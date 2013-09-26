//
//  UserVO.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/2/13.
//
//

#import "UserVO.h"
#import <objc/runtime.h>

@implementation UserVO

@synthesize user_id, status;
@synthesize firstname, middlename, lastname;
@synthesize company, title, phone, fax;
@synthesize address, city, state, zip;
@synthesize password, hint;

@synthesize verifycode;

- (id)init
{
    self = [super init];
    status = 0;
    
    return self;
}

-(void)dumpInfo
{
    Class clazz = [self class];
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}

- (NSString *) getFullname {
    NSString *fmt = @"%@ %@";
    NSString *output = [NSString stringWithFormat:fmt, self.firstname, self.lastname];
    return output;
}
+ (UserVO *) readFromDictionary:(NSDictionary *) dict {
    UserVO *o = [[UserVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"user_id"];
    o.user_id = text.integerValue;
    text = [dict valueForKey:@"status"];
    o.status = text.integerValue;
    
    text = [dict valueForKey:@"firstname"];
    o.firstname = text;
    text = [dict valueForKey:@"middlename"];
    o.middlename = text;
    text = [dict valueForKey:@"lastname"];
    o.lastname = text;
    text = [dict valueForKey:@"company"];
    o.company = text;
    text = [dict valueForKey:@"title"];
    o.title = text;
    text = [dict valueForKey:@"phone"];
    o.phone = text;
    text = [dict valueForKey:@"fax"];
    o.fax = text;
    text = [dict valueForKey:@"address"];
    o.address = text;
    text = [dict valueForKey:@"city"];
    o.city = text;
    text = [dict valueForKey:@"state"];
    o.state = text;
    text = [dict valueForKey:@"zip"];
    o.zip = text;
    text = [dict valueForKey:@"password"];
    o.password = text;
    text = [dict valueForKey:@"hint"];
    o.hint = text;
//    text = [dict valueForKey:@"email"];
//    o.email = text;
    
    
    return o;
}

@end
