PRAGMA foreign_keys = 1;

-- UserIDLen
-- PomodoroIDLen

CREATE TABLE pomodoro(
	id char(PomodoroIDLen),
	userid char(UserIDLen),
	starttime varchar(100),
	endtime varchar(100)
);

CREATE TABLE users (
	id char(UserIDLen) primary key,
	name varchar(200)
);
