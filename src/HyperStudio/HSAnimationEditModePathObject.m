#import "HSAnimationEditModePathObject.h"

@implementation HSAnimationEditModePathObject

/* i386 ivar offsets: _vectorGraphics=0x4, _transform=0x8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa99f @ 000aa99f, 141 bytes * /

id FUN_000aa99f(HSAnimationEditModePathObject *self,SEL _cmd,NSZone *copyWithZone)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(pvVar1,sel_allocWithZone_,copyWithZone);
  pvVar1 = _objc_msgSend(pvVar1,sel_init);
  _objc_msgSend(pvVar1,sel_setVectorGraphics_,self->_vectorGraphics);
  _objc_msgSend(pvVar1,sel_setTransform_,self->_transform);
  return pvVar1;
}

*/
- (id)copyWithZone:(NSZone *)aZone
{
    id copy = [[[self class] allocWithZone:aZone] init];
    [copy setVectorGraphics:_vectorGraphics];
    [copy setTransform:_transform];
    return copy;
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfoInvocation:(id)aInvocation
{
    [[self attributeNotificationCenter] notifyChange:aChange ofAttribute:aAttribute ofObject:self withUserInfoInvocation:aInvocation];
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    [[self attributeNotificationCenter] notifyChange:aChange ofAttribute:aAttribute ofObject:self withUserInfo:aInfo];
}

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:nil ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

- (void)setHyperFlippedVertical:(BOOL)aVertical
{

}

- (void)setHyperFlippedHorizontal:(BOOL)aHorizontal
{

}

- (void)hyperFlipVertical
{

}

- (void)hyperFlipHorizontal
{

}

- (void)setHyperScaleFactor:(NSSize)aFactor
{

}

- (void)setHyperRotationAngle:(CGFloat)aAngle
{

}

- (void)hyperScaleBy:(NSSize)aBy aboutPoint:(NSPoint)aPoint assumeAsOriginalSize:(NSSize)aSize affineTransform:(id)aTransform
{

}

- (void)hyperResizeToSize:(NSSize)aSize aboutPoint:(NSPoint)aPoint assumeAsOriginalSize:(NSSize)aSize2 affineTransform:(id)aTransform
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa8b3 @ 000aa8b3, 11 bytes * /

ulonglong FUN_000aa8b3(HSAnimationEditModePathObject *self,SEL _cmd,NSSize constrainHyperSize)

{
  return (ulonglong)constrainHyperSize;
}

*/
- (NSSize)constrainHyperSize:(NSSize)aSize
{
    return aSize;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa8a8 @ 000aa8a8, 11 bytes * /

ulonglong FUN_000aa8a8(HSAnimationEditModePathObject *self,SEL _cmd,NSPoint constrainHyperOrigin)

{
  return (ulonglong)constrainHyperOrigin;
}

*/
- (NSPoint)constrainHyperOrigin:(NSPoint)aOrigin
{
    return aOrigin;
}

- (void)setHyperOriginY:(CGFloat)aY
{

}

- (void)setHyperOriginX:(CGFloat)aX
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab141 @ 000ab141, 101 bytes * /

void FUN_000ab141(HSAnimationEditModePathObject *self,SEL _cmd,NSPoint setHyperOrigin)

{
  id pvVar1;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_hyperOrigin);
  _objc_msgSend(self->_transform,sel_hyperPosttranslateBy_,setHyperOrigin.x - (float)pvVar1,
                setHyperOrigin.y - extraout_EDX);
  return;
}

*/
- (void)setHyperOrigin:(NSPoint)aOrigin
{
    NSPoint origin = [self hyperOrigin];
    [_transform hyperPosttranslateBy:NSMakeSize(aOrigin.x - origin.x, aOrigin.y - origin.y)];
}

- (id)constrainHyperAffineTransform:(id)aTransform
{
    return aTransform;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa88b @ 000aa88b, 11 bytes * /

ulonglong FUN_000aa88b(HSAnimationEditModePathObject *self,SEL _cmd,NSSize constrainHyperSize,
                      NSSize assumeAsOriginal)

{
  return (ulonglong)constrainHyperSize;
}

*/
- (NSSize)constrainHyperSize:(NSSize)aSize assumeAsOriginal:(NSSize)aOriginal
{
    return aSize;
}

- (BOOL)prefersHyperResizingToScaling
{
    return YES;
}

- (void)setHyperPrefersProportionalResizingScaling:(BOOL)aScaling
{

}

- (void)setHyperAffineTransform:(id)aTransform
{

}

- (void)setHyperFrameHeight:(CGFloat)aHeight
{

}

- (void)setHyperFrameWidth:(CGFloat)aWidth
{

}

- (void)setHyperSize:(NSSize)aSize
{

}

- (void)hyperResetToDefaultSizeAboutPoint:(NSPoint)aPoint
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa854 @ 000aa854, 15 bytes * /

ulonglong FUN_000aa854(HSAnimationEditModePathObject *self,SEL _cmd)

{
  return 0x3f0000003f000000;
}

*/
- (NSSize)hyperRotationCenterToSidesRatio
{
    return NSMakeSize(0.5f, 0.5f);
}

- (BOOL)canHyperSkew
{
    return NO;
}

- (BOOL)canHyperRotate
{
    return NO;
}

- (BOOL)canHyperScaleVertical
{
    return NO;
}

- (BOOL)canHyperScaleHorizontal
{
    return NO;
}

- (BOOL)canHyperMove
{
    return NO;
}

- (BOOL)canHyperResizeVertical
{
    return YES;
}

- (BOOL)canHyperResizeHorizontal
{
    return YES;
}

- (NSSize)hyperDefaultSize
{
    return [self hyperSize];
}

- (NSSize)hyperScale
{
    return [_transform hyperScaleFactor];
}

- (BOOL)hyperPrefersProportionalResizingScaling
{
    return NO;
}

- (BOOL)isHyperFlippedVertical
{
    return NO;
}

- (BOOL)isHyperFlippedHorizontal
{
    return NO;
}

- (CGFloat)hyperRotationAngle
{
    return 0.0;
}

- (id)copiedHyperAffineTransform
{
    return [[_transform copy] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab232 @ 000ab232, 115 bytes * /

CGAffineTransform *
FUN_000ab232(CGAffineTransform *__return_storage_ptr__,HSAnimationEditModePathObject *self,SEL _cmd)

{
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  float local_c;
  float local_8;
  
  _objc_msgSend_stret(&local_1c,self->_transform,sel_transformStruct);
  __return_storage_ptr__->a = local_1c;
  __return_storage_ptr__->b = local_18;
  __return_storage_ptr__->c = local_14;
  __return_storage_ptr__->d = local_10;
  __return_storage_ptr__->tx = local_c;
  __return_storage_ptr__->ty = local_8;
  return __return_storage_ptr__;
}

*/
- (CGAffineTransform)affineTransform
{
    NSAffineTransformStruct s = [_transform transformStruct];
    return CGAffineTransformMake(s.m11, s.m12, s.m21, s.m22, s.tX, s.tY);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab2a5 @ 000ab2a5, 50 bytes * /

float FUN_000ab2a5(HSAnimationEditModePathObject *self,SEL _cmd)

{
  float extraout_EDX;
  
  _objc_msgSend(self,sel_hyperFrameSize);
  return extraout_EDX;
}

*/
- (CGFloat)hyperFrameHeight
{
    return [self hyperFrameSize].height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab2d7 @ 000ab2d7, 50 bytes * /

float FUN_000ab2d7(HSAnimationEditModePathObject *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_hyperFrameSize);
  return (float)pvVar1;
}

*/
- (CGFloat)hyperFrameWidth
{
    return [self hyperFrameSize].width;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab309 @ 000ab309, 105 bytes * /

ulonglong FUN_000ab309(HSAnimationEditModePathObject *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(self,sel_hyperSize);
  pvVar2 = _objc_msgSend(self->_transform,sel_hyperScaleFactor);
  return CONCAT44(extraout_EDX_00 * extraout_EDX,(float)pvVar2 * (float)pvVar1);
}

*/
- (NSSize)hyperFrameSize
{
    NSSize size = [self hyperSize];
    NSSize scale = [_transform hyperScaleFactor];
    return NSMakeSize(scale.width * size.width, scale.height * size.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab372 @ 000ab372, 50 bytes * /

float FUN_000ab372(HSAnimationEditModePathObject *self,SEL _cmd)

{
  float extraout_EDX;
  
  _objc_msgSend(self,sel_hyperOrigin);
  return extraout_EDX;
}

*/
- (CGFloat)hyperOriginY
{
    return [self hyperOrigin].y;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab3a4 @ 000ab3a4, 50 bytes * /

float FUN_000ab3a4(HSAnimationEditModePathObject *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_hyperOrigin);
  return (float)pvVar1;
}

*/
- (CGFloat)hyperOriginX
{
    return [self hyperOrigin].x;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab3d6 @ 000ab3d6, 54 bytes * /

ulonglong FUN_000ab3d6(HSAnimationEditModePathObject *self,SEL _cmd)

{
  ulonglong local_14 [2];
  
  _objc_msgSend_stret(local_14,self,sel_hyperBoundingRect);
  return local_14[0];
}

*/
- (NSPoint)hyperOrigin
{
    return [self hyperBoundingRect].origin;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab40c @ 000ab40c, 145 bytes * /

NSRect * FUN_000ab40c(NSRect *__return_storage_ptr__,HSAnimationEditModePathObject *self,SEL _cmd)

{
  undefined8 uVar1;
  id pvVar2;
  NSRect *extraout_EAX;
  undefined4 extraout_EDX;
  
  uVar1 = *(undefined8 *)PTR_00336074;
  pvVar2 = _objc_msgSend(self,sel_hyperSize);
  _objc_msgSend_stret(__return_storage_ptr__,self->_transform,sel_hyperTransformAndBoundRect_,uVar1,
                      CONCAT44(extraout_EDX,pvVar2));
  return extraout_EAX;
}

*/
- (NSRect)hyperBoundingRect
{
    NSRect rect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, [self hyperSize].width, [self hyperSize].height);
    return [_transform hyperTransformAndBoundRect:rect];
}

- (NSSize)hyperSize
{
    return [_vectorGraphics size];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab4c6 @ 000ab4c6, 419 bytes * /

id FUN_000ab4c6(HSAnimationEditModePathObject *self,SEL _cmd,id queryHyperInterface)

{
  undefined *puVar1;
  char cVar2;
  char *pcVar3;
  char *pcVar4;
  int iVar5;
  id pvVar6;
  id pvVar7;
  HSAnimationEditModePathObject *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_00336340;
  if (queryHyperInterface == &DAT_00369c38) {
LAB_000ab5be:
    pvVar6 = _objc_msgSend(cls_HSAnimationPathKnobsProvider,sel_alloc);
    pvVar6 = _objc_msgSend(pvVar6,sel_initWithHyperObject_,self);
    pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
  }
  else {
    if (*(double *)PTR_00336340 <= 677.0 && *(double *)PTR_00336340 != 677.0) {
      pcVar3 = _objc_msgSend(queryHyperInterface,sel_name);
    }
    else {
      pcVar3 = (char *)_protocol_getName(queryHyperInterface);
    }
    if (pcVar3 != (char *)0x0) {
      if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
        pcVar4 = _objc_msgSend(&DAT_00369c38,sel_name);
      }
      else {
        pcVar4 = (char *)_protocol_getName(&DAT_00369c38);
      }
      if ((pcVar4 != (char *)0x0) && (iVar5 = _strcmp(pcVar3,pcVar4), iVar5 == 0)) {
        if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
          pvVar6 = _objc_msgSend(queryHyperInterface,sel_isEqual_,&DAT_00369c38);
          cVar2 = (char)pvVar6;
        }
        else {
          cVar2 = _protocol_isEqual(queryHyperInterface,&DAT_00369c38);
        }
        if (cVar2 != '\0') goto LAB_000ab5be;
      }
    }
    local_1c = self;
    local_18 = PTR_s_NSObject_0034f3d0;
    pvVar6 = _objc_msgSendSuper(&local_1c,sel_queryHyperInterface_,queryHyperInterface);
    if ((pvVar6 == (id)0x0) &&
       (pvVar7 = _objc_msgSend(self->_vectorGraphics,sel_conformsToProtocol_,queryHyperInterface),
       (char)pvVar7 != '\0')) {
      pvVar6 = self->_vectorGraphics;
    }
  }
  return pvVar6;
}

*/
- (id)queryHyperInterface:(id)aInterface
{
    if (aInterface == @protocol(HSVectorGraphicsKnobsProvider) || protocol_isEqual(aInterface, @protocol(HSVectorGraphicsKnobsProvider))) {
        return [[[HSAnimationPathKnobsProvider alloc] initWithHyperObject:self] autorelease];
    }
    id result = [super queryHyperInterface:aInterface];
    if (result == nil && [_vectorGraphics conformsToProtocol:aInterface]) {
        result = _vectorGraphics;
    }
    return result;
}

- (void)setTransform:(id)aTransform
{
    if (_transform != aTransform) {
        [_transform release];
        _transform = [aTransform copy];
    }
}

- (id)transform
{
    return _transform;
}

- (id)undoManager
{
    return nil;
}

- (id)hyperObjectForVectorGraphics:(id)aGraphics
{
    return nil;
}

- (void)setVectorGraphics:(id)aGraphics
{
    id self_00;

    if (_vectorGraphics != aGraphics) {
        [_vectorGraphics setOwner:nil];
        [_vectorGraphics release];
        self_00 = [aGraphics copy];
        _vectorGraphics = self_00;
        [self_00 setOwner:self];
    }
}

- (id)vectorGraphics
{
    return _vectorGraphics;
}

- (id)bezierPath
{
    return [_vectorGraphics hyperBezierPath];
}

- (void)dealloc
{
    [_transform release];
    [_vectorGraphics setOwner:nil];
    [_vectorGraphics release];
    [super dealloc];
}

- (id)initWithBezierPath:(id)aPath
{
    id pvVar2_2;

    self = [super init];
    if (self != nil) {
        pvVar2_2 = [[HSVectorGraphics alloc] initWithBezierPath:[[aPath copy] autorelease]];
        _vectorGraphics = pvVar2_2;
        [pvVar2_2 setOwner:self];
        _transform = [[NSAffineTransform transform] retain];
    }
    return self;
}

- (id)init
{
    id pvVar2_2;

    self = [super init];
    if (self != nil) {
        pvVar2_2 = [[HSVectorGraphics alloc] init];
        _vectorGraphics = pvVar2_2;
        [pvVar2_2 setOwner:self];
        _transform = [[NSAffineTransform transform] retain];
    }
    return self;
}

@end

