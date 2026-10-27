#import "HSColorMatrix.h"

@implementation HSColorMatrix

/* i386 ivar offsets: _dataProvider=0xb0 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d022e @ 000d022e, 217 bytes * /

NSRect * FUN_000d022e(NSRect *__return_storage_ptr__,HSColorMatrix *self,SEL _cmd,
                     int selectionRectForCellAtRow,int column)

{
  NSRect *pNVar1;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined8 local_1c;
  undefined8 local_14;
  
  pNVar1 = (NSRect *)0xd023b;
  local_2c = *(float *)PTR_00336078;
  local_28 = *(float *)(PTR_00336078 + 4);
  local_24 = *(float *)(PTR_00336078 + 8);
  local_20 = *(float *)(PTR_00336078 + 0xc);
  if ((selectionRectForCellAtRow != -1) || (column != -1)) {
    _objc_msgSend_stret(&local_1c,self,sel_cellFrameAtRow_column_);
    pNVar1 = (NSRect *)_NSInsetRect(&local_2c,local_1c,local_14,0xbf800000,0xbf800000);
  }
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = local_28;
  (__return_storage_ptr__->size).width = local_24;
  (__return_storage_ptr__->size).height = local_20;
  return pNVar1;
}

*/
- (NSRect)selectionRectForCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    NSRect rect = NSZeroRect;
    if (aRow != -1 || aColumn != -1) {
        rect = NSInsetRect([self cellFrameAtRow:aRow column:aColumn], -1.0, -1.0);
    }
    return rect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d0129 @ 000d0129, 80 bytes * /

id FUN_000d0129(HSColorMatrix *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabled);
  op = sel_grayColor;
  if ((char)pvVar1 != '\0') {
    op = sel_blackColor;
  }
  pvVar1 = _objc_msgSend(cls_NSColor,op);
  return pvVar1;
}

*/
- (id)selectionColor
{
    return [self isEnabled] ? [NSColor blackColor] : [NSColor grayColor];
}

- (void)handleDoubleClick
{

}

- (void)handleSingleClickWithSelectionChange:(BOOL)aChange
{

}

- (void)handleMouseTracking
{

}

- (void)reloadData
{
    NSUInteger pvVar1;
    NSInteger pvVar2;
    NSCell *self_00;
    id pvVar3;
    int iVar4;
    int local_14;

    pvVar1 = [_dataProvider numberOfRows];
    pvVar2 = [_dataProvider numberOfColumns];
    [self willChangeValueForKey:@"selectedColor"];
    if ((0 < (int)pvVar1) && (0 < (int)pvVar2)) {
        local_14 = 0;
        do {
            iVar4 = 0;
            do {
                self_00 = [self cellAtRow:local_14 column:iVar4];
                pvVar3 = [_dataProvider colorSwatchImageAtRow:local_14 column:iVar4]
                ;
                [self_00 setImage:pvVar3];
                iVar4 = iVar4 + 1;
            } while (iVar4 < (int)pvVar2);
            local_14 = local_14 + 1;
        } while (local_14 < (int)pvVar1);
    }
    [self didChangeValueForKey:@"selectedColor"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSColorMatrixSelectedColorDidChangeNotification" object:self];
    [self setNeedsDisplay];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d0307 @ 000d0307, 537 bytes * /

void FUN_000d0307(HSColorMatrix *self,SEL _cmd,id dataProviderDidColorChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSColorMatrix **ppHVar4;
  HSColorMatrix *local_50;
  undefined1 local_24 [20];
  
  local_50 = (HSColorMatrix *)0xd032b;
  pvVar1 = _objc_msgSend(dataProviderDidColorChange,sel_userInfo);
  local_50 = (HSColorMatrix *)0xd034b;
  pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_);
  local_50 = (HSColorMatrix *)0xd036b;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_);
  ppHVar4 = (HSColorMatrix **)&stack0xffffffb4;
  if ((pvVar2 != (id)0x0) && (ppHVar4 = (HSColorMatrix **)&stack0xffffffb4, pvVar1 != (id)0x0)) {
    local_50 = (HSColorMatrix *)0xd038f;
    pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
    local_50 = (HSColorMatrix *)0xd03a4;
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    local_50 = (HSColorMatrix *)0xd03c9;
    pvVar3 = _objc_msgSend(self,sel_cellAtRow_column_);
    local_50 = (HSColorMatrix *)0xd03f1;
    _objc_msgSend(self->_dataProvider,sel_colorSwatchImageAtRow_column_);
    local_50 = (HSColorMatrix *)0xd0407;
    _objc_msgSend(pvVar3,sel_setImage_);
    local_50 = (HSColorMatrix *)0xd041c;
    pvVar3 = _objc_msgSend(self,sel_selectedRow);
    if (pvVar3 == pvVar2) {
      local_50 = (HSColorMatrix *)0xd0439;
      pvVar2 = _objc_msgSend(self,sel_selectedColumn);
      if (pvVar2 == pvVar1) {
        local_50 = (HSColorMatrix *)0xd045d;
        _objc_msgSend(self,sel_willChangeValueForKey_);
        local_50 = (HSColorMatrix *)0xd0475;
        pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
        local_50 = (HSColorMatrix *)0xd0498;
        _objc_msgSend(pvVar1,sel_postNotificationName_object_);
        local_50 = (HSColorMatrix *)0xd04b1;
        _objc_msgSend(self,sel_didChangeValueForKey_);
      }
    }
    local_50 = (HSColorMatrix *)0xd04db;
    _objc_msgSend_stret(local_24,self,sel_selectionRectForCellAtRow_column_);
    local_50 = self;
    ppHVar4 = &local_50;
  }
  ppHVar4[-1] = (HSColorMatrix *)0xd0518;
  _objc_msgSend(*ppHVar4,(SEL)ppHVar4[1]);
  return;
}

