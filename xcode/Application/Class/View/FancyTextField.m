//
//  FancyTextField
//

#import "FancyTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

@implementation FancyTextField

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

    defaultStyle = [[WidgetStyle alloc] init];
    defaultStyle.bgcolor = 0xFFFFFF;
    defaultStyle.bordercolor = 0x758188;
    defaultStyle.borderwidth = 1;

    self.isChanged = NO;
    [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:self.font.pointSize]];

    self.textColor = [UIColor colorWithHexValue:0x333333];
//    self.borderStyle = UITextBorderStyleRoundedRect; // clear out default border
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setBorderColor:[UIColor colorWithHexValue:defaultStyle.bordercolor].CGColor];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:5];
    
    return self;
}

// See: http://vodpodgeekblog.wordpress.com/2011/03/04/ios-trick-add-padding-to-a-uitextlabel/
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y + 4,
                      bounds.size.width - 10, bounds.size.height - 8);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}


- (void) setActiveStyle:(WidgetStyle *)widgetStyle {
    if (widgetStyle == nil) {
        widgetStyle = [[WidgetStyle alloc] init];
        widgetStyle.bgcolor = kHighlightLightBlueBG;
        widgetStyle.bordercolor = kHighlightAquaBorder;
        widgetStyle.borderwidth = 2;
    }
    
    self.backgroundColor = [UIColor colorWithHexValue:widgetStyle.bgcolor];
    self.layer.borderColor = [UIColor colorWithHexValue:widgetStyle.bordercolor].CGColor;
    self.layer.borderWidth = widgetStyle.borderwidth;
    
}
- (void) setDefaultStyle {
    self.backgroundColor = [UIColor colorWithHexValue:defaultStyle.bgcolor];
    self.layer.borderColor = [UIColor colorWithHexValue:defaultStyle.bordercolor].CGColor;
    self.layer.borderWidth = defaultStyle.borderwidth;
    
}


// SEE: https://coderwall.com/p/_kiqsq
//- (void)setPlaceholder:(NSString *)placeholder
//{
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{
//                                                        NSFontAttributeName: [UIFont fontWithName:@"Raleway-Regular" size:[self.font pointSize]],
//                                             NSForegroundColorAttributeName:  [UIColor grayColor]}];
//}
//
//- (void)setNeedsDisplayError:(BOOL)hasError
//{
//    UIColor* color = hasError ? [UIColor redColor] : [UIColor blackColor];
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.attributedPlaceholder.string attributes:@{
//                                                        NSFontAttributeName: [UIFont fontWithName:@"Raleway-Regular"
//                                                                                             size:[self.font pointSize]],
//                                             NSForegroundColorAttributeName: color}];
//}

//- (void) drawPlaceholderInRect:(CGRect)rect {
//    [[UIColor whiteColor] setFill];
////    [[self placeholder] t]
//    [[self placeholder] drawInRect:rect withFont:[UIFont fontWithName:@"Avenir-Medium" size:self.font.pointSize]];
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
