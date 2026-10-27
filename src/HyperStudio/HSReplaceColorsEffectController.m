#import "HSReplaceColorsEffectController.h"

@implementation HSReplaceColorsEffectController

/* i386 ivar offsets: _effectMatrix=0x24, _replaceColorWell=0x28, _withColorWell=0x2c, _replaceColorPickerButton=0x30, _withColorPickerButton=0x34, _toleranceSlider=0x38, _ignoreTransparencySwitch=0x3c */

+ (id)defaultWithColor
{
    return [NSColor redColor];
}

+ (id)defaultReplaceColor
{
    return [NSColor blueColor];
}

+ (id)createEffect
{
    return [[HSReplaceColorsEffect alloc] initWithName:@"ReplaceColors"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d2a6f @ 001d2a6f, 73 bytes * /

id FUN_001d2a6f(HSReplaceColorsEffectController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336258);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  return pvVar1;
}

*/
- (id)pickingCursor
{
    return [[HSCursor cursorNamed:HSEyeDropperCursor] cursor];
    return 0;
}

- (void)mouseDownInEffectImageAtColor:(id)aColor
{
    [self mouseDownInOriginalImageAtColor:aColor];
}

- (void)mouseDownInOriginalImageAtColor:(id)aColor
{
    id pvVar1_2;

    if ([_replaceColorPickerButton state] == 0x1) {
        [_replaceColorWell setColor:aColor];
        [self replaceColorDidChange:_replaceColorWell];
        [_replaceColorPickerButton setState:0];
        pvVar1_2 = [self pickingCursor];
    }
    else {
        if ([_withColorPickerButton state] != 0x1) {
            return;
        }
        [_withColorWell setColor:aColor];
        [self withColorDidChange:_withColorWell];
        [_withColorPickerButton setState:0];
        pvVar1_2 = [self pickingCursor];
    }
    [pvVar1_2 pop];
}

- (void)ignoreTransparencyDidChange:(id)aChange
{
    [self setTransparencyIgnored:(unsigned int)([aChange state] == 0x1)];
}

- (void)toleranceDidChange:(id)aChange
{
    [self setTolerance:(float)[aChange floatValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d2833 @ 001d2833, 145 bytes * /

void FUN_001d2833(HSReplaceColorsEffectController *self,SEL _cmd,id startWithColorPicking)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(startWithColorPicking,sel_state);
  if (pvVar1 == (id)0x1) {
    _objc_msgSend(self->_replaceColorPickerButton,sel_setState_,0);
    pvVar1 = _objc_msgSend(self,sel_pickingCursor);
    op = sel_push;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_pickingCursor);
    op = sel_pop;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)startWithColorPicking:(id)aPicking
{
    if ([aPicking state] == NSOnState) {
        [_replaceColorPickerButton setState:NSOffState];
        [[self pickingCursor] push];
    } else {
        [[self pickingCursor] pop];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d27a2 @ 001d27a2, 145 bytes * /

void FUN_001d27a2(HSReplaceColorsEffectController *self,SEL _cmd,id startReplaceColorPicking)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(startReplaceColorPicking,sel_state);
  if (pvVar1 == (id)0x1) {
    _objc_msgSend(self->_withColorPickerButton,sel_setState_,0);
    pvVar1 = _objc_msgSend(self,sel_pickingCursor);
    op = sel_push;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_pickingCursor);
    op = sel_pop;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)startReplaceColorPicking:(id)aPicking
{
    if ([aPicking state] == NSOnState) {
        [_withColorPickerButton setState:NSOffState];
        [[self pickingCursor] push];
    } else {
        [[self pickingCursor] pop];
    }
}

- (void)withColorDidChange:(id)aChange
{
    [self setWithColor:[aChange color]];
}

- (void)replaceColorDidChange:(id)aChange
{
    [self setReplaceColor:[aChange color]];
}

- (void)effectDidChange:(id)aChange
{
    [self setColorsExchanged:(unsigned int)([[aChange selectedCell] tag] != 0)];
}

- (void)applyChanges
{
    [super applyChanges];
    [[self pickingCursor] pop];
}

- (void)willUnmount
{
    [super willUnmount];
    [[self pickingCursor] pop];
}

- (void)willMount
{
    [super willMount];
    [_replaceColorPickerButton setState:0];
    [_withColorPickerButton setState:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d2d79 @ 001d2d79, 247 bytes * /

void FUN_001d2d79(HSReplaceColorsEffectController *self,SEL _cmd)

{
  HSReplaceColorsEffectController *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSEffectCompositeController_00353d50;
  _objc_msgSendSuper(&local_14,sel_didLoadNib);
  _objc_msgSend(self->_withColorWell,sel_setGradientSupportEnabled_,0);
  _objc_msgSend(self->_replaceColorWell,sel_setGradientSupportEnabled_,0);
  _objc_msgSend(self->_withColorWell,sel_setPatternSupportEnabled_,0);
  _objc_msgSend(self->_replaceColorWell,sel_setPatternSupportEnabled_,0);
  _objc_msgSend(self->_toleranceSlider,sel_setMinValue_,0,0);
  _objc_msgSend(self->_toleranceSlider,sel_setMaxValue_,0,0x3ff00000);
  return;
}

*/
- (void)didLoadNib
{
    [super didLoadNib];
    [_withColorWell setGradientSupportEnabled:NO];
    [_replaceColorWell setGradientSupportEnabled:NO];
    [_withColorWell setPatternSupportEnabled:NO];
    [_replaceColorWell setPatternSupportEnabled:NO];
    [_toleranceSlider setMinValue:0.0];
    [_toleranceSlider setMaxValue:1.0];
}

- (void)revertSettingsToDefault
{
    [[self effect] setDefaults];
    [_toleranceSlider setFloatValue:(float)[self tolerance]];
    [_ignoreTransparencySwitch setState:0];
    [_replaceColorWell setColor:[[self class] defaultReplaceColor]];
    [_withColorWell setColor:[[self class] defaultWithColor]];
    [self replaceColorDidChange:_replaceColorWell];
    [self withColorDidChange:_withColorWell];
    [_effectMatrix selectCellWithTag:(unsigned int)([self isColorsExchanged])];
    [self update];
}

- (void)setColorsExchanged:(BOOL)aExchanged
{
    [[self effect] setValue:[NSNumber numberWithBool:(unsigned int)aExchanged] forKey:HSReplaceColorsExchangeColorsKey];
    [self update];
}

- (BOOL)isColorsExchanged
{
    return (BOOL)[[[self effect] valueForKey:HSReplaceColorsExchangeColorsKey] boolValue];
}

- (void)setWithColor:(id)aColor
{
    [[self effect] setTargetColor:aColor];
    [self update];
}

- (void)setReplaceColor:(id)aColor
{
    [[self effect] setSourceColor:aColor];
    [self update];
}

- (void)setTransparencyIgnored:(BOOL)aIgnored
{
    [[self effect] setValue:[NSNumber numberWithBool:(unsigned int)aIgnored] forKey:HSReplaceColorsIgnoreAlphaKey];
    [self update];
}

- (BOOL)isTransparencyIgnored
{
    return (BOOL)[[[self effect] valueForKey:HSReplaceColorsIgnoreAlphaKey] boolValue];
}

- (void)setTolerance:(CGFloat)aTolerance
{
    [[self effect] setTolerance:(double)(1.0 - aTolerance)];
    [self update];
}

- (CGFloat)tolerance
{
    return 1.0 - (float)[[[self effect] valueForKey:HSReplaceColorsToleranceKey] floatValue];
}

- (id)undoActionName
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Replace Colors" value:@"" table:@"UndoManager"];
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"ApplyGraphicEffect" value:@"" table:@"UndoManager"], pvVar1_2];
}

- (id)nibName
{
    return @"ReplaceColorsEffect";
}

@end

