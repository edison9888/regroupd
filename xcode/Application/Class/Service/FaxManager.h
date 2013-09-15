//
//  FaxManager.h
//  eAttending
//
//  Created by Hugh Lang on 8/11/13.
//
//

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"
#import "FaxLogVO.h"
#import "FaxAccountVO.h"
#import "ContactVO.h"

@interface FaxManager : NSObject {
    
}

- (FaxAccountVO *) loadCurrentAccount:(int) userId;
- (int) createFaxAccount:(FaxAccountVO *)account;
- (void) updateAccountBalance:(FaxAccountVO *)account;

- (FaxLogVO *) selectLastLog:(int) userId;
- (int) createFaxLog:(FaxLogVO *)faxlog;
- (void) updateFaxLog:(FaxLogVO *)faxlog;

- (ContactVO *) selectContactByID:(int) contactId;

+ (NSString *) renderFaxQtyLabel:(int) qty;

@end
