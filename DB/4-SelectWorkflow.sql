CREATE OR REPLACE FUNCTION indv.select_workflow(varchar(255)) 
	RETURNS TABLE(wf_id integer, wf_name character varying, wf_info text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT wf.wf_id, wf.wf_name, wf.wf_info 
	FROM indv.workflow wf 
	WHERE wf.wf_name = $1;
END;
$$ LANGUAGE plpgsql;