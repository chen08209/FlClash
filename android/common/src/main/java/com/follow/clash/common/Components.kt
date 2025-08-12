package com.follow.clash.common

import android.content.ComponentName

object Components {
    const val PACKAGE_NAME = "com.follow.clash"

    val MAIN_ACTIVITY =
        ComponentName(PACKAGE_NAME, "${GlobalState.application.packageName}.MainActivity")

    val TEMP_ACTIVITY =
        ComponentName(PACKAGE_NAME, "${GlobalState.application.packageName}.TempActivity")
}