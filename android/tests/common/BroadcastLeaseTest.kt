package com.follow.clash.common

import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class BroadcastLeaseTest {
    @Test
    fun `starts held`() {
        val lease = BroadcastLease { }

        assertFalse(lease.isReleased)
    }

    @Test
    fun `the first release runs the release action and reports the win`() {
        var releases = 0
        val lease = BroadcastLease { releases++ }

        assertTrue(lease.release())
        assertEquals(1, releases)
        assertTrue(lease.isReleased)
    }

    @Test
    fun `a second release neither runs nor claims the win`() {
        var releases = 0
        val lease = BroadcastLease { releases++ }
        lease.release()

        assertFalse(lease.release())
        assertEquals(1, releases)
    }

    @Test
    fun `the reason runs only for the caller that wins`() {
        val reasons = mutableListOf<String>()
        val lease = BroadcastLease { }

        lease.release { reasons.add("timeout") }
        lease.release { reasons.add("completion") }

        assertEquals(listOf("timeout"), reasons)
    }

    @Test
    fun `the reason runs before the lease is released`() {
        val order = mutableListOf<String>()
        val lease = BroadcastLease { order.add("release") }

        lease.release { order.add("reason") }

        assertEquals(listOf("reason", "release"), order)
    }

    @Test
    fun `only one of many concurrent releases wins`() {
        val threads = 16
        val releases = AtomicInteger(0)
        val wins = AtomicInteger(0)
        val lease = BroadcastLease { releases.incrementAndGet() }
        val start = CountDownLatch(1)
        val done = CountDownLatch(threads)
        val pool = Executors.newFixedThreadPool(threads)

        repeat(threads) {
            pool.execute {
                start.await()
                if (lease.release()) {
                    wins.incrementAndGet()
                }
                done.countDown()
            }
        }
        start.countDown()

        assertTrue(done.await(5, TimeUnit.SECONDS))
        pool.shutdown()
        assertEquals(1, releases.get())
        assertEquals(1, wins.get())
    }
}
