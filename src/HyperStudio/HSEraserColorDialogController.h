#import "HyperStudioPrefix.h"


@interface HSEraserColorDialogController : HSGenericModalController
{
    HSBigColorMatrix *_backgroundColorMatrix;
    NSTextField *_explanationField;
    HSDocument *_originalObject;
}
- (void)dealloc;
- (void)applyChanges;
- (id)initWithOriginalObject:(id)aObject;
- (void)didLoadNib;
- (id)nibName;
@end

@interface HSEraserColorDialogController (IBActions)
- (void)actionEraseBackground:(id)aBackground;
@end

