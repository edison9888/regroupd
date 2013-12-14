//
//  FormVO.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/26/13.
//
//
typedef enum {
	FormType_POLL = 1,
	FormType_RATING,
	FormType_RSVP
}FormType;

typedef enum {
	FormStatus_DRAFT = 0,
	FormStatus_SAVED,
	FormStatus_PUBLISHED,
	FormStatus_REMOVED
}FormStatus;

#import <Foundation/Foundation.h>

/*
 form_id INTEGER PRIMARY KEY,
 system_id TEXT,
 name TEXT,
 location TEXT,
 description TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 start_time TEXT,
 end_time TEXT,
 allow_public INT DEFAULT 0,
 allow_share INT DEFAULT 0,
 allow_multiple INT DEFAULT 0,
 created TEXT,
 updated TEXT
 */

@interface FormVO : NSObject {
    
}
@property int form_id;
@property (nonatomic, retain) NSString *system_id;

@property (nonatomic, retain) NSString *user_key;
@property (nonatomic, retain) NSString *contact_key;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *details;
@property (nonatomic, retain) NSString *imagefile;
@property int type;
@property int status;

@property (nonatomic, retain) NSNumber *counter;

@property (nonatomic, retain) NSDate *eventStartsAt;
@property (nonatomic, retain) NSDate *eventEndsAt;

@property (nonatomic, retain) NSString *start_time;
@property (nonatomic, retain) NSString *end_time;

@property (nonatomic, retain) NSNumber *allow_public;
@property (nonatomic, retain) NSNumber *allow_share;
@property (nonatomic, retain) NSNumber *allow_multiple;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

// Transient fields
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) PFFile *pfPhoto;

@property (nonatomic, retain) NSMutableArray *options;

@property (nonatomic, retain) NSMutableDictionary *responsesMap;



+ (FormVO *) readFromDictionary:(NSDictionary *) dict;
+ (FormVO *) readFromPFObject:(PFObject *)data;

@end
