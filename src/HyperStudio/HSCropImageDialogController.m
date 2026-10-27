#import "HSCropImageDialogController.h"

@implementation HSCropImageDialogController

/* i386 ivar offsets: _scrollView=0x28, _imageCropView=0x2c, _scaleSlider=0x30, _toolMatrix=0x34, _OKButton=0x38, _toleranceSlider=0x3c, _sensitivityView=0x40, _selectedToolTag=0x44, _selectionTolerance=0x48, _selectionAlternateProportion=0x4c, _isFlippedVertically=0x50, _isFlippedHorizontally=0x51 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00231c4b @ 00231c4b, 150 bytes * /

void FUN_00231c4b(HSCropImageDialogController *self,SEL _cmd,id clipViewBoundsChanged)

{
  id pvVar1;
  id self_00;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(clipViewBoundsChanged,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_documentView);
  self_00 = _objc_msgSend(clipViewBoundsChanged,sel_object);
  _objc_msgSend_stret(local_24,self_00,sel_bounds);
  _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
  return;
}

*/
- (void)clipViewBoundsChanged:(id)aChanged
{
    [[[aChanged object] documentView] setFrameSize:[[aChanged object] bounds].size];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00231ce1 @ 00231ce1, 150 bytes * /

void FUN_00231ce1(HSCropImageDialogController *self,SEL _cmd,id clipViewFrameChanged)

{
  id pvVar1;
  id self_00;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(clipViewFrameChanged,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_documentView);
  self_00 = _objc_msgSend(clipViewFrameChanged,sel_object);
  _objc_msgSend_stret(local_24,self_00,sel_bounds);
  _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
  return;
}

*/
- (void)clipViewFrameChanged:(id)aChanged
{
    [[[aChanged object] documentView] setFrameSize:[[aChanged object] bounds].size];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023156c @ 0023156c, 1468 bytes * /

void FUN_0023156c(HSCropImageDialogController *self,SEL _cmd,
                 id *setupSelectionToolForResizeAndRotateOperation)

{
  id self_00;
  id pvVar1;
  
  if ((setupSelectionToolForResizeAndRotateOperation != (id *)0x0) &&
     (self_00 = *setupSelectionToolForResizeAndRotateOperation, self_00 != (id)0x0)) {
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336304);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillResizeTopLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeTopLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setWillResizeBottomRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeBottomRightSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336308);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillResizeTopRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeTopRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setWillResizeBottomLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeBottomLeftSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362e8);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillResizeCenterLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeCenterLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setWillResizeCenterRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeCenterRightSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362ec);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillResizeTopCenterSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeTopCenterSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setWillResizeBottomCenterSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoResizeBottomCenterSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c8);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateBottomLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateBottomLeftSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362d0);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateBottomCenterSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateBottomCenterSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362cc);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateBottomRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateBottomRightSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362d4);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateCenterLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateCenterLeftSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362d8);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateCenterRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateCenterRightSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362dc);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateTopLeftSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateTopLeftSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362e4);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateTopCenterSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateTopCenterSelectionCursor_,pvVar1);
    }
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362e0);
    pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self_00,sel_setWillRotateTopRightSelectionCursor_,pvVar1);
      _objc_msgSend(self_00,sel_setDoRotateTopRightSelectionCursor_,pvVar1);
    }
  }
  return;
}

