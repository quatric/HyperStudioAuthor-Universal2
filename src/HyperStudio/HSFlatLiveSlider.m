#import "HSFlatLiveSlider.h"

@implementation HSFlatLiveSlider

/* i386 ivar offsets: _progress=0x5c, _changeDuration=0x60, _cancelDuration=0x68, _sliderAnimation=0x70, _texturesCache=0x74, _state=0x78, _isTrackingMouse=0x7c */

+ (Class)cellClass
{
    return [NSActionCell class];
}

- (NSInteger)tag
{
    return (int)[super tag];
}

- (SEL)action
{
    return [super action];
}

- (void)setCancelDuration:(double)aDuration
{
    if (_cancelDuration != aDuration) {
        _cancelDuration = aDuration;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015037e @ 0015037e, 67 bytes * /

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address * /

double FUN_0015037e(HSFlatLiveSlider *self,SEL _cmd)

{
  double dVar1;
  longdouble lVar2;
  
  dVar1 = self->_cancelDuration;
  if ((dVar1 != 0.0) || (NAN(dVar1))) {
    lVar2 = (longdouble)dVar1;
  }
  else {
    *(undefined4 *)((int)&self->_cancelDuration + 4) = 0x3fb99999;
    *(undefined4 *)&self->_cancelDuration = 0x9999999a;
    lVar2 = _DAT_00335510;
  }
  return (double)lVar2;
}

*/
- (double)cancelDuration
{
    if (_cancelDuration == 0.0) {
        _cancelDuration = 0.1;
        return 0.1;
    }
    return _cancelDuration;
}

- (void)setChangeDuration:(double)aDuration
{
    if (_changeDuration != aDuration) {
        _changeDuration = aDuration;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00150316 @ 00150316, 67 bytes * /

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address * /

double FUN_00150316(HSFlatLiveSlider *self,SEL _cmd)

{
  double dVar1;
  longdouble lVar2;
  
  dVar1 = self->_changeDuration;
  if ((dVar1 != 0.0) || (NAN(dVar1))) {
    lVar2 = (longdouble)dVar1;
  }
  else {
    *(undefined4 *)((int)&self->_changeDuration + 4) = 0x3fb99999;
    *(undefined4 *)&self->_changeDuration = 0x9999999a;
    lVar2 = _DAT_00335500;
  }
  return (double)lVar2;
}

*/
- (double)changeDuration
{
    if (_changeDuration == 0.0) {
        _changeDuration = 0.1;
        return 0.1;
    }
    return _changeDuration;
}

- (void)animationDidEnd:(id)aEnd
{
    id pvVar1_2;

    [self invalidateAnimation];
    [self setProgress:(float)[self progressForState:[self state]]];
    pvVar1_2 = [self target];
    [self sendAction:[self action] to:pvVar1_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015076b @ 0015076b, 443 bytes * /

void FUN_0015076b(HSFlatLiveSlider *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  float fVar3;
  float fVar4;
  double dVar5;
  undefined8 uVar6;
  undefined8 local_1c;
  undefined8 local_14;
  
  uVar6 = CONCAT44(sel_bounds,self);
  _objc_msgSend_stret(&local_1c,self,sel_bounds);
  dVar5 = _objc_msgSend_fpret(self,sel_progress);
  fVar1 = (float)dVar5;
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar3 = ABS(fVar1);
  }
  else {
    fVar3 = 1.0;
  }
  fVar4 = 1.0;
  if (1.0 <= fVar3) {
    fVar4 = fVar3;
  }
  if (fVar1 < fVar4 * -0.0005 + 1.0) {
    pvVar2 = _objc_msgSend(self,sel_flatBackgroundImage);
    uVar6 = local_1c;
    _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_,local_1c,local_14,
                  *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),2,0x3f800000);
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar3 = ABS(fVar1);
  }
  else {
    fVar3 = 1.0;
  }
  fVar4 = 0.0005;
  if (1.0 <= fVar3) {
    fVar4 = fVar3 * 0.0005;
  }
  if (0.0 - fVar4 <= fVar1) {
    pvVar2 = _objc_msgSend(self,sel_liveBackgroundImage,uVar6);
    _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_,local_1c,local_14,
                  *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),2,fVar1);
  }
  return;
}

*/
- (void)drawBackground
{
    NSRect bounds = [self bounds];
    float progress = (float)[self progress];
    float a = progress != 0.0 ? fabsf(progress) : 1.0;
    float m = 1.0 <= a ? a : 1.0;
    if (progress < m * -0.0005 + 1.0) {
        [[self flatBackgroundImage] drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    float tol = 0.0005;
    if (1.0 <= a) {
        tol = a * 0.0005;
    }
    if (0.0 - tol <= progress) {
        [[self liveBackgroundImage] drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:progress];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00150926 @ 00150926, 719 bytes * /

void FUN_00150926(HSFlatLiveSlider *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  SEL op;
  float fVar3;
  float fVar4;
  float fVar5;
  double dVar6;
  double dVar7;
  ulonglong uVar8;
  undefined8 in_stack_ffffff6c;
  undefined4 uVar10;
  undefined8 uVar9;
  undefined8 uVar11;
  float fVar12;
  float local_2c [2];
  float local_24;
  undefined1 local_1c [12];
  undefined4 local_10;
  
  uVar10 = (undefined4)((ulonglong)in_stack_ffffff6c >> 0x20);
  dVar6 = _objc_msgSend_fpret(self,sel_progress);
  dVar7 = _objc_msgSend_fpret(self,sel_knobWidth);
  uVar9 = CONCAT44(uVar10,sel_bounds);
  _objc_msgSend_stret(local_2c,self,sel_bounds);
  uVar8 = CONCAT44(sel_bounds,self);
  fVar1 = (float)dVar7;
  fVar12 = (float)dVar6;
  fVar3 = ((local_2c[0] + local_24) - fVar1) * fVar12;
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  pvVar2 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar2 == '\0') {
    op = sel_liveSliderImage;
    if (self->_state == 0) {
      op = sel_flatSliderImage;
    }
    pvVar2 = _objc_msgSend(self,op);
    uVar9 = *(undefined8 *)PTR_00336078;
    uVar11 = *(undefined8 *)(PTR_00336078 + 8);
    fVar12 = 0.5;
  }
  else {
    if ((fVar12 != 0.0) || (NAN(fVar12))) {
      fVar4 = ABS(fVar12);
    }
    else {
      fVar4 = 1.0;
    }
    fVar5 = 1.0;
    if (1.0 <= fVar4) {
      fVar5 = fVar4;
    }
    if (fVar12 < fVar5 * -0.0005 + 1.0) {
      pvVar2 = _objc_msgSend(self,sel_flatSliderImage);
      uVar8 = (ulonglong)(uint)fVar3;
      uVar9 = CONCAT44(local_10,fVar1);
      _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_,uVar8,uVar9,
                    *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),2,0x3f800000);
    }
    if ((fVar12 != 0.0) || (NAN(fVar12))) {
      fVar4 = ABS(fVar12);
    }
    else {
      fVar4 = 1.0;
    }
    fVar5 = 0.0005;
    if (1.0 <= fVar4) {
      fVar5 = fVar4 * 0.0005;
    }
    if (fVar12 < 0.0 - fVar5) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_liveSliderImage,uVar8,uVar9);
    uVar9 = *(undefined8 *)PTR_00336078;
    uVar11 = *(undefined8 *)(PTR_00336078 + 8);
  }
  _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_,(ulonglong)(uint)fVar3,
                CONCAT44(local_10,fVar1),uVar9,uVar11,2,fVar12);
  return;
}

