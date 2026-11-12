import org.jetbrains.kotlin.gradle.dsl.JvmTarget
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

    sourceSets {
        // Unit tests live under android/tests/ instead of each module's src/test.
        getByName("test").java.setSrcDirs(listOf("../tests/core"))
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

val isWindows = System.getProperty("os.name").startsWith("Windows")

val concordLibraryName = "concord"

val buildConfig =
    providers.fileContents(rootProject.layout.projectDirectory.file("../build_config.yaml")).asText.map { text ->
        text.lines()
            .mapNotNull { Regex("""^(\w+):\s*(.*?)\s*$""").find(it)?.destructured }
            .associate { (key, value) -> key to value.trim('"', '\'') }
    }

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

androidComponents {
    onVariants { variant ->
        variant.sources.jniLibs?.addGeneratedSourceDirectory(cargoCore, CargoBuild::outputDirectory)
    }
}

dependencies {
    implementation(libs.gson)
    testImplementation(libs.junit)
}
