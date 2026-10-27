#import "HSLayoutRulesCanvasLayer.h"

// FUN_000adfde: map key comparison by identity
static BOOL HSLayoutRulesIsEqualByIdentity(NSMapTable *table, const void *a, const void *b)
{
    return a == b;
}

@implementation HSLayoutRulesCanvasLayer

/* i386 ivar offsets: _xSideLayoutGuidingRuleRects=0x1c, _ySideLayoutGuidingRuleRects=0x20, _xMiddleLayoutGuidingRuleRects=0x24, _yMiddleLayoutGuidingRuleRects=0x28, _widthLayoutGuidingRuleRects=0x2c, _heightLayoutGuidingRuleRects=0x30, _snappedRect=0x34, _widthRuleInitialRectsAndTransforms=0x44, _heightRuleInitialRectsAndTransforms=0x48 */

- (id)guidelinesColor
{
    return [NSColor objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSGuidelinesColor"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ae306 @ 000ae306, 7228 bytes * /

void FUN_000ae306(HSLayoutRulesCanvasLayer *self,SEL _cmd,id setAppliedLayoutRules,
                 NSRect forSnappingRect)

{
  float *pfVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  undefined4 extraout_EDX;
  int *piVar10;
  int *piVar11;
  float *pfVar12;
  int *piVar13;
  int iVar14;
  longdouble lVar15;
  longdouble lVar16;
  float fVar17;
  float fVar18;
  double dVar19;
  int aiStack_3b4 [2];
  float local_374;
  undefined4 local_34c;
  undefined4 local_348;
  undefined4 local_344;
  undefined4 local_340;
  float local_33c;
  undefined4 uStack_338;
  undefined4 local_334;
  float fStack_330;
  undefined4 local_32c;
  undefined4 local_328;
  undefined4 local_324;
  undefined4 local_320;
  undefined4 local_31c;
  float fStack_318;
  float local_314;
  undefined4 uStack_310;
  undefined4 local_30c;
  undefined4 local_308;
  undefined4 local_304;
  undefined4 local_300;
  float local_2fc;
  undefined4 uStack_2f8;
  undefined4 local_2f4;
  float fStack_2f0;
  undefined4 local_2ec;
  undefined4 local_2e8;
  undefined4 local_2e4;
  undefined4 local_2e0;
  undefined4 local_2dc;
  float fStack_2d8;
  float local_2d4;
  undefined4 uStack_2d0;
  float local_2cc;
  float local_2c8;
  float local_2c4;
  float local_2c0;
  undefined8 local_2bc;
  undefined8 local_2b4;
  undefined8 local_2ac;
  undefined8 local_2a4;
  undefined8 local_29c;
  undefined8 local_294;
  undefined1 local_28c [8];
  float local_284;
  float local_280;
  float local_27c;
  float fStack_278;
  float local_274;
  float fStack_270;
  float local_26c;
  float local_268;
  float local_264;
  float local_260;
  undefined8 local_25c;
  undefined8 local_254;
  undefined8 local_24c;
  undefined8 local_244;
  undefined8 local_23c;
  undefined8 local_234;
  undefined8 local_22c;
  undefined8 local_224;
  undefined8 local_21c;
  undefined8 local_214;
  undefined8 local_20c;
  undefined8 local_204;
  undefined8 local_1fc;
  undefined8 local_1f4;
  undefined8 local_1ec;
  undefined4 local_1e4;
  undefined4 local_1e0;
  undefined4 local_1dc;
  undefined4 local_1d8;
  undefined4 local_1d4;
  undefined4 uStack_1d0;
  undefined4 local_1cc;
  undefined4 uStack_1c8;
  undefined4 local_1c4;
  undefined4 local_1c0;
  undefined4 local_1bc;
  undefined4 local_1b8;
  undefined4 local_1b4;
  undefined4 uStack_1b0;
  undefined4 local_1ac;
  undefined4 uStack_1a8;
  undefined8 local_1a4;
  undefined8 local_19c;
  float local_194;
  float fStack_190;
  undefined4 local_18c;
  float fStack_188;
  float local_184;
  float fStack_180;
  undefined4 local_17c;
  float fStack_178;
  float local_174;
  float fStack_170;
  float local_16c;
  undefined4 uStack_168;
  float local_164;
  float fStack_160;
  float local_15c;
  undefined4 uStack_158;
  undefined8 local_154;
  undefined8 local_14c;
  undefined4 local_144;
  float fStack_140;
  float local_13c;
  undefined4 uStack_138;
  undefined4 local_134;
  undefined4 uStack_130;
  undefined4 local_12c;
  undefined4 uStack_128;
  undefined8 local_124;
  undefined8 local_11c;
  float local_114;
  undefined4 uStack_110;
  undefined4 local_10c;
  float fStack_108;
  undefined4 local_104;
  undefined4 uStack_100;
  undefined4 local_fc;
  undefined4 uStack_f8;
  undefined8 local_f4;
  undefined8 local_ec;
  undefined8 local_e4;
  undefined8 local_dc;
  undefined4 local_d4;
  float fStack_d0;
  float local_cc;
  undefined4 uStack_c8;
  undefined4 local_c4;
  undefined4 uStack_c0;
  undefined4 local_bc;
  undefined4 uStack_b8;
  undefined8 local_b4;
  undefined8 local_ac;
  float local_a4;
  undefined4 uStack_a0;
  undefined4 local_9c;
  float fStack_98;
  undefined4 local_94;
  undefined4 uStack_90;
  undefined4 local_8c;
  undefined4 uStack_88;
  undefined8 local_84;
  undefined8 local_7c;
  undefined8 local_74;
  undefined8 local_6c;
  undefined8 local_64;
  undefined8 local_5c;
  undefined8 local_54;
  undefined8 local_4c;
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pfVar12 = (float *)&stack0xfffffc54;
  (self->_snappedRect).origin.x = forSnappingRect.origin.x;
  (self->_snappedRect).origin.y = forSnappingRect.origin.y;
  (self->_snappedRect).size.width = forSnappingRect.size.width;
  (self->_snappedRect).size.height = forSnappingRect.size.height;
  pvVar3 = _objc_msgSend(self->_xSideLayoutGuidingRuleRects,sel_count);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)&stack0xfffffc54;
    do {
      pvVar4 = self->_xSideLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xae380;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_25c;
      piVar13[-1] = 0xae39c;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_254;
      *(undefined8 *)(piVar13 + 1) = local_25c;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xae3cd;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_ySideLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.000121e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_ySideLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xae416;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_24c;
      piVar13[-1] = 0xae432;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_244;
      *(undefined8 *)(piVar13 + 1) = local_24c;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xae463;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_xMiddleLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.000331e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_xMiddleLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xae4ac;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_23c;
      piVar13[-1] = 0xae4c8;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_234;
      *(undefined8 *)(piVar13 + 1) = local_23c;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xae4f9;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_yMiddleLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.000541e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_yMiddleLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xae542;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_22c;
      piVar13[-1] = 0xae55e;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_224;
      *(undefined8 *)(piVar13 + 1) = local_22c;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xae58f;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_widthLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.000751e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_widthLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xae5d8;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_21c;
      piVar13[-1] = 0xae5f4;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_214;
      *(undefined8 *)(piVar13 + 1) = local_21c;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xae625;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_heightLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.000962e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_heightLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xae66e;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_20c;
      piVar13[-1] = 0xae68a;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_204;
      *(undefined8 *)(piVar13 + 1) = local_20c;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xae6bb;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_xSideLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_removeAllObjects;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.001172e-39;
  _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  pvVar3 = self->_ySideLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_removeAllObjects;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.001201e-39;
  _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  pvVar3 = self->_xMiddleLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_removeAllObjects;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.00123e-39;
  _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  pvVar3 = self->_yMiddleLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_removeAllObjects;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.00126e-39;
  _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  pvVar3 = self->_widthLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_removeAllObjects;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.00129e-39;
  _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  pvVar3 = self->_heightLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_removeAllObjects;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.001319e-39;
  _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  *pfVar12 = (float)self->_widthRuleInitialRectsAndTransforms;
  pfVar12[-1] = 1.001334e-39;
  _NSResetMapTable();
  *pfVar12 = (float)self->_heightRuleInitialRectsAndTransforms;
  pfVar12[-1] = 1.00135e-39;
  _NSResetMapTable();
  local_26c = *(float *)PTR_00336078;
  local_268 = *(float *)(PTR_00336078 + 4);
  local_264 = *(float *)(PTR_00336078 + 8);
  local_260 = *(float *)(PTR_00336078 + 0xc);
  local_27c = (self->_snappedRect).origin.x;
  fStack_278 = (self->_snappedRect).origin.y;
  local_274 = (self->_snappedRect).size.width;
  fStack_270 = (self->_snappedRect).size.height;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)setAppliedLayoutRules;
  pfVar12[-1] = 1.001532e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    local_374 = 0.0;
    do {
      pfVar12[1] = (float)sel_alloc;
      *pfVar12 = (float)cls_NSAutoreleasePool;
      pfVar12[-1] = 1.001599e-39;
      pvVar4 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
      pfVar12[1] = (float)sel_init;
      *pfVar12 = (float)pvVar4;
      pfVar12[-1] = 1.001624e-39;
      pvVar4 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
      pfVar12[2] = local_374;
      pfVar12[1] = (float)sel_objectAtIndex_;
      *pfVar12 = (float)setAppliedLayoutRules;
      pfVar12[-1] = 1.001676e-39;
      pvVar5 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
      pfVar12[1] = (float)sel_affectedRectSidesCount;
      *pfVar12 = (float)pvVar5;
      pfVar12[-1] = 1.00171e-39;
      pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
      if (pvVar6 != (id)0x0) {
        pfVar12[1] = (float)sel_ruleType;
        *pfVar12 = (float)pvVar5;
        pfVar12[-1] = 1.001755e-39;
        pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
        if (pvVar6 == (id)0x1) {
          pfVar12[1] = (float)sel_geometryHoldersUsed;
          *pfVar12 = (float)pvVar5;
          pfVar12[-1] = 1.001801e-39;
          pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          pfVar12[1] = (float)sel_objectEnumerator;
          *pfVar12 = (float)pvVar6;
          pfVar12[-1] = 1.001826e-39;
          pvVar7 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          pfVar12[1] = (float)sel_alloc;
          *pfVar12 = (float)cls_HSMutableRegion;
          pfVar12[-1] = 1.001868e-39;
          pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          pfVar12[1] = (float)sel_init;
          *pfVar12 = (float)pvVar6;
          pfVar12[-1] = 1.001893e-39;
          pvVar8 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          *(ulonglong *)(pfVar12 + 4) = CONCAT44(fStack_270,local_274);
          *(ulonglong *)(pfVar12 + 2) = CONCAT44(fStack_278,local_27c);
          pfVar12[1] = (float)sel_addRect_;
          *pfVar12 = (float)pvVar8;
          pfVar12[-1] = 1.001966e-39;
          _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          pfVar12[1] = (float)sel_nextObject;
          *pfVar12 = (float)pvVar7;
          pfVar12[-1] = 1.002e-39;
          pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          pfVar1 = pfVar12;
          while (pvVar6 != (id)0x0) {
            pfVar1[2] = (float)sel_hyperLayoutInfluencingTransform;
            pfVar1[1] = (float)pvVar6;
            *pfVar1 = (float)&local_1fc;
            pfVar1[-1] = 1.002053e-39;
            _objc_msgSend_stret((void *)*pfVar1,(id)pfVar1[1],(SEL)pfVar1[2]);
            pfVar1[1] = (float)sel_hyperLayoutInfluencingBoundingRect;
            *pfVar1 = (float)pvVar6;
            pfVar1[-1] = (float)&local_1e4;
            pfVar1[-2] = 1.002097e-39;
            _objc_msgSend_stret((void *)pfVar1[-1],(id)*pfVar1,(SEL)pfVar1[1]);
            local_1d4 = local_1e4;
            uStack_1d0 = local_1e0;
            local_1cc = local_1dc;
            uStack_1c8 = local_1d8;
            *(undefined8 *)(pfVar1 + 7) = local_1ec;
            *(undefined8 *)(pfVar1 + 5) = local_1f4;
            *(undefined8 *)(pfVar1 + 3) = local_1fc;
            *(ulonglong *)(pfVar1 + 1) = CONCAT44(local_1d8,local_1dc);
            *(ulonglong *)(pfVar1 + -1) = CONCAT44(local_1e0,local_1e4);
            pfVar1[-2] = (float)&local_1c4;
            pfVar1[-3] = 1.002308e-39;
            _CGRectApplyAffineTransform();
            local_1b4 = local_1c4;
            uStack_1b0 = local_1c0;
            local_1ac = local_1bc;
            uStack_1a8 = local_1b8;
            *(ulonglong *)(pfVar1 + 1) = CONCAT44(local_1b8,local_1bc);
            *(ulonglong *)(pfVar1 + -1) = CONCAT44(local_1c0,local_1c4);
            pfVar1[-2] = (float)sel_addRect_;
            pfVar1[-3] = (float)pvVar8;
            pfVar1[-4] = 1.002475e-39;
            _objc_msgSend((id)pfVar1[-3],(SEL)pfVar1[-2]);
            pfVar1[-2] = (float)sel_nextObject;
            pfVar1[-3] = (float)pvVar7;
            pfVar1[-4] = 1.002509e-39;
            pvVar6 = _objc_msgSend((id)pfVar1[-3],(SEL)pfVar1[-2]);
            pfVar1 = pfVar1 + -3;
          }
          pfVar1[1] = (float)sel_context;
          *pfVar1 = (float)self;
          pfVar1[-1] = 1.002552e-39;
          pvVar6 = _objc_msgSend((id)*pfVar1,(SEL)pfVar1[1]);
          pfVar1[1] = (float)sel_renderingView;
          *pfVar1 = (float)pvVar6;
          pfVar1[-1] = 1.002577e-39;
          pvVar6 = _objc_msgSend((id)*pfVar1,(SEL)pfVar1[1]);
          pfVar1[2] = (float)sel_boundingRect;
          pfVar1[1] = (float)pvVar8;
          *pfVar1 = (float)&local_1a4;
          pfVar1[-1] = 1.002628e-39;
          _objc_msgSend_stret((void *)*pfVar1,(id)pfVar1[1],(SEL)pfVar1[2]);
          *(undefined8 *)(pfVar1 + 4) = local_19c;
          *(undefined8 *)(pfVar1 + 2) = local_1a4;
          pfVar1[1] = (float)sel_viewBoundingRectForUserRect_;
          *pfVar1 = (float)pvVar6;
          pfVar1[-1] = (float)&local_26c;
          pfVar1[-2] = 1.00271e-39;
          _objc_msgSend_stret((void *)pfVar1[-1],(id)*pfVar1,(SEL)pfVar1[1]);
          pfVar1[-1] = (float)sel_release;
          pfVar1[-2] = (float)pvVar8;
          pfVar1[-3] = 1.002748e-39;
          _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
          pfVar1[-1] = (float)sel_affectedRectSidesCount;
          pfVar1[-2] = (float)pvVar5;
          pfVar1[-3] = 1.002782e-39;
          pvVar6 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
          pfVar12 = pfVar1 + -2;
          if (pvVar6 != (id)0x0) {
            pvVar7 = (id)0x0;
            do {
              *pfVar1 = (float)pvVar7;
              pfVar1[-1] = (float)sel_affectedRectSideAtIndex_;
              pfVar1[-2] = (float)pvVar5;
              pfVar1[-3] = 1.002843e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              *pfVar1 = (float)pvVar8;
              pfVar1[-1] = (float)sel_layoutRuleFloatValueForRectSide_;
              pfVar1[-2] = (float)pvVar5;
              pfVar1[-3] = 1.002883e-39;
              dVar19 = _objc_msgSend_fpret((id)pfVar1[-2],(SEL)pfVar1[-1]);
              pfVar1[-1] = (float)sel_context;
              pfVar1[-2] = (float)self;
              pfVar1[-3] = 1.00292e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              pfVar1[-1] = (float)sel_renderingView;
              pfVar1[-2] = (float)pvVar8;
              pfVar1[-3] = 1.002963e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              pfVar1[1] = (float)dVar19;
              *pfVar1 = (float)dVar19;
              pfVar1[-1] = (float)sel_convertPointFromUserSpaceToViewSpace_;
              pfVar1[-2] = (float)pvVar8;
              pfVar1[-3] = 1.003016e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              pfVar1[-2] = (float)pvVar8;
              pfVar1[-3] = 1.00303e-39;
              lVar15 = (longdouble)_floorf();
              pfVar1[-2] = (float)extraout_EDX;
              pfVar1[-3] = 1.00305e-39;
              lVar16 = (longdouble)_floorf();
              pfVar1[-1] = (float)sel_affectsRectSide_;
              pfVar1[-2] = (float)pvVar5;
              *pfVar1 = 0.0;
              pfVar1[-3] = 1.00312e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              fVar17 = (float)lVar15 + 0.5;
              fVar18 = (float)lVar16 + 0.5;
              if ((char)pvVar8 == '\0') {
                pfVar1[-1] = (float)sel_affectsRectSide_;
                pfVar1[-2] = (float)pvVar5;
                *pfVar1 = 2.8026e-45;
                pfVar1[-3] = 1.003237e-39;
                pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
                if ((char)pvVar8 != '\0') goto LAB_000aeca6;
              }
              else {
LAB_000aeca6:
                pvVar8 = self->_xSideLayoutGuidingRuleRects;
                local_194 = fVar17;
                fStack_190 = local_268;
                local_18c = 0x3f800000;
                fStack_188 = local_260;
                *(ulonglong *)(pfVar1 + 2) = CONCAT44(local_260,0x3f800000);
                *(ulonglong *)pfVar1 = CONCAT44(local_268,fVar17);
                pfVar1[-1] = (float)sel_valueWithRect_;
                pfVar1[-2] = (float)cls_NSValue;
                pfVar1[-3] = 1.003411e-39;
                pvVar9 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
                *pfVar1 = (float)pvVar9;
                pfVar1[-1] = (float)sel_addObject_;
                pfVar1[-2] = (float)pvVar8;
                pfVar1[-3] = 1.003442e-39;
                _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              }
              pfVar1[-1] = (float)sel_affectsRectSide_;
              pfVar1[-2] = (float)pvVar5;
              *pfVar1 = 5.60519e-45;
              pfVar1[-3] = 1.003487e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              if ((char)pvVar8 != '\0') {
                pvVar8 = self->_xMiddleLayoutGuidingRuleRects;
                local_184 = fVar17;
                fStack_180 = local_268 + -15.0;
                local_17c = 0x3f800000;
                fStack_178 = local_260 + 30.0;
                *(ulonglong *)(pfVar1 + 2) = CONCAT44(local_260 + 30.0,0x3f800000);
                *(ulonglong *)pfVar1 = CONCAT44(local_268 + -15.0,fVar17);
                pfVar1[-1] = (float)sel_valueWithRect_;
                pfVar1[-2] = (float)cls_NSValue;
                pfVar1[-3] = 1.003683e-39;
                pvVar9 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
                *pfVar1 = (float)pvVar9;
                pfVar1[-1] = (float)sel_addObject_;
                pfVar1[-2] = (float)pvVar8;
                pfVar1[-3] = 1.003714e-39;
                _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              }
              pfVar1[-1] = (float)sel_affectsRectSide_;
              pfVar1[-2] = (float)pvVar5;
              *pfVar1 = 1.4013e-45;
              pfVar1[-3] = 1.003758e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              if ((char)pvVar8 == '\0') {
                pfVar1[-1] = (float)sel_affectsRectSide_;
                pfVar1[-2] = (float)pvVar5;
                *pfVar1 = 4.2039e-45;
                pfVar1[-3] = 1.003809e-39;
                pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
                if ((char)pvVar8 != '\0') goto LAB_000aee3e;
              }
              else {
LAB_000aee3e:
                pvVar8 = self->_ySideLayoutGuidingRuleRects;
                local_174 = local_26c;
                fStack_170 = fVar18;
                local_16c = local_264;
                uStack_168 = 0x3f800000;
                *(ulonglong *)(pfVar1 + 2) = CONCAT44(0x3f800000,local_264);
                *(ulonglong *)pfVar1 = CONCAT44(fVar18,local_26c);
                pfVar1[-1] = (float)sel_valueWithRect_;
                pfVar1[-2] = (float)cls_NSValue;
                pfVar1[-3] = 1.003983e-39;
                pvVar9 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
                *pfVar1 = (float)pvVar9;
                pfVar1[-1] = (float)sel_addObject_;
                pfVar1[-2] = (float)pvVar8;
                pfVar1[-3] = 1.004014e-39;
                _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              }
              pfVar1[-1] = (float)sel_affectsRectSide_;
              pfVar1[-2] = (float)pvVar5;
              *pfVar1 = 7.00649e-45;
              pfVar1[-3] = 1.004058e-39;
              pvVar8 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              if ((char)pvVar8 != '\0') {
                pvVar8 = self->_yMiddleLayoutGuidingRuleRects;
                local_164 = local_26c + -15.0;
                fStack_160 = fVar18;
                local_15c = local_264 + 30.0;
                uStack_158 = 0x3f800000;
                *(ulonglong *)(pfVar1 + 2) = CONCAT44(0x3f800000,local_264 + 30.0);
                *(ulonglong *)pfVar1 = CONCAT44(fVar18,local_26c + -15.0);
                pfVar1[-1] = (float)sel_valueWithRect_;
                pfVar1[-2] = (float)cls_NSValue;
                pfVar1[-3] = 1.004255e-39;
                pvVar9 = _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
                *pfVar1 = (float)pvVar9;
                pfVar1[-1] = (float)sel_addObject_;
                pfVar1[-2] = (float)pvVar8;
                pfVar1[-3] = 1.004285e-39;
                _objc_msgSend((id)pfVar1[-2],(SEL)pfVar1[-1]);
              }
              pvVar7 = (id)((int)pvVar7 + 1);
              pfVar12 = pfVar1 + -2;
            } while (pvVar7 < pvVar6);
          }
        }
        else {
          pfVar12[1] = (float)sel_ruleType;
          *pfVar12 = (float)pvVar5;
          pfVar12[-1] = 1.004344e-39;
          pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
          if (pvVar6 == (id)0x3) {
            pfVar12[1] = (float)sel_geometryHoldersUsed;
            *pfVar12 = (float)pvVar5;
            pfVar12[-1] = 1.00439e-39;
            pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            pfVar12[1] = (float)sel_objectEnumerator;
            *pfVar12 = (float)pvVar6;
            pfVar12[-1] = 1.004416e-39;
            pvVar7 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            pfVar12[1] = (float)sel_nextObject;
            *pfVar12 = (float)pvVar7;
            pfVar12[-1] = 1.00445e-39;
            pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            while (pvVar6 != (id)0x0) {
              pfVar12[1] = (float)sel_context;
              *pfVar12 = (float)self;
              pfVar12[-1] = 1.004493e-39;
              pvVar8 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
              pfVar12[1] = (float)sel_renderingView;
              *pfVar12 = (float)pvVar8;
              pfVar12[-1] = 1.004518e-39;
              pvVar8 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
              pfVar12[2] = (float)sel_hyperLayoutInfluencingBoundingRect;
              pfVar12[1] = (float)pvVar6;
              *pfVar12 = (float)&local_154;
              pfVar12[-1] = 1.00456e-39;
              _objc_msgSend_stret((void *)*pfVar12,(id)pfVar12[1],(SEL)pfVar12[2]);
              *(undefined8 *)(pfVar12 + 4) = local_14c;
              *(undefined8 *)(pfVar12 + 2) = local_154;
              pfVar12[1] = (float)sel_viewBoundingRectForUserRect_;
              *pfVar12 = (float)pvVar8;
              pfVar12[-1] = (float)&local_2cc;
              pfVar12[-2] = 1.004643e-39;
              _objc_msgSend_stret((void *)pfVar12[-1],(id)*pfVar12,(SEL)pfVar12[1]);
              local_26c = local_2cc;
              local_268 = local_2c8;
              local_264 = local_2c4;
              local_260 = local_2c0;
              *pfVar12 = (float)sel_hyperLayoutInfluencingTransform;
              pfVar12[-1] = (float)pvVar6;
              pfVar12[-2] = (float)&local_2bc;
              pfVar12[-3] = 1.004776e-39;
              _objc_msgSend_stret((void *)pfVar12[-2],(id)pfVar12[-1],(SEL)*pfVar12);
              piVar10 = (int *)(pfVar12 + -3);
              *(undefined8 *)(pfVar12 + 3) = local_2ac;
              *(undefined8 *)(pfVar12 + 1) = local_2b4;
              *(undefined8 *)(pfVar12 + -1) = local_2bc;
              pfVar12[-2] = (float)sel_transformWithHyperCGAffineTransform_;
              pfVar12[-3] = (float)cls_NSAffineTransform;
              pfVar12[-4] = 1.004873e-39;
              pvVar6 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              pfVar12[-2] = (float)sel_context;
              pfVar12[-3] = (float)self;
              pfVar12[-4] = 1.004913e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              pfVar12[-2] = (float)sel_renderingView;
              pfVar12[-3] = (float)pvVar8;
              pfVar12[-4] = 1.004938e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              pfVar12[-2] = (float)sel_userSpaceToViewSpaceTransform;
              pfVar12[-3] = (float)pvVar8;
              pfVar12[-4] = 1.004964e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              pfVar12[-1] = (float)pvVar8;
              pfVar12[-2] = (float)sel_appendTransform_;
              pfVar12[-3] = (float)pvVar6;
              pfVar12[-4] = 1.004994e-39;
              _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              pfVar12[-2] = (float)sel_affectsRectSide_;
              pfVar12[-3] = (float)pvVar5;
              pfVar12[-1] = 8.40779e-45;
              pfVar12[-4] = 1.005039e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              if ((char)pvVar8 != '\0') {
                local_2dc = 0;
                fStack_2d8 = local_260 + 6.0;
                local_2d4 = local_264;
                uStack_2d0 = 0x41000000;
                *(ulonglong *)(pfVar12 + 1) = CONCAT44(0x41000000,local_264);
                *(ulonglong *)(pfVar12 + -1) = (ulonglong)(uint)(local_260 + 6.0) << 0x20;
                pfVar12[-2] = (float)sel_valueWithRect_;
                pfVar12[-3] = (float)cls_NSValue;
                pfVar12[-4] = 1.005207e-39;
                pvVar9 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
                pvVar8 = self->_widthRuleInitialRectsAndTransforms;
                pfVar12[-1] = (float)pvVar6;
                pfVar12[-2] = (float)pvVar9;
                pfVar12[-3] = (float)pvVar8;
                pfVar12[-4] = 1.005247e-39;
                _NSMapInsert();
                local_144 = local_2dc;
                fStack_140 = fStack_2d8;
                local_13c = local_2d4;
                uStack_138 = uStack_2d0;
                *(undefined8 *)(pfVar12 + 6) = local_2ac;
                *(undefined8 *)(pfVar12 + 4) = local_2b4;
                *(undefined8 *)(pfVar12 + 2) = local_2bc;
                *(ulonglong *)pfVar12 = CONCAT44(uStack_2d0,local_2d4);
                *(ulonglong *)(pfVar12 + -2) = CONCAT44(fStack_2d8,local_2dc);
                pfVar12[-3] = (float)&local_2ec;
                pfVar12[-4] = 1.005454e-39;
                _CGRectApplyAffineTransform();
                puVar2 = cls_NSValue;
                pvVar8 = self->_widthLayoutGuidingRuleRects;
                pfVar12[-3] = (float)sel_context;
                pfVar12[-4] = (float)self;
                pfVar12[-5] = 1.0055e-39;
                pvVar9 = _objc_msgSend((id)pfVar12[-4],(SEL)pfVar12[-3]);
                pfVar12[-3] = (float)sel_renderingView;
                pfVar12[-4] = (float)pvVar9;
                pfVar12[-5] = 1.005526e-39;
                pvVar9 = _objc_msgSend((id)pfVar12[-4],(SEL)pfVar12[-3]);
                local_134 = local_2ec;
                uStack_130 = local_2e8;
                local_12c = local_2e4;
                uStack_128 = local_2e0;
                *(ulonglong *)(pfVar12 + 1) = CONCAT44(local_2e0,local_2e4);
                *(ulonglong *)(pfVar12 + -1) = CONCAT44(local_2e8,local_2ec);
                pfVar12[-2] = (float)sel_viewBoundingRectForUserRect_;
                pfVar12[-3] = (float)pvVar9;
                pfVar12[-4] = (float)&local_124;
                pfVar12[-5] = 1.005694e-39;
                _objc_msgSend_stret((void *)pfVar12[-4],(id)pfVar12[-3],(SEL)pfVar12[-2]);
                piVar10 = (int *)(pfVar12 + -5);
                *(undefined8 *)(pfVar12 + -1) = local_11c;
                *(undefined8 *)(pfVar12 + -3) = local_124;
                pfVar12[-4] = (float)sel_valueWithRect_;
                pfVar12[-5] = (float)puVar2;
                pfVar12[-6] = 1.005762e-39;
                pvVar9 = _objc_msgSend((id)pfVar12[-5],(SEL)pfVar12[-4]);
                pfVar12[-3] = (float)pvVar9;
                pfVar12[-4] = (float)sel_addObject_;
                pfVar12[-5] = (float)pvVar8;
                pfVar12[-6] = 1.005793e-39;
                _objc_msgSend((id)pfVar12[-5],(SEL)pfVar12[-4]);
              }
              piVar10[1] = (int)sel_affectsRectSide_;
              *piVar10 = (int)pvVar5;
              piVar10[2] = 7;
              piVar10[-1] = 0xaf3de;
              pvVar8 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
              pfVar12 = (float *)piVar10;
              if ((char)pvVar8 != '\0') {
                local_2fc = local_264 + 6.0;
                uStack_2f8 = 0;
                local_2f4 = 0x41000000;
                fStack_2f0 = local_260;
                *(ulonglong *)(piVar10 + 4) = CONCAT44(local_260,0x41000000);
                *(ulonglong *)(piVar10 + 2) = (ulonglong)(uint)(local_264 + 6.0);
                piVar10[1] = (int)sel_valueWithRect_;
                *piVar10 = (int)cls_NSValue;
                piVar10[-1] = 0xaf456;
                pvVar9 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
                pvVar8 = self->_heightRuleInitialRectsAndTransforms;
                piVar10[2] = (int)pvVar6;
                piVar10[1] = (int)pvVar9;
                *piVar10 = (int)pvVar8;
                piVar10[-1] = 0xaf472;
                _NSMapInsert();
                local_114 = local_2fc;
                uStack_110 = uStack_2f8;
                local_10c = local_2f4;
                fStack_108 = fStack_2f0;
                *(undefined8 *)(piVar10 + 9) = local_2ac;
                *(undefined8 *)(piVar10 + 7) = local_2b4;
                *(undefined8 *)(piVar10 + 5) = local_2bc;
                *(ulonglong *)(piVar10 + 3) = CONCAT44(fStack_2f0,local_2f4);
                *(ulonglong *)(piVar10 + 1) = CONCAT44(uStack_2f8,local_2fc);
                *piVar10 = (int)&local_30c;
                piVar10[-1] = 0xaf506;
                _CGRectApplyAffineTransform();
                puVar2 = cls_NSValue;
                pvVar6 = self->_widthLayoutGuidingRuleRects;
                *piVar10 = (int)sel_context;
                piVar10[-1] = (int)self;
                piVar10[-2] = 0xaf527;
                pvVar8 = _objc_msgSend((id)piVar10[-1],(SEL)*piVar10);
                *piVar10 = (int)sel_renderingView;
                piVar10[-1] = (int)pvVar8;
                piVar10[-2] = 0xaf539;
                pvVar8 = _objc_msgSend((id)piVar10[-1],(SEL)*piVar10);
                local_104 = local_30c;
                uStack_100 = local_308;
                local_fc = local_304;
                uStack_f8 = local_300;
                *(ulonglong *)(piVar10 + 4) = CONCAT44(local_300,local_304);
                *(ulonglong *)(piVar10 + 2) = CONCAT44(local_308,local_30c);
                piVar10[1] = (int)sel_viewBoundingRectForUserRect_;
                *piVar10 = (int)pvVar8;
                piVar10[-1] = (int)&local_f4;
                piVar10[-2] = 0xaf5b1;
                _objc_msgSend_stret((void *)piVar10[-1],(id)*piVar10,(SEL)piVar10[1]);
                pfVar12 = (float *)(piVar10 + -2);
                *(undefined8 *)(piVar10 + 2) = local_ec;
                *(undefined8 *)piVar10 = local_f4;
                piVar10[-1] = (int)sel_valueWithRect_;
                piVar10[-2] = (int)puVar2;
                piVar10[-3] = 0xaf5e2;
                pvVar8 = _objc_msgSend((id)piVar10[-2],(SEL)piVar10[-1]);
                *piVar10 = (int)pvVar8;
                piVar10[-1] = (int)sel_addObject_;
                piVar10[-2] = (int)pvVar6;
                piVar10[-3] = 0xaf5f8;
                _objc_msgSend((id)piVar10[-2],(SEL)piVar10[-1]);
              }
              pfVar12[1] = (float)sel_nextObject;
              *pfVar12 = (float)pvVar7;
              pfVar12[-1] = 1.006626e-39;
              pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            }
            pfVar12[1] = (float)sel_ownGeometryHolder;
            *pfVar12 = (float)pvVar5;
            pfVar12[-1] = 1.006673e-39;
            pvVar6 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            pfVar12[1] = (float)sel_context;
            *pfVar12 = (float)self;
            pfVar12[-1] = 1.006705e-39;
            pvVar7 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            pfVar12[1] = (float)sel_renderingView;
            *pfVar12 = (float)pvVar7;
            pfVar12[-1] = 1.00673e-39;
            pvVar7 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
            pfVar12[2] = (float)sel_hyperLayoutInfluencingBoundingRect;
            pfVar12[1] = (float)pvVar6;
            *pfVar12 = (float)&local_e4;
            pfVar12[-1] = 1.006773e-39;
            _objc_msgSend_stret((void *)*pfVar12,(id)pfVar12[1],(SEL)pfVar12[2]);
            *(undefined8 *)(pfVar12 + 4) = local_dc;
            *(undefined8 *)(pfVar12 + 2) = local_e4;
            pfVar12[1] = (float)sel_viewBoundingRectForUserRect_;
            *pfVar12 = (float)pvVar7;
            pfVar12[-1] = (float)local_28c;
            pfVar12[-2] = 1.006855e-39;
            _objc_msgSend_stret((void *)pfVar12[-1],(id)*pfVar12,(SEL)pfVar12[1]);
            *pfVar12 = (float)sel_hyperLayoutInfluencingTransform;
            pfVar12[-1] = (float)pvVar6;
            pfVar12[-2] = (float)&local_2a4;
            pfVar12[-3] = 1.006899e-39;
            _objc_msgSend_stret((void *)pfVar12[-2],(id)pfVar12[-1],(SEL)*pfVar12);
            piVar11 = (int *)(pfVar12 + -3);
            *(undefined8 *)(pfVar12 + 3) = local_294;
            *(undefined8 *)(pfVar12 + 1) = local_29c;
            *(undefined8 *)(pfVar12 + -1) = local_2a4;
            pfVar12[-2] = (float)sel_transformWithHyperCGAffineTransform_;
            pfVar12[-3] = (float)cls_NSAffineTransform;
            pfVar12[-4] = 1.006995e-39;
            pvVar6 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
            pfVar12[-2] = (float)sel_context;
            pfVar12[-3] = (float)self;
            pfVar12[-4] = 1.007036e-39;
            pvVar7 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
            pfVar12[-2] = (float)sel_renderingView;
            pfVar12[-3] = (float)pvVar7;
            pfVar12[-4] = 1.007061e-39;
            pvVar7 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
            pfVar12[-2] = (float)sel_userSpaceToViewSpaceTransform;
            pfVar12[-3] = (float)pvVar7;
            pfVar12[-4] = 1.007087e-39;
            pvVar7 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
            pfVar12[-1] = (float)pvVar7;
            pfVar12[-2] = (float)sel_appendTransform_;
            pfVar12[-3] = (float)pvVar6;
            pfVar12[-4] = 1.007117e-39;
            _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
            pfVar12[-2] = (float)sel_affectsRectSide_;
            pfVar12[-3] = (float)pvVar5;
            pfVar12[-1] = 8.40779e-45;
            pfVar12[-4] = 1.007162e-39;
            pvVar7 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
            if ((char)pvVar7 != '\0') {
              local_31c = 0;
              fStack_318 = local_280 + 6.0;
              local_314 = local_264;
              uStack_310 = 0x41000000;
              *(ulonglong *)(pfVar12 + 1) = CONCAT44(0x41000000,local_264);
              *(ulonglong *)(pfVar12 + -1) = (ulonglong)(uint)(local_280 + 6.0) << 0x20;
              pfVar12[-2] = (float)sel_valueWithRect_;
              pfVar12[-3] = (float)cls_NSValue;
              pfVar12[-4] = 1.00733e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-3],(SEL)pfVar12[-2]);
              pvVar7 = self->_widthRuleInitialRectsAndTransforms;
              pfVar12[-1] = (float)pvVar6;
              pfVar12[-2] = (float)pvVar8;
              pfVar12[-3] = (float)pvVar7;
              pfVar12[-4] = 1.007364e-39;
              _NSMapInsert();
              local_d4 = local_31c;
              fStack_d0 = fStack_318;
              local_cc = local_314;
              uStack_c8 = uStack_310;
              *(undefined8 *)(pfVar12 + 6) = local_294;
              *(undefined8 *)(pfVar12 + 4) = local_29c;
              *(undefined8 *)(pfVar12 + 2) = local_2a4;
              *(ulonglong *)pfVar12 = CONCAT44(uStack_310,local_314);
              *(ulonglong *)(pfVar12 + -2) = CONCAT44(fStack_318,local_31c);
              pfVar12[-3] = (float)&local_32c;
              pfVar12[-4] = 1.007571e-39;
              _CGRectApplyAffineTransform();
              puVar2 = cls_NSValue;
              pvVar7 = self->_widthLayoutGuidingRuleRects;
              pfVar12[-3] = (float)sel_context;
              pfVar12[-4] = (float)self;
              pfVar12[-5] = 1.007618e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-4],(SEL)pfVar12[-3]);
              pfVar12[-3] = (float)sel_renderingView;
              pfVar12[-4] = (float)pvVar8;
              pfVar12[-5] = 1.007643e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-4],(SEL)pfVar12[-3]);
              local_c4 = local_32c;
              uStack_c0 = local_328;
              local_bc = local_324;
              uStack_b8 = local_320;
              *(ulonglong *)(pfVar12 + 1) = CONCAT44(local_320,local_324);
              *(ulonglong *)(pfVar12 + -1) = CONCAT44(local_328,local_32c);
              pfVar12[-2] = (float)sel_viewBoundingRectForUserRect_;
              pfVar12[-3] = (float)pvVar8;
              pfVar12[-4] = (float)&local_b4;
              pfVar12[-5] = 1.007811e-39;
              _objc_msgSend_stret((void *)pfVar12[-4],(id)pfVar12[-3],(SEL)pfVar12[-2]);
              piVar11 = (int *)(pfVar12 + -5);
              *(undefined8 *)(pfVar12 + -1) = local_ac;
              *(undefined8 *)(pfVar12 + -3) = local_b4;
              pfVar12[-4] = (float)sel_valueWithRect_;
              pfVar12[-5] = (float)puVar2;
              pfVar12[-6] = 1.00788e-39;
              pvVar8 = _objc_msgSend((id)pfVar12[-5],(SEL)pfVar12[-4]);
              pfVar12[-3] = (float)pvVar8;
              pfVar12[-4] = (float)sel_addObject_;
              pfVar12[-5] = (float)pvVar7;
              pfVar12[-6] = 1.00791e-39;
              _objc_msgSend((id)pfVar12[-5],(SEL)pfVar12[-4]);
            }
            piVar11[1] = (int)sel_affectsRectSide_;
            *piVar11 = (int)pvVar5;
            piVar11[2] = 7;
            piVar11[-1] = 0xaf9c5;
            pvVar5 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
            pfVar12 = (float *)piVar11;
            if ((char)pvVar5 != '\0') {
              local_33c = local_284 + 6.0;
              uStack_338 = 0;
              local_334 = 0x41000000;
              fStack_330 = local_260;
              *(ulonglong *)(piVar11 + 4) = CONCAT44(local_260,0x41000000);
              *(ulonglong *)(piVar11 + 2) = (ulonglong)(uint)(local_284 + 6.0);
              piVar11[1] = (int)sel_valueWithRect_;
              *piVar11 = (int)cls_NSValue;
              piVar11[-1] = 0xafa3d;
              pvVar7 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
              pvVar5 = self->_heightRuleInitialRectsAndTransforms;
              piVar11[2] = (int)pvVar6;
              piVar11[1] = (int)pvVar7;
              *piVar11 = (int)pvVar5;
              piVar11[-1] = 0xafa59;
              _NSMapInsert();
              local_a4 = local_33c;
              uStack_a0 = uStack_338;
              local_9c = local_334;
              fStack_98 = fStack_330;
              *(undefined8 *)(piVar11 + 9) = local_294;
              *(undefined8 *)(piVar11 + 7) = local_29c;
              *(undefined8 *)(piVar11 + 5) = local_2a4;
              *(ulonglong *)(piVar11 + 3) = CONCAT44(fStack_330,local_334);
              *(ulonglong *)(piVar11 + 1) = CONCAT44(uStack_338,local_33c);
              *piVar11 = (int)&local_34c;
              piVar11[-1] = 0xafaed;
              _CGRectApplyAffineTransform();
              puVar2 = cls_NSValue;
              pvVar5 = self->_heightLayoutGuidingRuleRects;
              *piVar11 = (int)sel_context;
              piVar11[-1] = (int)self;
              piVar11[-2] = 0xafb0e;
              pvVar6 = _objc_msgSend((id)piVar11[-1],(SEL)*piVar11);
              *piVar11 = (int)sel_renderingView;
              piVar11[-1] = (int)pvVar6;
              piVar11[-2] = 0xafb20;
              pvVar6 = _objc_msgSend((id)piVar11[-1],(SEL)*piVar11);
              local_94 = local_34c;
              uStack_90 = local_348;
              local_8c = local_344;
              uStack_88 = local_340;
              *(ulonglong *)(piVar11 + 4) = CONCAT44(local_340,local_344);
              *(ulonglong *)(piVar11 + 2) = CONCAT44(local_348,local_34c);
              piVar11[1] = (int)sel_viewBoundingRectForUserRect_;
              *piVar11 = (int)pvVar6;
              piVar11[-1] = (int)&local_84;
              piVar11[-2] = 0xafb95;
              _objc_msgSend_stret((void *)piVar11[-1],(id)*piVar11,(SEL)piVar11[1]);
              *(undefined8 *)(piVar11 + 2) = local_7c;
              *(undefined8 *)piVar11 = local_84;
              piVar11[-1] = (int)sel_valueWithRect_;
              piVar11[-2] = (int)puVar2;
              piVar11[-3] = 0xafbc0;
              pvVar6 = _objc_msgSend((id)piVar11[-2],(SEL)piVar11[-1]);
              *piVar11 = (int)pvVar6;
              piVar11[-1] = (int)sel_addObject_;
              piVar11[-2] = (int)pvVar5;
              piVar11[-3] = 0xafbd6;
              _objc_msgSend((id)piVar11[-2],(SEL)piVar11[-1]);
              pfVar12 = (float *)(piVar11 + -2);
            }
          }
        }
      }
      pfVar12[1] = (float)sel_release;
      *pfVar12 = (float)pvVar4;
      pfVar12[-1] = 1.00873e-39;
      _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
      local_374 = (float)((int)local_374 + 1);
    } while ((int)local_374 < (int)pvVar3);
  }
  pvVar3 = self->_xSideLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.008799e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_xSideLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xafc43;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_74;
      piVar13[-1] = 0xafc5c;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_6c;
      *(undefined8 *)(piVar13 + 1) = local_74;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xafc8a;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_ySideLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.00899e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_ySideLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xafccb;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_64;
      piVar13[-1] = 0xafce4;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_5c;
      *(undefined8 *)(piVar13 + 1) = local_64;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xafd12;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_xMiddleLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.00918e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_xMiddleLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xafd53;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_54;
      piVar13[-1] = 0xafd6c;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_4c;
      *(undefined8 *)(piVar13 + 1) = local_54;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xafd9a;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_yMiddleLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.00937e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_yMiddleLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xafddb;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_44;
      piVar13[-1] = 0xafdf4;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_3c;
      *(undefined8 *)(piVar13 + 1) = local_44;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xafe22;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_widthLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.009561e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_widthLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xafe63;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_34;
      piVar13[-1] = 0xafe7c;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      pfVar12 = (float *)(piVar13 + -1);
      *(undefined8 *)(piVar13 + 3) = local_2c;
      *(undefined8 *)(piVar13 + 1) = local_34;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xafeaa;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  pvVar3 = self->_heightLayoutGuidingRuleRects;
  pfVar12[1] = (float)sel_count;
  *pfVar12 = (float)pvVar3;
  pfVar12[-1] = 1.009752e-39;
  pvVar3 = _objc_msgSend((id)*pfVar12,(SEL)pfVar12[1]);
  if (0 < (int)pvVar3) {
    iVar14 = 0;
    piVar13 = (int *)pfVar12;
    do {
      pvVar4 = self->_heightLayoutGuidingRuleRects;
      piVar13[2] = iVar14;
      piVar13[1] = (int)sel_objectAtIndex_;
      *piVar13 = (int)pvVar4;
      piVar13[-1] = 0xafeeb;
      pvVar4 = _objc_msgSend((id)*piVar13,(SEL)piVar13[1]);
      piVar13[2] = (int)sel_rectValue;
      piVar13[1] = (int)pvVar4;
      *piVar13 = (int)&local_24;
      piVar13[-1] = 0xaff04;
      _objc_msgSend_stret((void *)*piVar13,(id)piVar13[1],(SEL)piVar13[2]);
      *(undefined8 *)(piVar13 + 3) = local_1c;
      *(undefined8 *)(piVar13 + 1) = local_24;
      *piVar13 = (int)sel_setNeedsDisplayInRect_;
      piVar13[-1] = (int)self;
      piVar13[-2] = 0xaff32;
      _objc_msgSend((id)piVar13[-1],(SEL)*piVar13);
      iVar14 = iVar14 + 1;
      piVar13 = piVar13 + -1;
    } while (iVar14 < (int)pvVar3);
  }
  return;
}

