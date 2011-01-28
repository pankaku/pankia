create table item_acquirements
(id integer primary key,
created_at DATETIME,
user_id INTEGER,
item_id TEXT,
quantity INTEGER,
revised_quantity INTEGER,
revised_at DATETIME);