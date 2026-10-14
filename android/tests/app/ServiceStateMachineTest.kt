package com.follow.clash

import com.follow.clash.common.AccessControlMode
import com.follow.clash.models.SetupParams
import com.follow.clash.models.SharedState
import com.follow.clash.service.models.AccessControlProps
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

private fun vpnOptions(enable: Boolean = true, stack: String = "gvisor") = VpnOptions(
    enable = enable,
    port = 7890,
    ipv6 = false,
    dnsHijacking = false,
    accessControlProps = AccessControlProps(
        enable = false,
        mode = AccessControlMode.ACCEPT_SELECTED,
        acceptList = emptyList(),
        rejectList = emptyList(),
    ),
    allowBypass = false,
    systemProxy = true,
    bypassDomain = emptyList(),
    stack = stack,
    routeAddress = emptyList(),
)

private fun configuredState(enable: Boolean = true, stack: String = "gvisor") = SharedState(
    vpnOptions = vpnOptions(enable, stack),
    setupParams = SetupParams(testUrl = "https://example.com", selectedMap = emptyMap()),
)

private const val STARTED_AT = 1_700_000_000_000L

private class FakeTile : TileGateway {
    var startCount = 0

    override fun handleStart() {
        startCount++
    }
}

private class FakeApp(
    private val notificationGranted: Boolean = true,
    private val localNetworkGranted: Boolean = true,
    private val vpnGranted: Boolean = true,
    private val holdVpnPreparation: Boolean = false,
) : AppGateway {
    var beforeVpnPrepared: (() -> Unit)? = null
    var cancelledPreparations = 0
    var localNetworkRequests = 0

    private var heldCallback: ((Boolean) -> Unit)? = null

    override fun requestNotificationPermission(callback: (Boolean) -> Unit) =
        callback(notificationGranted)

    override fun requestLocalNetworkPermission(callback: (Boolean) -> Unit) {
        localNetworkRequests++
        callback(localNetworkGranted)
    }

    override fun prepareVpn(enable: Boolean, callback: (Boolean) -> Unit) {
        beforeVpnPrepared?.invoke()
        if (holdVpnPreparation) {
            heldCallback = callback
            return
        }
        callback(vpnGranted)
    }

    override fun cancelVpnPreparation(callback: (Boolean) -> Unit) {
        cancelledPreparations++
        if (heldCallback === callback) {
            heldCallback = null
        }
    }
}

private class FakeHost(override val scope: CoroutineScope) : ServiceStateHost {
    var storedSharedState = configuredState()
    var setupResult: Result<String> = Result.success("")
    var startSucceeds = true
    var vpnPermissionGranted = true
    var localNetworkPermissionGranted = true
    var runsAsVpn: Boolean? = null
    var tile: TileGateway? = null
    var app: AppGateway? = null
    var duringSetup: (suspend () -> Unit)? = null
    var beforeStartService: (() -> Unit)? = null
    var lastStartOptions: VpnOptions? = null

    override var runtime: ServiceRuntime? = null
    override val homeDirPath = "/data/user/0/com.follow.clash/files"
    override val sdkInt = 34

    val toasts = mutableListOf<String>()
    val logs = mutableListOf<String>()
    val notificationParams = mutableListOf<NotificationParams>()
    val crashlytics = mutableListOf<Boolean>()
    var setupCalls = 0
    var startCalls = 0
    var stopCalls = 0
    var stoppedNotifications = 0
    var lastInitParams: String? = null
    var lastSetupParams: String? = null

    override fun log(message: String) {
        logs += message
    }

    override fun showToast(message: String) {
        toasts += message
    }

    override fun setCrashlytics(enabled: Boolean) {
        crashlytics += enabled
    }

    override fun updateNotificationParams(params: NotificationParams) {
        notificationParams += params
    }

    override fun loadSharedState(): SharedState = storedSharedState

    override fun isVpnPermissionGranted(): Boolean = vpnPermissionGranted

    override fun isLocalNetworkPermissionGranted(): Boolean = localNetworkPermissionGranted

    override fun tile(): TileGateway? = tile

    override fun app(): AppGateway? = app

    override fun notifyStopped() {
        stoppedNotifications++
    }

    override suspend fun quickSetup(initParams: String, setupParams: String): Result<String> {
        setupCalls++
        lastInitParams = initParams
        lastSetupParams = setupParams
        duringSetup?.invoke()
        return setupResult
    }

    override suspend fun startService(options: VpnOptions): Boolean {
        startCalls++
        lastStartOptions = options
        beforeStartService?.invoke()
        if (!startSucceeds) {
            return false
        }
        runtime = ServiceRuntime(vpn = runsAsVpn ?: options.enable, startedAtMillis = STARTED_AT)
        return true
    }

