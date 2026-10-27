#import "HSSplitView.h"

// Optional delegate method consulted before collapsing a subview from the divider.
@interface NSObject (HSSplitViewDelegate)
- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubviewAfterDoubleClickAtIndex:(NSInteger)aIndex;
@end

@implementation HSSplitView

/* i386 ivar offsets: _viewsWithZeroSize=0x54, _collapsedSubviews=0x58, _dividerBackgroundImage=0x5c, _dividerImage=0x60 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078a25 @ 00078a25, 595 bytes * /

void FUN_00078a25(HSSplitView *self,SEL _cmd,NSRect drawDividerInRect)

{
  float fVar1;
  float fVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  longdouble lVar6;
  longdouble lVar7;
  HSSplitView *local_1c;
  undefined *local_18;
  
  pvVar5 = self->_dividerBackgroundImage;
  if ((pvVar5 == (id)0x0) && (self->_dividerImage == (id)0x0)) {
    local_1c = self;
    local_18 = PTR_s_NSSplitView_0034e9b0;
    _objc_msgSendSuper(&local_1c,sel_drawDividerInRect_,drawDividerInRect.origin,
                       drawDividerInRect.size);
  }
  else {
    uVar4 = *(undefined8 *)PTR_00336078;
    uVar3 = *(undefined8 *)PTR_00336078;
    if (pvVar5 != (id)0x0) {
      pvVar5 = _objc_msgSend(pvVar5,sel_size);
      _objc_msgSend(self->_dividerBackgroundImage,sel_drawInRect_fromRect_operation_fraction_,
                    drawDividerInRect.origin,drawDividerInRect.size,uVar3,
                    CONCAT44(extraout_EDX,pvVar5),2,0x3f800000);
    }
    if (self->_dividerImage != (id)0x0) {
      fVar1 = *(float *)PTR_00336074;
      fVar2 = *(float *)(PTR_00336074 + 4);
      pvVar5 = _objc_msgSend(self->_dividerImage,sel_size);
      lVar6 = (longdouble)
              _floorf((drawDividerInRect.size.height * 0.5 + drawDividerInRect.origin.y) -
                      (extraout_EDX_00 * 0.5 + fVar2));
      lVar7 = (longdouble)
              _floorf((drawDividerInRect.size.width * 0.5 + drawDividerInRect.origin.x) -
                      ((float)pvVar5 * 0.5 + fVar1));
      _objc_msgSend(self->_dividerImage,sel_drawInRect_fromRect_operation_fraction_,
                    CONCAT44((float)lVar6,(float)lVar7),CONCAT44(extraout_EDX_00,pvVar5),uVar4,
                    CONCAT44(extraout_EDX_00,pvVar5),2,0x3f800000);
    }
  }
  return;
}

*/
- (void)drawDividerInRect:(NSRect)aRect
{
    NSSize size;
    NSRect rect;
    if (_dividerBackgroundImage == nil && _dividerImage == nil) {
        [super drawDividerInRect:aRect];
        return;
    }
    if (_dividerBackgroundImage != nil) {
        size = [_dividerBackgroundImage size];
        [_dividerBackgroundImage drawInRect:aRect fromRect:NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    }
    if (_dividerImage != nil) {
        size = [_dividerImage size];
        rect.origin.x = floorf((float)((aRect.size.width * 0.5 + aRect.origin.x) - (size.width * 0.5 + NSZeroPoint.x)));
        rect.origin.y = floorf((float)((aRect.size.height * 0.5 + aRect.origin.y) - (size.height * 0.5 + NSZeroPoint.y)));
        rect.size = size;
        [_dividerImage drawInRect:rect fromRect:NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    }
}

- (void)setDividerImage:(id)aImage
{
    if (_dividerImage != aImage) {
        [_dividerImage release];
        _dividerImage = [aImage retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)dividerImage
{
    return _dividerImage;
}

- (void)setDividerBackgroundImage:(id)aImage
{
    if (_dividerBackgroundImage != aImage) {
        [_dividerBackgroundImage release];
        _dividerBackgroundImage = [aImage retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)dividerBackgroundImage
{
    return _dividerBackgroundImage;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000787ba @ 000787ba, 276 bytes * /

void FUN_000787ba(HSSplitView *self,SEL _cmd,int performDoubleClickInDividerAtIndex)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_delegate);
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,
                         sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_);
  if (((char)pvVar2 == '\0') || (performDoubleClickInDividerAtIndex == -1)) {
    pvVar2 = (id)0xffffffff;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar1,sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_,self,
                           performDoubleClickInDividerAtIndex);
    pvVar2 = (id)performDoubleClickInDividerAtIndex;
    if ((char)pvVar3 == '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_,self,
                             (id)(performDoubleClickInDividerAtIndex + 1));
      pvVar2 = (id)0xffffffff;
      if ((char)pvVar1 != '\0') {
        pvVar2 = (id)(performDoubleClickInDividerAtIndex + 1);
      }
    }
  }
  pvVar1 = _objc_msgSend(self,sel_collapsedViewIndexWithDividerAtIndex_,
                         performDoubleClickInDividerAtIndex);
  if (pvVar2 != (id)0xffffffff) {
    op = sel_uncollapseSubviewAtIndex_withDividerAtIndex_;
    if (pvVar1 == (id)0xffffffff) {
      op = sel_collapseSubviewAtIndex_withDividerAtIndex_;
      pvVar1 = pvVar2;
    }
    _objc_msgSend(self,op,pvVar1,performDoubleClickInDividerAtIndex);
  }
  return;
}

*/
- (void)performDoubleClickInDividerAtIndex:(NSInteger)aIndex
{
    id delegate = [self delegate];
    NSInteger target;
    NSInteger collapsedIndex;
    if (![delegate respondsToSelector:@selector(splitView:canCollapseSubviewAfterDoubleClickAtIndex:)] || aIndex == -1) {
        target = -1;
    }
    else if ([delegate splitView:self canCollapseSubviewAfterDoubleClickAtIndex:aIndex]) {
        target = aIndex;
    }
    else {
        target = [delegate splitView:self canCollapseSubviewAfterDoubleClickAtIndex:aIndex + 1] ? aIndex + 1 : -1;
    }
    collapsedIndex = [self collapsedViewIndexWithDividerAtIndex:aIndex];
    if (target != -1) {
        if (collapsedIndex == -1) {
            [self collapseSubviewAtIndex:target withDividerAtIndex:aIndex];
        }
        else {
            [self uncollapseSubviewAtIndex:collapsedIndex withDividerAtIndex:aIndex];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078c78 @ 00078c78, 510 bytes * /

id FUN_00078c78(HSSplitView *self,SEL _cmd,int viewWithZeroSizeForSubviewAtndex)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar3 = (undefined4 *)&stack0xffffff94;
  pvVar1 = self->_viewsWithZeroSize;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_new);
    self->_viewsWithZeroSize = pvVar1;
  }
  _objc_msgSend(cls_NSNumber,sel_numberWithInt_);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSView,sel_new);
    pvVar2 = _objc_msgSend(self,sel_isVertical);
    if ((char)pvVar2 == '\0') {
      _objc_msgSend_stret(local_24,self,sel_frame);
    }
    else {
      _objc_msgSend_stret(local_34,self,sel_frame);
    }
    puVar3 = (undefined4 *)&stack0xffffff90;
    _objc_msgSend(pvVar1,sel_setFrame_);
    pvVar2 = self->_viewsWithZeroSize;
    _objc_msgSend(cls_NSNumber,sel_numberWithInt_);
    _objc_msgSend(pvVar2,sel_setObject_forKey_);
    _objc_msgSend(pvVar1,sel_release);
  }
  pvVar1 = self->_viewsWithZeroSize;
  puVar3[2] = viewWithZeroSizeForSubviewAtndex;
  puVar3[1] = sel_numberWithInt_;
  *puVar3 = cls_NSNumber;
  puVar3[-1] = 0x78e58;
  pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[2] = pvVar2;
  puVar3[1] = sel_objectForKey_;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x78e6e;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return pvVar1;
}

