<?php

	$db = mysql_connect("localhost", "xampp", "root");
	
	if($db)
	{
		if(mysql_select_db("balcony"))
		{
			$res = mysql_query("SELECT * FROM SensorValues");
			$res = mysql_fetch_array($res, MYSQL_ASSOC);
			foreach($res as $r)
			{
				echo $r["VALUE"];
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