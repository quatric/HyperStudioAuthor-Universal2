#import "HSFrameResizeSelectionTracker.h"

@implementation HSFrameResizeSelectionTracker

/* i386 ivar offsets: _startSize=0x30, _startAffineTransform=0x38, _untransformedStartPoint=0x50, _deltaFactor=0x58, _resizingCenterPositionFactor=0x60, _modifyingEdges=0x68, _aspectRatioMaintainingRule=0x6c, _aspectRatioMaintainingRequest=0x70, _invertsProportionalResizePreferences=0x74, _resizesAboutCenter=0x74, _isCrop=0x74 */

+ (id)alternateProportionsTrackerWithModifyingEdges:(NSInteger)aEdges
{
    return [[[self alloc] initWithModifyingEdges:aEdges invertsProportionalResizePreferences:YES] autorelease];
}

+ (id)trackerWithModifyingEdges:(NSInteger)aEdges
{
    return [[[self alloc] initWithModifyingEdges:aEdges invertsProportionalResizePreferences:NO] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a2f8 @ 0003a2f8, 620 bytes * /

void FUN_0003a2f8(HSFrameResizeSelectionTracker *self,SEL _cmd,id mouseUp,id inView)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  id pvVar6;
  undefined4 extraout_EDX;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  HSFrameResizeSelectionTracker *local_1c;
  undefined *local_18;
  
  _objc_msgSend(self,sel_mouseEvent_inView_,mouseUp,inView);
  pvVar4 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar5 = _objc_msgSend(pvVar4,sel_size);
  _objc_msgSend_stret(&local_34,pvVar4,sel_affineTransform);
  self_00 = _objc_msgSend(self,sel_mutableGeometryAttributes);
  uVar1._0_4_ = (self->_startAffineTransform).tx;
  uVar1._4_4_ = (self->_startAffineTransform).ty;
  uVar2._0_4_ = (self->_startAffineTransform).a;
  uVar2._4_4_ = (self->_startAffineTransform).b;
  uVar3._0_4_ = (self->_startAffineTransform).c;
  uVar3._4_4_ = (self->_startAffineTransform).d;
  _objc_msgSend(self_00,sel_setSize_affineTransform_,(self->_startSize).width,
                (self->_startSize).height,uVar2,uVar3,uVar1);
  pvVar6 = _objc_msgSend(self,sel_trackingObject);
  pvVar6 = _objc_msgSend(pvVar6,sel_hyperObject);
  pvVar6 = _objc_msgSend(pvVar6,sel_undoManager);
  _objc_msgSend(pvVar6,sel_enableUndoRegistration);
  _objc_msgSend(self_00,sel_setSize_affineTransform_,pvVar5,extraout_EDX,local_34,local_2c,local_24)
  ;
  pvVar4 = _objc_msgSend(pvVar4,sel_attributeObservingController);
  pvVar5 = _objc_msgSend(cls_NSEProtocolSet,sel_protocolSetWithProtocols_,&DAT_00362a00,
                         &DAT_003629d8,&DAT_003629c4,&DAT_0036299c,&DAT_00362988,&DAT_003628e8,0);
  _objc_msgSend(pvVar4,sel_endContinuousChangeOfAttributeSet_,pvVar5);
  local_1c = self;
  local_18 = PTR_s_HSSelectionKnobTracker_0034dc60;
  _objc_msgSendSuper(&local_1c,sel_mouseUp_inView_,mouseUp,inView);
  pvVar4 = _objc_msgSend(self,sel_layoutGuidingContext);
  if (pvVar4 != (id)0x0) {
    pvVar4 = _objc_msgSend(self,sel_layoutGuidingContext);
    _objc_msgSend(pvVar4,sel_hideInfoTag);
  }
  return;
}

*/
- (void)mouseUp:(id)aUp inView:(id)aView
{
    [self mouseEvent:aUp inView:aView];
    id geometry = [self geometryAttributes];
    NSSize size = [(id<HSSizeAttributes>)geometry size];
    CGAffineTransform transform = [geometry affineTransform];
    /* Replay the whole change from the start state with undo registration on. */
    id mutableGeometry = [self mutableGeometryAttributes];
    [mutableGeometry setSize:_startSize affineTransform:_startAffineTransform];
    [[[[self trackingObject] hyperObject] undoManager] enableUndoRegistration];
    [mutableGeometry setSize:size affineTransform:transform];
    [[geometry attributeObservingController] endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil]];
    [super mouseUp:aUp inView:aView];
    if ([self layoutGuidingContext] != nil) {
        [[self layoutGuidingContext] hideInfoTag];
    }
}

- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    [self mouseEvent:aDragged inView:aView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a5ca @ 0003a5ca, 772 bytes * /

void FUN_0003a5ca(HSFrameResizeSelectionTracker *self,SEL _cmd,id processMouseDown,id inView)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  undefined4 extraout_EDX_02;
  undefined4 uVar4;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  HSFrameResizeSelectionTracker *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_trackingObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_disableUndoRegistration);
  local_1c = self;
  local_18 = PTR_s_HSSelectionKnobTracker_0034dc60;
  _objc_msgSendSuper(&local_1c,sel_processMouseDown_inView_,processMouseDown,inView);
  pvVar1 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar2 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  pvVar3 = _objc_msgSend(cls_NSEProtocolSet,sel_protocolSetWithProtocols_,&DAT_00362a00,
                         &DAT_003629d8,&DAT_003629c4,&DAT_0036299c,&DAT_00362988,&DAT_003628e8,0);
  _objc_msgSend(pvVar2,sel_beginContinuousChangeOfAttributeSet_,pvVar3);
  pvVar2 = _objc_msgSend(pvVar1,sel_size);
  (self->_startSize).width = (float)pvVar2;
  (self->_startSize).height = extraout_EDX;
  _objc_msgSend_stret(&local_34,pvVar1,sel_affineTransform);
  (self->_startAffineTransform).a = local_34;
  (self->_startAffineTransform).b = local_30;
  (self->_startAffineTransform).c = local_2c;
  (self->_startAffineTransform).d = local_28;
  (self->_startAffineTransform).tx = local_24;
  (self->_startAffineTransform).ty = local_20;
  pvVar2 = _objc_msgSend(self,sel_inverseStartTransform);
  pvVar3 = _objc_msgSend(self,sel_startPoint);
  uVar4 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(pvVar2,sel_transformPoint_,pvVar3,extraout_EDX_00);
  (self->_untransformedStartPoint).x = (float)pvVar2;
  (self->_untransformedStartPoint).y = extraout_EDX_01;
  pvVar2 = _objc_msgSend(pvVar1,sel_isFlippedHorizontally);
  if ((char)pvVar2 != '\0') {
    (self->_untransformedStartPoint).x =
         (self->_startSize).width - (self->_untransformedStartPoint).x;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_isFlippedVertically,pvVar3,uVar4);
  if ((char)pvVar2 != '\0') {
    (self->_untransformedStartPoint).y =
         (self->_startSize).height - (self->_untransformedStartPoint).y;
  }
  pvVar2 = _objc_msgSend(processMouseDown,sel_modifierFlags);
  self->_invertsProportionalResizePreferences[0] =
       (byte)((uint)pvVar2 >> 0x12) & 2 | self->_invertsProportionalResizePreferences[0] & 0xfd;
  pvVar3 = _objc_msgSend(self,sel_isCropForModifierFlags_,pvVar2);
  self->_invertsProportionalResizePreferences[0] =
       self->_invertsProportionalResizePreferences[0] & 0xfb | ((byte)pvVar3 & 1) << 2;
  pvVar3 = _objc_msgSend(self,sel_aspectRatioMaintainingRequestForModifierFlags_,pvVar2);
  self->_aspectRatioMaintainingRequest = (int)pvVar3;
  pvVar3 = _objc_msgSend(self,sel_layoutGuidingContext);
  if (pvVar3 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_layoutGuidingContext,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_affineFrameSize);
    _objc_msgSend(pvVar2,sel_showInfoTagWithSize_,pvVar1,extraout_EDX_02);
  }
  return;
}

