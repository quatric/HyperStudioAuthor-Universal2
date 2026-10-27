#import "HSTexturizerEffectController.h"

static NSInteger HSTextureNameCompare(id a, id b, void *context)
{
    return [[a objectForKey:@"Texture Name"] caseInsensitiveCompare:[b objectForKey:@"Texture Name"]];
}

@implementation HSTexturizerEffectController

/* i386 ivar offsets: _texturePopUpButton=0x24, _reliefSlider=0x28, _scaleSlider=0x2c, _lightAngleSlider=0x30, _styleSwitch=0x34, _lightDirectionPopUpButton=0x38, _textureNamesMenu=0x3c, _textureNamesMap=0x40 */

+ (id)createEffect
{
    return [[HSTexturizerEffect alloc] initWithName:@"Texturizer"];
}

- (void)lightDirectionDidChange:(id)aChange
{
    [self setLightDirection:(int)[_lightDirectionPopUpButton indexOfSelectedItem] + 1];
}

- (void)styleDidChange:(id)aChange
{
    [self setInverted:(unsigned int)([aChange state] == 0x1)];
}

- (void)lightAngleDidChange:(id)aChange
{

}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)scaleDidChange:(id)aChange
{
    [self setScale:(float)([aChange doubleValue] / [aChange maxValue]) * 1.5 + 0.5];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)reliefDidChange:(id)aChange
{
    [self setReliefValue:(float)([aChange doubleValue] / [aChange maxValue])];
}
#pragma clang diagnostic pop

- (void)textureDidChange:(id)aChange
{
    [self setTexture:[self loadTextureAtPath:[[_textureNamesMap objectAtIndex:[aChange indexOfSelectedItem]] objectForKey:@"Texture Path"]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d3878 @ 001d3878, 1122 bytes * /

void FUN_001d3878(HSTexturizerEffectController *self,SEL _cmd)

{
  undefined *self_00;
  HSTexturizerEffectController *pHVar1;
  int iVar2;
  code *self_01;
  code *pcVar3;
  code *pcVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  cfstringStruct *pcVar10;
  char *pcVar11;
  char local_75;
  HSTexturizerEffectController *local_74;
  undefined *local_70;
  int local_6c [22];
  HSTexturizerEffectController *local_14;
  
  local_14 = self;
  local_74 = self;
  local_70 = PTR_s_HSEffectCompositeController_00353d80;
  _objc_msgSendSuper(&local_74,sel_didLoadNib);
  _objc_exception_try_enter(local_6c);
  iVar2 = __setjmp(local_6c);
  if (iVar2 == 0) {
    pvVar6 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar6 = _objc_msgSend(pvVar6,sel_resourcePath);
    self_01 = _objc_msgSend(pvVar6,sel_stringByAppendingPathComponent_,&cfstr_Textures);
    pvVar6 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pcVar3 = self_01;
    pvVar6 = _objc_msgSend(pvVar6,sel_enumeratorAtPath_,self_01);
    pvVar7 = _objc_msgSend(cls_NSImage,sel_imageFileTypes);
    local_75 = '\0';
    pvVar8 = _objc_msgSend(cls_NSMutableArray,sel_new);
    while (pvVar9 = _objc_msgSend(pvVar6,sel_nextObject,pcVar3), pHVar1 = local_14,
          pvVar9 != (id)0x0) {
      pcVar4 = _objc_msgSend(self_01,sel_stringByAppendingPathComponent_,pvVar9);
      pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
      pcVar11 = &local_75;
      pcVar3 = pcVar4;
      pvVar5 = _objc_msgSend(pvVar5,sel_fileExistsAtPath_isDirectory_,pcVar4,pcVar11);
      if (((char)pvVar5 != '\0') && (local_75 == '\0')) {
        pcVar3 = _objc_msgSend(pvVar9,sel_pathExtension,pcVar3,pcVar11);
        pvVar5 = _objc_msgSend(pvVar7,sel_containsObject_,pcVar3);
        self_00 = cls_NSDictionary;
        if ((char)pvVar5 != '\0') {
          pvVar9 = _objc_msgSend(pvVar9,sel_stringByDeletingPathExtension,pcVar3,pcVar11);
          pcVar3 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar9,
                                 &cfstr_Texture_Name,pcVar4,&cfstr_Texture_Path,0);
          _objc_msgSend(pvVar8,sel_addObject_,pcVar3);
        }
      }
    }
    pvVar6 = _objc_msgSend(pvVar8,sel_count,pcVar3);
    if (pvVar6 == (id)0x0) {
      pvVar6 = (id)0x0;
    }
    else {
      pcVar3 = FUN_001d2f9d;
      pvVar6 = _objc_msgSend(pvVar8,sel_sortedArrayUsingFunction_context_,FUN_001d2f9d,0);
      pvVar6 = _objc_msgSend(pvVar6,sel_retain);
    }
    pHVar1->_textureNamesMap = pvVar6;
    _objc_msgSend(pvVar8,sel_release,pcVar3);
  }
  else {
    _objc_exception_extract(local_6c);
    _objc_exception_try_enter(local_6c);
    iVar2 = __setjmp(local_6c);
    if ((iVar2 != 0) && (iVar2 = _objc_exception_extract(local_6c), iVar2 != 0)) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar2);
    }
  }
  _objc_exception_try_exit(local_6c);
  pvVar6 = _objc_msgSend(local_14->_textureNamesMap,sel_objectEnumerator);
  pHVar1 = local_14;
  pvVar7 = _objc_msgSend(cls_NSMenu,sel_alloc);
  pcVar10 = &cfstr_Texture_Names;
  pvVar7 = _objc_msgSend(pvVar7,sel_initWithTitle_,&cfstr_Texture_Names);
  pHVar1->_textureNamesMenu = pvVar7;
  while (pvVar7 = _objc_msgSend(pvVar6,sel_nextObject,pcVar10), pvVar7 != (id)0x0) {
    pvVar8 = _objc_msgSend(pvVar7,sel_objectForKey_,&cfstr_Texture_Name);
    pvVar7 = local_14->_textureNamesMenu;
    pvVar9 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar10 = _objc_msgSend(pvVar9,sel_localizedStringForKey_value_table_,pvVar8,pvVar8,
                            &cfstr_Dialogs);
    _objc_msgSend(pvVar7,sel_addItemWithTitle_action_keyEquivalent_,pcVar10,0,&cfstr_empty);
  }
  _objc_msgSend(local_14->_texturePopUpButton,sel_setMenu_,local_14->_textureNamesMenu);
  _objc_msgSend(local_14->_texturePopUpButton,sel_selectItemAtIndex_,0);
  return;
}

