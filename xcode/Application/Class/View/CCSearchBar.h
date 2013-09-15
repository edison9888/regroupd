//
//  CCSearchBar.h
//  Blocpad
//
//  Created by Hugh Lang on 4/8/13.
//
//

#import <UIKit/UIKit.h>

@interface CCSearchBar : UISearchBar {
    UITextField *searchField;
}

@property (nonatomic, retain) UITextField *searchField;

- (void) clearPlaceholderText;
- (void) resetPlaceholderText;
@end