*/
- (void)dataProviderDidColorChange:(id)aChange
{
    id userInfo = [aChange userInfo];
    id rowValue = [userInfo objectForKey:@"HSRowKey"];
    id columnValue = [userInfo objectForKey:@"HSColumnKey"];
    if (rowValue == nil || columnValue == nil) {
        [self reloadData];
        return;
    }
    NSInteger row = [rowValue intValue];
    NSInteger column = [columnValue intValue];
    [[self cellAtRow:row column:column] setImage:[_dataProvider colorSwatchImageAtRow:row column:column]];
    if ([self selectedRow] == row && [self selectedColumn] == column) {
        [self willChangeValueForKey:@"selectedColor"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSColorMatrixSelectedColorDidChangeNotification" object:self];
        [self didChangeValueForKey:@"selectedColor"];
    }
    [self setNeedsDisplayInRect:[self selectionRectForCellAtRow:row column:column]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cff05 @ 000cff05, 195 bytes * /

void FUN_000cff05(HSColorMatrix *self,SEL _cmd,id setSelectedColor)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedColor);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualTo_,setSelectedColor);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_dataProvider,sel_positionOfColor_,setSelectedColor);
    op = sel_deselectSelectedCell;
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar1,sel_column,setSelectedColor);
      setSelectedColor = _objc_msgSend(pvVar1,sel_row);
      op = sel_selectCellAtRow_column_;
    }
    _objc_msgSend(self,op,setSelectedColor);
  }
  return;
}

*/
- (void)setSelectedColor:(id)aColor
{
    if (![[self selectedColor] isEqualTo:aColor]) {
        id position = [_dataProvider positionOfColor:aColor];
        if (position != nil) {
            [position column];
            [self selectCellAtRow:[position row] column:[position column]];
        }
        else {
            [self deselectSelectedCell];
        }
    }
}

- (id)selectedColor
{
    NSInteger pvVar1;
    NSInteger pvVar2;
    id pvVar1_2;

    pvVar1 = [self selectedRow];
    pvVar2 = [self selectedColumn];
    if ((pvVar1 == 0xffffffff) && (pvVar2 == 0xffffffff)) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [_dataProvider colorAtRow:pvVar1 column:pvVar2];
    }
    return pvVar1_2;
}

