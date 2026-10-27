#import "HSButtonTypeAssistantPane.h"
static id sDAT_00342a08;

static id sDAT_00342a08;


@implementation HSButtonTypeAssistantPane

/* i386 ivar offsets: _buttonTypeMatrix=0x88, _paneState=0x8c, _navigationPaneSwitcher=0x90, _storedPaneState=0x94, _storedInvisibleButtonBounds=0x98 */

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020c1ee @ 0020c1ee, 221 bytes * /

id FUN_0020c1ee(HSButtonTypeAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined8 local_1c;
  undefined8 local_14;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
  _objc_msgSend_stret(&local_1c,pvVar2,sel_boundingRect);
  cVar1 = _NSEqualRects(local_1c,local_14,*(undefined8 *)PTR_00336078,
                        *(undefined8 *)(PTR_00336078 + 8));
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,local_1c,local_14);
  }
  else {
    pvVar2 = (id)0x0;
  }
  return pvVar2;
}

*/
- (id)currentButtonBorderPath
{
    id geometry = [[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)];
    NSRect bounds = [geometry boundingRect];
    if (NSEqualRects(bounds, NSZeroRect)) {
        return nil;
    }
    return [NSBezierPath bezierPathWithRect:bounds];
}

- (id)defaultButtonBorderPath
{
    if (sDAT_00342a08 == nil) {
        sDAT_00342a08 = [[NSBezierPath bezierPathWithRect:[[[HSButtonObject defaultObject] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect]] retain];
    }
    return sDAT_00342a08;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020c382 @ 0020c382, 557 bytes * /

void FUN_0020c382(HSButtonTypeAssistantPane *self,SEL _cmd,id drawPaneDidDone,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  HSButtonObjectAssistantPaneState *pHVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  HSButtonTypeAssistantPane *pHVar6;
  SEL op;
  undefined *puVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  if (pvVar1 == (id)0x0) {
    pvVar1 = contextInfo;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar2 = _objc_msgSend(self,sel_undoManager);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
  }
  _objc_msgSend(pvVar2,sel_enableUndoRegistration);
  puVar7 = &DAT_0038297c;
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0038297c);
  pvVar2 = _objc_msgSend(pvVar2,sel_borderPath);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(drawPaneDidDone,sel_objectAssistantNavigationController,puVar7);
    uVar9 = 1;
    uVar8 = 0;
    pvVar1 = (id)0x0;
    pHVar6 = self;
    _objc_msgSend(pvVar2,sel_pushViewController_withIdentifier_animate_replacePrevious_,self,0,0,1);
    if (self->_paneState != self->_storedPaneState) {
      _objc_msgSend(self->_paneState,sel_release,pHVar6,pvVar1,uVar8,uVar9);
      pHVar3 = _objc_msgSend(self->_storedPaneState,sel_copy);
      self->_paneState = pHVar3;
    }
    _objc_msgSend(self,sel_applyPaneStateToButtonObject,pHVar6,pvVar1,uVar8,uVar9);
    pvVar2 = self->_buttonTypeMatrix;
    pvVar4 = _objc_msgSend(self->_paneState,sel_buttonType);
    pvVar4 = _objc_msgSend(self,sel_tagForButtonType_,pvVar4);
    _objc_msgSend(pvVar2,sel_selectCellWithTag_,pvVar4);
    pcVar5 = _objc_msgSend(self->_paneState,sel_buttonType);
    _objc_msgSend(self,sel_setInformativeTextForCoachingKey_,pcVar5);
    pHVar6 = self;
    op = sel_restoreSizeOfInvisibleButton;
  }
  else {
    pHVar6 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,puVar7);
    pcVar5 = &cfstr_HSButtonObjectAssistantPaneDidDoneNotification;
    op = sel_postNotificationName_object_;
  }
  _objc_msgSend(pHVar6,op,pcVar5,pvVar1);
  _objc_msgSend(self,sel_autorelease);
  return;
}

