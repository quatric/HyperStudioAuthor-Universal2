// Plain C functions of the original binary, still to translate.
#import "HyperStudioPrefix.h"

// The C runtime start-up (crt1) and the QuickTime Flash enabler (QFlash*,
// for QuickTime 7's Flash track) are gone; main registers the media
// library's content filters before the application starts.
int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    Class libraryManager = NSClassFromString(@"HSLibraryManager");
    Class contentFilter = NSClassFromString(@"HSLibraryContentFilter");
    [[libraryManager sharedLibraryManager] registerMediaContentFilter:[contentFilter sharedContentFilter]];
    contentFilter = NSClassFromString(@"HSLibraryMoviesContentFilter");
    [[libraryManager sharedLibraryManager] registerMoviesContentFilter:[contentFilter sharedContentFilter]];
    contentFilter = NSClassFromString(@"HSLibrarySoundsContentFilter");
    [[libraryManager sharedLibraryManager] registerSoundsContentFilter:[contentFilter sharedContentFilter]];
    [pool release];
    return NSApplicationMain(argc, argv);
}

// Layout rule helpers shared by HSLayoutSimpleRule and
// HSLayoutGridCornerAlignmentRule. Side numbers: 0 left, 1 bottom, 2 right,
// 3 top, 4 horizontal centre, 5 vertical centre.
NSRect HSLayoutRuleTranslateRect(id aRule, NSRect aRect)
{
    CGFloat x = aRect.origin.x;
    CGFloat y = aRect.origin.y;
    if ([aRule affectsRectSide:0])
        x = [aRule layoutRuleFloatValueForRectSide:0];
    else if ([aRule affectsRectSide:2])
        x = [aRule layoutRuleFloatValueForRectSide:2] - aRect.size.width;
    else if ([aRule affectsRectSide:4])
        x += [aRule layoutRuleFloatValueForRectSide:4] - (aRect.size.width * 0.5 + aRect.origin.x);
    if ([aRule affectsRectSide:1])
        y = [aRule layoutRuleFloatValueForRectSide:1];
    else if ([aRule affectsRectSide:3])
        y = [aRule layoutRuleFloatValueForRectSide:3] - aRect.size.height;
    else if ([aRule affectsRectSide:5])
        y += [aRule layoutRuleFloatValueForRectSide:5] - (aRect.size.height * 0.5 + aRect.origin.y);
    return NSMakeRect(x, y, aRect.size.width, aRect.size.height);
}

NSUInteger HSLayoutRuleHash(id aRule)
{
    if ([aRule affectedRectSidesCount] == 0)
        return 0;
    NSInteger side = [aRule affectedRectSideAtIndex:0];
    float value = [aRule layoutRuleFloatValueForRectSide:side];
    return (unsigned int)(((unsigned int)side << 24) | (unsigned int)value);
}

BOOL HSLayoutRuleIsEqual(id aRule, id anotherRule)
{
    if ([aRule appliesToXAxis] != [anotherRule appliesToXAxis])
        return NO;
    if ([aRule appliesToYAxis] != [anotherRule appliesToYAxis])
        return NO;
    if ([aRule affectedRectSidesCount] != [anotherRule affectedRectSidesCount])
        return NO;
    BOOL equal = YES;
    for (NSUInteger side = 0; side < 8; side++) {
        if ([aRule affectsRectSide:side] != [anotherRule affectsRectSide:side])
            return NO;
        if ([aRule affectsRectSide:side]) {
            float other = [anotherRule layoutRuleFloatValueForRectSide:side];
            float mine = [aRule layoutRuleFloatValueForRectSide:side];
            float a = mine != 0.0f ? fabsf(mine) : 1.0f;
            float b = other != 0.0f ? fabsf(other) : 1.0f;
            if (b <= a)
                b = a;
            equal = fabsf(mine - other) <= b * 0.0005f;
        }
        if (!equal)
            return NO;
    }
    return equal;
}

#if 0
/* --- i386 decompilation (Ghidra) ---
/* FUN_00030774 @ 00030774, 159 bytes * /

void FUN_00030774(id param_1,id param_2)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(param_1,sel_queryHyperInterface_,&DAT_003627f8);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperTitle);
  pvVar2 = _objc_msgSend(param_2,sel_queryHyperInterface_,&DAT_003627f8);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperTitle);
  uVar3 = _CFStringGetLength(pvVar1);
  _CFStringCompareWithOptions(pvVar1,pvVar2,0,uVar3,0x71);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003244b @ 0003244b, 65 bytes * /

void FUN_0003244b(int param_1,undefined4 param_2)

{
  _objc_msgSend(*(id *)(param_1 + 0x18),sel_saveAsReadyMadeCardPanelDidEnd_returnCode_contextInfo_,
                *(undefined4 *)(param_1 + 0x14),param_2,0);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003248c @ 0003248c, 73 bytes * /

void FUN_0003248c(int param_1,int param_2)

{
  __Block_object_assign((void *)(param_1 + 0x14),*(void **)(param_2 + 0x14),3);
  __Block_object_assign((void *)(param_1 + 0x18),*(void **)(param_2 + 0x18),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000324d5 @ 000324d5, 54 bytes * /

void FUN_000324d5(int param_1)

{
  __Block_object_dispose(*(void **)(param_1 + 0x14),3);
  __Block_object_dispose(*(void **)(param_1 + 0x18),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000332ff @ 000332ff, 86 bytes * /

void FUN_000332ff(int param_1,undefined4 param_2)

{
  id self;
  undefined4 uVar1;
  id pvVar2;
  
  self = *(id *)(param_1 + 0x1c);
  uVar1 = *(undefined4 *)(param_1 + 0x18);
  pvVar2 = _objc_msgSend(*(id *)(param_1 + 0x14),sel_retain);
  _objc_msgSend(self,sel_findReadyMadeCardPanelDidEnd_returnCode_contextInfo_,uVar1,param_2,pvVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00033355 @ 00033355, 99 bytes * /

void FUN_00033355(int param_1,int param_2)

{
  __Block_object_assign((void *)(param_1 + 0x14),*(void **)(param_2 + 0x14),3);
  __Block_object_assign((void *)(param_1 + 0x18),*(void **)(param_2 + 0x18),3);
  __Block_object_assign((void *)(param_1 + 0x1c),*(void **)(param_2 + 0x1c),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000333b8 @ 000333b8, 73 bytes * /

void FUN_000333b8(int param_1)

{
  __Block_object_dispose(*(void **)(param_1 + 0x14),3);
  __Block_object_dispose(*(void **)(param_1 + 0x18),3);
  __Block_object_dispose(*(void **)(param_1 + 0x1c),3);
  return;
}

*/


