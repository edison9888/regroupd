
//
//  GroupManager.m
//  Regroupd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import "ContactManager.h"
#import "SQLiteDB.h"
#import "DateTimeUtils.h"
#import <AddressBook/AddressBook.h>
#import "NBPhoneNumberUtil.h"

#define kLiteralNull    @"<null>"

@implementation ContactManager


#pragma mark - Contact DAO

- (ContactVO *) loadContact:(int)_contactId{
    NSString *sql = nil;
    sql = @"select * from contact where contact_id=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:_contactId]];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    ContactVO *result;
    
    if (dict != nil) {
        result = [ContactVO readFromDictionary:dict];
    }
    return result;
}

- (int) saveContact:(ContactVO *) contact{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    /*
     CREATE TABLE IF NOT EXISTS contact (
     contact_id INTEGER PRIMARY KEY,
     user_key TEXT,
     record_id BIGINT,
     system_id TEXT,
     facebook_id TEXT,
     first_name TEXT,
     last_name TEXT,
     phone TEXT,
     email TEXT,
     imagefile TEXT,
     type int DEFAULT 1,
     status INT DEFAULT 0,
     created TEXT,
     updated TEXT
     );
     
     */
    sql = @"INSERT into contact (user_key, system_id, first_name, last_name, phone, email, imagefile, type, status, created, updated) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               [DataModel shared].user.user_key,
               contact.system_id,
               contact.first_name,
               contact.last_name,
               contact.phone,
               contact.email,
               contact.imagefile,
               [NSNumber numberWithInt:contact.type],
               [NSNumber numberWithInt:contact.status],
               dt,
               dt
               ];
    
    if (!success) {
        NSLog(@"####### SQL Insert failed #######");
    } else {
        NSLog(@"====== SQL INSERT SUCCESS ======");
        
        sql = @"SELECT last_insert_rowid()";
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        
        if ([rs next]) {
            int lastId = [rs intForColumnIndex:0];
            NSLog(@"lastId = %i", lastId);
            return lastId;
        }
    }
    return -1;
}
- (void) deleteContact:(ContactVO *) contact{
    NSString *sql;
    BOOL success;
    
    sql = @"delete from contact where contact_id=?";
    
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               contact.contact_id
               ];
    
    if (!success) {
        NSLog(@"####### SQL Delete failed #######");
    } else {
        NSLog(@"====== SQL DELETE SUCCESS ======");
    }
    
}
- (void) updateContact:(ContactVO *) contact{
    NSString *sql;
    BOOL success;
    NSDate *now = [NSDate date];
    NSString *dt = [DateTimeUtils dbDateTimeStampFromDate:now];
    NSLog(@"dt %@", dt);
    
    sql = @"UPDATE contact set system_id=?, first_name=?, last_name=?, phone=?, type=?, status=?, updated=? where contact_id=?";
    success = [[SQLiteDB sharedConnection] executeUpdate:sql,
               contact.system_id,
               contact.first_name,
               contact.last_name,
               contact.phone,
               contact.type,
               contact.status,
               dt,
               [NSNumber numberWithInt:contact.contact_id]
               ];
    
    if (!success) {
        NSLog(@"####### SQL Update failed #######");
    } else {
        NSLog(@"====== SQL UPDATE SUCCESS ======");
    }
    
}

- (int) fetchLastContactID{
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"SELECT MAX(contact_id) AS max_id FROM contact";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
    int maxId = 0;
    
    if ([rs next]) {
        maxId = [rs intForColumnIndex:0];
    }
    
    return maxId;
}


#pragma mark - parse.com - Contact API

- (void) apiSaveContact:(ContactVO *)contact callback:(void (^)(PFObject *))callback {
    NSLog(@"%s", __FUNCTION__);
    
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    [query whereKey:@"phone" equalTo:contact.phone];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        PFObject *data = nil;
        
        if (results.count == 0) {
            data = [PFObject objectWithClassName:kContactDB];
            
            data[@"phone"] = contact.phone;
            
            if (contact.first_name != nil) {
                data[@"first_name"] = contact.first_name;
            }
            
            if (contact.last_name != nil) {
                data[@"last_name"] = contact.last_name;
            }
            
            if (contact.email != nil) {
                data[@"email"] = contact.email;
            }
            
            [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Saved contact with objectId %@", data.objectId);
                callback(data);
                //                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_contactSavedNotification
                //                                                                                                     object:data]];
            }];
            
        } else if (results.count > 0) {
            data = [results objectAtIndex:0];
            
            if (results.count > 1) {
                NSLog(@"Data consistency exception. Multiple contacts with same phone number");
            }
            NSLog(@"Found contact with phone %@", contact.phone);
            
            callback(data);
            //            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_contactSavedNotification
            //                                                                                                 object:data]];
        }
        
    }];
    
    
}
// NOT FINISHED
- (void) apiUpdateContact:(ContactVO *)contact callback:(void (^)(PFObject *))callback {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"NOT FINISHED");
    
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        PFObject *data = nil;
        
        if (results.count == 0) {
            callback(nil);
            
        } else {
            data = [results objectAtIndex:0];
            
            callback(data);
            //            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_contactSavedNotification
            //                                                                                                 object:data]];
        }
        
    }];
    
    
}

