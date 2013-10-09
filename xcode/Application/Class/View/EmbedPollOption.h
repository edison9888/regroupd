//
//  EmbedPollOption.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "FancyTextView.h"
#import "BrandUILabel.h"

@interface EmbedPollOption : UIView {
    UIView *_theView;
    int _index;
}

@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet UIImageView *checkbox;
@property (nonatomic, strong) IBOutlet UIImageView *divider;

@property (nonatomic, strong) IBOutlet UIView *inputHolder;
@property (nonatomic, strong) IBOutlet BrandUILabel *fieldLabel;
//@property (nonatomic, strong) IBOutlet FancyTextView *input;

- (void) setIndex:(int)index;

- (void) selected;
- (void) unselected;

- (void) resizeHeight:(float)height;

@end
