#import "HSDragCardViewCanvasLayer.h"

/* FUN_00228eb8: the card view can be scrolled when one of its scroll view scrollers is active */
static BOOL HSCardViewCanScroll(id view)
{
    NSScrollView *scrollView = [view enclosingScrollView];
    if ([scrollView hasVerticalScroller] && [[scrollView verticalScroller] isEnabled] && ![[scrollView verticalScroller] isHidden]) {
        return YES;
    }
    if ([scrollView hasHorizontalScroller] && [[scrollView horizontalScroller] isEnabled]) {
        return ![[scrollView horizontalScroller] isHidden];
    }
    return NO;
}

@implementation HSDragCardViewCanvasLayer

/* i386 ivar offsets: _startPoint=0x8, _currentCursor=0x10, _isLayerStarted=0x14, _activeLayerMode=0x18 */

- (void)HSDragCardViewCanvasLayer_windowDidBecomeKey:(id)aKey
{
    id pvVar1;

    if (_activeLayerMode == 1) {
        pvVar1 = [HSKeysRegistry sharedRegistry];
        if (![pvVar1 isKeyWithVirtualCodePressed:0x31]) {
            _activeLayerMode = 0;
            [self resetCurrentCursor];
            [[aKey object] resetCursorRects];
        }
    }
}

- (void)HSDragCardViewCanvasLayer_selectCursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags
{
    id pvVar1;

    pvVar1 = [self cursorForLayerMode:aMode modifierFlags:aFlags];
    if (pvVar1 != _currentCursor) {
        [_currentCursor release];
        _currentCursor = [pvVar1 retain];
    }
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    id pvVar1;

    pvVar1 = _currentCursor;
    if (pvVar1 == nil) {
        [self HSDragCardViewCanvasLayer_selectCursorForLayerMode:_activeLayerMode modifierFlags:[aEvent modifierFlags]];
        pvVar1 = _currentCursor;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002290b8 @ 002290b8, 85 bytes * /

id FUN_002290b8(HSDragCardViewCanvasLayer *self,SEL _cmd,NSPoint hitTestCanvasLayerAtPoint,
               BOOL insideView,uint clickCount,uint modifierFlags,id *hitTestInfo)

{
  char cVar1;
  id pvVar2;
  HSDragCardViewCanvasLayer *pHVar3;
  
  if (((insideView == '\0') || ((modifierFlags & 0x9e0000) != 0)) || (self->_activeLayerMode != 1))
  {
    pHVar3 = (HSDragCardViewCanvasLayer *)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_renderingView);
    cVar1 = FUN_00228eb8(pvVar2);
    pHVar3 = (HSDragCardViewCanvasLayer *)0x0;
    if (cVar1 != '\0') {
      pHVar3 = self;
    }
  }
  return pHVar3;
}

*/
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    if (aView && (aFlags & 0x9e0000) == 0 && _activeLayerMode == 1 && HSCardViewCanScroll([self renderingView])) {
        return self;
    }
    return nil;
    return 0;
}

