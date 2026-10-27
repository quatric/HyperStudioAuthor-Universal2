#import "HSObjectAssistant.h"

// Margin between the composition view and the textured content view (room for the anchor and the shadow).
static const CGFloat HSObjectAssistantCompositionInset = 16.0;

// Anchor images cached by position (1-4).
static NSImage *HSObjectAssistantAnchorImages[5];

@implementation HSObjectAssistant

/* i386 ivar offsets: _window=0x4, _compositionView=0x8, _anchorView=0xc, _contentView=0x10, _containerView=0x14, _closeButton=0x18, _toggleInspectorButton=0x1c, _inspectorNameTextField=0x20, _inset=0x24, _object=0x34, _delegate=0x38, _paneHistory=0x3c, _currentPane=0x40, _lastSelectedPaneIdentifier=0x44, _active=0x48, _visible=0x49, _shouldBeVisible=0x4a, _shouldUseAnimationWhenChangingVisibility=0x4b, _persistentMode=0x4c, _actualMode=0x50, _prefersInspectorMode=0x54, _doesntSupportsSettingsOnTheSpotMode=0x55, _suspendSwitchingDelegation=0x56, _isInternalWindowMovement=0x57, _shouldNotCoverObjectForAssistant=0x58, _SOTSLayout=0x5c, _SOTSWithDrawerLayout=0x60, _inspectorLayout=0x64, _inspectorCenteringLayout=0x68, _layoutIsValid=0x6c, _objectScreenFrameUpdated=0x6d, _layoutIsCalculating=0x6e, _windowMoveIsInitiatedByUser=0x6f, _layoutResult=0x70, _parentWindow=0x74, _drawer=0x78 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fb449 @ 000fb449, 149 bytes * /

id FUN_000fb449(id self,SEL _cmd,int anchorImageForPosition)

{
  undefined *self_00;
  id pvVar1;
  
  self_00 = cls_NSImage;
  if (anchorImageForPosition - 1U < 4) {
    pvVar1 = (id)(&DAT_00342910)[anchorImageForPosition];
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_assistantWindowAnchor__d,
                             anchorImageForPosition);
      pvVar1 = _objc_msgSend(self_00,sel_imageNamed_,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      (&DAT_00342910)[anchorImageForPosition] = pvVar1;
    }
  }
  else {
    pvVar1 = (id)0x0;
  }
  return pvVar1;
}

*/
+ (id)anchorImageForPosition:(NSInteger)aPosition
{
    if ((NSUInteger)(aPosition - 1) >= 4) {
        return nil;
    }
    if (HSObjectAssistantAnchorImages[aPosition] == nil) {
        HSObjectAssistantAnchorImages[aPosition] = [[NSImage imageNamed:[NSString stringWithFormat:@"assistantWindowAnchor_%d", (int)aPosition]] retain];
    }
    return HSObjectAssistantAnchorImages[aPosition];
}

- (BOOL)window:(id)aWindow doCommandBySelector:(SEL)aSelector
{
    return (BOOL)[[self delegate] objectAssistant:self doCommandBySelector:aSelector];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fd32b @ 000fd32b, 1456 bytes * /

void FUN_000fd32b(HSObjectAssistant *self,SEL _cmd,id showPopDownAnimationForLayoutResult)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined *puVar8;
  undefined *puVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  undefined8 local_74;
  undefined8 local_6c;
  undefined8 local_64;
  undefined8 local_5c;
  undefined8 local_54;
  undefined8 local_4c;
  undefined1 local_44 [16];
  float local_34;
  float local_30;
  float local_24;
  float fStack_20;
  undefined8 local_1c;
  
  pvVar10 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(&local_24,pvVar10,sel_frame);
  _objc_msgSend(self,sel_replaceWindowContentViewWithImageRepresentation);
  pvVar10 = _objc_msgSend(showPopDownAnimationForLayoutResult,sel_objectForKey_);
  _objc_msgSend_stret(&local_34,pvVar10,sel_rectValue);
  fVar14 = local_24 - local_34;
  fVar15 = fStack_20 - local_30;
  pvVar10 = _objc_msgSend(showPopDownAnimationForLayoutResult,sel_objectForKey_,
                          *(undefined4 *)PTR_PTR_00336528);
  _objc_msgSend_stret(local_44,pvVar10,sel_rectValue);
  fVar16 = fVar14;
  fVar17 = fVar15;
  _NSOffsetRect();
  puVar9 = cls_NSDictionary;
  puVar6 = PTR_00336548;
  uVar1 = *(undefined4 *)PTR_00336548;
  pvVar10 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,local_54,local_4c,fVar16,fVar17);
  puVar7 = PTR_00336550;
  uVar2 = *(undefined4 *)PTR_00336550;
  pvVar11 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,CONCAT44(fStack_20,local_24),local_1c);
  puVar8 = PTR_00336554;
  uVar3 = *(undefined4 *)PTR_00336554;
  pvVar12 = _objc_msgSend(self,sel_window);
  pvVar10 = _objc_msgSend(puVar9,sel_dictionaryWithObjectsAndKeys_,pvVar12,uVar3,pvVar11,uVar2,
                          pvVar10,uVar1,0);
  pvVar11 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
  pvVar10 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pvVar10);
  pvVar10 = _objc_msgSend(pvVar11,sel_initWithViewAnimations_,pvVar10);
  _objc_msgSend(pvVar10,sel_setDuration_,0x9999999a);
  _objc_msgSend(pvVar10,sel_setAnimationBlockingMode_,0);
  pvVar11 = _objc_msgSend(showPopDownAnimationForLayoutResult,sel_objectForKey_,
                          *(undefined4 *)PTR_PTR_0033652c);
  _objc_msgSend_stret(&local_64,pvVar11,sel_rectValue);
  _NSOffsetRect(&local_74,local_64,local_5c,fVar14,fVar15);
  puVar9 = cls_NSDictionary;
  uVar1 = *(undefined4 *)puVar6;
  uVar2 = *(undefined4 *)PTR_0033654c;
  uVar3 = *(undefined4 *)PTR_00336544;
  pvVar11 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,local_74,local_6c);
  uVar4 = *(undefined4 *)puVar7;
  pvVar12 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,local_54,local_4c);
  uVar5 = *(undefined4 *)puVar8;
  pvVar13 = _objc_msgSend(self,sel_window);
  pvVar11 = _objc_msgSend(puVar9,sel_dictionaryWithObjectsAndKeys_,pvVar13,uVar5,pvVar12,uVar4,
                          pvVar11,uVar1,uVar2,uVar3,0);
  pvVar12 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
  pvVar11 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pvVar11);
  pvVar11 = _objc_msgSend(pvVar12,sel_initWithViewAnimations_,pvVar11);
  _objc_msgSend(pvVar11,sel_setDuration_,0,0x3fd00000);
  _objc_msgSend(pvVar11,sel_setAnimationBlockingMode_,0);
  _objc_msgSend(pvVar10,sel_startAnimation);
  _objc_msgSend(pvVar11,sel_startAnimation);
  _objc_msgSend(pvVar10,sel_release);
  _objc_msgSend(pvVar11,sel_release);
  _objc_msgSend(self,sel_setParentWindow_,0);
  pvVar10 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar10,sel_setFrame_display_,CONCAT44(fStack_20,local_24),local_1c,1);
  _objc_msgSend(self,sel_restoreWindowContentView);
  return;
}

*/
- (void)showPopDownAnimationForLayoutResult:(id)aResult
{
    NSRect windowFrame = [[self window] frame];
    [self replaceWindowContentViewWithImageRepresentation];
    NSRect layoutFrame = [[aResult objectForKey:HSObjectAssistantLayoutWindowFrame] rectValue];
    CGFloat dx = windowFrame.origin.x - layoutFrame.origin.x;
    CGFloat dy = windowFrame.origin.y - layoutFrame.origin.y;
    NSRect middleFrame = NSOffsetRect([[aResult objectForKey:HSObjectAssistantLayoutPopUpMiddleFrame] rectValue], dx, dy);
    NSDictionary *shrink = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self window], NSViewAnimationTargetKey,
                            [NSValue valueWithRect:windowFrame], NSViewAnimationStartFrameKey,
                            [NSValue valueWithRect:middleFrame], NSViewAnimationEndFrameKey,
                            nil];
    NSViewAnimation *shrinkAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:shrink]];
    [shrinkAnimation setDuration:0.1];
    [shrinkAnimation setAnimationBlockingMode:NSAnimationBlocking];
    NSRect endFrame = NSOffsetRect([[aResult objectForKey:HSObjectAssistantLayoutPopUpStartFrame] rectValue], dx, dy);
    NSDictionary *fade = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self window], NSViewAnimationTargetKey,
                          [NSValue valueWithRect:middleFrame], NSViewAnimationStartFrameKey,
                          [NSValue valueWithRect:endFrame], NSViewAnimationEndFrameKey,
                          NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
                          nil];
    NSViewAnimation *fadeAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:fade]];
    [fadeAnimation setDuration:0.25];
    [fadeAnimation setAnimationBlockingMode:NSAnimationBlocking];
    [shrinkAnimation startAnimation];
    [fadeAnimation startAnimation];
    [shrinkAnimation release];
    [fadeAnimation release];
    [self setParentWindow:nil];
    // Put the (now hidden) window back where it was.
    [[self window] setFrame:windowFrame display:YES];
    [self restoreWindowContentView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fc311 @ 000fc311, 1035 bytes * /

void FUN_000fc311(HSObjectAssistant *self,SEL _cmd,id showPopUpAnimationForLayoutResult)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined *puVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  undefined4 *puVar13;
  undefined1 local_24 [20];
  
  puVar13 = (undefined4 *)&stack0xffffff94;
  _objc_msgSend(self,sel_invalidateWindow);
  _objc_msgSend(self,sel_replaceWindowContentViewWithImageRepresentation);
  pvVar9 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar9,sel_orderFront_);
  uVar1 = *(undefined4 *)PTR_PTR_0033652c;
  pvVar9 = _objc_msgSend(showPopUpAnimationForLayoutResult,sel_objectForKey_);
  if (pvVar9 != (id)0x0) {
    pvVar9 = _objc_msgSend(self,sel_window);
    pvVar10 = _objc_msgSend(showPopUpAnimationForLayoutResult,sel_objectForKey_);
    _objc_msgSend_stret(local_24,pvVar10,sel_rectValue);
    puVar13 = (undefined4 *)&stack0xffffff90;
    _objc_msgSend(pvVar9,sel_setFrame_display_);
  }
  puVar8 = cls_NSDictionary;
  puVar5 = PTR_00336548;
  uVar2 = *(undefined4 *)PTR_00336548;
  uVar3 = *(undefined4 *)PTR_PTR_00336528;
  puVar13[2] = uVar3;
  puVar13[1] = sel_objectForKey_;
  *puVar13 = showPopUpAnimationForLayoutResult;
  puVar13[-1] = 0xfc44b;
  pvVar9 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar6 = PTR_00336550;
  uVar4 = *(undefined4 *)PTR_00336550;
  puVar13[2] = uVar1;
  puVar13[1] = sel_objectForKey_;
  *puVar13 = showPopUpAnimationForLayoutResult;
  puVar13[-1] = 0xfc475;
  pvVar10 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar7 = PTR_00336554;
  uVar1 = *(undefined4 *)PTR_00336554;
  puVar13[1] = sel_window;
  *puVar13 = self;
  puVar13[-1] = 0xfc498;
  pvVar11 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[7] = uVar2;
  puVar13[6] = pvVar9;
  puVar13[5] = uVar4;
  puVar13[4] = pvVar10;
  puVar13[3] = uVar1;
  puVar13[2] = pvVar11;
  puVar13[1] = sel_dictionaryWithObjectsAndKeys_;
  *puVar13 = puVar8;
  puVar13[8] = 0;
  puVar13[-1] = 0xfc4d9;
  pvVar9 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_alloc;
  *puVar13 = cls_NSViewAnimation;
  puVar13[-1] = 0xfc4f3;
  pvVar10 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[2] = pvVar9;
  puVar13[1] = sel_arrayWithObject_;
  *puVar13 = cls_NSArray;
  puVar13[-1] = 0xfc511;
  pvVar9 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[2] = pvVar9;
  puVar13[1] = sel_initWithViewAnimations_;
  *puVar13 = pvVar10;
  puVar13[-1] = 0xfc527;
  pvVar9 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_setDuration_;
  *puVar13 = pvVar9;
  puVar13[3] = 0x3fc00000;
  puVar13[2] = 0;
  puVar13[-1] = 0xfc54f;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_setAnimationBlockingMode_;
  *puVar13 = pvVar9;
  puVar13[2] = 0;
  puVar13[-1] = 0xfc56c;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar8 = cls_NSDictionary;
  uVar1 = *(undefined4 *)puVar5;
  puVar13[2] = *(undefined4 *)PTR_PTR_00336534;
  puVar13[1] = sel_objectForKey_;
  *puVar13 = showPopUpAnimationForLayoutResult;
  puVar13[-1] = 0xfc59e;
  pvVar10 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  uVar2 = *(undefined4 *)puVar6;
  puVar13[2] = uVar3;
  puVar13[1] = sel_objectForKey_;
  *puVar13 = showPopUpAnimationForLayoutResult;
  puVar13[-1] = 0xfc5c5;
  pvVar11 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  uVar3 = *(undefined4 *)puVar7;
  puVar13[1] = sel_window;
  *puVar13 = self;
  puVar13[-1] = 0xfc5e4;
  pvVar12 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[7] = uVar1;
  puVar13[6] = pvVar10;
  puVar13[5] = uVar2;
  puVar13[4] = pvVar11;
  puVar13[3] = uVar3;
  puVar13[2] = pvVar12;
  puVar13[1] = sel_dictionaryWithObjectsAndKeys_;
  *puVar13 = puVar8;
  puVar13[8] = 0;
  puVar13[-1] = 0xfc625;
  pvVar10 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_alloc;
  *puVar13 = cls_NSViewAnimation;
  puVar13[-1] = 0xfc63f;
  pvVar11 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[2] = pvVar10;
  puVar13[1] = sel_arrayWithObject_;
  *puVar13 = cls_NSArray;
  puVar13[-1] = 0xfc65d;
  pvVar10 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[2] = pvVar10;
  puVar13[1] = sel_initWithViewAnimations_;
  *puVar13 = pvVar11;
  puVar13[-1] = 0xfc673;
  pvVar10 = _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_setDuration_;
  *puVar13 = pvVar10;
  puVar13[3] = 0x3fb99999;
  puVar13[2] = 0x9999999a;
  puVar13[-1] = 0xfc697;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_setAnimationBlockingMode_;
  *puVar13 = pvVar10;
  puVar13[2] = 0;
  puVar13[-1] = 0xfc6b1;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_startAnimation;
  *puVar13 = pvVar9;
  puVar13[-1] = 0xfc6c6;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_startAnimation;
  *puVar13 = pvVar10;
  puVar13[-1] = 0xfc6d8;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_release;
  *puVar13 = pvVar9;
  puVar13[-1] = 0xfc6ed;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_release;
  *puVar13 = pvVar10;
  puVar13[-1] = 0xfc6ff;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  puVar13[1] = sel_restoreWindowContentView;
  *puVar13 = self;
  puVar13[-1] = 0xfc714;
  _objc_msgSend((id)*puVar13,(SEL)puVar13[1]);
  return;
}

