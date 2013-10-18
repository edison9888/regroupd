//
//  SettingsHomeVC.h
//  NView-iphone
//
//  Created by Hugh Lang on 6/29/13.
//
//

#import "SlideViewController.h"
#import "SQLiteDB.h"
#import "CCSearchBar.h"
#import "CCTableViewCell.h"
#import "ContactVO.h"

@interface SettingsHomeVC : SlideViewController {
    BOOL isLoading;
    int selectedIndex;
    NSMutableArray *tableData;
}


@end
