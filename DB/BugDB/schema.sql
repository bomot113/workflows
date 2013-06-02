create schema final;
create table final.status (
	status_id serial not null,
	status_name varchar(255) not null,
	description text,
	primary key (status_id));

create table final.workflow(
	wf_id serial not null,
	wf_name varchar(255),
	description text,
	start_status_id int not null,
	final_status_id int not null,
	foreign key (start_status_id) references final.status(status_id) on delete no action,
	foreign key (final_status_id) references final.status(status_id) on delete no action
)

CREATE OR REPLACE FUNCTION final.create_workflow(varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_start_status_id integer;
	local_final_status_id integer;
	local_wf_id integer;
BEGIN
	
	-- Create a new start status for this workflow
	INSERT INTO final.status (status_name, description) 
	VALUES ('Start', 'Start of the workflow ' || $1);
	SELECT currval('final.status_status_id_seq') INTO local_start_status_id;
	
	-- Create a new end status for this workflow
	INSERT INTO final.status (status_name, description)
	VALUES ('End', 'End of the workflow ' || $1);
	SELECT currval('final.status_status_id_seq') INTO local_final_status_id;
	
	-- create new workflow
	INSERT INTO final.workflow (wf_name, start_status_id, final_status_id, description) 
		values ($1, local_start_status_id, local_final_status_id, $2);
	SELECT currval('final.workflow_wf_id_seq') INTO local_wf_id;
	
	-- Return wf_id to the application
	RETURN local_wf_id;
END;
$$ LANGUAGE plpgsql;

-- select final.create_workflow('normal workflow','normal bug tracking follow for agile project')
CREATE OR REPLACE FUNCTION final.delete_workflow(varchar(255)) 
	RETURNS VOID 
AS $$ 
DECLARE
	local_start_status_id integer;
	local_final_status_id integer;
BEGIN
	
	SELECT 	wf.start_status_id, wf.final_status_id INTO local_start_status_id, 
			 local_final_status_id
	FROM final.workflow wf
	WHERE wf.wf_name = $1;
	
	DELETE 
	FROM final.workflow wf 
	WHERE wf.wf_name = $1;

	DELETE 
	FROM final.status st
	WHERE 	(st.status_id = local_start_status_id) OR
			(st.status_id = local_final_status_id);
END;
$$ LANGUAGE plpgsql;
-- select final.delete_workflow('normal workflow')

CREATE OR REPLACE FUNCTION final.select_workflow(varchar(255)) 
	RETURNS TABLE(wf_id integer, wf_name character varying, description text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT wf.wf_id, wf.wf_name, wf.description 
	FROM final.workflow wf 
	WHERE wf.wf_name = $1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.select_workflow('normal workflow')

CREATE OR REPLACE FUNCTION final.get_workflows() 
	RETURNS TABLE (wf_name varchar(255), wf_info text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT wf.wf_name, wf.description 
	FROM final.workflow wf;
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_workflows()

CREATE OR REPLACE FUNCTION final.create_status(varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_status_id integer;
BEGIN
	INSERT INTO final.status (status_name, description) values ($1, $2);
	SELECT currval('final.status_status_id_seq') INTO local_status_id;
	RETURN local_status_id;
END;
$$ LANGUAGE plpgsql;
-- select final.create_status('new','this bug has just been submitted')

create table final.link (
	link_id serial not null,
	startStatus_id integer not null,
	endStatus_id integer not null,
	description text,
	foreign key (startStatus_id) references final.status (status_id) on delete cascade,
	foreign key (endStatus_id) references final.status (status_id) on delete cascade,
	primary key (link_id)
)

CREATE OR REPLACE FUNCTION final.link_nodes(integer, integer, text)
  RETURNS integer AS
$$ 
DECLARE
	local_link_id integer;
BEGIN
	-- Link 2 nodes together
	SELECT link_id INTO local_link_id 
	FROM final.link
	WHERE startStatus_id = $1 and endStatus_id = $2;

	IF (local_link_id is null) THEN
		INSERT INTO final.link (startStatus_id, endStatus_id, description) 
			VALUES ($1, $2, $3);
		SELECT currval('final.link_link_id_seq') INTO local_link_id;
	ELSE 
		UPDATE final.link
		SET 
		label = $3
		WHERE link_id = local_link_id;
	END IF;
	RETURN local_link_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION final.link_wf(integer, integer, text, character)
  RETURNS integer 
AS $$ 
DECLARE
	local_link_id integer;
	local_id integer;
BEGIN
	-- Get start status id through the workflow id.
	SELECT wf.start_status_id into local_id 
	FROM final.workflow wf
	WHERE wf.wf_id =$1;

	-- Link 2 nodes together
	IF ($4 = 'S') THEN
		-- Get start status id through the workflow id.
		SELECT wf.start_status_id into local_id 
		FROM final.workflow wf
		WHERE wf.wf_id =$1;
		PERFORM final.link_nodes(local_id, $2, $3);

	ELSEIF ($4 = 'E') THEN
		SELECT wf.final_status_id into local_id 
		FROM final.workflow wf
		WHERE wf.wf_id =$1;
		PERFORM final.link_nodes($2, local_id, $3);
	ELSE
		-- DO NOTHING HERE
	END IF;
	RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- select final.link_wf(2, 9, 'raising a new bug', 'S')
-- select final.link_wf(2, 9, 'not a bug, you stupid!!!', 'E')


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

CREATE OR REPLACE FUNCTION final.get_Status_by_workflow(varchar(255)) 
	RETURNS TABLE (status_name varchar(255), description text) 
AS $$ 
DECLARE
	local_start_status_id integer;
	local_final_status_id integer;
BEGIN
	
	SELECT 	wf.start_status_id, wf.final_status_id INTO local_start_status_id, 
			 local_final_status_id
	FROM final.workflow wf
	WHERE wf.wf_name=$1;
	RETURN QUERY
	SELECT  cte.to_status as status_name,
			cte.to_status_desc as description
	FROM final.get_child_statuses(local_start_status_id) cte
	WHERE cte.to_status_id <> local_final_status_id;
END
$$ LANGUAGE plpgsql;
-- select * from final.get_Status_by_workflow('normal workflow');
