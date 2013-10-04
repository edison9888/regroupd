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
    
    text = [dict valueForKey:@"form_id"];
    o.form_id = text.integerValue;
    
    text = [dict valueForKey:@"system_id"];
    o.system_id = text;

    text = [dict valueForKey:@"name"];
    o.name = text;

    text = [dict valueForKey:@"location"];
    o.location = text;
    
    text = [dict valueForKey:@"description"];
    o.description = text;

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

    text = [dict valueForKey:@"allow_public"];
    o.allow_public = text.integerValue;
    
    text = [dict valueForKey:@"allow_share"];
    o.allow_share = text.integerValue;
    
    text = [dict valueForKey:@"allow_multiple"];
    o.allow_multiple = text.integerValue;

    text = [dict valueForKey:@"created"];
    o.created = text;

    text = [dict valueForKey:@"updated"];
    o.updated = text;

    return o;
}
@end
