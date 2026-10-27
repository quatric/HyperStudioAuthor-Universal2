#import "HSPlayerInEditorCardView.h"

@interface HSPlayerInEditorCardView (HSPlayerInEditorCardViewSurfaceBounds)
- (void)HSPlayerInEditorCardView_updateRelativeOpenGLSurfaceBounds;
@end

@implementation HSPlayerInEditorCardView

/* i386 ivar offsets: _backgroundColor=0x1b8, _dragHelper=0x1bc, _cardOffset=0x1c0, _gridSettings=0x1c8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8162 @ 001c8162, 268 bytes * /

id FUN_001c8162(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id extraout_EDX;
  undefined4 uVar3;
  
  self_00 = _objc_msgSend(cls_HSLayoutGuidingTrackerHelper,sel_helperWithHostView_,self);
  pvVar1 = _objc_msgSend(self,sel_card);
  _objc_msgSend(self_00,sel_setCard_,pvVar1);
  pvVar1 = _objc_msgSend(self_00,sel_isSnappingEnabled);
  if ((char)pvVar1 != '\0') {
    uVar3 = 0x40a00000;
    _objc_msgSend(self_00,sel_setCommonSnapDelta_,0x40a00000);
    pvVar1 = _objc_msgSend(self,sel_gridSettings);
    pvVar1 = _objc_msgSend(pvVar1,sel_layoutGrid);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self_00,sel_isSnapToGridEnabled,uVar3);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(pvVar1,sel_gridSpacing,uVar3);
        pvVar1 = extraout_EDX;
        if ((float)extraout_EDX <= (float)pvVar2) {
          pvVar1 = pvVar2;
        }
        _objc_msgSend(self_00,sel_setGridSnapDelta_,pvVar1);
      }
    }
  }
  return self_00;
}

*/
- (id)layoutGuidingContext
{
    id helper = [HSLayoutGuidingTrackerHelper helperWithHostView:self];
    [helper setCard:[self card]];
    if ([helper isSnappingEnabled]) {
        [helper setCommonSnapDelta:5.0];
        id grid = [[self gridSettings] layoutGrid];
        if (grid != nil && [helper isSnapToGridEnabled]) {
            NSSize spacing = [grid gridSpacing];
            [helper setGridSnapDelta:MAX(spacing.width, spacing.height)];
        }
    }
    return helper;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8335 @ 001c8335, 305 bytes * /

void FUN_001c8335(HSPlayerInEditorCardView *self,SEL _cmd,id renderer,id didDrawRegion,
                 id ofRenderLayerAtIndexPath,id withRenderDelegate)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id *ppvVar4;
  id local_20;
  HSPlayerInEditorCardView *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSPlayerCardView_003539f0;
  _objc_msgSendSuper(&local_1c,
                     sel_renderer_didDrawRegion_ofRenderLayerAtIndexPath_withRenderDelegate_,
                     renderer,didDrawRegion,ofRenderLayerAtIndexPath,withRenderDelegate);
  local_20 = (id)0x0;
  pvVar1 = _objc_msgSend(renderer,sel_rootRenderLayer);
  ppvVar4 = &local_20;
  pvVar1 = _objc_msgSend(pvVar1,sel_renderLayerAtIndexPath_role_,ofRenderLayerAtIndexPath,ppvVar4);
  pvVar2 = _objc_msgSend(renderer,sel_visualization);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperObject);
  if (pvVar2 == pvVar1) {
    pcVar3 = &cfstr_HSBackgroundRenderLayerRole;
    pvVar1 = _objc_msgSend(local_20,sel_isEqualToString_,&cfstr_HSBackgroundRenderLayerRole,ppvVar4)
    ;
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_gridSettings,pcVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_isGridVisible);
      if ((char)pvVar1 != '\0') {
        _objc_msgSend(self,sel_renderGrid,pcVar3);
      }
    }
  }
  return;
}

*/
- (void)renderer:(id)aRenderer didDrawRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath withRenderDelegate:(id)aDelegate
{
    [super renderer:aRenderer didDrawRegion:aRegion ofRenderLayerAtIndexPath:aPath withRenderDelegate:aDelegate];
    id role = nil;
    id layer = [[aRenderer rootRenderLayer] renderLayerAtIndexPath:aPath role:&role];
    if ([[aRenderer visualization] hyperObject] == [layer hyperObject] && [role isEqualToString:@"HSBackgroundRenderLayerRole"]) {
        if ([[self gridSettings] isGridVisible]) {
            [self renderGrid];
        }
    }
}

- (void)gridSettingsDidChange:(id)aChange
{
    [self setNeedsDisplayOpenGLSurface:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8466 @ 001c8466, 108 bytes * /

void FUN_001c8466(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_gridSettings);
  _objc_msgSend_stret(&local_24,self,sel_contentBoundingRect);
  _HSRenderGrid(pvVar1,self,local_24,local_1c);
  return;
}

*/
- (void)renderGrid
{
    HSRenderGrid([self gridSettings], self, [self contentBoundingRect]);
}

- (id)gridSettings
{
    id self_00;
    id pvVar1_3;

    self_00 = [[[self card] stack] gridSettings];
    pvVar1_3 = _gridSettings;
    if (pvVar1_3 != self_00) {
        if (pvVar1_3 != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HSGridSettingsDidChangeNotification object:_gridSettings];
            [_gridSettings release];
        }
        _gridSettings = [self_00 retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridSettingsDidChange:) name:HSGridSettingsDidChangeNotification object:_gridSettings];
        pvVar1_3 = _gridSettings;
    }
    return pvVar1_3;
}

