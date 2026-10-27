#import "HSCenteringDocumentViewWrapper.h"
// A scroll view's document view that centers its one subview: it is at least
// as big as the clip view (its superview) and the subview, and keeps the
// subview centered in it. The subview isn't retained.
@implementation HSCenteringDocumentViewWrapper
- (void)HSCenteringDocumentViewWrapper_environmentDidChange:(id)aChange
{
    [self HSCenteringDocumentViewWrapper_recalculateFrameSize];
}
- (void)willRemoveSubview:(id)aSubview
{
    if (_subviewToCenter == aSubview) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:_subviewToCenter];
        _subviewToCenter = nil;
        [self HSCenteringDocumentViewWrapper_recalculateFrameSize];
    }
    [super willRemoveSubview:aSubview];
}
- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    NSView *superview = [self superview];
    if (superview != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(HSCenteringDocumentViewWrapper_environmentDidChange:) name:NSViewBoundsDidChangeNotification object:superview];
        [center addObserver:self selector:@selector(HSCenteringDocumentViewWrapper_environmentDidChange:) name:NSViewFrameDidChangeNotification object:superview];
    }
    [self HSCenteringDocumentViewWrapper_recalculateFrameSize];
}
- (void)viewWillMoveToSuperview:(id)aSuperview
{
    NSView *superview = [self superview];
    if (superview != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:NSViewBoundsDidChangeNotification object:superview];
        [center removeObserver:self name:NSViewFrameDidChangeNotification object:superview];
    }
    [super viewWillMoveToSuperview:aSuperview];
}
- (void)setFrameSize:(NSSize)aSize
{
    [super setFrameSize:aSize];
    [self HSCenteringDocumentViewWrapper_positionSubview];
}
- (void)setBoundsSize:(NSSize)aSize
{
    [super setBoundsSize:aSize];
    [self HSCenteringDocumentViewWrapper_positionSubview];
}
- (void)setSubviewToCenter:(id)aCenter
{
    if (_subviewToCenter == aCenter)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_subviewToCenter != nil)
        [center removeObserver:self name:NSViewFrameDidChangeNotification object:_subviewToCenter];
    _subviewToCenter = aCenter;
    if (aCenter != nil)
        [center addObserver:self selector:@selector(HSCenteringDocumentViewWrapper_environmentDidChange:) name:NSViewFrameDidChangeNotification object:aCenter];
    [self HSCenteringDocumentViewWrapper_recalculateFrameSize];
}
- (id)subviewToCenter
{
    return _subviewToCenter;
}
- (void)awakeFromNib
{
    if (_subviewToCenter != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSCenteringDocumentViewWrapper_environmentDidChange:)
                                                     name:NSViewFrameDidChangeNotification object:_subviewToCenter];
    [self HSCenteringDocumentViewWrapper_recalculateFrameSize];
}
- (BOOL)isFlipped
{
    return YES;
}
// On whole points.
- (void)HSCenteringDocumentViewWrapper_positionSubview
{
    if (_subviewToCenter == nil)
        return;
    NSRect bounds = [self bounds];
    NSRect frame = [_subviewToCenter frame];
    [_subviewToCenter setFrameOrigin:NSMakePoint(floor((bounds.size.width - frame.size.width) * 0.5),
                                                 floor((bounds.size.height - frame.size.height) * 0.5))];
}
// The larger of the superview's bounds size and the subview's frame size.
- (void)HSCenteringDocumentViewWrapper_recalculateFrameSize
{
    NSSize superSize = NSZeroSize, subviewSize = NSZeroSize;
    NSView *superview = [self superview];
    if (superview != nil)
        superSize = [superview bounds].size;
    if (_subviewToCenter != nil)
        subviewSize = [_subviewToCenter frame].size;
    [self setFrameSize:NSMakeSize(MAX(superSize.width, subviewSize.width), MAX(superSize.height, subviewSize.height))];
}
@end
