#import "HSEditorCardView.h"

@implementation HSEditorCardView

/* i386 ivar offsets: _zoomMode=0x1bc, _cardOffset=0x1c0, _poofPointsQueue=0x1c8, _liveResizeRecacheTimer=0x1cc, _rectVisuallyObscuredBySuperview=0x1d0, _additionalContentRect=0x1e0, _editObjectDialogContext=0x1f0, _gridSettings=0x1f4, _guidelinesSettings=0x1f8, _colorPickingCanvasLayer=0x1fc, _colorPickingDelegate=0x200, _colorPickingDelegateDidEndSelector=0x204, _numberOfRunningPoofEffects=0x208, _backgroundColor=0x20c, _dragHelper=0x210, _cacheOnlyRendering=0x214, _isColorPickingModeActive=0x214, _isObjectsLayoutReflected=0x214, _didDrawBitmapToolsLayer=0x214, _lightweightChangeProcessingModeCounter=0x218, _lastActiveWindow=0x21c, _previousOnionSkinUserObject=0x220, _nextOnionSkinUserObject=0x224, _cardObjects=0x228, _initialFontSize=0x22c, _initialWidth=0x230, _initialHeight=0x234, _needOpenHelpPane=0x238, _newActionDropHelpPane=0x23c, _attributesForSelectedTextObject=0x240, _newOnionSkinModeIsInRenderingProcess=0x244, _ignoreNextMouseDown=0x245 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00003768 @ 00003768, 447 bytes * /

void FUN_00003768(HSEditorCardView *self,SEL _cmd,id magnifyWithEvent)

{
  float fVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float fVar3;
  float fVar4;
  float fVar5;
  double dVar6;
  double dVar7;
  double dVar8;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(pvVar2,sel_nodesCount);
  if (pvVar2 == (id)0x0) {
    dVar6 = _objc_msgSend_fpret(self,sel_zoomFactor);
    dVar7 = _objc_msgSend_fpret(magnifyWithEvent,sel_magnification);
    dVar8 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_minZoomFactor);
    fVar1 = (float)dVar6;
    dVar6 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_maxZoomFactor);
    fVar4 = (float)dVar8;
    if ((float)dVar8 <= (float)dVar7 + fVar1) {
      fVar4 = (float)dVar7 + fVar1;
    }
    fVar3 = (float)dVar6;
    if (fVar4 <= (float)dVar6) {
      fVar3 = fVar4;
    }
    if ((fVar3 != 0.0) || (NAN(fVar3))) {
      fVar4 = ABS(fVar3);
    }
    else {
      fVar4 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar5 = ABS(fVar1);
    }
    else {
      fVar5 = 1.0;
    }
    if (fVar5 <= fVar4) {
      fVar5 = fVar4;
    }
    if (fVar5 * 0.0005 < ABS(fVar3 - fVar1)) {
      pvVar2 = _objc_msgSend(magnifyWithEvent,sel_locationInWindow);
      pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
      _objc_msgSend(self,sel_zoomToFactor_aboutPoint_,fVar3,pvVar2,extraout_EDX_00);
    }
  }
  else {
    local_1c = self;
    local_18 = PTR_s_HSToolView_0034db70;
    _objc_msgSendSuper(&local_1c,sel_magnifyWithEvent_,magnifyWithEvent);
  }
  return;
}

*/
- (void)showInspector:(id)aInspector
{
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
}

- (void)editText:(id)aText
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self selectedHyperObject];
    if ([self startEditorForObject:pvVar1 creationMode:NO]) {
        if ([[self runTimeEditorController] selectedRunTimeEditorObject] != nil) {
            pvVar1_2 = [HSObjectAssistantController sharedAssistantController];
            [pvVar1_2 setSelectedInModelObjectAndBringAssistantToFront:[[self runTimeEditorController] selectedRunTimeEditorObject]];
            [pvVar1_2 setActive:YES explicitlyByUser:YES];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:HSForceSOTSForObjectDoubleClickKey]) {
                [[[HSObjectAssistantController sharedAssistantController] objectAssistant] setPrefersInspectorMode:NO];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00003ae6 @ 00003ae6, 880 bytes * /

BOOL FUN_00003ae6(HSEditorCardView *self,SEL _cmd,id performKeyEquivalent)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined4 *puVar5;
  undefined1 local_3c [16];
  undefined1 local_2c [16];
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  puVar5 = (undefined4 *)&stack0xffffffb4;
  pvVar2 = _objc_msgSend(self,sel_runTimeEditorController);
  pvVar2 = _objc_msgSend(pvVar2,sel_selectedRunTimeEditorObject);
  if (pvVar2 != (id)0x0) {
    local_1c = self;
    local_18 = PTR_s_HSToolView_0034db70;
    pvVar2 = _objc_msgSendSuper(&local_1c,sel_performKeyEquivalent_);
    return (BOOL)pvVar2;
  }
  pvVar2 = _objc_msgSend(performKeyEquivalent,sel_BT_keyBindingCharacters);
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_);
    if (((char)pvVar3 == '\0') &&
       (pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_), (char)pvVar3 == '\0')) {
      pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_);
      if (((char)pvVar3 == '\0') &&
         (pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_), (char)pvVar2 == '\0')) {
        return '\0';
      }
      pvVar2 = _objc_msgSend(self,sel_canHandleKeyBindingCharactersBySelectedObject);
      if ((char)pvVar2 != '\0') {
LAB_00003b75:
        pvVar2 = _objc_msgSend(self,sel_handleKeyBindingCharactersBySelectedObject_);
        return (BOOL)pvVar2;
      }
      pvVar2 = _objc_msgSend(self,sel_HSEditorCardView_selectedTextObject);
      if (pvVar2 != (id)0x0) {
        return '\0';
      }
      _objc_msgSend_stret(local_3c,self,sel_HSEditorCardView_selectionGeometryBounds);
      puVar5 = (undefined4 *)&stack0xffffffb0;
      cVar1 = _NSIsEmptyRect();
      puVar4 = sel_zoomOut;
      if (cVar1 == '\0') {
        _objc_msgSend(self,sel_convertPointFromUserSpaceToViewSpace_);
LAB_00003cfa:
        puVar5 = (undefined4 *)&stack0xffffffb0;
        goto LAB_00003bd6;
      }
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_canHandleKeyBindingCharactersBySelectedObject);
      if ((char)pvVar2 != '\0') goto LAB_00003b75;
      pvVar2 = _objc_msgSend(self,sel_HSEditorCardView_selectedTextObject);
      if (pvVar2 != (id)0x0) {
        return '\0';
      }
      _objc_msgSend_stret(local_2c,self,sel_HSEditorCardView_selectionGeometryBounds);
      puVar5 = (undefined4 *)&stack0xffffffb0;
      cVar1 = _NSIsEmptyRect();
      puVar4 = sel_zoomIn;
      if (cVar1 == '\0') {
        _objc_msgSend(self,sel_convertPointFromUserSpaceToViewSpace_);
        goto LAB_00003cfa;
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_canHandleKeyBindingCharactersBySelectedObject);
    puVar4 = cls_HSEditorZoomController;
    if ((char)pvVar2 != '\0') goto LAB_00003b75;
    _objc_msgSend_fpret(self,sel_zoomFactor);
    pvVar2 = _objc_msgSend(puVar4,sel_canZoomToActualSizeForZoomFactor_);
    puVar4 = sel_zoomToActualSize;
    if ((char)pvVar2 == '\0') {
      return '\0';
    }
  }
  *(undefined **)((int)puVar5 + 4) = puVar4;
LAB_00003bd6:
  *puVar5 = self;
  puVar5[-1] = 0x3bde;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return '\x01';
}

*/
- (BOOL)performKeyEquivalent:(id)aEquivalent
{
    if ([[self runTimeEditorController] selectedRunTimeEditorObject] != nil) {
        return [super performKeyEquivalent:aEquivalent];
    }
    NSString *chars = [aEquivalent BT_keyBindingCharacters];
    if ([chars isEqualToString:@"@0"]) {
        if ([self canHandleKeyBindingCharactersBySelectedObject]) {
            return [self handleKeyBindingCharactersBySelectedObject:chars];
        }
        if (![HSEditorZoomController canZoomToActualSizeForZoomFactor:[self zoomFactor]]) {
            return NO;
        }
        [self zoomToActualSize];
        return YES;
    }
    BOOL zoomIn = [chars isEqualToString:@"@+"] || [chars isEqualToString:@"@="];
    if (!zoomIn && ![chars isEqualToString:@"@-"] && ![chars isEqualToString:@"@_"]) {
        return NO;
    }
    if ([self canHandleKeyBindingCharactersBySelectedObject]) {
        return [self handleKeyBindingCharactersBySelectedObject:chars];
    }
    if ([self HSEditorCardView_selectedTextObject] != nil) {
        return NO;
    }
    NSRect bounds = [self HSEditorCardView_selectionGeometryBounds];
    if (!NSIsEmptyRect(bounds)) {
        NSPoint point = [self convertPointFromUserSpaceToViewSpace:NSMakePoint(NSMidX(bounds), NSMidY(bounds))];
        if (zoomIn) {
            [self zoomInAboutPoint:point];
        } else {
            [self zoomOutAboutPoint:point];
        }
    } else if (zoomIn) {
        [self zoomIn];
    } else {
        [self zoomOut];
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00003e56 @ 00003e56, 2014 bytes * /

BOOL FUN_00003e56(HSEditorCardView *self,SEL _cmd,id handleKeyBindingCharactersBySelectedObject)

{
  float fVar1;
  undefined *puVar2;
  BOOL BVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id self_00;
  id pvVar8;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  undefined4 extraout_EDX_03;
  float fVar9;
  float fVar10;
  double dVar11;
  SEL op;
  cfstringStruct *pcVar12;
  float local_2c;
  float local_28;
  float local_20;
  float local_1c;
  
  pvVar4 = _objc_msgSend(self,sel_selection);
  pvVar4 = _objc_msgSend(pvVar4,sel_nodesCount);
  if (pvVar4 != (id)0x1) {
    return '\0';
  }
  pvVar4 = _objc_msgSend(self,sel_HSEditorCardView_selectedScaledObject);
  if (pvVar4 == (id)0x0) {
    BVar3 = '\0';
    goto LAB_00004413;
  }
  pvVar5 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00360868);
  pvVar6 = _objc_msgSend(pvVar4,sel_affineFrameSize);
  pvVar7 = _objc_msgSend(pvVar5,sel_defaultSize);
  _objc_msgSend(pvVar5,sel_defaultSize);
  local_1c = (float)pvVar6 / (float)pvVar7;
  local_20 = extraout_EDX / extraout_EDX_00;
  fVar9 = SQRT(local_1c * local_20);
  pvVar6 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,&cfstr__0);
  local_28 = *(float *)PTR_0033607c;
  local_2c = *(float *)(PTR_0033607c + 4);
  if ((char)pvVar6 == '\0') {
    pcVar12 = &cfstr___;
    pvVar6 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,&cfstr___
                          );
    if ((char)pvVar6 == '\0') {
      pcVar12 = &cfstr___;
      pvVar6 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                             &cfstr___);
      if ((char)pvVar6 != '\0') goto LAB_00003ff4;
      pcVar12 = &cfstr___;
      pvVar6 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                             &cfstr___);
      if ((char)pvVar6 == '\0') {
        pcVar12 = &cfstr___;
        pvVar6 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                               &cfstr___);
        if ((char)pvVar6 == '\0') goto LAB_000040d9;
      }
      _objc_msgSend(pvVar5,sel_defaultSize,pcVar12);
      fVar10 = -0.01;
      local_2c = extraout_EDX_02;
    }
    else {
LAB_00003ff4:
      _objc_msgSend(pvVar5,sel_defaultSize,pcVar12);
      fVar10 = 0.01;
      local_2c = extraout_EDX_01;
    }
    fVar10 = (fVar10 + fVar9) / fVar9;
    local_20 = local_20 * fVar10;
    local_2c = local_2c * local_20;
    local_1c = local_1c * fVar10;
    pvVar5 = _objc_msgSend(pvVar5,sel_defaultSize,pcVar12);
    local_28 = (float)pvVar5 * local_1c;
  }
  else {
    local_28 = *(float *)((int)&self->_initialFontSize + 1);
    local_2c = *(float *)((int)&self->_initialWidth + 1);
  }
LAB_000040d9:
  if ((local_1c != 0.0) || (NAN(local_1c))) {
    fVar10 = ABS(local_1c);
  }
  else {
    fVar10 = 1.0;
  }
  fVar1 = 0.01;
  if (0.01 <= fVar10) {
    fVar1 = fVar10;
  }
  if (fVar1 * -0.0005 + 0.01 <= local_1c) {
    if ((local_20 != 0.0) || (NAN(local_20))) {
      fVar10 = ABS(local_20);
    }
    else {
      fVar10 = 1.0;
    }
    fVar1 = 0.01;
    if (0.01 <= fVar10) {
      fVar1 = fVar10;
    }
    if (local_20 < fVar1 * -0.0005 + 0.01) goto LAB_00004128;
    if ((local_1c != 0.0) || (NAN(local_1c))) {
      fVar10 = ABS(local_1c);
    }
    else {
      fVar10 = 1.0;
    }
    fVar1 = 8.0;
    if (8.0 <= fVar10) {
      fVar1 = fVar10;
    }
    if (fVar1 * 0.0005 + 8.0 < local_1c) goto LAB_00004128;
    if ((local_20 != 0.0) || (NAN(local_20))) {
      fVar10 = ABS(local_20);
    }
    else {
      fVar10 = 1.0;
    }
    fVar1 = 8.0;
    if (8.0 <= fVar10) {
      fVar1 = fVar10;
    }
    if (fVar1 * 0.0005 + 8.0 < local_20) goto LAB_00004128;
    pvVar5 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00360d18);
    pvVar5 = _objc_msgSend(pvVar5,sel_queryGeometryBehaviorApplier);
    _objc_msgSend(pvVar5,
                  sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                  ,local_28,local_2c,0x3f000000,0x3f000000,1,2,0,0);
    BVar3 = '\x01';
  }
  else {
LAB_00004128:
    BVar3 = '\0';
  }
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00360570);
  if (pvVar4 != (id)0x0) {
    pvVar5 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,&cfstr__0
                          );
    if ((char)pvVar5 == '\0') {
      pvVar5 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                             &cfstr___);
      if (((char)pvVar5 == '\0') &&
         (pvVar5 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                                 &cfstr___), (char)pvVar5 == '\0')) {
        pvVar5 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                               &cfstr___);
        if (((char)pvVar5 == '\0') &&
           (pvVar5 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,
                                   &cfstr___), (char)pvVar5 == '\0')) goto LAB_00004413;
        dVar11 = _objc_msgSend_fpret(pvVar4,sel_hyperFontSize);
        fVar9 = ((fVar9 + -0.01) / fVar9) * (float)dVar11;
      }
      else {
        dVar11 = _objc_msgSend_fpret(pvVar4,sel_hyperFontSize);
        fVar9 = ((fVar9 + 0.01) / fVar9) * (float)dVar11;
      }
      _objc_msgSend(pvVar4,sel_setHyperFontSize_,fVar9);
    }
    else {
      _objc_msgSend(pvVar4,sel_setHyperFontSize_,*(undefined4 *)((int)&self->_cardObjects + 1));
      BVar3 = '\x01';
    }
  }
LAB_00004413:
  pvVar4 = _objc_msgSend(self,sel_HSEditorCardView_selectedTextObject);
  if (pvVar4 != (id)0x0) {
    pcVar12 = &cfstr__0;
    pvVar5 = _objc_msgSend(handleKeyBindingCharactersBySelectedObject,sel_isEqualToString_,&cfstr__0
                          );
    if ((char)pvVar5 != '\0') {
      pvVar5 = _objc_msgSend(pvVar4,sel_hyperText,pcVar12);
      pvVar5 = _objc_msgSend(pvVar5,sel_length);
      pvVar6 = _objc_msgSend(self,sel_attributesForSelectedTextObject);
      if (pvVar5 == (id)0x0) {
        pvVar5 = _objc_msgSend(pvVar6,sel_allValues,pcVar12);
        pvVar5 = _objc_msgSend(pvVar5,sel_lastObject);
        op = sel_applyHyperTextAttributesDictionary_;
        if (pvVar5 == (id)0x0) {
          return '\x01';
        }
      }
      else {
        pvVar7 = _objc_msgSend(pvVar6,sel_keyEnumerator,pcVar12);
        pvVar6 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
        pvVar5 = _objc_msgSend(pvVar4,sel_hyperText);
        self_00 = _objc_msgSend(pvVar6,sel_initWithAttributedString_,pvVar5);
        pvVar6 = _objc_msgSend(pvVar7,sel_nextObject);
        puVar2 = PTR_00336068;
        while (pvVar6 != (id)0x0) {
          pvVar8 = _objc_msgSend(self,sel_attributesForSelectedTextObject,pvVar5);
          pvVar5 = pvVar6;
          pvVar8 = _objc_msgSend(pvVar8,sel_objectForKey_);
          if (pvVar8 != (id)0x0) {
            pvVar6 = _objc_msgSend(pvVar6,sel_rangeValue,pvVar5);
            pvVar5 = *(id *)puVar2;
            _objc_msgSend(self_00,sel_addAttribute_value_range_,pvVar5,pvVar8,pvVar6,extraout_EDX_03
                         );
          }
          pvVar6 = _objc_msgSend(pvVar7,sel_nextObject,pvVar5);
        }
        pvVar5 = self_00;
        _objc_msgSend(pvVar4,sel_setHyperText_,self_00);
        pvVar4 = self_00;
        op = sel_release;
      }
      _objc_msgSend(pvVar4,op,pvVar5);
      BVar3 = '\x01';
    }
  }
  return BVar3;
}

*/
- (BOOL)handleKeyBindingCharactersBySelectedObject:(id)aObject
{
    if ([[self selection] nodesCount] != 1) {
        return NO;
    }
    id scaledObject = [self HSEditorCardView_selectedScaledObject];
    if (scaledObject == nil) {
        return NO;
    }
    BOOL handled;
    id geometry = [scaledObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    NSSize frameSize = [scaledObject affineFrameSize];
    NSSize defaultSize = [geometry defaultSize];
    float scaleX = frameSize.width / defaultSize.width;
    float scaleY = frameSize.height / defaultSize.height;
    float scale = sqrtf(scaleX * scaleY);
    BOOL isReset = [aObject isEqualToString:@"@0"];
    BOOL isGrow = [aObject isEqualToString:@"@+"] || [aObject isEqualToString:@"@="];
    BOOL isShrink = [aObject isEqualToString:@"@-"] || [aObject isEqualToString:@"@_"];
    NSSize newSize = NSZeroSize;
    if (isReset) {
        newSize = NSMakeSize(_initialWidth, _initialHeight);
    } else if (isGrow || isShrink) {
        float factor = ((isGrow ? 0.01f : -0.01f) + scale) / scale;
        scaleY = scaleY * factor;
        scaleX = scaleX * factor;
        newSize = NSMakeSize(defaultSize.width * scaleX, defaultSize.height * scaleY);
    }
#define HS_FUZZY_GE(v, limit) ((limit) - fmaxf((limit), ((v) != 0.0f || isnan(v)) ? fabsf(v) : 1.0f) * 0.0005f <= (v))
#define HS_FUZZY_LE(v, limit) (!((v) > (limit) + fmaxf((limit), ((v) != 0.0f || isnan(v)) ? fabsf(v) : 1.0f) * 0.0005f))
    if (HS_FUZZY_GE(scaleX, 0.01f) && HS_FUZZY_GE(scaleY, 0.01f) && HS_FUZZY_LE(scaleX, 8.0f) && HS_FUZZY_LE(scaleY, 8.0f)) {
        id applier = [[scaledObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        [applier resizeFrameTo:newSize aboutRelativePoint:NSMakePoint(0.5, 0.5) followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
        handled = YES;
    } else {
        handled = NO;
    }
#undef HS_FUZZY_GE
#undef HS_FUZZY_LE
    id fontAttributes = [scaledObject queryHyperInterface:@protocol(HSGenericFontAttributes)];
    if (fontAttributes != nil) {
        if (isReset) {
            [fontAttributes setHyperFontSize:_initialFontSize];
            handled = YES;
        } else if (isGrow) {
            [fontAttributes setHyperFontSize:((scale + 0.01f) / scale) * [fontAttributes hyperFontSize]];
        } else if (isShrink) {
            [fontAttributes setHyperFontSize:((scale - 0.01f) / scale) * [fontAttributes hyperFontSize]];
        }
    }
    id textObject = [self HSEditorCardView_selectedTextObject];
    if (textObject != nil && isReset) {
        NSUInteger length = [[textObject hyperText] length];
        NSDictionary *remembered = [self attributesForSelectedTextObject];
        if (length == 0) {
            id last = [[remembered allValues] lastObject];
            if (last == nil) {
                return YES;
            }
            [textObject applyHyperTextAttributesDictionary:last];
        } else {
            NSEnumerator *keys = [remembered keyEnumerator];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[textObject hyperText]];
            id key;
            while ((key = [keys nextObject]) != nil) {
                id attribute = [[self attributesForSelectedTextObject] objectForKey:key];
                if (attribute != nil) {
                    [text addAttribute:NSFontAttributeName value:attribute range:[key rangeValue]];
                }
            }
            [textObject setHyperText:text];
            [text release];
        }
        handled = YES;
    }
    return handled;
}

- (BOOL)canHandleKeyBindingCharactersBySelectedObject
{
    BOOL bVar2;

    if ([self HSEditorCardView_selectedTextObject] == nil) {
        bVar2 = [self HSEditorCardView_selectedScaledObject] != nil;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (id)HSEditorCardView_selectedScaledObject
{
    id pvVar1_5;

    if ([[self selection] nodesCount] == 0x1) {
        pvVar1_5 = [[[self selection] selectedObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
        if ([pvVar1_5 queryHyperInterface:@protocol(HSSystemTextViewAttributes)] == nil) {
            if ([[pvVar1_5 queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
                return nil;
            }
            return pvVar1_5;
        }
    }
    return nil;
}

- (id)HSEditorCardView_selectedTextObject
{
    id self_00;
    BOOL pvVar2;
    id pvVar1_6;

    if ([[self selection] nodesCount] == 0x1) {
        self_00 = [[[self selection] selectedObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
        pvVar2 = [[self_00 queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked];
        pvVar1_6 = nil;
        if (!pvVar2) {
            pvVar1_6 = self_00;
        }
    }
    else {
        pvVar1_6 = nil;
    }
    return pvVar1_6;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00004825 @ 00004825, 299 bytes * /

NSRect * FUN_00004825(NSRect *__return_storage_ptr__,HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  int *piVar3;
  int aiStack_64 [2];
  undefined8 local_54 [4];
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar3 = (int *)&stack0xffffffa4;
  local_34 = *(float *)PTR_00336078;
  fStack_30 = *(float *)(PTR_00336078 + 4);
  local_2c = *(float *)(PTR_00336078 + 8);
  fStack_28 = *(float *)(PTR_00336078 + 0xc);
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesEnumerator);
  while( true ) {
    piVar3[1] = (int)sel_nextObject;
    *piVar3 = (int)pvVar1;
    piVar3[-1] = 0x4914;
    pvVar2 = _objc_msgSend((id)*piVar3,(SEL)piVar3[1]);
    if (pvVar2 == (id)0x0) break;
    piVar3[2] = (int)&DAT_00360868;
    piVar3[1] = (int)sel_queryHyperInterface_;
    *piVar3 = (int)pvVar2;
    piVar3[-1] = 0x48a8;
    pvVar2 = _objc_msgSend((id)*piVar3,(SEL)piVar3[1]);
    if (pvVar2 != (id)0x0) {
      piVar3[2] = (int)sel_frameBoundingRect;
      piVar3[1] = (int)pvVar2;
      *piVar3 = (int)&local_24;
      piVar3[-1] = 0x48c5;
      _objc_msgSend_stret((void *)*piVar3,(id)piVar3[1],(SEL)piVar3[2]);
      *(undefined8 *)(piVar3 + 6) = local_1c;
      *(undefined8 *)(piVar3 + 4) = local_24;
      *(ulonglong *)(piVar3 + 2) = CONCAT44(fStack_28,local_2c);
      *(ulonglong *)piVar3 = CONCAT44(fStack_30,local_34);
      piVar3[-1] = (int)&local_34;
      piVar3[-2] = 0x48ff;
      _NSUnionRect();
      piVar3 = piVar3 + -2;
    }
  }
  (__return_storage_ptr__->origin).x = local_34;
  (__return_storage_ptr__->origin).y = fStack_30;
  (__return_storage_ptr__->size).width = local_2c;
  (__return_storage_ptr__->size).height = fStack_28;
  return __return_storage_ptr__;
}

*/
- (NSRect)HSEditorCardView_selectionGeometryBounds
{
    NSRect bounds = NSZeroRect;
    NSEnumerator *e = [[self selection] nodesEnumerator];
    id node;
    while ((node = [e nextObject]) != nil) {
        id geometry = [node queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry != nil) {
            bounds = NSUnionRect(bounds, [geometry frameBoundingRect]);
        }
    }
    return bounds;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00004950 @ 00004950, 581 bytes * /

void FUN_00004950(HSEditorCardView *self,SEL _cmd,id keyUp)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(cls_HSKeysRegistry,sel_sharedRegistry);
  uVar3 = 0xf700;
  pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0xf700);
  pvVar1 = _objc_msgSend(pvVar1,sel_isKeyWithCharCodesPressed_,pvVar2);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSKeysRegistry,sel_sharedRegistry,pvVar2,uVar3);
    uVar3 = 0xf701;
    pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0xf701);
    pvVar1 = _objc_msgSend(pvVar1,sel_isKeyWithCharCodesPressed_,pvVar2);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(cls_HSKeysRegistry,sel_sharedRegistry,pvVar2,uVar3);
      uVar3 = 0xf702;
      pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0xf702);
      pvVar1 = _objc_msgSend(pvVar1,sel_isKeyWithCharCodesPressed_,pvVar2);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(cls_HSKeysRegistry,sel_sharedRegistry,pvVar2,uVar3);
        uVar3 = 0xf703;
        pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0xf703);
        pvVar1 = _objc_msgSend(pvVar1,sel_isKeyWithCharCodesPressed_,pvVar2);
        if ((char)pvVar1 == '\0') {
          pvVar1 = _objc_msgSend(self,sel_nodeSelection,pvVar2,uVar3);
          _objc_msgSend(pvVar1,sel_setShouldDisplaySelectionKnobs_,1);
          pvVar1 = _objc_msgSend(self,sel_layoutGuidingContext);
          pvVar1 = _objc_msgSend(pvVar1,sel_isSnappingEnabled);
          if ((char)pvVar1 != '\0') {
            _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,
                          sel_clearLayoutGuidingRules,0,0,0x3fe00000);
          }
        }
      }
    }
  }
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_1c,sel_keyUp_,keyUp);
  return;
}

*/
- (void)keyUp:(id)aUp
{
    HSKeysRegistry *registry = [HSKeysRegistry sharedRegistry];
    if (![registry isKeyWithCharCodesPressed:[NSString stringWithFormat:@"%C", (unichar)0xf700]] &&
        ![registry isKeyWithCharCodesPressed:[NSString stringWithFormat:@"%C", (unichar)0xf701]] &&
        ![registry isKeyWithCharCodesPressed:[NSString stringWithFormat:@"%C", (unichar)0xf702]] &&
        ![registry isKeyWithCharCodesPressed:[NSString stringWithFormat:@"%C", (unichar)0xf703]]) {
        [[self nodeSelection] setShouldDisplaySelectionKnobs:YES];
        if ([[self layoutGuidingContext] isSnappingEnabled]) {
            [self performSelector:@selector(clearLayoutGuidingRules) withObject:nil afterDelay:0.5];
        }
    }
    [super keyUp:aUp];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00004b95 @ 00004b95, 213 bytes * /

void FUN_00004b95(HSEditorCardView *self,SEL _cmd,id keyDown)

{
  id pvVar1;
  undefined4 uVar2;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(keyDown,sel_characters);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar1 == (id)0x0) {
LAB_00004c43:
    local_1c = self;
    local_18 = PTR_s_HSToolView_0034db70;
    _objc_msgSendSuper(&local_1c,sel_keyDown_,keyDown);
  }
  else {
    pvVar1 = _objc_msgSend(keyDown,sel_characters);
    pvVar1 = _objc_msgSend(pvVar1,sel_characterAtIndex_,0);
    if ((short)pvVar1 == 9) {
      uVar2 = 1;
    }
    else {
      if ((short)pvVar1 != 0x19) goto LAB_00004c43;
      uVar2 = 0xffffffff;
    }
    _objc_msgSend(self,sel_goToNextObjectOnCardWithDirection_,uVar2);
  }
  return;
}

*/
- (void)keyDown:(id)aDown
{
    if ([[aDown characters] length] != 0) {
        unichar c = [[aDown characters] characterAtIndex:0];
        if (c == 9) {
            [self goToNextObjectOnCardWithDirection:1];
            return;
        }
        if (c == 0x19) {
            [self goToNextObjectOnCardWithDirection:-1];
            return;
        }
    }
    [super keyDown:aDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00004c6a @ 00004c6a, 381 bytes * /

void FUN_00004c6a(HSEditorCardView *self,SEL _cmd,int goToNextObjectOnCardWithDirection)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  int iVar5;
  undefined *puVar6;
  
  pvVar1 = _objc_msgSend(self,sel_card);
  puVar6 = &DAT_00360034;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360034);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperCount);
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(self,sel_editorSelection,puVar6);
  pvVar2 = _objc_msgSend(pvVar2,sel_nodesCount);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_editorSelection,puVar6);
    pvVar2 = _objc_msgSend(pvVar2,sel_nodesArray);
    puVar3 = _objc_msgSend(pvVar2,sel_lastObject);
    if (puVar3 != (undefined *)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_indexOfHyperChild_,puVar3);
      pvVar4 = _objc_msgSend(pvVar1,sel_hyperCount);
      iVar5 = goToNextObjectOnCardWithDirection + (int)pvVar2;
      if (iVar5 < 0) {
        iVar5 = (int)pvVar4 + -1;
        goto LAB_00004d73;
      }
      puVar6 = puVar3;
      if (iVar5 < (int)pvVar4) goto LAB_00004d73;
    }
  }
  iVar5 = 0;
  puVar3 = puVar6;
LAB_00004d73:
  pvVar2 = _objc_msgSend(self,sel_editorSelection,puVar3);
  _objc_msgSend(pvVar2,sel_removeAllNodes);
  pvVar2 = _objc_msgSend(self,sel_editorSelection);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,iVar5);
  _objc_msgSend(pvVar2,sel_selectNode_,pvVar1);
  return;
}

*/
- (void)goToNextObjectOnCardWithDirection:(NSInteger)aDirection
{
    id container = [[self card] queryHyperInterface:@protocol(HSNodeContainer)];
    NSInteger count = [container hyperCount];
    if (count == 0) {
        return;
    }
    NSInteger index = 0;
    if ([[self editorSelection] nodesCount] != 0) {
        id last = [[[self editorSelection] nodesArray] lastObject];
        if (last != nil) {
            index = aDirection + (NSInteger)[container indexOfHyperChild:last];
            if (index < 0) {
                index = count - 1;
            }
            if (index >= count) {
                index = 0;
            }
        }
    }
    [[self editorSelection] removeAllNodes];
    [[self editorSelection] selectNode:[container hyperChildAtIndex:index]];
}

- (void)cancelAppliedLayoutGuidingRulesClearing
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearLayoutGuidingRules) object:nil];
}

