#import "HyperPlayerBasePrefix.h"


@interface HSClipView : NSClipView
{
    BOOL _isScrollingDisabled;
}
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (void)ownFrameChanged:(id)aChanged;
- (void)setScrollable:(BOOL)aScrollable;
- (BOOL)isScrollable;
- (NSPoint)constrainScrollPoint:(NSPoint)aPoint;
- (void)dealloc;
@end

