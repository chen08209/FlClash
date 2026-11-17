package com.follow.clash.service

import android.app.Service
import android.content.ComponentCallbacks2
import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.GlobalState
import com.follow.clash.common.sendBroadcast
import com.follow.clash.core.Core
import java.util.concurrent.Executor
import java.util.concurrent.Executors

interface ManagedService {
    fun start()

    fun stop()
}

internal fun Service.notifyVpnStartRequested() {
    GlobalState.log("VPN start requested")
    BroadcastAction.VPN_START_REQUESTED.sendBroadcast()
}

internal fun Service.notifyVpnRevoked() {
    GlobalState.log("VPN permission revoked")
    BroadcastAction.VPN_REVOKED.sendBroadcast()
}

// Memory callbacks run on the main thread, and a Core call can wait there for a
// session to open.
private val coreMemoryCalls =
    Executors.newSingleThreadExecutor { task -> Thread(task, "core-memory").apply { isDaemon = true } }

// UI_HIDDEN reaches the services too, since they share the activity's process,
// and Android 14 stopped delivering the running levels this answers to.
@Suppress("DEPRECATION")
internal fun trimCoreMemory(
    level: Int,
    calls: Executor = coreMemoryCalls,
) = calls.execute {
    MitmPressure.onTrimMemory(level)
    if (level == ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW ||
        level == ComponentCallbacks2.TRIM_MEMORY_RUNNING_CRITICAL
    ) {
        Core.forceGC()
    }
}

internal fun lowCoreMemory(calls: Executor = coreMemoryCalls) =
    calls.execute {
        MitmPressure.onLowMemory()
        Core.forceGC()
    }
