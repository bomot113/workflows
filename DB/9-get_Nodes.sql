CREATE OR REPLACE FUNCTION indv.get_Nodes(varchar(255)) 
	RETURNS TABLE (n_sn varchar(255), n_type char(1), n_name text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT node.n_sn, node.n_type, node.n_name 
	FROM indv.node node
	INNER JOIN indv.workflow wf
	 on node.wf_id = wf.wf_id
	WHERE wf.wf_name=$1;
END;
$$ LANGUAGE plpgsql;