package com.follow.clash

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.core.content.pm.ShortcutManagerCompat
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import com.follow.clash.common.QuickAction
import com.follow.clash.common.action
import com.follow.clash.common.intent
import com.follow.clash.common.mode
import com.follow.clash.plugins.AppPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Transparent executor for external automation (Samsung Modes and Routines,
 * Tasker app shortcuts, or broadcasts relayed by ChangeModeReceiver): performs
 * start/stop/toggle, outbound-mode switch and profile selection without ever
 * showing UI. finish() runs immediately after dispatching the request.
 */
class QuickActionActivity : Activity() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (val quickAction = QuickAction.entries.firstOrNull { it.action == intent.action }) {
            QuickAction.START -> scope.launch { ServiceState.handleStartAction() }
            QuickAction.STOP -> scope.launch { ServiceState.handleStopAction() }
            QuickAction.TOGGLE -> {
                ShortcutManagerCompat.reportShortcutUsed(this@QuickActionActivity, TOGGLE_SHORTCUT_ID)
                scope.launch { ServiceState.handleToggleAction() }
            }
            QuickAction.MODE_RULE,
            QuickAction.MODE_GLOBAL,
            QuickAction.MODE_DIRECT -> {
                val mode = quickAction?.mode ?: return finish()
                ShortcutManagerCompat.reportShortcutUsed(this@QuickActionActivity, mode)
                if (!AppPlugin.changeMode(mode)) {
                    // No live Flutter engine (app fully dead): park the request
                    // and cold-start MainActivity, which replays it once Dart is up.
                    ModeRequest.pending = mode
                    startActivity(
                        Components.mainActivity.intent.apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        },
                    )
                }
            }
            null -> Unit
        }
        if (intent.action == actionSelectProfile) {
            val id = intent.getLongExtra(EXTRA_PROFILE_ID, -1L)
            if (id >= 0 && !AppPlugin.selectProfile(id)) {
                ModeRequest.pendingProfileId = id
                startActivity(
                    Components.mainActivity.intent.apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    },
                )
            }
        }
        finish()
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    internal companion object {
        const val TOGGLE_SHORTCUT_ID = "toggle"

        /**
         * The select-profile action must match what AppPlugin stamps onto the
         * dynamic shortcut intents, which builds it dynamically from the runtime
         * applicationId (see Ext.kt QuickAction.action). A hardcoded literal here
         * silently breaks profile selection on every non-default package variant
         * (.dev/.debug/.cn) — never inline this string.
         */
        val actionSelectProfile: String
            get() = "${GlobalState.application.packageName}.action.SELECT_PROFILE"
        const val EXTRA_PROFILE_ID = "profile_id"
    }
}
