//
//  FormOptionCheckbox.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "FancyToggle.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

#define kLeftPositionY  2
#define kRightPositionY 50
#define kOnColor    0x28cfea
#define kOffColor   0x1788b2

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
        
        [self.layer setCornerRadius:3.0f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.0f];
//        [self.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [self addSubview:_theView];
        
        bgColorSelected = _theView.backgroundColor.colorCode;
        [self selected];

    }
    
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    
    
}

- (void) toggle {
    if (self.isOn) {
        [self unselected];
    } else {
        [self selected];
    }
}


- (void) selected {
    self.isOn = YES;
    
    _theView.backgroundColor = [UIColor colorWithHexValue:kOnColor];
//    self.layer.backgroundColor = [UIColor colorWithHexValue:kOnColor].CGColor;
    self.offIcon.hidden = YES;
    self.onIcon.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{

        CGRect switchFrame = self.switchIcon.frame;
        switchFrame.origin.x = kLeftPositionY;
        self.switchIcon.frame = switchFrame;
    }];
    
}
- (void) unselected {
    self.isOn = NO;
    
    _theView.backgroundColor = [UIColor colorWithHexValue:kOffColor];
//    self.layer.backgroundColor = [UIColor colorWithHexValue:kOffColor].CGColor;
    self.offIcon.hidden = NO;
    self.onIcon.hidden = YES;

    [UIView animateWithDuration:0.1f animations:^{
        
        CGRect switchFrame = self.switchIcon.frame;
        switchFrame.origin.x = kRightPositionY;
        self.switchIcon.frame = switchFrame;
    }];
}


@end
