//
//  BuyFaxModel.m
//  eAttending
//
//  Created by Hugh Lang on 8/3/13.
//
//

#import "BuyFaxModel.h"
#import "BuyFaxData.h"

@implementation BuyFaxModel

@synthesize buyDB;
@synthesize buyList;

- (id)init{
    if ((self = [super init])) {
        [self load];
    }
    return self;
}

- (void) load {
    BuyFaxData *data;
    
    buyDB = [[NSMutableDictionary alloc] init];
    buyList = [[NSMutableArray alloc] init];
    
    data = [[BuyFaxData alloc] init];
    data.qty = 5;
    data.price = 10.0;
    data.title = @"5 Faxes for $10";
    data.key = @"buy5";
    [buyDB setObject:data forKey:data.key];
    [buyList addObject:data];
    
    data = [[BuyFaxData alloc] init];
    data.qty = 10;
    data.price = 18.0;
    data.title = @"10 Faxes for $18";
    data.key = @"buy10";
    [buyDB setObject:data forKey:data.key];
    [buyList addObject:data];
    
    data = [[BuyFaxData alloc] init];
    data.qty = 20;
    data.price = 30.0;
    data.title = @"20 Faxes for $30";
    data.key = @"buy20";
    [buyDB setObject:data forKey:data.key];
    [buyList addObject:data];
    
    data = [[BuyFaxData alloc] init];
    data.qty = 40;
    data.price = 48.0;
    data.title = @"40 Faxes for $48";
    data.key = @"buy40";
    [buyDB setObject:data forKey:data.key];
    [buyList addObject:data];

    data = [[BuyFaxData alloc] init];
    data.qty = 80;
    data.price = 78.0;
    data.title = @"80 Faxes for $78";
    data.key = @"buy80";
    [buyDB setObject:data forKey:data.key];
    [buyList addObject:data];
    
    data = [[BuyFaxData alloc] init];
    data.qty = 160;
    data.price = 125.0;
    data.title = @"160 Faxes for $125";
    data.key = @"buy160";
    [buyDB setObject:data forKey:data.key];
    [buyList addObject:data];


}

@end
