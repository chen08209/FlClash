package com.follow.clash.core

import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.URI

object Core {
    private external fun startTun(
        fd: Int,
        cb: TunInterface,
        stack: String,
        address: String,
        dns: String,
    )

    external fun forceGC()

    external fun updateDNS(
        dns: String,
    )

    private fun parseInetSocketAddress(address: String): InetSocketAddress {
        val uri = URI("tcp://$address")
        val host = requireNotNull(uri.host) { "Missing host in address: $address" }
        require(uri.port >= 0) { "Missing port in address: $address" }
        return InetSocketAddress(InetAddress.getByName(host), uri.port)
    }

    fun startTun(
        fd: Int,
        protect: (Int) -> Boolean,
        resolverProcess: (protocol: Int, source: InetSocketAddress, target: InetSocketAddress, uid: Int) -> String,
        stack: String,
        address: String,
        dns: String,
    ) {
        startTun(
            fd,
            object : TunInterface {
                override fun protect(fd: Int) {
                    protect(fd)
                }

                override fun resolverProcess(
                    protocol: Int,
                    source: String,
                    target: String,
                    uid: Int,
                ): String {
                    return resolverProcess(
                        protocol,
                        parseInetSocketAddress(source),
                        parseInetSocketAddress(target),
                        uid,
                    )
                }
            },
            stack,
            address,
            dns,
        )
    }

    external fun suspended(
        suspended: Boolean,
    )

    private external fun invokeMethod(
        data: String,
        cb: InvokeInterface,
    )

    fun invokeMethod(
        data: String,
        cb: (result: String?) -> Unit,
    ) {
        invokeMethod(
            data,
            object : InvokeInterface {
                override fun onResult(result: String?) {
                    cb(result)
                }
            },
        )
    }

    private external fun setEventListener(cb: InvokeInterface?)

    fun updateEventListener(
        callback: ((result: String?) -> Unit)?,
    ) {
        if (callback == null) {
            setEventListener(null)
        } else {
            setEventListener(
                object : InvokeInterface {
                    override fun onResult(result: String?) {
                        callback(result)
                    }
                },
            )
        }
    }

    fun quickSetup(
        initParamsString: String,
        setupParamsString: String,
        callback: (result: String?) -> Unit,
    ) {
        quickSetup(
            initParamsString,
            setupParamsString,
            object : InvokeInterface {
                override fun onResult(result: String?) {
                    callback(result)
                }
            },
        )
    }

    private external fun quickSetup(
        initParamsString: String,
        setupParamsString: String,
        cb: InvokeInterface,
    )

    external fun stopTun()

    external fun getTraffic(onlyStatisticsProxy: Boolean): String

    external fun getTotalTraffic(onlyStatisticsProxy: Boolean): String

    init {
        System.loadLibrary("core")
    }
}
