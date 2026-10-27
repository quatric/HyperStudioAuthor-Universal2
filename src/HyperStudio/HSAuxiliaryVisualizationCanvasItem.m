#import "HSAuxiliaryVisualizationCanvasItem.h"

@implementation HSAuxiliaryVisualizationCanvasItem

+ (id)itemWithObject:(id)aObject
{
    id renderer = [[aObject queryHyperInterface:@protocol(HSVisualization)] queryRenderer];
    if (!renderer)
        return nil;
    return [[[self alloc] initWithRenderer:renderer] autorelease];
}

- (id)updateWithChangedRegionBounds:(id)aBounds inCanvasLayer:(id)aLayer
{
    if (!aBounds)
        aBounds = [self userBoundingRegion];
    return [self userRegion:aBounds transformedToViewSpaceInCanvasLayer:aLayer];
}

// View space to user space of the layer, then back out of the renderer's
// transform (inverted).
- (id)viewRegion:(id)aRegion transformedToUserSpaceInCanvasLayer:(id)aLayer
{
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[[[aLayer context] renderingView] viewSpaceToUserSpaceCGAffineTransform]];
    [region applyAffineTransform:CGAffineTransformInvert([self rendererToRootUserSpaceAffineTransform])];
    return region;
}

- (id)userRegion:(id)aRegion transformedToViewSpaceInCanvasLayer:(id)aLayer
{
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self rendererToRootUserSpaceAffineTransform]];
    [region applyAffineTransform:[[[aLayer context] renderingView] userSpaceToViewSpaceCGAffineTransform]];
    return region;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return YES;
}

- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [self userRegion:[self userBoundingRegion] transformedToViewSpaceInCanvasLayer:aLayer];
}

- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    return [[self renderingRegionInCanvasLayer:aLayer] boundingRect];
}

- (BOOL)prefersRegionInvalidation
{
    return YES;
}

- (BOOL)hitTestRect:(NSRect)aRect inCanvasLayer:(id)aLayer
{
    return NO;
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NSPointInRect(aPoint, [self renderingBoundsInCanvasLayer:aLayer]);
}

- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    id region = [self viewRegion:[HSRegion regionWithRect:aRect] transformedToUserSpaceInCanvasLayer:aLayer];
    [NSGraphicsContext saveGraphicsState];
    [[[[aLayer context] renderingView] userSpaceToViewSpaceTransform] concat];
    [[NSAffineTransform transformWithHyperCGAffineTransform:[self rendererToRootUserSpaceAffineTransform]] concat];
    [[self renderer] drawRegion:region withDelegate:nil];
    [NSGraphicsContext restoreGraphicsState];
}

- (CGAffineTransform)rendererToRootUserSpaceAffineTransform
{
    return [[[[self renderer] visualization] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
}

- (id)userBoundingRegion
{
    return [[self renderer] boundingRegion];
}

- (id)renderer
{
    return [self hyperObject];
}

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject
{
    return nil;
}

- (id)initWithRenderer:(id)aRenderer
{
    return [super initWithHyperObject:aRenderer];
}

@end
