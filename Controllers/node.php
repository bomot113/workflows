<?php

class Node_Controller {
	private $node;
	private $wf;
	private $printing;
	public function __construct($n_model, $wf_model){
		$this->node = $n_model;
		$this->wf = $wf_model;
	}
	public function add($wf_name, $n_sn, $n_type, $n_name){
		$this->wf->set_wf_name($wf_name);
		$result="";
		if ($this->wf->get_wf_id() == NULL){
			$result = "couldn't find the workflow named $wf_name in the database";
		} else {
			$this->node->init($this->wf->get_wf_id(), $n_sn, $n_type);
			if ($this->node->get_n_id() != NULL){
				$result = "can't create ANOTHER node named $n_sn type $n_type in the workflow $wf_name exists";
			} else {
				$this->node->create($this->wf->get_wf_id(),$n_sn, $n_type, $n_name);
				$result = "a node named '$n_sn' has been created.";
			}
		}
		return $result;
	}

	public function getNodes($wf_name){
		$result="";
		$this->wf->set_wf_name($wf_name);
		if($this->wf->get_wf_id() == NULL){
			$result = "couldn't find the workflow named $wf_name in the database";
		} else {
			$result = $this->wf->getNodes();
		}
		return $result;
	}

	public function list_childnodes($wf_name, $n_sn){
		$result="";
		$this->wf->set_wf_name($wf_name);
		if($this->wf->get_wf_id() == NULL){
			$result = "couldn't find the workflow named $wf_name in the database";
		} else {
			$this->node->init($this->wf->get_wf_id(), $n_sn);
			if ($this->node->get_n_id() == NULL){
				$result = "couldn't locate node named $n_sn in the workflow $wf_name.";
			} else {
				$result = $this->node->list_childnodes();
			}
		}
		return $result;
	}

}
?>
