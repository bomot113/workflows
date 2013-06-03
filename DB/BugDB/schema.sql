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
	primary key (wf_id),
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
	SELECT status.status_id INTO local_status_id
	FROM final.status status
	WHERE status.status_name = $1;

	IF (local_status_id is null) THEN 
		INSERT INTO final.status (status_name, description) values ($1, $2);
		SELECT currval('final.status_status_id_seq') INTO local_status_id;
	ELSE
		UPDATE final.status 
		SET description = $2
		WHERE status_id = local_status_id;
	END IF;
	
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

CREATE OR REPLACE FUNCTION final.drop_link_nodes(integer, integer)
  RETURNS integer AS
$$ 
BEGIN
	-- Drop the Link between 2 nodes together
	DELETE
	FROM final.link link
	WHERE link.startStatus_id = $1 AND link.endstatus_id = $2;

	-- return the success status
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.drop_link_nodes(9,8)

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

create table final.project(
	prj_id serial not null,
	prj_name varchar(255) UNIQUE,
	description text,
	wf_id int not null,
	primary key (prj_id),
	foreign key (wf_id) references final.workflow(wf_id) on delete no action
)

CREATE OR REPLACE FUNCTION final.create_project(integer, varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_prj_id integer;
BEGIN
	INSERT INTO final.project (wf_id, prj_name, description) 
	VALUES ($1, $2, $3);
	SELECT currval('final.project_prj_id_seq') INTO local_prj_id;		
	-- Return prj_id to the application
	RETURN local_prj_id;
END;
$$ LANGUAGE plpgsql;
-- select final.create_project(2, 'INFO445 final project','an awesome class')

CREATE OR REPLACE FUNCTION final.get_projects() 
	RETURNS TABLE (prj_name varchar(255), description text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT prj.prj_name, prj.description 
	FROM final.project prj;
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_projects()

CREATE OR REPLACE FUNCTION final.delete_project(varchar(255)) 
	RETURNS VOID 
AS $$ 
DECLARE
	local_prj_id integer;
BEGIN
	DELETE
	FROM final.project
	WHERE prj_name=$1;		
	-- Return prj_id to the application
END;
$$ LANGUAGE plpgsql;
-- select final.delete_project(2)

create table final.user(
	usr_id serial not null,
	usr_name varchar(255) UNIQUE,
	primary key (usr_id)
)

CREATE OR REPLACE FUNCTION final.create_user(varchar(255)) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_usr_id integer;
BEGIN
	INSERT INTO final.user (usr_name) 
	VALUES ($1);
	SELECT currval('final.user_usr_id_seq') INTO local_usr_id;		
	-- Return prj_id to the application
	RETURN local_usr_id;
END;
$$ LANGUAGE plpgsql;
-- select * from final.create_user('tue')

CREATE OR REPLACE FUNCTION final.delete_user(varchar(255)) 
	RETURNS VOID 
AS $$ 
BEGIN
	DELETE
	FROM final.user
	WHERE usr_name=$1;		
	-- Return prj_id to the application
END;
$$ LANGUAGE plpgsql;
-- select final.delete_user('tue')

CREATE OR REPLACE FUNCTION final.get_users() 
	RETURNS TABLE (usr_id integer, usr_name varchar(255)) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT usr.usr_id, usr.usr_name 
	FROM final.user usr;
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_users()

create table final.Project_User_Role (
	usr_id integer not null,
	prj_id integer not null,
	primary key (usr_id, prj_id),
	foreign key (usr_id) references final.user(usr_id) on delete no action,
	foreign key (prj_id) references final.project(prj_id) on delete no action
)

CREATE OR REPLACE FUNCTION final.assign_user_project(varchar(255), varchar(255)) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_usr_id integer;
	local_prj_id integer;

BEGIN
	
	SELECT prj_usr.usr_id into local_usr_id
	FROM final.Project_User_Role prj_usr
		INNER JOIN final.user usr
			ON prj_usr.usr_id = usr.usr_id
		INNER JOIN final.project prj
			ON prj_usr.prj_id = prj.prj_id
	WHERE usr.usr_name = $1 AND prj.prj_name = $2;

	IF (local_usr_id is NULL) THEN

		SELECT usr.usr_id into local_usr_id
		FROM final.user usr
		WHERE usr.usr_name = $1;

		SELECT prj.prj_id into local_prj_id
		FROM final.project prj
		WHERE prj.prj_name = $2;

		INSERT INTO final.Project_User_Role (usr_id, prj_id)
		VALUES (local_usr_id, local_prj_id);
		RETURN 1;
	END IF;
	-- Return failed to the application
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
-- select * from final.assign_user_project('tue', 'INFO445 final project')

CREATE OR REPLACE FUNCTION final.get_all_user_in_project(varchar(255)) 
	RETURNS TABLE (usr_name varchar(255), usr_id integer) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT usr.usr_name, usr.usr_id
	FROM final.Project_User_Role prj_usr
		INNER JOIN final.user usr
			ON prj_usr.usr_id = usr.usr_id
		INNER JOIN final.project prj
			ON prj_usr.prj_id = prj.prj_id
	WHERE prj.prj_name = $1;
	
END;
$$ LANGUAGE plpgsql;
-- 	SELECT * from final.get_all_user_in_project('INFO445 final project');

create table final.Bug (
	bug_id serial not null,
	prj_id integer not null,
	status_id integer not null,
	bug_title varchar(255),
	date_created timestamp not null,
	content text,
	primary key (bug_id),
	foreign key (prj_id) references final.project(prj_id) on delete no action,
	foreign key (status_id) references final.status(status_id) on delete no action
)

CREATE OR REPLACE FUNCTION final.create_bug(varchar(255), varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_prj_id integer;
	local_status_id integer;

BEGIN
	-- get the prj_id and status_id first
	SELECT 	prj.prj_id,link.endstatus_id
			into local_prj_id, local_status_id
	FROM final.project prj
		INNER JOIN final.workflow wf
			ON prj.wf_id = wf.wf_id
		INNER JOIN final.link link
			ON wf.start_status_id = link.startstatus_id

	WHERE prj.prj_name = $1;

	-- get the initial status

	IF (local_status_id is not null) THEN
		INSERT INTO final.Bug (prj_id, status_id, date_created, bug_title, content)
		VALUES (local_prj_id, local_status_id, now(), $2, $3);
		RETURN 1;
	END IF;
	-- Return success to the application
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
-- select * from final.create_bug('INFO445 final project','cannot log in','It keeps raising ERRORS')

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

CREATE OR REPLACE FUNCTION final.delete_bug(integer) 
	RETURNS INTEGER 
AS $$ 

BEGIN
	DELETE 
	FROM final.bug bug
	WHERE bug.bug_id = $1;
	-- Return success to the application
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.delete_bug(1)

CREATE OR REPLACE FUNCTION final.get_all_bugs_in_project(varchar(255)) 
	RETURNS TABLE (bug_id integer, bug_title varchar(255), status varchar(255), content text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT bug.bug_id, bug.bug_title, status.status_name, bug.content
	FROM final.bug bug
		INNER JOIN final.project prj
			ON prj.prj_id = bug.prj_id
		INNER JOIN final.status status
			ON bug.status_id = status.status_id
	WHERE prj.prj_name = $1;
	
END;
$$ LANGUAGE plpgsql;
-- 	SELECT * from final.get_all_bugs_in_project('INFO445 final project');

create table final.users_bug_rel (
	usr_id integer not null,
	bug_id integer not null,
	role varchar(255),
	primary key (usr_id, bug_id),
	foreign key (usr_id) references final.user(usr_id) on delete cascade,
	foreign key (bug_id) references final.bug(bug_id) on delete cascade
)


CREATE OR REPLACE FUNCTION final.assign_user_bug(varchar(255), integer, varchar(255)) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_usr_id integer;

BEGIN
	
	SELECT usr.usr_id into local_usr_id
	FROM final.users_bug_rel usr_bug
		INNER JOIN final.user usr
			ON usr_bug.usr_id = usr.usr_id
		INNER JOIN final.bug bug
			ON usr_bug.bug_id = bug.bug_id
	WHERE usr.usr_name = $1 AND bug.bug_id = $2;

	IF (local_usr_id is NULL) THEN

		SELECT usr.usr_id into local_usr_id
		FROM final.user usr
		WHERE usr.usr_name = $1;

		INSERT INTO final.users_bug_rel (usr_id, bug_id, role)
		VALUES (local_usr_id, $2, $3);
		RETURN 1;
	END IF;
	-- Return failed to the application
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
-- select * from final.assign_user_bug('tue', 2, 'bug owner')

CREATE OR REPLACE FUNCTION final.get_all_bugs_for_user(varchar(255)) 
	RETURNS TABLE (bug_id integer, bug_title varchar(255), status varchar(255), content text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT bug.bug_id, bug.bug_title, status.status_name, bug.content
	FROM final.users_bug_rel usr_bug 
		INNER JOIN final.bug bug
			ON usr_bug.bug_id = bug.bug_id 
		INNER JOIN final.user usr
			ON usr_bug.usr_id = usr.usr_id
		INNER JOIN final.status status
			ON bug.status_id = status.status_id
	WHERE usr.usr_name = $1;
	
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_all_bugs_for_user('tue')

CREATE OR REPLACE FUNCTION final.get_all_users_for_bug(integer) 
	RETURNS TABLE (usr_name varchar(255), role varchar(255)) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT usr.usr_name, usr_bug.role
	FROM final.users_bug_rel usr_bug 
		INNER JOIN final.bug bug
			ON usr_bug.bug_id = bug.bug_id 
		INNER JOIN final.user usr
			ON usr_bug.usr_id = usr.usr_id

	WHERE bug.bug_id = $1;
	
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_all_users_for_bug(2)

CREATE OR REPLACE FUNCTION final.unassign_user_bug(varchar(255), integer) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_usr_id integer;

BEGIN
	SELECT usr.usr_id into local_usr_id
	FROM final.user usr
	WHERE usr.usr_name = $1;

	IF (local_usr_id is not null) THEN
		DELETE
		FROM final.users_bug_rel usr_bug
		WHERE usr_bug.usr_id = local_usr_id AND usr_bug.bug_id = $2;
	END IF;
	-- Return failed to the application
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.unassign_user_bug('tue', 2)

create table final.tag (
	tag_id serial not null,
	name varchar(255) UNIQUE,
	primary key (tag_id)
)

create table final.tag_bug (
	tag_id integer not null,
	bug_id integer not null,
	primary key (tag_id, bug_id)
)

CREATE OR REPLACE FUNCTION final.assign_tag_to_bug(varchar(255), integer) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_tag_id integer;

BEGIN
	SELECT tag.tag_id into local_tag_id
	FROM final.tag tag
	WHERE tag.name = $1;

	IF (local_tag_id is null) THEN
		INSERT INTO final.tag (name) VALUES ($1);
		SELECT	currval('final.tag_tag_id_seq') INTO local_tag_id;
	END IF;

	INSERT INTO final.tag_bug (tag_id, bug_id) VALUES
	SELECT (local_tag_id, $2)
	WHERE (local_tag_id, $2) NOT IN (SELECT tag_id, bug_id FROM final.tag_bug);

	-- Return failed to the application
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.assign_tag_to_bug('funny', 2)

CREATE OR REPLACE FUNCTION final.unassign_tag_bug(varchar(255), integer) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_tag_id integer;

BEGIN
	SELECT tag.tag_id into local_tag_id
	FROM final.tag tag
	WHERE tag.name = $1;

	IF (local_tag_id is not null) THEN
		DELETE
		FROM final.tag_bug tag_bug
		WHERE tag_bug.tag_id = local_tag_id AND tag_bug.bug_id = $2;
	END IF;
	-- Return failed to the application
	RETURN 1;
END;
$$ LANGUAGE plpgsql;
-- select * from final.unassign_tag_bug('LOL', 2)

CREATE OR REPLACE FUNCTION final.get_all_tags_for_bug(integer) 
	RETURNS TABLE (name varchar(255)) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT tag.name
	FROM final.tag_bug tag_bug 
		INNER JOIN final.tag tag
		ON tag_bug.tag_id = tag.tag_id
	WHERE tag_bug.bug_id = $1;
	
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_all_tags_for_bug(2)

CREATE OR REPLACE FUNCTION final.get_all_bugs_for_tag(varchar(255)) 
	RETURNS TABLE (bug_id integer, bug_title varchar(255), status varchar(255), content text) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT bug.bug_id, bug.bug_title, status.status_name, bug.content
	FROM final.tag_bug tag_bug 
		INNER JOIN final.bug bug
			ON tag_bug.bug_id = bug.bug_id 
		INNER JOIN final.tag tag
			ON tag_bug.tag_id = tag.tag_id
		INNER JOIN final.status status
			ON bug.status_id = status.status_id
	WHERE tag.name = $1;	
END;
$$ LANGUAGE plpgsql;
-- select * from final.get_all_bugs_for_tag('LOL')

