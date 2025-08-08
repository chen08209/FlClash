package com.follow.clash

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import com.follow.clash.common.Components
import com.follow.clash.common.toPendingIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

@RequiresApi(Build.VERSION_CODES.N)
class TileService : TileService() {
    private var scope: CoroutineScope? = null
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
        scope?.cancel()
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        scope?.launch {
            AppState.runStateFlow.collect {
                updateTile(it)
            }
        }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun activityTransfer() {
        val intent = Intent().setComponent(Components.TEMP_ACTIVITY)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
        val pendingIntent = intent.toPendingIntent
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(pendingIntent)
        } else {
            startActivityAndCollapse(intent)
        }
    }

    override fun onClick() {
        super.onClick()
        activityTransfer()
        AppState.handleToggle()
    }

    override fun onStopListening() {
        scope?.cancel()
        super.onStopListening()
    }
}