#import "HSGeometryNodeUnit.h"
#import "HSGenericGeometryBehaviorAdaptor.h"
#import "HSMutableGeometryAttributesImplementation.h"

// Positions within 1/256 point, and decomposed components within 0.00005,
// count as unchanged.
#define HSGeometryPositionTolerance 0.00390625
#define HSGeometryComponentTolerance 5e-05

// The components the transform decomposes into: scales along the x axis and
// perpendicular to it, skew, rotation and flips.
struct HSGeometryComponents {
    CGFloat horizontalScale;
    CGFloat verticalScale;
    CGFloat heightScale;
    CGFloat skewAngle;
    CGFloat rotationAngle;
    BOOL isFlippedVertically;
};

static BOOL HSGeometryValuesDiffer(CGFloat aValue, CGFloat aValue2, CGFloat aTolerance)
{
    return aValue < aValue2 - aTolerance || aValue2 + aTolerance < aValue;
}

// Into (-pi/2, pi/2), nudged one float step toward zero.
static CGFloat HSGeometrySkewAngle(CGAffineTransform aTransform)
{
    double angle = atan2(aTransform.a * aTransform.c + aTransform.b * aTransform.d, aTransform.a * aTransform.d - aTransform.b * aTransform.c);
    if (angle < -M_PI_2)
        angle += M_PI;
    else if (angle > M_PI_2)
        angle -= M_PI;
    return nextafterf((float)angle, 0.0f);
}

// In [0, 2pi), from the x axis (or the y axis when the x axis collapses).
static CGFloat HSGeometryRotationAngle(CGAffineTransform aTransform, BOOL aFlippedHorizontally)
{
    CGFloat angle;
    if (aTransform.a != 0 || aTransform.b != 0) {
        if (aFlippedHorizontally)
            angle = atan2f(-aTransform.b, -aTransform.a);
        else
            angle = atan2f(aTransform.b, aTransform.a);
    } else {
        if (aFlippedHorizontally)
            angle = atan2f(-aTransform.d, -aTransform.c) - M_PI_2;
        else
            angle = atan2f(aTransform.d, aTransform.c) - M_PI_2;
    }
    if (angle < 0)
        angle += 6.2831855f;
    return angle;
}

static struct HSGeometryComponents HSGeometryDecompose(CGAffineTransform aTransform, BOOL aFlippedHorizontally)
{
    struct HSGeometryComponents components;
    components.heightScale = hypotf(aTransform.c, aTransform.d);
    components.isFlippedVertically = aFlippedHorizontally;
    if (aTransform.a != 0 || aTransform.b != 0) {
        components.horizontalScale = hypotf(aTransform.a, aTransform.b);
        CGFloat determinant = aTransform.a * aTransform.d - aTransform.b * aTransform.c;
        if (determinant < 0)
            components.isFlippedVertically = !components.isFlippedVertically;
        components.verticalScale = fabs(determinant) / components.horizontalScale;
        components.skewAngle = HSGeometrySkewAngle(aTransform);
    } else {
        components.horizontalScale = 0;
        components.verticalScale = components.heightScale;
        components.skewAngle = 0;
    }
    components.rotationAngle = HSGeometryRotationAngle(aTransform, aFlippedHorizontally);
    return components;
}

static void HSGeometryGetMinimum(const NSPoint *aCorners, CGFloat *aMinX, CGFloat *aMinY)
{
    CGFloat minX = aCorners[0].x, minY = aCorners[0].y;
    for (NSUInteger i = 1; i < 4; i++) {
        minX = MIN(minX, aCorners[i].x);
        minY = MIN(minY, aCorners[i].y);
    }
    *aMinX = minX;
    *aMinY = minY;
}

// An object's geometry: an affine transform (with a horizontal flip flag) or,
// once distorted, four free corner positions. Both share the same storage.
@implementation HSGeometryNodeUnit

- (id)HSGeometryNodeUnit_allAttributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSGeometryAffinenessAttribute), @protocol(HSHorizontalFlipAttribute),
            @protocol(HSVerticalFlipAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute),
            @protocol(HSSkewAngleAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute),
            @protocol(HSRotationAngleAttribute), @protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute),
            @protocol(HSRelativeCornerPositionsAttribute), @protocol(HSAbsoluteCornerPositionsAttribute), nil];
}

- (void)setCornerPositions:(NSPoint *)aPositions
{
    if (aPositions == _geometry.cornerPositions)
        return;
    struct __HSCornerPositions positions;
    memcpy(positions.f0, aPositions, sizeof(positions.f0));
    [self HSGeometryNodeUnit_setCornerPositions:positions];
}

