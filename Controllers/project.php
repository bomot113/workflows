<?php

class Project_Controller{
	private $p;
	private $gResult;
	public function __construct($p_model){
		$this->p = $p_model;
	}
	
	//Creation of a project, requires project name and workflow name
	public function create($p_name, $p_wf){
		$this->p->set_p_wf($p_wf);
		$this->p->set_p_name($p_name);
		
		//If project id is not set, project name available
		if($this->p->get_p_id() == NULL){
			$this->p->create();
			$gResult = "new project named ".$p_name." has been created successfully.";
		
		//If project id is set, project name not available
		}else{
			$gResult = "project named ".$p_name." already exists! Couldn't create another.";
		}
		
		return $gResult;
	}
	
	//Delection of a project, requires the project name
	public function delete($p_name){
		$this->p->set_p_name($p_name);

		//If project id is not set, the project does not exist
		if($this->p->get_p_id() == NULL){
			$gResult = "there's no project named ".$p_name." in the database.";
		
		//If project id is set, then project exists, so delete it
		}else{
			$this->p->delete();	
			$gResult = "project named ".$p_name." has been deleted.";
		}	
		return $gResult;
	}

	//Retrieval of all projects
	public function getAllprojects(){
		$gResult = $this->p->getAllprojects();
		return $gResult;
	}
}
?>