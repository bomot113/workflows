<?php
$cSelectDeveloper = "select * from indv.selectDeveloper";
$cCreateDeveloper = "select * from indv.createDeveloper";
$cDeleteDeveloper = "select * from indv.deleteDeveloper";
$cListDeveloper	  = "select * from indv.getDevelopers()";

class developer{
	private $d_id;
	private $d_name;
	private $printing;

	//Sets the developer name, retrieves developer data if exists
	public function set_d_name($d_name){
		$this->d_name = $d_name;
		$this->init();
	}

	//Returns the id of this developer
	public function get_d_id(){
		return $this->d_id;
	}

	//Checks for existing developers with set name. 
	//If developer exists, data is saved in class vars
	public function init(){
		if($this->d_name != NULL){
			global $cSelectDeveloper;
			$queryStr = $cSelectDeveloper."('{$this->d_name}')";
			$returnedVal = runTableDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->d_id = $returnedVal["d_id"];
				$this->d_name = $returnedVal["d_name"];
			}
		}
	}

	//Creates a developer with the set developer name
	public function create(){
		global $cCreateDeveloper; 
		if($this->d_id == NULL){
			$queryStr = $cCreateDeveloper."('{$this->d_name}')";
			$returnedVal = runScalarDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->d_id = $returnedVal;				
			}
		}
	}	
 
	//Delete a developer with the set developer name
	public function delete(){
		if($this->d_name != NULL){
			global $cDeleteDeveloper;
			$queryStr = $cDeleteDeveloper."('{$this->d_name}')";
			runScalarDbQuery($queryStr);
		}
	}	
 
	//Retrieves a list of all the developers
	public function getAlldevelopers(){
		global $cListDeveloper;
		$queryStr = $cListDeveloper;
		$this->printing = "All developers have been created:\n";
		$this->printing .= "Name\n";  
		runSetDbQuery($queryStr, array($this, 'developerPrintLine'));
		return $this->printing;
	}
	
	//Call back function to print all the records in the dataset.
	function developerPrintLine($row){
		$this->printing .= $row['d_name']."\n";
	}	
}
?>