*/
- (void)setupSelectionToolForResizeAndRotateOperation:(id *)aOperation
{
    id tool;
    id cursor;

    if (aOperation == NULL || (tool = *aOperation) == nil) {
        return;
    }
    cursor = [[HSCursor cursorNamed:HSTLBRCursor] cursor];
    if (cursor != nil) {
        [tool setWillResizeTopLeftSelectionCursor:cursor];
        [tool setDoResizeTopLeftSelectionCursor:cursor];
        [tool setWillResizeBottomRightSelectionCursor:cursor];
        [tool setDoResizeBottomRightSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSTRBLCursor] cursor];
    if (cursor != nil) {
        [tool setWillResizeTopRightSelectionCursor:cursor];
        [tool setDoResizeTopRightSelectionCursor:cursor];
        [tool setWillResizeBottomLeftSelectionCursor:cursor];
        [tool setDoResizeBottomLeftSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSScaleHorCursor] cursor];
    if (cursor != nil) {
        [tool setWillResizeCenterLeftSelectionCursor:cursor];
        [tool setDoResizeCenterLeftSelectionCursor:cursor];
        [tool setWillResizeCenterRightSelectionCursor:cursor];
        [tool setDoResizeCenterRightSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSScaleVertCursor] cursor];
    if (cursor != nil) {
        [tool setWillResizeTopCenterSelectionCursor:cursor];
        [tool setDoResizeTopCenterSelectionCursor:cursor];
        [tool setWillResizeBottomCenterSelectionCursor:cursor];
        [tool setDoResizeBottomCenterSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateBLCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateBottomLeftSelectionCursor:cursor];
        [tool setDoRotateBottomLeftSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateBottomCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateBottomCenterSelectionCursor:cursor];
        [tool setDoRotateBottomCenterSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateBRCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateBottomRightSelectionCursor:cursor];
        [tool setDoRotateBottomRightSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateLeftCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateCenterLeftSelectionCursor:cursor];
        [tool setDoRotateCenterLeftSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateRightCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateCenterRightSelectionCursor:cursor];
        [tool setDoRotateCenterRightSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateTLCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateTopLeftSelectionCursor:cursor];
        [tool setDoRotateTopLeftSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateTopCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateTopCenterSelectionCursor:cursor];
        [tool setDoRotateTopCenterSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSRotateTRCursor] cursor];
    if (cursor != nil) {
        [tool setWillRotateTopRightSelectionCursor:cursor];
        [tool setDoRotateTopRightSelectionCursor:cursor];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00231d77 @ 00231d77, 257 bytes * /

id FUN_00231d77(HSCropImageDialogController *self,SEL _cmd,int toolForTag)

{
  undefined4 uVar1;
  id pvVar2;
  
  if (toolForTag == 2) {
    pvVar2 = _objc_msgSend(self,sel_magicLassoCreateSelectionTool);
  }
  else {
    if (toolForTag == 1) {
      uVar1 = _CGPathCreateMutable();
      _CGPathAddEllipseInRect(uVar1,0,0,0x3f8000003f800000);
    }
    else {
      if (toolForTag != 0) {
        return (id)0x0;
      }
      uVar1 = _CGPathCreateMutable();
      _CGPathAddRect(uVar1,0,0,0x3f8000003f800000);
    }
    pvVar2 = _objc_msgSend(self,sel_shapeCreateSelectionToolWithPath_,uVar1);
    _CGPathRelease(uVar1);
  }
  return pvVar2;
}

*/
- (id)toolForTag:(NSInteger)aTag
{
    CGMutablePathRef path;
    id tool;

    if (aTag == 2) {
        return [self magicLassoCreateSelectionTool];
    }
    if (aTag == 1) {
        path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, 1, 1));
    }
    else if (aTag == 0) {
        path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, 1, 1));
    }
    else {
        return nil;
    }
    tool = [self shapeCreateSelectionToolWithPath:(id)path];
    CGPathRelease(path);
    return tool;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002313a0 @ 002313a0, 460 bytes * /

id FUN_002313a0(HSCropImageDialogController *self,SEL _cmd)

{
  id pvVar1;
  id local_14;
  
  local_14 = _objc_msgSend(cls_BTSelectionTool,sel_new);
  _objc_msgSend(local_14,sel_setInitialCreateSelectionMode_,&cfstr_BTMagicLassoCreateSelectionMode);
  _objc_msgSend(local_14,sel_setTolerance_,self->_selectionTolerance);
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,&cfstr_HSLassoCursor);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(local_14,sel_setWillCreateMagicLassoSelectionCursor_,pvVar1);
    _objc_msgSend(local_14,sel_setDoCreateMagicLassoSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c4);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(local_14,sel_setWillCreateMagicWandSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336294);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(local_14,sel_setWillCreateFreeHandSelectionCursor_,pvVar1);
    _objc_msgSend(local_14,sel_setDoCreateFreeHandSelectionCursor_,pvVar1);
  }
  _objc_msgSend(self,sel_setupSelectionToolForResizeAndRotateOperation_,&local_14);
  pvVar1 = _objc_msgSend(local_14,sel_autorelease);
  return pvVar1;
}