*/
- (void)drawPaneDidDone:(id)aDone contextInfo:(void *)aInfo
{
    id assistant = [self assistant];
    if (assistant == nil) {
        assistant = (id)aInfo;
    }
    id object = [assistant object];
    id undoManager = [self undoManager];
    if (undoManager == nil) {
        undoManager = [[object stack] undoManager];
    }
    [undoManager enableUndoRegistration];
    if ([[object queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] borderPath] == nil) {
        [[aDone objectAssistantNavigationController] pushViewController:self withIdentifier:nil animate:NO replacePrevious:YES];
        if (_paneState != _storedPaneState) {
            [_paneState release];
            _paneState = [_storedPaneState copy];
        }
        [self applyPaneStateToButtonObject];
        [_buttonTypeMatrix selectCellWithTag:[self tagForButtonType:[_paneState buttonType]]];
        [self setInformativeTextForCoachingKey:[_paneState buttonType]];
        [self restoreSizeOfInvisibleButton];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSButtonObjectAssistantPaneDidDoneNotification" object:object];
    }
    [self autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020c5af @ 0020c5af, 276 bytes * /

void FUN_0020c5af(HSButtonTypeAssistantPane *self,SEL _cmd)

{
  NSSize *pNVar1;
  float fVar2;
  undefined *puVar3;
  char cVar4;
  id pvVar5;
  NSSize NVar6;
  
  pvVar5 = _objc_msgSend(self,sel_undoManager);
  _objc_msgSend(pvVar5,sel_disableUndoRegistration);
  puVar3 = PTR_00336078;
  NVar6 = (self->_storedInvisibleButtonBounds).size;
  cVar4 = _NSEqualRects((self->_storedInvisibleButtonBounds).origin,NVar6,
                        *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8));
  if (cVar4 == '\0') {
    pvVar5 = _objc_msgSend(self,sel_shapeBackgroundInterface);
    pNVar1 = &(self->_storedInvisibleButtonBounds).size;
    NVar6 = *pNVar1;
    _objc_msgSend(pvVar5,sel_setSize_,pNVar1->width,(self->_storedInvisibleButtonBounds).size.height
                 );
  }
  fVar2 = *(float *)(puVar3 + 4);
  (self->_storedInvisibleButtonBounds).origin.x = *(float *)puVar3;
  (self->_storedInvisibleButtonBounds).origin.y = fVar2;
  (self->_storedInvisibleButtonBounds).size.width = *(float *)(puVar3 + 8);
  (self->_storedInvisibleButtonBounds).size.height = *(float *)(puVar3 + 0xc);
  pvVar5 = _objc_msgSend(self,sel_undoManager,NVar6);
  _objc_msgSend(pvVar5,sel_enableUndoRegistration);
  return;
}

*/
- (void)restoreSizeOfInvisibleButton
{
    [[self undoManager] disableUndoRegistration];
    if (!NSEqualRects(_storedInvisibleButtonBounds, NSZeroRect)) {
        [[self shapeBackgroundInterface] setSize:_storedInvisibleButtonBounds.size];
    }
    _storedInvisibleButtonBounds = NSZeroRect;
    [[self undoManager] enableUndoRegistration];
}

- (void)assistDrawShapeBackground
{
    NSUInteger pvVar1_3;
    id pvVar2_2;

    [[self undoManager] disableUndoRegistration];
    pvVar1_3 = [self toolTagForShapeButtonType:[_paneState buttonType]];
    pvVar2_2 = [HSDrawButtonShapeAssistantPane paneWithCoachingKey:[HSToolManager toolIdentifierForTag:pvVar1_3]];
    [pvVar2_2 setPaneState:_paneState];
    [pvVar2_2 setToolTag:pvVar1_3];
    [pvVar2_2 setDidDoneDelegate:self didDoneSelector:@selector(drawPaneDidDone:contextInfo:) contextInfo:(void *)[self assistant]];
    [self retain];
    [[self shapeBackgroundInterface] setBorderPath:nil];
    [[self objectAssistantNavigationController] pushViewController:pvVar2_2 withIdentifier:nil animate:NO replacePrevious:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020c869 @ 0020c869, 303 bytes * /

void FUN_0020c869(HSButtonTypeAssistantPane *self,SEL _cmd,id paneDidOK)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar2 = _objc_msgSend(self->_paneState,sel_backgroundStyle);
  pcVar3 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self->_paneState,sel_buttonType,pcVar3);
    pcVar3 = &cfstr_HSInvisibleShapeButtonType;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSInvisibleShapeButtonType);
    op = sel_assistDrawShapeBackground;
    if ((char)pvVar2 == '\0') goto LAB_0020c98b;
  }
  _objc_msgSend(self,sel_applyPaneStateToButtonObject,pcVar3);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_postNotificationName_object_,
                &cfstr_HSButtonObjectAssistantPaneDidDoneNotification,pvVar1);
  pcVar3 = (cfstringStruct *)0x1;
  op = sel_dismiss_slide_;