- (id)dataProvider
{
    return _dataProvider;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cfbcd @ 000cfbcd, 714 bytes * /

void FUN_000cfbcd(HSColorMatrix *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  id pvVar2;
  undefined4 ****ppppuVar3;
  undefined4 ****ppppuVar4;
  undefined4 ****ppppuVar5;
  SEL pcVar6;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  char cVar7;
  undefined4 uVar8;
  undefined4 ***local_18;
  undefined4 ***local_14;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_window);
    local_14 = (undefined4 ****)0x0;
    local_18 = (undefined4 ****)0x0;
    do {
      pvVar2 = _objc_msgSend(mouseDown,sel_locationInWindow);
      pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
      ppppuVar5 = &local_18;
      ppppuVar4 = &local_14;
      uVar8 = extraout_EDX_00;
      _objc_msgSend(self,sel_getRow_column_forPoint_,ppppuVar4,ppppuVar5,pvVar2,extraout_EDX_00);
      ppppuVar3 = _objc_msgSend(self,sel_selectedRow);
      if ((ppppuVar3 == (undefined4 ****)local_14) &&
         (ppppuVar3 = _objc_msgSend(self,sel_selectedColumn,ppppuVar4,ppppuVar5,pvVar2,uVar8),
         ppppuVar3 == (undefined4 ****)local_18)) {
        cVar7 = '\0';
      }
      else {
        ppppuVar4 = (undefined4 ****)local_14;
        ppppuVar5 = (undefined4 ****)local_18;
        _objc_msgSend(self,sel_selectCellAtRow_column_,local_14,local_18,pvVar2,uVar8);
        cVar7 = '\x01';
      }
      pvVar2 = _objc_msgSend(mouseDown,sel_type,ppppuVar4,ppppuVar5,pvVar2,uVar8);
      if (pvVar2 == (id)0x6) {
        pcVar6 = sel_handleMouseTracking;
        if (cVar7 != '\0') {
LAB_000cfdb3:
          _objc_msgSend(self,pcVar6,ppppuVar4,ppppuVar5);
          pvVar2 = _objc_msgSend(self,sel_action);
          if ((pvVar2 != (id)0x0) &&
             (pvVar2 = _objc_msgSend(self,sel_target,ppppuVar4), pvVar2 != (id)0x0)) {
            ppppuVar5 = _objc_msgSend(self,sel_target,ppppuVar4);
            pcVar6 = sel_action;
LAB_000cfe0e:
            pvVar2 = _objc_msgSend(self,pcVar6);
            _objc_msgSend(self,sel_sendAction_to_,pvVar2,ppppuVar5);
          }
        }
      }
      else if (pvVar2 == (id)0x1) {
        pvVar2 = _objc_msgSend(mouseDown,sel_clickCount,ppppuVar4,ppppuVar5);
        if (pvVar2 == (id)0x2) {
          _objc_msgSend(self,sel_handleDoubleClick,ppppuVar4,ppppuVar5);
          pvVar2 = _objc_msgSend(self,sel_doubleAction);
          if ((pvVar2 != (id)0x0) && (pvVar2 = _objc_msgSend(self,sel_target), pvVar2 != (id)0x0)) {
            ppppuVar5 = _objc_msgSend(self,sel_target);
            pcVar6 = sel_doubleAction;
            goto LAB_000cfe0e;
          }
        }
        else if (pvVar2 == (id)0x1) {
          ppppuVar4 = (undefined4 ****)(int)cVar7;
          pcVar6 = sel_handleSingleClickWithSelectionChange_;
          goto LAB_000cfdb3;
        }
      }
      mouseDown = _objc_msgSend(pvVar1,sel_nextEventMatchingMask_,0x44,ppppuVar5);
      pvVar2 = _objc_msgSend(mouseDown,sel_type);
    } while (pvVar2 != (id)0x2);
    _objc_msgSend(pvVar1,sel_discardEventsMatchingMask_beforeEvent_,0xffffffff,mouseDown);
  }
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    if (![self isEnabled]) {
        return;
    }
    NSWindow *window = [self window];
    int row = 0;
    int column = 0;
    do {
        NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
        [self getRow:&row column:&column forPoint:point];
        BOOL changed;
        if ([self selectedRow] == row && [self selectedColumn] == column) {
            changed = NO;
        }
        else {
            [self selectCellAtRow:row column:column];
            changed = YES;
        }
        NSEvent *event = aDown;
        NSInteger type = [event type];
        if (type == 6) {
            if (changed) {
                [self handleMouseTracking];
                if ([self action] != NULL && [self target] != nil) {
                    [self sendAction:[self action] to:[self target]];
                }
            }
        }
        else if (type == 1) {
            NSInteger clicks = [event clickCount];
            if (clicks == 2) {
                [self handleDoubleClick];
                if ([self doubleAction] != NULL && [self target] != nil) {
                    [self sendAction:[self doubleAction] to:[self target]];
                }
            }
            else if (clicks == 1) {
                [self handleSingleClickWithSelectionChange:changed];
                if ([self action] != NULL && [self target] != nil) {
                    [self sendAction:[self action] to:[self target]];
                }
            }
        }
        aDown = [window nextEventMatchingMask:0x44];
    } while ([(NSEvent *)aDown type] != 2);
    [window discardEventsMatchingMask:0xffffffff beforeEvent:aDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d0520 @ 000d0520, 398 bytes * /

BOOL FUN_000d0520(HSColorMatrix *self,SEL _cmd,int *getRow,int *column,NSPoint forPoint)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  float extraout_EDX;
  float extraout_EDX_00;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  HSColorMatrix *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSMatrix_0034ffa0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_getRow_column_forPoint_,getRow,column,forPoint.x,
                              forPoint.y);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend_stret(&local_2c,self,sel_bounds);
    pvVar2 = _objc_msgSend(self,sel_cellSize);
    pvVar3 = _objc_msgSend(self,sel_intercellSpacing);
    if (0.0 <= forPoint.x) {
      if (forPoint.x <= local_2c + local_24) {
        *column = (int)(forPoint.x / ((float)pvVar3 + (float)pvVar2));
      }
      else {
        pvVar2 = _objc_msgSend(self,sel_numberOfColumns);
        *column = (int)pvVar2 + -1;
      }
    }
    else {
      *column = 0;
    }
    if (0.0 <= forPoint.y) {
      if (forPoint.y <= local_28 + local_20) {
        iVar4 = (int)(forPoint.y / (extraout_EDX + extraout_EDX_00));
      }
      else {
        pvVar2 = _objc_msgSend(self,sel_numberOfRows);
        iVar4 = (int)pvVar2 + -1;
      }
      *getRow = iVar4;
    }
    else {
      *getRow = 0;
    }
  }
  return (char)pvVar1;
}

