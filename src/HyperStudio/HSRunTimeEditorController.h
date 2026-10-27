#import "HyperStudioPrefix.h"


@interface HSRunTimeEditorController : NSObject <HSRunTimeEditorHost, NSObject>
{
    HSToolView *_parentToolView;
    id<HSRunTimeEditor> _activeInPlaceEditor;
    struct HyperStudio_anon2 _flags;
}
- (BOOL)haveChanges;
- (id)runtimeEditorsCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (BOOL)runtimeEditorsHandleKeyEventSelector:(SEL)aSelector;
- (BOOL)runtimeEditorsHandleMouseMoved:(id)aMoved;
- (BOOL)runtimeEditorsHandleMouseDown:(id)aDown;
- (void)hyperRenderRect:(NSRect)aRect;
- (id)selectedRunTimeEditorObject;
- (void)notifyDidDeactivateRuntimeEditor;
- (void)notifyDidActivateRuntimeEditor;
- (void)flushActivationNotifications;
- (void)delayActivationNotifications;
- (BOOL)shouldActiveRuntimeEditorsDisableRenderingEditingObject;
- (id)editingNode;
- (BOOL)runTimeEditor:(id)aEditor isEditingObject:(id)aObject;
- (void)setAllowsInPlaceEditors:(BOOL)aEditors;
- (BOOL)allowsInPlaceEditors;
- (void)saveAllEditors;
- (void)deactivateInPlaceEditor;
- (void)deactivateAllEditors;
- (void)deactivateEditorForObject:(id)aObject;
- (void)setParentToolView:(id)aView;
- (id)parentToolView;
- (id)activeEventBasedEditor;
- (id)activeEmbeddedEditor;
- (void)setNeedsDisplayInRect:(NSRect)aRect;
- (void)setNeedsDisplayRunTimeEditor:(id)aEditor;
- (void)runtimeEditorWantsToResign:(id)aResign;
- (id)canvasHitTester;
- (id)presentationContext;
- (id)hostView;
- (void)viewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform;
- (BOOL)startEditorForObject:(id)aObject atPointInHostView:(NSPoint)aView;
- (BOOL)startEditor:(id)aEditor forObject:(id)aObject creationMode:(BOOL)aMode;
- (BOOL)startEditorForObject:(id)aObject creationMode:(BOOL)aMode;
- (BOOL)startEditorForObject:(id)aObject onlyIfPoint:(NSPoint)aPoint isInside:(BOOL)aInside creationMode:(BOOL)aMode;
- (BOOL)setupActiveInPlaceEditor:(id)aEditor forObject:(id)aObject inCreationMode:(BOOL)aMode onlyIfPoint:(NSPoint)aPoint isInside:(BOOL)aInside;
- (void)clearActiveInPlaceEditor;
- (void)dealloc;
@end

