//
//  GroupVO.m
//  Re:group'd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import "GroupVO.h"

@implementation GroupVO

@synthesize group_id, user_key, chat_key, name;
@synthesize type, status, created, updated;
@synthesize contacts;
@synthesize createdAt, updatedAt;

+ (GroupVO *) readFromDictionary:(NSDictionary *) dict {
    GroupVO *o = [[GroupVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"group_id"];
    o.group_id = text.intValue;
    
    text = [dict valueForKey:@"user_key"];
    o.user_key = text;
    text = [dict valueForKey:@"chat_key"];
    o.chat_key = text;
    text = [dict valueForKey:@"name"];
    o.name = text;
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

+ (GroupVO *) readFromPFChat:(PFObject *)data {
    GroupVO *o = [[GroupVO alloc] init];
    NSString *text;
    
    o.chat_key = data.objectId;
    
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;
    
    text = [data valueForKey:@"name"];
    o.name = text;
    
    return o;
}
@end
