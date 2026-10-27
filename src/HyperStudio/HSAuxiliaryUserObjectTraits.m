#import "HSAuxiliaryUserObjectTraits.h"

@implementation HSAuxiliaryUserObjectTraits

/* i386 ivar offsets: _userObject=0x4, _traits=0x8, _traitsMarkedInvalid=0xc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00063a51 @ 00063a51, 334 bytes * /

id FUN_00063a51(id self,SEL _cmd,id rectsForIcons)

{
  undefined4 uVar1;
  undefined *self_00;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  id local_2c;
  float local_28;
  
  self_00 = cls_NSMutableArray;
  pvVar2 = _objc_msgSend(rectsForIcons,sel_count);
  pvVar2 = _objc_msgSend(self_00,sel_arrayWithCapacity_,pvVar2);
  self_01 = _objc_msgSend(rectsForIcons,sel_reverseObjectEnumerator);
  pvVar3 = _objc_msgSend(self_01,sel_nextObject);
  local_28 = *(float *)PTR_00336078;
  if (pvVar3 != (id)0x0) {
    uVar1 = *(undefined4 *)(PTR_00336074 + 4);
    local_2c = *(id *)(PTR_00336078 + 8);
    do {
      pvVar4 = _objc_msgSend(pvVar3,sel_size);
      local_28 = (float)local_2c + local_28;
      pvVar3 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,CONCAT44(uVar1,local_28),
                             CONCAT44(extraout_EDX,pvVar4));
      _objc_msgSend(pvVar2,sel_insertObject_atIndex_,pvVar3,0);
      pvVar3 = _objc_msgSend(self_01,sel_nextObject);
      local_2c = pvVar4;
    } while (pvVar3 != (id)0x0);
  }
  return pvVar2;
}

*/
+ (id)rectsForIcons:(id)aIcons
{
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:[aIcons count]];
    NSEnumerator *enumerator = [aIcons reverseObjectEnumerator];
    id icon = [enumerator nextObject];
    float x = 0.0;
    float previousWidth = 0.0;
    while (icon != nil) {
        NSSize size = [icon size];
        x = previousWidth + x;
        [rects insertObject:[NSValue valueWithRect:NSMakeRect(x, 0.0, size.width, size.height)] atIndex:0];
        previousWidth = size.width;
        icon = [enumerator nextObject];
    }
    return rects;
}

