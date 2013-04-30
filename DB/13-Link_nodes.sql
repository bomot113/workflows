CREATE OR REPLACE FUNCTION indv.link_nodes(integer, integer, text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_link_id integer;
BEGIN
	-- Link 2 nodes together
	INSERT INTO indv.link (startNode_id, endNode_id, label) values ($1, $2, $3);
	SELECT currval('indv.link_link_id_seq') INTO local_link_id;
	RETURN local_link_id;
END;
$$ LANGUAGE plpgsql;
