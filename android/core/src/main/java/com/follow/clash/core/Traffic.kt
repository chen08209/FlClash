package com.follow.clash.core

import com.google.gson.JsonElement

private const val TRAFFIC_INTERVAL_MILLIS = 1000

/** The current rates first, then a sample only when one differs, so an idle tunnel sends nothing. */
internal fun CoreClient.watchTraffic(
    onlyProxy: Boolean,
    onLost: () -> Unit,
    onTraffic: (up: Long, down: Long) -> Unit,
): AutoCloseable {
    val sample = { element: JsonElement ->
        val traffic = element.asJsonObject
        onTraffic(traffic.get("up").asLong, traffic.get("down").asLong)
    }
    return watch(
        "traffic.watch",
        mapOf("intervalMs" to TRAFFIC_INTERVAL_MILLIS, "onlyProxy" to onlyProxy, "changesOnly" to true),
        onLost,
        onSnapshot = sample,
        onEvent = sample,
    )
}
