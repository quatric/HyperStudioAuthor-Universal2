#import "HyperStudioPrefix.h"


@interface HSAbstractSelectionHolder : NSObject <HSSelectionHost, HSPrimitiveSelectionHost, NSObject>
{
    id<HSDocumentSelectionHolderInterface> _documentSelectionHolder;
}
- (void)updateSelectionWithSelectedObject:(id)aObject;
- (void)makeCurrent;
- (id)ownSelectedObject;
- (id)documentSelectionHolder;
- (void)setDocumentSelectionHolder:(id)aHolder;
- (void)noteDidChangeSelectedObject;
@end

