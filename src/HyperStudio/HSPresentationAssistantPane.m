#import "HSPresentationAssistantPane.h"

@implementation HSPresentationAssistantPane

/* i386 ivar offsets: _fillTypeControllerView=0x5c, _coverDesktopSwitch=0x60, _hideMenuBarSwitch=0x64, _hideWindowTitleBarSwitch=0x68, _playInFullScreenModeSwitch=0x6c, _fillTypePopUpButton=0x70, _gradientColorView=0x74, _imageView=0x78, _solidColorView=0x7c, _fillTypeGradientColorController=0x80, _fillTypeSolidColorController=0x84, _fillTypeImageController=0x88, _fillTypeController=0x8c, _animation=0x90, _paneSwitcher=0x94, _applier=0x98, _userMadeDecision=0x9c */

- (void)defaultBackgroundAttributesDidChange:(id)aChange
{
    [[self applier] refreshDefaultBackgroundAttributes];
    [self validateUI];
}

- (void)animationDidEnd:(id)aEnd
{
    [[[[aEnd viewAnimations] objectAtIndex:0] objectForKey:NSViewAnimationTargetKey] removeFromSuperview];
}

- (void)animationDidStop:(id)aStop
{
    [[[[aStop viewAnimations] objectAtIndex:0] objectForKey:NSViewAnimationTargetKey] removeFromSuperview];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f2995 @ 001f2995, 472 bytes * /

id FUN_001f2995(HSPresentationAssistantPane *self,SEL _cmd,id animationForView,id andView)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  
  pvVar3 = _objc_msgSend(self->_animation,sel_isAnimating);
  if ((char)pvVar3 != '\0') {
    _objc_msgSend(self->_animation,sel_stopAnimation);
  }
  _objc_msgSend(self->_animation,sel_release);
  puVar2 = PTR_00336554;
  puVar1 = PTR_00336544;
  pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,animationForView,
                         *(undefined4 *)PTR_00336554,*(undefined4 *)PTR_0033654c,
                         *(undefined4 *)PTR_00336544,0);
  pvVar4 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,andView,
                         *(undefined4 *)puVar2,*(undefined4 *)PTR_003365ac,*(undefined4 *)puVar1,0);
  self_00 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pvVar3,pvVar4,0);
  pvVar3 = _objc_msgSend(self_00,sel_initWithViewAnimations_,pvVar3);
  self->_animation = pvVar3;
  _objc_msgSend(pvVar3,sel_setDelegate_,self);
  _objc_msgSend(self->_animation,sel_setDuration_,0,0x3fe00000);
  _objc_msgSend(self->_animation,sel_setAnimationBlockingMode_,1);
  return self->_animation;
}

*/
- (id)animationForView:(id)aView andView:(id)aView2
{
    if ([_animation isAnimating]) {
        [_animation stopAnimation];
    }
    [_animation release];
    NSDictionary *fadeOut = [NSDictionary dictionaryWithObjectsAndKeys:aView, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
    NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:aView2, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
    _animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:fadeOut, fadeIn, nil]];
    [_animation setDelegate:self];
    [_animation setDuration:0.5];
    [_animation setAnimationBlockingMode:NSAnimationNonblockingThreaded];
    return _animation;
    return 0;
}

- (void)hideMenuBarStateChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged state];
    [[self applier] setPresentationMenuVisible:(unsigned int)(pvVar1 != 0x1)];
    if (pvVar1 != 0x1) {
        [_playInFullScreenModeSwitch setState:0];
        [self playInFullScreenModeStateChanged:_playInFullScreenModeSwitch];
    }
}

- (void)coverDesktopStateChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged state];
    [[self applier] setPresentationCoveringDesktop:(unsigned int)(pvVar1 == 0x1)];
    if (pvVar1 != 0x1) {
        [_playInFullScreenModeSwitch setState:0];
        [self playInFullScreenModeStateChanged:_playInFullScreenModeSwitch];
    }
}

- (void)hideWindowTitleBarChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged state];
    [[self applier] setPresentationPlaysWithoutTitleBar:(unsigned int)(pvVar1 == 0x1)];
    if (pvVar1 != 0x1) {
        [_playInFullScreenModeSwitch setState:0];
        [self playInFullScreenModeStateChanged:_playInFullScreenModeSwitch];
    }
}

