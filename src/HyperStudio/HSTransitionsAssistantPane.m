#import "HSTransitionsAssistantPane.h"

@implementation HSTransitionsAssistantPane

/* i386 ivar offsets: _transitionsGrid=0x78, _transitionScrollView=0x7c, _tryItButton=0x80, _durationSlider=0x84, _actionType=0x88, _transitionPreviewView=0x8c, _paneMultiApplier=0x90, _transitionPreviewIsRunning=0x94 */

+ (double)maxSliderDuration
{
    return HSMaxTransitionDuration - HSMinTransitionDuration;
}

+ (double)minSliderDuration
{
    return 0.0;
}

+ (double)sliderDurationFromTransitionDuration:(double)aDuration
{
    return HSMaxTransitionDuration - aDuration;
}

+ (double)transitionDurationFromSliderDuration:(double)aDuration
{
    return HSMaxTransitionDuration - aDuration;
}

- (id)attributeNotificationCenterForTransition:(id)aTransition
{
    return [HSAttributeNotificationCenter defaultCenter];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00123455 @ 00123455, 386 bytes * /

void FUN_00123455(HSTransitionsAssistantPane *self,SEL _cmd,id selectionDidChangeInTransitionsGrid)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  double dVar4;
  undefined8 in_stack_ffffffdc;
  undefined4 uVar6;
  undefined8 uVar5;
  
  uVar6 = (undefined4)((ulonglong)in_stack_ffffffdc >> 0x20);
  pvVar1 = _objc_msgSend(self->_transitionsGrid,sel_selectedRow);
  pvVar2 = _objc_msgSend(self->_transitionsGrid,sel_numberOfColumns);
  pvVar3 = _objc_msgSend(self->_transitionsGrid,sel_selectedColumn);
  self_00 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider);
  pvVar3 = (id)((int)pvVar2 * (int)pvVar1 + (int)pvVar3);
  pvVar1 = _objc_msgSend(self_00,sel_transitionEffectNames);
  uVar5 = CONCAT44(uVar6,pvVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar3);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_transitionPaneApplier,uVar5);
    uVar5 = CONCAT44((int)((ulonglong)uVar5 >> 0x20),pvVar1);
    _objc_msgSend(pvVar2,sel_setTransitionName_,pvVar1);
    if (pvVar3 == (id)0x0) {
      dVar4 = 0.0;
      _objc_msgSend(pvVar2,sel_setDuration_,0,0);
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_class,uVar5);
      dVar4 = _objc_msgSend_fpret(self->_durationSlider,sel_doubleValue);
      dVar4 = _objc_msgSend_fpret(pvVar1,sel_transitionDurationFromSliderDuration_,dVar4);
      _objc_msgSend(pvVar2,sel_setDuration_,dVar4);
    }
    _objc_msgSend(self,sel_validateUI,dVar4);
  }
  return;
}

