//
//  FormResponse.h
//  Regroupd
//
//  Created by Hugh Lang on 11/17/13.
//
//

#import <Foundation/Foundation.h>

@interface FormResponseVO : NSObject

@property (nonatomic, retain) NSString *system_id;
@property (nonatomic, retain) NSString *contact_key;
@property (nonatomic, retain) NSString *form_key;
@property (nonatomic, retain) NSString *option_key;

@property (nonatomic, retain) NSArray *option_keys;
@property (nonatomic, retain) NSNumber *rating;

@property int status;

@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

//@property (nonatomic, retain) NSString *form_key;
+ (FormResponseVO *) readFromPFObject:(PFObject *)data;

@end