*/
- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [[[[self trackingObject] hyperObject] undoManager] disableUndoRegistration];
    [super processMouseDown:aDown inView:aView];
    id geometry = [self geometryAttributes];
    [[geometry attributeObservingController] beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil]];
    _startSize = [(id<HSSizeAttributes>)geometry size];
    _startAffineTransform = [geometry affineTransform];
    _untransformedStartPoint = [[self inverseStartTransform] transformPoint:[self startPoint]];
    if ([geometry isFlippedHorizontally]) {
        _untransformedStartPoint.x = _startSize.width - _untransformedStartPoint.x;
    }
    if ([geometry isFlippedVertically]) {
        _untransformedStartPoint.y = _startSize.height - _untransformedStartPoint.y;
    }
    NSUInteger flags = [aDown modifierFlags];
    _resizesAboutCenter = (flags & NSEventModifierFlagOption) != 0;
    _isCrop = [self isCropForModifierFlags:flags];
    _aspectRatioMaintainingRequest = (int)[self aspectRatioMaintainingRequestForModifierFlags:flags];
    if ([self layoutGuidingContext] != nil) {
        [[self layoutGuidingContext] showInfoTagWithSize:[geometry affineFrameSize]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a8ce @ 0003a8ce, 322 bytes * /

void FUN_0003a8ce(HSFrameResizeSelectionTracker *self,SEL _cmd,id flagsChanged,id inView)

{
  byte bVar1;
  byte bVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar3 = _objc_msgSend(flagsChanged,sel_modifierFlags);
  bVar1 = self->_invertsProportionalResizePreferences[0];
  pvVar6 = (id)self->_aspectRatioMaintainingRequest;
  self->_invertsProportionalResizePreferences[0] = (byte)((uint)pvVar3 >> 0x12) & 2 | bVar1 & 0xfd;
  pvVar4 = _objc_msgSend(self,sel_isCropForModifierFlags_,pvVar3);
  self->_invertsProportionalResizePreferences[0] =
       self->_invertsProportionalResizePreferences[0] & 0xfb | ((byte)pvVar4 & 1) << 2;
  pvVar4 = pvVar3;
  pvVar5 = _objc_msgSend(self,sel_aspectRatioMaintainingRequestForModifierFlags_,pvVar3);
  self->_aspectRatioMaintainingRequest = (int)pvVar5;
  bVar2 = self->_invertsProportionalResizePreferences[0];
  if ((((bVar2 & 2) == 0) || ((bVar1 & 2) != 0)) && (((bVar2 & 2) != 0 || ((bVar1 & 2) == 0)))) {
    if (((((bVar2 & 4) == 0) || ((bVar1 & 4) != 0)) && ((bVar2 & 4) != 0 || (bVar1 & 4) == 0)) &&
       (pvVar5 == pvVar6)) {
      return;
    }
  }
  pvVar6 = _objc_msgSend(inView,sel_window,pvVar4);
  pvVar6 = _objc_msgSend(pvVar6,sel_BT_effectiveMouseLocation);
  pvVar6 = _objc_msgSend(inView,sel_convertPoint_fromView_,pvVar6,extraout_EDX,0);
  _objc_msgSend(self,sel_HSFrameResizeSelectionTracker_processWithLocation_modifierFlags_inView_,
                pvVar6,extraout_EDX_00,pvVar3,inView);
  return;
}

*/
- (void)flagsChanged:(id)aChanged inView:(id)aView
{
    NSUInteger flags = [aChanged modifierFlags];
    BOOL wasResizingAboutCenter = _resizesAboutCenter;
    BOOL wasCrop = _isCrop;
    int oldRequest = _aspectRatioMaintainingRequest;
    _resizesAboutCenter = (flags & NSEventModifierFlagOption) != 0;
    _isCrop = [self isCropForModifierFlags:flags];
    _aspectRatioMaintainingRequest = (int)[self aspectRatioMaintainingRequestForModifierFlags:flags];
    if (_resizesAboutCenter == wasResizingAboutCenter && _isCrop == wasCrop && _aspectRatioMaintainingRequest == oldRequest) {
        return;
    }
    NSPoint location = [aView convertPoint:[[aView window] BT_effectiveMouseLocation] fromView:nil];
    [self HSFrameResizeSelectionTracker_processWithLocation:location modifierFlags:flags inView:aView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003aa10 @ 0003aa10, 282 bytes * /

void FUN_0003aa10(HSFrameResizeSelectionTracker *self,SEL _cmd,id mouseEvent,id inView)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  HSFrameResizeSelectionTracker *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(mouseEvent,sel_modifierFlags);
  self->_invertsProportionalResizePreferences[0] =
       (byte)((uint)pvVar1 >> 0x12) & 2 | self->_invertsProportionalResizePreferences[0] & 0xfd;
  pvVar2 = _objc_msgSend(self,sel_isCropForModifierFlags_,pvVar1);
  self->_invertsProportionalResizePreferences[0] =
       self->_invertsProportionalResizePreferences[0] & 0xfb | ((byte)pvVar2 & 1) << 2;
  pvVar2 = _objc_msgSend(self,sel_aspectRatioMaintainingRequestForModifierFlags_,pvVar1);
  self->_aspectRatioMaintainingRequest = (int)pvVar2;
  local_1c = self;
  local_18 = PTR_s_HSSelectionKnobTracker_0034dc60;
  _objc_msgSendSuper(&local_1c,sel_mouseEvent_inView_,mouseEvent,inView);
  pvVar2 = _objc_msgSend(mouseEvent,sel_locationInWindow);
  pvVar2 = _objc_msgSend(inView,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  _objc_msgSend(self,sel_HSFrameResizeSelectionTracker_processWithLocation_modifierFlags_inView_,
                pvVar2,extraout_EDX_00,pvVar1,inView);
  return;
}

*/
- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSUInteger flags = [aEvent modifierFlags];
    _resizesAboutCenter = (flags & NSEventModifierFlagOption) != 0;
    _isCrop = [self isCropForModifierFlags:flags];
    _aspectRatioMaintainingRequest = (int)[self aspectRatioMaintainingRequestForModifierFlags:flags];
    [super mouseEvent:aEvent inView:aView];
    NSPoint location = [aView convertPoint:[aEvent locationInWindow] fromView:nil];
    [self HSFrameResizeSelectionTracker_processWithLocation:location modifierFlags:flags inView:aView];
}

- (BOOL)isCropForEvent:(id)aEvent
{
    return (BOOL)[self isCropForModifierFlags:[aEvent modifierFlags]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003ab6e @ 0003ab6e, 258 bytes * /

BOOL FUN_0003ab6e(HSFrameResizeSelectionTracker *self,SEL _cmd,uint isCropForModifierFlags)

{
  id pvVar1;
  float extraout_EDX;
  byte bVar2;
  float fVar3;
  float fVar4;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_selectionKnob);
  puVar5 = &DAT_003628d4;
  bVar2 = (byte)(isCropForModifierFlags >> 0x14) & 1;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003628d4);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_framePositionFactor,puVar5);
    if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
      fVar3 = ABS(extraout_EDX);
    }
    else {
      fVar3 = 1.0;
    }
    fVar4 = 0.5;
    if (0.5 <= fVar3) {
      fVar4 = fVar3;
    }
    if (fVar4 * 0.0005 < ABS(extraout_EDX + -0.5)) {
      if (((float)pvVar1 != 0.0) || (NAN((float)pvVar1))) {
        fVar3 = ABS((float)pvVar1);
      }
      else {
        fVar3 = 1.0;
      }
      fVar4 = 0.5;
      if (0.5 <= fVar3) {
        fVar4 = fVar3;
      }
      if (fVar4 * 0.0005 < ABS((float)pvVar1 + -0.5)) {
        return bVar2;
      }
    }
    bVar2 = bVar2 ^ 1;
  }
  return bVar2;
}

