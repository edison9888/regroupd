//
//  FancyDateTimeField.h
//  Regroupd
//
//  Created by Hugh Lang on 9/27/13.
//
//

#import <UIKit/UIKit.h>

@interface FancyDateTimeField : UITextField {
    UIImageView *__leftView;
    
}

@property (nonatomic, retain) NSString* defaultText;
@property BOOL isChanged;

- (void) setIcon:(UIImage *)image;


@end
