#import "HSBaseEmbeddedEditor.h"

@implementation HSBaseEmbeddedEditor

/* i386 ivar offsets: _embeddedView=0x10, _viewEmbedder=0x14, _occupiedRect=0x18, _boundsInHostView=0x28, _isDeactivating=0x38, _calculatedRectsAreValid=0x39, _isEditorChanged=0x3a */

- (void)setHyperSelectedRange:(NSRange)aRange
{
    id pvVar1_2;

    pvVar1_2 = [[self viewEmbedder] queryHyperInterface:@protocol(HSTextObjectSelectionInterface)];
    if (pvVar1_2 != nil) {
        [pvVar1_2 setHyperSelectedRange:aRange];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006b8bc @ 0006b8bc, 108 bytes * /

ulonglong FUN_0006b8bc(HSBaseEmbeddedEditor *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_viewEmbedder);
  puVar3 = &DAT_00364db4;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00364db4);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
    uVar2 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperSelectedRange,puVar3);
    uVar2 = extraout_EDX;
  }
  return CONCAT44(uVar2,pvVar1);
}

*/
- (NSRange)hyperSelectedRange
{
    id selection = [[self viewEmbedder] queryHyperInterface:@protocol(HSTextObjectSelectionInterface)];
    if (selection == nil) {
        return NSMakeRange(0, 0);
    }
    return [selection hyperSelectedRange];
}

- (void)textView:(id)aView willInsertText:(id)aText
{
    if ([[self editingObject] respondsToSelector:@selector(textView:willInsertText:)]) {
        [[self editingObject] textView:aView willInsertText:aText];
    }
}

- (void)setEditorChanged:(BOOL)aChanged
{
    if ((BOOL)_isEditorChanged != (aChanged != NO)) {
        _isEditorChanged = aChanged != NO;
    }
}

- (void)unregisterFromAttributesDidChangeNotifications
{
    NSEnumerator *self_00;
    id pvVar1_2;

    self_00 = [[self attributesDidChangeNotificationNames] objectEnumerator];
    pvVar1_2 = [self_00 nextObject];
    while (pvVar1_2 != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:pvVar1_2 object:[self editingObject]];
        pvVar1_2 = [self_00 nextObject];
    }
}

- (void)registerForAttributesDidChangeNotifications
{
    NSEnumerator *self_00;
    id pvVar1_2;

    self_00 = [[self attributesDidChangeNotificationNames] objectEnumerator];
    pvVar1_2 = [self_00 nextObject];
    while (pvVar1_2 != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attributesDidChange:) name:pvVar1_2 object:[self editingObject]];
        pvVar1_2 = [self_00 nextObject];
    }
}

- (void)unregisterFromNotifications
{
    [self unregisterFromAttributesDidChangeNotifications];
}