LAB_0020c98b:
  _objc_msgSend(self,op,pcVar3);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    id object = [[self assistant] object];
    if ([[_paneState backgroundStyle] isEqual:@"HSButtonObjectSystemBackgroundStyle"] || [[_paneState buttonType] isEqual:@"HSInvisibleShapeButtonType"]) {
        [self applyPaneStateToButtonObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSButtonObjectAssistantPaneDidDoneNotification" object:object];
        [self dismiss:YES slide:NO];
    } else {
        [self assistDrawShapeBackground];
    }
}

- (void)paneDidCancel:(id)aCancel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSButtonObjectAssistantPaneDidCancelNotification" object:[[self assistant] object]];
}

- (void)applyShapeBackgroundStyleWithButtonType
{
    id pvVar2;
    BOOL pvVar1_2;
    id pvVar1_4;
    id pvVar1_5;

    pvVar1_2 = [[_paneState buttonType] isEqualToString:@"HSInvisibleShapeButtonType"];
    pvVar2 = [self currentButtonBorderPath];
    [[self buttonObjectInterface] setBackgroundStyle:@"HSButtonObjectShapeBackgroundStyle" needsResetRotationAngle:(unsigned int)(!pvVar1_2)];
    [[self shapeBackgroundInterface] setShapeButtonType:[_paneState buttonType]];
    pvVar1_4 = [self systemBackgroundInterface];
    [pvVar1_4 setSystemButtonType:nil];
    pvVar1_5 = [self shapeBackgroundInterface];
    if (pvVar2 == nil) {
        pvVar2 = [self defaultButtonBorderPath];
    }
    [pvVar1_5 setBorderPath:pvVar2];
    [[self buttonObjectInterface] setContentOverlapsBackground:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020cba0 @ 0020cba0, 561 bytes * /

void FUN_0020cba0(HSButtonTypeAssistantPane *self,SEL _cmd)

{
  undefined8 uVar1;
  HSButtonObjectAssistantPaneState *pHVar2;
  undefined *puVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  undefined8 *puVar7;
  undefined4 local_50;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  puVar3 = PTR_00336078;
  puVar7 = (undefined8 *)&stack0xffffffb4;
  local_24 = *(undefined4 *)PTR_00336078;
  uStack_20 = *(undefined4 *)(PTR_00336078 + 4);
  local_1c = *(undefined4 *)(PTR_00336078 + 8);
  uStack_18 = *(undefined4 *)(PTR_00336078 + 0xc);
  local_50 = 0x20cbf1;
  pvVar5 = _objc_msgSend(self,sel_shapeBackgroundInterface);
  local_50 = 0x20cc03;
  pvVar5 = _objc_msgSend(pvVar5,sel_shapeButtonType);
  local_50 = 0x20cc1f;
  pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_);
  if ((char)pvVar5 != '\0') {
    local_50 = 0x20cc38;
    pvVar5 = _objc_msgSend(self,sel_assistant);
    local_50 = 0x20cc4a;
    pvVar5 = _objc_msgSend(pvVar5,sel_object);
    local_50 = 0x20cc66;
    pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_);
    local_50 = 0x20cc7f;
    _objc_msgSend_stret(&local_24,pvVar5,sel_boundingRect);
    puVar7 = (undefined8 *)&local_50;
  }
  *(undefined **)((int)puVar7 + 4) = sel_buttonObjectInterface;
  *(HSButtonTypeAssistantPane **)puVar7 = self;
  *(undefined4 *)((int)puVar7 + -4) = 0x20cc97;
  pvVar5 = _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(cfstringStruct **)(puVar7 + 1) = &cfstr_HSButtonObjectSystemBackgroundStyle;
  *(undefined **)((int)puVar7 + 4) = sel_setBackgroundStyle_;
  *(id *)puVar7 = pvVar5;
  *(undefined4 *)((int)puVar7 + -4) = 0x20ccb3;
  _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(undefined **)((int)puVar7 + 4) = sel_systemBackgroundInterface;
  *(HSButtonTypeAssistantPane **)puVar7 = self;
  *(undefined4 *)((int)puVar7 + -4) = 0x20ccc8;
  pvVar5 = _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  pHVar2 = self->_paneState;
  *(undefined **)((int)puVar7 + 4) = sel_buttonType;
  *(HSButtonObjectAssistantPaneState **)puVar7 = pHVar2;
  *(undefined4 *)((int)puVar7 + -4) = 0x20cce5;
  pvVar6 = _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(id *)(puVar7 + 1) = pvVar6;
  *(undefined **)((int)puVar7 + 4) = sel_setSystemButtonType_;
  *(id *)puVar7 = pvVar5;
  *(undefined4 *)((int)puVar7 + -4) = 0x20ccfb;
  _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(undefined **)((int)puVar7 + 4) = sel_shapeBackgroundInterface;
  *(HSButtonTypeAssistantPane **)puVar7 = self;
  *(undefined4 *)((int)puVar7 + -4) = 0x20cd10;
  pvVar5 = _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(undefined **)((int)puVar7 + 4) = sel_setShapeButtonType_;
  *(id *)puVar7 = pvVar5;
  *(undefined4 *)(puVar7 + 1) = 0;
  *(undefined4 *)((int)puVar7 + -4) = 0x20cd2a;
  _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(undefined **)((int)puVar7 + 4) = sel_buttonObjectInterface;
  *(HSButtonTypeAssistantPane **)puVar7 = self;
  *(undefined4 *)((int)puVar7 + -4) = 0x20cd3f;
  pvVar5 = _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  *(undefined **)((int)puVar7 + 4) = sel_setContentOverlapsBackground_;
  *(id *)puVar7 = pvVar5;
  *(undefined4 *)(puVar7 + 1) = 0;
  *(undefined4 *)((int)puVar7 + -4) = 0x20cd59;
  _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  uVar1 = *(undefined8 *)puVar3;
  puVar7[3] = *(undefined8 *)(puVar3 + 8);
  puVar7[2] = uVar1;
  puVar7[1] = CONCAT44(uStack_18,local_1c);
  *puVar7 = CONCAT44(uStack_20,local_24);
  *(undefined4 *)((int)puVar7 + -4) = 0x20cd88;
  cVar4 = _NSEqualRects();
  if (cVar4 == '\0') {
    *(undefined **)((int)puVar7 + 4) = sel_systemBackgroundInterface;
    *(HSButtonTypeAssistantPane **)puVar7 = self;
    *(undefined4 *)((int)puVar7 + -4) = 0x20cda1;
    pvVar5 = _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
    *(undefined4 *)((int)puVar7 + 0xc) = uStack_18;
    *(undefined4 *)(puVar7 + 1) = local_1c;
    *(undefined **)((int)puVar7 + 4) = sel_setSize_;
    *(id *)puVar7 = pvVar5;
    *(undefined4 *)((int)puVar7 + -4) = 0x20cdc9;
    _objc_msgSend(*(id *)puVar7,*(SEL *)((int)puVar7 + 4));
  }
  return;
}

