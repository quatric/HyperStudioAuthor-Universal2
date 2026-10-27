#import "HSAnimationModeController.h"

@implementation HSAnimationModeController

/* i386 ivar offsets: _cardView=0x34, _bottomAreaTintedView=0x38, _mainAreaTintedView=0x3c, _workAreaView=0x40, _actingObject=0x44, _actionEvents=0x48, _animation=0x4c, _initialAnimation=0x50, _tryItAnimation=0x54, _state=0x58, _stateBeforeHelp=0x5c, _revertMode=0x60, _storedPath=0x64, _storedKeyFrames=0x68, _pointToScrollCardView=0x6c, _assistant=0x74, _assistantNavigationController=0x78, _pickImageAssistantPane=0x7c, _drawPathAssistantPane=0x80, _mainAssistantPane=0x84, _dropHelpPane=0x88, _transparentColorAssistantPane=0x8c, _editPathTool=0x90, _undoManager=0x94, _dummyUndoManager=0x98, _undoHelper=0x9c, _applyChanges=0xa0, _switchFromAnimationModeOnCancelPathCreation=0xa0, _initialInspectorSupportsSOTSMode=0xa0, _isBlockingUndoRegistration=0xa0, _ignoreObjectGeometryChanges=0xa0 */

- (void)selectImagePartPaneCancel:(id)aCancel
{
    NSDictionary *self_00;
    id pvVar1_2;
    id pvVar1_3;
    id pvVar1_5;
    id pvVar2_2;

    pvVar1_2 = [[HSToolManager sharedToolManager] currentTool];
    [pvVar1_2 setDelegate:0];
    self_00 = [pvVar1_2 userInfo];
    [pvVar1_2 setUserInfo:0];
    pvVar2_2 = [[pvVar1_2 workObject] hyperObject];
    if (pvVar2_2 != nil) {
        [pvVar1_2 setWorkObject:nil];
        pvVar1_3 = [self card];
        [[pvVar1_3 undoManager] disableUndoRegistration];
        [pvVar1_3 removeHyperChild:pvVar2_2];
        [[pvVar1_3 undoManager] enableUndoRegistration];
        pvVar1_5 = [self_00 objectForKey:@"HSUserInfoTemporaryObjectOwner"];
        if ([pvVar1_5 respondsToSelector:@selector(releaseTemporaryObject)]) {
            [pvVar1_5 releaseTemporaryObject];
        }
    }
    [self_00 release];
    [self selectToolWithTag:0x39];
    [_assistantNavigationController popViewControllerAnimated:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001372cb @ 001372cb, 2754 bytes * /

void FUN_001372cb(HSAnimationModeController *self,SEL _cmd,id selectImagePartPaneCrop)

{
  undefined4 uVar1;
  undefined4 uVar2;
  float fVar3;
  float fVar4;
  undefined8 uVar5;
  undefined *puVar6;
  uint *puVar7;
  char cVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  undefined4 *puVar15;
  id pvVar16;
  id pvVar17;
  float extraout_EDX;
  undefined4 **ppuVar18;
  uint *puVar19;
  uint *puVar20;
  undefined4 uStack_154;
  undefined4 *puStack_150;
  undefined4 *local_f8;
  uint local_f4;
  uint uStack_f0;
  undefined4 local_ec;
  uint uStack_e8;
  undefined4 local_e4;
  undefined4 local_e0;
  undefined4 local_dc;
  undefined4 local_d8;
  float local_d4;
  undefined4 local_d0;
  undefined4 local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  float local_bc;
  undefined4 uStack_b8;
  undefined4 local_b4;
  float fStack_b0;
  float local_ac;
  float fStack_a8;
  float local_a4;
  float fStack_a0;
  id local_9c;
  float fStack_98;
  float local_94;
  float local_90;
  float local_8c;
  float local_88;
  float local_84;
  float fStack_80;
  float local_7c;
  float fStack_78;
  undefined4 local_74;
  undefined4 uStack_70;
  undefined4 local_6c;
  undefined4 uStack_68;
  undefined8 local_64;
  undefined8 local_5c;
  undefined4 local_54;
  undefined4 uStack_50;
  undefined4 local_4c;
  undefined4 uStack_48;
  undefined4 local_44;
  float fStack_40;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  puStack_150 = (undefined4 *)0x1372f5;
  pvVar9 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  puStack_150 = (undefined4 *)0x137307;
  pvVar9 = _objc_msgSend(pvVar9,sel_currentTool);
  puStack_150 = (undefined4 *)0x137329;
  _objc_msgSend(pvVar9,sel_setDelegate_);
  puVar6 = PTR_00336090;
  local_74 = *(undefined4 *)PTR_00336090;
  uStack_70 = *(undefined4 *)(PTR_00336090 + 4);
  uVar1 = *(undefined4 *)(PTR_00336090 + 8);
  uVar2 = *(undefined4 *)(PTR_00336090 + 0xc);
  local_84 = *(float *)PTR_00336078;
  fStack_80 = *(float *)(PTR_00336078 + 4);
  local_7c = *(float *)(PTR_00336078 + 8);
  fStack_78 = *(float *)(PTR_00336078 + 0xc);
  puStack_150 = (undefined4 *)0x1373a5;
  local_6c = uVar1;
  uStack_68 = uVar2;
  local_f8 = _objc_msgSend(pvVar9,sel_copiedCGPath);
  puStack_150 = (undefined4 *)0x1373bd;
  pvVar10 = _objc_msgSend(pvVar9,sel_workObject);
  puStack_150 = (undefined4 *)0x1373d9;
  pvVar10 = _objc_msgSend(pvVar10,sel_queryHyperInterface_);
  puVar20 = (uint *)&stack0xfffffeb4;
  if ((local_f8 != (undefined4 *)0x0) && (puVar20 = (uint *)&stack0xfffffeb4, pvVar10 != (id)0x0)) {
    puStack_150 = (undefined4 *)0x137416;
    _objc_msgSend_stret(&local_94,pvVar10,sel_boundingRect);
    ppuVar18 = &puStack_150;
    local_84 = local_94;
    fStack_80 = local_90;
    local_7c = local_8c;
    fStack_78 = local_88;
    uStack_154 = 0x13745b;
    puStack_150 = local_f8;
    cVar8 = _CGPathIsEmpty();
    if (cVar8 == '\0') {
      puStack_150 = &local_74;
      uStack_154 = 0x137474;
      _CGEPathGetPathBoundingBox();
      ppuVar18 = (undefined4 **)&uStack_154;
    }
    *(ulonglong *)(ppuVar18 + 7) = CONCAT44(fStack_78,local_7c);
    *(ulonglong *)(ppuVar18 + 5) = CONCAT44(fStack_80,local_84);
    *(ulonglong *)(ppuVar18 + 3) = CONCAT44(uStack_68,local_6c);
    *(ulonglong *)(ppuVar18 + 1) = CONCAT44(uStack_70,local_74);
    *ppuVar18 = (undefined4 *)&local_64;
    ppuVar18[-1] = (undefined4 *)0x1374ae;
    _CGRectIntersection();
    *(undefined8 *)(ppuVar18 + 1) = local_5c;
    *(undefined8 *)(ppuVar18 + -1) = local_64;
    ppuVar18[-2] = (undefined4 *)0x1374cb;
    cVar8 = _CGRectIsEmpty();
    puVar20 = (uint *)(ppuVar18 + -1);
    if (cVar8 != '\0') {
      local_74 = *(undefined4 *)puVar6;
      uStack_70 = *(undefined4 *)(puVar6 + 4);
      puVar20 = (uint *)(ppuVar18 + -1);
      local_6c = uVar1;
      uStack_68 = uVar2;
    }
  }
  *(ulonglong *)(puVar20 + 2) = CONCAT44(uStack_68,local_6c);
  *(ulonglong *)puVar20 = CONCAT44(uStack_70,local_74);
  puVar20[-1] = 0x137516;
  cVar8 = _CGRectIsEmpty();
  if (cVar8 != '\0') {
    if (local_f8 != (undefined4 *)0x0) {
      *puVar20 = (uint)local_f8;
      puVar20[-1] = 0x137531;
      _CGPathRelease();
    }
    puVar20[2] = (uint)selectImagePartPaneCrop;
    puVar20[1] = (uint)sel_selectImagePartPaneCancel_;
    *puVar20 = (uint)self;
    goto LAB_00137548;
  }
  puVar20[1] = (uint)sel_new;
  *puVar20 = (uint)cls_NSAutoreleasePool;
  puVar20[-1] = 0x137570;
  pvVar11 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_userInfo;
  *puVar20 = (uint)pvVar9;
  puVar20[-1] = 0x13758e;
  pvVar12 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_setUserInfo_;
  *puVar20 = (uint)pvVar9;
  puVar20[2] = 0;
  puVar20[-1] = 0x1375b4;
  _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_retain;
  *puVar20 = (uint)pvVar10;
  puVar20[-1] = 0x1375cc;
  _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_resetToolToDefault;
  *puVar20 = (uint)self;
  puVar20[-1] = 0x1375e1;
  _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_hyperObject;
  *puVar20 = (uint)pvVar10;
  puVar20[-1] = 0x1375f3;
  pvVar13 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  if (pvVar13 != (id)0x0) {
    puVar20[1] = (uint)sel_setWorkObject_;
    *puVar20 = (uint)pvVar9;
    puVar20[2] = 0;
    puVar20[-1] = 0x13761d;
    _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_retain;
    *puVar20 = (uint)pvVar13;
    puVar20[-1] = 0x13762f;
    _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_card;
    *puVar20 = (uint)self;
    puVar20[-1] = 0x137644;
    pvVar9 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_undoManager;
    *puVar20 = (uint)pvVar9;
    puVar20[-1] = 0x137658;
    pvVar14 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_disableUndoRegistration;
    *puVar20 = (uint)pvVar14;
    puVar20[-1] = 0x13766a;
    _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[2] = (uint)pvVar13;
    puVar20[1] = (uint)sel_removeHyperChild_;
    *puVar20 = (uint)pvVar9;
    puVar20[-1] = 0x137680;
    _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_undoManager;
    *puVar20 = (uint)pvVar9;
    puVar20[-1] = 0x137692;
    pvVar9 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_enableUndoRegistration;
    *puVar20 = (uint)pvVar9;
    puVar20[-1] = 0x1376a4;
    _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[2] = (uint)&cfstr_HSUserInfoTemporaryObjectOwner;
    puVar20[1] = (uint)sel_objectForKey_;
    *puVar20 = (uint)pvVar12;
    puVar20[-1] = 0x1376c6;
    pvVar9 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[2] = (uint)sel_releaseTemporaryObject;
    puVar20[1] = (uint)sel_respondsToSelector_;
    *puVar20 = (uint)pvVar9;
    puVar20[-1] = 0x1376e4;
    pvVar14 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    if ((char)pvVar14 != '\0') {
      puVar20[1] = (uint)sel_releaseTemporaryObject;
      *puVar20 = (uint)pvVar9;
      puVar20[-1] = 0x1376fa;
      _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    }
    puVar20[1] = (uint)sel_autorelease;
    *puVar20 = (uint)pvVar13;
    puVar20[-1] = 0x13770c;
    _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  }
  puVar20[2] = (uint)&DAT_00373350;
  puVar20[1] = (uint)sel_queryHyperInterface_;
  *puVar20 = (uint)pvVar13;
  puVar20[-1] = 0x137728;
  pvVar9 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  if (pvVar9 != (id)0x0) {
    puVar20[1] = (uint)sel_image;
    *puVar20 = (uint)pvVar9;
    puVar20[-1] = 0x137748;
    pvVar13 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    puVar20[1] = (uint)sel_size;
    *puVar20 = (uint)pvVar13;
    fVar3 = *(float *)PTR_00336074;
    fVar4 = *(float *)(PTR_00336074 + 4);
    uVar5 = *(undefined8 *)PTR_00336074;
    puVar20[-1] = 0x137779;
    local_9c = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    *(ulonglong *)(puVar20 + 2) = CONCAT44(extraout_EDX,local_9c);
    *(undefined8 *)puVar20 = uVar5;
    puVar20[-1] = 0x1377c5;
    local_a4 = fVar3;
    fStack_a0 = fVar4;
    fStack_98 = extraout_EDX;
    cVar8 = _NSIsEmptyRect();
    if (cVar8 == '\0') {
      if ((local_7c != 0.0) || (NAN(local_7c))) {
        local_bc = (float)local_9c / local_7c;
      }
      else {
        local_bc = 1.0;
      }
      if ((fStack_78 != 0.0) || (NAN(fStack_78))) {
        fStack_b0 = fStack_98 / fStack_78;
      }
      else {
        fStack_b0 = 1.0;
      }
      local_ac = local_a4 - local_84 * local_bc;
      uStack_b8 = 0;
      local_b4 = 0;
      fStack_a8 = fStack_a0 - fStack_80 * fStack_b0;
      fStack_40 = fStack_a0 + fStack_a0 + fStack_98;
      local_54 = 0x3f800000;
      uStack_50 = 0;
      local_4c = 0;
      uStack_48 = 0xbf800000;
      local_44 = 0;
      *(ulonglong *)(puVar20 + 0xb) = (ulonglong)(uint)fStack_40 << 0x20;
      puVar20[9] = 0;
      puVar20[10] = -0x40800000;
      puVar20[7] = 0x3f800000;
      puVar20[8] = 0;
      *(ulonglong *)(puVar20 + 5) = CONCAT44(fStack_a8,local_ac);
      *(ulonglong *)(puVar20 + 3) = (ulonglong)(uint)fStack_b0 << 0x20;
      *(ulonglong *)(puVar20 + 1) = (ulonglong)(uint)local_bc;
      *puVar20 = (uint)&local_d4;
      puVar20[-1] = 0x137912;
      _CGAffineTransformConcat();
      local_bc = local_d4;
      uStack_b8 = local_d0;
      local_b4 = local_cc;
      fStack_b0 = (float)local_c8;
      local_ac = (float)local_c4;
      fStack_a8 = (float)local_c0;
      puVar20[-2] = 0x13797a;
      puVar15 = (undefined4 *)_CGPathCreateMutable();
      puVar7 = puVar20 + -1;
      if (puVar15 != (undefined4 *)0x0) {
        puVar20[1] = (uint)local_f8;
        *puVar20 = (uint)&local_bc;
        puVar20[-1] = (uint)puVar15;
        puVar20[-2] = 0x13799c;
        _CGPathAddPath();
        puVar20[-1] = (uint)local_f8;
        puVar20[-2] = 0x1379aa;
        _CGPathRelease();
        *puVar20 = (uint)puVar15;
        puVar20[-1] = (uint)&local_e4;
        puVar20[-2] = 0x1379bc;
        _CGEPathGetPathBoundingBox();
        local_74 = local_e4;
        uStack_70 = local_e0;
        local_6c = local_dc;
        uStack_68 = local_d8;
        puVar7 = puVar20 + -2;
        local_f8 = puVar15;
      }
      puVar20 = puVar7;
      puVar20[2] = (uint)&cfstr_HSUserInfoOptions;
      puVar20[1] = (uint)sel_objectForKey_;
      *puVar20 = (uint)pvVar12;
      puVar20[-1] = 0x137a1b;
      pvVar13 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
      puVar20[2] = *(uint *)PTR_PTR_003365f0;
      puVar20[1] = (uint)sel_objectForKey_;
      *puVar20 = (uint)pvVar13;
      puVar20[-1] = 0x137a3f;
      pvVar14 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
      puVar6 = PTR_DAT_003365e0;
      puVar20[1] = (uint)sel_unsignedLongValue;
      *puVar20 = (uint)pvVar14;
      puVar20[-1] = 0x137a57;
      pvVar14 = _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
      if (*(id *)puVar6 == pvVar14) {
        *(ulonglong *)(puVar20 + 3) = CONCAT44(uStack_68,local_6c);
        *(ulonglong *)(puVar20 + 1) = CONCAT44(uStack_70,local_74);
        *puVar20 = (uint)&local_3c;
        puVar20[-1] = 0x137a80;
        _CGRectIntegral();
        *(ulonglong *)(puVar20 + 6) = CONCAT44(fStack_98,local_9c);
        *(ulonglong *)(puVar20 + 4) = CONCAT44(fStack_a0,local_a4);
        *(undefined8 *)(puVar20 + 2) = local_34;
        *(undefined8 *)puVar20 = local_3c;
        puVar20[-1] = (uint)&local_f4;
        puVar20[-2] = 0x137ac3;
        _CGRectIntersection();
        puVar19 = puVar20 + -2;
        *(ulonglong *)puVar20 = CONCAT44(uStack_e8,local_ec);
        *(ulonglong *)(puVar20 + -2) = CONCAT44(uStack_f0,local_f4);
        puVar20[-3] = 0x137ae6;
        cVar8 = _CGRectIsEmpty();
        if (cVar8 == '\0') {
          puVar20[-1] = (uint)sel_alloc;
          puVar20[-2] = (uint)cls_NSImage;
          puVar20[-3] = 0x137b21;
          pvVar14 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[1] = uStack_e8;
          *puVar20 = local_ec;
          puVar20[-1] = (uint)sel_initWithSize_;
          puVar20[-2] = (uint)pvVar14;
          puVar20[-3] = 0x137b4f;
          pvVar16 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          pvVar14 = pvVar16;
          if (pvVar16 == (id)0x0) goto LAB_00137aec;
          puVar20[-1] = (uint)sel_image;
          puVar20[-2] = (uint)pvVar9;
          puVar20[-3] = 0x137b6d;
          pvVar9 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[-1] = (uint)sel_copy;
          puVar20[-2] = (uint)pvVar9;
          puVar20[-3] = 0x137b7f;
          pvVar9 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[-1] = (uint)sel_autorelease;
          puVar20[-2] = (uint)pvVar9;
          puVar20[-3] = 0x137b91;
          pvVar9 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[-1] = (uint)sel_setFlipped_;
          puVar20[-2] = (uint)pvVar9;
          *puVar20 = 0;
          puVar20[-3] = 0x137bb7;
          _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[-1] = (uint)sel_lockFocus;
          puVar20[-2] = (uint)pvVar16;
          puVar20[-3] = 0x137bc9;
          _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[-1] = (uint)sel_currentContext;
          puVar20[-2] = (uint)cls_NSGraphicsContext;
          puVar20[-3] = 0x137be1;
          pvVar17 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          puVar20[-1] = (uint)sel_graphicsPort;
          puVar20[-2] = (uint)pvVar17;
          puVar20[-3] = 0x137bf3;
          pvVar17 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
          *puVar20 = uStack_f0 ^ 0x80000000;
          puVar20[-1] = local_f4 ^ 0x80000000;
          puVar20[-2] = (uint)&local_2c;
          puVar20[-3] = 0x137c2a;
          _CGAffineTransformMakeTranslation();
          puVar19 = puVar20 + -3;
          *(undefined8 *)(puVar20 + 2) = local_1c;
          *(undefined8 *)puVar20 = local_24;
          *(undefined8 *)(puVar20 + -2) = local_2c;
          puVar20[-3] = (uint)pvVar17;
          puVar20[-4] = 0x137c56;
          _CGContextConcatCTM();
          puVar20[-3] = (uint)pvVar17;
          puVar20[-4] = 0x137c5e;
          _CGContextBeginPath();
          puVar20[-2] = (uint)local_f8;
          puVar20[-3] = (uint)pvVar17;
          puVar20[-4] = 0x137c70;
          _CGContextAddPath();
          puVar20[-3] = (uint)pvVar17;
          puVar20[-4] = 0x137c78;
          _CGContextClip();
          *(ulonglong *)(puVar20 + 5) = CONCAT44(uStack_e8,local_ec);
          *(ulonglong *)(puVar20 + 3) = CONCAT44(uStack_f0,local_f4);
          *(ulonglong *)(puVar20 + 1) = CONCAT44(uStack_e8,local_ec);
          *(ulonglong *)(puVar20 + -1) = CONCAT44(uStack_f0,local_f4);
          puVar20[-2] = (uint)sel_drawInRect_fromRect_operation_fraction_;
          puVar20[-3] = (uint)pvVar9;
          puVar20[8] = 0x3f800000;
          puVar20[7] = 2;
          puVar20[-4] = 0x137cc8;
          _objc_msgSend((id)puVar20[-3],(SEL)puVar20[-2]);
          puVar20[-2] = (uint)sel_unlockFocus;
          puVar20[-3] = (uint)pvVar16;
          puVar20[-4] = 0x137cda;
          _objc_msgSend((id)puVar20[-3],(SEL)puVar20[-2]);
        }
        else {
          pvVar14 = (id)0x0;
LAB_00137aec:
          puVar20[-1] = (uint)sel_image;
          puVar20[-2] = (uint)pvVar9;
          puVar20[-3] = 0x137b04;
          pvVar16 = _objc_msgSend((id)puVar20[-2],(SEL)puVar20[-1]);
        }
        puVar19[3] = (uint)pvVar16;
        puVar19[2] = (uint)pvVar13;
        puVar19[1] = (uint)sel_createImageAnimationWithOptions_image_;
        *puVar19 = (uint)self;
        puVar19[-1] = 0x137cff;
        _objc_msgSend((id)*puVar19,(SEL)puVar19[1]);
        puVar19[1] = (uint)sel_release;
        *puVar19 = (uint)pvVar14;
        puVar20 = puVar19;
      }
      else {
        puVar20[3] = (uint)local_f8;
        puVar20[2] = (uint)pvVar13;
        puVar20[1] = (uint)sel_createCelAnimationWithOptions_croppingPath_;
        *puVar20 = (uint)self;
      }
      puVar20[-1] = 0x137d37;
      _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
    }
  }
  *puVar20 = (uint)local_f8;
  puVar20[-1] = 0x137d45;
  _CGPathRelease();
  puVar20[1] = (uint)sel_release;
  *puVar20 = (uint)pvVar10;
  puVar20[-1] = 0x137d5d;
  _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_release;
  *puVar20 = (uint)pvVar12;
  puVar20[-1] = 0x137d75;
  _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  puVar20[1] = (uint)sel_release;
  *puVar20 = (uint)pvVar11;
LAB_00137548:
  puVar20[-1] = 0x13754d;
  _objc_msgSend((id)*puVar20,(SEL)puVar20[1]);
  return;
}

*/
- (void)selectImagePartPaneCrop:(id)aCrop
{
    id tool = [[HSToolManager sharedToolManager] currentTool];
    [tool setDelegate:nil];
    CGRect pathBounds = CGRectZero;
    NSRect objectBounds = NSZeroRect;
    CGPathRef path = [tool copiedCGPath];
    id geometry = [[tool workObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (path != NULL && geometry != nil) {
        objectBounds = [geometry boundingRect];
        if (!CGPathIsEmpty(path)) {
            pathBounds = CGEPathGetPathBoundingBox(path);
        }
        if (CGRectIsEmpty(CGRectIntersection(pathBounds, objectBounds))) {
            pathBounds = CGRectZero;
        }
    }
    if (CGRectIsEmpty(pathBounds)) {
        if (path != NULL) {
            CGPathRelease(path);
        }
        [self selectImagePartPaneCancel:aCrop];
        return;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSDictionary *userInfo = [tool userInfo];
    [tool setUserInfo:nil];
    [geometry retain];
    [self resetToolToDefault];
    id hyperObject = [geometry hyperObject];
    if (hyperObject != nil) {
        [tool setWorkObject:nil];
        [hyperObject retain];
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:hyperObject];
        [[card undoManager] enableUndoRegistration];
        id owner = [userInfo objectForKey:@"HSUserInfoTemporaryObjectOwner"];
        if ([owner respondsToSelector:@selector(releaseTemporaryObject)]) {
            [owner releaseTemporaryObject];
        }
        [hyperObject autorelease];
    }
    id imageAttributes = [hyperObject queryHyperInterface:@protocol(HSImageAttributes)];
    if (imageAttributes != nil) {
        NSSize imageSize = [[imageAttributes image] size];
        NSRect imageRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
        if (!NSIsEmptyRect(imageRect)) {
            CGFloat scaleX = (objectBounds.size.width != 0.0) ? imageSize.width / objectBounds.size.width : 1.0;
            CGFloat scaleY = (objectBounds.size.height != 0.0) ? imageSize.height / objectBounds.size.height : 1.0;
            CGAffineTransform scale = CGAffineTransformMake(scaleX, 0, 0, scaleY, imageRect.origin.x - objectBounds.origin.x * scaleX, imageRect.origin.y - objectBounds.origin.y * scaleY);
            CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, imageRect.origin.y * 2 + imageSize.height);
            CGAffineTransform transform = CGAffineTransformConcat(scale, flip);
            CGMutablePathRef newPath = CGPathCreateMutable();
            if (newPath != NULL) {
                CGPathAddPath(newPath, &transform, path);
                CGPathRelease(path);
                pathBounds = CGEPathGetPathBoundingBox(newPath);
                path = newPath;
            }
            NSDictionary *options = [userInfo objectForKey:@"HSUserInfoOptions"];
            if ([[options objectForKey:@"graphicType"] unsignedLongValue] == ' img') {
                CGRect cropRect = CGRectIntersection(CGRectIntegral(pathBounds), NSRectToCGRect(imageRect));
                NSImage *croppedImage = nil;
                NSImage *image;
                if (!CGRectIsEmpty(cropRect)) {
                    croppedImage = [[NSImage alloc] initWithSize:cropRect.size];
                }
                if (croppedImage != nil) {
                    NSImage *source = [[[imageAttributes image] copy] autorelease];
                    [source setFlipped:NO];
                    [croppedImage lockFocus];
                    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
                    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-cropRect.origin.x, -cropRect.origin.y));
                    CGContextBeginPath(context);
                    CGContextAddPath(context, path);
                    CGContextClip(context);
                    [source drawInRect:NSRectFromCGRect(cropRect) fromRect:NSRectFromCGRect(cropRect) operation:NSCompositingOperationSourceOver fraction:1.0];
                    [croppedImage unlockFocus];
                    image = croppedImage;
                } else {
                    image = [imageAttributes image];
                }
                [self createImageAnimationWithOptions:options image:image];
                [croppedImage release];
            } else {
                [self createCelAnimationWithOptions:options croppingPath:path];
            }
        }
    }
    CGPathRelease(path);
    [geometry release];
    [userInfo release];
    [pool release];
}

- (void)coachingAssistantGoBackFromPane:(id)aPane
{
    [self resetToolToDefault];
    [aPane dismiss:YES];
}

- (void)invalidateDropHelpPane
{
    [_dropHelpPane release];
    _dropHelpPane = nil;
}

- (void)animationDropHelpPaneWillDismiss:(id)aDismiss
{
    [[HSCoachingHelpManager sharedCoachingHelpManager] removeDropHelpPaneForObject:[aDismiss actingObject]];
}

- (void)animationDropHelpPaneDoContinue:(id)aContinue
{
    id pvVar1;
    id pvVar2;
    id pvVar3;
    id pvVar4;

    pvVar1 = [aContinue objectAssistantNavigationController];
    pvVar2 = [aContinue assistant];
    pvVar3 = [aContinue animatedObject];
    pvVar4 = [aContinue actionEvents];
    [self createAnimationForActingObject:[aContinue actingObject] actionEvents:pvVar4 animatedObject:pvVar3 assistant:pvVar2 assistantNavigationController:pvVar1];
    [self setState:1];
    [self runDrawPath];
    _revertMode = (int)[aContinue revertMode];
    _dropHelpPane = [aContinue retain];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00137f80 @ 00137f80, 906 bytes * /

void FUN_00137f80(HSAnimationModeController *self,SEL _cmd,id runWithImage,id options,id fromPane)

{
  undefined4 uVar1;
  undefined *puVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  SEL pcVar8;
  
  pvVar3 = _objc_msgSend(options,sel_objectForKey_,*(undefined4 *)PTR_PTR_003365f4);
  if ((pvVar3 == (id)0x0) ||
     (pvVar3 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_,pvVar3), pvVar3 == (id)0x0)) {
    pvVar3 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithImage_,runWithImage);
  }
  self_00 = _objc_msgSend(cls_HSDocument,sel_userObjectWithMedia_,pvVar3);
  pvVar3 = *(id *)PTR_PTR_003365e8;
  pvVar4 = _objc_msgSend(options,sel_objectForKey_,pvVar3);
  if (pvVar4 != (id)0x0) {
    pvVar3 = _objc_msgSend(cls_HSImageCropApplier,sel_cropApplierForImageObject_,self_00);
    _objc_msgSend(pvVar3,sel_cropImageObjectWithPaths_modifyObjectGeometry_,pvVar4,1);
    pvVar3 = pvVar4;
  }
  if (self->_state == 3) {
    _objc_msgSend(self->_pickImageAssistantPane,sel_release,pvVar3);
    self->_pickImageAssistantPane = (HSAnimationSetupPickImageAssistantPane *)0x0;
    pcVar8 = sel_cleanUpTryItAnimation;
  }
  else {
    _objc_msgSend(self,sel_lockAssistantIfNeeded,pvVar3);
    pvVar3 = _objc_msgSend(fromPane,sel_assistant);
    pvVar4 = _objc_msgSend(pvVar3,sel_object);
    pvVar5 = _objc_msgSend(cls_HSHypertextLinksProxyForInspector,
                           sel_sharedHypertextLinksProxyForInspector);
    if (pvVar4 == pvVar5) {
      pvVar4 = _objc_msgSend(pvVar4,sel_selectedHypertextLink);
    }
    pvVar5 = _objc_msgSend(self,sel_actionEventsForObject_,pvVar4);
    pvVar6 = _objc_msgSend(fromPane,sel_objectAssistantNavigationController);
    _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,
                  pvVar4,pvVar5,pvVar3,pvVar6);
    pvVar7 = _objc_msgSend(self,sel_isAnimationModeActive);
    if ((char)pvVar7 == '\0') {
      _objc_msgSend(self,sel_switchToAnimationMode,pvVar4,pvVar5,pvVar3,pvVar6);
      self->_applyChanges[0] = self->_applyChanges[0] | 2;
    }
    _objc_msgSend(self,sel_setUpAnimation,pvVar4,pvVar5,pvVar3,pvVar6);
    _objc_msgSend(self,sel_setUpUndoHelper);
    pvVar3 = (id)0x0;
    pcVar8 = sel_setState_;
  }
  _objc_msgSend(self,pcVar8,pvVar3);
  if (self_00 != (id)0x0) {
    pvVar3 = (id)0x39;
    _objc_msgSend(self,sel_selectToolWithTag_,0x39);
  }
  _objc_msgSend(self_00,sel_retain,pvVar3);
  pvVar3 = _objc_msgSend(options,sel_objectForKey_,*(undefined4 *)PTR_PTR_003365f0);
  puVar2 = PTR_DAT_003365dc;
  pvVar3 = _objc_msgSend(pvVar3,sel_unsignedLongValue);
  if (*(id *)puVar2 == pvVar3) {
    pcVar8 = sel_createCelAnimationWithOptions_croppingPath_;
    pvVar3 = (id)0x0;
  }
  else {
    uVar1 = *(undefined4 *)PTR_PTR_003365e4;
    pvVar4 = _objc_msgSend(options,sel_objectForKey_,uVar1);
    pvVar3 = self_00;
    if (pvVar4 == (id)0x0) {
      options = (id)0x0;
      pcVar8 = sel_createObjectAnimationWithOptions_object_;
    }
    else {
      options = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar4,uVar1);
      pcVar8 = sel_createObjectAnimationWithOptions_object_;
    }
  }
  _objc_msgSend(self,pcVar8,options,pvVar3);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)runWithImage:(id)aImage options:(id)aOptions fromPane:(id)aPane
{
    id media = nil;
    NSString *sourcePath = [aOptions objectForKey:@"sourcePath"];
    if (sourcePath != nil) {
        media = [HSNewMedia mediaWithPath:sourcePath];
    }
    if (media == nil) {
        media = [HSNewMedia mediaWithImage:aImage];
    }
    id imageObject = [HSDocument userObjectWithMedia:media];
    id clipPaths = [aOptions objectForKey:@"clipPaths"];
    if (clipPaths != nil) {
        [[HSImageCropApplier cropApplierForImageObject:imageObject] cropImageObjectWithPaths:clipPaths modifyObjectGeometry:YES];
    }
    if (_state == 3) {
        [_pickImageAssistantPane release];
        _pickImageAssistantPane = nil;
        [self cleanUpTryItAnimation];
    } else {
        [self lockAssistantIfNeeded];
        id assistant = [aPane assistant];
        id object = [assistant object];
        if (object == [HSHypertextLinksProxyForInspector sharedHypertextLinksProxyForInspector]) {
            object = [object selectedHypertextLink];
        }
        id events = [self actionEventsForObject:object];
        [self setActingObject:object actionEvents:events assistant:assistant assistantNavigationController:[aPane objectAssistantNavigationController]];
        if (![self isAnimationModeActive]) {
            [self switchToAnimationMode];
            _switchFromAnimationModeOnCancelPathCreation = YES;
        }
        [self setUpAnimation];
        [self setUpUndoHelper];
        [self setState:0];
    }
    if (imageObject != nil) {
        [self selectToolWithTag:0x39];
    }
    [imageObject retain];
    if ([[aOptions objectForKey:@"graphicType"] unsignedLongValue] == 'CELm') {
        [self createCelAnimationWithOptions:aOptions croppingPath:NULL];
    } else {
        NSValue *transform = [aOptions objectForKey:@"affineTransform"];
        NSDictionary *options = transform != nil ? [NSDictionary dictionaryWithObject:transform forKey:@"affineTransform"] : nil;
        [self createObjectAnimationWithOptions:options object:imageObject];
    }
    [imageObject release];
}

