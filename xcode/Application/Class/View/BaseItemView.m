//
//  ViewTemplate.m
//

#import "BaseItemView.h"


@implementation BaseItemView

@synthesize data;
@synthesize isInScrollWindow;

- (id)initWithFrame:(CGRect)frame andData:(NSDictionary *)pageData {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		isInScrollWindow = NO;
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andView:(UIView *)embedView {
    
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
//		isInScrollWindow = NO;
//        subview = embedView;
//        subview.frame = self.bounds;
//        [self addSubview:subview];
    }
    return self;
}

- (void)willFocus {
}

- (void)willBlur {
}

- (void)willRemoveFromSuperview {
}

- (void)swapViews {
}

- (void)dealloc {
}

@end
