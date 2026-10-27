#import "HSModeSwitcher.h"

@implementation HSModeSwitcher

/* i386 ivar offsets: _switching=0x4, _animation=0x8, _temporalStorage=0xc, _previousModeController=0x10, _activeModeController=0x14, _animatedWindow=0x18, _destinationViewFrame=0x1c, _destinationClipViewBoundsOrigin=0x2c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00131f75 @ 00131f75, 187 bytes * /

BOOL FUN_00131f75(HSModeSwitcher *self,SEL _cmd)

{
  id pvVar1;
  id *ppvVar2;
  id *ppvVar3;
  undefined4 uVar4;
  id local_18;
  id local_14;
  char local_d;
  
  local_d = '\0';
  local_14 = (id)0x0;
  local_18 = (id)0x0;
  _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_,0
                ,0,&local_d);
  if (local_d == '\0') {
    ppvVar3 = &local_18;
    ppvVar2 = &local_14;
    uVar4 = 0;
    _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_
                  ,ppvVar2,ppvVar3,0);
    pvVar1 = _objc_msgSend(local_14,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(local_18,sel_count,ppvVar2,ppvVar3,uVar4);
      return pvVar1 != (id)0x0;
    }
  }
  return '\0';
}

*/
- (BOOL)switchesAllWindows
{
    BOOL sameMainWindow = NO;
    id sourceWindows = nil;
    id destinationWindows = nil;
    [self getSwitchingSourceWindowsToRemove:NULL destinationWindowsToAdd:NULL sameMainWindow:&sameMainWindow];
    if (!sameMainWindow) {
        [self getSwitchingSourceWindowsToRemove:&sourceWindows destinationWindowsToAdd:&destinationWindows sameMainWindow:NULL];
        if ([sourceWindows count] != 0) {
            return [destinationWindows count] != 0;
        }
    }
    return NO;
}

- (id)previousModeController
{
    return _previousModeController;
}

- (BOOL)switching
{
    return _switching;
}

- (id)activeModeController
{
    return _activeModeController;
}

- (void)switchWithBlockingAnimationAnimationToModeController:(id)aController
{
    [self switchToModeController:aController animate:YES deffered:NO blocking:YES];
}

- (void)switchToModeController:(id)aController
{
    [self switchToModeController:aController animate:YES deffered:NO blocking:NO];
}

- (void)switchWithoutAnimationToModeController:(id)aController deffered:(BOOL)aDeffered
{
    [self switchToModeController:aController animate:NO deffered:aDeffered blocking:NO];
}

- (void)switchToModeController:(id)aController animate:(BOOL)aAnimate deffered:(BOOL)aDeffered blocking:(BOOL)aBlocking
{
    BOOL pvVar1_7;

    if ([self activeModeController] != aController) {
        if ([_animation isAnimating]) {
            [_animation stopAnimation];
        }
        [self setPreviousModeController:_activeModeController];
        [self setActiveModeController:aController];
        if ([_activeModeController respondsToSelector:@selector(setToolbarController:)]) {
            if ([_previousModeController respondsToSelector:@selector(toolbarController)]) {
                [_activeModeController setToolbarController:[_previousModeController toolbarController]];
            }
        }
        if ([_activeModeController respondsToSelector:@selector(setMainAreaTintedView:)]) {
            pvVar1_7 = [_previousModeController respondsToSelector:@selector(workAreaView)]
            ;
            if (pvVar1_7) {
                if ([_activeModeController respondsToSelector:@selector(setBottomAreaTintedView:)]) {
                    if ([_previousModeController respondsToSelector:@selector(bottomAreaTintedView)]) {
                        if ([_activeModeController respondsToSelector:@selector(setBottomToolbarVisible:)]) {
                            if ([_previousModeController respondsToSelector:@selector(isBottomToolbarVisible)]) {
                                [_activeModeController setWorkAreaView:[_previousModeController workAreaView]];
                                [_activeModeController setBottomAreaTintedView:[_previousModeController bottomAreaTintedView]];
                                [_activeModeController setMainAreaTintedView:[_previousModeController mainAreaTintedView]];
                                [_activeModeController setBottomToolbarVisible:[_previousModeController isBottomToolbarVisible]];
                            }
                        }
                    }
                }
            }
        }
        if ([_activeModeController respondsToSelector:@selector(setStatusbarController:)]) {
            if ([_previousModeController respondsToSelector:@selector(statusbarController)]) {
                [_activeModeController setStatusbarController:[_previousModeController statusbarController]];
            }
        }
        [self startSwitchAnimation:aAnimate deffered:aDeffered blocking:aBlocking];
    }
}

- (void)awakeFromInit
{
    [self notifyWillBecameWorkingInModeSwitcher];
    [self notifyDidBecomeWorkingInModeSwitcher];
}

- (void)dealloc
{
    [_animatedWindow release];
    [_animation release];
    [super dealloc];
}

- (id)initWithModeController:(id)aController
{
    self = [super init];
    if (self != nil) {
        _activeModeController = aController;
    }
    return self;
}

- (id)init
{
    return [self initWithModeController:nil];
}

- (void)animationDidEnd:(id)aEnd
{
    [self finalizeAnimation];
}

- (void)animationDidStop:(id)aStop
{
    [self finalizeAnimation];
}

- (BOOL)animationShouldStart:(id)aStart
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001318ca @ 001318ca, 469 bytes * /

void FUN_001318ca(HSModeSwitcher *self,SEL _cmd,BOOL startSwitchAnimation,BOOL deffered,
                 BOOL blocking)

{
  id pvVar1;
  SEL pcVar2;
  SEL op;
  undefined *puVar3;
  HSModeSwitcher *pHVar4;
  HSModeSwitcher *pHVar5;
  
  self->_switching = '\x01';
  pvVar1 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                         sel_modeSwitcherCardView_);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_previousModeController,sel_modeSwitcherCardView_,self);
    _objc_msgSend(pvVar1,sel_disableOpenGLSurfaceDetachingImmediately_,0);
    _objc_msgSend(pvVar1,sel_display);
  }
  puVar3 = sel_modeSwitcherCardView_;
  pvVar1 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                         sel_modeSwitcherCardView_);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_activeModeController,sel_modeSwitcherCardView_,self);
    puVar3 = (undefined *)0x0;
    _objc_msgSend(pvVar1,sel_disableOpenGLSurfaceDetachingImmediately_,0);
    _objc_msgSend(pvVar1,sel_display);
  }
  _objc_msgSend(self,sel_retainBeforeSwitching,puVar3);
  pHVar4 = (HSModeSwitcher *)sel_willBecameNonWorkingInModeSwitcher_;
  pvVar1 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                         sel_willBecameNonWorkingInModeSwitcher_);
  if ((char)pvVar1 != '\0') {
    pHVar4 = self;
    _objc_msgSend(self->_previousModeController,sel_willBecameNonWorkingInModeSwitcher_,self);
  }
  _objc_msgSend(self,sel_notifyWillBecameWorkingInModeSwitcher,pHVar4);
  if (startSwitchAnimation == '\0') {
    pcVar2 = sel_finalizeAnimation;
    op = sel_performSelectorOnMainThread_withObject_waitUntilDone_;
    pHVar5 = (HSModeSwitcher *)sel_finalizeAnimation;
    if (deffered != '\0') goto LAB_00131a92;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_switchesAllWindows,pHVar4);
    pcVar2 = sel_runSwitchingInSeparateWindows;
    if ((char)pvVar1 == '\0') {
      op = sel_runSwitchingInTheSameWindowWithBlockingMode_;
      pHVar5 = (HSModeSwitcher *)(uint)(blocking == '\0');
      goto LAB_00131a92;
    }
  }
  op = pcVar2;
  pHVar5 = pHVar4;
LAB_00131a92:
  _objc_msgSend(self,op,pHVar5);
  return;
}

