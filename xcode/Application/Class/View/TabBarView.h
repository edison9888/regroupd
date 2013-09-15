//
//  BrandNavView.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/14/13.
//
//

#import <UIKit/UIKit.h>

@interface TabBarView : UIView {
    UIView *_theView;
    NSMutableDictionary *_buttonMap;
    UIImageView *_bgLayer;
    
}

- (void) moveLayerToIndex:(int)index;

@end
