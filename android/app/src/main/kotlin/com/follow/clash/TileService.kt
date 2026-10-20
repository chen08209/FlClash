package com.follow.clash

import android.service.quicksettings.Tile
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class TileService : android.service.quicksettings.TileService() {
    private var scope: CoroutineScope? = null

    override fun onStartListening() {
        super.onStartListening()
        scope?.cancel()
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate).also { scope ->
            scope.launch {
                ServiceState.runState.collect(::updateTile)
            }
        }
    }

    // Toggling used to go through an activity (startActivityAndCollapse), which
    // collapsed the shade and brought the app forward on every tap. The tile is
    // just another owner of the same intent, so it drives the service in place.
    override fun onClick() {
        super.onClick()
        val current =
            scope ?: CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate).also { scope = it }
        current.launch { ServiceState.handleToggleAction() }
    }

    override fun onStopListening() {
        scope?.cancel()
        scope = null
        super.onStopListening()
    }

    private fun updateTile(runState: RunState) {
        qsTile?.apply {
            state = when (runState) {
                RunState.STARTED -> Tile.STATE_ACTIVE
                RunState.STARTING, RunState.STOPPING -> Tile.STATE_UNAVAILABLE
                RunState.STOPPED -> Tile.STATE_INACTIVE
            }
            updateTile()
        }
    }
}