- (void)clearLayoutGuidingRules
{
    id self_00;

    self_00 = [self layoutGuidingContext];
    [self_00 clearAppliedLayoutGuidingRules];
    [self_00 showAppliedLayoutGuidingRules];
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard dataName:(id *)aName
{
    return (BOOL)[[self dragHelper] canRecieveDataFromPasteboard:aPasteboard dataName:aName];
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard
{
    return (BOOL)[self canRecieveDataFromPasteboard:aPasteboard dataName:nil];
}

- (id)pasteboardTypes
{
    return [[self dragHelper] pasteboardTypes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00004f36 @ 00004f36, 174 bytes * /

BOOL FUN_00004f36(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_isEditable);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_isOccupiedByTool), (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(self,sel_window);
    pvVar1 = _objc_msgSend(pvVar1,sel_attachedSheet);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_card);
      pvVar1 = _objc_msgSend(pvVar1,sel_document);
      pvVar1 = _objc_msgSend(pvVar1,sel_isInAnimationMode);
      return (char)pvVar1 == '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)allowsDragSession
{
    if ([self isEditable] && ![self isOccupiedByTool] && [[self window] attachedSheet] == nil) {
        return ![[[self card] document] isInAnimationMode];
    }
    return NO;
}

- (void)duplicateObjectsInEnumerator:(id)aEnumerator duplicatedObjects:(id *)aObjects
{
    [[self dragHelper] duplicateObjectsInEnumerator:aEnumerator duplicatedObjects:aObjects];
}

- (void)writeObjectsInEnumeratorToPasteboard:(id)aPasteboard
{
    [[self dragHelper] writeObjectsInEnumeratorToPasteboard:aPasteboard];
}

- (BOOL)startDragWithNodes:(id)aNodes event:(id)aEvent
{
    if ([[self layoutGuidingContext] isSnappingEnabled]) {
        [[self layoutGuidingContext] showAppliedLayoutGuidingRules];
    }
    return (BOOL)[[self dragHelper] startDragWithNodes:aNodes event:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00005108 @ 00005108, 471 bytes * /

BOOL FUN_00005108(HSEditorCardView *self,SEL _cmd,id performDragOperation)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  HSEditorCardView *pHVar4;
  char *pcVar5;
  char *pcVar6;
  char local_12;
  char local_11;
  
  local_11 = '\0';
  local_12 = '\0';
  pvVar1 = _objc_msgSend(performDragOperation,sel_draggingLocation);
  pvVar2 = _objc_msgSend(self,sel_canvasHitTester);
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_hitTestNodeAtPoint_,pvVar1,extraout_EDX_00);
  pvVar1 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00360b60);
  pvVar3 = _objc_msgSend(pvVar1,sel_isLocked);
  self_00 = _objc_msgSend(self,sel_dragHelper);
  pcVar6 = &local_12;
  pcVar5 = &local_11;
  pvVar1 = (id)0x0;
  if ((char)pvVar3 == '\0') {
    pvVar1 = pvVar2;
  }
  pvVar2 = performDragOperation;
  pvVar3 = _objc_msgSend(self_00,
                         sel_performDragOperation_acceptingObject_runAnimationMode_didAddNewObject_,
                         performDragOperation,pvVar1,pcVar5,pcVar6);
  if (((char)pvVar3 != '\0') && (local_12 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_window,pvVar2,pvVar1,pcVar5,pcVar6);
    _objc_msgSend(pvVar1,sel_makeKeyAndOrderFront_,0);
    pvVar1 = _objc_msgSend(self,sel_window);
    pHVar4 = self;
    _objc_msgSend(pvVar1,sel_makeFirstResponder_,self);
    pvVar1 = _objc_msgSend(performDragOperation,sel_draggingSource);
    pvVar2 = _objc_msgSend(self,sel_dragHelper);
    if ((pvVar1 != pvVar2) && (local_11 == '\0')) {
      _objc_msgSend(self,sel_didAddNewObject,pHVar4);
    }
  }
  return (char)pvVar3;
}

*/
- (BOOL)performDragOperation:(id)aOperation
{
    BOOL runAnimationMode = NO;
    BOOL didAddNewObject = NO;
    NSPoint point = [self convertPoint:[aOperation draggingLocation] fromView:nil];
    id node = [[self canvasHitTester] hitTestNodeAtPoint:point];
    BOOL locked = [[node queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
    BOOL result = [[self dragHelper] performDragOperation:aOperation acceptingObject:(locked ? nil : node) runAnimationMode:&runAnimationMode didAddNewObject:&didAddNewObject];
    if (result && didAddNewObject) {
        [[self window] makeKeyAndOrderFront:nil];
        [[self window] makeFirstResponder:self];
        if ([aOperation draggingSource] != [self dragHelper] && !runAnimationMode) {
            [self didAddNewObject];
        }
    }
    return result;
}

- (void)concludeDragOperation:(id)aOperation
{
    [[self dragHelper] concludeDragOperation:aOperation];
}

- (void)draggingExited:(id)aExited
{
    [[self dragHelper] draggingExited:aExited];
}

- (NSUInteger)draggingUpdated:(id)aUpdated
{
    return (unsigned int)[[self dragHelper] draggingUpdated:aUpdated];
}

- (NSUInteger)draggingEntered:(id)aEntered
{
    return (unsigned int)[[self dragHelper] draggingEntered:aEntered];
}

- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation
{
    [[self dragHelper] draggedImage:aImage endedAt:aAt operation:aOperation];
}

- (void)setDragHelperDelegate:(id)aDelegate
{
    [[self dragHelper] setDelegate:aDelegate];
}

- (BOOL)canDeactivate
{
    return ![[HSObjectAssistantController sharedAssistantController] isLocked];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000054c7 @ 000054c7, 1860 bytes * /

BOOL FUN_000054c7(HSEditorCardView *self,SEL _cmd,id validateUserInterfaceItem)

{
  char cVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  undefined *local_24;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  puVar2 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  pvVar4 = validateUserInterfaceItem;
  pvVar3 = _objc_msgSendSuper(&local_1c,sel_validateUserInterfaceItem_,validateUserInterfaceItem);
  cVar1 = (char)pvVar3;
  pvVar3 = _objc_msgSend(self,sel_isOccupiedByTool);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_card);
    pvVar3 = _objc_msgSend(pvVar3,sel_document);
    pvVar3 = _objc_msgSend(pvVar3,sel_isModalSessionPresent);
    if ((char)pvVar3 != '\0') goto LAB_00005573;
  }
  else {
LAB_00005573:
    if ((((puVar2 == sel_delete_) || (puVar2 == sel_cut_)) || (puVar2 == sel_selectAll_)) ||
       ((puVar2 == sel_paste_ || (puVar2 == sel_copy_)))) {
      return '\0';
    }
  }
  if (puVar2 == sel_copy_) {
    pvVar4 = _objc_msgSend(cls_NSMenuItem,sel_class);
    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar4);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(self,sel_isSelectionToolActiveInToolManager,pvVar4);
      if ((char)pvVar3 != '\0') {
        return cVar1;
      }
      if (cVar1 != '\0') {
        pvVar3 = _objc_msgSend(self,sel_selection,pvVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_nodesCount);
        if (pvVar3 == (id)0x0) {
          return cVar1;
        }
        pvVar4 = _objc_msgSend(self,sel_localizedSelectedCardObjectName,pvVar4);
        if (pvVar4 == (id)0x0) {
          return cVar1;
        }
        local_24 = cls_NSString;
        pvVar4 = _objc_msgSend(self,sel_localizedSelectedCardObjectName);
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar5 = &cfstr_HSCopyFormat;
        goto LAB_000056aa;
      }
      goto LAB_000056f6;
    }
  }
  if (puVar2 == sel_cut_) {
    pvVar4 = _objc_msgSend(cls_NSMenuItem,sel_class,pvVar4);
    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar4);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(self,sel_isSelectionToolActiveInToolManager,pvVar4);
      if ((char)pvVar3 != '\0') {
        return cVar1;
      }
      if (cVar1 != '\0') {
        pvVar3 = _objc_msgSend(self,sel_selection,pvVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_nodesCount);
        if (pvVar3 == (id)0x0) {
          return cVar1;
        }
        pvVar4 = _objc_msgSend(self,sel_localizedSelectedCardObjectName,pvVar4);
        if (pvVar4 == (id)0x0) {
          return cVar1;
        }
        local_24 = cls_NSString;
        pvVar4 = _objc_msgSend(self,sel_localizedSelectedCardObjectName);
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar5 = &cfstr_HSCutFormat;
        goto LAB_000056aa;
      }
      goto LAB_000056f6;
    }
  }
  if (puVar2 == sel_paste_) {
    pvVar4 = _objc_msgSend(cls_NSMenuItem,sel_class,pvVar4);
    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar4);
    if ((char)pvVar3 != '\0') goto LAB_000056f6;
  }
  if (puVar2 == sel_delete_) {
    pvVar4 = _objc_msgSend(cls_NSMenuItem,sel_class,pvVar4);
    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar4);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(self,sel_isSelectionToolActiveInToolManager,pvVar4);
      if ((char)pvVar3 != '\0') {
        return cVar1;
      }
      if (cVar1 != '\0') {
        pvVar3 = _objc_msgSend(self,sel_selection,pvVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_nodesCount);
        if (pvVar3 == (id)0x0) {
          return cVar1;
        }
        pvVar4 = _objc_msgSend(self,sel_localizedSelectedCardObjectName,pvVar4);
        if (pvVar4 == (id)0x0) {
          return cVar1;
        }
        local_24 = cls_NSString;
        pvVar4 = _objc_msgSend(self,sel_localizedSelectedCardObjectName);
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar5 = &cfstr_HSDeleteFormat;
LAB_000056aa:
        pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                               &cfstr_Editor);
        pvVar4 = _objc_msgSend(local_24,sel_stringWithFormat_,pvVar3,pvVar4);
        _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,pvVar4);
        return cVar1;
      }
LAB_000056f6:
      pvVar4 = _objc_msgSend(self,sel_delegate,pvVar4);
      pvVar4 = _objc_msgSend(pvVar4,sel_validateUserInterfaceItem_,validateUserInterfaceItem);
      return (BOOL)pvVar4;
    }
  }
  if (puVar2 != sel_onScalePopUp_) {
    if (puVar2 != sel_orderFrontFontPanel_) {
      if (puVar2 == sel_modifyFont_) {
        pvVar4 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar4);
        pvVar3 = _objc_msgSend(self,sel_selectedHyperObject);
        puVar2 = &DAT_00360570;
        pvVar3 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_00360570);
        if ((char)pvVar3 != '\0') {
          pvVar3 = _objc_msgSend(self,sel_selectedHyperObject,puVar2);
          puVar2 = &DAT_00360a48;
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00360a48);
          pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
          if ((char)pvVar3 == '\0') {
            return '\x01';
          }
        }
        pvVar4 = _objc_msgSend(pvVar4,sel_selectedToolTag,puVar2);
        return pvVar4 == (id)0x2;
      }
      if (puVar2 == sel_editText_) {
        pvVar4 = _objc_msgSend(self,sel_selectedHyperObject,pvVar4);
        puVar2 = &DAT_00360548;
        pvVar4 = _objc_msgSend(pvVar4,sel_implementsHyperInterface_,&DAT_00360548);
        if ((char)pvVar4 != '\0') {
          pvVar4 = _objc_msgSend(self,sel_selectedHyperObject,puVar2);
          puVar2 = &DAT_00360a48;
          pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00360a48);
LAB_00005b46:
          pvVar4 = _objc_msgSend(pvVar4,sel_isLocked,puVar2);
          return (char)pvVar4 == '\0';
        }
      }
      else {
        if (puVar2 != sel_showInspector_) {
          return cVar1;
        }
        pvVar4 = _objc_msgSend(self,sel_selectedHyperObject,pvVar4);
        puVar2 = &DAT_00360548;
        pvVar4 = _objc_msgSend(pvVar4,sel_implementsHyperInterface_,&DAT_00360548);
        if ((char)pvVar4 != '\0') {
          pvVar4 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                 puVar2);
          pvVar4 = _objc_msgSend(pvVar4,sel_isActive);
          if ((char)pvVar4 == '\0') {
            pvVar4 = _objc_msgSend(self,sel_selectedHyperObject,puVar2);
            puVar2 = &DAT_00360a48;
            pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00360a48);
            goto LAB_00005b46;
          }
        }
      }
      return '\0';
    }
    puVar2 = sel_setState_;
    pvVar4 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(cls_NSFontPanel,sel_sharedFontPanel,puVar2);
      pvVar4 = _objc_msgSend(pvVar4,sel_isVisible);
      _objc_msgSend(validateUserInterfaceItem,sel_setState_,(uint)((char)pvVar4 != '\0'));
      return '\x01';
    }
  }
  return '\x01';
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    BOOL ok = [super validateUserInterfaceItem:aItem];
    if ([self isOccupiedByTool] || [[[self card] document] isModalSessionPresent]) {
        if (action == @selector(delete:) || action == @selector(cut:) || action == @selector(selectAll:) || action == @selector(paste:) || action == @selector(copy:)) {
            return NO;
        }
    }
    if (action == @selector(copy:) || action == @selector(cut:) || action == @selector(delete:)) {
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            if ([self isSelectionToolActiveInToolManager]) {
                return ok;
            }
            if (!ok) {
                return [[self delegate] validateUserInterfaceItem:aItem];
            }
            if ([[self selection] nodesCount] != 0 && [self localizedSelectedCardObjectName] != nil) {
                NSString *key = (action == @selector(copy:)) ? @"HSCopyFormat" : (action == @selector(cut:)) ? @"HSCutFormat" : @"HSDeleteFormat";
                [aItem setTitle:[NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:key value:@"" table:@"Editor"], [self localizedSelectedCardObjectName]]];
            }
            return ok;
        }
    }
    if (action == @selector(paste:) && [aItem isKindOfClass:[NSMenuItem class]]) {
        return [[self delegate] validateUserInterfaceItem:aItem];
    }
    if (action == @selector(onScalePopUp:)) {
        return YES;
    }
    if (action == @selector(orderFrontFontPanel:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[NSFontPanel sharedFontPanel] isVisible]];
        }
        return YES;
    }
    if (action == @selector(modifyFont:)) {
        HSToolManager *toolManager = [HSToolManager sharedToolManager];
        if ([[self selectedHyperObject] implementsHyperInterface:@protocol(HSGenericFontAttributes)]) {
            if (![[[self selectedHyperObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
                return YES;
            }
        }
        return [toolManager selectedToolTag] == 2;
    }
    if (action == @selector(editText:)) {
        if ([[self selectedHyperObject] implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
            return ![[[self selectedHyperObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked];
        }
        return NO;
    }
    if (action == @selector(showInspector:)) {
        if ([[self selectedHyperObject] implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]
            && ![[HSObjectAssistantController sharedAssistantController] isActive]) {
            return ![[[self selectedHyperObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked];
        }
        return NO;
    }
    return ok;
}

- (BOOL)supportMenuItemStoredTitleValidation
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00005c0b @ 00005c0b, 208 bytes * /

id FUN_00005c0b(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesCount);
  self_00 = _objc_msgSend(self,sel_selection);
  op = sel_localizedSelectionName;
  if (pvVar1 < (id)0x2) {
    pvVar1 = _objc_msgSend(self_00,sel_nodesCount);
    if (pvVar1 != (id)0x1) {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(self,sel_selection);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedObject);
    self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360c64);
    op = sel_hyperKindDisplayName;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)localizedSelectedCardObjectName
{
    id selection = [self selection];
    if ([selection nodesCount] >= 2) {
        return [[self selection] localizedSelectionName];
    }
    if ([[self selection] nodesCount] != 1) {
        return nil;
    }
    id object = [[[self selection] selectedObject] queryHyperInterface:@protocol(HSObjectAttributes)];
    return [object hyperKindDisplayName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00005cdb @ 00005cdb, 466 bytes * /

id FUN_00005cdb(HSEditorCardView *self,SEL _cmd,id menuForEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  SEL op;
  undefined4 uVar4;
  undefined4 uVar5;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(menuForEvent,sel_locationInWindow);
  uVar5 = 0;
  pvVar1 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  pvVar2 = _objc_msgSend(self,sel_canvasHitTester);
  uVar4 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(pvVar2,sel_hitTestNodeAtPoint_,pvVar1,extraout_EDX_00);
  pvVar3 = _objc_msgSend(self,sel_selection);
  if (pvVar3 == (id)0x0) {
    pvVar2 = (id)0x0;
    goto LAB_00005e5e;
  }
  pvVar3 = _objc_msgSend(self,sel_selection,pvVar1,uVar4,uVar5);
  op = sel_removeAllNodes;
  if (pvVar2 == (id)0x0) {
LAB_00005def:
    _objc_msgSend(pvVar3,op,pvVar1,uVar4);
  }
  else {
    pvVar1 = pvVar2;
    pvVar3 = _objc_msgSend(pvVar3,sel_containsNode_,pvVar2,uVar4);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self,sel_selection,pvVar1,uVar4);
      op = sel_selectNode_;
      pvVar1 = pvVar2;
      goto LAB_00005def;
    }
  }
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_menuForEvent_,menuForEvent);
  pvVar1 = _objc_msgSend(pvVar1,sel_copy);
  pvVar2 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = pvVar2;
  _objc_msgSend(self,sel_cutDisabledItemsFromMenu_,pvVar2);
LAB_00005e5e:
  pvVar1 = _objc_msgSend(self,sel_window,pvVar1,uVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_attachedSheet);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(pvVar2,sel_setAllowsContextMenuPlugIns_,0);
  }
  return pvVar2;
}

*/
- (id)menuForEvent:(id)aEvent
{
    NSPoint point = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
    id node = [[self canvasHitTester] hitTestNodeAtPoint:point];
    if ([self selection] == nil) {
        node = nil;
    }
    if (node == nil) {
        [[self selection] removeAllNodes];
    } else if (![[self selection] containsNode:node]) {
        [[self selection] selectNode:node];
    }
    NSMenu *menu = [[[super menuForEvent:aEvent] copy] autorelease];
    [self cutDisabledItemsFromMenu:menu];
    if ([[self window] attachedSheet] != nil && [menu respondsToSelector:@selector(setAllowsContextMenuPlugIns:)]) {
        [(id)menu setAllowsContextMenuPlugIns:NO];
    }
    return menu;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00005ead @ 00005ead, 465 bytes * /

void FUN_00005ead(HSEditorCardView *self,SEL _cmd,id cutDisabledItemsFromMenu)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id self_01;
  
  _objc_msgSend(cutDisabledItemsFromMenu,sel_update);
  pvVar1 = _objc_msgSend(cutDisabledItemsFromMenu,sel_itemArray);
  self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(cls_NSMenuItem,sel_separatorItem);
  while (self_01 = pvVar1, pvVar1 = _objc_msgSend(self_00,sel_nextObject), pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_hasSubmenu);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(pvVar1,sel_submenu);
      _objc_msgSend(self,sel_cutDisabledItemsFromMenu_,pvVar2);
      pvVar2 = _objc_msgSend(pvVar1,sel_submenu);
      pvVar2 = _objc_msgSend(pvVar2,sel_itemArray);
      pvVar2 = _objc_msgSend(pvVar2,sel_count);
      if (pvVar2 == (id)0x0) {
        _objc_msgSend(pvVar1,sel_setEnabled_,0);
      }
    }
    pvVar2 = _objc_msgSend(pvVar1,sel_isEnabled);
    if (((char)pvVar2 == '\0') &&
       ((pvVar2 = _objc_msgSend(pvVar1,sel_isSeparatorItem), (char)pvVar2 == '\0' ||
        (pvVar2 = _objc_msgSend(self_01,sel_isSeparatorItem), (char)pvVar2 != '\0')))) {
      _objc_msgSend(cutDisabledItemsFromMenu,sel_removeItem_,pvVar1);
      pvVar1 = self_01;
    }
  }
  pvVar1 = _objc_msgSend(self_01,sel_isSeparatorItem);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self_01,sel_menu), pvVar1 == cutDisabledItemsFromMenu)) {
    _objc_msgSend(cutDisabledItemsFromMenu,sel_removeItem_,self_01);
  }
  return;
}

*/
- (void)cutDisabledItemsFromMenu:(id)aMenu
{
    [aMenu update];
    NSEnumerator *e = [[aMenu itemArray] objectEnumerator];
    NSMenuItem *previous = [NSMenuItem separatorItem];
    NSMenuItem *item;
    while ((item = [e nextObject]) != nil) {
        if ([item hasSubmenu]) {
            [self cutDisabledItemsFromMenu:[item submenu]];
            if ([[[item submenu] itemArray] count] == 0) {
                [item setEnabled:NO];
            }
        }
        if (![item isEnabled] && (![item isSeparatorItem] || [previous isSeparatorItem])) {
            [aMenu removeItem:item];
        } else {
            previous = item;
        }
    }
    if ([previous isSeparatorItem] && [previous menu] == aMenu) {
        [aMenu removeItem:previous];
    }
}

- (void)stackDidAddOrRemoveCard:(id)aCard
{
    id pvVar2;
    id self_00;
    id pvVar1_4;

    pvVar2 = [[aCard userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    self_00 = [self card];
    if ([pvVar2 containsObject:self_00]) {
        pvVar1_4 = [[self_00 stack] attributeObservingController];
        [pvVar1_4 removeObserver:self selector:@selector(cardStackDidChangeGridAttribute:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSLayoutGridVisibilityAttribute)];
        [pvVar1_4 removeObserver:self selector:@selector(stackDidAddOrRemoveCard:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006195 @ 00006195, 275 bytes * /

void FUN_00006195(HSEditorCardView *self,SEL _cmd,id cardStackDidChangeChildren)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *self_00;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cardStackDidChangeChildren,sel_userInfo);
  pcVar4 = &cfstr_HSNodeChildrenForAddition;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while (self_00 = _objc_msgSend(pvVar1,sel_nextObject,pcVar4), self_00 != (cfstringStruct *)0x0) {
    pcVar4 = (cfstringStruct *)&DAT_00360264;
    pvVar2 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_00360264);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperParent);
    pvVar3 = _objc_msgSend(self,sel_userObject);
    if ((pvVar2 == pvVar3) &&
       (pvVar2 = _objc_msgSend(self,sel_userObject,pcVar4), pvVar2 != (id)0x0)) {
      _objc_msgSend(self,sel_reflectCardObjectsHiddenStateForObject_invalidate_,self_00,1);
      pcVar4 = self_00;
    }
  }
  return;
}

*/
- (void)cardStackDidChangeChildren:(id)aChildren
{
    NSEnumerator *e = [[[aChildren userInfo] objectForKey:@"HSNodeChildrenForAddition"] objectEnumerator];
    id child;
    while ((child = [e nextObject]) != nil) {
        id parent = [[child queryHyperInterface:@protocol(HSNodeParentAttribute)] hyperParent];
        if (parent == [self userObject] && [self userObject] != nil) {
            [self reflectCardObjectsHiddenStateForObject:child invalidate:YES];
        }
    }
}

- (id)gridSettings
{
    id self_00;
    id pvVar1_3;

    self_00 = [[[self card] stack] gridSettings];
    pvVar1_3 = _gridSettings;
    if (pvVar1_3 != self_00) {
        if (pvVar1_3 != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HSGridSettingsDidChangeNotification object:_gridSettings];
            [_gridSettings release];
        }
        _gridSettings = [self_00 retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridSettingsDidChange:) name:HSGridSettingsDidChangeNotification object:_gridSettings];
        pvVar1_3 = _gridSettings;
    }
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000063e3 @ 000063e3, 175 bytes * /

void FUN_000063e3(HSEditorCardView *self,SEL _cmd,id delete)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesCount);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isSelectionToolActiveInToolManager);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_delegate);
      op = sel_delete_;
      _cmd = delete;
      goto LAB_00006482;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  op = sel_performActionSelector_withSender_;
LAB_00006482:
  _objc_msgSend(pvVar1,op,_cmd);
  return;
}

*/
- (void)delete:(id)aDelete
{
    if ([[self selection] nodesCount] == 0 && ![self isSelectionToolActiveInToolManager]) {
        [[self delegate] delete:aDelete];
        return;
    }
    [[self rootCanvasLayer] performActionSelector:@selector(delete:) withSender:aDelete];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006492 @ 00006492, 175 bytes * /

void FUN_00006492(HSEditorCardView *self,SEL _cmd,id cut)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesCount);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isSelectionToolActiveInToolManager);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_delegate);
      op = sel_cut_;
      _cmd = cut;
      goto LAB_00006531;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  op = sel_performActionSelector_withSender_;
LAB_00006531:
  _objc_msgSend(pvVar1,op,_cmd);
  return;
}

*/
- (void)cut:(id)aCut
{
    if ([[self selection] nodesCount] == 0 && ![self isSelectionToolActiveInToolManager]) {
        [[self delegate] cut:aCut];
        return;
    }
    [[self rootCanvasLayer] performActionSelector:@selector(cut:) withSender:aCut];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006541 @ 00006541, 175 bytes * /

void FUN_00006541(HSEditorCardView *self,SEL _cmd,id copy)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesCount);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isSelectionToolActiveInToolManager);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_delegate);
      op = sel_copy_;
      _cmd = copy;
      goto LAB_000065e0;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  op = sel_performActionSelector_withSender_;
LAB_000065e0:
  _objc_msgSend(pvVar1,op,_cmd);
  return;
}

*/
- (void)copy:(id)aCopy
{
    if ([[self selection] nodesCount] == 0 && ![self isSelectionToolActiveInToolManager]) {
        [[self delegate] copy:aCopy];
        return;
    }
    [[self rootCanvasLayer] performActionSelector:@selector(copy:) withSender:aCopy];
}

- (BOOL)isSelectionToolActiveInToolManager
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] != 0xe) {
        if ([[HSToolManager sharedToolManager] selectedToolTag] != 0xf) {
            return [[HSToolManager sharedToolManager] selectedToolTag] == 0x10;
        }
    }
    return YES;
}

- (void)setupRootCanvasLayer:(id)aLayer
{
    [super setupRootCanvasLayer:aLayer];
    [aLayer registerSupportedActionSelector:@selector(copy:)];
    [aLayer registerSupportedActionSelector:@selector(cut:)];
    [aLayer registerSupportedActionSelector:@selector(paste:)];
    [aLayer registerSupportedActionSelector:@selector(selectAll:)];
    [aLayer registerSupportedActionSelector:@selector(delete:)];
    [aLayer registerSupportedActionSelector:@selector(deleteSelectedCardObjects:)];
    [aLayer registerSupportedActionSelector:@selector(copyIntoSelection:)];
    [aLayer registerSupportedActionSelector:@selector(selectAllArea:)];
    [aLayer registerSupportedActionSelector:@selector(finalize:)];
    [aLayer registerSupportedActionSelector:@selector(stamp:)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000067f3 @ 000067f3, 239 bytes * /

void FUN_000067f3(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar1 = _objc_msgSend(pvVar1,sel_arrowToolCanvasLayer);
  pvVar2 = _objc_msgSend(self,sel_isAuxiliaryIconsCanvasLayerEnabled);
  _objc_msgSend(pvVar1,sel_setSublayerIdentifier_isEnabledByDefault_,*(undefined4 *)PTR_PTR_00336024
                ,(int)(char)pvVar2);
  pvVar1 = _objc_msgSend(self,sel_guidelinesSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_isSnapToObjectsEnabled);
  pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar2 = _objc_msgSend(pvVar2,sel_arrowToolCanvasLayer);
  _objc_msgSend(pvVar2,sel_setSublayerIdentifier_isEnabledByDefault_,*(undefined4 *)PTR_PTR_00336040
                ,(int)(char)pvVar1);
  return;
}

*/
- (void)refreshEnabledAuxiliaryCanvasLayers
{
    [[[self rootCanvasLayer] arrowToolCanvasLayer] setSublayerIdentifier:@"HSAuxiliaryIconsCanvasLayer" isEnabledByDefault:[self isAuxiliaryIconsCanvasLayerEnabled]];
    BOOL snap = [[self guidelinesSettings] isSnapToObjectsEnabled];
    [[[self rootCanvasLayer] arrowToolCanvasLayer] setSublayerIdentifier:@"HSLayoutRulesCanvasLayer" isEnabledByDefault:snap];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000068e2 @ 000068e2, 641 bytes * /

void FUN_000068e2(HSEditorCardView *self,SEL _cmd,id cardStackDidChangeCardObjectsHiddenState)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined *puVar5;
  
  pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer);
  puVar4 = sel_interactiveObjectsLayer;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_interactiveObjectsLayer);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_performSelector_,sel_interactiveObjectsLayer);
    puVar4 = (undefined *)0x0;
    _objc_msgSend(pvVar2,sel_setActiveItem_,0);
  }
  puVar1 = PTR_00336020;
  pvVar2 = _objc_msgSend(cardStackDidChangeCardObjectsHiddenState,sel_attributeChange,puVar4);
  puVar5 = PTR_0033601c;
  if ((*(uint *)puVar1 & (uint)pvVar2) == 0) {
    pvVar2 = _objc_msgSend(cardStackDidChangeCardObjectsHiddenState,sel_attributeChange,puVar4);
    if ((*(uint *)puVar5 & (uint)pvVar2) != 0) {
      pvVar2 = _objc_msgSend(self,sel_card,puVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperEnumerator);
      _objc_msgSend(self,sel_reflectCardObjectsHiddenStateOfObjectsInEnumerator_invalidate_,pvVar2,1
                   );
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_card,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperEnumerator);
    puVar4 = _objc_msgSend(pvVar2,sel_nextObject);
    while (puVar4 != (undefined *)0x0) {
      puVar5 = &DAT_00360b60;
      pvVar3 = _objc_msgSend(puVar4,sel_queryHyperInterface_,&DAT_00360b60);
      if (pvVar3 != (id)0x0) {
        _objc_msgSend(self,sel_showCardChildIfHidden_invalidate_,puVar4,1);
        puVar5 = puVar4;
      }
      puVar4 = _objc_msgSend(pvVar2,sel_nextObject,puVar5);
    }
  }
  _objc_msgSend(self,sel_setNeedsDisplayOpenGLSurface_,1);
  pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar2 = _objc_msgSend(pvVar2,sel_arrowToolCanvasLayer);
  pvVar3 = _objc_msgSend(self,sel_isAuxiliaryIconsCanvasLayerEnabled);
  _objc_msgSend(pvVar2,sel_setSublayerIdentifier_isEnabledByDefault_,*(undefined4 *)PTR_PTR_00336024
                ,(int)(char)pvVar3);
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_onionSkinMode);
  _objc_msgSend(self,sel_setOnionSkinMode_,pvVar2);
  return;
}

*/
- (void)cardStackDidChangeCardObjectsHiddenState:(id)aState
{
    id rootLayer = [self rootCanvasLayer];
    if ([rootLayer respondsToSelector:@selector(interactiveObjectsLayer)]) {
        [[[self rootCanvasLayer] performSelector:@selector(interactiveObjectsLayer)] setActiveItem:nil];
    }
    if ((HSActualWillAttributeChanges & [aState attributeChange]) != 0) {
        NSEnumerator *e = [[self card] hyperEnumerator];
        id child;
        while ((child = [e nextObject]) != nil) {
            if ([child queryHyperInterface:@protocol(HSCardObjectAttributes)] != nil) {
                [self showCardChildIfHidden:child invalidate:YES];
            }
        }
    } else if ((HSActualDidAttributeChanges & [aState attributeChange]) != 0) {
        [self reflectCardObjectsHiddenStateOfObjectsInEnumerator:[[self card] hyperEnumerator] invalidate:YES];
    }
    [self setNeedsDisplayOpenGLSurface:YES];
    [[[self rootCanvasLayer] arrowToolCanvasLayer] setSublayerIdentifier:@"HSAuxiliaryIconsCanvasLayer" isEnabledByDefault:[self isAuxiliaryIconsCanvasLayerEnabled]];
    [self setOnionSkinMode:[[HSEditorController sharedDocumentController] onionSkinMode]];
}

- (void)cardStackDidChangeGridAttribute:(id)aAttribute
{
    [self setNeedsDisplayOpenGLSurfaceInRect:[self viewBoundingRectForUserRect:[self userObjectBounds]]];
}

