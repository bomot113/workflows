<?php
/*
 * filename: cmd_developer.php 
 */
include_once 'Controllers/developer.php';
include_once 'Models/developer.php';
/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchDeveloperCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "developer") {
		$status = cCmdStatus_NOT_FOUND; 
		return $status;
	}

	$arg1 = "";
	if (count($cmd_list) > 1) {
		$arg1 = $cmd_list[1];
	}
	// make strings more psql-liked
  psqlString($cmd_list);	
	
	if ($arg1 == "create") {
		$status = dev_create($cmd_list);
	}
	elseif ($arg1 == "delete") {
		$status = dev_delete($cmd_list);
	}
	elseif ($arg1 == "list") {
		$status = dev_list();
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}


/*
 * create -- Creates a developer
 */
function dev_create($cmd_list) {
	global $gResult;
  $msg;
	$dev_name = search_cmdOpt($cmd_list, 'n');
	if ($dev_name == ""){
		$msg="couldn't create new developer without a name";
		return cCmdStatus_ERROR;
	} else {
		$dev_controller = new Developer_Controller(new Developer);
		$msg = $dev_controller->create($d_name);
	}  
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- Deletes a developer
 */
function dev_delete($cmd_list) {
	global $gResult;
	$msg;
	$devName = search_cmdOpt($cmd_list, 'n');
	if ($devName == "") {
		$msg = "couldn't delete a developer without the name";
	} else {
		$dev_controller = new Developer_Controller(new Developer);
		$msg = $dev_controller->delete($devName);
	}
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- List all developer
 */
function dev_list() {
	global $gResult;
	$dev_controller = new Developer_Controller(new Developer);
	$msg = $dev_controller->getAllDevelopers();
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}


?>
