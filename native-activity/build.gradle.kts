plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

apply(from = "../swift-android.gradle.kts")

android {
    namespace = "dev.swiftandroid.nativeactivity"
    compileSdk = 36

    defaultConfig {
        applicationId = "dev.swiftandroid.nativeactivity"
        minSdk = 29
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        debug {
            isJniDebuggable = true
        }
        release {
            isMinifyEnabled = false
            isJniDebuggable = false
        }
    }
}