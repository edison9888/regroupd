//
//  FormVO.h
//  Regroupd
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
 type int DEFAULT 1,
 status INT DEFAULT 0,
 event_date TEXT,
 created TEXT,
 updated TEXT
 */

@interface FormVO : NSObject {
    
}
@property int form_id;
@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *name;
@property int type;
@property int status;
@property (nonatomic, retain) NSString *event_date;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

@property (nonatomic, retain) NSMutableArray *options;

+ (FormVO *) readFromDictionary:(NSDictionary *) dict;


@end
