import Android
import AndroidNativeAppGlue
import AndroidOpenGL

public struct SavedState {
    public var angle: Float = 0
    public var x: Int32 = 0
    public var y: Int32 = 0
}

public final class Engine {
    public var app: UnsafeMutablePointer<android_app>?

    public var display: EGLDisplay?
    public var surface: EGLSurface?
    public var context: EGLContext?
    public var width: Int32 = 0
    public var height: Int32 = 0
    public var state = SavedState()

    private var running_ = false

    public init(app: UnsafeMutablePointer<android_app>?) {
        self.app = app
    }

    /**
     * Initialize an EGL context for the current display.
     */
    public func initDisplay() -> Int32 {
        guard let win = app?.pointee.window else { return -1 }
        // initialize OpenGL ES and EGL

        /*
         * Here specify the attributes of the desired configuration.
         * Below, we select an EGLConfig with at least 8 bits per color
         * component compatible with on-screen windows
         */
        let attribs: [EGLint] = [
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
            EGL_BLUE_SIZE,    8,
            EGL_GREEN_SIZE,   8,
            EGL_RED_SIZE,     8,
            EGL_NONE
        ]

        let display: EGLDisplay! = eglGetDisplay(nil)
        _ = eglInitialize(display, nil, nil)

        var numConfigs: EGLint = 0
        _ = eglChooseConfig(display, attribs, nil, 0, &numConfigs)
        if numConfigs <= 0 { return -1 }
        let cfgBuf = UnsafeMutablePointer<EGLConfig?>.allocate(capacity: Int(numConfigs))
        defer { cfgBuf.deallocate() }

        /* Here, the application chooses the configuration it desires.
         * find the best match if possible, otherwise use the very first one
         */
        _ = eglChooseConfig(display, attribs, cfgBuf, numConfigs, &numConfigs)

        // Pick the best match: R=G=B=8, DEPTH=0
        var chosen: EGLConfig? = nil
        for i in 0..<Int(numConfigs) {
            guard let cfg = cfgBuf[i] else { continue }
            var r: EGLint = 0, g: EGLint = 0, b: EGLint = 0, d: EGLint = 0
            if eglGetConfigAttrib(display, cfg, EGL_RED_SIZE,   &r) != 0 &&
               eglGetConfigAttrib(display, cfg, EGL_GREEN_SIZE, &g) != 0 &&
               eglGetConfigAttrib(display, cfg, EGL_BLUE_SIZE,  &b) != 0 &&
               eglGetConfigAttrib(display, cfg, EGL_DEPTH_SIZE, &d) != 0 &&
               r == 8 && g == 8 && b == 8 && d == 0 {
                chosen = cfg
                break
            }
        }
        if chosen == nil { chosen = cfgBuf[0] }
        guard let config = chosen else {
            print("Unable to initialize EGLConfig")
            return -1
        }

        /* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
         * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
         * As soon as we picked a EGLConfig, we can safely reconfigure the
         * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
        var nativeFormat: EGLint = 0
        _ = eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &nativeFormat)
        let surface: EGLSurface! = eglCreateWindowSurface(display, config, win, nil)

        /* A version of OpenGL has not been specified here.  This will default to
         * OpenGL 1.0.  You will need to change this if you want to use the newer
         * features of OpenGL like shaders. */
        let context: EGLContext! = eglCreateContext(display, config, nil, nil)

        if eglMakeCurrent(display, surface, surface, context) == EGL_FALSE {
            print("Unable to eglMakeCurrent")
            return -1
        }

        var w: EGLint = 0, h: EGLint = 0
        _ = eglQuerySurface(display, surface, EGL_WIDTH,  &w)
        _ = eglQuerySurface(display, surface, EGL_HEIGHT, &h)

        self.display = display
        self.context = context
        self.surface = surface
        self.width   = w
        self.height  = h
        self.state.angle = 0

        // Check openGL on the system
        for name in [GL_VENDOR, GL_RENDERER, GL_VERSION, GL_EXTENSIONS] {
            if let bytes = glGetString(GLenum(name)) {
                let cchars = UnsafeRawPointer(bytes).assumingMemoryBound(to: CChar.self)
                let s = String(cString: cchars)
                print("OpenGL Info: \(s)")
            }
        }

        // Initialize GL state.
        glHint(UInt32(GL_PERSPECTIVE_CORRECTION_HINT), UInt32(GL_FASTEST))
        glEnable(UInt32(GL_CULL_FACE))
        glShadeModel(UInt32(GL_SMOOTH))
        glDisable(UInt32(GL_DEPTH_TEST))

        return 0
    }

