#import "HSBrushToolSettingsViewController.h"

@implementation HSBrushToolSettingsViewController

/* i386 ivar offsets: _gridControl=0xc, _colorContainerView=0x10, _colorViewController=0x14, _sizeSlider=0x18, _brushPreviewView=0x1c, _nameField=0x20, _pseudoImageView=0x24, _settingsTitle=0x28, _brushRect=0x2c, _previewPresets=0x3c, _currectToolIndex=0x40, _didFinishLoading=0x44 */

- (void)selectionDidChangeInGridControl:(id)aControl
{
    NSUInteger pvVar1;
    id pvVar2;
    id self_00;
    NSUInteger pvVar3;

    if (_didFinishLoading != NO) {
        pvVar1 = [_gridControl selectedItemIndex];
        if (_currectToolIndex != pvVar1) {
            pvVar2 = [HSToolManager sharedToolManager];
            self_00 = [pvVar2 toolSettings];
            pvVar3 = [_gridControl selectedItemIndex];
            [self_00 applySettingsForTool:[pvVar2 currentTool] templateIndex:pvVar3];
            [self refreshBrushPreview];
            _currectToolIndex = (unsigned int)pvVar1;
        }
    }
}

- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt
{
    id pvVar1;
    id pvVar1_7;

    if (_gridControl == aControl) {
        pvVar1 = [HSToolManager sharedToolManager];
        pvVar1_7 = [NSDictionary dictionaryWithObject:[[NSBundle mainBundle] localizedStringForKey:[[[[pvVar1 toolSettings] templateDictionaryAtIndex:aAt forTool:[pvVar1 currentTool]] objectForKey:kToolInformationKey] objectForKey:kToolDisplayNameKey] value:@"" table:@"Tools"] forKey:SMKGridAttributeVoiceOverItemTypeKey];
    }
    else {
        pvVar1_7 = nil;
    }
    return pvVar1_7;
}

- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    id pvVar1;
    id pvVar2;
    id pvVar3_2;

    pvVar1 = [HSToolManager sharedToolManager];
    pvVar2 = [pvVar1 currentTool];
    pvVar3_2 = [[pvVar1 toolSettings] drawColor];
    return [BTBrushTool hyperPreviewImageOfSize:NSMakeSize(32.0, 32.0) withToolTemplate:[[pvVar1 toolSettings] templateDictionaryAtIndex:aAt forTool:[pvVar1 currentTool]] color:pvVar3_2 settingsWrapperDelegate:pvVar2];
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return nil;
}

- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    return (int)[[[HSToolManager sharedToolManager] toolSettings] countOfTemplatesForTool:[[HSToolManager sharedToolManager] currentTool]];
}

- (Class)cellClass
{
    return [SMKGridBaseCell class];
}

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    NSUInteger pvVar1_3;

    [[[HSToolManager sharedToolManager] toolSettings] setDrawColor:aTo];
    pvVar1_3 = [_gridControl selectedItemIndex];
    [_gridControl reloadData];
    [_gridControl selectItemAtIndex:pvVar1_3 byExtendingSelection:NO];
    [self refreshBrushPreview];
    [self validateBackgroundColor];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00134463 @ 00134463, 317 bytes * /

void FUN_00134463(HSBrushToolSettingsViewController *self,SEL _cmd,id brushSizeChanged)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  double dVar4;
  
  lVar3 = (longdouble)_HSNonLinearValueForSlider(brushSizeChanged);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  dVar4 = _objc_msgSend_fpret(pvVar1,sel_sizeRatio);
  self_00 = cls_NSString;
  if ((float)dVar4 != (float)lVar3) {
    pvVar1 = self->_previewPresets;
    pvVar2 = _objc_msgSend(self->_gridControl,sel_selectedItemIndex);
    pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr__u,pvVar2);
    _objc_msgSend(pvVar1,sel_removeObjectForKey_,pvVar2);
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
    _objc_msgSend(pvVar1,sel_setSizeRatio_,(float)lVar3);
    _objc_msgSend(self,sel_refreshBrushPreview);
  }
  return;
}

