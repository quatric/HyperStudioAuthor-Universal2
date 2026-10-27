#import "HyperStudioPrefix.h"


@interface HSEmbedCodeForStackDialogController : HSGenericModalController <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    NSTextField *_stackURLField;
    NSTextField *_cardWidthField;
    NSTextField *_cardHeightField;
    unsigned int _isCardWidthValid:1;
    unsigned int _isCardHeightValid:1;
    HSEditorDocument *_currentDocument;
}
- (void)applyChanges;
- (BOOL)control:(id)aControl isValidObject:(id)aObject;
- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription;
- (void)controlTextDidChange:(id)aChange;
- (void)didLoadNib;
- (id)nibName;
@end

