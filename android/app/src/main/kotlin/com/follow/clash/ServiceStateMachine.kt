package com.follow.clash

import com.follow.clash.common.RunIntentArbiter
import com.follow.clash.models.SharedState
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.async
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

internal typealias RunRequest = RunIntentArbiter.Token

internal const val MISSING_CONFIG_MESSAGE = "No configuration found."
internal const val INVALID_CONFIG_MESSAGE = "Invalid configuration."
internal const val VPN_PERMISSION_MESSAGE = "VPN permission required."
internal const val START_FAILED_MESSAGE = "Failed to start service."

private enum class StartOutcome {
    STARTED,
    FAILED,
    SUPERSEDED,
}

/**
 * Callers request a transition; the newest request always wins. No step assigns [runState]:
 * [publish] derives it from the latest intent, the transition in flight and what the host really
 * runs, so no path can leave it claiming a service that is not there.
 */
internal class ServiceStateMachine(private val host: ServiceStateHost) {
    private val transitionLock = Mutex()
    private val startPreparationLock = Mutex()
    private val mutableRunState = MutableStateFlow(RunState.STOPPED)
    private val arbiter = RunIntentArbiter()

    @Volatile
    private var sharedState = SharedState()

    @Volatile
    private var pendingVpnPreparation: (() -> Unit)? = null

    @Volatile
    private var transition: RunState? = null

    val runState = mutableRunState.asStateFlow()

    val isRunRequested: Boolean
        get() = arbiter.isRunningRequested

    suspend fun handleToggleAction() {
        if (isRunRequested) {
            handleStopAction()
        } else {
            handleStartAction()
        }
    }

    suspend fun awaitRunTime(): Long = transitionLock.withLock {
        host.runtime?.startedAtMillis?.takeIf { isRunRequested } ?: 0L
    }

    fun captureRequestToken(): RunRequest = arbiter.current()

    /**
     * Settles the state after the bound service was lost. [token] is the request that was current
     * when the loss was observed, so a start that raced ahead of this callback keeps its intent.
     */
    suspend fun handleServiceLost(token: RunRequest) {
        val dropped = transitionLock.withLock {
            if (host.runtime != null) {
                return@withLock false
            }
            arbiter.resetToStopped(token).also { publish() }
        }
        if (dropped) {
            host.notifyStopped()
        }
    }

    suspend fun handleStartAction() {
        if (isRunRequested) {
            return
        }
        val tile = host.tile()
        if (tile != null) {
            tile.handleStart()
            return
        }
        startFromPreferences()
    }

    suspend fun handleStopAction() {
        if (!isRunRequested) {
            return
        }
        host.showToast(sharedState.stopTip)
        requestStop().await()
        host.notifyStopped()
    }

    suspend fun handleVpnRevokeAction() {
        if (host.runtime?.vpn != true) {
            return
        }
        handleStopAction()
    }

    fun requestStart(): Deferred<Boolean> {
        if (isStartedAs(sharedState.vpnOptions)) {
            return CompletableDeferred(true)
        }
        val outcome = launchStart(createRequest(running = true))
        return host.scope.async { outcome.await() == StartOutcome.STARTED }
    }

    fun requestStop(): Deferred<Boolean> {
        val request = createRequest(running = false)
        return host.scope.async { stop(request) }
    }

    fun syncSharedState(state: SharedState) {
        sharedState = state
        applySharedState()
    }

    // No new request for a settled run: one refused at a prompt would take the service down.
    private fun isStartedAs(options: VpnOptions?): Boolean =
        runState.value == RunState.STARTED && host.runtime?.vpn == options?.enable

    // The intent is claimed before the Core is set up, so a second action that lands meanwhile
    // toggles this start off instead of racing a second setup against it.
    private suspend fun startFromPreferences() {
        val request = createRequest(running = true)
        sharedState = host.loadSharedState()
        if (sharedState.setupParams == null || sharedState.vpnOptions == null) {
            host.showToast(MISSING_CONFIG_MESSAGE)
            abandon(request)
            return
        }
        if (!setupCore()) {
            abandon(request)
        } else if (launchStart(request).await() == StartOutcome.FAILED) {
            host.showToast(START_FAILED_MESSAGE)
        }
    }

    private fun launchStart(request: RunRequest): Deferred<StartOutcome> {
        val result = CompletableDeferred<StartOutcome>()
        val launch: (Boolean) -> Unit = { permitted ->
            host.scope.launch {
                result.complete(if (permitted) start(request) else abandon(request))
            }
        }
        val app = host.app()
        if (app != null) {
            app.requestNotificationPermission { permitted ->
                if (permitted) {
                    app.requestLocalNetworkPermission { launch(true) }
                } else {
                    launch(false)
                }
            }
        } else {
            launch(true)
        }
        return result
    }

    private fun applySharedState() {
        host.setCrashlytics(sharedState.crashlytics)
        host.updateNotificationParams(notificationParams(sharedState))
    }

