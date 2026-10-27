#import "HSStopWatchView.h"

@implementation HSStopWatchView

/* i386 ivar offsets: _seconds=0x50, _backgroundClockImage=0x54, _colonClockImage=0x58, _digitImageSize=0x5c, _accessibilityRoleDescriptionString=0x64 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069747 @ 00069747, 237 bytes * /

ulonglong FUN_00069747(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  undefined4 extraout_EDX;
  undefined4 uVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  self_00 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
  pcVar4 = &cfstr_tiff;
  pvVar2 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_BackgrondClock,&cfstr_tiff);
  self_01 = _objc_msgSend(pvVar1,sel_initWithContentsOfFile_,pvVar2);
  pvVar1 = *(id *)PTR_0033607c;
  uVar3 = *(undefined4 *)(PTR_0033607c + 4);
  if (self_01 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_01,sel_size,pvVar2,pcVar4);
    _objc_msgSend(self_01,sel_release);
    uVar3 = extraout_EDX;
  }
  return CONCAT44(uVar3,pvVar1);
}

*/
+ (NSSize)stopWatchViewSize
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"BackgrondClock" ofType:@"tiff"]];
    NSSize size = NSZeroSize;
    if (image != nil) {
        size = [image size];
        [image release];
    }
    return size;
}

- (id)accessibilityFocusedUIElement
{
    return self;
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (BOOL)accessibilityIsAttributeSettable:(id)aSettable
{
    return (BOOL)[super accessibilityIsAttributeSettable:aSettable];
}

- (id)accessibilityAttributeNames
{
    return [[super accessibilityAttributeNames] arrayByAddingObject:NSAccessibilityValueAttribute];
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069889 @ 00069889, 387 bytes * /

id FUN_00069889(HSStopWatchView *self,SEL _cmd,id accessibilityAttributeValue)

{
  id pvVar1;
  undefined *self_00;
  cfstringStruct *pcVar2;
  SEL op;
  undefined4 uVar3;
  cfstringStruct *pcVar4;
  HSStopWatchView *local_1c;
  undefined *local_18;
  
  uVar3 = *(undefined4 *)PTR_00336370;
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
  if ((char)pvVar1 == '\0') {
    uVar3 = *(undefined4 *)PTR_00336374;
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
    if ((char)pvVar1 == '\0') {
      uVar3 = *(undefined4 *)PTR_003363b4;
      pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
      self_00 = cls_NSString;
      if ((char)pvVar1 == '\0') {
        local_1c = self;
        local_18 = PTR_s_NSView_0034e710;
        pvVar1 = _objc_msgSendSuper(&local_1c,sel_accessibilityAttributeValue_,
                                    accessibilityAttributeValue);
        return pvVar1;
      }
      pvVar1 = _objc_msgSend(self,sel_secondsForDigit,uVar3);
      pcVar2 = _objc_msgSend(self,sel_minutesForDigit);
      pcVar4 = &cfstr__d__d;
      op = sel_stringWithFormat_;
      goto LAB_00069900;
    }
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar3);
    pcVar4 = self->_accessibilityRoleDescriptionString;
  }
  else {
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar3);
    pcVar4 = *(cfstringStruct **)PTR_003363b8;
  }
  pcVar2 = &cfstr_empty;
  pvVar1 = (id)0x0;
  op = sel_localizedStringForKey_value_table_;
LAB_00069900:
  pvVar1 = _objc_msgSend(self_00,op,pcVar4,pcVar2,pvVar1);
  return pvVar1;
}

*/
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:NSAccessibilityValueIndicatorRole value:@"" table:nil];
    }
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:_accessibilityRoleDescriptionString value:@"" table:nil];
    }
    if ([aValue isEqualToString:NSAccessibilityValueAttribute]) {
        return [NSString stringWithFormat:@"%d:%d", (int)[self minutesForDigit], (int)[self secondsForDigit]];
    }
    return [super accessibilityAttributeValue:aValue];
}

- (id)accessibilityRoleDescriptionString
{
    return [[_accessibilityRoleDescriptionString retain] autorelease];
}

