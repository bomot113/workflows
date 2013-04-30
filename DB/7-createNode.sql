CREATE OR REPLACE FUNCTION indv.create_node(integer, varchar(255), char(1), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_n_id integer;
BEGIN
	INSERT INTO indv.node (wf_id, n_sn, n_type, n_name) values ($1, $2, $3, $4);
	SELECT currval('indv.node_n_id_seq') INTO local_n_id;
	RETURN local_n_id;
END;
$$ LANGUAGE plpgsql;

