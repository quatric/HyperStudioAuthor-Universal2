#import "HyperPlayerBasePrefix.h"
#import "HSTintedView.h"


@interface HSOldstyleButtonBackgroundView : HSTintedView
{
    BOOL _rendersAsDefaultButton;
}
- (void)drawRect:(NSRect)aRect;
- (void)setRendersAsDefaultButton:(BOOL)aButton;
- (BOOL)rendersAsDefaultButton;
@end

