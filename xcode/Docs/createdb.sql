
DROP TABLE contact;

CREATE TABLE IF NOT EXISTS user ( 
    user_id INTEGER PRIMARY KEY,  
    system_id TEXT,
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

CREATE TABLE IF NOT EXISTS contact ( 
    contact_id INTEGER PRIMARY KEY,  
    system_id TEXT,
    name TEXT, 
    phone TEXT,
    fax TEXT,
    type int DEFAULT 1, 
    status INT DEFAULT 0,
	updated TEXT
);

CREATE TABLE IF NOT EXISTS group ( 
    group_id INTEGER PRIMARY KEY,  
    system_id TEXT,
    name TEXT, 
    type int DEFAULT 1, 
    status INT DEFAULT 0,
	updated TEXT
);

CREATE TABLE IF NOT EXISTS group_contact ( 
    group_id INTEGER,  
    contact_id INTEGER
);

CREATE TABLE IF NOT EXISTS chat ( 
    chat_id INTEGER PRIMARY KEY,  
    system_id TEXT,
    name TEXT, 	
    type int DEFAULT 1, 
    status INT DEFAULT 0,
	updated TEXT
);

CREATE TABLE IF NOT EXISTS form ( 
    form_id INTEGER PRIMARY KEY,  
    system_id TEXT,
    name TEXT,
    type int DEFAULT 1, 
    status INT DEFAULT 0,
    event_date TEXT,
    created TEXT,
    updated TEXT
);

CREATE TABLE IF NOT EXISTS form_option ( 
    option_id INTEGER PRIMARY KEY,
    form_id INTEGER,  
    system_id TEXT,
    name TEXT,
    stats TEXT,
    datafile TEXT,
    imagefile TEXT,
    type int DEFAULT 1, 
    status INT DEFAULT 0,
    created TEXT,
    updated TEXT
);

insert into contact (name, phone, fax) values ('Hugh Lang', '1-646-498-6305', '1-855-546-5470');

---- 07.21 02:05:52 PM ----

insert into user (firstname, middlename, lastname, company, title, phone, fax, address, city, state, zip, password, hint, email, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	



