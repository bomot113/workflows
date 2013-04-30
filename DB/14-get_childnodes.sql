CREATE OR REPLACE FUNCTION indv.get_childnodes(integer) 
	RETURNS TABLE (childnode_n_sn varchar(255), from_n_sn varchar(255), linkinfo text) 
AS $$ 
BEGIN
	RETURN QUERY
	with recursive cte_tree(childnode_n_sn, childnode_n_id, from_n_sn, linkinfo) as (
	select 	childnode.n_sn as childnode_n_sn, 
		childnode.n_id as childnode_n_id,
		node.n_sn as from_n_sn, 
		link.label as linkinfo
	from indv.node node
	  inner join indv.link link
		  on node.n_id = link.startnode_id
	  inner join indv.node childnode
		  on link.endnode_id = childnode.n_id
	where node.n_id = $1
	
    UNION ALL
	select childnode.n_sn as childnode_n_sn, 
		childnode.n_id as childnode_n_id,
		cte.childnode_n_sn as from_n_sn, 
		link.label as linkinfo
	from cte_tree cte
	 inner join indv.link link
	         on cte.childnode_n_id = link.startnode_id
	 inner join indv.node childnode
		  on link.endnode_id = childnode.n_id
	) 
	select tree.childnode_n_sn, tree.from_n_sn, tree.linkinfo
	from cte_tree tree
	group by tree.childnode_n_sn, tree.from_n_sn, tree.linkinfo;

END;
$$ LANGUAGE plpgsql;