- (void)cancelColorPicking
{
    [self deactivateColorPickingLayer];
    _colorPickingDelegate = nil;
    _colorPickingDelegateDidEndSelector = (SEL)0x0;
}

- (void)colorPickingDidFinishInLayer:(id)aLayer withColor:(id)aColor
{
    id pvVar1_3;

    [self deactivateColorPickingLayer];
    [_colorPickingDelegate performSelector:_colorPickingDelegateDidEndSelector withObject:aColor];
    _colorPickingDelegate = nil;
    _colorPickingDelegateDidEndSelector = (SEL)0x0;
    pvVar1_3 = [[[self runTimeEditorController] selectedRunTimeEditorObject] queryHyperInterface:@protocol(HSEmbeddedEditor)];
    if (pvVar1_3 != nil) {
        [[pvVar1_3 viewEmbedder] makeEmbeddedViewFirstResponder];
    }
}

- (void)activateColorPickingModeWithDelegate:(id)aDelegate didEndSelector:(SEL)aSelector
{
    _colorPickingDelegate = aDelegate;
    _colorPickingDelegateDidEndSelector = aSelector;
    [self activateColorPickingLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000036e1 @ 000036e1, 26 bytes * /

BOOL FUN_000036e1(HSEditorCardView *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((*(uint *)self->_cacheOnlyRendering & 2) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isColorPickingModeActive
{
    return _isColorPickingModeActive != 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006d3a @ 00006d3a, 182 bytes * /

void FUN_00006d3a(HSEditorCardView *self,SEL _cmd)

{
  id self_00;
  id self_01;
  id pvVar1;
  undefined4 uVar2;
  
  self_00 = _objc_msgSend(self,sel_rootCanvasLayer);
  self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] & 0xfd;
  self_01 = _objc_msgSend(self_00,sel_bitmapToolsCanvasLayer);
  uVar2 = *(undefined4 *)PTR_PTR_00336028;
  pvVar1 = _objc_msgSend(self_00,sel_isEnabledSublayerForIdentifier_,uVar2);
  if ((char)pvVar1 == '\0') {
    self_01 = _objc_msgSend(self_00,sel_vectorToolsCanvasLayer,uVar2);
  }
  _objc_msgSend(self_01,sel_removeSublayer_,self->_colorPickingCanvasLayer);
  _objc_msgSend(self->_colorPickingCanvasLayer,sel_release);
  return;
}

*/
- (void)deactivateColorPickingLayer
{
    id rootLayer = [self rootCanvasLayer];
    _isColorPickingModeActive = 0;
    id parentLayer = [rootLayer bitmapToolsCanvasLayer];
    if (![rootLayer isEnabledSublayerForIdentifier:@"HSBitmapToolsCanvasLayer"]) {
        parentLayer = [rootLayer vectorToolsCanvasLayer];
    }
    [parentLayer removeSublayer:_colorPickingCanvasLayer];
    [_colorPickingCanvasLayer release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006df0 @ 00006df0, 349 bytes * /

void FUN_00006df0(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  if (pvVar1 == (id)0x12) {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_bitmapTool);
    _objc_msgSend(pvVar1,sel_doCommandBySelector_,sel_finalize_);
  }
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  self_00 = _objc_msgSend(pvVar1,sel_bitmapToolsCanvasLayer);
  uVar3 = *(undefined4 *)PTR_PTR_00336028;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEnabledSublayerForIdentifier_,uVar3);
  if ((char)pvVar2 == '\0') {
    self_00 = _objc_msgSend(pvVar1,sel_vectorToolsCanvasLayer,uVar3);
  }
  pvVar1 = _objc_msgSend(cls_HSColorPickingCanvasLayer,sel_new,uVar3);
  self->_colorPickingCanvasLayer = pvVar1;
  _objc_msgSend(self_00,sel_addSublayer_,pvVar1);
  self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] | 2;
  _objc_msgSend(self->_colorPickingCanvasLayer,sel_startPickingColorInView_withDelegate_,self,self);
  return;
}

*/
- (void)activateColorPickingLayer
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x12) {
        [[[[HSToolManager sharedToolManager] currentTool] bitmapTool] doCommandBySelector:@selector(finalize:)];
    }
    id rootLayer = [self rootCanvasLayer];
    id parentLayer = [rootLayer bitmapToolsCanvasLayer];
    if (![rootLayer isEnabledSublayerForIdentifier:@"HSBitmapToolsCanvasLayer"]) {
        parentLayer = [rootLayer vectorToolsCanvasLayer];
    }
    _colorPickingCanvasLayer = [HSColorPickingCanvasLayer new];
    [parentLayer addSublayer:_colorPickingCanvasLayer];
    _isColorPickingModeActive = 1;
    [_colorPickingCanvasLayer startPickingColorInView:self withDelegate:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006f4d @ 00006f4d, 108 bytes * /

void FUN_00006f4d(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_gridSettings);
  _objc_msgSend_stret(&local_24,self,sel_userObjectBounds);
  _HSRenderGrid(pvVar1,self,local_24,local_1c);
  return;
}

*/
- (void)renderGrid
{
    HSRenderGrid([self gridSettings], self, [self userObjectBounds]);
}

- (void)noteDidPerformCutOperation
{
    [[self card] resetPasteCount];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00006ff3 @ 00006ff3, 561 bytes * /

BOOL FUN_00006ff3(HSEditorCardView *self,SEL _cmd,id shouldPerformDeleteOperationWithNodesInArray)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(shouldPerformDeleteOperationWithNodesInArray,sel_count);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(self,sel_containsGroupObjectInNodesArray_,
                             shouldPerformDeleteOperationWithNodesInArray), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(cls_HSAlert,sel_alloc,shouldPerformDeleteOperationWithNodesInArray);
    pvVar1 = _objc_msgSend(pvVar1,sel_init);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_Delete_these_group_objects_,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_If_you_delete_these_group_objects__they_will_be_,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_Delete_From_All_Cards,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
    _objc_msgSend(pvVar1,sel_release);
    return pvVar2 != (id)0x3e9;
  }
  return '\x01';
}

*/
- (BOOL)shouldPerformDeleteOperationWithNodesInArray:(id)aArray
{
    if ([aArray count] != 0 && [self containsGroupObjectInNodesArray:aArray]) {
        HSAlert *alert = [[HSAlert alloc] init];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Delete these group objects?" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"If you delete these group objects, they will be permanently deleted from all the cards in the group." value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Delete From All Cards" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        NSInteger response = [alert runModal];
        [alert release];
        return response != 1001;
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00007224 @ 00007224, 1345 bytes * /

void FUN_00007224(HSEditorCardView *self,SEL _cmd,id performDeleteOperationWithNodesInArray)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int *piVar6;
  int aiStack_78 [2];
  id local_50;
  id local_4c;
  undefined1 local_44 [16];
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar6 = (int *)&stack0xffffff94;
  pvVar1 = _objc_msgSend(performDeleteOperationWithNodesInArray,sel_count);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(performDeleteOperationWithNodesInArray,sel_count);
    if (pvVar1 == (id)0x1) {
      pvVar1 = _objc_msgSend(performDeleteOperationWithNodesInArray,sel_lastObject);
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
      piVar6 = (int *)&stack0xffffff94;
      if (pvVar2 != (id)0x0) {
        _objc_msgSend_stret(local_44,pvVar2,sel_frameBoundingRect);
        piVar6 = (int *)&stack0xffffff90;
        _objc_msgSend(self,sel_addPoofEffectForUserSpaceRect_);
      }
      piVar6[1] = (int)sel_removeFromHyperParent;
      *piVar6 = (int)pvVar1;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_selectionObject);
      _objc_msgSend(pvVar1,sel_beginSelectionChanging);
      pvVar1 = _objc_msgSend(performDeleteOperationWithNodesInArray,sel_hyperObjectForAllInterfaces)
      ;
      pvVar2 = _objc_msgSend(pvVar1,sel_hyperParent);
      pvVar3 = _objc_msgSend(pvVar1,sel_lastHyperAccessDidReturnMultipleValues);
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
        pvVar3 = _objc_msgSend(pvVar3,sel_allHyperInterfaces);
        pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
        piVar6 = (int *)&stack0xffffff94;
        while( true ) {
          piVar6[1] = (int)sel_nextObject;
          *piVar6 = (int)pvVar3;
          piVar6[-1] = 0x740d;
          pvVar4 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
          if (pvVar4 == (id)0x0) break;
          piVar6[2] = (int)sel_frameBoundingRect;
          piVar6[1] = (int)pvVar4;
          *piVar6 = (int)&local_34;
          piVar6[-1] = 0x73cd;
          _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
          *(undefined8 *)(piVar6 + 3) = local_2c;
          *(undefined8 *)(piVar6 + 1) = local_34;
          *piVar6 = (int)sel_addPoofEffectForUserSpaceRect_;
          piVar6[-1] = (int)self;
          piVar6[-2] = 0x73fb;
          _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
          piVar6 = piVar6 + -1;
        }
        piVar6[1] = (int)sel_hyperRemoveChildrenBeginGrouping;
        *piVar6 = (int)pvVar2;
        piVar6[-1] = 0x7426;
        _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
        piVar6[1] = (int)sel_removeFromHyperParent;
        *piVar6 = (int)pvVar1;
        piVar6[-1] = 0x743b;
        _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
        piVar6[1] = (int)sel_hyperRemoveChildrenEndGrouping;
        *piVar6 = (int)pvVar2;
      }
      else {
        pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithArray_);
        self_00 = cls_NSMutableArray;
        _objc_msgSend(pvVar2,sel_allHyperInterfaces);
        pvVar2 = _objc_msgSend(self_00,sel_arrayWithArray_);
        pvVar3 = _objc_msgSend(self,sel_userObject);
        pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_);
        pvVar4 = _objc_msgSend(pvVar2,sel_indexOfObjectIdenticalTo_);
        pvVar5 = _objc_msgSend(self,sel_userObject);
        _objc_msgSend(pvVar5,sel_hyperRemoveChildrenBeginGrouping);
        pvVar5 = _objc_msgSend(pvVar2,sel_count);
        if (pvVar5 != (id)0x0) {
          piVar6 = (int *)&stack0xffffff94;
          local_50 = (id)0x0;
          if (pvVar4 != (id)0x7fffffff) {
            piVar6 = (int *)&stack0xffffff94;
            local_50 = pvVar3;
          }
          do {
            if (local_50 == (id)0x0) {
              piVar6[1] = (int)sel_lastObject;
              *piVar6 = (int)pvVar2;
              piVar6[-1] = 0x7568;
              local_50 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
            }
            piVar6[2] = (int)local_50;
            piVar6[1] = (int)sel_removeObjectIdenticalTo_;
            *piVar6 = (int)pvVar2;
            piVar6[-1] = 0x7587;
            _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
            piVar6[1] = (int)sel_hyperRemoveChildrenBeginGrouping;
            *piVar6 = (int)local_50;
            piVar6[-1] = 0x7599;
            _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
            piVar6[1] = (int)sel_count;
            *piVar6 = (int)pvVar1;
            pvVar3 = (id)0x0;
            piVar6[-1] = 0x75b0;
            local_4c = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
            while (pvVar3 < local_4c) {
              piVar6[2] = (int)pvVar3;
              piVar6[1] = (int)sel_objectAtIndex_;
              *piVar6 = (int)pvVar1;
              piVar6[-1] = 0x75d1;
              pvVar4 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
              piVar6[1] = (int)sel_hyperParent;
              *piVar6 = (int)pvVar4;
              piVar6[-1] = 0x75e5;
              pvVar5 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
              if (pvVar5 == local_50) {
                piVar6[2] = (int)&DAT_00360868;
                piVar6[1] = (int)sel_queryHyperInterface_;
                *piVar6 = (int)pvVar4;
                piVar6[-1] = 0x760a;
                pvVar5 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
                if (pvVar5 != (id)0x0) {
                  piVar6[2] = (int)sel_frameBoundingRect;
                  piVar6[1] = (int)pvVar5;
                  *piVar6 = (int)&local_24;
                  piVar6[-1] = 0x7627;
                  _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
                  *(undefined8 *)(piVar6 + 3) = local_1c;
                  *(undefined8 *)(piVar6 + 1) = local_24;
                  *piVar6 = (int)sel_addPoofEffectForUserSpaceRect_;
                  piVar6[-1] = (int)self;
                  piVar6[-2] = 0x7655;
                  _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
                  piVar6 = piVar6 + -1;
                }
                local_4c = (id)((int)local_4c + -1);
                piVar6[1] = (int)sel_removeFromHyperParent;
                *piVar6 = (int)pvVar4;
                piVar6[-1] = 0x766a;
                _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
                piVar6[2] = (int)pvVar3;
                piVar6[1] = (int)sel_removeObjectAtIndex_;
                *piVar6 = (int)pvVar1;
                piVar6[-1] = 0x7683;
                _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
              }
              else {
                pvVar3 = (id)((int)pvVar3 + 1);
              }
            }
            piVar6[1] = (int)sel_hyperRemoveChildrenEndGrouping;
            *piVar6 = (int)local_50;
            piVar6[-1] = 0x76a4;
            _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
            piVar6[1] = (int)sel_count;
            *piVar6 = (int)pvVar2;
            local_50 = (id)0x0;
            piVar6[-1] = 0x76c0;
            pvVar3 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
          } while (pvVar3 != (id)0x0);
        }
        piVar6[1] = (int)sel_userObject;
        *piVar6 = (int)self;
        piVar6[-1] = 0x76dd;
        pvVar1 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
        piVar6[1] = (int)sel_hyperRemoveChildrenEndGrouping;
        *piVar6 = (int)pvVar1;
      }
      piVar6[-1] = 0x76ef;
      _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      piVar6[1] = (int)sel_selectionObject;
      *piVar6 = (int)self;
      piVar6[-1] = 0x7704;
      pvVar1 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      piVar6[1] = (int)sel_endSelectionChanging;
      *piVar6 = (int)pvVar1;
    }
    piVar6[-1] = 0x7716;
    _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
    piVar6[1] = (int)sel_showPendingPoofEffects;
    *piVar6 = (int)self;
    piVar6[-1] = 0x772b;
    _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
    piVar6[1] = (int)sel_sharedAssistantController;
    *piVar6 = (int)cls_HSObjectAssistantController;
    piVar6[-1] = 0x7743;
    pvVar1 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
    piVar6[1] = (int)sel_setTemporaryHide_;
    *piVar6 = (int)pvVar1;
    piVar6[2] = 1;
    piVar6[-1] = 0x775d;
    _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
  }
  return;
}

*/
- (void)performDeleteOperationWithNodesInArray:(id)aArray
{
    if ([aArray count] == 0) {
        return;
    }
    if ([aArray count] == 1) {
        id node = [aArray lastObject];
        id geometry = [node queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry != nil) {
            [self addPoofEffectForUserSpaceRect:[geometry frameBoundingRect]];
        }
        [node removeFromHyperParent];
    } else {
        [[self selectionObject] beginSelectionChanging];
        id combined = [aArray hyperObjectForAllInterfaces];
        id parent = [combined hyperParent];
        if (![combined lastHyperAccessDidReturnMultipleValues]) {
            NSEnumerator *e = [[[combined queryHyperInterface:@protocol(HSGeometryAttributes)] allHyperInterfaces] objectEnumerator];
            id geometry;
            while ((geometry = [e nextObject]) != nil) {
                [self addPoofEffectForUserSpaceRect:[geometry frameBoundingRect]];
            }
            [parent hyperRemoveChildrenBeginGrouping];
            [combined removeFromHyperParent];
            [parent hyperRemoveChildrenEndGrouping];
        } else {
            NSMutableArray *objects = [NSMutableArray arrayWithArray:aArray];
            NSMutableArray *parents = [NSMutableArray arrayWithArray:[parent allHyperInterfaces]];
            id userContainer = [[self userObject] queryHyperInterface:@protocol(HSNodeContainer)];
            NSUInteger userIndex = [parents indexOfObjectIdenticalTo:userContainer];
            [[self userObject] hyperRemoveChildrenBeginGrouping];
            if ([parents count] != 0) {
                id current = (userIndex != NSNotFound) ? userContainer : nil;
                do {
                    if (current == nil) {
                        current = [parents lastObject];
                    }
                    [parents removeObjectIdenticalTo:current];
                    [current hyperRemoveChildrenBeginGrouping];
                    NSUInteger n = [objects count];
                    NSUInteger i = 0;
                    while (i < n) {
                        id child = [objects objectAtIndex:i];
                        if ([child hyperParent] == current) {
                            id geometry = [child queryHyperInterface:@protocol(HSGeometryAttributes)];
                            if (geometry != nil) {
                                [self addPoofEffectForUserSpaceRect:[geometry frameBoundingRect]];
                            }
                            n--;
                            [child removeFromHyperParent];
                            [objects removeObjectAtIndex:i];
                        } else {
                            i++;
                        }
                    }
                    [current hyperRemoveChildrenEndGrouping];
                    current = nil;
                } while ([parents count] != 0);
            }
            [[self userObject] hyperRemoveChildrenEndGrouping];
        }
        [[self selectionObject] endSelectionChanging];
    }
    [self showPendingPoofEffects];
    [[HSObjectAssistantController sharedAssistantController] setTemporaryHide:YES];
}

- (BOOL)containsGroupObjectInNodesArray:(id)aArray
{
    id self_00;
    NSUInteger pvVar1;
    id pvVar2;
    int iVar4;

    self_00 = [aArray queryAnyHyperInterfaces:@protocol(HSCardObjectGroupAttribute)];
    iVar4 = 0;
    pvVar1 = [self_00 count];
    do {
        if ((int)pvVar1 <= iVar4) {
            return NO;
        }
        pvVar2 = [self_00 objectAtIndex:iVar4];
        if ([pvVar2 isGroupObject]) {
            if ([[[pvVar2 hyperParent] queryHyperInterface:@protocol(HSCardGroupAttribute)] isGroupCard]) {
                return YES;
            }
        }
        iVar4 = iVar4 + 1;
    } while( YES );
}

- (BOOL)canPerformDeleteOperationWithNodesInArray:(id)aArray
{
    char cVar1;
    char cVar2;
    NSUInteger pvVar3_2;
    NSUInteger pvVar3_3;
    id pvVar3_6;
    id pvVar4_2;

    cVar2 = [self isEditable];
    if (cVar2 != NO) {
        pvVar3_2 = [aArray count];
        cVar1 = NO;
        if (pvVar3_2 != 0) {
            cVar1 = cVar2;
        }
        cVar2 = cVar1;
        if ((cVar2 != NO) && (pvVar3_3 = [aArray count], pvVar3_3 == 0x1)) {
            if ([aArray lastObject] == [self userObject]) {
                pvVar3_6 = [[aArray lastObject] queryHyperInterface:@protocol(HSNodeChild)];
                pvVar4_2 = [pvVar3_6 hyperParent];
                if (pvVar3_6 == nil) {
                    cVar2 = NO;
                }
                else {
                    cVar2 = 0x1 < [pvVar4_2 hyperCount];
                }
            }
        }
    }
    return cVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000794a @ 0000794a, 168 bytes * /

BOOL FUN_0000794a(HSEditorCardView *self,SEL _cmd,uint handleDoubleClickOutsideNodesWithModifiers)

{
  id pvVar1;
  id pvVar2;
  bool bVar3;
  
  bVar3 = (handleDoubleClickOutsideNodesWithModifiers & 0xffff0000) == 0x100000;
  if (bVar3) {
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    pvVar2 = _objc_msgSend(self,sel_card);
    _objc_msgSend(pvVar1,sel_openDefaultEditingPaneForObject_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAssistant);
    _objc_msgSend(pvVar1,sel_openPaneWithIdentifier_,*(undefined4 *)PTR_PTR_00336018);
  }
  return bVar3;
}

*/
- (BOOL)handleDoubleClickOutsideNodesWithModifiers:(NSUInteger)aModifiers
{
    BOOL handled = (aModifiers & 0xffff0000) == 0x100000;
    if (handled) {
        id assistant = [HSObjectAssistantController sharedAssistantController];
        [assistant openDefaultEditingPaneForObject:[self card]];
        [[assistant objectAssistant] openPaneWithIdentifier:@"HSActionsAssistantPane"];
    }
    return handled;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000079f2 @ 000079f2, 304 bytes * /

BOOL FUN_000079f2(HSEditorCardView *self,SEL _cmd,uint handleMouseUpWithModifiers,id inNode,
                 BOOL nodeIsSelected,id previousEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  if ((((handleMouseUpWithModifiers & 0xffff0000) == 0x120000) &&
      (pvVar1 = _objc_msgSend(previousEvent,sel_type), pvVar1 != (id)0x6)) &&
     (pvVar1 = inNode, pvVar2 = _objc_msgSend(cls_HSImageObjectRestorer,sel_canRestoreNode_,inNode),
     (char)pvVar2 != '\0')) {
    pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_editorSelection);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForRestoreOperation);
    pvVar3 = _objc_msgSend(pvVar1,sel_count);
    if ((pvVar3 == (id)0x1) &&
       (pvVar1 = _objc_msgSend(pvVar1,sel_lastObject,pvVar2), pvVar1 == inNode)) {
      _objc_msgSend(cls_HSImageObjectRestorer,sel_restoreNodeToOriginal_,inNode);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)handleMouseUpWithModifiers:(NSUInteger)aModifiers inNode:(id)aNode nodeIsSelected:(BOOL)aSelected previousEvent:(id)aEvent
{
    if ((aModifiers & 0xffff0000) == 0x120000 && [aEvent type] != 6 && [HSImageObjectRestorer canRestoreNode:aNode]) {
        HSSelectionOperationVerifier *verifier = [[[HSSelectionOperationVerifier alloc] initWithSelection:[self editorSelection]] autorelease];
        id nodes = [verifier selectedNodesArrayForRestoreOperation];
        if ([nodes count] == 1 && [nodes lastObject] == aNode) {
            [HSImageObjectRestorer restoreNodeToOriginal:aNode];
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00007b22 @ 00007b22, 605 bytes * /

BOOL FUN_00007b22(HSEditorCardView *self,SEL _cmd,uint handleClickWithModifiers,uint clickCount,
                 id inNode,BOOL nodeIsSelected)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  undefined4 uVar4;
  undefined *puVar5;
  
  uVar3 = handleClickWithModifiers & 0xffff0000;
  if ((clickCount != 2 || uVar3 != 0x100000) && (uVar3 != 0x120000)) {
    return '\0';
  }
  if (nodeIsSelected != '\0') {
    pvVar1 = _objc_msgSend(self,sel_editorSelection);
    pvVar1 = _objc_msgSend(pvVar1,sel_nodesCount);
    if (pvVar1 < (id)0x2) goto LAB_00007bbd;
  }
  pvVar1 = _objc_msgSend(self,sel_editorSelection);
  _objc_msgSend(pvVar1,sel_selectNode_,inNode);
LAB_00007bbd:
  pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_editorSelection);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  uVar4 = 1;
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForEditingOperationWithImplicitCheck_,1);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 == (id)0x1) {
    pvVar1 = _objc_msgSend(pvVar1,sel_lastObject,uVar4);
    if ((pvVar1 == inNode) && (uVar3 == 0x100000 && clickCount == 2)) {
      puVar5 = &DAT_00360a48;
      pvVar1 = _objc_msgSend(inNode,sel_queryHyperInterface_,&DAT_00360a48);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar5)
        ;
        _objc_msgSend(pvVar1,sel_setActive_explicitlyByUser_,1,1);
        pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
        _objc_msgSend(pvVar1,sel_setSelectedInModelObjectAndBringAssistantToFront_,inNode);
        pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAssistant);
        _objc_msgSend(pvVar1,sel_openPaneWithIdentifier_,*(undefined4 *)PTR_PTR_00336018);
        return '\x01';
      }
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)handleClickWithModifiers:(NSUInteger)aModifiers clickCount:(NSUInteger)aCount inNode:(id)aNode nodeIsSelected:(BOOL)aSelected
{
    NSUInteger modifierFlags = aModifiers & 0xffff0000;
    if ((aCount != 2 || modifierFlags != 0x100000) && modifierFlags != 0x120000) {
        return NO;
    }
    if (!aSelected || [[self editorSelection] nodesCount] >= 2) {
        [[self editorSelection] selectNode:aNode];
    }
    HSSelectionOperationVerifier *verifier = [[[HSSelectionOperationVerifier alloc] initWithSelection:[self editorSelection]] autorelease];
    id nodes = [verifier selectedNodesArrayForEditingOperationWithImplicitCheck:YES];
    if ([nodes count] == 1 && [nodes lastObject] == aNode && modifierFlags == 0x100000 && aCount == 2) {
        if (![[aNode queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
            [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
            [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:aNode];
            [[[HSObjectAssistantController sharedAssistantController] objectAssistant] openPaneWithIdentifier:@"HSActionsAssistantPane"];
        }
        return YES;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00007d7f @ 00007d7f, 481 bytes * /

void FUN_00007d7f(HSEditorCardView *self,SEL _cmd,float zoomToFactor,NSPoint aboutPoint)

{
  float fVar1;
  id self_00;
  id pvVar2;
  float fVar3;
  float fVar4;
  double dVar5;
  SEL op;
  
  dVar5 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar1 = (float)dVar5;
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar3 = ABS(fVar1);
  }
  else {
    fVar3 = 1.0;
  }
  if ((zoomToFactor != 0.0) || (NAN(zoomToFactor))) {
    fVar4 = ABS(zoomToFactor);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= fVar3) {
    fVar4 = fVar3;
  }
  if (fVar4 * 0.0005 < ABS(fVar1 - zoomToFactor)) {
    self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    if (self->_zoomMode != 0) {
      self->_zoomMode = 0;
      _objc_msgSend(self_00,sel_postNotificationName_object_,
                    &cfstr_HSEditorCardViewDidChangeZoomModeNotification,self);
    }
    pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
    op = sel_setZoomFactor_;
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_convertPointFromViewSpaceToUserSpace_,aboutPoint.x,
                             aboutPoint.y);
      _objc_msgSend(self,sel_setZoomFactor_,zoomToFactor);
      op = sel_autosizeCenteringAtUserPoint_respectingLastVisibleContent_;
      zoomToFactor = (float)pvVar2;
    }
    _objc_msgSend(self,op,zoomToFactor);
    _objc_msgSend(self_00,sel_postNotificationName_object_,*(undefined4 *)PTR_00336050,self);
    _objc_msgSend(self,sel_setNeedsDisplayOpenGLSurface_,1);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_00007f60 @ 00007f60, 181 bytes * /

void FUN_00007f60(HSEditorCardView *self,SEL _cmd,NSPoint zoomOutAboutPoint)

{
  undefined *self_00;
  double dVar1;
  undefined4 uVar2;
  float fVar3;
  float local_14;
  
  self_00 = cls_HSEditorZoomController;
  local_14 = 0.0;
  dVar1 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar3 = (float)dVar1;
  uVar2 = 0;
  _objc_msgSend(self_00,sel_nextZoomOutFactor_zoomInFactor_forZoomFactor_,&local_14,0,fVar3);
  if (!NAN(local_14)) {
    _objc_msgSend(self,sel_setZoomMode_,0,uVar2,fVar3);
    _objc_msgSend(self,sel_zoomToFactor_aboutPoint_,local_14,zoomOutAboutPoint.x,zoomOutAboutPoint.y
                 );
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_00008015 @ 00008015, 181 bytes * /

void FUN_00008015(HSEditorCardView *self,SEL _cmd,NSPoint zoomInAboutPoint)

{
  undefined *self_00;
  double dVar1;
  float *pfVar2;
  float fVar3;
  float local_14;
  
  self_00 = cls_HSEditorZoomController;
  local_14 = 0.0;
  dVar1 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar3 = (float)dVar1;
  pfVar2 = &local_14;
  _objc_msgSend(self_00,sel_nextZoomOutFactor_zoomInFactor_forZoomFactor_,0,pfVar2,fVar3);
  if (!NAN(local_14)) {
    _objc_msgSend(self,sel_setZoomMode_,0,pfVar2,fVar3);
    _objc_msgSend(self,sel_zoomToFactor_aboutPoint_,local_14,zoomInAboutPoint.x,zoomInAboutPoint.y);
  }
  return;
}

*/
- (id)editObjectDialogContext
{
    return _editObjectDialogContext;
}

- (void)selectedRuntimeEditorDidChangeAndWantsToActivate:(BOOL)aActivate
{
    [self localNotifyHyperSelectionDidChangeAndActivate:aActivate];
}

- (id)layoutGuidingContext
{
    return [self helperForTracker];
}

- (id)editorSelection
{
    return [self selectionObject];
}

- (id)nodeSelection
{
    id pvVar1_2;

    if ([self selection] == nil) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [self selectionObject];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00008188 @ 00008188, 437 bytes * /

id FUN_00008188(HSEditorCardView *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id extraout_EDX;
  float fVar3;
  double dVar4;
  
  self_00 = _objc_msgSend(cls_HSLayoutGuidingTrackerHelper,sel_helperWithHostView_,self);
  pvVar1 = _objc_msgSend(self,sel_card);
  _objc_msgSend(self_00,sel_setCard_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar1 = _objc_msgSend(pvVar1,sel_enabledArrowToolCanvasLayer);
  pvVar1 = _objc_msgSend(pvVar1,sel_enabledLayoutRulesLayer);
  _objc_msgSend(self_00,sel_setRulesRenderer_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_guidelinesSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_isSnapToObjectsEnabled);
  _objc_msgSend(self_00,sel_setSnapToObjectsEnabled_,(int)(char)pvVar1);
  pvVar1 = _objc_msgSend(self_00,sel_isSnappingEnabled);
  if ((char)pvVar1 != '\0') {
    dVar4 = _objc_msgSend_fpret(self,sel_zoomFactor);
    fVar3 = 5.0 / (float)dVar4;
    _objc_msgSend(self_00,sel_setCommonSnapDelta_,fVar3);
    pvVar1 = _objc_msgSend(self,sel_gridSettings);
    pvVar1 = _objc_msgSend(pvVar1,sel_layoutGrid);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self_00,sel_isSnapToGridEnabled,fVar3);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(pvVar1,sel_gridSpacing,fVar3);
        pvVar1 = extraout_EDX;
        if ((float)extraout_EDX <= (float)pvVar2) {
          pvVar1 = pvVar2;
        }
        _objc_msgSend(self_00,sel_setGridSnapDelta_,pvVar1);
      }
    }
  }
  return self_00;
}

*/
- (id)helperForTracker
{
    HSLayoutGuidingTrackerHelper *helper = [HSLayoutGuidingTrackerHelper helperWithHostView:self];
    [helper setCard:[self card]];
    [helper setRulesRenderer:[[[self rootCanvasLayer] enabledArrowToolCanvasLayer] enabledLayoutRulesLayer]];
    [helper setSnapToObjectsEnabled:[[self guidelinesSettings] isSnapToObjectsEnabled]];
    if ([helper isSnappingEnabled]) {
        float delta = 5.0f / [self zoomFactor];
        [helper setCommonSnapDelta:delta];
        id grid = [[self gridSettings] layoutGrid];
        if (grid != nil && [helper isSnapToGridEnabled]) {
            NSSize spacing = [grid gridSpacing];
            [helper setGridSnapDelta:(spacing.height <= spacing.width ? spacing.width : spacing.height)];
        }
    }
    return helper;
}

- (id)guidelinesSettings
{
    id self_00;
    id pvVar1_3;

    self_00 = [[[self card] stack] guidelinesSettings];
    pvVar1_3 = _guidelinesSettings;
    if (pvVar1_3 != self_00) {
        if (pvVar1_3 != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HSSnapToObjectsDidChangeNotification object:_guidelinesSettings];
            [_guidelinesSettings release];
        }
        _guidelinesSettings = [self_00 retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snapToObjectsDidChange:) name:HSSnapToObjectsDidChangeNotification object:_guidelinesSettings];
        pvVar1_3 = _guidelinesSettings;
    }
    return pvVar1_3;
}

- (void)setEditObjectDialogContext:(id)aContext
{
    if (_editObjectDialogContext != aContext) {
        [_editObjectDialogContext release];
        _editObjectDialogContext = [aContext retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000084c9 @ 000084c9, 479 bytes * /

void FUN_000084c9(HSEditorCardView *self,SEL _cmd,id reflectCardObjectsHiddenStateForObject,
                 BOOL invalidate)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  SEL op;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(reflectCardObjectsHiddenStateForObject,sel_queryHyperInterface_,
                         &DAT_00360b60);
  if (pvVar1 == (id)0x0) {
    return;
  }
  puVar5 = &DAT_00360250;
  pvVar2 = _objc_msgSend(reflectCardObjectsHiddenStateForObject,sel_queryHyperInterface_,
                         &DAT_00360250);
  if (pvVar1 == (id)0x0) {
    return;
  }
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(pvVar1,sel_isVisibleInEditor,puVar5);
  if ((char)pvVar3 == '\0') {
LAB_00008539:
    pcVar4 = sel_hideCardChildIfNotHidden_invalidate_;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_card,puVar5);
    pvVar3 = _objc_msgSend(pvVar3,sel_stack);
    pvVar3 = _objc_msgSend(pvVar3,sel_cardObjectsVisibility);
    pcVar4 = sel_showCardChildIfHidden_invalidate_;
    if (pvVar3 != (id)0x0) {
      if (pvVar3 == (id)0x2) {
        pvVar1 = _objc_msgSend(pvVar1,sel_isHiddenInPlayer);
        op = sel_showCardChildIfHidden_invalidate_;
        if ((char)pvVar1 == '\0') goto LAB_00008555;
        pvVar1 = _objc_msgSend(self,sel_selection);
        pvVar1 = _objc_msgSend(pvVar1,sel_selectedObject);
        pvVar1 = _objc_msgSend(pvVar1,sel_allHyperInterfaces);
        pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,pvVar2);
        pcVar4 = sel_hideCardChildIfNotHidden_invalidate_;
        op = sel_showCardChildIfHidden_invalidate_;
        if ((char)pvVar1 != '\0') goto LAB_00008555;
      }
      else {
        if (pvVar3 != (id)0x1) {
          return;
        }
        pvVar1 = _objc_msgSend(self,sel_selection);
        pvVar1 = _objc_msgSend(pvVar1,sel_selectedObject);
        pvVar1 = _objc_msgSend(pvVar1,sel_allHyperInterfaces);
        pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,pvVar2);
        pcVar4 = sel_showCardChildIfHidden_invalidate_;
        if ((char)pvVar1 == '\0') goto LAB_00008539;
      }
    }
  }
  op = pcVar4;
LAB_00008555:
  _objc_msgSend(self,op,pvVar2,(int)invalidate);
  return;
}

*/
- (void)reflectCardObjectsHiddenStateForObject:(id)aObject invalidate:(BOOL)aInvalidate
{
    id attributes = [aObject queryHyperInterface:@protocol(HSCardObjectAttributes)];
    id child = [aObject queryHyperInterface:@protocol(HSNodeChild)];
    if (attributes == nil || child == nil) {
        return;
    }
    BOOL show;
    NSInteger mode = (NSInteger)[[[self card] stack] cardObjectsVisibility];
    if (mode == 0) {
        show = YES;
    } else if (mode == 2) {
        show = ![attributes isHiddenInPlayer] || [[[[self selection] selectedObject] allHyperInterfaces] containsObject:child];
    } else if (mode == 1) {
        show = [[[[self selection] selectedObject] allHyperInterfaces] containsObject:child];
    } else {
        return;
    }
    if (show) {
        [self showCardChildIfHidden:child invalidate:aInvalidate];
    } else {
        [self hideCardChildIfNotHidden:child invalidate:aInvalidate];
    }
}

- (void)reflectCardObjectsHiddenStateOfObjectsInEnumerator:(id)aEnumerator invalidate:(BOOL)aInvalidate
{
    id pvVar1;

    pvVar1 = [aEnumerator nextObject];
    while (pvVar1 != nil) {
        [self reflectCardObjectsHiddenStateForObject:pvVar1 invalidate:aInvalidate];
        pvVar1 = [aEnumerator nextObject];
    }
}

- (void)showCardChildIfHidden:(id)aHidden invalidate:(BOOL)aInvalidate
{
    id self_00;

    self_00 = [self cardObjects];
    if ([self_00 containsObject:aHidden]) {
        [self unignoreChild:aHidden];
        [self_00 removeObject:aHidden];
        if (aInvalidate != NO) {
            [self invalidateRegionOfChild:aHidden];
        }
    }
}

- (void)hideCardChildIfNotHidden:(id)aHidden invalidate:(BOOL)aInvalidate
{
    id self_00;

    self_00 = [self cardObjects];
    if (![self_00 containsObject:aHidden]) {
        if (aInvalidate != NO) {
            [self invalidateRegionOfChild:aHidden];
        }
        [self_00 addObject:aHidden];
        [self ignoreChild:aHidden];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00008843 @ 00008843, 62 bytes * /

id FUN_00008843(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = *(id *)((int)&self->_nextOnionSkinUserObject + 1);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableSet,sel_new);
    *(id *)((int)&self->_nextOnionSkinUserObject + 1) = pvVar1;
  }
  return pvVar1;
}

*/
- (id)cardObjects
{
    if (_cardObjects == nil) {
        _cardObjects = [NSMutableSet new];
    }
    return _cardObjects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00008881 @ 00008881, 186 bytes * /

void FUN_00008881(HSEditorCardView *self,SEL _cmd,id setUserObject)

{
  id pvVar1;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_userObject);
  if (pvVar1 != setUserObject) {
    _objc_msgSend(*(id *)((int)&self->_nextOnionSkinUserObject + 1),sel_removeAllObjects);
    local_1c = self;
    local_18 = PTR_s_HSToolView_0034db70;
    _objc_msgSendSuper(&local_1c,sel_setUserObject_,setUserObject);
    pvVar1 = _objc_msgSend(self,sel_card);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperEnumerator);
      _objc_msgSend(self,sel_reflectCardObjectsHiddenStateOfObjectsInEnumerator_invalidate_,pvVar1,0
                   );
    }
  }
  return;
}

