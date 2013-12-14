//
//  SurveyOptionWithPic.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "IndentedTextField.h"
#import "BrandUILabel.h"

@interface SurveyOptionWithPic : UIView<UITextFieldDelegate> {
    UIView *_theView;
    
}

@property int index;
@property (nonatomic, strong) IBOutlet IndentedTextField *input;
@property (nonatomic, strong) IBOutlet UIView *photoHolder;
@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet UIButton *pickPhoto;
@property (nonatomic, strong) IBOutlet BrandUILabel *fieldLabel;


- (IBAction)tapPickPhoto;

- (void) setPhoto:(UIImage *)photo;

@end
