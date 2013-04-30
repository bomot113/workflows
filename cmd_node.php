<?php

include_once 'Controllers/node.php';
include_once 'Models/node.php';

/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchNodeCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "node") {
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
		$status = node_add($cmd_list);
	}
	elseif ($arg1 == "list") {
		$status = node_list($cmd_list);
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}

/*
 * add node
 */
function node_add($cmd_list) {
	global $gResult;
  $msg="";
	$wf_name= search_cmdOpt($cmd_list, 'wf');
 	$n_sn 	= search_cmdOpt($cmd_list, 'sn');
	$n_type = search_cmdOpt($cmd_list, 't');
	$n_name = search_cmdOpt($cmd_list, 'n');

	if ($wf_name == ""){
		$msg="couldn't add new node without specifying a workflow";
		return cCmdStatus_ERROR;
	}
	if ($n_sn == "") {
		$msg="couldn't add a new node without a shortname";
		return cCmdStatus_ERROR;
	}
	if ($n_type == "") {
		$msg="couldn't add a new node without knowing its type";
		return cCmdStatus_ERROR;
	} elseif (!in_array($n_type, array('A', 'F', 'J', 'S', 'E'))){
		$msg="only nodes type A,F,J,S,E are allowed";
		return cCmdStatus_ERROR;
	}
	if ($n_name == "") {
		$msg="couldn't add a new node without a node name";
		return cCmdStatus_ERROR;
	}
  $n_controller = new Node_Controller(new Node, new Workflow);
	$msg = $n_controller->add($wf_name, $n_sn, $n_type, $n_name);
	$gResult = $gResult.$msg;
	return cCmdStatus_OK; 
}
/*
 * List all nodes in a given workflow
 */
function node_list($cmd_list){
	global $gResult;
	$wf_name= search_cmdOpt($cmd_list, 'wf');
	if($wf_name == "") {
		$msg = "what workflow are you talking about?";
	}
  $n_controller = new Node_Controller(new Node, new Workflow);
	$msg=$n_controller->getNodes($wf_name);
	$gResult = $gResult.$msg;
	return cCmdStatus_OK;
}

?>
