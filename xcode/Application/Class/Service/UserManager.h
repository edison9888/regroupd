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
#define kDefaultPhotoFilename   @"myphoto.png"

@interface UserManager : NSObject {
}

@property (nonatomic, retain) UserVO *user;

- (UserVO *) lookupDefaultUser;
- (void) createUser:(UserVO *) user;

- (void)savePhoto:(UIImage *)saveImage filename:(NSString *)filename callback:(void (^)(NSString *imageUrl))callback;
- (UIImage *)loadPhoto:(NSString *)filename;


// API functions
- (void) apiLookupContactForUser:(PFUser *)pfUser callback:(void (^)(PFObject *pfContact))callback;
- (void) apiCreateUserAndContact:(UserVO *)user callback:(void (^)(PFObject *pfUser))callback;

- (UserVO *) apiLoadUser:(NSString *)objectId;
- (NSString *) apiSaveUser:(UserVO *) user;
- (NSMutableArray *) apiListUsers:(NSString *)userId;
- (void) apiDeleteUser:(UserVO *)user;

@end
