#import "HSToolSettings.h"

@implementation HSToolSettings

/* i386 ivar offsets: _data=0x4, _additionalPrototypesByToolIdentifier=0x8, _additionalPrototypeSetsByToolIdentifier=0xc */

+ (id)standardSetsNames
{
    return [NSArray arrayWithObjects:@"DefaultToolSettings", @"ToolTemplates", @"ToolSettings", nil];
}

- (void)removeUserObjectPrototype:(id)aPrototype forTool:(id)aTool
{
    id pvVar1;

    pvVar1 = [aTool primarySettingsIdentifier];
    [[_additionalPrototypeSetsByToolIdentifier objectForKey:pvVar1] removeObject:aPrototype];
    [self updateObjectPrototypeForToolIdentifier:pvVar1];
}

- (void)addUserObjectPrototype:(id)aPrototype forTool:(id)aTool
{
    id pvVar1;
    id self_00;

    pvVar1 = [aTool primarySettingsIdentifier];
    self_00 = [_additionalPrototypeSetsByToolIdentifier objectForKey:pvVar1];
    if (_additionalPrototypeSetsByToolIdentifier == nil) {
        _additionalPrototypeSetsByToolIdentifier = [NSMutableDictionary new];
    }
    if (self_00 == nil) {
        self_00 = [NSMutableSet set];
        [_additionalPrototypeSetsByToolIdentifier setObject:self_00 forKey:pvVar1];
    }
    [self_00 addObject:aPrototype];
    [self updateObjectPrototypeForToolIdentifier:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186482 @ 00186482, 407 bytes * /

void FUN_00186482(HSToolSettings *self,SEL _cmd,id updateObjectPrototypeForToolIdentifier)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar3 = updateObjectPrototypeForToolIdentifier;
  pvVar1 = _objc_msgSend(self->_additionalPrototypeSetsByToolIdentifier,sel_objectForKey_,
                         updateObjectPrototypeForToolIdentifier);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  self_00 = cls_NSMutableArray;
  if (pvVar2 == (id)0x0) {
    pvVar1 = (id)0x0;
LAB_00186544:
    pvVar3 = updateObjectPrototypeForToolIdentifier;
    pvVar2 = _objc_msgSend(self->_additionalPrototypesByToolIdentifier,sel_objectForKey_,
                           updateObjectPrototypeForToolIdentifier);
    if (pvVar2 != (id)0x0) {
      pvVar2 = self->_additionalPrototypesByToolIdentifier;
      op = sel_removeObjectForKey_;
      pvVar1 = updateObjectPrototypeForToolIdentifier;
      goto LAB_001865d1;
    }
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  else {
    pvVar3 = _objc_msgSend(pvVar1,sel_allObjects,pvVar3);
    pvVar1 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar3);
    pvVar3 = _objc_msgSend(self,sel_primaryUserObjectPrototypeForToolIdentifier_,
                           updateObjectPrototypeForToolIdentifier);
    _objc_msgSend(pvVar1,sel_addObject_,pvVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperObjectForAllInterfacesWithStrictReturnValueBehavior);
    if (pvVar1 == (id)0x0) goto LAB_00186544;
  }
  pvVar2 = self->_additionalPrototypesByToolIdentifier;
  op = sel_setObject_forKey_;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_new,pvVar3);
    self->_additionalPrototypesByToolIdentifier = pvVar2;
    op = sel_setObject_forKey_;
  }
LAB_001865d1:
  _objc_msgSend(pvVar2,op,pvVar1);
  pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar3,sel_postNotificationName_object_,&cfstr_HSToolSettingsDidChangeNotification,
                self);
  return;
}

