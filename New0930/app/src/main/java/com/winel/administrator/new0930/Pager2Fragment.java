package com.winel.administrator.new0930;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 * Created by admin on 2015/10/15.
 */
public class Pager2Fragment extends android.support.v4.app.Fragment {
    private View mainview;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        ViewGroup p = (ViewGroup)mainview.getParent();
        if(p != null){
            p.removeAllViewsInLayout();
        }
        return mainview;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LayoutInflater inflater = getActivity().getLayoutInflater();
        mainview = inflater.inflate(R.layout.pager2, (ViewGroup)getActivity().findViewById(R.id.viewpager), false);
    }
}
