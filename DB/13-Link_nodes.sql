CREATE OR REPLACE FUNCTION indv.link_nodes(integer, integer, text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_link_id integer;
BEGIN
	-- Link 2 nodes together
	SELECT link_id INTO local_link_id 
	FROM indv.link
	WHERE startNode_id = $1 and endNode_id = $2;

	IF (local_link_id is null) THEN
		INSERT INTO indv.link (startNode_id, endNode_id, label) values ($1, $2, $3);
		SELECT currval('indv.link_link_id_seq') INTO local_link_id;
	ELSE 
		UPDATE indv.link
		SET 
		label = $3
		WHERE startNode_id = $1 and endNode_id = $2;
	END IF;
	RETURN local_link_id;
END;
$$ LANGUAGE plpgsql;
