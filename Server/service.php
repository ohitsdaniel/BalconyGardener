<?php

	$db = mysql_connect("localhost", "balcony", "gardener");
	
	if($db)
	{
		if(mysql_select_db("balcony"))
		{
			$res = mysql_query("SELECT Sensors.NAME as SENSOR_NAME, SensorValues.VALUE, SensorValues.TIMESTAMP FROM SensorValues LEFT JOIN Sensors ON (SensorValues.SENSOR_ID=Sensors.ID)");
			while($row = mysql_fetch_array($res, MYSQL_ASSOC))
			{
				echo $row["SENSOR_NAME"] . "@" . $row["TIMESTAMP"] . ": " . $row["VALUE"] . "</br>";
			}
	
		}
		else
		{
			echo "no db selected";
		}
	}
	else
	{
		echo "no connection";
	}
	mysql_close($db);
?>
