
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
    created TEXT,
    updated TEXT
);
CREATE TABLE IF NOT EXISTS chat_message (
    message_id INTEGER PRIMARY KEY,  
    chat_id INTEGER,
    contact_id INTEGER,
    form_id INTEGER,
    system_id TEXT,
    message TEXT, 	
    attachment TEXT, 	
    type int DEFAULT 1, 
    status INT DEFAULT 0,
    created TEXT
);
CREATE TABLE IF NOT EXISTS chat_contact ( 
    chat_id INTEGER,  
    contact_id INTEGER
);

CREATE TABLE IF NOT EXISTS form ( 
    form_id INTEGER PRIMARY KEY,  
    system_id TEXT,
    name TEXT,
    location TEXT,
    description TEXT,
    imagefile TEXT,
    type int DEFAULT 1, 
    status INT DEFAULT 0,
    start_time TEXT,
    end_time TEXT,
    allow_public INT DEFAULT 0,
    allow_share INT DEFAULT 0,
    allow_multiple INT DEFAULT 0,
    created TEXT,
    updated TEXT
);

CREATE TABLE IF NOT EXISTS form_option ( 
    option_id INTEGER PRIMARY KEY,
    form_id INTEGER,  
    position int DEFAULT 1, 
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

INSERT INTO "form" (form_id, name, type, status, created, updated) VALUES(2,'Lunch',1,0,'2013-09-26 22:12:31','2013-09-26 22:12:31');
INSERT INTO "form" (form_id, name, type, status, created, updated) VALUES(3,'Who will win the World Cup?',1,0,'2013-09-26 22:58:05','2013-09-26 22:58:05');
INSERT INTO "form" (form_id, name, type, status, created, updated) VALUES(4,'Hot cars',2,0,'2013-09-27 18:05:56','2013-09-27 18:05:56');

INSERT INTO "form_option" VALUES(1,2,NULL,'Burgers',NULL,NULL,NULL,1,1,'2013-09-26 22:12:31','2013-09-26 22:12:31');
INSERT INTO "form_option" VALUES(2,2,NULL,'Pizza',NULL,NULL,NULL,1,1,'2013-09-26 22:12:31','2013-09-26 22:12:31');
INSERT INTO "form_option" VALUES(3,2,NULL,'Beer',NULL,NULL,NULL,1,1,'2013-09-26 22:12:31','2013-09-26 22:12:31');
INSERT INTO "form_option" VALUES(4,3,NULL,'Brazil',NULL,NULL,NULL,1,1,'2013-09-26 22:58:05','2013-09-26 22:58:05');
INSERT INTO "form_option" VALUES(5,3,NULL,'Germany',NULL,NULL,NULL,1,1,'2013-09-26 22:58:05','2013-09-26 22:58:05');
INSERT INTO "form_option" VALUES(6,3,NULL,'Italy',NULL,NULL,NULL,1,1,'2013-09-26 22:58:05','2013-09-26 22:58:05');
INSERT INTO "form_option" VALUES(7,4,NULL,'Audi A7',NULL,NULL,NULL,1,1,'2013-09-27 18:05:56','2013-09-27 18:05:56');
INSERT INTO "form_option" VALUES(8,4,NULL,'Maserati',NULL,NULL,NULL,1,1,'2013-09-27 18:05:56','2013-09-27 18:05:56');
INSERT INTO "form_option" VALUES(9,4,NULL,'Tesla',NULL,NULL,NULL,1,1,'2013-09-27 18:05:56','2013-09-27 18:05:56');

INSERT INTO "chat" (name, type, status, created, updated) VALUES('Test Chat',1,0,'2013-09-26 22:12:31','2013-09-26 22:12:31');

INSERT INTO "chat_contact" (chat_id, contact_id) VALUES(1, 1);


---- 07.21 02:05:52 PM ----

insert into user (firstname, middlename, lastname, company, title, phone, fax, address, city, state, zip, password, hint, email, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	


