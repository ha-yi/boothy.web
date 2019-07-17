package com.dr.kode.boothy

import androidx.multidex.MultiDexApplication
import com.google.firebase.FirebaseApp

class BoothyApp: MultiDexApplication() {

    override fun onCreate() {
        super.onCreate()
        FirebaseApp.initializeApp(this)
    }
}