*/
- (BOOL)isCropForModifierFlags:(NSUInteger)aFlags
{
    BOOL isCrop = (aFlags & NSEventModifierFlagCommand) != 0;
    id knob = [[self selectionKnob] queryHyperInterface:@protocol(HSFrameManipulationSelectionKnobAttributes)];
    if (knob != nil) {
        /* Edge knobs crop by default; corner knobs need Command. */
        NSSize factor = [knob framePositionFactor];
        float x = (float)factor.width;
        float y = (float)factor.height;
        BOOL isEdgeMiddle = fabsf(y + -0.5f) <= MAX(y != 0.0f ? fabsf(y) : 1.0f, 0.5f) * 0.0005f
            || fabsf(x + -0.5f) <= MAX(x != 0.0f ? fabsf(x) : 1.0f, 0.5f) * 0.0005f;
        if (isEdgeMiddle) {
            isCrop = !isCrop;
        }
    }
    return isCrop;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003ac70 @ 0003ac70, 1048 bytes * /

void FUN_0003ac70(HSFrameResizeSelectionTracker *self,SEL _cmd,
                 NSPoint HSFrameResizeSelectionTracker_processWithLocation,uint modifierFlags,
                 id inView)

{
  float fVar1;
  float fVar2;
  float fVar3;
  undefined8 uVar4;
  int iVar5;
  id self_00;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  float extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  longdouble lVar10;
  longdouble lVar11;
  uint uVar12;
  float fVar13;
  undefined8 in_stack_ffffff90;
  undefined4 uVar15;
  undefined8 uVar14;
  undefined8 uVar16;
  id local_50;
  float local_4c;
  id local_44;
  float local_40;
  id local_34;
  float local_30;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  
  uVar15 = (undefined4)((ulonglong)in_stack_ffffff90 >> 0x20);
  _objc_msgSend(self,sel_willResizeCardObject);
  self_00 = _objc_msgSend(self,sel_mutableGeometryAttributes);
  pvVar6 = _objc_msgSend(self_00,sel_isFlippedHorizontally);
  pvVar7 = _objc_msgSend(self_00,sel_isFlippedVertically);
  uVar12 = modifierFlags;
  local_50 = _objc_msgSend(self,sel_resizingCenterPositionFactorForModifierFlags_,modifierFlags);
  if ((char)pvVar6 != '\0') {
    local_50 = (id)(1.0 - (float)local_50);
  }
  local_4c = extraout_EDX;
  if ((char)pvVar7 != '\0') {
    local_4c = 1.0 - extraout_EDX;
  }
  pvVar8 = _objc_msgSend(self,sel_inverseStartTransform,uVar12);
  pvVar9 = _objc_msgSend(inView,sel_convertPointFromViewSpaceToUserSpace_,
                         HSFrameResizeSelectionTracker_processWithLocation.x,
                         HSFrameResizeSelectionTracker_processWithLocation.y);
  uVar14 = CONCAT44(uVar15,extraout_EDX_00);
  local_44 = _objc_msgSend(pvVar8,sel_transformPoint_,pvVar9,extraout_EDX_00);
  if ((char)pvVar6 != '\0') {
    local_44 = (id)((self->_startSize).width - (float)local_44);
  }
  local_40 = extraout_EDX_01;
  if ((char)pvVar7 != '\0') {
    local_40 = (self->_startSize).height - extraout_EDX_01;
  }
  fVar13 = (self->_untransformedStartPoint).y;
  fVar1 = (self->_untransformedStartPoint).x;
  pvVar6 = _objc_msgSend(self,sel_deltaFactorForModifierFlags_,modifierFlags,uVar14);
  pvVar7 = _objc_msgSend(self,sel_startTransform);
  _objc_msgSend_stret(&local_2c,pvVar7,sel_hyperCGAffineTransform);
  fVar2 = (self->_startSize).width;
  lVar10 = (longdouble)_hypotf(local_2c,local_28);
  fVar3 = (self->_startSize).height;
  lVar11 = (longdouble)_hypotf(local_24,local_20);
  local_34 = (id)(((float)pvVar6 * ((float)local_44 - fVar1) + fVar2) * (float)lVar10);
  local_30 = (extraout_EDX_02 * (local_40 - fVar13) + fVar3) * (float)lVar11;
  _objc_msgSend(self,sel_adjustSize_,&local_34);
  iVar5 = self->_aspectRatioMaintainingRequest;
  pvVar6 = _objc_msgSend(self,sel_aspectRatioMaintainingRuleForModifierFlags_,modifierFlags);
  if ((float)local_34 < 0.0) {
    local_34 = (id)0x0;
  }
  if (local_30 < 0.0) {
    local_30 = 0.0;
  }
  uVar14._0_4_ = (self->_startAffineTransform).tx;
  uVar14._4_4_ = (self->_startAffineTransform).ty;
  uVar16._0_4_ = (self->_startAffineTransform).a;
  uVar16._4_4_ = (self->_startAffineTransform).b;
  uVar4._0_4_ = (self->_startAffineTransform).c;
  uVar4._4_4_ = (self->_startAffineTransform).d;
  _objc_msgSend(self_00,sel_setSize_affineTransform_,(self->_startSize).width,
                (self->_startSize).height,uVar16,uVar4,uVar14);
  pvVar8 = _objc_msgSend(self,sel_geometryApplier);
  uVar14 = CONCAT44(local_4c,local_50);
  uVar16 = CONCAT44(iVar5,1);
  pvVar7 = local_34;
  fVar13 = local_30;
  _objc_msgSend(pvVar8,
                sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                ,local_34,local_30,local_50,local_4c,1,iVar5,pvVar6,0);
  pvVar6 = _objc_msgSend(self,sel_layoutGuidingContext);
  if (pvVar6 != (id)0x0) {
    pvVar6 = _objc_msgSend(self,sel_layoutGuidingContext,pvVar7,fVar13,uVar14,uVar16);
    _objc_msgSend(pvVar6,sel_showAppliedLayoutGuidingRules);
    pvVar6 = _objc_msgSend(self,sel_layoutGuidingContext);
    pvVar7 = _objc_msgSend(self_00,sel_affineFrameSize);
    fVar13 = extraout_EDX_03;
    _objc_msgSend(pvVar6,sel_showInfoTagWithSize_,pvVar7,extraout_EDX_03);
  }
  _objc_msgSend(self,sel_didResizeCardObject,pvVar7,fVar13,uVar14,uVar16);
  return;
}

*/
- (void)HSFrameResizeSelectionTracker_processWithLocation:(NSPoint)aLocation modifierFlags:(NSUInteger)aFlags inView:(id)aView
{
    [self willResizeCardObject];
    id geometry = [self mutableGeometryAttributes];
    BOOL isFlippedHorizontally = [geometry isFlippedHorizontally];
    BOOL isFlippedVertically = [geometry isFlippedVertically];
    NSSize center = [self resizingCenterPositionFactorForModifierFlags:aFlags];
    if (isFlippedHorizontally) {
        center.width = 1.0f - center.width;
    }
    if (isFlippedVertically) {
        center.height = 1.0f - center.height;
    }
    NSPoint point = [[self inverseStartTransform] transformPoint:[aView convertPointFromViewSpaceToUserSpace:aLocation]];
    if (isFlippedHorizontally) {
        point.x = _startSize.width - point.x;
    }
    if (isFlippedVertically) {
        point.y = _startSize.height - point.y;
    }
    NSSize delta = [self deltaFactorForModifierFlags:aFlags];
    CGAffineTransform transform = [[self startTransform] hyperCGAffineTransform];
    float scaleX = hypotf(transform.a, transform.b);
    float scaleY = hypotf(transform.c, transform.d);
    NSSize size;
    size.width = (float)((delta.width * (point.x - _untransformedStartPoint.x) + _startSize.width) * scaleX);
    size.height = (float)((delta.height * (point.y - _untransformedStartPoint.y) + _startSize.height) * scaleY);
    [self adjustSize:&size];
    NSInteger request = _aspectRatioMaintainingRequest;
    NSInteger rule = [self aspectRatioMaintainingRuleForModifierFlags:aFlags];
    if (size.width < 0) {
        size.width = 0;
    }
    if (size.height < 0) {
        size.height = 0;
    }
    [geometry setSize:_startSize affineTransform:_startAffineTransform];
    [[self geometryApplier] resizeFrameTo:size aboutRelativePoint:NSMakePoint(center.width, center.height) followResizingScalingPreference:YES maintainAspectRatio:request byAspectRatioMaintainingRule:rule withLayoutGuidingContext:nil];
    if ([self layoutGuidingContext] != nil) {
        [[self layoutGuidingContext] showAppliedLayoutGuidingRules];
        [[self layoutGuidingContext] showInfoTagWithSize:[geometry affineFrameSize]];
    }
    [self didResizeCardObject];
}

- (void)didResizeCardObject
{

}

- (void)willResizeCardObject
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b088 @ 0003b088, 825 bytes * /

BOOL FUN_0003b088(HSFrameResizeSelectionTracker *self,SEL _cmd,NSSize *adjustSize)

{
  float fVar1;
  float fVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  char cVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  BOOL BVar9;
  undefined8 uVar10;
  undefined8 uVar11;
  float local_58;
  float local_54;
  undefined4 local_48;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar6 = _objc_msgSend(self,sel_layoutGuidingContext);
  if (pvVar6 == (id)0x0) {
    return '\0';
  }
  pvVar6 = _objc_msgSend(self,sel_layoutGuidingContext);
  pvVar6 = _objc_msgSend(pvVar6,sel_isSnappingEnabled);
  if ((char)pvVar6 == '\0') {
    return '\0';
  }
  fVar1 = adjustSize->width;
  fVar2 = adjustSize->height;
  _objc_msgSend_stret(&local_24,self,sel_currentBoundingRect);
  local_54 = local_24;
  local_58 = local_20;
  pvVar6 = _objc_msgSend(self,sel_modifyingEdges);
  if (((uint)pvVar6 & 1) != 0) {
    local_54 = local_24 + (local_1c - fVar1);
  }
  if (((uint)pvVar6 & 2) != 0) {
    local_58 = local_20 + (local_18 - fVar2);
  }
  local_34 = local_54;
  fStack_30 = local_58;
  local_44 = local_54;
  fStack_40 = local_58;
  local_48 = 0;
  local_3c = fVar1;
  fStack_38 = fVar2;
  local_2c = fVar1;
  fStack_28 = fVar2;
  pvVar7 = _objc_msgSend(self,sel_trackingObject);
  pvVar7 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_00362a14);
  _objc_msgSend(pvVar7,sel_setHyperIgnoredInLayoutGuiding_,1);
  pvVar8 = _objc_msgSend(self,sel_layoutGuidingContext);
  pvVar8 = _objc_msgSend(pvVar8,sel_layoutGuidingProcessor);
  uVar3 = *(undefined4 *)((self->super).super_HSCardObjectTracker + 0x24);
  uVar4 = *(undefined4 *)((self->super).super_HSCardObjectTracker + 0x28);
  uVar11 = CONCAT44(&local_48,uVar4);
  uVar10 = CONCAT44(uVar3,pvVar6);
  pvVar6 = _objc_msgSend(pvVar8,sel_snapRect_edges_transformationDirectionHint_appliedRules_,
                         &local_34,pvVar6,uVar3,uVar4,&local_48);
  if ((char)pvVar6 == '\0') {
LAB_0003b273:
    pvVar6 = (id)0x0;
  }
  else {
    uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),fStack_28);
    cVar5 = _NSEqualSizes(fVar1,fVar2,local_2c,fStack_28);
    if (cVar5 != '\0') goto LAB_0003b273;
    pvVar6 = _objc_msgSend(self,sel_layoutGuidingContext);
    uVar10 = CONCAT44(fStack_40,local_44);
    uVar11 = CONCAT44(fStack_38,local_3c);
    pvVar6 = _objc_msgSend(pvVar6,sel_filterSnapRules_madeForRect_byMoveDirection_,local_48,uVar10,
                           uVar11,*(undefined4 *)((self->super).super_HSCardObjectTracker + 0x24),
                           *(undefined4 *)((self->super).super_HSCardObjectTracker + 0x28));
    pvVar8 = _objc_msgSend(pvVar6,sel_count);
    if (pvVar8 != (id)0x0) {
      adjustSize->width = local_2c;
      adjustSize->height = fStack_28;
      BVar9 = '\x01';
      goto LAB_0003b352;
    }
    adjustSize->width = local_3c;
    adjustSize->height = fStack_38;
  }
  BVar9 = '\0';
