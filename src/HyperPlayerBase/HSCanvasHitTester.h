#import "HyperPlayerBasePrefix.h"
#import "HSObservingNodesCanvasSublayer.h"


@interface HSCanvasHitTester : HSObservingNodesCanvasSublayer <HSCanvasHitTesting, HyperInterface, NSObject, HSCanvasEditorHitTesting>
{
    id<HSCanvasLayerContext> _context;
    HSProtocolIdentifier *_hitTestingInterface;
    id _rootNode;
    id<HSSizeAttributes> _cardSizeAttributes;
}
+ (BOOL)isEditorHitTestingEnabledForInterface:(id)aInterface;
- (NSRect)HSCanvasHitTester_cardRect;
- (id)representedObject;
- (void)setRootNode:(id)aNode;
- (id)rootNode;
- (id)queryHyperInterface:(id)aInterface;
- (id)hitTestNodesInRect:(NSRect)aRect;
- (BOOL)hasHitTesterForNode:(id)aNode;
- (id)hitTesterForNode:(id)aNode point:(NSPoint)aPoint;
- (id)hitTesterForNode:(id)aNode;
- (id)hitTestingItemForNode:(id)aNode;
- (id)hitTestingItemAtIndex:(NSUInteger)aIndex;
- (id)hitTestNodeAtPoint:(NSPoint)aPoint;
- (id)queryCanvasItemForNode:(id)aNode;
- (void)userObjectHitTesterAttributeDidChange:(id)aChange;
- (void)renderRect:(NSRect)aRect;
- (void)invalidateDisplay;
- (BOOL)supportsHitTesting;
- (id)context;
- (void)setCanvasLayerContext:(id)aContext;
- (id)hitTestingInterface;
- (void)setHitTestingInterface:(id)aInterface;
- (void)hiddenAttributeDidChange:(id)aChange;
- (void)dealloc;
- (id)init;
- (id)initWithHitTestingInterface:(id)aInterface;
@end

