//
//  FormOptionVO.m
//  Regroupd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import "FormOptionVO.h"

@implementation FormOptionVO

/*
 
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
 */

+ (FormOptionVO *) readFromDictionary:(NSDictionary *) dict {
    FormOptionVO *o = [[FormOptionVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"option_id"];
    o.option_id = text.integerValue;

    text = [dict valueForKey:@"form_id"];
    o.form_id = text.integerValue;
    
    text = [dict valueForKey:@"system_id"];
    o.system_id = text;

    text = [dict valueForKey:@"name"];
    o.name = text;

    text = [dict valueForKey:@"stats"];
    o.stats = text;

    text = [dict valueForKey:@"datafile"];
    o.datafile = text;

    text = [dict valueForKey:@"imagefile"];
    o.imagefile = text;

    text = [dict valueForKey:@"type"];
    o.type = text.integerValue;
    
    text = [dict valueForKey:@"status"];
    o.status = text.integerValue;
    
    text = [dict valueForKey:@"created"];
    o.created = text;
    
    text = [dict valueForKey:@"updated"];
    o.updated = text;
    
    return o;
}

+ (FormOptionVO *) readFromPFObject:(PFObject *)data {
    FormOptionVO *o = [[FormOptionVO alloc] init];
    NSString *text;
    
    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;
    
    text = [data valueForKey:@"name"];
    o.name = text;
    
//    text = [data valueForKey:@"type"];
//    o.type = text.integerValue;
    if (data[@"position"]) {
        text = [data valueForKey:@"position"];
        o.position = text.integerValue;
    }
    if (data[@"photo"]) {
        PFFile *pfPhoto = (PFFile *) [data objectForKey:@"photo"];
        o.pfPhoto = pfPhoto;
    }
    
    return o;
}


@end
