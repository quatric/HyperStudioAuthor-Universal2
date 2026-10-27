#import "HSViewEmbedder.h"

@implementation HSViewEmbedder

- (id)observer
{
    return _observer;
}

- (void)setObserver:(id)aObserver
{
    _observer = aObserver;
}

- (BOOL)isMountedInHostView
{
    return [[self embeddedView] superview] != nil;
}

- (void)unmountFromHostView:(id)aView
{
    [[self embeddedView] removeFromSuperview];
    if ([[aView window] firstResponder] == [aView window])
        [[aView window] makeFirstResponder:aView];
}

- (BOOL)makeEmbeddedViewFirstResponder
{
    NSView *view = [self embeddedView];
    if (![view acceptsFirstResponder])
        return NO;
    return [[view window] makeFirstResponder:view];
}

- (void)mountInHostView:(id)aView
{
    NSView *view = [self embeddedView];
    [aView addSubview:view];
    if ([self makeEmbeddedViewFirstResponder])
        [[[view window] firstResponder] setNextResponder:[view window]];
}

- (void)sizeToFitWithObjectBounds:(NSRect)aBounds
{
}

- (NSSize)preferredSize
{
    return NSZeroSize;
}

- (void)setFrame:(NSRect)aFrame
{
    [[self embeddedView] setFrame:aFrame];
}

- (NSRect)frame
{
    NSView *view = [self embeddedView];
    if (view == nil)
        return NSZeroRect;
    return [view frame];
}

// Abstract; subclasses supply the view.
- (id)embeddedView
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
