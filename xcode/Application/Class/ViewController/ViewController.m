//
//  ViewController.m
//
//  Created by hugh
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SlideModel.h"
#import "UserManager.h"

@implementation ViewController

@synthesize brandNav;
//@synthesize popOverNavigation = _popOverNavigation;
//@synthesize overlayView = _overlayView;
//@synthesize tabBarOverlayView = _tabBarOverlayView;
//@synthesize tabBar = _tabBar;
//@synthesize navigationButtons = _navigationButtons;
//@synthesize espButton = _espButton;
//@synthesize selectedButton = _selectedButton;
//@synthesize lastSelectedButton = _lastSelectedButton;
//@synthesize isOnHomeSlide = _isOnHomeSlide;
//@synthesize isOnEspSlide = _isOnEspSlide;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"%s", __FUNCTION__);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.presentationModel = [PresentationModel presentationModelWithPlistFile:@"AppUI.plist"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"%s", __FUNCTION__);
//    _isOnHomeSlide = YES;
//    _selectedButton = [_navigationButtons objectAtIndex:0];
    
    [super viewDidLoad];
    
    UserManager *userSvc = [[UserManager alloc] init];
    UserVO *user = [userSvc lookupDefaultUser];
    [DataModel shared].user = user;

    NSNumber *numIndex;
    navMap = [[NSMutableDictionary alloc] init];
    numIndex = [NSNumber numberWithInt:1];
    [navMap setObject:@"GroupsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:2];
    [navMap setObject:@"ChatsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:3];
    [navMap setObject:@"FormsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:4];
    [navMap setObject:@"ContactsHome" forKey:numIndex];

    numIndex = [NSNumber numberWithInt:5];
    [navMap setObject:@"SettingsHome" forKey:numIndex];

    brandNav = [[TabBarView alloc] init];

    
    NSLog(@"dimensions = %i x %i", [DataModel shared].stageWidth, [DataModel shared].stageHeight);
    
    CGRect frame = CGRectMake(0, [DataModel shared].stageHeight - 50, [DataModel shared].stageWidth, 50);
    brandNav.frame = frame;
    brandNav.hidden = YES;
    [self.view addSubview:brandNav];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNavNotificationHandler:)     name:@"hideNavNotification"            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNavNotificationHandler:)     name:@"showNavNotification"            object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMaskNotificationHandler:)     name:@"hideMaskNotification"            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMaskNotificationHandler:)     name:@"showMaskNotification"            object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchNavNotificationHandler:)     name:@"switchNavNotification"            object:nil];

    // Do any additional setup after loading the view, typically from a nib.
    [self gotoSlideWithName:kSlideHome andOverrideTransition:kPresentationTransitionFadeInFadeOut];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    self.popOverNavigation = nil;
//    self.tabBar = nil;
//    self.navigationButtons = nil;
//    self.espButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


#pragma mark - Notification handlers
- (void)hideNavNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    brandNav.hidden = YES;
    
}
- (void)showNavNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    brandNav.hidden = NO;
}
- (void)hideMaskNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    if (navMask != nil) {
        [navMask removeFromSuperview];
        navMask = nil;
    }
    
}
- (void)showMaskNotificationHandler:(NSNotification*)notification
{
    NSLog(@"%s", __FUNCTION__);
    CGRect navFrame = brandNav.frame;
    navMask = [[UIView alloc] initWithFrame:navFrame];
    navMask.backgroundColor = [UIColor grayColor];
    navMask.alpha = 0;

    [self.view addSubview:navMask];
}

- (void)switchNavNotificationHandler:(NSNotification*)notification
{
#ifdef DEBUGX
    NSLog(@"%s", __FUNCTION__);
#endif
    NSNumber *numIndex = [NSNumber numberWithInt:[DataModel shared].navIndex];
    NSString *slideName = [navMap objectForKey:numIndex];
    
    [brandNav moveLayerToIndex:numIndex.intValue];
    
    NSLog(@"Switch to slide %@", slideName);
    [_activeSlide.delegate gotoSlideWithName:slideName andOverrideTransition:kPresentationTransitionFade];
    
}

#pragma mark - menu button tap handlers

- (void)setSelectedButton:(UIButton *)selectedButton {
        
//    _selectedButton.selected = NO;
//    _selectedButton = selectedButton;
//    _selectedButton.selected = YES;
}

- (void)onHomeButtonTapped:(id)sender {
    
//    if (self.isTransitioning) {
//        return;
//    }
//    
//    _lastSelectedButton = sender;
//
//    _isOnHomeSlide = YES;
//    _isOnEspSlide = NO;
//    _espButton.selected = NO;
//    
//    if ([self isDifferentSection:kSlideHome]) { 
//        [self gotoSlideWithName:kSlideHome andOverrideTransition:kPresentationTransitionFadeInFadeOut];
//        self.selectedButton = (UIButton*)sender;
//    }
}

     
- (BOOL)isDifferentSection:(NSString *)slideId 
{
    BOOL isDifferent = NO;
    SlideModel *toSlide = [_presentationModel slideWithName:slideId];
    if (![toSlide.category isEqualToString:_activeSlide.slideModel.category]) {
        isDifferent = YES;
    }
    
    return isDifferent;
}

- (void)removePopOver
{
//    self.selectedButton = _lastSelectedButton;
//
//    if (_isOnHomeSlide && ((SlideHomeVideoVC*)self.activeSlide).isPlaying) {
//        [((SlideHomeVideoVC*)self.activeSlide) playVideo];
//    }
    
//    [_overlayView setAlpha:0];
//    [_tabBarOverlayView setAlpha:0];
//    [_overlayView removeFromSuperview];
//    [_tabBarOverlayView removeFromSuperview];
//    [_popOverNavigation removeFromSuperview];
}
-(void) showPrimaryNav {
    
}
-(void) hidePrimaryNav {
    
}


@end