+ (BOOL)userObjectHasScript:(id)aScript isScriptValid:(BOOL *)aValid warning:(BOOL *)aWarning
{
    id pvVar1;
    id pvVar2;
    BOOL pvVar3;
    BOOL pvVar1_2;
    BOOL pvVar2_2;

    pvVar1 = [aScript queryHyperInterface:@protocol(HSActor)];
    pvVar2 = [aScript queryHyperInterface:@protocol(HSRunScriptActionValidation)];
    pvVar3 = [pvVar2 isHyperValid];
    pvVar2_2 = [pvVar2 hasHyperWarnings];
    pvVar1_2 = [pvVar1 hasActionsMatchingProtocol:@protocol(HSRunScriptActionValidation)];
    if (aValid != nil) {
        *aValid = pvVar3;
    }
    if (aWarning != nil) {
        *aWarning = pvVar2_2;
    }
    return (BOOL)pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00063bed @ 00063bed, 450 bytes * /

id FUN_00063bed(HSAuxiliaryUserObjectTraits *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined8 uVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  float fVar7;
  float fVar8;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  pvVar5 = _objc_msgSend(self,sel_iconImages);
  pvVar6 = _objc_msgSend(self,sel_class);
  pvVar5 = _objc_msgSend(pvVar6,sel_rectsForIcons_,pvVar5);
  _objc_msgSend_stret(&local_24,self,sel_boundingRectForIconRects_,pvVar5);
  cVar4 = _NSIsEmptyRect(CONCAT44(fStack_20,local_24),local_1c,fStack_18);
  if (cVar4 == '\0') {
    fVar8 = fStack_20 + fStack_18;
    fVar7 = local_24 + local_1c;
    uVar1 = *(undefined4 *)PTR_00336074;
    uVar2 = *(undefined4 *)(PTR_00336074 + 4);
    uVar3 = *(undefined8 *)PTR_00336074;
    pvVar6 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar6 = _objc_msgSend(pvVar6,sel_initWithSize_,fVar7,fVar8);
    pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
    _objc_msgSend(pvVar6,sel_setCachedSeparately_,1);
    _objc_msgSend(pvVar6,sel_lockFocus);
    _NSRectFillUsingOperation(uVar3,fVar7,fVar8,0);
    _objc_msgSend(self,sel_renderIconsInRects_clipRect_inView_,pvVar5,uVar1,uVar2,
                  CONCAT44(fVar8,fVar7),0);
    _objc_msgSend(pvVar6,sel_unlockFocus);
  }
  else {
    pvVar6 = (id)0x0;
  }
  return pvVar6;
}

*/
- (id)combinedIconsImage
{
    id rects = [[self class] rectsForIcons:[self iconImages]];
    NSRect bounds = [self boundingRectForIconRects:rects];
    if (NSIsEmptyRect(bounds)) {
        return nil;
    }
    float width = bounds.origin.x + bounds.size.width;
    float height = bounds.origin.y + bounds.size.height;
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
    [image setCachedSeparately:YES];
    [image lockFocus];
    NSRectFillUsingOperation(NSMakeRect(0.0, 0.0, width, height), NSCompositeClear);
    [self renderIconsInRects:rects clipRect:NSMakeRect(0.0, 0.0, width, height) inView:nil];
    [image unlockFocus];
    return image;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00063daf @ 00063daf, 688 bytes * /

void FUN_00063daf(HSAuxiliaryUserObjectTraits *self,SEL _cmd,id renderIconsInRects,NSRect clipRect,
                 id inView)

{
  undefined8 uVar1;
  undefined *puVar2;
  int *piVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  int *piVar11;
  int aiStack_94 [2];
  float afStack_84 [5];
  int local_70 [7];
  int local_54;
  float fStack_50;
  undefined4 local_4c;
  float fStack_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined4 local_34;
  float fStack_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  pvVar5 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  pvVar6 = _objc_msgSend(pvVar5,sel_isFlipped);
  pvVar5 = _objc_msgSend(pvVar5,sel_graphicsPort);
  pvVar7 = _objc_msgSend(self,sel_iconImages);
  pvVar7 = _objc_msgSend(pvVar7,sel_objectEnumerator);
  pvVar8 = _objc_msgSend(renderIconsInRects,sel_objectEnumerator);
  puVar2 = PTR_00336078;
  piVar3 = (int *)&stack0xffffff74;
  while( true ) {
    piVar11 = piVar3;
    piVar11[1] = (int)sel_nextObject;
    *piVar11 = (int)pvVar7;
    piVar11[-1] = 0x64034;
    pvVar9 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
    if (pvVar9 == (id)0x0) {
      return;
    }
    piVar11[1] = (int)sel_nextObject;
    *piVar11 = (int)pvVar8;
    piVar11[-1] = 0x6404f;
    pvVar10 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
    if (pvVar10 == (id)0x0) break;
    piVar11[2] = (int)sel_rectValue;
    piVar11[1] = (int)pvVar10;
    *piVar11 = (int)&local_54;
    piVar11[-1] = 0x63e68;
    _objc_msgSend_stret((void *)*piVar11,(id)piVar11[1],(SEL)piVar11[2]);
    *(NSSize *)(piVar11 + 5) = clipRect.size;
    *(NSPoint *)(piVar11 + 3) = clipRect.origin;
    *(ulonglong *)(piVar11 + 1) = CONCAT44(fStack_48,local_4c);
    *(ulonglong *)(piVar11 + -1) = CONCAT44(fStack_50,local_54);
    piVar11[-2] = 0x63e9d;
    cVar4 = _NSIntersectsRect();
    piVar3 = piVar11 + -1;
    if (cVar4 != '\0') {
      if ((char)pvVar6 == '\0') {
        uVar1 = *(undefined8 *)puVar2;
        *(undefined8 *)(piVar11 + 5) = *(undefined8 *)(puVar2 + 8);
        *(undefined8 *)(piVar11 + 3) = uVar1;
        piVar11[2] = (int)fStack_50;
        piVar11[1] = local_54;
        *piVar11 = (int)sel_drawAtPoint_fromRect_operation_fraction_;
        piVar11[-1] = (int)pvVar9;
        piVar11[8] = 0x3f800000;
        piVar11[7] = 2;
        piVar11[-2] = 0x6401f;
        _objc_msgSend((id)piVar11[-1],(SEL)*piVar11);
        piVar3 = piVar11 + -1;
      }
      else {
        fStack_30 = fStack_48 + fStack_50 + fStack_50;
        local_44 = 0x3f800000;
        uStack_40 = 0;
        local_3c = 0;
        uStack_38 = 0xbf800000;
        local_34 = 0;
        *(ulonglong *)(piVar11 + 4) = (ulonglong)(uint)fStack_30 << 0x20;
        piVar11[2] = 0;
        piVar11[3] = -0x40800000;
        piVar11[0] = 0x3f800000;
        piVar11[1] = 0;
        piVar11[-1] = (int)pvVar5;
        piVar11[-2] = 0x63f19;
        _CGContextConcatCTM();
        uVar1 = *(undefined8 *)puVar2;
        *(undefined8 *)(piVar11 + 5) = *(undefined8 *)(puVar2 + 8);
        *(undefined8 *)(piVar11 + 3) = uVar1;
        piVar11[2] = (int)fStack_50;
        piVar11[1] = local_54;
        *piVar11 = (int)sel_drawAtPoint_fromRect_operation_fraction_;
        piVar11[-1] = (int)pvVar9;
        piVar11[8] = 0x3f800000;
        piVar11[7] = 2;
        piVar11[-2] = 0x63f66;
        _objc_msgSend((id)piVar11[-1],(SEL)*piVar11);
        fStack_18 = fStack_48 + fStack_50 + fStack_50;
        local_2c = 0x3f800000;
        uStack_28 = 0;
        local_24 = 0;
        uStack_20 = 0xbf800000;
        local_1c = 0;
        *(ulonglong *)(piVar11 + 4) = (ulonglong)(uint)fStack_18 << 0x20;
        piVar11[2] = 0;
        piVar11[3] = -0x40800000;
        piVar11[0] = 0x3f800000;
        piVar11[1] = 0;
        piVar11[-1] = (int)pvVar5;
        piVar11[-2] = 0x63fd0;
        _CGContextConcatCTM();
        piVar3 = piVar11 + -1;
      }
    }
  }
  return;
}

*/
- (void)renderIconsInRects:(id)aRects clipRect:(NSRect)aRect inView:(id)aView
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    BOOL flipped = [context isFlipped];
    CGContextRef port = (CGContextRef)[context graphicsPort];
    NSEnumerator *icons = [[self iconImages] objectEnumerator];
    NSEnumerator *rects = [aRects objectEnumerator];
    id icon;
    while ((icon = [icons nextObject]) != nil) {
        id rectValue = [rects nextObject];
        if (rectValue == nil) {
            break;
        }
        NSRect rect = [rectValue rectValue];
        if (!NSIntersectsRect(rect, aRect)) {
            continue;
        }
        if (!flipped) {
            [icon drawAtPoint:rect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        }
        else {
            CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, rect.size.height + rect.origin.y + rect.origin.y);
            CGContextConcatCTM(port, flip);
            [icon drawAtPoint:rect.origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
            CGContextConcatCTM(port, flip);
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006405f @ 0006405f, 265 bytes * /

NSRect * FUN_0006405f(NSRect *__return_storage_ptr__,HSAuxiliaryUserObjectTraits *self,SEL _cmd,
                     id boundingRectForIconRects)

{
  id self_00;
  id pvVar1;
  int *piVar2;
  int aiStack_68 [3];
  undefined8 local_54 [6];
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  local_24 = *(float *)PTR_00336078;
  fStack_20 = *(float *)(PTR_00336078 + 4);
  local_1c = *(float *)(PTR_00336078 + 8);
  fStack_18 = *(float *)(PTR_00336078 + 0xc);
  self_00 = _objc_msgSend(boundingRectForIconRects,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  if (pvVar1 != (id)0x0) {
    piVar2 = (int *)&stack0xffffffa4;
    do {
      piVar2[2] = (int)sel_rectValue;
      piVar2[1] = (int)pvVar1;
      *piVar2 = (int)(local_54 + 4);
      piVar2[-1] = 0x640e4;
      _objc_msgSend_stret((void *)*piVar2,(id)piVar2[1],(SEL)piVar2[2]);
      *(ulonglong *)(piVar2 + 6) = CONCAT44(fStack_18,local_1c);
      *(ulonglong *)(piVar2 + 4) = CONCAT44(fStack_20,local_24);
      *(undefined8 *)(piVar2 + 2) = local_54[5];
      *(undefined8 *)piVar2 = local_54[4];
      piVar2[-1] = (int)&local_24;
      piVar2[-2] = 0x6411b;
      _NSUnionRect();
      piVar2[-1] = (int)sel_nextObject;
      piVar2[-2] = (int)self_00;
      piVar2[-3] = 0x64130;
      pvVar1 = _objc_msgSend((id)piVar2[-2],(SEL)piVar2[-1]);
      piVar2 = piVar2 + -2;
    } while (pvVar1 != (id)0x0);
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = fStack_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = fStack_18;
  return __return_storage_ptr__;
}

*/
- (NSRect)boundingRectForIconRects:(id)aRects
{
    NSRect result = NSZeroRect;
    NSEnumerator *enumerator = [aRects objectEnumerator];
    id value;
    while ((value = [enumerator nextObject]) != nil) {
        result = NSUnionRect(result, [value rectValue]);
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006372e @ 0006372e, 621 bytes * /

id FUN_0006372e(HSAuxiliaryUserObjectTraits *self,SEL _cmd)

{
  HSAuxiliaryTraits *pHVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,5);
  if ((((&self->_traits)->masterCard != 0) || ((&self->_traits)->masterObject != 0)) &&
     (pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_GroupCardAuxIcon), pvVar3 != (id)0x0
     )) {
    _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
  }
  if (((self->_traits).genericAction != 0) &&
     (pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_auxAction), pvVar3 != (id)0x0)) {
    _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
  }
  if (((self->_traits).invalidAction != 0) &&
     (pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_auxInvalidAction), pvVar3 != (id)0x0
     )) {
    _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
  }
  if (((self->_traits).playSoundAction != 0) &&
     (pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_auxPlaySoundAction),
     pvVar3 != (id)0x0)) {
    _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
  }
  if (pHVar1->scriptAction != 0) {
    if (pHVar1->scriptInvalid == 0) {
      if (pHVar1->scriptWarning == 0) {
        pcVar4 = &cfstr_auxScript;
      }
      else {
        pcVar4 = &cfstr_auxScriptAlert;
      }
    }
    else {
      pcVar4 = &cfstr_auxScriptStop;
    }
    pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pcVar4);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
    }
  }
  if (((self->_traits).animation != 0) &&
     (pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_auxAnimation), pvVar3 != (id)0x0)) {
    _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
  }
  if (((self->_traits).hiddenObject != 0) &&
     (pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_auxHidden), pvVar3 != (id)0x0)) {
    _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
  }
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar2);
  return pvVar2;
}

