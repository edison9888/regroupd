//
//  ChatMessage.h
//  Re:group'd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <Foundation/Foundation.h>

//@class PFImageView;

@interface ChatMessageVO : NSObject

@property int message_id;
@property int chat_id;
@property int contact_id;
@property int form_id;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *chat_key;
@property (nonatomic, retain) NSString *contact_key;
@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *form_key;
@property (nonatomic, retain) NSString *photo_url;

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *attachment;
@property (nonatomic, retain) NSNumber *timestamp;

@property NSNumber *type;
@property NSNumber *status;

@property (nonatomic, retain) NSString *created;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

// Transient fields
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) PFFile *pfPhoto;

+ (ChatMessageVO *) readFromDictionary:(NSDictionary *) dict;

+ (ChatMessageVO *) readFromPFObject:(PFObject *)data;
@end
