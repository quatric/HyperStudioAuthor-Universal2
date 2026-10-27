#import "HyperPlayerBasePrefix.h"


@interface HSQuartzOpenGLView : NSEView
{
    NSRect _rectBeingDrawn;
    id _quartzOpenGLViewProxy;
    NSMutableArray *_windowLayers;
    unsigned int _isWindowLayersGeometryValid:1;
    unsigned int _isRegisteredForViewGeometryChangeNotifications:1;
    unsigned int _isRegisteredForWindowDidMoveNotification:1;
}
+ (id)createDefaultOpenGLContext;
- (NSRect)rectBeingDrawn;
- (void)drawRect:(NSRect)aRect;
- (void)drawQuartzRect:(NSRect)aRect;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect;
- (void)HSQuartzOpenGLView_displayWindowLayers;
- (void)setNeedsDisplayInRect:(NSRect)aRect inWindowLayer:(id)aLayer;
- (void)setNeedsDisplayInViewLayerRect:(NSRect)aRect;
- (void)setNeedsHyperDisplayInRegion:(id)aRegion;
- (id)viewForWindowLayer:(id)aLayer;
- (id)windowLayers;
- (void)removeWindowLayer:(id)aLayer;
- (id)addWindowLayerWithDrawingSelector:(SEL)aSelector;
- (id)addWindowLayerWithView:(id)aView;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)HSQuartzOpenGLView_removeViewGeometryObservers;
- (void)HSQuartzOpenGLView_addViewGeometryObserversStartingFromView:(id)aView;
- (void)HSQuartzOpenGLView_windowDidMoveDuringChildAddition:(id)aAddition;
- (void)HSQuartzOpenGLView_viewDidChangeGeometry:(id)aGeometry;
- (void)HSQuartzOpenGLView_synchronizeWindowLayersGeometry;
- (void)HSQuartzOpenGLView_synchronizeGeometryOfWindowLayer:(id)aLayer withContentRect:(NSRect)aRect contentViewFlippedFlag:(BOOL)aFlag contentViewBounds:(NSRect)aBounds contentViewBoundsRotation:(CGFloat)aRotation;
- (void)HSQuartzOpenGLView_getWindowLayerContentRect:(NSRect *)aRect windowLayerContentViewFlippedFlag:(BOOL *)aFlag windowLayerContentViewBounds:(NSRect *)aBounds windowLayerContentViewBoundsRotation:(float *)aRotation;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
- (id)HSQuartzOpenGLView_proxy;
@end

@interface HSQuartzOpenGLView_HSWindowLayerDrawingView : NSEView
{
    NSInvocation *_drawingInvocation;
}
+ (id)createDefaultOpenGLContext;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect;
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect;
- (void)drawQuartzRect:(NSRect)aRect;
- (BOOL)isFlipped;
- (void)clearParentView;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame parentView:(id)aView drawingSelector:(SEL)aSelector;
@end

@interface HSQuartzOpenGLView_HSFlippingView : NSView
{
    unsigned int _isFlipped:1;
}
- (void)setFlipped:(BOOL)aFlipped;
- (BOOL)isFlipped;
@end

