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

    suspend fun handleSyncState() {
        runLock.withLock {
            try {
                Service.bind()
                runTime = Service.getRunTime()
                val runState = when (runTime == 0L) {
                    true -> RunState.STOP
                    false -> RunState.START
                }
                runStateFlow.tryEmit(runState)
            } catch (_: Exception) {
                runStateFlow.tryEmit(RunState.STOP)
            }
        }
    }

    suspend fun handleStartServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.STOP) {
                return
            }
            tilePlugin?.handleStart()
            if (flutterEngine != null) {
                return
            }
            startServiceWithEngine()
        }

    }

    suspend fun handleStopServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.START) {
                return
            }
            tilePlugin?.handleStop()
            if (flutterEngine != null || serviceFlutterEngine != null) {
                return
            }
            handleStopService()
        }
    }

    fun handleStartService() {
        val appPlugin = flutterEngine?.plugin<AppPlugin>()
        if (appPlugin != null) {
            appPlugin.requestNotificationsPermission {
                startService()
            }
            return
        }
        startService()
    }

    fun handleStopService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.START) {
                    return@launch
                }
                runStateFlow.tryEmit(RunState.PENDING)
                runTime = Service.stopService()
                runStateFlow.tryEmit(RunState.STOP)
            }
            destroyServiceEngine()
        }
    }

    suspend fun destroyServiceEngine() {
        runLock.withLock {
            GlobalState.log("Destroy service engine")
            withContext(Dispatchers.Main) {
                runCatching {
                    serviceFlutterEngine?.destroy()
                    serviceFlutterEngine = null
                }
            }
        }
    }

    private fun startServiceWithEngine() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                GlobalState.log("Create service engine")
                withContext(Dispatchers.Main) {
                    serviceFlutterEngine?.destroy()
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
    }

    private fun startService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                runStateFlow.tryEmit(RunState.PENDING)
                if (servicePlugin == null) {
                    return@launch
                }
                val options = servicePlugin?.handleGetVpnOptions() ?: return@launch
                appPlugin?.prepare(options.enable) {
                    runTime = Service.startService(options, runTime)
                    runStateFlow.tryEmit(RunState.START)
                }
            }
        }

    }
}