*/
- (void)startSwitchAnimation:(BOOL)aAnimation deffered:(BOOL)aDeffered blocking:(BOOL)aBlocking
{
    NSEView *cardView;
    _switching = YES;
    if ([_previousModeController respondsToSelector:@selector(modeSwitcherCardView:)]) {
        cardView = [_previousModeController modeSwitcherCardView:self];
        [cardView disableOpenGLSurfaceDetachingImmediately:NO];
        [cardView display];
    }
    if ([_activeModeController respondsToSelector:@selector(modeSwitcherCardView:)]) {
        cardView = [_activeModeController modeSwitcherCardView:self];
        [cardView disableOpenGLSurfaceDetachingImmediately:NO];
        [cardView display];
    }
    [self retainBeforeSwitching];
    if ([_previousModeController respondsToSelector:@selector(willBecameNonWorkingInModeSwitcher:)]) {
        [_previousModeController willBecameNonWorkingInModeSwitcher:self];
    }
    [self notifyWillBecameWorkingInModeSwitcher];
    if (!aAnimation) {
        if (aDeffered) {
            [self performSelectorOnMainThread:@selector(finalizeAnimation) withObject:nil waitUntilDone:NO];
        }
        else {
            [self finalizeAnimation];
        }
    }
    else if ([self switchesAllWindows]) {
        [self runSwitchingInSeparateWindows];
    }
    else {
        [self runSwitchingInTheSameWindowWithBlockingMode:(aBlocking ? NSAnimationBlocking : NSAnimationNonblocking)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001316a4 @ 001316a4, 550 bytes * /

void FUN_001316a4(HSModeSwitcher *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id *ppvVar5;
  id *ppvVar6;
  char *pcVar7;
  id local_20;
  char local_19;
  id local_18;
  id local_14;
  
  local_14 = (id)0x0;
  local_18 = (id)0x0;
  local_19 = '\0';
  pcVar7 = &local_19;
  ppvVar6 = &local_18;
  ppvVar5 = &local_14;
  _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_,
                ppvVar5,ppvVar6,pcVar7);
  if (local_19 == '\0') {
    pvVar1 = _objc_msgSend(local_18,sel_count,ppvVar5,ppvVar6,pcVar7);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(local_14,sel_count,ppvVar5,ppvVar6,pcVar7);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(local_18,sel_count,ppvVar5,ppvVar6,pcVar7);
        if (pvVar1 != (id)0x0) {
          pvVar4 = (id)0x0;
          do {
            pvVar3 = pvVar4;
            self_00 = _objc_msgSend(local_18,sel_objectAtIndex_,pvVar4,ppvVar6);
            pvVar2 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
            pvVar2 = _objc_msgSend(pvVar2,sel_isOpenGLEnabled);
            if ((char)pvVar2 != '\0') {
              pvVar3 = _objc_msgSend(cls_NSEWindow,sel_class,pvVar3);
              pvVar3 = _objc_msgSend(self_00,sel_isKindOfClass_,pvVar3);
              if ((char)pvVar3 != '\0') {
                _objc_msgSend(self_00,sel_setHasOpaqueShapeShadow_,0);
              }
            }
            _objc_msgSend(self_00,sel_performSelector_,sel_hyperMakeTransparent);
            ppvVar6 = (id *)0x0;
            ppvVar5 = (id *)sel_hyperOrderFrontRespectingLastVisibilityState_;
            _objc_msgSend(self_00,sel_performSelector_withObject_,
                          sel_hyperOrderFrontRespectingLastVisibilityState_,0);
            pvVar4 = (id)((int)pvVar4 + 1);
          } while (pvVar4 < pvVar1);
        }
      }
    }
  }
  pvVar1 = _objc_msgSend(self,sel_switchesAllWindows,ppvVar5,ppvVar6,pcVar7);
  if ((char)pvVar1 != '\0') {
    local_20 = (id)0x0;
    ppvVar6 = &local_20;
    pcVar7 = (char *)0x0;
    _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_
                  ,0,ppvVar6,0);
  }
  pvVar1 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                         sel_willBecomeWorkingInModeSwitcher_,ppvVar6,pcVar7);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_activeModeController,sel_willBecomeWorkingInModeSwitcher_,self,ppvVar6,
                  pcVar7);
  }
  return;
}

*/
- (void)notifyWillBecameWorkingInModeSwitcher
{
    id sourceWindows = nil;
    id destinationWindows = nil;
    BOOL sameMainWindow = NO;
    NSUInteger count;
    NSUInteger i;
    id window;
    id unused = nil;
    [self getSwitchingSourceWindowsToRemove:&sourceWindows destinationWindowsToAdd:&destinationWindows sameMainWindow:&sameMainWindow];
    if (!sameMainWindow && [destinationWindows count] != 0 && [sourceWindows count] != 0) {
        count = [destinationWindows count];
        for (i = 0; i < count; i++) {
            window = [destinationWindows objectAtIndex:i];
            if ([[HSSystem sharedSystem] isOpenGLEnabled] && [window isKindOfClass:[NSEWindow class]]) {
                [window setHasOpaqueShapeShadow:NO];
            }
            [window performSelector:@selector(hyperMakeTransparent)];
            [window performSelector:@selector(hyperOrderFrontRespectingLastVisibilityState:) withObject:nil];
        }
    }
    if ([self switchesAllWindows]) {
        // The original fetches the destination windows again here and drops them.
        [self getSwitchingSourceWindowsToRemove:NULL destinationWindowsToAdd:&unused sameMainWindow:NULL];
    }
    if ([_activeModeController respondsToSelector:@selector(willBecomeWorkingInModeSwitcher:)]) {
        [_activeModeController willBecomeWorkingInModeSwitcher:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00132dba @ 00132dba, 877 bytes * /

void FUN_00132dba(HSModeSwitcher *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  longdouble lVar8;
  ulonglong uVar9;
  undefined4 uVar10;
  undefined4 uVar11;
  id local_18;
  id local_14;
  
  local_14 = (id)0x0;
  local_18 = (id)0x0;
  uVar11 = 0;
  _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_,
                &local_18,&local_14,0);
  pvVar1 = _objc_msgSend(self,sel_animationsForWindows_effect_,local_14,*(undefined4 *)PTR_003365ac)
  ;
  uVar10 = *(undefined4 *)PTR_0033654c;
  pvVar6 = pvVar1;
  pvVar2 = _objc_msgSend(self,sel_animationsForWindows_effect_,local_18,uVar10,uVar11,pvVar1);
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  uVar9 = CONCAT44(uVar10,pvVar1);
  pvVar1 = _objc_msgSend(self_00,sel_arrayWithCapacity_,pvVar1);
  pvVar3 = _objc_msgSend(self,sel_disableDestinationAnimation);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem,uVar9);
    pvVar3 = _objc_msgSend(pvVar3,sel_isOpenGLEnabled);
    uVar10 = (undefined4)(uVar9 >> 0x20);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(local_14,sel_count);
      uVar10 = (undefined4)(uVar9 >> 0x20);
      if (pvVar3 != (id)0x0) {
        pvVar7 = (id)0x0;
        do {
          uVar10 = (undefined4)(uVar9 >> 0x20);
          pvVar4 = _objc_msgSend(local_14,sel_objectAtIndex_,pvVar7);
          pvVar5 = _objc_msgSend(cls_NSEWindow,sel_class);
          uVar9 = CONCAT44(uVar10,pvVar5);
          pvVar5 = _objc_msgSend(pvVar4,sel_isKindOfClass_,pvVar5);
          if ((char)pvVar5 != '\0') {
            uVar9 = uVar9 & 0xffffffff00000000;
            _objc_msgSend(pvVar4,sel_setHasOpaqueShapeShadow_,0);
          }
          uVar10 = (undefined4)(uVar9 >> 0x20);
          pvVar7 = (id)((int)pvVar7 + 1);
        } while (pvVar7 < pvVar3);
      }
    }
    uVar9 = CONCAT44(uVar10,pvVar6);
    _objc_msgSend(pvVar1,sel_addObjectsFromArray_,pvVar6);
  }
  pvVar6 = _objc_msgSend(self,sel_disableSourceAnimation,uVar9);
  if ((char)pvVar6 == '\0') {
    pvVar6 = _objc_msgSend(cls_HSSystem,sel_sharedSystem,uVar9);
    pvVar6 = _objc_msgSend(pvVar6,sel_isOpenGLEnabled);
    uVar10 = (undefined4)(uVar9 >> 0x20);
    if ((char)pvVar6 != '\0') {
      pvVar6 = _objc_msgSend(local_18,sel_count);
      uVar10 = (undefined4)(uVar9 >> 0x20);
      if (pvVar6 != (id)0x0) {
        pvVar3 = (id)0x0;
        do {
          uVar10 = (undefined4)(uVar9 >> 0x20);
          pvVar7 = _objc_msgSend(local_18,sel_objectAtIndex_,pvVar3);
          pvVar4 = _objc_msgSend(cls_NSEWindow,sel_class);
          uVar9 = CONCAT44(uVar10,pvVar4);
          pvVar4 = _objc_msgSend(pvVar7,sel_isKindOfClass_,pvVar4);
          if ((char)pvVar4 != '\0') {
            uVar9 = uVar9 & 0xffffffff00000000;
            _objc_msgSend(pvVar7,sel_setHasOpaqueShapeShadow_,0);
          }
          uVar10 = (undefined4)(uVar9 >> 0x20);
          pvVar3 = (id)((int)pvVar3 + 1);
        } while (pvVar3 < pvVar6);
      }
    }
    uVar9 = CONCAT44(uVar10,pvVar2);
    _objc_msgSend(pvVar1,sel_addObjectsFromArray_,pvVar2);
  }
  pvVar6 = _objc_msgSend(cls_NSViewAnimation,sel_alloc,uVar9);
  pvVar6 = _objc_msgSend(pvVar6,sel_initWithViewAnimations_,pvVar1);
  pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
  _objc_msgSend(self,sel_setAnimation_,pvVar6);
  pvVar6 = self->_animation;
  lVar8 = (longdouble)_HSObjectAssistantAnimationDuration();
  _objc_msgSend(pvVar6,sel_setDuration_,(double)lVar8);
  _objc_msgSend(self->_animation,sel_setDelegate_,self);
  _objc_msgSend(self->_animation,sel_startAnimation);
  return;
}

