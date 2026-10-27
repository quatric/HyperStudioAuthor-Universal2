#import "HyperStudioPrefix.h"


@interface HSSpinCell : NSButtonCell
{
    BOOL _isContinious;
    int _prevHotZone;
}
+ (BOOL)prefersTrackingUntilMouseUp;
- (NSInteger)hitZoneForPoint:(NSPoint)aPoint;
- (id)segmentImageForZone:(NSInteger)aZone;
- (id)spinImage;
- (NSPoint)segmentOriginForZone:(NSInteger)aZone;
- (void)performClick:(id)aClick;
- (void)moveDown:(id)aDown;
- (void)moveUp:(id)aUp;
- (void)moveLeft:(id)aLeft;
- (void)moveRight:(id)aRight;
- (void)setIntValue:(int)aValue;
- (int)intValue;
- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp;
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView;
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (BOOL)isOpaque;
- (id)init;
@end