*/
- (void)showPopUpAnimationForLayoutResult:(id)aResult
{
    [self invalidateWindow];
    [self replaceWindowContentViewWithImageRepresentation];
    // The original passes no sender here.
    [[self window] orderFront:nil];
    if ([aResult objectForKey:HSObjectAssistantLayoutPopUpStartFrame] != nil) {
        [[self window] setFrame:[[aResult objectForKey:HSObjectAssistantLayoutPopUpStartFrame] rectValue] display:NO];
    }
    NSDictionary *grow = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self window], NSViewAnimationTargetKey,
                          [aResult objectForKey:HSObjectAssistantLayoutPopUpStartFrame], NSViewAnimationStartFrameKey,
                          [aResult objectForKey:HSObjectAssistantLayoutPopUpMiddleFrame], NSViewAnimationEndFrameKey,
                          nil];
    NSViewAnimation *growAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:grow]];
    [growAnimation setDuration:0.125];
    [growAnimation setAnimationBlockingMode:NSAnimationBlocking];
    NSDictionary *settle = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self window], NSViewAnimationTargetKey,
                            [aResult objectForKey:HSObjectAssistantLayoutPopUpMiddleFrame], NSViewAnimationStartFrameKey,
                            [aResult objectForKey:HSObjectAssistantLayoutWindowFrame], NSViewAnimationEndFrameKey,
                            nil];
    NSViewAnimation *settleAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:settle]];
    [settleAnimation setDuration:0.1];
    [settleAnimation setAnimationBlockingMode:NSAnimationBlocking];
    [growAnimation startAnimation];
    [settleAnimation startAnimation];
    [growAnimation release];
    [settleAnimation release];
    [self restoreWindowContentView];
}

- (void)restoreWindowContentView
{
    [[self window] setContentView:_compositionView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fc1af @ 000fc1af, 354 bytes * /

void FUN_000fc1af(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined1 local_44 [12];
  undefined4 local_38;
  undefined1 local_34 [8];
  undefined4 local_2c;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  pvVar1 = _objc_msgSend(cls_NSImageView,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(local_44,pvVar2,sel_frame);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(local_34,pvVar2,sel_frame);
  local_24 = 0;
  uStack_20 = 0;
  local_1c = local_2c;
  uStack_18 = local_38;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,0,CONCAT44(local_38,local_2c));
  pvVar2 = _objc_msgSend(self,sel_contentViewImage);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  _objc_msgSend(pvVar1,sel_setImageScaling_,1);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar2,sel_setContentView_,pvVar1);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)replaceWindowContentViewWithImageRepresentation
{
    NSRect windowFrame = [[self window] frame];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, windowFrame.size.width, windowFrame.size.height)];
    [imageView setImage:[self contentViewImage]];
    [imageView setImageScaling:NSImageScaleAxesIndependently];
    [[self window] setContentView:imageView];
    [imageView release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fc04d @ 000fc04d, 354 bytes * /

id FUN_000fc04d(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined8 local_24;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
  _objc_msgSend_stret(&local_24,pvVar1,sel_bounds);
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
  pvVar1 = _objc_msgSend(pvVar1,sel_bitmapImageRepForCachingDisplayInRect_,local_24,
                         CONCAT44(uStack_18,local_1c));
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
  _objc_msgSend(pvVar2,sel_cacheDisplayInRect_toBitmapImageRep_,local_24,
                CONCAT44(uStack_18,local_1c),pvVar1);
  pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithSize_,local_1c,uStack_18);
  _objc_msgSend(pvVar2,sel_addRepresentation_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar2,sel_autorelease);
  return pvVar1;
}

*/
- (id)contentViewImage
{
    NSView *contentView = [[self window] contentView];
    NSRect bounds = [contentView bounds];
    NSBitmapImageRep *rep = [contentView bitmapImageRepForCachingDisplayInRect:bounds];
    [contentView cacheDisplayInRect:bounds toBitmapImageRep:rep];
    NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
    [image addRepresentation:rep];
    return [image autorelease];
}

- (void)invalidateLayout
{
    _layoutIsValid = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fb2bd @ 000fb2bd, 233 bytes * /

id FUN_000fb2bd(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  op = sel_inspectorCenteringLayout;
  if (self->_actualMode == 2) goto LAB_000fb2de;
  pvVar1 = _objc_msgSend(self,sel_object);
  puVar2 = &DAT_0036f05c;
  pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036f05c);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_object,puVar2);
    puVar2 = &DAT_0036f0ac;
    pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036f0ac);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_prefersInspectorMode,puVar2), (char)pvVar1 == '\0')) {
      switch(self->_actualMode) {
      case 0:
        op = sel_SOTSLayout;
        break;
      case 1:
      case 3:
        goto switchD_000fb381_caseD_1;
      default:
        return (id)0x0;
      case 4:
        op = sel_SOTSWithDrawerLayout;
      }
      goto LAB_000fb2de;
    }
  }
switchD_000fb381_caseD_1:
  op = sel_inspectorLayout;
LAB_000fb2de:
  pvVar1 = _objc_msgSend(self,op);
  return pvVar1;
}

*/
- (id)currentLayout
{
    if (_actualMode == 2) {
        return [self inspectorCenteringLayout];
    }
    // Cards, stacks and users who prefer it always get the inspector.
    if ([[self object] implementsHyperInterface:@protocol(HSCardAttributes)]
        || [[self object] implementsHyperInterface:@protocol(HSStackAttributes)]
        || [self prefersInspectorMode]) {
        return [self inspectorLayout];
    }
    switch (_actualMode) {
        case 0:
            return [self SOTSLayout];
        case 1:
        case 3:
            return [self inspectorLayout];
        case 4:
            return [self SOTSWithDrawerLayout];
        default:
            return nil;
    }
}

- (id)inspectorCenteringLayout
{
    HSInspectorCenteringLayout *pHVar1;

    pHVar1 = _inspectorCenteringLayout;
    if (pHVar1 == nil) {
        pHVar1 = [HSInspectorCenteringLayout new];
        _inspectorCenteringLayout = pHVar1;
    }
    return pHVar1;
}

- (id)inspectorLayout
{
    HSInspectorLayout *pHVar1;

    pHVar1 = _inspectorLayout;
    if (pHVar1 == nil) {
        pHVar1 = [HSInspectorLayout new];
        _inspectorLayout = pHVar1;
    }
    return pHVar1;
}

- (id)SOTSWithDrawerLayout
{
    id pvVar1;

    pvVar1 = _SOTSWithDrawerLayout;
    if (pvVar1 == nil) {
        pvVar1 = [HSSOTSWithDrawerLayout new];
        _SOTSWithDrawerLayout = pvVar1;
    }
    return pvVar1;
}

- (id)SOTSLayout
{
    id pvVar1;

    pvVar1 = _SOTSLayout;
    if (pvVar1 == nil) {
        pvVar1 = [HSSOTSLayout new];
        _SOTSLayout = pvVar1;
    }
    return pvVar1;
}

- (void)setShouldNotCoverObjectForAssistant:(BOOL)aAssistant
{
    _shouldNotCoverObjectForAssistant = aAssistant != NO;
}

- (BOOL)shouldNotCoverObjectForAssistant
{
    return _shouldNotCoverObjectForAssistant;
}

- (void)setSupportsSettingsOnTheSpotMode:(BOOL)aMode
{
    if ((BOOL)_doesntSupportsSettingsOnTheSpotMode != (aMode == NO) ) {
        _doesntSupportsSettingsOnTheSpotMode = aMode == NO;
        [self refreshInspectorModeAsChangedByUser];
        [self updateToggleInspectorButtonVisibility];
    }
}

