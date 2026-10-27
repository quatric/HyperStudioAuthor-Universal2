#import "HSMediaStripView.h"

// Shared text system used to measure and draw item labels.
static NSLayoutManager *HSMediaStripLabelLayoutManager(NSString *aLabel, CGFloat aWidth, NSRange *aGlyphRange)
{
    static NSLayoutManager *layoutManager = nil;
    NSTextStorage *textStorage;
    NSTextContainer *textContainer;
    NSString *label;

    if (layoutManager == nil) {
        textStorage = [[NSTextStorage alloc] initWithString:@" "];
        [textStorage addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize] - 2.0] range:NSMakeRange(0, 1)];
        [textStorage setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, 1)];
        layoutManager = [NSLayoutManager new];
        textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(10000.0, 10000.0)];
        [textContainer setHeightTracksTextView:YES];
        [textContainer setWidthTracksTextView:NO];
        [textContainer setLineFragmentPadding:2.0];
        [layoutManager addTextContainer:textContainer];
        [textContainer release];
        [textStorage addLayoutManager:layoutManager];
        // The text storage owns the layout manager from here on.
        [layoutManager release];
    }
    textStorage = [layoutManager textStorage];
    textContainer = [[layoutManager textContainers] objectAtIndex:0];
    label = [aLabel length] != 0 ? aLabel : @" ";
    if (![[textStorage string] isEqualToString:label]) {
        [textStorage replaceCharactersInRange:NSMakeRange(0, [textStorage length]) withString:label];
    }
    *aGlyphRange = [layoutManager glyphRangeForCharacterRange:NSMakeRange(0, [textStorage length]) actualCharacterRange:NULL];
    [textContainer setContainerSize:NSMakeSize(aWidth, 10000.0)];
    return layoutManager;
}

static void HSMediaStripDrawLabel(NSString *aLabel, NSRect aRect, BOOL aSelected, BOOL aFirstResponder)
{
    NSLayoutManager *layoutManager;
    NSTextStorage *textStorage;
    NSUInteger length;
    NSRange glyphRange;
    NSColor *currentColor;
    NSColor *color;

    glyphRange = NSMakeRange(0, 0);
    layoutManager = HSMediaStripLabelLayoutManager(aLabel != nil ? aLabel : @"", aRect.size.width, &glyphRange);
    textStorage = [layoutManager textStorage];
    length = [textStorage length];
    currentColor = [textStorage attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
    color = [HSMediaStripView textColorSelected:aSelected firstResponder:aFirstResponder];
    if (color != currentColor) {
        if (color == nil) {
            [textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, length)];
        }
        else {
            [textStorage addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, length)];
        }
    }
    [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:aRect.origin];
}

@implementation HSMediaStripView

/* i386 ivar offsets: _dataSource=0x50, _delegate=0x54, _geometryCache=0x58, _baseWidthForCachedGeometry=0x5c, _itemsCache=0x60, _itemsCacheValidator=0x64, _stripWidth=0x68, _numberOfItems=0x6c, _selectedItemIndex=0x70, _activeItemIndex=0x74, _shadow=0x78, _msFlags=0x7c, _draggingInfo=0x80, _animation=0x84 */

- (id)itemsEnumeratorForAnimation:(id)aAnimation
{
    return [_geometryCache objectEnumerator];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00057d01 @ 00057d01, 174 bytes * /

id FUN_00057d01(HSMediaStripView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = (id)_NSClassFromString(&cfstr_HSMediaStripAnimation);
  pvVar1 = _objc_msgSend(pvVar1,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithDataSource_duration_,self,0x33333333,0x3fd33333);
  _objc_msgSend(pvVar1,sel_setFrameRate_,0x42480000);
  _objc_msgSend(pvVar1,sel_setAnimationBlockingMode_,1);
  _objc_msgSend(pvVar1,sel_setDelegate_,self);
  return pvVar1;
}

*/
- (id)newAnimation
{
    NSAnimation *animation;

    animation = [[NSClassFromString(@"HSMediaStripAnimation") alloc] initWithDataSource:self duration:0.3];
    [animation setFrameRate:50.0];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [animation setDelegate:self];
    return animation;
}

- (id)accessibilityFocusedUIElement
{
    return self;
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (BOOL)accessibilityIsAttributeSettable:(id)aSettable
{
    BOOL pvVar1;

    pvVar1 = [aSettable isEqualToString:NSAccessibilityTitleAttribute];
    if ((((!pvVar1) && (pvVar1 = [aSettable isEqualToString:NSAccessibilityHelpAttribute], !pvVar1)) && (pvVar1 = [aSettable isEqualToString:NSAccessibilityChildrenAttribute], !pvVar1)) && (pvVar1 = [aSettable isEqualToString:NSAccessibilityVisibleChildrenAttribute], !pvVar1)) {
        pvVar1 = [super accessibilityIsAttributeSettable:aSettable];
        return (BOOL)pvVar1;
    }
    return NO;
}

- (void)accessibilityPerformAction:(id)aAction
{
    if ([aAction isEqualToString:NSAccessibilityPressAction]) {
        if ([[self delegate] respondsToSelector:@selector(mediaStripToggleCardIndex:)]) {
            [[self delegate] mediaStripToggleCardIndex:self];
        }
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

/* --- i386 decompilation (Ghidra) ---
/* FUN_00057fd0 @ 00057fd0, 237 bytes * /

id FUN_00057fd0(HSMediaStripView *self,SEL _cmd,NSPoint accessibilityHitTest)

{
  id pvVar1;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  if (pvVar1 == (id)0x0) {
    pvVar1 = *(id *)PTR_00336074;
    uVar2 = *(undefined4 *)(PTR_00336074 + 4);
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_window);
    pvVar1 = _objc_msgSend(pvVar1,sel_convertScreenToBase_,accessibilityHitTest.x,
                           accessibilityHitTest.y);
    uVar2 = extraout_EDX;
  }
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,uVar2,0);
  pvVar1 = _objc_msgSend(self,sel_indexOfItemAtPoint_,pvVar1,extraout_EDX_00);
  self_00 = _objc_msgSend(self,sel_geometryCache);
  pvVar1 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar1);
  return pvVar1;
}

*/
- (id)accessibilityHitTest:(NSPoint)aTest
{
    NSPoint point;

    if ([self window] == nil) {
        point = NSZeroPoint;
    }
    else {
        point = [[self window] convertScreenToBase:aTest];
    }
    point = [self convertPoint:point fromView:nil];
    return [[self geometryCache] objectAtIndex:[self indexOfItemAtPoint:point]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000580bd @ 000580bd, 472 bytes * /

id FUN_000580bd(HSMediaStripView *self,SEL _cmd,id accessibilityAttributeValue)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  undefined4 uVar3;
  HSMediaStripView *local_1c;
  undefined *local_18;
  
  pcVar2 = *(cfstringStruct **)PTR_00336384;
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,pcVar2);
  op = sel_geometryCache;
  if ((char)pvVar1 == '\0') {
    pcVar2 = *(cfstringStruct **)PTR_0033638c;
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,pcVar2);
    op = sel_geometryCache;
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,
                             *(undefined4 *)PTR_00336370);
      if ((char)pvVar1 != '\0') {
        return *(id *)PTR_00336388;
      }
      uVar3 = *(undefined4 *)PTR_00336374;
      pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
      if ((char)pvVar1 == '\0') {
        uVar3 = *(undefined4 *)PTR_0033637c;
        pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
        if ((char)pvVar1 == '\0') {
          uVar3 = *(undefined4 *)PTR_00336360;
          pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_,uVar3);
          if ((char)pvVar1 == '\0') {
            local_1c = self;
            local_18 = PTR_s_NSView_0034e3e0;
            pvVar1 = _objc_msgSendSuper(&local_1c,sel_accessibilityAttributeValue_,
                                        accessibilityAttributeValue);
            return pvVar1;
          }
          self = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar3);
          pcVar2 = &cfstr_Click_to_hide_Card_Browser;
          op = sel_localizedStringForKey_value_table_;
        }
        else {
          self = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar3);
          pcVar2 = &cfstr_Card_Browser;
          op = sel_localizedStringForKey_value_table_;
        }
      }
      else {
        self = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar3);
        pcVar2 = &cfstr_Card_Browser_Role;
        op = sel_localizedStringForKey_value_table_;
      }
    }
  }
  pvVar1 = _objc_msgSend(self,op,pcVar2);
  return pvVar1;
}

*/
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityChildrenAttribute]
        || [aValue isEqualToString:NSAccessibilityVisibleChildrenAttribute]) {
        return [self geometryCache];
    }
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        return NSAccessibilityListRole;
    }
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Card Browser Role" value:@"" table:nil];
    }
    if ([aValue isEqualToString:NSAccessibilityTitleAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Card Browser" value:@"" table:nil];
    }
    if ([aValue isEqualToString:NSAccessibilityHelpAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Click to hide Card Browser" value:@"" table:nil];
    }
    return [super accessibilityAttributeValue:aValue];
}

- (id)view:(id)aView stringForToolTip:(NSInteger)aTip point:(NSPoint)aPoint userData:(void *)aData
{
    NSInteger pvVar1;

    if (((_msFlags).dsSupportsToolTips != 0) && (pvVar1 = [self indexOfItemAtPoint:aPoint], pvVar1 != NSNotFound )) {
        return [_dataSource mediaStrip:self toolTipForItemAtIndex:pvVar1];
    }
    return nil;
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if ((_msFlags).dsSupportsToolTips != 0) {
        [self setToolTipSupport:(unsigned int)(aWindow != nil)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005833e @ 0005833e, 252 bytes * /

void FUN_0005833e(HSMediaStripView *self,SEL _cmd,BOOL setToolTipSupport)

{
  undefined1 *puVar1;
  id pvVar2;
  SEL op;
  
  if (setToolTipSupport == '\0') {
    op = sel_cleanupToolTips;
    if ((&self->_msFlags)->listensToFrameDidChange != 0) {
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003361e0,self);
      (self->_msFlags).listensToFrameDidChange = 0;
      op = sel_cleanupToolTips;
    }
  }
  else {
    op = sel_resetToolTips_;
    if ((&self->_msFlags)->listensToFrameDidChange == 0) {
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_resetToolTips_,
                    *(undefined4 *)PTR_003361e0,self);
      (self->_msFlags).listensToFrameDidChange = 1;
      op = sel_resetToolTips_;
    }
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)setToolTipSupport:(BOOL)aSupport
{
    if (aSupport) {
        if (!_msFlags.listensToFrameDidChange) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetToolTips:) name:NSViewFrameDidChangeNotification object:self];
            _msFlags.listensToFrameDidChange = 1;
        }
        [self resetToolTips:nil];
    }
    else {
        if (_msFlags.listensToFrameDidChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
            _msFlags.listensToFrameDidChange = 0;
        }
        [self cleanupToolTips];
    }
}