*/
- (void)applySystemBackgroundStyleWithButtonType
{
    NSRect bounds = NSZeroRect;
    if ([[[self shapeBackgroundInterface] shapeButtonType] isEqualToString:@"HSInvisibleShapeButtonType"]) {
        bounds = [[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
    }
    [[self buttonObjectInterface] setBackgroundStyle:@"HSButtonObjectSystemBackgroundStyle"];
    [[self systemBackgroundInterface] setSystemButtonType:[_paneState buttonType]];
    [[self shapeBackgroundInterface] setShapeButtonType:nil];
    [[self buttonObjectInterface] setContentOverlapsBackground:NO];
    if (!NSEqualRects(bounds, NSZeroRect)) {
        [[self systemBackgroundInterface] setSize:bounds.size];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020cdd1 @ 0020cdd1, 374 bytes * /

void FUN_0020cdd1(HSButtonTypeAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  _objc_msgSend(pvVar1,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self->_paneState,sel_backgroundStyle);
  pcVar3 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  op = sel_applySystemBackgroundStyleWithButtonType;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_paneState,sel_backgroundStyle,pcVar3);
    pcVar3 = &cfstr_HSButtonObjectShapeBackgroundStyle;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSButtonObjectShapeBackgroundStyle);
    op = sel_applyShapeBackgroundStyleWithButtonType;
    if ((char)pvVar1 == '\0') goto LAB_0020ce91;
  }
  _objc_msgSend(self,op,pcVar3);
LAB_0020ce91:
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface,pcVar3);
  pvVar2 = _objc_msgSend(self->_paneState,sel_titleVisible);
  _objc_msgSend(pvVar1,sel_setTitleVisible_,(int)(char)pvVar2);
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(self->_paneState,sel_highlight);
  _objc_msgSend(pvVar1,sel_setHasHighlight_,(int)(char)pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  _objc_msgSend(pvVar1,sel_enableUndoRegistration);
  return;
}

*/
- (void)applyPaneStateToButtonObject
{
    [[self undoManager] disableUndoRegistration];
    if ([[_paneState backgroundStyle] isEqual:@"HSButtonObjectSystemBackgroundStyle"]) {
        [self applySystemBackgroundStyleWithButtonType];
    } else if ([[_paneState backgroundStyle] isEqual:@"HSButtonObjectShapeBackgroundStyle"]) {
        [self applyShapeBackgroundStyleWithButtonType];
    }
    [[self buttonObjectInterface] setTitleVisible:[_paneState titleVisible]];
    [[self buttonObjectInterface] setHasHighlight:[_paneState highlight]];
    [[self undoManager] enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020cf47 @ 0020cf47, 68 bytes * /

void FUN_0020cf47(HSButtonTypeAssistantPane *self,SEL _cmd,int selectToolWithTag)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(self_00,sel_selectToolWithTag_,selectToolWithTag);
  return;
}

*/
- (void)selectToolWithTag:(NSInteger)aTag
{
    [[HSToolManager sharedToolManager] selectToolWithTag:aTag];
}

- (NSUInteger)toolTagForShapeButtonType:(id)aType
{
    unsigned int uVar2;
    BOOL pvVar1_3;

    if (![aType isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
        if (![aType isEqualToString:@"HSLassoAreaShapeButtonType"]) {
            pvVar1_3 = [aType isEqualToString:@"HSExpandingAreaShapeButtonType"];
            uVar2 = 0x3d;
            if (!pvVar1_3) {
                uVar2 = 0;
            }
        }
        else {
            uVar2 = 0x3c;
        }
    }
    else {
        uVar2 = 0x3b;
    }
    return uVar2;
}

- (NSInteger)tagForButtonType:(id)aType
{
    int iVar2;

    if (![aType isEqualToString:@"HSRegularSystemButtonType"]) {
        if (![aType isEqualToString:@"HSDefaultSystemButtonType"]) {
            if (![aType isEqualToString:@"HSRectangleSystemButtonType"]) {
                if (![aType isEqualToString:@"HSDropShadowRectangleSystemButtonType"]) {
                    if (![aType isEqualToString:@"HSInvisibleShapeButtonType"]) {
                        if (![aType isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
                            if (![aType isEqualToString:@"HSExpandingAreaShapeButtonType"]) {
                                iVar2 = (unsigned int)([aType isEqualToString:@"HSLassoAreaShapeButtonType"]) << 3;
                            }
                            else {
                                iVar2 = 7;
                            }
                        }
                        else {
                            iVar2 = 6;
                        }
                    }
                    else {
                        iVar2 = 5;
                    }
                }
                else {
                    iVar2 = 4;
                }
            }
            else {
                iVar2 = 3;
            }
        }
        else {
            iVar2 = 2;
        }
    }
    else {
        iVar2 = 1;
    }
    return iVar2;
}

- (id)systemBackgroundInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020d1cb @ 0020d1cb, 302 bytes * /

void FUN_0020d1cb(HSButtonTypeAssistantPane *self,SEL _cmd)

{
  HSButtonObjectAssistantPaneState *pHVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  if (self->_storedPaneState != self->_paneState) {
    _objc_msgSend(self->_storedPaneState,sel_release);
    pHVar1 = _objc_msgSend(self->_paneState,sel_copy);
    self->_storedPaneState = pHVar1;
  }
  pvVar2 = _objc_msgSend(self,sel_shapeBackgroundInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_shapeButtonType);
  pcVar3 = &cfstr_HSInvisibleShapeButtonType;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_HSInvisibleShapeButtonType);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_assistant,pcVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00382aa8);
    _objc_msgSend_stret(&local_1c,pvVar2,sel_boundingRect);
    (self->_storedInvisibleButtonBounds).origin.x = local_1c;
    (self->_storedInvisibleButtonBounds).origin.y = local_18;
    (self->_storedInvisibleButtonBounds).size.width = local_14;
    (self->_storedInvisibleButtonBounds).size.height = local_10;
  }
  return;
}

*/
- (void)storePreviousState
{
    if (_storedPaneState != _paneState) {
        [_storedPaneState release];
        _storedPaneState = [_paneState copy];
    }
    if ([[[self shapeBackgroundInterface] shapeButtonType] isEqualToString:@"HSInvisibleShapeButtonType"]) {
        _storedInvisibleButtonBounds = [[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
    }
}

- (void)lassoAreaShapeButtonTypeChosen:(id)aChosen
{
    [self storePreviousState];
    [_paneState setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSLassoAreaShapeButtonType"];
    [_paneState setTitleVisible:NO];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSLassoAreaShapeButtonType"];
    [self assistDrawShapeBackground];
}

- (void)expandingAreaShapeButtonTypeChosen:(id)aChosen
{
    [self storePreviousState];
    [_paneState setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSExpandingAreaShapeButtonType"];
    [_paneState setTitleVisible:NO];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSExpandingAreaShapeButtonType"];
    [self assistDrawShapeBackground];
}

- (void)freehandAreaButtonTypeChosen:(id)aChosen
{
    [self storePreviousState];
    [_paneState setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSFreehandAreaShapeButtonType"];
    [_paneState setTitleVisible:NO];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSFreehandAreaShapeButtonType"];
    [self assistDrawShapeBackground];
}

- (void)invisibleShapeButtonTypeChosen:(id)aChosen
{
    [_paneState setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSInvisibleShapeButtonType"];
    [_paneState setTitleVisible:NO];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSInvisibleShapeButtonType"];
    [self applyPaneStateToButtonObject];
}

- (void)dropShadowRectangleSystemButtonTypeChosen:(id)aChosen
{
    [_paneState setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSDropShadowRectangleSystemButtonType"];
    [_paneState setTitleVisible:YES];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSDropShadowRectangleSystemButtonType"];
    [self applyPaneStateToButtonObject];
}

- (void)rectangleSystemButtonTypeChosen:(id)aChosen
{
    [_paneState setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSRectangleSystemButtonType"];
    [_paneState setTitleVisible:YES];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSRectangleSystemButtonType"];
    [self applyPaneStateToButtonObject];
}

- (void)defaultSystemButtonTypeChosen:(id)aChosen
{
    [_paneState setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSDefaultSystemButtonType"];
    [_paneState setTitleVisible:YES];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSDefaultSystemButtonType"];
    [self applyPaneStateToButtonObject];
}

- (void)regularSystemButtonTypeChosen:(id)aChosen
{
    [_paneState setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSRegularSystemButtonType"];
    [_paneState setTitleVisible:YES];
    [_paneState setHighlight:YES];
    [self setInformativeTextForCoachingKey:@"HSRegularSystemButtonType"];
    [self applyPaneStateToButtonObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020d8cf @ 0020d8cf, 351 bytes * /

void FUN_0020d8cf(HSButtonTypeAssistantPane *self,SEL _cmd,id setInformativeTextForCoachingKey)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  
  pvVar1 = _objc_msgSend(cls_HSCoachingInfoProvider,sel_sharedProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_coachingInfoForKey_,setInformativeTextForCoachingKey);
  pvVar2 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
  self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_informativeTextFilename);
  pvVar1 = _objc_msgSend(self_00,sel_pathForResource_ofType_inDirectory_,pvVar1,&cfstr_rtf,
                         &cfstr_Coaching);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithPath_documentAttributes_,pvVar1,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar2 = _objc_msgSend(pvVar2,sel_coachingHintDefaultButton);
  _objc_msgSend(pvVar1,sel_replaceOccurencesOfString_withString_,*(undefined4 *)PTR_PTR_003366fc,
                pvVar2);
  _objc_msgSend(self,sel_setInformativeText_,pvVar1);
  return;
}

*/
- (void)setInformativeTextForCoachingKey:(id)aKey
{
    id info = [[HSCoachingInfoProvider sharedProvider] coachingInfoForKey:aKey];
    NSString *path = [[NSBundle mainBundle] pathForResource:[info objectForKey:@"informativeTextFilename"] ofType:@"rtf" inDirectory:@"Coaching"];
    NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithPath:path documentAttributes:NULL] autorelease];
    [text replaceOccurencesOfString:@"<defaultButtonName>" withString:[[HSObjectAssistantController sharedAssistantController] coachingHintDefaultButton]];
    [self setInformativeText:text];
}

- (id)shapeBackgroundInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
}

- (id)buttonObjectInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
}

- (id)undoManager
{
    return [[self stack] undoManager];
}

- (void)viewDidLoad
{
    HSButtonObjectAssistantPaneState *self_00;

    [super viewDidLoad];
    self_00 = [[HSButtonObjectAssistantPaneState alloc] init];
    _paneState = self_00;
    [self_00 setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSDefaultSystemButtonType"];
    [_paneState setTitleVisible:YES];
    [_paneState setHighlight:YES];
    [_buttonTypeMatrix selectCellWithTag:[self tagForButtonType:@"HSDefaultSystemButtonType"]];
    [self setInformativeTextForCoachingKey:@"HSDefaultSystemButtonType"];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSObjectAssistantNavigationPaneSwitcher alloc] initWithNibName:@"NewButtonTypePaneSwitcher"];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (void)dealloc
{
    [_paneState release];
    [_storedPaneState release];
    [_navigationPaneSwitcher setDelegate:0];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"NewButtonTypeAssistantPane"];
    if (self != nil) {
        [self setCoachingKey:@"NewButtonTypeCoachingHintsKey"];
    }
    return self;
}

- (id)cardGroupController
{
    return nil;
}

- (id)delegate
{
    return nil;
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}

- (id)scriptController
{
    return nil;
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[self object] setSupport:self];
}

@end

