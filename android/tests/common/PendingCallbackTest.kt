package com.follow.clash.common

import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PendingCallbackTest {
    @Test
    fun `starts empty`() {
        val slot = PendingCallback<Boolean>()

        assertFalse(slot.isPending)
    }

    @Test
    fun `replace leaves the new callback pending`() {
        val slot = PendingCallback<Boolean>()

        slot.replace({ }, supersededValue = false)

        assertTrue(slot.isPending)
    }

    @Test
    fun `resolve delivers the value once and empties the slot`() {
        val slot = PendingCallback<Boolean>()
        val received = mutableListOf<Boolean>()
        slot.replace({ received.add(it) }, supersededValue = false)

        slot.resolve(true)
        slot.resolve(true)

        assertEquals(listOf(true), received)
        assertFalse(slot.isPending)
    }

    @Test
    fun `replace settles the request it supersedes`() {
        val slot = PendingCallback<Boolean>()
        val first = mutableListOf<Boolean>()
        val second = mutableListOf<Boolean>()
        slot.replace({ first.add(it) }, supersededValue = false)

        slot.replace({ second.add(it) }, supersededValue = false)

        assertEquals(listOf(false), first)
        assertTrue(second.isEmpty())

        slot.resolve(true)

        assertEquals(listOf(false), first)
        assertEquals(listOf(true), second)
    }

    @Test
    fun `resolve on an empty slot is inert`() {
        val slot = PendingCallback<Boolean>()

        slot.resolve(true)

        assertFalse(slot.isPending)
    }

    @Test
    fun `cancel drops the matching callback without invoking it`() {
        val slot = PendingCallback<Boolean>()
        val received = mutableListOf<Boolean>()
        val callback: (Boolean) -> Unit = { received.add(it) }
        slot.replace(callback, supersededValue = false)

        slot.cancel(callback)

        assertFalse(slot.isPending)
        assertTrue(received.isEmpty())
    }

    @Test
    fun `cancel keeps a callback that is no longer the pending one`() {
        val slot = PendingCallback<Boolean>()
        val stale = mutableListOf<Boolean>()
        val current = mutableListOf<Boolean>()
        val staleCallback: (Boolean) -> Unit = { stale.add(it) }
        slot.replace(staleCallback, supersededValue = false)
        slot.replace({ current.add(it) }, supersededValue = false)

        slot.cancel(staleCallback)

        assertTrue(slot.isPending)

        slot.resolve(true)

        assertEquals(listOf(false), stale)
        assertEquals(listOf(true), current)
    }

    @Test
    fun `a callback that starts a new request is not resolved twice`() {
        val slot = PendingCallback<Boolean>()
        val outer = mutableListOf<Boolean>()
        val inner = mutableListOf<Boolean>()
        slot.replace(
            {
                outer.add(it)
                slot.replace({ value -> inner.add(value) }, supersededValue = false)
            },
            supersededValue = false,
        )

        slot.resolve(true)

        assertEquals(listOf(true), outer)
        assertTrue(inner.isEmpty())
        assertTrue(slot.isPending)

        slot.resolve(false)

        assertEquals(listOf(true), outer)
        assertEquals(listOf(false), inner)
    }

    /**
     * The request is started off the main thread and the answer arrives on it, so
     * a resolve that has already read the slot must not clear the callback a
     * concurrent replace installed after that read. Losing it strands the request
     * that callback belongs to, which on the VPN consent hop means the start path
     * never releases its lock.
     */
    @Test
    fun `a callback installed while a resolve is in flight is never dropped`() {
        repeat(200) {
            val slot = PendingCallback<Boolean>()
            val settled = AtomicInteger()
            slot.replace({ settled.incrementAndGet() }, supersededValue = false)

            val ready = CountDownLatch(2)
            val go = CountDownLatch(1)
            val replacer = Thread {
                ready.countDown()
                go.await()
                slot.replace({ settled.incrementAndGet() }, supersededValue = false)
            }
            val resolver = Thread {
                ready.countDown()
                go.await()
                slot.resolve(true)
            }
            replacer.start()
            resolver.start()
            ready.await()
            go.countDown()
            replacer.join(TimeUnit.SECONDS.toMillis(5))
            resolver.join(TimeUnit.SECONDS.toMillis(5))

            // Two callbacks were installed and at most one of them can still be
            // pending, so every callback the slot let go of must have been called.
            val pending = if (slot.isPending) 1 else 0
            assertEquals(2 - pending, settled.get())
        }
    }
}
