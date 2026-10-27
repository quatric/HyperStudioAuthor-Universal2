#import "HSRunTimeEditorController.h"
#import <objc/message.h>

@implementation HSRunTimeEditorController

/* i386 ivar offsets: _parentToolView=0x4, _activeInPlaceEditor=0x8, _flags=0xc */

- (BOOL)haveChanges
{
    return (BOOL)[_activeInPlaceEditor haveChanges];
}

- (id)runtimeEditorsCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self activeEventBasedEditor];
    if (pvVar1 == nil) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [pvVar1 cursorAtPoint:aPoint inside:(unsigned int)aInside modifierFlags:aFlags event:aEvent];
    }
    return pvVar1_2;
}

- (BOOL)runtimeEditorsHandleKeyEventSelector:(SEL)aSelector
{
    BOOL BVar1;
    id pvVar2;

    pvVar2 = [self activeEventBasedEditor];
    if (pvVar2 == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[pvVar2 handleKeyEventSelector:aSelector];
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071f86 @ 00071f86, 76 bytes * /

BOOL FUN_00071f86(HSRunTimeEditorController *self,SEL _cmd,id runtimeEditorsHandleMouseMoved)

{
  BOOL BVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self,sel_activeEventBasedEditor);
  if (pvVar2 == (id)0x0) {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_handleMouseMoved_,runtimeEditorsHandleMouseMoved);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)runtimeEditorsHandleMouseMoved:(id)aMoved
{
    id editor = [self activeEventBasedEditor];
    if (editor == nil) {
        return NO;
    }
    return ((BOOL (*)(id, SEL, id))objc_msgSend)(editor, @selector(handleMouseMoved:), aMoved);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00072155 @ 00072155, 953 bytes * /

BOOL FUN_00072155(HSRunTimeEditorController *self,SEL _cmd,id runtimeEditorsHandleMouseDown)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined1 *puVar4;
  undefined4 *puVar5;
  undefined1 local_24 [20];
  
  puVar4 = &stack0xffffffb4;
  puVar5 = (undefined4 *)&stack0xffffffb4;
  pvVar2 = _objc_msgSend(self,sel_hostView);
  _objc_msgSend(runtimeEditorsHandleMouseDown,sel_locationInWindow);
  pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_);
  _objc_msgSend(self,sel_delayActivationNotifications);
  if (self->_activeInPlaceEditor == (id)0x0) {
    cVar1 = '\0';
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_activeEventBasedEditor);
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_activeEmbeddedEditor);
      if (pvVar3 != (id)0x0) {
        _objc_msgSend_stret(local_24,self->_activeInPlaceEditor,sel_occupiedAreaInHostView);
        puVar4 = &stack0xffffffb0;
        puVar5 = (undefined4 *)&stack0xffffffb0;
        pvVar3 = _objc_msgSend(self,sel_hostView);
        pvVar3 = _objc_msgSend(pvVar3,sel_mouse_inRect_);
        if ((char)pvVar3 != '\0') {
          cVar1 = '\x01';
          goto LAB_000722b9;
        }
      }
      cVar1 = '\0';
      puVar5 = (undefined4 *)puVar4;
    }
    else {
      pvVar3 = _objc_msgSend(pvVar3,sel_handleMouseDown_);
      cVar1 = (char)pvVar3;
      puVar5 = (undefined4 *)&stack0xffffffb4;
    }
