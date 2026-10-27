#import "HSImportDialogImportedTableView.h"

@implementation HSImportDialogImportedTableView

- (void)dragImage:(id)aImage at:(NSPoint)aAt offset:(NSSize)aOffset event:(id)aEvent pasteboard:(id)aPasteboard source:(id)aSource slideBack:(BOOL)aBack
{
    [super dragImage:aImage at:aAt offset:aOffset event:aEvent pasteboard:aPasteboard source:aSource slideBack:NO];
}

// Rows dropped outside the table go up in a puff of smoke.
- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation
{
    NSWindow *window = [self window];
    NSPoint mouse = [window mouseLocationOutsideOfEventStream];
    NSPoint point = [window convertRectToScreen:NSMakeRect(mouse.x, mouse.y, 0, 0)].origin;
    NSRect visible = [window convertRectToScreen:[self convertRect:[self visibleRect] toView:nil]];
    if (!NSPointInRect(point, visible))
        NSShowAnimationEffect(NSAnimationEffectPoof, point, NSZeroSize, self, @selector(poofAnimationEffectDidEnd:), NULL);
}

- (void)poofAnimationEffectDidEnd:(void *)aEnd
{
    if ([[self delegate] respondsToSelector:@selector(removeDraggedOutRowsFromTableView:)])
        [(id)[self delegate] performSelector:@selector(removeDraggedOutRowsFromTableView:) withObject:self];
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal
{
    return NSDragOperationDelete;
}

@end
