package com.follow.clash

import android.net.VpnService
import com.follow.clash.common.GlobalState
import com.follow.clash.models.SharedState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import com.follow.clash.service.ServiceConfig
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CoroutineScope

/**
 * Everything [ServiceStateMachine] needs from the Android runtime.
 *
 * The machine owns the arbitration and the transitions; this is only the part that cannot run on a
 * plain JVM, so unit tests can drive the state machine with an in-memory implementation.
 */
internal interface ServiceStateHost {
    val scope: CoroutineScope
    val runTimeMillis: Long
    val homeDirPath: String
    val sdkInt: Int

    fun log(message: String)

    fun showToast(message: String)

    fun setCrashlytics(enabled: Boolean)

    fun updateNotificationParams(params: NotificationParams)

    fun loadSharedState(): SharedState

    fun isVpnPermissionGranted(): Boolean

    fun tile(): TileGateway?

    fun app(): AppGateway?

    suspend fun quickSetup(initParams: String, setupParams: String): Result<String>

    suspend fun startService(options: VpnOptions): Long

    suspend fun stopService()

    suspend fun isVpnServiceActive(): Boolean
}

/** The Quick Settings tile surface, backed by [TilePlugin] in production. */
internal interface TileGateway {
    fun handleStart()

    fun handleStop()
}

/** The foreground-app surface, backed by [AppPlugin] in production. */
internal interface AppGateway {
    fun requestNotificationPermission(callback: (Boolean) -> Unit)

    fun prepareVpn(enable: Boolean, callback: (Boolean) -> Unit)

    fun cancelVpnPreparation(callback: (Boolean) -> Unit)
}

internal object AndroidServiceStateHost : ServiceStateHost {
    @Volatile
    private var flutterEngine: FlutterEngine? = null

    override val scope: CoroutineScope
        get() = GlobalState

    override val runTimeMillis: Long
        get() = ServiceController.getRunTimeMillis()

    override val homeDirPath: String
        get() = GlobalState.application.filesDir.path

    override val sdkInt: Int
        get() = android.os.Build.VERSION.SDK_INT

    fun attachFlutterEngine(engine: FlutterEngine) {
        flutterEngine = engine
    }

    fun detachFlutterEngine(engine: FlutterEngine) {
        if (flutterEngine === engine) {
            flutterEngine = null
        }
    }

    override fun log(message: String) = GlobalState.log(message)

    override fun showToast(message: String) = GlobalState.application.showToast(message)

    override fun setCrashlytics(enabled: Boolean) = GlobalState.setCrashlytics(enabled)

    override fun updateNotificationParams(params: NotificationParams) =
        ServiceConfig.updateNotificationParams(params)

    override fun loadSharedState(): SharedState = GlobalState.application.sharedState

    override fun isVpnPermissionGranted(): Boolean =
        VpnService.prepare(GlobalState.application) == null

    override fun tile(): TileGateway? = flutterEngine?.plugin<TilePlugin>()?.let { plugin ->
        object : TileGateway {
            override fun handleStart() = plugin.handleStart()

            override fun handleStop() = plugin.handleStop()
        }
    }

    override fun app(): AppGateway? = flutterEngine?.plugin<AppPlugin>()?.let { plugin ->
        object : AppGateway {
            override fun requestNotificationPermission(callback: (Boolean) -> Unit) =
                plugin.requestNotificationPermission(callback)

            override fun prepareVpn(enable: Boolean, callback: (Boolean) -> Unit) =
                plugin.prepareVpn(enable, callback)

            override fun cancelVpnPreparation(callback: (Boolean) -> Unit) =
                plugin.cancelVpnPreparation(callback)
        }
    }

    override suspend fun quickSetup(initParams: String, setupParams: String): Result<String> =
        ServiceController.quickSetup(initParams, setupParams)

    override suspend fun startService(options: VpnOptions): Long =
        ServiceController.start(options)

    override suspend fun stopService() = ServiceController.stop()

    override suspend fun isVpnServiceActive(): Boolean = ServiceController.isVpnServiceActive()
}
