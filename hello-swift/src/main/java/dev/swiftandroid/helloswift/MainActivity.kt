package dev.swiftandroid.helloswift

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        findViewById<TextView>(R.id.sample_text).text = stringFromSwift()
    }

    /**
     * A native method that is implemented by the 'helloswift' native library,
     * which is packaged with this application.
     */
    external fun stringFromSwift(): String

    companion object {
        // Used to load the 'helloswift' library on application startup.
        init {
            System.loadLibrary("helloswift")
        }
    }
}