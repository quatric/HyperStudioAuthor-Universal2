#import "HSAuxiliaryIconsCanvasItem.h"

static BOOL HSTraitValuesEqual(float a, float b)
{
    float sa = (a != 0.0f) ? fabsf(a) : 1.0f;
    float sb = (b != 0.0f) ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(sa, sb) * 0.0005f;
}

// FUN_000927b9 / FUN_0009286c / FUN_000946ba (register-argument helpers) for compositeRectsForIcons:inView:
typedef struct {
    NSPoint p[4];
} HSAuxiliaryCorners;

#define HSAuxiliaryNoCorner 0x7fffffff

static NSPoint HSAuxiliaryCornerPoint(HSAuxiliaryCorners corners, NSUInteger index)
{
    switch (index) {
        case 0:
        case 4:
            return corners.p[0];
        case 1:
            return corners.p[1];
        case 2:
            return corners.p[2];
        case 3:
        case (NSUInteger)-1:
            return corners.p[3];
    }
    return NSZeroPoint;
}

static NSUInteger HSAuxiliaryWrapCorner(NSUInteger corner)
{
    if (corner > 3) {
        if (corner == 4) {
            return 0;
        }
        if (corner == (NSUInteger)-1) {
            return 3;
        }
    }
    return corner;
}

static BOOL HSAuxiliaryEdgeBetweenCorners(NSUInteger *edge, NSUInteger a, NSUInteger b)
{
    if (edge == NULL) {
        return NO;
    }
    a = HSAuxiliaryWrapCorner(a);
    b = HSAuxiliaryWrapCorner(b);
    if (b < a) {
        return HSAuxiliaryEdgeBetweenCorners(edge, b, a);
    }
    if (a >= b) {
        return NO;
    }
    if (a + 1 == b) {
        if (a == 0) {
            *edge = 0;
            return YES;
        }
        if (a == 2) {
            *edge = 2;
            return YES;
        }
        if (a == 1) {
            *edge = 3;
            return YES;
        }
        return NO;
    }
    if (a == 0 && b == 3) {
        *edge = 1;
        return YES;
    }
    return NO;
}

static void HSAuxiliaryTransformCorners(NSAffineTransform *transform, HSAuxiliaryCorners *corners)
{
    [transform hyperTransformPoints:corners->p count:4];
}

static HSAuxiliaryCorners HSAuxiliaryCornersForRect(NSRect rect)
{
    HSAuxiliaryCorners corners;
    corners.p[0] = NSMakePoint(rect.origin.x, rect.origin.y);
    corners.p[1] = NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height);
    corners.p[2] = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    corners.p[3] = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y);
    return corners;
}

static float HSAuxiliaryScale(float v)
{
    return (v != 0.0f) ? fabsf(v) : 1.0f;
}

@implementation HSAuxiliaryIconsCanvasItem

