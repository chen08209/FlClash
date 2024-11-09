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
import android.util.Log
import androidx.core.app.NotificationCompat
import com.follow.clash.BaseServiceInterface
import com.follow.clash.GlobalState
import com.follow.clash.MainActivity
import com.follow.clash.R
import com.follow.clash.extensions.getActionPendingIntent
import com.follow.clash.extensions.getIpv4RouteAddress
import com.follow.clash.extensions.getIpv6RouteAddress
import com.follow.clash.extensions.toCIDR
import com.follow.clash.models.AccessControlMode
import com.follow.clash.models.VpnOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch


class FlClashVpnService : VpnService(), BaseServiceInterface {
    override fun onCreate() {
        super.onCreate()
        GlobalState.initServiceEngine(applicationContext)
    }

    override fun start(options: VpnOptions): Int {
        return with(Builder()) {
            if (options.ipv4Address.isNotEmpty()) {
                val cidr = options.ipv4Address.toCIDR()
                addAddress(cidr.address, cidr.prefixLength)
                val routeAddress = options.getIpv4RouteAddress()
                if (routeAddress.isNotEmpty()) {
                    routeAddress.forEach { i ->
                        Log.d("addRoute4", "address: ${i.address} prefixLength:${i.prefixLength}")
                        addRoute(i.address, i.prefixLength)
                    }
                } else {
                    addRoute("0.0.0.0", 0)
                }
            }
            if (options.ipv6Address.isNotEmpty()) {
                val cidr = options.ipv6Address.toCIDR()
                addAddress(cidr.address, cidr.prefixLength)
                val routeAddress = options.getIpv6RouteAddress()
                if (routeAddress.isNotEmpty()) {
                    routeAddress.forEach { i ->
                        Log.d("addRoute6", "address: ${i.address} prefixLength:${i.prefixLength}")
                        addRoute(i.address, i.prefixLength)
                    }
                } else {
                    addRoute("::", 0)
                }
            }
            addDnsServer(options.dnsServerAddress)
            setMtu(9000)
            options.accessControl?.let { accessControl ->
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
            if (options.allowBypass) {
                allowBypass()
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.systemProxy) {
                setHttpProxy(
                    ProxyInfo.buildDirectProxy(
                        "127.0.0.1",
                        options.port,
                        options.bypassDomain
                    )
                )
            }
            establish()?.detachFd()
                ?: throw NullPointerException("Establish VPN rejected by system")
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
            addAction(
                0,
                GlobalState.getText("stop"),
                getActionPendingIntent("STOP")
            )
            setShowWhen(false)
            setOnlyAlertOnce(true)
            setAutoCancel(true)
        }
    }

    @SuppressLint("ForegroundServiceType", "WrongConstant")
    override fun startForeground(title: String, content: String) {
        CoroutineScope(Dispatchers.Default).launch {
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
                notificationBuilder
                    .setContentTitle(title)
                    .setContentText(content)
                    .build()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(notificationId, notification, FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            } else {
                startForeground(notificationId, notification)
            }
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