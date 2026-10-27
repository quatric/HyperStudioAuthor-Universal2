#import "HyperPlayerBasePrefix.h"


@interface HSScroller : NSScroller
{
}
- (void)trackScrollButtons:(id)aButtons;
- (void)trackKnob:(id)aKnob;
- (id)enclosingHyperScrollView;
@end

