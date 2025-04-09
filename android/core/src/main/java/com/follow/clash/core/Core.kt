package com.follow.clash.core

import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.URL

data object Core {
    private external fun startTun(
        fd: Int,
        cb: TunInterface
    )

    private fun parseInetSocketAddress(address: String): InetSocketAddress {
        val url = URL("https://$address")

        return InetSocketAddress(InetAddress.getByName(url.host), url.port)
    }

    fun startTun(
        fd: Int,
        protect: (Int) -> Boolean,
        resolverProcess: (protocol: Int, source: InetSocketAddress, target: InetSocketAddress, uid: Int) -> String
    ) {
        startTun(fd, object : TunInterface {
            override fun protect(fd: Int) {
                protect(fd)
            }

            override fun resolverProcess(
                protocol: Int,
                source: String,
                target: String,
                uid: Int
            ): String {
                return resolverProcess(
                    protocol,
                    parseInetSocketAddress(source),
                    parseInetSocketAddress(target),
                    uid,
                )
            }
        });
    }

    external fun stopTun()

    init {
        System.loadLibrary("core")
    }
}