*/
- (void)updateObjectPrototypeForToolIdentifier:(id)aIdentifier
{
    id prototype = nil;
    id prototypeSet = [_additionalPrototypeSetsByToolIdentifier objectForKey:aIdentifier];
    if ([prototypeSet count] != 0) {
        NSMutableArray *prototypes = [NSMutableArray arrayWithArray:[prototypeSet allObjects]];
        [prototypes addObject:[self primaryUserObjectPrototypeForToolIdentifier:aIdentifier]];
        prototype = [prototypes hyperObjectForAllInterfacesWithStrictReturnValueBehavior];
    }
    if (prototype != nil) {
        if (_additionalPrototypesByToolIdentifier == nil) {
            _additionalPrototypesByToolIdentifier = [NSMutableDictionary new];
        }
        [_additionalPrototypesByToolIdentifier setObject:prototype forKey:aIdentifier];
    } else if ([_additionalPrototypesByToolIdentifier objectForKey:aIdentifier] != nil) {
        [_additionalPrototypesByToolIdentifier removeObjectForKey:aIdentifier];
    } else {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018683f @ 0018683f, 237 bytes * /

void FUN_0018683f(HSToolSettings *self,SEL _cmd,float setAlternateProportion)

{
  undefined4 uVar1;
  id pvVar2;
  double dVar3;
  
  dVar3 = _objc_msgSend_fpret(self,sel_alternateProportion);
  if ((float)dVar3 != setAlternateProportion) {
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,setAlternateProportion);
    uVar1 = *(undefined4 *)PTR_00336684;
    _objc_msgSend(self,sel_setSetting_forIdentifier_andKey_,pvVar2,*(undefined4 *)PTR_PTR_003362c0,
                  uVar1);
    _objc_msgSend(self,sel_setSetting_forIdentifier_andKey_,pvVar2,*(undefined4 *)PTR_PTR_00336278,
                  uVar1);
    _objc_msgSend(self,sel_setSetting_forIdentifier_andKey_,pvVar2,*(undefined4 *)PTR_PTR_00336208,
                  uVar1);
  }
  return;
}

*/
- (void)setAlternateProportion:(CGFloat)aProportion
{
    if ((float)[self alternateProportion] != aProportion) {
        NSNumber *proportion = [NSNumber numberWithFloat:aProportion];
        /* The rectangle tools share one proportion. */
        [self setSetting:proportion forIdentifier:@"HSRectSelectionTool" andKey:HSToolAlternateProportionAttributeKey];
        [self setSetting:proportion forIdentifier:@"HSImagePartRectSelectionTool" andKey:HSToolAlternateProportionAttributeKey];
        [self setSetting:proportion forIdentifier:@"HSAnimationSetupRectGrabTool" andKey:HSToolAlternateProportionAttributeKey];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018692c @ 0018692c, 90 bytes * /

float FUN_0018692c(HSToolSettings *self,SEL _cmd)

{
  float fVar1;
  id self_00;
  double dVar2;
  
  self_00 = _objc_msgSend(self,sel_settingForIdentifier_andKey_,*(undefined4 *)PTR_PTR_003362c0,
                          *(undefined4 *)PTR_00336684);
  if (self_00 == (id)0x0) {
    fVar1 = 0.0;
  }
  else {
    dVar2 = _objc_msgSend_fpret(self_00,sel_floatValue);
    fVar1 = (float)dVar2;
  }
  return fVar1;
}

*/
- (CGFloat)alternateProportion
{
    id proportion = [self settingForIdentifier:@"HSRectSelectionTool" andKey:HSToolAlternateProportionAttributeKey];
    return proportion == nil ? 0.0 : [proportion floatValue];
}

- (void)setTextShadowEnabled:(BOOL)aEnabled
{
    if ([self textShadowEnabled] != aEnabled) {
        [[self mutableSettingDictionaryForKey:HSTextToolShadowEnabledAttributeKey] setExtraBool:(unsigned int)aEnabled forKey:(NSStringFromSelector(@selector(textShadowEnabled)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

- (void)setFlatTextShadowEnabled:(BOOL)aEnabled
{
    if ([self flatTextShadowEnabled] != aEnabled) {
        [[self mutableSettingDictionaryForKey:HSFlatTextToolShadowEnabledAttributeKey] setExtraBool:(unsigned int)aEnabled forKey:(NSStringFromSelector(@selector(flatTextShadowEnabled)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186b06 @ 00186b06, 164 bytes * /

BOOL FUN_00186b06(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336680;
  uVar4 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_extraFloatForKey_,uVar2);
  return (BOOL)(int)dVar3;
}

*/
- (BOOL)textShadowEnabled
{
    id settings = [[self settings] objectForKey:HSTextToolShadowEnabledAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSTextToolShadowEnabledAttributeKey];
    }
    return (BOOL)(int)[settings extraFloatForKey:NSStringFromSelector(_cmd)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186baa @ 00186baa, 164 bytes * /

BOOL FUN_00186baa(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336678;
  uVar4 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_extraFloatForKey_,uVar2);
  return (BOOL)(int)dVar3;
}

*/
- (BOOL)flatTextShadowEnabled
{
    id settings = [[self settings] objectForKey:HSFlatTextToolShadowEnabledAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSFlatTextToolShadowEnabledAttributeKey];
    }
    return (BOOL)(int)[settings extraFloatForKey:NSStringFromSelector(_cmd)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186c4e @ 00186c4e, 206 bytes * /

void FUN_00186c4e(HSToolSettings *self,SEL _cmd,float setShouldUseCursorContours)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  
  dVar3 = _objc_msgSend_fpret(self,sel_shouldUseCursorContours);
  if ((float)dVar3 != setShouldUseCursorContours) {
    pvVar1 = _objc_msgSend(self,sel_mutableSettingDictionaryForKey_,*(undefined4 *)PTR_003364c8);
    uVar2 = _NSStringFromSelector(sel_shouldUseCursorContours);
    _objc_msgSend(pvVar1,sel_setExtraBool_forKey_,(int)setShouldUseCursorContours & 0xff,uVar2);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_postNotificationName_object_,&cfstr_HSToolSettingsDidChangeNotification
                  ,self);
  }
  return;
}

*/
- (void)setShouldUseCursorContours:(CGFloat)aContours
{
    if ((float)[self shouldUseCursorContours] != aContours) {
        /* Stored as a bool from the float's integer part, as the original does. */
        [[self mutableSettingDictionaryForKey:HSToolCursorContourAttributeKey] setExtraBool:(unsigned char)(int)aContours forKey:NSStringFromSelector(@selector(shouldUseCursorContours))];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186d1c @ 00186d1c, 153 bytes * /

float FUN_00186d1c(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_003364c8;
  uVar4 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_extraFloatForKey_,uVar2);
  return (float)dVar3;
}

*/
- (CGFloat)shouldUseCursorContours
{
    id settings = [[self settings] objectForKey:HSToolCursorContourAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolCursorContourAttributeKey];
    }
    return (float)[settings extraFloatForKey:NSStringFromSelector(_cmd)];
}

- (void)setEffectIntencity:(CGFloat)aIntencity
{
    if ((float)[self effectIntencity] != aIntencity) {
        [[self mutableSettingDictionaryForKey:HSToolEffectIntencityAttributeKey] setExtraFloat:aIntencity forKey:(NSStringFromSelector(@selector(effectIntencity)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186e82 @ 00186e82, 153 bytes * /

float FUN_00186e82(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_0033660c;
  uVar4 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_extraFloatForKey_,uVar2);
  return (float)dVar3;
}

*/
- (CGFloat)effectIntencity
{
    id settings = [[self settings] objectForKey:HSToolEffectIntencityAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolEffectIntencityAttributeKey];
    }
    return (float)[settings extraFloatForKey:NSStringFromSelector(_cmd)];
}

- (void)setShouldFillShapes:(BOOL)aShapes
{
    if ([self shouldFillShapes] != aShapes) {
        [[self mutableSettingDictionaryForKey:HSToolShapeStyleAttributeKey] setExtraBool:(unsigned int)aShapes forKey:(NSStringFromSelector(@selector(shouldFillShapes)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00186fdb @ 00186fdb, 156 bytes * /

BOOL FUN_00186fdb(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336478;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_extraBoolForKey_,uVar2);
  return (BOOL)pvVar1;
}

*/
- (BOOL)shouldFillShapes
{
    id settings = [[self settings] objectForKey:HSToolShapeStyleAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolShapeStyleAttributeKey];
    }
    return [settings extraBoolForKey:NSStringFromSelector(_cmd)];
}

- (void)setShouldStrokeShapes:(BOOL)aShapes
{
    if ([self shouldStrokeShapes] != aShapes) {
        [[self mutableSettingDictionaryForKey:HSToolShapeStyleAttributeKey] setExtraBool:(unsigned int)aShapes forKey:(NSStringFromSelector(@selector(shouldStrokeShapes)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187137 @ 00187137, 156 bytes * /

BOOL FUN_00187137(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336478;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_extraBoolForKey_,uVar2);
  return (BOOL)pvVar1;
}

*/
- (BOOL)shouldStrokeShapes
{
    id settings = [[self settings] objectForKey:HSToolShapeStyleAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolShapeStyleAttributeKey];
    }
    return [settings extraBoolForKey:NSStringFromSelector(_cmd)];
}

- (void)setStrokeWidth:(CGFloat)aWidth
{
    if ((float)[self strokeWidth] != aWidth) {
        [[self mutableSettingDictionaryForKey:HSToolStrokeWidthAttributeKey] setExtraFloat:aWidth forKey:(NSStringFromSelector(@selector(strokeWidth)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001872a0 @ 001872a0, 153 bytes * /

float FUN_001872a0(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_0033647c;
  uVar4 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_extraFloatForKey_,uVar2);
  return (float)dVar3;
}

*/
- (CGFloat)strokeWidth
{
    id settings = [[self settings] objectForKey:HSToolStrokeWidthAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolStrokeWidthAttributeKey];
    }
    return (float)[settings extraFloatForKey:NSStringFromSelector(_cmd)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187339 @ 00187339, 268 bytes * /

void FUN_00187339(HSToolSettings *self,SEL _cmd,NSSize setEraserSize)

{
  char cVar1;
  id pvVar2;
  undefined4 uVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  
  pvVar2 = _objc_msgSend(self,sel_eraserSize);
  cVar1 = _NSEqualSizes(pvVar2,extraout_EDX,setEraserSize.width,setEraserSize.height);
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_mutableSettingDictionaryForKey_,*(undefined4 *)PTR_003364d4);
    uVar3 = _NSStringFromSelector(sel_eraserSize);
    pvVar4 = _objc_msgSend(cls_NSDictionary,sel_extraDictionaryWithSize_,setEraserSize.width,
                           setEraserSize.height);
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar4,uVar3);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_postNotificationName_object_,&cfstr_HSToolSettingsDidChangeNotification
                  ,self);
  }
  return;
}

*/
- (void)setEraserSize:(NSSize)aSize
{
    if (!NSEqualSizes([self eraserSize], aSize)) {
        [[self mutableSettingDictionaryForKey:HSToolEraserSizeAttributeKey] setObject:[NSDictionary extraDictionaryWithSize:aSize] forKey:NSStringFromSelector(@selector(eraserSize))];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187445 @ 00187445, 208 bytes * /

ulonglong FUN_00187445(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_003364d4;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = *(id *)PTR_0033607c;
    uVar2 = *(undefined4 *)(PTR_0033607c + 4);
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_extraSizeValue,uVar2);
    uVar2 = extraout_EDX;
  }
  return CONCAT44(uVar2,pvVar1);
}

*/
- (NSSize)eraserSize
{
    id settings = [[self settings] objectForKey:HSToolEraserSizeAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolEraserSizeAttributeKey];
    }
    id size = [settings objectForKey:NSStringFromSelector(_cmd)];
    return size == nil ? NSZeroSize : [size extraSizeValue];
}

- (void)setSizeRatio:(CGFloat)aRatio
{
    if ((float)[self sizeRatio] != aRatio) {
        [[self mutableSettingDictionaryForKey:HSToolSizeRatioAttributeKey] setExtraFloat:aRatio forKey:(NSStringFromSelector(@selector(sizeRatio)))];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001875e2 @ 001875e2, 153 bytes * /

float FUN_001875e2(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  double dVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_003364cc;
  uVar4 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  uVar2 = _NSStringFromSelector(_cmd);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_extraFloatForKey_,uVar2);
  return (float)dVar3;
}

*/
- (CGFloat)sizeRatio
{
    id settings = [[self settings] objectForKey:HSToolSizeRatioAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolSizeRatioAttributeKey];
    }
    return (float)[settings extraFloatForKey:NSStringFromSelector(_cmd)];
}

- (void)setEraserColor:(id)aColor
{
    [self setSetting:aColor forIdentifier:HSToolEraserColorAttributeKey andKey:(NSStringFromSelector(@selector(eraserColor)))];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSArchiver archivedDataWithRootObject:aColor] forKey:HSToolEraserColorPreferencesKey]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187747 @ 00187747, 181 bytes * /

id FUN_00187747(HSToolSettings *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_003364c4;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  self_00 = cls_NSObject;
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  pvVar1 = _objc_msgSend(self_00,sel_objectWithExtraDictionary_,pvVar1);
  return pvVar1;
}

*/
- (id)eraserColor
{
    id settings = [[self settings] objectForKey:HSToolEraserColorAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolEraserColorAttributeKey];
    }
    return [NSObject objectWithExtraDictionary:[settings objectForKey:NSStringFromSelector(_cmd)]];
}

- (void)setFillColor:(id)aColor
{
    [self setSetting:aColor forIdentifier:HSToolFillColorAttributeKey andKey:(NSStringFromSelector(@selector(fillColor)))];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187849 @ 00187849, 181 bytes * /

id FUN_00187849(HSToolSettings *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336474;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  self_00 = cls_NSObject;
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  pvVar1 = _objc_msgSend(self_00,sel_objectWithExtraDictionary_,pvVar1);
  return pvVar1;
}

*/
- (id)fillColor
{
    id settings = [[self settings] objectForKey:HSToolFillColorAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolFillColorAttributeKey];
    }
    return [NSObject objectWithExtraDictionary:[settings objectForKey:NSStringFromSelector(_cmd)]];
}

- (void)setDrawColor:(id)aColor
{
    [self setSetting:aColor forIdentifier:HSToolDrawColorAttributeKey andKey:(NSStringFromSelector(@selector(drawColor)))];
    [self setSetting:[NSNumber numberWithBool:(unsigned int)(![[aColor colorSpaceName] isEqualToString:NSPatternColorSpace])] forIdentifier:kToolPaddingKey andKey:kToolPaddingKey];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001879c9 @ 001879c9, 181 bytes * /

id FUN_001879c9(HSToolSettings *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336470;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  self_00 = cls_NSObject;
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  pvVar1 = _objc_msgSend(self_00,sel_objectWithExtraDictionary_,pvVar1);
  return pvVar1;
}

*/
- (id)drawColor
{
    id settings = [[self settings] objectForKey:HSToolDrawColorAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolDrawColorAttributeKey];
    }
    return [NSObject objectWithExtraDictionary:[settings objectForKey:NSStringFromSelector(_cmd)]];
}

- (void)setTextColor:(id)aColor
{
    [self setSetting:aColor forIdentifier:HSToolTextColorAttributeKey andKey:(NSStringFromSelector(@selector(textColor)))];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187acb @ 00187acb, 181 bytes * /

id FUN_00187acb(HSToolSettings *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  uVar2 = *(undefined4 *)PTR_00336688;
  uVar3 = uVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_defaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  }
  self_00 = cls_NSObject;
  uVar2 = _NSStringFromSelector(_cmd);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  pvVar1 = _objc_msgSend(self_00,sel_objectWithExtraDictionary_,pvVar1);
  return pvVar1;
}

*/
- (id)textColor
{
    id settings = [[self settings] objectForKey:HSToolTextColorAttributeKey];
    if (settings == nil) {
        settings = [[self defaults] objectForKey:HSToolTextColorAttributeKey];
    }
    return [NSObject objectWithExtraDictionary:[settings objectForKey:NSStringFromSelector(_cmd)]];
}

- (void)resetColorsToDefault
{
    [[self settings] removeObjectForKey:HSToolTextColorAttributeKey];
    [[self settings] removeObjectForKey:HSToolDrawColorAttributeKey];
    [[self settings] removeObjectForKey:HSToolFillColorAttributeKey];
    [[self settings] removeObjectForKey:HSToolEraserColorAttributeKey];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001862d5 @ 001862d5, 213 bytes * /

void FUN_001862d5(HSToolSettings *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(self,sel_settings);
  _objc_msgSend(pvVar1,sel_setObject_forKey_,pvVar2,*(undefined4 *)PTR_0033668c);
  pvVar1 = _objc_msgSend(self,sel_primaryUserObjectPrototypeForToolIdentifier_,
                         *(undefined4 *)PTR_PTR_00336310);
  pvVar1 = _objc_msgSend(pvVar1,sel_extraDictionaryRepresentation);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,*(undefined4 *)PTR_0033667c);
  return;
}

*/
- (void)saveToolsSettingsToDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[self settings] forKey:HSToolsSettingsPreferencesKey];
    id textToolPrototype = [[self primaryUserObjectPrototypeForToolIdentifier:@"HSTextTool"] extraDictionaryRepresentation];
    [[NSUserDefaults standardUserDefaults] setObject:textToolPrototype forKey:HSTextToolSettingsPreferencesKey];
}

- (id)userObjectPrototypeForTool:(id)aTool
{
    id pvVar1;
    id pvVar2;

    pvVar1 = [aTool primarySettingsIdentifier];
    pvVar2 = [_additionalPrototypesByToolIdentifier objectForKey:pvVar1];
    if (pvVar2 == nil) {
        pvVar2 = [self primaryUserObjectPrototypeForToolIdentifier:pvVar1];
    }
    return pvVar2;
}

- (id)primaryUserObjectPrototypeForTool:(id)aTool
{
    return [self primaryUserObjectPrototypeForToolIdentifier:[aTool primarySettingsIdentifier]];
}

- (id)primaryUserObjectPrototypeForToolIdentifier:(id)aIdentifier
{
    return [[HSCreationToolSettingsProvider sharedInstance] userObjectPrototypeForToolIdentifier:aIdentifier];
}

- (id)settingForIdentifier:(id)aIdentifier andKey:(id)aKey
{
    id pvVar2;
    id pvVar2_2;

    pvVar2 = [[self settings] objectForKey:aIdentifier];
    pvVar2_2 = [pvVar2 objectForKey:aKey];
    if (pvVar2_2 == nil) {
        pvVar2_2 = [[[self defaults] objectForKey:aIdentifier] objectForKey:aKey];
        if (pvVar2_2 != nil) {
            [[self mutableSettingDictionaryForKey:aIdentifier] setObject:pvVar2_2 forKey:aKey];
        }
    }
    return pvVar2_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00185f6d @ 00185f6d, 407 bytes * /

void FUN_00185f6d(HSToolSettings *self,SEL _cmd,id setSetting,id forIdentifier,id andKey)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_mutableSettingDictionaryForKey_,forIdentifier);
  puVar3 = &DAT_003796c4;
  pvVar2 = _objc_msgSend(setSetting,sel_conformsToProtocol_,&DAT_003796c4);
  if ((char)pvVar2 != '\0') {
    setSetting = _objc_msgSend(setSetting,sel_extraDictionaryRepresentation,puVar3);
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,andKey);
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,setSetting);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(pvVar1,sel_setObject_forKey_,setSetting,andKey);
    pvVar1 = forIdentifier;
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,forIdentifier);
    puVar3 = cls_NSNumber;
    if (pvVar2 == (id)0x0) {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,forIdentifier,andKey);
      pvVar2 = _objc_msgSend(puVar3,sel_numberWithInt_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar1,andKey);
    if (pvVar2 == (id)0x0) {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar2,
                             &cfstr_HSToolTagKey);
    }
    _objc_msgSend(pvVar1,sel_postNotificationName_object_userInfo_,
                  &cfstr_HSToolSettingsDidChangeNotification,self,pvVar2);
  }
  return;
}

*/
- (void)setSetting:(id)aSetting forIdentifier:(id)aIdentifier andKey:(id)aKey
{
    NSMutableDictionary *settings = [self mutableSettingDictionaryForKey:aIdentifier];
    if ([aSetting conformsToProtocol:@protocol(EXKeyValueCoding)]) {
        aSetting = [aSetting extraDictionaryRepresentation];
    }
    if ([[settings objectForKey:aKey] isEqual:aSetting]) {
        return;
    }
    [settings setObject:aSetting forKey:aKey];
    NSNumber *tag = nil;
    if ([HSToolManager toolTagForIdentifier:aIdentifier] != 0) {
        tag = [NSNumber numberWithInt:(int)[HSToolManager toolTagForIdentifier:aIdentifier]];
    }
    NSDictionary *userInfo = tag == nil ? nil : [NSDictionary dictionaryWithObject:tag forKey:@"HSToolTagKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSToolSettingsDidChangeNotification" object:self userInfo:userInfo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00185e84 @ 00185e84, 233 bytes * /

id FUN_00185e84(HSToolSettings *self,SEL _cmd,id mutableSettingDictionaryForKey)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_settings);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,mutableSettingDictionaryForKey);
  pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_class);
  pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
  if ((char)pvVar3 == '\0') {
    self_00 = cls_NSMutableDictionary;
    op = sel_dictionary;
    if (pvVar1 != (id)0x0) {
      self_00 = _objc_msgSend(pvVar1,sel_mutableCopy,pvVar2);
      op = sel_autorelease;
    }
    pvVar1 = _objc_msgSend(self_00,op,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_settings);
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,mutableSettingDictionaryForKey);
  }
  return pvVar1;
}

*/
- (id)mutableSettingDictionaryForKey:(id)aKey
{
    id settings = [[self settings] objectForKey:aKey];
    if (![settings isKindOfClass:[NSMutableDictionary class]]) {
        settings = settings == nil ? [NSMutableDictionary dictionary] : [[settings mutableCopy] autorelease];
        [[self settings] setObject:settings forKey:aKey];
    }
    return settings;
}

- (id)settings
{
    return [self dictionaryWithName:@"ToolSettings" objectClass:[NSMutableDictionary class]];
}

- (id)defaults
{
    return [self dictionaryWithName:@"DefaultToolSettings" objectClass:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00185ca7 @ 00185ca7, 343 bytes * /

id FUN_00185ca7(HSToolSettings *self,SEL _cmd,id settingsSetForName,id toolIdentifier,int index)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(settingsSetForName,sel_isEqual_,&cfstr_ToolTemplates);
  if ((char)pvVar1 == '\0') {
    pcVar4 = &cfstr_ToolSettings;
    pvVar1 = _objc_msgSend(settingsSetForName,sel_isEqual_,&cfstr_ToolSettings);
    if ((char)pvVar1 == '\0') {
      pvVar1 = (id)0x0;
      pvVar2 = _objc_msgSend(self,sel_dictionaryWithName_objectClass_,settingsSetForName,0);
      op = sel_objectForKey_;
    }
    else {
      pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_class,pcVar4);
      pvVar2 = _objc_msgSend(self,sel_dictionaryWithName_objectClass_,settingsSetForName,pvVar1);
      op = sel_objectForKey_;
    }
  }
  else {
    pvVar1 = (id)0x0;
    pvVar2 = _objc_msgSend(self,sel_dictionaryWithName_objectClass_,settingsSetForName,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,toolIdentifier);
    if ((index < 0) ||
       (pvVar3 = _objc_msgSend(pvVar2,sel_count,toolIdentifier,pvVar1), op = sel_objectAtIndex_,
       toolIdentifier = (id)index, (int)pvVar3 <= index)) {
      return (id)0x0;
    }
  }
  pvVar1 = _objc_msgSend(pvVar2,op,toolIdentifier,pvVar1);
  return pvVar1;
}

*/
- (id)settingsSetForName:(id)aName toolIdentifier:(id)aIdentifier index:(NSInteger)aIndex
{
    if ([aName isEqual:@"ToolTemplates"]) {
        NSArray *templates = [[self dictionaryWithName:aName objectClass:Nil] objectForKey:aIdentifier];
        if (aIndex < 0 || (NSInteger)[templates count] <= aIndex) {
            return nil;
        }
        return [templates objectAtIndex:aIndex];
    }
    if ([aName isEqual:@"ToolSettings"]) {
        return [[self dictionaryWithName:aName objectClass:[NSMutableDictionary class]] objectForKey:aIdentifier];
    }
    return [[self dictionaryWithName:aName objectClass:Nil] objectForKey:aIdentifier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00185aea @ 00185aea, 445 bytes * /

id FUN_00185aea(HSToolSettings *self,SEL _cmd,id dictionaryWithName,Class objectClass)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar2 = dictionaryWithName;
  pvVar1 = _objc_msgSend(self->_data,sel_objectForKey_,dictionaryWithName);
  if (pvVar1 != (id)0x0) {
    return pvVar1;
  }
  if (objectClass == (Class)0x0) {
    objectClass = _objc_msgSend(cls_NSDictionary,sel_class,pvVar2);
  }
  pcVar3 = &cfstr_ToolSettings;
  pvVar2 = _objc_msgSend(dictionaryWithName,sel_isEqualToString_,&cfstr_ToolSettings);
  if ((char)pvVar2 == '\0') {
LAB_00185be9:
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar3);
    pcVar3 = &cfstr_plist;
    pvVar2 = dictionaryWithName;
    pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,dictionaryWithName,&cfstr_plist);
    op = sel_new;
    if (pvVar1 != (id)0x0) {
      objectClass = _objc_msgSend(objectClass,sel_alloc,pvVar2,pcVar3);
      op = sel_initWithContentsOfFile_;
      pvVar2 = pvVar1;
    }
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar3);
    pcVar3 = &cfstr_HSPreserveToolsSettings;
    pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,&cfstr_HSPreserveToolsSettings);
    if ((char)pvVar2 == '\0') goto LAB_00185be9;
    pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar3);
    pvVar2 = *(id *)PTR_0033668c;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
    op = sel_new;
    if (pvVar1 != (id)0x0) goto LAB_00185c52;
  }
  pvVar1 = _objc_msgSend(objectClass,op,pvVar2);
LAB_00185c52:
  if (pvVar1 != (id)0x0) {
    self_00 = self->_data;
    if (self_00 == (id)0x0) {
      self_00 = _objc_msgSend(cls_NSMutableDictionary,sel_new,pvVar2);
      self->_data = self_00;
    }
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,dictionaryWithName);
  }
  return pvVar1;
}

*/
- (id)dictionaryWithName:(id)aName objectClass:(Class)aClass
{
    id dictionary = [_data objectForKey:aName];
    if (dictionary != nil) {
        return dictionary;
    }
    if (aClass == Nil) {
        aClass = [NSDictionary class];
    }
    if ([aName isEqualToString:@"ToolSettings"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"HSPreserveToolsSettings"]) {
        dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:HSToolsSettingsPreferencesKey];
        if (dictionary == nil) {
            dictionary = [[aClass new] autorelease];
        }
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:aName ofType:@"plist"];
        /* Fix: the original leaked the dictionaries it created here. */
        dictionary = path != nil ? [[[aClass alloc] initWithContentsOfFile:path] autorelease] : [[aClass new] autorelease];
    }
    if (dictionary != nil) {
        if (_data == nil) {
            _data = [NSMutableDictionary new];
        }
        [_data setObject:dictionary forKey:aName];
    }
    return dictionary;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187b80 @ 00187b80, 1065 bytes * /

BOOL FUN_00187b80(HSToolSettings *self,SEL _cmd,id processIdentifier,id inDictionary)

{
  id pvVar1;
  id pvVar2;
  float fVar3;
  id pvVar4;
  undefined4 uVar5;
  id pvVar6;
  id self_00;
  id self_01;
  id pvVar7;
  id pvVar8;
  float extraout_EDX;
  double dVar9;
  SEL op;
  id local_20;
  float local_1c;
  
  pvVar4 = _objc_msgSend(processIdentifier,sel_isEqualTo_,*(undefined4 *)PTR_003364cc);
  pvVar6 = inDictionary;
  if ((char)pvVar4 == '\0') {
    uVar5 = *(undefined4 *)PTR_00336478;
    pvVar4 = _objc_msgSend(processIdentifier,sel_isEqualTo_,uVar5);
    if ((char)pvVar4 == '\0') {
      pvVar4 = *(id *)PTR_003364c8;
      pvVar6 = _objc_msgSend(processIdentifier,sel_isEqualTo_,pvVar4);
      if ((char)pvVar6 == '\0') {
        return '\0';
      }
      dVar9 = _objc_msgSend_fpret(self,sel_shouldUseCursorContours);
      if (((float)dVar9 == 0.0) && (!NAN((float)dVar9))) {
        pvVar6 = _objc_msgSend(inDictionary,sel_copy,pvVar4);
        self_00 = _objc_msgSend(pvVar6,sel_keyEnumerator);
        self_01 = _objc_msgSend(self_00,sel_nextObject);
        op = sel_release;
        if (self_01 != (id)0x0) {
          pvVar1 = *(id *)PTR_00336690;
          pvVar2 = *(id *)PTR_00336694;
          do {
            pvVar7 = _objc_msgSend(self_01,sel_hasPrefix_,pvVar2);
            pvVar4 = pvVar1;
            pvVar8 = _objc_msgSend(self_01,sel_hasPrefix_,pvVar1);
            if ((char)pvVar8 != '\0' || (char)pvVar7 != '\0') {
              _objc_msgSend(inDictionary,sel_removeObjectForKey_,self_01);
              pvVar8 = pvVar2;
              if ((char)pvVar7 == '\0') {
                pvVar8 = pvVar1;
              }
              pvVar4 = _objc_msgSend(cls_NSNull,sel_null,self_01);
              _objc_msgSend(inDictionary,sel_setObject_forKey_,pvVar4,pvVar8);
            }
            self_01 = _objc_msgSend(self_00,sel_nextObject,pvVar4);
            op = sel_release;
          } while (self_01 != (id)0x0);
        }
LAB_00187e22:
        _objc_msgSend(pvVar6,op,pvVar4);
        return '\x01';
      }
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_shouldStrokeShapes,uVar5);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,&cfstr_empty,
                               *(undefined4 *)PTR_00336674);
        _objc_msgSend(inDictionary,sel_setObject_forKey_,pvVar4,*(undefined4 *)PTR_00336470);
        uVar5 = 0;
        _objc_msgSend(inDictionary,sel_setExtraFloat_forKey_,0,*(undefined4 *)PTR_0033647c);
      }
      pvVar4 = _objc_msgSend(self,sel_shouldFillShapes,uVar5);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,&cfstr_empty,
                               *(undefined4 *)PTR_00336674);
        op = sel_setObject_forKey_;
        goto LAB_00187e22;
      }
    }
  }
  else {
    uVar5 = _NSStringFromSelector(sel_size);
    pvVar4 = _objc_msgSend(inDictionary,sel_objectForKey_,uVar5);
    if (pvVar4 == (id)0x0) {
      local_20 = *(id *)PTR_0033607c;
      local_1c = *(float *)(PTR_0033607c + 4);
    }
    else {
      local_20 = _objc_msgSend(pvVar4,sel_extraSizeValue,uVar5);
      local_1c = extraout_EDX;
    }
    dVar9 = _objc_msgSend_fpret(self,sel_sizeRatio);
    fVar3 = (float)dVar9;
    if (((0.0 < (float)local_20) && (0.0 < local_1c)) && (0.0 < fVar3)) {
      if ((float)local_20 <= local_1c) {
        local_20 = (id)(((float)local_20 * fVar3) / local_1c);
        local_1c = fVar3;
      }
      else {
        local_1c = (local_1c * fVar3) / (float)local_20;
        local_20 = (id)fVar3;
      }
      _NSStringFromSelector(sel_size);
      pvVar4 = _objc_msgSend(cls_NSDictionary,sel_extraDictionaryWithSize_,local_20,local_1c);
      op = sel_setObject_forKey_;
      goto LAB_00187e22;
    }
  }
  return '\x01';
}

