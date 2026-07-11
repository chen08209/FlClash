package com.follow.clash.wifi_ssid

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.util.concurrent.ConcurrentHashMap

class WifiSsidPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var wifiManager: WifiManager? = null
    private var connectivityManager: ConnectivityManager? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingPermissionResult: Result? = null
    private var wifiNetworkCallback: ConnectivityManager.NetworkCallback? = null
    private val wifiInfoByNetwork = ConcurrentHashMap<Network, WifiInfo>()

    private val permissionResultListener = RequestPermissionsResultListener { requestCode, _, _ ->
        if (requestCode != REQUEST_CODE_LOCATION) {
            return@RequestPermissionsResultListener false
        }
        val result = pendingPermissionResult
            ?: return@RequestPermissionsResultListener false
        pendingPermissionResult = null
        val currentActivity = activity
        if (currentActivity == null) {
            result.error(ERROR_UNAVAILABLE, "Activity not available", null)
            return@RequestPermissionsResultListener true
        }
        val state = permissionState(currentActivity, afterRequest = true)
        if (state == PERMISSION_GRANTED) {
            refreshWifiNetworkCallback()
        } else {
            unregisterWifiNetworkCallback()
        }
        result.success(state)
        true
    }

    companion object {
        private const val CHANNEL_NAME = "wifi_ssid"
        private const val METHOD_GET_SSID = "getSsid"
        private const val METHOD_CHECK_PERMISSION = "checkPermission"
        private const val METHOD_REQUEST_PERMISSION = "requestPermission"
        private const val ERROR_UNAVAILABLE = "UNAVAILABLE"
        private const val ERROR_IN_PROGRESS = "IN_PROGRESS"
        private const val REQUEST_CODE_LOCATION = 1001

        // Values must match WifiSsidPermission enum index in Dart
        private const val PERMISSION_GRANTED = 0
        private const val PERMISSION_DENIED = 1
        private const val PERMISSION_PERMANENTLY_DENIED = 2
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        wifiManager = binding.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        connectivityManager = binding.applicationContext.getSystemService(
            Context.CONNECTIVITY_SERVICE,
        ) as? ConnectivityManager
        if (permissionState(binding.applicationContext) == PERMISSION_GRANTED) {
            registerWifiNetworkCallback()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        unregisterWifiNetworkCallback()
        detachFromActivity(cancelPermissionRequest = true)
        context = null
        wifiManager = null
        connectivityManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding?.removeRequestPermissionsResultListener(permissionResultListener)
        activityBinding = binding
        activity = binding.activity
        binding.addRequestPermissionsResultListener(permissionResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity(cancelPermissionRequest = false)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachFromActivity(cancelPermissionRequest = true)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_GET_SSID -> getSsid(result)
            METHOD_CHECK_PERMISSION -> checkPermission(result)
            METHOD_REQUEST_PERMISSION -> requestPermission(result)
            else -> result.notImplemented()
        }
    }

    private fun checkPermission(result: Result) {
        val ctx = context ?: run {
            result.error(ERROR_UNAVAILABLE, "Context not available", null)
            return
        }
        val state = permissionState(ctx)
        if (state == PERMISSION_GRANTED) {
            refreshWifiNetworkCallback()
        } else {
            unregisterWifiNetworkCallback()
        }
        result.success(state)
    }

    private fun requestPermission(result: Result) {
        val act = activity ?: run {
            result.error(ERROR_UNAVAILABLE, "Activity not available", null)
            return
        }
        val ctx = context ?: run {
            result.error(ERROR_UNAVAILABLE, "Context not available", null)
            return
        }
        if (permissionState(ctx) == PERMISSION_GRANTED) {
            refreshWifiNetworkCallback()
            result.success(PERMISSION_GRANTED)
            return
        }
        if (pendingPermissionResult != null) {
            result.error(ERROR_IN_PROGRESS, "A permission request is already active", null)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            act,
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
            ),
            REQUEST_CODE_LOCATION,
        )
    }

    private fun permissionState(context: Context, afterRequest: Boolean = false): Int {
        if (
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION,
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return PERMISSION_GRANTED
        }
        if (!afterRequest) return PERMISSION_DENIED
        val activity = activity ?: return PERMISSION_DENIED
        return if (
            ActivityCompat.shouldShowRequestPermissionRationale(
                activity,
                Manifest.permission.ACCESS_FINE_LOCATION,
            )
        ) {
            PERMISSION_DENIED
        } else {
            PERMISSION_PERMANENTLY_DENIED
        }
    }

    private fun getSsid(result: Result) {
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cm = connectivityManager ?: run {
                result.error(ERROR_UNAVAILABLE, "ConnectivityManager not available", null)
                return
            }
            registerWifiNetworkCallback()
            val activeNetwork = cm.activeNetwork
            val activeInfo = activeNetwork?.let(wifiInfoByNetwork::get)
                ?: activeNetwork
                    ?.let(cm::getNetworkCapabilities)
                    ?.takeIf { capabilities ->
                        capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                    }?.transportInfo as? WifiInfo
            activeInfo ?: wifiInfoByNetwork.values.firstOrNull()
        } else {
            val wm = wifiManager ?: run {
                result.error(ERROR_UNAVAILABLE, "WifiManager not available", null)
                return
            }
            @Suppress("DEPRECATION")
            wm.connectionInfo
        }
        result.success(normalizeSsid(info?.ssid))
    }

    private fun normalizeSsid(ssid: String?): String? {
        val normalized = ssid?.removeSurrounding("\"")
        return normalized?.takeIf {
            it.isNotEmpty() && it != WifiManager.UNKNOWN_SSID && it != "0x"
        }
    }

    private fun refreshWifiNetworkCallback() {
        unregisterWifiNetworkCallback()
        registerWifiNetworkCallback()
    }

    private fun registerWifiNetworkCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return
        }
        val ctx = context ?: return
        if (permissionState(ctx) != PERMISSION_GRANTED) {
            unregisterWifiNetworkCallback()
            return
        }
        if (wifiNetworkCallback != null) {
            return
        }
        val cm = connectivityManager ?: return
        val callback = object : ConnectivityManager.NetworkCallback(FLAG_INCLUDE_LOCATION_INFO) {
            override fun onCapabilitiesChanged(
                network: Network,
                capabilities: NetworkCapabilities,
            ) {
                val wifiInfo = capabilities.transportInfo as? WifiInfo
                if (wifiInfo == null) {
                    wifiInfoByNetwork.remove(network)
                } else {
                    wifiInfoByNetwork[network] = wifiInfo
                }
            }

            override fun onLost(network: Network) {
                wifiInfoByNetwork.remove(network)
            }
        }
        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .build()
        runCatching { cm.registerNetworkCallback(request, callback) }
            .onSuccess { wifiNetworkCallback = callback }
    }

    private fun unregisterWifiNetworkCallback() {
        val callback = wifiNetworkCallback
        wifiNetworkCallback = null
        if (callback != null) {
            connectivityManager?.let { manager ->
                runCatching { manager.unregisterNetworkCallback(callback) }
            }
        }
        wifiInfoByNetwork.clear()
    }

    private fun detachFromActivity(cancelPermissionRequest: Boolean) {
        activityBinding?.removeRequestPermissionsResultListener(permissionResultListener)
        activityBinding = null
        activity = null
        if (cancelPermissionRequest) {
            completePendingPermissionRequest(
                "Activity detached before permission request completed",
            )
        }
    }

    private fun completePendingPermissionRequest(message: String) {
        pendingPermissionResult?.error(ERROR_UNAVAILABLE, message, null)
        pendingPermissionResult = null
    }
}
