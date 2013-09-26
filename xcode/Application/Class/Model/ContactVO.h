//
//  ContactVO.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/16/13.
//
//

#import <Foundation/Foundation.h>

@interface ContactVO : NSObject


@property int contact_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *fax;
@property int type;
@property int status;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *updated;

+ (ContactVO *) readFromDictionary:(NSDictionary *) dict;

@end