*/
- (void)drawSlider
{
    float progress = (float)[self progress];
    float knob = (float)[self knobWidth];
    NSRect bounds = [self bounds];
    float x = ((bounds.origin.x + bounds.size.width) - knob) * progress;
    NSRect rect = NSMakeRect(x, 0.0, knob, [self bounds].size.height);
    id image;
    float fraction;
    if (![self isEnabled]) {
        image = _state == 0 ? [self flatSliderImage] : [self liveSliderImage];
        fraction = 0.5;
    }
    else {
        float a = progress != 0.0 ? fabsf(progress) : 1.0;
        float m = 1.0 <= a ? a : 1.0;
        if (progress < m * -0.0005 + 1.0) {
            [[self flatSliderImage] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        }
        float tol = 0.0005;
        if (1.0 <= a) {
            tol = a * 0.0005;
        }
        if (progress < 0.0 - tol) {
            return;
        }
        image = [self liveSliderImage];
        fraction = progress;
    }
    [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:fraction];
}

- (void)drawRect:(NSRect)aRect
{
    [self drawBackground];
    [self drawSlider];
}

- (id)liveSliderImage
{
    return [NSImage imageNamed:@"live_head"];
}

- (id)flatSliderImage
{
    return [NSImage imageNamed:@"flat_head"];
}

- (id)liveBackgroundImage
{
    return [NSImage imageNamed:@"live_back"];
}

- (id)flatBackgroundImage
{
    return [NSImage imageNamed:@"flat_back"];
}

- (void)invalidateAnimation
{
    [_sliderAnimation release];
    _sliderAnimation = nil;
}

- (CGFloat)progress
{
    return _progress;
}

- (void)setProgress:(CGFloat)aProgress
{
    _progress = aProgress;
}

- (BOOL)isAnimationInProgress
{
    return (BOOL)[_sliderAnimation isAnimating];
}

- (void)animateWithProgress:(CGFloat)aProgress
{
    float fVar1;
    float fVar2;
    float fVar3;

    fVar1 = (float)[self progress];
    fVar2 = aProgress != 0.0 ? fabs(aProgress) : 1.0;
    fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    if (fVar3 <= fVar2) {
        fVar3 = fVar2;
    }
    if (fVar3 * 0.0005 < fabs(aProgress - fVar1)) {
        [self setProgress:aProgress];
        [self setNeedsDisplay];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00150cb5 @ 00150cb5, 853 bytes * /

void FUN_00150cb5(HSFlatLiveSlider *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  dword *pdVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float fVar4;
  float fVar5;
  dword *pdVar6;
  float fVar7;
  double dVar8;
  double dVar9;
  SEL op;
  undefined4 uVar10;
  undefined4 uVar11;
  id local_40;
  dword *local_3c;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_isAnimationInProgress);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_sliderAnimation,sel_stopAnimation);
    _objc_msgSend(self,sel_invalidateAnimation);
    _objc_msgSend(self,sel_setNeedsDisplay);
  }
  dVar8 = _objc_msgSend_fpret(self,sel_knobWidth);
  dVar9 = _objc_msgSend_fpret(self,sel_xForProgress_,self->_progress);
  pdVar2 = _objc_msgSend(mouseDown,sel_locationInWindow);
  uVar11 = 0;
  uVar10 = extraout_EDX;
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pdVar2,extraout_EDX,0);
  fVar4 = (float)pvVar1 - (float)dVar9;
  pvVar1 = (id)self->_state;
  local_40 = pvVar1;
  if ((0.0 < fVar4) && (fVar4 < (float)dVar8)) {
    local_3c = (dword *)(float)dVar9;
    fVar5 = 0.0;
    do {
      do {
        pvVar1 = _objc_msgSend(self,sel_window,pdVar2,uVar10,uVar11);
        pdVar2 = &segment_command_0000101c.maxprot;
        pvVar1 = _objc_msgSend(pvVar1,sel_nextEventMatchingMask_);
        if (pvVar1 == (id)0x0) goto LAB_00150f1f;
        pvVar3 = _objc_msgSend(pvVar1,sel_type,pdVar2);
      } while ((pvVar3 != (id)0x2) && (pvVar3 != (id)0x6));
      self->_isTrackingMouse = pvVar3 == (id)0x6;
      pvVar1 = _objc_msgSend(pvVar1,sel_locationInWindow,pdVar2);
      uVar11 = 0;
      uVar10 = extraout_EDX_00;
      pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX_00,0);
      pdVar6 = (dword *)((float)pvVar1 - fVar4);
      pdVar2 = pdVar6;
      dVar8 = _objc_msgSend_fpret(self,sel_progressForX_);
      self->_progress = (float)dVar8;
      fVar7 = (float)pdVar6 - (float)local_3c;
      if (0.0 < fVar7 * fVar5) {
        fVar7 = fVar7 + fVar5;
      }
      if (3.0 < ABS(fVar7)) {
        local_40 = (id)(uint)(0.0 <= fVar7);
      }
      _objc_msgSend(self,sel_setNeedsDisplay,pdVar2,uVar10,uVar11);
      local_3c = pdVar6;
      fVar5 = fVar7;
    } while (self->_isTrackingMouse != '\0');