- (void)cropTemporaryObject:(id)aObject options:(id)aOptions forAssistantPane:(id)aPane shouldProceedWithMode:(NSInteger)aMode
{
    if (_state == 3) {
        [_pickImageAssistantPane release];
        _pickImageAssistantPane = nil;
    }
    else {
        [self setUpAnimation];
        [self setUpUndoHelper];
        [self setState:0];
    }
    [self runCropForTemporaryObject:aObject options:aOptions withMode:aMode temporaryObjectOwner:aPane];
}

- (void)unprepareCroppingForAssistantPane:(id)aPane temporaryObject:(id)aObject
{
    [self unprepareCroppingForTemporaryObject:aObject];
    if ([aPane respondsToSelector:@selector(releaseTemporaryObject)]) {
        [aPane releaseTemporaryObject];
    }
}

- (void)unprepareCroppingForTemporaryObject:(id)aObject
{
    id pvVar1;

    [self resetToolToDefault];
    if (aObject != nil) {
        pvVar1 = [self card];
        [[pvVar1 undoManager] disableUndoRegistration];
        [pvVar1 removeHyperChild:aObject];
        [[pvVar1 undoManager] enableUndoRegistration];
    }
    if (_state == 0) {
        [self switchFromAnimationMode];
        [self restoreSelectonAfterSwitchFromAnimationMode];
        [self unlockAssistantIfNeeded];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001384fd @ 001384fd, 1369 bytes * /

id FUN_001384fd(HSAnimationModeController *self,SEL _cmd,id prepareToCroppingForAssistantPane,
               id image,id options)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  undefined4 uVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  float extraout_EDX;
  longdouble lVar12;
  float fVar13;
  undefined8 in_stack_ffffff7c;
  undefined4 uVar16;
  undefined8 uVar14;
  ulonglong uVar15;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  uVar16 = (undefined4)((ulonglong)in_stack_ffffff7c >> 0x20);
  pvVar7 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithImage_,image);
  uVar14 = CONCAT44(uVar16,pvVar7);
  pvVar7 = _objc_msgSend(cls_HSDocument,sel_userObjectWithMedia_,pvVar7);
  if (pvVar7 != (id)0x0) {
    pvVar8 = _objc_msgSend(pvVar7,sel_undoManager,uVar14);
    uVar16 = (undefined4)((ulonglong)uVar14 >> 0x20);
    _objc_msgSend(pvVar8,sel_disableUndoRegistration);
    uVar15 = CONCAT44(uVar16,&DAT_00372ef0);
    pvVar8 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_00372ef0);
    if (pvVar8 != (id)0x0) {
      uVar15 = uVar15 & 0xffffffff00000000;
      _objc_msgSend(pvVar8,sel_setHyperShadowEnabled_,0);
    }
    pvVar8 = _objc_msgSend(pvVar7,sel_undoManager,uVar15);
    _objc_msgSend(pvVar8,sel_enableUndoRegistration);
    if (self->_state == 3) {
      _objc_msgSend(self->_pickImageAssistantPane,sel_release);
      self->_pickImageAssistantPane = (HSAnimationSetupPickImageAssistantPane *)0x0;
      _objc_msgSend(self,sel_cleanUpTryItAnimation);
    }
    else {
      _objc_msgSend(self,sel_lockAssistantIfNeeded);
      pvVar8 = _objc_msgSend(prepareToCroppingForAssistantPane,sel_assistant);
      pvVar11 = _objc_msgSend(pvVar8,sel_object);
      pvVar9 = _objc_msgSend(self,sel_actionEventsForObject_,pvVar11);
      pvVar10 = _objc_msgSend(prepareToCroppingForAssistantPane,
                              sel_objectAssistantNavigationController);
      uVar14 = CONCAT44(pvVar10,pvVar8);
      uVar15 = CONCAT44(pvVar9,pvVar11);
      _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,
                    pvVar11,pvVar9,pvVar8,pvVar10);
      pvVar8 = _objc_msgSend(self,sel_isAnimationModeActive);
      if ((char)pvVar8 == '\0') {
        _objc_msgSend(self,sel_switchToAnimationMode,uVar15,uVar14);
        self->_applyChanges[0] = self->_applyChanges[0] & 0xfd;
      }
    }
    uVar16 = (undefined4)(uVar15 >> 0x20);
    _objc_msgSend(self,sel_addTemporaryObjectToCard_,pvVar7);
    pvVar8 = _objc_msgSend(pvVar7,sel_undoManager);
    _objc_msgSend(pvVar8,sel_disableUndoRegistration);
    uVar14 = CONCAT44(uVar16,&DAT_00373328);
    pvVar8 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_00373328);
    pvVar8 = _objc_msgSend(pvVar8,sel_queryGeometryBehaviorApplier);
    if (pvVar8 != (id)0x0) {
      uVar14 = CONCAT44((int)((ulonglong)uVar14 >> 0x20),*(undefined4 *)PTR_PTR_003365e4);
      pvVar11 = _objc_msgSend(options,sel_objectForKey_,*(undefined4 *)PTR_PTR_003365e4);
      if (pvVar11 != (id)0x0) {
        local_2c = *(float *)PTR_00336088;
        fStack_28 = *(float *)(PTR_00336088 + 4);
        local_24 = *(float *)(PTR_00336088 + 8);
        fStack_20 = *(float *)(PTR_00336088 + 0xc);
        local_1c = *(undefined4 *)(PTR_00336088 + 0x10);
        uStack_18 = *(undefined4 *)(PTR_00336088 + 0x14);
        _objc_msgSend(pvVar11,sel_getValue_,&local_2c);
        uVar6 = uStack_18;
        uVar16 = local_1c;
        fVar5 = fStack_20;
        fVar4 = local_24;
        fVar3 = fStack_28;
        fVar2 = local_2c;
        lVar12 = (longdouble)_hypotf(local_2c,fStack_28);
        fVar1 = (float)lVar12;
        lVar12 = (longdouble)_hypotf(fVar4,fVar5);
        fStack_20 = (float)lVar12;
        fVar13 = fStack_20;
        if (&stack0x00000000 == (undefined1 *)0x30) {
          fVar13 = 1.0;
        }
        if ((fStack_20 != 0.0) || (NAN(fStack_20))) {
          fStack_20 = 1.0 / fStack_20;
        }
        else {
          fStack_20 = 1.0;
        }
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fStack_28 = 1.0 / fVar1;
        }
        else {
          fStack_28 = 1.0;
        }
        local_2c = fVar2 * fStack_28;
        fStack_28 = fVar3 * fStack_28;
        local_24 = fVar4 * fStack_20;
        fStack_20 = fVar5 * fStack_20;
        local_1c = uVar16;
        uStack_18 = uVar6;
        _objc_msgSend(pvVar8,sel_resizeFrameBy_aboutRelativePoint_withLayoutGuidingContext_,fVar1,
                      fVar13,*(undefined4 *)PTR_00336074,*(undefined4 *)(PTR_00336074 + 4),0);
        uVar14 = CONCAT44(fStack_28,local_2c);
        _objc_msgSend(pvVar8,sel_setAffineTransform_withLayoutGuidingContext_,uVar14,
                      CONCAT44(fStack_20,local_24),CONCAT44(uStack_18,local_1c),0);
      }
      pvVar11 = _objc_msgSend(self,sel_document,uVar14);
      pvVar11 = _objc_msgSend(pvVar11,sel_stack);
      pvVar11 = _objc_msgSend(pvVar11,sel_hyperCardSize);
      uVar14 = CONCAT44(extraout_EDX * 0.5,(float)pvVar11 * 0.5);
      _objc_msgSend(pvVar8,sel_moveCenterTo_withLayoutGuidingContext_,(float)pvVar11 * 0.5,
                    extraout_EDX * 0.5,0);
    }
    pvVar8 = _objc_msgSend(pvVar7,sel_undoManager,uVar14);
    _objc_msgSend(pvVar8,sel_enableUndoRegistration);
    _objc_msgSend(self,sel_selectToolWithTag_,0x39);
  }
  return pvVar7;
}

