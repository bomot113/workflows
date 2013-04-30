CREATE OR REPLACE FUNCTION indv.get_workflows() 
	RETURNS TABLE (wf_name varchar(255), wf_info text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT wf.wf_name, wf.wf_info 
	FROM indv.workflow wf;
END;
$$ LANGUAGE plpgsql;