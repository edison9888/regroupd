//
//  EmbedRatingOption.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "RatingMeterSlider.h"
#import "FancySlider.h"

@interface EmbedRatingOption : UIView {
    UIView *_theView;
    int _index;
    float _rating;
}

@property (nonatomic, retain) NSNumber *theRating;

@property (nonatomic, strong) NSString *optionKey;

@property (nonatomic, strong) IBOutlet UIView *sliderGuide;

@property (nonatomic, strong) IBOutlet PFImageView *roundPic;
@property (nonatomic, strong) IBOutlet UIImageView *divider;

@property (nonatomic, strong) IBOutlet BrandUILabel *fieldLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *ratingValue;
@property (nonatomic, strong) IBOutlet FancySlider *fancySlider;

-(IBAction)sliderValueChanged:(UISlider *)sender;

@property (nonatomic, retain) RatingMeterSlider *slider;

- (void) setIndex:(int)index;
- (void) setRating:(NSNumber *)value;

//- (float) getRating;

- (void) resizeHeight:(float)height;

@end
