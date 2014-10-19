package com.intel.iot.balconygardener;

import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.EditText;

public class HistoryActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		getActionBar().setDisplayHomeAsUpEnabled(true);
		setContentView(R.layout.activity_history);
		
		Intent intent = getIntent();
		final String sensorName = intent.getStringExtra("SENSOR_NAME");
		
		final EditText historyView = (EditText) findViewById(R.id.editText1);
		
		DataServer server = new DataServer();
		server.downloadData(null, 4, new DownloadHandler() {
			
			@Override
			public void onDownloadedData(List<SensorData> data) {
				
				String history = "History of " + sensorName + " sensor\n";
				for (int i = 0; i < data.size(); i++) {
					if (sensorName.equals("Temperature")) {
						history += data.get(i).temperature + "\n";
					} else if (sensorName.equals("Moisture")) {
						history += data.get(i).moisture + "\n";
					} else if (sensorName.equals("Humidity")) {
						history += data.get(i).humidity + "\n";
					}
				}
				
				historyView.setText(history);
			}
		});
	}


	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.history, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		switch (item.getItemId()) {
		case R.id.action_settings :
			return true;
	    // Respond to the action bar's Up/Home button
	    case android.R.id.home :
	        NavUtils.navigateUpFromSameTask(this);
	        return true;
		}
		return super.onOptionsItemSelected(item);
	}

}
