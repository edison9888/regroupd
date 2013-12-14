//
//  SurveyOptionWidget.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "FancyTextView.h"
#import "BrandUILabel.h"

@interface SurveyOptionWidget : UIView<UITextViewDelegate> {
    UIView *_theView;
    
}

@property int index;
@property (nonatomic, strong) IBOutlet UIView *photoHolder;
@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet UIButton *pickPhoto;

@property (nonatomic, strong) IBOutlet UIView *inputHolder;
@property (nonatomic, strong) IBOutlet BrandUILabel *fieldLabel;
@property (nonatomic, strong) IBOutlet FancyTextView *input;


- (IBAction)tapPickPhoto;

- (void) setPhoto:(UIImage *)photo;
- (void) resizeHeight:(float)height;

@end
