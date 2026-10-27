#import "HSWebRenderer.h"
#import <WebKit/WebKit.h>
#import "NSEWindow.h"

static NSString * const HSWebRendererDidUpdateNotificationName = @"HSWebRendererDidUpdateNotificationName";
static NSString * const HSWebRendererDidUpdatePreviewImageNotificationName = @"HSWebRendererDidUpdatePreviewImageNotificationName";

// Renders a URL or an HTML string in an offscreen WebView (in a borderless,
// never ordered-in window) while played, posting an update notification
// updateRate times a second (at most 30) and keeping a preview image of the
// last loaded page. Links open in the default browser. The web view can be
// ejected into a real view hierarchy and reclaimed.
@implementation HSWebRenderer

// Drops "open in new window", "download" and similar items.
- (id)webView:(id)aView contextMenuItemsForElement:(id)aElement defaultMenuItems:(id)aItems
{
    NSUInteger count = [aItems count];
    NSMutableArray *items = nil;
    NSUInteger kept = 0;
    NSUInteger i;
    for (i = 0; i < count; i++) {
        NSInteger tag = [[aItems objectAtIndex:i] tag];
        // Tags 1, 2, 4, 5 and 7 (WebMenuItemTagOpenLinkInNewWindow,
        // DownloadLinkToDisk, OpenImageInNewWindow, DownloadImageToDisk,
        // OpenFrameInNewWindow).
        if (tag > 7 || ((0xb6u >> tag) & 1) == 0) {
            kept++;
            continue;
        }
        if (items == nil)
            items = [[aItems mutableCopy] autorelease];
        [items removeObjectAtIndex:kept];
    }
    return items != nil ? items : aItems;
}

// New windows: requests open in the browser; without a request (scripts) a
// throwaway web view catches the navigation and hands its URL to the browser.
- (id)webView:(id)aView createWebViewWithRequest:(id)aRequest
{
    if (aRequest != nil) {
        [[NSWorkspace sharedWorkspace] openURL:[aRequest URL]];
        return nil;
    }
    if (_navigationWebView == nil) {
        _navigationWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 320, 240)];
        [_navigationWebView setPolicyDelegate:(id)self];
    }
    return _navigationWebView;
}

- (void)webView:(id)aView decidePolicyForNavigationAction:(id)aAction request:(id)aRequest frame:(id)aFrame decisionListener:(id)aListener
{
    if (aView == _navigationWebView) {
        id URL = [aAction objectForKey:WebActionOriginalURLKey];
        if (URL != nil)
            [[NSWorkspace sharedWorkspace] openURL:URL];
        [_navigationWebView setPolicyDelegate:nil];
        [_navigationWebView close];
        [_navigationWebView autorelease];
        _navigationWebView = nil;
        return;
    }
    if ([_webView mainFrame] != aFrame) {
        [aListener use];
        return;
    }
    switch ([[aAction objectForKey:WebActionNavigationTypeKey] intValue]) {
    case WebNavigationTypeFormSubmitted:
    case WebNavigationTypeFormResubmitted:
        [aListener use];
        break;
    case WebNavigationTypeReload:
        // Reloads our own content.
        [aListener ignore];
        if (_URLRequest != nil)
            [(WebFrame *)aFrame loadRequest:_URLRequest];
        else
            [(WebFrame *)aFrame loadHTMLString:_HTMLString baseURL:_baseURL];
        break;
    case WebNavigationTypeOther: {
        id URL = [aAction objectForKey:WebActionOriginalURLKey];
        if ([[URL absoluteString] isEqualToString:@"about:blank"]) {
            [aListener use];
            break;
        }
        [aListener ignore];
        if (URL != nil)
            [[NSWorkspace sharedWorkspace] openURL:URL];
        break;
    }
    default: {
        // Links and back/forward go to the browser.
        [aListener ignore];
        id URL = [aAction objectForKey:WebActionOriginalURLKey];
        if (URL != nil)
            [[NSWorkspace sharedWorkspace] openURL:URL];
        break;
    }
    }
}

- (void)webView:(id)aView didFinishLoadForFrame:(id)aFrame
{
    if ([_webView mainFrame] != aFrame)
        return;
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(HSWebRenderer_performReleasePreviewImage) target:self argument:nil];
    CGImageRelease(_previewImage);
    _previewImage = [self HSWebRenderer_copyWebImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSWebRendererDidUpdatePreviewImageNotificationName object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSWebRendererDidUpdateNotificationName object:self];
}

