//
//  ContactVO.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/16/13.
//
//

#import "ContactVO.h"

@implementation ContactVO

@synthesize contact_id, record_id, system_id, facebook_id;
@synthesize first_name, last_name, phone, email, imagefile;
@synthesize type, status, created, updated;

/*
 CREATE TABLE IF NOT EXISTS contact (
 contact_id INTEGER PRIMARY KEY,
 user_key TEXT,
 record_id BIGINT,
 system_id TEXT,
 facebook_id TEXT,
 first_name TEXT,
 last_name TEXT,
 phone TEXT,
 email TEXT,
 imagefile TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT,
 updated TEXT
 );
 
 */

+ (ContactVO *) readFromDictionary:(NSDictionary *) data {
    ContactVO *o = [[ContactVO alloc] init];
    NSString *text;
    
    text = [data valueForKey:@"contact_id"];
    o.contact_id = text.integerValue;
//    text = [data valueForKey:@"record_id"];
//    o.record_id = [NSNumber numberWithInt:text.integerValue];
    
    text = [data valueForKey:@"system_id"];
    o.system_id = text;
    text = [data valueForKey:@"facebook_id"];
    o.facebook_id = text;
    text = [data valueForKey:@"first_name"];
    o.first_name = text;
    text = [data valueForKey:@"last_name"];
    o.last_name = text;
    text = [data valueForKey:@"phone"];
    o.phone = text;
    text = [data valueForKey:@"email"];
    o.email = text;
    text = [data valueForKey:@"imagefile"];
    o.imagefile = text;
    text = [data valueForKey:@"type"];
    o.type = text.intValue;
    text = [data valueForKey:@"status"];
    o.status = text.intValue;
    text = [data valueForKey:@"created"];
    o.created = text;
    text = [data valueForKey:@"updated"];
    o.updated = text;
    
    return o;
}

+ (ContactVO *) readFromPFObject:(PFObject *)data {
    ContactVO *o = [[ContactVO alloc] init];
    NSString *text;

    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;
    
    text = [data valueForKey:@"record_id"];
    o.record_id = [NSNumber numberWithInt:text.integerValue];
    
    text = [data valueForKey:@"facebook_id"];
    o.facebook_id = text;
    text = [data valueForKey:@"first_name"];
    o.first_name = text;
    text = [data valueForKey:@"last_name"];
    o.last_name = text;
    text = [data valueForKey:@"phone"];
    o.phone = text;
    text = [data valueForKey:@"email"];
    o.email = text;
    text = [data valueForKey:@"imagefile"];
    o.imagefile = text;
    text = [data valueForKey:@"type"];
    o.type = text.intValue;
    text = [data valueForKey:@"status"];
    o.status = text.intValue;
    return o;
}

@end
