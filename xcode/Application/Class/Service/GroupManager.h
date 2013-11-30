//
//  GroupManager.h
//  Regroupd
//
//  Created by Hugh Lang on 11/2/13.
//
//

#import <Foundation/Foundation.h>
#import "GroupVO.h"

@interface GroupManager : NSObject


- (GroupVO *) loadGroup:(int)_groupId;
- (GroupVO *) loadGroup:(int)_groupId fetchAll:(BOOL)all;
- (int) saveGroup:(GroupVO *) group;
- (void) deleteGroup:(GroupVO *) group;
- (void) updateGroup:(GroupVO *) group;
- (NSMutableArray *) listGroups:(int)type;
- (int) fetchLastGroupID;

- (void) saveGroupContact:(int)groupId contactKey:(NSString *)contactKey;
- (NSMutableArray *) listGroupContacts:(int)groupId;
- (BOOL) checkGroupContact:(int)groupId contactId:(int)contactId;
- (void) addGroupContact:(int)groupId contactId:(int)contactId;
- (void) removeGroupContact:(int)groupId contactId:(int)contactId;

@end
