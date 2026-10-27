#import "HyperEditorBasePrefix.h"


@interface HSMediaOutlineView : NSOutlineView
{
    NSEvent *_endEditingEvent;
}
- (void)textDidEndEditing:(id)aEditing;
- (void)keyDown:(id)aDown;
- (void)collapseItem:(id)aItem collapseChildren:(BOOL)aChildren;
- (void)expandItem:(id)aItem expandChildren:(BOOL)aChildren;
- (void)paste:(id)aPaste;
- (void)delete:(id)aDelete;
- (void)cut:(id)aCut;
- (void)copy:(id)aCopy;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)mouseMoved:(id)aMoved;
- (void)mouseDown:(id)aDown;
- (void)dealloc;
@end