- (BOOL)supportsSettingsOnTheSpotMode
{
    return _doesntSupportsSettingsOnTheSpotMode == NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fb0dd @ 000fb0dd, 181 bytes * /

void FUN_000fb0dd(HSObjectAssistant *self,SEL _cmd,BOOL setPrefersInspectorMode)

{
  id self_00;
  
  if ((bool)self->_prefersInspectorMode != (setPrefersInspectorMode != '\0')) {
    self->_prefersInspectorMode = setPrefersInspectorMode != '\0';
    _objc_msgSend(self,sel_setParentWindow_,0);
    _objc_msgSend(self,sel_invalidateLayout);
    self_00 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    _objc_msgSend(self_00,sel_setBool_forKey_,(int)self->_prefersInspectorMode,
                  *(undefined4 *)PTR_PTR_00336520);
    _objc_msgSend(self,sel_refreshInspectorModeAsChangedByUser);
  }
  return;
}

*/
- (void)setPrefersInspectorMode:(BOOL)aMode
{
    if (_prefersInspectorMode != (aMode != NO)) {
        _prefersInspectorMode = (aMode != NO);
        [self setParentWindow:nil];
        [self invalidateLayout];
        [[NSUserDefaults standardUserDefaults] setBool:_prefersInspectorMode forKey:HSObjectAssistantIsWorkingInInspectorMode];
        [self refreshInspectorModeAsChangedByUser];
    }
}

- (BOOL)prefersInspectorMode
{
    return _prefersInspectorMode;
}

- (void)refreshInspectorModeAsChangedByUser
{
    int uVar1;

    if ((_prefersInspectorMode == NO) && (_doesntSupportsSettingsOnTheSpotMode == NO))
    {
        uVar1 = 0;
    }
    else {
        uVar1 = 1;
    }
    [self setPersistentInspectorMode:uVar1];
}

- (void)toggleDrawerModeWithDrawerSize:(NSSize)aSize
{
    int uVar1;

    if (_actualMode == 0) {
        [[self SOTSWithDrawerLayout] setDrawerSize:aSize];
        uVar1 = 4;
    }
    else {
        if (_actualMode != 4) {
            return;
        }
        uVar1 = 0;
    }
    [self setActualInspectorMode:uVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fafcc @ 000fafcc, 67 bytes * /

void FUN_000fafcc(HSObjectAssistant *self,SEL _cmd,BOOL setNeedsTemporaryCenteringMode)

{
  SEL op;
  
  op = sel_synchronizeWithPersistentMode;
  if (setNeedsTemporaryCenteringMode != '\0') {
    op = sel_setActualInspectorMode_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)setNeedsTemporaryCenteringMode:(BOOL)aMode
{
    if (aMode != NO) {
        [self setActualInspectorMode:2];
    } else {
        [self synchronizeWithPersistentMode];
    }
}

- (void)setActualInspectorMode:(NSInteger)aMode
{
    BOOL pvVar1;

    if (_actualMode != aMode) {
        pvVar1 = [self isCurrentlyRespectingPositionSetByUser];
        _actualMode = aMode;
        [self invalidateLayout];
        if ([self isActive]) {
            if (pvVar1) {
                [self updateTopLeft];
            }
            if (![self isCurrentlyWorkingInSOTSMode]) {
                [self hideAnchor];
            }
            [self updateAssistant];
        }
        [self updateToggleInspectorButton];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fae63 @ 000fae63, 159 bytes * /

BOOL FUN_000fae63(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  
  pvVar1 = _objc_msgSend(self,sel_isCurrentlyWorkingInInspectorMode);
  if (((char)pvVar1 == '\0') && (self->_actualMode != 3)) {
    pvVar1 = _objc_msgSend(self,sel_isCurrentlyWorkingInSOTSMode);
    if ((char)pvVar1 == '\0') {
      bVar2 = false;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_layoutResult);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_PTR_00336538);
      pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
      bVar2 = pvVar1 == (id)0x0;
    }
  }
  else {
    bVar2 = true;
  }
  return bVar2;
}

*/
- (BOOL)isCurrentlyRespectingPositionSetByUser
{
    if ([self isCurrentlyWorkingInInspectorMode] || _actualMode == 3) {
        return YES;
    }
    if (![self isCurrentlyWorkingInSOTSMode]) {
        return NO;
    }
    return [[[self layoutResult] objectForKey:HSObjectAssistantLayoutWindowPosition] intValue] == 0;
}

- (BOOL)isCurrentlyWorkingInInspectorMode
{
    return _actualMode == 1;
}

- (BOOL)isCurrentlyWorkingInSOTSMode
{
    return _actualMode == 0 || _actualMode == 4;
}

- (BOOL)isWorkingInTemporaryMode
{
    return -(_actualMode - 2U < 2) & 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000faddf @ 000faddf, 132 bytes * /

id FUN_000faddf(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_anchorView;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSImageView,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,*(undefined8 *)PTR_00336078,
                           *(undefined8 *)(PTR_00336078 + 8));
    self->_anchorView = pvVar1;
    _objc_msgSend(pvVar1,sel_setImageFrameStyle_,0);
    pvVar1 = self->_anchorView;
  }
  return pvVar1;
}

*/
- (id)anchorView
{
    if (_anchorView == nil) {
        _anchorView = [[NSImageView alloc] initWithFrame:NSZeroRect];
        [_anchorView setImageFrameStyle:NSImageFrameNone];
    }
    return _anchorView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fd8db @ 000fd8db, 1097 bytes * /

id FUN_000fd8db(HSObjectAssistant *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  uint uVar3;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined1 local_24 [20];
  
  pvVar4 = self->_window;
  if (pvVar4 == (id)0x0) {
    uVar1 = *(undefined4 *)PTR_00336074;
    uVar2 = *(undefined4 *)(PTR_00336074 + 4);
    pvVar4 = _objc_msgSend(self,sel_windowSize);
    pvVar5 = _objc_msgSend(cls_HSObjectAssistantWindow,sel_alloc);
    pvVar4 = _objc_msgSend(pvVar5,sel_initWithContentRect_styleMask_backing_defer_,uVar1,uVar2,
                           pvVar4,extraout_EDX,0,2,0);
    self->_window = pvVar4;
    _objc_msgSend(pvVar4,sel_setAutorecalculatesKeyViewLoop_,1);
    _objc_msgSend(self->_window,sel_setMovableByWindowBackground_,1);
    pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar4,sel_addObserver_selector_name_object_,self,sel_assistantWindowWillMove_,
                  *(undefined4 *)PTR_0033655c,self->_window);
    pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar4,sel_addObserver_selector_name_object_,self,sel_assistantWindowDidMove_,
                  *(undefined4 *)PTR_00336558,self->_window);
    _objc_msgSend(self->_window,sel_setDelegate_,self);
    pvVar4 = _objc_msgSend(self,sel_contentViewSize);
    pvVar5 = _objc_msgSend(cls_NSView,sel_alloc);
    uVar3 = *(uint *)PTR_DAT_0033651c;
    _NSInsetRect(local_24,uVar1,uVar2,pvVar4,extraout_EDX_00,uVar3 ^ 0x80000000,uVar3 ^ 0x80000000);
    pvVar4 = _objc_msgSend(pvVar5,sel_initWithFrame_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                           (int)local_24._8_8_,SUB84(local_24._8_8_,4));
    self->_compositionView = pvVar4;
    _objc_msgSend(self->_contentView,sel_setFrameOrigin_,uVar3,uVar3);
    pvVar4 = self->_contentView;
    pvVar5 = _objc_msgSend(self,sel_contentViewSize);
    _objc_msgSend(pvVar4,sel_setFrameSize_,pvVar5,extraout_EDX_01);
    _objc_msgSend(self->_compositionView,sel_addSubview_,self->_contentView);
    _objc_msgSend(self->_contentView,sel_setAutoresizingMask_,0x12);
    _objc_msgSend(self->_window,sel_setContentView_,self->_compositionView);
    _objc_msgSend(self->_window,sel_setBecomesKeyOnlyIfNeeded_,1);
    _objc_msgSend(self->_window,sel_setAcceptsMouseMovedEvents_,1);
    _objc_msgSend(self->_window,sel_setHidesOnDeactivate_,1);
    _objc_msgSend(self->_window,sel_setFloatingPanel_,1);
    _objc_msgSend(self->_window,sel_setOpaque_,0);
    _objc_msgSend(self->_window,sel_setHasShadow_,1);
    pvVar4 = self->_window;
    pvVar5 = _objc_msgSend(cls_NSColor,sel_clearColor);
    _objc_msgSend(pvVar4,sel_setBackgroundColor_,pvVar5);
    _objc_msgSend(self,sel_updateToggleInspectorButton);
    pvVar4 = self->_window;
  }
  return pvVar4;
}

*/
- (id)window
{
    if (_window == nil) {
        NSSize windowSize = [self windowSize];
        _window = [[HSObjectAssistantWindow alloc] initWithContentRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, windowSize.width, windowSize.height)
                                                             styleMask:NSWindowStyleMaskBorderless
                                                               backing:NSBackingStoreBuffered
                                                                 defer:NO];
        [_window setAutorecalculatesKeyViewLoop:YES];
        [_window setMovableByWindowBackground:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assistantWindowWillMove:) name:NSWindowWillMoveNotification object:_window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assistantWindowDidMove:) name:NSWindowDidMoveNotification object:_window];
        [_window setDelegate:self];
        NSSize contentSize = [self contentViewSize];
        NSRect compositionFrame = NSInsetRect(NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, contentSize.width, contentSize.height),
                                              -HSObjectAssistantCompositionInset, -HSObjectAssistantCompositionInset);
        _compositionView = [[NSView alloc] initWithFrame:compositionFrame];
        [_contentView setFrameOrigin:NSMakePoint(HSObjectAssistantCompositionInset, HSObjectAssistantCompositionInset)];
        [_contentView setFrameSize:[self contentViewSize]];
        [_compositionView addSubview:_contentView];
        [_contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_window setContentView:_compositionView];
        [_window setBecomesKeyOnlyIfNeeded:YES];
        [_window setAcceptsMouseMovedEvents:YES];
        [_window setHidesOnDeactivate:YES];
        [_window setFloatingPanel:YES];
        [_window setOpaque:NO];
        [_window setHasShadow:YES];
        [_window setBackgroundColor:[NSColor clearColor]];
        [self updateToggleInspectorButton];
    }
    return _window;
}

- (void)updateToggleInspectorButton
{
    NSBundle *self_00;
    id pcVar3;
    id pvVar2_2;
    BOOL pvVar2_3;
    NSString *pvVar2_4;
    BOOL pvVar1_2;
    NSBundle *pvVar1_4;
    id pcVar3_2;

    [_toggleInspectorButton setState:(unsigned int)([self isCurrentlyWorkingInInspectorMode])];
    pvVar2_2 = _toggleInspectorButton;
    pvVar1_2 = [self isCurrentlyWorkingInInspectorMode];
    self_00 = [NSBundle mainBundle];
    if (!pvVar1_2) {
        pcVar3 = @"LinkButtonInSOTSModeTooltip";
    }
    else {
        pcVar3 = @"LinkButtonInInspectorModeTooltip";
    }
    [pvVar2_2 setToolTip:[self_00 localizedStringForKey:pcVar3 value:@"" table:@"AssistantPanes"]];
    pvVar2_3 = [self isCurrentlyWorkingInInspectorMode];
    pvVar1_4 = [NSBundle mainBundle];
    if (!pvVar2_3) {
        pcVar3_2 = @"Turn Off Settings on the Spot";
    }
    else {
        pcVar3_2 = @"Turn On Settings on the Spot";
    }
    pvVar2_4 = [pvVar1_4 localizedStringForKey:pcVar3_2 value:@"" table:@"AssistantPanes"];
    [[_toggleInspectorButton cell] accessibilitySetOverrideValue:pvVar2_4 forAttribute:NSAccessibilityDescriptionAttribute];
    [self updateToggleInspectorButtonVisibility];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fabd1 @ 000fabd1, 86 bytes * /

void FUN_000fabd1(HSObjectAssistant *self,SEL _cmd)

{
  id self_00;
  char cVar1;
  id pvVar2;
  
  self_00 = self->_toggleInspectorButton;
  if (self->_doesntSupportsSettingsOnTheSpotMode == '\0') {
    pvVar2 = _objc_msgSend(self,sel_isWorkingInTemporaryMode);
    if ((char)pvVar2 == '\0') {
      cVar1 = '\0';
      goto LAB_000fac07;
    }
  }
  cVar1 = '\x01';
LAB_000fac07:
  _objc_msgSend(self_00,sel_setHidden_,(int)cVar1);
  return;
}

*/
- (void)updateToggleInspectorButtonVisibility
{
    [_toggleInspectorButton setHidden:(_doesntSupportsSettingsOnTheSpotMode || [self isWorkingInTemporaryMode])];
}

- (id)delegate
{
    return _delegate;
}

- (id)object
{
    return _object;
}

- (id)paneHistory
{
    return _paneHistory;
}

- (void)openPaneWithIdentifier:(id)aIdentifier
{
    if ([[self currentPane] respondsToSelector:@selector(openPaneWithIdentifier:)]) {
        if ([[self currentPane] modalViewController] == nil) {
            [[self currentPane] performSelector:@selector(openPaneWithIdentifier:) withObject:aIdentifier];
        }
    }
}

- (id)rootViewController
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self object];
    if (![pvVar1 respondsToSelector:@selector(rootViewController)]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [pvVar1 rootViewController];
    }
    return pvVar1_2;
}

- (void)openPreviousPane:(id)aPane
{
    id pvVar1;

    pvVar1 = [self currentPane];
    if ([pvVar1 respondsToSelector:_cmd]) {
        [[self currentPane] performSelector:_cmd withObject:aPane];
    }
}

- (void)openNextPane:(id)aPane
{
    id pvVar1;

    pvVar1 = [self currentPane];
    if ([pvVar1 respondsToSelector:_cmd]) {
        [[self currentPane] performSelector:_cmd withObject:aPane];
    }
}

- (void)toggleInspectorMode:(id)aMode
{
    [self setPrefersInspectorMode:(unsigned int)(![self prefersInspectorMode])];
}

- (void)performClose:(id)aClose
{
    BOOL pvVar1_5;

    if ([[self currentPane] respondsToSelector:@selector(canClosePane)]) {
        if (![[self currentPane] canClosePane]) {
            return;
        }
    }
    [_drawer close:self];
    pvVar1_5 = [_delegate respondsToSelector:@selector(objectAssistantDidCloseByUser:)]
    ;
    if (pvVar1_5) {
        [_delegate objectAssistantDidCloseByUser:self];
    }
    [self performHideWindow:NO];
}

- (void)setPersistentInspectorMode:(NSInteger)aMode
{
    if (_persistentMode != aMode) {
        _persistentMode = aMode;
        [self synchronizeWithPersistentModeIfNeeded];
    }
}

- (void)synchronizeWithPersistentMode
{
    [self setActualInspectorMode:_persistentMode];
}

