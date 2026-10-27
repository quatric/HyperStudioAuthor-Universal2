#import "HyperStudioPrefix.h"
#import "HSBaseRunTimeEditor.h"


@interface HSBaseEmbeddedEditor : HSBaseRunTimeEditor <HSEmbeddedEditor, HSRunTimeEditor, HyperInterface, NSObject, HSSelectableObject, HSRunTimeEditorEmbedderObserver, HSTextObjectSelectionInterface>
{
    NSView *_embeddedView;
    id<HSRunTimeEditorEmbedder> _viewEmbedder;
    NSRect _occupiedRect;
    NSRect _boundsInHostView;
    BOOL _isDeactivating;
    BOOL _calculatedRectsAreValid;
    BOOL _isEditorChanged;
}
- (void)setHyperSelectedRange:(NSRange)aRange;
- (NSRange)hyperSelectedRange;
- (void)textView:(id)aView willInsertText:(id)aText;
- (void)setEditorChanged:(BOOL)aChanged;
- (void)unregisterFromAttributesDidChangeNotifications;
- (void)registerForAttributesDidChangeNotifications;
- (void)unregisterFromNotifications;
- (void)registerForNotifications;
- (void)recalculateRects;
- (void)runTimeEditorEmbedderWillChangeSelectionWithoutChangingContent:(id)aContent;
- (void)runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:(id)aContent;
- (void)runTimeEditorEmbedderDidChangeContent:(id)aContent;
- (void)runTimeEditorEmbedderWantsToCancel:(id)aCancel;
- (void)runTimeEditorEmbedderWantsToResign:(id)aResign;
- (id)embeddedView;
- (void)hostViewDidChangeUserSpaceToViewSpaceTransform;
- (BOOL)disablesRenderingEditingObject;
- (void)hyperRenderRect:(NSRect)aRect;
- (NSRect)boundsInHostView;
- (NSRect)occupiedAreaInHostView;
- (void)setOwner:(id)aOwner;
- (BOOL)isActive;
- (void)deactivate;
- (void)activate;
- (BOOL)shouldAutoResizeEditorToFitContent;
- (BOOL)isEditorChanged;
- (void)clearChangedState;
- (void)didChangeContent;
- (void)attributesDidChange:(id)aChange;
- (id)attributesDidChangeNotificationNames;
- (BOOL)isDeactivating;
- (BOOL)displaysFocusRing;
- (NSRect)editingObjectBounds;
- (NSRect)boundsWithOccupiedRect:(NSRect)aRect;
- (NSRect)calculateOccupiedRect;
- (BOOL)calculatedRectIsPrecise;
- (void)recalculateOccupiedRectIfNeeded;
- (void)recalculateOccupiedRect;
- (void)updateEmbeddedViewWithEditingObject;
- (id)loadEmbeddedView;
- (void)setViewEmbedder:(id)aEmbedder;
- (id)viewEmbedder;
- (id)viewEmbeddingInterface;
- (void)dealloc;
@end

