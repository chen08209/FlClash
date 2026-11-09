package com.follow.clash

import android.content.Context
import java.io.File
import java.io.IOException
import java.security.KeyStore
import java.security.MessageDigest
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

// Installs a root manager module, mounted at every boot, and mounts the same
// copy at once for the running apps: assets/mitm_ca.
object SystemCaStore {
    private const val ASSETS = "mitm_ca"
    private const val GRANTED = "FLCLASH_ROOT_GRANTED"
    private const val UNMANAGED = 3
    private const val PREFERENCES = "root"
    private const val ROOT_GRANTED = "granted"

    private val moduleEntries = mapOf(
        "module.prop" to "module.prop",
        "post-fs-data.sh" to "post-fs-data.sh",
        "service.sh" to "service.sh",
        "inject.sh" to "inject.sh",
        "update-binary" to "META-INF/com/google/android/update-binary",
        "updater-script" to "META-INF/com/google/android/updater-script",
    )

    fun locate(der: ByteArray): Map<String, Boolean> {
        val certificate = parse(der)
        val store = KeyStore.getInstance("AndroidCAStore").apply { load(null) }
        val hash = subjectHash(certificate)
        val system = generateSequence(0) { it + 1 }
            .map { store.getCertificate("system:$hash.$it") }
            .takeWhile { it != null }
            .any { it == certificate }
        return mapOf(
            "user" to (store.getCertificateAlias(certificate)?.startsWith("user:") == true),
            "system" to system,
            "root" to rootAvailable(),
        )
    }

    /** "installed", "untilReboot" when no root manager took the module, or "denied". */
    fun install(context: Context, der: ByteArray): String {
        return withScripts(context, der) { work, cert ->
            val zip = File(work, "module.zip")
            ZipOutputStream(zip.outputStream()).use { out ->
                moduleEntries.forEach { (asset, entry) ->
                    out.putNextEntry(ZipEntry(entry))
                    File(work, asset).inputStream().use { it.copyTo(out) }
                }
                out.putNextEntry(ZipEntry("cacert/${cert.name}"))
                out.write(der)
            }
            when (runAsRoot(context, work, "install", zip.path, cert.path)) {
                null -> "denied"
                UNMANAGED -> "untilReboot"
                else -> "installed"
            }
        }
    }

    fun remove(context: Context, der: ByteArray): Boolean {
        return withScripts(context, der) { work, cert ->
            runAsRoot(context, work, "remove", cert.path) != null
        }
    }

    // Asking su would prompt for root, so the answer to the last request stands
    // in for it until the next one.
    fun hasRootAccess(context: Context): Boolean {
        return rootAvailable() && preferences(context).getBoolean(ROOT_GRANTED, false)
    }

    private fun preferences(context: Context) =
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    private fun rootAvailable(): Boolean {
        val directories = System.getenv("PATH").orEmpty().split(':') + listOf("/system/xbin", "/sbin")
        return directories.any { it.isNotEmpty() && File(it, "su").exists() }
    }

    private fun parse(der: ByteArray): X509Certificate {
        return CertificateFactory.getInstance("X.509")
            .generateCertificate(der.inputStream()) as X509Certificate
    }

    // OpenSSL's X509_NAME_hash_old, which names the files of Android's stores.
    private fun subjectHash(certificate: X509Certificate): String {
        val digest = MessageDigest.getInstance("MD5")
            .digest(certificate.subjectX500Principal.encoded)
        return "%02x%02x%02x%02x".format(digest[3], digest[2], digest[1], digest[0])
    }

    private fun <T> withScripts(
        context: Context,
        der: ByteArray,
        block: (work: File, cert: File) -> T,
    ): T {
        val work = File(context.cacheDir, ASSETS)
        work.deleteRecursively()
        work.mkdirs()
        try {
            context.assets.list(ASSETS).orEmpty().forEach { name ->
                context.assets.open("$ASSETS/$name").use { input ->
                    File(work, name).outputStream().use { input.copyTo(it) }
                }
            }
            val cert = File(work, "${subjectHash(parse(der))}.0").apply { writeBytes(der) }
            return block(work, cert)
        } finally {
            work.deleteRecursively()
        }
    }

    private fun runAsRoot(context: Context, work: File, vararg arguments: String): Int? {
        val process = ProcessBuilder("su").redirectErrorStream(true).start()
        val command = listOf("exec", "/system/bin/sh", File(work, "root.sh").path) + arguments
        process.outputStream.bufferedWriter().use { writer ->
            writer.write("echo $GRANTED\n")
            writer.write(command.joinToString(" ") { "'$it'" } + "\n")
        }
        val output = process.inputStream.bufferedReader().readText()
        val code = process.waitFor()
        val granted = output.contains(GRANTED)
        preferences(context).edit().putBoolean(ROOT_GRANTED, granted).apply()
        return when {
            !granted -> null
            code == 0 || code == UNMANAGED -> code
            else -> throw IOException("su exited with $code: ${output.takeLast(2000).trim()}")
        }
    }
}
