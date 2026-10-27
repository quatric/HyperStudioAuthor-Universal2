#import "HyperStudioPrefix.h"


@interface HSSlider : NSSlider
{
    id _delegate;
}
+ (Class)cellClass;
- (void)mouseDown:(id)aDown;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)awakeFromNib;
@end

