//
//  GroupVO.h
//  Re:group'd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import <Foundation/Foundation.h>

#define kGroupTypeLocal     0
#define kGroupTypeRemote    1

@interface GroupVO : NSObject

@property int group_id;
@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *chat_key;

@property (nonatomic, retain) NSString *name;
@property int type;
@property int status;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

// Transient fields
@property (nonatomic, retain) NSMutableArray *contacts;

+ (GroupVO *) readFromDictionary:(NSDictionary *) dict;
//+ (GroupVO *) readFromPFChat:(PFObject *) data;

@end