*/
- (id)prepareToCroppingForAssistantPane:(id)aPane image:(id)aImage options:(id)aOptions
{
    id imageObject = [HSDocument userObjectWithMedia:[HSNewMedia mediaWithImage:aImage]];
    if (imageObject == nil) {
        return nil;
    }
    [[imageObject undoManager] disableUndoRegistration];
    id shadow = [imageObject queryHyperInterface:@protocol(HSMutableShadowAttributes)];
    if (shadow != nil) {
        [shadow setHyperShadowEnabled:NO];
    }
    [[imageObject undoManager] enableUndoRegistration];
    if (_state == 3) {
        [_pickImageAssistantPane release];
        _pickImageAssistantPane = nil;
        [self cleanUpTryItAnimation];
    } else {
        [self lockAssistantIfNeeded];
        id assistant = [aPane assistant];
        id object = [assistant object];
        id events = [self actionEventsForObject:object];
        [self setActingObject:object actionEvents:events assistant:assistant assistantNavigationController:[aPane objectAssistantNavigationController]];
        if (![self isAnimationModeActive]) {
            [self switchToAnimationMode];
            _switchFromAnimationModeOnCancelPathCreation = NO;
        }
    }
    [self addTemporaryObjectToCard:imageObject];
    [[imageObject undoManager] disableUndoRegistration];
    id applier = [[imageObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier != nil) {
        NSValue *transformValue = [aOptions objectForKey:@"affineTransform"];
        if (transformValue != nil) {
            CGAffineTransform t = CGAffineTransformIdentity;
            [transformValue getValue:&t];
            CGFloat sx = hypot(t.a, t.b);
            CGFloat sy = hypot(t.c, t.d);
            CGFloat invY = (sy != 0.0) ? 1.0 / sy : 1.0;
            CGFloat invX = (sx != 0.0) ? 1.0 / sx : 1.0;
            t.a *= invX;
            t.b *= invX;
            t.c *= invY;
            t.d *= invY;
            [applier resizeFrameBy:NSMakeSize(sx, sy) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
            [applier setAffineTransform:t withLayoutGuidingContext:nil];
        }
        NSSize cardSize = [[[self document] stack] hyperCardSize];
        [applier moveCenterTo:NSMakePoint(cardSize.width * 0.5, cardSize.height * 0.5) withLayoutGuidingContext:nil];
    }
    [[imageObject undoManager] enableUndoRegistration];
    [self selectToolWithTag:0x39];
    return imageObject;
}

- (void)hideAnimationObjectForAssistantPane:(id)aPane
{
    if (_state == 3) {
        [self cleanUpTryItAnimation];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00138a82 @ 00138a82, 170 bytes * /

void FUN_00138a82(HSAnimationModeController *self,SEL _cmd,id cancelFromPickImageAssistantPane)

{
  bool bVar1;
  SEL op;
  undefined4 uVar2;
  
  uVar2 = 0;
  _objc_msgSend(cancelFromPickImageAssistantPane,sel_setDelegate_,0);
  bVar1 = self->_state == 3;
  op = sel_finishAndApplyChanges_;
  if (bVar1) {
    _objc_msgSend(self->_pickImageAssistantPane,sel_autorelease,uVar2);
    self->_pickImageAssistantPane = (HSAnimationSetupPickImageAssistantPane *)0x0;
    _objc_msgSend(self,sel_setState_,2);
    op = sel_runEditPath_openMainAssistantPane_;
  }
  _objc_msgSend(self,op,(uint)bVar1);
  return;
}

*/
- (void)cancelFromPickImageAssistantPane:(id)aPane
{
    [aPane setDelegate:nil];
    if (_state == 3) {
        [_pickImageAssistantPane autorelease];
        _pickImageAssistantPane = nil;
        [self setState:2];
        [self runEditPath:YES openMainAssistantPane:YES];
    } else {
        [self finishAndApplyChanges:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00138b2c @ 00138b2c, 1053 bytes * /

void FUN_00138b2c(HSAnimationModeController *self,SEL _cmd,id pickMovie,id name,
                 id forPickImageAssistantPane)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  char cVar8;
  
  pvVar1 = _objc_msgSend(cls_NSMovie,sel_alloc);
  pvVar2 = _objc_msgSend(pickMovie,sel_quickTimeMovie);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithMovie_,pvVar2);
  if (pvVar1 != (id)0x0) {
    pvVar3 = _objc_msgSend(cls_HSMovieObject,sel_new,pvVar2);
    if (pvVar3 != (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_document,pvVar2);
      _objc_msgSend(pvVar3,sel_setSupport_,pvVar4);
      pvVar2 = _objc_msgSend(pvVar3,sel_undoManager);
      self_00 = _objc_msgSend(pvVar2,sel_retain);
      _objc_msgSend(self_00,sel_disableUndoRegistration);
      pvVar2 = _objc_msgSend(self,sel_undoManager);
      _objc_msgSend(pvVar2,sel_disableUndoRegistration);
      pvVar2 = name;
      _objc_msgSend(pvVar3,sel_setHyperMovie_name_,pvVar1,name);
      _objc_msgSend(pvVar3,sel_setHyperName_,name);
      if (self->_state == 0) {
        pvVar2 = _objc_msgSend(forPickImageAssistantPane,sel_assistant,name,pvVar2);
        pvVar5 = _objc_msgSend(pvVar2,sel_object);
        _objc_msgSend(self,sel_recreateDrawPathAssistantPane);
        pvVar6 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
        _objc_msgSend(pvVar6,sel_setSelectedInModelObjectAndBringAssistantToFront_,pvVar5);
        pvVar6 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
        _objc_msgSend(pvVar6,sel_setActive_explicitlyByUser_,1,0);
        pvVar6 = _objc_msgSend(self,sel_actionEventsForObject_,pvVar5);
        pvVar7 = _objc_msgSend(forPickImageAssistantPane,sel_objectAssistantNavigationController);
        _objc_msgSend(self,
                      sel_createAnimationForActingObject_actionEvents_animatedObject_assistant_assistantNavigationController_
                      ,pvVar5,pvVar6,pvVar3,pvVar2,pvVar7);
        _objc_msgSend(pvVar3,sel_setSupport_,pvVar4);
      }
      _objc_msgSend(self,sel_animationEditModePickTool_pickedObject_event_,0,pvVar3,0);
      pvVar2 = _objc_msgSend(pickMovie,sel_queryHyperInterface_,&DAT_0037379c);
      pvVar2 = _objc_msgSend(pvVar2,sel_media);
      pvVar2 = _objc_msgSend(pvVar2,sel_fullPathToMediaFileCreateIfNeeded_,1);
      pvVar4 = _objc_msgSend(cls_HSLibraryContentHelper,sel_shouldFileBeCreatedAsAnimationAtPath_,
                             pvVar2);
      if (((char)pvVar4 == '\0') &&
         (pvVar2 = _objc_msgSend(pickMovie,sel_isAnimatedGifMovie,pvVar2), (char)pvVar2 == '\0')) {
        cVar8 = '\x01';
      }
      else {
        cVar8 = '\0';
      }
      _objc_msgSend(pvVar3,sel_setMedia_,0);
      _objc_msgSend(pvVar3,sel_setSupport_,0);
      _objc_msgSend(pvVar3,sel_release);
      pvVar2 = (id)(int)cVar8;
      _objc_msgSend(self,sel_setIsMovieAnimation_,pvVar2);
      pvVar3 = _objc_msgSend(self,sel_mainAssistantPane);
      _objc_msgSend(pvVar3,sel_updateUI);
      _objc_msgSend(self_00,sel_enableUndoRegistration);
      pvVar3 = _objc_msgSend(self,sel_undoManager);
      _objc_msgSend(pvVar3,sel_enableUndoRegistration);
      _objc_msgSend(self_00,sel_release);
    }
    _objc_msgSend(pvVar1,sel_release,pvVar2);
    return;
  }
  return;
}

*/
- (void)pickMovie:(id)aMovie name:(id)aName forPickImageAssistantPane:(id)aPane
{
    HSMovie *movie = [[HSMovie alloc] initWithMovie:[aMovie QTMovie] error:NULL];
    if (movie == nil) {
        return;
    }
    id movieObject = [HSMovieObject new];
    if (movieObject != nil) {
        id support = [self document];
        [movieObject setSupport:support];
        NSUndoManager *objectUndoManager = [[movieObject undoManager] retain];
        [objectUndoManager disableUndoRegistration];
        [[self undoManager] disableUndoRegistration];
        [movieObject setHyperMovie:movie name:aName];
        [movieObject setHyperName:aName];
        if (_state == 0) {
            id assistant = [aPane assistant];
            id object = [assistant object];
            [self recreateDrawPathAssistantPane];
            [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:object];
            [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:NO];
            [self createAnimationForActingObject:object actionEvents:[self actionEventsForObject:object] animatedObject:movieObject assistant:assistant assistantNavigationController:[aPane objectAssistantNavigationController]];
            [movieObject setSupport:support];
        }
        [self animationEditModePickTool:nil pickedObject:movieObject event:nil];
        id media = [[aMovie queryHyperInterface:@protocol(HSMediaAttributes)] media];
        NSString *path = [media fullPathToMediaFileCreateIfNeeded:YES];
        BOOL isMovieAnimation = ![HSLibraryContentHelper shouldFileBeCreatedAsAnimationAtPath:path] && ![aMovie isAnimatedGifMovie];
        [movieObject setMedia:nil];
        [movieObject setSupport:nil];
        [movieObject release];
        [self setIsMovieAnimation:isMovieAnimation];
        [[self mainAssistantPane] updateUI];
        [objectUndoManager enableUndoRegistration];
        [[self undoManager] enableUndoRegistration];
        [objectUndoManager release];
    }
    [movie release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00138f49 @ 00138f49, 334 bytes * /

void FUN_00138f49(HSAnimationModeController *self,SEL _cmd,id pickCardObjectForAssistantPane,
                 id temporaryObject)

{
  id pvVar1;
  id self_00;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(self,sel_card);
  self_00 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(self_00,sel_disableUndoRegistration);
  _objc_msgSend(pvVar1,sel_removeHyperChild_,temporaryObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_enableUndoRegistration);
  puVar2 = sel_releaseTemporaryObject;
  pvVar1 = _objc_msgSend(pickCardObjectForAssistantPane,sel_respondsToSelector_,
                         sel_releaseTemporaryObject);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(pickCardObjectForAssistantPane,sel_releaseTemporaryObject,puVar2);
  }
  if (self->_state == 3) {
    _objc_msgSend(self->_pickImageAssistantPane,sel_release,puVar2);
    self->_pickImageAssistantPane = (HSAnimationSetupPickImageAssistantPane *)0x0;
  }
  else {
    _objc_msgSend(self,sel_setUpAnimation,puVar2);
    _objc_msgSend(self,sel_setUpUndoHelper);
    puVar2 = (undefined *)0x0;
    _objc_msgSend(self,sel_setState_,0);
  }
  pvVar1 = _objc_msgSend(pickCardObjectForAssistantPane,sel_assistant,puVar2);
  _objc_msgSend(self,sel_runPickCardObjectWithAssistant_,pvVar1);
  return;
}

*/
- (void)pickCardObjectForAssistantPane:(id)aPane temporaryObject:(id)aObject
{
    id card = [self card];
    [[card undoManager] disableUndoRegistration];
    [card removeHyperChild:aObject];
    [[card undoManager] enableUndoRegistration];
    if ([aPane respondsToSelector:@selector(releaseTemporaryObject)]) {
        [aPane releaseTemporaryObject];
    }
    if (_state == 3) {
        [_pickImageAssistantPane release];
        _pickImageAssistantPane = nil;
    } else {
        [self setUpAnimation];
        [self setUpUndoHelper];
        [self setState:0];
    }
    [self runPickCardObjectWithAssistant:[aPane assistant]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139097 @ 00139097, 180 bytes * /

id FUN_00139097(HSAnimationModeController *self,SEL _cmd,id lockedObjectAssistantController,
               id paneHistoryForObject)

{
  id pvVar1;
  undefined *self_00;
  SEL op;
  
  self_00 = cls_NSArray;
  switch(self->_state) {
  case 0:
  case 3:
    _objc_msgSend(self,sel_recreatePickImageAssistantPane);
    self_00 = cls_NSArray;
    op = sel_arrayWithObject_;
    break;
  case 1:
  case 4:
    _objc_msgSend(self,sel_recreateDrawPathAssistantPane);
    self_00 = cls_NSArray;
    op = sel_arrayWithObject_;
    break;
  default:
    op = sel_array;
    if (self->_state == 2) {
      _objc_msgSend(self,sel_mainAssistantPane);
      op = sel_arrayWithObject_;
    }
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)lockedObjectAssistantController:(id)aController paneHistoryForObject:(id)aObject
{
    switch (_state) {
        case 0:
        case 3:
            [self recreatePickImageAssistantPane];
            return [NSArray arrayWithObject:_pickImageAssistantPane];
        case 1:
        case 4:
            [self recreateDrawPathAssistantPane];
            return [NSArray arrayWithObject:_drawPathAssistantPane];
        case 2:
            return [NSArray arrayWithObject:[self mainAssistantPane]];
        default:
            return [NSArray array];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139160 @ 00139160, 206 bytes * /

id FUN_00139160(HSAnimationModeController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  undefined *self_00;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pcVar3 = (cfstringStruct *)&DAT_003736e8;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003736e8);
  puVar1 = cls_NSString;
  self_00 = cls_HSPlayAnimationAction;
  op = sel_localizedNameInInspector;
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(cls_HSPlayAnimationAction,sel_localizedNameInInspector,pcVar3);
    _objc_msgSend(pvVar2,sel_hyperName);
    pcVar3 = &cfstr________;
    self_00 = puVar1;
    op = sel_stringWithFormat_;
  }
  pvVar2 = _objc_msgSend(self_00,op,pcVar3);
  return pvVar2;
}

*/
- (id)assistantWindowTitle
{
    id named = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    if (named != nil) {
        return [NSString stringWithFormat:@"%@ : %@", [HSPlayAnimationAction localizedNameInInspector], [named hyperName]];
    }
    return [HSPlayAnimationAction localizedNameInInspector];
}

- (BOOL)isAnimationModeActive
{
    return [[[self document] modeSwitcher] activeModeController] == self;
}

- (id)actionEventsForObject:(id)aObject
{
    id self_00;

    self_00 = [self actionEvents];
    if ([self_00 count] == 0) {
        self_00 = [HSActor actionEventsForObject:aObject];
    }
    return self_00;
}

- (void)toggleObjectAssistantInspectorMode:(id)aMode
{
    [[[self document] mainWindowController] toggleObjectAssistantInspectorMode:aMode];
}

- (void)toggleObjectAssistant:(id)aAssistant
{
    [[[self document] mainWindowController] toggleObjectAssistant:aAssistant];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013938f @ 0013938f, 590 bytes * /

BOOL FUN_0013938f(HSAnimationModeController *self,SEL _cmd,id validateUserInterfaceItem)

{
  BOOL BVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  SEL op;
  
  puVar2 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  puVar5 = cls_HSEditorZoomController;
  if (sel_toggleObjectAssistant_ == puVar2) {
    pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    puVar5 = sel_setState_;
    pvVar4 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(pvVar3,sel_isActive,puVar5);
      puVar5 = (undefined *)(uint)((char)pvVar4 != '\0');
      _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar5);
    }
    pvVar4 = _objc_msgSend(pvVar3,sel_isActive,puVar5);
    if ((char)pvVar4 != '\0') {
      pvVar3 = _objc_msgSend(pvVar3,sel_canChangeActive,puVar5);
      return (BOOL)pvVar3;
    }
LAB_0013943f:
    BVar1 = '\x01';
  }
  else {
    if (sel_toggleObjectAssistantInspectorMode_ == puVar2) {
      pvVar3 = _objc_msgSend(self,sel_document);
      puVar5 = _objc_msgSend(pvVar3,sel_mainWindowController);
      op = sel_validateUserInterfaceItem_;
    }
    else if (puVar2 == sel_zoomIn_) {
      _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
      op = sel_canZoomInForZoomFactor_;
    }
    else if (puVar2 == sel_zoomOut_) {
      _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
      op = sel_canZoomOutForZoomFactor_;
    }
    else if (puVar2 == sel_zoomToActualSize_) {
      _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
      op = sel_canZoomToActualSizeForZoomFactor_;
    }
    else {
      if (puVar2 == sel_fitInWindow_) {
        pvVar3 = _objc_msgSend(self->_cardView,sel_zoomMode);
        return pvVar3 != (id)0x1;
      }
      if ((sel_zoomToMinScaleFactor_ == puVar2) || (sel_zoomToMaxScaleFactor_ == puVar2))
      goto LAB_0013943f;
      if (sel_undo_ != puVar2) {
        if (sel_redo_ != puVar2) {
          return '\0';
        }
        pvVar3 = _objc_msgSend(self,sel_preferedUndoManager);
        pvVar3 = _objc_msgSend(pvVar3,sel_canRedo);
        return (BOOL)pvVar3;
      }
      puVar5 = _objc_msgSend(self,sel_preferedUndoManager);
      op = sel_canUndo;
    }
    pvVar3 = _objc_msgSend(puVar5,op);
    BVar1 = (BOOL)pvVar3;
  }
  return BVar1;
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    if (action == @selector(toggleObjectAssistant:)) {
        HSObjectAssistantController *controller = [HSObjectAssistantController sharedAssistantController];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[controller isActive] ? 1 : 0];
        }
        if ([controller isActive]) {
            return [controller canChangeActive];
        }
        return YES;
    }
    if (action == @selector(toggleObjectAssistantInspectorMode:)) {
        return [[[self document] mainWindowController] validateUserInterfaceItem:aItem];
    }
    if (action == @selector(zoomIn:)) {
        return [HSEditorZoomController canZoomInForZoomFactor:[_cardView zoomFactor]];
    }
    if (action == @selector(zoomOut:)) {
        return [HSEditorZoomController canZoomOutForZoomFactor:[_cardView zoomFactor]];
    }
    if (action == @selector(zoomToActualSize:)) {
        return [HSEditorZoomController canZoomToActualSizeForZoomFactor:[_cardView zoomFactor]];
    }
    if (action == @selector(fitInWindow:)) {
        return [_cardView zoomMode] != 1;
    }
    if (action == @selector(zoomToMinScaleFactor:) || action == @selector(zoomToMaxScaleFactor:)) {
        return YES;
    }
    if (action == @selector(undo:)) {
        return [[self preferedUndoManager] canUndo];
    }
    if (action == @selector(redo:)) {
        return [[self preferedUndoManager] canRedo];
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001395dd @ 001395dd, 389 bytes * /

void FUN_001395dd(HSAnimationModeController *self,SEL _cmd,id openAssistantPaneAsInitialIfNeeded,
                 id withIdentifier)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  
  if (self->_assistantNavigationController == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentPane);
    pvVar1 = _objc_msgSend(pvVar1,sel_modalViewController);
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithRootViewController_identifier_,
                           openAssistantPaneAsInitialIfNeeded,withIdentifier);
    self_00 = _objc_msgSend(self,sel_assistant);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self_00,sel_currentPane,openAssistantPaneAsInitialIfNeeded,
                             withIdentifier);
      _objc_msgSend(pvVar1,sel_presentModalViewController_animated_,pvVar2,1);
      _objc_msgSend(self,sel_setAssistantNavigationController_,pvVar2);
      _objc_msgSend(pvVar2,sel_release);
      self->_revertMode = 1;
    }
    else {
      _objc_msgSend(self_00,sel_openAssistantPane_,pvVar2,withIdentifier);
      _objc_msgSend(self,sel_setAssistantNavigationController_,pvVar2);
      _objc_msgSend(pvVar2,sel_release);
      self->_revertMode = 2;
    }
  }
  else {
    _objc_msgSend(self,sel_pushAnimationViewController_withIdentifier_,
                  openAssistantPaneAsInitialIfNeeded,withIdentifier);
  }
  return;
}

*/
- (void)openAssistantPaneAsInitialIfNeeded:(id)aNeeded withIdentifier:(id)aIdentifier
{
    if (_assistantNavigationController == nil) {
        id modalViewController = [[[self assistant] currentPane] modalViewController];
        id navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:aNeeded identifier:aIdentifier];
        if (modalViewController == nil) {
            [[[self assistant] currentPane] presentModalViewController:navigationController animated:YES];
            [self setAssistantNavigationController:navigationController];
            [navigationController release];
            _revertMode = 1;
        } else {
            [[self assistant] openAssistantPane:navigationController];
            [self setAssistantNavigationController:navigationController];
            [navigationController release];
            _revertMode = 2;
        }
    } else {
        [self pushAnimationViewController:aNeeded withIdentifier:aIdentifier];
    }
}

- (void)pushAnimationViewController:(id)aController
{
    [self pushAnimationViewController:aController withIdentifier:@"HSAnimationModePane"];
}

- (void)pushAnimationViewController:(id)aController withIdentifier:(id)aIdentifier
{
    [_assistantNavigationController pushViewController:aController withIdentifier:aIdentifier animate:YES replacePrevious:NO];
}

- (void)cleanupTemporaryAnimationAssistantPanes
{
    [_assistantNavigationController removeAllViewControllersWithIdentifier:@"HSAnimationModeTempPane"];
}

- (void)lockAssistantIfNeeded
{
    id self_00;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    if (![self_00 isLocked]) {
        [self_00 setLocked:YES delegate:self];
    }
}

- (void)unlockAssistantIfNeeded
{
    id self_00;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    if ([self_00 isLocked]) {
        [self_00 setLocked:NO delegate:nil];
    }
}

- (id)assistant
{
    return _assistant;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001398e0 @ 001398e0, 65 bytes * /

void FUN_001398e0(HSAnimationModeController *self,SEL _cmd,id mouseMoved)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(self_00,sel_handleMouseMoved_,mouseMoved);
  return;
}

*/
- (void)mouseMoved:(id)aMoved
{
    [[self cardView] handleMouseMoved:aMoved];
}

- (void)setState:(NSInteger)aState
{
    _state = aState;
}

- (id)card
{
    return [_cardView card];
}

- (id)selectToolWithTag:(NSInteger)aTag
{
    [[HSToolManager sharedToolManager] selectToolWithTag:aTag setAsPermanent:YES forceSelection:YES];
    return [[HSToolManager sharedToolManager] currentTool];
}

- (void)resetToolToDefault
{
    [self selectToolWithTag:0];
}

- (id)cardView
{
    return _cardView;
}

- (id)actor
{
    return [_actingObject queryHyperInterface:@protocol(HSActor)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139a29 @ 00139a29, 223 bytes * /

void FUN_00139a29(HSAnimationModeController *self,SEL _cmd,BOOL setBottomToolbarVisible)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  HSAnimationModeController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_00351530;
  _objc_msgSendSuper(&local_1c,sel_setBottomToolbarVisible_,(int)setBottomToolbarVisible);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_editorWindowController);
  pvVar2 = _objc_msgSend(self,sel_window);
  if (setBottomToolbarVisible == 0) {
    pvVar3 = self->_bottomAreaTintedView;
    pvVar6 = (id)0x1;
    op = sel_hideIfNeededBottomToolbarView_mainAreaTintedView_mainWindow_animated_;
    pvVar4 = self->_mainAreaTintedView;
    pvVar5 = pvVar2;
  }
  else {
    pvVar3 = self->_bottomAreaTintedView;
    op = sel_showIfNeededBottomToolbarView_workAreaView_mainAreaTintedView_mainWindow_animated_;
    pvVar4 = self->_workAreaView;
    pvVar5 = self->_mainAreaTintedView;
    pvVar6 = pvVar2;
  }
  _objc_msgSend(pvVar1,op,pvVar3,pvVar4,pvVar5,pvVar6);
  return;
}

*/
- (void)setBottomToolbarVisible:(BOOL)aVisible
{
    [super setBottomToolbarVisible:aVisible];
    id editorWindowController = [[self document] editorWindowController];
    NSWindow *window = [self window];
    if (!aVisible) {
        [editorWindowController hideIfNeededBottomToolbarView:_bottomAreaTintedView mainAreaTintedView:_mainAreaTintedView mainWindow:window animated:YES];
    } else {
        [editorWindowController showIfNeededBottomToolbarView:_bottomAreaTintedView workAreaView:_workAreaView mainAreaTintedView:_mainAreaTintedView mainWindow:window animated:YES];
    }
}

- (void)setMainAreaTintedView:(id)aView
{
    _mainAreaTintedView = aView;
}

- (void)setBottomAreaTintedView:(id)aView
{
    _bottomAreaTintedView = aView;
}

- (void)setWorkAreaView:(id)aView
{
    _workAreaView = aView;
}

- (void)saveEditingState
{

}

- (id)modeSwitcherCardView:(id)aView
{
    return [self cardView];
}

- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible
{
    return YES;
}

- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding
{
    return NO;
}

- (id)secondaryModeSwitcherWindows:(id)aWindows
{
    return [[super secondaryModeSwitcherWindows:aWindows] arrayByAddingObjectsFromArray:[HSEditorWindowController palettesArrayIncludingLibrary:YES toolPalette:YES layoutPalette:NO objectListPalette:NO commentsAndAttributionsPalette:NO shortcutsPalette:NO]];
}

- (id)modeSwitcherWindowController:(id)aController
{
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139bce @ 00139bce, 226 bytes * /

id FUN_00139bce(HSAnimationModeController *self,SEL _cmd,id modeSwitcherView)

{
  HSAnimationModeController *pHVar1;
  id pvVar2;
  SEL op;
  
  pHVar1 = _objc_msgSend(modeSwitcherView,sel_previousModeController);
  if (pHVar1 == self) {
    pvVar2 = _objc_msgSend(modeSwitcherView,sel_activeModeController);
    pvVar2 = _objc_msgSend(pvVar2,sel_ownsScrollViewForModeSwitcherViewEmbedding);
    op = sel_cardView;
    if ((char)pvVar2 != '\0') goto LAB_00139ca3;
  }
  pvVar2 = _objc_msgSend(modeSwitcherView,sel_previousModeController);
  pvVar2 = _objc_msgSend(pvVar2,sel_ownsScrollViewForModeSwitcherViewEmbedding);
  if (((char)pvVar2 == '\0') ||
     (pHVar1 = _objc_msgSend(modeSwitcherView,sel_activeModeController), op = sel_cardView,
     pHVar1 != self)) {
    pvVar2 = _objc_msgSend(self,sel_document);
    self = _objc_msgSend(pvVar2,sel_editorWindowController);
    op = sel_modeSwitcherView_;
  }
LAB_00139ca3:
  pvVar2 = _objc_msgSend(self,op);
  return pvVar2;
}

*/
- (id)modeSwitcherView:(id)aView
{
    if ([aView previousModeController] == self && [[aView activeModeController] ownsScrollViewForModeSwitcherViewEmbedding]) {
        return [self cardView];
    }
    if ([[aView previousModeController] ownsScrollViewForModeSwitcherViewEmbedding] && [aView activeModeController] == self) {
        return [self cardView];
    }
    return [[[self document] editorWindowController] modeSwitcherView:aView];
}

- (id)targetForScalePopUpButton:(id)aButton inStatusbarController:(id)aController
{
    return _cardView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139cb0 @ 00139cb0, 125 bytes * /

void FUN_00139cb0(HSAnimationModeController *self,SEL _cmd,id cardViewDidChangeZoomFactor)

{
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(cardViewDidChangeZoomFactor,sel_object);
  dVar2 = _objc_msgSend_fpret(pvVar1,sel_zoomFactor);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_mainWindowController);
  _objc_msgSend(pvVar1,sel_activeCardViewDidChangeZoomFactor_,(float)dVar2);
  return;
}

*/
- (void)cardViewDidChangeZoomFactor:(id)aFactor
{
    [[[self document] mainWindowController] activeCardViewDidChangeZoomFactor:[[aFactor object] zoomFactor]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139d2d @ 00139d2d, 246 bytes * /

void FUN_00139d2d(HSAnimationModeController *self,SEL _cmd,id zoomFactorDidChange)

{
  float fVar1;
  longdouble lVar2;
  float fVar3;
  float fVar4;
  double dVar5;
  SEL op;
  float fVar6;
  
  dVar5 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_zoomFactorValueFrom_,
                              zoomFactorDidChange);
  fVar6 = (float)dVar5;
  dVar5 = _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
  fVar1 = (float)dVar5;
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar3 = ABS(fVar6);
  }
  else {
    fVar3 = 1.0;
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar4 = ABS(fVar1);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= fVar3) {
    fVar4 = fVar3;
  }
  if (ABS(fVar6 - fVar1) <= fVar4 * 0.0005) {
    lVar2 = (longdouble)_HSLinearValueForSliderFromNonLinear(zoomFactorDidChange,fVar1);
    fVar6 = (float)lVar2;
    op = sel_setFloatValue_;
  }
  else {
    zoomFactorDidChange = self->_cardView;
    op = sel_zoomToFactor_;
  }
  _objc_msgSend(zoomFactorDidChange,op,fVar6);
  return;
}

*/
- (void)zoomFactorDidChange:(id)aChange
{
    float requestedZoom = [HSEditorZoomController zoomFactorValueFrom:aChange];
    float currentZoom = [_cardView zoomFactor];
    float scale = MAX((requestedZoom != 0.0f) ? fabsf(requestedZoom) : 1.0f, (currentZoom != 0.0f) ? fabsf(currentZoom) : 1.0f);
    if (fabsf(requestedZoom - currentZoom) <= scale * 0.0005f) {
        // The slider already shows the current zoom: it is only synchronized with the non-linear scale.
        [aChange setFloatValue:HSLinearValueForSliderFromNonLinear(aChange, currentZoom)];
    } else {
        [_cardView zoomToFactor:requestedZoom];
    }
}

- (void)zoomToMaxScaleFactor:(id)aFactor
{
    [_cardView zoomToFactor:(float)[HSEditorZoomController maxZoomFactor]];
}

- (void)zoomToMinScaleFactor:(id)aFactor
{
    [_cardView zoomToFactor:(float)[HSEditorZoomController minZoomFactor]];
}

- (void)fitInWindow:(id)aWindow
{
    [_cardView fitInWindow];
}

- (void)zoomToActualSize:(id)aSize
{
    [_cardView zoomToActualSize];
}

- (void)zoomOut:(id)aOut
{
    [_cardView zoomOut];
}

- (void)zoomIn:(id)aIn
{
    [_cardView zoomIn];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139f59 @ 00139f59, 158 bytes * /

void FUN_00139f59(HSAnimationModeController *self,SEL _cmd,BOOL updateUI)

{
  id pvVar1;
  int iVar2;
  char cVar3;
  
  if (self->_state - 3U < 2) {
LAB_00139f76:
    cVar3 = '\0';
  }
  else {
    if (self->_state == 2) {
      pvVar1 = _objc_msgSend(self->_tryItAnimation,sel_isPlaying);
      if ((char)pvVar1 != '\0') goto LAB_00139f76;
    }
    cVar3 = '\x01';
  }
  pvVar1 = _objc_msgSend(self,sel_mainAssistantPane);
  iVar2 = (int)cVar3;
  _objc_msgSend(pvVar1,sel_setPlayTryItAnimation_,iVar2);
  if (updateUI != '\0') {
    pvVar1 = _objc_msgSend(self,sel_mainAssistantPane,iVar2);
    _objc_msgSend(pvVar1,sel_updateUI);
  }
  return;
}

*/
- (void)updateUI:(BOOL)aUI
{
    BOOL canPlay = YES;
    if (_state == 3 || _state == 4) {
        canPlay = NO;
    } else if (_state == 2 && [_tryItAnimation isPlaying]) {
        canPlay = NO;
    }
    [[self mainAssistantPane] setPlayTryItAnimation:canPlay];
    if (aUI) {
        [[self mainAssistantPane] updateUI];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00139ff7 @ 00139ff7, 161 bytes * /

void FUN_00139ff7(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  undefined8 local_1c [2];
  
  pvVar1 = _objc_msgSend(self->_tryItAnimation,sel_playMovie);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_tryItAnimation,sel_animatedObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend_stret(local_1c,pvVar1,sel_hyperPlayRange);
      _objc_msgSend(pvVar1,sel_setHyperCurrentTime_,local_1c[0]);
    }
  }
  return;
}

*/
- (void)resetMovieTimeIfNecessary
{
    if ([_tryItAnimation playMovie]) {
        id playable = [[_tryItAnimation animatedObject] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
        if (playable != nil) {
            [playable setHyperCurrentTime:[playable hyperPlayRange].location];
        }
    }
}

- (void)playStop:(id)aStop
{
    id self_00;
    BOOL bVar3;
    id pvVar1_5;

    bVar3 = ![_tryItAnimation isPlaying];
    if (bVar3) {
        [self resetMovieTimeIfNecessary];
        [[self cardView] selectHyperObjects:nil];
        [self selectToolWithTag:0x38];
        [self updateAnimatedObjectFromTryItAnimation];
        [_tryItAnimation setSuppressDontErase:NO];
        [[self undoManager] disableUndoRegistration];
        self_00 = [[self card] animationController];
        pvVar1_5 = _actingObject;
        [self_00 changeObjectIndexOnStartingAnimation:_tryItAnimation inAbsoluteLayer:[_tryItAnimation goingAbsoluteLayer] forActingObject:pvVar1_5];
        [_tryItAnimation start:1];
        [[self undoManager] enableUndoRegistration];
    }
    else {
        [_tryItAnimation stop];
        [self runEditPath];
    }
    [self updateUI:(unsigned int)!bVar3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013a29c @ 0013a29c, 155 bytes * /

void FUN_0013a29c(HSAnimationModeController *self,SEL _cmd,id newPath)

{
  id self_00;
  id pvVar1;
  
  _objc_msgSend(self,sel_updateAnimatedObjectFromTryItAnimation);
  _objc_msgSend(self,sel_cleanUpTryItAnimation);
  _objc_msgSend(self,sel_setState_,4);
  self_00 = self->_animation;
  pvVar1 = _objc_msgSend(cls_HSAnimationOptions,sel_undefinedTimesPerSecond);
  _objc_msgSend(self_00,sel_setTimesPerSecond_,pvVar1);
  _objc_msgSend(self,sel_runDrawPath);
  return;
}

*/
- (void)newPath:(id)aPath
{
    [self updateAnimatedObjectFromTryItAnimation];
    [self cleanUpTryItAnimation];
    [self setState:4];
    [_animation setTimesPerSecond:[HSAnimationOptions undefinedTimesPerSecond]];
    [self runDrawPath];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013a337 @ 0013a337, 272 bytes * /

void FUN_0013a337(HSAnimationModeController *self,SEL _cmd,NSSize useAnimatedObjectSize,
                 CGAffineTransform affineTransform,id actionName)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self->_tryItAnimation,sel_animatedObject);
  _objc_msgSend(self,sel_registerUndoGeometryChangesOfAnimatedObject_withActionName_,pvVar1,
                actionName);
  pvVar2 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar2,sel_disableUndoRegistration);
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00373468);
  _objc_msgSend(pvVar2,sel_setSize_affineTransform_,useAnimatedObjectSize.width,
                useAnimatedObjectSize.height,affineTransform._0_8_,affineTransform._8_8_,
                affineTransform._16_8_);
  _objc_msgSend(self->_tryItAnimation,sel_updateObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_enableUndoRegistration);
  return;
}

*/
- (void)useAnimatedObjectSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform actionName:(id)aName
{
    id animatedObject = [_tryItAnimation animatedObject];
    [self registerUndoGeometryChangesOfAnimatedObject:animatedObject withActionName:aName];
    [[animatedObject undoManager] disableUndoRegistration];
    [[animatedObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)] setSize:aSize affineTransform:aTransform];
    [_tryItAnimation updateObject];
    [[animatedObject undoManager] enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013a447 @ 0013a447, 299 bytes * /

void FUN_0013a447(HSAnimationModeController *self,SEL _cmd,
                 id registerUndoGeometryChangesOfAnimatedObject,id withActionName)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  if (withActionName != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_undoManager);
    _objc_msgSend(pvVar1,sel_setActionName_,withActionName);
  }
  pvVar1 = _objc_msgSend(registerUndoGeometryChangesOfAnimatedObject,sel_queryHyperInterface_,
                         &DAT_00373468);
  pvVar2 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_prepareWithInvocationTarget_,self);
  _objc_msgSend_stret(&local_2c,pvVar1,sel_affineTransform);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  _objc_msgSend(pvVar2,sel_useAnimatedObjectSize_affineTransform_actionName_,pvVar1,extraout_EDX,
                local_2c,local_24,local_1c,withActionName);
  _objc_msgSend(self->_undoHelper,sel_duplicateAction);
  return;
}

*/
- (void)registerUndoGeometryChangesOfAnimatedObject:(id)aObject withActionName:(id)aName
{
    if (aName != nil) {
        [[self undoManager] setActionName:aName];
    }
    id geometry = [aObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    [[[self undoManager] prepareWithInvocationTarget:self] useAnimatedObjectSize:[geometry size] affineTransform:[geometry affineTransform] actionName:aName];
    [_undoHelper duplicateAction];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013a572 @ 0013a572, 421 bytes * /

void FUN_0013a572(HSAnimationModeController *self,SEL _cmd,id replaceAnimatedObject,id with,
                 BOOL undoRegistrationOnly)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  undefined8 uVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Change_Animated_Object
                         ,&cfstr_empty,&cfstr_UndoManager);
  _objc_msgSend(pvVar1,sel_setActionName_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareWithInvocationTarget_,self);
  uVar4 = CONCAT44(replaceAnimatedObject,with);
  uVar5 = 0;
  _objc_msgSend(pvVar1,sel_replaceAnimatedObject_with_undoRegistrationOnly_,with,
                replaceAnimatedObject,0);
  _objc_msgSend(self->_undoHelper,sel_duplicateAction);
  if (undoRegistrationOnly == '\0') {
    _objc_msgSend(self->_tryItAnimation,sel_stop,uVar4,uVar5);
    _objc_msgSend(self->_animation,sel_setAnimatedObject_,with);
    dVar3 = _objc_msgSend_fpret(self->_tryItAnimation,sel_pathTime);
    _objc_msgSend(self,sel_setUpTryItAnimation);
    _objc_msgSend(self->_tryItAnimation,sel_setPathTime_,dVar3);
    _objc_msgSend(self,sel_updateAnimationPlayMovie);
    _objc_msgSend(self,sel_updateUI_,1);
  }
  return;
}

*/
- (void)replaceAnimatedObject:(id)aObject with:(id)aWith undoRegistrationOnly:(BOOL)aOnly
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Animated Object" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] replaceAnimatedObject:aWith with:aObject undoRegistrationOnly:NO];
    [_undoHelper duplicateAction];
    if (!aOnly) {
        [_tryItAnimation stop];
        [_animation setAnimatedObject:aWith];
        double pathTime = [_tryItAnimation pathTime];
        [self setUpTryItAnimation];
        [_tryItAnimation setPathTime:pathTime];
        [self updateAnimationPlayMovie];
        [self updateUI:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013a717 @ 0013a717, 626 bytes * /

void FUN_0013a717(HSAnimationModeController *self,SEL _cmd,id replacePath,id keyFrames,id withPath,
                 id keyFrames4,BOOL undoRegistrationOnly)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  double dVar3;
  double dVar4;
  undefined8 uVar5;
  undefined4 uVar6;
  double local_34;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareWithInvocationTarget_,self);
  uVar5 = CONCAT44(keyFrames4,withPath);
  uVar6 = 0;
  _objc_msgSend(pvVar1,sel_replacePath_keyFrames_withPath_keyFrames_undoRegistrationOnly_,withPath,
                keyFrames4,replacePath,keyFrames,0);
  _objc_msgSend(self->_undoHelper,sel_duplicateAction);
  if (undoRegistrationOnly == '\0') {
    _objc_msgSend(self->_tryItAnimation,sel_stop,uVar5,replacePath,keyFrames,uVar6);
    _objc_msgSend(self->_animation,sel_setPath_keyFrames_,withPath,keyFrames4);
    _objc_msgSend(self->_tryItAnimation,sel_setPath_keyFrames_,withPath,keyFrames4);
    pvVar1 = _objc_msgSend(cls_HSAnimationFixation,sel_new);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    pvVar2 = _objc_msgSend(self->_tryItAnimation,sel_pathPointAtTime_,0,0);
    uVar6 = extraout_EDX;
    _objc_msgSend(pvVar1,sel_setObjectPositionAtZeroTime_,pvVar2,extraout_EDX);
    pvVar2 = _objc_msgSend(self->_tryItAnimation,sel_positioning);
    uVar5 = CONCAT44(uVar6,pvVar1);
    _objc_msgSend(pvVar2,sel_replaceFixationWith_,pvVar1);
    dVar3 = _objc_msgSend_fpret(self->_tryItAnimation,sel_pathTime);
    local_34 = 0.0;
    if ((0.0 <= dVar3) &&
       (dVar4 = _objc_msgSend_fpret(self->_tryItAnimation,sel_duration), local_34 = dVar3,
       dVar4 < dVar3)) {
      local_34 = _objc_msgSend_fpret(self->_tryItAnimation,sel_duration);
    }
    _objc_msgSend(self,sel_updatePathInEditPathTool,uVar5);
    _objc_msgSend(self->_tryItAnimation,sel_setPathTime_,local_34);
    _objc_msgSend(self,sel_updateUI_,1);
  }
  return;
}

*/
- (void)replacePath:(id)aPath keyFrames:(id)aFrames withPath:(id)aPath2 keyFrames:(id)aFrames2 undoRegistrationOnly:(BOOL)aOnly
{
    [[[self undoManager] prepareWithInvocationTarget:self] replacePath:aPath2 keyFrames:aFrames2 withPath:aPath keyFrames:aFrames undoRegistrationOnly:NO];
    [_undoHelper duplicateAction];
    if (!aOnly) {
        [_tryItAnimation stop];
        [_animation setPath:aPath2 keyFrames:aFrames2];
        [_tryItAnimation setPath:aPath2 keyFrames:aFrames2];
        HSAnimationFixation *fixation = [[HSAnimationFixation new] autorelease];
        [fixation setObjectPositionAtZeroTime:[_tryItAnimation pathPointAtTime:0]];
        [[_tryItAnimation positioning] replaceFixationWith:fixation];
        double pathTime = [_tryItAnimation pathTime];
        double clamped = 0.0;
        if (pathTime >= 0.0) {
            clamped = pathTime;
            if ([_tryItAnimation duration] < pathTime) {
                clamped = [_tryItAnimation duration];
            }
        }
        [self updatePathInEditPathTool];
        [_tryItAnimation setPathTime:clamped];
        [self updateUI:YES];
    }
}

- (void)applyPathAndKeyFramesChanges
{
    id pvVar1_3;

    pvVar1_3 = [[[_animation pathKeyFrames] copy] autorelease];
    [self replacePath:_storedPath keyFrames:_storedKeyFrames withPath:[[[_animation path] copy] autorelease] keyFrames:pvVar1_3 undoRegistrationOnly:YES];
}

- (void)storeCurrentPathAndKeyFrames
{
    [_storedPath release];
    [_storedKeyFrames release];
    _storedPath = [[_animation path] copy];
    _storedKeyFrames = [[_animation pathKeyFrames] copy];
}

- (void)animationPlaybackDirectionDidChange:(id)aChange
{
    [self recreateTryItAnimationOnAnimationOptionsChange];
}

- (void)HSAnimationModeController_animationAbsoluteLayerDidChange:(id)aChange
{
    [self recreateTryItAnimationOnAnimationOptionsChange];
}

- (void)recreateTryItAnimationOnAnimationOptionsChange
{
    [self updateAnimatedObjectFromTryItAnimation];
    [self setUpTryItAnimation];
}

- (void)animationPlaybackDidEnd:(id)aEnd
{
    [self runEditPath:YES openMainAssistantPane:NO];
}

- (void)updateAnimatedObjectFromTryItAnimation
{
    id pvVar1_3;

    pvVar1_3 = [[[_tryItAnimation animatedObject] localCopyIncludingNodeUnits:YES] autorelease];
    [pvVar1_3 setDraggable:NO];
    [pvVar1_3 setResizable:NO];
    [pvVar1_3 setRotatable:NO];
    [_animation setAnimatedObject:pvVar1_3];
}

- (void)setUpTryItAnimation
{
    id pvVar1_7;

    if ([_animation animatedObject] != nil) {
        [self cleanUpTryItAnimation];
        [[[self card] animationController] prepareForTryItAnimation:_animation];
        pvVar1_7 = [[[[self card] animationController] prepareToStartAnimation:_animation forActingObject:_actingObject] retain];
        _tryItAnimation = pvVar1_7;
        [pvVar1_7 setSuppressDontErase:YES];
        [_tryItAnimation prepareAnimation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationPlaybackDidEnd:) name:HSAnimationPlaybackDidEndNotification object:_tryItAnimation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSAnimationModeController_animationAbsoluteLayerDidChange:) name:HSAnimationAbsoluteLayerDidChangeNotification object:_tryItAnimation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationPlaybackDirectionDidChange:) name:HSAnimationPlaybackDirectionDidChangeNotification object:_tryItAnimation];
        [[self cardView] selectHyperObject:[_tryItAnimation animatedObject]];
        [[_tryItAnimation animatedObject] addObserver:self selector:@selector(tryItAnimatedObjectGeometryChanged:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013af19 @ 0013af19, 492 bytes * /

void FUN_0013af19(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSAnimationModeController *pHVar3;
  undefined *puVar4;
  undefined4 uVar5;
  undefined *puVar6;
  
  if (self->_tryItAnimation != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_tryItAnimation,sel_animatedObject);
    _objc_msgSend(self->_tryItAnimation,sel_stop);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003365d4,
                  self->_tryItAnimation);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003365c8,
                  self->_tryItAnimation);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003365d8,
                  self->_tryItAnimation);
    puVar6 = &DAT_00373454;
    uVar5 = *(undefined4 *)PTR_003363bc;
    pHVar3 = self;
    puVar4 = sel_tryItAnimatedObjectGeometryChanged_;
    _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                  sel_tryItAnimatedObjectGeometryChanged_,uVar5,&DAT_00373454);
    if ((self->_applyChanges[0] & 8) != 0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_undoManager,pHVar3,puVar4,uVar5,puVar6);
      _objc_msgSend(pvVar1,sel_enableUndoRegistration);
      self->_applyChanges[0] = self->_applyChanges[0] & 0xf7;
    }
    _objc_msgSend(self->_tryItAnimation,sel_release,pHVar3,puVar4,uVar5,puVar6);
    self->_tryItAnimation = (id)0x0;
    pvVar1 = _objc_msgSend(self,sel_card);
    pvVar1 = _objc_msgSend(pvVar1,sel_animationController);
    _objc_msgSend(pvVar1,sel_cleanUpAfterTryIt);
  }
  return;
}

