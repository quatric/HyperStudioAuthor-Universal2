#import "HSAnimationPathCanvasItem.h"
static id sDAT_003428b8;

static id sDAT_003428b8;


@implementation HSAnimationPathCanvasItem

/* i386 ivar offsets: _pathObject=0x4, _selectedSegments=0x8 */

+ (id)animationPathStrokeColor
{
    return [NSColor blackColor];
}

+ (void)setSelectedSegmentHighlightColor:(id)aColor
{
    if (sDAT_003428b8 != aColor) {
        [sDAT_003428b8 release];
        sDAT_003428b8 = [aColor retain];
    }
}

+ (id)selectedSegmentHighlightColor
{
    if (sDAT_003428b8 == nil) {
        sDAT_003428b8 = [[NSColor selectedControlColor] retain];
    }
    return sDAT_003428b8;
}

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a9891 @ 000a9891, 105 bytes * /

id FUN_000a9891(HSAnimationPathCanvasItem *self,SEL _cmd,id renderingRegionInCanvasLayer)

{
  undefined *self_00;
  id pvVar1;
  undefined8 local_1c;
  undefined8 local_14;
  
  self_00 = cls_HSRegion;
  _objc_msgSend_stret(&local_1c,self,sel_renderingBoundsInCanvasLayer_,renderingRegionInCanvasLayer)
  ;
  pvVar1 = _objc_msgSend(self_00,sel_regionWithRect_,local_1c,local_14);
  return pvVar1;
}

*/
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [HSRegion regionWithRect:[self renderingBoundsInCanvasLayer:aLayer]];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a98fa @ 000a98fa, 220 bytes * /

NSRect * FUN_000a98fa(NSRect *__return_storage_ptr__,HSAnimationPathCanvasItem *self,SEL _cmd,
                     id renderingBoundsInCanvasLayer)

{
  id self_00;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined8 local_1c;
  undefined8 local_14;
  
  local_2c = *(float *)PTR_00336078;
  local_28 = *(float *)(PTR_00336078 + 4);
  local_24 = *(float *)(PTR_00336078 + 8);
  local_20 = *(float *)(PTR_00336078 + 0xc);
  self_00 = _objc_msgSend(self,sel_bezierPathInCanvasLayer_,renderingBoundsInCanvasLayer);
  if (self_00 != (id)0x0) {
    _objc_msgSend_stret(&local_1c,self_00,sel_hyperVisualBounds);
    _NSInsetRect(&local_2c,local_1c,local_14,0xc0a00000,0xc0a00000);
  }
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = local_28;
  (__return_storage_ptr__->size).width = local_24;
  (__return_storage_ptr__->size).height = local_20;
  return __return_storage_ptr__;
}

*/
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    NSRect bounds = NSZeroRect;
    id path = [self bezierPathInCanvasLayer:aLayer];
    if (path != nil) {
        bounds = NSInsetRect([path hyperVisualBounds], -5.0, -5.0);
    }
    return bounds;
    return (NSRect){0};
}