*/
- (id)viewWithZeroSizeForSubviewAtndex:(NSInteger)aAtndex
{
    NSView *view;
    NSRect frame;
    if (_viewsWithZeroSize == nil) {
        _viewsWithZeroSize = [NSMutableDictionary new];
    }
    if ([_viewsWithZeroSize objectForKey:[NSNumber numberWithInt:(int)aAtndex]] == nil) {
        // A placeholder spanning the split view's breadth with no extent along the split axis.
        view = [NSView new];
        frame = NSZeroRect;
        if ([self isVertical]) {
            frame.size.height = [self frame].size.height;
        }
        else {
            frame.size.width = [self frame].size.width;
        }
        [view setFrame:frame];
        [_viewsWithZeroSize setObject:view forKey:[NSNumber numberWithInt:(int)aAtndex]];
        [view release];
    }
    return [_viewsWithZeroSize objectForKey:[NSNumber numberWithInt:(int)aAtndex]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078e76 @ 00078e76, 181 bytes * /

float FUN_00078e76(HSSplitView *self,SEL _cmd,int bottomBoundFromSubviewAtIndex)

{
  id pvVar1;
  id pvVar2;
  float local_34 [2];
  float local_2c;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_isVertical);
  pvVar2 = _objc_msgSend(self,sel_subviews);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,bottomBoundFromSubviewAtIndex);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend_stret(local_24,pvVar2,sel_frame);
    local_34[0] = local_20 + local_18;
  }
  else {
    _objc_msgSend_stret(local_34,pvVar2,sel_frame);
    local_34[0] = local_34[0] + local_2c;
  }
  return local_34[0];
}

*/
- (CGFloat)bottomBoundFromSubviewAtIndex:(NSInteger)aIndex
{
    BOOL vertical = [self isVertical];
    NSRect frame = [[[self subviews] objectAtIndex:aIndex] frame];
    if (!vertical) {
        return frame.origin.y + frame.size.height;
    }
    return frame.origin.x + frame.size.width;
}