- (void)synchronizeWithPersistentModeIfNeeded
{
    if (![self isWorkingInTemporaryMode]) {
        [self setActualInspectorMode:_persistentMode];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fa7a9 @ 000fa7a9, 95 bytes * /

void FUN_000fa7a9(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_isWorkingInTemporaryMode);
  if ((char)pvVar1 == '\0') {
    uVar2 = 1;
    op = sel_setPrefersInspectorMode_;
  }
  else {
    uVar2 = 3;
    op = sel_setActualInspectorMode_;
  }
  _objc_msgSend(self,op,uVar2);
  return;
}

*/
- (void)userDidMoveObjectAssistantWindow
{
    if ([self isWorkingInTemporaryMode]) {
        [self setActualInspectorMode:3];
    } else {
        [self setPrefersInspectorMode:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fa728 @ 000fa728, 129 bytes * /

void FUN_000fa728(HSObjectAssistant *self,SEL _cmd,BOOL updateObjectScreenFrame)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_object);
  if ((pvVar1 != (id)0x0) && (self->_layoutIsCalculating == '\0')) {
    _objc_msgSend(self,sel_invalidateLayout);
    pvVar1 = _objc_msgSend(self,sel_isActive);
    if ((char)pvVar1 != '\0') {
      op = sel_updateAssistantWithoutKeyState;
      if (updateObjectScreenFrame != '\0') {
        op = sel_updateAssistant;
      }
      _objc_msgSend(self,op);
    }
  }
  return;
}

*/
- (void)updateObjectScreenFrame:(BOOL)aFrame
{
    if ([self object] != nil && !_layoutIsCalculating) {
        [self invalidateLayout];
        if ([self isActive]) {
            if (aFrame) {
                [self updateAssistant];
            } else {
                [self updateAssistantWithoutKeyState];
            }
        }
    }
}

- (void)updateObjectScreenFrameIfNeeded:(BOOL)aNeeded
{
    if (_objectScreenFrameUpdated == NO) {
        [self updateObjectScreenFrame:aNeeded];
        _objectScreenFrameUpdated = YES;
    }
}

- (BOOL)canGoBack
{
    return 0x1 < [_paneHistory count];
}

- (void)assistantGoBack:(id)aBack
{
    id pvVar2;

    pvVar2 = _paneHistory;
    [self goBackToPane:[pvVar2 objectAtIndex:(int)[pvVar2 count] + -2]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fa5a5 @ 000fa5a5, 183 bytes * /

void FUN_000fa5a5(HSObjectAssistant *self,SEL _cmd,id goBackToPane)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_isActive);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_notifyWillFinishObjectEditing), (char)pvVar1 != '\0')) {
    while (pvVar1 = _objc_msgSend(self->_paneHistory,sel_lastObject), pvVar1 != goBackToPane) {
      _objc_msgSend(self->_paneHistory,sel_removeLastObject);
    }
    _objc_msgSend(self,sel_invalidateLayout);
    _objc_msgSend(self,sel_setCurrentPane_,goBackToPane);
    _objc_msgSend(self,sel_notifyDidFinishObjectEditing);
  }
  return;
}

*/
- (void)goBackToPane:(id)aPane
{
    if ([self isActive] && [self notifyWillFinishObjectEditing]) {
        while ([_paneHistory lastObject] != aPane) {
            [_paneHistory removeLastObject];
        }
        [self invalidateLayout];
        [self setCurrentPane:aPane];
        [self notifyDidFinishObjectEditing];
    }
}

- (void)openAssistantPane:(id)aPane
{
    if ([self isActive]) {
        [self invalidateLayout];
        if ([self notifyWillFinishObjectEditing]) {
            [self pushPaneInHistory:aPane];
            [self notifyDidFinishObjectEditing];
            [self setCurrentPane:aPane];
        }
    }
}

- (void)pushPaneInHistory:(id)aHistory
{
    if ([aHistory needsToBeSavedInHistory]) {
        if ([_paneHistory lastObject] != aHistory) {
            [_paneHistory addObject:aHistory];
        }
    }
}

- (void)hideAssistant:(BOOL)aAssistant
{
    if (_visible != NO) {
        [self performHideWindow:aAssistant];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fa3ed @ 000fa3ed, 132 bytes * /

void FUN_000fa3ed(HSObjectAssistant *self,SEL _cmd,BOOL showAssistant)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isActive);
  op = sel_activateMainPaneShowWindow;
  if ((char)pvVar1 != '\0') {
    if (self->_visible != '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_isCurrentlyWorkingInSOTSMode);
    op = sel_performShowWindow_;
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self,sel_invalidateLayout);
      op = sel_performShowWindow_;
    }
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)showAssistant:(BOOL)aAssistant
{
    id assistantController = [HSObjectAssistantController sharedAssistantController];
    if (![assistantController isRecordingMovie] && ![assistantController isRecordingSound]) {
        if ([[HSEditorController sharedDocumentController] isInViewingMode])
            return;
        if (![[self object] isKindOfClass:[HSHypertextLinksProxyForInspector class]]) {
            id document = [[[[self object] queryHyperInterface:@protocol(HSNodeAttributes)] rootNode] document];
            id current = [[HSEditorController sharedDocumentController] currentDocument];
            if (current == nil) {
                if (![[[HSEditorController sharedDocumentController] documents] containsObject:document] && document != nil)
                    return;
            } else if (document != nil && document != current) {
                return;
            }
        }
    }
    if (![self isActive]) {
        [self activateMainPaneShowWindow];
        return;
    }
    if (_visible) {
        return;
    }
    if ([self isCurrentlyWorkingInSOTSMode]) {
        [self invalidateLayout];
    }
    [self performShowWindow:aAssistant];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fa339 @ 000fa339, 180 bytes * /

void FUN_000fa339(HSObjectAssistant *self,SEL _cmd,BOOL setShouldBeVisible,BOOL animate)

{
  id pvVar1;
  
  if ((self->_shouldBeVisible != setShouldBeVisible) ||
     (self->_shouldUseAnimationWhenChangingVisibility != animate)) {
    self->_shouldBeVisible = setShouldBeVisible;
    if (self->_shouldUseAnimationWhenChangingVisibility == '\0') {
      self->_shouldUseAnimationWhenChangingVisibility = animate;
    }
    if (setShouldBeVisible != '\0') {
      pvVar1 = _objc_msgSend(self,sel_object);
      if (pvVar1 != (id)0x0) {
        _objc_msgSend(cls_NSObject,sel_cancelPreviousPerformRequestsWithTarget_selector_object_,self
                      ,sel_applyGeometryChanges,0);
        _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_applyGeometryChanges,0,0,0
                     );
      }
    }
  }
  return;
}

*/
- (void)setShouldBeVisible:(BOOL)aVisible animate:(BOOL)aAnimate
{
    if (_shouldBeVisible != aVisible || _shouldUseAnimationWhenChangingVisibility != aAnimate) {
        _shouldBeVisible = aVisible;
        // Once requested, animation sticks until the change is applied.
        if (!_shouldUseAnimationWhenChangingVisibility) {
            _shouldUseAnimationWhenChangingVisibility = aAnimate;
        }
        if (aVisible && [self object] != nil) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(applyGeometryChanges) object:nil];
            [self performSelector:@selector(applyGeometryChanges) withObject:nil afterDelay:0.0];
        }
    }
}

- (void)deactivate
{
    if ([self isActive]) {
        if ([self notifyWillFinishObjectEditing]) {
            [self notifyDidFinishObjectEditing];
            _active = NO;
            [self performHideWindow:NO];
            [self setDelegate:0];
            [self setObject:0];
            [self setCurrentPane:nil];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillBecomeActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillResignActiveNotification object:NSApp];
    }
}

- (void)activateWithObject:(id)aObject delegate:(id)aDelegate
{
    if ([self notifyWillFinishObjectEditing]) {
        [self notifyDidFinishObjectEditing];
        _active = YES;
        [self setDelegate:aDelegate];
        [self setObject:aObject];
        [self setShouldBeVisible:YES animate:NO];
    }
}

- (void)updateAssistantWithShowedPane:(id)aPane
{
    [self updateObjectAssistantKeyState];
    [self updateInspectorName];
}

