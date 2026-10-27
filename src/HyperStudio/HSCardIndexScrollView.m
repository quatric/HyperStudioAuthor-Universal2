#import "HSCardIndexScrollView.h"

@implementation HSCardIndexScrollView

- (void)scrollDownAction:(id)aAction
{
    NSRect visibleRect = [[self mediaStripView] visibleRect];
    NSUInteger index = [[self mediaStripView] indexOfItemAtPoint:visibleRect.origin];

    if (index != NSNotFound) {
        NSUInteger count = [[self mediaStripView] numberOfItems];
        index++;
        if (index >= count)
            [[self mediaStripView] scrollToBottom];
        else
            [[self mediaStripView] scrollItemAtIndexToTop:index];
    }
}

- (void)scrollUpAction:(id)aAction
{
    NSRect visibleRect = [[self mediaStripView] visibleRect];
    NSUInteger index = [[self mediaStripView] indexOfItemAtPoint:visibleRect.origin];

    if (index == NSNotFound)
        index = [[self mediaStripView] numberOfItems];
    [[self mediaStripView] scrollItemAtIndexToTop:index == 0 ? 0 : index - 1];
}

- (id)mediaStripView
{
    return [self documentView];
}

- (void)customizeAppearance
{
    NSScroller *scroller = [[[HSCardIndexSimpleVerticalScroller alloc] initWithScrollView:self] autorelease];

    [scroller setControlSize:NSControlSizeSmall];
    [self setVerticalScroller:scroller];
    [self setHorizontalScroller:nil];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        [self setDocumentView:[[[HSMediaStripView alloc] initWithFrame:[self bounds]] autorelease]];
        [[self documentView] setStripWidth:[self bounds].size.width - [NSScroller scrollerWidthForControlSize:NSControlSizeSmall]];
        [self customizeAppearance];
        [self setDrawsBackground:NO];
        [self setHasVerticalScroller:YES];
        [self setHasHorizontalScroller:NO];
    }
    return self;
}

@end
