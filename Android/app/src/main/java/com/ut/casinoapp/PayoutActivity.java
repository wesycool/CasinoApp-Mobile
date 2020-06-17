package com.ut.casinoapp;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;

public class PayoutActivity extends AppCompatActivity {
    private final static String TAG  = "CasinoApp";

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.payout_layout);
        Log.i(TAG, "Payout Table Activity");



        //Enable ToolBar
        Toolbar toolbar = (Toolbar) findViewById(R.id.action_bar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        toolbar.getNavigationIcon().setColorFilter(getResources().getColor(R.color.colorBlue), PorterDuff.Mode.SRC_ATOP);

        TextView mTitle = (TextView) toolbar.findViewById(R.id.toolbar_title);
        mTitle.setText(toolbar.getTitle());
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        Button mButton = (Button) toolbar.findViewById(R.id.toolbar_button);
        mButton.setEnabled(false);
        mButton.setVisibility(View.GONE);



        //Display Payout Table
        try {
            ArrayList<HashMap<String, String>> payoutList = new ArrayList<>();
            ListView lv = (ListView) findViewById(R.id.payout_list);

            JSONObject jObj = new JSONObject(loadJSONFromAsset());
            JSONArray jsonArry = jObj.getJSONArray("poker");
            for (int i = 0; i < jsonArry.length(); i++) {
                HashMap<String, String> payout = new HashMap<>();
                JSONObject obj = jsonArry.getJSONObject(i);
                payout.put("jackpot", obj.getString("jackpot"));
                payout.put("payout", "x" + obj.getString("payout"));
                payout.put("card1", getResources().getIdentifier(obj.getString("card1"), "drawable", getPackageName())+"");
                payout.put("card2", getResources().getIdentifier(obj.getString("card2"), "drawable", getPackageName())+"");
                payout.put("card3", getResources().getIdentifier(obj.getString("card3"), "drawable", getPackageName())+"");
                payout.put("card4", getResources().getIdentifier(obj.getString("card4"), "drawable", getPackageName())+"");
                payout.put("card5", getResources().getIdentifier(obj.getString("card5"), "drawable", getPackageName())+"");
                payoutList.add(payout);
            }

            ListAdapter adapter = new SimpleAdapter(PayoutActivity.this, payoutList, R.layout.payout,new String[]{"jackpot","payout","card1","card2","card3","card4","card5"}, new int[]{R.id.jackpot, R.id.payout,R.id.card1,R.id.card2,R.id.card3,R.id.card4,R.id.card5});
            lv.setAdapter(adapter);

        }catch (JSONException ignored){

        }
    }



    public String loadJSONFromAsset() {
        Log.i(TAG, "loadJSONFromAsset called");
        String json = null;
        try {
            InputStream is = getAssets().open("poker.json");
            int size = is.available();
            byte[] buffer = new byte[size];
            is.read(buffer);
            is.close();
            json = new String(buffer, "UTF-8");
        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }
        return json;
    }
}