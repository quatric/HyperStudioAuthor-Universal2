#import "HSEffectObjectVisualization.h"
// An effect object's visualization. The effect layer goes into its parent's
// render layer tree, with a source area layer whose external group shows the
// layers below the effect (the parent's sublayers before it). In replace mode
// those layers are moved out of the tree: an inverse clip layer takes their
// place, and the layers on the path to the effect are copied.
@implementation HSEffectObjectVisualization
// Returns the path to the layer the effect was added to, changed when the
// inverse clip layer was put in front of it.
- (id)expandRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions
{
    id effect = [self expandableRenderLayerWithIdentifier:[self effectRenderLayerIdentifierForVisualizationOptions:aOptions]
                                        precreateSelector:@selector(precreateEffectRenderLayerForVisualizationOptions:)
                                     visualizationOptions:aOptions];
    if (effect == nil)
        return aPath;
    if (_rootRenderLayerPointer != NULL)
        *_rootRenderLayerPointer = [effect retain];
    id sourceArea = [self expandableRenderLayerWithIdentifier:@"HSEffectSourceAreaRenderLayerIdentifier"
                                            precreateSelector:@selector(precreateEffectSourceAreaRenderLayerForVisualizationOptions:)
                                         visualizationOptions:aOptions];
    if (sourceArea == nil)
        return aPath;
    [effect addRenderSublayer:sourceArea forRole:@"HSEffectSourceAreaRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:NO];
    id externalGroup = [self expandableRenderLayerWithIdentifier:@"HSEffectSourceAreaExternalGroupRenderLayerIdentifier"
                                               precreateSelector:@selector(precreateEffectSourceAreaExternalGroupRenderLayerForVisualizationOptions:)
                                            visualizationOptions:aOptions];
    if (externalGroup == nil)
        return aPath;
    [sourceArea addRenderSublayer:externalGroup forRole:@"HSExternalGroupRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    NSUInteger count = [aRoot renderSublayerCount];
    NSUInteger pathLength = [aPath length];
    id parent = aRoot;
    if (pathLength != 0) {
        if (!_isInReplaceMode) {
            parent = [aRoot renderLayerAtIndexPath:aPath role:NULL];
        } else {
            // copies of the layers on the path, without their other sublayers
            NSUInteger index = [aPath indexAtPosition:0];
            id role = [aRoot roleOfRenderSublayerAtIndex:index];
            id original = [aRoot renderSublayerAtIndex:index];
            id top = [[original copyRemovingRenderSublayers] autorelease];
            [self prepareRenderLayerForExpanding:top];
            parent = top;
            for (NSUInteger i = 1; i < pathLength; i++) {
                index = [aPath indexAtPosition:i];
                id sublayer = [original renderSublayerAtIndex:index];
                id copy = [[sublayer copyRemovingRenderSublayers] autorelease];
                [parent addRenderSublayer:copy forRole:[original roleOfRenderSublayerAtIndex:index] asRoot:NO addingTransparencyLayerRequirement:YES];
                [self prepareRenderLayerForExpanding:copy];
                parent = copy;
                original = sublayer;
            }
            [aRoot addRenderSublayer:top forRole:role asRoot:NO addingTransparencyLayerRequirement:YES];
        }
    }
    id inverseClip = nil;
    if (count != 0) {
        [externalGroup addRenderSublayersFromRenderLayer:aRoot range:NSMakeRange(0, count)];
        if (_isInReplaceMode) {
            inverseClip = [self expandableRenderLayerWithIdentifier:@"HSEffectSourceAreaInverseClipRenderLayerIdentifier"
                                                  precreateSelector:@selector(precreateEffectSourceAreaInverseClipRenderLayerForVisualizationOptions:)
                                               visualizationOptions:aOptions];
            if (inverseClip != nil) {
                id clipGroup = [self expandableRenderLayerWithIdentifier:@"HSEffectSourceAreaInverseClipExternalGroupRenderLayerIdentifier"
                                                       precreateSelector:@selector(precreateEffectSourceAreaInverseClipExternalGroupRenderLayerForVisualizationOptions:)
                                                    visualizationOptions:aOptions];
                if (clipGroup != nil) {
                    [inverseClip addRenderSublayer:clipGroup forRole:@"HSExternalGroupRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
                    [clipGroup addRenderSublayersFromRenderLayer:aRoot range:NSMakeRange(0, count)];
                }
                [aRoot removeRenderSublayersInRange:NSMakeRange(0, count)];
                [aRoot insertRenderSublayer:inverseClip atIndex:0 forRole:@"HSEffectSourceAreaInverseClipRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
            }
        }
    }
    [parent addRenderSublayer:effect forRole:@"HSSubobjectRootRenderLayerRole" asRoot:YES addingTransparencyLayerRequirement:YES];
    if (inverseClip == nil || pathLength == 0)
        return aPath;
    // The root now holds the inverse clip and the copied path, each copy
    // holding just the next one.
    if (pathLength == 1)
        return [HSIndexPath indexPathWithIndex:1];
    unsigned int *indexes = calloc(pathLength, sizeof(unsigned int));
    indexes[0] = 1;
    id path = [HSIndexPath indexPathWithIndexes:indexes length:pathLength];
    free(indexes);
    return path;
}
// The effect's layer: its parent builds its tree with this object's options,
// and the effect layer is caught on the way.
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions
{
    id layering = [[_nodeChild hyperParent] queryHyperInterface:[self visualizationProtocol]];
    if (![layering conformsToProtocol:@protocol(HSVisualizationLayering)])
        return nil;
    id root = nil;
    NSDictionary *options = nil;
    if (aOptions != nil)
        options = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObject:aOptions forKey:(id)_nodeChild],
                                                             @"HSSubobjectsVisualizationOptionsVisualizationOption", nil];
    _rootRenderLayerPointer = &root;
    [layering buildRenderLayerTreeWithVisualizationOptions:options];
    _rootRenderLayerPointer = NULL;
    return [root autorelease];
}
// The precreate methods return retained layers.
- (id)precreateEffectSourceAreaInverseClipExternalGroupRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericExternalGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateEffectSourceAreaInverseClipRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericEffectSourceAreaInverseClipRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateEffectSourceAreaExternalGroupRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericExternalGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateEffectSourceAreaRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericEffectSourceAreaRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
// A Core Image effect, else a QuickTime one.
- (id)precreateEffectRenderLayerForVisualizationOptions:(id)aOptions
{
    id object = [self hyperObject];
    id layer = [[HSGenericCIEffectRenderLayer alloc] initWithHyperObject:object];
    if (layer == nil)
        layer = [[HSGenericQTEffectRenderLayer alloc] initWithHyperObject:object];
    return layer;
}
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSEffectRenderLayerIdentifier";
}
- (void)dealloc
{
    [_nodeChild release];
    [super dealloc];
}
// Only for node children.
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol inReplaceMode:(BOOL)aMode
{
    self = [super initWithHyperObject:aObject visualizationProtocol:aProtocol];
    if (self != nil) {
        _nodeChild = [[aObject queryHyperInterface:@protocol(HSNodeChild)] retain];
        if (_nodeChild == nil) {
            [self release];
            return nil;
        }
        _isInReplaceMode = aMode ? 1 : 0;
    }
    return self;
}
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    return [self initWithHyperObject:aObject visualizationProtocol:aProtocol inReplaceMode:NO];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
