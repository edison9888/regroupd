//
//  FaxLogVO.h
//  eAttending
//
//  Created by Hugh Lang on 8/5/13.
//
//

/*
 
 log_id INTEGER PRIMARY KEY,
 contact_id INTEGER,
 bundle TEXT,
 fax TEXT,
 efax_id TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT
 */
#import <Foundation/Foundation.h>
#import "ContactVO.h"

@interface FaxLogVO : NSObject {
    
}
@property int log_id;
@property int contact_id;
@property int user_id;
@property int account_id;
@property int type;
@property int status;
@property (nonatomic, retain) NSString *patient_name;
@property (nonatomic, retain) NSString *efax_id;
@property (nonatomic, retain) NSString *fax;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *created;

@property (nonatomic, retain) NSString *contact_name;

+ (FaxLogVO *) readFromDictionary:(NSDictionary *) dict;

@end