*/
- (BOOL)getRow:(int *)aRow column:(int *)aColumn forPoint:(NSPoint)aPoint
{
    BOOL found = [super getRow:aRow column:aColumn forPoint:aPoint];
    if (!found) {
        NSRect bounds = [self bounds];
        NSSize cellSize = [self cellSize];
        NSSize spacing = [self intercellSpacing];
        if (0.0 <= aPoint.x) {
            if (aPoint.x <= bounds.origin.x + bounds.size.width) {
                *aColumn = (int)(aPoint.x / (spacing.width + cellSize.width));
            }
            else {
                *aColumn = (int)[self numberOfColumns] - 1;
            }
        }
        else {
            *aColumn = 0;
        }
        if (0.0 <= aPoint.y) {
            int row;
            if (aPoint.y <= bounds.origin.y + bounds.size.height) {
                row = (int)(aPoint.y / (cellSize.height + spacing.height));
            }
            else {
                row = (int)[self numberOfRows] - 1;
            }
            *aRow = row;
        }
        else {
            *aRow = 0;
        }
    }
    return found;
}

- (void)deselectSelectedCell
{
    NSInteger row = [self selectedRow];
    NSInteger column = [self selectedColumn];
    if (row != NSNotFound && column != NSNotFound) {
        [self willChangeValueForKey:@"selectedColor"];
        [super deselectSelectedCell];
        [self didChangeValueForKey:@"selectedColor"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSColorMatrixSelectedColorDidChangeNotification" object:self];
        [self setNeedsDisplayInRect:[self selectionRectForCellAtRow:row column:column]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d07ee @ 000d07ee, 430 bytes * /

BOOL FUN_000d07ee(HSColorMatrix *self,SEL _cmd,int selectCellWithTag)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined8 local_3c;
  undefined8 local_34;
  HSColorMatrix *local_2c;
  undefined *local_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend(self,sel_selectedColumn);
  _objc_msgSend(self,sel_selectedRow);
  _objc_msgSend_stret(&local_24,self,sel_selectionRectForCellAtRow_column_);
  _objc_msgSend(self,sel_willChangeValueForKey_);
  local_2c = self;
  local_28 = PTR_s_NSMatrix_0034ffa0;
  pvVar1 = _objc_msgSendSuper(&local_2c,sel_selectCellWithTag_);
  _objc_msgSend(self,sel_didChangeValueForKey_);
  if ((char)pvVar1 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_selectedColumn);
    pvVar3 = _objc_msgSend(self,sel_selectedRow);
    _objc_msgSend_stret(&local_3c,self,sel_selectionRectForCellAtRow_column_,pvVar3,pvVar2);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,local_24,local_1c);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,local_3c,local_34);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_postNotificationName_object_,
                  &cfstr_HSColorMatrixSelectedColorDidChangeNotification,self);
  }
  return (char)pvVar1;
}

