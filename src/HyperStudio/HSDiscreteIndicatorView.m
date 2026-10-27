#import "HSDiscreteIndicatorView.h"
static id sDAT_00342810;

static id sDAT_00342810;


@implementation HSDiscreteIndicatorView

/* i386 ivar offsets: _minValue=0x50, _maxValue=0x54, _warningValue=0x58, _criticalValue=0x5c, _value=0x60, _spaceSizeBetweenIndicatorSegments=0x64, _isVertical=0x68 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007d35f @ 0007d35f, 281 bytes * /

ulonglong FUN_0007d35f(id self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id self_00;
  float extraout_EDX;
  float extraout_EDX_00;
  longdouble lVar3;
  cfstringStruct *pcVar4;
  
  cVar1 = _NSEqualSizes(DAT_00342814,DAT_00342818,*(undefined4 *)PTR_0033607c,
                        *(undefined4 *)(PTR_0033607c + 4));
  if (cVar1 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_imageNamed_,&cfstr_GraphiteIndicator);
    pcVar4 = &cfstr_GraphiteIndicatorBound;
    self_00 = _objc_msgSend(self,sel_imageNamed_,&cfstr_GraphiteIndicatorBound);
    if ((pvVar2 != (id)0x0) && (self_00 != (id)0x0)) {
      _objc_msgSend(pvVar2,sel_size,pcVar4);
      pvVar2 = _objc_msgSend(self_00,sel_size);
      lVar3 = (longdouble)_floorf((float)pvVar2 * 10.0 + (float)pvVar2 * 10.0 + 10.0 + 9.0);
      DAT_00342814 = (float)lVar3;
      DAT_00342818 = extraout_EDX_00;
      if (extraout_EDX_00 <= extraout_EDX) {
        DAT_00342818 = extraout_EDX;
      }
    }
  }
  return CONCAT44(DAT_00342818,DAT_00342814);
}

*/
+ (NSSize)minSize
{
    static NSSize sMinSize;
    if (NSEqualSizes(sMinSize, NSZeroSize)) {
        NSImage *indicator = [self imageNamed:@"GraphiteIndicator"];
        NSImage *bound = [self imageNamed:@"GraphiteIndicatorBound"];
        if (indicator != nil && bound != nil) {
            NSSize indicatorSize = [indicator size];
            NSSize boundSize = [bound size];
            sMinSize.width = floorf(boundSize.width * 10.0f + boundSize.width * 10.0f + 10.0f + 9.0f);
            sMinSize.height = boundSize.height;
            if (boundSize.height <= indicatorSize.height) {
                sMinSize.height = indicatorSize.height;
            }
        }
    }
    return sMinSize;
    return (NSSize){0};
}

+ (id)imageNamed:(id)aNamed
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self sharedImages];
    pvVar1_2 = [pvVar1 objectForKey:aNamed];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:aNamed ofType:@"tiff"]] autorelease];
        [[self sharedImages] setObject:pvVar1_2 forKey:aNamed];
    }
    return pvVar1_2;
}

+ (id)sharedImages
{
    if (sDAT_00342810 == nil) {
        sDAT_00342810 = [NSMutableDictionary new];
    }
    return sDAT_00342810;
}

