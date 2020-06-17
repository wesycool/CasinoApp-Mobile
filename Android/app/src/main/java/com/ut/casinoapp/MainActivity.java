package com.ut.casinoapp;

import androidx.appcompat.app.AppCompatActivity;
import android.content.Intent;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;


public class MainActivity extends AppCompatActivity{
    private final static String TAG  = "CasinoApp";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }


    public void onClick(View view) {
        Log.i(TAG, "onClick called: "+ ((Button) view).getText().toString() + " Button");

        ToneGenerator tg = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100);
        tg.startTone(ToneGenerator.TONE_PROP_BEEP);

        Class getClass;
        switch (view.getId()){
            case R.id.button1:
                getClass = PokerActivity.class;
                break;
            case R.id.button2:
                getClass = AccountActivity.class;
                break;
            default:
                throw new IllegalStateException("Unexpected value: " + view.getId());
        }

        Intent intent = new Intent(this, getClass);
        startActivity(intent);

    }

}