- (void)resetToolTips:(id)aTips
{
    if ((_msFlags).toolTipsSetUp != 0) {
        [self cleanupToolTips];
    }
    [self setupToolTips];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005847c @ 0005847c, 307 bytes * /

void FUN_0005847c(HSMediaStripView *self,SEL _cmd)

{
  undefined1 *puVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined *puVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  int *piVar8;
  id pvVar9;
  int aiStack_78 [3];
  int local_5c [10];
  undefined1 local_34 [16];
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  if ((self->_msFlags).dsSupportsToolTips != 0) {
    aiStack_78[2] = 0x584ad;
    pvVar5 = _objc_msgSend(self,sel_numberOfItems);
    puVar4 = PTR_00336078;
    if (pvVar5 != (id)0x0) {
      uVar2 = *(undefined4 *)PTR_00336078;
      uVar3 = *(undefined4 *)(PTR_00336078 + 4);
      aiStack_78[2] = 0x584e6;
      pvVar6 = _objc_msgSend(self,sel_geometryCache);
      local_1c = *(undefined4 *)(puVar4 + 8);
      uStack_18 = *(undefined4 *)(puVar4 + 0xc);
      aiStack_78[2] = 0x5852c;
      local_24 = uVar2;
      uStack_20 = uVar3;
      _objc_msgSend_stret(local_34,self,sel_visibleRect);
      pvVar9 = (id)0x0;
      piVar8 = aiStack_78 + 2;
      do {
        piVar8[2] = (int)pvVar9;
        piVar8[1] = (int)sel_objectAtIndex_;
        *piVar8 = (int)pvVar6;
        piVar8[-1] = 0x58547;
        pvVar7 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
        piVar8[2] = (int)sel_frame;
        piVar8[1] = (int)pvVar7;
        *piVar8 = (int)&local_24;
        piVar8[-1] = 0x58560;
        _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
        *(ulonglong *)(piVar8 + 3) = CONCAT44(uStack_18,local_1c);
        *(ulonglong *)(piVar8 + 1) = CONCAT44(uStack_20,local_24);
        piVar8[5] = (int)self;
        *piVar8 = (int)sel_addToolTipRect_owner_userData_;
        piVar8[-1] = (int)self;
        piVar8[6] = 0;
        piVar8[-2] = 0x5859a;
        _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
        pvVar9 = (id)((int)pvVar9 + 1);
        piVar8 = piVar8 + -1;
      } while (pvVar9 < pvVar5);
    }
    (self->_msFlags).toolTipsSetUp = 1;
  }
  return;
}

*/
- (void)setupToolTips
{
    NSUInteger count;
    NSUInteger index;
    NSArray *geometry;

    if (_msFlags.dsSupportsToolTips) {
        count = [self numberOfItems];
        if (count != 0) {
            geometry = [self geometryCache];
            for (index = 0; index < count; index++) {
                [self addToolTipRect:[[geometry objectAtIndex:index] frame] owner:self userData:NULL];
            }
        }
        _msFlags.toolTipsSetUp = 1;
    }
}

- (void)cleanupToolTips
{
    if ((_msFlags).toolTipsSetUp != 0) {
        [self removeAllToolTips];
        (_msFlags).toolTipsSetUp = 0;
    }
}

- (id)representedObject
{
    id pvVar1_2;

    if (![_dataSource respondsToSelector:@selector(representedObjectForMediaStrip:)]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [_dataSource representedObjectForMediaStrip:self];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00058639 @ 00058639, 807 bytes * /

void FUN_00058639(HSMediaStripView *self,SEL _cmd,uint startDragItemAtIndex,NSPoint at,id event)

{
  undefined8 uVar1;
  undefined *puVar2;
  float fVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  undefined8 uVar6;
  undefined4 local_24;
  float local_20;
  undefined4 local_1c;
  float local_18;
  
  self_00 = _objc_msgSend(cls_NSPasteboard,sel_pasteboardWithName_);
  _objc_msgSend(self,sel_selectedItemIndex);
  _objc_msgSend(self,sel_selectedItemIndex);
  pvVar4 = _objc_msgSend(self->_dataSource,sel_respondsToSelector_);
  if ((char)pvVar4 != '\0') {
    _objc_msgSend(self->_dataSource,sel_pasteboardTypesForMediaStrip_);
    _objc_msgSend(self_00,sel_declareTypes_owner_);
    pvVar4 = self_00;
    pvVar5 = _objc_msgSend(self->_dataSource,sel_mediaStrip_writeItemWithIndex_toPasteboard_);
    if ((char)pvVar5 != '\0') {
      uVar6 = CONCAT44(pvVar4,startDragItemAtIndex);
      pvVar4 = _objc_msgSend(self->_dataSource,sel_mediaStrip_imageForItemAtIndex_);
      pvVar5 = _objc_msgSend(self,sel_geometryCache);
      pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_);
      _objc_msgSend_stret(&local_24,pvVar5,sel_imageFrame,uVar6);
      pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc);
      uVar6 = CONCAT44(local_18,local_1c);
      pvVar5 = _objc_msgSend(pvVar5,sel_initWithSize_,local_1c,local_18);
      puVar2 = PTR_00336078;
      pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
      fVar3 = local_18;
      if ((pvVar4 != (id)0x0) && (pvVar5 != (id)0x0)) {
        uVar1 = *(undefined8 *)PTR_00336074;
        _objc_msgSend(pvVar5,sel_lockFocus,uVar6);
        _objc_msgSend(pvVar4,sel_drawInRect_fromRect_operation_fraction_,uVar1,
                      CONCAT44(fVar3,local_1c),*(undefined8 *)puVar2,*(undefined8 *)(puVar2 + 8),2,
                      0x3f000000);
        _objc_msgSend(pvVar5,sel_unlockFocus);
        _objc_msgSend(self,sel_dragImage_at_offset_event_pasteboard_source_slideBack_,pvVar5,
                      local_24,local_20 + local_18,*(undefined4 *)PTR_0033607c,
                      *(undefined4 *)(PTR_0033607c + 4),event,self_00,self,1);
      }
    }
  }
  return;
}

*/
- (void)startDragItemAtIndex:(NSUInteger)aIndex at:(NSPoint)aAt event:(id)aEvent
{
    NSPasteboard *pasteboard;
    NSImage *image;
    NSRect imageFrame;
    NSImage *dragImage;

    pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    if (![_dataSource respondsToSelector:@selector(mediaStrip:writeItemWithIndex:toPasteboard:)]) {
        return;
    }
    [pasteboard declareTypes:[_dataSource pasteboardTypesForMediaStrip:self] owner:nil];
    if (![_dataSource mediaStrip:self writeItemWithIndex:aIndex toPasteboard:pasteboard]) {
        return;
    }
    image = [_dataSource mediaStrip:self imageForItemAtIndex:aIndex];
    imageFrame = [[[self geometryCache] objectAtIndex:aIndex] imageFrame];
    dragImage = [[[NSImage alloc] initWithSize:imageFrame.size] autorelease];
    if (image != nil && dragImage != nil) {
        [dragImage lockFocus];
        [image drawInRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, imageFrame.size.width, imageFrame.size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:0.5];
        [dragImage unlockFocus];
        [self dragImage:dragImage at:NSMakePoint(imageFrame.origin.x, imageFrame.origin.y + imageFrame.size.height) offset:NSZeroSize event:aEvent pasteboard:pasteboard source:self slideBack:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00058960 @ 00058960, 243 bytes * /

BOOL FUN_00058960(HSMediaStripView *self,SEL _cmd,id performDragOperation)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar2 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar2 == '\0') {
    BVar1 = '\0';
  }
  else {
    pvVar2 = self->_dataSource;
    pvVar3 = _objc_msgSend(self,sel_draggingInfo);
    pvVar3 = _objc_msgSend(pvVar3,sel_dropOperation);
    pvVar4 = _objc_msgSend(self,sel_draggingInfo);
    pvVar4 = _objc_msgSend(pvVar4,sel_dropIndex);
    pvVar2 = _objc_msgSend(pvVar2,sel_mediaStrip_acceptDrop_item_dropOperation_,self,
                           performDragOperation,pvVar4,pvVar3);
    BVar1 = (BOOL)pvVar2;
    _objc_msgSend(self->_draggingInfo,sel_release);
    self->_draggingInfo = (HSMediaStripDraggingInfo *)0x0;
    _objc_msgSend(self,sel_setNeedsDisplay_,1);
  }
  return BVar1;
}

*/
- (BOOL)performDragOperation:(id)aOperation
{
    BOOL accepted;

    if (![self isEnabled]) {
        return NO;
    }
    accepted = [_dataSource mediaStrip:self acceptDrop:aOperation item:[[self draggingInfo] dropIndex] dropOperation:[(HSMediaStripDraggingInfo *)[self draggingInfo] dropOperation]];
    [_draggingInfo release];
    _draggingInfo = nil;
    [self setNeedsDisplay:YES];
    return accepted;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00058a53 @ 00058a53, 727 bytes * /

uint FUN_00058a53(HSMediaStripView *self,SEL _cmd,id draggingUpdated)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  HSMediaStripView *pHVar4;
  id pvVar5;
  id pvVar6;
  id self_00;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  undefined8 uVar7;
  undefined4 uVar8;
  id local_38;
  undefined8 local_34;
  undefined8 local_2c;
  undefined4 local_24;
  float fStack_20;
  undefined8 local_1c;
  
  pvVar2 = _objc_msgSend(draggingUpdated,sel_draggingSourceOperationMask);
  pvVar3 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar3 == '\0') {
    local_38 = (id)0x0;
    pvVar2 = local_38;
  }
  else {
    pHVar4 = _objc_msgSend(draggingUpdated,sel_draggingSource);
    if ((pHVar4 == self) && (((uint)pvVar2 & 0x10) != 0)) {
      local_38 = (id)0x10;
    }
    else if (((uint)pvVar2 & 1) == 0) {
      local_38 = (id)0x0;
    }
    else {
      local_38 = (id)0x1;
    }
    pvVar2 = _objc_msgSend(draggingUpdated,sel_draggingLocation);
    uVar8 = 0;
    pvVar3 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    uVar7 = CONCAT44(extraout_EDX_00,pvVar3);
    pvVar5 = _objc_msgSend(self,sel_indexOfItemAtPoint_,pvVar3);
    pvVar2 = local_38;
    if (pvVar5 != (id)0x7fffffff) {
      pvVar6 = _objc_msgSend(self,sel_geometryCache,uVar7,uVar8);
      self_00 = _objc_msgSend(pvVar6,sel_objectAtIndex_,pvVar5);
      _objc_msgSend_stret(&local_24,self_00,sel_imageFrame);
      pvVar6 = _objc_msgSend(pvVar6,sel_objectAtIndex_);
      _objc_msgSend_stret(&local_34,pvVar6,sel_frame);
      cVar1 = _NSPointInRect(pvVar3,extraout_EDX_00,CONCAT44(fStack_20,local_24),local_1c);
      if (cVar1 == '\0') {
        cVar1 = _NSPointInRect(pvVar3,extraout_EDX_00,local_34,local_2c);
        if (cVar1 == '\0') {
          uVar8 = 0;
          pvVar5 = (id)0x7fffffff;
        }
        else {
          pvVar5 = (id)((int)pvVar5 + (uint)(fStack_20 <= extraout_EDX_00));
          if ((local_38 == (id)0x1) &&
             (pvVar3 = _objc_msgSend(self,sel_numberOfItems), pvVar3 < pvVar5)) {
            uVar8 = 1;
            pvVar5 = _objc_msgSend(self,sel_numberOfItems);
          }
          else {
            uVar8 = 1;
          }
        }
      }
      else {
        uVar8 = 0;
      }
      _objc_msgSend(self,sel_setDropIndex_dropOperation_,pvVar5,1);
      pvVar3 = _objc_msgSend(self,sel_isDropEnabled);
      if ((((char)pvVar3 != '\0') && ((self->_msFlags).dsSupportsDrop != 0)) &&
         (pvVar2 = _objc_msgSend(self->_dataSource,
                                 sel_mediaStrip_validateDrop_proposedItem_proposedDropOperation_,
                                 self,draggingUpdated,pvVar5,uVar8),
         pvVar2 == local_38 || pvVar2 == (id)0x0)) {
        pvVar2 = local_38;
      }
    }
  }
  return (uint)pvVar2;
}

*/
- (NSUInteger)draggingUpdated:(id)aUpdated
{
    NSDragOperation mask;
    NSDragOperation operation;
    NSDragOperation validated;
    NSPoint point;
    NSUInteger index;
    NSUInteger dropOperation;
    NSArray *geometry;
    NSRect imageFrame;
    NSRect frame;

    mask = [aUpdated draggingSourceOperationMask];
    if (![self isEnabled]) {
        return NSDragOperationNone;
    }
    if ([aUpdated draggingSource] == self && (mask & NSDragOperationMove) != 0) {
        operation = NSDragOperationMove;
    }
    else if ((mask & NSDragOperationCopy) != 0) {
        operation = NSDragOperationCopy;
    }
    else {
        operation = NSDragOperationNone;
    }
    point = [self convertPoint:[aUpdated draggingLocation] fromView:nil];
    index = [self indexOfItemAtPoint:point];
    if (index == NSNotFound) {
        return operation;
    }
    geometry = [self geometryCache];
    imageFrame = [[geometry objectAtIndex:index] imageFrame];
    frame = [[geometry objectAtIndex:index] frame];
    if (NSPointInRect(point, imageFrame)) {
        // Over the image: drop on the item.
        dropOperation = 0;
    }
    else if (NSPointInRect(point, frame)) {
        // Between images: drop above this item or the next one.
        if (imageFrame.origin.y <= point.y) {
            index++;
        }
        if (operation == NSDragOperationCopy && [self numberOfItems] < index) {
            index = [self numberOfItems];
        }
        dropOperation = 1;
    }
    else {
        dropOperation = 0;
        index = NSNotFound;
    }
    [self setDropIndex:index dropOperation:dropOperation];
    if ([self isDropEnabled] && _msFlags.dsSupportsDrop) {
        validated = [_dataSource mediaStrip:self validateDrop:aUpdated proposedItem:index proposedDropOperation:dropOperation];
        if (validated != operation && validated != NSDragOperationNone) {
            return validated;
        }
    }
    return operation;
}

- (void)draggingExited:(id)aExited
{
    [_draggingInfo release];
    _draggingInfo = nil;
    [self setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00058d7e @ 00058d7e, 252 bytes * /

uint FUN_00058d7e(HSMediaStripView *self,SEL _cmd,id draggingEntered)

{
  id pvVar1;
  HSMediaStripDraggingInfo *pHVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabled);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_isDragEnabled), (char)pvVar1 != '\0')) {
    pHVar2 = _objc_msgSend(cls_HSMediaStripDraggingInfo,sel_new);
    self->_draggingInfo = pHVar2;
    pvVar1 = _objc_msgSend(draggingEntered,sel_draggingLocation);
    pvVar3 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
    pvVar1 = self->_dataSource;
    pvVar3 = _objc_msgSend(self,sel_indexOfItemAtPoint_,pvVar3,extraout_EDX_00);
    pvVar1 = _objc_msgSend(pvVar1,sel_mediaStrip_validateDrop_proposedItem_proposedDropOperation_,
                           self,draggingEntered,pvVar3,0);
    return (uint)pvVar1;
  }
  return 0;
}

*/
- (NSUInteger)draggingEntered:(id)aEntered
{
    NSPoint point;

    if (![self isEnabled] || ![self isDragEnabled]) {
        return NSDragOperationNone;
    }
    // Fix: release any dragging info left over from an earlier drag.
    [_draggingInfo release];
    _draggingInfo = [HSMediaStripDraggingInfo new];
    point = [self convertPoint:[aEntered draggingLocation] fromView:nil];
    return [_dataSource mediaStrip:self validateDrop:aEntered proposedItem:[self indexOfItemAtPoint:point] proposedDropOperation:0];
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal
{
    unsigned int uVar1;

    uVar1 = 0x13;
    if (aLocal == NO) {
        uVar1 = 1;
    }
    return uVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00058e7a @ 00058e7a, 483 bytes * /

void FUN_00058e7a(HSMediaStripView *self,SEL _cmd,uint setDropIndex,uint dropOperation)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar1 = _objc_msgSend(self,sel_draggingInfo);
  pvVar1 = _objc_msgSend(pvVar1,sel_dropIndex);
  pvVar2 = _objc_msgSend(self,sel_numberOfItems);
  if (pvVar2 <= pvVar1) {
    pvVar1 = _objc_msgSend(self,sel_numberOfItems);
    pvVar1 = (id)((int)pvVar1 + -1);
  }
  pvVar2 = _objc_msgSend(self,sel_numberOfItems);
  uVar3 = setDropIndex;
  if (pvVar2 <= setDropIndex) {
    pvVar2 = _objc_msgSend(self,sel_numberOfItems);
    uVar3 = (int)pvVar2 - 1;
  }
  pvVar2 = _objc_msgSend(self,sel_draggingInfo);
  _objc_msgSend(pvVar2,sel_setDropIndex_,setDropIndex);
  pvVar2 = _objc_msgSend(self,sel_draggingInfo);
  _objc_msgSend(pvVar2,sel_setDropOperation_,dropOperation);
  if (pvVar1 != (id)setDropIndex) {
    pvVar2 = _objc_msgSend(self,sel_geometryCache,dropOperation);
    pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,uVar3);
    _objc_msgSend_stret(local_34,pvVar1,sel_frame);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,(int)local_34._0_8_,SUB84(local_34._0_8_,4),
                  (int)local_34._8_8_,SUB84(local_34._8_8_,4));
    _objc_msgSend_stret(local_24,pvVar2,sel_frame);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                  (int)local_24._8_8_,SUB84(local_24._8_8_,4));
  }
  return;
}

*/
- (void)setDropIndex:(NSUInteger)aIndex dropOperation:(NSUInteger)aOperation
{
    NSUInteger previousIndex;
    NSUInteger clampedIndex;
    NSArray *geometry;

    previousIndex = [[self draggingInfo] dropIndex];
    if ([self numberOfItems] <= previousIndex) {
        previousIndex = [self numberOfItems] - 1;
    }
    clampedIndex = aIndex;
    if ([self numberOfItems] <= aIndex) {
        clampedIndex = [self numberOfItems] - 1;
    }
    [[self draggingInfo] setDropIndex:aIndex];
    [[self draggingInfo] setDropOperation:aOperation];
    if (previousIndex != aIndex) {
        geometry = [self geometryCache];
        [self setNeedsDisplayInRect:[[geometry objectAtIndex:previousIndex] frame]];
        [self setNeedsDisplayInRect:[[geometry objectAtIndex:clampedIndex] frame]];
    }
}

