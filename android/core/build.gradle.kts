import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.ByteArrayOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import javax.inject.Inject

plugins {
    id("com.android.library")
}

android {
    namespace = "com.follow.clash.core"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndkVersion.get()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
        consumerProguardFiles("consumer-rules.pro")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

val gomobileTargetByPlatform =
    linkedMapOf("android-arm" to "android/arm", "android-arm64" to "android/arm64", "android-x64" to "android/amd64")
val gomobileTargets =
    (rootProject.findProperty("target-platform") as String?)
        ?.split(",")
        ?.map { gomobileTargetByPlatform[it.trim()] ?: throw GradleException("No Core for Flutter target platform $it") }
        ?: gomobileTargetByPlatform.values.toList()

val isWindows = System.getProperty("os.name").startsWith("Windows")

// Gradle started from Android Studio sees the PATH of the GUI session, which leaves out Homebrew and the Go installer.
val goExecutablePath =
    providers.provider {
        val name = if (isWindows) "go.exe" else "go"
        val home = System.getProperty("user.home")
        val searchPath =
            System.getenv("PATH").orEmpty().split(File.pathSeparator) +
                listOf("/opt/homebrew/bin", "/usr/local/bin", "/usr/local/go/bin", "$home/go/bin")
        searchPath
            .filter { it.isNotEmpty() }
            .map { File(it, name) }
            .firstOrNull { it.canExecute() }
            ?.path
            ?: throw GradleException("The Android Core is built with gomobile, which needs Go on PATH")
    }

val goModule = rootProject.layout.projectDirectory.dir("../core")

// gomobile names the library gojni, both as the file it builds and in go.Seq's System.loadLibrary, and has no option to change it.
val coreLibraryName = "clash"
val concordLibraryName = "concord"

val buildConfig =
    providers.fileContents(rootProject.layout.projectDirectory.file("../build_config.yaml")).asText.map { text ->
        text.lines()
            .mapNotNull { Regex("""^(\w+):\s*(.*?)\s*$""").find(it)?.destructured }
            .associate { (key, value) -> key to value.trim('"', '\'') }
    }

val coreImpl = buildConfig.map { it["core_impl"] ?: "go" }.get()

class CargoAbi(
    val triple: String,
    val abi: String,
    val clangPrefix: String,
)

val cargoAbiByPlatform =
    linkedMapOf(
        "android-arm" to CargoAbi("armv7-linux-androideabi", "armeabi-v7a", "armv7a-linux-androideabi"),
        "android-arm64" to CargoAbi("aarch64-linux-android", "arm64-v8a", "aarch64-linux-android"),
        "android-x64" to CargoAbi("x86_64-linux-android", "x86_64", "x86_64-linux-android"),
    )

val cargoAbis =
    (rootProject.findProperty("target-platform") as String?)
        ?.split(",")
        ?.map { cargoAbiByPlatform[it.trim()] ?: throw GradleException("No Core for Flutter target platform $it") }
        ?: cargoAbiByPlatform.values.toList()

val cargoExecutablePath =
    providers.provider {
        val name = if (isWindows) "cargo.exe" else "cargo"
        val home = System.getProperty("user.home")
        val searchPath =
            System.getenv("PATH").orEmpty().split(File.pathSeparator) +
                listOf("$home/.cargo/bin", "/opt/homebrew/bin", "/usr/local/bin")
        searchPath
            .filter { it.isNotEmpty() }
            .map { File(it, name) }
            .firstOrNull { it.canExecute() }
            ?.path
            ?: throw GradleException("The Android Core is built with cargo, which needs Rust on PATH")
    }

abstract class CargoBuild : DefaultTask() {
    @get:Inject
    abstract val execOperations: ExecOperations

    @get:InputFiles
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val sources: ConfigurableFileCollection

    @get:Internal
    abstract val workspace: DirectoryProperty

    @get:Internal
    abstract val cargoExecutable: Property<String>

    @get:Input
    abstract val triples: ListProperty<String>

    @get:Input
    abstract val abis: ListProperty<String>

    @get:Input
    abstract val clangPrefixes: ListProperty<String>

    @get:Input
    abstract val androidApi: Property<Int>

    @get:Internal
    abstract val ndkDirectory: DirectoryProperty

    @get:Input
    abstract val ndkVersion: Property<String>

    @get:Input
    abstract val libraryName: Property<String>

    @get:OutputDirectory
    abstract val outputDirectory: DirectoryProperty

    @TaskAction
    fun build() {
        val ndk = ndkDirectory.get().asFile
        val host =
            ndk.resolve("toolchains/llvm/prebuilt").listFiles()?.firstOrNull { it.isDirectory }
                ?: throw GradleException("The NDK at $ndk has no prebuilt toolchain")
        val bin = host.resolve("bin")
        val api = androidApi.get()
        val output = outputDirectory.get().asFile
        output.deleteRecursively()
        triples.get().indices.forEach { index ->
            val triple = triples.get()[index]
            val abi = abis.get()[index]
            val underscored = triple.replace('-', '_')
            val clang = bin.resolve("${clangPrefixes.get()[index]}$api-clang").path
            // boring-sys assembles its own Android CMake arguments, which recent CMake rejects at link time,
            // and it honours a toolchain file instead.
            val toolchain = temporaryDir.resolve("$abi.toolchain.cmake")
            toolchain.writeText(
                """
                set(ANDROID_ABI "$abi")
                set(ANDROID_PLATFORM "android-$api")
                include("${ndk.resolve("build/cmake/android.toolchain.cmake").path.replace('\\', '/')}")
                """.trimIndent(),
            )
            execOperations.exec {
                workingDir(workspace)
                environment("ANDROID_NDK_HOME", ndk.path)
                environment("ANDROID_NDK_ROOT", ndk.path)
                environment("CC_$underscored", clang)
                environment("CXX_$underscored", "$clang++")
                environment("AR_$underscored", bin.resolve("llvm-ar").path)
                environment("CARGO_TARGET_${underscored.uppercase()}_LINKER", clang)
                environment("CMAKE_TOOLCHAIN_FILE_$underscored", toolchain.path)
                // bindgen runs the host's libclang, which does not know the NDK sysroot.
                environment(
                    "BINDGEN_EXTRA_CLANG_ARGS_$underscored",
                    "--sysroot=${host.resolve("sysroot").path} --target=${clangPrefixes.get()[index]}$api",
                )
                // The APK ships no libc++_shared.so for boring-sys to load.
                environment("BORING_BSSL_RUST_CPPLIB", "c++_static")
                commandLine(cargoExecutable.get(), "build", "--release", "--locked", "--target", triple, "-p", "concord-android")
            }
            val library = "lib${libraryName.get()}.so"
            val built = workspace.get().asFile.resolve("target/$triple/release/$library")
            built.copyTo(output.resolve("$abi/$library"), overwrite = true)
        }
    }
}

abstract class GomobileBind : DefaultTask() {
    @get:Inject
    abstract val execOperations: ExecOperations

    @get:InputFiles
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val sources: ConfigurableFileCollection

    @get:Internal
    abstract val moduleDirectory: DirectoryProperty

    @get:Internal
    abstract val goExecutable: Property<String>

    @get:Input
    abstract val goVersion: Property<String>

    @get:Input
    abstract val targets: ListProperty<String>

    @get:Input
    abstract val androidApi: Property<Int>

    @get:Input
    abstract val tags: Property<String>

    @get:Input
    abstract val ldflags: Property<String>

    @get:Internal
    abstract val sdkDirectory: DirectoryProperty

    @get:Internal
    abstract val ndkDirectory: DirectoryProperty

    @get:Input
    abstract val ndkVersion: Property<String>

    @get:Input
    abstract val libraryName: Property<String>

    @get:OutputFile
    abstract val aar: RegularFileProperty

    @get:OutputFile
    abstract val classesJar: RegularFileProperty

    @TaskAction
    fun bind() {
        val go = goExecutable.get()
        val tools = temporaryDir.resolve("bin")
        val executableSuffix = if (System.getProperty("os.name").startsWith("Windows")) ".exe" else ""
        tools.mkdirs()
        val path =
            listOf(tools, File(System.getProperty("java.home"), "bin"), File(go).parentFile)
                .joinToString(File.pathSeparator) { it.path } + File.pathSeparator + System.getenv("PATH").orEmpty()
        execOperations.exec {
            workingDir(moduleDirectory)
            environment("PATH", path)
            commandLine(go, "build", "-o", tools.path + File.separator, "golang.org/x/mobile/cmd/gomobile", "golang.org/x/mobile/cmd/gobind")
        }
        // gomobile links the library as the main package of a module it generates, whose go line is the toolchain's,
        // so the GODEBUG defaults that the go line of core/go.mod sets for the desktop Core would not reach it on their own.
        val godebug = ByteArrayOutputStream()
        execOperations.exec {
            workingDir(moduleDirectory)
            environment("PATH", path)
            commandLine(go, "list", "-f", "{{.DefaultGODEBUG}}", "./cmd/core")
            standardOutput = godebug
        }
        execOperations.exec {
            workingDir(moduleDirectory)
            environment("PATH", path)
            environment("ANDROID_HOME", sdkDirectory.get().asFile.path)
            environment("ANDROID_NDK_HOME", ndkDirectory.get().asFile.path)
            commandLine(
                tools.resolve("gomobile$executableSuffix").path,
                "bind",
                "-trimpath",
                "-target=${targets.get().joinToString(",")}",
                "-androidapi=${androidApi.get()}",
                "-javapkg=com.follow.clash.core",
                "-tags=${tags.get()}",
                "-ldflags=${ldflags.get()} -X=runtime.godebugDefault=${godebug.toString().trim()}",
                "-o",
                aar.get().asFile.path,
                "./mobile",
            )
        }
        ZipFile(aar.get().asFile).use { aarFile ->
            ZipInputStream(aarFile.getInputStream(aarFile.getEntry("classes.jar"))).use { jar ->
                ZipOutputStream(classesJar.get().asFile.outputStream()).use { out ->
                    var seqPatched = false
                    generateSequence { jar.nextEntry }.forEach { entry ->
                        var bytes = jar.readBytes()
                        if (entry.name == "go/Seq.class") {
                            bytes = bytes.replaceUtf8Constant("gojni", libraryName.get())
                            seqPatched = true
                        }
                        out.putNextEntry(ZipEntry(entry.name).apply { time = entry.time })
                        out.write(bytes)
                    }
                    if (!seqPatched) throw GradleException("gomobile's classes.jar has no go/Seq.class to load lib${libraryName.get()}.so")
                }
            }
        }
    }

    private fun ByteArray.replaceUtf8Constant(old: String, new: String): ByteArray {
        fun constant(value: String) = value.toByteArray().let { byteArrayOf(1, (it.size shr 8).toByte(), it.size.toByte()) + it }
        val target = constant(old)
        val matches = (0..size - target.size).filter { start -> target.indices.all { this[start + it] == target[it] } }
        if (matches.size != 1) throw GradleException("Expected one \"$old\" constant in go/Seq.class, found ${matches.size}")
        val start = matches.single()
        return copyOfRange(0, start) + constant(new) + copyOfRange(start + target.size, size)
    }
}

abstract class UnpackJniLibs : DefaultTask() {
    @get:Inject
    abstract val archiveOperations: ArchiveOperations

    @get:Inject
    abstract val fileSystemOperations: FileSystemOperations

    @get:InputFile
    @get:PathSensitive(PathSensitivity.NONE)
    abstract val aar: RegularFileProperty

    @get:Input
    abstract val libraryName: Property<String>

    @get:OutputDirectory
    abstract val outputDirectory: DirectoryProperty

    @TaskAction
    fun unpack() {
        var renamed = 0
        fileSystemOperations.sync {
            from(archiveOperations.zipTree(aar)) {
                include("jni/**")
                eachFile {
                    path = path.removePrefix("jni/")
                    if (name == "libgojni.so") {
                        name = "lib${libraryName.get()}.so"
                        renamed++
                    }
                }
                includeEmptyDirs = false
            }
            into(outputDirectory)
        }
        if (renamed == 0) throw GradleException("gomobile's AAR has no libgojni.so to rename")
    }
}

val cargoCore =
    tasks.register<CargoBuild>("cargoCore") {
        val concordWorkspace =
            buildConfig.map { config ->
                rootProject.layout.projectDirectory.dir("..").asFile.resolve(config["concord_dir"] ?: "concord")
            }
        sources.from(concordWorkspace.map { fileTree(it) { exclude("target/**") } })
        workspace.set(layout.dir(concordWorkspace))
        cargoExecutable.set(cargoExecutablePath)
        triples.set(cargoAbis.map { it.triple })
        abis.set(cargoAbis.map { it.abi })
        clangPrefixes.set(cargoAbis.map { it.clangPrefix })
        androidApi.set(libs.versions.minSdk.get().toInt())
        ndkDirectory.set(androidComponents.sdkComponents.ndkDirectory)
        ndkVersion.set(libs.versions.ndkVersion)
        libraryName.set(concordLibraryName)
        outputDirectory.set(layout.buildDirectory.dir("cargo/jniLibs"))
    }

val bindCore =
    tasks.register<GomobileBind>("bindCore") {
        sources.from(
            fileTree(goModule) {
                exclude("**/*_test.go", "**/testdata/**", "cmd/**", "Clash.Meta/.github/**")
            },
        )
        moduleDirectory.set(goModule)
        goExecutable.set(goExecutablePath)
        goVersion.set(
            goExecutablePath
                .flatMap { go -> providers.exec { commandLine(go, "env", "GOVERSION") }.standardOutput.asText }
                .map { it.trim() },
        )
        targets.set(gomobileTargets)
        androidApi.set(libs.versions.minSdk.get().toInt())
        tags.set(buildConfig.map { it["tags"].orEmpty() })
        ldflags.set(
            buildConfig.map { config ->
                val flags = config["go_ldflags"].orEmpty().split(" ").filter { it.isNotEmpty() }
                val version = config["core_version"].orEmpty()
                (flags + listOfNotNull(version.takeIf { it.isNotEmpty() }?.let { "-X=github.com/metacubex/mihomo/constant.Version=$it" }))
                    .joinToString(" ")
            },
        )
        sdkDirectory.set(androidComponents.sdkComponents.sdkDirectory)
        ndkDirectory.set(androidComponents.sdkComponents.ndkDirectory)
        ndkVersion.set(libs.versions.ndkVersion)
        libraryName.set(coreLibraryName)
        aar.set(layout.buildDirectory.file("gomobile/core.aar"))
        classesJar.set(layout.buildDirectory.file("gomobile/classes.jar"))
    }

// A library cannot bundle a local AAR into its own, so the gomobile AAR reaches AGP as a classes jar and generated jniLibs.
androidComponents {
    onVariants { variant ->
        if (coreImpl == "concord") {
            variant.sources.java?.addStaticSourceDirectory("src/concord/java")
            variant.sources.jniLibs?.addGeneratedSourceDirectory(cargoCore, CargoBuild::outputDirectory)
            return@onVariants
        }
        val unpack =
            tasks.register<UnpackJniLibs>("unpack${variant.name.replaceFirstChar { it.uppercase() }}CoreJniLibs") {
                aar.set(bindCore.flatMap { it.aar })
                libraryName.set(coreLibraryName)
            }
        variant.sources.jniLibs?.addGeneratedSourceDirectory(unpack, UnpackJniLibs::outputDirectory)
    }
}

dependencies {
    if (coreImpl != "concord") {
        implementation(files(bindCore.flatMap { it.classesJar }))
    }
}
