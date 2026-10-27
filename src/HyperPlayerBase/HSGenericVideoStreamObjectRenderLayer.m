#import "HSGenericVideoStreamObjectRenderLayer.h"
#import "HSGenericVideoStreamRenderLayer.h"

// Renders a video stream object: the video stream layer while there is a
// frame, otherwise the placeholder layer (if any). Everything is forwarded to
// whichever of the two is current.
@implementation HSGenericVideoStreamObjectRenderLayer

- (id)HSGenericVideoStreamObjectRenderLayer_currentRenderLayer
{
    return _hasVideoFrame ? (id)_videoStreamRenderLayer : _placeholderRenderLayer;
}

- (void)renderLayerWantsToReexpand:(id)aReexpand
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}

- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    [self boundingRegionDidChange];
}

- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet
{
    [self visualizationMaskAttributesSetDidChange:nil];
}

- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet
{
    [self visualizationAttributesSetDidChange:nil];
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer] getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
}

- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (!_hasVideoFrame && _placeholderRenderLayer == nil)
        return;
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
    BOOL draw;
    if (delegate == nil) {
        [NSGraphicsContext saveGraphicsState];
        draw = YES;
    } else {
        if (![delegate renderLayerShouldBeRenderedInRegion:aRegion])
            return;
        [NSGraphicsContext saveGraphicsState];
        draw = [delegate renderLayerShouldBeDrawnInRegion:aRegion intoRenderCache:NO];
    }
    if (draw) {
        [NSGraphicsContext saveGraphicsState];
        [[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer] drawRegion:aRegion withDelegate:delegate];
        [NSGraphicsContext restoreGraphicsState];
        [delegate renderLayerIsDrawnInRegion:aRegion intoRenderCache:NO];
    }
    [NSGraphicsContext restoreGraphicsState];
    [delegate renderLayerIsRenderedInRegion:aRegion];
}

- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return NO;
}

- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return NO;
}

- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return _hasVideoFrame ? @"HSVideoStreamRenderLayer" : @"HSPlaceHolderRenderLayer";
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return [self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer];
}

- (NSUInteger)renderSublayerCount
{
    return _hasVideoFrame || _placeholderRenderLayer != nil ? 1 : 0;
}

- (id)renderSublayerRoles
{
    if (!_hasVideoFrame && _placeholderRenderLayer == nil)
        return [NSArray array];
    return [NSArray arrayWithObject:[self roleOfRenderSublayerAtIndex:0]];
}

- (id)renderSublayers
{
    if (!_hasVideoFrame && _placeholderRenderLayer == nil)
        return [NSArray array];
    return [NSArray arrayWithObject:[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer]];
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return [[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer] unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}

- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return NO;
}

- (id)calculateBoundingRegion
{
    id layer = [self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer];
    if (layer == nil)
        return [HSRegion region];
    return [layer boundingRegion];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer] addVisualizationMaskAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    [[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer] addVisualizationAttributesToSet:aSet];
}

- (BOOL)requiresTransparencyLayer
{
    return [[self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer] requiresTransparencyLayer];
}

- (BOOL)isEmpty
{
    id layer = [self HSGenericVideoStreamObjectRenderLayer_currentRenderLayer];
    if (layer == nil)
        return YES;
    return [layer isEmpty];
}

// Switches between the video and the placeholder as frames come and go.
- (void)HSGenericVideoStreamObjectRenderLayer_videoFrameDidChange:(id)aChange
{
    BOOL hasVideoFrame = ![_videoStreamRenderLayer isEmpty];
    if (hasVideoFrame == _hasVideoFrame)
        return;
    _hasVideoFrame = hasVideoFrame;
    [self visualizationAttributesSetDidChange:nil];
    [self visualizationMaskAttributesSetDidChange:nil];
}

- (void)dealloc
{
    [[_videoStreamAttributes attributeObservingController] removeObserver:self selector:@selector(HSGenericVideoStreamObjectRenderLayer_videoFrameDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVideoFrameAttribute)];
    [_videoStreamAttributes release];
    [_placeholderRenderLayer removeObserver:self];
    [_placeholderRenderLayer release];
    [_videoStreamRenderLayer removeObserver:self];
    [_videoStreamRenderLayer release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject withPlaceholderRenderSublayer:(id)aSublayer cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _videoStreamAttributes = [[aObject queryHyperInterface:@protocol(HSVideoStreamAttributes)] retain];
    if (_videoStreamAttributes != nil) {
        [[_videoStreamAttributes attributeObservingController] addObserver:self selector:@selector(HSGenericVideoStreamObjectRenderLayer_videoFrameDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVideoFrameAttribute) withPriority:0.25];
        _videoStreamRenderLayer = [[HSGenericVideoStreamRenderLayer alloc] initWithHyperObject:aObject cachingPolicy:aPolicy];
        if (_videoStreamRenderLayer != nil) {
            [_videoStreamRenderLayer addObserver:self];
            _hasVideoFrame = ![_videoStreamRenderLayer isEmpty];
            _placeholderRenderLayer = [aSublayer retain];
            [_placeholderRenderLayer addObserver:self];
            return self;
        }
    }
    [self release];
    return nil;
}

- (id)initWithHyperObject:(id)aObject withPlaceholderRenderSublayer:(id)aSublayer
{
    return [self initWithHyperObject:aObject withPlaceholderRenderSublayer:aSublayer cachingPolicy:0];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject withPlaceholderRenderSublayer:nil cachingPolicy:aPolicy];
}

@end
