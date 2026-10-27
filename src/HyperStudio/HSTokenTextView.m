#import "HSTokenTextView.h"

@implementation HSTokenTextView

/* i386 ivar offsets: _lastHighlighted=0x64, _mouseEnteredCount=0x68, _viewTrackingRectTag=0x6c, _tokensTrackingRectTags=0x70 */

+ (id)paragraphStyle
{
    id pvVar1;

    pvVar1 = [NSMutableParagraphStyle new];
    [pvVar1 setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [pvVar1 setMinimumLineHeight:19.0];
    return [pvVar1 autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020a820 @ 0020a820, 644 bytes * /

id FUN_0020a820(HSTokenTextView *self,SEL _cmd,NSPoint cellAtPoint)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar7;
  undefined8 uVar6;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar2 = _objc_msgSend(self,sel_layoutManager);
  _objc_msgSend(self,sel_textContainer);
  pvVar2 = _objc_msgSend(pvVar2,sel_glyphIndexForPoint_inTextContainer_);
  pvVar3 = _objc_msgSend(self,sel_layoutManager);
  pvVar4 = _objc_msgSend(self,sel_textContainer);
  _objc_msgSend_stret(&local_24,pvVar3,sel_boundingRectForGlyphRange_inTextContainer_,pvVar2,1,
                      pvVar4);
  cVar1 = _NSPointInRect(cellAtPoint.x,cellAtPoint.y,local_24,local_1c);
  if (cVar1 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_window);
    pvVar3 = _objc_msgSend(self,sel_convertPoint_toView_,cellAtPoint.x,cellAtPoint.y,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_convertBaseToScreen_,pvVar3,extraout_EDX);
    uVar7 = extraout_EDX_00;
    pvVar2 = _objc_msgSend(self,sel_characterIndexForPoint_,pvVar2,extraout_EDX_00);
    pvVar3 = _objc_msgSend(self,sel_textStorage);
    pvVar3 = _objc_msgSend(pvVar3,sel_string);
    pvVar4 = _objc_msgSend(pvVar3,sel_length);
    if (pvVar2 < pvVar4) {
      uVar6 = CONCAT44(uVar7,pvVar2);
      pvVar3 = _objc_msgSend(pvVar3,sel_characterAtIndex_,pvVar2);
      if ((short)pvVar3 == -4) {
        pvVar3 = _objc_msgSend(self,sel_textStorage,uVar6);
        pvVar3 = _objc_msgSend(pvVar3,sel_attribute_atIndex_effectiveRange_,
                               *(undefined4 *)PTR_003367a8,pvVar2,0);
        pvVar4 = _objc_msgSend(pvVar3,sel_attachmentCell);
        pvVar5 = _objc_msgSend(cls_HSTokenCell,sel_class);
        uVar6 = CONCAT44(pvVar2,pvVar5);
        pvVar2 = _objc_msgSend(pvVar4,sel_isKindOfClass_,pvVar5);
        if ((char)pvVar2 != '\0') {
          pvVar2 = _objc_msgSend(pvVar3,sel_attachmentCell,uVar6);
          return pvVar2;
        }
      }
    }
  }
  return (id)0x0;
}

*/
- (id)cellAtPoint:(NSPoint)aPoint
{
    NSUInteger glyphIndex = [[self layoutManager] glyphIndexForPoint:aPoint inTextContainer:[self textContainer]];
    NSRect glyphRect = [[self layoutManager] boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:[self textContainer]];
    if (!NSPointInRect(aPoint, glyphRect)) {
        return nil;
    }
    NSPoint screenPoint = [[self window] convertPointToScreen:[self convertPoint:aPoint toView:nil]];
    NSUInteger index = [self characterIndexForPoint:screenPoint];
    NSString *string = [[self textStorage] string];
    if (index < [string length] && [string characterAtIndex:index] == NSAttachmentCharacter) {
        NSTextAttachment *attachment = [[self textStorage] attribute:NSAttachmentAttributeName atIndex:index effectiveRange:NULL];
        if ([[attachment attachmentCell] isKindOfClass:[HSTokenCell class]]) {
            return [attachment attachmentCell];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020a575 @ 0020a575, 345 bytes * /

id FUN_0020a575(HSTokenTextView *self,SEL _cmd)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int iVar7;
  int iVar8;
  undefined4 *puVar9;
  undefined4 local_1c;
  int local_18;
  
  self_00 = _objc_msgSend(self,sel_textStorage);
  pvVar2 = _objc_msgSend(self_00,sel_containsAttachments);
  if ((char)pvVar2 == '\0') {
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar3 = _objc_msgSend(self_00,sel_length);
    puVar1 = PTR_003367a8;
    if (0 < (int)pvVar3) {
      iVar7 = 0;
      do {
        local_1c = 0;
        local_18 = 0;
        puVar9 = &local_1c;
        iVar8 = iVar7;
        pvVar4 = _objc_msgSend(self_00,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)puVar1,
                               iVar7,puVar9);
        pvVar5 = _objc_msgSend(pvVar4,sel_attachmentCell);
        pvVar6 = _objc_msgSend(cls_HSTokenCell,sel_class);
        pvVar5 = _objc_msgSend(pvVar5,sel_isKindOfClass_,pvVar6);
        if ((char)pvVar5 != '\0') {
          pvVar4 = _objc_msgSend(pvVar4,sel_attachmentCell,pvVar6,iVar8,puVar9);
          _objc_msgSend(pvVar2,sel_addObject_,pvVar4);
        }
        iVar8 = local_18 + iVar7;
        iVar7 = iVar7 + 1;
        if (local_18 != 0) {
          iVar7 = iVar8;
        }
      } while (iVar7 < (int)pvVar3);
    }
  }
  return pvVar2;
}

*/
- (id)allCells
{
    NSTextStorage *storage = [self textStorage];
    if (![storage containsAttachments]) {
        return nil;
    }
    NSMutableArray *cells = [NSMutableArray array];
    NSInteger length = [storage length];
    NSInteger index = 0;
    while (index < length) {
        NSRange range = {0, 0};
        NSTextAttachment *attachment = [storage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
        if ([[attachment attachmentCell] isKindOfClass:[HSTokenCell class]]) {
            [cells addObject:[attachment attachmentCell]];
        }
        index = range.length != 0 ? index + range.length : index + 1;
    }
    return cells;
}

- (void)textStorageDidProcessEditing:(id)aEditing
{
    [self updateTextStorage];
}

- (void)updateTextStorage
{
    NSTextStorage *self_00;
    unsigned pvVar1;

    self_00 = [self textStorage];
    pvVar1 = [self_00 length];
    [self_00 addAttribute:NSParagraphStyleAttributeName value:[[self class] paragraphStyle] range:NSMakeRange(0, pvVar1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020aaa4 @ 0020aaa4, 299 bytes * /

void FUN_0020aaa4(HSTokenTextView *self,SEL _cmd,NSRect setBounds)

{
  id pvVar1;
  HSTokenTextView *pHVar2;
  undefined4 *puVar3;
  HSTokenTextView *local_24;
  undefined *local_20;
  undefined1 local_1c [16];
  
  puVar3 = (undefined4 *)&stack0xffffffb4;
  local_24 = self;
  local_20 = PTR_s_HSPlaceholderTextView_00354a10;
  _objc_msgSendSuper(&local_24,sel_setBounds_);
  if (self->_viewTrackingRectTag != 0) {
    _objc_msgSend(self,sel_removeTokensTrackingRects);
    _objc_msgSend(self,sel_setupTrackingRectsForTokens);
    _objc_msgSend(self,sel_removeTrackingRect_);
    _objc_msgSend_stret(local_1c,self,sel_bounds);
    puVar3 = (undefined4 *)&stack0xffffffb0;
    pvVar1 = _objc_msgSend(self,sel_addTrackingRect_owner_userData_assumeInside_);
    self->_viewTrackingRectTag = (int)pvVar1;
  }
  puVar3[1] = sel_window;
  *puVar3 = self;
  puVar3[-1] = 0x20aba0;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_firstResponder;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x20abb2;
  pHVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  if (pHVar2 != self) {
    puVar3[1] = sel_updateTokenRects;
    *puVar3 = self;
    puVar3[-1] = 0x20abc8;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)setBounds:(NSRect)aBounds
{
    [super setBounds:aBounds];
    if (_viewTrackingRectTag != 0) {
        [self removeTokensTrackingRects];
        [self setupTrackingRectsForTokens];
        [self removeTrackingRect:_viewTrackingRectTag];
        _viewTrackingRectTag = (int)[self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
    }
    if ([[self window] firstResponder] != self) {
        [self updateTokenRects];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020abcf @ 0020abcf, 299 bytes * /

void FUN_0020abcf(HSTokenTextView *self,SEL _cmd,NSRect setFrame)

{
  id pvVar1;
  HSTokenTextView *pHVar2;
  undefined4 *puVar3;
  HSTokenTextView *local_24;
  undefined *local_20;
  undefined1 local_1c [16];
  
  puVar3 = (undefined4 *)&stack0xffffffb4;
  local_24 = self;
  local_20 = PTR_s_HSPlaceholderTextView_00354a10;
  _objc_msgSendSuper(&local_24,sel_setFrame_);
  if (self->_viewTrackingRectTag != 0) {
    _objc_msgSend(self,sel_removeTokensTrackingRects);
    _objc_msgSend(self,sel_setupTrackingRectsForTokens);
    _objc_msgSend(self,sel_removeTrackingRect_);
    _objc_msgSend_stret(local_1c,self,sel_bounds);
    puVar3 = (undefined4 *)&stack0xffffffb0;
    pvVar1 = _objc_msgSend(self,sel_addTrackingRect_owner_userData_assumeInside_);
    self->_viewTrackingRectTag = (int)pvVar1;
  }
  puVar3[1] = sel_window;
  *puVar3 = self;
  puVar3[-1] = 0x20accb;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_firstResponder;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x20acdd;
  pHVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  if (pHVar2 != self) {
    puVar3[1] = sel_updateTokenRects;
    *puVar3 = self;
    puVar3[-1] = 0x20acf3;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)setFrame:(NSRect)aFrame
{
    [super setFrame:aFrame];
    if (_viewTrackingRectTag != 0) {
        [self removeTokensTrackingRects];
        [self setupTrackingRectsForTokens];
        [self removeTrackingRect:_viewTrackingRectTag];
        _viewTrackingRectTag = (int)[self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
    }
    if ([[self window] firstResponder] != self) {
        [self updateTokenRects];
    }
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if (([self window] != nil) && (_viewTrackingRectTag != 0)) {
        [self removeTokensTrackingRects];
        [self removeTrackingRect:_viewTrackingRectTag];
        _viewTrackingRectTag = 0;
    }
    [super viewWillMoveToWindow:aWindow];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window] != nil) {
        _viewTrackingRectTag = (int)[self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
        [self setupTrackingRectsForTokens];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020ae44 @ 0020ae44, 655 bytes * /

void FUN_0020ae44(HSTokenTextView *self,SEL _cmd)

{
  undefined8 uVar1;
  int iVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  char cVar6;
  id self_00;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  int *piVar10;
  int *piVar11;
  int iVar12;
  undefined8 local_4c;
  undefined8 local_44;
  int local_3c;
  int local_38;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  self_00 = _objc_msgSend(self,sel_textStorage);
  pvVar7 = _objc_msgSend(self_00,sel_containsAttachments);
  if ((char)pvVar7 != '\0') {
    _objc_msgSend(self,sel_removeTokensTrackingRects);
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar7,sel_init);
    self->_tokensTrackingRectTags = pvVar7;
    pvVar7 = _objc_msgSend(self_00,sel_length);
    puVar4 = PTR_003367a8;
    puVar3 = PTR_00336078;
    if (0 < (int)pvVar7) {
      iVar12 = 0;
      piVar10 = (int *)&stack0xffffff74;
      do {
        local_3c = 0;
        local_38 = 0;
        iVar2 = *(int *)puVar4;
        piVar10[4] = (int)&local_3c;
        piVar10[3] = iVar12;
        piVar10[2] = iVar2;
        piVar10[1] = (int)sel_attribute_atIndex_effectiveRange_;
        *piVar10 = (int)self_00;
        piVar10[-1] = 0x20af32;
        pvVar8 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
        piVar10[1] = (int)sel_attachmentCell;
        *piVar10 = (int)pvVar8;
        piVar10[-1] = 0x20af44;
        pvVar8 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
        piVar10[1] = (int)sel_class;
        *piVar10 = (int)cls_HSTokenCell;
        piVar10[-1] = 0x20af5e;
        pvVar9 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
        piVar10[2] = (int)pvVar9;
        piVar10[1] = (int)sel_isKindOfClass_;
        *piVar10 = (int)pvVar8;
        piVar10[-1] = 0x20af74;
        pvVar8 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
        piVar11 = piVar10;
        if ((char)pvVar8 != '\0') {
          local_38 = 1;
          piVar10[3] = local_3c;
          piVar10[2] = (int)sel_frameForTokenCellAtRange_;
          piVar10[1] = (int)self;
          *piVar10 = (int)&local_4c;
          piVar10[4] = 1;
          piVar10[-1] = 0x20afae;
          _objc_msgSend_stret((void *)*piVar10,(id)piVar10[1],(SEL)piVar10[2]);
          piVar10[1] = (int)sel_frame;
          *piVar10 = (int)self;
          piVar10[-1] = (int)&local_34;
          piVar10[-2] = 0x20afca;
          _objc_msgSend_stret((void *)piVar10[-1],(id)*piVar10,(SEL)piVar10[1]);
          *(undefined8 *)(piVar10 + 5) = local_44;
          *(undefined8 *)(piVar10 + 3) = local_4c;
          *(undefined8 *)(piVar10 + 1) = local_2c;
          *(undefined8 *)(piVar10 + -1) = local_34;
          piVar10[-2] = (int)&local_24;
          piVar10[-3] = 0x20b004;
          _NSIntersectionRect();
          uVar1 = *(undefined8 *)puVar3;
          *(undefined8 *)(piVar10 + 3) = *(undefined8 *)(puVar3 + 8);
          *(undefined8 *)(piVar10 + 1) = uVar1;
          *(undefined8 *)(piVar10 + -1) = local_1c;
          *(undefined8 *)(piVar10 + -3) = local_24;
          piVar10[-4] = 0x20b039;
          cVar6 = _NSEqualRects();
          puVar5 = cls_NSNumber;
          piVar11 = piVar10 + -3;
          if (cVar6 == '\0') {
            pvVar8 = self->_tokensTrackingRectTags;
            *(undefined8 *)(piVar10 + 1) = local_44;
            *(undefined8 *)(piVar10 + -1) = local_4c;
            piVar10[3] = (int)self;
            piVar10[-2] = (int)sel_addTrackingRect_owner_userData_assumeInside_;
            piVar10[-3] = (int)self;
            piVar10[5] = 0;
            piVar10[4] = 0;
            piVar10[-4] = 0x20b087;
            pvVar9 = _objc_msgSend((id)piVar10[-3],(SEL)piVar10[-2]);
            piVar10[-1] = (int)pvVar9;
            piVar10[-2] = (int)sel_numberWithInt_;
            piVar10[-3] = (int)puVar5;
            piVar10[-4] = 0x20b09d;
            pvVar9 = _objc_msgSend((id)piVar10[-3],(SEL)piVar10[-2]);
            piVar10[-1] = (int)pvVar9;
            piVar10[-2] = (int)sel_addObject_;
            piVar10[-3] = (int)pvVar8;
            piVar10[-4] = 0x20b0b6;
            _objc_msgSend((id)piVar10[-3],(SEL)piVar10[-2]);
            piVar11 = piVar10 + -3;
          }
        }
        iVar2 = local_38 + iVar12;
        iVar12 = iVar12 + 1;
        if (local_38 != 0) {
          iVar12 = iVar2;
        }
        piVar10 = piVar11;
      } while (iVar12 < (int)pvVar7);
    }
  }
  return;
}

*/
- (void)setupTrackingRectsForTokens
{
    NSTextStorage *storage = [self textStorage];
    if (![storage containsAttachments]) {
        return;
    }
    [self removeTokensTrackingRects];
    _tokensTrackingRectTags = [[NSMutableArray alloc] init];
    NSInteger length = [storage length];
    NSInteger index = 0;
    while (index < length) {
        NSRange range = {0, 0};
        NSTextAttachment *attachment = [storage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
        if ([[attachment attachmentCell] isKindOfClass:[HSTokenCell class]]) {
            range.length = 1;
            NSRect tokenFrame = [self frameForTokenCellAtRange:range];
            /* Only tokens that are on screen get a tracking rect. */
            if (!NSEqualRects(NSIntersectionRect([self frame], tokenFrame), NSZeroRect)) {
                NSTrackingRectTag tag = [self addTrackingRect:tokenFrame owner:self userData:NULL assumeInside:NO];
                [_tokensTrackingRectTags addObject:[NSNumber numberWithInt:(int)tag]];
            }
        }
        index = range.length != 0 ? index + range.length : index + 1;
    }
}

- (void)removeTokensTrackingRects
{
    NSEnumerator *self_00;
    id pvVar1;

    self_00 = [_tokensTrackingRectTags objectEnumerator];
    while( YES ) {
        pvVar1 = [self_00 nextObject];
        if (pvVar1 == nil) break;
        [self removeTrackingRect:[pvVar1 intValue]];
    }
    [_tokensTrackingRectTags release];
    _tokensTrackingRectTags = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020b0d3 @ 0020b0d3, 284 bytes * /

NSRect * FUN_0020b0d3(NSRect *__return_storage_ptr__,HSTokenTextView *self,SEL _cmd,
                     NSRange frameForTokenCellAtRange)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float local_24;
  float local_20;
  
  self_00 = _objc_msgSend(self,sel_layoutManager);
  pvVar1 = _objc_msgSend(self_00,sel_glyphRangeForCharacterRange_actualCharacterRange_,
                         frameForTokenCellAtRange.location,frameForTokenCellAtRange.length,0);
  pvVar2 = _objc_msgSend(self_00,sel_locationForGlyphAtIndex_,pvVar1);
  pvVar3 = _objc_msgSend(self_00,sel_attachmentSizeForGlyphAtIndex_,pvVar1);
  pvVar4 = _objc_msgSend(self,sel_textContainerOrigin);
  _objc_msgSend_stret(&local_24,self_00,sel_lineFragmentRectForGlyphAtIndex_effectiveRange_,pvVar1,0
                     );
  (__return_storage_ptr__->origin).x = (float)pvVar4 + local_24 + (float)pvVar2;
  (__return_storage_ptr__->origin).y = (extraout_EDX - extraout_EDX_00) + extraout_EDX_01 + local_20
  ;
  (__return_storage_ptr__->size).width = (float)pvVar3;
  (__return_storage_ptr__->size).height = extraout_EDX_00;
  return __return_storage_ptr__;
}

*/
- (NSRect)frameForTokenCellAtRange:(NSRange)aRange
{
    NSLayoutManager *layoutManager = [self layoutManager];
    NSUInteger glyphIndex = [layoutManager glyphRangeForCharacterRange:aRange actualCharacterRange:NULL].location;
    NSPoint location = [layoutManager locationForGlyphAtIndex:glyphIndex];
    NSSize size = [layoutManager attachmentSizeForGlyphAtIndex:glyphIndex];
    NSPoint origin = [self textContainerOrigin];
    NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    /* The glyph location is the baseline; the attachment sits above it. */
    return NSMakeRect(origin.x + lineRect.origin.x + location.x, (location.y - size.height) + origin.y + lineRect.origin.y, size.width, size.height);
}

- (void)updateTokenRects
{
    [self removeTokensTrackingRects];
    [self setupTrackingRectsForTokens];
}

- (BOOL)resignFirstResponder
{
    BOOL pvVar1;

    pvVar1 = [super resignFirstResponder];
    if (pvVar1) {
        [self setupTrackingRectsForTokens];
    }
    return pvVar1;
}

- (BOOL)becomeFirstResponder
{
    BOOL pvVar1;

    pvVar1 = [super becomeFirstResponder];
    if (pvVar1) {
        [self removeTokensTrackingRects];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020b2a1 @ 0020b2a1, 993 bytes * /

void FUN_0020b2a1(HSTokenTextView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 *puVar4;
  undefined8 uVar5;
  undefined1 local_24 [20];
  
  _objc_msgSend(mouseDown,sel_locationInWindow);
  _objc_msgSend(self,sel_convertPoint_fromView_);
  pvVar1 = _objc_msgSend(self,sel_cellAtPoint_);
  puVar4 = (undefined4 *)&stack0xffffff94;
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_layoutManager);
    _objc_msgSend(self,sel_textContainer);
    _objc_msgSend(pvVar2,sel_glyphIndexForPoint_inTextContainer_);
    pvVar2 = _objc_msgSend(self,sel_layoutManager);
    _objc_msgSend(self,sel_textContainer);
    _objc_msgSend_stret(local_24,pvVar2,sel_boundingRectForGlyphRange_inTextContainer_);
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(mouseDown,sel_locationInWindow);
    _objc_msgSend(pvVar2,sel_convertBaseToScreen_);
    pvVar2 = _objc_msgSend(self,sel_characterIndexForPoint_);
    pvVar3 = _objc_msgSend(pvVar1,sel_activateMenuForEvent_cellFrame_controlView_);
    if ((char)pvVar3 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_delegate);
      pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(self,sel_delegate);
        _objc_msgSend(pvVar2,sel_tokenTextView_didPopUpCell_);
      }
      pvVar2 = _objc_msgSend(self,sel_layoutManager);
      _objc_msgSend(pvVar1,sel_cellSize);
      _objc_msgSend(pvVar2,sel_setAttachmentSize_forGlyphRange_);
      pvVar1 = _objc_msgSend(self,sel_layoutManager);
      pvVar2 = _objc_msgSend(self,sel_textStorage);
      _objc_msgSend(pvVar2,sel_length);
      _objc_msgSend(pvVar1,sel_invalidateLayoutForCharacterRange_isSoft_actualCharacterRange_);
      _objc_msgSend(self,sel_setNeedsDisplay_);
      return;
    }
    _objc_msgSend(self,sel_selectedRange);
    uVar5 = _NSIntersectionRange();
    if (((id)uVar5 != pvVar2) ||
       (puVar4 = (undefined4 *)&stack0xffffff90, (int)((ulonglong)uVar5 >> 0x20) != 1)) {
      _objc_msgSend(self,sel_setSelectedRange_);
      puVar4 = (undefined4 *)&stack0xffffff90;
    }
  }
  puVar4[-1] = 0x20b652;
  _objc_msgSendSuper((void *)*puVar4,(SEL)puVar4[1]);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    HSTokenCell *cell = [self cellAtPoint:point];
    if (cell != nil) {
        NSUInteger glyphIndex = [[self layoutManager] glyphIndexForPoint:point inTextContainer:[self textContainer]];
        NSRect cellFrame = [[self layoutManager] boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:[self textContainer]];
        NSUInteger index = [self characterIndexForPoint:[[self window] convertPointToScreen:[aDown locationInWindow]]];
        if ([cell activateMenuForEvent:aDown cellFrame:cellFrame controlView:self]) {
            if ([[self delegate] respondsToSelector:@selector(tokenTextView:didPopUpCell:)]) {
                [(id)[self delegate] tokenTextView:self didPopUpCell:cell];
            }
            /* The chosen menu item may change the token's size. */
            [[self layoutManager] setAttachmentSize:[cell cellSize] forGlyphRange:NSMakeRange(glyphIndex, 1)];
            [[self layoutManager] invalidateLayoutForCharacterRange:NSMakeRange(0, [[self textStorage] length]) isSoft:NO actualCharacterRange:NULL];
            [self setNeedsDisplay:YES];
            return;
        }
        NSRange tokenRange = NSMakeRange(index, 1);
        NSRange intersection = NSIntersectionRange(tokenRange, [self selectedRange]);
        if (intersection.location != index || intersection.length != 1) {
            [self setSelectedRange:tokenRange];
        }
    }
    [super mouseDown:aDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020b682 @ 0020b682, 391 bytes * /

void FUN_0020b682(HSTokenTextView *self,SEL _cmd,id mouseMoved)

{
  id pvVar1;
  id self_00;
  undefined *self_01;
  SEL op;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  HSTokenTextView *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSPlaceholderTextView_00354a10;
  _objc_msgSendSuper(&local_1c,sel_mouseMoved_,mouseMoved);
  pvVar1 = _objc_msgSend(mouseMoved,sel_locationInWindow);
  uVar4 = 0;
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  uVar3 = extraout_EDX_00;
  self_00 = _objc_msgSend(self,sel_cellAtPoint_,pvVar1,extraout_EDX_00);
  pvVar1 = self->_lastHighlighted;
  if (self_00 == (id)0x0) {
    if (pvVar1 == (id)0x0) goto LAB_0020b7e7;
    uVar2 = 0;
    _objc_msgSend(pvVar1,sel_setHighlighted_,0,uVar3,uVar4);
    _objc_msgSend(self->_lastHighlighted,sel_release);
    self->_lastHighlighted = (id)0x0;
    self_01 = cls_HSCursor;
    op = sel_clearCursor;
  }
  else {
    _objc_msgSend(pvVar1,sel_setHighlighted_,0,uVar3,uVar4);
    uVar2 = 1;
    _objc_msgSend(self_00,sel_setHighlighted_,1);
    _objc_msgSend(self->_lastHighlighted,sel_release);
    pvVar1 = _objc_msgSend(self_00,sel_retain);
    self->_lastHighlighted = pvVar1;
    self_01 = _objc_msgSend(cls_HSCursor,sel_defaultCursor);
    op = sel_set;
  }
  _objc_msgSend(self_01,op,uVar2,uVar3);
LAB_0020b7e7:
  _objc_msgSend(self,sel_setNeedsDisplay_,1,uVar3,uVar4);
  return;
}

*/
- (void)mouseMoved:(id)aMoved
{
    [super mouseMoved:aMoved];
    HSTokenCell *cell = [self cellAtPoint:[self convertPoint:[aMoved locationInWindow] fromView:nil]];
    if (cell == nil) {
        if (_lastHighlighted == nil) {
            [self setNeedsDisplay:YES];
            return;
        }
        [_lastHighlighted setHighlighted:NO];
        [_lastHighlighted release];
        _lastHighlighted = nil;
        [HSCursor clearCursor];
    } else {
        [_lastHighlighted setHighlighted:NO];
        [cell setHighlighted:YES];
        [_lastHighlighted release];
        _lastHighlighted = [cell retain];
        [(HSCursor *)[HSCursor defaultCursor] set];
    }
    [self setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020b809 @ 0020b809, 294 bytes * /

void FUN_0020b809(HSTokenTextView *self,SEL _cmd,id mouseExited)

{
  int iVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar3;
  undefined4 uVar4;
  HSTokenTextView *local_14;
  undefined *local_10;
  
  iVar1 = self->_mouseEnteredCount + -1;
  self->_mouseEnteredCount = iVar1;
  if (iVar1 < 1) {
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_setAcceptsMouseMovedEvents_,0);
    self->_mouseEnteredCount = 0;
  }
  pvVar2 = _objc_msgSend(mouseExited,sel_locationInWindow);
  uVar4 = 0;
  pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  uVar3 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(self,sel_cellAtPoint_,pvVar2,extraout_EDX_00);
  if (pvVar2 == (id)0x0) {
    _objc_msgSend(self->_lastHighlighted,sel_setHighlighted_,0,uVar3,uVar4);
    _objc_msgSend(self->_lastHighlighted,sel_release);
    self->_lastHighlighted = (id)0x0;
    _objc_msgSend(self,sel_setNeedsDisplay_,1);
  }
  local_14 = self;
  local_10 = PTR_s_HSPlaceholderTextView_00354a10;
  _objc_msgSendSuper(&local_14,sel_mouseExited_,mouseExited);
  return;
}

*/
- (void)mouseExited:(id)aExited
{
    _mouseEnteredCount = _mouseEnteredCount - 1;
    if (_mouseEnteredCount < 1) {
        [[self window] setAcceptsMouseMovedEvents:NO];
        _mouseEnteredCount = 0;
    }
    if ([self cellAtPoint:[self convertPoint:[aExited locationInWindow] fromView:nil]] == nil) {
        [_lastHighlighted setHighlighted:NO];
        [_lastHighlighted release];
        _lastHighlighted = nil;
        [self setNeedsDisplay:YES];
    }
    [super mouseExited:aExited];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020b92f @ 0020b92f, 373 bytes * /

void FUN_0020b92f(HSTokenTextView *self,SEL _cmd,id mouseEntered)

{
  int iVar1;
  id pvVar2;
  HSTokenTextView *pHVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar4;
  undefined4 uVar5;
  HSTokenTextView *local_1c;
  undefined *local_18;
  
  iVar1 = self->_mouseEnteredCount;
  self->_mouseEnteredCount = iVar1 + 1;
  if (iVar1 == 0) {
    pvVar2 = _objc_msgSend(self,sel_window);
    pHVar3 = _objc_msgSend(pvVar2,sel_firstResponder);
    if (pHVar3 == self) {
      pvVar2 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar2,sel_setAcceptsMouseMovedEvents_,1);
    }
  }
  pvVar2 = _objc_msgSend(mouseEntered,sel_locationInWindow);
  uVar5 = 0;
  pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  uVar4 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(self,sel_cellAtPoint_,pvVar2,extraout_EDX_00);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self->_lastHighlighted,sel_setHighlighted_,0,uVar4,uVar5);
    _objc_msgSend(self->_lastHighlighted,sel_release);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_lastHighlighted = pvVar2;
    _objc_msgSend(pvVar2,sel_setHighlighted_,1);
    _objc_msgSend(self,sel_setNeedsDisplay_,1);
  }
  local_1c = self;
  local_18 = PTR_s_HSPlaceholderTextView_00354a10;
  _objc_msgSendSuper(&local_1c,sel_mouseEntered_,mouseEntered);
  return;
}

*/
- (void)mouseEntered:(id)aEntered
{
    if (_mouseEnteredCount++ == 0 && [[self window] firstResponder] == self) {
        [[self window] setAcceptsMouseMovedEvents:YES];
    }
    HSTokenCell *cell = [self cellAtPoint:[self convertPoint:[aEntered locationInWindow] fromView:nil]];
    if (cell != nil) {
        [_lastHighlighted setHighlighted:NO];
        [_lastHighlighted release];
        _lastHighlighted = [cell retain];
        [cell setHighlighted:YES];
        [self setNeedsDisplay:YES];
    }
    [super mouseEntered:aEntered];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020baa4 @ 0020baa4, 135 bytes * /

id FUN_0020baa4(HSTokenTextView *self,SEL _cmd,id preferredPasteboardTypeFromArray,
               id restrictedToTypesFromArray)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  HSTokenTextView *local_1c;
  undefined *local_18;
  
  pcVar2 = &cfstr_HSTokenStringPasteboardType;
  pvVar1 = _objc_msgSend(preferredPasteboardTypeFromArray,sel_containsObject_,
                         &cfstr_HSTokenStringPasteboardType);
  if (((char)pvVar1 == '\0') ||
     (pvVar1 = _objc_msgSend(preferredPasteboardTypeFromArray,sel_containsObject_,
                             &cfstr_HSTokenStringPasteboardType), (char)pvVar1 == '\0')) {
    local_1c = self;
    local_18 = PTR_s_HSPlaceholderTextView_00354a10;
    pcVar2 = _objc_msgSendSuper(&local_1c,
                                sel_preferredPasteboardTypeFromArray_restrictedToTypesFromArray_,
                                preferredPasteboardTypeFromArray,restrictedToTypesFromArray);
  }
  return pcVar2;
}

*/
- (id)preferredPasteboardTypeFromArray:(id)aArray restrictedToTypesFromArray:(id)aArray2
{
    /* The original tested the first array twice; honour the restriction list (nil means none). */
    if ([aArray containsObject:@"HSTokenStringPasteboardType"] && (aArray2 == nil || [aArray2 containsObject:@"HSTokenStringPasteboardType"])) {
        return @"HSTokenStringPasteboardType";
    }
    return [super preferredPasteboardTypeFromArray:aArray restrictedToTypesFromArray:aArray2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020bb2b @ 0020bb2b, 636 bytes * /

BOOL FUN_0020bb2b(HSTokenTextView *self,SEL _cmd,id readSelectionFromPasteboard,id type)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  HSTokenTextView *pHVar4;
  BOOL BVar5;
  HSTokenTextView *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_PTR_00336848;
  pvVar2 = _objc_msgSend(type,sel_isEqualToString_,*(undefined4 *)PTR_PTR_00336848);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(type,sel_isEqualToString_,&cfstr_HSTokenStringPasteboardType);
    puVar1 = cls_NSKeyedUnarchiver;
    if ((char)pvVar2 == '\0') {
      local_1c = self;
      local_18 = PTR_s_HSPlaceholderTextView_00354a10;
      pvVar2 = _objc_msgSendSuper(&local_1c,sel_readSelectionFromPasteboard_type_,
                                  readSelectionFromPasteboard,type);
      BVar5 = (BOOL)pvVar2;
    }
    else {
      pvVar2 = _objc_msgSend(readSelectionFromPasteboard,sel_dataForType_,
                             &cfstr_HSTokenStringPasteboardType);
      readSelectionFromPasteboard = _objc_msgSend(puVar1,sel_unarchiveObjectWithData_,pvVar2);
      if (readSelectionFromPasteboard == (id)0x0) {
        BVar5 = '\0';
        readSelectionFromPasteboard = pvVar2;
      }
      else {
        _objc_msgSend(self,sel_insertText_,readSelectionFromPasteboard);
        BVar5 = '\x01';
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(readSelectionFromPasteboard,sel_dataForType_,*(undefined4 *)puVar1);
    pvVar3 = _objc_msgSend(cls_NSKeyedUnarchiver,sel_unarchiveObjectWithData_,pvVar2);
    BVar5 = pvVar3 != (id)0x0;
    if ((bool)BVar5) {
      pvVar2 = _objc_msgSend(cls_NSTextAttachment,sel_alloc,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithFileWrapper_,0);
      _objc_msgSend(pvVar2,sel_setAttachmentCell_,pvVar3);
      _objc_msgSend(pvVar3,sel_setCanChangeHighlight_,1);
      _objc_msgSend(pvVar3,sel_setHighlighted_,0);
      _objc_msgSend(pvVar3,sel_setAutosize_,1);
      pvVar3 = _objc_msgSend(cls_NSAttributedString,sel_attributedStringWithAttachment_,pvVar2);
      _objc_msgSend(self,sel_insertText_,pvVar3);
      _objc_msgSend(pvVar2,sel_release);
    }
    readSelectionFromPasteboard = (id)0x1;
    _objc_msgSend(self,sel_setNeedsDisplay_,1);
  }
  pvVar2 = _objc_msgSend(self,sel_window,readSelectionFromPasteboard);
  pHVar4 = _objc_msgSend(pvVar2,sel_firstResponder);
  if (pHVar4 != self) {
    _objc_msgSend(self,sel_updateTokenRects,readSelectionFromPasteboard);
  }
  return BVar5;
}

*/
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard type:(id)aType
{
    BOOL didRead;
    if ([aType isEqualToString:@"HSTokenCellPasteboardType"]) {
        id cell = [NSKeyedUnarchiver unarchiveObjectWithData:[aPasteboard dataForType:@"HSTokenCellPasteboardType"]];
        didRead = cell != nil;
        if (didRead) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
            [attachment setAttachmentCell:cell];
            [cell setCanChangeHighlight:YES];
            [cell setHighlighted:NO];
            [cell setAutosize:YES];
            [self insertText:[NSAttributedString attributedStringWithAttachment:attachment]];
            [attachment release];
        }
        [self setNeedsDisplay:YES];
    } else if ([aType isEqualToString:@"HSTokenStringPasteboardType"]) {
        id string = [NSKeyedUnarchiver unarchiveObjectWithData:[aPasteboard dataForType:@"HSTokenStringPasteboardType"]];
        didRead = string != nil;
        if (didRead) {
            [self insertText:string];
        }
    } else {
        didRead = [super readSelectionFromPasteboard:aPasteboard type:aType];
    }
    if ([[self window] firstResponder] != self) {
        [self updateTokenRects];
    }
    return didRead;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020bda7 @ 0020bda7, 499 bytes * /

BOOL FUN_0020bda7(HSTokenTextView *self,SEL _cmd,id writeSelectionToPasteboard,id type)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar5;
  SEL pcVar6;
  cfstringStruct *pcVar7;
  HSTokenTextView *local_1c;
  undefined *local_18;
  
  pvVar3 = _objc_msgSend(self,sel_selectedRange);
  pcVar5 = &cfstr_HSTokenStringPasteboardType;
  pcVar7 = pcVar5;
  pvVar4 = _objc_msgSend(type,sel_isEqualToString_,&cfstr_HSTokenStringPasteboardType);
  puVar2 = cls_NSKeyedArchiver;
  puVar1 = PTR_003361bc;
  if ((char)pvVar4 == '\0') {
    pvVar4 = _objc_msgSend(type,sel_isEqualToString_,*(undefined4 *)PTR_003361bc);
    puVar2 = PTR_003367b4;
    if ((char)pvVar4 == '\0') {
      pvVar4 = _objc_msgSend(type,sel_isEqualToString_,*(undefined4 *)PTR_003367b4);
      puVar1 = PTR_003367b8;
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(type,sel_isEqualToString_,*(undefined4 *)PTR_003367b8);
        if ((char)pvVar4 == '\0') {
          local_1c = self;
          local_18 = PTR_s_HSPlaceholderTextView_00354a10;
          pvVar3 = _objc_msgSendSuper(&local_1c,sel_writeSelectionToPasteboard_type_,
                                      writeSelectionToPasteboard,type);
          return (BOOL)pvVar3;
        }
        pcVar5 = *(cfstringStruct **)puVar1;
        pcVar6 = sel_RTFFromRange_;
      }
      else {
        pcVar5 = *(cfstringStruct **)puVar2;
        pcVar6 = sel_RTFDFromRange_;
      }
      pvVar3 = _objc_msgSend(self,pcVar6,pvVar3,extraout_EDX);
      pcVar6 = sel_setData_forType_;
    }
    else {
      pcVar5 = *(cfstringStruct **)puVar1;
      pvVar3 = _objc_msgSend(self,sel_stringRepresentationForRange_,pvVar3,extraout_EDX);
      pcVar6 = sel_setString_forType_;
    }
  }
  else {
    pvVar4 = _objc_msgSend(self,sel_textStorage,pcVar7);
    pvVar3 = _objc_msgSend(pvVar4,sel_attributedSubstringFromRange_,pvVar3,extraout_EDX);
    pvVar3 = _objc_msgSend(puVar2,sel_archivedDataWithRootObject_,pvVar3);
    pcVar6 = sel_setData_forType_;
  }
  _objc_msgSend(writeSelectionToPasteboard,pcVar6,pvVar3,pcVar5);
  return '\x01';
}

*/
- (BOOL)writeSelectionToPasteboard:(id)aPasteboard type:(id)aType
{
    NSRange range = [self selectedRange];
    if ([aType isEqualToString:@"HSTokenStringPasteboardType"]) {
        [aPasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:[[self textStorage] attributedSubstringFromRange:range]] forType:@"HSTokenStringPasteboardType"];
    } else if ([aType isEqualToString:NSStringPboardType]) {
        [aPasteboard setString:[self stringRepresentationForRange:range] forType:NSStringPboardType];
    } else if ([aType isEqualToString:NSRTFDPboardType]) {
        [aPasteboard setData:[self RTFDFromRange:range] forType:NSRTFDPboardType];
    } else if ([aType isEqualToString:NSRTFPboardType]) {
        [aPasteboard setData:[self RTFFromRange:range] forType:NSRTFPboardType];
    } else {
        return [super writeSelectionToPasteboard:aPasteboard type:aType];
    }
    return YES;
}

- (id)writablePasteboardTypes
{
    return [[super writablePasteboardTypes] arrayByAddingObject:@"HSTokenStringPasteboardType"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020bfed @ 0020bfed, 139 bytes * /

id FUN_0020bfed(HSTokenTextView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSTokenTextView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSPlaceholderTextView_00354a10;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_acceptableDragTypes);
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_PTR_00336848,
                         &cfstr_HSTokenStringPasteboardType,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_arrayByAddingObjectsFromArray_,pvVar2);
  return pvVar1;
}

*/
- (id)acceptableDragTypes
{
    return [[super acceptableDragTypes] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"HSTokenCellPasteboardType", @"HSTokenStringPasteboardType", nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020c078 @ 0020c078, 139 bytes * /

id FUN_0020c078(HSTokenTextView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSTokenTextView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSPlaceholderTextView_00354a10;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_readablePasteboardTypes);
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_PTR_00336848,
                         &cfstr_HSTokenStringPasteboardType,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_arrayByAddingObjectsFromArray_,pvVar2);
  return pvVar1;
}

*/
- (id)readablePasteboardTypes
{
    return [[super readablePasteboardTypes] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"HSTokenCellPasteboardType", @"HSTokenStringPasteboardType", nil]];
}

- (void)setTextContainer:(id)aContainer
{
    [super setTextContainer:aContainer];
    [[self textStorage] setDelegate:self];
    [self updateTextStorage];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020a37d @ 0020a37d, 114 bytes * /

id FUN_0020a37d(HSTokenTextView *self,SEL _cmd,NSRange RTFDFromRange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_attributedStringRepresentationForRange_,RTFDFromRange.location,
                         RTFDFromRange.length);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  pvVar1 = _objc_msgSend(pvVar1,sel_RTFDFromRange_documentAttributes_,0,pvVar2,0);
  return pvVar1;
}

*/
- (id)RTFDFromRange:(NSRange)aRange
{
    NSAttributedString *string = [self attributedStringRepresentationForRange:aRange];
    return [string RTFDFromRange:NSMakeRange(0, [string length]) documentAttributes:[NSDictionary dictionary]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020a30b @ 0020a30b, 114 bytes * /

id FUN_0020a30b(HSTokenTextView *self,SEL _cmd,NSRange RTFFromRange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_attributedStringRepresentationForRange_,RTFFromRange.location,
                         RTFFromRange.length);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  pvVar1 = _objc_msgSend(pvVar1,sel_RTFFromRange_documentAttributes_,0,pvVar2,0);
  return pvVar1;
}

*/
- (id)RTFFromRange:(NSRange)aRange
{
    NSAttributedString *string = [self attributedStringRepresentationForRange:aRange];
    return [string RTFFromRange:NSMakeRange(0, [string length]) documentAttributes:[NSDictionary dictionary]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020a0f1 @ 0020a0f1, 538 bytes * /

id FUN_0020a0f1(HSTokenTextView *self,SEL _cmd,NSRange attributedStringRepresentationForRange)

{
  id pvVar1;
  undefined *puVar2;
  undefined *self_00;
  id self_01;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  SEL op;
  id *ppvVar9;
  id local_1c;
  id local_18;
  
  local_1c = (id)attributedStringRepresentationForRange.location;
  local_18 = (id)attributedStringRepresentationForRange.length;
  self_01 = _objc_msgSend(self,sel_textStorage);
  pvVar3 = _objc_msgSend(self_01,sel_containsAttachments);
  if ((char)pvVar3 == '\0') {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSMutableAttributedString,sel_new);
    pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
    puVar2 = PTR_003367a8;
    pvVar8 = (id)((int)local_18 + (int)local_1c);
    pvVar1 = local_1c;
    while (pvVar1 < pvVar8) {
      ppvVar9 = &local_1c;
      pvVar7 = pvVar1;
      pvVar4 = _objc_msgSend(self_01,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)puVar2,
                             pvVar1,ppvVar9);
      pvVar5 = _objc_msgSend(pvVar4,sel_attachmentCell);
      pvVar6 = _objc_msgSend(cls_HSTokenCell,sel_class);
      pvVar5 = _objc_msgSend(pvVar5,sel_isKindOfClass_,pvVar6);
      if ((char)pvVar5 == '\0') {
        if (local_1c < pvVar1) {
          local_18 = (id)(((int)local_1c - (int)pvVar1) + (int)local_18);
          local_1c = pvVar1;
        }
        pvVar7 = self_01;
        op = sel_attributedSubstringFromRange_;
        pvVar4 = local_1c;
        pvVar5 = local_18;
        if (pvVar8 < (id)((int)local_18 + (int)local_1c)) {
          pvVar5 = (id)((int)pvVar8 - (int)local_1c);
          local_18 = pvVar5;
        }
      }
      else {
        pvVar7 = _objc_msgSend(pvVar4,sel_attachmentCell,pvVar6,pvVar7,ppvVar9);
        self_00 = cls_NSString;
        pvVar5 = _objc_msgSend(pvVar7,sel_title);
        pvVar4 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr_____,pvVar5);
        pvVar7 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
        pvVar7 = _objc_msgSend(pvVar7,sel_initWithString_,pvVar4);
        op = sel_autorelease;
      }
      pvVar7 = _objc_msgSend(pvVar7,op,pvVar4,pvVar5);
      _objc_msgSend(pvVar3,sel_appendAttributedString_,pvVar7);
      pvVar7 = (id)((int)local_18 + (int)pvVar1);
      pvVar1 = (id)((int)pvVar1 + 1);
      if (local_18 != (id)0x0) {
        pvVar1 = pvVar7;
      }
    }
  }
  return pvVar3;
}

*/
- (id)attributedStringRepresentationForRange:(NSRange)aRange
{
    NSTextStorage *storage = [self textStorage];
    if (![storage containsAttachments]) {
        /* The original returned nil here, which dropped plain text on copy. */
        return [storage attributedSubstringFromRange:aRange];
    }
    NSMutableAttributedString *result = [[NSMutableAttributedString new] autorelease];
    NSUInteger end = NSMaxRange(aRange);
    NSUInteger index = aRange.location;
    /* Tokens become "{title}"; everything else is copied as is. */
    while (index < end) {
        NSRange range = {0, 0};
        NSTextAttachment *attachment = [storage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
        if ([[attachment attachmentCell] isKindOfClass:[HSTokenCell class]]) {
            NSString *title = [NSString stringWithFormat:@"{%@}", [(HSTokenCell *)[attachment attachmentCell] title]];
            [result appendAttributedString:[[[NSAttributedString alloc] initWithString:title] autorelease]];
        } else {
            range = NSIntersectionRange(range, NSMakeRange(index, end - index));
            [result appendAttributedString:[storage attributedSubstringFromRange:range]];
        }
        index = range.length != 0 ? NSMaxRange(range) : index + 1;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00209ef9 @ 00209ef9, 504 bytes * /

id FUN_00209ef9(HSTokenTextView *self,SEL _cmd,NSRange stringRepresentationForRange)

{
  cfstringStruct *pcVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined *self_00;
  cfstringStruct *pcVar8;
  SEL op;
  cfstringStruct *pcVar9;
  cfstringStruct **ppcVar10;
  cfstringStruct *local_1c;
  id local_18;
  
  local_1c = (cfstringStruct *)stringRepresentationForRange.location;
  local_18 = (id)stringRepresentationForRange.length;
  pvVar3 = _objc_msgSend(self,sel_textStorage);
  pvVar4 = _objc_msgSend(pvVar3,sel_containsAttachments);
  if ((char)pvVar4 == '\0') {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar4 = _objc_msgSend(cls_NSMutableString,sel_string);
    puVar2 = PTR_003367a8;
    pcVar8 = (cfstringStruct *)((int)local_18 + (int)local_1c);
    pcVar1 = local_1c;
    while (pcVar1 < pcVar8) {
      ppcVar10 = &local_1c;
      pcVar9 = pcVar1;
      pvVar5 = _objc_msgSend(pvVar3,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)puVar2,
                             pcVar1,ppcVar10);
      pvVar6 = _objc_msgSend(pvVar5,sel_attachmentCell);
      pvVar7 = _objc_msgSend(cls_HSTokenCell,sel_class);
      pvVar6 = _objc_msgSend(pvVar6,sel_isKindOfClass_,pvVar7);
      if ((char)pvVar6 == '\0') {
        if (local_1c < pcVar1) {
          local_18 = (id)(((int)local_1c - (int)pcVar1) + (int)local_18);
          local_1c = pcVar1;
        }
        if (pcVar8 < (cfstringStruct *)((int)local_18 + (int)local_1c)) {
          local_18 = (id)((int)pcVar8 - (int)local_1c);
        }
        self_00 = _objc_msgSend(pvVar3,sel_string,pvVar7,pcVar9,ppcVar10);
        op = sel_substringWithRange_;
        pcVar9 = local_1c;
        pvVar5 = local_18;
      }
      else {
        pvVar5 = _objc_msgSend(pvVar5,sel_attachmentCell,pvVar7,pcVar9,ppcVar10);
        self_00 = cls_NSString;
        pvVar5 = _objc_msgSend(pvVar5,sel_title);
        op = sel_stringWithFormat_;
        pcVar9 = &cfstr_____;
      }
      pvVar5 = _objc_msgSend(self_00,op,pcVar9,pvVar5);
      _objc_msgSend(pvVar4,sel_appendString_,pvVar5);
      pcVar9 = (cfstringStruct *)((int)local_18 + (int)pcVar1);
      pcVar1 = (cfstringStruct *)((int)&pcVar1->field0_0x0 + 1);
      if (local_18 != (id)0x0) {
        pcVar1 = pcVar9;
      }
    }
    pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithString_,pvVar4);
  }
  return pvVar3;
}

*/
- (id)stringRepresentationForRange:(NSRange)aRange
{
    NSTextStorage *storage = [self textStorage];
    if (![storage containsAttachments]) {
        /* The original returned nil here, which dropped plain text on copy. */
        return [[storage string] substringWithRange:aRange];
    }
    NSMutableString *result = [NSMutableString string];
    NSUInteger end = NSMaxRange(aRange);
    NSUInteger index = aRange.location;
    while (index < end) {
        NSRange range = {0, 0};
        NSTextAttachment *attachment = [storage attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
        if ([[attachment attachmentCell] isKindOfClass:[HSTokenCell class]]) {
            [result appendString:[NSString stringWithFormat:@"{%@}", [(HSTokenCell *)[attachment attachmentCell] title]]];
        } else {
            range = NSIntersectionRange(range, NSMakeRange(index, end - index));
            [result appendString:[[storage string] substringWithRange:range]];
        }
        index = range.length != 0 ? NSMaxRange(range) : index + 1;
    }
    return [NSString stringWithString:result];
}

- (void)dealloc
{
    NSTextStorage *pvVar1;

    [_lastHighlighted release];
    [_tokensTrackingRectTags release];
    [self removeTokensTrackingRects];
    pvVar1 = [self textStorage];
    if ([pvVar1 delegate] == self) {
        pvVar1 = [self textStorage];
        [pvVar1 setDelegate:0];
    }
    [super dealloc];
}

@end