- (void)updateInspectorName
{
    if ([[self currentPane] windowTitle] != nil) {
        [_inspectorNameTextField setStringValue:[[self currentPane] windowTitle]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f9fc2 @ 000f9fc2, 196 bytes * /

void FUN_000f9fc2(HSObjectAssistant *self,SEL _cmd,id assistantWindowDidMove)

{
  bool bVar1;
  id pvVar2;
  
  if (self->_windowMoveIsInitiatedByUser == '\0') {
    pvVar2 = _objc_msgSend(self,sel_isCurrentlyWorkingInSOTSMode);
    if ((char)pvVar2 != '\0') {
      bVar1 = false;
      goto LAB_000f9ff5;
    }
  }
  bVar1 = true;
LAB_000f9ff5:
  if (((self->_isInternalWindowMovement == '\0') && (self->_visible != '\0')) && (bVar1)) {
    self->_windowMoveIsInitiatedByUser = '\0';
    _objc_msgSend(self,sel_updateTopLeft);
    _objc_msgSend(self,sel_invalidateLayout);
    _objc_msgSend(self,sel_userDidMoveObjectAssistantWindow);
    pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_userDidMoveObjectAssistantWindow_);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(self->_delegate,sel_userDidMoveObjectAssistantWindow_,self);
    }
  }
  return;
}

*/
- (void)assistantWindowDidMove:(id)aMove
{
    BOOL movedByUser = _windowMoveIsInitiatedByUser || ![self isCurrentlyWorkingInSOTSMode];
    if (!_isInternalWindowMovement && _visible && movedByUser) {
        _windowMoveIsInitiatedByUser = NO;
        [self updateTopLeft];
        [self invalidateLayout];
        [self userDidMoveObjectAssistantWindow];
        if ([_delegate respondsToSelector:@selector(userDidMoveObjectAssistantWindow:)]) {
            [_delegate userDidMoveObjectAssistantWindow:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fbfb4 @ 000fbfb4, 153 bytes * /

void FUN_000fbfb4(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  undefined4 local_1c;
  float local_18;
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(&local_1c,pvVar1,sel_frame);
  pvVar1 = _objc_msgSend(self,sel_inspectorLayout);
  _objc_msgSend(pvVar1,sel_setInspectorTopLeft_,local_1c,local_18 + local_10);
  return;
}

*/
- (void)updateTopLeft
{
    NSRect windowFrame = [[self window] frame];
    [[self inspectorLayout] setInspectorTopLeft:NSMakePoint(windowFrame.origin.x, NSMaxY(windowFrame))];
}

- (void)assistantWindowWillMove:(id)aMove
{
    if (_isInternalWindowMovement == NO) {
        [self hideAnchor];
        _windowMoveIsInitiatedByUser = YES;
    }
}

- (void)setCloseButtonEnabled:(BOOL)aEnabled
{
    [_closeButton setEnabled:aEnabled];
}

- (void)awakeFromNib
{
    [_contentView setImage:[NSImage imageNamed:@"Title_left_corner"] forType:0];
    [_contentView setImage:[NSImage imageNamed:@"Title_right_corner"] forType:2];
    [_contentView setImage:[NSImage imageNamed:@"Title_central"] forType:1];
    [_contentView setImage:[NSImage imageNamed:@"Left_central"] forType:3];
    [_contentView setImage:[NSImage imageNamed:@"Right_central"] forType:5];
    [_contentView setImage:[NSImage imageNamed:@"Central_part"] forType:4];
    [_contentView setImage:[NSImage imageNamed:@"Bottom_central"] forType:7];
    [_contentView setImage:[NSImage imageNamed:@"Bottom_left_corner"] forType:6];
    [_contentView setImage:[NSImage imageNamed:@"Bottom_right_corner"] forType:8];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_compositionView release];
    [_contentView release];
    [_paneHistory release];
    [[_window parentWindow] removeChildWindow:_window];
    [_window setDelegate:0];
    [_window release];
    [_SOTSWithDrawerLayout release];
    [_SOTSLayout release];
    [_inspectorLayout release];
    [_inspectorCenteringLayout release];
    [_anchorView release];
    [_object release];
    [_lastSelectedPaneIdentifier release];
    [_layoutResult release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fd115 @ 000fd115, 534 bytes * /

id FUN_000fd115(HSObjectAssistant *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  uint uVar3;
  cfstringStruct *pcVar4;
  HSObjectAssistant *local_7c;
  undefined *local_78;
  undefined4 local_74 [4];
  undefined1 local_64 [8];
  float local_5c;
  float local_54 [2];
  float local_4c;
  undefined1 local_44 [4];
  undefined4 local_40;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  local_7c = self;
  local_78 = PTR_s_NSObject_00350a50;
  self_00 = _objc_msgSendSuper(&local_7c,sel_init);
  if (self_00 != (id)0x0) {
    pcVar4 = &cfstr_ObjectAssistant;
    pvVar2 = self_00;
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_loadNibNamed_owner_,&cfstr_ObjectAssistant,self_00);
    if ((char)pvVar1 == '\0') {
      _objc_msgSend(self_00,sel_release,pcVar4,pvVar2);
      self_00 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_alloc,pcVar4,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_init);
      *(id *)((int)self_00 + 0x3c) = pvVar2;
      pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,*(undefined4 *)PTR_PTR_00336520);
      *(char *)((int)self_00 + 0x54) = (char)pvVar2;
      uVar3 = (uint)((char)pvVar2 != '\0');
      *(uint *)((int)self_00 + 0x4c) = uVar3;
      *(uint *)((int)self_00 + 0x50) = uVar3;
      _objc_msgSend_stret(local_74,*(id *)((int)self_00 + 0x14),sel_frame);
      *(undefined4 *)((int)self_00 + 0x24) = local_74[0];
      _objc_msgSend_stret(local_64,*(id *)((int)self_00 + 0x10),sel_frame);
      _objc_msgSend_stret(local_54,*(id *)((int)self_00 + 0x14),sel_frame);
      *(float *)((int)self_00 + 0x2c) = local_5c - (local_54[0] + local_4c);
      _objc_msgSend_stret(local_44,*(id *)((int)self_00 + 0x14),sel_frame);
      *(undefined4 *)((int)self_00 + 0x30) = local_40;
      _objc_msgSend_stret(local_34,*(id *)((int)self_00 + 0x10),sel_frame);
      _objc_msgSend_stret(local_24,*(id *)((int)self_00 + 0x14),sel_frame);
      *(float *)((int)self_00 + 0x28) = local_28 - (local_20 + local_18);
    }
  }
  return self_00;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        if (![NSBundle loadNibNamed:@"ObjectAssistant" owner:self]) {
            [self release];
            return nil;
        }
        _paneHistory = [[NSMutableArray alloc] init];
        _prefersInspectorMode = [[NSUserDefaults standardUserDefaults] boolForKey:HSObjectAssistantIsWorkingInInspectorMode];
        _persistentMode = _prefersInspectorMode ? 1 : 0;
        _actualMode = _persistentMode;
        // Margins of the container view inside the content view, as laid out in the nib.
        NSRect containerFrame = [_containerView frame];
        NSRect contentFrame = [_contentView frame];
        _inset.left = containerFrame.origin.x;
        _inset.right = contentFrame.size.width - NSMaxX(containerFrame);
        _inset.bottom = containerFrame.origin.y;
        _inset.top = contentFrame.size.height - NSMaxY(containerFrame);
    }
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fcd9a @ 000fcd9a, 891 bytes * /

void FUN_000fcd9a(HSObjectAssistant *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined *puVar3;
  undefined4 *puVar4;
  undefined4 uStack_b8;
  undefined1 local_74 [16];
  undefined8 local_64;
  undefined4 local_5c;
  undefined4 uStack_58;
  undefined1 local_54 [16];
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(local_54,pvVar2,sel_frame);
  if (self->_visible == '\0') {
    pvVar2 = _objc_msgSend(self,sel_inspectorLayout);
    _objc_msgSend(pvVar2,sel_setShouldCorrectWindowFrame_);
  }
  pvVar2 = _objc_msgSend(self,sel_layoutResult);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
  _objc_msgSend_stret(&local_64,pvVar2,sel_rectValue);
  puVar4 = (undefined4 *)&stack0xffffff5c;
  cVar1 = _NSEqualSizes();
  if (cVar1 == '\0') {
    _objc_msgSend_stret(local_74,self,sel_containerViewFrame);
    _objc_msgSend_stret(local_44,self->_containerView,sel_frame);
    puVar4 = (undefined4 *)&stack0xffffff54;
    cVar1 = _NSContainsRect();
    if (cVar1 == '\0') {
      _objc_msgSend(self->_containerView,sel_setAutoresizingMask_);
      pvVar2 = self->_containerView;
      _objc_msgSend_stret(local_34,self,sel_containerViewFrame);
      _objc_msgSend(pvVar2,sel_setFrame_);
      pvVar2 = _objc_msgSend(self,sel_currentPane);
      pvVar2 = _objc_msgSend(pvVar2,sel_view);
      _objc_msgSend_stret(local_24,self->_containerView,sel_bounds);
      puVar4 = (undefined4 *)&stack0xffffff4c;
      _objc_msgSend(pvVar2,sel_setFrame_);
      _objc_msgSend(self,sel_internalSetFrame_);
      goto LAB_000fd04b;
    }
  }
  else {
    _objc_msgSend(self,sel_hideAnchor);
  }
  *(ulonglong *)(puVar4 + 4) = CONCAT44(uStack_58,local_5c);
  *(undefined8 *)(puVar4 + 2) = local_64;
  puVar4[1] = sel_internalSetFrame_;
  *puVar4 = self;
LAB_000fd04b:
  puVar4[-1] = 0xfd050;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[1] = sel_layoutResult;
  *puVar4 = self;
  puVar4[-1] = 0xfd062;
  pvVar2 = _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[2] = pvVar2;
  puVar4[1] = sel_setupAnchorViewWithLayoutResult_;
  *puVar4 = self;
  puVar4[-1] = 0xfd078;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  if (self->_visible != self->_shouldBeVisible) {
    puVar3 = sel_hideAssistant_;
    if (self->_shouldBeVisible != '\0') {
      puVar3 = sel_showAssistant_;
    }
    puVar4[2] = (int)self->_shouldUseAnimationWhenChangingVisibility;
    puVar4[1] = puVar3;
    *puVar4 = self;
    puVar4[-1] = 0xfd0a8;
    _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  }
  puVar4[1] = sel_inspectorLayout;
  *puVar4 = self;
  puVar4[-1] = 0xfd0ba;
  pvVar2 = _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[1] = sel_setShouldCorrectWindowFrame_;
  *puVar4 = pvVar2;
  puVar4[2] = 0;
  puVar4[-1] = 0xfd0d4;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[1] = sel_updateReferenceToParentWindow;
  *puVar4 = self;
  puVar4[-1] = 0xfd0e6;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[1] = sel_updateToggleInspectorButton;
  *puVar4 = self;
  puVar4[-1] = 0xfd0f8;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[1] = sel_invalidateWindow;
  *puVar4 = self;
  puVar4[-1] = 0xfd10a;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return;
}

*/
- (void)applyGeometryChanges
{
    NSRect windowFrame = [[self window] frame];
    if (!_visible) {
        [[self inspectorLayout] setShouldCorrectWindowFrame:_shouldBeVisible];
    }
    NSRect newFrame = [[[self layoutResult] objectForKey:HSObjectAssistantLayoutWindowFrame] rectValue];
    if (NSEqualSizes(windowFrame.size, newFrame.size)) {
        [self hideAnchor];
        [self internalSetFrame:newFrame];
    } else if (NSContainsRect([self containerViewFrame], [_containerView frame])) {
        [self internalSetFrame:newFrame];
    } else {
        // Growing: keep the container pinned to the top while the window resizes, then let it follow again.
        [_containerView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
        [_containerView setFrame:[self containerViewFrame]];
        [[[self currentPane] view] setFrame:[_containerView bounds]];
        [self internalSetFrame:newFrame];
        [_containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    [self setupAnchorViewWithLayoutResult:[self layoutResult]];
    if (_visible != _shouldBeVisible) {
        if (_shouldBeVisible) {
            [self showAssistant:_shouldUseAnimationWhenChangingVisibility];
        } else {
            [self hideAssistant:_shouldUseAnimationWhenChangingVisibility];
        }
    }
    [[self inspectorLayout] setShouldCorrectWindowFrame:NO];
    [self updateReferenceToParentWindow];
    [self updateToggleInspectorButton];
    [self invalidateWindow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f9c6c @ 000f9c6c, 102 bytes * /

void FUN_000f9c6c(HSObjectAssistant *self,SEL _cmd,NSRect internalSetFrame)

{
  id self_00;
  
  self->_isInternalWindowMovement = '\x01';
  self_00 = _objc_msgSend(self,sel_window);
  _objc_msgSend(self_00,sel_setFrame_display_animate_,internalSetFrame.origin,internalSetFrame.size,
                (int)self->_visible,(int)self->_visible);
  self->_isInternalWindowMovement = '\0';
  return;
}

*/
- (void)internalSetFrame:(NSRect)aFrame
{
    _isInternalWindowMovement = YES;
    [[self window] setFrame:aFrame display:_visible animate:_visible];
    _isInternalWindowMovement = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fc868 @ 000fc868, 357 bytes * /

void FUN_000fc868(HSObjectAssistant *self,SEL _cmd,NSRect setWindowFrame)

{
  char cVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined1 local_24 [20];
  
  puVar3 = (undefined4 *)&stack0xffffffb4;
  if (self->_visible == '\0') {
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend_stret(local_24,pvVar2,sel_frame);
    puVar3 = (undefined4 *)&stack0xffffffb0;
    cVar1 = _NSEqualRects();
    if (cVar1 != '\0') {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_setFrame_display_animate_);
    _objc_msgSend(self,sel_layoutResult);
    _objc_msgSend(self,sel_setupAnchorViewWithLayoutResult_);
  }
  else {
    _objc_msgSend(cls_NSObject,sel_cancelPreviousPerformRequestsWithTarget_selector_object_);
  }
  puVar3[-1] = 0xfc8e2;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)setWindowFrame:(NSRect)aFrame
{
    if (_visible) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(applyGeometryChanges) object:nil];
        [self performSelector:@selector(applyGeometryChanges) withObject:nil afterDelay:0.0];
        return;
    }
    if (NSEqualRects(aFrame, [[self window] frame])) {
        return;
    }
    [[self window] setFrame:aFrame display:_visible animate:_visible];
    [self setupAnchorViewWithLayoutResult:[self layoutResult]];
    [self invalidateWindow];
}

- (void)setHasSeparatedFooter:(BOOL)aFooter
{
    [_containerView setSeparatesBottomArea:aFooter];
}

- (void)updateAssistantWithoutKeyState
{
    [self layoutComposition];
    [self updateInspectorName];
    [self setHasSeparatedFooter:[self requiresDarkBottomArea]];
}

- (void)updateAssistant
{
    [self layoutComposition];
    [self updateObjectAssistantKeyState];
    [self updateInspectorName];
    [self setHasSeparatedFooter:[self requiresDarkBottomArea]];
}

- (void)updateObjectAssistantKeyState
{
    BOOL pvVar1;
    id pvVar1_2;
    BOOL pvVar2_2;

    pvVar1 = [_currentPane assistantShouldBeKeyWindow];
    pvVar2_2 = [[self window] isKeyWindow];
    [[self window] setBecomesKeyOnlyIfNeeded:((unsigned int)(!pvVar1))];
    if (!pvVar1) {
        if (!pvVar2_2) {
            return;
        }
        pvVar1_2 = [NSApp mainWindow];
    }
    else {
        if (pvVar2_2) {
            return;
        }
        pvVar1_2 = [self window];
    }
    [pvVar1_2 makeKeyWindow];
}

- (BOOL)requiresDarkBottomArea
{
    if ([self mainPane] != nil) {
        if ([[self mainPane] respondsToSelector:@selector(requiresDarkBottomArea)]) {
            return [[self mainPane] requiresDarkBottomArea];
        }
    }
    return NO;
}

- (void)activateMainPaneShowWindow
{
    [self setCurrentPane:[self mainPane]];
    [self setShouldBeVisible:YES animate:NO];
}

- (void)performHideWindow:(BOOL)aWindow
{
    if (_visible != NO) {
        if (aWindow != NO) {
            [_drawer close:self];
            [self showPopDownAnimationForLayoutResult:[self layoutResult]];
        }
        _visible = NO;
        _shouldUseAnimationWhenChangingVisibility = NO;
        [self setParentWindow:0];
        [[self window] close];
        if (aWindow == NO) {
            [[_drawer window] orderOut:self];
        }
    }
    _shouldBeVisible = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(applyGeometryChanges) object:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f96f0 @ 000f96f0, 390 bytes * /

void FUN_000f96f0(HSObjectAssistant *self,SEL _cmd,BOOL performShowWindow)

{
  HSObjectAssistant *pHVar1;
  HSObjectAssistant *self_00;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  if (self->_visible != '\0') {
    return;
  }
  _objc_msgSend(self,sel_updateAssistant);
  if (performShowWindow == '\0') {
    _objc_msgSend(self,sel_invalidateWindow);
    pvVar2 = _objc_msgSend(self,sel_window);
    pHVar1 = self;
    _objc_msgSend(pvVar2,sel_orderFront_,self);
    if (self->_drawer == (HSObjectAssistantDrawer *)0x0) goto LAB_000f97b3;
    self_00 = _objc_msgSend(self->_drawer,sel_window,pHVar1);
    op = sel_orderFront_;
    pHVar1 = self;
  }
  else {
    pHVar1 = _objc_msgSend(self,sel_layoutResult);
    self_00 = self;
    op = sel_showPopUpAnimationForLayoutResult_;
  }
  _objc_msgSend(self_00,op,pHVar1);
LAB_000f97b3:
  self->_visible = '\x01';
  self->_shouldBeVisible = '\x01';
  self->_shouldUseAnimationWhenChangingVisibility = '\0';
  pvVar2 = _objc_msgSend(self,sel_window,pHVar1);
  _objc_msgSend(pvVar2,sel_orderFront_,self);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar2,sel_recalculateKeyViewLoop);
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar3 = _objc_msgSend(self->_currentPane,sel_initialKeyView);
  _objc_msgSend(pvVar2,sel_makeFirstResponder_,pvVar3);
  _objc_msgSend(self,sel_updateObjectAssistantKeyState);
  _objc_msgSend(self,sel_updateReferenceToParentWindow);
  return;
}

*/
- (void)performShowWindow:(BOOL)aWindow
{
    if (_visible) {
        return;
    }
    [self updateAssistant];
    if (aWindow) {
        [self showPopUpAnimationForLayoutResult:[self layoutResult]];
    } else {
        [self invalidateWindow];
        [[self window] orderFront:self];
        if (_drawer != nil) {
            [[_drawer window] orderFront:self];
        }
    }
    _visible = YES;
    _shouldBeVisible = YES;
    _shouldUseAnimationWhenChangingVisibility = NO;
    [[self window] orderFront:self];
    [[self window] recalculateKeyViewLoop];
    [[self window] makeFirstResponder:[_currentPane initialKeyView]];
    [self updateObjectAssistantKeyState];
    [self updateReferenceToParentWindow];
}

- (void)updateReferenceToParentWindow
{
    BOOL pvVar1_2;
    id pvVar1_3;

    if (![self isCurrentlyRespectingPositionSetByUser]) {
        pvVar1_2 = [_delegate respondsToSelector:@selector(objectAssistantParentWindow:)]
        ;
        if (!pvVar1_2) {
            pvVar1_3 = nil;
        }
        else {
            pvVar1_3 = [_delegate objectAssistantParentWindow:self];
        }
    }
    else {
        pvVar1_3 = nil;
    }
    [self setParentWindow:pvVar1_3];
}

- (void)applicationWillResignActive:(id)aActive
{
    NSWindow *pvVar1_2;

    pvVar1_2 = [[self window] parentWindow];
    _parentWindow = pvVar1_2;
    if (pvVar1_2 != nil) {
        [pvVar1_2 removeChildWindow:[self window]];
        [[self window] setHidesOnDeactivate:YES];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)applicationWillBecomeActive:(id)aActive
{
    id pvVar2;

    pvVar2 = _parentWindow;
    if (pvVar2 != nil) {
        [pvVar2 addChildWindow:[self window] ordered:1];
        [[self window] setHidesOnDeactivate:NO];
        [[self window] setFloatingPanel:NO];
        [[self window] setLevel:(CGWindowLevelForKey(5))];
        _parentWindow = nil;
    }
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fc9cd @ 000fc9cd, 739 bytes * /

void FUN_000fc9cd(HSObjectAssistant *self,SEL _cmd,id setParentWindow)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  SEL op;
  undefined *puVar5;
  
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_parentWindow);
  if (pvVar2 != setParentWindow) {
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar3,sel_setFloatingPanel_,1);
      pvVar3 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar2,sel_removeChildWindow_,pvVar3);
      pvVar2 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar2,sel_setHidesOnDeactivate_,1);
    }
    if (setParentWindow == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      puVar1 = PTR_00336058;
      _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_00336540,
                    *(undefined4 *)PTR_00336058);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      puVar5 = *(undefined **)PTR_00336484;
      uVar4 = *(undefined4 *)puVar1;
      op = sel_removeObserver_name_object_;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_window);
      _objc_msgSend(setParentWindow,sel_addChildWindow_ordered_,pvVar2,1);
      pvVar2 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar2,sel_setHidesOnDeactivate_,0);
      pvVar2 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar2,sel_setFloatingPanel_,0);
      pvVar2 = _objc_msgSend(self,sel_window);
      uVar4 = _CGWindowLevelForKey(5);
      _objc_msgSend(pvVar2,sel_setLevel_,uVar4);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,
                    sel_applicationWillBecomeActive_,*(undefined4 *)PTR_00336540,
                    *(undefined4 *)PTR_00336058);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      uVar4 = *(undefined4 *)PTR_00336484;
      op = sel_addObserver_selector_name_object_;
      puVar5 = sel_applicationWillResignActive_;
    }
    _objc_msgSend(pvVar2,op,self,puVar5,uVar4);
  }
  return;
}