*/
- (void)setUserObject:(id)aObject
{
    if ([self userObject] != aObject) {
        [_cardObjects removeAllObjects];
        [super setUserObject:aObject];
        id card = [self card];
        if (card != nil) {
            [self reflectCardObjectsHiddenStateOfObjectsInEnumerator:[card hyperEnumerator] invalidate:NO];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000893b @ 0000893b, 1355 bytes * /

void FUN_0000893b(HSEditorCardView *self,SEL _cmd,int setOnionSkinMode)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL pcVar5;
  undefined *puVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  
  self->_newOnionSkinModeIsInRenderingProcess = '\x01';
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360b4c);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperIndex);
  pvVar2 = _objc_msgSend(self,sel_card);
  pvVar2 = _objc_msgSend(pvVar2,sel_stack);
  puVar6 = &DAT_00360034;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00360034);
  if (setOnionSkinMode == 1) {
    if (pvVar1 == (id)0x0) goto LAB_000089ea;
    pvVar4 = (id)0x0;
    pvVar3 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,(int)pvVar1 + -1);
  }
  else if (setOnionSkinMode == 2) {
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperCount,puVar6);
    if ((id)((int)pvVar4 + -1) <= pvVar1) goto LAB_000089ea;
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,(int)pvVar1 + 1);
    pvVar3 = (id)0x0;
  }
  else if (setOnionSkinMode == 3) {
    if (pvVar1 == (id)0x0) {
      pvVar3 = (id)0x0;
    }
    else {
      puVar6 = (undefined *)((int)pvVar1 + -1);
      pvVar3 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,puVar6);
    }
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperCount,puVar6);
    if (pvVar1 < (id)((int)pvVar4 + -1)) {
      pvVar4 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,(int)pvVar1 + 1);
    }
    else {
      pvVar4 = (id)0x0;
    }
  }
  else {
LAB_000089ea:
    pvVar3 = (id)0x0;
    pvVar4 = (id)0x0;
  }
  _objc_msgSend(self,sel_setUserObjectForNextOnionSkin_previousOnionSkin_,pvVar4,pvVar3);
  pvVar1 = _objc_msgSend(self,sel_previousOnionSkinUserObject);
  pvVar2 = _objc_msgSend(self,sel_getCardImageForCard_,pvVar1);
  pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar4 = _objc_msgSend(pvVar4,sel_isEnabledOnionSkinPreviousCanvasLayer);
  if (pvVar2 == (id)0x0) {
    if ((char)pvVar4 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1);
      puVar6 = PTR_PTR_00336048;
      pvVar1 = *(id *)PTR_PTR_00336048;
      pvVar3 = (id)0x0;
      _objc_msgSend(pvVar2,sel_setSublayerIdentifier_isEnabledByDefault_,pvVar1,0);
      pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer);
      pvVar2 = _objc_msgSend(pvVar2,sel_isEnabledOnionSkinPreviousCanvasLayer);
      if ((char)pvVar2 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1,pvVar3);
        pvVar2 = *(id *)puVar6;
        pcVar5 = sel_disableSublayerForIdentifier_;
        goto LAB_00008c91;
      }
    }
  }
  else {
    if ((char)pvVar4 == '\0') {
      pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1);
      puVar6 = PTR_PTR_00336048;
      pvVar1 = *(id *)PTR_PTR_00336048;
      pvVar3 = (id)0x1;
      _objc_msgSend(pvVar4,sel_setSublayerIdentifier_isEnabledByDefault_,pvVar1,1);
      pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer);
      pvVar4 = _objc_msgSend(pvVar4,sel_isEnabledOnionSkinPreviousCanvasLayer);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1,pvVar3);
        pvVar1 = *(id *)puVar6;
        _objc_msgSend(pvVar4,sel_enableSublayerForIdentifier_,pvVar1);
      }
    }
    pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1,pvVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_sublayerForIdentifier_,*(undefined4 *)PTR_PTR_00336048);
    pcVar5 = sel_setCGImage_;
LAB_00008c91:
    _objc_msgSend(pvVar1,pcVar5,pvVar2);
    pvVar1 = pvVar2;
  }
  pvVar1 = _objc_msgSend(self,sel_nextOnionSkinUserObject,pvVar1,pvVar3);
  pvVar2 = _objc_msgSend(self,sel_getCardImageForCard_,pvVar1);
  pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar4 = _objc_msgSend(pvVar4,sel_isEnabledOnionSkinNextCanvasLayer);
  if (pvVar2 == (id)0x0) {
    if ((char)pvVar4 == '\0') goto LAB_00008e74;
    pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1);
    puVar6 = PTR_PTR_00336044;
    uVar7 = *(undefined4 *)PTR_PTR_00336044;
    uVar8 = 0;
    _objc_msgSend(pvVar1,sel_setSublayerIdentifier_isEnabledByDefault_,uVar7,0);
    pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEnabledOnionSkinNextCanvasLayer);
    if ((char)pvVar1 == '\0') goto LAB_00008e74;
    pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer,uVar7,uVar8);
    pvVar2 = *(id *)puVar6;
    pcVar5 = sel_disableSublayerForIdentifier_;
  }
  else {
    if ((char)pvVar4 == '\0') {
      pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1);
      puVar6 = PTR_PTR_00336044;
      pvVar1 = *(id *)PTR_PTR_00336044;
      pvVar3 = (id)0x1;
      _objc_msgSend(pvVar4,sel_setSublayerIdentifier_isEnabledByDefault_,pvVar1,1);
      pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer);
      pvVar4 = _objc_msgSend(pvVar4,sel_isEnabledOnionSkinNextCanvasLayer);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1,pvVar3);
        pvVar1 = *(id *)puVar6;
        _objc_msgSend(pvVar4,sel_enableSublayerForIdentifier_,pvVar1);
      }
    }
    pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer,pvVar1,pvVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_sublayerForIdentifier_,*(undefined4 *)PTR_PTR_00336044);
    pcVar5 = sel_setCGImage_;
  }
  _objc_msgSend(pvVar1,pcVar5,pvVar2);
LAB_00008e74:
  self->_newOnionSkinModeIsInRenderingProcess = '\0';
  return;
}