LAB_0003b352:
  _objc_msgSend(pvVar7,sel_setHyperIgnoredInLayoutGuiding_,0,uVar10,uVar11);
  pvVar7 = _objc_msgSend(self,sel_layoutGuidingContext);
  _objc_msgSend(pvVar7,sel_setAppliedLayoutGuidingRules_forSnappingRect_,pvVar6,
                CONCAT44(fStack_30,local_34),CONCAT44(fStack_28,local_2c));
  return BVar9;
}

*/
- (BOOL)adjustSize:(NSSize *)aSize
{
    if ([self layoutGuidingContext] == nil || ![[self layoutGuidingContext] isSnappingEnabled]) {
        return NO;
    }
    NSSize size = *aSize;
    NSRect bounds = [self currentBoundingRect];
    NSInteger edges = [self modifyingEdges];
    NSPoint origin = bounds.origin;
    /* Moving the left or bottom edge keeps the opposite edge in place. */
    if ((edges & 1) != 0) {
        origin.x = bounds.origin.x + (bounds.size.width - size.width);
    }
    if ((edges & 2) != 0) {
        origin.y = bounds.origin.y + (bounds.size.height - size.height);
    }
    NSRect snappedRect = {origin, size};
    NSRect originalRect = {origin, size};
    id rules = nil;
    id ignoredObject = [[self trackingObject] queryHyperInterface:@protocol(HSCardObjectLayoutGuidingInterface)];
    [ignoredObject setHyperIgnoredInLayoutGuiding:YES];
    BOOL didAdjust = NO;
    if (![[[self layoutGuidingContext] layoutGuidingProcessor] snapRect:&snappedRect edges:edges transformationDirectionHint:NSMakeSize(_moveDirection.x, _moveDirection.y) appliedRules:&rules] || NSEqualSizes(size, snappedRect.size)) {
        rules = nil;
    } else {
        rules = [[self layoutGuidingContext] filterSnapRules:rules madeForRect:originalRect byMoveDirection:_moveDirection];
        if ([rules count] != 0) {
            *aSize = snappedRect.size;
            didAdjust = YES;
        } else {
            *aSize = originalRect.size;
        }
    }
    [ignoredObject setHyperIgnoredInLayoutGuiding:NO];
    [[self layoutGuidingContext] setAppliedLayoutGuidingRules:rules forSnappingRect:snappedRect];
    return didAdjust;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a1db @ 0003a1db, 22 bytes * /

BOOL FUN_0003a1db(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_invertsProportionalResizePreferences[0] & 2) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isResizesAboutCenter
{
    return _resizesAboutCenter;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a1c5 @ 0003a1c5, 22 bytes * /

BOOL FUN_0003a1c5(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_invertsProportionalResizePreferences[0] & 4) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isCrop
{
    return _isCrop;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a1b7 @ 0003a1b7, 14 bytes * /

ulonglong FUN_0003a1b7(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_untransformedStartPoint).x;
  uVar1._4_4_ = (self->_untransformedStartPoint).y;
  return uVar1;
}

*/
- (NSPoint)untransformedStartPoint
{
    return _untransformedStartPoint;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a1a9 @ 0003a1a9, 14 bytes * /

ulonglong FUN_0003a1a9(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_startSize).width;
  uVar1._4_4_ = (self->_startSize).height;
  return uVar1;
}

*/
- (NSSize)startSize
{
    return _startSize;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b3c1 @ 0003b3c1, 67 bytes * /

ulonglong FUN_0003b3c1(HSFrameResizeSelectionTracker *self,SEL _cmd,
                      uint resizingCenterPositionFactorForModifierFlags)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  
  if ((resizingCenterPositionFactorForModifierFlags & 0x80000) == 0) {
    pvVar1 = _objc_msgSend(self,sel_resizingCenterPositionFactor);
    uVar2 = extraout_EDX;
  }
  else {
    pvVar1 = (id)0x3f000000;
    uVar2 = 0x3f000000;
  }
  return CONCAT44(uVar2,pvVar1);
}

*/
- (NSSize)resizingCenterPositionFactorForModifierFlags:(NSUInteger)aFlags
{
    /* Option resizes about the center. */
    if ((aFlags & NSEventModifierFlagOption) != 0) {
        return NSMakeSize(0.5, 0.5);
    }
    return [self resizingCenterPositionFactor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a19b @ 0003a19b, 14 bytes * /

ulonglong FUN_0003a19b(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_resizingCenterPositionFactor).width;
  uVar1._4_4_ = (self->_resizingCenterPositionFactor).height;
  return uVar1;
}

*/
- (NSSize)resizingCenterPositionFactor
{
    return _resizingCenterPositionFactor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b404 @ 0003b404, 65 bytes * /

int FUN_0003b404(HSFrameResizeSelectionTracker *self,SEL _cmd,
                uint aspectRatioMaintainingRequestForModifierFlags)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_invertsProportionalResizePreferences);
  return (uint)((bool)((byte)(aspectRatioMaintainingRequestForModifierFlags >> 0x11) & 1 ^ 1) ==
               ((char)pvVar1 != '\0'));
}

*/
- (NSInteger)aspectRatioMaintainingRequestForModifierFlags:(NSUInteger)aFlags
{
    /* Shift toggles proportional resizing. */
    BOOL isShiftUp = (aFlags & NSEventModifierFlagShift) == 0;
    return isShiftUp == ([self invertsProportionalResizePreferences] != NO);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a185 @ 0003a185, 22 bytes * /

BOOL FUN_0003a185(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_invertsProportionalResizePreferences[0] & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)invertsProportionalResizePreferences
{
    return _invertsProportionalResizePreferences;
}

- (NSInteger)aspectRatioMaintainingRuleForModifierFlags:(NSUInteger)aFlags
{
    return (int)[self aspectRatioMaintainingRule];
}

- (NSInteger)aspectRatioMaintainingRule
{
    return _aspectRatioMaintainingRule;
}

- (NSInteger)modifyingEdges
{
    return _modifyingEdges;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b46b @ 0003b46b, 68 bytes * /

ulonglong FUN_0003b46b(HSFrameResizeSelectionTracker *self,SEL _cmd,uint deltaFactorForModifierFlags
                      )

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  
  pvVar1 = _objc_msgSend(self,sel_deltaFactor);
  fVar2 = extraout_EDX;
  if ((deltaFactorForModifierFlags & 0x80000) != 0) {
    fVar2 = extraout_EDX + extraout_EDX;
    pvVar1 = (id)((float)pvVar1 + (float)pvVar1);
  }
  return CONCAT44(fVar2,pvVar1);
}

*/
- (NSSize)deltaFactorForModifierFlags:(NSUInteger)aFlags
{
    NSSize delta = [self deltaFactor];
    /* Resizing about the center moves both edges. */
    if ((aFlags & NSEventModifierFlagOption) != 0) {
        delta.width = delta.width + delta.width;
        delta.height = delta.height + delta.height;
    }
    return delta;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a161 @ 0003a161, 14 bytes * /

ulonglong FUN_0003a161(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_deltaFactor).width;
  uVar1._4_4_ = (self->_deltaFactor).height;
  return uVar1;
}

*/
- (NSSize)deltaFactor
{
    return _deltaFactor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b4af @ 0003b4af, 257 bytes * /

id FUN_0003b4af(HSFrameResizeSelectionTracker *self,SEL _cmd,int initWithModifyingEdges,
               BOOL invertsProportionalResizePreferences)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  HSFrameResizeSelectionTracker *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSSelectionKnobTracker_0034dc60;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar1 == (id)0x0) {
    return (id)0x0;
  }
  if ((initWithModifyingEdges & 1U) == 0) {
    if ((initWithModifyingEdges & 4U) == 0) {
      uVar2 = 0;
      uVar3 = 0x3f000000;
    }
    else {
      uVar2 = 0x3f800000;
      uVar3 = 0;
    }
  }
  else {
    uVar2 = 0xbf800000;
    uVar3 = 0x3f800000;
  }
  if ((initWithModifyingEdges & 2U) == 0) {
    if ((initWithModifyingEdges & 8U) == 0) {
      uVar4 = 0;
      uVar5 = 0x3f000000;
    }
    else {
      uVar4 = 0x3f800000;
      uVar5 = 0;
    }
  }
  else {
    uVar4 = 0xbf800000;
    uVar5 = 0x3f800000;
  }
  *(undefined4 *)((int)pvVar1 + 0x58) = uVar2;
  *(undefined4 *)((int)pvVar1 + 0x5c) = uVar4;
  *(undefined4 *)((int)pvVar1 + 0x60) = uVar3;
  *(undefined4 *)((int)pvVar1 + 100) = uVar5;
  *(int *)((int)pvVar1 + 0x68) = initWithModifyingEdges;
  if ((initWithModifyingEdges & 5U) == 0) {
    if ((initWithModifyingEdges & 10U) != 0) {
      *(undefined4 *)((int)pvVar1 + 0x6c) = 3;
      goto LAB_0003b59c;
    }
  }
  else if ((initWithModifyingEdges & 10U) == 0) {
    *(undefined4 *)((int)pvVar1 + 0x6c) = 2;
    goto LAB_0003b59c;
  }
  *(undefined4 *)((int)pvVar1 + 0x6c) = 0;
LAB_0003b59c:
  *(byte *)((int)pvVar1 + 0x74) =
       *(byte *)((int)pvVar1 + 0x74) & 0xfe | invertsProportionalResizePreferences & 1U;
  return pvVar1;
}

*/
- (id)initWithModifyingEdges:(NSInteger)aEdges invertsProportionalResizePreferences:(BOOL)aPreferences
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    /* Edge bits: 1 left, 2 bottom, 4 right, 8 top. */
    if ((aEdges & 1) != 0) {
        _deltaFactor.width = -1;
        _resizingCenterPositionFactor.width = 1;
    } else if ((aEdges & 4) != 0) {
        _deltaFactor.width = 1;
        _resizingCenterPositionFactor.width = 0;
    } else {
        _deltaFactor.width = 0;
        _resizingCenterPositionFactor.width = 0.5;
    }
    if ((aEdges & 2) != 0) {
        _deltaFactor.height = -1;
        _resizingCenterPositionFactor.height = 1;
    } else if ((aEdges & 8) != 0) {
        _deltaFactor.height = 1;
        _resizingCenterPositionFactor.height = 0;
    } else {
        _deltaFactor.height = 0;
        _resizingCenterPositionFactor.height = 0.5;
    }
    _modifyingEdges = (int)aEdges;
    BOOL isHorizontal = (aEdges & 5) != 0;
    BOOL isVertical = (aEdges & 10) != 0;
    if (isHorizontal && !isVertical) {
        _aspectRatioMaintainingRule = 2;
    } else if (!isHorizontal && isVertical) {
        _aspectRatioMaintainingRule = 3;
    } else {
        _aspectRatioMaintainingRule = 0;
    }
    _invertsProportionalResizePreferences = aPreferences ? 1 : 0;
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003a1fb @ 0003a1fb, 71 bytes * /

id FUN_0003a1fb(HSFrameResizeSelectionTracker *self,SEL _cmd)

{
  id pvVar1;
  HSFrameResizeSelectionTracker *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_HSSelectionKnobTracker_0034dc60;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x60) = 0x3f000000;
    *(undefined4 *)((int)pvVar1 + 100) = 0x3f000000;
  }
  return pvVar1;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _resizingCenterPositionFactor = NSMakeSize(0.5, 0.5);
    }
    return self;
}

@end

