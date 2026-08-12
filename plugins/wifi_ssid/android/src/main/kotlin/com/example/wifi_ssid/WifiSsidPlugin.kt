package com.example.wifi_ssid

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class WifiSsidPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var wifiManager: WifiManager? = null
    private var connectivityManager: ConnectivityManager? = null
    private var pendingPermissionResult: Result? = null

    companion object {
        private const val REQUEST_CODE_LOCATION = 1001
        // Values must match WifiSsidPermission enum index in Dart
        private const val PERMISSION_GRANTED = 0
        private const val PERMISSION_DENIED = 1
        private const val PERMISSION_PERMANENTLY_DENIED = 2
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_ssid")
        channel.setMethodCallHandler(this)
        wifiManager = context?.applicationContext?.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        connectivityManager = context?.applicationContext?.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        wifiManager = null
        connectivityManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener { requestCode, _, grantResults ->
            if (requestCode == REQUEST_CODE_LOCATION) {
                val result = pendingPermissionResult ?: return@addRequestPermissionsResultListener false
                pendingPermissionResult = null
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    result.success(PERMISSION_GRANTED)
                } else {
                    if (!ActivityCompat.shouldShowRequestPermissionRationale(binding.activity, Manifest.permission.ACCESS_FINE_LOCATION)) {
                        result.success(PERMISSION_PERMANENTLY_DENIED)
                    } else {
                        result.success(PERMISSION_DENIED)
                    }
                }
                true
            } else {
                false
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getSsid" -> getSsid(result)
            "checkPermission" -> checkPermission(result)
            "requestPermission" -> requestPermission(result)
            else -> result.notImplemented()
        }
    }

    // MARK: - Permission

    private fun checkPermission(result: Result) {
        val ctx = context ?: run {
            result.error("UNAVAILABLE", "Context not available", null)
            return
        }
        val granted = ContextCompat.checkSelfPermission(ctx, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        result.success(if (granted) PERMISSION_GRANTED else PERMISSION_DENIED)
    }

    private fun requestPermission(result: Result) {
        val act = activity ?: run {
            result.error("UNAVAILABLE", "Activity not available", null)
            return
        }
        val ctx = context ?: run {
            result.error("UNAVAILABLE", "Context not available", null)
            return
        }
        if (ContextCompat.checkSelfPermission(ctx, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            result.success(PERMISSION_GRANTED)
            return
        }
        // Replacing a pending result would leave the first caller's future
        // uncompleted forever.
        pendingPermissionResult?.success(PERMISSION_DENIED)
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(act, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_CODE_LOCATION)
    }

    // MARK: - SSID

    private fun getSsid(result: Result) {
        val wm = wifiManager ?: run {
            result.error("UNAVAILABLE", "WifiManager not available", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cm = connectivityManager ?: run {
                result.error("UNAVAILABLE", "ConnectivityManager not available", null)
                return
            }
            val currentNetwork = cm.activeNetwork
            if (currentNetwork == null) {
                result.success(null)
                return
            }
            val caps = cm.getNetworkCapabilities(currentNetwork)
            if (caps == null || !caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                result.success(null)
                return
            }
        }

        @Suppress("DEPRECATION")
        val info = wm.connectionInfo
        result.success(normalizeSsid(info.ssid))
    }

    private fun normalizeSsid(ssid: String?): String? {
        return if (ssid == null || ssid == "<unknown ssid>" || ssid == "0x") {
            null
        } else {
            ssid.removeSurrounding("\"")
        }
    }
}