*/
- (void)setOnionSkinMode:(NSInteger)aMode
{
    _newOnionSkinModeIsInRenderingProcess = YES;
    NSUInteger index = [[[self card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperIndex];
    id container = [[[self card] stack] queryHyperInterface:@protocol(HSNodeContainer)];
    id previousCard = nil;
    id nextCard = nil;
    if (aMode == 1) {
        if (index != 0) {
            previousCard = [container hyperChildAtIndex:index - 1];
        }
    } else if (aMode == 2) {
        if ((NSInteger)index < (NSInteger)[container hyperCount] - 1) {
            nextCard = [container hyperChildAtIndex:index + 1];
        }
    } else if (aMode == 3) {
        if (index != 0) {
            previousCard = [container hyperChildAtIndex:index - 1];
        }
        if ((NSInteger)index < (NSInteger)[container hyperCount] - 1) {
            nextCard = [container hyperChildAtIndex:index + 1];
        }
    }
    [self setUserObjectForNextOnionSkin:nextCard previousOnionSkin:previousCard];

    id previousImage = [self getCardImageForCard:[self previousOnionSkinUserObject]];
    BOOL previousEnabled = [[self rootCanvasLayer] isEnabledOnionSkinPreviousCanvasLayer];
    if (previousImage == nil) {
        if (previousEnabled) {
            [[self rootCanvasLayer] setSublayerIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier" isEnabledByDefault:NO];
            if ([[self rootCanvasLayer] isEnabledOnionSkinPreviousCanvasLayer]) {
                [[self rootCanvasLayer] disableSublayerForIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier"];
            }
        }
    } else {
        if (!previousEnabled) {
            [[self rootCanvasLayer] setSublayerIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier" isEnabledByDefault:YES];
            if (![[self rootCanvasLayer] isEnabledOnionSkinPreviousCanvasLayer]) {
                [[self rootCanvasLayer] enableSublayerForIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier"];
            }
        }
        [[[self rootCanvasLayer] sublayerForIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier"] setCGImage:previousImage];
    }

    id nextImage = [self getCardImageForCard:[self nextOnionSkinUserObject]];
    BOOL nextEnabled = [[self rootCanvasLayer] isEnabledOnionSkinNextCanvasLayer];
    if (nextImage == nil) {
        if (nextEnabled) {
            [[self rootCanvasLayer] setSublayerIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier" isEnabledByDefault:NO];
            if ([[self rootCanvasLayer] isEnabledOnionSkinNextCanvasLayer]) {
                [[self rootCanvasLayer] disableSublayerForIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier"];
            }
        }
    } else {
        if (!nextEnabled) {
            [[self rootCanvasLayer] setSublayerIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier" isEnabledByDefault:YES];
            if (![[self rootCanvasLayer] isEnabledOnionSkinNextCanvasLayer]) {
                [[self rootCanvasLayer] enableSublayerForIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier"];
            }
        }
        [[[self rootCanvasLayer] sublayerForIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier"] setCGImage:nextImage];
    }
    _newOnionSkinModeIsInRenderingProcess = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00008e86 @ 00008e86, 340 bytes * /

void FUN_00008e86(HSEditorCardView *self,SEL _cmd,id setUserObjectForNextOnionSkin,
                 id previousOnionSkin)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  
  pvVar2 = *(id *)((int)&self->_previousOnionSkinUserObject + 1);
  if (pvVar2 == previousOnionSkin) {
    _objc_msgSend(self,sel_unregisterAttributesChangesForOnionSkinUserObject_,pvVar2);
  }
  pvVar1 = *(id *)((int)&self->_lastActiveWindow + 1);
  if (pvVar1 == setUserObjectForNextOnionSkin) {
    _objc_msgSend(self,sel_unregisterAttributesChangesForOnionSkinUserObject_,pvVar1);
  }
  self_00 = *(id *)((int)&self->_previousOnionSkinUserObject + 1);
  if (self_00 != setUserObjectForNextOnionSkin) {
    if ((self_00 != (id)0x0) && (pvVar2 != previousOnionSkin)) {
      _objc_msgSend(self,sel_unregisterAttributesChangesForOnionSkinUserObject_,self_00);
      self_00 = *(id *)((int)&self->_previousOnionSkinUserObject + 1);
    }
    _objc_msgSend(self_00,sel_release);
    pvVar2 = _objc_msgSend(setUserObjectForNextOnionSkin,sel_retain);
    *(id *)((int)&self->_previousOnionSkinUserObject + 1) = pvVar2;
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self,sel_registerAttributesChangesForOnionSkinUserObject_,pvVar2);
    }
  }
  pvVar2 = *(id *)((int)&self->_lastActiveWindow + 1);
  if (pvVar2 != previousOnionSkin) {
    if ((pvVar2 != (id)0x0) && (pvVar1 != setUserObjectForNextOnionSkin)) {
      _objc_msgSend(self,sel_unregisterAttributesChangesForOnionSkinUserObject_,pvVar2);
      pvVar2 = *(id *)((int)&self->_lastActiveWindow + 1);
    }
    _objc_msgSend(pvVar2,sel_release);
    pvVar2 = _objc_msgSend(previousOnionSkin,sel_retain);
    *(id *)((int)&self->_lastActiveWindow + 1) = pvVar2;
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self,sel_registerAttributesChangesForOnionSkinUserObject_,pvVar2);
    }
  }
  return;
}

*/
- (void)setUserObjectForNextOnionSkin:(id)aSkin previousOnionSkin:(id)aSkin2
{
    id oldNext = _nextOnionSkinUserObject;
    if (oldNext == aSkin2) {
        [self unregisterAttributesChangesForOnionSkinUserObject:oldNext];
    }
    id oldPrevious = _previousOnionSkinUserObject;
    if (oldPrevious == aSkin) {
        [self unregisterAttributesChangesForOnionSkinUserObject:oldPrevious];
    }
    if (_nextOnionSkinUserObject != aSkin) {
        if (_nextOnionSkinUserObject != nil && oldNext != aSkin2) {
            [self unregisterAttributesChangesForOnionSkinUserObject:_nextOnionSkinUserObject];
        }
        [_nextOnionSkinUserObject release];
        _nextOnionSkinUserObject = [aSkin retain];
        if (_nextOnionSkinUserObject != nil) {
            [self registerAttributesChangesForOnionSkinUserObject:_nextOnionSkinUserObject];
        }
    }
    if (_previousOnionSkinUserObject != aSkin2) {
        if (_previousOnionSkinUserObject != nil && oldPrevious != aSkin) {
            [self unregisterAttributesChangesForOnionSkinUserObject:_previousOnionSkinUserObject];
        }
        [_previousOnionSkinUserObject release];
        _previousOnionSkinUserObject = [aSkin2 retain];
        if (_previousOnionSkinUserObject != nil) {
            [self registerAttributesChangesForOnionSkinUserObject:_previousOnionSkinUserObject];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000036c5 @ 000036c5, 14 bytes * /

id FUN_000036c5(HSEditorCardView *self,SEL _cmd)

{
  return *(id *)((int)&self->_previousOnionSkinUserObject + 1);
}

*/
- (id)nextOnionSkinUserObject
{
    return _nextOnionSkinUserObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000036b7 @ 000036b7, 14 bytes * /

id FUN_000036b7(HSEditorCardView *self,SEL _cmd)

{
  return *(id *)((int)&self->_lastActiveWindow + 1);
}

*/
- (id)previousOnionSkinUserObject
{
    return _previousOnionSkinUserObject;
}

- (void)unregisterAttributesChangesForOnionSkinUserObject:(id)aObject
{
    int uVar1;

    uVar1 = HSActualDidAttributeChanges;
    [aObject removeObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSSizeAttribute)];
    [aObject removeObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSVisualAttribute)];
    [aObject removeObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [aObject removeObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSImageAttribute)];
}

- (void)registerAttributesChangesForOnionSkinUserObject:(id)aObject
{
    int uVar1;

    uVar1 = HSActualDidAttributeChanges;
    [aObject addObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSSizeAttribute) withPriority:-0.75];
    [aObject addObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
    [aObject addObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75];
    [aObject addObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSImageAttribute) withPriority:-0.75];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000091d8 @ 000091d8, 323 bytes * /

void FUN_000091d8(HSEditorCardView *self,SEL _cmd,NSRect addPoofEffectForUserSpaceRect)

{
  char cVar1;
  id pvVar2;
  float fVar3;
  float fVar4;
  undefined1 local_24 [20];
  
  cVar1 = _NSIsEmptyRect(addPoofEffectForUserSpaceRect.origin,
                         addPoofEffectForUserSpaceRect.size.width,
                         addPoofEffectForUserSpaceRect.size.height);
  if (cVar1 == '\0') {
    fVar3 = addPoofEffectForUserSpaceRect.size.width * 0.5 + addPoofEffectForUserSpaceRect.origin.x;
    fVar4 = addPoofEffectForUserSpaceRect.size.height * 0.5 + addPoofEffectForUserSpaceRect.origin.y
    ;
    _objc_msgSend(cls_NSValue,sel_valueWithPoint_,fVar3,fVar4);
    _objc_msgSend(self,sel_convertPointFromUserSpaceToViewSpace_,fVar3,fVar4);
    _objc_msgSend_stret(local_24,self,sel_visibleRect);
    pvVar2 = _objc_msgSend(self,sel_mouse_inRect_);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_poofPointsQueue);
      _objc_msgSend(pvVar2,sel_addObject_);
    }
  }
  return;
}

*/
- (void)addPoofEffectForUserSpaceRect:(NSRect)aRect
{
    if (!NSIsEmptyRect(aRect)) {
        NSPoint center = NSMakePoint(NSMidX(aRect), NSMidY(aRect));
        NSValue *value = [NSValue valueWithPoint:center];
        NSPoint viewPoint = [self convertPointFromUserSpaceToViewSpace:center];
        if ([self mouse:viewPoint inRect:[self visibleRect]]) {
            [[self poofPointsQueue] addObject:value];
        }
    }
}

- (id)poofPointsQueue
{
    id pvVar1;

    pvVar1 = _poofPointsQueue;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _poofPointsQueue = pvVar1;
    }
    return pvVar1;
}

- (void)poofEffectAnimationDidEnd:(id)aEnd
{
    int iVar1;

    iVar1 = _numberOfRunningPoofEffects + -1;
    _numberOfRunningPoofEffects = iVar1;
    if (iVar1 == 0) {
        [self HSEditorCardView_reflectObjectsDidRelayout];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00009390 @ 00009390, 480 bytes * /

void FUN_00009390(HSEditorCardView *self,SEL _cmd)

{
  undefined *puVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  HSEditorCardView *extraout_EDX_02;
  HSEditorCardView *pHVar5;
  undefined *puVar6;
  undefined4 uVar7;
  
  pvVar3 = _objc_msgSend(self->_poofPointsQueue,sel_count);
  if (pvVar3 != (id)0x0) {
    uVar7 = 0;
    pHVar5 = self;
    puVar6 = sel_HSEditorCardView_reflectObjectsDidRelayout;
    _objc_msgSend(cls_NSObject,sel_cancelPreviousPerformRequestsWithTarget_selector_object_,self,
                  sel_HSEditorCardView_reflectObjectsDidRelayout,0);
    pvVar3 = _objc_msgSend(self,sel_window);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(self->_poofPointsQueue,sel_objectEnumerator,pHVar5,puVar6,uVar7);
      pvVar4 = _objc_msgSend(pvVar3,sel_nextObject);
      if (pvVar4 != (id)0x0) {
        puVar1 = *(undefined **)PTR_0033607c;
        uVar2 = *(undefined4 *)(PTR_0033607c + 4);
        do {
          pvVar4 = _objc_msgSend(pvVar4,sel_pointValue);
          pvVar4 = _objc_msgSend(self,sel_convertPointFromUserSpaceToViewSpace_,pvVar4,extraout_EDX)
          ;
          pvVar4 = _objc_msgSend(self,sel_convertPoint_toView_,pvVar4,extraout_EDX_00,0);
          self_00 = _objc_msgSend(self,sel_window);
          pvVar4 = _objc_msgSend(self_00,sel_convertBaseToScreen_,pvVar4,extraout_EDX_01);
          pHVar5 = extraout_EDX_02;
          puVar6 = puVar1;
          uVar7 = uVar2;
          _NSShowAnimationEffect
                    (10,pvVar4,extraout_EDX_02,puVar1,uVar2,self,sel_poofEffectAnimationDidEnd_,0);
          self->_numberOfRunningPoofEffects = self->_numberOfRunningPoofEffects + 1;
          pvVar4 = _objc_msgSend(pvVar3,sel_nextObject);
        } while (pvVar4 != (id)0x0);
      }
    }
    _objc_msgSend(self->_poofPointsQueue,sel_removeAllObjects,pHVar5,puVar6,uVar7);
  }
  return;
}

*/
- (void)showPendingPoofEffects
{
    if ([_poofPointsQueue count] != 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSEditorCardView_reflectObjectsDidRelayout) object:nil];
        if ([self window] != nil) {
            NSEnumerator *e = [_poofPointsQueue objectEnumerator];
            id value;
            while ((value = [e nextObject]) != nil) {
                NSPoint viewPoint = [self convertPointFromUserSpaceToViewSpace:[value pointValue]];
                NSPoint windowPoint = [self convertPoint:viewPoint toView:nil];
                NSPoint screenPoint = [[self window] convertBaseToScreen:windowPoint];
                NSShowAnimationEffect(NSAnimationEffectPoof, screenPoint, NSZeroSize, self, @selector(poofEffectAnimationDidEnd:), NULL);
                _numberOfRunningPoofEffects++;
            }
        }
        [_poofPointsQueue removeAllObjects];
    }
}

- (void)changeDocumentBackgroundColor:(id)aColor
{
    id pvVar1_2;

    pvVar1_2 = [[self selectedHyperObject] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    if (pvVar1_2 != nil) {
        [pvVar1_2 applySystemFontPanelDocumentBackgroundColor:[aColor color]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000095e7 @ 000095e7, 382 bytes * /

void FUN_000095e7(HSEditorCardView *self,SEL _cmd,id changeAttributes)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar3 = &DAT_00360570;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360570);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_selectedHyperObject,puVar3);
    puVar3 = &DAT_00360a48;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00360a48);
    pvVar2 = _objc_msgSend(pvVar2,sel_isLocked);
    op = sel_applyCharacterAttributesWithAttributesConverter_;
    if ((char)pvVar2 == '\0') goto LAB_00009685;
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar3);
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  if (pvVar2 != (id)0x2) {
    return;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_toolSettings,puVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar1 = _objc_msgSend(pvVar2,sel_userObjectPrototypeForTool_,pvVar1);
  puVar3 = &DAT_00360a5c;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360a5c);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(cls_NSColorPanel,sel_sharedColorPanel,puVar3);
  changeAttributes = _objc_msgSend(pvVar2,sel_color);
  op = sel_setHyperSolidColor_;
LAB_00009685:
  _objc_msgSend(pvVar1,op,changeAttributes);
  return;
}

*/
- (void)changeAttributes:(id)aAttributes
{
    id text = [[self selectedHyperObject] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    if (text != nil && ![[[self selectedHyperObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
        [text applyCharacterAttributesWithAttributesConverter:aAttributes];
        return;
    }
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([toolManager selectedToolTag] != 2) {
        return;
    }
    id prototype = [[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]];
    id solid = [prototype queryHyperInterface:@protocol(HSGenericSolidColorAttributes)];
    if (solid != nil) {
        [solid setHyperSolidColor:[[NSColorPanel sharedColorPanel] color]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00009765 @ 00009765, 609 bytes * /

void FUN_00009765(HSEditorCardView *self,SEL _cmd,id changeColor)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  undefined *puVar4;
  SEL pcVar5;
  
  pvVar1 = _objc_msgSend(cls_HSColorWell,sel_hasActiveColorWell);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_selectedHyperObject);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00360a48);
    pvVar2 = _objc_msgSend(pvVar2,sel_isLocked);
    if ((char)pvVar2 == '\0') {
      self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360a5c);
      puVar4 = &DAT_00360a84;
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360a84);
      if (self_00 != (id)0x0) {
        puVar4 = &DAT_00360ae8;
        pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360ae8);
        if ((pvVar3 == (id)0x0) ||
           (pvVar3 = _objc_msgSend(pvVar3,sel_backgroundGraphics,puVar4), pvVar3 != (id)0x0)) {
          puVar4 = _objc_msgSend(changeColor,sel_color,puVar4);
          pcVar5 = sel_setHyperSolidColor_;
        }
        else {
          self_00 = _objc_msgSend(pvVar1,sel_vg,puVar4);
          puVar4 = _objc_msgSend(changeColor,sel_color);
          pcVar5 = sel_setHyperStrokeColor_;
        }
        _objc_msgSend(self_00,pcVar5,puVar4);
      }
      pvVar1 = _objc_msgSend(changeColor,sel_color,puVar4);
      pcVar5 = sel_setHyperOutlineColor_;
      goto LAB_000099b9;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  if (pvVar2 != (id)0x2) {
    return;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar1 = _objc_msgSend(pvVar2,sel_primaryUserObjectPrototypeForTool_,pvVar1);
  puVar4 = &DAT_00360a5c;
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360a5c);
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(changeColor,sel_color,puVar4);
  pcVar5 = sel_setHyperSolidColor_;
LAB_000099b9:
  _objc_msgSend(pvVar2,pcVar5,pvVar1);
  return;
}

*/
- (void)changeColor:(id)aColor
{
    if ([HSColorWell hasActiveColorWell]) {
        return;
    }
    id selected = [self selectedHyperObject];
    if (selected != nil && ![[[self selectedHyperObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
        id solid = [selected queryHyperInterface:@protocol(HSGenericSolidColorAttributes)];
        id outline = [selected queryHyperInterface:@protocol(HSMutableOutlineAttributes)];
        if (solid != nil) {
            id background = [selected queryHyperInterface:@protocol(HSBackgroundAttributes)];
            if (background == nil || [background backgroundGraphics] != nil) {
                [solid setHyperSolidColor:[aColor color]];
            } else {
                [[selected vg] setHyperStrokeColor:[aColor color]];
            }
        }
        [outline setHyperOutlineColor:[aColor color]];
        return;
    }
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([toolManager selectedToolTag] != 2) {
        return;
    }
    id prototype = [[toolManager toolSettings] primaryUserObjectPrototypeForTool:[toolManager currentTool]];
    id solid = [prototype queryHyperInterface:@protocol(HSGenericSolidColorAttributes)];
    if (solid != nil) {
        [solid setHyperSolidColor:[aColor color]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000099c6 @ 000099c6, 409 bytes * /

void FUN_000099c6(HSEditorCardView *self,SEL _cmd,id modifyFont)

{
  float fVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  SEL op;
  undefined *puVar6;
  
  self_00 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar3 = _objc_msgSend(pvVar2,sel_selectedToolTag);
  op = sel_modifyFont_;
  if (pvVar3 == (id)0x2) {
    pvVar3 = _objc_msgSend(pvVar2,sel_toolSettings);
    pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
    pvVar2 = _objc_msgSend(pvVar3,sel_userObjectPrototypeForTool_,pvVar2);
    puVar6 = &DAT_00360570;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00360570);
    dVar5 = _objc_msgSend_fpret(pvVar2,sel_hyperFontSize);
    pvVar3 = _objc_msgSend(pvVar2,sel_hyperFont);
    pvVar4 = _objc_msgSend(modifyFont,sel_tag);
    if (pvVar4 == (id)0x3) {
      fVar1 = 1.0;
    }
    else {
      pvVar4 = _objc_msgSend(modifyFont,sel_tag,puVar6);
      if (pvVar4 != (id)0x4) {
        return;
      }
      fVar1 = -1.0;
    }
    modifyFont = _objc_msgSend(self_00,sel_convertFont_toSize_,pvVar3,(float)dVar5 + fVar1);
    self_00 = pvVar2;
    op = sel_setHyperFont_;
  }
  _objc_msgSend(self_00,op,modifyFont);
  return;
}

*/
- (void)modifyFont:(id)aFont
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([toolManager selectedToolTag] != 2) {
        [fontManager modifyFont:aFont];
        return;
    }
    id prototype = [[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]];
    id fontAttributes = [prototype queryHyperInterface:@protocol(HSGenericFontAttributes)];
    float size = [fontAttributes hyperFontSize];
    NSFont *font = [fontAttributes hyperFont];
    float delta;
    if ([aFont tag] == 3) {
        delta = 1.0f;
    } else if ([aFont tag] == 4) {
        delta = -1.0f;
    } else {
        return;
    }
    [fontAttributes setHyperFont:[fontManager convertFont:font toSize:size + delta]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00009b5f @ 00009b5f, 302 bytes * /

void FUN_00009b5f(HSEditorCardView *self,SEL _cmd,id orderFrontFontPanel)

{
  id pvVar1;
  id pvVar2;
  char local_11;
  
  pvVar1 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
  _objc_msgSend(pvVar1,sel_orderFrontFontPanel_,orderFrontFontPanel);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  if (pvVar2 == (id)0x2) {
    pvVar2 = _objc_msgSend(pvVar1,sel_toolSettings,orderFrontFontPanel);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    pvVar1 = _objc_msgSend(pvVar2,sel_userObjectPrototypeForTool_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360570);
    if (pvVar1 != (id)0x0) {
      local_11 = '\0';
      pvVar1 = _objc_msgSend(pvVar1,sel_fontForSystemFontPanelIsMultiple_,&local_11);
      pvVar2 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
      _objc_msgSend(pvVar2,sel_setSelectedFont_isMultiple_,pvVar1,(int)local_11);
    }
  }
  return;
}

*/
- (void)orderFrontFontPanel:(id)aPanel
{
    [[NSFontManager sharedFontManager] orderFrontFontPanel:aPanel];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([toolManager selectedToolTag] == 2) {
        id prototype = [[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]];
        id fontAttributes = [prototype queryHyperInterface:@protocol(HSGenericFontAttributes)];
        if (fontAttributes != nil) {
            BOOL isMultiple = NO;
            NSFont *font = [fontAttributes fontForSystemFontPanelIsMultiple:&isMultiple];
            [[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:isMultiple];
        }
    }
}

- (void)changeFont:(id)aFont
{
    id pvVar2;
    id pvVar1_2;

    pvVar2 = [[self selectedHyperObject] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    pvVar1_2 = [HSToolManager sharedToolManager];
    if (pvVar2 == nil) {
        if ([pvVar1_2 selectedToolTag] != 0x2) {
            return;
        }
        pvVar2 = [[[pvVar1_2 toolSettings] userObjectPrototypeForTool:[pvVar1_2 currentTool]] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    }
    else {
        if ([[[self selectedHyperObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
            return;
        }
    }
    [pvVar2 applyFontWithFontConverter:aFont];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00009dda @ 00009dda, 119 bytes * /

void FUN_00009dda(HSEditorCardView *self,SEL _cmd,id hideAuxiliaryIconsDidChange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar1 = _objc_msgSend(pvVar1,sel_arrowToolCanvasLayer);
  pvVar2 = _objc_msgSend(self,sel_isAuxiliaryIconsCanvasLayerEnabled);
  _objc_msgSend(pvVar1,sel_setSublayerIdentifier_isEnabledByDefault_,*(undefined4 *)PTR_PTR_00336024
                ,(int)(char)pvVar2);
  return;
}

*/
- (void)hideAuxiliaryIconsDidChange:(id)aChange
{
    [[[self rootCanvasLayer] arrowToolCanvasLayer] setSublayerIdentifier:@"HSAuxiliaryIconsCanvasLayer" isEnabledByDefault:[self isAuxiliaryIconsCanvasLayerEnabled]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00009e51 @ 00009e51, 125 bytes * /

void FUN_00009e51(HSEditorCardView *self,SEL _cmd,id snapToObjectsDidChange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self->_guidelinesSettings,sel_isSnapToObjectsEnabled);
  pvVar2 = _objc_msgSend(self,sel_rootCanvasLayer);
  pvVar2 = _objc_msgSend(pvVar2,sel_arrowToolCanvasLayer);
  _objc_msgSend(pvVar2,sel_setSublayerIdentifier_isEnabledByDefault_,*(undefined4 *)PTR_PTR_00336040
                ,(int)(char)pvVar1);
  return;
}

*/
- (void)snapToObjectsDidChange:(id)aChange
{
    BOOL snapEnabled = [_guidelinesSettings isSnapToObjectsEnabled];
    [[[self rootCanvasLayer] arrowToolCanvasLayer] setSublayerIdentifier:@"HSLayoutRulesCanvasLayer" isEnabledByDefault:snapEnabled];
}

- (void)gridSettingsDidChange:(id)aChange
{
    [self setNeedsDisplayOpenGLSurfaceInRect:[self cardViewingRect]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00009f2a @ 00009f2a, 219 bytes * /

BOOL FUN_00009f2a(HSEditorCardView *self,SEL _cmd,id updateSelectionWithSelectionAccessor)

{
  id pvVar1;
  SEL op;
  id *ppvVar2;
  id local_1c;
  id local_18;
  HSEditorCardView *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(updateSelectionWithSelectionAccessor,sel_queryHyperInterface_,&DAT_00360840
                        );
  if (pvVar1 != (id)0x0) {
    local_18 = (id)0x0;
    local_1c = (id)0x0;
    ppvVar2 = &local_18;
    _objc_msgSend(updateSelectionWithSelectionAccessor,sel_getSelectedHyperObject_orObjects_,
                  &local_1c,ppvVar2);
    pvVar1 = local_18;
    op = sel_scrollToObjects_;
    if (local_18 == (id)0x0) {
      pvVar1 = _objc_msgSend(local_1c,sel_queryHyperInterface_,&DAT_00360868,ppvVar2);
      op = sel_scrollToObject_;
    }
    _objc_msgSend(self,op,pvVar1,ppvVar2);
  }
  local_14 = self;
  local_10 = PTR_s_HSToolView_0034db70;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_updateSelectionWithSelectionAccessor_,
                              updateSelectionWithSelectionAccessor);
  return (BOOL)pvVar1;
}

*/
- (BOOL)updateSelectionWithSelectionAccessor:(id)aAccessor
{
    if ([aAccessor queryHyperInterface:@protocol(HSCardObjectSelectionAccessor)] != nil) {
        id object = nil;
        id objects = nil;
        [aAccessor getSelectedHyperObject:&object orObjects:&objects];
        if (objects != nil) {
            [self scrollToObjects:objects];
        } else {
            [self scrollToObject:[object queryHyperInterface:@protocol(HSGeometryAttributes)]];
        }
    }
    return [super updateSelectionWithSelectionAccessor:aAccessor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000a005 @ 0000a005, 622 bytes * /

void FUN_0000a005(HSEditorCardView *self,SEL _cmd,id selectionDidChange,BOOL wasExpanded)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  undefined *puVar4;
  undefined4 extraout_EDX;
  double dVar5;
  undefined4 uVar6;
  char *pcVar7;
  char local_1d;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_HSEditorCardView_selectedTextObject);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self,sel_rememberAttributesForTextView_,pvVar1);
  }
  pvVar1 = _objc_msgSend(self,sel_HSEditorCardView_selectedScaledObject);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_affineFrameSize);
    *(id *)((int)&self->_initialFontSize + 1) = pvVar2;
    *(undefined4 *)((int)&self->_initialWidth + 1) = extraout_EDX;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360570);
    if (pvVar1 != (id)0x0) {
      dVar5 = _objc_msgSend_fpret(pvVar1,sel_hyperFontSize);
      *(float *)((int)&self->_cardObjects + 1) = (float)dVar5;
    }
  }
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  iVar3 = (int)wasExpanded;
  _objc_msgSendSuper(&local_1c,sel_selectionDidChange_wasExpanded_,selectionDidChange,iVar3);
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar4 = &DAT_00360570;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360570);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager,puVar4);
    uVar6 = 1;
    _objc_msgSend(pvVar2,sel_fontPanel_,1);
    local_1d = '\0';
    pvVar2 = _objc_msgSend(pvVar1,sel_isHyperProxy);
    if ((char)pvVar2 == '\0') {
      pcVar7 = &local_1d;
      puVar4 = _objc_msgSend(pvVar1,sel_fontForSystemFontPanelIsMultiple_,pcVar7);
    }
    else {
      pvVar2 = _objc_msgSend(pvVar1,sel_allHyperInterfaces,uVar6);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,0);
      pcVar7 = (char *)0x0;
      puVar4 = _objc_msgSend(pvVar2,sel_fontForSystemFontPanelIsMultiple_,0);
      pvVar1 = _objc_msgSend(pvVar1,sel_lastHyperAccessDidReturnMultipleValues);
      local_1d = (char)pvVar1;
    }
    pvVar1 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager,pcVar7);
    iVar3 = (int)local_1d;
    _objc_msgSend(pvVar1,sel_setSelectedFont_isMultiple_,puVar4,iVar3);
  }
  pvVar1 = _objc_msgSend(self,sel_card,puVar4,iVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperEnumerator);
  _objc_msgSend(self,sel_reflectCardObjectsHiddenStateOfObjectsInEnumerator_invalidate_,pvVar1,1);
  return;
}

*/
- (void)selectionDidChange:(id)aChange wasExpanded:(BOOL)aExpanded
{
    id textObject = [self HSEditorCardView_selectedTextObject];
    if (textObject != nil) {
        [self rememberAttributesForTextView:textObject];
    }
    id scaledObject = [self HSEditorCardView_selectedScaledObject];
    if (scaledObject != nil) {
        NSSize frameSize = [scaledObject affineFrameSize];
        _initialWidth = frameSize.width;
        _initialHeight = frameSize.height;
        id scaledFont = [scaledObject queryHyperInterface:@protocol(HSGenericFontAttributes)];
        if (scaledFont != nil) {
            _initialFontSize = [scaledFont hyperFontSize];
        }
    }
    [super selectionDidChange:aChange wasExpanded:aExpanded];
    id fontAttributes = [[self selectedHyperObject] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    if (fontAttributes != nil) {
        [[NSFontManager sharedFontManager] fontPanel:YES];
        BOOL isMultiple = NO;
        NSFont *font;
        if (![fontAttributes isHyperProxy]) {
            font = [fontAttributes fontForSystemFontPanelIsMultiple:&isMultiple];
        } else {
            font = [[[fontAttributes allHyperInterfaces] objectAtIndex:0] fontForSystemFontPanelIsMultiple:NULL];
            isMultiple = [fontAttributes lastHyperAccessDidReturnMultipleValues];
        }
        [[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:isMultiple];
    }
    [self reflectCardObjectsHiddenStateOfObjectsInEnumerator:[[self card] hyperEnumerator] invalidate:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000a273 @ 0000a273, 446 bytes * /

void FUN_0000a273(HSEditorCardView *self,SEL _cmd,id rememberAttributesForTextView)

{
  undefined *puVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int iVar7;
  undefined4 uVar8;
  int *piVar9;
  undefined4 uVar10;
  int local_1c;
  int local_18;
  
  _objc_msgSend(self,sel_clearAttributesForSelectedTextObject);
  pvVar3 = _objc_msgSend(rememberAttributesForTextView,sel_hyperText);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  puVar1 = PTR_00336068;
  local_1c = 0;
  local_18 = 0;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_attributesForSelectedTextObject);
    pvVar5 = _objc_msgSend(cls_NSValue,sel_valueWithRange_,local_1c,local_18);
    pvVar4 = _objc_msgSend(rememberAttributesForTextView,sel_hyperTextAttributes);
    _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar4,pvVar5);
  }
  else {
    do {
      iVar2 = local_18;
      iVar7 = local_1c;
      pvVar4 = _objc_msgSend(rememberAttributesForTextView,sel_hyperText);
      uVar8 = *(undefined4 *)puVar1;
      piVar9 = &local_1c;
      iVar7 = iVar7 + iVar2;
      uVar10 = 0;
      pvVar5 = pvVar3;
      pvVar4 = _objc_msgSend(pvVar4,sel_attribute_atIndex_longestEffectiveRange_inRange_,uVar8,iVar7
                             ,piVar9,0,pvVar3);
      if (pvVar4 != (id)0x0) {
        pvVar5 = _objc_msgSend(self,sel_attributesForSelectedTextObject,uVar8,iVar7,piVar9,uVar10,
                               pvVar5);
        pvVar6 = _objc_msgSend(cls_NSValue,sel_valueWithRange_,local_1c,local_18);
        _objc_msgSend(pvVar5,sel_setObject_forKey_,pvVar4,pvVar6);
      }
    } while ((id)(local_18 + local_1c) < pvVar3);
  }
  return;
}

*/
- (void)rememberAttributesForTextView:(id)aView
{
    [self clearAttributesForSelectedTextObject];
    NSUInteger length = [[aView hyperText] length];
    NSRange range = NSMakeRange(0, 0);
    if (length == 0) {
        [[self attributesForSelectedTextObject] setObject:[aView hyperTextAttributes] forKey:[NSValue valueWithRange:range]];
        return;
    }
    do {
        id value = [[aView hyperText] attribute:NSFontAttributeName atIndex:range.location + range.length longestEffectiveRange:&range inRange:NSMakeRange(0, length)];
        if (value != nil) {
            [[self attributesForSelectedTextObject] setObject:value forKey:[NSValue valueWithRange:range]];
        }
    } while (range.location + range.length < length);
}

- (void)clearAttributesForSelectedTextObject
{
    [_attributesForSelectedTextObject release];
    _attributesForSelectedTextObject = nil;
}

- (id)attributesForSelectedTextObject
{
    id pvVar1;

    pvVar1 = _attributesForSelectedTextObject;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary alloc] initWithCapacity:1];
        _attributesForSelectedTextObject = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000a4c3 @ 0000a4c3, 216 bytes * /

void FUN_0000a4c3(HSEditorCardView *self,SEL _cmd,id cardDidChangeChildren)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(cardDidChangeChildren,sel_userInfo);
  pcVar3 = &cfstr_HSNodeChildrenForAddition;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while( true ) {
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject,pcVar3);
    if (pvVar2 == (id)0x0) break;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00360728);
    pcVar3 = (cfstringStruct *)sel_startLoading;
    _objc_msgSend(pvVar2,sel_performSelectorOnMainThread_withObject_waitUntilDone_,sel_startLoading,
                  0,0);
  }
  _objc_msgSend(self,sel_nodeContainerAttributeChanged_,cardDidChangeChildren);
  return;
}

*/
- (void)cardDidChangeChildren:(id)aChildren
{
    NSEnumerator *e = [[[aChildren userInfo] objectForKey:@"HSNodeChildrenForAddition"] objectEnumerator];
    id child;
    while ((child = [e nextObject]) != nil) {
        [[child queryHyperInterface:@protocol(HSWebPageAttributes)] performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
    }
    [self nodeContainerAttributeChanged:aChildren];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000a59b @ 0000a59b, 948 bytes * /

void FUN_0000a59b(HSEditorCardView *self,SEL _cmd,
                 id addImageToBackgroundAndSwitchToBitmapSelectionTool,NSRect inRect)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  id pvVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar6;
  undefined8 in_stack_ffffff9c;
  undefined8 uVar7;
  float local_3c;
  uint local_38;
  undefined4 local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  id local_1c;
  float fStack_18;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(pvVar1,sel_selectToolWithTag_,0xe);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar1 = _objc_msgSend(pvVar1,sel_bitmapTool);
  pvVar2 = _objc_msgSend(cls_HSImportDialogGraphicsBTCGImage,sel_alloc);
  uVar7 = CONCAT44(uVar4,addImageToBackgroundAndSwitchToBitmapSelectionTool);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithNSImage_,
                         addImageToBackgroundAndSwitchToBitmapSelectionTool);
  local_1c = _objc_msgSend(addImageToBackgroundAndSwitchToBitmapSelectionTool,sel_size);
  local_24 = 0;
  uStack_20 = 0;
  if (((float)local_1c != 0.0) || (NAN((float)local_1c))) {
    local_3c = inRect.size.width / (float)local_1c;
  }
  else {
    local_3c = 1.0;
  }
  if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
    fVar6 = inRect.size.height / extraout_EDX;
  }
  else {
    fVar6 = 1.0;
  }
  local_30 = -fVar6;
  local_38 = 0x80000000;
  local_34 = 0;
  local_2c = inRect.origin.x - local_3c * 0.0;
  local_28 = (inRect.origin.y + inRect.origin.y + inRect.size.height) -
             (inRect.origin.y - fVar6 * 0.0);
  fStack_18 = extraout_EDX;
  pvVar3 = _objc_msgSend(self,sel_card,uVar7);
  pvVar3 = _objc_msgSend(pvVar3,sel_stack);
  _objc_msgSend(pvVar3,sel_hyperCardSize);
  local_38 = local_38 ^ 0x80000000;
  local_30 = -local_30;
  local_28 = (extraout_EDX_00 + *(float *)(PTR_00336074 + 4) + *(float *)(PTR_00336074 + 4)) -
             local_28;
  uVar4 = _CGPathCreateMutable();
  _CGPathAddRect(uVar4,0,CONCAT44(uStack_20,local_24),CONCAT44(fStack_18,local_1c));
  pvVar3 = _objc_msgSend(pvVar1,sel_initialCreateSelectionMode);
  _objc_msgSend(pvVar1,sel_setInitialCreateSelectionMode_,0);
  _objc_msgSend(pvVar1,sel_setSelectionPath_,uVar4);
  pvVar5 = _objc_msgSend(cls_NSValue,sel_valueWithBytes_objCType_,&local_3c,
                         "{CGAffineTransform=ffffff}");
  _objc_msgSend(pvVar1,sel_setSelectionPathTransform_,pvVar5);
  _objc_msgSend(pvVar1,sel_setSelectionPathFlippedHorizontally_,0);
  _objc_msgSend(pvVar1,sel_setImageSelection_,pvVar2);
  pvVar5 = _objc_msgSend(cls_NSValue,sel_valueWithBytes_objCType_,&local_24,
                         "{CGRect={CGPoint=ff}{CGSize=ff}}");
  _objc_msgSend(pvVar1,sel_setImageSelectionBounds_,pvVar5);
  pvVar5 = _objc_msgSend(cls_NSValue,sel_valueWithBytes_objCType_,&local_3c,
                         "{CGAffineTransform=ffffff}");
  _objc_msgSend(pvVar1,sel_setImageSelectionTransform_,pvVar5);
  _CGPathRelease(uVar4);
  _objc_msgSend(pvVar2,sel_release);
  _objc_msgSend(pvVar1,sel_setInitialCreateSelectionMode_,pvVar3);
  return;
}

*/
- (void)addImageToBackgroundAndSwitchToBitmapSelectionTool:(id)aTool inRect:(NSRect)aRect
{
    [[HSToolManager sharedToolManager] selectToolWithTag:0xe];
    id bitmapTool = [[[HSToolManager sharedToolManager] currentTool] bitmapTool];
    id imageSelection = [[HSImportDialogGraphicsBTCGImage alloc] initWithNSImage:aTool];
    NSSize imageSize = [aTool size];
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGFloat scaleX = (imageSize.width != 0.0) ? aRect.size.width / imageSize.width : 1.0;
    CGFloat scaleY = (imageSize.height != 0.0) ? aRect.size.height / imageSize.height : 1.0;
    CGFloat cardHeight = [[[self card] stack] hyperCardSize].height;
    CGAffineTransform transform = CGAffineTransformMake(scaleX, 0, 0, scaleY, aRect.origin.x, cardHeight - (aRect.origin.y + aRect.size.height));
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, imageRect);
    id previousMode = [bitmapTool initialCreateSelectionMode];
    [bitmapTool setInitialCreateSelectionMode:0];
    [bitmapTool setSelectionPath:path];
    [bitmapTool setSelectionPathTransform:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)]];
    [bitmapTool setSelectionPathFlippedHorizontally:NO];
    [bitmapTool setImageSelection:imageSelection];
    [bitmapTool setImageSelectionBounds:[NSValue valueWithBytes:&imageRect objCType:@encode(CGRect)]];
    [bitmapTool setImageSelectionTransform:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)]];
    CGPathRelease(path);
    [imageSelection release];
    [bitmapTool setInitialCreateSelectionMode:previousMode];
}

- (void)convertSelectedObjectToImage
{
    id pvVar1_3;

    [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
    [[self runTimeEditorController] deactivateAllEditors];
    pvVar1_3 = [self card];
    if ([[self selection] nodesCount] == 0x1) {
        [pvVar1_3 convertObjectToImage:[[self selection] selectedNode]];
    }
    [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000aa58 @ 0000aa58, 387 bytes * /

void FUN_0000aa58(HSEditorCardView *self,SEL _cmd,BOOL flatSelectedObjects)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  int iVar5;
  
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  _objc_msgSend(pvVar1,sel_disableObjectRegistration);
  pvVar1 = _objc_msgSend(self,sel_runTimeEditorController);
  _objc_msgSend(pvVar1,sel_saveAllEditors);
  self_00 = _objc_msgSend(self,sel_card);
  pvVar2 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithSelection_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pcVar4 = sel_selectedNodesArrayForFlatOperation;
  if (flatSelectedObjects != '\0') {
    pcVar4 = sel_selectedNodesArrayForMergeOperation;
  }
  pvVar2 = _objc_msgSend(pvVar2,pcVar4,pvVar1);
  pvVar3 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar3 != (id)0x0) {
    iVar5 = (int)flatSelectedObjects;
    pvVar1 = pvVar2;
    pvVar3 = _objc_msgSend(self,sel_confirmShouldFlattenObjectsInArray_toImage_,pvVar2,iVar5);
    if ((char)pvVar3 != '\0') {
      pcVar4 = sel_flatObjectsToBackground_;
      if (flatSelectedObjects != '\0') {
        pcVar4 = sel_flatObjectsToImage_;
      }
      _objc_msgSend(self_00,pcVar4,pvVar2,iVar5);
      pvVar1 = pvVar2;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,pvVar1);
  _objc_msgSend(pvVar1,sel_enableObjectRegistration);
  return;
}

*/
- (void)flatSelectedObjects:(BOOL)aObjects
{
    [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
    [[self runTimeEditorController] saveAllEditors];
    id card = [self card];
    HSSelectionOperationVerifier *verifier = [[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease];
    id nodes = aObjects ? [verifier selectedNodesArrayForMergeOperation] : [verifier selectedNodesArrayForFlatOperation];
    if ([nodes count] != 0 && [self confirmShouldFlattenObjectsInArray:nodes toImage:aObjects]) {
        if (aObjects) {
            [card flatObjectsToImage:nodes];
        } else {
            [card flatObjectsToBackground:nodes];
        }
    }
    [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000abdb @ 0000abdb, 1551 bytes * /

BOOL FUN_0000abdb(HSEditorCardView *self,SEL _cmd,id confirmShouldFlattenObjectsInArray,BOOL toImage
                 )

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  bool bVar7;
  undefined8 in_stack_ffffffcc;
  undefined4 uVar9;
  undefined8 uVar8;
  undefined8 in_stack_ffffffd4;
  undefined4 uVar10;
  id local_1c;
  id local_18;
  
  uVar10 = (undefined4)((ulonglong)in_stack_ffffffd4 >> 0x20);
  uVar9 = (undefined4)((ulonglong)in_stack_ffffffcc >> 0x20);
  pcVar5 = &cfstr_HSSuppressMergeObjectsConfirmationAlert;
  if (toImage == '\0') {
    pcVar5 = &cfstr_HSSuppressFlattenObjectsConfirmationAlert;
  }
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pcVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
  if (pvVar1 == (id)0x0) {
    uVar8 = CONCAT44(uVar9,confirmShouldFlattenObjectsInArray);
    pvVar1 = _objc_msgSend(self,sel_objectsInArrayHaveAssignedActions_,
                           confirmShouldFlattenObjectsInArray);
    if ((char)pvVar1 == '\0') {
      if (toImage == '\0') goto LAB_0000b1dd;
      pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar8);
      local_18 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                               &cfstr_Permanently_merge_these_objects_,&cfstr_empty,&cfstr_Alerts);
      pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      local_1c = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                               &cfstr_Merging_objects_joins_them_together_permanently_,&cfstr_empty,
                               &cfstr_Alerts);
      pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      uVar8 = 0x33767c003378dc;
    }
    else if (toImage == '\0') {
      pvVar1 = _objc_msgSend(confirmShouldFlattenObjectsInArray,sel_count);
      pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      if (pvVar1 < (id)0x2) {
        local_18 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                                 &cfstr_Clear_actions_and_flatten_the_selected_object_,&cfstr_empty,
                                 &cfstr_Alerts);
        pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar6 = &cfstr_The_selected_object_has_actions_assigned__By_fla;
      }
      else {
        local_18 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                                 &cfstr_Clear_actions_and_flatten_the_selected_objects_,&cfstr_empty
                                 ,&cfstr_Alerts);
        pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar6 = &cfstr_The_selected_objects_have_actions_assigned__By_f;
      }
      uVar8 = CONCAT44(uVar10,&cfstr_Alerts);
      local_1c = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar6,&cfstr_empty,
                               uVar8);
      uVar10 = (undefined4)((ulonglong)uVar8 >> 0x20);
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      uVar8 = 0x33767c003378ac;
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      local_18 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                               &cfstr_Are_you_sure_you_want_to_merge_the_selected_obje,&cfstr_empty,
                               &cfstr_Alerts);
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      local_1c = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                               &cfstr_Some_of_the_selected_objects_have_actions_assign,&cfstr_empty,
                               &cfstr_Alerts);
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      uVar8 = 0x33767c0033785c;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,uVar8,
                           CONCAT44(uVar10,&cfstr_Alerts));
    pvVar2 = _objc_msgSend(cls_HSAlert,sel_new);
    _objc_msgSend(pvVar2,sel_setMessageText_,local_18);
    _objc_msgSend(pvVar2,sel_setInformativeText_,local_1c);
    _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar1);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar1);
    pvVar1 = _objc_msgSend(cls_NSButton,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,*(undefined8 *)PTR_00336078,
                           *(undefined8 *)(PTR_00336078 + 8));
    _objc_msgSend(pvVar1,sel_setButtonType_,3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar6 = &cfstr_empty;
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_Don_t_show_this_message_again,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_setTitle_,pvVar3);
    uVar8 = CONCAT44(pcVar6,pvVar1);
    _objc_msgSend(pvVar2,sel_setCustomView_,pvVar1);
    pvVar3 = _objc_msgSend(pvVar2,sel_runModal);
    bVar7 = pvVar3 == (id)0x3e8;
    pvVar3 = _objc_msgSend(pvVar1,sel_state);
    if (pvVar3 == (id)0x1) {
      pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar8);
      pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
      uVar8 = CONCAT44(pcVar5,pvVar4);
      _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar4,pcVar5);
    }
    _objc_msgSend(pvVar1,sel_release,uVar8);
    _objc_msgSend(pvVar2,sel_release);
  }
  else {
LAB_0000b1dd:
    bVar7 = true;
  }
  return bVar7;
}

*/
- (BOOL)confirmShouldFlattenObjectsInArray:(id)aArray toImage:(BOOL)aImage
{
    NSString *key = aImage ? @"HSSuppressMergeObjectsConfirmationAlert" : @"HSSuppressFlattenObjectsConfirmationAlert";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue] != 0) {
        return YES;
    }
    NSString *messageText;
    NSString *informativeText;
    NSString *buttonTitle;
    if (![self objectsInArrayHaveAssignedActions:aArray]) {
        if (!aImage) {
            return YES;
        }
        messageText = [[NSBundle mainBundle] localizedStringForKey:@"Permanently merge these objects?" value:@"" table:@"Alerts"];
        informativeText = [[NSBundle mainBundle] localizedStringForKey:@"Merging objects joins them together permanently into a single new object that cannot be separated into its parts again. Are you sure you want to merge these objects?" value:@"" table:@"Alerts"];
        buttonTitle = [[NSBundle mainBundle] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    } else if (!aImage) {
        BOOL plural = [aArray count] >= 2;
        messageText = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(plural ? @"Clear actions and flatten the selected objects?" : @"Clear actions and flatten the selected object?") value:@"" table:@"Alerts"];
        informativeText = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(plural ? @"The selected objects have actions assigned. By flattening the objects to the background, you will lose all these actions. You will only be able to undo this right after flattening (by choosing Undo from the Edit menu). Otherwise, the flattening will be permanent." : @"The selected object has actions assigned. By flattening the object to the background, you will lose all these actions. You will only be able to undo this right after flattening (by choosing Undo from the Edit menu). Otherwise, the flattening will be permanent.") value:@"" table:@"Alerts"];
        buttonTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Clear and Flatten" value:@"" table:@"Alerts"];
    } else {
        messageText = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Are you sure you want to merge the selected objects?" value:@"" table:@"Alerts"];
        informativeText = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Some of the selected objects have actions assigned to them. After the objects are merged, some of these actions might be lost. Make sure that all the objects are exactly as you want them to be. If you are not satisfied with the result of the merger, you can separate the objects by choosing Undo from the Edit menu." value:@"" table:@"Alerts"];
        buttonTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Merge" value:@"" table:@"Alerts"];
    }
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:messageText];
    [alert setInformativeText:informativeText];
    [alert addButtonWithTitle:buttonTitle];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    NSButton *checkbox = [[NSButton alloc] initWithFrame:NSZeroRect];
    [checkbox setButtonType:NSSwitchButton];
    [checkbox setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Don't show this message again" value:@"" table:@"Alerts"]];
    [alert setCustomView:checkbox];
    BOOL confirmed = [alert runModal] == 1000;
    if ([checkbox state] == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:key];
    }
    [checkbox release];
    [alert release];
    return confirmed;
}

- (BOOL)objectsInArrayHaveAssignedActions:(id)aActions
{
    NSUInteger pvVar1;
    NSUInteger pvVar3;
    id pvVar2_2;

    pvVar3 = 0;
    pvVar1 = [aActions count];
    do {
        if (pvVar1 <= pvVar3) {
            return NO;
        }
        pvVar2_2 = [[aActions objectAtIndex:pvVar3] queryHyperInterface:@protocol(HSActor)];
        if (pvVar2_2 != nil) {
            if ([[pvVar2_2 hyperActions] count] != 0) {
                return YES;
            }
        }
        pvVar3 = (pvVar3 + 1);
    } while( YES );
}

- (BOOL)readSelectionFromPasteboard:(id)aPasteboard
{
    return (BOOL)[self readSelectionFromPasteboard:aPasteboard useDragPreferences:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000b2c5 @ 0000b2c5, 248 bytes * /

BOOL FUN_0000b2c5(HSEditorCardView *self,SEL _cmd,id readSelectionFromPasteboard,
                 BOOL useDragPreferences)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  cfstringStruct *pcVar5;
  char *pcVar6;
  char local_11;
  
  local_11 = '\0';
  pvVar1 = _objc_msgSend(self,sel_dragHelper);
  pcVar6 = &local_11;
  iVar4 = (int)useDragPreferences;
  pvVar3 = readSelectionFromPasteboard;
  pvVar1 = _objc_msgSend(pvVar1,sel_readSelectionFromPasteboard_useDragPreferences_didAddNewObject_,
                         readSelectionFromPasteboard,iVar4,pcVar6);
  pvVar2 = _objc_msgSend(self,sel_isOccupiedByTool);
  if ((((char)pvVar2 == '\0') && ((char)pvVar1 != '\0')) && (local_11 != '\0')) {
    pvVar3 = _objc_msgSend(self,sel_window,pvVar3,iVar4,pcVar6);
    _objc_msgSend(pvVar3,sel_makeKeyWindow);
    pvVar3 = _objc_msgSend(readSelectionFromPasteboard,sel_types);
    pcVar5 = &cfstr_HSObjectsPasteboardType;
    pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_HSObjectsPasteboardType);
    if ((char)pvVar3 == '\0') {
      _objc_msgSend(self,sel_didAddNewObject,pcVar5);
    }
  }
  return (char)pvVar1;
}

