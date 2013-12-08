//
//  FormVO.m
//  Regroupd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import "FormVO.h"

@implementation FormVO

/*
 form_id INTEGER PRIMARY KEY,
 system_id TEXT,
 name TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 event_date TEXT,
 created TEXT,
 updated TEXT
 */

+ (FormVO *) readFromDictionary:(NSDictionary *) dict {
    FormVO *o = [[FormVO alloc] init];
    NSString *text;
    NSNumber *number;
    
    text = [dict valueForKey:@"form_id"];
    o.form_id = text.integerValue;
    
    text = [dict valueForKey:@"system_id"];
    o.system_id = text;

    text = [dict valueForKey:@"name"];
    o.name = text;

    text = [dict valueForKey:@"location"];
    o.location = text;
    
    text = [dict valueForKey:@"details"];
    o.details = text;

    text = [dict valueForKey:@"imagefile"];
    o.imagefile = text;
    
    text = [dict valueForKey:@"type"];
    o.type = text.integerValue;
    
    text = [dict valueForKey:@"status"];
    o.status = text.integerValue;

    text = [dict valueForKey:@"start_time"];
    o.start_time = text;
    
    text = [dict valueForKey:@"end_time"];
    o.end_time = text;

    number = [dict valueForKey:@"allow_public"];
    o.allow_public = number;
    
    number = [dict valueForKey:@"allow_share"];
    o.allow_share = number;
    
    number = [dict valueForKey:@"allow_multiple"];
    o.allow_multiple = number;

    text = [dict valueForKey:@"created"];
    o.created = text;

    text = [dict valueForKey:@"updated"];
    o.updated = text;

    return o;
}


+ (FormVO *) readFromPFObject:(PFObject *)data {
    FormVO *o = [[FormVO alloc] init];
    NSString *text;
    NSNumber *number;
    NSDate *dt;
    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;

    if (data[@"user"]) {
        PFObject *pfUser = data[@"user"];
        o.user_key = pfUser.objectId;
    }
    text = [data valueForKey:@"contact_key"];
    o.contact_key= text;
    
    text = [data valueForKey:@"name"];
    o.name = text;
    
    text = [data valueForKey:@"location"];
    o.location = text;
    
    if (data[@"details"]) {
        text = [data valueForKey:@"details"];
        o.details = text;
        NSLog(@"found details %@", text);
    }
    
    if (data[@"eventStartsAt"]) {
        dt = [data valueForKey:@"eventStartsAt"];
        o.eventStartsAt = dt;
    }
    if (data[@"eventEndsAt"]) {
        dt = [data valueForKey:@"eventEndsAt"];
        o.eventEndsAt = dt;
    }

    if (data[@"photo"]) {
        PFFile *pfPhoto = (PFFile *) [data objectForKey:@"photo"];
        o.pfPhoto = pfPhoto;
    }

    text = [data valueForKey:@"type"];
    o.type = text.integerValue;

    number = [data valueForKey:@"allow_public"];
    o.allow_public = number;

    number = [data valueForKey:@"allow_share"];
    o.allow_share = number;

    number = [data valueForKey:@"allow_multiple"];
    o.allow_multiple = number;

    if (data[@"counter"]) {
        number = [data valueForKey:@"counter"];
    } else {
        number = [NSNumber numberWithInt:0];
    }
    o.counter = number;

    return o;
}

@end