- (id)draggingInfo
{
    return _draggingInfo;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00057c1d @ 00057c1d, 43 bytes * /

void FUN_00057c1d(HSMediaStripView *self,SEL _cmd,BOOL setDragAndDropEnabled)

{
  self->_msFlags =
       (WBMediaStripFlags)
       ((uint)(setDragAndDropEnabled != '\0') * 0x18000 + ((uint)self->_msFlags & 0xfffe7fff));
  return;
}

*/
- (void)setDragAndDropEnabled:(BOOL)aEnabled
{
    _msFlags.dsSupportsDrag = aEnabled ? 1 : 0;
    _msFlags.dsSupportsDrop = aEnabled ? 1 : 0;
}

- (BOOL)isDropEnabled
{
    return (&_msFlags)->dsSupportsDrop;
}

- (BOOL)isDragEnabled
{
    return (&_msFlags)->dsSupportsDrag;
}

- (void)activateItemAtIndex:(NSUInteger)aIndex
{
    [self setActiveItemIndex:aIndex force:NO];
}

- (void)selectItemAtIndex:(NSUInteger)aIndex
{
    [self setSelectedItemIndex:aIndex];
    [self scrollItemAtIndexToVisible:aIndex];
    if (([self delegate] != nil) && ((_msFlags).delegateNotifiedOfClick != 0)) {
        [[self delegate] mediaStrip:self clickedOnItemAtIndex:aIndex insideImage:NO];
    }
}

- (void)setActiveItemIndex:(NSUInteger)aIndex force:(BOOL)aForce
{
    NSUInteger uVar1;

    uVar1 = _activeItemIndex;
    if ((uVar1 != aIndex) || (aForce != NO)) {
        if (uVar1 != NSNotFound) {
            [self setNeedsDisplayForItemAtIndex:uVar1];
        }
        _activeItemIndex = aIndex;
        if (aIndex != NSNotFound) {
            [self setNeedsDisplayForItemAtIndex:aIndex];
        }
    }
}

- (void)setActiveItemIndex:(NSUInteger)aIndex
{
    [self setActiveItemIndex:aIndex force:NO];
}

- (NSUInteger)activeItemIndex
{
    return _activeItemIndex;
}

- (void)setSelectedItemIndex:(NSUInteger)aIndex force:(BOOL)aForce
{
    NSUInteger uVar1;

    uVar1 = _selectedItemIndex;
    if ((uVar1 != aIndex) || (aForce != NO)) {
        if (uVar1 != NSNotFound) {
            [self setNeedsDisplayForItemAtIndex:uVar1];
        }
        _selectedItemIndex = aIndex;
        if (aIndex != NSNotFound) {
            [self setNeedsDisplayForItemAtIndex:aIndex];
        }
    }
}

- (void)setSelectedItemIndex:(NSUInteger)aIndex
{
    [self setSelectedItemIndex:aIndex force:NO];
}

- (NSUInteger)selectedItemIndex
{
    return _selectedItemIndex;
}

- (BOOL)firstResponderStatus
{
    BOOL bVar3;

    if (![self showsFirstResponderStatus]) {
        bVar3 = NO;
    }
    else {
        bVar3 = [[self window] firstResponder] == self;
    }
    return bVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000592c5 @ 000592c5, 128 bytes * /

void FUN_000592c5(HSMediaStripView *self,SEL _cmd,BOOL setShowsFirstResponderStatus)

{
  id pvVar1;
  
  if ((&self->_msFlags)->showsFirstResponderStatus != (uint)(setShowsFirstResponderStatus != '\0'))
  {
    self->_msFlags =
         (WBMediaStripFlags)
         (((uint)self->_msFlags & 0xfffbffff) +
         (uint)(setShowsFirstResponderStatus != '\0') * 0x40000);
    pvVar1 = _objc_msgSend(self,sel_activeItemIndex);
    if (pvVar1 != (id)0x7fffffff) {
      pvVar1 = _objc_msgSend(self,sel_activeItemIndex);
      _objc_msgSend(self,sel_setNeedsDisplayForItemAtIndex_,pvVar1);
    }
  }
  return;
}

*/
- (void)setShowsFirstResponderStatus:(BOOL)aStatus
{
    if (_msFlags.showsFirstResponderStatus != (aStatus ? 1u : 0u)) {
        _msFlags.showsFirstResponderStatus = aStatus ? 1 : 0;
        if ([self activeItemIndex] != NSNotFound) {
            [self setNeedsDisplayForItemAtIndex:[self activeItemIndex]];
        }
    }
}

- (BOOL)showsFirstResponderStatus
{
    return (&_msFlags)->showsFirstResponderStatus;
}

- (void)setEnabled:(BOOL)aEnabled
{
    (&_msFlags)->isDisabled = aEnabled == NO;
}

- (BOOL)isEnabled
{
    unsigned char bVar2;

    if (![[self delegate] respondsToSelector:@selector(userInteractionEnabledForMediaStrip:)]) {
        bVar2 = (&_msFlags)->isDisabled ^ 1;
    }
    else {
        bVar2 = [[self delegate] userInteractionEnabledForMediaStrip:self];
    }
    return bVar2;
}

- (NSUInteger)indexOfItem:(id)aItem
{
    return (unsigned int)[[self geometryCache] indexOfObject:aItem];
}

- (id)labelForItemAtIndex:(NSUInteger)aIndex
{
    id pvVar1_2;

    if ((![self showsLabels]) || ((_msFlags).dsSupportsLabels == 0)) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [_dataSource mediaStrip:self labelForItemAtIndex:aIndex];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059468 @ 00059468, 268 bytes * /

ulonglong FUN_00059468(HSMediaStripView *self,SEL _cmd,NSRect itemsInRect)

{
  char cVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  NSPoint *pNVar5;
  int iVar6;
  id pvVar7;
  float fStack_78;
  NSPoint local_74;
  NSSize local_64;
  NSPoint local_5c [5];
  NSPoint local_34;
  NSPoint local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  self_00 = _objc_msgSend(self,sel_geometryCache);
  iVar6 = 0;
  pvVar7 = (id)0x7fffffff;
  pvVar2 = _objc_msgSend(self_00,sel_count);
  pNVar5 = (NSPoint *)&stack0xffffff94;
  for (pvVar4 = (id)0x0; pvVar4 < pvVar2; pvVar4 = (id)((int)pvVar4 + 1)) {
    pNVar5[1].x = (float)pvVar4;
    pNVar5->y = (float)sel_objectAtIndex_;
    pNVar5->x = (float)self_00;
    pNVar5[-1].y = 5.12563e-40;
    pvVar3 = _objc_msgSend((id)pNVar5->x,(SEL)pNVar5->y);
    pNVar5[1].x = (float)sel_frame;
    pNVar5->y = (float)pvVar3;
    pNVar5->x = (float)&local_34;
    pNVar5[-1].y = 5.12602e-40;
    _objc_msgSend_stret((void *)pNVar5->x,(id)pNVar5->y,(SEL)pNVar5[1].x);
    pNVar5[3] = local_2c;
    pNVar5[2] = local_34;
    *(NSSize *)(pNVar5 + 1) = itemsInRect.size;
    *pNVar5 = itemsInRect.origin;
    pNVar5[-1].y = (float)&local_24;
    pNVar5[-1].x = 5.12686e-40;
    _NSIntersectionRect();
    pNVar5->x = (float)(undefined4)local_1c;
    pNVar5->y = (float)local_1c._4_4_;
    pNVar5[-0xffffffff00000001].x = (float)(undefined4)local_24;
    pNVar5[-0xffffffff00000001].y = (float)local_24._4_4_;
    pNVar5[-2].y = 5.12727e-40;
    cVar1 = _NSIsEmptyRect();
    if (cVar1 == '\0') {
      if (pvVar7 == (id)0x7fffffff) {
        pvVar7 = pvVar4;
      }
      iVar6 = iVar6 + 1;
    }
    else if (pvVar7 != (id)0x7fffffff) break;
    pNVar5 = pNVar5 + -1;
  }
  return CONCAT44(iVar6,pvVar7);
}

*/
- (NSRange)itemsInRect:(NSRect)aRect
{
    NSArray *geometry;
    NSUInteger count;
    NSUInteger index;
    NSUInteger first;
    NSUInteger length;

    geometry = [self geometryCache];
    first = NSNotFound;
    length = 0;
    count = [geometry count];
    for (index = 0; index < count; index++) {
        if (!NSIsEmptyRect(NSIntersectionRect([[geometry objectAtIndex:index] frame], aRect))) {
            if (first == NSNotFound) {
                first = index;
            }
            length++;
        }
        else if (first != NSNotFound) {
            break;
        }
    }
    return NSMakeRange(first, length);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059574 @ 00059574, 212 bytes * /

uint FUN_00059574(HSMediaStripView *self,SEL _cmd,NSPoint indexOfItemImageAtPoint)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined8 in_stack_ffffffd0;
  undefined8 uVar4;
  undefined8 local_24;
  undefined8 local_1c;
  
  uVar4 = CONCAT44((int)((ulonglong)in_stack_ffffffd0 >> 0x20),indexOfItemImageAtPoint.y);
  pvVar2 = _objc_msgSend(self,sel_indexOfItemAtPoint_);
  if (pvVar2 == (id)0x7fffffff) {
    pvVar3 = (id)0x7fffffff;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_geometryCache);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_);
    _objc_msgSend_stret(&local_24,pvVar3,sel_imageFrame,uVar4);
    cVar1 = _NSPointInRect(indexOfItemImageAtPoint.x,indexOfItemImageAtPoint.y,local_24,local_1c);
    pvVar3 = (id)0x7fffffff;
    if (cVar1 != '\0') {
      pvVar3 = pvVar2;
    }
  }
  return (uint)pvVar3;
}

*/
- (NSUInteger)indexOfItemImageAtPoint:(NSPoint)aPoint
{
    NSUInteger index;

    index = [self indexOfItemAtPoint:aPoint];
    if (index == NSNotFound) {
        return NSNotFound;
    }
    if (NSPointInRect(aPoint, [[[self geometryCache] objectAtIndex:index] imageFrame])) {
        return index;
    }
    return NSNotFound;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059648 @ 00059648, 233 bytes * /

uint FUN_00059648(HSMediaStripView *self,SEL _cmd,NSPoint indexOfItemAtPoint)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int *piVar4;
  id pvVar5;
  int aiStack_54 [2];
  float local_44 [8];
  undefined8 local_24;
  undefined8 local_1c;
  
  self_00 = _objc_msgSend(self,sel_geometryCache);
  pvVar1 = _objc_msgSend(self_00,sel_count);
  if (pvVar1 == (id)0x0) {
    pvVar5 = (id)0x7fffffff;
  }
  else {
    pvVar5 = (id)0x7fffffff;
    pvVar3 = (id)0x0;
    piVar4 = (int *)&stack0xffffffb4;
    do {
      piVar4[2] = (int)pvVar3;
      piVar4[1] = (int)sel_objectAtIndex_;
      *piVar4 = (int)self_00;
      piVar4[-1] = 0x596ac;
      pvVar2 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
      piVar4[2] = (int)sel_frame;
      piVar4[1] = (int)pvVar2;
      *piVar4 = (int)&local_24;
      piVar4[-1] = 0x596c5;
      _objc_msgSend_stret((void *)*piVar4,(id)piVar4[1],(SEL)piVar4[2]);
      *(undefined8 *)(piVar4 + 5) = local_1c;
      *(undefined8 *)(piVar4 + 3) = local_24;
      piVar4[2] = (int)indexOfItemAtPoint.y;
      piVar4[1] = (int)indexOfItemAtPoint.x;
      *piVar4 = (int)sel_mouse_inRect_;
      piVar4[-1] = (int)self;
      piVar4[-2] = 0x59709;
      pvVar2 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
      if ((char)pvVar2 != '\0') {
        pvVar5 = pvVar3;
      }
      pvVar3 = (id)((int)pvVar3 + 1);
    } while ((pvVar3 < pvVar1) && (piVar4 = piVar4 + -1, pvVar5 == (id)0x7fffffff));
  }
  return (uint)pvVar5;
}

*/
- (NSUInteger)indexOfItemAtPoint:(NSPoint)aPoint
{
    NSArray *geometry;
    NSUInteger count;
    NSUInteger index;
    NSUInteger found;

    geometry = [self geometryCache];
    count = [geometry count];
    found = NSNotFound;
    for (index = 0; index < count && found == NSNotFound; index++) {
        if ([self mouse:aPoint inRect:[[geometry objectAtIndex:index] frame]]) {
            found = index;
        }
    }
    return found;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059731 @ 00059731, 154 bytes * /

ulonglong FUN_00059731(HSMediaStripView *self,SEL _cmd,uint sizeForItemAtIndex)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(self,sel_geometryCache);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  uVar3 = *(undefined4 *)PTR_0033607c;
  uVar4 = *(undefined4 *)(PTR_0033607c + 4);
  if (sizeForItemAtIndex < pvVar2) {
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,sizeForItemAtIndex);
    _objc_msgSend_stret(local_24,pvVar1,sel_imageFrame);
    uVar3 = local_1c;
    uVar4 = local_18;
  }
  return CONCAT44(uVar4,uVar3);
}

*/
- (NSSize)sizeForItemAtIndex:(NSUInteger)aIndex
{
    NSArray *geometry;

    geometry = [self geometryCache];
    if (aIndex < [geometry count]) {
        return [[geometry objectAtIndex:aIndex] imageFrame].size;
    }
    return NSZeroSize;
}

- (void)setStripWidth:(CGFloat)aWidth
{
    if (_stripWidth != aWidth) {
        _stripWidth = aWidth;
        [self sizeToFit];
    }
}

