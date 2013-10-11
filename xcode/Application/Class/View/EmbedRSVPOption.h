//
//  EmbedRSVPOption.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "FancyTextView.h"
#import "BrandUILabel.h"

@interface EmbedRSVPOption : UIView {
    UIView *_theView;
    int _index;
}

@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *dateLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;
//@property (nonatomic, strong) IBOutlet FancyTextView *input;

- (void) resizeHeight:(float)height;

@end
