#import "HyperStudioPrefix.h"


@interface HSLicenseInfoDialogController : NSWindowController
{
    NSTextView *_informationView;
    NSTextField *_typeField;
    NSTextField *_identifierField;
    NSTextField *_creationDateField;
    NSTextField *_expirationDateField;
    NSTextField *_copiesCountField;
    NSDictionary *_information;
    unsigned int _isModalSession:1;
    unsigned int _needsUpdate:1;
}
- (void)actionCloseDialog:(id)aDialog;
- (void)actionGetRegistrationNumber:(id)aNumber;
- (void)run;
- (NSInteger)runModal;
- (void)windowDidLoad;
- (id)licenseInfo;
- (void)setLicenseInfo:(id)aInfo;
- (void)HSLicenseInfoDialogController_updateWindow;
- (void)dealloc;
- (id)initWithInfo:(id)aInfo;
- (id)init;
@end

