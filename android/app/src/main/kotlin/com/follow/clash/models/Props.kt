package com.follow.clash.models

enum class AccessControlMode {
    acceptSelected,
    rejectSelected,
}

data class AccessControl(
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
)

data class Props (
    val accessControl: AccessControl?,
    val allowBypass: Boolean?,
)
