#import "HyperStudioPrefix.h"


@interface HSEditObjectDialogContext : NSObject
{
    HSEditorDocument *_document;
}
- (id)document;
- (id)stack;
- (id)card;
- (id)initWithEditorDocument:(id)aDocument;
@end

