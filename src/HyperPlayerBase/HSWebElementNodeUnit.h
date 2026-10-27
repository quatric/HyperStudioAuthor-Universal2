#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSWebElementNodeUnit : HSNodeUnit
{
    NSString *_HTMLCode;
    float _refreshRate;
    HSWebRendererProxy *_webRendererProxy;
}
- (id)queryWebRenderer;
- (void)HSWebElementNodeUnit_webRendererDidUpdatePreviewImage;
- (void)HSWebElementNodeUnit_webRendererDidUpdate;
- (void)HSWebElementNodeUnit_initializeWebRenderer;
- (void)setRefreshRate:(CGFloat)aRate;
- (CGFloat)refreshRate;
- (void)setHTMLCode:(id)aCode;
- (id)HTMLCode;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)copyWithZone:(NSZone *)aZone;
- (void)setRefreshRateAsFPS:(CGFloat)aFPS;
- (CGFloat)refreshRateAsFPS;
- (void)setHTMLCodeAsString:(id)aString;
- (id)HTMLCodeAsString;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

@interface HSWebRendererProxy : NSProxy
{
    unsigned int _effectiveRetainCount;
    HSWebElementNodeUnit *_webElementNodeUnit;
    HSWebRenderer *_webRenderer;
}
+ (id)allocWithZone:(NSZone *)aZone;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (struct CGImage *)previewImage;
- (void)synchronizeHTMLCode:(id)aCode;
- (void)synchronizeUpdateRate:(CGFloat)aRate;
- (id)webRenderer;
- (void)HSWebRendererProxy_webRendererDidUpdatePreviewImage:(id)aImage;
- (void)HSWebRendererProxy_webRendererDidUpdate:(id)aUpdate;
- (void)setWebElementNodeUnit:(id)aUnit;
- (id)webElementNodeUnit;
- (void)release;
- (id)retain;
- (void)serviceRelease;
- (id)serviceRetain;
- (id)init;
@end

