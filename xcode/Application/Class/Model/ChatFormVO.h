//
//  ChatFormVO.h
//  Regroupd
//
//  Created by Hugh Lang on 11/21/13.
//
//

#import <Foundation/Foundation.h>

@interface ChatFormVO : NSObject


@property (nonatomic, retain) NSString *form_key;
@property (nonatomic, retain) NSString *chat_key;

@property (nonatomic, retain) NSMutableArray *formResponses;

@end