*/
- (id)iconImages
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:5];
    NSImage *image;
    if ((_traits.masterCard || _traits.masterObject) && (image = [NSImage imageNamed:@"GroupCardAuxIcon"]) != nil) {
        [images addObject:image];
    }
    if (_traits.genericAction && (image = [NSImage imageNamed:@"auxAction"]) != nil) {
        [images addObject:image];
    }
    if (_traits.invalidAction && (image = [NSImage imageNamed:@"auxInvalidAction"]) != nil) {
        [images addObject:image];
    }
    if (_traits.playSoundAction && (image = [NSImage imageNamed:@"auxPlaySoundAction"]) != nil) {
        [images addObject:image];
    }
    if (_traits.scriptAction) {
        NSString *name;
        if (_traits.scriptInvalid) {
            name = @"auxScriptStop";
        }
        else if (_traits.scriptWarning) {
            name = @"auxScriptAlert";
        }
        else {
            name = @"auxScript";
        }
        image = [NSImage imageNamed:name];
        if (image != nil) {
            [images addObject:image];
        }
    }
    if (_traits.animation && (image = [NSImage imageNamed:@"auxAnimation"]) != nil) {
        [images addObject:image];
    }
    if (_traits.hiddenObject && (image = [NSImage imageNamed:@"auxHidden"]) != nil) {
        [images addObject:image];
    }
    return [NSArray arrayWithArray:images];
}