- (void)webView:(id)aView resource:(id)aResource didReceiveAuthenticationChallenge:(id)aChallenge fromDataSource:(id)aSource
{
    [[aChallenge sender] cancelAuthenticationChallenge:aChallenge];
}

- (void)reclaimWebView
{
    [_webView setHostWindow:_webWindow];
    [_webView setFrameLoadDelegate:(id)self];
    [self HSWebRenderer_claimWebView];
}

- (id)ejectWebView
{
    [_webWindow setContentView:nil];
    return _webView;
}

- (struct CGImage *)previewImage
{
    return _previewImage;
}

- (void)drawInRect:(NSRect)aRect clipToRect:(NSRect)aRect2
{
    if (_webView == nil)
        return;
    CGImageRef image = [self HSWebRenderer_copyWebImage];
    if (image != NULL) {
        CGContextDrawImage([[NSGraphicsContext currentContext] CGContext], NSRectToCGRect(aRect), image);
        CGImageRelease(image);
    }
}

- (void)stop
{
    // The original wrapped the play count on an unbalanced stop.
    if (_playCount == 0)
        return;
    if (--_playCount == 0) {
        [_updateTimer invalidate];
        [_updateTimer release];
        _updateTimer = nil;
        [self HSWebRenderer_destroyWebView];
        [self HSWebRenderer_releasePreviewImage];
    }
}

- (void)play
{
    if (_playCount++ == 0)
        [self HSWebRenderer_loadAndLayoutIfNeeded];
}

- (BOOL)isPlaying
{
    return _playCount != 0;
}

- (void)setUpdateRate:(CGFloat)aRate
{
    if (!(aRate < _updateRate - 1.0 / 3600.0 || _updateRate + 1.0 / 3600.0 < aRate))
        return;
    _updateRate = (float)aRate;
    if (_playCount != 0) {
        [_updateTimer invalidate];
        [_updateTimer release];
        _updateTimer = nil;
        [self HSWebRenderer_scheduleUpdateTimerIfNeeded];
    }
}

- (CGFloat)updateRate
{
    return _updateRate;
}

- (void)setPageSize:(NSSize)aSize
{
    const CGFloat tolerance = 1.0 / 512.0;
    if (!(aSize.width < _pageSize.width - tolerance || _pageSize.width + tolerance < aSize.width ||
          aSize.height < _pageSize.height - tolerance || _pageSize.height + tolerance < aSize.height))
        return;
    _pageSize = aSize;
    if (_playCount != 0) {
        [self HSWebRenderer_loadAndLayoutIfNeeded];
        if (_previewImage != NULL) {
            CGImageRelease(_previewImage);
            _previewImage = [self HSWebRenderer_copyWebImage];
            [[NSNotificationCenter defaultCenter] postNotificationName:HSWebRendererDidUpdatePreviewImageNotificationName object:self];
        }
    }
}

- (NSSize)pageSize
{
    return _pageSize;
}

- (void)setHTMLString:(id)aString baseURL:(id)aURL
{
    BOOL sameHTML = [_HTMLString isEqualToString:aString];
    BOOL baseChanged = aURL == nil ? _baseURL != nil : ![_baseURL isEqual:aURL];
    if (sameHTML && !baseChanged)
        return;
    [_URLRequest release];
    _URLRequest = nil;
    if (!sameHTML) {
        [_HTMLString release];
        _HTMLString = [aString copy];
    }
    if (baseChanged) {
        [_baseURL release];
        _baseURL = [aURL copy];
    }
    if (_playCount != 0) {
        [self HSWebRenderer_releasePreviewImage];
        if (_HTMLString == nil)
            [self HSWebRenderer_destroyWebView];
        else if (_webView == nil)
            [self HSWebRenderer_loadAndLayoutIfNeeded];
        else
            [[_webView mainFrame] loadHTMLString:_HTMLString baseURL:_baseURL];
    }
}

- (id)baseURL
{
    return _baseURL;
}

- (id)HTMLString
{
    return _HTMLString;
}

