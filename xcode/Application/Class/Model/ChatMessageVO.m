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


+ (ChatMessageVO *) readFromDictionary:(NSDictionary *) data {
    ChatMessageVO *o = [[ChatMessageVO alloc] init];
    NSString *text;
    
    text = [data valueForKey:@"message_id"];
    o.message_id = text.integerValue;
    
    text = [data valueForKey:@"chat_id"];
    o.chat_id = text.integerValue;

    text = [data valueForKey:@"contact_id"];
    o.contact_id = text.integerValue;

    text = [data valueForKey:@"form_id"];
    o.form_id = text.integerValue;
    
    text = [data valueForKey:@"system_id"];
    o.system_id = text;
    
    text = [data valueForKey:@"message"];
    o.message = text;
    
    text = [data valueForKey:@"attachment"];
    o.attachment = text;
    
    text = [data valueForKey:@"type"];
    o.type = text.integerValue;
    
    text = [data valueForKey:@"status"];
    o.status = text.integerValue;
    
    text = [data valueForKey:@"created"];
    o.created = text;
    
    return o;
    
}

+ (ChatMessageVO *) readFromPFObject:(PFObject *)data {
    ChatMessageVO *o = [[ChatMessageVO alloc] init];
    NSString *text;
    
    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;

    text = [data valueForKey:@"message_id"];
    o.message_id = text.integerValue;
    
    text = [data valueForKey:@"chat_id"];
    o.chat_id = text.integerValue;
    
    text = [data valueForKey:@"contact_id"];
    o.contact_id = text.integerValue;
    
    text = [data valueForKey:@"form_id"];
    o.form_id = text.integerValue;

    text = [data valueForKey:@"chat_key"];
    o.chat_key = text;

    text = [data valueForKey:@"contact_key"];
    o.contact_key = text;
    
    text = [data valueForKey:@"user_key"];
    o.user_key = text;

    text = [data valueForKey:@"message"];
    o.message = text;
    
    text = [data valueForKey:@"attachment"];
    o.attachment = text;
    
    text = [data valueForKey:@"type"];
    o.type = text.integerValue;
    
    text = [data valueForKey:@"status"];
    o.status = text.integerValue;
    
    text = [data valueForKey:@"created"];
    o.created = text;
    return o;
}
@end
