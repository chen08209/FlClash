package com.follow.clash.plugins

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.net.toUri
import com.follow.clash.common.Components
import com.follow.clash.common.PendingCallback
import com.follow.clash.common.registerReceiverCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class BatteryPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var context: Context

    private lateinit var methodChannel: MethodChannel

    private lateinit var eventChannel: EventChannel

    private var activityBinding: ActivityPluginBinding? = null

    private val pendingRequest = PendingCallback<Unit>()

    private var events: EventChannel.EventSink? = null

    private var lastPublished: Boolean? = null

    private val activityResultListener =
        PluginRegistry.ActivityResultListener { requestCode, _, _ ->
            if (requestCode != REQUEST_CODE) {
                return@ActivityResultListener false
            }
            resolve()
            true
        }

    private val allowlistReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            publish()
        }
    }

    private val saverObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
        override fun onChange(selfChange: Boolean) {
            publish()
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "${Components.PACKAGE_NAME}/battery")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(
            binding.binaryMessenger,
            "${Components.PACKAGE_NAME}/battery/optimization",
        )
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        onCancel(null)
        resolve()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestIgnoreOptimizations" -> requestIgnoreOptimizations { result.success(null) }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        val ignoring = isIgnoringOptimizations()
        sink.success(ignoring)
        context.registerReceiverCompat(
            allowlistReceiver,
            IntentFilter(ACTION_POWER_SAVE_WHITELIST_CHANGED),
        )
        context.contentResolver.registerContentObserver(
            Settings.System.getUriFor(MILLET_NO_RESTRICT_APP),
            false,
            saverObserver,
        )
        events = sink
        lastPublished = ignoring
    }

    override fun onCancel(arguments: Any?) {
        events ?: return
        events = null
        context.unregisterReceiver(allowlistReceiver)
        context.contentResolver.unregisterContentObserver(saverObserver)
    }

    private fun publish() {
        val sink = events ?: return
        val ignoring = isIgnoringOptimizations()
        if (ignoring == lastPublished) {
            return
        }
        lastPublished = ignoring
        sink.success(ignoring)
    }

    private fun resolve() {
        publish()
        pendingRequest.resolve(Unit)
    }

    private fun requestIgnoreOptimizations(callback: (Unit) -> Unit) {
        val activity = activityBinding?.activity
        if (activity == null || isIgnoringOptimizations()) {
            callback(Unit)
            return
        }
        pendingRequest.replace(callback, supersededValue = Unit)
        val pages = if (isXiaomi) saverPages() else optimizationPages()
        if (pages.none { launch(activity, it) }) {
            resolve()
        }
    }

    @SuppressLint("BatteryLife")
    private fun optimizationPages(): List<Intent> {
        // VPN continuity is the user-requested core function, so the direct exemption is intentional.
        val prompt = Intent(
            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
            "package:${context.packageName}".toUri(),
        )
        // Some ROMs drop the direct prompt; the allowlist page still lets the user exempt the app.
        val allowlist = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        return listOf(prompt, allowlist)
    }

    private fun saverPages(): List<Intent> {
        val policy = Intent()
            .setComponent(ComponentName(POWERKEEPER_PACKAGE, POWERKEEPER_POLICY_ACTIVITY))
            .putExtra("package_name", context.packageName)
            .putExtra(
                "package_label",
                context.applicationInfo.loadLabel(context.packageManager).toString(),
            )
        val details = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            "package:${context.packageName}".toUri(),
        )
        return listOf(policy, details)
    }

    private fun launch(activity: Activity, page: Intent): Boolean = try {
        @Suppress("DEPRECATION")
        activity.startActivityForResult(page, REQUEST_CODE)
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }

    // On Xiaomi the battery saver is what counts: "No restrictions" also allowlists the
    // app, the allowlist alone does not stop PowerKeeper freezing it, and PowerKeeper
    // drops a running VPN from the allowlist while the list follows the user's policy.
    private fun isIgnoringOptimizations(): Boolean {
        if (isXiaomi) {
            return context.packageName in noRestrictionApps()
        }
        return context.getSystemService(PowerManager::class.java)
            ?.isIgnoringBatteryOptimizations(context.packageName) ?: false
    }

    // PowerKeeper's comma-separated "No restrictions" packages, kept for user 0 only.
    private fun noRestrictionApps(): List<String> {
        val packages = try {
            Settings.System.getString(context.contentResolver, MILLET_NO_RESTRICT_APP)
        } catch (_: SecurityException) {
            null
        }
        return packages?.split(',')?.map { it.trim() }.orEmpty()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(activityResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachFromActivity()
        resolve()
    }

    private fun detachFromActivity() {
        activityBinding?.removeActivityResultListener(activityResultListener)
        activityBinding = null
    }

    private companion object {
        val isXiaomi = Build.MANUFACTURER.equals("xiaomi", ignoreCase = true)

        // Every plugin on the activity sees every result; AppPlugin holds 1001-1004.
        const val REQUEST_CODE = 1005

        // PowerManager keeps this action @hide, yet the system broadcasts it to
        // registered receivers of the system user whenever the allowlist changes.
        const val ACTION_POWER_SAVE_WHITELIST_CHANGED =
            "android.os.action.POWER_SAVE_WHITELIST_CHANGED"

        const val MILLET_NO_RESTRICT_APP = "MILLET_NO_RESTRICT_APP"

        const val POWERKEEPER_PACKAGE = "com.miui.powerkeeper"

        const val POWERKEEPER_POLICY_ACTIVITY = "com.miui.powerkeeper.ui.HiddenAppsConfigActivity"
    }
}
