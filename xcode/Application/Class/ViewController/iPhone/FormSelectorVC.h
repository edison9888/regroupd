//
//  AttachFormPanelVC.h
//  Regroupd
//
//  Created by Hugh Lang on 10/7/13.
//
//

#import <UIKit/UIKit.h>
#import "FormVO.h"
#import "BrandUILabel.h"

@interface FormSelectorVC : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *tableData;
}

@property(retain) NSMutableArray *tableData;

@property (nonatomic, strong) IBOutlet UITableView *theTableView;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet BrandUILabel *titleLabel;

- (IBAction)tapCloseButton;


@end
