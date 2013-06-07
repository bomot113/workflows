<?php
$cSelectProject = "select * from final.select_Project";
$cCreateProject = "select * from final.create_Project";
$cDeleteProject = "select * from final.deleteProject";
$cListProject	= "select * from final.get_Projects()";
include_once 'Models/workflow.php';
class project{
	private $p_id;
	private $p_name;
	private $p_wf;
	private $printing;

	//Sets the project workflow
	public function set_p_wf($p_wf){
		$wf = new Workflow();
		$wf->set_wf_name($p_wf);
		$this->p_wf = $wf->get_wf_id();
	}
 
	//Sets the project name, checks if project name already exists
	public function set_p_name($p_name){
		$this->p_name = $p_name;
		$this->init();
	}
 
	//Retrieves this project's id
	public function get_p_id(){
		return $this->p_id;
	}
	
	//Checks for existing project of the set project name. 
	//If project exists, data is saved in class vars
	public function init(){
		if($this->p_name != NULL){
			global $cSelectProject;
			$queryStr = $cSelectProject."('{$this->p_name}')";
			$returnedVal = runTableDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->p_id = $returnedVal["p_id"];
				$this->p_name = $returnedVal["p_name"];
				$this->p_wf = $returnedVal["p_wf"];
			}
		}
	}
	
	//Creates a project using the project name and workflow
	public function create(){
		global $cCreateProject; 
		if($this->p_id == NULL){
			$queryStr = $cCreateProject."('{$this->p_wf}','{$this->p_name}','')";
			$returnedVal = runScalarDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->p_id = $returnedVal;				
			}
		}
	}
 
	//Deletes a project with the set project name
	public function delete(){
		if($this->p_name != NULL){
			global $cDeleteProject;
			$queryStr = $cDeleteProject."('{$this->p_name}')";
			runScalarDbQuery($queryStr);
		}
	}

	//Retrieves a list of all projects
	public function getAllprojects(){
		global $cListProject;
		$queryStr = $cListProject;
		$this->printing = "All projects have been created:\n";
		$this->printing .= "Name | Description | Workflow\n";  
		runSetDbQuery($queryStr, array($this, 'projectPrintLine'));
		return $this->printing;
	}
	
	//Call back function to print all the records in the dataset.
	function projectPrintLine($row){
		$this->printing .= $row['prj_name']." | ". $row['description'] ." | ". $row['p_wf']."\n";
	}
}
?>