*/
- (void)selectionDidChangeInTransitionsGrid:(id)aGrid
{
    NSInteger row = [_transitionsGrid selectedRow];
    NSInteger columns = [_transitionsGrid numberOfColumns];
    NSInteger column = [_transitionsGrid selectedColumn];
    NSInteger index = columns * row + column;
    id name = [[[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectNames] objectAtIndex:index];
    if (name != nil) {
        id applier = [self transitionPaneApplier];
        [applier setTransitionName:name];
        if (index == 0) {
            [applier setDuration:0.0];
        } else {
            [applier setDuration:[[self class] transitionDurationFromSliderDuration:[_durationSlider doubleValue]]];
        }
        [self validateUI];
    }
}

- (id)endImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid
{
    return [NSImage imageNamed:@"TransitionPreviewEnd"];
}

- (id)startImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid
{
    return [NSImage imageNamed:@"TransitionPreviewStart"];
}

- (id)transitionEffectWithDisplayName:(id *)aName thumbnail:(id *)aThumbnail atIndex:(NSUInteger)aIndex inTransitionsGrid:(id)aGrid
{
    id pvVar1;
    id pvVar2_2;

    if (aName != NULL) {
        *aName = nil;
    }
    if (aThumbnail != NULL) {
        *aThumbnail = nil;
    }
    pvVar1 = [HSTransitionEffectProvider sharedTransitionEffectProvider];
    if (pvVar1 != nil) {
        pvVar2_2 = [[pvVar1 transitionEffectNames] objectAtIndex:aIndex];
        if (pvVar2_2 != nil) {
            if (aName != NULL) {
                *aName = [pvVar1 displayNameForTransitionEffectWithName:pvVar2_2];
            }
            if (aThumbnail != NULL) {
                *aThumbnail = [pvVar1 thumbnailForTransitionEffectWithName:pvVar2_2];
            }
            return [pvVar1 transitionEffectWithName:pvVar2_2];
        }
    }
    return nil;
}

- (NSUInteger)transitionEffectCountInTransitionsGrid:(id)aGrid
{
    return (unsigned int)[[[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectNames] count];
}

- (void)transitionViewDidFinishTransition:(id)aTransition
{
    if (_transitionPreviewView == aTransition) {
        [self HSTransitionsAssistantPane_transitionDidEnd];
    }
    [super transitionViewDidFinishTransition:aTransition];
}

- (void)transitionViewDidStopTransition:(id)aTransition
{
    if (_transitionPreviewView == aTransition) {
        [self HSTransitionsAssistantPane_transitionDidEnd];
    }
    [super transitionViewDidStopTransition:aTransition]
    ;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012368f @ 0012368f, 539 bytes * /

void FUN_0012368f(HSTransitionsAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  
  self->_transitionPreviewIsRunning = '\0';
  pvVar1 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
  self_00 = cls_NSArray;
  pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,
                         self->_transitionPreviewView,*(undefined4 *)PTR_00336554,
                         *(undefined4 *)PTR_0033654c,*(undefined4 *)PTR_00336544,0);
  pvVar2 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithViewAnimations_,pvVar2);
  _objc_msgSend(pvVar1,sel_setAnimationBlockingMode_,0);
  lVar3 = (longdouble)_HSObjectAssistantAnimationDuration();
  _objc_msgSend(pvVar1,sel_setDuration_,(double)lVar3);
  _objc_msgSend(pvVar1,sel_startAnimation);
  _objc_msgSend(pvVar1,sel_release);
  _objc_msgSend(self->_transitionPreviewView,sel_setDelegate_,0);
  _objc_msgSend(self->_transitionPreviewView,sel_removeFromSuperview);
  _objc_msgSend(self->_transitionPreviewView,sel_release);
  self->_transitionPreviewView = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_view);
  _objc_msgSend(pvVar1,sel_addSubview_,self->_transitionScrollView);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_makeFirstResponder_,self->_transitionsGrid);
  _objc_msgSend(self->_transitionScrollView,sel_release);
  _objc_msgSend(self,sel_validateTransitionItems);
  return;
}

