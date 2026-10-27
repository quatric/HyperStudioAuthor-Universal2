#import "HSGenericInternalGroupRenderLayer.h"
// A group layer for a node container's children. It asks its observers to
// reexpand when the children change, and stops auto-grouping its sublayers
// for caching while the children are being changed continuously (an
// observer of the actual changes is added for the duration).
//
// _isAutoGroupingOfRenderSublayersForEfficientCachingCanceled: auto-grouping
// was turned off by a continuous change (and is to be turned back on);
// _isWaitingForContinuousSubobjectsChange: the actual changes are observed.
@implementation HSGenericInternalGroupRenderLayer
// The bounding region of the visual subobjects attribute: of the changed
// children described in the info, or of all the children when none is
// described.
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if ([aObject hyperIdentifier] != [[self hyperObject] hyperIdentifier] || ![aSet containsProtocol:@protocol(HSVisualSubobjectsAttribute)])
        return NO;
    BOOL changed = NO, noneDescribed = YES;
    NSEnumerator *descriptions = [[aInfo objectForKey:@"HSVisualSubobjectChangeDescriptions"] objectEnumerator];
    NSDictionary *description;
    while ((description = [descriptions nextObject]) != nil) {
        id notification = [description objectForKey:@"HSVisualSubobjectAttributeNotification"];
        if (notification != nil) {
            id attributes = [[notification attributeProtocolSet] copyAdoptedProtocols];
            if (attributes == nil)
                break;
            if ([self unionBoundingRegionOfConcreteAttributeSet:attributes ofHyperObject:[notification object] withInfo:[notification userInfo] withRegion:aRegion])
                changed = YES;
            [attributes release];
            noneDescribed = NO;
        } else {
            id subobject = [[description objectForKey:@"HSVisualSubobject"] hyperObject];
            if (subobject == nil)
                continue;
            noneDescribed = NO;
            id attributes = [[self visualizationAttributes] attributesForObject:subobject];
            if (attributes == nil)
                continue;
            if ([self unionBoundingRegionOfLocalVisualAttributeSet:attributes ofHyperObject:subobject withInfo:nil withRegion:aRegion])
                changed = YES;
            if ([self unionBoundingRegionOfSublayersVisualAttributeSet:attributes ofHyperObject:subobject withInfo:nil withRegion:aRegion])
                changed = YES;
        }
    }
    if (noneDescribed && [_nodeContainer hyperCount] != 0) {
        id visualizationAttributes = [self visualizationAttributes];
        NSEnumerator *children = [_nodeContainer hyperEnumerator];
        id subobject;
        while ((subobject = [[children nextObject] hyperObject]) != nil) {
            id attributes = [visualizationAttributes attributesForObject:subobject];
            if (attributes == nil)
                continue;
            if ([self unionBoundingRegionOfLocalVisualAttributeSet:attributes ofHyperObject:subobject withInfo:nil withRegion:aRegion])
                changed = YES;
            if ([self unionBoundingRegionOfSublayersVisualAttributeSet:attributes ofHyperObject:subobject withInfo:nil withRegion:aRegion])
                changed = YES;
        }
    }
    return changed;
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSVisualSubobjectsAttribute) forObject:[self hyperObject]];
    [super fillVisualizationMaskAttributesSet:aSet];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSVisualSubobjectsAttribute) forObject:[self hyperObject]];
    [super fillVisualizationAttributesSet:aSet];
}
// Stops watching for continuous changes. (The canceled flag is left as it
// is, as in the original.)
- (void)disableAutogroupingOfRenderSublayersForEfficientCaching
{
    id controller = [_nodeContainer attributeObservingController];
    [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsWillBeginChangeContinuously:)
                     ofChanges:0x40 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidEndChangeContinuously:)
                     ofChanges:0x80 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    if (_isWaitingForContinuousSubobjectsChange) {
        [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:)
                         ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        _isWaitingForContinuousSubobjectsChange = 0;
    }
    [super disableAutogroupingOfRenderSublayersForEfficientCaching];
}
// Watches for continuous changes (0x40 begin, 0x80 end); while the children
// are being changed continuously, auto-grouping is left canceled.
- (void)enableAutogroupingOfRenderSublayersForEfficientCaching
{
    id controller = [_nodeContainer attributeObservingController];
    [controller addObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsWillBeginChangeContinuously:)
                  ofChanges:0x40 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25f];
    [controller addObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidEndChangeContinuously:)
                  ofChanges:0x80 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25f];
    BOOL changing = [[controller attributesBeingChangedContinuously] containsProtocol:@protocol(HSNodeContainerChildrenAttribute)];
    _isAutoGroupingOfRenderSublayersForEfficientCachingCanceled = changing ? 1 : 0;
    if (!changing)
        [super enableAutogroupingOfRenderSublayersForEfficientCaching];
}
// Turning it on while canceled just waits for the continuous change to end;
// turning it off then stops watching.
- (void)setAutogroupsRenderSublayersForEfficientCaching:(BOOL)aCaching
{
    if (_isAutoGroupingOfRenderSublayersForEfficientCachingCanceled) {
        if (!aCaching) {
            id controller = [_nodeContainer attributeObservingController];
            [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsWillBeginChangeContinuously:)
                             ofChanges:0x40 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
            [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidEndChangeContinuously:)
                             ofChanges:0x80 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
            _isAutoGroupingOfRenderSublayersForEfficientCachingCanceled = 0;
            return;
        }
        aCaching = NO;
    }
    [super setAutogroupsRenderSublayersForEfficientCaching:aCaching];
}
- (void)HSGenericInternalGroupRenderLayer_subobjectsDidEndChangeContinuously:(id)aContinuously
{
    id controller = [_nodeContainer attributeObservingController];
    if ([[controller attributesBeingChangedContinuously] containsProtocol:@protocol(HSNodeContainerChildrenAttribute)])
        return;
    if (_isWaitingForContinuousSubobjectsChange) {
        [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:)
                         ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        _isWaitingForContinuousSubobjectsChange = 0;
    }
    if (_isAutoGroupingOfRenderSublayersForEfficientCachingCanceled) {
        _isAutoGroupingOfRenderSublayersForEfficientCachingCanceled = 0;
        [super enableAutogroupingOfRenderSublayersForEfficientCaching];
    }
}
// The first actual change of a continuous change cancels auto-grouping.
- (void)HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:(id)aContinuously
{
    [[_nodeContainer attributeObservingController] removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:)
                                                        ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    _isWaitingForContinuousSubobjectsChange = 0;
    _isAutoGroupingOfRenderSublayersForEfficientCachingCanceled = 1;
    [super disableAutogroupingOfRenderSublayersForEfficientCaching];
}
- (void)HSGenericInternalGroupRenderLayer_subobjectsWillBeginChangeContinuously:(id)aContinuously
{
    if (_isAutoGroupingOfRenderSublayersForEfficientCachingCanceled || _isWaitingForContinuousSubobjectsChange)
        return;
    _isWaitingForContinuousSubobjectsChange = 1;
    [[_nodeContainer attributeObservingController] addObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:)
                                                     ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25f];
}
- (void)HSGenericInternalGroupRenderLayer_subobjectsDidChange:(id)aChange
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}
- (void)dealloc
{
    id controller = [_nodeContainer attributeObservingController];
    [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChange:)
                     ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsWillBeginChangeContinuously:)
                     ofChanges:0x40 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidEndChangeContinuously:)
                     ofChanges:0x80 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    if (_isWaitingForContinuousSubobjectsChange)
        [controller removeObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:)
                         ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [_nodeContainer release];
    [super dealloc];
}
// Only for node containers.
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self != nil) {
        _nodeContainer = [[aObject queryHyperInterface:@protocol(HSNodeContainer)] retain];
        if (_nodeContainer == nil) {
            [self release];
            return nil;
        }
        [[_nodeContainer attributeObservingController] addObserver:self selector:@selector(HSGenericInternalGroupRenderLayer_subobjectsDidChange:)
                                                         ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25f];
    }
    return self;
}
@end