/* --- i386 decompilation (Ghidra) ---
/* FUN_00046ce2 @ 00046ce2, 232 bytes * /

void FUN_00046ce2(void)

{
  id self;
  id pvVar1;
  id self_00;
  id in_ECX;
  id in_EDX;
  int iVar2;
  
  self = _objc_msgSend(in_ECX,sel_objectEnumerator);
  while (self_00 = _objc_msgSend(self,sel_nextObject), self_00 != (id)0x0) {
    iVar2 = 0;
    do {
      pvVar1 = _objc_msgSend(self_00,sel_affectsRectSide_,iVar2);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(in_EDX,sel_objectAtIndex_,iVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObjectIdenticalTo_,self_00);
        if (pvVar1 == (id)0x7fffffff) {
          pvVar1 = _objc_msgSend(in_EDX,sel_objectAtIndex_,iVar2);
          _objc_msgSend(pvVar1,sel_addObject_,self_00);
        }
      }
      iVar2 = iVar2 + 1;
    } while (iVar2 != 8);
  }
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00046dca @ 00046dca, 186 bytes * /

void FUN_00046dca(id param_1)

{
  id pvVar1;
  int iVar2;
  id self;
  int in_ECX;
  id in_EDX;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(param_1,sel_count);
  _objc_msgSend(in_EDX,sel_removeAllObjects);
  if (pvVar1 != (id)0x0) {
    pvVar3 = (id)0x0;
    do {
      if ((pvVar3 < (id)0x7) && ((0x55U >> ((uint)pvVar3 & 0x1f) & 1) != 0)) {
        iVar2 = 0;
      }
      else {
        iVar2 = 1;
      }
      if (iVar2 == in_ECX) {
        self = _objc_msgSend(param_1,sel_objectAtIndex_,pvVar3);
        _objc_msgSend(in_EDX,sel_addObjectsFromArray_,self);
        _objc_msgSend(self,sel_removeAllObjects);
      }
      pvVar3 = (id)((int)pvVar3 + 1);
    } while (pvVar3 < pvVar1);
  }
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00047122 @ 00047122, 601 bytes * /

uint FUN_00047122(id param_1,id param_2,int param_3)

{
  float local_a4;
  float local_a0;
  undefined1 local_9c [16];
  undefined8 local_8c;
  undefined4 local_84;
  undefined4 local_80;
  undefined4 local_7c;
  undefined4 local_78;
  undefined4 local_74;
  undefined4 uStack_70;
  undefined4 local_6c;
  undefined4 uStack_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  undefined1 local_54 [24];
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  _objc_msgSend_stret(local_9c,param_1,sel_hyperLayoutInfluencingTransform);
  _objc_msgSend_stret(&local_84,param_1,sel_hyperLayoutInfluencingBoundingRect);
  local_74 = local_84;
  uStack_70 = local_80;
  local_6c = local_7c;
  uStack_68 = local_78;
  _CGRectApplyAffineTransform
            (&local_64,local_84,local_80,local_7c,local_78,(int)local_9c._0_8_,
             SUB84(local_9c._0_8_,4),(int)local_9c._8_8_,SUB84(local_9c._8_8_,4),local_8c);
  local_a4 = local_64;
  _objc_msgSend_stret(local_54,param_2,sel_hyperLayoutInfluencingTransform);
  _objc_msgSend_stret(&local_3c,param_2,sel_hyperLayoutInfluencingBoundingRect);
  local_2c = local_3c;
  uStack_28 = local_38;
  local_24 = local_34;
  uStack_20 = local_30;
  _CGRectApplyAffineTransform
            (&local_1c,CONCAT44(local_38,local_3c),local_34,local_30,(int)local_54._0_8_,
             SUB84(local_54._0_8_,4),(int)local_54._8_8_,SUB84(local_54._8_8_,4),
             (int)local_54._16_8_,SUB84(local_54._16_8_,4));
  if (param_3 == 0) {
    local_a0 = local_58 + local_60;
    local_a4 = local_60;
    local_14 = local_18 + local_10;
    local_1c = local_18;
  }
  else {
    local_a0 = local_5c + local_64;
    local_14 = local_1c + local_14;
  }
  if (local_1c <= local_a4) {
    if (local_1c < local_a4) {
      return 1;
    }
    if (local_14 <= local_a0) {
      return (uint)(local_14 < local_a0);
    }
  }
  return 0xffffffff;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00051545 @ 00051545, 100 bytes * /

bool FUN_00051545(void)

{
  float in_XMM0_Da;
  float in_XMM1_Da;
  float fVar1;
  float fVar2;
  
  if ((in_XMM0_Da != 0.0) || (NAN(in_XMM0_Da))) {
    fVar1 = ABS(in_XMM0_Da);
  }
  else {
    fVar1 = 1.0;
  }
  if ((in_XMM1_Da != 0.0) || (NAN(in_XMM1_Da))) {
    fVar2 = ABS(in_XMM1_Da);
  }
  else {
    fVar2 = 1.0;
  }
  if (fVar2 <= fVar1) {
    fVar2 = fVar1;
  }
  return in_XMM1_Da + fVar2 * -0.0005 <= in_XMM0_Da;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005cdf5 @ 0005cdf5, 896 bytes * /

id FUN_0005cdf5(void)

{
  undefined *self;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *in_ECX;
  undefined4 *in_EDX;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar4;
  undefined4 in_XMM0_Da;
  double dVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  
  if (DAT_003427e4 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSTextStorage,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_,&cfstr__);
    self = cls_NSFont;
    DAT_003427e8 = pvVar1;
    dVar5 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
    pvVar2 = _objc_msgSend(self,sel_boldSystemFontOfSize_,(float)dVar5 + -2.0);
    _objc_msgSend(pvVar1,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336068,pvVar2,0,1);
    _objc_msgSend(DAT_003427e8,sel_setAlignment_range_,2,0,1);
    DAT_003427e4 = _objc_msgSend(cls_NSLayoutManager,sel_new);
    pvVar1 = _objc_msgSend(cls_NSTextContainer,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithContainerSize_,0x461c4000,0x461c4000);
    _objc_msgSend(pvVar1,sel_setHeightTracksTextView_,1);
    _objc_msgSend(pvVar1,sel_setWidthTracksTextView_,0);
    _objc_msgSend(pvVar1,sel_setLineFragmentPadding_,0x40000000);
    _objc_msgSend(DAT_003427e4,sel_addTextContainer_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
    _objc_msgSend(DAT_003427e8,sel_addLayoutManager_,DAT_003427e4);
    _objc_msgSend(DAT_003427e4,sel_release);
  }
  DAT_003427e8 = _objc_msgSend(DAT_003427e4,sel_textStorage);
  pvVar1 = _objc_msgSend(DAT_003427e4,sel_textContainers);
  uVar6 = 0;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0);
  pvVar2 = _objc_msgSend(DAT_003427e8,sel_length);
  pvVar3 = _objc_msgSend(in_ECX,sel_length);
  pcVar4 = &cfstr__;
  if (pvVar3 != (id)0x0) {
    pcVar4 = in_ECX;
  }
  pvVar3 = _objc_msgSend(DAT_003427e8,sel_string,uVar6);
  pcVar7 = pcVar4;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pcVar4);
  if ((char)pvVar3 == '\0') {
    pcVar7 = (cfstringStruct *)0x0;
    _objc_msgSend(DAT_003427e8,sel_replaceCharactersInRange_withString_,0,pvVar2,pcVar4);
  }
  pvVar2 = _objc_msgSend(DAT_003427e8,sel_length,pcVar7);
  pvVar2 = _objc_msgSend(DAT_003427e4,sel_glyphRangeForCharacterRange_actualCharacterRange_,0,pvVar2
                         ,0);
  *in_EDX = pvVar2;
  in_EDX[1] = extraout_EDX;
  _objc_msgSend(pvVar1,sel_setContainerSize_,in_XMM0_Da,0x461c4000);
  return DAT_003427e4;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005d175 @ 0005d175, 359 bytes * /

void FUN_0005d175(undefined4 param_1,undefined4 param_2,undefined4 param_3,undefined4 param_4,
                 byte param_5)

{
  undefined *puVar1;
  id self;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  uint in_EDX;
  SEL op;
  
  self = (id)FUN_0005cdf5();
  self_00 = _objc_msgSend(self,sel_textStorage);
  pvVar2 = _objc_msgSend(self_00,sel_length);
  puVar1 = PTR_00336394;
  pvVar3 = _objc_msgSend(self_00,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)PTR_00336394,0
                         ,0);
  pvVar4 = _objc_msgSend(cls_HSMediaStripView,sel_textColorSelected_firstResponder_,in_EDX & 0xff,
                         (uint)param_5);
  if (pvVar4 != pvVar3) {
    if (pvVar4 == (id)0x0) {
      pvVar4 = (id)0x0;
      op = sel_removeAttribute_range_;
    }
    else {
      pvVar2 = (id)0x0;
      op = sel_addAttribute_value_range_;
    }
    _objc_msgSend(self_00,op,*(undefined4 *)puVar1,pvVar4,pvVar2);
  }
  _objc_msgSend(self,sel_drawGlyphsForGlyphRange_atPoint_,0,0,param_1,param_2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000927b9 @ 000927b9, 139 bytes * /

undefined8
FUN_000927b9(undefined4 param_1,undefined4 param_2,undefined4 param_3,undefined4 param_4,
            undefined4 param_5,undefined4 param_6,undefined4 param_7,undefined4 param_8)

{
  uint in_ECX;
  undefined4 uVar1;
  undefined4 uVar2;
  
  uVar1 = *(undefined4 *)PTR_00336074;
  uVar2 = *(undefined4 *)(PTR_00336074 + 4);
  if (in_ECX < 4) {
    switch(in_ECX) {
    case 0:
      goto switchD_000927ec_caseD_0;
    case 1:
      goto switchD_000927ec_caseD_1;
    case 2:
      goto switchD_000927ec_caseD_2;
    case 3:
      goto switchD_000927ec_caseD_3;
    default:
      goto switchD_000927ec_default;
    }
  }
  switch(in_ECX) {
  case 1:
switchD_000927ec_caseD_1:
    uVar1 = param_3;
    uVar2 = param_4;
    break;
  case 2:
switchD_000927ec_caseD_2:
    uVar1 = param_5;
    uVar2 = param_6;
    break;
  case 4:
  case 0:
switchD_000927ec_caseD_0:
    uVar1 = param_1;
    uVar2 = param_2;
    break;
  case 0xffffffff:
  case 3:
switchD_000927ec_caseD_3:
    uVar1 = param_7;
    uVar2 = param_8;
    break;
  default:
    break;
  }
switchD_000927ec_default:
  return CONCAT44(uVar2,uVar1);
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009286c @ 0009286c, 202 bytes * /

int FUN_0009286c(undefined4 *param_1)

{
  char cVar1;
  uint in_ECX;
  uint in_EDX;
  
  if (param_1 != (undefined4 *)0x0) {
    if (3 < in_ECX) {
      if (in_ECX == 4) {
        in_ECX = 0;
      }
      else if (in_ECX == 0xffffffff) {
        in_ECX = 3;
      }
    }
    if (3 < in_EDX) {
      if (in_EDX == 4) {
        in_EDX = 0;
      }
      else if (in_EDX == 0xffffffff) {
        in_EDX = 3;
      }
    }
    if (in_EDX < in_ECX) {
      cVar1 = FUN_0009286c(param_1);
      return (int)cVar1;
    }
    if (in_ECX < in_EDX) {
      if (in_ECX + 1 == in_EDX) {
        if (in_ECX == 0) {
          *param_1 = 0;
        }
        else if (in_ECX == 2) {
          *param_1 = 2;
        }
        else {
          if (in_ECX != 1) {
            return 0;
          }
          *param_1 = 3;
        }
      }
      else {
        if (in_ECX != 0) {
          return 0;
        }
        if (in_EDX != 3) {
          return 0;
        }
        *param_1 = 1;
      }
      return 1;
    }
  }
  return 0;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000946ba @ 000946ba, 233 bytes * /

void FUN_000946ba(void)

{
  undefined4 *in_ECX;
  id in_EDX;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 uStack_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  undefined4 uStack_14;
  undefined4 uStack_10;
  
  uStack_10 = in_ECX[5];
  uStack_14 = in_ECX[4];
  uStack_18 = in_ECX[7];
  local_1c = in_ECX[6];
  uStack_20 = in_ECX[3];
  uStack_24 = in_ECX[2];
  local_2c = *in_ECX;
  uStack_28 = in_ECX[1];
  _objc_msgSend(in_EDX,sel_hyperTransformPoints_count_,&local_2c,4);
  *in_ECX = local_2c;
  in_ECX[1] = uStack_28;
  in_ECX[2] = uStack_24;
  in_ECX[3] = uStack_20;
  in_ECX[6] = local_1c;
  in_ECX[7] = uStack_18;
  in_ECX[4] = uStack_14;
  in_ECX[5] = uStack_10;
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009d014 @ 0009d014, 120 bytes * /

uint FUN_0009d014(id param_1,id param_2)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  
  pvVar1 = _objc_msgSend(param_1,sel_node);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperIndex);
  pvVar2 = _objc_msgSend(param_2,sel_node);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperIndex);
  if (pvVar1 < pvVar2) {
    uVar3 = 0xffffffff;
  }
  else {
    uVar3 = (uint)(pvVar2 < pvVar1);
  }
  return uVar3;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000adfde @ 000adfde, 17 bytes * /

bool FUN_000adfde(undefined4 param_1,int param_2,int param_3)

{
  return param_2 == param_3;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000da5c8 @ 000da5c8, 53 bytes * /

void FUN_000da5c8(id param_1,undefined4 param_2)

{
  _objc_msgSend(param_1,sel_compare_options_,param_2,0x40);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dcea9 @ 000dcea9, 206 bytes * /

id FUN_000dcea9(id param_1,undefined4 param_2)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_pluginForLibraryType_,param_1);
  pvVar1 = _objc_msgSend(pvVar1,sel_weight);
  pvVar2 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_pluginForLibraryType_,param_2);
  pvVar2 = _objc_msgSend(pvVar2,sel_weight);
  if ((int)pvVar2 < (int)pvVar1) {
    pvVar1 = (id)0x1;
  }
  else if ((int)pvVar1 < (int)pvVar2) {
    pvVar1 = (id)0xffffffff;
  }
  else {
    pvVar1 = _objc_msgSend(param_1,sel_compare_,param_2);
  }
  return pvVar1;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8581 @ 000f8581, 109 bytes * /

void FUN_000f8581(undefined4 param_1,undefined4 param_2)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = (id)_NSClassFromString(param_1);
  pvVar2 = (id)_NSClassFromString(param_2);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedName);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedName);
  _objc_msgSend(pvVar1,sel_compare_,pvVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011632c @ 0011632c, 143 bytes * /

void FUN_0011632c(id param_1,id param_2)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(param_1,sel_queryHyperInterface_,&DAT_00370fec);
  pvVar2 = _objc_msgSend(param_2,sel_queryHyperInterface_,&DAT_00370fec);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperName);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperName);
  _objc_msgSend(pvVar1,sel_caseInsensitiveCompare_,pvVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011fc3e @ 0011fc3e, 143 bytes * /

void FUN_0011fc3e(id param_1,id param_2)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(param_1,sel_queryHyperInterface_,&DAT_00371f28);
  pvVar2 = _objc_msgSend(param_2,sel_queryHyperInterface_,&DAT_00371f28);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperName);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperName);
  _objc_msgSend(pvVar1,sel_caseInsensitiveCompare_,pvVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00127731 @ 00127731, 466 bytes * /

void FUN_00127731(id param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
                 undefined4 param_5,undefined4 param_6,id param_7,id param_8)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined1 local_2c [16];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSize_,param_5,param_6);
  _objc_msgSend(pvVar1,sel_lockFocus);
  _objc_msgSend(param_8,sel_concat);
  pvVar2 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar2,sel_setShouldAntialias_,0);
  pvVar2 = _objc_msgSend(cls_NSColor,sel_clearColor);
  _objc_msgSend(pvVar2,sel_set);
  uVar3 = (undefined4)((ulonglong)param_4 >> 0x20);
  _objc_msgSend(cls_NSBezierPath,sel_fillRect_,(int)param_4,uVar3,param_5,param_6);
  _objc_msgSend(param_7,sel_setClip);
  _NSIntegralRect(local_2c,(int)param_2,(int)((ulonglong)param_2 >> 0x20),(int)param_3,
                  (int)((ulonglong)param_3 >> 0x20));
  _NSIntegralRect(&local_1c,(int)param_4,uVar3,param_5,param_6);
  _objc_msgSend(param_1,sel_compositeToPoint_fromRect_operation_,local_1c,local_18,
                (int)local_2c._0_8_,SUB84(local_2c._0_8_,4),(int)local_2c._8_8_,
                SUB84(local_2c._8_8_,4),2);
  _objc_msgSend(pvVar1,sel_unlockFocus);
  _objc_msgSend(pvVar1,sel_autorelease);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001469f8 @ 001469f8, 100 bytes * /

bool FUN_001469f8(void)

{
  float in_XMM0_Da;
  float in_XMM1_Da;
  float fVar1;
  float fVar2;
  
  if ((in_XMM0_Da != 0.0) || (NAN(in_XMM0_Da))) {
    fVar1 = ABS(in_XMM0_Da);
  }
  else {
    fVar1 = 1.0;
  }
  if ((in_XMM1_Da != 0.0) || (NAN(in_XMM1_Da))) {
    fVar2 = ABS(in_XMM1_Da);
  }
  else {
    fVar2 = 1.0;
  }
  if (fVar2 <= fVar1) {
    fVar2 = fVar1;
  }
  return in_XMM1_Da + fVar2 * -0.0005 <= in_XMM0_Da;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001802d7 @ 001802d7, 100 bytes * /

bool FUN_001802d7(void)

{
  float in_XMM0_Da;
  float in_XMM1_Da;
  float fVar1;
  float fVar2;
  
  if ((in_XMM0_Da != 0.0) || (NAN(in_XMM0_Da))) {
    fVar1 = ABS(in_XMM0_Da);
  }
  else {
    fVar1 = 1.0;
  }
  if ((in_XMM1_Da != 0.0) || (NAN(in_XMM1_Da))) {
    fVar2 = ABS(in_XMM1_Da);
  }
  else {
    fVar2 = 1.0;
  }
  if (fVar2 <= fVar1) {
    fVar2 = fVar1;
  }
  return in_XMM1_Da + fVar2 * -0.0005 <= in_XMM0_Da;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00193512 @ 00193512, 185 bytes * /

void FUN_00193512(undefined4 param_1,undefined4 param_2)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSNewMediaAccessor,sel_sharedMediaAccessor);
  pvVar1 = _objc_msgSend(pvVar1,sel_mediaForUID_,param_1);
  pvVar2 = _objc_msgSend(cls_HSNewMediaAccessor,sel_sharedMediaAccessor);
  pvVar2 = _objc_msgSend(pvVar2,sel_mediaForUID_,param_2);
  pvVar1 = _objc_msgSend(pvVar1,sel_mediaName);
  pvVar2 = _objc_msgSend(pvVar2,sel_mediaName);
  _objc_msgSend(pvVar1,sel_compare_,pvVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001988a8 @ 001988a8, 151 bytes * /

uint FUN_001988a8(id param_1)

{
  id pvVar1;
  uint uVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(param_1,sel_affectedRectSidesCount);
  if (pvVar1 == (id)0x0) {
    uVar2 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(param_1,sel_affectedRectSideAtIndex_,0);
    dVar3 = _objc_msgSend_fpret(param_1,sel_layoutRuleFloatValueForRectSide_,pvVar1);
    uVar2 = (int)dVar3;
    if (2.1474836e+09 <= (float)dVar3) {
      uVar2 = (int)((float)dVar3 - 2.1474836e+09) ^ 0x80000000;
    }
    uVar2 = (int)pvVar1 << 0x18 | uVar2;
  }
  return uVar2;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e888 @ 0019e888, 22 bytes * /

void FUN_0019e888(undefined4 param_1,void *param_2)

{
  _free(param_2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ae49e @ 001ae49e, 61 bytes * /

undefined4 FUN_001ae49e(undefined4 param_1)

{
  switch(param_1) {
  case 2:
    return 1;
  case 3:
    return 2;
  case 4:
    return 3;
  case 5:
    return 4;
  default:
    return 0;
  }
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ae4ec @ 001ae4ec, 72 bytes * /

undefined4 FUN_001ae4ec(undefined4 param_1)

{
  switch(param_1) {
  case 0:
    return 1;
  case 1:
    return 2;
  case 2:
    return 3;
  case 3:
    return 4;
  case 4:
    return 5;
  case 5:
    return 0;
  default:
    return 0xffffffff;
  }
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b1906 @ 001b1906, 18 bytes * /

void FUN_001b1906(int param_1)

{
  if (param_1 == 0) {
    return;
  }
  _CFRelease();
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b8233 @ 001b8233, 10 bytes * /

undefined4 FUN_001b8233(void)

{
  return 0xfffffffc;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bab1d @ 001bab1d, 86 bytes * /

undefined4 FUN_001bab1d(void)

{
  if (DAT_003429e0 == '\0') {
    _CAWeakRegisterAndBind
              ("/System/Library/Frameworks/QuickLook.framework/QuickLook","_QLThumbnailImageCreate",
               FUN_001b8233,&DAT_003429e4);
    DAT_003429e0 = '\x01';
  }
  return DAT_003429e4;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bb761 @ 001bb761, 163 bytes * /

id FUN_001bb761(id param_1,id param_2,id param_3)

{
  id pvVar1;
  id pvVar2;
  bool bVar3;
  SEL op;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(param_3,sel_objectForKey_,param_1);
  pvVar2 = _objc_msgSend(param_3,sel_objectForKey_,param_2);
  if ((pvVar1 == (id)0x0) || (op = sel_compare_, pvVar4 = pvVar2, pvVar2 == (id)0x0)) {
    if ((pvVar1 != (id)0x0) && (pvVar2 == (id)0x0)) {
      return (id)0x1;
    }
    bVar3 = pvVar1 == (id)0x0;
    pvVar1 = param_1;
    op = sel_caseInsensitiveCompare_;
    pvVar4 = param_2;
    if ((bVar3) && (pvVar2 != (id)0x0)) {
      return (id)0xffffffff;
    }
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pvVar4);
  return pvVar1;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d0cf8 @ 001d0cf8, 38 bytes * /

void FUN_001d0cf8(id param_1)

{
  _objc_msgSend(param_1,sel_release);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d2f9d @ 001d2f9d, 103 bytes * /

void FUN_001d2f9d(id param_1,id param_2)

{
  id self;
  id pvVar1;
  
  self = _objc_msgSend(param_1,sel_objectForKey_,&cfstr_Texture_Name);
  pvVar1 = _objc_msgSend(param_2,sel_objectForKey_,&cfstr_Texture_Name);
  _objc_msgSend(self,sel_caseInsensitiveCompare_,pvVar1);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dffac @ 001dffac, 168 bytes * /

void FUN_001dffac(id param_1,id param_2,undefined4 param_3)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  
  puVar1 = cls_HSLibrarySound;
  pvVar2 = _objc_msgSend(param_1,sel_valueForKey_,param_3);
  pvVar2 = _objc_msgSend(puVar1,sel_stringForValue_forIdentifier_,pvVar2,param_3);
  puVar1 = cls_HSLibrarySound;
  pvVar3 = _objc_msgSend(param_2,sel_valueForKey_,param_3);
  pvVar3 = _objc_msgSend(puVar1,sel_stringForValue_forIdentifier_,pvVar3,param_3);
  _objc_msgSend(pvVar2,sel_caseInsensitiveCompare_,pvVar3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e15d1 @ 001e15d1, 255 bytes * /

void FUN_001e15d1(id param_1,id param_2,id param_3)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  
  uVar3 = *(undefined4 *)PTR_0033678c;
  pvVar1 = _objc_msgSend(param_3,sel_isEqualToString_,uVar3);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSSoundsLibraryiTunesSong,sel_stringForSong_forIdentifier_,param_1,
                           param_3);
    pvVar2 = _objc_msgSend(cls_HSSoundsLibraryiTunesSong,sel_stringForSong_forIdentifier_,param_2,
                           param_3);
    op = sel_caseInsensitiveCompare_;
  }
  else {
    pvVar1 = _objc_msgSend(param_1,sel_info,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,param_3);
    pvVar2 = _objc_msgSend(param_2,sel_info);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,param_3);
    op = sel_compare_;
  }
  _objc_msgSend(pvVar1,op,pvVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fc21d @ 001fc21d, 103 bytes * /

void FUN_001fc21d(id param_1,id param_2)

{
  id self;
  id pvVar1;
  
  self = _objc_msgSend(param_1,sel_objectForKey_,&cfstr_label);
  pvVar1 = _objc_msgSend(param_2,sel_objectForKey_,&cfstr_label);
  _objc_msgSend(self,sel_localizedCaseInsensitiveCompare_,pvVar1);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00228eb8 @ 00228eb8, 263 bytes * /

bool FUN_00228eb8(id param_1)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(param_1,sel_enclosingScrollView);
  pvVar2 = _objc_msgSend(pvVar1,sel_hasVerticalScroller);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(pvVar1,sel_verticalScroller);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEnabled);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(pvVar1,sel_verticalScroller);
      pvVar2 = _objc_msgSend(pvVar2,sel_isHidden);
      if ((char)pvVar2 == '\0') {
        return true;
      }
    }
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_hasHorizontalScroller);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(pvVar1,sel_horizontalScroller);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEnabled);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_horizontalScroller);
      pvVar1 = _objc_msgSend(pvVar1,sel_isHidden);
      return (char)pvVar1 == '\0';
    }
  }
  return false;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_002430d1 @ 002430d1, 194 bytes * /

void FUN_002430d1(id param_1)

{
  undefined *self;
  id pvVar1;
  double dVar2;
  double dVar3;
  double dVar4;
  double dVar5;
  
  self = cls_NSString;
  dVar2 = _objc_msgSend_fpret(param_1,sel_alphaComponent);
  dVar3 = _objc_msgSend_fpret(param_1,sel_blueComponent);
  dVar4 = _objc_msgSend_fpret(param_1,sel_greenComponent);
  dVar5 = _objc_msgSend_fpret(param_1,sel_redComponent);
  pvVar1 = _objc_msgSend(param_1,sel_colorSpaceName);
  _objc_msgSend(self,sel_stringWithFormat_,&cfstr_____f__f__f__f,pvVar1,dVar5,dVar4,dVar3,dVar2);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256918 @ 00256918, 91 bytes * /

undefined4 FUN_00256918(void)

{
  double dVar1;
  double dVar2;
  int in_stack_00000010;
  id in_stack_00000014;
  
  dVar1 = (double)((float)in_stack_00000010 / 65535.0) * 50.0;
  dVar2 = dVar1 - DAT_00342a38;
  DAT_00342a38 = dVar1;
  _objc_msgSend(in_stack_00000014,sel_notifyExportProgressDidChangeWithProgress_,dVar2);
  return 0;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025a411 @ 0025a411, 106 bytes * /

void FUN_0025a411(undefined4 param_1,id param_2,undefined4 *param_3)

{
  double dVar1;
  
  dVar1 = _objc_msgSend_fpret(param_2,sel_doubleValue);
  _objc_msgSend((id)*param_3,sel_addBackgroundSoundWithProperties_atTime_withDuration_inMovie_,
                param_1,dVar1,*(double *)(param_3 + 2) - dVar1,param_3[1]);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025a47b @ 0025a47b, 86 bytes * /

void FUN_0025a47b(void)

{
  int in_EDX;
  
  if (in_EDX != 0) {
    _NSSizeFromString();
  }
  _HSMakeTimeRange();
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_00267c9e @ 00267c9e, 271 bytes * /

void FUN_00267c9e(void)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  id self;
  id pvVar4;
  id pvVar5;
  id in_ECX;
  SEL op;
  id pvVar6;
  
  pvVar2 = _objc_msgSend(cls_QTCompressionOptions,sel_compressionOptionsWithIdentifier_);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(in_ECX,sel_connections);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    self = _objc_msgSend(pvVar3,sel_nextObject);
    if (self != (id)0x0) {
      uVar1 = *(undefined4 *)PTR_00336404;
      do {
        pvVar4 = _objc_msgSend(self,sel_mediaType);
        pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,uVar1);
        pvVar4 = in_ECX;
        op = sel_setCompressionOptions_forConnection_;
        pvVar6 = pvVar2;
        if ((char)pvVar5 == '\0') {
          pvVar4 = self;
          op = sel_setEnabled_;
          pvVar6 = (id)0x0;
        }
        _objc_msgSend(pvVar4,op,pvVar6);
        self = _objc_msgSend(pvVar3,sel_nextObject);
      } while (self != (id)0x0);
    }
  }
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026c73c @ 0026c73c, 64 bytes * /

void FUN_0026c73c(int param_1,undefined4 param_2)

{
  _objc_msgSend(*(id *)(param_1 + 0x18),sel_savePanelDidEnd_returnCode_contextInfo_,
                *(undefined4 *)((int)*(id *)(param_1 + 0x18) + 0x44),param_2,
                *(undefined4 *)(param_1 + 0x14));
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026c77c @ 0026c77c, 43 bytes * /

void FUN_0026c77c(int param_1,int param_2)

{
  __Block_object_assign((void *)(param_1 + 0x18),*(void **)(param_2 + 0x18),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026c7a7 @ 0026c7a7, 33 bytes * /

void FUN_0026c7a7(int param_1)

{
  __Block_object_dispose(*(void **)(param_1 + 0x18),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027cf86 @ 0027cf86, 65 bytes * /

void FUN_0027cf86(int param_1,undefined4 param_2)

{
  _objc_msgSend(*(id *)(param_1 + 0x18),sel_optimizeAndSaveAsPanelDidEnd_returnCode_contextInfo_,
                *(undefined4 *)(param_1 + 0x14),param_2,0);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027cfc7 @ 0027cfc7, 73 bytes * /

void FUN_0027cfc7(int param_1,int param_2)

{
  __Block_object_assign((void *)(param_1 + 0x14),*(void **)(param_2 + 0x14),3);
  __Block_object_assign((void *)(param_1 + 0x18),*(void **)(param_2 + 0x18),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027d010 @ 0027d010, 54 bytes * /

void FUN_0027d010(int param_1)

{
  __Block_object_dispose(*(void **)(param_1 + 0x14),3);
  __Block_object_dispose(*(void **)(param_1 + 0x18),3);
  return;
}

*/

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a3e08 @ 002a3e08, 1243 bytes * /

