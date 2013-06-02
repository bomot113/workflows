<?php

class Tag_Controller{
	private $t;
	private $gResult;
	public function __construct($t_model){
		$this->t = $t_model;
	}
	
	public function create($t_list, $t_bug){
		$this->t->set_t_list($t_list);
		$this->t->set_t_bug($t_bug);
		
		if($this->t->get_t_id() == NULL){
			$this->t->create();
			$gResult = "new tag named $t_name has been created successfully.";
		}else{
			$gResult = "tag named $t_name already exists! Couldn't create another.";
		}
		return $gResult;
	}

	public function update($t_bug, $t_list){
		$this->t->set_t_bug($t_bug);
		$this->t->set_t_list($t_list);

		if($this->t->get_t_id() == NULL){
			$gResult = "there's no tag named $t_name in the database.";
		}else{
		  $this->t->delete();	
			$gResult = "tag named $t_name has been deleted.";
		}	
		return $gResult;
	}
	
	public function getAlltags(){
		$gResult = $this->t->getAlltags();
		return $gResult;
	}
}
?>