- (void)setAccessibilityRoleDescriptionString:(id)aString
{
    if (_accessibilityRoleDescriptionString != aString) {
        [_accessibilityRoleDescriptionString release];
        _accessibilityRoleDescriptionString = [aString copy];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069a94 @ 00069a94, 286 bytes * /

void FUN_00069a94(HSStopWatchView *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined8 local_1c;
  undefined4 local_14;
  undefined4 uStack_10;
  
  _objc_msgSend_stret(&local_1c,self,sel_frame);
  if (self->_backgroundClockImage != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_stopWatchViewSize);
    cVar1 = _NSEqualSizes(pvVar2,extraout_EDX,local_14,uStack_10);
    if (cVar1 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_class);
      pvVar2 = _objc_msgSend(pvVar2,sel_stopWatchViewSize);
      _objc_msgSend(self,sel_setFrameSize_,pvVar2,extraout_EDX_00);
      _objc_msgSend(self,sel_setNeedsDisplay_,1);
      pvVar2 = _objc_msgSend(self,sel_superview);
      _objc_msgSend(pvVar2,sel_setNeedsDisplayInRect_,local_1c,CONCAT44(uStack_10,local_14));
    }
  }
  return;
}

*/
- (void)sizeToFit
{
    NSRect frame = [self frame];
    if (_backgroundClockImage != nil) {
        NSSize size = [[self class] stopWatchViewSize];
        if (!NSEqualSizes(size, frame.size)) {
            [self setFrameSize:size];
            [self setNeedsDisplay:YES];
            [[self superview] setNeedsDisplayInRect:frame];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069bb2 @ 00069bb2, 165 bytes * /

id FUN_00069bb2(HSStopWatchView *self,SEL _cmd,uint digitImageNameAtIndex)

{
  id pvVar1;
  SEL op;
  
  if (((self->_seconds < 0.0) || (3600.0 <= self->_seconds)) || (3 < digitImageNameAtIndex)) {
    return &cfstr_NoDigit;
  }
  switch(digitImageNameAtIndex) {
  case 0:
    op = sel_highDigitOfMinutes;
    break;
  case 1:
    op = sel_lowDigitOfMinutes;
    break;
  case 2:
    op = sel_highDigitOfSeconds;
    break;
  case 3:
    op = sel_lowDigitOfSeconds;
    break;
  default:
    pvVar1 = (id)0x0;
    goto LAB_00069c23;
  }
  pvVar1 = _objc_msgSend(self,op);
LAB_00069c23:
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_WatchDigit_d,pvVar1);
  return pvVar1;
}

*/
- (id)digitImageNameAtIndex:(NSUInteger)aIndex
{
    if (_seconds < 0.0 || 3600.0 <= _seconds || aIndex > 3) {
        return @"NoDigit";
    }
    NSUInteger digit = 0;
    switch (aIndex) {
        case 0: digit = [self highDigitOfMinutes]; break;
        case 1: digit = [self lowDigitOfMinutes]; break;
        case 2: digit = [self highDigitOfSeconds]; break;
        case 3: digit = [self lowDigitOfSeconds]; break;
    }
    return [NSString stringWithFormat:@"WatchDigit%d", (int)digit];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069c68 @ 00069c68, 56 bytes * /

uint FUN_00069c68(HSStopWatchView *self,SEL _cmd)

{
  div_t *__return_storage_ptr__;
  uint extraout_EDX;
  int unaff_EBP;
  
  __return_storage_ptr__ = _objc_msgSend(self,sel_secondsForDigit);
  _div(__return_storage_ptr__,10,unaff_EBP);
  return extraout_EDX;
}

*/
- (NSUInteger)lowDigitOfSeconds
{
    return [self secondsForDigit] % 10;
}

- (NSUInteger)highDigitOfSeconds
{
    return (unsigned int)[self secondsForDigit] / 10;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069cd4 @ 00069cd4, 56 bytes * /

uint FUN_00069cd4(HSStopWatchView *self,SEL _cmd)

{
  div_t *__return_storage_ptr__;
  uint extraout_EDX;
  int unaff_EBP;
  
  __return_storage_ptr__ = _objc_msgSend(self,sel_minutesForDigit);
  _div(__return_storage_ptr__,10,unaff_EBP);
  return extraout_EDX;
}

*/
- (NSUInteger)lowDigitOfMinutes
{
    return [self minutesForDigit] % 10;
}

- (NSUInteger)highDigitOfMinutes
{
    return (unsigned int)[self minutesForDigit] / 10;
}

- (NSUInteger)minutesForDigit
{
    return (NSUInteger)(_seconds / 60.0) % 60;
}

- (NSUInteger)secondsForDigit
{
    return (unsigned int)_seconds % 0x3c;
}

- (CGFloat)clockTimeInSeconds
{
    return _seconds;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069d40 @ 00069d40, 204 bytes * /

void FUN_00069d40(HSStopWatchView *self,SEL _cmd,float setClockTimeInSeconds)

{
  float fVar1;
  float fVar2;
  longdouble lVar3;
  longdouble lVar4;
  float fVar5;
  float fVar6;
  
  lVar3 = (longdouble)_floorf(setClockTimeInSeconds);
  lVar4 = (longdouble)_floorf(self->_seconds);
  fVar1 = (float)lVar4;
  fVar2 = (float)lVar3;
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar5 = ABS(fVar1);
  }
  else {
    fVar5 = 1.0;
  }
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar6 = ABS(fVar2);
  }
  else {
    fVar6 = 1.0;
  }
  self->_seconds = setClockTimeInSeconds;
  if (fVar6 <= fVar5) {
    fVar6 = fVar5;
  }
  if (fVar6 * 0.0005 < ABS(fVar1 - fVar2)) {
    _objc_msgSend(self,sel_setNeedsDisplay_,1);
  }
  return;
}

*/
- (void)setClockTimeInSeconds:(CGFloat)aSeconds
{
    float newFloor = floorf(aSeconds);
    float oldFloor = floorf(_seconds);
    float oldScale = oldFloor != 0.0f ? fabsf(oldFloor) : 1.0f;
    float newScale = newFloor != 0.0f ? fabsf(newFloor) : 1.0f;
    _seconds = aSeconds;
    if (MAX(newScale, oldScale) * 0.0005f < fabsf(oldFloor - newFloor)) {
        [self setNeedsDisplay:YES];
    }
}

- (void)drawDigitWithName:(id)aName toPoint:(NSPoint)aPoint
{
    id pvVar1_2;

    pvVar1_2 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:aName ofType:@"tiff"]];
    if (pvVar1_2 != nil) {
        [pvVar1_2 compositeToPoint:aPoint operation:2];
        [pvVar1_2 release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00069eef @ 00069eef, 696 bytes * /

void FUN_00069eef(HSStopWatchView *self,SEL _cmd,NSRect drawRect)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  uint uVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  undefined8 uVar8;
  undefined4 uVar10;
  undefined8 uVar9;
  undefined1 local_34 [8];
  float local_2c;
  undefined1 local_24 [12];
  float local_18;
  
  if ((self->_backgroundClockImage != (id)0x0) && (self->_colonClockImage != (id)0x0)) {
    _objc_msgSend_stret(local_34,self,sel_bounds);
    pvVar2 = _objc_msgSend(self->_backgroundClockImage,sel_size);
    if ((float)pvVar2 <= local_2c) {
      _objc_msgSend_stret(local_24,self,sel_bounds);
      _objc_msgSend(self->_backgroundClockImage,sel_size);
      if (extraout_EDX <= local_18) {
        fVar1 = *(float *)PTR_00336078;
        fVar5 = *(float *)(PTR_00336078 + 4);
        uVar9 = *(undefined8 *)PTR_00336078;
        pvVar2 = _objc_msgSend(self->_backgroundClockImage,sel_size);
        uVar8 = CONCAT44(extraout_EDX_00,pvVar2);
        _objc_msgSend(self->_backgroundClockImage,sel_drawInRect_fromRect_operation_fraction_,uVar9,
                      uVar8,uVar9,uVar8,2,0x3f800000);
        uVar10 = (undefined4)((ulonglong)uVar8 >> 0x20);
        _objc_msgSend(self->_colonClockImage,sel_size);
        fVar5 = extraout_EDX_01 + fVar5;
        pvVar3 = _objc_msgSend(self->_colonClockImage,sel_size);
        fVar6 = (float)pvVar3 * -0.5 + (float)pvVar2 * 0.5 + fVar1;
        uVar8 = CONCAT44(fVar5,fVar6);
        uVar9 = CONCAT44(uVar10,2);
        _objc_msgSend(self->_colonClockImage,sel_compositeToPoint_operation_,fVar6,fVar5,2);
        fVar1 = (self->_digitImageSize).width;
        fVar7 = fVar1 * -2.0;
        uVar4 = 0;
        while( true ) {
          if (uVar4 < 2) {
            pvVar2 = (id)0x0;
          }
          else {
            pvVar2 = _objc_msgSend(self->_colonClockImage,sel_size,uVar8,uVar9);
          }
          pvVar3 = _objc_msgSend(self,sel_digitImageNameAtIndex_,uVar4,
                                 (int)((ulonglong)uVar8 >> 0x20),uVar9);
          uVar9 = CONCAT44((int)((ulonglong)uVar9 >> 0x20),fVar5);
          uVar8 = CONCAT44((float)((double)((ulonglong)uVar4 | 0x4330000000000000) -
                                  4503599627370496.0) * fVar1 + fVar7 + fVar6 + (float)pvVar2,pvVar3
                          );
          _objc_msgSend(self,sel_drawDigitWithName_toPoint_);
          if (uVar4 == 3) break;
          uVar4 = uVar4 + 1;
          fVar1 = (self->_digitImageSize).width;
        }
      }
    }
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    if (_backgroundClockImage != nil && _colonClockImage != nil) {
        NSRect bounds = [self bounds];
        NSSize backgroundSize = [_backgroundClockImage size];
        if (backgroundSize.width <= bounds.size.width && backgroundSize.height <= bounds.size.height) {
            NSRect imageRect = NSMakeRect(0.0, 0.0, backgroundSize.width, backgroundSize.height);
            [_backgroundClockImage drawInRect:imageRect fromRect:imageRect operation:NSCompositingOperationSourceOver fraction:1.0];
            NSSize colonSize = [_colonClockImage size];
            CGFloat y = colonSize.height + 0.0;
            CGFloat colonX = backgroundSize.width * 0.5 - colonSize.width * 0.5 + 0.0;
            [_colonClockImage compositeToPoint:NSMakePoint(colonX, y) operation:NSCompositingOperationSourceOver];
            for (NSUInteger i = 0; i < 4; i++) {
                CGFloat offset = i < 2 ? 0.0 : colonSize.width;
                [self drawDigitWithName:[self digitImageNameAtIndex:i] toPoint:NSMakePoint((CGFloat)i * _digitImageSize.width + _digitImageSize.width * -2.0 + colonX + offset, y)];
            }
        }
    }
}

- (void)dealloc
{
    [_backgroundClockImage release];
    [_colonClockImage release];
    [_accessibilityRoleDescriptionString release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006a21f @ 0006a21f, 610 bytes * /

id FUN_0006a21f(HSStopWatchView *self,SEL _cmd,NSRect initWithFrame)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar5;
  undefined8 uVar4;
  HSStopWatchView *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSView_0034e710;
  self_00 = _objc_msgSendSuper(&local_1c,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size)
  ;
  if (self_00 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self_00,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,&cfstr_BackgrondClock,&cfstr_tiff);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pvVar3);
    *(id *)((int)self_00 + 0x54) = pvVar2;
    pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self_00,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,&cfstr_Colon,&cfstr_tiff);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pvVar3);
    *(id *)((int)self_00 + 0x58) = pvVar2;
    pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self_00,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pcVar5 = &cfstr_tiff;
    pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,&cfstr_WatchDigit0,&cfstr_tiff);
    uVar4 = CONCAT44(pcVar5,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pvVar3);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar2,sel_size,uVar4);
      *(id *)((int)self_00 + 0x5c) = pvVar3;
      *(undefined4 *)((int)self_00 + 0x60) = extraout_EDX;
      _objc_msgSend(pvVar2,sel_release);
    }
    pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithString_,&cfstr_Stop_watch_time);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    *(id *)((int)self_00 + 100) = pvVar2;
  }
  return self_00;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _backgroundClockImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"BackgrondClock" ofType:@"tiff"]];
        _colonClockImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Colon" ofType:@"tiff"]];
        NSImage *digit = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"WatchDigit0" ofType:@"tiff"]];
        if (digit != nil) {
            _digitImageSize = [digit size];
            [digit release];
        }
        _accessibilityRoleDescriptionString = [[NSString stringWithString:@"Stop watch time"] retain];
    }
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

@end