// Moving all corners together changes only the absolute positions; anything
// else also changes the relative ones. Leaving affine mode changes it all.
- (void)HSGeometryNodeUnit_setCornerPositions:(struct __HSCornerPositions)aPositions
{
    id attributes;
    if (!_isGeometryAffine) {
        BOOL same = YES;
        for (NSUInteger i = 0; i < 4 && same; i++)
            same = !HSGeometryValuesDiffer(aPositions.f0[i].x, _geometry.cornerPositions[i].x, HSGeometryPositionTolerance)
                && !HSGeometryValuesDiffer(aPositions.f0[i].y, _geometry.cornerPositions[i].y, HSGeometryPositionTolerance);
        if (same)
            return;
        attributes = [NSEMutableProtocolSet protocolSetWithProtocol:@protocol(HSAbsoluteCornerPositionsAttribute)];
        CGFloat oldMinX, oldMinY, newMinX, newMinY;
        HSGeometryGetMinimum(_geometry.cornerPositions, &oldMinX, &oldMinY);
        HSGeometryGetMinimum(aPositions.f0, &newMinX, &newMinY);
        BOOL moved = YES;
        for (NSUInteger i = 0; i < 4 && moved; i++)
            moved = !HSGeometryValuesDiffer(aPositions.f0[i].x - newMinX, _geometry.cornerPositions[i].x - oldMinX, HSGeometryPositionTolerance)
                && !HSGeometryValuesDiffer(aPositions.f0[i].y - newMinY, _geometry.cornerPositions[i].y - oldMinY, HSGeometryPositionTolerance);
        if (!moved)
            [attributes addProtocol:@protocol(HSRelativeCornerPositionsAttribute)];
    } else {
        attributes = [self HSGeometryNodeUnit_allAttributes];
    }
    if (attributes != nil)
        [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Transformation" value:@"" table:@"UndoManager"]];
    if (!_isGeometryAffine) {
        struct __HSCornerPositions oldPositions;
        memcpy(oldPositions.f0, _geometry.cornerPositions, sizeof(oldPositions.f0));
        [[undoManager prepareWithInvocationTarget:self] HSGeometryNodeUnit_setCornerPositions:oldPositions];
    } else {
        [[undoManager prepareWithInvocationTarget:self] setAffineTransform:_geometry.affine.transform flippedHorizontally:_geometry.affine.isFlippedHorizontally];
        _isGeometryAffine = NO;
    }
    memcpy(_geometry.cornerPositions, aPositions.f0, sizeof(aPositions.f0));
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

// Quirk kept: doesn't check for affine mode.
- (void)setPosition:(NSPoint)aPosition forCornerAtIndex:(NSUInteger)aIndex
{
    NSPoint old = _geometry.cornerPositions[aIndex];
    if (!HSGeometryValuesDiffer(aPosition.x, old.x, HSGeometryPositionTolerance) && !HSGeometryValuesDiffer(aPosition.y, old.y, HSGeometryPositionTolerance))
        return;
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSRelativeCornerPositionsAttribute), @protocol(HSAbsoluteCornerPositionsAttribute), nil];
    if (attributes != nil)
        [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Transformation" value:@"" table:@"UndoManager"]];
    [[undoManager prepareWithInvocationTarget:self] setPosition:old forCornerAtIndex:aIndex];
    _geometry.cornerPositions[aIndex] = aPosition;
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

// Notifies only the components that change; nothing changing does nothing.
- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally
{
    id attributes;
    if (!_isGeometryAffine) {
        attributes = [self HSGeometryNodeUnit_allAttributes];
    } else {
        attributes = [NSEMutableProtocolSet protocolSet];
        CGAffineTransform old = _geometry.affine.transform;
        BOOL oldFlipped = _geometry.affine.isFlippedHorizontally;
        struct HSGeometryComponents oldComponents = HSGeometryDecompose(old, oldFlipped);
        struct HSGeometryComponents newComponents = HSGeometryDecompose(aTransform, aHorizontally);
        if (aHorizontally != oldFlipped)
            [attributes addProtocol:@protocol(HSHorizontalFlipAttribute)];
        if (newComponents.isFlippedVertically != oldComponents.isFlippedVertically)
            [attributes addProtocol:@protocol(HSVerticalFlipAttribute)];
        if (HSGeometryValuesDiffer(newComponents.horizontalScale, oldComponents.horizontalScale, HSGeometryComponentTolerance))
            [attributes addProtocol:@protocol(HSHorizontalScaleAttribute)];
        if (HSGeometryValuesDiffer(newComponents.verticalScale, oldComponents.verticalScale, HSGeometryComponentTolerance))
            [attributes addProtocol:@protocol(HSVerticalScaleAttribute)];
        if (HSGeometryValuesDiffer(newComponents.skewAngle, oldComponents.skewAngle, HSGeometryComponentTolerance))
            [attributes addProtocol:@protocol(HSSkewAngleAttribute)];
        if (HSGeometryValuesDiffer(newComponents.horizontalScale, oldComponents.horizontalScale, HSGeometryComponentTolerance))
            [attributes addProtocol:@protocol(HSWidthScaleAttribute)];
        if (HSGeometryValuesDiffer(newComponents.heightScale, oldComponents.heightScale, HSGeometryComponentTolerance))
            [attributes addProtocol:@protocol(HSHeightScaleAttribute)];
        if (HSGeometryValuesDiffer(newComponents.rotationAngle, oldComponents.rotationAngle, HSGeometryComponentTolerance))
            [attributes addProtocol:@protocol(HSRotationAngleAttribute)];
        if (HSGeometryValuesDiffer(aTransform.tx, old.tx, HSGeometryPositionTolerance))
            [attributes addProtocol:@protocol(HSHorizontalOffsetAttribute)];
        if (HSGeometryValuesDiffer(aTransform.ty, old.ty, HSGeometryPositionTolerance))
            [attributes addProtocol:@protocol(HSVerticalOffsetAttribute)];
        if ([attributes count] == 0)
            return;
    }
    if (attributes != nil)
        [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Transformation" value:@"" table:@"UndoManager"]];
    if (!_isGeometryAffine) {
        // The original registered setCornerPositions: with a pointer to this
        // storage, which the transform then overwrote.
        struct __HSCornerPositions oldPositions;
        memcpy(oldPositions.f0, _geometry.cornerPositions, sizeof(oldPositions.f0));
        [[undoManager prepareWithInvocationTarget:self] HSGeometryNodeUnit_setCornerPositions:oldPositions];
        _isGeometryAffine = YES;
    } else {
        [[undoManager prepareWithInvocationTarget:self] setAffineTransform:_geometry.affine.transform flippedHorizontally:_geometry.affine.isFlippedHorizontally];
    }
    _geometry.affine.transform = aTransform;
    _geometry.affine.isFlippedHorizontally = aHorizontally;
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (void)setAffineTransform:(CGAffineTransform)aTransform
{
    [self setAffineTransform:aTransform flippedHorizontally:(_isGeometryAffine ? _geometry.affine.isFlippedHorizontally : NO)];
}

- (NSPoint *)cornerPositions
{
    return _geometry.cornerPositions;
}

- (NSSize)offset
{
    return NSMakeSize(_geometry.affine.transform.tx, _geometry.affine.transform.ty);
}

- (CGFloat)verticalOffset
{
    return _geometry.affine.transform.ty;
}

- (CGFloat)horizontalOffset
{
    return _geometry.affine.transform.tx;
}

- (CGFloat)rotationAngle
{
    return HSGeometryRotationAngle(_geometry.affine.transform, _geometry.affine.isFlippedHorizontally);
}

- (NSSize)sizeScale
{
    return NSMakeSize([self widthScale], [self heightScale]);
}

- (CGFloat)heightScale
{
    return hypotf(_geometry.affine.transform.c, _geometry.affine.transform.d);
}

- (CGFloat)widthScale
{
    return hypotf(_geometry.affine.transform.a, _geometry.affine.transform.b);
}

- (CGFloat)skewAngle
{
    return HSGeometrySkewAngle(_geometry.affine.transform);
}

- (NSSize)baseScale
{
    return NSMakeSize([self horizontalScale], [self verticalScale]);
}

- (CGFloat)verticalScale
{
    CGAffineTransform t = _geometry.affine.transform;
    if (t.a != 0 || t.b != 0)
        return fabs(t.d * t.a - t.c * t.b) / hypotf(t.a, t.b);
    return hypotf(t.c, t.d);
}

- (CGFloat)horizontalScale
{
    return hypotf(_geometry.affine.transform.a, _geometry.affine.transform.b);
}

- (BOOL)isFlippedVertically
{
    CGAffineTransform t = _geometry.affine.transform;
    return (_geometry.affine.isFlippedHorizontally != 0) != (t.a * t.d < t.b * t.c);
}

- (BOOL)isFlippedHorizontally
{
    return _isGeometryAffine ? _geometry.affine.isFlippedHorizontally : NO;
}

- (CGAffineTransform)affineTransform
{
    return _geometry.affine.transform;
}

- (BOOL)isGeometryAffine
{
    return _isGeometryAffine;
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSGeometryAttributes), aInterface) || HSProtocolsAreEqual(@protocol(HSMutableGeometryAttributes), aInterface))
        return [HSMutableGeometryAttributesImplementation class];
    if (HSProtocolsAreEqual(@protocol(HSGeometryBehaviorAdapting), aInterface))
        return [HSGenericGeometryBehaviorAdaptor class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSGeometryAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableGeometryAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSGeometryBehaviorAdapting), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSGeometryAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableGeometryAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSGeometryBehaviorAdapting)], nil];
}