*/
- (BOOL)processIdentifier:(id)aIdentifier inDictionary:(id)aDictionary
{
    if ([aIdentifier isEqualTo:HSToolSizeRatioAttributeKey]) {
        /* Fit the size into a square of sizeRatio, keeping its aspect. */
        id sizeValue = [aDictionary objectForKey:NSStringFromSelector(@selector(size))];
        NSSize size = sizeValue == nil ? NSZeroSize : [sizeValue extraSizeValue];
        float width = size.width;
        float height = size.height;
        float ratio = (float)[self sizeRatio];
        if (width > 0.0f && height > 0.0f && ratio > 0.0f) {
            if (width <= height) {
                width = (width * ratio) / height;
                height = ratio;
            } else {
                height = (height * ratio) / width;
                width = ratio;
            }
            [aDictionary setObject:[NSDictionary extraDictionaryWithSize:NSMakeSize(width, height)] forKey:NSStringFromSelector(@selector(size))];
        }
        return YES;
    }
    if ([aIdentifier isEqualTo:HSToolShapeStyleAttributeKey]) {
        /* An empty class name stands for no color. */
        if (![self shouldStrokeShapes]) {
            [aDictionary setObject:[NSDictionary dictionaryWithObject:@"" forKey:EXClassNameKey] forKey:HSToolDrawColorAttributeKey];
            [aDictionary setExtraFloat:0.0 forKey:HSToolStrokeWidthAttributeKey];
        }
        if (![self shouldFillShapes]) {
            [aDictionary setObject:[NSDictionary dictionaryWithObject:@"" forKey:EXClassNameKey] forKey:HSToolFillColorAttributeKey];
        }
        return YES;
    }
    if (![aIdentifier isEqualTo:HSToolCursorContourAttributeKey]) {
        return NO;
    }
    if ((float)[self shouldUseCursorContours] == 0.0f) {
        /* Contours are off: blank out every contour drawing entry. */
        NSDictionary *copy = [aDictionary copy];
        NSEnumerator *enumerator = [copy keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject]) != nil) {
            BOOL isWillDraw = [key hasPrefix:kToolWillDrawCursorContourKey];
            BOOL isDoDraw = [key hasPrefix:kToolDoDrawCursorContourKey];
            if (isDoDraw || isWillDraw) {
                [aDictionary removeObjectForKey:key];
                [aDictionary setObject:[NSNull null] forKey:isWillDraw ? kToolWillDrawCursorContourKey : kToolDoDrawCursorContourKey];
            }
        }
        [copy release];
    }
    return YES;
}

