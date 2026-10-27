#import "HyperStudioPrefix.h"


@interface HSBlueCircleSlider : NSSlider
{
    id _delegate;
}
+ (Class)cellClass;
- (void)mouseDown:(id)aDown;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)awakeFromNib;
@end

