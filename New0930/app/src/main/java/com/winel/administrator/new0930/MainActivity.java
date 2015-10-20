package com.winel.administrator.new0930;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.PagerTitleStrip;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.LayoutDirection;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;


public class MainActivity extends FragmentActivity {

    private ViewPager viewPager;
    private Pager1Fragment pager1;
    private Pager2Fragment pager2;
    private Pager3Fragment pager3;
    //页面list
    private ArrayList<Fragment> fraglist;
    //标题list
    private ArrayList<String> titlelist = new ArrayList<>();
    //标题设置
    private PagerTitleStrip titleStrip;
    private PagerTabStrip tabStrip;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        viewPager = (ViewPager)findViewById(R.id.viewpager);
        tabStrip = (PagerTabStrip)findViewById(R.id.pagertab);
        tabStrip.setTabIndicatorColor(getResources().getColor(android.R.color.holo_blue_bright));
        tabStrip.setBackgroundColor(getResources().getColor(android.R.color.holo_green_light));
        //		pagerTitleStrip=(PagerTitleStrip) findViewById(R.id.pagertab);
//		//设置背景的颜色
//		pagerTitleStrip.setBackgroundColor(getResources().getColor(android.R.color.holo_blue
        Pager1Fragment pfm1 = new Pager1Fragment();
        Pager2Fragment pfm2 = new Pager2Fragment();
        Pager3Fragment pfm3 = new Pager3Fragment();
        fraglist = new ArrayList<Fragment>();
        fraglist.add(pfm1);
        fraglist.add(pfm2);
        fraglist.add(pfm3);

        titlelist.add("列表一");
        titlelist.add("列表二");
        titlelist.add("列表三");
        viewPager.setAdapter(new MyViewPagerAdapter(getSupportFragmentManager()));
        viewPager.addOnPageChangeListener(new MyViewPagerChangeListener());
        //
//        TextView textView = new TextView(this);
//        textView.setText("跳过");
//        addContentView(textView, new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT));
//        Timer timer = new Timer();
//        timer.schedule(new TimerTask() {
//            @Override
//            public void run() {
//                Intent intent = new Intent(MainActivity.this, BoardActivity.class);
//                startActivity(intent);
//                MainActivity.this.finish();
//            }
//        }, 3000);
    }


    public class MyViewPagerChangeListener implements ViewPager.OnPageChangeListener{
        private int changeif = 0;
        @Override
        public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            Log.d("winel", "onPageScrolled--position:" + position + "-Offset:" + positionOffset
                + "-Pixels:" + positionOffsetPixels);
            if((position == 2) && (positionOffset == 0)){
                changeif = 1;
            }else{
                changeif = 0;
            }
        }

        @Override
        public void onPageScrollStateChanged(int state) {
            Log.d("winel", "onPageScrollStateChanged:" + state);
            if((changeif == 1) && (state == 1)){
//                Intent intent = new Intent(MainActivity.this, BoardActivity.class);
//                startActivity(intent);
//                MainActivity.this.finish();
            }
        }

        @Override
        public void onPageSelected(int position) {
            Log.d("winel", "position:" + position);
        }
    }
    public class MyViewPagerAdapter extends FragmentPagerAdapter{
        @Override
        public CharSequence getPageTitle(int position) {
            return titlelist.get(position);
        }

        @Override
        public int getCount() {
            return fraglist.size();
        }

        @Override
        public Fragment getItem(int position) {
            return fraglist.get(position);
        }

        public MyViewPagerAdapter(FragmentManager fm){
            super(fm);
        }
    }

}
