#import "SMKApplicationKitPrefix.h"


@interface NSEView : NSView <NSEOpenGLCGContextDestination>
{
    id _viewProxy;
    NSRecursiveLock *_openGLLock;
    NSEOpenGLContext *_openGLContext;
    struct _CGLContextObject *_coreGLContext;
    unsigned int _openGLRendererMinVideoMemory;
    NSMutableDictionary *_allowedOpenGLRenderers;
    NSMutableDictionary *_disallowedOpenGLRenderers;
    NSRect _relativeOpenGLSurfaceBounds;
    NSRect _openGLSurfaceViewportRect;
    int _openGLSurfaceBoundsLock;
    int _openGLSurfaceViewportRectLock;
    void *_openGLSurfaceAutodisplayControl;
    struct __NSEViewOpenGLSurfaceInvalidationInfo *_openGLInvalidationInfo;
    NSEOpenGLFramebufferClipper *_openGLFramebufferClipper;
    struct __NSEViewOpenGLDrawingInfo *_openGLDrawingInfo;
    struct __NSEViewQuartzLayer *_quartzLayer;
    struct OpaqueCMProfileRef *_colorSyncProfile;
    struct CGColorSpace *_colorSpace;
    unsigned int _openGLBufferTexture;
    int _isOpenGLSurfaceDisplayLinkUpdateScheduled;
    unsigned int _isOpenGLSurfaceEnabled:1;
    unsigned int _openGLSurfaceAutodisplayMode:2;
    unsigned int _isQuartzBackingEnabled:1;
    unsigned int _disablesOpenGLSurfaceInLiveResize:1;
    unsigned int _isOpenGLSurfaceDisabledDueToLiveResize:1;
    unsigned int _isOpenGLContextAssociated:1;
    unsigned int _isOpenGLContextUpdateQueried:1;
    unsigned int _isOpenGLSurfaceValid:1;
    unsigned int _canDrawOpenGLSurfaceConcurrently:1;
    unsigned int _isOpenGLSurfaceDisplayed:1;
    unsigned int _isObservingWindowDidChangeScreenProfileNotification:1;
    unsigned int _isTextureRectangleExtensionPresenceChecked:1;
    unsigned int _isTextureRectangleExtensionPresent:1;
    unsigned int _isAGPTexturingChecked:1;
    unsigned int _isAGPTexturingCorrect:1;
    unsigned int _isOpenGLFramebufferStable:1;
    unsigned int _isOpenGLFramebufferStabilityChecked:1;
}
+ (id)createDefaultOpenGLContext;
- (BOOL)isOpenGLSurfaceDisplayed;
- (BOOL)needsToDrawOpenGLSurfaceRect:(NSRect)aRect;
- (void)getOpenGLSurfaceRectsBeingDrawn:(NSRect **)aDrawn count:(int *)aCount;
- (void)clearQuartzSurfaceRect:(NSRect)aRect;
- (void)drawRect:(NSRect)aRect;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (id)flushCGContext;
- (id)destinationOpenGLContext;
- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect;
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect;
- (void)NSEView_flushQuartzTexture;
- (void)setCanDrawOpenGLSurfaceConcurrently:(BOOL)aConcurrently;
- (BOOL)canDrawOpenGLSurfaceConcurrently;
- (BOOL)shouldDisplayOpenGLSurface;
- (BOOL)displayOpenGLSurfaceIfNeeded;
- (void)NSEView_autodisplayOpenGLSurfaceByEventLoop;
- (NSInteger)NSEView_displayOpenGLSurfaceAsNeeded;
- (BOOL)displayOpenGLSurface;
- (NSInteger)NSEView_displayOpenGLSurface;
- (NSInteger)NSEView_displayOpenGLSurfaceRect:(NSRect)aRect;
- (BOOL)NSEView_isOpenGLSurfaceValidWithViewportRect:(NSRect *)aRect;
- (NSInteger)NSEView_openGLSurfaceValidnessWithViewportRect:(NSRect *)aRect;
- (NSRect)NSEView_openGLSurfaceViewportBounds;
- (BOOL)needsDisplayOpenGLSurface;
- (void)setNeedsDisplayOpenGLSurfaceInRect:(NSRect)aRect;
- (void)setNeedsDisplayOpenGLSurface:(BOOL)aSurface;
- (void)NSEView_setNeedsDisplay;
- (void)setDisablesOpenGLSurfaceInLiveResize:(BOOL)aResize;
- (BOOL)disablesOpenGLSurfaceInLiveResize;
- (void)setQuartzBackingEnabled:(BOOL)aEnabled;
- (BOOL)isQuartzBackingEnabled;
- (void)NSEView_windowDidChangeScreenProfile:(id)aProfile;
- (void)getOpenGLSurfaceProjectionMatrix:(float *)aMatrix forBounds:(NSRect)aBounds viewportRect:(NSRect)aRect;
- (void)changeOpenGLSurfaceViewportFrom:(int *)aFrom to:(int *)aTo;
- (void)updateOpenGLContext;
- (void)NSEView_openGLSurfaceNeedsUpdate:(id)aUpdate;
- (void)disassociateOpenGLContext;
- (BOOL)associateOpenGLContext;
- (void)unlockAssociatedOpenGLContext;
- (BOOL)lockAssociatedOpenGLContext;
- (BOOL)wantsDefaultOpenGLClipping;
- (BOOL)isInitialQuartzTextureOpaque;
- (BOOL)isOpenGLSurfaceOpaque;
- (void)setOpenGLSurfaceAutodisplayMode:(NSUInteger)aMode;
- (NSUInteger)openGLSurfaceAutodisplayMode;
- (NSUInteger)openGLSurfaceAutodisplayRunLoopOrdering;
- (void)disallowOpenGLRendererWithName:(id)aName vendor:(id)aVendor;
- (void)allowOpenGLRendererWithName:(id)aName vendor:(id)aVendor;
- (BOOL)NSEView_isOpenGLRendererAllowed;
- (BOOL)allowsOpenGLRendererWithName:(id)aName vendor:(id)aVendor;
- (id)disallowedOpenGLRenderers;
- (id)allowedOpenGLRenderers;
- (void)setOpenGLRendererMinVideoMemory:(NSUInteger)aMemory;
- (NSUInteger)openGLRendererMinVideoMemory;
- (NSUInteger)NSEView_openGLRendererVideoMemory;
- (void)setOpenGLContext:(id)aContext;
- (id)openGLContext;
- (NSRect)openGLSurfaceBounds;
- (void)setRelativeOpenGLSurfaceBounds:(NSRect)aBounds;
- (NSRect)relativeOpenGLSurfaceBounds;
- (void)disableOpenGLSurfaceDetachingImmediately:(BOOL)aImmediately;
- (void)enableOpenGLSurface;
- (BOOL)isOpenGLSurfaceEnabled;
- (void)NSEView_disableOpenGLSurface;
- (void)NSEView_scheduleFallBackToQuartz;
- (void)NSEView_delayedFallBackToQuartz;
- (void)NSEView_fallBackToQuartz;
- (void)NSEView_setNeedsDisplayOpenGLSurface;
- (void)NSEView_scheduleNeedsDisplayInRect:(NSRect)aRect;
- (void)NSEView_setNeedsDisplayInRectFromValue:(id)aValue;
- (struct CGColorSpace *)colorSpace;
- (struct OpaqueCMProfileRef *)colorSyncProfile;
- (void)viewDidEndLiveResize;
- (void)viewWillStartLiveResize;
- (void)NSEView_reenableOpenGLSurfaceForLiveResizeIfNeeded;
- (void)NSEView_disableOpenGLSurfaceForLiveResizeIfNeeded;
- (void)setHidden:(BOOL)aHidden;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)NSEView_disableOpenGLSurfaceAutodisplay;
- (void)NSEView_enableOpenGLSurfaceAutodisplay;
- (void)NSEView_updateDisplayLinkIfNeeded;
- (void)NSEView_updateDisplayLink;
- (id)NSEView_proxy;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

@interface NSView (NSEViewPartial)
- (CGAffineTransform)NSE_affineTransformToView:(id)aView;
- (CGAffineTransform)NSE_boundsAffineTransform;
- (NSRect)NSE_unrotatedBounds;
- (id)NSE_screen;
@end

@interface NSView (NSEViewLoading)
+ (void)load;
@end

