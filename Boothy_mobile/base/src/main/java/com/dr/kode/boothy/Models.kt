package com.dr.kode.boothy

import androidx.annotation.Keep

@Keep
data class MyInfo(
    var name: String,
    var email: String?,
    var gender: String?,
    var phone: String?,
    var address: String,
    var institution: String?,
    var question: String? = null
)