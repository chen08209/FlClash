import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.library")
}

// Must equal Target.forPlatform("android") in setup_hooks, which writes libclash.so only for the platforms being built.
val coreAbiByPlatform =
    linkedMapOf("android-arm" to "armeabi-v7a", "android-arm64" to "arm64-v8a", "android-x64" to "x86_64")
val coreAbis =
    (rootProject.findProperty("target-platform") as String?)
        ?.split(",")
        ?.map { coreAbiByPlatform[it.trim()] ?: throw GradleException("No Core for Flutter target platform $it") }
        ?: coreAbiByPlatform.values.toList()

android {
    namespace = "com.follow.clash.core"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndkVersion.get()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()

        ndk {
            abiFilters += coreAbis
        }
    }

    externalNativeBuild {
        cmake {
            path("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
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

dependencies {
    implementation(libs.annotation.jvm)
}

// Why prefix matching and mustRunAfter: .agents/architecture.md, "Android Native Task Ordering".
val nativeTaskPattern =
    Regex("^(configureCMake|buildCMake|externalNativeBuild|merge.*(NativeLibs|JniLibFolders)|copy.*JniLibs)")
val flutterCompileTasks =
    rootProject.project(":app").tasks.matching { it.name.startsWith("compileFlutterBuild") }

tasks.matching { nativeTaskPattern.containsMatchIn(it.name) }.configureEach {
    mustRunAfter(flutterCompileTasks)
}

gradle.taskGraph.whenReady {
    val nativeTask =
        allTasks.firstOrNull {
            it.path.startsWith("${project.path}:") && nativeTaskPattern.containsMatchIn(it.name)
        }
    if (nativeTask == null || allTasks.any { it.path.startsWith(":app:compileFlutterBuild") }) {
        return@whenReady
    }
    val missing =
        coreAbis
            .flatMap {
                listOf(file("src/main/jniLibs/$it/libclash.so"), file("src/main/cpp/includes/$it/libclash.h"))
            }.filterNot { it.isFile }
    if (missing.isNotEmpty()) {
        throw GradleException(
            "${nativeTask.name} consumes Core artifacts that the setup build hook writes into src/main, " +
                "and these are absent: ${missing.joinToString { it.relativeTo(projectDir).path }}. " +
                "Run `dart setup.dart android` once, or build through :app so the hook runs first.",
        )
    }
    logger.warn(
        ":core: ${nativeTask.name} is running without an :app Flutter compile task, " +
            "so the Core artifacts under src/main are whatever the last hook run left behind",
    )
}
