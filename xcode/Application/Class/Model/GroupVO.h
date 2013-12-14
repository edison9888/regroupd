//
//  GroupVO.h
//  Re:group'd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import <Foundation/Foundation.h>

@interface GroupVO : NSObject

@property int group_id;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *name;
@property int type;
@property int status;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;
@property (nonatomic, retain) NSMutableArray *contacts;

+ (GroupVO *) readFromDictionary:(NSDictionary *) dict;

@end
