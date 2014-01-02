//
//  GroupManager.h
//  Re:group'd
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

- (BOOL) checkGroupContact:(int)groupId contacKey:(NSString *)contactKey;
- (void) saveGroupContact:(int)groupId contactKey:(NSString *)contactKey;
- (void) removeGroupContact:(int)groupId contactKey:(NSString *)contactKey;
- (NSMutableArray *) listGroupContactKeys:(int)groupId;
- (NSMutableArray *) listContactGroupIds:(NSString *)contactKey;

- (NSMutableArray *) listContactGroups:(NSString *)contactKey;


@end
