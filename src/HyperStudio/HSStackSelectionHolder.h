#import "HyperStudioPrefix.h"
#import "HSAbstractSelectionHolder.h"


@interface HSStackSelectionHolder : HSAbstractSelectionHolder
{
    HSDocument *_document;
}
- (void)documentDidChangeCurrentStack:(id)aStack;
- (id)ownSelectedObject;
- (void)setDocument:(id)aDocument;
- (void)dealloc;
@end

