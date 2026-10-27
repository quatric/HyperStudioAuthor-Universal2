#import "HSEffectTool.h"

@implementation HSEffectTool

/* i386 ivar offsets: _effect=0x10, _intencity=0x14, _previewInputImage=0x18, _dragCardCanvasLayer=0x1c */

- (id)effectDisplayName
{
    return [_effect displayName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00151e6a @ 00151e6a, 110 bytes * /

id FUN_00151e6a(HSEffectTool *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_previewInputImage);
  pvVar2 = _objc_msgSend(pvVar1,sel_size);
  pvVar1 = _objc_msgSend(self,sel_applyEffectToImage_atPoint_frameSize_,pvVar1,0x42480000,0x42480000
                         ,pvVar2,extraout_EDX);
  return pvVar1;
}

*/
- (id)effectPreviewImage
{
    id input = [self previewInputImage];
    return [self applyEffectToImage:input atPoint:NSMakePoint(50.0f, 50.0f) frameSize:[input size]];
    return 0;
}

- (id)effect
{
    return _effect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00151db9 @ 00151db9, 177 bytes * /

id FUN_00151db9(HSEffectTool *self,SEL _cmd,NSPoint defaultEffectSettings,float intencity)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar2 = _objc_msgSend(cls_HSEffectSettings,sel_sharedSettings);
  uVar1 = *(undefined4 *)PTR_PTR_0033624c;
  pvVar3 = _objc_msgSend(self->_effect,sel_category);
  pvVar4 = _objc_msgSend(self->_effect,sel_name);
  pvVar2 = _objc_msgSend(pvVar2,sel_defaultSettingsForName_category_center_intencity_identifier_,
                         pvVar4,pvVar3,defaultEffectSettings.x,defaultEffectSettings.y,intencity,
                         uVar1);
  return pvVar2;
}

*/
- (id)defaultEffectSettings:(NSPoint)aSettings intencity:(CGFloat)aIntencity
{
    return [[HSEffectSettings sharedSettings] defaultSettingsForName:[_effect name] category:[_effect category] center:aSettings intencity:aIntencity identifier:@"HSEffectTool"];
    return 0;
}

- (id)previewInputImage
{
    id pvVar2;
    NSString *pvVar2_4;

    pvVar2 = _previewInputImage;
    if (pvVar2 == nil) {
        pvVar2_4 = [[NSBundle bundleForClass:[self class]] pathForResource:@"EffectPreviewInput" ofType:@"jpg"];
        if (pvVar2_4 == nil) {
            pvVar2 = _previewInputImage;
        }
        else {
            pvVar2 = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:pvVar2_4];
            _previewInputImage = pvVar2;
        }
    }
    return pvVar2;
}

- (void)setEffectIntencity:(CGFloat)aIntencity
{
    _intencity = aIntencity;
}

- (CGFloat)effectIntencity
{
    return _intencity;
}

- (BOOL)isIntencitySupported
{
    return (BOOL)[[HSEffectSettings sharedSettings] isIntencitySupportedForName:[_effect name]];
}

- (id)effectName
{
    return [_effect name];
}

