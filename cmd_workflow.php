<?php
/*
 * filename: cmd_workflow.php 
 */


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
	
	if ($arg1 == "create") {
		$status = wf_create($cmd_list);
	}
	elseif ($arg1 == "delete") {
		$status = wf_delete($cmd_list);
	}
	elseif ($arg1 == "list") {
		$status = wf_list($cmd_list);
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
	$t = "Stub to implement workflow create \n"; 
	$gResult = $t . print_r($cmd_list,true);
	return cCmdStatus_OK; 
}

/*
 * create -- Deletes a workflow
 */
function wf_delete($cmd_list) {
	global $gResult;
	$t = "Stub to implement workflow delete \n"; 
	$gResult = $t . print_r($cmd_list,true);
	return cCmdStatus_OK; 
}

/*
 * create -- List all workflows
 */
function wf_list($cmd_list) {
	global $gResult;
	$t = "Stub to implement workflow list \n"; 
	$gResult = $t . print_r($cmd_list,true);
	return cCmdStatus_OK; 
}

?>