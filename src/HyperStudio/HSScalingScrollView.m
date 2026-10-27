#import "HSScalingScrollView.h"

@implementation HSScalingScrollView

- (void)setDocumentView:(id)aView
{
    [self setInEditMode:NO];
    [super setDocumentView:aView];
    [self setInEditMode:[self documentView] == _cardView];
}

- (void)scrollWheel:(id)aWheel
{
    HSEditorCardView *cardView = [self cardViewInEditMode];
    if (!([(NSEvent *)aWheel modifierFlags] & NSEventModifierFlagOption) || cardView == nil) {
        [super scrollWheel:aWheel];
        return;
    }
    float factor = fmaxf([HSEditorZoomController minZoomFactor], [(NSEvent *)aWheel deltaY] * 0.1 + [cardView zoomFactor]);
    factor = fminf([HSEditorZoomController maxZoomFactor], factor);
    [cardView zoomToFactor:factor aboutPoint:[cardView convertPoint:[(NSEvent *)aWheel locationInWindow] fromView:nil]];
}

- (id)cardViewInEditMode
{
    return [self isInEditMode] ? _cardView : nil;
}

- (void)setInEditMode:(BOOL)aMode
{
    _isNotInEditMode = !aMode;
}

- (BOOL)isInEditMode
{
    return !_isNotInEditMode;
}

- (void)reflectScrolledClipView:(id)aView
{
    [super reflectScrolledClipView:aView];
    id documentView = [self documentView];
    if ([documentView isKindOfClass:[HSCardView class]])
        [documentView enclosingScrollViewDidScroll];
}

- (void)setFrameSize:(NSSize)aSize
{
    [super setFrameSize:aSize];
    id documentView = [self documentView];
    if ([documentView isKindOfClass:[HSCardView class]])
        [documentView enclosingScrollViewDidResize];
}

- (void)awakeFromNib
{
    [self setInEditMode:[self documentView] == _cardView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
