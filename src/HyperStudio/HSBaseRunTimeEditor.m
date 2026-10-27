#import "HSBaseRunTimeEditor.h"

@implementation HSBaseRunTimeEditor

/* i386 ivar offsets: _owner=0x8, _isInCreationMode=0xc, _isEditing=0xd */

- (BOOL)haveChanges
{
    return NO;
}

- (id)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfoInvocation:(id)aInvocation
{
    id pvVar1;

    pvVar1 = [HSAttributeNotification notificationWithChange:aChange attribute:aAttribute object:self userInfoInvocation:aInvocation];
    [[self attributeNotificationCenter] postAttributeChangeNotification:pvVar1];
    return [pvVar1 userInfoIfCreated];
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    [[self attributeNotificationCenter] notifyChange:aChange ofAttribute:aAttribute ofObject:self withUserInfo:aInfo];
}

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:nil ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

- (void)hostViewDidChangeUserSpaceToViewSpaceTransform
{

}

- (BOOL)disablesRenderingEditingObject
{
    return NO;
}

- (void)hyperRenderRect:(NSRect)aRect
{

}

- (NSRect)boundsInHostView
{
    NSRect result;

    result = [self occupiedAreaInHostView];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006c522 @ 0006c522, 60 bytes * /

NSRect * FUN_0006c522(NSRect *__return_storage_ptr__,HSBaseRunTimeEditor *self,SEL _cmd)

{
  float fVar1;
  undefined *puVar2;
  NSRect *pNVar3;
  
  puVar2 = PTR_00336078;
  pNVar3 = (NSRect *)PTR_00336078;
  fVar1 = *(float *)(PTR_00336078 + 4);
  (__return_storage_ptr__->origin).x = *(float *)PTR_00336078;
  (__return_storage_ptr__->origin).y = fVar1;
  (__return_storage_ptr__->size).width = *(float *)(puVar2 + 8);
  (__return_storage_ptr__->size).height = *(float *)(puVar2 + 0xc);
  return pNVar3;
}

*/
- (NSRect)occupiedAreaInHostView
{
    return NSZeroRect;
    return (NSRect){0};
}

- (BOOL)isActive
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isInCreationMode
{
    return _isInCreationMode;
}

- (BOOL)isEditing
{
    return _isEditing;
}

- (id)editingObject
{
    return [self hyperObject];
}

- (void)postProcessEditingObjectAfterDeactivateEditing
{

}

- (void)saveEditing
{

}

- (void)deactivateEditing
{
    [self deactivate];
    _isEditing = NO;
}

- (BOOL)wantsToDeactivateASAPWhenSwitchToNonRuntimeEditorTool
{
    return YES;
}

- (BOOL)activateEditing
{
    BOOL pvVar1;

    [self activate];
    pvVar1 = [self isActive];
    if (!pvVar1) {
        _isEditing = NO;
    }
    return pvVar1;
}

- (BOOL)prepareForEditingWithPointInHostView:(NSPoint)aView
{
    BOOL BVar1;

    if (_isEditing == NO) {
        BVar1 = NO;
    }
    else {
        if (![self canStartEditingWithPointInHostView:aView]) {
            _isEditing = NO;
            BVar1 = NO;
        }
        else {
            BVar1 = _isEditing;
        }
    }
    return BVar1;
}

- (BOOL)prepareForEditing
{
    return YES;
}

- (BOOL)prepareForEditingInCreationMode:(BOOL)aMode
{
    BOOL BVar1;

    if (![self canEditObject]) {
        BVar1 = _isEditing;
    }
    else {
        BVar1 = (BOOL)[self prepareForEditing];
        _isEditing = BVar1;
        _isInCreationMode = aMode;
    }
    return BVar1;
}

- (id)support
{
    id pvVar1;

    if (_owner == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [[[self hyperObject] queryHyperInterface:@protocol(HSNodeSupportAttributes)] support];
    }
    return pvVar1;
}

- (void)setOwner:(id)aOwner
{
    if (_owner != aOwner) {
        [self notifyChange:1 ofAttribute:@protocol(HSNodeSupportAttribute) withUserInfo:nil];
        _owner = aOwner;
        [self notifyChange:2 ofAttribute:@protocol(HSNodeSupportAttribute) withUserInfo:nil];
    }
}

- (id)owner
{
    return _owner;
}

- (id)hyperKindDisplayName
{
    id pcVar2;

    pcVar2 = [[[self hyperObject] queryHyperInterface:@protocol(HSSelectableObject)] hyperKindDisplayName];
    if (pcVar2 == NULL) {
        pcVar2 = @"";
    }
    return pcVar2;
}

- (BOOL)canStartEditingWithPointInHostView:(NSPoint)aView
{
    return YES;
}

- (void)notifyWantsToCancel
{
    [_owner runtimeEditorWantsToResign:self];
}

- (void)notifyWantsToFinish
{
    [self saveEditing];
    [_owner runtimeEditorWantsToResign:self];
}

- (void)deactivate
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)activate
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id)hostView
{
    return [_owner hostView];
}

- (BOOL)canEditObject
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006d0cc @ 0006d0cc, 345 bytes * /

id FUN_0006d0cc(HSBaseRunTimeEditor *self,SEL _cmd,id queryHyperInterface)

{
  undefined *puVar1;
  char cVar2;
  char *pcVar3;
  char *pcVar4;
  int iVar5;
  id pvVar6;
  HSBaseRunTimeEditor *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_00336340;
  if (queryHyperInterface != &DAT_003650c0) {
    if (*(double *)PTR_00336340 <= 677.0 && *(double *)PTR_00336340 != 677.0) {
      pcVar3 = _objc_msgSend(queryHyperInterface,sel_name);
    }
    else {
      pcVar3 = (char *)_protocol_getName(queryHyperInterface);
    }
    if (pcVar3 == (char *)0x0) goto LAB_0006d1f2;
    if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
      pcVar4 = _objc_msgSend(&DAT_003650c0,sel_name);
    }
    else {
      pcVar4 = (char *)_protocol_getName(&DAT_003650c0);
    }
    if ((pcVar4 == (char *)0x0) || (iVar5 = _strcmp(pcVar3,pcVar4), iVar5 != 0)) goto LAB_0006d1f2;
    if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
      pvVar6 = _objc_msgSend(queryHyperInterface,sel_isEqual_,&DAT_003650c0);
      cVar2 = (char)pvVar6;
    }
    else {
      cVar2 = _protocol_isEqual(queryHyperInterface,&DAT_003650c0);
    }
    if (cVar2 == '\0') goto LAB_0006d1f2;
  }
  pvVar6 = _objc_msgSend(self,sel_hyperObject);
  pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,queryHyperInterface);
  if (pvVar6 != (id)0x0) {
    return pvVar6;
  }
LAB_0006d1f2:
  local_1c = self;
  local_18 = PTR_s_HSHyperImplementation_0034e7d0;
  pvVar6 = _objc_msgSendSuper(&local_1c,sel_queryHyperInterface_,queryHyperInterface);
  return pvVar6;
}

*/
- (id)queryHyperInterface:(id)aInterface
{
    if (protocol_isEqual(aInterface, @protocol(HSSelectableObject))) {
        id result = [[self hyperObject] queryHyperInterface:aInterface];
        if (result != nil) {
            return result;
        }
    }
    return [super queryHyperInterface:aInterface];
    return 0;
}

- (void)dealloc
{
    [super dealloc];
}

@end

