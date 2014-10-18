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
	$sensorData[];
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

function writeDataToJSon($json, $currentSensorJson, $currentSensorDataJson, $last=false)
{
	
	
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
	$limit = limitString($count);
	$query = "SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID) WHERE Sensors.NAME = \"$name\" ORDER BY SensorValues.TIMESTAMP DESC $limit";
	echo $query;
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
	
	foreach($sensor as $sensors)
	{
		$sensorData[$sensor] = getSingleSensorData($sensor, $count);
	}
	
	return $sensorData;
}

function querySensorData($on, $where, $count)
{

	$query = $vars . $select . $on . $where . $orderBy;
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
