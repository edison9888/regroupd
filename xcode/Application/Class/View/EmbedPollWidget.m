//
//  EmbedPollWidget.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedPollWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "FormOptionVO.h"
#import "ChatFormVO.h"
#import "FormResponseVO.h"
#import "UIColor+ColorWithHex.h"

#define kInitialY   67
#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  80
#define kDetailsBackFoldWidth   9


@implementation EmbedPollWidget


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions andResponses:(NSMutableDictionary *)responseMap isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
    
    if (self) {
        self.optionKeys = [[NSMutableArray alloc] init];
        
        _optionViews = [[NSMutableArray alloc] initWithCapacity:formOptions.count];
        self.allowMultiple = NO;
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedPollWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        self.doneButton.enabled = NO;
        self.optionIndex = -1;
        
        float xpos = 0;
        float ypos = kInitialY;
        EmbedPollOption *embedOption = nil;
        CGRect itemFrame;
        int index=0;
        
        
        for (FormOptionVO* opt in formOptions) {
            index++;
            itemFrame = CGRectMake(xpos, ypos, kEmbedOptionWidth, kEmbedOptionHeight);
            embedOption = [[EmbedPollOption alloc] initWithFrame:itemFrame];
            embedOption.optionKey = opt.system_id;
            
            [embedOption setIndex:index];
            embedOption.tag = k_CHAT_OPTION_BASETAG + index;
            embedOption.userInteractionEnabled = YES;
            embedOption.roundPic.image = [DataModel shared].defaultImage;

            if (opt.pfPhoto != nil) {
                embedOption.roundPic.file = opt.pfPhoto;
                [embedOption.roundPic loadInBackground];
            }

            embedOption.fieldLabel.text = opt.name;
            
            if (index == formOptions.count) {
                embedOption.divider.hidden = YES;
                ypos += kEmbedOptionHeight;
                
            } else {
                ypos += kEmbedOptionHeight;
            }
            
            if ([responseMap objectForKey:opt.system_id] != nil) {
                [embedOption selected];
            } else {
                [embedOption unselected];
            }
            
            [self addSubview:embedOption];
            [_optionViews addObject:embedOption];
            
        }
        if (owner) {
            self.doneButton.hidden = YES;
            self.leftCallout.hidden = YES;
            self.rightCallout.hidden = NO;
            [self.subjectLabel setTextColor:[UIColor whiteColor]];
            [self.timeLabel setTextColor:[UIColor whiteColor]];
            [self.nameLabel setTextColor:[UIColor colorWithHexValue:0x28CFEA]];
            formLocked = YES;
        } else {
            formLocked = NO;
            self.rightCallout.hidden = YES;
            self.leftCallout.hidden = NO;
            [self.subjectLabel setTextColor:[UIColor blackColor]];
            [self.nameLabel setTextColor:[UIColor colorWithHexValue:0x0d7dac]];
            [self.timeLabel setTextColor:[UIColor blackColor]];
            
            itemFrame = self.doneView.frame;
            itemFrame.origin.y = ypos;
            self.doneView.frame = itemFrame;
            ypos += self.doneView.frame.size.height;
        }
        
        if (responseMap != nil && responseMap.count > 0) {
            formLocked = YES;
            
        }

        
        self.dynamicHeight = ypos + 10;
        
        [self addSubview:_theView];
        
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    [super touchesBegan:touches withEvent:event];
//    [self.nextResponder touchesBegan:touches withEvent:event];
    CGPoint locationPoint = [[touches anyObject] locationInView:self];

    float hitX = locationPoint.x;
    float hitY = locationPoint.y;
    float hitNum = (hitY - kInitialY) / kEmbedOptionHeight;
    CGRect detailsFrame = self.seeDetailsView.frame;

    NSLog(@"hit point = %f / %f", hitX, hitY);

    
    if (hitNum > 0 && hitNum < _optionViews.count) {
        if (!formLocked) {
            self.doneButton.enabled = YES;
            
            self.optionIndex = ((int) hitNum);
            NSLog(@"option index = %i", self.optionIndex);
            ((FormOptionVO *)[_optionViews objectAtIndex:self.optionIndex]).isSelected = YES;
            
            if (self.allowMultiple) {
                int i = 0;
                for (EmbedPollOption* opt in _optionViews) {
                    if (i == self.optionIndex) {
                        if (![self.optionKeys containsObject:opt.optionKey]) {
                            [self.optionKeys addObject:opt.optionKey];
                        }
                        [opt selected];
                    } else {
                        [opt unselected];
                    }
                    i++;
                }
                
                
            } else {
                int i = 0;
                [self.optionKeys removeAllObjects];
                for (EmbedPollOption* opt in _optionViews) {
                    if (i == self.optionIndex) {
                        [self.optionKeys addObject:opt.optionKey];
                        [opt selected];
                    } else {
                        [opt unselected];
                    }
                    i++;
                }
                
            }
        }
    } else if (hitY >= detailsFrame.origin.y && hitY <= detailsFrame.origin.y + detailsFrame.size.height
               && hitX >= detailsFrame.origin.x && hitX <= detailsFrame.origin.x + detailsFrame.size.width) {
//        [DataModel shared].form = self.theForm;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_showFormDetails object:self.form_key]];

        
        
    } else if (hitY >= self.doneView.frame.origin.y && hitY <= self.doneView.frame.origin.y + self.doneView.frame.size.height) {
        if (!formLocked) {
            NSLog(@"Hit done button at hitY %f", hitY);
            self.doneButton.enabled = NO;
            formLocked = YES;
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            CGFloat halfButtonHeight = self.doneButton.bounds.size.height / 2;
            CGFloat buttonWidth = self.doneButton.bounds.size.width;
            indicator.center = CGPointMake(buttonWidth - halfButtonHeight , halfButtonHeight);
            [self.doneButton addSubview:indicator];
            [indicator startAnimating];
            
            
            if (formSvc == nil) {
                formSvc = [[FormManager alloc] init];
            }
            
            FormResponseVO *response;
            int index = 0;
            int total = self.optionKeys.count;
            
            for (NSString *key in self.optionKeys) {
                response = [[FormResponseVO alloc] init];
                response.contact_key = [DataModel shared].user.contact_key;
                response.form_key = self.form_key;
                response.chat_key = self.chat_key;
                response.option_key = key;
                
                index ++;
                [formSvc apiSaveFormResponse:response callback:^(PFObject *object) {
                    if (index == total) {
                        [indicator stopAnimating];
                        [indicator removeFromSuperview];
                        if (object) {
                            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_formResponseEntered object:nil]];
                        }
                    }
                }];
                
            } // end for loop
            
        } // !formLocked
        
        
    } // doneView hit test

}
- (IBAction)tapDoneButton {
    NSLog(@"%s", __FUNCTION__);
    self.dynamicHeight -= self.doneButton.frame.size.height;
    self.doneButton.enabled = NO;
    formLocked = YES;
}

- (IBAction)tapDetailsButton {
    
    NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_showFormDetails object:self.form_key]];
    
}

@end
