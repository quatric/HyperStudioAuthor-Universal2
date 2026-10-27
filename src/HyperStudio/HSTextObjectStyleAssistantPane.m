#import "HSTextObjectStyleAssistantPane.h"

@implementation HSTextObjectStyleAssistantPane

/* i386 ivar offsets: _observedTextObjectAttributes=0xbc, _observedTextLayoutAttributes=0xc0, _observedTextShadowAttributes=0xc4 */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSTextObjectAttributes)];
}

- (void)validateCharacterSpacingControls
{
    float fVar1;
    unsigned int uVar2;
    float fVar3;
    float fVar4;

    fVar1 = (float)[_observedTextObjectAttributes hyperSpaceBetweenCharacters];
    fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar4 = 0.0005;
    if (1.0 <= fVar3) {
        fVar4 = fVar3 * 0.0005;
    }
    uVar2 = -(unsigned int)(fVar4 < fabs(fVar1)) & 1;
    [_characterSpaceSwitch setState:uVar2];
    [self enableSpaceCharactersControls:uVar2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00172e7a @ 00172e7a, 1080 bytes * /

void FUN_00172e7a(HSTextObjectStyleAssistantPane *self,SEL _cmd)

{
  float fVar1;
  HSGradientColorWell *self_00;
  float fVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  uint uVar7;
  longdouble lVar8;
  double dVar9;
  float fVar10;
  HSTextObjectStyleAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSTextStyleAssistantPane_00352460;
  _objc_msgSendSuper(&local_1c,sel_validateUI);
  if (self->_observedTextObjectAttributes != (id)0x0) {
    self_00 = (self->super)._textColorWell;
    pvVar4 = _objc_msgSend(self->_observedTextObjectAttributes,sel_hyperTextColor);
    _objc_msgSend(self_00,sel_setColor_,pvVar4);
    pvVar4 = _objc_msgSend((self->super)._textStyleMatrix,sel_cellWithTag_,1);
    pvVar5 = _objc_msgSend(self->_observedTextObjectAttributes,sel_isHyperBold);
    _objc_msgSend(pvVar4,sel_setState_,(int)(char)pvVar5);
    pvVar4 = _objc_msgSend((self->super)._textStyleMatrix,sel_cellWithTag_,2);
    pvVar5 = _objc_msgSend(self->_observedTextObjectAttributes,sel_isHyperItalic);
    _objc_msgSend(pvVar4,sel_setState_,(int)(char)pvVar5);
    pvVar4 = _objc_msgSend((self->super)._textStyleMatrix,sel_cellWithTag_,3);
    pvVar5 = _objc_msgSend(self->_observedTextObjectAttributes,sel_isHyperUnderlined);
    _objc_msgSend(pvVar4,sel_setState_,(int)(char)pvVar5);
    pvVar4 = _objc_msgSend(self->_observedTextObjectAttributes,sel_isHyperOutlineEnabled);
    cVar3 = (char)pvVar4;
    _objc_msgSend((self->super)._outlineSwitch,sel_setState_,(int)cVar3);
    uVar7 = (uint)(cVar3 == '\0');
    _objc_msgSend((self->super)._outlineButton,sel_setHidden_,uVar7);
    if (cVar3 == '\0') {
      pcVar6 = _objc_msgSend((self->super)._outlineButton,sel_title,uVar7);
    }
    else {
      pcVar6 = &cfstr_empty;
    }
    _objc_msgSend((self->super)._outlineSwitch,sel_setTitle_,pcVar6);
    pvVar4 = (self->super)._alignmentMatrix;
    pvVar5 = _objc_msgSend(self->_observedTextObjectAttributes,sel_hyperTextAlignment);
    _objc_msgSend(pvVar4,sel_selectCellWithTag_,pvVar5);
    dVar9 = _objc_msgSend_fpret(self->_observedTextObjectAttributes,sel_hyperSpaceBetweenCharacters)
    ;
    fVar2 = (float)dVar9;
    dVar9 = _objc_msgSend_fpret((self->super)._genericFontAttributes,sel_hyperFontSize);
    lVar8 = (longdouble)_roundf((fVar2 * 100.0) / (float)dVar9);
    fVar10 = (float)lVar8;
    fVar1 = fVar10;
    if (fVar2 == 0.0) {
      fVar1 = (self->super)._characterSpaceValue;
    }
    _objc_msgSend((self->super)._characterSpaceField,sel_setFloatValue_,fVar1,fVar10);
    if (fVar2 == 0.0) {
      fVar10 = (self->super)._characterSpaceValue;
    }
    _objc_msgSend((self->super)._characterSpaceStepper,sel_setFloatValue_,fVar10);
  }
  if (self->_observedTextShadowAttributes != (id)0x0) {
    pvVar4 = _objc_msgSend(self->_observedTextShadowAttributes,sel_isHyperShadowEnabled);
    cVar3 = (char)pvVar4;
    _objc_msgSend((self->super)._shadowSwitch,sel_setState_,(int)cVar3);
    uVar7 = (uint)(cVar3 == '\0');
    _objc_msgSend((self->super)._shadowButton,sel_setHidden_,uVar7);
    if (cVar3 == '\0') {
      pcVar6 = _objc_msgSend((self->super)._shadowButton,sel_title,uVar7);
    }
    else {
      pcVar6 = &cfstr_empty;
    }
    _objc_msgSend((self->super)._shadowSwitch,sel_setTitle_,pcVar6);
  }
  if (self->_observedTextLayoutAttributes != (id)0x0) {
    pvVar4 = (self->super)._verticalAlignmentMatrix;
    pvVar5 = _objc_msgSend(self->_observedTextLayoutAttributes,sel_textBlockVerticalAlignment);
    _objc_msgSend(pvVar4,sel_selectCellWithTag_,pvVar5);
  }
  return;
}

*/
- (void)validateUI
{
    [super validateUI];
    if (_observedTextObjectAttributes != nil) {
        [_textColorWell setColor:[_observedTextObjectAttributes hyperTextColor]];
        [[_textStyleMatrix cellWithTag:1] setState:[_observedTextObjectAttributes isHyperBold]];
        [[_textStyleMatrix cellWithTag:2] setState:[_observedTextObjectAttributes isHyperItalic]];
        [[_textStyleMatrix cellWithTag:3] setState:[_observedTextObjectAttributes isHyperUnderlined]];
        BOOL outlineEnabled = [_observedTextObjectAttributes isHyperOutlineEnabled];
        [_outlineSwitch setState:outlineEnabled];
        [_outlineButton setHidden:!outlineEnabled];
        [_outlineSwitch setTitle:outlineEnabled ? @"" : [_outlineButton title]];
        [_alignmentMatrix selectCellWithTag:[_observedTextObjectAttributes hyperTextAlignment]];
        float spacing = [_observedTextObjectAttributes hyperSpaceBetweenCharacters];
        float rounded = roundf((spacing * 100.0f) / (float)[_genericFontAttributes hyperFontSize]);
        [_characterSpaceField setFloatValue:spacing == 0.0f ? _characterSpaceValue : rounded];
        [_characterSpaceStepper setFloatValue:spacing == 0.0f ? _characterSpaceValue : rounded];
    }
    if (_observedTextShadowAttributes != nil) {
        BOOL shadowEnabled = [_observedTextShadowAttributes isHyperShadowEnabled];
        [_shadowSwitch setState:shadowEnabled];
        [_shadowButton setHidden:!shadowEnabled];
        [_shadowSwitch setTitle:shadowEnabled ? @"" : [_shadowButton title]];
    }
    if (_observedTextLayoutAttributes != nil) {
        [_verticalAlignmentMatrix selectCellWithTag:[_observedTextLayoutAttributes textBlockVerticalAlignment]];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)setShadow:(id)aShadow
{
    NSInteger pvVar1;
    BOOL uVar2;
    id pvVar1_2;

    pvVar1 = [aShadow state];
    if (pvVar1 == 0) {
        pvVar1_2 = _observedTextShadowAttributes;
        uVar2 = 0;
    }
    else {
        if (pvVar1 != 0x1) {
            return;
        }
        pvVar1_2 = _observedTextShadowAttributes;
        uVar2 = 1;
    }
    [pvVar1_2 setHyperShadowEnabled:uVar2];
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

- (void)setOutline:(id)aOutline
{
    NSInteger pvVar1;
    BOOL uVar2;
    id pvVar1_2;

    pvVar1 = [aOutline state];
    if (pvVar1 == 0) {
        pvVar1_2 = _observedTextObjectAttributes;
        uVar2 = 0;
    }
    else {
        if (pvVar1 != 0x1) {
            return;
        }
        pvVar1_2 = _observedTextObjectAttributes;
        uVar2 = 1;
    }
    [pvVar1_2 setHyperOutlineEnabled:uVar2];
}

- (void)showOutlinePane
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSTextOutlineAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

- (void)enableSpaceCharactersControls:(BOOL)aControls
{
    [_characterSpaceStepper setEnabled:aControls];
    [_characterSpaceField setEnabled:aControls];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00173558 @ 00173558, 341 bytes * /

void FUN_00173558(HSTextObjectStyleAssistantPane *self,SEL _cmd,id characterSpacingValueChanged)

{
  float fVar1;
  id self_00;
  double dVar2;
  
  if (self->_observedTextObjectAttributes == (id)0x0) {
    return;
  }
  dVar2 = _objc_msgSend_fpret(characterSpacingValueChanged,sel_floatValue);
  fVar1 = (float)dVar2;
  self_00 = (self->super)._characterSpaceField;
  if (self_00 == characterSpacingValueChanged) {
    dVar2 = _objc_msgSend_fpret((self->super)._characterSpaceStepper,sel_minValue);
    if (((double)fVar1 < dVar2) ||
       (dVar2 = _objc_msgSend_fpret((self->super)._characterSpaceStepper,sel_maxValue),
       dVar2 < (double)fVar1)) goto LAB_00173638;
    self_00 = (self->super)._characterSpaceStepper;
  }
  else if ((self->super)._characterSpaceStepper != characterSpacingValueChanged) goto LAB_00173638;
  _objc_msgSend(self_00,sel_setFloatValue_,fVar1);
LAB_00173638:
  _objc_msgSend(self,sel_setCharacterSpaceValue_,fVar1);
  dVar2 = _objc_msgSend_fpret((self->super)._genericFontAttributes,sel_hyperFontSize);
  _objc_msgSend(self->_observedTextObjectAttributes,sel_setHyperSpaceBetweenCharacters_,
                (fVar1 * (float)dVar2) / 100.0);
  return;
}

*/
- (void)characterSpacingValueChanged:(id)aChanged
{
    if (_observedTextObjectAttributes == nil) {
        return;
    }
    float value = [aChanged floatValue];
    id target = nil;
    if (_characterSpaceField == aChanged) {
        if (!((double)value < [_characterSpaceStepper minValue] || [_characterSpaceStepper maxValue] < (double)value)) {
            target = _characterSpaceStepper;
        }
    } else if (_characterSpaceStepper == aChanged) {
        target = _characterSpaceField;
    }
    [target setFloatValue:value];
    [self setCharacterSpaceValue:value];
    [_observedTextObjectAttributes setHyperSpaceBetweenCharacters:(value * (float)[_genericFontAttributes hyperFontSize]) / 100.0f];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001736ad @ 001736ad, 376 bytes * /

void FUN_001736ad(HSTextObjectStyleAssistantPane *self,SEL _cmd,id characterSpacingEnabled)

{
  float fVar1;
  id pvVar2;
  uint uVar3;
  longdouble lVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  float fVar8;
  
  pvVar2 = _objc_msgSend(characterSpacingEnabled,sel_state);
  uVar3 = (uint)((char)pvVar2 == '\x01');
  _objc_msgSend(self,sel_enableSpaceCharactersControls_,uVar3);
  dVar7 = _objc_msgSend_fpret((self->super)._genericFontAttributes,sel_hyperFontSize);
  fVar8 = (float)dVar7;
  if ((char)pvVar2 == '\0') {
    dVar7 = _objc_msgSend_fpret(self->_observedTextObjectAttributes,sel_hyperSpaceBetweenCharacters,
                                uVar3,fVar8);
    lVar4 = (longdouble)_roundf(((float)dVar7 * 100.0) / fVar8);
    _objc_msgSend(self,sel_setCharacterSpaceValue_,(float)lVar4);
    pvVar2 = self->_observedTextObjectAttributes;
    fVar8 = 0.0;
  }
  else {
    fVar1 = (self->super)._characterSpaceValue;
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar5 = ABS(fVar1);
    }
    else {
      fVar5 = 1.0;
    }
    fVar6 = 0.0005;
    if (1.0 <= fVar5) {
      fVar6 = fVar5 * 0.0005;
    }
    if (ABS(fVar1) <= fVar6) {
      return;
    }
    pvVar2 = self->_observedTextObjectAttributes;
    dVar7 = _objc_msgSend_fpret(self,sel_characterSpaceValue,uVar3,fVar8);
    fVar8 = (fVar8 * (float)dVar7) / 100.0;
  }
  _objc_msgSend(pvVar2,sel_setHyperSpaceBetweenCharacters_,fVar8);
  return;
}

*/
- (void)characterSpacingEnabled:(id)aEnabled
{
    NSInteger state = [aEnabled state];
    [self enableSpaceCharactersControls:state == 1];
    float fontSize = (float)[_genericFontAttributes hyperFontSize];
    if (state == 0) {
        [self setCharacterSpaceValue:roundf(([_observedTextObjectAttributes hyperSpaceBetweenCharacters] * 100.0f) / fontSize)];
        [_observedTextObjectAttributes setHyperSpaceBetweenCharacters:0.0f];
    } else {
        float value = _characterSpaceValue;
        float scale = (value != 0.0f || value != value) ? fabsf(value) : 1.0f;
        float tolerance = 1.0f <= scale ? scale * 0.0005f : 0.0005f;
        if (fabsf(value) <= tolerance) {
            return;
        }
        [_observedTextObjectAttributes setHyperSpaceBetweenCharacters:(fontSize * [self characterSpaceValue]) / 100.0f];
    }
}

- (void)setVerticalAlignment:(id)aAlignment
{
    id self_00;

    self_00 = _observedTextLayoutAttributes;
    if (self_00 != nil) {
        [self_00 setTextBlockVerticalAlignment:[aAlignment selectedTag]];
    }
}

- (void)setAlign:(id)aAlign
{
    if (_observedTextObjectAttributes != nil) {
        [_observedTextObjectAttributes setHyperTextAlignment:[[aAlign selectedCell] tag]];
    }
}

- (void)setUnderline:(id)aUnderline
{
    id self_00;

    self_00 = _observedTextObjectAttributes;
    if (self_00 != nil) {
        [self_00 setHyperUnderlined:(unsigned int)([[aUnderline cellWithTag:3] state] == 0x1)];
    }
}

- (void)setItalic:(id)aItalic
{
    id self_00;

    self_00 = _observedTextObjectAttributes;
    if (self_00 != nil) {
        [self_00 setHyperItalic:(unsigned int)([[aItalic cellWithTag:2] state] == 0x1)];
    }
}

- (void)setBold:(id)aBold
{
    id self_00;

    self_00 = _observedTextObjectAttributes;
    if (self_00 != nil) {
        [self_00 setHyperBold:(unsigned int)([[aBold cellWithTag:1] state] == 0x1)];
    }
}

- (void)textColorChanged:(id)aChanged
{
    [_observedTextObjectAttributes setHyperTextColor:[aChanged color]];
}

- (void)readjustCharacterSpacingValue
{
    if (0.0 < (float)[_observedTextObjectAttributes hyperSpaceBetweenCharacters]) {
        [_observedTextObjectAttributes setHyperSpaceBetweenCharacters:((float)[_genericFontAttributes hyperFontSize] * (float)[self characterSpaceValue]) / 100.0]
        ;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_textColorWell setGradientSupportEnabled:YES];
    [_textColorWell setPatternSupportEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [self setObservedTextObjectAttributes:nil];
    [self setObservedTextLayoutAttributes:nil];
    [self setObservedTextShadowAttributes:nil];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [self setObservedTextObjectAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)]];
    [self setObservedTextLayoutAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSTextLayoutAttributes)]];
    [self setObservedTextShadowAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)]];
    [super viewWillAppear:aAppear];
}

- (void)setObservedTextShadowAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedTextShadowAttributes != aAttributes) {
        pvVar2 = [_observedTextShadowAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
        [_observedTextShadowAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedTextShadowAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    }
}

- (void)setObservedTextLayoutAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedTextLayoutAttributes != aAttributes) {
        pvVar2 = [_observedTextLayoutAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextLayoutAttributes)];
        [_observedTextLayoutAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedTextLayoutAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextLayoutAttributes) withPriority:-0.25];
    }
}

- (void)setObservedTextObjectAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedTextObjectAttributes != aAttributes) {
        pvVar2 = [_observedTextObjectAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes)];
        [_observedTextObjectAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedTextObjectAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes) withPriority:-0.25];
    }
}

- (void)dealloc
{
    int uVar1;
    id pvVar2;

    pvVar2 = [_observedTextObjectAttributes attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes)];
    [_observedTextObjectAttributes release];
    [[_observedTextLayoutAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextLayoutAttributes)];
    [_observedTextLayoutAttributes release];
    [[_observedTextShadowAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [_observedTextShadowAttributes release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"TextObjectStyleAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Style" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"style"]];
    }
    return self;
}

@end

