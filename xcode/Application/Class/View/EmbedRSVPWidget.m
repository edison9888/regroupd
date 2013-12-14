//
//  EmbedRSVPWidget.m
//  Re:group'd
//
//  Created by Hugh Lang on 9/25/13.
//
//

#import "EmbedRSVPWidget.h"
#import <EventKit/EventKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIColor+ColorWithHex.h"
#import "UIImage+Tint.h"
#import "FormOptionVO.h"

#define kInitialY   62
#define kEmbedOptionWidth   230
#define kEmbedOptionHeight  100
#define kTagOption1     101
#define kTagOption2     102
#define kTagOption3     103
#define kTagDone     199

#define kCheckboxOnImage    @"poll_checkbox_on"
#define kCheckboxOffImage   @"poll_checkbox"


@implementation EmbedRSVPWidget


- (id)initWithFrame:(CGRect)frame andOptions:(NSMutableArray *)formOptions andResponses:(NSMutableDictionary *)responseMap isOwner:(BOOL)owner
{
    NSLog(@"===== %s", __FUNCTION__);
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //        self.hotspot1.backgroundColor = [UIColor clearColor];
        //        self.hotspot2.backgroundColor = [UIColor clearColor];
        //        self.hotspot3.backgroundColor = [UIColor clearColor];
        
        _theView = [[[NSBundle mainBundle] loadNibNamed:@"EmbedRSVPWidget" owner:self options:nil] objectAtIndex:0];
        _theView.backgroundColor = [UIColor clearColor];
        
        _options = formOptions;
        _optionIndex = -1;
        [self.roundPic.layer setCornerRadius:36.0f];
        [self.roundPic.layer setMasksToBounds:YES];
        [self.roundPic.layer setBorderWidth:1.0f];
        [self.roundPic.layer setBorderColor:[UIColor whiteColor].CGColor];
        self.roundPic.clipsToBounds = YES;
        self.roundPic.contentMode = UIViewContentModeScaleAspectFill;
        
        float ypos = kInitialY;
        
        offFont = [UIFont fontWithName:@"Raleway-Regular" size:14];
        onFont = [UIFont fontWithName:@"Raleway-Bold" size:14];
        
        offCheckbox = [UIImage imageNamed:kCheckboxOffImage];
        onCheckbox = [UIImage imageNamed:kCheckboxOnImage];
        
        self.label1.font = offFont;
        self.label2.font = offFont;
        self.label3.font = offFont;

        if (owner) {
            
            self.doneButton.hidden = YES;
            self.leftCallout.hidden = YES;
            self.rightCallout.hidden = NO;
            //            [self.subjectLabel setTextColor:[UIColor whiteColor]];
            [self.subjectLabel setTextColor:[UIColor whiteColor]];
            
            [self.timeLabel setTextColor:[UIColor whiteColor]];
            [self.nameLabel setTextColor:[UIColor colorWithHexValue:0x28CFEA]];
            formLocked = YES;
            ypos = self.frame.size.height - 40;
        } else {
            formLocked = NO;
            self.rightCallout.hidden = YES;
            self.leftCallout.hidden = NO;
            
            UIColor *tintColor = [UIColor blackColor];
            offCheckbox = [offCheckbox tintedImageUsingColor:tintColor];
            onCheckbox = [onCheckbox tintedImageUsingColor:tintColor];
            
            self.checkbox1.image = offCheckbox;
            self.checkbox2.image = offCheckbox;
            self.checkbox3.image = offCheckbox;
            
            [self.label1 setTextColor:tintColor];
            [self.label2 setTextColor:tintColor];
            [self.label3 setTextColor:tintColor];
            [self.whatText setTextColor:tintColor];
            [self.whereText setTextColor:tintColor];
            
            [self.subjectLabel setTextColor:tintColor];
            
            [self.nameLabel setTextColor:[UIColor colorWithHexValue:0x0d7dac]];
            [self.timeLabel setTextColor:[UIColor blackColor]];
            ypos = self.frame.size.height;
        }
        self.dynamicHeight = self.lowerForm.frame.origin.y + self.lowerForm.frame.size.height + 10;
        
        
        if (responseMap != nil && responseMap.count > 0) {
            formLocked = YES;
            self.doneButton.enabled = NO;
            int index = 0;
            for (FormOptionVO *option in _options) {
                NSLog(@"Evaluate responseMap option %i -- value %@", index, option.name);
                FormResponseVO *myResponse = (FormResponseVO *) [responseMap objectForKey:option.system_id];
                if (myResponse != nil) {
                    if ([myResponse.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
                        if ([option.name isEqualToString:kResponseYes]) {
                            self.checkbox1.image = onCheckbox;
                            self.label1.font = onFont;
                            
                        } else if ([option.name isEqualToString:kResponseNo]) {
                            self.checkbox2.image = onCheckbox;
                            self.label2.font = onFont;

                        } else if ([option.name isEqualToString:kResponseMaybe]) {
                            self.checkbox3.image = onCheckbox;
                            self.label3.font = onFont;
                            
                        }
                    }
                    
                }
                index ++;
            }
            
            
            
            
        } else {
            self.label1.font = offFont;
            self.label2.font = offFont;
            self.label3.font = offFont;

        }
        
        [self addSubview:_theView];
        
        
        //        UIImage *detailsImage = [UIImage imageNamed:@"see_details"];
        //        CGRect detailsFrame = CGRectMake(self.headerView.frame.origin.x + 100, self.headerView.frame.origin.y + 70, 143, 41);
        //
        //        UIView *detailsView = [[UIView alloc] initWithFrame:detailsFrame];
        //        detailsView.backgroundColor = [UIColor orangeColor];
        
        //        UIButton *detailsButton;
        //        detailsButton = [[UIButton alloc] init];
        //        detailsButton.imageView.image = detailsImage;
        //
        //        detailsButton.frame = detailsFrame;
        //        [self addSubview:detailsView];
        
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    
    float hitY = locationPoint.y;
    float hitNum = (hitY - kInitialY) / kEmbedOptionHeight;
    NSLog(@"y = %f", hitNum);
    
    UIView* hitView = [self hitTest:locationPoint withEvent:event];
    NSLog(@"hitView.tag = %i", hitView.tag);
    if (!formLocked) {
        switch (hitView.tag) {
                
                
            case kTagOption1:
            {
                self.checkbox1.image = onCheckbox;
                self.label1.font = onFont;
                self.checkbox2.image = offCheckbox;
                self.label2.font = offFont;
                self.checkbox3.image = offCheckbox;
                self.label3.font = offFont;
                _optionIndex = 0;
                break;
            }
            case kTagOption2:
            {
                self.checkbox1.image = offCheckbox;
                self.label1.font = offFont;
                self.checkbox2.image = onCheckbox;
                self.label2.font = onFont;
                self.checkbox3.image = offCheckbox;
                self.label3.font = offFont;
                _optionIndex = 1;
                break;
            }
            case kTagOption3:
            {
                self.checkbox1.image = offCheckbox;
                self.label1.font = offFont;
                self.checkbox2.image = offCheckbox;
                self.label2.font = offFont;
                self.checkbox3.image = onCheckbox;
                self.label3.font = onFont;
                _optionIndex = 2;
                break;
            }
                
        }
    }
    
}
- (IBAction)tapDoneButton {
    
    if (!formLocked) {
        
        BOOL isOk = YES;
        if (_optionIndex < 0) {
            isOk = NO;
            return;
        }
        self.dynamicHeight -= self.doneButton.frame.size.height;
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
        
        FormOptionVO *selectedOption = [_options objectAtIndex:_optionIndex];
        
        NSLog(@"Select option key is %@", selectedOption.system_id);
        
        response = [[FormResponseVO alloc] init];
        response.contact_key = [DataModel shared].user.contact_key;
        response.form_key = self.form_key;
        response.chat_key = self.chat_key;
        response.option_key = selectedOption.system_id;
        
        index ++;
        [formSvc apiSaveFormResponse:response callback:^(PFObject *object) {
            

            if ([[NSUserDefaults standardUserDefaults] boolForKey:kSetting_Add_To_Calendar]) {
                if ([selectedOption.name isEqualToString:@"Yes"] || [selectedOption.name isEqualToString:@"Maybe"] ) {

                    NSLog(@"Saving event to user calendar");
                    EKEventStore *eventStore = [[EKEventStore alloc] init];
                    
                    

                    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
                    {
                        // iOS 6 and later
                        // This line asks user's permission to access his calendar
                        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
                         {
                             if (granted) // user user is ok with it
                             {
                                 EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                                 event.calendar  = [eventStore defaultCalendarForNewEvents];
                                 event.title     = self.form.name;
                                 event.location  = self.form.location;
                                 event.notes     = self.form.details;
                                 event.startDate = self.form.eventStartsAt;
                                 event.endDate   = self.form.eventEndsAt;
                                 event.allDay    = NO;
                                 NSError *err;
                                 
                                 [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                                 
                                 if(err)
                                     NSLog(@"unable to save event to the calendar!: Error= %@", err);
                                 
                             }
                         }];
                    }
                    
                    // iOS < 6
                    else
                    {
                        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                        event.calendar  = [eventStore defaultCalendarForNewEvents];
                        event.title     = self.form.name;
                        event.location  = self.form.location;
                        event.notes     = self.form.details;
                        event.startDate = self.form.eventStartsAt;
                        event.endDate   = self.form.eventEndsAt;
                        event.allDay    = NO;

                        NSError *err;
                        
                        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                        
                        if(err)
                            NSLog(@"unable to save event to the calendar!: Error= %@", err);
                        
                    }
                    
                }
            } else {
                // do nothing
            }

            [indicator stopAnimating];
            [indicator removeFromSuperview];
            if (object) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_formResponseEntered object:nil]];
            }
        }];
        
        
    } else {
        // Done button not enabled
    }
}
- (IBAction)tapDetailsButton {
    
    NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:k_showFormDetails object:self.form_key]];

}

@end