*/
- (void)HSTransitionsAssistantPane_transitionDidEnd
{
    _transitionPreviewIsRunning = NO;
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:_transitionPreviewView, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil]]];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [animation setDuration:HSObjectAssistantAnimationDuration()];
    [animation startAnimation];
    [animation release];
    [_transitionPreviewView setDelegate:nil];
    [_transitionPreviewView removeFromSuperview];
    [_transitionPreviewView release];
    _transitionPreviewView = nil;
    [[self view] addSubview:_transitionScrollView];
    [[self window] makeFirstResponder:_transitionsGrid];
    [_transitionScrollView release];
    [self validateTransitionItems];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)transitionDurationChanged:(id)aChanged
{
    double dVar2_2;

    dVar2_2 = [[self class] transitionDurationFromSliderDuration:[aChanged doubleValue]];
    [[self transitionPaneApplier] setDuration:dVar2_2];
    [_transitionsGrid setTransitionDuration:dVar2_2];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012395a @ 0012395a, 954 bytes * /

void FUN_0012395a(HSTransitionsAssistantPane *self,SEL _cmd,id tryIt)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  double dVar4;
  undefined8 local_24;
  undefined8 local_1c;
  
  if (self->_transitionPreviewIsRunning == '\0') {
    self->_transitionPreviewIsRunning = '\x01';
    _objc_msgSend(self,sel_validateTransitionItems);
    pvVar1 = _objc_msgSend(self->_transitionsGrid,sel_selectedTransitionEffect);
    pvVar2 = _objc_msgSend(cls_HSTransitionView,sel_alloc);
    _objc_msgSend_stret(&local_24,self->_transitionScrollView,sel_frame);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithFrame_,local_24,local_1c);
    self->_transitionPreviewView = pvVar2;
    _objc_msgSend(pvVar2,sel_setTransitionEffect_,pvVar1);
    pvVar1 = self->_transitionPreviewView;
    dVar4 = _objc_msgSend_fpret(self->_transitionsGrid,sel_transitionDuration);
    _objc_msgSend(pvVar1,sel_setTransitionDuration_,dVar4);
    _objc_msgSend(self->_transitionPreviewView,sel_enableOpenGLSurface);
    _objc_msgSend(self->_transitionPreviewView,sel_setScalesImagesToFit_,1);
    pvVar1 = self->_transitionPreviewView;
    pvVar2 = _objc_msgSend(self,sel_card);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00372220);
    pvVar2 = _objc_msgSend(pvVar2,sel_image);
    _objc_msgSend(pvVar1,sel_setStartImage_,pvVar2);
    pvVar1 = self->_transitionPreviewView;
    pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_TransitionPreviewEnd);
    _objc_msgSend(pvVar1,sel_setEndImage_,pvVar2);
    _objc_msgSend(self->_transitionPreviewView,sel_setDelegate_,self);
    _objc_msgSend(self->_transitionScrollView,sel_retain);
    _objc_msgSend(self->_transitionScrollView,sel_removeFromSuperview);
    pvVar1 = _objc_msgSend(self,sel_view);
    _objc_msgSend(pvVar1,sel_addSubview_,self->_transitionPreviewView);
    pvVar1 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
    self_00 = cls_NSArray;
    pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,
                           self->_transitionPreviewView,*(undefined4 *)PTR_00336554,
                           *(undefined4 *)PTR_003365ac,*(undefined4 *)PTR_00336544,0);
    pvVar2 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithViewAnimations_,pvVar2);
    _objc_msgSend(pvVar1,sel_setAnimationBlockingMode_,0);
    lVar3 = (longdouble)_HSObjectAssistantAnimationDuration();
    _objc_msgSend(pvVar1,sel_setDuration_,(double)lVar3);
    _objc_msgSend(pvVar1,sel_startAnimation);
    _objc_msgSend(pvVar1,sel_release);
    _objc_msgSend(self->_transitionsGrid,sel_stopPlayingIfNeeded);
    _objc_msgSend(self->_transitionPreviewView,sel_startTransition);
  }
  return;
}

