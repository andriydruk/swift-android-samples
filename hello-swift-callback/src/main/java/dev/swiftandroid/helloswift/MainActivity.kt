package dev.swiftandroid.helloswift

import android.os.Bundle
import android.widget.TextView
import androidx.annotation.Keep
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    var hour: Int = 0
    var minute: Int = 0
    var second: Int = 0
    var tickView: TextView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        tickView = findViewById(R.id.tickView)
    }

    public override fun onResume() {
        super.onResume()
        second = 0
        minute = 0
        hour = 0
        startTicks()
    }

    public override fun onPause() {
        super.onPause()
        stopTicks()
    }

    /*
     * A function calling from JNI to update current timer
     */
    @Keep
    private fun updateTimer() {
        ++second
        if (second >= 60) {
            ++minute
            second -= 60
            if (minute >= 60) {
                ++hour
                minute -= 60
            }
        }
        runOnUiThread {
            val ticks = "" + this@MainActivity.hour + ":" +
                    this@MainActivity.minute + ":" +
                    this@MainActivity.second
            this@MainActivity.tickView?.text = ticks
        }
    }

    external fun startTicks()
    external fun stopTicks()

    companion object {
        // Used to load the 'hello-swift-callback' library on application startup.
        init {
            System.loadLibrary("hello-swift-callback")
        }
    }
}