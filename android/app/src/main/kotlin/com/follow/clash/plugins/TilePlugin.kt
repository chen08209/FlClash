
package com.follow.clash.plugins

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TilePlugin(private val onStart: (() -> Unit)? = null, private val onStop: (() -> Unit)? = null) : FlutterPlugin,
    MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tile")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        handleDetached()
        channel.setMethodCallHandler(null)
    }

    fun handleStart() {
        onStart?.let { it() }
        channel.invokeMethod("start", null)
    }

    fun handleStop() {
        channel.invokeMethod("stop", null)
        onStop?.let { it() }
    }

    private fun handleDetached() {
        channel.invokeMethod("detached", null)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {}
}