//
//  ChatVO.m
//  Regroupd
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
+ (ChatVO *) readFromDictionary:(NSDictionary *) dict {
    ChatVO *o = [[ChatVO alloc] init];    
    NSString *text;
    
    text = [dict valueForKey:@"chat_id"];
    o.chat_id = text.integerValue;
    
    text = [dict valueForKey:@"system_id"];
    o.system_id = text;

    text = [dict valueForKey:@"name"];
    o.name = text;
    
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
@end
