package com.follow.clash.remote

import android.app.Service
import android.content.Intent
import android.os.IBinder

class RemoteService : Service() {
    private val binder: ICoreInterface.Stub = object : ICoreInterface.Stub() {
        override fun invokeAction(data: String?, callback: ICallbackInterface?) {
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
}