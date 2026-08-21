package com.follow.clash.packages

/**
 * Decides whether a package name or a fully qualified class name looks like it
 * belongs to a domestic app or SDK.
 *
 * The prefixes in [CHINA_PACKAGE_REGEX] are matched *without* a trailing dot
 * boundary, and that is deliberate: `com.qihoo` has to reach `com.qihoo360.*`
 * and `com.ali` has to reach `com.aliyun.*` and `com.alimama.*`. Requiring a
 * separator would turn those into misses.
 *
 * The price is that unrelated names starting with the same letters match too.
 * [SKIPPED_PREFIXES] is where those come back out, and it *does* apply a dot
 * boundary, because there the entries are whole package roots.
 */
internal object ChinaPackageMatcher {

    /**
     * Whether [packageName] is never treated as domestic, no matter which
     * classes or SDKs it ships.
     */
    fun isSkipped(packageName: String): Boolean = SKIPPED_PREFIXES.any {
        packageName == it || packageName.startsWith("$it.")
    }

    fun matchesKnownPrefix(name: String): Boolean = name.matches(CHINA_PACKAGE_REGEX)

    /** Normalizes a dex type descriptor such as `Lcom/tencent/Foo$Bar;`. */
    fun classNameOf(descriptor: String): String = descriptor
        .removeSurrounding("L", ";")
        .replace('/', '.')
        .replace('$', '.')

    private val SKIPPED_PREFIXES = listOf(
        "com.google",
        "com.android.chrome",
        "com.android.vending",
        "com.microsoft",
        "com.apple",
        "com.zhiliaoapp.musically",
        // Caught by the loose "com.mx" prefix, which targets Maxthon's
        // com.mx.browser. MX Player is unrelated.
        "com.mxtech",
        // Caught by the loose "com.stub" prefix, which targets the
        // com.stub.StubApp packer. StubHub is unrelated.
        "com.stubhub",
    )

    private val CHINA_PACKAGE_REGEX = listOf(
        "com.tencent",
        "com.alibaba",
        "com.umeng",
        "com.qihoo",
        "com.ali",
        "com.alipay",
        "com.amap",
        "com.sina",
        "com.weibo",
        "com.vivo",
        "com.xiaomi",
        "com.huawei",
        "com.taobao",
        "com.secneo",
        "s.h.e.l.l",
        "com.stub",
        "com.kiwisec",
        "com.secshell",
        "com.wrapper",
        "cn.securitystack",
        "com.mogosec",
        "com.secoen",
        "com.netease",
        "com.mx",
        "com.qq.e",
        "com.baidu",
        "com.bytedance",
        "com.bugly",
        "com.miui",
        "com.oppo",
        "com.coloros",
        "com.iqoo",
        "com.meizu",
        "com.gionee",
        "cn.nubia",
        "com.oplus",
        "andes.oplus",
        "com.unionpay",
        "cn.wps",
    ).joinToString("|", prefix = "(", postfix = ").*") { prefix ->
        Regex.escape(prefix)
    }.toRegex()
}
