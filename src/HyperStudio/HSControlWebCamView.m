#import "HSControlWebCamView.h"

@implementation HSControlWebCamView

/* i386 ivar offsets: _renderer=0xf4, _buttonCell=0xf8, _buttonRect=0xfc, _previewImage=0x10c, _isEnabled=0x110, _isPlaying=0x111, _isPreviewChanged=0x112, _webCamViewDelegate=0x114 */

- (void)mouseDragged:(id)aDragged
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ccc2 @ 0016ccc2, 359 bytes * /

void FUN_0016ccc2(HSControlWebCamView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  undefined4 *puVar2;
  undefined4 uStack_68;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar2 = (undefined4 *)&stack0xffffffa4;
  if (self->_isEnabled != '\0') {
    _objc_msgSend_stret(local_34,self,sel_buttonRect);
    puVar2 = (undefined4 *)&stack0xffffffa0;
    _objc_msgSend(mouseDown,sel_locationInWindow);
    _objc_msgSend(self,sel_convertPoint_fromView_);
    pvVar1 = _objc_msgSend(self,sel_mouse_inRect_);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend_stret(local_24,self,sel_buttonRect);
      puVar2 = (undefined4 *)&stack0xffffff9c;
      _objc_msgSend(self,sel_buttonCell);
      pvVar1 = _objc_msgSend(self,sel_trackButtonCell_inRect_withEvent_);
      if ((char)pvVar1 == '\0') {
        return;
      }
      _objc_msgSend(self,sel_buttonCell);
      goto LAB_0016cdf4;
    }
  }
  puVar2[1] = sel_superview;
  *puVar2 = self;
  puVar2[-1] = 0x16ce13;
  pvVar1 = _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  puVar2[2] = mouseDown;
  puVar2[1] = sel_mouseDown_;
  *puVar2 = pvVar1;
