#import "HSYouTubeRenderer.h"
// Renders a YouTube object: the page is loaded into a web view in an
// offscreen cache window, and its contents are cached as an image once
// loaded. While loading (30 s at most) or offline a placeholder is drawn.
// States: -1 connecting, 0 offline, 1 loaded.

static void HSYouTubeRendererTimeout(CFRunLoopTimerRef aTimer, void *aInfo)
{
    [(HSYouTubeRenderer *)aInfo HSYouTubeRenderer_invalidate];
}

@implementation HSYouTubeRenderer
// A copy of the cache as a plain image (cached as is).
- (id)updateYouTubeImage
{
    [_youTubeImage release];
    _youTubeImage = nil;
    if (_cache != nil) {
        id cacheCopy = [_cache copy];
        if (cacheCopy != nil) {
            HSCachedImageRep *rep = [[HSCachedImageRep alloc] initWithCachedImageRep:cacheCopy];
            [cacheCopy release];
            if (rep != nil) {
                _youTubeImage = [[NSImage alloc] initWithSize:_movieSize];
                [_youTubeImage setCacheMode:NSImageCacheNever];
                [_youTubeImage addRepresentation:rep];
                [rep release];
            }
        }
    }
    return _youTubeImage;
}
- (void)setYouTubeImage:(id)aImage
{
    if (_youTubeImage == aImage)
        return;
    [_youTubeImage release];
    _youTubeImage = [aImage retain];
}
- (void)getPlaceholderLabel:(id *)aLabel icon:(id *)aIcon
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSImage *icon;
    if (_youTubeState == -1) {
        if (aLabel != NULL)
            *aLabel = [bundle localizedStringForKey:@"Connecting..." value:@"" table:@"HyperPlayerBase"];
        if (aIcon == NULL)
            return;
        icon = [HSPlayerBaseID imageNamed:@"YouTubeObjectIcon"];
    } else if (_youTubeState == 0) {
        if (aLabel != NULL)
            *aLabel = [bundle localizedStringForKey:@"Offline" value:@"" table:@"HyperPlayerBase"];
        if (aIcon == NULL)
            return;
        icon = [HSPlayerBaseID imageNamed:@"YouTubeObjectOffIcon"];
    } else {
        if (aLabel != NULL)
            *aLabel = [bundle localizedStringForKey:@"YouTube" value:@"" table:@"HyperPlayerBase"];
        if (aIcon == NULL)
            return;
        icon = [HSPlayerBaseID imageNamed:@"YouTubeObjectIcon"];
    }
    *aIcon = icon;
    [icon setCacheMode:NSImageCacheNever];
}
- (void)webView:(id)aView resource:(id)aResource didReceiveAuthenticationChallenge:(id)aChallenge fromDataSource:(id)aSource
{
    [[aChallenge sender] cancelAuthenticationChallenge:aChallenge];
}
- (void)authenticationDoneWithChallenge:(id)aChallenge result:(id)aResult
{
    if (aResult != nil)
        [[aChallenge sender] useCredential:aResult forAuthenticationChallenge:aChallenge];
    else
        [[aChallenge sender] cancelAuthenticationChallenge:aChallenge];
}
// The cache or image is drawn flipped into aRect; the placeholder is a
// translucent blue box with a dark and a light frame, the state icon
// centred above the white bold label (both drawn upright).
- (void)drawCurrentFrameInRect:(NSRect)aRect
{
    if (_isDetached)
        return;
    CGAffineTransform flip = { 1, 0, 0, -1, 0, (CGFloat)(float)(aRect.origin.y * 2.0 + aRect.size.height) };
    if (_cache != nil) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
        [_cache drawInRect:aRect];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        return;
    }
    if (_youTubeImage != nil) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
        NSSize imageSize = [_youTubeImage size];
        [_youTubeImage drawInRect:aRect fromRect:(NSRect){ NSZeroPoint, imageSize } operation:NSCompositingOperationSourceOver fraction:1.0];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        return;
    }
    [NSBezierPath clipRect:aRect];
    [[NSColor colorWithCalibratedRed:0.25 green:0.5 blue:0.75 alpha:0.25] set];
    [[NSBezierPath bezierPathWithRect:aRect] fill];
    NSRect frame = NSMakeRect(aRect.origin.x, aRect.origin.y, aRect.size.width - 0.5f, aRect.size.height - 0.5f);
    [[NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:0.25] set];
    [[NSBezierPath bezierPathWithRect:frame] stroke];
    [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.25] set];
    [[NSBezierPath bezierPathWithRect:NSInsetRect(frame, 1.0, 1.0)] stroke];
    NSString *labelString = nil;
    NSImage *icon = nil;
    [self getPlaceholderLabel:&labelString icon:&icon];
    NSMutableAttributedString *label = nil;
    if ([labelString length] != 0) {
        NSRange range = NSMakeRange(0, [labelString length]);
        label = [[[NSMutableAttributedString alloc] initWithString:labelString] autorelease];
        [label addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:range];
        [label addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]] range:range];
    }
    NSSize labelSize = label != nil ? [label size] : NSZeroSize;
    NSSize iconSize = icon != nil ? [icon size] : NSZeroSize;
    float freeHeight = (float)(aRect.size.height - ((float)(iconSize.height + labelSize.height) + 10.0));
    float margin = freeHeight > 0 ? freeHeight * 0.5f : 0.0f;
    if (icon != nil) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
        float x = aRect.origin.x;
        if (aRect.size.width > iconSize.width)
            x = (float)(x + (aRect.size.width - iconSize.width) * 0.5);
        float y = (float)(aRect.origin.y + aRect.size.height) - (float)(iconSize.height + margin);
        [icon drawAtPoint:NSMakePoint(x, y) fromRect:(NSRect){ NSZeroPoint, iconSize } operation:NSCompositingOperationSourceOver fraction:1.0];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    float labelX = aRect.origin.x;
    float offset;
    BOOL flipped = NO;
    if ([context isFlipped])
        offset = (float)aRect.size.height - (float)(margin + labelSize.height);
    else {
        // Draw the label upright in an unflipped context.
        [context saveGraphicsState];
        CGContextConcatCTM([context CGContext], flip);
        offset = margin;
        flipped = YES;
    }
    float labelY = (float)aRect.origin.y + offset;
    if (aRect.size.width > labelSize.width)
        labelX = (float)(labelX + (aRect.size.width - labelSize.width) * 0.5);
    [label drawAtPoint:NSMakePoint(labelX, MAX((float)aRect.origin.y, labelY))];
    if (flipped)
        [context restoreGraphicsState];
}
// Snapshots the cache window's content.
- (void)invalidateCache
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"HSYouTubeRendererWillUpdateFrameImageNotification" object:self];
    [_cache release];
    [_cacheWindow displayIfNeeded];
    _cache = (NSCachedImageRep *)[[HSCachedImageRep alloc] initWithWindow:_cacheWindow rect:[_cacheWindow contentRectForFrameRect:[_cacheWindow frame]]];
    [center postNotificationName:@"HSYouTubeRendererDidUpdateFrameImageNotification" object:self];
}
- (void)webView:(id)aView didFinishLoadForFrame:(id)aFrame
{
    if ([_webView mainFrame] != aFrame)
        return;
    if (_timeoutTimer != NULL) {
        CFRunLoopTimerInvalidate(_timeoutTimer);
        CFRelease(_timeoutTimer);
        _timeoutTimer = NULL;
    }
    _youTubeState = 1;
    if (_cache == nil)
        [self performSelector:@selector(invalidateCache) withObject:nil afterDelay:1.5];
}
// Loading timed out: offline.
- (void)HSYouTubeRenderer_invalidate
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"HSYouTubeRendererWillUpdateFrameImageNotification" object:self];
    _youTubeState = 0;
    [self destroyWebViewStructure];
    if (_cache != nil) {
        [_cache release];
        _cache = nil;
    }
    [center postNotificationName:@"HSYouTubeRendererDidUpdateFrameImageNotification" object:self];
}
- (void)reattach
{
    _isDetached = NO;
    [self destroyWebViewStructure];
    [self createWebViewStructure];
}
- (void)detach
{
    _isDetached = YES;
}
- (id)interactiveView
{
    return _webView;
}
- (void)destroyWebViewStructure
{
    if (_timeoutTimer != NULL) {
        CFRunLoopTimerInvalidate(_timeoutTimer);
        CFRelease(_timeoutTimer);
        _timeoutTimer = NULL;
    }
    if ([_webView resourceLoadDelegate] == (id)self)
        [_webView setResourceLoadDelegate:nil];
    if ([_webView frameLoadDelegate] == (id)self)
        [_webView setFrameLoadDelegate:nil];
    [_webView removeFromSuperviewWithoutNeedingDisplay];
    [_webView release];
    _webView = nil;
}
- (void)createWebViewStructure
{
    _webView = [[WebView alloc] initWithFrame:(NSRect){ NSZeroPoint, _movieSize }];
    [_webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_webView setResourceLoadDelegate:(id)self];
    [[_cacheWindow contentView] addSubview:_webView];
    [_webView setFrameLoadDelegate:(id)self];
    [[[_webView mainFrame] frameView] setAllowsScrolling:NO];
    [[_webView mainFrame] loadRequest:_URLRequest];
    CFRunLoopTimerContext context = { 0, self, NULL, NULL, NULL };
    _timeoutTimer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 30.0, 0, 0, 0, HSYouTubeRendererTimeout, &context);
    if (_timeoutTimer != NULL)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), _timeoutTimer, kCFRunLoopCommonModes);
}
- (void)dealloc
{
    [self destroyWebViewStructure];
    [_URLRequest release];
    [_cache release];
    [_cacheWindow release];
    [_youTubeImage release];
    [super dealloc];
}
- (id)initWithURL:(id)aURL movieSize:(NSSize)aSize
{
    self = [super init];
    if (self == nil)
        return nil;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _URLRequest = [[NSURLRequest alloc] initWithURL:aURL];
    _movieSize = aSize;
    _cacheWindow = [[HSYouTubeCacheWindow youTubeCacheWindowWithContentRect:(NSRect){ NSZeroPoint, aSize }] retain];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"HSYouTubeRendererWillUpdateFrameImageNotification" object:self];
    [self createWebViewStructure];
    _youTubeState = -1;
    [center postNotificationName:@"HSYouTubeRendererDidUpdateFrameImageNotification" object:self];
    [pool release];
    return self;
}
@end
