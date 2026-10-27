#import "NSAffineTransform+HSKeyValueCoding.h"

// Relative comparison: values within 0.05% of the larger magnitude (zero
// counting as 1) are equal.
static BOOL HSAffineTransformValuesEqual(CGFloat a, CGFloat b)
{
    CGFloat magnitudeA = a != 0.0 ? fabs(a) : 1.0;
    CGFloat magnitudeB = b != 0.0 ? fabs(b) : 1.0;
    CGFloat magnitude = magnitudeB <= magnitudeA ? magnitudeA : magnitudeB;
    return fabs(a - b) <= magnitude * 0.0005;
}

// Stored as the class name and the six matrix values.
@implementation NSAffineTransform (HSKeyValueCoding)

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}

- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    NSAffineTransformStruct matrix = [self transformStruct];
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), EXClassNameKey,
        [NSNumber numberWithDouble:matrix.m11], @"m11",
        [NSNumber numberWithDouble:matrix.m12], @"m12",
        [NSNumber numberWithDouble:matrix.m21], @"m21",
        [NSNumber numberWithDouble:matrix.m22], @"m22",
        [NSNumber numberWithDouble:matrix.tX], @"tX",
        [NSNumber numberWithDouble:matrix.tY], @"tY", nil];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSAffineTransformStruct matrix;
    matrix.m11 = [[aRepresentation objectForKey:@"m11"] doubleValue];
    matrix.m12 = [[aRepresentation objectForKey:@"m12"] doubleValue];
    matrix.m21 = [[aRepresentation objectForKey:@"m21"] doubleValue];
    matrix.m22 = [[aRepresentation objectForKey:@"m22"] doubleValue];
    matrix.tX = [[aRepresentation objectForKey:@"tX"] doubleValue];
    matrix.tY = [[aRepresentation objectForKey:@"tY"] doubleValue];
    [self setTransformStruct:matrix];
}

@end

// The "post" methods append (applied after this transform), the "pre" ones
// prepend; all of them change and return the receiver.
@implementation NSAffineTransform (HSExtendedAffineTransform)

+ (id)transformWithHyperString:(id)aString
{
    return [[[self alloc] initWithHyperString:aString] autorelease];
}

+ (id)transformWithHyperCGAffineTransform:(CGAffineTransform)aTransform
{
    return [[[self alloc] initWithHyperCGAffineTransform:aTransform] autorelease];
}

+ (id)transformWithHyperTransformStruct:(struct HyperPlayerBase_anon1)aStruct
{
    return [[[self alloc] initWithHyperTransformStruct:aStruct] autorelease];
}

+ (id)hyperTransitionFromRect:(NSRect)aRect toRect:(NSRect)aRect2
{
    return [[[self alloc] initWithHyperTransitionFromRect:aRect toRect:aRect2] autorelease];
}

+ (id)hyperYFlipInRect:(NSRect)aRect
{
    return [[[self alloc] initWithHyperFlipYInRect:aRect] autorelease];
}

+ (id)hyperXFlipInRect:(NSRect)aRect
{
    return [[[self alloc] initWithHyperFlipXInRect:aRect] autorelease];
}

+ (id)hyperYFlipWithHeight:(CGFloat)aHeight
{
    return [[[self alloc] initWithHyperFlipYWithHeight:aHeight] autorelease];
}

+ (id)hyperXFlipWithWidth:(CGFloat)aWidth
{
    return [[[self alloc] initWithHyperFlipXWithWidth:aWidth] autorelease];
}

+ (id)hyperRotationBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint
{
    return [[[self alloc] initWithHyperRotationBy:aBy aboutPoint:aPoint] autorelease];
}

+ (id)hyperRotationBy:(CGFloat)aBy
{
    return [[[self alloc] initWithHyperRotationBy:aBy] autorelease];
}

+ (id)hyperScalingBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint
{
    return [[[self alloc] initWithHyperScalingBy:aBy aboutPoint:aPoint] autorelease];
}

+ (id)hyperScalingBy:(NSSize)aBy
{
    return [[[self alloc] initWithHyperScalingBy:aBy] autorelease];
}

+ (id)hyperTranslationBy:(NSSize)aBy
{
    return [[[self alloc] initWithHyperTranslationBy:aBy] autorelease];
}

- (void)setHyperCGAffineTransform:(CGAffineTransform)aTransform
{
    NSAffineTransformStruct matrix = {aTransform.a, aTransform.b, aTransform.c, aTransform.d, aTransform.tx, aTransform.ty};
    [self setTransformStruct:matrix];
}

- (CGAffineTransform)hyperCGAffineTransform
{
    NSAffineTransformStruct matrix = [self transformStruct];
    return CGAffineTransformMake(matrix.m11, matrix.m12, matrix.m21, matrix.m22, matrix.tX, matrix.tY);
}

