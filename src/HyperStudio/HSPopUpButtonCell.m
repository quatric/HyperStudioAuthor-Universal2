#import "HSPopUpButtonCell.h"

@implementation HSPopUpButtonCell

/* i386 ivar offsets: _backgroundImage=0x80, _pushedBackgroundImage=0x84, _backgroundRenderer=0x88, _isMenuAttached=0x8c, _drawsText=0x8d, _textFieldCell=0x90 */

- (NSUInteger)displayedImagePosition
{
    return (unsigned int)[self imagePosition];
}

- (BOOL)isEnabled
{
    return (BOOL)[super isEnabled];
}

- (BOOL)isSelected
{
    return _isMenuAttached;
}

- (BOOL)isRightCap
{
    return YES;
}

- (BOOL)isLeftCap
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00169a7c @ 00169a7c, 237 bytes * /

NSRect * FUN_00169a7c(NSRect *__return_storage_ptr__,HSPopUpButtonCell *self,SEL _cmd,
                     NSRect titleRectForCellFrame)

{
  id pvVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_backgroundRenderer);
  _objc_msgSend_stret(&local_1c,pvVar1,sel_contentInsetForObject_,self);
  pvVar1 = _objc_msgSend(self,sel_controlView);
  pvVar1 = _objc_msgSend(pvVar1,sel_isFlipped);
  fVar2 = local_10;
  if ((char)pvVar1 == '\0') {
    fVar2 = local_18;
    local_18 = local_10;
  }
  (__return_storage_ptr__->origin).x = local_1c + titleRectForCellFrame.origin.x;
  (__return_storage_ptr__->origin).y = titleRectForCellFrame.origin.y + local_18;
  fVar3 = titleRectForCellFrame.size.width - (local_14 + local_1c);
  fVar4 = 0.0;
  if (0.0 <= fVar3) {
    fVar4 = fVar3;
  }
  (__return_storage_ptr__->size).width = fVar4;
  fVar4 = titleRectForCellFrame.size.height - (fVar2 + local_18);
  fVar2 = 0.0;
  if (0.0 <= fVar4) {
    fVar2 = fVar4;
  }
  (__return_storage_ptr__->size).height = fVar2;
  return &titleRectForCellFrame;
}