*/
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard useDragPreferences:(BOOL)aPreferences
{
    BOOL didAddNewObject = NO;
    BOOL result = [[self dragHelper] readSelectionFromPasteboard:aPasteboard useDragPreferences:aPreferences didAddNewObject:&didAddNewObject];
    if (![self isOccupiedByTool] && result && didAddNewObject) {
        [[self window] makeKeyWindow];
        if (![[aPasteboard types] containsObject:@"HSObjectsPasteboardType"]) {
            [self didAddNewObject];
        }
    }
    return result;
}

- (id)objectsFromPDFFile:(id)aFile firstPageOnly:(BOOL)aOnly
{
    return [[self dragHelper] objectsFromPDFFile:aFile firstPageOnly:(unsigned int)aOnly];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000b406 @ 0000b406, 313 bytes * /

uint FUN_0000b406(HSEditorCardView *self,SEL _cmd,id importToCardDataFromFiles,BOOL showHelpPane)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  *(BOOL *)((int)&self->_initialHeight + 1) = showHelpPane;
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar3 = &DAT_00360548;
  pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00360548);
  pvVar2 = _objc_msgSend(self,sel_dragHelper);
  op = sel_importToCardDataFromFiles_;
  if ((char)pvVar1 != '\0') {
    importToCardDataFromFiles = _objc_msgSend(self,sel_selectedHyperObject,puVar3);
    op = sel_importToObject_dataFromFiles_;
  }
  pvVar1 = _objc_msgSend(pvVar2,op,importToCardDataFromFiles);
  if ((*(char *)((int)&self->_initialHeight + 1) != '\0') &&
     (self->_newActionDropHelpPane != (HSNewActionDropHelpPane *)0x0)) {
    pvVar2 = _objc_msgSend(self->_newActionDropHelpPane,sel_containersForAdd,
                           importToCardDataFromFiles);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
    _objc_msgSend(self,sel_openDropHelpPane_forContainer_,self->_newActionDropHelpPane,pvVar2);
    _objc_msgSend(self->_newActionDropHelpPane,sel_release);
    self->_newActionDropHelpPane = (HSNewActionDropHelpPane *)0x0;
  }
  return (uint)pvVar1;
}

*/
- (NSUInteger)importToCardDataFromFiles:(id)aFiles showHelpPane:(BOOL)aPane
{
    _needOpenHelpPane = aPane;
    BOOL toObject = [[self selectedHyperObject] implementsHyperInterface:@protocol(HSSystemTextViewAttributes)];
    id dragHelper = [self dragHelper];
    NSUInteger result;
    if (toObject) {
        result = [dragHelper importToObject:[self selectedHyperObject] dataFromFiles:aFiles];
    } else {
        result = [dragHelper importToCardDataFromFiles:aFiles];
    }
    if (_needOpenHelpPane && _newActionDropHelpPane != nil) {
        id container = [[_newActionDropHelpPane containersForAdd] lastObject];
        [self openDropHelpPane:_newActionDropHelpPane forContainer:container];
        [_newActionDropHelpPane release];
        _newActionDropHelpPane = nil;
    }
    return result;
}

- (void)addObjectToCenter:(id)aCenter useDragPreferences:(BOOL)aPreferences
{
    id self_00;
    BOOL pvVar1;

    self_00 = [self dragHelper];
    pvVar1 = [aCenter implementsHyperInterface:@protocol(HSMovieObjectAttributes)];
    [self_00 addObjectsInArray:[NSArray arrayWithObject:aCenter] center:YES needOpenHelpPane:(unsigned int)(!pvVar1) useDragPreferences:aPreferences];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000b5e1 @ 0000b5e1, 773 bytes * /

void FUN_0000b5e1(HSEditorCardView *self,SEL _cmd,id showHelpPaneBeforeAddAction,id actionEvent,
                 id toNodeContainer,BOOL useDragPreferences)

{
  id pvVar1;
  id pvVar2;
  HSNewActionDropHelpPane *pHVar3;
  cfstringStruct *pcVar4;
  SEL op;
  undefined *puVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(showHelpPaneBeforeAddAction,sel_implementsHyperInterface_,&DAT_00360188);
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(showHelpPaneBeforeAddAction,sel_implementsHyperInterface_,&DAT_003602b4
                            ), (char)pvVar1 == '\0')) {
    return;
  }
  pvVar1 = _objc_msgSend(toNodeContainer,sel_implementsHyperInterface_,&DAT_00360034);
  if ((char)pvVar1 == '\0') {
    return;
  }
  if (actionEvent == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(showHelpPaneBeforeAddAction,sel_implementsHyperInterface_,&DAT_00360174);
  if ((char)pvVar1 == '\0') {
    puVar5 = &DAT_003604d0;
    pvVar1 = _objc_msgSend(showHelpPaneBeforeAddAction,sel_implementsHyperInterface_,&DAT_003604d0);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pcVar4 = &cfstr_NewMovieObjectAsDroppedToObject;
  }
  else {
    puVar5 = &DAT_00360084;
    pvVar1 = _objc_msgSend(toNodeContainer,sel_implementsHyperInterface_,&DAT_00360084);
    if ((char)pvVar1 == '\0') {
      pcVar4 = &cfstr_NewPlaySoundActionAsDroppedToObject;
    }
    else {
      pvVar1 = _objc_msgSend(actionEvent,sel_eventType,puVar5);
      puVar5 = *(undefined **)PTR_00336084;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,puVar5);
      if ((char)pvVar1 == '\0') {
        pcVar4 = &cfstr_NewPlaySoundActionAsDroppedToCardPlayOnArrive;
      }
      else {
        pcVar4 = &cfstr_NewPlaySoundActionAsDroppedToCardPlayOnClick;
      }
    }
  }
  pHVar3 = self->_newActionDropHelpPane;
  if (pHVar3 != (HSNewActionDropHelpPane *)0x0) goto LAB_0000b83d;
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,puVar5);
  pcVar6 = toNodeContainer;
  pvVar1 = _objc_msgSend(pvVar1,sel_dropHelpPaneForObject_,toNodeContainer);
  if (pvVar1 == (id)0x0) {
LAB_0000b7ca:
    pvVar1 = _objc_msgSend(cls_HSNewActionDropHelpPane,sel_alloc,pcVar6);
    op = sel_initWithCoachingKey_;
    pcVar6 = pcVar4;
  }
  else {
    pcVar6 = (cfstringStruct *)&DAT_00360228;
    pvVar2 = _objc_msgSend(pvVar1,sel_conformsToProtocol_,&DAT_00360228);
    if ((char)pvVar2 == '\0') goto LAB_0000b7ca;
    pvVar2 = _objc_msgSend(pvVar1,sel_coachingKey,pcVar6);
    pcVar6 = pcVar4;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar4);
    op = sel_retain;
    if ((char)pvVar2 == '\0') goto LAB_0000b7ca;
  }
  pHVar3 = _objc_msgSend(pvVar1,op,pcVar6);
  self->_newActionDropHelpPane = pHVar3;
  _objc_msgSend(pHVar3,sel_setDropDelegate_,self);
  _objc_msgSend(self->_newActionDropHelpPane,sel_setUseDragPreferences_,(int)useDragPreferences);
  pHVar3 = self->_newActionDropHelpPane;
LAB_0000b83d:
  _objc_msgSend(pHVar3,sel_addActionToAdd_actionEvent_forContainer_,showHelpPaneBeforeAddAction,
                actionEvent,toNodeContainer);
  if (*(char *)((int)&self->_initialHeight + 1) != '\0') {
    pvVar1 = _objc_msgSend(self->_newActionDropHelpPane,sel_containersForAdd,
                           showHelpPaneBeforeAddAction,actionEvent,toNodeContainer);
    pvVar1 = _objc_msgSend(pvVar1,sel_lastObject);
    _objc_msgSend(self,sel_openDropHelpPane_forContainer_,self->_newActionDropHelpPane,pvVar1);
    _objc_msgSend(self->_newActionDropHelpPane,sel_release);
    self->_newActionDropHelpPane = (HSNewActionDropHelpPane *)0x0;
  }
  return;
}

*/
- (void)showHelpPaneBeforeAddAction:(id)aAction actionEvent:(id)aEvent toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences
{
    if (![aAction implementsHyperInterface:@protocol(HSActionAttributes)] && ![aAction implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
        return;
    }
    if (![aContainer implementsHyperInterface:@protocol(HSNodeContainer)]) {
        return;
    }
    if (aEvent == nil) {
        return;
    }
    NSString *key;
    if ([aAction implementsHyperInterface:@protocol(HSPlaySoundActionAttributes)]) {
        if (![aContainer implementsHyperInterface:@protocol(HSCardAttributes)]) {
            key = @"NewPlaySoundActionAsDroppedToObject";
        } else if ([[aEvent eventType] isEqualToString:kHSClickActionEventType]) {
            key = @"NewPlaySoundActionAsDroppedToCardPlayOnClick";
        } else {
            key = @"NewPlaySoundActionAsDroppedToCardPlayOnArrive";
        }
    } else if ([aAction implementsHyperInterface:@protocol(HSPlayMovieActionAttributes)]) {
        key = @"NewMovieObjectAsDroppedToObject";
    } else {
        return;
    }
    if (_newActionDropHelpPane == nil) {
        id pane = [[HSCoachingHelpManager sharedCoachingHelpManager] dropHelpPaneForObject:aContainer];
        if (pane != nil && [pane conformsToProtocol:@protocol(HSNewActionDropHelpPaneInterface)] && [[pane coachingKey] isEqualToString:key]) {
            pane = [pane retain];
        } else {
            pane = [[HSNewActionDropHelpPane alloc] initWithCoachingKey:key];
        }
        _newActionDropHelpPane = pane;
        [_newActionDropHelpPane setDropDelegate:self];
        [_newActionDropHelpPane setUseDragPreferences:aPreferences];
    }
    [_newActionDropHelpPane addActionToAdd:aAction actionEvent:aEvent forContainer:aContainer];
    if (_needOpenHelpPane) {
        id container = [[_newActionDropHelpPane containersForAdd] lastObject];
        [self openDropHelpPane:_newActionDropHelpPane forContainer:container];
        [_newActionDropHelpPane release];
        _newActionDropHelpPane = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000b8e6 @ 0000b8e6, 629 bytes * /

void FUN_0000b8e6(HSEditorCardView *self,SEL _cmd,id openPlaySoundPaneWithInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  SEL pcVar5;
  HSEditorCardView *pHVar6;
  
  pvVar1 = _objc_msgSend(openPlaySoundPaneWithInfo,sel_objectAtIndex_,0);
  _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00360034);
  pvVar2 = _objc_msgSend(openPlaySoundPaneWithInfo,sel_objectAtIndex_,1);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pvVar2);
  pvVar4 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar4 = _objc_msgSend(pvVar4,sel_objectAssistant);
  self_00 = _objc_msgSend(pvVar4,sel_currentPane);
  pvVar4 = _objc_msgSend(self_00,sel_modalViewController);
  if (pvVar4 != (id)0x0) {
    pvVar1 = (id)0x0;
    _objc_msgSend(self_00,sel_dismissModalViewControllerAnimated_,0);
  }
  pvVar1 = _objc_msgSend(cls_HSCardAssistantPane,sel_class,pvVar1);
  pvVar4 = _objc_msgSend(self_00,sel_isKindOfClass_,pvVar1);
  if ((char)pvVar4 == '\0') {
    self = _objc_msgSend(cls_HSObjectAssistantToolbarController,sel_class,pvVar1);
    pvVar1 = _objc_msgSend(self_00,sel_isKindOfClass_,self);
    if ((char)pvVar1 == '\0') {
      pvVar1 = (id)0x0;
      goto LAB_0000bb14;
    }
    pvVar1 = _objc_msgSend(self_00,sel_identifierForSelectedViewController,self);
    pHVar6 = *(HSEditorCardView **)PTR_PTR_00336018;
    self = pHVar6;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,pHVar6);
    pcVar5 = sel_selectedViewController;
    if ((char)pvVar1 == '\0') {
      _objc_msgSend(self_00,sel_openPaneWithIdentifier_,pHVar6);
      pcVar5 = sel_selectedViewController;
      self = pHVar6;
    }
  }
  else {
    pvVar1 = _objc_msgSend(pvVar2,sel_eventType,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,*(undefined4 *)PTR_00336084);
    pcVar5 = sel_openActionsPaneForArriveEvent_;
    if ((char)pvVar1 != '\0') {
      pcVar5 = sel_openActionsPaneForClickEvent_;
    }
    _objc_msgSend(self_00,pcVar5,self);
    self_00 = _objc_msgSend(self_00,sel_modalViewController);
    pcVar5 = sel_topViewController;
  }
  pvVar1 = _objc_msgSend(self_00,pcVar5,self);
LAB_0000bb14:
  pvVar2 = _objc_msgSend(cls_HSPlaySoundAction,sel_actionType,self);
  _objc_msgSend(pvVar1,sel_openAssistantPaneForActionType_forEvents_animate_,pvVar2,pvVar3,0);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000bb5b @ 0000bb5b, 909 bytes * /

void FUN_0000bb5b(HSEditorCardView *self,SEL _cmd,id dropHelpPaneDidEnd,BOOL canceled)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  id self_01;
  id self_02;
  id pvVar5;
  id self_03;
  id pvVar6;
  int iVar7;
  id pvVar8;
  undefined4 uVar9;
  undefined4 uVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  
  pvVar1 = _objc_msgSend(dropHelpPaneDidEnd,sel_queryHyperInterface_,&DAT_003604bc);
  if (pvVar1 == (id)0x0) {
    puVar4 = &DAT_00360228;
    pvVar1 = _objc_msgSend(dropHelpPaneDidEnd,sel_queryHyperInterface_,&DAT_00360228);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = _objc_msgSend(dropHelpPaneDidEnd,sel_queryHyperInterface_,&DAT_00360228);
    pvVar2 = _objc_msgSend(pvVar1,sel_actionsToAdd);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    self_01 = _objc_msgSend(pvVar1,sel_containersForAdd);
    if ((canceled == '\0') && (pvVar3 != (id)0x0)) {
      pvVar8 = (id)0x0;
      do {
        self_02 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar8);
        pvVar5 = _objc_msgSend(self_01,sel_objectAtIndex_,pvVar8);
        self_03 = _objc_msgSend(self,sel_dragHelper);
        pvVar6 = _objc_msgSend(pvVar1,sel_useDragPreferences);
        puVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,self_02);
        iVar7 = (int)(char)pvVar6;
        uVar12 = 0;
        uVar11 = 0;
        uVar10 = 0;
        uVar9 = 1;
        pvVar6 = pvVar5;
        _objc_msgSend(self_03,
                      sel_addObjectsInArray_intoObject_center_fitCanvas_needOpenHelpPane_isPasting_useDragPreferences_
                      ,puVar4,pvVar5,1,0,0,0,iVar7);
        self_00 = cls_NSArray;
        if ((id)((int)pvVar3 + -1) == pvVar8) {
          pvVar6 = _objc_msgSend(self_02,sel_events,puVar4,pvVar6,uVar9,uVar10,uVar11,uVar12,iVar7);
          pvVar6 = _objc_msgSend(pvVar6,sel_lastObject);
          pvVar6 = _objc_msgSend(self_00,sel_arrayWithObjects_,pvVar5,pvVar6,0);
          puVar4 = sel_openPlaySoundPaneWithInfo_;
          _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,
                        sel_openPlaySoundPaneWithInfo_,pvVar6,0,0);
        }
        pvVar8 = (id)((int)pvVar8 + 1);
      } while (pvVar8 < pvVar3);
    }
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,puVar4);
    pvVar2 = _objc_msgSend(self_01,sel_lastObject);
  }
  else {
    puVar4 = &DAT_003604bc;
    pvVar1 = _objc_msgSend(dropHelpPaneDidEnd,sel_queryHyperInterface_,&DAT_003604bc);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectToAdd);
    if ((pvVar2 != (id)0x0) && (canceled == '\0')) {
      pvVar2 = _objc_msgSend(self,sel_dragHelper,puVar4);
      pvVar3 = _objc_msgSend(pvVar1,sel_useDragPreferences);
      puVar4 = cls_NSArray;
      pvVar1 = _objc_msgSend(pvVar1,sel_objectToAdd);
      puVar4 = _objc_msgSend(puVar4,sel_arrayWithObject_,pvVar1);
      _objc_msgSend(pvVar2,sel_addObjectsInArray_center_needOpenHelpPane_useDragPreferences_,puVar4,
                    1,0,(int)(char)pvVar3);
    }
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,puVar4);
    pvVar2 = _objc_msgSend(self,sel_card);
  }
  _objc_msgSend(pvVar1,sel_removeDropHelpPaneForObject_,pvVar2);
  return;
}

*/
- (void)dropHelpPaneDidEnd:(id)aEnd canceled:(BOOL)aCanceled
{
    id objectPane = [aEnd queryHyperInterface:@protocol(HSNewObjectDropHelpPaneInterface)];
    id removeTarget;
    if (objectPane == nil) {
        id actionPane = [aEnd queryHyperInterface:@protocol(HSNewActionDropHelpPaneInterface)];
        if (actionPane == nil) {
            return;
        }
        NSArray *actions = [actionPane actionsToAdd];
        NSUInteger count = [actions count];
        NSArray *containers = [actionPane containersForAdd];
        if (!aCanceled && count != 0) {
            for (NSUInteger i = 0; i < count; i++) {
                id action = [actions objectAtIndex:i];
                id container = [containers objectAtIndex:i];
                [[self dragHelper] addObjectsInArray:[NSArray arrayWithObject:action] intoObject:container center:YES fitCanvas:NO needOpenHelpPane:NO isPasting:NO useDragPreferences:[actionPane useDragPreferences] pastingNotHSObject:NO];
                if (i == count - 1) {
                    id lastEvent = [[action events] lastObject];
                    [self performSelector:@selector(openPlaySoundPaneWithInfo:) withObject:[NSArray arrayWithObjects:container, lastEvent, nil] afterDelay:0];
                }
            }
        }
        removeTarget = [containers lastObject];
    } else {
        if ([objectPane objectToAdd] != nil && !aCanceled) {
            [[self dragHelper] addObjectsInArray:[NSArray arrayWithObject:[objectPane objectToAdd]] center:YES needOpenHelpPane:NO useDragPreferences:[objectPane useDragPreferences]];
        }
        removeTarget = [self card];
    }
    [[HSCoachingHelpManager sharedCoachingHelpManager] removeDropHelpPaneForObject:removeTarget];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000bee8 @ 0000bee8, 461 bytes * /

void FUN_0000bee8(HSEditorCardView *self,SEL _cmd,id showHelpPaneBeforeAddObject,id toNodeContainer,
                 BOOL useDragPreferences)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(showHelpPaneBeforeAddObject,sel_implementsHyperInterface_,&DAT_00360250);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(toNodeContainer,sel_implementsHyperInterface_,&DAT_00360034);
  if ((char)pvVar1 == '\0') {
    return;
  }
  puVar3 = &DAT_003602b4;
  pvVar1 = _objc_msgSend(showHelpPaneBeforeAddObject,sel_implementsHyperInterface_,&DAT_003602b4);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,puVar3);
  puVar3 = toNodeContainer;
  pvVar1 = _objc_msgSend(pvVar1,sel_dropHelpPaneForObject_,toNodeContainer);
  if (pvVar1 != (id)0x0) {
    puVar3 = &DAT_003604bc;
    pvVar2 = _objc_msgSend(pvVar1,sel_conformsToProtocol_,&DAT_003604bc);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_retain,puVar3);
      _objc_msgSend(pvVar1,sel_setObjectToAdd_,showHelpPaneBeforeAddObject);
      _objc_msgSend(pvVar1,sel_setContainerForAdd_,toNodeContainer);
      goto LAB_0000c061;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSNewObjectDropHelpPane,sel_alloc,puVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithCoachingKey_dropDelegate_objectForAdd_containerForAdd_,
                         &cfstr_NewMovieObjectAsDroppedToCard,self,showHelpPaneBeforeAddObject,
                         toNodeContainer);
LAB_0000c061:
  _objc_msgSend(pvVar1,sel_setUseDragPreferences_,(int)useDragPreferences);
  _objc_msgSend(self,sel_openDropHelpPane_forContainer_,pvVar1,toNodeContainer);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)showHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences
{
    if (![aObject implementsHyperInterface:@protocol(HSNodeChild)] || ![aContainer implementsHyperInterface:@protocol(HSNodeContainer)] || ![aObject implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
        return;
    }
    id pane = [[HSCoachingHelpManager sharedCoachingHelpManager] dropHelpPaneForObject:aContainer];
    if (pane != nil && [pane conformsToProtocol:@protocol(HSNewObjectDropHelpPaneInterface)]) {
        pane = [pane retain];
        [pane setObjectToAdd:aObject];
        [pane setContainerForAdd:aContainer];
    } else {
        pane = [[HSNewObjectDropHelpPane alloc] initWithCoachingKey:@"NewMovieObjectAsDroppedToCard" dropDelegate:self objectForAdd:aObject containerForAdd:aContainer];
    }
    [pane setUseDragPreferences:aPreferences];
    [self openDropHelpPane:pane forContainer:aContainer];
    [pane release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000c0b5 @ 0000c0b5, 1005 bytes * /

void FUN_0000c0b5(HSEditorCardView *self,SEL _cmd,id openDropHelpPane,id forContainer)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id pvVar3;
  undefined *puVar4;
  SEL pcVar5;
  
  if (openDropHelpPane == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  if (pvVar2 != (id)0x1) {
    _objc_msgSend(pvVar1,sel_selectToolWithTag_,1);
  }
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  self_00 = _objc_msgSend(pvVar2,sel_objectAssistant);
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  self_01 = _objc_msgSend(pvVar1,sel_dropHelpPaneForObject_,forContainer);
  pvVar3 = _objc_msgSend(self,sel_selection);
  pvVar1 = forContainer;
  pvVar3 = _objc_msgSend(pvVar3,sel_containsNode_,forContainer);
  if ((char)pvVar3 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_selection,pvVar1);
    _objc_msgSend(pvVar1,sel_selectNode_,forContainer);
  }
  _objc_msgSend(pvVar2,sel_setSelectedInModelObjectAndBringAssistantToFront_,forContainer);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar2 = (id)0x1;
  _objc_msgSend(pvVar1,sel_setActive_,1);
  pvVar1 = self_01;
  pcVar5 = sel_objectAssistantNavigationController;
  if (self_01 == (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_currentPane,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_modalViewController);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self_00,sel_currentPane,pvVar2);
      pcVar5 = sel_modalViewController;
      goto LAB_0000c28b;
    }
    pvVar1 = (id)0x0;
  }
  else {
LAB_0000c28b:
    pvVar1 = _objc_msgSend(pvVar1,pcVar5,pvVar2);
  }
  if (self_01 == (id)0x0) {
    puVar4 = &DAT_00360228;
    pvVar2 = _objc_msgSend(openDropHelpPane,sel_implementsHyperInterface_,&DAT_00360228);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(pvVar1,sel_topViewController,puVar4);
      puVar4 = &DAT_0036023c;
      pvVar2 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_0036023c);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(openDropHelpPane,sel_queryHyperInterface_,&DAT_00360228);
        pvVar1 = _objc_msgSend(pvVar1,sel_topViewController);
        puVar4 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036023c);
        _objc_msgSend(pvVar2,sel_setDelegate_,puVar4);
      }
    }
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,puVar4);
    pvVar3 = _objc_msgSend(openDropHelpPane,sel_dropHelpPaneIdentifier);
    self_01 = _objc_msgSend(pvVar1,sel_initWithRootViewController_identifier_,openDropHelpPane,
                            pvVar3);
    pvVar2 = self_01;
    _objc_msgSend(self_00,sel_openAssistantPane_,self_01);
    pcVar5 = sel_release;
  }
  else {
    if (self_01 == openDropHelpPane) goto LAB_0000c462;
    pvVar2 = _objc_msgSend(self_01,sel_shouldDismissWhenDisappeared,pvVar2);
    _objc_msgSend(self_01,sel_setShouldDismissWhenDisappeared_,0);
    pvVar3 = _objc_msgSend(openDropHelpPane,sel_dropHelpPaneIdentifier);
    _objc_msgSend(pvVar1,sel_pushViewController_withIdentifier_animate_replacePrevious_,
                  openDropHelpPane,pvVar3,1,1);
    pvVar2 = (id)(int)(char)pvVar2;
    pcVar5 = sel_setShouldDismissWhenDisappeared_;
  }
  _objc_msgSend(self_01,pcVar5,pvVar2,pvVar3);
LAB_0000c462:
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,pvVar2);
  _objc_msgSend(pvVar1,sel_addDropHelpPane_forObject_,openDropHelpPane,forContainer);
  return;
}

*/
- (void)openDropHelpPane:(id)aPane forContainer:(id)aContainer
{
    if (aPane == nil) {
        return;
    }
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([toolManager selectedToolTag] != 1) {
        [toolManager selectToolWithTag:1];
    }
    id assistantController = [HSObjectAssistantController sharedAssistantController];
    id objectAssistant = [assistantController objectAssistant];
    id existingPane = [[HSCoachingHelpManager sharedCoachingHelpManager] dropHelpPaneForObject:aContainer];
    if (![[self selection] containsNode:aContainer]) {
        [[self selection] selectNode:aContainer];
    }
    [assistantController setSelectedInModelObjectAndBringAssistantToFront:aContainer];
    [[HSObjectAssistantController sharedAssistantController] setActive:YES];
    id navigation;
    if (existingPane != nil) {
        navigation = [existingPane objectAssistantNavigationController];
    } else {
        navigation = [[objectAssistant currentPane] modalViewController];
    }
    if (existingPane == nil) {
        if ([aPane implementsHyperInterface:@protocol(HSNewActionDropHelpPaneInterface)] && [[navigation topViewController] implementsHyperInterface:@protocol(HSAddActionHandlerDelegate)]) {
            [[aPane queryHyperInterface:@protocol(HSNewActionDropHelpPaneInterface)] setDelegate:[[navigation topViewController] queryHyperInterface:@protocol(HSAddActionHandlerDelegate)]];
        }
        id newNavigation = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:aPane identifier:[aPane dropHelpPaneIdentifier]];
        [objectAssistant openAssistantPane:newNavigation];
        [newNavigation release];
    } else if (existingPane != aPane) {
        BOOL shouldDismiss = [existingPane shouldDismissWhenDisappeared];
        [existingPane setShouldDismissWhenDisappeared:NO];
        [navigation pushViewController:aPane withIdentifier:[aPane dropHelpPaneIdentifier] animate:YES replacePrevious:YES];
        [existingPane setShouldDismissWhenDisappeared:shouldDismiss];
    }
    [[HSCoachingHelpManager sharedCoachingHelpManager] addDropHelpPane:aPane forObject:aContainer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000c4a2 @ 0000c4a2, 336 bytes * /

BOOL FUN_0000c4a2(HSEditorCardView *self,SEL _cmd,id needsOpenHelpPaneBeforeAddObject,
                 id toNodeContainer)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar1 = _objc_msgSend(pvVar1,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_isInStoryboardMode);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pvVar2 = _objc_msgSend(pvVar1,sel_dontShowAllCoachingHints);
    if (((char)pvVar2 == '\0') &&
       (pvVar2 = _objc_msgSend(needsOpenHelpPaneBeforeAddObject,sel_implementsHyperInterface_,
                               &DAT_00360174), (char)pvVar2 != '\0')) {
      puVar3 = &DAT_00360084;
      pvVar2 = _objc_msgSend(toNodeContainer,sel_implementsHyperInterface_,&DAT_00360084);
      if ((char)pvVar2 == '\0') {
        pcVar4 = &cfstr_NewPlaySoundActionAsDroppedToObject;
      }
      else {
        pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar3);
        pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,*(undefined4 *)PTR_0033603c);
        if ((char)pvVar2 == '\0') {
          pcVar4 = &cfstr_NewPlaySoundActionAsDroppedToCardPlayOnArrive;
        }
        else {
          pcVar4 = &cfstr_NewPlaySoundActionAsDroppedToCardPlayOnClick;
        }
      }
      pvVar1 = _objc_msgSend(pvVar1,sel_dontShowCoachingHintsForKey_,pcVar4);
      return (char)pvVar1 == '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)needsOpenHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer
{
    if ([[[self card] document] isInStoryboardMode]) {
        return NO;
    }
    HSCoachingHelpManager *manager = [HSCoachingHelpManager sharedCoachingHelpManager];
    if ([manager dontShowAllCoachingHints] || ![aObject implementsHyperInterface:@protocol(HSPlaySoundActionAttributes)]) {
        return NO;
    }
    NSString *key;
    if (![aContainer implementsHyperInterface:@protocol(HSCardAttributes)]) {
        key = @"NewPlaySoundActionAsDroppedToObject";
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:HSImportSoundToPlayOnClickKey]) {
        key = @"NewPlaySoundActionAsDroppedToCardPlayOnArrive";
    } else {
        key = @"NewPlaySoundActionAsDroppedToCardPlayOnClick";
    }
    return ![manager dontShowCoachingHintsForKey:key];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000c5f2 @ 0000c5f2, 170 bytes * /

void FUN_0000c5f2(HSEditorCardView *self,SEL _cmd,id startAnimationModeForObject,id actingObject)

{
  undefined *self_00;
  id pvVar1;
  undefined4 *puVar2;
  
  if (actingObject == (id)0x0) {
    actingObject = _objc_msgSend(self,sel_card);
  }
  self_00 = cls_HSActionEvent;
  pvVar1 = _objc_msgSend(actingObject,sel_queryHyperInterface_,&DAT_00360084);
  puVar2 = (undefined4 *)PTR_00336080;
  if (pvVar1 == (id)0x0) {
    puVar2 = (undefined4 *)PTR_00336084;
  }
  pvVar1 = _objc_msgSend(self_00,sel_actionEventOfType_,*puVar2);
  _objc_msgSend(self,sel_startAnimationModeForObject_byDragAndDrop_actingObject_actionEvent_,
                startAnimationModeForObject,1,actingObject,pvVar1);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000c69c @ 0000c69c, 226 bytes * /

void FUN_0000c69c(HSEditorCardView *self,SEL _cmd,id startAnimationModeForObject,BOOL byDragAndDrop,
                 id actingObject,id actionEvent)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  puVar3 = &DAT_003600d4;
  pvVar1 = _objc_msgSend(actingObject,sel_queryHyperInterface_,&DAT_003600d4);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSPlayAnimationAction,sel_actionType,puVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionsOfType_forEvent_,pvVar2,actionEvent);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    op = sel_continueReplacingExistingAnimationForObject_byDragAndDrop_actingObject_actionEvent_;
    if (pvVar1 != (id)0x0) {
      op = 
      sel_askUserAboutReplacingExistingAnimationForObject_byDragAndDrop_actingObject_actionEvent_;
    }
    _objc_msgSend(self,op,startAnimationModeForObject,(int)byDragAndDrop,actingObject,actionEvent);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000c77e @ 0000c77e, 296 bytes * /

void FUN_0000c77e(HSEditorCardView *self,SEL _cmd,id alertDidEnd,int returnCode,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  _objc_msgSend(*(id *)PTR_00336058,sel_stopModal);
  if (returnCode == 1000) {
    pvVar1 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_object);
    pvVar2 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_actionEvent);
    pvVar3 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_actingObject);
    pvVar4 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_objectDropped);
    pvVar4 = _objc_msgSend(pvVar4,sel_boolValue);
    _objc_msgSend(self,
                  sel_continueReplacingExistingAnimationForObject_byDragAndDrop_actingObject_actionEvent_
                  ,pvVar1,(int)(char)pvVar4,pvVar3,pvVar2);
  }
  _objc_msgSend(contextInfo,sel_release);
  _objc_msgSend(alertDidEnd,sel_release);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000c8a6 @ 0000c8a6, 784 bytes * /

