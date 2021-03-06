//
//  DataModel.h
//
//  Created by Hugh Lang on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "UserVO.h"
#import "ContactVO.h"
#import "FormVO.h"
#import "FormOptionVO.h"
#import "ChatVO.h"
#import "GroupVO.h"

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)

#define kContactDB          @"ContactDB"
#define kUserContactDB      @"UserContactDB"
#define kChatDB             @"ChatDB"
#define kChatMessageDB      @"ChatMessageDB"
#define kChatFormDB         @"ChatFormDB"
#define kChatContactDB      @"ChatContactDB"
#define kFormDB             @"FormDB"
#define kFormContactDB      @"FormContactDB"
#define kFormOptionDB       @"FormOptionDB"
#define kFormResponseDB     @"FormResponseDB"
#define kPrivacyDB          @"PrivacyDB"

#define kSetting_Notifications_Enabled      @"Setting_Notifications_Enabled"
#define kSetting_Notifications_Show_Preview @"Setting_Notifications_Show_Preview"
#define kSetting_Add_To_Calendar            @"Setting_Add_To_Calendar"
#define kSetting_Access_Contacts            @"Setting_Access_Contacts"

#define kAction_New_Group_From_List         @"Action_New_Group_From_List"

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
@property (nonatomic, retain) ContactVO *myContact;

@property (nonatomic, retain) ContactVO *contact;
@property (nonatomic, retain) FormVO *form;
@property (nonatomic, retain) ChatVO *chat;
@property (nonatomic, retain) GroupVO *group;

@property (nonatomic, retain) NSMutableArray *formsList;
@property (nonatomic, retain) NSMutableArray *chatsList;
@property (nonatomic, retain) NSMutableArray *groupsList;

@property (nonatomic, retain) NSMutableDictionary *contactCache;
@property (nonatomic, retain) NSMutableDictionary *phonebookCache;
@property (nonatomic, retain) NSMutableDictionary *chatCache;

@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) NSString *mode;
@property (nonatomic, retain) NSString *timestampText;
@property (nonatomic, retain) UIImage *anonymousImage;
@property (nonatomic, retain) UIImage *defaultImage;


@property int stageHeight;
@property int stageWidth;
@property int navIndex;
@property int formType;

@property BOOL needsLookup;
@property BOOL needsRefresh;
@property BOOL didSaveOK;


+ (DataModel *) shared;

+ (NSDictionary *) readPFObjectAsDictionary:(PFObject *) data;


@end
