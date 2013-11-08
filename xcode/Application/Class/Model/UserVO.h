//
//  UserVO.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/2/13.
//
//

#import <Foundation/Foundation.h>

@interface UserVO : NSObject {
    
}

/*
 CREATE TABLE IF NOT EXISTS user (
 user_key TEXT,
 username TEXT,
 password TEXT,
 system_id TEXT,
 facebook_id TEXT,
 first_name TEXT,
 last_name TEXT,
 phone TEXT,
 email TEXT,
 imagefile TEXT,
 type INT DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT,
 updated TEXT
 );

 
 */

@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *facebook_id;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *imagefile;


@property int type;
@property int status;

@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

// Transient fields
@property (nonatomic, retain) NSString *contact_key;
@property (nonatomic, retain) NSString *photoUrl;

+ (UserVO *) readFromDictionary:(NSDictionary *) dict;

- (NSString *) getFullname;
@end