- (void) apiLoadContact:(NSString *)contactKey callback:(void (^)(PFObject *))callback {
    NSLog(@"%s", __FUNCTION__);
    
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    
    [query getObjectInBackgroundWithId:contactKey block:^(PFObject *object, NSError *error) {
        callback(object);
    }];
}

- (void) apiLookupContacts:(NSArray *)contactKeys callback:(void (^)(NSArray *))callback {
    NSLog(@"%s", __FUNCTION__);
    
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    [query whereKey:@"objectId" containedIn:contactKeys];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        ContactVO *contact;
        for (PFObject *result in results) {
            
            if ([[DataModel shared].contactCache objectForKey:result.objectId] == nil) {
                contact = [ContactVO readFromPFObject:result];
                [[DataModel shared].contactCache setObject:contact forKey:result.objectId];
            } else {
                contact = [[DataModel shared].contactCache objectForKey:result.objectId];
            }
            [contacts addObject:contact];
        }
        callback([contacts copy]);
    }];
}


- (void) apiLookupContactsByPhoneNumbers:(NSArray *)numbers callback:(void (^)(NSArray *))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kContactDB];
    [query whereKey:@"phone" containedIn:numbers];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        ContactVO *contact;
        for (PFObject *result in results) {
            contact = [ContactVO readFromPFObject:result];
            
            [contacts addObject:contact];
        }
        callback([contacts copy]);
    }];
    
}
- (UIImage *) loadCachedPhoto:(NSString *)contactKey {
    @try {
        NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
        NSString *filename;
        filename = [NSString stringWithFormat:@"%@.png", contactKey];
        
        NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        
        if (image) {
            return image;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR %@", exception);
    }
    return nil;
}
- (void)asyncLoadCachedPhoto:(NSString *)contactKey callback:(void (^)(UIImage *img))callback
{
    NSLog(@"%s", __FUNCTION__);
    
    @try {
        NSArray *pathsToDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [pathsToDocuments objectAtIndex:0];
        NSString *filename;
        filename = [NSString stringWithFormat:@"%@.png", contactKey];
        
        NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        
        if (image) {
            NSLog(@"Found cached image at %@", filepath);
            callback(image);
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:kContactDB];
            
            [query getObjectInBackgroundWithId:contactKey block:^(PFObject *pfContact, NSError *error) {
                if (pfContact) {
                    PFFile *pfImage = pfContact[@"photo"];
                    if (pfImage) {
                        NSLog(@"Contact has photo");
                        [pfImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                            if (!error) {
                                if (imageData) {
                                    NSLog(@"Downloading image at %@", pfImage.url);
                                    
                                    [imageData writeToFile:filepath atomically:NO];
                                    
                                    UIImage *image = [UIImage imageWithData:imageData];
                                    callback(image);
                                    
                                } else {
                                    NSLog(@"No imageData");
                                    callback(nil);
                                }
                            } else {
                                NSLog(@"Error occurred %@", error);
                                callback(nil);
                            }
                        }];
                        
                    } else {
                        NSLog(@"Contact has no photo");
                        callback(nil);
                    }
                } else {
                    
                    NSLog(@"Contact not found");
                    callback(nil);
                }
            }];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR %@", exception);
    }
}


#pragma mark - PrivacyDB

// Add row in PrivacyDB to block another user
- (void) apiPrivacyListBlocks:(NSString *)contactKey callback:(void (^)(NSArray *))callback {
    PFQuery *query = [PFQuery queryWithClassName:kPrivacyDB];
    [query whereKey:@"contact"
            equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
//    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:PrivacyType_BLOCK_USER]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        
        for (PFObject *data in results) {
            if (data[@"blocked"]) {
                PFObject *pfContact = (PFObject *) data[@"blocked"];
                [keys addObject:pfContact.objectId];
            }
        }
        callback([keys copy]);
    }];
    
}


