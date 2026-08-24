package com.follow.clash.common

/**
 * A single-slot callback holder for request/response hops that leave the process
 * and come back through an Android callback, such as a permission prompt or the
 * VPN consent dialog.
 *
 * Only the newest request is ever pending: [replace] settles the request it
 * supersedes rather than dropping it, so no caller is left waiting forever. The
 * slot is cleared before the callback runs, so a callback that starts another
 * request cannot resolve itself twice.
 *
 * The two ends of such a hop live on different threads — the request is started
 * from whatever coroutine wants the permission, the answer arrives on the main
 * thread through `onActivityResult` — so every read and write of the slot is a
 * single atomic swap. Without that, a resolve that has already read the slot can
 * clear a callback a concurrent replace installed after it, and the request that
 * callback belonged to never completes: the VPN consent answer is lost and the
 * lock the start path holds is never released.
 *
 * Callbacks run outside the lock. They resume coroutines and can start the next
 * request, and holding the monitor across that would make the slot's lock part
 * of every caller's lock order.
 */
class PendingCallback<T> {
    private val lock = Any()
    private var callback: ((T) -> Unit)? = null

    val isPending: Boolean
        get() = synchronized(lock) { callback != null }

    fun replace(next: (T) -> Unit, supersededValue: T) {
        val superseded = synchronized(lock) {
            val current = callback
            callback = next
            current
        }
        superseded?.invoke(supersededValue)
    }

    fun resolve(value: T) {
        val current = synchronized(lock) {
            val current = callback ?: return
            callback = null
            current
        }
        current(value)
    }

    fun cancel(target: (T) -> Unit) {
        synchronized(lock) {
            if (callback === target) {
                callback = null
            }
        }
    }
}
