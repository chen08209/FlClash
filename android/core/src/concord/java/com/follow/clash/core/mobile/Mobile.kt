package com.follow.clash.core.mobile

fun interface ResultHandler {
    fun onResult(data: ByteArray?)
}

interface TunHandler {
    fun protect(fd: Int): Boolean

    fun resolveUid(
        protocol: Int,
        source: String,
        target: String,
    ): Int

    fun resolvePackage(uid: Int): String
}

object Mobile {
    init {
        System.loadLibrary("concord")
    }

    fun touch() {}

    @JvmStatic
    external fun invokeMethod(
        data: String,
        handler: ResultHandler,
    )

    @JvmStatic
    external fun startTun(
        fd: Int,
        handler: TunHandler,
        stack: String,
        address: String,
        dns: String,
        options: String,
    ): Boolean

    @JvmStatic
    external fun stopTun()

    @JvmStatic
    external fun startListener()

    @JvmStatic
    external fun stopListener()

    @JvmStatic
    external fun setEventListener(handler: ResultHandler?)

    @JvmStatic
    external fun quickSetup(
        initParams: String,
        setupParams: String,
        handler: ResultHandler,
    )

    @JvmStatic
    external fun forceGC()

    @JvmStatic
    external fun setMitmPressure(level: Int)

    @JvmStatic
    external fun updateDns(value: String)

    @JvmStatic
    external fun resetNetwork()

    @JvmStatic
    external fun getTraffic(onlyStatisticsProxy: Boolean): String

    @JvmStatic
    external fun getTotalTraffic(onlyStatisticsProxy: Boolean): String
}