*/
- (void)brushSizeChanged:(id)aChanged
{
    float size = HSNonLinearValueForSlider(aChanged);
    float current = [[[HSToolManager sharedToolManager] toolSettings] sizeRatio];
    if (current != size) {
        [_previewPresets removeObjectForKey:[NSString stringWithFormat:@"%u", (unsigned int)[_gridControl selectedItemIndex]]];
        [[[HSToolManager sharedToolManager] toolSettings] setSizeRatio:size];
        [self refreshBrushPreview];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00133e38 @ 00133e38, 263 bytes * /

void FUN_00133e38(HSBrushToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_drawColor);
  pvVar2 = _objc_msgSend(self,sel_backgroundColorForPreviewColor_,pvVar1);
  _objc_msgSend(self->_pseudoImageView,sel_setBackgroundColor_,pvVar2);
  pvVar1 = _objc_msgSend(self->_gridControl,sel_scrollView);
  pvVar4 = pvVar2;
  _objc_msgSend(pvVar1,sel_setBackgroundColor_,pvVar2);
  pvVar1 = self->_nameField;
  pvVar3 = _objc_msgSend(cls_NSColor,sel_whiteColor);
  op = sel_whiteColor;
  if (pvVar2 == pvVar3) {
    op = sel_grayColor;
  }
  pvVar4 = _objc_msgSend(cls_NSColor,op,pvVar4);
  _objc_msgSend(pvVar1,sel_setTextColor_,pvVar4);
  return;
}

*/
- (void)validateBackgroundColor
{
    id color = [[[HSToolManager sharedToolManager] toolSettings] drawColor];
    NSColor *background = [self backgroundColorForPreviewColor:color];
    [_pseudoImageView setBackgroundColor:background];
    [[_gridControl scrollView] setBackgroundColor:background];
    [_nameField setTextColor:(background == [NSColor whiteColor]) ? [NSColor grayColor] : [NSColor whiteColor]];
}

- (void)updateSelectedTemplate
{
    NSInteger pvVar1_3;

    pvVar1_3 = [[[HSToolManager sharedToolManager] toolSettings] appliedTemplateIndexForTool:[[HSToolManager sharedToolManager] currentTool]];
    if (0 < (int)pvVar1_3) {
        if ((int)pvVar1_3 < (int)[_gridControl count]) {
            [_gridControl selectItemAtIndex:pvVar1_3 byExtendingSelection:NO];
        }
    }
}

- (void)updateBrushColorIfNeeded
{
    id pvVar1_3;
    NSUInteger pvVar1_4;

    pvVar1_3 = [[[HSToolManager sharedToolManager] toolSettings] drawColor];
    if (![[_colorViewController color] isEqual:pvVar1_3]) {
        [_colorViewController setColor:pvVar1_3];
        pvVar1_4 = [_gridControl selectedItemIndex];
        [_gridControl reloadData];
        [_gridControl selectItemAtIndex:pvVar1_4 byExtendingSelection:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001345a0 @ 001345a0, 915 bytes * /

void FUN_001345a0(HSBrushToolSettingsViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  longdouble lVar6;
  longdouble lVar7;
  
  pvVar1 = _objc_msgSend(self,sel_brushToolStorage);
  pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
  lVar6 = (longdouble)_CGRectGetHeight((self->_brushRect).origin,(self->_brushRect).size);
  lVar7 = (longdouble)_CGRectGetWidth((self->_brushRect).origin,(self->_brushRect).size);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithSize_,(float)lVar7,(float)lVar6);
  pvVar3 = _objc_msgSend(self,sel_brushTool);
  pvVar4 = _objc_msgSend(pvVar3,sel_isPadFlippedVertically);
  _objc_msgSend(pvVar3,sel_setPadFlippedVertically_,0);
  _objc_msgSend(pvVar2,sel_lockFocus);
  pvVar5 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar5,sel_saveGraphicsState);
  self_00 = cls_NSAffineTransform;
  lVar6 = (longdouble)_CGRectGetHeight((self->_brushRect).origin,(self->_brushRect).size);
  lVar7 = (longdouble)_CGRectGetWidth((self->_brushRect).origin,(self->_brushRect).size);
  pvVar5 = _objc_msgSend(self_00,sel_hyperTransitionFromRect_toRect_,(self->_brushRect).origin,
                         (self->_brushRect).size,0,CONCAT44((float)lVar6,(float)lVar7));
  _objc_msgSend(pvVar5,sel_concat);
  pvVar5 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  pvVar5 = _objc_msgSend(pvVar5,sel_graphicsPort);
  _objc_msgSend(pvVar3,sel_drawWithTouchProvider_inContext_withBounds_,pvVar1,pvVar5,
                (self->_brushRect).origin,(self->_brushRect).size);
  pvVar1 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar1,sel_restoreGraphicsState);
  _objc_msgSend(pvVar2,sel_unlockFocus);
  _objc_msgSend(self->_brushPreviewView,sel_setImage_,pvVar2);
  _objc_msgSend(pvVar2,sel_release);
  _objc_msgSend(pvVar3,sel_setPadFlippedVertically_,(int)(char)pvVar4);
  pvVar1 = self->_nameField;
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(self,sel_currentPresetDictionary);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,*(undefined4 *)PTR_003365c4);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,*(undefined4 *)PTR_003365c0);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pvVar3,&cfstr_empty,
                         &cfstr_Tools);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)refreshBrushPreview
{
    id storage = [self brushToolStorage];
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(CGRectGetWidth(_brushRect), CGRectGetHeight(_brushRect))];
    id brushTool = [self brushTool];
    BOOL flipped = [brushTool isPadFlippedVertically];
    [brushTool setPadFlippedVertically:NO];
    [image lockFocus];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    NSAffineTransform *transform = [NSAffineTransform hyperTransitionFromRect:NSRectFromCGRect(_brushRect) toRect:NSMakeRect(0.0f, 0.0f, CGRectGetWidth(_brushRect), CGRectGetHeight(_brushRect))];
    [transform concat];
    [brushTool drawWithTouchProvider:storage inContext:[[NSGraphicsContext currentContext] graphicsPort] withBounds:_brushRect];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    [image unlockFocus];
    [_brushPreviewView setImage:image];
    [image release];
    [brushTool setPadFlippedVertically:flipped];
    NSString *name = [[[self currentPresetDictionary] objectForKey:kToolInformationKey] objectForKey:kToolDisplayNameKey];
    [_nameField setStringValue:[[NSBundle mainBundle] localizedStringForKey:name value:@"" table:@"Tools"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00134933 @ 00134933, 148 bytes * /

void FUN_00134933(HSBrushToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  longdouble lVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_sizeRatio);
  if ((float)dVar3 != 0.0) {
    pvVar1 = self->_sizeSlider;
    lVar2 = (longdouble)_HSLinearValueForSliderFromNonLinear(pvVar1,(float)dVar3);
    _objc_msgSend(pvVar1,sel_setFloatValue_,(float)lVar2);
  }
  return;
}

*/
- (void)updateBrushSize
{
    float ratio = [[[HSToolManager sharedToolManager] toolSettings] sizeRatio];
    if (ratio != 0.0f) {
        [_sizeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_sizeSlider, ratio)];
    }
}

