#import "HSTokenCell.h"

@implementation HSTokenCell

/* i386 ivar offsets: _textFieldCell=0x14, _popUpButtonCell=0x18, _menuTriangleColor=0x1c, _borderColor=0x20, _highlightedBorderColor=0x24, _backgroundColor=0x28, _highlightedBackgroundColor=0x2c, _canChangeHighlight=0x30, _autosize=0x31, _textAttachment=0x34, _isDragging=0x38, _selectedMenuItemIndex=0x3c, _cellSize=0x40, _target=0x48, _action=0x4c */

+ (id)defaultHighlightedBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.733 green:0.808 blue:0.945 alpha:1.0];
}

+ (id)defaultBackgroundColor
{
    return [NSColor colorWithCalibratedRed:0.871 green:0.901 blue:0.973 alpha:1.0];
}

+ (id)defaultHighlightedBorderColor
{
    return [NSColor colorWithCalibratedRed:0.424 green:0.588 blue:0.886 alpha:1.0];
}

+ (id)defaultBorderColor
{
    return [NSColor colorWithCalibratedRed:0.655 green:0.741 blue:0.933 alpha:1.0];
}

+ (id)defaultMenuTriangleColor
{
    return [NSColor whiteColor];
}

- (void)popUpDidEnd:(id)aEnd
{
    id pvVar1_5;

    [self setTitle:[[[self popUpButtonCell] selectedItem] title]];
    _selectedMenuItemIndex = (int)[[self popUpButtonCell] indexOfSelectedItem];
    pvVar1_5 = _target;
    if ((pvVar1_5 != nil) && (_action != (SEL)0x0)) {
        [pvVar1_5 performSelector:_action withObject:[self controlView]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020843d @ 0020843d, 85 bytes * /

NSRect * FUN_0020843d(NSRect *__return_storage_ptr__,HSTokenCell *self,SEL _cmd,
                     id cellFrameForTextContainer,NSRect proposedLineFragment,NSPoint glyphPosition,
                     uint characterIndex)

{
  id pvVar1;
  NSRect *pNVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(self,sel_cellBaselineOffset);
  pNVar2 = _objc_msgSend(self,sel_cellSize);
  (__return_storage_ptr__->origin).x = (float)pvVar1;
  (__return_storage_ptr__->origin).y = extraout_EDX;
  (__return_storage_ptr__->size).width = (float)pNVar2;
  (__return_storage_ptr__->size).height = extraout_EDX_00;
  return pNVar2;
}

*/
- (NSRect)cellFrameForTextContainer:(id)aContainer proposedLineFragment:(NSRect)aFragment glyphPosition:(NSPoint)aPosition characterIndex:(NSUInteger)aIndex
{
    NSPoint offset = [self cellBaselineOffset];
    NSSize size = [self cellSize];
    return NSMakeRect(offset.x, offset.y, size.width, size.height);
}

- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView atCharacterIndex:(NSUInteger)aIndex untilMouseUp:(BOOL)aUp
{
    return NO;
}

- (BOOL)wantsToTrackMouseForEvent:(id)aEvent inRect:(NSRect)aRect ofView:(id)aView atCharacterIndex:(NSUInteger)aIndex
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00208492 @ 00208492, 74 bytes * /

void FUN_00208492(HSTokenCell *self,SEL _cmd,NSRect drawWithFrame,id inView,uint characterIndex,
                 id layoutManager)

{
  _objc_msgSend(self,sel_drawWithFrame_inView_characterIndex_,drawWithFrame.origin,
                drawWithFrame.size,inView,characterIndex);
  return;
}

*/
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView characterIndex:(NSUInteger)aIndex layoutManager:(id)aManager
{
    [self drawWithFrame:aFrame inView:aView characterIndex:aIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002084dc @ 002084dc, 67 bytes * /

void FUN_002084dc(HSTokenCell *self,SEL _cmd,NSRect drawWithFrame,id inView,uint characterIndex)

{
  _objc_msgSend(self,sel_drawWithFrame_inView_,drawWithFrame.origin,drawWithFrame.size,inView);
  return;
}

*/
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView characterIndex:(NSUInteger)aIndex
{
    [self drawWithFrame:aFrame inView:aView];
}

- (id)attachment
{
    return _textAttachment;
}

- (void)setAttachment:(id)aAttachment
{
    if (_textAttachment != aAttachment) {
        [_textAttachment release];
        _textAttachment = [aAttachment retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002081bd @ 002081bd, 12 bytes * /

ulonglong FUN_002081bd(HSTokenCell *self,SEL _cmd)

{
  return 0xc080000000000000;
}

*/
- (NSPoint)cellBaselineOffset
{
    return NSMakePoint(0.0, -4.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020856a @ 0020856a, 281 bytes * /

ulonglong FUN_0020856a(HSTokenCell *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  float local_14;
  float local_10;
  
  local_10 = (self->_cellSize).width;
  local_14 = (self->_cellSize).height;
  cVar1 = _NSEqualSizes(local_10,local_14,*(undefined4 *)PTR_0033607c,
                        *(undefined4 *)(PTR_0033607c + 4));
  if (cVar1 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_title);
    if ((pvVar2 == (id)0x0) || (self->_autosize == '\0')) {
      local_14 = 16.0;
      local_10 = 100.0;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_textFieldCell);
      pvVar2 = _objc_msgSend(pvVar2,sel_attributedStringValue);
      pvVar2 = _objc_msgSend(pvVar2,sel_size);
      local_10 = (float)pvVar2 + 20.0 + 5.3333335 + 9.0;
      (self->_cellSize).width = local_10;
      (self->_cellSize).height = 16.0;
      local_14 = 16.0;
    }
  }
  return CONCAT44(local_14,local_10);
}

*/
- (NSSize)cellSize
{
    NSSize size = _cellSize;
    if (NSEqualSizes(size, NSZeroSize)) {
        if ([self title] == nil || !_autosize) {
            size = NSMakeSize(100.0, 16.0);
        }
        else {
            float textWidth = (float)[[[self textFieldCell] attributedStringValue] size].width;
            size.width = textWidth + 20.0 + 5.3333335 + 9.0;
            size.height = 16.0;
            _cellSize = size;
        }
    }
    return size;
}

- (void)setCellSize:(NSSize)aSize
{
    (_cellSize).width = aSize.width;
    (_cellSize).height = aSize.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00208683 @ 00208683, 76 bytes * /

BOOL FUN_00208683(HSTokenCell *self,SEL _cmd,id trackMouse,NSRect inRect,id ofView,BOOL untilMouseUp
                 )

{
  _objc_msgSend(self,sel_activateMenuForEvent_cellFrame_controlView_,trackMouse,inRect.origin,
                inRect.size,ofView);
  return '\0';
}

*/
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    [self activateMenuForEvent:aMouse cellFrame:aRect controlView:aView];
    return NO;
}

- (BOOL)wantsToTrackMouse
{
    return NO;
}

- (void)invalidateSize
{
    float fVar1;

    if (_autosize != NO) {
        fVar1 = NSZeroSize.height;
        (_cellSize).width = NSZeroSize.width;
        (_cellSize).height = fVar1;
        [[self controlView] setNeedsDisplay:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00208130 @ 00208130, 106 bytes * /

NSRect * FUN_00208130(NSRect *__return_storage_ptr__,HSTokenCell *self,SEL _cmd,
                     NSRect menuTriangleRectForRect)

{
  (__return_storage_ptr__->origin).x =
       (menuTriangleRectForRect.size.height / -3.0) * 2.0 +
       menuTriangleRectForRect.origin.x + menuTriangleRectForRect.size.width + -8.0;
  (__return_storage_ptr__->origin).y =
       menuTriangleRectForRect.size.height * 0.5 + menuTriangleRectForRect.origin.y + -3.5;
  (__return_storage_ptr__->size).width = 8.0;
  (__return_storage_ptr__->size).height = 7.0;
  return (NSRect *)0x208138;
}

*/
- (NSRect)menuTriangleRectForRect:(NSRect)aRect
{
    float x = (aRect.size.height / -3.0) * 2.0 + aRect.origin.x + aRect.size.width + -8.0;
    float y = aRect.size.height * 0.5 + aRect.origin.y + -3.5;
    return NSMakeRect(x, y, 8.0, 7.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00208730 @ 00208730, 466 bytes * /

void FUN_00208730(HSTokenCell *self,SEL _cmd,NSRect drawMenuTriangleInRect,BOOL flipped)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_menuTriangleColor);
  _objc_msgSend(pvVar1,sel_set);
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_new);
  if (flipped == '\0') {
    _objc_msgSend(pvVar1,sel_moveToPoint_,drawMenuTriangleInRect.origin.x,
                  drawMenuTriangleInRect.size.height + drawMenuTriangleInRect.origin.y);
    _objc_msgSend(pvVar1,sel_lineToPoint_,
                  drawMenuTriangleInRect.origin.x + drawMenuTriangleInRect.size.width,
                  drawMenuTriangleInRect.size.height + drawMenuTriangleInRect.origin.y);
  }
  else {
    _objc_msgSend(pvVar1,sel_moveToPoint_,drawMenuTriangleInRect.origin.x,
                  drawMenuTriangleInRect.origin.y);
    _objc_msgSend(pvVar1,sel_lineToPoint_,
                  drawMenuTriangleInRect.origin.x + drawMenuTriangleInRect.size.width,
                  drawMenuTriangleInRect.origin.y);
    drawMenuTriangleInRect.origin.y =
         drawMenuTriangleInRect.origin.y + drawMenuTriangleInRect.size.height;
  }
  _objc_msgSend(pvVar1,sel_lineToPoint_,
                drawMenuTriangleInRect.size.width * 0.5 + drawMenuTriangleInRect.origin.x,
                drawMenuTriangleInRect.origin.y);
  _objc_msgSend(pvVar1,sel_fill);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)drawMenuTriangleInRect:(NSRect)aRect flipped:(BOOL)aFlipped
{
    [[self menuTriangleColor] set];
    NSBezierPath *path = [NSBezierPath new];
    if (!aFlipped) {
        [path moveToPoint:NSMakePoint(aRect.origin.x, aRect.size.height + aRect.origin.y)];
        [path lineToPoint:NSMakePoint(aRect.origin.x + aRect.size.width, aRect.size.height + aRect.origin.y)];
    }
    else {
        [path moveToPoint:NSMakePoint(aRect.origin.x, aRect.origin.y)];
        [path lineToPoint:NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y)];
        aRect.origin.y = aRect.origin.y + aRect.size.height;
    }
    [path lineToPoint:NSMakePoint(aRect.size.width * 0.5 + aRect.origin.x, aRect.origin.y)];
    [path fill];
    [path release];
}

- (id)copy
{
    return [[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]] retain];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (id)initWithCoder:(id)aCoder
{
    int pvVar1_7;

    self = [super initWithCoder:aCoder];
    _textFieldCell = [[aCoder decodeObjectForKey:@"textFieldCell"] retain];
    _textAttachment = [[aCoder decodeObjectForKey:@"textAttachment"] retain];
    [self popUpButtonCell];
    [self setMenu:[aCoder decodeObjectForKey:@"menu"]];
    _canChangeHighlight = [aCoder decodeBoolForKey:@"canChangeHighlight"];
    pvVar1_7 = [aCoder decodeIntForKey:@"selectedMenuItemIndex"];
    _selectedMenuItemIndex = pvVar1_7;
    if (-1 < (int)pvVar1_7) {
        [self setSelectedMenuItem:[[self menu] itemAtIndex:_selectedMenuItemIndex]];
    }
    [self setHighlighted:NO];
    _autosize = [aCoder decodeBoolForKey:@"autosize"];
    [self setTitle:[aCoder decodeObjectForKey:@"title"]];
    [self setMenuTriangleColor:[aCoder decodeObjectForKey:@"menuTriangleColor"]];
    [self setBorderColor:[aCoder decodeObjectForKey:@"borderColor"]];
    [self setHighlightedBackgroundColor:[aCoder decodeObjectForKey:@"highlightedBorderColor"]];
    [self setBackgroundColor:[aCoder decodeObjectForKey:@"backgroundColor"]];
    [self setHighlightedBackgroundColor:[aCoder decodeObjectForKey:@"highlightedBackgroundColor"]];
    return self;
}
#pragma clang diagnostic pop

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_textFieldCell forKey:@"textFieldCell"];
    [aCoder encodeObject:_textAttachment forKey:@"textAttachment"];
    [aCoder encodeObject:[self menu] forKey:@"menu"];
    [aCoder encodeBool:_canChangeHighlight forKey:@"canChangeHighlight"];
    [aCoder encodeInt:_selectedMenuItemIndex forKey:@"selectedMenuItemIndex"];
    [aCoder encodeBool:_autosize forKey:@"autosize"];
    [aCoder encodeObject:[self title] forKey:@"title"];
    [aCoder encodeObject:[self menuTriangleColor] forKey:@"menuTriangleColor"];
    [aCoder encodeObject:[self borderColor] forKey:@"borderColor"];
    [aCoder encodeObject:[self highlightedBorderColor] forKey:@"highlightedBorderColor"];
    [aCoder encodeObject:[self backgroundColor] forKey:@"backgroundColor"];
    [aCoder encodeObject:[self highlightedBackgroundColor] forKey:@"highlightedBackgroundColor"];
}

- (void)setHighlightedBackgroundColor:(id)aColor
{
    if (_highlightedBackgroundColor != aColor) {
        [_highlightedBackgroundColor release];
        _highlightedBackgroundColor = [aColor retain];
    }
}

- (id)highlightedBackgroundColor
{
    id pvVar1;

    pvVar1 = _highlightedBackgroundColor;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultHighlightedBackgroundColor] retain];
        _highlightedBackgroundColor = pvVar1;
    }
    return pvVar1;
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [_backgroundColor release];
        _backgroundColor = [aColor retain];
    }
}

- (id)backgroundColor
{
    id pvVar1;

    pvVar1 = _backgroundColor;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultBackgroundColor] retain];
        _backgroundColor = pvVar1;
    }
    return pvVar1;
}

