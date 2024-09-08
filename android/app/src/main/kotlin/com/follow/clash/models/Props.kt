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

data class Props(
    val enable: Boolean?,
    val accessControl: AccessControl?,
    val allowBypass: Boolean?,
    val systemProxy: Boolean?,
)

data class TunProps(
    val fd: Int,
    val gateway: String,
    val gateway6: String,
    val portal: String,
    val portal6: String,
    val dns: String,
    val dns6: String
)