#import "HSGradientPicker.h"

static HSGradientPicker *sSharedGradientPicker = nil;

@implementation HSGradientPicker

/* i386 ivar offsets: _startColorController=0x1c, _endColorController=0x20, _gradientStartColor=0x24, _gradientEndColor=0x28, _topColorTextFiled=0x2c, _bottomColorTextFiled=0x30, _matrix=0x34 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00141845 @ 00141845, 224 bytes * /

id FUN_00141845(id self,SEL _cmd,NSZone *allocWithZone)

{
  bool bVar1;
  int iVar2;
  id unaff_EBX;
  id local_7c;
  undefined *local_78;
  int local_74 [23];
  NSZone *local_18;
  id local_14;
  
  local_14 = self;
  local_18 = allocWithZone;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  if (iVar2 == 0) {
    if (DAT_00342954 == (id)0x0) {
      local_7c = local_14;
      local_78 = PTR_s_HSColorPicker_0035a7a0;
      unaff_EBX = _objc_msgSendSuper(&local_7c,sel_allocWithZone_,local_18);
      iVar2 = 0;
      bVar1 = false;
      DAT_00342954 = unaff_EBX;
    }
    else {
      bVar1 = true;
      iVar2 = 0;
      unaff_EBX = (id)0x0;
    }
  }
  else {
    iVar2 = _objc_exception_extract(local_74);
    if (iVar2 != 0) {
      bVar1 = true;
      goto LAB_001418fa;
    }
    bVar1 = true;
    unaff_EBX = (id)0x0;
  }
  _objc_exception_try_exit(local_74);
LAB_001418fa:
  _objc_sync_exit(self);
  if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar2);
  }
  if (bVar1) {
    unaff_EBX = (id)0x0;
  }
  return unaff_EBX;
}

*/
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedGradientPicker == nil) {
            sSharedGradientPicker = [super allocWithZone:aZone];
            return sSharedGradientPicker;
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00141925 @ 00141925, 175 bytes * /

id FUN_00141925(id self,SEL _cmd)

{
  int iVar1;
  id self_00;
  int local_6c [22];
  id local_14;
  
  local_14 = self;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    if (DAT_00342954 == (id)0x0) {
      self_00 = _objc_msgSend(local_14,sel_alloc);
      _objc_msgSend(self_00,sel_init);
    }
    iVar1 = 0;
  }
  else {
    iVar1 = _objc_exception_extract(local_6c);
    if (iVar1 != 0) goto LAB_001419ad;
  }
  _objc_exception_try_exit(local_6c);
LAB_001419ad:
  _objc_sync_exit(self);
  if (iVar1 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar1);
  }
  return DAT_00342954;
}

*/
+ (id)sharedGradienPicker
{
    @synchronized(self) {
        if (sSharedGradientPicker == nil) {
            [[self alloc] init];
        }
    }
    return sSharedGradientPicker;
}

- (void)gradientTypeChanged:(id)aChanged
{
    [self setGradientKindFromInterface:aChanged];
}

