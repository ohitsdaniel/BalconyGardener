<?php

function execute_action($action, $data)
{
	switch($action)
	{
		case "getSensorData":
			echo getSensorData($data);
			break;
		case "sensors":
		case "getSensors":
			echo getSensors();
			break;
		case "infoPlantWatered":
			addWaterPlantLog("Galileo");
			break;
		case "waterPlant":
			addWaterPlantLog("App");
			echo "Plant Watered!";
			break;
		case "getWateringLog":
			echo getWateringLog($data);
		default:
			break;
	}
}

function addWaterPlantLog($trigger)
{
	$query = "INSERT INTO Log (ACTION, TRIGGERED_BY) VALUES ('Plant watered', '$trigger');";
	
	mysql_query($query);
}

function getSensorData($params)
{	
	$sensorData = [];
	$count = null;
	
	if(isset($params["count"]))
	{
		$count = $params["count"];
	}
	
	if(isset($params["sensorName"]))
	{
		$sensorData[$params["sensorName"]] = getSingleSensorData($params["sensorName"], $count);
	}
	else
	{
		$sensorData = getAllSensorData($count);
	}
	
	$json = "{";
	
	$i = 1;
	foreach($sensorData as $sensorName => $data)
	{
		$currentSensorJson = "\"" . $sensorName . "\": [";
		$currentSensorDataJson = "";
		
		while($row = mysql_fetch_array($data, MYSQL_ASSOC))
		{			
			$rowData = "{\"time\": \"" . $row["TIMESTAMP"] . "\", \"value\": " . $row["VALUE"] . "}";
				
			if($currentSensorDataJson != "")
			{
				$currentSensorDataJson .= ", ";
			}
			$currentSensorDataJson .= $rowData;
		}
		
		$currentSensorJson .= $currentSensorDataJson;
		$currentSensorJson .= "]";
		if($i != count($sensorData))
		{
			$currentSensorJson .= ", ";
		}
		$json .= $currentSensorJson;
		++$i;
	}
	$json .= "}";
	return $json;
}

function limitString($count = 0)
{
	$limit = "";
	if(0 != $count)
	{
		$limit = " LIMIT $count";
	}
	
	return $limit;
}

function getSingleSensorData($name, $count)
{	
	$limit = limitString($count);
	$query = "SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID) WHERE Sensors.NAME = \"$name\" ORDER BY SensorValues.TIMESTAMP DESC $limit";
	return mysql_query($query);
}

function getAllSensorData($count)
{
	$res = mysql_query("SELECT Sensors.* FROM Sensors");
	$sensors = [];
	while($row = mysql_fetch_array($res, MYSQL_ASSOC))
	{
		$sensors[] = $row["NAME"];
	}
	
	$sensorData = [];
	
	foreach($sensors as $sensor)
	{
		$sensorData[$sensor] = getSingleSensorData($sensor, $count);
	}
	
	return $sensorData;
}

function getSensors()
{
	$res = mysql_query("SELECT Sensors.* FROM Sensors");
	$json = "";
	$json .= "{";
	
	$json .= "\"sensors\": [";
	$sensors = "";
	while($row = mysql_fetch_array($res, MYSQL_ASSOC))
	{
		$sensor = "\"" . $row["NAME"] ."\"";
		if($sensors != "")
		{
			$sensors .= ", ";
		}
		$sensors .= $sensor;
	}
	$json .= $sensors;	
	$json .="]}";
	
	return $json;	
}

function getWateringLog($data)
{
	$count = 0;
	if(isset($data["count"]))
	{
		$count = $data["count"];
	}
	
	$limit =limitString($count);
	$res = mysql_query("SELECT Log.* FROM Log $limit");
	
	$json = "";
	$json .= "{";

	$json .= "\"wateringLogs\": [";
	$logs = "";
	while($row = mysql_fetch_array($res, MYSQL_ASSOC))
	{
		$log = "{\"timestamp\": \"" . $row["TIMESTAMP"] ."\", \"trigger\": \"". $row["TRIGGER"] . "\", \"action\": \"" . $row["ACTION"]."\"}";
		if($logs != "")
		{
			$logs .= ", ";
		}
		$logs .= $log;
	}
	$json .= $logs;
	$json .="]}";

	return $json;
}

?>
