create table if not exists indv.nodeType (
  n_type char(1) not null,
  n_typeName varchar(255) not Null,
  primary key (n_type)
);

insert into indv.nodeType values ('A', 'Activity node');
insert into indv.nodeType values ('F', 'Fork node');
insert into indv.nodeType values ('J', 'Join node');
insert into indv.nodeType values ('S', 'Starting node');
insert into indv.nodeType values ('E', 'Finishing node');

create table if not exists indv.node (
	n_id  Serial not null,
	wf_id Integer not null,
	n_sn  varchar(255) not null,
	n_type char(1) not NULL,
	n_name text,
	primary key (n_id),
	foreign key (wf_id) references indv.workflow (wf_id) on delete cascade,
	foreign key (n_type) references indv.nodeType (n_type) on delete cascade
);

