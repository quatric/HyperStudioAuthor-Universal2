#import "HSSetCursorPositionAction.h"
// Moves the mouse pointer to a point on the card (stored relative to the
// card's centre, y up).
@implementation HSSetCursorPositionAction
- (void)setPosition:(NSPoint)aPosition
{
    [self setCursorPosition:aPosition];
}
- (NSPoint)position
{
    return [self cursorPosition];
}
static BOOL HSSetCursorPositionActionNearlyEqual(float aValue, float aValue2)
{
    float scale = fmaxf(aValue2 != 0 ? fabsf(aValue2) : 1.0f, aValue != 0 ? fabsf(aValue) : 1.0f);
    return fabsf(aValue - aValue2) <= scale * 0.0005f;
}
- (void)setCursorPosition:(NSPoint)aPosition
{
    if (HSSetCursorPositionActionNearlyEqual(_cursorPosition.x, aPosition.x) && HSSetCursorPositionActionNearlyEqual(_cursorPosition.y, aPosition.y))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Cursor Position" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setCursorPosition:[self cursorPosition]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSCursorPositionAttribute) ofObject:self withUserInfo:nil];
    _cursorPosition = aPosition;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSCursorPositionAttribute) ofObject:self withUserInfo:nil];
}
- (NSPoint)cursorPosition
{
    return _cursorPosition;
}
// In card coordinates: origin at the top left, y down.
- (void)startInContext:(id)aContext
{
    NSSize cardSize = [[self stack] hyperCardSize];
    NSPoint position = [self cursorPosition];
    [aContext setCursorPosition:NSMakePoint(position.x + cardSize.width * 0.5f, cardSize.height * 0.5f - position.y)];
    [self notifyDidFinish];
}
- (void)setCursorPositionRepresentation:(id)aRepresentation
{
    [self setCursorPosition:NSPointFromString(aRepresentation)];
}
- (id)cursorPositionRepresentation
{
    return NSStringFromPoint([self cursorPosition]);
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
- (BOOL)isSynchronous
{
    return YES;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"cursorPositionRepresentation"];
}
@end
