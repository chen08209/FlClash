package com.follow.clash

import com.follow.clash.common.GlobalState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.ServicePlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

enum class RunState {
    START, PENDING, STOP
}


object State {

    val runLock = Mutex()

    var runTime: Long = 0

    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)
    var flutterEngine: FlutterEngine? = null
    var serviceFlutterEngine: FlutterEngine? = null

    val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>() ?: serviceFlutterEngine?.plugin<AppPlugin>()

    val servicePlugin: ServicePlugin?
        get() = flutterEngine?.plugin<ServicePlugin>()
            ?: serviceFlutterEngine?.plugin<ServicePlugin>()

    val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>() ?: serviceFlutterEngine?.plugin<TilePlugin>()

    suspend fun handleToggleAction() {
        var action: (suspend () -> Unit)?
        runLock.withLock {
            action = when (runStateFlow.value) {
                RunState.PENDING -> null
                RunState.START -> ::handleStopServiceAction
                RunState.STOP -> ::handleStartServiceAction
            }
        }
        action?.invoke()
    }

    suspend fun handleStartServiceAction() {
        tilePlugin?.handleStart()
        startServiceWithEngine()
    }

    suspend fun handleStopServiceAction() {
        tilePlugin?.handleStop()
        destroyServiceEngine()
    }

    fun handleStartService() {
        if (appPlugin != null) {
            appPlugin?.requestNotificationsPermission {
                startService()
            }
            return
        }
        startService()
    }

    suspend fun destroyServiceEngine() {
        runLock.withLock {
            serviceFlutterEngine?.destroy()
            serviceFlutterEngine = null
        }
    }

    suspend fun startServiceWithEngine() {
        if (flutterEngine != null) {
            return
        }
        runLock.withLock {
            withContext(Dispatchers.Main) {
                serviceFlutterEngine = FlutterEngine(GlobalState.application)
                serviceFlutterEngine?.plugins?.add(ServicePlugin())
                serviceFlutterEngine?.plugins?.add(AppPlugin())
                serviceFlutterEngine?.plugins?.add(TilePlugin())
                val dartEntrypoint = DartExecutor.DartEntrypoint(
                    FlutterInjector.instance().flutterLoader().findAppBundlePath(), "_service"
                )
                serviceFlutterEngine?.dartExecutor?.executeDartEntrypoint(dartEntrypoint)
            }

        }
    }

    private fun startService() {
        GlobalState.launch {
            runLock.withLock {
                runStateFlow.tryEmit(RunState.PENDING)
                if (servicePlugin == null) {
                    return@launch
                }
                val options = servicePlugin?.handleGetVpnOptions()
                if (options == null) {
                    return@launch
                }
                appPlugin?.prepare(options.enable) {
                    servicePlugin?.startService(options, true)
                    runStateFlow.tryEmit(RunState.START)
                    runTime = System.currentTimeMillis()
                }
            }
        }

    }

    fun handleStopService() {
        GlobalState.launch {
            runLock.withLock {
                runStateFlow.tryEmit(RunState.PENDING)
                servicePlugin?.stopService()
                runStateFlow.tryEmit(RunState.STOP)
                runTime = 0
            }
        }

    }
}


