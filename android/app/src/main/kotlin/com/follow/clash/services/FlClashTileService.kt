package com.follow.clash.services

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import androidx.lifecycle.Observer
import com.follow.clash.GlobalState
import com.follow.clash.RunState
import com.follow.clash.TempActivity
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.ProxyPlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor


class FlClashTileService : TileService() {

    private val observer = Observer<RunState> { runState ->
        updateTile(runState)
    }

    private fun updateTile(runState: RunState) {
        if (qsTile != null) {
            qsTile.state = when (runState) {
                RunState.START -> Tile.STATE_ACTIVE
                RunState.PENDING -> Tile.STATE_UNAVAILABLE
                RunState.STOP -> Tile.STATE_INACTIVE
            }
            qsTile.updateTile()
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        GlobalState.runState.value?.let { updateTile(it) }
        GlobalState.runState.observeForever(observer)
    }

    private fun activityTransfer() {
        val intent = Intent(this, TempActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
        val pendingIntent = if (Build.VERSION.SDK_INT >= 31) {
            PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        } else {
            PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(pendingIntent)
        }else{
            startActivityAndCollapse(intent)
        }
    }

    private var flutterEngine: FlutterEngine? = null;

    private fun initFlutterEngine() {
        flutterEngine = FlutterEngine(this)
        flutterEngine?.plugins?.add(ProxyPlugin())
        flutterEngine?.plugins?.add(TilePlugin())
        flutterEngine?.plugins?.add(AppPlugin())
        GlobalState.flutterEngine = flutterEngine
        if (flutterEngine?.dartExecutor?.isExecutingDart != true) {
            val vpnService = DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "vpnService"
            )
            flutterEngine?.dartExecutor?.executeDartEntrypoint(vpnService)
        }
    }

    override fun onClick() {
        super.onClick()
        activityTransfer()
        val currentTilePlugin = GlobalState.getCurrentTilePlugin()
        if (GlobalState.runState.value == RunState.STOP) {
            GlobalState.runState.value = RunState.PENDING
            if(currentTilePlugin == null){
                initFlutterEngine()
            }else{
                currentTilePlugin.handleStart()
            }
        } else if(GlobalState.runState.value == RunState.START){
            GlobalState.runState.value = RunState.PENDING
            currentTilePlugin?.handleStop()
        }

    }

    override fun onDestroy() {
        GlobalState.runState.removeObserver(observer)
        super.onDestroy()
    }
}