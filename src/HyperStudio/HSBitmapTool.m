#import "HSBitmapTool.h"

@implementation HSBitmapTool

/* i386 ivar offsets: _currentEditableImageAttributes=0x28, _toolSelectionCanvasLayer=0x2c */

+ (Class)toolCanvasLayerClass
{
    return [HSBitmapToolCanvasLayer class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c68a1 @ 000c68a1, 708 bytes * /

CGAffineTransform *
FUN_000c68a1(CGAffineTransform *__return_storage_ptr__,HSBitmapTool *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  CGAffineTransform *pCVar3;
  float extraout_EDX;
  float fVar4;
  float fVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  float local_54;
  float local_50;
  float local_48;
  float local_44;
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
  float local_14;
  float local_10;
  
  _objc_msgSend_stret(&local_34,self->_currentEditableImageAttributes,sel_imageRect);
  pvVar2 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(&local_24,pvVar2,sel_userSpaceToViewSpaceCGAffineTransform);
  local_38 = local_24;
  local_3c = local_20;
  uVar7 = 0;
  uVar6 = 0;
  fVar1 = local_30 + local_30 + local_28;
  fVar4 = -local_18;
  fVar5 = -local_1c;
  local_54 = local_18 * fVar1 + local_10;
  local_50 = fVar1 * local_1c + local_14;
  pvVar2 = _objc_msgSend(self->_currentEditableImageAttributes,
                         sel_queryImageWithRequiredProtocols_optionalProtocols_,0,0);
  pCVar3 = (CGAffineTransform *)0x0;
  local_48 = fVar4;
  local_44 = fVar5;
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar2,sel_imageSize,uVar6,uVar7);
    if (((float)pvVar2 != 0.0) || (NAN((float)pvVar2))) {
      local_2c = local_2c / (float)pvVar2;
    }
    else {
      local_2c = 1.0;
    }
    if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
      local_28 = local_28 / extraout_EDX;
    }
    else {
      local_28 = 1.0;
    }
    local_38 = local_2c * local_24 + local_1c * -0.0;
    local_3c = local_2c * local_20 + local_18 * -0.0;
    local_34 = local_34 - *(float *)PTR_0033608c * local_2c;
    local_44 = local_24 * 0.0 + local_28 * fVar5;
    local_48 = local_20 * 0.0 + local_28 * fVar4;
    local_30 = local_30 - *(float *)(PTR_0033608c + 4) * local_28;
    local_50 = local_50 + fVar5 * local_30 + local_34 * local_24;
    local_54 = local_54 + local_30 * fVar4 + local_34 * local_20;
    pCVar3 = (CGAffineTransform *)PTR_0033608c;
  }
  __return_storage_ptr__->a = local_38;
  __return_storage_ptr__->b = local_3c;
  __return_storage_ptr__->c = local_44;
  __return_storage_ptr__->d = local_48;
  __return_storage_ptr__->tx = local_50;
  __return_storage_ptr__->ty = local_54;
  return pCVar3;
}