LAB_00150f1f:
    pvVar1 = (id)self->_state;
    if (local_40 != pvVar1) goto LAB_00150f52;
  }
  dVar8 = _objc_msgSend_fpret(self,sel_progressForState_,pvVar1);
  self->_progress = (float)dVar8;
  _objc_msgSend(self,sel_setNeedsDisplay,pvVar1,uVar10,uVar11);
LAB_00150f52:
  dVar8 = _objc_msgSend_fpret(self,sel_progressForState_,local_40);
  if (((self->_progress != (float)dVar8) || (NAN(self->_progress) || NAN((float)dVar8))) ||
     (local_40 == (id)self->_state)) {
    pvVar1 = (id)0x1;
    op = sel_setState_animate_;
  }
  else {
    _objc_msgSend(self,sel_setState_animate_,local_40,1);
    pvVar1 = _objc_msgSend(self,sel_target);
    local_40 = _objc_msgSend(self,sel_action);
    op = sel_sendAction_to_;
  }
  _objc_msgSend(self,op,local_40,pvVar1);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    if (![self isEnabled]) {
        return;
    }
    if ([self isAnimationInProgress]) {
        [_sliderAnimation stopAnimation];
        [self invalidateAnimation];
        [self setNeedsDisplay];
    }
    float knob = (float)[self knobWidth];
    float knobX = (float)[self xForProgress:_progress];
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    float grab = point.x - knobX;
    NSInteger target = _state;
    if (0.0 < grab && grab < knob) {
        float previousX = knobX;
        float previousDelta = 0.0;
        NSEvent *event;
        do {
            do {
                event = [[self window] nextEventMatchingMask:0x1044];
                if (event == nil) {
                    goto finished;
                }
            } while ([event type] != 2 && [event type] != 6);
            _isTrackingMouse = [event type] == 6;
            point = [self convertPoint:[event locationInWindow] fromView:nil];
            float x = point.x - grab;
            _progress = (float)[self progressForX:x];
            float delta = x - previousX;
            if (0.0 < delta * previousDelta) {
                delta = delta + previousDelta;
            }
            if (3.0 < fabsf(delta)) {
                target = 0.0 <= delta;
            }
            [self setNeedsDisplay];
            previousX = x;
            previousDelta = delta;
        } while (_isTrackingMouse);
finished:
        if (target != _state) {
            goto changed;
        }
    }
    _progress = (float)[self progressForState:_state];
    [self setNeedsDisplay];
