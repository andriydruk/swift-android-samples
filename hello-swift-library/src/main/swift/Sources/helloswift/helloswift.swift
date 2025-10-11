import Android

@_silgen_name("Java_dev_swiftandroid_library_SwiftLibrary_stringFromSwift")
public func SwiftLibrary_stringFromSwift(env: UnsafeMutablePointer<JNIEnv?>, clazz: jclass) -> jstring {
    let hello = "Hello from Swift"
    return hello.withCString { ptr in
    	env.pointee!.pointee.NewStringUTF(env, ptr)!
    }
}