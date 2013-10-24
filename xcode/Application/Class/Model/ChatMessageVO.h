//
//  ChatMessage.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <Foundation/Foundation.h>

@interface ChatMessageVO : NSObject

@property int message_id;
@property int chat_id;
@property int contact_id;
@property int form_id;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *contact_key;
@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *attachment;
@property int type;
@property int status;

@property (nonatomic, retain) NSString *created;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

+ (ChatMessageVO *) readFromDictionary:(NSDictionary *) dict;

+ (ChatMessageVO *) readFromPFObject:(PFObject *)data;
@end