changed:
    {
        float targetProgress = (float)[self progressForState:target];
        if (_progress != targetProgress || target == _state) {
            [self setState:target animate:YES];
        }
        else {
            [self setState:target animate:YES];
            [self sendAction:[self action] to:[self target]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015100a @ 0015100a, 366 bytes * /

void FUN_0015100a(HSFlatLiveSlider *self,SEL _cmd,id mouseUp)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  double dVar4;
  double dVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  
  pvVar2 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar2 != '\0') {
    dVar4 = _objc_msgSend_fpret(self,sel_xForProgress_,self->_progress);
    pvVar2 = _objc_msgSend(mouseUp,sel_locationInWindow);
    uVar7 = 0;
    uVar6 = extraout_EDX;
    pvVar3 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    if ((0.0 < (float)pvVar3 - (float)dVar4) &&
       (dVar5 = _objc_msgSend_fpret(self,sel_knobWidth), (float)pvVar3 - (float)dVar4 < (float)dVar5
       )) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_invertedState,pvVar2,uVar6,uVar7);
    dVar4 = _objc_msgSend_fpret(self,sel_progressForState_,pvVar2);
    fVar1 = self->_progress;
    uVar6 = 1;
    _objc_msgSend(self,sel_setState_animate_,pvVar2,1);
    if ((fVar1 == (float)dVar4) && (!NAN(fVar1) && !NAN((float)dVar4))) {
      pvVar2 = _objc_msgSend(self,sel_target,pvVar2,uVar6);
      pvVar3 = _objc_msgSend(self,sel_action);
      _objc_msgSend(self,sel_sendAction_to_,pvVar3,pvVar2);
    }
  }
  return;
}