*/
- (void)cleanUpTryItAnimation
{
    if (_tryItAnimation != nil) {
        id animatedObject = [_tryItAnimation animatedObject];
        [_tryItAnimation stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationPlaybackDidEndNotification object:_tryItAnimation];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationAbsoluteLayerDidChangeNotification object:_tryItAnimation];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationPlaybackDirectionDidChangeNotification object:_tryItAnimation];
        [animatedObject removeObserver:self selector:@selector(tryItAnimatedObjectGeometryChanged:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
        if (_isBlockingUndoRegistration) {
            [[animatedObject undoManager] enableUndoRegistration];
            _isBlockingUndoRegistration = NO;
        }
        [_tryItAnimation release];
        _tryItAnimation = nil;
        [[[self card] animationController] cleanUpAfterTryIt];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013b105 @ 0013b105, 535 bytes * /

void FUN_0013b105(HSAnimationModeController *self,SEL _cmd,id tryItAnimatedObjectGeometryChanged)

{
  byte bVar1;
  id pvVar2;
  id self_00;
  cfstringStruct *pcVar3;
  SEL op;
  
  pvVar2 = _objc_msgSend(tryItAnimatedObjectGeometryChanged,sel_attributeChange);
  if (pvVar2 == (id)0x80) {
    self = self->_tryItAnimation;
    op = sel_updateObject;
  }
  else {
    if (pvVar2 != (id)0x40) {
      if ((*(uint *)PTR_00336020 & (uint)pvVar2) != 0) {
        if ((self->_applyChanges[0] & 8) != 0) {
          return;
        }
        pvVar2 = _objc_msgSend(self->_tryItAnimation,sel_animatedObject);
        pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
        _objc_msgSend(pvVar2,sel_disableUndoRegistration);
        self->_applyChanges[0] = self->_applyChanges[0] | 8;
        return;
      }
      if ((*(uint *)PTR_0033601c & (uint)pvVar2) == 0) {
        return;
      }
      bVar1 = self->_applyChanges[0];
      if ((bVar1 & 0x10) == 0) {
        self->_applyChanges[0] = bVar1 | 0x10;
        _objc_msgSend(self->_tryItAnimation,sel_updateObject);
        bVar1 = self->_applyChanges[0] & 0xef;
        self->_applyChanges[0] = bVar1;
      }
      if ((bVar1 & 8) == 0) {
        return;
      }
      pvVar2 = _objc_msgSend(self->_tryItAnimation,sel_animatedObject);
      pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
      _objc_msgSend(pvVar2,sel_enableUndoRegistration);
      self->_applyChanges[0] = self->_applyChanges[0] & 0xf7;
      return;
    }
    pvVar2 = _objc_msgSend(tryItAnimatedObjectGeometryChanged,sel_attributeProtocolSet);
    pvVar2 = _objc_msgSend(pvVar2,sel_containsProtocol_,&DAT_0037342c);
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    if ((char)pvVar2 == '\0') {
      pcVar3 = &cfstr_Resize;
    }
    else {
      pcVar3 = &cfstr_Rotation;
    }
    _objc_msgSend(self_00,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,
                  &cfstr_UndoManager);
    _objc_msgSend(self->_tryItAnimation,sel_animatedObject);
    op = sel_registerUndoGeometryChangesOfAnimatedObject_withActionName_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)tryItAnimatedObjectGeometryChanged:(id)aChanged
{
    NSUInteger change = [aChanged attributeChange];
    if (change == 0x80) {
        [_tryItAnimation updateObject];
        return;
    }
    if (change == 0x40) {
        BOOL isRotation = [[aChanged attributeProtocolSet] containsProtocol:@protocol(HSRotationAngleAttribute)];
        NSString *name = [[NSBundle mainBundle] localizedStringForKey:(isRotation ? @"Rotation" : @"Resize") value:@"" table:@"UndoManager"];
        [self registerUndoGeometryChangesOfAnimatedObject:[_tryItAnimation animatedObject] withActionName:name];
        return;
    }
    if (HSActualWillAttributeChanges & change) {
        if (_isBlockingUndoRegistration) {
            return;
        }
        [[[_tryItAnimation animatedObject] undoManager] disableUndoRegistration];
        _isBlockingUndoRegistration = YES;
        return;
    }
    if ((HSActualDidAttributeChanges & change) == 0) {
        return;
    }
    if (!_ignoreObjectGeometryChanges) {
        _ignoreObjectGeometryChanges = YES;
        [_tryItAnimation updateObject];
        _ignoreObjectGeometryChanges = NO;
    }
    if (_isBlockingUndoRegistration) {
        [[[_tryItAnimation animatedObject] undoManager] enableUndoRegistration];
        _isBlockingUndoRegistration = NO;
    }
}

- (void)updatePathInEditPathTool
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x37) {
        [[[HSToolManager sharedToolManager] currentTool] updatePath];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013b39a @ 0013b39a, 80 bytes * /

void FUN_0013b39a(HSAnimationModeController *self,SEL _cmd,NSRect updateAnimationPathBounds,
                 id forEditPathTool)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(self_00,sel_setAdditionalContentBoundingRect_,updateAnimationPathBounds.origin,
                updateAnimationPathBounds.size);
  return;
}

*/
- (void)updateAnimationPathBounds:(NSRect)aBounds forEditPathTool:(id)aTool
{
    [[self cardView] setAdditionalContentBoundingRect:aBounds];
}

- (void)editingFinishedForEditPathTool:(id)aTool
{
    [self resetToolToDefault];
    [self setState:2];
    [self updateUI:YES];
}

- (void)editingDidEndForEditPathTool:(id)aTool
{
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Edit Path" value:@"" table:@"UndoManager"]];
    [self applyPathAndKeyFramesChanges];
    [self updateUI:YES];
}

- (void)editingWillBeginForEditPathTool:(id)aTool
{
    [self storeCurrentPathAndKeyFrames];
    [_tryItAnimation stop];
    [self updateUI:YES];
}

- (id)tryItAnimationForEditPathTool:(id)aTool
{
    return _tryItAnimation;
}

- (id)animationForEditPathTool:(id)aTool
{
    return _animation;
}

- (void)setEditPathTool:(id)aTool
{
    id self_00;

    if (_editPathTool != aTool) {
        [_editPathTool setDelegate:0];
        [_editPathTool release];
        self_00 = [aTool retain];
        _editPathTool = self_00;
        [self_00 setDelegate:self];
    }
}

- (id)editPathTool
{
    return _editPathTool;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013b5e4 @ 0013b5e4, 108 bytes * /

void FUN_0013b5e4(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_selectToolWithTag_,0x37);
  _objc_msgSend(self,sel_setEditPathTool_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_editPathTool);
  _objc_msgSend(pvVar1,sel_run);
  return;
}

*/
- (void)runEditPath
{
    [self setEditPathTool:[self selectToolWithTag:0x37]];
    [[self editPathTool] run];
}

- (id)tryItAnimationForTransparentColorAssistantPane:(id)aPane
{
    return _tryItAnimation;
}

- (void)editingFinishedForTransparentAssistantPane:(id)aPane
{
    id pvVar1_4;

    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    pvVar1_4 = [[[_tryItAnimation animatedObject] localCopyIncludingNodeUnits:YES] autorelease];
    [self replaceAnimatedObject:[_animation animatedObject] with:pvVar1_4 undoRegistrationOnly:NO];
}

- (void)transparentColorFromAnimationSetupMainAssistantPane:(id)aPane
{
    id pvVar1_2;

    [_transparentColorAssistantPane setDelegate:0];
    [_transparentColorAssistantPane release];
    pvVar1_2 = [[HSTransparentColorAssistantPane alloc] init];
    _transparentColorAssistantPane = pvVar1_2;
    [pvVar1_2 setDelegate:self];
    [self openAssistantPaneAsInitialIfNeeded:_transparentColorAssistantPane withIdentifier:@"HSAnimationModePane"];
    [self cleanupTemporaryAnimationAssistantPanes];
}

- (id)undoHelperForAnimationSetupMainAssistantPane:(id)aPane
{
    return _undoHelper;
}

- (id)undoManagerForAnimationSetupMainAssistantPane:(id)aPane
{
    return [self undoManager];
}

- (void)playStopFromAnimationSetupMainAssistantPane:(id)aPane
{
    [self playStop:nil];
}

- (void)cancelFromAnimationSetupMainAssistantPane:(id)aPane
{
    [_tryItAnimation stop];
    [self finishAndApplyChanges:NO];
}

- (void)doneFromAnimationSetupMainAssistantPane:(id)aPane
{
    [_tryItAnimation stop];
    [self finishAndApplyChanges:YES];
}

- (void)getNewSourceFromAnimationSetupMainAssistantPane:(id)aPane
{
    [self updateAnimatedObjectFromTryItAnimation];
    [self setState:3];
    [self runPickImage];
}

- (void)newPathFromAnimationSetupMainAssistantPane:(id)aPane
{
    [self newPath:nil];
}

- (id)tryItAnimationForAnimationSetupMainAssistantPane:(id)aPane
{
    return _tryItAnimation;
}

- (id)animationForAnimationSetupMainAssistantPane:(id)aPane
{
    return _animation;
}

- (id)mainAssistantPane
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _mainAssistantPane;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSAnimationSetupMainAssistantPane new];
        _mainAssistantPane = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _mainAssistantPane;
    }
    return pvVar1;
}

