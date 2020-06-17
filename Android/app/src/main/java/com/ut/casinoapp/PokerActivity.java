package com.ut.casinoapp;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;

import java.util.Collections;
import java.util.HashSet;
import android.text.InputType;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ListAdapter;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Random;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;

public class PokerActivity extends AppCompatActivity{
    private final static String TAG  = "CasinoApp";

    TextView creditLabel;
    TextView jackpotLabel;
    TextView winLabel;

    String[][] content;
    Double balance;

    final NumberFormat formatter = new DecimalFormat("#,##0.00");


    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.poker);
        Log.i(TAG, "Let's Play Poker Activity");


        //Define Variables
        creditLabel = (TextView) findViewById(R.id.creditLabel);
        jackpotLabel = (TextView) findViewById(R.id.jackpotLabel);
        winLabel = (TextView) findViewById(R.id.winLabel);


        try {
            content = new PokerData().loadContent(this);
            balance = Double.parseDouble(content[content.length - 1][3]);
        }catch (Exception e){
            balance = 0.0;
        }


        //Set Default
        creditLabel.setText("Credit: $" + formatter.format(balance));
        jackpotLabel.setText("");
        winLabel.setAlpha(0);
        setButton(balance);



        //Enable ToolBar
        Toolbar toolbar = (Toolbar) findViewById(R.id.action_bar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        toolbar.getNavigationIcon().setColorFilter(getResources().getColor(R.color.colorBlue), PorterDuff.Mode.SRC_ATOP);

        TextView mTitle = (TextView) toolbar.findViewById(R.id.toolbar_title);
        mTitle.setText(toolbar.getTitle());
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        Button mButton = (Button) toolbar.findViewById(R.id.toolbar_button);
        mButton.setEnabled(true);
        mButton.setVisibility(View.VISIBLE);



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
                payoutList.add(payout);
            }

            ListAdapter adapter = new SimpleAdapter(this, payoutList, R.layout.payout_table,new String[]{"jackpot","payout"}, new int[]{R.id.jackpot, R.id.payout});
            lv.setAdapter(adapter);
        }catch (JSONException e){

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





    public void onClickPayout(View view) {
        Log.i(TAG, "onClickPayout called");
        Intent intent = new Intent(this, PayoutActivity.class);
        startActivity(intent);

    }




    public void onClickBet(View view) {
        Log.i(TAG, "onClickBet called: "+ ((Button) view).getText().toString());
        Handler handler = new Handler();

        jackpotLabel.setText("");
        winLabel.setAlpha(0);

        String buttonText = ((Button) view).getText().toString();
        String[] betLabelSplitText = buttonText.split("x");
        Double betValue = Double.parseDouble(betLabelSplitText[1]) * 0.3;


        //Disable Bet Buttons
        for (int i=0; i< 4; i++) {
            String buttonName = "betButton" + String.valueOf(i + 1);
            int buttonId = getResources().getIdentifier(buttonName, "id", getPackageName());
            Button button = (Button) findViewById(buttonId);

            button.setEnabled(false);
            button.setAlpha((float) 0.5);
        }


        //Play Sound
        MediaPlayer bloomSound = MediaPlayer.create(this,R.raw.bloom);
        bloomSound.setVolume((float) 100, (float) 100);
        bloomSound.start();


        //Set Bet Amount
        TextView betLabel = (TextView) findViewById(R.id.betLabel);
        String newBetLabel = "Bet: $" + formatter.format(betValue);
        betLabel.setText(newBetLabel);



        //Subtract Credit Amount
        String creditText = creditLabel.getText().toString();
        String[] creditLabelSplitText = creditText.split(Matcher.quoteReplacement("$"));
        final Double creditValue = Double.parseDouble(creditLabelSplitText[1]) - betValue;
        String newCreditLabel = "Credit: $" + formatter.format(creditValue);
        creditLabel.setText(newCreditLabel);



        //Random Cards
        final ArrayList<Integer> cardArray = new ArrayList<Integer>(Arrays.asList(0,0,0,0,0));
        for (int i = 0; i < 5; i++) {
            String imageName = "imageView"+ String.valueOf(i+1);
            int imageId = getResources().getIdentifier(imageName, "id", getPackageName());
            ImageView image = (ImageView) findViewById(imageId);
            int drawableId = getResources().getIdentifier("card0","drawable",getPackageName());
            image.setImageResource(drawableId);

            int random = 0;

            while (cardArray.contains(random)) {
                random = new Random().nextInt(51) + 1;
            }
            cardArray.set(i,random);
        }



        //Flip Cards
        for (int i = 0; i < 5; i++) {
            final int a = i;
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    String imageName = "imageView"+ String.valueOf(a+1);
                    int imageId = getResources().getIdentifier(imageName, "id", getPackageName());
                    ImageView image = (ImageView) findViewById(imageId);

                    String cardName = "card" + String.valueOf(cardArray.get(a));
                    int drawableId = getResources().getIdentifier(cardName,"drawable",getPackageName());
                    image.setImageResource(drawableId);
                }
            }, (a+1)*250);

        }



        //Calculate Jackpot
        int payout = calculateJackpot(cardArray);
        ListView lv = (ListView) findViewById(R.id.payout_list);
        String jackpotMessage = "";
        Double jackpotAmount = 0.0;


        if (payout != 10){

            String payoutList = lv.getItemAtPosition(payout).toString();
            payoutList = payoutList.replaceAll("[{}]","");


            String[] payoutListSplitText = payoutList.split("[,=]");
            payoutListSplitText[3] = payoutListSplitText[3].replace("x","");
            jackpotMessage = payoutListSplitText[1];
            jackpotAmount = Double.parseDouble(payoutListSplitText[3]) * betValue;



            final String finalJackpotMessage = jackpotMessage;
            final Double finalJackpotAmount = jackpotAmount;


            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    jackpotLabel.setText(finalJackpotMessage);
                    winLabel.setAlpha(1);

                    MediaPlayer fanfareSound = MediaPlayer.create(PokerActivity.this,R.raw.fanfare);
                    fanfareSound.setVolume((float) 100, (float) 100);
                    fanfareSound.start();

                    final Timer timer = new Timer();
                    TimerTask tasknew = new TimerTask(){
                        int i = 0;
                        public void run() {
                            int counter = (int) (finalJackpotAmount * 100);

                            if (i < counter) {
                                double amount = (double) ++i/100;
                                final String newCreditLabel = "Credit: $" + formatter.format(creditValue + amount);

                                runOnUiThread(new Runnable() {
                                    public void run() {
                                        creditLabel.setText(newCreditLabel);
                                    }
                                });

                            }else{
                                timer.cancel();
                                timer.purge();
                            }
                        }
                    };
                    timer.schedule(tasknew,1, 1);
                }
            }, 1500);

        }else{
            jackpotMessage = "No Win";

            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    MediaPlayer descentSound = MediaPlayer.create(PokerActivity.this, R.raw.descent);
                    descentSound.setVolume((float) 100, (float) 100);
                    descentSound.start();
                }
            },1500);

        }


        final double credit = creditValue + jackpotAmount;
        new PokerData().save(this, jackpotMessage, jackpotAmount, credit,true);


        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                setButton(credit);
            }
        }, (int) (1501 + jackpotAmount * 100 / 0.027));

    }




    private int calculateJackpot(ArrayList arrayList){
        Log.i(TAG, "calculateJackpot called");

        ArrayList cardValue = new ArrayList<Integer>(Arrays.asList(0,0,0,0,0));
        ArrayList cardSymbol = new ArrayList<Integer>(Arrays.asList(0,0,0,0,0));
        ArrayList aceCard = new ArrayList<Integer>(Arrays.asList(0,0,0,0,0));
        ArrayList compareCard = new ArrayList<Boolean>(Arrays.asList(false,false,false,false,false));
        ArrayList aceCompareCard = new ArrayList<Boolean>(Arrays.asList(false,false,false,false,false));


        //Define Cards
        for (int i=0; i<5; i++) {
            cardValue.set(i, (Integer.parseInt(arrayList.get(i).toString()) - 1) % 13 + 1);
            cardSymbol.set(i, (Integer.parseInt(arrayList.get(i).toString()) - 1) / 13);
        }


        //Sort and Set Cards
        ArrayList sortCardValue = cardValue;
        Collections.sort(sortCardValue);

        Set<String> setCardValue = new HashSet<String>(cardValue);
        Set<String> setCardSymbol = new HashSet<String>(cardSymbol);


        //Sort Ace Card
        if (Integer.parseInt(sortCardValue.get(0).toString()) == 1){
            for (int i=1; i<5; i++){
                aceCard.set(i-1,Integer.parseInt(sortCardValue.get(i).toString()));
            }
            aceCard.set(4, 14);
        }else{
            aceCard = sortCardValue;
        }


        //Compare Cards for Straight
        for (int i=0; i<5; i++){
            compareCard.set(i,Integer.parseInt(sortCardValue.get(i).toString()) == Integer.parseInt(Collections.min(sortCardValue).toString()) + i);
            aceCompareCard.set(i,Integer.parseInt(aceCard.get(i).toString()) == Integer.parseInt(Collections.min(aceCard).toString()) + i);
        }


        //Run Calculation
        switch (setCardValue.size()){
            case 2:
                //2 Sets of Numbers
                ArrayList count2 = new ArrayList<Integer>(Arrays.asList(0,0));

                for (int i=0;i<2;i++){
                    count2.set(i, Collections.frequency(cardValue, Integer.parseInt(setCardValue.toArray()[i].toString())));
                }

                if (Integer.parseInt(Collections.max(count2).toString()) == 4){
                    //Four of a Kind
                    return 2;
                }else{
                    //Full House
                    return 3;
                }

            case 3:
                //2 Sets of Numbers
                ArrayList count3 = new ArrayList<Integer>(Arrays.asList(0,0,0));

                for (int i=0;i<3;i++) {
                    count3.set(i, Collections.frequency(cardValue, Integer.parseInt(setCardValue.toArray()[i].toString())));
                }

                if (Integer.parseInt(Collections.max(count3).toString()) == 3){
                    //Three of a Kind
                    return 6;
                }else{
                    //Two Pairs
                    return 7;
                }

            case 4:
                //4 Sets of Numbers (aka One Pair)
                return 8;

            default:
                //5 Sets of Numbers - all different numbers

                if (aceCompareCard.contains(false)){
                    //No Royal
                    if (compareCard.contains(false)){
                        //No Straight
                        if (setCardSymbol.size() == 1){
                            //Flush
                            return 4;
                        }else{
                            //No Flush
                            for (int i=0;i<5;i++){
                                if (Integer.parseInt(arrayList.get(i).toString()) == 27){
                                    //High Ace
                                    return 9;
                                }
                            }
                            return 10;
                        }
                    }else{
                        //Straight
                        if (setCardSymbol.size() == 1){
                            //Flush
                            return 2;
                        }else{
                            //No Flush
                            return 5;
                        }
                    }
                }else{
                    //Royal
                    if (setCardSymbol.size() == 1){
                        //Flush
                        return 0;
                    }else{
                        //No Flush
                        return 5;
                    }
                }

        }
    }




    public void onClickCredit(View view){
        Log.i(TAG, "onClickCredit called");

        final EditText input = new EditText(this);
        input.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
        input.setHint("How much credit to add?");
        input.setPadding(100,50,100,50);


        final String title = "Purchasing Credit";
        final String currentBalance = "Current balance: $" + formatter.format(balance);


        final AlertDialog.Builder confirmAlert  = new AlertDialog.Builder(this);
        AlertDialog.Builder creditAlert  = new AlertDialog.Builder(this);
        creditAlert.setMessage(currentBalance);
        creditAlert.setView(input);
        creditAlert.setTitle(title);
        creditAlert.setPositiveButton("Submit", new DialogInterface.OnClickListener() {

            public void onClick(DialogInterface dialog, int id) {
                final double credit = Double.parseDouble(input.getText().toString());
                String addCredit = "Confirm to add credit of $"+ formatter.format(credit);
                String newBalance = "New balance: $"+ formatter.format(balance+credit);
                String confirmMessage = addCredit +"\n"+ currentBalance +"\n"+ newBalance;


                confirmAlert.setTitle(title);
                confirmAlert.setMessage(confirmMessage);
                confirmAlert.setPositiveButton("Confirm",new DialogInterface.OnClickListener() {

                    public void onClick(DialogInterface dialog, int id) {
                        new PokerData().save(PokerActivity.this, "Add Credit", credit, (balance+credit),false);
                        finish();
                        startActivity(getIntent());
                    }
                });

                confirmAlert.setNegativeButton("Cancel",null);
                confirmAlert.create().show();
            }
        });

        creditAlert.setNegativeButton("Cancel",null);
        creditAlert.create().show();

    }




    private void setButton(Double value){
        Log.i(TAG, "setButton called");

        double[] buttonValue = {0.3, 1.5, 3, 15};

        for (int i=0; i< buttonValue.length; i++){
            String buttonName = "betButton"+ String.valueOf(i+1);
            int buttonId = getResources().getIdentifier(buttonName, "id", getPackageName());
            Button button = (Button) findViewById(buttonId);

            if (value < buttonValue[i]){
                button.setEnabled(false);
                button.setAlpha((float) 0.5);
            } else {
                button.setEnabled(true);
                button.setAlpha((float) 1);
            }
        }
    }
}