*/
- (void)setAppliedLayoutRules:(id)aRules forSnappingRect:(NSRect)aRect
{
    _snappedRect = aRect;
    NSArray *guideArrays[6] = {
        _xSideLayoutGuidingRuleRects, _ySideLayoutGuidingRuleRects,
        _xMiddleLayoutGuidingRuleRects, _yMiddleLayoutGuidingRuleRects,
        _widthLayoutGuidingRuleRects, _heightLayoutGuidingRuleRects
    };
    for (int a = 0; a < 6; a++) {
        NSInteger guideCount = [guideArrays[a] count];
        for (NSInteger i = 0; i < guideCount; i++) {
            [self setNeedsDisplayInRect:[[guideArrays[a] objectAtIndex:i] rectValue]];
        }
    }
    for (int a = 0; a < 6; a++) {
        [guideArrays[a] removeAllObjects];
    }
    NSResetMapTable(_widthRuleInitialRectsAndTransforms);
    NSResetMapTable(_heightRuleInitialRectsAndTransforms);

    NSRect viewRect = NSZeroRect;
    NSInteger ruleCount = [aRules count];
    for (NSInteger ruleIndex = 0; ruleIndex < ruleCount; ruleIndex++) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        id rule = [aRules objectAtIndex:ruleIndex];
        if ([rule affectedRectSidesCount] != 0) {
            NSInteger ruleType = [rule ruleType];
            if (ruleType == 1) {
                NSEnumerator *holders = [[rule geometryHoldersUsed] objectEnumerator];
                HSMutableRegion *region = [[HSMutableRegion alloc] init];
                [region addRect:_snappedRect];
                id holder;
                while ((holder = [holders nextObject]) != nil) {
                    CGAffineTransform transform = [holder hyperLayoutInfluencingTransform];
                    NSRect bounds = [holder hyperLayoutInfluencingBoundingRect];
                    NSRect applied = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(bounds), transform));
                    [region addRect:applied];
                }
                viewRect = [[[self context] renderingView] viewBoundingRectForUserRect:[region boundingRect]];
                [region release];
                NSUInteger sideCount = [rule affectedRectSidesCount];
                for (NSUInteger sideIndex = 0; sideIndex < sideCount; sideIndex++) {
                    NSInteger side = [rule affectedRectSideAtIndex:sideIndex];
                    CGFloat value = [rule layoutRuleFloatValueForRectSide:side];
                    NSPoint point = [[[self context] renderingView] convertPointFromUserSpaceToViewSpace:NSMakePoint(value, value)];
                    CGFloat snappedX = floorf(point.x) + 0.5f;
                    CGFloat snappedY = floorf(point.y) + 0.5f;
                    if ([rule affectsRectSide:0] || [rule affectsRectSide:2]) {
                        [_xSideLayoutGuidingRuleRects addObject:[NSValue valueWithRect:NSMakeRect(snappedX, viewRect.origin.y, 1.0, viewRect.size.height)]];
                    }
                    if ([rule affectsRectSide:4]) {
                        [_xMiddleLayoutGuidingRuleRects addObject:[NSValue valueWithRect:NSMakeRect(snappedX, viewRect.origin.y - 15.0, 1.0, viewRect.size.height + 30.0)]];
                    }
                    if ([rule affectsRectSide:1] || [rule affectsRectSide:3]) {
                        [_ySideLayoutGuidingRuleRects addObject:[NSValue valueWithRect:NSMakeRect(viewRect.origin.x, snappedY, viewRect.size.width, 1.0)]];
                    }
                    if ([rule affectsRectSide:5]) {
                        [_yMiddleLayoutGuidingRuleRects addObject:[NSValue valueWithRect:NSMakeRect(viewRect.origin.x - 15.0, snappedY, viewRect.size.width + 30.0, 1.0)]];
                    }
                }
            }
            else if (ruleType == 3) {
                NSEnumerator *holders = [[rule geometryHoldersUsed] objectEnumerator];
                id holder;
                while ((holder = [holders nextObject]) != nil) {
                    viewRect = [[[self context] renderingView] viewBoundingRectForUserRect:[holder hyperLayoutInfluencingBoundingRect]];
                    CGAffineTransform cgTransform = [holder hyperLayoutInfluencingTransform];
                    NSAffineTransform *transform = [NSAffineTransform transformWithHyperCGAffineTransform:cgTransform];
                    [transform appendTransform:[[[self context] renderingView] userSpaceToViewSpaceTransform]];
                    if ([rule affectsRectSide:6]) {
                        NSRect initial = NSMakeRect(0, viewRect.size.height + 6.0, viewRect.size.width, 8.0);
                        NSMapInsert(_widthRuleInitialRectsAndTransforms, [NSValue valueWithRect:initial], transform);
                        NSRect applied = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(initial), cgTransform));
                        NSRect guide = [[[self context] renderingView] viewBoundingRectForUserRect:applied];
                        [_widthLayoutGuidingRuleRects addObject:[NSValue valueWithRect:guide]];
                    }
                    if ([rule affectsRectSide:7]) {
                        NSRect initial = NSMakeRect(viewRect.size.width + 6.0, 0, 8.0, viewRect.size.height);
                        NSMapInsert(_heightRuleInitialRectsAndTransforms, [NSValue valueWithRect:initial], transform);
                        NSRect applied = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(initial), cgTransform));
                        NSRect guide = [[[self context] renderingView] viewBoundingRectForUserRect:applied];
                        [_widthLayoutGuidingRuleRects addObject:[NSValue valueWithRect:guide]];
                    }
                }
                id ownHolder = [rule ownGeometryHolder];
                NSRect ownRect = [[[self context] renderingView] viewBoundingRectForUserRect:[ownHolder hyperLayoutInfluencingBoundingRect]];
                CGAffineTransform ownCGTransform = [ownHolder hyperLayoutInfluencingTransform];
                NSAffineTransform *ownTransform = [NSAffineTransform transformWithHyperCGAffineTransform:ownCGTransform];
                [ownTransform appendTransform:[[[self context] renderingView] userSpaceToViewSpaceTransform]];
                if ([rule affectsRectSide:6]) {
                    NSRect initial = NSMakeRect(0, ownRect.size.height + 6.0, viewRect.size.width, 8.0);
                    NSMapInsert(_widthRuleInitialRectsAndTransforms, [NSValue valueWithRect:initial], ownTransform);
                    NSRect applied = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(initial), ownCGTransform));
                    NSRect guide = [[[self context] renderingView] viewBoundingRectForUserRect:applied];
                    [_widthLayoutGuidingRuleRects addObject:[NSValue valueWithRect:guide]];
                }
                if ([rule affectsRectSide:7]) {
                    NSRect initial = NSMakeRect(ownRect.size.width + 6.0, 0, 8.0, viewRect.size.height);
                    NSMapInsert(_heightRuleInitialRectsAndTransforms, [NSValue valueWithRect:initial], ownTransform);
                    NSRect applied = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(initial), ownCGTransform));
                    NSRect guide = [[[self context] renderingView] viewBoundingRectForUserRect:applied];
                    [_heightLayoutGuidingRuleRects addObject:[NSValue valueWithRect:guide]];
                }
            }
        }
        [pool release];
    }
    for (int a = 0; a < 6; a++) {
        NSInteger guideCount = [guideArrays[a] count];
        for (NSInteger i = 0; i < guideCount; i++) {
            [self setNeedsDisplayInRect:[[guideArrays[a] objectAtIndex:i] rectValue]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aff42 @ 000aff42, 3810 bytes * /

void FUN_000aff42(HSLayoutRulesCanvasLayer *self,SEL _cmd,NSRect renderRect)

{
  id pvVar1;
  float fVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  int *piVar7;
  int *piVar8;
  int iVar9;
  longdouble lVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  int local_e4 [2];
  float local_d4 [22];
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  float local_4c;
  float local_48;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  HSLayoutRulesCanvasLayer *local_1c;
  undefined *local_18;
  
  piVar8 = (int *)&stack0xffffff24;
  local_1c = self;
  local_18 = PTR_s_HSGenericItemsCanvasSublayer_0034f4f0;
  _objc_msgSendSuper(&local_1c,sel_renderRect_);
  pvVar3 = _objc_msgSend(self,sel_guidelinesColor);
  _objc_msgSend(pvVar3,sel_set);
  local_2c = *(float *)PTR_00336078;
  local_28 = *(float *)(PTR_00336078 + 4);
  local_24 = *(float *)(PTR_00336078 + 8);
  local_20 = *(float *)(PTR_00336078 + 0xc);
  pvVar3 = _objc_msgSend(cls_NSBezierPath,sel_bezierPath);
  _objc_msgSend(pvVar3,sel_setLineWidth_);
  pvVar4 = _objc_msgSend(self->_xSideLayoutGuidingRuleRects,sel_count);
  if (0 < (int)pvVar4) {
    iVar9 = 0;
    piVar7 = (int *)&stack0xffffff24;
    do {
      pvVar5 = self->_xSideLayoutGuidingRuleRects;
      piVar7[2] = iVar9;
      piVar7[1] = (int)sel_objectAtIndex_;
      *piVar7 = (int)pvVar5;
      piVar7[-1] = 0xb0054;
      pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
      piVar7[2] = (int)sel_rectValue;
      piVar7[1] = (int)pvVar5;
      *piVar7 = (int)&local_2c;
      piVar7[-1] = 0xb006d;
      _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
      piVar8 = piVar7 + -1;
      piVar7[2] = (int)local_28;
      piVar7[1] = (int)local_2c;
      *piVar7 = (int)sel_moveToPoint_;
      piVar7[-1] = (int)pvVar3;
      piVar7[-2] = 0xb0098;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      piVar7[2] = (int)(local_28 + local_20);
      piVar7[1] = (int)local_2c;
      *piVar7 = (int)sel_lineToPoint_;
      piVar7[-1] = (int)pvVar3;
      piVar7[-2] = 0xb00c5;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      iVar9 = iVar9 + 1;
      piVar7 = piVar7 + -1;
    } while (iVar9 < (int)pvVar4);
  }
  pvVar4 = self->_ySideLayoutGuidingRuleRects;
  piVar8[1] = (int)sel_count;
  *piVar8 = (int)pvVar4;
  piVar8[-1] = 0xb00ea;
  pvVar4 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (0 < (int)pvVar4) {
    iVar9 = 0;
    piVar7 = piVar8;
    do {
      pvVar5 = self->_ySideLayoutGuidingRuleRects;
      piVar7[2] = iVar9;
      piVar7[1] = (int)sel_objectAtIndex_;
      *piVar7 = (int)pvVar5;
      piVar7[-1] = 0xb0116;
      pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
      piVar7[2] = (int)sel_rectValue;
      piVar7[1] = (int)pvVar5;
      *piVar7 = (int)&local_3c;
      piVar7[-1] = 0xb012f;
      _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
      piVar8 = piVar7 + -1;
      local_2c = local_3c;
      local_28 = local_38;
      local_24 = local_34;
      local_20 = local_30;
      piVar7[2] = (int)local_38;
      piVar7[1] = (int)local_3c;
      *piVar7 = (int)sel_moveToPoint_;
      piVar7[-1] = (int)pvVar3;
      piVar7[-2] = 0xb0178;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      piVar7[2] = (int)local_28;
      piVar7[1] = (int)(local_2c + local_24);
      *piVar7 = (int)sel_lineToPoint_;
      piVar7[-1] = (int)pvVar3;
      piVar7[-2] = 0xb01a5;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      iVar9 = iVar9 + 1;
      piVar7 = piVar7 + -1;
    } while (iVar9 < (int)pvVar4);
  }
  piVar8[1] = (int)sel_closePath;
  *piVar8 = (int)pvVar3;
  piVar8[-1] = 0xb01c4;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_stroke;
  *piVar8 = (int)pvVar3;
  piVar8[-1] = 0xb01d6;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_bezierPath;
  *piVar8 = (int)cls_NSBezierPath;
  piVar8[-1] = 0xb01ee;
  pvVar4 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_setLineWidth_;
  *piVar8 = (int)pvVar4;
  piVar8[2] = 0x3f800000;
  piVar8[-1] = 0xb020a;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  pvVar3 = self->_xMiddleLayoutGuidingRuleRects;
  piVar8[1] = (int)sel_count;
  *piVar8 = (int)pvVar3;
  piVar8[-1] = 0xb0222;
  pvVar3 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (0 < (int)pvVar3) {
    iVar9 = 0;
    piVar7 = piVar8;
    do {
      pvVar5 = self->_xMiddleLayoutGuidingRuleRects;
      piVar7[2] = iVar9;
      piVar7[1] = (int)sel_objectAtIndex_;
      *piVar7 = (int)pvVar5;
      piVar7[-1] = 0xb024e;
      pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
      piVar7[2] = (int)sel_rectValue;
      piVar7[1] = (int)pvVar5;
      *piVar7 = (int)&local_4c;
      piVar7[-1] = 0xb0267;
      _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
      piVar8 = piVar7 + -1;
      local_2c = local_4c;
      local_28 = local_48;
      local_24 = local_44;
      local_20 = local_40;
      piVar7[2] = (int)local_48;
      piVar7[1] = (int)local_4c;
      *piVar7 = (int)sel_moveToPoint_;
      piVar7[-1] = (int)pvVar4;
      piVar7[-2] = 0xb02b0;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      piVar7[2] = (int)(local_28 + local_20);
      piVar7[1] = (int)local_2c;
      *piVar7 = (int)sel_lineToPoint_;
      piVar7[-1] = (int)pvVar4;
      piVar7[-2] = 0xb02dd;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      iVar9 = iVar9 + 1;
      piVar7 = piVar7 + -1;
    } while (iVar9 < (int)pvVar3);
  }
  pvVar3 = self->_yMiddleLayoutGuidingRuleRects;
  piVar8[1] = (int)sel_count;
  *piVar8 = (int)pvVar3;
  piVar8[-1] = 0xb0302;
  pvVar3 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (0 < (int)pvVar3) {
    iVar9 = 0;
    piVar7 = piVar8;
    do {
      pvVar5 = self->_yMiddleLayoutGuidingRuleRects;
      piVar7[2] = iVar9;
      piVar7[1] = (int)sel_objectAtIndex_;
      *piVar7 = (int)pvVar5;
      piVar7[-1] = 0xb032e;
      pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
      piVar7[2] = (int)sel_rectValue;
      piVar7[1] = (int)pvVar5;
      *piVar7 = (int)&local_5c;
      piVar7[-1] = 0xb0347;
      _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
      piVar8 = piVar7 + -1;
      local_2c = local_5c;
      local_28 = local_58;
      local_24 = local_54;
      local_20 = local_50;
      piVar7[2] = (int)local_58;
      piVar7[1] = (int)local_5c;
      *piVar7 = (int)sel_moveToPoint_;
      piVar7[-1] = (int)pvVar4;
      piVar7[-2] = 0xb0390;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      piVar7[2] = (int)local_28;
      piVar7[1] = (int)(local_2c + local_24);
      *piVar7 = (int)sel_lineToPoint_;
      piVar7[-1] = (int)pvVar4;
      piVar7[-2] = 0xb03bd;
      _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      iVar9 = iVar9 + 1;
      piVar7 = piVar7 + -1;
    } while (iVar9 < (int)pvVar3);
  }
  piVar8[1] = (int)sel_closePath;
  *piVar8 = (int)pvVar4;
  piVar8[-1] = 0xb03dc;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_stroke;
  *piVar8 = (int)pvVar4;
  piVar8[-1] = 0xb03ee;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  *piVar8 = (int)self->_widthRuleInitialRectsAndTransforms;
  piVar8[-1] = 0xb03fc;
  uVar6 = _NSAllMapTableKeys();
  piVar8[1] = (int)sel_objectEnumerator;
  *piVar8 = uVar6;
  piVar8[-1] = 0xb040e;
  pvVar4 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_nextObject;
  *piVar8 = (int)pvVar4;
  piVar8[-1] = 0xb0426;
  pvVar3 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar7 = piVar8;
  while (pvVar3 != (id)0x0) {
    piVar7[1] = (int)sel_bezierPath;
    *piVar7 = (int)cls_NSBezierPath;
    piVar7[-1] = 0xb0448;
    pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_setLineWidth_;
    *piVar7 = (int)pvVar5;
    piVar7[2] = 0x3f800000;
    piVar7[-1] = 0xb0464;
    _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[2] = (int)sel_rectValue;
    piVar7[1] = (int)pvVar3;
    *piVar7 = (int)&local_6c;
    piVar7[-1] = 0xb047d;
    _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
    fVar13 = local_60;
    fVar12 = local_64;
    fVar11 = local_68;
    fVar2 = local_6c;
    local_2c = local_6c;
    local_28 = local_68;
    local_24 = local_64;
    local_20 = local_60;
    piVar7[2] = (int)local_68;
    piVar7[1] = (int)local_6c;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    fVar14 = local_68 + local_60;
    piVar7[-2] = 0xb04f9;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar2;
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0527;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar11;
    piVar7[1] = (int)(local_24 + fVar2);
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb055a;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)(fVar2 + local_24);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb058d;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    fVar2 = local_2c;
    fVar11 = local_24 + local_2c;
    piVar7[-1] = (int)(local_20 * 0.5 + local_28);
    piVar7[-2] = 0xb05c7;
    lVar10 = (longdouble)_floorf();
    fVar14 = (float)lVar10 + 0.5;
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar2;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0605;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar11;
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0633;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar2;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0661;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_20 * 0.25 + fVar14);
    piVar7[-2] = 0xb0680;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)((float)lVar10 + 0.5);
    if (fVar13 <= fVar12) {
      fVar12 = fVar13;
    }
    piVar7[1] = (int)(fVar2 + fVar12);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb06de;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar2;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb070c;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_20 * -0.25 + fVar14);
    piVar7[-2] = 0xb072b;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)((float)lVar10 + 0.5);
    piVar7[1] = (int)(fVar2 + fVar12);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0767;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar11;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0795;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_20 * 0.25 + fVar14);
    piVar7[-2] = 0xb07b4;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)((float)lVar10 + 0.5);
    piVar7[1] = (int)(fVar11 - fVar12);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0800;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar14;
    piVar7[1] = (int)fVar11;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb082e;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_20 * -0.25 + fVar14);
    piVar7[-2] = 0xb084d;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)((float)lVar10 + 0.5);
    piVar7[1] = (int)(fVar11 - fVar12);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0889;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    pvVar1 = self->_widthRuleInitialRectsAndTransforms;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = (int)pvVar1;
    piVar7[-2] = 0xb089b;
    iVar9 = _NSMapGet();
    piVar7[1] = iVar9;
    *piVar7 = (int)sel_transformUsingAffineTransform_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb08b1;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_closePath;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb08c3;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_stroke;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb08d5;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_nextObject;
    piVar7[-1] = (int)pvVar4;
    piVar7[-2] = 0xb08ed;
    pvVar3 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7 = piVar7 + -1;
  }
  *piVar7 = (int)self->_heightRuleInitialRectsAndTransforms;
  piVar7[-1] = 0xb0905;
  iVar9 = _NSAllMapTableKeys();
  piVar7[1] = (int)sel_objectEnumerator;
  *piVar7 = iVar9;
  piVar7[-1] = 0xb0917;
  pvVar4 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  piVar7[1] = (int)sel_nextObject;
  *piVar7 = (int)pvVar4;
  piVar7[-1] = 0xb092f;
  pvVar3 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  while (pvVar3 != (id)0x0) {
    piVar7[1] = (int)sel_bezierPath;
    *piVar7 = (int)cls_NSBezierPath;
    piVar7[-1] = 0xb0951;
    pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_setLineWidth_;
    *piVar7 = (int)pvVar5;
    piVar7[2] = 0x3f800000;
    piVar7[-1] = 0xb096d;
    _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[2] = (int)sel_rectValue;
    piVar7[1] = (int)pvVar3;
    *piVar7 = (int)&local_7c;
    piVar7[-1] = 0xb0986;
    _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
    fVar13 = local_70;
    fVar12 = local_74;
    fVar11 = local_78;
    fVar2 = local_7c;
    local_2c = local_7c;
    local_28 = local_78;
    local_24 = local_74;
    local_20 = local_70;
    piVar7[2] = (int)local_78;
    piVar7[1] = (int)local_7c;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb09ef;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar11;
    fVar14 = fVar2 + fVar12;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0a2d;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)(local_20 + fVar11);
    piVar7[1] = (int)fVar2;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0a60;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)(fVar11 + local_20);
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0a93;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    fVar2 = local_28;
    fVar11 = local_20 + local_28;
    piVar7[-1] = (int)(local_24 * 0.5 + local_2c);
    piVar7[-2] = 0xb0acd;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)fVar2;
    fVar14 = (float)lVar10 + 0.5;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0b11;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar11;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0b3f;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar2;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0b6d;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_24 * 0.25 + fVar14);
    if (fVar12 <= fVar13) {
      fVar13 = fVar12;
    }
    piVar7[-2] = 0xb0bbc;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)(fVar2 + fVar13);
    piVar7[1] = (int)((float)lVar10 + 0.5);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0bf8;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar2;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0c26;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_24 * -0.25 + fVar14);
    piVar7[-2] = 0xb0c45;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)(fVar2 + fVar13);
    piVar7[1] = (int)((float)lVar10 + 0.5);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0c81;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar11;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0caf;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_24 * 0.25 + fVar14);
    piVar7[-2] = 0xb0ce6;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)(fVar11 - fVar13);
    piVar7[1] = (int)((float)lVar10 + 0.5);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0d22;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)fVar11;
    piVar7[1] = (int)fVar14;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0d50;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[-1] = (int)(local_24 * -0.25 + fVar14);
    piVar7[-2] = 0xb0d6f;
    lVar10 = (longdouble)_floorf();
    piVar7[2] = (int)(fVar11 - fVar13);
    piVar7[1] = (int)((float)lVar10 + 0.5);
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0dab;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    pvVar1 = self->_heightRuleInitialRectsAndTransforms;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = (int)pvVar1;
    piVar7[-2] = 0xb0dbd;
    iVar9 = _NSMapGet();
    piVar7[1] = iVar9;
    *piVar7 = (int)sel_transformUsingAffineTransform_;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0dd3;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_closePath;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0de5;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_stroke;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0xb0df7;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_nextObject;
    piVar7[-1] = (int)pvVar4;
    piVar7[-2] = 0xb0e0f;
    pvVar3 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7 = piVar7 + -1;
  }
  return;
}