/* i386 ivar offsets: _traits=0x8, _traitRects=0xc, _traitsRegion=0x10, _transformUsedForRectCalculations=0x14, _boundsUsedForRectCalculations=0x2c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092a4f @ 00092a4f, 59 bytes * /

id FUN_00092a4f(HSAuxiliaryIconsCanvasItem *self,SEL _cmd)

{
  SEL op;
  id pvVar1;
  undefined *self_00;
  
  op = sel_array;
  self_00 = cls_NSArray;
  if (self->_traits != (undefined *)0x0) {
    op = sel_iconImages;
    self_00 = self->_traits;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)traitIcons
{
    return (_traits != nil) ? [_traits iconImages] : [NSArray array];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092a8a @ 00092a8a, 272 bytes * /

id FUN_00092a8a(HSAuxiliaryIconsCanvasItem *self,SEL _cmd,id traitRectsInView)

{
  id pvVar1;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar1 = self->_traitRects;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_traitIcons);
    pvVar1 = _objc_msgSend(self,sel_compositeRectsForIcons_inView_,pvVar1,traitRectsInView);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_traitRects = pvVar1;
    _objc_msgSend_stret(&local_24,self,sel_boundsForTraitRectsInView_,traitRectsInView);
    (self->_boundsUsedForRectCalculations).origin.x = local_24;
    (self->_boundsUsedForRectCalculations).origin.y = local_20;
    (self->_boundsUsedForRectCalculations).size.width = local_1c;
    (self->_boundsUsedForRectCalculations).size.height = local_18;
    _objc_msgSend_stret(&local_3c,self,sel_transformForTraitRectsInView_,traitRectsInView);
    (self->_transformUsedForRectCalculations).a = local_3c;
    (self->_transformUsedForRectCalculations).b = local_38;
    (self->_transformUsedForRectCalculations).c = local_34;
    (self->_transformUsedForRectCalculations).d = local_30;
    (self->_transformUsedForRectCalculations).tx = local_2c;
    (self->_transformUsedForRectCalculations).ty = local_28;
    pvVar1 = self->_traitRects;
  }
  return pvVar1;
}

*/
- (id)traitRectsInView:(id)aView
{
    if (_traitRects == nil) {
        _traitRects = [[self compositeRectsForIcons:[self traitIcons] inView:aView] retain];
        _boundsUsedForRectCalculations = [self boundsForTraitRectsInView:aView];
        _transformUsedForRectCalculations = [self transformForTraitRectsInView:aView];
    }
    return _traitRects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092b9a @ 00092b9a, 4061 bytes * /

id FUN_00092b9a(HSAuxiliaryIconsCanvasItem *self,SEL _cmd,id compositeRectsForIcons,id inView)

{
  float fVar1;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  bool bVar5;
  char cVar6;
  id pvVar7;
  id pvVar8;
  id self_00;
  id self_01;
  id self_02;
  uint uVar9;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  uint uVar10;
  uint uVar11;
  longdouble lVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  undefined8 uVar20;
  undefined8 uVar21;
  undefined8 uVar22;
  undefined *puVar23;
  undefined *local_160;
  id local_15c;
  id local_150;
  float local_14c;
  bool local_145;
  uint local_140;
  uint local_13c;
  undefined *local_138;
  float local_134;
  uint local_130;
  float local_128;
  float local_124;
  float local_120;
  float local_dc;
  undefined *puStack_d8;
  float local_ac;
  float local_a8;
  uint local_a4;
  uint local_a0;
  uint local_9c;
  bool local_95;
  float local_94;
  undefined *puStack_90;
  id local_8c;
  float fStack_88;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  undefined1 local_74 [24];
  undefined8 local_5c;
  undefined8 local_54;
  undefined8 local_4c;
  undefined8 local_44;
  float local_3c [10];
  undefined4 local_14;
  
  _objc_msgSend_stret(local_74,self,sel_transformForTraitRectsInView_,inView);
  fVar14 = (float)local_74._8_8_;
  pvVar7 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperCGAffineTransform_,
                         (int)local_74._0_8_,SUB84(local_74._0_8_,4),fVar14,SUB84(local_74._8_8_,4),
                         (int)local_74._16_8_,SUB84(local_74._16_8_,4));
  pvVar8 = _objc_msgSend(pvVar7,sel_copy);
  pvVar8 = _objc_msgSend(pvVar8,sel_autorelease);
  _objc_msgSend(pvVar8,sel_invert);
  puVar23 = sel_boundsForTraitRectsInView_;
  _objc_msgSend_stret(&local_84,self,sel_boundsForTraitRectsInView_,inView);
  puVar2 = cls_NSMutableArray;
  pvVar8 = _objc_msgSend(compositeRectsForIcons,sel_count);
  self_00 = _objc_msgSend(puVar2,sel_arrayWithCapacity_,pvVar8);
  puVar3 = PTR_00336078;
  fVar1 = *(float *)PTR_00336078;
  puVar2 = *(undefined **)(PTR_00336078 + 4);
  self_01 = _objc_msgSend(compositeRectsForIcons,sel_objectEnumerator);
  local_8c = *(id *)(puVar3 + 8);
  fStack_88 = *(float *)(puVar3 + 0xc);
  local_94 = fVar1;
  puStack_90 = puVar2;
  self_02 = _objc_msgSend(self_01,sel_nextObject);
  if (self_02 != (id)0x0) {
    local_8c = _objc_msgSend(self_02,sel_size,pvVar8);
    local_a8 = local_80 + local_78;
    local_ac = local_84 + local_7c;
    fStack_88 = extraout_EDX;
    _objc_msgSend(pvVar7,sel_hyperTransformPoints_count_,&local_ac,1);
    fVar14 = local_ac - (float)local_8c;
    fVar17 = local_a8 - fStack_88;
    fVar16 = fStack_88 + fVar17;
    fVar15 = fVar14 + (float)local_8c;
    local_94 = fVar14;
    puStack_90 = (undefined *)fVar17;
    FUN_000946ba();
    fVar1 = fVar15;
    if (fVar15 <= fVar14) {
      fVar1 = fVar14;
    }
    fVar19 = fVar15;
    if (fVar15 <= fVar1) {
      fVar19 = fVar1;
    }
    fVar1 = fVar16;
    if (fVar16 <= fVar17) {
      fVar1 = fVar17;
    }
    fVar13 = fVar17;
    if (fVar17 <= fVar1) {
      fVar13 = fVar1;
    }
    fVar1 = fVar16;
    if (fVar16 <= fVar13) {
      fVar1 = fVar13;
    }
    fVar13 = *(float *)PTR_00336074;
    fVar18 = *(float *)(PTR_00336074 + 4);
    if (local_84 + local_7c < fVar19) {
      fVar13 = (local_84 + local_7c) - fVar19;
    }
    if (local_80 + local_78 < fVar1) {
      fVar18 = (local_80 + local_78) - fVar1;
    }
    FUN_000946ba();
    fVar1 = fVar14 + fVar13;
    if (fVar15 + fVar13 <= fVar14 + fVar13) {
      fVar1 = fVar15 + fVar13;
    }
    if (fVar15 + fVar13 <= fVar1) {
      fVar1 = fVar15 + fVar13;
    }
    lVar12 = (longdouble)_roundf(fVar1);
    local_94 = (float)lVar12;
    fVar1 = fVar17 + fVar18;
    if (fVar16 + fVar18 <= fVar17 + fVar18) {
      fVar1 = fVar16 + fVar18;
    }
    if (fVar17 + fVar18 <= fVar1) {
      fVar1 = fVar17 + fVar18;
    }
    if (fVar16 + fVar18 <= fVar1) {
      fVar1 = fVar16 + fVar18;
    }
    lVar12 = (longdouble)_roundf(fVar1);
    puVar23 = (undefined *)(float)lVar12;
    inView = local_8c;
    fVar14 = fStack_88;
    puStack_90 = puVar23;
    pvVar8 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,local_94,puVar23,local_8c,fStack_88);
    _objc_msgSend(self_00,sel_addObject_,pvVar8);
  }
  local_14c = fStack_88;
  local_150 = local_8c;
  local_134 = local_94;
  local_138 = puStack_90;
  local_95 = false;
  local_9c = 0x7fffffff;
  local_a0 = 0x7fffffff;
  local_a4 = 0x7fffffff;
  local_15c = _objc_msgSend(self_01,sel_nextObject,pvVar8,puVar23,inView,fVar14);
  puVar2 = PTR_00336074;
  if (local_15c != (id)0x0) {
    fVar1 = *(float *)PTR_00336074;
    puVar3 = *(undefined **)(PTR_00336074 + 4);
    local_128 = 0.0;
    bVar5 = true;
    local_140 = 0x7fffffff;
    local_145 = false;
    local_13c = 0x7fffffff;
    local_130 = 0x7fffffff;
    local_160 = (undefined *)0x0;
LAB_00093177:
    puVar23 = puStack_90;
    fVar14 = local_94;
    if (bVar5) {
      fVar15 = (float)local_8c + local_94;
      local_160 = (undefined *)(fStack_88 + (float)puStack_90);
      FUN_000946ba();
      local_44 = CONCAT44(puVar23,fVar15);
      local_4c = CONCAT44(local_160,fVar15);
      local_5c = CONCAT44(puVar23,fVar14);
      local_54 = CONCAT44(local_160,fVar14);
      local_14 = 0;
      local_3c[4] = 0.0;
      local_3c[5] = 0.0;
      local_3c[6] = 0.0;
      local_3c[7] = 0.0;
      local_3c[2] = 0.0;
      local_3c[3] = 0.0;
      local_128 = *(float *)puVar2;
      local_120 = *(float *)(puVar2 + 4);
      uVar10 = 0;
      uVar11 = 0x7fffffff;
      bVar5 = false;
      local_3c[0] = local_128;
      local_3c[1] = local_120;
      do {
        uVar20 = FUN_000927b9(local_5c,(int)local_54,(int)((ulonglong)local_54 >> 0x20),
                              (int)local_4c,(int)((ulonglong)local_4c >> 0x20),(int)local_44,
                              (int)((ulonglong)local_44 >> 0x20));
        fVar14 = (float)((ulonglong)uVar20 >> 0x20);
        local_3c[uVar10 * 2] = (float)uVar20;
        local_3c[uVar10 * 2 + 1] = fVar14;
        if (uVar11 == 0x7fffffff) {
LAB_000933b3:
          bVar5 = false;
          uVar11 = uVar10;
        }
        else {
          if ((fVar14 != 0.0) || (NAN(fVar14))) {
            fVar15 = ABS(fVar14);
          }
          else {
            fVar15 = 1.0;
          }
          if ((local_120 != 0.0) || (NAN(local_120))) {
            fVar16 = ABS(local_120);
          }
          else {
            fVar16 = 1.0;
          }
          if (fVar16 <= fVar15) {
            fVar16 = fVar15;
          }
          if (ABS(fVar14 - local_120) <= fVar16 * 0.0005) {
            if ((float)uVar20 < local_128) {
              bVar5 = true;
              uVar11 = uVar10;
              goto LAB_000933bc;
            }
            bVar5 = true;
          }
          else if (local_120 < fVar14) goto LAB_000933b3;
          uVar20 = CONCAT44(local_120,local_128);
        }
LAB_000933bc:
        local_120 = (float)((ulonglong)uVar20 >> 0x20);
        local_124 = (float)uVar20;
        uVar10 = uVar10 + 1;
        if (uVar10 == 4) goto code_r0x000933c6;
        local_128 = local_124;
      } while( true );
    }
    local_120 = (float)local_13c;
    uVar11 = local_140;
    goto LAB_00093678;
  }