int FUN_002a3e08(int param_1,double param_2,double param_3)

{
  short sVar1;
  int iVar2;
  undefined4 uVar3;
  uint uVar4;
  int iVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  undefined4 *puVar8;
  undefined4 uVar9;
  uint uVar10;
  uint uVar11;
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  uint local_28;
  uint local_24;
  undefined2 local_20;
  undefined2 local_1e;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  
  iVar2 = _GetTrackMovie(param_1);
  if ((iVar2 == 0) || (param_1 == 0)) {
    sVar1 = 0;
  }
  else {
    uVar3 = _GetTrackMedia(param_1);
    sVar1 = _GetMoviesError();
    if (sVar1 == 0) {
      uVar4 = _GetMediaDuration(uVar3);
      iVar5 = _GetMediaTimeScale(uVar3);
      sVar1 = _GetMoviesError();
      if (sVar1 == 0) {
        if (0.0 <= param_2) {
          uVar10 = (uint)((double)iVar5 * param_2);
        }
        else {
          uVar10 = 0;
        }
        if ((int)uVar10 <= (int)uVar4) {
          uVar6 = _NewMovieTrack(iVar2,0,0,0);
          uVar11 = (uint)((double)iVar5 * param_3);
          if ((int)uVar11 < 1 || (int)uVar4 < (int)uVar11) {
            uVar11 = uVar4;
          }
          uVar7 = _NewTrackMedia(uVar6,0x7477656e,iVar5,0,0);
          sVar1 = _GetMoviesError();
          if (sVar1 == 0) {
            local_14 = 0;
            _QTNewAtomContainer(&local_14);
            sVar1 = _QTInsertChild(local_14,0,0x7477656e,1,0,0,0,&local_18);
            if (sVar1 == 0) {
              local_1c = 0x1000000;
              sVar1 = _QTInsertChild(local_14,local_18,0x74776e74,1,0,4,&local_1c,0);
              if (sVar1 == 0) {
                local_20 = 0xff00;
                local_1e = 0;
                sVar1 = _QTInsertChild(local_14,local_18,0x64617461,1,0,4,&local_20,0);
                if (sVar1 == 0) {
                  local_24 = uVar10 >> 0x18 | (uVar10 & 0xff0000) >> 8 | (uVar10 & 0xff00) << 8 |
                             uVar10 << 0x18;
                  sVar1 = _QTInsertChild(local_14,local_18,0x74777374,1,0,4,&local_24,0);
                  if (sVar1 == 0) {
                    local_28 = uVar11 >> 0x18 | (uVar11 & 0xff0000) >> 8 | (uVar11 & 0xff00) << 8 |
                               uVar11 << 0x18;
                    sVar1 = _QTInsertChild(local_14,local_18,0x74776475,1,0,4,&local_28,0);
                    if ((sVar1 == 0) &&
                       (puVar8 = (undefined4 *)_NewHandleClear(0x10), puVar8 != (undefined4 *)0x0))
                    {
                      *(undefined4 *)*puVar8 = 0x10;
                      _BeginMediaEdits(uVar7);
                      uVar9 = _GetHandleSize(local_14);
                      sVar1 = _AddMediaSample(uVar7,local_14,0,uVar9,uVar4,puVar8,1,0,0);
                      if (sVar1 == 0) {
                        _EndMediaEdits(uVar7);
                        uVar7 = _GetMediaDuration(uVar7);
                        uVar9 = _GetTrackOffset(param_1);
                        sVar1 = _InsertMediaIntoTrack(uVar6,uVar9,0,uVar7,0x10000);
                        if (sVar1 == 0) {
                          _QTDisposeAtomContainer(local_14);
                          _DisposeHandle(puVar8);
                          sVar1 = _AddTrackReference(param_1,uVar6,0x73737263,&local_2c);
                          if (sVar1 == 0) {
                            local_30 = 0;
                            sVar1 = _QTNewAtomContainer(&local_30);
                            if ((sVar1 == 0) &&
                               (sVar1 = _QTInsertChild(local_30,0,0x696e,local_2c,0,0,0,&local_34),
                               sVar1 == 0)) {
                              local_38 = 0x3000000;
                              sVar1 = _QTInsertChild(local_30,local_34,0x7479,1,0,4,&local_38,0);
                              if (sVar1 == 0) {
                                local_3c = 0x1000000;
                                _QTInsertChild(local_30,local_34,0x73756269,1,0,4,&local_3c,0);
                                sVar1 = _SetMediaInputMap(uVar3,local_30);
                                if (sVar1 == 0) {
                                  _QTDisposeAtomContainer(local_30);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return (int)sVar1;
}

*/








#endif
