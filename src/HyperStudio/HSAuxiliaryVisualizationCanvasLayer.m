#import "HSAuxiliaryVisualizationCanvasLayer.h"

@implementation HSAuxiliaryVisualizationCanvasLayer

- (BOOL)supportsHitTesting
{
    return YES;
}

- (void)visualAttributesWillDidChange:(id)aChange
{
    id item = [self canvasItemForNodeIfExists:[aChange object]];
    id view = [self renderingView];
    if (item != nil && view != nil)
        [view setNeedsHyperDisplayInRegion:[item updateWithChangedRegionBounds:nil inCanvasLayer:self]];
}

- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super willUnregisterCanvasItem:aItem forNode:aNode];
    [[aNode attributeObservingController] removeObserver:self selector:@selector(visualAttributesWillDidChange:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
}

- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super didRegisterCanvasItem:aItem forNode:aNode];
    [[aNode attributeObservingController] addObserver:self selector:@selector(visualAttributesWillDidChange:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.25f];
}

- (BOOL)invalidatesDisplayUponRegisterUnregister
{
    return YES;
}

- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    if (_rendersCardNodes)
        return [super canvasItemAtIndex:aIndex];
    return [self canvasItemForNode:[_orderedVisualizedNodes objectAtIndex:aIndex]];
}

- (NSUInteger)numberOfCanvasItems
{
    if (_rendersCardNodes)
        return [super numberOfCanvasItems];
    return [_orderedVisualizedNodes count];
}

- (void)removeAllItems
{
    [_visualizedNodes removeAllObjects];
    [_orderedVisualizedNodes removeAllObjects];
    [self unregisterAllCanvasItems];
}

- (id)queryCanvasItemForNode:(id)aNode
{
    if (![_visualizedNodes containsObject:aNode])
        return nil;
    return [HSAuxiliaryVisualizationCanvasItem itemWithObject:aNode];
}

- (void)removeItemForNode:(id)aNode
{
    [aNode retain];
    [_visualizedNodes removeObject:aNode];
    [_orderedVisualizedNodes removeObject:aNode];
    [self unregisterCanvasItemForNode:aNode];
    [aNode release];
}

- (void)addItemForNode:(id)aNode
{
    if (_visualizedNodes == nil)
        _visualizedNodes = [NSMutableSet new];
    if (_orderedVisualizedNodes == nil && !_rendersCardNodes)
        _orderedVisualizedNodes = [NSMutableArray new];
    [_visualizedNodes addObject:aNode];
    [_orderedVisualizedNodes addObject:aNode];
    [self canvasItemForNode:aNode];
}

- (void)dealloc
{
    for (id node in _visualizedNodes)
        [[node attributeObservingController] removeObserver:self selector:@selector(visualAttributesWillDidChange:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
    [_visualizedNodes release];
    [_orderedVisualizedNodes release];
    [super dealloc];
}

- (id)init
{
    return [self initForRenderingCardNodes:YES];
}

- (id)initForRenderingCardNodes:(BOOL)aNodes
{
    self = [super init];
    if (self != nil)
        _rendersCardNodes = aNodes;
    return self;
}

@end
