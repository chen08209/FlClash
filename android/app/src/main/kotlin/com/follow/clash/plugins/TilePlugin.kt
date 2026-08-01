package com.follow.clash.plugins

import com.follow.clash.common.Components
import com.follow.clash.awaitResult
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

    suspend fun handleStart(): Boolean =
        channel.awaitResult<Boolean>("start") == true

    suspend fun handleStop(): Boolean =
        channel.awaitResult<Boolean>("stop") == true

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.notImplemented()
    }
}