- (void)registerForNotifications
{
    [self registerForAttributesDidChangeNotifications];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006ba3e @ 0006ba3e, 280 bytes * /

void FUN_0006ba3e(HSBaseEmbeddedEditor *self,SEL _cmd)

{
  NSPoint NVar1;
  id pvVar2;
  int *piVar3;
  undefined4 local_64;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  _objc_msgSend_stret(&local_1c,self,sel_calculateOccupiedRect);
  piVar3 = (int *)&stack0xffffffa0;
  (self->_occupiedRect).origin.x = local_1c;
  (self->_occupiedRect).origin.y = local_18;
  (self->_occupiedRect).size.width = local_14;
  (self->_occupiedRect).size.height = local_10;
  local_64 = 0x6baa5;
  pvVar2 = _objc_msgSend(self,sel_calculatedRectIsPrecise);
  if ((char)pvVar2 == '\0') {
    local_64 = 0x6baca;
    _NSIntegralRect();
    piVar3 = &local_64;
    (self->_occupiedRect).origin.x = local_2c;
    (self->_occupiedRect).origin.y = local_28;
    (self->_occupiedRect).size.width = local_24;
    (self->_occupiedRect).size.height = local_20;
  }
  NVar1 = (self->_occupiedRect).origin;
  *(NSSize *)(piVar3 + 5) = (self->_occupiedRect).size;
  *(NSPoint *)(piVar3 + 3) = NVar1;
  piVar3[2] = (int)sel_boundsWithOccupiedRect_;
  piVar3[1] = (int)self;
  *piVar3 = (int)&local_3c;
  piVar3[-1] = 0x6bb24;
  _objc_msgSend_stret((void *)*piVar3,(id)piVar3[1],(SEL)piVar3[2]);
  (self->_boundsInHostView).origin.x = local_3c;
  (self->_boundsInHostView).origin.y = local_38;
  (self->_boundsInHostView).size.width = local_34;
  (self->_boundsInHostView).size.height = local_30;
  return;
}

*/
- (void)recalculateRects
{
    _occupiedRect = [self calculateOccupiedRect];
    if (![self calculatedRectIsPrecise]) {
        _occupiedRect = NSIntegralRect(_occupiedRect);
    }
    _boundsInHostView = [self boundsWithOccupiedRect:_occupiedRect];
}

- (void)runTimeEditorEmbedderWillChangeSelectionWithoutChangingContent:(id)aContent
{

}

- (void)runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:(id)aContent
{

}

- (void)runTimeEditorEmbedderDidChangeContent:(id)aContent
{
    [self didChangeContent];
}

- (void)runTimeEditorEmbedderWantsToCancel:(id)aCancel
{
    if (![self isDeactivating]) {
        [self notifyWantsToFinish];
    }
}

- (void)runTimeEditorEmbedderWantsToResign:(id)aResign
{
    if (![self isDeactivating]) {
        [self notifyWantsToFinish];
    }
}

- (id)embeddedView
{
    id pvVar1;

    pvVar1 = _embeddedView;
    if (pvVar1 == nil) {
        pvVar1 = [[self loadEmbeddedView] retain];
        _embeddedView = pvVar1;
    }
    return pvVar1;
}

- (void)hostViewDidChangeUserSpaceToViewSpaceTransform
{
    [self recalculateOccupiedRect];
}

- (BOOL)disablesRenderingEditingObject
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006bb56 @ 0006bb56, 340 bytes * /

void FUN_0006bb56(HSBaseEmbeddedEditor *self,SEL _cmd,NSRect hyperRenderRect)

{
  NSPoint NVar1;
  NSSize NVar2;
  char cVar3;
  id pvVar4;
  undefined1 local_24 [8];
  undefined8 local_1c;
  
  pvVar4 = _objc_msgSend(self,sel_displaysFocusRing);
  if ((char)pvVar4 != '\0') {
    NVar1 = (self->_occupiedRect).origin;
    NVar2 = (self->_occupiedRect).size;
    cVar3 = _NSIsEmptyRect(NVar1.x,NVar1.y,NVar2.width,NVar2.height);
    if (cVar3 == '\0') {
      _objc_msgSend_stret(local_24,self,sel_boundsInHostView);
      cVar3 = _NSIntersectsRect(hyperRenderRect.origin.x,hyperRenderRect.origin.y,
                                hyperRenderRect.size.width,hyperRenderRect.size.height,
                                local_24._0_4_,local_24._4_4_,local_1c);
      if (cVar3 != '\0') {
        _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
        _NSSetFocusRingStyle(1);
        pvVar4 = _objc_msgSend(cls_NSColor,sel_clearColor);
        _objc_msgSend(pvVar4,sel_set);
        NVar1 = (self->_occupiedRect).origin;
        NVar2 = (self->_occupiedRect).size;
        pvVar4 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,NVar1.x,NVar1.y,NVar2.width,
                               NVar2.height);
        _objc_msgSend(pvVar4,sel_fill);
        _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
      }
    }
  }
  return;
}