*/
- (void)tryIt:(id)aIt
{
    if (!_transitionPreviewIsRunning) {
        _transitionPreviewIsRunning = YES;
        [self validateTransitionItems];
        id effect = [_transitionsGrid selectedTransitionEffect];
        _transitionPreviewView = [[HSTransitionView alloc] initWithFrame:[_transitionScrollView frame]];
        [_transitionPreviewView setTransitionEffect:effect];
        [_transitionPreviewView setTransitionDuration:[_transitionsGrid transitionDuration]];
        [_transitionPreviewView enableOpenGLSurface];
        [_transitionPreviewView setScalesImagesToFit:YES];
        [_transitionPreviewView setStartImage:[[[self card] queryHyperInterface:@protocol(HSUserObjectImageProvider)] image]];
        [_transitionPreviewView setEndImage:[NSImage imageNamed:@"TransitionPreviewEnd"]];
        [_transitionPreviewView setDelegate:self];
        [_transitionScrollView retain];
        [_transitionScrollView removeFromSuperview];
        [[self view] addSubview:_transitionPreviewView];
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:_transitionPreviewView, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil]]];
        [animation setAnimationBlockingMode:NSAnimationNonblocking];
        [animation setDuration:HSObjectAssistantAnimationDuration()];
        [animation startAnimation];
        [animation release];
        [_transitionsGrid stopPlayingIfNeeded];
        [_transitionPreviewView startTransition];
    }
}

- (void)dismiss:(BOOL)aDismiss
{
    if ([_transitionsGrid delegate] == self) {
        [_transitionsGrid setDelegate:0];
    }
    [super dismiss:aDismiss];
}

- (id)objectAssistantForNavigationPaneSwitcher:(id)aSwitcher
{
    return [self assistant];
}

- (id)helpTopicKey
{
    return @"HSTransition";
}

- (Class)hubPaneClass
{
    return [HSActionsAssistantPane class];
}

- (BOOL)shouldRewindToPreviousHubPane
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00122c74 @ 00122c74, 326 bytes * /

id FUN_00122c74(HSTransitionsAssistantPane *self,SEL _cmd,id firstPaneForObjectAssistant)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar4 = &DAT_003720b8;
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003720b8);
  if (pvVar2 == (id)0x0) {
    puVar4 = &DAT_00372108;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00372108);
    if (pvVar1 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSActionsAssistantPane,sel_alloc,puVar4);
      pvVar1 = _objc_msgSend(self,sel_actionEvent);
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithActionEvent_,pvVar1);
      goto LAB_00122daa;
    }
  }
  pvVar2 = _objc_msgSend(cls_HSActionsAssistantPane,sel_alloc,puVar4);
  pvVar3 = _objc_msgSend(cls_HSActionsPaneGoBackSwitcher,sel_class);
  pvVar1 = _objc_msgSend(self,sel_actionEvent);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithActionEvent_navigationSwitcherClass_,pvVar1,pvVar3);
LAB_00122daa:
  pvVar1 = _objc_msgSend(pvVar2,sel_autorelease,pvVar1);
  return pvVar1;
}