LAB_00093b4a:
  pvVar7 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,self_00,puVar23,inView,fVar14);
  return pvVar7;
code_r0x000933c6:
  if (uVar11 < 4) {
    uVar10 = uVar11;
    if (1 < uVar11) goto LAB_000933f2;
  }
  else {
    if (uVar11 == 0xffffffff) {
      uVar10 = 3;
LAB_000933f2:
      uVar10 = uVar10 - 2;
      goto LAB_000933f5;
    }
    uVar10 = uVar11;
    if (uVar11 != 4) goto LAB_000933f5;
    uVar10 = 0;
  }
  uVar10 = uVar10 + 2;
LAB_000933f5:
  fVar14 = (float)FUN_000927b9(local_5c,(int)local_54,(int)((ulonglong)local_54 >> 0x20),
                               (int)local_4c,(int)((ulonglong)local_4c >> 0x20),(int)local_44,
                               (int)((ulonglong)local_44 >> 0x20));
  if (local_124 <= fVar14) {
    uVar10 = uVar11;
  }
  fVar14 = (float)FUN_000927b9(local_5c,(int)local_54,(int)((ulonglong)local_54 >> 0x20),
                               (int)local_4c,(int)((ulonglong)local_4c >> 0x20),(int)local_44,
                               (int)((ulonglong)local_44 >> 0x20));
  pvVar8 = (id)local_54;
  fVar15 = (float)FUN_000927b9(local_5c,pvVar8,(int)((ulonglong)local_54 >> 0x20),(int)local_4c,
                               (int)((ulonglong)local_4c >> 0x20),(int)local_44,
                               (int)((ulonglong)local_44 >> 0x20));
  uVar9 = uVar10 + 1;
  if (fVar14 < fVar15) {
    uVar9 = uVar10 - 1;
  }
  cVar6 = FUN_0009286c(&local_14);
  if (cVar6 == '\0') {
    local_120 = (float)local_13c;
    uVar11 = local_140;
  }
  else {
    local_145 = !bVar5;
    if (local_145) {
      FUN_000927b9(local_5c,(int)local_54,(int)((ulonglong)local_54 >> 0x20),(int)local_4c,
                   (int)((ulonglong)local_4c >> 0x20),(int)local_44,
                   (int)((ulonglong)local_44 >> 0x20));
      pvVar8 = (id)local_54;
      FUN_000927b9(local_5c,pvVar8,(int)((ulonglong)local_54 >> 0x20),(int)local_4c,
                   (int)((ulonglong)local_4c >> 0x20),(int)local_44,
                   (int)((ulonglong)local_44 >> 0x20));
      local_120 = (float)uVar9;
      local_130 = uVar10;
      if (extraout_EDX_00 < extraout_EDX_01) {
        local_120 = (float)uVar10;
        local_130 = uVar9;
      }
      if (3 < (uint)local_120) {
        if (local_120 == 5.60519e-45) {
          local_120 = 0.0;
        }
        else if (local_120 == -NAN) {
          local_120 = 4.2039e-45;
        }
      }
      if (3 < local_130) {
        if (local_130 == 4) {
          local_130 = 0;
        }
        else if (local_130 == 0xffffffff) {
          local_130 = 3;
        }
      }
    }
    else {
      local_120 = NAN;
      local_130 = 0x7fffffff;
    }
    if (3 < uVar11) {
      if (uVar11 == 4) {
        uVar11 = 0;
      }
      else if (uVar11 == 0xffffffff) {
        uVar11 = 3;
      }
    }
  }
  puVar4 = local_160;
  if ((float)local_160 <= (float)puVar23) {
    puVar4 = puVar23;
  }
  if ((float)puVar23 <= (float)puVar4) {
    puVar23 = puVar4;
  }
  if ((float)local_160 <= (float)puVar23) {
    local_160 = puVar23;
  }
  bVar5 = false;
  local_128 = (float)local_14;
