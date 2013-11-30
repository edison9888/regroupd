//
//  GroupVO.m
//  Regroupd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import "GroupVO.h"

@implementation GroupVO

@synthesize group_id, system_id, name;
@synthesize type, status, created, updated;
@synthesize contacts;

+ (GroupVO *) readFromDictionary:(NSDictionary *) dict {
    GroupVO *o = [[GroupVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"group_id"];
    o.group_id = text.intValue;
    
    text = [dict valueForKey:@"system_id"];
    o.system_id = text;
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

@end
