//
//  ParseUtils.m
//  Regroupd
//
//  Created by Hugh Lang on 11/16/13.
//
//

#import "ParseUtils.h"

@implementation ParseUtils

+ (NSMutableDictionary *) readFormOptionDictFromPFObject:(PFObject *)data {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *text;
    NSDate *dt;
    NSNumber *number;
    text = data.objectId;
    [dict setObject:text forKey:@"system_id"];
    
    dt = data.createdAt;
    [dict setObject:dt forKey:@"createdAt"];

    dt = data.updatedAt;
    [dict setObject:dt forKey:@"updatedAt"];

    text = [data valueForKey:@"name"];
    [dict setObject:text forKey:@"name"];
    
    number = [data valueForKey:@"position"];
    [dict setObject:number forKey:@"position"];
    
    if (data[@"photo"]) {
        [dict setObject:data[@"photo"] forKey:@"photo"];
    }
    
    return dict;
}
@end
