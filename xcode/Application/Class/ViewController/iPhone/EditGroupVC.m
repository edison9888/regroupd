//
//  EditGroupVC.m
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "EditGroupVC.h"
#import "DataModel.h"
#import "ContactManager.h"

#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

#define kSearchViewBGColor 0xCACFD0

#define kBaseTagForNameWidget 900

#define kTagScrollView  10

#define kTagNameField   11
#define kTagSearchField 12


@interface EditGroupVC ()

@end

@implementation EditGroupVC

@synthesize tableData;
@synthesize ccSearchBar;
@synthesize navTitle;

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
    
    chatSvc = [[ChatManager alloc] init];
    
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake([DataModel shared].stageWidth, [DataModel shared].stageWidth);
    self.scrollView.tag = kTagScrollView;
    
    // Setup styles for name widgets
    theFont = [UIFont fontWithName:@"Raleway-Regular" size:13];
    xicon = [UIImage imageNamed:@"name_widget_x"];
    
    widgetStyle = [[WidgetStyle alloc] init];
    widgetStyle.fontcolor = 0xFFFFFF;
    widgetStyle.bgcolor = 0x28CFEA;
    widgetStyle.bordercolor = 0x09a1bd;
    widgetStyle.corner = 2;
    widgetStyle.font = theFont;

    nameWidgets = [[NSMutableArray alloc] init];
    
    if ([[DataModel shared].action isEqualToString:kActionADD]) {
        self.navTitle.text = @"New Group";
//        self.groupName.text = @"new group";
        
    } else {
        self.navTitle.text = @"Edit Group";
    }
    
    xpos = 3;
    ypos = 3;
    
    contactKeys = [[NSMutableArray alloc] init];
    contactsArray = [[NSMutableArray alloc] init];
    
    CGRect searchFrame = CGRectMake(5,5,300,36);
    
    ccSearchBar = [[CCSearchBar alloc] initWithFrame:searchFrame];
    ccSearchBar.delegate = self;
    
    UITextField *txfSearchField = [ccSearchBar valueForKey:@"_searchField"];
    txfSearchField.tag = kTagSearchField;
//    txfSearchField.delegate = self;
    
    self.groupName.delegate = self;
    self.groupName.tag = kTagNameField;
    
    [self.searchView addSubview:ccSearchBar];
    [self.searchView.layer setCornerRadius:3.0];
    
    self.searchView.backgroundColor = [UIColor clearColor];
    
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.hidden = NO;
    [self.theTableView setSeparatorColor:[UIColor grayColor]];
    
    
    self.theTableView.backgroundColor = [UIColor clearColor];
    
    self.tableData =[[NSMutableArray alloc]init];
    
    NSNotification* hideNavNotification = [NSNotification notificationWithName:@"hideNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:hideNavNotification];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             
                                             initWithTarget:self action:@selector(singleTap:)];
    
    // Specify that the gesture must be a single tap
    
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];

    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    

    [self performSearch:@""];
    

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[DataModel shared].action isEqualToString:@"popup"]) {
        contactKeys = [[DataModel shared].chat.contact_keys mutableCopy];
        
        ContactVO *contact;
        for (NSString *key in contactKeys) {
            if ([key isEqualToString:[DataModel shared].user.contact_key]) {
                NSLog(@"Ignore current user");
            } else {
                if ([[DataModel shared].contactCache objectForKey:key]) {
                    contact = [[DataModel shared].contactCache objectForKey:key];
                    [contactsArray addObject:contact];
                } else {
                    NSLog(@"ContactCache lookup failed for key %@", key);
                }
            }
        }
        [self reloadNameWidgets];
    }
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


#pragma mark - Keyboard event handlers

/*
 SEE: http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present/2703756#2703756
 */
- (void)keyboardWillHide:(NSNotification *)n
{
    NSLog(@"%s", __FUNCTION__);
    if (_currentField == self.groupName) {
        return;
    }
    
    CGRect viewFrame = self.scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height = [DataModel shared].stageHeight - viewFrame.origin.y;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:0.3];
    
    [self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];

    keyboardIsShown = NO;
    
}

- (void)keyboardWillShow:(NSNotification *)n
{
    NSLog(@"%s", __FUNCTION__);
    if (keyboardIsShown) {
        return;
    }
    NSDictionary* userInfo = [n userInfo];
    keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    keyboardIsShown = YES;

}

#pragma mark - UITextField methods

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    [textField resignFirstResponder];
    if (textField.tag == kTagNameField) {
        UITextField *txfSearchField = [ccSearchBar valueForKey:@"_searchField"];
        [txfSearchField becomeFirstResponder];
//        [self.ccSearchBar.inputView.]
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"%s tag=%i", __FUNCTION__, textField.tag);
    _currentField = textField;

    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}