- (NSInteger)collapsedViewIndexWithDividerAtIndex:(NSInteger)aIndex
{
    id pvVar1;
    int iVar3;
    id pvVar1_2;
    id pvVar2_2;
    NSNumber *pvVar2_3;

    pvVar1 = [self collapsedSubviews];
    pvVar2_2 = [pvVar1 objectForKey:[NSNumber numberWithInt:aIndex]];
    iVar3 = aIndex;
    if (pvVar2_2 == nil) {
        pvVar2_3 = [NSNumber numberWithInt:aIndex + 1]
        ;
        pvVar1_2 = [pvVar1 objectForKey:pvVar2_3];
        iVar3 = -1;
        if (pvVar1_2 != nil) {
            iVar3 = aIndex + 1;
        }
    }
    return iVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078f2b @ 00078f2b, 414 bytes * /

void FUN_00078f2b(HSSplitView *self,SEL _cmd,int adjustSubviewsWithDividerAtIndex)

{
  float fVar1;
  id pvVar2;
  double dVar3;
  double dVar4;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_subviews);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
  _objc_msgSend_stret(&local_24,pvVar2,sel_frame);
  fStack_30 = local_20;
  local_34 = local_24;
  local_2c = local_1c;
  fStack_28 = local_18;
  dVar3 = _objc_msgSend_fpret(self,sel_dividerThickness);
  dVar4 = _objc_msgSend_fpret(self,sel_bottomBoundFromSubviewAtIndex_,
                              adjustSubviewsWithDividerAtIndex + 1);
  fVar1 = (float)dVar3;
  pvVar2 = _objc_msgSend(self,sel_isVertical);
  if ((char)pvVar2 == '\0') {
    fStack_30 = local_18 + fVar1 + fStack_30;
    fStack_28 = ((float)dVar4 - (local_18 + local_20)) - fVar1;
  }
  else {
    local_34 = local_1c + fVar1 + local_34;
    local_2c = ((float)dVar4 - (local_1c + local_24)) - fVar1;
  }
  pvVar2 = _objc_msgSend(self,sel_subviews);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,adjustSubviewsWithDividerAtIndex + 1);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(pvVar2,sel_setFrame_,CONCAT44(fStack_30,local_34),CONCAT44(fStack_28,local_2c));
  }
  _objc_msgSend(self,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)adjustSubviewsWithDividerAtIndex:(NSInteger)aIndex
{
    NSRect frame = [[[self subviews] objectAtIndex:aIndex] frame];
    NSRect nextFrame = frame;
    float thickness = (float)[self dividerThickness];
    float bottom = (float)[self bottomBoundFromSubviewAtIndex:aIndex + 1];
    id nextView;
    if (![self isVertical]) {
        nextFrame.origin.y = frame.size.height + thickness + frame.origin.y;
        nextFrame.size.height = (bottom - (frame.size.height + frame.origin.y)) - thickness;
    }
    else {
        nextFrame.origin.x = frame.size.width + thickness + frame.origin.x;
        nextFrame.size.width = (bottom - (frame.size.width + frame.origin.x)) - thickness;
    }
    nextView = [[self subviews] objectAtIndex:aIndex + 1];
    if (nextView != nil) {
        [nextView setFrame:nextFrame];
    }
    [self setNeedsDisplay:YES];
}

- (void)adjustSubviews
{

}

- (id)collapsedSubviews
{
    id pvVar1;

    pvVar1 = _collapsedSubviews;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _collapsedSubviews = pvVar1;
    }
    return pvVar1;
}

- (BOOL)isCollapsedSubview:(id)aSubview
{
    id pvVar2;
    NSEnumerator *pvVar1_2;

    pvVar1_2 = [[self collapsedSubviews] objectEnumerator];
    do {
        pvVar2 = [pvVar1_2 nextObject];
        if (pvVar2 == nil) {
            return NO;
        }
    } while (pvVar2 != aSubview);
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000785d2 @ 000785d2, 162 bytes * /

BOOL FUN_000785d2(HSSplitView *self,SEL _cmd,int isCollapsedSubviewAtIndex)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(self,sel_collapsedSubviews);
  pvVar3 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar3 == (id)0x0) {
LAB_0007860e:
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_allKeys);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    do {
      pvVar3 = _objc_msgSend(pvVar2,sel_nextObject);
      if (pvVar3 == (id)0x0) goto LAB_0007860e;
      pvVar3 = _objc_msgSend(pvVar3,sel_intValue);
    } while (pvVar3 != (id)isCollapsedSubviewAtIndex);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)isCollapsedSubviewAtIndex:(NSInteger)aIndex
{
    id collapsedSubviews = [self collapsedSubviews];
    NSEnumerator *enumerator;
    id key;
    if ([collapsedSubviews count] == 0) {
        return NO;
    }
    enumerator = [[collapsedSubviews allKeys] objectEnumerator];
    while ((key = [enumerator nextObject]) != nil) {
        if ([key intValue] == aIndex) {
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000790c9 @ 000790c9, 609 bytes * /

void FUN_000790c9(HSSplitView *self,SEL _cmd,int uncollapseSubviewAtIndex,int withDividerAtIndex)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id pvVar3;
  undefined4 *puVar4;
  double dVar5;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  float local_34 [4];
  undefined1 local_24 [4];
  float local_20;
  
  puVar4 = (undefined4 *)&stack0xffffff84;
  pvVar1 = _objc_msgSend(self,sel_collapsedSubviews);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_viewWithZeroSizeForSubviewAtndex_);
    self_00 = _objc_msgSend(self,sel_collapsedSubviews);
    _objc_msgSend(cls_NSNumber,sel_numberWithInt_);
    self_01 = _objc_msgSend(self_00,sel_objectForKey_);
    if (withDividerAtIndex + 1 == uncollapseSubviewAtIndex) {
      pvVar2 = _objc_msgSend(self,sel_subviews);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
      _objc_msgSend_stret(&local_44,pvVar2,sel_frame);
      pvVar3 = _objc_msgSend(self,sel_isVertical);
      if ((char)pvVar3 == '\0') {
        _objc_msgSend_stret(local_24,self_01,sel_frame);
        dVar5 = _objc_msgSend_fpret(self,sel_dividerThickness);
        fStack_38 = (local_20 - fStack_40) - (float)dVar5;
      }
      else {
        _objc_msgSend_stret(local_34,self_01,sel_frame);
        dVar5 = _objc_msgSend_fpret(self,sel_dividerThickness);
        local_3c = (local_34[0] - local_44) - (float)dVar5;
      }
      puVar4 = (undefined4 *)&stack0xffffff7c;
      _objc_msgSend(pvVar2,sel_setFrame_);
    }
    puVar4[3] = self_01;
    puVar4[2] = pvVar1;
    puVar4[1] = sel_replaceSubview_with_;
    *puVar4 = self;
    puVar4[-1] = 0x792d1;
    _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
    puVar4[2] = uncollapseSubviewAtIndex;
    puVar4[1] = sel_numberWithInt_;
    *puVar4 = cls_NSNumber;
    puVar4[-1] = 0x792f0;
    pvVar1 = _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
    puVar4[2] = pvVar1;
    puVar4[1] = sel_removeObjectForKey_;
    *puVar4 = self_00;
    puVar4[-1] = 0x79309;
    _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
    puVar4[2] = withDividerAtIndex;
    puVar4[1] = sel_adjustSubviewsWithDividerAtIndex_;
    *puVar4 = self;
    puVar4[-1] = 0x79322;
    _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  }
  return;
}

