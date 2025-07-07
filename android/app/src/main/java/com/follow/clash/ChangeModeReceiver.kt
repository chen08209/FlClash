package com.follow.clash

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.follow.clash.extensions.wrapAction

class ChangeModeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val appContext = FlClashApplication.getAppContext()
        when (intent.action) {
            appContext.wrapAction("CHANGE_MODE") -> {
                val mode = intent.getStringExtra("mode")
                if (mode != null) {
                    GlobalState.handleChangeMode(mode)
                }
            }
        }
    }
}