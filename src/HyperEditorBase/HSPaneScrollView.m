#import "HSPaneScrollView.h"

@implementation HSPaneScrollView

- (void)viewDidEndLiveResize
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPaneScrollViewDidEndLiveResizeNotification" object:self];
}

// HSPaneScrollers, both arrows at the end, in place of the scrollers.
- (void)customizeScrollers
{
    NSScroller *scroller;
    if ([self hasHorizontalScroller] && (scroller = [self horizontalScroller]) != nil) {
        HSPaneScroller *paneScroller = [[HSPaneScroller alloc] initWithFrame:[scroller frame]];
        [paneScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
        [self setHorizontalScroller:paneScroller];
        [paneScroller release];
    }
    if ([self hasVerticalScroller] && (scroller = [self verticalScroller]) != nil) {
        HSPaneScroller *paneScroller = [[HSPaneScroller alloc] initWithFrame:[scroller frame]];
        [paneScroller setArrowsPosition:NSScrollerArrowsMaxEnd];
        [self setVerticalScroller:paneScroller];
        [paneScroller release];
    }
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]))
        [self customizeScrollers];
    return self;
}

@end
