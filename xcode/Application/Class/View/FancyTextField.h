//
//  FancyTextField
//
//


@interface FancyTextField : UITextField {
    
}

@property (nonatomic, retain) NSString* defaultText;
@property BOOL isChanged;

- (void) setFieldLabel:(NSString *)label;



@end
