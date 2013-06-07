-- workflow --
	Select final.create_workflow('devtrack', 'Award-Winning Implementation and Defect Tracking');
		-- $1: workflow name
		-- $2: workflow description	
	Select final.delete_workflow('devtrack')
		-- $1: workflow name
	Select * from final.select_workflow('devtrack')
		-- $1: workflow name
	Select * from final.get_workflows()
-- Status -
	Select * from final.create_status(2, 'New', 'New thing has just happened')
		-- $1: workflow id
		-- $2: status name
		-- $3: status description
	Select * from final.link_nodes(11, 12,'Passed')
		-- $1: start status
		-- $2: end status
		-- $3: description
	Select * from final.drop_link_nodes(11, 12)
		-- $1: start status
		-- $2: end status
	Select * from final.get_NextStatus(7)
	
-- Status + workflow --
	Select * from final.link_wf(2,5,'raising an issue','S')
		-- $1: workflow ID
		-- $2: status
		-- $3: description
		-- $4: 'S'-> link to start, 'E' -> link to end
	Select * from final.get_Status_by_workflow('devtrack')
		-- $1: workflow name
-- Project --
	Select final.create_project(2, 'Info445', 'this is an awesome class')
		-- $1: workflow_id
		-- $2: name of project
		-- $3: description
	Select * from final.get_projects()
	Select * from final.delete_project('Info445')
		-- $1: name of project
	Select * from final.create_user('tue')
		-- $1: username
	Select * from final.delete_user('Justin5')
		-- $1: username
	Select * from final.get_users() 
	Select * from final.assign_user_project('Justin', 'Info445')
		-- $1: username
		-- $2: name of project
	Select * from final.get_all_user_in_project('Info445')
		-- $1: username
-- Bug + project --
	Select * from final.create_bug('Info445', 'cannot log in','It keeps raising ERRORS')
		-- $1: name of project
		-- $2: bug title
		-- $3: bug content
	Select * from final.get_all_bugs_in_project('Info445')
		-- $1: name of project
	Select * from final.delete_bug(1)
		-- $1: bug id retrieved from the bugs of the project
-- Bug + User --
	Select * from final.assign_user_bug('Justin', 2, 'developer')
		-- $1: username
		-- $2: bug id
		-- $3: role
	Select * from final.get_all_bugs_for_user('tue')
		-- $1: username
	Select * from final.get_all_users_for_bug(2)
		-- $1: bug ID
-- Bug + Tag --
	Select * from final.assign_tag_to_bug('funny', 2)
		-- $1: tag
		-- $2: bug id
	Select * from final.unassign_tag_bug ('funny', 2)
		-- $1: tag
		-- $2: bug id
	Select * from final.get_all_tags_for_bug(2)	
		-- $1: bug id
	Select * from final.get_all_bugs_for_tag('funny')
		-- $1: tag name
-- Bug + status --
	Select * from final.get_NextStatus_for_bug (2)
		-- $1: bug id
	Select * from final.set_Status_for_bug(2, 7)
		-- $1: bug id
		-- $2: status id



