#import "HSUserObjectPreviewView.h"
#import "HSGenericRenderDelegate.h"
#import "HSMutableRegion.h"
#import "NSAffineTransform+HSKeyValueCoding.h"
#import "NSImage+HSImageSize.h"
#import "NSMutableArray+HSWeightBehaviors.h"

// Draws the renderers of a set of user objects, for previews, thumbnails and
// drag images. Subclasses say which renderer an object has.
@implementation HSUserObjectPreviewView

+ (id)retrieveRendererFromObject:(id)aObject
{
    return nil;
}

// Scaled down to fit the size, keeping the aspect ratio.
+ (id)thumbnailPreviewImageWithMaxSize:(NSSize)aSize forObject:(id)aObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *objects = [[NSArray alloc] initWithObjects:aObject, nil];
    NSImage *preview = [self previewImageForObjects:objects objectsAreAlreadySorted:YES needBitmapRep:NO renderingOrigin:NULL];
    [objects release];
    NSImage *thumbnail = nil;
    if (preview != nil && aSize.width > 0 && aSize.height > 0) {
        NSSize size = [preview size];
        NSSize thumbnailSize = size;
        if (size.width > aSize.width || size.height > aSize.height) {
            CGFloat scale = size.width <= size.height ? aSize.height / size.height : aSize.width / size.width;
            thumbnailSize = NSMakeSize(size.width * scale, size.height * scale);
        }
        NSImage *image = [[[NSImage alloc] initWithSize:thumbnailSize] autorelease];
        [image lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [preview drawInRect:NSMakeRect(0, 0, thumbnailSize.width, thumbnailSize.height) fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1];
        [image unlockFocus];
        thumbnail = [[NSImage alloc] initWithData:[image TIFFRepresentation]];
    }
    [pool release];
    return [thumbnail autorelease];
}

// The preview, scaled down to fit inside the inset and centred on a canvas of
// the given size.
+ (id)thumbnailPreviewImageOfSize:(NSSize)aSize forObject:(id)aObject borderInset:(NSSize)aInset
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *objects = [[NSArray alloc] initWithObjects:aObject, nil];
    NSImage *preview = [self previewImageForObjects:objects objectsAreAlreadySorted:YES needBitmapRep:NO renderingOrigin:NULL];
    [objects release];
    NSImage *thumbnail = nil;
    if (preview != nil && aSize.width > 0 && aSize.height > 0) {
        NSSize size = [preview size];
        NSImage *image = [[[NSImage alloc] initWithSize:aSize] autorelease];
        NSRect inner = NSInsetRect(NSMakeRect(0, 0, aSize.width, aSize.height), aInset.width, aInset.height);
        NSSize drawSize = size;
        if (size.width > inner.size.width || size.height > inner.size.height) {
            CGFloat scale = size.width > size.height ? inner.size.width / size.width : inner.size.height / size.height;
            drawSize = NSMakeSize(size.width * scale, size.height * scale);
        }
        NSRect destination;
        destination.origin.x = floor(inner.origin.x + (inner.size.width - drawSize.width) * 0.5);
        destination.origin.y = floor(inner.origin.y + (inner.size.height - drawSize.height) * 0.5);
        destination.size = drawSize;
        [image lockFocus];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [preview drawInRect:destination fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1];
        [image unlockFocus];
        thumbnail = [[NSImage alloc] initWithData:[image TIFFRepresentation]];
    }
    [pool release];
    return [thumbnail autorelease];
}

// The preview at half opacity.
+ (id)dragPreviewImageForSortedObjects:(id)aObjects
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImage *preview = [self previewImageForObjects:aObjects objectsAreAlreadySorted:YES needBitmapRep:NO renderingOrigin:NULL];
    NSImage *dragImage = nil;
    if (preview != nil) {
        NSImage *image = [[[NSImage alloc] initWithSize:[preview size]] autorelease];
        [image lockFocus];
        // compositeToPoint:operation:fraction: in the original
        [preview drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:0.5];
        [image unlockFocus];
        dragImage = [[NSImage alloc] initWithData:[image TIFFRepresentation]];
    }
    [pool release];
    return [dragImage autorelease];
}

+ (id)previewImageForObjects:(id)aObjects renderingOrigin:(NSPoint *)aOrigin
{
    id view = [[[[self class] alloc] initWithFrame:NSZeroRect] autorelease];
    return [self previewImageWithView:view forObjects:aObjects objectsAreAlreadySorted:NO needBitmapRep:YES renderingOrigin:aOrigin];
}

+ (id)previewImageForSortedObjects:(id)aObjects
{
    return [self previewImageForObjects:aObjects objectsAreAlreadySorted:YES needBitmapRep:YES renderingOrigin:NULL];
}

+ (id)previewImageForObjects:(id)aObjects
{
    return [self previewImageForObjects:aObjects objectsAreAlreadySorted:NO needBitmapRep:YES renderingOrigin:NULL];
}

