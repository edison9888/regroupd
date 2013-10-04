//
//  ChatVO.h
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import <Foundation/Foundation.h>

@interface ChatVO : NSObject {
    
}
@property int chat_id;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *name;
@property int type;
@property int status;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSMutableArray *messages;

+ (ChatVO *) readFromDictionary:(NSDictionary *) dict;

@end
