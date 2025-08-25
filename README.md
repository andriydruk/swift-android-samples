# Swift Android Samples

[![macOS](https://github.com/andriydruk/swift-android-samples/actions/workflows/mac.yml/badge.svg)](https://github.com/andriydruk/swift-android-samples/actions/workflows/mac.yml)
[![Linux](https://github.com/andriydruk/swift-android-samples/actions/workflows/linux.yml/badge.svg)](https://github.com/andriydruk/swift-android-samples/actions/workflows/linux.yml)
[![Swift](https://img.shields.io/badge/swift-6.2%20snapshot-orange)](https://github.com/swift-android-sdk/swift-android-sdk/releases/tag/6.2-DEVELOPMENT-SNAPSHOT-2025-08-14-a-22-g49dbb15f5f7)
[![Android API](https://img.shields.io/badge/Android%20API-29+-green)](https://developer.android.com/about/versions/10)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

This repository contains sample apps that use the [Swift Android SDK](https://github.com/swift-android-sdk/swift-android-sdk/releases/tag/6.2-DEVELOPMENT-SNAPSHOT-2025-08-14-a-22-g49dbb15f5f7).

# Build and run

1. Setup Swift Android SDK
2. Clone this repository
3. Open the whole project in Android Studio
4. Select the sample you want to run in the top bar (you may need to sync gradle first)
5. Click the play button to run the sample


You can also build the samples from the command line if you prefer. Use `./gradlew` build to build everything. For individual tasks, see `./gradlew tasks`. To see the tasks for an individual sample, run the tasks task for that directory. For example, `./gradlew :hello-swift:tasks` will show the tasks for the hello-swift app.

You can build all sample apps for both the debug and release build types by running `./gradlew assemble`.
