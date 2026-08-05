package com.follow.clash

import android.net.VpnService
import com.follow.clash.common.GlobalState
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.ServiceConfig
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import java.util.concurrent.atomic.AtomicReference
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlin.coroutines.resume

enum class RunState {
    STARTED,
    STARTING,
    STOPPING,
    STOPPED,
}

private const val MISSING_CONFIG_MESSAGE = "No configuration found."
private const val INVALID_CONFIG_MESSAGE = "Invalid configuration."
private const val VPN_PERMISSION_MESSAGE = "VPN permission required."
private const val START_FAILED_MESSAGE = "Failed to start service."

object ServiceState {
    private val transitionLock = Mutex()
    private val startPreparationLock = Mutex()
    private val mutableRunState = MutableStateFlow(RunState.STOPPED)
    private val latestRequest = AtomicReference(RunRequest(running = false))

    @Volatile
    private var sharedState = SharedState()

    @Volatile
    private var flutterEngine: FlutterEngine? = null

    val runState = mutableRunState.asStateFlow()

    private val runTimeMillis: Long
        get() = ServiceController.getRunTimeMillis()

    private val appPlugin: AppPlugin?
        get() = flutterEngine?.plugin<AppPlugin>()

    private val tilePlugin: TilePlugin?
        get() = flutterEngine?.plugin<TilePlugin>()

    fun attachFlutterEngine(engine: FlutterEngine) {
        flutterEngine = engine
    }

    fun detachFlutterEngine(engine: FlutterEngine) {
        if (flutterEngine === engine) {
            flutterEngine = null
        }
    }

    suspend fun handleToggleAction() {
        if (isRunningRequested()) {
            handleStopAction()
        } else {
            handleStartAction()
        }
    }

    suspend fun refresh(): Long = transitionLock.withLock {
        val current = runTimeMillis
        mutableRunState.value = if (current == 0L) RunState.STOPPED else RunState.STARTED
        current
    }

    internal fun captureRequestToken(): RunRequest = latestRequest.get()

    /**
     * Settles the state after the bound service was lost. [token] is the request that was current
     * when the loss was observed, so a start that raced ahead of this callback keeps its intent.
     */
    internal suspend fun handleServiceLost(token: RunRequest) = transitionLock.withLock {
        if (runTimeMillis != 0L) {
            return@withLock
        }
        if (!latestRequest.compareAndSet(token, RunRequest(running = false))) {
            return@withLock
        }
        mutableRunState.value = RunState.STOPPED
    }

    suspend fun handleStartAction() {
        if (isRunningRequested()) {
            return
        }
        val plugin = tilePlugin
        if (plugin != null) {
            plugin.handleStart()
            return
        }
        loadPreferencesAndStart()
    }

    suspend fun handleStopAction() {
        if (!isRunningRequested()) {
            return
        }
        val plugin = tilePlugin
        if (plugin != null) {
            plugin.handleStop()
            return
        }
        GlobalState.application.showToast(sharedState.stopTip)
        requestStop().await()
    }

    suspend fun handleVpnRevokeAction() {
        if (!ServiceController.isVpnServiceActive()) {
            return
        }
        handleStopAction()
    }

    fun requestStart(): Deferred<Boolean> {
        val request = createRequest(running = true)
        val result = CompletableDeferred<Boolean>()
        val launchRequest: (Boolean) -> Unit = { shouldStart ->
            if (!shouldStart) {
                fail(request)
                result.complete(false)
            } else {
                GlobalState.launch {
                    result.complete(
                        runCatching { start(request) }
                            .onFailure { error ->
                                GlobalState.log("Unable to process service start request: $error")
                                fail(request)
                            }
                            .getOrDefault(false),
                    )
                }
            }
        }
        val plugin = appPlugin
        if (plugin != null) {
            plugin.requestNotificationPermission(launchRequest)
        } else {
            launchRequest(true)
        }
        return result
    }

    fun requestStop(): Deferred<Boolean> {
        val request = createRequest(running = false)
        val result = CompletableDeferred<Boolean>()
        GlobalState.launch {
            result.complete(
                runCatching { stop(request) }
                    .onFailure { error ->
                        GlobalState.log("Unable to process service stop request: $error")
                    }
                    .getOrDefault(false),
            )
        }
        return result
    }

    fun syncSharedState(state: SharedState) {
        sharedState = state
        applySharedState()
    }