- (void)setEffectName:(id)aName
{
    NSString *pvVar1;

    if (aName != nil) {
        pvVar1 = [_effect name];
        if (![pvVar1 isEqualToString:aName]) {
            [_effect release];
            _effect = [[HSEffect effectWithName:aName] retain];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00151a18 @ 00151a18, 427 bytes * /

BOOL FUN_00151a18(HSEffectTool *self,SEL _cmd,id wantsToSwitchToolInToolCanvasLayer,id event,
                 NSPoint viewPoint,int *newToolTag,int *newTemplateIndex,BOOL *skipToolApplying)

{
  BOOL BVar1;
  id pvVar2;
  undefined4 *puVar3;
  id pvVar4;
  BOOL BVar5;
  undefined *puVar6;
  undefined *puVar7;
  
  pvVar2 = _objc_msgSend(wantsToSwitchToolInToolCanvasLayer,sel_context);
  pvVar2 = _objc_msgSend(pvVar2,sel_canvasHitTester);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0037428c);
  pvVar2 = _objc_msgSend(pvVar2,sel_hitTestNodeAtPoint_,viewPoint.x,viewPoint.y);
  puVar3 = (undefined4 *)PTR_PTR_00336248;
  if (pvVar2 == (id)0x0) {
    puVar3 = (undefined4 *)PTR_PTR_0033624c;
  }
  puVar7 = (undefined *)*puVar3;
  pvVar4 = _objc_msgSend(self,sel_toolIdentifier,viewPoint.x,viewPoint.y);
  puVar6 = puVar7;
  pvVar4 = _objc_msgSend(pvVar4,sel_isEqual_,puVar7);
  if ((char)pvVar4 != '\0') {
    BVar1 = '\0';
    BVar5 = '\0';
    goto LAB_00151bad;
  }
  if (puVar7 == *(undefined **)PTR_PTR_0033624c) {
LAB_00151b38:
    if (newToolTag != (int *)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,puVar7,viewPoint.y);
      *newToolTag = (int)pvVar2;
      puVar6 = puVar7;
    }
    if (newTemplateIndex != (int *)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar6);
      pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
      pvVar2 = _objc_msgSend(pvVar2,sel_appliedTemplateIndexForTool_,self);
      *newTemplateIndex = (int)pvVar2;
    }
    BVar5 = '\0';
    BVar1 = '\x01';
  }
  else {
    pvVar4 = _objc_msgSend(pvVar2,sel_supportsEffectPerObject,puVar6,viewPoint.y);
    if ((char)pvVar4 != '\0') {
      puVar6 = &DAT_003742dc;
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003742dc,viewPoint.y);
      pvVar2 = _objc_msgSend(pvVar2,sel_isLocked);
      if ((char)pvVar2 == '\0') goto LAB_00151b38;
    }
    BVar5 = '\x01';
    BVar1 = '\0';
  }
LAB_00151bad:
  if (skipToolApplying != (BOOL *)0x0) {
    *skipToolApplying = BVar5;
  }
  return BVar1;
}

*/
- (BOOL)wantsToSwitchToolInToolCanvasLayer:(id)aLayer event:(id)aEvent viewPoint:(NSPoint)aPoint newToolTag:(int *)aTag newTemplateIndex:(int *)aIndex skipToolApplying:(BOOL *)aApplying
{
    id hit = [[[[aLayer context] canvasHitTester] queryHyperInterface:@protocol(HSCanvasEditorHitTesting)] hitTestNodeAtPoint:aPoint];
    NSString *identifier = (hit != nil) ? @"HSEffectPerObjectTool" : @"HSEffectTool";
    BOOL result;
    BOOL skip;
    if ([[self toolIdentifier] isEqual:identifier]) {
        result = NO;
        skip = NO;
    } else {
        BOOL switchTool;
        if ([identifier isEqual:@"HSEffectTool"]) {
            switchTool = YES;
        } else {
            switchTool = ([hit supportsEffectPerObject] && ![[hit queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]);
        }
        if (switchTool) {
            if (aTag != NULL) {
                *aTag = (int)[HSToolManager toolTagForIdentifier:identifier];
            }
            if (aIndex != NULL) {
                *aIndex = (int)[[[HSToolManager sharedToolManager] toolSettings] appliedTemplateIndexForTool:self];
            }
            skip = NO;
            result = YES;
        } else {
            skip = YES;
            result = NO;
        }
    }
    if (aApplying != NULL) {
        *aApplying = skip;
    }
    return result;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001519e3 @ 001519e3, 53 bytes * /

id FUN_001519e3(HSEffectTool *self,SEL _cmd,id cursorForToolCanvasLayer)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336608);
  return pvVar1;
}

