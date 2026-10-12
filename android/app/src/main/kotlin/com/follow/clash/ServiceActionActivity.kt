package com.follow.clash

import android.app.Activity
import android.os.Bundle
import androidx.core.content.pm.ShortcutManagerCompat
import com.follow.clash.common.GlobalState
import com.follow.clash.common.QuickAction
import com.follow.clash.common.action
import kotlinx.coroutines.launch

class ServiceActionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.action) {
            QuickAction.START.action -> {
                ShortcutManagerCompat.reportShortcutUsed(this, "start")
                GlobalState.launch { ServiceState.handleStartAction() }
            }
            QuickAction.STOP.action -> {
                ShortcutManagerCompat.reportShortcutUsed(this, "stop")
                GlobalState.launch { ServiceState.handleStopAction() }
            }
        }
        finish()
    }
}