*/
- (void)uncollapseSubviewAtIndex:(NSInteger)aIndex withDividerAtIndex:(NSInteger)aIndex2
{
    id zeroSizeView;
    id collapsedSubviews;
    NSView *collapsedView;
    NSView *dividerView;
    NSRect frame;
    if ([[self collapsedSubviews] count] == 0) {
        return;
    }
    zeroSizeView = [self viewWithZeroSizeForSubviewAtndex:aIndex];
    collapsedSubviews = [self collapsedSubviews];
    collapsedView = [collapsedSubviews objectForKey:[NSNumber numberWithInt:(int)aIndex]];
    if (aIndex2 + 1 == aIndex) {
        dividerView = [[self subviews] objectAtIndex:aIndex2];
        frame = [dividerView frame];
        if ([self isVertical]) {
            frame.size.width = ([collapsedView frame].origin.x - frame.origin.x) - (float)[self dividerThickness];
        }
        else {
            frame.size.height = ([collapsedView frame].origin.y - frame.origin.y) - (float)[self dividerThickness];
        }
        [dividerView setFrame:frame];
    }
    [self replaceSubview:zeroSizeView with:collapsedView];
    [collapsedSubviews removeObjectForKey:[NSNumber numberWithInt:(int)aIndex]];
    [self adjustSubviewsWithDividerAtIndex:aIndex2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007932a @ 0007932a, 679 bytes * /

void FUN_0007932a(HSSplitView *self,SEL _cmd,int collapseSubviewAtIndex,int withDividerAtIndex)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  double dVar7;
  float local_50;
  float local_4c;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  
  pvVar2 = _objc_msgSend(self,sel_isCollapsedSubviewAtIndex_);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_viewWithZeroSizeForSubviewAtndex_);
    pvVar3 = _objc_msgSend(self,sel_subviews);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_);
    pvVar4 = _objc_msgSend(self,sel_subviews);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_);
    _objc_msgSend_stret(&local_24,pvVar4,sel_frame);
    puVar6 = (undefined4 *)&stack0xffffff90;
    local_4c = local_24;
    local_50 = local_20;
    if (withDividerAtIndex + 1 == collapseSubviewAtIndex) {
      _objc_msgSend_stret(&local_34,pvVar4,sel_frame);
      puVar6 = (undefined4 *)&stack0xffffff8c;
      dVar7 = _objc_msgSend_fpret(self,sel_bottomBoundFromSubviewAtIndex_);
      fVar1 = (float)dVar7;
      pvVar5 = _objc_msgSend(self,sel_isVertical);
      if ((char)pvVar5 == '\0') {
        dVar7 = _objc_msgSend_fpret(self,sel_dividerThickness);
        fStack_28 = (fVar1 - fStack_30) - (float)dVar7;
        local_50 = fVar1;
      }
      else {
        dVar7 = _objc_msgSend_fpret(self,sel_dividerThickness);
        local_2c = (fVar1 - local_34) - (float)dVar7;
        local_4c = fVar1;
      }
      _objc_msgSend(pvVar4,sel_setFrame_);
    }
    puVar6[3] = local_50;
    puVar6[2] = local_4c;
    puVar6[1] = sel_setFrameOrigin_;
    *puVar6 = pvVar2;
    puVar6[-1] = 0x7953a;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[1] = sel_collapsedSubviews;
    *puVar6 = self;
    puVar6[-1] = 0x7954f;
    pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[2] = collapseSubviewAtIndex;
    puVar6[1] = sel_numberWithInt_;
    *puVar6 = cls_NSNumber;
    puVar6[-1] = 0x79570;
    pvVar5 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[3] = pvVar5;
    puVar6[2] = pvVar3;
    puVar6[1] = sel_setObject_forKey_;
    *puVar6 = pvVar4;
    puVar6[-1] = 0x7958d;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[3] = pvVar2;
    puVar6[2] = pvVar3;
    puVar6[1] = sel_replaceSubview_with_;
    *puVar6 = self;
    puVar6[-1] = 0x795ad;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[2] = withDividerAtIndex;
    puVar6[1] = sel_adjustSubviewsWithDividerAtIndex_;
    *puVar6 = self;
    puVar6[-1] = 0x795c9;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  }
  return;
}