*/
- (void)mouseUp:(id)aUp
{
    if ([self isEnabled]) {
        float knobX = (float)[self xForProgress:_progress];
        NSPoint point = [self convertPoint:[aUp locationInWindow] fromView:nil];
        float grab = point.x - knobX;
        if (0.0 < grab && grab < (float)[self knobWidth]) {
            return;
        }
        NSInteger state = [self invertedState];
        float target = (float)[self progressForState:state];
        float previous = _progress;
        [self setState:state animate:YES];
        if (previous == target) {
            [self sendAction:[self action] to:[self target]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00151178 @ 00151178, 147 bytes * /

float FUN_00151178(HSFlatLiveSlider *self,SEL _cmd,float xForProgress)

{
  double dVar1;
  float local_28;
  float local_1c [2];
  float local_14;
  
  local_28 = 0.0;
  if ((0.0 <= xForProgress) && (local_28 = 1.0, xForProgress <= 1.0)) {
    local_28 = xForProgress;
  }
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  dVar1 = _objc_msgSend_fpret(self,sel_knobWidth);
  return ((local_1c[0] + local_14) - (float)dVar1) * local_28;
}

*/
- (CGFloat)xForProgress:(CGFloat)aProgress
{
    float progress = 0.0;
    if (0.0 <= aProgress) {
        progress = 1.0;
        if (aProgress <= 1.0) {
            progress = aProgress;
        }
    }
    NSRect bounds = [self bounds];
    float knob = (float)[self knobWidth];
    return ((bounds.origin.x + bounds.size.width) - knob) * progress;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015120b @ 0015120b, 146 bytes * /

float FUN_0015120b(HSFlatLiveSlider *self,SEL _cmd,float progressForX)

{
  float fVar1;
  float fVar2;
  double dVar3;
  float local_1c [2];
  float local_14;
  
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  dVar3 = _objc_msgSend_fpret(self,sel_knobWidth);
  fVar2 = progressForX / ((local_1c[0] + local_14) - (float)dVar3);
  if (fVar2 < 0.0) {
    fVar1 = 0.0;
  }
  else {
    fVar1 = 1.0;
    if (fVar2 <= 1.0) {
      fVar1 = fVar2;
    }
  }
  return fVar1;
}

*/
- (CGFloat)progressForX:(CGFloat)aX
{
    NSRect bounds = [self bounds];
    float knob = (float)[self knobWidth];
    float progress = aX / ((bounds.origin.x + bounds.size.width) - knob);
    if (progress < 0.0) {
        return 0.0;
    }
    if (progress > 1.0) {
        return 1.0;
    }
    return progress;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001502dd @ 001502dd, 28 bytes * /

float FUN_001502dd(HSFlatLiveSlider *self,SEL _cmd,int progressForState)

{
  return *(float *)(&DAT_003354f8 + (uint)(progressForState == 1) * 4);
}

*/
- (CGFloat)progressForState:(NSInteger)aState
{
    return aState == 1 ? 1.0 : 0.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001503ed @ 001503ed, 70 bytes * /

float FUN_001503ed(HSFlatLiveSlider *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_flatSliderImage);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  return (float)pvVar1;
}

*/
- (CGFloat)knobWidth
{
    return [[self flatSliderImage] size].width;
}

- (NSInteger)invertedState
{
    return (unsigned int)(_state == 0);
}

- (NSInteger)state
{
    return _state;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015129d @ 0015129d, 506 bytes * /

void FUN_0015129d(HSFlatLiveSlider *self,SEL _cmd,int setState,BOOL animate)

{
  float fVar1;
  float fVar2;
  float fVar4;
  id pvVar5;
  double dVar6;
  double dVar7;
  HSFlatLiveSlider *self_00;
  SEL op;
  HSFlatLiveSlider *pHVar8;
  float fVar3;
  
  pHVar8 = (HSFlatLiveSlider *)setState;
  dVar6 = _objc_msgSend_fpret(self,sel_progressForState_,setState);
  fVar4 = (float)dVar6;
  if (self->_progress == fVar4) {
    if (self->_state == setState) {
      return;
    }
    self->_state = setState;
    return;
  }
  if (animate == '\0') {
    dVar6 = _objc_msgSend_fpret(self,sel_progressForState_,setState);
    pHVar8 = (HSFlatLiveSlider *)(float)dVar6;
    self_00 = self;
    op = sel_setProgress_;
  }
  else {
    pvVar5 = _objc_msgSend(self,sel_isAnimationInProgress);
    if ((char)pvVar5 != '\0') {
      _objc_msgSend(self->_sliderAnimation,sel_invertAnimationDirection);
      goto LAB_00151464;
    }
    dVar6 = _objc_msgSend_fpret(self,sel_changeDuration,pHVar8);
    fVar1 = self->_progress;
    pvVar5 = _objc_msgSend(cls_HSFlatLiveSliderAnimation,sel_alloc);
    fVar2 = self->_progress;
    fVar3 = self->_progress;
    dVar7 = _objc_msgSend_fpret(self,sel_cancelDuration);
    pvVar5 = _objc_msgSend(pvVar5,
                           sel_initWithFlatLiveSlider_duration_cancelingDuration_isLeftToRight_,self
                           ,(double)ABS(fVar1 - fVar4) * dVar6,dVar7,
                           (uint)(fVar3 <= fVar4 && fVar4 != fVar2));
    self->_sliderAnimation = pvVar5;
    _objc_msgSend(pvVar5,sel_setCurrentProgress_,self->_progress);
    _objc_msgSend(self->_sliderAnimation,sel_setAnimationBlockingMode_,1);
    pHVar8 = self;
    _objc_msgSend(self->_sliderAnimation,sel_setDelegate_,self);
    self_00 = self->_sliderAnimation;
    op = sel_startAnimation;
  }
  _objc_msgSend(self_00,op,pHVar8);
LAB_00151464:
  self->_state = setState;
  if (animate == '\0') {
    _objc_msgSend(self,sel_setNeedsDisplay,pHVar8);
  }
  return;
}

*/
- (void)setState:(NSInteger)aState animate:(BOOL)aAnimate
{
    float target = (float)[self progressForState:aState];
    if (_progress == target) {
        if (_state == aState) {
            return;
        }
        _state = aState;
        return;
    }
    if (!aAnimate) {
        [self setProgress:(float)[self progressForState:aState]];
    }
    else {
        if ([self isAnimationInProgress]) {
            [_sliderAnimation invertAnimationDirection];
        }
        double duration = [self changeDuration];
        float progress = _progress;
        _sliderAnimation = [HSFlatLiveSliderAnimation alloc];
        _sliderAnimation = [_sliderAnimation initWithFlatLiveSlider:self
                                                           duration:(double)fabsf(progress - target) * duration
                                                  cancelingDuration:[self cancelDuration]
                                                      isLeftToRight:(_progress <= target && target != _progress)];
        [_sliderAnimation setCurrentProgress:_progress];
        [_sliderAnimation setAnimationBlockingMode:(NSAnimationBlockingMode)1];
        [_sliderAnimation setDelegate:self];
        [_sliderAnimation startAnimation];
    }
    _state = aState;
    if (!aAnimate) {
        [self setNeedsDisplay];
    }
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (void)dealloc
{
    if ([self isAnimationInProgress]) {
        [_sliderAnimation stopAnimation];
        [_sliderAnimation release];
        _sliderAnimation = nil;
    }
    [_texturesCache release];
    [super dealloc];
}

@end

@implementation HSFlatLiveSlider (Accessibility)

- (id)accessibilityAttributeValue:(id)aValue
{
    id pcVar3;
    id pvVar1_4;
    NSInteger pvVar1_5;
    NSBundle *pvVar2_2;

    if (![aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        if (![aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
            if (![aValue isEqualToString:NSAccessibilityDescriptionAttribute]) {
                pvVar1_4 = [super accessibilityAttributeValue:aValue];
            }
            else {
                pvVar1_5 = [self state];
                pvVar2_2 = [NSBundle bundleForClass:[self class]];
                if (pvVar1_5 == 0) {
                    pcVar3 = @"Background mode";
                }
                else {
                    pcVar3 = @"Objects mode";
                }
                pvVar1_4 = [pvVar2_2 localizedStringForKey:pcVar3 value:@"" table:@"ToolPalette"];
            }
        }
        else {
            pvVar1_4 = NSAccessibilityRoleDescription(NSAccessibilitySliderRole,0);
        }
    }
    else {
        pvVar1_4 = NSAccessibilityUnknownRole;
    }
    return pvVar1_4;
}

- (id)accessibilityAttributeNames
{
    return [[super accessibilityAttributeNames] arrayByAddingObject:NSAccessibilityDescriptionAttribute];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001514f5 @ 001514f5, 9 bytes * /

id FUN_001514f5(HSFlatLiveSlider *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = (id)_NSAccessibilityUnignoredAncestor();
  return pvVar1;
}

*/
- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001514ec @ 001514ec, 9 bytes * /

id FUN_001514ec(HSFlatLiveSlider *self,SEL _cmd,NSPoint accessibilityHitTest)

{
  id pvVar1;
  
  pvVar1 = (id)_NSAccessibilityUnignoredAncestor();
  return pvVar1;
}

*/
- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

@end

