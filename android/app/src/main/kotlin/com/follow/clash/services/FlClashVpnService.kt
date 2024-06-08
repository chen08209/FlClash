package com.follow.clash.services

import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.net.ProxyInfo
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.follow.clash.GlobalState
import com.follow.clash.MainActivity
import com.follow.clash.R
import com.follow.clash.models.AccessControl
import com.follow.clash.models.AccessControlMode


class FlClashVpnService : VpnService() {


    private val CHANNEL = "FlClash"

    var fd: Int? = null
    private val notificationId: Int = 1

    private val passList = listOf(
        "*zhihu.com",
        "*zhimg.com",
        "*jd.com",
        "100ime-iat-api.xfyun.cn",
        "*360buyimg.com",
        "localhost",
        "*.local",
        "127.*",
        "10.*",
        "172.16.*",
        "172.17.*",
        "172.18.*",
        "172.19.*",
        "172.2*",
        "172.30.*",
        "172.31.*",
        "192.168.*"
    )

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    fun start(port: Int, accessControl: AccessControl?) {
        fd = with(Builder()) {
            addAddress("172.16.0.1", 30)
            setMtu(9000)
            addRoute("0.0.0.0", 0)
            if (accessControl != null) {
                when (accessControl.mode) {
                    AccessControlMode.acceptSelected -> {
                        (accessControl.acceptList + packageName).forEach {
                            addAllowedApplication(it)
                        }
                    }

                    AccessControlMode.rejectSelected -> {
                        (accessControl.rejectList - packageName).forEach {
                            addDisallowedApplication(it)
                        }
                    }
                }
            }
            addDnsServer("172.16.0.2")
            setSession("FlClash")
            setBlocking(false)
            if (Build.VERSION.SDK_INT >= 29) {
                setMetered(false)
            }
            allowBypass()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                setHttpProxy(
                    ProxyInfo.buildDirectProxy(
                        "127.0.0.1",
                        port,
                        passList
                    )
                )
            }
            establish()?.detachFd()
        }
    }

    fun stop() {
        stopSelf()
        stopForeground()
    }


    private val notificationBuilder: NotificationCompat.Builder by lazy {
        val intent = Intent(this, MainActivity::class.java)

        val pendingIntent = if (Build.VERSION.SDK_INT >= 31) {
            PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        } else {
            PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT
            )
        }

        with(NotificationCompat.Builder(this, CHANNEL)) {
            setSmallIcon(R.drawable.ic_stat_name)
            setContentTitle("FlClash")
            setContentIntent(pendingIntent)
            setCategory(NotificationCompat.CATEGORY_SERVICE)
            priority = NotificationCompat.PRIORITY_MIN
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                foregroundServiceBehavior = FOREGROUND_SERVICE_IMMEDIATE
            }
            setOngoing(true)
            setShowWhen(false)
            setOnlyAlertOnce(true)
            setAutoCancel(true);
        }
    }


    fun startForeground(title: String, content: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel =
                NotificationChannel(CHANNEL, "FlClash", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
            channel.setShowBadge(false)
        }
        val notification =
            notificationBuilder.setContentTitle(title).setContentText(content).build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(notificationId, notification,  FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        }else{
            startForeground(notificationId, notification)
        }
    }

    private fun stopForeground() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        }
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): FlClashVpnService = this@FlClashVpnService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        GlobalState.getCurrentTilePlugin()?.handleStop();
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        stop()
        super.onDestroy()
    }
}