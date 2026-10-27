#import "HyperStudioPrefix.h"
#import "HSBaseEmbeddedEditor.h"


@interface HSTextObjectEditor : HSBaseEmbeddedEditor <HSTextObjectAttributesImplementationParent, HSAttributes, HyperInterface, NSObject>
{
}
- (void)updateViewScaleFactor;
- (void)recalculateOccupiedRect;
- (NSRect)userSpaceObjectBounds;
- (id)nodeChildInterface;
- (id)nodeAttributes;
- (id)sizingAttributesInterface;
- (id)geometryAttributes;
- (id)attributesInterface;
- (void)runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:(id)aContent;
- (void)runTimeEditorEmbedderWantsToResign:(id)aResign;
- (BOOL)displaysFocusRing;
- (NSRect)calculateOccupiedRect;
- (BOOL)calculatedRectIsPrecise;
- (void)updateEmbeddedViewWithEditingObject;
- (void)postProcessEditingObjectAfterDeactivateEditing;
- (void)deactivate;
- (BOOL)activateEditing;
- (id)undoManager;
- (void)hostViewDidChangeUserSpaceToViewSpaceTransform;
- (BOOL)disablesRenderingEditingObject;
- (void)saveEditing;
- (id)coreTextInterface;
- (id)queryHyperInterface:(id)aInterface;
- (id)viewEmbeddingInterface;
- (id)textEditorEmbedder;
- (id)initWithHyperObject:(id)aObject;
@end

