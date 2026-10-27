#import "HyperStudioPrefix.h"
#import "HSSegmentGraphicObject.h"


@interface HSSegmentSelectionGraphicObject : HSSegmentGraphicObject
{
    BOOL _leftEdgeRounded;
    BOOL _rightEdgeRounded;
}
- (void)drawInRect:(NSRect)aRect;
- (void)setRightEdgeRounded:(BOOL)aRounded;
- (void)setLeftEdgeRounded:(BOOL)aRounded;
@end

