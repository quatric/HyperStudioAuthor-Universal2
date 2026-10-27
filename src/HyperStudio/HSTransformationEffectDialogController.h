#import "HyperStudioPrefix.h"


@interface HSTransformationEffectDialogController : HSGenericModalController
{
    NSTextField *_scaleFactorTextField;
    NSTextField *_rotationTextField;
    NSMatrix *_rotationMatrix;
    NSButton *_applyButton;
    id _originalObject;
}
- (id)initWithOriginalObject:(id)aObject;
- (void)applyChanges;
- (void)didLoadNib;
- (id)nibName;
@end

@interface HSTransformationEffectDialogController (TextFieldDelegate)
- (void)controlTextDidChange:(id)aChange;
@end

