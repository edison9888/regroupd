//
//  TabbedContentComponent.h
//
//

#import "BaseComponentView.h"

@protocol TabbedContentComponentDelegate <NSObject>
- (void)tabbedContentButtonPressedTag:(NSInteger)tag;

@end

@interface TabbedContentComponent : BaseComponentView {
    UIImageView *_contentImageView;
    NSArray *_componentButtons;
}
@property (nonatomic, strong) IBOutlet UIImageView *contentImageView;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *componentButtons;

- (void)buttonTapped:(id)sender;

@end
