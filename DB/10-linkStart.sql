CREATE OR REPLACE FUNCTION indv.linkStart(integer, integer, text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_link_id integer;
	local_start_id integer;
BEGIN
	-- Get start node id through the workflow id.
	SELECT wf.n_id into local_start_id 
	FROM indv.workflow wf
	WHERE wf.wf_id =$1;

	-- Link 2 nodes together
	INSERT INTO indv.link (startNode_id, endNode_id, label) values ($1, $2, $3);
	SELECT currval('indv.link_link_id_seq') INTO local_start_id;
	RETURN local_link_id;
END;
$$ LANGUAGE plpgsql;

