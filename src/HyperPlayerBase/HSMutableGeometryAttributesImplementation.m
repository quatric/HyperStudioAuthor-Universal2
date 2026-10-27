#import "HSMutableGeometryAttributesImplementation.h"
#import "HSGeometryNodeUnit.h"

// The four corners of a size (bottom left, bottom right, top right, top left)
// put through a transform.
static void HSMutableGeometryGetCorners(NSPoint *aCorners, NSSize aSize, CGAffineTransform aTransform)
{
    aCorners[0] = NSMakePoint(0, 0);
    aCorners[1] = NSMakePoint(aSize.width, 0);
    aCorners[2] = NSMakePoint(aSize.width, aSize.height);
    aCorners[3] = NSMakePoint(0, aSize.height);
    for (int i = 0; i < 4; i++) {
        NSPoint corner = aCorners[i];
        aCorners[i].x = aTransform.a * corner.x + aTransform.c * corner.y + aTransform.tx;
        aCorners[i].y = aTransform.b * corner.x + aTransform.d * corner.y + aTransform.ty;
    }
}

static NSRect HSMutableGeometryBoundingRectOfCorners(const NSPoint *aCorners)
{
    CGFloat minX = aCorners[0].x, maxX = aCorners[0].x;
    CGFloat minY = aCorners[0].y, maxY = aCorners[0].y;
    for (int i = 1; i < 4; i++) {
        minX = MIN(minX, aCorners[i].x);
        maxX = MAX(maxX, aCorners[i].x);
        minY = MIN(minY, aCorners[i].y);
        maxY = MAX(maxY, aCorners[i].y);
    }
    return NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

// The geometry attributes of a node: its size from the node's standalone
// size attributes, its transform from a geometry node unit.
@implementation HSMutableGeometryAttributesImplementation

+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSGeometryNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}

- (id)attributeObservingController
{
    return _node;
}

// The point at the relative position (0-1) of the size stays in place.
- (void)setSize:(NSSize)aSize aboutRelativePoint:(NSPoint)aPoint
{
    if (_mutableSizeAttributes == nil)
        return;
    NSSize size = [_sizeAttributes size];
    CGAffineTransform transform = [_nodeUnit affineTransform];
    CGFloat dx = (size.width - aSize.width) * aPoint.x;
    CGFloat dy = (size.height - aSize.height) * aPoint.y;
    [_mutableSizeAttributes setSize:aSize];
    transform.tx += transform.a * dx + transform.c * dy;
    transform.ty += transform.b * dx + transform.d * dy;
    [_nodeUnit setAffineTransform:transform];
}

- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally
{
    [_mutableSizeAttributes setSize:aSize];
    [_nodeUnit setAffineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform
{
    [_mutableSizeAttributes setSize:aSize];
    [_nodeUnit setAffineTransform:aTransform];
}

- (void)setCornerPositions:(NSPoint *)aPositions
{
    [_nodeUnit setCornerPositions:aPositions];
}

// An affine geometry turns into corner positions with this one moved.
- (void)setPosition:(NSPoint)aPosition forCornerAtIndex:(NSUInteger)aIndex
{
    if (![_nodeUnit isGeometryAffine]) {
        [_nodeUnit setPosition:aPosition forCornerAtIndex:aIndex];
        return;
    }
    NSPoint corners[4];
    HSMutableGeometryGetCorners(corners, [_sizeAttributes size], [_nodeUnit affineTransform]);
    corners[aIndex] = aPosition;
    [_nodeUnit setCornerPositions:corners];
}

- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally
{
    [_nodeUnit setAffineTransform:aTransform flippedHorizontally:aHorizontally];
}

- (void)setAffineTransform:(CGAffineTransform)aTransform
{
    [_nodeUnit setAffineTransform:aTransform];
}

- (void)setSize:(NSSize)aSize
{
    [_mutableSizeAttributes setSize:aSize];
}

// Autoreleased storage for an affine geometry.
- (NSPoint *)cornerPositions
{
    if (![_nodeUnit isGeometryAffine])
        return [_nodeUnit cornerPositions];
    NSPoint corners[4];
    HSMutableGeometryGetCorners(corners, [_sizeAttributes size], [_nodeUnit affineTransform]);
    return (NSPoint *)[[NSData dataWithBytes:corners length:sizeof(corners)] bytes];
}

- (NSRect)frameBoundingRect
{
    if (![_nodeUnit isGeometryAffine])
        return HSMutableGeometryBoundingRectOfCorners([_nodeUnit cornerPositions]);
    NSPoint corners[4];
    HSMutableGeometryGetCorners(corners, [_sizeAttributes size], [_nodeUnit affineTransform]);
    return HSMutableGeometryBoundingRectOfCorners(corners);
}

- (NSSize)affineFrameSize
{
    NSSize size = [_sizeAttributes size];
    return NSMakeSize(size.width * [_nodeUnit widthScale], size.height * [_nodeUnit heightScale]);
}

- (CGFloat)affineFrameHeight
{
    return [_sizeAttributes size].height * [_nodeUnit heightScale];
}

- (CGFloat)affineFrameWidth
{
    return [_sizeAttributes size].width * [_nodeUnit widthScale];
}

- (NSSize)offset
{
    return [_nodeUnit offset];
}

- (CGFloat)verticalOffset
{
    return [_nodeUnit verticalOffset];
}

- (CGFloat)horizontalOffset
{
    return [_nodeUnit horizontalOffset];
}

- (CGFloat)rotationAngle
{
    return [_nodeUnit rotationAngle];
}

- (NSSize)sizeScale
{
    return [_nodeUnit sizeScale];
}

- (CGFloat)heightScale
{
    return [_nodeUnit heightScale];
}

- (CGFloat)widthScale
{
    return [_nodeUnit widthScale];
}

- (CGFloat)skewAngle
{
    return [_nodeUnit skewAngle];
}

- (NSSize)baseScale
{
    return [_nodeUnit baseScale];
}

- (CGFloat)verticalScale
{
    return [_nodeUnit verticalScale];
}

- (CGFloat)horizontalScale
{
    return [_nodeUnit horizontalScale];
}

- (BOOL)isFlippedVertically
{
    return [_nodeUnit isFlippedVertically];
}

- (BOOL)isFlippedHorizontally
{
    return [_nodeUnit isFlippedHorizontally];
}

- (CGAffineTransform)affineTransform
{
    return [_nodeUnit affineTransform];
}

- (BOOL)isGeometryAffine
{
    return [_nodeUnit isGeometryAffine];
}

- (NSRect)boundingRect
{
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = [_sizeAttributes size];
    return rect;
}

- (NSSize)size
{
    return [_sizeAttributes size];
}

- (NSSize)defaultSize
{
    return [_sizeAttributes defaultSize];
}

- (CGFloat)height
{
    return [_sizeAttributes height];
}

- (CGFloat)width
{
    return [_sizeAttributes width];
}

- (id)hyperObject
{
    return _node;
}

- (id)nodeUnit
{
    return _nodeUnit;
}

- (id)node
{
    return _node;
}

- (void)dealloc
{
    [(id)_sizeAttributes release];
    [(id)_mutableSizeAttributes release];
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}

// Nil for a node without standalone size attributes.
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self == nil)
        return nil;
    _sizeAttributes = [[aNode queryHyperInterface:@protocol(HSStandaloneSizeAttributes)] retain];
    if (_sizeAttributes == nil) {
        [self release];
        return nil;
    }
    _node = [aNode retain];
    _nodeUnit = [aUnit retain];
    _mutableSizeAttributes = [[aNode queryHyperInterface:@protocol(HSStandaloneMutableSizeAttributes)] retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