*/
- (void)hyperRenderRect:(NSRect)aRect
{
    if ([self displaysFocusRing] && !NSIsEmptyRect(_occupiedRect) && NSIntersectsRect(aRect, [self boundsInHostView])) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSColor clearColor] set];
        [[NSBezierPath bezierPathWithRect:_occupiedRect] fill];
        [NSGraphicsContext restoreGraphicsState];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006b021 @ 0006b021, 52 bytes * /

NSRect * FUN_0006b021(NSRect *__return_storage_ptr__,HSBaseEmbeddedEditor *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_boundsInHostView).origin.x;
  (__return_storage_ptr__->origin).y = (self->_boundsInHostView).origin.y;
  (__return_storage_ptr__->size).width = (self->_boundsInHostView).size.width;
  (__return_storage_ptr__->size).height = (self->_boundsInHostView).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)boundsInHostView
{
    return _boundsInHostView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006afed @ 0006afed, 52 bytes * /

NSRect * FUN_0006afed(NSRect *__return_storage_ptr__,HSBaseEmbeddedEditor *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_occupiedRect).origin.x;
  (__return_storage_ptr__->origin).y = (self->_occupiedRect).origin.y;
  (__return_storage_ptr__->size).width = (self->_occupiedRect).size.width;
  (__return_storage_ptr__->size).height = (self->_occupiedRect).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)occupiedAreaInHostView
{
    return _occupiedRect;
}

- (void)setOwner:(id)aOwner
{
    [super setOwner:aOwner];
    _calculatedRectsAreValid = NO;
}

- (BOOL)isActive
{
    BOOL BVar2;

    if (_isDeactivating == NO) {
        if (_viewEmbedder == nil) {
            if ([[self embeddedView] superview] == nil) {
                BVar2 = NO;
            }
            else {
                BVar2 = [[self embeddedView] window] != nil;
            }
        }
        else {
            BVar2 = (BOOL)[_viewEmbedder isMountedInHostView];
        }
    }
    else {
        BVar2 = _isDeactivating == NO;
    }
    return BVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006b378 @ 0006b378, 310 bytes * /

void FUN_0006b378(HSBaseEmbeddedEditor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  _objc_msgSend(self,sel_unregisterFromNotifications);
  self->_isDeactivating = '\x01';
  pvVar2 = self->_viewEmbedder;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_embeddedView);
    _objc_msgSend(pvVar2,sel_removeFromSuperview);
    pvVar2 = _objc_msgSend(self,sel_hostView);
    pvVar2 = _objc_msgSend(pvVar2,sel_window);
    pvVar2 = _objc_msgSend(pvVar2,sel_firstResponder);
    pvVar1 = _objc_msgSend(self,sel_hostView);
    pvVar1 = _objc_msgSend(pvVar1,sel_window);
    if (pvVar2 != pvVar1) goto LAB_0006b49e;
    pvVar2 = _objc_msgSend(self,sel_hostView);
    pvVar2 = _objc_msgSend(pvVar2,sel_window);
    pvVar1 = _objc_msgSend(self,sel_hostView);
    op = sel_makeFirstResponder_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_hostView);
    op = sel_unmountFromHostView_;
  }
  _objc_msgSend(pvVar2,op,pvVar1);
LAB_0006b49e:
  self->_isDeactivating = '\0';
  self->_calculatedRectsAreValid = '\0';
  return;
}

