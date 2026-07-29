package com.follow.clash.service.models

import android.os.Parcel
import android.os.Parcelable
import com.follow.clash.common.AccessControlMode
import java.net.InetAddress

data class AccessControlProps(
    val enable: Boolean,
    val mode: AccessControlMode,
    val acceptList: List<String>,
    val rejectList: List<String>,
) : Parcelable {
    constructor(parcel: Parcel) : this(
        enable = parcel.readByte() != 0.toByte(),
        mode = AccessControlMode.valueOf(parcel.readString() ?: AccessControlMode.ACCEPT_SELECTED.name),
        acceptList = parcel.createStringArrayList() ?: emptyList(),
        rejectList = parcel.createStringArrayList() ?: emptyList(),
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeByte(if (enable) 1.toByte() else 0.toByte())
        parcel.writeString(mode.name)
        parcel.writeStringList(acceptList)
        parcel.writeStringList(rejectList)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<AccessControlProps> {
        override fun createFromParcel(parcel: Parcel): AccessControlProps {
            return AccessControlProps(parcel)
        }

        override fun newArray(size: Int): Array<AccessControlProps?> {
            return arrayOfNulls(size)
        }
    }
}

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
) : Parcelable {
    constructor(parcel: Parcel) : this(
        enable = parcel.readByte() != 0.toByte(),
        port = parcel.readInt(),
        ipv6 = parcel.readByte() != 0.toByte(),
        dnsHijacking = parcel.readByte() != 0.toByte(),
        accessControlProps = readAccessControlProps(parcel),
        allowBypass = parcel.readByte() != 0.toByte(),
        systemProxy = parcel.readByte() != 0.toByte(),
        bypassDomain = parcel.createStringArrayList() ?: emptyList(),
        stack = parcel.readString() ?: "",
        routeAddress = parcel.createStringArrayList() ?: emptyList(),
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeByte(if (enable) 1.toByte() else 0.toByte())
        parcel.writeInt(port)
        parcel.writeByte(if (ipv6) 1.toByte() else 0.toByte())
        parcel.writeByte(if (dnsHijacking) 1.toByte() else 0.toByte())
        parcel.writeParcelable(accessControlProps, flags)
        parcel.writeByte(if (allowBypass) 1.toByte() else 0.toByte())
        parcel.writeByte(if (systemProxy) 1.toByte() else 0.toByte())
        parcel.writeStringList(bypassDomain)
        parcel.writeString(stack)
        parcel.writeStringList(routeAddress)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<VpnOptions> {
        @Suppress("DEPRECATION")
        private fun readAccessControlProps(parcel: Parcel): AccessControlProps {
            return parcel.readParcelable<AccessControlProps>(
                AccessControlProps::class.java.classLoader,
            ) ?: AccessControlProps(
                enable = false,
                mode = AccessControlMode.ACCEPT_SELECTED,
                acceptList = emptyList(),
                rejectList = emptyList(),
            )
        }

        override fun createFromParcel(parcel: Parcel): VpnOptions {
            return VpnOptions(parcel)
        }

        override fun newArray(size: Int): Array<VpnOptions?> {
            return arrayOfNulls(size)
        }
    }
}

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
