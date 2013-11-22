//
//  RatingMeterSlider.m
//  Regroupd
//
//  Created by Hugh Lang on 10/10/13.
//
//

#import "RatingMeterSlider.h"
#import <QuartzCore/QuartzCore.h>

@implementation RatingMeterSlider


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        bgColor = [UIColor whiteColor];
        dotColor = [UIColor clearColor];

        self.bounds = frame;
        // Initialization code
        self.minValue = 0;
        self.maxValue = 10;
        
        // Set zero to left edge excluding corner radius
        lowerBound = frame.size.height / 2;
        upperBound = frame.size.width - lowerBound;
        
        self.sliderBG = [[UIView alloc] initWithFrame:frame];
        self.sliderBG.backgroundColor = bgColor;
        
        [self setMaskTo:self.sliderBG byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:frame.size.height / 2];
        [self addSubview:self.sliderBG];
        
    }
    return self;
}


- (void) setRatingBar:(float)value {
    self.ratingValue = value;
    
    float percent = self.ratingValue / self.maxValue;
    
    float barWidth = ((upperBound - lowerBound) * percent) + (lowerBound * 2);
    
    CGRect barFrame = self.sliderBG.frame;
    barFrame.origin.x += 1;
    barFrame.origin.y += 1;
    barFrame.size.height -= 2;
    barFrame.size.width = barWidth - 2; // minus 2 for inset
    
    if (self.meterBar == nil) {
        self.meterBar = [[UIView alloc] initWithFrame:barFrame];
        self.meterBar.backgroundColor = sliderColor;
        
        [self setMaskTo:self.meterBar byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:barFrame.size.height / 2];
        
        [self addSubview:self.meterBar];
    } else {
        self.meterBar.frame = barFrame;
        [self setMaskTo:self.meterBar byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:barFrame.size.height / 2];
    }

    CGRect dotFrame = self.sliderBG.frame;
    dotFrame.size.height -= 4;
    dotFrame.size.width = dotFrame.size.height;
    dotFrame.origin.x = self.sliderBG.frame.origin.x + barFrame.size.width - dotFrame.size.width - 2;
    dotFrame.origin.y += 2;
    
    if (self.ratingDot == nil) {
        self.ratingDot = [[UIView alloc] initWithFrame:dotFrame];
        self.ratingDot.backgroundColor = dotColor;
        
        [self setMaskTo:self.ratingDot byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:dotFrame.size.height / 2];
        [self addSubview:self.ratingDot];
        
    } else {
        [self setMaskTo:self.ratingDot byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerTopRight|UIRectCornerBottomRight radius:dotFrame.size.height / 2];
        self.ratingDot.frame = dotFrame;
    }
    
}

- (void) setBGColor:(UIColor *)color {
    bgColor = color;
    self.sliderBG.backgroundColor = bgColor;
}
- (void) setSliderColor:(UIColor *)color {
    sliderColor = color;
}
- (void) setDotColor:(UIColor *)color {
    dotColor = color;
}

- (void) setRatingDot:(float)size color:(UIColor *)color {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// See: http://stackoverflow.com/questions/4847163/round-two-corners-in-uiview
-(void) setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners radius:(float)radius
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

@end
