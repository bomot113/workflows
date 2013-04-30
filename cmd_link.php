<?php
include_once 'Controllers/link.php';

/*
 * This function dispatches a command and its parameters to the corresponding function 
 */
function dispatchLinkCmd($cmd, $cmd_list) 
{
	global $gResult;
	$status = cCmdStatus_NOT_FOUND;
	
	$cmd = $cmd_list[0];
	if ($cmd != "link") {
		$status = cCmdStatus_NOT_FOUND; 
		return $status;
	}

	$arg1 = "";
	if (count($cmd_list) > 1) {
		$arg1 = $cmd_list[1];
	}

	// make strings more psql-liked
  psqlString($cmd_list);	

	if ($arg1 == "start") {
		$status = link_wf($cmd_list,'start');
	}
	elseif ($arg1 == "finish") {
		$status = link_wf($cmd_list,'finish');
	}
	elseif ($arg1 == "children") {
		$status = link_children($cmd_list);
	}
	elseif (in_array($arg1, array("-wf","-from","-to","-g"))) {
		$status = link_nodes($cmd_list);
	}
	else {
		$status = cCmdStatus_NOT_FOUND; 
	}
	
	return $status;
}
/*
 * Link a node to start/finish node of the workflow
 */
function link_wf($cmd_list,$position){
	global $gResult;
	$wf_name= search_cmdOpt($cmd_list, 'wf');
	if ($position == 'start') {
		$n_name = search_cmdOpt($cmd_list, 'to');
	} 
	elseif ($position == 'finish') {
		$n_name = search_cmdOpt($cmd_list, 'from');
	} 
	else {
		return cCmdStatus_ERROR;
	}
	$label  = search_cmdOpt($cmd_list, 'g');
	if($wf_name == "") {
		$msg = "Need a workflow param.";
		return cCmdStatus_ERROR;
	} 
	if ($n_name == ""){
		$msg = "Need a node shortname to link to.";
		return cCmdStatus_ERROR;
	}
  $l_controller = new Link_Controller(new Node, new Workflow);
	$msg=$l_controller->link_wf($wf_name, $n_name, $label,$position);
  $gResult = $gResult.$msg;
	return cCmdStatus_OK;
}
/*
 * List all nodes in a given workflow
 */
function link_nodes($cmd_list){
	global $gResult;
	$wf_name= search_cmdOpt($cmd_list, 'wf');
	$n_name_to 		= search_cmdOpt($cmd_list, 'to');
	$n_name_from 	= search_cmdOpt($cmd_list, 'from');
	$label  = search_cmdOpt($cmd_list, 'g');
	if($wf_name == "") {
		$msg = "Need a workflow param.";
		return cCmdStatus_ERROR;
	} 
	if ($n_name_to == ""){
		$msg = "Need a node shortname to link to.";
		return cCmdStatus_ERROR;
	}
	if ($n_name_from == ""){
		$msg = "Need a node shortname to link from.";
		return cCmdStatus_ERROR;
	}
  $l_controller = new Link_Controller(new Node, new Workflow);
	$msg=$l_controller->link_nodes($wf_name, $n_name_to, $n_name_from, $label);
  $gResult = $gResult.$msg;
	return cCmdStatus_OK;
}
/*
 * List all the children nodes of a node in a given workflow
 */
function link_children($cmd_list){
	global $gResult;
	$wf_name= search_cmdOpt($cmd_list, 'wf');
	$n_sn	= search_cmdOpt($cmd_list, 'sn');
	if($wf_name == "") {
		$msg = "Need a workflow param.";
		return cCmdStatus_ERROR;
	} 
	if ($n_sn == ""){
		$msg = "Need a node shortname search for";
		return cCmdStatus_ERROR;
	}
  $n_controller = new Node_Controller(new Node, new Workflow);
	$msg=$n_controller->list_childnodes($wf_name, $n_sn);
  $gResult = $gResult.$msg;
	return cCmdStatus_OK;
}

?>