// Scales the transform back to 1; returns the scale it had.
- (NSSize)hyperRemoveScale
{
    NSSize scale = [self hyperScaleFactor];
    [self hyperPrescaleBy:NSMakeSize(scale.width != 0.0 ? 1.0 / scale.width : 1.0, scale.height != 0.0 ? 1.0 / scale.height : 1.0)];
    return scale;
}

// Zero scales count as 1.
- (NSSize)hyperInverseScaleFactor
{
    NSSize scale = [self hyperScaleFactor];
    return NSMakeSize(scale.width != 0.0 ? 1.0 / scale.width : 1.0, scale.height != 0.0 ? 1.0 / scale.height : 1.0);
}

- (NSSize)hyperScaleFactor
{
    NSAffineTransformStruct matrix = [self transformStruct];
    return NSMakeSize(hypot(matrix.m11, matrix.m12), hypot(matrix.m21, matrix.m22));
}

// The bounds of the transformed corners.
- (NSRect)hyperTransformAndBoundRect:(NSRect)aRect
{
    NSPoint corners[4] = {
        aRect.origin,
        NSMakePoint(NSMaxX(aRect), aRect.origin.y),
        NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)),
        NSMakePoint(aRect.origin.x, NSMaxY(aRect)),
    };
    [self hyperTransformPoints:corners count:4];
    CGFloat minX = corners[0].x, maxX = corners[0].x, minY = corners[0].y, maxY = corners[0].y;
    for (int i = 1; i < 4; i++) {
        minX = MIN(minX, corners[i].x);
        maxX = MAX(maxX, corners[i].x);
        minY = MIN(minY, corners[i].y);
        maxY = MAX(maxY, corners[i].y);
    }
    return NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

- (void)hyperTransformPoints:(NSPoint *)aPoints count:(NSUInteger)aCount
{
    for (NSUInteger i = 0; i < aCount; i++)
        aPoints[i] = [self transformPoint:aPoints[i]];
}

- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    NSAffineTransformStruct a = [self transformStruct];
    NSAffineTransformStruct b = [aEqual transformStruct];
    return HSAffineTransformValuesEqual(a.m11, b.m11) && HSAffineTransformValuesEqual(a.m12, b.m12)
        && HSAffineTransformValuesEqual(a.m21, b.m21) && HSAffineTransformValuesEqual(a.m22, b.m22)
        && HSAffineTransformValuesEqual(a.tX, b.tX) && HSAffineTransformValuesEqual(a.tY, b.tY);
}

- (id)hyperPostmultiplyBy:(id)aBy
{
    [self appendTransform:aBy];
    return self;
}

- (id)hyperPremultiplyBy:(id)aBy
{
    [self prependTransform:aBy];
    return self;
}

// A new, autoreleased inverse.
- (id)hyperInverseTransform
{
    NSAffineTransform *inverse = [[self copy] autorelease];
    [inverse invert];
    return inverse;
}

- (id)hyperInvert
{
    [self invert];
    return self;
}

- (id)hyperPostflipYInRect:(NSRect)aRect
{
    [self appendTransform:[NSAffineTransform hyperYFlipInRect:aRect]];
    return self;
}

- (id)hyperPostflipXInRect:(NSRect)aRect
{
    [self appendTransform:[NSAffineTransform hyperXFlipInRect:aRect]];
    return self;
}

- (id)hyperPreflipYInRect:(NSRect)aRect
{
    [self prependTransform:[NSAffineTransform hyperYFlipInRect:aRect]];
    return self;
}

- (id)hyperPreflipXInRect:(NSRect)aRect
{
    [self prependTransform:[NSAffineTransform hyperXFlipInRect:aRect]];
    return self;
}

- (id)hyperPostflipYWithHeight:(CGFloat)aHeight
{
    [self appendTransform:[NSAffineTransform hyperYFlipWithHeight:aHeight]];
    return self;
}

- (id)hyperPostflipXWithWidth:(CGFloat)aWidth
{
    [self appendTransform:[NSAffineTransform hyperXFlipWithWidth:aWidth]];
    return self;
}

- (id)hyperPreflipYWithHeight:(CGFloat)aHeight
{
    [self prependTransform:[NSAffineTransform hyperYFlipWithHeight:aHeight]];
    return self;
}

- (id)hyperPreflipXWithWidth:(CGFloat)aWidth
{
    [self prependTransform:[NSAffineTransform hyperXFlipWithWidth:aWidth]];
    return self;
}

- (id)hyperPostrotateBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint
{
    [self appendTransform:[NSAffineTransform hyperRotationBy:aBy aboutPoint:aPoint]];
    return self;
}

- (id)hyperPrerotateBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint
{
    [self prependTransform:[NSAffineTransform hyperRotationBy:aBy aboutPoint:aPoint]];
    return self;
}

- (id)hyperPostrotateBy:(CGFloat)aBy
{
    [self appendTransform:[NSAffineTransform hyperRotationBy:aBy]];
    return self;
}

- (id)hyperPrerotateBy:(CGFloat)aBy
{
    [self rotateByRadians:aBy];
    return self;
}

