#import "HSGraphicAppearanceAssistantPane.h"

@implementation HSGraphicAppearanceAssistantPane

/* i386 ivar offsets: _nameTextField=0x5c, _frameColorWell=0x60, _shadowButton=0x64, _shadowSwitch=0x68, _frameWidthSlider=0x6c, _frameWidthTextField=0x70, _frameWidthStepper=0x74, _opacitySlider=0x78, _opacityTextField=0x7c, _opacityStepper=0x80, _highlightSwitch=0x84, _transparentColorButton=0x88, _transparentColorSwitch=0x8c, _transparentColorAttributes=0x90 */

- (id)geometryAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)objectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
}

- (id)opacityAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableOpacityAttributes)];
}

- (id)outlineAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableOutlineAttributes)];
}

- (id)highlightAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSHighlightAttributes)];
}

- (void)updateHighlight
{
    [_highlightSwitch setState:(unsigned int)([[self highlightAttributes] canBeHighlighted])];
}

- (void)updateName
{
    [_nameTextField setStringValue:[[self objectAttributes] hyperName]];
}

- (void)updateOpacity:(CGFloat)aOpacity
{
    float fVar1;

    fVar1 = aOpacity * 100.0;
    [_opacitySlider setFloatValue:fVar1];
    [_opacityTextField setFloatValue:fVar1];
    [_opacityStepper setFloatValue:fVar1];
}

