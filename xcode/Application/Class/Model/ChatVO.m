//
//  ChatVO.m
//  Re:group'd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import "ChatVO.h"

@implementation ChatVO

/*
 chat_id INTEGER PRIMARY KEY,
 system_id TEXT,
 name TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT,
 updated TEXT
 
 */
+ (ChatVO *) readFromDictionary:(NSDictionary *) data {
    ChatVO *o = [[ChatVO alloc] init];    
    NSString *text;
    NSNumber *number;
    
    text = [data valueForKey:@"chat_id"];
    o.chat_id = text.integerValue;
    
    text = [data valueForKey:@"user_key"];
    o.user_key = text;
    
    text = [data valueForKey:@"system_id"];
    o.system_id = text;

    text = [data valueForKey:@"name"];
    o.name = text;
//    o.names = text;
    
    number = [data valueForKey:@"type"];
    o.type = number;
    
    number = [data valueForKey:@"status"];
    o.status = number;
    
    text = [data valueForKey:@"created"];
    o.created = text;
    
    text = [data valueForKey:@"updated"];
    o.updated = text;

    number = [data valueForKey:@"read_timestamp"];
    o.read_timestamp = number;
    
    number = [data valueForKey:@"clear_timestamp"];
    o.clear_timestamp = number;
    
    if (number && number.doubleValue > 100) {
//        NSTimeInterval timestamp = (NSTimeInterval)number.doubleValue;
        o.cutoffDate = [NSDate dateWithTimeIntervalSince1970:number.doubleValue];
        NSLog(@"clear timestamp %@ with cutoffDate %@", o.clear_timestamp, o.cutoffDate);
    }
    
    return o;
}

+ (ChatVO *) readFromPFObject:(PFObject *)data {
    ChatVO *o = [[ChatVO alloc] init];
    NSString *text;
    NSNumber *number;

    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;

    text = [data valueForKey:@"chat_id"];
    o.chat_id = text.integerValue;
    
    if (data[@"user"]) {
        PFObject *pfUser = data[@"user"];
        o.user_key = pfUser.objectId;
    }
    
    text = [data valueForKey:@"name"];
    o.name = text;
    
    number = [data valueForKey:@"type"];
    o.type = number;
    
    number = [data valueForKey:@"status"];
    o.status = number;
        
    o.contact_keys = (NSArray *) [data valueForKey:@"contact_keys"];
    o.removed_keys = (NSArray *) [data valueForKey:@"removed_keys"];
    o.contact_names = (NSArray *) [data valueForKey:@"contact_names"];

    return o;
}
@end
