#import "HSVectorBrushToolCanvasLayer.h"

@implementation HSVectorBrushToolCanvasLayer

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    [[self tool] prepareContext];
    return [super handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    if (!aView)
        return nil;
    return [super cursorForPoint:aPoint insideView:aView modifierFlags:aFlags hitTestInfo:aInfo event:aEvent];
}

// Original quirk kept: the translation is only undone for flipped views.
- (void)renderRect:(NSRect)aRect
{
    id tool = [self tool];
    id image = [tool contextImage];
    if (image == nil)
        return;
    NSView *view = [tool view];
    NSRect bounds = [view bounds];
    CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, 1, bounds.origin.x, bounds.origin.y);
    if ([view isFlipped]) {
        transform.b = -transform.b;
        transform.d = -transform.d;
        transform.ty = (float)(bounds.origin.y + bounds.origin.y + bounds.size.height) - transform.ty;
        [NSGraphicsContext saveGraphicsState];
    }
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], transform);
    [image drawInCurrentNSGraphicsContextAtPoint:NSZeroPoint];
    if ([view isFlipped])
        [NSGraphicsContext restoreGraphicsState];
}

@end
