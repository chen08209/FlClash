package com.follow.clash.services

import android.annotation.SuppressLint
import android.app.Notification.FOREGROUND_SERVICE_IMMEDIATE
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
import android.net.Network
import android.net.ProxyInfo
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.Parcel
import android.os.RemoteException
import androidx.core.app.NotificationCompat
import com.follow.clash.BaseServiceInterface
import com.follow.clash.GlobalState
import com.follow.clash.MainActivity
import com.follow.clash.R
import com.follow.clash.TempActivity
import com.follow.clash.models.AccessControlMode
import com.follow.clash.models.Props
import com.follow.clash.models.TunProps
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch


class FlClashVpnService : VpnService(), BaseServiceInterface {

    companion object {
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
        private const val TUN_MTU = 9000
        private const val TUN_SUBNET_PREFIX = 30
        private const val TUN_GATEWAY = "172.19.0.1"
        private const val TUN_SUBNET_PREFIX6 = 126
        private const val TUN_GATEWAY6 = "fdfe:dcba:9876::1"
        private const val TUN_PORTAL = "172.19.0.2"
        private const val TUN_PORTAL6 = "fdfe:dcba:9876::2"
        private const val TUN_DNS = TUN_PORTAL
        private const val TUN_DNS6 = TUN_PORTAL6
        private const val NET_ANY = "0.0.0.0"
        private const val NET_ANY6 = "::"
    }

    override fun onCreate() {
        super.onCreate()
        GlobalState.initServiceEngine(applicationContext)
    }

    override fun start(port: Int, props: Props?): TunProps {
        return with(Builder()) {
            addAddress(TUN_GATEWAY, TUN_SUBNET_PREFIX)
            addRoute(NET_ANY, 0)
            addDnsServer(TUN_DNS)


            if (props?.ipv6 == true) {
                try {
                    addAddress(TUN_GATEWAY6, TUN_SUBNET_PREFIX6)
                    addRoute(NET_ANY6, 0)
                    addDnsServer(TUN_DNS6)
                } catch (_: Exception) {

                }
            }
            setMtu(TUN_MTU)
            props?.accessControl?.let { accessControl ->
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
            setSession("FlClash")
            setBlocking(false)
            if (Build.VERSION.SDK_INT >= 29) {
                setMetered(false)
            }
            if (props?.allowBypass == true) {
                allowBypass()
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && props?.systemProxy == true) {
                setHttpProxy(
                    ProxyInfo.buildDirectProxy(
                        "127.0.0.1",
                        port,
                        passList
                    )
                )
            }
            TunProps(
                fd = establish()?.detachFd()
                    ?: throw NullPointerException("Establish VPN rejected by system"),
                gateway = "$TUN_GATEWAY/$TUN_SUBNET_PREFIX",
                gateway6 = if (props?.ipv6 == true) "$TUN_GATEWAY6/$TUN_SUBNET_PREFIX6" else "",
                portal = TUN_PORTAL,
                portal6 = if (props?.ipv6 == true) TUN_PORTAL6 else "",
                dns = TUN_DNS,
                dns6 = if (props?.ipv6 == true) TUN_DNS6 else ""
            )
        }
    }

    fun updateUnderlyingNetworks(networks: Array<Network>) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            this.setUnderlyingNetworks(networks)
        }
    }

    override fun stop() {
        stopSelf()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        }
    }

    private val CHANNEL = "FlClash"

    private val notificationId: Int = 1

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

        val stopIntent = Intent(this, TempActivity::class.java)
        stopIntent.action = "com.follow.clash.action.STOP"
        stopIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)


        val stopPendingIntent = if (Build.VERSION.SDK_INT >= 31) {
            PendingIntent.getActivity(
                this,
                0,
                stopIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        } else {
            PendingIntent.getActivity(
                this,
                0,
                stopIntent,
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
            setAutoCancel(true)
            addAction(0, "Stop", stopPendingIntent);
        }
    }

    @SuppressLint("ForegroundServiceType", "WrongConstant")
    override fun startForeground(title: String, content: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            var channel = manager?.getNotificationChannel(CHANNEL)
            if (channel == null) {
                channel =
                    NotificationChannel(CHANNEL, "FlClash", NotificationManager.IMPORTANCE_LOW)
                manager?.createNotificationChannel(channel)
            }
        }
        val notification =
            notificationBuilder.setContentTitle(title).setContentText(content).build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(notificationId, notification, FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(notificationId, notification)
        }
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        GlobalState.getCurrentVPNPlugin()?.requestGc()
    }

    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): FlClashVpnService = this@FlClashVpnService

        override fun onTransact(code: Int, data: Parcel, reply: Parcel?, flags: Int): Boolean {
            try {
                val isSuccess = super.onTransact(code, data, reply, flags)
                if (!isSuccess) {
                    CoroutineScope(Dispatchers.Main).launch {
                        GlobalState.getCurrentTilePlugin()?.handleStop()
                    }
                }
                return isSuccess
            } catch (e: RemoteException) {
                throw e
            }
        }
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun onUnbind(intent: Intent?): Boolean {
        return super.onUnbind(intent)
    }

    override fun onDestroy() {
        stop()
        super.onDestroy()
    }
}