- (void)switchColors:(id)aColors
{
    id pvVar1_2;

    pvVar1_2 = [[self gradientStartColor] retain];
    [self setGradientStartColor:[self gradientEndColor]];
    [self setGradientEndColor:pvVar1_2];
    [self setGradientKindFromInterface:_matrix];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014133e @ 0014133e, 958 bytes * /

void FUN_0014133e(HSGradientPicker *self,SEL _cmd,id setGradientKindFromInterface)

{
  id pvVar1;
  id pvVar2;
  undefined **ppuVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(cls_HSColor,sel_new);
  _objc_msgSend(pvVar1,sel_setHyperClear_,0);
  pvVar2 = _objc_msgSend(self,sel_gradientStartColor);
  _objc_msgSend(pvVar1,sel_setHyperStartColor_,pvVar2);
  pvVar2 = _objc_msgSend(self,sel_gradientEndColor);
  _objc_msgSend(pvVar1,sel_setHyperEndColor_,pvVar2);
  pvVar2 = _objc_msgSend(setGradientKindFromInterface,sel_selectedRow);
  switch(pvVar2) {
  case (id)0x0:
    _objc_msgSend(pvVar1,sel_setKind_,0);
    _objc_msgSend(pvVar1,sel_setAngle_,0x43870000);
    ppuVar3 = &PTR_cfstr_grTop_003372dc;
    break;
  case (id)0x1:
    _objc_msgSend(pvVar1,sel_setKind_,0);
    _objc_msgSend(pvVar1,sel_setAngle_,0);
    ppuVar3 = &PTR_cfstr_grLeft_003372e4;
    break;
  case (id)0x2:
    uVar6 = 1;
    goto LAB_001414b0;
  case (id)0x3:
    uVar6 = 2;
LAB_001414b0:
    _objc_msgSend(pvVar1,sel_setKind_,uVar6);
switchD_001413fe_default:
    ppuVar3 = &PTR_cfstr_grInside_003372d4;
    break;
  default:
    goto switchD_001413fe_default;
  }
  self_00 = _objc_msgSend(cls_HSGradientColor,sel_gradientColorWithHSColor_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_colorPanel);
  pvVar4 = _objc_msgSend(pvVar2,sel_color);
  pvVar2 = self_00;
  pvVar5 = _objc_msgSend(pvVar4,sel_isEqual_,self_00);
  if ((char)pvVar5 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_colorPanel,pvVar2);
  }
  else {
    pvVar2 = _objc_msgSend(self_00,sel_isEqual_,pvVar4);
    if ((char)pvVar2 != '\0') goto LAB_0014160c;
    pvVar4 = _objc_msgSend(cls_NSColor,sel_whiteColor,pvVar4);
    pvVar2 = pvVar4;
    pvVar5 = _objc_msgSend(self_00,sel_isEqualTo_,pvVar4);
    if ((char)pvVar5 != '\0') {
      pvVar4 = _objc_msgSend(cls_NSColor,sel_blackColor,pvVar2);
    }
    pvVar2 = _objc_msgSend(self,sel_colorPanel,pvVar2);
    _objc_msgSend(pvVar2,sel_setColor_,pvVar4);
    pvVar2 = _objc_msgSend(self,sel_colorPanel);
  }
  _objc_msgSend(pvVar2,sel_setColor_,self_00);
  pvVar4 = self_00;
LAB_0014160c:
  _objc_msgSend(pvVar1,sel_release,pvVar4);
  pvVar1 = self->_topColorTextFiled;
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,*ppuVar3,&cfstr_empty,
                         &cfstr_Dialogs);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  pvVar1 = self->_bottomColorTextFiled;
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,ppuVar3[1],&cfstr_empty,
                         &cfstr_Dialogs);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)setGradientKindFromInterface:(id)aInterface
{
    HSColor *color = [HSColor new];
    [color setHyperClear:NO];
    [color setHyperStartColor:[self gradientStartColor]];
    [color setHyperEndColor:[self gradientEndColor]];
    NSString *topKey = @"grInside";
    NSString *bottomKey = @"grOutside";
    switch ([aInterface selectedRow]) {
        case 0:
        [color setKind:0];
        [color setAngle:270.0f];
        topKey = @"grTop";
        bottomKey = @"grBottom";
        break;
        case 1:
        [color setKind:0];
        [color setAngle:0.0f];
        topKey = @"grLeft";
        bottomKey = @"grRight";
        break;
        case 2:
        [color setKind:1];
        break;
        case 3:
        [color setKind:2];
        break;
        default:
        break;
    }
    id gradient = [HSGradientColor gradientColorWithHSColor:color];
    id panelColor = [[self colorPanel] color];
    if (![panelColor isEqual:gradient]) {
        [[self colorPanel] setColor:gradient];
    } else if (![gradient isEqual:panelColor]) {
        id other = panelColor;
        if ([gradient isEqualTo:[NSColor whiteColor]]) {
            other = [NSColor blackColor];
        }
        [[self colorPanel] setColor:other];
        [[self colorPanel] setColor:gradient];
    }
    [color release];
    [_topColorTextFiled setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:topKey value:@"" table:@"Dialogs"]];
    [_bottomColorTextFiled setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:bottomKey value:@"" table:@"Dialogs"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00141097 @ 00141097, 15 bytes * /

ulonglong FUN_00141097(HSGradientPicker *self,SEL _cmd)

{
  return 0x43b8000043650000;
}

*/
- (NSSize)minContentSize
{
    return NSMakeSize(229.0f, 368.0f);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00141088 @ 00141088, 15 bytes * /

ulonglong FUN_00141088(HSGradientPicker *self,SEL _cmd)

{
  return 0x43b8000043650000;
}

*/
- (NSSize)maxContentSize
{
    return NSMakeSize(229.0f, 368.0f);
}

- (void)colorDidChange:(id)aChange
{
    if (_endColorController == aChange) {
        [self setGradientEndColor:[aChange color]];
    }
    if (_startColorController == aChange) {
        [self setGradientStartColor:[aChange color]];
    }
    [self setGradientKindFromInterface:_matrix];
}

- (void)didLoadNib
{
    [_endColorController setTarget:self];
    [_startColorController setTarget:self];
    [_endColorController setAction:@selector(colorDidChange:)];
    [_startColorController setAction:@selector(colorDidChange:)];
    [_pickerView setMinSize:NSMakeSize(229.0, 368.0)];
    [_startColorController setColor:_gradientStartColor];
    [_endColorController setColor:_gradientEndColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001419d4 @ 001419d4, 663 bytes * /

void FUN_001419d4(HSGradientPicker *self,SEL _cmd,id setColor)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined **ppuVar4;
  double dVar5;
  SEL op;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(setColor,sel_hyperGradientColor);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self,sel_setGradientStartColor_,setColor);
    op = sel_setGradientEndColor_;
    goto LAB_00141c5e;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperHSColor);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperStartColor);
  _objc_msgSend(self,sel_setGradientStartColor_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperHSColor);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperEndColor);
  _objc_msgSend(self,sel_setGradientEndColor_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_hyperHSColor);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperKind);
  if (pvVar3 == (id)0x1) {
    pvVar1 = self->_matrix;
    uVar6 = 2;
LAB_00141ade:
    _objc_msgSend(pvVar1,sel_selectCellWithTag_,uVar6);
    ppuVar4 = &PTR_cfstr_grInside_003372d4;
  }
  else {
    if (pvVar3 == (id)0x2) {
      pvVar1 = self->_matrix;
      uVar6 = 3;
      goto LAB_00141ade;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperHSColor,pvVar2);
    dVar5 = _objc_msgSend_fpret(pvVar1,sel_hyperAngle);
    if (((float)dVar5 != 0.0) || (NAN((float)dVar5))) {
      uVar6 = 0;
      _objc_msgSend(self->_matrix,sel_selectCellWithTag_,0);
      ppuVar4 = &PTR_cfstr_grTop_003372dc;
    }
    else {
      uVar6 = 1;
      _objc_msgSend(self->_matrix,sel_selectCellWithTag_,1);
      ppuVar4 = &PTR_cfstr_grLeft_003372e4;
    }
  }
  pvVar1 = self->_topColorTextFiled;
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,uVar6);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,*ppuVar4,&cfstr_empty,
                         &cfstr_Dialogs);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  self = self->_bottomColorTextFiled;
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  setColor = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,ppuVar4[1],&cfstr_empty,
                           &cfstr_Dialogs);
  op = sel_setStringValue_;
