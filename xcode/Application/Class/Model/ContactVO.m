//
//  ContactVO.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/16/13.
//
//

#import "ContactVO.h"

@implementation ContactVO

@synthesize contactId, name, phone, fax;
@synthesize type, status, created, updated;

+ (ContactVO *) readFromDictionary:(NSDictionary *) dict {
    ContactVO *o = [[ContactVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"contact_id"];
    o.contactId = text.integerValue;
    text = [dict valueForKey:@"name"];
    o.name = text;
    text = [dict valueForKey:@"phone"];
    o.phone = text;
    text = [dict valueForKey:@"fax"];
    o.fax = text;
    text = [dict valueForKey:@"type"];
    o.type = text.intValue;
    text = [dict valueForKey:@"status"];
    o.status = text.intValue;
    text = [dict valueForKey:@"created"];
    o.created = text;
    text = [dict valueForKey:@"updated"];
    o.updated = text;
    
    return o;
}

@end
