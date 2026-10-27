#import "HyperEditorBasePrefix.h"


@interface HSMediaOutlineCell : NSTextFieldCell
{
    int _actionState;
    NSPoint _lastMousePoint;
    id _hyperRepresentedObject;
}
- (BOOL)trackActionMoveMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView;
- (BOOL)trackActionMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView;
- (BOOL)mouseMoved:(id)aMoved inRect:(NSRect)aRect ofView:(id)aView;
- (BOOL)mouseDown:(id)aDown inRect:(NSRect)aRect ofView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)selectWithFrame:(NSRect)aFrame inView:(id)aView editor:(id)aEditor delegate:(id)aDelegate start:(NSInteger)aStart length:(NSInteger)aLength;
- (void)setObjectValue:(id)aValue;
- (id)copyWithZone:(NSZone *)aZone;
- (void)setHyperRepresentedObject:(id)aObject;
- (id)hyperRepresentedObject;
- (void)dealloc;
- (id)init;
@end

