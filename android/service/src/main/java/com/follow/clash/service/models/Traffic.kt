package com.follow.clash.service.models

import com.follow.clash.common.formatBytes
import com.follow.clash.core.Core
import com.google.gson.Gson

data class Traffic(
    val up: Long,
    val down: Long,
)

val Traffic.speedText: String
    get() = "${up.formatBytes}/s↑  ${down.formatBytes}/s↓"

fun Core.getSpeedTrafficText(onlyStatisticsProxy: Boolean): String {
    val res = getTraffic(onlyStatisticsProxy)
    val traffic = Gson().fromJson(res, Traffic::class.java)
    return traffic.speedText
}