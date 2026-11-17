package com.follow.clash.service

import android.content.ComponentCallbacks2
import java.util.concurrent.Executor
import org.junit.Assert.assertEquals
import org.junit.Test

class CoreMemoryTest {
    @Suppress("DEPRECATION")
    @Test
    fun `memory callbacks leave the Core calls to another thread`() {
        val queued = mutableListOf<Runnable>()
        val later = Executor { task -> queued += task }

        trimCoreMemory(ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW, later)
        lowCoreMemory(later)

        assertEquals(2, queued.size)
    }
}
