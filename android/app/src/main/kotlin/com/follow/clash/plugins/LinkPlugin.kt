package com.follow.clash.plugins

import android.content.Intent
import android.os.Bundle
import com.follow.clash.common.Components
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class LinkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.NewIntentListener, ActivityPluginBinding.OnSaveInstanceStateListener {
    private lateinit var channel: MethodChannel

    private val pending = mutableListOf<String>()

    private var taken = false

    private var activityBinding: ActivityPluginBinding? = null

    private var launchIntent: Intent? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "${Components.PACKAGE_NAME}/link")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "takeLinks" -> {
                taken = true
                result.success(pending.toList())
                pending.clear()
            }

            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attach(binding)
        launchIntent = binding.activity.intent
    }

    override fun onSaveInstanceState(bundle: Bundle) {}

    // Only an activity Android rebuilds after its process died gets saved state,
    // and it comes back with the intent that first opened it.
    override fun onRestoreInstanceState(bundle: Bundle?) {
        val intent = launchIntent ?: return
        launchIntent = null
        if (bundle == null) {
            receive(intent)
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attach(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() = detach()

    override fun onDetachedFromActivity() = detach()

    override fun onNewIntent(intent: Intent): Boolean = receive(intent)

    private fun attach(binding: ActivityPluginBinding) {
        detach()
        activityBinding = binding
        binding.addOnNewIntentListener(this)
        binding.addOnSaveStateListener(this)
    }

    private fun detach() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding?.removeOnSaveStateListener(this)
        activityBinding = null
    }

    // Recents relaunches an activity with the intent that first opened it.
    private fun receive(intent: Intent?): Boolean {
        if (intent?.action != Intent.ACTION_VIEW ||
            intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0
        ) {
            return false
        }
        val link = intent.dataString ?: return false
        deliver(link)
        return true
    }

    private fun deliver(link: String) {
        if (!taken) {
            pending.add(link)
            return
        }
        channel.invokeMethod("link", link, object : MethodChannel.Result {
            override fun success(result: Any?) {}

            override fun error(code: String, message: String?, details: Any?) {
                pending.add(link)
            }

            override fun notImplemented() {
                pending.add(link)
            }
        })
    }
}
