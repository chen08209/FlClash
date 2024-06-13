package com.follow.clash.extensions

import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.system.OsConstants.IPPROTO_TCP
import android.system.OsConstants.IPPROTO_UDP
import android.util.Base64
import java.net.URL
import androidx.core.graphics.drawable.toBitmap
import com.follow.clash.models.Metadata
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.net.InetAddress
import java.net.InetSocketAddress


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

fun String.getInetSocketAddress(): InetSocketAddress {
    val url = URL("https://$this")
    return InetSocketAddress(InetAddress.getByName(url.host), url.port)
}
