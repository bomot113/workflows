create schema indv;
create table indv.workflow (
	wf_id serial not null,
	wf_name varchar(255) not null,
	wf_info text,
	primary key (wf_id));

