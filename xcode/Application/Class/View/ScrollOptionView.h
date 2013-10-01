//
//  ScrollOptionView.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "FancyTextField.h"
#import "BrandUILabel.h"
#import "BaseItemView.h"

@interface ScrollOptionView : BaseItemView {
    UIView *_theView;
}

- (id)initWithFrame:(CGRect)frame andData:(NSDictionary *)data;

@property int index;
@property (nonatomic, strong) IBOutlet UIImageView *roundPic;

@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *optionLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *counterLabel;


- (void) setPhoto:(UIImage *)photo;

@end
