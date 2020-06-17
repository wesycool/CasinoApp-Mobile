package com.ut.casinoapp;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;

public class StatsDetailActivity extends AppCompatActivity {
    private final static String TAG  = "CasinoApp";
    final NumberFormat formatter = new DecimalFormat("#,##0.00");

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.stats_detail_layout);
        Intent intent = getIntent();
        String title = intent.getExtras().getString("Title");
        Log.i(TAG, "Stats Detail Table Activity: " + title);


        //Enable ToolBar
        Toolbar toolbar = (Toolbar) findViewById(R.id.action_bar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        toolbar.getNavigationIcon().setColorFilter(getResources().getColor(R.color.colorBlue), PorterDuff.Mode.SRC_ATOP);

        TextView mTitle = (TextView) toolbar.findViewById(R.id.toolbar_title);
        mTitle.setText(title);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        Button mButton = (Button) toolbar.findViewById(R.id.toolbar_button);
        mButton.setEnabled(false);
        mButton.setVisibility(View.GONE);


        String[][] content = new PokerData().loadContent(this);
        ArrayList<HashMap<String, String>> statsDetailList = new ArrayList<>();
        ListView list = (ListView) findViewById(R.id.stats_detail);
        Date date = new Date();


        try{

            for (int i =0; i<content.length; i++){
                HashMap<String, String> statsDetail = new HashMap<>();

                if (content[i][1].contains(title)){
                    date.setTime(Long.parseLong(content[i][0]));
                    statsDetail.put("Date",date.toString());
                    statsDetail.put("winAmount", "$"+formatter.format(Double.parseDouble(content[i][2])));
                    statsDetailList.add(statsDetail);
                }
            }

            Collections.reverse(statsDetailList);

            ListAdapter adapter = new SimpleAdapter(this, statsDetailList , R.layout.stats_detail_table,new String[]{"Date","winAmount"}, new int[]{R.id.date,R.id.winAmount});
            list.setAdapter(adapter);

        }catch (Exception e){

        }


    }


}
