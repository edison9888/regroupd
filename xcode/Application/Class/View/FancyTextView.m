//
//
//
#import "FancyTextView.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

#define kLeftIndent 30

@implementation FancyTextView


- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        defaultStyle = [[WidgetStyle alloc] init];
        defaultStyle.bgcolor = 0xFFFFFF;
        defaultStyle.bordercolor = 0x758188;
        defaultStyle.borderwidth = 1;

        self.clipsToBounds = YES;
        [self setTextColor:[UIColor colorWithHexValue:0x333333 andAlpha:1.0]];
        theFont = [UIFont fontWithName:@"Raleway-Regular" size:13];
        
        [self setFont:theFont];
        [self setTextAlignment:NSTextAlignmentLeft];
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:1.0];
        [self.layer setCornerRadius:5];
        [self setScrollEnabled:NO];

        [self setContentInset:UIEdgeInsetsMake(0.0, 25.0, 0.0, -25.0)];

    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    defaultStyle = [[WidgetStyle alloc] init];
    defaultStyle.bgcolor = 0xFFFFFF;
    defaultStyle.bordercolor = 0x758188;
    defaultStyle.borderwidth = 1;

    self.backgroundColor = [UIColor whiteColor];
    
    self.clipsToBounds = YES;
    [self setTextColor:[UIColor colorWithHexValue:0x333333 andAlpha:1.0]];
    [self setFont:[UIFont fontWithName:@"Raleway-Regular" size:13]];
    [self setTextAlignment:NSTextAlignmentLeft];
    [self.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.layer setBorderWidth:1.0];
    [self.layer setCornerRadius:5];
    [self setScrollEnabled:NO];
    
    [self setContentInset:UIEdgeInsetsMake(0.0, 25.0, 0.0, -25.0)];
    
    return self;
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

-(void)setNumLabel:(NSString*)num {
    __numLabel.text = num;    
}

-(void)setPlaceholder:(NSString*)placeholder
{
    showPlaceholder = YES;
    self.defaultText = placeholder;
    self.text = placeholder;
    self.textColor = [UIColor grayColor];
}

-(void)unsetPlaceholder:(NSString*)placeholder {
    self.textColor = [UIColor blackColor];
    
}

//http://stackoverflow.com/questions/19028743/ios7-uitextview-contentsize-height-alternative


- (CGSize)determineSize:(NSString *)text constrainedToSize:(CGSize)size
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:theFont}
                                          context:nil];
        return frame.size;
    } else {
        return [text sizeWithFont:theFont constrainedToSize:size];
    }
}
@end