LAB_000722b9:
    puVar5[1] = sel_hostView;
    *puVar5 = self;
    puVar5[-1] = 0x722d0;
    pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    puVar5[2] = &DAT_00365b38;
    puVar5[1] = sel_queryHyperInterface_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x722ec;
    pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    if (cVar1 != '\0') goto LAB_000724ec;
    puVar5[1] = sel_isColorPickingModeActive;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x72306;
    pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    if ((char)pvVar3 == '\0') {
      puVar5[1] = sel_deactivateInPlaceEditor;
      *puVar5 = self;
      puVar5[-1] = 0x7231f;
      _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    }
  }
  puVar5[1] = sel_clickCount;
  *puVar5 = runtimeEditorsHandleMouseDown;
  puVar5[-1] = 0x72334;
  pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  if (pvVar3 == (id)0x2) {
    puVar5[1] = sel_modifierFlags;
    *puVar5 = runtimeEditorsHandleMouseDown;
    puVar5[-1] = 0x72352;
    pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    if (((uint)pvVar3 & 0x100000) == 0) {
      puVar5[1] = sel_parentToolView;
      *puVar5 = self;
      puVar5[-1] = 0x72372;
      pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
      puVar5[1] = sel_canvasHitTester;
      *puVar5 = pvVar3;
      puVar5[-1] = 0x72384;
      pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
      puVar5[3] = extraout_EDX;
      puVar5[2] = pvVar2;
      puVar5[1] = sel_hitTestNodeAtPoint_;
      *puVar5 = pvVar3;
      puVar5[-1] = 0x723ac;
      pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
      if (pvVar3 != (id)0x0) {
        puVar5[4] = extraout_EDX;
        puVar5[3] = pvVar2;
        puVar5[2] = pvVar3;
        puVar5[1] = sel_startEditorForObject_atPointInHostView_;
        *puVar5 = self;
        puVar5[-1] = 0x723e3;
        pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
        cVar1 = (char)pvVar2;
        if ((cVar1 != '\0') && (self->_activeInPlaceEditor != (id)0x0)) {
          puVar5[1] = sel_sharedAssistantController;
          *puVar5 = cls_HSObjectAssistantController;
          puVar5[-1] = 0x72412;
          pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
          puVar5[2] = self->_activeInPlaceEditor;
          puVar5[1] = sel_setSelectedInModelObjectAndBringAssistantToFront_;
          *puVar5 = pvVar2;
          puVar5[-1] = 0x72430;
          _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
          puVar5[1] = sel_setActive_explicitlyByUser_;
          *puVar5 = pvVar2;
          puVar5[3] = 1;
          puVar5[2] = 1;
          puVar5[-1] = 0x72452;
          _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
          puVar5[1] = sel_modifierFlags;
          *puVar5 = runtimeEditorsHandleMouseDown;
          puVar5[-1] = 0x72467;
          pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
          if (pvVar2 < (id)0x10000) {
            puVar5[1] = sel_standardUserDefaults;
            *puVar5 = cls_NSUserDefaults;
            puVar5[-1] = 0x72486;
            pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
            puVar5[2] = *(undefined4 *)PTR_0033602c;
            puVar5[1] = sel_boolForKey_;
            *puVar5 = pvVar2;
            puVar5[-1] = 0x724a4;
            pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
            if ((char)pvVar2 != '\0') {
              puVar5[1] = sel_sharedAssistantController;
              *puVar5 = cls_HSObjectAssistantController;
              puVar5[-1] = 0x724c0;
              pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
              puVar5[1] = sel_objectAssistant;
              *puVar5 = pvVar2;
              puVar5[-1] = 0x724d2;
              pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
              puVar5[1] = sel_setPrefersInspectorMode_;
              *puVar5 = pvVar2;
              puVar5[2] = 0;
              puVar5[-1] = 0x724ec;
              _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
            }
          }
        }
      }
    }
  }
LAB_000724ec:
  puVar5[1] = sel_flushActivationNotifications;
  *puVar5 = self;
  puVar5[-1] = 0x72504;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return cVar1;
}

*/
- (BOOL)runtimeEditorsHandleMouseDown:(id)aDown
{
    NSPoint point = [[self hostView] convertPoint:[aDown locationInWindow] fromView:nil];
    BOOL handled = NO;
    [self delayActivationNotifications];
    if (_activeInPlaceEditor != nil) {
        id eventEditor = [self activeEventBasedEditor];
        if (eventEditor == nil) {
            if ([self activeEmbeddedEditor] != nil) {
                handled = [[self hostView] mouse:point inRect:[_activeInPlaceEditor occupiedAreaInHostView]];
            }
        } else {
            handled = [eventEditor handleMouseDown:aDown];
        }
        id pickingController = [[self hostView] queryHyperInterface:@protocol(HSColorPickingController)];
        if (handled) {
            [self flushActivationNotifications];
            return handled;
        }
        if (![pickingController isColorPickingModeActive]) {
            [self deactivateInPlaceEditor];
        }
    }
    if ([aDown clickCount] == 2 && ([aDown modifierFlags] & NSEventModifierFlagCommand) == 0) {
        id node = [[[self parentToolView] canvasHitTester] hitTestNodeAtPoint:point];
        if (node != nil) {
            handled = [self startEditorForObject:node atPointInHostView:point];
            if (handled && _activeInPlaceEditor != nil) {
                id assistantController = [HSObjectAssistantController sharedAssistantController];
                [assistantController setSelectedInModelObjectAndBringAssistantToFront:_activeInPlaceEditor];
                [assistantController setActive:YES explicitlyByUser:YES];
                if ([aDown modifierFlags] < 0x10000) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:HSForceSOTSForObjectDoubleClickKey]) {
                        [[assistantController objectAssistant] setPrefersInspectorMode:NO];
                    }
                }
            }
        }
    }
    [self flushActivationNotifications];
    return handled;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071f47 @ 00071f47, 63 bytes * /

