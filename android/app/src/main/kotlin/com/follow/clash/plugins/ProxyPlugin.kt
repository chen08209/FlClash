package com.follow.clash.plugins

import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.os.IBinder
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.follow.clash.GlobalState
import com.follow.clash.RunState
import com.follow.clash.models.Props
import com.follow.clash.services.FlClashVpnService
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class ProxyPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var flutterMethodChannel: MethodChannel

    val VPN_PERMISSION_REQUEST_CODE = 1001
    val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002

    private var activity: Activity? = null
    private var context: Context? = null
    private var flClashVpnService: FlClashVpnService? = null
    private var port: Int = 7890
    private var props: Props? = null
    private var isBlockNotification: Boolean = false
    private var isStart: Boolean = false

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as FlClashVpnService.LocalBinder
            flClashVpnService = binder.getService()
            if (isStart) {
                startVpn()
            }
        }

        override fun onServiceDisconnected(arg: ComponentName) {
            flClashVpnService = null
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        flutterMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "proxy")
        flutterMethodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterMethodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) = when (call.method) {
        "initService" -> {
            isStart = false
            initService()
            requestNotificationsPermission()
            result.success(true)
        }

        "startProxy" -> {
            isStart = true
            port = call.argument<Int>("port")!!
            val args = call.argument<String>("args")
            props =
                if (args != null) Gson().fromJson(args, Props::class.java) else null
            startVpn()
            result.success(true)
        }

        "stopProxy" -> {
            stopVpn()
            result.success(true)
        }

        "setProtect" -> {
            val fd = call.argument<Int>("fd")
            if (fd != null) {
                flClashVpnService?.protect(fd)
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

    private fun initService() {
        val intent = VpnService.prepare(context)
        if (intent != null) {
            activity?.startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
        } else {
            if (flClashVpnService != null) {
                flClashVpnService!!.initServiceEngine()
            } else {
                bindService()
            }
        }
    }

    private fun startVpn() {
        if (flClashVpnService == null) {
            bindService()
            return
        }
        if (GlobalState.runState.value == RunState.START) return
        GlobalState.runState.value = RunState.START
        flutterMethodChannel.invokeMethod("started", flClashVpnService?.start(port, props))
    }

    private fun stopVpn() {
        if (GlobalState.runState.value == RunState.STOP) return
        GlobalState.runState.value = RunState.STOP
        flClashVpnService?.stop()
        GlobalState.destroyServiceEngine()
    }

    private fun startForeground(title: String, content: String) {
        if (GlobalState.runState.value != RunState.START) return
        flClashVpnService?.startForeground(title, content)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(::onActivityResult)
        binding.addRequestPermissionsResultListener(::onRequestPermissionsResultListener)
    }

    private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == VPN_PERMISSION_REQUEST_CODE) {
            if (resultCode == FlutterActivity.RESULT_OK) {
                bindService()
            } else {
                stopVpn()
            }
        }
        return true
    }

    private fun onRequestPermissionsResultListener(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            isBlockNotification = true
        }
        return false
    }

    private fun requestNotificationsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val permission = context?.let {
                ContextCompat.checkSelfPermission(
                    it,
                    Manifest.permission.POST_NOTIFICATIONS
                )
            }
            if (permission != PackageManager.PERMISSION_GRANTED) {
                if (isBlockNotification) return
                if (activity == null) return
                ActivityCompat.requestPermissions(
                    activity!!,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
                )
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun bindService() {
        val intent = Intent(context, FlClashVpnService::class.java)
        context?.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }
}