- (void)applySettingsForTool:(id)aTool templateIndex:(NSInteger)aIndex setsNames:(id)aNames
{
    id pvVar2_2;
    id pvVar1_3;

    if (-1 < aIndex) {
        if (aIndex < (int)[self countOfTemplatesForTool:aTool]) {
            pvVar2_2 = [self settings];
            pvVar1_3 = [@"template-" stringByAppendingString:[aTool primarySettingsIdentifier]];
            [pvVar2_2 setObject:[NSNumber numberWithInt:aIndex] forKey:pvVar1_3];
        }
    }
    [aTool loadExtraDictionaryRepresentation:[self settingsForTool:aTool templateIndex:aIndex setsNames:aNames]];
}

- (void)applySettingsForTool:(id)aTool templateIndex:(NSInteger)aIndex
{
    [self applySettingsForTool:aTool templateIndex:aIndex setsNames:[[self class] standardSetsNames]];
}

- (void)applySettingsForTool:(id)aTool
{
    [self applySettingsForTool:aTool templateIndex:0xffffffff];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001857dd @ 001857dd, 363 bytes * /

id FUN_001857dd(HSToolSettings *self,SEL _cmd,id settingsForTool,int templateIndex,id setsNames)

{
  id self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  id pvVar6;
  undefined4 local_24;
  undefined4 local_20;
  
  self_00 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
  local_20 = (id)templateIndex;
  if (templateIndex == -1) {
    local_20 = _objc_msgSend(self,sel_appliedTemplateIndexForTool_,settingsForTool);
  }
  self_01 = _objc_msgSend(settingsForTool,sel_settingsIdentifiers);
  pvVar1 = _objc_msgSend(self_01,sel_count);
  if (0 < (int)pvVar1) {
    local_24 = 0;
    do {
      pvVar2 = _objc_msgSend(self_01,sel_objectAtIndex_,local_24);
      pvVar4 = pvVar2;
      pvVar6 = self_00;
      pvVar3 = _objc_msgSend(self,sel_processIdentifier_inDictionary_,pvVar2,self_00);
      if ((char)pvVar3 == '\0') {
        pvVar4 = _objc_msgSend(setsNames,sel_count,pvVar4,pvVar6);
        if (0 < (int)pvVar4) {
          iVar5 = 0;
          do {
            pvVar3 = _objc_msgSend(setsNames,sel_objectAtIndex_,iVar5,pvVar6);
            pvVar6 = pvVar2;
            pvVar3 = _objc_msgSend(self,sel_settingsSetForName_toolIdentifier_index_,pvVar3,pvVar2,
                                   local_20);
            _objc_msgSend(self_00,sel_addEntriesFromDictionary_,pvVar3);
            iVar5 = iVar5 + 1;
          } while (iVar5 < (int)pvVar4);
        }
      }
      local_24 = local_24 + 1;
    } while (local_24 < (int)pvVar1);
  }
  return self_00;
}

*/
- (id)settingsForTool:(id)aTool templateIndex:(NSInteger)aIndex setsNames:(id)aNames
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    NSInteger templateIndex = aIndex == -1 ? [self appliedTemplateIndexForTool:aTool] : aIndex;
    NSArray *identifiers = [aTool settingsIdentifiers];
    NSInteger count = [identifiers count];
    for (NSInteger i = 0; i < count; i++) {
        id identifier = [identifiers objectAtIndex:i];
        if ([self processIdentifier:identifier inDictionary:settings]) {
            continue;
        }
        NSInteger setsCount = [aNames count];
        for (NSInteger j = 0; j < setsCount; j++) {
            [settings addEntriesFromDictionary:[self settingsSetForName:[aNames objectAtIndex:j] toolIdentifier:identifier index:templateIndex]];
        }
    }
    return settings;
}

