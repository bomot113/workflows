CREATE OR REPLACE FUNCTION final.get_child_statuses(integer) 
	RETURNS TABLE (to_status_id integer, to_status varchar(255), to_status_desc text,
		from_status_id integer, from_status varchar(255),  linkinfo text) 
AS $$ 
BEGIN
	RETURN QUERY
	with recursive cte_tree(to_status_id, to_status, from_status_id, from_status, to_status_desc, linkinfo) as (
	select 	childstatus.status_id as to_status_id, 
		childstatus.status_name as to_status,
		childstatus.description as to_status_desc,
		status.status_id as from_status_id,
		status.status_name as from_status, 
		link.description as linkinfo
	from final.status status
	  inner join final.link link
		  on status.status_id = link.startstatus_id
	  inner join final.status childstatus
		  on link.endstatus_id = childstatus.status_id
	where status.status_id = $1
	
    UNION ALL
	select 	childstatus.status_id as to_status_id, 
		childstatus.status_name as to_status,
		childstatus.description as to_status_desc,
		cte.to_status_id as from_status_id,
		cte.to_status as from_status,
 		link.description as linkinfo
	from cte_tree cte
	inner join final.link link
	        on cte.to_status_id = link.startstatus_id
	inner join final.status childstatus
		on link.endstatus_id = childstatus.status_id
	) 
	select 	
		tree.to_status_id, tree.to_status, tree.to_status_desc,
		tree.from_status_id, tree.from_status,
		tree.linkinfo
	from cte_tree tree
	group by tree.to_status_id, tree.to_status, 
		tree.from_status_id, tree.from_status,
		tree.to_status_desc, tree.linkinfo;

END;
$$ LANGUAGE plpgsql;
-- select * from final.get_child_statuses(7)

CREATE OR REPLACE FUNCTION final.delete_bug(varchar(255), varchar(255)) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_bug_id integer;

BEGIN
	-- get the bug_id first
	SELECT 	bug.bug_id into local_bug_id
	FROM final.project prj
		INNER JOIN final.bug bug
			ON prj.prj_id = bug.prj_id
	WHERE prj.prj_name = $1 AND bug.bug_title=$2;

	DELETE 
	FROM final.bug bug
	WHERE bug.bug_id = local_bug_id;
	-- Return success to the application
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.delete_bug('INFO445 final project','cannot log in')