*/
- (void)runSwitchingInSeparateWindows
{
    id sourceWindows = nil;
    id destinationWindows = nil;
    id fadeInAnimations;
    id fadeOutAnimations;
    NSMutableArray *animations;
    NSUInteger count;
    NSUInteger i;
    id window;
    [self getSwitchingSourceWindowsToRemove:&sourceWindows destinationWindowsToAdd:&destinationWindows sameMainWindow:NULL];
    fadeInAnimations = [self animationsForWindows:destinationWindows effect:NSViewAnimationFadeInEffect];
    fadeOutAnimations = [self animationsForWindows:sourceWindows effect:NSViewAnimationFadeOutEffect];
    animations = [NSMutableArray arrayWithCapacity:[fadeInAnimations count]];
    if (![self disableDestinationAnimation]) {
        if ([[HSSystem sharedSystem] isOpenGLEnabled]) {
            count = [destinationWindows count];
            for (i = 0; i < count; i++) {
                window = [destinationWindows objectAtIndex:i];
                if ([window isKindOfClass:[NSEWindow class]]) {
                    [window setHasOpaqueShapeShadow:NO];
                }
            }
        }
        [animations addObjectsFromArray:fadeInAnimations];
    }
    if (![self disableSourceAnimation]) {
        if ([[HSSystem sharedSystem] isOpenGLEnabled]) {
            count = [sourceWindows count];
            for (i = 0; i < count; i++) {
                window = [sourceWindows objectAtIndex:i];
                if ([window isKindOfClass:[NSEWindow class]]) {
                    [window setHasOpaqueShapeShadow:NO];
                }
            }
        }
        [animations addObjectsFromArray:fadeOutAnimations];
    }
    [self setAnimation:[[[NSViewAnimation alloc] initWithViewAnimations:animations] autorelease]];
    [_animation setDuration:HSObjectAssistantAnimationDuration()];
    [_animation setDelegate:self];
    [_animation startAnimation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00131649 @ 00131649, 91 bytes * /

BOOL FUN_00131649(HSModeSwitcher *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                         sel_shouldDisableAnimationInModeSwitcher_);
  if ((char)pvVar2 == '\0') {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self->_previousModeController,sel_shouldDisableAnimationInModeSwitcher_,
                           self);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)disableSourceAnimation
{
    if (![_previousModeController respondsToSelector:@selector(shouldDisableAnimationInModeSwitcher:)]) {
        return NO;
    }
    return (BOOL)(uintptr_t)[_previousModeController shouldDisableAnimationInModeSwitcher:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001315ee @ 001315ee, 91 bytes * /

BOOL FUN_001315ee(HSModeSwitcher *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                         sel_shouldDisableAnimationInModeSwitcher_);
  if ((char)pvVar2 == '\0') {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self->_activeModeController,sel_shouldDisableAnimationInModeSwitcher_,
                           self);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)disableDestinationAnimation
{
    if (![_activeModeController respondsToSelector:@selector(shouldDisableAnimationInModeSwitcher:)]) {
        return NO;
    }
    return (BOOL)(uintptr_t)[_activeModeController shouldDisableAnimationInModeSwitcher:self];
}

- (id)animationsForWindows:(id)aWindows effect:(id)aEffect
{
    id self_00;
    NSEnumerator *self_01;
    id pvVar3_2;

    self_00 = [NSMutableArray arrayWithCapacity:[aWindows count]];
    self_01 = [aWindows objectEnumerator];
    pvVar3_2 = [self_01 nextObject];
    while (pvVar3_2 != nil) {
        [self_00 addObject:[NSDictionary dictionaryWithObjectsAndKeys:pvVar3_2, NSViewAnimationTargetKey, aEffect, NSViewAnimationEffectKey, nil]];
        pvVar3_2 = [self_01 nextObject];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001312fe @ 001312fe, 490 bytes * /

void FUN_001312fe(HSModeSwitcher *self,SEL _cmd,uint runSwitchingInTheSameWindowWithBlockingMode)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_windowForAnimation);
  pvVar2 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar2 = _objc_msgSend(pvVar2,sel_isOpenGLEnabled);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_NSEWindow,sel_class);
    pvVar2 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(pvVar1,sel_setHasOpaqueShapeShadow_,0);
    }
  }
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar1,
                         *(undefined4 *)PTR_00336554,*(undefined4 *)PTR_003365ac,
                         *(undefined4 *)PTR_00336544,0);
  pvVar2 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pvVar1,0);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithViewAnimations_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(self,sel_setAnimation_,pvVar1);
  _objc_msgSend(self->_animation,sel_setDuration_,0x9999999a,0x3fb99999);
  _objc_msgSend(self->_animation,sel_setDelegate_,self);
  _objc_msgSend(self->_animation,sel_setAnimationBlockingMode_,
                runSwitchingInTheSameWindowWithBlockingMode);
  _objc_msgSend(self->_animation,sel_startAnimation);
  return;
}

*/
- (void)runSwitchingInTheSameWindowWithBlockingMode:(NSUInteger)aMode
{
    id window = [self windowForAnimation];
    NSDictionary *animation;
    if ([[HSSystem sharedSystem] isOpenGLEnabled] && [window isKindOfClass:[NSEWindow class]]) {
        [window setHasOpaqueShapeShadow:NO];
    }
    animation = [NSDictionary dictionaryWithObjectsAndKeys:window, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
    [self setAnimation:[[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:animation, nil]] autorelease]];
    [_animation setDuration:0.1];
    [_animation setDelegate:self];
    [_animation setAnimationBlockingMode:aMode];
    [_animation startAnimation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00131050 @ 00131050, 686 bytes * /

void FUN_00131050(HSModeSwitcher *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  id *ppvVar4;
  id *ppvVar5;
  char *pcVar6;
  char local_19;
  id local_18;
  id local_14;
  
  if (self->_switching == '\0') {
    return;
  }
  pvVar2 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                         sel_modeSwitcherCardView_);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self->_previousModeController,sel_modeSwitcherCardView_,self);
    _objc_msgSend(pvVar2,sel_enableOpenGLSurface);
    _objc_msgSend(pvVar2,sel_setNeedsDisplay_,1);
  }
  puVar3 = sel_modeSwitcherCardView_;
  pvVar2 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                         sel_modeSwitcherCardView_);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self->_activeModeController,sel_modeSwitcherCardView_,self);
    _objc_msgSend(pvVar2,sel_enableOpenGLSurface);
    puVar3 = (undefined *)0x1;
    _objc_msgSend(pvVar2,sel_setNeedsDisplay_,1);
  }
  pvVar2 = _objc_msgSend(self,sel_switchesAllWindows,puVar3);
  op = sel_finalizeSameWindow;
  if ((char)pvVar2 != '\0') {
    op = sel_finalizeSeparateWindows;
  }
  _objc_msgSend(self,op,puVar3);
  pvVar2 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                         sel_didBecomeNonWorkingInModeSwitcher_);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self->_previousModeController,sel_didBecomeNonWorkingInModeSwitcher_,self);
  }
  local_14 = (id)0x0;
  local_18 = (id)0x0;
  local_19 = '\0';
  pcVar6 = &local_19;
  ppvVar5 = &local_18;
  ppvVar4 = &local_14;
  _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_,
                ppvVar4,ppvVar5,pcVar6);
  cVar1 = local_19;
  pvVar2 = _objc_msgSend(local_14,sel_count);
  if (cVar1 == '\0') {
    if (pvVar2 == (id)0x0) goto LAB_00131246;
    pvVar2 = _objc_msgSend(local_18,sel_count,ppvVar4,ppvVar5,pcVar6);
  }
  if (pvVar2 != (id)0x0) {
    ppvVar5 = (id *)0x0;
    ppvVar4 = (id *)sel_hyperOrderOutWithSavingVisibilityState_;
    _objc_msgSend(local_14,sel_makeObjectsPerformSelector_withObject_,
                  sel_hyperOrderOutWithSavingVisibilityState_,0,pcVar6);
  }
LAB_00131246:
  _objc_msgSend(self,sel_notifyDidBecomeWorkingInModeSwitcher,ppvVar4,ppvVar5,pcVar6);
  puVar3 = PTR_00336058;
  _objc_msgSend(*(id *)PTR_00336058,sel_updateWindows);
  _objc_msgSend(*(id *)puVar3,sel_setWindowsNeedUpdate_,1);
  _objc_msgSend(self,sel_setAnimation_,0);
  _objc_msgSend(self,sel_releaseAfterSwitching);
  self->_switching = '\0';
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_postNotificationName_object_,
                PTR_cfstr_HSModeSwitcherDidEndModeSwitchingNotification_003424f0,self);
  return;
}