- (id)settingsForTool:(id)aTool templateIndex:(NSInteger)aIndex
{
    return [self settingsForTool:aTool templateIndex:aIndex setsNames:[[self class] standardSetsNames]];
}

- (id)settingsForTool:(id)aTool
{
    return [self settingsForTool:aTool templateIndex:0xffffffff];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018569d @ 0018569d, 171 bytes * /

int FUN_0018569d(HSToolSettings *self,SEL _cmd,id appliedTemplateIndexForTool)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(appliedTemplateIndexForTool,sel_primarySettingsIdentifier);
  pvVar1 = _objc_msgSend(&cfstr_template_,sel_stringByAppendingString_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_settings);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_countOfTemplatesForTool_,appliedTemplateIndexForTool);
    pvVar1 = (id)-(uint)(pvVar1 == (id)0x0);
  }
  else {
    pvVar1 = _objc_msgSend(pvVar2,sel_intValue,pvVar1);
  }
  return (int)pvVar1;
}

*/
- (NSInteger)appliedTemplateIndexForTool:(id)aTool
{
    id index = [[self settings] objectForKey:[@"template_" stringByAppendingString:[aTool primarySettingsIdentifier]]];
    if (index == nil) {
        /* No template applied yet: the first one if there are any. */
        return [self countOfTemplatesForTool:aTool] == 0 ? -1 : 0;
    }
    return [index intValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00187fa9 @ 00187fa9, 998 bytes * /

id FUN_00187fa9(HSToolSettings *self,SEL _cmd,uint imageForTemplateAtIndex,id forTool)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  double dVar4;
  undefined8 in_stack_ffffffbc;
  undefined8 uVar5;
  undefined4 uVar6;
  id local_2c;
  
  puVar1 = cls_HSToolManager;
  uVar6 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  pvVar2 = _objc_msgSend(forTool,sel_toolIdentifier);
  uVar5 = CONCAT44(uVar6,pvVar2);
  pvVar2 = _objc_msgSend(puVar1,sel_toolTagForIdentifier_,pvVar2);
  if ((int)pvVar2 < 0x25) {
    if (pvVar2 == (id)0x7) {
LAB_00188158:
      pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
      local_2c = _objc_msgSend(pvVar2,sel_initWithSize_,0x42200000,0x42200000);
      pvVar2 = _objc_msgSend(cls_NSBezierPath,sel_bezierPath);
      pvVar3 = _objc_msgSend(self,sel_templateDictionaryAtIndex_forTool_,imageForTemplateAtIndex,
                             forTool);
      pvVar3 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_shapePrototypePath);
      uVar5 = CONCAT44(forTool,pvVar3);
      _objc_msgSend(pvVar2,sel_loadExtraDictionaryRepresentation_,pvVar3);
      _objc_msgSend(local_2c,sel_lockFocus);
      pvVar3 = _objc_msgSend(cls_NSColor,sel_blackColor);
      _objc_msgSend(pvVar3,sel_set);
      _objc_msgSend(pvVar2,sel_fill);
      op = sel_unlockFocus;
LAB_00188363:
      _objc_msgSend(local_2c,op,uVar5);
      goto LAB_00188372;
    }
    if (pvVar2 == (id)0xa) {
      pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
      local_2c = _objc_msgSend(pvVar2,sel_initWithSize_,0x42480000,0x42c80000);
      pvVar2 = _objc_msgSend(self,sel_templateDictionaryAtIndex_forTool_,imageForTemplateAtIndex,
                             forTool);
      pvVar2 = _objc_msgSend(pvVar2,sel_valueForKey_,&cfstr_lineWidth);
      dVar4 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
      _objc_msgSend(local_2c,sel_lockFocus);
      pvVar2 = _objc_msgSend(cls_NSColor,sel_blackColor);
      _objc_msgSend(pvVar2,sel_set);
      uVar5 = CONCAT44(0x42c80000,(float)dVar4);
      _NSRectFill((float)dVar4 * -0.5 + 25.0,uVar5);
      _objc_msgSend(local_2c,sel_unlockFocus);
      goto LAB_00188372;
    }
  }
  else {
    if ((int)pvVar2 - 0x25U < 2) {
      pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc,uVar5);
      uVar5 = 0x4238000042380000;
      local_2c = _objc_msgSend(pvVar2,sel_initWithSize_,0x42380000,0x42380000);
      if (local_2c == (id)0x0) goto LAB_00188372;
      pvVar2 = _objc_msgSend(self,sel_templateDictionaryAtIndex_forTool_,imageForTemplateAtIndex,
                             forTool);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,*(undefined4 *)PTR_PTR_00336610);
      puVar1 = cls_NSBundle;
      pvVar3 = _objc_msgSend(self,sel_class);
      pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
      uVar5 = CONCAT44(&cfstr_tiff,pvVar2);
      pvVar2 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,pvVar2,&cfstr_tiff);
      if (pvVar2 == (id)0x0) goto LAB_00188372;
      uVar6 = (undefined4)((ulonglong)uVar5 >> 0x20);
      pvVar2 = _objc_msgSend(cls_NSBitmapImageRep,sel_imageRepWithContentsOfFile_,pvVar2);
      uVar5 = CONCAT44(uVar6,pvVar2);
      op = sel_addRepresentation_;
      goto LAB_00188363;
    }
    if (pvVar2 == (id)0x27) goto LAB_00188158;
  }
  local_2c = (id)0x0;
