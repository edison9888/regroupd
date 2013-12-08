//
//  FancyTextField
//
//

#import "WidgetStyle.h"

#define kHighlightLightBlueBG    0xc4f5fd
#define kHighlightAquaBorder    0x28cfea

@interface FancyTextField : UITextField {
    WidgetStyle *defaultStyle;
}

@property (nonatomic, retain) NSString* defaultText;
@property BOOL isChanged;


- (void) setActiveStyle:(WidgetStyle *)widgetStyle;
- (void) setDefaultStyle;


@end
