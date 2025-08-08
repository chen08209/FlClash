package com.follow.clash.common

import android.Manifest
import android.app.Application
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

object GlobalState {

    const val NOTIFICATION_CHANNEL = "FlClash"

    const val NOTIFICATION_ID = 1

    val application: Application
        get() = _application

    private lateinit var _application: Application

    fun init(application: Application) {
        _application = application
    }
}