- (BOOL)readSelectionFromPasteboard:(id)aPasteboard
{
    return (BOOL)[self readSelectionFromPasteboard:aPasteboard useDragPreferences:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c7eba @ 001c7eba, 263 bytes * /

BOOL FUN_001c7eba(HSPlayerInEditorCardView *self,SEL _cmd,id readSelectionFromPasteboard,
                 BOOL useDragPreferences)

{
  char cVar1;
  id pvVar2;
  int iVar3;
  undefined4 uVar4;
  cfstringStruct *pcVar5;
  char *pcVar6;
  char local_d;
  
  pvVar2 = _objc_msgSend(self,sel_card);
  if (pvVar2 == (id)0x0) {
    cVar1 = '\0';
  }
  else {
    local_d = '\0';
    pvVar2 = _objc_msgSend(self,sel_dragHelper);
    pcVar6 = &local_d;
    iVar3 = (int)useDragPreferences;
    pvVar2 = _objc_msgSend(pvVar2,
                           sel_readSelectionFromPasteboard_useDragPreferences_didAddNewObject_,
                           readSelectionFromPasteboard,iVar3,pcVar6);
    cVar1 = (char)pvVar2;
    if (cVar1 != '\0') {
      uVar4 = 0;
      _objc_msgSend(self,sel_switchToEditorWithBlockingAnimation_,0,iVar3,pcVar6);
      if (local_d != '\0') {
        pvVar2 = _objc_msgSend(readSelectionFromPasteboard,sel_types,uVar4,iVar3,pcVar6);
        pcVar5 = &cfstr_HSObjectsPasteboardType;
        pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,&cfstr_HSObjectsPasteboardType);
        if ((char)pvVar2 == '\0') {
          pvVar2 = _objc_msgSend(self,sel_editorWindowController,pcVar5,iVar3,pcVar6);
          _objc_msgSend(pvVar2,sel_didAddNewObject);
        }
      }
    }
  }
  return cVar1;
}

*/
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard useDragPreferences:(BOOL)aPreferences
{
    BOOL didAddNewObject = NO;
    BOOL result;

    if ([self card] == nil) {
        return NO;
    }
    result = [[self dragHelper] readSelectionFromPasteboard:aPasteboard useDragPreferences:aPreferences didAddNewObject:&didAddNewObject];
    if (result) {
        [self switchToEditorWithBlockingAnimation:NO];
        if (didAddNewObject && ![[aPasteboard types] containsObject:@"HSObjectsPasteboardType"]) {
            [[self editorWindowController] didAddNewObject];
        }
    }
    return result;
}

- (void)showHelpPaneBeforeAddAction:(id)aAction actionEvent:(id)aEvent toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences
{

}

- (void)showHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences
{

}

- (BOOL)needsOpenHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer
{
    return NO;
}

- (BOOL)allowsDragSession
{
    if ([[self window] attachedSheet] == nil) {
        if (![[[self card] document] isInAnimationMode]) {
            if (![[[self card] document] isStackProtected]) {
                return ![[self editorDocument] isInHyperCastingMode];
            }
        }
    }
    return NO;
}

- (void)switchToEditorWithBlockingAnimation:(BOOL)aAnimation
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = [self editorDocument];
    [pvVar1 switchToEditor:YES blockingAnimation:aAnimation];
    pvVar1_3 = [[pvVar1 editorWindowController] cardView];
    [[pvVar1_3 window] makeFirstResponder:pvVar1_3];
}

- (BOOL)performDragOperation:(id)aOperation
{
    id pvVar1;
    id self_00;

    pvVar1 = [self editorDocument];
    self_00 = [pvVar1 undoManager];
    [pvVar1 selectInEditorCardViewObjects:nil];
    [self switchToEditorWithBlockingAnimation:YES];
    if ([self_00 groupingLevel] == 0x1) {
        if ([self_00 groupsByEvent]) {
            [self_00 endUndoGrouping];
            [self_00 beginUndoGrouping];
        }
    }
    return (BOOL)[[[self editorWindowController] cardView] performDragOperation:aOperation];
}

- (void)concludeDragOperation:(id)aOperation
{
    [[self dragHelper] concludeDragOperation:aOperation];
}

- (void)draggingExited:(id)aExited
{
    [[self dragHelper] draggingExited:aExited];
}

- (NSUInteger)draggingUpdated:(id)aUpdated
{
    return (unsigned int)[[self dragHelper] draggingUpdated:aUpdated];
}

- (NSUInteger)draggingEntered:(id)aEntered
{
    return (unsigned int)[[self dragHelper] draggingEntered:aEntered];
}

