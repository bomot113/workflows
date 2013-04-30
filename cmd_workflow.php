<?php
/*
 * filename: cmd_workflow.php 
 */
include_once 'Controllers/workflow.php';
include_once 'Models/workflow.php';
/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchWorkflowCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "workflow") {
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
		$status = wf_create($cmd_list);
	}
	elseif ($arg1 == "delete") {
		$status = wf_delete($cmd_list);
	}
	elseif ($arg1 == "list") {
		$status = wf_list();
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}


/*
 * create -- Creates a workflow
 */
function wf_create($cmd_list) {
	global $gResult;
  $msg;
	$wf_name = search_cmdOpt($cmd_list, 'n');
 	$wf_info = search_cmdOpt($cmd_list, 'i');
	if ($wf_name == ""){
		$msg="couldn't create new workflow without a name";
		return cCmdStatus_ERROR;
	} else {
		$wf_controller = new Workflow_Controller(new Workflow);
		$msg = $wf_controller->create($wf_name, $wf_info);
	}  
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- Deletes a workflow
 */
function wf_delete($cmd_list) {
	global $gResult;
	$msg;
	$wfName = search_cmdOpt($cmd_list, 'n');
	if ($wfName == "") {
		$msg = "couldn't delete a workflow without the name";
	} else {
		$wf_controller = new Workflow_Controller(new Workflow);
		$msg = $wf_controller->delete($wfName);
	}
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}

/*
 * create -- List all workflows
 */
function wf_list() {
	global $gResult;
	$wf_controller = new Workflow_Controller(new Workflow);
	$msg = $wf_controller->getAllWorkflows();
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}


?>