*/
- (id)cursorForToolCanvasLayer:(id)aLayer
{
    return [HSCursor cursorNamed:@"HSMagicWandCursor"];
    return 0;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector inToolCanvasLayer:(id)aLayer
{
    return NO;
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint inToolCanvasLayer:(id)aLayer
{
    return NO;
}

- (BOOL)handleMouseMoved:(id)aMoved inToolCanvasLayer:(id)aLayer
{
    return NO;
}

- (void)handleAutoscrollingWithMouseEvent:(id)aEvent whileTrackingInToolCanvasLayer:(id)aLayer
{

}

- (BOOL)wantsAutoscrollingWhileTrackingInToolCanvasLayer:(id)aLayer
{
    return NO;
}

- (void)handleFlagsChanged:(id)aChanged whileTrackingInToolCanvasLayer:(id)aLayer
{

}

- (void)handleMouseUp:(id)aUp whileTrackingInToolCanvasLayer:(id)aLayer
{

}

- (void)handleMouseDragged:(id)aDragged whileTrackingInToolCanvasLayer:(id)aLayer
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00151f64 @ 00151f64, 1620 bytes * /

void FUN_00151f64(HSEffectTool *self,SEL _cmd,id handleMouseDown,id whileTrackingInToolCanvasLayer)

{
  HSEffectTool *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  id self_02;
  int iVar5;
  int iVar6;
  id pvVar7;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  float fVar8;
  float fVar9;
  undefined **ppuVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  float fVar13;
  float local_c0;
  undefined *local_80;
  undefined4 local_7c;
  id local_78;
  int local_74 [23];
  id local_18;
  HSEffectTool *local_14;
  
  local_14 = self;
  local_18 = handleMouseDown;
  if (self->_effect == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(handleMouseDown,sel_clickCount);
  if (pvVar1 != (id)0x1) {
    return;
  }
  pvVar1 = _objc_msgSend(local_14,sel_view);
  pvVar1 = _objc_msgSend(pvVar1,sel_card);
  local_78 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00374430);
  if (local_78 == (id)0x0) {
    return;
  }
  local_80 = &DAT_0037446c;
  local_7c = 0;
  ppuVar10 = &local_80;
  uVar11 = 0;
  pvVar1 = _objc_msgSend(local_78,sel_queryImageWithRequiredProtocols_optionalProtocols_,ppuVar10,0)
  ;
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(local_14,sel_view,ppuVar10,uVar11);
  pvVar3 = _objc_msgSend(local_14,sel_view);
  pvVar4 = _objc_msgSend(local_18,sel_locationInWindow);
  pvVar3 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_,pvVar4,extraout_EDX,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_convertPointFromViewSpaceToUserSpace_,pvVar3,extraout_EDX_00);
  pvVar3 = _objc_msgSend(pvVar1,sel_imageSize);
  pvVar4 = _objc_msgSend(local_14,sel_view);
  pvVar4 = _objc_msgSend(pvVar4,sel_isFlipped);
  local_c0 = extraout_EDX_01;
  if ((char)pvVar4 != '\0') {
    local_c0 = extraout_EDX_02 - extraout_EDX_01;
  }
  local_80 = &DAT_00374494;
  uVar11 = 0;
  pvVar4 = _objc_msgSend(local_78,sel_queryImageWithRequiredProtocols_optionalProtocols_,&local_80,0
                        );
  self_00 = local_14;
  if (pvVar4 == (id)0x0) {
    return;
  }
  fVar8 = ((float)pvVar2 / (float)pvVar3) * 100.0;
  fVar9 = (local_c0 / extraout_EDX_02) * 100.0;
  pvVar2 = _objc_msgSend(cls_NSImage,sel_BT_imageWithBTCocoaImage_,pvVar1,uVar11);
  pvVar1 = pvVar3;
  fVar13 = extraout_EDX_02;
  self_01 = _objc_msgSend(self_00,sel_applyEffectToImage_atPoint_frameSize_,pvVar2,fVar8,fVar9,
                          pvVar3,extraout_EDX_02);
  if (self_01 == (id)0x0) {
    return;
  }
  self_02 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,pvVar2,fVar8,fVar9,pvVar1,fVar13);
  _objc_exception_try_enter(local_74);
  iVar5 = __setjmp(local_74);
  if (iVar5 == 0) {
    pvVar1 = _objc_msgSend(local_14,sel_view,pvVar2,fVar8,fVar9,pvVar1,fVar13);
    pvVar1 = _objc_msgSend(pvVar1,sel_card);
    pvVar1 = _objc_msgSend(pvVar1,sel_support);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Background_Effect,
                           &cfstr_empty,&cfstr_UndoManager);
    _objc_msgSend(pvVar1,sel_setActionName_,pvVar2);
    uVar11 = 0;
    uVar12 = 0;
    pvVar1 = pvVar4;
    pvVar2 = pvVar3;
    fVar13 = extraout_EDX_02;
    _objc_msgSend(local_78,sel_beginEditImage_inRect_,pvVar4,0,0,pvVar3,extraout_EDX_02);
    _objc_msgSend(pvVar4,sel_beginCocoaEditing);
    pvVar7 = _objc_msgSend(self_01,sel_size);
    if ((((float)pvVar7 != (float)pvVar3) || (NAN((float)pvVar7) || NAN((float)pvVar3))) ||
       (extraout_EDX_03 != extraout_EDX_02)) {
      pvVar1 = _objc_msgSend(cls_NSColor,sel_whiteColor,pvVar1,uVar11,uVar12,pvVar2,fVar13);
      _objc_msgSend(pvVar1,sel_set);
      _objc_msgSend(cls_NSBezierPath,sel_fillRect_,0,0,pvVar3,extraout_EDX_02);
    }
    _objc_msgSend(self_01,sel_drawAtPoint_fromRect_operation_fraction_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4),(int)*(undefined8 *)PTR_00336078,
                  (int)((ulonglong)*(undefined8 *)PTR_00336078 >> 0x20),
                  (int)*(undefined8 *)(PTR_00336078 + 8),
                  (int)((ulonglong)*(undefined8 *)(PTR_00336078 + 8) >> 0x20),2,0x3f800000);
    _objc_msgSend(pvVar4,sel_endCocoaEditing);
    _objc_msgSend(local_78,sel_endEditImage);
  }
  else {
    iVar6 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar5 = __setjmp(local_74);
    if (iVar5 == 0) {
      iVar5 = _objc_exception_match(cls_NSException,iVar6);
      if (iVar5 != 0) goto LAB_0015258f;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar6 = _objc_exception_extract(local_74);
    }
    if (iVar6 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar6);
    }
  }
