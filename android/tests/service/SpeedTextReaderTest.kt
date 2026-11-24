package com.follow.clash.service

import android.net.TrafficStats
import org.junit.Assert.assertEquals
import org.junit.Test

class SpeedTextReaderTest {
    private var millis = 0L
    private var bytes = 0L
    private var coreText = idleSpeedText
    private var coreReads = 0
    private val reader = SpeedTextReader(
        uidBytes = { bytes },
        readText = { coreReads++; coreText },
        clock = { millis },
    )

    private fun tick(): String {
        millis += 1_000
        return reader.read(false)
    }

    @Test
    fun `an idle tunnel stops asking the Core once its counters stay still`() {
        reader.read(false)
        repeat(5) { assertEquals(idleSpeedText, tick()) }

        assertEquals(2, coreReads)
    }

    @Test
    fun `moved bytes reach the notification on the next tick`() {
        reader.read(false)
        repeat(5) { tick() }
        val idleReads = coreReads

        bytes += 4096
        coreText = "4.0KB/s↑  0B/s↓"
        assertEquals(coreText, tick())
        assertEquals(idleReads + 1, coreReads)
    }

    @Test
    fun `a rate the Core reports a second late still shows`() {
        reader.read(false)
        repeat(5) { tick() }

        bytes += 4096
        assertEquals(idleSpeedText, tick())
        coreText = "4.0KB/s↑  0B/s↓"
        assertEquals(coreText, tick())
    }

    @Test
    fun `a speed that is not zero keeps being read until the Core says zero`() {
        coreText = "1.0KB/s↑  0B/s↓"
        reader.read(false)
        repeat(3) { tick() }
        coreText = idleSpeedText
        assertEquals(idleSpeedText, tick())

        assertEquals(5, coreReads)
    }

    @Test
    fun `counters the kernel cannot give leave every read to the Core`() {
        bytes = TrafficStats.UNSUPPORTED.toLong()
        reader.read(false)
        repeat(5) { tick() }

        assertEquals(6, coreReads)
    }
}