*/
- (void)collapseSubviewAtIndex:(NSInteger)aIndex withDividerAtIndex:(NSInteger)aIndex2
{
    NSView *zeroSizeView;
    NSView *collapsedView;
    NSView *dividerView;
    NSRect frame;
    NSPoint origin;
    float bottom;
    if ([self isCollapsedSubviewAtIndex:aIndex]) {
        return;
    }
    zeroSizeView = [self viewWithZeroSizeForSubviewAtndex:aIndex];
    collapsedView = [[self subviews] objectAtIndex:aIndex];
    dividerView = [[self subviews] objectAtIndex:aIndex2];
    origin = [dividerView frame].origin;
    if (aIndex2 + 1 == aIndex) {
        frame = [dividerView frame];
        bottom = (float)[self bottomBoundFromSubviewAtIndex:aIndex2 + 1];
        if ([self isVertical]) {
            frame.size.width = (bottom - frame.origin.x) - (float)[self dividerThickness];
            origin.x = bottom;
        }
        else {
            frame.size.height = (bottom - frame.origin.y) - (float)[self dividerThickness];
            origin.y = bottom;
        }
        [dividerView setFrame:frame];
    }
    [zeroSizeView setFrameOrigin:origin];
    [[self collapsedSubviews] setObject:collapsedView forKey:[NSNumber numberWithInt:(int)aIndex]];
    [self replaceSubview:collapsedView with:zeroSizeView];
    [self adjustSubviewsWithDividerAtIndex:aIndex2];
}

- (CGFloat)constrainValueWithProposedDividerCoordinate:(CGFloat)aCoordinate withDividerAtIndex:(NSInteger)aIndex
{
    float fVar1;
    float fVar2;
    id self_00;
    float fVar4;
    float fVar5;
    double dVar6;
    double dVar7;
    double dVar6_2;

    dVar6 = [self minConstrainCoordinateWithDividerAtIndex:aIndex]
    ;
    dVar7 = [self maxConstrainCoordinateWithDividerAtIndex:aIndex]
    ;
    self_00 = [self delegate];
    fVar1 = (float)dVar6;
    fVar2 = (float)dVar7;
    if (aCoordinate <= fVar1) {
        aCoordinate = fVar1;
    }
    fVar5 = fVar2;
    if (aCoordinate <= fVar2) {
        fVar5 = aCoordinate;
    }
    if ([self_00 respondsToSelector:@selector(splitView:constrainSplitPosition:ofSubviewAt:)]) {
        dVar6_2 = [self_00 splitView:self constrainSplitPosition:fVar5 ofSubviewAt:0];
        fVar4 = (float)dVar6_2;
        if ((float)dVar6_2 <= fVar1) {
            fVar4 = fVar1;
        }
        fVar5 = fVar2;
        if (fVar4 <= fVar2) {
            fVar5 = fVar4;
        }
    }
    return fVar5;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000796dc @ 000796dc, 329 bytes * /

void FUN_000796dc(HSSplitView *self,SEL _cmd,float resizeSubviewsWithNewConstrainValue,
                 int withDividerAtIndex)

{
  id pvVar1;
  id pvVar2;
  undefined8 in_stack_ffffffd0;
  undefined4 uVar4;
  undefined8 uVar3;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffffd0 >> 0x20);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  uVar3 = CONCAT44(uVar4,self);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_);
  pvVar1 = _objc_msgSend(self,sel_subviews);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_);
  _objc_msgSend_stret(&local_24,pvVar1,sel_frame,uVar3);
  pvVar2 = _objc_msgSend(self,sel_isVertical);
  if ((char)pvVar2 == '\0') {
    fStack_18 = resizeSubviewsWithNewConstrainValue - fStack_20;
  }
  else {
    local_1c = resizeSubviewsWithNewConstrainValue - local_24;
  }
  _objc_msgSend(pvVar1,sel_setFrame_,CONCAT44(fStack_20,local_24),CONCAT44(fStack_18,local_1c));
  _objc_msgSend(self,sel_adjustSubviewsWithDividerAtIndex_,withDividerAtIndex);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,*(undefined4 *)PTR_003363e8,self);
  return;
}

