//
//  UserManager.m
//  eAttending
//
//  Created by Hugh Lang on 7/21/13.
//
//

#import "UserManager.h"
#import "DateTimeUtils.h"

@implementation UserManager

@synthesize user = _user;

- (UserVO *) lookupUser:(NSString *)userKey {
    // get first user from database
    NSString *sql = nil;
    sql = @"select * from user where user_key=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql, userKey];
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    if (dict != nil) {
        UserVO *user = [UserVO readFromDictionary:dict];
        return user;
        
    } else {
        return nil;
    }
    
}
- (UserVO *) lookupDefaultUser {
    // get first user from database
    NSString *sql = nil;
    sql = @"select * from user where user_key is not null limit 1";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    if (dict != nil) {
        UserVO *user = [UserVO readFromDictionary:dict];
        return user;
        
    } else {
        return nil;
    }
}
- (void) createUser:(UserVO *) user {
    NSLog(@"%s", __FUNCTION__);
    
    //    [user dumpInfo];
    
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    /*
     CREATE TABLE IF NOT EXISTS user (
     user_key TEXT,
     username TEXT,
     password TEXT,
     system_id TEXT,
     facebook_id TEXT,
     first_name TEXT,
     last_name TEXT,
     phone TEXT,
     email TEXT,
     imagefile TEXT,
     type INT DEFAULT 1,
     status INT DEFAULT 0,
     created TEXT,
     updated TEXT
     );
     
     */
    sql = @"INSERT into user (user_key, username, password, first_name, last_name, phone, email, imagefile, type, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               user.user_key,
               user.username,
               user.password,
               user.first_name,
               user.last_name,
               user.phone,
               user.email,
               user.imagefile,
               [NSNumber numberWithInt:1],
               [NSNumber numberWithInt:0],
               dt,
               dt
               ];
    
    if (!success) {
        NSLog(@"################################### SQL Insert failed ###################################");
    } else {
        NSLog(@"=================================== SQL INSERT SUCCESS ===================================");
        
        sql = @"SELECT last_insert_rowid()";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        
        if ([rs next]) {
            int lastId = [rs intForColumnIndex:0];
            NSLog(@"lastId = %i", lastId);
        }
    }
}

/*
 Create a temporary filename and save image data to file in Documents or temp dir
 */
- (void)savePhoto:(UIImage *)saveImage filename:(NSString *)filename callback:(void (^)(NSString *imageUrl))callback
{
    NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
    
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImagePNGRepresentation(saveImage);
    
    [imageData writeToFile:savePath atomically:NO];
    
    NSLog(@"Save photo to parse");
    
    PFFile *fileObject = [PFFile fileWithName:filename data:imageData];
    
    [fileObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved File with URL %@", fileObject.url);
        
        PFQuery *query = [PFQuery queryWithClassName:kContactDB];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfContact, NSError *error) {
            if (pfContact) {
                NSLog(@"Saving contact with photo");
                pfContact[@"photo"] = fileObject;
                [pfContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    callback(fileObject.url);
                }];
            } else {
                
                NSLog(@"Contact not found");
                callback(nil);
            }
        }];
    }];
}

- (UIImage *)loadPhoto:(NSString *)filename {
    
    @try {
        NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
        
        NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        return image;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

#pragma mark - User API Async

// Create a user and then contact. Return the PF
/*
 Use case: user signup with phone number and SMS verification code as password. 
 Notes:
 -- Existing UserDB record may already exist if user already signed up
 -- Existing ContactDB record may already exist
 
 Check if user exists. If yes, overwrite.
 
 
 */
- (void) apiCreateUserAndContact:(UserVO *)user callback:(void (^)(PFObject *pfUser, PFObject *pfContact))callback{
    
    PFQuery *query= [PFUser query];
    
    [query whereKey:@"username" equalTo:user.phone];
    
    __block PFUser *pfUser;
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        BOOL isOk = YES;
        
        if (object == nil) {
            // need to create user
            NSLog(@"Creating new user for phone %@", user.phone);
            pfUser = [PFUser user];
            pfUser.username = user.username;
            pfUser.password = user.password;
            if (user.email != nil) {
                pfUser.email = user.email;
            }
            [pfUser setObject:user.phone forKey:@"phone"];
            isOk = [pfUser signUp];
            
            if (isOk) {
                NSLog(@"Signup ok");
            } else {
                NSLog(@"Signup failed");
            }
        } else {
            NSLog(@"Found user for phone %@", user.phone);
            pfUser = (PFUser *)object;
            NSError* error;
            
            [PFUser logInWithUsername:user.username password:user.password error:&error] ;
            
            if (error) {
                NSLog(@"%@", error);
            } else {
                isOk = YES;
            }
        }
        if (isOk) {
            PFQuery *query = [PFQuery queryWithClassName:kContactDB];
            [query whereKey:@"phone" equalTo:user.phone];
            
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfContact, NSError *error){
                
                if (!pfUser) {
                    NSLog(@"pfUser is null!!!!!!!!!!");
                }
                if (!pfContact) {
                    NSLog(@"Creating new contact for phone %@", user.phone);
                    
                    pfContact = [PFObject objectWithClassName:kContactDB];
                    
                    pfContact[@"user"] = pfUser;
                    pfContact[@"phone"] = user.phone;
                    //                pfContact[@"first_name"] = user.first_name;
                    //                pfContact[@"last_name"] = user.last_name;
                    
                } else {
                    NSLog(@"Updating contact for phone %@", user.phone);
                    pfContact[@"user"] = pfUser;
                    pfContact[@"phone"] = user.phone;
                    [pfUser setObject:user.phone forKey:@"phone"];
                    
                }
                
                [pfContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"##### %@", error);
                    } else {
                        NSLog(@"Saved contact with objectId %@", pfContact.objectId);
                    }
                    callback(pfUser, pfContact);
                }];
                
            }];
            
        }
        
    }];
   
}

- (void) apiLookupContactForUser:(PFUser *)pfUser callback:(void (^)(PFObject *pfContact))callback{
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    [query whereKey:@"user" equalTo:pfUser];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *pfContact, NSError *error){
        if (error) {
            NSLog(@">>>> %@", error);
            callback(nil);
        } else {
            callback(pfContact);
        }
    }];

}
#pragma mark - User API Synchronous -- to be deprecated
// API functions
- (UserVO *) apiLoadUser:(NSString *)objectId {
    
    return nil;
}
- (NSString *) apiSaveUser:(UserVO *) user {

    PFUser *u = [PFUser user];
    u.username = user.username;
    u.password = user.password;
    if (user.email != nil) {
        u.email = user.email;
    }
    [u setObject:user.phone forKey:@"phone"];
    BOOL success = [u signUp];
    
    if (success) {
        return u.objectId;
        
    } else {
        NSLog(@"apiSaveUser failed");
        return nil;
    }
    
}
- (NSMutableArray *) apiListUsers:(NSString *)userId {
    return nil;
}
- (void) apiDeleteUser:(UserVO *)user {
}


@end
