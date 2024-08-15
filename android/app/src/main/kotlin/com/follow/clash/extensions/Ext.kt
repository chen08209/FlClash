package com.follow.clash.extensions

import android.annotation.SuppressLint
import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.os.Build
import android.system.OsConstants.IPPROTO_TCP
import android.system.OsConstants.IPPROTO_UDP
import android.util.Base64
import androidx.core.app.NotificationCompat
import androidx.core.graphics.drawable.toBitmap
import com.follow.clash.MainActivity
import com.follow.clash.R
import com.follow.clash.models.Metadata
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream


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

private val CHANNEL = "FlClash"

private val notificationId: Int = 1
