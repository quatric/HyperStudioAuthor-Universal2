#import "NSCachedImageRep+HSExtensions.h"
@implementation NSCachedImageRep (HSExtensions)
- (id)initWithHyperContentOfView:(id)aView size:(NSSize)aSize flipped:(BOOL)aFlipped
{
    self = [self initWithSize:aSize depth:[NSWindow defaultDepthLimit] separate:YES alpha:YES];
    if (self != nil) {
        NSWindow *window = [self window];
        if (aFlipped) {
            HSVisualizationAuxiliaryView *contentView = [[[HSVisualizationAuxiliaryView alloc] init] autorelease];
            [contentView setHyperFlipped:YES];
            [window setContentView:contentView];
        }
        [window setOpaque:NO];
        [window setBackgroundColor:[NSColor clearColor]];
        [window disableCursorRects];
        [[window contentView] addSubview:aView];
        // drawing the cache window makes it key for a moment
        NSWindow *keyWindow = [NSApp keyWindow];
        [window becomeKeyWindow];
        [window displayIfNeeded];
        [keyWindow makeKeyWindow];
        [aView removeFromSuperviewWithoutNeedingDisplay];
    }
    return self;
}
@end
