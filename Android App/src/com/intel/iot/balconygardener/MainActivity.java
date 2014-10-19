package com.intel.iot.balconygardener;

import java.io.IOException;
import java.util.List;

import org.apache.http.client.ClientProtocolException;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {

	final DataServer server = new DataServer();
	
	Button temperatureButton;
	Button humidityButton;
	Button moistureButton;
	Button waterButton;
	ImageButton waterButton2;
	TextView temperatureView;
	TextView humidityView;
	TextView moistureView;
	TextView lastTimeWateredView;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		temperatureButton = (Button) findViewById(R.id.button1);
		humidityButton = (Button) findViewById(R.id.button2);
		moistureButton = (Button) findViewById(R.id.button4);
		waterButton = (Button) findViewById(R.id.button5);
		waterButton2 = (ImageButton) findViewById(R.id.imageButton1);
		temperatureView = (TextView) findViewById(R.id.textViewTemperature);
		humidityView = (TextView) findViewById(R.id.textViewHumidity);
		moistureView = (TextView) findViewById(R.id.textViewMoisture);
		lastTimeWateredView = (TextView) findViewById(R.id.textViewLastTimeWatered);

		waterButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {

				server.sendWateringRequest(new WateringRequestHandler() {

					@Override
					public void onWateringRequestSend(boolean result) {
						if (result) {
							Toast.makeText(MainActivity.this, "Watering request submitted!", Toast.LENGTH_LONG).show();
						} else {
							Toast.makeText(MainActivity.this, "Error while sending watering request!", Toast.LENGTH_LONG).show();
						}
					}
					
				});
			}
		});

		waterButton2.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {

				server.sendWateringRequest(new WateringRequestHandler() {

					@Override
					public void onWateringRequestSend(boolean result) {
						if (result) {
							Toast.makeText(MainActivity.this, "Watering request submitted!", Toast.LENGTH_LONG).show();
						} else {
							Toast.makeText(MainActivity.this, "Error while sending watering request!", Toast.LENGTH_LONG).show();
						}
					}
					
				});
			}
		});
		
		temperatureButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {

				Intent startHistoryIntent = new Intent(MainActivity.this, HistoryActivity.class);
				startHistoryIntent.putExtra("SENSOR_NAME", "Temperature");
				startActivity(startHistoryIntent);
				
			}
		});
		
		humidityButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {

				Intent startHistoryIntent = new Intent(MainActivity.this, HistoryActivity.class);
				startHistoryIntent.putExtra("SENSOR_NAME", "Humidity");
				startActivity(startHistoryIntent);
				
			}
		});
		
		moistureButton.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {

				Intent startHistoryIntent = new Intent(MainActivity.this, HistoryActivity.class);
				startHistoryIntent.putExtra("SENSOR_NAME", "Moisture");
				startActivity(startHistoryIntent);
				
			}
		});		

	}
	
	@Override
	protected void onStart() {
		super.onStart();
		
		try {
			server.update(new UpdateHandler() {

				@Override
				public void onUpdateSuccessful(SensorData result) {
					temperatureView.setText(getString(R.string.temperature) + ": " + result.temperature + " @ " + result.timeTemperature);
					humidityView.setText(getString(R.string.humidity) + ": " + result.humidity+ " @ " + result.timeHumidity);
					moistureView.setText(getString(R.string.moisture) + ": " + result.moisture+ " @ " + result.timeMoisture);
				}
			});
			server.downloadWateringLog(1, new WateringLogHandler() {

				@Override
				public void onWateringLogDownloaded(List<WateringLog> result) {

					WateringLog log = result.get(0);
					lastTimeWateredView.setText(getString(R.string.last_time_watered) + ": " + log.timestamp);
				}

			});
		} catch (ClientProtocolException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

//		});
//	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();
		if (id == R.id.action_settings) {
			return true;
		}
		return super.onOptionsItemSelected(item);
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
	  // Ignore orientation changes and use landscape only
	  super.onConfigurationChanged(newConfig);
	}
	
}
