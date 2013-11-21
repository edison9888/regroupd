//
//  FormResponse.m
//  Regroupd
//
//  Created by Hugh Lang on 11/17/13.
//
//

#import "FormResponseVO.h"

@implementation FormResponseVO

+ (FormResponseVO *) readFromPFObject:(PFObject *)data {
    FormResponseVO *o = [[FormResponseVO alloc] init];
    NSString *text;
    NSNumber *number;
    
    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;

    if (data[@"contact"]) {
        o.contact_key = ((PFObject *) data[@"contact"]).objectId;
    }
    if (data[@"form"]) {
        o.form_key = ((PFObject *) data[@"form"]).objectId;
    }
    if (data[@"chat"]) {
        o.chat_key = ((PFObject *) data[@"chat"]).objectId;
    }
    if (data[@"option"]) {
        o.option_key = ((PFObject *) data[@"option"]).objectId;
    }
//    text = [data valueForKey:@"contact_key"];
//    o.contact_key = text;
//    text = [data valueForKey:@"form_key"];
//    o.form_key = text;
//    text = [data valueForKey:@"chat_key"];
//    o.chat_key = text;
//    text = [data valueForKey:@"option_key"];
//    o.option_key = text;

    if (data[@"status"]) {
        text = [data valueForKey:@"status"];
        o.status = text.integerValue;
    }
    if (data[@"rating"]) {
        number = [data valueForKey:@"rating"];
        o.rating = number;
    }

    return o;
}

@end
