#import "HSCardView.h"
#import "HSCard.h"
#import "HSStack.h"
#import "HSDocument.h"
#import "HSMainWindowController.h"
#import "HSPresentationContext.h"
#import "HSFunctions.h"
#import "NSAffineTransform+HSKeyValueCoding.h"

#define HSCardViewEpsilon (1.0 / 512.0)

// The intersection used throughout the autosizing: rects that only touch do
// not intersect, and the result is CGRectNull when they don't.
static CGRect HSCardViewIntersectRect(CGRect a, CGRect b)
{
    if (a.origin.x >= b.origin.x + b.size.width || b.origin.x >= a.origin.x + a.size.width
        || a.origin.y >= b.origin.y + b.size.height || b.origin.y >= a.origin.y + a.size.height)
        return CGRectNull;
    CGFloat x = fmax(a.origin.x, b.origin.x);
    CGFloat y = fmax(a.origin.y, b.origin.y);
    return CGRectMake(x, y,
                      fmin(a.origin.x + a.size.width, b.origin.x + b.size.width) - x,
                      fmin(a.origin.y + a.size.height, b.origin.y + b.size.height) - y);
}

// Plain bounding-box union; neither rect is ever null here.
static CGRect HSCardViewUnionRect(CGRect a, CGRect b)
{
    CGFloat x = fmin(a.origin.x, b.origin.x);
    CGFloat y = fmin(a.origin.y, b.origin.y);
    return CGRectMake(x, y,
                      fmax(a.origin.x + a.size.width, b.origin.x + b.size.width) - x,
                      fmax(a.origin.y + a.size.height, b.origin.y + b.size.height) - y);
}

static BOOL HSCardViewNearlyEqual(CGFloat a, CGFloat b)
{
    return a >= b - HSCardViewEpsilon && b + HSCardViewEpsilon >= a;
}

// Shows a card zoomed by _zoomFactor inside an enclosing scroll view. The
// view is sized so that the card stays centered when it is smaller than the
// visible area and scrollable when it is larger, keeping track of the part
// of the content last visible so that resizing preserves it.
@implementation HSCardView

+ (CGFloat)zoomFactorForFullScreen:(NSSize)aScreen
{
    return [self zoomFactorForFullScreen:aScreen forScreen:[[NSApp mainWindow] screen]];
}

+ (CGFloat)zoomFactorForFullScreen:(NSSize)aScreen forScreen:(id)aScreen2
{
    NSSize screenSize = [(NSScreen *)aScreen2 frame].size;
    return fmin(screenSize.width / aScreen.width, screenSize.height / aScreen.height);
}

- (void)autosizePreservingVisibleCenter
{
    [self HSCardView_autosizePreservingVisibleArea:YES orCenteringAtUserPoint:NSZeroPoint respectingLastVisibleContent:NO];
}

- (void)autosizePreservingVisibleArea
{
    [self HSCardView_autosizePreservingVisibleArea:YES orCenteringAtUserPoint:NSZeroPoint respectingLastVisibleContent:YES];
}

- (void)autosizeCenteringAtUserPoint:(NSPoint)aPoint respectingLastVisibleContent:(BOOL)aContent
{
    [self HSCardView_autosizePreservingVisibleArea:NO orCenteringAtUserPoint:aPoint respectingLastVisibleContent:aContent];
}

