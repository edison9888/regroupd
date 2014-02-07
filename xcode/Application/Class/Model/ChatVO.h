//
//  ChatVO.h
//  Re:group'd
//
//  Created by Hugh Lang on 10/3/13.
//
//


typedef enum {
	ChatType_REMOVED = -2,
	ChatType_BLOCKED = -1,
	ChatType_INFORMAL = 0,
	ChatType_GROUP = 1
}ChatType;

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ChatVO : NSObject {
    
}
@property int chat_id;
@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

@property (nonatomic, retain) NSNumber *clear_timestamp;
@property (nonatomic, retain) NSNumber *read_timestamp;
@property (nonatomic, retain) NSNumber *message_timestamp;

@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSArray *contact_keys; // for keys
@property (nonatomic, retain) NSArray *contact_names; // for names
@property (nonatomic, retain) NSArray *removed_keys; // for phoneIds
@property (nonatomic, retain) NSArray *contact_ids;  // for objectIds

// Transient fields
//@property (nonatomic, retain) NSString *names;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, retain) NSMutableDictionary *contactMap;
@property (nonatomic, retain) NSMutableDictionary *namesMap;
@property (nonatomic, retain) NSDate *cutoffDate;

@property (nonatomic, retain) PFObject *pf_chat;
@property BOOL hasNew;

+ (ChatVO *) readFromDictionary:(NSDictionary *) dict;
+ (ChatVO *) readFromPFObject:(PFObject *)data;

@end