*/
- (void)setParentWindow:(id)aWindow
{
    NSWindow *oldParent = [[self window] parentWindow];
    if (oldParent == aWindow) {
        return;
    }
    if (oldParent != nil) {
        [[self window] setFloatingPanel:YES];
        [oldParent removeChildWindow:[self window]];
        [[self window] setHidesOnDeactivate:YES];
    }
    if (aWindow == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillBecomeActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillResignActiveNotification object:NSApp];
    } else {
        [aWindow addChildWindow:[self window] ordered:NSWindowAbove];
        [[self window] setHidesOnDeactivate:NO];
        [[self window] setFloatingPanel:NO];
        [(NSWindow *)[self window] setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillBecomeActive:) name:NSApplicationWillBecomeActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:NSApp];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fbbde @ 000fbbde, 963 bytes * /

void FUN_000fbbde(HSObjectAssistant *self,SEL _cmd,id setupAnchorViewWithLayoutResult)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id self_01;
  int *piVar3;
  int *piVar4;
  undefined4 auStack_78 [3];
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  piVar3 = (int *)&stack0xffffff94;
  auStack_78[2] = 0xfbc0e;
  pvVar1 = _objc_msgSend(setupAnchorViewWithLayoutResult,sel_objectForKey_);
  if (pvVar1 != (id)0x0) {
    auStack_78[2] = 0xfbc24;
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    if ((char)pvVar1 != '\0') {
      return;
    }
  }
  auStack_78[2] = 0xfbc41;
  pvVar1 = _objc_msgSend(self,sel_layoutResult);
  auStack_78[2] = 0xfbc62;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_);
  auStack_78[2] = 0xfbc74;
  pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
  auStack_78[2] = 0xfbc89;
  pvVar2 = _objc_msgSend(self,sel_isCurrentlyWorkingInSOTSMode);
  if ((char)pvVar2 == '\0') {
    auStack_78[2] = 0xfbf87;
    _objc_msgSend(self,sel_anchorView);
    piVar4 = (int *)&stack0xffffff94;
  }
  else {
    auStack_78[2] = 0xfbca6;
    pvVar2 = _objc_msgSend(self,sel_window);
    auStack_78[2] = 0xfbcb8;
    pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
    auStack_78[2] = 0xfbccf;
    _objc_msgSend(self,sel_anchorView);
    auStack_78[2] = 0xfbce5;
    _objc_msgSend(pvVar2,sel_addSubview_);
    auStack_78[2] = 0xfbcfa;
    pvVar2 = _objc_msgSend(self,sel_anchorView);
    auStack_78[2] = 0xfbd11;
    self_00 = _objc_msgSend(self,sel_class);
    auStack_78[2] = 0xfbd2f;
    self_01 = _objc_msgSend(setupAnchorViewWithLayoutResult,sel_objectForKey_);
    auStack_78[2] = 0xfbd41;
    _objc_msgSend(self_01,sel_intValue);
    auStack_78[2] = 0xfbd57;
    _objc_msgSend(self_00,sel_anchorImageForPosition_);
    auStack_78[2] = 0xfbd6d;
    _objc_msgSend(pvVar2,sel_setImage_);
    auStack_78[2] = 0xfbd8e;
    pvVar2 = _objc_msgSend(setupAnchorViewWithLayoutResult,sel_objectForKey_);
    if (pvVar2 == (id)0x0) {
      local_24 = *(undefined4 *)PTR_00336078;
      uStack_20 = *(undefined4 *)(PTR_00336078 + 4);
      local_1c = *(undefined4 *)(PTR_00336078 + 8);
      uStack_18 = *(undefined4 *)(PTR_00336078 + 0xc);
    }
    else {
      auStack_78[2] = 0xfbdab;
      _objc_msgSend_stret(&local_24,pvVar2,sel_rectValue);
      piVar3 = auStack_78 + 2;
    }
    pvVar2 = self->_compositionView;
    *(ulonglong *)(piVar3 + 5) = CONCAT44(uStack_18,local_1c);
    *(ulonglong *)(piVar3 + 3) = CONCAT44(uStack_20,local_24);
    piVar3[2] = (int)sel_convertRect_fromView_;
    piVar3[1] = (int)pvVar2;
    *piVar3 = (int)&local_34;
    piVar3[7] = 0;
    piVar3[-1] = 0xfbe3b;
    _objc_msgSend_stret((void *)*piVar3,(id)piVar3[1],(SEL)piVar3[2]);
    piVar4 = piVar3 + -1;
    local_24 = local_34;
    uStack_20 = local_30;
    local_1c = local_2c;
    uStack_18 = local_28;
    *piVar3 = (int)sel_anchorView;
    piVar3[-1] = (int)self;
    piVar3[-2] = 0xfbe7d;
    pvVar2 = _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
    *(ulonglong *)(piVar3 + 3) = CONCAT44(uStack_18,local_1c);
    *(ulonglong *)(piVar3 + 1) = CONCAT44(uStack_20,local_24);
    *piVar3 = (int)sel_setFrame_;
    piVar3[-1] = (int)pvVar2;
    piVar3[-2] = 0xfbea5;
    _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
    switch(pvVar1) {
    case (id)0x1:
      *piVar3 = (int)sel_anchorView;
      piVar3[-1] = (int)self;
      piVar3[-2] = 0xfbed5;
      pvVar1 = _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
      *piVar3 = (int)sel_setAutoresizingMask_;
      piVar3[-1] = (int)pvVar1;
      piVar3[1] = 0xd;
      break;
    case (id)0x2:
      *piVar3 = (int)sel_anchorView;
      piVar3[-1] = (int)self;
      piVar3[-2] = 0xfbf04;
      pvVar1 = _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
      *piVar3 = (int)sel_setAutoresizingMask_;
      piVar3[-1] = (int)pvVar1;
      piVar3[1] = 0x25;
      piVar4 = piVar3 + -1;
      break;
    case (id)0x3:
      *piVar3 = (int)sel_anchorView;
      piVar3[-1] = (int)self;
      piVar3[-2] = 0xfbf30;
      pvVar1 = _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
      *piVar3 = (int)sel_setAutoresizingMask_;
      piVar3[-1] = (int)pvVar1;
      piVar3[1] = 0xc;
      piVar4 = piVar3 + -1;
      break;
    case (id)0x4:
      *piVar3 = (int)sel_anchorView;
      piVar3[-1] = (int)self;
      piVar3[-2] = 0xfbf5c;
      pvVar1 = _objc_msgSend((id)piVar3[-1],(SEL)*piVar3);
      *piVar3 = (int)sel_setAutoresizingMask_;
      piVar3[-1] = (int)pvVar1;
      piVar3[1] = 9;
      piVar4 = piVar3 + -1;
      break;
    default:
      goto switchD_000fbebe_default;
    }
  }
  piVar4[-1] = 0xfbf99;
  _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
switchD_000fbebe_default:
  return;
}

