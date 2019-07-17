package com.dr.kode.boothy

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import com.dr.kode.boothy.fragments.BoothyFragment
import com.dr.kode.boothy.fragments.FragmentBertamu
import com.dr.kode.boothy.fragments.FragmentInputInfo
import com.dr.kode.boothy.fragments.OnData
import com.google.firebase.FirebaseApp

class MainActivity : AppCompatActivity(), OnData {
    // URL: http://bukutamu.lumbunginovasi.com/event_xyti12_booth01
    // http://bukutamu.lumbunginovasi.com/event_0012_booth03
    // URL: http://bukutamu.lumbunginovasi.com/event_*
    companion object {
        val STR_PREF = "com.dr.kode.boothy_user_info"
    }

    private var eventID: String? = null
    private var boothID: String? = null

    override fun onStart() {
        super.onStart()
        try {
            FirebaseApp.initializeApp(applicationContext)
        } catch (e: Exception) { }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val sf = getSharedPreferences(STR_PREF, Context.MODE_PRIVATE)
        val savedData = sf.getString("data", null)
        val ft = supportFragmentManager.beginTransaction()
        val dt = intent.data

        if (dt != null) {
            eventID = dt.getQueryParameter("id")
            boothID = dt.getQueryParameter("b")

            savedData?.let {
                Log.e("data", it)
                ft.replace(R.id.fragmentContainer, FragmentBertamu.create(eventID, boothID))
            } ?: run {
                ft.replace(R.id.fragmentContainer, FragmentInputInfo.create(eventID, boothID))
            }
            ft.commit()
        } else {
            ft.replace(R.id.fragmentContainer, BoothyFragment()).commit()
        }
    }

    override fun onSaveInfo() {
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragmentContainer, FragmentBertamu.create(eventID, boothID))
            .commit()
    }

    override fun onEditInfo() {
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragmentContainer, FragmentInputInfo.create(eventID, boothID))
            .commit()
    }
}
