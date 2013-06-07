
CREATE OR REPLACE FUNCTION final.create_workflow(varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_start_status_id integer;
	local_final_status_id integer;
	local_wf_id integer;
BEGIN
	-- create new workflow
	INSERT INTO final.workflow (wf_name, description) 
		values ($1, $2);
	SELECT currval('final.workflow_wf_id_seq') INTO local_wf_id;

	-- Create a new start status for this workflow
	INSERT INTO final.status (wf_id, status_name, description) 
	VALUES (local_wf_id, 'Start', 'Start of the workflow ' || $1);
	SELECT currval('final.status_status_id_seq') INTO local_start_status_id;
	
	-- Create a new end status for this workflow
	INSERT INTO final.status (wf_id, status_name, description)
	VALUES (local_wf_id, 'End', 'End of the workflow ' || $1);
	SELECT currval('final.status_status_id_seq') INTO local_final_status_id;
	
	-- update start and end statuses for the new workflow
	UPDATE final.workflow 
	SET 	(start_status_id, final_status_id) =  (local_start_status_id, local_final_status_id)
	WHERE wf_id = local_wf_id;
	
	-- Return wf_id to the application
	RETURN local_wf_id;
END;
$$ LANGUAGE plpgsql;
-- select final.create_workflow('normal workflow','normal bug tracking follow for agile project')

CREATE OR REPLACE FUNCTION final.delete_workflow(varchar(255)) 
	RETURNS VOID 
AS $$ 

BEGIN
	DELETE 
	FROM final.workflow wf 
	WHERE wf.wf_name = $1;
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

CREATE OR REPLACE FUNCTION final.create_status(integer, varchar(255), text) 
	RETURNS INTEGER 
AS $$ 
DECLARE
	local_status_id integer;

BEGIN
	SELECT status.status_id INTO local_status_id
	FROM final.status status
	WHERE status.wf_id = $1 AND status.status_name = $2;

	IF (local_status_id is null) THEN 
		INSERT INTO final.status (wf_id, status_name, description) values ($1, $2, $3);
		SELECT currval('final.status_status_id_seq') INTO local_status_id;
	ELSE
		UPDATE final.status 
		SET description = $3
		WHERE status_id = local_status_id;
	END IF;
	
	RETURN local_status_id;
END;
$$ LANGUAGE plpgsql;
-- select final.create_status('new','this bug has just been submitted')


CREATE OR REPLACE FUNCTION final.link_nodes(integer, integer, text)
  RETURNS integer AS
$$ 
DECLARE
	local_link_id integer;
	local_wf_id integer;
BEGIN
	-- if 2 nodes are not in the same workflow return with errors
	SELECT status1.wf_id into local_wf_id
	FROM final.status status1
	INNER JOIN final.status status2
		ON status1.wf_id = status2.wf_id
	WHERE status1.status_id = $1 AND status2.status_id = $2;

	IF (local_wf_id is NULL) THEN
		RETURN 0;
	END IF;

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
		description = $3
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

CREATE OR REPLACE FUNCTION final.get_NextStatus(integer) 
	RETURNS TABLE (status_id integer, status_name varchar(255), description text) 
AS $$ 
BEGIN
	
	RETURN QUERY
	SELECT  n_status.status_id, n_status.status_name, n_status.description
	FROM final.status status
	INNER JOIN final.link link
		ON status.status_id = link.startStatus_id
	INNER JOIN final.status n_status
		ON link.endstatus_id = n_status.status_id
	WHERE status.status_id = $1;

END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION final.get_Status_by_workflow(varchar(255)) 
	RETURNS TABLE (status_id integer, status_name varchar(255), description text) 
AS $$ 
DECLARE
	local_start_status_id integer;
	local_final_status_id integer;
BEGIN
	
	RETURN QUERY
	SELECT  status.status_id, status.status_name, status.description
	FROM final.status status
	INNER JOIN final.workflow wf
		ON status.wf_id = wf.wf_id
	WHERE wf.wf_name = $1;

END
$$ LANGUAGE plpgsql;
-- select * from final.get_Status_by_workflow('normal workflow');


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
	RETURNS TABLE (prj_name varchar(255), description text, p_wf varchar(255)) 
AS $$ 
BEGIN
	RETURN QUERY
	SELECT prj.prj_name as p_name, prj.description, wf.wf_name as p_wf
	FROM final.project prj 
	inner join final.workflow wf
	 on prj.wf_id = wf.wf_id;
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

	INSERT INTO final.tag_bug (tag_id, bug_id)
	SELECT local_tag_id, $2
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

CREATE OR REPLACE FUNCTION final.get_NextStatus_for_bug(integer) 
	RETURNS TABLE (status_id integer, status_name varchar(255), description text) 
AS $$ 
BEGIN
	
	RETURN QUERY
	SELECT  n_status.status_id, n_status.status_name, n_status.description
	FROM final.bug bug
	INNER JOIN final.link link
		ON bug.status_id = link.startStatus_id
	INNER JOIN final.status n_status
		ON link.endstatus_id = n_status.status_id
	WHERE bug.bug_id = $1;

END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION final.set_Status_for_bug(integer, integer) 
	RETURNS INTEGER 
AS $$
 
BEGIN
	UPDATE final.bug
	SET status_id = $2
	WHERE bug.bug_id = $1 AND $2 in (SELECT status_id from final.status);
	RETURN 1;
END
$$ LANGUAGE plpgsql;
