package com.follow.clash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.action
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class BroadcastReceiver : BroadcastReceiver(),
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            BroadcastAction.CREATE_VPN.action -> {
                launch {
                    State.handleStartServiceAction()
                }
            }
        }
    }
}