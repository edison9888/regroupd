//
//  GroupManager.h
//  Re:group'd
//
//  Created by Hugh Lang on 10/21/13.
//
//

#import <Foundation/Foundation.h>
#import "GroupVO.h"
#import "ContactVO.h"

@interface ContactManager : NSObject {
    
}
- (NSString *) formatPhoneNumberAsE164:(NSString *)phone;

- (ContactVO *) loadContact:(int)_contactId;
- (int) saveContact:(ContactVO *) contact;
- (void) deleteContact:(ContactVO *) contact;
- (void) updateContact:(ContactVO *) contact;


// API METHODS

- (void) apiSaveContact:(ContactVO *)contact callback:(void (^)(PFObject *))callback;
- (void) apiUpdateContact:(ContactVO *)contact callback:(void (^)(PFObject *))callback;

- (void) apiLoadContact:(NSString *)contactKey callback:(void (^)(PFObject *))callback;

- (void) apiLookupContacts:(NSArray *)contactKeys callback:(void (^)(NSArray *))callback;
- (void) apiLookupContactsByPhoneNumbers:(NSArray *)numbers callback:(void (^)(NSArray *))callback;

- (void) apiSendSMSInviteCode:(NSString *) phone callback:(void (^)(NSString *))callback;

// PRIVACY API METHODS

- (void) apiPrivacyLookupBlock:(NSString *)contactKey blockedKey:(NSString *)blockedKey callback:(void (^)(PFObject *))callback;
- (void) apiPrivacyBlockUser:(NSString *)contactKey blockedKey:(NSString *)blockedKey callback:(void (^)(PFObject *))callback;
- (void) apiPrivacyListBlocks:(NSString *)contactKey callback:(void (^)(NSArray *))callback;

- (UIImage *) loadCachedPhoto:(NSString *)contactKey;

- (void) asyncLoadCachedPhoto:(NSString *)contactKey callback:(void (^)(UIImage *img))callback;

// Phonebook methods
- (NSDictionary *) findPersonByPhone:(NSString *)phone;
- (NSMutableArray *) listPhonebookByStatus:(int)status;
- (NSMutableDictionary *) lookupContactsFromPhonebook:(NSArray *)contactKeys;
- (ContactVO *) lookupContactKeyInPhonebook:(NSArray *)key;

- (void)bulkLoadPhonebook:(NSArray *)contacts;
- (void)purgePhonebook;
- (void)updatePhonebookWithContacts:(NSArray *)contacts;

// Address Book
- (NSMutableArray *)readAddressBook;
- (ContactVO *) readContactFromAddressBook:(NSNumber *)recordId;

@end
