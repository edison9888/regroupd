//
//  IndentedTextField
//
//

#import "WidgetStyle.h"
#import "FancyTextField.h"

#define kHighlightLightBlueBG    0xc4f5fd
#define kHighlightAquaBorder    0x28cfea

@interface IndentedTextField : UITextField {
    WidgetStyle *defaultStyle;
}

@property (nonatomic, retain) NSString* defaultText;
@property BOOL isChanged;

- (void) setFieldLabel:(NSString *)label;

- (void) setActiveStyle:(WidgetStyle *)widgetStyle;
- (void) setDefaultStyle;


@end