LAB_0015258f:
  _objc_exception_try_exit(local_74);
  _objc_msgSend(self_02,sel_release);
  return;
}

*/
- (void)handleMouseDown:(id)aDown whileTrackingInToolCanvasLayer:(id)aLayer
{
    if (_effect == nil || [aDown clickCount] != 1) {
        return;
    }
    id<HSEditableImageAttributes> editable = [[[self view] card] queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editable == nil) {
        return;
    }
    id requiredCocoa[] = { @protocol(BTCocoaImage), nil };
    id image = [editable queryImageWithRequiredProtocols:requiredCocoa optionalProtocols:nil];
    if (image == nil) {
        return;
    }
    NSPoint viewPoint = [[self view] convertPoint:[aDown locationInWindow] fromView:nil];
    NSPoint point = [[self view] convertPointFromViewSpaceToUserSpace:viewPoint];
    NSSize size = [image imageSize];
    float y = point.y;
    if ([[self view] isFlipped]) {
        y = size.height - point.y;
    }
    id requiredMutable[] = { @protocol(BTCocoaMutableImage), nil };
    id mutableImage = [editable queryImageWithRequiredProtocols:requiredMutable optionalProtocols:nil];
    if (mutableImage == nil) {
        return;
    }
    float percentX = (point.x / size.width) * 100.0f;
    float percentY = (y / size.height) * 100.0f;
    NSImage *source = [NSImage BT_imageWithBTCocoaImage:image];
    NSImage *result = [self applyEffectToImage:source atPoint:NSMakePoint(percentX, percentY) frameSize:size];
    if (result == nil) {
        return;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    @try {
        NSUndoManager *undoManager = [[[[self view] card] support] undoManager];
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Background Effect" value:@"" table:@"UndoManager"]];
        [editable beginEditImage:mutableImage inRect:NSMakeRect(0.0f, 0.0f, size.width, size.height)];
        [mutableImage beginCocoaEditing];
        NSSize resultSize = [result size];
        if (resultSize.width != size.width || resultSize.height != size.height) {
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:NSMakeRect(0.0f, 0.0f, size.width, size.height)];
        }
        [result drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0f];
        [mutableImage endCocoaEditing];
        [editable endEditImage];
    } @catch (NSException *exception) {
    }
    [pool release];
}

