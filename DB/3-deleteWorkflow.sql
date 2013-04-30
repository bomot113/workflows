CREATE OR REPLACE FUNCTION indv.delete_workflow(varchar(255)) 
	RETURNS VOID 
AS $$ 
DECLARE
	local_wf_id integer;
BEGIN
	DELETE 
	FROM indv.workflow wf 
	WHERE wf.wf_name = $1;
END;
$$ LANGUAGE plpgsql;