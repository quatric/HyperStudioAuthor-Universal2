#import "HyperStudioPrefix.h"


@interface HSBaseRunTimeEditor : HSHyperImplementation <HSRunTimeEditor, HyperInterface, NSObject, HSSelectableObject, HSAttributeObserving, HSNodeSupportAttributes, HSAttributes, HSNodeSupportAttribute, HSAttribute>
{
    id<HSRunTimeEditorHost> _owner;
    BOOL _isInCreationMode;
    BOOL _isEditing;
}
- (BOOL)haveChanges;
- (id)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfoInvocation:(id)aInvocation;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (id)attributesChangedTemporary;
- (id)attributesBeingChangedContinuously;
- (void)endContinuousChangeOfAttributeSet:(id)aSet;
- (void)beginContinuousChangeOfAttributeSet:(id)aSet;
- (void)endContinuousChangeOfAttribute:(id)aAttribute;
- (void)beginContinuousChangeOfAttribute:(id)aAttribute;
- (void)removeAttributeObserver:(id)aObserver;
- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (id)attributeObservingController;
- (id)attributeNotificationCenter;
- (void)hostViewDidChangeUserSpaceToViewSpaceTransform;
- (BOOL)disablesRenderingEditingObject;
- (void)hyperRenderRect:(NSRect)aRect;
- (NSRect)boundsInHostView;
- (NSRect)occupiedAreaInHostView;
- (BOOL)isActive;
- (BOOL)isInCreationMode;
- (BOOL)isEditing;
- (id)editingObject;
- (void)postProcessEditingObjectAfterDeactivateEditing;
- (void)saveEditing;
- (void)deactivateEditing;
- (BOOL)wantsToDeactivateASAPWhenSwitchToNonRuntimeEditorTool;
- (BOOL)activateEditing;
- (BOOL)prepareForEditingWithPointInHostView:(NSPoint)aView;
- (BOOL)prepareForEditing;
- (BOOL)prepareForEditingInCreationMode:(BOOL)aMode;
- (id)support;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (id)hyperKindDisplayName;
- (BOOL)canStartEditingWithPointInHostView:(NSPoint)aView;
- (void)notifyWantsToCancel;
- (void)notifyWantsToFinish;
- (void)deactivate;
- (void)activate;
- (id)hostView;
- (BOOL)canEditObject;
- (id)queryHyperInterface:(id)aInterface;
- (void)dealloc;
@end

