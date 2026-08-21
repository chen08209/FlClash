package com.follow.clash.common

import java.util.concurrent.CyclicBarrier
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class RunIntentArbiterTest {
    @Test
    fun `starts stopped by default`() {
        val arbiter = RunIntentArbiter()

        assertFalse(arbiter.isRunningRequested)
        assertFalse(arbiter.current().running)
    }

    @Test
    fun `request publishes the new intent`() {
        val arbiter = RunIntentArbiter()

        val token = arbiter.request(running = true)

        assertTrue(arbiter.isRunningRequested)
        assertTrue(arbiter.isCurrent(token))
        assertSame(token, arbiter.current())
    }

    @Test
    fun `each request mints a distinct token`() {
        val arbiter = RunIntentArbiter()

        val first = arbiter.request(running = true)
        val second = arbiter.request(running = true)

        assertNotSame(first, second)
        assertFalse(arbiter.isCurrent(first))
        assertTrue(arbiter.isCurrent(second))
    }

    @Test
    fun `a newer request supersedes work started for an older token`() {
        val arbiter = RunIntentArbiter()
        val start = arbiter.request(running = true)

        val stop = arbiter.request(running = false)

        assertFalse(arbiter.isCurrent(start))
        assertTrue(arbiter.isCurrent(stop))
        assertFalse(arbiter.isRunningRequested)
    }

    @Test
    fun `resetToStopped rolls back the current token`() {
        val arbiter = RunIntentArbiter()
        val token = arbiter.request(running = true)

        assertTrue(arbiter.resetToStopped(token))

        assertFalse(arbiter.isRunningRequested)
        assertFalse(arbiter.isCurrent(token))
    }

    @Test
    fun `resetToStopped does not clobber a newer intent`() {
        val arbiter = RunIntentArbiter()
        val stale = arbiter.request(running = true)
        val latest = arbiter.request(running = true)

        assertFalse(arbiter.resetToStopped(stale))

        assertTrue(arbiter.isRunningRequested)
        assertTrue(arbiter.isCurrent(latest))
    }

    @Test
    fun `resetToStopped is not idempotent for the same token`() {
        val arbiter = RunIntentArbiter()
        val token = arbiter.request(running = true)

        assertTrue(arbiter.resetToStopped(token))
        assertFalse(arbiter.resetToStopped(token))
    }

    @Test
    fun `a start racing ahead of a service-lost callback keeps its intent`() {
        val arbiter = RunIntentArbiter()
        val observed = arbiter.request(running = true)

        // The service-loss callback captured `observed`, but a new start won the race first.
        val restart = arbiter.request(running = true)
        val settled = arbiter.resetToStopped(observed)

        assertFalse(settled)
        assertTrue(arbiter.isRunningRequested)
        assertTrue(arbiter.isCurrent(restart))
    }

    @Test
    fun `initialRunning seeds the first intent`() {
        val arbiter = RunIntentArbiter(initialRunning = true)

        assertTrue(arbiter.isRunningRequested)
    }

    @Test
    fun `concurrent requests leave exactly one winning token`() {
        val arbiter = RunIntentArbiter()
        val threads = 8
        val executor = Executors.newFixedThreadPool(threads)
        val barrier = CyclicBarrier(threads)

        try {
            val tokens = (0 until threads).map { index ->
                executor.submit<RunIntentArbiter.Token> {
                    barrier.await(5, TimeUnit.SECONDS)
                    arbiter.request(running = index % 2 == 0)
                }
            }.map { it.get(5, TimeUnit.SECONDS) }

            val winners = tokens.filter(arbiter::isCurrent)
            assertEquals(1, winners.size)
            assertEquals(winners.single().running, arbiter.isRunningRequested)

            tokens.filterNot(arbiter::isCurrent).forEach { stale ->
                assertFalse(arbiter.resetToStopped(stale))
            }
            assertTrue(arbiter.isCurrent(winners.single()))
        } finally {
            executor.shutdownNow()
        }
    }
}
