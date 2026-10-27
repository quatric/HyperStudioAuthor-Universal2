#import "HSMediaStripItemGeometry.h"

@implementation HSMediaStripItemGeometry

/* i386 ivar offsets: _owner=0x4, _frame=0x8, _imageFrame=0x18, _imageBorderFrame=0x28, _labelFrame=0x38, _sourceFrame=0x48, _destinationFrame=0x58 */

- (id)accessibilityFocusedUIElement
{
    return _owner;
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return self;
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (void)accessibilityPerformAction:(id)aAction
{
    if ([aAction isEqualToString:NSAccessibilityPressAction]) {
        [_owner selectItemAtIndex:[_owner indexOfItem:self]];
    }
}

- (id)accessibilityActionDescription:(id)aDescription
{
    NSString *pvVar1_2;

    if (![aDescription isEqualToString:NSAccessibilityPressAction]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Card Browser Select Item Action" value:@"" table:0];
    }
    return pvVar1_2;
}

- (id)accessibilityActionNames
{
    return [NSArray arrayWithObject:NSAccessibilityPressAction];
}

- (void)accessibilitySetValue:(id)aValue forAttribute:(id)aAttribute
{

}

- (BOOL)accessibilityIsAttributeSettable:(id)aSettable
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa00a @ 000aa00a, 852 bytes * /

id FUN_000aa00a(HSMediaStripItemGeometry *self,SEL _cmd,id accessibilityAttributeValue)

{
  id pvVar1;
  id self_00;
  undefined4 *puVar2;
  undefined4 *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar2 = (undefined4 *)&stack0xffffff94;
  puVar3 = (undefined4 *)&stack0xffffff94;
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
  if ((char)pvVar1 != '\0') {
    return self->_owner;
  }
  pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      return *(id *)PTR_00336354;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(cls_NSBundle,sel_mainBundle);
      puVar3 = (undefined4 *)&stack0xffffff94;
      goto LAB_000aa184;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_),
       (char)pvVar1 != '\0')) {
      pvVar1 = _objc_msgSend(self->_owner,sel_indexOfItem_);
      puVar4 = sel_labelForItemAtIndex_;
      puVar5 = self->_owner;
LAB_000aa179:
      *(id *)((int)puVar2 + 8) = pvVar1;
      goto LAB_000aa17d;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_),
       puVar3 = (undefined4 *)&stack0xffffff94, (char)pvVar1 != '\0')) goto LAB_000aa184;
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    if ((char)pvVar1 != '\0') {
      self_00 = _objc_msgSend(self->_owner,sel_window);
      pvVar1 = self->_owner;
      _objc_msgSend_stret(local_44,self,sel_frame);
      _objc_msgSend_stret(local_34,pvVar1,sel_convertRect_toView_);
      puVar2 = (undefined4 *)&stack0xffffff8c;
      pvVar1 = _objc_msgSend(self_00,sel_convertBaseToScreen_);
      puVar4 = sel_valueWithPoint_;
      puVar5 = cls_NSValue;
      goto LAB_000aa179;
    }
    pvVar1 = _objc_msgSend(accessibilityAttributeValue,sel_isEqualToString_);
    puVar5 = cls_NSValue;
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    _objc_msgSend_stret(local_24,self,sel_frame);
    puVar2 = (undefined4 *)&stack0xffffff90;
  }
  else {
    puVar5 = self->_owner;
    puVar2 = (undefined4 *)&stack0xffffff94;
    puVar4 = sel_window;
LAB_000aa17d:
    *(undefined **)((int)puVar2 + 4) = puVar4;
  }
  *puVar2 = puVar5;
  puVar3 = puVar2;
LAB_000aa184:
  puVar3[-1] = 0xaa189;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return pvVar1;
}

