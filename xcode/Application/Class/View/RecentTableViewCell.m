//
//  RecentTableViewCell.m
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import "RecentTableViewCell.h"

@implementation RecentTableViewCell

@synthesize name, timestamp, patient;
@synthesize arrowView;
@synthesize dotView;


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
    return @"RecentTableCell";
}
- (void)setRowdata:(NSDictionary *)data inMode:(int)mode
{
    
    self.name.text = [data objectForKey:@"name"];
    self.timestamp.text = [data objectForKey:@"created"];
    self.patient.text = [data objectForKey:@"patient_name"];
    NSString *text = [data objectForKey:@"status"];
    
    int status = text.intValue;
    
    if (mode == 0) {
        self.deleteButton.hidden = YES;
        
        if (status == 1) {
            self.dotView.hidden = YES;
            
        } else  {
            self.dotView.hidden = NO;
            
        }
        
    } else if (mode == 1) {
        self.deleteButton.hidden = NO;
        // temporary setting
        self.dotView.hidden = YES;
        
    }
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action handlers

- (IBAction)tapDelete
{
    //    BOOL isOk = YES;
    
}

@end
