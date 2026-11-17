package com.follow.clash.service

import com.follow.clash.common.GlobalState
import com.follow.clash.core.Core
import com.follow.clash.service.models.Traffic
import com.follow.clash.service.models.speedText
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collectLatest

internal suspend fun Flow<Boolean>.whileScreenOn(
    meter: TrafficMeter,
    show: suspend () -> Unit,
) = collectLatest { screenOn -> if (screenOn) show() else meter.close() }

internal class TrafficMeter(
    private val watchTraffic: (Boolean, () -> Unit, (Long, Long) -> Unit) -> AutoCloseable = Core::watchTraffic,
) {
    private var watch: AutoCloseable? = null
    private var watchedProxyOnly: Boolean? = null

    private var generation = 0

    @Volatile
    private var lostGeneration = -1

    @Volatile
    private var latest = Traffic(up = 0, down = 0)

    @Synchronized
    fun speedText(onlyStatisticsProxy: Boolean): String {
        if (watchedProxyOnly != onlyStatisticsProxy || lostGeneration == generation) {
            watch?.close()
            watchedProxyOnly = onlyStatisticsProxy
            val mine = ++generation
            watch = runCatching {
                watchTraffic(onlyStatisticsProxy, { lostGeneration = mine }) { up, down ->
                    latest = Traffic(up, down)
                }
            }.onFailure { error ->
                GlobalState.log("Unable to read traffic: $error")
            }.getOrNull()
        }
        return latest.speedText
    }

    @Synchronized
    fun close() {
        watch?.close()
        watch = null
        watchedProxyOnly = null
        latest = Traffic(up = 0, down = 0)
    }
}
