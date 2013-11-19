//
//  EmbedRatingWidget.h
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "EmbedRatingOption.h"

@interface EmbedRatingWidget : UIView {
    UIView *_theView;
    NSMutableArray *options;
    BOOL formLocked;
}


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions isOwner:(BOOL)owner;

@property float dynamicHeight;

@property (nonatomic, strong) IBOutlet BrandUILabel *typeLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *subjectLabel;

@property (nonatomic, strong) IBOutlet UIView *doneView;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) IBOutlet UIImageView *rightCallout;
@property (nonatomic, strong) IBOutlet UIImageView *leftCallout;

@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;


@property (nonatomic, strong) IBOutlet UIView *inputHolder;

- (IBAction)tapDoneButton;


@end