*/
- (void)finalizeAnimation
{
    id cardView;
    id sourceWindows = nil;
    id destinationWindows = nil;
    BOOL sameMainWindow = NO;
    NSUInteger count;
    if (!_switching) {
        return;
    }
    if ([_previousModeController respondsToSelector:@selector(modeSwitcherCardView:)]) {
        cardView = [_previousModeController modeSwitcherCardView:self];
        [cardView enableOpenGLSurface];
        [cardView setNeedsDisplay:YES];
    }
    if ([_activeModeController respondsToSelector:@selector(modeSwitcherCardView:)]) {
        cardView = [_activeModeController modeSwitcherCardView:self];
        [cardView enableOpenGLSurface];
        [cardView setNeedsDisplay:YES];
    }
    if ([self switchesAllWindows]) {
        [self finalizeSeparateWindows];
    }
    else {
        [self finalizeSameWindow];
    }
    if ([_previousModeController respondsToSelector:@selector(didBecomeNonWorkingInModeSwitcher:)]) {
        [_previousModeController didBecomeNonWorkingInModeSwitcher:self];
    }
    [self getSwitchingSourceWindowsToRemove:&sourceWindows destinationWindowsToAdd:&destinationWindows sameMainWindow:&sameMainWindow];
    count = [sourceWindows count];
    if (!sameMainWindow && count != 0) {
        count = [destinationWindows count];
    }
    if (count != 0) {
        [sourceWindows makeObjectsPerformSelector:@selector(hyperOrderOutWithSavingVisibilityState:) withObject:nil];
    }
    [self notifyDidBecomeWorkingInModeSwitcher];
    [NSApp updateWindows];
    [NSApp setWindowsNeedUpdate:YES];
    [self setAnimation:nil];
    [self releaseAfterSwitching];
    _switching = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSModeSwitcherDidEndModeSwitchingNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00130d58 @ 00130d58, 760 bytes * /

void FUN_00130d58(HSModeSwitcher *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  undefined *puVar6;
  HSModeSwitcher *pHVar7;
  id *ppvVar8;
  char *pcVar9;
  char local_19;
  id local_18;
  id local_14;
  
  local_14 = (id)0x0;
  local_18 = (id)0x0;
  local_19 = '\0';
  pcVar9 = &local_19;
  ppvVar8 = &local_18;
  _objc_msgSend(self,sel_getSwitchingSourceWindowsToRemove_destinationWindowsToAdd_sameMainWindow_,
                &local_14,ppvVar8,pcVar9);
  if (local_19 == '\0') {
    pvVar2 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                           sel_mainModeSwitcherWindow_,ppvVar8,pcVar9);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self->_activeModeController,sel_mainModeSwitcherWindow_,self,ppvVar8,
                             pcVar9);
      pvVar3 = _objc_msgSend(pvVar2,sel_isVisible);
      if ((char)pvVar3 != '\0') {
        _objc_msgSend(pvVar2,sel_makeKeyAndOrderFront_,0,ppvVar8,pcVar9);
        puVar6 = sel_hyperMakeNonTransparent;
        _objc_msgSend(pvVar2,sel_performSelector_,sel_hyperMakeNonTransparent);
        pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
        pvVar3 = _objc_msgSend(pvVar3,sel_isOpenGLEnabled);
        if ((char)pvVar3 != '\0') {
          pvVar3 = _objc_msgSend(cls_NSEWindow,sel_class,puVar6);
          pvVar3 = _objc_msgSend(pvVar2,sel_isKindOfClass_,pvVar3);
          if ((char)pvVar3 != '\0') {
            _objc_msgSend(pvVar2,sel_setHasOpaqueShapeShadow_,1);
          }
        }
      }
    }
  }
  pHVar7 = (HSModeSwitcher *)sel_didBecomeWorkingInModeSwitcher_;
  pvVar2 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                         sel_didBecomeWorkingInModeSwitcher_,ppvVar8,pcVar9);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self->_activeModeController,sel_didBecomeWorkingInModeSwitcher_,self,ppvVar8,
                  pcVar9);
    pHVar7 = self;
  }
  cVar1 = local_19;
  pvVar2 = _objc_msgSend(local_18,sel_count,pHVar7,ppvVar8,pcVar9);
  if (cVar1 == '\0') {
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(local_14,sel_count,pHVar7);
      if (pvVar2 != (id)0x0) {
        pvVar2 = _objc_msgSend(local_18,sel_count,pHVar7);
        if (pvVar2 != (id)0x0) {
          pvVar3 = (id)0x0;
          do {
            pvVar5 = pvVar3;
            self_00 = _objc_msgSend(local_18,sel_objectAtIndex_,pvVar3);
            pvVar4 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
            pvVar4 = _objc_msgSend(pvVar4,sel_isOpenGLEnabled);
            if ((char)pvVar4 != '\0') {
              pvVar5 = _objc_msgSend(cls_NSEWindow,sel_class,pvVar5);
              pvVar5 = _objc_msgSend(self_00,sel_isKindOfClass_,pvVar5);
              if ((char)pvVar5 != '\0') {
                _objc_msgSend(self_00,sel_setHasOpaqueShapeShadow_,1);
              }
            }
            _objc_msgSend(self_00,sel_performSelector_,sel_hyperMakeNonTransparent);
            pvVar3 = (id)((int)pvVar3 + 1);
          } while (pvVar3 < pvVar2);
        }
      }
    }
  }
  else if (pvVar2 != (id)0x0) {
    _objc_msgSend(local_18,sel_makeObjectsPerformSelector_withObject_,
                  sel_hyperOrderFrontRespectingLastVisibilityState_,0);
  }
  return;
}

*/
- (void)notifyDidBecomeWorkingInModeSwitcher
{
    id sourceWindows = nil;
    id destinationWindows = nil;
    BOOL sameMainWindow = NO;
    id mainWindow;
    NSUInteger count;
    NSUInteger i;
    id window;
    [self getSwitchingSourceWindowsToRemove:&sourceWindows destinationWindowsToAdd:&destinationWindows sameMainWindow:&sameMainWindow];
    if (!sameMainWindow && [_activeModeController respondsToSelector:@selector(mainModeSwitcherWindow:)]) {
        mainWindow = [_activeModeController mainModeSwitcherWindow:self];
        if ([mainWindow isVisible]) {
            [mainWindow makeKeyAndOrderFront:nil];
            [mainWindow performSelector:@selector(hyperMakeNonTransparent)];
            if ([[HSSystem sharedSystem] isOpenGLEnabled] && [mainWindow isKindOfClass:[NSEWindow class]]) {
                [mainWindow setHasOpaqueShapeShadow:YES];
            }
        }
    }
    if ([_activeModeController respondsToSelector:@selector(didBecomeWorkingInModeSwitcher:)]) {
        [_activeModeController didBecomeWorkingInModeSwitcher:self];
    }
    if (!sameMainWindow) {
        if ([destinationWindows count] != 0 && [sourceWindows count] != 0) {
            count = [destinationWindows count];
            for (i = 0; i < count; i++) {
                window = [destinationWindows objectAtIndex:i];
                if ([[HSSystem sharedSystem] isOpenGLEnabled] && [window isKindOfClass:[NSEWindow class]]) {
                    [window setHasOpaqueShapeShadow:YES];
                }
                [window performSelector:@selector(hyperMakeNonTransparent)];
            }
        }
    }
    else if ([destinationWindows count] != 0) {
        [destinationWindows makeObjectsPerformSelector:@selector(hyperOrderFrontRespectingLastVisibilityState:) withObject:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00132a3d @ 00132a3d, 893 bytes * /

void FUN_00132a3d(HSModeSwitcher *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id pvVar3;
  id self_02;
  id pvVar4;
  undefined4 *puVar5;
  undefined1 local_24 [20];
  
  puVar5 = (undefined4 *)&stack0xffffffa4;
  pvVar1 = _objc_msgSend(self,sel_switchingSourceView);
  self_00 = _objc_msgSend(self,sel_switchingDestinationView);
  self_01 = _objc_msgSend(pvVar1,sel_enclosingScrollView);
  pvVar2 = _objc_msgSend(self_01,sel_documentView);
  if (pvVar2 == pvVar1) {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar1,sel_superview);
  }
  self_02 = _objc_msgSend(self,sel_mainWindow);
  _objc_msgSend(self_02,sel_disableFlushWindow);
  pvVar4 = _objc_msgSend(pvVar1,sel_superview);
  if (pvVar4 != (id)0x0) {
    _objc_msgSend(pvVar1,sel_removeFromSuperviewWithoutNeedingDisplay);
  }
  pvVar4 = _objc_msgSend(self->_animatedWindow,sel_parentWindow);
  _objc_msgSend(pvVar4,sel_removeChildWindow_);
  pvVar4 = _objc_msgSend(self->_animatedWindow,sel_contentView);
  pvVar4 = _objc_msgSend(pvVar4,sel_subviews);
  pvVar4 = _objc_msgSend(pvVar4,sel_lastObject);
  pvVar4 = _objc_msgSend(pvVar4,sel_retain);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
  if (pvVar2 == pvVar1) {
    _objc_msgSend(self_00,sel_setFrame_);
    _objc_msgSend(self_01,sel_setDocumentView_);
    _objc_msgSend(cls_HSCardView,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_isKindOfClass_);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self_00,sel_autosizePreservingVisibleArea);
    }
    pvVar3 = _objc_msgSend(self_01,sel_contentView);
  }
  else {
    _objc_msgSend_stret(local_24,pvVar1,sel_frame);
    puVar5 = (undefined4 *)&stack0xffffffa0;
    _objc_msgSend(self_00,sel_setFrame_);
  }
  *puVar5 = pvVar3;
  puVar5[-1] = 0x132ce8;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  pvVar1 = self->_activeModeController;
  puVar5[2] = sel_modeSwitcherDidAddView_;
  puVar5[1] = sel_respondsToSelector_;
  *puVar5 = pvVar1;
  puVar5[-1] = 0x132d0a;
  pvVar1 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  if ((char)pvVar1 != '\0') {
    pvVar1 = self->_activeModeController;
    puVar5[2] = self;
    puVar5[1] = sel_modeSwitcherDidAddView_;
    *puVar5 = pvVar1;
    puVar5[-1] = 0x132d2a;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  }
  puVar5[1] = sel_enableFlushWindow;
  *puVar5 = self_02;
  puVar5[-1] = 0x132d3f;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[1] = sel_displayIfNeeded;
  *puVar5 = self_02;
  puVar5[-1] = 0x132d51;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  pvVar1 = self->_animatedWindow;
  puVar5[2] = self;
  puVar5[1] = sel_orderOut_;
  *puVar5 = pvVar1;
  puVar5[-1] = 0x132d6d;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[1] = sel_destinationWindowController;
  *puVar5 = self;
  puVar5[-1] = 0x132d7f;
  pvVar1 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[3] = pvVar1;
  puVar5[2] = self_02;
  puVar5[1] = sel_switchWindow_controller_;
  *puVar5 = self;
  puVar5[-1] = 0x132d99;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  pvVar1 = self->_animatedWindow;
  puVar5[2] = pvVar1;
  puVar5[1] = sel_makeFirstResponder_;
  *puVar5 = pvVar1;
  puVar5[-1] = 0x132db2;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)finalizeSameWindow
{
    NSView *sourceView = [self switchingSourceView];
    NSView *destinationView = [self switchingDestinationView];
    NSScrollView *scrollView = [sourceView enclosingScrollView];
    BOOL isDocumentView = [scrollView documentView] == sourceView;
    NSView *superview = isDocumentView ? nil : [sourceView superview];
    NSWindow *mainWindow = [self mainWindow];
    [mainWindow disableFlushWindow];
    if ([sourceView superview] != nil) {
        [sourceView removeFromSuperviewWithoutNeedingDisplay];
    }
    [[_animatedWindow parentWindow] removeChildWindow:_animatedWindow];
    [[[[[[_animatedWindow contentView] subviews] lastObject] retain] autorelease] removeFromSuperviewWithoutNeedingDisplay];
    if (isDocumentView) {
        [destinationView setFrame:_destinationViewFrame];
        [scrollView setDocumentView:destinationView];
        if ([destinationView isKindOfClass:[HSCardView class]]) {
            [(HSCardView *)destinationView autosizePreservingVisibleArea];
        }
        [[scrollView contentView] setBoundsOrigin:_destinationClipViewBoundsOrigin];
    }
    else {
        [destinationView setFrame:[sourceView frame]];
        [superview addSubview:destinationView];
    }
    if ([_activeModeController respondsToSelector:@selector(modeSwitcherDidAddView:)]) {
        [_activeModeController modeSwitcherDidAddView:self];
    }
    [mainWindow enableFlushWindow];
    [mainWindow displayIfNeeded];
    [_animatedWindow orderOut:self];
    [self switchWindow:mainWindow controller:[self destinationWindowController]];
    [_animatedWindow makeFirstResponder:_animatedWindow];
}