- (void)HSCardView_autosizePreservingVisibleArea:(BOOL)aArea orCenteringAtUserPoint:(NSPoint)aPoint respectingLastVisibleContent:(BOOL)aContent
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSRect userBounds = [self userObjectBounds];
    NSRect contentBounds = [self contentBoundingRect];
    Class scrollViewClass = [scrollView class];
    NSBorderType borderType = [scrollView borderType];
    NSSize frameSize = [scrollView frame].size;
    // Visible size with both scrollers shown, and with none.
    NSSize scrolledSize = [scrollViewClass contentSizeForFrameSize:frameSize hasHorizontalScroller:YES hasVerticalScroller:YES borderType:borderType];
    NSSize visibleSize = [scrollViewClass contentSizeForFrameSize:frameSize hasHorizontalScroller:NO hasVerticalScroller:NO borderType:borderType];
    CGRect viewUser = CGRectIntegral(NSRectToCGRect([self viewBoundingRectForUserRect:userBounds]));
    CGRect viewContent = CGRectIntegral(NSRectToCGRect([self viewBoundingRectForUserRect:contentBounds]));
    CGPoint clipOrigin = CGRectNull.origin;
    CGFloat availWidth = scrolledSize.width;
    CGFloat availHeight = scrolledSize.height;
    CGFloat contentWidth = viewContent.size.width;
    CGFloat contentHeight = viewContent.size.height;
    NSPoint center;

    if (!aArea)
        center = aPoint;
    else {
        NSRect clip = [self convertRect:[[scrollView contentView] frame] fromView:scrollView];
        clipOrigin = NSPointToCGPoint(clip.origin);
        center = [self convertPointFromViewSpaceToUserSpace:NSMakePoint(clip.origin.x + visibleSize.width * 0.5, clip.origin.y + visibleSize.height * 0.5)];
    }

    if (aContent && _lastVisibleContentUserRect.size.width > HSCardViewEpsilon && _lastVisibleContentUserRect.size.height > HSCardViewEpsilon) {
        CGRect viewLast = CGRectIntegral(NSRectToCGRect([self viewBoundingRectForUserRect:NSRectFromCGRect(_lastVisibleContentUserRect)]));
        if (viewLast.size.width > HSCardViewEpsilon && viewLast.size.height > HSCardViewEpsilon) {
            if (!aArea) {
                NSRect clip = [self convertRect:[[scrollView contentView] frame] fromView:scrollView];
                clipOrigin = NSPointToCGPoint(clip.origin);
            }
            CGRect visibleLast = HSCardViewIntersectRect(CGRectMake(clipOrigin.x, clipOrigin.y, visibleSize.width, visibleSize.height), viewLast);
            if (visibleLast.size.width > HSCardViewEpsilon && visibleLast.size.height > HSCardViewEpsilon) {
                CGRect visibleUnion = HSCardViewUnionRect(visibleLast, viewContent);
                CGRect scrolledLast = HSCardViewIntersectRect(CGRectMake(clipOrigin.x, clipOrigin.y, availWidth, availHeight), viewLast);
                if (scrolledLast.size.width > HSCardViewEpsilon && scrolledLast.size.height > HSCardViewEpsilon)
                    viewContent = HSCardViewUnionRect(scrolledLast, viewContent);
                contentWidth = visibleUnion.size.width;
                contentHeight = visibleUnion.size.height;
            }
        }
    }

    // Horizontally: a card narrower than the visible area is centered in it.
    CGFloat fitWidth;
    if (visibleSize.width > viewUser.size.width) {
        CGFloat x0 = viewUser.origin.x - floor((visibleSize.width - viewUser.size.width) * 0.5 + HSCardViewEpsilon);
        if (viewContent.origin.x > x0) {
            CGFloat delta = viewContent.origin.x - x0;
            contentWidth += delta;
            viewContent.size.width += delta;
            viewContent.origin.x = x0;
        }
        fitWidth = contentWidth;
        if (availWidth > viewUser.size.width) {
            CGFloat width = x0 + availWidth - viewContent.origin.x;
            if (width > viewContent.size.width)
                viewContent.size.width = width;
            contentWidth = fmax(width, fitWidth);
        } else
            contentWidth = fitWidth;
        CGFloat width = x0 + visibleSize.width - viewContent.origin.x;
        if (width > fitWidth)
            fitWidth = width;
    } else
        fitWidth = contentWidth;

    CGFloat fitHeight;
    if (visibleSize.height > viewUser.size.height) {
        CGFloat y0 = viewUser.origin.y - floor((visibleSize.height - viewUser.size.height) * 0.5 + HSCardViewEpsilon);
        if (viewContent.origin.y > y0) {
            CGFloat delta = viewContent.origin.y - y0;
            contentHeight += delta;
            viewContent.size.height += delta;
            viewContent.origin.y = y0;
        }
        fitHeight = contentHeight;
        if (availHeight > viewUser.size.height) {
            CGFloat height = y0 + availHeight - viewContent.origin.y;
            if (height > viewContent.size.height)
                viewContent.size.height = height;
            contentHeight = fmax(height, fitHeight);
        } else
            contentHeight = fitHeight;
        CGFloat height = y0 + visibleSize.height - viewContent.origin.y;
        if (height > fitHeight)
            fitHeight = height;
    } else
        fitHeight = contentHeight;

    BOOL horizontalOverflow = viewContent.size.width > visibleSize.width
        || (viewContent.size.width > availWidth && (fitWidth > visibleSize.width || viewContent.size.height > visibleSize.height));
    BOOL verticalOverflow = viewContent.size.height > visibleSize.height
        || (viewContent.size.height > availHeight && (fitHeight > visibleSize.height || viewContent.size.width > visibleSize.width));

    if (horizontalOverflow && verticalOverflow) {
        viewContent.size.width = contentWidth;
        viewContent.size.height = contentHeight;
    } else if (horizontalOverflow) {
        viewContent.size.width = fitWidth;
        availWidth = visibleSize.width;
    } else {
        viewContent.size.height = fitHeight;
        availHeight = visibleSize.height;
        if (!verticalOverflow) {
            viewContent.size.width = fitWidth;
            availWidth = visibleSize.width;
        }
    }

    [self autooffsetCardTo:NSMakePoint(viewUser.origin.x - viewContent.origin.x, viewUser.origin.y - viewContent.origin.y)];

    NSPoint viewCenter = [self convertPointFromUserSpaceToViewSpace:center];
    CGFloat offsetX = ceil(visibleSize.width * 0.5 - viewCenter.x - HSCardViewEpsilon);
    CGFloat offsetY = ceil(visibleSize.height * 0.5 - viewCenter.y - HSCardViewEpsilon);
    NSRect frame;
    frame.size.width = fmax(viewContent.size.width, availWidth);
    frame.size.height = fmax(viewContent.size.height, availHeight);
    frame.origin.x = offsetX >= 0 ? 0 : fmax(offsetX, availWidth - frame.size.width);
    frame.origin.y = offsetY >= 0 ? 0 : fmax(offsetY, availHeight - frame.size.height);

    if (!aContent)
        _lastVisibleContentUserRect = NSRectToCGRect(contentBounds);
    else {
        // Work out which part of the content will be visible, snapping the
        // edges of a centered card to the card itself.
        CGRect user = CGRectIntegral(NSRectToCGRect([self viewBoundingRectForUserRect:userBounds]));
        BOOL centered = NO;
        CGFloat edgeX = user.origin.x, edgeWidth = user.size.width;
        CGFloat edgeY = user.origin.y, edgeHeight = user.size.height;
        if (visibleSize.width > user.size.width) {
            edgeX = user.origin.x - floor((visibleSize.width - user.size.width) * 0.5 + HSCardViewEpsilon);
            edgeWidth = visibleSize.width;
            centered = YES;
        }
        if (visibleSize.height > user.size.height) {
            edgeY = user.origin.y - floor((visibleSize.height - user.size.height) * 0.5 + HSCardViewEpsilon);
            edgeHeight = visibleSize.height;
            centered = YES;
        }
        NSRect visible = NSMakeRect(-frame.origin.x, -frame.origin.y, visibleSize.width, visibleSize.height);
        if (centered) {
            if (HSCardViewNearlyEqual(visible.origin.x, edgeX)) {
                visible.size.width -= user.origin.x - edgeX;
                visible.origin.x = user.origin.x;
            }
            if (HSCardViewNearlyEqual(visible.origin.x + visible.size.width, edgeX + edgeWidth))
                visible.size.width = user.origin.x + user.size.width - visible.origin.x;
            if (HSCardViewNearlyEqual(visible.origin.y, edgeY)) {
                visible.size.height -= user.origin.y - edgeY;
                visible.origin.y = user.origin.y;
            }
            if (HSCardViewNearlyEqual(visible.origin.y + visible.size.height, edgeY + edgeHeight))
                visible.size.height = user.origin.y + user.size.height - visible.origin.y;
        }
        CGRect visibleUser = NSRectToCGRect([self userBoundingRectForViewRect:visible]);
        CGRect last = HSCardViewIntersectRect(visibleUser, _lastVisibleContentUserRect);
        if (last.size.width <= HSCardViewEpsilon || last.size.height <= HSCardViewEpsilon)
            _lastVisibleContentUserRect = NSRectToCGRect(contentBounds);
        else
            _lastVisibleContentUserRect = HSCardViewUnionRect(last, NSRectToCGRect(contentBounds));
    }

    _isAutosizing = 1;
    [self autosizeToFrame:[self convertRect:frame toView:[self superview]]];
    _isAutosizing = 0;
}

