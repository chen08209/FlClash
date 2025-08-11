package com.follow.clash

import android.content.Intent
import com.follow.clash.common.GlobalState
import com.follow.clash.common.intent
import com.follow.clash.common.plugin
import com.follow.clash.common.startForegroundServiceCompat
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.CommonService
import com.follow.clash.service.VpnService
import com.follow.clash.service.models.VpnOptions
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.flow.MutableStateFlow
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

enum class RunState {
    START,
    PENDING,
    STOP
}


object AppState {
    var options: VpnOptions? = null
    var intent: Intent? = null

    val runLock = ReentrantLock()

    var runTime: Long = 0

    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)
    var flutterEngine: FlutterEngine? = null

    val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>()

    val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>()

    fun handleToggle() {
        var action: (() -> Unit)?
        runLock.lock()
        try {
            action = when (runStateFlow.value) {
                RunState.PENDING -> null
                RunState.START -> ::handleStartService
                RunState.STOP -> ::handleStopService
            }
        } finally {
            runLock.unlock()
        }
        action?.invoke()
    }

    fun handleStartService() {
        runLock.withLock {
            if (runStateFlow.value == RunState.PENDING || runStateFlow.value == RunState.START) {
                return
            }
            runStateFlow.tryEmit(RunState.PENDING)
            if (options == null) {
                return
            }
            val vpn = options!!.enable
            intent = if (vpn) {
                VpnService::class.intent
            } else {
                CommonService::class.intent
            }
            if (vpn) {
                appPlugin?.startVpnService {
                    GlobalState.application.startForegroundServiceCompat(intent)
                }
            } else {
                GlobalState.application.startForegroundServiceCompat(intent)
            }
            runStateFlow.tryEmit(RunState.START)
            runTime = System.currentTimeMillis()
        }
    }

    fun handleStopService() {
        runLock.withLock {
            if (runStateFlow.value == RunState.PENDING || runStateFlow.value == RunState.STOP) {
                return
            }
            runStateFlow.tryEmit(RunState.PENDING)
            if (intent == null) {
                return
            }
            GlobalState.application.stopService(intent)
            intent = null
            runStateFlow.tryEmit(RunState.STOP)
            runTime = 0
        }
    }

    fun requestNotificationsPermission() {
        appPlugin?.requestNotificationsPermission()
    }
}


