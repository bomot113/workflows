<?php
/*
 * filename: workflow.php 
 */
//include_once "DBVars.php";

class Workflow 
{
  private $_name;
  private $_id;
  private $info;
  
  /*
   * construction
   */
  public function __construct($name,$info){
   	$this->_name = $name;
   	$this->_info = $info;
  }

  /*
   *  Create new workflow by name
   */
  public function create(){
  	   
		return "A new workflow named $this->_name has been created";	
  }
}

?>

