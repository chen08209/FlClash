package com.follow.clash.models


data class AppState(
    val crashlytics: Boolean = true,
    val currentProfileName: String = "FlClash",
    val stopText: String = "Stop",
    val onlyStatisticsProxy: Boolean = false,
)
