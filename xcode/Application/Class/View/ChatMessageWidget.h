//
//  ChatMessageWidget.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "BrandUILabel.h"
#import "ChatMessageVO.h"

@class PFImageView;

@interface ChatMessageWidget : UIView {
    UIView *_theView;
    NSMutableArray *options;
    UIFont *theFont;
}


- (id)initWithFrame:(CGRect)frame message:(ChatMessageVO *)msg isOwner:(BOOL)owner;

@property float dynamicHeight;

@property (nonatomic, strong) IBOutlet BrandUILabel *nameLabel;
@property (nonatomic, strong) IBOutlet BrandUILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UITextView *msgView;

@property (nonatomic, strong) IBOutlet UIImageView *rightCallout;
@property (nonatomic, strong) IBOutlet UIImageView *leftCallout;

@property (nonatomic, strong) PFImageView *photoView;

//@property (nonatomic, strong) IBOutlet UIImageView *calloutImage;

@end
