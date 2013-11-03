
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
- (void) apiSaveUserContact:(ContactVO *)contact callback:(void (^)(NSString *))callback {
    PFQuery *query = [PFQuery queryWithClassName:kUserContactDB];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"contact_key" equalTo:contact.system_id];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *data, NSError *error){
//    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (data) {
            // object exists
            NSLog(@"Found UserContact with objectId %@", data.objectId);
            callback(data.objectId);
        } else {
            
            data[@"user"] = [PFUser currentUser];
            data = [PFObject objectWithClassName:kUserContactDB];
            data[@"contact_key"] = contact.system_id;
            
            if (contact.first_name != nil) {
                data[@"first_name"] = contact.first_name;
            }
            
            if (contact.last_name != nil) {
                data[@"last_name"] = contact.last_name;
            }
            [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    // Error auto-logged
                    
                } else {
                    NSLog(@"Saved UserContact with objectId %@", data.objectId);
                    callback(data.objectId);
                }
            }];
        }
    }];
}


// Usage. null userKey means use PFUser
- (void) apiListUserContacts:(NSString *)userKey callback:(void (^)(NSArray *))callback {
    
    PFQuery *query = [PFQuery queryWithClassName:kUserContactDB];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
//    [query whereKey:@"user" equalTo:[PFObject objectWithoutDataWithClassName:[PFUser parseClassName] objectId:userKey]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        ContactVO *contact;
        for (PFObject *result in results) {
            if ([[DataModel shared].contactCache objectForKey:contact.system_id] == nil) {
                contact = [ContactVO readFromPFUserContact:result];
                [[DataModel shared].contactCache setObject:contact forKey:result.objectId];
            } else {
                contact = [[DataModel shared].contactCache objectForKey:result.objectId];
            }
            [contacts addObject:contact];
        }
        callback([contacts copy]);
    }];

}

#pragma mark - OLD Non-async methods
- (PFObject *) apiSaveUserContact:(PFObject *) pfContact {
    NSLog(@"%s", __FUNCTION__);
    
    PFObject *data = [PFObject objectWithClassName:kUserContactDB];
    
    data[@"user"] = [PFUser currentUser];
    data[@"contact"] = pfContact;

    [data save];
    
    NSLog(@"Saved user_contact with objectId %@", data.objectId);
    return data;
    
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

- (NSMutableArray *) lookupContactsFromPhonebook:(NSArray *)contactKeys {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *sql = @"select * from phonebook where contact_key=?";
    ContactVO *contact;
    
    for (NSString *key in contactKeys) {
        NSLog(@"Lookup for contactKey %@", key);
        if ([[DataModel shared].contactCache objectForKey:key] == nil) {
            FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                               key];
            
            if ([rs next]) {
                contact = [ContactVO readFromPhonebook:[rs resultDictionary]];
                [[DataModel shared].contactCache setObject:contact forKey:key];
                [results addObject:contact];
            }
            
        } else {
            contact = [[DataModel shared].contactCache objectForKey:key];
            [results addObject:contact];
        }
    }
    return results;
    
}


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
    NSLog(@"%s", __FUNCTION__);
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
    NSMutableArray *peopleData = [[NSMutableArray alloc] init];
    
    CFErrorRef err;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    ContactVO *c;
    
    // Only capture users who have mobile phone numbers
    for (int i=0; i<people.count; i++) {
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:i];
        ABRecordID abRecordID = ABRecordGetRecordID(person);
        NSNumber *recordId = [NSNumber numberWithInt:abRecordID];
        
        @try {
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            NSString* mobile=nil;
            NSString* mobileLabel;
            for (int i=0; i < ABMultiValueGetCount(phones); i++) {
                //NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
                //NSLog(@"%@", phone);
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    continue;
                    
                } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMobileLabel]) {
                    mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                    continue;
                }
            }
            
            if (mobile != nil && mobile.length > 10) {
                
                mobile = [self makePhoneId:mobile];
                c = [[ContactVO alloc] init];
                c.phone = mobile;
                CFStringRef firstName;
                CFStringRef lastName;
                
                firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                c.first_name = (__bridge NSString *)firstName;
                c.last_name = (__bridge NSString *)lastName;
                c.record_id = recordId;
                [peopleData addObject:c];

                if (firstName)
                    CFRelease(firstName);
                if (lastName)
                    CFRelease(lastName);
                
            } else {
                // Ignore contact without mobile phone
                
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
    }
    CFRelease(addressBook);
    
    return peopleData;
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