+ (id)previewImageForObject:(id)aObject
{
    NSArray *objects = [[NSArray alloc] initWithObjects:aObject, nil];
    id image = [self previewImageForObjects:objects objectsAreAlreadySorted:YES needBitmapRep:YES renderingOrigin:NULL];
    [objects release];
    return image;
}

+ (id)previewImageForObjects:(id)aObjects objectsAreAlreadySorted:(BOOL)aSorted needBitmapRep:(BOOL)aRep renderingOrigin:(NSPoint *)aOrigin
{
    id view = [[[[self class] alloc] initWithFrame:NSZeroRect] autorelease];
    return [self previewImageWithView:view forObjects:aObjects objectsAreAlreadySorted:aSorted needBitmapRep:aRep renderingOrigin:aOrigin];
}

// The rendering origin is the origin of the renderers' bounds, which is where
// the image goes to cover the objects.
+ (id)previewImageWithView:(id)aView forObjects:(id)aObjects objectsAreAlreadySorted:(BOOL)aSorted needBitmapRep:(BOOL)aRep renderingOrigin:(NSPoint *)aOrigin
{
    [aView setBackgroundColor:[NSColor clearColor]];
    if ([aObjects count] == 1) {
        [aView addUserObject:[aObjects lastObject]];
    } else if ([aObjects count] > 1) {
        NSEnumerator *enumerator = aSorted ? [aObjects objectEnumerator] : [self objectEnumeratorForSortedObjectsInArray:aObjects];
        id object;
        while ((object = [enumerator nextObject]) != nil)
            [aView addUserObject:object];
    }
    NSRect bounds = NSIntegralRect([aView renderersBoundingRect]);
    NSImage *image = nil;
    if (!NSIsEmptyRect(bounds)) {
        [aView setFrameSize:bounds.size];
        image = [NSImage hyperImageWithView:aView];
        if (aRep)
            image = [[[NSImage alloc] initWithData:[image TIFFRepresentation]] autorelease];
    }
    if (aOrigin != NULL)
        *aOrigin = bounds.origin;
    return image;
}

+ (id)objectEnumeratorForSortedObjectsInArray:(id)aArray
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[aArray count]];
    NSEnumerator *enumerator = [aArray objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id weighted = [object queryHyperInterface:@protocol(HSObjectWeightBehaviors)];
        if (weighted != nil)
            [objects addObject:weighted];
    }
    [objects sortByHyperOrder];
    return [objects objectEnumerator];
}

+ (NSSize)sizeOfPreviewImageForObject:(id)aObject
{
    return [self sizeOfPreviewImageForObject:aObject offsetFromObjectBounds:NULL];
}

// The integral transformed bounds of the renderer, and the offset of their
// top left corner from the object's frame. Quirk kept: without an offset
// pointer nothing is computed and the size is zero.
+ (NSSize)sizeOfPreviewImageForObject:(id)aObject offsetFromObjectBounds:(NSPoint *)aBounds
{
    NSRect bounds = NSZeroRect;
    id renderer = [self retrieveRendererFromObject:aObject];
    if (renderer != nil && aBounds != NULL) {
        id<HSGeometryAttributes> geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry == nil) {
            *aBounds = NSZeroPoint;
        } else {
            bounds = NSIntegralRect(CGRectApplyAffineTransform([[renderer boundingRegion] boundingRect], [geometry affineTransform]));
            NSRect frame = NSIntegralRect([geometry frameBoundingRect]);
            aBounds->x = bounds.origin.x - frame.origin.x;
            aBounds->y = NSMaxY(frame) - NSMaxY(bounds);
        }
    }
    return bounds.size;
}

- (void)setOpaque:(BOOL)aOpaque
{
    if (aOpaque == _isOpaque)
        return;
    _isOpaque = aOpaque;
    [self setNeedsDisplay:YES];
    [[self superview] setNeedsDisplayInRect:[self frame]];
}

- (BOOL)isOpaque
{
    return _isOpaque;
}

- (void)hyperUpdateVisualObjectCount
{
    [[self renderers] removeAllObjects];
    NSEnumerator *enumerator = [[self userObjects] objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id renderer = [[self class] retrieveRendererFromObject:object];
        if (renderer != nil)
            [_renderers addObject:renderer];
    }
}

- (id)renderers
{
    if (_renderers == nil)
        _renderers = [NSMutableArray new];
    return _renderers;
}

- (id)mutableUserObjects
{
    if (_userObjects == nil)
        _userObjects = [NSMutableArray new];
    return _userObjects;
}