*/
- (id)firstPaneForObjectAssistant:(id)aAssistant
{
    id object = [[self assistant] object];
    id pane;
    if ([object queryHyperInterface:@protocol(HSCardAttributes)] == nil && [object queryHyperInterface:@protocol(HSStackAttributes)] == nil) {
        pane = [[HSActionsAssistantPane alloc] initWithActionEvent:[self actionEvent]];
    } else {
        pane = [[HSActionsAssistantPane alloc] initWithActionEvent:[self actionEvent] navigationSwitcherClass:[HSActionsPaneGoBackSwitcher class]];
    }
    return [pane autorelease];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00123df2 @ 00123df2, 519 bytes * /

void FUN_00123df2(HSTransitionsAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  double dVar3;
  double dVar4;
  double dVar5;
  double dVar6;
  undefined4 uVar7;
  HSTransitionsAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar2 = self->_durationSlider;
  pvVar1 = _objc_msgSend(self,sel_class);
  dVar5 = _objc_msgSend_fpret(pvVar1,sel_minSliderDuration);
  _objc_msgSend(pvVar2,sel_setDoubleValue_,dVar5);
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00351260;
  uVar7 = (undefined4)((ulonglong)dVar5 >> 0x20);
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar2 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  pvVar1 = _objc_msgSend(self,sel_paneMultiApplier);
  dVar5 = (double)CONCAT44(uVar7,pvVar1);
  _objc_msgSend(pvVar2,sel_setApplier_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_transitionOwner);
  pvVar2 = _objc_msgSend(pvVar2,sel_transition);
  pvVar1 = _objc_msgSend(pvVar2,sel_isFastestTransition);
  if ((char)pvVar1 == '\0') {
    dVar6 = _objc_msgSend_fpret(pvVar2,sel_duration);
    if ((dVar6 != 0.0) || (NAN(dVar6))) {
      dVar3 = ABS(dVar6);
    }
    else {
      dVar3 = 1.0;
    }
    dVar4 = 1e-05;
    if (1.0 <= dVar3) {
      dVar4 = dVar3 * 1e-05;
    }
    if (dVar4 < ABS(dVar6)) {
      pvVar1 = self->_durationSlider;
      self_00 = _objc_msgSend(self,sel_class);
      dVar5 = _objc_msgSend_fpret(pvVar2,sel_duration);
      dVar5 = _objc_msgSend_fpret(self_00,sel_sliderDurationFromTransitionDuration_,dVar5);
      _objc_msgSend(pvVar1,sel_setDoubleValue_,dVar5);
    }
  }
  pvVar1 = self->_transitionsGrid;
  pvVar2 = _objc_msgSend(pvVar2,sel_effect,dVar5);
  _objc_msgSend(pvVar1,sel_setSelectedTransitionEffect_,pvVar2);
  _objc_msgSend(self,sel_validateUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [_durationSlider setDoubleValue:[[self class] minSliderDuration]];
    [super viewWillAppear:aAppear];
    [[self navigationPaneSwitcher] setApplier:[self paneMultiApplier]];
    id<HSTransitionAttributes> transition = [[self transitionOwner] transition];
    if (![transition isFastestTransition]) {
        double duration = [transition duration];
        double scale = (duration != 0.0) ? fabs(duration) : 1.0;
        double tolerance = (1.0 <= scale) ? scale * 1e-05 : 1e-05;
        if (tolerance < fabs(duration)) {
            [_durationSlider setDoubleValue:[[self class] sliderDurationFromTransitionDuration:[transition duration]]];
        }
    }
    [_transitionsGrid setSelectedTransitionEffect:[transition effect]];
    [self validateUI];
}

- (void)applySettingsOnOK
{
    if ([_transitionPreviewView isTransitionPlaying]) {
        [_transitionPreviewView stopTransition];
    }
    [[self paneMultiApplier] applyChanges];
    [[self paneMultiApplier] makeInitialEqualToCurrent];
}

- (void)revertSettingsOnCancel
{
    if ([_transitionPreviewView isTransitionPlaying]) {
        [_transitionPreviewView stopTransition];
    }
    [[self paneMultiApplier] revertChanges];
    [[self paneMultiApplier] makeCurrentEqualToInitial];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00123ff9 @ 00123ff9, 302 bytes * /

void FUN_00123ff9(HSTransitionsAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  undefined8 in_stack_ffffffdc;
  undefined4 uVar5;
  undefined8 uVar4;
  double local_1c;
  
  uVar5 = (undefined4)((ulonglong)in_stack_ffffffdc >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_transitionOwner);
  pvVar1 = _objc_msgSend(pvVar1,sel_transition);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_transitionName);
    uVar4 = CONCAT44(uVar5,&cfstr_No_Transition);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_No_Transition);
    if ((char)pvVar2 == '\0') {
      local_1c = _objc_msgSend_fpret(pvVar1,sel_duration);
      if (0.0 < local_1c) {
        pvVar1 = self->_durationSlider;
        pvVar2 = _objc_msgSend(self,sel_class,uVar4);
        dVar3 = _objc_msgSend_fpret(pvVar2,sel_sliderDurationFromTransitionDuration_,local_1c);
        _objc_msgSend(pvVar1,sel_setDoubleValue_,dVar3);
      }
      goto LAB_001240eb;
    }
  }
  local_1c = 0.0;
LAB_001240eb:
  _objc_msgSend(self->_transitionsGrid,sel_setTransitionDuration_,local_1c);
  _objc_msgSend(self,sel_validateTransitionItems);
  return;
}