*/
- (void)resizeSubviewsWithNewConstrainValue:(CGFloat)aValue withDividerAtIndex:(NSInteger)aIndex
{
    NSView *view;
    NSRect frame;
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewWillResizeSubviewsNotification object:self];
    view = [[self subviews] objectAtIndex:aIndex];
    frame = [view frame];
    if ([self isVertical]) {
        frame.size.width = (float)aValue - frame.origin.x;
    }
    else {
        frame.size.height = (float)aValue - frame.origin.y;
    }
    [view setFrame:frame];
    [self adjustSubviewsWithDividerAtIndex:aIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00079825 @ 00079825, 833 bytes * /

BOOL FUN_00079825(HSSplitView *self,SEL _cmd,float isChangeCollapseStateWithMouseLocation,
                 int withDividerAtIndex)

{
  int iVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  int iVar6;
  int iVar7;
  double dVar8;
  double dVar9;
  double dVar10;
  SEL op;
  float local_24;
  float local_20;
  
  pvVar3 = _objc_msgSend(self,sel_delegate);
  pvVar4 = _objc_msgSend(pvVar3,sel_respondsToSelector_,sel_splitView_canCollapseSubview_);
  if ((char)pvVar4 != '\0') {
    dVar8 = _objc_msgSend_fpret(self,sel_maxConstrainCoordinateWithDividerAtIndex_,
                                withDividerAtIndex);
    dVar9 = _objc_msgSend_fpret(self,sel_minConstrainCoordinateWithDividerAtIndex_,
                                withDividerAtIndex);
    iVar1 = withDividerAtIndex + 1;
    dVar10 = _objc_msgSend_fpret(self,sel_bottomBoundFromSubviewAtIndex_,iVar1);
    pvVar4 = _objc_msgSend(self,sel_subviews);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,withDividerAtIndex);
    _objc_msgSend_stret(&local_24,pvVar4,sel_frame);
    pvVar4 = _objc_msgSend(self,sel_isVertical);
    if ((char)pvVar4 != '\0') {
      local_20 = local_24;
    }
    iVar5 = (int)(((float)dVar10 - (float)dVar8) * 0.5 + (float)dVar8);
    iVar7 = (int)isChangeCollapseStateWithMouseLocation;
    if ((iVar7 < iVar5) ||
       (pvVar4 = _objc_msgSend(self,sel_isCollapsedSubviewAtIndex_,iVar1), (char)pvVar4 != '\0')) {
      iVar6 = (int)(((float)dVar9 - local_20) * -0.5 + (float)dVar9);
      if ((iVar6 < iVar7) ||
         (pvVar4 = _objc_msgSend(self,sel_isCollapsedSubviewAtIndex_,withDividerAtIndex),
         (char)pvVar4 != '\0')) {
        if (iVar7 < iVar6) {
          return '\0';
        }
        if (iVar5 < iVar7) {
          return '\0';
        }
        pvVar3 = _objc_msgSend(self,sel_isCollapsedSubviewAtIndex_,withDividerAtIndex);
        op = sel_uncollapseSubviewAtIndex_withDividerAtIndex_;
        iVar5 = withDividerAtIndex;
        if ((char)pvVar3 != '\0') goto LAB_00079ace;
        pvVar3 = _objc_msgSend(self,sel_isCollapsedSubviewAtIndex_,iVar1);
        cVar2 = (char)pvVar3;
        op = sel_uncollapseSubviewAtIndex_withDividerAtIndex_;
      }
      else {
        pvVar4 = _objc_msgSend(pvVar3,sel_respondsToSelector_,
                               sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_);
        if ((char)pvVar4 == '\0') {
          return '\0';
        }
        pvVar3 = _objc_msgSend(pvVar3,sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_,self,
                               withDividerAtIndex);
        cVar2 = (char)pvVar3;
        iVar1 = withDividerAtIndex;
        op = sel_collapseSubviewAtIndex_withDividerAtIndex_;
      }
    }
    else {
      pvVar4 = _objc_msgSend(pvVar3,sel_respondsToSelector_,
                             sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_);
      if ((char)pvVar4 == '\0') {
        return '\0';
      }
      pvVar3 = _objc_msgSend(pvVar3,sel_splitView_canCollapseSubviewAfterDoubleClickAtIndex_,self,
                             iVar1);
      cVar2 = (char)pvVar3;
      op = sel_collapseSubviewAtIndex_withDividerAtIndex_;
    }
    iVar5 = iVar1;
    if (cVar2 != '\0') {
LAB_00079ace:
      _objc_msgSend(self,op,iVar5,withDividerAtIndex);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)isChangeCollapseStateWithMouseLocation:(CGFloat)aLocation withDividerAtIndex:(NSInteger)aIndex
{
    id delegate = [self delegate];
    float maxCoordinate;
    float minCoordinate;
    float bottom;
    float origin;
    NSInteger nextIndex;
    NSRect frame;
    int collapseThreshold;
    int expandThreshold;
    int location;
    BOOL change;
    SEL action;
    NSInteger index;
    if (![delegate respondsToSelector:@selector(splitView:canCollapseSubview:)]) {
        return NO;
    }
    maxCoordinate = (float)[self maxConstrainCoordinateWithDividerAtIndex:aIndex];
    minCoordinate = (float)[self minConstrainCoordinateWithDividerAtIndex:aIndex];
    nextIndex = aIndex + 1;
    bottom = (float)[self bottomBoundFromSubviewAtIndex:nextIndex];
    frame = [[[self subviews] objectAtIndex:aIndex] frame];
    origin = [self isVertical] ? frame.origin.x : frame.origin.y;
    // Dragging past half of the remaining space collapses the neighbour; dragging back expands it.
    collapseThreshold = (int)((bottom - maxCoordinate) * 0.5f + maxCoordinate);
    location = (int)aLocation;
    if (location >= collapseThreshold && ![self isCollapsedSubviewAtIndex:nextIndex]) {
        if (![delegate respondsToSelector:@selector(splitView:canCollapseSubviewAfterDoubleClickAtIndex:)]) {
            return NO;
        }
        change = [delegate splitView:self canCollapseSubviewAfterDoubleClickAtIndex:nextIndex];
        action = @selector(collapseSubviewAtIndex:withDividerAtIndex:);
        index = nextIndex;
    }
    else {
        expandThreshold = (int)((minCoordinate - origin) * -0.5f + minCoordinate);
        if (location <= expandThreshold && ![self isCollapsedSubviewAtIndex:aIndex]) {
            if (![delegate respondsToSelector:@selector(splitView:canCollapseSubviewAfterDoubleClickAtIndex:)]) {
                return NO;
            }
            change = [delegate splitView:self canCollapseSubviewAfterDoubleClickAtIndex:aIndex];
            action = @selector(collapseSubviewAtIndex:withDividerAtIndex:);
            index = aIndex;
        }
        else {
            if (location < expandThreshold || collapseThreshold < location) {
                return NO;
            }
            if ([self isCollapsedSubviewAtIndex:aIndex]) {
                [self uncollapseSubviewAtIndex:aIndex withDividerAtIndex:aIndex];
                return YES;
            }
            change = [self isCollapsedSubviewAtIndex:nextIndex];
            action = @selector(uncollapseSubviewAtIndex:withDividerAtIndex:);
            index = nextIndex;
        }
    }
    if (!change) {
        return NO;
    }
    if (action == @selector(collapseSubviewAtIndex:withDividerAtIndex:)) {
        [self collapseSubviewAtIndex:index withDividerAtIndex:aIndex];
    }
    else {
        [self uncollapseSubviewAtIndex:index withDividerAtIndex:aIndex];
    }
    return YES;
}

- (CGFloat)maxConstrainCoordinateWithDividerAtIndex:(NSInteger)aIndex
{
    id self_00;
    double dVar2;
    double dVar3;
    float local_20;

    dVar2 = [self bottomBoundFromSubviewAtIndex:aIndex + 1];
    local_20 = (float)dVar2;
    dVar3 = [self dividerThickness];
    if ((int)dVar3 <= (int)dVar2) {
        local_20 = local_20 - (float)dVar3;
    }
    self_00 = [self delegate];
    if ([self_00 respondsToSelector:@selector(splitView:constrainMaxCoordinate:ofSubviewAt:)]) {
        local_20 = (float)[self_00 splitView:self constrainMaxCoordinate:local_20 ofSubviewAt:aIndex];
    }
    return local_20;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00079c48 @ 00079c48, 243 bytes * /

float FUN_00079c48(HSSplitView *self,SEL _cmd,int minConstrainCoordinateWithDividerAtIndex)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  float local_24;
  float local_20;
  
  pvVar1 = _objc_msgSend(self,sel_subviews);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,minConstrainCoordinateWithDividerAtIndex);
  _objc_msgSend_stret(&local_24,pvVar1,sel_frame);
  pvVar1 = _objc_msgSend(self,sel_isVertical);
  if ((char)pvVar1 != '\0') {
    local_20 = local_24;
  }
  pvVar1 = _objc_msgSend(self,sel_delegate);
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,
                         sel_splitView_constrainMinCoordinate_ofSubviewAt_);
  if ((char)pvVar2 != '\0') {
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_splitView_constrainMinCoordinate_ofSubviewAt_,self,
                                local_20,minConstrainCoordinateWithDividerAtIndex);
    local_20 = (float)dVar3;
  }
  return local_20;
}