- (BOOL)updateTraitsIfInvalid
{
    BOOL BVar1;

    if (_traitsMarkedInvalid == NO) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[self updateTraitsIfNeeded];
    }
    return BVar1;
}

- (void)invalidateTraits
{
    _traitsMarkedInvalid = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006369e @ 0006369e, 93 bytes * /

BOOL FUN_0006369e(HSAuxiliaryUserObjectTraits *self,SEL _cmd)

{
  HSAuxiliaryTraits HVar1;
  id pvVar2;
  bool bVar3;
  
  HVar1 = (HSAuxiliaryTraits)_objc_msgSend(self,sel_updatedTraits);
  pvVar2 = _objc_msgSend(self,sel_traitsAreEqual_,HVar1);
  bVar3 = (char)pvVar2 == '\0';
  if (bVar3) {
    self->_traits = HVar1;
  }
  self->_traitsMarkedInvalid = '\0';
  return bVar3;
}

*/
- (BOOL)updateTraitsIfNeeded
{
    struct HSAuxiliaryTraits traits = [self updatedTraits];
    BOOL changed = ![self traitsAreEqual:traits];
    if (changed) {
        _traits = traits;
    }
    _traitsMarkedInvalid = NO;
    return changed;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000634f3 @ 000634f3, 427 bytes * /

uint FUN_000634f3(HSAuxiliaryUserObjectTraits *self,SEL _cmd)

{
  HSAuxiliaryTraits HVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  uint uVar6;
  uint uVar7;
  bool bVar8;
  char *pcVar9;
  char *pcVar10;
  char local_12;
  char local_11;
  
  HVar1 = self->_traits;
  pvVar2 = _objc_msgSend(self,sel_userObjectHasActionsOtherThanScript);
  if ((char)pvVar2 == '\0') {
    uVar6 = (uint)HVar1 & 0xfffffffc;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_allActionsAreValid);
    bVar8 = (char)pvVar2 == '\0';
    uVar6 = (uint)bVar8 * 2 + (uint)!bVar8 + ((uint)HVar1 & 0xfffffffc);
  }
  pvVar2 = _objc_msgSend(self,sel_userObjectHasPlaySoundAction);
  local_11 = '\x01';
  local_12 = '\0';
  pcVar10 = &local_12;
  pcVar9 = &local_11;
  uVar7 = uVar6 | 4;
  if ((char)pvVar2 == '\0') {
    uVar7 = uVar6 & 0xfffffffb;
  }
  pvVar2 = _objc_msgSend(self,sel_userObjectHasScriptValid_warning_,pcVar9,pcVar10);
  if ((char)pvVar2 == '\0') {
    uVar7 = uVar7 & 0xffffffc7;
  }
  else {
    uVar7 = (uint)(local_12 != '\0') * 0x20 +
            (uint)(local_11 == '\0') * 0x10 + (uVar7 & 0xffffffcf | 8);
  }
  pvVar2 = _objc_msgSend(self,sel_userObjectHasChildrenWithInvalidScripts,pcVar9,pcVar10);
  pvVar3 = _objc_msgSend(self,sel_userObjectHasAnimation);
  pvVar4 = _objc_msgSend(self,sel_userObjectIsMasterCard);
  pvVar5 = _objc_msgSend(self,sel_userObjectIsMasterObject);
  uVar6 = uVar7 | 0x40;
  if ((char)pvVar2 == '\0') {
    uVar6 = uVar7 & 0xffffffbf;
  }
  uVar7 = uVar6 | 0x80;
  if ((char)pvVar3 == '\0') {
    uVar7 = uVar6 & 0xffffff7f;
  }
  uVar6 = uVar7 | 0x100;
  if ((char)pvVar4 == '\0') {
    uVar6 = uVar7 & 0xfffffeff;
  }
  uVar7 = uVar6 | 0x200;
  if ((char)pvVar5 == '\0') {
    uVar7 = uVar6 & 0xfffffdff;
  }
  pvVar2 = _objc_msgSend(self,sel_userObjectIsHidden);
  uVar6 = uVar7 | 0x400;
  if ((char)pvVar2 == '\0') {
    uVar6 = uVar7 & 0xfffffbff;
  }
  return uVar6;
}

*/
- (struct HSAuxiliaryTraits)updatedTraits
{
    struct HSAuxiliaryTraits traits = _traits;
    if ([self userObjectHasActionsOtherThanScript]) {
        BOOL valid = [self allActionsAreValid];
        traits.genericAction = valid;
        traits.invalidAction = !valid;
    }
    else {
        traits.genericAction = 0;
        traits.invalidAction = 0;
    }
    traits.playSoundAction = [self userObjectHasPlaySoundAction];
    BOOL scriptValid = YES;
    BOOL scriptWarning = NO;
    if ([self userObjectHasScriptValid:&scriptValid warning:&scriptWarning]) {
        traits.scriptAction = 1;
        traits.scriptInvalid = !scriptValid;
        traits.scriptWarning = scriptWarning;
    }
    else {
        traits.scriptAction = 0;
        traits.scriptInvalid = 0;
        traits.scriptWarning = 0;
    }
    traits.childInvalidScript = [self userObjectHasChildrenWithInvalidScripts];
    traits.animation = [self userObjectHasAnimation];
    traits.masterCard = [self userObjectIsMasterCard];
    traits.masterObject = [self userObjectIsMasterObject];
    traits.hiddenObject = [self userObjectIsHidden];
    return traits;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00062f69 @ 00062f69, 137 bytes * /

BOOL FUN_00062f69(HSAuxiliaryUserObjectTraits *self,SEL _cmd,HSAuxiliaryTraits traitsAreEqual)

{
  uint uVar1;
  
  uVar1 = (uint)self->_traits ^ (uint)traitsAreEqual;
  return ((byte)((uVar1 & 0x400) >> 10) ^ 1) &
         ~(byte)(uVar1 >> 9) &
         ~((byte)(uVar1 >> 8) & 1) &
         ~((byte)uVar1 >> 7) &
         ~(byte)((uVar1 & 0x40) >> 6) &
         ~(byte)((uVar1 & 0x20) >> 5) &
         ~(byte)((uVar1 & 0x10) >> 4) &
         ~(byte)((uVar1 & 8) >> 3) &
         ~(byte)((uVar1 & 4) >> 2) & ~(byte)((uVar1 & 2) >> 1) & ~((byte)uVar1 & 1);
}

*/
- (BOOL)traitsAreEqual:(struct HSAuxiliaryTraits)aEqual
{
    return _traits.genericAction == aEqual.genericAction
        && _traits.invalidAction == aEqual.invalidAction
        && _traits.playSoundAction == aEqual.playSoundAction
        && _traits.scriptAction == aEqual.scriptAction
        && _traits.scriptInvalid == aEqual.scriptInvalid
        && _traits.scriptWarning == aEqual.scriptWarning
        && _traits.childInvalidScript == aEqual.childInvalidScript
        && _traits.animation == aEqual.animation
        && _traits.masterCard == aEqual.masterCard
        && _traits.masterObject == aEqual.masterObject
        && _traits.hiddenObject == aEqual.hiddenObject;
}

- (void)setUserObject:(id)aObject
{
    if (_userObject != aObject) {
        [_userObject release];
        _userObject = [aObject retain];
        [self updateTraitsIfNeeded];
    }
}

- (id)userObject
{
    return _userObject;
}

- (void)dealloc
{
    [_userObject release];
    [super dealloc];
}

- (BOOL)userObjectIsHidden
{
    BOOL BVar1;
    id pvVar2_2;

    pvVar2_2 = [[self userObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (pvVar2_2 == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[pvVar2_2 isHidden];
    }
    return BVar1;
}

- (BOOL)userObjectIsMasterObject
{
    BOOL BVar1;
    id pvVar2_2;

    pvVar2_2 = [[self userObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (pvVar2_2 == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[pvVar2_2 isGroupObject];
    }
    return BVar1;
}

- (BOOL)userObjectIsMasterCard
{
    BOOL BVar1;
    id pvVar2_2;

    pvVar2_2 = [[self userObject] queryHyperInterface:@protocol(HSCardAttributes)];
    if (pvVar2_2 == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[pvVar2_2 isGroupCard];
    }
    return BVar1;
}

- (BOOL)userObjectHasAnimation
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000632af @ 000632af, 196 bytes * /

BOOL FUN_000632af(HSAuxiliaryUserObjectTraits *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  undefined *puVar4;
  char local_11;
  
  pvVar1 = _objc_msgSend(self,sel_userObject);
  puVar4 = &DAT_0036442c;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036442c);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperEnumerator);
  do {
    puVar3 = _objc_msgSend(pvVar1,sel_nextObject,puVar4);
    if (puVar3 == (undefined *)0x0) {
      return '\0';
    }
    local_11 = '\0';
    pvVar2 = _objc_msgSend(self,sel_class,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_userObjectHasScript_isScriptValid_warning_,puVar3,&local_11,0)
    ;
    puVar4 = puVar3;
  } while (((char)pvVar2 == '\0') || (local_11 != '\0'));
  return '\0';
}

*/
- (BOOL)userObjectHasChildrenWithInvalidScripts
{
    id enumerator = [[[self userObject] queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        BOOL valid = NO;
        if ([[self class] userObjectHasScript:child isScriptValid:&valid warning:NULL] && !valid) {
            return NO;
        }
    }
    return NO;
}

- (BOOL)userObjectHasScriptValid:(BOOL *)aValid warning:(BOOL *)aWarning
{
    return (BOOL)[[self class] userObjectHasScript:[self userObject] isScriptValid:aValid warning:aWarning];
}

- (BOOL)allActionsAreValid
{
    return (BOOL)[[[[self userObject] queryHyperInterface:@protocol(HSActor)] queryHyperInterface:@protocol(HSActionValidation)] isValid];
}

- (BOOL)userObjectHasPlaySoundAction
{
    BOOL bVar3;
    id pvVar1_2;

    pvVar1_2 = [[self userObject] queryHyperInterface:@protocol(HSActor)];
    if (pvVar1_2 == nil) {
        bVar3 = NO;
    }
    else {
        bVar3 = [[pvVar1_2 hyperActionsOfType:[HSPlaySoundAction actionType]] count] != 0;
    }
    return bVar3;
}

- (BOOL)userObjectHasActionsOtherThanScript
{
    id self_00;
    BOOL bVar4;
    id pvVar1_2;
    NSUInteger pvVar2_4;

    pvVar1_2 = [[self userObject] queryHyperInterface:@protocol(HSActor)];
    self_00 = [pvVar1_2 automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    if (pvVar1_2 == nil) {
        bVar4 = NO;
    }
    else {
        pvVar2_4 = [[pvVar1_2 hyperActionsOfType:[HSAction actionType]] count];
        if ([[pvVar1_2 hyperActionsOfType:[HSRunScriptAction actionType]] count] < pvVar2_4) {
            bVar4 = YES;
        }
        else {
            bVar4 = [self_00 runActionsAutomatically];
        }
    }
    return bVar4;
}

@end