- (void)runEditPath:(BOOL)aPath openMainAssistantPane:(BOOL)aPane
{
    if (aPane != NO) {
        [self openAssistantPaneAsInitialIfNeeded:[self mainAssistantPane] withIdentifier:@"HSAnimationModePane"];
        [self cleanupTemporaryAnimationAssistantPanes];
    }
    if (aPath != NO) {
        [self runEditPath];
        [self setUpTryItAnimation];
    }
    [self updateUI:YES];
}

- (void)updateAnimationForCurrentPath
{
    id pvVar1_4;

    if ([_animation path] != nil) {
        if ([_animation isOnePointPathAnimation]) {
            if ([_animation loopMode] == 0x2) {
                pvVar1_4 = _animation;
                [pvVar1_4 setLoopMode:([pvVar1_4 playMovie]) + 3];
            }
        }
    }
}

- (void)drawPathShouldFinishFromDrawPathAssistantPane:(id)aPane
{
    [[[HSToolManager sharedToolManager] currentTool] finishPathCreationForDrawPathCanvasLayer:nil];
}

- (void)drawPathShouldCancelFromDrawPathAssistantPane:(id)aPane
{
    [[[HSToolManager sharedToolManager] currentTool] cancelPathCreationForDrawPathCanvasLayer:nil];
}

- (void)pathStateIsUpdatedForDrawPathTool:(id)aTool
{
    [_drawPathAssistantPane setPathCreationCanBeFinished:YES];
}

- (void)drawingCanceledForDrawPathTool:(id)aTool
{
    [self cancelDrawPath];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013bc36 @ 0013bc36, 203 bytes * /

void FUN_0013bc36(HSAnimationModeController *self,SEL _cmd,
                 id goBackFromAnimationSetupEditPathAssistantPane)

{
  id self_00;
  
  _objc_msgSend(self,sel_setState_,self->_stateBeforeHelp);
  _objc_msgSend(self,sel_cleanUpTryItAnimation);
  self_00 = _objc_msgSend(self,sel_selectToolWithTag_,0x35);
  _objc_msgSend(self_00,sel_setDelegate_,self);
  _objc_msgSend(self_00,sel_run);
  _objc_msgSend(goBackFromAnimationSetupEditPathAssistantPane,sel_setDelegate_,0);
  _objc_msgSend(self->_assistantNavigationController,sel_popViewControllerAnimated_slide_,1,1);
  return;
}

*/
- (void)goBackFromAnimationSetupEditPathAssistantPane:(id)aPane
{
    [self setState:_stateBeforeHelp];
    [self cleanUpTryItAnimation];
    id tool = [self selectToolWithTag:0x35];
    [tool setDelegate:self];
    [tool run];
    [aPane setDelegate:nil];
    [_assistantNavigationController popViewControllerAnimated:YES slide:YES];
}

- (void)animationEditPathHelpPaneDidDone:(id)aDone contextInfo:(void *)aInfo
{
    [self runEditPath:NO openMainAssistantPane:YES];
}

- (void)drawingFinishedForDrawPathTool:(id)aTool
{
    id pvVar1_2;
    BOOL pvVar2_3;

    [aTool setDelegate:0];
    [self resetToolToDefault];
    if (_state == 4) {
        [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"New Path" value:@"" table:@"UndoManager"]];
        [self applyPathAndKeyFramesChanges];
    }
    [_animation setLoopMode:2];
    [self updateAnimationForCurrentPath];
    _stateBeforeHelp = _state;
    [self setState:2];
    pvVar1_2 = [HSAnimationSetupEditPathAssistantPane paneWithCoachingKey:@"AnimationEditPath"];
    pvVar2_3 = [pvVar1_2 needsToShow];
    if (pvVar2_3) {
        [pvVar1_2 setWindowTitle:[self assistantWindowTitle]];
        [pvVar1_2 setDidDoneDelegate:self didDoneSelector:@selector(animationEditPathHelpPaneDidDone:contextInfo:) contextInfo:nil];
        [pvVar1_2 setDelegate:self];
        [pvVar1_2 setShouldDismissWhenDisappeared:NO];
        [pvVar1_2 setShouldDismissOnOkFromSwitcher:NO];
        [self pushAnimationViewController:pvVar1_2];
    }
    [self runEditPath:YES openMainAssistantPane:(unsigned int)(!pvVar2_3)];
}

- (void)drawPathTool:(id)aTool setAnimatedObjectPosition:(NSPoint)aPosition
{
    [self setAnimatedObjectPosition:aPosition];
}

- (void)removeAnimatedObjectFromCardForDrawPathTool:(id)aTool
{
    [self removeAnimatedObjectFromCard];
}

- (void)addAnimatedObjectToCardForDrawPathTool:(id)aTool
{
    [self addTemporaryObjectToCard:[_animation animatedObject]];
}

