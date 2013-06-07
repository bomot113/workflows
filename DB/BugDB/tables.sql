create schema final;
create table final.status (
	status_id serial not null,
	wf_id integer not null,
	status_name varchar(255) not null,
	description text,
	primary key (status_id)
);

create table final.workflow(
	wf_id serial not null,
	wf_name varchar(255),
	description text,
	start_status_id int,
	final_status_id int,
	primary key (wf_id),
	foreign key (start_status_id) references final.status(status_id) on delete no action,
	foreign key (final_status_id) references final.status(status_id) on delete no action
);

alter table final.status add foreign key (wf_id) references final.workflow(wf_id) ON DELETE cascade;

create table final.link (
	link_id serial not null,
	startStatus_id integer not null,
	endStatus_id integer not null,
	description text,
	foreign key (startStatus_id) references final.status (status_id) on delete cascade,
	foreign key (endStatus_id) references final.status (status_id) on delete cascade,
	primary key (link_id)
);

create table final.project(
	prj_id serial not null,
	prj_name varchar(255) UNIQUE,
	description text,
	wf_id int not null,
	primary key (prj_id),
	foreign key (wf_id) references final.workflow(wf_id) on delete no action
);

create table final.user(
	usr_id serial not null,
	usr_name varchar(255) UNIQUE,
	primary key (usr_id)
);

create table final.Project_User_Role (
	usr_id integer not null,
	prj_id integer not null,
	primary key (usr_id, prj_id),
	foreign key (usr_id) references final.user(usr_id) on delete no action,
	foreign key (prj_id) references final.project(prj_id) on delete no action
);

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
);
create table final.users_bug_rel (
	usr_id integer not null,
	bug_id integer not null,
	role varchar(255),
	primary key (usr_id, bug_id),
	foreign key (usr_id) references final.user(usr_id) on delete cascade,
	foreign key (bug_id) references final.bug(bug_id) on delete cascade
);

create table final.tag (
	tag_id serial not null,
	name varchar(255) UNIQUE,
	primary key (tag_id)
);

create table final.tag_bug (
	tag_id integer not null,
	bug_id integer not null,
	primary key (tag_id, bug_id)
);