- (id)cursorWithMouseEvent:(id)aEvent inTrackingLoop:(id)aLoop
{
    id pvVar1;

    pvVar1 = _currentCursor;
    if (pvVar1 == nil) {
        [self HSDragCardViewCanvasLayer_selectCursorForLayerMode:_activeLayerMode modifierFlags:[aEvent modifierFlags]];
        pvVar1 = _currentCursor;
    }
    return pvVar1;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)handleKeyUp:(id)aUp inTrackingLoop:(id)aLoop
{
    if (_activeLayerMode == 2) {
        if ((short)[aUp keyCode] == 0x31) {
            _activeLayerMode = 1;
            [self resetCurrentCursor];
            [[self renderingView] updateCursor];
        }
    }
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)handleKeyDown:(id)aDown inTrackingLoop:(id)aLoop
{
    if (_activeLayerMode == 1) {
        if ((short)[aDown keyCode] == 0x31) {
            _activeLayerMode = 2;
            [self resetCurrentCursor];
            [[self renderingView] updateCursor];
        }
    }
}
#pragma clang diagnostic pop

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{

}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    float fVar1;

    fVar1 = NSZeroPoint.y;
    (_startPoint).x = NSZeroPoint.x;
    (_startPoint).y = fVar1;
    if (_activeLayerMode == 1) {
        _activeLayerMode = 0;
    }
    if (_activeLayerMode == 2) {
        _activeLayerMode = 1;
    }
    [self resetCurrentCursor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022915b @ 0022915b, 311 bytes * /

void FUN_0022915b(HSDragCardViewCanvasLayer *self,SEL _cmd,id handleMouseDragged,id inTrackingLoop)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  float local_24;
  float local_20;
  
  pvVar1 = _objc_msgSend(handleMouseDragged,sel_locationInWindow);
  pvVar2 = _objc_msgSend(handleMouseDragged,sel_modifierFlags);
  if ((((uint)pvVar2 & 0x9e0000) == 0) && (self->_activeLayerMode == 2)) {
    pvVar2 = _objc_msgSend(self,sel_renderingView);
    pvVar3 = _objc_msgSend(pvVar2,sel_enclosingScrollView);
    _objc_msgSend_stret(&local_24,pvVar3,sel_documentVisibleRect);
    pvVar3 = _objc_msgSend(pvVar2,sel_isFlipped);
    fVar4 = (self->_startPoint).y;
    if ((char)pvVar3 == '\0') {
      fVar4 = extraout_EDX - fVar4;
    }
    else {
      fVar4 = fVar4 - extraout_EDX;
    }
    _objc_msgSend(pvVar2,sel_scrollPoint_,local_24 - ((float)pvVar1 - (self->_startPoint).x),
                  local_20 - fVar4);
  }
  (self->_startPoint).x = (float)pvVar1;
  (self->_startPoint).y = extraout_EDX;
  return;
}

*/
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    NSPoint location = [(NSEvent *)aDragged locationInWindow];
    if (([(NSEvent *)aDragged modifierFlags] & 0x9e0000) == 0 && _activeLayerMode == 2) {
        id view = [self renderingView];
        NSRect visible = [[view enclosingScrollView] documentVisibleRect];
        float deltaY;
        if ([view isFlipped]) {
            deltaY = _startPoint.y - location.y;
        } else {
            deltaY = location.y - _startPoint.y;
        }
        [view scrollPoint:NSMakePoint(visible.origin.x - (location.x - _startPoint.x), visible.origin.y - deltaY)];
    }
    _startPoint = location;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00228b83 @ 00228b83, 69 bytes * /

void FUN_00228b83(HSDragCardViewCanvasLayer *self,SEL _cmd,id handleMouseDown,id inTrackingLoop)

{
  id pvVar1;
  float extraout_EDX;
  
  _objc_msgSend(self,sel_resetCurrentCursor);
  pvVar1 = _objc_msgSend(handleMouseDown,sel_locationInWindow);
  (self->_startPoint).x = (float)pvVar1;
  (self->_startPoint).y = extraout_EDX;
  return;
}