LAB_00141c5e:
  _objc_msgSend(self,op,setColor);
  return;
}

*/
- (void)setColor:(id)aColor
{
    id gradient = [aColor hyperGradientColor];
    if (gradient == nil) {
        [self setGradientStartColor:aColor];
        [self setGradientEndColor:aColor];
        return;
    }
    [self setGradientStartColor:[[gradient hyperHSColor] hyperStartColor]];
    [self setGradientEndColor:[[gradient hyperHSColor] hyperEndColor]];
    NSString *topKey;
    NSString *bottomKey;
    NSInteger kind = [[gradient hyperHSColor] hyperKind];
    if (kind == 1) {
        [_matrix selectCellWithTag:2];
        topKey = @"grInside";
        bottomKey = @"grOutside";
    } else if (kind == 2) {
        [_matrix selectCellWithTag:3];
        topKey = @"grInside";
        bottomKey = @"grOutside";
    } else if ([[gradient hyperHSColor] hyperAngle] != 0.0f) {
        [_matrix selectCellWithTag:0];
        topKey = @"grTop";
        bottomKey = @"grBottom";
    } else {
        [_matrix selectCellWithTag:1];
        topKey = @"grLeft";
        bottomKey = @"grRight";
    }
    [_topColorTextFiled setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:topKey value:@"" table:@"Dialogs"]];
    [_bottomColorTextFiled setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:bottomKey value:@"" table:@"Dialogs"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00141c6b @ 00141c6b, 233 bytes * /

id FUN_00141c6b(HSGradientPicker *self,SEL _cmd)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id local_70;
  int local_6c [22];
  HSGradientPicker *local_14;
  
  local_14 = self;
  local_70 = (id)0x0;
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    local_70 = _objc_msgSend(local_14->_gradientEndColor,sel_patternImage);
  }
  else {
    iVar2 = _objc_exception_extract(local_6c);
    _objc_exception_try_enter(local_6c);
    iVar1 = __setjmp(local_6c);
    if (iVar1 == 0) {
      iVar1 = _objc_exception_match(cls_NSException,iVar2);
      if (iVar1 != 0) goto LAB_00141cee;
      _objc_exception_try_exit(local_6c);
    }
    else {
      iVar2 = _objc_exception_extract(local_6c);
    }
    if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar2);
    }
  }
