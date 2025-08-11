package com.follow.clash.plugins

import com.follow.clash.AppState
import com.follow.clash.Service
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private val service = Service(GlobalState.application)
    private lateinit var flutterMethodChannel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/service"
        )
        flutterMethodChannel.setMethodCallHandler(this)
        service.bind()
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
        service.unbind()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        "invokeAction" -> {
            handleInvokeAction(call, result)
        }

        "getRunTime" -> {
            handleGetRunTime(result)
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
        val data = call.arguments<String>()!!
        service.invokeAction(data) {
            result.success(it)
        }
    }

    private fun handleStart(result: MethodChannel.Result) {
        AppState.handleStartService()
        result.success(true)
    }

    private fun handleStop(result: MethodChannel.Result) {
        AppState.handleStopService()
        result.success(true)
    }

    private fun handleGetRunTime(result: MethodChannel.Result){
        return result.success(AppState.runTime)
    }
}