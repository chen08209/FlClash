package com.follow.clash.core

import androidx.annotation.Keep

@Keep
interface TunInterface {
    fun protect(fd: Int)
    fun resolverProcess(protocol: Int, source: String, target: String, uid: Int): String
}