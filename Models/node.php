<?php
$cCreateNode = "select * from indv.create_node";
$cSelectNode = "select * from indv.select_node";
$cSelectChildnodes = "select * from indv.get_childnodes";
class node {
	private $n_id;
	private $printing;
	public function get_n_id(){
		return $this->n_id;
	}

	/*
	 * Constructor
	 *
	 */
	public function __construct(){
		//nothing to do here.	
	}

	public function init($wf_id, $n_sn){
		global $cSelectNode; 
		$queryStr = $cSelectNode."('{$wf_id}','{$n_sn}')";
		$returnedVal = runScalarDbQuery($queryStr);
		if($returnedVal != NULL) $this->n_id = $returnedVal;
	}
  /*
	 * Create a node
	 */
	public function create($wf_id, $n_sn, $n_type, $n_name){
		global $cCreateNode;
		if ($this->n_id == NULL){
			$queryStr = $cCreateNode."('{$wf_id}','{$n_sn}',
															 '{$n_type}','{$n_name}')";
			$returnedVal = runScalarDbQuery($queryStr);
			if($returnedVal != NULL) {
				$this->n_id = $returnedVal;				
		
			}
		}
	}	
  /*
	 * Collect all info of childnodes belonging to the node
	 */
	public function list_childnodes(){
		global $cSelectChildnodes;
		if ($this->n_id != NULL){
			$queryStr = $cSelectChildnodes."('{$this->n_id}')";
			$this->printing = "All childnodes and their linking information:\n";
			$this->printing = "Child Node SN | Start From Node | Guard Label \n ";
			runSetDbQuery($queryStr, array($this, "printNodes"));
			return $this->printing;
		}
	}	

	public function printNodes($row){
		$this->printing .=  $row['childnode_n_sn']." | ". $row['from_n_sn']." | ".$row['linkinfo']."\n";
	}
}
?>
