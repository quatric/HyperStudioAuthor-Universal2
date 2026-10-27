#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveSystemViewItem.h"


@interface HSInteractiveTextItem : HSInteractiveSystemViewItem
{
}
- (BOOL)objectCanBeActivated;
- (id)defaultCursorAtPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
@end

