//
//  KeypadViewController.m
//  Blocpad
//
//  Created by Hugh Lang on 3/30/13.
//
//

#import "KeypadViewController.h"

@interface KeypadViewController ()

@end

@implementation KeypadViewController

@synthesize keyPadView;
@synthesize delegate = _delegate;

- (id)init
{
    NSLog(@"%s", __FUNCTION__);
    self = [super init];
    if (self) {
        // Custom initialization
//        CGRect baseFrame = CGRectMake(0, 0, 380, 340);
//        self.view.frame = baseFrame;

    }
    return self;
    
}

- (void)viewDidLoad
{
    NSLog(@"%s", __FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    keyPadView = [[CalculatorKeyPadView alloc] init];
    keyPadView.frame = self.view.bounds;
    keyPadView.delegate = self;
    [self.view addSubview:keyPadView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Calculator KeyPad Delegate

- (void)calculatorKeyPadKeyPressed:(CalculatorKeys)key {
    if (_delegate || [_delegate respondsToSelector:@selector(keyHandler:)]) {
//        NSLog(@"%s delegate key: %i", __FUNCTION__, key);
        [_delegate keyHandler:key];
    }
}

@end