LAB_00141cee:
  _objc_exception_try_exit(local_6c);
  if ((local_14->_gradientEndColor == (id)0x0) || (local_70 != (id)0x0)) {
    pvVar3 = _objc_msgSend(cls_NSColor,sel_blackColor);
  }
  else {
    pvVar3 = local_14->_gradientEndColor;
  }
  return pvVar3;
}

*/
- (id)gradientEndColor
{
    id patternImage = nil;
    @try {
        patternImage = [_gradientEndColor patternImage];
    }
    @catch (NSException *exception) {
    }
    if (_gradientEndColor == nil || patternImage != nil) {
        return [NSColor blackColor];
    }
    return _gradientEndColor;
}

- (void)setGradientEndColor:(id)aColor
{
    id pvVar1;

    if (_gradientEndColor != aColor) {
        [_gradientEndColor autorelease];
        pvVar1 = [aColor retain];
        _gradientEndColor = pvVar1;
        [_endColorController setColor:pvVar1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00141d54 @ 00141d54, 233 bytes * /

id FUN_00141d54(HSGradientPicker *self,SEL _cmd)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id local_70;
  int local_6c [22];
  HSGradientPicker *local_14;
  
  local_14 = self;
  local_70 = (id)0x0;
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    local_70 = _objc_msgSend(local_14->_gradientStartColor,sel_patternImage);
  }
  else {
    iVar2 = _objc_exception_extract(local_6c);
    _objc_exception_try_enter(local_6c);
    iVar1 = __setjmp(local_6c);
    if (iVar1 == 0) {
      iVar1 = _objc_exception_match(cls_NSException,iVar2);
      if (iVar1 != 0) goto LAB_00141dd7;
      _objc_exception_try_exit(local_6c);
    }
    else {
      iVar2 = _objc_exception_extract(local_6c);
    }
    if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar2);
    }
  }
LAB_00141dd7:
  _objc_exception_try_exit(local_6c);
  if ((local_14->_gradientStartColor == (id)0x0) || (local_70 != (id)0x0)) {
    pvVar3 = _objc_msgSend(cls_NSColor,sel_blackColor);
  }
  else {
    pvVar3 = local_14->_gradientStartColor;
  }
  return pvVar3;
}

*/
- (id)gradientStartColor
{
    id patternImage = nil;
    @try {
        patternImage = [_gradientStartColor patternImage];
    }
    @catch (NSException *exception) {
    }
    if (_gradientStartColor == nil || patternImage != nil) {
        return [NSColor blackColor];
    }
    return _gradientStartColor;
}

- (void)setGradientStartColor:(id)aColor
{
    id pvVar1;

    if (_gradientStartColor != aColor) {
        [_gradientStartColor autorelease];
        pvVar1 = [aColor retain];
        _gradientStartColor = pvVar1;
        [_startColorController setColor:pvVar1];
    }
}

- (id)nibName
{
    return @"HSGradientPicker";
}

- (id)imageName
{
    return @"GradientPicker";
}

- (NSInteger)currentMode
{
    return 8;
}

- (BOOL)supportsMode:(NSInteger)aMode
{
    return aMode == 4 || aMode == 8;
}

- (id)buttonToolTip
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Gradient" value:@"" table:@"ColorPickers"];
}

- (void)dealloc
{
    [_gradientStartColor release];
    [_gradientEndColor release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{

}

- (NSUInteger)retainCount
{
    return 0xffffffff;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end

