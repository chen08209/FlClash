package com.follow.clash.service.models

import com.follow.clash.common.AccessControlMode
import com.google.gson.Gson
import java.net.Inet4Address
import java.net.Inet6Address
import java.net.InetAddress

data class AccessControlProps(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
)

data class VpnOptions(
    val enable: Boolean,
    val port: Int,
    val ipv6: Boolean,
    val dnsHijacking: Boolean,
    val accessControlProps: AccessControlProps,
    val allowBypass: Boolean,
    val systemProxy: Boolean,
    val bypassDomain: List<String>,
    val stack: String,
    val routeAddress: List<String>,
    val mtu: Int = 0,
    val congestionController: String? = null,
)

private const val DEFAULT_TUN_MTU = 9000

// establish() rejects an MTU above 65535, and below 1280 the kernel drops the
// IPv6 address.
private val TUN_MTU_RANGE = 1280..65535

private val gson = Gson()

val VpnOptions.tunMtu: Int
    get() = if (mtu > 0) mtu.coerceIn(TUN_MTU_RANGE) else DEFAULT_TUN_MTU

val VpnOptions.tunOptions: String
    get() = gson.toJson(
        mapOf(
            "mtu" to tunMtu,
            "congestion-controller" to congestionController.orEmpty(),
        ),
    )

data class CIDR(
    val address: InetAddress,
    val prefixLength: Int,
)

fun VpnOptions.getIpv4RouteAddress(): List<CIDR> = routeAddress
    .map(String::toCIDR)
    .filter { it.address is Inet4Address }

fun VpnOptions.getIpv6RouteAddress(): List<CIDR> = routeAddress
    .map(String::toCIDR)
    .filter { it.address is Inet6Address }

fun String.toCIDR(): CIDR {
    val parts = split("/")
    require(parts.size == 2) { "Invalid CIDR format: $this" }
    val ipAddress = parts[0]
    val prefixLength = parts[1].toIntOrNull()
        ?: throw IllegalArgumentException("Invalid prefix length: ${parts[1]}")

    val address = InetAddress.getByName(ipAddress)
    val maxPrefix = if (address.address.size == 4) 32 else 128
    require(prefixLength in 0..maxPrefix) {
        "Invalid prefix length $prefixLength for $ipAddress"
    }

    return CIDR(address, prefixLength)
}
