package com.follow.clash.common

import com.google.gson.annotations.SerializedName


enum class QuickAction {
    STOP,
    START,
    TOGGLE,
}

enum class BroadcastAction {
    START,
    STOP,
    TOGGLE,
}

enum class AccessControlMode {
    @SerializedName("acceptSelected")
    ACCEPT_SELECTED,

    @SerializedName("rejectSelected")
    REJECT_SELECTED,
}