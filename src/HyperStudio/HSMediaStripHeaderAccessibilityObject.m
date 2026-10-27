#import "HSMediaStripHeaderAccessibilityObject.h"

@implementation HSMediaStripHeaderAccessibilityObject

/* i386 ivar offsets: _owner=0x4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00057b0b @ 00057b0b, 9 bytes * /

id FUN_00057b0b(HSMediaStripHeaderAccessibilityObject *self,SEL _cmd,NSPoint accessibilityHitTest)

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

- (void)accessibilityPerformAction:(id)aAction
{
    if ([aAction isEqualToString:NSAccessibilityPressAction]) {
        [_owner startRolling:self];
    }
}

- (id)accessibilityActionDescription:(id)aDescription
{
    NSString *pvVar1_2;

    if (![aDescription isEqualToString:NSAccessibilityPressAction]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Close Card Browser" value:@"" table:0];
    }
    return pvVar1_2;
}

- (id)accessibilityActionNames
{
    return [NSArray arrayWithObject:NSAccessibilityPressAction];
}

- (void)accessibilitySetValue:(id)aValue forAttribute:(id)aAttribute
{

}

- (BOOL)accessibilityIsAttributeSettable:(id)aSettable
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00055ccc @ 00055ccc, 821 bytes * /

id FUN_00055ccc(HSMediaStripHeaderAccessibilityObject *self,SEL _cmd,id accessibilityAttributeValue)

{
  id pvVar1;
  undefined4 *puVar2;
  undefined4 *puVar3;
  undefined *puVar4;
  HSMediaStripScrollView *pHVar5;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar2 = (undefined4 *)&stack0xffffff94;
  puVar3 = (undefined4 *)&stack0xffffff94;
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
  if ((char)pvVar1 != '\0') {
    return self->_owner;
  }
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      return *(id *)PTR_00336354;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(cls_NSBundle,sel_mainBundle);
      puVar3 = (undefined4 *)&stack0xffffff94;
      goto LAB_00055d3d;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_),
       (char)pvVar1 != '\0')) {
      puVar4 = sel_title;
      pHVar5 = self->_owner;
      goto LAB_00055d36;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_),
       puVar3 = (undefined4 *)&stack0xffffff94, (char)pvVar1 != '\0')) goto LAB_00055d3d;
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self->_owner,sel_window);
      pHVar5 = self->_owner;
      _objc_msgSend_stret(local_44,pHVar5,sel_headerRect);
      _objc_msgSend_stret(local_34,pHVar5,sel_convertRect_toView_);
      puVar2 = (undefined4 *)&stack0xffffff8c;
      _objc_msgSend(pvVar1,sel_convertBaseToScreen_);
      puVar4 = sel_valueWithPoint_;
      pHVar5 = (HSMediaStripScrollView *)cls_NSValue;
      goto LAB_00055d36;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    pHVar5 = (HSMediaStripScrollView *)cls_NSValue;
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    _objc_msgSend_stret(local_24,self->_owner,sel_headerRect);
    puVar2 = (undefined4 *)&stack0xffffff90;
  }
  else {
    puVar2 = (undefined4 *)&stack0xffffff94;
    puVar4 = sel_window;
    pHVar5 = self->_owner;
LAB_00055d36:
    *(undefined **)((int)puVar2 + 4) = puVar4;
  }
  *puVar2 = pHVar5;
  puVar3 = puVar2;
LAB_00055d3d:
  puVar3[-1] = 0x55d42;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return pvVar1;
}

*/
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityParentAttribute]) {
        return _owner;
    }
    if ([aValue isEqualToString:NSAccessibilityWindowAttribute]) {
        return [_owner window];
    }
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        return NSAccessibilityButtonRole;
    }
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Card Browser Header Role" value:@"" table:nil];
    }
    if ([aValue isEqualToString:NSAccessibilityTitleAttribute] || [aValue isEqualToString:NSAccessibilityHelpAttribute]) {
        return [_owner title];
    }
    if ([aValue isEqualToString:NSAccessibilityFocusedAttribute]) {
        return [NSNumber numberWithBool:NO];
    }
    if ([aValue isEqualToString:NSAccessibilityEnabledAttribute]) {
        return [NSNumber numberWithBool:YES];
    }
    if ([aValue isEqualToString:NSAccessibilityPositionAttribute]) {
        NSRect rect = [_owner convertRect:[_owner headerRect] toView:nil];
        return [NSValue valueWithPoint:[[_owner window] convertPointToScreen:rect.origin]];
    }
    if ([aValue isEqualToString:NSAccessibilitySizeAttribute]) {
        return [NSValue valueWithSize:[_owner headerRect].size];
    }
    return nil;
}

- (id)accessibilityAttributeNames
{
    return [NSArray arrayWithObjects:NSAccessibilityParentAttribute, NSAccessibilityRoleAttribute, NSAccessibilityRoleDescriptionAttribute, NSAccessibilityTitleAttribute, NSAccessibilityHelpAttribute, NSAccessibilityEnabledAttribute, NSAccessibilityPositionAttribute, NSAccessibilitySizeAttribute, NSAccessibilityWindowAttribute, NSAccessibilityFocusedAttribute, nil];
}

- (id)initWithOwner:(id)aOwner
{
    self = [super init];
    if (self != nil) {
        _owner = aOwner;
    }
    return self;
}

@end

@implementation HSMediaStripScrollView

/* i386 ivar offsets: _title=0x78, _titleRect=0x7c, _footerRect=0x8c, _boundsRect=0x9c, _endRollingRect=0xac, _titleHeightAndOriginValid=0xbc, _rollTimer=0xc0, _rollStartTime=0xc4, _rollInterval=0xcc, _rollDelta=0xd4, _headerImage=0xd8, _footerImage=0xdc, _backgroundImage=0xe0, _filmPartImage=0xe4, _offscreenCache=0xe8, _patternColor=0xec, _cornerSplitterShown=0xf0, _isRolling=0xf1, _cornerSplitter=0xf4, _headerAccessibilityObject=0xf8 */

- (void)setDocumentView:(id)aView
{

}

- (void)setHorizontalScroller:(id)aScroller
{

}

- (void)setVerticalScroller:(id)aScroller
{

}

- (BOOL)hasHorizontalScroller
{
    return NO;
}

- (void)setHasHorizontalScroller:(BOOL)aScroller
{

}

- (BOOL)hasVerticalScroller
{
    return YES;
}

- (void)setHasVerticalScroller:(BOOL)aScroller
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00056257 @ 00056257, 234 bytes * /

void FUN_00056257(HSMediaStripScrollView *self,SEL _cmd,id scrollWheel)

{
  id pvVar1;
  id self_00;
  id self_01;
  double dVar2;
  undefined1 local_24 [4];
  float local_20;
  
  pvVar1 = _objc_msgSend(self,sel_documentView);
  pvVar1 = _objc_msgSend(pvVar1,sel_isFlipped);
  self_00 = _objc_msgSend(self,sel_documentView);
  self_01 = _objc_msgSend(self,sel_documentView);
  _objc_msgSend_stret(local_24,self_01,sel_visibleRect);
  dVar2 = _objc_msgSend_fpret(scrollWheel,sel_deltaY);
  _objc_msgSend(self_00,sel_scrollPoint_,0,
                (float)dVar2 * 10.0 * *(float *)(&DAT_00334d38 + (uint)((char)pvVar1 == '\0') * 4) +
                local_20);
  return;
}

