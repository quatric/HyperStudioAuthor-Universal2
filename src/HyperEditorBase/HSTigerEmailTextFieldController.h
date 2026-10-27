#import "HyperEditorBasePrefix.h"


@interface HSTigerEmailTextFieldController : NSObject <HSEmailTextFieldController, NSObject>
{
    NSTokenField *_tokenField;
    HSAddressBookEmailTokenFieldController *_addresBookEmailTokenFieldController;
}
- (void)setEmailAddresses:(id)aAddresses;
- (id)emailAddresses;
- (void)awakeFromNib;
@end

