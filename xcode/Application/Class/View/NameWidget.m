//
//  SelectedItemWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 10/3/13.
//
//

#import "NameWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

@implementation NameWidget

@synthesize nameLabel;


- (id)initWithFrame:(CGRect)frame {
    WidgetStyle *style = [[WidgetStyle alloc] init];
    
    style.fontcolor = 0xFFFFFF;
    style.bgcolor = 0x28CFEA;
    style.bordercolor = 0x09a1bd;
    style.corner = 2;
    style.font = [UIFont fontWithName:@"Raleway-Regular" size:13];
    
    return [self initWithFrame:frame andStyle:style];
    
}
- (id)initWithFrame:(CGRect)frame andStyle:(WidgetStyle *)style
{
    NSLog(@"%s", __FUNCTION__);
    theFont = style.font;
    bgColor = [UIColor colorWithHexValue:style.bgcolor andAlpha:1.0];
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:bgColor];
        [self.layer setBackgroundColor:bgColor.CGColor];
        
        [self.layer setBorderColor:[UIColor colorWithHexValue:style.bordercolor].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:style.corner];
        
        CGRect textFrame = CGRectMake(5, 5, 200, 15);
        self.nameLabel = [[UILabel alloc] initWithFrame:textFrame];
        [self.nameLabel setFont:theFont];
        self.nameLabel.textColor = [UIColor colorWithHexValue:style.fontcolor];
        
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.nameLabel];
        
    }
    
    return self;
}
- (void) setupButton:(NSString *)key {
    self.itemKey = key;
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearButton.frame = self.frame;
    self.clearButton.backgroundColor = [UIColor clearColor];
    
    [self.clearButton addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.clearButton];
    
}
- (void) setFieldLabel:(NSString *)label {
    
    //    self.borderStyle = UITextBorderStyleRoundedRect; // clear out default border
    self.nameLabel.text = label;
    
//    [self resizeLabel:self.nameLabel];
    
}
- (void) setIcon:(UIImage *)image {
    CGRect iconFrame = CGRectMake(self.frame.size.width - image.size.width - 5,
                                  (self.frame.size.height - image.size.height)/2,
                                  image.size.width,
                                  image.size.height);
    self.rightIcon = [[UIImageView alloc] initWithFrame:iconFrame];
    self.rightIcon.image = image;
    self.rightIcon.backgroundColor = [UIColor clearColor];
    [self addSubview:self.rightIcon];
    
}

- (void) handleTap:(id)sender {
    NSLog(@"Tap event %@", self.itemKey);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
