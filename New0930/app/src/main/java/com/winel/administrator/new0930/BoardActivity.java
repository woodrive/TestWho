package com.winel.administrator.new0930;

import android.app.Activity;
import android.app.TabActivity;
import android.os.Bundle;
import android.widget.TabHost;

/**
 * Created by Administrator on 2015/10/10.
 */
public class BoardActivity extends TabActivity {
    private TabHost tabHost;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_board);
        //
        tabHost = getTabHost();
        tabHost.addTab(tabHost.newTabSpec("layout1").setIndicator("标签一").setContent(R.id.layout_sheet1));
        tabHost.addTab(tabHost.newTabSpec("layout2").setIndicator("标签二").setContent(R.id.layout_sheet2));
        tabHost.addTab(tabHost.newTabSpec("layout3").setIndicator("标签三").setContent(R.id.layout_sheet3));
    }
}