*/
- (void)validateUI
{
    id<HSTransitionAttributes> transition = [[self transitionOwner] transition];
    double duration = 0.0;
    if (transition != nil && ![[transition transitionName] isEqualToString:@"No Transition"]) {
        duration = [transition duration];
        if (0.0 < duration) {
            [_durationSlider setDoubleValue:[[self class] sliderDurationFromTransitionDuration:duration]];
        }
    }
    [_transitionsGrid setTransitionDuration:duration];
    [self validateTransitionItems];
}

- (void)validateTransitionItems
{
    char cVar1;
    double dVar2;
    char cVar1_2;

    dVar2 = [_transitionsGrid transitionDuration];
    if ((dVar2 <= 0.0) || (_transitionPreviewIsRunning != NO)) {
        cVar1 = NO;
    }
    else {
        cVar1 = YES;
    }
    [_durationSlider setEnabled:cVar1];
    if ((dVar2 <= 0.0) || (_transitionPreviewIsRunning != NO)) {
        cVar1_2 = NO;
    }
    else {
        cVar1_2 = YES;
    }
    [_tryItButton setEnabled:cVar1_2];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_transitionsGrid setDataSource:self];
    [_transitionsGrid invalidateTransitionStartImage];
    [_transitionsGrid invalidateTransitionEndImage];
    [_transitionsGrid setDelegate:self];
    [_durationSlider setMinValue:[[self class] minSliderDuration]];
    [_durationSlider setMaxValue:[[self class] maxSliderDuration]];
}

- (id)transitionAttributes
{
    return [[self transitionOwner] transition];
}

- (id)transitionOwner
{
    return [[self transitionPaneApplier] transitionOwner];
}

- (id)actionType
{
    return _actionType;
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _paneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSActionSetupPaneSwitcher alloc] initWithAssistantSettingsApplier:[self paneMultiApplier] windowNibName:@"ActionPaneSwitcher"];
        _paneSwitcher = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        pvVar1 = _paneSwitcher;
    }
    return pvVar1;
}

- (id)transitionPaneApplier
{
    [[self paneMultiApplier] addApplier:[self applier]];
    return [self applier];
}

- (Class)applierClass
{
    return [HSTransitionsAssistantPaneApplier class];
}

- (id)paneMultiApplier
{
    HSAssistantPaneMultiApplier *pHVar3;

    pHVar3 = _paneMultiApplier;
    if (pHVar3 == nil) {
        if ([[self assistant] object] == nil) {
            pHVar3 = _paneMultiApplier;
        }
        else {
            pHVar3 = [[HSAssistantPaneMultiApplier alloc] initWithObject:[[self assistant] object]];
            _paneMultiApplier = pHVar3;
        }
    }
    return pHVar3;
}

- (void)dealloc
{
    [_actionType release];
    if ([_transitionsGrid dataSource] == self) {
        [_transitionsGrid setDataSource:0];
    }
    if ([_transitionsGrid delegate] == self) {
        [_transitionsGrid setDelegate:0];
    }
    if (_transitionPreviewView != nil) {
        if ([_transitionPreviewView delegate] == self) {
            [_transitionPreviewView setDelegate:0];
        }
        [_transitionPreviewView removeFromSuperview];
        [_transitionPreviewView release];
        [_transitionScrollView release];
    }
    [_paneMultiApplier release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithActionType:[self actionType] paneMultiApplier:nil];
}

- (id)initialKeyView
{
    return _transitionsGrid;
}

- (id)initWithActionType:(id)aType paneMultiApplier:(id)aApplier
{
    self = [super initWithNibName:@"TransitionsAssistantPane"];
    if (self != nil) {
        _actionType = [aType retain];
        _paneMultiApplier = [aApplier retain];
    }
    return self;
}

