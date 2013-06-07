<?php
$cSelectWorkflow = "select * from final.select_workflow";
$cCreateWorkflow = "select * from final.create_workflow";
$cDeleteWorkflow = "select * from final.delete_workflow";
$cListWorkflow	 = "select * from final.get_workflows()";
$cGetNodes 			 = "select * from final.get_Status_by_workflow";
$cLinkWF			 	 = "select * from final.link_WF";
$cLinkNodes			 = "select * from final.link_nodes";
class workflow {
	private $wf_id;
	private $wf_name;
	private $wf_info;
	private $printing;
	 /*
		* Constructor
		*
		*/
	public function __construct(){
		//nothing to do here.	
	}

 /*
	* setter of wf_info
	*/	
	public function set_wf_info($wf_info){
		$this->wf_info = $wf_info;
	}
 /*
	* setter of wf_name
	*/	
	public function set_wf_name($wf_name){
		$this->wf_name = $wf_name;
		// check if there's any wf with that name in DB
		$this->init();
	}
 /*
	* getter of wf_id
	*/	
	public function get_wf_id(){
		return $this->wf_id;
	}
	/* 
	 * access database to check if there's any existing
	 * workflow with that wf_name
	 */
	public function init(){
		if ($this->wf_name != NULL) {
			global $cSelectWorkflow;
			$queryStr = $cSelectWorkflow."('{$this->wf_name}')";
			$returnedVal = runTableDbQuery($queryStr);
			if ($returnedVal != NULL){
				$this->wf_id = $returnedVal["wf_id"];
				$this->wf_name = $returnedVal["wf_name"];
				$this->wf_info = $returnedVal["description"];
			}
		}
	}
 /*
	* Create a workflow with wf_name and wf_id
	*/
	public function create(){
		global $cCreateWorkflow; 
		if ($this->wf_id == NULL) {
			$queryStr = $cCreateWorkflow."('{$this->wf_name}','{$this->wf_info}')";
			$returnedVal = runScalarDbQuery($queryStr);
			if($returnedVal != NULL) {
				$this->wf_id = $returnedVal;				
			}
		}
	}	
 /*
	* Delete a workflow with wf_name and wf_id
	*/
	public function delete(){
		if ($this->wf_name != NULL) {
			global $cDeleteWorkflow;
			$queryStr = $cDeleteWorkflow."('{$this->wf_name}')";
			runScalarDbQuery($queryStr);
		}
	}	
 /*
	* List all workflows
	*/
	public function getAllWorkflows(){
		global $cListWorkflow;
		$queryStr = $cListWorkflow;
		$this->printing = "All workflows have been created:\n";
		$this->printing .= "Name | Info\n";  
		runSetDbQuery($queryStr, array($this, 'workflowPrintLine'));
		return $this->printing;
	}
	/*
	 * a Call back function to print all the records in the dataset.
	 */
	function workflowPrintLine($row)
	{
		$this->printing .= $row['wf_name']." | ". $row['wf_info']."\n";
	}	
 /*
	* List all Nodes
	*/
	public function getNodes(){
		global $cGetNodes;
		$queryStr = $cGetNodes."('{$this->wf_name}');";
		$this->printing = "Statuses in workflow $this->wf_name:\n";
		$this->printing .= "Status_id | Status Name | Description | \n";  
		runSetDbQuery($queryStr, array($this, 'nodePrintLine'));
		return $this->printing;
	}
	/*
	 * a Call back function to print all the records in the dataset.
	 */
	function nodePrintLine($row)
	{
		$this->printing .= $row['status_id']." | ". $row['status_name']." | ".$row['description']."\n";
	}	

 /*
	* Link the start/end node of the workflow to another node
	*/
	public function link_WF($n_id,$label,$pos){
		global $cLinkWF;
		$queryStr = $cLinkWF."('{$this->wf_id}','{$n_id}','{$label}','{$pos}');";
		runScalarDbQuery($queryStr);
	}

 /*
	* Link nodes together
	*/
	public function link_nodes($n_id_from, $n_id_to, $label){
		global $cLinkNodes;
		$queryStr = $cLinkNodes."('{$n_id_from}','{$n_id_to}','{$label}');";
		runScalarDbQuery($queryStr);
	}

}
?>
