package com.follow.clash.service.models

import java.util.Locale
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class TrafficTest {
    private lateinit var defaultLocale: Locale

    @Before
    fun pinLocale() {
        // speedText formats through String.format, which follows the default locale.
        defaultLocale = Locale.getDefault()
        Locale.setDefault(Locale.ROOT)
    }

    @After
    fun restoreLocale() {
        Locale.setDefault(defaultLocale)
    }

    @Test
    fun `renders whole bytes without a decimal part`() {
        assertEquals("0B/s↑  0B/s↓", Traffic(up = 0, down = 0).speedText)
        assertEquals("1023B/s↑  1B/s↓", Traffic(up = 1023, down = 1).speedText)
    }

    @Test
    fun `promotes to the next unit at 1024`() {
        assertEquals("1.0KB/s↑  1.0KB/s↓", Traffic(up = 1024, down = 1024).speedText)
    }

    @Test
    fun `keeps one decimal place for fractional values`() {
        assertEquals("1.5KB/s↑  2.5KB/s↓", Traffic(up = 1536, down = 2560).speedText)
    }

    @Test
    fun `scales through every unit`() {
        assertTrue(Traffic(up = 1024L * 1024, down = 0).speedText.startsWith("1.0MB"))
        assertTrue(
            Traffic(up = 1024L * 1024 * 1024, down = 0).speedText.startsWith("1.0GB"),
        )
        assertTrue(
            Traffic(up = 1024L * 1024 * 1024 * 1024, down = 0).speedText
                .startsWith("1.0TB"),
        )
    }

    @Test
    fun `stops promoting above terabytes`() {
        val text = Traffic(up = 1024L * 1024 * 1024 * 1024 * 1024, down = 0).speedText

        assertTrue(text.startsWith("1024.0TB"))
    }

    @Test
    fun `labels upload before download`() {
        val text = Traffic(up = 1, down = 2).speedText

        assertTrue(text.indexOf("↑") < text.indexOf("↓"))
        assertEquals("1B/s↑  2B/s↓", text)
    }
}
