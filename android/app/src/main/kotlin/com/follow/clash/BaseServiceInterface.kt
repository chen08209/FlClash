package com.follow.clash


import com.follow.clash.models.VpnOptions

interface BaseServiceInterface {
    fun start(options: VpnOptions): Int
    fun stop()
    fun startForeground(title: String, content: String)
}