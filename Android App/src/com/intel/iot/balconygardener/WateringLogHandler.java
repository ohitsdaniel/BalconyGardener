package com.intel.iot.balconygardener;

import java.util.List;

public interface WateringLogHandler {

	public void onWateringLogDownloaded(List<WateringLog> result);
	
}
