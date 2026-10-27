#import "HSDefaultWindowsLayoutManager.h"

@implementation HSDefaultWindowsLayoutManager

/* i386 ivar offsets: _defaults=0x4, _screenFrame=0x8, _visibleScreenFrame=0x18, _idealLayoutSize=0x28, _idealLayoutToScreenOffset=0x30, _leftPalettesMinX=0x38, _rightPalettesMinX=0x3c, _rightPalettesMaxX=0x40, _mainWindowFrame=0x44, _pallettesFrameValuesDictionary=0x54, _leftPalettesFrameValues=0x58, _rightPalettesFrameValues=0x5c */

+ (id)windowsLayoutManagerWithDefaults:(id)aDefaults
{
    return [[[self alloc] initWithDefaults:aDefaults] autorelease];
}

- (id)defaults
{
    return _defaults;
}

- (void)applySmartDefaultWindowsLayout
{
    if ([self defaults] != nil) {
        [self mergeDefaultsWithResolutionDependentDefaults];
        [self shiftLeftPalettesOnCardIndexWidthIfCan];
        [self shiftRightPalettesToRespectMainWindowIfCan];
        [self applySmartLayoutCorrectionsToPalettes];
        [self applySmartLayoutCorrectionsToMainWindow];
        [self synchronizeWithDefaults];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024677e @ 0024677e, 868 bytes * /

void FUN_0024677e(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined8 local_24;
  undefined8 local_1c;
  
  self_00 = _objc_msgSend(self,sel_palettesAutoSaveNamesEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  do {
    if (pvVar1 == (id)0x0) {
      pvVar1 = self->_defaults;
      _objc_msgSend_stret(&local_24,self,sel_mainWindowFrame);
      uVar4 = _NSStringFromRect(local_24,local_1c);
      _objc_msgSend(pvVar1,sel_setObject_forKey_,uVar4,&cfstr_HSUntitledWindowFrame);
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_pallettesFrameValuesDictionary);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if ((id)0x7 < pvVar3) {
      _objc_msgSend(pvVar2,sel_componentsJoinedByString_);
      _objc_msgSend(self->_defaults,sel_setValue_forKey_);
      pvVar3 = _objc_msgSend(pvVar1,sel_isEqualToString_);
      if ((char)pvVar3 == '\0') {
        pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_);
        if ((char)pvVar1 == '\0') goto LAB_0024681f;
        pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
        _objc_msgSend_fpret(pvVar1,sel_floatValue);
        pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
        _objc_msgSend_fpret(pvVar1,sel_floatValue);
        pvVar1 = self->_defaults;
        _NSStringFromPoint();
      }
      else {
        pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
        _objc_msgSend_fpret(pvVar1,sel_floatValue);
        pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
        _objc_msgSend_fpret(pvVar1,sel_floatValue);
        pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
        _objc_msgSend_fpret(pvVar1,sel_floatValue);
        pvVar1 = self->_defaults;
        _NSStringFromPoint();
        _objc_msgSend(pvVar1,sel_setValue_forKey_);
        pvVar1 = self->_defaults;
        _NSStringFromPoint();
      }
      _objc_msgSend(pvVar1,sel_setValue_forKey_);
    }
LAB_0024681f:
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  } while( true );
}

*/
- (void)synchronizeWithDefaults
{
    NSEnumerator *enumerator = [self palettesAutoSaveNamesEnumerator];
    NSString *name;

    while ((name = [enumerator nextObject]) != nil) {
        NSArray *values = [[self pallettesFrameValuesDictionary] objectForKey:name];
        if ([values count] <= 7) {
            continue;
        }
        [_defaults setValue:[values componentsJoinedByString:@" "] forKey:name];
        if ([name isEqualToString:@"NSWindow Frame HSObjectAssistantWindow"]) {
            float y = [[values objectAtIndex:1] floatValue];
            float x = [[values objectAtIndex:0] floatValue];
            float height = [[values objectAtIndex:3] floatValue];
            [_defaults setValue:NSStringFromPoint(NSMakePoint(x, y)) forKey:HSInspectorOriginKey];
            [_defaults setValue:NSStringFromPoint(NSMakePoint(x, y + height)) forKey:HSInspectorTopLeftKey];
        }
        else if ([name isEqualToString:@"NSWindow Frame HSToolPaletteControllerFrame"]) {
            float y = [[values objectAtIndex:1] floatValue];
            float x = [[values objectAtIndex:0] floatValue];
            [_defaults setValue:NSStringFromPoint(NSMakePoint(x, y)) forKey:@"HSToolPaletteFrameTopLeft"];
        }
    }
    [_defaults setObject:NSStringFromRect([self mainWindowFrame]) forKey:@"HSUntitledWindowFrame"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00246ae2 @ 00246ae2, 180 bytes * /

void FUN_00246ae2(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  float extraout_EDX;
  double dVar1;
  float local_1c;
  float fStack_18;
  undefined8 local_14;
  
  _objc_msgSend_stret(&local_1c,self,sel_mainWindowFrame);
  dVar1 = _objc_msgSend_fpret(self,sel_resultLayoutHorizontalOffset);
  local_1c = local_1c + (float)dVar1;
  _objc_msgSend(self,sel_idealLayoutToScreenOffset);
  fStack_18 = extraout_EDX + fStack_18;
  _objc_msgSend(self,sel_setMainWindowFrame_,CONCAT44(fStack_18,local_1c),local_14);
  return;
}

*/
- (void)applySmartLayoutCorrectionsToMainWindow
{
    NSRect frame = [self mainWindowFrame];
    frame.origin.x += (float)[self resultLayoutHorizontalOffset];
    frame.origin.y += [self idealLayoutToScreenOffset].height;
    [self setMainWindowFrame:frame];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00246b96 @ 00246b96, 1272 bytes * /

void FUN_00246b96(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  double *pdVar4;
  double *pdVar5;
  float fVar6;
  double dVar7;
  double dVar8;
  double dVar9;
  double dVar10;
  double local_ac;
  undefined1 local_74 [8];
  float local_6c;
  undefined1 local_64 [8];
  float local_5c;
  float local_54 [4];
  undefined1 local_44 [4];
  float local_40;
  undefined1 local_34 [8];
  float local_2c;
  undefined1 local_24 [12];
  float local_18;
  
  pdVar4 = (double *)&stack0xffffff34;
  self_00 = _objc_msgSend(self,sel_palettesAutoSaveNamesEnumerator);
  dVar7 = _objc_msgSend_fpret(self,sel_resultLayoutHorizontalOffset);
  pvVar2 = _objc_msgSend(self_00,sel_nextObject);
  while (pvVar2 != (id)0x0) {
    *(undefined **)((int)pdVar4 + 4) = sel_pallettesFrameValuesDictionary;
    *(HSDefaultWindowsLayoutManager **)pdVar4 = self;
    *(undefined4 *)((int)pdVar4 + -4) = 0x246c18;
    pvVar3 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
    *(id *)((int)pdVar4 + 8) = pvVar2;
    *(undefined **)((int)pdVar4 + 4) = sel_objectForKey_;
    *(id *)pdVar4 = pvVar3;
    *(undefined4 *)((int)pdVar4 + -4) = 0x246c2e;
    pvVar2 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
    *(undefined **)((int)pdVar4 + 4) = sel_count;
    *(id *)pdVar4 = pvVar2;
    *(undefined4 *)((int)pdVar4 + -4) = 0x246c42;
    pvVar3 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
    if ((id)0x7 < pvVar3) {
      *(undefined **)((int)pdVar4 + 4) = sel_objectAtIndex_;
      *(id *)pdVar4 = pvVar2;
      *(int *)((int)pdVar4 + 8) = 1;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246c84;
      pvVar3 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_floatValue;
      *(id *)pdVar4 = pvVar3;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246c96;
      dVar8 = _objc_msgSend_fpret(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_objectAtIndex_;
      *(id *)pdVar4 = pvVar2;
      *(int *)((int)pdVar4 + 8) = 0;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246cb6;
      pvVar3 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_floatValue;
      *(id *)pdVar4 = pvVar3;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246cc8;
      dVar9 = _objc_msgSend_fpret(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_objectAtIndex_;
      *(id *)pdVar4 = pvVar2;
      *(int *)((int)pdVar4 + 8) = 3;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246ce8;
      pvVar3 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_floatValue;
      *(id *)pdVar4 = pvVar3;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246cfa;
      _objc_msgSend_fpret(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_objectAtIndex_;
      *(id *)pdVar4 = pvVar2;
      *(int *)((int)pdVar4 + 8) = 2;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246d16;
      pvVar3 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_floatValue;
      *(id *)pdVar4 = pvVar3;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246d28;
      dVar10 = _objc_msgSend_fpret(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 4) = sel_idealLayoutToScreenOffset;
      *(HSDefaultWindowsLayoutManager **)pdVar4 = self;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246d43;
      _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
      *(undefined **)((int)pdVar4 + 8) = sel_screenFrame;
      *(HSDefaultWindowsLayoutManager **)((int)pdVar4 + 4) = self;
      *(undefined1 **)pdVar4 = local_74;
      fVar6 = (float)dVar9 + (float)dVar7;
      *(undefined4 *)((int)pdVar4 + -4) = 0x246daa;
      _objc_msgSend_stret(*(void **)pdVar4,*(id *)((int)pdVar4 + 4),*(SEL *)((int)pdVar4 + 8));
      pdVar5 = (double *)((int)pdVar4 + -4);
      if (local_6c < fVar6 + (float)dVar10) {
        *(undefined **)((int)pdVar4 + 4) = sel_screenFrame;
        *(HSDefaultWindowsLayoutManager **)pdVar4 = self;
        *(undefined1 **)((int)pdVar4 + -4) = local_64;
        *(undefined4 *)((int)pdVar4 + -8) = 0x246de8;
        _objc_msgSend_stret(*(void **)((int)pdVar4 + -4),*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
        pdVar5 = (double *)((int)pdVar4 + -8);
        fVar6 = local_5c - (float)dVar10;
      }
      local_ac = 0.0;
      dVar9 = 0.0;
      if (0.0 <= fVar6) {
        dVar9 = (double)fVar6;
      }
      *(double *)((int)pdVar5 + 0xc) = dVar9;
      *(cfstringStruct **)(pdVar5 + 1) = &cfstr___0f;
      *(undefined **)((int)pdVar5 + 4) = sel_stringWithFormat_;
      *(undefined **)pdVar5 = cls_NSString;
      *(undefined4 *)((int)pdVar5 + -4) = 0x246e4d;
      pvVar3 = _objc_msgSend(*(id *)pdVar5,*(SEL *)((int)pdVar5 + 4));
      *(id *)((int)pdVar5 + 0xc) = pvVar3;
      *(undefined **)((int)pdVar5 + 4) = sel_replaceObjectAtIndex_withObject_;
      *(id *)pdVar5 = pvVar2;
      *(int *)(pdVar5 + 1) = 0;
      if (0.0 <= extraout_EDX + (float)dVar8) {
        local_ac = (double)(extraout_EDX + (float)dVar8);
      }
      *(undefined4 *)((int)pdVar5 + -4) = 0x246e88;
      _objc_msgSend(*(id *)pdVar5,*(SEL *)((int)pdVar5 + 4));
      *(double *)((int)pdVar5 + 0xc) = local_ac;
      *(cfstringStruct **)(pdVar5 + 1) = &cfstr___0f;
      *(undefined **)((int)pdVar5 + 4) = sel_stringWithFormat_;
      *(undefined **)pdVar5 = cls_NSString;
      *(undefined4 *)((int)pdVar5 + -4) = 0x246eb8;
      pvVar3 = _objc_msgSend(*(id *)pdVar5,*(SEL *)((int)pdVar5 + 4));
      *(id *)((int)pdVar5 + 0xc) = pvVar3;
      *(undefined **)((int)pdVar5 + 4) = sel_replaceObjectAtIndex_withObject_;
      *(id *)pdVar5 = pvVar2;
      *(int *)(pdVar5 + 1) = 1;
      *(undefined4 *)((int)pdVar5 + -4) = 0x246ed6;
      _objc_msgSend(*(id *)pdVar5,*(SEL *)((int)pdVar5 + 4));
      puVar1 = cls_NSString;
      *(undefined **)(pdVar5 + 1) = sel_screenFrame;
      *(HSDefaultWindowsLayoutManager **)((int)pdVar5 + 4) = self;
      *(float **)pdVar5 = local_54;
      *(undefined4 *)((int)pdVar5 + -4) = 0x246ef8;
      _objc_msgSend_stret(*(void **)pdVar5,*(id *)((int)pdVar5 + 4),*(SEL *)(pdVar5 + 1));
      pdVar5[1] = (double)local_54[0];
      *(cfstringStruct **)((int)pdVar5 + 4) = &cfstr___0f;
      *(undefined **)pdVar5 = sel_stringWithFormat_;
      *(undefined **)((int)pdVar5 + -4) = puVar1;
      *(undefined4 *)(pdVar5 + -1) = 0x246f22;
      pvVar3 = _objc_msgSend(*(id *)((int)pdVar5 + -4),*(SEL *)pdVar5);
      *(id *)(pdVar5 + 1) = pvVar3;
      *(undefined **)pdVar5 = sel_replaceObjectAtIndex_withObject_;
      *(id *)((int)pdVar5 + -4) = pvVar2;
      *(int *)((int)pdVar5 + 4) = 4;
      *(undefined4 *)(pdVar5 + -1) = 0x246f40;
      _objc_msgSend(*(id *)((int)pdVar5 + -4),*(SEL *)pdVar5);
      puVar1 = cls_NSString;
      *(undefined **)((int)pdVar5 + 4) = sel_screenFrame;
      *(HSDefaultWindowsLayoutManager **)pdVar5 = self;
      *(undefined1 **)((int)pdVar5 + -4) = local_44;
      *(undefined4 *)(pdVar5 + -1) = 0x246f62;
      _objc_msgSend_stret(*(void **)((int)pdVar5 + -4),*(id *)pdVar5,*(SEL *)((int)pdVar5 + 4));
      *(double *)((int)pdVar5 + 4) = (double)local_40;
      *(cfstringStruct **)pdVar5 = &cfstr___0f;
      *(undefined **)((int)pdVar5 + -4) = sel_stringWithFormat_;
      *(undefined **)(pdVar5 + -1) = puVar1;
      *(undefined4 *)((int)pdVar5 + -0xc) = 0x246f8c;
      pvVar3 = _objc_msgSend(*(id *)(pdVar5 + -1),*(SEL *)((int)pdVar5 + -4));
      *(id *)((int)pdVar5 + 4) = pvVar3;
      *(undefined **)((int)pdVar5 + -4) = sel_replaceObjectAtIndex_withObject_;
      *(id *)(pdVar5 + -1) = pvVar2;
      *(undefined4 *)pdVar5 = 5;
      *(undefined4 *)((int)pdVar5 + -0xc) = 0x246faa;
      _objc_msgSend(*(id *)(pdVar5 + -1),*(SEL *)((int)pdVar5 + -4));
      puVar1 = cls_NSString;
      *(undefined **)pdVar5 = sel_screenFrame;
      *(HSDefaultWindowsLayoutManager **)((int)pdVar5 + -4) = self;
      *(undefined1 **)(pdVar5 + -1) = local_34;
      *(undefined4 *)((int)pdVar5 + -0xc) = 0x246fcc;
      _objc_msgSend_stret(*(void **)(pdVar5 + -1),*(id *)((int)pdVar5 + -4),*(SEL *)pdVar5);
      *pdVar5 = (double)local_2c;
      *(cfstringStruct **)((int)pdVar5 + -4) = &cfstr___0f;
      *(undefined **)(pdVar5 + -1) = sel_stringWithFormat_;
      *(undefined **)((int)pdVar5 + -0xc) = puVar1;
      *(undefined4 *)(pdVar5 + -2) = 0x246ff6;
      pvVar3 = _objc_msgSend(*(id *)((int)pdVar5 + -0xc),*(SEL *)(pdVar5 + -1));
      *(id *)pdVar5 = pvVar3;
      *(undefined **)(pdVar5 + -1) = sel_replaceObjectAtIndex_withObject_;
      *(id *)((int)pdVar5 + -0xc) = pvVar2;
      *(int *)((int)pdVar5 + -4) = 6;
      *(undefined4 *)(pdVar5 + -2) = 0x247014;
      _objc_msgSend(*(id *)((int)pdVar5 + -0xc),*(SEL *)(pdVar5 + -1));
      puVar1 = cls_NSString;
      *(undefined **)((int)pdVar5 + -4) = sel_screenFrame;
      *(HSDefaultWindowsLayoutManager **)(pdVar5 + -1) = self;
      *(undefined1 **)((int)pdVar5 + -0xc) = local_24;
      *(undefined4 *)(pdVar5 + -2) = 0x247036;
      _objc_msgSend_stret(*(void **)((int)pdVar5 + -0xc),*(id *)(pdVar5 + -1),
                          *(SEL *)((int)pdVar5 + -4));
      pdVar4 = pdVar5 + -2;
      *(double *)((int)pdVar5 + -4) = (double)local_18;
      *(cfstringStruct **)(pdVar5 + -1) = &cfstr___0f;
      *(undefined **)((int)pdVar5 + -0xc) = sel_stringWithFormat_;
      *(undefined **)(pdVar5 + -2) = puVar1;
      *(undefined4 *)((int)pdVar5 + -0x14) = 0x247060;
      pvVar3 = _objc_msgSend(*(id *)(pdVar5 + -2),*(SEL *)((int)pdVar5 + -0xc));
      *(id *)((int)pdVar5 + -4) = pvVar3;
      *(undefined **)((int)pdVar5 + -0xc) = sel_replaceObjectAtIndex_withObject_;
      *(id *)(pdVar5 + -2) = pvVar2;
      *(int *)(pdVar5 + -1) = 7;
      *(undefined4 *)((int)pdVar5 + -0x14) = 0x24707e;
      _objc_msgSend(*(id *)(pdVar5 + -2),*(SEL *)((int)pdVar5 + -0xc));
    }
    *(undefined **)((int)pdVar4 + 4) = sel_nextObject;
    *(id *)pdVar4 = self_00;
    *(undefined4 *)((int)pdVar4 + -4) = 0x246c5f;
    pvVar2 = _objc_msgSend(*(id *)pdVar4,*(SEL *)((int)pdVar4 + 4));
  }
  return;
}

*/
- (void)applySmartLayoutCorrectionsToPalettes
{
    NSEnumerator *enumerator = [self palettesAutoSaveNamesEnumerator];
    float horizontalOffset = (float)[self resultLayoutHorizontalOffset];
    NSString *name;

    // Saved frames are "x y w h screenX screenY screenW screenH".
    while ((name = [enumerator nextObject]) != nil) {
        NSMutableArray *values = [[self pallettesFrameValuesDictionary] objectForKey:name];
        if ([values count] <= 7) {
            continue;
        }
        float y = [[values objectAtIndex:1] floatValue];
        float x = [[values objectAtIndex:0] floatValue];
        float width = [[values objectAtIndex:2] floatValue];
        NSSize offset = [self idealLayoutToScreenOffset];
        x += horizontalOffset;
        if ([self screenFrame].size.width < x + width) {
            x = [self screenFrame].size.width - width;
        }
        [values replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%.0f", (double)(x >= 0.0f ? x : 0.0f)]];
        y += offset.height;
        [values replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%.0f", (double)(y >= 0.0f ? y : 0.0f)]];
        [values replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%.0f", (double)[self screenFrame].origin.x]];
        [values replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%.0f", (double)[self screenFrame].origin.y]];
        [values replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%.0f", (double)[self screenFrame].size.width]];
        [values replaceObjectAtIndex:7 withObject:[NSString stringWithFormat:@"%.0f", (double)[self screenFrame].size.height]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024708e @ 0024708e, 409 bytes * /

void FUN_0024708e(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  float fVar3;
  double dVar4;
  HSDefaultWindowsLayoutManager *pHVar5;
  undefined8 in_stack_ffffffbc;
  undefined8 uVar6;
  float local_24 [2];
  float local_1c;
  
  uVar6 = CONCAT44((int)((ulonglong)in_stack_ffffffbc >> 0x20),sel_mainWindowFrame);
  pHVar5 = self;
  _objc_msgSend_stret(local_24,self,sel_mainWindowFrame);
  dVar4 = _objc_msgSend_fpret(self,sel_rightPalettesMinX);
  fVar3 = (local_24[0] + local_1c) - (float)dVar4;
  if ((0.0 < fVar3) &&
     (dVar4 = _objc_msgSend_fpret(self,sel_rightFreeVisibleScreenWidth), fVar3 < (float)dVar4)) {
    pvVar1 = _objc_msgSend(self,sel_rightPalettesFrameValues);
    self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0,uVar6);
      dVar4 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
      dVar4 = (double)((float)dVar4 + fVar3);
      pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr___0f,dVar4);
      uVar6 = CONCAT44((int)((ulonglong)dVar4 >> 0x20),pvVar2);
      pHVar5 = (HSDefaultWindowsLayoutManager *)0x0;
      _objc_msgSend(pvVar1,sel_replaceObjectAtIndex_withObject_,0);
      pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    }
    _objc_msgSend(self,sel_invalidateCachedValues,pHVar5,uVar6);
  }
  return;
}

*/
- (void)shiftRightPalettesToRespectMainWindowIfCan
{
    NSRect frame = [self mainWindowFrame];
    float shift = (float)(frame.origin.x + frame.size.width) - (float)[self rightPalettesMinX];
    if (shift > 0.0f && shift < (float)[self rightFreeVisibleScreenWidth]) {
        NSEnumerator *enumerator = [[self rightPalettesFrameValues] objectEnumerator];
        NSMutableArray *values;
        while ((values = [enumerator nextObject]) != nil) {
            [values replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%.0f", (double)([[values objectAtIndex:0] floatValue] + shift)]];
        }
        [self invalidateCachedValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247227 @ 00247227, 333 bytes * /

void FUN_00247227(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(self,sel_canOffsetLeftPalettes);
  if (((char)pvVar1 != '\0') ||
     (pvVar1 = _objc_msgSend(self,sel_canOffsetRightPalettes), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_leftPalettesFrameValues);
    self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0);
      dVar3 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
      pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr___0f,
                             (double)((float)dVar3 + -113.0));
      _objc_msgSend(pvVar1,sel_replaceObjectAtIndex_withObject_,0,pvVar2);
      pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    }
    _objc_msgSend(self,sel_invalidateCachedValues);
  }
  return;
}

*/
- (void)shiftLeftPalettesOnCardIndexWidthIfCan
{
    if ([self canOffsetLeftPalettes] || [self canOffsetRightPalettes]) {
        NSEnumerator *enumerator = [[self leftPalettesFrameValues] objectEnumerator];
        NSMutableArray *values;
        while ((values = [enumerator nextObject]) != nil) {
            [values replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%.0f", (double)([[values objectAtIndex:0] floatValue] - 113.0f)]];
        }
        [self invalidateCachedValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247374 @ 00247374, 222 bytes * /

float FUN_00247374(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  
  pvVar1 = _objc_msgSend(self,sel_shouldUseMainWindowCenteringHorizontalOffset);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_idealLayoutToScreenOffset);
    pvVar2 = _objc_msgSend(self,sel_canOffsetLeftPalettes);
    pvVar3 = _objc_msgSend(self,sel_canOffsetRightPalettes);
    pvVar4 = _objc_msgSend(self,sel_canCenterLayout);
    if (((char)pvVar4 != '\0') && ((char)pvVar3 != '\0' || (char)pvVar2 != '\0')) {
      dVar5 = _objc_msgSend_fpret(self,sel_cardIndexHalfOffset);
      pvVar1 = (id)((float)pvVar1 + (float)dVar5);
    }
  }
  else {
    dVar5 = _objc_msgSend_fpret(self,sel_mainWindowCenteringHorizontalOffset);
    pvVar1 = (id)(float)dVar5;
  }
  return (float)pvVar1;
}

*/
- (CGFloat)resultLayoutHorizontalOffset
{
    if ([self shouldUseMainWindowCenteringHorizontalOffset]) {
        return (float)[self mainWindowCenteringHorizontalOffset];
    }
    float offset = [self idealLayoutToScreenOffset].width;
    BOOL canOffsetLeft = [self canOffsetLeftPalettes];
    BOOL canOffsetRight = [self canOffsetRightPalettes];
    if ([self canCenterLayout] && (canOffsetRight || canOffsetLeft)) {
        offset += (float)[self cardIndexHalfOffset];
    }
    return offset;
}

- (BOOL)canCenterLayout
{
    BOOL bVar2;

    if (![self canOffsetLeftPalettes]) {
        bVar2 = (float)[self leftPalettesMinX] < (float)[self cardIndexHalfOffset];
    }
    else {
        if ([self canOffsetRightPalettes]) {
            return YES;
        }
        bVar2 = (float)[self rightFreeVisibleScreenWidth] < (float)[self cardIndexHalfOffset];
    }
    return !bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024750b @ 0024750b, 89 bytes * /

BOOL FUN_0024750b(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(self,sel_idealLayoutToScreenOffset);
  dVar2 = _objc_msgSend_fpret(self,sel_rightFreeVisibleScreenWidth);
  return 113.0 <= (float)pvVar1 + (float)dVar2;
}

*/
- (BOOL)canOffsetRightPalettes
{
    return 113.0f <= (float)[self idealLayoutToScreenOffset].width + (float)[self rightFreeVisibleScreenWidth];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247564 @ 00247564, 120 bytes * /

BOOL FUN_00247564(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(self,sel_idealLayoutToScreenOffset);
  if ((float)pvVar1 < 113.0) {
    pvVar1 = _objc_msgSend(self,sel_idealLayoutToScreenOffset);
    dVar2 = _objc_msgSend_fpret(self,sel_leftPalettesMinX);
    pvVar1 = (id)((float)pvVar1 + (float)dVar2);
  }
  return 113.0 <= (float)pvVar1;
}

*/
- (BOOL)canOffsetLeftPalettes
{
    float space = [self idealLayoutToScreenOffset].width;
    if (space < 113.0f) {
        space = [self idealLayoutToScreenOffset].width + (float)[self leftPalettesMinX];
    }
    return 113.0f <= space;
}

- (BOOL)shouldUseMainWindowCenteringHorizontalOffset
{
    float fVar1;
    BOOL bVar2;
    BOOL bVar3;
    float fVar4;
    double dVar5_3;

    fVar1 = (float)[self mainWindowCenteringHorizontalOffset];
    fVar4 = (float)[self leftPalettesMinX] + fVar1;
    if (fVar4 <= 0.0) {
        bVar3 = fVar4 == 0.0;
        bVar2 = fVar4 < 0.0;
    }
    else {
        dVar5_3 = [self rightFreeVisibleScreenWidth];
        bVar3 = (float)dVar5_3 == fVar1;
        bVar2 = (float)dVar5_3 < fVar1;
    }
    return !bVar2 && !bVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247663 @ 00247663, 237 bytes * /

float FUN_00247663(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  longdouble lVar2;
  float fVar3;
  double dVar4;
  undefined1 local_2c [8];
  float local_24;
  float local_1c [2];
  float local_14;
  
  _objc_msgSend_stret(local_2c,self,sel_screenFrame);
  _objc_msgSend_stret(local_1c,self,sel_mainWindowFrame);
  lVar2 = (longdouble)_roundf(local_24 * 0.5 - (local_14 * 0.5 + local_1c[0]));
  fVar3 = (float)lVar2;
  pvVar1 = _objc_msgSend(self,sel_isCardIndexOpened);
  if ((char)pvVar1 == '\0') {
    dVar4 = _objc_msgSend_fpret(self,sel_cardIndexHalfOffset);
    fVar3 = fVar3 - (float)dVar4;
  }
  return fVar3;
}

*/
- (CGFloat)mainWindowCenteringHorizontalOffset
{
    NSRect screen = [self screenFrame];
    NSRect frame = [self mainWindowFrame];
    float offset = roundf((float)(screen.size.width * 0.5 - (frame.size.width * 0.5 + frame.origin.x)));
    if (![self isCardIndexOpened]) {
        offset -= (float)[self cardIndexHalfOffset];
    }
    return offset;
}

- (void)setMainWindowFrame:(NSRect)aFrame
{
    (_mainWindowFrame).origin.x = aFrame.origin.x;
    (_mainWindowFrame).origin.y = aFrame.origin.y;
    (_mainWindowFrame).size.width = aFrame.size.width;
    (_mainWindowFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247750 @ 00247750, 197 bytes * /

NSRect * FUN_00247750(NSRect *__return_storage_ptr__,HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  NSRect *pNVar1;
  NSRect *extraout_EAX;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pNVar1 = (NSRect *)
           _NSEqualRects(*(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),
                         (self->_mainWindowFrame).origin,(self->_mainWindowFrame).size);
  if ((char)pNVar1 == '\0') {
    local_18 = (self->_mainWindowFrame).size.height;
    local_1c = (self->_mainWindowFrame).size.width;
    local_24 = (self->_mainWindowFrame).origin.x;
    local_20 = (self->_mainWindowFrame).origin.y;
  }
  else {
    _objc_msgSend_stret(&local_24,self,sel_defaultMainWindowFrame);
    (self->_mainWindowFrame).origin.x = local_24;
    (self->_mainWindowFrame).origin.y = local_20;
    (self->_mainWindowFrame).size.width = local_1c;
    (self->_mainWindowFrame).size.height = local_18;
    pNVar1 = extraout_EAX;
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = local_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = local_18;
  return pNVar1;
}

*/
- (NSRect)mainWindowFrame
{
    if (NSEqualRects(NSZeroRect, _mainWindowFrame)) {
        _mainWindowFrame = [self defaultMainWindowFrame];
    }
    return _mainWindowFrame;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247815 @ 00247815, 88 bytes * /

NSRect * FUN_00247815(NSRect *__return_storage_ptr__,HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  NSRect *pNVar2;
  
  pvVar1 = _objc_msgSend(self,sel_defaults);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSUntitledWindowFrame);
  pNVar2 = (NSRect *)_NSRectFromString(__return_storage_ptr__,pvVar1);
  return pNVar2;
}

*/
- (NSRect)defaultMainWindowFrame
{
    return NSRectFromString([[self defaults] objectForKey:@"HSUntitledWindowFrame"]);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024786d @ 0024786d, 101 bytes * /

float FUN_0024786d(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  double dVar1;
  undefined1 local_1c [8];
  float local_14;
  
  _objc_msgSend_stret(local_1c,self,sel_visibleScreenFrame);
  dVar1 = _objc_msgSend_fpret(self,sel_rightPalettesMaxX);
  return local_14 - (float)dVar1;
}

*/
- (CGFloat)rightFreeVisibleScreenWidth
{
    return (float)[self visibleScreenFrame].size.width - (float)[self rightPalettesMaxX];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002478d2 @ 002478d2, 293 bytes * /

float FUN_002478d2(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  float fVar2;
  double dVar3;
  double dVar4;
  undefined4 uVar5;
  
  fVar2 = self->_rightPalettesMaxX;
  if ((fVar2 == 0.0) && (!NAN(fVar2))) {
    pvVar1 = _objc_msgSend(self,sel_rightPalettesFrameValues);
    self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      self_01 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0);
      dVar3 = _objc_msgSend_fpret(self_01,sel_floatValue);
      uVar5 = 2;
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,2);
      dVar4 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
      fVar2 = (float)dVar3 + (float)dVar4;
      if (self->_rightPalettesMaxX <= fVar2 && fVar2 != self->_rightPalettesMaxX) {
        self->_rightPalettesMaxX = fVar2;
      }
      pvVar1 = _objc_msgSend(self_00,sel_nextObject,uVar5);
    }
    fVar2 = self->_rightPalettesMaxX;
  }
  return fVar2;
}

*/
- (CGFloat)rightPalettesMaxX
{
    if (_rightPalettesMaxX == 0.0f) {
        NSEnumerator *enumerator = [[self rightPalettesFrameValues] objectEnumerator];
        NSArray *values;
        while ((values = [enumerator nextObject]) != nil) {
            float maxX = [[values objectAtIndex:0] floatValue] + [[values objectAtIndex:2] floatValue];
            if (maxX > _rightPalettesMaxX) {
                _rightPalettesMaxX = maxX;
            }
        }
    }
    return _rightPalettesMaxX;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002479f7 @ 002479f7, 192 bytes * /

float FUN_002479f7(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  
  fVar1 = self->_rightPalettesMinX;
  if ((fVar1 == 3.4028235e+38) && (!NAN(fVar1))) {
    pvVar2 = _objc_msgSend(self,sel_rightPalettesFrameValues);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    while (pvVar3 = _objc_msgSend(pvVar2,sel_nextObject), pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
      dVar4 = _objc_msgSend_fpret(pvVar3,sel_floatValue);
      if ((float)dVar4 < self->_rightPalettesMinX) {
        self->_rightPalettesMinX = (float)dVar4;
      }
    }
    fVar1 = self->_rightPalettesMinX;
  }
  return fVar1;
}

*/
- (CGFloat)rightPalettesMinX
{
    if (_rightPalettesMinX == FLT_MAX) {
        NSEnumerator *enumerator = [[self rightPalettesFrameValues] objectEnumerator];
        NSArray *values;
        while ((values = [enumerator nextObject]) != nil) {
            float minX = [[values objectAtIndex:0] floatValue];
            if (minX < _rightPalettesMinX) {
                _rightPalettesMinX = minX;
            }
        }
    }
    return _rightPalettesMinX;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247ab7 @ 00247ab7, 192 bytes * /

float FUN_00247ab7(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  
  fVar1 = self->_leftPalettesMinX;
  if ((fVar1 == 3.4028235e+38) && (!NAN(fVar1))) {
    pvVar2 = _objc_msgSend(self,sel_leftPalettesFrameValues);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    while (pvVar3 = _objc_msgSend(pvVar2,sel_nextObject), pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
      dVar4 = _objc_msgSend_fpret(pvVar3,sel_floatValue);
      if ((float)dVar4 < self->_leftPalettesMinX) {
        self->_leftPalettesMinX = (float)dVar4;
      }
    }
    fVar1 = self->_leftPalettesMinX;
  }
  return fVar1;
}

*/
- (CGFloat)leftPalettesMinX
{
    if (_leftPalettesMinX == FLT_MAX) {
        NSEnumerator *enumerator = [[self leftPalettesFrameValues] objectEnumerator];
        NSArray *values;
        while ((values = [enumerator nextObject]) != nil) {
            float minX = [[values objectAtIndex:0] floatValue];
            if (minX < _leftPalettesMinX) {
                _leftPalettesMinX = minX;
            }
        }
    }
    return _leftPalettesMinX;
}

- (void)invalidateCachedValues
{
    _leftPalettesMinX = 3.4028235e+38;
    _rightPalettesMaxX = 0.0;
    _rightPalettesMinX = 3.4028235e+38;
}

- (id)rightPalettesFrameValues
{
    id pvVar1;

    pvVar1 = _rightPalettesFrameValues;
    if (pvVar1 == nil) {
        [self dividePaletteFrameValuesToLeftAndRightRelativeToIdealLayoutCenter];
        pvVar1 = _rightPalettesFrameValues;
    }
    return pvVar1;
}

- (id)leftPalettesFrameValues
{
    id pvVar1;

    pvVar1 = _leftPalettesFrameValues;
    if (pvVar1 == nil) {
        [self dividePaletteFrameValuesToLeftAndRightRelativeToIdealLayoutCenter];
        pvVar1 = _leftPalettesFrameValues;
    }
    return pvVar1;
}

- (void)dividePaletteFrameValuesToLeftAndRightRelativeToIdealLayoutCenter
{
    id pvVar3;
    id *ppvVar4;
    double dVar5;
    double dVar6;
    id pvVar1_3;
    NSEnumerator *pvVar2_2;
    id pvVar3_2;

    [_leftPalettesFrameValues release];
    _leftPalettesFrameValues = [NSMutableArray new];
    [_rightPalettesFrameValues release];
    _rightPalettesFrameValues = [NSMutableArray new];
    dVar5 = [self idealLayoutHalfWidth];
    pvVar1_3 = [self pallettesFrameValuesDictionary];
    pvVar2_2 = [[pvVar1_3 allKeys] objectEnumerator];
    pvVar3 = [pvVar2_2 nextObject];
    if (pvVar3 != nil) {
        do {
            pvVar3_2 = [pvVar1_3 objectForKey:pvVar3];
            dVar6 = [[pvVar3_2 objectAtIndex:0] floatValue];
            ppvVar4 = &_rightPalettesFrameValues;
            if ((float)dVar6 < (float)dVar5) {
                ppvVar4 = &_leftPalettesFrameValues;
            }
            [*ppvVar4 addObject:pvVar3_2];
            pvVar3 = [pvVar2_2 nextObject];
        } while (pvVar3 != nil);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247d69 @ 00247d69, 295 bytes * /

id FUN_00247d69(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  
  pvVar1 = self->_pallettesFrameValuesDictionary;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_pallettesFrameValuesDictionary = pvVar1;
    self_00 = _objc_msgSend(self,sel_palettesAutoSaveNamesEnumerator);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self->_defaults,sel_valueForKey_,pvVar1);
      pvVar2 = _objc_msgSend(pvVar2,sel_componentsSeparatedByString_,&cfstr__);
      pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy);
      pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
      _objc_msgSend(self->_pallettesFrameValuesDictionary,sel_setObject_forKey_,pvVar2,pvVar1);
      pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    }
    pvVar1 = self->_pallettesFrameValuesDictionary;
  }
  return pvVar1;
}

*/
- (id)pallettesFrameValuesDictionary
{
    if (_pallettesFrameValuesDictionary == nil) {
        _pallettesFrameValuesDictionary = [[NSMutableDictionary dictionary] retain];
        NSEnumerator *enumerator = [self palettesAutoSaveNamesEnumerator];
        NSString *name;
        while ((name = [enumerator nextObject]) != nil) {
            [_pallettesFrameValuesDictionary setObject:[[[[_defaults valueForKey:name] componentsSeparatedByString:@" "] mutableCopy] autorelease] forKey:name];
        }
    }
    return _pallettesFrameValuesDictionary;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247e90 @ 00247e90, 62 bytes * /

float FUN_00247e90(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  id pvVar1;
  longdouble lVar2;
  
  pvVar1 = _objc_msgSend(self,sel_idealLayoutSize);
  lVar2 = (longdouble)_roundf((float)pvVar1 * 0.5);
  return (float)lVar2;
}

*/
- (CGFloat)idealLayoutHalfWidth
{
    return roundf((float)[self idealLayoutSize].width * 0.5f);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247ece @ 00247ece, 302 bytes * /

ulonglong FUN_00247ece(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  float extraout_EDX;
  float local_3c;
  float local_38;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [8];
  float local_1c;
  
  cVar1 = _NSEqualSizes((self->_idealLayoutToScreenOffset).width,
                        (self->_idealLayoutToScreenOffset).height,*(undefined4 *)PTR_0033607c,
                        *(undefined4 *)(PTR_0033607c + 4));
  if (cVar1 == '\0') {
    local_38 = (self->_idealLayoutToScreenOffset).width;
    local_3c = (self->_idealLayoutToScreenOffset).height;
  }
  else {
    _objc_msgSend_stret(local_34,self,sel_screenFrame);
    _objc_msgSend(self,sel_idealLayoutSize);
    _objc_msgSend_stret(local_24,self,sel_screenFrame);
    pvVar2 = _objc_msgSend(self,sel_idealLayoutSize);
    local_38 = (local_1c - (float)pvVar2) * 0.5;
    (self->_idealLayoutToScreenOffset).width = local_38;
    local_3c = (local_28 - extraout_EDX) * 0.5;
    (self->_idealLayoutToScreenOffset).height = local_3c;
  }
  return CONCAT44(local_3c,local_38);
}

*/
- (NSSize)idealLayoutToScreenOffset
{
    if (NSEqualSizes(_idealLayoutToScreenOffset, NSZeroSize)) {
        _idealLayoutToScreenOffset.width = ([self screenFrame].size.width - [self idealLayoutSize].width) * 0.5;
        _idealLayoutToScreenOffset.height = ([self screenFrame].size.height - [self idealLayoutSize].height) * 0.5;
    }
    return _idealLayoutToScreenOffset;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00247ffc @ 00247ffc, 199 bytes * /

ulonglong FUN_00247ffc(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  char cVar1;
  ulonglong uVar2;
  undefined1 local_2c [8];
  float local_24;
  undefined1 local_1c [12];
  float local_10;
  
  cVar1 = _NSEqualSizes((self->_idealLayoutSize).width,(self->_idealLayoutSize).height,
                        *(undefined4 *)PTR_0033607c,*(undefined4 *)(PTR_0033607c + 4));
  if (cVar1 != '\0') {
    (self->_idealLayoutSize).width = 1024.0;
    (self->_idealLayoutSize).height = 768.0;
    _objc_msgSend_stret(local_2c,self,sel_screenFrame);
    if (1440.0 <= local_24) {
      _objc_msgSend_stret(local_1c,self,sel_screenFrame);
      if (900.0 <= local_10) {
        (self->_idealLayoutSize).width = 1440.0;
        (self->_idealLayoutSize).height = 900.0;
      }
    }
  }
  uVar2._0_4_ = (self->_idealLayoutSize).width;
  uVar2._4_4_ = (self->_idealLayoutSize).height;
  return uVar2;
}

*/
- (NSSize)idealLayoutSize
{
    if (NSEqualSizes(_idealLayoutSize, NSZeroSize)) {
        _idealLayoutSize = NSMakeSize(1024.0, 768.0);
        if ([self screenFrame].size.width >= 1440.0 && [self screenFrame].size.height >= 900.0) {
            _idealLayoutSize = NSMakeSize(1440.0, 900.0);
        }
    }
    return _idealLayoutSize;
}

- (void)mergeDefaultsWithResolutionDependentDefaults
{
    id pvVar1;
    id self_00;

    pvVar1 = [self resolutionDependentDefaults];
    if (pvVar1 != nil) {
        self_00 = [NSMutableDictionary dictionary];
        [self_00 addEntriesFromDictionary:pvVar1];
        [self_00 addEntriesFromDictionary:_defaults];
        [_defaults release];
        _defaults = [self_00 retain];
    }
}

- (id)resolutionDependentDefaults
{
    return [_defaults objectForKey:[self keyForResolutionDependentDefaults]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002481ae @ 002481ae, 126 bytes * /

id FUN_002481ae(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  undefined *puVar1;
  undefined1 local_34 [8];
  float local_2c;
  undefined1 local_24 [12];
  float local_18;
  
  puVar1 = PTR_cfstr_HSWindowsLayout1024x768_00342698;
  _objc_msgSend_stret(local_34,self,sel_screenFrame);
  if ((1440.0 <= local_2c) &&
     (_objc_msgSend_stret(local_24,self,sel_screenFrame), 900.0 <= local_18)) {
    puVar1 = PTR_cfstr_HSWindowsLayout1440x900_00342694;
  }
  return puVar1;
}

*/
- (id)keyForResolutionDependentDefaults
{
    if ([self screenFrame].size.width >= 1440.0 && [self screenFrame].size.height >= 900.0) {
        return @"HSWindowsLayout1440x900";
    }
    return @"HSWindowsLayout1024x768";
}

- (BOOL)isCardIndexOpened
{
    return (BOOL)[HSUI isCardIndexOpenedInApplicationDefaults:[self defaults]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00248275 @ 00248275, 23 bytes * /

float FUN_00248275(HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  longdouble lVar1;
  
  lVar1 = (longdouble)_roundf(0x42620000);
  return (float)lVar1;
}

*/
- (CGFloat)cardIndexHalfOffset
{
    return roundf(56.5f);
}

- (id)palettesAutoSaveNamesEnumerator
{
    return [[NSArray arrayWithObjects:@"NSWindow Frame HSLibraryPanelFramePosition", @"NSWindow Frame HSObjectListPaletteControllerFrame", @"NSWindow Frame HSToolPaletteControllerFrame", @"NSWindow Frame HSObjectAssistantWindow", @"NSWindow Frame HSLayoutPaletteControllerFrame", @"NSWindow Frame NSColorPanel", nil] objectEnumerator];
}

- (void)setVisibleScreenFrame:(NSRect)aFrame
{
    (_visibleScreenFrame).origin.x = aFrame.origin.x;
    (_visibleScreenFrame).origin.y = aFrame.origin.y;
    (_visibleScreenFrame).size.width = aFrame.size.width;
    (_visibleScreenFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024830d @ 0024830d, 221 bytes * /

NSRect * FUN_0024830d(NSRect *__return_storage_ptr__,HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  NSRect *pNVar1;
  id self_00;
  NSRect *extraout_EAX;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pNVar1 = (NSRect *)
           _NSEqualRects((self->_visibleScreenFrame).origin,(self->_visibleScreenFrame).size,
                         *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8));
  if ((char)pNVar1 == '\0') {
    local_18 = (self->_visibleScreenFrame).size.height;
    local_1c = (self->_visibleScreenFrame).size.width;
    local_24 = (self->_visibleScreenFrame).origin.x;
    local_20 = (self->_visibleScreenFrame).origin.y;
  }
  else {
    self_00 = _objc_msgSend(cls_NSScreen,sel_mainScreen);
    _objc_msgSend_stret(&local_24,self_00,sel_visibleFrame);
    (self->_visibleScreenFrame).origin.x = local_24;
    (self->_visibleScreenFrame).origin.y = local_20;
    (self->_visibleScreenFrame).size.width = local_1c;
    (self->_visibleScreenFrame).size.height = local_18;
    pNVar1 = extraout_EAX;
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = local_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = local_18;
  return pNVar1;
}

*/
- (NSRect)visibleScreenFrame
{
    if (NSEqualRects(_visibleScreenFrame, NSZeroRect)) {
        _visibleScreenFrame = [[NSScreen mainScreen] visibleFrame];
    }
    return _visibleScreenFrame;
}

- (void)setScreenFrame:(NSRect)aFrame
{
    (_screenFrame).origin.x = aFrame.origin.x;
    (_screenFrame).origin.y = aFrame.origin.y;
    (_screenFrame).size.width = aFrame.size.width;
    (_screenFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002483ea @ 002483ea, 221 bytes * /

NSRect * FUN_002483ea(NSRect *__return_storage_ptr__,HSDefaultWindowsLayoutManager *self,SEL _cmd)

{
  NSRect *pNVar1;
  id self_00;
  NSRect *extraout_EAX;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pNVar1 = (NSRect *)
           _NSEqualRects((self->_screenFrame).origin,(self->_screenFrame).size,
                         *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8));
  if ((char)pNVar1 == '\0') {
    local_18 = (self->_screenFrame).size.height;
    local_1c = (self->_screenFrame).size.width;
    local_24 = (self->_screenFrame).origin.x;
    local_20 = (self->_screenFrame).origin.y;
  }
  else {
    self_00 = _objc_msgSend(cls_NSScreen,sel_mainScreen);
    _objc_msgSend_stret(&local_24,self_00,sel_frame);
    (self->_screenFrame).origin.x = local_24;
    (self->_screenFrame).origin.y = local_20;
    (self->_screenFrame).size.width = local_1c;
    (self->_screenFrame).size.height = local_18;
    pNVar1 = extraout_EAX;
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = local_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = local_18;
  return pNVar1;
}

*/
- (NSRect)screenFrame
{
    if (NSEqualRects(_screenFrame, NSZeroRect)) {
        _screenFrame = [[NSScreen mainScreen] frame];
    }
    return _screenFrame;
}

- (void)dealloc
{
    [_defaults release];
    [_pallettesFrameValuesDictionary release];
    [_leftPalettesFrameValues release];
    [_rightPalettesFrameValues release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024660c @ 0024660c, 133 bytes * /

id FUN_0024660c(HSDefaultWindowsLayoutManager *self,SEL _cmd,id initWithDefaults)

{
  id pvVar1;
  id pvVar2;
  HSDefaultWindowsLayoutManager *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_00355b20;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithDictionary_,initWithDefaults);
    *(id *)((int)pvVar1 + 4) = pvVar2;
    *(undefined4 *)((int)pvVar1 + 0x38) = 0x7f7fffff;
    *(undefined4 *)((int)pvVar1 + 0x3c) = 0x7f7fffff;
  }
  return pvVar1;
}

*/
- (id)initWithDefaults:(id)aDefaults
{
    self = [super init];
    if (self != nil) {
        _defaults = [[NSMutableDictionary alloc] initWithDictionary:aDefaults];
        _leftPalettesMinX = FLT_MAX;
        _rightPalettesMinX = FLT_MAX;
    }
    return self;
}

@end