- (void)finalizeSeparateWindows
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00132030 @ 00132030, 2573 bytes * /

id FUN_00132030(HSModeSwitcher *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  NSPoint NVar5;
  NSPoint NVar6;
  NSPoint NVar7;
  NSPoint NVar8;
  undefined *puVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  id pvVar15;
  id pvVar16;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  undefined4 extraout_EDX_03;
  NSPoint *pNVar17;
  float *pfVar18;
  undefined4 uStack_124;
  id local_ec;
  id local_e8;
  float local_e4;
  float local_d8;
  float local_c4;
  float local_c0;
  float local_bc;
  float local_b8;
  undefined8 local_b4;
  undefined8 local_ac;
  id local_a4;
  float fStack_a0;
  float local_9c;
  float fStack_98;
  float local_94;
  float local_90;
  float local_8c;
  float local_88;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  id local_64;
  float fStack_60;
  float local_5c;
  float fStack_58;
  undefined1 local_54 [16];
  float local_44;
  float local_40;
  float local_34;
  float local_30;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar10 = _objc_msgSend(self,sel_mainWindow);
  pvVar11 = _objc_msgSend(self,sel_switchingSourceView);
  puVar9 = PTR_00336078;
  fVar1 = *(float *)PTR_00336078;
  fVar2 = *(float *)(PTR_00336078 + 4);
  pvVar12 = _objc_msgSend(self,sel_switchingDestinationView);
  fVar3 = *(float *)(puVar9 + 8);
  fVar4 = *(float *)(puVar9 + 0xc);
  local_64 = (id)fVar1;
  fStack_60 = fVar2;
  local_5c = fVar3;
  fStack_58 = fVar4;
  pvVar13 = _objc_msgSend(pvVar11,sel_enclosingScrollView);
  local_74 = fVar1;
  local_70 = fVar2;
  local_6c = fVar3;
  local_68 = fVar4;
  pvVar14 = _objc_msgSend(pvVar13,sel_documentView);
  if (pvVar14 == pvVar11) {
    pvVar15 = _objc_msgSend(pvVar13,sel_contentView);
    pvVar16 = _objc_msgSend(pvVar13,sel_contentView);
    _objc_msgSend_stret(local_54,pvVar16,sel_visibleRect);
    uStack_124 = 0x1321e5;
    _objc_msgSend_stret(&local_74,pvVar15,sel_convertRect_toView_);
    pNVar17 = (NSPoint *)&uStack_124;
  }
  else {
    _objc_msgSend_stret(&local_84,pvVar11,sel_frame);
    pNVar17 = (NSPoint *)&stack0xfffffee0;
    local_74 = local_84;
    local_70 = local_80;
    local_6c = local_7c;
    local_68 = local_78;
  }
  pNVar17[1].y = local_70;
  pNVar17[1].x = local_74;
  pNVar17->y = (float)sel_convertBaseToScreen_;
  pNVar17->x = (float)pvVar10;
  pNVar17[-1].y = 1.757209e-39;
  local_64 = _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
  local_5c = local_6c;
  fStack_58 = local_68;
  pvVar15 = self->_animatedWindow;
  fStack_60 = extraout_EDX;
  if (pvVar15 == (id)0x0) {
    pNVar17->y = (float)sel_alloc;
    pNVar17->x = (float)cls_NSWindow;
    pNVar17[-1].y = 1.757298e-39;
    pvVar15 = _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    NVar6.y = fStack_60;
    NVar6.x = (float)local_64;
    NVar7.y = fStack_58;
    NVar7.x = local_5c;
    pNVar17[2] = NVar7;
    pNVar17[1] = NVar6;
    pNVar17->y = (float)sel_initWithContentRect_styleMask_backing_defer_;
    pNVar17->x = (float)pvVar15;
    pNVar17[4].x = 0.0;
    pNVar17[3].y = 2.8026e-45;
    pNVar17[3].x = 0.0;
    pNVar17[-1].y = 1.757388e-39;
    pvVar15 = _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    self->_animatedWindow = pvVar15;
    pNVar17->y = (float)sel_useOptimizedDrawing_;
    pNVar17->x = (float)pvVar15;
    pNVar17[1].x = 1.4013e-45;
    pNVar17[-1].y = 1.757433e-39;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pvVar15 = self->_animatedWindow;
    pNVar17->y = (float)sel_setOpaque_;
    pNVar17->x = (float)pvVar15;
    pNVar17[1].x = 0.0;
    pNVar17[-1].y = 1.757478e-39;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pvVar15 = self->_animatedWindow;
    pNVar17->y = (float)sel_setReleasedWhenClosed_;
    pNVar17->x = (float)pvVar15;
    pNVar17[1].x = 0.0;
    pNVar17[-1].y = 1.757523e-39;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pvVar15 = self->_animatedWindow;
    pNVar17->y = (float)sel_whiteColor;
    pNVar17->x = (float)cls_NSColor;
    pNVar17[-1].y = 1.757565e-39;
    pvVar16 = _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pNVar17[1].x = (float)pvVar16;
    pNVar17->y = (float)sel_setBackgroundColor_;
    pNVar17->x = (float)pvVar15;
    pNVar17[-1].y = 1.757595e-39;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pvVar15 = self->_animatedWindow;
    pNVar17->y = (float)sel_setAlphaValue_;
    pNVar17->x = (float)pvVar15;
    pNVar17[1].x = 0.0;
  }
  else {
    pNVar17->y = (float)sel_setAlphaValue_;
    pNVar17->x = (float)pvVar15;
    pNVar17[1].x = 0.0;
    pNVar17[-1].y = 1.757672e-39;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pvVar15 = self->_animatedWindow;
    NVar5.y = fStack_60;
    NVar5.x = (float)local_64;
    NVar8.y = fStack_58;
    NVar8.x = local_5c;
    pNVar17[2] = NVar8;
    pNVar17[1] = NVar5;
    pNVar17->y = (float)sel_setFrame_display_;
    pNVar17->x = (float)pvVar15;
    pNVar17[3].x = 0.0;
    pNVar17[-1].y = 1.757748e-39;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pvVar15 = self->_animatedWindow;
    pNVar17->y = (float)sel_display;
    pNVar17->x = (float)pvVar15;
  }
  pNVar17[-1].y = 1.757778e-39;
  _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
  if (pvVar14 == pvVar11) {
    local_94 = *(float *)puVar9;
    local_90 = *(float *)(puVar9 + 4);
    pNVar17->y = (float)sel_disableFlushWindow;
    pNVar17->x = (float)pvVar10;
    pNVar17[-1].y = 1.757916e-39;
    local_8c = fVar3;
    local_88 = fVar4;
    _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pNVar17->y = (float)sel_contentView;
    pNVar17->x = (float)pvVar13;
    pNVar17[-1].y = 1.75795e-39;
    pvVar14 = _objc_msgSend((id)pNVar17->x,(SEL)pNVar17->y);
    pNVar17[1].x = (float)sel_bounds;
    pNVar17->y = (float)pvVar14;
    pNVar17->x = (float)&local_44;
    pNVar17[-1].y = 1.757985e-39;
    _objc_msgSend_stret((void *)pNVar17->x,(id)pNVar17->y,(SEL)pNVar17[1].x);
    pNVar17->y = (float)&DAT_00372c20;
    pNVar17->x = (float)sel_queryHyperInterface_;
    pNVar17[-1].y = (float)pvVar11;
    pNVar17[-1].x = 1.758073e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    if (pvVar14 == (id)0x0) {
      local_e8 = *(id *)PTR_0033607c;
      local_e4 = *(float *)(PTR_0033607c + 4);
    }
    else {
      pNVar17->x = (float)sel_cardOffset;
      pNVar17[-1].y = (float)pvVar14;
      pNVar17[-1].x = 1.758104e-39;
      local_e8 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
      local_e4 = extraout_EDX_00;
    }
    pNVar17->y = (float)pvVar12;
    pNVar17->x = (float)sel_setDocumentView_;
    pNVar17[-1].y = (float)pvVar13;
    pNVar17[-1].x = 1.758232e-39;
    _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    pNVar17->x = (float)sel_class;
    pNVar17[-1].y = (float)cls_HSCardView;
    pNVar17[-1].x = 1.758265e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    pNVar17->y = (float)pvVar14;
    pNVar17->x = (float)sel_isKindOfClass_;
    pNVar17[-1].y = (float)pvVar12;
    pNVar17[-1].x = 1.758296e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    if ((char)pvVar14 != '\0') {
      pNVar17->x = (float)sel_autosizePreservingVisibleArea;
      pNVar17[-1].y = (float)pvVar12;
      pNVar17[-1].x = 1.75833e-39;
      _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    }
    pNVar17->y = (float)&DAT_00372c20;
    pNVar17->x = (float)sel_queryHyperInterface_;
    pNVar17[-1].y = (float)pvVar12;
    pNVar17[-1].x = 1.758369e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    if (pvVar14 == (id)0x0) {
      local_ec = *(id *)PTR_0033607c;
      local_d8 = *(float *)(PTR_0033607c + 4);
    }
    else {
      pNVar17->x = (float)sel_cardOffset;
      pNVar17[-1].y = (float)pvVar14;
      pNVar17[-1].x = 1.7584e-39;
      local_ec = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
      local_d8 = extraout_EDX_01;
    }
    pNVar17->x = (float)sel_contentView;
    pNVar17[-1].y = (float)pvVar13;
    pNVar17[-1].x = 1.758558e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    pNVar17[1].x = (local_d8 - local_e4) + local_40;
    pNVar17->y = ((float)local_ec - (float)local_e8) + local_44;
    pNVar17->x = (float)sel_setBoundsOrigin_;
    pNVar17[-1].y = (float)pvVar14;
    pNVar17[-1].x = 1.758645e-39;
    _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    pNVar17->x = (float)sel_contentView;
    pNVar17[-1].y = (float)pvVar13;
    pNVar17[-1].x = 1.758679e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    pNVar17->y = (float)sel_bounds;
    pNVar17->x = (float)pvVar14;
    pNVar17[-1].y = (float)&local_34;
    pNVar17[-1].x = 1.758714e-39;
    _objc_msgSend_stret((void *)pNVar17[-1].y,(id)pNVar17->x,(SEL)pNVar17->y);
    (self->_destinationClipViewBoundsOrigin).x = local_34;
    (self->_destinationClipViewBoundsOrigin).y = local_30;
    pNVar17->x = (float)sel_frame;
    pNVar17[-1].y = (float)pvVar12;
    pNVar17[-1].x = (float)&local_c4;
    pNVar17[-2].y = 1.758798e-39;
    _objc_msgSend_stret((void *)pNVar17[-1].x,(id)pNVar17[-1].y,(SEL)pNVar17->x);
    (self->_destinationViewFrame).origin.x = local_c4;
    (self->_destinationViewFrame).origin.y = local_c0;
    (self->_destinationViewFrame).size.width = local_bc;
    (self->_destinationViewFrame).size.height = local_b8;
    pNVar17[-1].x = (float)sel_superview;
    pNVar17[-2].y = (float)pvVar12;
    pNVar17[-2].x = 1.7589e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-2].y,(SEL)pNVar17[-1].x);
    NVar5 = (self->_destinationViewFrame).origin;
    *(NSSize *)(pNVar17 + 1) = (self->_destinationViewFrame).size;
    *pNVar17 = NVar5;
    pNVar17[-1].y = (float)sel_convertRect_toView_;
    pNVar17[-1].x = (float)pvVar14;
    pNVar17[-2].y = (float)&local_94;
    pNVar17[2].x = 0.0;
    pNVar17[-2].x = 1.758981e-39;
    _objc_msgSend_stret((void *)pNVar17[-2].y,(id)pNVar17[-1].x,(SEL)pNVar17[-1].y);
    pNVar17[-1].x = (float)pvVar11;
    pNVar17[-2].y = (float)sel_setDocumentView_;
    pNVar17[-2].x = (float)pvVar13;
    pNVar17[-3].y = 1.759033e-39;
    _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    pNVar17[-2].y = (float)sel_class;
    pNVar17[-2].x = (float)cls_HSCardView;
    pNVar17[-3].y = 1.759067e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    pNVar17[-1].x = (float)pvVar14;
    pNVar17[-2].y = (float)sel_isKindOfClass_;
    pNVar17[-2].x = (float)pvVar11;
    pNVar17[-3].y = 1.759098e-39;
    pvVar14 = _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    if ((char)pvVar14 != '\0') {
      pNVar17[-2].y = (float)sel_autosizePreservingVisibleArea;
      pNVar17[-2].x = (float)pvVar11;
      pNVar17[-3].y = 1.759131e-39;
      _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    }
    pNVar17[-2].y = (float)sel_contentView;
    pNVar17[-2].x = (float)pvVar13;
    pNVar17[-3].y = 1.759165e-39;
    pvVar11 = _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    pNVar17[-1].y = local_40;
    pNVar17[-1].x = local_44;
    pNVar17[-2].y = (float)sel_setBoundsOrigin_;
    pNVar17[-2].x = (float)pvVar11;
    pNVar17[-3].y = 1.75923e-39;
    _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    pNVar17[-2].y = (float)sel_enableFlushWindow;
    pNVar17[-2].x = (float)pvVar10;
    pNVar17[-3].y = 1.759263e-39;
    _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    pNVar17[-1].y = local_90;
    pNVar17[-1].x = local_94;
    pNVar17[-2].y = (float)sel_convertBaseToScreen_;
    pNVar17[-2].x = (float)pvVar10;
    pNVar17[-3].y = 1.759327e-39;
    pvVar13 = _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    local_a4 = (id)local_94;
    fStack_a0 = local_90;
    local_9c = local_8c;
    fStack_98 = local_88;
    pvVar11 = self->_animatedWindow;
    pNVar17[-1].y = extraout_EDX_02;
    pNVar17[-1].x = (float)pvVar13;
    pNVar17[-2].y = (float)sel_convertScreenToBase_;
    pNVar17[-2].x = (float)pvVar11;
    pNVar17[-3].y = 1.759462e-39;
    local_a4 = _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    pvVar11 = self->_animatedWindow;
    pNVar17[-2].y = (float)sel_contentView;
    pNVar17[-2].x = (float)pvVar11;
    pNVar17[-3].y = 1.759512e-39;
    fStack_a0 = (float)extraout_EDX_03;
    pvVar11 = _objc_msgSend((id)pNVar17[-2].x,(SEL)pNVar17[-2].y);
    *(ulonglong *)&pNVar17->y = CONCAT44(fStack_98,local_9c);
    *(ulonglong *)&pNVar17[-1].y = CONCAT44(fStack_a0,local_a4);
    pNVar17[-1].x = (float)sel_convertRect_fromView_;
    pNVar17[-2].y = (float)pvVar11;
    pNVar17[-2].x = (float)&local_b4;
    pNVar17[1].y = 0.0;
    pNVar17[-3].y = 1.759602e-39;
    _objc_msgSend_stret((void *)pNVar17[-2].x,(id)pNVar17[-2].y,(SEL)pNVar17[-1].x);
    pfVar18 = &pNVar17[-3].y;
    *(undefined8 *)&pNVar17[-1].y = local_ac;
    *(undefined8 *)&pNVar17[-2].y = local_b4;
    pNVar17[-2].x = (float)sel_setFrame_;
    pNVar17[-3].y = (float)pvVar12;
    pNVar17[-3].x = 1.759679e-39;
    _objc_msgSend((id)pNVar17[-3].y,(SEL)pNVar17[-2].x);
    pvVar11 = self->_animatedWindow;
  }
  else {
    pNVar17[1].x = (float)sel_frame;
    pNVar17->y = (float)pvVar11;
    pNVar17->x = (float)&local_24;
    pNVar17[-1].y = 1.759734e-39;
    _objc_msgSend_stret((void *)pNVar17->x,(id)pNVar17->y,(SEL)pNVar17[1].x);
    pfVar18 = &pNVar17[-1].y;
    *(undefined8 *)&pNVar17[1].y = local_1c;
    *(undefined8 *)&pNVar17->y = local_24;
    pNVar17->x = (float)sel_setFrame_;
    pNVar17[-1].y = (float)pvVar12;
    pNVar17[-1].x = 1.759802e-39;
    _objc_msgSend((id)pNVar17[-1].y,(SEL)pNVar17->x);
    pvVar11 = self->_animatedWindow;
  }
  pfVar18[1] = (float)sel_contentView;
  *pfVar18 = (float)pvVar11;
  pfVar18[-1] = 1.759836e-39;
  pvVar11 = _objc_msgSend((id)*pfVar18,(SEL)pfVar18[1]);
  pfVar18[2] = (float)pvVar12;
  pfVar18[1] = (float)sel_addSubview_;
  *pfVar18 = (float)pvVar11;
  pfVar18[-1] = 1.759867e-39;
  _objc_msgSend((id)*pfVar18,(SEL)pfVar18[1]);
  pvVar11 = self->_animatedWindow;
  pfVar18[1] = (float)sel_setAlphaValue_;
  *pfVar18 = (float)pvVar11;
  pfVar18[2] = 0.0;
  pfVar18[-1] = 1.759912e-39;
  _objc_msgSend((id)*pfVar18,(SEL)pfVar18[1]);
  pvVar11 = self->_animatedWindow;
  pfVar18[1] = (float)sel_orderFront_;
  *pfVar18 = (float)pvVar11;
  pfVar18[2] = 0.0;
  pfVar18[-1] = 1.759952e-39;
  _objc_msgSend((id)*pfVar18,(SEL)pfVar18[1]);
  pfVar18[2] = (float)self->_animatedWindow;
  pfVar18[1] = (float)sel_addChildWindow_ordered_;
  *pfVar18 = (float)pvVar10;
  pfVar18[3] = 1.4013e-45;
  pfVar18[-1] = 1.760007e-39;
  _objc_msgSend((id)*pfVar18,(SEL)pfVar18[1]);
  return self->_animatedWindow;
}

