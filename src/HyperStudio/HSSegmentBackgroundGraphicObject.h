#import "HyperStudioPrefix.h"
#import "HSSegmentGraphicObject.h"


@interface HSSegmentBackgroundGraphicObject : HSSegmentGraphicObject
{
    float _firstGuider;
    float _guiderInterval;
}
- (void)drawInRect:(NSRect)aRect;
- (void)setGuiderInterval:(CGFloat)aInterval;
- (CGFloat)guiderInterval;
- (void)setFirstGuider:(CGFloat)aGuider;
- (CGFloat)firstGuider;
@end

