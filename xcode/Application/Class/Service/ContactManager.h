//
//  GroupManager.h
//  Regroupd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import <Foundation/Foundation.h>
#import "GroupVO.h"
#import "ContactVO.h"

@interface ContactManager : NSObject {
    
}

- (ContactVO *) loadContact:(int)_contactId;
- (int) saveContact:(ContactVO *) contact;
- (void) deleteContact:(ContactVO *) contact;
- (void) updateContact:(ContactVO *) contact;


// API METHODS
- (void) apiSaveContact:(ContactVO *)contact callback:(void (^)(PFObject *))callback;

- (void) apiLookupContacts:(NSArray *)contactKeys callback:(void (^)(NSArray *))callback;

- (void) apiListUserContacts:(NSString *)userKey callback:(void (^)(NSArray *))callback;

- (void) apiSaveUserContact:(ContactVO *)contact callback:(void (^)(NSString *))callback;


- (void) apiLookupContactsByPhoneNumbers:(NSArray *)numbers callback:(void (^)(NSArray *))callback;

// Phonebook methods
- (NSDictionary *) findPersonByPhone:(NSString *)phone;
- (NSMutableArray *) listPhonebookByStatus:(int)status;
- (void)bulkLoadPhonebook:(NSArray *)contacts;
- (void)purgePhonebook;
- (void)updatePhonebookWithContacts:(NSArray *)contacts;

// Address Book
- (NSMutableArray *)readAddressBook;


@end
