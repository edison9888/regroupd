//
//  BrandNavView.m
//  NView-iphone
//
//  Created by Hugh Lang on 7/14/13.
//
//

#import "TabBarView.h"

@implementation TabBarView

//@synthesize delegate = _delegate;

- (id)init {
    NSLog(@"%s", __FUNCTION__);
    if ((self = [super init])) {

        _buttonMap = [[NSMutableDictionary alloc] init];

        _theView = [[[NSBundle mainBundle] loadNibNamed:@"TabBarView" owner:self options:nil] objectAtIndex:0];
        [self addSubview:_theView];

        NSUInteger numViews = [_theView.subviews count];
        NSNumber *numIndex;
        for(int i = 0; i < numViews; i++) {
            if([[_theView.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *) [_theView.subviews objectAtIndex:i];
                button.enabled = YES;
                [button addTarget:self action:@selector(onKeyTapped:) forControlEvents:UIControlEventTouchUpInside];
                numIndex = [NSNumber numberWithInt:button.tag];
                [_buttonMap setObject:button forKey:numIndex];
            } else if([[_theView.subviews objectAtIndex:i] isKindOfClass:[UIImageView class]]) {
                _bgLayer = (UIImageView *) [_theView.subviews objectAtIndex:i];
            }
        }
        
        
    }
    return self;
}

- (void)onKeyTapped:(id)selector {
    NSLog(@"%s", __FUNCTION__);
    
    UIButton *button = (UIButton *) selector;
    NSLog(@"hit tag=%i", button.tag);
    
    if ([DataModel shared].navIndex != button.tag) {

        // move bglayer behind active button
        int xpos = button.frame.origin.x + (button.frame.size.width/2) - _bgLayer.frame.size.width /2;
        
        NSLog(@"move to xpos %i", xpos);
        CGRect bgframe = CGRectMake(xpos, _bgLayer.frame.origin.y, _bgLayer.frame.size.width,
                                     _bgLayer.frame.size.height);
        _bgLayer.frame = bgframe;
        
        [DataModel shared].navIndex = button.tag;
        
        // post notification to switch to new tab (in ViewController)
        NSNotification* switchNavNotification = [NSNotification notificationWithName:@"switchNavNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:switchNavNotification];
        
        
    }


    
}

- (void) moveLayerToIndex:(int)index {
    NSLog(@"%s >> %i", __FUNCTION__, index);
    
    NSNumber *num = [NSNumber numberWithInt:index];
    
    UIButton *button = (UIButton *) [_buttonMap objectForKey:num];

    // move bglayer behind active button
    int xpos = button.frame.origin.x + (button.frame.size.width/2) - _bgLayer.frame.size.width /2;
    
    NSLog(@"move to xpos %i", xpos);
    CGRect bgframe = CGRectMake(xpos, _bgLayer.frame.origin.y, _bgLayer.frame.size.width,
                                _bgLayer.frame.size.height);
    _bgLayer.frame = bgframe;
    
    
}
#pragma mark - getters and seters

//- (void)setEnabled:(BOOL)val {
//    for (UIButton *button in _keysView.subviews) {
//        button.enabled = val;
//    }
//}

#pragma mark - gesture handlers
//
//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __FUNCTION__);
//    
//    
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];
//    UIView* hitView = [self hitTest:locationPoint withEvent:event];
//    NSLog(@"hitView.tag = %i", hitView.tag);
//    
////    UIImageView *dotView;
////    int xpos, ypos = 0;
////    int index = 0;
////    if (hitView.tag >= 100) {
////        dotView = (UIImageView *) [self viewWithTag:hitView.tag];
////        index = hitView.tag - 100;
////        
////        if (dotView != nil) {
////            NSLog(@"Evaluate index %i in array of length %i", index, trendArray.count);
////            
////            item = [trendArray objectAtIndex:index];
////            
////            xpos = (dotView.frame.origin.x + (kDotFrame / 2)) - kBubbleWidth / 2;
////            ypos = dotView.frame.origin.y - kBubbleHeight + 12;
////            
////            [trendBubble removeFromSuperview];
////            if (trendBubble == nil) {
////                trendBubble = [[TrendBubble alloc] init];
////            }
////            CGRect bubbleFrame = CGRectMake(xpos, ypos, 113, 61);
////            trendBubble.frame = bubbleFrame;
////            
////            NSString *_rebate = @"-";
////            
////            TraccsRebateHistory *rebateRecord = [self findRebateByQuarter:item.qtrname];
////            
////            if (rebateRecord != nil) {
////                _rebate =  [NSString formatDoubleWithCommas:rebateRecord.totalRebateAdj*100 decimals:2];
////                _rebate = [_rebate stringByAppendingString:@"%"];
////                NSLog(@"%@ -- Found rebate %@", item.qtrname, _rebate);
////            }
////            
////            [trendBubble configure:[NSString formatIntWithCommas:item.actUnits]
////                            rebate:_rebate];
////            [self addSubview:trendBubble];
////            
////            
////        }
////        
////    }
//
//    
//    
//}


//- (void)setKey:(CalculatorKeys)key enabled:(BOOL)val {
//    
//    UIButton *button = (UIButton*)[_keysView viewWithTag:key];
//    button.enabled = val;
//}

@end
