#import "HSWebElementNodeUnit.h"
#import "HSWebElementAttributesImplementation.h"
#import "HSWebRenderer.h"
#import "HSProtocolIdentifier.h"
#import <libkern/OSAtomic.h>

// HTML code shown in a web element, refreshed refreshRate times a second. The
// renderer is shared through a proxy that creates it on demand and destroys
// it when its last (effective) user releases it.
@implementation HSWebElementNodeUnit

- (id)queryWebRenderer
{
    if (_webRendererProxy == nil) {
        _webRendererProxy = [[[[HSWebRendererProxy alloc] init] autorelease] serviceRetain];
        [_webRendererProxy setWebElementNodeUnit:self];
    }
    return _webRendererProxy;
}

- (void)HSWebElementNodeUnit_webRendererDidUpdatePreviewImage
{
    id attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSWebElementPreviewImageAttribute)];
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (void)HSWebElementNodeUnit_webRendererDidUpdate
{
    id attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSWebElementContentAttribute)];
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (void)HSWebElementNodeUnit_initializeWebRenderer
{
    [_webRendererProxy synchronizeHTMLCode:_HTMLCode];
    [_webRendererProxy synchronizeUpdateRate:_refreshRate];
}

- (void)setRefreshRate:(CGFloat)aRate
{
    // Rates within one per hour count as equal.
    if (!(aRate < _refreshRate - 1.0 / 3600.0 || _refreshRate + 1.0 / 3600.0 < aRate))
        return;
    id attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSWebElementRefreshRateAttribute)];
    if (attributes != nil)
        [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Element Refresh Rate" value:@"" table:@"UndoManager"]];
    [[undoManager prepareWithInvocationTarget:self] setRefreshRate:_refreshRate];
    _refreshRate = (float)aRate;
    [_webRendererProxy synchronizeUpdateRate:aRate];
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (CGFloat)refreshRate
{
    return _refreshRate;
}

- (void)setHTMLCode:(id)aCode
{
    if (_HTMLCode == aCode)
        return;
    if (_HTMLCode == nil ? [aCode length] == 0 : [aCode isEqualToString:_HTMLCode])
        return;
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSWebElementHTMLCodeAttribute), @protocol(HSWebElementContentAttribute), @protocol(HSWebElementPreviewImageAttribute), nil];
    if (attributes != nil)
        [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Web Element HTML Code" value:@"" table:@"UndoManager"]];
    [[undoManager prepareWithInvocationTarget:self] setHTMLCode:_HTMLCode];
    [_HTMLCode release];
    _HTMLCode = [aCode copy];
    [_webRendererProxy synchronizeHTMLCode:_HTMLCode];
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (id)HTMLCode
{
    return _HTMLCode;
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if ([self implementsHyperInterface:aInterface])
        return [HSWebElementAttributesImplementation class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSWebElementAttributes), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSWebElementAttributes)], nil];
}

- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSWebElementHTMLCodeAttribute), @protocol(HSWebElementRefreshRateAttribute), nil];
}

- (id)copyWithZone:(NSZone *)aZone
{
    id copy = [[[self class] allocWithZone:aZone] init];
    [copy setHTMLCodeAsString:_HTMLCode];
    [copy setRefreshRateAsFPS:_refreshRate];
    return copy;
}

- (void)setRefreshRateAsFPS:(CGFloat)aFPS
{
    _refreshRate = (float)aFPS;
}

- (CGFloat)refreshRateAsFPS
{
    return _refreshRate;
}

- (void)setHTMLCodeAsString:(id)aString
{
    if (_HTMLCode == aString)
        return;
    [_HTMLCode release];
    _HTMLCode = [aString copy];
}

- (id)HTMLCodeAsString
{
    return _HTMLCode;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [[[super keysForExtraStoringWithCodingContext:aContext] mutableCopy] autorelease];
    [keys addObject:@"HTMLCodeAsString"];
    [keys addObject:@"refreshRateAsFPS"];
    return [[keys copy] autorelease];
}

- (void)dealloc
{
    [_webRendererProxy setWebElementNodeUnit:nil];
    // The original sent -release, which also counted as an effective release
    // and could destroy a renderer still in use.
    [_webRendererProxy serviceRelease];
    [_HTMLCode release];
    [super dealloc];
}

@end

// Forwards to the renderer, creating it on first use. Ordinary retains count
// users ("effective" retains); service retains keep the proxy alive without
// keeping the renderer. The renderer is destroyed when the effective count
// drops to zero.
@implementation HSWebRendererProxy

+ (id)allocWithZone:(NSZone *)aZone
{
    HSWebRendererProxy *proxy = [super allocWithZone:aZone];
    if (proxy != nil)
        proxy->_effectiveRetainCount = 1;
    return proxy;
}

- (void)forwardInvocation:(id)aInvocation
{
    if ([self webRenderer] != nil)
        [aInvocation invokeWithTarget:_webRenderer];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    return [[self webRenderer] methodSignatureForSelector:aSelector];
}

- (struct CGImage *)previewImage
{
    return [[self webRenderer] previewImage];
}

- (void)synchronizeHTMLCode:(id)aCode
{
    if (_webRenderer == nil)
        return;
    NSString *HTML = @"<HTML></HTML>";
    if ([aCode length] != 0) {
        HTML = [NSString stringWithFormat:@"<HTML><BODY>%@</BODY></HTML>", aCode];
        if (HTML == nil)
            return;
    }
    [_webRenderer setHTMLString:HTML baseURL:nil];
}

- (void)synchronizeUpdateRate:(CGFloat)aRate
{
    [_webRenderer setUpdateRate:aRate];
}

- (id)webRenderer
{
    if (_webRenderer == nil) {
        _webRenderer = [[HSWebRenderer alloc] init];
        if (_webRenderer != nil) {
            [_webElementNodeUnit HSWebElementNodeUnit_initializeWebRenderer];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(HSWebRendererProxy_webRendererDidUpdate:) name:@"HSWebRendererDidUpdateNotificationName" object:_webRenderer];
            [center addObserver:self selector:@selector(HSWebRendererProxy_webRendererDidUpdatePreviewImage:) name:@"HSWebRendererDidUpdatePreviewImageNotificationName" object:_webRenderer];
        }
    }
    return _webRenderer;
}

- (void)HSWebRendererProxy_webRendererDidUpdatePreviewImage:(id)aImage
{
    [_webElementNodeUnit HSWebElementNodeUnit_webRendererDidUpdatePreviewImage];
}

- (void)HSWebRendererProxy_webRendererDidUpdate:(id)aUpdate
{
    [_webElementNodeUnit HSWebElementNodeUnit_webRendererDidUpdate];
}

- (void)setWebElementNodeUnit:(id)aUnit
{
    _webElementNodeUnit = aUnit;
}

- (id)webElementNodeUnit
{
    return _webElementNodeUnit;
}

- (void)release
{
    if (OSAtomicAdd32Barrier(-1, (int32_t *)&_effectiveRetainCount) == 0 && _webRenderer != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:@"HSWebRendererDidUpdateNotificationName" object:_webRenderer];
        [center removeObserver:self name:@"HSWebRendererDidUpdatePreviewImageNotificationName" object:_webRenderer];
        [_webRenderer release];
        _webRenderer = nil;
    }
    [super release];
}

- (id)retain
{
    OSAtomicAdd32Barrier(1, (int32_t *)&_effectiveRetainCount);
    return [super retain];
}

- (void)serviceRelease
{
    [super release];
}

- (id)serviceRetain
{
    return [super retain];
}

- (id)init
{
    return self;
}

@end
