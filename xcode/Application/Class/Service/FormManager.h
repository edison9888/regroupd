//
//  FormManager.h
//  Re:group'd
//
//  Created by Hugh Lang on 9/26/13.
//
//

#import <Foundation/Foundation.h>
#import "FormVO.h"
#import "FormOptionVO.h"
#import "FormResponseVO.h"

#define kDefaultOptionCount 5

#define kResponseYes @"Yes"
#define kResponseNo @"No"
#define kResponseMaybe @"Maybe"
#define kResponseWaiting @"Waiting"

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
- (void) apiRemoveForm:(NSString *)formKey callback:(void (^)(BOOL))callback;

- (void) apiUpdateFormCounter:(NSString *)formKey withCount:(NSNumber *)count;

// Form Options API
- (void) apiSaveFormOption:(FormOptionVO *)option formId:(NSString *)formId callback:(void (^)(PFObject *object))callback;
- (void) apiListFormOptions:(NSString *)formId callback:(void (^)(NSArray *results))callback;
- (void) apiLookupFormOption:(NSString *)formKey withName:(NSString *)name callback:(void (^)(FormOptionVO *option))callback;


// Form Response API
- (void)apiSaveFormResponse:(FormResponseVO *)response callback:(void (^)(PFObject *object))callback;
- (void)apiListFormResponses:(NSString *)formKey contactKey:(NSString *)contactKey callback:(void (^)(NSArray *results))callback;

#pragma mark - FormContact API

- (void) apiSaveFormContact:(NSString *)formKey contactKey:(NSString *)contactKey callback:(void (^)(PFObject *object))callback;
- (void) apiListFormContacts:(NSString *)formKey contactKey:(NSString *)contactKey callback:(void (^)(NSArray *results))callback;
- (void) apiLookupFormContacts:(NSString *)formKey contactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *savedKeys))callback;
- (void) apiBatchSaveFormContacts:(NSString *)formKey contactKeys:(NSArray *)contactKeys callback:(void (^)(NSArray *savedKeys))callback;
- (void) apiFindReceivedForms:(NSString *)contactKey callback:(void (^)(NSArray *results))callback;

@end