    private suspend fun setupCore(): Boolean {
        applySharedState()
        host.showToast(sharedState.startTip)
        return host.quickSetup(
            initParams(host.homeDirPath, host.sdkInt),
            Gson().toJson(sharedState.setupParams),
        ).fold(
            onSuccess = { message ->
                if (message.isEmpty()) {
                    true
                } else {
                    host.log("Unable to set up core: $message")
                    showConfigError(message)
                    false
                }
            },
            onFailure = { error ->
                host.log("Unable to set up core: $error")
                showConfigError(error.message)
                false
            },
        )
    }

    private fun showConfigError(message: String?) {
        host.showToast(message?.takeIf { it.isNotBlank() } ?: INVALID_CONFIG_MESSAGE)
    }

    private suspend fun start(request: RunRequest): StartOutcome {
        val started = try {
            startPreparationLock.withLock { runStart(request) }
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            host.log("Unable to process service start request: $error")
            false
        }
        return if (started) StartOutcome.STARTED else abandon(request)
    }

    private suspend fun abandon(request: RunRequest): StartOutcome {
        val dropped = arbiter.resetToStopped(request)
        reconcileStopped()
        if (!dropped) {
            return StartOutcome.SUPERSEDED
        }
        host.notifyStopped()
        return StartOutcome.FAILED
    }

    private suspend fun runStart(request: RunRequest): Boolean {
        if (!isCurrent(request)) {
            return false
        }
        val options = sharedState.vpnOptions ?: return false
        if (!prepareVpn(options)) {
            if (host.app() == null && isCurrent(request)) {
                host.showToast(VPN_PERMISSION_MESSAGE)
            }
            return false
        }
        return transitionLock.withLock {
            when {
                !isCurrent(request) -> false
                host.runtime?.vpn == options.enable -> true
                else -> transitioning(RunState.STARTING) {
                    host.startService(withLocalNetworkFallback(options)) && isCurrent(request)
                }
            }
        }
    }

    // system/mixed hand TCP to the kernel via the tun subnet, which Android 17 gates as local network.
    private fun withLocalNetworkFallback(options: VpnOptions): VpnOptions {
        if (!options.enable || options.stack !in KERNEL_TCP_STACKS ||
            host.isLocalNetworkPermissionGranted()
        ) {
            return options
        }
        host.showToast(sharedState.localNetworkTip)
        return options.copy(stack = FALLBACK_STACK)
    }

    // Flutter's startListener and the native quickSetup both open the Core's listeners before any
    // service exists to answer for them, and Flutter may be gone before it hears of the failure.
    private suspend fun reconcileStopped() = transitionLock.withLock {
        when {
            isRunRequested -> publish()
            host.runtime != null -> stopLocked()
            else -> {
                stopService()
                publish()
            }
        }
    }

    private suspend fun stop(request: RunRequest): Boolean = transitionLock.withLock {
        if (!isCurrent(request)) {
            return@withLock false
        }
        abandonVpnPreparation()
        if (host.runtime != null) {
            stopLocked()
        }
        isCurrent(request)
    }

    private suspend fun stopLocked() = transitioning(RunState.STOPPING) { stopService() }

    private suspend fun stopService() {
        try {
            host.stopService()
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            host.log("Unable to stop service: $error")
        }
    }

    private inline fun <T> transitioning(state: RunState, block: () -> T): T {
        transition = state
        publish()
        try {
            return block()
        } finally {
            transition = null
            publish()
        }
    }

    @Synchronized
    private fun publish() {
        mutableRunState.value = transition ?: when {
            host.runtime == null -> RunState.STOPPED
            isRunRequested -> RunState.STARTED
            else -> RunState.STOPPING
        }
    }

    private suspend fun prepareVpn(options: VpnOptions): Boolean {
        val app = host.app()
            ?: return !options.enable || host.isVpnPermissionGranted()
        return suspendCancellableCoroutine { continuation ->
            val callback: (Boolean) -> Unit = { granted ->
                pendingVpnPreparation = null
                if (continuation.isActive) {
                    continuation.resume(granted)
                }
            }
            pendingVpnPreparation = {
                app.cancelVpnPreparation(callback)
                callback(false)
            }
            continuation.invokeOnCancellation {
                pendingVpnPreparation = null
                app.cancelVpnPreparation(callback)
            }
            app.prepareVpn(options.enable, callback)
        }
    }

    private fun abandonVpnPreparation() {
        val abandon = pendingVpnPreparation ?: return
        pendingVpnPreparation = null
        abandon()
    }

    private fun createRequest(running: Boolean): RunRequest =
        arbiter.request(running).also { publish() }

    private fun isCurrent(request: RunRequest): Boolean = arbiter.isCurrent(request)

    internal companion object {
        val KERNEL_TCP_STACKS = setOf("system", "mixed")
        const val FALLBACK_STACK = "gvisor"

        /**
         * The Core init payload. The key spelling is a cross-language contract with the Go wrapper,
         * not an implementation detail.
         */
        fun initParams(homeDirPath: String, sdkInt: Int): String = Gson().toJson(
            mapOf(
                "home-dir" to homeDirPath,
                "version" to sdkInt,
            ),
        )

        fun notificationParams(state: SharedState): NotificationParams = NotificationParams(
            title = state.currentProfileName,
            stopText = state.stopText,
            onlyStatisticsProxy = state.onlyStatisticsProxy,
            showStopAction = state.showStopAction,
        )
    }
}
