package com.follow.clash

import android.app.Activity
import android.os.Bundle
import androidx.core.content.pm.ShortcutManagerCompat
import com.follow.clash.common.GlobalState
import com.follow.clash.common.QuickAction
import com.follow.clash.common.action
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class QuickActionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GlobalState.launch {
            try {
                when (intent.action) {
                    QuickAction.START.action -> ServiceState.handleStartAction()
                    QuickAction.STOP.action -> ServiceState.handleStopAction()
                    QuickAction.TOGGLE.action -> {
                        ShortcutManagerCompat.reportShortcutUsed(this@QuickActionActivity, SHORTCUT_ID)
                        ServiceState.handleToggleAction()
                    }
                }
            } finally {
                withContext(Dispatchers.Main) {
                    finish()
                }
            }
        }
    }

    private companion object {
        const val SHORTCUT_ID = "toggle"
    }
}