- (id)attributes
{
    return [self HSGeometryNodeUnit_allAttributes];
}

// Quirk kept: stored corner positions are never read back.
- (void)setCornerPositionsAsArray:(id)aArray
{
}

- (id)cornerPositionsAsArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:8];
    for (NSUInteger i = 0; i < 4; i++) {
        [array addObject:[NSNumber numberWithDouble:_geometry.cornerPositions[i].x]];
        [array addObject:[NSNumber numberWithDouble:_geometry.cornerPositions[i].y]];
    }
    return array;
}

- (void)setIsFlippedHorizontally:(BOOL)aHorizontally
{
    if (_areCornerPositionsRead)
        return;
    _isGeometryAffine = YES;
    _geometry.affine.isFlippedHorizontally = aHorizontally;
}

- (void)setAffineTransformAsArray:(id)aArray
{
    if (_areCornerPositionsRead)
        return;
    _isGeometryAffine = YES;
    _geometry.affine.transform.a = [[aArray objectAtIndex:0] doubleValue];
    _geometry.affine.transform.b = [[aArray objectAtIndex:1] doubleValue];
    _geometry.affine.transform.c = [[aArray objectAtIndex:2] doubleValue];
    _geometry.affine.transform.d = [[aArray objectAtIndex:3] doubleValue];
    _geometry.affine.transform.tx = [[aArray objectAtIndex:4] doubleValue];
    _geometry.affine.transform.ty = [[aArray objectAtIndex:5] doubleValue];
}

