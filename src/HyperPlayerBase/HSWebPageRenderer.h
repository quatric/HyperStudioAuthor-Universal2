#import "HyperPlayerBasePrefix.h"


@interface HSWebPageRenderer : NSObject
{
    NSURLRequest *_URLRequest;
    NSWindow *_cacheWindow;
    WebView *_webView;
    NSTimer *_invalidationTimer;
    NSTimer *_preparationTimer;
    NSCachedImageRep *_cache;
    BOOL _firstInvalidationAfterFrameDidLoad;
    float _refreshRate;
    NSSize _pageSize;
    int _loadState;
    NSImage *_webPageImage;
}
- (id)webPageImage;
- (void)setWebPageImage:(id)aImage;
- (void)reload;
- (void)webView:(id)aView resource:(id)aResource didReceiveAuthenticationChallenge:(id)aChallenge fromDataSource:(id)aSource;
- (void)authenticationDoneWithChallenge:(id)aChallenge result:(id)aResult;
- (void)drawInRect:(NSRect)aRect;
- (void)HSWebPageRenderer_prepareTimerFireMethod:(id)aMethod;
- (void)HSWebPageRenderer_invalidateCacheTimerFireMethod:(id)aMethod;
- (void)stopLoading;
- (void)startLoading;
- (NSInteger)loadState;
- (CGFloat)refreshRate;
- (void)setRefreshRate:(CGFloat)aRate;
- (void)HSWebPageRenderer_viewProgressFinished:(id)aFinished;
- (void)HSWebPageRenderer_invalidate;
- (void)HSWebPageRenderer_startInvalidationIfNeeded;
- (void)HSWebPageRenderer_stopInvalidation;
- (void)destroyWebViewStructure;
- (void)createWebViewStructure;
- (void)dealloc;
- (id)initWithURLRequest:(id)aRequest pageSize:(NSSize)aSize refreshRate:(CGFloat)aRate;
@end

