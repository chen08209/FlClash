package com.follow.clash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.BroadcastLease
import com.follow.clash.common.GlobalState
import com.follow.clash.common.action
import kotlinx.coroutines.launch

class ServiceBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action ?: return
        val pendingResult = goAsync()
        val lease = BroadcastLease { pendingResult.finish() }
        val timeout = Runnable {
            lease.release { GlobalState.log("Broadcast handling timed out: $action") }
        }
        mainHandler.postDelayed(timeout, BROADCAST_TIMEOUT_MILLIS)
        GlobalState.launch {
            try {
                handleAction(action)
            } catch (error: Exception) {
                GlobalState.log("Unable to handle service broadcast $action: $error")
            } finally {
                mainHandler.removeCallbacks(timeout)
                lease.release()
            }
        }
    }

    private suspend fun handleAction(action: String) {
        when (action) {
            BroadcastAction.VPN_START_REQUESTED.action -> {
                GlobalState.log("System requested VPN service start")
                ServiceState.handleStartAction()
            }

            BroadcastAction.VPN_REVOKED.action -> {
                GlobalState.log("VPN permission revoked")
                ServiceState.handleVpnRevokeAction()
            }
        }
    }

    companion object {
        private const val BROADCAST_TIMEOUT_MILLIS = 9_000L
        private val mainHandler = Handler(Looper.getMainLooper())
    }
}
