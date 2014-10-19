package com.intel.iot.balconygardener;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.LinkedList;
import java.util.List;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;

public class DataServer {

	public SensorData data;
	
	public List<SensorData> parseN(String jsonString, int n) {
		LinkedList<SensorData> result = new LinkedList<SensorData>();
		
		for (int i = 1; i <= n; i++) {
			result.add(parseOne(jsonString, i-1));
		}
	
		return result;
	}
	
	public SensorData parseOne(String jsonString, int index) {

		SensorData result = new SensorData();
		result.init();
		
		JSONObject json;
		try {
			json = new JSONObject(jsonString);
			JSONArray humidityArray = json.getJSONArray("Humidity");
			if (index < humidityArray.length()) {
				JSONObject humidity = humidityArray.getJSONObject(index);
//			data.humidity = Double.parseDouble(humidity.getString(name));
				result.humidity = humidity.getDouble("value");
			}

			JSONArray moistureArray = json.getJSONArray("Moisture");
			if (index < moistureArray.length()) {
				JSONObject moisture = moistureArray.getJSONObject(index);
//			data.moisture = Double.parseDouble(moisture.getString("value"));
				result.moisture = moisture.getDouble("value");
			}

			JSONArray temperatureArray = json.getJSONArray("Temperature");
			if (index < temperatureArray.length()) {
				JSONObject temperature = temperatureArray.getJSONObject(index);
//			data.temperature = Double.parseDouble(temperature.getString("value"));
				result.temperature = temperature.getDouble("value");
			}
			
		} catch (JSONException e) {
//			result.init();
			Log.e("MARK", "Exception in parseOne.");
		}
		
		return result;
	}
	
	public SensorData parseLatest(String jsonString) {
		return parseOne(jsonString, 0);
	}
	
	
	public void update(final UpdateHandler updateHandler) throws ClientProtocolException, IOException {
		
		AsyncTask<Void, Void, SensorData> task = new AsyncTask<Void, Void, SensorData>() {
				
			@Override
			protected SensorData doInBackground(Void... params) {
				
				data = new SensorData();
				
				HttpURLConnection con;
				try {
					con = (HttpURLConnection) ( new URL("http://146.0.40.96/balconygardener/service.php?action=getSensorData&count=1")).openConnection();
					con.setRequestMethod("GET");
					con.setDoInput(true);
					con.setDoOutput(true);
					con.connect();
					//con.getOutputStream().write( ("name=" + name).getBytes());
					InputStream is = con.getInputStream();
					BufferedReader reader = new BufferedReader(new InputStreamReader(is));
					String jsonString = reader.readLine();
					
					data = parseLatest(jsonString);
//					
//					JSONArray ar = json.getJSONArray("sensors");
//					data = new SensorData();
//					for (int i = 0; i < ar.length(); i++) {
//						if (i == 0) {
//							humidity = ar.getString(i);
//						}
//					}

					con.disconnect();
					
					} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				
				return data;
			}
			
			
			
			@Override
			protected void onPostExecute(SensorData result) {
				updateHandler.onUpdateSuccessful(result);
			}
			
		};
		
		task.execute();
		
	}
	
	public void downloadData(final String sensor, final int count, final DownloadHandler downloadHandler) {
		AsyncTask<Void, Void, List<SensorData>> task = new AsyncTask<Void, Void, List<SensorData>>() {
			
			@Override
			protected List<SensorData> doInBackground(Void... params) {
				
				List<SensorData> result = null;
				
				HttpURLConnection con;
				try {
					String urlString = "http://146.0.40.96/balconygardener/service.php?action=getSensorData";
//					if (sensor != null) {
//						urlString += "&sensorName=" + sensor;
//					}
					urlString += "&count=" + count;
					URL url = new URL(urlString);
					con = (HttpURLConnection) url.openConnection();
					con.setRequestMethod("GET");
					con.setDoInput(true);
					con.setDoOutput(true);
					con.connect();
					InputStream is = con.getInputStream();
					BufferedReader reader = new BufferedReader(new InputStreamReader(is));
					String jsonString = reader.readLine();

					result = parseN(jsonString, count);
					
					con.disconnect();
					
					} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				
				return result;
			}
			
			@Override
			protected void onPostExecute(List<SensorData> result) {
				downloadHandler.onDownloadedData(result);
			}
			
		};		
		task.execute();
	}

	public void downloadWateringLog(final int count, final WateringLogHandler wateringLogHandler) {
		AsyncTask<Void, Void, List<WateringLog>> task = new AsyncTask<Void, Void, List<WateringLog>>() {
			
			@Override
			protected List<WateringLog> doInBackground(Void... params) {
				
				List<WateringLog> result = null;
				
				HttpURLConnection con;
				try {
					String urlString = "http://146.0.40.96/balconygardener/service.php?action=getWateringLog";
					urlString += "&count=" + count;
					URL url = new URL(urlString);
					con = (HttpURLConnection) url.openConnection();
					con.setRequestMethod("GET");
					con.setDoInput(true);
					con.setDoOutput(true);
					con.connect();
					InputStream is = con.getInputStream();
					BufferedReader reader = new BufferedReader(new InputStreamReader(is));
					String jsonString = reader.readLine();

					result = parseWateringLogN(jsonString, count);
					
					con.disconnect();
					
					} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}
				
				return result;
			}

			@Override
			protected void onPostExecute(List<WateringLog> result) {
				wateringLogHandler.onWateringLogDownloaded(result);
			}
			
		};		
		task.execute();
	}
	

	
	private List<WateringLog> parseWateringLogN(String jsonString, int n) {
			LinkedList<WateringLog> result = new LinkedList<WateringLog>();
	
			for (int i = 1; i <= n; i++) {
				result.add(parseWateringLogOne(jsonString, i-1));
			}
		
			return result;
	}
	
	private WateringLog parseWateringLogOne(String jsonString, int index) {

		WateringLog result = new WateringLog();
		result.init();
		
		JSONObject json;
		try {
			json = new JSONObject(jsonString);
			JSONArray wateringLogsArray = json.getJSONArray("wateringLogs");
			if (index < wateringLogsArray.length()) {
				JSONObject wateringLog = wateringLogsArray.getJSONObject(index);
				result.timestamp = wateringLog.getString("timestamp");
				result.trigger = wateringLog.getString("trigger");
				result.action = wateringLog.getString("action");
				result.duration = wateringLog.getDouble("duration");
			}			
		} catch (JSONException e) {
			Log.e("MARK", "Exception in parseWateringLogOne.");
		}
		
		return result;
	}

	public void sendWateringRequest(final WateringRequestHandler handler) {
		AsyncTask<Void, Void, Boolean> task = new AsyncTask<Void, Void, Boolean>() {

			@Override
			protected Boolean doInBackground(Void... params) {

				Boolean result = false;

				HttpURLConnection con;
				try {
					String urlString = "http://146.0.40.96/balconygardener/service.php?action=waterPlant";
					URL url = new URL(urlString);
					con = (HttpURLConnection) url.openConnection();
					con.setRequestMethod("GET");
					con.setDoInput(true);
					con.setDoOutput(true);
					con.connect();
					InputStream is = con.getInputStream();
					BufferedReader reader = new BufferedReader(new InputStreamReader(is));
					String jsonString = reader.readLine();

					if (jsonString.equals("Plant Watered!")) {
						result = true;
					}
					con.disconnect();

				} catch (MalformedURLException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}

				return result;
			}

			@Override
			protected void onPostExecute(Boolean result) {
				handler.onWateringRequestSend(result);
			}

		};		
		task.execute();
	}
}