- (void)enclosingScrollViewDidScroll
{
    if (!_isAutosizingScheduled && !_isAutosizing)
        _isAutosizingScheduled = [self HSCardView_scheduleAutosizing];
}

- (void)HSCardView_autosizeScheduled
{
    NSScrollView *scrollView = [self enclosingScrollView];
    if (scrollView) {
        // Wait for the clip view to finish an animated scroll; the private
        // _isAnimatingScroll is only queried when it is there.
        char isAnimating = 0;
        NSClipView *clipView = [scrollView contentView];
        NSMethodSignature *signature = [clipView methodSignatureForSelector:@selector(_isAnimatingScroll)];
        if (signature && strcmp([signature methodReturnType], "c") == 0) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            if (invocation) {
                [invocation setTarget:clipView];
                [invocation setSelector:@selector(_isAnimatingScroll)];
                [invocation invoke];
                [invocation getReturnValue:&isAnimating];
            }
        }
        if (isAnimating) {
            _isAutosizingScheduled = [self HSCardView_scheduleAutosizing];
            return;
        }
        [self autosizeToReflectEnclosingScrollView];
    }
    _isAutosizingScheduled = 0;
}

- (BOOL)HSCardView_scheduleAutosizing
{
    NSArray *modes = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    if (modes)
        [[NSRunLoop currentRunLoop] performSelector:@selector(HSCardView_autosizeScheduled) target:self argument:nil order:0xffffffff modes:modes];
    return modes != nil;
}