    /// Resumes ticking the application (Choreographer).
    public func resume() {
        if !running_ {
            running_ = true
            scheduleNextTick()
        }
    }

    /// Pauses ticking the application (Choreographer).
    public func pause() {
        running_ = false
    }

    /**
     * Tear down the EGL context currently associated with the display.
     */
    public func termDisplay() {
        if let dpy = self.display {
            _ = eglMakeCurrent(dpy, nil, nil, nil)
            if let ctx = self.context {
                _ = eglDestroyContext(dpy, ctx)
            }
            if let surf = self.surface {
                _ = eglDestroySurface(dpy, surf)
            }
            _ = eglTerminate(dpy)
        }
        self.pause()
        self.display = nil
        self.context = nil
        self.surface = nil
    }

    private func scheduleNextTick() {
        let choreo = AChoreographer_getInstance()
        AChoreographer_postFrameCallback(choreo, Engine_Tick, Unmanaged.passUnretained(self).toOpaque())
    }

    fileprivate func doTick() {
        guard running_ else { return }

        // Choreographer does not continuously schedule the callback. We have to re-
        // register the callback each time we're ticked.
        scheduleNextTick()
        update()
        drawFrame()
    }

    private func update() {
        state.angle += 0.01
        if state.angle > 1 {
            state.angle = 0
        }
    }

    private func drawFrame() {
        guard display != nil, surface != nil else {
            // No display/surface yet.
            return
        }

        // Just fill the screen with a color
        let r = Float(state.x) / Float(max(1, width))
        let g = state.angle
        let b = Float(state.y) / Float(max(1, height))

        glClearColor(r, g, b, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        _ = eglSwapBuffers(display, surface)
    }
}

@_cdecl("Engine_Tick")
public func Engine_Tick(_ frameTimeNanos: Int, _ data: UnsafeMutableRawPointer?) {
    guard let data else { return }
    let engine = Unmanaged<Engine>.fromOpaque(data).takeUnretainedValue()
    engine.doTick()
}

@_silgen_name("android_main")
public func android_main(_ app: UnsafeMutablePointer<android_app>) {
    let engine = Engine(app: app)
    app.pointee.userData = Unmanaged.passRetained(engine).toOpaque()

    app.pointee.onAppCmd = { app, cmd in
        // unwrap the optional android_app* and userData
        guard let opaque = app?.pointee.userData else { return }

        // turn void* back into Engine
        let engine = Unmanaged<Engine>.fromOpaque(opaque).takeUnretainedValue()

        switch Int(cmd) {
        case APP_CMD_INIT_WINDOW:
            _ = engine.initDisplay()
        case APP_CMD_TERM_WINDOW:
            engine.termDisplay()
        case APP_CMD_GAINED_FOCUS:
            engine.resume()
        case APP_CMD_LOST_FOCUS:
            engine.pause()
        default:
            print("Unsupported command \(cmd)")
        }
    }

    while app.pointee.destroyRequested == 0 {
        var outData: UnsafeMutableRawPointer? = nil

        let r = ALooper_pollOnce(-1, nil, nil, &outData)
        if r == ALOOPER_POLL_ERROR {
            fatalError("ALooper_pollOnce returned an error")
        }

        if let outData {
            let source = outData.assumingMemoryBound(to: android_poll_source.self)
            source.pointee.process(app, source)
        }
    }

    engine.termDisplay()
}
