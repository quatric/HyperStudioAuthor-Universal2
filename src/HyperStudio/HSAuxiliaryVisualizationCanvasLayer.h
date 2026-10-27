#import "HyperStudioPrefix.h"


@interface HSAuxiliaryVisualizationCanvasLayer : HSObservingNodesCanvasSublayer
{
    NSMutableSet *_visualizedNodes;
    NSMutableArray *_orderedVisualizedNodes;
    BOOL _rendersCardNodes;
}
- (BOOL)supportsHitTesting;
- (void)visualAttributesWillDidChange:(id)aChange;
- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode;
- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode;
- (BOOL)invalidatesDisplayUponRegisterUnregister;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfCanvasItems;
- (void)removeAllItems;
- (id)queryCanvasItemForNode:(id)aNode;
- (void)removeItemForNode:(id)aNode;
- (void)addItemForNode:(id)aNode;
- (void)dealloc;
- (id)init;
- (id)initForRenderingCardNodes:(BOOL)aNodes;
@end