- (id)hyperPostscaleBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint
{
    [self appendTransform:[NSAffineTransform hyperScalingBy:aBy aboutPoint:aPoint]];
    return self;
}

- (id)hyperPrescaleBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint
{
    [self prependTransform:[NSAffineTransform hyperScalingBy:aBy aboutPoint:aPoint]];
    return self;
}

- (id)hyperPostscaleBy:(NSSize)aBy
{
    [self appendTransform:[NSAffineTransform hyperScalingBy:aBy]];
    return self;
}

- (id)hyperPrescaleBy:(NSSize)aBy
{
    [self scaleXBy:aBy.width yBy:aBy.height];
    return self;
}

- (id)hyperPosttranslateBy:(NSSize)aBy
{
    [self appendTransform:[NSAffineTransform hyperTranslationBy:aBy]];
    return self;
}

- (id)hyperPretranslateBy:(NSSize)aBy
{
    [self translateXBy:aBy.width yBy:aBy.height];
    return self;
}

// Six space-separated values (m11 m12 m21 m22 tX tY); any other count gives
// the identity.
- (id)initWithHyperString:(id)aString
{
    self = [self init];
    if (aString == nil) {
        [self release];
        return nil;
    }
    NSArray *values = [aString componentsSeparatedByString:@" "];
    if ([values count] == 6) {
        NSAffineTransformStruct matrix;
        matrix.m11 = [[values objectAtIndex:0] floatValue];
        matrix.m12 = [[values objectAtIndex:1] floatValue];
        matrix.m21 = [[values objectAtIndex:2] floatValue];
        matrix.m22 = [[values objectAtIndex:3] floatValue];
        matrix.tX = [[values objectAtIndex:4] floatValue];
        matrix.tY = [[values objectAtIndex:5] floatValue];
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperCGAffineTransform:(CGAffineTransform)aTransform
{
    self = [self init];
    [self setHyperCGAffineTransform:aTransform];
    return self;
}

// The i386 (float) transform struct.
- (id)initWithHyperTransformStruct:(struct HyperPlayerBase_anon1)aStruct
{
    self = [self init];
    NSAffineTransformStruct matrix = {aStruct.f0, aStruct.f1, aStruct.f2, aStruct.f3, aStruct.f4, aStruct.f5};
    [self setTransformStruct:matrix];
    return self;
}

// Maps aRect onto aRect2.
- (id)initWithHyperTransitionFromRect:(NSRect)aRect toRect:(NSRect)aRect2
{
    self = [self init];
    if (self != nil) {
        CGFloat scaleX = aRect2.size.width / aRect.size.width;
        CGFloat scaleY = aRect2.size.height / aRect.size.height;
        NSAffineTransformStruct matrix = {scaleX, 0.0, 0.0, scaleY, aRect2.origin.x - aRect.origin.x * scaleX, aRect2.origin.y - aRect.origin.y * scaleY};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperFlipYInRect:(NSRect)aRect
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {1.0, 0.0, 0.0, -1.0, 0.0, aRect.origin.y + aRect.origin.y + aRect.size.height};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperFlipXInRect:(NSRect)aRect
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {-1.0, 0.0, 0.0, 1.0, aRect.origin.x + aRect.origin.x + aRect.size.width, 0.0};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperFlipYWithHeight:(CGFloat)aHeight
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {1.0, 0.0, 0.0, -1.0, 0.0, aHeight};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperFlipXWithWidth:(CGFloat)aWidth
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {-1.0, 0.0, 0.0, 1.0, aWidth, 0.0};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperRotationBy:(CGFloat)aBy aboutPoint:(NSPoint)aPoint
{
    self = [self init];
    if (self != nil) {
        CGFloat sine = sin(aBy), cosine = cos(aBy);
        NSAffineTransformStruct matrix = {cosine, sine, -sine, cosine,
            aPoint.x - cosine * aPoint.x + sine * aPoint.y, aPoint.y - sine * aPoint.x - cosine * aPoint.y};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperRotationBy:(CGFloat)aBy
{
    self = [self init];
    if (self != nil) {
        CGFloat sine = sin(aBy), cosine = cos(aBy);
        NSAffineTransformStruct matrix = {cosine, sine, -sine, cosine, 0.0, 0.0};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperScalingBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {aBy.width, 0.0, 0.0, aBy.height, (1.0 - aBy.width) * aPoint.x, (1.0 - aBy.height) * aPoint.y};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperScalingBy:(NSSize)aBy
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {aBy.width, 0.0, 0.0, aBy.height, 0.0, 0.0};
        [self setTransformStruct:matrix];
    }
    return self;
}

- (id)initWithHyperTranslationBy:(NSSize)aBy
{
    self = [self init];
    if (self != nil) {
        NSAffineTransformStruct matrix = {1.0, 0.0, 0.0, 1.0, aBy.width, aBy.height};
        [self setTransformStruct:matrix];
    }
    return self;
}

@end
