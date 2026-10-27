#import "HyperStudioPrefix.h"


@interface HSSelectionKnobsCanvasLayer : HSCanvasRootLayerMixin
{
    NSMutableArray *_sublayers;
    BOOL _sublayersOrderIsValid;
    NSMapTable *_sublayersByNodes;
    id _selection;
}
- (void)updateKnobLayers;
- (void)rebuildKnobLayers;
- (void)removeAllKnobLayers;
- (void)buildKnobLayers;
- (id)queryCanvasSublayerForNode:(id)aNode;
- (void)objectsInSelectionDidChange:(id)aChange;
- (void)objectsInSelectionDidChange;
- (void)selectionDidChange;
- (void)updateWithSelection:(id)aSelection;
- (id)selection;
- (void)contextDidChange;
- (void)removeSublayerFromStorage:(id)aStorage atIndex:(NSUInteger)aIndex;
- (void)insertSublayerInStorage:(id)aStorage atIndex:(NSUInteger)aIndex;
- (NSUInteger)indexOfSublayer:(id)aSublayer;
- (id)sublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSublayers;
- (void)invalidateSublayersOrder;
- (id)allSublayers;
- (id)orderedSublayers;
- (id)unorderedSublayers;
- (id)sublayersByNodes;
- (void)dealloc;
@end

