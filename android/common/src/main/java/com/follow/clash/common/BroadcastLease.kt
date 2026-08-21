package com.follow.clash.common

import java.util.concurrent.atomic.AtomicBoolean

/**
 * Releases an Android broadcast lease exactly once.
 *
 * A `BroadcastReceiver.goAsync()` path holds the broadcast open until its
 * `PendingResult` is finished, and finishing twice throws. Normal completion and
 * the timeout watchdog both race to release it, so the winner is decided here
 * rather than by whichever callback happens to run first.
 *
 * Releasing the lease says only that Android may stop waiting for this receiver.
 * It does not cancel, reverse, or otherwise redefine the work the broadcast
 * started, which keeps running under its own owner.
 */
class BroadcastLease(private val release: () -> Unit) {
    private val released = AtomicBoolean(false)

    val isReleased: Boolean
        get() = released.get()

    /**
     * Releases the lease if it is still held, running [onRelease] first so a
     * caller can report why it won.
     *
     * Returns whether this call is the one that released it.
     */
    fun release(onRelease: () -> Unit = {}): Boolean {
        if (!released.compareAndSet(false, true)) {
            return false
        }
        onRelease()
        release.invoke()
        return true
    }
}
