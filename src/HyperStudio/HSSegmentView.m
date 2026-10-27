#import "HSSegmentView.h"

@interface NSObject (HSSegmentViewDataSource)
- (double)currentValueForHyperSegmentView:(id)aView;
- (NSUInteger)pegCountForHyperSegmentView:(id)aView;
- (double)startValueForHyperSegmentView:(id)aView;
- (double)pegValueAtIndex:(NSUInteger)aIndex forHyperSegmentView:(id)aView;
@end

@implementation HSSegmentView

/* i386 ivar offsets: _attributesView=0x50, _bodyView=0x54, _rulerView=0x58, _dataSource=0x5c, _delegate=0x60, _selectedSegments=0x64, _scale=0x6c, _primaryInterval=0x70, _secondaryCount=0x78, _firstPrimaryValue=0x7c, _initialWidth=0x84 */

+ (CGFloat)minSegmentDuration
{
    return 0.25;
}

- (void)stopBodyEditing
{

}

- (void)continueBodyEditing
{

}

- (void)startBodyEditing
{

}

- (void)stopChangingCurrentValue:(CGFloat)aValue
{

}

- (void)continueChangingCurrentValue:(CGFloat)aValue
{

}

- (void)startChangingCurrentValue:(CGFloat)aValue
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b91f @ 0003b91f, 84 bytes * /

void FUN_0003b91f(HSSegmentView *self,SEL _cmd,BOOL setValueScaleSliderEnabled)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar1 = _objc_msgSend(pvVar1,sel_valueScaleSlider);
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)setValueScaleSliderEnabled);
  return;
}

*/
- (void)setValueScaleSliderEnabled:(BOOL)aEnabled
{
    [[[self enclosingScrollView] valueScaleSlider] setEnabled:aEnabled];
}