- (void)setHighlightedBorderColor:(id)aColor
{
    if (_highlightedBorderColor != aColor) {
        [_highlightedBorderColor release];
        _highlightedBorderColor = [aColor retain];
    }
}

- (id)highlightedBorderColor
{
    id pvVar1;

    pvVar1 = _highlightedBorderColor;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultHighlightedBorderColor] retain];
        _highlightedBorderColor = pvVar1;
    }
    return pvVar1;
}

- (void)setBorderColor:(id)aColor
{
    if (_borderColor != aColor) {
        [_borderColor release];
        _borderColor = [aColor retain];
    }
}

- (id)borderColor
{
    id pvVar1;

    pvVar1 = _borderColor;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultBorderColor] retain];
        _borderColor = pvVar1;
    }
    return pvVar1;
}

- (void)setMenuTriangleColor:(id)aColor
{
    if (_menuTriangleColor != aColor) {
        [_menuTriangleColor release];
        _menuTriangleColor = [aColor retain];
    }
}

- (id)menuTriangleColor
{
    id pvVar1;

    pvVar1 = _menuTriangleColor;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultMenuTriangleColor] retain];
        _menuTriangleColor = pvVar1;
    }
    return pvVar1;
}

- (void)setAutosize:(BOOL)aAutosize
{
    if ((_autosize != aAutosize) && (_autosize = aAutosize, aAutosize != NO)) {
        [self invalidateSize];
    }
}

