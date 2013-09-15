//
//  FaxTemplateView.h
//  NView-iphone
//
//  Created by Hugh Lang on 7/15/13.
//
//

#import <UIKit/UIKit.h>

@interface FaxTemplateView : UIView {
    UIView *_theView;
}

@property (nonatomic, retain) IBOutlet UILabel *rcptName;
@property (nonatomic, retain) IBOutlet UILabel *rcptPhone;
@property (nonatomic, retain) IBOutlet UILabel *rcptFax;

@property (nonatomic, retain) IBOutlet UILabel *senderName;
@property (nonatomic, retain) IBOutlet UILabel *senderPhone;
@property (nonatomic, retain) IBOutlet UILabel *senderFax;

@property (nonatomic, retain) IBOutlet UILabel *company;
@property (nonatomic, retain) IBOutlet UILabel *street;
@property (nonatomic, retain) IBOutlet UILabel *city;
@property (nonatomic, retain) IBOutlet UILabel *state;
@property (nonatomic, retain) IBOutlet UILabel *zip;

@property (nonatomic, retain) IBOutlet UILabel *patient;

@property (nonatomic, retain) IBOutlet UILabel *orderDate;
@property (nonatomic, retain) IBOutlet UITextView *orderText;

@property (nonatomic, retain) IBOutlet UIImageView *signatureBox;






@end