// Corner geometry stores as a translation to its top left corner.
- (id)affineTransformAsArray
{
    if (!_isGeometryAffine) {
        CGFloat minX, minY;
        HSGeometryGetMinimum(_geometry.cornerPositions, &minX, &minY);
        return [NSArray arrayWithObjects:[NSNumber numberWithDouble:1], [NSNumber numberWithDouble:0], [NSNumber numberWithDouble:0],
                [NSNumber numberWithDouble:1], [NSNumber numberWithDouble:minX], [NSNumber numberWithDouble:minY], nil];
    }
    CGAffineTransform t = _geometry.affine.transform;
    return [NSArray arrayWithObjects:[NSNumber numberWithDouble:t.a], [NSNumber numberWithDouble:t.b], [NSNumber numberWithDouble:t.c],
            [NSNumber numberWithDouble:t.d], [NSNumber numberWithDouble:t.tx], [NSNumber numberWithDouble:t.ty], nil];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    _areCornerPositionsRead = NO;
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraLoadingWithCodingContext:aContext];
    if (!_isGeometryAffine)
        return keys;
    NSMutableArray *mutableKeys = [keys mutableCopy];
    [mutableKeys addObject:@"cornerPositionsAsArray"];
    keys = [[mutableKeys copy] autorelease];
    [mutableKeys release];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [[[super keysForExtraStoringWithCodingContext:aContext] mutableCopy] autorelease];
    [keys addObject:@"affineTransformAsArray"];
    [keys addObject:@"isFlippedHorizontally"];
    if (!_isGeometryAffine)
        [keys addObject:@"cornerPositionsAsArray"];
    return [[keys copy] autorelease];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSGeometryNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    if (_isGeometryAffine) {
        [copy setAffineTransform:_geometry.affine.transform flippedHorizontally:_geometry.affine.isFlippedHorizontally];
    } else {
        // The original copied corner geometry as a transform, losing a corner.
        struct __HSCornerPositions positions;
        memcpy(positions.f0, _geometry.cornerPositions, sizeof(positions.f0));
        [copy HSGeometryNodeUnit_setCornerPositions:positions];
    }
    return copy;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _isGeometryAffine = YES;
        _geometry.affine.transform.a = 1;
        _geometry.affine.transform.d = 1;
    }
    return self;
}

@end
