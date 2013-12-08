//
//  FancyDateTimeField.h
//  Regroupd
//
//  Created by Hugh Lang on 9/27/13.
//
//

#import <UIKit/UIKit.h>
#import "FancyTextField.h"


// Highlight light blue:  0xc4f5fd

@interface FancyDateTimeField : FancyTextField {
    UIImageView *__leftView;
    
}

@property (nonatomic, retain) NSString* defaultText;
@property BOOL isChanged;

- (void) setIcon:(UIImage *)image;



@end