- (void) apiPrivacyLookupBlock:(NSString *)contactKey blockedKey:(NSString *)blockedKey callback:(void (^)(PFObject *))callback {
    PFQuery *query = [PFQuery queryWithClassName:kPrivacyDB];
    [query whereKey:@"contact"
            equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey]];
    [query whereKey:@"blocked"
            equalTo:[PFObject objectWithoutDataWithClassName:kContactDB objectId:blockedKey]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        PFObject *data = nil;
        
        if (results.count > 0) {
            data = [results objectAtIndex:0];
            
            callback(data);
            
        } else {
            callback(nil);
        }
    }];
    
}
- (void) apiPrivacyBlockUser:(NSString *)contactKey blockedKey:(NSString *)blockedKey callback:(void (^)(PFObject *))callback {
    NSLog(@"%s", __FUNCTION__);
    PFObject *data = nil;
    
    data = [PFObject objectWithClassName:kPrivacyDB];
    
    data[@"contact"] = [PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey];
    data[@"blocked"] = [PFObject objectWithoutDataWithClassName:kContactDB objectId:blockedKey];
    data[@"type"] = [NSNumber numberWithInt:PrivacyType_BLOCK_USER];
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            callback(data);
        }
    }];
    
    
}

- (void) apiPrivacyUnblockUser:(NSString *)contactKey blockedKey:(NSString *)blockedKey callback:(void (^)(PFObject *))callback {
    NSLog(@"%s", __FUNCTION__);
    PFObject *data = nil;
    
    data = [PFObject objectWithClassName:kPrivacyDB];
    
    data[@"contact"] = [PFObject objectWithoutDataWithClassName:kContactDB objectId:contactKey];
    data[@"blocked"] = [PFObject objectWithoutDataWithClassName:kContactDB objectId:blockedKey];
    data[@"type"] = [NSNumber numberWithInt:PrivacyType_BLOCK_USER];
    [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            callback(data);
        }
    }];
    
    
}

#pragma mark - Phonebook DAO

- (NSDictionary *) findPersonByPhone:(NSString *)phone {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *sql = nil;
    sql = @"select * from phone_book where phone=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql, phone];
    
    NSDictionary *dict;
    if ([rs next]) {
        dict = [rs resultDictionary];
    }
    
    return dict;
}

- (NSMutableArray *) listPhonebookByStatus:(int)status {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *sql = @"select * from phonebook where status=?";
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       [NSNumber numberWithInt:status]];
    while ([rs next]) {
        [results addObject:[rs resultDictionary]];
    }
    
    return results;
    
}
- (ContactVO *) lookupContactKeyInPhonebook:(NSArray *)key {
    NSString *sql = @"select * from phonebook where contact_key=?";
    ContactVO *contact;
    
    FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                       key];
    
    if ([rs next]) {
        contact = [ContactVO readFromPhonebook:[rs resultDictionary]];
        return contact;
    }
    return nil;
    
}
- (NSMutableDictionary *) lookupContactsFromPhonebook:(NSArray *)contactKeys {
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    NSString *sql = @"select * from phonebook where contact_key=?";
    ContactVO *contact;
    
    for (NSString *key in contactKeys) {
        NSLog(@"Lookup for contactKey %@", key);
        if ([[DataModel shared].phonebookCache objectForKey:key] == nil) {
            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                               key];
            
            if ([rs next]) {
                contact = [ContactVO readFromPhonebook:[rs resultDictionary]];
                NSLog(@"Found name %@ -- phone %@ for key %@", contact.first_name, contact.phone, key);
                [[DataModel shared].phonebookCache setObject:contact forKey:key];
                [results setObject:contact forKey:key];
            } else {
                NSLog(@"Did not find key %@", key);
                //                [results setObject:[NSNull null] forKey:key];
            }
            
        } else {
            contact = [[DataModel shared].phonebookCache objectForKey:key];
            NSLog(@"Found cached phone %@ for key %@", contact.phone, key);
            [results setObject:contact forKey:key];
        }
    }
    return results;
    
}