void FUN_0000c8a6(HSEditorCardView *self,SEL _cmd,id askUserAboutReplacingExistingAnimationForObject
                 ,BOOL byDragAndDrop,id actingObject,id actionEvent)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  bool bVar7;
  
  pvVar2 = _objc_msgSend(cls_NSAlert,sel_new);
  pvVar3 = _objc_msgSend(actingObject,sel_implementsHyperInterface_,&DAT_00360084);
  pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  bVar7 = (char)pvVar3 == '\0';
  pcVar5 = &cfstr_HSReplaceCardAnimationMessageText;
  if (bVar7) {
    pcVar5 = &cfstr_HSReplaceObjectAnimationMessageText;
  }
  pcVar6 = &cfstr_HSReplaceCardAnimationInformativeText;
  if (bVar7) {
    pcVar6 = &cfstr_HSReplaceObjectAnimationInformativeText;
  }
  pvVar3 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar2,sel_setMessageText_,pvVar3);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar6,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar2,sel_setInformativeText_,pvVar3);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_HSReplaceAnimationButtonTitle,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar3);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pcVar5 = &cfstr_Alerts;
  pcVar6 = &cfstr_empty;
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar3);
  if (((actingObject == (id)0x0) || (askUserAboutReplacingExistingAnimationForObject == (id)0x0)) ||
     (actionEvent == (id)0x0)) {
    pvVar4 = (id)0x0;
    askUserAboutReplacingExistingAnimationForObject = pvVar3;
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSDictionary,sel_alloc,pvVar3,pcVar6,pcVar5);
    pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(byte)byDragAndDrop);
    pcVar6 = &cfstr_object;
    pvVar4 = _objc_msgSend(pvVar3,sel_initWithObjectsAndKeys_,
                           askUserAboutReplacingExistingAnimationForObject,&cfstr_object,
                           actingObject,&cfstr_actingObject,actionEvent,&cfstr_actionEvent,pvVar4,
                           &cfstr_objectDropped,0);
    pcVar5 = actingObject;
  }
  puVar1 = sel_alertDidEnd_returnCode_contextInfo_;
  pvVar3 = _objc_msgSend(self,sel_window,askUserAboutReplacingExistingAnimationForObject,pcVar6,
                         pcVar5);
  _objc_msgSend(pvVar2,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,pvVar3
                ,self,puVar1,pvVar4);
  pvVar3 = *(id *)PTR_00336058;
  pvVar2 = _objc_msgSend(pvVar2,sel_window);
  _objc_msgSend(pvVar3,sel_runModalForWindow_,pvVar2);
  return;
}

*/
- (void)zoomToActualSize
{
    [self setZoomMode:0];
    [self zoomToFactor:(float)[HSEditorZoomController actualZoomFactor]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000cd4f @ 0000cd4f, 167 bytes * /

void FUN_0000cd4f(HSEditorCardView *self,SEL _cmd)

{
  double dVar1;
  undefined4 uVar2;
  float fVar3;
  float local_14;
  
  dVar1 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar3 = (float)dVar1;
  uVar2 = 0;
  local_14 = fVar3;
  _objc_msgSend(cls_HSEditorZoomController,sel_nextZoomOutFactor_zoomInFactor_forZoomFactor_,
                &local_14,0,fVar3);
  if (!NAN(local_14)) {
    _objc_msgSend(self,sel_setZoomMode_,0,uVar2,fVar3);
    _objc_msgSend(self,sel_zoomToFactor_,local_14);
  }
  return;
}

*/
- (void)zoomOut
{
    float zoomOutFactor = [self zoomFactor];
    [HSEditorZoomController nextZoomOutFactor:&zoomOutFactor zoomInFactor:NULL forZoomFactor:[self zoomFactor]];
    if (!isnan(zoomOutFactor)) {
        [self setZoomMode:0];
        [self zoomToFactor:zoomOutFactor];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000cdf6 @ 0000cdf6, 167 bytes * /

void FUN_0000cdf6(HSEditorCardView *self,SEL _cmd)

{
  double dVar1;
  float *pfVar2;
  float fVar3;
  float local_14;
  
  dVar1 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar3 = (float)dVar1;
  pfVar2 = &local_14;
  local_14 = fVar3;
  _objc_msgSend(cls_HSEditorZoomController,sel_nextZoomOutFactor_zoomInFactor_forZoomFactor_,0,
                pfVar2,fVar3);
  if (!NAN(local_14)) {
    _objc_msgSend(self,sel_setZoomMode_,0,pfVar2,fVar3);
    _objc_msgSend(self,sel_zoomToFactor_,local_14);
  }
  return;
}

*/
- (void)zoomIn
{
    float zoomInFactor = [self zoomFactor];
    [HSEditorZoomController nextZoomOutFactor:NULL zoomInFactor:&zoomInFactor forZoomFactor:[self zoomFactor]];
    if (!isnan(zoomInFactor)) {
        [self setZoomMode:0];
        [self zoomToFactor:zoomInFactor];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000ce9d @ 0000ce9d, 128 bytes * /

void FUN_0000ce9d(HSEditorCardView *self,SEL _cmd,id onScalePopUp)

{
  id pvVar1;
  double dVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(onScalePopUp,sel_selectedCell);
  pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  dVar2 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
  op = sel_fitInWindow;
  if (!NAN((float)dVar2)) {
    op = sel_zoomToFactor_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)onScalePopUp:(id)aUp
{
    float factor = [[[aUp selectedCell] representedObject] floatValue];
    if (!isnan(factor)) {
        [self zoomToFactor:factor];
    } else {
        [self fitInWindow];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000cf1d @ 0000cf1d, 53 bytes * /

float FUN_0000cf1d(HSEditorCardView *self,SEL _cmd)

{
  longdouble extraout_ST0;
  HSEditorCardView *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_c,sel_zoomFactor);
  return (float)extraout_ST0;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000cf52 @ 0000cf52, 275 bytes * /

void FUN_0000cf52(HSEditorCardView *self,SEL _cmd,float zoomToFactor)

{
  id self_00;
  id pvVar1;
  float extraout_EDX;
  undefined4 *puVar2;
  float fVar3;
  undefined4 uStack_40;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  uStack_40 = 0xcf76;
  self_00 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar1 = *(id *)PTR_00336074;
  fVar3 = *(float *)(PTR_00336074 + 4);
  puVar2 = (undefined4 *)&stack0xffffffc4;
  if (self_00 != (id)0x0) {
    if ((zoomToFactor != 1.0) || (NAN(zoomToFactor))) {
      uStack_40 = 0xd011;
      _objc_msgSend_stret(&local_24,self_00,sel_documentVisibleRect);
      puVar2 = &uStack_40;
      fVar3 = local_18 * 0.5 + local_20;
      pvVar1 = (id)(local_1c * 0.5 + local_24);
    }
    else {
      uStack_40 = 0xcfaf;
      _objc_msgSend(self,sel_cardSize);
      uStack_40 = 0xcfee;
      pvVar1 = _objc_msgSend(self,sel_convertPointFromUserSpaceToViewSpace_);
      puVar2 = (undefined4 *)&stack0xffffffc4;
      fVar3 = extraout_EDX;
    }
  }
  puVar2[4] = fVar3;
  puVar2[3] = pvVar1;
  puVar2[2] = zoomToFactor;
  puVar2[1] = sel_zoomToFactor_aboutPoint_;
  *puVar2 = self;
  puVar2[-1] = 0xd05d;
  _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d0e9 @ 0000d0e9, 244 bytes * /

void FUN_0000d0e9(HSEditorCardView *self,SEL _cmd,int setZoomMode)

{
  id pvVar1;
  float extraout_EDX;
  HSEditorCardView *pHVar2;
  cfstringStruct *pcVar3;
  
  if (self->_zoomMode != setZoomMode) {
    self->_zoomMode = setZoomMode;
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pcVar3 = &cfstr_HSEditorCardViewDidChangeZoomModeNotification;
    pHVar2 = self;
    _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                  &cfstr_HSEditorCardViewDidChangeZoomModeNotification,self);
    if (self->_zoomMode == 1) {
      pvVar1 = _objc_msgSend(self,sel_enclosingScrollView,pcVar3,pHVar2);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(self,sel_cardSize,pcVar3,pHVar2);
        pHVar2 = (HSEditorCardView *)(extraout_EDX * 0.5);
        _objc_msgSend(self,
                      sel_HSEditorCardView_autolayoutCenteringAtUserPoint_respectingLastVisibleContent_
                      ,(float)pvVar1 * 0.5,pHVar2,0);
      }
      _objc_msgSend(self,sel_setNeedsDisplayOpenGLSurface_,1,pHVar2);
    }
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d1dd @ 0000d1dd, 539 bytes * /

void FUN_0000d1dd(HSEditorCardView *self,SEL _cmd,id scrollToObjects)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined8 uVar3;
  undefined *puVar4;
  char cVar5;
  id pvVar6;
  id pvVar7;
  int *piVar8;
  undefined4 local_54;
  undefined4 local_50;
  undefined4 local_4c;
  undefined4 local_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  puVar4 = PTR_00336078;
  piVar8 = (int *)&stack0xffffff74;
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  pvVar6 = _objc_msgSend(scrollToObjects,sel_objectEnumerator);
  local_3c = *(undefined4 *)(puVar4 + 8);
  uStack_38 = *(undefined4 *)(puVar4 + 0xc);
  local_44 = uVar1;
  uStack_40 = uVar2;
  while( true ) {
    *piVar8 = (int)pvVar6;
    piVar8[-1] = 0xd358;
    pvVar7 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
    if (pvVar7 == (id)0x0) break;
    piVar8[2] = (int)&DAT_00360868;
    piVar8[1] = (int)sel_queryHyperInterface_;
    *piVar8 = (int)pvVar7;
    piVar8[-1] = 0xd2ea;
    pvVar7 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
    if (pvVar7 != (id)0x0) {
      *(ulonglong *)(piVar8 + 6) = CONCAT44(uStack_38,local_3c);
      *(ulonglong *)(piVar8 + 4) = CONCAT44(uStack_40,local_44);
      uVar3 = *(undefined8 *)puVar4;
      *(undefined8 *)(piVar8 + 2) = *(undefined8 *)(puVar4 + 8);
      *(undefined8 *)piVar8 = uVar3;
      piVar8[-1] = 0xd31f;
      cVar5 = _NSEqualRects();
      if (cVar5 == '\0') {
        piVar8[2] = (int)sel_frameBoundingRect;
        piVar8[1] = (int)pvVar7;
        *piVar8 = (int)&local_34;
        piVar8[-1] = 0xd267;
        _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
        *(undefined8 *)(piVar8 + 6) = local_2c;
        *(undefined8 *)(piVar8 + 4) = local_34;
        *(ulonglong *)(piVar8 + 2) = CONCAT44(uStack_38,local_3c);
        *(ulonglong *)piVar8 = CONCAT44(uStack_40,local_44);
        piVar8[-1] = (int)&local_54;
        piVar8[-2] = 0xd2a1;
        _NSUnionRect();
        piVar8 = piVar8 + -2;
        local_44 = local_54;
        uStack_40 = local_50;
        local_3c = local_4c;
        uStack_38 = local_48;
      }
      else {
        piVar8[2] = (int)sel_frameBoundingRect;
        piVar8[1] = (int)pvVar7;
        *piVar8 = (int)&local_44;
        piVar8[-1] = 0xd340;
        _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
        piVar8 = piVar8 + -1;
      }
    }
    *(undefined **)((int)piVar8 + 4) = sel_nextObject;
  }
  *(ulonglong *)(piVar8 + 6) = CONCAT44(uStack_38,local_3c);
  *(ulonglong *)(piVar8 + 4) = CONCAT44(uStack_40,local_44);
  uVar3 = *(undefined8 *)puVar4;
  *(undefined8 *)(piVar8 + 2) = *(undefined8 *)(puVar4 + 8);
  *(undefined8 *)piVar8 = uVar3;
  piVar8[-1] = 0xd38f;
  cVar5 = _NSEqualRects();
  if (cVar5 == '\0') {
    *(ulonglong *)(piVar8 + 5) = CONCAT44(uStack_38,local_3c);
    *(ulonglong *)(piVar8 + 3) = CONCAT44(uStack_40,local_44);
    piVar8[2] = (int)sel_viewBoundingRectForUserRect_;
    piVar8[1] = (int)self;
    *piVar8 = (int)&local_24;
    piVar8[-1] = 0xd3c5;
    _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
    *(undefined8 *)(piVar8 + 3) = local_1c;
    *(undefined8 *)(piVar8 + 1) = local_24;
    *piVar8 = (int)sel_scrollRectToVisible_;
    piVar8[-1] = (int)self;
    piVar8[-2] = 0xd3f0;
    _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  }
  return;
}

*/
- (void)scrollToObjects:(id)aObjects
{
    NSRect unionRect = NSZeroRect;
    NSEnumerator *e = [aObjects objectEnumerator];
    id object;
    while ((object = [e nextObject]) != nil) {
        id geometry = [object queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry != nil) {
            if (NSEqualRects(unionRect, NSZeroRect)) {
                unionRect = [geometry frameBoundingRect];
            } else {
                unionRect = NSUnionRect(unionRect, [geometry frameBoundingRect]);
            }
        }
    }
    if (!NSEqualRects(unionRect, NSZeroRect)) {
        [self scrollRectToVisible:[self viewBoundingRectForUserRect:unionRect]];
    }
}

- (void)scrollToObject:(id)aObject
{
    [self scrollRectToVisible:[self viewBoundingRectForUserRect:[aObject frameBoundingRect]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00003697 @ 00003697, 18 bytes * /

void FUN_00003697(HSEditorCardView *self,SEL _cmd,id appDidBecomeActive)

{
  *(undefined4 *)((int)&self->_lightweightChangeProcessingModeCounter + 1) = 0;
  return;
}

*/
- (void)appDidBecomeActive:(id)aActive
{
    _lightweightChangeProcessingModeCounter = 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d489 @ 0000d489, 121 bytes * /

void FUN_0000d489(HSEditorCardView *self,SEL _cmd,id someWindowDidResignKey)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(someWindowDidResignKey,sel_object);
  *(id *)((int)&self->_lightweightChangeProcessingModeCounter + 1) = pvVar1;
  pvVar1 = _objc_msgSend(self,sel_window);
  if (pvVar1 == *(id *)((int)&self->_lightweightChangeProcessingModeCounter + 1)) {
    pvVar1 = _objc_msgSend(self,sel_selection);
    _objc_msgSend(pvVar1,sel_setShouldDisplaySelectionKnobs_,1);
  }
  return;
}

*/
- (void)someWindowDidResignKey:(id)aKey
{
    _lastActiveWindow = [aKey object];
    if ([self window] == _lastActiveWindow) {
        [[self selection] setShouldDisplaySelectionKnobs:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d502 @ 0000d502, 439 bytes * /

void FUN_0000d502(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  HSEditorCardView *pHVar2;
  HSEditorCardView *self_01;
  SEL op;
  undefined4 uVar3;
  undefined4 uVar4;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_1c,sel_viewDidMoveToWindow);
  pvVar1 = _objc_msgSend(self,sel_window);
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_00336070,0);
    self_01 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    uVar3 = *(undefined4 *)PTR_00336060;
    uVar4 = *(undefined4 *)PTR_00336058;
    op = sel_removeObserver_name_object_;
  }
  else {
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,sel_someWindowDidResignKey_,
                  *(undefined4 *)PTR_0033606c,0);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    uVar4 = *(undefined4 *)PTR_00336060;
    _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_appDidBecomeActive_,uVar4,
                  *(undefined4 *)PTR_00336058);
    pvVar1 = _objc_msgSend(self,sel_card);
    pHVar2 = _objc_msgSend(pvVar1,sel_hyperEnumerator);
    uVar3 = 1;
    self_01 = self;
    op = sel_reflectCardObjectsHiddenStateOfObjectsInEnumerator_invalidate_;
    self = pHVar2;
  }
  _objc_msgSend(self_01,op,self,uVar3,uVar4);
  return;
}

*/
- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window] == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:NSApp];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someWindowDidResignKey:) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
        [self reflectCardObjectsHiddenStateOfObjectsInEnumerator:[[self card] hyperEnumerator] invalidate:YES];
    }
}

- (BOOL)isAuxiliaryIconsCanvasLayerEnabled
{
    BOOL bVar2;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:HSHideAuxiliaryIcons]) {
        bVar2 = [[[self card] stack] cardObjectsVisibility] != 0x1;
    }
    else {
        bVar2 = NO;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d74c @ 0000d74c, 495 bytes * /

void FUN_0000d74c(HSEditorCardView *self,SEL _cmd,id renderer,id didDrawRegion,
                 id ofRenderLayerAtIndexPath,id withRenderDelegate)

{
  id pvVar1;
  id pvVar2;
  HSEditorCardView *local_2c;
  undefined *local_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  local_2c = self;
  local_28 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_2c,
                     sel_renderer_didDrawRegion_ofRenderLayerAtIndexPath_withRenderDelegate_);
  pvVar1 = _objc_msgSend(renderer,sel_rootRenderLayer);
  pvVar1 = _objc_msgSend(pvVar1,sel_renderLayerAtIndexPath_role_);
  pvVar2 = _objc_msgSend(renderer,sel_visualization);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperObject);
  if (pvVar2 == pvVar1) {
    pvVar1 = _objc_msgSend((id)0x0,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_gridSettings);
      pvVar1 = _objc_msgSend(pvVar1,sel_isGridVisible);
      if ((char)pvVar1 != '\0') {
        _objc_msgSend(self,sel_renderGrid);
      }
      _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
      pvVar1 = _objc_msgSend(self,sel_viewSpaceToUserSpaceTransform);
      _objc_msgSend(pvVar1,sel_concat);
      pvVar1 = _objc_msgSend(self,sel_rootCanvasLayer);
      _objc_msgSend_stret(&local_24,self,sel_rectBeingDrawn);
      _objc_msgSend(pvVar1,sel_renderBitmapToolsLayerInRect_,local_24,local_1c);
      _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
      self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] | 8;
    }
  }
  return;
}

*/
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate
{
    [super renderer:aRenderer didDrawRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:aDelegate];
    NSString *role = nil;
    id layer = [[aRenderer rootRenderLayer] renderLayerAtIndexPath:aPath role:&role];
    if ([[aRenderer visualization] hyperObject] == [layer hyperObject]) {
        if ([role isEqualToString:@"HSBackgroundRenderLayerRole"]) {
            if ([[self gridSettings] isGridVisible]) {
                [self renderGrid];
            }
            [NSGraphicsContext saveGraphicsState];
            [[self viewSpaceToUserSpaceTransform] concat];
            [[self rootCanvasLayer] renderBitmapToolsLayerInRect:[self rectBeingDrawn]];
            [NSGraphicsContext restoreGraphicsState];
            _didDrawBitmapToolsLayer = 1;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d93b @ 0000d93b, 130 bytes * /

void FUN_0000d93b(HSEditorCardView *self,SEL _cmd,NSRect renderRootCanvasLayerInRect)

{
  uint uVar1;
  id self_00;
  SEL op;
  
  uVar1 = *(uint *)self->_cacheOnlyRendering;
  self_00 = _objc_msgSend(self,sel_rootCanvasLayer);
  op = sel_renderRect_;
  if ((uVar1 & 8) != 0) {
    op = sel_renderTopLayersInRect_;
  }
  _objc_msgSend(self_00,op,renderRootCanvasLayerInRect.origin,renderRootCanvasLayerInRect.size);
  return;
}

*/
- (void)renderRootCanvasLayerInRect:(NSRect)aRect
{
    if (_didDrawBitmapToolsLayer) {
        [[self rootCanvasLayer] renderTopLayersInRect:aRect];
    } else {
        [[self rootCanvasLayer] renderRect:aRect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000d9bd @ 0000d9bd, 82 bytes * /

void FUN_0000d9bd(HSEditorCardView *self,SEL _cmd,NSRect drawQuartzRect)

{
  HSEditorCardView *local_c;
  undefined *local_8;
  
  self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] & 0xf7;
  local_c = self;
  local_8 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_c,sel_drawQuartzRect_,drawQuartzRect.origin,drawQuartzRect.size);
  return;
}

*/
- (void)drawQuartzRect:(NSRect)aRect
{
    _didDrawBitmapToolsLayer = 0;
    [super drawQuartzRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000da0f @ 0000da0f, 489 bytes * /

void FUN_0000da0f(HSEditorCardView *self,SEL _cmd,NSRect preDrawContentRect)

{
  char cVar1;
  id pvVar2;
  int *piVar3;
  HSEditorCardView *local_5c;
  undefined *local_58;
  undefined4 local_54;
  undefined4 uStack_50;
  undefined4 local_4c;
  undefined4 uStack_48;
  undefined4 local_44;
  undefined4 local_40;
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 uStack_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  _objc_msgSend_stret(&local_54,self,sel_cardViewingRect);
  piVar3 = (int *)&stack0xffffff80;
  cVar1 = _NSContainsRect();
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    _objc_msgSend(pvVar2,sel_graphicsPort);
    _CGContextSaveGState();
    _CGContextBeginPath();
    _objc_msgSend_stret(&local_44,self,sel_bounds);
    piVar3 = (int *)&stack0xffffff7c;
    local_34 = local_44;
    uStack_30 = local_40;
    local_2c = local_3c;
    uStack_28 = local_38;
    _CGContextAddRect();
    local_24 = local_54;
    uStack_20 = uStack_50;
    local_1c = local_4c;
    uStack_18 = uStack_48;
    _CGContextAddRect();
    _CGContextEOClip();
    pvVar2 = _objc_msgSend(self,sel_backgroundColor);
    _objc_msgSend(pvVar2,sel_set);
    _objc_msgSend(self,sel_drawBackgroundInContentRect_);
    _CGContextRestoreGState();
  }
  local_5c = self;
  local_58 = PTR_s_HSToolView_0034db70;
  *(NSSize *)(piVar3 + 4) = preDrawContentRect.size;
  *(NSPoint *)(piVar3 + 2) = preDrawContentRect.origin;
  piVar3[1] = (int)sel_preDrawContentRect_;
  *piVar3 = (int)&local_5c;
  piVar3[-1] = 0xdbf0;
  _objc_msgSendSuper((void *)*piVar3,(SEL)piVar3[1]);
  return;
}

*/
- (void)preDrawContentRect:(NSRect)aRect
{
    NSRect cardRect = [self cardViewingRect];
    if (!NSContainsRect(cardRect, aRect)) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSaveGState(ctx);
        CGContextBeginPath(ctx);
        CGContextAddRect(ctx, NSRectToCGRect([self bounds]));
        CGContextAddRect(ctx, NSRectToCGRect(cardRect));
        CGContextEOClip(ctx);
        [[self backgroundColor] set];
        [self drawBackgroundInContentRect:aRect];
        CGContextRestoreGState(ctx);
    }
    [super preDrawContentRect:aRect];
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [aColor retain];
        [_backgroundColor release];
        _backgroundColor = aColor;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000dc4d @ 0000dc4d, 120 bytes * /

id FUN_0000dc4d(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = self->_backgroundColor;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_HSEditorCardView_backgroundPattern);
    op = sel_colorWithPatternImage_;
    if (pvVar1 == (id)0x0) {
      op = sel_clearColor;
    }
    pvVar1 = _objc_msgSend(cls_NSColor,op);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_backgroundColor = pvVar1;
  }
  return pvVar1;
}

*/
- (id)backgroundColor
{
    if (_backgroundColor == nil) {
        id pattern = [self HSEditorCardView_backgroundPattern];
        NSColor *color = pattern ? [NSColor colorWithPatternImage:pattern] : [NSColor clearColor];
        _backgroundColor = [color retain];
    }
    return _backgroundColor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000dcc5 @ 0000dcc5, 228 bytes * /

id FUN_0000dcc5(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id self_00;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar2 = _objc_msgSend(pvVar1,sel_stringForKey_,*(undefined4 *)PTR_00336054);
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar5 = &cfstr_WABPatterns;
  pcVar4 = &cfstr_tiff;
  pcVar3 = &cfstr_Denim;
  if (pcVar2 != (cfstringStruct *)0x0) {
    pcVar3 = pcVar2;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_inDirectory_,pcVar3,&cfstr_tiff,
                         &cfstr_WABPatterns);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    self_00 = _objc_msgSend(cls_NSImage,sel_alloc,pcVar3,pcVar4,pcVar5);
    pvVar1 = _objc_msgSend(self_00,sel_initByReferencingFile_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  }
  return pvVar1;
}

*/
- (id)HSEditorCardView_backgroundPattern
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:HSWorkAreaBackgroundKey];
    NSString *path = [[NSBundle mainBundle] pathForResource:(name ? name : @"Denim") ofType:@"tiff" inDirectory:@"WABPatterns"];
    if (path == nil) {
        return nil;
    }
    return [[[NSImage alloc] initByReferencingFile:path] autorelease];
}

- (BOOL)resignFirstResponder
{
    [[HSObjectAssistantController sharedAssistantController] setTemporaryHide:NO];
    return (BOOL)[super resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [[HSObjectAssistantController sharedAssistantController] setTemporaryHide:YES];
    return (BOOL)[super becomeFirstResponder];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00003705 @ 00003705, 99 bytes * /

BOOL FUN_00003705(HSEditorCardView *self,SEL _cmd,id acceptsFirstMouse)

{
  id pvVar1;
  HSEditorCardView *local_14;
  undefined *local_10;
  
  if (self->_ignoreNextMouseDown == '\0') {
    local_14 = self;
    local_10 = PTR_s_HSToolView_0034db70;
    pvVar1 = _objc_msgSendSuper(&local_14,sel_acceptsFirstMouse_,acceptsFirstMouse);
    if ((char)pvVar1 != '\0') {
      return *(int *)((int)&self->_lightweightChangeProcessingModeCounter + 1) != 0;
    }
  }
  else {
    self->_ignoreNextMouseDown = '\0';
  }
  return '\0';
}

*/
- (BOOL)acceptsFirstMouse:(id)aMouse
{
    if (_ignoreNextMouseDown) {
        _ignoreNextMouseDown = NO;
        return NO;
    }
    if ([super acceptsFirstMouse:aMouse]) {
        return _lastActiveWindow != NULL;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000de81 @ 0000de81, 177 bytes * /

void FUN_0000de81(HSEditorCardView *self,SEL _cmd,NSSize setFrameSize)

{
  HSEditorCardView *self_00;
  SEL op;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  self_00 = self->_liveResizeRecacheTimer;
  if (self_00 == (HSEditorCardView *)0x0) {
    self_00 = self;
    op = sel_HSEditorCardView_setupLiveResizeRecacheTimer;
    if ((self->_cacheOnlyRendering[0] & 1) == 0) goto LAB_0000def3;
  }
  else {
    _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0,0x3ff00000);
    op = sel_setFireDate_;
  }
  _objc_msgSend(self_00,op);
LAB_0000def3:
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_1c,sel_setFrameSize_,setFrameSize.width,setFrameSize.height);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000dfb2 @ 0000dfb2, 183 bytes * /

void FUN_0000dfb2(HSEditorCardView *self,SEL _cmd)

{
  HSEditorCardView *local_14;
  undefined *local_10;
  
  if ((self->_cacheOnlyRendering[0] & 1) != 0) {
    _objc_msgSend(self,sel_declineDrawingQualityLoss_,0x3f7ff972);
    _objc_msgSend(self,sel_setNeedsDisplayOpenGLSurface_,1);
    self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] & 0xfe;
    _objc_msgSend(self->_liveResizeRecacheTimer,sel_invalidate);
    _objc_msgSend(self->_liveResizeRecacheTimer,sel_release);
    self->_liveResizeRecacheTimer = (id)0x0;
  }
  local_14 = self;
  local_10 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_14,sel_viewDidEndLiveResize);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e0ca @ 0000e0ca, 84 bytes * /

void FUN_0000e0ca(HSEditorCardView *self,SEL _cmd)

{
  if (self->_zoomMode == 1) {
    _objc_msgSend(self,sel_acceptDrawingQualityLoss_,0x3f7ff972);
    self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] | 1;
    _objc_msgSend(self,sel_HSEditorCardView_setupLiveResizeRecacheTimer);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e11e @ 0000e11e, 234 bytes * /

void FUN_0000e11e(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  HSEditorCardView *pHVar5;
  undefined *puVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  
  pvVar1 = _objc_msgSend(cls_NSTimer,sel_alloc);
  puVar6 = sel_HSEditorCardView_liveResizeRecache_;
  pvVar2 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0,0x3ff00000);
  uVar4 = 0;
  uVar3 = 0;
  uVar8 = 0;
  uVar7 = 0;
  pHVar5 = self;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithFireDate_interval_target_selector_userInfo_repeats_,
                         pvVar2,0,0,self,puVar6,0,0);
  self->_liveResizeRecacheTimer = pvVar1;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop,pvVar2,uVar3,uVar4,pHVar5,puVar6,uVar7,
                           uVar8);
    _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_liveResizeRecacheTimer,
                  *(undefined4 *)PTR_00336064);
  }
  return;
}

*/
- (BOOL)isOpaque
{
    return YES;
}

- (id)cardForDragHost
{
    return [self card];
}

- (void)endDragOperation
{
    [self endContentChangeAccumulation];
}

- (void)beginDragOperation
{
    [self beginContentChangeAccumulation];
}

- (BOOL)needImageOriginConvertion
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e27a @ 0000e27a, 69 bytes * /

NSRect * FUN_0000e27a(NSRect *__return_storage_ptr__,HSEditorCardView *self,SEL _cmd,
                     NSRect convertToDragHostCardRect)

{
  NSRect *extraout_EAX;
  
  _objc_msgSend_stret(__return_storage_ptr__,self,sel_userBoundingRectForViewRect_,
                      convertToDragHostCardRect.origin,convertToDragHostCardRect.size);
  return extraout_EAX;
}

*/
- (NSRect)convertToDragHostCardRect:(NSRect)aRect
{
    return [self userBoundingRectForViewRect:aRect];
}

- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard
{
    return [self convertPointFromViewSpaceToUserSpace:aCard];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e2fb @ 0000e2fb, 90 bytes * /

ulonglong FUN_0000e2fb(HSEditorCardView *self,SEL _cmd)

{
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  _objc_msgSend_stret(&local_1c,self,sel_visibleRect);
  return CONCAT44(local_10 * 0.5 + local_18,local_14 * 0.5 + local_1c);
}

*/
- (NSPoint)dragHostCardCenterPoint
{
    NSRect visible = [self visibleRect];
    return NSMakePoint(visible.origin.x + visible.size.width * 0.5, visible.origin.y + visible.size.height * 0.5);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e355 @ 0000e355, 82 bytes * /

id FUN_0000e355(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = *(id *)((self->super).super_HSCardView + 0x154);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSEditingContext,sel_presentationContext);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    *(id *)((self->super).super_HSCardView + 0x154) = pvVar1;
  }
  return pvVar1;
}

*/
- (id)presentationContext
{
    if (_presentationContext == nil) {
        _presentationContext = [[HSEditingContext presentationContext] retain];
    }
    return _presentationContext;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e61f @ 0000e61f, 120 bytes * /

ulonglong FUN_0000e61f(HSEditorCardView *self,SEL _cmd,NSPoint convertPointFromUserSpaceToViewSpace)

{
  float fVar1;
  double dVar2;
  double dVar3;
  
  dVar2 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar1 = (self->_cardOffset).height;
  dVar3 = _objc_msgSend_fpret(self,sel_zoomFactor);
  return CONCAT44((float)dVar2 * convertPointFromUserSpaceToViewSpace.y + fVar1,
                  (float)dVar3 * convertPointFromUserSpaceToViewSpace.x + (self->_cardOffset).width)
  ;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e697 @ 0000e697, 187 bytes * /

id FUN_0000e697(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  float fVar2;
  double dVar3;
  
  dVar3 = _objc_msgSend_fpret(self,sel_zoomFactor);
  fVar2 = 1.0 / (float)dVar3;
  pvVar1 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperTransformStruct_,
                         (ulonglong)(uint)fVar2,(ulonglong)(uint)fVar2 << 0x20,
                         CONCAT44(-(self->_cardOffset).height * fVar2,
                                  -(self->_cardOffset).width * fVar2));
  return pvVar1;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e752 @ 0000e752, 169 bytes * /

id FUN_0000e752(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  double dVar3;
  
  dVar2 = _objc_msgSend_fpret(self,sel_zoomFactor);
  dVar3 = _objc_msgSend_fpret(self,sel_zoomFactor);
  pvVar1 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperTransformStruct_,
                         (ulonglong)(uint)(float)dVar2,(ulonglong)(uint)(float)dVar3 << 0x20,
                         self->_cardOffset);
  return pvVar1;
}

*/
- (void)onionSkinModeDidChange:(id)aChange
{
    [self setOnionSkinMode:[[HSEditorController sharedDocumentController] onionSkinMode]];
}

- (void)onionSkinImageChanged:(id)aChanged
{
    if (_newOnionSkinModeIsInRenderingProcess == NO) {
        [self setOnionSkinMode:[[HSEditorController sharedDocumentController] onionSkinMode]];
    }
}

- (void)cardSizeDidChange:(id)aChange
{
    if ([self enclosingScrollView] != nil) {
        [self autolayoutPreservingVisibleCenter];
        [self setNeedsDisplayOpenGLSurface:YES];
    }
    [self updateCardAlternateProportion];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e91e @ 0000e91e, 174 bytes * /

void FUN_0000e91e(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_cardSize);
  if (((float)pvVar1 != 0.0) && (extraout_EDX != 0.0)) {
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
    _objc_msgSend(pvVar2,sel_setAlternateProportion_,extraout_EDX / (float)pvVar1);
  }
  return;
}

*/
- (void)updateCardAlternateProportion
{
    NSSize cardSize = [self cardSize];
    if (cardSize.width != 0 && cardSize.height != 0) {
        [[[HSToolManager sharedToolManager] toolSettings] setAlternateProportion:cardSize.height / cardSize.width];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000e9cc @ 0000e9cc, 84 bytes * /

void FUN_0000e9cc(HSEditorCardView *self,SEL _cmd)

{
  HSEditorCardView *local_14;
  undefined *local_10;
  
  if ((self->_cacheOnlyRendering[0] & 4) == 0) {
    _objc_msgSend(self,sel_HSEditorCardView_reflectObjectsLayout);
  }
  local_14 = self;
  local_10 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_14,sel_processAccumulatedContentChanges);
  return;
}

*/
- (void)processAccumulatedContentChanges
{
    if (!_isObjectsLayoutReflected) {
        [self HSEditorCardView_reflectObjectsLayout];
    }
    [super processAccumulatedContentChanges];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000ea20 @ 0000ea20, 563 bytes * /

id FUN_0000ea20(HSEditorCardView *self,SEL _cmd,id stringOfPermittedLengthFromString)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id local_14;
  
  pvVar1 = _objc_msgSend(stringOfPermittedLengthFromString,sel_length);
  if ((id)0x7d00 < pvVar1) {
    pvVar1 = _objc_msgSend(cls_HSAlert,sel_new);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_Do_you_want_to_insert_what_will_fit_,&cfstr_empty,&cfstr_Alerts);
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_The_text_file_you_selected_to_insert_will_cause_,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2);
    _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar3);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Insert,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar4 = &cfstr_Alerts;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
    _objc_msgSend(pvVar1,sel_release);
    if (pvVar2 == (id)0x3e8) {
      stringOfPermittedLengthFromString =
           _objc_msgSend(stringOfPermittedLengthFromString,sel_attributedSubstringFromRange_,0,32000
                         ,pcVar4);
    }
    else {
      local_14 = (id)0x0;
      stringOfPermittedLengthFromString = local_14;
    }
  }
  return stringOfPermittedLengthFromString;
}

