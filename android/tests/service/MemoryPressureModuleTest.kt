package com.follow.clash.service

import com.follow.clash.service.modules.MEMORY_POLL_INTERVAL_MS
import com.follow.clash.service.modules.pollWhile
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class MemoryPressureModuleTest {
    @Test
    fun `memory is read only while MITM is on`() =
        runTest {
            val mitm = MutableStateFlow(false)
            var polls = 0
            val polling = launch { pollWhile(mitm) { polls++ } }

            advanceTimeBy(MEMORY_POLL_INTERVAL_MS * 3)
            runCurrent()
            assertEquals(0, polls)

            mitm.value = true
            runCurrent()
            assertEquals(1, polls)
            advanceTimeBy(MEMORY_POLL_INTERVAL_MS)
            runCurrent()
            assertEquals(2, polls)

            mitm.value = false
            runCurrent()
            advanceTimeBy(MEMORY_POLL_INTERVAL_MS * 3)
            runCurrent()
            assertEquals(2, polls)
            polling.cancel()
        }
}
