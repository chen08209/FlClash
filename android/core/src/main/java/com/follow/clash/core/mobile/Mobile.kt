package com.follow.clash.core.mobile

import com.follow.clash.core.FrameReceiver
import com.follow.clash.core.PlatformHost

object Mobile {
    init {
        System.loadLibrary("core_jni")
    }

    fun touch() {}

    @JvmStatic
    external fun openSession(receiver: FrameReceiver): Long

    @JvmStatic
    external fun sendFrame(
        session: Long,
        frame: ByteArray,
    ): Boolean

    @JvmStatic
    external fun closeSession(session: Long)

    @JvmStatic
    external fun setPlatformHost(host: PlatformHost?)

    @JvmStatic
    external fun adoptFd(fd: Int): Long
}
