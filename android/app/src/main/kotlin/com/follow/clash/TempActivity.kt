package com.follow.clash

import android.app.Activity
import android.os.Bundle
import com.follow.clash.common.QuickAction
import com.follow.clash.common.value

class TempActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.action) {
            QuickAction.START.value -> {
//                GlobalState.handleStart()
            }

            QuickAction.STOP.value -> {
//                GlobalState.handleStop()
            }

            QuickAction.TOGGLE.value -> {
//                GlobalState.handleToggle()
            }
        }
        finish()
    }
}