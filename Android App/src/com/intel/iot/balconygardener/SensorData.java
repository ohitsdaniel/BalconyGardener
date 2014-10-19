package com.intel.iot.balconygardener;

public class SensorData {

	double temperature;
	String timeTemperature;
	double moisture;
	String timeMoisture;
	double humidity;
	String timeHumidity;
	
	public void init() {
		temperature = 0.;
		timeTemperature = "";
		moisture = 0.;
		timeMoisture = "";
		humidity = 0.;
		timeHumidity = "";
	}
}
