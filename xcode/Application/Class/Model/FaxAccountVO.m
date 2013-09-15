//
//  FaxAccountVO.m
//  eAttending
//
//  Created by Hugh Lang on 8/13/13.
//
//

#import "FaxAccountVO.h"

@implementation FaxAccountVO

@synthesize account_id, user_id, qty_purchased, qty_used, qty_left, status;
@synthesize purchase_id, created, updated;

+ (FaxAccountVO *) readFromDictionary:(NSDictionary *) dict {
    FaxAccountVO *o = [[FaxAccountVO alloc] init];
    NSString *text;
    
    text = [dict valueForKey:@"account_id"];
    o.account_id = text.integerValue;
    text = [dict valueForKey:@"user_id"];
    o.user_id = text.integerValue;
    text = [dict valueForKey:@"qty_purchased"];
    o.qty_purchased = text.integerValue;
    text = [dict valueForKey:@"qty_used"];
    o.qty_used = text.integerValue;
    text = [dict valueForKey:@"qty_left"];
    o.qty_left = text.integerValue;
    text = [dict valueForKey:@"status"];
    o.status = text.integerValue;
    text = [dict valueForKey:@"purchase_id"];
    o.purchase_id = text;
    text = [dict valueForKey:@"created"];
    o.created = text;
    text = [dict valueForKey:@"updated"];
    o.updated = text;
    
    return o;
}
@end
