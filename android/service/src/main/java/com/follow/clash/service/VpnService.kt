package com.follow.clash.service

import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.ProxyInfo
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.content.getSystemService
import com.follow.clash.common.AccessControlMode
import com.follow.clash.common.GlobalState
import com.follow.clash.common.R as CommonR
import com.follow.clash.core.Core
import com.follow.clash.service.models.CIDR
import com.follow.clash.service.models.VpnOptions
import com.follow.clash.service.models.getIpv4RouteAddress
import com.follow.clash.service.models.getIpv6RouteAddress
import com.follow.clash.service.models.toCIDR
import com.follow.clash.service.modules.ServiceModules
import java.net.InetSocketAddress
import java.util.concurrent.ConcurrentHashMap
import android.net.VpnService as SystemVpnService

class VpnService : SystemVpnService(), ManagedService {
    private val modules = ServiceModules(this)
    private val binder = LocalBinder()
    private val tunLock = Any()
    private var tunRunning = false

    override fun onDestroy() {
        try {
            cleanup()
        } finally {
            super.onDestroy()
        }
    }

    private val connectivity by lazy {
        getSystemService<ConnectivityManager>()
    }
    private val uidPackageNameMap = ConcurrentHashMap<Int, String>()

    private fun resolveUid(
        protocol: Int,
        source: InetSocketAddress,
        target: InetSocketAddress,
    ): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return -1
        }
        return connectivity?.getConnectionOwnerUid(protocol, source, target) ?: -1
    }

    private fun resolvePackage(uid: Int): String {
        val cached = uidPackageNameMap[uid]
        if (cached != null) return cached
        val packageName = packageManager
            .getPackagesForUid(uid)
            ?.firstOrNull()
            ?.takeIf { it.isNotEmpty() }
            .orEmpty()
        return uidPackageNameMap.putIfAbsent(uid, packageName) ?: packageName
    }

    private val VpnOptions.tunAddress
        get(): String = buildString {
            append(IPV4_ADDRESS)
            if (ipv6) {
                append(",")
                append(IPV6_ADDRESS)
            }
        }

    private val VpnOptions.tunDns
        get(): String {
            if (dnsHijacking) {
                return NET_ANY
            }
            return buildString {
                append(DNS)
                if (ipv6) {
                    append(",")
                    append(DNS6)
                }
            }
        }

    override fun onLowMemory() {
        Core.forceGC()
        super.onLowMemory()
    }

    inner class LocalBinder : Binder() {
        val service: VpnService
            get() = this@VpnService
    }

    override fun onBind(intent: Intent): IBinder? =
        if (intent.action == SystemVpnService.SERVICE_INTERFACE) {
            super.onBind(intent)
        } else {
            binder
        }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Android starts always-on VPN through this callback instead of FlClash's bound-service
        // path. Notify the app layer so it can restore Core and fully initialize the VPN service.
        notifyVpnStartRequested()
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onRevoke() {
        stop()
        notifyVpnRevoked()
    }

    private fun handleStart(options: VpnOptions) {
        val fd = with(Builder()) {
            addAddressAndRoutes(options)
            addDnsServers(options)
            setMtu(MTU)
            configureAccessControl(options)
            setSession(getString(CommonR.string.app_name))
            setBlocking(false)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                setMetered(false)
            }
            if (options.allowBypass) {
                allowBypass()
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && options.systemProxy) {
                GlobalState.log("Enable VPN HTTP proxy")
                setHttpProxy(
                    ProxyInfo.buildDirectProxy(
                        LOCAL_HOST,
                        options.port,
                        options.bypassDomain,
                    ),
                )
            }
            establish()?.detachFd()
                ?: error("VPN establishment was rejected by the system")
        }
        synchronized(tunLock) {
            tunRunning = true
            try {
                // A Core that fails to take the descriptor leaves the system
                // routes pointing at an interface nothing reads, and it no
                // longer keeps its own sockets out of them: every connection
                // then hangs until it times out. Tear the VPN down instead of
                // reporting a start that only looks successful.
                check(
                    Core.startTun(
                        fd = fd,
                        protect = this::protect,
                        resolveUid = this::resolveUid,
                        resolvePackage = this::resolvePackage,
                        stack = options.stack,
                        address = options.tunAddress,
                        dns = options.tunDns,
                    ),
                ) { "Core rejected the tun file descriptor" }
            } catch (error: Exception) {
                stopTunLocked()
                throw error
            }
        }
    }

    private fun Builder.addAddressAndRoutes(options: VpnOptions) {
        val ipv4Address = IPV4_ADDRESS.toCIDR()
        addAddress(ipv4Address.address, ipv4Address.prefixLength)
        addRoutes(
            routes = options::getIpv4RouteAddress,
            fallbackAddress = NET_ANY,
            logTag = "addRoute4",
        )

        if (options.ipv6) {
            try {
                val ipv6Address = IPV6_ADDRESS.toCIDR()
                addAddress(ipv6Address.address, ipv6Address.prefixLength)
            } catch (_: Exception) {
                GlobalState.log("IPv6 VPN address is not supported")
            }
            addRoutes(
                routes = options::getIpv6RouteAddress,
                fallbackAddress = NET_ANY6,
                logTag = "addRoute6",
            )
        }
    }

    private fun Builder.addRoutes(
        routes: () -> List<CIDR>,
        fallbackAddress: String,
        logTag: String,
    ) {
        val routeList = runCatching(routes).getOrDefault(emptyList())
        if (routeList.isEmpty()) {
            addRoute(fallbackAddress, 0)
            return
        }
        try {
            routeList.forEach { route ->
                Log.d(logTag, "address: ${route.address} prefixLength: ${route.prefixLength}")
                addRoute(route.address, route.prefixLength)
            }
        } catch (_: Exception) {
            addRoute(fallbackAddress, 0)
        }
    }

    private fun Builder.addDnsServers(options: VpnOptions) {
        addDnsServer(DNS)
        if (options.ipv6) {
            addDnsServer(DNS6)
        }
    }

    private fun Builder.configureAccessControl(options: VpnOptions) {
        val accessControl = options.accessControlProps
        if (!accessControl.enable) return
        when (accessControl.mode) {
            AccessControlMode.ACCEPT_SELECTED -> {
                (accessControl.acceptList + packageName).forEach { name ->
                    addApplication(name, ::addAllowedApplication)
                }
            }

            AccessControlMode.REJECT_SELECTED -> {
                (accessControl.rejectList - packageName).forEach { name ->
                    addApplication(name, ::addDisallowedApplication)
                }
            }
        }
    }

    // A selected package that was uninstalled since must not veto the whole tunnel.
    private fun addApplication(name: String, add: (String) -> Builder) {
        try {
            add(name)
        } catch (_: PackageManager.NameNotFoundException) {
            GlobalState.log("Access control skipped an uninstalled package: $name")
        }
    }

    override fun start() {
        try {
            modules.start()
            handleStart(requireNotNull(ServiceConfig.vpnOptions) { "VPN options are missing" })
        } catch (error: Exception) {
            stop()
            throw error
        }
    }

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
            stopTun()
        }
    }

    private fun stopTun() = synchronized(tunLock) {
        stopTunLocked()
    }

    private fun stopTunLocked() {
        if (tunRunning) {
            Core.stopTun()
            tunRunning = false
        }
    }

    companion object {
        private const val IPV4_ADDRESS = "172.19.0.1/30"
        private const val IPV6_ADDRESS = "fdfe:dcba:9876::1/126"
        private const val DNS = "172.19.0.2"
        private const val DNS6 = "fdfe:dcba:9876::2"
        private const val NET_ANY = "0.0.0.0"
        private const val NET_ANY6 = "::"
        private const val LOCAL_HOST = "127.0.0.1"
        private const val MTU = 9000
    }
}