*/
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityParentAttribute]) {
        return _owner;
    }
    if ([aValue isEqualToString:NSAccessibilityWindowAttribute]) {
        return [_owner window];
    }
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute]) {
        return NSAccessibilityButtonRole;
    }
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Card Browser Item Role" value:@"" table:nil];
    }
    if ([aValue isEqualToString:NSAccessibilityTitleAttribute] || [aValue isEqualToString:NSAccessibilityHelpAttribute]) {
        return [_owner labelForItemAtIndex:[_owner indexOfItem:self]];
    }
    if ([aValue isEqualToString:NSAccessibilityFocusedAttribute]) {
        return [NSNumber numberWithBool:NO];
    }
    if ([aValue isEqualToString:NSAccessibilityEnabledAttribute]) {
        return [NSNumber numberWithBool:YES];
    }
    if ([aValue isEqualToString:NSAccessibilityPositionAttribute]) {
        NSRect rect = [_owner convertRect:[self frame] toView:nil];
        return [NSValue valueWithPoint:[[_owner window] convertBaseToScreen:rect.origin]];
    }
    if ([aValue isEqualToString:NSAccessibilitySizeAttribute]) {
        return [NSValue valueWithSize:[self frame].size];
    }
    return nil;
}

- (id)accessibilityAttributeNames
{
    return [NSArray arrayWithObjects:NSAccessibilityParentAttribute, NSAccessibilityRoleAttribute, NSAccessibilityTitleAttribute, NSAccessibilityHelpAttribute, NSAccessibilityFocusedAttribute, NSAccessibilityEnabledAttribute, NSAccessibilityPositionAttribute, NSAccessibilitySizeAttribute, NSAccessibilityWindowAttribute, NSAccessibilityRoleDescriptionAttribute, nil];
}

- (void)invalidateAnimation
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;

    fVar1 = (_frame).origin.x;
    (_sourceFrame).origin.x = fVar1;
    fVar2 = (_frame).origin.y;
    (_sourceFrame).origin.y = fVar2;
    fVar3 = (_frame).size.width;
    (_sourceFrame).size.width = fVar3;
    fVar4 = (_frame).size.height;
    (_sourceFrame).size.height = fVar4;
    (_destinationFrame).origin.x = fVar1;
    (_destinationFrame).origin.y = fVar2;
    (_destinationFrame).size.width = fVar3;
    (_destinationFrame).size.height = fVar4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa409 @ 000aa409, 175 bytes * /

void FUN_000aa409(HSMediaStripItemGeometry *self,SEL _cmd)

{
  char cVar1;
  
  cVar1 = _NSEqualRects((self->_frame).origin,(self->_frame).size,(self->_destinationFrame).origin,
                        (self->_destinationFrame).size);
  if (cVar1 == '\0') {
    cVar1 = _NSEqualRects((self->_destinationFrame).origin,(self->_destinationFrame).size,
                          *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8));
    if (cVar1 == '\0') {
      (self->_frame).origin.x = (self->_destinationFrame).origin.x;
      (self->_frame).origin.y = (self->_destinationFrame).origin.y;
      (self->_frame).size.width = (self->_destinationFrame).size.width;
      (self->_frame).size.height = (self->_destinationFrame).size.height;
    }
  }
  return;
}

