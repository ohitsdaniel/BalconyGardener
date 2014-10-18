<?php
	
	include 'actions.php';

	$db = mysql_connect("localhost", "balcony", "gardener");
	
	if($db)
	{
		if(mysql_select_db("balcony"))
		{
			execute_action($_GET["action"], $_GET);
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