LAB_00093678:
  pvVar7 = _objc_msgSend(local_15c,sel_size,pvVar8);
  puVar23 = puVar3;
  fVar14 = fVar1;
  switch(local_128) {
  case 0.0:
    puVar23 = local_138;
    fVar14 = local_134 - (float)pvVar7;
    break;
  case 1.4013e-45:
    puVar23 = (undefined *)((float)local_138 - extraout_EDX_02);
    fVar14 = local_134;
    break;
  case 2.8026e-45:
    puVar23 = local_138;
    fVar14 = local_134 + (float)local_150;
    break;
  case 4.2039e-45:
    puVar23 = (undefined *)((float)local_138 + local_14c);
    fVar14 = local_134;
  }
  local_134 = fVar14;
  local_138 = puVar23;
  local_dc = local_134;
  puStack_d8 = local_138;
  if (local_145 != false) {
    fVar14 = extraout_EDX_02 + (float)local_138;
    fVar15 = (float)pvVar7 + local_134;
    FUN_000946ba();
    FUN_000927b9(CONCAT44(local_138,local_134),local_134,fVar14,fVar15,fVar14,fVar15,local_138);
    uVar21 = FUN_000927b9(CONCAT44(local_138,local_134),local_134,fVar14,fVar15,fVar14,fVar15,
                          local_138);
    fVar16 = (float)local_160 - extraout_EDX_03;
    uVar22 = FUN_000927b9(CONCAT44(local_138,local_134),local_134,fVar14,fVar15,fVar14,fVar15,
                          local_138);
    fVar17 = (float)((ulonglong)uVar22 >> 0x20) - (float)((ulonglong)uVar21 >> 0x20);
    uVar20 = uVar22;
    if (((fVar16 <= 0.0) || (0.0 <= fVar17)) && ((0.0 <= fVar16 || (fVar17 <= 0.0)))) {
      uVar20 = uVar21;
      uVar21 = uVar22;
    }
    fVar19 = (((float)uVar21 - (float)uVar20) * fVar16) /
             ((float)((ulonglong)uVar21 >> 0x20) - (float)((ulonglong)uVar20 >> 0x20));
    FUN_000946ba();
    fVar17 = local_134 + fVar19;
    if (fVar15 + fVar19 <= local_134 + fVar19) {
      fVar17 = fVar15 + fVar19;
    }
    if (fVar19 + fVar15 <= fVar17) {
      fVar17 = fVar19 + fVar15;
    }
    lVar12 = (longdouble)_roundf(fVar17);
    local_dc = (float)lVar12;
    fVar15 = (float)local_138 + fVar16;
    if (fVar14 + fVar16 <= (float)local_138 + fVar16) {
      fVar15 = fVar14 + fVar16;
    }
    if ((float)local_138 + fVar16 <= fVar15) {
      fVar15 = (float)local_138 + fVar16;
    }
    if (fVar16 + fVar14 <= fVar15) {
      fVar15 = fVar16 + fVar14;
    }
    lVar12 = (longdouble)_roundf(fVar15);
    puStack_d8 = (undefined *)(float)lVar12;
  }
  puVar23 = puStack_d8;
  inView = pvVar7;
  fVar14 = extraout_EDX_02;
  pvVar8 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,local_dc,puStack_d8,pvVar7,extraout_EDX_02);
  _objc_msgSend(self_00,sel_addObject_,pvVar8);
  local_134 = local_dc;
  local_138 = puStack_d8;
  local_15c = _objc_msgSend(self_01,sel_nextObject);
  if (local_15c == (id)0x0) goto code_r0x00093b20;
  local_13c = (uint)local_120;
  local_150 = pvVar7;
  local_14c = extraout_EDX_02;
  local_140 = uVar11;
  goto LAB_00093177;
code_r0x00093b20:
  local_a0 = local_130;
  local_9c = (uint)local_120;
  local_95 = local_145;
  local_a4 = uVar11;
  goto LAB_00093b4a;
}

