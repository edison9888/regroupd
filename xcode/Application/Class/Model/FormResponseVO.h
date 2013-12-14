//
//  FormResponse.h
//  Re:group'd
//
//  Created by Hugh Lang on 11/17/13.
//
//

#import <Foundation/Foundation.h>
#import "ChatVO.h"
#import "ContactVO.h"

@interface FormResponseVO : NSObject

@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *contact_key;
@property (nonatomic, retain) NSString *form_key;
@property (nonatomic, retain) NSString *chat_key;
@property (nonatomic, retain) NSString *option_key;

@property (nonatomic, retain) NSNumber *rating;

@property int status;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;


// Transient fields
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) PFFile *pfPhoto;

@property (nonatomic, retain) ContactVO *contact;
@property (nonatomic, retain) ChatVO *chat;

@property (nonatomic, retain) NSNumber *answerTotal;
@property (nonatomic, retain) NSNumber *ratingTotal;
@property (nonatomic, retain) NSNumber *ratingCount;

//@property (nonatomic, retain) NSString *form_key;
+ (FormResponseVO *) readFromPFObject:(PFObject *)data;

@end
