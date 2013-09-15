//
//  UIImage+BundleInit.m
//  Presentation Framework
//
//

#import "UIImage+BundleInit.h"


@implementation UIImage (UIImage_BundleInit)

- (id)initWithBundlePath:(NSString *)path {
	NSString *imagePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:path];
    return [self initWithContentsOfFile:imagePath];
}

+ (id)imageWithBundlePath:(NSString *)path {
    return [[UIImage alloc] initWithBundlePath:path];
}

@end