- (CGFloat)stripWidth
{
    return _stripWidth;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005980d @ 0005980d, 152 bytes * /

void FUN_0005980d(HSMediaStripView *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  float *pfVar3;
  undefined4 *puVar4;
  undefined4 uStack_30;
  undefined1 local_1c [4];
  float local_18;
  float local_10;
  
  puVar4 = (undefined4 *)&stack0xffffffd4;
  uStack_30 = 0x59830;
  pvVar2 = _objc_msgSend(self,sel_geometryCache);
  uStack_30 = 0x59842;
  pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
  if (pvVar2 == (id)0x0) {
    local_18 = *(float *)(PTR_0033607c + 4);
    pfVar3 = (float *)PTR_0033607c;
  }
  else {
    uStack_30 = 0x5986c;
    _objc_msgSend_stret(local_1c,pvVar2,sel_frame);
    puVar4 = &uStack_30;
    pfVar3 = &self->_stripWidth;
    local_18 = local_18 + local_10;
  }
  fVar1 = *pfVar3;
  puVar4[3] = local_18;
  puVar4[2] = fVar1;
  puVar4[1] = sel_setFrameSize_;
  *puVar4 = self;
  puVar4[-1] = 0x5989e;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return;
}

*/
- (void)sizeToFit
{
    id lastItem;
    NSRect frame;

    lastItem = [[self geometryCache] lastObject];
    if (lastItem == nil) {
        [self setFrameSize:NSZeroSize];
    }
    else {
        frame = [lastItem frame];
        [self setFrameSize:NSMakeSize(_stripWidth, frame.origin.y + frame.size.height)];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
    (_msFlags).delegateNotifiedOfClick = [aDelegate respondsToSelector:@selector(mediaStrip:clickedOnItemAtIndex:insideImage:)];
    (&_msFlags)->delegateNotifiedOfDoubleClick = [aDelegate respondsToSelector:@selector(mediaStrip:doubleClickedOnItemAtIndex:insideImage:modifiers:)];
    (&_msFlags)->delegateNotifiedOfKeyStatusChange = [aDelegate respondsToSelector:@selector(mediaStrip:keyStatusChangedTo:)];
    (&_msFlags)->delegateNotifiedOfKeyEvents = [aDelegate respondsToSelector:@selector(mediaStrip:handleKeyEventBySelector:)];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDataSource:(id)aSource
{
    if (_dataSource != aSource) {
        (_msFlags).dsSupportsLabels = [aSource respondsToSelector:@selector(mediaStrip:labelForItemAtIndex:)];
        (_msFlags).dsSupportsBadgedIcons = [aSource respondsToSelector:@selector(mediaStrip:badgedIconForItemAtIndex:)];
        (_msFlags).dsSupportsToolTips = 0;
        [self setToolTipSupport:NO];
        _dataSource = aSource;
        if ([aSource respondsToSelector:@selector(pasteboardTypesForMediaStrip:)]) {
            if ([_dataSource respondsToSelector:@selector(mediaStrip:writeItemWithIndex:toPasteboard:)]) {
                (_msFlags).dsSupportsDrag = 1;
                [self registerForDraggedTypes:[_dataSource pasteboardTypesForMediaStrip:self]];
            }
        }
        if ([_dataSource respondsToSelector:@selector(mediaStrip:acceptDrop:item:dropOperation:)]) {
            if ([_dataSource respondsToSelector:@selector(mediaStrip:validateDrop:proposedItem:proposedDropOperation:)]) {
                (_msFlags).dsSupportsDrop = 1;
            }
        }
        [self noteNumberOfItemsChanged];
        [self reloadData];
    }
}

- (id)dataSource
{
    return _dataSource;
}

- (NSUInteger)numberOfItems
{
    NSUInteger pvVar1;

    if ((_msFlags).numberOfItemsValid == 0) {
        if (_dataSource == nil) {
            pvVar1 = 0;
        }
        else {
            pvVar1 = [_dataSource numberOfRowsInMediaStrip:self];
            _numberOfItems = (unsigned int)pvVar1;
            (_msFlags).numberOfItemsValid = 1;
        }
    }
    else {
        pvVar1 = _numberOfItems;
    }
    return (unsigned int)pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059b69 @ 00059b69, 94 bytes * /

void FUN_00059b69(HSMediaStripView *self,SEL _cmd)

{
  undefined1 local_1c [4];
  float local_18;
  float local_10;
  
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  _objc_msgSend(self,sel_scrollPoint_,0,local_18 + local_10);
  return;
}

*/
- (void)scrollToBottom
{
    NSRect bounds;

    bounds = [self bounds];
    [self scrollPoint:NSMakePoint(0.0, bounds.origin.y + bounds.size.height)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059bc7 @ 00059bc7, 89 bytes * /

void FUN_00059bc7(HSMediaStripView *self,SEL _cmd)

{
  undefined1 local_1c [4];
  undefined4 local_18;
  
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  _objc_msgSend(self,sel_scrollPoint_,0,local_18);
  return;
}

*/
- (void)scrollToTop
{
    [self scrollPoint:NSMakePoint(0.0, [self bounds].origin.y)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059c20 @ 00059c20, 468 bytes * /

void FUN_00059c20(HSMediaStripView *self,SEL _cmd,uint scrollItemAtIndexToCenter)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  longdouble lVar3;
  longdouble lVar4;
  undefined1 local_34 [4];
  float local_30;
  float local_28;
  undefined1 local_24 [12];
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_geometryCache);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,scrollItemAtIndexToCenter);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend_stret(local_34,pvVar1,sel_frame);
    pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
    pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
    _objc_msgSend_stret(local_24,pvVar1,sel_documentVisibleRect);
    pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
    pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
    pvVar1 = _objc_msgSend(pvVar1,sel_constrainScrollPoint_,0,
                           local_18 * -0.5 + local_28 * 0.5 + local_30);
    lVar3 = (longdouble)_ceilf(pvVar1);
    lVar4 = (longdouble)_ceilf(extraout_EDX);
    pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
    pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
    _objc_msgSend(pvVar1,sel_scrollToPoint_,(float)lVar3,(float)lVar4);
    pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
    pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
    pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
    _objc_msgSend(pvVar1,sel_reflectScrolledClipView_,pvVar2);
  }
  return;
}

*/
- (void)scrollItemAtIndexToCenter:(NSUInteger)aCenter
{
    id item;
    NSRect frame;
    NSRect visibleRect;
    NSClipView *clipView;
    NSPoint point;

    item = [[self geometryCache] objectAtIndex:aCenter];
    if (item != nil) {
        frame = [item frame];
        clipView = [[self enclosingScrollView] contentView];
        visibleRect = [clipView documentVisibleRect];
        point = [clipView constrainScrollPoint:NSMakePoint(0.0, visibleRect.size.height * -0.5 + frame.size.height * 0.5 + frame.origin.y)];
        [clipView scrollToPoint:NSMakePoint(ceilf(point.x), ceilf(point.y))];
        [[self enclosingScrollView] reflectScrolledClipView:clipView];
    }
}

- (void)scrollItemAtIndexToVisible:(NSUInteger)aVisible
{
    id geometry = [[self geometryCache] objectAtIndex:aVisible];
    if (geometry != nil) {
        [self scrollRectToVisible:[geometry frame]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059e7f @ 00059e7f, 139 bytes * /

void FUN_00059e7f(HSMediaStripView *self,SEL _cmd,uint scrollItemAtIndexToTop)

{
  id pvVar1;
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(self,sel_geometryCache);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,scrollItemAtIndexToTop);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend_stret(&local_1c,pvVar1,sel_frame);
    _objc_msgSend(self,sel_scrollPoint_,local_1c,local_18);
  }
  return;
}

*/
- (void)scrollItemAtIndexToTop:(NSUInteger)aTop
{
    id item;

    item = [[self geometryCache] objectAtIndex:aTop];
    if (item != nil) {
        [self scrollPoint:[item frame].origin];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059f0a @ 00059f0a, 80 bytes * /

void FUN_00059f0a(HSMediaStripView *self,SEL _cmd)

{
  WBMediaStripFlags *pWVar1;
  
  _objc_msgSend(self,sel_setSelectedItemIndex_,0x7fffffff);
  _objc_msgSend(self,sel_setActiveItemIndex_,0x7fffffff);
  pWVar1->geometryValid = 0;
  pWVar1->numberOfItemsValid = 0;
  return;
}

*/
- (void)noteNumberOfItemsChanged
{
    [self setSelectedItemIndex:NSNotFound];
    [self setActiveItemIndex:NSNotFound];
    _msFlags.geometryValid = 0;
    _msFlags.numberOfItemsValid = 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00059f5a @ 00059f5a, 525 bytes * /

void FUN_00059f5a(HSMediaStripView *self,SEL _cmd,uint reloadItemAtIndex)

{
  char cVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined1 local_44 [4];
  float fStack_40;
  float fStack_38;
  undefined1 local_34 [16];
  undefined1 local_24 [12];
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_itemsCacheValidator);
  pvVar2 = _objc_msgSend(pvVar2,sel_length);
  if (reloadItemAtIndex < pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_itemsCacheValidator);
    _objc_msgSend(pvVar2,sel_resetBytesInRange_);
  }
  pvVar2 = _objc_msgSend(self,sel_geometryCache);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
  _objc_msgSend_stret(local_34,pvVar2,sel_frame);
  _objc_msgSend(self,sel_recalculateGeometryForItemAtIndex_);
  _objc_msgSend_stret(local_44,pvVar2,sel_frame);
  puVar3 = (undefined4 *)&stack0xffffff8c;
  cVar1 = _NSEqualRects();
  if (cVar1 == '\0') {
    _objc_msgSend(self,sel_sizeToFit);
    _objc_msgSend_stret(local_24,self,sel_frame);
    puVar3 = (undefined4 *)&stack0xffffff88;
    fStack_38 = local_18 - fStack_40;
    _objc_msgSend(self,sel_setNeedsDisplayInRect_);
    pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
    _objc_msgSend(pvVar2,sel_tile);
    _objc_msgSend(self,sel_enclosingScrollView);
  }
  puVar3[-1] = 0x5a0a7;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)reloadItemAtIndex:(NSUInteger)aIndex
{
    id item;
    NSRect oldFrame;
    NSRect newFrame;

    if (aIndex < [[self itemsCacheValidator] length]) {
        [[self itemsCacheValidator] resetBytesInRange:NSMakeRange(aIndex, 1)];
    }
    item = [[self geometryCache] objectAtIndex:aIndex];
    oldFrame = [item frame];
    [self recalculateGeometryForItemAtIndex:aIndex];
    newFrame = [item frame];
    if (NSEqualRects(oldFrame, newFrame)) {
        [self setNeedsDisplayInRect:newFrame];
        return;
    }
    // The item changed size, so everything below it moves.
    [self sizeToFit];
    newFrame.size.height = [self frame].size.height - newFrame.origin.y;
    [self setNeedsDisplayInRect:newFrame];
    [[self enclosingScrollView] tile];
    [[self enclosingScrollView] setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005a167 @ 0005a167, 586 bytes * /

void FUN_0005a167(HSMediaStripView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  int iVar3;
  undefined4 uVar4;
  id local_14;
  
  (self->_msFlags).geometryValid = 0;
  pvVar1 = _objc_msgSend(self,sel_numberOfItems);
  pvVar2 = _objc_msgSend(self,sel_itemsCacheValidator);
  local_14 = _objc_msgSend(pvVar2,sel_length);
  if (local_14 < pvVar1) {
    if (local_14 < pvVar1) {
      pvVar2 = (id)((int)local_14 + 1U);
      if ((id)((int)local_14 + 1U) < pvVar1) {
        pvVar2 = pvVar1;
      }
      iVar3 = (int)pvVar2 - (int)local_14;
      do {
        pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
        pvVar2 = _objc_msgSend(pvVar2,sel_initWithSize_,0x41200000,0x41200000);
        _objc_msgSend(pvVar2,sel_setFlipped_,1);
        self_00 = _objc_msgSend(self,sel_itemsCache);
        _objc_msgSend(self_00,sel_addObject_,pvVar2);
        _objc_msgSend(pvVar2,sel_release);
        iVar3 = iVar3 + -1;
      } while (iVar3 != 0);
    }
    pvVar2 = _objc_msgSend(self,sel_itemsCacheValidator);
    _objc_msgSend(pvVar2,sel_setLength_,pvVar1);
    local_14 = pvVar1;
  }
  pvVar1 = _objc_msgSend(self,sel_itemsCacheValidator);
  uVar4 = 0;
  _objc_msgSend(pvVar1,sel_resetBytesInRange_,0,local_14);
  _objc_msgSend(self,sel_sizeToFit);
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
  _objc_msgSend(pvVar1,sel_tile);
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_switching);
  if ((char)pvVar1 == '\0') {
    uVar4 = 0;
    _objc_msgSend(self,sel_scrollItemAtIndexToTop_,0);
  }
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView,uVar4);
  _objc_msgSend(pvVar1,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)reloadData
{
    NSUInteger count;
    NSUInteger cachedCount;
    NSImage *image;

    _msFlags.geometryValid = 0;
    count = [self numberOfItems];
    cachedCount = [[self itemsCacheValidator] length];
    if (cachedCount < count) {
        // Placeholder images; cachedItemImageAtIndex: resizes and draws them.
        for (; cachedCount < count; cachedCount++) {
            image = [[NSImage alloc] initWithSize:NSMakeSize(10.0, 10.0)];
            [image setFlipped:YES];
            [[self itemsCache] addObject:image];
            [image release];
        }
        [(NSMutableData *)[self itemsCacheValidator] setLength:count];
        cachedCount = count;
    }
    [[self itemsCacheValidator] resetBytesInRange:NSMakeRange(0, cachedCount)];
    [self sizeToFit];
    [[self enclosingScrollView] tile];
    if (![[[[HSEditorController sharedDocumentController] currentDocument] modeSwitcher] switching]) {
        [self scrollItemAtIndexToTop:0];
    }
    [[self enclosingScrollView] setNeedsDisplay:YES];
}

- (void)setRemovesSelectionOnClickBetweenItems:(BOOL)aItems
{
    (&_msFlags)->doesntRemoveSelectionOnClickBetweenItems =
    aItems == NO;
}

- (BOOL)removesSelectionOnClickBetweenItems
{
    return (&_msFlags)->doesntRemoveSelectionOnClickBetweenItems ^ 1;
}

- (void)setShowsBadgedIcons:(BOOL)aIcons
{
    BOOL pvVar1;

    pvVar1 = [self showsBadgedIcons];
    (_msFlags).showsBadgedIcons = aIcons != NO;
    if (pvVar1 != [self showsBadgedIcons]) {
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)showsBadgedIcons
{
    return (_msFlags).showsBadgedIcons;
}

- (void)setShowsLabels:(BOOL)aLabels
{
    BOOL pvVar1;

    pvVar1 = [self showsLabels];
    (_msFlags).showsLabels = aLabels != NO;
    if (pvVar1 != [self showsLabels]) {
        (_msFlags).geometryValid = 0;
        [self sizeToFit];
    }
}

- (BOOL)showsLabels
{
    return (_msFlags).showsLabels;
}

- (void)scrollToEndOfDocument:(id)aDocument
{
    if ([self isEnabled]) {
        [self selectItemAtIndex:[self numberOfItems] + -1];
        (_msFlags).didHandleKeyEvent = 1;
    }
}

- (void)scrollToBeginningOfDocument:(id)aDocument
{
    if ([self isEnabled]) {
        [self selectItemAtIndex:0];
        (_msFlags).didHandleKeyEvent = 1;
    }
}

- (void)moveDown:(id)aDown
{
    if ([self isEnabled]) {
        if ([self selectedItemIndex] < ([self numberOfItems] + -1)) {
            [self selectItemAtIndex:[self selectedItemIndex] + 1];
        }
        (_msFlags).didHandleKeyEvent = 1;
    }
}

- (void)moveUp:(id)aUp
{
    if ([self isEnabled]) {
        if ([self selectedItemIndex] != 0) {
            if ([self selectedItemIndex] != NSNotFound) {
                [self selectItemAtIndex:[self selectedItemIndex] + -1];
            }
        }
        (_msFlags).didHandleKeyEvent = 1;
    }
}

- (void)doCommandBySelector:(SEL)aSelector
{
    if (![self respondsToSelector:aSelector]) {
        if ((_msFlags).delegateNotifiedOfKeyEvents != 0) {
            if ([_delegate mediaStrip:self handleKeyEventBySelector:aSelector]) {
                (_msFlags).didHandleKeyEvent = 1;
            }
        }
    }
    else {
        [self performSelector:aSelector withObject:0];
    }
}

- (void)keyDown:(id)aDown
{
    (_msFlags).didHandleKeyEvent = 0;
    [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    if ((_msFlags).didHandleKeyEvent == 0) {
        [super keyDown:aDown];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005a756 @ 0005a756, 282 bytes * /

void FUN_0005a756(HSMediaStripView *self,SEL _cmd,id mouseUp)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  bool bVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabled);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(mouseUp,sel_locationInWindow);
    uVar6 = 0;
    pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
    pvVar1 = pvVar2;
    uVar5 = extraout_EDX_00;
    pvVar3 = _objc_msgSend(self,sel_indexOfItemImageAtPoint_,pvVar2,extraout_EDX_00);
    bVar4 = pvVar3 != (id)0x7fffffff;
    if (!bVar4) {
      uVar5 = extraout_EDX_00;
      pvVar3 = _objc_msgSend(self,sel_indexOfItemAtPoint_,pvVar2,extraout_EDX_00,uVar6);
      pvVar1 = pvVar2;
    }
    pvVar1 = _objc_msgSend(mouseUp,sel_modifierFlags,pvVar1,uVar5,uVar6);
    pvVar2 = _objc_msgSend(mouseUp,sel_clickCount);
    _objc_msgSend(self,sel_clickedInItemAtIndex_insideImage_clickCount_modifiers_,pvVar3,(uint)bVar4
                  ,pvVar2,pvVar1);
  }
  return;
}

*/
- (void)mouseUp:(id)aUp
{
    NSPoint point;
    NSUInteger index;
    BOOL insideImage;

    if (![self isEnabled]) {
        return;
    }
    point = [self convertPoint:[aUp locationInWindow] fromView:nil];
    index = [self indexOfItemImageAtPoint:point];
    insideImage = index != NSNotFound;
    if (!insideImage) {
        index = [self indexOfItemAtPoint:point];
    }
    [self clickedInItemAtIndex:index insideImage:insideImage clickCount:[aUp clickCount] modifiers:[aUp modifierFlags]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005a870 @ 0005a870, 455 bytes * /

void FUN_0005a870(HSMediaStripView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSMediaStripView *pHVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  SEL op;
  undefined *puVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabled);
  if (((char)pvVar1 == '\0') ||
     (pvVar1 = _objc_msgSend(mouseDown,sel_clickCount), pvVar1 != (id)0x1)) {
    pvVar1 = _objc_msgSend(self,sel_window);
    pHVar4 = _objc_msgSend(pvVar1,sel_firstResponder);
    if (pHVar4 == self) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_delegate);
    puVar5 = sel_mediaStripShouldBecomeFirstResponder_;
    pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_mediaStripShouldBecomeFirstResponder_)
    ;
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_delegate,puVar5);
    op = sel_mediaStripShouldBecomeFirstResponder_;
  }
  else {
    pvVar1 = _objc_msgSend(mouseDown,sel_modifierFlags);
    if ((((id)0xffff < pvVar1) && (((uint)pvVar1 & 0xffff0000) != 0x100000)) &&
       (((uint)pvVar1 & 0xffff0000) != 0x20000)) {
      return;
    }
    pvVar1 = _objc_msgSend(mouseDown,sel_locationInWindow);
    uVar7 = 0;
    pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
    uVar6 = extraout_EDX_00;
    pvVar2 = _objc_msgSend(self,sel_indexOfItemImageAtPoint_,pvVar1,extraout_EDX_00);
    pvVar3 = _objc_msgSend(self,sel_selectedItemIndex);
    if (pvVar2 != pvVar3) {
      return;
    }
    if ((self->_msFlags).isFirstResponderStatusDrawn == 0) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_delegate,pvVar1,uVar6,uVar7);
    puVar5 = sel_mediaStripShouldResignFirstResponder_;
    pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_mediaStripShouldResignFirstResponder_)
    ;
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_delegate,puVar5,uVar6);
    op = sel_mediaStripShouldResignFirstResponder_;
  }
  _objc_msgSend(pvVar1,op,self);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    NSUInteger modifiers;
    NSPoint point;

    if (![self isEnabled] || [aDown clickCount] != 1) {
        if ([[self window] firstResponder] == self) {
            return;
        }
        if ([[self delegate] respondsToSelector:@selector(mediaStripShouldBecomeFirstResponder:)]) {
            [[self delegate] mediaStripShouldBecomeFirstResponder:self];
        }
        return;
    }
    // Only plain, Command and Shift clicks hand off the first responder.
    modifiers = [aDown modifierFlags];
    if (modifiers > 0xffff && (modifiers & 0xffff0000) != NSEventModifierFlagCommand && (modifiers & 0xffff0000) != NSEventModifierFlagShift) {
        return;
    }
    point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    if ([self indexOfItemImageAtPoint:point] != [self selectedItemIndex]) {
        return;
    }
    if (!_msFlags.isFirstResponderStatusDrawn) {
        return;
    }
    if ([[self delegate] respondsToSelector:@selector(mediaStripShouldResignFirstResponder:)]) {
        [[self delegate] mediaStripShouldResignFirstResponder:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005aa37 @ 0005aa37, 231 bytes * /

void FUN_0005aa37(HSMediaStripView *self,SEL _cmd,id mouseDragged)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(self,sel_isDragEnabled);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_isEnabled);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(mouseDragged,sel_locationInWindow);
      pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
      pvVar2 = _objc_msgSend(self,sel_indexOfItemImageAtPoint_,pvVar1,extraout_EDX_00);
      if (pvVar2 != (id)0x7fffffff) {
        _objc_msgSend(self,sel_startDragItemAtIndex_at_event_,pvVar2,pvVar1,extraout_EDX_00,
                      mouseDragged);
      }
    }
  }
  return;
}

*/
- (void)mouseDragged:(id)aDragged
{
    NSPoint point;
    NSUInteger index;

    if ([self isDragEnabled] && [self isEnabled]) {
        point = [self convertPoint:[aDragged locationInWindow] fromView:nil];
        index = [self indexOfItemImageAtPoint:point];
        if (index != NSNotFound) {
            [self startDragItemAtIndex:index at:point event:aDragged];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005ab1e @ 0005ab1e, 206 bytes * /

void FUN_0005ab1e(HSMediaStripView *self,SEL _cmd,uint clickedInItemAtIndex,BOOL insideImage,
                 uint clickCount,uint modifiers)

{
  uint uVar1;
  bool bVar2;
  SEL op;
  id pvVar3;
  
  pvVar3 = _objc_msgSend(self,sel_selectedItemIndex);
  if (pvVar3 == (id)clickedInItemAtIndex) {
    if (clickCount == 2) {
      bVar2 = true;
      goto LAB_0005ab53;
    }
    if (2 < clickCount) {
      return;
    }
  }
  else {
    if ((clickedInItemAtIndex == 0x7fffffff) &&
       ((self->_msFlags).doesntRemoveSelectionOnClickBetweenItems != 0)) {
      return;
    }
    _objc_msgSend(self,sel_selectItemAtIndex_,clickedInItemAtIndex);
    pvVar3 = _objc_msgSend(self,sel_selectedItemIndex);
    if (pvVar3 != (id)clickedInItemAtIndex) {
      return;
    }
  }
  bVar2 = false;
LAB_0005ab53:
  if (self->_delegate != (id)0x0) {
    if (bVar2) {
      uVar1 = (uint)self->_msFlags & 0x100;
      op = sel_mediaStrip_doubleClickedOnItemAtIndex_insideImage_modifiers_;
    }
    else {
      uVar1 = (uint)self->_msFlags & 0x80;
      op = sel_mediaStrip_clickedOnItemAtIndex_insideImage_;
    }
    if (uVar1 != 0) {
      _objc_msgSend(self->_delegate,op,self,clickedInItemAtIndex,1);
    }
  }
  return;
}

*/
- (void)clickedInItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aImage clickCount:(NSUInteger)aCount modifiers:(NSUInteger)aModifiers
{
    BOOL doubleClick;

    doubleClick = NO;
    if ([self selectedItemIndex] == aIndex) {
        if (aCount == 2) {
            doubleClick = YES;
        }
        else if (aCount > 2) {
            return;
        }
    }
    else {
        if (aIndex == NSNotFound && _msFlags.doesntRemoveSelectionOnClickBetweenItems) {
            return;
        }
        [self selectItemAtIndex:aIndex];
        if ([self selectedItemIndex] != aIndex) {
            return;
        }
    }
    if (_delegate == nil) {
        return;
    }
    // The original always reports the click as inside the image.
    if (doubleClick) {
        if (_msFlags.delegateNotifiedOfDoubleClick) {
            [_delegate mediaStrip:self doubleClickedOnItemAtIndex:aIndex insideImage:YES modifiers:aModifiers];
        }
    }
    else if (_msFlags.delegateNotifiedOfClick) {
        [_delegate mediaStrip:self clickedOnItemAtIndex:aIndex insideImage:YES];
    }
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005abec @ 0005abec, 516 bytes * /

void FUN_0005abec(HSMediaStripView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined1 local_34 [4];
  float local_30;
  float local_28;
  undefined4 local_24;
  float fStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  pvVar1 = _objc_msgSend(self,sel_geometryCache);
  pvVar2 = _objc_msgSend(self,sel_draggingInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_dropIndex);
  pvVar3 = _objc_msgSend(self,sel_numberOfItems);
  if (pvVar2 < pvVar3) {
    pvVar2 = _objc_msgSend(self,sel_draggingInfo);
    pvVar2 = _objc_msgSend(pvVar2,sel_dropIndex);
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_numberOfItems);
    pvVar2 = (id)((int)pvVar2 + -1);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSMediaStripView,sel_dropIndicatorColor);
  _objc_msgSend(pvVar2,sel_set);
  pvVar2 = _objc_msgSend(self,sel_draggingInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_dropOperation);
  if (pvVar2 == (id)0x1) {
    _objc_msgSend_stret(&local_24,pvVar1,sel_imageFrame);
    _objc_msgSend_stret(local_34,pvVar1,sel_frame);
    pvVar1 = _objc_msgSend(self,sel_draggingInfo);
    pvVar1 = _objc_msgSend(pvVar1,sel_dropIndex);
    pvVar2 = _objc_msgSend(self,sel_numberOfItems);
    if (pvVar1 == pvVar2) {
      local_30 = local_30 + local_28 + -5.0;
    }
    uStack_18 = 0x40000000;
    fStack_20 = local_30;
    pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_smkRoundedBorderPathWithRect_cornerRadius_,
                           CONCAT44(local_30,local_24),CONCAT44(0x40000000,local_1c),0x3f800000);
    _objc_msgSend(pvVar1,sel_fill);
  }
  return;
}

*/
- (void)drawDragFeedback
{
    NSArray *geometry;
    NSUInteger index;
    id item;
    NSRect imageFrame;
    NSRect frame;
    NSRect indicator;

    geometry = [self geometryCache];
    index = [[self draggingInfo] dropIndex];
    if (index >= [self numberOfItems]) {
        index = [self numberOfItems] - 1;
    }
    item = [geometry objectAtIndex:index];
    [(NSColor *)[HSMediaStripView dropIndicatorColor] set];
    if ([(HSMediaStripDraggingInfo *)[self draggingInfo] dropOperation] == 1) {
        // A 2-point bar above the item, or below the last one.
        imageFrame = [item imageFrame];
        frame = [item frame];
        if ([[self draggingInfo] dropIndex] == [self numberOfItems]) {
            frame.origin.y = frame.origin.y + frame.size.height - 5.0;
        }
        indicator = NSMakeRect(imageFrame.origin.x, frame.origin.y, imageFrame.size.width, 2.0);
        [[NSBezierPath smkRoundedBorderPathWithRect:indicator cornerRadius:1.0] fill];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005adf0 @ 0005adf0, 2517 bytes * /

void FUN_0005adf0(HSMediaStripView *self,SEL _cmd,NSRect drawRect)

{
  undefined4 uVar1;
  float fVar2;
  undefined8 uVar3;
  bool bVar4;
  bool bVar5;
  undefined *puVar6;
  undefined *puVar7;
  char cVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  float extraout_EDX;
  int *piVar15;
  int *piVar16;
  int *piVar17;
  int *piVar18;
  float fVar19;
  WBMediaStripFlags *local_bc;
  id local_a8;
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  undefined4 local_94;
  float fStack_90;
  undefined4 local_8c;
  undefined4 uStack_88;
  undefined8 local_84;
  undefined8 local_7c;
  undefined8 local_74;
  undefined8 local_6c;
  undefined8 local_64;
  undefined8 local_5c;
  undefined8 local_54;
  undefined8 local_4c;
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar18 = (int *)&stack0xffffff04;
  pvVar9 = _objc_msgSend(self,sel_numberOfItems);
  puVar6 = PTR_00336078;
  if (pvVar9 != (id)0x0) {
    uVar1 = *(undefined4 *)PTR_00336078;
    fVar2 = *(float *)(PTR_00336078 + 4);
    pvVar10 = _objc_msgSend(self,sel_geometryCache);
    local_8c = *(undefined4 *)(puVar6 + 8);
    uStack_88 = *(undefined4 *)(puVar6 + 0xc);
    local_94 = uVar1;
    fStack_90 = fVar2;
    pvVar11 = _objc_msgSend(self,sel_showsLabels);
    if (((char)pvVar11 == '\0') || ((self->_msFlags).dsSupportsLabels == 0)) {
      bVar4 = false;
    }
    else {
      bVar4 = true;
    }
    pvVar11 = _objc_msgSend(self,sel_showsBadgedIcons);
    if (((char)pvVar11 == '\0') || ((self->_msFlags).dsSupportsBadgedIcons == 0)) {
      bVar5 = true;
    }
    else {
      bVar5 = false;
    }
    local_a8 = (id)0x0;
    fVar2 = *(float *)PTR_00336074;
    for (; local_a8 < pvVar9; local_a8 = (id)((int)local_a8 + 1)) {
      piVar18[2] = (int)local_a8;
      piVar18[1] = (int)sel_objectAtIndex_;
      *piVar18 = (int)pvVar10;
      piVar18[-1] = 0x5af57;
      pvVar11 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
      piVar18[2] = (int)sel_frame;
      piVar18[1] = (int)pvVar11;
      *piVar18 = (int)&local_94;
      piVar18[-1] = 0x5af79;
      _objc_msgSend_stret((void *)*piVar18,(id)piVar18[1],(SEL)piVar18[2]);
      *(ulonglong *)(piVar18 + 5) = CONCAT44(uStack_88,local_8c);
      *(ulonglong *)(piVar18 + 3) = CONCAT44(fStack_90,local_94);
      *(NSSize *)(piVar18 + 1) = drawRect.size;
      *(NSPoint *)(piVar18 + -1) = drawRect.origin;
      piVar18[-2] = 0x5afb4;
      cVar8 = _NSIntersectsRect();
      *piVar18 = (int)sel_activeItemIndex;
      piVar18[-1] = (int)self;
      piVar18[-2] = 0x5afcb;
      pvVar12 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
      puVar7 = cls_NSBezierPath;
      piVar17 = piVar18 + -1;
      if (local_a8 == pvVar12) {
        piVar18[1] = (int)sel_frame;
        *piVar18 = (int)pvVar11;
        piVar18[-1] = (int)&local_84;
        piVar18[-2] = 0x5aff8;
        _objc_msgSend_stret((void *)piVar18[-1],(id)*piVar18,(SEL)piVar18[1]);
        *(undefined8 *)(piVar18 + 1) = local_7c;
        *(undefined8 *)(piVar18 + -1) = local_84;
        piVar18[-2] = (int)&local_74;
        piVar18[4] = 0x40600000;
        piVar18[3] = 0x40600000;
        piVar18[-3] = 0x5b02c;
        _NSInsetRect();
        *(undefined8 *)(piVar18 + 1) = local_6c;
        *(undefined8 *)(piVar18 + -1) = local_74;
        piVar18[-2] = (int)sel_smkRoundedBorderPathWithRect_cornerRadius_;
        piVar18[-3] = (int)puVar7;
        piVar18[3] = 0x40800000;
        piVar18[-4] = 0x5b05f;
        pvVar12 = _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_setLineWidth_;
        piVar18[-3] = (int)pvVar12;
        piVar18[-1] = 0x3f800000;
        piVar18[-4] = 0x5b07b;
        _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_activeOutlineBackgroundColor;
        piVar18[-3] = (int)cls_HSMediaStripView;
        piVar18[-4] = 0x5b093;
        pvVar13 = _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_set;
        piVar18[-3] = (int)pvVar13;
        piVar18[-4] = 0x5b0a5;
        _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_fill;
        piVar18[-3] = (int)pvVar12;
        piVar18[-4] = 0x5b0b7;
        _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_activeOutlineColor;
        piVar18[-3] = (int)cls_HSMediaStripView;
        piVar18[-4] = 0x5b0cf;
        pvVar13 = _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_set;
        piVar18[-3] = (int)pvVar13;
        piVar18[-4] = 0x5b0e1;
        _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar18[-2] = (int)sel_stroke;
        piVar18[-3] = (int)pvVar12;
        piVar18[-4] = 0x5b0f3;
        _objc_msgSend((id)piVar18[-3],(SEL)piVar18[-2]);
        piVar17 = piVar18 + -3;
      }
      piVar18 = piVar17;
      if (cVar8 == '\0') {
        if (drawRect.origin.y + drawRect.size.height <= fStack_90) break;
      }
      else {
        piVar18[1] = (int)sel_selectedItemIndex;
        *piVar18 = (int)self;
        piVar18[-1] = 0x5b110;
        pvVar12 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
        if (local_a8 == pvVar12) {
          pvVar12 = self->_dataSource;
          piVar18[3] = (int)local_a8;
          piVar18[2] = (int)self;
          piVar18[1] = (int)sel_mediaStrip_imageForItemAtIndex_;
          *piVar18 = (int)pvVar12;
          piVar18[-1] = 0x5b24e;
          pvVar12 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          piVar18[1] = (int)sel_saveGraphicsState;
          *piVar18 = (int)cls_NSGraphicsContext;
          piVar18[-1] = 0x5b26c;
          _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          puVar7 = cls_NSBezierPath;
          piVar18[2] = (int)sel_imageBorderFrame;
          piVar18[1] = (int)pvVar11;
          *piVar18 = (int)&local_64;
          piVar18[-1] = 0x5b291;
          _objc_msgSend_stret((void *)*piVar18,(id)piVar18[1],(SEL)piVar18[2]);
          piVar15 = piVar18 + -1;
          *(undefined8 *)(piVar18 + 3) = local_5c;
          *(undefined8 *)(piVar18 + 1) = local_64;
          *piVar18 = (int)sel_bezierPathWithRect_;
          piVar18[-1] = (int)puVar7;
          piVar18[-2] = 0x5b2bc;
          pvVar13 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_setLineWidth_;
          piVar18[-1] = (int)pvVar13;
          piVar18[1] = 0x40000000;
          piVar18[-2] = 0x5b2d8;
          _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_HSMediaStripView_shadow;
          piVar18[-1] = (int)self;
          piVar18[-2] = 0x5b2ed;
          pvVar14 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_set;
          piVar18[-1] = (int)pvVar14;
          piVar18[-2] = 0x5b2ff;
          _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          puVar7 = cls_HSMediaStripView;
          *piVar18 = (int)sel_firstResponderStatus;
          piVar18[-1] = (int)self;
          piVar18[-2] = 0x5b31a;
          pvVar14 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          piVar18[2] = (uint)pvVar14 & 0xff;
          *piVar18 = (int)sel_imageBorderColorSelected_firstResponder_;
          piVar18[-1] = (int)puVar7;
          piVar18[1] = 1;
          piVar18[-2] = 0x5b33b;
          pvVar14 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_set;
          piVar18[-1] = (int)pvVar14;
          piVar18[-2] = 0x5b34d;
          _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_stroke;
          piVar18[-1] = (int)pvVar13;
          piVar18[-2] = 0x5b35f;
          _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_restoreGraphicsState;
          piVar18[-1] = (int)cls_NSGraphicsContext;
          piVar18[-2] = 0x5b377;
          _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_saveGraphicsState;
          piVar18[-1] = (int)cls_NSGraphicsContext;
          piVar18[-2] = 0x5b38f;
          _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          *piVar18 = (int)sel_isFlipped;
          piVar18[-1] = (int)self;
          piVar18[-2] = 0x5b3a4;
          pvVar13 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          puVar7 = cls_NSAffineTransform;
          if ((char)pvVar13 != '\0') {
            piVar18[1] = (int)sel_imageFrame;
            *piVar18 = (int)pvVar11;
            piVar18[-1] = (int)&local_54;
            piVar18[-2] = 0x5b3cd;
            _objc_msgSend_stret((void *)piVar18[-1],(id)*piVar18,(SEL)piVar18[1]);
            piVar15 = piVar18 + -2;
            *(undefined8 *)(piVar18 + 2) = local_4c;
            *(undefined8 *)piVar18 = local_54;
            piVar18[-1] = (int)sel_hyperYFlipInRect_;
            piVar18[-2] = (int)puVar7;
            piVar18[-3] = 0x5b3f8;
            pvVar13 = _objc_msgSend((id)piVar18[-2],(SEL)piVar18[-1]);
            piVar18[-1] = (int)sel_concat;
            piVar18[-2] = (int)pvVar13;
            piVar18[-3] = 0x5b40a;
            _objc_msgSend((id)piVar18[-2],(SEL)piVar18[-1]);
          }
          piVar15[2] = (int)sel_imageFrame;
          piVar15[1] = (int)pvVar11;
          *piVar15 = (int)&local_44;
          piVar15[-1] = 0x5b429;
          _objc_msgSend_stret((void *)*piVar15,(id)piVar15[1],(SEL)piVar15[2]);
          piVar16 = piVar15 + -1;
          uVar3 = *(undefined8 *)puVar6;
          *(undefined8 *)(piVar15 + 7) = *(undefined8 *)(puVar6 + 8);
          *(undefined8 *)(piVar15 + 5) = uVar3;
          *(undefined8 *)(piVar15 + 3) = local_3c;
          *(undefined8 *)(piVar15 + 1) = local_44;
          *piVar15 = (int)sel_drawInRect_fromRect_operation_fraction_;
          piVar15[-1] = (int)pvVar12;
          piVar15[10] = 0x3f800000;
          piVar15[9] = 2;
          piVar15[-2] = 0x5b485;
          _objc_msgSend((id)piVar15[-1],(SEL)*piVar15);
          *piVar15 = (int)sel_restoreGraphicsState;
          piVar15[-1] = (int)cls_NSGraphicsContext;
          piVar15[-2] = 0x5b49d;
          _objc_msgSend((id)piVar15[-1],(SEL)*piVar15);
          piVar18 = piVar15;
          if (bVar4) {
            *piVar15 = (int)sel_firstResponderStatus;
            piVar15[-1] = (int)self;
            piVar15[-2] = 0x5b4bf;
            pvVar12 = _objc_msgSend((id)piVar15[-1],(SEL)*piVar15);
            puVar7 = cls_HSMediaStripView;
            if ((char)pvVar12 != '\0') {
              *piVar15 = (int)sel_firstResponderStatus;
              piVar15[-1] = (int)self;
              piVar15[-2] = 0x5b4e2;
              pvVar12 = _objc_msgSend((id)piVar15[-1],(SEL)*piVar15);
              piVar15[2] = (uint)pvVar12 & 0xff;
              *piVar15 = (int)sel_imageBorderColorSelected_firstResponder_;
              piVar15[-1] = (int)puVar7;
              piVar15[1] = 1;
              piVar15[-2] = 0x5b503;
              pvVar12 = _objc_msgSend((id)piVar15[-1],(SEL)*piVar15);
              *piVar15 = (int)sel_set;
              piVar15[-1] = (int)pvVar12;
              piVar15[-2] = 0x5b515;
              _objc_msgSend((id)piVar15[-1],(SEL)*piVar15);
              puVar7 = cls_NSBezierPath;
              piVar15[1] = (int)sel_labelFrame;
              *piVar15 = (int)pvVar11;
              piVar15[-1] = (int)&local_34;
              piVar15[-2] = 0x5b53a;
              _objc_msgSend_stret((void *)piVar15[-1],(id)*piVar15,(SEL)piVar15[1]);
              piVar16 = piVar15 + -2;
              *(undefined8 *)(piVar15 + 2) = local_2c;
              *(undefined8 *)piVar15 = local_34;
              piVar15[-1] = (int)sel_smkFinderSelectionStyleBorderPathWithRect_;
              piVar15[-2] = (int)puVar7;
              piVar15[-3] = 0x5b565;
              pvVar12 = _objc_msgSend((id)piVar15[-2],(SEL)piVar15[-1]);
              piVar15[-1] = (int)sel_fill;
              piVar15[-2] = (int)pvVar12;
              piVar15[-3] = 0x5b577;
              _objc_msgSend((id)piVar15[-2],(SEL)piVar15[-1]);
            }
            piVar16[1] = (int)sel_firstResponderStatus;
            *piVar16 = (int)self;
            piVar16[-1] = 0x5b58c;
            pvVar13 = _objc_msgSend((id)*piVar16,(SEL)piVar16[1]);
            piVar16[1] = (int)sel_firstResponderStatus;
            *piVar16 = (int)self;
            piVar16[-1] = 0x5b5a3;
            _objc_msgSend((id)*piVar16,(SEL)piVar16[1]);
            piVar16[2] = (int)sel_labelFrame;
            piVar16[1] = (int)pvVar11;
            *piVar16 = (int)&local_24;
            piVar16[-1] = 0x5b5c4;
            _objc_msgSend_stret((void *)*piVar16,(id)piVar16[1],(SEL)piVar16[2]);
            pvVar12 = self->_dataSource;
            piVar16[2] = (int)local_a8;
            piVar16[1] = (int)self;
            *piVar16 = (int)sel_mediaStrip_labelForItemAtIndex_;
            piVar16[-1] = (int)pvVar12;
            piVar16[-2] = 0x5b5f0;
            _objc_msgSend((id)piVar16[-1],(SEL)*piVar16);
            *(undefined8 *)(piVar16 + 1) = local_1c;
            *(undefined8 *)(piVar16 + -1) = local_24;
            piVar16[3] = (int)(char)pvVar13;
            piVar16[-2] = 0x5b616;
            FUN_0005d175();
            piVar18 = piVar16;
          }
          piVar17 = piVar18 + -1;
          *piVar18 = (int)sel_firstResponderStatus;
          piVar18[-1] = (int)self;
          piVar18[-2] = 0x5b62b;
          pvVar12 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
          local_bc->isFirstResponderStatusDrawn = (char)pvVar12 != '\0';
        }
        else {
          piVar18[1] = (int)sel_saveGraphicsState;
          *piVar18 = (int)cls_NSGraphicsContext;
          piVar18[-1] = 0x5b134;
          _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          piVar18[1] = (int)sel_isFlipped;
          *piVar18 = (int)self;
          piVar18[-1] = 0x5b149;
          pvVar12 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          if ((char)pvVar12 != '\0') {
            *(ulonglong *)(piVar18 + 4) = CONCAT44(uStack_88,local_8c);
            *(ulonglong *)(piVar18 + 2) = CONCAT44(fStack_90,local_94);
            piVar18[1] = (int)sel_hyperYFlipInRect_;
            *piVar18 = (int)cls_NSAffineTransform;
            piVar18[-1] = 0x5b181;
            pvVar12 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
            piVar18[1] = (int)sel_concat;
            *piVar18 = (int)pvVar12;
            piVar18[-1] = 0x5b193;
            _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          }
          piVar18[2] = (int)local_a8;
          piVar18[1] = (int)sel_cachedItemImageAtIndex_;
          *piVar18 = (int)self;
          piVar18[-1] = 0x5b1b2;
          pvVar12 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          uVar3 = *(undefined8 *)puVar6;
          *(undefined8 *)(piVar18 + 8) = *(undefined8 *)(puVar6 + 8);
          *(undefined8 *)(piVar18 + 6) = uVar3;
          *(ulonglong *)(piVar18 + 4) = CONCAT44(uStack_88,local_8c);
          *(ulonglong *)(piVar18 + 2) = CONCAT44(fStack_90,local_94);
          piVar18[1] = (int)sel_drawInRect_fromRect_operation_fraction_;
          *piVar18 = (int)pvVar12;
          piVar18[0xb] = 0x3f800000;
          piVar18[10] = 2;
          piVar18[-1] = 0x5b20b;
          _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          piVar18[1] = (int)sel_restoreGraphicsState;
          *piVar18 = (int)cls_NSGraphicsContext;
          piVar18[-1] = 0x5b223;
          _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
          piVar17 = piVar18;
        }
        piVar18 = piVar17;
        if (!bVar5) {
          pvVar12 = self->_dataSource;
          piVar17[3] = (int)local_a8;
          piVar17[2] = (int)self;
          piVar17[1] = (int)sel_mediaStrip_badgedIconForItemAtIndex_;
          *piVar17 = (int)pvVar12;
          piVar17[-1] = 0x5b67c;
          pvVar12 = _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
          if (pvVar12 != (id)0x0) {
            piVar17[1] = (int)sel_size;
            *piVar17 = (int)pvVar12;
            piVar17[-1] = 0x5b69c;
            pvVar13 = _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
            piVar17[2] = (int)sel_imageFrame;
            piVar17[1] = (int)pvVar11;
            *piVar17 = (int)&local_a4;
            piVar17[-1] = 0x5b6c2;
            _objc_msgSend_stret((void *)*piVar17,(id)piVar17[1],(SEL)piVar17[2]);
            piVar18 = piVar17 + -1;
            if ((float)pvVar13 <= local_9c) {
              fVar19 = (local_a4 + local_9c) - (float)pvVar13;
            }
            else {
              fVar19 = ((local_a4 + local_9c * 0.5) - ((float)pvVar13 * 0.5 + fVar2)) + fVar2;
            }
            piVar17[2] = (int)(((local_a0 + local_98) - extraout_EDX) + extraout_EDX);
            piVar17[1] = (int)fVar19;
            *piVar17 = (int)sel_compositeToPoint_operation_;
            piVar17[-1] = (int)pvVar12;
            piVar17[3] = 2;
            piVar17[-2] = 0x5b758;
            _objc_msgSend((id)piVar17[-1],(SEL)*piVar17);
          }
        }
      }
    }
    piVar18[1] = (int)sel_draggingInfo;
    *piVar18 = (int)self;
    piVar18[-1] = 0x5b7a1;
    pvVar9 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
    if (pvVar9 != (id)0x0) {
      piVar18[1] = (int)sel_drawDragFeedback;
      *piVar18 = (int)self;
      piVar18[-1] = 0x5b7ba;
      _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
    }
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    NSUInteger count;
    NSUInteger index;
    NSArray *geometry;
    id item;
    NSRect frame;
    NSRect imageFrame;
    BOOL drawsLabels;
    BOOL drawsBadges;
    BOOL intersects;
    BOOL firstResponder;
    NSBezierPath *path;
    NSImage *image;
    NSImage *badge;
    NSSize badgeSize;
    CGFloat badgeX;

    count = [self numberOfItems];
    if (count == 0) {
        return;
    }
    geometry = [self geometryCache];
    drawsLabels = [self showsLabels] && _msFlags.dsSupportsLabels;
    drawsBadges = [self showsBadgedIcons] && _msFlags.dsSupportsBadgedIcons;
    for (index = 0; index < count; index++) {
        item = [geometry objectAtIndex:index];
        frame = [item frame];
        intersects = NSIntersectsRect(frame, aRect);
        if (index == [self activeItemIndex]) {
            path = [NSBezierPath smkRoundedBorderPathWithRect:NSInsetRect([item frame], 3.5, 3.5) cornerRadius:4.0];
            [path setLineWidth:1.0];
            [(NSColor *)[HSMediaStripView activeOutlineBackgroundColor] set];
            [path fill];
            [(NSColor *)[HSMediaStripView activeOutlineColor] set];
            [path stroke];
        }
        if (!intersects) {
            if (aRect.origin.y + aRect.size.height <= frame.origin.y) {
                break;
            }
            continue;
        }
        if (index == [self selectedItemIndex]) {
            // The selected item is drawn live; the others come from the image cache.
            image = [_dataSource mediaStrip:self imageForItemAtIndex:index];
            [NSGraphicsContext saveGraphicsState];
            path = [NSBezierPath bezierPathWithRect:[item imageBorderFrame]];
            [path setLineWidth:2.0];
            [(SMKShadow *)[self HSMediaStripView_shadow] set];
            [(NSColor *)[HSMediaStripView imageBorderColorSelected:YES firstResponder:[self firstResponderStatus]] set];
            [path stroke];
            [NSGraphicsContext restoreGraphicsState];
            [NSGraphicsContext saveGraphicsState];
            if ([self isFlipped]) {
                [[NSAffineTransform hyperYFlipInRect:[item imageFrame]] concat];
            }
            [image drawInRect:[item imageFrame] fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            [NSGraphicsContext restoreGraphicsState];
            if (drawsLabels) {
                if ([self firstResponderStatus]) {
                    [(NSColor *)[HSMediaStripView imageBorderColorSelected:YES firstResponder:[self firstResponderStatus]] set];
                    [[NSBezierPath smkFinderSelectionStyleBorderPathWithRect:[item labelFrame]] fill];
                }
                firstResponder = [self firstResponderStatus];
                HSMediaStripDrawLabel([_dataSource mediaStrip:self labelForItemAtIndex:index], [item labelFrame], firstResponder, firstResponder);
            }
            _msFlags.isFirstResponderStatusDrawn = [self firstResponderStatus] ? 1 : 0;
        }
        else {
            [NSGraphicsContext saveGraphicsState];
            if ([self isFlipped]) {
                [[NSAffineTransform hyperYFlipInRect:frame] concat];
            }
            [[self cachedItemImageAtIndex:index] drawInRect:frame fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            [NSGraphicsContext restoreGraphicsState];
        }
        if (drawsBadges) {
            badge = [_dataSource mediaStrip:self badgedIconForItemAtIndex:index];
            if (badge != nil) {
                // Bottom-right corner of the image, centred when wider than it.
                badgeSize = [badge size];
                imageFrame = [item imageFrame];
                if (badgeSize.width <= imageFrame.size.width) {
                    badgeX = imageFrame.origin.x + imageFrame.size.width - badgeSize.width;
                }
                else {
                    badgeX = imageFrame.origin.x + imageFrame.size.width * 0.5 - badgeSize.width * 0.5;
                }
                // compositeToPoint: placed the badge's bottom edge at the image's bottom.
                [badge drawInRect:NSMakeRect(badgeX, imageFrame.origin.y + imageFrame.size.height - badgeSize.height, badgeSize.width, badgeSize.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
            }
        }
    }
    if ([self draggingInfo] != nil) {
        [self drawDragFeedback];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unregisterDraggedTypes];
    [_geometryCache release];
    [_shadow release];
    [_itemsCache release];
    [_itemsCacheValidator release];
    [_draggingInfo release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00057c7b @ 00057c7b, 93 bytes * /

id FUN_00057c7b(HSMediaStripView *self,SEL _cmd,NSRect initWithFrame)

{
  id pvVar1;
  HSMediaStripView *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_NSView_0034e3e0;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x70) = 0x7fffffff;
    *(undefined4 *)((int)pvVar1 + 0x74) = 0x7fffffff;
  }
  return pvVar1;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _selectedItemIndex = NSNotFound;
        _activeItemIndex = NSNotFound;
    }
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005b8aa @ 0005b8aa, 1718 bytes * /

id FUN_0005b8aa(HSMediaStripView *self,SEL _cmd,uint cachedItemImageAtIndex)

{
  undefined8 uVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int *piVar7;
  int *piVar8;
  int aiStack_fc [4];
  int local_d0 [14];
  undefined1 local_95;
  undefined1 local_94 [8];
  undefined4 local_8c;
  undefined4 local_88;
  undefined4 local_84;
  undefined4 uStack_80;
  undefined4 local_7c;
  undefined4 uStack_78;
  undefined1 local_74 [16];
  undefined1 local_64 [16];
  undefined1 local_54 [16];
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar3 = _objc_msgSend(self,sel_itemsCacheValidator);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  if (cachedItemImageAtIndex <= pvVar3) {
    pvVar3 = _objc_msgSend(self,sel_itemsCacheValidator);
    pvVar3 = _objc_msgSend(pvVar3,sel_bytes);
    if ('\0' < *(char *)((int)pvVar3 + cachedItemImageAtIndex)) {
      pvVar3 = _objc_msgSend(self,sel_itemsCache);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_);
      return pvVar3;
    }
  }
  pvVar3 = _objc_msgSend(self,sel_geometryCache);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_);
  _objc_msgSend_stret(local_94,pvVar3,sel_frame);
  pvVar4 = _objc_msgSend(self,sel_itemsCache);
  pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_);
  pvVar5 = _objc_msgSend(pvVar4,sel_isCachedSeparately);
  if ((char)pvVar5 == '\0') {
    _objc_msgSend(pvVar4,sel_setCachedSeparately_);
  }
  _objc_msgSend(pvVar4,sel_setSize_);
  _objc_msgSend(pvVar4,sel_lockFocus);
  local_84 = 0;
  uStack_80 = 0;
  local_7c = local_8c;
  uStack_78 = local_88;
  _NSRectFillUsingOperation();
  _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
  pvVar5 = _objc_msgSend(cls_NSAffineTransform,sel_transform);
  _objc_msgSend_stret(local_74,pvVar3,sel_frame);
  _objc_msgSend_stret(local_64,pvVar3,sel_frame);
  _objc_msgSend(pvVar5,sel_translateXBy_yBy_);
  _objc_msgSend(pvVar5,sel_concat);
  pvVar5 = _objc_msgSend(self,sel_showsLabels);
  piVar7 = (int *)&stack0xffffff18;
  if (((char)pvVar5 != '\0') &&
     (piVar7 = (int *)&stack0xffffff18, (self->_msFlags).dsSupportsLabels != 0)) {
    _objc_msgSend(self,sel_firstResponderStatus);
    _objc_msgSend_stret(local_54,pvVar3,sel_labelFrame);
    piVar7 = (int *)&stack0xffffff14;
    _objc_msgSend(self->_dataSource,sel_mediaStrip_labelForItemAtIndex_);
    FUN_0005d175();
  }
  puVar2 = cls_NSBezierPath;
  piVar7[2] = (int)sel_imageBorderFrame;
  piVar7[1] = (int)pvVar3;
  *piVar7 = (int)&local_44;
  piVar7[-1] = 0x5bbf7;
  _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
  piVar8 = piVar7 + -1;
  *(undefined8 *)(piVar7 + 3) = local_3c;
  *(undefined8 *)(piVar7 + 1) = local_44;
  *piVar7 = (int)sel_bezierPathWithRect_;
  piVar7[-1] = (int)puVar2;
  piVar7[-2] = 0x5bc22;
  pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_setLineWidth_;
  piVar7[-1] = (int)pvVar5;
  piVar7[1] = 0x40000000;
  piVar7[-2] = 0x5bc3e;
  _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_HSMediaStripView_shadow;
  piVar7[-1] = (int)self;
  piVar7[-2] = 0x5bc53;
  pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_set;
  piVar7[-1] = (int)pvVar6;
  piVar7[-2] = 0x5bc65;
  _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  puVar2 = cls_HSMediaStripView;
  *piVar7 = (int)sel_firstResponderStatus;
  piVar7[-1] = (int)self;
  piVar7[-2] = 0x5bc80;
  pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  piVar7[2] = (uint)pvVar6 & 0xff;
  *piVar7 = (int)sel_imageBorderColorSelected_firstResponder_;
  piVar7[-1] = (int)puVar2;
  piVar7[1] = 0;
  piVar7[-2] = 0x5bca1;
  pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_set;
  piVar7[-1] = (int)pvVar6;
  piVar7[-2] = 0x5bcb3;
  _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_fill;
  piVar7[-1] = (int)pvVar5;
  piVar7[-2] = 0x5bcc5;
  _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  pvVar5 = self->_dataSource;
  piVar7[2] = cachedItemImageAtIndex;
  piVar7[1] = (int)self;
  *piVar7 = (int)sel_mediaStrip_imageForItemAtIndex_;
  piVar7[-1] = (int)pvVar5;
  piVar7[-2] = 0x5bce8;
  pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_saveGraphicsState;
  piVar7[-1] = (int)cls_NSGraphicsContext;
  piVar7[-2] = 0x5bd02;
  _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_currentContext;
  piVar7[-1] = (int)cls_NSGraphicsContext;
  piVar7[-2] = 0x5bd1a;
  pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  *piVar7 = (int)sel_isFlipped;
  piVar7[-1] = (int)pvVar6;
  piVar7[-2] = 0x5bd2c;
  pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  puVar2 = cls_NSAffineTransform;
  if ((char)pvVar6 != '\0') {
    piVar7[1] = (int)sel_imageFrame;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = (int)&local_34;
    piVar7[-2] = 0x5bd55;
    _objc_msgSend_stret((void *)piVar7[-1],(id)*piVar7,(SEL)piVar7[1]);
    piVar8 = piVar7 + -2;
    *(undefined8 *)(piVar7 + 2) = local_2c;
    *(undefined8 *)piVar7 = local_34;
    piVar7[-1] = (int)sel_hyperYFlipInRect_;
    piVar7[-2] = (int)puVar2;
    piVar7[-3] = 0x5bd80;
    pvVar6 = _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
    piVar7[-1] = (int)sel_concat;
    piVar7[-2] = (int)pvVar6;
    piVar7[-3] = 0x5bd92;
    _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
  }
  piVar8[2] = (int)sel_imageFrame;
  piVar8[1] = (int)pvVar3;
  *piVar8 = (int)&local_24;
  piVar8[-1] = 0x5bdb1;
  _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
  uVar1 = *(undefined8 *)PTR_00336078;
  *(undefined8 *)(piVar8 + 7) = *(undefined8 *)(PTR_00336078 + 8);
  *(undefined8 *)(piVar8 + 5) = uVar1;
  *(undefined8 *)(piVar8 + 3) = local_1c;
  *(undefined8 *)(piVar8 + 1) = local_24;
  *piVar8 = (int)sel_drawInRect_fromRect_operation_fraction_;
  piVar8[-1] = (int)pvVar5;
  piVar8[10] = 0x3f800000;
  piVar8[9] = 2;
  piVar8[-2] = 0x5be07;
  _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  *piVar8 = (int)sel_restoreGraphicsState;
  piVar8[-1] = (int)cls_NSGraphicsContext;
  piVar8[-2] = 0x5be1f;
  _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  *piVar8 = (int)sel_restoreGraphicsState;
  piVar8[-1] = (int)cls_NSGraphicsContext;
  piVar8[-2] = 0x5be37;
  _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  *piVar8 = (int)sel_unlockFocus;
  piVar8[-1] = (int)pvVar4;
  piVar8[-2] = 0x5be4f;
  _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  *piVar8 = (int)sel_itemsCacheValidator;
  piVar8[-1] = (int)self;
  piVar8[-2] = 0x5be64;
  pvVar3 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  *piVar8 = (int)sel_length;
  piVar8[-1] = (int)pvVar3;
  piVar8[-2] = 0x5be76;
  pvVar3 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  *piVar8 = (int)sel_numberOfItems;
  piVar8[-1] = (int)self;
  piVar8[-2] = 0x5be8a;
  pvVar5 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  if (pvVar3 < pvVar5) {
    *piVar8 = (int)sel_itemsCacheValidator;
    piVar8[-1] = (int)self;
    piVar8[-2] = 0x5bea0;
    pvVar3 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
    *piVar8 = (int)sel_numberOfItems;
    piVar8[-1] = (int)self;
    piVar8[-2] = 0x5beb4;
    pvVar5 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
    piVar8[1] = (int)pvVar5;
    *piVar8 = (int)sel_setLength_;
    piVar8[-1] = (int)pvVar3;
    piVar8[-2] = 0x5beca;
    _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  }
  local_95 = 1;
  *piVar8 = (int)sel_itemsCacheValidator;
  piVar8[-1] = (int)self;
  piVar8[-2] = 0x5bee6;
  pvVar3 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  piVar8[3] = (int)&local_95;
  piVar8[1] = cachedItemImageAtIndex;
  *piVar8 = (int)sel_replaceBytesInRange_withBytes_length_;
  piVar8[-1] = (int)pvVar3;
  piVar8[4] = 1;
  piVar8[2] = 1;
  piVar8[-2] = 0x5bf19;
  _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  return pvVar4;
}

*/
- (id)cachedItemImageAtIndex:(NSUInteger)aIndex
{
    id item;
    NSRect frame;
    NSImage *cachedImage;
    NSAffineTransform *transform;
    BOOL firstResponder;
    NSBezierPath *path;
    NSImage *image;
    char valid;

    // Fix: the original also read the validator byte at index == length.
    if (aIndex < [[self itemsCacheValidator] length] && ((const char *)[[self itemsCacheValidator] bytes])[aIndex] > 0) {
        return [[self itemsCache] objectAtIndex:aIndex];
    }
    item = [[self geometryCache] objectAtIndex:aIndex];
    frame = [item frame];
    cachedImage = [[self itemsCache] objectAtIndex:aIndex];
    if (![cachedImage isCachedSeparately]) {
        [cachedImage setCachedSeparately:YES];
    }
    [cachedImage setSize:frame.size];
    [cachedImage lockFocus];
    NSRectFillUsingOperation(NSMakeRect(0.0, 0.0, frame.size.width, frame.size.height), NSCompositingOperationClear);
    [NSGraphicsContext saveGraphicsState];
    // The original moves the item to the image origin vertically only.
    transform = [NSAffineTransform transform];
    [transform translateXBy:[item frame].origin.x yBy:-[item frame].origin.y];
    [transform concat];
    firstResponder = NO;
    if ([self showsLabels] && _msFlags.dsSupportsLabels) {
        firstResponder = [self firstResponderStatus];
        HSMediaStripDrawLabel([_dataSource mediaStrip:self labelForItemAtIndex:aIndex], [item labelFrame], NO, firstResponder);
    }
    path = [NSBezierPath bezierPathWithRect:[item imageBorderFrame]];
    [path setLineWidth:2.0];
    [(SMKShadow *)[self HSMediaStripView_shadow] set];
    [(NSColor *)[HSMediaStripView imageBorderColorSelected:NO firstResponder:[self firstResponderStatus]] set];
    [path fill];
    image = [_dataSource mediaStrip:self imageForItemAtIndex:aIndex];
    [NSGraphicsContext saveGraphicsState];
    if ([[NSGraphicsContext currentContext] isFlipped]) {
        [[NSAffineTransform hyperYFlipInRect:[item imageFrame]] concat];
    }
    [image drawInRect:[item imageFrame] fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    [NSGraphicsContext restoreGraphicsState];
    [cachedImage unlockFocus];
    if ([[self itemsCacheValidator] length] < [self numberOfItems]) {
        [(NSMutableData *)[self itemsCacheValidator] setLength:[self numberOfItems]];
    }
    valid = 1;
    [[self itemsCacheValidator] replaceBytesInRange:NSMakeRange(aIndex, 1) withBytes:&valid length:1];
    return cachedImage;
}

- (id)itemsCacheValidator
{
    id pvVar1;

    pvVar1 = _itemsCacheValidator;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableData new];
        _itemsCacheValidator = pvVar1;
    }
    return pvVar1;
}

- (id)itemsCache
{
    id pvVar1;

    pvVar1 = _itemsCache;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _itemsCache = pvVar1;
    }
    return pvVar1;
}

- (void)setNeedsDisplayForItemAtIndex:(NSUInteger)aIndex
{
    [self setNeedsDisplayInRect:[[[self geometryCache] objectAtIndex:aIndex] frame]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005c057 @ 0005c057, 822 bytes * /

void FUN_0005c057(HSMediaStripView *self,SEL _cmd,uint recalculateGeometryForItemAtIndex)

{
  undefined4 uVar1;
  undefined *puVar2;
  char cVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  int extraout_EDX;
  int *piVar9;
  float fVar10;
  undefined4 uStack_b8;
  float local_70;
  undefined4 local_64;
  float fStack_60;
  undefined4 local_5c;
  float fStack_58;
  int local_54;
  float local_50;
  undefined1 local_44 [4];
  float local_40;
  float local_38;
  undefined8 local_34;
  undefined8 local_2c;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  puVar2 = PTR_00336078;
  uVar1 = *(undefined4 *)PTR_00336078;
  fVar10 = *(float *)(PTR_00336078 + 4);
  self_00 = _objc_msgSend(self,sel_geometryCache);
  local_5c = *(undefined4 *)(puVar2 + 8);
  fStack_58 = *(float *)(puVar2 + 0xc);
  local_64 = uVar1;
  fStack_60 = fVar10;
  pvVar4 = _objc_msgSend(self_00,sel_objectAtIndex_);
  _objc_msgSend_stret(&local_64,pvVar4,sel_frame);
  _objc_msgSend_stret(&local_54,self,sel_bounds);
  piVar9 = (int *)&stack0xffffff4c;
  local_70 = local_50;
  if (recalculateGeometryForItemAtIndex != 0) {
    uStack_b8 = 0x5c14d;
    pvVar5 = _objc_msgSend(self_00,sel_objectAtIndex_);
    uStack_b8 = 0x5c166;
    _objc_msgSend_stret(local_44,pvVar5,sel_frame);
    piVar9 = &uStack_b8;
    local_70 = local_40 + local_38;
  }
  pvVar5 = self->_dataSource;
  piVar9[3] = recalculateGeometryForItemAtIndex;
  piVar9[2] = (int)self;
  piVar9[1] = (int)sel_mediaStrip_imageSizeForItemAtIndex_;
  *piVar9 = (int)pvVar5;
  piVar9[-1] = 0x5c198;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[1] = (int)sel_showsLabels;
  *piVar9 = (int)self;
  piVar9[-1] = 0x5c1b2;
  pvVar6 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  if (((char)pvVar6 == '\0') || ((self->_msFlags).dsSupportsLabels == 0)) {
    pcVar8 = (cfstringStruct *)0x0;
  }
  else {
    pvVar6 = self->_dataSource;
    piVar9[3] = recalculateGeometryForItemAtIndex;
    piVar9[2] = (int)self;
    piVar9[1] = (int)sel_mediaStrip_labelForItemAtIndex_;
    *piVar9 = (int)pvVar6;
    piVar9[-1] = 0x5c1f3;
    pcVar7 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
    pcVar8 = &cfstr_empty;
    if (pcVar7 != (cfstringStruct *)0x0) {
      pcVar8 = pcVar7;
    }
  }
  fVar10 = self->_stripWidth;
  piVar9[8] = (int)local_70;
  piVar9[7] = local_54;
  piVar9[6] = (int)fVar10;
  piVar9[5] = (int)pcVar8;
  piVar9[4] = extraout_EDX;
  piVar9[3] = (int)pvVar5;
  piVar9[2] = (int)pvVar4;
  piVar9[1] = (int)sel_calculateGeometry_forImageSize_label_limitToWidth_offset_;
  *piVar9 = (int)self;
  piVar9[-1] = 0x5c255;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[1] = (int)sel_numberOfItems;
  *piVar9 = (int)self;
  pvVar6 = (id)(recalculateGeometryForItemAtIndex + 1);
  piVar9[-1] = 0x5c268;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  if (pvVar6 < pvVar5) {
    piVar9[2] = (int)sel_frame;
    piVar9[1] = (int)pvVar4;
    *piVar9 = (int)&local_34;
    piVar9[-1] = 0x5c28c;
    _objc_msgSend_stret((void *)*piVar9,(id)piVar9[1],(SEL)piVar9[2]);
    *(ulonglong *)(piVar9 + 5) = CONCAT44(fStack_58,local_5c);
    *(ulonglong *)(piVar9 + 3) = CONCAT44(fStack_60,local_64);
    *(undefined8 *)(piVar9 + 1) = local_2c;
    *(undefined8 *)(piVar9 + -1) = local_34;
    piVar9[-2] = 0x5c2bf;
    cVar3 = _NSEqualRects();
    if (cVar3 == '\0') {
      piVar9[1] = (int)sel_frame;
      *piVar9 = (int)pvVar4;
      piVar9[-1] = (int)local_24;
      piVar9[-2] = 0x5c2e3;
      _objc_msgSend_stret((void *)piVar9[-1],(id)*piVar9,(SEL)piVar9[1]);
      fVar10 = fStack_60 + fStack_58;
      piVar9[-1] = (int)sel_numberOfItems;
      piVar9[-2] = (int)self;
      piVar9[-3] = 0x5c318;
      pvVar4 = _objc_msgSend((id)piVar9[-2],(SEL)piVar9[-1]);
      if (pvVar6 < pvVar4) {
        uVar1 = *(undefined4 *)PTR_00336074;
        do {
          *piVar9 = (int)pvVar6;
          piVar9[-1] = (int)sel_objectAtIndex_;
          piVar9[-2] = (int)self_00;
          piVar9[-3] = 0x5c355;
          pvVar5 = _objc_msgSend((id)piVar9[-2],(SEL)piVar9[-1]);
          piVar9[1] = (int)((local_20 + local_18) - fVar10);
          *piVar9 = uVar1;
          piVar9[-1] = (int)sel_offsetByPoint_;
          piVar9[-2] = (int)pvVar5;
          piVar9[-3] = 0x5c37d;
          _objc_msgSend((id)piVar9[-2],(SEL)piVar9[-1]);
          pvVar6 = (id)((int)pvVar6 + 1);
        } while (pvVar4 != pvVar6);
      }
    }
  }
  return;
}

*/
- (void)recalculateGeometryForItemAtIndex:(NSUInteger)aIndex
{
    NSArray *geometry;
    id item;
    NSRect oldFrame;
    NSRect newFrame;
    NSRect bounds;
    NSRect previousFrame;
    CGFloat offsetY;
    BOOL drawsLabels;
    CGFloat delta;
    NSUInteger count;
    NSUInteger index;

    geometry = [self geometryCache];
    item = [geometry objectAtIndex:aIndex];
    oldFrame = [item frame];
    bounds = [self bounds];
    offsetY = bounds.origin.y;
    if (aIndex != 0) {
        previousFrame = [[geometry objectAtIndex:aIndex - 1] frame];
        offsetY = previousFrame.origin.y + previousFrame.size.height;
    }
    drawsLabels = [self showsLabels] && _msFlags.dsSupportsLabels;
    [self calculateGeometry:item forImageSize:[_dataSource mediaStrip:self imageSizeForItemAtIndex:aIndex] label:drawsLabels ? ([_dataSource mediaStrip:self labelForItemAtIndex:aIndex] ?: @"") : nil limitToWidth:_stripWidth offset:NSMakePoint(bounds.origin.x, offsetY)];
    count = [self numberOfItems];
    if (aIndex + 1 < count && !NSEqualRects([item frame], oldFrame)) {
        // Shift the following items by the change in this item's bottom edge.
        newFrame = [item frame];
        delta = (newFrame.origin.y + newFrame.size.height) - (oldFrame.origin.y + oldFrame.size.height);
        for (index = aIndex + 1; index < count; index++) {
            [[geometry objectAtIndex:index] offsetByPoint:NSMakePoint(NSZeroPoint.x, delta)];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005c38d @ 0005c38d, 810 bytes * /

id FUN_0005c38d(HSMediaStripView *self,SEL _cmd)

{
  float fVar1;
  char cVar2;
  bool bVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  int extraout_EDX;
  int *piVar8;
  uint uVar9;
  cfstringStruct *pcVar10;
  int iStack_84;
  int local_70 [2];
  float local_68;
  int local_64;
  float local_60 [8];
  cfstringStruct *local_40;
  int local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined1 local_24 [12];
  float local_18;
  
  pvVar4 = _objc_msgSend(self,sel_numberOfItems);
  if (pvVar4 == (id)0x0) {
    pvVar4 = (id)0x0;
  }
  else {
    pvVar5 = self->_geometryCache;
    if (pvVar5 == (id)0x0) {
      pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
      pvVar5 = _objc_msgSend(pvVar5,sel_initWithCapacity_);
      self->_geometryCache = pvVar5;
    }
    pvVar5 = _objc_msgSend(pvVar5,sel_count);
    if (pvVar5 != pvVar4) {
      (self->_msFlags).geometryValid = 0;
      if (pvVar5 < pvVar4) {
        if (pvVar4 != pvVar5) {
          uVar9 = 0;
          do {
            pvVar6 = _objc_msgSend(cls_HSMediaStripItemGeometry,sel_alloc);
            pvVar6 = _objc_msgSend(pvVar6,sel_initWithOwner_);
            _objc_msgSend(self->_geometryCache,sel_addObject_);
            _objc_msgSend(pvVar6,sel_release);
            uVar9 = uVar9 + 1;
          } while (uVar9 < (uint)((int)pvVar4 - (int)pvVar5));
        }
      }
      else {
        _objc_msgSend(self->_geometryCache,sel_removeObjectsInRange_);
      }
    }
    if ((((self->_msFlags).geometryValid == 0) ||
        (self->_baseWidthForCachedGeometry != self->_stripWidth)) && (self->_dataSource != (id)0x0))
    {
      _objc_msgSend_stret(&local_34,self,sel_bounds);
      piVar8 = (int *)&stack0xffffff80;
      pvVar5 = _objc_msgSend(self,sel_showsLabels);
      if (((char)pvVar5 == '\0') || ((self->_msFlags).dsSupportsLabels == 0)) {
        bVar3 = false;
      }
      else {
        bVar3 = true;
      }
      local_2c = self->_stripWidth;
      local_28 = 0.0;
      local_40 = (cfstringStruct *)0x0;
      pvVar5 = (id)0x0;
      do {
        if (bVar3) {
          pvVar6 = self->_dataSource;
          piVar8[3] = (int)pvVar5;
          piVar8[2] = (int)self;
          piVar8[1] = (int)sel_mediaStrip_labelForItemAtIndex_;
          *piVar8 = (int)pvVar6;
          piVar8[-1] = 0x5c580;
          local_40 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
        }
        pvVar6 = self->_geometryCache;
        piVar8[2] = (int)pvVar5;
        piVar8[1] = (int)sel_objectAtIndex_;
        *piVar8 = (int)pvVar6;
        piVar8[-1] = 0x5c59f;
        pvVar7 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
        pvVar6 = self->_dataSource;
        piVar8[3] = (int)pvVar5;
        piVar8[2] = (int)self;
        piVar8[1] = (int)sel_mediaStrip_imageSizeForItemAtIndex_;
        *piVar8 = (int)pvVar6;
        piVar8[-1] = 0x5c5c2;
        pvVar6 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
        fVar1 = self->_stripWidth;
        if (bVar3) {
          pcVar10 = local_40;
          if (local_40 == (cfstringStruct *)0x0) {
            pcVar10 = &cfstr_empty;
          }
        }
        else {
          pcVar10 = (cfstringStruct *)0x0;
        }
        piVar8[8] = (int)(local_30 + local_28);
        piVar8[7] = local_34;
        piVar8[6] = (int)fVar1;
        piVar8[5] = (int)pcVar10;
        piVar8[4] = extraout_EDX;
        piVar8[3] = (int)pvVar6;
        piVar8[2] = (int)pvVar7;
        piVar8[1] = (int)sel_calculateGeometry_forImageSize_label_limitToWidth_offset_;
        *piVar8 = (int)self;
        piVar8[-1] = 0x5c637;
        pvVar6 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
        fVar1 = local_28;
        cVar2 = (char)pvVar6;
        if (cVar2 != '\0') {
          piVar8[2] = (int)sel_frame;
          piVar8[1] = (int)pvVar7;
          *piVar8 = (int)local_24;
          piVar8[-1] = 0x5c663;
          _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
          piVar8 = piVar8 + -1;
          local_28 = fVar1 + local_18;
        }
      } while (((id)((int)pvVar5 + 1U) < pvVar4) && (pvVar5 = (id)((int)pvVar5 + 1U), cVar2 != '\0')
              );
      self->_baseWidthForCachedGeometry = self->_stripWidth;
      (self->_msFlags).geometryValid = cVar2 != '\0';
    }
    pvVar4 = self->_geometryCache;
  }
  return pvVar4;
}

*/
- (id)geometryCache
{
    NSUInteger count;
    NSUInteger cachedCount;
    NSUInteger index;
    HSMediaStripItemGeometry *item;
    NSRect bounds;
    BOOL drawsLabels;
    BOOL valid;
    CGFloat offsetY;

    count = [self numberOfItems];
    if (count == 0) {
        return nil;
    }
    if (_geometryCache == nil) {
        _geometryCache = [[NSMutableArray alloc] initWithCapacity:count];
    }
    cachedCount = [_geometryCache count];
    if (cachedCount != count) {
        _msFlags.geometryValid = 0;
        if (cachedCount < count) {
            for (index = 0; index < count - cachedCount; index++) {
                item = [[HSMediaStripItemGeometry alloc] initWithOwner:self];
                [_geometryCache addObject:item];
                [item release];
            }
        }
        else {
            [_geometryCache removeObjectsInRange:NSMakeRange(count, cachedCount - count)];
        }
    }
    if ((!_msFlags.geometryValid || _baseWidthForCachedGeometry != _stripWidth) && _dataSource != nil) {
        // Lay the items out top to bottom, stopping at the first that does not fit.
        bounds = [self bounds];
        drawsLabels = [self showsLabels] && _msFlags.dsSupportsLabels;
        offsetY = 0.0;
        index = 0;
        do {
            item = [_geometryCache objectAtIndex:index];
            valid = [self calculateGeometry:item forImageSize:[_dataSource mediaStrip:self imageSizeForItemAtIndex:index] label:drawsLabels ? ([_dataSource mediaStrip:self labelForItemAtIndex:index] ?: @"") : nil limitToWidth:_stripWidth offset:NSMakePoint(bounds.origin.x, bounds.origin.y + offsetY)];
            if (valid) {
                offsetY += [item frame].size.height;
            }
            index++;
        } while (index < count && valid);
        _baseWidthForCachedGeometry = _stripWidth;
        _msFlags.geometryValid = valid ? 1 : 0;
    }
    return _geometryCache;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005c6b7 @ 0005c6b7, 1434 bytes * /

BOOL FUN_0005c6b7(HSMediaStripView *self,SEL _cmd,id calculateGeometry,NSSize forImageSize,id label,
                 float limitToWidth,NSPoint offset)

{
  BOOL BVar1;
  id self_00;
  id self_01;
  int *piVar2;
  float fVar3;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  float local_b4;
  float fStack_b0;
  float local_ac;
  float fStack_a8;
  float local_a4;
  float fStack_a0;
  float local_9c;
  float fStack_98;
  float local_94;
  float fStack_90;
  float local_8c;
  float fStack_88;
  float local_84;
  float fStack_80;
  float local_7c;
  float fStack_78;
  undefined8 local_54;
  undefined8 local_4c;
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined4 local_24;
  undefined4 local_20;
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  local_b4 = *(float *)PTR_00336078;
  fStack_b0 = *(float *)(PTR_00336078 + 4);
  local_ac = *(float *)(PTR_00336078 + 8);
  fStack_a8 = *(float *)(PTR_00336078 + 0xc);
  if (limitToWidth < 0.0) {
    BVar1 = '\0';
  }
  else {
    fVar3 = limitToWidth + -6.0 + -14.0 + -2.0;
    if ((fVar3 < forImageSize.width) || (fVar3 < forImageSize.height)) {
      if (forImageSize.width <= forImageSize.height) {
        local_7c = (fVar3 / forImageSize.height) * forImageSize.width;
        fStack_78 = fVar3;
      }
      else {
        local_7c = fVar3;
        fStack_78 = (fVar3 / forImageSize.width) * forImageSize.height;
      }
    }
    else {
      local_7c = forImageSize.width;
      fStack_78 = forImageSize.height;
    }
    local_84 = (fVar3 - local_7c) * 0.5 + 11.0;
    fStack_80 = 11.0;
    local_a4 = local_b4;
    fStack_a0 = fStack_b0;
    local_9c = local_ac;
    fStack_98 = fStack_a8;
    local_94 = local_b4;
    fStack_90 = fStack_b0;
    local_8c = local_ac;
    fStack_88 = fStack_a8;
    _NSIntegralRect();
    _NSInsetRect();
    piVar2 = (int *)&stack0xffffff0c;
    local_94 = *(float *)PTR_00336074;
    fStack_90 = *(float *)(PTR_00336074 + 4);
    local_8c = limitToWidth;
    if (label != (id)0x0) {
      local_24 = 0;
      local_20 = 0;
      self_00 = (id)FUN_0005cdf5();
      self_01 = _objc_msgSend(self_00,sel_textContainers);
      _objc_msgSend(self_01,sel_extraFirstObject);
      _objc_msgSend_stret(local_1c,self_00,sel_boundingRectForGlyphRange_inTextContainer_);
      fStack_a8 = local_10;
      local_ac = fVar3;
      if (local_14 + local_10 <= fVar3) {
        local_ac = local_14 + local_10;
      }
      local_b4 = (fVar3 - local_ac) * 0.5 + 10.0;
      fStack_b0 = fStack_80 + fStack_78 + 5.0;
      fStack_88 = fStack_b0 + local_10 + 7.0;
      _NSOffsetRect();
      _NSIntegralRect();
      piVar2 = (int *)&stack0xffffff00;
      _objc_msgSend(calculateGeometry,sel_setLabelFrame_);
    }
    *(ulonglong *)(piVar2 + 3) = CONCAT44(fStack_88,local_8c);
    *(ulonglong *)(piVar2 + 1) = CONCAT44(fStack_90,local_94);
    piVar2[6] = (int)offset.y;
    piVar2[5] = (int)offset.x;
    *piVar2 = (int)&local_94;
    piVar2[-1] = 0x5ca8b;
    _NSOffsetRect();
    *(ulonglong *)(piVar2 + 2) = CONCAT44(fStack_88,local_8c);
    *(ulonglong *)piVar2 = CONCAT44(fStack_90,local_94);
    piVar2[-1] = (int)&local_54;
    piVar2[-2] = 0x5cab5;
    _NSIntegralRect();
    *(undefined8 *)(piVar2 + 2) = local_4c;
    *(undefined8 *)piVar2 = local_54;
    piVar2[-1] = (int)sel_setFrame_;
    piVar2[-2] = (int)calculateGeometry;
    piVar2[-3] = 0x5cae3;
    _objc_msgSend((id)piVar2[-2],(SEL)piVar2[-1]);
    *(ulonglong *)(piVar2 + 1) = CONCAT44(fStack_78,local_7c);
    *(ulonglong *)(piVar2 + -1) = CONCAT44(fStack_80,local_84);
    piVar2[4] = (int)offset.y;
    piVar2[3] = (int)offset.x;
    piVar2[-2] = (int)&local_84;
    piVar2[-3] = 0x5cb1a;
    _NSOffsetRect();
    *(ulonglong *)piVar2 = CONCAT44(fStack_78,local_7c);
    *(ulonglong *)(piVar2 + -2) = CONCAT44(fStack_80,local_84);
    piVar2[-3] = (int)&local_44;
    piVar2[-4] = 0x5cb3e;
    _NSIntegralRect();
    *(undefined8 *)piVar2 = local_3c;
    *(undefined8 *)(piVar2 + -2) = local_44;
    piVar2[-3] = (int)sel_setImageFrame_;
    piVar2[-4] = (int)calculateGeometry;
    piVar2[-5] = 0x5cb69;
    _objc_msgSend((id)piVar2[-4],(SEL)piVar2[-3]);
    *(ulonglong *)(piVar2 + -1) = CONCAT44(fStack_98,local_9c);
    *(ulonglong *)(piVar2 + -3) = CONCAT44(fStack_a0,local_a4);
    piVar2[2] = (int)offset.y;
    piVar2[1] = (int)offset.x;
    piVar2[-4] = (int)&local_c4;
    piVar2[-5] = 0x5cba9;
    _NSOffsetRect();
    local_a4 = (float)local_c4;
    fStack_a0 = (float)local_c0;
    local_9c = (float)local_bc;
    fStack_98 = (float)local_b8;
    *(ulonglong *)(piVar2 + -2) = CONCAT44(local_b8,local_bc);
    *(ulonglong *)(piVar2 + -4) = CONCAT44(local_c0,local_c4);
    piVar2[-5] = (int)&local_34;
    piVar2[-6] = 0x5cc13;
    _NSIntegralRect();
    *(undefined8 *)(piVar2 + -2) = local_2c;
    *(undefined8 *)(piVar2 + -4) = local_34;
    piVar2[-5] = (int)sel_setImageBorderFrame_;
    piVar2[-6] = (int)calculateGeometry;
    piVar2[-7] = 0x5cc3e;
    _objc_msgSend((id)piVar2[-6],(SEL)piVar2[-5]);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)calculateGeometry:(id)aGeometry forImageSize:(NSSize)aSize label:(id)aLabel limitToWidth:(CGFloat)aWidth offset:(NSPoint)aOffset
{
    CGFloat available;
    NSRect imageRect;
    NSRect borderRect;
    NSRect frameRect;
    NSRect labelRect;
    NSLayoutManager *layoutManager;
    NSRange glyphRange;
    NSRect bounding;

    if (aWidth < 0.0) {
        return NO;
    }
    // 6 + 14 + 2 points of horizontal padding around the image.
    available = aWidth - 6.0 - 14.0 - 2.0;
    imageRect.size = aSize;
    if (available < aSize.width || available < aSize.height) {
        if (aSize.width > aSize.height) {
            imageRect.size = NSMakeSize(available, available / aSize.width * aSize.height);
        }
        else {
            imageRect.size = NSMakeSize(available / aSize.height * aSize.width, available);
        }
    }
    imageRect.origin = NSMakePoint((available - imageRect.size.width) * 0.5 + 11.0, 11.0);
    borderRect = NSInsetRect(NSIntegralRect(imageRect), -1.0, -1.0);
    // Without a label the item frame keeps a zero height.
    frameRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aWidth, NSZeroRect.size.height);
    if (aLabel != nil) {
        glyphRange = NSMakeRange(0, 0);
        layoutManager = HSMediaStripLabelLayoutManager(aLabel, available, &glyphRange);
        bounding = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:[[layoutManager textContainers] extraFirstObject]];
        // The original pads the label width by its height.
        labelRect.size = NSMakeSize(MIN(available, bounding.size.width + bounding.size.height), bounding.size.height);
        labelRect.origin = NSMakePoint((available - labelRect.size.width) * 0.5 + 10.0, imageRect.origin.y + imageRect.size.height + 5.0);
        frameRect.size.height = labelRect.origin.y + bounding.size.height + 7.0;
        [aGeometry setLabelFrame:NSIntegralRect(NSOffsetRect(labelRect, aOffset.x, aOffset.y))];
    }
    [aGeometry setFrame:NSIntegralRect(NSOffsetRect(frameRect, aOffset.x, aOffset.y))];
    [aGeometry setImageFrame:NSIntegralRect(NSOffsetRect(imageRect, aOffset.x, aOffset.y))];
    [aGeometry setImageBorderFrame:NSIntegralRect(NSOffsetRect(borderRect, aOffset.x, aOffset.y))];
    return YES;
}

- (id)HSMediaStripView_shadow
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _shadow;
    if (pvVar1 == nil) {
        pvVar1_3 = [[SMKShadow alloc] init];
        _shadow = pvVar1_3;
        [pvVar1_3 setShadowOffset:NSMakeSize(0, -1.0)];
        [_shadow setShadowBlurRadius:4.0];
        pvVar1 = _shadow;
    }
    return pvVar1;
}

- (BOOL)resignFirstResponder
{
    BOOL pvVar1;

    pvVar1 = [super resignFirstResponder];
    if (pvVar1) {
        if ((_msFlags).delegateNotifiedOfKeyStatusChange != 0) {
            [_delegate mediaStrip:self keyStatusChangedTo:0];
        }
        [self setNeedsDisplayForItemAtIndex:_activeItemIndex];
    }
    return pvVar1;
}

- (BOOL)becomeFirstResponder
{
    BOOL pvVar1;

    pvVar1 = [super becomeFirstResponder];
    if (pvVar1) {
        if ((_msFlags).delegateNotifiedOfKeyStatusChange != 0) {
            [_delegate mediaStrip:self keyStatusChangedTo:1];
        }
        [self setNeedsDisplayForItemAtIndex:_activeItemIndex];
    }
    return pvVar1;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)isOpaque
{
    return NO;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)reloadDataAndScrollToTop:(BOOL)aTop
{
    _msFlags.geometryValid = 0;
    NSUInteger numberOfItems = [self numberOfItems];
    NSUInteger validated = [[self itemsCacheValidator] length];
    if (validated < numberOfItems) {
        do {
            NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(10.0, 10.0)];
            [image setFlipped:YES];
            [[self itemsCache] addObject:image];
            [image release];
            validated++;
        } while (numberOfItems != validated);
        [[self itemsCacheValidator] setLength:numberOfItems];
        validated = numberOfItems;
    }
    [[self itemsCacheValidator] resetBytesInRange:NSMakeRange(0, validated)];
    [self sizeToFit];
    [[self enclosingScrollView] tile];
    BOOL switching = [[[[HSEditorController sharedDocumentController] currentDocument] modeSwitcher] switching];
    if (aTop && !switching)
        [self scrollItemAtIndexToTop:0];
    [[self enclosingScrollView] setNeedsDisplay:YES];
}

@end

