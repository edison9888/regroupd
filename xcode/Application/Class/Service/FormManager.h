//
//  FormManager.h
//  Regroupd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import <Foundation/Foundation.h>
#import "FormVO.h"
#import "FormOptionVO.h"

@interface FormManager : NSObject {
    
}

- (FormVO *) loadForm:(int)_formId;
- (FormVO *) loadForm:(int)_formId fetchAll:(BOOL)all;
- (int) saveForm:(FormVO *) form;
- (void) deleteForm:(FormVO *) form;
- (void) updateForm:(FormVO *) form;
- (NSMutableArray *) listForms:(int)type;
- (int) fetchLastFormID;

- (FormOptionVO *) loadOption:(int)_optionId;
- (int) saveOption:(FormOptionVO *) option;
- (void) deleteOption:(FormOptionVO *) option;
- (void) updateOption:(FormOptionVO *) option;
- (NSMutableArray *) listFormOptions:(int)formId;

- (NSString *)saveFormImage:(UIImage *)saveImage withName:(NSString *)filename;
- (UIImage *)loadFormImage:(NSString *)filename;
- (int) fetchLastOptionID;

// API client functions
- (void) apiSaveForm:(FormVO *)form callback:(void (^)(PFObject *))callback;
- (void) apiLoadForm:(NSString *)formKey fetchAll:(BOOL)fetchAll callback:(void (^)(FormVO *form))callback;
- (void) apiListForms:(NSString *)contactKey callback:(void (^)(NSArray *results))callback;

// Form API
- (void) apiSaveFormOption:(FormOptionVO *)option formId:(NSString *)formId callback:(void (^)(PFObject *object))callback;
- (void) apiListFormOptions:(NSString *)formId callback:(void (^)(NSArray *results))callback;

@end