*/
- (CGAffineTransform)imageToViewTransform
{
    NSRect imageRect = [_currentEditableImageAttributes imageRect];
    CGAffineTransform viewTransform = [[self view] userSpaceToViewSpaceCGAffineTransform];
    CGFloat flipOffset = imageRect.origin.y + imageRect.origin.y + imageRect.size.height;
    CGAffineTransform result;
    result.a = viewTransform.a;
    result.b = viewTransform.b;
    result.c = -viewTransform.c;
    result.d = -viewTransform.d;
    result.tx = flipOffset * viewTransform.c + viewTransform.tx;
    result.ty = viewTransform.d * flipOffset + viewTransform.ty;
    id image = [_currentEditableImageAttributes queryImageWithRequiredProtocols:nil optionalProtocols:nil];
    if (image != nil) {
        NSSize imageSize = [image imageSize];
        CGFloat scaleX = imageSize.width != 0.0 ? imageRect.size.width / imageSize.width : 1.0;
        CGFloat scaleY = imageSize.height != 0.0 ? imageRect.size.height / imageSize.height : 1.0;
        result.a = scaleX * viewTransform.a + viewTransform.c * -0.0;
        result.b = scaleX * viewTransform.b + viewTransform.d * -0.0;
        imageRect.origin.x = imageRect.origin.x - CGPointZero.x * scaleX;
        result.c = viewTransform.a * 0.0 + scaleY * -viewTransform.c;
        result.d = viewTransform.b * 0.0 + scaleY * -viewTransform.d;
        imageRect.origin.y = imageRect.origin.y - CGPointZero.y * scaleY;
        result.tx = result.tx + -viewTransform.c * imageRect.origin.y + imageRect.origin.x * viewTransform.a;
        result.ty = result.ty + imageRect.origin.y * -viewTransform.d + imageRect.origin.x * viewTransform.b;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c643b @ 000c643b, 897 bytes * /

id FUN_000c643b(HSBitmapTool *self,SEL _cmd,id tool,id willSetUndoActionName)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(self,sel_bitmapTool);
  if (pvVar1 == tool) {
    pvVar1 = _objc_msgSend(self,sel_view);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    if (pvVar1 != (id)0x0) {
      pcVar5 = &cfstr_Pick_Color___Stroke;
      pvVar2 = _objc_msgSend(willSetUndoActionName,sel_isEqualToString_,&cfstr_Pick_Color___Stroke);
      if ((char)pvVar2 == '\0') {
        pcVar5 = &cfstr_Pick_Alternate_Color___Stroke;
        pvVar2 = _objc_msgSend(willSetUndoActionName,sel_isEqualToString_,
                               &cfstr_Pick_Alternate_Color___Stroke);
        if ((char)pvVar2 == '\0') {
          pcVar5 = &cfstr_Draw_Selection;
          pvVar2 = _objc_msgSend(willSetUndoActionName,sel_isEqualToString_,&cfstr_Draw_Selection);
          if ((char)pvVar2 == '\0') {
            pcVar5 = &cfstr_Create_Shape_Selection;
            pvVar2 = _objc_msgSend(willSetUndoActionName,sel_isEqualToString_,
                                   &cfstr_Create_Shape_Selection);
            pcVar4 = willSetUndoActionName;
            if ((char)pvVar2 == '\0') {
              pcVar5 = &cfstr_Create_All_Area_Shape_Selection;
              pvVar2 = _objc_msgSend(willSetUndoActionName,sel_isEqualToString_,
                                     &cfstr_Create_All_Area_Shape_Selection);
              if ((char)pvVar2 == '\0') {
                pcVar5 = &cfstr_Paint;
                pvVar2 = _objc_msgSend(willSetUndoActionName,sel_isEqualToString_,&cfstr_Paint);
                if ((char)pvVar2 != '\0') {
                  pvVar2 = _objc_msgSend(self,sel_toolIdentifier,pcVar5);
                  pcVar5 = *(cfstringStruct **)PTR_PTR_00336218;
                  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
                  if ((char)pvVar3 == '\0') {
                    pcVar5 = *(cfstringStruct **)PTR_PTR_00336300;
                    pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
                    if ((char)pvVar3 == '\0') {
                      pcVar5 = *(cfstringStruct **)PTR_PTR_00336254;
                      pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
                      if ((char)pvVar2 != '\0') {
                        pcVar4 = &cfstr_Erase;
                      }
                    }
                    else {
                      pcVar4 = &cfstr_Spray;
                    }
                  }
                  else {
                    pcVar4 = &cfstr_Paint;
                  }
                }
              }
              else {
                pvVar2 = _objc_msgSend(self,sel_toolIdentifier,pcVar5);
                pcVar5 = *(cfstringStruct **)PTR_PTR_003362c0;
                pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
                if ((char)pvVar3 == '\0') {
                  pcVar5 = *(cfstringStruct **)PTR_PTR_00336234;
                  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
                  if ((char)pvVar2 != '\0') {
                    pcVar4 = &cfstr_Create_All_Area_Elliptical_Selection;
                  }
                }
                else {
                  pcVar4 = &cfstr_Create_All_Area_Rectangular_Selection;
                }
              }
            }
            else {
              pvVar2 = _objc_msgSend(self,sel_toolIdentifier,pcVar5);
              pcVar5 = *(cfstringStruct **)PTR_PTR_003362c0;
              pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
              if ((char)pvVar3 == '\0') {
                pcVar5 = *(cfstringStruct **)PTR_PTR_00336234;
                pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar5);
                if ((char)pvVar2 != '\0') {
                  pcVar4 = &cfstr_Create_Elliptical_Selection;
                }
              }
              else {
                pcVar4 = &cfstr_Create_Rectangular_Selection;
              }
            }
          }
          else {
            pcVar4 = &cfstr_Fill;
          }
        }
        else {
          pcVar4 = &cfstr_Alternate_Stroke;
        }
      }
      else {
        pcVar4 = &cfstr_Stroke;
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_isMultipleActionsNameEnabled,pcVar5);
      _objc_msgSend(pvVar1,sel_setMultipleActionsNameEnabled_,0);
      pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pcVar5 = &cfstr_UndoManager;
      pcVar6 = &cfstr_empty;
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                             &cfstr_UndoManager);
      _objc_msgSend(pvVar1,sel_NSE_setActionNameIfNeeded_,pvVar3);
      if ((char)pvVar2 != '\0') {
        _objc_msgSend(pvVar1,sel_setMultipleActionsNameEnabled_,1,pcVar6,pcVar5);
      }
    }
  }
  return (id)0x0;
}

