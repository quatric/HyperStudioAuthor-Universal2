#import "HSInteractiveTextItem.h"
@implementation HSInteractiveTextItem
- (BOOL)objectCanBeActivated
{
    // a temporary text object can't be edited while an animation moves it
    if (![[self node] isTemporary])
        return YES;
    NSEnumerator *enumerator = [[[[[self node] card] animationController] playingAnimations] objectEnumerator];
    id animation;
    while ((animation = [enumerator nextObject]) != nil)
        if ([animation animatedObject] == [self node])
            return NO;
    return YES;
}
- (id)defaultCursorAtPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return [HSCursor textCursor];
}
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    id cursor = [super cursorAtPoint:aPoint modifierFlags:aFlags inCanvasLayer:aLayer];
    if (cursor == nil && [self objectCanBeActivated] &&
        [(id<HSSystemTextViewAttributes>)[[self hyperObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] isEditable])
        cursor = [self defaultCursorAtPoint:aPoint inCanvasLayer:aLayer];
    return cursor;
}
@end