*/
- (NSRect)titleRectForCellFrame:(NSRect)aFrame
{
    id renderer = [self backgroundRenderer];
    struct _SMKInset inset = [renderer contentInsetForObject:self];
    float yOffset = inset.top;
    float otherOffset = inset.bottom;
    if (![[self controlView] isFlipped]) {
        yOffset = inset.bottom;
        otherOffset = inset.top;
    }
    NSRect rect;
    rect.origin.x = inset.left + aFrame.origin.x;
    rect.origin.y = aFrame.origin.y + yOffset;
    rect.size.width = MAX(0.0f, (float)(aFrame.size.width - (inset.right + inset.left)));
    rect.size.height = MAX(0.0f, (float)(aFrame.size.height - (otherOffset + yOffset)));
    return rect;
    return (NSRect){0};
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00169b69 @ 00169b69, 524 bytes * /

id FUN_00169b69(HSPopUpButtonCell *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined8 uVar3;
  id pvVar4;
  id pvVar5;
  double dVar6;
  HSPopUpButtonCell *pHVar7;
  undefined1 local_34 [8];
  undefined4 local_2c;
  undefined4 local_28;
  undefined1 local_24 [8];
  undefined4 local_1c;
  
  pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar5 = _objc_msgSend(self,sel_controlView);
  _objc_msgSend_stret(local_34,pvVar5,sel_bounds);
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  uVar3 = *(undefined8 *)PTR_00336078;
  pvVar4 = _objc_msgSend(pvVar4,sel_initWithSize_,local_2c,local_28);
  pvVar5 = _objc_msgSend(self,sel_controlView);
  _objc_msgSend_stret(local_24,pvVar5,sel_bounds);
  pvVar5 = _objc_msgSend(self,sel_backgroundRenderer);
  pHVar7 = self;
  dVar6 = _objc_msgSend_fpret(pvVar5,sel_segmentHeightForObject_,self);
  pvVar5 = _objc_msgSend(self,sel_controlView);
  pvVar5 = _objc_msgSend(pvVar5,sel_isFlipped);
  if ((char)pvVar5 != '\0') {
    pHVar7 = (HSPopUpButtonCell *)0x1;
    _objc_msgSend(pvVar4,sel_setFlipped_,1);
  }
  _objc_msgSend(pvVar4,sel_lockFocus,pHVar7);
  _NSRectFillUsingOperation(uVar3,local_1c,(float)dVar6,0);
  pvVar5 = _objc_msgSend(self,sel_backgroundRenderer);
  _objc_msgSend(pvVar5,sel_drawBackgroundImageForObject_bounds_style_,self,uVar1,uVar2,
                CONCAT44((float)dVar6,local_1c),0);
  _objc_msgSend(pvVar4,sel_unlockFocus);
  return pvVar4;
}

*/
- (id)newBackgroundImage
{
    NSImage *image = [NSImage alloc];
    image = [image initWithSize:[[self controlView] bounds].size];
    float width = [[self controlView] bounds].size.width;
    id renderer = [self backgroundRenderer];
    float height = [renderer segmentHeightForObject:self];
    if ([[self controlView] isFlipped]) {
        [image setFlipped:YES];
    }
    [image lockFocus];
    NSRectFillUsingOperation(NSMakeRect(0.0, 0.0, width, height), NSCompositingOperationClear);
    [renderer drawBackgroundImageForObject:self bounds:NSMakeRect(0.0, 0.0, width, height) style:0];
    [image unlockFocus];
    return image;
    return 0;
}

- (id)pushedBackgroundImage
{
    id pvVar1;

    pvVar1 = _pushedBackgroundImage;
    if (pvVar1 == nil) {
        pvVar1 = [self newBackgroundImage];
        _pushedBackgroundImage = pvVar1;
    }
    return pvVar1;
}

- (id)backgroundImage
{
    id pvVar1;

    pvVar1 = _backgroundImage;
    if (pvVar1 == nil) {
        pvVar1 = [self newBackgroundImage];
        _backgroundImage = pvVar1;
    }
    return pvVar1;
}

- (id)textFieldCell
{
    id pvVar1_4;
    BOOL pvVar2_5;
    NSColor *pvVar2_6;

    if ([self selectedItem] != nil) {
        if ([_textFieldCell title] != [[self selectedItem] title]) {
            [_textFieldCell setTitle:[[self selectedItem] title]];
        }
    }
    pvVar2_5 = [self isEnabled];
    pvVar1_4 = _textFieldCell;
    if (!pvVar2_5) {
        pvVar2_6 = [NSColor disabledControlTextColor];
    }
    else {
        pvVar2_6 = [NSColor controlTextColor];
    }
    [pvVar1_4 setTextColor:pvVar2_6];
    return _textFieldCell;
}

- (void)loadDefaultImages
{

}

- (void)setupTextFieldCell
{
    double dVar3;
    id pvVar1_2;
    id pvVar1_4;
    PDFKitPlatformFont *pvVar2_2;

    pvVar1_2 = [[NSTextFieldCell alloc] initTextCell:@""];
    _textFieldCell = pvVar1_2;
    [pvVar1_2 setScrollable:NO];
    [_textFieldCell setSelectable:NO];
    [_textFieldCell setEnabled:YES];
    [_textFieldCell setWraps:YES];
    [_textFieldCell setLineBreakMode:4];
    [_textFieldCell setAlignment:0];
    [_textFieldCell setControlView:[self controlView]];
    [_textFieldCell setEditable:NO];
    pvVar2_2 = [_textFieldCell font];
    pvVar1_4 = _textFieldCell;
    dVar3 = [NSFont smallSystemFontSize];
    [pvVar1_4 setFont:[NSFont fontWithName:[pvVar2_2 fontName] size:(float)dVar3]];
}

- (void)applyDefaultSettings
{
    [super setBezelStyle:6];
    [super setBordered:NO];
    [super setBezeled:NO];
    [self setImage:0];
    [self loadDefaultImages];
    [self setupTextFieldCell];
    [self setDrawsText:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016a1d6 @ 0016a1d6, 672 bytes * /

void FUN_0016a1d6(HSPopUpButtonCell *self,SEL _cmd,NSRect drawInteriorWithFrame,id inView)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float fVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  undefined8 uVar13;
  undefined4 uVar14;
  undefined4 uVar15;
  HSPopUpButtonCell *local_3c;
  undefined *local_38;
  undefined4 local_34;
  undefined4 uStack_30;
  id local_2c;
  undefined4 uStack_28;
  undefined1 local_24 [20];
  
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(cls_HSPopUpButtonCell,sel_class);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar2);
  fVar9 = drawInteriorWithFrame.size.height;
  fVar5 = drawInteriorWithFrame.origin.y;
  fVar3 = drawInteriorWithFrame.origin.x;
  fVar7 = drawInteriorWithFrame.size.width;
  if ((char)pvVar1 == '\0') {
    local_3c = self;
    local_38 = PTR_s_NSPopUpButtonCell_003520d0;
    _objc_msgSendSuper(&local_3c,sel_drawInteriorWithFrame_inView_,fVar3,fVar5,fVar7,fVar9,inView);
  }
  else {
    local_34 = *(undefined4 *)PTR_00336078;
    uStack_30 = *(undefined4 *)(PTR_00336078 + 4);
    local_2c = *(id *)(PTR_00336078 + 8);
    uStack_28 = *(undefined4 *)(PTR_00336078 + 0xc);
    pvVar1 = _objc_msgSend(self,sel_showsFirstResponder,pvVar2);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState,pvVar2);
      pvVar2 = (id)0x0;
      _objc_msgSend(self,sel_setFocusRingType_,0);
      _NSSetFocusRingStyle(1);
    }
    if (self->_isMenuAttached == '\0') {
      pvVar2 = _objc_msgSend(self,sel_backgroundImage,pvVar2);
      local_2c = _objc_msgSend(pvVar2,sel_size);
      op = sel_backgroundImage;
      uStack_28 = extraout_EDX;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_pushedBackgroundImage,pvVar2);
      local_2c = _objc_msgSend(pvVar2,sel_size);
      op = sel_pushedBackgroundImage;
      uStack_28 = extraout_EDX_00;
    }
    pvVar2 = _objc_msgSend(self,op);
    uVar13 = CONCAT44(uStack_28,local_2c);
    uVar15 = 0x3f800000;
    uVar14 = 2;
    fVar4 = fVar3;
    fVar6 = fVar5;
    fVar8 = fVar7;
    fVar10 = fVar9;
    uVar11 = local_34;
    uVar12 = uStack_30;
    _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_,fVar3,fVar5,fVar7,fVar9,
                  local_34,uStack_30,uVar13,2,0x3f800000);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState,fVar4,fVar6,fVar8,fVar10,uVar11,
                    uVar12,uVar13,uVar14,uVar15);
    }
    pvVar1 = _objc_msgSend(self,sel_drawsText,fVar4,fVar6,fVar8,fVar10,uVar11,uVar12,uVar13,uVar14,
                           uVar15);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_textFieldCell,fVar4,fVar6,fVar8,fVar10,uVar11,uVar12,uVar13,
                             uVar14,uVar15);
      _objc_msgSend_stret(local_24,self,sel_titleRectForCellFrame_,fVar3,fVar5,fVar7,fVar9);
      _objc_msgSend(pvVar1,sel_drawInteriorWithFrame_inView_,(int)local_24._0_8_,
                    SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4),inView);
    }
  }
  return;
}