void FUN_00071f47(HSRunTimeEditorController *self,SEL _cmd,NSRect hyperRenderRect)

{
  _objc_msgSend(self->_activeInPlaceEditor,sel_hyperRenderRect_,hyperRenderRect.origin,
                hyperRenderRect.size);
  return;
}

*/
- (void)hyperRenderRect:(NSRect)aRect
{
    [_activeInPlaceEditor hyperRenderRect:aRect];
}

- (id)selectedRunTimeEditorObject
{
    return _activeInPlaceEditor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071ee8 @ 00071ee8, 95 bytes * /

void FUN_00071ee8(HSRunTimeEditorController *self,SEL _cmd)

{
  id self_00;
  
  if ((self->_flags).activationNotificationDelayed == 0) {
    self_00 = _objc_msgSend(self->_parentToolView,sel_queryHyperInterface_,&DAT_00365ae8);
    _objc_msgSend(self_00,sel_selectedRuntimeEditorDidChangeAndWantsToActivate_,0);
  }
  else {
    self->_flags = (anon_435fb0c6_2)((uint)self->_flags | 8);
  }
  return;
}

*/
- (void)notifyDidDeactivateRuntimeEditor
{
    if (!_flags.activationNotificationDelayed) {
        [[_parentToolView queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] selectedRuntimeEditorDidChangeAndWantsToActivate:NO];
    } else {
        _flags.deactivateNotificationPending = 1;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071e89 @ 00071e89, 95 bytes * /

void FUN_00071e89(HSRunTimeEditorController *self,SEL _cmd)

{
  id self_00;
  
  if ((self->_flags).activationNotificationDelayed == 0) {
    self_00 = _objc_msgSend(self->_parentToolView,sel_queryHyperInterface_,&DAT_00365ae8);
    _objc_msgSend(self_00,sel_selectedRuntimeEditorDidChangeAndWantsToActivate_,1);
  }
  else {
    self->_flags = (anon_435fb0c6_2)((uint)self->_flags | 4);
  }
  return;
}

*/
- (void)notifyDidActivateRuntimeEditor
{
    if (!_flags.activationNotificationDelayed) {
        [[_parentToolView queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] selectedRuntimeEditorDidChangeAndWantsToActivate:YES];
    } else {
        _flags.activateNotificationPending = 1;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071e1f @ 00071e1f, 106 bytes * /

void FUN_00071e1f(HSRunTimeEditorController *self,SEL _cmd)

{
  anon_435fb0c6_2 *paVar1;
  anon_435fb0c6_2 *paVar2;
  anon_435fb0c6_2 aVar3;
  anon_435fb0c6_2 aVar4;
  anon_435fb0c6_2 aVar5;
  id self_00;
  
  paVar2 = &self->_flags;
  paVar2->activationNotificationDelayed = 0;
  paVar2->deactivateNotificationPending = 0;
  paVar2->activateNotificationPending = 0;
  if (((paVar1->deactivateNotificationPending | paVar1->activateNotificationPending) & 1) != 0) {
    self_00 = _objc_msgSend(self->_parentToolView,sel_queryHyperInterface_,&DAT_00365ae8);
    _objc_msgSend(self_00,sel_selectedRuntimeEditorDidChangeAndWantsToActivate_,
                  paVar1->activateNotificationPending);
  }
  return;
}

*/
- (void)flushActivationNotifications
{
    BOOL activatePending = _flags.activateNotificationPending;
    BOOL deactivatePending = _flags.deactivateNotificationPending;
    _flags.activationNotificationDelayed = 0;
    _flags.deactivateNotificationPending = 0;
    _flags.activateNotificationPending = 0;
    if (deactivatePending || activatePending) {
        [[_parentToolView queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] selectedRuntimeEditorDidChangeAndWantsToActivate:activatePending];
    }
}

- (void)delayActivationNotifications
{
    (_flags).activationNotificationDelayed = 1;
}

- (BOOL)shouldActiveRuntimeEditorsDisableRenderingEditingObject
{
    BOOL BVar1;
    id pvVar2;

    pvVar2 = [self editingNode];
    if ((_activeInPlaceEditor == nil) || (pvVar2 == nil)) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[_activeInPlaceEditor disablesRenderingEditingObject];
    }
    return BVar1;
}

- (id)editingNode
{
    return [[_activeInPlaceEditor editingObject] queryHyperInterface:@protocol(HSNodeAttributes)];
}

- (BOOL)runTimeEditor:(id)aEditor isEditingObject:(id)aObject
{
    BOOL bVar3;

    if ((![aEditor isEditing]) || (aObject == nil)) {
        bVar3 = NO;
    }
    else {
        if (![[[aEditor editingObject] queryHyperInterface:@protocol(HSNodeAttributes)] isEqual:[aObject queryHyperInterface:@protocol(HSNodeAttributes)]]) {
            bVar3 = [[[aEditor editingObject] hyperObject] isEqual:[aObject hyperObject]];
        }
        else {
            bVar3 = YES;
        }
    }
    return bVar3;
}

- (void)setAllowsInPlaceEditors:(BOOL)aEditors
{
    if ((unsigned int)(aEditors != NO) != (_flags).allowsInPlaceEditors) {
        if ((aEditors == NO) && (_activeInPlaceEditor != nil)) {
            if ([_activeInPlaceEditor wantsToDeactivateASAPWhenSwitchToNonRuntimeEditorTool]) {
                [self deactivateInPlaceEditor];
            }
        }
        (_flags).allowsInPlaceEditors = aEditors != NO;
    }
}

- (BOOL)allowsInPlaceEditors
{
    return (_flags).allowsInPlaceEditors;
}

- (void)saveAllEditors
{
    [_activeInPlaceEditor saveEditing];
}

- (void)deactivateInPlaceEditor
{
    if (_activeInPlaceEditor != nil) {
        [_activeInPlaceEditor saveEditing];
        [self clearActiveInPlaceEditor];
    }
}

- (void)deactivateAllEditors
{
    [self deactivateInPlaceEditor];
}

- (void)deactivateEditorForObject:(id)aObject
{
    if ([self runTimeEditor:_activeInPlaceEditor isEditingObject:aObject]) {
        [self deactivateInPlaceEditor];
    }
}

- (void)setParentToolView:(id)aView
{
    if (_parentToolView != aView) {
        if (_parentToolView != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:0 object:_parentToolView];
        }
        _parentToolView = aView;
        if (aView != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidChangeUserSpaceToViewSpaceTransform:) name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:_parentToolView];
        }
    }
}

- (id)parentToolView
{
    return _parentToolView;
}

- (id)activeEventBasedEditor
{
    return [_activeInPlaceEditor queryHyperInterface:@protocol(HSEventBasedEditor)];
}

- (id)activeEmbeddedEditor
{
    return [_activeInPlaceEditor queryHyperInterface:@protocol(HSEmbeddedEditor)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000719bf @ 000719bf, 80 bytes * /

void FUN_000719bf(HSRunTimeEditorController *self,SEL _cmd,NSRect setNeedsDisplayInRect)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_parentToolView);
  _objc_msgSend(self_00,sel_setNeedsDisplayInRect_,setNeedsDisplayInRect.origin,
                setNeedsDisplayInRect.size);
  return;
}

*/
- (void)setNeedsDisplayInRect:(NSRect)aRect
{
    [[self parentToolView] setNeedsDisplayInRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007250e @ 0007250e, 141 bytes * /

void FUN_0007250e(HSRunTimeEditorController *self,SEL _cmd,id setNeedsDisplayRunTimeEditor)

{
  char cVar1;
  id self_00;
  undefined8 local_1c;
  undefined8 local_14;
  
  _objc_msgSend_stret(&local_1c,setNeedsDisplayRunTimeEditor,sel_boundsInHostView);
  cVar1 = _NSIsEmptyRect(local_1c,local_14);
  if (cVar1 == '\0') {
    self_00 = _objc_msgSend(self,sel_parentToolView);
    _objc_msgSend(self_00,sel_setNeedsDisplayOpenGLSurfaceInRect_,local_1c,local_14);
  }
  return;
}

*/
- (void)setNeedsDisplayRunTimeEditor:(id)aEditor
{
    NSRect bounds = [aEditor boundsInHostView];
    if (!NSIsEmptyRect(bounds)) {
        [[self parentToolView] setNeedsDisplayOpenGLSurfaceInRect:bounds];
    }
}

- (void)runtimeEditorWantsToResign:(id)aResign
{
    [self clearActiveInPlaceEditor];
}

- (id)canvasHitTester
{
    return [[self parentToolView] canvasHitTester];
}

- (id)presentationContext
{
    return [[self parentToolView] presentationContext];
}

- (id)hostView
{
    return [self parentToolView];
}

- (void)viewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform
{
    if (([aTransform object] == _parentToolView) && (_activeInPlaceEditor != nil)) {
        [_activeInPlaceEditor hostViewDidChangeUserSpaceToViewSpaceTransform];
    }
}

- (BOOL)startEditorForObject:(id)aObject atPointInHostView:(NSPoint)aView
{
    return (BOOL)[self startEditorForObject:aObject onlyIfPoint:aView isInside:YES creationMode:NO];
}

- (BOOL)startEditor:(id)aEditor forObject:(id)aObject creationMode:(BOOL)aMode
{
    return (BOOL)[self setupActiveInPlaceEditor:aEditor forObject:aObject inCreationMode:aMode onlyIfPoint:NSZeroPoint isInside:NO];
}

- (BOOL)startEditorForObject:(id)aObject creationMode:(BOOL)aMode
{
    return (BOOL)[self startEditorForObject:aObject onlyIfPoint:NSZeroPoint isInside:NO creationMode:aMode];
}

- (BOOL)startEditorForObject:(id)aObject onlyIfPoint:(NSPoint)aPoint isInside:(BOOL)aInside creationMode:(BOOL)aMode
{
    BOOL BVar1;
    id pvVar2_2;

    pvVar2_2 = [[HSRunTimeEditorFactory sharedInstance] createRunTimeEditorForObject:aObject];
    if (pvVar2_2 == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[self setupActiveInPlaceEditor:pvVar2_2 forObject:aObject inCreationMode:aMode onlyIfPoint:aPoint isInside:aInside];
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007259b @ 0007259b, 728 bytes * /

BOOL FUN_0007259b(HSRunTimeEditorController *self,SEL _cmd,id setupActiveInPlaceEditor,id forObject,
                 BOOL inCreationMode,NSPoint onlyIfPoint,BOOL isInside)

{
  undefined *puVar1;
  char cVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar7;
  undefined8 uVar6;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar4 = _objc_msgSend(forObject,sel_queryHyperInterface_);
  if (((self->_flags).allowsInPlaceEditors == 0 && inCreationMode == '\0') ||
     ((pvVar4 != (id)0x0 && (pvVar4 = _objc_msgSend(pvVar4,sel_isLocked), (char)pvVar4 != '\0')))) {
    cVar2 = '\0';
  }
  else {
    pvVar4 = _objc_msgSend(setupActiveInPlaceEditor,sel_retain);
    self->_activeInPlaceEditor = pvVar4;
    _objc_msgSend(pvVar4,sel_setOwner_);
    pvVar4 = _objc_msgSend(self->_activeInPlaceEditor,sel_prepareForEditingInCreationMode_);
    cVar3 = (char)pvVar4;
    if ((cVar3 != '\0') && (isInside != '\0')) {
      pvVar4 = _objc_msgSend(self->_activeInPlaceEditor,sel_prepareForEditingWithPointInHostView_);
      cVar3 = (char)pvVar4;
    }
    cVar2 = '\0';
    if (cVar3 != '\0') {
      pvVar4 = _objc_msgSend(self->_activeInPlaceEditor,sel_activateEditing);
      cVar2 = (char)pvVar4;
    }
    if (cVar2 != '\0') {
      pvVar4 = self->_activeInPlaceEditor;
      goto LAB_000726c0;
    }
  }
  if (self->_activeInPlaceEditor != (id)0x0) {
    _objc_msgSend(self->_activeInPlaceEditor,sel_setOwner_);
    _objc_msgSend(self->_activeInPlaceEditor,sel_release);
    self->_activeInPlaceEditor = (id)0x0;
    return cVar2;
  }
  pvVar4 = (id)0x0;
LAB_000726c0:
  if (pvVar4 != (id)0x0) {
    _objc_msgSend_stret(&local_24,pvVar4,sel_boundsInHostView);
    uVar6 = local_1c;
    cVar3 = _NSIsEmptyRect(local_24,local_1c);
    if (cVar3 == '\0') {
      pvVar4 = _objc_msgSend(self,sel_parentToolView);
      _objc_msgSend(pvVar4,sel_setNeedsDisplayOpenGLSurfaceInRect_,local_24,local_1c);
      uVar6 = local_24;
    }
    _objc_msgSend(self,sel_notifyDidActivateRuntimeEditor,uVar6);
    uVar7 = (undefined4)((ulonglong)uVar6 >> 0x20);
    pvVar4 = _objc_msgSend(self,sel_parentToolView);
    pvVar4 = _objc_msgSend(pvVar4,sel_rootCanvasLayer);
    pvVar4 = _objc_msgSend(pvVar4,sel_arrowToolCanvasLayer);
    puVar1 = PTR_PTR_003363c0;
    uVar6 = CONCAT44(uVar7,*(undefined4 *)PTR_PTR_003363c0);
    pvVar5 = _objc_msgSend(pvVar4,sel_isEnabledSublayerForIdentifier_,
                           *(undefined4 *)PTR_PTR_003363c0);
    if ((char)pvVar5 != '\0') {
      uVar6 = CONCAT44((int)((ulonglong)uVar6 >> 0x20),*(undefined4 *)puVar1);
      _objc_msgSend(pvVar4,sel_disableSublayerForIdentifier_,*(undefined4 *)puVar1);
    }
    pvVar4 = _objc_msgSend(self,sel_shouldActiveRuntimeEditorsDisableRenderingEditingObject,uVar6);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(self,sel_parentToolView,uVar6);
      pvVar5 = _objc_msgSend(self,sel_editingNode);
      _objc_msgSend(pvVar4,sel_disableVisualizationForNode_,pvVar5);
    }
  }
  return cVar2;
}

*/
- (BOOL)setupActiveInPlaceEditor:(id)aEditor forObject:(id)aObject inCreationMode:(BOOL)aMode onlyIfPoint:(NSPoint)aPoint isInside:(BOOL)aInside
{
    id lockAttributes = [aObject queryHyperInterface:@protocol(HSCardObjectAttributes)];
    BOOL activated = NO;
    if ((_flags.allowsInPlaceEditors || aMode) && !(lockAttributes != nil && [lockAttributes isLocked])) {
        _activeInPlaceEditor = [aEditor retain];
        [_activeInPlaceEditor setOwner:self];
        BOOL prepared = [_activeInPlaceEditor prepareForEditingInCreationMode:aMode];
        if (prepared && aInside) {
            prepared = [_activeInPlaceEditor prepareForEditingWithPointInHostView:aPoint];
        }
        if (prepared) {
            activated = [_activeInPlaceEditor activateEditing];
        }
    }
    if (!activated) {
        if (_activeInPlaceEditor != nil) {
            [_activeInPlaceEditor setOwner:nil];
            [_activeInPlaceEditor release];
            _activeInPlaceEditor = nil;
        }
        return NO;
    }
    NSRect bounds = [_activeInPlaceEditor boundsInHostView];
    if (!NSIsEmptyRect(bounds)) {
        [[self parentToolView] setNeedsDisplayOpenGLSurfaceInRect:bounds];
    }
    [self notifyDidActivateRuntimeEditor];
    id arrowLayer = [[[self parentToolView] rootCanvasLayer] arrowToolCanvasLayer];
    if ([arrowLayer isEnabledSublayerForIdentifier:@"HSSelectionCanvasLayer"]) {
        [arrowLayer disableSublayerForIdentifier:@"HSSelectionCanvasLayer"];
    }
    if ([self shouldActiveRuntimeEditorsDisableRenderingEditingObject]) {
        [[self parentToolView] disableVisualizationForNode:[self editingNode]];
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00072873 @ 00072873, 654 bytes * /

void FUN_00072873(HSRunTimeEditorController *self,SEL _cmd)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar8;
  undefined8 uVar7;
  undefined8 local_24;
  undefined8 local_1c;
  
  if (self->_activeInPlaceEditor != (id)0x0) {
    pvVar3 = _objc_msgSend(self->_activeInPlaceEditor,sel_retain);
    pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
    pvVar4 = _objc_msgSend(self,sel_shouldActiveRuntimeEditorsDisableRenderingEditingObject);
    pvVar5 = _objc_msgSend(self,sel_editingNode);
    _objc_msgSend_stret(&local_24,self->_activeInPlaceEditor,sel_boundsInHostView);
    _objc_msgSend(self->_activeInPlaceEditor,sel_deactivateEditing);
    _objc_msgSend(self->_activeInPlaceEditor,sel_setOwner_,0);
    _objc_msgSend(self->_activeInPlaceEditor,sel_release);
    self->_activeInPlaceEditor = (id)0x0;
    uVar7 = local_1c;
    cVar2 = _NSIsEmptyRect(local_24,local_1c);
    if (cVar2 == '\0') {
      pvVar6 = _objc_msgSend(self,sel_parentToolView);
      _objc_msgSend(pvVar6,sel_setNeedsDisplayOpenGLSurfaceInRect_,local_24,local_1c);
      uVar7 = local_24;
    }
    _objc_msgSend(self,sel_notifyDidDeactivateRuntimeEditor,uVar7);
    uVar8 = (undefined4)((ulonglong)uVar7 >> 0x20);
    _objc_msgSend(pvVar3,sel_postProcessEditingObjectAfterDeactivateEditing);
    pvVar3 = _objc_msgSend(self,sel_parentToolView);
    pvVar3 = _objc_msgSend(pvVar3,sel_rootCanvasLayer);
    pvVar3 = _objc_msgSend(pvVar3,sel_arrowToolCanvasLayer);
    puVar1 = PTR_PTR_003363c0;
    uVar7 = CONCAT44(uVar8,*(undefined4 *)PTR_PTR_003363c0);
    pvVar6 = _objc_msgSend(pvVar3,sel_isEnabledSublayerForIdentifier_,
                           *(undefined4 *)PTR_PTR_003363c0);
    if ((char)pvVar6 == '\0') {
      uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),*(undefined4 *)puVar1);
      _objc_msgSend(pvVar3,sel_enableSublayerForIdentifier_,*(undefined4 *)puVar1);
    }
    if ((char)pvVar4 != '\0') {
      pvVar3 = _objc_msgSend(self,sel_parentToolView,uVar7);
      uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),pvVar5);
      _objc_msgSend(pvVar3,sel_reenableVisualizationForNode_,pvVar5);
    }
    if (pvVar5 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar7);
      pvVar3 = _objc_msgSend(pvVar3,sel_currentTool);
      pvVar4 = _objc_msgSend(cls_HSTextTool,sel_class);
      pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
      if ((char)pvVar4 != '\0') {
        _objc_msgSend(pvVar3,sel_saveChangesAndNotify_,0);
      }
    }
  }
  return;
}

