//
//  BuyFaxData.h
//  eAttending
//
//  Created by Hugh Lang on 8/3/13.
//
//

#import <Foundation/Foundation.h>

@interface BuyFaxData : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property int qty;
@property double price;

@end
