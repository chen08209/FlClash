package com.follow.clash.service

import android.content.pm.PackageManager
import com.follow.clash.service.models.VpnOptions
import java.util.concurrent.ConcurrentHashMap

internal class UidPackageNames(private val packageManager: PackageManager) {
    private val names = ConcurrentHashMap<Int, String>()

    fun resolve(uid: Int): String {
        names[uid]?.let { return it }
        val name = packageManager.getPackagesForUid(uid)?.firstOrNull()?.takeIf { it.isNotEmpty() }.orEmpty()
        return names.putIfAbsent(uid, name) ?: name
    }
}

internal val VpnOptions.tunAddress: List<String>
    get() = buildList {
        add(VpnService.IPV4_ADDRESS)
        if (ipv6) add(VpnService.IPV6_ADDRESS)
    }
