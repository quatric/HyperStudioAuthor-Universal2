#import "HSWebElementAttributesImplementation.h"
// The web element's attributes, over its node unit and (lazily) a web
// renderer sized like the object. A refresh rate of 1 (continuous, give or
// take float error) counts as a continuous change of the content.
#define HSWebElementContinuousRefreshRate 0.99972224f

@implementation HSWebElementAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSWebElementNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (id)attributeObservingController
{
    return _node;
}
- (void)reclaimWebView
{
    [[self HSWebElementAttributesImplementation_webRenderer] reclaimWebView];
}
- (id)ejectWebView
{
    return [[self HSWebElementAttributesImplementation_webRenderer] ejectWebView];
}
- (void)drawInRect:(NSRect)aRect clipToRect:(NSRect)aRect2
{
    [[self HSWebElementAttributesImplementation_webRenderer] drawInRect:aRect clipToRect:aRect2];
}
- (struct CGImage *)previewImage
{
    return [[self HSWebElementAttributesImplementation_webRenderer] previewImage];
}
// Created and started on first use; the page size follows the object's.
- (id)HSWebElementAttributesImplementation_webRenderer
{
    if (_sizeAttributes == nil) {
        _sizeAttributes = [[_node queryHyperInterface:@protocol(HSSizeAttributes)] retain];
        if (_sizeAttributes == nil)
            return _webRenderer;
    }
    if (_webRenderer == nil) {
        _webRenderer = [[_nodeUnit queryWebRenderer] retain];
        if (_webRenderer == nil)
            return nil;
        [_webRenderer setPageSize:[_sizeAttributes size]];
        [_webRenderer play];
    } else
        [_webRenderer setPageSize:[_sizeAttributes size]];
    return _webRenderer;
}
- (void)setRefreshRate:(CGFloat)aRate
{
    float oldRate = (float)[_nodeUnit refreshRate];
    [_nodeUnit setRefreshRate:aRate];
    if (oldRate < HSWebElementContinuousRefreshRate) {
        if ((float)aRate >= HSWebElementContinuousRefreshRate)
            [_node beginContinuousChangeOfAttribute:@protocol(HSWebElementContentAttribute)];
    } else if ((float)aRate < HSWebElementContinuousRefreshRate)
        [_node endContinuousChangeOfAttribute:@protocol(HSWebElementContentAttribute)];
}
- (CGFloat)refreshRate
{
    return (float)[_nodeUnit refreshRate];
}
- (void)setHTMLCode:(id)aCode
{
    [_nodeUnit setHTMLCode:aCode];
}
- (id)HTMLCode
{
    return [_nodeUnit HTMLCode];
}
- (id)hyperObject
{
    return _node;
}
- (id)nodeUnit
{
    return _nodeUnit;
}
- (id)node
{
    return _node;
}
- (void)dealloc
{
    [_webRenderer stop];
    [_webRenderer release];
    [_sizeAttributes release];
    [_nodeUnit release];
    [_node release];
    [super dealloc];
}
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self == nil)
        return nil;
    _node = [aNode retain];
    _nodeUnit = [aUnit retain];
    if ((float)[_nodeUnit refreshRate] >= HSWebElementContinuousRefreshRate)
        [_node beginContinuousChangeOfAttribute:@protocol(HSWebElementContentAttribute)];
    return self;
}
- (id)init
{
    [self release];
    return nil;
}
- (CGImageRef)copyPreviewImageWithScale:(CGSize)aScale
{
    return [[self HSWebElementAttributesImplementation_webRenderer] copyPreviewImageWithScale:aScale];
}

@end
