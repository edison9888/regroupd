//
//  WidgetStyle.h
//  Regroupd
//
//  Created by Hugh Lang on 11/25/13.
//
//

#import <Foundation/Foundation.h>

@interface WidgetStyle : NSObject

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIImage *icon;
@property uint fontcolor;
@property uint bgcolor;
@property uint bordercolor;
@property int corner;

@end