*/
- (id)magicLassoCreateSelectionTool
{
    id tool = [BTSelectionTool new];
    id cursor;

    [tool setInitialCreateSelectionMode:@"BTMagicLassoCreateSelectionMode"];
    [(BTSelectionTool *)tool setTolerance:_selectionTolerance];
    cursor = [[HSCursor cursorNamed:@"HSLassoCursor"] cursor];
    if (cursor != nil) {
        [tool setWillCreateMagicLassoSelectionCursor:cursor];
        [tool setDoCreateMagicLassoSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSReverseToolCursor] cursor];
    if (cursor != nil) {
        [tool setWillCreateMagicWandSelectionCursor:cursor];
    }
    cursor = [[HSCursor cursorNamed:HSPencilLassoCursor] cursor];
    if (cursor != nil) {
        [tool setWillCreateFreeHandSelectionCursor:cursor];
        [tool setDoCreateFreeHandSelectionCursor:cursor];
    }
    [self setupSelectionToolForResizeAndRotateOperation:&tool];
    return [tool autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00231e78 @ 00231e78, 227 bytes * /

id FUN_00231e78(HSCropImageDialogController *self,SEL _cmd,id shapeCreateSelectionToolWithPath)

{
  id pvVar1;
  double dVar2;
  id local_14;
  
  local_14 = _objc_msgSend(cls_BTSelectionTool,sel_new);
  _objc_msgSend(local_14,sel_setInitialCreateSelectionMode_,&cfstr_BTShapeCreateSelectionMode);
  _objc_msgSend(local_14,sel_setTolerance_,0);
  pvVar1 = local_14;
  dVar2 = _objc_msgSend_fpret(self,sel_selectionAlternateProportion);
  _objc_msgSend(pvVar1,sel_setAlternateProportion_,(float)dVar2);
  _objc_msgSend(local_14,sel_setSelectionShapePrototypePath_,shapeCreateSelectionToolWithPath);
  _objc_msgSend(self,sel_setupSelectionToolForResizeAndRotateOperation_,&local_14);
  pvVar1 = _objc_msgSend(local_14,sel_autorelease);
  return pvVar1;
}

*/
- (id)shapeCreateSelectionToolWithPath:(id)aPath
{
    id tool = [BTSelectionTool new];

    [tool setInitialCreateSelectionMode:@"BTShapeCreateSelectionMode"];
    [(BTSelectionTool *)tool setTolerance:0];
    [(BTSelectionTool *)tool setAlternateProportion:[self selectionAlternateProportion]];
    [tool setSelectionShapePrototypePath:aPath];
    [self setupSelectionToolForResizeAndRotateOperation:&tool];
    return [tool autorelease];
}

- (void)selectionToleranceChanged:(id)aChanged
{
    [self setSelectionTolerance:1.0 - (float)[aChanged floatValue]];
}

- (void)selectAllArea:(id)aArea
{
    id self_00;

    if (_toolMatrix == aArea) {
        self_00 = [_imageCropView currentTool];
        if ([self_00 respondsToSelector:@selector(selectAllArea:)]) {
            [self_00 performSelector:@selector(selectAllArea:) withObject:0];
        }
    }
}

- (void)toolChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged selectedTag];
    if (pvVar1 != _selectedToolTag) {
        [_imageCropView setCurrentTool:[self toolForTag:pvVar1] forceSwitch:YES];
        _selectedToolTag = (int)pvVar1;
        [self validateToleranceSlider];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)zoomMax:(id)aMax
{
    id self_00;

    self_00 = _scaleSlider;
    [self_00 setDoubleValue:[self_00 maxValue]];
    [self scaleChanged:_scaleSlider];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)zoomMin:(id)aMin
{
    id self_00;

    self_00 = _scaleSlider;
    [self_00 setDoubleValue:[self_00 minValue]];
    [self scaleChanged:_scaleSlider];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023206a @ 0023206a, 60 bytes * /

void FUN_0023206a(HSCropImageDialogController *self,SEL _cmd,id scaleChanged)

{
  id self_00;
  longdouble lVar1;
  
  self_00 = self->_imageCropView;
  lVar1 = (longdouble)_HSNonLinearValueForSlider(scaleChanged);
  _objc_msgSend(self_00,sel_setScaleFactor_,(double)lVar1);
  return;
}

*/
- (void)scaleChanged:(id)aChanged
{
    [_imageCropView setScaleFactor:HSNonLinearValueForSlider(aChanged)];
}

- (void)openHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSCropImage"];
}

- (void)cancel:(id)aCancel
{
    [self closeDialogWithCode:0];
}

- (void)crop:(id)aCrop
{
    [self closeDialogWithCode:1];
}

- (void)closeDialogWithCode:(NSInteger)aCode
{
    if ([NSApp modalWindow] == [self window]) {
        [[self window] close];
        [NSApp stopModalWithCode:aCode];
    }
}

- (void)setOKButtonTitle:(id)aTitle
{
    [_OKButton setTitle:aTitle];
}

- (void)ensureNibIsLoaded
{
    [self window];
}

- (void)setFlippedHorizontally:(BOOL)aHorizontally
{
    _isFlippedHorizontally = aHorizontally;
}

- (void)setFlippedVertically:(BOOL)aVertically
{
    _isFlippedVertically = aVertically;
}

- (void)setSelectionAlternateProportion:(CGFloat)aProportion
{
    _selectionAlternateProportion = aProportion;
    [[_imageCropView currentTool] setAlternateProportion:_selectionAlternateProportion];
}

- (CGFloat)selectionAlternateProportion
{
    return _selectionAlternateProportion;
}

- (CGFloat)selectionTolerance
{
    return _selectionTolerance;
}

- (void)setSelectionTolerance:(CGFloat)aTolerance
{
    _selectionTolerance = aTolerance;
    if ([_toolMatrix selectedTag] == 0x2) {
        [[_imageCropView currentTool] setTolerance:_selectionTolerance];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002320a6 @ 002320a6, 565 bytes * /

id FUN_002320a6(HSCropImageDialogController *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  uint local_34;
  uint local_30;
  undefined4 local_2c;
  undefined4 local_28;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 uStack_18;
  
  _objc_msgSend_stret(local_24,self,sel_croppedImageFrame);
  cVar1 = _NSIsEmptyRect(local_24._0_4_,local_24._4_4_,local_1c,uStack_18);
  if (cVar1 == '\0') {
    _NSIntegralRect(&local_34,local_24._0_4_,local_24._4_4_,local_1c,uStack_18);
    pvVar2 = _objc_msgSend(self,sel_cgPath);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
      pvVar3 = _objc_msgSend(pvVar3,sel_initWithSize_,local_2c,local_28);
      pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
      _objc_msgSend(pvVar3,sel_lockFocus);
      pvVar4 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
      pvVar4 = _objc_msgSend(pvVar4,sel_graphicsPort);
      _CGContextConcatCTM(pvVar4,0x3f800000,0,0,0x3f800000,local_34 ^ 0x80000000,
                          local_30 ^ 0x80000000);
      _CGContextAddPath(pvVar4,pvVar2);
      _CGContextClip(pvVar4);
      pvVar2 = _objc_msgSend(self->_imageCropView,sel_image);
      _objc_msgSend(pvVar2,sel_drawInCGContext_atPoint_,pvVar4,*(undefined4 *)PTR_0033608c,
                    *(undefined4 *)(PTR_0033608c + 4));
      _objc_msgSend(pvVar3,sel_unlockFocus);
      _objc_msgSend(pvVar3,sel_setSize_,local_1c,uStack_18);
      return pvVar3;
    }
  }
  return (id)0x0;
}

*/
- (id)croppedImage
{
    NSRect frame = [self croppedImageFrame];
    if (NSIsEmptyRect(frame)) {
        return nil;
    }
    NSRect integralFrame = NSIntegralRect(frame);
    CGPathRef path = [self cgPath];
    if (path == NULL) {
        return nil;
    }
    NSImage *image = [[[NSImage alloc] initWithSize:integralFrame.size] autorelease];
    [image lockFocus];
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, 1, -integralFrame.origin.x, -integralFrame.origin.y));
    CGContextAddPath(context, path);
    CGContextClip(context);
    [[_imageCropView image] drawInCGContext:context atPoint:CGPointZero];
    [image unlockFocus];
    [image setSize:frame.size];
    return image;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002322db @ 002322db, 124 bytes * /

BOOL FUN_002322db(HSCropImageDialogController *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined8 local_1c;
  undefined8 local_14;
  
  pvVar2 = _objc_msgSend(self,sel_cgPath);
  if ((pvVar2 != (id)0x0) && (cVar1 = _CGPathIsEmpty(), cVar1 == '\0')) {
    _objc_msgSend_stret(&local_1c,self,sel_croppedImageFrame);
    cVar1 = _NSIsEmptyRect(local_1c,local_14);
    return cVar1 == '\0';
  }
  return '\0';
}

*/
- (BOOL)hasValidCropPath
{
    CGPathRef path = [self cgPath];
    if (path != NULL && !CGPathIsEmpty(path)) {
        return !NSIsEmptyRect([self croppedImageFrame]);
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00232357 @ 00232357, 446 bytes * /

/* WARNING: Restarted to delay deadcode elimination for space: stack * /

NSRect * FUN_00232357(NSRect *__return_storage_ptr__,HSCropImageDialogController *self,SEL _cmd)

{
  undefined8 uVar1;
  char cVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  int *piVar4;
  undefined4 local_90;
  undefined4 local_44;
  undefined4 local_40;
  undefined4 local_3c;
  undefined4 local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  piVar4 = (int *)&stack0xffffff74;
  local_34 = *(float *)PTR_00336078;
  local_30 = *(float *)(PTR_00336078 + 4);
  local_2c = *(float *)(PTR_00336078 + 8);
  local_28 = *(float *)(PTR_00336078 + 0xc);
  local_90 = 0x2323a8;
  pvVar3 = _objc_msgSend(self,sel_cgPath);
  if (pvVar3 != (id)0x0) {
    local_90 = 0x2323ba;
    cVar2 = _CGPathIsEmpty();
    if (cVar2 == '\0') {
      local_90 = 0x2323cd;
      _CGEPathGetPathBoundingBox();
      piVar4 = &local_90;
    }
    else {
      local_44 = *(undefined4 *)PTR_00336090;
      local_40 = *(undefined4 *)(PTR_00336090 + 4);
      local_3c = *(undefined4 *)(PTR_00336090 + 8);
      local_38 = *(undefined4 *)(PTR_00336090 + 0xc);
    }
    pvVar3 = self->_imageCropView;
    piVar4[1] = (int)sel_image;
    *piVar4 = (int)pvVar3;
    piVar4[-1] = 0x232438;
    pvVar3 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
    piVar4[1] = (int)sel_imageSize;
    *piVar4 = (int)pvVar3;
    uVar1 = *(undefined8 *)PTR_00336074;
    piVar4[-1] = 0x232463;
    pvVar3 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
    uStack_18 = local_38;
    local_1c = local_3c;
    local_24 = local_44;
    uStack_20 = local_40;
    *(ulonglong *)(piVar4 + 7) = CONCAT44(extraout_EDX,pvVar3);
    *(undefined8 *)(piVar4 + 5) = uVar1;
    *(ulonglong *)(piVar4 + 3) = CONCAT44(local_38,local_3c);
    *(ulonglong *)(piVar4 + 1) = CONCAT44(local_40,local_44);
    *piVar4 = (int)&local_34;
    piVar4[-1] = 0x2324de;
    _NSIntersectionRect();
  }
  (__return_storage_ptr__->origin).x = local_34;
  (__return_storage_ptr__->origin).y = local_30;
  (__return_storage_ptr__->size).width = local_2c;
  (__return_storage_ptr__->size).height = local_28;
  return __return_storage_ptr__;
}

*/
- (NSRect)croppedImageFrame
{
    NSRect frame = NSZeroRect;
    CGPathRef path = [self cgPath];
    if (path != NULL) {
        CGRect bounds = CGPathIsEmpty(path) ? CGRectZero : CGPathGetPathBoundingBox(path);
        NSRect imageRect;
        imageRect.origin = NSZeroPoint;
        imageRect.size = NSSizeFromCGSize([[_imageCropView image] imageSize]);
        frame = NSIntersectionRect(NSRectFromCGRect(bounds), imageRect);
    }
    return frame;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00232515 @ 00232515, 367 bytes * /

CGPath * FUN_00232515(HSCropImageDialogController *self,SEL _cmd)

{
  uint uVar1;
  uint uVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  CGPath *self_00;
  float extraout_EDX;
  uint local_2c;
  uint local_28;
  uint local_24;
  uint local_20;
  float local_1c;
  float local_18;
  
  puVar3 = PTR_00336088;
  uVar1 = *(uint *)PTR_00336088;
  uVar2 = *(uint *)(PTR_00336088 + 4);
  pvVar4 = _objc_msgSend(self,sel_cgPath);
  local_24 = *(uint *)(puVar3 + 8);
  local_20 = *(uint *)(puVar3 + 0xc);
  local_1c = *(float *)(puVar3 + 0x10);
  local_18 = *(float *)(puVar3 + 0x14);
  local_2c = uVar1;
  local_28 = uVar2;
  if (self->_isFlippedHorizontally != '\0') {
    pvVar5 = _objc_msgSend(self->_imageCropView,sel_image);
    pvVar5 = _objc_msgSend(pvVar5,sel_imageSize);
    local_2c = local_2c ^ 0x80000000;
    local_1c = (float)pvVar5 - local_1c;
    local_24 = local_24 ^ 0x80000000;
  }
  if (self->_isFlippedVertically == '\0') {
    pvVar5 = _objc_msgSend(self->_imageCropView,sel_image);
    _objc_msgSend(pvVar5,sel_imageSize);
    local_28 = local_28 ^ 0x80000000;
    local_18 = extraout_EDX - local_18;
    local_20 = local_20 ^ 0x80000000;
  }
  self_00 = (CGPath *)_CGPathCreateMutable();
  _CGPathAddPath(self_00,&local_2c,pvVar4);
  _objc_msgSend(self_00,sel_autorelease);
  return self_00;
}

*/
- (struct CGPath *)borderPath
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGPathRef path = [self cgPath];

    if (_isFlippedHorizontally) {
        CGSize size = [[_imageCropView image] imageSize];
        transform.a = -transform.a;
        transform.c = -transform.c;
        transform.tx = size.width - transform.tx;
    }
    // The crop view works in flipped coordinates, so the vertical flip is applied when the image is not flipped.
    if (!_isFlippedVertically) {
        CGSize size = [[_imageCropView image] imageSize];
        transform.b = -transform.b;
        transform.d = -transform.d;
        transform.ty = size.height - transform.ty;
    }
    CGMutablePathRef borderPath = CGPathCreateMutable();
    CGPathAddPath(borderPath, &transform, path);
    [(id)borderPath autorelease];
    return borderPath;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00232684 @ 00232684, 280 bytes * /

CGPath * FUN_00232684(HSCropImageDialogController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  CGPath *self_00;
  id pvVar4;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  self_00 = (CGPath *)_CGPathCreateMutable();
  pvVar4 = _objc_msgSend(self->_imageCropView,sel_currentTool);
  puVar3 = PTR_00336088;
  uVar1 = *(undefined4 *)PTR_00336088;
  uVar2 = *(undefined4 *)(PTR_00336088 + 4);
  pvVar4 = _objc_msgSend(pvVar4,sel_valueForKey_,&cfstr_selectionAffineTransform);
  local_24 = *(undefined4 *)(puVar3 + 8);
  local_20 = *(undefined4 *)(puVar3 + 0xc);
  local_1c = *(undefined4 *)(puVar3 + 0x10);
  local_18 = *(undefined4 *)(puVar3 + 0x14);
  local_2c = uVar1;
  local_28 = uVar2;
  _objc_msgSend(pvVar4,sel_getValue_,&local_2c);
  pvVar4 = _objc_msgSend(self->_imageCropView,sel_currentTool);
  pvVar4 = _objc_msgSend(pvVar4,sel_valueForKey_,&cfstr_selectionPath);
  _CGPathAddPath(self_00,&local_2c,pvVar4);
  _objc_msgSend(self_00,sel_autorelease);
  return self_00;
}

*/
- (struct CGPath *)cgPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformIdentity;

    [[[_imageCropView currentTool] valueForKey:@"selectionAffineTransform"] getValue:&transform];
    CGPathAddPath(path, &transform, (CGPathRef)[[_imageCropView currentTool] valueForKey:@"selectionPath"]);
    [(id)path autorelease];
    return path;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00230fc5 @ 00230fc5, 143 bytes * /

void FUN_00230fc5(HSCropImageDialogController *self,SEL _cmd,id setSourceNSImage)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_HSImportDialogGraphicsBTCGImage,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithNSImage_,setSourceNSImage);
  pvVar2 = _objc_msgSend(setSourceNSImage,sel_size);
  _objc_msgSend(self,sel_setSourceImage_size_,pvVar1,pvVar2,extraout_EDX);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)setSourceNSImage:(id)aImage
{
    id image = [[HSImportDialogGraphicsBTCGImage alloc] initWithNSImage:aImage];
    [self setSourceImage:image size:NSSizeToCGSize([(NSImage *)aImage size])];
    [image release];
}

- (void)setSourceCGImage:(struct CGImage *)aImage size:(CGSize)aSize
{
    id pvVar1_2;

    pvVar1_2 = [[BTCGImage alloc] initWithCGImage:aImage];
    [self setSourceImage:pvVar1_2 size:aSize];
    [pvVar1_2 release];
}

- (void)setSourceCGImage:(struct CGImage *)aImage
{
    [self setSourceCGImage:aImage size:NSMakeSize((float)((double)((unsigned long long)(CGImageGetWidth(aImage)) | 0x4330000000000000) - 4503599627370496.0), (float)((double)((unsigned long long)(CGImageGetHeight(aImage)) | 0x4330000000000000) - 4503599627370496.0))];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00232825 @ 00232825, 765 bytes * /

void FUN_00232825(HSCropImageDialogController *self,SEL _cmd,id setSourceImage,CGSize size)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar5;
  double dVar6;
  float local_50;
  double local_4c;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(setSourceImage,sel_imageSize);
  if (((float)pvVar1 != 0.0) || (NAN((float)pvVar1))) {
    fVar5 = size.width / (float)pvVar1;
  }
  else {
    fVar5 = 1.0;
  }
  if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
    local_50 = size.height / extraout_EDX;
  }
  else {
    local_50 = 1.0;
  }
  pvVar1 = _objc_msgSend(cls_HSScaledBTCGImage,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithBTCGImage_imageScaling_);
  _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(self->_imageCropView,sel_setImage_);
  _objc_msgSend_stret(local_24,self->_scrollView,sel_frame,fVar5,local_50);
  pvVar1 = _objc_msgSend(self->_scrollView,sel_class);
  pvVar2 = _objc_msgSend(self->_scrollView,sel_borderType);
  pvVar3 = _objc_msgSend(self->_scrollView,sel_autohidesScrollers);
  pvVar4 = _objc_msgSend(self->_scrollView,sel_autohidesScrollers);
  pvVar1 = _objc_msgSend(pvVar1,
                         sel_contentSizeForFrameSize_hasHorizontalScroller_hasVerticalScroller_borderType_
                         ,local_1c,local_18,(uint)((char)pvVar4 == '\0'),(char)pvVar3 == '\0',pvVar2
                        );
  if (((float)pvVar1 < size.width) || (extraout_EDX_00 < size.height)) {
    dVar6 = _objc_msgSend_fpret(self->_scaleSlider,sel_minValue);
    local_4c = (double)((float)pvVar1 / size.width);
    if ((double)(extraout_EDX_00 / size.height) <= (double)((float)pvVar1 / size.width)) {
      local_4c = (double)(extraout_EDX_00 / size.height);
    }
    if (local_4c <= dVar6) {
      local_4c = _objc_msgSend_fpret(self->_scaleSlider,sel_minValue);
    }
    dVar6 = _objc_msgSend_fpret(self->_scaleSlider,sel_maxValue);
    if (dVar6 <= local_4c) {
      local_4c = _objc_msgSend_fpret(self->_scaleSlider,sel_maxValue);
    }
    _objc_msgSend(self->_scaleSlider,sel_setDoubleValue_,local_4c);
    _objc_msgSend(self,sel_scaleChanged_,self->_scaleSlider);
  }
  return;
}

*/
- (void)setSourceImage:(id)aImage size:(CGSize)aSize
{
    CGSize imageSize = [aImage imageSize];
    CGFloat scaleX = imageSize.width != 0 ? aSize.width / imageSize.width : 1.0;
    CGFloat scaleY = imageSize.height != 0 ? aSize.height / imageSize.height : 1.0;
    id image = [[[HSScaledBTCGImage alloc] initWithBTCGImage:aImage imageScaling:NSMakeSize(scaleX, scaleY)] autorelease];

    [_imageCropView setImage:image];
    NSRect frame = [_scrollView frame];
    NSSize contentSize = [[_scrollView class] contentSizeForFrameSize:frame.size
                                              horizontalScrollerClass:([_scrollView autohidesScrollers] ? Nil : [NSScroller class])
                                                verticalScrollerClass:([_scrollView autohidesScrollers] ? Nil : [NSScroller class])
                                                           borderType:[_scrollView borderType]
                                                          controlSize:NSControlSizeRegular
                                                        scrollerStyle:[NSScroller preferredScrollerStyle]];
    if (contentSize.width < aSize.width || contentSize.height < aSize.height) {
        double scale = contentSize.width / aSize.width;
        if (contentSize.height / aSize.height <= scale) {
            scale = contentSize.height / aSize.height;
        }
        if (scale <= [_scaleSlider minValue]) {
            scale = [_scaleSlider minValue];
        }
        if ([_scaleSlider maxValue] <= scale) {
            scale = [_scaleSlider maxValue];
        }
        [_scaleSlider setDoubleValue:scale];
        [self scaleChanged:_scaleSlider];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00230ef1 @ 00230ef1, 75 bytes * /

void FUN_00230ef1(HSCropImageDialogController *self,SEL _cmd,id setSourceImage)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(setSourceImage,sel_imageSize);
  _objc_msgSend(self,sel_setSourceImage_size_,setSourceImage,pvVar1,extraout_EDX);
  return;
}

*/
- (void)setSourceImage:(id)aImage
{
    [self setSourceImage:aImage size:[aImage imageSize]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00232b22 @ 00232b22, 528 bytes * /

void FUN_00232b22(HSCropImageDialogController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  double dVar4;
  
  pvVar1 = _objc_msgSend(self->_scrollView,sel_contentView);
  _objc_msgSend(pvVar1,sel_setPostsFrameChangedNotifications_,1);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(self->_scrollView,sel_contentView);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_clipViewFrameChanged_,
                *(undefined4 *)PTR_003361e0,pvVar2);
  pvVar1 = _objc_msgSend(self->_scrollView,sel_contentView);
  _objc_msgSend(pvVar1,sel_setPostsBoundsChangedNotifications_,1);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(self->_scrollView,sel_contentView);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_clipViewBoundsChanged_,
                *(undefined4 *)PTR_00336574,pvVar2);
  _objc_msgSend(self,sel_toolChanged_,self->_toolMatrix);
  _objc_msgSend(self->_toolMatrix,sel_setDoubleAction_,sel_selectAllArea_);
  pvVar1 = self->_scaleSlider;
  dVar4 = _objc_msgSend_fpret(self->_imageCropView,sel_scaleFactor);
  lVar3 = (longdouble)_HSLinearValueForSliderFromNonLinear(self->_scaleSlider,(float)dVar4);
  _objc_msgSend(pvVar1,sel_setFloatValue_,(float)lVar3);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setAcceptsMouseMovedEvents_,1);
  _objc_msgSend(self,sel_validateToleranceSlider);
  return;
}

*/
- (void)awakeFromNib
{
    [[_scrollView contentView] setPostsFrameChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipViewFrameChanged:) name:NSViewFrameDidChangeNotification object:[_scrollView contentView]];
    [[_scrollView contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipViewBoundsChanged:) name:NSViewBoundsDidChangeNotification object:[_scrollView contentView]];
    [self toolChanged:_toolMatrix];
    [_toolMatrix setDoubleAction:@selector(selectAllArea:)];
    [_scaleSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_scaleSlider, (float)[_imageCropView scaleFactor])];
    [[self window] setAcceptsMouseMovedEvents:YES];
    [self validateToleranceSlider];
}

