//
//  FormsTableViewCell.m
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "FormsTableViewCell.h"
#import "NSDate+Extensions.h"

#define kIconPoll @"icon_poll_purple@2x.png"
#define kIconRating @"icon_rating_purple@2x.png"
#define kIconEvent @"icon_event_purple@2x.png"

@implementation FormsTableViewCell

@synthesize titleField;
@synthesize rowdata;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (NSString *) reuseIdentifier {
    return @"FormsTableCell";
}



////http://stackoverflow.com/questions/11920156/custom-uitableviewcell-selection-style
//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    if (highlighted) {
//        self.titleField.textColor = [UIColor blackColor];
//    } else {
//        self.titleField.textColor = [UIColor blackColor];
//    }
////    [super setHighlighted:<#highlighted#> animated:<#animated#>];
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

#pragma mark - Customizations

- (void)setRowdata:(FormVO *)form
{
    rowdata = form;
    self.titleField.text = form.name;
    UIImage *icon;
    
    if (form.type == FormType_POLL) {
        icon = [UIImage imageNamed:kIconPoll];
        self.iconType.image = icon;
        self.whenLabel.hidden = YES;
        self.whenField.hidden = YES;
        self.whereLabel.hidden = YES;
        self.whereField.hidden = YES;
        
    } else if (form.type == FormType_RATING) {
        icon = [UIImage imageNamed:kIconRating];
        self.iconType.image = icon;
        self.whenLabel.hidden = YES;
        self.whenField.hidden = YES;
        self.whereLabel.hidden = YES;
        self.whereField.hidden = YES;
        
    } else if (form.type == FormType_RSVP) {
//        self.whenField = 
        
        
    } else {
        // Use default Poll icon already set in NIB
    }
    
    
}

- (IBAction)tapSendArrow {
    
}

@end
