package com.follow.clash.service

import com.follow.clash.service.models.Traffic
import com.follow.clash.service.models.speedText
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class TrafficMeterTest {
    private class FakeWatch {
        var opened = 0
        var closed = 0
        var sample: ((Long, Long) -> Unit)? = null
        var lose: (() -> Unit)? = null

        fun open(
            @Suppress("UNUSED_PARAMETER") onlyProxy: Boolean,
            onLost: () -> Unit,
            onTraffic: (Long, Long) -> Unit,
        ): AutoCloseable {
            opened++
            lose = onLost
            sample = onTraffic
            return AutoCloseable { closed++ }
        }
    }

    @Test
    fun `only a changed speed reaches the notification`() =
        runTest {
            val watch = FakeWatch()
            val texts = mutableListOf<String>()
            val collecting = launch { speedTexts(false, watch::open).toList(texts) }
            runCurrent()

            repeat(3) { watch.sample!!(0, 0) }
            watch.sample!!(2048, 0)
            watch.sample!!(2048, 0)
            watch.sample!!(0, 0)
            runCurrent()

            assertEquals(
                listOf(idleSpeedText, idleSpeedText, Traffic(2048, 0).speedText, idleSpeedText),
                texts,
            )
            collecting.cancel()
            runCurrent()
            assertEquals(1 to 1, watch.opened to watch.closed)
        }

    @Test
    fun `a reopened watch shows the speed it starts from, not the one before the loss`() =
        runTest {
            val watch = FakeWatch()
            val texts = mutableListOf<String>()
            val collecting = launch { speedTexts(false, watch::open).toList(texts) }
            runCurrent()
            watch.sample!!(2048, 0)
            runCurrent()

            watch.lose!!()
            advanceTimeBy(1_000)
            runCurrent()
            watch.sample!!(0, 0)
            runCurrent()

            assertEquals(listOf(idleSpeedText, Traffic(2048, 0).speedText, idleSpeedText), texts)
            collecting.cancel()
        }

    @Test
    fun `a watch the Core drops opens again a second later`() =
        runTest {
            val watch = FakeWatch()
            val collecting = launch { speedTexts(false, watch::open).collect {} }
            runCurrent()

            watch.lose!!()
            runCurrent()
            assertEquals(1 to 1, watch.opened to watch.closed)
            advanceTimeBy(999)
            runCurrent()
            assertEquals(1, watch.opened)
            advanceTimeBy(1)
            runCurrent()
            assertEquals(2, watch.opened)
            collecting.cancel()
        }
}