*/
- (void)deactivate
{
    [self unregisterFromNotifications];
    _isDeactivating = YES;
    if (_viewEmbedder == nil) {
        [[self embeddedView] removeFromSuperview];
        if ([[[self hostView] window] firstResponder] == [[self hostView] window]) {
            [[[self hostView] window] makeFirstResponder:[self hostView]];
        }
    }
    else {
        [_viewEmbedder unmountFromHostView:[self hostView]];
    }
    _isDeactivating = NO;
    _calculatedRectsAreValid = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006b217 @ 0006b217, 353 bytes * /

void FUN_0006b217(HSBaseEmbeddedEditor *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  
  if (self->_viewEmbedder == (id)0x0) {
    self_00 = _objc_msgSend(self,sel_embeddedView);
  }
  else {
    self_00 = (id)0x0;
  }
  pvVar1 = _objc_msgSend(self,sel_editingObject);
  if (pvVar1 == (id)0x0) {
    return;
  }
  if ((self->_viewEmbedder == (id)0x0) && (self_00 == (id)0x0)) {
    return;
  }
  _objc_msgSend(self,sel_registerForNotifications);
  _objc_msgSend(self,sel_updateEmbeddedViewWithEditingObject);
  _objc_msgSend(self,sel_recalculateOccupiedRectIfNeeded);
  pvVar1 = self->_viewEmbedder;
  if (pvVar1 == (id)0x0) {
    if (self_00 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_hostView);
    pvVar1 = self_00;
    _objc_msgSend(pvVar2,sel_addSubview_,self_00);
    pvVar2 = _objc_msgSend(self_00,sel_acceptsFirstResponder);
    if ((char)pvVar2 == '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self_00,sel_window,pvVar1);
    _objc_msgSend(pvVar1,sel_makeFirstResponder_,self_00);
    pvVar2 = _objc_msgSend(self_00,sel_window);
    op = sel_setNextResponder_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_hostView);
    self_00 = pvVar1;
    op = sel_mountInHostView_;
  }
  _objc_msgSend(self_00,op,pvVar2);
  return;
}

*/
- (void)activate
{
    NSView *embedded = _viewEmbedder == nil ? [self embeddedView] : nil;
    if ([self editingObject] == nil) {
        return;
    }
    if (_viewEmbedder == nil && embedded == nil) {
        return;
    }
    [self registerForNotifications];
    [self updateEmbeddedViewWithEditingObject];
    [self recalculateOccupiedRectIfNeeded];
    if (_viewEmbedder != nil) {
        [_viewEmbedder mountInHostView:[self hostView]];
        return;
    }
    if (embedded == nil) {
        return;
    }
    [[self hostView] addSubview:embedded];
    if ([embedded acceptsFirstResponder]) {
        [[embedded window] makeFirstResponder:embedded];
        [embedded setNextResponder:[embedded window]];
    }
}

- (BOOL)shouldAutoResizeEditorToFitContent
{
    return YES;
}

- (BOOL)isEditorChanged
{
    return _isEditorChanged;
}

- (void)clearChangedState
{
    [self setEditorChanged:NO];
}

- (void)didChangeContent
{
    [self recalculateOccupiedRect];
    [self setEditorChanged:YES];
}

- (void)attributesDidChange:(id)aChange
{

}

- (id)attributesDidChangeNotificationNames
{
    return [NSArray array];
}

- (BOOL)isDeactivating
{
    return _isDeactivating;
}

- (BOOL)displaysFocusRing
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006bcec @ 0006bcec, 301 bytes * /

NSRect * FUN_0006bcec(NSRect *__return_storage_ptr__,HSBaseEmbeddedEditor *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  undefined1 local_34 [8];
  undefined8 local_2c;
  undefined8 local_24 [2];
  
  local_44 = *(float *)PTR_00336078;
  local_40 = *(float *)(PTR_00336078 + 4);
  local_3c = *(float *)(PTR_00336078 + 8);
  local_38 = *(float *)(PTR_00336078 + 0xc);
  pvVar1 = _objc_msgSend(self,sel_editingObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00364e40);
  self_00 = _objc_msgSend(self,sel_hostView);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend_stret(local_34,pvVar1,sel_frameBoundingRect);
    _objc_msgSend_stret(local_24,self_00,sel_viewBoundingRectForUserRect_,local_34._0_4_,
                        local_34._4_4_,local_2c);
    _NSIntegralRect(&local_44,local_24[0],(int)local_24[1],(int)((ulonglong)local_24[1] >> 0x20));
  }
  (__return_storage_ptr__->origin).x = local_44;
  (__return_storage_ptr__->origin).y = local_40;
  (__return_storage_ptr__->size).width = local_3c;
  (__return_storage_ptr__->size).height = local_38;
  return __return_storage_ptr__;
}

