package com.follow.clash.service.models

import android.os.Parcelable
import com.follow.clash.common.AccessControlMode
import kotlinx.parcelize.Parcelize
import java.net.InetAddress

@Parcelize
data class AccessControl(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
) : Parcelable

@Parcelize
data class VpnOptions(
    val enable: Boolean,
    val port: Int,
    val ipv6: Boolean,
    val dnsHijacking: Boolean,
    val accessControl: AccessControl,
    val allowBypass: Boolean,
    val systemProxy: Boolean,
    val bypassDomain: List<String>,
    val stack: String,
    val routeAddress: List<String>,
) : Parcelable

data class CIDR(val address: InetAddress, val prefixLength: Int)

fun VpnOptions.getIpv4RouteAddress(): List<CIDR> {
    return routeAddress.filter {
        it.isIpv4()
    }.map {
        it.toCIDR()
    }
}

fun VpnOptions.getIpv6RouteAddress(): List<CIDR> {
    return routeAddress.filter {
        it.isIpv6()
    }.map {
        it.toCIDR()
    }
}

fun String.isIpv4(): Boolean {
    val parts = split("/")
    if (parts.size != 2) {
        throw IllegalArgumentException("Invalid CIDR format")
    }
    val address = InetAddress.getByName(parts[0])
    return address.address.size == 4
}

fun String.isIpv6(): Boolean {
    val parts = split("/")
    if (parts.size != 2) {
        throw IllegalArgumentException("Invalid CIDR format")
    }
    val address = InetAddress.getByName(parts[0])
    return address.address.size == 16
}

fun String.toCIDR(): CIDR {
    val parts = split("/")
    if (parts.size != 2) {
        throw IllegalArgumentException("Invalid CIDR format")
    }
    val ipAddress = parts[0]
    val prefixLength =
        parts[1].toIntOrNull() ?: throw IllegalArgumentException("Invalid prefix length")

    val address = InetAddress.getByName(ipAddress)

    val maxPrefix = if (address.address.size == 4) 32 else 128
    if (prefixLength < 0 || prefixLength > maxPrefix) {
        throw IllegalArgumentException("Invalid prefix length for IP version")
    }

    return CIDR(address, prefixLength)
}