*/
- (BOOL)selectCellWithTag:(NSInteger)aTag
{
    NSRect oldRect = [self selectionRectForCellAtRow:[self selectedRow] column:[self selectedColumn]];
    [self willChangeValueForKey:@"selectedColor"];
    BOOL selected = [super selectCellWithTag:aTag];
    [self didChangeValueForKey:@"selectedColor"];
    if (selected) {
        NSRect newRect = [self selectionRectForCellAtRow:[self selectedRow] column:[self selectedColumn]];
        [self setNeedsDisplayInRect:oldRect];
        [self setNeedsDisplayInRect:newRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSColorMatrixSelectedColorDidChangeNotification" object:self];
    }
    return selected;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d099c @ 000d099c, 389 bytes * /

void FUN_000d099c(HSColorMatrix *self,SEL _cmd,int selectCellAtRow,int column)

{
  id pvVar1;
  id pvVar2;
  undefined8 local_3c;
  undefined8 local_34;
  HSColorMatrix *local_2c;
  undefined *local_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_selectedRow);
  pvVar2 = _objc_msgSend(self,sel_selectedColumn);
  if ((pvVar1 != (id)selectCellAtRow) || (pvVar2 != (id)column)) {
    _objc_msgSend_stret(&local_24,self,sel_selectionRectForCellAtRow_column_);
    _objc_msgSend(self,sel_willChangeValueForKey_);
    local_2c = self;
    local_28 = PTR_s_NSMatrix_0034ffa0;
    _objc_msgSendSuper(&local_2c,sel_selectCellAtRow_column_);
    _objc_msgSend(self,sel_didChangeValueForKey_);
    _objc_msgSend_stret(&local_3c,self,sel_selectionRectForCellAtRow_column_,selectCellAtRow,column,
                        pvVar2);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,local_24,local_1c);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,local_3c,local_34);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                  &cfstr_HSColorMatrixSelectedColorDidChangeNotification,self);
  }
  return;
}

*/
- (void)selectCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    NSInteger row = [self selectedRow];
    NSInteger column = [self selectedColumn];
    if (row != aRow || column != aColumn) {
        NSRect oldRect = [self selectionRectForCellAtRow:row column:column];
        [self willChangeValueForKey:@"selectedColor"];
        [super selectCellAtRow:aRow column:aColumn];
        [self didChangeValueForKey:@"selectedColor"];
        NSRect newRect = [self selectionRectForCellAtRow:aRow column:aColumn];
        [self setNeedsDisplayInRect:oldRect];
        [self setNeedsDisplayInRect:newRect];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSColorMatrixSelectedColorDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d0b21 @ 000d0b21, 269 bytes * /

void FUN_000d0b21(HSColorMatrix *self,SEL _cmd,NSRect drawRect)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined8 local_2c [2];
  HSColorMatrix *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSMatrix_0034ffa0;
  _objc_msgSendSuper(&local_1c,sel_drawRect_,drawRect.origin.x,drawRect.origin.y,drawRect.size.width
                     ,drawRect.size.height);
  pvVar2 = _objc_msgSend(self,sel_selectedColumn);
  pvVar3 = _objc_msgSend(self,sel_selectedRow);
  _objc_msgSend_stret(local_2c,self,sel_selectionRectForCellAtRow_column_,pvVar3,pvVar2);
  cVar1 = _NSIntersectsRect(local_2c[0],(int)local_2c[1],(int)((ulonglong)local_2c[1] >> 0x20),
                            drawRect.origin.x,drawRect.origin.y,drawRect.size.width,
                            drawRect.size.height);
  if (cVar1 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_selectionColor);
    _objc_msgSend(pvVar2,sel_set);
    _NSFrameRect(local_2c[0],(int)local_2c[1],(int)((ulonglong)local_2c[1] >> 0x20));
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    NSRect rect = [self selectionRectForCellAtRow:[self selectedRow] column:[self selectedColumn]];
    if (NSIntersectsRect(rect, aRect)) {
        [[self selectionColor] set];
        NSFrameRect(rect);
    }
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cf9e0 @ 000cf9e0, 493 bytes * /

void FUN_000cf9e0(HSColorMatrix *self,SEL _cmd,id viewWillMoveToSuperview)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined4 extraout_EDX;
  int iVar3;
  int iVar4;
  id pvVar5;
  int iVar6;
  
  pvVar1 = _objc_msgSend(self->_dataProvider,sel_colorSwatchImageSize);
  _objc_msgSend(self,sel_setCellSize_,pvVar1,extraout_EDX);
  pvVar1 = _objc_msgSend(cls_NSColor,sel_whiteColor);
  _objc_msgSend(self,sel_setBackgroundColor_,pvVar1);
  _objc_msgSend(self,sel_setDrawsBackground_,1);
  iVar6 = 0;
  _objc_msgSend(self,sel_setIntercellSpacing_,0,0);
  pvVar5 = (id)0x1;
  _objc_msgSend(self,sel_setAllowsEmptySelection_,1);
  pvVar1 = _objc_msgSend(self->_dataProvider,sel_numberOfRows);
  pvVar2 = _objc_msgSend(self->_dataProvider,sel_numberOfColumns);
  if ((0 < (int)pvVar1) && (0 < (int)pvVar2)) {
    iVar3 = 0;
    do {
      iVar4 = 0;
      do {
        self_00 = _objc_msgSend(self,sel_cellAtRow_column_,iVar3,iVar4);
        iVar6 = iVar4;
        pvVar5 = _objc_msgSend(self->_dataProvider,sel_colorSwatchImageAtRow_column_,iVar3,iVar4);
        _objc_msgSend(self_00,sel_setImage_,pvVar5);
        iVar4 = iVar4 + 1;
      } while (iVar4 < (int)pvVar2);
      iVar3 = iVar3 + 1;
    } while (iVar3 < (int)pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar5,iVar6);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_dataProviderDidColorChange_,
                *(undefined4 *)PTR_PTR_003364a0,self->_dataProvider);
  _objc_msgSend(self,sel_sizeToCells);
  return;
}

