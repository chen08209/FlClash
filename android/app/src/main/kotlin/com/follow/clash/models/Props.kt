package com.follow.clash.models

import java.net.InetAddress

enum class AccessControlMode {
    acceptSelected, rejectSelected,
}

data class AccessControl(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
)

data class CIDR(val address: InetAddress, val prefixLength: Int)

data class VpnOptions(
    val enable: Boolean,
    val port: Int,
    val accessControl: AccessControl,
    val allowBypass: Boolean,
    val systemProxy: Boolean,
    val bypassDomain: List<String>,
    val routeAddress: List<String>,
    val ipv4Address: String,
    val ipv6Address: String,
    val dnsServerAddress: String,
)

data class StartForegroundParams(
    val title: String,
    val content: String,
)