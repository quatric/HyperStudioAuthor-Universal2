#import "HSCardObjectView.h"
// Shows one card object (centered, on white) outside a card, as in
// previews.
@implementation HSCardObjectView
- (void)drawViewLayerContentRect:(NSRect)aRect
{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:aRect];
    [super drawViewLayerContentRect:aRect];
}
- (id)userSpaceToViewSpaceTransform
{
    NSAffineTransform *transform = [NSAffineTransform transform];
    NSSize size = [self cardObjectSize];
    NSRect bounds = [self bounds];
    [transform translateXBy:(bounds.size.width * 0.5f + bounds.origin.x) - (size.width * 0.5f + NSZeroPoint.x)
                        yBy:(bounds.size.height * 0.5f + bounds.origin.y) - (size.height * 0.5f + NSZeroPoint.y)];
    return transform;
}
- (id)presentationContext
{
    if (_presentationContext == nil)
        _presentationContext = [[HSPreviewContext presentationContext] retain];
    return _presentationContext;
}
- (id)createCanvasHitTester
{
    return [[HSCanvasHitTester alloc] initWithHitTestingInterface:[HSProtocolIdentifier identifierForProtocol:@protocol(HSUserObjectInteractiveHitTesting)]];
}
- (id)createRootCanvasLayer
{
    HSRootCanvasLayer *root = [[HSRootCanvasLayer alloc] init];
    HSInteractiveObjectsLayer *objects = [[HSInteractiveObjectsLayer alloc] init];
    [root addSublayer:objects];
    [objects release];
    return root;
}
- (NSRect)userObjectBounds
{
    NSSize size = [self cardObjectSize];
    return NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height);
}
- (BOOL)isFlipped
{
    return YES;
}
- (NSPoint)cardObjectOrigin
{
    id geometry = [[self userObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroPoint;
    return [geometry frameBoundingRect].origin;
}
- (NSSize)cardObjectSize
{
    id size = [[self userObject] queryHyperInterface:@protocol(HSSizeAttributes)];
    if (size == nil)
        return NSZeroSize;
    return [(id<HSSizeAttributes>)size size];
}
@end
