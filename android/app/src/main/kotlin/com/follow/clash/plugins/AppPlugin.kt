package com.follow.clash.plugins

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import androidx.core.net.toUri
import com.follow.clash.R
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import com.follow.clash.common.PendingCallback
import com.follow.clash.common.QuickAction
import com.follow.clash.common.quickIntent
import com.follow.clash.getPackageIconPath
import com.follow.clash.packages.PackageResolver
import com.follow.clash.showToast
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class AppPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private var activity: Activity? = null

    private var activityBinding: ActivityPluginBinding? = null

    private val activityResultListener =
        PluginRegistry.ActivityResultListener(::onActivityResult)

    private val permissionsResultListener =
        PluginRegistry.RequestPermissionsResultListener(::onRequestPermissionsResultListener)

    private lateinit var channel: MethodChannel

    private lateinit var scope: CoroutineScope

    private val vpnPrepareCallback = PendingCallback<Boolean>()

    private val requestNotificationCallback = PendingCallback<Boolean>()

    private var isRequestingNotificationPermission = false

    private val gson = Gson()

    private val packageResolver by lazy {
        PackageResolver(
            GlobalState.application.packageManager,
            GlobalState.application.packageName,
        )
    }

    private var skipNotificationPermissionRequest = false

    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Runs [block] on the main thread.
     *
     * The permission and consent hops below touch the Activity — starting an
     * activity for result, raising a permission prompt — and read the state that
     * tracks whether one is already up. Their callers are coroutines on
     * [Dispatchers.Default], while the answers come back on the main thread
     * through the ActivityAware listeners, so main is the one thread both ends
     * can agree on. A plain main-looper post rather than the plugin scope: the
     * scope is cancelled when the engine detaches, and a request dropped there
     * would leave its caller waiting for a callback that can no longer run.
     */
    private fun onMainThread(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    override fun onMethodCall(call: MethodCall, rawResult: Result) {
        val result = MainThreadResult(rawResult)
        when (call.method) {
            "moveTaskToBack" -> {
                activity?.moveTaskToBack(true)
                result.success(true)
            }

            "updateExcludeFromRecents" -> {
                val value = call.argument<Boolean>("value")
                updateExcludeFromRecents(value)
                result.success(true)
            }

            "initShortcuts" -> {
                val label = call.arguments as? String
                if (label == null) {
                    result.error("INVALID_ARGUMENT", "Shortcut label must be a string", null)
                } else {
                    initShortcuts(label)
                    result.success(true)
                }
            }

            "getPackages" -> {
                scope.launch(Dispatchers.IO) {
                    result.success(gson.toJson(packageResolver.installedPackages))
                }
            }

            "getChinaPackageNames" -> {
                scope.launch(Dispatchers.IO) {
                    result.success(gson.toJson(packageResolver.getChinaPackageNames()))
                }
            }

            "getPackageIcon" -> {
                handleGetPackageIcon(call, result)
            }

            "tip" -> {
                val message = call.argument<String>("message")
                GlobalState.application.showToast(message)
                result.success(true)
            }

            "isBatteryOptimizationDisabled" -> {
                result.success(isBatteryOptimizationDisabled())
            }

            "openBatteryOptimizationSettings" -> {
                result.success(openBatteryOptimizationSettings())
            }

            "openAppSettings" -> {
                result.success(openAppSettings())
            }

            "didCrashOnPreviousExecution" -> {
                result.success(GlobalState.didCrashOnPreviousExecution())
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleGetPackageIcon(call: MethodCall, result: Result) {
        scope.launch {
            val packageName = call.argument<String>("packageName")
            if (packageName == null) {
                result.success("")
                return@launch
            }
            val path = GlobalState.application.packageManager.getPackageIconPath(packageName)
            result.success(path)
        }
    }

    private fun initShortcuts(label: String) {
        val shortcut = with(ShortcutInfoCompat.Builder(GlobalState.application, "toggle")) {
            setShortLabel(label)
            setIcon(
                IconCompat.createWithResource(
                    GlobalState.application,
                    R.mipmap.ic_launcher_round,
                ),
            )
            setIntent(QuickAction.TOGGLE.quickIntent)
            build()
        }
        ShortcutManagerCompat.setDynamicShortcuts(
            GlobalState.application,
            listOf(shortcut),
        )
    }

    private fun isBatteryOptimizationDisabled(): Boolean {
        val powerManager = getSystemService(GlobalState.application, PowerManager::class.java)
        return powerManager?.isIgnoringBatteryOptimizations(GlobalState.application.packageName)
            ?: false
    }

    @SuppressLint("BatteryLife")
    private fun openBatteryOptimizationSettings(): Boolean {
        // VPN continuity is the user-requested core function, so the direct exemption is intentional.
        val activity = activity ?: return false
        return try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = "package:${GlobalState.application.packageName}".toUri()
            }
            activity.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openAppSettings(): Boolean {
        val activity = activity ?: return false
        return try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = "package:${GlobalState.application.packageName}".toUri()
            }
            activity.startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun updateExcludeFromRecents(value: Boolean?) {
        val am = getSystemService(GlobalState.application, ActivityManager::class.java)
        val task = am?.appTasks?.firstOrNull {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                it.taskInfo.taskId == activity?.taskId
            } else {
                it.taskInfo.id == activity?.taskId
            }
        }
        task?.setExcludeFromRecents(value ?: false)
    }

    fun requestNotificationPermission(callback: (Boolean) -> Unit) = onMainThread {
        requestNotificationCallback.replace(callback, supersededValue = false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val permission = ContextCompat.checkSelfPermission(
                GlobalState.application,
                Manifest.permission.POST_NOTIFICATIONS,
            )
            if (permission == PackageManager.PERMISSION_GRANTED || skipNotificationPermissionRequest) {
                invokeRequestNotificationCallback(true)
                return@onMainThread
            }
            if (isRequestingNotificationPermission) {
                return@onMainThread
            }
            isRequestingNotificationPermission = true
            activity?.let {
                ActivityCompat.requestPermissions(
                    it,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE,
                )
            } ?: invokeRequestNotificationCallback(true)
            return@onMainThread
        }
        invokeRequestNotificationCallback(true)
    }

    private fun invokeRequestNotificationCallback(shouldStart: Boolean) {
        isRequestingNotificationPermission = false
        requestNotificationCallback.resolve(shouldStart)
    }

    fun prepareVpn(needPrepare: Boolean, callback: (Boolean) -> Unit) = onMainThread {
        vpnPrepareCallback.replace(callback, supersededValue = false)
        if (!needPrepare) {
            invokeVpnPrepareCallback(true)
            return@onMainThread
        }
        val intent = VpnService.prepare(GlobalState.application)
        if (intent != null) {
            val activity = activity
            if (activity == null) {
                invokeVpnPrepareCallback(false)
            } else {
                @Suppress("DEPRECATION")
                activity.startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
            }
            return@onMainThread
        }
        invokeVpnPrepareCallback(true)
    }

    // Posted rather than run where the cancellation lands, so it stays ordered
    // behind the prepareVpn that installed the callback it is cancelling.
    fun cancelVpnPreparation(callback: (Boolean) -> Unit) = onMainThread {
        vpnPrepareCallback.cancel(callback)
    }

    private fun invokeVpnPrepareCallback(granted: Boolean) {
        vpnPrepareCallback.resolve(granted)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "${Components.PACKAGE_NAME}/app")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
        invokeVpnPrepareCallback(false)
        invokeRequestNotificationCallback(false)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachToActivity(binding)
    }

    private fun attachToActivity(binding: ActivityPluginBinding) {
        detachFromActivity()
        activityBinding = binding
        activity = binding.activity
        binding.addActivityResultListener(activityResultListener)
        binding.addRequestPermissionsResultListener(permissionsResultListener)
    }

    private fun detachFromActivity() {
        activity = null
        val binding = activityBinding ?: return
        activityBinding = null
        binding.removeActivityResultListener(activityResultListener)
        binding.removeRequestPermissionsResultListener(permissionsResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        channel.invokeMethod("exit", null)
        detachFromActivity()
        invokeVpnPrepareCallback(false)
        invokeRequestNotificationCallback(false)
    }

    private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != VPN_PERMISSION_REQUEST_CODE) {
            return false
        }
        invokeVpnPrepareCallback(resultCode == Activity.RESULT_OK)
        return true
    }

    private fun onRequestPermissionsResultListener(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != NOTIFICATION_PERMISSION_REQUEST_CODE) {
            return false
        }
        skipNotificationPermissionRequest = true
        invokeRequestNotificationCallback(true)
        return true
    }

    private companion object {
        const val VPN_PERMISSION_REQUEST_CODE = 1001
        const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002
    }
}
