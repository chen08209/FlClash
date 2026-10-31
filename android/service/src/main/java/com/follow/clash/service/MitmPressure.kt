package com.follow.clash.service

import android.app.ActivityManager
import android.content.ComponentCallbacks2
import com.follow.clash.core.Core

// The levels of mitm.SetPressure in the Core.
internal object MitmPressure {
    private const val NONE = 0
    private const val NO_SCRIPTS = 1
    private const val NO_BODIES = 2
    private const val RELAY = 3

    @Suppress("DEPRECATION")
    fun onTrimMemory(level: Int) = report(
        when (level) {
            ComponentCallbacks2.TRIM_MEMORY_RUNNING_MODERATE -> NO_SCRIPTS

            ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW,
            ComponentCallbacks2.TRIM_MEMORY_MODERATE -> NO_BODIES

            ComponentCallbacks2.TRIM_MEMORY_RUNNING_CRITICAL,
            ComponentCallbacks2.TRIM_MEMORY_COMPLETE -> RELAY

            else -> NONE
        },
    )

    fun onLowMemory() = report(RELAY)

    fun onMemoryInfo(info: ActivityManager.MemoryInfo) = report(
        when {
            info.lowMemory -> NO_BODIES
            info.availMem < info.threshold * 2 -> NO_SCRIPTS
            else -> NONE
        },
    )

    private fun report(level: Int) {
        if (level != NONE) {
            Core.setMitmPressure(level)
        }
    }
}
