#import "HSGenericExternalGroupRenderLayer.h"
// A group drawn outside its object's transform (it undoes it), redone when
// the object's siblings change.
@implementation HSGenericExternalGroupRenderLayer
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id savedTransform = [[NSGraphicsContext currentContext] currentHyperTransform];
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    [[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformInvert(transform)] concat];
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:transform];
    [super drawRenderSublayersInRegion:region withDelegate:aDelegate];
    [(NSAffineTransform *)savedTransform set];
}
- (id)calculateBoundingRegion
{
    HSMutableRegion *region = [[[super calculateBoundingRegion] mutableCopy] autorelease];
    [region applyAffineTransform:CGAffineTransformInvert([_geometryAttributes affineTransform])];
    return [[region copy] autorelease];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSAffineTransformAttribute) forObject:[self hyperObject]];
    [super fillBoundingRegionAttributesSet:aSet];
}
- (void)HSGenericExternalGroupRenderLayer_siblingsDidChange:(id)aChange
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}
- (void)HSGenericExternalGroupRenderLayer_superobjectDidChange:(id)aChange
{
    [[[_nodeChild hyperParent] attributeObservingController] addObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_siblingsDidChange:)
                                                                ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25];
}
- (void)HSGenericExternalGroupRenderLayer_superobjectWillChange:(id)aChange
{
    [[[_nodeChild hyperParent] attributeObservingController] removeObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_siblingsDidChange:)
                                                                   ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}
- (void)dealloc
{
    id controller = [_nodeChild attributeObservingController];
    [controller removeObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_superobjectWillChange:)
                     ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
    [controller removeObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_superobjectDidChange:)
                     ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
    [[[_nodeChild hyperParent] attributeObservingController] removeObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_siblingsDidChange:)
                                                                   ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [_nodeChild release];
    [_geometryAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
    if (_geometryAttributes != nil) {
        _nodeChild = [[aObject queryHyperInterface:@protocol(HSNodeChild)] retain];
        if (_nodeChild != nil) {
            id controller = [_nodeChild attributeObservingController];
            [controller addObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_superobjectWillChange:)
                          ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:0.25];
            [controller addObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_superobjectDidChange:)
                          ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:0.25];
            [[[_nodeChild hyperParent] attributeObservingController] addObserver:self selector:@selector(HSGenericExternalGroupRenderLayer_siblingsDidChange:)
                                                                        ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25];
            return self;
        }
    }
    [self release];
    return nil;
}
@end
