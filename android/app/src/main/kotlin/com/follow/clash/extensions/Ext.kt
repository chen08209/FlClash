package com.follow.clash.extensions

import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.net.ConnectivityManager
import android.net.Network
import android.system.OsConstants.IPPROTO_TCP
import android.system.OsConstants.IPPROTO_UDP
import android.util.Base64
import androidx.core.graphics.drawable.toBitmap
import com.follow.clash.models.Metadata
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress


suspend fun Drawable.getBase64(): String {
    val drawable = this
    return withContext(Dispatchers.IO) {
        val bitmap = drawable.toBitmap()
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        Base64.encodeToString(byteArrayOutputStream.toByteArray(), Base64.NO_WRAP)
    }
}

fun Metadata.getProtocol(): Int? {
    if (network.startsWith("tcp")) return IPPROTO_TCP
    if (network.startsWith("udp")) return IPPROTO_UDP
    return null
}


fun ConnectivityManager.resolveDns(network: Network?): List<String> {
    val properties = getLinkProperties(network) ?: return listOf()
    return properties.dnsServers.map { it.asSocketAddressText(53) }
}

fun InetAddress.asSocketAddressText(port: Int): String {
    return when (this) {
        is Inet6Address ->
            "[${numericToTextFormat(this.address)}]:$port"

        is Inet4Address ->
            "${this.hostAddress}:$port"

        else -> throw IllegalArgumentException("Unsupported Inet type ${this.javaClass}")
    }
}


private fun numericToTextFormat(src: ByteArray): String {
    val sb = StringBuilder(39)
    for (i in 0 until 8) {
        sb.append(
            Integer.toHexString(
                src[i shl 1].toInt() shl 8 and 0xff00
                        or (src[(i shl 1) + 1].toInt() and 0xff)
            )
        )
        if (i < 7) {
            sb.append(":")
        }
    }
    return sb.toString()
}
