#import "HSDisablingCardExternalCanvasLayer.h"

@implementation HSDisablingCardExternalCanvasLayer

// Dims only what lies outside the card's background.
- (void)renderRect:(NSRect)aRect
{
    if (NSIsEmptyRect(aRect))
        return;
    id background = [[[[self context] actionExecutionContext] card] queryHyperInterface:@protocol(HSBackgroundAttributes)];
    if (background == nil)
        return;
    id view = [[self context] renderingView];
    NSRect cardRect = NSIntegralRect([view viewBoundingRectForUserRect:[background backgroundBounds]]);
    cardRect = NSIntersectionRect(aRect, cardRect);
    if (NSIsEmptyRect(cardRect))
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSaveGState(context);
    CGContextAddRect(context, NSRectToCGRect(aRect));
    CGContextAddRect(context, NSRectToCGRect(cardRect));
    CGContextEOClip(context);
    [super renderRect:aRect];
    CGContextRestoreGState(context);
}

@end
