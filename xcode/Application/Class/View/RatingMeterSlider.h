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