*/
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    if (![[self class] isEqual:[HSPopUpButtonCell class]]) {
        [super drawInteriorWithFrame:aFrame inView:aView];
        return;
    }
    NSRect from = NSZeroRect;
    BOOL ring = [self showsFirstResponder];
    if (ring) {
        [NSGraphicsContext saveGraphicsState];
        [self setFocusRingType:NSFocusRingTypeDefault];
        NSSetFocusRingStyle(NSFocusRingAbove);
    }
    if (!_isMenuAttached) {
        from.size = [[self backgroundImage] size];
        [[self backgroundImage] drawInRect:aFrame fromRect:from operation:NSCompositingOperationSourceOver fraction:1.0];
    } else {
        from.size = [[self pushedBackgroundImage] size];
        [[self pushedBackgroundImage] drawInRect:aFrame fromRect:from operation:NSCompositingOperationSourceOver fraction:1.0];
    }
    if (ring) {
        [NSGraphicsContext restoreGraphicsState];
    }
    if ([self drawsText]) {
        [[self textFieldCell] drawInteriorWithFrame:[self titleRectForCellFrame:aFrame] inView:aView];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016a476 @ 0016a476, 67 bytes * /

void FUN_0016a476(HSPopUpButtonCell *self,SEL _cmd,NSRect drawWithFrame,id inView)

{
  _objc_msgSend(self,sel_drawInteriorWithFrame_inView_,drawWithFrame.origin,drawWithFrame.size,
                inView);
  return;
}

*/
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    [self drawInteriorWithFrame:aFrame inView:aView];
}

