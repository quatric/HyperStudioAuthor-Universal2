#import "HSCenteredScrollView.h"
@implementation HSCenteredScrollView
- (void)reflectScrolledClipView:(id)aView
{
    if ([self contentView] == aView)
        [self centerDocumentView];
    [super reflectScrolledClipView:aView];
}
- (void)centerDocumentView
{
    // a document smaller than the clip view sits in its middle
    NSRect bounds = [[self contentView] bounds];
    NSRect frame = [[self documentView] frame];
    if (frame.size.width < bounds.size.width)
        bounds.origin.x = frame.origin.x - floor((bounds.size.width - frame.size.width) * 0.5);
    if (frame.size.height < bounds.size.height)
        bounds.origin.y = frame.origin.y - floor((bounds.size.height - frame.size.height) * 0.5);
    [[self contentView] scrollToPoint:bounds.origin];
}
@end
