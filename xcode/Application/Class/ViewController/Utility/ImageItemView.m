//
//  ImageViewTemplate.m
//

#import "ImageItemView.h"

@implementation ImageItemView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame andPage:(Page *)page {
#ifdef kDEBUG
   // NSLog(@"%s", __FUNCTION__);
#endif
    if ((self = [super initWithFrame: frame])) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        [self.imageView setOpaque:YES];
        self.imageView.backgroundColor = [UIColor blackColor];
//        [self.imageView setImageWithURL:[NSURL URLWithString:defaultPhoto.mediumURL]];

        [self addSubview:self.imageView];
        
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame andView:(UIView *)embedView {
    
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		isInScrollWindow = NO;
        subview = embedView;
        subview.frame = self.bounds;
        [self addSubview:subview];
    }
    return self;
}


#pragma mark hooks

- (void)swapViews {
}
- (void)dealloc {
}

@end
