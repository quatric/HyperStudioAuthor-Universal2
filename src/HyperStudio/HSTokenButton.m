#import "HSTokenButton.h"

@implementation HSTokenButton

/* i386 ivar offsets: _isDragging=0x5c, _trackingRectTag=0x60, _doubleClickAction=0x64 */

+ (Class)cellClass
{
    return [HSTokenCell class];
}

- (id)accessibilityAttributeValue:(id)aValue
{
    id pvVar1_3;

    if (![aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        if (![aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
            pvVar1_3 = [super accessibilityAttributeValue:aValue];
        }
        else {
            pvVar1_3 = [[NSBundle mainBundle] localizedStringForKey:@"token" value:@"" table:@"AssistantPanes"];
        }
    }
    else {
        pvVar1_3 = NSAccessibilityUnknownRole;
    }
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00207ef9 @ 00207ef9, 9 bytes * /

id FUN_00207ef9(HSTokenButton *self,SEL _cmd)

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
/* FUN_00207f02 @ 00207f02, 9 bytes * /

id FUN_00207f02(HSTokenButton *self,SEL _cmd,NSPoint accessibilityHitTest)

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

/* --- i386 decompilation (Ghidra) ---
/* FUN_00207805 @ 00207805, 107 bytes * /

void FUN_00207805(HSTokenButton *self,SEL _cmd,id writeCellToPasteboard)

{
  undefined4 uVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self,sel_cell);
  uVar1 = *(undefined4 *)PTR_PTR_00336848;
  pvVar2 = _objc_msgSend(cls_NSKeyedArchiver,sel_archivedDataWithRootObject_,pvVar2);
  _objc_msgSend(writeCellToPasteboard,sel_setData_forType_,pvVar2,uVar1);
  return;
}

*/
- (void)writeCellToPasteboard:(id)aPasteboard
{
    [aPasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:[self cell]] forType:@"HSTokenCellPasteboardType"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00207cd4 @ 00207cd4, 215 bytes * /

void FUN_00207cd4(HSTokenButton *self,SEL _cmd,id pasteboard,id provideDataForType)

{
  id pvVar1;
  undefined4 uVar2;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  uVar2 = *(undefined4 *)PTR_PTR_00336848;
  pvVar1 = _objc_msgSend(provideDataForType,sel_isEqualToString_,uVar2);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_cell,uVar2);
    _objc_msgSend_stret(local_24,self,sel_bounds);
    _objc_msgSend(pvVar1,sel_setCellSize_,local_1c,local_18);
    pvVar1 = _objc_msgSend(cls_NSKeyedArchiver,sel_archivedDataWithRootObject_,pvVar1);
    _objc_msgSend(pasteboard,sel_setData_forType_,pvVar1,provideDataForType);
  }
  return;
}

*/
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    if ([aType isEqualToString:@"HSTokenCellPasteboardType"]) {
        id cell = [self cell];
        [cell setCellSize:[self bounds].size];
        [aPasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:cell] forType:aType];
    }
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal
{
    return (unsigned int)(aLocal != NO);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00207f0b @ 00207f0b, 262 bytes * /

void FUN_00207f0b(HSTokenButton *self,SEL _cmd,NSRect setBounds)

{
  id pvVar1;
  undefined4 *puVar2;
  HSTokenButton *local_2c;
  undefined *local_28;
  undefined1 local_24 [20];
  
  puVar2 = (undefined4 *)&stack0xffffffa4;
  local_2c = self;
  local_28 = PTR_s_NSControl_003549b0;
  _objc_msgSendSuper(&local_2c,sel_setBounds_);
  if (self->_trackingRectTag != 0) {
    _objc_msgSend(self,sel_removeTrackingRect_);
    _objc_msgSend_stret(local_24,self,sel_bounds);
    puVar2 = (undefined4 *)&stack0xffffffa0;
    pvVar1 = _objc_msgSend(self,sel_addTrackingRect_owner_userData_assumeInside_);
    self->_trackingRectTag = (int)pvVar1;
  }
  puVar2[1] = sel_cell;
  *puVar2 = self;
  puVar2[-1] = 0x207fe1;
  pvVar1 = _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  puVar2[3] = setBounds.size.height;
  puVar2[2] = setBounds.size.width;
  puVar2[1] = sel_setCellSize_;
  *puVar2 = pvVar1;
  puVar2[-1] = 0x208009;
  _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  return;
}

*/
- (void)setBounds:(NSRect)aBounds
{
    [super setBounds:aBounds];
    if (_trackingRectTag != 0) {
        [self removeTrackingRect:_trackingRectTag];
        _trackingRectTag = (int)[self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
    }
    [[self cell] setCellSize:aBounds.size];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00208011 @ 00208011, 199 bytes * /

void FUN_00208011(HSTokenButton *self,SEL _cmd,NSRect setFrame)

{
  id pvVar1;
  HSTokenButton *local_24;
  undefined *local_20;
  undefined1 local_1c [16];
  
  local_24 = self;
  local_20 = PTR_s_NSControl_003549b0;
  _objc_msgSendSuper(&local_24,sel_setFrame_,setFrame.origin.x,setFrame.origin.y,setFrame.size.width
                     ,setFrame.size.height);
  if (self->_trackingRectTag != 0) {
    _objc_msgSend(self,sel_removeTrackingRect_,self->_trackingRectTag);
    _objc_msgSend_stret(local_1c,self,sel_bounds);
    pvVar1 = _objc_msgSend(self,sel_addTrackingRect_owner_userData_assumeInside_,(int)local_1c._0_8_
                           ,SUB84(local_1c._0_8_,4),(int)local_1c._8_8_,SUB84(local_1c._8_8_,4),self
                           ,0,0);
    self->_trackingRectTag = (int)pvVar1;
  }
  return;
}

*/
- (void)setFrame:(NSRect)aFrame
{
    [super setFrame:aFrame];
    if (_trackingRectTag != 0) {
        [self removeTrackingRect:_trackingRectTag];
        _trackingRectTag = (int)[self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
    }
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    if (([self window] != nil) && (_trackingRectTag != 0)) {
        [self removeTrackingRect:_trackingRectTag];
    }
    [super viewWillMoveToWindow:aWindow];
}

- (void)viewDidMoveToWindow
{
    if ([self window] != nil) {
        _trackingRectTag = (int)[self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
    }
}

- (void)mouseUp:(id)aUp
{
    _isDragging = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00207a5c @ 00207a5c, 495 bytes * /

void FUN_00207a5c(HSTokenButton *self,SEL _cmd,id mouseDragged)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined8 uVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  if (self->_isDragging == '\0') {
    _objc_msgSend_stret(local_24,self,sel_frame);
    uVar1 = *(undefined4 *)PTR_00336074;
    uVar2 = *(undefined4 *)(PTR_00336074 + 4);
    uVar3 = *(undefined8 *)PTR_00336074;
    pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar4 = _objc_msgSend(pvVar4,sel_initWithSize_,local_1c,local_18);
    _objc_msgSend(pvVar4,sel_lockFocus);
    _objc_msgSend(self,sel_drawRect_,uVar3,CONCAT44(local_18,local_1c));
    _objc_msgSend(pvVar4,sel_unlockFocus);
    self_00 = _objc_msgSend(cls_NSPasteboard,sel_pasteboardWithName_,*(undefined4 *)PTR_00336390);
    pvVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_PTR_00336848);
    _objc_msgSend(self_00,sel_declareTypes_owner_,pvVar5,self);
    _objc_msgSend(self,sel_dragImage_at_offset_event_pasteboard_source_slideBack_,pvVar4,uVar1,uVar2
                  ,*(undefined4 *)PTR_0033607c,*(undefined4 *)(PTR_0033607c + 4),mouseDragged,
                  self_00,self,1);
    _objc_msgSend(pvVar4,sel_release);
  }
  return;
}

*/
- (void)mouseDragged:(id)aDragged
{
    if (!_isDragging) {
        NSRect frame = [self frame];
        NSImage *image = [[NSImage alloc] initWithSize:frame.size];
        [image lockFocus];
        [self drawRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, frame.size.width, frame.size.height)];
        [image unlockFocus];
        NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:@"HSTokenCellPasteboardType"] owner:self];
        [self dragImage:image at:NSZeroPoint offset:NSZeroSize event:aDragged pasteboard:pasteboard source:self slideBack:YES];
        [image release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00207899 @ 00207899, 419 bytes * /

void FUN_00207899(HSTokenButton *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  SEL pcVar2;
  id pvVar3;
  undefined4 *puVar4;
  undefined1 local_24 [20];
  
  puVar4 = (undefined4 *)&stack0xffffffb4;
  pvVar1 = _objc_msgSend(mouseDown,sel_clickCount);
  if ((pvVar1 != (id)0x2) || (self->_doubleClickAction == (SEL)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_cell);
    _objc_msgSend_stret(local_24,self,sel_bounds);
    puVar4 = (undefined4 *)&stack0xffffffb0;
    pvVar1 = _objc_msgSend(pvVar1,sel_activateMenuForEvent_cellFrame_controlView_);
    if ((char)pvVar1 != '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_init);
switchD_002079ff_caseD_3:
    pvVar3 = _objc_msgSend(self,sel_window);
    pvVar3 = _objc_msgSend(pvVar3,sel_nextEventMatchingMask_);
    pvVar3 = _objc_msgSend(pvVar3,sel_type);
    switch(pvVar3) {
    case (id)0x2:
      goto switchD_002079ff_caseD_2;
    default:
      goto switchD_002079ff_caseD_3;
    case (id)0x6:
      pcVar2 = sel_mouseDragged_;
      goto LAB_00207a07;
    case (id)0x8:
      pcVar2 = sel_mouseEntered_;
      break;
    case (id)0x9:
      pcVar2 = sel_mouseExited_;
    }
    _objc_msgSend(self,pcVar2);
    goto switchD_002079ff_caseD_3;
  }
  pvVar1 = _objc_msgSend(self,sel_target);
LAB_002078f2:
  *puVar4 = pvVar1;
  puVar4[-1] = 0x2078fa;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return;
switchD_002079ff_caseD_2:
  pcVar2 = sel_mouseUp_;
LAB_00207a07:
  _objc_msgSend(self,pcVar2);
  goto LAB_002078f2;
}

*/
- (void)mouseDown:(id)aDown
{
    if ([aDown clickCount] == 2 && _doubleClickAction != NULL) {
        [[self target] performSelector:_doubleClickAction withObject:self];
        return;
    }
    if ([[self cell] activateMenuForEvent:aDown cellFrame:[self bounds] controlView:self]) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (;;) {
        NSEvent *event = [[self window] nextEventMatchingMask:0x344];
        switch ([event type]) {
            case 2:
            [self mouseUp:event];
            [pool release];
            return;
            case 6:
            [self mouseDragged:event];
            [pool release];
            return;
            case 8:
            [self mouseEntered:event];
            break;
            case 9:
            [self mouseExited:event];
            break;
            default:
            break;
        }
    }
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (void)mouseExited:(id)aExited
{
    [[self cell] setCanChangeHighlight:YES];
    [[self cell] setHighlighted:NO];
    [self setNeedsDisplay:YES];
    [[self cell] setCanChangeHighlight:NO];
}

- (void)mouseEntered:(id)aEntered
{
    [[self cell] setCanChangeHighlight:YES];
    [[self cell] setHighlighted:YES];
    [self setNeedsDisplay:YES];
    [[self cell] setCanChangeHighlight:NO];
}

- (void)setDoubleClickAction:(SEL)aAction
{
    _doubleClickAction = aAction;
}

- (SEL)doubleClickAction
{
    return _doubleClickAction;
}

- (id)title
{
    return [[self cell] title];
}

- (void)setTitle:(id)aTitle
{
    [[self cell] setTitle:aTitle];
}

- (id)menu
{
    return [[self cell] menu];
}

- (void)setMenu:(id)aMenu
{
    if ([self menu] != aMenu) {
        [[self cell] setMenu:aMenu];
    }
}

@end

