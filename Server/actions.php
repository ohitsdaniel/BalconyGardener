<?php

function execute_action($action)
{
	switch($action)
	{
		case "getData":
			getData();
		break;
		case "sensors":
			echo getSensors();
		break;
		default:
		break;
	}
}

function getData()
{
	$res = mysql_query("SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID)");
	while($row = mysql_fetch_array($res, MYSQL_ASSOC))
	{
		echo $row["SENSOR_NAME"] . "@" . $row["TIMESTAMP"] . ": " . $row["VALUE"] . "</br>";
	}
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
