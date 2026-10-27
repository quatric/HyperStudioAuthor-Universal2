#import "HSCustomWindow.h"

@implementation HSCustomWindow

- (NSRect)contentRectForFrameRect:(NSRect)aRect
{
    NSRect rect = [super contentRectForFrameRect:aRect];
    return [[self customWindowContentView] applyMarginsToRect:rect extend:NO];
}

- (NSRect)frameRectForContentRect:(NSRect)aRect
{
    NSRect rect = [super frameRectForContentRect:aRect];
    return [[self customWindowContentView] applyMarginsToRect:rect extend:YES];
}

- (void)setContentView:(id)aView
{
    id contentView = [self contentView];
    if (_customContentView == nil || contentView != _customContentView) {
        [super setContentView:aView];
        return;
    }
    NSArray *subviews = [[contentView subviews] copy];
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [subviews release];
    [self moveSubviewsOfView:aView toView:contentView];
}

- (void)setCustomWindowContentViewClass:(Class)aClass
{
    id view = [[aClass alloc] initWithFrame:[_customContentView frame]];
    [self moveSubviewsOfView:_customContentView toView:view];
    [_customContentView release];
    _customContentView = view;
    [super setContentView:view];
}

- (void)moveSubviewsOfView:(id)aView toView:(id)aView2
{
    NSEnumerator *enumerator = [[aView subviews] objectEnumerator];
    id subview;
    while ((subview = [enumerator nextObject]) != nil)
        [aView2 addSubview:subview];
}

- (id)customWindowContentView
{
    return _customContentView;
}

- (void)dealloc
{
    [_customContentView release];
    [super dealloc];
}

- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer
{
    self = [super initWithContentRect:aRect styleMask:aMask backing:aBacking defer:aDefer];
    if (self != nil) {
        [self setOpaque:NO];
        _customContentView = [[HSCustomWindowContentView alloc] initWithFrame:[self frame]];
        [self setContentView:_customContentView];
    }
    return self;
}

@end
