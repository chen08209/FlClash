package com.follow.clash.plugins

import android.content.Context
import android.net.ConnectivityManager
import androidx.core.content.getSystemService
import com.follow.clash.GlobalState
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var flutterMethodChannel: MethodChannel

    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        flutterMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "service")
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        "init" -> {
            GlobalState.getCurrentAppPlugin()?.requestNotificationsPermission(context)
            GlobalState.initServiceEngine(context)
            result.success(true)
        }

        "destroy" -> {
            handleDestroy()
            result.success(true)
        }

        else -> {
            result.notImplemented()
        }
    }

    private fun handleDestroy() {
        GlobalState.getCurrentVPNPlugin()?.stop()
        GlobalState.destroyServiceEngine()
    }
}