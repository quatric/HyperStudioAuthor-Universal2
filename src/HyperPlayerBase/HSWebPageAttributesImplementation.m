#import "HSWebPageAttributesImplementation.h"
#import "HSWebCamRendererRegister.h"
#import "HSWebPageObject.h"
#import "HSWebPageRenderer.h"

// The web page (web cam) attributes of a web page object. Load states: 0 not
// loading, 1 loading, 2 invalid camera, 3 loaded.
@implementation HSWebPageAttributesImplementation

// A valid camera takes its page size and clip rect from the register (not
// undoable) and gets its renderer.
- (void)webCamValidityStateDidChange:(id)aChange
{
    id cameraID = [self webPageCameraID];
    if (aChange != nil && ![[aChange object] isEqualToString:cameraID])
        return;
    HSWebCamRendererRegister *cameras = [HSWebCamRendererRegister sharedWebCamRendererRegister];
    NSInteger state = [cameras validityStateForWebCamWithID:cameraID];
    if (state == 2) {
        [self setWebPageLoadState:2];
    } else if (state == 1) {
        NSSize size = [[HSWebCamRendererRegister sharedWebCamRendererRegister] pageSizeForWebCamWithID:cameraID];
        NSRect clipRect = [[HSWebCamRendererRegister sharedWebCamRendererRegister] clipRectForWebCamWithID:cameraID];
        [[_webPageObject undoManager] disableUndoRegistration];
        [self setWebPageSize:size];
        [self setWebPageCropPath:[NSBezierPath bezierPathWithRect:clipRect]];
        [[_webPageObject undoManager] enableUndoRegistration];
        [self webPageRenderer];
    } else {
        [self setWebPageLoadState:1];
    }
}

- (void)validateWebCam
{
    id cameraID = [self webPageCameraID];
    if ([self loadState] != 3)
        [self setWebPageLoadState:1];
    if ([[HSWebCamRendererRegister sharedWebCamRendererRegister] validityStateForWebCamWithID:cameraID] == 1) {
        [self webCamValidityStateDidChange:nil];
        return;
    }
    HSWebCamRendererRegister *cameras = [HSWebCamRendererRegister sharedWebCamRendererRegister];
    [cameras validateWebCamWithID:cameraID pageSize:[self webPageSize] clipRect:[(NSBezierPath *)[self webPageCropPath] bounds]];
}

- (id)attributeObservingController
{
    return _webPageObject;
}

- (BOOL)isLoading
{
    NSInteger state = [self loadState];
    return state != 2 && state != 0;
}

- (void)reload
{
    [self setWebPageLoadState:1];
    id cameraID = [self webPageCameraID];
    if (_renderer != nil)
        [[HSWebCamRendererRegister sharedWebCamRendererRegister] reloadWebCamWithID:cameraID];
    HSWebCamRendererRegister *cameras = [HSWebCamRendererRegister sharedWebCamRendererRegister];
    [cameras validateWebCamWithID:cameraID pageSize:[self webPageSize] clipRect:[(NSBezierPath *)[self webPageCropPath] bounds]];
}

- (void)stopLoading
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if ([self loadState] == 0) {
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    } else {
        if (_renderer != nil)
            [[HSWebCamRendererRegister sharedWebCamRendererRegister] unregisterWebPageRenderer:_renderer user:self];
        [self setWebPageLoadState:0];
    }
    _renderer = nil;
}

- (void)startLoading
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center removeObserver:self];
    [center addObserver:self selector:@selector(webCamValidityStateDidChange:) name:@"HSWebCamValidityStateDidChangeNotification" object:[self webPageCameraID] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    [self validateWebCam];
}

- (void)HSWebPageAttributesImplementation_webPageDidUpdateNotification:(id)aNotification
{
    [_webPageObject notifyChange:1 ofAttribute:@protocol(HSWebPageContentAttribute) withUserInfo:nil];
    [self setWebPageLoadState:3];
    [_webPageObject notifyChange:2 ofAttribute:@protocol(HSWebPageContentAttribute) withUserInfo:nil];
}

// Registered on first use, once there is a camera and a page URL.
- (id)webPageRenderer
{
    if (_renderer != nil)
        return _renderer;
    id cameraID = [self webPageCameraID];
    if ([cameraID length] == 0)
        return _renderer;
    id URL = [self webPageURL];
    if (URL == nil)
        return _renderer;
    HSWebCamRendererRegister *cameras = [HSWebCamRendererRegister sharedWebCamRendererRegister];
    _renderer = [cameras registeredWebPageRendererForCamID:cameraID pageURL:URL pageSize:[self webPageSize] refreshRate:[self webPageRefreshRate] user:self];
    [_renderer setWebPageImage:[self webPageImage]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSWebPageAttributesImplementation_webPageDidUpdateNotification:) name:@"HSWebCamDidRefreshNotification" object:self];
    return _renderer;
}

- (void)setWebPageImage:(id)aImage
{
    [_webPageObject setWebPageImage:aImage];
}