- (BOOL)prefersRegionInvalidation
{
    return NO;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a957e @ 000a957e, 357 bytes * /

void FUN_000a957e(HSAnimationPathCanvasItem *self,SEL _cmd,NSRect renderRect,id inCanvasLayer,
                 BOOL isActive)

{
  id self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  self_00 = _objc_msgSend(self,sel_bezierPathInCanvasLayer_,inCanvasLayer);
  if ((self->_selectedSegments).length != 0) {
    pvVar2 = (id)(self->_selectedSegments).location;
    do {
      uVar3 = 2;
      inCanvasLayer = pvVar2;
      self_01 = _objc_msgSend(self_00,sel_hyperSubpathForElementRange_,pvVar2,2);
      if (self_01 != (id)0x0) {
        inCanvasLayer = (id)0x40c00000;
        _objc_msgSend(self_01,sel_setLineWidth_,0x40c00000,uVar3);
        _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
        pvVar1 = _objc_msgSend(self,sel_class);
        pvVar1 = _objc_msgSend(pvVar1,sel_selectedSegmentHighlightColor);
        _objc_msgSend(pvVar1,sel_set);
        _objc_msgSend(self_01,sel_stroke);
        _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
      }
      pvVar2 = (id)((int)pvVar2 + 1);
    } while ((int)pvVar2 - (self->_selectedSegments).location < (self->_selectedSegments).length);
  }
  pvVar2 = _objc_msgSend(self,sel_class,inCanvasLayer);
  pvVar2 = _objc_msgSend(pvVar2,sel_animationPathStrokeColor);
  _objc_msgSend(pvVar2,sel_set);
  _objc_msgSend(self_00,sel_stroke);
  return;
}

*/
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    id path = [self bezierPathInCanvasLayer:aLayer];
    if (_selectedSegments.length != 0) {
        NSUInteger index = _selectedSegments.location;
        do {
            id subpath = [path hyperSubpathForElementRange:NSMakeRange(index, 2)];
            if (subpath != nil) {
                [subpath setLineWidth:6.0];
                [NSGraphicsContext saveGraphicsState];
                [[[self class] selectedSegmentHighlightColor] set];
                [subpath stroke];
                [NSGraphicsContext restoreGraphicsState];
            }
            index++;
        } while (index - _selectedSegments.location < _selectedSegments.length);
    }
    [[[self class] animationPathStrokeColor] set];
    [path stroke];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a99d6 @ 000a99d6, 364 bytes * /

id FUN_000a99d6(HSAnimationPathCanvasItem *self,SEL _cmd,id bezierPathInCanvasLayer)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(bezierPathInCanvasLayer,sel_context);
  pvVar1 = _objc_msgSend(pvVar1,sel_renderingView);
  self_00 = cls_NSAffineTransform;
  if ((self->_pathObject == (id)0x0) || (pvVar1 == (id)0x0)) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_geometryAttributes);
    _objc_msgSend_stret(&local_2c,pvVar2,sel_affineTransform);
    pvVar2 = _objc_msgSend(self_00,sel_transformWithHyperCGAffineTransform_,local_2c,local_24,
                           local_1c);
    pvVar1 = _objc_msgSend(pvVar1,sel_userSpaceToViewSpaceTransform);
    _objc_msgSend(pvVar2,sel_appendTransform_,pvVar1);
    pvVar1 = _objc_msgSend(self,sel_vectorGraphicsAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperBezierPath);
    pvVar1 = _objc_msgSend(pvVar1,sel_copy);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    _objc_msgSend(pvVar1,sel_setLineWidth_,0x40000000);
    _objc_msgSend(pvVar1,sel_transformUsingAffineTransform_,pvVar2);
  }
  return pvVar1;
}

*/
- (id)bezierPathInCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    if (_pathObject == nil || view == nil) {
        return nil;
    }
    NSAffineTransform *transform = [NSAffineTransform transformWithHyperCGAffineTransform:[[self geometryAttributes] affineTransform]];
    [transform appendTransform:[view userSpaceToViewSpaceTransform]];
    NSBezierPath *path = [[[[self vectorGraphicsAttributes] hyperBezierPath] copy] autorelease];
    [path setLineWidth:2.0];
    [path transformUsingAffineTransform:transform];
    return path;
    return 0;
}

- (void)animationPathDidChange:(id)aChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGenericCanvasItemDidChangeNotification" object:self];
}

- (void)animationPathWillChange:(id)aChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGenericCanvasItemWillChangeNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a92c6 @ 000a92c6, 540 bytes * /

