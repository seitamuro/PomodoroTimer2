CREATE TABLE pomodoro(
	id char(24) primary key,
	userid char(12),
	starttime varchar(100),
	endtime varchar(100),
	worktype int
);

CREATE TABLE users (
	id char(12) primary key,
	name varchar(200),
	password varchar(200),
	salt varchar(200),
	algorithm char(4)
);