- (void)updateUI
{
    [self updateBrushColorIfNeeded];
    [self updateSelectedTemplate];
    [self updateBrushSize];
    [self refreshBrushPreview];
    [self validateBackgroundColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00133b3a @ 00133b3a, 217 bytes * /

id FUN_00133b3a(HSBrushToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  undefined *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_gridControl,sel_selectedItemIndex);
  self_00 = cls_NSDictionary;
  op = sel_dictionary;
  if (pvVar1 != (id)0x7fffffff) {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    self_00 = _objc_msgSend(pvVar1,sel_toolSettings);
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    _objc_msgSend(pvVar1,sel_currentTool);
    _objc_msgSend(self->_gridControl,sel_selectedItemIndex);
    op = sel_templateDictionaryAtIndex_forTool_;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)currentPresetDictionary
{
    if ([_gridControl selectedItemIndex] == NSNotFound) {
        return [NSDictionary dictionary];
    }
    HSToolManager *manager = [HSToolManager sharedToolManager];
    return [[manager toolSettings] templateDictionaryAtIndex:[_gridControl selectedItemIndex] forTool:[manager currentTool]];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001349c7 @ 001349c7, 872 bytes * /

id FUN_001349c7(HSBrushToolSettingsViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  longdouble lVar5;
  double dVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  self_00 = cls_NSString;
  pvVar1 = _objc_msgSend(self->_gridControl,sel_selectedItemIndex);
  pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr__u,pvVar1);
  pvVar3 = pvVar2;
  self_01 = _objc_msgSend(self->_previewPresets,sel_objectForKey_,pvVar2);
  if ((self_01 == (id)0x0) && (self->_previewPresets != (id)0x0)) {
    self_01 = _objc_msgSend(cls_BTBrushTouchStorage,sel_new,pvVar3,pvVar1);
    pvVar3 = _objc_msgSend(self,sel_brushTool);
    pvVar3 = _objc_msgSend(pvVar3,sel_positionOscillation);
    pvVar1 = _objc_msgSend(self,sel_brushTool);
    dVar6 = _objc_msgSend_fpret(pvVar1,sel_spacing);
    pvVar1 = _objc_msgSend(self,sel_brushTool);
    uVar8 = 0;
    uVar7 = 0;
    _objc_msgSend(pvVar1,sel_setPositionOscillation_,0,0);
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
    if (pvVar1 == (id)0x13) {
      pvVar1 = _objc_msgSend(self,sel_brushTool,uVar7,uVar8);
      pvVar4 = _objc_msgSend(self,sel_brushTool);
      pvVar4 = _objc_msgSend(pvVar4,sel_size);
      _objc_msgSend(pvVar1,sel_setSpacing_,pvVar4);
    }
    _objc_msgSend_stret(local_24,self->_brushPreviewView,sel_frame);
    lVar5 = (longdouble)_HSNonLinearValueForSlider(self->_sizeSlider);
    local_34 = local_1c * 0.5;
    if ((float)lVar5 <= local_1c * 0.5) {
      local_34 = (float)lVar5;
    }
    local_2c = local_1c - local_34;
    local_30 = local_18 * 0.5;
    local_28 = local_18 * 0.5;
    pvVar1 = _objc_msgSend(self,sel_brushTool);
    _objc_msgSend_stret(&local_44,pvVar1,
                        sel_recordAlongPolylineWithPoints_count_withAlternateColor_withPressure_to_,
                        &local_34,2,0,0x3f800000,self_01);
    (self->_brushRect).origin.x = local_44;
    (self->_brushRect).origin.y = local_40;
    (self->_brushRect).size.width = local_3c;
    (self->_brushRect).size.height = local_38;
    pvVar1 = _objc_msgSend(self,sel_brushTool);
    _objc_msgSend(pvVar1,sel_setPositionOscillation_,pvVar3,extraout_EDX);
    pvVar3 = _objc_msgSend(self,sel_brushTool);
    _objc_msgSend(pvVar3,sel_setSpacing_,(float)dVar6);
    _objc_msgSend(self->_previewPresets,sel_setObject_forKey_,self_01,pvVar2);
    _objc_msgSend(self_01,sel_release);
  }
  return self_01;
}

*/
- (id)brushToolStorage
{
    NSString *key = [NSString stringWithFormat:@"%u", (unsigned int)[_gridControl selectedItemIndex]];
    id storage = [_previewPresets objectForKey:key];
    if (storage == nil && _previewPresets != nil) {
        storage = [BTBrushTouchStorage new];
        NSSize oscillation = [[self brushTool] positionOscillation];
        float spacing = [[self brushTool] spacing];
        [[self brushTool] setPositionOscillation:NSZeroSize];
        if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x13) {
            [[self brushTool] setSpacing:((float (*)(id, SEL))objc_msgSend)([self brushTool], @selector(size))];
        }
        NSRect frame = [_brushPreviewView frame];
        float size = HSNonLinearValueForSlider(_sizeSlider);
        float inset = frame.size.width * 0.5f;
        if (size <= inset) {
            inset = size;
        }
        NSPoint points[2];
        points[0] = NSMakePoint(inset, frame.size.height * 0.5f);
        points[1] = NSMakePoint(frame.size.width - inset, frame.size.height * 0.5f);
        NSRect rect = [[self brushTool] recordAlongPolylineWithPoints:points count:2 withAlternateColor:NO withPressure:1.0f to:storage];
        _brushRect = NSRectToCGRect(rect);
        [[self brushTool] setPositionOscillation:oscillation];
        [[self brushTool] setSpacing:spacing];
        [_previewPresets setObject:storage forKey:key];
        [storage release];
    }
    return storage;
    return 0;
}

- (id)brushTool
{
    return [[[HSToolManager sharedToolManager] currentTool] bitmapTool];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00134d2f @ 00134d2f, 689 bytes * /

void FUN_00134d2f(HSBrushToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  undefined *puVar5;
  HSBrushToolSettingsViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSToolSettingsViewController_00351470;
  _objc_msgSendSuper(&local_1c,sel_didMount);
  _objc_msgSend(self->_previewPresets,sel_removeAllObjects);
  _objc_msgSend(self,sel_updateSelectedTemplate);
  _objc_msgSend(self,sel_updateBrushColorIfNeeded);
  pvVar1 = _objc_msgSend(self->_sizeSlider,sel_cell);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar3 = _objc_msgSend(pvVar3,sel_selectedToolTag);
  pcVar4 = &cfstr_paintbrush_size;
  if (pvVar3 == (id)0x13) {
    pcVar4 = &cfstr_spray_can_size;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                         &cfstr_ToolPalette);
  _objc_msgSend(pvVar1,sel_accessibilitySetOverrideValue_forAttribute_,pvVar2,
                *(undefined4 *)PTR_0033653c);
  _objc_msgSend(self,sel_updateBrushSize);
  _objc_msgSend(self,sel_brushSizeChanged_,self->_sizeSlider);
  _objc_msgSend(self,sel_validateBackgroundColor);
  pvVar1 = _objc_msgSend(self->_gridControl,sel_gridMatrix);
  pvVar1 = _objc_msgSend(pvVar1,sel_cells);
  pvVar2 = _objc_msgSend(pvVar1,sel_extraFirstObject);
  puVar5 = sel_updateContentIfNeeded;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_updateContentIfNeeded);
  if ((char)pvVar2 != '\0') {
    puVar5 = sel_updateContentIfNeeded;
    _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_,sel_updateContentIfNeeded);
  }
  pvVar1 = _objc_msgSend(self->_settingsTitle,sel_headerCell,puVar5);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar3 = _objc_msgSend(pvVar3,sel_selectedToolTag);
  pcVar4 = &cfstr_Brush_header;
  if (pvVar3 == (id)0x13) {
    pcVar4 = &cfstr_Spray_header;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                         &cfstr_ToolPalette);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)didMount
{
    [super didMount];
    [_previewPresets removeAllObjects];
    [self updateSelectedTemplate];
    [self updateBrushColorIfNeeded];
    NSString *sizeKey = ([[HSToolManager sharedToolManager] selectedToolTag] == 0x13) ? @"spray can size" : @"paintbrush size";
    [[_sizeSlider cell] accessibilitySetOverrideValue:[[NSBundle mainBundle] localizedStringForKey:sizeKey value:@"" table:@"ToolPalette"] forAttribute:NSAccessibilityDescriptionAttribute];
    [self updateBrushSize];
    [self brushSizeChanged:_sizeSlider];
    [self validateBackgroundColor];
    NSArray *cells = [[_gridControl gridMatrix] cells];
    if ([[cells extraFirstObject] respondsToSelector:@selector(updateContentIfNeeded)]) {
        [cells makeObjectsPerformSelector:@selector(updateContentIfNeeded)];
    }
    NSString *headerKey = ([[HSToolManager sharedToolManager] selectedToolTag] == 0x13) ? @"Spray header" : @"Brush header";
    [[_settingsTitle headerCell] setStringValue:[[NSBundle mainBundle] localizedStringForKey:headerKey value:@"" table:@"ToolPalette"]];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_colorViewController validateUserInterface];
}

