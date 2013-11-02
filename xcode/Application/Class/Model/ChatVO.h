//
//  ChatVO.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ChatVO : NSObject {
    
}
@property int chat_id;
@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *name;
@property int type;
@property int status;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSArray *contact_keys; // for phoneIds
@property (nonatomic, retain) NSArray *contact_ids;  // for objectIds

// Transient fields
@property (nonatomic, retain) NSString *names;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, retain) NSMutableDictionary *contactMap;

@property (nonatomic, retain) PFObject *pf_chat;

+ (ChatVO *) readFromDictionary:(NSDictionary *) dict;
+ (ChatVO *) readFromPFObject:(PFObject *)data;

@end
