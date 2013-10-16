//
//  GalTextView.h
//  helpy
//
//  Created by Gal Blank on 9/23/12.
//  Copyright (c) 2012 Gal Blank. All rights reserved.
//
//   Renamed from GalTextView and customized


#import <UIKit/UIKit.h>

@interface FancyTextView : UITextView
{
    
    BOOL showPlaceholder;
    
    UILabel *__numLabel;
    UIFont *theFont;
    
}

@property (nonatomic, retain) NSString* defaultText;
@property BOOL isChanged;

-(void)setNumLabel:(NSString*)num;
-(void)setPlaceholder:(NSString*)placeholder;
-(void)unsetPlaceholder:(NSString*)placeholder;

- (CGSize)determineSize:(NSString *)text constrainedToSize:(CGSize)size;

@end
