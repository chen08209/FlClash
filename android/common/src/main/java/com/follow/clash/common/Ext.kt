package com.follow.clash.common

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Context.RECEIVER_NOT_EXPORTED
import android.content.Intent
import android.content.IntentFilter
import android.content.ServiceConnection
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.RemoteException
import android.util.Log
import androidx.core.content.getSystemService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.retryWhen
import kotlinx.coroutines.withContext
import java.nio.charset.Charset
import kotlin.reflect.KClass

//fun Context.startForegroundServiceCompat(intent: Intent?) {
//    if (Build.VERSION.SDK_INT >= 26) {
//        startForegroundService(intent)
//    } else {
//        startService(intent)
//    }
//}

val KClass<*>.intent: Intent
    get() = Intent(GlobalState.application, this.java)

fun Service.startForegroundCompat(id: Int, notification: Notification) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startForeground(id, notification, FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
    } else {
        startForeground(id, notification)
    }
}

val ComponentName.intent: Intent
    get() = Intent().apply {
        setComponent(this@intent)
        setPackage(GlobalState.packageName)
    }

val QuickAction.action: String
    get() = "${GlobalState.application.packageName}.action.${this.name}"

val QuickAction.quickIntent: Intent
    get() = Components.TEMP_ACTIVITY.intent.apply {
        action = this@quickIntent.action
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
    }

val BroadcastAction.action: String
    get() = "${GlobalState.application.packageName}.intent.action.${this.name}"

val Context.processName: String?
    get() {
        val pid = android.os.Process.myPid()
        val activityManager = getSystemService<ActivityManager>()
        activityManager?.runningAppProcesses?.find { it.pid == pid }?.let {
            return it.processName
        }
        return null
    }

val BroadcastAction.quickIntent: Intent
    get() = Components.BROADCAST_RECEIVER.intent.apply {
        action = this@quickIntent.action
    }

fun BroadcastAction.sendBroadcast() {
    val intent = Intent().apply {
        action = this@sendBroadcast.action
        Log.d("[sendBroadcast]", "$action")
        setPackage(GlobalState.packageName)
    }
    GlobalState.application.sendBroadcast(
        intent, GlobalState.RECEIVE_BROADCASTS_PERMISSIONS
    )
}


val Intent.toPendingIntent: PendingIntent
    get() = PendingIntent.getActivity(
        GlobalState.application,
        0,
        this,
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )


fun Service.startForeground(notification: Notification) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val manager = getSystemService(NotificationManager::class.java)
        var channel = manager?.getNotificationChannel(GlobalState.NOTIFICATION_CHANNEL)
        if (channel == null) {
            channel = NotificationChannel(
                GlobalState.NOTIFICATION_CHANNEL,
                "SERVICE_CHANNEL",
                NotificationManager.IMPORTANCE_LOW
            )
            manager?.createNotificationChannel(channel)
        }
    }
    startForegroundCompat(GlobalState.NOTIFICATION_ID, notification)
}

@SuppressLint("UnspecifiedRegisterReceiverFlag")
fun Context.registerReceiverCompat(
    receiver: BroadcastReceiver,
    filter: IntentFilter,
) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    registerReceiver(receiver, filter, RECEIVER_NOT_EXPORTED)
} else {
    registerReceiver(receiver, filter)
}

fun Context.receiveBroadcastFlow(
    configure: IntentFilter.() -> Unit,
): Flow<Intent> = callbackFlow {
    val filter = IntentFilter().apply(configure)
    val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (context == null || intent == null) return
            trySend(intent)
        }
    }
    registerReceiverCompat(receiver, filter)
    awaitClose { unregisterReceiver(receiver) }
}


inline fun <reified T : IBinder> Context.bindServiceFlow(
    intent: Intent,
    flags: Int = Context.BIND_AUTO_CREATE,
    maxRetries: Int = 10,
    retryDelayMillis: Long = 200L
): Flow<Pair<IBinder?, String>> = callbackFlow {
    val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            if (binder != null) {
                try {
                    @Suppress("UNCHECKED_CAST") val casted = binder as? T
                    if (casted != null) {
                        trySend(Pair(casted, ""))
                    } else {
                        trySend(Pair(null, "Binder is not of type ${T::class.java}"))
                    }
                } catch (e: RemoteException) {
                    trySend(Pair(null, "Failed to link to death: ${e.message}"))
                }
            } else {
                trySend(Pair(null, "Binder empty"))
            }
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            trySend(Pair(null, "Service disconnected"))
        }
    }

    val success = withContext(Dispatchers.Main) {
        bindService(intent, connection, flags)
    }

    if (!success) {
        throw IllegalStateException("bindService() failed, will retry")
    }

    awaitClose {
        Handler(Looper.getMainLooper()).post {
            unbindService(connection)
            trySend(Pair(null, ""))
        }
    }
}.retryWhen { cause, attempt ->
    if (attempt < maxRetries && cause is Exception) {
        delay(retryDelayMillis)
        true
    } else {
        false
    }
}


val Long.formatBytes: String
    get() {
        val units = arrayOf("B", "KB", "MB", "GB", "TB")
        var size = this.toDouble()
        var unitIndex = 0

        while (size >= 1024 && unitIndex < units.size - 1) {
            size /= 1024
            unitIndex++
        }

        return if (unitIndex == 0) {
            "${size.toLong()}${units[unitIndex]}"
        } else {
            "%.1f${units[unitIndex]}".format(size)
        }
    }

fun String.chunkedForAidl(charset: Charset = Charsets.UTF_8): List<ByteArray> {
    val allBytes = toByteArray(charset)
    val total = allBytes.size
    val maxBytes = when {
        total <= 100 * 1024 -> total
        total <= 1024 * 1024 -> 64 * 1024
        total <= 10 * 1024 * 1024 -> 128 * 1024
        else -> 256 * 1024
    }

    val result = mutableListOf<ByteArray>()
    var index = 0
    while (index < total) {
        val end = minOf(index + maxBytes, total)
        result.add(allBytes.copyOfRange(index, end))
        index = end
    }
    return result
}


fun <T : List<ByteArray>> T.formatString(charset: Charset = Charsets.UTF_8): String {
    val totalSize = this.sumOf { it.size }
    val combined = ByteArray(totalSize)
    var offset = 0
    forEach { byteArray ->
        byteArray.copyInto(combined, offset)
        offset += byteArray.size
    }
    return String(combined, charset)
}