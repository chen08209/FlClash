package com.follow.clash.packages

import org.junit.Assert.assertFalse
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class ChinaPackageMatcherTest {

    @Test
    fun `known vendors and SDKs match`() {
        val names = listOf(
            "com.tencent.mm",
            "com.alipay.android.app",
            "com.taobao.taobao",
            "com.baidu.searchbox",
            "com.bytedance.sdk.openadsdk",
            "com.netease.cloudmusic",
            "com.unionpay.tsmservice",
            "cn.wps.moffice",
            "andes.oplus.internal",
        )
        for (name in names) {
            assertTrue(name, ChinaPackageMatcher.matchesKnownPrefix(name))
        }
    }

    @Test
    fun `packer signatures used as class names match`() {
        val classNames = listOf(
            "com.secneo.apkwrapper.H",
            "s.h.e.l.l.S",
            "com.stub.StubApp",
            "com.kiwisec.KiwiSecApplication",
            "com.secshell.shellwrapper.SecAppWrapper",
            "com.wrapper.proxyapplication.WrapperProxyApplication",
            "cn.securitystack.stack.StackApplication",
        )
        for (name in classNames) {
            assertTrue(name, ChinaPackageMatcher.matchesKnownPrefix(name))
        }
    }

    /**
     * The prefixes carry no dot boundary on purpose. Adding one would look
     * tidier and would silently stop detecting 360 and the Alibaba clouds,
     * whose packages extend the prefix without a separator.
     */
    @Test
    fun `prefixes deliberately match without a separator`() {
        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.qihoo360.mobilesafe"))
        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.aliyun.linkcard"))
        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.alimama.moon"))
    }

    @Test
    fun `a bare prefix matches on its own`() {
        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.tencent"))
    }

    @Test
    fun `unrelated packages do not match`() {
        val names = listOf(
            "org.mozilla.firefox",
            "com.spotify.music",
            "de.telekom.mail",
            "com.whatsapp",
        )
        for (name in names) {
            assertFalse(name, ChinaPackageMatcher.matchesKnownPrefix(name))
        }
    }

    /**
     * These two do match a prefix, which is exactly why they have to be skipped
     * explicitly: MX Player is caught by `com.mx` (meant for Maxthon) and
     * StubHub by `com.stub` (meant for the StubApp packer).
     */
    @Test
    fun `loose prefixes drag in unrelated apps that the skip list removes`() {
        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.mxtech.videoplayer.ad"))
        assertTrue(ChinaPackageMatcher.isSkipped("com.mxtech.videoplayer.ad"))

        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.stubhub"))
        assertTrue(ChinaPackageMatcher.isSkipped("com.stubhub"))
    }

    @Test
    fun `the intended owners of those prefixes still match and are not skipped`() {
        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.mx.browser"))
        assertFalse(ChinaPackageMatcher.isSkipped("com.mx.browser"))

        assertTrue(ChinaPackageMatcher.matchesKnownPrefix("com.stub.StubApp"))
        assertFalse(ChinaPackageMatcher.isSkipped("com.stub.StubApp"))
    }

    @Test
    fun `the skip list applies a dot boundary`() {
        assertTrue(ChinaPackageMatcher.isSkipped("com.google"))
        assertTrue(ChinaPackageMatcher.isSkipped("com.google.android.gms"))
        assertFalse(
            "com.googlefoo is a different vendor",
            ChinaPackageMatcher.isSkipped("com.googlefoo"),
        )
    }

    @Test
    fun `skipping wins over a matching prefix`() {
        // TikTok ships domestic SDKs but must stay out of the domestic list.
        assertTrue(ChinaPackageMatcher.isSkipped("com.zhiliaoapp.musically"))
    }

    @Test
    fun `dex descriptors are normalized before matching`() {
        assertEquals(
            "com.tencent.mm.Foo.Bar",
            ChinaPackageMatcher.classNameOf("Lcom/tencent/mm/Foo\$Bar;"),
        )
        assertTrue(
            ChinaPackageMatcher.matchesKnownPrefix(
                ChinaPackageMatcher.classNameOf("Lcom/qihoo360/replugin/Entry;"),
            ),
        )
    }

    @Test
    fun `an already normalized name survives normalization`() {
        assertEquals("com.example.Foo", ChinaPackageMatcher.classNameOf("com.example.Foo"))
    }
}
