package com.follow.clash.plugins

import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.app.DownloadManager
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.BroadcastReceiver
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.provider.Settings
import android.security.KeyChain
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.content.IntentCompat
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import androidx.core.net.toUri
import androidx.core.view.OnApplyWindowInsetsListener
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.follow.clash.R
import com.follow.clash.SystemCaStore
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import com.follow.clash.common.PendingCallback
import com.follow.clash.common.QuickAction
import com.follow.clash.common.quickIntent
import com.follow.clash.common.registerReceiverCompat
import com.follow.clash.common.shortcutId
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
import kotlinx.coroutines.withContext
import java.io.File
import java.io.IOException

class AppPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private var activity: Activity? = null

    private var activityBinding: ActivityPluginBinding? = null

    private val activityResultListener =
        PluginRegistry.ActivityResultListener(::onActivityResult)

    private val permissionsResultListener =
        PluginRegistry.RequestPermissionsResultListener(::onRequestPermissionsResultListener)

    private lateinit var channel: MethodChannel

    private lateinit var flutterAssets: FlutterPlugin.FlutterAssets

    private lateinit var scope: CoroutineScope

    private val vpnPrepareCallback = PendingCallback<Boolean>()

    private val requestNotificationCallback = PendingCallback<Boolean>()

    private val requestInstalledAppsCallback = PendingCallback<Boolean>()

    private val requestLocalNetworkCallback = PendingCallback<Boolean>()

    private val installPackageCallback = PendingCallback<Int>()

    private var isRequestingNotificationPermission = false

    private var isRequestingLocalNetworkPermission = false

    private var skipLocalNetworkPermissionRequest = false

    private val gson = Gson()

    private val packageResolver by lazy {
        PackageResolver(
            GlobalState.application.packageManager,
            GlobalState.application.packageName,
        )
    }

    private var packageChangeContext: Context? = null

    private val packageChangeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null || intent.data?.schemeSpecificPart == GlobalState.application.packageName) {
                return
            }
            val addedByUpdate = intent.action == Intent.ACTION_PACKAGE_ADDED &&
                intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)
            if (addedByUpdate) {
                return
            }
            packageResolver.invalidate()
            channel.invokeMethod("packagesChanged", null)
        }
    }

    private val installStatusReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null) {
                return
            }
            val status = intent.getIntExtra(
                PackageInstaller.EXTRA_STATUS,
                PackageInstaller.STATUS_FAILURE,
            )
            if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
                confirmInstall(intent)
                return
            }
            if (status != PackageInstaller.STATUS_SUCCESS) {
                val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)
                GlobalState.log("Package install ended with $status: $message")
            }
            installPackageCallback.resolve(status)
        }
    }

    private var skipNotificationPermissionRequest = false

    @Suppress("DEPRECATION")
    private val isTelevision by lazy {
        val packageManager = GlobalState.application.packageManager
        packageManager.hasSystemFeature(PackageManager.FEATURE_TELEVISION) ||
            packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
    }

    private var floatingIme = false

    // A TV keyboard floats over the app and reports a zero-height IME inset.
    private val imeInsetsListener = OnApplyWindowInsetsListener { view, insets ->
        val ime = WindowInsetsCompat.Type.ime()
        reportFloatingIme(insets.isVisible(ime) && insets.getInsets(ime).bottom == 0)
        ViewCompat.onApplyWindowInsets(view, insets)
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    /**
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

    override fun onMethodCall(call: MethodCall, result: Result) {
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
                val labels = shortcutLabels(call.arguments)
                if (labels == null) {
                    result.error(
                        "INVALID_ARGUMENT",
                        "Shortcut labels must map every quick action to a string",
                        null,
                    )
                } else {
                    initShortcuts(labels)
                    result.success(true)
                }
            }

            "getPackages" -> reply(result) {
                gson.toJson(packageResolver.installedPackages)
            }

            "getChinaPackageNames" -> reply(result) {
                gson.toJson(packageResolver.getChinaPackageNames())
            }

            "isInstalledAppsPermissionGranted" -> reply(result) {
                packageResolver.hasInstalledAppsPermission()
            }

            "requestInstalledAppsPermission" -> {
                requestInstalledAppsPermission { granted -> result.success(granted) }
            }

            "requestLocalNetworkPermission" -> {
                requestLocalNetworkPermission { granted -> result.success(granted) }
            }

            "getPackageIcon" -> {
                handleGetPackageIcon(call, result)
            }

            "tip" -> {
                val message = call.argument<String>("message")
                GlobalState.application.showToast(message)
                result.success(true)
            }

            "openAppSettings" -> {
                result.success(openAppSettings())
            }

            "getLastExitInfo" -> reply(result) {
                GlobalState.lastExitInfo()
            }

            "locateCaCertificate" -> reply(result) {
                SystemCaStore.locate(requireNotNull(call.argument<ByteArray>("der")))
            }

            "installCaCertificateWithRoot" -> reply(result) {
                SystemCaStore.install(
                    GlobalState.application,
                    requireNotNull(call.argument<ByteArray>("der")),
                )
            }

            "hasRootAccess" -> reply(result) {
                SystemCaStore.hasRootAccess(GlobalState.application)
            }

            "removeCaCertificateWithRoot" -> reply(result) {
                SystemCaStore.remove(
                    GlobalState.application,
                    requireNotNull(call.argument<ByteArray>("der")),
                )
            }

            "installCaCertificate" -> reply(result) {
                installCaCertificate(
                    requireNotNull(call.argument<ByteArray>("der")),
                    requireNotNull(call.argument<String>("name")),
                    requireNotNull(call.argument<String>("fileName")),
                )
            }

            "openCertificateSettings" -> {
                val userCredentials = call.argument<Boolean>("userCredentials") == true
                onMainThread { result.success(openCertificateSettings(userCredentials)) }
            }

            "extractAsset" -> reply(result) {
                extractAsset(
                    requireNotNull(call.argument<String>("asset")),
                    requireNotNull(call.argument<String>("path")),
                )
                true
            }

            "enqueueDownload" -> reply(result) {
                enqueueDownload(
                    requireNotNull(call.argument<String>("url")),
                    File(requireNotNull(call.argument<String>("path"))),
                    call.argument<String>("title"),
                    call.argument<String>("userAgent"),
                )
            }

            "queryDownload" -> reply(result) {
                queryDownload(requireNotNull(call.argument<Number>("id")).toLong())
            }

            "clearDownloads" -> reply(result) {
                clearDownloads()
                true
            }

            "installPackage" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("INVALID_ARGUMENT", "installPackage needs a path", null)
                } else {
                    installPackage(File(path)) { status -> result.success(status) }
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    // From Android 11 an app can no longer hand a CA certificate to the
    // installer; the user picks the saved file under Settings instead.
    private suspend fun installCaCertificate(der: ByteArray, name: String, fileName: String): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            val intent = KeyChain.createInstallIntent().apply {
                putExtra(KeyChain.EXTRA_CERTIFICATE, der)
                putExtra(KeyChain.EXTRA_NAME, name)
            }
            return if (withContext(Dispatchers.Main) { startSettings(intent) }) "prompted" else "unavailable"
        }
        saveToDownloads(der, fileName)
        return "saved"
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun saveToDownloads(data: ByteArray, fileName: String) {
        val resolver = GlobalState.application.contentResolver
        val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
        val existing = resolver.query(
            collection,
            arrayOf(MediaStore.MediaColumns._ID),
            "${MediaStore.MediaColumns.DISPLAY_NAME} = ?",
            arrayOf(fileName),
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) ContentUris.withAppendedId(collection, cursor.getLong(0)) else null
        }
        val uri = existing ?: resolver.insert(
            collection,
            ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/x-x509-ca-cert")
            },
        ) ?: throw IOException("Unable to create $fileName in Downloads")
        resolver.openOutputStream(uri, "wt")?.use { it.write(data) }
            ?: throw IOException("Unable to write $fileName in Downloads")
    }

    // The list of user certificates is a Settings screen without a public
    // action on every ROM, so the security screen stands in for it.
    private fun openCertificateSettings(userCredentials: Boolean): Boolean {
        val intents = buildList {
            if (userCredentials) {
                add(Intent("com.android.settings.TRUSTED_CREDENTIALS_USER"))
            }
            add(Intent(Settings.ACTION_SECURITY_SETTINGS))
            add(Intent(Settings.ACTION_SETTINGS))
        }
        return intents.any(::startSettings)
    }

    private fun startSettings(intent: Intent): Boolean {
        val context: Context = activity ?: GlobalState.application.also {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return try {
            context.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        } catch (_: SecurityException) {
            false
        }
    }

    private fun extractAsset(asset: String, path: String) {
        val partial = File("$path.part")
        val key = flutterAssets.getAssetFilePathByName(asset)
        GlobalState.application.assets.open(key).use { input ->
            partial.outputStream().use { output -> input.copyTo(output, 1 shl 16) }
        }
        if (!partial.renameTo(File(path))) {
            throw IOException("Unable to move $asset to $path")
        }
    }

    private val downloadManager: DownloadManager
        get() = requireNotNull(
            GlobalState.application.getSystemService(DownloadManager::class.java),
        )

    // The system download service keeps going while this app is in the
    // background, where its own network access may be cut off.
    private fun enqueueDownload(
        url: String,
        destination: File,
        title: String?,
        userAgent: String?,
    ): Long {
        destination.delete()
        val request = DownloadManager.Request(url.toUri())
            .setDestinationUri(Uri.fromFile(destination))
            .setTitle(title)
            .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)
        userAgent?.let { request.addRequestHeader("User-Agent", it) }
        return downloadManager.enqueue(request)
    }

    private fun queryDownload(id: Long): Map<String, Any>? {
        val query = DownloadManager.Query().setFilterById(id)
        return downloadManager.query(query)?.use { cursor ->
            if (!cursor.moveToFirst()) {
                return@use null
            }
            fun column(name: String) = cursor.getColumnIndexOrThrow(name)
            mapOf(
                "status" to cursor.getInt(column(DownloadManager.COLUMN_STATUS)),
                "reason" to cursor.getInt(column(DownloadManager.COLUMN_REASON)),
                "received" to cursor.getLong(
                    column(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR),
                ),
                "total" to cursor.getLong(column(DownloadManager.COLUMN_TOTAL_SIZE_BYTES)),
            )
        }
    }

    // A query only sees the downloads this app started, which are all updates;
    // removing one deletes its file too.
    private fun clearDownloads() {
        val ids = downloadManager.query(DownloadManager.Query())?.use { cursor ->
            val column = cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_ID)
            buildList { while (cursor.moveToNext()) add(cursor.getLong(column)) }
        }.orEmpty()
        if (ids.isNotEmpty()) {
            downloadManager.remove(*ids.toLongArray())
        }
    }

    private fun installPackage(apk: File, callback: (Int) -> Unit) {
        installPackageCallback.replace(
            callback,
            supersededValue = PackageInstaller.STATUS_FAILURE_ABORTED,
        )
        scope.launch(Dispatchers.IO) {
            try {
                commitInstallSession(apk)
            } catch (error: Exception) {
                GlobalState.log("Package install failed: $error")
                installPackageCallback.resolve(PackageInstaller.STATUS_FAILURE)
            }
        }
    }

    private fun commitInstallSession(apk: File) {
        val application = GlobalState.application
        val installer = application.packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(
            PackageInstaller.SessionParams.MODE_FULL_INSTALL,
        ).apply { setAppPackageName(application.packageName) }
        val sessionId = installer.createSession(params)
        try {
            installer.openSession(sessionId).use { session ->
                apk.inputStream().use { input ->
                    session.openWrite(apk.name, 0, apk.length()).use { output ->
                        input.copyTo(output, 1 shl 16)
                        session.fsync(output)
                    }
                }
                session.commit(installStatusIntent(sessionId).intentSender)
            }
        } catch (error: Exception) {
            runCatching { installer.abandonSession(sessionId) }
            throw error
        }
    }

    private fun installStatusIntent(sessionId: Int): PendingIntent {
        val application = GlobalState.application
        val intent = Intent(INSTALL_STATUS_ACTION).setPackage(application.packageName)
        // The installer writes the status into the intent's extras.
        val mutable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_MUTABLE
        } else {
            0
        }
        return PendingIntent.getBroadcast(
            application,
            sessionId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or mutable,
        )
    }

    private fun confirmInstall(intent: Intent) = onMainThread {
        val confirmation = IntentCompat.getParcelableExtra(
            intent,
            Intent.EXTRA_INTENT,
            Intent::class.java,
        )
        if (confirmation == null) {
            installPackageCallback.resolve(PackageInstaller.STATUS_FAILURE)
            return@onMainThread
        }
        val activity = activity
        if (activity != null) {
            activity.startActivity(confirmation)
        } else {
            GlobalState.application.startActivity(
                confirmation.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        }
    }

    private fun handleGetPackageIcon(call: MethodCall, result: Result) = reply(result) {
        val packageName = call.argument<String>("packageName") ?: ""
        GlobalState.application.packageManager.getPackageIconPath(packageName)
    }

    // A throw inside the plugin scope has no handler and ends the process;
    // the Dart caller gets a PlatformException to handle instead.
    private fun reply(result: Result, block: suspend () -> Any?) {
        scope.launch(Dispatchers.IO) {
            try {
                result.success(block())
            } catch (error: Exception) {
                GlobalState.log("Platform call failed: $error")
                result.error("PLATFORM_ERROR", error.toString(), null)
            }
        }
    }

    private fun shortcutLabels(arguments: Any?): Map<QuickAction, String>? {
        val map = arguments as? Map<*, *> ?: return null
        return QuickAction.entries.associateWith { action ->
            map[action.shortcutId] as? String ?: return null
        }
    }

    private fun initShortcuts(labels: Map<QuickAction, String>) {
        val shortcuts = SHORTCUT_ORDER.mapIndexed { rank, action ->
            with(ShortcutInfoCompat.Builder(GlobalState.application, action.shortcutId)) {
                setShortLabel(labels.getValue(action))
                setIcon(IconCompat.createWithResource(GlobalState.application, action.shortcutIcon))
                setIntent(action.quickIntent)
                setRank(rank)
                build()
            }
        }
        ShortcutManagerCompat.setDynamicShortcuts(GlobalState.application, shortcuts)
    }

    // Plain circles, not adaptive icons: an adaptive shortcut icon takes the
    // launcher's own mask, which is a square on many devices.
    private val QuickAction.shortcutIcon: Int
        get() = when (this) {
            QuickAction.START -> R.drawable.ic_shortcut_start
            QuickAction.STOP -> R.drawable.ic_shortcut_stop
            QuickAction.TOGGLE -> R.drawable.ic_shortcut_toggle
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
        val taskId = activity?.taskId ?: return
        val am = getSystemService(GlobalState.application, ActivityManager::class.java)
        val task = am?.appTasks?.firstOrNull {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                it.taskInfo?.taskId == taskId
            } else {
                it.taskInfo?.id == taskId
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

    fun requestLocalNetworkPermission(callback: (Boolean) -> Unit) = onMainThread {
        requestLocalNetworkCallback.replace(callback, supersededValue = false)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.CINNAMON_BUN || hasLocalNetworkPermission()) {
            invokeRequestLocalNetworkCallback(true)
            return@onMainThread
        }
        if (skipLocalNetworkPermissionRequest) {
            invokeRequestLocalNetworkCallback(false)
            return@onMainThread
        }
        if (isRequestingLocalNetworkPermission) {
            return@onMainThread
        }
        val activity = activity
        if (activity == null) {
            invokeRequestLocalNetworkCallback(false)
            return@onMainThread
        }
        isRequestingLocalNetworkPermission = true
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.ACCESS_LOCAL_NETWORK),
            LOCAL_NETWORK_PERMISSION_REQUEST_CODE,
        )
    }

    private fun hasLocalNetworkPermission(): Boolean = ContextCompat.checkSelfPermission(
        GlobalState.application,
        Manifest.permission.ACCESS_LOCAL_NETWORK,
    ) == PackageManager.PERMISSION_GRANTED

    private fun invokeRequestLocalNetworkCallback(granted: Boolean) {
        isRequestingLocalNetworkPermission = false
        requestLocalNetworkCallback.resolve(granted)
    }

    private fun requestInstalledAppsPermission(callback: (Boolean) -> Unit) = onMainThread {
        requestInstalledAppsCallback.replace(callback, supersededValue = false)
        val activity = activity
        if (packageResolver.hasInstalledAppsPermission()) {
            invokeRequestInstalledAppsCallback(true)
            return@onMainThread
        }
        if (activity == null) {
            invokeRequestInstalledAppsCallback(false)
            return@onMainThread
        }
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(PackageResolver.GET_INSTALLED_APPS),
            INSTALLED_APPS_PERMISSION_REQUEST_CODE,
        )
    }

    private fun invokeRequestInstalledAppsCallback(granted: Boolean) {
        if (granted) {
            packageResolver.invalidate()
        }
        requestInstalledAppsCallback.resolve(granted)
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
        flutterAssets = flutterPluginBinding.flutterAssets
        watchPackageChanges(flutterPluginBinding.applicationContext)
        flutterPluginBinding.applicationContext.registerReceiverCompat(
            installStatusReceiver,
            IntentFilter(INSTALL_STATUS_ACTION),
        )
    }

    private fun watchPackageChanges(context: Context) {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REPLACED)
            addAction(Intent.ACTION_PACKAGE_FULLY_REMOVED)
            addDataScheme("package")
        }
        context.registerReceiverCompat(packageChangeReceiver, filter)
        packageChangeContext = context
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        packageChangeContext?.unregisterReceiver(packageChangeReceiver)
        packageChangeContext = null
        binding.applicationContext.unregisterReceiver(installStatusReceiver)
        channel.setMethodCallHandler(null)
        scope.cancel()
        invokeVpnPrepareCallback(false)
        invokeRequestNotificationCallback(false)
        invokeRequestLocalNetworkCallback(false)
        invokeRequestInstalledAppsCallback(false)
        installPackageCallback.resolve(PackageInstaller.STATUS_FAILURE_ABORTED)
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
        if (isTelevision) {
            ViewCompat.setOnApplyWindowInsetsListener(
                binding.activity.window.decorView,
                imeInsetsListener,
            )
        }
    }

    private fun detachFromActivity() {
        if (isTelevision) {
            activity?.window?.decorView?.let {
                ViewCompat.setOnApplyWindowInsetsListener(it, null)
            }
            reportFloatingIme(false)
        }
        activity = null
        val binding = activityBinding ?: return
        activityBinding = null
        binding.removeActivityResultListener(activityResultListener)
        binding.removeRequestPermissionsResultListener(permissionsResultListener)
    }

    private fun reportFloatingIme(floating: Boolean) {
        if (floating == floatingIme) {
            return
        }
        floatingIme = floating
        channel.invokeMethod("floatingImeChanged", floating)
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
        invokeRequestLocalNetworkCallback(false)
        invokeRequestInstalledAppsCallback(false)
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
    ): Boolean = when (requestCode) {
        NOTIFICATION_PERMISSION_REQUEST_CODE -> {
            skipNotificationPermissionRequest = true
            invokeRequestNotificationCallback(true)
            true
        }

        INSTALLED_APPS_PERMISSION_REQUEST_CODE -> {
            invokeRequestInstalledAppsCallback(
                grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED,
            )
            true
        }

        LOCAL_NETWORK_PERMISSION_REQUEST_CODE -> {
            skipLocalNetworkPermissionRequest = true
            invokeRequestLocalNetworkCallback(
                grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED,
            )
            true
        }

        else -> false
    }

    private companion object {
        val SHORTCUT_ORDER = listOf(QuickAction.START, QuickAction.STOP, QuickAction.TOGGLE)
        const val VPN_PERMISSION_REQUEST_CODE = 1001
        const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002
        const val INSTALLED_APPS_PERMISSION_REQUEST_CODE = 1003
        const val LOCAL_NETWORK_PERMISSION_REQUEST_CODE = 1004
        const val INSTALL_STATUS_ACTION = "${Components.PACKAGE_NAME}.action.INSTALL_STATUS"
    }
}
