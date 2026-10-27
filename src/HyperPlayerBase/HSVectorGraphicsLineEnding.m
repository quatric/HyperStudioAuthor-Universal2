#import "HSVectorGraphicsLineEnding.h"

// Relative tolerance used for the path cache keys.
static BOOL HSLineEndingNearlyEqual(float a, float b)
{
    float magnitude = MAX(a != 0 ? fabsf(a) : 1.0f, b != 0 ? fabsf(b) : 1.0f);
    return fabsf(a - b) <= magnitude * 0.0005f;
}

@implementation HSVectorGraphicsLineEnding
- (id)attributeObservingController
{
    return [[self hyperObject] attributeObservingController];
}
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObject:@"infoObjectKey"];
}
// Shared info objects are stored by name.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSString *infoKey = (_infoObject && [self infoObjectKey]) ? @"infoObjectKey" : @"infoObject";
    return [NSArray arrayWithObjects:infoKey, @"scale", nil];
}
- (void)setHyperInfoObject:(id)aObject
{
    if ([self hyperInfoObject] == aObject)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Line Ending" value:@"" table:@"UndoManager"]];
    [(HSVectorGraphicsLineEnding *)[[self undoManager] prepareWithInvocationTarget:self] setHyperInfoObject:[self hyperInfoObject]];
    [[self hyperObject] notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineEndingsInfoObjectAttribute) withUserInfo:nil];
    [self setInfoObject:aObject];
    [[self hyperObject] notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineEndingsInfoObjectAttribute) withUserInfo:nil];
}
- (void)setHyperScale:(NSInteger)aScale
{
    if ([self hyperScale] == aScale)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Line Ending Size" value:@"" table:@"UndoManager"]];
    [(HSVectorGraphicsLineEnding *)[[self undoManager] prepareWithInvocationTarget:self] setHyperScale:[self hyperScale]];
    [[self hyperObject] notifyChange:1 ofAttribute:@protocol(HSVectorGraphicsLineEndingScaleAttribute) withUserInfo:nil];
    [self setScale:aScale];
    [[self hyperObject] notifyChange:2 ofAttribute:@protocol(HSVectorGraphicsLineEndingScaleAttribute) withUserInfo:nil];
}
- (id)hyperInfoObject
{
    return _infoObject;
}
- (NSInteger)hyperScale
{
    return _scale;
}
- (void)setInfoObjectKey:(id)aKey
{
    [self setInfoObject:[[[HSVectorGraphicsLineEndingInfoObjectProvider sharedProvider] namedObjects] objectForKey:aKey]];
}
- (void)setInfoObject:(id)aObject
{
    if (_infoObject == aObject)
        return;
    [_infoObject releaseOwnerCount];
    [_infoObject autorelease];
    _infoObject = [aObject retain];
    [_infoObject retainOwnerCount];
    [self invalidateCache];
}
- (void)setScale:(NSInteger)aScale
{
    if (_scale != aScale) {
        _scale = (int)aScale;
        [self invalidateCache];
    }
}
- (BOOL)isFilled
{
    return [_infoObject isFilled];
}
- (id)path
{
    return [_infoObject path];
}
- (id)infoObjectKey
{
    return [[[[[_infoObject class] sharedProvider] namedObjects] allKeysForObject:_infoObject] extraFirstObject];
}
// The path is cached; a new point only translates it, a new angle, scale
// or inversion rebuilds it. The additional scale and inversion only key the
// cache, as in the original.
- (id)pathAtPoint:(NSPoint)aPoint angle:(CGFloat)aAngle additionalScale:(CGFloat)aScale isInverse:(BOOL)aInverse
{
    float angle = (float)aAngle;
    float additionalScale = (float)aScale;
    float x = (float)aPoint.x;
    float y = (float)aPoint.y;
    if (!HSLineEndingNearlyEqual(_additionalScale, additionalScale) || _isInverse != aInverse || !HSLineEndingNearlyEqual(_angle, angle))
        [self invalidateCache];
    if (!_cachedPath) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleBy:(float)_scale];
        [transform hyperPostrotateBy:(float)((double)angle + M_PI)];
        [transform hyperPosttranslateBy:NSMakeSize(x, y)];
        _cachedPath = [[transform transformBezierPath:[_infoObject path]] retain];
    } else if (!HSLineEndingNearlyEqual((float)_origin.x, x) || !HSLineEndingNearlyEqual((float)_origin.y, y)) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:x - _origin.x yBy:y - _origin.y];
        [_cachedPath transformUsingAffineTransform:transform];
    }
    _origin = NSMakePoint(x, y);
    _angle = angle;
    _additionalScale = additionalScale;
    _isInverse = aInverse;
    return _cachedPath;
}
- (id)undoManager
{
    return [[self hyperObject] undoManager];
}
- (id)hyperObject
{
    return [[self owner] hyperObjectForLineEnding:self];
}
// The owner is not retained.
- (void)setOwner:(id)aOwner
{
    if (_owner != aOwner)
        _owner = aOwner;
}
- (id)owner
{
    return _owner;
}
- (void)invalidateCache
{
    [_cachedPath release];
    _cachedPath = nil;
}
- (void)dealloc
{
    [_infoObject releaseOwnerCount];
    [_infoObject release];
    [_cachedPath release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self)
        _scale = 4;
    return self;
}
@end
