CREATE OR REPLACE FUNCTION indv.select_node(integer, varchar(255)) 
	RETURNS INTEGER 
AS $$ 
DECLARE 
	local_n_id integer;
BEGIN
	SELECT node.n_id INTO local_n_id
	FROM indv.node node 
	WHERE node.wf_id = $1 
	  and node.n_sn = $2s;
	RETURN local_n_id;
END;
$$ LANGUAGE plpgsql;