@end

@implementation HSTransitionsAssistantPaneApplier

/* i386 ivar offsets: _initialTransitionName=0x30, _initialDuration=0x34, _transitionName=0x3c, _duration=0x40 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setDuration:(double)aDuration
{
    if (_duration != aDuration) {
        _duration = aDuration;
        [self disableUndo];
        [[[self transitionOwner] transition] setDuration:_duration];
        [self enableUndo];
    }
}
#pragma clang diagnostic pop

- (void)setTransitionName:(id)aName
{
    if (![_transitionName isEqualToString:aName]) {
        [_transitionName release];
        _transitionName = [aName copy];
        [self disableUndo];
        [[[self transitionOwner] transition] setTransitionName:_transitionName];
        [self enableUndo];
    }
}

- (BOOL)areSettingsEqual
{
    double dVar1;
    double dVar2;
    BOOL pvVar3;
    double dVar4;
    double dVar5;

    pvVar3 = [super areSettingsEqual];
    if (pvVar3) {
        dVar1 = _initialDuration;
        dVar2 = _duration;
        dVar4 = dVar1 != 0.0 ? fabs(dVar1) : 1.0;
        dVar5 = dVar2 != 0.0 ? fabs(dVar2) : 1.0;
        if (dVar5 <= dVar4) {
            dVar5 = dVar4;
        }
        if (fabs(dVar1 - dVar2) <= dVar5 * 1e-05) {
            if (_transitionName == nil) {
                return _initialTransitionName == nil;
            }
            pvVar3 = [_initialTransitionName isEqualToString:_transitionName];
            return (BOOL)pvVar3;
        }
    }
    return NO;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_transitionName release];
    _transitionName = [_initialTransitionName retain];
    _duration = _initialDuration;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialTransitionName release];
    _initialTransitionName = [_transitionName retain];
    _initialDuration = _duration;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setInitialSettingsToObject
{
    id pvVar1_2;

    pvVar1_2 = [[self transitionOwner] transition];
    [pvVar1_2 setTransitionName:_initialTransitionName];
    [pvVar1_2 setDuration:_initialDuration];
    [super setInitialSettingsToObject];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setCurrentSettingsToObject
{
    id pvVar1_2;

    [super setCurrentSettingsToObject];
    pvVar1_2 = [[self transitionOwner] transition];
    [pvVar1_2 setTransitionName:_transitionName];
    [pvVar1_2 setDuration:_duration];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012331a @ 0012331a, 184 bytes * /

void FUN_0012331a(HSTransitionsAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(self,sel_transitionOwner);
  pvVar1 = _objc_msgSend(pvVar1,sel_transition);
  pvVar2 = _objc_msgSend(pvVar1,sel_transitionName);
  pvVar2 = _objc_msgSend(pvVar2,sel_copy);
  self->_initialTransitionName = pvVar2;
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_transitionName = pvVar2;
  *(undefined4 *)((int)&self->_initialDuration + 4) = 0;
  *(undefined4 *)&self->_initialDuration = 0;
  if (pvVar1 == (id)0x0) {
    dVar3 = 0.0;
  }
  else {
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_duration);
    self->_initialDuration = dVar3;
  }
  self->_duration = dVar3;
  return;
}

*/
- (void)setUpInitialSettings
{
    id<HSTransitionAttributes> transition = [[self transitionOwner] transition];
    _initialTransitionName = [[transition transitionName] copy];
    _transitionName = [_initialTransitionName retain];
    _initialDuration = 0.0;
    double duration = 0.0;
    if (transition != nil) {
        duration = [transition duration];
        _initialDuration = duration;
    }
    _duration = duration;
}

- (id)transitionOwner
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSTransitionOwner)];
}

- (void)dealloc
{
    [_transitionName release];
    [_initialTransitionName release];
    [super dealloc];
}

@end