void FUN_000a92c6(HSAnimationPathCanvasItem *self,SEL _cmd,id setPathObject)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  HSAnimationPathCanvasItem *pHVar3;
  
  if (self->_pathObject != setPathObject) {
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pcVar2 = &cfstr_HSGenericCanvasItemWillChangeNotification;
    pHVar3 = self;
    _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                  &cfstr_HSGenericCanvasItemWillChangeNotification,self);
    pvVar1 = _objc_msgSend(self,sel_vectorGraphicsAttributes);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController,pcVar2,pHVar3);
      _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_animationPathWillChange_,*(undefined4 *)PTR_00336020,&DAT_00369a08);
      pcVar2 = (cfstringStruct *)self;
      pHVar3 = (HSAnimationPathCanvasItem *)sel_animationPathDidChange_;
      _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_animationPathDidChange_,*(undefined4 *)PTR_0033601c,&DAT_00369a08);
    }
    _objc_msgSend(self->_pathObject,sel_release,pcVar2,pHVar3);
    pvVar1 = _objc_msgSend(setPathObject,sel_retain);
    self->_pathObject = pvVar1;
    pvVar1 = _objc_msgSend(self,sel_vectorGraphicsAttributes);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
      _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                    sel_animationPathWillChange_,*(undefined4 *)PTR_00336020,&DAT_00369a08,
                    0xbe800000);
      pcVar2 = (cfstringStruct *)self;
      pHVar3 = (HSAnimationPathCanvasItem *)sel_animationPathDidChange_;
      _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                    sel_animationPathDidChange_,*(undefined4 *)PTR_0033601c,&DAT_00369a08,0xbe800000
                   );
    }
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pcVar2,pHVar3);
    _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                  &cfstr_HSGenericCanvasItemDidChangeNotification,self);
  }
  return;
}

*/
- (void)setPathObject:(id)aObject
{
    if (_pathObject != aObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGenericCanvasItemWillChangeNotification" object:self];
        id vectorGraphics = [self vectorGraphicsAttributes];
        if (vectorGraphics != nil) {
            id controller = [vectorGraphics attributeObservingController];
            [controller removeObserver:self selector:@selector(animationPathWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
            [controller removeObserver:self selector:@selector(animationPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
        }
        [_pathObject release];
        _pathObject = [aObject retain];
        vectorGraphics = [self vectorGraphicsAttributes];
        if (vectorGraphics != nil) {
            id controller = [vectorGraphics attributeObservingController];
            [controller addObserver:self selector:@selector(animationPathWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
            [controller addObserver:self selector:@selector(animationPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGenericCanvasItemDidChangeNotification" object:self];
    }
}

- (id)pathObject
{
    return _pathObject;
}

- (void)setSelectedSegments:(NSRange)aSegments
{
    if (((_selectedSegments).location != aSegments.location) || ((_selectedSegments).length != aSegments.length)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGenericCanvasItemWillChangeNotification" object:self];
        (_selectedSegments).location = aSegments.location;
        (_selectedSegments).length = aSegments.length;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGenericCanvasItemDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a9185 @ 000a9185, 14 bytes * /

ulonglong FUN_000a9185(HSAnimationPathCanvasItem *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_selectedSegments).location;
  uVar1._4_4_ = (self->_selectedSegments).length;
  return uVar1;
}

*/
- (NSRange)selectedSegments
{
    return _selectedSegments;
    return (NSRange){0};
}

- (id)queryHyperInterface:(id)aInterface
{
    id pvVar1;

    pvVar1 = [super queryHyperInterface:aInterface];
    if (pvVar1 == nil) {
        pvVar1 = [_pathObject queryHyperInterface:aInterface];
    }
    return pvVar1;
}

- (id)geometryAttributes
{
    return [_pathObject queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)vectorGraphicsAttributes
{
    return [_pathObject queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
}

- (void)dealloc
{
    id pvVar1_2;

    pvVar1_2 = [[self vectorGraphicsAttributes] attributeObservingController];
    [pvVar1_2 removeObserver:self selector:@selector(animationPathWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
    [pvVar1_2 removeObserver:self selector:@selector(animationPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
    [_pathObject release];
    [super dealloc];
}

@end