- (void)enclosingScrollViewDidResize
{
    [self autosizeToFitEnclosingScrollView];
}

- (void)autosizeToReflectEnclosingScrollView
{
    [self autosizePreservingVisibleArea];
}

- (void)autosizeToFitEnclosingScrollView
{
    if (![self inLightweightChangeProcessingMode])
        [self autolayoutPreservingVisibleArea];
}

- (void)autosizeToFrame:(NSRect)aFrame
{
    BOOL openGL = [self isOpenGLSurfaceEnabled];
    if (!openGL)
        [self setFrameSize:aFrame.size];
    else {
        // Grow first so the surface never shrinks below what is scrolled
        // into view, then settle on the final size after scrolling.
        [[self window] disableScreenUpdatesUntilFlush];
        NSSize size = [self frame].size;
        if (aFrame.size.width > size.width || aFrame.size.height > size.height)
            [self setFrameSize:NSMakeSize(fmax(aFrame.size.width, size.width), fmax(aFrame.size.height, size.height))];
    }
    NSClipView *clipView = [[self enclosingScrollView] contentView];
    NSRect clipFrame = [[self superview] convertRect:aFrame toView:clipView];
    [clipView setBoundsOrigin:NSMakePoint(-clipFrame.origin.x, -clipFrame.origin.y)];
    if (openGL)
        [self setFrameSize:aFrame.size];
}

- (void)autooffsetCardTo:(NSPoint)aTo
{
    [self setCardOffset:NSMakeSize(aTo.x, aTo.y)];
}

- (NSRect)userBoundingRectForViewRect:(NSRect)aRect
{
    return NSMakeRect(aRect.origin.x / _zoomFactor, aRect.origin.y / _zoomFactor, aRect.size.width / _zoomFactor, aRect.size.height / _zoomFactor);
}

- (NSRect)viewBoundingRectForUserRect:(NSRect)aRect
{
    return NSMakeRect(aRect.origin.x * _zoomFactor, aRect.origin.y * _zoomFactor, aRect.size.width * _zoomFactor, aRect.size.height * _zoomFactor);
}

- (NSPoint)convertPointFromViewSpaceToUserSpace:(NSPoint)aSpace
{
    return NSMakePoint(aSpace.x / _zoomFactor, aSpace.y / _zoomFactor);
}

- (NSPoint)convertPointFromUserSpaceToViewSpace:(NSPoint)aSpace
{
    return NSMakePoint(aSpace.x * _zoomFactor, aSpace.y * _zoomFactor);
}

- (id)viewSpaceToUserSpaceTransform
{
    float scale = 1.0f / _zoomFactor;
    struct HyperPlayerBase_anon1 transform = {scale, 0, 0, scale, 0, 0};
    return [NSAffineTransform transformWithHyperTransformStruct:transform];
}

- (id)userSpaceToViewSpaceTransform
{
    struct HyperPlayerBase_anon1 transform = {_zoomFactor, 0, 0, _zoomFactor, 0, 0};
    return [NSAffineTransform transformWithHyperTransformStruct:transform];
}

- (CGFloat)zoomFactor
{
    return _zoomFactor;
}

- (void)setZoomFactor:(CGFloat)aFactor
{
    float factor = aFactor;
    float magnitude = fmaxf(factor != 0 ? fabsf(factor) : 1, _zoomFactor != 0 ? fabsf(_zoomFactor) : 1);
    if (magnitude * 0.0005f < fabsf(factor - _zoomFactor))
        _zoomFactor = factor;
}

- (void)setHasEdgeShadowView:(BOOL)aView
{
}

- (BOOL)isSlideshow
{
    return [[self presentationContext] isSlideshowContext];
}

- (BOOL)canDeactivate
{
    return YES;
}