    override suspend fun stopService() {
        stopCalls++
        runtime = null
    }
}

@OptIn(ExperimentalCoroutinesApi::class)
class ServiceStateMachineTest {

    @Test
    fun `initParams spells the keys the Go wrapper expects`() {
        val json = ServiceStateMachine.initParams("/files", 34)

        assertEquals("""{"home-dir":"/files","version":34}""", json)
    }

    @Test
    fun `notification params come straight off the shared state`() {
        val params = ServiceStateMachine.notificationParams(
            SharedState(
                currentProfileName = "Work",
                stopText = "Disconnect",
                onlyStatisticsProxy = true,
            ),
        )

        assertEquals(NotificationParams("Work", "Disconnect", true), params)
    }

    @Test
    fun `notification params carry the stop action switch`() {
        val params = ServiceStateMachine.notificationParams(
            SharedState(showStopAction = false),
        )

        assertEquals(false, params.showStopAction)
    }

    @Test
    fun `the run time is reported only while a run is both requested and up`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        assertEquals(0L, machine.awaitRunTime())

        machine.requestStart().await()
        assertEquals(STARTED_AT, machine.awaitRunTime())

        machine.requestStop().await()
        assertEquals(0L, machine.awaitRunTime())
    }

    @Test
    fun `a stop request reads as STOPPING until the service is down`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()

        val stop = machine.requestStop()

        assertEquals(RunState.STOPPING, machine.runState.value)
        assertEquals(0L, machine.awaitRunTime())
        assertTrue(stop.await())
        assertEquals(RunState.STOPPED, machine.runState.value)
    }

    @Test
    fun `a start request drives the service to STARTED`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        assertTrue(machine.requestStart().await())
        assertEquals(RunState.STARTED, machine.runState.value)
        assertEquals(1, host.startCalls)
    }

    @Test
    fun `a start that the service refuses settles back to STOPPED`() = runTest {
        val host = FakeHost(backgroundScope)
        host.startSucceeds = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        assertFalse(machine.requestStart().await())
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertFalse(machine.isRunRequested)
        assertEquals(1, host.stoppedNotifications)
    }

    @Test
    fun `a start without stored vpn options never reaches the service`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        assertFalse(machine.requestStart().await())
        assertEquals(0, host.startCalls)
    }

    @Test
    fun `a denied notification permission cancels the start`() = runTest {
        val host = FakeHost(backgroundScope)
        host.app = FakeApp(notificationGranted = false)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        assertFalse(machine.requestStart().await())
        assertEquals(0, host.startCalls)
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertEquals(1, host.stoppedNotifications)
    }

    @Test
    fun `a start repeated on a settled run asks for nothing and keeps the service`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()
        val token = machine.captureRequestToken()
        val app = FakeApp(notificationGranted = false)
        host.app = app

        assertTrue(machine.requestStart().await())

        assertTrue(machine.captureRequestToken() === token)
        assertEquals(0, app.localNetworkRequests)
        assertEquals(1, host.startCalls)
        assertEquals(0, host.stopCalls)
        assertEquals(RunState.STARTED, machine.runState.value)
    }

    @Test
    fun `a start that changes the service kind is refused down to STOPPED`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(enable = false))
        machine.requestStart().await()
        machine.syncSharedState(configuredState(enable = true))
        host.app = FakeApp(vpnGranted = false)

        assertFalse(machine.requestStart().await())

        assertEquals(1, host.stopCalls)
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertFalse(machine.isRunRequested)
    }

    @Test
    fun `a denied vpn permission cancels the start`() = runTest {
        val host = FakeHost(backgroundScope)
        host.app = FakeApp(vpnGranted = false)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        assertFalse(machine.requestStart().await())
        assertEquals(0, host.startCalls)
        assertEquals(1, host.stoppedNotifications)
    }

    /** Flutter opened the Core's listeners before asking, and may be gone before it hears back. */
    @Test
    fun `a start refused before any service came up closes the core without passing STOPPING`() =
        runTest {
            val host = FakeHost(backgroundScope)
            host.app = FakeApp(vpnGranted = false)
            val machine = ServiceStateMachine(host)
            machine.syncSharedState(configuredState())
            val states = mutableListOf<RunState>()
            backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
                machine.runState.toList(states)
            }

            assertFalse(machine.requestStart().await())
            testScheduler.runCurrent()

            assertEquals(1, host.stopCalls)
            assertFalse(states.contains(RunState.STOPPING))
            assertEquals(RunState.STOPPED, machine.runState.value)
        }

    /**
     * Without a foreground app there is nobody to show the system consent dialog, so the machine
     * has to explain the refusal itself.
     */
    @Test
    fun `a missing vpn permission is reported when no app is attached`() = runTest {
        val host = FakeHost(backgroundScope)
        host.vpnPermissionGranted = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        assertFalse(machine.requestStart().await())
        assertTrue(host.toasts.contains(VPN_PERMISSION_MESSAGE))
    }

    @Test
    fun `a proxy-only start does not need the vpn permission`() = runTest {
        val host = FakeHost(backgroundScope)
        host.vpnPermissionGranted = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(enable = false))

        assertTrue(machine.requestStart().await())
        assertEquals(1, host.startCalls)
    }

    /** Android 17 drops the kernel hop system/mixed rely on until the permission is granted. */
    @Test
    fun `a denied local network permission falls back to the gvisor stack`() = runTest {
        val host = FakeHost(backgroundScope)
        host.localNetworkPermissionGranted = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(stack = "system"))

        assertTrue(machine.requestStart().await())
        assertEquals("gvisor", host.lastStartOptions?.stack)
        assertTrue(host.toasts.contains(configuredState().localNetworkTip))
    }

    @Test
    fun `a granted local network permission keeps the chosen stack`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(stack = "mixed"))

        assertTrue(machine.requestStart().await())
        assertEquals("mixed", host.lastStartOptions?.stack)
        assertFalse(host.toasts.contains(configuredState().localNetworkTip))
    }

    @Test
    fun `a proxy-only start keeps its stack without the local network permission`() = runTest {
        val host = FakeHost(backgroundScope)
        host.localNetworkPermissionGranted = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(enable = false, stack = "system"))

        assertTrue(machine.requestStart().await())
        assertEquals("system", host.lastStartOptions?.stack)
        assertFalse(host.toasts.contains(configuredState().localNetworkTip))
    }

    @Test
    fun `the local network prompt is asked once and never blocks the start`() = runTest {
        val host = FakeHost(backgroundScope)
        val app = FakeApp(localNetworkGranted = false)
        host.app = app
        host.localNetworkPermissionGranted = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(stack = "system"))

        assertTrue(machine.requestStart().await())
        assertEquals(1, app.localNetworkRequests)
        assertEquals(1, host.startCalls)
        assertEquals("gvisor", host.lastStartOptions?.stack)
    }

    @Test
    fun `a stop request drives the service to STOPPED`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()

        assertTrue(machine.requestStop().await())
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertEquals(1, host.stopCalls)
        assertEquals(0, host.stoppedNotifications)
    }

    @Test
    fun `stopping an already stopped service touches nothing`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        assertTrue(machine.requestStop().await())
        assertEquals(0, host.stopCalls)
    }

    @Test
    fun `a stop that lands mid-preparation keeps the service stopped`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        val app = FakeApp()
        host.app = app
        app.beforeVpnPrepared = { machine.requestStop() }

        assertFalse(machine.requestStart().await())
        assertEquals(0, host.startCalls)
        assertEquals(RunState.STOPPED, machine.runState.value)
    }

    @Test
    fun `a start reports failure when a stop overtakes the service call`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        host.beforeStartService = { machine.requestStop() }

        assertFalse(machine.requestStart().await())
        assertEquals(0, host.stoppedNotifications)
    }

    @Test
    fun `handleServiceLost clears the state for the token that observed the loss`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()

        val token = machine.captureRequestToken()
        host.runtime = null
        machine.handleServiceLost(token)

        assertEquals(RunState.STOPPED, machine.runState.value)
        assertFalse(machine.isRunRequested)
        assertEquals(1, host.stoppedNotifications)
    }

    /** The newer start still owns the intent, but nothing is running until it brings it up. */
    @Test
    fun `handleServiceLost keeps the intent of a start that raced ahead of it`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        val staleToken = machine.captureRequestToken()

        machine.requestStart().await()
        host.runtime = null
        machine.handleServiceLost(staleToken)

        assertTrue(machine.isRunRequested)
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertEquals(0, host.stoppedNotifications)
    }

    @Test
    fun `handleServiceLost ignores a service that is running again`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()

        machine.handleServiceLost(machine.captureRequestToken())

        assertEquals(RunState.STARTED, machine.runState.value)
    }

    @Test
    fun `handleStartAction hands the start to the tile when one is attached`() = runTest {
        val host = FakeHost(backgroundScope)
        val tile = FakeTile()
        host.tile = tile
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertEquals(1, tile.startCount)
        assertEquals(0, host.setupCalls)
    }

    @Test
    fun `handleStartAction is a no-op while a run is already requested`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()
        val startsBefore = host.startCalls

        machine.handleStartAction()

        assertEquals(startsBefore, host.startCalls)
        assertEquals(0, host.setupCalls)
    }

    @Test
    fun `handleStartAction reports a missing configuration`() = runTest {
        val host = FakeHost(backgroundScope)
        host.storedSharedState = SharedState()
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertEquals(listOf(MISSING_CONFIG_MESSAGE), host.toasts)
        assertEquals(0, host.setupCalls)
        assertFalse(machine.isRunRequested)
    }

    @Test
    fun `handleStartAction loads the stored configuration and sets the core up`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertEquals(1, host.setupCalls)
        assertEquals(1, host.startCalls)
        assertEquals(RunState.STARTED, machine.runState.value)
        assertEquals(
            ServiceStateMachine.initParams(host.homeDirPath, host.sdkInt),
            host.lastInitParams,
        )
        assertEquals(Gson().toJson(host.storedSharedState.setupParams), host.lastSetupParams)
    }

    @Test
    fun `a core that rejects the configuration reports its own message`() = runTest {
        val host = FakeHost(backgroundScope)
        host.setupResult = Result.success("proxy group not found")
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertTrue(host.toasts.contains("proxy group not found"))
        assertEquals(0, host.startCalls)
    }

    @Test
    fun `a core setup that throws without a message falls back to the generic one`() = runTest {
        val host = FakeHost(backgroundScope)
        host.setupResult = Result.failure(RuntimeException("   "))
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertTrue(host.toasts.contains(INVALID_CONFIG_MESSAGE))
        assertEquals(0, host.startCalls)
    }

    @Test
    fun `a service that refuses the start after a good setup is reported`() = runTest {
        val host = FakeHost(backgroundScope)
        host.startSucceeds = false
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertTrue(host.toasts.contains(START_FAILED_MESSAGE))
        assertFalse(machine.isRunRequested)
    }

    @Test
    fun `handleStopAction stops the service itself and reports it to Flutter`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()
        val tile = FakeTile()
        host.tile = tile

        machine.handleStopAction()

        assertEquals(0, tile.startCount)
        assertEquals(1, host.stopCalls)
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertEquals(1, host.stoppedNotifications)
    }

    @Test
    fun `a toggle during the native setup cancels the start without reporting a failure`() =
        runTest {
            val host = FakeHost(backgroundScope)
            val machine = ServiceStateMachine(host)
            host.duringSetup = { machine.handleToggleAction() }

            machine.handleStartAction()

            assertEquals(1, host.setupCalls)
            assertEquals(0, host.startCalls)
            assertFalse(host.toasts.contains(START_FAILED_MESSAGE))
            assertFalse(machine.isRunRequested)
            assertEquals(RunState.STOPPED, machine.runState.value)
        }

    /** The setup already opened the Core's ports, so a start that ends there has to close them. */
    @Test
    fun `a native start that does not end up running tears the core setup down`() = runTest {
        val cancelled = FakeHost(backgroundScope)
        val cancelledMachine = ServiceStateMachine(cancelled)
        cancelled.duringSetup = { cancelledMachine.handleToggleAction() }
        cancelledMachine.handleStartAction()

        val refused = FakeHost(backgroundScope)
        refused.vpnPermissionGranted = false
        ServiceStateMachine(refused).handleStartAction()

        val rejected = FakeHost(backgroundScope)
        rejected.setupResult = Result.success("proxy group not found")
        ServiceStateMachine(rejected).handleStartAction()

        assertEquals(listOf(1, 1, 1), listOf(cancelled, refused, rejected).map { it.stopCalls })
    }

    @Test
    fun `a native start that runs leaves the core setup alone`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        machine.handleStartAction()

        assertEquals(0, host.stopCalls)
        assertEquals(RunState.STARTED, machine.runState.value)
    }

    @Test
    fun `a second start action during the native setup is ignored`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        host.duringSetup = { machine.handleStartAction() }

        machine.handleStartAction()

        assertEquals(1, host.setupCalls)
        assertEquals(1, host.startCalls)
        assertEquals(RunState.STARTED, machine.runState.value)
    }

    @Test
    fun `handleStopAction is a no-op while nothing is running`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        machine.handleStopAction()

        assertEquals(0, host.stopCalls)
        assertTrue(host.toasts.isEmpty())
    }

    @Test
    fun `handleStopAction announces itself before stopping`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState().copy(stopTip = "Stopping..."))
        machine.requestStart().await()

        machine.handleStopAction()

        assertEquals(listOf("Stopping..."), host.toasts)
        assertEquals(1, host.stopCalls)
    }

    @Test
    fun `handleToggleAction starts when stopped and stops when started`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        machine.handleToggleAction()
        assertEquals(1, host.startCalls)

        machine.handleToggleAction()
        assertEquals(1, host.stopCalls)
    }

    @Test
    fun `a revoke is ignored while no vpn service is active`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState(enable = false))
        machine.requestStart().await()

        machine.handleVpnRevokeAction()

        assertEquals(0, host.stopCalls)
    }

    @Test
    fun `a revoke stops the vpn service even with Flutter attached`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()
        host.tile = FakeTile()

        machine.handleVpnRevokeAction()

        assertEquals(1, host.stopCalls)
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertEquals(1, host.stoppedNotifications)
    }

    @Test
    fun `a revoke stops the active vpn service`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        machine.requestStart().await()

        machine.handleVpnRevokeAction()

        assertEquals(1, host.stopCalls)
    }

    @Test
    fun `syncSharedState pushes crashlytics and the notification straight through`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)

        machine.syncSharedState(
            SharedState(
                crashlytics = false,
                currentProfileName = "Work",
                stopText = "Disconnect",
                onlyStatisticsProxy = true,
            ),
        )

        assertEquals(listOf(false), host.crashlytics)
        assertEquals(listOf(NotificationParams("Work", "Disconnect", true)), host.notificationParams)
    }

    @Test
    fun `a start that a stop overtakes never announces STARTED`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        val states = mutableListOf<RunState>()
        backgroundScope.launch(UnconfinedTestDispatcher(testScheduler)) {
            machine.runState.toList(states)
        }
        host.beforeStartService = { machine.requestStop() }

        assertFalse(machine.requestStart().await())
        testScheduler.runCurrent()

        assertFalse(states.contains(RunState.STARTED))
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertEquals(null, host.runtime)
    }

    @Test
    fun `a start rolled back after the service came up stops it again`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        host.beforeStartService = {
            host.app = FakeApp(vpnGranted = false)
            machine.requestStart()
        }

        assertFalse(machine.requestStart().await())
        testScheduler.runCurrent()

        assertEquals(1, host.stopCalls)
        assertEquals(null, host.runtime)
        assertEquals(RunState.STOPPED, machine.runState.value)
        assertFalse(machine.captureRequestToken().running)
    }

    @Test
    fun `a start that overtakes another inside the binding window adopts the running service`() =
        runTest {
            val host = FakeHost(backgroundScope)
            val machine = ServiceStateMachine(host)
            machine.syncSharedState(configuredState())
            host.beforeStartService = {
                host.beforeStartService = null
                machine.requestStart()
            }

            machine.requestStart().await()
            testScheduler.runCurrent()

            assertEquals(1, host.startCalls)
            assertEquals(0, host.stopCalls)
            assertEquals(RunState.STARTED, machine.runState.value)
            assertTrue(machine.captureRequestToken().running)
        }

    @Test
    fun `a start rebinds when the running service is not the one the options ask for`() = runTest {
        val host = FakeHost(backgroundScope)
        host.runsAsVpn = false
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        host.beforeStartService = {
            host.beforeStartService = null
            machine.requestStart()
        }

        machine.requestStart().await()
        testScheduler.runCurrent()

        assertEquals(2, host.startCalls)
        assertEquals(RunState.STARTED, machine.runState.value)
    }

    @Test
    fun `a stop releases a start that is waiting on the vpn consent`() = runTest {
        val host = FakeHost(backgroundScope)
        val app = FakeApp(holdVpnPreparation = true)
        host.app = app
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())

        val start = machine.requestStart()
        testScheduler.runCurrent()
        assertEquals(0, host.startCalls)

        assertTrue(machine.requestStop().await())
        assertFalse(start.await())
        assertEquals(0, host.startCalls)
        assertEquals(1, app.cancelledPreparations)
        assertEquals(RunState.STOPPED, machine.runState.value)
    }

    @Test
    fun `a start request that throws is logged and rolled back`() = runTest {
        val host = FakeHost(backgroundScope)
        val machine = ServiceStateMachine(host)
        machine.syncSharedState(configuredState())
        host.beforeStartService = { throw IllegalStateException("binder died") }

        assertFalse(machine.requestStart().await())
        assertTrue(host.logs.any { it.contains("binder died") })
        assertFalse(machine.captureRequestToken().running)
        assertEquals(RunState.STOPPED, machine.runState.value)
    }
}
