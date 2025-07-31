package com.follow.clash.plugins

import com.follow.clash.common.Components
import com.follow.clash.invokeMethodOnMainThread
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TilePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/tile")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    fun handleStart() {
        channel.invokeMethodOnMainThread<Any>("start", null)
    }

    fun handleStop() {
        channel.invokeMethodOnMainThread<Any>("stop", null)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {}
}