//
//  BuyFaxModel.h
//  eAttending
//
//  Created by Hugh Lang on 8/3/13.
//
//

#import <Foundation/Foundation.h>

@interface BuyFaxModel : NSObject {
    NSMutableDictionary *buyDB;
    NSMutableArray *buyList;
}

@property (nonatomic, retain) NSMutableDictionary *buyDB;
@property (nonatomic, retain) NSMutableArray *buyList;

- (void) load;


@end
