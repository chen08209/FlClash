package com.follow.clash.common

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow


fun tickerFlow(delayMillis: Long, initialDelayMillis: Long = delayMillis): Flow<Unit> = flow {
    delay(initialDelayMillis)
    while (true) {
        emit(Unit)
        delay(delayMillis)
    }
}