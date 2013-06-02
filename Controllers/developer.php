<?php

class Developer_Controller{
	private $d;
	private $gResult;
	public function __construct($d_model){
		$this->d = $d_model;
	}
	public function getAlldevelopers(){
		$gResult = $this->d->getAlldevelopers();
		return $gResult;
	}
	
	public function delete($d_name){
		$this->d->set_d_name($d_name);

		if($this->d->get_d_id() == NULL){
			$gResult = "there's no developer named $d_name in the database.";
		}else{
		  $this->d->delete();	
			$gResult = "developer named $d_name has been deleted.";
		}	
		return $gResult;
	}

	public function create($d_name, $d_info){
		$this->d->set_d_info($d_info);
		$this->d->set_d_name($d_name);
		if($this->d->get_d_id() == NULL){
			$this->d->create();
			$gResult = "new developer named ".$d_name." has been created successfully.";
		}else{
			$gResult = "developer named ".$d_name." already exists! Couldn't create another.";
		}
		return $gResult;
	}
}
?>