*/
- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    if ([self bitmapTool] == aTool) {
        id undoManager = [[self view] undoManager];
        if (undoManager != nil) {
            NSString *key = aName;
            if ([aName isEqualToString:@"Pick Color & Stroke"]) {
                key = @"Stroke";
            } else if ([aName isEqualToString:@"Pick Alternate Color & Stroke"]) {
                key = @"Alternate Stroke";
            } else if ([aName isEqualToString:@"Draw Selection"]) {
                key = @"Fill";
            } else if ([aName isEqualToString:@"Create Shape Selection"]) {
                NSString *identifier = [self toolIdentifier];
                if ([identifier isEqualToString:@"HSRectSelectionTool"]) {
                    key = @"Create Rectangular Selection";
                } else if ([identifier isEqualToString:@"HSCircularSelectionTool"]) {
                    key = @"Create Elliptical Selection";
                }
            } else if ([aName isEqualToString:@"Create All Area Shape Selection"]) {
                NSString *identifier = [self toolIdentifier];
                if ([identifier isEqualToString:@"HSRectSelectionTool"]) {
                    key = @"Create All Area Rectangular Selection";
                } else if ([identifier isEqualToString:@"HSCircularSelectionTool"]) {
                    key = @"Create All Area Elliptical Selection";
                }
            } else if ([aName isEqualToString:@"Paint"]) {
                NSString *identifier = [self toolIdentifier];
                if ([identifier isEqualToString:@"HSBrushTool"]) {
                    key = @"Paint";
                } else if ([identifier isEqualToString:@"HSSprayCanTool"]) {
                    key = @"Spray";
                } else if ([identifier isEqualToString:@"HSEraserTool"]) {
                    key = @"Erase";
                }
            }
            BOOL multipleActionsNameEnabled = [undoManager isMultipleActionsNameEnabled];
            [undoManager setMultipleActionsNameEnabled:NO];
            [undoManager NSE_setActionNameIfNeeded:[[NSBundle mainBundle] localizedStringForKey:key value:@"" table:@"UndoManager"]];
            if (multipleActionsNameEnabled) {
                [undoManager setMultipleActionsNameEnabled:YES];
            }
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c639f @ 000c639f, 156 bytes * /

id FUN_000c639f(HSBitmapTool *self,SEL _cmd,id undoManagerForTool,id category)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(self,sel_bitmapTool);
  if ((pvVar1 == undoManagerForTool) &&
     (pvVar1 = _objc_msgSend(category,sel_isEqualToString_,&cfstr_BTToolWorkImageUndoCategory),
     (char)pvVar1 == '\0')) {
    pcVar2 = &cfstr_BTStrokeColorUndoCategory;
    pvVar1 = _objc_msgSend(category,sel_isEqualToString_,&cfstr_BTStrokeColorUndoCategory);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_view,pcVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    if ([self bitmapTool] == aTool && ![aCategory isEqualToString:@"BTToolWorkImageUndoCategory"] && ![aCategory isEqualToString:@"BTStrokeColorUndoCategory"]) {
        return [[self view] undoManager];
    }
    return nil;
}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{

}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c62f4 @ 000c62f4, 171 bytes * /

void FUN_000c62f4(HSBitmapTool *self,SEL _cmd,id tool,
                 NSRect didReplaceImageWithEffectiveChangeInRect)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_bitmapTool);
  if (pvVar1 == tool) {
    pvVar1 = self->_currentEditableImageAttributes;
    pvVar2 = _objc_msgSend(tool,sel_workImage);
    _objc_msgSend(pvVar1,sel_beginEditImage_inRect_,pvVar2,
                  didReplaceImageWithEffectiveChangeInRect.origin,
                  didReplaceImageWithEffectiveChangeInRect.size);
    _objc_msgSend(self,sel_HSBitmapTool_tool_didChangeImageInRect_,tool,
                  didReplaceImageWithEffectiveChangeInRect.origin,
                  didReplaceImageWithEffectiveChangeInRect.size);
  }
  return;
}

