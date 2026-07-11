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
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.os.Build
import androidx.core.content.getSystemService
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlin.reflect.KClass

val KClass<*>.intent: Intent
    get() = Intent(GlobalState.application, this.java)

val ComponentName.intent: Intent
    get() = Intent().apply {
        component = this@intent
    }

val QuickAction.action: String
    get() = "${GlobalState.application.packageName}.action.${this.name}"

val QuickAction.quickIntent: Intent
    get() = Components.quickActionActivity.intent.apply {
        action = this@quickIntent.action
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }

val BroadcastAction.action: String
    get() = "${GlobalState.application.packageName}.intent.action.${this.name}"

val Context.processName: String?
    get() = getSystemService<ActivityManager>()
        ?.runningAppProcesses
        ?.firstOrNull { it.pid == android.os.Process.myPid() }
        ?.processName

fun BroadcastAction.sendBroadcast() {
    val broadcastAction = action
    val intent = Intent(broadcastAction).apply {
        component = Components.serviceBroadcastReceiver
    }
    GlobalState.log("Send broadcast: $broadcastAction")
    GlobalState.application.sendBroadcast(
        intent,
        GlobalState.receiveBroadcastPermission,
    )
}

val Intent.toPendingIntent: PendingIntent
    get() = PendingIntent.getActivity(
        GlobalState.application,
        0,
        this,
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

fun Service.startForeground(notification: Notification) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val manager = getSystemService(NotificationManager::class.java)
        var channel = manager?.getNotificationChannel(GlobalState.NOTIFICATION_CHANNEL)
        if (channel == null) {
            channel = NotificationChannel(
                GlobalState.NOTIFICATION_CHANNEL,
                getString(R.string.service_channel_name),
                NotificationManager.IMPORTANCE_LOW,
            )
            manager?.createNotificationChannel(channel)
        }
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startForeground(
            GlobalState.NOTIFICATION_ID,
            notification,
            FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
        )
    } else {
        startForeground(GlobalState.NOTIFICATION_ID, notification)
    }
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