- (BOOL)isActive
{
    return _active;
}

- (void)refreshCanvasLayersRunningInCurrentActiveState
{
    [self setSupportsCanvasLayersRunning:[self supportsCanvasLayersRunningInCurrentActiveState]];
}

- (BOOL)supportsCanvasLayersRunningInCurrentActiveState
{
    return _active;
}

- (void)deactivate
{
    _active = NO;
    [self refreshCanvasLayersRunningInCurrentActiveState];
}

- (void)activate
{
    _active = YES;
    [self refreshCanvasLayersRunningInCurrentActiveState];
}

- (void)endChangeUserSpaceToViewSpaceTransformNotificationsCoalescing
{
    if (--_changeUserSpaceToViewSpaceTransformNotificationsCoalescingCount == 0)
        [self flushChangeUserSpaceToViewSpaceTransformNotifications];
}

- (void)beginChangeUserSpaceToViewSpaceTransformNotificationsCoalescing
{
    _changeUserSpaceToViewSpaceTransformNotificationsCoalescingCount++;
}

- (void)notifyDidChangeUserSpaceToViewSpaceTransform
{
    _hasPendingUserSpaceToViewSpaceTransformNotifications = YES;
    if (_changeUserSpaceToViewSpaceTransformNotificationsCoalescingCount == 0)
        [self flushChangeUserSpaceToViewSpaceTransformNotifications];
}

- (void)flushChangeUserSpaceToViewSpaceTransformNotifications
{
    if (_hasPendingUserSpaceToViewSpaceTransformNotifications) {
        _hasPendingUserSpaceToViewSpaceTransformNotifications = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:self];
    }
}

- (void)setSupportsCanvasLayersRunning:(BOOL)aRunning
{
    if (_supportsCanvasLayersRunning != (aRunning != NO)) {
        _supportsCanvasLayersRunning = aRunning != NO;
        [[self rootCanvasLayer] setRunningDisabled:!_supportsCanvasLayersRunning];
    }
}

- (BOOL)supportsCanvasLayersRunning
{
    return _supportsCanvasLayersRunning;
}

- (void)setupRootCanvasLayer:(id)aLayer
{
    [super setupRootCanvasLayer:aLayer];
    [aLayer setRunningDisabled:!_supportsCanvasLayersRunning];
}

- (void)drawBackgroundInContentRect:(NSRect)aRect
{
    [self fillBackground];
}

- (void)addCardRect:(NSRect)aRect toContext:(struct CGContext *)aContext
{
    CGContextAddRect(aContext, NSRectToCGRect(aRect));
}

- (void)setNeedsDisplayWorkAreaBackground
{
}

- (BOOL)isFlipped
{
    return YES;
}

- (NSRect)contentViewingRect
{
    NSRect rect = [self contentBoundingRect];
    if (!NSIsEmptyRect(rect))
        rect = [self viewBoundingRectForUserRect:rect];
    return rect;
}

- (NSRect)cardViewingRect
{
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = [self cardSize];
    return [self viewBoundingRectForUserRect:rect];
}

- (NSRect)userObjectBounds
{
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = [self cardSize];
    return rect;
}

- (NSSize)cardSize
{
    id size = [[self card] queryHyperInterface:@protocol(HSSizeAttributes)];
    if (!size)
        return NSZeroSize;
    return [(id<HSSizeAttributes>)size size];
}

- (void)setCard:(id)aCard
{
    if ([self card] == aCard)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCurrentCardInCardViewWillChange" object:self];
    if ([self card] && [_delegate respondsToSelector:@selector(cardView:willSetCard:)])
        [_delegate cardView:self willSetCard:aCard];
    [self setUserObject:aCard];
    if ([_delegate respondsToSelector:@selector(cardView:didSetCard:)])
        [_delegate cardView:self didSetCard:aCard];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCurrentCardInCardViewDidChange" object:self];
}

- (id)card
{
    return [self userObject];
}

- (void)stackDidChange:(id)aChange
{
    [self cardStackDidChange];
}

- (void)stackWillChange:(id)aChange
{
    [self cardStackWillChange];
}

- (void)cardStackDidChange
{
    [self registerStackNotifications];
}

- (void)cardStackWillChange
{
    [self unregisterStackNotifications];
}

- (void)cardSizeDidChange:(id)aChange
{
    [self setNeedsDisplayOpenGLSurface:YES];
}

