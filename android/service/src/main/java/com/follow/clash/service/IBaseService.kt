package com.follow.clash.service

import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.sendBroadcast

interface IBaseService {
    fun handleCreate() {
        if (!State.inApp) {
            BroadcastAction.START.sendBroadcast()
        } else {
            State.inApp = false
        }
    }

    fun start()

    fun stop()
}