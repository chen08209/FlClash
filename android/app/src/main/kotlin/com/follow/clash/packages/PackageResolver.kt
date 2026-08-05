package com.follow.clash.packages

import android.Manifest
import android.content.pm.ApplicationInfo
import android.content.pm.ComponentInfo
import android.content.pm.PackageManager
import android.os.Build
import com.android.tools.smali.dexlib2.dexbacked.DexBackedDexFile
import com.follow.clash.models.InstalledPackage
import java.io.File
import java.util.zip.ZipFile

internal class PackageResolver(
    private val packageManager: PackageManager,
    private val appPackageName: String,
) {
    val installedPackages: List<InstalledPackage> by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
        loadPackages()
    }

    fun getChinaPackageNames(): List<String> = installedPackages
        .map { it.packageName }
        .filter(::isChinaPackage)

    private fun loadPackages(): List<InstalledPackage> {
        val flags = PackageManager.GET_PERMISSIONS
        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getInstalledPackages(
                PackageManager.PackageInfoFlags.of(flags.toLong()),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstalledPackages(flags)
        }
        return packages.asSequence()
            .filter { info ->
                info.packageName != appPackageName && info.packageName != ANDROID_PACKAGE_NAME
            }
            .map { info ->
                InstalledPackage(
                    packageName = info.packageName,
                    label = info.applicationInfo?.loadLabel(packageManager)?.toString()
                        ?: info.packageName,
                    system = info.applicationInfo?.let { applicationInfo ->
                        applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0
                    } == true,
                    internet = info.requestedPermissions
                        ?.contains(Manifest.permission.INTERNET) == true,
                    lastUpdateTime = info.lastUpdateTime,
                )
            }.toList()
    }

    private fun isChinaPackage(packageName: String): Boolean {
        if (SKIPPED_PREFIXES.any { packageName == it || packageName.startsWith("$it.") }) {
            return false
        }
        if (packageName.matches(CHINA_PACKAGE_REGEX)) {
            return true
        }

        return runCatching {
            val packageInfo = getPackageInfo(packageName)
            packageInfo.componentNames().any { it.matches(CHINA_PACKAGE_REGEX) } ||
                packageInfo.applicationInfo?.publicSourceDir?.let(::scanArchive) == true
        }.getOrDefault(false)
    }

    private fun getPackageInfo(packageName: String) = if (
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
    ) {
        packageManager.getPackageInfo(
            packageName,
            PackageManager.PackageInfoFlags.of(PACKAGE_INFO_FLAGS.toLong()),
        )
    } else {
        @Suppress("DEPRECATION")
        packageManager.getPackageInfo(packageName, PACKAGE_INFO_FLAGS)
    }

    private fun android.content.pm.PackageInfo.componentNames(): Sequence<String> = sequence {
        yieldAll(services.orEmpty().asSequence().map(ComponentInfo::name))
        yieldAll(activities.orEmpty().asSequence().map(ComponentInfo::name))
        yieldAll(receivers.orEmpty().asSequence().map(ComponentInfo::name))
        yieldAll(providers.orEmpty().asSequence().map(ComponentInfo::name))
    }

    private fun scanArchive(sourcePath: String): Boolean = ZipFile(File(sourcePath)).use { archive ->
        if (archive.entries().asSequence().any { it.name.startsWith("firebase-") }) {
            return false
        }
        archive.entries().asSequence()
            .filter { entry ->
                entry.name.startsWith("classes") && entry.name.endsWith(".dex")
            }.any { entry ->
                if (entry.size > MAX_DEX_SIZE_BYTES) {
                    return@any true
                }
                val dexFile = archive.getInputStream(entry).buffered().use { input ->
                    DexBackedDexFile.fromInputStream(null, input)
                }
                dexFile.classes.any { clazz ->
                    clazz.type
                        .removeSurrounding("L", ";")
                        .replace('/', '.')
                        .replace('$', '.')
                        .matches(CHINA_PACKAGE_REGEX)
                }
            }
    }

    private companion object {
        const val ANDROID_PACKAGE_NAME = "android"
        const val MAX_DEX_SIZE_BYTES = 15_000_000L

        val PACKAGE_INFO_FLAGS = PackageManager.GET_ACTIVITIES or
            PackageManager.GET_SERVICES or
            PackageManager.GET_RECEIVERS or
            PackageManager.GET_PROVIDERS

        val SKIPPED_PREFIXES = listOf(
            "com.google",
            "com.android.chrome",
            "com.android.vending",
            "com.microsoft",
            "com.apple",
            "com.zhiliaoapp.musically",
        )

        val CHINA_PACKAGE_REGEX = listOf(
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
}
