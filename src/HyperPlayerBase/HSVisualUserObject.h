#import "HyperPlayerBasePrefix.h"
#import "HSUserObject.h"


@interface HSVisualUserObject : HSUserObject
{
    BOOL _observesChildrenVisualAttributes;
    BOOL _observesChildrenUndoableAttributes;
}
- (void)HSVisualUserObject_subobjectWillDidChangeUndoableAttribute:(id)aAttribute;
- (void)HSVisualUserObject_subobjectWillDidChangeVisualAttribute:(id)aAttribute;
- (id)children;
- (void)release;
@end

