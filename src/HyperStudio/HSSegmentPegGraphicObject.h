#import "HyperStudioPrefix.h"
#import "HSSegmentGraphicObject.h"


@interface HSSegmentPegGraphicObject : HSSegmentGraphicObject
{
    double _time;
    BOOL _isHidden;
}
- (void)drawInRect:(NSRect)aRect;
- (BOOL)hitTest:(NSPoint)aTest;
- (void)setHidden:(BOOL)aHidden;
- (BOOL)isHidden;
- (void)setTime:(double)aTime;
- (double)time;
@end

