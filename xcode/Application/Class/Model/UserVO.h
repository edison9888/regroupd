//
//  UserVO.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/2/13.
//
//

#import <Foundation/Foundation.h>

@interface UserVO : NSObject {
    
}

@property int user_id;
@property int status;

@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *middlename;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *fax;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *hint;
@property (nonatomic, retain) NSString *email;

@property (nonatomic, retain) NSString *verifycode;


+ (UserVO *) readFromDictionary:(NSDictionary *) dict;
-(void)dumpInfo;
- (NSString *) getFullname;
@end
