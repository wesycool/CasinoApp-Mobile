package com.ut.casinoapp;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.Arrays;
import java.util.Date;

public class PokerData extends AppCompatActivity {
    private final static String TAG  = "CasinoApp";
    private static final String FILE_NAME = "pokerdata.txt";

    public void save(Context context, String jackpot, Double jackpotAmount, Double score, Boolean play){
        Log.i(TAG, "PokerData Save called");
        Date date = new Date();

        String text = (String) String.valueOf(date.getTime()) + "," + jackpot + "," + jackpotAmount + "," + score + "," + play;
        File file = new File(context.getFilesDir(),FILE_NAME);
        StringBuilder content = new StringBuilder();

        try {

            if (file.exists()){
                BufferedReader reader = new BufferedReader(new FileReader(file));
                String line;

                while ((line = reader.readLine()) != null) {
                    content.append(line);
                    content.append("\n");
                }
                reader.close();
            }

            content.append(text);

            FileWriter writer = new FileWriter(file);
            writer.append(content);
            writer.flush();
            writer.close();

        } catch (Exception e) {
        }

    }



    public String[][] loadContent(Context context){
        Log.i(TAG, "PokerData loadContent called");
        File file = new File(context.getFilesDir(), FILE_NAME);
        try {

            if (file.exists()) {
                BufferedReader reader = new BufferedReader(new FileReader(file));
                String[][] array = {{}};
                String line;

                int i = 0;

                while ((line = reader.readLine()) != null){
                    String[] str = line.split(",");
                    array = Arrays.copyOf(array, i + 1);
                    array[i] = str;
                    i++;
                }
                reader.close();
                return array;
            }

        } catch (Exception e) {
        }
        return null;
    }
}
