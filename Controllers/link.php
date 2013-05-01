<?php

class Link_Controller {
	private $node;
	private $wf;
	public function __construct($n_model, $wf_model){
		$this->node = $n_model;
		$this->wf = $wf_model;
	}
	public function link_wf($wf_name, $n_sn, $label, $position){
		$result="";
		$this->wf->set_wf_name($wf_name);
		if ($this->wf->get_wf_id() == NULL){
			$result = "couldn't find the workflow named $wf_name in the database";
		} else {
			$this->node->init($this->wf->get_wf_id(), $n_sn);
			if ($this->node->get_n_id() == NULL){
				$result = "FAILED! The node named $n_sn MUST be in the workflow $wf_name in order to link.";
			} else {
				if ($position == 'start') {
					$this->wf->link_WF($this->node->get_n_id(), $label,'S');
				  $result = "the start node has been linked to the node '$n_sn'";
				}
				elseif ($position == 'finish') {
					$this->wf->link_WF($this->node->get_n_id(), $label,'E');
				  $result = "the node '$n_sn' has been linked  the end node";
				}
			}
		}
		return $result;
	}
	public function link_nodes($wf_name, $n_name_to, $n_name_from, $label){
		$result="";
		// Check if the workflow does exist in the database
		$this->wf->set_wf_name($wf_name);
		if ($this->wf->get_wf_id() == NULL){
			$result = "couldn't find the workflow named $wf_name in the database";
			return $result;
		} 

		// Check if the node is belonging to that workflow
		$this->node->init($this->wf->get_wf_id(), $n_name_to);
		if ($this->node->get_n_id() == NULL){
			$result = "FAILED! The node named $n_name_to MUST be in the workflow $wf_name in order to link.";
			return $result;
		}
		$n_id_to = $this->node->get_n_id();

		// Check if the node is belonging to that workflow
		$this->node->init($this->wf->get_wf_id(), $n_name_from);
		if ($this->node->get_n_id() == NULL){
			$result = "FAILED! The node named $n_name_from MUST be in the workflow $wf_name in order to link.";
			return $result;
		}
		$n_id_from = $this->node->get_n_id();

		// linking nodes together
		$this->wf->link_nodes($n_id_from, $n_id_to, $label);
		$result = "the node '$n_name_from' has been linked to the node '$n_name_to'";
		return $result;
	}
}
?>
