package dev.swiftandroid.library

class SwiftLibrary {

    external fun stringFromSwift(): String

    companion object {
        init {
            System.loadLibrary("hello-swift-library")
        }
    }
}