<?php
$cSelectBug = "select * from indv.selectBug";
$cCreateBug = "select * from indv.createBug";
$cDeleteBug = "select * from indv.deleteBug";
$cListBug	= "select * from indv.getBugs()";

class bug{
	private $b_id;
	private $b_name;
	private $b_project;
	private $b_creator;
	private $b_responsible;
	private $printing;

	//Sets the Bug name, checks if any bug with this name already exists
	public function set_b_name($b_name){
		$this->b_name = $b_name;
		$this->init();
	}
	
	//Sets the project the bug belongs to
	public function set_b_project($b_project){
		$this->b_project = $b_project;
	}
	
	//Sets the creator of this bug
	public function set_b_creator($b_creator){
		$this->b_creator = $b_creator;
	}
	
	//Sets the developer responsible for this bug
	public function set_b_responsible($b_responsible){
		$this->b_responsible = $b_responsible;
	}

	//Checks for existing Bugs with set name. 
	//If Bug exists, data is saved in class vars
	public function init(){
		if($this->b_name != NULL){
			global $cSelectBug;
			$queryStr = $cSelectBug."('{$this->b_name}')";
			$returnedVal = runTableDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->b_id = $returnedVal["b_id"];
				$this->b_name = $returnedVal["b_name"];
				$this->b_project = $returnedVal["b_project"];
				$this->b_creator = $returnedVal["b_creator"];
				$this->b_responsible = $returnedVal["b_responsible"];
			}
		}
	}

	//Creates a Bug with the set Bug name
	public function create(){
		global $cCreateBug; 
		if($this->b_id == NULL){
			$queryStr = $cCreateBug."(".$this->b_name.", ".$this->b_project.", ".$this->b_creator.", ".$this->b_responsible.")";
			$returnedVal = runScalarDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->b_id = $returnedVal;				
			}
		}
	}
 
	//Delete a Bug with the set Bug name
	public function delete(){
		if($this->b_name != NULL){
			global $cDeleteBug;
			$queryStr = $cDeleteBug."('{$this->b_name}')";
			runScalarDbQuery($queryStr);
		}
	}
 
	//Retrieves a list of all the Bugs
	public function getAllBugs(){
		global $cListBug;
		$queryStr = $cListBug;
		$this->printing = "All Bugs have been created:\n";
		$this->printing .= "Name | Project | Creator | Responsible \n";  
		runSetDbQuery($queryStr, array($this, 'BugPrintLine'));
		return $this->printing;
	}
	
	//Call back function to print all the records in the dataset.
	function BugPrintLine($row){
		$this->printing .= $row['b_name']." | ".$row['b_project']." | ".$row['b_creator']." | ".$row['b_responsible']."\n";
	}
}
?>