*/
- (id)stringOfPermittedLengthFromString:(id)aString
{
    if ([aString length] > 32000) {
        HSAlert *alert = [HSAlert new];
        NSString *message = [[NSBundle mainBundle] localizedStringForKey:@"Do you want to insert what will fit?" value:@"" table:@"Alerts"];
        NSString *informative = [[NSBundle mainBundle] localizedStringForKey:@"The text file you selected to insert will cause the field to exceed its limit of 32,000 characters. Click Insert to have the text cut at the end." value:@"" table:@"Alerts"];
        [alert setMessageText:message];
        [alert setInformativeText:informative];
        [alert addButtonWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Insert" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        NSInteger response = [alert runModal];
        [alert release];
        if (response == 1000) {
            return [aString attributedSubstringFromRange:NSMakeRange(0, 32000)];
        }
        return nil;
    }
    return aString;
}

- (void)cardStackDidChange
{
    [self refreshEnabledAuxiliaryCanvasLayers];
}

- (void)ignoreNextMouseDown
{
    _ignoreNextMouseDown = YES;
}

- (void)toolManagerWillSelectTool:(id)aTool explicitly:(BOOL)aExplicitly
{
    [super toolManagerWillSelectTool:aTool explicitly:aExplicitly];
    if ([self isColorPickingModeActive]) {
        [self cancelColorPicking];
    }
}

- (void)setCard:(id)aCard
{
    id pvVar1;
    id pvVar1_2;
    id pvVar2_4;

    pvVar1 = [self card];
    if (pvVar1 != aCard) {
        [self saveEditingState];
        [super setCard:aCard];
        [self setOnionSkinMode:[[HSEditorController sharedDocumentController] onionSkinMode]];
        pvVar2_4 = [[HSToolManager sharedToolManager] currentTool];
        if ([pvVar2_4 isKindOfClass:[HSBaseBitmapTool class]]) {
            [[pvVar2_4 bitmapTool] removeAllUndoActionsFromManager:[self undoManager]];
        }
        pvVar1_2 = [pvVar1 stack];
        if ([aCard stack] != pvVar1_2) {
            [self refreshEnabledAuxiliaryCanvasLayers];
        }
        [self updateCardAlternateProportion];
        if ([self enclosingScrollView] != nil) {
            [self HSEditorCardView_autosizePreservingVisibleCenter];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00003662 @ 00003662, 21 bytes * /

BOOL FUN_00003662(HSEditorCardView *self,SEL _cmd)

{
  return *(int *)((int)&self->_didDrawBitmapToolsLayer + 1) != 0;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000eeb1 @ 0000eeb1, 151 bytes * /

void FUN_0000eeb1(HSEditorCardView *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  undefined4 uVar3;
  
  iVar1 = *(int *)((int)&self->_didDrawBitmapToolsLayer + 1) + -1;
  *(int *)((int)&self->_didDrawBitmapToolsLayer + 1) = iVar1;
  if (iVar1 == 0) {
    _objc_msgSend(self,sel_endContentChangeAccumulation);
    _objc_msgSend(self,sel_declineDrawingQualityLoss_,0x3f7ff972);
    uVar3 = 1;
    _objc_msgSend(self,sel_setNeedsDisplayOpenGLSurface_,1);
    pvVar2 = _objc_msgSend(self,sel_inLiveResize);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(self,sel_enterLiveResizeCacheOnlyRenderingModeIfNeeded,uVar3);
    }
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000ef48 @ 0000ef48, 91 bytes * /

void FUN_0000ef48(HSEditorCardView *self,SEL _cmd)

{
  int iVar1;
  
  iVar1 = *(int *)((int)&self->_didDrawBitmapToolsLayer + 1);
  if (iVar1 == 0) {
    _objc_msgSend(self,sel_beginContentChangeAccumulation);
    _objc_msgSend(self,sel_acceptDrawingQualityLoss_,0x3f7ff972);
    iVar1 = *(int *)((int)&self->_didDrawBitmapToolsLayer + 1);
  }
  *(int *)((int)&self->_didDrawBitmapToolsLayer + 1) = iVar1 + 1;
  return;
}

*/
- (void)nodeContainerAttributeChanged:(id)aChanged
{
    if ([_poofPointsQueue count] == 0) {
        [self HSEditorCardView_reflectObjectsDidRelayout];
    }
}

- (void)cardChildrenGeometryChanged:(id)aChanged
{
    [self HSEditorCardView_reflectObjectsDidRelayout];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000f00f @ 0000f00f, 73 bytes * /

void FUN_0000f00f(HSEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_areContentChangesBeingAccumulated);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_HSEditorCardView_reflectObjectsLayout);
  }
  else {
    self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] & 0xfb;
  }
  return;
}

*/
- (void)HSEditorCardView_reflectObjectsDidRelayout
{
    if (![self areContentChangesBeingAccumulated]) {
        [self HSEditorCardView_reflectObjectsLayout];
    } else {
        _isObjectsLayoutReflected = 0;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000f058 @ 0000f058, 617 bytes * /

void FUN_0000f058(HSEditorCardView *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  undefined4 *puVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  undefined4 local_54;
  undefined1 local_2c [8];
  float local_24;
  float local_20;
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
  if (pvVar2 == (id)0x0) {
    return;
  }
  _objc_msgSend_stret(local_2c,self,sel_frame);
  fVar4 = (self->_cardOffset).width;
  fVar5 = (self->_cardOffset).height;
  local_54 = 0xf0cb;
  _objc_msgSend(self,sel_autosizePreservingVisibleArea);
  fVar7 = (self->_cardOffset).width;
  fVar1 = (self->_cardOffset).height;
  if ((fVar7 != 0.0) || (NAN(fVar7))) {
    fVar6 = ABS(fVar7);
  }
  else {
    fVar6 = 1.0;
  }
  if ((fVar4 != 0.0) || (NAN(fVar4))) {
    fVar8 = ABS(fVar4);
  }
  else {
    fVar8 = 1.0;
  }
  if (fVar8 <= fVar6) {
    fVar8 = fVar6;
  }
  puVar3 = (undefined4 *)&stack0xffffffb0;
  if (ABS(fVar7 - fVar4) <= fVar8 * 0.0005) {
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar4 = ABS(fVar1);
    }
    else {
      fVar4 = 1.0;
    }
    if ((fVar5 != 0.0) || (NAN(fVar5))) {
      fVar7 = ABS(fVar5);
    }
    else {
      fVar7 = 1.0;
    }
    if (fVar7 <= fVar4) {
      fVar7 = fVar4;
    }
    puVar3 = (undefined4 *)&stack0xffffffb0;
    if (ABS(fVar1 - fVar5) <= fVar7 * 0.0005) {
      local_54 = 0xf1ca;
      _objc_msgSend_stret(local_1c,self,sel_frame);
      if ((local_14 != 0.0) || (NAN(local_14))) {
        fVar4 = ABS(local_14);
      }
      else {
        fVar4 = 1.0;
      }
      if ((local_24 != 0.0) || (NAN(local_24))) {
        fVar5 = ABS(local_24);
      }
      else {
        fVar5 = 1.0;
      }
      if (fVar5 <= fVar4) {
        fVar5 = fVar4;
      }
      puVar3 = &local_54;
      if (ABS(local_14 - local_24) <= fVar5 * 0.0005) {
        if ((local_10 != 0.0) || (NAN(local_10))) {
          fVar4 = ABS(local_10);
        }
        else {
          fVar4 = 1.0;
        }
        if ((local_20 != 0.0) || (NAN(local_20))) {
          fVar5 = ABS(local_20);
        }
        else {
          fVar5 = 1.0;
        }
        if (fVar5 <= fVar4) {
          fVar5 = fVar4;
        }
        puVar3 = &local_54;
        if (ABS(local_10 - local_20) <= fVar5 * 0.0005) goto LAB_0000f2b3;
      }
    }
  }
  puVar3[1] = sel_setNeedsDisplayOpenGLSurface_;
  *puVar3 = self;
  puVar3[2] = 1;
  puVar3[-1] = 0xf2b3;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
LAB_0000f2b3:
  self->_cacheOnlyRendering[0] = self->_cacheOnlyRendering[0] | 4;
  return;
}

*/
- (void)HSEditorCardView_reflectObjectsLayout
{
    if ([self enclosingScrollView] == nil) {
        return;
    }
#define HS_FUZZY_EQUAL(a, b) (fabsf((a) - (b)) <= fmaxf(((a) != 0.0f || isnan(a)) ? fabsf(a) : 1.0f, ((b) != 0.0f || isnan(b)) ? fabsf(b) : 1.0f) * 0.0005f)
    NSRect oldFrame = [self frame];
    NSSize oldOffset = _cardOffset;
    [self autosizePreservingVisibleArea];
    NSSize newOffset = _cardOffset;
    NSRect newFrame = [self frame];
    BOOL unchanged = HS_FUZZY_EQUAL(newOffset.width, oldOffset.width) && HS_FUZZY_EQUAL(newOffset.height, oldOffset.height)
        && HS_FUZZY_EQUAL(oldFrame.size.width, newFrame.size.width) && HS_FUZZY_EQUAL(oldFrame.size.height, newFrame.size.height);
#undef HS_FUZZY_EQUAL
    if (!unchanged) {
        [self setNeedsDisplayOpenGLSurface:YES];
    }
    _isObjectsLayoutReflected = 1;
}

- (void)HSEditorCardView_autosizePreservingVisibleCenter
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;
    double dVar5;
    double dVar6;

    dVar5 = [self zoomFactor];
    fVar1 = (_cardOffset).width;
    fVar2 = (_cardOffset).height;
    if (_zoomMode == 1) {
        [self autozoomToFitCardToVisibleArea];
    }
    [self autosizePreservingVisibleCenter];
    dVar6 = [self zoomFactor];
    if (((float)dVar6 < (float)dVar5 + -0.0001) || ((float)dVar5 + 0.0001 < (float)dVar6)) {
        fVar3 = (_cardOffset).width;
        fVar4 = (_cardOffset).height;
        if ((fVar1 + -0.001953125 <= fVar3) && (((fVar3 <= fVar1 + 0.001953125 && (fVar2 + -0.001953125 <= fVar4)) && (fVar4 <= fVar2 + 0.001953125)))) {
            [self notifyDidChangeUserSpaceToViewSpaceTransform];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000f90e @ 0000f90e, 300 bytes * /

void FUN_0000f90e(HSEditorCardView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined4 uVar6;
  undefined4 uVar7;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar3 = _objc_msgSend(self,sel_cardSize);
  if ((0.0 < (float)pvVar3) && (0.0 < extraout_EDX)) {
    pvVar4 = _objc_msgSend(self,sel_enclosingScrollView);
    self_00 = _objc_msgSend(pvVar4,sel_class);
    pvVar5 = _objc_msgSend(pvVar4,sel_borderType);
    _objc_msgSend_stret(local_24,pvVar4,sel_frame);
    uVar7 = 0;
    uVar6 = 0;
    pvVar4 = _objc_msgSend(self_00,
                           sel_contentSizeForFrameSize_hasHorizontalScroller_hasVerticalScroller_borderType_
                           ,local_1c,local_18,0,0,pvVar5);
    fVar1 = extraout_EDX_00 / extraout_EDX;
    if ((float)pvVar4 / (float)pvVar3 <= extraout_EDX_00 / extraout_EDX) {
      fVar1 = (float)pvVar4 / (float)pvVar3;
    }
    fVar2 = 0.01;
    if (0.01 <= fVar1) {
      fVar2 = fVar1;
    }
    _objc_msgSend(self,sel_setZoomFactor_,fVar2,local_18,uVar6,uVar7,pvVar5);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0000fa76 @ 0000fa76, 520 bytes * /

void FUN_0000fa76(HSEditorCardView *self,SEL _cmd)

{
  uint uVar1;
  float *pfVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54 [2];
  undefined8 local_4c;
  
  _objc_msgSend_stret(&local_64,self,sel_cardViewingRect);
  _objc_msgSend_stret(&local_74,self,sel_bounds);
  local_54[0] = local_74;
  local_54[1] = local_70;
  local_4c._0_4_ = local_6c;
  local_4c._4_4_ = local_68;
  fVar4 = local_74 + local_6c;
  if (local_64 < fVar4) {
    local_5c = local_5c + local_64;
    if ((local_74 + 0.0 < local_5c) && (local_68 = local_68 + local_70, local_60 < local_68)) {
      local_58 = local_58 + local_60;
      fVar5 = local_70 + 0.0;
      if (fVar5 < local_58) {
        fVar3 = local_70;
        if (fVar5 < local_60) {
          local_4c._4_4_ = local_60 - local_70;
          fVar3 = local_60;
        }
        uVar1 = (uint)(fVar5 < local_60);
        if (local_58 < local_68) {
          local_54[uVar1 * 4] = local_74;
          local_54[uVar1 * 4 + 1] = local_58;
          *(float *)(&local_4c + uVar1 * 2) = local_6c;
          *(float *)((int)&local_4c + uVar1 * 0x10 + 4) = local_68 - local_58;
          uVar1 = uVar1 + 1;
          local_68 = local_58;
        }
        if (local_74 + 0.0 < local_64) {
          local_54[uVar1 * 4] = local_74;
          local_54[uVar1 * 4 + 1] = fVar3;
          *(float *)(&local_4c + uVar1 * 2) = local_64 - local_74;
          *(float *)((int)&local_4c + uVar1 * 0x10 + 4) = local_68 - fVar3;
          uVar1 = uVar1 + 1;
        }
        if (local_5c < fVar4) {
          local_54[uVar1 * 4] = local_5c;
          local_54[uVar1 * 4 + 1] = fVar3;
          *(float *)(&local_4c + uVar1 * 2) = fVar4 - local_5c;
          *(float *)((int)&local_4c + uVar1 * 0x10 + 4) = local_68 - fVar3;
          uVar1 = uVar1 + 1;
        }
        if (uVar1 == 0) {
          return;
        }
        pfVar2 = local_54;
        goto LAB_0000fc43;
      }
    }
  }
  pfVar2 = local_54;
  uVar1 = 1;
LAB_0000fc43:
  do {
    _objc_msgSend(self,sel_setNeedsDisplayOpenGLSurfaceInRect_,*(undefined8 *)pfVar2,
                  *(undefined8 *)(pfVar2 + 2));
    pfVar2 = pfVar2 + 4;
    uVar1 = uVar1 - 1;
  } while (uVar1 != 0);
  return;
}

*/
- (void)setNeedsDisplayWorkAreaBackground
{
    NSRect card = [self cardViewingRect];
    NSRect bounds = [self bounds];
    NSRect rects[4];
    NSUInteger count = 0;
    CGFloat cardMaxX = NSMaxX(card);
    CGFloat cardMaxY = NSMaxY(card);
    CGFloat boundsMaxX = NSMaxX(bounds);
    CGFloat boundsMaxY = NSMaxY(bounds);
    if (card.origin.x < boundsMaxX && NSMinX(bounds) < cardMaxX && card.origin.y < boundsMaxY && NSMinY(bounds) < cardMaxY) {
        CGFloat lower = NSMinY(bounds);
        CGFloat upper = boundsMaxY;
        if (NSMinY(bounds) < card.origin.y) {
            rects[count++] = NSMakeRect(NSMinX(bounds), NSMinY(bounds), bounds.size.width, card.origin.y - NSMinY(bounds));
            lower = card.origin.y;
        }
        if (cardMaxY < boundsMaxY) {
            rects[count++] = NSMakeRect(NSMinX(bounds), cardMaxY, bounds.size.width, boundsMaxY - cardMaxY);
            upper = cardMaxY;
        }
        if (NSMinX(bounds) < card.origin.x) {
            rects[count++] = NSMakeRect(NSMinX(bounds), lower, card.origin.x - NSMinX(bounds), upper - lower);
        }
        if (cardMaxX < boundsMaxX) {
            rects[count++] = NSMakeRect(cardMaxX, lower, boundsMaxX - cardMaxX, upper - lower);
        }
        if (count == 0) {
            return;
        }
    } else {
        rects[0] = bounds;
        count = 1;
    }
    for (NSUInteger i = 0; i < count; i++) {
        [self setNeedsDisplayOpenGLSurfaceInRect:rects[i]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000fc7e @ 0000fc7e, 209 bytes * /

NSRect * FUN_0000fc7e(NSRect *__return_storage_ptr__,HSEditorCardView *self,SEL _cmd)

{
  float fVar1;
  undefined *puVar2;
  char cVar3;
  HSEditorCardView *local_24;
  undefined *local_20;
  undefined1 local_1c [16];
  
  local_24 = self;
  local_20 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper_stret(local_1c,&local_24,sel_contentBoundingRect);
  cVar3 = _NSIsEmptyRect((int)local_1c._0_8_,SUB84(local_1c._0_8_,4),(int)local_1c._8_8_,
                         SUB84(local_1c._8_8_,4));
  puVar2 = PTR_00336078;
  if (cVar3 == '\0') {
    __return_storage_ptr__ =
         (NSRect *)
         _NSUnionRect(__return_storage_ptr__,(int)local_1c._0_8_,SUB84(local_1c._0_8_,4),
                      (int)local_1c._8_8_,SUB84(local_1c._8_8_,4),
                      (self->_additionalContentRect).origin,(self->_additionalContentRect).size);
  }
  else {
    fVar1 = *(float *)(PTR_00336078 + 4);
    (__return_storage_ptr__->origin).x = *(float *)PTR_00336078;
    (__return_storage_ptr__->origin).y = fVar1;
    (__return_storage_ptr__->size).width = *(float *)(puVar2 + 8);
    (__return_storage_ptr__->size).height = *(float *)(puVar2 + 0xc);
  }
  return __return_storage_ptr__;
}

*/
- (NSRect)contentBoundingRect
{
    NSRect rect = [super contentBoundingRect];
    if (NSIsEmptyRect(rect)) {
        return NSZeroRect;
    }
    return NSUnionRect(rect, _additionalContentRect);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000fd4f @ 0000fd4f, 154 bytes * /

void FUN_0000fd4f(HSEditorCardView *self,SEL _cmd,NSRect setAdditionalContentBoundingRect)

{
  char cVar1;
  
  cVar1 = _NSEqualRects(setAdditionalContentBoundingRect.origin,
                        setAdditionalContentBoundingRect.size,(self->_additionalContentRect).origin,
                        (self->_additionalContentRect).size);
  if (cVar1 == '\0') {
    (self->_additionalContentRect).origin.x = setAdditionalContentBoundingRect.origin.x;
    (self->_additionalContentRect).origin.y = setAdditionalContentBoundingRect.origin.y;
    (self->_additionalContentRect).size.width = setAdditionalContentBoundingRect.size.width;
    (self->_additionalContentRect).size.height = setAdditionalContentBoundingRect.size.height;
    _objc_msgSend(self,sel_HSEditorCardView_reflectObjectsDidRelayout);
  }
  return;
}

*/
- (void)setAdditionalContentBoundingRect:(NSRect)aRect
{
    if (!NSEqualRects(aRect, _additionalContentRect)) {
        _additionalContentRect = aRect;
        [self HSEditorCardView_reflectObjectsDidRelayout];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0000364e @ 0000364e, 20 bytes * /

ulonglong FUN_0000364e(HSEditorCardView *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_cardOffset).width;
  uVar1._4_4_ = (self->_cardOffset).height;
  return uVar1;
}

*/
- (void)activate
{
    [self reflectCardObjectsHiddenStateOfObjectsInEnumerator:[[self card] hyperEnumerator] invalidate:YES];
    [super activate];
}

- (void)didAddNewObject
{
    [[[_editObjectDialogContext document] editorWindowController] didAddNewObject];
}

- (void)registerObservingUserObjectAttributesChange
{
    int uVar1;
    id self_00;

    [super registerObservingUserObjectAttributesChange];
    self_00 = [self card];
    [self_00 addObserver:self selector:@selector(cardChildrenGeometryChanged:) ofChanges:2 ofChildrenAttribute:@protocol(HSGeometryAttribute) withPriority:-0.75];
    uVar1 = HSActualDidAttributeChanges;
    [self_00 addObserver:self selector:@selector(cardDidChangeChildren:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75];
    [self_00 addObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardObjectGroupAttribute) withPriority:-0.75];
}

- (void)unregisterObservingUserObjectAttributesChange
{
    int uVar1;
    id self_00;

    [super unregisterObservingUserObjectAttributesChange];
    self_00 = [self card];
    [self_00 removeObserver:self selector:@selector(cardChildrenGeometryChanged:) ofChanges:2 ofChildrenAttribute:@protocol(HSGeometryAttribute)];
    uVar1 = HSActualDidAttributeChanges;
    [self_00 removeObserver:self selector:@selector(cardDidChangeChildren:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [self_00 removeObserver:self selector:@selector(onionSkinImageChanged:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardObjectGroupAttribute)];
}

- (void)unregisterObservingCardStackAttributesChanges
{
    int uVar1;
    id self_00;
    id pvVar2_2;

    pvVar2_2 = [[self card] stack];
    self_00 = [pvVar2_2 attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [self_00 removeObserver:self selector:@selector(cardStackDidChangeGridAttribute:) ofChanges:uVar1 ofAttribute:@protocol(HSLayoutGridVisibilityAttribute)];
    [self_00 removeObserver:self selector:@selector(stackDidAddOrRemoveCard:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [self_00 removeObserver:self selector:@selector(cardStackDidChangeCardObjectsHiddenState:) ofChanges:uVar1 ofAttribute:@protocol(HSStackCardObjectsVisibilityAttribute)];
    [[pvVar2_2 queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:self selector:@selector(cardStackDidChangeChildren:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)registerObservingCardStackAttributesChanges
{
    int uVar1;
    id self_00;
    id pvVar2_2;

    pvVar2_2 = [[self card] stack];
    self_00 = [pvVar2_2 attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [self_00 addObserver:self selector:@selector(cardStackDidChangeGridAttribute:) ofChanges:uVar1 ofAttribute:@protocol(HSLayoutGridVisibilityAttribute) withPriority:-0.75];
    [self_00 addObserver:self selector:@selector(stackDidAddOrRemoveCard:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75];
    [self_00 addObserver:self selector:@selector(cardStackDidChangeCardObjectsHiddenState:) ofChanges:uVar1 ofAttribute:@protocol(HSStackCardObjectsVisibilityAttribute) withPriority:-0.75];
    [[pvVar2_2 queryHyperInterface:@protocol(HSNodeContainer)] addObserver:self selector:@selector(cardStackDidChangeChildren:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00010378 @ 00010378, 523 bytes * /

void FUN_00010378(HSEditorCardView *self,SEL _cmd)

{
  id self_00;
  HSEditorCardView *local_14;
  undefined *local_10;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_removeObserver_,self);
  _objc_msgSend(self->_liveResizeRecacheTimer,sel_invalidate);
  _objc_msgSend(self->_liveResizeRecacheTimer,sel_release);
  self->_liveResizeRecacheTimer = (id)0x0;
  _objc_msgSend(self->_poofPointsQueue,sel_release);
  _objc_msgSend(self->_gridSettings,sel_release);
  _objc_msgSend(self->_guidelinesSettings,sel_release);
  _objc_msgSend(self->_editObjectDialogContext,sel_release);
  _objc_msgSend(self->_backgroundColor,sel_release);
  _objc_msgSend(*(id *)((int)&self->_nextOnionSkinUserObject + 1),sel_release);
  _objc_msgSend(self->_dragHelper,sel_invalidateDragHost);
  _objc_msgSend(self->_dragHelper,sel_release);
  _objc_msgSend(self,sel_unregisterAttributesChangesForOnionSkinUserObject_,
                *(undefined4 *)((int)&self->_lastActiveWindow + 1));
  _objc_msgSend(*(id *)((int)&self->_lastActiveWindow + 1),sel_release);
  _objc_msgSend(self,sel_unregisterAttributesChangesForOnionSkinUserObject_,
                *(undefined4 *)((int)&self->_previousOnionSkinUserObject + 1));
  _objc_msgSend(*(id *)((int)&self->_previousOnionSkinUserObject + 1),sel_release);
  _objc_msgSend(self->_attributesForSelectedTextObject,sel_release);
  _objc_msgSend(self,sel_cancelAppliedLayoutGuidingRulesClearing);
  _objc_msgSend(self->_newActionDropHelpPane,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSToolView_0034db70;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_liveResizeRecacheTimer invalidate];
    [_liveResizeRecacheTimer release];
    _liveResizeRecacheTimer = nil;
    [_poofPointsQueue release];
    [_gridSettings release];
    [_guidelinesSettings release];
    [_editObjectDialogContext release];
    [_backgroundColor release];
    [_cardObjects release];
    [_dragHelper invalidateDragHost];
    [_dragHelper release];
    [self unregisterAttributesChangesForOnionSkinUserObject:_nextOnionSkinUserObject];
    [_nextOnionSkinUserObject release];
    [self unregisterAttributesChangesForOnionSkinUserObject:_previousOnionSkinUserObject];
    [_previousOnionSkinUserObject release];
    [_attributesForSelectedTextObject release];
    [self cancelAppliedLayoutGuidingRulesClearing];
    [_newActionDropHelpPane release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSScrollView *self_00;

    if (1038.0 < NSAppKitVersionNumber || NSAppKitVersionNumber == 1038.0) {
        [self setAcceptsTouchEvents:1];
    }
    [self dragHelper];
    self_00 = [self enclosingScrollView];
    [self_00 setHasHorizontalRuler:NO];
    [self_00 setHasVerticalRuler:NO];
    [self_00 setRulersVisible:NO];
    [self setObservesAndNotifiesOfSuperviewBoundsChanges:YES];
}

- (id)dragHelper
{
    HSEditorCardViewDragHelper *pHVar1;

    pHVar1 = _dragHelper;
    if (pHVar1 == nil) {
        pHVar1 = [[HSEditorCardViewDragHelper alloc] initWithDragHost:self];
        _dragHelper = pHVar1;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000106af @ 000106af, 274 bytes * /

id FUN_000106af(HSEditorCardView *self,SEL _cmd,NSRect initWithFrame)

{
  id pvVar1;
  id pvVar2;
  HSEditorCardView *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSToolView_0034db70;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x1bc) = 0;
    *(byte *)((int)pvVar1 + 0x214) = *(byte *)((int)pvVar1 + 0x214) | 4;
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,
                  sel_hideAuxiliaryIconsDidChange_,*(undefined4 *)PTR_00336038,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,sel_onionSkinModeDidChange_,
                  &cfstr_HSOnionSkinModeDidChangeNotification,0);
    *(undefined1 *)((int)pvVar1 + 0x238) = 1;
    *(undefined1 *)((int)pvVar1 + 0x245) = 0;
  }
  return pvVar1;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        _zoomMode = 0;
        _isObjectsLayoutReflected = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAuxiliaryIconsDidChange:) name:HSHideAuxiliaryIconsDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onionSkinModeDidChange:) name:@"HSOnionSkinModeDidChangeNotification" object:nil];
        _needOpenHelpPane = YES;
        _ignoreNextMouseDown = NO;
    }
    return self;
}

- (void)draggableAttributeDidChange:(id)aChange
{
    id object = [aChange object];
    id snapping = [object queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
    id uid = [snapping dropOffTargetUID];
    id uidAccess = [[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    id temporaryTarget = [snapping temporaryDropOffTarget];
    id target = [[uidAccess childInTreeWithUID:uid] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];

    [[[self card] undoManager] disableUndoRegistration];
    if ([object isDraggable] && temporaryTarget != nil) {
        [[self card] addHyperChild:temporaryTarget];
        [snapping setTemporaryDropOffTarget:nil];
        [self selectObject:object];
    } else if (![object isDraggable] && target != nil) {
        [snapping setTemporaryDropOffTarget:target];
        [[target queryHyperInterface:@protocol(HSNodeChild)] removeFromHyperParent];
    }
    [[[self card] undoManager] enableUndoRegistration];
}

@end