- (BOOL)autosize
{
    return _autosize;
}

- (id)popUpButtonCell
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _popUpButtonCell;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSPopUpButtonCell alloc] init];
        _popUpButtonCell = pvVar1_3;
        [pvVar1_3 setAction:@selector(popUpDidEnd:)];
        [_popUpButtonCell setTarget:self];
        pvVar1 = _popUpButtonCell;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00209296 @ 00209296, 235 bytes * /

void FUN_00209296(HSTokenCell *self,SEL _cmd,id setSelectedMenuItem)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  if (setSelectedMenuItem == (id)0x0) {
    self->_selectedMenuItemIndex = -1;
    pvVar1 = _objc_msgSend(self,sel_textFieldCell);
    op = sel_setTitle_;
    setSelectedMenuItem = &cfstr_empty;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_menu);
    pvVar1 = _objc_msgSend(pvVar1,sel_indexOfItem_,setSelectedMenuItem);
    self->_selectedMenuItemIndex = (int)pvVar1;
    pvVar1 = _objc_msgSend(self,sel_textFieldCell);
    pvVar2 = _objc_msgSend(setSelectedMenuItem,sel_title);
    _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_popUpButtonCell);
    op = sel_selectItem_;
  }
  _objc_msgSend(pvVar1,op,setSelectedMenuItem);
  return;
}

