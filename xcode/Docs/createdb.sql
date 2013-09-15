
DROP TABLE contact;

CREATE TABLE IF NOT EXISTS contact ( 
    id INTEGER PRIMARY KEY,  
    name TEXT, 
    phone TEXT,
    fax TEXT,
    type int DEFAULT 1, 
    status INT DEFAULT 0,
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
    bundle TEXT,
    fax TEXT,
    efax_id TEXT, 
    type int DEFAULT 1, 
    status INT DEFAULT 0,
	created TEXT
);

insert into contact (name, phone, fax) values ('Hugh Lang', '1-646-498-6305', '1-855-546-5470');

---- 07.21 02:05:52 PM ----

insert into user (firstname, middlename, lastname, company, title, phone, fax, address, city, state, zip, password, hint, email, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	



