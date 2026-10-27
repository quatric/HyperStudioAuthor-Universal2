#import "HSMutableRegion.h"
#import "CGERegion.h"

@implementation HSRegion

+ (id)regionWithIntersectionOfRegion:(id)aRegion andRegion:(id)aRegion2
{
    return [[self region] HSRegion_postInitWithRegion:CGERegionCreateMutableIntersection([aRegion HSRegion_region], [aRegion2 HSRegion_region])];
}

+ (id)regionWithLineFromPoint:(NSPoint)aPoint toPoint:(NSPoint)aPoint2 strokeThickness:(CGFloat)aThickness
{
    NSRect rect = NSMakeRect(MIN(aPoint.x, aPoint2.x), MIN(aPoint.y, aPoint2.y),
                             fabs(aPoint.x - aPoint2.x), fabs(aPoint.y - aPoint2.y));
    return [self regionWithRect:NSInsetRect(rect, -aThickness, -aThickness)];
}

+ (id)regionWithRectOutline:(NSRect)aOutline strokeThickness:(CGFloat)aThickness
{
    // Four zero-width edge rects, each grown by the stroke thickness.
    NSRect edges[4] = {
        NSMakeRect(aOutline.origin.x, aOutline.origin.y, 0.0, aOutline.size.height),
        NSMakeRect(aOutline.origin.x + aOutline.size.width, aOutline.origin.y, 0.0, aOutline.size.height),
        NSMakeRect(aOutline.origin.x, aOutline.origin.y, aOutline.size.width, 0.0),
        NSMakeRect(aOutline.origin.x, aOutline.origin.y + aOutline.size.height, aOutline.size.width, 0.0),
    };
    for (int i = 0; i < 4; i++)
        edges[i] = NSInsetRect(edges[i], -aThickness, -aThickness);
    CGEMutableRegionRef region = CGERegionCreateMutable();
    for (int i = 0; i < 4; i++)
        CGERegionAddRect(region, NSRectToCGRect(edges[i]));
    return [[self region] HSRegion_postInitWithRegion:region];
}

+ (id)regionWithRectValues:(id)aValues
{
    CGEMutableRegionRef region = CGERegionCreateMutable();
    NSEnumerator *enumerator = [aValues objectEnumerator];
    id value;
    while ((value = [enumerator nextObject]) != nil)
        CGERegionAddRect(region, NSRectToCGRect([value rectValue]));
    return [[self region] HSRegion_postInitWithRegion:region];
}

+ (id)regionWithCGERegion:(struct CGERegion *)aRegion
{
    return [[self region] HSRegion_postInitWithRegion:CGERegionCreateMutableCopy(aRegion)];
}

+ (id)regionWithRect:(NSRect)aRect
{
    CGEMutableRegionRef region = CGERegionCreateMutable();
    CGERegionAddRect(region, NSRectToCGRect(aRect));
    return [[self region] HSRegion_postInitWithRegion:region];
}

+ (id)region
{
    return [[[self alloc] init] autorelease];
}

- (void)show
{
    CGERegionShow(_region);
}

- (id)rectApproximation
{
    return [(id)CGERegionCopyRectApproximation(_region) autorelease];
}

- (NSRect)boundingRect
{
    return NSRectFromCGRect(CGERegionGetBoundingRect(_region));
}

- (BOOL)intersectsRegion:(id)aRegion
{
    return CGERegionIntersectsRegion(_region, [aRegion HSRegion_region]);
}

- (BOOL)intersectsCGERegion:(struct CGERegion *)aRegion
{
    return CGERegionIntersectsRegion(_region, aRegion);
}

- (BOOL)intersectsRect:(NSRect)aRect
{
    return CGERegionIntersectsRect(_region, NSRectToCGRect(aRect));
}

- (BOOL)isEmpty
{
    return CGERegionIsEmpty(_region);
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSRegion class]])
        return NO;
    return [self isEqualToRegion:aEqual];
}

- (BOOL)isEqualToRegion:(id)aRegion
{
    if (self == aRegion)
        return YES;
    // Let a more specific subclass decide.
    if ([aRegion isKindOfClass:[self class]] && ![aRegion isMemberOfClass:[self class]])
        return [aRegion isEqualToRegion:self];
    return CGERegionEqualToRegion(_region, [aRegion HSRegion_region]);
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[[HSMutableRegion allocWithZone:aZone] init] HSRegion_postInitWithRegion:CGERegionCreateMutableCopy(_region)];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}

- (void)dealloc
{
    CGERegionRelease(_region);
    [super dealloc];
}

- (struct CGERegion *)HSRegion_mutableRegionForExpanding
{
    if (_region == NULL)
        _region = CGERegionCreateMutable();
    return _region;
}

- (struct CGERegion *)HSRegion_region
{
    return _region;
}

- (id)HSRegion_postInitWithRegion:(struct CGERegion *)aRegion
{
    _region = aRegion;
    return self;
}

@end

@implementation HSMutableRegion

- (id)applyAffineTransform:(CGAffineTransform)aTransform
{
    CGERegionApplyAffineTransform([self HSRegion_region], aTransform);
    return self;
}

- (id)intersectRegion:(id)aRegion
{
    CGERegionIntersectRegion([self HSRegion_region], [aRegion HSRegion_region]);
    return self;
}

- (id)intersectCGERegion:(struct CGERegion *)aRegion
{
    CGERegionIntersectRegion([self HSRegion_region], aRegion);
    return self;
}

- (id)intersectRect:(NSRect)aRect
{
    CGERegionIntersectRect([self HSRegion_region], NSRectToCGRect(aRect));
    return self;
}

- (id)addRegion:(id)aRegion
{
    CGERegionAddRegion([self HSRegion_mutableRegionForExpanding], [aRegion HSRegion_region]);
    return self;
}

- (id)addCGERegion:(struct CGERegion *)aRegion
{
    CGERegionAddRegion([self HSRegion_mutableRegionForExpanding], aRegion);
    return self;
}

- (id)addRect:(NSRect)aRect
{
    CGERegionAddRect([self HSRegion_mutableRegionForExpanding], NSRectToCGRect(aRect));
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[[[self class] allocWithZone:aZone] init] HSRegion_postInitWithRegion:CGERegionCreateMutableCopy([self HSRegion_region])];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[HSRegion allocWithZone:aZone] init] HSRegion_postInitWithRegion:CGERegionCreateMutableCopy([self HSRegion_region])];
}

@end
