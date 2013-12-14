//
//  FormResponse.m
//  Re:group'd
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
//    PFObject *pfObject;
    
    o.system_id = data.objectId;
    o.createdAt = data.createdAt;
    o.updatedAt = data.updatedAt;

    if (data[@"contact"]) {
        o.contact_key = ((PFObject *) data[@"contact"]).objectId;
//        pfObject = data[@"contact"];
//        [pfObject fetchIfNeeded];
//        o.contact = [ContactVO readFromPFObject:pfObject];
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
