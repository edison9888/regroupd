//
//  UserVO.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/2/13.
//
//

#import "UserVO.h"
#import <objc/runtime.h>

@implementation UserVO

@synthesize user_key, username, password;
@synthesize system_id, facebook_id;
@synthesize first_name, last_name, phone, email, imagefile;
@synthesize type, status, created, updated;

@synthesize contact_key;

- (id)init
{
    self = [super init];
    status = 0;
    
    return self;
}


- (NSString *) getFullname {
    NSString *fmt = @"%@ %@";
    NSString *output = [NSString stringWithFormat:fmt, self.first_name, self.last_name];
 
    return output;
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

+ (UserVO *) readFromDictionary:(NSDictionary *) dict {
    UserVO *o = [[UserVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"user_key"];
    o.user_key = text;
    text = [dict valueForKey:@"username"];
    o.username = text;
    text = [dict valueForKey:@"password"];
    o.password = text;

    text = [dict valueForKey:@"system_id"];
    o.system_id = text;
    text = [dict valueForKey:@"facebook_id"];
    o.facebook_id = text;
    text = [dict valueForKey:@"first_name"];
    o.first_name = text;
    text = [dict valueForKey:@"last_name"];
    o.last_name = text;
    text = [dict valueForKey:@"phone"];
    o.phone = text;
    text = [dict valueForKey:@"email"];
    o.email = text;
    text = [dict valueForKey:@"imagefile"];
    o.imagefile = text;
    text = [dict valueForKey:@"type"];
    o.type = text.intValue;
    text = [dict valueForKey:@"status"];
    o.status = text.intValue;
    text = [dict valueForKey:@"created"];
    o.created = text;
    text = [dict valueForKey:@"updated"];
    o.updated = text;
    
    return o;
}

@end