- (void)onChangeValueScale:(id)aScale
{
    [self setScale:(float)[aScale floatValue] * -72.0 + 80.0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b9ce @ 0003b9ce, 112 bytes * /

void FUN_0003b9ce(HSSegmentView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar1 = _objc_msgSend(pvVar1,sel_valueScaleSlider);
  _objc_msgSend(pvVar1,sel_setFloatValue_,0x3f000000);
  _objc_msgSend(self,sel_onChangeValueScale_,pvVar1);
  return;
}

*/
- (void)prepareValueScaleSlider
{
    id slider = [[self enclosingScrollView] valueScaleSlider];
    [slider setFloatValue:0.5];
    [self onChangeValueScale:slider];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003ba3e @ 0003ba3e, 528 bytes * /

void FUN_0003ba3e(HSSegmentView *self,SEL _cmd,id onMinus)

{
  uint uVar1;
  uint uVar2;
  uint uVar3;
  id pvVar4;
  uint uVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  double dVar10;
  double dVar11;
  double dVar12;
  uint uVar13;
  
  _objc_msgSend(self,sel_startBodyEditing);
  uVar5 = (self->_selectedSegments).location;
  pvVar4 = _objc_msgSend(self,sel_pegCount);
  if (uVar5 < (int)pvVar4 - 1U) {
    fVar7 = 0.0;
    do {
      uVar2 = (self->_selectedSegments).length;
      uVar3 = (self->_selectedSegments).location;
      uVar1 = uVar5 + 1;
      dVar10 = _objc_msgSend_fpret(self,sel_pegValueAtIndex_,uVar1);
      dVar10 = dVar10 - (double)fVar7;
      uVar13 = uVar1;
      if (uVar5 < uVar2 + uVar3) {
        dVar11 = _objc_msgSend_fpret(self,sel_pegValueAtIndex_,uVar5);
        pvVar4 = _objc_msgSend(self,sel_class);
        dVar12 = _objc_msgSend_fpret(pvVar4,sel_minSegmentDuration);
        fVar6 = (float)(dVar10 + -0.10000000149011612);
        fVar7 = (float)(dVar11 + dVar12);
        if ((fVar6 != 0.0) || (NAN(fVar6))) {
          fVar8 = ABS(fVar6);
        }
        else {
          fVar8 = 1.0;
        }
        if ((fVar7 != 0.0) || (NAN(fVar7))) {
          fVar9 = ABS(fVar7);
        }
        else {
          fVar9 = 1.0;
        }
        if (fVar9 <= fVar8) {
          fVar9 = fVar8;
        }
        if (fVar9 * -0.0005 + fVar7 <= fVar6) {
          fVar7 = fVar6;
        }
        dVar11 = (double)fVar7;
        dVar10 = dVar11;
        _objc_msgSend(self,sel_setPegValue_atIndex_,dVar11,uVar1);
        dVar10 = (double)CONCAT44((int)((ulonglong)dVar10 >> 0x20),uVar5);
        dVar12 = _objc_msgSend_fpret(self,sel_pegValueAtIndex_,uVar5);
        fVar7 = (float)(dVar11 - dVar12);
      }
      else {
        _objc_msgSend(self,sel_setPegValue_atIndex_,dVar10,uVar1);
      }
      pvVar4 = _objc_msgSend(self,sel_pegCount,dVar10,uVar13);
      uVar5 = uVar1;
    } while (uVar1 < (int)pvVar4 - 1U);
  }
  _objc_msgSend(self,sel_stopBodyEditing);
  return;
}

*/
- (void)onMinus:(id)aMinus
{
    [self startBodyEditing];
    NSUInteger i = _selectedSegments.location;
    if (i < (unsigned int)((int)[self pegCount] - 1)) {
        float shift = 0.0;
        do {
            NSUInteger next = i + 1;
            double v = [self pegValueAtIndex:next] - (double)shift;
            if (i < _selectedSegments.length + _selectedSegments.location) {
                double cur = [self pegValueAtIndex:i];
                double minDur = [[self class] minSegmentDuration];
                float lo = (float)(v - 0.10000000149011612);
                float hi = (float)(cur + minDur);
                float a = lo != 0.0 ? fabsf(lo) : 1.0;
                float b = hi != 0.0 ? fabsf(hi) : 1.0;
                float m = a >= b ? a : b;
                if (m * -0.0005 + hi <= lo) {
                    hi = lo;
                }
                [self setPegValue:(double)hi atIndex:next];
                shift = (float)((double)hi - [self pegValueAtIndex:i]);
            }
            else {
                [self setPegValue:v atIndex:next];
            }
            i = next;
        } while (i < (unsigned int)((int)[self pegCount] - 1));
    }
    [self stopBodyEditing];
}

- (void)onPlus:(id)aPlus
{
    unsigned int uVar1;
    NSUInteger pvVar2;
    unsigned int uVar3;
    unsigned int uVar4;
    double dVar5;
    unsigned int uVar4_2;

    [self startBodyEditing];
    pvVar2 = [self pegCount];
    uVar4 = (_selectedSegments).location;
    if (uVar4 < (int)pvVar2 - 1U) {
        uVar3 = (int)pvVar2 - 1;
        do {
            uVar1 = (_selectedSegments).length;
            dVar5 = [self pegValueAtIndex:uVar3];
            if (uVar4 + uVar1 < uVar3) {
                uVar4_2 = (_selectedSegments).length;
            }
            else {
                uVar4_2 = uVar3 - (_selectedSegments).location;
            }
            [self setPegValue:dVar5 + (double)((float)((double)((unsigned long long)uVar4_2 | 0x4330000000000000) - 4503599627370496.0) * 0.1) atIndex:uVar3];
            uVar4 = (_selectedSegments).location;
            uVar3 = uVar3 - 1;
        } while (uVar4 < uVar3);
    }
    [self stopBodyEditing];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003bd68 @ 0003bd68, 623 bytes * /

void FUN_0003bd68(HSSegmentView *self,SEL _cmd)

{
  id pvVar1;
  float *pfVar2;
  int *piVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  float fVar8;
  float fVar9;
  double dVar10;
  undefined4 local_90;
  undefined1 local_3c [8];
  float local_34 [2];
  undefined1 local_2c [12];
  float local_20;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  piVar3 = (int *)&stack0xffffff74;
  local_90 = 0x3bd8e;
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
  if (pvVar1 == (id)0x0) {
    pfVar2 = &self->_initialWidth;
  }
  else {
    local_90 = 0x3bda4;
    pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
    local_90 = 0x3bdbd;
    _objc_msgSend_stret(local_3c,pvVar1,sel_frame);
    piVar3 = &local_90;
    pfVar2 = local_34;
  }
  fVar9 = *pfVar2;
  piVar3[2] = (int)sel_frame;
  piVar3[1] = (int)self;
  *piVar3 = (int)local_2c;
  piVar3[-1] = 0x3bded;
  _objc_msgSend_stret((void *)*piVar3,(id)piVar3[1],(SEL)piVar3[2]);
  *piVar3 = (int)sel_totalDuration;
  piVar3[-1] = (int)self;
  piVar3[-2] = 0x3be0c;
  dVar10 = _objc_msgSend_fpret((id)piVar3[-1],(SEL)*piVar3);
  dVar7 = (double)self->_scale * dVar10 + 30.0;
  dVar10 = (double)fVar9;
  if ((double)fVar9 <= dVar7) {
    dVar10 = dVar7;
  }
  fVar4 = (float)dVar10;
  piVar3[1] = (int)sel_frame;
  *piVar3 = (int)self;
  piVar3[-1] = (int)&local_1c;
  piVar3[-2] = 0x3be69;
  _objc_msgSend_stret((void *)piVar3[-1],(id)*piVar3,(SEL)piVar3[1]);
  fVar6 = local_20 + 0.0;
  fVar9 = ABS(local_18) + local_10;
  if ((fVar9 != 0.0) || (NAN(fVar9))) {
    fVar9 = ABS(fVar9);
  }
  else {
    fVar9 = 1.0;
  }
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar6 = ABS(fVar6);
  }
  else {
    fVar6 = 1.0;
  }
  fVar8 = fVar4 + 0.0;
  fVar5 = ABS(local_1c) + local_14;
  if (fVar6 <= fVar9) {
    fVar6 = fVar9;
  }
  if ((fVar5 != 0.0) || (NAN(fVar5))) {
    fVar5 = ABS(fVar5);
  }
  else {
    fVar5 = 1.0;
  }
  if ((fVar8 != 0.0) || (NAN(fVar8))) {
    fVar8 = ABS(fVar8);
  }
  else {
    fVar8 = 1.0;
  }
  if (fVar8 <= fVar5) {
    fVar8 = fVar5;
  }
  if ((((fVar8 * 0.0005 < ABS(local_1c - 0.0)) || (fVar6 * 0.0005 < ABS(local_18 - 0.0))) ||
      (fVar8 * 0.0005 < ABS(local_14 - fVar4))) || (fVar6 * 0.0005 < ABS(local_10 - local_20))) {
    *(ulonglong *)(piVar3 + 2) = CONCAT44(local_20,fVar4);
    piVar3[0] = 0;
    piVar3[1] = 0;
    piVar3[-1] = (int)sel_setFrame_;
    piVar3[-2] = (int)self;
    piVar3[-3] = 0x3bfcd;
    _objc_msgSend((id)piVar3[-2],(SEL)piVar3[-1]);
  }
  return;
}

*/
- (void)setupViewFrame
{
    float width;
    NSScrollView *scroll = [self enclosingScrollView];
    if (scroll == nil) {
        width = _initialWidth;
    }
    else {
        width = [[scroll contentView] frame].size.width;
    }
    double want = (double)_scale * [self totalDuration] + 30.0;
    if ((double)width <= want) {
        width = (float)want;
    }
    NSRect cur = [self frame];
    float h = cur.size.height;
    float oldW = cur.size.width;
    float a = fabsf(cur.origin.x) + oldW;
    float b = fabsf(cur.origin.y) + h;
    float c = width + 0.0;
    float d = h + 0.0;
    a = a != 0.0 ? fabsf(a) : 1.0;
    b = b != 0.0 ? fabsf(b) : 1.0;
    c = c != 0.0 ? fabsf(c) : 1.0;
    d = d != 0.0 ? fabsf(d) : 1.0;
    float tx = (c <= a ? a : c) * 0.0005;
    float ty = (d <= b ? b : d) * 0.0005;
    if (tx < fabsf(cur.origin.x - 0.0) || ty < fabsf(cur.origin.y - 0.0)
        || tx < fabsf(oldW - width) || ty < fabsf(h - h)) {
        [self setFrame:NSMakeRect(0, 0, width, h)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003bfd7 @ 0003bfd7, 364 bytes * /

void FUN_0003bfd7(HSSegmentView *self,SEL _cmd)

{
  uint *puVar1;
  uint *puVar2;
  int iVar3;
  longdouble lVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  double dVar9;
  double local_2c;
  
  fVar5 = self->_scale;
  *(undefined4 *)((int)&self->_primaryInterval + 4) = 0;
  *(undefined4 *)&self->_primaryInterval = 0;
  fVar5 = 40.0 / fVar5;
  iVar3 = -1;
  puVar1 = &DAT_00334a08;
  do {
    puVar2 = puVar1;
    iVar3 = iVar3 + 1;
    if (0x13 < iVar3) {
      return;
    }
    fVar6 = (float)*(double *)(puVar2 + -2);
    if ((fVar5 != 0.0) || (NAN(fVar5))) {
      fVar7 = ABS(fVar5);
    }
    else {
      fVar7 = 1.0;
    }
    if ((fVar6 != 0.0) || (NAN(fVar6))) {
      fVar8 = ABS(fVar6);
    }
    else {
      fVar8 = 1.0;
    }
    if (fVar8 <= fVar7) {
      fVar8 = fVar7;
    }
    puVar1 = puVar2 + 3;
  } while (fVar8 * 0.0005 + fVar6 < fVar5);
  self->_primaryInterval = *(double *)(puVar2 + -2);
  self->_secondaryCount = *puVar2;
  dVar9 = _objc_msgSend_fpret(self,sel_startValue);
  local_2c = self->_primaryInterval;
  lVar4 = (longdouble)_fmod(dVar9,local_2c);
  fVar5 = (float)lVar4;
  if ((fVar5 != 0.0) || (NAN(fVar5))) {
    fVar6 = ABS(fVar5);
  }
  else {
    fVar6 = 1.0;
  }
  if (1.0 <= fVar6) {
    fVar6 = fVar6 * 0.0005;
  }
  else {
    fVar6 = 0.0005;
  }
  if (fVar5 <= fVar6 + 0.0) {
    local_2c = -0.0;
  }
  self->_firstPrimaryValue = dVar9 + (local_2c - (double)lVar4);
  return;
}

*/
- (void)setupRuler
{
    static const struct { double interval; unsigned int count; } table[20] = {
        {0.002, 4}, {0.005, 5}, {0.01, 5}, {0.02, 4}, {0.05, 5}, {0.1, 5}, {0.2, 4}, {0.5, 5}, {1.0, 4}, {2.0, 4},
        {5.0, 5}, {10.0, 5}, {20.0, 4}, {50.0, 5}, {100.0, 4}, {200.0, 4}, {500.0, 5}, {1000.0, 4}, {2000.0, 4}, {5000.0, 5}
    };
    _primaryInterval = 0;
    float target = 40.0 / _scale;
    int i = 0;
    for (; i < 20; i++) {
        float iv = (float)table[i].interval;
        float a = target != 0.0 ? fabsf(target) : 1.0;
        float b = iv != 0.0 ? fabsf(iv) : 1.0;
        float m = b <= a ? a : b;
        if (!(m * 0.0005 + iv < target)) {
            break;
        }
    }
    if (i >= 20) {
        return;
    }
    _primaryInterval = table[i].interval;
    _secondaryCount = table[i].count;
    double start = [self startValue];
    double step = _primaryInterval;
    double rem = fmod(start, step);
    float frem = (float)rem;
    float tol = frem != 0.0 ? fabsf(frem) : 1.0;
    tol = 1.0 <= tol ? tol * 0.0005 : 0.0005;
    if (frem <= tol + 0.0) {
        step = -0.0;
    }
    _firstPrimaryValue = start + (step - rem);
}

- (void)refreshCurrentValue
{
    [_bodyView refreshCurrentValue];
    [_rulerView refreshCurrentValue];
}

- (void)refresh
{
    [self setupRuler];
    [self setupViewFrame];
    [_attributesView refresh];
    [_bodyView refresh];
    [_rulerView refresh];
    [self setNeedsDisplay:YES];
}

- (NSInteger)segmentAtX:(CGFloat)aX
{
    int iVar1;
    float fVar2;
    float fVar3;
    NSUInteger pvVar4;
    int iVar5;
    float fVar6;
    float fVar7;
    float fVar3_2;
    float fVar6_2;
    float fVar7_2;

    fVar2 = (float)[self valueForX:aX];
    pvVar4 = [self pegCount];
    iVar1 = 0;
    do {
        do {
            iVar5 = iVar1;
            if ((int)pvVar4 + -1 <= iVar5) {
                return -1;
            }
            iVar1 = iVar5 + 1;
            fVar3 = (float)[self pegValueAtIndex:iVar5];
            fVar6 = fVar3 != 0.0 ? fabs(fVar3) : 1.0;
            fVar7 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
            if (fVar7 <= fVar6) {
                fVar7 = fVar6;
            }
        } while (fVar7 * -0.0005 + fVar2 <= fVar3);
        fVar3_2 = (float)[self pegValueAtIndex:iVar1];
        fVar6_2 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
        fVar7_2 = fVar3_2 != 0.0 ? fabs(fVar3_2) : 1.0;
        if (fVar7_2 <= fVar6_2) {
            fVar7_2 = fVar6_2;
        }
    } while (fVar3_2 + fVar7_2 * -0.0005 <= fVar2);
    return iVar5;
}

- (NSInteger)pegIndexAtValue:(double)aValue
{
    float fVar1;
    NSUInteger pvVar2;
    int iVar3;
    float fVar4;
    float fVar5;
    float fVar6;

    iVar3 = 0;
    fVar4 = (float)aValue;
    pvVar2 = [self pegCount];
    while( YES ) {
        if ((int)pvVar2 <= iVar3) {
            return -1;
        }
        fVar1 = (float)[self pegValueAtIndex:iVar3];
        fVar5 = fVar4 != 0.0 ? fabs(fVar4) : 1.0;
        fVar6 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        if (fVar6 <= fVar5) {
            fVar6 = fVar5;
        }
        if (fabs(fVar4 - fVar1) <= fVar6 * 0.0005) break;
        iVar3 = iVar3 + 1;
    }
    return iVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c45e @ 0003c45e, 127 bytes * /

float FUN_0003c45e(HSSegmentView *self,SEL _cmd,double xForValue)

{
  double dVar1;
  float local_1c [4];
  
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  dVar1 = _objc_msgSend_fpret(self,sel_startValue);
  return (float)((xForValue - dVar1) * (double)self->_scale + (double)local_1c[0] + 15.0);
}

*/
- (CGFloat)xForValue:(double)aValue
{
    return (float)((aValue - [self startValue]) * (double)_scale + (double)[self bounds].origin.x + 15.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c4dd @ 0003c4dd, 113 bytes * /

double FUN_0003c4dd(HSSegmentView *self,SEL _cmd,float valueForX)

{
  double dVar1;
  float local_1c [4];
  
  dVar1 = _objc_msgSend_fpret(self,sel_startValue);
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  return (double)(((valueForX + -15.0) - local_1c[0]) / self->_scale) + dVar1;
}

*/
- (double)valueForX:(CGFloat)aX
{
    double start = [self startValue];
    return (double)((((float)aX + -15.0f) - (float)[self bounds].origin.x) / _scale) + start;
}

- (double)firstPrimaryValue
{
    return _firstPrimaryValue;
}

- (NSUInteger)secondaryCount
{
    return _secondaryCount;
}

- (double)primaryInterval
{
    return _primaryInterval;
}

- (void)setScale:(CGFloat)aScale
{
    float fVar1;
    float fVar2;
    float fVar3;

    fVar1 = _scale;
    fVar2 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar3 = aScale != 0.0 ? fabs(aScale) : 1.0;
    if (fVar3 <= fVar2) {
        fVar3 = fVar2;
    }
    if (fVar3 * 0.0005 < fabs(fVar1 - aScale)) {
        _scale = aScale;
        [self refresh];
    }
}

- (CGFloat)scale
{
    return _scale;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c5df @ 0003c5df, 150 bytes * /

void FUN_0003c5df(HSSegmentView *self,SEL _cmd,NSRange setSelectedSegments)

{
  id pvVar1;
  
  if (((self->_selectedSegments).location != setSelectedSegments.location) ||
     ((self->_selectedSegments).length != setSelectedSegments.length)) {
    (self->_selectedSegments).location = setSelectedSegments.location;
    (self->_selectedSegments).length = setSelectedSegments.length;
    if (self->_delegate != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                             sel_hyperSegmentView_setSelectedSegments_);
      if ((char)pvVar1 != '\0') {
        _objc_msgSend(self->_delegate,sel_hyperSegmentView_setSelectedSegments_,self,
                      setSelectedSegments.location,setSelectedSegments.length);
      }
    }
    _objc_msgSend(self,sel_refresh);
  }
  return;
}

*/
- (void)setSelectedSegments:(NSRange)aSegments
{
    if (_selectedSegments.location != aSegments.location || _selectedSegments.length != aSegments.length) {
        _selectedSegments = aSegments;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(hyperSegmentView:setSelectedSegments:)]) {
            [_delegate hyperSegmentView:self setSelectedSegments:aSegments];
        }
        [self refresh];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b5d4 @ 0003b5d4, 14 bytes * /

ulonglong FUN_0003b5d4(HSSegmentView *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_selectedSegments).location;
  uVar1._4_4_ = (self->_selectedSegments).length;
  return uVar1;
}

*/
- (NSRange)selectedSegments
{
    return _selectedSegments;
}

- (void)setCurrentValue:(double)aValue
{
    float fVar1;
    float fVar3;
    float fVar4;
    float fVar5;

    if (_delegate != nil) {
        fVar1 = (float)[self currentValue];
        fVar3 = (float)aValue;
        fVar4 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        fVar5 = fVar3 != 0.0 ? fabs(fVar3) : 1.0;
        if (fVar5 <= fVar4) {
            fVar5 = fVar4;
        }
        if (fVar5 * 0.0005 < fabs(fVar1 - fVar3)) {
            if ([_delegate respondsToSelector:@selector(hyperSegmentView:setCurrentValue:)]) {
                [_delegate hyperSegmentView:self setCurrentValue:aValue];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c759 @ 0003c759, 53 bytes * /

double FUN_0003c759(HSSegmentView *self,SEL _cmd)

{
  double dVar1;
  
  if (self->_dataSource == (id)0x0) {
    dVar1 = 0.0;
  }
  else {
    dVar1 = _objc_msgSend_fpret(self->_dataSource,sel_currentValueForHyperSegmentView_,self);
  }
  return dVar1;
}

*/
- (double)currentValue
{
    if (_dataSource == nil) {
        return 0.0;
    }
    return [_dataSource currentValueForHyperSegmentView:self];
}

- (double)totalDuration
{
    double dVar2;

    if ([self pegCount] == 0) {
        dVar2 = 0.0;
    }
    else {
        dVar2 = [self pegValueAtIndex:(int)[self pegCount] + -1] - [self pegValueAtIndex:0];
    }
    return dVar2;
}

- (void)setPegValue:(double)aValue atIndex:(NSUInteger)aIndex
{
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(hyperSegmentView:setPegValue:atIndex:)]) {
            [_delegate hyperSegmentView:self setPegValue:aValue atIndex:aIndex];
            [self refresh];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c897 @ 0003c897, 52 bytes * /

double FUN_0003c897(HSSegmentView *self,SEL _cmd,uint pegValueAtIndex)

{
  double dVar1;
  
  dVar1 = _objc_msgSend_fpret(self->_dataSource,sel_pegValueAtIndex_forHyperSegmentView_,
                              pegValueAtIndex,self);
  return dVar1;
}

*/
- (double)pegValueAtIndex:(NSUInteger)aIndex
{
    return [_dataSource pegValueAtIndex:aIndex forHyperSegmentView:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c8cb @ 0003c8cb, 53 bytes * /

uint FUN_0003c8cb(HSSegmentView *self,SEL _cmd)

{
  id pvVar1;
  
  if (self->_dataSource == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_dataSource,sel_pegCountForHyperSegmentView_,self);
  }
  return (uint)pvVar1;
}

*/
- (NSUInteger)pegCount
{
    if (_dataSource == nil) {
        return 0;
    }
    return [_dataSource pegCountForHyperSegmentView:self];
}

- (void)setStartValue:(double)aValue
{
    float fVar1;
    float fVar3;
    float fVar4;
    float fVar5;

    if (_delegate != nil) {
        fVar1 = (float)[self startValue];
        fVar3 = (float)aValue;
        fVar4 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        fVar5 = fVar3 != 0.0 ? fabs(fVar3) : 1.0;
        if (fVar5 <= fVar4) {
            fVar5 = fVar4;
        }
        if (fVar5 * 0.0005 < fabs(fVar1 - fVar3)) {
            if ([_delegate respondsToSelector:@selector(hyperSegmentView:setStartValue:)]) {
                [_delegate hyperSegmentView:self setStartValue:aValue];
                [self refresh];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003c9f6 @ 0003c9f6, 53 bytes * /

double FUN_0003c9f6(HSSegmentView *self,SEL _cmd)

{
  double dVar1;
  
  if (self->_dataSource == (id)0x0) {
    dVar1 = 0.0;
  }
  else {
    dVar1 = _objc_msgSend_fpret(self->_dataSource,sel_startValueForHyperSegmentView_,self);
  }
  return dVar1;
}

*/
- (double)startValue
{
    if (_dataSource == nil) {
        return 0.0;
    }
    return [_dataSource startValueForHyperSegmentView:self];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDataSource:(id)aSource
{
    if (_dataSource != aSource) {
        _dataSource = aSource;
        (_selectedSegments).location = 0;
        (_selectedSegments).length = 0;
        [self refresh];
    }
}

- (id)dataSource
{
    return _dataSource;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003b63d @ 0003b63d, 738 bytes * /

id FUN_0003b63d(HSSegmentView *self,SEL _cmd,NSRect initWithFrame)

{
  id self_00;
  id pvVar1;
  HSSegmentView *local_4c;
  undefined *local_48;
  undefined4 local_44;
  undefined4 uStack_40;
  float local_3c;
  undefined4 uStack_38;
  undefined4 local_34;
  undefined4 uStack_30;
  float local_2c;
  float fStack_28;
  undefined4 local_24;
  float fStack_20;
  float local_1c;
  undefined4 uStack_18;
  
  local_4c = self;
  local_48 = PTR_s_NSView_0034dc90;
  self_00 = _objc_msgSendSuper(&local_4c,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size)
  ;
  if (self_00 != (id)0x0) {
    *(undefined4 *)((int)self_00 + 100) = 0;
    *(undefined4 *)((int)self_00 + 0x68) = 0;
    *(undefined4 *)((int)self_00 + 0x6c) = 0x3f800000;
    *(undefined4 *)((int)self_00 + 0x74) = 0;
    *(undefined4 *)((int)self_00 + 0x70) = 0;
    *(undefined4 *)((int)self_00 + 0x78) = 0;
    *(undefined4 *)((int)self_00 + 0x80) = 0;
    *(undefined4 *)((int)self_00 + 0x7c) = 0;
    *(float *)((int)self_00 + 0x84) = initWithFrame.size.width;
    pvVar1 = _objc_msgSend(cls_HSSegmentAttributesView,sel_alloc);
    local_44 = 0;
    uStack_40 = 0;
    local_3c = initWithFrame.size.width;
    uStack_38 = 0x41a00000;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_segmentView_,0,
                           CONCAT44(0x41a00000,initWithFrame.size.width),self_00);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    *(id *)((int)self_00 + 0x50) = pvVar1;
    pvVar1 = _objc_msgSend(cls_HSSegmentBodyView,sel_alloc);
    local_34 = 0;
    uStack_30 = 0x41a00000;
    local_2c = initWithFrame.size.width;
    fStack_28 = initWithFrame.size.height + -37.0 + -20.0;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_segmentView_,0x41a0000000000000,
                           CONCAT44(fStack_28,initWithFrame.size.width),self_00);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    *(id *)((int)self_00 + 0x54) = pvVar1;
    pvVar1 = _objc_msgSend(cls_HSSegmentRulerView,sel_alloc);
    fStack_20 = initWithFrame.size.height + -37.0;
    local_24 = 0;
    local_1c = initWithFrame.size.width;
    uStack_18 = 0x42140000;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_segmentView_,(ulonglong)(uint)fStack_20 << 0x20,
                           CONCAT44(0x42140000,initWithFrame.size.width),self_00);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    *(id *)((int)self_00 + 0x58) = pvVar1;
    _objc_msgSend(self_00,sel_addSubview_,*(undefined4 *)((int)self_00 + 0x50));
    _objc_msgSend(self_00,sel_addSubview_,*(undefined4 *)((int)self_00 + 0x54));
    _objc_msgSend(self_00,sel_addSubview_,*(undefined4 *)((int)self_00 + 0x58));
    _objc_msgSend(*(id *)((int)self_00 + 0x50),sel_setAutoresizingMask_,0x12);
    _objc_msgSend(*(id *)((int)self_00 + 0x54),sel_setAutoresizingMask_,0x12);
    _objc_msgSend(*(id *)((int)self_00 + 0x58),sel_setAutoresizingMask_,2);
    _objc_msgSend(self_00,sel_refresh);
  }
  return self_00;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        _selectedSegments.location = 0;
        _selectedSegments.length = 0;
        _scale = 1.0;
        _primaryInterval = 0;
        _secondaryCount = 0;
        _firstPrimaryValue = 0;
        _initialWidth = aFrame.size.width;
        _attributesView = [[[HSSegmentAttributesView alloc] initWithFrame:NSMakeRect(0, 0, aFrame.size.width, 20.0) segmentView:self] autorelease];
        _bodyView = [[[HSSegmentBodyView alloc] initWithFrame:NSMakeRect(0, 20.0, aFrame.size.width, aFrame.size.height - 37.0 - 20.0) segmentView:self] autorelease];
        _rulerView = [[[HSSegmentRulerView alloc] initWithFrame:NSMakeRect(0, aFrame.size.height - 37.0, aFrame.size.width, 37.0) segmentView:self] autorelease];
        [self addSubview:_attributesView];
        [self addSubview:_bodyView];
        [self addSubview:_rulerView];
        [_attributesView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_bodyView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_rulerView setAutoresizingMask:NSViewWidthSizable];
        [self refresh];
    }
    return self;
}

@end

