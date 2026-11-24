package com.follow.clash.service.modules

import android.app.ActivityManager
import android.app.Service
import androidx.core.content.getSystemService
import com.follow.clash.service.MitmPressure
import com.follow.clash.service.ServiceConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

internal const val MEMORY_POLL_INTERVAL_MS = 15_000L

// Stands in for the running trim levels Android 14 stopped delivering.
internal class MemoryPressureModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    override fun start() {
        val activityManager = service.getSystemService<ActivityManager>() ?: return
        val info = ActivityManager.MemoryInfo()
        scope.launch {
            pollWhile(ServiceConfig.mitm) {
                activityManager.getMemoryInfo(info)
                MitmPressure.onMemoryInfo(info)
            }
        }
    }

    override fun stop() = Unit
}

internal suspend fun pollWhile(enabled: Flow<Boolean>, poll: () -> Unit) =
    enabled.collectLatest { on ->
        while (on) {
            poll()
            delay(MEMORY_POLL_INTERVAL_MS)
        }
    }
