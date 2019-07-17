package com.dr.kode.boothy.fragments

import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RadioButton
import androidx.fragment.app.Fragment
import com.dr.kode.boothy.MainActivity
import com.dr.kode.boothy.MyInfo
import com.dr.kode.boothy.R
import com.google.gson.Gson
import kotlinx.android.synthetic.main.fragment_input.*

class FragmentInputInfo : Fragment(), EventData {
    override var eventID: String? = null
    override var boothID: String? = null

    companion object {
        fun create(eventID: String?, boothID: String?): FragmentInputInfo = FragmentInputInfo().apply {
            this.eventID = eventID
            this.boothID = boothID
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_input, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        btnSave.setOnClickListener {
            save()
        }

    }

    private fun save() {
        if (inputName.text.isNullOrBlank()) {
            inputName.error = "Nama harus di isi."
            inputName.requestFocus()
            return
        } else {
            inputName.error = null
        }

        if (inputDomisili.text.isNullOrBlank()) {
            inputDomisili.error = "Alamat harus di isi."
            inputDomisili.requestFocus()
            return
        } else {
            inputDomisili.error = null
        }
        val jk = view?.findViewById<RadioButton>(rgGenders.checkedRadioButtonId)?.text?.toString()

        val info = MyInfo(
            inputName.text.toString(),
            inputEmail.text.toString(),
            jk,
            inputPhone.text.toString(),
            inputDomisili.text.toString(),
            inputInstansi.text.toString()
        )

        val sf = context?.getSharedPreferences(MainActivity.STR_PREF, Context.MODE_PRIVATE)?.edit()
        sf?.putString("data", Gson().toJson(info))
        sf?.apply()

        Log.e("SAVING", "simpan data")

        (activity as OnData).onSaveInfo()
    }

}