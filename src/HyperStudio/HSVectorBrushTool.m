#import "HSVectorBrushTool.h"

@implementation HSVectorBrushTool

/* i386 ivar offsets: _touchStorage=0x28, _contextImage=0x2c, _brushBounds=0x30, _prototypeObject=0x40 */

+ (Class)settingsSerializationClass
{
    return [BTBrushToolSettingsSerialization class];
}

+ (id)layerIdentifiersWithRootLayer:(id)aLayer
{
    return [aLayer vectorToolsIdentifiers];
}

+ (id)toolsCanvasLayerWithRootLayer:(id)aLayer
{
    return [aLayer vectorToolsCanvasLayer];
}

+ (Class)toolCanvasLayerClass
{
    return [HSVectorBrushToolCanvasLayer class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014a427 @ 0014a427, 1079 bytes * /

/* WARNING: Heritage AFTER dead removal. Example location: s0xffffff2c : 0x0014a778 * /
/* WARNING: Restarted to delay deadcode elimination for space: stack * /

void FUN_0014a427(HSVectorBrushTool *self,SEL _cmd,id touchStorageDidAddTouch)

{
  id pvVar1;
  id pvVar2;
  int *piVar3;
  int aiStack_e4 [3];
  float *local_d8;
  int local_d4;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  undefined4 local_4c;
  undefined4 local_48;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  undefined1 local_34 [16];
  undefined8 local_24;
  undefined8 local_1c;
  
  if (self->_touchStorage == touchStorageDidAddTouch) {
    pvVar1 = _objc_msgSend(self,sel_bitmapTool);
    _objc_msgSend(pvVar1,sel_size);
    _objc_msgSend(pvVar1,sel_shadowOffset);
    _objc_msgSend_fpret(pvVar1,sel_rotationAngle);
    pvVar2 = _objc_msgSend(pvVar1,sel_shadowMask);
    if (pvVar2 == (id)0x0) {
      _objc_msgSend_fpret(pvVar1,sel_shadowBlurRadius);
    }
    pvVar2 = _objc_msgSend(self->_touchStorage,sel_numberOfTouches);
    _objc_msgSend_stret(&local_44,self->_touchStorage,
                        sel_boundingRectOfTouchAtIndex_forToolSize_rotationAngle_shadowOffset_shadowBlurRadius_
                       );
    piVar3 = (int *)&stack0xffffff30;
    if (pvVar2 == (id)0x1) {
      (self->_brushBounds).origin.x = local_44;
      (self->_brushBounds).origin.y = fStack_40;
      (self->_brushBounds).size.width = local_3c;
      (self->_brushBounds).size.height = fStack_38;
      local_4c = *(undefined4 *)PTR_0033608c;
      local_48 = *(undefined4 *)(PTR_0033608c + 4);
      _objc_msgSend(self->_touchStorage,
                    sel_position_sizeDeviation_rotationAngleDeviation_opacityDeviation_alternateColor_colorHSVADeviation_colorNativeDeviation_shadowColorHSVADeviation_shadowColorNativeDeviation_forTouchAtIndex_
                   );
      _objc_msgSend(pvVar1,sel_setUserPatternPhase_);
    }
    else {
      _CGRectUnion();
      (self->_brushBounds).origin.x = local_5c;
      (self->_brushBounds).origin.y = local_58;
      (self->_brushBounds).size.width = local_54;
      (self->_brushBounds).size.height = local_50;
      local_d8 = (float *)0x14a77d;
      _objc_msgSend_stret(local_34,self->_touchStorage,
                          sel_boundingRectOfTouchAtIndex_forToolSize_rotationAngle_shadowOffset_shadowBlurRadius_
                         );
      local_d8 = &local_6c;
      aiStack_e4[2] = 0x14a7b7;
      _CGRectUnion();
      piVar3 = aiStack_e4 + 2;
      local_44 = local_6c;
      fStack_40 = local_68;
      local_3c = local_64;
      fStack_38 = local_60;
    }
    piVar3[1] = (int)sel_view;
    *piVar3 = (int)self;
    piVar3[-1] = 0x14a7f7;
    pvVar1 = _objc_msgSend((id)*piVar3,(SEL)piVar3[1]);
    *(ulonglong *)(piVar3 + 5) = CONCAT44(fStack_38,local_3c);
    *(ulonglong *)(piVar3 + 3) = CONCAT44(fStack_40,local_44);
    piVar3[2] = (int)sel_convertImageRectToViewRect_;
    piVar3[1] = (int)self;
    *piVar3 = (int)&local_24;
    piVar3[-1] = 0x14a828;
    _objc_msgSend_stret((void *)*piVar3,(id)piVar3[1],(SEL)piVar3[2]);
    *(undefined8 *)(piVar3 + 3) = local_1c;
    *(undefined8 *)(piVar3 + 1) = local_24;
    *piVar3 = (int)sel_setNeedsDisplayOpenGLSurfaceInRect_;
    piVar3[-1] = (int)pvVar1;
    piVar3[-2] = 0x14a853;
    _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
  }
  return;
}

*/
- (void)touchStorageDidAddTouch:(id)aTouch
{
    if (_touchStorage != aTouch) {
        return;
    }
    BTBrushTool *bitmapTool = (BTBrushTool *)[self bitmapTool];
    NSSize toolSize = [bitmapTool size];
    NSSize shadowOffset = [bitmapTool shadowOffset];
    float rotationAngle = (float)[bitmapTool rotationAngle];
    float shadowBlurRadius = ([bitmapTool shadowMask] == nil) ? (float)[bitmapTool shadowBlurRadius] : NAN;
    NSUInteger count = [_touchStorage numberOfTouches];
    CGRect dirtyRect = [_touchStorage boundingRectOfTouchAtIndex:count - 1 forToolSize:toolSize rotationAngle:rotationAngle shadowOffset:shadowOffset shadowBlurRadius:shadowBlurRadius];
    if (count == 1) {
        _brushBounds = dirtyRect;
        CGPoint position = CGPointZero;
        [_touchStorage position:&position sizeDeviation:NULL rotationAngleDeviation:NULL opacityDeviation:NULL alternateColor:NULL colorHSVADeviation:NULL colorNativeDeviation:NULL shadowColorHSVADeviation:NULL shadowColorNativeDeviation:NULL forTouchAtIndex:0];
        [bitmapTool setUserPatternPhase:NSMakeSize(position.x, position.y)];
    }
    else {
        _brushBounds = CGRectUnion(_brushBounds, dirtyRect);
        CGRect previousRect = [_touchStorage boundingRectOfTouchAtIndex:count - 2 forToolSize:toolSize rotationAngle:rotationAngle shadowOffset:shadowOffset shadowBlurRadius:shadowBlurRadius];
        dirtyRect = CGRectUnion(dirtyRect, previousRect);
    }
    id view = [self view];
    [view setNeedsDisplayOpenGLSurfaceInRect:[self convertImageRectToViewRect:NSRectFromCGRect(dirtyRect)]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014a85e @ 0014a85e, 1617 bytes * /

BOOL FUN_0014a85e(HSVectorBrushTool *self,SEL _cmd,id tool,id didFinalizeStage,id withEvent,
                 id nextStage)

{
  float fVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  int *piVar5;
  longdouble lVar6;
  longdouble lVar7;
  HSVectorBrushTool *local_64;
  undefined *local_60;
  undefined1 local_5c [24];
  undefined1 local_44 [24];
  float local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  pvVar3 = _objc_msgSend(self,sel_bitmapTool);
  piVar5 = (int *)&stack0xffffff24;
  if (((pvVar3 == tool) && (piVar5 = (int *)&stack0xffffff24, nextStage == (id)0x0)) &&
     (pvVar4 = _objc_msgSend(self->_touchStorage,sel_numberOfTouches),
     piVar5 = (int *)&stack0xffffff24, pvVar4 != (id)0x0)) {
    _objc_msgSend(pvVar3,sel_stopRecordTouchesWithConsumer_);
    _objc_msgSend(self,sel_invalidateContext);
    pvVar4 = _objc_msgSend(self,sel_view);
    _objc_msgSend_stret(local_5c,pvVar4,sel_viewSpaceToUserSpaceCGAffineTransform);
    _objc_msgSend_stret(local_44,self,sel_imageToViewTransform);
    piVar5 = (int *)&stack0xffffff1c;
    lVar6 = (longdouble)_hypotf();
    lVar7 = (longdouble)_hypotf();
    fStack_20 = (float)lVar7;
    uStack_28 = 0;
    local_24 = 0;
    local_1c = -((self->_brushBounds).origin.x * (float)lVar6);
    fStack_18 = -((self->_brushBounds).origin.y * fStack_20);
    local_2c = (float)lVar6;
    _objc_msgSend(self->_touchStorage,sel_applyAffineTransform_);
    _objc_msgSend(pvVar4,sel_isFlipped);
    puVar2 = cls_NSDictionary;
    _objc_msgSend(self,sel_toolSettings);
    _objc_msgSend(puVar2,sel_dictionaryWithDictionary_);
    pvVar4 = _objc_msgSend(self,sel_prototypeObject);
    pvVar4 = _objc_msgSend(pvVar4,sel_localCopyIncludingNodeUnits_);
    _objc_msgSend(pvVar4,
                  sel_setToolSettings_touchStorage_geometryTransform_geometryFlippedHorizontally_settingsWrapperInitialDelegate_
                 );
    _objc_msgSend(self,sel_addObjectToCard_);
    _objc_msgSend(pvVar4,sel_release);
    _objc_msgSend(self->_touchStorage,sel_release);
    pvVar4 = _objc_msgSend(cls_HSBrushTouchesStorage,sel_new);
    self->_touchStorage = pvVar4;
    _objc_msgSend(pvVar4,sel_setDelegate_);
    puVar2 = PTR_00336090;
    fVar1 = *(float *)(PTR_00336090 + 4);
    (self->_brushBounds).origin.x = *(float *)PTR_00336090;
    (self->_brushBounds).origin.y = fVar1;
    (self->_brushBounds).size.width = *(float *)(puVar2 + 8);
    (self->_brushBounds).size.height = *(float *)(puVar2 + 0xc);
    _objc_msgSend(pvVar3,sel_setUserPatternPhase_);
    _objc_msgSend(pvVar3,sel_startRecordTouchesWithConsumer_);
  }
  local_64 = self;
  local_60 = PTR_s_HSBaseBitmapTool_00351800;
  piVar5[5] = (int)nextStage;
  piVar5[4] = (int)withEvent;
  piVar5[3] = (int)didFinalizeStage;
  piVar5[2] = (int)tool;
  piVar5[1] = (int)sel_tool_didFinalizeStage_withEvent_nextStage_;
  *piVar5 = (int)&local_64;
  piVar5[-1] = 0x14ae9f;
  pvVar3 = _objc_msgSendSuper((void *)*piVar5,(SEL)piVar5[1]);
  return (BOOL)pvVar3;
}

*/
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2
{
    BTBrushTool *bitmapTool = (BTBrushTool *)[self bitmapTool];
    if (bitmapTool == aTool && aStage2 == nil && [_touchStorage numberOfTouches] != 0) {
        [bitmapTool stopRecordTouchesWithConsumer:_touchStorage];
        [self invalidateContext];
        id view = [self view];
        CGAffineTransform viewToUser = [view viewSpaceToUserSpaceCGAffineTransform];
        CGAffineTransform geometry = CGAffineTransformConcat([self imageToViewTransform], viewToUser);
        float scaleX = hypotf((float)geometry.a, (float)geometry.b);
        float scaleY = hypotf((float)geometry.c, (float)geometry.d);
        float inverseY = (scaleY != 0.0f) ? 1.0f / scaleY : 1.0f;
        float inverseX = (scaleX != 0.0f) ? 1.0f / scaleX : 1.0f;
        geometry.a *= inverseX;
        geometry.b *= inverseX;
        geometry.c *= inverseY;
        geometry.d *= inverseY;
        float offsetX = (float)_brushBounds.origin.x * scaleX;
        float offsetY = (float)_brushBounds.origin.y * scaleY;
        [_touchStorage applyAffineTransform:CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, -offsetX, -offsetY)];
        geometry = CGAffineTransformTranslate(geometry, offsetX, offsetY);
        if ([view isFlipped]) {
            float height = scaleY * (float)_brushBounds.size.height;
            geometry.tx += geometry.c * height;
            geometry.ty += geometry.d * height;
            geometry.c = -geometry.c;
            geometry.d = -geometry.d;
        }
        NSDictionary *settings = [NSDictionary dictionaryWithDictionary:[self toolSettings]];
        id object = [[self prototypeObject] localCopyIncludingNodeUnits:YES];
        [object setToolSettings:settings touchStorage:_touchStorage geometryTransform:geometry geometryFlippedHorizontally:NO settingsWrapperInitialDelegate:self];
        [self addObjectToCard:object];
        [object release];
        [_touchStorage release];
        _touchStorage = [HSBrushTouchesStorage new];
        [_touchStorage setDelegate:self];
        _brushBounds = CGRectZero;
        [bitmapTool setUserPatternPhase:NSZeroSize];
        [bitmapTool startRecordTouchesWithConsumer:_touchStorage];
    }
    return [super tool:aTool didFinalizeStage:aStage withEvent:aEvent nextStage:aStage2];
}

- (id)touchProvider
{
    return _touchStorage;
}

- (void)invalidateContext
{
    [[self bitmapTool] setWorkImage:nil];
    [_contextImage release];
    _contextImage = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014aeaf @ 0014aeaf, 421 bytes * /

void FUN_0014aeaf(HSVectorBrushTool *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  int *piVar3;
  id pvVar4;
  int iVar5;
  undefined1 local_3c [8];
  undefined4 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(local_3c,pvVar1,sel_bounds);
  if (self->_contextImage == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
    self_00 = _objc_msgSend(pvVar1,sel_initWithSize_,local_34);
    pvVar2 = _objc_msgSend(cls_HSTransformedBTNSImage,sel_alloc);
    _objc_msgSend_stret(&local_2c,self,sel_HSVectorBrushTool_imageTransform);
    pvVar1 = self_00;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithNSImage_contextTransform_,self_00,local_2c,local_24,
                           local_1c);
    self->_contextImage = pvVar2;
    pvVar2 = _objc_msgSend(self,sel_bitmapTool);
    piVar3 = _objc_msgSend(pvVar2,sel_requiredImageProtocols);
    for (; pvVar2 = (id)*piVar3, iVar5 = 0, pvVar2 != (id)0x0; piVar3 = piVar3 + 1) {
      pvVar4 = _objc_msgSend(self->_contextImage,sel_conformsToProtocol_,pvVar2,local_2c,local_24,
                             local_1c);
      pvVar1 = pvVar2;
      if ((char)pvVar4 == '\0') {
        iVar5 = *piVar3;
        break;
      }
    }
    if (iVar5 == 0) {
      pvVar2 = _objc_msgSend(self,sel_bitmapTool,pvVar1);
      pvVar1 = self->_contextImage;
      _objc_msgSend(pvVar2,sel_setWorkImage_,pvVar1);
    }
    _objc_msgSend(self_00,sel_release,pvVar1);
  }
  return;
}

*/
- (void)prepareContext
{
    NSRect bounds = [[self view] bounds];
    if (_contextImage == nil) {
        NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
        _contextImage = [[HSTransformedBTNSImage alloc] initWithNSImage:image contextTransform:[self HSVectorBrushTool_imageTransform]];
        id *protocols = [[self bitmapTool] requiredImageProtocols];
        BOOL conforms = YES;
        for (; *protocols != nil; protocols++) {
            if (![(id)_contextImage conformsToProtocol:(Protocol *)*protocols]) {
                conforms = NO;
                break;
            }
        }
        if (conforms) {
            [[self bitmapTool] setWorkImage:_contextImage];
        }
        [image release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014b054 @ 0014b054, 74 bytes * /

ulonglong FUN_0014b054(HSVectorBrushTool *self,SEL _cmd)

{
  id self_00;
  undefined1 local_1c [8];
  ulonglong local_14;
  
  self_00 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(local_1c,self_00,sel_bounds);
  return local_14;
}

*/
- (NSSize)contextImageSize
{
    return [[self view] bounds].size;
}

- (id)contextImage
{
    return _contextImage;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014b09e @ 0014b09e, 344 bytes * /

CGAffineTransform *
FUN_0014b09e(CGAffineTransform *__return_storage_ptr__,HSVectorBrushTool *self,SEL _cmd)

{
  id pvVar1;
  float local_4c;
  float local_48;
  float local_40;
  float local_3c;
  float local_38;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(&local_3c,pvVar1,sel_bounds);
  local_40 = local_38;
  _objc_msgSend_stret(&local_2c,self,sel_HSVectorBrushTool_imageTransform);
  local_40 = local_40 + local_18;
  local_48 = local_20;
  local_4c = local_28;
  pvVar1 = _objc_msgSend(pvVar1,sel_isFlipped);
  if ((char)pvVar1 != '\0') {
    local_48 = -local_20;
    local_4c = -local_28;
    local_40 = (local_30 + local_38 + local_38) - local_40;
  }
  __return_storage_ptr__->a = local_2c;
  __return_storage_ptr__->b = local_4c;
  __return_storage_ptr__->c = local_24;
  __return_storage_ptr__->d = local_48;
  __return_storage_ptr__->tx = local_3c + local_1c;
  __return_storage_ptr__->ty = local_40;
  return __return_storage_ptr__;
}

*/
- (CGAffineTransform)imageToViewTransform
{
    id view = [self view];
    NSRect bounds = [view bounds];
    CGAffineTransform imageTransform = [self HSVectorBrushTool_imageTransform];
    CGAffineTransform result = imageTransform;
    result.tx = bounds.origin.x + imageTransform.tx;
    result.ty = bounds.origin.y + imageTransform.ty;
    if ([view isFlipped]) {
        result.b = -imageTransform.b;
        result.d = -imageTransform.d;
        result.ty = (bounds.size.height + bounds.origin.y + bounds.origin.y) - result.ty;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014b1f6 @ 0014b1f6, 164 bytes * /

CGAffineTransform *
FUN_0014b1f6(CGAffineTransform *__return_storage_ptr__,HSVectorBrushTool *self,SEL _cmd)

{
  id self_00;
  CGAffineTransform *pCVar1;
  longdouble lVar2;
  longdouble extraout_ST0;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  self_00 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(&local_24,self_00,sel_userSpaceToViewSpaceCGAffineTransform);
  lVar2 = (longdouble)_hypotf(local_1c,local_18);
  pCVar1 = (CGAffineTransform *)_hypotf(local_24,local_20);
  __return_storage_ptr__->a = (float)extraout_ST0;
  __return_storage_ptr__->b = 0.0;
  __return_storage_ptr__->c = 0.0;
  __return_storage_ptr__->d = (float)lVar2;
  __return_storage_ptr__->tx = 0.0;
  __return_storage_ptr__->ty = 0.0;
  return pCVar1;
}

*/
- (CGAffineTransform)HSVectorBrushTool_imageTransform
{
    CGAffineTransform userToView = [[self view] userSpaceToViewSpaceCGAffineTransform];
    float scaleY = hypotf((float)userToView.c, (float)userToView.d);
    float scaleX = hypotf((float)userToView.a, (float)userToView.b);
    return CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, 0.0, 0.0);
}

- (BOOL)activateBitmapTool
{
    BOOL pvVar1;
    id pvVar2;

    pvVar1 = [super activateBitmapTool];
    if ((pvVar1) && (_touchStorage == nil)) {
        pvVar2 = [HSBrushTouchesStorage new];
        _touchStorage = pvVar2;
        [pvVar2 setDelegate:self];
        [[self bitmapTool] startRecordTouchesWithConsumer:_touchStorage];
    }
    return pvVar1;
}

- (id)bitmapTool
{
    return [super bitmapTool];
}

- (id)prototypeObject
{
    id pvVar1_3;
    id pvVar1_4;

    if (_prototypeObject == nil) {
        pvVar1_3 = [[[HSCreationToolSettingsProvider sharedInstance] userObjectPrototypeForToolIdentifier:[self primarySettingsIdentifier]] retain];
        _prototypeObject = pvVar1_3;
        pvVar1_4 = [pvVar1_3 unitForRole:HSVectorBrushRole];
        if ([pvVar1_4 isKindOfClass:[HSVectorBrushNodeUnit class]]) {
            [pvVar1_4 setTouchStorage:_touchStorage];
        }
    }
    return _prototypeObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014b37c @ 0014b37c, 173 bytes * /

id FUN_0014b37c(HSVectorBrushTool *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSVectorBrushTool *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSBaseBitmapTool_00351800;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_settingsIdentifiers);
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_00336470,
                         *(undefined4 *)PTR_003364cc,*(undefined4 *)PTR_003364d0,
                         *(undefined4 *)PTR_003364c8,*(undefined4 *)PTR_PTR_00336320,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_arrayByAddingObjectsFromArray_,pvVar2);
  return pvVar1;
}

*/
- (id)settingsIdentifiers
{
    NSArray *identifiers = [NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolSizeRatioAttributeKey, kToolPaddingKey, HSToolCursorContourAttributeKey, @"HSVectorBrushTool", nil];
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:identifiers];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014b429 @ 0014b429, 133 bytes * /

id FUN_0014b429(HSVectorBrushTool *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  undefined4 *puVar4;
  HSVectorBrushTool *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_PTR_00336320;
  pvVar3 = _objc_msgSend(self,sel_toolIdentifier);
  puVar2 = PTR_PTR_0033632c;
  puVar4 = (undefined4 *)PTR_PTR_00336218;
  if ((pvVar3 == *(id *)puVar1) ||
     (pvVar3 = _objc_msgSend(self,sel_toolIdentifier), puVar4 = (undefined4 *)PTR_PTR_00336300,
     pvVar3 == *(id *)puVar2)) {
    pvVar3 = (id)*puVar4;
  }
  else {
    local_1c = self;
    local_18 = PTR_s_HSBaseBitmapTool_00351800;
    pvVar3 = _objc_msgSendSuper(&local_1c,sel_primarySettingsIdentifier);
  }
  return pvVar3;
}

*/
- (id)primarySettingsIdentifier
{
    if ([[self toolIdentifier] isEqualToString:@"HSVectorBrushTool"]) {
        return @"HSBrushTool";
    }
    if ([[self toolIdentifier] isEqualToString:@"HSVectorSprayCanTool"]) {
        return @"HSSprayCanTool";
    }
    return [super primarySettingsIdentifier];
}

- (void)dealloc
{
    [[self bitmapTool] stopRecordTouchesWithConsumer:_touchStorage];
    [_touchStorage release];
    _touchStorage = nil;
    [_prototypeObject release];
    [_contextImage release];
    [super dealloc];
}

@end

