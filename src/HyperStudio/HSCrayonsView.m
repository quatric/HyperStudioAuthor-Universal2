#import "HSCrayonsView.h"
static id sDAT_00342964;

static id sDAT_00342964;


@implementation HSCrayonsView

/* i386 ivar offsets: _items=0x5c, _numberOfRows=0x60, _numberOfColumns=0x64, _layoutIsValid=0x68, _needsForceLayout=0x69, _color=0x6c, _highlightedItem=0x70, _dataSource=0x74, _defaultDataSource=0x78 */

+ (Class)defaultDataSourceClass
{
    if (sDAT_00342964 == Nil) {
        sDAT_00342964 = [HSFlexibleCrayonsDataSource class];
    }
    return sDAT_00342964;
}

+ (void)setDefaultDataSourceClass:(Class)aClass
{
    sDAT_00342964 = aClass;
}

+ (Class)cellClass
{
    return [NSActionCell class];
}

- (void)mouseUp:(id)aUp
{
    [self highlightItem:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014597e @ 0014597e, 105 bytes * /

void FUN_0014597e(HSCrayonsView *self,SEL _cmd,id mouseDragged)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(mouseDragged,sel_locationInWindow);
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  _objc_msgSend(self,sel_handleMousePoint_,pvVar1,extraout_EDX_00);
  return;
}

*/
- (void)mouseDragged:(id)aDragged
{
    [self handleMousePoint:[self convertPoint:[aDragged locationInWindow] fromView:nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001459e7 @ 001459e7, 105 bytes * /

void FUN_001459e7(HSCrayonsView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(mouseDown,sel_locationInWindow);
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  _objc_msgSend(self,sel_handleMousePoint_,pvVar1,extraout_EDX_00);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    [self handleMousePoint:[self convertPoint:[aDown locationInWindow] fromView:nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00145a50 @ 00145a50, 309 bytes * /

void FUN_00145a50(HSCrayonsView *self,SEL _cmd,NSPoint handleMousePoint)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float fVar4;
  
  pvVar1 = _objc_msgSend(self,sel_items);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  do {
    pvVar1 = (id)((int)pvVar1 + -1);
    if ((int)pvVar1 < 0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_items);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
    fVar4 = handleMousePoint.y;
    pvVar3 = _objc_msgSend(pvVar2,sel_hitTestPoint_,handleMousePoint.x,handleMousePoint.y);
  } while ((char)pvVar3 == '\0');
  _objc_msgSend(self,sel_highlightItem_,pvVar2,fVar4);
  pvVar1 = _objc_msgSend(pvVar2,sel_color);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_color = pvVar1;
  pvVar1 = *(id *)PTR_00336058;
  pvVar2 = _objc_msgSend(self,sel_target);
  pvVar3 = _objc_msgSend(self,sel_action);
  _objc_msgSend(pvVar1,sel_sendAction_to_from_,pvVar3,pvVar2,self);
  return;
}

*/
- (void)handleMousePoint:(NSPoint)aPoint
{
    NSInteger i = [[self items] count];
    while (--i >= 0) {
        HSCrayonItem *item = [[self items] objectAtIndex:i];
        if ([item hitTestPoint:aPoint]) {
            [self highlightItem:item];
            _color = [[item color] retain];
            [NSApp sendAction:[self action] to:[self target] from:self];
            return;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00145b85 @ 00145b85, 330 bytes * /

void FUN_00145b85(HSCrayonsView *self,SEL _cmd,id highlightItem)

{
  HSCrayonItem *pHVar1;
  HSCrayonItem *pHVar2;
  int *piVar3;
  undefined1 local_54 [32];
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar3 = (int *)&stack0xffffff84;
  pHVar2 = self->_highlightedItem;
  if (pHVar2 != highlightItem) {
    pHVar1 = (HSCrayonItem *)0x0;
    if (pHVar2 != (HSCrayonItem *)0x0) {
      _objc_msgSend_stret(local_54,pHVar2,sel_frame);
      _NSInsetRect();
      piVar3 = (int *)&stack0xffffff7c;
      _objc_msgSend(self,sel_setNeedsDisplayInRect_);
      pHVar1 = self->_highlightedItem;
    }
    piVar3[1] = (int)sel_release;
    *piVar3 = (int)pHVar1;
    piVar3[-1] = 0x145c36;
    _objc_msgSend((id)*piVar3,(SEL)piVar3[1]);
    piVar3[1] = (int)sel_retain;
    *piVar3 = (int)highlightItem;
    piVar3[-1] = 0x145c48;
    pHVar2 = _objc_msgSend((id)*piVar3,(SEL)piVar3[1]);
    self->_highlightedItem = pHVar2;
    if (pHVar2 != (HSCrayonItem *)0x0) {
      piVar3[2] = (int)sel_frame;
      piVar3[1] = (int)pHVar2;
      *piVar3 = (int)&local_34;
      piVar3[-1] = 0x145c68;
      _objc_msgSend_stret((void *)*piVar3,(id)piVar3[1],(SEL)piVar3[2]);
      *(undefined8 *)(piVar3 + 2) = local_2c;
      *(undefined8 *)piVar3 = local_34;
      piVar3[-1] = (int)&local_24;
      piVar3[5] = -0x3f600000;
      piVar3[4] = -0x3f600000;
      piVar3[-2] = 0x145c9c;
      _NSInsetRect();
      *(undefined8 *)(piVar3 + 2) = local_1c;
      *(undefined8 *)piVar3 = local_24;
      piVar3[-1] = (int)sel_setNeedsDisplayInRect_;
      piVar3[-2] = (int)self;
      piVar3[-3] = 0x145cc7;
      _objc_msgSend((id)piVar3[-2],(SEL)piVar3[-1]);
    }
  }
  return;
}

*/
- (void)highlightItem:(id)aItem
{
    if (_highlightedItem != aItem) {
        if (_highlightedItem != nil) {
            [self setNeedsDisplayInRect:NSInsetRect([_highlightedItem frame], -5.0, -5.0)];
        }
        [_highlightedItem release];
        _highlightedItem = [aItem retain];
        if (_highlightedItem != nil) {
            [self setNeedsDisplayInRect:NSInsetRect([_highlightedItem frame], -5.0, -5.0)];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00145ccf @ 00145ccf, 424 bytes * /

void FUN_00145ccf(HSCrayonsView *self,SEL _cmd,NSSize setFrameSize)

{
  float fVar1;
  float fVar2;
  HSCrayonsView *local_24;
  undefined *local_20;
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  _objc_msgSend_stret(local_1c,self,sel_frame);
  if ((local_14 != 0.0) || (NAN(local_14))) {
    fVar1 = ABS(local_14);
  }
  else {
    fVar1 = 1.0;
  }
  if ((setFrameSize.width != 0.0) || (NAN(setFrameSize.width))) {
    fVar2 = ABS(setFrameSize.width);
  }
  else {
    fVar2 = 1.0;
  }
  if (fVar2 <= fVar1) {
    fVar2 = fVar1;
  }
  if (fVar2 * 0.0005 < ABS(local_14 - setFrameSize.width)) {
    local_24 = self;
    local_20 = PTR_s_NSControl_003517a0;
    _objc_msgSendSuper(&local_24,sel_setFrameSize_,setFrameSize.width,setFrameSize.height);
  }
  else {
    if ((local_10 != 0.0) || (NAN(local_10))) {
      fVar1 = ABS(local_10);
    }
    else {
      fVar1 = 1.0;
    }
    if ((setFrameSize.height != 0.0) || (NAN(setFrameSize.height))) {
      fVar2 = ABS(setFrameSize.height);
    }
    else {
      fVar2 = 1.0;
    }
    local_24 = self;
    local_20 = PTR_s_NSControl_003517a0;
    if (fVar2 <= fVar1) {
      fVar2 = fVar1;
    }
    _objc_msgSendSuper(&local_24,sel_setFrameSize_,setFrameSize.width,setFrameSize.height);
    if (ABS(local_10 - setFrameSize.height) <= fVar2 * 0.0005) {
      return;
    }
  }
  _objc_msgSend(self,sel_setNeedsLayout_,1);
  return;
}

*/
- (void)setFrameSize:(NSSize)aSize
{
    NSSize old = [self frame].size;
    float a = old.width != 0.0 ? fabsf(old.width) : 1.0;
    float b = aSize.width != 0.0 ? fabsf(aSize.width) : 1.0;
    float tol = (b <= a ? a : b) * 0.0005;
    if (tol < fabsf(old.width - aSize.width)) {
        [super setFrameSize:aSize];
    }
    else {
        a = old.height != 0.0 ? fabsf(old.height) : 1.0;
        b = aSize.height != 0.0 ? fabsf(aSize.height) : 1.0;
        tol = (b <= a ? a : b) * 0.0005;
        [super setFrameSize:aSize];
        if (fabsf(old.height - aSize.height) <= tol) {
            return;
        }
    }
    [self setNeedsLayout:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00145e77 @ 00145e77, 744 bytes * /

void FUN_00145e77(HSCrayonsView *self,SEL _cmd,NSRect drawRect)

{
  int iVar1;
  int *piVar2;
  undefined *puVar3;
  char cVar4;
  id pvVar5;
  HSCrayonItem *pHVar6;
  id pvVar7;
  id pvVar8;
  undefined *puVar9;
  int *piVar10;
  undefined8 local_44;
  float local_3c;
  undefined4 uStack_38;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend(self,sel_layout_);
  pvVar5 = _objc_msgSend(self,sel_items);
  pvVar5 = _objc_msgSend(pvVar5,sel_objectEnumerator);
  pHVar6 = _objc_msgSend(pvVar5,sel_nextObject);
  puVar3 = PTR_0033607c;
  piVar2 = (int *)&stack0xffffff94;
  while (pHVar6 != (HSCrayonItem *)0x0) {
    piVar2[2] = (int)sel_frame;
    piVar2[1] = (int)pHVar6;
    *piVar2 = (int)&local_34;
    piVar2[-1] = 0x145f08;
    _objc_msgSend_stret((void *)*piVar2,(id)piVar2[1],(SEL)piVar2[2]);
    piVar10 = piVar2 + -1;
    *(NSSize *)(piVar2 + 5) = drawRect.size;
    *(NSPoint *)(piVar2 + 3) = drawRect.origin;
    *(undefined8 *)(piVar2 + 1) = local_2c;
    *(undefined8 *)(piVar2 + -1) = local_34;
    piVar2[-2] = 0x145f3d;
    cVar4 = _NSIntersectsRect();
    if (cVar4 != '\0') {
      if (pHVar6 == self->_highlightedItem) {
        piVar2[1] = (int)sel_frame;
        *piVar2 = (int)pHVar6;
        piVar2[-1] = (int)&local_44;
        piVar2[-2] = 0x145f6a;
        _objc_msgSend_stret((void *)piVar2[-1],(id)*piVar2,(SEL)piVar2[1]);
        *(ulonglong *)(piVar2 + 1) = CONCAT44(uStack_38,local_3c);
        *(undefined8 *)(piVar2 + -1) = local_44;
        piVar2[4] = (int)(local_3c * -0.25);
        piVar2[-2] = (int)&local_24;
        piVar2[3] = 0;
        piVar2[-3] = 0x145fa9;
        _NSOffsetRect();
        *(undefined8 *)(piVar2 + 1) = local_1c;
        *(undefined8 *)(piVar2 + -1) = local_24;
        piVar2[-2] = (int)sel_setFrame_;
        piVar2[-3] = (int)pHVar6;
        piVar2[-4] = 0x145fd4;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_currentContext;
        piVar2[-3] = (int)cls_NSGraphicsContext;
        piVar2[-4] = 0x145fec;
        pvVar7 = _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_saveGraphicsState;
        piVar2[-3] = (int)pvVar7;
        piVar2[-4] = 0x145ffe;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_new;
        piVar2[-3] = (int)cls_NSShadow;
        piVar2[-4] = 0x146016;
        pvVar7 = _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_colorWithCalibratedWhite_alpha_;
        piVar2[-3] = (int)cls_NSColor;
        *piVar2 = 0x3f400000;
        piVar2[-1] = 0;
        piVar2[-4] = 0x146040;
        pvVar8 = _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-1] = (int)pvVar8;
        piVar2[-2] = (int)sel_setShadowColor_;
        piVar2[-3] = (int)pvVar7;
        piVar2[-4] = 0x146056;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        iVar1 = *(int *)puVar3;
        *piVar2 = *(int *)(puVar3 + 4);
        piVar2[-1] = iVar1;
        piVar2[-2] = (int)sel_setShadowOffset_;
        piVar2[-3] = (int)pvVar7;
        piVar2[-4] = 0x146080;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_setShadowBlurRadius_;
        piVar2[-3] = (int)pvVar7;
        piVar2[-1] = 0x40a00000;
        piVar2[-4] = 0x14609a;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_set;
        piVar2[-3] = (int)pvVar7;
        piVar2[-4] = 0x1460ac;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-1] = (int)self;
        piVar2[-2] = (int)sel_drawInView_;
        piVar2[-3] = (int)pHVar6;
        piVar2[-4] = 0x1460c5;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_release;
        piVar2[-3] = (int)pvVar7;
        piVar2[-4] = 0x1460d7;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_currentContext;
        piVar2[-3] = (int)cls_NSGraphicsContext;
        piVar2[-4] = 0x1460ef;
        pvVar7 = _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        piVar2[-2] = (int)sel_restoreGraphicsState;
        piVar2[-3] = (int)pvVar7;
        piVar2[-4] = 0x146101;
        _objc_msgSend((id)piVar2[-3],(SEL)piVar2[-2]);
        *(ulonglong *)(piVar2 + 1) = CONCAT44(uStack_38,local_3c);
        *(undefined8 *)(piVar2 + -1) = local_44;
        puVar9 = sel_setFrame_;
        piVar10 = piVar2 + -3;
      }
      else {
        piVar2[1] = (int)self;
        puVar9 = sel_drawInView_;
        piVar10 = piVar2 + -1;
      }
      piVar10[1] = (int)puVar9;
      *piVar10 = (int)pHVar6;
      piVar10[-1] = 0x146129;
      _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    }
    piVar10[1] = (int)sel_nextObject;
    *piVar10 = (int)pvVar5;
    piVar10[-1] = 0x14613e;
    pHVar6 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    piVar2 = piVar10;
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [self layout:NO];
    NSEnumerator *enumerator = [[self items] objectEnumerator];
    HSCrayonItem *item;
    while ((item = [enumerator nextObject]) != nil) {
        if (!NSIntersectsRect([item frame], aRect)) {
            continue;
        }
        if (item == _highlightedItem) {
            NSRect frame = [item frame];
            [item setFrame:NSOffsetRect(frame, 0.0, frame.size.width * -0.25)];
            [[NSGraphicsContext currentContext] saveGraphicsState];
            NSShadow *shadow = [NSShadow new];
            [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.75f]];
            [shadow setShadowOffset:NSZeroSize];
            [shadow setShadowBlurRadius:5.0];
            [shadow set];
            [item drawInView:self];
            [shadow release];
            [[NSGraphicsContext currentContext] restoreGraphicsState];
            [item setFrame:frame];
        }
        else {
            [item drawInView:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014615f @ 0014615f, 755 bytes * /

void FUN_0014615f(HSCrayonsView *self,SEL _cmd,BOOL layout)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int *piVar5;
  int *piVar6;
  int iVar7;
  float fVar8;
  int aiStack_9c [2];
  float local_64;
  uint local_60;
  undefined1 local_44 [8];
  float local_3c;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [12];
  undefined4 local_18;
  
  pvVar2 = _objc_msgSend(self,sel_needsLayout);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend_stret(local_44,self,sel_frame);
    pvVar2 = _objc_msgSend(self,sel_numberOfColumns);
    _objc_msgSend_stret(local_34,self,sel_frame);
    piVar6 = (int *)&stack0xffffff6c;
    pvVar3 = _objc_msgSend(self,sel_numberOfRows);
    pvVar4 = _objc_msgSend(self,sel_items);
    _objc_msgSend(pvVar4,sel_removeAllObjects);
    pvVar4 = _objc_msgSend(self,sel_numberOfRows);
    if (0 < (int)pvVar4) {
      fVar8 = local_3c / ((float)(int)pvVar2 + 0.5);
      local_60 = 0;
      do {
        piVar6[1] = (int)sel_numberOfColumns;
        *piVar6 = (int)self;
        local_64 = 0.0;
        if ((local_60 & 1) != 0) {
          local_64 = fVar8 * 0.5;
        }
        piVar6[-1] = 0x1462c2;
        pvVar2 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
        if (0 < (int)pvVar2) {
          iVar7 = 0;
          piVar5 = piVar6;
          do {
            piVar5[2] = (int)sel_frame;
            piVar5[1] = (int)self;
            *piVar5 = (int)local_24;
            piVar5[-1] = 0x146312;
            _objc_msgSend_stret((void *)*piVar5,(id)piVar5[1],(SEL)piVar5[2]);
            uVar1 = local_18;
            piVar6 = piVar5 + -1;
            piVar5[2] = iVar7;
            piVar5[1] = local_60;
            *piVar5 = (int)sel_colorForRow_column_;
            piVar5[-1] = (int)self;
            piVar5[-2] = 0x14635d;
            pvVar2 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            *piVar5 = (int)sel_alloc;
            piVar5[-1] = (int)cls_HSCrayonItem;
            piVar5[-2] = 0x146377;
            pvVar4 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            *(ulonglong *)(piVar5 + 4) = CONCAT44(uVar1,fVar8);
            *(ulonglong *)(piVar5 + 2) =
                 CONCAT44((float)(int)local_60 * ((local_28 + -5.0) / (float)((int)pvVar3 + 1)) +
                          5.0,(float)iVar7 * fVar8 + local_64);
            piVar5[1] = (int)pvVar2;
            *piVar5 = (int)sel_initWithColor_frame_;
            piVar5[-1] = (int)pvVar4;
            piVar5[-2] = 0x1463a3;
            pvVar2 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            if (layout != '\0') {
              piVar5[1] = (int)self;
              *piVar5 = (int)sel_imageForView_;
              piVar5[-1] = (int)pvVar2;
              piVar5[-2] = 0x1463c4;
              _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            }
            iVar7 = iVar7 + 1;
            *piVar5 = (int)sel_items;
            piVar5[-1] = (int)self;
            piVar5[-2] = 0x1463da;
            pvVar4 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            piVar5[1] = (int)pvVar2;
            *piVar5 = (int)sel_addObject_;
            piVar5[-1] = (int)pvVar4;
            piVar5[-2] = 0x1463f0;
            _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            *piVar5 = (int)sel_release;
            piVar5[-1] = (int)pvVar2;
            piVar5[-2] = 0x146402;
            _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            *piVar5 = (int)sel_numberOfColumns;
            piVar5[-1] = (int)self;
            piVar5[-2] = 0x146417;
            pvVar2 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
            piVar5 = piVar5 + -1;
          } while (iVar7 < (int)pvVar2);
        }
        local_60 = local_60 + 1;
        piVar6[1] = (int)sel_numberOfRows;
        *piVar6 = (int)self;
        piVar6[-1] = 0x14643b;
        pvVar2 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      } while ((int)local_60 < (int)pvVar2);
    }
    self->_layoutIsValid = '\x01';
  }
  return;
}

*/
- (void)layout:(BOOL)aLayout
{
    if (![self needsLayout]) {
        return;
    }
    float width = [self frame].size.width;
    NSInteger columns = [self numberOfColumns];
    float height = [self frame].size.height;
    NSInteger rows = [self numberOfRows];
    [[self items] removeAllObjects];
    if ([self numberOfRows] > 0) {
        float colWidth = width / ((float)columns + 0.5);
        float rowHeight = (height + -5.0) / (float)(rows + 1);
        float oddOffset = colWidth * 0.5;
        for (NSInteger row = 0; row < [self numberOfRows]; row++) {
            float rowOffset = (row & 1) ? oddOffset : 0.0;
            float y = (float)row * rowHeight + 5.0;
            for (NSInteger column = 0; column < [self numberOfColumns]; column++) {
                float itemHeight = [self frame].size.height;
                float x = (float)column * colWidth + rowOffset;
                id color = [self colorForRow:row column:column];
                HSCrayonItem *item = [[HSCrayonItem alloc] initWithColor:color frame:NSMakeRect(x, y, colWidth, itemHeight)];
                if (aLayout) {
                    [item imageForView:self];
                }
                [[self items] addObject:item];
                [item release];
            }
        }
    }
    _layoutIsValid = YES;
}

- (id)defaultDataSource
{
    id pvVar1;

    pvVar1 = _defaultDataSource;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultDataSourceClass] new];
        _defaultDataSource = pvVar1;
    }
    return pvVar1;
}

- (id)colorForRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [[self dataSource] crayonsView:self colorForRow:aRow column:aColumn];
}

- (void)setNeedsLayout:(BOOL)aLayout
{
    _layoutIsValid = aLayout == NO;
}

- (BOOL)needsLayout
{
    return _layoutIsValid == NO;
}

- (id)items
{
    id pvVar1;

    pvVar1 = _items;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _items = pvVar1;
    }
    return pvVar1;
}

- (void)setNeedsForceLayout:(BOOL)aLayout
{
    _needsForceLayout = aLayout;
}

- (void)setNumberOfColumns:(NSInteger)aColumns
{
    if (_numberOfColumns != aColumns) {
        _numberOfColumns = aColumns;
        [self setNeedsLayout:YES];
        [self setNeedsDisplay:YES];
    }
}

- (NSInteger)numberOfColumns
{
    id pvVar1;
    NSInteger pvVar1_3;

    pvVar1 = [self dataSource];
    if (![pvVar1 managesRowsAndColumnsCountForCrayonsView:self]) {
        pvVar1_3 = _numberOfColumns;
    }
    else {
        pvVar1_3 = [[self dataSource] numberOfColumnsInCrayonsView:self];
    }
    return (int)pvVar1_3;
}

- (void)setNumberOfRows:(NSInteger)aRows
{
    if (_numberOfRows != aRows) {
        _numberOfRows = aRows;
        [self setNeedsLayout:YES];
        [self setNeedsDisplay:YES];
    }
}

- (NSInteger)numberOfRows
{
    id pvVar1;
    NSInteger pvVar1_3;

    pvVar1 = [self dataSource];
    if (![pvVar1 managesRowsAndColumnsCountForCrayonsView:self]) {
        pvVar1_3 = _numberOfRows;
    }
    else {
        pvVar1_3 = [[self dataSource] numberOfRowsInCrayonsView:self];
    }
    return (int)pvVar1_3;
}

- (id)color
{
    id pvVar1;

    pvVar1 = _color;
    if (pvVar1 == nil) {
        pvVar1 = [[NSColor clearColor] retain];
        _color = pvVar1;
    }
    return pvVar1;
}

- (id)dataSource
{
    id pvVar1;

    pvVar1 = _dataSource;
    if (pvVar1 == nil) {
        pvVar1 = [self defaultDataSource];
        _dataSource = pvVar1;
    }
    return pvVar1;
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if (_needsForceLayout != NO) {
        if ([self window] != nil) {
            [self layout:YES];
        }
    }
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)dealloc
{
    [_color release];
    [_items release];
    [_highlightedItem release];
    [_defaultDataSource release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014586d @ 0014586d, 127 bytes * /

id FUN_0014586d(HSCrayonsView *self,SEL _cmd,NSRect initWithFrame)

{
  id self_00;
  HSCrayonsView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSControl_003517a0;
  self_00 = _objc_msgSendSuper(&local_14,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size)
  ;
  if (self_00 != (id)0x0) {
    *(undefined4 *)((int)self_00 + 0x60) = 6;
    *(undefined4 *)((int)self_00 + 100) = 8;
    _objc_msgSend(self_00,sel_setContinuous_,1);
  }
  return self_00;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        _numberOfRows = 6;
        _numberOfColumns = 8;
        [self setContinuous:YES];
    }
    return self;
}

@end

@implementation HSCrayonsView (Accessibility)

/* --- i386 decompilation (Ghidra) ---
/* FUN_001468c3 @ 001468c3, 289 bytes * /

id FUN_001468c3(HSCrayonsView *self,SEL _cmd,id accessibilityAttributeValue)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  undefined4 uVar3;
  HSCrayonsView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,
                         *(undefined4 *)PTR_00336370);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,
                           *(undefined4 *)PTR_00336374);
    if ((char)pvVar1 == '\0') {
      uVar3 = *(undefined4 *)PTR_0033653c;
      pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
      self_00 = cls_NSBundle;
      if ((char)pvVar1 == '\0') {
        local_1c = self;
        local_18 = cls_NSControl;
        pcVar2 = _objc_msgSendSuper(&local_1c,sel_accessibilityAttributeValue_,
                                    accessibilityAttributeValue);
      }
      else {
        pvVar1 = _objc_msgSend(self,sel_class,uVar3);
        pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
        pcVar2 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                               &cfstr_Set_of_predefined_colors,&cfstr_empty,&cfstr_ToolPalette);
      }
    }
    else {
      pcVar2 = &cfstr_empty;
    }
  }
  else {
    pcVar2 = *(cfstringStruct **)PTR_003365fc;
  }
  return pcVar2;
}

*/
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        return NSAccessibilityUnknownRole;
    }
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        return @"";
    }
    if ([aValue isEqualToString:NSAccessibilityDescriptionAttribute]) {
        return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Set of predefined colors" value:@"" table:@"ToolPalette"];
    }
    return [super accessibilityAttributeValue:aValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001469ed @ 001469ed, 9 bytes * /

id FUN_001469ed(HSCrayonsView *self,SEL _cmd)

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
/* FUN_001469e4 @ 001469e4, 9 bytes * /

id FUN_001469e4(HSCrayonsView *self,SEL _cmd,NSPoint accessibilityHitTest)

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

- (id)accessibilityAttributeNames
{
    return [[super accessibilityAttributeNames] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:NSAccessibilityDescriptionAttribute, NSAccessibilityRoleDescriptionAttribute, nil]];
}

@end

