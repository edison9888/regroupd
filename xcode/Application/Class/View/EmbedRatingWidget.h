//
//  EmbedRatingWidget.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "EmbedRatingOption.h"
#import "FormManager.h"
#import "FormVO.h"
#import "RatingMeterSlider.h"
#import "FancySlider.h"

@interface EmbedRatingWidget : UIView {
    UIView *_theView;
    NSMutableArray *optionViews;
    BOOL formLocked;
    FormManager *formSvc;
}

- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions andResponses:(NSMutableDictionary *)responseMap isOwner:(BOOL)owner;


@property (nonatomic, retain) NSString *form_key;
@property (nonatomic, retain) NSString *chat_key;

@property float dynamicHeight;

@property (nonatomic, strong) IBOutlet BrandUILabel *typeLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;

@property (nonatomic, strong) IBOutlet UIView *doneView;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIView *seeDetailsView;

@property (nonatomic, strong) IBOutlet UIImageView *rightCallout;
@property (nonatomic, strong) IBOutlet UIImageView *leftCallout;

@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;

@property (nonatomic, strong) IBOutlet UIView *inputHolder;

//@property (nonatomic, strong) IBOutlet FancySlider *fancySlider1;
////@property (nonatomic, strong) IBOutlet FancySlider *fancySlider2;
//@property (nonatomic, strong) FancySlider *fancySlider3;


- (IBAction)tapDoneButton;
- (IBAction)tapDetailsButton;

@end
