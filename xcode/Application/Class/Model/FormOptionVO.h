//
//  FormOptionVO.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/26/13.
//
//
typedef enum {
	OptionType_TEXT = 1,
	OptionType_IMAGE
}OptionType;

typedef enum {
	OptionStatus_DRAFT = 1,
	OptionStatus_PUBLISHED
}OptionStatus;


#import <Foundation/Foundation.h>

/*
 
 option_id INTEGER PRIMARY KEY,
 form_id INTEGER,
 system_id TEXT,
 name TEXT,
 stats TEXT,
 datafile TEXT,
 imagefile TEXT,
 type int DEFAULT 1,
 status INT DEFAULT 0,
 created TEXT,
 updated TEXT
 */
@interface FormOptionVO : NSObject {
    
}
@property int option_id;
@property int form_id;
@property int position;

@property (nonatomic, retain) NSString *system_id;
//@property (nonatomic, retain) NSString *form_key;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *stats;
@property (nonatomic, retain) NSString *datafile;
@property (nonatomic, retain) NSString *imagefile;
@property int type;
@property int status;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

// Transient fields
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) PFFile *pfPhoto;
@property BOOL isSelected;
@property (nonatomic, retain) NSMutableArray *responses;


+ (FormOptionVO *) readFromDictionary:(NSDictionary *) dict;
+ (FormOptionVO *) readFromPFObject:(PFObject *)data;

@end