*/
- (id)windowForAnimation
{
    NSWindow *mainWindow = [self mainWindow];
    NSView *sourceView = [self switchingSourceView];
    NSView *destinationView = [self switchingDestinationView];
    NSScrollView *scrollView = [sourceView enclosingScrollView];
    BOOL isDocumentView = [scrollView documentView] == sourceView;
    NSRect sourceRect;
    NSRect screenRect;
    NSRect destinationRect;
    NSRect clipBounds;
    NSSize sourceOffset;
    NSSize destinationOffset;
    id host;
    if (isDocumentView) {
        sourceRect = [[scrollView contentView] convertRect:[[scrollView contentView] visibleRect] toView:nil];
    }
    else {
        sourceRect = [sourceView frame];
    }
    // -convertBaseToScreen: on the origin in the original.
    screenRect.origin = [mainWindow convertRectToScreen:NSMakeRect(sourceRect.origin.x, sourceRect.origin.y, 0, 0)].origin;
    screenRect.size = sourceRect.size;
    if (_animatedWindow == nil) {
        _animatedWindow = [[NSWindow alloc] initWithContentRect:screenRect styleMask:0 backing:NSBackingStoreBuffered defer:NO];
        [_animatedWindow useOptimizedDrawing:YES];
        [_animatedWindow setOpaque:NO];
        [_animatedWindow setReleasedWhenClosed:NO];
        [_animatedWindow setBackgroundColor:[NSColor whiteColor]];
        [_animatedWindow setAlphaValue:0.0];
    }
    else {
        [_animatedWindow setAlphaValue:0.0];
        [_animatedWindow setFrame:screenRect display:NO];
        [_animatedWindow display];
    }
    if (isDocumentView) {
        [mainWindow disableFlushWindow];
        clipBounds = [[scrollView contentView] bounds];
        host = [sourceView queryHyperInterface:@protocol(HSEditorCardViewBackgroundHost)];
        sourceOffset = host != nil ? [host cardOffset] : NSZeroSize;
        [scrollView setDocumentView:destinationView];
        if ([destinationView isKindOfClass:[HSCardView class]]) {
            [(HSCardView *)destinationView autosizePreservingVisibleArea];
        }
        host = [destinationView queryHyperInterface:@protocol(HSEditorCardViewBackgroundHost)];
        destinationOffset = host != nil ? [host cardOffset] : NSZeroSize;
        [[scrollView contentView] setBoundsOrigin:NSMakePoint(destinationOffset.width - sourceOffset.width + clipBounds.origin.x, destinationOffset.height - sourceOffset.height + clipBounds.origin.y)];
        _destinationClipViewBoundsOrigin = [[scrollView contentView] bounds].origin;
        _destinationViewFrame = [destinationView frame];
        destinationRect = [[destinationView superview] convertRect:_destinationViewFrame toView:nil];
        [scrollView setDocumentView:sourceView];
        if ([sourceView isKindOfClass:[HSCardView class]]) {
            [(HSCardView *)sourceView autosizePreservingVisibleArea];
        }
        [[scrollView contentView] setBoundsOrigin:clipBounds.origin];
        [mainWindow enableFlushWindow];
        // -convertBaseToScreen: / -convertScreenToBase: in the original.
        destinationRect.origin = [mainWindow convertRectToScreen:NSMakeRect(destinationRect.origin.x, destinationRect.origin.y, 0, 0)].origin;
        destinationRect.origin = [_animatedWindow convertRectFromScreen:NSMakeRect(destinationRect.origin.x, destinationRect.origin.y, 0, 0)].origin;
        [destinationView setFrame:[[_animatedWindow contentView] convertRect:destinationRect fromView:nil]];
    }
    else {
        [destinationView setFrame:[sourceView frame]];
    }
    [[_animatedWindow contentView] addSubview:destinationView];
    [_animatedWindow setAlphaValue:0.0];
    [_animatedWindow orderFront:nil];
    [mainWindow addChildWindow:_animatedWindow ordered:NSWindowAbove];
    return _animatedWindow;
}

