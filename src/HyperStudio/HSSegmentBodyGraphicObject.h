#import "HyperStudioPrefix.h"
#import "HSSegmentGraphicObject.h"


@interface HSSegmentBodyGraphicObject : HSSegmentGraphicObject
{
    double _startValue;
    double _endValue;
}
- (void)drawInRect:(NSRect)aRect;
- (void)setEndValue:(double)aValue;
- (double)endValue;
- (void)setStartValue:(double)aValue;
- (double)startValue;
@end