- (void)setOriginalObjectOpacity:(CGFloat)aOpacity
{
    [[self opacityAttributes] setHyperOpacity:aOpacity];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00178ce6 @ 00178ce6, 148 bytes * /

void FUN_00178ce6(HSGraphicAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar2 = _objc_msgSend(pvVar1,sel_affineFrameSize);
  pvVar1 = extraout_EDX;
  if ((float)pvVar2 <= (float)extraout_EDX) {
    pvVar1 = pvVar2;
  }
  _objc_msgSend(self->_frameWidthSlider,sel_setMaxValue_,(double)((float)pvVar1 * 0.5));
  _objc_msgSend(self->_frameWidthStepper,sel_setMaxValue_,(double)((float)pvVar1 * 0.5));
  return;
}

*/
- (void)updateOutlineControls
{
    NSSize size = [[self geometryAttributes] affineFrameSize];
    float smaller = (size.width <= size.height) ? size.width : size.height;
    [_frameWidthSlider setMaxValue:(double)(smaller * 0.5f)];
    [_frameWidthStepper setMaxValue:(double)(smaller * 0.5f)];
}

- (void)updateOutlineWidth:(CGFloat)aWidth
{
    [_frameWidthSlider setFloatValue:aWidth];
    [_frameWidthTextField setFloatValue:aWidth];
    [_frameWidthStepper setFloatValue:aWidth];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00178df2 @ 00178df2, 132 bytes * /

void FUN_00178df2(HSGraphicAppearanceAssistantPane *self,SEL _cmd,
                 float setOriginalObjectOutlineWidth)

{
  id self_00;
  undefined4 uVar1;
  
  self_00 = _objc_msgSend(self,sel_outlineAttributes);
  if ((setOriginalObjectOutlineWidth != 0.0) || (NAN(setOriginalObjectOutlineWidth))) {
    uVar1 = 1;
  }
  else {
    uVar1 = 0;
  }
  _objc_msgSend(self_00,sel_setHyperOutlineEnabled_,uVar1);
  _objc_msgSend(self_00,sel_setHyperOutlineWidth_,setOriginalObjectOutlineWidth);
  return;
}

*/
- (void)setOriginalObjectOutlineWidth:(CGFloat)aWidth
{
    id outline = [self outlineAttributes];
    [outline setHyperOutlineEnabled:(aWidth != 0.0f)];
    [outline setHyperOutlineWidth:aWidth];
}

- (void)updateOutlineColor:(id)aColor
{
    [_frameColorWell setColor:aColor];
}

- (void)setOriginalObjectOutlineColor:(id)aColor
{
    [[self outlineAttributes] setHyperOutlineColor:aColor];
}

- (void)updateShadow
{
    char cVar1;
    NSString *pcVar3;

    cVar1 = [[self shadowAttributes] isHyperShadowEnabled];
    [_shadowSwitch setState:cVar1];
    [_shadowButton setHidden:((unsigned int)(cVar1 == NO))];
    if (cVar1 == NO) {
        pcVar3 = [_shadowButton title];
    }
    else {
        pcVar3 = @"";
    }
    [_shadowSwitch setTitle:pcVar3];
}

- (void)updateOutline
{
    id self_00;
    float fVar2;

    self_00 = [self outlineAttributes];
    [self updateOutlineColor:[self_00 hyperOutlineColor]];
    if (![self_00 isHyperOutlineEnabled]) {
        fVar2 = 0.0;
    }
    else {
        fVar2 = (float)[self_00 hyperOutlineWidth];
    }
    [self updateOutlineWidth:fVar2];
}

- (void)validateTransparentAttributesWithNotification:(id)aNotification
{
    [self HSGraphicAppearanceAssistantPane_validateTransparentColorSwitchAndButton];
}

- (void)validateShadowAttributesWithNotification:(id)aNotification
{
    [self updateShadow];
}

- (void)validateOpacityAttributesWithNotification:(id)aNotification
{
    [self updateOpacity:(float)[[self opacityAttributes] hyperOpacity]];
}

- (void)validateOutlineAttributesWithNotification:(id)aNotification
{
    [self updateOutline];
}

- (void)validateOutlineControlsWithNotification:(id)aNotification
{
    [self updateOutlineControls];
}

- (void)validateObjectAttributesWithNotification:(id)aNotification
{
    [self updateName];
}

- (void)validateHighlightAttributesWithNotification:(id)aNotification
{
    [self updateHighlight];
}

- (void)HSGraphicAppearanceAssistantPane_validateTransparentColorSwitchAndButton
{
    BOOL bVar3;
    id pvVar1_3;

    bVar3 = ![_transparentColorAttributes isTransparentColorEnabled];
    if (bVar3) {
        [_transparentColorSwitch setState:0];
        [_transparentColorSwitch setTitle:[_transparentColorButton title]];
        pvVar1_3 = _transparentColorButton;
    }
    else {
        [_transparentColorSwitch setState:1];
        [_transparentColorSwitch setTitle:@""];
        pvVar1_3 = _transparentColorButton;
    }
    [pvVar1_3 setHidden:(unsigned int)bVar3];
}

- (void)editTransparentColor:(id)aColor
{
    id pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[HSTransparentColorAssistantPane alloc] init];
    if (pvVar1_2 != nil) {
        pvVar2_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
        [pvVar1_2 release];
        if (pvVar2_2 != nil) {
            [self presentModalViewController:pvVar2_2 animated:YES];
            [pvVar2_2 release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00179341 @ 00179341, 164 bytes * /

void FUN_00179341(HSGraphicAppearanceAssistantPane *self,SEL _cmd,id setTransparentColor)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(setTransparentColor,sel_state);
  if (pvVar1 == (id)0x0) {
    self = self->_transparentColorAttributes;
    setTransparentColor = (id)0x0;
    op = sel_setTransparentColorEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self->_transparentColorAttributes,sel_transparentColor);
    op = sel_editTransparentColor_;
    if (pvVar1 != (id)0x0) {
      self = self->_transparentColorAttributes;
      setTransparentColor = (id)0x1;
      op = sel_setTransparentColorEnabled_;
    }
  }
  _objc_msgSend(self,op,setTransparentColor);
  return;
}

*/
- (void)setTransparentColor:(id)aColor
{
    NSInteger state = [aColor state];
    if (state == 0) {
        [_transparentColorAttributes setTransparentColorEnabled:NO];
    } else if (state == 1) {
        if ([_transparentColorAttributes transparentColor] == nil) {
            [self editTransparentColor:aColor];
        } else {
            [_transparentColorAttributes setTransparentColorEnabled:YES];
        }
    }
}

- (void)highlightStateChanged:(id)aChanged
{
    [[self highlightAttributes] setCanBeHighlighted:(unsigned int)([aChanged state] == 0x1)];
}

- (void)frameWidthChanged:(id)aChanged
{
    [self setOriginalObjectOutlineWidth:(float)[aChanged floatValue]];
}

- (void)colorInWellChanged:(id)aChanged
{
    [self setOriginalObjectOutlineColor:[aChanged color]];
}

- (void)opacityChanged:(id)aChanged
{
    [self setOriginalObjectOpacity:(float)[aChanged floatValue] / 100.0];
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00179540 @ 00179540, 201 bytes * /

void FUN_00179540(HSGraphicAppearanceAssistantPane *self,SEL _cmd,id setShadow)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(setShadow,sel_state);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    uVar2 = 0;
    op = sel_setHyperShadowEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,1);
    _objc_msgSend(self->_shadowButton,sel_setHidden_,0);
    pvVar1 = self->_shadowButton;
    uVar2 = 1;
    op = sel_setEnabled_;
  }
  _objc_msgSend(pvVar1,op,uVar2);
  return;
}

*/
- (void)setShadow:(id)aShadow
{
    NSInteger state = [aShadow state];
    if (state == 0) {
        [[self shadowAttributes] setHyperShadowEnabled:NO];
    } else if (state == 1) {
        [[self shadowAttributes] setHyperShadowEnabled:YES];
        [_shadowButton setHidden:NO];
        [_shadowButton setEnabled:YES];
    }
}

- (void)showShadowPane
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSTextShadowAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

- (void)setName:(id)aName
{
    [[self objectAttributes] setHyperName:[_nameTextField stringValue]];
}

- (id)nameTextfField
{
    return _nameTextField;
}

- (id)initialKeyView
{
    return _nameTextField;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00179706 @ 00179706, 110 bytes * /

BOOL FUN_00179706(HSGraphicAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_nameTextField,sel_currentEditor);
  if ((pvVar1 == (id)0x0) &&
     (pvVar1 = _objc_msgSend(self->_frameWidthTextField,sel_currentEditor), pvVar1 == (id)0x0)) {
    pvVar1 = _objc_msgSend(self->_opacityTextField,sel_currentEditor);
    return pvVar1 != (id)0x0;
  }
  return '\x01';
}

*/
- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil || [_frameWidthTextField currentEditor] != nil || [_opacityTextField currentEditor] != nil;
    return 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_frameColorWell setGradientSupportEnabled:NO];
    [_frameColorWell setPatternSupportEnabled:NO];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    int uVar1;
    id pvVar2_2;
    id pvVar2_8;

    [super viewWillDisappear:aDisappear];
    pvVar2_2 = [[self highlightAttributes] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 removeObserver:self selector:@selector(validateHighlightAttributesWithNotification:) ofChanges:uVar1 ofAttribute:@protocol(HSHighlightSupportAttribute)];
    [[[self opacityAttributes] attributeObservingController] removeObserver:self selector:@selector(validateOpacityAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSOpacityAttributes)];
    [[[self outlineAttributes] attributeObservingController] removeObserver:self selector:@selector(validateOutlineAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSOutlineAttributes)];
    pvVar2_8 = [[self objectAttributes] attributeObservingController];
    [pvVar2_8 removeObserver:self selector:@selector(validateObjectAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSObjectAttributes)];
    [[[self shadowAttributes] attributeObservingController] removeObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [[[self geometryAttributes] attributeObservingController] removeObserver:self selector:@selector(validateOutlineControlsWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes)];
    [pvVar2_8 removeObserver:self selector:@selector(validateTransparentAttributesWithNotification:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorEnabledAttribute)];
    [_transparentColorAttributes release];
    _transparentColorAttributes = nil;
}

