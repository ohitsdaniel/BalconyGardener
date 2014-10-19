package com.intel.iot.balconygardener;

import java.util.List;

public interface DownloadHandler {

	public void onDownloadedData(List<SensorData> data);
	
}