*/
- (void)scrollWheel:(id)aWheel
{
    BOOL isFlipped = [[self documentView] isFlipped];
    NSRect visible = [[self documentView] visibleRect];
    [[self documentView] scrollPoint:NSMakePoint(0, (float)[aWheel deltaY] * 10.0f * (isFlipped ? -1.0f : 1.0f) + visible.origin.y)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00056483 @ 00056483, 424 bytes * /

void FUN_00056483(HSMediaStripScrollView *self,SEL _cmd,id mouseDown)

{
  char cVar1;
  id pvVar2;
  int *piVar3;
  undefined1 local_2c [16];
  HSMediaStripScrollView *local_1c;
  undefined *local_18;
  
  piVar3 = (int *)&stack0xffffffb4;
  pvVar2 = _objc_msgSend(self,sel_isRolling);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(mouseDown,sel_locationInWindow);
    _objc_msgSend(self,sel_convertPoint_fromView_);
    _objc_msgSend_stret(local_2c,self,sel_contentBounds);
    piVar3 = (int *)&stack0xffffffb0;
    _objc_msgSend(self->_headerImage,sel_size);
    cVar1 = _NSPointInRect();
    if (cVar1 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_window);
      pvVar2 = _objc_msgSend(pvVar2,sel_nextEventMatchingMask_);
      _objc_msgSend(pvVar2,sel_locationInWindow);
      _objc_msgSend(self,sel_convertPoint_fromView_);
      cVar1 = _NSPointInRect();
      if (cVar1 == '\0') {
        return;
      }
      _objc_msgSend(self,sel_startRolling_);
      return;
    }
  }
  local_1c = self;
  local_18 = PTR_s_NSScrollView_0034e380;
  piVar3[2] = (int)mouseDown;
  piVar3[1] = (int)sel_mouseDown_;
  *piVar3 = (int)&local_1c;
  piVar3[-1] = 0x56623;
  _objc_msgSendSuper((void *)*piVar3,(SEL)piVar3[1]);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    if (![self isRolling]) {
        NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
        NSRect headerRect = [self contentBounds];
        headerRect.size.height = [_headerImage size].height;
        if (NSPointInRect(point, headerRect)) {
            NSEvent *mouseUp = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp];
            if (NSPointInRect([self convertPoint:[mouseUp locationInWindow] fromView:nil], headerRect)) {
                [self startRolling:self];
            }
            return;
        }
    }
    [super mouseDown:aDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00055b46 @ 00055b46, 219 bytes * /

id FUN_00055b46(HSMediaStripScrollView *self,SEL _cmd,id view,int stringForToolTip,NSPoint point,
               void *userData)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined8 uVar2;
  undefined8 local_1c;
  undefined4 local_14;
  
  _objc_msgSend_stret(&local_1c,self,sel_contentBounds);
  _objc_msgSend(self->_headerImage,sel_size);
  uVar2 = CONCAT44(extraout_EDX,local_14);
  pvVar1 = _objc_msgSend(self,sel_mouse_inRect_,point.x,point.y,local_1c,uVar2);
  if ((char)pvVar1 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,point.x,point.y,local_1c,uVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_Click_to_hide_Card_Browser,&cfstr_empty,0);
  }
  return pvVar1;
}

