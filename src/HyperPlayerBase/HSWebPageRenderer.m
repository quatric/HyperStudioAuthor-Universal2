#import "HSWebPageRenderer.h"

// Renders a web page offscreen in a cache window. Load states: 0 idle,
// 1 loading, 3 loaded. Pages refreshed less often than every 30 s are torn
// down between refreshes and prepared again 30 s before the next one.
@implementation HSWebPageRenderer
- (id)webPageImage
{
    return _webPageImage;
}
- (void)setWebPageImage:(id)aImage
{
    if (_webPageImage != aImage) {
        [_webPageImage release];
        _webPageImage = [aImage retain];
    }
}
- (void)reload
{
    [self stopLoading];
    [self startLoading];
}
- (void)webView:(id)aView resource:(id)aResource didReceiveAuthenticationChallenge:(id)aChallenge fromDataSource:(id)aSource
{
    [[aChallenge sender] cancelAuthenticationChallenge:aChallenge];
}
- (void)authenticationDoneWithChallenge:(id)aChallenge result:(id)aResult
{
    if (aResult)
        [[aChallenge sender] useCredential:aResult forAuthenticationChallenge:aChallenge];
    else
        [[aChallenge sender] cancelAuthenticationChallenge:aChallenge];
}
// Draws the cached window contents once loaded, else the placeholder image.
- (void)drawInRect:(NSRect)aRect
{
    if (_loadState == 3) {
        if (!_cache) {
            [_cacheWindow displayIfNeeded];
            _cache = [[NSCachedImageRep alloc] initWithWindow:_cacheWindow rect:[_cacheWindow contentRectForFrameRect:[_cacheWindow frame]]];
        }
        if (_cache) {
            [_cache drawInRect:aRect];
            return;
        }
    }
    [_webPageImage drawInRect:aRect fromRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, _pageSize.width, _pageSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
}
- (void)HSWebPageRenderer_prepareTimerFireMethod:(id)aMethod
{
    if (!_webView)
        [self createWebViewStructure];
    [[_webView mainFrame] loadRequest:_URLRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSWebPageRenderer_viewProgressFinished:) name:WebViewProgressFinishedNotification object:_webView];
    [_preparationTimer invalidate];
    [_preparationTimer autorelease];
    _preparationTimer = nil;
}
- (void)HSWebPageRenderer_invalidateCacheTimerFireMethod:(id)aMethod
{
    [self HSWebPageRenderer_invalidate];
}
- (void)stopLoading
{
    if (_loadState == 0)
        return;
    [[_webView mainFrame] stopLoading];
    _loadState = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebViewProgressFinishedNotification object:_webView];
    [self HSWebPageRenderer_stopInvalidation];
    [self destroyWebViewStructure];
    if (_preparationTimer) {
        [_preparationTimer invalidate];
        [_preparationTimer autorelease];
        _preparationTimer = nil;
    }
}
- (void)startLoading
{
    if (_loadState != 0)
        return;
    _loadState = 1;
    if (!_webView)
        [self createWebViewStructure];
    [[_webView mainFrame] loadRequest:_URLRequest];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSWebPageRenderer_viewProgressFinished:) name:WebViewProgressFinishedNotification object:_webView];
}
- (NSInteger)loadState
{
    return _loadState;
}
- (CGFloat)refreshRate
{
    return _refreshRate;
}
- (void)setRefreshRate:(CGFloat)aRate
{
    if (_refreshRate == (float)aRate)
        return;
    _refreshRate = (float)aRate;
    if (_invalidationTimer) {
        [self HSWebPageRenderer_stopInvalidation];
        [self HSWebPageRenderer_startInvalidationIfNeeded];
    }
    if (_preparationTimer) {
        [_preparationTimer invalidate];
        [_preparationTimer autorelease];
        _preparationTimer = nil;
    }
}
- (void)HSWebPageRenderer_viewProgressFinished:(id)aFinished
{
    _loadState = 3;
    [self HSWebPageRenderer_startInvalidationIfNeeded];
    _firstInvalidationAfterFrameDidLoad = YES;
}
// Unloads the web view until shortly before the next refresh.
- (void)HSWebPageRenderer_unloadUntilRefreshWithLead:(double)aLead
{
    [[_webView mainFrame] stopLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebViewProgressFinishedNotification object:_webView];
    [self destroyWebViewStructure];
    if (_preparationTimer) {
        [_preparationTimer invalidate];
        [_preparationTimer release];
        _preparationTimer = nil;
    }
    _preparationTimer = [[NSTimer alloc] initWithFireDate:[[_invalidationTimer fireDate] dateByAddingTimeInterval:aLead] interval:_refreshRate target:self selector:@selector(HSWebPageRenderer_prepareTimerFireMethod:) userInfo:nil repeats:NO];
    if (_preparationTimer) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_preparationTimer forMode:NSDefaultRunLoopMode];
        [runLoop addTimer:_preparationTimer forMode:NSModalPanelRunLoopMode];
    }
}
// Drops the cached image and tells observers; the first time after a load
// also posts HSWebPageDidLoadNotification.
- (void)HSWebPageRenderer_invalidate
{
    [_cache release];
    _cache = nil;
    if (_firstInvalidationAfterFrameDidLoad) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSWebPageDidLoadNotification" object:self userInfo:nil];
        _firstInvalidationAfterFrameDidLoad = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSWebPageDidUpdateNotification" object:self userInfo:nil];
    if (_refreshRate > 30.0f && _invalidationTimer)
        [self HSWebPageRenderer_unloadUntilRefreshWithLead:_refreshRate - 30.0f];
}
- (void)HSWebPageRenderer_startInvalidationIfNeeded
{
    if (_invalidationTimer)
        return;
    _invalidationTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:_refreshRate target:self selector:@selector(HSWebPageRenderer_invalidateCacheTimerFireMethod:) userInfo:nil repeats:YES];
    if (!_invalidationTimer)
        return;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_invalidationTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_invalidationTimer forMode:NSModalPanelRunLoopMode];
    if (_refreshRate > 30.0f)
        [self HSWebPageRenderer_unloadUntilRefreshWithLead:-30.0];
}
- (void)HSWebPageRenderer_stopInvalidation
{
    [_invalidationTimer invalidate];
    [_invalidationTimer release];
    _invalidationTimer = nil;
}
- (void)destroyWebViewStructure
{
    [_webView setResourceLoadDelegate:nil];
    [_webView removeFromSuperviewWithoutNeedingDisplay];
    [_webView release];
    _webView = nil;
    [_cache release];
    _cache = nil;
}
- (void)createWebViewStructure
{
    _webView = [[WebView alloc] initWithFrame:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, _pageSize.width, _pageSize.height)];
    [_webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_webView setResourceLoadDelegate:(id)self];
    [[_cacheWindow contentView] addSubview:_webView];
    [[[_webView mainFrame] frameView] setAllowsScrolling:NO];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_preparationTimer invalidate];
    [_preparationTimer release];
    [_invalidationTimer invalidate];
    [_invalidationTimer release];
    [_webView setResourceLoadDelegate:nil];
    [_webView removeFromSuperviewWithoutNeedingDisplay];
    [_webView release];
    [_URLRequest release];
    [_cache release];
    [_cacheWindow release];
    [_webPageImage release];
    [super dealloc];
}
- (id)initWithURLRequest:(id)aRequest pageSize:(NSSize)aSize refreshRate:(CGFloat)aRate
{
    self = [super init];
    if (self) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        _URLRequest = [aRequest copy];
        _pageSize = aSize;
        _refreshRate = (float)aRate;
        _loadState = 0;
        _cacheWindow = [[HSWebPageCacheWindow webPageCacheWindowWithContentRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height)] retain];
        [self createWebViewStructure];
        [pool release];
    }
    return self;
}
@end
