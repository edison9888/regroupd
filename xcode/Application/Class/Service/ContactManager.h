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

- (GroupVO *) loadGroup:(int)_groupId;
- (GroupVO *) loadGroup:(int)_groupId fetchAll:(BOOL)all;
- (int) saveGroup:(GroupVO *) group;
- (void) deleteGroup:(GroupVO *) group;
- (void) updateGroup:(GroupVO *) group;
- (NSMutableArray *) listGroups:(int)type;
- (int) fetchLastGroupID;

// API METHODS
- (void) apiSaveContact:(ContactVO *)contact callback:(void (^)(PFObject *))callback;

- (void) apiLookupContacts:(NSArray *)contactKeys callback:(void (^)(NSArray *))callback;

- (void) apiListUserContacts:(NSString *)userKey callback:(void (^)(NSArray *))callback;

- (void) apiSaveUserContact:(ContactVO *)contact callback:(void (^)(NSString *))callback;

- (NSMutableArray *) listGroupContacts:(int)groupId;
- (BOOL) checkGroupContact:(int)groupId contactId:(int)contactId;
- (void) addGroupContact:(int)groupId contactId:(int)contactId;
- (void) removeGroupContact:(int)groupId contactId:(int)contactId;


@end