*/
- (void)didLoadNib
{
    [super didLoadNib];
    @try {
        NSString *directory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Textures"];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directory];
        NSArray *imageTypes = [NSImage imageFileTypes];
        BOOL isDirectory = NO;
        NSMutableArray *entries = [NSMutableArray new];
        NSString *file;
        while ((file = [enumerator nextObject]) != nil) {
            NSString *path = [directory stringByAppendingPathComponent:file];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
                if ([imageTypes containsObject:[file pathExtension]]) {
                    [entries addObject:[NSDictionary dictionaryWithObjectsAndKeys:[file stringByDeletingPathExtension], @"Texture Name", path, @"Texture Path", nil]];
                }
            }
        }
        if ([entries count] == 0) {
            _textureNamesMap = nil;
        } else {
            _textureNamesMap = [[entries sortedArrayUsingFunction:HSTextureNameCompare context:NULL] retain];
        }
        [entries release];
    } @catch (id exception) {
    }
    NSEnumerator *enumerator = [_textureNamesMap objectEnumerator];
    _textureNamesMenu = [[NSMenu alloc] initWithTitle:@"Texture Names"];
    NSDictionary *entry;
    while ((entry = [enumerator nextObject]) != nil) {
        NSString *name = [entry objectForKey:@"Texture Name"];
        [_textureNamesMenu addItemWithTitle:[[NSBundle mainBundle] localizedStringForKey:name value:name table:@"Dialogs"] action:NULL keyEquivalent:@""];
    }
    [_texturePopUpButton setMenu:_textureNamesMenu];
    [_texturePopUpButton selectItemAtIndex:0];
}

- (void)revertSettingsToDefault
{
    [[self effect] setDefaults];
    [_reliefSlider setFloatValue:(float)([self reliefValue] * [_reliefSlider maxValue])];
    [_scaleSlider setFloatValue:(float)((([self scale] + -0.5) / 1.5) * [_reliefSlider maxValue])];
    [_lightDirectionPopUpButton selectItemAtIndex:[self lightDirection] + -1];
    [_styleSwitch setState:(unsigned int)([self isInverted])];
    [_texturePopUpButton selectItemAtIndex:0];
    [self update];
}

