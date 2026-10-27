#import "HSGenericGroupVisualization.h"
// A group's visualization: a visual subobjects layer into which each child
// with a visualization of this protocol expands its layers. Children's
// visualizations are kept in a map (weak keys); the children list is reset
// when the container's children change.
@implementation HSGenericGroupVisualization
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions
{
    id identifier = [self visualSubobjectsRenderLayerIdentifierForVisualizationOptions:aOptions];
    if (identifier == nil)
        return nil;
    id root = [self expandableRenderLayerWithIdentifier:identifier
                                      precreateSelector:@selector(precreateVisualSubobjectsRenderLayerForVisualizationOptions:)
                                   visualizationOptions:aOptions];
    if (root != nil) {
        HSIndexPath *path = [[[HSIndexPath alloc] init] autorelease];
        if (path != nil)
            [self expandWithVisualSubobjectsRenderLayersRenderLayerTreeWithRoot:root fromRenderLayerAtPath:path withVisualizationOptions:aOptions];
    }
    return root;
}
// Each child not ignored by the options expands the tree in turn, with its
// own options, from the path the previous one returned.
- (id)expandWithVisualSubobjectsRenderLayersRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions
{
    id ignored = [aOptions objectForKey:@"HSIgnoredSubobjectsVisualizationOption"];
    NSArray *subobjects = _subobjects != nil ? (id)_subobjects : [_nodeContainer hyperChildren];
    id path = aPath;
    for (id subobject in subobjects) {
        if ([ignored containsObject:subobject])
            continue;
        id visualization = [self HSGenericGroupVisualization_visualizationForSubobject:subobject];
        if (visualization != nil) {
            id options = [[aOptions objectForKey:@"HSSubobjectsVisualizationOptionsVisualizationOption"] objectForKey:subobject];
            path = [visualization expandRenderLayerTreeWithRoot:aRoot fromRenderLayerAtPath:path withVisualizationOptions:options];
        }
    }
    return path;
}
- (id)precreateVisualSubobjectsRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericInternalGroupRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)visualSubobjectsRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self renderLayerIdentifierAppendingSuffixForVisualizationOptions:aOptions toBaseIdentifier:@"HSVisualSubobjectsRenderLayerIdentifier"];
}
- (id)visualizationForSubobject:(id)aSubobject
{
    return [self HSGenericGroupVisualization_visualizationForSubobject:aSubobject];
}
// The children's visualizations. Builds the children list when there's none
// (by -visualizationForSubobject:, which subclasses may change).
- (id)subobjectVisualizations
{
    NSArray *subobjects = _subobjects;
    NSMutableArray *newSubobjects = nil;
    if (subobjects == nil) {
        subobjects = [_nodeContainer hyperChildren];
        newSubobjects = _subobjects = [[NSMutableArray alloc] initWithCapacity:[subobjects count]];
    }
    NSMutableArray *visualizations = [NSMutableArray arrayWithCapacity:[subobjects count]];
    for (id subobject in subobjects) {
        id visualization = [self visualizationForSubobject:subobject];
        if (visualization != nil) {
            [newSubobjects addObject:subobject];
            [visualizations addObject:visualization];
        }
    }
    return visualizations;
}
// The children with a visualization.
- (id)subobjects
{
    if (_subobjects == nil) {
        NSArray *children = [_nodeContainer hyperChildren];
        _subobjects = [[NSMutableArray alloc] initWithCapacity:[children count]];
        for (id child in children) {
            if ([self HSGenericGroupVisualization_visualizationForSubobject:child] != nil)
                [_subobjects addObject:child];
        }
    }
    return [[_subobjects copy] autorelease];
}
- (id)HSGenericGroupVisualization_visualizationForSubobject:(id)aSubobject
{
    if (_subobjectToVisualizationMap == nil) {
        _subobjectToVisualizationMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    } else {
        id visualization = NSMapGet(_subobjectToVisualizationMap, aSubobject);
        if (visualization != nil)
            return visualization;
    }
    id visualization = [aSubobject queryHyperInterface:[self visualizationProtocol]];
    if (![visualization conformsToProtocol:@protocol(HSVisualizationLayering)])
        return nil;
    NSMapInsert(_subobjectToVisualizationMap, aSubobject, visualization);
    return visualization;
}
- (void)HSGenericGroupVisualization_subobjectsDidChange:(id)aChange
{
    [self HSGenericGroupVisualization_removeVisualizationsForRemovedObjects];
    [_subobjects release];
    _subobjects = nil;
}
- (void)HSGenericGroupVisualization_removeVisualizationsForRemovedObjects
{
    if (_subobjectToVisualizationMap == nil)
        return;
    NSArray *children = [_nodeContainer hyperChildren];
    for (id subobject in NSAllMapTableKeys(_subobjectToVisualizationMap)) {
        if (![children containsObject:subobject])
            NSMapRemove(_subobjectToVisualizationMap, subobject);
    }
}
- (void)dealloc
{
    [[_nodeContainer attributeObservingController] removeObserver:self selector:@selector(HSGenericGroupVisualization_subobjectsDidChange:)
                                                        ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    if (_subobjectToVisualizationMap != nil)
        NSFreeMapTable(_subobjectToVisualizationMap);
    [_subobjects release];
    [_nodeContainer release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    self = [super initWithHyperObject:aObject visualizationProtocol:aProtocol];
    if (self != nil) {
        _nodeContainer = [[aObject queryHyperInterface:@protocol(HSNodeContainer)] retain];
        [[_nodeContainer attributeObservingController] addObserver:self selector:@selector(HSGenericGroupVisualization_subobjectsDidChange:)
                                                         ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:0.25f];
    }
    return self;
}
@end
