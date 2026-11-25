package com.follow.clash.service

import com.follow.clash.common.GlobalState
import com.follow.clash.core.Core
import com.follow.clash.service.models.Traffic
import com.follow.clash.service.models.speedText
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.flow.retryWhen
import java.util.concurrent.atomic.AtomicReference

private const val REOPEN_DELAY_MILLIS = 1_000L

internal val idleSpeedText = Traffic(up = 0, down = 0).speedText

private class WatchLost : Exception()

/** Emits only when the text changes; the Core sends only changed samples, so an idle tunnel wakes neither side. */
internal fun speedTexts(
    onlyStatisticsProxy: Boolean,
    watchTraffic: (Boolean, () -> Unit, (Long, Long) -> Unit) -> AutoCloseable = Core::watchTraffic,
): Flow<String> =
    callbackFlow {
        val shown = AtomicReference<String?>(null)
        val watch = watchTraffic(onlyStatisticsProxy, { close(WatchLost()) }) { up, down ->
            val text = Traffic(up, down).speedText
            if (shown.getAndSet(text) != text) trySend(text)
        }
        awaitClose { watch.close() }
    }.retryWhen { error, _ ->
        if (error !is WatchLost) GlobalState.log("Unable to read traffic: $error")
        delay(REOPEN_DELAY_MILLIS)
        true
    }.onStart {
        emit(idleSpeedText)
    }
