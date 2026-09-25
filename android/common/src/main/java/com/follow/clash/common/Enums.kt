package com.follow.clash.common

import com.google.gson.annotations.SerializedName

enum class QuickAction {
    STOP,
    START,
    TOGGLE,
    MODE_RULE,
    MODE_GLOBAL,
    MODE_DIRECT,
}

/**
 * Outbound-mode quick actions carry a mode string; their shortcut id is the
 * lowercase mode name ("rule"/"global"/"direct") so reportShortcutUsed and
 * the Dart-side handler share one vocabulary.
 */
val QuickAction.mode: String?
    get() = when (this) {
        QuickAction.MODE_RULE -> "rule"
        QuickAction.MODE_GLOBAL -> "global"
        QuickAction.MODE_DIRECT -> "direct"
        else -> null
    }

enum class BroadcastAction {
    VPN_START_REQUESTED,
    VPN_REVOKED,
}

enum class AccessControlMode {
    @SerializedName("acceptSelected")
    ACCEPT_SELECTED,

    @SerializedName("rejectSelected")
    REJECT_SELECTED,
}
