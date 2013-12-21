//
//  ANPopoverSlider.h
//  CustomSlider
//
//

#import <UIKit/UIKit.h>
#define kSelectedColor      0x8755a2   //purple
#define kDotColor           0x613976  // dark purple
#define kUnselectedColor    0x68747b  // grey
#define kFadedAlpha     0.8f

@interface FancySlider : UISlider

@property (nonatomic, readonly) CGRect thumbRect;

@end

