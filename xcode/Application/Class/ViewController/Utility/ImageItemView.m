//
//  ImageViewTemplate.m
//

#import "ImageItemView.h"

@implementation ImageItemView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame andProduct:(Product *)product {
#ifdef kDEBUG
   // NSLog(@"%s", __FUNCTION__);
#endif
    if ((self = [super initWithFrame: frame])) {
        [self setProduct:product];
        
        ProductPhoto *defaultPhoto = (ProductPhoto *) [self.product.images objectAtIndex:0];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        // https://github.com/rs/SDWebImage
        NSLog(@"display image from url: %@", defaultPhoto.mediumURL);
//        self.imageView.image = [UIImage imageWithData:
//                                [NSData dataWithContentsOfURL:
//                                 [NSURL URLWithString:
//                                  defaultPhoto.mediumURL]]];
        [self.imageView setOpaque:YES];
        self.imageView.backgroundColor = [UIColor blackColor];
        [self.imageView setImageWithURL:[NSURL URLWithString:defaultPhoto.mediumURL]];

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
