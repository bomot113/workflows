CREATE OR REPLACE FUNCTION indv.link_WF(integer, integer, text, char(1)) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_link_id integer;
	local_id integer;
BEGIN
	-- Get start node id through the workflow id.
	SELECT node.n_id into local_id 
	FROM indv.workflow wf
	INNER JOIN indv.node node
	  ON wf.wf_id = node.wf_id
	WHERE wf.wf_id =$1 and node.n_type=$4;

	-- Link 2 nodes together
	IF ($4 = 'S') THEN
		INSERT INTO indv.link (startNode_id, endNode_id, label) values (local_id, $2, $3);
	ELSEIF ($4 = 'E') THEN
		INSERT INTO indv.link (startNode_id, endNode_id, label) values ($2, local_id, $3);
	ELSE
		-- DO NOTHING HERE
	END IF;
	SELECT currval('indv.link_link_id_seq') INTO local_id;
	RETURN local_link_id;
END;
$$ LANGUAGE plpgsql;