#pragma mark - UISearchBar
/*
 SOURCE: http://jduff.github.com/2010/03/01/building-a-searchview-with-uisearchbar-and-uitableview/
 */

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [ccSearchBar setShowsCancelButton:NO animated:YES];
    
    self.theTableView.allowsSelection = YES;
    self.theTableView.scrollEnabled = YES;
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height = [DataModel shared].stageHeight - keyboardSize.height - viewFrame.origin.y;
    
    CGRect targetFrame = self.searchView.frame;
    //    targetFrame.origin.y += targetFrame.size.height;
    
    self.scrollView.frame = viewFrame;
    //    self.scrollView.contentSize = CGSizeMake([DataModel shared].stageWidth, self.saveButton.frame.origin.y + 50);
    [self.scrollView scrollRectToVisible:targetFrame animated:YES];
    

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length > 0) {
        self.searchView.backgroundColor = [UIColor colorWithHexValue:kSearchViewBGColor];
        self.theTableView.hidden = NO;
        [self performSearch:searchText];
    } else {
        self.searchView.backgroundColor = [UIColor clearColor];
        self.theTableView.hidden = YES;
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%s", __FUNCTION__);
    ccSearchBar.text=@"";
    
    //    self.theTableView.hidden = YES;
    selectedIndex = -1;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSLog(@"search text=%@", _searchBar.text);
    
    [self performSearch:_searchBar.text];
    
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
    static NSString *CellIdentifier = @"ContactTVC";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    @try {
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.frame = CGRectMake(0, 0, 300, 36);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Regular" size:13]];
            cell.textLabel.textColor = [UIColor colorWithHexValue:0x111111];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSDictionary *rowData = (NSDictionary *) [tableData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:kFullNameFormat, [rowData objectForKey:@"first_name"], [rowData objectForKey:@"last_name"]];
        
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    @try {
        if (indexPath != nil) {
            NSLog(@"Selected row %i", indexPath.row);
            
            selectedIndex = indexPath.row;
            NSDictionary *rowdata = [tableData objectAtIndex:indexPath.row];
            
            ContactVO *contact = [ContactVO readFromPhonebook:rowdata];
            [contactsArray addObject:contact];
            
            [contactKeys addObject:contact.system_id];
            
            CGSize txtSize = [contact.fullname sizeWithFont:theFont];
            float itemWidth = 0;
            itemWidth = txtSize.width + 25;

            if (xpos + itemWidth > self.selectionsView.frame.size.width) {
                xpos = 0;
                ypos += kNameWidgetRowHeight;
                
            }
            
            if (ypos + kNameWidgetRowHeight > self.selectionsView.frame.size.height) {
                CGRect sframe = self.selectionsView.frame;
                sframe.size.height += kNameWidgetRowHeight;
                self.selectionsView.frame = sframe;
                
                CGRect searchFrame = self.searchView.frame;
                if (sframe.origin.y + sframe.size.height > searchFrame.origin.y) {
                    searchFrame.origin.y += kNameWidgetRowHeight;
                    searchFrame.size.height -= kNameWidgetRowHeight;
                    self.searchView.frame = searchFrame;
                }
            }
            CGRect itemFrame = CGRectMake(xpos, ypos, itemWidth, 25);
            NameWidget *item = [[NameWidget alloc] initWithFrame:itemFrame andStyle:widgetStyle];
            
            item.itemKey = contact.contact_key;
            [item setFieldLabel:contact.fullname];
            [item setIcon:xicon];
            
            item.tag = kBaseTagForNameWidget + contactsArray.count - 1;
            xpos += itemWidth + kNameWidgetGap;
            [self.selectionsView addSubview:item];
            
            self.ccSearchBar.text = @"";
            [self performSearch:@""];
            
        }
    } @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
}

#pragma mark - Private Helpers

- (void) reloadNameWidgets
{
    xpos = 3;
    ypos = 3;
    for (UIView *view in self.selectionsView.subviews) {
        [view removeFromSuperview];
    }
    
    for (ContactVO *contact in contactsArray) {
        CGSize txtSize = [contact.fullname sizeWithFont:theFont];
        float itemWidth = 0;
        itemWidth = txtSize.width + 25;
        
        if (xpos + itemWidth > self.selectionsView.frame.size.width) {
            xpos = 0;
            ypos += kNameWidgetRowHeight;
            
        }
        
        if (ypos + kNameWidgetRowHeight > self.selectionsView.frame.size.height) {
            CGRect sframe = self.selectionsView.frame;
            sframe.size.height += kNameWidgetRowHeight;
            self.selectionsView.frame = sframe;
            
            CGRect searchFrame = self.searchView.frame;
            if (sframe.origin.y + sframe.size.height > searchFrame.origin.y) {
                searchFrame.origin.y += kNameWidgetRowHeight;
                searchFrame.size.height -= kNameWidgetRowHeight;
                self.searchView.frame = searchFrame;
            }
        }
        CGRect itemFrame = CGRectMake(xpos, ypos, itemWidth, 25);
        NameWidget *item = [[NameWidget alloc] initWithFrame:itemFrame andStyle:widgetStyle];
        
        item.itemKey = contact.contact_key;
        [item setFieldLabel:contact.fullname];
        [item setIcon:xicon];
        
        item.tag = kBaseTagForNameWidget + contactsArray.count - 1;
        xpos += itemWidth + kNameWidgetGap;
        [self.selectionsView addSubview:item];
        
        
    }
    
    
}
-(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"%s", __FUNCTION__);
    if (UIGestureRecognizerStateEnded == sender.state)
    {
        if (keyboardIsShown) {
            [_currentField resignFirstResponder];
            [_currentField endEditing:YES];
        }
        
        UIView* view = sender.view;
        CGPoint loc = [sender locationInView:view];
        UIView* subview = [view hitTest:loc withEvent:nil];
//        CGPoint subloc = [sender locationInView:subview];
        NSLog(@"hit tag = %i or subview.tag %i", view.tag, subview.tag);
        
        
        //            switch (subview.tag) {
        int nameIndex = subview.tag - kBaseTagForNameWidget;

        if (nameIndex >= 0 && nameIndex <= 99) {
            [contactsArray removeObjectAtIndex:nameIndex];
            [contactKeys removeObjectAtIndex:nameIndex];
            
            NSLog(@"contacts count now %i", contactsArray.count);
            [self reloadNameWidgets];
        }
    }
}