- (void)playInFullScreenModeStateChanged:(id)aChanged
{
    NSInteger pvVar1_2;

    if ([aChanged state] == 0x1) {
        [_coverDesktopSwitch setState:1];
        [_hideMenuBarSwitch setState:1];
        [_hideWindowTitleBarSwitch setState:1];
        [self coverDesktopStateChanged:_coverDesktopSwitch];
        [self hideMenuBarStateChanged:_hideMenuBarSwitch];
        [self hideWindowTitleBarChanged:_hideWindowTitleBarSwitch];
    }
    pvVar1_2 = [aChanged state];
    [[self applier] setShouldPlayInFullScreen:(unsigned int)(pvVar1_2 == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f2e66 @ 001f2e66, 289 bytes * /

void FUN_001f2e66(HSPresentationAssistantPane *self,SEL _cmd,id fillTypeChanged)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  HSStackBackgroundSolidColorController *pHVar3;
  
  pvVar1 = _objc_msgSend(fillTypeChanged,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  _objc_msgSend(self->_applier,sel_setFillType_,pvVar1);
  pvVar2 = _objc_msgSend(self->_fillTypeController,sel_deactivatedColorWellOnUnmount);
  self_00 = _objc_msgSend(self->_fillTypeController,sel_contentView);
  _objc_msgSend(self_00,sel_removeFromSuperview);
  self->_fillTypeController = (id)0x0;
  if (pvVar1 == (id)0x3) {
    pHVar3 = (HSStackBackgroundSolidColorController *)self->_fillTypeImageController;
  }
  else if (pvVar1 == (id)0x2) {
    pHVar3 = (HSStackBackgroundSolidColorController *)self->_fillTypeGradientColorController;
  }
  else {
    if (pvVar1 != (id)0x1) goto LAB_001f2f47;
    pHVar3 = self->_fillTypeSolidColorController;
  }
  _objc_msgSend(self,sel_mountController_,pHVar3);
LAB_001f2f47:
  _objc_msgSend(self->_fillTypeController,sel_setShouldActivateColorWellOnMount_,(int)(char)pvVar2);
  _objc_msgSend(self->_fillTypeController,sel_validateUIElements);
  return;
}

*/
- (void)fillTypeChanged:(id)aChanged
{
    NSInteger fillType = [[aChanged selectedItem] tag];
    [_applier setFillType:fillType];
    BOOL activateColorWell = [_fillTypeController deactivatedColorWellOnUnmount];
    [[_fillTypeController contentView] removeFromSuperview];
    _fillTypeController = nil;
    id controller = nil;
    switch (fillType) {
    case 3:
        controller = _fillTypeImageController;
        break;
    case 2:
        controller = _fillTypeGradientColorController;
        break;
    case 1:
        controller = _fillTypeSolidColorController;
        break;
    }
    if (controller != nil) {
        [self mountController:controller];
    }
    [_fillTypeController setShouldActivateColorWellOnMount:activateColorWell];
    [_fillTypeController validateUIElements];
}

- (void)mountController:(id)aController
{
    NSView *pvVar1_3;

    if (_fillTypeController != aController) {
        if ([_fillTypeController contentView] != nil) {
            if ([aController contentView] != nil) {
                pvVar1_3 = [aController contentView];
                [[self animationForView:[_fillTypeController contentView] andView:pvVar1_3] startAnimation];
            }
        }
        _fillTypeController = aController;
        [_fillTypeControllerView addSubview:[aController contentView]];
        [_fillTypeController apply];
        [[self window] recalculateKeyViewLoop];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f30aa @ 001f30aa, 316 bytes * /

void FUN_001f30aa(HSPresentationAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  HSStackBackgroundSolidColorController *pHVar3;
  
  pvVar1 = _objc_msgSend(self,sel_applier);
  pvVar2 = _objc_msgSend(self,sel_backgroundAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_fillTypeFromInterface_,pvVar2);
  if (pvVar1 == (id)0xffffffff) {
    return;
  }
  _objc_msgSend(self->_fillTypePopUpButton,sel_selectItemWithTag_,pvVar1);
  pvVar2 = _objc_msgSend(self->_fillTypeController,sel_deactivatedColorWellOnUnmount);
  self_00 = _objc_msgSend(self->_fillTypeController,sel_contentView);
  _objc_msgSend(self_00,sel_removeFromSuperview);
  self->_fillTypeController = (id)0x0;
  if (pvVar1 == (id)0x3) {
    pHVar3 = (HSStackBackgroundSolidColorController *)self->_fillTypeImageController;
  }
  else if (pvVar1 == (id)0x2) {
    pHVar3 = (HSStackBackgroundSolidColorController *)self->_fillTypeGradientColorController;
  }
  else {
    if (pvVar1 != (id)0x1) goto LAB_001f31a6;
    pHVar3 = self->_fillTypeSolidColorController;
  }
  _objc_msgSend(self,sel_mountController_,pHVar3);
LAB_001f31a6:
  _objc_msgSend(self->_fillTypeController,sel_setShouldActivateColorWellOnMount_,(int)(char)pvVar2);
  _objc_msgSend(self->_fillTypeController,sel_validateUIElements);
  return;
}

*/
- (void)validateFillTypeController
{
    NSInteger fillType = [[self applier] fillTypeFromInterface:[self backgroundAttributes]];
    if (fillType == -1) {
        return;
    }
    [_fillTypePopUpButton selectItemWithTag:fillType];
    BOOL activateColorWell = [_fillTypeController deactivatedColorWellOnUnmount];
    [[_fillTypeController contentView] removeFromSuperview];
    _fillTypeController = nil;
    id controller = nil;
    switch (fillType) {
    case 3:
        controller = _fillTypeImageController;
        break;
    case 2:
        controller = _fillTypeGradientColorController;
        break;
    case 1:
        controller = _fillTypeSolidColorController;
        break;
    }
    if (controller != nil) {
        [self mountController:controller];
    }
    [_fillTypeController setShouldActivateColorWellOnMount:activateColorWell];
    [_fillTypeController validateUIElements];
}

- (void)validateUI
{
    [_hideMenuBarSwitch setState:(unsigned int)(![[self applier] isPresentationMenuVisible])];
    [_coverDesktopSwitch setState:(unsigned int)([[self applier] isPresentationCoveringDesktop])];
    [_hideWindowTitleBarSwitch setState:(unsigned int)([[self applier] isPresentationPlaysWithoutTitleBar])];
    [_playInFullScreenModeSwitch setState:(unsigned int)([[self applier] shouldPlayInFullScreen])];
    [self validateFillTypeController];
}

- (id)backgroundAttributes
{
    return [[self applier] backgroundAttributes];
}

- (id)applier
{
    HSPresentationAssistantPaneApplier *pHVar3;

    pHVar3 = _applier;
    if (pHVar3 == nil) {
        [self setApplier:[[[HSPresentationAssistantPaneApplier alloc] initWithObject:[[self assistant] object]] autorelease]];
        pHVar3 = _applier;
    }
    return pHVar3;
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier) {
        [_applier autorelease];
        _applier = [aApplier retain];
    }
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _paneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _paneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _paneSwitcher;
    }
    return pHVar1;
}

- (void)paneDidCancel:(id)aCancel
{
    _userMadeDecision = YES;
    [[self applier] revertChanges];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    _userMadeDecision = YES;
    [[self applier] applyChanges];
    [self dismiss:YES slide:NO];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    id pvVar1;

    pvVar1 = [NSNotificationCenter defaultCenter];
    [pvVar1 removeObserver:self];
    if (_userMadeDecision == NO) {
        pvVar1 = [self applier];
        [pvVar1 restoreIfNotApplied];
    }
    pvVar1 = [self navigationPaneSwitcher];
    [pvVar1 setApplier:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultBackgroundAttributesDidChange:) name:HSUICoverDesktopBackgroundDidChangeNotification object:0];
    [_fillTypeGradientColorController setApplier:[self applier]];
    [_fillTypeSolidColorController setApplier:[self applier]];
    [_fillTypeImageController setApplier:[self applier]];
    [_fillTypeGradientColorController setDelegate:self];
    [_fillTypeSolidColorController setDelegate:self];
    [[self applier] updateObject];
    [[self navigationPaneSwitcher] setApplier:[self applier]];
    [self validateUI];
}

- (void)dealloc
{
    [_fillTypeGradientColorController release];
    [_fillTypeSolidColorController release];
    [_fillTypeImageController release];
    [_applier release];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PresentationAssistantPane"];
    return self;
}

@end

