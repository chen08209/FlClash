package com.follow.clash.service.modules

import android.app.ActivityManager
import android.app.Service
import androidx.core.content.getSystemService
import com.follow.clash.service.MitmPressure
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

private const val POLL_INTERVAL_MS = 15_000L

// Stands in for the running trim levels Android 14 stopped delivering.
internal class MemoryPressureModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    override fun start() {
        val activityManager = service.getSystemService<ActivityManager>() ?: return
        scope.launch {
            val info = ActivityManager.MemoryInfo()
            while (isActive) {
                activityManager.getMemoryInfo(info)
                MitmPressure.onMemoryInfo(info)
                delay(POLL_INTERVAL_MS)
            }
        }
    }

    override fun stop() = Unit
}
