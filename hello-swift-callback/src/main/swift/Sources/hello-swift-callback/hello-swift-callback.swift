import Android
import Foundation
import Dispatch

private var gJavaVM: UnsafeMutablePointer<JavaVM?>?

@_cdecl("JNI_OnLoad")
public func JNI_OnLoad(vm: UnsafeMutablePointer<JavaVM?>, reserved: UnsafeMutableRawPointer?) -> jint {
    gJavaVM = vm
    return jint(JNI_VERSION_1_6)
}

let queue = DispatchQueue(label: "hello-swift-callback")
var workItem: DispatchWorkItem? = nil
var activityRef: jobject? = nil

private func getEnvForCurrentThread(block: (UnsafeMutablePointer<JNIEnv?>?) -> Void) {
    var env: UnsafeMutablePointer<JNIEnv?>?
    let attachCode = gJavaVM!.pointee!.pointee.AttachCurrentThread(gJavaVM, &env, nil)
    guard attachCode == 0 else { return }
    block(env)
    gJavaVM!.pointee!.pointee.DetachCurrentThread(gJavaVM)
}

@_cdecl("Java_dev_swiftandroid_helloswift_MainActivity_startTicks")
public func MainActivity_startTicks(env: UnsafeMutablePointer<JNIEnv?>, thiz: jobject) {
    guard let globalRef = env.pointee!.pointee.NewGlobalRef(env, thiz) else { return }
    guard let cls = env.pointee!.pointee.GetObjectClass(env, thiz) else { return }
    defer { env.pointee!.pointee.DeleteLocalRef(env, cls) }
    guard let mid = env.pointee!.pointee.GetMethodID(env, cls, "updateTimer", "()V") else { return }

    queue.async {
        workItem?.cancel()
        activityRef = globalRef
        workItem = DispatchWorkItem {
            getEnvForCurrentThread { env in
                env?.pointee!.pointee.CallVoidMethodA(env, activityRef, mid, nil)
            }
            if let workItem = workItem, workItem.isCancelled == false {
                queue.asyncAfter(deadline: .now() + 1, execute: workItem)
            }
        }
        queue.async(execute: workItem!)
    }
}

@_cdecl("Java_dev_swiftandroid_helloswift_MainActivity_stopTicks")
public func MainActivity_stopTicks(env: UnsafeMutablePointer<JNIEnv?>, jthis: jobject) {
    queue.async {
        workItem?.cancel()
        workItem = nil
        if let activityRef = activityRef {
            getEnvForCurrentThread { env in
                env?.pointee!.pointee.DeleteGlobalRef(env, activityRef)
            }
        }
    }
}