- (void)registerObservingUserObjectAttributesChange
{
    [super registerObservingUserObjectAttributesChange];
    id card = [self card];
    [card addObserver:self selector:@selector(stackWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:-0.75];
    [card addObserver:self selector:@selector(stackDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:-0.75];
    [card addObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSizeAttribute) withPriority:-0.75];
    [self registerStackNotifications];
}

- (void)unregisterObservingUserObjectAttributesChange
{
    [super unregisterObservingUserObjectAttributesChange];
    id card = [self card];
    [card removeObserver:self selector:@selector(stackWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
    [card removeObserver:self selector:@selector(stackDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
    [card removeObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSizeAttribute)];
    [self unregisterStackNotifications];
}

- (void)unregisterStackNotifications
{
    [self unregisterObservingCardStackAttributesChanges];
}

- (void)registerStackNotifications
{
    [self registerObservingCardStackAttributesChanges];
}

- (void)unregisterObservingCardStackAttributesChanges
{
}

- (void)registerObservingCardStackAttributesChanges
{
}

- (void)cancelOperation:(id)aOperation
{
    BOOL handled = [self handleKeyEventSelector:_cmd];
    if (!handled) {
        id windowController = [[self window] windowController];
        if ([windowController isKindOfClass:[HSMainWindowController class]])
            handled = [(HSMainWindowController *)windowController cancelOperation];
    }
    if (handled)
        [self didHandleKeyEvent];
}

- (void)dealloc
{
    [[[[self card] stack] attributeObservingController] removeAttributeObserver:self];
    [[self card] removeAttributeObserver:self];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        _zoomFactor = 1;
        [super enableOpenGLSurface];
        [super setOpenGLSurfaceAutodisplayMode:1];
    }
    return self;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        _zoomFactor = 1;
        [super enableOpenGLSurface];
        [super setOpenGLSurfaceAutodisplayMode:1];
    }
    return self;
}

- (void)autolayoutCenteringAtUserPoint:(NSPoint)aPoint respectingLastVisibleContent:(BOOL)aContent
{
    CGFloat zoomBefore = [self zoomFactor];
    NSSize offsetBefore = _cardOffset;
    if (_zoomMode == 1) {
        [self autozoomToFitCardToVisibleArea];
    }
    [self autosizeCenteringAtUserPoint:aPoint respectingLastVisibleContent:aContent];
    CGFloat zoomAfter = [self zoomFactor];
    if ((zoomAfter < zoomBefore - 0.0001 || zoomBefore + 0.0001 < zoomAfter) && offsetBefore.width - 0.001953125 <= _cardOffset.width && _cardOffset.width <= offsetBefore.width + 0.001953125 && offsetBefore.height - 0.001953125 <= _cardOffset.height && _cardOffset.height <= offsetBefore.height + 0.001953125) {
        [self notifyDidChangeUserSpaceToViewSpaceTransform];
    }
}

- (void)autolayoutPreservingVisibleArea
{
    CGFloat zoomBefore = [self zoomFactor];
    NSSize offsetBefore = _cardOffset;
    if (_zoomMode == 1 && ![[[self card] document] isInPresentationMode]) {
        [self autozoomToFitCardToVisibleArea];
    }
    [self autosizePreservingVisibleArea];
    CGFloat zoomAfter = [self zoomFactor];
    if ((zoomAfter < zoomBefore - 0.0001 || zoomBefore + 0.0001 < zoomAfter) && offsetBefore.width - 0.001953125 <= _cardOffset.width && _cardOffset.width <= offsetBefore.width + 0.001953125 && offsetBefore.height - 0.001953125 <= _cardOffset.height && _cardOffset.height <= offsetBefore.height + 0.001953125) {
        [self notifyDidChangeUserSpaceToViewSpaceTransform];
    }
}

- (void)autolayoutPreservingVisibleCenter
{
    CGFloat zoomBefore = [self zoomFactor];
    NSSize offsetBefore = _cardOffset;
    if (_zoomMode == 1 && ![[[self card] document] isInPresentationMode]) {
        [self autozoomToFitCardToVisibleArea];
    }
    [self autosizePreservingVisibleCenter];
    CGFloat zoomAfter = [self zoomFactor];
    if ((zoomAfter < zoomBefore - 0.0001 || zoomBefore + 0.0001 < zoomAfter) && offsetBefore.width - 0.001953125 <= _cardOffset.width && _cardOffset.width <= offsetBefore.width + 0.001953125 && offsetBefore.height - 0.001953125 <= _cardOffset.height && _cardOffset.height <= offsetBefore.height + 0.001953125) {
        [self notifyDidChangeUserSpaceToViewSpaceTransform];
    }
}

- (void)autozoomToFitCardToVisibleArea
{
    NSSize cardSize = [self cardSize];
    if (cardSize.width > 0 && cardSize.height > 0) {
        NSScrollView *scrollView = [self enclosingScrollView];
        NSRect frame = scrollView != nil ? [scrollView frame] : NSZeroRect;
        NSSize content = [[scrollView class] contentSizeForFrameSize:frame.size hasHorizontalScroller:NO hasVerticalScroller:NO borderType:[scrollView borderType]];
        CGFloat zoom = content.height / cardSize.height;
        if (content.width / cardSize.width <= zoom) {
            zoom = content.width / cardSize.width;
        }
        [self setZoomFactor:MAX(0.01f, zoom)];
    }
}

- (void)beginLightweightChangeProcessingMode
{
    if (_lightweightChangeProcessingModeCounter == 0) {
        [self beginContentChangeAccumulation];
        [self acceptDrawingQualityLoss:0.9999];
    }
    _lightweightChangeProcessingModeCounter++;
}

- (void)endLightweightChangeProcessingMode
{
    _lightweightChangeProcessingModeCounter--;
    if (_lightweightChangeProcessingModeCounter == 0) {
        [self endContentChangeAccumulation];
        [self declineDrawingQualityLoss:0.9999];
        [self setNeedsDisplayOpenGLSurface:YES];
        if ([self inLiveResize]) {
            [self enterLiveResizeCacheOnlyRenderingModeIfNeeded];
        }
    }
}

- (BOOL)inLightweightChangeProcessingMode
{
    return _lightweightChangeProcessingModeCounter != 0;
}

- (NSSize)cardOffset
{
    return _cardOffset;
}

- (void)setCardOffset:(NSSize)aOffset
{
    _cardOffset = aOffset;
}

- (void)enterLiveResizeCacheOnlyRenderingModeIfNeeded
{
    if (_zoomMode == 1) {
        [self acceptDrawingQualityLoss:0.9999];
        _cacheOnlyRendering = YES;
        [self setupLiveResizeRecacheTimer];
    }
}

- (void)fillBackground
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    NSRect userBounds = self != nil ? [self userObjectBounds] : NSZeroRect;
    NSRect viewRect = self != nil ? [self viewBoundingRectForUserRect:userBounds] : NSZeroRect;
    CGAffineTransform transform = CGContextGetCTM(context);
    CGContextSetPatternPhase(context, CGSizeMake(transform.a * viewRect.origin.x + transform.c * viewRect.origin.y + transform.tx, transform.b * viewRect.origin.x + transform.d * viewRect.origin.y + transform.ty));
    [NSBezierPath fillRect:self != nil ? [self bounds] : NSZeroRect];
}

- (void)fitInWindow
{
    [self setZoomMode:1];
}

- (void)handleFluidSwipe:(id)aSwipe
{
    if ([aSwipe phase] == NSEventPhaseEnded) {
        if ([aSwipe gestureAmount] < 0) {
            [[[self userObject] document] goToNextCardWithoutLeaveActions:self];
        } else if ([aSwipe gestureAmount] > 0) {
            [[[self userObject] document] goToPreviousCardWithoutLeaveActions:self];
        }
    }
}

- (void)handleLiveResizeRecacheTimerFire:(id)aTimer
{
    [self acceptDrawingQualityLoss:0];
    [self display];
    [self declineDrawingQualityLoss:0];
    [_liveResizeRecacheTimer release];
    _liveResizeRecacheTimer = nil;
}

- (BOOL)handleMagnificationGesture:(id)aGesture
{
    BOOL handled = [super handleMagnificationGesture:aGesture];
    if (!handled) {
        CGFloat current = [self zoomFactor];
        CGFloat target = [aGesture magnification] + current;
        CGFloat minimum = [HSEditorZoomController minZoomFactor];
        CGFloat maximum = [HSEditorZoomController maxZoomFactor];
        target = MIN(MAX(minimum, target), maximum);
        handled = YES;
        if (MAX(fabsf(target) != 0 ? fabsf(target) : 1.0f, fabsf(current) != 0 ? fabsf(current) : 1.0f) * 0.0005 < fabsf(target - current)) {
            [self zoomToFactor:target aboutPoint:[self convertPoint:[aGesture locationInWindow] fromView:nil]];
        }
    }
    return handled;
}

- (BOOL)handleSwipeGesture:(id)aGesture
{
    BOOL handled = [super handleSwipeGesture:aGesture];
    if (!handled) {
        if ([aGesture deltaX] > 0) {
            [[[self userObject] document] goToNextCardWithoutLeaveActions:self];
            handled = YES;
        } else if ([aGesture deltaX] < 0) {
            [[[self userObject] document] goToPreviousCardWithoutLeaveActions:self];
            handled = YES;
        }
    }
    return handled;
}

- (void)setFrameSize:(NSSize)aSize
{
    if (_liveResizeRecacheTimer == nil) {
        if (_cacheOnlyRendering) {
            [self setupLiveResizeRecacheTimer];
        }
    } else {
        [_liveResizeRecacheTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    [super setFrameSize:aSize];
}

- (void)setZoomMode:(int)aMode
{
    if (_zoomMode != aMode) {
        _zoomMode = aMode;
        if (aMode == 1) {
            if ([self enclosingScrollView] != nil) {
                NSSize cardSize = [self cardSize];
                [self autolayoutCenteringAtUserPoint:NSMakePoint(cardSize.width * 0.5, cardSize.height * 0.5) respectingLastVisibleContent:NO];
            }
            [self setNeedsDisplayOpenGLSurface:YES];
        }
    }
}

- (int)zoomMode
{
    return _zoomMode;
}

- (void)setupLiveResizeRecacheTimer
{
    _liveResizeRecacheTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0] interval:0 target:self selector:@selector(handleLiveResizeRecacheTimerFire:) userInfo:nil repeats:NO];
    if (_liveResizeRecacheTimer != nil) {
        [[NSRunLoop currentRunLoop] addTimer:_liveResizeRecacheTimer forMode:NSEventTrackingRunLoopMode];
    }
}

- (void)viewDidEndLiveResize
{
    if (_cacheOnlyRendering) {
        [self declineDrawingQualityLoss:0.9999];
        [self setNeedsDisplayOpenGLSurface:YES];
        _cacheOnlyRendering = NO;
        [_liveResizeRecacheTimer invalidate];
        [_liveResizeRecacheTimer release];
        _liveResizeRecacheTimer = nil;
    }
    [super viewDidEndLiveResize];
}

- (void)viewWillStartLiveResize
{
    [super viewWillStartLiveResize];
    if (![self inLightweightChangeProcessingMode]) {
        [self enterLiveResizeCacheOnlyRenderingModeIfNeeded];
    }
}

- (void)zoomInAboutPoint:(NSPoint)aPoint
{
    float zoomIn = 0;
    [HSEditorZoomController nextZoomOutFactor:NULL zoomInFactor:&zoomIn forZoomFactor:[self zoomFactor]];
    if (!isnan(zoomIn)) {
        [self setZoomMode:0];
        [self zoomToFactor:zoomIn aboutPoint:aPoint];
    }
}

- (void)zoomOutAboutPoint:(NSPoint)aPoint
{
    float zoomOut = 0;
    [HSEditorZoomController nextZoomOutFactor:&zoomOut zoomInFactor:NULL forZoomFactor:[self zoomFactor]];
    if (!isnan(zoomOut)) {
        [self setZoomMode:0];
        [self zoomToFactor:zoomOut aboutPoint:aPoint];
    }
}

- (void)zoomToFactor:(float)aFactor
{
    NSPoint point;
    if ([self enclosingScrollView] == nil) {
        point = NSZeroPoint;
    } else if (aFactor != 1.0) {
        NSRect visible = [[self enclosingScrollView] documentVisibleRect];
        point = NSMakePoint(visible.origin.x + visible.size.width * 0.5, visible.origin.y + visible.size.height * 0.5);
    } else {
        NSSize cardSize = [self cardSize];
        point = [self convertPointFromUserSpaceToViewSpace:NSMakePoint(cardSize.width * 0.5, cardSize.height * 0.5)];
    }
    [self zoomToFactor:aFactor aboutPoint:point];
}

- (void)zoomToFactor:(float)aFactor aboutPoint:(NSPoint)aPoint
{
    CGFloat current = [self zoomFactor];
    if (MAX(fabsf(aFactor) != 0 ? fabsf(aFactor) : 1.0f, fabsf(current) != 0 ? fabsf(current) : 1.0f) * 0.0005 < fabsf(current - aFactor)) {
        [self setZoomMode:0];
        if ([self enclosingScrollView] != nil) {
            NSPoint userPoint = [self convertPointFromViewSpaceToUserSpace:aPoint];
            [self setZoomFactor:aFactor];
            [self autosizeCenteringAtUserPoint:userPoint respectingLastVisibleContent:YES];
        } else {
            [self setZoomFactor:aFactor];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:self];
        [self setNeedsDisplayOpenGLSurface:YES];
    }
}

@end
