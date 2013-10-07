//
//  DataModel.h
//
//  Created by Hugh Lang on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserVO.h"
#import "ContactVO.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "ChatVO.h"

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)

@interface DataModel : NSObject {
    NSMutableDictionary *contactData;
    NSString *action;
    NSString *timestampText;
    BOOL needsLookup;
    BOOL needsRefresh;
    int stageHeight;
    int stageWidth;
    int navIndex;
    int contactId;
    
    UserVO *user;
    ContactVO *contact;

}

@property int contactId;

@property (nonatomic, retain) UserVO *user;
@property (nonatomic, retain) ContactVO *contact;
@property (nonatomic, retain) FormVO *form;
@property (nonatomic, retain) ChatVO *chat;

@property (nonatomic, retain) NSMutableDictionary *contactData;
@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) NSString *timestampText;

@property int stageHeight;
@property int stageWidth;
@property int navIndex;

@property BOOL needsLookup;
@property BOOL needsRefresh;


+ (DataModel *) shared;

@end