*/
- (void)clearActiveInPlaceEditor
{
    if (_activeInPlaceEditor != nil) {
        id editor = [[_activeInPlaceEditor retain] autorelease];
        BOOL disablesRendering = [self shouldActiveRuntimeEditorsDisableRenderingEditingObject];
        id node = [self editingNode];
        NSRect bounds = [_activeInPlaceEditor boundsInHostView];
        [_activeInPlaceEditor deactivateEditing];
        [_activeInPlaceEditor setOwner:nil];
        [_activeInPlaceEditor release];
        _activeInPlaceEditor = nil;
        if (!NSIsEmptyRect(bounds)) {
            [[self parentToolView] setNeedsDisplayOpenGLSurfaceInRect:bounds];
        }
        [self notifyDidDeactivateRuntimeEditor];
        [editor postProcessEditingObjectAfterDeactivateEditing];
        id arrowLayer = [[[self parentToolView] rootCanvasLayer] arrowToolCanvasLayer];
        if (![arrowLayer isEnabledSublayerForIdentifier:@"HSSelectionCanvasLayer"]) {
            [arrowLayer enableSublayerForIdentifier:@"HSSelectionCanvasLayer"];
        }
        if (disablesRendering) {
            [[self parentToolView] reenableVisualizationForNode:node];
        }
        if (node == nil) {
            id tool = [[HSToolManager sharedToolManager] currentTool];
            if ([tool isKindOfClass:[HSTextTool class]]) {
                [tool saveChangesAndNotify:NO];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_activeInPlaceEditor setOwner:nil];
    [_activeInPlaceEditor release];
    [super dealloc];
}

@end

