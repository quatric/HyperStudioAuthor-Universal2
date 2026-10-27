#import "HyperStudioPrefix.h"
#import "HSSegmentGraphicObject.h"


@interface HSSegmentGuiderGraphicObject : HSSegmentGraphicObject
{
    double _time;
}
- (void)drawInRect:(NSRect)aRect;
- (BOOL)hitTest:(NSPoint)aTest;
- (void)setTime:(double)aTime;
- (double)time;
@end

