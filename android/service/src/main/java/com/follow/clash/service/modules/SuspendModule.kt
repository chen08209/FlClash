package com.follow.clash.service.modules

import android.app.Service
import android.content.Intent
import android.os.PowerManager
import androidx.core.content.getSystemService
import com.follow.clash.common.receiveBroadcastFlow
import com.follow.clash.core.Core
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.launch

internal class SuspendModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {
    private fun isScreenOn() =
        service.getSystemService<PowerManager>()?.isInteractive ?: true

    private val isDeviceIdle: Boolean
        get() = service.getSystemService<PowerManager>()?.isDeviceIdleMode ?: true

    private fun updateSuspension(screenOn: Boolean) {
        Core.suspended(!screenOn && isDeviceIdle)
    }

    override fun start() {
        scope.launch {
            val screenFlow = service.receiveBroadcastFlow {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(PowerManager.ACTION_DEVICE_IDLE_MODE_CHANGED)
            }.map {
                isScreenOn()
            }.onStart {
                emit(isScreenOn())
            }

            screenFlow.collect(::updateSuspension)
        }
    }

    override fun stop() {
        Core.suspended(false)
    }
}