// Each renderer draws with its object's transform, moved so the renderers'
// bounds start at the view origin unless origins are preserved, scaled to the
// view when scaling to fit, and centred in the rect when asked.
- (void)drawHyperRenderersInRect:(NSRect)aRect
{
    NSRect bounds = NSIntegralRect([self renderersBoundingRect]);
    NSEnumerator *enumerator = [[self renderers] objectEnumerator];
    id renderer;
    while ((renderer = [enumerator nextObject]) != nil) {
        [NSGraphicsContext saveGraphicsState];
        CGAffineTransform transform = [(id<HSGeometryAttributes>)[[renderer visualization] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
        if ([self isScaleToFit]) {
            CGFloat scaleX = [self bounds].size.width / bounds.size.width;
            CGFloat scaleY = [self bounds].size.height / bounds.size.height;
            transform.a *= scaleX;
            transform.b *= scaleY;
            transform.c *= scaleX;
            transform.d *= scaleY;
            transform.tx = (transform.tx - bounds.origin.x) * scaleX;
            transform.ty = (transform.ty - bounds.origin.y) * scaleY;
        } else if (![self shouldPreserveOrigins]) {
            transform.tx -= bounds.origin.x;
            transform.ty -= bounds.origin.y;
        }
        if ([self shouldBeCentered]) {
            transform.tx += (aRect.size.width - bounds.size.width) * 0.5;
            transform.ty += (aRect.size.height - bounds.size.height) * 0.5;
        }
        [[NSAffineTransform transformWithHyperCGAffineTransform:transform] concat];
        id region = [(HSMutableRegion *)[HSMutableRegion regionWithRect:aRect] applyAffineTransform:CGAffineTransformInvert(transform)];
        [renderer drawRegion:region withDelegate:[HSGenericRenderDelegate delegateWithDrawable:nil]];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (void)drawRect:(NSRect)aRect
{
    [(NSColor *)[self backgroundColor] set];
    [NSBezierPath fillRect:aRect];
    [self drawHyperRenderersInRect:aRect];
}

- (id)backgroundColor
{
    return _backgroundColor != nil ? _backgroundColor : [NSColor whiteColor];
}

- (void)setBackgroundColor:(id)aColor
{
    if ([self backgroundColor] == aColor)
        return;
    [_backgroundColor release];
    _backgroundColor = [aColor retain];
    [self setNeedsDisplay:YES];
}

// Returns an NSData of NSPoints, the offset of each user object's frame
// origin from the point (zero for an object without geometry).
- (id)offsetsFromPoint:(NSPoint)aPoint
{
    NSArray *objects = [self userObjects];
    NSUInteger count = [objects count];
    if (count == 0)
        return nil;
    NSUInteger length = count * sizeof(NSPoint);
    NSPoint *offsets = malloc(length);
    for (NSUInteger i = 0; i < count; i++) {
        id<HSGeometryAttributes> geometry = [[objects objectAtIndex:i] queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry == nil) {
            offsets[i] = NSMakePoint(NSZeroSize.width, NSZeroSize.height);
        } else {
            NSRect frame = [geometry frameBoundingRect];
            offsets[i] = NSMakePoint(frame.origin.x - aPoint.x, frame.origin.y - aPoint.y);
        }
    }
    return [NSData dataWithBytesNoCopy:offsets length:length freeWhenDone:YES];
}

- (NSRect)renderersBoundingRect
{
    NSRect rect = NSZeroRect;
    NSEnumerator *enumerator = [[self renderers] objectEnumerator];
    id renderer;
    while ((renderer = [enumerator nextObject]) != nil) {
        HSMutableRegion *region = [HSMutableRegion region];
        [renderer unionBoundingRegionWithRegion:region];
        id<HSGeometryAttributes> geometry = [[renderer visualization] queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry != nil)
            [region applyAffineTransform:[geometry affineTransform]];
        rect = NSUnionRect(rect, [region boundingRect]);
    }
    return rect;
}

- (void)visualAttributeDidChange:(id)aChange
{
    [self setNeedsDisplay:YES];
}

- (void)removeAllUserObjects
{
    [[[[_userObjects hyperObjectForAllInterfaces] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] removeAttributeObserver:self];
    [_userObjects removeAllObjects];
    [self hyperUpdateVisualObjectCount];
}

- (void)addUserObject:(id)aObject
{
    [[self mutableUserObjects] addObject:aObject];
    [[[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] addObserver:self selector:@selector(visualAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
    [self hyperUpdateVisualObjectCount];
}

- (id)userObjects
{
    return [self mutableUserObjects];
}

- (void)setShouldBeCentered:(BOOL)aCentered
{
    _shouldBeCentered = aCentered;
}

- (BOOL)shouldBeCentered
{
    return _shouldBeCentered;
}

- (void)setShouldPreserveOrigins:(BOOL)aOrigins
{
    _shouldPreserveOrigins = aOrigins;
}

- (BOOL)shouldPreserveOrigins
{
    return _shouldPreserveOrigins;
}

- (void)setScaleToFit:(BOOL)aFit
{
    if (_scaleToFit == aFit)
        return;
    _scaleToFit = aFit;
    [self setNeedsDisplay:YES];
}

- (BOOL)isScaleToFit
{
    return _scaleToFit;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)dealloc
{
    [_renderers release];
    [[[[_userObjects hyperObjectForAllInterfaces] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] removeAttributeObserver:self];
    [_userObjects release];
    [_presentationContext release];
    [_backgroundColor release];   // the original leaked the background colour
    [super dealloc];
}

@end
