//
//  RatingMeterSlider.h
//  Regroupd
//
//  Created by Hugh Lang on 10/10/13.
//
//
/*
 This creates a rating slider bar any size with white background
 
 */
#import <UIKit/UIKit.h>
#define kSelectedColor      0x8755a2   //purple
#define kDotColor           0x613976  // dark purple
#define kUnselectedColor    0x68747b  // grey
#define kFadedAlpha     0.8f

@interface RatingMeterSlider : UIView {
    float lowerBound;
    float upperBound;
    UIColor *bgColor;
    UIColor *sliderColor;
    UIColor *dotColor;
}

@property float ratingValue;
@property float minValue;
@property float maxValue;

@property (nonatomic, strong) UIView *sliderBG;
@property (nonatomic, strong) UIView *meterBar;
@property (nonatomic, strong) UIView *ratingDot;

- (void) setBGColor:(UIColor *)color;
- (void) setSliderColor:(UIColor *)color;
- (void) setDotColor:(UIColor *)color;

- (void) setRatingBar:(float)value;
//- (void) setSliderBGColor:(UIColor *)color;

@end