- (void)validateToleranceSlider
{
    NSInteger pvVar1;
    id self_00;

    pvVar1 = [_toolMatrix selectedTag];
    if (pvVar1 != 0x2) {
        self_00 = _sensitivityView;
    }
    else {
        [_toleranceSlider setFloatValue:1.0 - _selectionTolerance];
        self_00 = _sensitivityView;
    }
    [self_00 setHidden:(unsigned int)(pvVar1 != 0x2)];
}

- (id)windowNibName
{
    return @"CropImageDialog";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:[_scrollView contentView]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:[_scrollView contentView]];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00231be3 @ 00231be3, 104 bytes * /

id FUN_00231be3(HSCropImageDialogController *self,SEL _cmd)

{
  id self_00;
  HSCropImageDialogController *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSWindowController_003553a0;
  self_00 = _objc_msgSendSuper(&local_14,sel_init);
  if (self_00 != (id)0x0) {
    *(undefined4 *)((int)self_00 + 0x44) = 0xffffffff;
    *(undefined4 *)((int)self_00 + 0x4c) = 0x3f800000;
    *(undefined4 *)((int)self_00 + 0x48) = 0x3e051eb8;
    _objc_msgSend(self_00,sel_ensureNibIsLoaded);
  }
  return self_00;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _selectedToolTag = -1;
        _selectionAlternateProportion = 1.0f;
        _selectionTolerance = 0.13f;
        [self ensureNibIsLoaded];
    }
    return self;
}