LAB_0016cdf4:
  puVar2[-1] = 0x16cdf9;
  _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    if (_isEnabled) {
        NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
        if ([self mouse:point inRect:[self buttonRect]]) {
            if ([self trackButtonCell:[self buttonCell] inRect:[self buttonRect] withEvent:aDown]) {
                [self togglePlay:[self buttonCell]];
            }
            return;
        }
    }
    [[self superview] mouseDown:aDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ca31 @ 0016ca31, 497 bytes * /

BOOL FUN_0016ca31(HSControlWebCamView *self,SEL _cmd,id trackButtonCell,NSRect inRect,id withEvent)

{
  bool bVar1;
  bool bVar2;
  id self_00;
  id pvVar3;
  undefined4 extraout_EDX;
  HSControlWebCamView *extraout_EDX_00;
  undefined4 uVar4;
  HSControlWebCamView *pHVar5;
  HSControlWebCamView *pHVar6;
  HSControlWebCamView *pHVar7;
  HSControlWebCamView *pHVar8;
  HSControlWebCamView *pHVar9;
  HSControlWebCamView *pHVar10;
  HSControlWebCamView *pHVar11;
  HSControlWebCamView *pHVar12;
  HSControlWebCamView *pHVar13;
  undefined4 uVar14;
  
  self_00 = _objc_msgSend(self,sel_window);
  bVar1 = false;
LAB_0016cc0b:
  do {
    if (bVar1) {
      return '\0';
    }
    pHVar9 = inRect.size.width;
    pHVar11 = inRect.size.height;
    pHVar5 = inRect.origin.x;
    pHVar7 = inRect.origin.y;
    _objc_msgSend(trackButtonCell,sel_highlight_withFrame_inView_,1,pHVar5,pHVar7,pHVar9,pHVar11,
                  self);
    uVar14 = 0;
    pvVar3 = _objc_msgSend(trackButtonCell,sel_trackMouse_inRect_ofView_untilMouseUp_,withEvent,
                           pHVar5,pHVar7,pHVar9,pHVar11,self,0);
    uVar4 = 0;
    pHVar6 = pHVar5;
    pHVar8 = pHVar7;
    pHVar10 = pHVar9;
    pHVar12 = pHVar11;
    pHVar13 = self;
    _objc_msgSend(trackButtonCell,sel_highlight_withFrame_inView_,0,pHVar5,pHVar7,pHVar9,pHVar11,
                  self);
    bVar2 = bVar1;
    if ((char)pvVar3 != '\0') {
      _objc_msgSend(self,sel_displayIfNeeded,uVar4,pHVar6,pHVar8,pHVar10,pHVar12,pHVar13,uVar14);
      return (char)pvVar3;
    }
    do {
      do {
        bVar1 = bVar2;
        if (bVar1) goto LAB_0016cc0b;
        uVar4 = 0x44;
        withEvent = _objc_msgSend(self_00,sel_nextEventMatchingMask_,0x44,pHVar6,pHVar8,pHVar10,
                                  pHVar12,pHVar13,uVar14);
        pvVar3 = _objc_msgSend(withEvent,sel_type);
        bVar2 = true;
      } while (pvVar3 == (id)0x2);
      pvVar3 = _objc_msgSend(withEvent,sel_locationInWindow,uVar4,pHVar6,pHVar8,pHVar10,pHVar12,
                             pHVar13);
      pvVar3 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
      pHVar6 = extraout_EDX_00;
      pHVar8 = pHVar5;
      pHVar10 = pHVar7;
      pHVar12 = pHVar9;
      pHVar13 = pHVar11;
      pvVar3 = _objc_msgSend(self,sel_mouse_inRect_,pvVar3);
      bVar2 = bVar1;
    } while ((char)pvVar3 == '\0');
  } while( true );
}

*/
- (BOOL)trackButtonCell:(id)aCell inRect:(NSRect)aRect withEvent:(id)aEvent
{
    NSWindow *window = [self window];
    while (YES) {
        [aCell highlight:YES withFrame:aRect inView:self];
        BOOL tracked = [aCell trackMouse:aEvent inRect:aRect ofView:self untilMouseUp:NO];
        [aCell highlight:NO withFrame:aRect inView:self];
        if (tracked) {
            [self displayIfNeeded];
            return YES;
        }
        while (YES) {
            NSEvent *event = [window nextEventMatchingMask:0x44];
            aEvent = event;
            if ([event type] == 2) {
                return NO;
            }
            NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
            if ([self mouse:point inRect:aRect]) {
                break;
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ce29 @ 0016ce29, 2310 bytes * /

void FUN_0016ce29(HSControlWebCamView *self,SEL _cmd,NSRect drawQuartzRect)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  int *piVar6;
  int *piVar7;
  int *piVar8;
  float local_9c [6];
  undefined1 local_84 [16];
  undefined1 local_74 [16];
  undefined4 local_64;
  undefined4 uStack_60;
  id local_5c;
  undefined1 local_54 [16];
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined1 local_24 [20];
  
  piVar6 = (int *)&stack0xffffff04;
  if (self->_isEnabled == '\0') {
    _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
    pvVar2 = _objc_msgSend(cls_NSColor,sel_grayColor);
    _objc_msgSend(pvVar2,sel_setFill);
    _objc_msgSend(cls_NSBezierPath,sel_fillRect_);
    pvVar2 = _objc_msgSend(cls_NSColor,sel_whiteColor);
    _objc_msgSend(pvVar2,sel_set);
    puVar1 = cls_NSBezierPath;
    _objc_msgSend_stret(local_24,self,sel_bounds);
    piVar8 = (int *)&stack0xffffff00;
    pvVar2 = _objc_msgSend(puVar1,sel_bezierPathWithRect_);
    _objc_msgSend(pvVar2,sel_setLineWidth_);
    _objc_msgSend(pvVar2,sel_stroke);
  }
  else {
    _objc_msgSend(self,sel_buttonCell);
    pvVar2 = _objc_msgSend(self,sel_isPlaying);
    if ((char)pvVar2 == '\0') {
      _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
      pvVar2 = _objc_msgSend(cls_NSColor,sel_grayColor);
      _objc_msgSend(pvVar2,sel_setFill);
      _objc_msgSend(cls_NSBezierPath,sel_fillRect_);
      if (self->_previewImage != (id)0x0) {
        _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
        pvVar2 = _objc_msgSend(cls_NSAffineTransform,sel_transform);
        _objc_msgSend(pvVar2,sel_scaleXBy_yBy_);
        _objc_msgSend_stret(local_74,self,sel_bounds);
        _objc_msgSend(pvVar2,sel_translateXBy_yBy_);
        _objc_msgSend(pvVar2,sel_concat);
        local_5c = _objc_msgSend(self->_previewImage,sel_size);
        pvVar2 = self->_previewImage;
        local_64 = 0;
        uStack_60 = 0;
        _objc_msgSend_stret(local_54,self,sel_bounds);
        piVar6 = (int *)&stack0xfffffefc;
        _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_);
        _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
      }
      piVar6[1] = (int)sel_whiteColor;
      *piVar6 = (int)cls_NSColor;
      piVar6[-1] = 0x16d468;
      pvVar2 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      piVar6[1] = (int)sel_set;
      *piVar6 = (int)pvVar2;
      piVar6[-1] = 0x16d47a;
      _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      puVar1 = cls_NSBezierPath;
      piVar6[2] = (int)sel_bounds;
      piVar6[1] = (int)self;
      *piVar6 = (int)&local_44;
      piVar6[-1] = 0x16d49c;
      _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
      piVar7 = piVar6 + -1;
      *(undefined8 *)(piVar6 + 3) = local_3c;
      *(undefined8 *)(piVar6 + 1) = local_44;
      *piVar6 = (int)sel_bezierPathWithRect_;
      piVar6[-1] = (int)puVar1;
      piVar6[-2] = 0x16d4c7;
      pvVar2 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      *piVar6 = (int)sel_setLineWidth_;
      piVar6[-1] = (int)pvVar2;
      piVar6[1] = 0x40800000;
      piVar6[-2] = 0x16d4e3;
      _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      *piVar6 = (int)sel_stroke;
      piVar6[-1] = (int)pvVar2;
      piVar6[-2] = 0x16d4f5;
      _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      *piVar6 = (int)sel_restoreGraphicsState;
      piVar6[-1] = (int)cls_NSGraphicsContext;
      piVar6[-2] = 0x16d50d;
      _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      piVar6[1] = (int)&cfstr_WebCamRefresh;
      *piVar6 = (int)sel_imageNamed_;
      piVar6[-1] = (int)cls_NSImage;
      piVar6[-2] = 0x16d52f;
      pvVar2 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      pcVar5 = &cfstr_WebCamRefreshPressed;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_nodeForRender);
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
      _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
      pvVar3 = _objc_msgSend(cls_NSColor,sel_blackColor);
      _objc_msgSend(pvVar3,sel_setFill);
      _objc_msgSend(cls_NSBezierPath,sel_fillRect_);
      _objc_msgSend_stret(local_9c,pvVar2,sel_affineTransform);
      pvVar2 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperCGAffineTransform_);
      _objc_msgSend(pvVar2,sel_concat);
      _NSInsetRect();
      pvVar2 = _objc_msgSend(cls_HSMutableRegion,sel_regionWithRect_);
      _objc_msgSend(pvVar2,sel_applyAffineTransform_);
      pvVar2 = _objc_msgSend(self,sel_renderer);
      _objc_msgSend(cls_HSGenericRenderDelegate,sel_delegateWithDrawable_);
      _objc_msgSend(pvVar2,sel_drawRegion_withDelegate_);
      pvVar2 = _objc_msgSend(cls_NSColor,sel_whiteColor);
      _objc_msgSend(pvVar2,sel_set);
      puVar1 = cls_NSBezierPath;
      _objc_msgSend_stret(local_84,self,sel_bounds);
      piVar7 = (int *)&stack0xfffffef8;
      pvVar2 = _objc_msgSend(puVar1,sel_bezierPathWithRect_);
      _objc_msgSend(pvVar2,sel_setLineWidth_);
      _objc_msgSend(pvVar2,sel_stroke);
      _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
      pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_);
      pcVar5 = &cfstr_WebCamStoppedPressed;
    }
    piVar7[2] = (int)pcVar5;
    piVar7[1] = (int)sel_imageNamed_;
    *piVar7 = (int)cls_NSImage;
    piVar7[-1] = 0x16d553;
    pvVar4 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    pvVar3 = self->_buttonCell;
    piVar7[2] = (int)pvVar2;
    piVar7[1] = (int)sel_setImage_;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = 0x16d574;
    _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    pvVar2 = self->_buttonCell;
    piVar7[2] = (int)pvVar4;
    piVar7[1] = (int)sel_setAlternateImage_;
    *piVar7 = (int)pvVar2;
    piVar7[-1] = 0x16d593;
    _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_buttonCell;
    *piVar7 = (int)self;
    piVar7[-1] = 0x16d5a8;
    pvVar2 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[2] = (int)sel_buttonRect;
    piVar7[1] = (int)self;
    *piVar7 = (int)&local_34;
    piVar7[-1] = 0x16d5c6;
    _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
    piVar8 = piVar7 + -1;
    *(undefined8 *)(piVar7 + 3) = local_2c;
    *(undefined8 *)(piVar7 + 1) = local_34;
    piVar7[5] = (int)self;
    *piVar7 = (int)sel_drawWithFrame_inView_;
    piVar7[-1] = (int)pvVar2;
  }
  piVar8[-1] = 0x16d5f8;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  return;
}