- (void)setWebPageCopyright:(id)aCopyright
{
    [_webPageObject setPageCopyright:aCopyright];
}

- (void)setWebPageLoadState:(NSInteger)aState
{
    if (_loadState == aState)
        return;
    [_webPageObject notifyChange:1 ofAttribute:@protocol(HSWebPageLoadStateAttribute) withUserInfo:nil];
    _loadState = (int)aState;
    [_webPageObject notifyChange:2 ofAttribute:@protocol(HSWebPageLoadStateAttribute) withUserInfo:nil];
}

- (void)setWebPageTimeZone:(id)aZone
{
    [_webPageObject setPageTimeZone:aZone];
}

- (void)setWebPageLocation:(id)aLocation
{
    [_webPageObject setPageLocation:aLocation];
}

- (void)setWebPageCameraID:(id)aID
{
    [_webPageObject setPageCameraID:aID];
}

- (void)setWebPageRefreshRate:(CGFloat)aRate
{
    [_webPageObject setPageRefreshRate:aRate];
    if (_renderer != nil)
        [[HSWebCamRendererRegister sharedWebCamRendererRegister] setNewRefreshRate:aRate user:self webPageRendererWithCamID:[self webPageCameraID]];
}

- (void)setWebPageTitle:(id)aTitle
{
    [_webPageObject setPageTitle:aTitle];
}

- (void)setWebPageCropPath:(id)aPath
{
    [_webPageObject setPageCropPath:aPath];
}

- (void)setWebPageSize:(NSSize)aSize
{
    [_webPageObject setPageSize:aSize];
}

// A new page drops the old image.
- (void)setWebPageURL:(id)aURL
{
    [_webPageObject setPageURL:aURL];
    [self setWebPageImage:nil];
}

- (id)webPageImage
{
    return [_webPageObject webPageImage];
}

- (id)webPageCopyright
{
    return [_webPageObject pageCopyright];
}

- (NSInteger)loadState
{
    return _loadState;
}

- (id)webPageTimeZone
{
    return [_webPageObject pageTimeZone];
}

- (id)webPageLocation
{
    return [_webPageObject pageLocation];
}

- (id)webPageCameraID
{
    return [_webPageObject pageCameraID];
}

- (CGFloat)webPageRefreshRate
{
    return [_webPageObject pageRefreshRate];
}

- (id)webPageTitle
{
    return [_webPageObject pageTitle];
}

- (NSRect)webPageRect
{
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = [_sizeAttributes size];
    return rect;
}

- (id)webPageCropPath
{
    return [_webPageObject pageCropPath];
}

- (NSSize)webPageSize
{
    return [_webPageObject pageSize];
}

- (id)webPageURL
{
    return [_webPageObject pageURL];
}

- (id)hyperObject
{
    return _webPageObject;
}

- (id)webPageObject
{
    return _webPageObject;
}

- (void)HSWebPageAttributesImplementation_webPageObjectDidChangePageSize:(id)aSize
{
    [self HSWebPageAttributesImplementation_invalidateRenderer];
}

- (void)HSWebPageAttributesImplementation_webPageObjectDidChangePageURL:(id)aURL
{
    [self HSWebPageAttributesImplementation_invalidateRenderer];
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [self HSWebPageAttributesImplementation_invalidateRenderer];
    [_webPageObject removeObserver:self selector:@selector(HSWebPageAttributesImplementation_webPageObjectDidChangePageURL:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebPageURLAttribute)];
    [_webPageObject removeObserver:self selector:@selector(HSWebPageAttributesImplementation_webPageObjectDidChangePageSize:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebPageSizeAttribute)];
    [(id)_sizeAttributes release];
    [_webPageObject release];
    [super dealloc];
}

- (void)HSWebPageAttributesImplementation_invalidateRenderer
{
    if (_renderer == nil)
        return;
    if ([self loadState] != 0) {
        [[HSWebCamRendererRegister sharedWebCamRendererRegister] unregisterWebPageRenderer:_renderer user:self];
        [self setWebPageLoadState:0];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSWebCamDidRefreshNotification" object:self];
    _renderer = nil;
}

// Nil for an object without size attributes.
- (id)initWithWebPageObject:(id)aObject
{
    self = [super init];
    if (self == nil)
        return nil;
    _webPageObject = [aObject retain];
    [_webPageObject associateImplementation:self withInterface:@protocol(HSWebPageAttributes)];
    _sizeAttributes = [[_webPageObject queryHyperInterface:@protocol(HSSizeAttributes)] retain];
    if (_sizeAttributes == nil) {
        [self release];
        return nil;
    }
    [_webPageObject addObserver:self selector:@selector(HSWebPageAttributesImplementation_webPageObjectDidChangePageURL:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebPageURLAttribute) withPriority:0.25];
    [_webPageObject addObserver:self selector:@selector(HSWebPageAttributesImplementation_webPageObjectDidChangePageSize:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSWebPageSizeAttribute) withPriority:0.25];
    [self setWebPageLoadState:0];
    return self;
}

@end
