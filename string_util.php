<?php
/* 
 * remove all " at the end and begining of a string
 * to make it easier to execute psql
 */
function psqlString(&$cmd_list) {
	foreach($cmd_list as $key=>$cmd) {
		$len = strlen($cmd);
		if ($len == 0) continue;
		if($cmd[0] == '"' || $cmd[0]=='\'' ) {
			$cmd[0] = ' ';
		}
		if($len > 0 && (($cmd[$len-1] =='"') || ($cmd[$len-1]=='\''))){
			$cmd[$len-1] = ' ';
		}
		$cmd_list[$key] = trim($cmd);
	}
}
/* 
 * search for an param option in the commandlist
 *
 */
function search_cmdOpt($cmd_list, $opt) {
  global $gResult;
  $found = false;
  foreach($cmd_list as $aStr){
    if ($found) {
		  return ((strlen($aStr)>0) || ($aStr[0]!='-')) ? $aStr : ""; 
		}
    if($aStr == '-'.$opt) $found = true;
  }
  if($found) $gResult = ('Couldn\'t find the value for -'.$opt);
  return ""; 
}
?>
