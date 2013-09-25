//
//  SurveyOptionWithPic.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "FancyTextField.h"
#import "BrandUILabel.h"

@interface SurveyOptionWithPic : UIView {
    UIView *_theView;
    
}

@property (nonatomic, strong) IBOutlet FancyTextField *input;
@property (nonatomic, strong) IBOutlet UIView *photoHolder;
@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet UIButton *pickPhoto;
@property (nonatomic, strong) IBOutlet BrandUILabel *fieldLabel;


- (IBAction)tapPickPhoto;


@end
