create table indv.link (
	link_id serial not null,
	startNode_id integer not null,
	endNode_id integer not null,
	label text,
	foreign key (startNode_id) references indv.node (n_id),
	foreign key (endNode_id) references indv.node (n_id),
	primary key (link_id)
)
