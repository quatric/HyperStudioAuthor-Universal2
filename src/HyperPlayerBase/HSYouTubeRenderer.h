#import "HyperPlayerBasePrefix.h"


@interface HSYouTubeRenderer : NSObject <HSYouTubeRendering, NSObject>
{
    NSURLRequest *_URLRequest;
    NSWindow *_cacheWindow;
    WebView *_webView;
    NSCachedImageRep *_cache;
    NSSize _movieSize;
    int _youTubeState;
    struct __CFRunLoopTimer *_timeoutTimer;
    BOOL _isDetached;
    NSImage *_youTubeImage;
}
- (id)updateYouTubeImage;
- (void)setYouTubeImage:(id)aImage;
- (void)getPlaceholderLabel:(id *)aLabel icon:(id *)aIcon;
- (void)webView:(id)aView resource:(id)aResource didReceiveAuthenticationChallenge:(id)aChallenge fromDataSource:(id)aSource;
- (void)authenticationDoneWithChallenge:(id)aChallenge result:(id)aResult;
- (void)drawCurrentFrameInRect:(NSRect)aRect;
- (void)invalidateCache;
- (void)webView:(id)aView didFinishLoadForFrame:(id)aFrame;
- (void)HSYouTubeRenderer_invalidate;
- (void)reattach;
- (void)detach;
- (id)interactiveView;
- (void)destroyWebViewStructure;
- (void)createWebViewStructure;
- (void)dealloc;
- (id)initWithURL:(id)aURL movieSize:(NSSize)aSize;
@end