- (id)animationForDrawPathTool:(id)aTool
{
    return _animation;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013c01f @ 0013c01f, 371 bytes * /

void FUN_0013c01f(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  _objc_msgSend(pvVar1,sel_setDelegate_,0);
  if (self->_state == 4) {
    _objc_msgSend(self,sel_setState_,2);
    uVar2 = 1;
    op = sel_runEditPath_openMainAssistantPane_;
  }
  else {
    if (self->_state != 1) {
      return;
    }
    _objc_msgSend(self,sel_setState_,0);
    _objc_msgSend(self,sel_removeAnimatedObjectFromCard);
    uVar2 = 1;
    _objc_msgSend(self->_drawPathAssistantPane,sel_dismiss_,1);
    if ((self->_applyChanges[0] & 2) != 0) {
      _objc_msgSend(self,sel_resetToolToDefault,uVar2);
      _objc_msgSend(self,sel_switchFromAnimationMode);
      _objc_msgSend(self,sel_restoreSelectonAfterSwitchFromAnimationMode);
      _objc_msgSend(self,sel_unlockAssistantIfNeeded);
      _objc_msgSend(self,sel_invalidateDropHelpPane);
    }
    uVar2 = 0;
    op = sel_updateUI_;
  }
  _objc_msgSend(self,op,uVar2);
  return;
}

*/
- (void)cancelDrawPath
{
    [[[HSToolManager sharedToolManager] currentTool] setDelegate:nil];
    if (_state == 4) {
        [self setState:2];
        [self runEditPath:YES openMainAssistantPane:YES];
    } else if (_state == 1) {
        [self setState:0];
        [self removeAnimatedObjectFromCard];
        [_drawPathAssistantPane dismiss:YES];
        if (_switchFromAnimationModeOnCancelPathCreation) {
            [self resetToolToDefault];
            [self switchFromAnimationMode];
            [self restoreSelectonAfterSwitchFromAnimationMode];
            [self unlockAssistantIfNeeded];
            [self invalidateDropHelpPane];
        }
        [self updateUI:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013c192 @ 0013c192, 421 bytes * /

void FUN_0013c192(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  SEL op;
  cfstringStruct *pcVar2;
  
  if (self->_state == 4) {
    _objc_msgSend(self,sel_storeCurrentPathAndKeyFrames);
  }
  pvVar1 = _objc_msgSend(self,sel_selectToolWithTag_,0x35);
  _objc_msgSend(pvVar1,sel_setDelegate_,self);
  _objc_msgSend(pvVar1,sel_run);
  _objc_msgSend(self->_drawPathAssistantPane,sel_setDelegate_,0);
  _objc_msgSend(self->_drawPathAssistantPane,sel_release);
  pvVar1 = _objc_msgSend(pvVar1,sel_pathCreationMode);
  self_00 = _objc_msgSend(cls_HSAnimationSetupDrawPathAssistantPane,sel_alloc);
  if (pvVar1 == (id)0x1) {
    pcVar2 = &cfstr_AnimationDrawSegmentedPath;
    pvVar1 = _objc_msgSend(self_00,sel_initWithCoachingKey_,&cfstr_AnimationDrawSegmentedPath);
    self->_drawPathAssistantPane = pvVar1;
    op = sel_setupUIForSegmentedPathCreationMode;
  }
  else {
    pcVar2 = &cfstr_AnimationDrawPath;
    pvVar1 = _objc_msgSend(self_00,sel_initWithCoachingKey_,&cfstr_AnimationDrawPath);
    self->_drawPathAssistantPane = pvVar1;
    op = sel_setupUIForNonSegmentedPathCreationMode;
  }
  _objc_msgSend(pvVar1,op,pcVar2);
  _objc_msgSend(self->_drawPathAssistantPane,sel_setDelegate_,self);
  _objc_msgSend(self,sel_openAssistantPaneAsInitialIfNeeded_withIdentifier_,
                self->_drawPathAssistantPane,&cfstr_HSAnimationModePane);
  _objc_msgSend(self,sel_cleanupTemporaryAnimationAssistantPanes);
  _objc_msgSend(self,sel_updateUI_,0);
  return;
}

*/
- (void)runDrawPath
{
    if (_state == 4) {
        [self storeCurrentPathAndKeyFrames];
    }
    id tool = [self selectToolWithTag:0x35];
    [tool setDelegate:self];
    [tool run];
    [_drawPathAssistantPane setDelegate:nil];
    [_drawPathAssistantPane release];
    BOOL segmented = ([tool pathCreationMode] == 1);
    _drawPathAssistantPane = [[HSAnimationSetupDrawPathAssistantPane alloc] initWithCoachingKey:segmented ? @"AnimationDrawSegmentedPath" : @"AnimationDrawPath"];
    if (segmented) {
        [_drawPathAssistantPane setupUIForSegmentedPathCreationMode];
    } else {
        [_drawPathAssistantPane setupUIForNonSegmentedPathCreationMode];
    }
    [_drawPathAssistantPane setDelegate:self];
    [self openAssistantPaneAsInitialIfNeeded:_drawPathAssistantPane withIdentifier:@"HSAnimationModePane"];
    [self cleanupTemporaryAnimationAssistantPanes];
    [self updateUI:NO];
}

- (void)recreateDrawPathAssistantPane
{
    id pvVar1_2;

    [_drawPathAssistantPane setDelegate:0];
    [_drawPathAssistantPane release];
    pvVar1_2 = [[HSAnimationSetupDrawPathAssistantPane alloc] initWithCoachingKey:@"AnimationDrawPath"];
    _drawPathAssistantPane = pvVar1_2;
    [pvVar1_2 setDelegate:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013c3d7 @ 0013c3d7, 906 bytes * /

void FUN_0013c3d7(HSAnimationModeController *self,SEL _cmd,id runCropForTemporaryObject,id options,
                 int withMode,id temporaryObjectOwner)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  id pvVar4;
  undefined *puVar5;
  SEL op;
  cfstringStruct *pcVar6;
  
  if (self->_state == 3) {
    _objc_msgSend(self,sel_cleanUpTryItAnimation);
  }
  if (withMode == 3) {
    _objc_msgSend(runCropForTemporaryObject,sel_retain);
    pvVar1 = _objc_msgSend(self,sel_card);
    pvVar2 = _objc_msgSend(pvVar1,sel_undoManager);
    _objc_msgSend(pvVar2,sel_disableUndoRegistration);
    _objc_msgSend(pvVar1,sel_removeHyperChild_,runCropForTemporaryObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    _objc_msgSend(pvVar1,sel_enableUndoRegistration);
    pvVar1 = _objc_msgSend(options,sel_objectForKey_,*(undefined4 *)PTR_PTR_003365f0);
    puVar5 = PTR_DAT_003365dc;
    pvVar1 = _objc_msgSend(pvVar1,sel_unsignedLongValue);
    if (*(id *)puVar5 == pvVar1) {
      pcVar6 = (cfstringStruct *)0x0;
      op = sel_createCelAnimationWithOptions_croppingPath_;
    }
    else {
      options = (id)0x0;
      op = sel_createObjectAnimationWithOptions_object_;
      pcVar6 = runCropForTemporaryObject;
    }
    _objc_msgSend(self,op,options,pcVar6);
    puVar5 = sel_releaseTemporaryObject;
    pvVar1 = _objc_msgSend(temporaryObjectOwner,sel_respondsToSelector_,sel_releaseTemporaryObject);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(temporaryObjectOwner,sel_releaseTemporaryObject,puVar5,pcVar6);
    }
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
    if (withMode == 0) {
      uVar3 = 0x32;
    }
    else if (withMode == 1) {
      uVar3 = 0x33;
    }
    else if (withMode == 2) {
      uVar3 = 0x34;
    }
    else {
      uVar3 = 0;
    }
    pvVar2 = _objc_msgSend(self,sel_selectToolWithTag_,uVar3);
    pvVar4 = _objc_msgSend(runCropForTemporaryObject,sel_queryHyperInterface_,&DAT_0037333c);
    _objc_msgSend(pvVar2,sel_setWorkObject_,pvVar4);
    pvVar4 = _objc_msgSend(cls_NSDictionary,sel_alloc);
    pvVar4 = _objc_msgSend(pvVar4,sel_initWithObjectsAndKeys_,options,&cfstr_HSUserInfoOptions,
                           temporaryObjectOwner,&cfstr_HSUserInfoTemporaryObjectOwner,0);
    _objc_msgSend(pvVar2,sel_setUserInfo_,pvVar4);
    puVar5 = cls_HSSelectImagePartPane;
    pvVar4 = _objc_msgSend(pvVar2,sel_toolIdentifier);
    puVar5 = _objc_msgSend(puVar5,sel_paneWithCoachingKey_,pvVar4);
    pvVar4 = _objc_msgSend(self,sel_assistantWindowTitle);
    _objc_msgSend(puVar5,sel_setWindowTitle_,pvVar4);
    _objc_msgSend(puVar5,sel_setDelegate_,self);
    _objc_msgSend(puVar5,sel_setShouldLeavePaneOnToolChange_,0);
    _objc_msgSend(puVar5,sel_setShouldDismissWhenDisappeared_,0);
    _objc_msgSend(pvVar2,sel_setDelegate_,puVar5);
    pcVar6 = &cfstr_HSAnimationModeTempPane;
    _objc_msgSend(self,sel_pushAnimationViewController_withIdentifier_,puVar5,
                  &cfstr_HSAnimationModeTempPane);
    runCropForTemporaryObject = pvVar1;
  }
  _objc_msgSend(runCropForTemporaryObject,sel_release,puVar5,pcVar6);
  return;
}

*/
- (void)runCropForTemporaryObject:(id)aObject options:(id)aOptions withMode:(NSInteger)aMode temporaryObjectOwner:(id)aOwner
{
    if (_state == 3) {
        [self cleanUpTryItAnimation];
    }
    if (aMode == 3) {
        [aObject retain];
        id card = [self card];
        [[card undoManager] disableUndoRegistration];
        [card removeHyperChild:aObject];
        [[card undoManager] enableUndoRegistration];
        if ([[aOptions objectForKey:@"graphicType"] unsignedLongValue] == 'CELm') {
            [self createCelAnimationWithOptions:aOptions croppingPath:NULL];
        } else {
            [self createObjectAnimationWithOptions:nil object:aObject];
        }
        if ([aOwner respondsToSelector:@selector(releaseTemporaryObject)]) {
            [aOwner releaseTemporaryObject];
        }
        [aObject release];
    } else {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSInteger toolTag = 0;
        if (aMode == 0) {
            toolTag = 0x32;
        } else if (aMode == 1) {
            toolTag = 0x33;
        } else if (aMode == 2) {
            toolTag = 0x34;
        }
        id tool = [self selectToolWithTag:toolTag];
        [tool setWorkObject:[aObject queryHyperInterface:@protocol(HSImageObjectAttributes)]];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:aOptions, @"HSUserInfoOptions", aOwner, @"HSUserInfoTemporaryObjectOwner", nil];
        [tool setUserInfo:userInfo];
        id pane = [HSSelectImagePartPane paneWithCoachingKey:[tool toolIdentifier]];
        [pane setWindowTitle:[self assistantWindowTitle]];
        [pane setDelegate:self];
        [pane setShouldLeavePaneOnToolChange:NO];
        [pane setShouldDismissWhenDisappeared:NO];
        [tool setDelegate:pane];
        [self pushAnimationViewController:pane withIdentifier:@"HSAnimationModeTempPane"];
        [pool release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013c761 @ 0013c761, 161 bytes * /

void FUN_0013c761(HSAnimationModeController *self,SEL _cmd)

{
  SEL op;
  undefined4 uVar1;
  
  _objc_msgSend(self,sel_configureAnimatedObjectAndAnimation);
  _objc_msgSend(self,sel_resetToolToDefault);
  if (self->_state == 3) {
    _objc_msgSend(self,sel_setState_,2);
    uVar1 = 1;
    op = sel_runEditPath_openMainAssistantPane_;
  }
  else {
    uVar1 = 1;
    _objc_msgSend(self,sel_setState_,1);
    op = sel_runDrawPath;
  }
  _objc_msgSend(self,op,uVar1);
  return;
}

*/
- (void)didSetAnimatedObject
{
    [self configureAnimatedObjectAndAnimation];
    [self resetToolToDefault];
    if (_state == 3) {
        [self setState:2];
        [self runEditPath:YES openMainAssistantPane:YES];
    } else {
        [self setState:1];
        [self runDrawPath];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013c802 @ 0013c802, 1026 bytes * /

void FUN_0013c802(HSAnimationModeController *self,SEL _cmd,id createCelAnimationWithOptions,
                 CGPath *croppingPath)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  undefined4 uVar6;
  char cVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  longdouble lVar11;
  float fVar12;
  SEL op;
  undefined8 in_stack_ffffff8c;
  undefined4 uVar14;
  undefined8 uVar13;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  uVar14 = (undefined4)((ulonglong)in_stack_ffffff8c >> 0x20);
  _objc_msgSend(self,sel_resetToolToDefault);
  if (self->_state == 3) {
    _objc_msgSend(self,sel_cleanUpTryItAnimation);
  }
  if ((croppingPath != (CGPath *)0x0) && (cVar7 = _CGPathIsEmpty(croppingPath), cVar7 == '\0')) {
    pvVar8 = _objc_msgSend(cls_NSBezierPath,sel_hyperBezierPathWithCGPath_,croppingPath);
    pvVar9 = _objc_msgSend(createCelAnimationWithOptions,sel_mutableCopy);
    uVar14 = *(undefined4 *)PTR_PTR_003365ec;
    _objc_msgSend(pvVar9,sel_setObject_forKey_,pvVar8,uVar14);
    createCelAnimationWithOptions = _objc_msgSend(pvVar9,sel_autorelease);
  }
  uVar13 = CONCAT44(uVar14,createCelAnimationWithOptions);
  pvVar8 = _objc_msgSend(cls_HSAnimationSetupPickImageAssistantPane,
                         sel_movieForCelAnimationWithOptions_,createCelAnimationWithOptions);
  op = sel_cancelFromPickImageTool;
  if (pvVar8 != (id)0x0) {
    pvVar9 = _objc_msgSend(createCelAnimationWithOptions,sel_objectForKey_,
                           *(undefined4 *)PTR_PTR_003365e4);
    if (pvVar9 != (id)0x0) {
      pvVar10 = _objc_msgSend(pvVar8,sel_queryHyperInterface_,&DAT_00373328);
      pvVar10 = _objc_msgSend(pvVar10,sel_queryGeometryBehaviorApplier);
      if (pvVar10 != (id)0x0) {
        local_2c = *(float *)PTR_00336088;
        fStack_28 = *(float *)(PTR_00336088 + 4);
        local_24 = *(float *)(PTR_00336088 + 8);
        fStack_20 = *(float *)(PTR_00336088 + 0xc);
        local_1c = *(undefined4 *)(PTR_00336088 + 0x10);
        uStack_18 = *(undefined4 *)(PTR_00336088 + 0x14);
        _objc_msgSend(pvVar9,sel_getValue_,&local_2c);
        uVar6 = uStack_18;
        uVar14 = local_1c;
        fVar5 = fStack_20;
        fVar4 = local_24;
        fVar3 = fStack_28;
        fVar2 = local_2c;
        lVar11 = (longdouble)_hypotf(local_2c,fStack_28);
        fVar1 = (float)lVar11;
        lVar11 = (longdouble)_hypotf(fVar4,fVar5);
        fStack_20 = (float)lVar11;
        fVar12 = fStack_20;
        if (&stack0x00000000 == (undefined1 *)0x30) {
          fVar12 = 1.0;
        }
        if ((fStack_20 != 0.0) || (NAN(fStack_20))) {
          fStack_20 = 1.0 / fStack_20;
        }
        else {
          fStack_20 = 1.0;
        }
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fStack_28 = 1.0 / fVar1;
        }
        else {
          fStack_28 = 1.0;
        }
        local_2c = fVar2 * fStack_28;
        fStack_28 = fVar3 * fStack_28;
        local_24 = fVar4 * fStack_20;
        fStack_20 = fVar5 * fStack_20;
        local_1c = uVar14;
        uStack_18 = uVar6;
        _objc_msgSend(pvVar10,sel_resizeFrameBy_aboutRelativePoint_withLayoutGuidingContext_,fVar1,
                      fVar12,*(undefined4 *)PTR_00336074,*(undefined4 *)(PTR_00336074 + 4),0);
        _objc_msgSend(pvVar10,sel_setAffineTransform_withLayoutGuidingContext_,
                      CONCAT44(fStack_28,local_2c),CONCAT44(fStack_20,local_24),
                      CONCAT44(uStack_18,local_1c),0);
      }
    }
    _objc_msgSend(self,sel_animationEditModePickTool_pickedObject_event_,0,pvVar8,0);
    _objc_msgSend(self,sel_setIsMovieAnimation_,0);
    pvVar9 = _objc_msgSend(self,sel_mainAssistantPane);
    _objc_msgSend(pvVar9,sel_updateUI);
    if (self->_state != 0) {
      return;
    }
    uVar13 = CONCAT44(pvVar8,1);
    _objc_msgSend(self,sel_setState_,1);
    op = sel_runDrawPath;
  }
  _objc_msgSend(self,op,uVar13);
  return;
}

*/
- (void)createCelAnimationWithOptions:(id)aOptions croppingPath:(struct CGPath *)aPath
{
    [self resetToolToDefault];
    if (_state == 3) {
        [self cleanUpTryItAnimation];
    }
    if (aPath != NULL && !CGPathIsEmpty(aPath)) {
        id bezier = [NSBezierPath hyperBezierPathWithCGPath:aPath];
        NSMutableDictionary *options = [aOptions mutableCopy];
        [options setObject:bezier forKey:@"cropping path"];
        aOptions = [options autorelease];
    }
    id movie = [HSAnimationSetupPickImageAssistantPane movieForCelAnimationWithOptions:aOptions];
    if (movie == nil) {
        [self cancelFromPickImageTool];
        return;
    }
    NSValue *transformValue = [aOptions objectForKey:@"affineTransform"];
    if (transformValue != nil) {
        id applier = [[movie queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            CGAffineTransform t = CGAffineTransformIdentity;
            [transformValue getValue:&t];
            CGFloat sx = hypot(t.a, t.b);
            CGFloat sy = hypot(t.c, t.d);
            CGFloat invY = (sy != 0.0) ? 1.0 / sy : 1.0;
            CGFloat invX = (sx != 0.0) ? 1.0 / sx : 1.0;
            t.a *= invX;
            t.b *= invX;
            t.c *= invY;
            t.d *= invY;
            [applier resizeFrameBy:NSMakeSize(sx, sy) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
            [applier setAffineTransform:t withLayoutGuidingContext:nil];
        }
    }
    [self animationEditModePickTool:nil pickedObject:movie event:nil];
    [self setIsMovieAnimation:NO];
    [[self mainAssistantPane] updateUI];
    if (_state == 0) {
        [self setState:1];
        [self runDrawPath];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013cc04 @ 0013cc04, 431 bytes * /

void FUN_0013cc04(HSAnimationModeController *self,SEL _cmd,id createCelAnimationWithOptions,
                 CGPath *croppingPath,id assistantPane)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  if (self->_state == 3) {
    _objc_msgSend(self->_pickImageAssistantPane,sel_setAnimationModeController_,0);
    _objc_msgSend(self->_pickImageAssistantPane,sel_setDelegate_,0);
    _objc_msgSend(self->_pickImageAssistantPane,sel_release);
    self->_pickImageAssistantPane = (HSAnimationSetupPickImageAssistantPane *)0x0;
  }
  else {
    _objc_msgSend(self,sel_lockAssistantIfNeeded);
    self_00 = _objc_msgSend(assistantPane,sel_assistant);
    pvVar1 = _objc_msgSend(self_00,sel_object);
    pvVar2 = _objc_msgSend(self,sel_actionEventsForObject_,pvVar1);
    pvVar3 = _objc_msgSend(assistantPane,sel_objectAssistantNavigationController);
    _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,
                  pvVar1,pvVar2,self_00,pvVar3);
    pvVar4 = _objc_msgSend(self,sel_isAnimationModeActive);
    if ((char)pvVar4 == '\0') {
      _objc_msgSend(self,sel_switchToAnimationMode,pvVar1,pvVar2,self_00,pvVar3);
      self->_applyChanges[0] = self->_applyChanges[0] | 2;
    }
    _objc_msgSend(self,sel_setUpAnimation,pvVar1,pvVar2,self_00,pvVar3);
    _objc_msgSend(self,sel_setUpUndoHelper);
    _objc_msgSend(self,sel_setState_,0);
  }
  _objc_msgSend(self,sel_createCelAnimationWithOptions_croppingPath_,createCelAnimationWithOptions,
                croppingPath);
  return;
}

*/
- (void)createCelAnimationWithOptions:(id)aOptions croppingPath:(struct CGPath *)aPath assistantPane:(id)aPane
{
    if (_state == 3) {
        [_pickImageAssistantPane setAnimationModeController:nil];
        [_pickImageAssistantPane setDelegate:nil];
        [_pickImageAssistantPane release];
        _pickImageAssistantPane = nil;
    } else {
        [self lockAssistantIfNeeded];
        id assistant = [aPane assistant];
        id object = [assistant object];
        id events = [self actionEventsForObject:object];
        [self setActingObject:object actionEvents:events assistant:assistant assistantNavigationController:[aPane objectAssistantNavigationController]];
        if (![self isAnimationModeActive]) {
            [self switchToAnimationMode];
            _switchFromAnimationModeOnCancelPathCreation = YES;
        }
        [self setUpAnimation];
        [self setUpUndoHelper];
        [self setState:0];
    }
    [self createCelAnimationWithOptions:aOptions croppingPath:aPath];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013cdb3 @ 0013cdb3, 488 bytes * /

void FUN_0013cdb3(HSAnimationModeController *self,SEL _cmd,id createObjectAnimationWithOptions,
                 id object)

{
  id pvVar1;
  undefined8 in_stack_ffffffbc;
  undefined8 uVar2;
  undefined4 uVar3;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  undefined4 local_14;
  undefined4 uStack_10;
  
  uVar2 = CONCAT44((int)((ulonglong)in_stack_ffffffbc >> 0x20),*(undefined4 *)PTR_PTR_003365e4);
  pvVar1 = _objc_msgSend(createObjectAnimationWithOptions,sel_objectForKey_,
                         *(undefined4 *)PTR_PTR_003365e4);
  if (pvVar1 != (id)0x0) {
    local_24 = *(undefined4 *)PTR_00336088;
    uStack_20 = *(undefined4 *)(PTR_00336088 + 4);
    local_1c = *(undefined4 *)(PTR_00336088 + 8);
    uStack_18 = *(undefined4 *)(PTR_00336088 + 0xc);
    local_14 = *(undefined4 *)(PTR_00336088 + 0x10);
    uStack_10 = *(undefined4 *)(PTR_00336088 + 0x14);
    uVar3 = (undefined4)((ulonglong)uVar2 >> 0x20);
    _objc_msgSend(pvVar1,sel_getValue_,&local_24);
    uVar2 = CONCAT44(uVar3,&DAT_00373328);
    pvVar1 = _objc_msgSend(object,sel_queryHyperInterface_,&DAT_00373328);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
    if (pvVar1 != (id)0x0) {
      uVar2 = CONCAT44(uStack_20,local_24);
      _objc_msgSend(pvVar1,sel_setAffineTransform_withLayoutGuidingContext_,uVar2,
                    CONCAT44(uStack_18,local_1c),CONCAT44(uStack_10,local_14),0);
    }
  }
  pvVar1 = _objc_msgSend(self->_animation,sel_animatedObject,uVar2);
  uVar3 = (undefined4)((ulonglong)uVar2 >> 0x20);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  if (pvVar1 != (id)0x0) {
    uVar3 = 0;
    _objc_msgSend(self,sel_registerUndoGeometryChangesOfAnimatedObject_withActionName_,pvVar1,0);
  }
  _objc_msgSend(self->_animation,sel_setAnimatedObject_,object,uVar3);
  _objc_msgSend(self,sel_setIsMovieAnimation_,0);
  _objc_msgSend(self,sel_didSetAnimatedObject);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self,sel_replaceAnimatedObject_with_undoRegistrationOnly_,pvVar1,object,1);
  }
  return;
}

*/
- (void)createObjectAnimationWithOptions:(id)aOptions object:(id)aObject
{
    NSValue *transformValue = [aOptions objectForKey:@"affineTransform"];
    if (transformValue != nil) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        [transformValue getValue:&transform];
        id applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            [applier setAffineTransform:transform withLayoutGuidingContext:nil];
        }
    }
    id previousAnimatedObject = [[[_animation animatedObject] retain] autorelease];
    if (previousAnimatedObject != nil) {
        [self registerUndoGeometryChangesOfAnimatedObject:previousAnimatedObject withActionName:nil];
    }
    [_animation setAnimatedObject:aObject];
    [self setIsMovieAnimation:NO];
    [self didSetAnimatedObject];
    if (previousAnimatedObject != nil) {
        [self replaceAnimatedObject:previousAnimatedObject with:aObject undoRegistrationOnly:YES];
    }
}

- (void)createImageAnimationWithOptions:(id)aOptions image:(id)aImage
{
    [self createObjectAnimationWithOptions:aOptions object:[HSDocument userObjectWithMedia:[HSNewMedia mediaWithImage:aImage]]];
}

- (void)cancelFromPickObjectTool:(id)aTool
{
    [aTool setDelegate:0];
    [self cancelFromPickImageTool];
}

- (void)animationEditModePickTool:(id)aTool pickedObject:(id)aObject event:(id)aEvent
{
    id pvVar1_2;
    id pvVar2_3;

    [aTool setDelegate:0];
    [self setIsMovieAnimation:NO];
    pvVar1_2 = [[aObject localCopyIncludingNodeUnits:YES] autorelease];
    pvVar2_3 = [[[_animation animatedObject] retain] autorelease];
    if ([aObject hyperParent] != nil) {
        if ([aObject implementsHyperInterface:@protocol(HSButtonObjectAttributes)]) {
            [pvVar1_2 setInteractiveInAnimation:YES];
        }
    }
    if (pvVar2_3 != nil) {
        [self registerUndoGeometryChangesOfAnimatedObject:pvVar2_3 withActionName:nil];
    }
    [_animation setAnimatedObject:pvVar1_2];
    [self didSetAnimatedObject];
    if (pvVar2_3 != nil) {
        [self replaceAnimatedObject:pvVar2_3 with:pvVar1_2 undoRegistrationOnly:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013d1e3 @ 0013d1e3, 132 bytes * /

void FUN_0013d1e3(HSAnimationModeController *self,SEL _cmd)

{
  SEL op;
  
  if (self->_state == 3) {
    _objc_msgSend(self,sel_setState_,2);
    op = sel_runEditPath_openMainAssistantPane_;
  }
  else {
    if (self->_state != 0) {
      return;
    }
    _objc_msgSend(self,sel_resetToolToDefault);
    self = self->_assistantNavigationController;
    op = sel_popViewControllerAnimated_;
  }
  _objc_msgSend(self,op,1);
  return;
}

*/
- (void)cancelFromPickImageTool
{
    if (_state == 3) {
        [self setState:2];
        [self runEditPath:YES openMainAssistantPane:YES];
    } else if (_state == 0) {
        [self resetToolToDefault];
        [_assistantNavigationController popViewControllerAnimated:YES];
    }
}

- (void)runPickCardObjectWithAssistant:(id)aAssistant
{
    id pvVar1;
    id pvVar1_3;

    if (_state == 3) {
        [self cleanUpTryItAnimation];
    }
    pvVar1 = [self selectToolWithTag:0x31];
    [pvVar1 setDelegate:self];
    pvVar1_3 = [HSAnimationSetupCoachingAssistantPane paneWithCoachingKey:[pvVar1 toolIdentifier]];
    [pvVar1_3 setWindowTitle:[self assistantWindowTitle]];
    [pvVar1_3 setDelegate:self];
    [self pushAnimationViewController:pvVar1_3 withIdentifier:@"HSAnimationModeTempPane"];
}

- (void)recreatePickImageAssistantPane
{
    HSAnimationSetupPickImageAssistantPane *pHVar1;

    [_pickImageAssistantPane setAnimationModeController:nil];
    [_pickImageAssistantPane setDelegate:0];
    [_pickImageAssistantPane release];
    pHVar1 = [HSAnimationSetupPickImageAssistantPane new];
    _pickImageAssistantPane = pHVar1;
    [pHVar1 setDelegate:self];
    [_pickImageAssistantPane setAnimationModeController:self];
    [_pickImageAssistantPane setTolerance:(float)[self selectionToolTolerance]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013d449 @ 0013d449, 131 bytes * /

float FUN_0013d449(HSAnimationModeController *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  double dVar3;
  
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
  pvVar2 = _objc_msgSend(pvVar2,sel_settingForIdentifier_andKey_,*(undefined4 *)PTR_PTR_003360f4,
                         *(undefined4 *)PTR_PTR_003360f8);
  if (pvVar2 == (id)0x0) {
    fVar1 = 0.0;
  }
  else {
    dVar3 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
    fVar1 = (float)dVar3;
  }
  return fVar1;
}

*/
- (CGFloat)selectionToolTolerance
{
    id tolerance = [[[HSToolManager sharedToolManager] toolSettings] settingForIdentifier:@"HSLassoSelectionTool" andKey:@"selectionTolerance"];
    if (tolerance == nil) {
        return 0.0;
    }
    return [tolerance floatValue];
}

- (void)runPickImage
{
    [self recreatePickImageAssistantPane];
    [self pushAnimationViewController:_pickImageAssistantPane];
    [self updateUI:NO];
}

- (void)setIsMovieAnimation:(BOOL)aAnimation
{
    if ([_animation useClones]) {
        [_animation setUseClones:(unsigned int)(aAnimation == NO)];
    }
    if (_initialAnimation == nil) {
        [_animation setLoopMode:(unsigned int)(aAnimation != NO) * 2 + 2];
    }
    [[self mainAssistantPane] setIsMovieAnimation:aAnimation];
    [self updateAnimationForCurrentPath];
}

- (void)setAnimatedObjectPosition:(NSPoint)aPosition
{
    id pvVar1;

    pvVar1 = [_animation animatedObject];
    [[pvVar1 undoManager] disableUndoRegistration];
    [HSAnimationPositioning setPosition:aPosition ofObject:pvVar1];
    [[pvVar1 undoManager] enableUndoRegistration];
}

- (void)removeAnimatedObjectFromCard
{
    id pvVar1;

    pvVar1 = [_animation animatedObject];
    [[[self card] undoManager] disableUndoRegistration];
    [[self card] removeHyperChild:pvVar1];
    [[[self card] undoManager] enableUndoRegistration];
    [[self cardView] setNeedsDisplay:YES];
}

- (void)addTemporaryObjectToCard:(id)aCard
{
    id pvVar1;

    pvVar1 = [self card];
    [[pvVar1 undoManager] disableUndoRegistration];
    [pvVar1 addTemporaryHyperChild:aCard];
    [[pvVar1 undoManager] enableUndoRegistration];
}

- (void)configureAnimatedObjectAndAnimation
{
    [self disableAnimatedObjectShadow];
    [self updateAnimationPlayMovie];
    [self makeAnimatedObjectButtonBorderless];
}

- (void)makeAnimatedObjectButtonBorderless
{
    id pvVar1_4;

    if ([[_animation animatedObject] queryHyperInterface:@protocol(HSButtonObjectAttributes)] != nil) {
        pvVar1_4 = [[_animation animatedObject] queryHyperInterface:@protocol(HSBorderAttributes)];
        if (pvVar1_4 != nil) {
            [[[_animation animatedObject] undoManager] disableUndoRegistration];
            [pvVar1_4 setIsBorderless:YES];
            [[[_animation animatedObject] undoManager] enableUndoRegistration];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013d977 @ 0013d977, 453 bytes * /

void FUN_0013d977(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  undefined8 in_stack_ffffffdc;
  undefined4 uVar4;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffffdc >> 0x20);
  pvVar1 = _objc_msgSend(self->_animation,sel_animatedObject);
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setSupport_,pvVar2);
  pvVar1 = _objc_msgSend(self->_animation,sel_animatedObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003737b0);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_animation,sel_setPlayMovie_,0);
    pvVar1 = self->_animation;
    dVar3 = _objc_msgSend_fpret(cls_HSAnimationOptions,sel_undefinedMovieSpeed);
    _objc_msgSend(pvVar1,sel_setMovieSpeed_,dVar3);
    pvVar1 = _objc_msgSend(self->_animation,sel_loopMode);
    if (pvVar1 == (id)0x4) {
      dVar3 = (double)CONCAT44((int)((ulonglong)dVar3 >> 0x20),2);
      _objc_msgSend(self->_animation,sel_setLoopMode_,2);
    }
    _objc_msgSend(self,sel_updateAnimationForCurrentPath,dVar3);
  }
  else {
    dVar3 = (double)CONCAT44(uVar4,1);
    _objc_msgSend(self->_animation,sel_setPlayMovie_,1);
    pvVar2 = _objc_msgSend(self->_animation,sel_wasMovieSpeedSet);
    if ((char)pvVar2 == '\0') {
      pvVar2 = self->_animation;
      dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperFramesPerSecond);
      _objc_msgSend(pvVar2,sel_setMovieSpeed_,dVar3);
    }
  }
  pvVar1 = _objc_msgSend(self->_animation,sel_animatedObject,dVar3);
  _objc_msgSend(pvVar1,sel_setSupport_,0);
  return;
}

*/
- (void)updateAnimationPlayMovie
{
    [[_animation animatedObject] setSupport:[self document]];
    id framesPerSecond = [[_animation animatedObject] queryHyperInterface:@protocol(HSFramesPerSecondAttributes)];
    if (framesPerSecond == nil) {
        [_animation setPlayMovie:NO];
        [_animation setMovieSpeed:[HSAnimationOptions undefinedMovieSpeed]];
        if ([_animation loopMode] == 4) {
            [_animation setLoopMode:2];
        }
        [self updateAnimationForCurrentPath];
    } else {
        [_animation setPlayMovie:YES];
        if (![_animation wasMovieSpeedSet]) {
            [_animation setMovieSpeed:[framesPerSecond hyperFramesPerSecond]];
        }
    }
    [[_animation animatedObject] setSupport:nil];
}

- (void)disableAnimatedObjectShadow
{
    id pvVar1_2;

    pvVar1_2 = [[_animation animatedObject] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
    if (pvVar1_2 != nil) {
        [[[_animation animatedObject] undoManager] disableUndoRegistration];
        [pvVar1_2 setHyperShadowEnabled:NO];
        [[[_animation animatedObject] undoManager] enableUndoRegistration];
    }
}

- (void)documentUndoManagerWillRegisterUndo:(id)aUndo
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013dc1d @ 0013dc1d, 103 bytes * /

void FUN_0013dc1d(HSAnimationModeController *self,SEL _cmd)

{
  undefined4 uVar1;
  
  uVar1 = 0xffffffff;
  if ((self->_applyChanges[0] & 1) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_undoHelper,sel_finishDuplicating_,uVar1);
  _objc_msgSend(self->_undoHelper,sel_release);
  self->_undoHelper = (id)0x0;
  return;
}

*/
- (void)cleanUpUndoHelper
{
    [_undoHelper finishDuplicating:_applyChanges];
    [_undoHelper release];
    _undoHelper = nil;
}

- (void)setUpUndoHelper
{
    id self_00;
    id pvVar3;
    id pvVar1_2;

    self_00 = [HSEditModeUndoHelper alloc];
    pvVar3 = _undoManager;
    pvVar1_2 = [[self document] undoManager];
    _undoHelper = [self_00 initWithDocument:[self document] documentUndoManager:pvVar1_2 editModeUndoManager:pvVar3 delegate:self];
}

- (void)didBecomeActiveInModeSwitcher:(id)aSwitcher
{
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:NO];
}

- (void)didBecomeNonWorkingInModeSwitcher:(id)aSwitcher
{
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:nil];
    [[self cardView] hibernate];
}

- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [[self cardView] scrollPoint:(_pointToScrollCardView)];
    [super didBecomeWorkingInModeSwitcher:aSwitcher];
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:[self cardView]];
    [[self cardView] dehibernate];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013dec3 @ 0013dec3, 526 bytes * /

void FUN_0013dec3(HSAnimationModeController *self,SEL _cmd,BOOL finishAndApplyChanges)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_switching);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_resetToolToDefault);
    _objc_msgSend(self,sel_updateAnimatedObjectFromTryItAnimation);
    _objc_msgSend(self,sel_cleanUpTryItAnimation);
    self->_applyChanges[0] = self->_applyChanges[0] & 0xfe | finishAndApplyChanges & 1U;
    _objc_msgSend(self,sel_cleanUpUndoHelper);
    pvVar1 = _objc_msgSend(self,sel_undoManager);
    _objc_msgSend(pvVar1,sel_removeAllActions);
    pvVar1 = _objc_msgSend(self,sel_dummyUndoManager);
    _objc_msgSend(pvVar1,sel_removeAllActions);
    self->_applyChanges[0] = self->_applyChanges[0] & 0xfe;
    _objc_msgSend(self,sel_cleanUpAnimation_,(int)finishAndApplyChanges);
    _objc_msgSend(self,sel_switchFromAnimationMode);
    _objc_msgSend(self,sel_restoreSelectonAfterSwitchFromAnimationMode);
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pvVar2 = _objc_msgSend(self->_dropHelpPane,sel_actingObject);
    _objc_msgSend(pvVar1,sel_removeDropHelpPaneForObject_,pvVar2);
    _objc_msgSend(self,sel_invalidateDropHelpPane);
    _objc_msgSend(self,sel_revertToInitialAssistantPane);
    _objc_msgSend(self,sel_unlockAssistantIfNeeded);
    _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,0,0
                  ,0,0);
    _objc_msgSend(self,sel_setState_,0);
  }
  return;
}

*/
- (void)finishAndApplyChanges:(BOOL)aChanges
{
    if (![[[self document] modeSwitcher] switching]) {
        [self resetToolToDefault];
        [self updateAnimatedObjectFromTryItAnimation];
        [self cleanUpTryItAnimation];
        _applyChanges = aChanges;
        [self cleanUpUndoHelper];
        [[self undoManager] removeAllActions];
        [[self dummyUndoManager] removeAllActions];
        _applyChanges = NO;
        [self cleanUpAnimation:aChanges];
        [self switchFromAnimationMode];
        [self restoreSelectonAfterSwitchFromAnimationMode];
        [[HSCoachingHelpManager sharedCoachingHelpManager] removeDropHelpPaneForObject:[_dropHelpPane actingObject]];
        [self invalidateDropHelpPane];
        [self revertToInitialAssistantPane];
        [self unlockAssistantIfNeeded];
        [self setActingObject:nil actionEvents:nil assistant:nil assistantNavigationController:nil];
        [self setState:0];
    }
}

- (void)restoreSelectonAfterSwitchFromAnimationMode
{
    id pvVar2;
    id pvVar1_2;
    id pvVar1_5;
    id pvVar3_3;

    pvVar2 = [[_actingObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    pvVar1_2 = _actingObject;
    pvVar3_3 = [[[self document] mainWindowController] cardView];
    if (pvVar2 == pvVar1_2) {
        [pvVar3_3 selectObjects:nil];
        pvVar3_3 = [[[self document] selectionController] stackController];
        pvVar1_5 = _actingObject;
    }
    else {
        pvVar1_5 = _actingObject;
    }
    [pvVar3_3 selectObject:pvVar1_5];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013e1e0 @ 0013e1e0, 146 bytes * /

void FUN_0013e1e0(HSAnimationModeController *self,SEL _cmd)

{
  HSAnimationModeController *self_00;
  SEL op;
  
  if (self->_revertMode == 1) {
    self_00 = _objc_msgSend(self->_assistantNavigationController,sel_topViewController);
    op = sel_dismissModalViewControllerAnimated_;
  }
  else {
    self_00 = self;
    op = sel_popToInitialAssistantPane;
    if (self->_revertMode != 0) {
      self_00 = _objc_msgSend(self,sel_assistant);
      op = sel_assistantGoBack_;
    }
  }
  _objc_msgSend(self_00,op);
  self->_revertMode = 0;
  return;
}

*/
- (void)revertToInitialAssistantPane
{
    if (_revertMode == 1) {
        [[_assistantNavigationController topViewController] dismissModalViewControllerAnimated:YES];
    } else if (_revertMode == 0) {
        [self popToInitialAssistantPane];
    } else {
        [[self assistant] assistantGoBack:nil];
    }
    _revertMode = 0;
}

- (void)popToInitialAssistantPane
{
    id self_00;
    BOOL pvVar1;
    id pcVar2;

    self_00 = [_assistantNavigationController paneIdentifierForTopViewController];
    pvVar1 = [self_00 isEqualToString:@"HSAnimationModePane"];
    pcVar2 = @"HSAnimationModeTempPane";
    if (!pvVar1) {
        pcVar2 = @"HSAnimationModePane";
    }
    [_assistantNavigationController removeAllViewControllersWithIdentifier:pcVar2];
    [_assistantNavigationController popAllTopViewControllersWithIdentifier:self_00 animate:YES];
}

- (void)noteShouldDismissModalViewControllerOnFinish
{
    _revertMode = 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013e30a @ 0013e30a, 614 bytes * /

void FUN_0013e30a(HSAnimationModeController *self,SEL _cmd,BOOL cleanUpAnimation)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_actor);
  pvVar1 = _objc_msgSend(self->_actionEvents,sel_lastObject);
  pvVar2 = _objc_msgSend(cls_HSPlayAnimationAction,sel_actionType);
  pvVar3 = _objc_msgSend(self_00,sel_hyperActionsOfType_forEvent_,pvVar2,pvVar1);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  if (cleanUpAnimation == '\0') {
    if (pvVar4 != (id)0x1) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_document,pvVar2,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    _objc_msgSend(pvVar2,sel_disableUndoRegistration);
    pvVar4 = (id)0x0;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
    pvVar2 = self->_initialAnimation;
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(self->_actionEvents,sel_objectEnumerator,pvVar4);
      while (pvVar5 = _objc_msgSend(pvVar2,sel_nextObject,pvVar4,pvVar1), pvVar5 != (id)0x0) {
        pvVar4 = pvVar3;
        _objc_msgSend(self_00,sel_removeHyperAction_forEvent_,pvVar3,pvVar5);
        pvVar1 = pvVar5;
      }
    }
    else {
      _objc_msgSend(pvVar3,sel_setAnimation_,pvVar2);
      pvVar4 = pvVar2;
    }
    pvVar2 = _objc_msgSend(self,sel_document,pvVar4,pvVar1);
    self_00 = _objc_msgSend(pvVar2,sel_undoManager);
    op = sel_enableUndoRegistration;
  }
  else if (pvVar4 == (id)0x1) {
    pvVar2 = self->_animation;
    pvVar4 = _objc_msgSend(self->_initialAnimation,sel_isEqual_,pvVar2,pvVar1);
    if ((char)pvVar4 != '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_playAniamtionAction,pvVar2,pvVar1);
    pvVar4 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
    op = sel_replaceHyperAction_withAction_forEvents_;
  }
  else {
    if (pvVar4 != (id)0x0) {
      return;
    }
    pvVar1 = _objc_msgSend(self->_actionEvents,sel_objectAtIndex_,0,pvVar1);
    pvVar4 = _objc_msgSend(self,sel_playAniamtionAction);
    op = sel_addHyperAction_forEvent_;
  }
  _objc_msgSend(self_00,op,pvVar4,pvVar1);
  return;
}

*/
- (void)cleanUpAnimation:(BOOL)aAnimation
{
    id actor = [self actor];
    id lastEvent = [_actionEvents lastObject];
    NSArray *actions = [actor hyperActionsOfType:[HSPlayAnimationAction actionType] forEvent:lastEvent];
    NSUInteger count = [actions count];
    if (!aAnimation) {
        if (count != 1) {
            return;
        }
        [[[self document] undoManager] disableUndoRegistration];
        id action = [actions objectAtIndex:0];
        if (_initialAnimation == nil) {
            NSEnumerator *enumerator = [_actionEvents objectEnumerator];
            id event;
            while ((event = [enumerator nextObject]) != nil) {
                [actor removeHyperAction:action forEvent:event];
            }
        } else {
            [action setAnimation:_initialAnimation];
        }
        [[[self document] undoManager] enableUndoRegistration];
    } else if (count == 1) {
        if ([_initialAnimation isEqual:_animation]) {
            return;
        }
        [actor replaceHyperAction:[actions objectAtIndex:0] withAction:[self playAniamtionAction] forEvents:_actionEvents];
    } else if (count == 0) {
        [actor addHyperAction:[self playAniamtionAction] forEvent:[_actionEvents objectAtIndex:0]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013e570 @ 0013e570, 200 bytes * /

id FUN_0013e570(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_actor);
  pvVar2 = _objc_msgSend(self->_actionEvents,sel_extraFirstObject);
  pvVar3 = _objc_msgSend(cls_HSPlayAnimationAction,sel_actionType);
  pvVar1 = _objc_msgSend(pvVar1,sel_createActionOfType_forEvent_,pvVar3,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setEvents_,self->_actionEvents);
  _objc_msgSend(pvVar1,sel_setAnimation_,self->_animation);
  return pvVar1;
}

*/
- (id)playAniamtionAction
{
    id action = [[[self actor] createActionOfType:[HSPlayAnimationAction actionType] forEvent:[_actionEvents extraFirstObject]] autorelease];
    [action setEvents:_actionEvents];
    [action setAnimation:_animation];
    return action;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013e638 @ 0013e638, 301 bytes * /

void FUN_0013e638(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *self_00;
  SEL op;
  
  _objc_msgSend(self,sel_checkActionsForAllEventsAreEqual);
  pvVar1 = _objc_msgSend(self,sel_actor);
  pvVar2 = _objc_msgSend(self->_actionEvents,sel_lastObject);
  pvVar3 = _objc_msgSend(cls_HSPlayAnimationAction,sel_actionType);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionsOfType_forEvent_,pvVar3,pvVar2);
  pvVar4 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar4 == (id)0x0) {
    self->_initialAnimation = (id)0x0;
    self_00 = cls_HSAnimation;
    op = sel_new;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar1,sel_count,pvVar3,pvVar2);
    if (pvVar3 != (id)0x1) {
      return;
    }
    pvVar3 = (id)0x0;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_animation);
    self_00 = _objc_msgSend(pvVar1,sel_copy);
    self->_initialAnimation = self_00;
    op = sel_copy;
  }
  pvVar1 = _objc_msgSend(self_00,op,pvVar3,pvVar2);
  self->_animation = pvVar1;
  return;
}

*/
- (void)setUpAnimation
{
    [self checkActionsForAllEventsAreEqual];
    NSArray *animationActions = [[self actor] hyperActionsOfType:[HSPlayAnimationAction actionType] forEvent:[_actionEvents lastObject]];
    if ([animationActions count] == 0) {
        _initialAnimation = nil;
        _animation = [HSAnimation new];
    } else if ([animationActions count] == 1) {
        _initialAnimation = [[[animationActions objectAtIndex:0] animation] copy];
        _animation = [_initialAnimation copy];
    }
}

- (void)checkActionsForAllEventsAreEqual
{
    id self_00;
    NSEnumerator *self_01;
    id self_02;
    NSUInteger pvVar3;
    id pvVar4;
    BOOL bVar5;
    NSUInteger pvVar2_2;

    self_00 = [self actor];
    bVar5 = YES;
    self_01 = [_actionEvents objectEnumerator];
    while( YES ) {
        pvVar4 = [self_01 nextObject];
        if (pvVar4 == nil) break;
        self_02 = [self_00 hyperActionsOfType:[HSPlayAnimationAction actionType] forEvent:pvVar4];
        if (bVar5) {
            bVar5 = self_02 == nil;
        }
        else {
            if ([self_02 count] != 0) {
                pvVar2_2 = 0;
                do {
                    pvVar2_2 = (pvVar2_2 + 1);
                    pvVar3 = [self_02 count];
                } while (pvVar2_2 < pvVar3);
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013e845 @ 0013e845, 627 bytes * /

void FUN_0013e845(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id self_01;
  id pvVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  self_00 = _objc_msgSend(pvVar1,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_mainWindowController);
  pvVar2 = _objc_msgSend(pvVar1,sel_cardView);
  self_01 = _objc_msgSend(self,sel_cardView);
  pvVar3 = _objc_msgSend(self_01,sel_card);
  _objc_msgSend(pvVar2,sel_setCard_,pvVar3);
  _objc_msgSend(self,sel_synchronizeZoomInCardView_withCardView_,pvVar2,self_01);
  pvVar2 = _objc_msgSend(self_01,sel_enclosingScrollView);
  _objc_msgSend(pvVar1,sel_useScrollerPositionFrom_,pvVar2);
  _objc_msgSend(self_00,sel_switchWithoutAnimationToModeController_deffered_,pvVar1,0);
  pvVar1 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_updateChangeCount_,1);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_stackView);
  _objc_msgSend(pvVar1,sel_setCardNavigationEnabled_,1);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  uVar4 = 0xffffffff;
  if ((self->_applyChanges[0] & 4) == 0) {
    uVar4 = 0;
  }
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,uVar4);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,
                &cfstr_HSEditorCardViewDidChangeZoomFactorNotification,self->_cardView);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,
                &cfstr_HSEditorCardViewDidFitInWindowNotification,self->_cardView);
  _objc_msgSend(self_01,sel_setCard_,0);
  self->_applyChanges[0] = self->_applyChanges[0] & 0xfd;
  return;
}

*/
- (void)switchFromAnimationMode
{
    id document = [self document];
    id modeSwitcher = [document modeSwitcher];
    id mainWindowController = [document mainWindowController];
    id mainCardView = [mainWindowController cardView];
    id cardView = [self cardView];
    [mainCardView setCard:[cardView card]];
    [self synchronizeZoomInCardView:mainCardView withCardView:cardView];
    [mainWindowController useScrollerPositionFrom:[cardView enclosingScrollView]];
    [modeSwitcher switchWithoutAnimationToModeController:mainWindowController deffered:NO];
    [[self document] updateChangeCount:1];
    [[[self document] stackView] setCardNavigationEnabled:YES];
    [[self assistant] setSupportsSettingsOnTheSpotMode:_initialInspectorSupportsSOTSMode ? YES : NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSEditorCardViewDidChangeZoomFactorNotification" object:_cardView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSEditorCardViewDidFitInWindowNotification" object:_cardView];
    [cardView setCard:nil];
    _switchFromAnimationModeOnCancelPathCreation = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013eab8 @ 0013eab8, 682 bytes * /

void FUN_0013eab8(HSAnimationModeController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  float local_24;
  float local_20;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  self_00 = _objc_msgSend(pvVar1,sel_modeSwitcher);
  self_01 = _objc_msgSend(self,sel_cardView);
  pvVar1 = _objc_msgSend(pvVar1,sel_mainWindowController);
  pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar1,sel_card);
  _objc_msgSend(self_01,sel_setCard_,pvVar2);
  _objc_msgSend(self,sel_synchronizeZoomInCardView_withCardView_,self_01,pvVar1);
  _objc_msgSend_stret(&local_24,pvVar1,sel_visibleRect);
  (self->_pointToScrollCardView).x = local_24;
  (self->_pointToScrollCardView).y = local_20;
  _objc_msgSend(self_00,sel_switchWithoutAnimationToModeController_deffered_,self,1);
  pvVar1 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_updateChangeCount_,0);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_stackView);
  _objc_msgSend(pvVar1,sel_setCardNavigationEnabled_,0);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_supportsSettingsOnTheSpotMode);
  self->_applyChanges[0] = self->_applyChanges[0] & 0xfb | ((byte)pvVar1 & 1) << 2;
  pvVar1 = _objc_msgSend(self,sel_assistant);
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,0);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_cardViewDidChangeZoomFactor_,
                &cfstr_HSEditorCardViewDidChangeZoomFactorNotification,self->_cardView);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_cardViewDidChangeZoomFactor_,
                &cfstr_HSEditorCardViewDidFitInWindowNotification,self->_cardView);
  _objc_msgSend(self,sel_updateUI_,0);
  return;
}