- (void)setTitle:(id)aTitle
{
    [super setTitle:aTitle];
    if ([_textFieldCell title] != aTitle) {
        [_textFieldCell setTitle:aTitle];
    }
}

- (void)setAlignment:(NSUInteger)aAlignment
{
    [super setAlignment:aAlignment];
    [_textFieldCell setAlignment:aAlignment];
}

- (void)setFormatter:(id)aFormatter
{
    [super setFormatter:aFormatter];
    [_textFieldCell setFormatter:aFormatter];
}

- (void)dismissPopUp
{
    _isMenuAttached = NO;
    [super dismissPopUp];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001699c5 @ 001699c5, 89 bytes * /

void FUN_001699c5(HSPopUpButtonCell *self,SEL _cmd,NSRect attachPopUpWithFrame,id inView)

{
  HSPopUpButtonCell *local_c;
  undefined *local_8;
  
  self->_isMenuAttached = '\x01';
  local_c = self;
  local_8 = PTR_s_NSPopUpButtonCell_003520d0;
  _objc_msgSendSuper(&local_c,sel_attachPopUpWithFrame_inView_,attachPopUpWithFrame.origin,
                     attachPopUpWithFrame.size,inView);
  return;
}

*/
- (void)attachPopUpWithFrame:(NSRect)aFrame inView:(id)aView
{
    _isMenuAttached = YES;
    [super attachPopUpWithFrame:aFrame inView:aView];
}

- (id)textRenderCell
{
    return [self textFieldCell];
}

- (void)setDrawsText:(BOOL)aText
{
    _drawsText = aText;
}

- (BOOL)drawsText
{
    return _drawsText;
}

- (void)setBackgroundRenderer:(id)aRenderer
{
    if (_backgroundRenderer != aRenderer) {
        [_backgroundRenderer release];
        _backgroundRenderer = [aRenderer retain];
    }
}

- (id)backgroundRenderer
{
    return _backgroundRenderer;
}

- (void)dealloc
{
    [_backgroundImage release];
    [_pushedBackgroundImage release];
    [_backgroundRenderer release];
    [_textFieldCell release];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        [self applyDefaultSettings];
    }
    return self;
}

@end