*/
- (NSRect)editingObjectBounds
{
    NSRect rect = NSZeroRect;
    id geometry = [[self editingObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    id host = [self hostView];
    if (geometry != nil) {
        rect = NSIntegralRect([host viewBoundingRectForUserRect:[geometry frameBoundingRect]]);
    }
    return rect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006be19 @ 0006be19, 180 bytes * /

NSRect * FUN_0006be19(NSRect *__return_storage_ptr__,HSBaseEmbeddedEditor *self,SEL _cmd,
                     NSRect boundsWithOccupiedRect)

{
  id pvVar1;
  float local_14;
  float local_10;
  float local_c;
  float local_8;
  
  local_14 = boundsWithOccupiedRect.origin.x;
  local_10 = boundsWithOccupiedRect.origin.y;
  local_c = boundsWithOccupiedRect.size.width;
  local_8 = boundsWithOccupiedRect.size.height;
  pvVar1 = _objc_msgSend(self,sel_displaysFocusRing);
  if ((char)pvVar1 != '\0') {
    _NSInsetRect(&local_14,boundsWithOccupiedRect.origin,boundsWithOccupiedRect.size,0xc0400000,
                 0xc0400000);
  }
  (__return_storage_ptr__->origin).x = local_14;
  (__return_storage_ptr__->origin).y = local_10;
  (__return_storage_ptr__->size).width = local_c;
  (__return_storage_ptr__->size).height = local_8;
  return __return_storage_ptr__;
}

*/
- (NSRect)boundsWithOccupiedRect:(NSRect)aRect
{
    if ([self displaysFocusRing]) {
        aRect = NSInsetRect(aRect, -3.0, -3.0);
    }
    return aRect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006becd @ 0006becd, 318 bytes * /

NSRect * FUN_0006becd(NSRect *__return_storage_ptr__,HSBaseEmbeddedEditor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float fVar3;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_editingObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00364e40);
  pvVar2 = _objc_msgSend(self,sel_hostView);
  local_28 = *(float *)PTR_00336078;
  local_2c = *(float *)(PTR_00336078 + 4);
  if ((pvVar1 == (id)0x0) || (pvVar2 == (id)0x0)) {
    fVar3 = *(float *)(PTR_00336078 + 0xc);
    pvVar1 = *(id *)(PTR_00336078 + 8);
  }
  else {
    _objc_msgSend_stret(&local_24,self,sel_editingObjectBounds);
    pvVar1 = _objc_msgSend(pvVar1,sel_size);
    local_2c = local_2c + ((local_18 * 0.5 + local_20) - (extraout_EDX * 0.5 + local_2c));
    local_28 = local_28 + ((local_1c * 0.5 + local_24) - ((float)pvVar1 * 0.5 + local_28));
    fVar3 = extraout_EDX;
  }
  (__return_storage_ptr__->origin).x = local_28;
  (__return_storage_ptr__->origin).y = local_2c;
  (__return_storage_ptr__->size).width = (float)pvVar1;
  (__return_storage_ptr__->size).height = fVar3;
  return __return_storage_ptr__;
}

*/
- (NSRect)calculateOccupiedRect
{
    id geometry = [[self editingObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    id host = [self hostView];
    NSRect rect = NSZeroRect;
    if (geometry != nil && host != nil) {
        NSRect bounds = [self editingObjectBounds];
        NSSize size = [geometry size];
        rect.origin.y = rect.origin.y + ((bounds.size.height * 0.5 + bounds.origin.y) - (size.height * 0.5 + rect.origin.y));
        rect.origin.x = rect.origin.x + ((bounds.size.width * 0.5 + bounds.origin.x) - (size.width * 0.5 + rect.origin.x));
        rect.size = size;
    }
    return rect;
}

- (BOOL)calculatedRectIsPrecise
{
    return NO;
}

- (void)recalculateOccupiedRectIfNeeded
{
    if (_calculatedRectsAreValid == NO) {
        [self recalculateOccupiedRect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006c00b @ 0006c00b, 1218 bytes * /

void FUN_0006c00b(HSBaseEmbeddedEditor *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  char cVar6;
  id pvVar7;
  NSPoint *pNVar8;
  NSPoint *pNVar9;
  uint uVar10;
  float fVar11;
  float fVar12;
  NSPoint NVar13;
  NSSize NVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  undefined4 local_c0;
  float local_7c;
  float local_78;
  NSPoint local_74;
  NSPoint local_6c [7];
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pNVar9 = (NSPoint *)&stack0xffffff44;
  local_78 = (self->_boundsInHostView).size.height;
  fVar1 = (self->_boundsInHostView).size.width;
  fVar2 = (self->_boundsInHostView).origin.x;
  fVar3 = (self->_boundsInHostView).origin.y;
  local_c0 = 0x6c05a;
  _objc_msgSend(self,sel_recalculateRects);
  local_24 = *(float *)PTR_00336078;
  local_20 = *(float *)(PTR_00336078 + 4);
  local_1c = *(float *)(PTR_00336078 + 8);
  local_18 = *(float *)(PTR_00336078 + 0xc);
  if (self->_viewEmbedder == (id)0x0) {
    local_c0 = 0x6c0c0;
    pvVar7 = _objc_msgSend(self,sel_embeddedView);
    if (pvVar7 != (id)0x0) {
      local_c0 = 0x6c0d9;
      pvVar7 = _objc_msgSend(self,sel_embeddedView);
      local_c0 = 0x6c0f2;
      _objc_msgSend_stret(&local_34,pvVar7,sel_frame);
      pNVar9 = (NSPoint *)&local_c0;
      local_24 = local_34;
      local_20 = local_30;
      local_1c = local_2c;
      local_18 = local_28;
    }
  }
  else {
    local_c0 = 0x6c0a7;
    _objc_msgSend_stret(&local_24,self->_viewEmbedder,sel_frame);
    pNVar9 = (NSPoint *)&local_c0;
  }
  fVar4 = (self->_occupiedRect).origin.y;
  fVar5 = (self->_occupiedRect).size.height;
  fVar11 = ABS(fVar4) + fVar5;
  fVar17 = ABS(local_20) + local_18;
  if ((fVar17 != 0.0) || (NAN(fVar17))) {
    fVar17 = ABS(fVar17);
  }
  else {
    fVar17 = 1.0;
  }
  if ((fVar11 != 0.0) || (NAN(fVar11))) {
    fVar11 = ABS(fVar11);
  }
  else {
    fVar11 = 1.0;
  }
  fVar12 = (self->_occupiedRect).origin.x;
  fVar18 = (self->_occupiedRect).size.width;
  fVar16 = ABS(fVar12) + fVar18;
  fVar15 = ABS(local_24) + local_1c;
  if (fVar11 <= fVar17) {
    fVar11 = fVar17;
  }
  if ((fVar15 != 0.0) || (NAN(fVar15))) {
    fVar15 = ABS(fVar15);
  }
  else {
    fVar15 = 1.0;
  }
  if ((fVar16 != 0.0) || (NAN(fVar16))) {
    fVar16 = ABS(fVar16);
  }
  else {
    fVar16 = 1.0;
  }
  if (fVar16 <= fVar15) {
    fVar16 = fVar15;
  }
  if ((((fVar16 * 0.0005 < ABS(local_24 - fVar12)) || (fVar11 * 0.0005 < ABS(local_20 - fVar4))) ||
      (fVar16 * 0.0005 < ABS(local_1c - fVar18))) || (fVar11 * 0.0005 < ABS(local_18 - fVar5))) {
    pvVar7 = self->_viewEmbedder;
    if (pvVar7 == (id)0x0) {
      pNVar9->y = (float)sel_embeddedView;
      pNVar9->x = (float)self;
      pNVar9[-1].y = 6.20851e-40;
      pvVar7 = _objc_msgSend((id)pNVar9->x,(SEL)pNVar9->y);
      NVar13 = (self->_occupiedRect).origin;
      NVar14 = (self->_occupiedRect).size;
    }
    else {
      NVar13 = (self->_occupiedRect).origin;
      NVar14 = (self->_occupiedRect).size;
    }
    *(NSSize *)(pNVar9 + 2) = NVar14;
    pNVar9[1] = NVar13;
    pNVar9->y = (float)sel_setFrame_;
    pNVar9->x = (float)pvVar7;
    pNVar9[-1].y = 6.20907e-40;
    _objc_msgSend((id)pNVar9->x,(SEL)pNVar9->y);
  }
  NVar13 = (self->_boundsInHostView).origin;
  *(NSSize *)(pNVar9 + 1) = (self->_boundsInHostView).size;
  *pNVar9 = NVar13;
  pNVar9[-1].y = 6.20948e-40;
  cVar6 = _NSIsEmptyRect();
  if (cVar6 == '\0') {
    fVar4 = (self->_boundsInHostView).origin.x;
    fVar5 = (self->_boundsInHostView).origin.y;
    local_74.x = fVar2;
    local_74.y = fVar3;
    local_6c[0].x = fVar1;
    local_6c[0].y = local_78;
    fVar17 = fVar2 + fVar1;
    if (fVar4 < fVar17) {
      fVar11 = (self->_boundsInHostView).size.width + fVar4;
      if ((fVar2 + 0.0 < fVar11) && (local_78 = local_78 + fVar3, fVar5 < local_78)) {
        fVar12 = (self->_boundsInHostView).size.height + fVar5;
        fVar18 = fVar3 + 0.0;
        if (fVar18 < fVar12) {
          local_7c = fVar3;
          if (fVar18 < fVar5) {
            local_6c[0].y = fVar5 - fVar3;
            local_7c = fVar5;
          }
          uVar10 = (uint)(fVar18 < fVar5);
          if (fVar12 < local_78) {
            (&local_74)[uVar10 * 2].x = fVar2;
            (&local_74)[uVar10 * 2].y = fVar12;
            local_6c[uVar10 * 2].x = fVar1;
            local_6c[uVar10 * 2].y = local_78 - fVar12;
            uVar10 = uVar10 + 1;
            local_78 = fVar12;
          }
          if (fVar2 + 0.0 < fVar4) {
            (&local_74)[uVar10 * 2].x = fVar2;
            (&local_74)[uVar10 * 2].y = local_7c;
            local_6c[uVar10 * 2].x = fVar4 - fVar2;
            local_6c[uVar10 * 2].y = local_78 - local_7c;
            uVar10 = uVar10 + 1;
          }
          if (fVar11 < fVar17) {
            (&local_74)[uVar10 * 2].x = fVar11;
            (&local_74)[uVar10 * 2].y = local_7c;
            local_6c[uVar10 * 2].x = fVar17 - fVar11;
            local_6c[uVar10 * 2].y = local_78 - local_7c;
            uVar10 = uVar10 + 1;
          }
          if (uVar10 != 0) {
            pNVar8 = &local_74;
            do {
              pNVar9->y = (float)sel_owner;
              pNVar9->x = (float)self;
              pNVar9[-1].y = 6.21524e-40;
              pvVar7 = _objc_msgSend((id)pNVar9->x,(SEL)pNVar9->y);
              NVar13 = *pNVar8;
              pNVar9[2] = pNVar8[1];
              pNVar9[1] = NVar13;
              pNVar9->y = (float)sel_setNeedsDisplayInRect_;
              pNVar9->x = (float)pvVar7;
              pNVar9[-1].y = 6.21578e-40;
              _objc_msgSend((id)pNVar9->x,(SEL)pNVar9->y);
              pNVar8 = pNVar8 + 2;
              uVar10 = uVar10 - 1;
            } while (uVar10 != 0);
          }
        }
      }
    }
  }
  self->_calculatedRectsAreValid = '\x01';
  return;
}

*/
- (void)recalculateOccupiedRect
{
    NSRect oldBounds = _boundsInHostView;
    [self recalculateRects];
    NSRect frame = NSZeroRect;
    if (_viewEmbedder == nil) {
        if ([self embeddedView] != nil) {
            frame = [[self embeddedView] frame];
        }
    }
    else {
        frame = [_viewEmbedder frame];
    }
    float oy = fabsf(_occupiedRect.origin.y) + _occupiedRect.size.height;
    float fy = fabsf(frame.origin.y) + frame.size.height;
    fy = fy != 0.0 ? fabsf(fy) : 1.0;
    oy = oy != 0.0 ? fabsf(oy) : 1.0;
    float ox = fabsf(_occupiedRect.origin.x) + _occupiedRect.size.width;
    float fx = fabsf(frame.origin.x) + frame.size.width;
    fx = fx != 0.0 ? fabsf(fx) : 1.0;
    ox = ox != 0.0 ? fabsf(ox) : 1.0;
    float yTol = (oy <= fy ? fy : oy) * 0.0005;
    float xTol = (ox <= fx ? fx : ox) * 0.0005;
    if (xTol < fabsf(frame.origin.x - _occupiedRect.origin.x)
        || yTol < fabsf(frame.origin.y - _occupiedRect.origin.y)
        || xTol < fabsf(frame.size.width - _occupiedRect.size.width)
        || yTol < fabsf(frame.size.height - _occupiedRect.size.height)) {
        id target = _viewEmbedder;
        if (target == nil) {
            target = [self embeddedView];
        }
        [target setFrame:_occupiedRect];
    }
    if (!NSIsEmptyRect(_boundsInHostView)) {
        float newX = _boundsInHostView.origin.x;
        float newY = _boundsInHostView.origin.y;
        float oldX = oldBounds.origin.x;
        float oldY = oldBounds.origin.y;
        float oldW = oldBounds.size.width;
        float oldRight = oldX + oldW;
        if (newX < oldRight) {
            float newRight = _boundsInHostView.size.width + newX;
            float oldTop = oldBounds.size.height + oldY;
            if (oldX + 0.0 < newRight && newY < oldTop) {
                float newTop = _boundsInHostView.size.height + newY;
                if (oldY + 0.0 < newTop) {
                    NSRect strips[4];
                    unsigned int count = 0;
                    float bottom = oldY;
                    if (oldY + 0.0 < newY) {
                        strips[count++] = NSMakeRect(oldX, oldY, oldW, newY - oldY);
                        bottom = newY;
                    }
                    if (newTop < oldTop) {
                        strips[count++] = NSMakeRect(oldX, newTop, oldW, oldTop - newTop);
                        oldTop = newTop;
                    }
                    if (oldX + 0.0 < newX) {
                        strips[count++] = NSMakeRect(oldX, bottom, newX - oldX, oldTop - bottom);
                    }
                    if (newRight < oldRight) {
                        strips[count++] = NSMakeRect(newRight, bottom, oldRight - newRight, oldTop - bottom);
                    }
                    for (unsigned int i = 0; i < count; i++) {
                        [[self owner] setNeedsDisplayInRect:strips[i]];
                    }
                }
            }
        }
    }
    _calculatedRectsAreValid = YES;
}

- (void)updateEmbeddedViewWithEditingObject
{
    [self clearChangedState];
}

- (id)loadEmbeddedView
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setViewEmbedder:(id)aEmbedder
{
    id self_00;

    if (_viewEmbedder != aEmbedder) {
        [_viewEmbedder setObserver:nil];
        [_viewEmbedder release];
        self_00 = [aEmbedder retain];
        _viewEmbedder = self_00;
        [self_00 setObserver:self];
    }
}

- (id)viewEmbedder
{
    return _viewEmbedder;
}

- (id)viewEmbeddingInterface
{
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_embeddedView autorelease];
    [_viewEmbedder setObserver:nil];
    [_viewEmbedder release];
    [super dealloc];
}

@end