*/
- (id)view:(id)aView stringForToolTip:(NSInteger)aTip point:(NSPoint)aPoint userData:(void *)aData
{
    NSRect headerRect = [self contentBounds];
    headerRect.size.height = [_headerImage size].height;
    if ([self mouse:aPoint inRect:headerRect]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Click to hide Card Browser" value:@"" table:nil];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005662b @ 0005662b, 1431 bytes * /

void FUN_0005662b(HSMediaStripScrollView *self,SEL _cmd,NSRect drawRect)

{
  float fVar1;
  id pvVar2;
  undefined4 uVar3;
  float fVar4;
  id pvVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  undefined4 extraout_EDX_02;
  float extraout_EDX_03;
  float extraout_EDX_04;
  float extraout_EDX_05;
  float extraout_EDX_06;
  float extraout_EDX_07;
  undefined4 extraout_EDX_08;
  undefined4 extraout_EDX_09;
  float fVar6;
  undefined8 uVar7;
  undefined8 uVar8;
  undefined8 uVar9;
  undefined8 uVar10;
  HSMediaStripScrollView *local_8c;
  undefined *local_88;
  undefined4 local_84;
  float local_80;
  undefined4 local_74;
  undefined4 uStack_70;
  id local_6c;
  undefined4 local_64;
  undefined4 uStack_60;
  id local_5c;
  undefined4 local_54;
  undefined4 uStack_50;
  id local_4c;
  float fStack_48;
  undefined4 local_44;
  float fStack_40;
  id local_3c;
  float fStack_38;
  undefined4 local_34;
  undefined4 uStack_30;
  id local_2c;
  undefined4 local_24;
  undefined4 uStack_20;
  id local_1c;
  
  _objc_msgSend_stret(&local_84,self,sel_contentBounds);
  fVar4 = local_80;
  uVar3 = local_84;
  pvVar5 = _objc_msgSend(self->_backgroundImage,sel_size);
  _objc_msgSend(self->_headerImage,sel_size);
  _objc_msgSend(self->_filmPartImage,sel_size);
  pvVar2 = self->_filmPartImage;
  _objc_msgSend(pvVar2,sel_size);
  local_6c = _objc_msgSend(self->_filmPartImage,sel_size);
  local_74 = 0;
  uStack_70 = 0;
  uVar8 = 0;
  uVar9 = CONCAT44(extraout_EDX_02,local_6c);
  local_80 = (extraout_EDX_00 - extraout_EDX_01) + local_80;
  uVar7 = CONCAT44(local_80,uVar3);
  uVar10 = 0x3f80000000000002;
  _objc_msgSend(pvVar2,sel_drawAtPoint_fromRect_operation_fraction_,uVar3,local_80,0,uVar9,2,
                0x3f800000);
  fVar6 = (self->_footerRect).origin.y;
  fVar1 = (self->_footerRect).size.height;
  _objc_msgSend(self->_footerImage,sel_size);
  fVar6 = ((fVar6 + fVar1) - extraout_EDX_03) - extraout_EDX;
  local_80 = fVar6;
  _objc_msgSend(self->_headerImage,sel_size);
  if (extraout_EDX_04 + fVar4 < fVar6) {
    do {
      local_64 = 0;
      uStack_60 = 0;
      uVar8 = 0;
      uVar9 = CONCAT44(extraout_EDX,pvVar5);
      uVar7 = CONCAT44(local_80,local_84);
      uVar10 = 0x3f80000000000002;
      local_5c = pvVar5;
      _objc_msgSend(self->_backgroundImage,sel_drawAtPoint_fromRect_operation_fraction_,local_84,
                    local_80,0,uVar9,2,0x3f800000);
      fVar6 = local_80 - extraout_EDX;
      local_80 = fVar6;
      _objc_msgSend(self->_headerImage,sel_size);
    } while (extraout_EDX_05 + fVar4 < fVar6);
  }
  _objc_msgSend(self->_headerImage,sel_size,uVar7,uVar8,uVar9);
  fVar6 = (extraout_EDX_06 + fVar4) - local_80;
  if (0.0 <= fVar6) {
    fVar1 = (self->_footerRect).origin.y;
    _objc_msgSend(self->_headerImage,sel_size,uVar7,uVar8,uVar9);
    if (extraout_EDX_07 < fVar1) {
      local_80 = local_80 + fVar6;
      local_54 = 0;
      uStack_50 = 0;
      fStack_48 = extraout_EDX - fVar6;
      local_44 = local_84;
      uVar9 = 0;
      uVar10 = CONCAT44(fStack_48,pvVar5);
      uVar7 = CONCAT44(local_80,local_84);
      uVar8 = CONCAT44(fStack_48,pvVar5);
      local_4c = pvVar5;
      fStack_40 = local_80;
      local_3c = pvVar5;
      fStack_38 = fStack_48;
      _objc_msgSend(self->_backgroundImage,sel_drawInRect_fromRect_operation_fraction_,uVar7,uVar8,0
                    ,uVar10,2,0x3f800000);
    }
  }
  pvVar2 = self->_footerImage;
  _objc_msgSend(pvVar2,sel_size,uVar7,uVar8,uVar9,uVar10);
  local_2c = _objc_msgSend(self->_footerImage,sel_size);
  local_34 = 0;
  uStack_30 = 0;
  _objc_msgSend(pvVar2,sel_drawAtPoint_fromRect_operation_fraction_,(self->_footerRect).origin.x,
                (self->_footerRect).origin.y,0,CONCAT44(extraout_EDX_08,local_2c),2,0x3f800000);
  pvVar2 = self->_headerImage;
  _objc_msgSend(pvVar2,sel_size);
  local_1c = _objc_msgSend(self->_headerImage,sel_size);
  local_24 = 0;
  uStack_20 = 0;
  _objc_msgSend(pvVar2,sel_drawAtPoint_fromRect_operation_fraction_,uVar3,fVar4,0,
                CONCAT44(extraout_EDX_09,local_1c),2,0x3f800000);
  local_8c = self;
  local_88 = PTR_s_NSScrollView_0034e380;
  _objc_msgSendSuper(&local_8c,sel_drawRect_,drawRect.origin,drawRect.size);
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = [self contentBounds];
    NSSize backgroundSize = [_backgroundImage size];
    CGFloat headerHeight = [_headerImage size].height;
    NSSize filmPartSize = [_filmPartImage size];
    CGFloat y;

    [_filmPartImage drawAtPoint:NSMakePoint(bounds.origin.x, bounds.origin.y + headerHeight - filmPartSize.height) fromRect:NSMakeRect(0, 0, filmPartSize.width, filmPartSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    y = NSMaxY(_footerRect) - [_footerImage size].height - backgroundSize.height;
    while (bounds.origin.y + headerHeight < y) {
        [_backgroundImage drawAtPoint:NSMakePoint(bounds.origin.x, y) fromRect:NSMakeRect(0, 0, backgroundSize.width, backgroundSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
        y -= backgroundSize.height;
    }
    CGFloat overlap = bounds.origin.y + headerHeight - y;
    if (0.0 <= overlap && headerHeight < _footerRect.origin.y) {
        y += overlap;
        NSRect part = NSMakeRect(bounds.origin.x, y, backgroundSize.width, backgroundSize.height - overlap);
        [_backgroundImage drawInRect:part fromRect:NSMakeRect(0, 0, part.size.width, part.size.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    }
    NSSize footerSize = [_footerImage size];
    [_footerImage drawAtPoint:_footerRect.origin fromRect:NSMakeRect(0, 0, footerSize.width, footerSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    NSSize headerSize = [_headerImage size];
    [_headerImage drawAtPoint:bounds.origin fromRect:NSMakeRect(0, 0, headerSize.width, headerSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    [super drawRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00056bc2 @ 00056bc2, 1017 bytes * /

void FUN_00056bc2(HSMediaStripScrollView *self,SEL _cmd,NSRect drawBackgroundImageAsPatternInRect)

{
  undefined4 uVar1;
  undefined8 uVar2;
  undefined4 uVar3;
  char cVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  int iVar6;
  undefined4 extraout_EDX_01;
  int iVar7;
  SEL op;
  longlong lVar8;
  float fVar10;
  undefined8 uVar9;
  float local_3c;
  id local_38;
  float fStack_30;
  float fStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  lVar8 = CONCAT44(sel_contentBounds,self);
  _objc_msgSend_stret(&local_24,self,sel_contentBounds);
  _objc_msgSend(self->_headerImage,sel_size);
  fStack_18 = (self->_footerRect).origin.y;
  if (self->_backgroundImage == (id)0x0) {
    return;
  }
  uVar1 = *(undefined4 *)PTR_00336078;
  fStack_30 = *(float *)(PTR_00336078 + 4);
  uVar2 = *(undefined8 *)PTR_00336078;
  uStack_20 = extraout_EDX;
  _objc_msgSend(self->_backgroundImage,sel_size);
  uVar3 = local_1c;
  iVar7 = (int)fStack_18;
  iVar6 = iVar7 % (int)extraout_EDX_00;
  if (iVar6 == 0) {
    local_38 = (id)0x0;
    local_3c = 0.0;
  }
  else {
    iVar6 = (int)extraout_EDX_00 - iVar6;
    local_3c = (float)iVar6;
    local_38 = _objc_msgSend(cls_NSAffineTransform,sel_transform);
    lVar8 = (ulonglong)(uint)local_3c << 0x20;
    iVar7 = iVar7 + iVar6;
    _objc_msgSend(local_38,sel_translateXBy_yBy_,0,local_3c);
  }
  fStack_28 = (float)iVar7;
  if (self->_offscreenCache == (id)0x0) {
    pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc);
    fVar10 = fStack_28;
    pvVar5 = _objc_msgSend(pvVar5,sel_initWithSize_,uVar3,fStack_28);
    self->_offscreenCache = pvVar5;
    _objc_msgSend(pvVar5,sel_setCachedSeparately_,1);
    _objc_msgSend(self->_offscreenCache,sel_setScalesWhenResized_,0);
    pvVar5 = self->_offscreenCache;
    uVar9 = CONCAT44(fVar10,1);
    op = sel_setFlipped_;
  }
  else {
    pvVar5 = _objc_msgSend(self->_offscreenCache,sel_size,lVar8);
    uVar9 = CONCAT44(fStack_28,uVar3);
    cVar4 = _NSEqualSizes(pvVar5,extraout_EDX_01,uVar3,fStack_28);
    if (cVar4 != '\0') goto LAB_00056e10;
    pvVar5 = self->_offscreenCache;
    uVar9 = CONCAT44(fStack_28,uVar3);
    op = sel_setSize_;
  }
  _objc_msgSend(pvVar5,op,uVar9);
LAB_00056e10:
  _objc_msgSend(self->_offscreenCache,sel_lockFocus,uVar9);
  _NSRectFillUsingOperation(uVar2,CONCAT44(fStack_28,uVar3),0);
  if (local_38 == (id)0x0) {
    pvVar5 = _objc_msgSend(self,sel_patternColor);
    _objc_msgSend(pvVar5,sel_set);
    _NSRectFillUsingOperation(CONCAT44(uStack_20,local_24),CONCAT44(fStack_18,local_1c),2);
  }
  else {
    _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
    _objc_msgSend(local_38,sel_concat);
    fStack_28 = fStack_18;
    fStack_30 = local_3c;
    pvVar5 = _objc_msgSend(self,sel_patternColor);
    _objc_msgSend(pvVar5,sel_set);
    _NSRectFillUsingOperation(CONCAT44(uStack_20,local_24),CONCAT44(fStack_18,local_1c),2);
    _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  }
  _objc_msgSend(self->_offscreenCache,sel_unlockFocus);
  _objc_msgSend(self->_offscreenCache,sel_drawInRect_fromRect_operation_fraction_,
                CONCAT44(uStack_20,local_24),CONCAT44(fStack_18,local_1c),CONCAT44(fStack_30,uVar1),
                CONCAT44(fStack_28,uVar3),2,0x3f800000);
  return;
}

*/
- (void)drawBackgroundImageAsPatternInRect:(NSRect)aRect
{
    NSRect bounds = [self contentBounds];
    NSRect fillRect = NSMakeRect(bounds.origin.x, [_headerImage size].height, bounds.size.width, _footerRect.origin.y);
    NSAffineTransform *transform = nil;
    float offset = 0;

    if (_backgroundImage == nil) {
        return;
    }
    int height = (int)fillRect.size.height;
    int remainder = height % (int)[_backgroundImage size].height;
    if (remainder != 0) {
        offset = (float)((int)[_backgroundImage size].height - remainder);
        transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:offset];
        height += (int)offset;
    }
    NSSize cacheSize = NSMakeSize(fillRect.size.width, (CGFloat)height);
    if (_offscreenCache == nil) {
        _offscreenCache = [[NSImage alloc] initWithSize:cacheSize];
        [_offscreenCache setCachedSeparately:YES];
        [_offscreenCache setScalesWhenResized:NO];
        [_offscreenCache setFlipped:YES];
    }
    else if (!NSEqualSizes([_offscreenCache size], cacheSize)) {
        [_offscreenCache setSize:cacheSize];
    }
    [_offscreenCache lockFocus];
    NSRectFillUsingOperation(NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, cacheSize.width, cacheSize.height), NSCompositingOperationClear);
    if (transform == nil) {
        [(NSColor *)[self patternColor] set];
        NSRectFillUsingOperation(fillRect, NSCompositingOperationSourceOver);
    }
    else {
        [NSGraphicsContext saveGraphicsState];
        [transform concat];
        [(NSColor *)[self patternColor] set];
        NSRectFillUsingOperation(fillRect, NSCompositingOperationSourceOver);
        [NSGraphicsContext restoreGraphicsState];
    }
    [_offscreenCache unlockFocus];
    [_offscreenCache drawInRect:fillRect fromRect:NSMakeRect(NSZeroRect.origin.x, offset, fillRect.size.width, fillRect.size.height) operation:NSCompositingOperationSourceOver fraction:1.0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000558b6 @ 000558b6, 656 bytes * /

void FUN_000558b6(HSMediaStripScrollView *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined4 local_54;
  undefined4 uStack_50;
  undefined4 local_4c;
  undefined4 uStack_48;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [20];
  
  _objc_msgSend_stret(&local_44,self,sel_contentBounds);
  local_54 = *(undefined4 *)PTR_00336078;
  uStack_50 = *(undefined4 *)(PTR_00336078 + 4);
  local_4c = *(undefined4 *)(PTR_00336078 + 8);
  uStack_48 = *(undefined4 *)(PTR_00336078 + 0xc);
  _objc_msgSend(self->_headerImage,sel_size);
  _objc_msgSend(self->_footerImage,sel_size);
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(local_34,pvVar1,sel_bounds);
  pvVar1 = _objc_msgSend(self,sel_isRolling);
  if ((char)pvVar1 == '\0') {
    if (local_28 < ((fStack_40 + fStack_38) - extraout_EDX) - extraout_EDX_00) {
      fStack_38 = local_28 + extraout_EDX + extraout_EDX_00;
    }
  }
  else {
    local_44 = (self->_boundsRect).origin.x;
    fStack_40 = (self->_boundsRect).origin.y;
    local_3c = (self->_boundsRect).size.width;
    fStack_38 = (self->_boundsRect).size.height;
  }
  _objc_msgSend_stret(&local_54,self,sel_contentRectForBounds_headerMaxY_footerMaxY_,local_44,
                      fStack_40,CONCAT44(fStack_38,local_3c),extraout_EDX,extraout_EDX_00);
  (self->_footerRect).origin.x = local_44;
  (self->_footerRect).size.width = local_3c;
  (self->_footerRect).origin.y = fStack_38 - extraout_EDX_00;
  (self->_footerRect).size.height = extraout_EDX_00;
  pvVar1 = _objc_msgSend(self,sel_documentView);
  _objc_msgSend(pvVar1,sel_setStripWidth_,local_4c);
  pvVar1 = _objc_msgSend(self,sel_contentView);
  _objc_msgSend(pvVar1,sel_setFrame_,local_54,uStack_50,local_4c,uStack_48);
  pvVar1 = _objc_msgSend(self,sel_verticalScroller);
  _objc_msgSend_stret(local_24,self,sel_scrollerRect);
  _objc_msgSend(pvVar1,sel_setFrame_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),(int)local_24._8_8_
                ,SUB84(local_24._8_8_,4));
  return;
}

*/
- (void)tile
{
    NSRect bounds = [self contentBounds];
    CGFloat headerHeight = [_headerImage size].height;
    CGFloat footerHeight = [_footerImage size].height;
    NSRect stripBounds = [[self mediaStripView] bounds];

    if (![self isRolling]) {
        if (stripBounds.size.height < NSMaxY(bounds) - headerHeight - footerHeight) {
            bounds.size.height = stripBounds.size.height + headerHeight + footerHeight;
        }
    }
    else {
        bounds = _boundsRect;
    }
    NSRect contentRect = [self contentRectForBounds:bounds headerMaxY:headerHeight footerMaxY:footerHeight];
    _footerRect = NSMakeRect(bounds.origin.x, NSMaxY(bounds) - footerHeight, bounds.size.width, footerHeight);
    [[self documentView] setStripWidth:contentRect.size.width];
    [[self contentView] setFrame:contentRect];
    [[self verticalScroller] setFrame:[self scrollerRect]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00056fbb @ 00056fbb, 361 bytes * /

void FUN_00056fbb(HSMediaStripScrollView *self,SEL _cmd,id reflectScrolledClipView)

{
  char cVar1;
  id pvVar2;
  float fVar3;
  HSMediaStripScrollView *local_3c;
  undefined *local_38;
  undefined4 local_34;
  float local_30;
  float local_28;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(&local_34,pvVar2,sel_visibleRect);
  fVar3 = local_30 + local_28;
  pvVar2 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(local_24,pvVar2,sel_bounds);
  pvVar2 = _objc_msgSend(self,sel_mediaStripScroller);
  _objc_msgSend(pvVar2,sel_setEnabled_forPart_,(uint)(fVar3 != local_20 + local_18),1);
  cVar1 = _NSEqualPoints(local_34,local_30,*(undefined4 *)PTR_00336074,
                         *(undefined4 *)(PTR_00336074 + 4));
  pvVar2 = _objc_msgSend(self,sel_mediaStripScroller);
  _objc_msgSend(pvVar2,sel_setEnabled_forPart_,(uint)(cVar1 == '\0'),2);
  local_3c = self;
  local_38 = PTR_s_NSScrollView_0034e380;
  _objc_msgSendSuper(&local_3c,sel_reflectScrolledClipView_,reflectScrolledClipView);
  return;
}

*/
- (void)reflectScrolledClipView:(id)aView
{
    NSRect visible = [[self mediaStripView] visibleRect];
    NSRect stripBounds = [[self mediaStripView] bounds];
    [[self mediaStripScroller] setEnabled:NSMaxY(visible) != NSMaxY(stripBounds) forPart:1];
    [[self mediaStripScroller] setEnabled:!NSEqualPoints(visible.origin, NSZeroPoint) forPart:2];
    [super reflectScrolledClipView:aView];
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if (aWindow == nil) {
        [self stopRolling:self];
    }
    [super viewWillMoveToWindow:aWindow];
}

- (void)stopRolling:(id)aRolling
{
    _isRolling = NO;
    if (_rollTimer != nil) {
        [_rollTimer invalidate];
        [_rollTimer release];
        _rollTimer = nil;
    }
}

- (BOOL)isRollingRolling
{
    return _rollDelta <= 0.0 && _rollDelta != 0.0;
}

- (BOOL)isRolling
{
    return _isRolling;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005561b @ 0005561b, 574 bytes * /

void FUN_0005561b(HSMediaStripScrollView *self,SEL _cmd,id startRolling)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  float extraout_EDX_04;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined1 local_1c [12];
  float local_10;
  
  pvVar3 = _objc_msgSend(self,sel_isRolling);
  if ((char)pvVar3 != '\0') {
    _objc_msgSend(self,sel_stopRolling_,self);
  }
  _objc_msgSend_stret(&local_2c,self,sel_contentBounds);
  (self->_endRollingRect).origin.x = local_2c;
  (self->_endRollingRect).origin.y = local_28;
  (self->_endRollingRect).size.width = local_24;
  (self->_endRollingRect).size.height = local_20;
  (self->_boundsRect).origin.x = local_2c;
  (self->_boundsRect).origin.y = local_28;
  (self->_boundsRect).size.width = local_24;
  (self->_boundsRect).size.height = local_20;
  pvVar3 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(local_1c,pvVar3,sel_bounds);
  fVar1 = (self->_endRollingRect).origin.y;
  fVar2 = (self->_endRollingRect).size.height;
  _objc_msgSend(self->_headerImage,sel_size);
  _objc_msgSend(self->_footerImage,sel_size);
  if (local_10 < ((fVar1 + fVar2) - extraout_EDX) - extraout_EDX_00) {
    _objc_msgSend(self->_headerImage,sel_size);
    _objc_msgSend(self->_footerImage,sel_size);
    (self->_boundsRect).size.height = extraout_EDX_02 + local_10 + extraout_EDX_01;
  }
  self->_rollDelta = -2.0;
  self->_isRolling = '\x01';
  _objc_msgSend(self->_headerImage,sel_size);
  _objc_msgSend(self->_footerImage,sel_size);
  (self->_endRollingRect).size.height = extraout_EDX_04 + extraout_EDX_03;
  pvVar3 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend(pvVar3,sel_scrollToBottom);
  _objc_msgSend(self,sel_roll_,self);
  return;
}

*/
- (void)startRolling:(id)aRolling
{
    if ([self isRolling]) {
        [self stopRolling:self];
    }
    _endRollingRect = [self contentBounds];
    _boundsRect = _endRollingRect;
    NSRect stripBounds = [[self mediaStripView] bounds];
    CGFloat headerHeight = [_headerImage size].height;
    CGFloat footerHeight = [_footerImage size].height;
    if (stripBounds.size.height < NSMaxY(_endRollingRect) - headerHeight - footerHeight) {
        _boundsRect.size.height = headerHeight + stripBounds.size.height + footerHeight;
    }
    _rollDelta = -2.0f;
    _isRolling = YES;
    _endRollingRect.size.height = [_headerImage size].height + [_footerImage size].height;
    [[self mediaStripView] scrollToBottom];
    [self roll:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00055496 @ 00055496, 389 bytes * /

void FUN_00055496(HSMediaStripScrollView *self,SEL _cmd,id startUnrolling)

{
  id pvVar1;
  float extraout_EDX;
  float extraout_EDX_00;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_isRolling);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRolling_,self);
  }
  _objc_msgSend_stret(&local_1c,self,sel_contentBounds);
  (self->_boundsRect).origin.x = local_1c;
  (self->_boundsRect).origin.y = local_18;
  (self->_boundsRect).size.width = local_14;
  (self->_boundsRect).size.height = local_10;
  self->_rollDelta = 2.0;
  self->_isRolling = '\x01';
  _objc_msgSend(self->_headerImage,sel_size);
  _objc_msgSend(self->_footerImage,sel_size);
  (self->_boundsRect).size.height = extraout_EDX_00 + extraout_EDX;
  _objc_msgSend(self,sel_tile);
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend(pvVar1,sel_scrollToBottom);
  _objc_msgSend(self,sel_setNeedsDisplay_,1);
  _objc_msgSend(cls_NSTimer,sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,
                0x40000000,0x3f847ae1,self,sel_unroll_,0,0);
  return;
}

*/
- (void)startUnrolling:(id)aUnrolling
{
    if ([self isRolling]) {
        [self stopRolling:self];
    }
    _boundsRect = [self contentBounds];
    _rollDelta = 2.0f;
    _isRolling = YES;
    _boundsRect.size.height = [_headerImage size].height + [_footerImage size].height;
    [self tile];
    [[self mediaStripView] scrollToBottom];
    [self setNeedsDisplay:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(unroll:) userInfo:nil repeats:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005538a @ 0005538a, 268 bytes * /

void FUN_0005538a(HSMediaStripScrollView *self,SEL _cmd)

{
  id pvVar1;
  HSMediaStripScrollView *pHVar2;
  SEL op;
  HSMediaStripScrollView *pHVar3;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_isRolling);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRolling_,self);
  }
  pHVar3 = self;
  _objc_msgSend_stret(&local_24,self,sel_contentBounds);
  (self->_boundsRect).origin.x = local_24;
  (self->_boundsRect).origin.y = local_20;
  (self->_boundsRect).size.width = local_1c;
  (self->_boundsRect).size.height = local_18;
  _objc_msgSend(self,sel_tile);
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  pHVar2 = _objc_msgSend(pvVar1,sel_activeItemIndex);
  op = sel_scrollItemAtIndexToVisible_;
  if (pHVar2 == (HSMediaStripScrollView *)0x7fffffff) {
    pvVar1 = _objc_msgSend(self,sel_mediaStripView);
    op = sel_scrollToTop;
    pHVar2 = pHVar3;
  }
  _objc_msgSend(pvVar1,op,pHVar2);
  return;
}

*/
- (void)unrollImmediately
{
    if ([self isRolling]) {
        [self stopRolling:self];
    }
    _boundsRect = [self contentBounds];
    [self tile];
    NSUInteger index = [[self mediaStripView] activeItemIndex];
    if (index == NSNotFound) {
        [[self mediaStripView] scrollToTop];
    }
    else {
        [[self mediaStripView] scrollItemAtIndexToVisible:index];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00055217 @ 00055217, 371 bytes * /

void FUN_00055217(HSMediaStripScrollView *self,SEL _cmd,id unroll)

{
  float fVar1;
  float fVar2;
  id self_00;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined1 local_1c [12];
  float local_10;
  
  _objc_msgSend_stret(&local_2c,self,sel_contentBounds);
  (self->_endRollingRect).origin.x = local_2c;
  (self->_endRollingRect).origin.y = local_28;
  (self->_endRollingRect).size.width = local_24;
  (self->_endRollingRect).size.height = local_20;
  self_00 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(local_1c,self_00,sel_bounds);
  fVar1 = (self->_endRollingRect).origin.y;
  fVar2 = (self->_endRollingRect).size.height;
  _objc_msgSend(self->_headerImage,sel_size);
  _objc_msgSend(self->_footerImage,sel_size);
  if (local_10 < ((fVar1 + fVar2) - extraout_EDX) - extraout_EDX_00) {
    _objc_msgSend(self->_headerImage,sel_size);
    _objc_msgSend(self->_footerImage,sel_size);
    (self->_endRollingRect).size.height = extraout_EDX_02 + local_10 + extraout_EDX_01;
  }
  _objc_msgSend(self,sel_roll_,self);
  return;
}

*/
- (void)unroll:(id)aUnroll
{
    _endRollingRect = [self contentBounds];
    NSRect stripBounds = [[self mediaStripView] bounds];
    CGFloat headerHeight = [_headerImage size].height;
    CGFloat footerHeight = [_footerImage size].height;
    if (stripBounds.size.height < NSMaxY(_endRollingRect) - headerHeight - footerHeight) {
        _endRollingRect.size.height = headerHeight + stripBounds.size.height + footerHeight;
    }
    [self roll:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00057180 @ 00057180, 841 bytes * /

void FUN_00057180(HSMediaStripScrollView *self,SEL _cmd,id roll)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  id pvVar4;
  bool bVar5;
  longdouble lVar6;
  float fVar7;
  double dVar8;
  SEL op;
  undefined8 uVar9;
  undefined8 uVar11;
  undefined8 local_24;
  undefined4 local_1c;
  float fStack_18;
  undefined4 uVar10;
  
  if (self->_rollTimer == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_isRolling);
    if ((char)pvVar3 == '\0') {
      return;
    }
    *(undefined4 *)((int)&self->_rollInterval + 4) = 0x3f847ae1;
    *(undefined4 *)&self->_rollInterval = 0x40000000;
    pvVar3 = _objc_msgSend(cls_NSTimer,
                           sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_rollTimer = pvVar3;
    dVar8 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
    self->_rollStartTime = dVar8;
    return;
  }
  dVar8 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
  _NSInsetRect(&local_24,(self->_boundsRect).origin,(self->_boundsRect).size,0xc0800000,0xc0800000);
  lVar6 = (longdouble)
          _floorf(self->_rollDelta * (float)((dVar8 - self->_rollStartTime) / self->_rollInterval));
  fVar2 = (float)lVar6;
  fVar7 = (self->_boundsRect).size.height;
  fVar1 = (self->_endRollingRect).size.height;
  if (((fVar7 < fVar1) && (0.0 < fVar2)) || ((fVar1 < fVar7 && (fVar2 < 0.0)))) {
    fVar7 = fVar7 + fVar2;
    (self->_boundsRect).size.height = fVar7;
    bVar5 = true;
  }
  else {
    bVar5 = false;
  }
  if (((fVar7 <= fVar1) || (fVar2 <= 0.0)) && ((fVar1 <= fVar7 || (0.0 <= fVar2)))) {
    if (((fVar7 != fVar1) || (NAN(fVar7) || NAN(fVar1))) || (fVar2 == 0.0)) {
      if (!bVar5) {
        return;
      }
      bVar5 = true;
      goto LAB_000572c6;
    }
  }
  (self->_boundsRect).size.height = fVar1;
  bVar5 = false;
LAB_000572c6:
  _objc_msgSend(self,sel_tile);
  pvVar3 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend(pvVar3,sel_scrollToBottom);
  lVar6 = (longdouble)_fmaxf((self->_boundsRect).size.height + 8.0,fStack_18);
  fStack_18 = (float)lVar6;
  uVar11 = CONCAT44(fStack_18,local_1c);
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,local_24,uVar11);
  if (!bVar5) {
    uVar10 = (undefined4)((ulonglong)local_24 >> 0x20);
    uVar9 = CONCAT44(uVar10,self);
    _objc_msgSend(self,sel_stopRolling_,self,uVar10,uVar11);
    pvVar3 = _objc_msgSend(self,sel_mediaStripView);
    pvVar4 = _objc_msgSend(pvVar3,sel_activeItemIndex);
    if (pvVar4 == (id)0x7fffffff) {
      pvVar3 = _objc_msgSend(self,sel_mediaStripView,uVar9,uVar11);
      op = sel_scrollToTop;
    }
    else {
      uVar9 = CONCAT44((int)((ulonglong)uVar9 >> 0x20),pvVar4);
      op = sel_scrollItemAtIndexToVisible_;
    }
    _objc_msgSend(pvVar3,op,uVar9);
    if (fVar2 < 0.0) {
      pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,uVar9);
      _objc_msgSend(pvVar3,sel_postNotificationName_object_,
                    PTR_cfstr_HSMediaStripViewDidFinishRollingNotification_00342490,self);
    }
  }
  return;
}

*/
- (void)roll:(id)aRoll
{
    if (_rollTimer == nil) {
        if (![self isRolling]) {
            return;
        }
        _rollInterval = 0.01;
        _rollTimer = [[NSTimer scheduledTimerWithTimeInterval:_rollInterval target:self selector:_cmd userInfo:nil repeats:YES] retain];
        _rollStartTime = [NSDate timeIntervalSinceReferenceDate];
        return;
    }
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSRect dirtyRect = NSInsetRect(_boundsRect, -4, -4);
    float step = floorf(_rollDelta * (float)((now - _rollStartTime) / _rollInterval));
    CGFloat height = _boundsRect.size.height;
    CGFloat endHeight = _endRollingRect.size.height;
    BOOL keepRolling;
    BOOL changed = NO;

    if ((height < endHeight && 0.0f < step) || (endHeight < height && step < 0.0f)) {
        height += step;
        _boundsRect.size.height = height;
        changed = YES;
    }
    if ((height <= endHeight || step <= 0.0f) && (endHeight <= height || 0.0f <= step) && (height != endHeight || step == 0.0f)) {
        if (!changed) {
            return;
        }
        keepRolling = YES;
    }
    else {
        _boundsRect.size.height = endHeight;
        keepRolling = NO;
    }
    [self tile];
    [[self mediaStripView] scrollToBottom];
    dirtyRect.size.height = fmaxf((float)(_boundsRect.size.height + 8.0), (float)dirtyRect.size.height);
    [self setNeedsDisplayInRect:dirtyRect];
    if (!keepRolling) {
        [self stopRolling:self];
        NSUInteger index = [[self mediaStripView] activeItemIndex];
        if (index == NSNotFound) {
            [[self mediaStripView] scrollToTop];
        }
        else {
            [[self mediaStripView] scrollItemAtIndexToVisible:index];
        }
        if (step < 0.0f) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HSMediaStripViewDidFinishRollingNotification object:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00055128 @ 00055128, 239 bytes * /

void FUN_00055128(HSMediaStripScrollView *self,SEL _cmd,id scrollDownAction)

{
  id pvVar1;
  int iVar2;
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(&local_1c,pvVar1,sel_visibleRect);
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  pvVar1 = _objc_msgSend(pvVar1,sel_indexOfItemAtPoint_,local_1c,local_18);
  if (pvVar1 == (id)0x7fffffff) {
    pvVar1 = _objc_msgSend(self,sel_mediaStripView,local_1c,local_18);
    pvVar1 = _objc_msgSend(pvVar1,sel_numberOfItems);
  }
  iVar2 = (int)pvVar1 + -1;
  if (pvVar1 == (id)0x0) {
    iVar2 = 0;
  }
  pvVar1 = _objc_msgSend(self,sel_mediaStripView,local_1c,local_18);
  _objc_msgSend(pvVar1,sel_scrollItemAtIndexToTop_,iVar2);
  return;
}

*/
- (void)scrollDownAction:(id)aAction
{
    NSRect visible = [[self mediaStripView] visibleRect];
    NSUInteger index = [[self mediaStripView] indexOfItemAtPoint:visible.origin];
    if (index == NSNotFound) {
        index = [[self mediaStripView] numberOfItems];
    }
    [[self mediaStripView] scrollItemAtIndexToTop:(index == 0 ? 0 : index - 1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00055024 @ 00055024, 260 bytes * /

void FUN_00055024(HSMediaStripScrollView *self,SEL _cmd,id scrollUpAction)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  id local_24;
  undefined4 local_20;
  
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  _objc_msgSend_stret(&local_24,pvVar1,sel_visibleRect);
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  pvVar1 = _objc_msgSend(pvVar1,sel_indexOfItemAtPoint_,local_24,local_20);
  if (pvVar1 != (id)0x7fffffff) {
    pvVar2 = _objc_msgSend(self,sel_mediaStripView,local_24,local_20);
    pvVar2 = _objc_msgSend(pvVar2,sel_numberOfItems);
    pvVar1 = (id)((int)pvVar1 + 1);
    self_00 = _objc_msgSend(self,sel_mediaStripView);
    op = sel_scrollItemAtIndexToTop_;
    if (pvVar2 <= pvVar1) {
      op = sel_scrollToBottom;
      pvVar1 = local_24;
    }
    _objc_msgSend(self_00,op,pvVar1,local_20);
  }
  return;
}

*/
- (void)scrollUpAction:(id)aAction
{
    NSRect visible = [[self mediaStripView] visibleRect];
    NSUInteger index = [[self mediaStripView] indexOfItemAtPoint:visible.origin];
    if (index != NSNotFound) {
        NSUInteger count = [[self mediaStripView] numberOfItems];
        index++;
        if (count <= index) {
            [[self mediaStripView] scrollToBottom];
        }
        else {
            [[self mediaStripView] scrollItemAtIndexToTop:index];
        }
    }
}

- (void)setShowsStopButton:(BOOL)aButton
{

}

- (BOOL)showsStopButton
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00054eb7 @ 00054eb7, 365 bytes * /

void FUN_00054eb7(HSMediaStripScrollView *self,SEL _cmd,id setCornerSplitter)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined4 local_50;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  puVar3 = (undefined4 *)&stack0xffffffb4;
  if (self->_cornerSplitter == setCornerSplitter) {
    return;
  }
  local_50 = 0x54eea;
  pvVar1 = _objc_msgSend(self->_cornerSplitter,sel_superview);
  if (self->_cornerSplitter == (id)0x0) {
    local_24 = *(undefined4 *)PTR_00336078;
    uStack_20 = *(undefined4 *)(PTR_00336078 + 4);
    local_1c = *(undefined4 *)(PTR_00336078 + 8);
    uStack_18 = *(undefined4 *)(PTR_00336078 + 0xc);
  }
  else {
    local_50 = 0x54f10;
    _objc_msgSend_stret(&local_24,self->_cornerSplitter,sel_frame);
    puVar3 = &local_50;
  }
  if (pvVar1 != (id)0x0) {
    pvVar2 = self->_cornerSplitter;
    puVar3[1] = sel_removeFromSuperview;
    *puVar3 = pvVar2;
    puVar3[-1] = 0x54f64;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  pvVar2 = self->_cornerSplitter;
  puVar3[1] = sel_release;
  *puVar3 = pvVar2;
  puVar3[-1] = 0x54f7e;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_retain;
  *puVar3 = setCornerSplitter;
  puVar3[-1] = 0x54f93;
  pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  self->_cornerSplitter = pvVar2;
  if (pvVar1 != (id)0x0) {
    if (pvVar2 != (id)0x0) {
      *(ulonglong *)(puVar3 + 4) = CONCAT44(uStack_18,local_1c);
      *(ulonglong *)(puVar3 + 2) = CONCAT44(uStack_20,local_24);
      puVar3[1] = sel_setFrame_;
      *puVar3 = pvVar2;
      puVar3[-1] = 0x54fcb;
      _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
      puVar3[2] = self->_cornerSplitter;
      puVar3[1] = sel_addSubview_;
      *puVar3 = pvVar1;
      puVar3[-1] = 0x54fea;
      _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
      goto LAB_0005500a;
    }
    puVar3[1] = sel_setCornerSplitterShown_;
    *puVar3 = self;
    puVar3[2] = 0;
    puVar3[-1] = 0x55006;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  if (pvVar1 == (id)0x0) {
    return;
  }
LAB_0005500a:
  puVar3[1] = sel_tile;
  *puVar3 = self;
  puVar3[-1] = 0x5501c;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)setCornerSplitter:(id)aSplitter
{
    if (_cornerSplitter == aSplitter) {
        return;
    }
    NSView *superview = [_cornerSplitter superview];
    NSRect frame = _cornerSplitter != nil ? [_cornerSplitter frame] : NSZeroRect;
    if (superview != nil) {
        [_cornerSplitter removeFromSuperview];
    }
    [_cornerSplitter release];
    _cornerSplitter = [aSplitter retain];
    if (superview == nil) {
        return;
    }
    if (_cornerSplitter != nil) {
        [_cornerSplitter setFrame:frame];
        [superview addSubview:_cornerSplitter];
    }
    else {
        [self setCornerSplitterShown:NO];
    }
    [self tile];
}

- (id)cornerSplitter
{
    return _cornerSplitter;
}

- (void)setCornerSplitterShown:(BOOL)aShown
{
    if (_cornerSplitterShown != aShown) {
        if ((_cornerSplitterShown != NO) && (_cornerSplitter != nil)) {
            [_cornerSplitter removeFromSuperview];
            [self tile];
        }
        _cornerSplitterShown = aShown;
        if (aShown != NO) {
            [self addSubview:[self cornerSplitter]];
            [self tile];
        }
    }
}

- (BOOL)isCornerSplitterShown
{
    return _cornerSplitterShown;
}

- (id)mediaStripScroller
{
    return [self verticalScroller];
}

- (id)mediaStripView
{
    return [self documentView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00054c29 @ 00054c29, 421 bytes * /

void FUN_00054c29(HSMediaStripScrollView *self,SEL _cmd,id setTitle)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined8 local_34;
  id local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  if (self->_title != setTitle) {
    self->_titleHeightAndOriginValid = '\0';
    _objc_msgSend(self->_title,sel_release);
    pvVar1 = _objc_msgSend(setTitle,sel_copy);
    self->_title = pvVar1;
    _objc_msgSend(self->_headerImage,sel_release);
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,self->_title);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_headerImage = pvVar1;
    _objc_msgSend(pvVar1,sel_setFlipped_,1);
    _objc_msgSend(self->_headerImage,sel_setCachedSeparately_,1);
    _objc_msgSend(self->_headerImage,sel_lockFocus);
    _objc_msgSend(self->_headerImage,sel_unlockFocus);
    _objc_msgSend_stret(&local_34,self,sel_contentBounds);
    local_2c = _objc_msgSend(self->_headerImage,sel_size);
    _NSInsetRect(&local_24,local_34,CONCAT44(extraout_EDX,local_2c),0xc0800000,0xc0800000);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,local_24,local_1c);
  }
  return;
}

*/
- (void)setTitle:(id)aTitle
{
    if (_title == aTitle) {
        return;
    }
    _titleHeightAndOriginValid = NO;
    [_title release];
    _title = [aTitle copy];
    [_headerImage release];
    _headerImage = [[NSImage imageNamed:_title] retain];
    [_headerImage setFlipped:YES];
    [_headerImage setCachedSeparately:YES];
    [_headerImage lockFocus];
    [_headerImage unlockFocus];
    NSRect headerRect;
    headerRect.origin = [self contentBounds].origin;
    headerRect.size = [_headerImage size];
    [self setNeedsDisplayInRect:NSInsetRect(headerRect, -4, -4)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005491c @ 0005491c, 28 bytes * /

id FUN_0005491c(HSMediaStripScrollView *self,SEL _cmd)

{
  cfstringStruct *pcVar1;
  
  pcVar1 = &cfstr_empty;
  if (self->_title != (cfstringStruct *)0x0) {
    pcVar1 = self->_title;
  }
  return pcVar1;
}

*/
- (id)title
{
    return _title != nil ? _title : @"";
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)dealloc
{
    [_headerAccessibilityObject release];
    [self setCornerSplitterShown:NO];
    [self setCornerSplitter:nil];
    [_headerImage release];
    [_footerImage release];
    [_backgroundImage release];
    [_filmPartImage release];
    [_offscreenCache release];
    [_title release];
    [_rollTimer release];
    [_patternColor release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000574c9 @ 000574c9, 1539 bytes * /

id FUN_000574c9(HSMediaStripScrollView *self,SEL _cmd,NSRect initWithFrame)

{
  HSMediaStripScrollView *self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54;
  float fStack_50;
  float local_4c;
  float fStack_48;
  undefined4 local_40;
  HSMediaStripScrollView *local_3c;
  undefined *local_38;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  local_3c = self;
  local_38 = PTR_s_NSScrollView_0034e380;
  self_00 = _objc_msgSendSuper(&local_3c,sel_initWithFrame_,initWithFrame.origin.x,
                               initWithFrame.origin.y,initWithFrame.size.width,
                               initWithFrame.size.height);
  if (self_00 != (HSMediaStripScrollView *)0x0) {
    local_40 = 0;
    _Gestalt(0x73797376,&local_40);
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_MediaStripHeader);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self_00->_headerImage = pvVar1;
    _objc_msgSend(pvVar1,sel_setFlipped_,1);
    _objc_msgSend(self_00->_headerImage,sel_setCachedSeparately_,1);
    _objc_msgSend(self_00->_headerImage,sel_lockFocus);
    _objc_msgSend(self_00->_headerImage,sel_unlockFocus);
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_film_edge);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self_00->_footerImage = pvVar1;
    _objc_msgSend(pvVar1,sel_setFlipped_,1);
    _objc_msgSend(self_00->_footerImage,sel_setCachedSeparately_,1);
    _objc_msgSend(self_00->_footerImage,sel_lockFocus);
    _objc_msgSend(self_00->_footerImage,sel_unlockFocus);
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_film);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self_00->_backgroundImage = pvVar1;
    _objc_msgSend(pvVar1,sel_setFlipped_,1);
    _objc_msgSend(self_00->_backgroundImage,sel_setCachedSeparately_,1);
    _objc_msgSend(self_00->_backgroundImage,sel_lockFocus);
    _objc_msgSend(self_00->_backgroundImage,sel_unlockFocus);
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_film_part);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self_00->_filmPartImage = pvVar1;
    _objc_msgSend(pvVar1,sel_setFlipped_,1);
    _objc_msgSend(self_00->_filmPartImage,sel_setCachedSeparately_,1);
    _objc_msgSend(self_00->_filmPartImage,sel_lockFocus);
    _objc_msgSend(self_00->_filmPartImage,sel_unlockFocus);
    local_38 = PTR_s_NSScrollView_0034e380;
    local_3c = self_00;
    _objc_msgSendSuper(&local_3c,sel_setHasVerticalScroller_,0);
    pvVar1 = _objc_msgSend(cls_HSMediaStripScroller,sel_alloc);
    _objc_msgSend_stret(local_34,self_00,sel_scrollerRect);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,(int)local_34._0_8_,SUB84(local_34._0_8_,4),
                           (int)local_34._8_8_,SUB84(local_34._8_8_,4));
    local_38 = PTR_s_NSScrollView_0034e380;
    local_3c = self_00;
    _objc_msgSendSuper(&local_3c,sel_setVerticalScroller_,pvVar1);
    _objc_msgSend(pvVar1,sel_setAction_forPart_,sel_scrollUpAction_,1);
    _objc_msgSend(pvVar1,sel_setAction_forPart_,sel_scrollDownAction_,2);
    _objc_msgSend(pvVar1,sel_release);
    local_38 = PTR_s_NSScrollView_0034e380;
    local_3c = self_00;
    pvVar1 = _objc_msgSend(cls_HSMediaStripView,sel_alloc);
    _objc_msgSend_stret(local_24,self_00,sel_contentBounds);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                           (int)local_24._8_8_,SUB84(local_24._8_8_,4));
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    _objc_msgSendSuper(&local_3c,sel_setDocumentView_,pvVar1);
    _objc_msgSend(self_00,sel_setCornerSplitterShown_,0);
    pvVar1 = _objc_msgSend(self_00,sel_contentView);
    _objc_msgSend(pvVar1,sel_setDrawsBackground_,0);
    _objc_msgSend(self_00,sel_setDrawsBackground_,0);
    _objc_msgSend_stret(&local_64,self_00,sel_contentBounds);
    (self_00->_boundsRect).origin.x = local_64;
    (self_00->_boundsRect).origin.y = local_60;
    (self_00->_boundsRect).size.width = local_5c;
    (self_00->_boundsRect).size.height = local_58;
    local_54 = local_64;
    fStack_50 = (self_00->_boundsRect).origin.y;
    local_4c = (self_00->_boundsRect).size.width;
    fStack_48 = (self_00->_boundsRect).size.height;
    _objc_msgSend(self_00->_headerImage,sel_size);
    _objc_msgSend(self_00,sel_addToolTipRect_owner_userData_,local_54,fStack_50,local_4c,
                  extraout_EDX,self_00,0);
    pvVar1 = _objc_msgSend(cls_HSMediaStripHeaderAccessibilityObject,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithOwner_,self_00);
    self_00->_headerAccessibilityObject = pvVar1;
  }
  return self_00;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _headerImage = [[NSImage imageNamed:@"MediaStripHeader"] retain];
        [_headerImage setFlipped:YES];
        [_headerImage setCachedSeparately:YES];
        [_headerImage lockFocus];
        [_headerImage unlockFocus];
        _footerImage = [[NSImage imageNamed:@"film edge"] retain];
        [_footerImage setFlipped:YES];
        [_footerImage setCachedSeparately:YES];
        [_footerImage lockFocus];
        [_footerImage unlockFocus];
        _backgroundImage = [[NSImage imageNamed:@"film"] retain];
        [_backgroundImage setFlipped:YES];
        [_backgroundImage setCachedSeparately:YES];
        [_backgroundImage lockFocus];
        [_backgroundImage unlockFocus];
        _filmPartImage = [[NSImage imageNamed:@"film_part"] retain];
        [_filmPartImage setFlipped:YES];
        [_filmPartImage setCachedSeparately:YES];
        [_filmPartImage lockFocus];
        [_filmPartImage unlockFocus];
        [super setHasVerticalScroller:NO];
        HSMediaStripScroller *scroller = [[HSMediaStripScroller alloc] initWithFrame:[self scrollerRect]];
        [super setVerticalScroller:scroller];
        [scroller setAction:@selector(scrollUpAction:) forPart:1];
        [scroller setAction:@selector(scrollDownAction:) forPart:2];
        [scroller release];
        [super setDocumentView:[[[HSMediaStripView alloc] initWithFrame:[self contentBounds]] autorelease]];
        [self setCornerSplitterShown:NO];
        [[self contentView] setDrawsBackground:NO];
        [self setDrawsBackground:NO];
        _boundsRect = [self contentBounds];
        [self addToolTipRect:NSMakeRect(_boundsRect.origin.x, _boundsRect.origin.y, _boundsRect.size.width, [_headerImage size].height) owner:self userData:NULL];
        _headerAccessibilityObject = [[HSMediaStripHeaderAccessibilityObject alloc] initWithOwner:self];
    }
    return self;
}

- (id)patternColor
{
    id pvVar1;

    pvVar1 = _patternColor;
    if ((pvVar1 == nil) && (_backgroundImage != nil)) {
        pvVar1 = [[NSColor colorWithPatternImage:_backgroundImage] retain];
        _patternColor = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00054b43 @ 00054b43, 134 bytes * /

NSRect * FUN_00054b43(NSRect *__return_storage_ptr__,HSMediaStripScrollView *self,SEL _cmd)

{
  NSRect *pNVar1;
  float extraout_EDX;
  float fVar2;
  float local_1c;
  float local_18;
  float local_14;
  
  _objc_msgSend_stret(&local_1c,self,sel_contentBounds);
  if (self->_headerImage == (id)0x0) {
    fVar2 = 0.0;
    pNVar1 = (NSRect *)0x0;
  }
  else {
    pNVar1 = _objc_msgSend(self->_headerImage,sel_size);
    fVar2 = extraout_EDX;
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = local_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = fVar2;
  return pNVar1;
}

*/
- (NSRect)headerRect
{
    NSRect rect = [self contentBounds];
    rect.size.height = _headerImage != nil ? [_headerImage size].height : 0;
    return rect;
}

- (NSRect)scrollerRect
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;
    double dVar5;
    NSRect result;

    fVar1 = (_footerRect).origin.x;
    fVar2 = (_footerRect).origin.y;
    fVar3 = (_footerRect).size.height;
    fVar4 = (_footerRect).size.width;
    dVar5 = [HSMediaStripScroller scrollerWidth];
    result.origin.x = ((fVar1 + fVar4) - (float)dVar5) + -35.0;
    result.origin.y = fVar2 + fVar3 + -23.0 + -4.0;
    result.size.width = (float)dVar5;
    result.size.height = 23.0;
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00054a29 @ 00054a29, 282 bytes * /

NSRect * FUN_00054a29(NSRect *__return_storage_ptr__,HSMediaStripScrollView *self,SEL _cmd,
                     NSRect cornerSplitterRectForBounds,NSRect *scrollerRect)

{
  id pvVar1;
  float fVar2;
  float fVar3;
  undefined *puVar4;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(self->_cornerSplitter,sel_superview);
  if (pvVar1 == (id)0x0) {
    fVar2 = cornerSplitterRectForBounds.origin.x + cornerSplitterRectForBounds.size.width;
    local_1c = *(float *)PTR_0033607c;
    local_18 = *(float *)(PTR_0033607c + 4);
    fVar3 = fVar2;
  }
  else {
    puVar4 = sel_sizeToFit;
    pvVar1 = _objc_msgSend(self->_cornerSplitter,sel_respondsToSelector_,sel_sizeToFit);
    if ((char)pvVar1 == '\0') {
      local_1c = (scrollerRect->size).width;
      local_18 = local_1c;
    }
    else {
      _objc_msgSend(self->_cornerSplitter,sel_sizeToFit,puVar4);
      _objc_msgSend_stret(local_24,self->_cornerSplitter,sel_frame);
    }
    fVar3 = (cornerSplitterRectForBounds.origin.y + cornerSplitterRectForBounds.size.height) -
            local_18;
    (scrollerRect->size).height = fVar3 - (scrollerRect->origin).y;
    fVar2 = (cornerSplitterRectForBounds.origin.x + cornerSplitterRectForBounds.size.width) -
            local_1c;
  }
  (__return_storage_ptr__->origin).x = fVar2;
  (__return_storage_ptr__->origin).y = fVar3;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = local_18;
  return __return_storage_ptr__;
}

*/
- (NSRect)cornerSplitterRectForBounds:(NSRect)aBounds scrollerRect:(NSRect *)aRect
{
    NSRect rect;

    if ([_cornerSplitter superview] == nil) {
        rect.origin.x = NSMaxX(aBounds);
        rect.origin.y = NSMaxX(aBounds);
        rect.size = NSZeroSize;
        return rect;
    }
    if ([_cornerSplitter respondsToSelector:@selector(sizeToFit)]) {
        [_cornerSplitter sizeToFit];
        rect.size = [_cornerSplitter frame].size;
    }
    else {
        rect.size.width = aRect->size.width;
        rect.size.height = aRect->size.width;
    }
    rect.origin.y = NSMaxY(aBounds) - rect.size.height;
    aRect->size.height = rect.origin.y - aRect->origin.y;
    rect.origin.x = NSMaxX(aBounds) - rect.size.width;
    return rect;
}

- (NSRect)contentRectForBounds:(NSRect)aBounds headerMaxY:(CGFloat)aY footerMaxY:(CGFloat)aY2
{
    NSRect result;

    result.origin.x = aBounds.origin.x + 8.0;
    result.origin.y = aY;
    result.size.width = 95.0;
    result.size.height =
    ((aBounds.origin.y + aBounds.size.height) - aY) -
    aY2;
    return result;
}

- (NSRect)contentRectForBounds:(NSRect)aBounds headerMaxY:(CGFloat)aY scrollerMinX:(CGFloat)aX
{
    NSRect result;

    result.origin.x = aBounds.origin.x;
    result.origin.y = aY;
    result.size.width = aX - aBounds.origin.x;
    result.size.height =
    (aBounds.origin.y + aBounds.size.height) - aY;
    return result;
}

- (NSRect)scrollerRectForBounds:(NSRect)aBounds headerMaxY:(CGFloat)aY
{
    NSScroller *pvVar1;
    double dVar2;
    NSRect result;

    pvVar1 = [self verticalScroller];
    dVar2 = [[pvVar1 class] scrollerWidthForControlSize:[pvVar1 controlSize]];
    result.origin.x =
    (aBounds.origin.x + aBounds.size.width) - (float)dVar2;
    result.origin.y = aY;
    result.size.width = (float)dVar2;
    result.size.height =
    (aBounds.origin.y + aBounds.size.height) - aY;
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000549c6 @ 000549c6, 99 bytes * /

NSRect * FUN_000549c6(NSRect *__return_storage_ptr__,HSMediaStripScrollView *self,SEL _cmd)

{
  NSRect *pNVar1;
  undefined8 local_14;
  undefined8 local_c;
  
  _objc_msgSend_stret(&local_14,self,sel_bounds);
  pNVar1 = (NSRect *)_NSInsetRect(__return_storage_ptr__,local_14,local_c,0x40800000,0x40800000);
  return pNVar1;
}

*/
- (NSRect)contentBounds
{
    return NSInsetRect([self bounds], 4, 4);
}

@end

