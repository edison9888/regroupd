//
//  FormOptionCheckbox.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "FancyToggle.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

#define kCheckboxOff @"poll_checkbox"
#define kCheckboxOn @"poll_checkbox_on"

@implementation FancyToggle

- (id)init {
    if ((self = [super init])) {
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"FancyToggle" owner:self options:nil] objectAtIndex:0];
        [self addSubview:_theView];
                
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ((self = [super init])) {
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"FancyToggle" owner:self options:nil] objectAtIndex:0];
        
        [self.layer setCornerRadius:5.0f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.0f];
//        [self.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [self addSubview:_theView];
        
        bgColorSelected = _theView.backgroundColor.colorCode;

        onImage = [UIImage imageNamed:kCheckboxOn];
        offImage = [UIImage imageNamed:kCheckboxOff];
    }
    
    return self;
}

- (void) selected {
//    self.backgroundColor = [UIColor colorWithHexValue:bgColorSelected andAlpha:1.0];
    _theView.backgroundColor = [UIColor colorWithHexValue:bgColorSelected andAlpha:1.0];
    self.layer.backgroundColor = [UIColor colorWithHexValue:bgColorSelected andAlpha:1.0].CGColor;

    self.ckIcon.image = onImage;
}
- (void) unselected {
    NSLog(@"%s", __FUNCTION__);
    _theView.backgroundColor = [UIColor clearColor];
    self.layer.backgroundColor = [UIColor clearColor].CGColor;

    self.ckIcon.image = offImage;

}

- (void)setTag:(NSInteger)theTag
{
    NSLog(@"set tag=%i", theTag);
//    [super setTag:theTag];
    _theView.tag = theTag;
}


@end
