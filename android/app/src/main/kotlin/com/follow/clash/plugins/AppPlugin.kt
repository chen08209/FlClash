package com.follow.clash.plugins

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Uri
import android.os.Build
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.content.getSystemService
import androidx.core.graphics.drawable.toBitmap
import com.follow.clash.extensions.getBase64
import com.follow.clash.extensions.getInetSocketAddress
import com.follow.clash.extensions.getProtocol
import com.follow.clash.models.Process
import com.follow.clash.models.Package
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.InetSocketAddress

class AppPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private var activity: Activity? = null

    private var toast: Toast? = null

    private var context: Context? = null

    private lateinit var channel: MethodChannel

    private lateinit var scope: CoroutineScope

    private var connectivity: ConnectivityManager? = null

    private val iconMap = mutableMapOf<String, String?>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext;
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun tip(message: String?) {
        if (toast != null) {
            toast!!.cancel()
        }
        toast = Toast.makeText(context, message, Toast.LENGTH_SHORT)
        toast!!.show()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "moveTaskToBack" -> {
                activity?.moveTaskToBack(true)
                result.success(true);
            }

            "getPackages" -> {
                scope.launch {
                    result.success(getPackages())
                }
            }

            "getPackageIcon" -> {
                scope.launch {
                    val packageName = call.argument<String>("packageName")
                    if (packageName == null) {
                        result.success(null)
                        return@launch
                    }
                    val packageIcon = getPackageIcon(packageName)
                    packageIcon.let {
                        if (it != null) {
                            result.success(it)
                            return@launch
                        }
                        if (iconMap["default"] == null) {
                            iconMap["default"] =
                                context?.packageManager?.defaultActivityIcon?.getBase64()
                        }
                        result.success(iconMap["default"])
                        return@launch
                    }
                }
            }

            "resolverProcess" -> {
                val data = call.argument<String>("data")
                val process =
                    if (data != null) Gson().fromJson(
                        data,
                        Process::class.java
                    ) else null
                val metadata = process?.metadata
                val protocol = metadata?.getProtocol()
                if (protocol == null) {
                    result.success(null)
                    return
                }
                scope.launch {
                    withContext(Dispatchers.Default) {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q){
                            result.success(null)
                            return@withContext
                        }
                        if (context == null) {
                            result.success(null)
                            return@withContext
                        }
                        if (connectivity == null) {
                            connectivity = context!!.getSystemService<ConnectivityManager>()
                        }
                        val src = InetSocketAddress(metadata.sourceIP, metadata.sourcePort)
                        val dst = InetSocketAddress(
                            metadata.destinationIP.ifEmpty { metadata.host },
                            metadata.destinationPort
                        )
                        val uid = try {
                            connectivity?.getConnectionOwnerUid(protocol, src, dst)
                        } catch (_: Exception) {
                            null
                        }
                        if (uid == null || uid == -1) {
                            result.success(null)
                            return@withContext
                        }
                        val packages = context?.packageManager?.getPackagesForUid(uid)
                        result.success(packages?.first())
                    }
                }
            }

            "tip" -> {
                val message = call.argument<String>("message")
                tip(message)
                result.success(true)
            }

            else -> {
                result.notImplemented();
            }
        }
    }

    private suspend fun getPackageIcon(packageName: String): String? {
        val packageManager = context?.packageManager
        if (iconMap[packageName] == null) {
            iconMap[packageName] = try {
                packageManager?.getApplicationIcon(packageName)?.getBase64()
            } catch (_: Exception) {
                null
            }

        }
        return iconMap[packageName]
    }

    private suspend fun getPackages(): String {
        return withContext(Dispatchers.Default) {
            val packageManager = context?.packageManager
            val packages: List<Package>? =
                packageManager?.getInstalledPackages(PackageManager.GET_META_DATA)?.filter {
                    it.packageName != context?.packageName
                            || it.requestedPermissions?.contains(Manifest.permission.INTERNET) == true
                            || it.packageName == "android"

                }?.map {
                    Package(
                        packageName = it.packageName,
                        label = it.applicationInfo.loadLabel(packageManager).toString(),
                        isSystem = (it.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 1
                    )
                }
            Gson().toJson(packages)
        }
    }

    fun requestGc() {
        channel.invokeMethod("gc", null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
        scope = CoroutineScope(Dispatchers.Default)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivity() {
        channel.invokeMethod("exit", null)
        scope.cancel()
        activity = null;
    }
}
