package com.follow.clash.plugins

import com.follow.clash.Service
import com.follow.clash.State
import com.follow.clash.awaitResult
import com.follow.clash.common.Components
import com.follow.clash.invokeMethodOnMainThread
import com.follow.clash.models.AppState
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    private lateinit var flutterMethodChannel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/service"
        )
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        "init" -> {
            handleInit(result)
        }

        "invokeAction" -> {
            handleInvokeAction(call, result)
        }

        "getRunTime" -> {
            handleGetRunTime(result)
        }

        "syncState" -> {
            handleSyncState(call, result)
        }

        "start" -> {
            handleStart(result)
        }

        "stop" -> {
            handleStop(result)
        }

        else -> {
            result.notImplemented()
        }
    }

    private fun handleInvokeAction(call: MethodCall, result: MethodChannel.Result) {
        launch {
            val data = call.arguments<String>()!!
            Service.invokeAction(data) {
                result.success(it)
            }
        }
    }

    private fun handleStart(result: MethodChannel.Result) {
        State.handleStartService()
        result.success(true)
    }

    private fun handleStop(result: MethodChannel.Result) {
        State.handleStopService()
        result.success(true)
    }

    suspend fun handleGetVpnOptions(): VpnOptions? {
        val res = flutterMethodChannel.awaitResult<String>("getVpnOptions", null)
        return Gson().fromJson(res, VpnOptions::class.java)
    }

    suspend fun startService(options: VpnOptions, inApp: Boolean) {
        Service.startService(options, inApp)
    }

    suspend fun stopService() {
        Service.stopService()
    }

    val semaphore = Semaphore(10)

    fun handleSendEvent(value: String?) {
        launch(Dispatchers.Main) {
            semaphore.withPermit {
                flutterMethodChannel.invokeMethod("event", value)
            }
        }
    }

    private fun onServiceCrash() {
        flutterMethodChannel.invokeMethodOnMainThread<Any>("crash", null)
    }

    private fun handleSyncState(call: MethodCall, result: MethodChannel.Result) {
        launch {
            val data = call.arguments<String>()!!
            val params = Gson().fromJson(data, AppState::class.java)
            Service.updateNotificationParams(
                NotificationParams(
                    title = params.currentProfileName,
                    stopText = params.stopText,
                    onlyStatisticsProxy = params.onlyStatisticsProxy
                )
            )
            result.success(true)
        }

    }

    fun handleInit(result: MethodChannel.Result) {
        launch {
            Service.bind()
            Service.setMessageCallback {
                handleSendEvent(it)
            }
            result.success(true)
        }
        Service.onServiceCrash = ::onServiceCrash
    }

    private fun handleGetRunTime(result: MethodChannel.Result) {
        return result.success(State.runTime)
    }
}