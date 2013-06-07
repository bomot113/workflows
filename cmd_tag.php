<?php
/*
 * filename: cmd_tag.php 
 */
include_once 'Controllers/tag.php';
include_once 'Models/tag.php';
/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchTagCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "tag") {
		$status = cCmdStatus_NOT_FOUND; 
		return $status;
	}

	$arg1 = "";
	if (count($cmd_list) > 1) {
		$arg1 = $cmd_list[1];
	}
	// make strings more psql-liked
  psqlString($cmd_list);	
	
	if ($arg1 == "tag") {
		$status = t_create($cmd_list);
	}
	elseif ($arg1 == "update") {
		$status = t_update($cmd_list);
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}


/*
 * create -- Creates a tag
 */
function t_create($cmd_list) {
	global $gResult;
  $msg;
	$t_list = search_cmdOpt($cmd_list, 't');
 	$t_bug = search_cmdOpt($cmd_list, 'b');
	if ($t_list == ""){
		$msg="couldn't create new tag without a tag list";
		return cCmdStatus_ERROR;
	} else {
		$t_controller = new Tag_Controller(new tag);
		$msg = $t_controller->create($t_list, $t_bug);
	}  
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * Update -- Updates a tag
 */
function t_update($cmd_list) {
	global $gResult;
  $msg;
	$t_id = search_cmdOpt($cmd_list, 'id');
	$t_list = search_cmdOpt($cmd_list, 't');
	if ($t_id == ""){
		$msg="couldn't create new tag without an id";
		return cCmdStatus_ERROR;
	} else {
		$t_controller = new Tag_Controller(new tag);
		$msg = $t_controller->update($t_bug, $t_list);
	}  
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

?>
