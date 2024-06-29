package com.follow.clash.plugins

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
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
import java.util.Date


class ProxyPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {


    val VPN_PERMISSION_REQUEST_CODE = 1001
    val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002

    private lateinit var flutterMethodChannel: MethodChannel

    private var activity: Activity? = null
    private var context: Context? = null
    private var flClashVpnService: FlClashVpnService? = null
    private var isBound = false
    private var port: Int? = null
    private var props: Props? = null
    private lateinit var title: String
    private lateinit var content: String
    var isBlockNotification: Boolean = false

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as FlClashVpnService.LocalBinder
            flClashVpnService = binder.getService()
            port?.let { startVpn(it) }
            isBound = true
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
            flClashVpnService = null
            isBound = false
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
        "StartProxy" -> {
            port = call.argument<Int>("port")
            val args = call.argument<String>("args")
            props =
                if (args != null) Gson().fromJson(args, Props::class.java) else null
            handleStartVpn()
            result.success(true)
        }

        "StopProxy" -> {
            stopVpn()
            result.success(true)
        }

        "SetProtect" -> {
            val fd = call.argument<Int>("fd")
            if (fd != null) {
                flClashVpnService?.protect(fd)
                result.success(true)
            } else {
                result.success(false)
            }
        }

        "GetRunTimeStamp" -> {
            result.success(GlobalState.runTime?.time)
        }

        "startForeground" -> {
            title = call.argument<String>("title") as String
            content = call.argument<String>("content") as String
            requestNotificationsPermission()
            result.success(true)
        }

        else -> {
            result.notImplemented()
        }
    }

    private fun handleStartVpn() {
        val intent = VpnService.prepare(context)
        if (intent != null) {
            activity?.startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
        } else {
            bindService()
        }
    }

    private fun startVpn(port: Int) {
        if (GlobalState.runState.value == RunState.START) return;
        flClashVpnService?.start(port, props)
        GlobalState.runState.value = RunState.START
        GlobalState.runTime = Date()
        startAfter()
    }

    private fun stopVpn() {
        if (GlobalState.runState.value == RunState.STOP) return
        flClashVpnService?.stop()
        unbindService()
        GlobalState.runState.value = RunState.STOP;
        GlobalState.runTime = null;
    }

    private fun startForeground() {
        if (GlobalState.runState.value != RunState.START) return
        flClashVpnService?.startForeground(title, content)
    }

    private fun requestNotificationsPermission() {
        if (VERSION.SDK_INT >= VERSION_CODES.TIRAMISU) {
            val permission = context?.let {
                ContextCompat.checkSelfPermission(
                    it,
                    Manifest.permission.POST_NOTIFICATIONS
                )
            }
            if (permission == PackageManager.PERMISSION_GRANTED) {
                startForeground()
            } else {
                if (isBlockNotification) return
                if (activity == null) return
                ActivityCompat.requestPermissions(
                    activity!!,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
                )

            }
        } else {
            startForeground()
        }
    }

    private fun startAfter() {
        flutterMethodChannel.invokeMethod("startAfter", flClashVpnService?.fd)
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
        return true;
    }

    private fun onRequestPermissionsResultListener(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            isBlockNotification = true
            if (grantResults.isNotEmpty()) {
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    startForeground()
                }
            }
        }
        return false;
    }


    override fun onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        stopVpn()
        activity = null
    }

    private fun bindService() {
        val intent = Intent(context, FlClashVpnService::class.java)
        context?.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }

    private fun unbindService() {
        if (isBound) {
            context?.unbindService(connection)
            isBound = false
        }
    }
}