*/
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    [self resetCurrentCursor];
    _startPoint = [(NSEvent *)aDown locationInWindow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00229292 @ 00229292, 273 bytes * /

BOOL FUN_00229292(HSDragCardViewCanvasLayer *self,SEL _cmd,NSPoint handleMouseDownAtPoint,id event,
                 id hitTestInfo)

{
  undefined *self_00;
  char cVar1;
  id pvVar2;
  HSDragCardViewCanvasLayer *local_1c;
  undefined *local_18;
  
  if (event != (id)0x0) {
    pvVar2 = _objc_msgSend(event,sel_modifierFlags);
    if ((((uint)pvVar2 & 0x9e0000) != 0) || (self->_activeLayerMode != 1)) {
      local_1c = self;
      local_18 = PTR_s_HSSimpleCanvasSublayer_00355100;
      pvVar2 = _objc_msgSendSuper(&local_1c,sel_handleMouseDownAtPoint_event_hitTestInfo_,
                                  handleMouseDownAtPoint.x,handleMouseDownAtPoint.y,event,
                                  hitTestInfo);
      return (BOOL)pvVar2;
    }
    pvVar2 = _objc_msgSend(self,sel_renderingView);
    cVar1 = FUN_00228eb8(pvVar2);
    if (cVar1 != '\0') {
      self->_activeLayerMode = 2;
      self_00 = cls_HSTrackingLoop;
      pvVar2 = _objc_msgSend(self,sel_renderingView);
      pvVar2 = _objc_msgSend(self_00,sel_trackingLoopWithView_client_,pvVar2,self);
      _objc_msgSend(pvVar2,sel_runWithMouseDownEvent_,event);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if (aEvent != nil) {
        if (([(NSEvent *)aEvent modifierFlags] & 0x9e0000) != 0 || _activeLayerMode != 1) {
            return [super handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
        }
        if (HSCardViewCanScroll([self renderingView])) {
            _activeLayerMode = 2;
            [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:self] runWithMouseDownEvent:aEvent];
            return YES;
        }
    }
    return NO;
    return 0;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (BOOL)handleRawKeyUpEvent:(id)aEvent
{
    int pvVar1;

    if ((_activeLayerMode != 0) && (pvVar1 = [aEvent keyCode], (short)pvVar1 == 0x31)) {
        _activeLayerMode = (unsigned int)(_activeLayerMode == 2);
        [self resetCurrentCursor];
        [[self renderingView] updateCursor];
        return YES;
    }
    return NO;
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    BOOL BVar1;

    if ((short)[aEvent keyCode] == 0x31) {
        if (_activeLayerMode == 0) {
            _activeLayerMode = 1;
            [self resetCurrentCursor];
            [[self renderingView] updateCursor];
            BVar1 = YES;
        }
        else {
            BVar1 = YES;
        }
    }
    else {
        BVar1 = NO;
    }
    return BVar1;
}
#pragma clang diagnostic pop

- (void)willStopRunningInWindow
{
    [super willStopRunningInWindow];
    if (_isLayerStarted != NO) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:0];
        _isLayerStarted = NO;
    }
}

- (void)willStopRunning
{
    [super willStopRunning];
    if (_isLayerStarted != NO) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:0];
        _isLayerStarted = NO;
    }
}

- (void)didStartRunningInWindow
{
    [super didStartRunningInWindow];
    if (_isLayerStarted == NO) {
        [self initialzeCanvasLayer];
    }
}

- (void)didStartRunning
{
    [super didStartRunning];
    if (_isLayerStarted == NO) {
        [self initialzeCanvasLayer];
    }
}

- (void)resetCurrentCursor
{
    [_currentCursor release];
    _currentCursor = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00228fbf @ 00228fbf, 249 bytes * /

id FUN_00228fbf(HSDragCardViewCanvasLayer *self,SEL _cmd,int cursorForLayerMode,uint modifierFlags)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  
  if (cursorForLayerMode == 1) {
    pvVar3 = _objc_msgSend(self,sel_renderingView);
    cVar1 = FUN_00228eb8(pvVar3);
    if (cVar1 == '\0') {
      return (id)0x0;
    }
    pvVar2 = _objc_msgSend(cls_HSCursor,sel_alloc);
    pvVar3 = _objc_msgSend(cls_NSCursor,sel_openHandCursor);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithCursor_,pvVar3);
  }
  else {
    if (cursorForLayerMode != 2) {
      return (id)0x0;
    }
    pvVar2 = _objc_msgSend(cls_HSCursor,sel_alloc);
    pvVar3 = _objc_msgSend(cls_NSCursor,sel_closedHandCursor);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithCursor_,pvVar3);
  }
  pvVar3 = _objc_msgSend(pvVar2,sel_autorelease,pvVar3);
  return pvVar3;
}

*/
- (id)cursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags
{
    id cursor;
    if (aMode == 1) {
        if (!HSCardViewCanScroll([self renderingView])) {
            return nil;
        }
        cursor = [[HSCursor alloc] initWithCursor:[NSCursor openHandCursor]];
    } else {
        if (aMode != 2) {
            return nil;
        }
        cursor = [[HSCursor alloc] initWithCursor:[NSCursor closedHandCursor]];
    }
    return [cursor autorelease];
    return 0;
}

- (NSInteger)activeLayerMode
{
    return _activeLayerMode;
}

- (BOOL)isLayerStarted
{
    return _isLayerStarted;
}

- (void)initialzeCanvasLayer
{
    id pvVar2_2;

    [self HSDragCardViewCanvasLayer_selectCursorForLayerMode:_activeLayerMode modifierFlags:[NSEvent modifierFlags]];
    pvVar2_2 = [[self renderingView] window];
    if (pvVar2_2 != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSDragCardViewCanvasLayer_windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:pvVar2_2];
    }
    _isLayerStarted = YES;
}

- (void)dealloc
{
    [_currentCursor release];
    [super dealloc];
}

@end

