package com.follow.clash.service

import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class TrafficMeterTest {
    @Test
    fun `the traffic watch closes with the screen and opens once when it is back`() =
        runTest {
            var opened = 0
            var closed = 0
            val meter =
                TrafficMeter { _, _, _ ->
                    opened++
                    AutoCloseable { closed++ }
                }
            val screen = MutableSharedFlow<Boolean>()
            val shown =
                launch {
                    screen.whileScreenOn(meter) {
                        meter.speedText(onlyStatisticsProxy = false)
                        awaitCancellation()
                    }
                }
            runCurrent()

            screen.emit(true)
            runCurrent()
            screen.emit(false)
            runCurrent()
            assertEquals(1 to 1, opened to closed)

            screen.emit(true)
            runCurrent()
            screen.emit(true)
            runCurrent()
            assertEquals(2 to 1, opened to closed)
            shown.cancel()
        }
}