LAB_00188372:
  pvVar2 = _objc_msgSend(local_2c,sel_autorelease,uVar5);
  return pvVar2;
}

*/
- (id)imageForTemplateAtIndex:(NSUInteger)aIndex forTool:(id)aTool
{
    NSImage *image = nil;
    NSInteger tag = [HSToolManager toolTagForIdentifier:[aTool toolIdentifier]];
    if (tag == 7 || tag == 0x27) {
        /* Shape templates. */
        image = [[NSImage alloc] initWithSize:NSMakeSize(40.0, 40.0)];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path loadExtraDictionaryRepresentation:[[self templateDictionaryAtIndex:aIndex forTool:aTool] valueForKey:@"shapePrototypePath"]];
        [image lockFocus];
        [[NSColor blackColor] set];
        [path fill];
        [image unlockFocus];
    } else if (tag == 10) {
        /* Line widths. */
        image = [[NSImage alloc] initWithSize:NSMakeSize(50.0, 100.0)];
        float lineWidth = [[[self templateDictionaryAtIndex:aIndex forTool:aTool] valueForKey:@"lineWidth"] floatValue];
        [image lockFocus];
        [[NSColor blackColor] set];
        NSRectFill(NSMakeRect(lineWidth * -0.5f + 25.0f, 0.0, lineWidth, 100.0));
        [image unlockFocus];
    } else if (tag == 0x25 || tag == 0x26) {
        /* Effect templates show the effect's picture. */
        image = [[NSImage alloc] initWithSize:NSMakeSize(46.0, 46.0)];
        if (image != nil) {
            id effectName = [[self templateDictionaryAtIndex:aIndex forTool:aTool] objectForKey:@"effectName"];
            NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:effectName ofType:@"tiff"];
            if (path != nil) {
                [image addRepresentation:[NSBitmapImageRep imageRepWithContentsOfFile:path]];
            }
        }
    }
    return [image autorelease];
}

- (id)templateDictionaryAtIndex:(NSUInteger)aIndex forTool:(id)aTool
{
    return [[[self dictionaryWithName:@"ToolTemplates" objectClass:nil] valueForKey:[aTool primarySettingsIdentifier]] objectAtIndex:aIndex];
}

- (NSUInteger)countOfTemplatesForTool:(id)aTool
{
    return (unsigned int)[[[self dictionaryWithName:@"ToolTemplates" objectClass:nil] objectForKey:[aTool primarySettingsIdentifier]] count];
}

- (void)dealloc
{
    [_data release];
    [_additionalPrototypesByToolIdentifier release];
    [_additionalPrototypeSetsByToolIdentifier release];
    [super dealloc];
}

@end

