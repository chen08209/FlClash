import com.android.build.gradle.tasks.MergeSourceSetFolders

plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.follow.clash.core"
    compileSdk = 35
    ndkVersion = "28.0.13004108"

    defaultConfig {
        minSdk = 21
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }

    externalNativeBuild {
        cmake {
            path("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

tasks.register<Copy>("copyNativeLibs") {
    doFirst {
        delete("src/main/jniLibs")
    }
    from("../../libclash/android")
    into("src/main/jniLibs")
}

tasks.withType<MergeSourceSetFolders>().configureEach {
    dependsOn("copyNativeLibs")
}

afterEvaluate {
    tasks.named("assembleDebug").configure {
        dependsOn("copyNativeLibs")
    }
    tasks.named("assembleRelease").configure {
        dependsOn("copyNativeLibs")
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.16.0")
}