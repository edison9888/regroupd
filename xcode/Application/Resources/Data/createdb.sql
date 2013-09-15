
DROP TABLE contact;
DROP TABLE user;
DROP TABLE fax_log;
DROP TABLE fax_account;

CREATE TABLE IF NOT EXISTS contact ( 
contact_id INTEGER PRIMARY KEY,  
name TEXT, 
phone TEXT,
fax TEXT,
type INT DEFAULT 1, 
status INT DEFAULT 0,
created TEXT,
updated TEXT
);


CREATE TABLE IF NOT EXISTS user ( 
user_id INTEGER PRIMARY KEY,  
firstname TEXT, 
middlename TEXT,
lastname TEXT,
company TEXT,
title TEXT,
phone TEXT,
fax TEXT,
address TEXT,
city TEXT,
state TEXT,
zip TEXT,
password TEXT,
hint TEXT,
email TEXT,
status INT DEFAULT 0,
created TEXT,
updated TEXT
);

CREATE TABLE IF NOT EXISTS fax_log ( 
log_id INTEGER PRIMARY KEY, 
contact_id INTEGER,
user_id INTEGER,
account_id INTEGER,
patient_id TEXT,
patient_name TEXT,
efax_id TEXT, 
fax TEXT,
message TEXT,
type int DEFAULT 1, 
status INT DEFAULT 0,
created TEXT
);

CREATE TABLE IF NOT EXISTS fax_account ( 
account_id INTEGER PRIMARY KEY,  
user_id INTEGER,
qty_purchased INTEGER DEFAULT 0,
qty_used INTEGER DEFAULT 0,
qty_left INTEGER DEFAULT 0,
status INT DEFAULT 0,
purchase_id TEXT,
created TEXT,
updated TEXT
);

insert into contact (name, phone, fax) values ('Hugh Lang', '1-646-498-6305', '1-855-546-5470');

---- 07.21 02:05:52 PM ----

insert into user (firstname, middlename, lastname, company, title, phone, fax, address, city, state, zip, password, hint, email, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	