- (void)setURL:(id)aURL
{
    if ([[_URLRequest URL] isEqual:aURL])
        return;
    [_HTMLString release];
    _HTMLString = nil;
    [_baseURL release];
    _baseURL = nil;
    [_URLRequest release];
    _URLRequest = [[NSURLRequest alloc] initWithURL:aURL];
    if (_playCount != 0) {
        [self HSWebRenderer_releasePreviewImage];
        if (_URLRequest == nil)
            [self HSWebRenderer_destroyWebView];
        else if (_webView == nil)
            [self HSWebRenderer_loadAndLayoutIfNeeded];
        else
            [[_webView mainFrame] loadRequest:_URLRequest];
    }
}

- (id)URL
{
    return [_URLRequest URL];
}

// Deferred to the next run loop pass, so that a new load can replace the
// preview without it going away in between.
- (void)HSWebRenderer_releasePreviewImage
{
    if (_previewImage == NULL)
        return;
    NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil];
    if (modes != nil)
        [[NSRunLoop currentRunLoop] performSelector:@selector(HSWebRenderer_performReleasePreviewImage) target:self argument:nil order:(NSUInteger)-1 modes:modes];
}

- (void)HSWebRenderer_performReleasePreviewImage
{
    if (_previewImage == NULL)
        return;
    CGImageRelease(_previewImage);
    _previewImage = NULL;
    [[NSNotificationCenter defaultCenter] postNotificationName:HSWebRendererDidUpdatePreviewImageNotificationName object:self];
}

// Snapshots the web view through the offscreen window. An ejected web view is
// borrowed back for the snapshot and returned to its place afterwards.
- (struct CGImage *)HSWebRenderer_copyWebImage
{
    BOOL borrowed = NO;
    id savedResourceLoadDelegate = nil;
    NSView *superview = nil;
    NSWindow *previousWindow = nil;
    id nextSibling = nil;
    BOOL siblingFound = NO;
    NSRect frame = NSZeroRect;
    if ([_webWindow contentView] == nil) {
        savedResourceLoadDelegate = [_webView resourceLoadDelegate];
        superview = [_webView superview];
        if ([_webView hostWindow] == nil)
            [_webView setHostWindow:_webWindow];
        if (superview == nil) {
            previousWindow = [_webView window];
            [previousWindow setContentView:nil];
        } else {
            frame = [_webView frame];
            // Remember the view above the web view to restore its z-order.
            BOOL passed = NO;
            for (NSView *view in [superview subviews]) {
                if (view == _webView) {
                    passed = YES;
                    siblingFound = YES;
                } else if (passed) {
                    nextSibling = view;
                    break;
                }
            }
            [_webView removeFromSuperviewWithoutNeedingDisplay];
        }
        [self HSWebRenderer_claimWebView];
        borrowed = YES;
    }
    [_webView displayIfNeeded];
    CGImageRef image = [_webWindow NSE_copyImageFromRect:[_webView frame]];
    if (borrowed) {
        [_webWindow setContentView:nil];
        [_webView setResourceLoadDelegate:savedResourceLoadDelegate];
        if (superview == nil) {
            [previousWindow setContentView:_webView];
        } else {
            [_webView setFrame:frame];
            // Below the next sibling, or on top when it was the topmost (the
            // original passed a bogus sibling when the web view was missing).
            if (siblingFound && nextSibling != nil)
                [superview addSubview:_webView positioned:NSWindowBelow relativeTo:nextSibling];
            else
                [superview addSubview:_webView positioned:NSWindowAbove relativeTo:nil];
        }
    }
    return image;
}

- (BOOL)HSWebRenderer_loadAndLayoutIfNeeded
{
    const CGFloat tolerance = 1.0 / 512.0;
    if ((_URLRequest == nil && _HTMLString == nil) || !(tolerance < _pageSize.width) || !(tolerance < _pageSize.height))
        return NO;
    if (_webWindow == nil) {
        NSRect contentRect = { NSZeroPoint, _pageSize };
        _webWindow = [[HSWebRendererWindow alloc] initWithContentRect:contentRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
        if (_webWindow == nil)
            return NO;
        [_webWindow setReleasedWhenClosed:NO];
        [_webWindow setOpaque:NO];
        [_webWindow setBackgroundColor:[NSColor clearColor]];
        [_webWindow useOptimizedDrawing:YES];
    } else {
        [_webWindow setContentSize:_pageSize];
    }
    if (_webView == nil && ![self HSWebRenderer_createWebView])
        return NO;
    if (_updateTimer == nil)
        [self HSWebRenderer_scheduleUpdateTimerIfNeeded];
    return YES;
}

- (BOOL)HSWebRenderer_scheduleUpdateTimerIfNeeded
{
    if (!(1.0 / 3600.0 < _updateRate))
        return YES;
    _updateTimer = [[NSTimer timerWithTimeInterval:fmax(1.0 / _updateRate, 1.0 / 30.0) target:self selector:@selector(HSWebRenderer_updateTimerFireMethod:) userInfo:nil repeats:YES] retain];
    if (_updateTimer == nil)
        return NO;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_updateTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_updateTimer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_updateTimer forMode:NSModalPanelRunLoopMode];
    return YES;
}

