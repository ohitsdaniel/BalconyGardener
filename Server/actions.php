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
	$on = "ON (SensorValues.SENSOR_ID=Sensors.ID)";
	$where = "WHERE Sensors.NAME = \"$name\"";
	return querySensorData($on, $where);
}

function getAllSensorData($count)
{
	$on = "ON (SensorValues.SENSOR_ID=Sensors.ID)";
	$where = "";
	return querySensorData($on, $where);
}

function querySensorData($on, $where, $count)
{
	$vars = "set @num := 0, @sensor := '';";
	$select = "SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP, @num := if(@sensor = SENSOR_NAME, @num + 1, 1) as row_number, @sensor := SENSOR_NAME as dummy FROM SensorValues force index(sensor) LEFT JOIN Sensors ";
	$orderBy = " GROUP BY SENSOR_NAME, VALUE, TIMESTAMP ORDER BY SensorValues.TIMESTAMP DESC HAVING row_number < $count";

	$query = $vars . $select . $on . $where . $orderBy;
	echo $query;
	return mysql_query($query);
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
