//
//  EmbedRSVPWidget.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "EmbedRSVPOption.h"

@interface EmbedRSVPWidget : UIView {
    UIView *_theView;
    NSMutableArray *options;
    BOOL formLocked;
}


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions isOwner:(BOOL)owner;

@property float dynamicHeight;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIImageView *roundPic;
@property (nonatomic, strong) IBOutlet BrandUILabel *dateLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;


@property (nonatomic, strong) IBOutlet UIView *lowerForm;
@property (nonatomic, strong) IBOutlet UIImageView *checkbox1;
@property (nonatomic, strong) IBOutlet UIImageView *checkbox2;
@property (nonatomic, strong) IBOutlet UIImageView *checkbox3;
@property (nonatomic, strong) IBOutlet BrandUILabel *label1;
@property (nonatomic, strong) IBOutlet BrandUILabel *label2;
@property (nonatomic, strong) IBOutlet BrandUILabel *label3;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) IBOutlet BrandUILabel *whatText;
@property (nonatomic, strong) IBOutlet BrandUILabel *whereText;



- (IBAction)tapDoneButton;


@end
