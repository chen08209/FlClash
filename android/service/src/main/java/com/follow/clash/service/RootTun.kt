package com.follow.clash.service

import android.content.Context
import android.content.SharedPreferences
import android.net.LocalServerSocket
import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.os.ParcelFileDescriptor
import android.system.Os
import java.io.File
import java.io.FileDescriptor
import java.io.IOException
import java.io.InputStream
import java.security.SecureRandom
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong
import kotlin.concurrent.thread

class RootTunUnavailable(message: String) : Exception(message)

// `libtun.so` keeps the device's routes only while this connection is open, so a dead app leaves none.
class RootTun private constructor(
    private val socket: LocalSocket,
    private val process: Process,
    private val prefs: SharedPreferences,
    val fd: Int,
) : AutoCloseable {
    private val closed = AtomicBoolean(false)
    private val nextId = AtomicLong(1)
    private val pending = ConcurrentHashMap<Long, CompletableFuture<Int>>()
    private val writeLock = Any()

    fun watch(onLost: (String) -> Unit) = thread(name = "RootTun", isDaemon = true) {
        val error = runCatching {
            val input = socket.inputStream.bufferedReader()
            while (true) {
                val line = input.readLine() ?: break
                val fields = line.split(' ')
                if (fields.size == 3 && fields[0] == "uid") {
                    val id = fields[1].toLongOrNull() ?: continue
                    pending.remove(id)?.complete(fields[2].toIntOrNull() ?: -1)
                }
            }
        }.exceptionOrNull()
        pending.values.forEach { it.complete(-1) }
        pending.clear()
        if (closed.compareAndSet(false, true)) {
            release()
            onLost(error?.message ?: "the root helper exited")
        }
    }

    fun resolveUid(protocol: Int, source: String): Int {
        if (closed.get()) return -1
        val id = nextId.getAndIncrement()
        val answer = CompletableFuture<Int>()
        pending[id] = answer
        return try {
            synchronized(writeLock) {
                socket.outputStream.write("uid $id $protocol $source\n".toByteArray())
            }
            answer.get(UID_TIMEOUT_MILLIS, TimeUnit.MILLISECONDS)
        } catch (_: Exception) {
            -1
        } finally {
            pending.remove(id)
        }
    }

    override fun close() {
        if (closed.compareAndSet(false, true)) {
            release()
            prefs.edit().putBoolean(MAY_LEAVE_RULES, false).apply()
        }
    }

    private fun release() {
        runCatching { socket.shutdownInput() }
        runCatching { socket.close() }
        process.destroy()
    }

    companion object {
        private const val EXECUTABLE = "libtun.so"
        private const val PREFS = "root_tun"
        private const val MAY_LEAVE_RULES = "may_leave_rules"
        private const val UID_TIMEOUT_MILLIS = 1_000L

        // Long enough for the user to answer the root manager's prompt.
        private const val CONNECT_TIMEOUT_MILLIS = 30_000L

        fun suPath(): File? = (System.getenv("PATH").orEmpty().split(':') + listOf("/system/xbin", "/sbin"))
            .filter { it.isNotEmpty() }
            .map { File(it, "su") }
            .firstOrNull { it.exists() }

        private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        // A helper killed before its release leaves its rules until the next root run or a reboot; a run
        // without root mode clears them itself, but only where root was granted, so it never prompts.
        fun clearLeftovers(context: Context) {
            val prefs = prefs(context)
            if (!prefs.getBoolean(MAY_LEAVE_RULES, false)) return
            val su = suPath() ?: return
            val executable = File(context.applicationInfo.nativeLibraryDir, EXECUTABLE)
            thread(name = "RootTun clean", isDaemon = true) {
                val cleaned = runCatching {
                    val process = ProcessBuilder(su.path, "-c", "exec ${executable.path} --clean")
                        .redirectErrorStream(true)
                        .start()
                    process.outputStream.close()
                    process.inputStream.readBytes()
                    process.waitFor() == 0
                }.getOrDefault(false)
                if (cleaned) {
                    prefs.edit().putBoolean(MAY_LEAVE_RULES, false).apply()
                }
            }
        }

        /** [request] is the JSON `concord_tun_provision` reads. */
        fun open(context: Context, request: String): RootTun {
            val su = suPath() ?: throw RootTunUnavailable("su not found")
            val executable = File(context.applicationInfo.nativeLibraryDir, EXECUTABLE)
            if (!executable.canExecute()) {
                throw RootTunUnavailable("${executable.path} is not executable")
            }
            val name = "${context.packageName}.tun." + ByteArray(16).also(SecureRandom()::nextBytes)
                .joinToString("") { "%02x".format(it) }
            val server = LocalServerSocket(name)
            val process = try {
                ProcessBuilder(su.path, "-c", "exec ${executable.path} $name")
                    .redirectErrorStream(true)
                    .start()
            } catch (error: IOException) {
                server.close()
                throw RootTunUnavailable("su: ${error.message}")
            }
            process.outputStream.close()
            val output = StringBuilder()
            thread(name = "RootTun su", isDaemon = true) {
                runCatching {
                    process.inputStream.bufferedReader().forEachLine { line ->
                        synchronized(output) { if (output.length < 512) output.appendLine(line) }
                    }
                }
            }
            val accepted = AtomicBoolean(false)
            // LocalServerSocket.close() does not wake a blocked accept(); a connection does.
            val giveUp = {
                if (!accepted.get()) {
                    runCatching { LocalSocket().connect(LocalSocketAddress(name)) }
                }
            }
            thread(name = "RootTun exit", isDaemon = true) {
                runCatching { process.waitFor() }
                giveUp()
            }
            thread(name = "RootTun timeout", isDaemon = true) {
                Thread.sleep(CONNECT_TIMEOUT_MILLIS)
                giveUp()
            }
            val socket = try {
                server.accept()
            } finally {
                accepted.set(true)
                server.close()
            }
            val reason = {
                val exit = runCatching { process.exitValue() }.getOrNull()
                val said = synchronized(output) { output.toString().trim() }
                when {
                    said.isNotEmpty() -> said
                    exit != null -> "su exited with $exit"
                    else -> "su did not answer"
                }
            }
            if (socket.peerCredentials.uid != 0) {
                socket.close()
                process.destroy()
                throw RootTunUnavailable(reason())
            }
            try {
                socket.soTimeout = CONNECT_TIMEOUT_MILLIS.toInt()
                socket.outputStream.write((request.replace('\n', ' ') + "\n").toByteArray())
                val (line, descriptors) = readFirstLine(socket)
                if (line != "ok" || descriptors.isEmpty()) {
                    descriptors.forEach { runCatching { Os.close(it) } }
                    throw RootTunUnavailable(line.removePrefix("err ").ifEmpty { reason() })
                }
                val fd = ParcelFileDescriptor.dup(descriptors[0]).detachFd()
                descriptors.forEach { runCatching { Os.close(it) } }
                socket.soTimeout = 0
                val prefs = prefs(context)
                prefs.edit().putBoolean(MAY_LEAVE_RULES, true).apply()
                return RootTun(socket, process, prefs, fd)
            } catch (error: Exception) {
                socket.close()
                process.destroy()
                throw error as? RootTunUnavailable ?: RootTunUnavailable(error.message ?: reason())
            }
        }

        // The descriptor arrives with the first bytes of the reply, so they are read unbuffered.
        private fun readFirstLine(socket: LocalSocket): Pair<String, Array<FileDescriptor>> {
            val input: InputStream = socket.inputStream
            val bytes = StringBuilder()
            var descriptors = emptyArray<FileDescriptor>()
            while (true) {
                val byte = input.read()
                socket.ancillaryFileDescriptors?.let { descriptors += it }
                if (byte < 0 || byte == '\n'.code) break
                bytes.append(byte.toChar())
            }
            return bytes.toString() to descriptors
        }
    }
}
