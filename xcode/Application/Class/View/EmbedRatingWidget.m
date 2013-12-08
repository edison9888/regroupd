//
//  EmbedRatingWidget.m
//  Regroupd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRatingWidget.h"
#import <QuartzCore/QuartzCore.h>
#import "FormOptionVO.h"
#import "FormManager.h"
#import "UIColor+ColorWithHex.h"

#define kInitialY   67
#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  90

#define kSliderRelativeOriginX  78
#define kSliderRelativeOriginY  60
#define kSliderWidth    144
#define kSliderHeight   14
#define kSliderMargin   10


@implementation EmbedRatingWidget


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions andResponses:(NSMutableDictionary *)responseMap isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
    //
    //- (id)initWithOptions:(NSMutableArray *)formOptions
    //{
    //    NSLog(@"===== %s", __FUNCTION__);
    //   self = [super init];
    if (self) {
        optionViews = [[NSMutableArray alloc] initWithCapacity:formOptions.count];
        if (responseMap != nil && responseMap.count > 0) {
            formLocked = YES;
            
        }
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRatingWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        float xpos = 0;
        float ypos = kInitialY;
        EmbedRatingOption *embedOption = nil;
        CGRect itemFrame;
        int index=0;
        formSvc = [[FormManager alloc]init];
        
        for (FormOptionVO* opt in formOptions) {
            index++;
            itemFrame = CGRectMake(xpos, ypos, kEmbedOptionWidth, kEmbedOptionHeight);
            embedOption = [[EmbedRatingOption alloc] initWithFrame:itemFrame];
            embedOption.optionKey = opt.system_id;
            [embedOption setIndex:index];
            embedOption.tag = k_CHAT_OPTION_BASETAG + index;
            embedOption.userInteractionEnabled = YES;
            
            embedOption.fieldLabel.text = opt.name;
            
            if (opt.pfPhoto != nil) {
                embedOption.roundPic.file = opt.pfPhoto;
                [embedOption.roundPic loadInBackground];
            } else if (opt.imagefile != nil) {
                UIImage *img = nil;
                img = [formSvc loadFormImage:opt.imagefile];
                embedOption.roundPic.image =img;
            }
            
            if (index == formOptions.count) {
                embedOption.divider.hidden = YES;
                ypos += kEmbedOptionHeight;
                
            } else {
                ypos += kEmbedOptionHeight;
            }
            FormResponseVO *response;
            /*
             Check responseMap for matching optionkey.
             If owner, this data is aggregated stats
             If not, this is the user's data
             */
            if ([responseMap objectForKey:opt.system_id] != nil) {
                response = [responseMap objectForKey:opt.system_id];
                
                if (owner) {
                    
                    if (response.ratingTotal && response.ratingCount) {
                        NSNumber *avgRating = [NSNumber numberWithFloat:(response.ratingTotal.floatValue / response.ratingCount.floatValue )];
                        [embedOption setRating:avgRating.floatValue];
                    } else {
                        NSLog(@"Missing rating total and count data");
                    }
                    
                } else {
                    if (response.rating) {
                        [embedOption setRating:response.rating.floatValue];
                    } else {
                        NSLog(@"no rating data!!!!");
                    }
                }
            }
            
            if (!owner) {
                [embedOption.slider setBGColor:[UIColor lightGrayColor]];
            }
            
            [self addSubview:embedOption];
            [optionViews addObject:embedOption];
            
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
            self.doneButton.enabled = NO;
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
    
    float hitY = locationPoint.y;
    float hitX = locationPoint.x;
    float yOffset = kInitialY;
    
    // Offset by inital Y
    //    hitY = (hitY - kInitialY);
    
    NSLog(@"hit point = %f / %f", hitX, hitY);
    
    float leftEdge = kSliderRelativeOriginX - 2;
    float rightEdge = kSliderRelativeOriginX + kSliderWidth + 2;
    
    float topEdge = 0;
    float bottomEdge = 0;
    CGRect detailsFrame = self.seeDetailsView.frame;
    
    NSLog(@"Done button range = %f to %f", self.doneView.frame.origin.y, self.doneView.frame.origin.y + self.doneView.frame.size.height);
    if (hitY >= kInitialY && hitY <= self.doneView.frame.origin.y - 20) {
        if (hitX >= leftEdge && hitX <= rightEdge) {
            if (!formLocked) {
                int i=0;
                
                for (EmbedRatingOption* opt in optionViews) {
                    topEdge = yOffset + kSliderRelativeOriginY - kSliderMargin;
                    bottomEdge = yOffset + kSliderRelativeOriginY + kSliderHeight + kSliderMargin;
                    
                    //            NSLog(@"hit zone with left %f, top %f, right %f, bottom %f", leftEdge, topEdge, rightEdge, bottomEdge);
                    
                    if (hitY >= topEdge && hitY <= bottomEdge) {
                        
                        float hitPercent = (hitX - leftEdge) / (rightEdge - leftEdge);
                        NSLog(@"hit success at %f / %f with est. percent %f", hitX, hitY, hitPercent);
                        
                        int ratingNumber = [NSNumber numberWithFloat:(hitPercent * 10)].intValue;
                        [opt setRating:(float) ratingNumber];
                        
                    }
                    yOffset += kEmbedOptionHeight;
                    i++;
                }
            }
            
        }
    } else if (hitY >= detailsFrame.origin.y && hitY <= detailsFrame.origin.y + detailsFrame.size.height
               && hitX >= detailsFrame.origin.x && hitX <= detailsFrame.origin.x + detailsFrame.size.width) {
        
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
            int total = optionViews.count;
            for (EmbedRatingOption *optionView in optionViews) {
                response = [[FormResponseVO alloc] init];
                response.contact_key = [DataModel shared].user.contact_key;
                response.form_key = self.form_key;
                response.chat_key = self.chat_key;
                response.option_key = optionView.optionKey;
                response.rating = [NSNumber numberWithFloat:[optionView getRating]];
                
                NSLog(@"Ready to save option_key %@ with rating %@", response.option_key, optionView.ratingValue.text);
                
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
                
            }
            
        } else {
            // Done button not enabled
        }
        
    } else {
        NSLog(@"No hit");
    }
    
    //    } else {
    //        // Form locked
    //        NSLog(@"Form locked");
    //    }
    
}
- (IBAction)tapDoneButton {
    NSLog(@"%s", __FUNCTION__);
    self.dynamicHeight -= self.doneButton.frame.size.height;
    self.doneButton.enabled = NO;
    formLocked = YES;
}
@end
