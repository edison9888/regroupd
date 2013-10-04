//
//  ChatMessage.m
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import "ChatMessageVO.h"

@implementation ChatMessageVO

/*
 message_id INTEGER PRIMARY KEY,
 chat_id INTEGER,
 contact_id INTEGER,
 form_id INTEGER,
 system_id TEXT,
 message TEXT,
 attachment TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT
 */


+ (ChatMessageVO *) readFromDictionary:(NSDictionary *) dict {
    ChatMessageVO *o = [[ChatMessageVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"message_id"];
    o.message_id = text.integerValue;
    
    text = [dict valueForKey:@"chat_id"];
    o.chat_id = text.integerValue;

    text = [dict valueForKey:@"contact_id"];
    o.contact_id = text.integerValue;

    text = [dict valueForKey:@"form_id"];
    o.form_id = text.integerValue;
    
    text = [dict valueForKey:@"system_id"];
    o.system_id = text;
    
    text = [dict valueForKey:@"message"];
    o.message = text;
    
    text = [dict valueForKey:@"attachment"];
    o.attachment = text;
    
    text = [dict valueForKey:@"type"];
    o.type = text.integerValue;
    
    text = [dict valueForKey:@"status"];
    o.status = text.integerValue;
    
    text = [dict valueForKey:@"created"];
    o.created = text;
    
    return o;
    
}
@end
