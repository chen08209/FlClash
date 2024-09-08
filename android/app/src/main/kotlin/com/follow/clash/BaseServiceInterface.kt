package com.follow.clash

import com.follow.clash.models.Props
import com.follow.clash.models.TunProps

interface BaseServiceInterface {
    fun start(port: Int, props: Props?): TunProps?
    fun stop()
    fun startForeground(title: String, content: String)
}