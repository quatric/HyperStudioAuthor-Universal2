#import "HyperStudioPrefix.h"


@interface HSToolView : HSCardView <HSSelectionHolder, HSSelectionAccessor, NSObject, HSCardObjectSelectionAccessor, HSCardSelectionAccessor, HSSelectionOwner, HSSelectionHost, HSPrimitiveSelectionHost>
{
    HSNodeSelection *_selection;
    id _selectionChangeDelegate;
    BOOL _isNotEditable;
    BOOL _isUpdatingSelection;
    BOOL _canvasLayersRunningDisabledByToolManager;
    BOOL _isOccupiedByTool;
    BOOL _isSynchronizingWithSelectionHost;
    HSRunTimeEditorController *_runTimeEditorController;
    id<HSDocumentSelectionHolderInterface> _documentSelectionHolder;
}
+ (id)visualizationProtocol;
- (void)endGestureWithEvent:(id)aEvent;
- (void)beginGestureWithEvent:(id)aEvent;
- (id)helperForTracker;
- (void)setOccupiedByTool:(BOOL)aTool;
- (BOOL)isOccupiedByTool;
- (void)setEditable:(BOOL)aEditable;
- (BOOL)isEditable;
- (void)drawQuartzRect:(NSRect)aRect;
- (void)postDrawContentRect:(NSRect)aRect;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (void)updateCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (void)handleMouseMoved:(id)aMoved;
- (void)mouseDown:(id)aDown;
- (void)endEditorForObject:(id)aObject;
- (BOOL)startEditor:(id)aEditor forObject:(id)aObject creationMode:(BOOL)aMode;
- (BOOL)startEditorForObject:(id)aObject creationMode:(BOOL)aMode;
- (void)cardWillChangeChildren:(id)aChildren;
- (BOOL)isAnyGroupObjectInChildren:(id)aChildren;
- (void)registerObservingUserObjectAttributesChange;
- (void)unregisterObservingUserObjectAttributesChange;
- (void)setUserObject:(id)aObject;
- (void)updateSelectionWithSelectedObject:(id)aObject;
- (id)documentSelectionHolder;
- (void)setDocumentSelectionHolder:(id)aHolder;
- (id)ownSelectedObject;
- (BOOL)supportsCanvasLayersRunningInCurrentActiveState;
- (void)toolManagerEnableCanvasLayersRunning;
- (void)toolManagerDisableCanvasLayersRunning;
- (BOOL)isPrimarySelectionAccessorForCurrentlyHeldSelection;
- (BOOL)updateSelectionWithInactiveCardViewSelectionAccessor:(id)aAccessor;
- (BOOL)isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor:(id)aAccessor;
- (BOOL)updateSelectionWithSelectionAccessor:(id)aAccessor;
- (BOOL)updateSelectionWithSelectedCard:(id)aCard orCards:(id)aCards synchronizingWithAnotherSelectionHost:(BOOL)aHost;
- (BOOL)updateSelectionWithSelectedCardObject:(id)aObject orObjects:(id)aObjects synchronizingWithAnotherSelectionHost:(BOOL)aHost;
- (void)selectHyperObjects:(id)aObjects;
- (void)selectHyperObject:(id)aObject;
- (void)selectObjects:(id)aObjects;
- (void)selectObject:(id)aObject;
- (void)addObjectToSelection:(id)aSelection;
- (void)selectNodes:(id)aNodes;
- (void)selectObjects:(id)aObjects objectsAreNodes:(BOOL)aNodes;
- (void)selectNode:(id)aNode;
- (void)addNodeToSelection:(id)aSelection;
- (id)createCanvasHitTester;
- (id)createRootCanvasLayer;
- (void)deactivateRunTimeEditor;
- (void)saveEditingState;
- (void)saveRunTimeEditors;
- (void)toolManagerDidSelectTool:(id)aTool oldTool:(id)aTool2 explicitly:(BOOL)aExplicitly;
- (void)toolManagerWillSelectTool:(id)aTool explicitly:(BOOL)aExplicitly;
- (BOOL)becomeFirstResponder;
- (void)displaySelectionHolderInactiveState;
- (void)displaySelectionHolderActiveStateAndBecomeFirstResponder:(BOOL)aResponder;
- (void)setSelectionChangeDelegate:(id)aDelegate;
- (id)selectedHyperObject;
- (id)selectionChangeDelegate;
- (void)didChangeHitTestingInterface;
- (BOOL)selection:(id)aSelection shouldIncludeNode:(id)aNode;
- (void)selectionDidChange:(id)aChange wasExpanded:(BOOL)aExpanded;
- (void)localNotifyHyperSelectionDidChangeAndActivate:(BOOL)aActivate;
- (void)localNotifyHyperSelectionDidChangeAndActivate:(BOOL)aActivate suppressLegacySelectionSynchronization:(BOOL)aSynchronization;
- (void)makeCurrentSelectionHost;
- (id)selectionObject;
- (id)selection;
- (BOOL)allowsSelectionWithTool:(id)aTool;
- (void)reflectObjectsDidRelayout;
- (NSRect)auxiliaryObjectsBoundingRect;
- (id)runTimeEditorController;
- (BOOL)acceptsFirstMouse:(id)aMouse;
- (void)dealloc;
@end