*/
- (void)setupAnchorViewWithLayoutResult:(id)aResult
{
    if ([[aResult objectForKey:HSObjectAssistantLayoutShouldNotShowAnchorKey] boolValue]) {
        return;
    }
    int position = [[[self layoutResult] objectForKey:HSObjectAssistantLayoutWindowPosition] intValue];
    if (![self isCurrentlyWorkingInSOTSMode]) {
        [[self anchorView] removeFromSuperview];
        return;
    }
    [[[self window] contentView] addSubview:[self anchorView]];
    [[self anchorView] setImage:[[self class] anchorImageForPosition:[[aResult objectForKey:HSObjectAssistantLayoutWindowPosition] intValue]]];
    NSValue *anchorValue = [aResult objectForKey:HSObjectAssistantLayoutLocalAnchorFrame];
    NSRect anchorFrame = anchorValue != nil ? [anchorValue rectValue] : NSZeroRect;
    anchorFrame = [_compositionView convertRect:anchorFrame fromView:nil];
    [[self anchorView] setFrame:anchorFrame];
    switch (position) {
        case 1:
            [(NSView *)[self anchorView] setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin];
            break;
        case 2:
            [(NSView *)[self anchorView] setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMaxYMargin];
            break;
        case 3:
            [(NSView *)[self anchorView] setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
            break;
        case 4:
            [(NSView *)[self anchorView] setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
            break;
        default:
            break;
    }
}

- (void)hideAnchor
{
    if ([[self anchorView] superview] != nil) {
        [[self anchorView] removeFromSuperview];
        [self invalidateWindow];
    }
}

- (id)windowWillReturnUndoManager:(id)aManager
{
    id pvVar1;
    NSWindow *pvVar2;
    id pvVar1_2;

    pvVar1 = [self currentPane];
    pvVar1_2 = [pvVar1 assistantPaneUndoManager];
    if ((pvVar1 == nil) && (pvVar2 = [NSApp modalWindow], pvVar2 == nil)) {
        pvVar1_2 = [[[[[NSDocumentController sharedDocumentController] currentDocument] currentWindowController] queryHyperInterface:@protocol(HSPreferedUndoManagerOwner)] preferedUndoManager];
    }
    return pvVar1_2;
}

- (void)setLastSelectedPaneIdentifier:(id)aIdentifier
{
    id pvVar1;

    if (_lastSelectedPaneIdentifier != aIdentifier) {
        pvVar1 = [aIdentifier copy];
        [_lastSelectedPaneIdentifier release];
        _lastSelectedPaneIdentifier = pvVar1;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f91ab @ 000f91ab, 633 bytes * /

void FUN_000f91ab(HSObjectAssistant *self,SEL _cmd,id setObject)

{
  id pvVar1;
  undefined *puVar2;
  undefined *puVar3;
  
  if (self->_object != setObject) {
    pvVar1 = _objc_msgSend(self->_currentPane,sel_respondsToSelector_,
                           sel_identifierForSelectedViewController);
    if ((char)pvVar1 != '\0') {
      puVar2 = &DAT_0036eeb8;
      pvVar1 = _objc_msgSend(self->_object,sel_queryHyperInterface_,&DAT_0036eeb8);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(self->_currentPane,sel_identifierForSelectedViewController,puVar2);
        _objc_msgSend(self,sel_setLastSelectedPaneIdentifier_,pvVar1);
      }
    }
    self->_suspendSwitchingDelegation = '\x01';
    _objc_msgSend(self,sel_setCurrentPane_,0);
    self->_suspendSwitchingDelegation = '\0';
    _objc_msgSend(self->_object,sel_release);
    pvVar1 = _objc_msgSend(setObject,sel_retain);
    self->_object = pvVar1;
    _objc_msgSend(self,sel_setPaneHistoryForObject_,pvVar1);
    pvVar1 = _objc_msgSend(self,sel_mainPane);
    _objc_msgSend(self,sel_setCurrentPane_,pvVar1);
    puVar2 = &DAT_0036f020;
    pvVar1 = _objc_msgSend(self->_object,sel_queryHyperInterface_,&DAT_0036f020);
    if (pvVar1 != self->_object) {
      puVar2 = &DAT_0036eeb8;
      pvVar1 = _objc_msgSend(self->_object,sel_queryHyperInterface_,&DAT_0036eeb8);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      if (((char)pvVar1 == '\0') &&
         (puVar3 = self->_lastSelectedPaneIdentifier, puVar3 != (undefined *)0x0)) {
        pvVar1 = _objc_msgSend(self,sel_currentPane,puVar2);
        puVar2 = sel_openPaneWithIdentifier_;
        pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_openPaneWithIdentifier_);
        if ((char)pvVar1 != '\0') {
          pvVar1 = _objc_msgSend(self,sel_currentPane,puVar2);
          puVar2 = sel_identifierForSelectedViewController;
          pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,
                                 sel_identifierForSelectedViewController);
          if ((char)pvVar1 != '\0') {
            pvVar1 = _objc_msgSend(self,sel_currentPane,puVar2);
            _objc_msgSend(pvVar1,sel_openPaneWithIdentifier_,puVar3);
            puVar2 = puVar3;
          }
        }
      }
    }
    _objc_msgSend(self,sel_notifyDidStartObjectEditing,puVar2);
    if (self->_object == (id)0x0) {
      _objc_msgSend(cls_NSObject,sel_cancelPreviousPerformRequestsWithTarget_selector_object_,self,
                    sel_applyGeometryChanges,0);
    }
  }
  return;
}

*/
- (void)setObject:(id)aObject
{
    if (_object == aObject) {
        return;
    }
    // Remember the selected tab so the next object opens on the same one.
    if ([_currentPane respondsToSelector:@selector(identifierForSelectedViewController)]
        && ![[_object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
        [self setLastSelectedPaneIdentifier:[(id)_currentPane identifierForSelectedViewController]];
    }
    _suspendSwitchingDelegation = YES;
    [self setCurrentPane:nil];
    _suspendSwitchingDelegation = NO;
    [_object release];
    _object = [aObject retain];
    [self setPaneHistoryForObject:_object];
    [self setCurrentPane:[self mainPane]];
    if ([_object queryHyperInterface:@protocol(HSRunTimeEditor)] != _object
        && ![[_object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
        NSString *identifier = _lastSelectedPaneIdentifier;
        if (identifier != nil
            && [[self currentPane] respondsToSelector:@selector(openPaneWithIdentifier:)]
            && [[self currentPane] respondsToSelector:@selector(identifierForSelectedViewController)]) {
            [[self currentPane] openPaneWithIdentifier:identifier];
        }
    }
    [self notifyDidStartObjectEditing];
    if (_object == nil) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(applyGeometryChanges) object:nil];
    }
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        if ([_window isVisible]) {
            [self updateReferenceToParentWindow];
        }
    }
}

- (void)setPaneHistoryForObject:(id)aObject
{
    id pvVar1_2;

    if (![_delegate respondsToSelector:@selector(objectAssistant:paneHistoryForObject:)]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [_delegate objectAssistant:self paneHistoryForObject:aObject];
    }
    [self setPaneHistory:pvVar1_2];
}

- (void)setPaneHistory:(id)aHistory
{
    [_paneHistory setArray:aHistory];
}

- (id)mainPane
{
    return [_paneHistory lastObject];
}

- (void)notifyDidStartObjectEditing
{
    if ([self isActive]) {
        if ([_delegate respondsToSelector:@selector(objectAssistantDidStartObjectEditing:)]) {
            [_delegate objectAssistantDidStartObjectEditing:self];
        }
    }
}

- (void)notifyDidFinishObjectEditing
{
    if (_object != nil) {
        if ([_delegate respondsToSelector:@selector(objectAssistantDidFinishObjectEditing:)]) {
            [_delegate objectAssistantDidFinishObjectEditing:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8f20 @ 000f8f20, 171 bytes * /

BOOL FUN_000f8f20(HSObjectAssistant *self,SEL _cmd)

{
  BOOL BVar1;
  id self_00;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_currentPane);
  pvVar2 = _objc_msgSend(self_00,sel_assistant);
  if ((pvVar2 != (id)0x0) && (self->_object != (id)0x0)) {
    pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_objectAssistantWillFinishObjectEditing_);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self->_delegate,sel_objectAssistantWillFinishObjectEditing_,self);
      BVar1 = (BOOL)pvVar2;
      goto LAB_000f8fa2;
    }
  }
  BVar1 = '\x01';
LAB_000f8fa2:
  _objc_msgSend(self_00,sel_setObject_,0);
  return BVar1;
}

*/
- (BOOL)notifyWillFinishObjectEditing
{
    id pane = [self currentPane];
    BOOL result = YES;
    if ([pane assistant] != nil && _object != nil
        && [_delegate respondsToSelector:@selector(objectAssistantWillFinishObjectEditing:)]) {
        result = [_delegate objectAssistantWillFinishObjectEditing:self];
    }
    [pane setObject:nil];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fb849 @ 000fb849, 917 bytes * /

void FUN_000fb849(HSObjectAssistant *self,SEL _cmd,id setCurrentPane)

{
  id pvVar1;
  HSObjectAssistantPane *pHVar2;
  id pvVar3;
  undefined4 uVar5;
  undefined8 uVar4;
  undefined8 local_24;
  undefined8 local_1c;
  
  if (self->_currentPane != setCurrentPane) {
    _objc_msgSend(self->_currentPane,sel_notifyViewWillDisappear_);
    pvVar1 = _objc_msgSend(self->_currentPane,sel_view);
    _objc_msgSend(pvVar1,sel_removeFromSuperview);
    _objc_msgSend(self->_currentPane,sel_notifyViewDidDisappear_);
    _objc_msgSend(self->_currentPane,sel_setObject_);
    _objc_msgSend(self->_currentPane,sel_setAssistant_);
    _objc_msgSend(self->_currentPane,sel_autorelease);
    pHVar2 = _objc_msgSend(setCurrentPane,sel_retain);
    self->_currentPane = pHVar2;
    _objc_msgSend(pHVar2,sel_invalidateLayout);
    _objc_msgSend(self->_currentPane,sel_layoutIfNeeded);
    _objc_msgSend(self->_currentPane,sel_setAssistant_);
    pHVar2 = self->_currentPane;
    _objc_msgSend(self,sel_object);
    _objc_msgSend(pHVar2,sel_setObject_);
    _objc_msgSend(self->_currentPane,sel_loadViewIfNeeded);
    _objc_msgSend(self->_currentPane,sel_notifyViewWillAppear_);
    pvVar1 = _objc_msgSend(self->_currentPane,sel_view);
    _objc_msgSend_stret(&local_24,self->_containerView,sel_bounds);
    _objc_msgSend(pvVar1,sel_setFrame_,local_24,local_1c);
    uVar5 = (undefined4)((ulonglong)local_24 >> 0x20);
    pvVar1 = self->_containerView;
    pvVar3 = _objc_msgSend(self->_currentPane,sel_view);
    _objc_msgSend(pvVar1,sel_addSubview_,pvVar3);
    pvVar1 = _objc_msgSend(self->_currentPane,sel_view);
    _objc_msgSend(pvVar1,sel_setAutoresizingMask_,0x12);
    uVar4 = CONCAT44(uVar5,1);
    _objc_msgSend(self->_currentPane,sel_notifyViewDidAppear_,1);
    _objc_msgSend(self->_currentPane,sel_showCoachingHelpIfNeeded);
    _objc_msgSend(self,sel_invalidateLayout);
    if ((self->_currentPane != (HSObjectAssistantPane *)0x0) && (self->_visible != '\0')) {
      _objc_msgSend(self,sel_updateAssistant,uVar4);
    }
    if (self->_visible != '\0') {
      pvVar1 = _objc_msgSend(self,sel_window);
      uVar4 = CONCAT44((int)((ulonglong)uVar4 >> 0x20),self);
      _objc_msgSend(pvVar1,sel_orderFront_,self);
    }
    pvVar1 = _objc_msgSend(self,sel_window,uVar4);
    uVar5 = (undefined4)((ulonglong)uVar4 >> 0x20);
    _objc_msgSend(pvVar1,sel_recalculateKeyViewLoop);
    pvVar1 = _objc_msgSend(self,sel_window);
    pvVar3 = _objc_msgSend(self->_currentPane,sel_initialKeyView);
    uVar4 = CONCAT44(uVar5,pvVar3);
    _objc_msgSend(pvVar1,sel_makeFirstResponder_,pvVar3);
    pvVar1 = _objc_msgSend(cls_NSApplication,sel_sharedApplication);
    pvVar1 = _objc_msgSend(pvVar1,sel_isActive);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(cls_NSApplication,sel_sharedApplication,uVar4);
      _objc_msgSend(pvVar1,sel_requestUserAttention_,0);
    }
  }
  return;
}

*/
- (void)setCurrentPane:(id)aPane
{
    if (_currentPane == aPane) {
        return;
    }
    [_currentPane notifyViewWillDisappear:YES];
    [[_currentPane view] removeFromSuperview];
    [_currentPane notifyViewDidDisappear:YES];
    [_currentPane setObject:nil];
    [_currentPane setAssistant:nil];
    [_currentPane autorelease];
    _currentPane = [aPane retain];
    [_currentPane invalidateLayout];
    [_currentPane layoutIfNeeded];
    [_currentPane setAssistant:self];
    [_currentPane setObject:[self object]];
    [_currentPane loadViewIfNeeded];
    [_currentPane notifyViewWillAppear:YES];
    [[_currentPane view] setFrame:[_containerView bounds]];
    [_containerView addSubview:[_currentPane view]];
    [(NSView *)[_currentPane view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_currentPane notifyViewDidAppear:YES];
    [_currentPane showCoachingHelpIfNeeded];
    [self invalidateLayout];
    if (_currentPane != nil && _visible) {
        [self updateAssistant];
    }
    if (_visible) {
        [[self window] orderFront:self];
    }
    [[self window] recalculateKeyViewLoop];
    [[self window] makeFirstResponder:[_currentPane initialKeyView]];
    if (![NSApp isActive]) {
        [NSApp requestUserAttention:NSCriticalRequest];
    }
}

- (id)currentPane
{
    return _currentPane;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fc71c @ 000fc71c, 332 bytes * /

void FUN_000fc71c(HSObjectAssistant *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined4 local_78;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar2 = _objc_msgSend(self,sel_layoutResult);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
  _objc_msgSend_stret(local_44,pvVar2,sel_rectValue);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(local_34,pvVar2,sel_frame);
  puVar3 = (undefined4 *)&stack0xffffff8c;
  local_78 = 0xfc7db;
  cVar1 = _NSEqualRects();
  local_78 = 0xfc7ef;
  pvVar2 = _objc_msgSend(self,sel_layoutResult);
  if (cVar1 == '\0') {
    local_78 = 0xfc80c;
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
    local_78 = 0xfc825;
    _objc_msgSend_stret(local_24,pvVar2,sel_rectValue);
    puVar3 = &local_78;
  }
  *puVar3 = self;
  puVar3[-1] = 0xfc860;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)layoutComposition
{
    NSRect layoutFrame = [[[self layoutResult] objectForKey:HSObjectAssistantLayoutWindowFrame] rectValue];
    if (!NSEqualRects(layoutFrame, [[self window] frame])) {
        [self setWindowFrame:[[[self layoutResult] objectForKey:HSObjectAssistantLayoutWindowFrame] rectValue]];
    } else {
        [self setupAnchorViewWithLayoutResult:[self layoutResult]];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)invalidateWindow
{
    [[self window] display];
    [[self window] invalidateShadow];
    [[self window] display];
    [self setShouldNotCoverObjectForAssistant:NO];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8e16 @ 000f8e16, 108 bytes * /

NSRect * FUN_000f8e16(NSRect *__return_storage_ptr__,HSObjectAssistant *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id self_00;
  NSRect *pNVar3;
  float extraout_EDX;
  
  fVar1 = (self->_inset).left;
  fVar2 = (self->_inset).bottom;
  self_00 = _objc_msgSend(self,sel_mainPane);
  pNVar3 = _objc_msgSend(self_00,sel_presentationSize);
  (__return_storage_ptr__->origin).x = fVar1;
  (__return_storage_ptr__->origin).y = fVar2;
  (__return_storage_ptr__->size).width = (float)pNVar3;
  (__return_storage_ptr__->size).height = extraout_EDX;
  return pNVar3;
}

*/
- (NSRect)containerViewFrame
{
    NSSize size = [[self mainPane] presentationSize];
    return NSMakeRect(_inset.left, _inset.bottom, size.width, size.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8da0 @ 000f8da0, 118 bytes * /

ulonglong FUN_000f8da0(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  float fVar3;
  
  pvVar1 = _objc_msgSend(self,sel_containerSize);
  fVar3 = (float)pvVar1 - (-(self->_inset).right - (self->_inset).left);
  if (fVar3 < 0.0) {
    fVar3 = 0.0;
  }
  fVar2 = extraout_EDX - (-(self->_inset).top - (self->_inset).bottom);
  if (fVar2 < 0.0) {
    fVar2 = 0.0;
  }
  return CONCAT44(fVar2,fVar3);
}

*/
- (NSSize)contentViewSize
{
    NSSize size = [self containerSize];
    CGFloat width = size.width + _inset.right + _inset.left;
    CGFloat height = size.height + _inset.top + _inset.bottom;
    return NSMakeSize(MAX(width, 0.0), MAX(height, 0.0));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8d08 @ 000f8d08, 152 bytes * /

ulonglong FUN_000f8d08(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float fVar3;
  float fVar4;
  
  pvVar1 = _objc_msgSend(self,sel_mainPane);
  pvVar2 = *(id *)(PTR_00336078 + 8);
  fVar4 = *(float *)(PTR_00336078 + 0xc);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_mainPane);
    pvVar2 = _objc_msgSend(pvVar2,sel_presentationSize);
    fVar4 = extraout_EDX;
  }
  pvVar1 = (id)0x438d0000;
  if (282.0 <= (float)pvVar2) {
    pvVar1 = pvVar2;
  }
  fVar3 = 202.0;
  if (202.0 <= fVar4) {
    fVar3 = fVar4;
  }
  return CONCAT44(fVar3,pvVar1);
}

*/
- (NSSize)containerSize
{
    NSSize size = NSZeroRect.size;
    if ([self mainPane] != nil) {
        size = [[self mainPane] presentationSize];
    }
    return NSMakeSize(MAX(size.width, 282.0), MAX(size.height, 202.0));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fb4de @ 000fb4de, 875 bytes * /

id FUN_000fb4de(HSObjectAssistant *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id self_01;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int extraout_EDX;
  int *piVar7;
  undefined8 local_64;
  undefined8 local_5c;
  undefined8 local_54;
  undefined8 local_4c;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [8];
  int local_1c;
  int local_18;
  
  if (self->_layoutIsValid == '\0') {
    self->_layoutIsCalculating = '\x01';
    pvVar2 = _objc_msgSend(self,sel_window);
    pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
    _objc_msgSend(self,sel_windowSize);
    pvVar2 = _objc_msgSend(pvVar2,sel_convertSize_toView_);
    self_00 = cls_NSMutableArray;
    puVar1 = cls_NSValue;
    pvVar3 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_window);
    _objc_msgSend_stret(local_44,pvVar3,sel_frame);
    piVar7 = (int *)&stack0xffffff30;
    _objc_msgSend(puVar1,sel_valueWithRect_);
    pvVar3 = _objc_msgSend(self_00,sel_arrayWithObject_);
    self_01 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar4 = _objc_msgSend(self->_delegate,sel_respondsToSelector_);
    puVar1 = cls_NSValue;
    if ((char)pvVar4 != '\0') {
      _objc_msgSend_stret(local_34,self->_delegate,sel_editorCardViewFrameForObjectAssistant_);
      piVar7 = (int *)&stack0xffffff2c;
      _objc_msgSend(puVar1,sel_valueWithRect_);
      _objc_msgSend(self_01,sel_addObject_);
    }
    pvVar4 = self->_delegate;
    piVar7[3] = (int)self;
    piVar7[2] = (int)sel_objectAssistantObjectScreenFrame_;
    piVar7[1] = (int)pvVar4;
    *piVar7 = (int)&local_54;
    piVar7[-1] = 0xfb6df;
    _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
    pvVar4 = self->_delegate;
    piVar7[2] = (int)self;
    piVar7[1] = (int)sel_editorCardViewFrameForObjectAssistant_;
    *piVar7 = (int)pvVar4;
    piVar7[-1] = (int)&local_64;
    piVar7[-2] = 0xfb705;
    _objc_msgSend_stret((void *)piVar7[-1],(id)*piVar7,(SEL)piVar7[1]);
    piVar7[-1] = (int)sel_window;
    piVar7[-2] = (int)self;
    piVar7[-3] = 0xfb71d;
    pvVar4 = _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
    *piVar7 = (int)sel_frame;
    piVar7[-1] = (int)pvVar4;
    piVar7[-2] = (int)local_24;
    piVar7[-3] = 0xfb736;
    _objc_msgSend_stret((void *)piVar7[-2],(id)piVar7[-1],(SEL)*piVar7);
    pvVar4 = self->_layoutResult;
    piVar7[-2] = (int)sel_currentLayout;
    piVar7[-3] = (int)self;
    piVar7[-4] = 0xfb765;
    pvVar5 = _objc_msgSend((id)piVar7[-3],(SEL)piVar7[-2]);
    piVar7[-2] = (int)sel_shouldNotCoverObjectForAssistant;
    piVar7[-3] = (int)self;
    piVar7[-4] = 0xfb77c;
    pvVar6 = _objc_msgSend((id)piVar7[-3],(SEL)piVar7[-2]);
    *(undefined8 *)(piVar7 + 5) = local_5c;
    *(undefined8 *)(piVar7 + 3) = local_64;
    *(undefined8 *)(piVar7 + 1) = local_4c;
    *(undefined8 *)(piVar7 + -1) = local_54;
    piVar7[0xe] = (int)pvVar4;
    piVar7[0xd] = (uint)pvVar6 & 0xff;
    piVar7[0xc] = (int)self_01;
    piVar7[0xb] = (int)pvVar3;
    piVar7[10] = local_18;
    piVar7[9] = local_1c;
    piVar7[8] = extraout_EDX;
    piVar7[7] = (int)pvVar2;
    piVar7[-2] = (int)
                 sel_layoutForObjectFrame_cardViewFrame_windowSize_currentWindowSize_primaryObstacleRects_secondaryObstacleRects_shouldNotCoverObjectForInspector_oldLayout_
    ;
    piVar7[-3] = (int)pvVar5;
    piVar7[-4] = 0xfb7ff;
    pvVar2 = _objc_msgSend((id)piVar7[-3],(SEL)piVar7[-2]);
    piVar7[-2] = (int)sel_retain;
    piVar7[-3] = (int)pvVar2;
    piVar7[-4] = 0xfb811;
    pvVar2 = _objc_msgSend((id)piVar7[-3],(SEL)piVar7[-2]);
    self->_layoutResult = pvVar2;
    piVar7[-2] = (int)sel_release;
    piVar7[-3] = (int)pvVar4;
    piVar7[-4] = 0xfb829;
    _objc_msgSend((id)piVar7[-3],(SEL)piVar7[-2]);
    self->_objectScreenFrameUpdated = '\0';
    self->_layoutIsCalculating = '\0';
    self->_layoutIsValid = '\x01';
  }
  return self->_layoutResult;
}

*/
- (id)layoutResult
{
    if (!_layoutIsValid) {
        _layoutIsCalculating = YES;
        NSSize windowSize = [[[self window] contentView] convertSize:[self windowSize] toView:nil];
        NSMutableArray *primaryObstacles = [NSMutableArray arrayWithObject:[NSValue valueWithRect:[[[HSToolPaletteController sharedInstance] window] frame]]];
        NSMutableArray *secondaryObstacles = [NSMutableArray array];
        // The original tests for -mainWindowFrameForObjectAssistant: but uses the card view frame.
        if ([_delegate respondsToSelector:@selector(mainWindowFrameForObjectAssistant:)]) {
            [secondaryObstacles addObject:[NSValue valueWithRect:[_delegate editorCardViewFrameForObjectAssistant:self]]];
        }
        NSRect objectFrame = [_delegate objectAssistantObjectScreenFrame:self];
        NSRect cardViewFrame = [_delegate editorCardViewFrameForObjectAssistant:self];
        NSRect currentWindowFrame = [[self window] frame];
        NSDictionary *oldLayout = _layoutResult;
        _layoutResult = [[[self currentLayout] layoutForObjectFrame:objectFrame
                                                      cardViewFrame:cardViewFrame
                                                         windowSize:windowSize
                                                  currentWindowSize:currentWindowFrame.size
                                               primaryObstacleRects:primaryObstacles
                                             secondaryObstacleRects:secondaryObstacles
                                   shouldNotCoverObjectForInspector:[self shouldNotCoverObjectForAssistant]
                                                          oldLayout:oldLayout] retain];
        [oldLayout release];
        _objectScreenFrameUpdated = NO;
        _layoutIsCalculating = NO;
        _layoutIsValid = YES;
    }
    return _layoutResult;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8cb5 @ 000f8cb5, 83 bytes * /

ulonglong FUN_000f8cb5(HSObjectAssistant *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  
  fVar2 = *(float *)PTR_DAT_0033651c + *(float *)PTR_DAT_0033651c;
  pvVar1 = _objc_msgSend(self,sel_contentViewSize);
  return CONCAT44(extraout_EDX + fVar2,(float)pvVar1 + fVar2);
}

*/
- (NSSize)windowSize
{
    CGFloat margin = HSObjectAssistantCompositionInset + HSObjectAssistantCompositionInset;
    NSSize size = [self contentViewSize];
    return NSMakeSize(size.width + margin, size.height + margin);
}

- (BOOL)isActive
{
    return _active;
}

@end