*/
- (void)drawQuartzRect:(NSRect)aRect
{
    if (!_isEnabled) {
        [NSGraphicsContext saveGraphicsState];
        [[NSColor grayColor] setFill];
        [NSBezierPath fillRect:aRect];
        [[NSColor whiteColor] set];
        NSBezierPath *border = [NSBezierPath bezierPathWithRect:[self bounds]];
        [border setLineWidth:4.0];
        [border stroke];
        [NSGraphicsContext restoreGraphicsState];
        return;
    }
    [self buttonCell];
    NSImage *image;
    NSImage *alternateImage;
    if ([self isPlaying]) {
        id geometry = [[self nodeForRender] queryHyperInterface:@protocol(HSGeometryAttributes)];
        [NSGraphicsContext saveGraphicsState];
        [[NSColor blackColor] setFill];
        [NSBezierPath fillRect:aRect];
        CGAffineTransform transform = [geometry affineTransform];
        [[NSAffineTransform transformWithHyperCGAffineTransform:transform] concat];
        HSMutableRegion *region = [HSMutableRegion regionWithRect:NSInsetRect(aRect, 8.0, 8.0)];
        [region applyAffineTransform:CGAffineTransformInvert(transform)];
        [[self renderer] drawRegion:region withDelegate:[HSGenericRenderDelegate delegateWithDrawable:nil]];
        [[NSColor whiteColor] set];
        NSBezierPath *border = [NSBezierPath bezierPathWithRect:[self bounds]];
        [border setLineWidth:4.0];
        [border stroke];
        [NSGraphicsContext restoreGraphicsState];
        image = [NSImage imageNamed:@"WebCamStopped"];
        alternateImage = [NSImage imageNamed:@"WebCamStoppedPressed"];
    }
    else {
        [NSGraphicsContext saveGraphicsState];
        [[NSColor grayColor] setFill];
        [NSBezierPath fillRect:aRect];
        if (_previewImage != nil) {
            [NSGraphicsContext saveGraphicsState];
            NSAffineTransform *flip = [NSAffineTransform transform];
            [flip scaleXBy:1.0 yBy:-1.0];
            [flip translateXBy:0.0 yBy:-[self bounds].size.height];
            [flip concat];
            NSSize size = [_previewImage size];
            [_previewImage drawInRect:[self bounds] fromRect:NSMakeRect(0.0, 0.0, size.width, size.height) operation:2 fraction:1.0];
            [NSGraphicsContext restoreGraphicsState];
        }
        [[NSColor whiteColor] set];
        NSBezierPath *border = [NSBezierPath bezierPathWithRect:[self bounds]];
        [border setLineWidth:4.0];
        [border stroke];
        [NSGraphicsContext restoreGraphicsState];
        image = [NSImage imageNamed:@"WebCamRefresh"];
        alternateImage = [NSImage imageNamed:@"WebCamRefreshPressed"];
    }
    [_buttonCell setImage:image];
    [_buttonCell setAlternateImage:alternateImage];
    [[self buttonCell] drawWithFrame:[self buttonRect] inView:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016d72f @ 0016d72f, 91 bytes * /

id FUN_0016d72f(HSControlWebCamView *self,SEL _cmd)

{
  id pvVar1;
  HSControlWebCamView *local_14;
  undefined *local_10;
  
  _objc_msgSend(*(id *)(self->super_HSControlObjectView + 0xe4),sel_release);
  self->super_HSControlObjectView[0xe4] = 0;
  self->super_HSControlObjectView[0xe5] = 0;
  self->super_HSControlObjectView[0xe6] = 0;
  self->super_HSControlObjectView[0xe7] = 0;
  local_14 = self;
  local_10 = PTR_s_HSControlObjectView_003522b0;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_objectImage);
  return pvVar1;
}

*/
- (id)objectImage
{
    [_objectImage release];
    _objectImage = nil;
    return [super objectImage];
}

- (BOOL)isOpaque
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)videoStreamDidChange:(id)aChange
{
    [self setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016c9ac @ 0016c9ac, 87 bytes * /

void FUN_0016c9ac(HSControlWebCamView *self,SEL _cmd)

{
  _objc_msgSend(*(id *)(self->super_HSControlObjectView + 0xd8),
                sel_removeObserver_selector_ofChanges_ofAttribute_,self,sel_videoStreamDidChange_,
                *(undefined4 *)PTR_0033601c,&DAT_00374de0);
  return;
}

*/
- (void)unsubscribeFromNotifications
{
    [_renderNode removeObserver:self selector:@selector(videoStreamDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016c94d @ 0016c94d, 95 bytes * /

void FUN_0016c94d(HSControlWebCamView *self,SEL _cmd)

{
  _objc_msgSend(*(id *)(self->super_HSControlObjectView + 0xd8),
                sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_videoStreamDidChange_,*(undefined4 *)PTR_0033601c,&DAT_00374de0,0xbf400000);
  return;
}

*/
- (void)subscribeToNotifications
{
    [_renderNode addObserver:self selector:@selector(videoStreamDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016d78a @ 0016d78a, 641 bytes * /

void FUN_0016d78a(HSControlWebCamView *self,SEL _cmd,id initializeRenderNode)

{
  id pvVar1;
  id self_00;
  undefined1 local_34 [8];
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(initializeRenderNode,sel_queryHyperInterface_);
  _objc_msgSend(pvVar1,sel_setPrefersToMaintainSizeAspectRatio_);
  _objc_msgSend(pvVar1,sel_setPrefersToMaintainSizeScaleAspectRatio_);
  pvVar1 = _objc_msgSend(initializeRenderNode,sel_queryHyperInterface_);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  self_00 = _objc_msgSend(pvVar1,sel_mutableGeometryAttributes);
  _objc_msgSend_stret(&local_24,self,sel_bounds);
  _objc_msgSend(pvVar1,sel_setAffineTransform_flippedHorizontally_withLayoutGuidingContext_,
                *(undefined8 *)PTR_00336088,*(undefined8 *)(PTR_00336088 + 8),
                *(undefined8 *)(PTR_00336088 + 0x10),0,0);
  _objc_msgSend(pvVar1,sel_resizeFrameTo_aboutRelativePoint_withLayoutGuidingContext_,local_1c,
                local_18,*(undefined4 *)PTR_00336074,*(undefined4 *)(PTR_00336074 + 4),0);
  _objc_msgSend_stret(local_34,self_00,sel_frameBoundingRect);
  _objc_msgSend(pvVar1,sel_moveBy_withLayoutGuidingContext_,(local_1c - local_2c) * 0.5 + local_24,
                (local_18 - local_28) * 0.5 + local_20,0);
  (self->_buttonRect).origin.x = local_24 + local_1c + -23.0 + -5.0;
  (self->_buttonRect).origin.y = local_20 + local_18 + -16.0 + -5.0;
  (self->_buttonRect).size.width = 23.0;
  (self->_buttonRect).size.height = 16.0;
  pvVar1 = _objc_msgSend(initializeRenderNode,sel_queryHyperInterface_,&DAT_00374f84);
  _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,0);
  return;
}

*/
- (void)initializeRenderNode:(id)aNode
{
    id behavior = [aNode queryHyperInterface:@protocol(HSMutableGeometryBehaviorAttributes)];
    [behavior setPrefersToMaintainSizeAspectRatio:YES];
    [behavior setPrefersToMaintainSizeScaleAspectRatio:YES];
    id applier = [[aNode queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    id geometry = [applier mutableGeometryAttributes];
    NSRect bounds = [self bounds];
    [applier setAffineTransform:CGAffineTransformIdentity flippedHorizontally:NO withLayoutGuidingContext:nil];
    [applier resizeFrameTo:bounds.size aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
    NSRect frame = [geometry frameBoundingRect];
    [applier moveBy:NSMakeSize((bounds.size.width - frame.size.width) * 0.5 + bounds.origin.x, (bounds.size.height - frame.size.height) * 0.5 + bounds.origin.y) withLayoutGuidingContext:nil];
    _buttonRect = NSMakeRect(bounds.origin.x + bounds.size.width - 23.0 - 5.0, bounds.origin.y + bounds.size.height - 16.0 - 5.0, 23.0, 16.0);
    [[aNode queryHyperInterface:@protocol(HSShadowAttributes)] setHyperShadowEnabled:NO];
}

- (id)renderer
{
    id pvVar1;

    pvVar1 = _renderer;
    if (pvVar1 == nil) {
        pvVar1 = [[[[self nodeForRender] queryHyperInterface:@protocol(HSVisualization)] queryRenderer] retain];
        _renderer = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016c331 @ 0016c331, 64 bytes * /

NSRect * FUN_0016c331(NSRect *__return_storage_ptr__,HSControlWebCamView *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_buttonRect).origin.x;
  (__return_storage_ptr__->origin).y = (self->_buttonRect).origin.y;
  (__return_storage_ptr__->size).width = (self->_buttonRect).size.width;
  (__return_storage_ptr__->size).height = (self->_buttonRect).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)buttonRect
{
    return _buttonRect;
}

- (id)buttonCell
{
    id pvVar1;
    id pvVar2;
    id pvVar1_2;
    id pvVar1_3;

    pvVar1 = _buttonCell;
    if (pvVar1 == nil) {
        pvVar1_2 = [NSImage imageNamed:@"WebCamRefresh"];
        pvVar2 = [NSImage imageNamed:@"WebCamRefreshPressed"];
        pvVar1_3 = [[NSButtonCell alloc] initImageCell:pvVar1_2];
        _buttonCell = pvVar1_3;
        [pvVar1_3 setAlternateImage:pvVar2];
        [_buttonCell setBordered:NO];
        [_buttonCell setButtonType:5];
        [_buttonCell setBezelStyle:6];
        pvVar1 = _buttonCell;
    }
    return pvVar1;
}

- (id)webCamViewDelegate
{
    return _webCamViewDelegate;
}

- (void)setWebCamViewDelegate:(id)aDelegate
{
    _webCamViewDelegate = aDelegate;
}

- (void)stopPlaying
{
    if ([self isPlaying]) {
        [self togglePlay:self];
    }
}

- (void)startPlaying
{
    if (![self isPlaying]) {
        [self togglePlay:self];
    }
}

- (BOOL)isPlaying
{
    return _isPlaying;
}

- (void)setEnabled:(BOOL)aEnabled
{
    if (_isEnabled != aEnabled) {
        _isEnabled = aEnabled;
        if (aEnabled == NO) {
            [self stopPlaying];
        }
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)isEnabled
{
    return _isEnabled;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016c594 @ 0016c594, 315 bytes * /

void FUN_0016c594(HSControlWebCamView *self,SEL _cmd,id togglePlay)

{
  id self_00;
  id pvVar1;
  HSControlWebCamView *pHVar2;
  
  pHVar2 = (HSControlWebCamView *)&DAT_00374d40;
  self_00 = _objc_msgSend(*(id *)(self->super_HSControlObjectView + 0xd8),sel_queryHyperInterface_,
                          &DAT_00374d40);
  if ((self_00 == (id)0x0) || (self->_isPlaying != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_buttonCell,pHVar2);
    if (pvVar1 == togglePlay) {
      pHVar2 = _objc_msgSend(self,sel_objectImage,pHVar2);
      _objc_msgSend(self,sel_setPreviewImage_,pHVar2);
      pvVar1 = _objc_msgSend(self_00,sel_isLoading);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_webCamViewDelegate,pHVar2);
        pHVar2 = self;
        _objc_msgSend(pvVar1,sel_newPreviewIsDoneForWebCamView_,self);
      }
    }
    _objc_msgSend(self_00,sel_stopLoading,pHVar2);
    self->_isPlaying = '\0';
  }
  else {
    _objc_msgSend(self_00,sel_performSelector_withObject_afterDelay_,sel_startLoading,0,0,0);
    self->_isPlaying = '\x01';
  }
  _objc_msgSend(self,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)togglePlay:(id)aPlay
{
    id webPage = [_renderNode queryHyperInterface:@protocol(HSWebPageAttributes)];
    if (webPage == nil || _isPlaying) {
        if ([self buttonCell] == aPlay) {
            [self setPreviewImage:[self objectImage]];
            if ([webPage isLoading]) {
                [[self webCamViewDelegate] newPreviewIsDoneForWebCamView:self];
            }
        }
        [webPage stopLoading];
        _isPlaying = NO;
    }
    else {
        [webPage performSelector:@selector(startLoading) withObject:nil afterDelay:0.0];
        _isPlaying = YES;
    }
    [self setNeedsDisplay:YES];
}

- (void)setIdentifier:(id)aIdentifier
{
    id pvVar1_2;

    pvVar1_2 = [[self nodeForRender] queryHyperInterface:@protocol(HSWebPageAttributes)];
    if (pvVar1_2 != nil) {
        [pvVar1_2 setWebPageCameraID:aIdentifier];
    }
    if (_isPlaying != NO) {
        [self togglePlay:self];
    }
}

- (id)identifier
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[self nodeForRender] queryHyperInterface:@protocol(HSWebPageAttributes)];
    if (pvVar1_2 == nil) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [pvVar1_2 webPageCameraID];
    }
    return pvVar1_3;
}

- (void)setURL:(id)aURL
{
    id pvVar1_2;

    pvVar1_2 = [[self nodeForRender] queryHyperInterface:@protocol(HSWebPageAttributes)];
    if (pvVar1_2 != nil) {
        [pvVar1_2 setWebPageURL:aURL];
    }
}

- (id)URL
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[self nodeForRender] queryHyperInterface:@protocol(HSWebPageAttributes)];
    if (pvVar1_2 == nil) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [pvVar1_2 webPageURL];
    }
    return pvVar1_3;
}

- (void)setPreviewImage:(id)aImage
{
    if (_previewImage != aImage) {
        [_previewImage release];
        _previewImage = [aImage retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)previewImage
{
    return _previewImage;
}

- (id)objectClassName
{
    return @"HSWebPageObject";
}

- (void)dealloc
{
    if (_isPlaying != NO) {
        [self togglePlay:self];
    }
    [_previewImage release];
    [_renderer release];
    [_buttonCell release];
    [super dealloc];
}

@end

