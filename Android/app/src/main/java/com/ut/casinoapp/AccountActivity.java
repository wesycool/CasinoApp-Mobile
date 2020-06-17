package com.ut.casinoapp;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.PorterDuff;
import android.os.Bundle;
import android.text.InputType;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

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

public class AccountActivity  extends AppCompatActivity {
    private final static String TAG  = "CasinoApp";
    TextView creditLabel;

    String[][] content;
    Double balance;

    final NumberFormat formatter = new DecimalFormat("#,##0.00");
    final NumberFormat percentage = new DecimalFormat("#,##0.0%");

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.account);
        Log.i(TAG, "My Account Activity");


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



        //Define Variables
        creditLabel = (TextView) findViewById(R.id.creditLabel);

        try {
            content = new PokerData().loadContent(this);
            balance = Double.parseDouble(content[content.length - 1][3]);
        }catch (Exception e){
            balance = 0.0;
        }

        creditLabel.setText("Current Credit: $" + formatter.format(balance));



        ArrayList<String[]> arrayList = new ArrayList<String[]>();
        try {
            JSONObject jObj = new JSONObject(loadJSONFromAsset());
            JSONArray jsonArry = jObj.getJSONArray("poker");
            for (int i = 0; i < jsonArry.length(); i++) {
                JSONObject obj = jsonArry.getJSONObject(i);
                arrayList.add(new String[] {obj.getString("jackpot"),"0","0"});
            }

        }catch (JSONException e){

        }




        double amount = 0;
        double count = 0;
        double win = 0;
        String[][] array = {{}};
        array = arrayList.toArray(array);

        try {
            for (int i = 0; i < content.length; i++) {
                if (Boolean.parseBoolean(content[i][4])) {
                    amount = amount + Double.parseDouble(content[i][2]);
                    count++;
                    if (!content[i][1].equals("No Win")){
                        win++;

                        for (int a=0; a < array.length; a++){
                            if (Arrays.toString(array[a]).contains(content[i][1])){
                                array[a][1] = String.valueOf(Integer.parseInt(array[a][1]) + 1);
                                array[a][2] = String.valueOf(Double.parseDouble(array[a][2]) + Double.parseDouble(content[i][2]));
                            }
                        }

                    }
                }
            }
        }catch (Exception e){

        }


        Double percent = win/count;


        TextView game = (TextView) findViewById(R.id.game);
        TextView winAmount = (TextView) findViewById(R.id.winAmount);
        TextView winRatio = (TextView) findViewById(R.id.winRatio);
        TextView percentRatio = (TextView) findViewById(R.id.percentRatio);

        game.setText("Total Game: "+ (int) count);
        winAmount.setText("Win Amount: $" + formatter.format(amount));
        winRatio.setText("Win Ratio: "+ (int) win + " : " + (int) count);
        percentRatio.setText("Percent Ratio: " + percentage.format(percent));


        //Display Stats Table

        try{
            ArrayList<HashMap<String, String>> statsList = new ArrayList<>();
            ListView lv = (ListView) findViewById(R.id.stats_list);

            for (int i=0; i< array.length; i++){
                HashMap<String, String> stats = new HashMap<>();
                stats.put("jackpot", array[i][0]);
                stats.put("jackpotAmount", "Total Amount: $" + formatter.format(Double.parseDouble(array[i][2])));
                stats.put("winRatio","Win Ratio: "+ Integer.parseInt(array[i][1]) + " : " + (int) count);
                stats.put("percentRatio","Percent Ratio: " + percentage.format(Double.parseDouble(array[i][1])/count));
                statsList.add(stats);
            }

            ListAdapter adapter = new SimpleAdapter(this, statsList, R.layout.stats_table,new String[]{"jackpot","jackpotAmount","winRatio","percentRatio"}, new int[]{R.id.jackpot, R.id.jackpotAmount,R.id.winRatio,R.id.percentRatio});
            lv.setAdapter(adapter);



            //Pass Data onItemClickListener
            final String[][] finalArray = array;
            AdapterView.OnItemClickListener itemClickListener = new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    Intent newIntent = new Intent(AccountActivity.this,StatsDetailActivity.class);
                    newIntent.putExtra("Title", finalArray[position][0]);

                    startActivity(newIntent);
                }
            };

            lv.setOnItemClickListener(itemClickListener);

        }catch (Exception e){
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
                        new PokerData().save(AccountActivity.this, "Add Credit", credit, (balance+credit),false);
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

}