- (void)HSWebRenderer_updateTimerFireMethod:(id)aMethod
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSWebRendererDidUpdateNotificationName object:self];
}

- (void)HSWebRenderer_destroyWebView
{
    [_webView setResourceLoadDelegate:nil];
    [_webView setFrameLoadDelegate:nil];
    [_webView setPolicyDelegate:nil];
    [_webView setUIDelegate:nil];
    [_webWindow setContentView:nil];
    [_webView close];
    [_webView release];
    _webView = nil;
}

- (BOOL)HSWebRenderer_createWebView
{
    NSRect frame = { NSZeroPoint, _pageSize };
    _webView = [[HSWebView alloc] initWithFrame:frame];
    WebFrame *mainFrame = [_webView mainFrame];
    if (mainFrame == nil) {
        [_webView release];
        _webView = nil;
        return NO;
    }
    [[mainFrame frameView] setAllowsScrolling:NO];
    [_webView setMaintainsBackForwardList:NO];
    [_webView setHostWindow:_webWindow];
    [_webView setFrameLoadDelegate:(id)self];
    [self HSWebRenderer_claimWebView];
    if (_URLRequest != nil)
        [mainFrame loadRequest:_URLRequest];
    else
        [mainFrame loadHTMLString:_HTMLString baseURL:_baseURL];
    return YES;
}

- (void)HSWebRenderer_claimWebView
{
    [_webView setUIDelegate:(id)self];
    [_webView setPolicyDelegate:(id)self];
    [_webView setResourceLoadDelegate:(id)self];
    [_webWindow setContentView:_webView];
}

- (void)dealloc
{
    [_navigationWebView setPolicyDelegate:nil];
    [_navigationWebView close];
    [_navigationWebView release];
    CGImageRelease(_previewImage);
    [_updateTimer invalidate];
    [_updateTimer release];
    if ([_webView resourceLoadDelegate] == self)
        [_webView setResourceLoadDelegate:nil];
    if ([_webView frameLoadDelegate] == self)
        [_webView setFrameLoadDelegate:nil];
    if ([_webView policyDelegate] == self)
        [_webView setPolicyDelegate:nil];
    if ([_webView UIDelegate] == self)
        [_webView setUIDelegate:nil];
    // An ejected web view stays open for its new owner.
    if ([_webWindow contentView] == _webView) {
        [_webView close];
        [_webView setHostWindow:nil];
    }
    [_webView release];
    [_webWindow release];
    [_URLRequest release];
    [_HTMLString release];
    [_baseURL release];
    [super dealloc];
}

- (CGImageRef)copyPreviewImageWithScale:(CGSize)aScale
{
    if (aScale.width == 1.0 && aScale.height == 1.0)
        return CGImageRetain(_previewImage);
    NSSize windowSize = [_webWindow frame].size;
    NSSize viewSize = [_webView frame].size;
    [_webView scaleUnitSquareToSize:aScale];
    NSSize scaledSize = NSMakeSize(aScale.width * viewSize.width, aScale.height * viewSize.height);
    [_webView setFrameSize:scaledSize];
    [_webWindow setContentSize:scaledSize];
    CGImageRef image = [self HSWebRenderer_copyWebImage];
    [_webView setFrameSize:viewSize];
    [_webView setBoundsSize:viewSize];
    [_webWindow setContentSize:windowSize];
    return image;
}

@end

// Display only: never takes mouse events.
@implementation HSWebView

- (id)hitTest:(NSPoint)aTest
{
    return nil;
}

@end

// Never shown, never key or main.
@implementation HSWebRendererWindow

- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo
{
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (BOOL)canBecomeKeyWindow
{
    return NO;
}

@end
