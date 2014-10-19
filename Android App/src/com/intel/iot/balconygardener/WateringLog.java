package com.intel.iot.balconygardener;

public class WateringLog {

	String timestamp;
	String trigger;
	String action;
	double duration;
	
	public void init() {
		timestamp = "";
		trigger = "";
		action = "";
		duration = 0.;
	}
	
}
