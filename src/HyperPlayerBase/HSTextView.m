#import "HSTextView.h"
@implementation HSTextView
- (void)erase:(id)aErase
{
    [self doCommandBySelector:@selector(selectAll:)];
    [self doCommandBySelector:@selector(deleteForward:)];
}
- (void)drawRect:(NSRect)aRect
{
    // background patterns start at the view's corner in window coordinates
    NSRect rect = [self convertRect:[self bounds] toView:nil];
    if ([self isFlipped])
        rect.origin.y += rect.size.height;
    [[NSGraphicsContext currentContext] setPatternPhase:rect.origin];
    [super drawRect:aRect];
}
@end