*/
- (id)compositeRectsForIcons:(id)aIcons inView:(id)aView
{
    NSAffineTransform *transform = [NSAffineTransform transformWithHyperCGAffineTransform:[self transformForTraitRectsInView:aView]];
    NSAffineTransform *inverse = [[transform copy] autorelease];
    [inverse invert];
    NSRect bounds = [self boundsForTraitRectsInView:aView];
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:[aIcons count]];
    NSEnumerator *enumerator = [aIcons objectEnumerator];
    NSRect rect = NSZeroRect;
    id icon = [enumerator nextObject];
    if (icon != nil) {
        NSSize size = [icon size];
        NSPoint corner = NSMakePoint(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
        [transform hyperTransformPoints:&corner count:1];
        rect.origin.x = corner.x - size.width;
        rect.origin.y = corner.y - size.height;
        rect.size = size;
        HSAuxiliaryCorners corners = HSAuxiliaryCornersForRect(rect);
        HSAuxiliaryTransformCorners(inverse, &corners);
        float maxX = MAX(corners.p[3].x, MAX(corners.p[2].x, MAX(corners.p[1].x, corners.p[0].x)));
        float maxY = MAX(corners.p[3].y, MAX(corners.p[2].y, MAX(corners.p[1].y, corners.p[0].y)));
        NSPoint offset = NSZeroPoint;
        if (maxX > bounds.origin.x + bounds.size.width) {
            offset.x = (bounds.origin.x + bounds.size.width) - maxX;
        }
        if (maxY > bounds.origin.y + bounds.size.height) {
            offset.y = (bounds.origin.y + bounds.size.height) - maxY;
        }
        for (int i = 0; i < 4; i++) {
            corners.p[i].x += offset.x;
            corners.p[i].y += offset.y;
        }
        HSAuxiliaryTransformCorners(transform, &corners);
        rect.origin.x = roundf(MIN(MIN(corners.p[0].x, corners.p[1].x), MIN(corners.p[3].x, corners.p[2].x)));
        rect.origin.y = roundf(MIN(MIN(corners.p[0].y, corners.p[1].y), MIN(corners.p[3].y, corners.p[2].y)));
        [rects addObject:[NSValue valueWithRect:rect]];
    }
    NSPoint previousOrigin = rect.origin;
    NSSize previousSize = rect.size;
    BOOL needsEdgeSearch = YES;
    BOOL slides = NO;
    NSUInteger edge = 0;
    NSUInteger topCorner = HSAuxiliaryNoCorner;
    NSUInteger lowCorner = HSAuxiliaryNoCorner;
    NSUInteger highCorner = HSAuxiliaryNoCorner;
    float previousMaxY = 0.0f;
    while ((icon = [enumerator nextObject]) != nil) {
        if (needsEdgeSearch) {
            HSAuxiliaryCorners corners = HSAuxiliaryCornersForRect(NSMakeRect(previousOrigin.x, previousOrigin.y, previousSize.width, previousSize.height));
            HSAuxiliaryTransformCorners(inverse, &corners);
            NSPoint best = NSZeroPoint;
            BOOL tie = NO;
            NSUInteger top = HSAuxiliaryNoCorner;
            NSUInteger savedTop = topCorner;
            NSUInteger savedLow = lowCorner;
            edge = 0;
            for (NSUInteger i = 0; i < 4; i++) {
                NSPoint point = HSAuxiliaryCornerPoint(corners, i);
                if (top == HSAuxiliaryNoCorner) {
                    tie = NO;
                    top = i;
                    best = point;
                }
                else if (fabsf(point.y - best.y) <= MAX(HSAuxiliaryScale(point.y), HSAuxiliaryScale(best.y)) * 0.0005f) {
                    tie = YES;
                    if (best.x > point.x) {
                        top = i;
                        best = point;
                    }
                }
                else if (point.y > best.y) {
                    tie = NO;
                    top = i;
                    best = point;
                }
            }
            NSUInteger opposite = (top < 4) ? ((top > 1) ? top - 2 : top + 2) : ((top == (NSUInteger)-1) ? 1 : ((top == 4) ? 2 : top));
            NSUInteger k = (best.x <= HSAuxiliaryCornerPoint(corners, opposite).x) ? top : opposite;
            float previousX = HSAuxiliaryCornerPoint(corners, k - 1).x;
            float nextX = HSAuxiliaryCornerPoint(corners, k + 1).x;
            NSUInteger m = (nextX > previousX) ? k - 1 : k + 1;
            if (HSAuxiliaryEdgeBetweenCorners(&edge, k, m)) {
                slides = !tie;
                if (slides) {
                    BOOL mHigher = HSAuxiliaryCornerPoint(corners, m).y > HSAuxiliaryCornerPoint(corners, k).y;
                    highCorner = mHigher ? m : k;
                    lowCorner = mHigher ? k : m;
                    lowCorner = HSAuxiliaryWrapCorner(lowCorner);
                    highCorner = HSAuxiliaryWrapCorner(highCorner);
                }
                else {
                    lowCorner = HSAuxiliaryNoCorner;
                    highCorner = HSAuxiliaryNoCorner;
                }
                topCorner = HSAuxiliaryWrapCorner(top);
            }
            else {
                topCorner = savedTop;
                lowCorner = savedLow;
            }
            previousMaxY = MAX(corners.p[3].y, MAX(corners.p[2].y, MAX(corners.p[1].y, corners.p[0].y)));
            needsEdgeSearch = NO;
        }
        NSSize size = [icon size];
        NSPoint origin = NSZeroPoint;
        switch (edge) {
            case 0:
                origin = NSMakePoint(previousOrigin.x - size.width, previousOrigin.y);
                break;
            case 1:
                origin = NSMakePoint(previousOrigin.x, previousOrigin.y - size.height);
                break;
            case 2:
                origin = NSMakePoint(previousOrigin.x + previousSize.width, previousOrigin.y);
                break;
            case 3:
                origin = NSMakePoint(previousOrigin.x, previousOrigin.y + previousSize.height);
                break;
        }
        NSRect placed = NSMakeRect(origin.x, origin.y, size.width, size.height);
        if (slides) {
            HSAuxiliaryCorners corners = HSAuxiliaryCornersForRect(placed);
            HSAuxiliaryTransformCorners(inverse, &corners);
            float topY = HSAuxiliaryCornerPoint(corners, topCorner).y;
            NSPoint low = HSAuxiliaryCornerPoint(corners, lowCorner);
            float rise = previousMaxY - topY;
            NSPoint high = HSAuxiliaryCornerPoint(corners, highCorner);
            float slope = high.y - low.y;
            NSPoint first = low;
            NSPoint second = high;
            if ((rise > 0.0f && slope < 0.0f) || (rise < 0.0f && slope > 0.0f)) {
                first = high;
                second = low;
            }
            float shift = ((second.x - first.x) * rise) / (second.y - first.y);
            for (int i = 0; i < 4; i++) {
                corners.p[i].x += shift;
                corners.p[i].y += rise;
            }
            HSAuxiliaryTransformCorners(transform, &corners);
            placed.origin.x = roundf(MIN(MIN(corners.p[0].x, corners.p[1].x), MIN(corners.p[3].x, corners.p[2].x)));
            placed.origin.y = roundf(MIN(MIN(corners.p[0].y, corners.p[1].y), MIN(corners.p[3].y, corners.p[2].y)));
        }
        [rects addObject:[NSValue valueWithRect:placed]];
        previousOrigin = placed.origin;
        previousSize = placed.size;
    }
    return [NSArray arrayWithArray:rects];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092972 @ 00092972, 80 bytes * /

CGAffineTransform *
FUN_00092972(CGAffineTransform *__return_storage_ptr__,HSAuxiliaryIconsCanvasItem *self,SEL _cmd,
            id transformForTraitRectsInView)

{
  float fVar1;
  undefined *puVar2;
  CGAffineTransform *pCVar3;
  
  puVar2 = PTR_00336088;
  pCVar3 = (CGAffineTransform *)PTR_00336088;
  fVar1 = *(float *)(PTR_00336088 + 4);
  __return_storage_ptr__->a = *(float *)PTR_00336088;
  __return_storage_ptr__->b = fVar1;
  __return_storage_ptr__->c = *(float *)(puVar2 + 8);
  __return_storage_ptr__->d = *(float *)(puVar2 + 0xc);
  __return_storage_ptr__->tx = *(float *)(puVar2 + 0x10);
  __return_storage_ptr__->ty = *(float *)(puVar2 + 0x14);
  return pCVar3;
}

*/
- (CGAffineTransform)transformForTraitRectsInView:(id)aView
{
    return CGAffineTransformIdentity;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092936 @ 00092936, 60 bytes * /

NSRect * FUN_00092936(NSRect *__return_storage_ptr__,HSAuxiliaryIconsCanvasItem *self,SEL _cmd,
                     id boundsForTraitRectsInView)

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
- (NSRect)boundsForTraitRectsInView:(id)aView
{
    return NSZeroRect;
}

- (id)userObject
{
    return [_traits userObject];
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return [HSCursor cursorNamed:HSDefaultCursor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00093be6 @ 00093be6, 448 bytes * /

BOOL FUN_00093be6(HSAuxiliaryIconsCanvasItem *self,SEL _cmd,NSPoint hitTestPoint,id inCanvasLayer)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  float *pfVar4;
  float afStack_44 [2];
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar2 = _objc_msgSend(self,sel_userObject);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
  pvVar2 = _objc_msgSend(pvVar2,sel_isHiddenInPlayer);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_userObject);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_cardObjectsVisibility);
    if (pvVar2 == (id)0x2) {
      return '\0';
    }
  }
  pvVar2 = _objc_msgSend(self,sel_userObject);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
  pvVar2 = _objc_msgSend(pvVar2,sel_isVisibleInEditor);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(inCanvasLayer,sel_context);
    _objc_msgSend(pvVar2,sel_renderingView);
    pvVar2 = _objc_msgSend(self,sel_traitRectsInView_);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    pfVar4 = (float *)&stack0xffffffc4;
    while( true ) {
      pfVar4[1] = (float)sel_nextObject;
      *pfVar4 = (float)pvVar2;
      pfVar4[-1] = 8.48497e-40;
      pvVar3 = _objc_msgSend((id)*pfVar4,(SEL)pfVar4[1]);
      if (pvVar3 == (id)0x0) break;
      pfVar4[2] = (float)sel_rectValue;
      pfVar4[1] = (float)pvVar3;
      *pfVar4 = (float)&local_24;
      pfVar4[-1] = 8.48539e-40;
      _objc_msgSend_stret((void *)*pfVar4,(id)pfVar4[1],(SEL)pfVar4[2]);
      *(undefined8 *)(pfVar4 + 3) = local_1c;
      *(undefined8 *)(pfVar4 + 1) = local_24;
      *pfVar4 = hitTestPoint.y;
      pfVar4[-1] = hitTestPoint.x;
      pfVar4[-2] = 8.48611e-40;
      cVar1 = _NSPointInRect();
      pfVar4 = pfVar4 + -1;
      if (cVar1 != '\0') {
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    if ([[[self userObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer]) {
        if ([[[[self userObject] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] cardObjectsVisibility] == 2) {
            return NO;
        }
    }
    if ([[[self userObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isVisibleInEditor]) {
        id view = [[aLayer context] renderingView];
        NSEnumerator *rects = [[self traitRectsInView:view] objectEnumerator];
        id value;
        while ((value = [rects nextObject]) != nil) {
            if (NSPointInRect(aPoint, [value rectValue])) {
                return YES;
            }
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00093da6 @ 00093da6, 1254 bytes * /

BOOL FUN_00093da6(HSAuxiliaryIconsCanvasItem *self,SEL _cmd,id updateIfNeededInCanvasLayer)

{
  float fVar1;
  float fVar2;
  float fVar3;
  id pvVar4;
  HSAuxiliaryIconsCanvasItem *self_00;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  HSAuxiliaryIconsCanvasItem *pHVar10;
  BOOL local_3d;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar4 = _objc_msgSend(self,sel_userTraitsDidChange);
  if ((char)pvVar4 != '\0') {
    return (char)pvVar4;
  }
  if (self->_traitRects == (id)0x0) {
    return '\x01';
  }
  self_00 = _objc_msgSend(self->_traitRects,sel_retain);
  pvVar4 = _objc_msgSend(updateIfNeededInCanvasLayer,sel_context);
  pvVar4 = _objc_msgSend(pvVar4,sel_renderingView);
  _objc_msgSend_stret(&local_24,self,sel_boundsForTraitRectsInView_,pvVar4);
  pHVar10 = self;
  _objc_msgSend_stret(&local_3c,self,sel_transformForTraitRectsInView_,pvVar4);
  fVar6 = ABS(local_20) + local_18;
  fVar1 = (self->_boundsUsedForRectCalculations).origin.y;
  fVar7 = (self->_boundsUsedForRectCalculations).size.height;
  fVar9 = ABS(fVar1) + fVar7;
  if ((fVar9 != 0.0) || (NAN(fVar9))) {
    fVar9 = ABS(fVar9);
  }
  else {
    fVar9 = 1.0;
  }
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar6 = ABS(fVar6);
  }
  else {
    fVar6 = 1.0;
  }
  fVar8 = ABS(local_24) + local_1c;
  fVar2 = (self->_boundsUsedForRectCalculations).origin.x;
  fVar3 = (self->_boundsUsedForRectCalculations).size.width;
  fVar5 = ABS(fVar2) + fVar3;
  if (fVar6 <= fVar9) {
    fVar6 = fVar9;
  }
  if ((fVar5 != 0.0) || (NAN(fVar5))) {
    fVar5 = ABS(fVar5);
  }
  else {
    fVar5 = 1.0;
  }
  if ((fVar8 != 0.0) || (NAN(fVar8))) {
    fVar8 = ABS(fVar8);
  }
  else {
    fVar8 = 1.0;
  }
  if (fVar8 <= fVar5) {
    fVar8 = fVar5;
  }
  local_3d = '\0';
  if ((((ABS(fVar2 - local_24) <= fVar8 * 0.0005) && (ABS(fVar1 - local_20) <= fVar6 * 0.0005)) &&
      (ABS(fVar3 - local_1c) <= fVar8 * 0.0005)) && (ABS(fVar7 - local_18) <= fVar6 * 0.0005)) {
    fVar1 = (self->_transformUsedForRectCalculations).a;
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar7 = ABS(fVar1);
    }
    else {
      fVar7 = 1.0;
    }
    if ((local_3c != 0.0) || (NAN(local_3c))) {
      fVar9 = ABS(local_3c);
    }
    else {
      fVar9 = 1.0;
    }
    if (fVar9 <= fVar7) {
      fVar9 = fVar7;
    }
    if (ABS(fVar1 - local_3c) <= fVar9 * 0.0005) {
      fVar1 = (self->_transformUsedForRectCalculations).b;
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar7 = ABS(fVar1);
      }
      else {
        fVar7 = 1.0;
      }
      if ((local_38 != 0.0) || (NAN(local_38))) {
        fVar9 = ABS(local_38);
      }
      else {
        fVar9 = 1.0;
      }
      if (fVar9 <= fVar7) {
        fVar9 = fVar7;
      }
      if (ABS(fVar1 - local_38) <= fVar9 * 0.0005) {
        fVar1 = (self->_transformUsedForRectCalculations).c;
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fVar7 = ABS(fVar1);
        }
        else {
          fVar7 = 1.0;
        }
        if ((local_34 != 0.0) || (NAN(local_34))) {
          fVar9 = ABS(local_34);
        }
        else {
          fVar9 = 1.0;
        }
        if (fVar9 <= fVar7) {
          fVar9 = fVar7;
        }
        if (ABS(fVar1 - local_34) <= fVar9 * 0.0005) {
          fVar1 = (self->_transformUsedForRectCalculations).d;
          if ((fVar1 != 0.0) || (NAN(fVar1))) {
            fVar7 = ABS(fVar1);
          }
          else {
            fVar7 = 1.0;
          }
          if ((local_30 != 0.0) || (NAN(local_30))) {
            fVar9 = ABS(local_30);
          }
          else {
            fVar9 = 1.0;
          }
          if (fVar9 <= fVar7) {
            fVar9 = fVar7;
          }
          if (ABS(fVar1 - local_30) <= fVar9 * 0.0005) {
            fVar1 = (self->_transformUsedForRectCalculations).tx;
            if ((fVar1 != 0.0) || (NAN(fVar1))) {
              fVar7 = ABS(fVar1);
            }
            else {
              fVar7 = 1.0;
            }
            if ((local_2c != 0.0) || (NAN(local_2c))) {
              fVar9 = ABS(local_2c);
            }
            else {
              fVar9 = 1.0;
            }
            if (fVar9 <= fVar7) {
              fVar9 = fVar7;
            }
            if (ABS(fVar1 - local_2c) <= fVar9 * 0.0005) {
              fVar1 = (self->_transformUsedForRectCalculations).ty;
              if ((fVar1 != 0.0) || (NAN(fVar1))) {
                fVar7 = ABS(fVar1);
              }
              else {
                fVar7 = 1.0;
              }
              if ((local_28 != 0.0) || (NAN(local_28))) {
                fVar9 = ABS(local_28);
              }
              else {
                fVar9 = 1.0;
              }
              if (fVar9 <= fVar7) {
                fVar9 = fVar7;
              }
              if (ABS(fVar1 - local_28) <= fVar9 * 0.0005) goto LAB_00094269;
            }
          }
        }
      }
    }
  }
  _objc_msgSend(self,sel_invalidateTraitRects);
  pvVar4 = _objc_msgSend(self,sel_traitRectsInView_,pvVar4);
  pHVar10 = self_00;
  pvVar4 = _objc_msgSend(pvVar4,sel_isEqualToArray_,self_00);
  if ((char)pvVar4 == '\0') {
    local_3d = '\x01';
  }
LAB_00094269:
  _objc_msgSend(self_00,sel_release,pHVar10);
  return local_3d;
}

*/
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    BOOL changed = [self userTraitsDidChange];
    if (changed) {
        return changed;
    }
    if (_traitRects == nil) {
        return YES;
    }
    NSArray *previousRects = [_traitRects retain];
    id view = [[aLayer context] renderingView];
    NSRect bounds = [self boundsForTraitRectsInView:view];
    CGAffineTransform transform = [self transformForTraitRectsInView:view];
    float oldY = fabs(_boundsUsedForRectCalculations.origin.y) + _boundsUsedForRectCalculations.size.height;
    float newY = fabs(bounds.origin.y) + bounds.size.height;
    float scaleY = MAX((newY != 0.0f) ? fabsf(newY) : 1.0f, (oldY != 0.0f) ? fabsf(oldY) : 1.0f);
    float oldX = fabs(_boundsUsedForRectCalculations.origin.x) + _boundsUsedForRectCalculations.size.width;
    float newX = fabs(bounds.origin.x) + bounds.size.width;
    float scaleX = MAX((newX != 0.0f) ? fabsf(newX) : 1.0f, (oldX != 0.0f) ? fabsf(oldX) : 1.0f);
    BOOL same = fabs(_boundsUsedForRectCalculations.origin.x - bounds.origin.x) <= scaleX * 0.0005f &&
                fabs(_boundsUsedForRectCalculations.origin.y - bounds.origin.y) <= scaleY * 0.0005f &&
                fabs(_boundsUsedForRectCalculations.size.width - bounds.size.width) <= scaleX * 0.0005f &&
                fabs(_boundsUsedForRectCalculations.size.height - bounds.size.height) <= scaleY * 0.0005f &&
                HSTraitValuesEqual(_transformUsedForRectCalculations.a, transform.a) &&
                HSTraitValuesEqual(_transformUsedForRectCalculations.b, transform.b) &&
                HSTraitValuesEqual(_transformUsedForRectCalculations.c, transform.c) &&
                HSTraitValuesEqual(_transformUsedForRectCalculations.d, transform.d) &&
                HSTraitValuesEqual(_transformUsedForRectCalculations.tx, transform.tx) &&
                HSTraitValuesEqual(_transformUsedForRectCalculations.ty, transform.ty);
    if (!same) {
        [self invalidateTraitRects];
        if (![[self traitRectsInView:view] isEqualToArray:previousRects]) {
            changed = YES;
        }
    }
    [previousRects release];
    return changed;
}

- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    id pvVar1;

    pvVar1 = _traitsRegion;
    if (pvVar1 == nil) {
        pvVar1 = [[HSRegion regionWithRectValues:[self traitRectsInView:[[aLayer context] renderingView]]] retain];
        _traitsRegion = pvVar1;
    }
    return pvVar1;
}

- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    NSRect result;

    result = [_traits boundingRectForIconRects:[self traitRectsInView:[[aLayer context] renderingView]]];
    return result;
}

- (BOOL)prefersRegionInvalidation
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00094394 @ 00094394, 491 bytes * /

void FUN_00094394(HSAuxiliaryIconsCanvasItem *self,SEL _cmd,NSRect renderRect,id inCanvasLayer,
                 BOOL isActive)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_userObject);
  puVar3 = &DAT_00366bdc;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00366bdc);
  pvVar1 = _objc_msgSend(pvVar1,sel_isHiddenInPlayer);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_userObject,puVar3);
    puVar3 = &DAT_00366d1c;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00366d1c);
    pvVar1 = _objc_msgSend(pvVar1,sel_stack);
    pvVar1 = _objc_msgSend(pvVar1,sel_cardObjectsVisibility);
    if (pvVar1 == (id)0x2) {
      pvVar1 = _objc_msgSend(cls_HSGlobalSelectionSync,sel_globalSelectionSync,puVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_currentSelectedObject);
      pvVar2 = _objc_msgSend(self,sel_userObject);
      if (pvVar1 != pvVar2) {
        return;
      }
    }
  }
  pvVar1 = _objc_msgSend(self,sel_userObject,puVar3);
  puVar3 = &DAT_00366bdc;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00366bdc);
  pvVar1 = _objc_msgSend(pvVar1,sel_isVisibleInEditor);
  if (((char)pvVar1 != '\0') && (self->_traits != (id)0x0)) {
    pvVar1 = _objc_msgSend(inCanvasLayer,sel_context,puVar3);
    pvVar2 = _objc_msgSend(pvVar1,sel_renderingView);
    pvVar2 = _objc_msgSend(self,sel_traitRectsInView_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_renderingView);
    _objc_msgSend(self->_traits,sel_renderIconsInRects_clipRect_inView_,pvVar2,renderRect.origin,
                  renderRect.size,pvVar1);
  }
  return;
}