- (id)imageNamed:(id)aNamed
{
    return [[self class] imageNamed:aNamed];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007d60d @ 0007d60d, 203 bytes * /

NSRect * FUN_0007d60d(NSRect *__return_storage_ptr__,HSDiscreteIndicatorView *self,SEL _cmd,
                     int segmentFrameAtIndex,NSRect inFrame)

{
  id self_00;
  float extraout_EDX;
  longdouble lVar1;
  float fVar2;
  double dVar3;
  
  self_00 = _objc_msgSend(self,sel_class);
  _objc_msgSend(self_00,sel_minSize);
  fVar2 = self->_maxValue - self->_minValue;
  dVar3 = 1.0;
  if (fVar2 != 0.0) {
    dVar3 = (double)fVar2;
  }
  lVar1 = (longdouble)_floorf((float)(((double)inFrame.size.width - (dVar3 + -1.0)) / dVar3));
  (__return_storage_ptr__->origin).x =
       (float)lVar1 * (float)segmentFrameAtIndex + (float)segmentFrameAtIndex;
  (__return_storage_ptr__->origin).y = inFrame.origin.y;
  (__return_storage_ptr__->size).width = (float)lVar1;
  (__return_storage_ptr__->size).height = extraout_EDX;
  return __return_storage_ptr__;
}

*/
- (NSRect)segmentFrameAtIndex:(NSInteger)aIndex inFrame:(NSRect)aFrame
{
    NSSize minSize = [[self class] minSize];
    float range = _maxValue - _minValue;
    double divisor = 1.0;
    if (range != 0.0f) {
        divisor = (double)range;
    }
    float width = floorf((float)(((double)aFrame.size.width - (divisor - 1.0)) / divisor));
    return NSMakeRect(width * (float)aIndex + (float)aIndex, aFrame.origin.y, width, minSize.height);
    return (NSRect){0};
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007d6d8 @ 0007d6d8, 822 bytes * /

void FUN_0007d6d8(HSDiscreteIndicatorView *self,SEL _cmd,NSRect drawSegmentInFrame,int withState)

{
  undefined8 uVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  cfstringStruct *pcVar7;
  float fVar8;
  undefined8 in_stack_ffffff9c;
  undefined8 uVar9;
  undefined8 uVar10;
  undefined8 uVar11;
  undefined8 uVar12;
  undefined4 uVar13;
  undefined4 uVar14;
  
  switch(withState) {
  case 0:
    pcVar7 = &cfstr_GraphiteIndicatorBound;
    pcVar2 = &cfstr_GraphiteIndicator;
    break;
  case 1:
    pcVar7 = &cfstr_GreenIndicatorBound;
    pcVar2 = &cfstr_GreenIndicator;
    break;
  case 2:
    pcVar7 = &cfstr_YellowIndicatorBound;
    pcVar2 = &cfstr_YellowIndicator;
    break;
  case 3:
    pcVar7 = &cfstr_RedIndicatorBound;
    pcVar2 = &cfstr_RedIndicator;
    break;
  default:
    goto switchD_0007d6fc_default;
  }
  if ((pcVar2 != (cfstringStruct *)0x0) && (pcVar7 != (cfstringStruct *)0x0)) {
    uVar13 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
    pvVar3 = _objc_msgSend(self,sel_imageNamed_,pcVar2);
    uVar9 = CONCAT44(uVar13,pcVar7);
    pvVar4 = _objc_msgSend(self,sel_imageNamed_,pcVar7);
    if ((pvVar3 != (id)0x0) && (pvVar4 != (id)0x0)) {
      uVar1 = *(undefined8 *)PTR_00336078;
      uVar11 = *(undefined8 *)PTR_00336078;
      uVar12 = *(undefined8 *)PTR_00336078;
      uVar10 = *(undefined8 *)PTR_00336078;
      pvVar5 = _objc_msgSend(pvVar3,sel_size,uVar9);
      pvVar6 = _objc_msgSend(self,sel_isFlipped);
      _objc_msgSend(pvVar3,sel_setFlipped_,(int)(char)pvVar6);
      _objc_msgSend(pvVar3,sel_drawInRect_fromRect_operation_fraction_,drawSegmentInFrame.origin,
                    drawSegmentInFrame.size,uVar10,CONCAT44(extraout_EDX,pvVar5),2,0x3f800000);
      pvVar3 = _objc_msgSend(pvVar4,sel_size);
      _objc_msgSend(pvVar4,sel_setFlipped_,1);
      _objc_msgSend(pvVar4,sel_drawInRect_fromRect_operation_fraction_,drawSegmentInFrame.origin,
                    CONCAT44(extraout_EDX_00,pvVar3),uVar12,CONCAT44(extraout_EDX_00,pvVar3),2,
                    0x3f800000);
      fVar8 = drawSegmentInFrame.size.width + -1.0 + drawSegmentInFrame.origin.x;
      uVar12 = CONCAT44(extraout_EDX_00,pvVar3);
      uVar9 = CONCAT44(drawSegmentInFrame.origin.y,fVar8);
      uVar10 = CONCAT44(extraout_EDX_00,pvVar3);
      uVar14 = 0x3f800000;
      uVar13 = 2;
      _objc_msgSend(pvVar4,sel_drawInRect_fromRect_operation_fraction_,uVar9,uVar10,uVar11,uVar12,2,
                    0x3f800000);
      if (drawSegmentInFrame.size.width + drawSegmentInFrame.origin.x <
          (drawSegmentInFrame.size.width + 1.0 + -1.0) * (self->_maxValue - self->_minValue)) {
        pvVar4 = _objc_msgSend(self,sel_imageNamed_,&cfstr_IndicatorSpace,
                               (int)((ulonglong)uVar9 >> 0x20),uVar10,uVar11,uVar12,uVar13,uVar14);
        _objc_msgSend(pvVar4,sel_drawInRect_fromRect_operation_fraction_,
                      CONCAT44(drawSegmentInFrame.origin.y,fVar8 + 1.0),
                      CONCAT44(extraout_EDX_00,pvVar3),uVar1,CONCAT44(extraout_EDX_00,pvVar3),2,
                      0x3f800000);
      }
    }
  }
switchD_0007d6fc_default:
  return;
}

*/
- (void)drawSegmentInFrame:(NSRect)aFrame withState:(NSInteger)aState
{
    NSString *imageName;
    NSString *boundName;
    switch (aState) {
    case 0:
        boundName = @"GraphiteIndicatorBound";
        imageName = @"GraphiteIndicator";
        break;
    case 1:
        boundName = @"GreenIndicatorBound";
        imageName = @"GreenIndicator";
        break;
    case 2:
        boundName = @"YellowIndicatorBound";
        imageName = @"YellowIndicator";
        break;
    case 3:
        boundName = @"RedIndicatorBound";
        imageName = @"RedIndicator";
        break;
    default:
        return;
    }
    NSImage *image = [self imageNamed:imageName];
    NSImage *bound = [self imageNamed:boundName];
    if (image == nil || bound == nil) {
        return;
    }
    NSSize imageSize = [image size];
    [image setFlipped:[self isFlipped]];
    [image drawInRect:aFrame fromRect:NSMakeRect(0.0f, 0.0f, imageSize.width, imageSize.height) operation:NSCompositingOperationSourceOver fraction:1.0f];
    NSSize boundSize = [bound size];
    [bound setFlipped:YES];
    NSRect boundRect = NSMakeRect(0.0f, 0.0f, boundSize.width, boundSize.height);
    [bound drawInRect:NSMakeRect(aFrame.origin.x, aFrame.origin.y, boundSize.width, boundSize.height) fromRect:boundRect operation:NSCompositingOperationSourceOver fraction:1.0f];
    float capX = aFrame.size.width - 1.0f + aFrame.origin.x;
    [bound drawInRect:NSMakeRect(capX, aFrame.origin.y, boundSize.width, boundSize.height) fromRect:boundRect operation:NSCompositingOperationSourceOver fraction:1.0f];
    if (aFrame.size.width + aFrame.origin.x < (aFrame.size.width + 1.0f - 1.0f) * (_maxValue - _minValue)) {
        NSImage *space = [self imageNamed:@"IndicatorSpace"];
        [space drawInRect:NSMakeRect(capX + 1.0f, aFrame.origin.y, boundSize.width, boundSize.height) fromRect:boundRect operation:NSCompositingOperationSourceOver fraction:1.0f];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007da20 @ 0007da20, 469 bytes * /

void FUN_0007da20(HSDiscreteIndicatorView *self,SEL _cmd,NSRect drawIndicatorInFrame)

{
  int iVar1;
  undefined4 uVar2;
  int iVar3;
  int *piVar4;
  int iVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  int aiStack_54 [10];
  float local_2c;
  int local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  local_28 = 0x7da2e;
  local_24 = *(undefined4 *)PTR_00336078;
  uStack_20 = *(undefined4 *)(PTR_00336078 + 4);
  local_1c = *(undefined4 *)(PTR_00336078 + 8);
  uStack_18 = *(undefined4 *)(PTR_00336078 + 0xc);
  fVar7 = self->_minValue;
  if (0.0 < self->_maxValue - fVar7) {
    iVar5 = 0;
    iVar3 = 0;
    piVar4 = aiStack_54 + 2;
    do {
      fVar6 = self->_value - fVar7;
      local_2c = (float)(iVar3 + 1);
      if (fVar6 < local_2c) {
        if (fVar6 < local_2c) {
          iVar5 = 0;
        }
      }
      else {
        fVar8 = self->_criticalValue - fVar7;
        fVar7 = self->_warningValue - fVar7;
        if ((((fVar7 != 0.0) || (NAN(fVar7))) || (fVar8 != 0.0)) || (NAN(fVar8))) {
          if (fVar7 < fVar6) {
            if (fVar7 < fVar6) {
              if (fVar8 == 0.0) goto LAB_0007dac5;
              if (fVar8 <= fVar6) {
                if (fVar8 <= fVar6) {
                  iVar5 = (uint)(fVar7 <= fVar8) * 2 + 1;
                }
              }
              else {
                iVar5 = (-(uint)(fVar8 < fVar7) & 1) + 2;
              }
            }
          }
          else if ((fVar8 == 0.0) || ((fVar7 == fVar6 && (!NAN(fVar7) && !NAN(fVar6))))) {
            iVar5 = 2;
          }
          else if (fVar8 <= fVar6) {
            if (fVar8 <= fVar6) {
              iVar5 = (fVar7 <= fVar8 || fVar6 == fVar8) + 2;
            }
          }
          else {
            iVar5 = (-(uint)(fVar8 < fVar7) & 2) + 1;
          }
        }
        else {
LAB_0007dac5:
          iVar5 = 1;
        }
      }
      iVar1 = *(int *)("ownsScrollViewForModeSwitcherViewEmbedding" + local_28 + 0x28);
      *(NSSize *)(piVar4 + 6) = drawIndicatorInFrame.size;
      *(NSPoint *)(piVar4 + 4) = drawIndicatorInFrame.origin;
      piVar4[3] = iVar3;
      piVar4[2] = iVar1;
      piVar4[1] = (int)self;
      *piVar4 = (int)&local_24;
      piVar4[-1] = 0x7dba3;
      _objc_msgSend_stret((void *)*piVar4,(id)piVar4[1],(SEL)piVar4[2]);
      uVar2 = *(undefined4 *)("ownsScrollViewForModeSwitcherViewEmbedding" + local_28 + 0x24);
      *(ulonglong *)(piVar4 + 3) = CONCAT44(uStack_18,local_1c);
      *(ulonglong *)(piVar4 + 1) = CONCAT44(uStack_20,local_24);
      piVar4[5] = iVar5;
      *piVar4 = uVar2;
      piVar4[-1] = (int)self;
      piVar4[-2] = 0x7dbd5;
      _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
      fVar7 = self->_minValue;
      iVar3 = iVar3 + 1;
      piVar4 = piVar4 + -1;
    } while (local_2c < self->_maxValue - fVar7);
  }
  return;
}

*/
- (void)drawIndicatorInFrame:(NSRect)aFrame
{
    float minValue = _minValue;
    if (0.0f < _maxValue - minValue) {
        NSInteger state = 0;
        NSInteger index = 0;
        float next;
        do {
            float relative = _value - minValue;
            next = (float)(index + 1);
            if (relative < next) {
                state = 0;
            } else {
                float critical = _criticalValue - minValue;
                float warning = _warningValue - minValue;
                if (warning != 0.0f || critical != 0.0f) {
                    if (warning < relative) {
                        if (critical == 0.0f) {
                            state = 1;
                        } else if (critical <= relative) {
                            state = (warning <= critical) * 2 + 1;
                        } else {
                            state = ((critical < warning) ? 1 : 0) + 2;
                        }
                    } else if (critical == 0.0f || warning == relative) {
                        state = 2;
                    } else if (critical <= relative) {
                        state = ((warning <= critical || relative == critical) ? 1 : 0) + 2;
                    } else {
                        state = ((critical < warning) ? 2 : 0) + 1;
                    }
                } else {
                    state = 1;
                }
            }
            NSRect segment = [self segmentFrameAtIndex:index inFrame:aFrame];
            [self drawSegmentInFrame:segment withState:state];
            minValue = _minValue;
            index++;
        } while (next < _maxValue - minValue);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007dbf5 @ 0007dbf5, 447 bytes * /

void FUN_0007dbf5(HSDiscreteIndicatorView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  float extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined8 uVar4;
  undefined8 local_1c;
  float local_14;
  float fStack_10;
  
  _objc_msgSend_stret(&local_1c,self,sel_frame);
  fVar2 = fStack_10;
  fVar1 = local_14;
  pvVar3 = _objc_msgSend(self,sel_isVerticalDirection);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_class);
    _objc_msgSend(pvVar3,sel_minSize);
    if (extraout_EDX != fStack_10) {
      pvVar3 = _objc_msgSend(self,sel_class);
      _objc_msgSend(pvVar3,sel_minSize);
      uVar4 = CONCAT44(extraout_EDX_00,fVar1);
      goto LAB_0007dd4d;
    }
  }
  pvVar3 = _objc_msgSend(self,sel_isVerticalDirection);
  if ((char)pvVar3 == '\0') {
    return;
  }
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(pvVar3,sel_minSize);
  if ((float)pvVar3 == local_14) {
    return;
  }
  pvVar3 = _objc_msgSend(self,sel_class);
  _objc_msgSend(pvVar3,sel_minSize);
  uVar4 = CONCAT44(fVar2,extraout_EDX_01);
LAB_0007dd4d:
  _objc_msgSend(self,sel_setFrameSize_,uVar4);
  _objc_msgSend(self,sel_setNeedsDisplay_,1);
  pvVar3 = _objc_msgSend(self,sel_superview);
  _objc_msgSend(pvVar3,sel_setNeedsDisplayInRect_,local_1c,CONCAT44(fStack_10,local_14));
  return;
}

*/
- (void)sizeToFit
{
    NSRect frame = [self frame];
    NSSize newSize;
    if (![self isVerticalDirection]) {
        NSSize minSize = [[self class] minSize];
        if (minSize.height != frame.size.height) {
            minSize = [[self class] minSize];
            newSize = NSMakeSize(frame.size.width, minSize.height);
            goto resize;
        }
    }
    if (![self isVerticalDirection]) {
        return;
    }
    {
        NSSize minSize = [[self class] minSize];
        if (minSize.width == frame.size.width) {
            return;
        }
        minSize = [[self class] minSize];
        newSize = NSMakeSize(minSize.height, frame.size.height);
    }
resize:
    [self setFrameSize:newSize];
    [self setNeedsDisplay:YES];
    [[self superview] setNeedsDisplayInRect:frame];
}

- (BOOL)isVerticalDirection
{
    return _isVertical;
}

- (void)setVerticalDirection:(BOOL)aDirection
{
    if (_isVertical != aDirection) {
        _isVertical = aDirection;
        [self setNeedsDisplay:YES];
    }
}

- (void)setCriticalValue:(CGFloat)aValue
{
    if (_criticalValue != aValue) {
        if (_criticalValue < 0.0) {
            _criticalValue = 0.0;
        }
        _criticalValue = aValue;
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat)criticalValue
{
    return _criticalValue;
}

- (void)setWarningValue:(CGFloat)aValue
{
    if (_warningValue != aValue) {
        if (_warningValue < 0.0) {
            _warningValue = 0.0;
        }
        _warningValue = aValue;
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat)warningValue
{
    return _warningValue;
}

- (CGFloat)value
{
    return _value;
}

- (void)setValue:(CGFloat)aValue
{
    if (((_value == aValue) || (aValue < 0.0)) || (_maxValue < aValue)) {
        if (0.0 <= aValue) {
            if (aValue <= _maxValue) {
                return;
            }
            _value = _maxValue;
        }
        else {
            _value = 0.0;
        }
    }
    else {
        _value = aValue;
    }
    [self setNeedsDisplay:YES];
}

- (CGFloat)maxValue
{
    return _maxValue;
}

- (void)setMaxValue:(CGFloat)aValue
{
    if (_maxValue != aValue) {
        if (1.0 <= aValue) {
            if (_minValue < aValue) {
                _maxValue = aValue;
            }
            else {
                _maxValue = _minValue + 1.0;
            }
        }
        else {
            _maxValue = 1.0;
        }
        [self setNeedsDisplay:YES];
    }
}

- (void)setMinValue:(CGFloat)aValue
{
    float fVar1;

    fVar1 = _minValue;
    if (fVar1 != aValue) {
        if (fVar1 < 0.0 || aValue <= fVar1) {
            aValue = 0.0;
        }
        _minValue = aValue;
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat)minValue
{
    return _minValue;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007dffb @ 0007dffb, 436 bytes * /

void FUN_0007dffb(HSDiscreteIndicatorView *self,SEL _cmd,NSRect drawRect)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined4 *puVar3;
  undefined4 local_64;
  undefined8 local_34;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined1 local_24 [8];
  undefined4 local_1c;
  
  pvVar1 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend_stret(&local_34,self,sel_bounds);
  puVar3 = (undefined4 *)&stack0xffffffa0;
  local_64 = 0x7e056;
  pvVar2 = _objc_msgSend(self,sel_isVerticalDirection);
  if ((char)pvVar2 != '\0') {
    local_64 = 0x7e076;
    _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
    local_64 = 0x7e08e;
    pvVar2 = _objc_msgSend(cls_NSAffineTransform,sel_transform);
    local_64 = 0x7e0b6;
    self_00 = _objc_msgSend(self,sel_class);
    local_64 = 0x7e0c8;
    _objc_msgSend(self_00,sel_minSize);
    local_64 = 0x7e0f8;
    _objc_msgSend(pvVar2,sel_translateXBy_yBy_);
    local_64 = 0x7e112;
    _objc_msgSend(pvVar2,sel_rotateByDegrees_);
    local_64 = 0x7e124;
    _objc_msgSend(pvVar2,sel_concat);
    local_2c = uStack_28;
    local_64 = 0x7e147;
    _objc_msgSend_stret(local_24,self,sel_bounds);
    puVar3 = &local_64;
    uStack_28 = local_1c;
  }
  *(ulonglong *)(puVar3 + 4) = CONCAT44(uStack_28,local_2c);
  *(undefined8 *)(puVar3 + 2) = local_34;
  puVar3[1] = sel_drawIndicatorInFrame_;
  *puVar3 = self;
  puVar3[-1] = 0x7e17c;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_isVerticalDirection;
  *puVar3 = self;
  puVar3[-1] = 0x7e18e;
  pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  if ((char)pvVar2 != '\0') {
    puVar3[1] = sel_restoreGraphicsState;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x7e1a7;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    NSRect frame = [self bounds];
    if ([self isVerticalDirection]) {
        NSRect bounds = frame;
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        NSSize minSize = [[self class] minSize];
        [transform translateXBy:bounds.size.width - minSize.height yBy:bounds.size.height];
        [transform rotateByDegrees:-90.0f];
        [transform concat];
        frame.size = NSMakeSize(bounds.size.height, bounds.size.width);
    }
    [self drawIndicatorInFrame:frame];
    if ([self isVerticalDirection]) {
        [context restoreGraphicsState];
    }
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)dealloc
{
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007d309 @ 0007d309, 86 bytes * /

id FUN_0007d309(HSDiscreteIndicatorView *self,SEL _cmd,NSRect initWithFrame)

{
  id pvVar1;
  HSDiscreteIndicatorView *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_NSView_0034ea10;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x54) = 0x41200000;
  }
  return pvVar1;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _maxValue = 10.0f;
    }
    return self;
    return 0;
}

@end

