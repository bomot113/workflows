<?php
$cSelectTag = "select * from indv.selectTag";
$cCreateTag = "select * from indv.createTag";
$cUpdateTag = "select * from indv.UpdateTag";
$cListTag	= "select * from indv.getTags()";

class tag{
	private $t_list;
	private $t_bug;
	private $printing;

	//Sets the list of tags
	public function set_t_list($t_list){
		$this->t_list = $t_list;
	}
 
	//Sets the bug these tags are related to
	public function set_t_bug($t_bug){
		$this->t_bug = $t_bug;
		$this->init();
	}

	//Gets the bug that this tag list belongs to
	public function get_t_bug(){
		return $this->t_bug;
	}
	
	//Checks for existing tags for set bug 
	//If tag list exists, data is saved in class vars
	public function init(){
		if($this->t_bug != NULL){
			global $cSelectTag;
			$queryStr = $cSelectTag."('{$this->t_bug}')";
			$returnedVal = runTableDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->t_bug = $returnedVal["t_bug"];
				$this->t_list = $returnedVal["t_list"];
			}
		}
	}
 
	//Creates a tag with the set tag list and bug name
	public function create(){
		global $cCreateTag; 
		if($this->t_id == NULL){
			$queryStr = $cCreateTag."('{$this->t_bug}','{$this->t_list}')";
			$returnedVal = runScalarDbQuery($queryStr);
			if($returnedVal != NULL){
				$this->t_id = $returnedVal;				
			}
		}
	}	
 
	//Adds the given tags to an existing tag list
	public function update(){
		if($this->t_bug != NULL){
			global $cUpdateTag;
			$queryStr = $cUpdateTag."('{$this->t_bug}', '{$this->t_list}')";
			runScalarDbQuery($queryStr);
		}
	}

	//Retrieves all of the tags
	public function getAlltags(){
		global $cListTag;
		$queryStr = $cListTag;
		$this->printing = "All tags have been created:\n";
		$this->printing .= "Tags | Bug\n";  
		runSetDbQuery($queryStr, array($this, 'tagPrintLine'));
		return $this->printing;
	}
		
	//	Call back function to print all the records in the dataset. 
	function tagPrintLine($row){
		$this->printing .= $row['t_list']." | ". $row['t_bug']."\n";
	}
}
?>