- (void)didLoadNib
{
    [_gridControl setMode:0];
    [_gridControl setScrollerControlSize:NSSmallControlSize];
    [_gridControl setThumbnailSize:NSMakeSize(21.0f, 21.0f) andBorderOffset:NSMakeSize(1.0f, 1.0f)];
    [_gridControl setSelectionStyle:2];
    [_gridControl setImageFrameColor:[NSColor redColor]];
    [_gridControl setThreadedPreloadingEnabled:NO];
    [_gridControl setAllowsMultipleSelection:NO];
    [_gridControl setThumbnailCachingEnabled:YES];
    [_gridControl setThumbnailHyphenationEnabled:YES];
    [_gridControl setGraphicContentShadowEnabled:NO];
    [_gridControl setExtraPasteboardDataProvidingAllowed:NO];
    [_gridControl setDataSource:self];
    [_gridControl setDelegate:self];
    [_gridControl setTarget:self];
    [[_gridControl gridMatrix] setAcceptsFirstMouse:YES];
    [[_gridControl gridMatrix] setNeedsPanelToBecomeKey:NO];
    [[_gridControl scrollView] setHasVerticalScroller:NO];
    [[_gridControl scrollView] setHasHorizontalScroller:NO];
    [[_gridControl scrollView] setBorderType:NSNoBorder];
    _previewPresets = [NSMutableDictionary new];
    [_gridControl reloadData];
    [_colorViewController setDelegate:self];
    [[_colorViewController colorView] setFrame:[_colorContainerView bounds]];
    [_colorContainerView addSubview:[_colorViewController colorView]];
    [[_colorViewController crayonsView] setNeedsForceLayout:YES];
    [_brushPreviewView setImageScaling:0];
    [self refreshBrushPreview];
    _currectToolIndex = (int)[_gridControl count] + 1;
    _didFinishLoading = YES;
}

- (id)nibName
{
    return @"BrushToolSettings";
}

- (void)dealloc
{
    [_colorViewController release];
    [_previewPresets release];
    [super dealloc];
}

@end

