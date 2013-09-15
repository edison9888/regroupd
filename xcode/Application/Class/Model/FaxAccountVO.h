//
//  FaxAccountVO.h
//  eAttending
//
//  Created by Hugh Lang on 8/13/13.
//
//

#import <Foundation/Foundation.h>

@interface FaxAccountVO : NSObject

/*
 CREATE TABLE IF NOT EXISTS fax_account (
 account_id INTEGER PRIMARY KEY,
 user_id INTEGER,
 qty_purchased INTEGER,
 qty_used INTEGER,
 purchase_id TEXT,
 status INT DEFAULT 0,
 created TEXT,
 updated TEXT
 );
 */

@property int account_id;
@property int user_id;
@property int qty_purchased;
@property int qty_used;
@property int qty_left;
@property int status;
@property (nonatomic, retain) NSString *purchase_id;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

+ (FaxAccountVO *) readFromDictionary:(NSDictionary *) dict;

@end
