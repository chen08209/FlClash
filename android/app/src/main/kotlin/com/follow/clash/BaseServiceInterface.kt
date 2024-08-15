package com.follow.clash

import com.follow.clash.models.Props

interface BaseServiceInterface {
    fun start(port: Int, props: Props?): Int?
    fun stop()
    fun startForeground(title: String, content: String)
}