- (void)setAnimation:(id)aAnimation
{
    if (_animation != aAnimation) {
        [_animation autorelease];
        _animation = [aAnimation retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00130b8f @ 00130b8f, 382 bytes * /

void FUN_00130b8f(HSModeSwitcher *self,SEL _cmd,id switchWindow,id controller)

{
  id pvVar1;
  HSModeSwitcher *pHVar2;
  
  pvVar1 = _objc_msgSend(switchWindow,sel_windowController);
  if (pvVar1 != controller) {
    pHVar2 = (HSModeSwitcher *)sel_windowControllerWillUnbindFromWindowInModeSwitcher_;
    pvVar1 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                           sel_windowControllerWillUnbindFromWindowInModeSwitcher_);
    if ((char)pvVar1 != '\0') {
      pHVar2 = self;
      _objc_msgSend(self->_previousModeController,
                    sel_windowControllerWillUnbindFromWindowInModeSwitcher_,self);
    }
    pvVar1 = _objc_msgSend(switchWindow,sel_retain,pHVar2);
    _objc_msgSend(pvVar1,sel_autorelease);
    pvVar1 = _objc_msgSend(switchWindow,sel_windowController);
    _objc_msgSend(pvVar1,sel_setShouldCloseDocument_,0);
    pvVar1 = _objc_msgSend(switchWindow,sel_windowController);
    _objc_msgSend(pvVar1,sel_setWindow_,0);
    _objc_msgSend(controller,sel_setWindow_,switchWindow);
    _objc_msgSend(controller,sel_setShouldCloseDocument_,1);
    _objc_msgSend(switchWindow,sel_setDelegate_,controller);
    pvVar1 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                           sel_windowControllerDidBindToWindowInModeSwitcher_);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self->_activeModeController,sel_windowControllerDidBindToWindowInModeSwitcher_,
                    self);
    }
  }
  return;
}

*/
- (void)switchWindow:(id)aWindow controller:(id)aController
{
    if ([aWindow windowController] != aController) {
        if ([_previousModeController respondsToSelector:@selector(windowControllerWillUnbindFromWindowInModeSwitcher:)]) {
            [_previousModeController windowControllerWillUnbindFromWindowInModeSwitcher:self];
        }
        [[aWindow retain] autorelease];
        [[aWindow windowController] setShouldCloseDocument:NO];
        [[aWindow windowController] setWindow:nil];
        [aController setWindow:aWindow];
        [aController setShouldCloseDocument:YES];
        [aWindow setDelegate:aController];
        if ([_activeModeController respondsToSelector:@selector(windowControllerDidBindToWindowInModeSwitcher:)]) {
            [_activeModeController windowControllerDidBindToWindowInModeSwitcher:self];
        }
    }
}

- (void)setPreviousModeController:(id)aController
{
    if (_previousModeController != aController) {
        _previousModeController = aController;
    }
}

- (void)setActiveModeController:(id)aController
{
    if (_activeModeController != aController) {
        if ([_activeModeController respondsToSelector:@selector(willResignActiveInModeSwitcher:)]) {
            [_activeModeController willResignActiveInModeSwitcher:self];
        }
        _activeModeController = aController;
        if ([aController respondsToSelector:@selector(didBecomeActiveInModeSwitcher:)]) {
            [_activeModeController didBecomeActiveInModeSwitcher:self];
        }
    }
}

- (void)releaseAfterSwitching
{
    [self setTemporalStorage:nil];
}

