package com.follow.clash.plugins

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import com.follow.clash.BaseServiceInterface
import com.follow.clash.GlobalState
import com.follow.clash.RunState
import com.follow.clash.models.Props
import com.follow.clash.services.FlClashService
import com.follow.clash.services.FlClashVpnService
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.withLock


class VpnPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var flutterMethodChannel: MethodChannel
    private lateinit var context: Context
    private var flClashService: BaseServiceInterface? = null
    private var port: Int = 7890
    private var props: Props? = null

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            flClashService = when (service) {
                is FlClashVpnService.LocalBinder -> service.getService()
                is FlClashService.LocalBinder -> service.getService()
                else -> throw Exception("invalid binder")
            }
            start()
        }

        override fun onServiceDisconnected(arg: ComponentName) {
            flClashService = null
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        flutterMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpn")
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {

        "start" -> {
            port = call.argument<Int>("port")!!
            val args = call.argument<String>("args")
            props =
                if (args != null) Gson().fromJson(args, Props::class.java) else null
            when (props?.enable == true) {
                true -> handleStartVpn()
                false -> start()
            }
            result.success(true)
        }

        "stop" -> {
            stop()
            result.success(true)
        }

        "setProtect" -> {
            val fd = call.argument<Int>("fd")
            if (fd != null) {
                if (flClashService is FlClashVpnService) {
                    (flClashService as FlClashVpnService).protect(fd)
                }
                result.success(true)
            } else {
                result.success(false)
            }
        }

        "startForeground" -> {
            val title = call.argument<String>("title") as String
            val content = call.argument<String>("content") as String
            startForeground(title, content)
            result.success(true)
        }

        else -> {
            result.notImplemented()
        }
    }

    @SuppressLint("ForegroundServiceType")
    fun handleStartVpn() {
        GlobalState.getCurrentAppPlugin()?.requestVpnPermission(context) {
            start()
        }
    }

    @SuppressLint("ForegroundServiceType")
    private fun startForeground(title: String, content: String) {
        GlobalState.runLock.withLock {
            if (GlobalState.runState.value != RunState.START) return
            flClashService?.startForeground(title, content)
        }
    }

    private fun start() {
        if (flClashService == null) {
            bindService()
            return
        }
        GlobalState.runLock.withLock {
            if (GlobalState.runState.value == RunState.START) return
            GlobalState.runState.value = RunState.START
            val fd = flClashService?.start(port, props)
            flutterMethodChannel.invokeMethod("started", fd)
        }
    }

    fun stop() {
        GlobalState.runLock.withLock {
            if (GlobalState.runState.value == RunState.STOP) return
            GlobalState.runState.value = RunState.STOP
            flClashService?.stop()
        }
        GlobalState.destroyServiceEngine()
    }

    private fun bindService() {
        val intent = when (props?.enable == true) {
            true -> Intent(context, FlClashVpnService::class.java)
            false -> Intent(context, FlClashService::class.java)
        }
        context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }

}