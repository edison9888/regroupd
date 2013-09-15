//
//  FaxLogVO.m
//  eAttending
//
//  Created by Hugh Lang on 8/5/13.
//
//

#import "FaxLogVO.h"

@implementation FaxLogVO

@synthesize log_id, contact_id, user_id, account_id, type, status;
@synthesize patient_name, efax_id, fax, message, created;
@synthesize contact_name;

+ (FaxLogVO *) readFromDictionary:(NSDictionary *) dict {
    FaxLogVO *o = [[FaxLogVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"log_id"];
    o.log_id = text.integerValue;
    text = [dict valueForKey:@"contact_id"];
    o.contact_id = text.integerValue;
    text = [dict valueForKey:@"user_id"];
    o.user_id = text.integerValue;
    text = [dict valueForKey:@"account_id"];
    o.account_id = text.integerValue;
    text = [dict valueForKey:@"type"];
    o.type = text.integerValue;
    text = [dict valueForKey:@"status"];
    o.status = text.integerValue;
    text = [dict valueForKey:@"patient_name"];
    o.patient_name = text;

    text = [dict valueForKey:@"efax_id"];
    o.efax_id = text;
    text = [dict valueForKey:@"fax"];
    o.fax = text;
    text = [dict valueForKey:@"message"];
    o.message = text;
    text = [dict valueForKey:@"created"];
    o.created = text;
    text = [dict valueForKey:@"name"];
    o.contact_name = text;
    
    
    return o;
}
@end
