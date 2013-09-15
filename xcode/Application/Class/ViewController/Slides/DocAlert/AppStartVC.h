//
//  AppStartVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"

@interface AppStartVC : SlideViewController
{
    IBOutlet UIImageView *_bgView;
    
}

@property (nonatomic, strong) IBOutlet UIImageView *_bgImage;

- (void) startNewProfile;

@end
