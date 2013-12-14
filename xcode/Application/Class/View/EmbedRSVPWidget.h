//
//  EmbedRSVPWidget.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "FormManager.h"
#import "FormResponseVO.h"

@interface EmbedRSVPWidget : UIView {
    
    FormManager *formSvc;
    
    UIView *_theView;
    NSMutableArray *_options;
    
    int _optionIndex;
    
    BOOL formLocked;
    UIFont *offFont;
    UIFont *onFont;
    UIImage *offCheckbox;
    UIImage *onCheckbox;
    
}


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions andResponses:(NSMutableDictionary *)responseMap isOwner:(BOOL)owner;

@property float dynamicHeight;

@property (nonatomic, retain) FormVO *form;

@property (nonatomic, retain) NSString *form_key;
@property (nonatomic, retain) NSString *chat_key;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet PFImageView *roundPic;

@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *eventDateLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *eventTimeLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *whatText;
@property (nonatomic, strong) IBOutlet BrandUILabel *whereText;

@property (nonatomic, strong) IBOutlet UIImageView *rightCallout;
@property (nonatomic, strong) IBOutlet UIImageView *leftCallout;

@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;


@property (nonatomic, strong) IBOutlet UIView *lowerForm;

@property (nonatomic, strong) IBOutlet UIView *hotspot1;
@property (nonatomic, strong) IBOutlet UIView *hotspot2;
@property (nonatomic, strong) IBOutlet UIView *hotspot3;

@property (nonatomic, strong) IBOutlet UIImageView *checkbox1;
@property (nonatomic, strong) IBOutlet UIImageView *checkbox2;
@property (nonatomic, strong) IBOutlet UIImageView *checkbox3;
@property (nonatomic, strong) IBOutlet BrandUILabel *label1;
@property (nonatomic, strong) IBOutlet BrandUILabel *label2;
@property (nonatomic, strong) IBOutlet BrandUILabel *label3;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;




- (IBAction)tapDoneButton;
- (IBAction)tapDetailsButton;


@end
