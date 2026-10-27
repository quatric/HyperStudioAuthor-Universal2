#import "HyperStudioPrefix.h"


@interface HSAddedNodeSelectionAccessor : NSObject <HSStackSelectionAccessor, HSSelectionAccessor, NSObject, HSCardSelectionAccessor, HSCardObjectSelectionAccessor>
{
    id _selectedObject;
    BOOL _containsStack;
    BOOL _containsCards;
    BOOL _containsCardObjects;
}
+ (id)nodeSelectionAccessorWithObjectsArray:(id)aArray;
+ (id)nodeSelectionAccessorWithObject:(id)aObject;
- (void)dealloc;
- (id)initWithSelectedObjectsArray:(id)aArray;
- (id)initWithSelectedObject:(id)aObject;
- (id)initWithHyperSelectedObject:(id)aObject;
- (id)queryHyperInterface:(id)aInterface;
- (id)selectedHyperObject;
@end

