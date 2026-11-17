package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.os.Process
import com.follow.clash.common.AccessControlMode
import com.follow.clash.core.Core
import com.follow.clash.core.TunOptions
import com.follow.clash.service.models.VpnOptions
import com.follow.clash.service.models.tunMtu
import com.follow.clash.service.modules.ServiceModules
import com.google.gson.Gson
import java.net.Inet6Address
import java.net.InetSocketAddress

class RootTunService : Service(), ManagedService {
    private val modules = ServiceModules(this)
    private val binder = LocalBinder()
    private val packageNames by lazy { UidPackageNames(packageManager) }
    private val tunLock = Any()
    private var tun: RootTun? = null

    override fun onDestroy() {
        try {
            cleanup()
        } finally {
            super.onDestroy()
        }
    }

    override fun onLowMemory() {
        lowCoreMemory()
        super.onLowMemory()
    }

    override fun onTrimMemory(level: Int) {
        trimCoreMemory(level)
        super.onTrimMemory(level)
    }

    inner class LocalBinder : Binder() {
        val service: RootTunService
            get() = this@RootTunService
    }

    override fun onBind(intent: Intent): IBinder = binder

    override fun start() {
        try {
            modules.start()
            handleStart(requireNotNull(ServiceConfig.vpnOptions) { "VPN options are missing" })
        } catch (error: Exception) {
            stop()
            throw error
        }
    }

    private fun handleStart(options: VpnOptions) {
        val opened = RootTun.open(this, Gson().toJson(provisionRequest(options)))
        synchronized(tunLock) {
            tun = opened
            try {
                Core.startTun(
                    fd = opened.fd,
                    protect = { true },
                    resolveUid = { protocol, source, _ -> opened.resolveUid(protocol, source.text) },
                    resolvePackage = packageNames::resolve,
                    options = TunOptions(
                        mtu = options.tunMtu,
                        address = options.tunAddress,
                        dns = listOf(VpnService.NET_ANY),
                        congestionController = options.congestionController,
                    ),
                )
            } catch (error: Exception) {
                stopTunLocked()
                throw error
            }
        }
        opened.watch { reason ->
            val current = synchronized(tunLock) { tun === opened }
            if (current) {
                notifyRootTunLost(reason)
            }
        }
    }

    // The core runs in this process unprotected, so this uid stays off the device. Only this
    // user's instance is meant: the uid already carries the user id.
    private fun provisionRequest(options: VpnOptions): Map<String, Any> = buildMap {
        put("mtu", options.tunMtu)
        put("inet4Address", listOf(VpnService.IPV4_ADDRESS))
        if (options.ipv6) put("inet6Address", listOf(VpnService.IPV6_ADDRESS))
        if (options.routeAddress.isNotEmpty()) put("routeAddress", options.routeAddress)
        put("excludeUid", listOf(Process.myUid()))
        val access = options.accessControlProps
        if (access.enable) {
            when (access.mode) {
                AccessControlMode.ACCEPT_SELECTED -> put("includePackage", access.acceptList - packageName)
                AccessControlMode.REJECT_SELECTED -> put("excludePackage", access.rejectList)
            }
        }
    }

    private val InetSocketAddress.text: String
        get() = if (address is Inet6Address) "[${address.hostAddress}]:$port" else "${address.hostAddress}:$port"

    override fun stop() {
        try {
            cleanup()
        } finally {
            stopSelf()
        }
    }

    private fun cleanup() {
        try {
            modules.stop()
        } finally {
            synchronized(tunLock) { stopTunLocked() }
        }
    }

    private fun stopTunLocked() {
        val current = tun ?: return
        tun = null
        try {
            Core.stopTun()
        } finally {
            current.close()
        }
    }
}
