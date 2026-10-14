package com.follow.clash.core

import com.follow.clash.core.mobile.Mobile
import com.follow.clash.core.mobile.ResultHandler
import com.follow.clash.core.mobile.TunHandler
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.URI

object Core {
    fun forceGC() = Mobile.forceGC()

    fun updateDNS(
        dns: String,
    ) = Mobile.updateDns(dns)

    fun resetNetwork() = Mobile.resetNetwork()

    private fun parseInetSocketAddress(address: String): InetSocketAddress {
        val uri = URI("tcp://$address")
        val host = requireNotNull(uri.host) { "Missing host in address: $address" }
        require(uri.port >= 0) { "Missing port in address: $address" }
        return InetSocketAddress(InetAddress.getByName(host), uri.port)
    }

    fun startTun(
        fd: Int,
        protect: (Int) -> Boolean,
        resolveUid: (protocol: Int, source: InetSocketAddress, target: InetSocketAddress) -> Int,
        resolvePackage: (uid: Int) -> String,
        stack: String,
        address: String,
        dns: String,
        options: String,
    ): Boolean {
        return Mobile.startTun(
            fd,
            object : TunHandler {
                override fun protect(fd: Int): Boolean = protect(fd)

                override fun resolveUid(
                    protocol: Int,
                    source: String,
                    target: String,
                ): Int {
                    return resolveUid(
                        protocol,
                        parseInetSocketAddress(source),
                        parseInetSocketAddress(target),
                    )
                }

                override fun resolvePackage(uid: Int): String = resolvePackage(uid)
            },
            stack,
            address,
            dns,
            options,
        )
    }

    fun invokeMethod(
        data: String,
        cb: (result: ByteArray?) -> Unit,
    ) {
        Mobile.invokeMethod(data, ResultHandler { result -> cb(result) })
    }

    fun updateEventListener(
        callback: ((result: String?) -> Unit)?,
    ) {
        Mobile.setEventListener(
            callback?.let { ResultHandler { result -> it(result?.decodeToString()) } },
        )
    }

    fun quickSetup(
        initParamsString: String,
        setupParamsString: String,
        callback: (result: String?) -> Unit,
    ) {
        Mobile.quickSetup(
            initParamsString,
            setupParamsString,
            ResultHandler { result -> callback(result?.decodeToString()) },
        )
    }

    fun stopTun() = Mobile.stopTun()

    fun startListener() = Mobile.startListener()

    fun stopListener() = Mobile.stopListener()

    fun getTraffic(onlyStatisticsProxy: Boolean): String = Mobile.getTraffic(onlyStatisticsProxy)

    fun getTotalTraffic(onlyStatisticsProxy: Boolean): String = Mobile.getTotalTraffic(onlyStatisticsProxy)
}
