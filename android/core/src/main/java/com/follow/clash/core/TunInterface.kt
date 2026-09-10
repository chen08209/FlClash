package com.follow.clash.core

import androidx.annotation.Keep

@Keep
interface TunInterface {
    /** Returns false when the socket could not be kept out of the tunnel. */
    fun protect(fd: Int): Boolean

    /** Returns the uid owning the connection, or -1 when the system will not name it. */
    fun resolveUid(protocol: Int, source: String, target: String): Int

    fun resolvePackage(uid: Int): String
}