//- (NSMutableArray *) lookupContactsFromPhonebook:(NSArray *)contactKeys {
//
//    NSMutableArray *results = [[NSMutableArray alloc] init];
//
//    NSString *sql = @"select * from phonebook where contact_key=?";
//    ContactVO *contact;
//
//    for (NSString *key in contactKeys) {
//        NSLog(@"Lookup for contactKey %@", key);
//        if ([[DataModel shared].contactCache objectForKey:key] == nil) {
//            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
//                               key];
//
//            if ([rs next]) {
//                contact = [ContactVO readFromPhonebook:[rs resultDictionary]];
//                [[DataModel shared].contactCache setObject:contact forKey:key];
//                [results addObject:contact];
//            }
//
//        } else {
//            contact = [[DataModel shared].contactCache objectForKey:key];
//            [results addObject:contact];
//        }
//    }
//    return results;
//
//}
//

- (void)purgePhonebook;
{
    NSLog(@"%s", __FUNCTION__);
    
    
    [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql;
        BOOL success;
        sql = @"DELETE from phonebook";
        success = [db executeUpdate:sql];
    }];
}

- (void)bulkLoadPhonebook:(NSArray *)contacts;
{
    NSLog(@"%s", __FUNCTION__);
    
    
    [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *insertSql = @"INSERT INTO phonebook (record_id, first_name, last_name, phone, status, timestamp) VALUES (?, ?, ?, ?, ?, ?);";
        for (ContactVO *contact in contacts) {
            
            BOOL success = [db executeUpdate:insertSql,
                            contact.record_id,
                            contact.first_name,
                            contact.last_name,
                            contact.phone,
                            [NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0]
                            ];
            
            if (!success) {
                NSLog(@"################################### SQL Insert failed ###################################");
            }
        }
    }];
    
}
- (void)updatePhonebookWithContacts:(NSArray *)contacts;
{
    //    NSLog(@"%s", __FUNCTION__);
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    [[SQLiteDB sharedQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql;
        BOOL success;
        sql = @"update phonebook set status=1, contact_key=?, timestamp=? where phone=?";
        for (ContactVO *contact in contacts) {
            success = [db executeUpdate:sql,
                       contact.system_id,
                       [NSNumber numberWithDouble:seconds],
                       contact.phone];
        }
    }];
}


#pragma mark - Address Book integration

- (NSMutableArray *)readAddressBook {
    NSMutableSet *phoneSet = [[NSMutableSet alloc] init];
    NSMutableArray *peopleData = [[NSMutableArray alloc] init];
    
    CFErrorRef err;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //        dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted)
    {
        
        NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        ContactVO *contact;
        NSLog(@"original addressBook count %i", people.count);
        // Only capture users who have mobile phone numbers
        for (int i=0; i<people.count; i++) {
            ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:i];
            ABRecordID abRecordID = ABRecordGetRecordID(person);
            NSNumber *recordId = [NSNumber numberWithInt:abRecordID];
            
            @try {
                ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                //                NSString* mobile=nil;
                NSString* phonenumber;
                
                //                NSString* mobileLabel;
                for (int i=0; i < ABMultiValueGetCount(phones); i++) {
                    phonenumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    
                    phonenumber = [self formatPhoneNumberAsE164:phonenumber];
                    
                    if (![phoneSet containsObject:phonenumber]) {
                        //                    mobile = [self makePhoneId:mobile];
                        contact = [[ContactVO alloc] init];
                        contact.phone = phonenumber;
                        CFStringRef firstName;
                        CFStringRef lastName;
                        
                        firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                        lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                        if (firstName) {
                            contact.first_name = (__bridge NSString *)firstName;
                        } else {
                            contact.first_name = @"";
                        }
                        if (lastName) {
                            contact.last_name = (__bridge NSString *)lastName;
                        } else {
                            contact.last_name = @"";
                        }
                        
                        if (contact.first_name.length == 0 && contact.last_name.length == 0) {
                            contact.first_name = contact.phone;
                        }
                        contact.record_id = recordId;
                        [peopleData addObject:contact];
                        [phoneSet addObject:phonenumber];
                        if (firstName)
                            CFRelease(firstName);
                        if (lastName)
                            CFRelease(lastName);
                        
                    }
                    
                }
                
                
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            
        }
    }
    CFRelease(addressBook);
    
    return peopleData;
}

// http://en.wikipedia.org/wiki/E.164
- (NSString *) formatPhoneNumberAsE164:(NSString *)phone {
    NSString *result = nil;
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *aError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:phone defaultRegion:@"US" error:&aError];
    
    if (aError == nil) {
        // Should check error
        result = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164
                             error:&aError];
    }
    else {
        NSLog(@"Error : %@", [aError localizedDescription]);
    }
    return result;
    
}

- (NSString *) makePhoneId:(NSString *)originalString {
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return strippedString;
}


@end
