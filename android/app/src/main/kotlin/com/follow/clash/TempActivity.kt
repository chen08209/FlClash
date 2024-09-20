package com.follow.clash

import android.app.Activity
import android.os.Bundle

class TempActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        when (intent.action) {
            "com.follow.clash.action.START" -> {
                GlobalState.getCurrentTilePlugin()?.handleStart()
            }

            "com.follow.clash.action.STOP" -> {
                GlobalState.getCurrentTilePlugin()?.handleStop()
            }
        }
        finishAndRemoveTask()
    }
}