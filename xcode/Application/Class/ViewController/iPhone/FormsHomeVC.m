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
#import "NSDate+Extensions.h"

static NSString *kEditLabel = @"Edit";
static NSString *kDoneLabel = @"Done";

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
    // Reset action
    typeFilter = 0;
    
    CGRect scrollFrame = self.theTableView.frame;
    scrollFrame.size.height -= 50;
    NSLog(@"Set scroll frame height to %f", scrollFrame.size.height);

    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.backgroundColor = [UIColor colorWithHexValue:0xEFEFEF];
    self.theTableView.frame = scrollFrame;
    
//    self.theTableView.separatorColor = [UIColor grayColor];
    self.tableData =[[NSMutableArray alloc]init];
    
    
    NSNotification* showNavNotification = [NSNotification notificationWithName:@"showNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:showNavNotification];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePopupNotificationHandler:)
                                                 name:@"closePopupNotification"
                                               object:nil];

    self.addModal.tag = 99;
    [self listMyForms];
//    [self performSearch:@""];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Load data

- (void)listMyForms
{
    NSLog(@"%s", __FUNCTION__);
    self.allForms = [[NSMutableArray alloc] init];
    
    if (formSvc == nil) {
        formSvc = [[FormManager alloc] init];
    }
    if (contactSvc == nil) {
        contactSvc = [[ContactManager alloc] init];
    }
    
    [formSvc apiListForms:nil callback:^(NSArray *results) {
        if (results) {
            FormVO *form;
            for (PFObject *result in results) {
                form = [FormVO readFromPFObject:result];
                [self.allForms addObject:form];
            }
            [formSvc apiFindReceivedForms:[DataModel shared].user.contact_key callback:^(NSArray *results) {
                FormVO *form;
                for (PFObject *pfForm in results) {
                    form = [FormVO readFromPFObject:pfForm];
                    if (form.type == FormType_RSVP) {
                        [self.allForms addObject:form];
                    }
                }
                
                [self.allForms sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
                 {
                     FormVO *form1 = (FormVO *)obj1;
                     FormVO *form2 = (FormVO *)obj2;
                     
                     return [form2.updatedAt compare:form1.updatedAt];
                 }];

                [DataModel shared].formsList = self.allForms;
                
                self.tableData = [self.allForms mutableCopy];
                [self.theTableView reloadData];
            }];
        }
    }];
}
- (void)listFormsByType:(int)formType
{
    [self.tableData removeAllObjects];
    
    for (FormVO *form in self.allForms) {
        if (formType == 0) {
            [self.tableData addObject:form];
        } else if (form.type == formType) {
            [self.tableData addObject:form];
        }
    }
    [self.theTableView reloadData];
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
        

        [cell.sendArrow addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([form.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
            cell.hostLabel.hidden = YES;
            cell.hostField.hidden = YES;
        } else {
            cell.hostLabel.hidden = NO;
            cell.hostField.hidden = NO;
            [contactSvc apiLoadContact:form.contact_key callback:^(PFObject *pfContact) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ContactVO *c = [ContactVO readFromPFObject:pfContact];
                    cell.hostField.text = c.fullname;
                });
            }];
            
        }

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
        if ([form.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
            return 100;
        } else {
            return 115;
        }

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    // http://stackoverflow.com/questions/1802707/detecting-which-uibutton-was-pressed-in-a-uitableview
    @try {
        if (indexPath != nil) {
            selectedIndex = indexPath.row;
            
            FormVO *form = [tableData objectAtIndex:indexPath.row];
            
            NSLog(@"Selected row %i with type %i", indexPath.row, form.type);
            
            switch (form.type) {
                    
                    
                case FormType_POLL:
                    [DataModel shared].form = form;
                    [_delegate gotoSlideWithName:@"PollDetail"];
                    break;
                case FormType_RATING:
                    [DataModel shared].form = form;
                    [_delegate gotoSlideWithName:@"RatingDetail"];
                    break;
                case FormType_RSVP:
                    [DataModel shared].form = form;
                    [_delegate gotoSlideWithName:@"RSVPDetail"];
                    break;
                    
                default:
                    break;
            }
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}

- (void)checkButtonTapped:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.theTableView];
    NSIndexPath *indexPath = [self.theTableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath != nil)
    {
        
        NSLog(@"button index %@", indexPath);
        
        FormVO *form = (FormVO *)[tableData objectAtIndex:indexPath.row];
        [DataModel shared].form = form;
        [_delegate gotoSlideWithName:@"FormSend" returnPath:@"FormsHome"];
        
    }
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.

    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        FormVO *form = [tableData objectAtIndex:indexPath.row];
        if ([form.contact_key isEqualToString:[DataModel shared].user.contact_key]) {
            // User is owner of form.
            [formSvc apiRemoveForm:form.system_id callback:^(BOOL success) {
                if (success) {
                    
                    NSString *msg;
                    
                    if (form.type == FormType_RSVP) {
                        [self setEditing:NO animated:YES];
                        [self listMyForms];

                        msg = @"This RSVP has been marked as cancelled";
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:msg
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        
                        [alert show];
                    } else {
                        msg = @"This form has been removed";
                        [self.tableData removeObjectAtIndex:indexPath.row];
                        [self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    }
                    
                }
                
            }];

        } else {
            [formSvc apiListFormContacts:form.system_id contactKey:[DataModel shared].user.contact_key callback:^(NSArray *results) {
                if (results) {
                    int total = results.count;
                    int index = 0;
                    for (PFObject *pfObject in results) {
                        NSLog(@"Deleting FormContact %@", pfObject.objectId);
                        [pfObject deleteInBackground];
                        index++;
                        
                        if (index == total) {
                            [self setEditing:NO animated:YES];
                            [self listMyForms];
                            
                        }
                    }
                }
            }];
        }
        
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    

    [self.theTableView setEditing:editing];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // i also tried to  return YES;
}

// Select the editing style of each cell
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FormsTableViewCell *cell = (FormsTableViewCell *)[self.theTableView cellForRowAtIndexPath:indexPath];
    if (inEditMode) {
        cell.dateField.hidden = YES;
        cell.sendArrow.hidden = YES;
        
    } else {
        cell.dateField.hidden = NO;
        cell.sendArrow.hidden = NO;
    }

    return UITableViewCellEditingStyleDelete;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
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
    if (inEditMode) {
        inEditMode = NO;
        [self.editButton setTitle:kEditLabel forState:UIControlStateNormal];
        
        [self setEditing:inEditMode animated:YES];

        for (int row = 0, rowCount = [self.theTableView numberOfRowsInSection:0]; row < rowCount; ++row) {
            FormsTableViewCell *cell = (FormsTableViewCell *) [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            cell.dateField.hidden = NO;
            cell.sendArrow.hidden = NO;
        }
        
        [self.theTableView reloadData];
        
    } else {
        inEditMode = YES;
        [self setEditing:inEditMode animated:YES];
        
        [self.editButton setTitle:kDoneLabel forState:UIControlStateNormal];
        
        [self.theTableView reloadData];
        
        
    }
    
}


- (IBAction)tapFormNav:(UIButton*)sender {
    NSLog(@"button clicked - %d",sender.tag);
    typeFilter = sender.tag;
    
    [self updateFormsNav];
    
    [self listFormsByType:typeFilter];
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