*/
- (void)viewWillMoveToSuperview:(id)aSuperview
{
    [self setCellSize:[_dataProvider colorSwatchImageSize]];
    [self setBackgroundColor:[NSColor whiteColor]];
    [self setDrawsBackground:YES];
    [self setIntercellSpacing:NSZeroSize];
    [self setAllowsEmptySelection:YES];
    NSInteger rows = [_dataProvider numberOfRows];
    NSInteger columns = [_dataProvider numberOfColumns];
    if (0 < rows && 0 < columns) {
        for (NSInteger row = 0; row < rows; row++) {
            for (NSInteger column = 0; column < columns; column++) {
                [[self cellAtRow:row column:column] setImage:[_dataProvider colorSwatchImageAtRow:row column:column]];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataProviderDidColorChange:) name:@"HSColorMatrixDataProviderColorDidChangeNotification" object:_dataProvider];
    [self sizeToCells];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d0179 @ 000d0179, 181 bytes * /

id FUN_000d0179(HSColorMatrix *self,SEL _cmd,NSRect initWithFrame,id dataProvider)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSColorMatrix *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(dataProvider,sel_numberOfRows);
  pvVar2 = _objc_msgSend(dataProvider,sel_numberOfColumns);
  local_1c = self;
  local_18 = PTR_s_NSMatrix_0034ffa0;
  pvVar3 = _objc_msgSend(cls_NSImageCell,sel_class);
  pvVar1 = _objc_msgSendSuper(&local_1c,
                              sel_initWithFrame_mode_cellClass_numberOfRows_numberOfColumns_,
                              initWithFrame.origin,initWithFrame.size,0,pvVar3,pvVar1,pvVar2);
  if (pvVar1 != (id)0x0) {
    *(id *)((int)pvVar1 + 0xb0) = dataProvider;
  }
  return pvVar1;
}

*/
- (id)initWithFrame:(NSRect)aFrame dataProvider:(id)aProvider
{
    NSInteger rows = [aProvider numberOfRows];
    NSInteger columns = [aProvider numberOfColumns];
    self = [super initWithFrame:aFrame mode:NSRadioModeMatrix cellClass:[NSImageCell class] numberOfRows:rows numberOfColumns:columns];
    if (self) {
        _dataProvider = aProvider;
    }
    return self;
}

@end

