CREATE TABLE pomodoro(
	id char(24) primary key,
	userid char(12),
	starttime varchar(100),
	endtime varchar(100),
	worktype int
);

CREATE TABLE users (
	id varchar(20) primary key,
	name varchar(200),
	password char(32),
	salt char(32),
	algorithm char(4)
);
