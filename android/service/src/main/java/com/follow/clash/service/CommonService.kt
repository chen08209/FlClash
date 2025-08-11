package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import com.follow.clash.common.QuickAction
import com.follow.clash.common.quickIntent
import com.follow.clash.common.toPendingIntent
import com.follow.clash.core.Core

class CommonService : Service() {

    override fun onCreate() {
        super.onCreate()
        QuickAction.START.quickIntent.toPendingIntent.send()
    }

    override fun onLowMemory() {
        Core.forceGC()
        super.onLowMemory()
    }
    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): CommonService = this@CommonService
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }
}