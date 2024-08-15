package com.follow.clash

import android.content.Context
import androidx.lifecycle.MutableLiveData
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.ServicePlugin
import com.follow.clash.plugins.VpnPlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

enum class RunState {
    START,
    PENDING,
    STOP
}


object GlobalState {

    private val lock = ReentrantLock()
    val runLock = ReentrantLock()

    val runState: MutableLiveData<RunState> = MutableLiveData<RunState>(RunState.STOP)
    var flutterEngine: FlutterEngine? = null
    private var serviceEngine: FlutterEngine? = null

    fun getCurrentAppPlugin(): AppPlugin? {
        val currentEngine = if (flutterEngine != null) flutterEngine else serviceEngine
        return currentEngine?.plugins?.get(AppPlugin::class.java) as AppPlugin?
    }

    fun getCurrentTitlePlugin(): TilePlugin? {
        val currentEngine = if (flutterEngine != null) flutterEngine else serviceEngine
        return currentEngine?.plugins?.get(TilePlugin::class.java) as TilePlugin?
    }

    fun getCurrentVPNPlugin(): VpnPlugin? {
        val currentEngine = if (serviceEngine != null) serviceEngine else flutterEngine
        return currentEngine?.plugins?.get(VpnPlugin::class.java) as VpnPlugin?
    }

    fun destroyServiceEngine() {
        serviceEngine?.destroy()
        serviceEngine = null
    }

    fun initServiceEngine(context: Context) {
        if (serviceEngine != null) return
        lock.withLock {
            destroyServiceEngine()
            serviceEngine = FlutterEngine(context)
            serviceEngine?.plugins?.add(VpnPlugin())
            serviceEngine?.plugins?.add(AppPlugin())
            serviceEngine?.plugins?.add(TilePlugin())
            serviceEngine?.plugins?.add(ServicePlugin())
            val vpnService = DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "vpnService"
            )
            serviceEngine?.dartExecutor?.executeDartEntrypoint(
                vpnService,
            )
        }
    }
}