*/
- (CGFloat)minConstrainCoordinateWithDividerAtIndex:(NSInteger)aIndex
{
    NSRect frame = [[[self subviews] objectAtIndex:aIndex] frame];
    float coordinate = [self isVertical] ? frame.origin.x : frame.origin.y;
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)]) {
        coordinate = (float)[delegate splitView:self constrainMinCoordinate:coordinate ofSubviewAt:aIndex];
    }
    return coordinate;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00079d3b @ 00079d3b, 289 bytes * /

int FUN_00079d3b(HSSplitView *self,SEL _cmd,NSPoint hitTestIndexAtPoint)

{
  float fVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  NSPoint *pNVar5;
  int iVar6;
  int *piVar7;
  float fVar8;
  double dVar9;
  int aiStack_64 [2];
  float local_34 [2];
  float local_2c;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_isVertical);
  self_00 = _objc_msgSend(self,sel_subviews);
  pNVar5 = &hitTestIndexAtPoint;
  if ((char)pvVar2 == '\0') {
    pNVar5 = (NSPoint *)&hitTestIndexAtPoint.y;
  }
  fVar1 = pNVar5->x;
  iVar6 = 0;
  pvVar3 = _objc_msgSend(self_00,sel_count);
  piVar7 = (int *)&stack0xffffffa4;
  do {
    if ((int)pvVar3 <= iVar6) {
      return -1;
    }
    piVar7[2] = iVar6;
    piVar7[1] = (int)sel_objectAtIndex_;
    *piVar7 = (int)self_00;
    piVar7[-1] = 0x79dbd;
    pvVar4 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    if ((char)pvVar2 == '\0') {
      piVar7[2] = (int)sel_frame;
      piVar7[1] = (int)pvVar4;
      *piVar7 = (int)local_24;
      piVar7[-1] = 0x79dfe;
      _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
      fVar8 = local_20 + local_18;
    }
    else {
      piVar7[2] = (int)sel_frame;
      piVar7[1] = (int)pvVar4;
      *piVar7 = (int)local_34;
      piVar7[-1] = 0x79ddc;
      _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
      fVar8 = local_34[0] + local_2c;
    }
    if ((int)fVar8 < (int)fVar1) {
      *piVar7 = (int)sel_dividerThickness;
      piVar7[-1] = (int)self;
      piVar7[-2] = 0x79e2e;
      dVar9 = _objc_msgSend_fpret((id)piVar7[-1],(SEL)*piVar7);
      if ((int)fVar1 < (int)(fVar8 + (float)dVar9)) {
        return iVar6;
      }
    }
    iVar6 = iVar6 + 1;
    piVar7 = piVar7 + -1;
  } while( true );
}

