package com.follow.clash.core

import com.follow.clash.core.mobile.Mobile

fun interface FrameReceiver {
    fun onFrame(frame: ByteArray): Boolean
}

interface PlatformHost {
    fun protect(fd: Int): Boolean

    fun resolveUid(
        protocol: Int,
        source: String,
        target: String,
    ): Int

    fun resolvePackage(uid: Int): String
}

interface FrameTransport {
    fun open(receiver: FrameReceiver): Long

    fun send(
        session: Long,
        frame: ByteArray,
    ): Boolean

    fun close(session: Long)
}

object NativeCore : FrameTransport {
    // Dart's DynamicLibrary.open finds the loaded library; JNI_OnLoad is what starts the Core.
    fun load() = Mobile.touch()

    override fun open(receiver: FrameReceiver): Long = Mobile.openSession(receiver)

    override fun send(
        session: Long,
        frame: ByteArray,
    ): Boolean = Mobile.sendFrame(session, frame)

    override fun close(session: Long) = Mobile.closeSession(session)

    fun setPlatformHost(host: PlatformHost?) = Mobile.setPlatformHost(host)

    fun adoptFd(fd: Int): Long = Mobile.adoptFd(fd)
}
