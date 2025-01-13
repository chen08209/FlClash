package com.follow.clash.services

import com.follow.clash.models.VpnOptions

interface BaseServiceInterface {

    fun start(options: VpnOptions): Int

    fun stop()

    suspend fun startForeground(title: String, content: String)
}