*/
- (void)renderRect:(NSRect)aRect
{
    [super renderRect:aRect];
    [(NSColor *)[self guidelinesColor] set];
    NSRect rect = NSZeroRect;
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:1.0f];
    NSUInteger count = [_xSideLayoutGuidingRuleRects count];
    for (NSUInteger i = 0; i < count; i++) {
        rect = [[_xSideLayoutGuidingRuleRects objectAtIndex:i] rectValue];
        [path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
        [path lineToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
    }
    count = [_ySideLayoutGuidingRuleRects count];
    for (NSUInteger i = 0; i < count; i++) {
        rect = [[_ySideLayoutGuidingRuleRects objectAtIndex:i] rectValue];
        [path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
        [path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
    }
    [path closePath];
    [path stroke];
    path = [NSBezierPath bezierPath];
    [path setLineWidth:1.0f];
    count = [_xMiddleLayoutGuidingRuleRects count];
    for (NSUInteger i = 0; i < count; i++) {
        rect = [[_xMiddleLayoutGuidingRuleRects objectAtIndex:i] rectValue];
        [path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
        [path lineToPoint:NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height)];
    }
    count = [_yMiddleLayoutGuidingRuleRects count];
    for (NSUInteger i = 0; i < count; i++) {
        rect = [[_yMiddleLayoutGuidingRuleRects objectAtIndex:i] rectValue];
        [path moveToPoint:NSMakePoint(rect.origin.x, rect.origin.y)];
        [path lineToPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
    }
    [path closePath];
    [path stroke];
    NSEnumerator *keys = [NSAllMapTableKeys(_widthRuleInitialRectsAndTransforms) objectEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        path = [NSBezierPath bezierPath];
        [path setLineWidth:1.0f];
        rect = [key rectValue];
        float x = rect.origin.x;
        float y = rect.origin.y;
        float w = rect.size.width;
        float h = rect.size.height;
        [path moveToPoint:NSMakePoint(x, y)];
        [path lineToPoint:NSMakePoint(x, y + h)];
        [path moveToPoint:NSMakePoint(w + x, y)];
        [path lineToPoint:NSMakePoint(x + w, y + h)];
        float right = x + w;
        float middle = floorf(h * 0.5f + y) + 0.5f;
        float arrow = MIN(w, h);
        [path moveToPoint:NSMakePoint(x, middle)];
        [path lineToPoint:NSMakePoint(right, middle)];
        [path moveToPoint:NSMakePoint(x, middle)];
        [path lineToPoint:NSMakePoint(x + arrow, floorf(h * 0.25f + middle) + 0.5f)];
        [path moveToPoint:NSMakePoint(x, middle)];
        [path lineToPoint:NSMakePoint(x + arrow, floorf(h * -0.25f + middle) + 0.5f)];
        [path moveToPoint:NSMakePoint(right, middle)];
        [path lineToPoint:NSMakePoint(right - arrow, floorf(h * 0.25f + middle) + 0.5f)];
        [path moveToPoint:NSMakePoint(right, middle)];
        [path lineToPoint:NSMakePoint(right - arrow, floorf(h * -0.25f + middle) + 0.5f)];
        [path transformUsingAffineTransform:NSMapGet(_widthRuleInitialRectsAndTransforms, key)];
        [path closePath];
        [path stroke];
    }
    keys = [NSAllMapTableKeys(_heightRuleInitialRectsAndTransforms) objectEnumerator];
    while ((key = [keys nextObject]) != nil) {
        path = [NSBezierPath bezierPath];
        [path setLineWidth:1.0f];
        rect = [key rectValue];
        float x = rect.origin.x;
        float y = rect.origin.y;
        float w = rect.size.width;
        float h = rect.size.height;
        [path moveToPoint:NSMakePoint(x, y)];
        [path lineToPoint:NSMakePoint(x + w, y)];
        [path moveToPoint:NSMakePoint(x, h + y)];
        [path lineToPoint:NSMakePoint(x + w, y + h)];
        float top = y + h;
        float middle = floorf(w * 0.5f + x) + 0.5f;
        float arrow = MIN(h, w);
        [path moveToPoint:NSMakePoint(middle, y)];
        [path lineToPoint:NSMakePoint(middle, top)];
        [path moveToPoint:NSMakePoint(middle, y)];
        [path lineToPoint:NSMakePoint(floorf(w * 0.25f + middle) + 0.5f, y + arrow)];
        [path moveToPoint:NSMakePoint(middle, y)];
        [path lineToPoint:NSMakePoint(floorf(w * -0.25f + middle) + 0.5f, y + arrow)];
        [path moveToPoint:NSMakePoint(middle, top)];
        [path lineToPoint:NSMakePoint(floorf(w * 0.25f + middle) + 0.5f, top - arrow)];
        [path moveToPoint:NSMakePoint(middle, top)];
        [path lineToPoint:NSMakePoint(floorf(w * -0.25f + middle) + 0.5f, top - arrow)];
        [path transformUsingAffineTransform:NSMapGet(_heightRuleInitialRectsAndTransforms, key)];
        [path closePath];
        [path stroke];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000adfef @ 000adfef, 98 bytes * /

void FUN_000adfef(HSLayoutRulesCanvasLayer *self,SEL _cmd,NSRect setNeedsDisplayInRect)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_context);
  pvVar1 = _objc_msgSend(pvVar1,sel_renderingView);
  _objc_msgSend(pvVar1,sel_setNeedsDisplayOpenGLSurfaceInRect_,setNeedsDisplayInRect.origin,
                setNeedsDisplayInRect.size);
  return;
}

*/
- (void)setNeedsDisplayInRect:(NSRect)aRect
{
    [[[self context] renderingView] setNeedsDisplayOpenGLSurfaceInRect:aRect];
}

- (void)dealloc
{
    [_xSideLayoutGuidingRuleRects release];
    [_xMiddleLayoutGuidingRuleRects release];
    [_ySideLayoutGuidingRuleRects release];
    [_yMiddleLayoutGuidingRuleRects release];
    [_widthLayoutGuidingRuleRects release];
    [_heightLayoutGuidingRuleRects release];
    NSFreeMapTable(_widthRuleInitialRectsAndTransforms);
    NSFreeMapTable(_heightRuleInitialRectsAndTransforms);
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ae0b6 @ 000ae0b6, 592 bytes * /

id FUN_000ae0b6(HSLayoutRulesCanvasLayer *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  id pvVar6;
  id pvVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  HSLayoutRulesCanvasLayer *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSGenericItemsCanvasSublayer_0034f4f0;
  pvVar6 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar6 != (id)0x0) {
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithCapacity_,0);
    *(id *)((int)pvVar6 + 0x1c) = pvVar7;
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithCapacity_,0);
    *(id *)((int)pvVar6 + 0x20) = pvVar7;
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithCapacity_,0);
    *(id *)((int)pvVar6 + 0x24) = pvVar7;
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithCapacity_,0);
    *(id *)((int)pvVar6 + 0x28) = pvVar7;
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithCapacity_,0);
    *(id *)((int)pvVar6 + 0x2c) = pvVar7;
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithCapacity_,0);
    *(id *)((int)pvVar6 + 0x30) = pvVar7;
    uVar9 = *(undefined4 *)PTR_00336444;
    uVar5 = *(undefined8 *)(PTR_00336444 + 8);
    uVar4 = *(undefined8 *)(PTR_00336444 + 0x10);
    uVar1 = *(undefined4 *)(PTR_0033639c + 8);
    uVar2 = *(undefined4 *)PTR_0033639c;
    uVar3 = *(undefined4 *)(PTR_0033639c + 4);
    uVar8 = _NSCreateMapTable(CONCAT44(FUN_000adfde,uVar9),*(undefined8 *)(PTR_00336444 + 8),
                              *(undefined8 *)(PTR_00336444 + 0x10),uVar2,uVar3,uVar1,0);
    *(undefined4 *)((int)pvVar6 + 0x44) = uVar8;
    uVar9 = _NSCreateMapTable(CONCAT44(FUN_000adfde,uVar9),uVar5,uVar4,uVar2,uVar3,uVar1,0);
    *(undefined4 *)((int)pvVar6 + 0x48) = uVar9;
  }
  return pvVar6;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _xSideLayoutGuidingRuleRects = [[NSMutableArray alloc] initWithCapacity:0];
        _ySideLayoutGuidingRuleRects = [[NSMutableArray alloc] initWithCapacity:0];
        _xMiddleLayoutGuidingRuleRects = [[NSMutableArray alloc] initWithCapacity:0];
        _yMiddleLayoutGuidingRuleRects = [[NSMutableArray alloc] initWithCapacity:0];
        _widthLayoutGuidingRuleRects = [[NSMutableArray alloc] initWithCapacity:0];
        _heightLayoutGuidingRuleRects = [[NSMutableArray alloc] initWithCapacity:0];
        NSMapTableKeyCallBacks keyCallBacks = NSObjectMapKeyCallBacks;
        keyCallBacks.isEqual = HSLayoutRulesIsEqualByIdentity;
        _widthRuleInitialRectsAndTransforms = NSCreateMapTable(keyCallBacks, NSObjectMapValueCallBacks, 0);
        _heightRuleInitialRectsAndTransforms = NSCreateMapTable(keyCallBacks, NSObjectMapValueCallBacks, 0);
    }
    return self;
}

@end

