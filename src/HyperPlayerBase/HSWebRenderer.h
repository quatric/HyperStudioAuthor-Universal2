#import "HyperPlayerBasePrefix.h"


@interface HSWebRenderer : NSObject
{
    NSURLRequest *_URLRequest;
    NSString *_HTMLString;
    NSURL *_baseURL;
    NSSize _pageSize;
    float _updateRate;
    unsigned int _playCount;
    WebView *_webView;
    NSWindow *_webWindow;
    NSTimer *_updateTimer;
    struct CGImage *_previewImage;
    WebView *_navigationWebView;
}
- (id)webView:(id)aView contextMenuItemsForElement:(id)aElement defaultMenuItems:(id)aItems;
- (id)webView:(id)aView createWebViewWithRequest:(id)aRequest;
- (void)webView:(id)aView decidePolicyForNavigationAction:(id)aAction request:(id)aRequest frame:(id)aFrame decisionListener:(id)aListener;
- (void)webView:(id)aView didFinishLoadForFrame:(id)aFrame;
- (void)webView:(id)aView resource:(id)aResource didReceiveAuthenticationChallenge:(id)aChallenge fromDataSource:(id)aSource;
- (void)reclaimWebView;
- (id)ejectWebView;
- (struct CGImage *)previewImage;
- (void)drawInRect:(NSRect)aRect clipToRect:(NSRect)aRect2;
- (void)stop;
- (void)play;
- (BOOL)isPlaying;
- (void)setUpdateRate:(CGFloat)aRate;
- (CGFloat)updateRate;
- (void)setPageSize:(NSSize)aSize;
- (NSSize)pageSize;
- (void)setHTMLString:(id)aString baseURL:(id)aURL;
- (id)baseURL;
- (id)HTMLString;
- (void)setURL:(id)aURL;
- (id)URL;
- (void)HSWebRenderer_releasePreviewImage;
- (void)HSWebRenderer_performReleasePreviewImage;
- (struct CGImage *)HSWebRenderer_copyWebImage;
- (BOOL)HSWebRenderer_loadAndLayoutIfNeeded;
- (BOOL)HSWebRenderer_scheduleUpdateTimerIfNeeded;
- (void)HSWebRenderer_updateTimerFireMethod:(id)aMethod;
- (void)HSWebRenderer_destroyWebView;
- (BOOL)HSWebRenderer_createWebView;
- (void)HSWebRenderer_claimWebView;
- (void)dealloc;
@end

@interface HSWebView : WebView
{
}
- (id)hitTest:(NSPoint)aTest;
@end

@interface HSWebRendererWindow : NSWindow
{
}
- (void)orderWindow:(NSInteger)aWindow relativeTo:(NSInteger)aTo;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
@end

