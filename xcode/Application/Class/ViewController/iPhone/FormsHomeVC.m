//
//  FormsHomeVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "FormsHomeVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FormVO.h"
#import "UIColor+ColorWithHex.h"

@interface FormsHomeVC ()

@end

@implementation FormsHomeVC

@synthesize tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    typeFilter = 0;
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor colorWithHexValue:0xEFEFEF];
//    self.theTableView.separatorColor = [UIColor grayColor];
    self.tableData =[[NSMutableArray alloc]init];
    
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePopupNotificationHandler:)
                                                 name:@"closePopupNotification"
                                               object:nil];

    self.addModal.tag = 99;
    
    [self performSearch:@""];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __FUNCTION__);
    // http://stackoverflow.com/questions/413993/loading-a-reusable-uitableviewcell-from-a-nib
    
    static NSString *CellIdentifier = @"FormsTableCell";
    static NSString *CellNib = @"FormsTableViewCell";
    
    FormsTableViewCell *cell = (FormsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            cell = (FormsTableViewCell *)[nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        FormVO *form = (FormVO *)[tableData objectAtIndex:indexPath.row];
        cell.rowdata = form;
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

/*
 66px for rating or poll
 100px for rsvp event
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    FormVO *form = [tableData objectAtIndex:indexPath.row];
    
    if (form.type == FormType_POLL || form.type == FormType_RATING) {
        return 66;
    } else {
        return 100;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
//            FormVO *form = [tableData objectAtIndex:indexPath.row];
            
//            [DataModel shared].contact = [ContactVO readFromDictionary:rowdata];
//            
//            [DataModel shared].action = kActionEDIT;
//            [_delegate gotoNextSlide];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}


- (void)performSearch:(NSString *)searchText
{
    
    if (typeFilter == 0) {
        NSString *sql = @"select * from form order by updated desc";
        
        isLoading = YES;
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        FormVO *row;
        
        while ([rs next]) {
            row = [FormVO readFromDictionary:[rs resultDictionary]];
            [tableData addObject:row];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
        
    } else {
        NSLog(@"%s: %i", __FUNCTION__, typeFilter);
        NSString *sql = @"select * from form where type=? order by updated desc";
        
        isLoading = YES;
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql,
                           [NSNumber numberWithInt:typeFilter]];
        [tableData removeAllObjects];
        
        FormVO *row;
        
        while ([rs next]) {
            row = [FormVO readFromDictionary:[rs resultDictionary]];
            [tableData addObject:row];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
    }
    
    
}

#pragma mark - Action handlers

- (IBAction)tapAddButton
{
    NSLog(@"%s", __FUNCTION__);

    NSNotification* showMaskNotification = [NSNotification notificationWithName:@"showMaskNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showMaskNotification];

    [self showModal];
    
}

- (IBAction)tapEditButton
{
    
}
- (IBAction)tapFormNav:(UIButton*)sender {
    NSLog(@"button clicked - %d",sender.tag);
    typeFilter = sender.tag;
    
    [self updateFormsNav];
    [self performSearch:nil];
}

- (IBAction)tapPollButton {
    NSLog(@"%s", __FUNCTION__);
    [_delegate gotoSlideWithName:@"EditPoll"];
}
- (IBAction)tapRatingButton {
    NSLog(@"%s", __FUNCTION__);
    [_delegate gotoSlideWithName:@"EditRating"];
    
}
- (IBAction)tapRSVPButton {
    NSLog(@"%s", __FUNCTION__);
    [_delegate gotoSlideWithName:@"EditRSVP"];
    
}
- (IBAction)tapCancelButton {
    [self hideModal];
}


#pragma mark -- Notification Handlers

- (void)closePopupNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    [self hideModal];

    
}

#pragma -- Interface methods

- (void) updateFormsNav {
    
    switch (typeFilter) {
        case 0:
            self.navImage0.image = [self lookupImage:0 withState:1];
            self.navImage1.image = [self lookupImage:1 withState:0];
            self.navImage2.image = [self lookupImage:2 withState:0];
            self.navImage3.image = [self lookupImage:3 withState:0];
            
            break;
            
        case FormType_POLL:
            self.navImage0.image = [self lookupImage:0 withState:0];
            self.navImage1.image = [self lookupImage:1 withState:1];
            self.navImage2.image = [self lookupImage:2 withState:0];
            self.navImage3.image = [self lookupImage:3 withState:0];
            break;
            
        case FormType_RATING:
            self.navImage0.image = [self lookupImage:0 withState:0];
            self.navImage1.image = [self lookupImage:1 withState:0];
            self.navImage2.image = [self lookupImage:2 withState:1];
            self.navImage3.image = [self lookupImage:3 withState:0];
            break;
            
        case FormType_RSVP:
            self.navImage0.image = [self lookupImage:0 withState:0];
            self.navImage1.image = [self lookupImage:1 withState:0];
            self.navImage2.image = [self lookupImage:2 withState:0];
            self.navImage3.image = [self lookupImage:3 withState:1];
            break;
            
    }
}

//- (void) updateFormsNav {
//    
//    switch (typeFilter) {
//        case 0:
//            [self.navBtnAll setImage:[self lookupImage:0 withState:1] forState:UIControlStateNormal];
//            [self.navBtnPolls setImage:[self lookupImage:1 withState:0] forState:UIControlStateNormal];
//            [self.navBtnRatings setImage:[self lookupImage:2 withState:0] forState:UIControlStateNormal];
//            [self.navBtnRSVPs setImage:[self lookupImage:3 withState:0] forState:UIControlStateNormal];
//            break;
//            
//        case FormType_POLL:
//            [self.navBtnAll setImage:[self lookupImage:0 withState:0] forState:UIControlStateNormal];
//            [self.navBtnPolls setImage:[self lookupImage:1 withState:1] forState:UIControlStateNormal];
//            [self.navBtnRatings setImage:[self lookupImage:2 withState:0] forState:UIControlStateNormal];
//            [self.navBtnRSVPs setImage:[self lookupImage:3 withState:0] forState:UIControlStateNormal];
//            break;
//            
//        case FormType_RATING:
//            [self.navBtnAll setImage:[self lookupImage:0 withState:0] forState:UIControlStateNormal];
//            [self.navBtnPolls setImage:[self lookupImage:1 withState:0] forState:UIControlStateNormal];
//            [self.navBtnRatings setImage:[self lookupImage:2 withState:1] forState:UIControlStateNormal];
//            [self.navBtnRSVPs setImage:[self lookupImage:3 withState:0] forState:UIControlStateNormal];
//            break;
//            
//        case FormType_RSVP:
//            [self.navBtnAll setImage:[self lookupImage:0 withState:0] forState:UIControlStateNormal];
//            [self.navBtnPolls setImage:[self lookupImage:1 withState:0] forState:UIControlStateNormal];
//            [self.navBtnRatings setImage:[self lookupImage:2 withState:0] forState:UIControlStateNormal];
//            [self.navBtnRSVPs setImage:[self lookupImage:3 withState:1] forState:UIControlStateNormal];
//            break;
//            
//    }
//}

/*
 Helper method for lazy-loading images
 */
- (UIImage *) lookupImage:(int)_type withState:(int)_state {
    
    switch (_type) {
        case 0:
            if (_state == 0) {
                if (nav0ImageOff == nil) {
                    nav0ImageOff = [UIImage imageNamed:@"navbtn_forms_all_off@2x.png"];
                }
                return nav0ImageOff;
            } else {
                if (nav0ImageOn == nil) {
                    nav0ImageOn = [UIImage imageNamed:@"navbtn_forms_all_on@2x.png"];
                }
                return nav0ImageOn;
            }
            break;
            
        case FormType_POLL:
            if (_state == 0) {
                if (nav1ImageOff == nil) {
                    nav1ImageOff = [UIImage imageNamed:@"navbtn_forms_polls_off@2x.png"];
                }
                return nav1ImageOff;
            } else {
                if (nav1ImageOn == nil) {
                    nav1ImageOn = [UIImage imageNamed:@"navbtn_forms_polls_on@2x.png"];
                }
                return nav1ImageOn;
            }
            break;
            
        case FormType_RATING:
            if (_state == 0) {
                if (nav2ImageOff == nil) {
                    nav2ImageOff = [UIImage imageNamed:@"navbtn_forms_ratings_off@2x.png"];
                }
                return nav2ImageOff;
            } else {
                if (nav2ImageOn == nil) {
                    nav2ImageOn = [UIImage imageNamed:@"navbtn_forms_ratings_on@2x.png"];
                }
                return nav2ImageOn;
            }
            break;
            
        case FormType_RSVP:
            if (_state == 0) {
                if (nav3ImageOff == nil) {
                    nav3ImageOff = [UIImage imageNamed:@"navbtn_forms_rsvps_off@2x.png"];
                }
                return nav3ImageOff;
            } else {
                if (nav3ImageOn == nil) {
                    nav3ImageOn = [UIImage imageNamed:@"navbtn_forms_rsvps_on@2x.png"];
                }
                return nav3ImageOn;
            }
            break;
            
    }
    return nil;
}
- (void) showModal {
    
    CGRect fullscreen = CGRectMake(0, 0, [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    bgLayer = [[UIView alloc] initWithFrame:fullscreen];
    bgLayer.backgroundColor = [UIColor grayColor];
    bgLayer.alpha = 0.8;
    bgLayer.tag = 1000;
    bgLayer.layer.zPosition = 9;
    bgLayer.tag = 666;
    [self.view addSubview:bgLayer];

    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height;
    float xpos = ([DataModel shared].stageWidth - modalFrame.size.width) / 2;
    
    modalFrame.origin.y = ypos;
    modalFrame.origin.x = xpos;
    
    NSLog(@"modal at %f, %f", xpos, ypos);
    self.addModal.layer.zPosition = 99;
    self.addModal.frame = modalFrame;
    [self.view addSubview:self.addModal];
    
    ypos = ([DataModel shared].stageHeight - modalFrame.size.height) / 2;
    modalFrame.origin.y = ypos;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];

}

- (void) hideModal {

    
    CGRect modalFrame = self.addModal.frame;
    float ypos = -modalFrame.size.height - 40;
    modalFrame.origin.y = ypos;
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.addModal.frame = modalFrame;
                     }
                     completion:^(BOOL finished){
                         if (bgLayer != nil) {
                             [bgLayer removeFromSuperview];
                             bgLayer = nil;
                         }
                         
                         NSNotification* hideMaskNotification = [NSNotification notificationWithName:@"hideMaskNotification" object:nil];
                         [[NSNotificationCenter defaultCenter] postNotification:hideMaskNotification];
                         
                     }];


}
@end
