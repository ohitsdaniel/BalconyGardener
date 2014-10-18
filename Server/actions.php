<?php

function execute_action($action, $data)
{
	switch($action)
	{
		case "getSensorData":
			echo getSensorData($data);
		break;
		case "sensors":
			echo getSensors();
		break;
		default:
		break;
	}
}

function getSensorData($params)
{	
	$data = null;
	$count = null;
	
	if(isset($params["count"]))
	{
		$count = $params["count"];
	}
	
	if(isset($params["sensorName"]))
	{
		$data = getSingleSensorData($params["sensorName"], $count);
	}
	else
	{
		$data = getAllSensorData($count);
	}
	$json = "{";
	
	$currentSensor = "";
	$currentSensorJson = "";
	$currentSensorDataJson = "";
	while($row = mysql_fetch_array($data, MYSQL_ASSOC))
	{
		if($row["SENSOR_NAME"] != $currentSensor)
		{
			$json = writeDataToJSon($json, $currentSensorJson, $currentSensorDataJson);
			
			$currentSensor = $row["SENSOR_NAME"];
			$currentSensorJson = "\"" . $currentSensor . "\": [";
			$currentSensorDataJson = "";
		}	
		
		$rowData = "{\"time\": \"" . $row["TIMESTAMP"] . "\", \"value\": " . $row["VALUE"] . "}";
			
		if($currentSensorDataJson != "")
		{
			$currentSensorDataJson .= ", ";
		}
		$currentSensorDataJson .= $rowData;
	}	
	$json = writeDataToJSon($json, $currentSensorJson, $currentSensorDataJson, true);
	$json .= "}";
	return $json;
}

function writeDataToJSon($json, $currentSensorJson, $currentSensorDataJson, $last=false)
{
	if($currentSensorJson != "")
	{
		$currentSensorJson .= $currentSensorDataJson;
		$currentSensorJson .= "]";
		if(!$last)
		{
			$currentSensorJson .= ", ";
		}
	}
	$json .= $currentSensorJson;
	
	return $json;
}

function limitString($count)
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
	return mysql_query("SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID) WHERE Sensors.NAME = \"$name\" ORDER BY SensorValues.TIMESTAMP ASC" . limitString($count));
}

function getAllSensorData($count)
{
	return mysql_query("SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID) ORDER BY Sensors.ID ASC, SensorValues.TIMESTAMP ASC" . limitString($count));
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

?>