*/
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    if ([[[self userObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer]) {
        if ([[[[self userObject] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] cardObjectsVisibility] == 2) {
            if ([[HSGlobalSelectionSync globalSelectionSync] currentSelectedObject] != [self userObject]) {
                return;
            }
        }
    }
    if ([[[self userObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isVisibleInEditor] && _traits != nil) {
        id context = [aLayer context];
        id rects = [self traitRectsInView:[context renderingView]];
        [_traits renderIconsInRects:rects clipRect:aRect inView:[context renderingView]];
    }
}

- (BOOL)userTraitsDidChange
{
    BOOL pvVar1;

    pvVar1 = [_traits updateTraitsIfNeeded];
    if (pvVar1) {
        [self invalidateTraitRects];
    }
    return pvVar1;
}

- (void)geometryDidChange
{
    [self invalidateTraitRects];
}

- (void)invalidateTraitRects
{
    [_traitRects release];
    _traitRects = nil;
    [_traitsRegion release];
    _traitsRegion = nil;
}

- (void)dealloc
{
    [_traits release];
    [_traitRects release];
    [_traitsRegion release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject
{
    return nil;
}

- (id)initWithNode:(id)aNode
{
    id pvVar2_2;

    self = [super initWithHyperObject:aNode];
    if (self != nil) {
        pvVar2_2 = [[HSAuxiliaryUserObjectTraits alloc] init];
        _traits = pvVar2_2;
        [pvVar2_2 setUserObject:aNode];
    }
    return self;
}

@end

