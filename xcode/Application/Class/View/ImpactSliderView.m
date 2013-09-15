//
//  ImpactSlider.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImpactSliderView.h"

@implementation ImpactSliderView

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
       //self.thumbTintColor = [UIColor colorWithRed:0.969 green:0.58 blue:0.114 alpha:1.0];
        
        UIImage *thumbImage = [UIImage imageNamed:@"slideImpact_slider_thumb"];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        _thumbSize = thumbImage.size;
        
        UIImage *minTrackImage = [[UIImage imageNamed:@"slideImpact_slider_track"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];        
        [self setMinimumTrackImage:minTrackImage forState:UIControlStateNormal];
         _trackHeight = minTrackImage.size.height;
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x, bounds.origin.y, self.bounds.size.width, _trackHeight);
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, 0, -50.0);
    return CGRectContainsPoint(bounds, point);
}

@end