    private suspend fun loadPreferencesAndStart() {
        sharedState = GlobalState.application.sharedState
        if (sharedState.setupParams == null || sharedState.vpnOptions == null) {
            GlobalState.application.showToast(MISSING_CONFIG_MESSAGE)
            return
        }
        if (setupCore()) {
            if (!requestStart().await()) {
                GlobalState.application.showToast(START_FAILED_MESSAGE)
            }
        }
    }

    private fun applySharedState() {
        GlobalState.setCrashlytics(sharedState.crashlytics)
        ServiceConfig.updateNotificationParams(
            NotificationParams(
                title = sharedState.currentProfileName,
                stopText = sharedState.stopText,
                onlyStatisticsProxy = sharedState.onlyStatisticsProxy,
            ),
        )
    }

    private suspend fun setupCore(): Boolean {
        applySharedState()
        GlobalState.application.showToast(sharedState.startTip)
        val initParams = Gson().toJson(
            mapOf(
                "home-dir" to GlobalState.application.filesDir.path,
                "version" to android.os.Build.VERSION.SDK_INT,
            ),
        )
        val setupParams = Gson().toJson(sharedState.setupParams)
        return ServiceController.quickSetup(
            initParams,
            setupParams,
        ).fold(
            onSuccess = { message ->
                if (message.isEmpty()) {
                    true
                } else {
                    GlobalState.log("Unable to set up core: $message")
                    showConfigError(message)
                    false
                }
            },
            onFailure = { error ->
                GlobalState.log("Unable to set up core: $error")
                showConfigError(error.message)
                false
            },
        )
    }

    private fun showConfigError(message: String?) {
        GlobalState.application.showToast(
            message?.takeIf { it.isNotBlank() } ?: INVALID_CONFIG_MESSAGE,
        )
    }

    private suspend fun start(request: RunRequest): Boolean = startPreparationLock.withLock {
        if (!isCurrent(request)) {
            return@withLock false
        }
        val options = sharedState.vpnOptions
        if (options == null) {
            fail(request)
            return@withLock false
        }
        if (!prepareVpn(options)) {
            if (appPlugin == null && isCurrent(request)) {
                GlobalState.application.showToast(VPN_PERMISSION_MESSAGE)
            }
            fail(request)
            return@withLock false
        }
        if (!isCurrent(request)) {
            return@withLock false
        }

        transitionLock.withLock transition@{
            if (!isCurrent(request)) {
                return@transition false
            }
            if (runState.value == RunState.STARTED && runTimeMillis != 0L) {
                return@transition true
            }
            mutableRunState.value = RunState.STARTING
            val startedAtMillis = ServiceController.start(options)
            mutableRunState.value =
                if (startedAtMillis == 0L) RunState.STOPPED else RunState.STARTED
            if (startedAtMillis == 0L) {
                fail(request)
                return@transition false
            }
            isCurrent(request)
        }
    }

    private suspend fun stop(request: RunRequest): Boolean = transitionLock.withLock {
        if (!isCurrent(request)) {
            return@withLock false
        }
        if (runState.value == RunState.STOPPED && runTimeMillis == 0L) {
            return@withLock true
        }
        mutableRunState.value = RunState.STOPPING
        ServiceController.stop()
        mutableRunState.value = RunState.STOPPED
        isCurrent(request)
    }

    private suspend fun prepareVpn(options: VpnOptions): Boolean {
        val plugin = appPlugin
            ?: return !options.enable || VpnService.prepare(GlobalState.application) == null
        return suspendCancellableCoroutine { continuation ->
            val callback: (Boolean) -> Unit = { granted ->
                if (continuation.isActive) {
                    continuation.resume(granted)
                }
            }
            continuation.invokeOnCancellation {
                plugin.cancelVpnPreparation(callback)
            }
            plugin.prepareVpn(options.enable, callback)
        }
    }

    private fun createRequest(running: Boolean): RunRequest =
        RunRequest(running).also(latestRequest::set)

    private fun isRunningRequested(): Boolean = latestRequest.get().running

    private fun isCurrent(request: RunRequest): Boolean = latestRequest.get() === request

    private fun fail(request: RunRequest) {
        latestRequest.compareAndSet(request, RunRequest(running = false))
    }

    internal class RunRequest(
        val running: Boolean,
    )
}
