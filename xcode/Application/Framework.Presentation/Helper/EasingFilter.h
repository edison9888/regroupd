//
//  EasingFilter.h
//  Incivek
//
//

#import <Foundation/Foundation.h>

//typedef enum {
//    EasingTypeLinear,
//    EasingType
//    
//} EasingFilterType;


@interface EasingFilter : NSObject {
    
}

+ (CGFloat)easeIn:(CGFloat)uVal;
+ (CGFloat)easeOut:(CGFloat)uVal;
+ (CGFloat)easeInOut:(CGFloat)uVal;


@end
