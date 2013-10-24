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

- (NSMutableArray *) listGroupContacts:(int)groupId;
- (BOOL) checkGroupContact:(int)groupId contactId:(int)contactId;
- (void) addGroupContact:(int)groupId contactId:(int)contactId;
- (void) removeGroupContact:(int)groupId contactId:(int)contactId;

- (NSString *) apiSaveContact:(ContactVO *) contact;

@end
