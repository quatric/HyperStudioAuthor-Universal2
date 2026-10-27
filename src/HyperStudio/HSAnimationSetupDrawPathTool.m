#import "HSAnimationSetupDrawPathTool.h"

@implementation HSAnimationSetupDrawPathTool

/* i386 ivar offsets: _delegate=0x10, _drawPathCanvasLayer=0x14, _drawPathCanvasItem=0x18, _path=0x1c, _keyFrames=0x20, _lastPoint=0x24, _lastEventTime=0x2c, _needsAddAnimatedObject=0x34 */

- (id)layerForEditPathCanvasItem:(id)aItem
{
    return _drawPathCanvasLayer;
}

- (id)pathForEditPathCanvasItem:(id)aItem
{
    return _path;
}

- (void)cleanUpPathAndKeyFrames
{
    [_path release];
    _path = nil;
    [_keyFrames release];
    _keyFrames = nil;
}

- (BOOL)didStartPath
{
    return _path != nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ca4c6 @ 000ca4c6, 88 bytes * /

void FUN_000ca4c6(HSAnimationSetupDrawPathTool *self,SEL _cmd,id drawPathCanvasLayer,
                 NSPoint mouseMovedToPoint)

{
  SEL op;
  
  op = sel_addAnimatedObject;
  if (self->_needsAddAnimatedObject == '\0') {
    self = self->_delegate;
    op = sel_drawPathTool_setAnimatedObjectPosition_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)drawPathCanvasLayer:(id)aLayer mouseMovedToPoint:(NSPoint)aPoint
{
    if (_needsAddAnimatedObject) {
        [self addAnimatedObject];
    } else {
        [_delegate drawPathTool:self setAnimatedObjectPosition:aPoint];
    }
}

- (void)cancelPathCreationForDrawPathCanvasLayer:(id)aLayer
{
    [self cleanUpPathAndKeyFrames];
    [self removeAnimatedObject];
    [_delegate drawingCanceledForDrawPathTool:self];
}

- (void)finishPathCreationForDrawPathCanvasLayer:(id)aLayer
{
    if ([self didStartPath]) {
        [[_delegate animationForDrawPathTool:self] setPath:_path keyFrames:_keyFrames];
        [self cleanUpPathAndKeyFrames];
        [self removeAnimatedObject];
        [_delegate drawingFinishedForDrawPathTool:self];
    }
}

- (void)drawPathCanvasLayer:(id)aLayer continuePathAtPoint:(NSPoint)aPoint
{
    [self HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:aPoint lastKeyFrame:NULL continuePath:YES];
    [_delegate drawPathTool:self setAnimatedObjectPosition:aPoint];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ca2a5 @ 000ca2a5, 167 bytes * /

void FUN_000ca2a5(HSAnimationSetupDrawPathTool *self,SEL _cmd,id drawPathCanvasLayer,
                 NSPoint finishPathPartAtPoint)

{
  float fVar1;
  
  fVar1 = (self->_lastPoint).x;
  if ((((finishPathPartAtPoint.x < fVar1 + -0.5) || (fVar1 + 0.5 < finishPathPartAtPoint.x)) ||
      (fVar1 = (self->_lastPoint).y, finishPathPartAtPoint.y < fVar1 + -0.5)) ||
     (fVar1 + 0.5 < finishPathPartAtPoint.y)) {
    _objc_msgSend(self,sel_HSAnimationSetupDrawPathTool_addPointToPath_lastKeyFrame_,
                  finishPathPartAtPoint.x,finishPathPartAtPoint.y,0);
  }
  _objc_msgSend(self->_delegate,sel_pathStateIsUpdatedForDrawPathTool_,self);
  return;
}

*/
- (void)drawPathCanvasLayer:(id)aLayer finishPathPartAtPoint:(NSPoint)aPoint
{
    if (aPoint.x < _lastPoint.x - 0.5f || _lastPoint.x + 0.5f < aPoint.x || aPoint.y < _lastPoint.y - 0.5f || _lastPoint.y + 0.5f < aPoint.y) {
        [self HSAnimationSetupDrawPathTool_addPointToPath:aPoint lastKeyFrame:NULL];
    }
    [_delegate pathStateIsUpdatedForDrawPathTool:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ca635 @ 000ca635, 189 bytes * /

void FUN_000ca635(HSAnimationSetupDrawPathTool *self,SEL _cmd,id drawPathCanvasLayer,
                 NSPoint addPointToPath)

{
  id self_00;
  double local_14;
  
  self_00 = _objc_msgSend(self->_keyFrames,sel_lastObject);
  local_14 = _objc_msgSend_fpret(self_00,sel_doubleValue);
  _objc_msgSend(self,sel_HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough_lastKeyFrame_,
                addPointToPath.x,addPointToPath.y,&local_14);
  _objc_msgSend(self->_delegate,sel_drawPathTool_setAnimatedObjectPosition_,self,addPointToPath.x,
                addPointToPath.y);
  _objc_msgSend(self,sel_HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration_,
                local_14);
  return;
}

*/
- (void)drawPathCanvasLayer:(id)aLayer addPointToPath:(NSPoint)aPath
{
    double lastKeyFrame = [[_keyFrames lastObject] doubleValue];
    [self HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:aPath lastKeyFrame:&lastKeyFrame];
    [_delegate drawPathTool:self setAnimatedObjectPosition:aPath];
    [self HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration:lastKeyFrame];
}

- (void)HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:(NSPoint)aEnough lastKeyFrame:(double *)aFrame
{
    [self HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:aEnough lastKeyFrame:aFrame continuePath:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ca6f2 @ 000ca6f2, 210 bytes * /

void FUN_000ca6f2(HSAnimationSetupDrawPathTool *self,SEL _cmd,
                 NSPoint HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough,
                 double *lastKeyFrame,BOOL continuePath)

{
  longdouble lVar1;
  double dVar2;
  
  dVar2 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
  dVar2 = dVar2 - self->_lastEventTime;
  lVar1 = (longdouble)
          _hypotf(HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough.x -
                  (self->_lastPoint).x,
                  HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough.y -
                  (self->_lastPoint).y);
  if ((0.5 <= dVar2) || (20.0 <= (float)lVar1)) {
    _objc_msgSend(self,sel_HSAnimationSetupDrawPathTool_addPointToPath_lastKeyFrame_continuePath_,
                  HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough.x,
                  HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough.y,lastKeyFrame,
                  (int)continuePath);
  }
  else if (lastKeyFrame != (double *)0x0) {
    *lastKeyFrame = dVar2 + *lastKeyFrame;
  }
  return;
}

*/
- (void)HSAnimationSetupDrawPathTool_addPointToPathIfDiffersEnough:(NSPoint)aEnough lastKeyFrame:(double *)aFrame continuePath:(BOOL)aPath
{
    double elapsed = [NSDate timeIntervalSinceReferenceDate] - _lastEventTime;
    float distance = hypotf(aEnough.x - _lastPoint.x, aEnough.y - _lastPoint.y);
    if (elapsed >= 0.5 || distance >= 20.0f) {
        [self HSAnimationSetupDrawPathTool_addPointToPath:aEnough lastKeyFrame:aFrame continuePath:aPath];
    } else if (aFrame != NULL) {
        *aFrame = elapsed + *aFrame;
    }
}

- (void)HSAnimationSetupDrawPathTool_addPointToPath:(NSPoint)aPath lastKeyFrame:(double *)aFrame
{
    [self HSAnimationSetupDrawPathTool_addPointToPath:aPath lastKeyFrame:aFrame continuePath:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ca7c4 @ 000ca7c4, 827 bytes * /

void FUN_000ca7c4(HSAnimationSetupDrawPathTool *self,SEL _cmd,
                 NSPoint HSAnimationSetupDrawPathTool_addPointToPath,double *lastKeyFrame,
                 BOOL continuePath)

{
  float fVar1;
  float fVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  float extraout_EDX;
  float extraout_EDX_00;
  double dVar7;
  double dVar8;
  double dVar9;
  float fVar10;
  float fVar11;
  undefined4 uVar12;
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  id local_2c;
  undefined4 uStack_28;
  float local_24;
  float fStack_20;
  double local_1c;
  
  fVar10 = HSAnimationSetupDrawPathTool_addPointToPath.x;
  fVar11 = HSAnimationSetupDrawPathTool_addPointToPath.y;
  _objc_msgSend(self->_path,sel_lineToPoint_,HSAnimationSetupDrawPathTool_addPointToPath.x,
                HSAnimationSetupDrawPathTool_addPointToPath.y);
  fVar1 = (self->_lastPoint).x;
  fVar2 = (self->_lastPoint).y;
  (self->_lastPoint).x = HSAnimationSetupDrawPathTool_addPointToPath.x;
  (self->_lastPoint).y = HSAnimationSetupDrawPathTool_addPointToPath.y;
  puVar3 = PTR_003361e4;
  dVar7 = self->_lastEventTime + *(double *)PTR_003361e4;
  local_1c = dVar7;
  dVar9 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
  if (dVar7 <= dVar9) {
    dVar7 = dVar9;
  }
  if (lastKeyFrame == (double *)0x0) {
    pvVar6 = _objc_msgSend(self->_keyFrames,sel_lastObject,fVar10,fVar11);
    dVar9 = _objc_msgSend_fpret(pvVar6,sel_doubleValue);
    lastKeyFrame = &local_1c;
    local_1c = dVar9;
  }
  else {
    dVar9 = *lastKeyFrame;
  }
  if (continuePath == '\0') {
    dVar8 = dVar7 - self->_lastEventTime;
  }
  else {
    dVar8 = *(double *)puVar3;
  }
  dVar9 = dVar9 + dVar8;
  *lastKeyFrame = dVar9;
  pvVar6 = self->_keyFrames;
  uVar12 = (undefined4)((ulonglong)dVar9 >> 0x20);
  pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,SUB84(dVar9,0),uVar12);
  _objc_msgSend(pvVar6,sel_addObject_,pvVar4);
  self->_lastEventTime = dVar7;
  if ((((HSAnimationSetupDrawPathTool_addPointToPath.x < fVar1 + -0.5) ||
       (fVar1 + 0.5 < HSAnimationSetupDrawPathTool_addPointToPath.x)) ||
      (HSAnimationSetupDrawPathTool_addPointToPath.y < fVar2 + -0.5)) ||
     (fVar2 + 0.5 < HSAnimationSetupDrawPathTool_addPointToPath.y)) {
    pvVar4 = _objc_msgSend(self,sel_view,pvVar4,uVar12);
    pvVar5 = _objc_msgSend(pvVar4,sel_userSpaceToViewSpaceTransform);
    pvVar6 = _objc_msgSend(pvVar5,sel_transformPoint_,fVar1,fVar2);
    pvVar5 = _objc_msgSend(pvVar5,sel_transformPoint_,HSAnimationSetupDrawPathTool_addPointToPath.x,
                           HSAnimationSetupDrawPathTool_addPointToPath.y);
    local_2c = pvVar5;
    if ((float)pvVar6 <= (float)pvVar5) {
      local_2c = pvVar6;
      pvVar6 = pvVar5;
    }
    dVar7 = _objc_msgSend_fpret(self->_path,sel_lineWidth);
    local_24 = (float)pvVar6 - (float)local_2c;
    fVar1 = extraout_EDX_00;
    fStack_20 = extraout_EDX;
    if (extraout_EDX <= extraout_EDX_00) {
      fVar1 = extraout_EDX;
      fStack_20 = extraout_EDX_00;
    }
    fStack_20 = fStack_20 - fVar1;
    _CGRectInset(&local_3c,local_2c,fVar1,local_24,fStack_20,(float)dVar7 * -0.5,(float)dVar7 * -0.5
                );
    local_2c = (id)local_3c;
    uStack_28 = local_38;
    local_24 = (float)local_34;
    fStack_20 = (float)local_30;
    _objc_msgSend(pvVar4,sel_setNeedsDisplayOpenGLSurfaceInRect_,local_3c,local_38,local_34,local_30
                 );
  }
  return;
}

*/
- (void)HSAnimationSetupDrawPathTool_addPointToPath:(NSPoint)aPath lastKeyFrame:(double *)aFrame continuePath:(BOOL)aPath2
{
    [_path lineToPoint:aPath];
    NSPoint previous = _lastPoint;
    _lastPoint = aPath;
    double minInterval = kAnimationMinTimeIntervalBetweenKeyFrames;
    double eventTime = _lastEventTime + minInterval;
    double now = [NSDate timeIntervalSinceReferenceDate];
    if (eventTime <= now) {
        eventTime = now;
    }
    double ownKeyFrame;
    double keyFrame;
    if (aFrame == NULL) {
        ownKeyFrame = [[_keyFrames lastObject] doubleValue];
        aFrame = &ownKeyFrame;
        keyFrame = ownKeyFrame;
    } else {
        keyFrame = *aFrame;
    }
    keyFrame += aPath2 ? minInterval : eventTime - _lastEventTime;
    *aFrame = keyFrame;
    [_keyFrames addObject:[NSNumber numberWithDouble:keyFrame]];
    _lastEventTime = eventTime;
    if (aPath.x < previous.x - 0.5f || previous.x + 0.5f < aPath.x || aPath.y < previous.y - 0.5f || previous.y + 0.5f < aPath.y) {
        id view = [self view];
        id transform = [view userSpaceToViewSpaceTransform];
        NSPoint from = [transform transformPoint:previous];
        NSPoint to = [transform transformPoint:aPath];
        float minX = MIN(from.x, to.x);
        float maxX = MAX(from.x, to.x);
        float minY = MIN(from.y, to.y);
        float maxY = MAX(from.y, to.y);
        float lineWidth = [_path lineWidth];
        CGRect rect = CGRectInset(CGRectMake(minX, minY, maxX - minX, maxY - minY), lineWidth * -0.5f, lineWidth * -0.5f);
        [view setNeedsDisplayOpenGLSurfaceInRect:NSRectFromCGRect(rect)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000caaff @ 000caaff, 338 bytes * /

void FUN_000caaff(HSAnimationSetupDrawPathTool *self,SEL _cmd,id drawPathCanvasLayer,
                 NSPoint startPathCreationAtPoint)

{
  undefined *self_00;
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_hyperBezierPathWithString_,&cfstr_M_0_0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_path = pvVar1;
  _objc_msgSend(pvVar1,sel_moveToPoint_,startPathCreationAtPoint.x,startPathCreationAtPoint.y);
  (self->_lastPoint).x = startPathCreationAtPoint.x;
  (self->_lastPoint).y = startPathCreationAtPoint.y;
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,0,0);
  pvVar1 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_keyFrames = pvVar1;
  dVar2 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
  self->_lastEventTime = dVar2;
  _objc_msgSend(self->_delegate,sel_drawPathTool_setAnimatedObjectPosition_,self,
                startPathCreationAtPoint.x,startPathCreationAtPoint.y);
  _objc_msgSend(self,sel_HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration_,0
                ,0);
  return;
}

*/
- (void)drawPathCanvasLayer:(id)aLayer startPathCreationAtPoint:(NSPoint)aPoint
{
    _path = [[NSBezierPath hyperBezierPathWithString:@"M 0 0"] retain];
    [_path moveToPoint:aPoint];
    _lastPoint = aPoint;
    _keyFrames = [[NSMutableArray arrayWithObject:[NSNumber numberWithDouble:0.0]] retain];
    _lastEventTime = [NSDate timeIntervalSinceReferenceDate];
    [_delegate drawPathTool:self setAnimatedObjectPosition:aPoint];
    [self HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration:0.0];
}

- (BOOL)didStartPathForDrawPathCanvasLayer:(id)aLayer
{
    return (BOOL)[self didStartPath];
}

- (NSInteger)pathCreationMode
{
    return (int)[[self drawPathCanvasLayer] pathCreationMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cac51 @ 000cac51, 360 bytes * /

void FUN_000cac51(HSAnimationSetupDrawPathTool *self,SEL _cmd,
                 double HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration)

{
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  double dVar4;
  undefined4 uVar6;
  undefined8 uVar5;
  undefined1 local_34 [8];
  undefined8 local_2c;
  double local_24 [2];
  
  pvVar1 = _objc_msgSend(self->_delegate,sel_animationForDrawPathTool_,self);
  pvVar2 = _objc_msgSend(pvVar1,sel_playMovie);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(pvVar1,sel_animatedObject,self);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036be20);
    _objc_msgSend_stret(local_34,pvVar2,sel_hyperPlayRange);
    _objc_msgSend_stret(local_24,pvVar2,sel_hyperPlayRange);
    dVar4 = _objc_msgSend_fpret(pvVar1,sel_movieRelativeSpeed);
    lVar3 = (longdouble)
            _fmod(HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration * dVar4,
                  local_2c);
    dVar4 = local_24[0] + (double)lVar3;
    _objc_msgSend(pvVar2,sel_setHyperCurrentTime_,dVar4);
    uVar6 = (undefined4)((ulonglong)dVar4 >> 0x20);
    pvVar1 = _objc_msgSend(pvVar1,sel_animatedObject);
    uVar5 = CONCAT44(uVar6,&DAT_0036befc);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036befc);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar1,sel_resetHyperFrameCount,uVar5);
    }
  }
  return;
}

*/
- (void)HSAnimationSetupDrawPathTool_updateMovieIfNecessaryWithAnimationDuration:(double)aDuration
{
    id animation = [_delegate animationForDrawPathTool:self];
    if ([animation playMovie]) {
        id playable = [[animation animatedObject] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
        struct HSTimeRange range = [playable hyperPlayRange];
        double offset = fmod(aDuration * [animation movieRelativeSpeed], range.length);
        [playable setHyperCurrentTime:[playable hyperPlayRange].location + offset];
        id movie = [[animation animatedObject] queryHyperInterface:@protocol(HSMovieObjectAttributes)];
        if (movie != nil) {
            [movie resetHyperFrameCount];
        }
    }
}

- (void)removeAnimatedObject
{
    [_delegate removeAnimatedObjectFromCardForDrawPathTool:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cadb9 @ 000cadb9, 420 bytes * /

void FUN_000cadb9(HSAnimationSetupDrawPathTool *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  uint extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined4 extraout_EDX_02;
  ulonglong uVar5;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar2 = _objc_msgSend(self,sel_drawPathCanvasLayer);
  pvVar2 = _objc_msgSend(pvVar2,sel_renderingView);
  pvVar3 = _objc_msgSend(pvVar2,sel_window);
  pvVar3 = _objc_msgSend(pvVar3,sel_mouseLocationOutsideOfEventStream);
  self_00 = _objc_msgSend(pvVar2,sel_enclosingScrollView);
  uVar5 = (ulonglong)extraout_EDX;
  pvVar4 = _objc_msgSend(self_00,sel_convertPoint_fromView_);
  _objc_msgSend_stret(&local_24,self_00,sel_bounds,uVar5);
  cVar1 = _NSPointInRect(pvVar4,extraout_EDX_00,local_24,local_1c);
  if (cVar1 == '\0') {
    self->_needsAddAnimatedObject = '\x01';
  }
  else {
    self->_needsAddAnimatedObject = '\0';
    _objc_msgSend(self->_delegate,sel_addAnimatedObjectToCardForDrawPathTool_,self);
    pvVar3 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_convertPointFromViewSpaceToUserSpace_,pvVar3,extraout_EDX_01);
    _objc_msgSend(self->_delegate,sel_drawPathTool_setAnimatedObjectPosition_,self,pvVar2,
                  extraout_EDX_02);
  }
  return;
}

*/
- (void)addAnimatedObject
{
    id view = [[self drawPathCanvasLayer] renderingView];
    NSPoint mouse = [[view window] mouseLocationOutsideOfEventStream];
    NSScrollView *scrollView = [view enclosingScrollView];
    NSPoint inScrollView = [scrollView convertPoint:mouse fromView:nil];
    if (!NSPointInRect(inScrollView, [scrollView bounds])) {
        _needsAddAnimatedObject = YES;
    } else {
        _needsAddAnimatedObject = NO;
        [_delegate addAnimatedObjectToCardForDrawPathTool:self];
        NSPoint viewPoint = [view convertPoint:mouse fromView:nil];
        [_delegate drawPathTool:self setAnimatedObjectPosition:[view convertPointFromViewSpaceToUserSpace:viewPoint]];
    }
}

- (void)run
{
    [self performSelectorOnMainThread:@selector(addAnimatedObject) withObject:self waitUntilDone:NO];
}

- (id)drawPathCanvasItem
{
    HSAnimationSetupDrawPathCanvasItem *pHVar1;
    HSAnimationSetupDrawPathCanvasItem *pHVar1_2;

    pHVar1 = _drawPathCanvasItem;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSAnimationSetupDrawPathCanvasItem alloc] init];
        _drawPathCanvasItem = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _drawPathCanvasItem;
    }
    return pHVar1;
}

- (id)drawPathCanvasLayer
{
    HSDrawPathCanvasLayer *pHVar2;
    HSDrawPathCanvasLayer *pHVar2_2;

    pHVar2 = _drawPathCanvasLayer;
    if (pHVar2 == nil) {
        pHVar2_2 = [[HSDrawPathCanvasLayer alloc] initWithPathCreationMode:(unsigned int)([[[NSUserDefaults standardUserDefaults] objectForKey:HSTurnAdvancedAnimationModeKey] boolValue])];
        _drawPathCanvasLayer = pHVar2_2;
        [pHVar2_2 setOwner:self];
        pHVar2 = _drawPathCanvasLayer;
    }
    return pHVar2;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeAllSublayers];
    [pvVar1_2 setEnabledSublayerIdentifiers:nil];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_3;
    id pvVar2_3;

    pvVar1_3 = [[[HSGenericItemsCanvasSublayer alloc] init] autorelease];
    [pvVar1_3 addCanvasItem:[self drawPathCanvasItem]];
    pvVar2_3 = [[self view] rootCanvasLayer];
    [[pvVar2_3 vectorToolsCanvasLayer] addSublayer:pvVar1_3];
    [[pvVar2_3 vectorToolsCanvasLayer] addSublayer:[self drawPathCanvasLayer]];
    [pvVar2_3 setEnabledSublayerIdentifiers:[pvVar2_3 vectorToolsIdentifiers]];
    [super didActivateExplicitly:aExplicitly];
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)shouldResetToolOnAddObjects
{
    return NO;
}

- (void)dealloc
{
    [_keyFrames release];
    [_path release];
    [_drawPathCanvasLayer setOwner:nil];
    [_drawPathCanvasLayer release];
    [_drawPathCanvasItem setDelegate:0];
    [_drawPathCanvasItem release];
    [super dealloc];
}

- (BOOL)shouldResetToolOnSelectObjects
{
    return NO;
}

@end

