package com.follow.clash.service

import android.app.Service
import com.follow.clash.common.BroadcastAction
import com.follow.clash.common.GlobalState
import com.follow.clash.common.sendBroadcast

interface ManagedService {
    fun start()

    fun stop()
}

internal fun Service.notifyCreated() {
    GlobalState.log("Service created")
    BroadcastAction.SERVICE_CREATED.sendBroadcast()
}

internal fun Service.notifyDestroyed() {
    GlobalState.log("Service destroyed")
    BroadcastAction.SERVICE_DESTROYED.sendBroadcast()
}
