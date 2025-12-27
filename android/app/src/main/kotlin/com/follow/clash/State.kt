package com.follow.clash

import com.follow.clash.common.GlobalState
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.UUID

enum class RunState {
    START, PENDING, STOP
}


object State {

    val runLock = Mutex()

    var runTime: Long = 0

    var sharedState: SharedState = SharedState()

    val runStateFlow: MutableStateFlow<RunState> = MutableStateFlow(RunState.STOP)

    var flutterEngine: FlutterEngine? = null

    val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>()

    val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>()

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
            startServiceWithFile()
        }

    }

    suspend fun handleStopServiceAction() {
        runLock.withLock {
            if (runStateFlow.value != RunState.START) {
                return
            }
            tilePlugin?.handleStop()
            if (flutterEngine != null) {
                return
            }
            GlobalState.application.showToast(sharedState.stopTip)
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

    private fun startServiceWithFile() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                val sharedFile = GlobalState.application.sharedFile
                try {
                    val data = sharedFile.readText()
                    sharedState = Gson().fromJson(data, SharedState::class.java)
                    GlobalState.application.showToast(sharedState.startTip)
                    setupConfig()
                    startService()
                } catch (_: Exception) {
                    GlobalState.application.showToast("Initialization failed")
                }
            }
        }
    }

    private fun setupConfig() {
        Service.bind()
        GlobalState.launch {
            val action = mutableMapOf<String, String>()
            action["method"] = "setupConfig"
            action["id"] = UUID.randomUUID().toString()
            action["data"] = Gson().toJson(sharedState.setupParams)
            val data = Gson().toJson(action)
            Service.invokeAction(data) {

            }
        }
    }

    private fun startService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.STOP) {
                    return@launch
                }
                try {
                    runStateFlow.tryEmit(RunState.PENDING)
                    sharedState.vpnOptions?.let { options ->
                        appPlugin?.prepare(options.enable) {
                            runTime = Service.startService(options, runTime)
                            runStateFlow.tryEmit(RunState.START)
                        }
                        return@launch
                    }
                    runStateFlow.tryEmit(RunState.STOP)
                } catch (_: Exception) {
                    runStateFlow.tryEmit(RunState.STOP)
                }
            }
        }

    }

    fun handleStopService() {
        GlobalState.launch {
            runLock.withLock {
                if (runStateFlow.value != RunState.START) {
                    return@launch
                }
                try {
                    runStateFlow.tryEmit(RunState.PENDING)
                    runTime = Service.stopService()
                    runStateFlow.tryEmit(RunState.STOP)
                } catch (_: Exception) {
                    runStateFlow.tryEmit(RunState.START)
                }
            }
        }
    }
}