@end

@implementation HSScaledBTCGImage

/* i386 ivar offsets: _image=0x4, _imageScaling=0x8 */

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    return nil;
}

- (struct CGImage *)coreGraphicsImage
{
    return nil;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return nil;
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00230dea @ 00230dea, 118 bytes * /

void FUN_00230dea(HSScaledBTCGImage *self,SEL _cmd,CGContext *drawInCGContext,CGPoint atPoint)

{
  id self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  
  self_00 = self->_image;
  pvVar1 = _objc_msgSend(self,sel_imageSize);
  _objc_msgSend(self_00,sel_drawInCGContext_inRect_,drawInCGContext,atPoint,
                CONCAT44(extraout_EDX,pvVar1));
  return;
}

*/
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGSize size = [self imageSize];
    [_image drawInCGContext:aContext inRect:CGRectMake(aPoint.x, aPoint.y, size.width, size.height)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00230da2 @ 00230da2, 72 bytes * /

void FUN_00230da2(HSScaledBTCGImage *self,SEL _cmd,CGContext *drawInCGContext,CGRect inRect)

{
  _objc_msgSend(self->_image,sel_drawInCGContext_inRect_,drawInCGContext,inRect.origin,inRect.size);
  return;
}

*/
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    [_image drawInCGContext:aContext inRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00230d5d @ 00230d5d, 69 bytes * /

ulonglong FUN_00230d5d(HSScaledBTCGImage *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self->_image,sel_imageSize);
  return CONCAT44(extraout_EDX * (self->_imageScaling).height,
                  (float)pvVar1 * (self->_imageScaling).width);
}

*/
- (CGSize)imageSize
{
    CGSize size = [_image imageSize];
    return CGSizeMake(size.width * _imageScaling.width, size.height * _imageScaling.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00231b76 @ 00231b76, 109 bytes * /

id FUN_00231b76(HSScaledBTCGImage *self,SEL _cmd,id initWithBTCGImage,NSSize imageScaling)

{
  id pvVar1;
  id pvVar2;
  HSScaledBTCGImage *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_00355370;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithBTCGImage,sel_retain);
    *(id *)((int)pvVar1 + 4) = pvVar2;
    *(float *)((int)pvVar1 + 8) = imageScaling.width;
    *(float *)((int)pvVar1 + 0xc) = imageScaling.height;
  }
  return pvVar1;
}

*/
- (id)initWithBTCGImage:(id)aImage imageScaling:(NSSize)aScaling
{
    self = [super init];
    if (self != nil) {
        _image = [aImage retain];
        _imageScaling = aScaling;
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end

