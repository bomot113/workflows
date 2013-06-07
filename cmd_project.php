<?php
/*
 * filename: cmd_project.php 
 */
include_once 'Controllers/project.php';
include_once 'Models/project.php';
/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchProjectCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "project") {
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
		$status = proj_create($cmd_list);
	}
	elseif ($arg1 == "delete") {
		$status = proj_delete($cmd_list);
	}
	elseif ($arg1 == "list") {
		$status = proj_list();
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}


/*
 * create -- Creates a project
 */
function proj_create($cmd_list) {
	global $gResult;
  $msg;
	$p_name = search_cmdOpt($cmd_list, 'n');
 	$p_wf = search_cmdOpt($cmd_list, 'wf');
	if ($p_name == ""){
		$msg="couldn't create new project without a name";
		return cCmdStatus_ERROR;
	} else {
		$p_controller = new Project_Controller(new project);
		$msg = $p_controller->create($p_name, $p_wf);
	}  
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- Deletes a project
 */
function proj_delete($cmd_list) {
	global $gResult;
	$msg;
	$p_name = search_cmdOpt($cmd_list, 'n');
	if ($p_name == "") {
		$msg = "couldn't delete a project without the name";
	} else {
		$p_controller = new Project_Controller(new project);
		$msg = $p_controller->delete($p_name);
	}
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- List all projects
 */
function proj_list() {
	global $gResult;
	$p_controller = new Project_Controller(new project);
	$msg = $p_controller->getAllprojects();
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}


?>
