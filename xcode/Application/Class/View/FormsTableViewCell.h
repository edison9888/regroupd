//
//  FormsTableViewCell.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>
#import "FormVO.h"
#import "BrandUILabel.h"

@interface FormsTableViewCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet UIImageView *iconType;
@property (nonatomic, retain) IBOutlet BrandUILabel *titleField;
@property (nonatomic, retain) IBOutlet BrandUILabel *dateField;
@property (nonatomic, retain) IBOutlet BrandUILabel *responsesField;
@property (nonatomic, retain) IBOutlet BrandUILabel *whenField;
@property (nonatomic, retain) IBOutlet BrandUILabel *whereField;
@property (nonatomic, retain) IBOutlet BrandUILabel *whenLabel;
@property (nonatomic, retain) IBOutlet BrandUILabel *whereLabel;

@property (nonatomic, retain) IBOutlet UIButton *sendArrow;

@property (nonatomic, retain) FormVO *rowdata;

- (IBAction)tapSendArrow;


@end
