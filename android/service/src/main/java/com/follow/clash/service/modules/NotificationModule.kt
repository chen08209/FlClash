package com.follow.clash.service.modules

import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.Service
import android.app.Service.STOP_FOREGROUND_REMOVE
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.core.content.getSystemService
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import com.follow.clash.common.QuickAction
import com.follow.clash.common.quickIntent
import com.follow.clash.common.receiveBroadcastFlow
import com.follow.clash.common.startForeground
import com.follow.clash.common.tickerFlow
import com.follow.clash.common.toPendingIntent
import com.follow.clash.core.Core
import com.follow.clash.service.R
import com.follow.clash.service.State
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.getSpeedTrafficText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

data class ExtendedNotificationParams(
    val title: String,
    val stopText: String,
    val onlyStatisticsProxy: Boolean,
    val contentText: String,
)

val NotificationParams.extended: ExtendedNotificationParams
    get() = ExtendedNotificationParams(
        title, stopText, onlyStatisticsProxy, Core.getSpeedTrafficText(onlyStatisticsProxy)
    )

class NotificationModule(private val service: Service) : Module() {
    private val scope = CoroutineScope(Dispatchers.Default)

    override fun onInstall() {
        State.notificationParamsFlow.value?.let {
            update(it.extended)
        }
        scope.launch {
            val screenFlow = service.receiveBroadcastFlow {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
            }.map { intent ->
                intent.action == Intent.ACTION_SCREEN_ON
            }.onStart {
                emit(isScreenOn())
            }

            combine(
                tickerFlow(1000, 0), State.notificationParamsFlow, screenFlow
            ) { _, params, screenOn ->
                params?.extended to screenOn
            }.filter { (params, screenOn) -> params != null && screenOn }
                .distinctUntilChanged { old, new -> old.first == new.first && old.second == new.second }
                .collect { (params, _) ->
                    update(params!!)
                }
        }
    }

    private fun isScreenOn(): Boolean {
        val pm = service.getSystemService<PowerManager>()
        return when (pm != null) {
            true -> pm.isInteractive
            false -> true
        }
    }

    private val notificationBuilder: NotificationCompat.Builder by lazy {
        val intent = Intent().setComponent(Components.MAIN_ACTIVITY)
        with(
            NotificationCompat.Builder(
                service, GlobalState.NOTIFICATION_CHANNEL
            )
        ) {
            setSmallIcon(R.drawable.ic)
            setContentTitle("FlClash")
            setContentIntent(intent.toPendingIntent)
            setCategory(NotificationCompat.CATEGORY_SERVICE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
            }
            setOngoing(true)
            setShowWhen(false)
            setOnlyAlertOnce(true)
        }
    }

    private fun update(params: ExtendedNotificationParams) {
        service.startForeground(
            with(notificationBuilder) {
                setContentTitle(params.title)
                setContentText(params.contentText)
                setPriority(NotificationCompat.PRIORITY_HIGH)
                clearActions()
                addAction(
                    0, params.stopText, QuickAction.STOP.quickIntent.toPendingIntent
                ).build()
            })
    }

    override fun onUninstall() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            service.stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            service.stopForeground(true)
        }
        scope.cancel()
    }
}