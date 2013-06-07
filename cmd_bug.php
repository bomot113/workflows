<?php

include_once 'Controllers/bug.php';
include_once 'Models/bug.php';

/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchBugCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "bug") {
		$status = cCmdStatus_NOT_FOUND; 
		return $status;
	}

	$arg1 = "";
	if (count($cmd_list) > 1) {
		$arg1 = $cmd_list[1];
	}

	// make strings more psql-liked
  psqlString($cmd_list);	

	if ($arg1 == "add") {
		$status = bug_create($cmd_list);
	}
	elseif ($arg1 == "delete") {
		$status = bug_delete($cmd_list);
	}
	elseif ($arg1 == "list") {
		$status = bug_list($cmd_list);
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}

/*
 * add Bug
 */
function bug_create($cmd_list) {
	global $gResult;
  $msg="";
	$b_name= search_cmdOpt($cmd_list, 'n');
 	$b_project 	= search_cmdOpt($cmd_list, 'p');
	$b_creator = search_cmdOpt($cmd_list, 'c');
	$b_responsible = search_cmdOpt($cmd_list, 'r');

	if ($b_name == ""){
		$msg="couldn't add new bug without specifying a name";
		return cCmdStatus_ERROR;
	}
	if ($b_project == "") {
		$msg="couldn't add a new bug without knowing its project";
		return cCmdStatus_ERROR;
	}
    $b_controller = new Bug_Controller(new Bug);
	$msg = $b_controller->create($b_name, $b_project, $b_creator, $b_responsible);
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- Deletes a bug
 */
function bug_delete($cmd_list) {
	global $gResult;
	$msg;
	$bugName = search_cmdOpt($cmd_list, 'n');
	if ($devName == "") {
		$msg = "couldn't delete a bug without the name";
	} else {
		$bug_controller = new Bug_Controller(new Bug);
		$msg = $bug_controller->delete($bugName);
	}
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * List all bugs
 */
function bug_list() {
	global $gResult;
	$bug_controller = new Bug_Controller(new Bug);
	$msg = $bug_controller->getAllbugs();
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

?>
