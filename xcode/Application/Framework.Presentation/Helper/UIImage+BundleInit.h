//
//  UIImage+BundleInit.h
//  Presentation Framework
//
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImage_BundleInit)

- (id)initWithBundlePath:(NSString *)path;

+ (id)imageWithBundlePath:(NSString *)path;

@end
