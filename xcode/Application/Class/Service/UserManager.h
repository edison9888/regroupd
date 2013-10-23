//
//  UserManager.h
//  eAttending
//
//  Created by Hugh Lang on 7/21/13.
//
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "UserVO.h"

@interface UserManager : NSObject {
}

@property (nonatomic, retain) UserVO *user;

- (UserVO *) lookupDefaultUser;
- (void) createUser:(UserVO *) user;
- (NSString *)saveSignature:(UIImage *)saveImage withName:(NSString *)filename;
- (UIImage *)loadSignature:(NSString *)filename;


// API functions
- (UserVO *) apiLoadUser:(NSString *)objectId;
- (NSString *) apiSaveUser:(UserVO *) user;
- (NSMutableArray *) apiListUsers:(NSString *)userId;
- (void) apiDeleteUser:(UserVO *)user;

@end