- (id)pasteboardTypes
{
    return [[self dragHelper] pasteboardTypes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c84d2 @ 001c84d2, 97 bytes * /

void FUN_001c84d2(HSPlayerInEditorCardView *self,SEL _cmd,NSRect drawWindowLayerContentRect)

{
  HSPlayerInEditorCardView *local_14;
  undefined *local_10;
  
  _objc_msgSend(self,sel_HSPlayerInEditorCardView_clipToCardBounds);
  local_14 = self;
  local_10 = PTR_s_HSPlayerCardView_003539f0;
  _objc_msgSendSuper(&local_14,sel_drawWindowLayerContentRect_,drawWindowLayerContentRect.origin,
                     drawWindowLayerContentRect.size);
  return;
}

*/
- (void)drawWindowLayerContentRect:(NSRect)aRect
{
    [self HSPlayerInEditorCardView_clipToCardBounds];
    [super drawWindowLayerContentRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8533 @ 001c8533, 97 bytes * /

void FUN_001c8533(HSPlayerInEditorCardView *self,SEL _cmd,NSRect drawViewLayerContentRect)

{
  HSPlayerInEditorCardView *local_14;
  undefined *local_10;
  
  _objc_msgSend(self,sel_HSPlayerInEditorCardView_clipToCardBounds);
  local_14 = self;
  local_10 = PTR_s_HSPlayerCardView_003539f0;
  _objc_msgSendSuper(&local_14,sel_drawViewLayerContentRect_,drawViewLayerContentRect.origin,
                     drawViewLayerContentRect.size);
  return;
}

*/
- (void)drawViewLayerContentRect:(NSRect)aRect
{
    [self HSPlayerInEditorCardView_clipToCardBounds];
    [super drawViewLayerContentRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8594 @ 001c8594, 311 bytes * /

void FUN_001c8594(HSPlayerInEditorCardView *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  undefined1 local_2c [28];
  
  pvVar3 = _objc_msgSend(self,sel_cardSize);
  if ((((float)pvVar3 != *(float *)PTR_00336704) ||
      (NAN((float)pvVar3) || NAN(*(float *)PTR_00336704))) ||
     (extraout_EDX != *(float *)(PTR_00336704 + 4))) {
    uVar1 = *(undefined4 *)PTR_00336074;
    uVar2 = *(undefined4 *)(PTR_00336074 + 4);
    pvVar4 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    pvVar4 = _objc_msgSend(pvVar4,sel_graphicsPort);
    _CGContextBeginPath(pvVar4);
    _CGContextSaveGState(pvVar4);
    _objc_msgSend_stret(local_2c,self,sel_userSpaceToViewSpaceCGAffineTransform);
    _CGContextConcatCTM(pvVar4,(int)local_2c._0_8_,SUB84(local_2c._0_8_,4),(int)local_2c._8_8_,
                        SUB84(local_2c._8_8_,4),(int)local_2c._16_8_,SUB84(local_2c._16_8_,4));
    _objc_msgSend(self,sel_addCardRect_toContext_,uVar1,uVar2,pvVar3,extraout_EDX,pvVar4);
    _CGContextRestoreGState(pvVar4);
    _CGContextClip(pvVar4);
  }
  return;
}

*/
- (void)HSPlayerInEditorCardView_clipToCardBounds
{
    NSSize size = [self cardSize];
    if (size.width != CGSizeZero.width || size.height != CGSizeZero.height) {
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextBeginPath(context);
        CGContextSaveGState(context);
        CGContextConcatCTM(context, [self userSpaceToViewSpaceCGAffineTransform]);
        [self addCardRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height) toContext:context];
        CGContextRestoreGState(context);
        CGContextClip(context);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c86cb @ 001c86cb, 689 bytes * /

void FUN_001c86cb(HSPlayerInEditorCardView *self,SEL _cmd,NSRect preDrawContentRect)

{
  char cVar1;
  id pvVar2;
  int *piVar3;
  HSPlayerInEditorCardView *local_74;
  undefined *local_70;
  undefined1 local_6c [16];
  undefined1 local_5c [16];
  undefined4 local_4c;
  undefined4 local_48;
  undefined4 local_44;
  undefined4 local_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined4 local_34;
  undefined4 uStack_30;
  undefined1 local_2c [28];
  
  _objc_msgSend(self,sel_cardSize);
  _objc_msgSend_stret(local_6c,self,sel_HSPlayerInEditorCardView_opaqueBoundingRectForCardSize_);
  _objc_msgSend_stret(local_5c,self,sel_viewBoundingRectForUserRect_);
  piVar3 = (int *)&stack0xffffff4c;
  cVar1 = _NSContainsRect();
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    _objc_msgSend(pvVar2,sel_graphicsPort);
    _CGContextSaveGState();
    _CGContextBeginPath();
    _objc_msgSend_stret(&local_4c,self,sel_bounds);
    local_3c = local_4c;
    uStack_38 = local_48;
    local_34 = local_44;
    uStack_30 = local_40;
    _CGContextAddRect();
    _CGContextSaveGState();
    _objc_msgSend_stret(local_2c,self,sel_userSpaceToViewSpaceCGAffineTransform);
    piVar3 = (int *)&stack0xffffff44;
    _CGContextConcatCTM();
    _objc_msgSend(self,sel_addCardRect_toContext_);
    _CGContextRestoreGState();
    _CGContextEOClip();
    pvVar2 = _objc_msgSend(self,sel_backgroundColor);
    _objc_msgSend(pvVar2,sel_set);
    _objc_msgSend(self,sel_drawBackgroundInContentRect_);
    _CGContextRestoreGState();
  }
  local_74 = self;
  local_70 = PTR_s_HSPlayerCardView_003539f0;
  *(NSSize *)(piVar3 + 4) = preDrawContentRect.size;
  *(NSPoint *)(piVar3 + 2) = preDrawContentRect.origin;
  piVar3[1] = (int)sel_preDrawContentRect_;
  *piVar3 = (int)&local_74;
  piVar3[-1] = 0x1c8971;
  _objc_msgSendSuper((void *)*piVar3,(SEL)piVar3[1]);
  return;
}

*/
- (void)preDrawContentRect:(NSRect)aRect
{
    NSSize size = [self cardSize];
    NSRect opaqueRect = [self viewBoundingRectForUserRect:[self HSPlayerInEditorCardView_opaqueBoundingRectForCardSize:size]];

    if (!NSContainsRect(opaqueRect, aRect)) {
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextSaveGState(context);
        CGContextBeginPath(context);
        CGContextAddRect(context, NSRectToCGRect([self bounds]));
        CGContextSaveGState(context);
        CGContextConcatCTM(context, [self userSpaceToViewSpaceCGAffineTransform]);
        [self addCardRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height) toContext:context];
        CGContextRestoreGState(context);
        CGContextEOClip(context);
        [(NSColor *)[self backgroundColor] set];
        [self drawBackgroundInContentRect:aRect];
        CGContextRestoreGState(context);
    }
    [super preDrawContentRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c897c @ 001c897c, 243 bytes * /

NSRect * FUN_001c897c(NSRect *__return_storage_ptr__,HSPlayerInEditorCardView *self,SEL _cmd,
                     NSSize HSPlayerInEditorCardView_opaqueBoundingRectForCardSize)

{
  id pvVar1;
  double dVar2;
  float local_1c;
  float fStack_18;
  float local_14;
  float fStack_10;
  
  local_1c = *(float *)PTR_00336074;
  fStack_18 = *(float *)(PTR_00336074 + 4);
  local_14 = HSPlayerInEditorCardView_opaqueBoundingRectForCardSize.width;
  fStack_10 = HSPlayerInEditorCardView_opaqueBoundingRectForCardSize.height;
  pvVar1 = _objc_msgSend(self,sel_roundsCardCorners);
  if ((char)pvVar1 != '\0') {
    dVar2 = _objc_msgSend_fpret(self,sel_HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize_);
    _NSInsetRect(&local_1c,CONCAT44(fStack_18,local_1c),CONCAT44(fStack_10,local_14),
                 (float)(dVar2 * 0.2928932188134524),(float)(dVar2 * 0.2928932188134524));
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = fStack_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = fStack_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)HSPlayerInEditorCardView_opaqueBoundingRectForCardSize:(NSSize)aSize
{
    NSRect rect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height);
    if ([self roundsCardCorners]) {
        // 1 - 1/sqrt(2): the part of the corner radius outside the inscribed square.
        CGFloat inset = [self HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize:aSize] * 0.2928932188134524;
        rect = NSInsetRect(rect, inset, inset);
    }
    return rect;
}

- (void)changeRoundsCardCorners:(BOOL)aCorners
{
    [super changeRoundsCardCorners:aCorners];
    [self HSPlayerInEditorCardView_setNeedsDisplayAroundRoundedCardCorners];
}

- (void)adjustCardFrame
{
    if ([self enclosingScrollView] != nil) {
        [self autosizePreservingVisibleCenter];
    }
}

- (BOOL)isOpaque
{
    return YES;
}

- (id)cardForDragHost
{
    return [self card];
}

- (void)endDragOperation
{
    [self endContentChangeAccumulation];
}

- (void)beginDragOperation
{
    [self beginContentChangeAccumulation];
}

- (BOOL)needImageOriginConvertion
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8ac2 @ 001c8ac2, 69 bytes * /

NSRect * FUN_001c8ac2(NSRect *__return_storage_ptr__,HSPlayerInEditorCardView *self,SEL _cmd,
                     NSRect convertToDragHostCardRect)

{
  NSRect *extraout_EAX;
  
  _objc_msgSend_stret(__return_storage_ptr__,self,sel_userBoundingRectForViewRect_,
                      convertToDragHostCardRect.origin,convertToDragHostCardRect.size);
  return extraout_EAX;
}

*/
- (NSRect)convertToDragHostCardRect:(NSRect)aRect
{
    return [self userBoundingRectForViewRect:aRect];
}

- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard
{
    return [self convertPointFromViewSpaceToUserSpace:aCard];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8b07 @ 001c8b07, 122 bytes * /

ulonglong FUN_001c8b07(HSPlayerInEditorCardView *self,SEL _cmd)

{
  undefined1 local_2c [12];
  float local_20;
  undefined1 local_1c [8];
  float local_14;
  
  _objc_msgSend_stret(local_2c,self,sel_bounds);
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  return CONCAT44(local_20 * 0.5,local_14 * 0.5);
}

*/
- (NSPoint)dragHostCardCenterPoint
{
    return NSMakePoint([self bounds].size.width * 0.5f, [self bounds].size.height * 0.5f);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c796c @ 001c796c, 145 bytes * /

id FUN_001c796c(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperTransformStruct_,0x3f800000,
                         0x3f80000000000000,(ulonglong)self->_cardOffset ^ 0x8000000080000000);
  return pvVar1;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_001c78e9 @ 001c78e9, 131 bytes * /

id FUN_001c78e9(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperTransformStruct_,0x3f800000,
                         0x3f80000000000000,self->_cardOffset);
  return pvVar1;
}

*/
- (void)cardSizeDidChange:(id)aChange
{
    if ([self enclosingScrollView] != nil) {
        [self autosizePreservingVisibleArea];
    }
    [self setNeedsDisplayOpenGLSurface:YES];
    [self setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8b81 @ 001c8b81, 457 bytes * /

void FUN_001c8b81(HSPlayerInEditorCardView *self,SEL _cmd,NSPoint autosizeCenteringAtUserPoint,
                 BOOL respectingLastVisibleContent)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  HSPlayerInEditorCardView *local_14;
  undefined *local_10;
  
  fVar1 = (self->_cardOffset).width;
  fVar2 = (self->_cardOffset).height;
  local_14 = self;
  local_10 = PTR_s_HSPlayerCardView_003539f0;
  _objc_msgSendSuper(&local_14,sel_autosizeCenteringAtUserPoint_respectingLastVisibleContent_,
                     autosizeCenteringAtUserPoint.x,autosizeCenteringAtUserPoint.y,
                     (int)respectingLastVisibleContent);
  fVar3 = (self->_cardOffset).width;
  fVar4 = (self->_cardOffset).height;
  if ((((fVar3 < fVar1 + -0.001953125) || (fVar1 + 0.001953125 < fVar3)) ||
      (fVar4 < fVar2 + -0.001953125)) || (fVar2 + 0.001953125 < fVar4)) {
    _objc_msgSend(self,sel_notifyDidChangeUserSpaceToViewSpaceTransform);
  }
  _objc_msgSend_stret(&local_34,self,sel_bounds);
  _objc_msgSend_stret(&local_44,self,sel_cardViewingRect);
  fStack_20 = local_40 - local_30;
  local_24 = local_44 - local_34;
  if (0.0 < local_2c) {
    local_3c = local_3c / local_2c;
    local_24 = local_24 / local_2c;
  }
  if (0.0 < local_28) {
    local_38 = local_38 / local_28;
    fStack_20 = fStack_20 / local_28;
  }
  local_1c = local_3c;
  fStack_18 = local_38;
  _objc_msgSend(self,sel_setRelativeOpenGLSurfaceBounds_,CONCAT44(fStack_20,local_24),
                CONCAT44(local_38,local_3c));
  return;
}

*/
- (void)autosizeCenteringAtUserPoint:(NSPoint)aPoint respectingLastVisibleContent:(BOOL)aContent
{
    NSSize oldOffset = _cardOffset;
    [super autosizeCenteringAtUserPoint:aPoint respectingLastVisibleContent:aContent];
    if (_cardOffset.width < oldOffset.width - 0.001953125f || oldOffset.width + 0.001953125f < _cardOffset.width ||
        _cardOffset.height < oldOffset.height - 0.001953125f || oldOffset.height + 0.001953125f < _cardOffset.height) {
        [self notifyDidChangeUserSpaceToViewSpaceTransform];
    }
    [self HSPlayerInEditorCardView_updateRelativeOpenGLSurfaceBounds];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8d4a @ 001c8d4a, 427 bytes * /

void FUN_001c8d4a(HSPlayerInEditorCardView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  HSPlayerInEditorCardView *local_14;
  undefined *local_10;
  
  fVar1 = (self->_cardOffset).width;
  fVar2 = (self->_cardOffset).height;
  local_14 = self;
  local_10 = PTR_s_HSPlayerCardView_003539f0;
  _objc_msgSendSuper(&local_14,sel_autosizePreservingVisibleCenter);
  fVar3 = (self->_cardOffset).width;
  fVar4 = (self->_cardOffset).height;
  if ((((fVar3 < fVar1 + -0.001953125) || (fVar1 + 0.001953125 < fVar3)) ||
      (fVar4 < fVar2 + -0.001953125)) || (fVar2 + 0.001953125 < fVar4)) {
    _objc_msgSend(self,sel_notifyDidChangeUserSpaceToViewSpaceTransform);
  }
  _objc_msgSend_stret(&local_34,self,sel_bounds);
  _objc_msgSend_stret(&local_44,self,sel_cardViewingRect);
  fStack_20 = local_40 - local_30;
  local_24 = local_44 - local_34;
  if (0.0 < local_2c) {
    local_3c = local_3c / local_2c;
    local_24 = local_24 / local_2c;
  }
  if (0.0 < local_28) {
    local_38 = local_38 / local_28;
    fStack_20 = fStack_20 / local_28;
  }
  local_1c = local_3c;
  fStack_18 = local_38;
  _objc_msgSend(self,sel_setRelativeOpenGLSurfaceBounds_,CONCAT44(fStack_20,local_24),
                CONCAT44(local_38,local_3c));
  return;
}

*/
- (void)autosizePreservingVisibleCenter
{
    NSSize oldOffset = _cardOffset;
    [super autosizePreservingVisibleCenter];
    if (_cardOffset.width < oldOffset.width - 0.001953125f || oldOffset.width + 0.001953125f < _cardOffset.width ||
        _cardOffset.height < oldOffset.height - 0.001953125f || oldOffset.height + 0.001953125f < _cardOffset.height) {
        [self notifyDidChangeUserSpaceToViewSpaceTransform];
    }
    [self HSPlayerInEditorCardView_updateRelativeOpenGLSurfaceBounds];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c8ef5 @ 001c8ef5, 427 bytes * /

void FUN_001c8ef5(HSPlayerInEditorCardView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  HSPlayerInEditorCardView *local_14;
  undefined *local_10;
  
  fVar1 = (self->_cardOffset).width;
  fVar2 = (self->_cardOffset).height;
  local_14 = self;
  local_10 = PTR_s_HSPlayerCardView_003539f0;
  _objc_msgSendSuper(&local_14,sel_autosizePreservingVisibleArea);
  fVar3 = (self->_cardOffset).width;
  fVar4 = (self->_cardOffset).height;
  if ((((fVar3 < fVar1 + -0.001953125) || (fVar1 + 0.001953125 < fVar3)) ||
      (fVar4 < fVar2 + -0.001953125)) || (fVar2 + 0.001953125 < fVar4)) {
    _objc_msgSend(self,sel_notifyDidChangeUserSpaceToViewSpaceTransform);
  }
  _objc_msgSend_stret(&local_34,self,sel_bounds);
  _objc_msgSend_stret(&local_44,self,sel_cardViewingRect);
  fStack_20 = local_40 - local_30;
  local_24 = local_44 - local_34;
  if (0.0 < local_2c) {
    local_3c = local_3c / local_2c;
    local_24 = local_24 / local_2c;
  }
  if (0.0 < local_28) {
    local_38 = local_38 / local_28;
    fStack_20 = fStack_20 / local_28;
  }
  local_1c = local_3c;
  fStack_18 = local_38;
  _objc_msgSend(self,sel_setRelativeOpenGLSurfaceBounds_,CONCAT44(fStack_20,local_24),
                CONCAT44(local_38,local_3c));
  return;
}

*/
- (void)autosizePreservingVisibleArea
{
    NSSize oldOffset = _cardOffset;
    [super autosizePreservingVisibleArea];
    if (_cardOffset.width < oldOffset.width - 0.001953125f || oldOffset.width + 0.001953125f < _cardOffset.width ||
        _cardOffset.height < oldOffset.height - 0.001953125f || oldOffset.height + 0.001953125f < _cardOffset.height) {
        [self notifyDidChangeUserSpaceToViewSpaceTransform];
    }
    [self HSPlayerInEditorCardView_updateRelativeOpenGLSurfaceBounds];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c90a0 @ 001c90a0, 566 bytes * /

void FUN_001c90a0(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  uint uVar2;
  float *pfVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  undefined8 uVar7;
  undefined8 in_stack_ffffff6c;
  undefined8 uVar8;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54 [2];
  undefined8 local_4c;
  
  uVar8 = CONCAT44((int)((ulonglong)in_stack_ffffff6c >> 0x20),sel_cardViewingRect);
  _objc_msgSend_stret(&local_64,self,sel_cardViewingRect);
  uVar7 = CONCAT44(sel_bounds,self);
  _objc_msgSend_stret(&local_74,self,sel_bounds);
  local_54[0] = local_74;
  local_54[1] = local_70;
  local_4c._0_4_ = local_6c;
  local_4c._4_4_ = local_68;
  fVar5 = local_74 + local_6c;
  if (local_64 < fVar5) {
    local_5c = local_5c + local_64;
    if ((local_5c <= local_74 + 0.0) || (local_68 = local_68 + local_70, local_68 <= local_60))
    goto LAB_001c914e;
    local_58 = local_58 + local_60;
    fVar6 = local_70 + 0.0;
    if (local_58 <= fVar6) goto LAB_001c914e;
    fVar4 = local_70;
    if (fVar6 < local_60) {
      local_4c._4_4_ = local_60 - local_70;
      fVar4 = local_60;
    }
    uVar2 = (uint)(fVar6 < local_60);
    if (local_58 < local_68) {
      local_54[uVar2 * 4] = local_74;
      local_54[uVar2 * 4 + 1] = local_58;
      *(float *)(&local_4c + uVar2 * 2) = local_6c;
      *(float *)((int)&local_4c + uVar2 * 0x10 + 4) = local_68 - local_58;
      uVar2 = uVar2 + 1;
      local_68 = local_58;
    }
    if (local_74 + 0.0 < local_64) {
      local_54[uVar2 * 4] = local_74;
      local_54[uVar2 * 4 + 1] = fVar4;
      *(float *)(&local_4c + uVar2 * 2) = local_64 - local_74;
      *(float *)((int)&local_4c + uVar2 * 0x10 + 4) = local_68 - fVar4;
      uVar2 = uVar2 + 1;
    }
    if (local_5c < fVar5) {
      local_54[uVar2 * 4] = local_5c;
      local_54[uVar2 * 4 + 1] = fVar4;
      *(float *)(&local_4c + uVar2 * 2) = fVar5 - local_5c;
      *(float *)((int)&local_4c + uVar2 * 0x10 + 4) = local_68 - fVar4;
      uVar2 = uVar2 + 1;
    }
    if (uVar2 == 0) goto LAB_001c929d;
    pfVar3 = local_54;
  }
  else {
LAB_001c914e:
    pfVar3 = local_54;
    uVar2 = 1;
  }
  do {
    uVar7 = *(undefined8 *)pfVar3;
    uVar8 = *(undefined8 *)(pfVar3 + 2);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,uVar7,uVar8);
    pfVar3 = pfVar3 + 4;
    uVar2 = uVar2 - 1;
  } while (uVar2 != 0);
LAB_001c929d:
  pvVar1 = _objc_msgSend(self,sel_roundsCardCorners,uVar7,uVar8);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_HSPlayerInEditorCardView_setNeedsDisplayAroundRoundedCardCorners,uVar7,
                  uVar8);
  }
  return;
}

*/
- (void)setNeedsDisplayWorkAreaBackground
{
    NSRect viewing = [self cardViewingRect];
    NSRect bounds = [self bounds];
    NSRect rects[4];
    NSUInteger count = 0;
    NSUInteger index;

    if (NSMinX(viewing) < NSMaxX(bounds) && NSMinX(bounds) < NSMaxX(viewing) &&
        NSMinY(viewing) < NSMaxY(bounds) && NSMinY(bounds) < NSMaxY(viewing)) {
        CGFloat bottom = NSMinY(bounds);
        CGFloat top = NSMaxY(bounds);
        if (NSMinY(bounds) < NSMinY(viewing)) {
            rects[count++] = NSMakeRect(NSMinX(bounds), NSMinY(bounds), NSWidth(bounds), NSMinY(viewing) - NSMinY(bounds));
            bottom = NSMinY(viewing);
        }
        if (NSMaxY(viewing) < top) {
            rects[count++] = NSMakeRect(NSMinX(bounds), NSMaxY(viewing), NSWidth(bounds), top - NSMaxY(viewing));
            top = NSMaxY(viewing);
        }
        if (NSMinX(bounds) < NSMinX(viewing)) {
            rects[count++] = NSMakeRect(NSMinX(bounds), bottom, NSMinX(viewing) - NSMinX(bounds), top - bottom);
        }
        if (NSMaxX(viewing) < NSMaxX(bounds)) {
            rects[count++] = NSMakeRect(NSMaxX(viewing), bottom, NSMaxX(bounds) - NSMaxX(viewing), top - bottom);
        }
    }
    else {
        rects[count++] = bounds;
    }
    for (index = 0; index < count; index++) {
        [self setNeedsDisplayInRect:rects[index]];
    }
    if ([self roundsCardCorners]) {
        [self HSPlayerInEditorCardView_setNeedsDisplayAroundRoundedCardCorners];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c92d6 @ 001c92d6, 1126 bytes * /

void FUN_001c92d6(HSPlayerInEditorCardView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  float extraout_EDX;
  longdouble lVar4;
  longdouble lVar5;
  float fVar6;
  float fVar7;
  double dVar8;
  float local_94;
  float local_90;
  float local_8c;
  float local_88;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  float local_74;
  float fStack_70;
  float local_6c;
  float fStack_68;
  float local_64;
  float fStack_60;
  float local_5c;
  float fStack_58;
  float local_54;
  float fStack_50;
  float local_4c;
  float fStack_48;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  id local_1c;
  float fStack_18;
  
  pvVar3 = _objc_msgSend(self,sel_cardSize);
  fVar1 = *(float *)PTR_00336074;
  fVar2 = *(float *)(PTR_00336074 + 4);
  dVar8 = _objc_msgSend_fpret(self,sel_HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize_,
                              pvVar3,extraout_EDX);
  local_24 = fVar1;
  fStack_20 = fVar2;
  local_1c = pvVar3;
  fStack_18 = extraout_EDX;
  _objc_msgSend_stret(&local_24,self,sel_viewBoundingRectForUserRect_,fVar1,fVar2,
                      CONCAT44(extraout_EDX,pvVar3));
  fVar6 = local_24 + (float)local_1c;
  fVar7 = fStack_20 + fStack_18;
  _NSInsetRect();
  _objc_msgSend_stret(&local_84,self,sel_convertRect_toView_,local_34,fStack_30,local_2c,fStack_28,0
                     );
  lVar4 = (longdouble)_roundf(local_84);
  fVar1 = (float)lVar4;
  lVar4 = (longdouble)_roundf((fVar1 - local_84) + local_7c);
  lVar5 = (longdouble)_roundf(local_80);
  fVar2 = (float)lVar5;
  lVar5 = (longdouble)_roundf((fVar2 - local_80) + local_78);
  local_2c = (float)lVar4;
  fStack_28 = (float)lVar5;
  local_34 = fVar1;
  fStack_30 = fVar2;
  _objc_msgSend_stret(&local_94,self,sel_convertRect_fromView_,fVar1,fVar2,local_2c,fStack_28,0);
  local_34 = local_94;
  fStack_30 = local_90;
  local_2c = local_8c;
  fStack_28 = local_88;
  local_44 = local_94;
  fVar1 = (float)dVar8;
  fStack_40 = local_90;
  local_3c = (local_24 - local_94) + fVar1;
  fStack_38 = (fStack_20 - local_90) + fVar1;
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,CONCAT44(local_90,local_94),local_3c,fStack_38);
  local_54 = local_44;
  fStack_50 = fVar7 - fVar1;
  local_4c = local_3c;
  fStack_48 = ((fStack_30 + fStack_28) - fVar7) + fVar1;
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,CONCAT44(fStack_50,local_44),local_3c,fStack_48);
  local_64 = fVar6 - fVar1;
  fStack_60 = fStack_50;
  local_5c = ((local_34 + local_2c) - fVar6) + fVar1;
  fStack_58 = fStack_48;
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,CONCAT44(fStack_50,local_64),local_5c,fStack_48);
  local_74 = local_64;
  fStack_70 = fStack_40;
  local_6c = local_5c;
  fStack_68 = fStack_38;
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,CONCAT44(fStack_40,local_64),local_5c,fStack_38);
  return;
}

*/
- (void)HSPlayerInEditorCardView_setNeedsDisplayAroundRoundedCardCorners
{
    NSSize size = [self cardSize];
    CGFloat radius = [self HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize:size];
    NSRect cardRect = [self viewBoundingRectForUserRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height)];
    CGFloat maxX = NSMaxX(cardRect);
    CGFloat maxY = NSMaxY(cardRect);
    NSRect windowRect = [self convertRect:NSInsetRect(cardRect, -1, -1) toView:nil];
    NSRect roundedRect;

    roundedRect.origin.x = roundf(windowRect.origin.x);
    roundedRect.size.width = roundf((roundedRect.origin.x - windowRect.origin.x) + windowRect.size.width);
    roundedRect.origin.y = roundf(windowRect.origin.y);
    roundedRect.size.height = roundf((roundedRect.origin.y - windowRect.origin.y) + windowRect.size.height);
    NSRect outer = [self convertRect:roundedRect fromView:nil];
    CGFloat leftWidth = (cardRect.origin.x - outer.origin.x) + radius;
    CGFloat bottomHeight = (cardRect.origin.y - outer.origin.y) + radius;
    CGFloat rightWidth = (NSMaxX(outer) - maxX) + radius;
    CGFloat topHeight = (NSMaxY(outer) - maxY) + radius;

    [self setNeedsDisplayInRect:NSMakeRect(outer.origin.x, outer.origin.y, leftWidth, bottomHeight)];
    [self setNeedsDisplayInRect:NSMakeRect(outer.origin.x, maxY - radius, leftWidth, topHeight)];
    [self setNeedsDisplayInRect:NSMakeRect(maxX - radius, maxY - radius, rightWidth, topHeight)];
    [self setNeedsDisplayInRect:NSMakeRect(maxX - radius, outer.origin.y, rightWidth, bottomHeight)];
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [aColor retain];
        [_backgroundColor release];
        _backgroundColor = aColor;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c7720 @ 001c7720, 120 bytes * /

id FUN_001c7720(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = self->_backgroundColor;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_HSPlayerInEditorCardView_backgroundPattern);
    op = sel_colorWithPatternImage_;
    if (pvVar1 == (id)0x0) {
      op = sel_clearColor;
    }
    pvVar1 = _objc_msgSend(cls_NSColor,op);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_backgroundColor = pvVar1;
  }
  return pvVar1;
}

*/
- (id)backgroundColor
{
    if (_backgroundColor == nil) {
        id pattern = [self HSPlayerInEditorCardView_backgroundPattern];
        _backgroundColor = [(pattern != nil ? [NSColor colorWithPatternImage:pattern] : [NSColor clearColor]) retain];
    }
    return _backgroundColor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c763c @ 001c763c, 228 bytes * /

id FUN_001c763c(HSPlayerInEditorCardView *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id self_00;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar2 = _objc_msgSend(pvVar1,sel_stringForKey_,*(undefined4 *)PTR_00336054);
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar5 = &cfstr_WABPatterns;
  pcVar4 = &cfstr_tiff;
  pcVar3 = &cfstr_Denim;
  if (pcVar2 != (cfstringStruct *)0x0) {
    pcVar3 = pcVar2;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_inDirectory_,pcVar3,&cfstr_tiff,
                         &cfstr_WABPatterns);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    self_00 = _objc_msgSend(cls_NSImage,sel_alloc,pcVar3,pcVar4,pcVar5);
    pvVar1 = _objc_msgSend(self_00,sel_initByReferencingFile_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  }
  return pvVar1;
}

*/
- (id)HSPlayerInEditorCardView_backgroundPattern
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:HSWorkAreaBackgroundKey];
    NSString *path = [[NSBundle mainBundle] pathForResource:(name != nil ? name : @"Denim") ofType:@"tiff" inDirectory:@"WABPatterns"];

    if (path == nil) {
        return nil;
    }
    return [[[NSImage alloc] initByReferencingFile:path] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c75df @ 001c75df, 93 bytes * /

NSRect * FUN_001c75df(NSRect *__return_storage_ptr__,HSPlayerInEditorCardView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  NSRect *pNVar3;
  float extraout_EDX;
  
  fVar1 = *(float *)PTR_00336074;
  fVar2 = *(float *)(PTR_00336074 + 4);
  pNVar3 = _objc_msgSend(self,sel_cardSize);
  (__return_storage_ptr__->origin).x = fVar1;
  (__return_storage_ptr__->origin).y = fVar2;
  (__return_storage_ptr__->size).width = (float)pNVar3;
  (__return_storage_ptr__->size).height = extraout_EDX;
  return pNVar3;
}

*/
- (NSRect)contentBoundingRect
{
    NSSize size = [self cardSize];
    return NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c7334 @ 001c7334, 20 bytes * /

ulonglong FUN_001c7334(HSPlayerInEditorCardView *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_cardOffset).width;
  uVar1._4_4_ = (self->_cardOffset).height;
  return uVar1;
}

*/
- (id)editorWindowController
{
    return [[self editorDocument] editorWindowController];
}

- (id)editorDocument
{
    return [[self card] document];
}

- (void)awakeFromNib
{
    if (1038.0 < NSAppKitVersionNumber || NSAppKitVersionNumber == 1038.0) {
        [self setAcceptsTouchEvents:1];
    }
    [self dragHelper];
}

- (NSUInteger)importToCardDataFromFiles:(id)aFiles showHelpPane:(BOOL)aPane
{
    [self switchToEditorWithBlockingAnimation:NO];
    return (unsigned int)[[[self editorDocument] cardView] importToCardDataFromFiles:aFiles showHelpPane:(unsigned int)aPane];
}

- (id)dragHelper
{
    HSEditorCardViewDragHelper *pHVar1;

    pHVar1 = _dragHelper;
    if (pHVar1 == nil) {
        pHVar1 = [[HSEditorCardViewDragHelper alloc] initWithDragHost:self];
        _dragHelper = pHVar1;
    }
    return pHVar1;
}

- (void)dealloc
{
    [_backgroundColor release];
    [_gridSettings release];
    [_dragHelper invalidateDragHost];
    [_dragHelper release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)HSPlayerInEditorCardView_updateRelativeOpenGLSurfaceBounds
{
    NSRect bounds = [self bounds];
    NSRect viewing = [self cardViewingRect];
    NSRect relative;

    relative.origin.x = viewing.origin.x - bounds.origin.x;
    relative.origin.y = viewing.origin.y - bounds.origin.y;
    relative.size = viewing.size;
    if (0.0 < bounds.size.width) {
        relative.size.width /= bounds.size.width;
        relative.origin.x /= bounds.size.width;
    }
    if (0.0 < bounds.size.height) {
        relative.size.height /= bounds.size.height;
        relative.origin.y /= bounds.size.height;
    }
    [self setRelativeOpenGLSurfaceBounds:relative];
}

@end