*/
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{
    if ([self bitmapTool] == aTool) {
        [_currentEditableImageAttributes beginEditImage:[aTool workImage] inRect:aRect];
        [self HSBitmapTool_tool:aTool didChangeImageInRect:aRect];
    }
}

- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{

}

- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect
{
    if ([self bitmapTool] == aTool) {
        [self HSBitmapTool_tool:aTool didChangeImageInRect:aRect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c621f @ 000c621f, 116 bytes * /

void FUN_000c621f(HSBitmapTool *self,SEL _cmd,id tool,NSRect willChangeImageInRect)

{
  id self_00;
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_bitmapTool);
  if (pvVar1 == tool) {
    self_00 = self->_currentEditableImageAttributes;
    pvVar1 = _objc_msgSend(pvVar1,sel_workImage);
    _objc_msgSend(self_00,sel_beginEditImage_inRect_,pvVar1,willChangeImageInRect.origin,
                  willChangeImageInRect.size);
  }
  return;
}

*/
- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect
{
    if ([self bitmapTool] == aTool) {
        [_currentEditableImageAttributes beginEditImage:[[self bitmapTool] workImage] inRect:aRect];
    }
}

- (void)toolDidEndChangingImageContinuously:(id)aContinuously
{
    [_currentEditableImageAttributes endEditImageContinuously];
    [[_currentEditableImageAttributes attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSImageAttribute)];
}

- (void)toolWillBeginChangingImageContinuously:(id)aContinuously
{
    [[_currentEditableImageAttributes attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSImageAttribute)];
    [_currentEditableImageAttributes beginEditImageContinuously];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c6b65 @ 000c6b65, 128 bytes * /

BOOL FUN_000c6b65(HSBitmapTool *self,SEL _cmd,id tool,id didFinalizeStage,id withEvent,id nextStage)

{
  id pvVar1;
  HSBitmapTool *local_1c;
  undefined *local_18;
  
  if ((*(id *)(self->super_HSBaseBitmapTool + 0x14) == tool) && (nextStage == (id)0x0)) {
    _objc_msgSend(self,sel_notifyManagerAtomOperationPerformedWithResult_,1);
  }
  local_1c = self;
  local_18 = PTR_s_HSBaseBitmapTool_0034fc70;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_tool_didFinalizeStage_withEvent_nextStage_,tool,
                              didFinalizeStage,withEvent,nextStage);
  return (BOOL)pvVar1;
}

*/
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2
{
    if ([self bitmapTool] == aTool && aStage2 == nil) {
        [self notifyManagerAtomOperationPerformedWithResult:YES];
    }
    return [super tool:aTool didFinalizeStage:aStage withEvent:aEvent nextStage:aStage2];
}

- (void)HSBitmapTool_tool:(id)aTool didChangeImageInRect:(NSRect)aRect
{
    [_currentEditableImageAttributes endEditImage];
}

- (void)reactivate
{
    if (_currentEditableImageAttributes != nil) {
        [self deactivateBitmapTool];
        [self activateBitmapTool];
    }
}

- (void)deactivateBitmapTool
{
    [[_currentEditableImageAttributes attributeObservingController] removeObserver:self selector:@selector(HSBitmapTool_userObjectDidChangeImage:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSImageAttribute)];
    [[self bitmapTool] deactivate];
    [[self bitmapTool] setWorkImage:nil];
    [_currentEditableImageAttributes release];
    _currentEditableImageAttributes = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c6be5 @ 000c6be5, 294 bytes * /

BOOL FUN_000c6be5(HSBitmapTool *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  HSBitmapTool *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self,sel_view);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_userObject);
    puVar2 = &DAT_0036bbdc;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036bbdc);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_currentEditableImageAttributes = pvVar1;
    if ((pvVar1 != (id)0x0) &&
       (pvVar1 = _objc_msgSend(self,sel_HSBitmapTool_setWorkImage,puVar2), (char)pvVar1 != '\0')) {
      local_14 = self;
      local_10 = PTR_s_HSBaseBitmapTool_0034fc70;
      pvVar1 = _objc_msgSendSuper(&local_14,sel_activateBitmapTool);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self->_currentEditableImageAttributes,
                               sel_attributeObservingController,puVar2);
        _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                      sel_HSBitmapTool_userObjectDidChangeImage_,*(undefined4 *)PTR_0033601c,
                      &DAT_0036bb8c,0xbe800000);
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)activateBitmapTool
{
    if ([self view] != nil) {
        _currentEditableImageAttributes = [[[[self view] userObject] queryHyperInterface:@protocol(HSEditableImageAttributes)] retain];
        if (_currentEditableImageAttributes != nil && [self HSBitmapTool_setWorkImage]) {
            if ([super activateBitmapTool]) {
                [[_currentEditableImageAttributes attributeObservingController] addObserver:self selector:@selector(HSBitmapTool_userObjectDidChangeImage:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSImageAttribute) withPriority:-0.25];
                return YES;
            }
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c6d0b @ 000c6d0b, 255 bytes * /

void FUN_000c6d0b(HSBitmapTool *self,SEL _cmd,BOOL didActivateExplicitly)

{
  id pvVar1;
  id self_00;
  HSBitmapTool *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSBaseBitmapTool_0034fc70;
  _objc_msgSendSuper(&local_1c,sel_didActivateExplicitly_,(int)didActivateExplicitly);
  if (self->_toolSelectionCanvasLayer == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSBitmapToolSelectionCanvasLayer,sel_new);
    self->_toolSelectionCanvasLayer = pvVar1;
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_view);
  pvVar1 = _objc_msgSend(pvVar1,sel_rootCanvasLayer);
  self_00 = _objc_msgSend(pvVar1,sel_bitmapToolsSelectionCanvasLayer);
  _objc_msgSend(self_00,sel_addSublayer_,self->_toolSelectionCanvasLayer);
  _objc_msgSend(self->_toolSelectionCanvasLayer,sel_setTool_,self);
  _objc_msgSend(pvVar1,sel_enableSublayerForIdentifier_,*(undefined4 *)PTR_PTR_0033648c);
  return;
}

*/
- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [super didActivateExplicitly:aExplicitly];
    if (_toolSelectionCanvasLayer == nil) {
        _toolSelectionCanvasLayer = [HSBitmapToolSelectionCanvasLayer new];
        if (_toolSelectionCanvasLayer == nil) {
            return;
        }
    }
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer bitmapToolsSelectionCanvasLayer] addSublayer:_toolSelectionCanvasLayer];
    [_toolSelectionCanvasLayer setTool:self];
    [rootLayer enableSublayerForIdentifier:@"HSBitmapToolsSelectionCanvasLayer"];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1;

    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    pvVar1 = [[self view] undoManager];
    if (pvVar1 != nil) {
        [[self bitmapTool] removeAllUndoActionsFromManager:pvVar1];
    }
    [_toolSelectionCanvasLayer setTool:nil];
    pvVar1 = [_toolSelectionCanvasLayer parentLayer];
    if (pvVar1 != nil) {
        pvVar1 = [[[self view] rootCanvasLayer] bitmapToolsSelectionCanvasLayer];
        [pvVar1 removeSublayer:_toolSelectionCanvasLayer];
    }
}