- (void)retainBeforeSwitching
{
    id pvVar1;
    id pvVar2;
    id pvVar3;
    id pvVar5;

    pvVar2 = [self switchingDestinationView];
    pvVar3 = [self switchingSourceView];
    pvVar5 = _previousModeController;
    pvVar1 = _activeModeController;
    [self setTemporalStorage:[NSSet setWithObjects:self, [self mainWindow], pvVar5, pvVar1, pvVar3, pvVar2, nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00130572 @ 00130572, 1173 bytes * /

void FUN_00130572(HSModeSwitcher *self,SEL _cmd,id *getSwitchingSourceWindowsToRemove,
                 id *destinationWindowsToAdd,BOOL *sameMainWindow)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  HSModeSwitcher *pHVar4;
  id pvVar5;
  uint uVar6;
  uint uVar7;
  HSModeSwitcher *pHVar8;
  undefined4 uVar9;
  
  pvVar2 = _objc_msgSend(self,sel_switchingSourceView);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_switchingDestinationView);
    if (pvVar2 != (id)0x0) {
      if (getSwitchingSourceWindowsToRemove != (id *)0x0 || destinationWindowsToAdd != (id *)0x0) {
        pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
        pHVar8 = (HSModeSwitcher *)sel_secondaryModeSwitcherWindows_;
        pvVar3 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                               sel_secondaryModeSwitcherWindows_);
        if ((char)pvVar3 != '\0') {
          pHVar8 = self;
          pHVar4 = _objc_msgSend(self->_previousModeController,sel_secondaryModeSwitcherWindows_,
                                 self);
          pvVar3 = _objc_msgSend(pHVar4,sel_count);
          if (pvVar3 != (id)0x0) {
            _objc_msgSend(pvVar2,sel_addObjectsFromArray_,pHVar4);
            pHVar8 = pHVar4;
          }
        }
        pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array,pHVar8);
        pHVar8 = (HSModeSwitcher *)sel_secondaryModeSwitcherWindows_;
        pvVar5 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                               sel_secondaryModeSwitcherWindows_);
        if ((char)pvVar5 != '\0') {
          pHVar8 = self;
          pHVar4 = _objc_msgSend(self->_activeModeController,sel_secondaryModeSwitcherWindows_,self)
          ;
          pvVar5 = _objc_msgSend(pHVar4,sel_count);
          if (pvVar5 != (id)0x0) {
            _objc_msgSend(pvVar3,sel_addObjectsFromArray_,pHVar4);
            pHVar8 = pHVar4;
          }
        }
        pvVar5 = _objc_msgSend(pvVar2,sel_count,pHVar8);
        uVar6 = 0;
        uVar7 = (int)pvVar5 + 1;
        while (uVar6 < uVar7 - 1) {
          pvVar5 = _objc_msgSend(pvVar2,sel_objectAtIndex_,uVar6);
          pvVar5 = _objc_msgSend(pvVar3,sel_indexOfObjectIdenticalTo_,pvVar5);
          if (pvVar5 == (id)0x7fffffff) {
            uVar6 = uVar6 + 1;
          }
          else {
            _objc_msgSend(pvVar3,sel_removeObjectAtIndex_,pvVar5);
            _objc_msgSend(pvVar2,sel_removeObjectAtIndex_,uVar6);
            uVar7 = uVar7 - 1;
          }
        }
        _objc_msgSend(self,sel_removeWinodwsThatAreVisible_fromArray_,0,pvVar2);
        _objc_msgSend(self,sel_removeWinodwsThatAreVisible_fromArray_,1,pvVar3);
        if (getSwitchingSourceWindowsToRemove != (id *)0x0) {
          *getSwitchingSourceWindowsToRemove = pvVar2;
        }
        if (destinationWindowsToAdd != (id *)0x0) {
          *destinationWindowsToAdd = pvVar3;
        }
      }
      BVar1 = '\x01';
      goto LAB_001309f4;
    }
  }
  if (getSwitchingSourceWindowsToRemove != (id *)0x0) {
    pvVar2 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                           sel_mainModeSwitcherWindow_);
    if ((char)pvVar2 == '\0') {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(self->_previousModeController,sel_mainModeSwitcherWindow_,self);
    }
    uVar9 = 0;
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithObjects_,pvVar2,0);
    pvVar3 = _objc_msgSend(self->_previousModeController,sel_respondsToSelector_,
                           sel_secondaryModeSwitcherWindows_);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(self->_previousModeController,sel_secondaryModeSwitcherWindows_,self,
                             uVar9);
      pvVar5 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar5 != (id)0x0) {
        _objc_msgSend(pvVar2,sel_addObjectsFromArray_,pvVar3,uVar9);
      }
    }
    *getSwitchingSourceWindowsToRemove = pvVar2;
  }
  if (destinationWindowsToAdd != (id *)0x0) {
    pvVar2 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                           sel_mainModeSwitcherWindow_);
    if ((char)pvVar2 == '\0') {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(self->_activeModeController,sel_mainModeSwitcherWindow_,self);
    }
    uVar9 = 0;
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithObjects_,pvVar2,0);
    pvVar3 = _objc_msgSend(self->_activeModeController,sel_respondsToSelector_,
                           sel_secondaryModeSwitcherWindows_);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(self->_activeModeController,sel_secondaryModeSwitcherWindows_,self,
                             uVar9);
      pvVar5 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar5 != (id)0x0) {
        _objc_msgSend(pvVar2,sel_addObjectsFromArray_,pvVar3,uVar9);
      }
    }
    *destinationWindowsToAdd = pvVar2;
  }
  BVar1 = '\0';
LAB_001309f4:
  if (sameMainWindow != (BOOL *)0x0) {
    *sameMainWindow = BVar1;
  }
  return;
}

*/
- (void)getSwitchingSourceWindowsToRemove:(id *)aRemove destinationWindowsToAdd:(id *)aAdd sameMainWindow:(BOOL *)aWindow
{
    BOOL sameMainWindow = NO;
    NSMutableArray *sourceWindows;
    NSMutableArray *destinationWindows;
    id windows;
    NSUInteger count;
    NSUInteger i;
    NSUInteger index;
    if ([self switchingSourceView] != nil && [self switchingDestinationView] != nil) {
        if (aRemove != NULL || aAdd != NULL) {
            sourceWindows = [NSMutableArray array];
            if ([_previousModeController respondsToSelector:@selector(secondaryModeSwitcherWindows:)]) {
                windows = [_previousModeController secondaryModeSwitcherWindows:self];
                if ([windows count] != 0) {
                    [sourceWindows addObjectsFromArray:windows];
                }
            }
            destinationWindows = [NSMutableArray array];
            if ([_activeModeController respondsToSelector:@selector(secondaryModeSwitcherWindows:)]) {
                windows = [_activeModeController secondaryModeSwitcherWindows:self];
                if ([windows count] != 0) {
                    [destinationWindows addObjectsFromArray:windows];
                }
            }
            // Windows shared by both modes are neither removed nor added.
            count = [sourceWindows count];
            i = 0;
            while (i < count) {
                index = [destinationWindows indexOfObjectIdenticalTo:[sourceWindows objectAtIndex:i]];
                if (index == NSNotFound) {
                    i = i + 1;
                }
                else {
                    [destinationWindows removeObjectAtIndex:index];
                    [sourceWindows removeObjectAtIndex:i];
                    count = count - 1;
                }
            }
            [self removeWinodwsThatAreVisible:NO fromArray:sourceWindows];
            [self removeWinodwsThatAreVisible:YES fromArray:destinationWindows];
            if (aRemove != NULL) {
                *aRemove = sourceWindows;
            }
            if (aAdd != NULL) {
                *aAdd = destinationWindows;
            }
        }
        sameMainWindow = YES;
    }
    else {
        if (aRemove != NULL) {
            windows = [_previousModeController respondsToSelector:@selector(mainModeSwitcherWindow:)] ? [_previousModeController mainModeSwitcherWindow:self] : nil;
            sourceWindows = [NSMutableArray arrayWithObjects:windows, nil];
            if ([_previousModeController respondsToSelector:@selector(secondaryModeSwitcherWindows:)]) {
                windows = [_previousModeController secondaryModeSwitcherWindows:self];
                if ([windows count] != 0) {
                    [sourceWindows addObjectsFromArray:windows];
                }
            }
            *aRemove = sourceWindows;
        }
        if (aAdd != NULL) {
            windows = [_activeModeController respondsToSelector:@selector(mainModeSwitcherWindow:)] ? [_activeModeController mainModeSwitcherWindow:self] : nil;
            destinationWindows = [NSMutableArray arrayWithObjects:windows, nil];
            if ([_activeModeController respondsToSelector:@selector(secondaryModeSwitcherWindows:)]) {
                windows = [_activeModeController secondaryModeSwitcherWindows:self];
                if ([windows count] != 0) {
                    [destinationWindows addObjectsFromArray:windows];
                }
            }
            *aAdd = destinationWindows;
        }
    }
    if (aWindow != NULL) {
        *aWindow = sameMainWindow;
    }
}

- (void)removeWinodwsThatAreVisible:(BOOL)aVisible fromArray:(id)aArray
{
    NSUInteger pvVar1;
    unsigned int uVar2;
    int local_14;

    pvVar1 = [aArray count];
    uVar2 = 0;
    local_14 = (int)pvVar1 + 1;
    while (uVar2 < local_14 - 1) {
        if ([[aArray objectAtIndex:uVar2] isVisible] == aVisible) {
            [aArray removeObjectAtIndex:uVar2];
            local_14 = local_14 - 1;
        }
        else {
            uVar2 = uVar2 + 1;
        }
    }
}

- (id)switchingDestinationView
{
    id pvVar1_2;

    if (![_activeModeController respondsToSelector:@selector(modeSwitcherView:)]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [_activeModeController modeSwitcherView:self];
    }
    return pvVar1_2;
}

- (id)switchingSourceView
{
    id pvVar1_2;

    if (![_previousModeController respondsToSelector:@selector(modeSwitcherView:)]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [_previousModeController modeSwitcherView:self];
    }
    return pvVar1_2;
}

- (id)mainWindow
{
    id pvVar1_2;

    if (_switching != NO) {
        pvVar1_2 = [[self sourceWindowController] window];
        if (pvVar1_2 != nil) {
            return pvVar1_2;
        }
    }
    return [[self destinationWindowController] window];
}

- (id)destinationWindowController
{
    return [_activeModeController modeSwitcherWindowController:self];
}

- (id)sourceWindowController
{
    return [_previousModeController modeSwitcherWindowController:self];
}

- (void)setTemporalStorage:(id)aStorage
{
    if (_temporalStorage != aStorage) {
        [_temporalStorage autorelease];
        _temporalStorage = [aStorage retain];
    }
}

@end

