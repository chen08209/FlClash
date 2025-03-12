package com.follow.clash;

import android.app.Application
import android.content.Context

class FlClashApplication : Application() {
    companion object {
        private lateinit var instance: FlClashApplication
        fun getAppContext(): Context {
            return instance.applicationContext
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
    }
}