- (void)HSBitmapTool_userObjectDidChangeImage:(id)aImage
{
    [self HSBitmapTool_setWorkImage];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c5f38 @ 000c5f38, 188 bytes * /

BOOL FUN_000c5f38(HSBitmapTool *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = _objc_msgSend(self,sel_bitmapTool);
  pvVar3 = self->_currentEditableImageAttributes;
  pvVar1 = _objc_msgSend(self_00,sel_optionalImageProtocols);
  pvVar2 = _objc_msgSend(self_00,sel_requiredImageProtocols);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryImageWithRequiredProtocols_optionalProtocols_,pvVar2,pvVar1
                        );
  if (pvVar3 == (id)0x0) {
    pvVar1 = (id)0x0;
    pvVar3 = _objc_msgSend(self->_currentEditableImageAttributes,
                           sel_queryImageWithRequiredProtocols_optionalProtocols_,0,0);
  }
  pvVar3 = _objc_msgSend(self_00,sel_setWorkImage_,pvVar3,pvVar1);
  return (BOOL)pvVar3;
}

*/
- (BOOL)HSBitmapTool_setWorkImage
{
    id tool = [self bitmapTool];
    id image = [_currentEditableImageAttributes queryImageWithRequiredProtocols:[tool requiredImageProtocols] optionalProtocols:[tool optionalImageProtocols]];
    if (image == nil) {
        image = [_currentEditableImageAttributes queryImageWithRequiredProtocols:nil optionalProtocols:nil];
    }
    return [tool setWorkImage:image];
}

- (id)currentEditableImageAttributes
{
    return _currentEditableImageAttributes;
}

- (void)dealloc
{
    [[_currentEditableImageAttributes attributeObservingController] removeObserver:self selector:@selector(HSBitmapTool_userObjectDidChangeImage:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSImageAttribute)];
    [_currentEditableImageAttributes release];
    [_toolSelectionCanvasLayer release];
    [super dealloc];
}

@end