- (void)performSearch:(NSString *)searchText
{
    NSLog(@"%s: %@", __FUNCTION__, searchText);
    
    if (searchText.length > 0) {
        NSString *sqlTemplate = @"select * from phonebook where status=1 and contact_key<>'%@' and (first_name like '%%%@%%' or last_name like '%%%@%%') limit 20";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, [DataModel shared].user.contact_key, searchText, searchText];
        NSLog(@"sql=%@", sql);
        
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            
            [tableData addObject:dict];
        }
        isLoading = NO;
        [self.theTableView reloadData];
        
    } else {
        NSString *sqlTemplate = @"select * from phonebook where status=1 and contact_key<>'%@' order by last_name";
        
        isLoading = YES;
        
        NSString *sql = [NSString stringWithFormat:sqlTemplate, [DataModel shared].user.contact_key, searchText];
        
        FMResultSet *rs = [[SQLiteDB sharedConnection] executeQuery:sql];
        [tableData removeAllObjects];
        
        while ([rs next]) {
            NSDictionary *dict =[rs resultDictionary];
            
            [tableData addObject:dict];
        }
        isLoading = NO;
        
        [self.theTableView reloadData];
    }
    
}

#pragma mark - Action handlers

- (IBAction)tapDoneButton
{
    //    BOOL isOk = YES;
    
    BOOL isOK = YES;
    
    if (contactKeys.count == 0) {
        isOK = NO;
    }
    if (isOK) {
        
        // TODO: save to group table
        GroupVO *group = [[GroupVO alloc] init];
        group.name = self.groupName.text;
        group.system_id = @"";
        group.status = 0;
        group.type = 1;
        
        if (groupSvc == nil) {
            groupSvc = [[GroupManager alloc] init];
        }
        int groupId = [groupSvc saveGroup:group];
        
        NSLog(@"New groupId %i", groupId);
        
        for (NSString* contactKey in contactKeys) {
//            BOOL exists = [groupSvc checkGroupContact:groupId contactId:contactId.intValue];
                [groupSvc saveGroupContact:groupId contactKey:contactKey];
        }
        if ([[DataModel shared].action isEqualToString:@"popup"]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [DataModel shared].action = nil;
            }];
        } else {
            [_delegate gotoSlideWithName:@"GroupsHome"];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Try again" message:@"Please add at least one contact" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    
}

- (IBAction)tapCancelButton
{
    
    if ([[DataModel shared].action isEqualToString:@"popup"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [DataModel shared].action = nil;
        }];
    } else {
        [_delegate goBack];
        
    }
}
@end
