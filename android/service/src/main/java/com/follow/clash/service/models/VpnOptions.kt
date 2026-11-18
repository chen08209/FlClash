package com.follow.clash.service.models

import com.follow.clash.common.AccessControlMode
import com.google.gson.Gson
import java.math.BigInteger
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
    val ipv4Address: String? = null,
    val ipv6Address: String? = null,
)

const val DEFAULT_TUN_IPV4_ADDRESS = "198.18.0.1/30"
const val DEFAULT_TUN_IPV6_ADDRESS = "fdfe:dcba:9876::1/126"
internal const val NET_ANY = "0.0.0.0"
internal const val NET_ANY6 = "::"

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

val VpnOptions.tunIpv4Cidr: CIDR
    get() = ipv4Address.toTunCidrOrDefault(DEFAULT_TUN_IPV4_ADDRESS, isIpv6 = false)

val VpnOptions.tunIpv6Cidr: CIDR
    get() = ipv6Address.toTunCidrOrDefault(DEFAULT_TUN_IPV6_ADDRESS, isIpv6 = true)

val VpnOptions.tunAddress: String
    get() = buildString {
        append(tunIpv4Cidr.cidrString)
        if (ipv6) {
            append(",")
            append(tunIpv6Cidr.cidrString)
        }
    }

val VpnOptions.tunDns: String
    get() {
        if (dnsHijacking) {
            return NET_ANY
        }
        return buildString {
            append(tunIpv4Cidr.peerAddress)
            if (ipv6) {
                append(",")
                append(tunIpv6Cidr.peerAddress)
            }
        }
    }

data class CIDR(
    val address: InetAddress,
    val prefixLength: Int,
) {
    val cidrString: String
        get() = "${address.hostAddress}/$prefixLength"

    val peerInetAddress: InetAddress
        get() {
            val bytes = address.address.clone()
            val last = bytes.lastIndex
            val value = bytes[last].toInt() and 0xFF
            bytes[last] = when (value and 3) {
                1 -> value + 1
                2 -> value - 1
                else -> value xor 1
            }.toByte()
            return InetAddress.getByAddress(bytes)
        }

    val peerAddress: String
        get() = peerInetAddress.hostAddress.orEmpty()
}

private fun String?.toTunCidrOrDefault(defaultCidr: String, isIpv6: Boolean): CIDR {
    val candidate = this?.trim().orEmpty()
    if (candidate.isNotEmpty()) {
        val parsed = runCatching { candidate.toCIDR() }.getOrNull()
        if (parsed != null && parsed.isValidTunHost(isIpv6 = isIpv6)) {
            return parsed
        }
    }
    return defaultCidr.toCIDR()
}

private fun CIDR.isValidTunHost(isIpv6: Boolean): Boolean {
    if ((address is Inet6Address) != isIpv6) return false
    val raw = address.address
    val bits = raw.size * 8
    if (prefixLength !in 1..(bits - 2)) return false
    val hostMask = BigInteger.ONE.shiftLeft(bits - prefixLength).subtract(BigInteger.ONE)
    val hostBits = BigInteger(1, raw).and(hostMask)
    return hostBits > BigInteger.ZERO && hostBits < hostMask
}

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
