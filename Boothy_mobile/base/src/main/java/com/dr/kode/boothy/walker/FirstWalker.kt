package com.dr.kode.boothy.walker

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.dr.kode.boothy.R

class FirstWalker: Fragment() {
    var PAGE_POS: Int = 0

    companion object {
        fun create(pos: Int) = FirstWalker().apply {
            PAGE_POS = pos
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val layout = when(PAGE_POS) {
            0 -> R.layout.first
            1 -> R.layout.second
            2 -> R.layout.third
            3 -> R.layout.fourth
            else -> R.layout.fifth
        }
        return inflater.inflate(layout, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
    }
}