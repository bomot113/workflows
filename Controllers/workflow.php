<?php

class Workflow_Controller {
	private $wf;
	private $gResult;
	public function __construct($wf_model){
		$this->wf = $wf_model;
	}
	public function getAllWorkflows() {
		$gResult = $this->wf->getAllWorkflows();
		return $gResult;
	}
	
	public function delete($wf_name) {
		$this->wf->set_wf_name($wf_name);

		if ($this->wf->get_wf_id() == NULL) {
			$gResult = "there's no workflow named $wf_name in the database.";
		} else {
		  $this->wf->delete();	
			$gResult = "workflow named $wf_name has been deleted.";
		}	
		return $gResult;
	}

	public function create($wf_name, $wf_info) {
		$this->wf->set_wf_info($wf_info);
		$this->wf->set_wf_name($wf_name);
		if ($this->wf->get_wf_id() == NULL) {
			$this->wf->create();
			$gResult = "new workflow named $wf_name has been created successfully.";
		} else {
			$gResult = "workflow named $wf_name already exists! Couldn't create another.";
		}
		return $gResult;	
	}


}
?>