*/
- (void)endAnimation
{
    if (!NSEqualRects(_frame, _destinationFrame) && !NSEqualRects(_destinationFrame, NSZeroRect)) {
        _frame = _destinationFrame;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa4b8 @ 000aa4b8, 173 bytes * /

void FUN_000aa4b8(HSMediaStripItemGeometry *self,SEL _cmd,float animateWithProgress)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  
  fVar1 = (self->_sourceFrame).origin.x;
  fVar2 = (self->_sourceFrame).origin.y;
  fVar5 = SQRT(animateWithProgress);
  fVar3 = (self->_sourceFrame).size.height;
  fVar4 = (self->_sourceFrame).size.width;
  _objc_msgSend(self,sel_setFrame_,
                CONCAT44(((self->_destinationFrame).origin.y - fVar2) * fVar5 + fVar2,
                         ((self->_destinationFrame).origin.x - fVar1) * fVar5 + fVar1),
                CONCAT44(((self->_destinationFrame).size.height - fVar3) * fVar5 + fVar3,
                         ((self->_destinationFrame).size.width - fVar4) * fVar5 + fVar4));
  return;
}

*/
- (void)animateWithProgress:(CGFloat)aProgress
{
    CGFloat t = sqrtf(aProgress);
    [self setFrame:NSMakeRect(_sourceFrame.origin.x + (_destinationFrame.origin.x - _sourceFrame.origin.x) * t,
                              _sourceFrame.origin.y + (_destinationFrame.origin.y - _sourceFrame.origin.y) * t,
                              _sourceFrame.size.width + (_destinationFrame.size.width - _sourceFrame.size.width) * t,
                              _sourceFrame.size.height + (_destinationFrame.size.height - _sourceFrame.size.height) * t)];
}

- (void)animateToFrame:(NSRect)aFrame
{
    (_sourceFrame).origin.x = (_frame).origin.x;
    (_sourceFrame).origin.y = (_frame).origin.y;
    (_sourceFrame).size.width = (_frame).size.width;
    (_sourceFrame).size.height = (_frame).size.height;
    (_destinationFrame).origin.x = aFrame.origin.x;
    (_destinationFrame).origin.y = aFrame.origin.y;
    (_destinationFrame).size.width = aFrame.size.width;
    (_destinationFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa565 @ 000aa565, 408 bytes * /

void FUN_000aa565(HSMediaStripItemGeometry *self,SEL _cmd,NSPoint offsetByPoint)

{
  NSPoint NVar1;
  NSSize NVar2;
  float local_4c;
  float local_48;
  float local_44;
  float local_40;
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
  
  NVar1 = (self->_frame).origin;
  NVar2 = (self->_frame).size;
  _NSOffsetRect(&local_1c,NVar1.x,NVar1.y,NVar2.width,NVar2.height,offsetByPoint.x,offsetByPoint.y);
  (self->_frame).origin.x = local_1c;
  (self->_frame).origin.y = local_18;
  (self->_frame).size.width = local_14;
  (self->_frame).size.height = local_10;
  NVar1 = (self->_imageFrame).origin;
  NVar2 = (self->_imageFrame).size;
  _NSOffsetRect(&local_2c,NVar1.x,NVar1.y,NVar2.width,NVar2.height,offsetByPoint.x,offsetByPoint.y);
  (self->_imageFrame).origin.x = local_2c;
  (self->_imageFrame).origin.y = local_28;
  (self->_imageFrame).size.width = local_24;
  (self->_imageFrame).size.height = local_20;
  NVar1 = (self->_imageBorderFrame).origin;
  NVar2 = (self->_imageBorderFrame).size;
  _NSOffsetRect(&local_3c,NVar1.x,NVar1.y,NVar2.width,NVar2.height,offsetByPoint.x,offsetByPoint.y);
  (self->_imageBorderFrame).origin.x = local_3c;
  (self->_imageBorderFrame).origin.y = local_38;
  (self->_imageBorderFrame).size.width = local_34;
  (self->_imageBorderFrame).size.height = local_30;
  NVar1 = (self->_labelFrame).origin;
  NVar2 = (self->_labelFrame).size;
  _NSOffsetRect(&local_4c,NVar1.x,NVar1.y,NVar2.width,NVar2.height,offsetByPoint.x,offsetByPoint.y);
  (self->_labelFrame).origin.x = local_4c;
  (self->_labelFrame).origin.y = local_48;
  (self->_labelFrame).size.width = local_44;
  (self->_labelFrame).size.height = local_40;
  return;
}

*/
- (void)offsetByPoint:(NSPoint)aPoint
{
    _frame = NSOffsetRect(_frame, aPoint.x, aPoint.y);
    _imageFrame = NSOffsetRect(_imageFrame, aPoint.x, aPoint.y);
    _imageBorderFrame = NSOffsetRect(_imageBorderFrame, aPoint.x, aPoint.y);
    _labelFrame = NSOffsetRect(_labelFrame, aPoint.x, aPoint.y);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aa6fd @ 000aa6fd, 164 bytes * /

id FUN_000aa6fd(HSMediaStripItemGeometry *self,SEL _cmd)

{
  undefined *self_00;
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  id pvVar4;
  
  self_00 = cls_NSString;
  uVar1 = _NSStringFromRect((self->_labelFrame).origin,(self->_labelFrame).size);
  uVar2 = _NSStringFromRect((self->_imageFrame).origin,(self->_imageFrame).size);
  uVar3 = _NSStringFromRect((self->_frame).origin,(self->_frame).size);
  pvVar4 = _objc_msgSend(self_00,sel_stringWithFormat_,
                         &cfstr_frame_______imageFrame_______labelFrame_____,uVar3,uVar2,uVar1);
  return pvVar4;
}

*/
- (id)description
{
    return [NSString stringWithFormat:@"frame = %@, imageFrame = %@, labelFrame = %@", NSStringFromRect(_frame), NSStringFromRect(_imageFrame), NSStringFromRect(_labelFrame)];
}

- (void)setImageBorderFrame:(NSRect)aFrame
{
    (_imageBorderFrame).origin.x = aFrame.origin.x;
    (_imageBorderFrame).origin.y = aFrame.origin.y;
    (_imageBorderFrame).size.width = aFrame.size.width;
    (_imageBorderFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a9d7f @ 000a9d7f, 52 bytes * /

NSRect * FUN_000a9d7f(NSRect *__return_storage_ptr__,HSMediaStripItemGeometry *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_imageBorderFrame).origin.x;
  (__return_storage_ptr__->origin).y = (self->_imageBorderFrame).origin.y;
  (__return_storage_ptr__->size).width = (self->_imageBorderFrame).size.width;
  (__return_storage_ptr__->size).height = (self->_imageBorderFrame).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)imageBorderFrame
{
    return _imageBorderFrame;
}

- (void)setLabelFrame:(NSRect)aFrame
{
    (_labelFrame).origin.x = aFrame.origin.x;
    (_labelFrame).origin.y = aFrame.origin.y;
    (_labelFrame).size.width = aFrame.size.width;
    (_labelFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a9d1b @ 000a9d1b, 52 bytes * /

NSRect * FUN_000a9d1b(NSRect *__return_storage_ptr__,HSMediaStripItemGeometry *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_labelFrame).origin.x;
  (__return_storage_ptr__->origin).y = (self->_labelFrame).origin.y;
  (__return_storage_ptr__->size).width = (self->_labelFrame).size.width;
  (__return_storage_ptr__->size).height = (self->_labelFrame).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)labelFrame
{
    return _labelFrame;
}

- (void)setImageFrame:(NSRect)aFrame
{
    (_imageFrame).origin.x = aFrame.origin.x;
    (_imageFrame).origin.y = aFrame.origin.y;
    (_imageFrame).size.width = aFrame.size.width;
    (_imageFrame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a9cb7 @ 000a9cb7, 52 bytes * /

NSRect * FUN_000a9cb7(NSRect *__return_storage_ptr__,HSMediaStripItemGeometry *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_imageFrame).origin.x;
  (__return_storage_ptr__->origin).y = (self->_imageFrame).origin.y;
  (__return_storage_ptr__->size).width = (self->_imageFrame).size.width;
  (__return_storage_ptr__->size).height = (self->_imageFrame).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)imageFrame
{
    return _imageFrame;
}

- (void)setFrame:(NSRect)aFrame
{
    (_frame).origin.x = aFrame.origin.x;
    (_frame).origin.y = aFrame.origin.y;
    (_frame).size.width = aFrame.size.width;
    (_frame).size.height = aFrame.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a9c53 @ 000a9c53, 52 bytes * /

NSRect * FUN_000a9c53(NSRect *__return_storage_ptr__,HSMediaStripItemGeometry *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_frame).origin.x;
  (__return_storage_ptr__->origin).y = (self->_frame).origin.y;
  (__return_storage_ptr__->size).width = (self->_frame).size.width;
  (__return_storage_ptr__->size).height = (self->_frame).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)frame
{
    return _frame;
}

- (id)initWithOwner:(id)aOwner
{
    self = [super init];
    if (self != nil) {
        _owner = aOwner;
    }
    return self;
}

@end

