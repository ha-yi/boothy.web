package com.dr.kode.boothy.fragments

import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.dr.kode.boothy.MainActivity
import com.dr.kode.boothy.MyInfo
import com.dr.kode.boothy.R
import com.google.gson.Gson
import kotlinx.android.synthetic.main.fragment_bertamu.*
import com.google.firebase.firestore.FirebaseFirestore


class FragmentBertamu : Fragment(), EventData {
    override var eventID: String? = null
    override var boothID: String? = null
    val db: FirebaseFirestore by lazy {
        FirebaseFirestore.getInstance()
    }

    companion object {
        fun create(eventID: String?, boothID: String?): FragmentBertamu = FragmentBertamu().apply {
            this.eventID = eventID
            this.boothID = boothID
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_bertamu, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val sf = context?.getSharedPreferences(MainActivity.STR_PREF, Context.MODE_PRIVATE)
        val savedData = sf?.getString("data", null)
        val info = Gson().fromJson(savedData, MyInfo::class.java)
        info.let {
            txtName.text = it.name
            txtAddr.text = it.address
            txtEmail.text = it.email
            txtInstitusi.text = it.institution
            txtPhone.text = it.phone
        }

        txtBoothName.text = "di Booth: $boothID"
        btnSave.setOnClickListener {
            info.question = inputPertanyaan.text.toString()
            save(info)
        }
        btnEditInfo.setOnClickListener {
            (activity as OnData).onEditInfo()
        }

        loadNamaBooth()
    }

    private fun loadNamaBooth() {
        if (eventID == null || boothID == null) return
        db.collection("events").document(eventID!!)
            .collection("booth").document(boothID!!).get().addOnCompleteListener {
                it.result?.get("name")?.let {
                    txtBoothName.text = "di Booth: $it"
                }
            }
    }

    private fun save(info: MyInfo) {
        if (eventID == null || boothID == null) return
        val ref = db.collection("events").document(eventID!!)
            .collection("booth").document(boothID!!)
            .collection("tamu")
        btnSave.isEnabled = false
        btnSave.text = "M E N Y I M P A N . . ."
        btnSave.setBackgroundColor(Color.parseColor("#2196F3"))
        ref.add(info)
            .addOnCompleteListener {
                Toast.makeText(context, "Berhasil disimpan", Toast.LENGTH_LONG).show()
                activity?.finish()
            }
    }

}