*/
- (void)switchToAnimationMode
{
    id document = [self document];
    id modeSwitcher = [document modeSwitcher];
    id cardView = [self cardView];
    id mainCardView = [[document mainWindowController] cardView];
    [cardView setCard:[mainCardView card]];
    [self synchronizeZoomInCardView:cardView withCardView:mainCardView];
    NSRect visible = [mainCardView visibleRect];
    _pointToScrollCardView = visible.origin;
    [modeSwitcher switchWithoutAnimationToModeController:self deffered:YES];
    [[self document] updateChangeCount:0];
    [[[self document] stackView] setCardNavigationEnabled:NO];
    _initialInspectorSupportsSOTSMode = [[self assistant] supportsSettingsOnTheSpotMode] ? 1 : 0;
    [[self assistant] setSupportsSettingsOnTheSpotMode:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardViewDidChangeZoomFactor:) name:@"HSEditorCardViewDidChangeZoomFactorNotification" object:_cardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardViewDidChangeZoomFactor:) name:@"HSEditorCardViewDidFitInWindowNotification" object:_cardView];
    [self updateUI:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013ed62 @ 0013ed62, 109 bytes * /

void FUN_0013ed62(HSAnimationModeController *self,SEL _cmd,id synchronizeZoomInCardView,
                 id withCardView)

{
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(withCardView,sel_zoomMode);
  _objc_msgSend(synchronizeZoomInCardView,sel_setZoomMode_,pvVar1);
  dVar2 = _objc_msgSend_fpret(withCardView,sel_zoomFactor);
  _objc_msgSend(synchronizeZoomInCardView,sel_zoomToFactor_,(float)dVar2);
  return;
}

*/
- (void)synchronizeZoomInCardView:(id)aView withCardView:(id)aView2
{
    [aView setZoomMode:[aView2 zoomMode]];
    [aView zoomToFactor:[aView2 zoomFactor]];
}

- (void)setActingObject:(id)aObject actionEvents:(id)aEvents assistant:(id)aAssistant assistantNavigationController:(id)aController
{
    [aObject retain];
    [_actingObject release];
    _actingObject = aObject;
    [self setActionEvents:aEvents];
    [aAssistant retain];
    [_assistant release];
    _assistant = aAssistant;
    [self setAssistantNavigationController:aController];
}

- (void)setAssistantNavigationController:(id)aController
{
    [aController retain];
    [_assistantNavigationController release];
    _assistantNavigationController = aController;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013eebc @ 0013eebc, 195 bytes * /

void FUN_0013eebc(HSAnimationModeController *self,SEL _cmd,id createAnimationForActingObject,
                 id actionEvents,id animatedObject,id assistant,id assistantNavigationController)

{
  _objc_msgSend(self,sel_lockAssistantIfNeeded);
  _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,
                createAnimationForActingObject,actionEvents,assistant,assistantNavigationController)
  ;
  _objc_msgSend(self,sel_setUpAnimation);
  _objc_msgSend(self->_animation,sel_setAnimatedObject_,animatedObject);
  _objc_msgSend(self,sel_configureAnimatedObjectAndAnimation);
  _objc_msgSend(self,sel_setUpUndoHelper);
  _objc_msgSend(self,sel_switchToAnimationMode);
  self->_applyChanges[0] = self->_applyChanges[0] | 2;
  return;
}

*/
- (void)createAnimationForActingObject:(id)aObject actionEvents:(id)aEvents animatedObject:(id)aObject2 assistant:(id)aAssistant assistantNavigationController:(id)aController
{
    [self lockAssistantIfNeeded];
    [self setActingObject:aObject actionEvents:aEvents assistant:aAssistant assistantNavigationController:aController];
    [self setUpAnimation];
    [_animation setAnimatedObject:aObject2];
    [self configureAnimatedObjectAndAnimation];
    [self setUpUndoHelper];
    [self switchToAnimationMode];
    _switchFromAnimationModeOnCancelPathCreation = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013ef7f @ 0013ef7f, 953 bytes * /

void FUN_0013ef7f(HSAnimationModeController *self,SEL _cmd,id createAnimationForActingObject,
                 BOOL byDragAndDrop,id actionEvents,id animatedObject,id assistant)

{
  undefined4 uVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  HSAnimationModeController *pHVar4;
  id pvVar5;
  undefined4 *puVar6;
  SEL op;
  int iVar7;
  id pvVar8;
  
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar2,sel_setSelectedInModelObjectAndBringAssistantToFront_,
                createAnimationForActingObject);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar8 = (id)0x0;
  _objc_msgSend(pvVar2,sel_setActive_explicitlyByUser_,1,0);
  self_00 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  pvVar2 = createAnimationForActingObject;
  pvVar3 = _objc_msgSend(self_00,sel_dropHelpPaneForObject_,createAnimationForActingObject);
  pHVar4 = _objc_msgSend(pvVar3,sel_objectAssistantNavigationController);
  if (pHVar4 == (HSAnimationModeController *)0x0) {
    pvVar3 = _objc_msgSend(assistant,sel_paneHistory,pvVar2,pvVar8);
    pvVar5 = _objc_msgSend(pvVar3,sel_count);
    if (pvVar5 == (id)0x0) {
      pvVar3 = (id)0x0;
    }
    else {
      pvVar2 = (id)((int)pvVar5 + -1);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar2);
    }
    pHVar4 = _objc_msgSend(pvVar3,sel_objectAssistantNavigationController,pvVar2);
  }
  pvVar2 = _objc_msgSend(createAnimationForActingObject,sel_implementsHyperInterface_,&DAT_00372e28)
  ;
  puVar6 = (undefined4 *)PTR_003365cc;
  if ((char)pvVar2 == '\0') {
    puVar6 = (undefined4 *)PTR_003365d0;
  }
  uVar1 = *puVar6;
  pvVar2 = _objc_msgSend(self_00,sel_dontShowCoachingHintsForKey_,uVar1);
  if (((char)pvVar2 == '\0') && (byDragAndDrop != '\0')) {
    pvVar3 = _objc_msgSend(self_00,sel_dropHelpPaneForObject_,createAnimationForActingObject);
    pvVar5 = _objc_msgSend(pvVar3,sel_conformsToProtocol_,&DAT_00372ec8);
    pvVar2 = pvVar3;
    if ((char)pvVar5 == '\0') {
      _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,0
                    ,0,assistant,pHVar4);
      pvVar2 = _objc_msgSend(cls_HSAnimationDropHelpPane,sel_paneWithCoachingKey_,uVar1);
      _objc_msgSend(pvVar2,sel_setActingObject_,createAnimationForActingObject);
      _objc_msgSend(pvVar2,sel_setDelegate_,self);
      pvVar8 = _objc_msgSend(pvVar2,sel_dropHelpPaneIdentifier);
      _objc_msgSend(self,sel_openAssistantPaneAsInitialIfNeeded_withIdentifier_,pvVar2,pvVar8);
      _objc_msgSend(self_00,sel_addDropHelpPane_forObject_,pvVar2,createAnimationForActingObject);
      if (pvVar3 != (id)0x0) {
        self->_revertMode = 2;
      }
      pvVar8 = (id)0x0;
      _objc_msgSend(self,sel_setActingObject_actionEvents_assistant_assistantNavigationController_,0
                    ,0,0,0);
    }
    _objc_msgSend(pvVar2,sel_setAnimatedObject_,animatedObject,pvVar8);
    _objc_msgSend(pvVar2,sel_setActionEvents_,actionEvents);
    iVar7 = self->_revertMode;
    _objc_msgSend(pvVar2,sel_setRevertMode_,iVar7);
    if (pvVar3 == pvVar2) {
      return;
    }
    pvVar2 = _objc_msgSend(pvVar3,sel_dropHelpPaneIdentifier,iVar7);
    self = pHVar4;
    op = sel_removeAllViewControllersWithIdentifier_;
    actionEvents = pvVar8;
  }
  else {
    _objc_msgSend(self,
                  sel_createAnimationForActingObject_actionEvents_animatedObject_assistant_assistantNavigationController_
                  ,createAnimationForActingObject,actionEvents,animatedObject,assistant,pHVar4);
    pvVar2 = (id)0x1;
    _objc_msgSend(self,sel_setState_,1);
    op = sel_runDrawPath;
  }
  _objc_msgSend(self,op,pvVar2,actionEvents);
  return;
}

