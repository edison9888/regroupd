//
//  ContactVO.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/16/13.
//
//

#import <Foundation/Foundation.h>

@interface ContactVO : NSObject

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
@property int contact_id;
@property (nonatomic, retain) NSNumber *record_id;

@property (nonatomic, retain) NSString *system_id;
//@property (nonatomic, retain) NSString *contact_key;

@property (nonatomic, retain) NSString *facebook_id;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *imagefile;


@property int type;
@property int status;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

- (NSString *) fullname;

+ (ContactVO *) readFromDictionary:(NSDictionary *) dict;
+ (ContactVO *) readFromPhonebook:(NSDictionary *) data;
+ (ContactVO *) readFromPFObject:(PFObject *)data;
+ (ContactVO *) readFromPFUserContact:(PFObject *)data;
@end
