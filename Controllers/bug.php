<?php

class Bug_Controller{
	private $b;
	private $gResult;
	public function __construct($b_model){
		$this->b = $b_model;
	}
	
	public function create($b_name, $b_project, $b_creator, $b_responsible){
		$this->b->set_b_name($b_name);
		$this->b->set_b_project($b_project);
		$this->b->set_b_creator($b_creator);
		$this->b->set_b_responsible($b_responsible);
		
		//If the bug name doesn't already exist, create it
		if($this->b->get_b_id() == NULL){
			$this->b->create();
			$gResult = "new bug named $b_name has been created successfully.";
			
		//Bug name already exists, can't create it
		}else{
			$gResult = "bug named $b_name already exists! Couldn't create another.";
		}
		return $gResult;
	}
	
	public function delete($b_name){
		$this->b->set_b_name($b_name);

		if($this->b->get_b_id() == NULL){
			$gResult = "there's no bug named $b_name in the database.";
		}else{
		  $this->b->delete();	
			$gResult = "bug named $b_name has been deleted.";
		}	
		return $gResult;
	}

	public function getAllbugs(){
		$gResult = $this->b->getAllbugs();
		return $gResult;
	}
}
?>