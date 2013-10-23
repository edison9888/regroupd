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
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *contacts;

@property (nonatomic, retain) NSArray *contact_keys;

+ (ChatVO *) readFromDictionary:(NSDictionary *) dict;
+ (ChatVO *) readFromPFObject:(PFObject *)data;

@end
