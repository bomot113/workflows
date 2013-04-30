CREATE OR REPLACE FUNCTION indv.create_workflow(varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_wf_id integer;
BEGIN
	-- create new workflow
	INSERT INTO indv.workflow (wf_name, wf_info) values ($1, $2);
	SELECT currval('indv.workflow_wf_id_seq') INTO local_wf_id;
	-- Create a new start node for this workflow
	INSERT INTO indv.node (wf_id, n_sn, n_type, n_name) 
	VALUES (local_wf_id,'Start','S','Start');
	-- Create a new end node for this workflow
	INSERT INTO indv.node (wf_id, n_sn, n_type, n_name) 
	VALUES (local_wf_id,'End','E','End');
	-- Return wf_id to the application
	RETURN local_wf_id;
END;
$$ LANGUAGE plpgsql;
