create table leaderboard_dailyhighscores
(id integer primary key,
scored_at DATETIME,
user_id INTEGER,
leaderboard_id INTEGER,
score INTEGER,
date_key TEXT,
delta INTEGER,
up_sync_at DATETIME,
up_sync_fail_at DATETIME,
up_sync_hash TEXT,
down_sync_at DATETIME,
commit_score INTEGER,
revised_score INTEGER);