- (NSUInteger)lightDirection
{
    return (unsigned int)[[[self effect] valueForKey:HSTEEmbossKey] unsignedIntValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d34dc @ 001d34dc, 136 bytes * /

void FUN_001d34dc(HSTexturizerEffectController *self,SEL _cmd,uint setLightDirection)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_effect);
  uVar1 = *(undefined4 *)PTR_0033673c;
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,setLightDirection);
  _objc_msgSend(self_00,sel_setValue_forKey_,pvVar2,uVar1);
  _objc_msgSend(self,sel_update);
  return;
}

*/
- (void)setLightDirection:(NSUInteger)aDirection
{
    [[self effect] setValue:[NSNumber numberWithUnsignedInt:(unsigned int)aDirection] forKey:HSTEEmbossKey];
    [self update];
}

- (BOOL)isInverted
{
    return (BOOL)[[[self effect] valueForKey:HSTEInversionFlagKey] boolValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d33fa @ 001d33fa, 135 bytes * /

void FUN_001d33fa(HSTexturizerEffectController *self,SEL _cmd,BOOL setInverted)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_effect);
  uVar1 = *(undefined4 *)PTR_00336740;
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(byte)setInverted);
  _objc_msgSend(self_00,sel_setValue_forKey_,pvVar2,uVar1);
  _objc_msgSend(self,sel_update);
  return;
}

*/
- (void)setInverted:(BOOL)aInverted
{
    [[self effect] setValue:[NSNumber numberWithBool:aInverted] forKey:HSTEInversionFlagKey];
    [self update];
}

- (CGFloat)scale
{
    return (float)[[[self effect] valueForKey:HSTEScaleKey] floatValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d3372 @ 001d3372, 136 bytes * /

void FUN_001d3372(HSTexturizerEffectController *self,SEL _cmd,float setScale)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_effect);
  uVar1 = *(undefined4 *)PTR_00336748;
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,(double)setScale);
  _objc_msgSend(self_00,sel_setValue_forKey_,pvVar2,uVar1);
  _objc_msgSend(self,sel_update);
  return;
}

*/
- (void)setScale:(CGFloat)aScale
{
    [[self effect] setValue:[NSNumber numberWithDouble:aScale] forKey:HSTEScaleKey];
    [self update];
}

- (CGFloat)reliefValue
{
    return (float)[[[self effect] valueForKey:HSTEReliefKey] floatValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d32ea @ 001d32ea, 136 bytes * /

void FUN_001d32ea(HSTexturizerEffectController *self,SEL _cmd,float setReliefValue)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_effect);
  uVar1 = *(undefined4 *)PTR_00336744;
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,(double)setReliefValue);
  _objc_msgSend(self_00,sel_setValue_forKey_,pvVar2,uVar1);
  _objc_msgSend(self,sel_update);
  return;
}

*/
- (void)setReliefValue:(CGFloat)aValue
{
    [[self effect] setValue:[NSNumber numberWithDouble:aValue] forKey:HSTEReliefKey];
    [self update];
}

- (id)texture
{
    return [[self effect] valueForKey:HSTETextureImageKey];
}

- (void)setTexture:(id)aTexture
{
    [[self effect] setValue:aTexture forKey:HSTETextureImageKey];
    [self update];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (id)loadTextureAtPath:(id)aPath
{
    id self_01;
    NSInteger pvVar2;
    NSInteger pvVar3;
    float fVar4;
    id pvVar1_3;

    if (aPath != nil) {
        self_01 = [NSBitmapImageRep imageRepWithData:[NSData dataWithContentsOfMappedFile:aPath]];
        if (self_01 != nil) {
            pvVar2 = [self_01 pixelsHigh];
            pvVar3 = [self_01 pixelsWide];
            if (((float)(int)pvVar3 != 0.0) && (fVar4 = (float)(int)pvVar2, fVar4 != 0.0)) {
                pvVar1_3 = [[NSImage alloc] initWithSize:NSMakeSize((float)(int)pvVar3, fVar4)];
                [pvVar1_3 addRepresentation:self_01];
                if ([pvVar1_3 isValid]) {
                    [pvVar1_3 autorelease];
                    return pvVar1_3;
                }
                [pvVar1_3 release];
            }
        }
    }
    return nil;
}
#pragma clang diagnostic pop

- (id)undoActionName
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Texturizer" value:@"" table:@"UndoManager"];
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"ApplyGraphicEffect" value:@"" table:@"UndoManager"], pvVar1_2];
}

- (id)nibName
{
    return @"TexturizerEffectController";
}

- (void)dealloc
{
    [_textureNamesMenu release];
    [_textureNamesMap release];
    [super dealloc];
}

@end

