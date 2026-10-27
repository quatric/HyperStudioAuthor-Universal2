#import "HyperPlayerBasePrefix.h"


@interface HSRegion : NSObject <NSCopying, NSMutableCopying>
{
    struct CGERegion *_region;
}
+ (id)regionWithIntersectionOfRegion:(id)aRegion andRegion:(id)aRegion2;
+ (id)regionWithLineFromPoint:(NSPoint)aPoint toPoint:(NSPoint)aPoint2 strokeThickness:(CGFloat)aThickness;
+ (id)regionWithRectOutline:(NSRect)aOutline strokeThickness:(CGFloat)aThickness;
+ (id)regionWithRectValues:(id)aValues;
+ (id)regionWithCGERegion:(struct CGERegion *)aRegion;
+ (id)regionWithRect:(NSRect)aRect;
+ (id)region;
- (void)show;
- (id)rectApproximation;
- (NSRect)boundingRect;
- (BOOL)intersectsRegion:(id)aRegion;
- (BOOL)intersectsCGERegion:(struct CGERegion *)aRegion;
- (BOOL)intersectsRect:(NSRect)aRect;
- (BOOL)isEmpty;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)isEqualToRegion:(id)aRegion;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (struct CGERegion *)HSRegion_mutableRegionForExpanding;
- (struct CGERegion *)HSRegion_region;
- (id)HSRegion_postInitWithRegion:(struct CGERegion *)aRegion;
@end

@interface HSMutableRegion : HSRegion
{
}
- (id)applyAffineTransform:(CGAffineTransform)aTransform;
- (id)intersectRegion:(id)aRegion;
- (id)intersectCGERegion:(struct CGERegion *)aRegion;
- (id)intersectRect:(NSRect)aRect;
- (id)addRegion:(id)aRegion;
- (id)addCGERegion:(struct CGERegion *)aRegion;
- (id)addRect:(NSRect)aRect;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
@end