*/
- (void)createAnimationForActingObject:(id)aObject byDragAndDrop:(BOOL)aDrop actionEvents:(id)aEvents animatedObject:(id)aObject2 assistant:(id)aAssistant
{
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:aObject];
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:NO];
    HSCoachingHelpManager *helpManager = [HSCoachingHelpManager sharedCoachingHelpManager];
    id dropPane = [helpManager dropHelpPaneForObject:aObject];
    id navigation = [dropPane objectAssistantNavigationController];
    if (navigation == nil) {
        NSArray *history = [aAssistant paneHistory];
        id lastPane = [history count] == 0 ? nil : [history objectAtIndex:[history count] - 1];
        navigation = [lastPane objectAssistantNavigationController];
    }
    NSString *key = [aObject implementsHyperInterface:@protocol(HSCardAttributes)] ? HSAnimationDropIntoCardKey : HSAnimationDropIntoObjectKey;
    if (![helpManager dontShowCoachingHintsForKey:key] && aDrop) {
        id oldPane = [helpManager dropHelpPaneForObject:aObject];
        id pane = oldPane;
        if (![oldPane conformsToProtocol:@protocol(HSAnimationDropHelpPaneInterface)]) {
            [self setActingObject:nil actionEvents:nil assistant:aAssistant assistantNavigationController:navigation];
            pane = [HSAnimationDropHelpPane paneWithCoachingKey:key];
            [pane setActingObject:aObject];
            [pane setDelegate:self];
            [self openAssistantPaneAsInitialIfNeeded:pane withIdentifier:[pane dropHelpPaneIdentifier]];
            [helpManager addDropHelpPane:pane forObject:aObject];
            if (oldPane != nil) {
                _revertMode = 2;
            }
            [self setActingObject:nil actionEvents:nil assistant:nil assistantNavigationController:nil];
        }
        [pane setAnimatedObject:aObject2];
        [pane setActionEvents:aEvents];
        [pane setRevertMode:_revertMode];
        if (oldPane != pane) {
            [navigation removeAllViewControllersWithIdentifier:[oldPane dropHelpPaneIdentifier]];
        }
    } else {
        [self createAnimationForActingObject:aObject actionEvents:aEvents animatedObject:aObject2 assistant:aAssistant assistantNavigationController:navigation];
        [self setState:1];
        [self runDrawPath];
    }
}

- (void)editAnimationForActingObject:(id)aObject actionEvents:(id)aEvents assistant:(id)aAssistant assistantNavigationController:(id)aController
{
    [self lockAssistantIfNeeded];
    [self setActingObject:aObject actionEvents:aEvents assistant:aAssistant assistantNavigationController:aController];
    [self setUpAnimation];
    [self setUpUndoHelper];
    [self switchToAnimationMode];
    [self setState:2];
    [self runEditPath:YES openMainAssistantPane:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013f402 @ 0013f402, 52 bytes * /

id FUN_0013f402(HSAnimationModeController *self,SEL _cmd)

{
  SEL op;
  id pvVar1;
  
  op = sel_dummyUndoManager;
  if (self->_state == 2) {
    op = sel_undoManager;
  }
  pvVar1 = _objc_msgSend(self,op);
  return pvVar1;
}

*/
- (id)preferedUndoManager
{
    return (_state == 2) ? [self undoManager] : [self dummyUndoManager];
}

- (void)setActionEvents:(id)aEvents
{
    if (![_actionEvents isEqualToArray:aEvents]) {
        [aEvents retain];
        [_actionEvents release];
        _actionEvents = aEvents;
    }
}

- (id)actionEvents
{
    return _actionEvents;
}

- (void)documentUndoManagerDidRemoveAllActions:(id)aActions
{

}

- (id)windowWillReturnUndoManager:(id)aManager
{
    return [self preferedUndoManager];
}

- (id)dummyUndoManager
{
    return _dummyUndoManager;
}

- (id)undoManager
{
    return _undoManager;
}

- (void)windowWillClose:(id)aClose
{
    [self unlockAssistantIfNeeded];
    [_assistant deactivate];
}

- (void)awakeFromNib
{
    [_cardView retain];
    [_cardView removeFromSuperviewWithoutNeedingDisplay];
    [self setWindow:0];
}

- (id)windowNibName
{
    return @"AnimationMode";
}

- (void)dealloc
{
    [_undoHelper finishDuplicating:NO];
    [_undoHelper release];
    [_undoManager release];
    [_dummyUndoManager release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_actingObject release];
    [_actionEvents release];
    [_animation release];
    [_initialAnimation release];
    [_tryItAnimation release];
    [_storedPath release];
    [_storedKeyFrames release];
    [_assistant release];
    [_assistantNavigationController release];
    [_mainAssistantPane setDelegate:0];
    [_mainAssistantPane release];
    [_pickImageAssistantPane setDelegate:0];
    [_pickImageAssistantPane release];
    [_drawPathAssistantPane setDelegate:0];
    [_drawPathAssistantPane release];
    [_dropHelpPane setDelegate:0];
    [_dropHelpPane release];
    [_transparentColorAssistantPane setDelegate:0];
    [_transparentColorAssistantPane release];
    [_cardView setDelegate:0];
    [_cardView release];
    _mainAreaTintedView = nil;
    _workAreaView = nil;
    _bottomAreaTintedView = nil;
    [self setEditPathTool:nil];
    [self resetToolToDefault];
    [super dealloc];
}

- (id)initWithWindow:(id)aWindow
{
    id pvVar2_2;

    self = [super initWithWindow:aWindow];
    if (self != nil) {
        _undoManager = [HSUndoManager new];
        pvVar2_2 = [NSUndoManager new];
        _dummyUndoManager = pvVar2_2;
        [pvVar2_2 disableUndoRegistration];
    }
    return self;
}

@end

