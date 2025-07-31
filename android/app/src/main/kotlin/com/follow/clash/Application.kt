package com.follow.clash

import android.app.Application
import android.content.Context
import com.follow.clash.common.GlobalState
import com.follow.clash.common.processName
import com.google.firebase.FirebaseApp
import com.google.firebase.crashlytics.FirebaseCrashlytics

class Application : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }

    override fun onCreate() {
        super.onCreate()
        initRemoteCrashlytics(this)
    }

    private fun initRemoteCrashlytics(context: Context) {
        try {
            if (processName?.endsWith(":remote") == true) {
                FirebaseApp.initializeApp(context)
                FirebaseCrashlytics.getInstance().isCrashlyticsCollectionEnabled = true
                GlobalState.log("init remote crashlytics")
            }
        } catch (e: Exception) {
            GlobalState.log("initRemoteCrashlytics error: $e")
        }
    }
}
