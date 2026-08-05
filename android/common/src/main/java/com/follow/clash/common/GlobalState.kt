package com.follow.clash.common

import android.app.Application
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.crashlytics.FirebaseCrashlytics
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

object GlobalState : CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    const val NOTIFICATION_CHANNEL = "FlClash"
    const val NOTIFICATION_ID = 1

    val packageName: String
        get() = application.packageName

    val receiveBroadcastPermission: String
        get() = "$packageName.permission.RECEIVE_BROADCASTS"

    val application: Application
        get() = checkNotNull(appInstance) { "GlobalState is not initialized" }

    @Volatile
    private var appInstance: Application? = null

    fun init(application: Application) {
        appInstance = application
    }

    fun log(text: String) {
        Log.d("FlClash", text)
    }

    fun setCrashlytics(enable: Boolean) {
        FirebaseApp.initializeApp(application)
        FirebaseCrashlytics.getInstance().isCrashlyticsCollectionEnabled = enable
        if (enable) {
            log("Crashlytics enabled for ${application.processName}")
        }
    }

    fun didCrashOnPreviousExecution(): Boolean {
        FirebaseApp.initializeApp(application)
        return FirebaseCrashlytics.getInstance().didCrashOnPreviousExecution()
    }
}