*/
- (void)setSelectedMenuItem:(id)aItem
{
    if (aItem == nil) {
        _selectedMenuItemIndex = -1;
        [[self textFieldCell] setTitle:@""];
        return;
    }
    _selectedMenuItemIndex = (int)[[self menu] indexOfItem:aItem];
    [[self textFieldCell] setTitle:[aItem title]];
    [[self popUpButtonCell] selectItem:aItem];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (id)selectedMenuItem
{
    NSMenuItem *pvVar2_4;

    if ((_selectedMenuItemIndex < (int)[[self menu] numberOfItems]) && (-1 < _selectedMenuItemIndex)) {
        pvVar2_4 = [[self menu] itemAtIndex:_selectedMenuItemIndex];
    }
    else {
        pvVar2_4 = nil;
    }
    return pvVar2_4;
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_002093fb @ 002093fb, 432 bytes * /

BOOL FUN_002093fb(HSTokenCell *self,SEL _cmd,id activateMenuForEvent,NSRect cellFrame,id controlView
                 )

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined1 local_34 [8];
  float local_2c;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  pvVar2 = _objc_msgSend(self,sel_menu);
  _objc_msgSend(activateMenuForEvent,sel_locationInWindow);
  pvVar3 = _objc_msgSend(controlView,sel_convertPoint_fromView_);
  local_24 = cellFrame.origin.x;
  fStack_20 = cellFrame.origin.y;
  local_1c = cellFrame.size.width;
  fStack_18 = cellFrame.size.height;
  _objc_msgSend_stret(local_34,self,sel_menuTriangleRectForRect_,cellFrame.origin,cellFrame.size);
  local_2c = (cellFrame.size.height / -3.0 + cellFrame.size.height / -3.0 + local_1c) - local_2c;
  local_24 = local_24 + local_2c;
  local_1c = local_1c - local_2c;
  if (((pvVar2 != (id)0x0) && (pvVar2 = _objc_msgSend(pvVar2,sel_numberOfItems), pvVar2 != (id)0x0))
     && (cVar1 = _NSPointInRect(pvVar3,extraout_EDX,CONCAT44(fStack_20,local_24),
                                CONCAT44(fStack_18,local_1c)), cVar1 != '\0')) {
    pvVar2 = _objc_msgSend(self,sel_popUpButtonCell);
    _objc_msgSend(pvVar2,sel_performClickWithFrame_inView_,cellFrame.origin,cellFrame.size,
                  controlView);
    return '\x01';
  }
  return '\0';
}

*/
- (BOOL)activateMenuForEvent:(id)aEvent cellFrame:(NSRect)aFrame controlView:(id)aView
{
    NSMenu *menu = [self menu];
    NSPoint point = [aView convertPoint:[aEvent locationInWindow] fromView:nil];
    float x = aFrame.origin.x;
    float w = aFrame.size.width;
    NSRect tri = [self menuTriangleRectForRect:aFrame];
    float adjust = (aFrame.size.height / -3.0 + aFrame.size.height / -3.0 + w) - tri.size.width;
    x = x + adjust;
    w = w - adjust;
    if (menu != nil && [menu numberOfItems] != 0
        && NSPointInRect(point, NSMakeRect(x, aFrame.origin.y, w, aFrame.size.height))) {
        [[self popUpButtonCell] performClickWithFrame:aFrame inView:aView];
        return YES;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002095ab @ 002095ab, 104 bytes * /

void FUN_002095ab(HSTokenCell *self,SEL _cmd,BOOL highlight,NSRect withFrame,id inView)

{
  HSTokenCell *local_14;
  undefined *local_10;
  
  if (self->_canChangeHighlight != '\0') {
    local_14 = self;
    local_10 = PTR_s_NSCell_003549e0;
    _objc_msgSendSuper(&local_14,sel_highlight_withFrame_inView_,(int)highlight,withFrame.origin,
                       withFrame.size,inView);
  }
  return;
}

*/
- (void)highlight:(BOOL)aHighlight withFrame:(NSRect)aFrame inView:(id)aView
{
    if (_canChangeHighlight) {
        [super highlight:aHighlight withFrame:aFrame inView:aView];
    }
}

- (BOOL)canChangeHighlight
{
    return _canChangeHighlight;
}

- (void)setCanChangeHighlight:(BOOL)aHighlight
{
    _canChangeHighlight = aHighlight;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00209613 @ 00209613, 765 bytes * /

void FUN_00209613(HSTokenCell *self,SEL _cmd,NSRect drawBackgroundInRect,BOOL highlighted,
                 BOOL flipped)

{
  id pvVar1;
  id pvVar2;
  SEL pcVar3;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_new);
  _objc_msgSend_fpret(pvVar1,sel_lineWidth);
  _objc_msgSend(pvVar1,sel_moveToPoint_);
  _objc_msgSend(pvVar1,sel_curveToPoint_controlPoint1_controlPoint2_);
  _objc_msgSend(pvVar1,sel_lineToPoint_);
  _objc_msgSend(pvVar1,sel_curveToPoint_controlPoint1_controlPoint2_);
  _objc_msgSend(pvVar1,sel_closePath);
  pcVar3 = sel_backgroundColor;
  if (highlighted != '\0') {
    pcVar3 = sel_highlightedBackgroundColor;
  }
  pvVar2 = _objc_msgSend(self,pcVar3);
  _objc_msgSend(pvVar2,sel_set);
  _objc_msgSend(pvVar1,sel_fill);
  pcVar3 = sel_borderColor;
  if (highlighted != '\0') {
    pcVar3 = sel_highlightedBorderColor;
  }
  pvVar2 = _objc_msgSend(self,pcVar3);
  _objc_msgSend(pvVar2,sel_set);
  _objc_msgSend(pvVar1,sel_stroke);
  _objc_msgSend(pvVar1,sel_release);
  pvVar1 = _objc_msgSend(self,sel_menu);
  if (((pvVar1 != (id)0x0) && (pvVar1 = _objc_msgSend(pvVar1,sel_numberOfItems), pvVar1 != (id)0x0))
     && (highlighted != '\0')) {
    _objc_msgSend_stret(&local_24,self,sel_menuTriangleRectForRect_,drawBackgroundInRect.origin,
                        drawBackgroundInRect.size);
    _objc_msgSend(self,sel_drawMenuTriangleInRect_flipped_,local_24,local_1c,(int)flipped);
  }
  return;
}

*/
- (void)drawBackgroundInRect:(NSRect)aRect highlighted:(BOOL)aHighlighted flipped:(BOOL)aFlipped
{
    NSBezierPath *path = [NSBezierPath new];
    float halfLine = (float)[path lineWidth] * 0.5;
    float y = aRect.origin.y + halfLine;
    float x = aRect.origin.x + halfLine;
    float inset = halfLine * -2.0;
    float height = aRect.size.height + inset;
    float radius = (height / 3.0) + (height / 3.0);
    float top = height + y;
    [path moveToPoint:NSMakePoint(x + radius, y)];
    [path curveToPoint:NSMakePoint(x + radius, top)
         controlPoint1:NSMakePoint(x, y)
         controlPoint2:NSMakePoint(x, top)];
    float right = inset + aRect.size.width + x;
    [path lineToPoint:NSMakePoint(right - radius, top)];
    [path curveToPoint:NSMakePoint(right - radius, y)
         controlPoint1:NSMakePoint(right, top)
         controlPoint2:NSMakePoint(right, y)];
    [path closePath];
    [(aHighlighted ? [self highlightedBackgroundColor] : [self backgroundColor]) set];
    [path fill];
    [(aHighlighted ? [self highlightedBorderColor] : [self borderColor]) set];
    [path stroke];
    [path release];
    if ([self menu] != nil && [[self menu] numberOfItems] != 0 && aHighlighted) {
        [self drawMenuTriangleInRect:[self menuTriangleRectForRect:aRect] flipped:aFlipped];
    }
}

- (void)setUpTextFieldCellInitialSettings:(id)aSettings
{
    [aSettings setTitle:@""];
    [aSettings setSelectable:NO];
    [aSettings setEditable:NO];
    [aSettings setAlignment:2];
    [aSettings setLineBreakMode:4];
}

- (id)textFieldCell
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _textFieldCell;
    if (pvVar1 == nil) {
        pvVar1_2 = [NSTextFieldCell new];
        _textFieldCell = pvVar1_2;
        [self setUpTextFieldCellInitialSettings:pvVar1_2];
        pvVar1 = _textFieldCell;
    }
    return pvVar1;
}

- (void)setAction:(SEL)aAction
{
    _action = aAction;
}

- (SEL)action
{
    return _action;
}

- (id)target
{
    return _target;
}

- (void)setTarget:(id)aTarget
{
    _target = aTarget;
}

- (void)setFont:(id)aFont
{
    [[self textFieldCell] setFont:aFont];
}

- (id)font
{
    return [[self textFieldCell] font];
}

- (id)menu
{
    return [[self popUpButtonCell] menu];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setMenu:(id)aMenu
{
    if (_popUpButtonCell != nil) {
        if ([_popUpButtonCell menu] != aMenu) {
            [_popUpButtonCell setMenu:aMenu];
            if ([aMenu numberOfItems] != 0) {
                [self setSelectedMenuItem:[aMenu itemAtIndex:0]];
            }
        }
    }
}
#pragma clang diagnostic pop

- (void)setHighlighted:(BOOL)aHighlighted
{
    if (_canChangeHighlight != NO) {
        [super setHighlighted:aHighlighted];
    }
}

- (void)setTitle:(id)aTitle
{
    [[self textFieldCell] setTitle:aTitle];
    [self invalidateSize];
}

- (id)stringValue
{
    return [[self textFieldCell] stringValue];
}

- (void)setStringValue:(id)aValue
{
    [[self textFieldCell] setStringValue:aValue];
    [self invalidateSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00209c31 @ 00209c31, 323 bytes * /

void FUN_00209c31(HSTokenCell *self,SEL _cmd,NSRect drawWithFrame,id inView)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  int iVar5;
  NSPoint NVar6;
  NSSize NVar7;
  
  pvVar2 = _objc_msgSend(inView,sel_isFlipped);
  pvVar3 = _objc_msgSend(self,sel_isHighlighted);
  NVar6 = drawWithFrame.origin;
  NVar7 = drawWithFrame.size;
  iVar4 = (int)(char)pvVar2;
  iVar5 = (int)(char)pvVar3;
  _objc_msgSend(self,sel_drawBackgroundInRect_highlighted_flipped_,NVar6,NVar7,iVar5,iVar4);
  pvVar2 = _objc_msgSend(inView,sel_isFlipped);
  if ((char)pvVar2 == '\0') {
    fVar1 = 1.0;
  }
  else {
    fVar1 = -1.0;
  }
  pvVar2 = _objc_msgSend(self,sel_textFieldCell,NVar6,NVar7,iVar5,iVar4);
  _objc_msgSend(pvVar2,sel_drawWithFrame_inView_,
                CONCAT44(drawWithFrame.origin.y + fVar1,
                         (drawWithFrame.size.height / 3.0) * 0.5 + drawWithFrame.origin.x + 10.0),
                CONCAT44(drawWithFrame.size.height,
                         drawWithFrame.size.width - (drawWithFrame.size.height / 3.0 + 20.0)),inView
               );
  return;
}

*/
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    BOOL flipped = [aView isFlipped];
    BOOL highlighted = [self isHighlighted];
    [self drawBackgroundInRect:aFrame highlighted:highlighted flipped:flipped];
    float dy = [aView isFlipped] ? -1.0 : 1.0;
    [[self textFieldCell] drawWithFrame:NSMakeRect((aFrame.size.height / 3.0) * 0.5 + aFrame.origin.x + 10.0,
                                                   aFrame.origin.y + dy,
                                                   aFrame.size.width - (aFrame.size.height / 3.0 + 20.0),
                                                   aFrame.size.height)
                                 inView:aView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00209d74 @ 00209d74, 67 bytes * /

void FUN_00209d74(HSTokenCell *self,SEL _cmd,NSRect drawInteriorWithFrame,id inView)

{
  _objc_msgSend(self,sel_drawWithFrame_inView_,drawInteriorWithFrame.origin,
                drawInteriorWithFrame.size,inView);
  return;
}

*/
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    [self drawWithFrame:aFrame inView:aView];
}

- (void)dealloc
{
    [_textAttachment release];
    [_textFieldCell release];
    [_menuTriangleColor release];
    [_borderColor release];
    [_highlightedBorderColor release];
    [_backgroundColor release];
    [_highlightedBackgroundColor release];
    [_popUpButtonCell release];
    _popUpButtonCell = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _selectedMenuItemIndex = 0xffffffff;
        [self popUpButtonCell];
    }
    return self;
}

@end