- (id)applyEffectToImage:(id)aImage atPoint:(NSPoint)aPoint frameSize:(NSSize)aSize
{
    id pvVar1;
    id pvVar2;
    NSString *pvVar3;
    id pvVar4;
    id pvVar5;

    pvVar5 = _effect;
    pvVar1 = [HSEffectSettings sharedSettings];
    pvVar2 = [_effect category];
    pvVar3 = [_effect name];
    pvVar4 = [self defaultEffectSettings:aPoint intencity:(float)[self effectIntencity]]
    ;
    [pvVar5 setAttributes:[pvVar1 adjustedSettings:pvVar4 forName:pvVar3 category:pvVar2 frameSize:aSize]];
    [_effect setInputImage:aImage];
    return [_effect outputImage];
}

- (BOOL)wantsToTrackMouseInToolCanvasLayer:(id)aLayer
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001526f9 @ 001526f9, 321 bytes * /

void FUN_001526f9(HSEffectTool *self,SEL _cmd,BOOL finalizeBeforeDeactivateExplicitly)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id self_02;
  HSEffectTool *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_view);
  pvVar1 = _objc_msgSend(pvVar1,sel_rootCanvasLayer);
  self_00 = _objc_msgSend(pvVar1,sel_bitmapToolsCanvasLayer);
  self_01 = _objc_msgSend(pvVar1,sel_vectorToolsCanvasLayer);
  if (self->_dragCardCanvasLayer != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_dragCardCanvasLayer,sel_parentLayer);
    if (pvVar2 == self_00) {
      pvVar2 = self->_dragCardCanvasLayer;
      self_02 = self_00;
    }
    else {
      if (pvVar2 != self_01) goto LAB_001527b5;
      pvVar2 = self->_dragCardCanvasLayer;
      self_02 = self_01;
    }
    _objc_msgSend(self_02,sel_removeSublayer_,pvVar2);
  }
LAB_001527b5:
  _objc_msgSend(pvVar1,sel_setEnabledSublayerIdentifiers_,0);
  _objc_msgSend(self_00,sel_setTool_,0);
  _objc_msgSend(self_01,sel_setTool_,0);
  local_1c = self;
  local_18 = PTR_s_HSTool_00351980;
  _objc_msgSendSuper(&local_1c,sel_finalizeBeforeDeactivateExplicitly_,
                     (int)finalizeBeforeDeactivateExplicitly);
  return;
}

*/
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id rootLayer = [[self view] rootCanvasLayer];
    id bitmapLayer = [rootLayer bitmapToolsCanvasLayer];
    id vectorLayer = [rootLayer vectorToolsCanvasLayer];
    if (_dragCardCanvasLayer != nil) {
        id parent = [_dragCardCanvasLayer parentLayer];
        if (parent == bitmapLayer) {
            [bitmapLayer removeSublayer:_dragCardCanvasLayer];
        } else if (parent == vectorLayer) {
            [vectorLayer removeSublayer:_dragCardCanvasLayer];
        }
    }
    [rootLayer setEnabledSublayerIdentifiers:nil];
    [bitmapLayer setTool:nil];
    [vectorLayer setTool:nil];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id self_00;
    id self_01;
    id pvVar1_2;

    self_00 = [[self view] rootCanvasLayer];
    self_01 = [self_00 bitmapToolsCanvasLayer];
    pvVar1_2 = _dragCardCanvasLayer;
    if (pvVar1_2 == nil) {
        pvVar1_2 = [HSDragCardViewCanvasLayer new];
        _dragCardCanvasLayer = pvVar1_2;
    }
    if (pvVar1_2 != nil) {
        [self_01 addSublayer:pvVar1_2];
    }
    [self_00 setEnabledSublayerIdentifiers:[self_00 bitmapToolsIdentifiers]];
    [self_01 setTool:self];
}

- (id)settingsIdentifiers
{
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:HSToolEffectIntencityAttributeKey, nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00151898 @ 00151898, 19 bytes * /

id FUN_00151898(HSEffectTool *self,SEL _cmd)

{
  return *(id *)PTR_PTR_0033624c;
}

*/
- (id)primarySettingsIdentifier
{
    return @"HSEffectTool";
    return 0;
}

- (void)dealloc
{
    [_effect release];
    [_dragCardCanvasLayer release];
    [super dealloc];
}

@end

