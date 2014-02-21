//
//  ChatMessage.m
//  Re:group'd
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
    NSNumber *number;
    
    text = [data valueForKey:@"message_id"];
    o.message_id = text.integerValue;

    text = [data valueForKey:@"system_id"];
    o.system_id = text;
    
    text = [data valueForKey:@"chat_key"];
    o.chat_key = text;

    text = [data valueForKey:@"contact_key"];
    o.contact_key = text;

    text = [data valueForKey:@"form_key"];
    o.form_key = text;
    
    text = [data valueForKey:@"message"];
    o.message = text;
    
    number = [data valueForKey:@"type"];
    o.type = number;
    
    number = [data valueForKey:@"status"];
    o.status = number;
    
    number = [data valueForKey:@"timestamp"];
    o.timestamp = number;
    
    o.createdAt = [NSDate dateWithTimeIntervalSince1970:o.timestamp.doubleValue];

    
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

    if (data[@"chat"] != nil) {
        PFObject *chat = [data valueForKey:@"chat"];
        o.chat_key = chat.objectId;
    }
    if (data[@"photo"] != nil) {
        PFFile *pfPhoto = [data valueForKey:@"photo"];
        if (pfPhoto) {
            o.pfPhoto = pfPhoto;
            o.photo_url = pfPhoto.url;
        }
    }

    text = [data valueForKey:@"form_key"];
    o.form_key = text;

    text = [data valueForKey:@"contact_key"];
    o.contact_key = text;
    
    text = [data valueForKey:@"user_key"];
    o.user_key = text;

    text = [data valueForKey:@"message"];
    o.message = text;
    
    text = [data valueForKey:@"attachment"];
    o.attachment = text;
    
    
    text = [data valueForKey:@"created"];
    o.created = text;
    return o;
}
@end
