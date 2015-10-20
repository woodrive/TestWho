package com.winel.administrator.new0930;

import android.app.Fragment;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.Layout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

/**
 * Created by admin on 2015/10/15.
 */
public class Pager3Fragment extends android.support.v4.app.Fragment {
    private View mainview;
    private Button btn_act;

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
        mainview = inflater.inflate(R.layout.pager3, (ViewGroup)getActivity().findViewById(R.id.viewpager), false);
        btn_act = (Button)mainview.findViewById(R.id.btn_act);
        btn_act.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getActivity(), BoardActivity.class);
                startActivity(intent);
                getActivity().finish();
            }
        });
    }
}