*/
- (NSInteger)hitTestIndexAtPoint:(NSPoint)aPoint
{
    BOOL vertical = [self isVertical];
    NSArray *subviews = [self subviews];
    int coordinate = (int)(vertical ? aPoint.x : aPoint.y);
    NSInteger count = [subviews count];
    NSInteger i;
    NSRect frame;
    float edge;
    for (i = 0; i < count; i++) {
        frame = [[subviews objectAtIndex:i] frame];
        edge = vertical ? frame.origin.x + frame.size.width : frame.origin.y + frame.size.height;
        if ((int)edge < coordinate && coordinate < (int)(edge + (float)[self dividerThickness])) {
            return i;
        }
    }
    return -1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00079e5c @ 00079e5c, 790 bytes * /

void FUN_00079e5c(HSSplitView *self,SEL _cmd,id trackDividerEvent)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  id self_00;
  id self_01;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  id extraout_EDX_00;
  undefined4 extraout_EDX_01;
  id extraout_EDX_02;
  float fVar6;
  double dVar7;
  undefined *puVar8;
  undefined4 uVar9;
  id local_44;
  id local_40;
  float local_34 [2];
  float local_2c;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  pvVar1 = _objc_msgSend(trackDividerEvent,sel_locationInWindow);
  uVar9 = 0;
  local_40 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  pvVar1 = local_40;
  pvVar3 = extraout_EDX_00;
  puVar2 = _objc_msgSend(self,sel_hitTestIndexAtPoint_,local_40,extraout_EDX_00);
  if (puVar2 != (undefined *)0xffffffff) {
    pvVar3 = _objc_msgSend(self,sel_isVertical,pvVar1,pvVar3,uVar9);
    pvVar1 = _objc_msgSend(self,sel_subviews);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,puVar2);
    puVar8 = sel_frame;
    if ((char)pvVar3 == '\0') {
      _objc_msgSend_stret(local_24,pvVar1,sel_frame);
      local_44 = (id)(local_20 + local_18);
      local_40 = extraout_EDX_00;
    }
    else {
      _objc_msgSend_stret(local_34,pvVar1,sel_frame);
      local_44 = (id)(local_34[0] + local_2c);
    }
    fVar6 = (float)local_44 - (float)local_40;
    self_00 = _objc_msgSend(self,sel_collapsedSubviews);
    do {
      pvVar1 = _objc_msgSend(self,sel_window,pvVar1,puVar8);
      self_01 = _objc_msgSend(pvVar1,sel_nextEventMatchingMask_,0x44);
      pvVar1 = _objc_msgSend(self_01,sel_locationInWindow);
      uVar9 = 0;
      pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX_01,0);
      pvVar5 = extraout_EDX_02;
      if ((char)pvVar3 != '\0') {
        pvVar5 = pvVar1;
      }
      pvVar1 = pvVar5;
      puVar8 = puVar2;
      pvVar4 = _objc_msgSend(self,sel_isChangeCollapseStateWithMouseLocation_withDividerAtIndex_,
                             pvVar5,puVar2,uVar9);
      if ((char)pvVar4 == '\0') {
        pvVar1 = (id)((float)pvVar5 + fVar6);
        puVar8 = puVar2;
        dVar7 = _objc_msgSend_fpret(self,
                                    sel_constrainValueWithProposedDividerCoordinate_withDividerAtIndex_
                                   );
        pvVar5 = (id)(float)dVar7;
        if ((float)local_44 != (float)pvVar5) {
          pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,puVar2,puVar8,uVar9);
          pvVar4 = _objc_msgSend(self_00,sel_objectForKey_,pvVar1);
          if (pvVar4 == (id)0x0) {
            pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,puVar2 + 1,puVar8);
            pvVar4 = _objc_msgSend(self_00,sel_objectForKey_,pvVar1);
            if (pvVar4 == (id)0x0) {
              pvVar1 = pvVar5;
              puVar8 = puVar2;
              _objc_msgSend(self,sel_resizeSubviewsWithNewConstrainValue_withDividerAtIndex_,pvVar5,
                            puVar2);
              local_44 = pvVar5;
            }
          }
        }
      }
      pvVar5 = _objc_msgSend(self_01,sel_type,pvVar1,puVar8,uVar9);
    } while (pvVar5 != (id)0x2);
  }
  return;
}

*/
- (void)trackDividerEvent:(id)aEvent
{
    NSPoint point = [self convertPoint:[aEvent locationInWindow] fromView:nil];
    NSInteger index = [self hitTestIndexAtPoint:point];
    BOOL vertical;
    NSRect frame;
    float edge;
    float offset;
    float location;
    float value;
    id collapsedSubviews;
    NSEvent *event;
    if (index == -1) {
        return;
    }
    vertical = [self isVertical];
    frame = [[[self subviews] objectAtIndex:index] frame];
    if (!vertical) {
        edge = frame.origin.y + frame.size.height;
        offset = edge - point.y;
    }
    else {
        edge = frame.origin.x + frame.size.width;
        offset = edge - point.x;
    }
    collapsedSubviews = [self collapsedSubviews];
    do {
        event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged)];
        point = [self convertPoint:[event locationInWindow] fromView:nil];
        location = vertical ? point.x : point.y;
        if (![self isChangeCollapseStateWithMouseLocation:location withDividerAtIndex:index]) {
            value = (float)[self constrainValueWithProposedDividerCoordinate:location + offset withDividerAtIndex:index];
            if (edge != value
                && [collapsedSubviews objectForKey:[NSNumber numberWithInt:(int)index]] == nil
                && [collapsedSubviews objectForKey:[NSNumber numberWithInt:(int)index + 1]] == nil) {
                [self resizeSubviewsWithNewConstrainValue:value withDividerAtIndex:index];
                edge = value;
            }
        }
    } while ([event type] != NSEventTypeLeftMouseUp);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007852a @ 0007852a, 168 bytes * /

void FUN_0007852a(HSSplitView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(mouseDown,sel_clickCount);
  op = sel_trackDividerEvent_;
  if (pvVar1 == (id)0x2) {
    pvVar1 = _objc_msgSend(mouseDown,sel_locationInWindow);
    pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
    mouseDown = _objc_msgSend(self,sel_hitTestIndexAtPoint_,pvVar1,extraout_EDX_00);
    op = sel_performDoubleClickInDividerAtIndex_;
  }
  _objc_msgSend(self,op,mouseDown);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    if ([aDown clickCount] == 2) {
        [self performDoubleClickInDividerAtIndex:[self hitTestIndexAtPoint:[self convertPoint:[aDown locationInWindow] fromView:nil]]];
    }
    else {
        [self trackDividerEvent:aDown];
    }
}

- (void)dealloc
{
    [_collapsedSubviews release];
    [_viewsWithZeroSize release];
    [_dividerBackgroundImage release];
    [_dividerImage release];
    [super dealloc];
}

@end