- (void)viewWillAppear:(BOOL)aAppear
{
    int uVar1;
    id pvVar2;
    id pvVar3;
    id pvVar4;
    id self_00;
    id pvVar2_2;

    [super viewWillAppear:aAppear];
    pvVar2 = [self objectAttributes];
    pvVar3 = [self opacityAttributes];
    pvVar4 = [self outlineAttributes];
    self_00 = [self highlightAttributes];
    [self updateName];
    [self updateOpacity:(float)[pvVar3 hyperOpacity]];
    [self updateOutlineControls];
    [self updateOutline];
    [self updateShadow];
    [self updateHighlight];
    pvVar2_2 = [pvVar2 attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 addObserver:self selector:@selector(validateObjectAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSObjectAttributes) withPriority:-0.25];
    [[pvVar4 attributeObservingController] addObserver:self selector:@selector(validateOutlineAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSOutlineAttributes) withPriority:-0.25]
    ;
    [[pvVar3 attributeObservingController] addObserver:self selector:@selector(validateOpacityAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSOpacityAttributes) withPriority:-0.25]
    ;
    [[self_00 attributeObservingController] addObserver:self selector:@selector(validateHighlightAttributesWithNotification:) ofChanges:uVar1 ofAttribute:@protocol(HSHighlightSupportAttribute) withPriority:-0.25];
    [[[self shadowAttributes] attributeObservingController] addObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    [[[self geometryAttributes] attributeObservingController] addObserver:self selector:@selector(validateOutlineControlsWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes) withPriority:-0.25];
    _transparentColorAttributes = [[[[self assistant] object] queryHyperInterface:@protocol(HSTransparentColorAttributes)] retain];
    [pvVar2_2 addObserver:self selector:@selector(validateTransparentAttributesWithNotification:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withPriority:-0.25];
    [self HSGraphicAppearanceAssistantPane_validateTransparentColorSwitchAndButton];
}

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ImageAppearanceAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end

