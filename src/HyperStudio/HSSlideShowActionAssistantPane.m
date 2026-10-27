#import "HSSlideShowActionAssistantPane.h"

@implementation HSSlideShowActionAssistantPane

/* i386 ivar offsets: _transitionPopup=0x88, _durationSlider=0x8c, _slideDurationField=0x90, _slideDurationStepper=0x94, _effectTransitionView=0x98, _effectTransitionImageView=0x9c, _returnToOriginalCardButton=0xa0, _useClickOnExitCardButton=0xa4, _loopButton=0xa8 */

- (id)initialKeyView
{
    return _transitionPopup;
}

- (void)transitionViewDidFinishTransition:(id)aTransition
{
    if (_effectTransitionView == aTransition) {
        [self HSSlideShowActionAssistantPane_hideTransition];
    }
    [super transitionViewDidFinishTransition:aTransition];
}

- (void)transitionViewDidStopTransition:(id)aTransition
{
    if (_effectTransitionView == aTransition) {
        [self HSSlideShowActionAssistantPane_hideTransition];
    }
    [super transitionViewDidStopTransition:aTransition]
    ;
}

- (void)showTransition:(id)aTransition
{
    [self HSSlideShowActionAssistantPane_startTransition];
}

- (void)loopChanged:(id)aChanged
{
    [[self slideShowActionAssistantPaneApplier] setLoopSlideShow:[_loopButton state]];
}

- (void)useClickOnExitCardChanged:(id)aChanged
{
    [[self slideShowActionAssistantPaneApplier] setUseClickOnExitCard:[_useClickOnExitCardButton state]];
}

- (void)returnToOriginalCardChanged:(id)aChanged
{
    [[self slideShowActionAssistantPaneApplier] setReturnsToOriginalCard:[_returnToOriginalCardButton state]];
}

- (void)slideDurationChanged:(id)aChanged
{
    [[self slideShowActionAssistantPaneApplier] setSlideDuration:[aChanged doubleValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011b99f @ 0011b99f, 183 bytes * /

void FUN_0011b99f(HSSlideShowActionAssistantPane *self,SEL _cmd,id durationChanged)

{
  id pvVar1;
  double dVar2;
  SEL op;
  double dVar3;
  
  dVar2 = _objc_msgSend_fpret(durationChanged,sel_doubleValue);
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAssistantPaneApplier);
  dVar2 = 2.0 - dVar2;
  dVar3 = dVar2;
  _objc_msgSend(pvVar1,sel_setTransitionDuration_,dVar2,dVar2);
  pvVar1 = _objc_msgSend(self->_effectTransitionView,sel_isTransitionPlaying);
  op = sel_HSSlideShowActionAssistantPane_startTransition;
  if ((char)pvVar1 != '\0') {
    self = self->_effectTransitionView;
    op = sel_setTransitionDuration_;
    dVar2 = dVar3;
  }
  _objc_msgSend(self,op,dVar2);
  return;
}

*/
- (void)durationChanged:(id)aChanged
{
    double duration = 2.0 - [aChanged doubleValue];
    [[self slideShowActionAssistantPaneApplier] setTransitionDuration:duration];
    if ([_effectTransitionView isTransitionPlaying]) {
        [_effectTransitionView setTransitionDuration:duration];
    } else {
        [self HSSlideShowActionAssistantPane_startTransition];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011ba56 @ 0011ba56, 340 bytes * /

void FUN_0011ba56(HSSlideShowActionAssistantPane *self,SEL _cmd,id transitionChanged)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(self->_effectTransitionView,sel_isTransitionPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_effectTransitionView,sel_stopTransition);
    _objc_msgSend(self,sel_HSSlideShowActionAssistantPane_hideTransition);
  }
  pvVar1 = _objc_msgSend(self->_transitionPopup,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  if (pvVar1 != (id)0x0) {
    self_00 = _objc_msgSend(self,sel_slideShowActionAssistantPaneApplier);
    pvVar2 = _objc_msgSend(self->_transitionPopup,sel_indexOfSelectedItem);
    if (pvVar2 == (id)0x0) {
      _objc_msgSend(self_00,sel_setTransitionDuration_,0,0);
    }
    else {
      dVar3 = _objc_msgSend_fpret(self->_durationSlider,sel_doubleValue);
      _objc_msgSend(self_00,sel_setTransitionDuration_,2.0 - dVar3);
    }
    _objc_msgSend(self_00,sel_setTransitionName_,pvVar1);
    _objc_msgSend(self,sel_HSSlideShowActionAssistantPane_startTransition);
  }
  return;
}

*/
- (void)transitionChanged:(id)aChanged
{
    if ([_effectTransitionView isTransitionPlaying]) {
        [_effectTransitionView stopTransition];
        [self HSSlideShowActionAssistantPane_hideTransition];
    }
    id transitionName = [[_transitionPopup selectedItem] representedObject];
    if (transitionName != nil) {
        id applier = [self slideShowActionAssistantPaneApplier];
        if ([_transitionPopup indexOfSelectedItem] == 0) {
            [applier setTransitionDuration:0.0];
        } else {
            [applier setTransitionDuration:2.0 - [_durationSlider doubleValue]];
        }
        [applier setTransitionName:transitionName];
        [self HSSlideShowActionAssistantPane_startTransition];
    }
}

- (id)helpTopicKey
{
    return @"HSSlideShow";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    if ([_effectTransitionView isTransitionPlaying]) {
        [_effectTransitionView stopTransition];
        [self HSSlideShowActionAssistantPane_hideTransition];
    }
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011bc45 @ 0011bc45, 620 bytes * /

void FUN_0011bc45(HSSlideShowActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  id pvVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  id local_20;
  HSSlideShowActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_003510b0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  uVar6 = 0;
  pvVar5 = (id)0x0;
  _objc_msgSend(self->_durationSlider,sel_setDoubleValue_,0,0);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  pvVar1 = _objc_msgSend(self->_transitionPopup,sel_numberOfItems);
  if ((int)pvVar1 < 2) {
    _objc_msgSend(self->_transitionPopup,sel_removeAllItems,pvVar5,uVar6);
    pvVar1 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider);
    self_00 = _objc_msgSend(pvVar1,sel_transitionEffectNames);
    local_20 = (id)0x0;
    pvVar2 = _objc_msgSend(self_00,sel_count);
    for (; local_20 < pvVar2; local_20 = (id)((int)local_20 + 1)) {
      pvVar3 = _objc_msgSend(self_00,sel_objectAtIndex_,local_20);
      pvVar5 = pvVar3;
      pvVar4 = _objc_msgSend(pvVar1,sel_displayNameForTransitionEffectWithName_,pvVar3);
      if (pvVar4 == (id)0x0) break;
      pvVar5 = _objc_msgSend(cls_NSMenuItem,sel_alloc,pvVar5);
      pcVar7 = &cfstr_empty;
      uVar6 = 0;
      self_01 = _objc_msgSend(pvVar5,sel_initWithTitle_action_keyEquivalent_,pvVar4,0,&cfstr_empty);
      pvVar5 = pvVar4;
      if (self_01 == (id)0x0) break;
      _objc_msgSend(self_01,sel_setRepresentedObject_,pvVar3,uVar6,pcVar7);
      pvVar3 = _objc_msgSend(self->_transitionPopup,sel_menu);
      pvVar5 = self_01;
      _objc_msgSend(pvVar3,sel_addItem_,self_01);
      _objc_msgSend(self_01,sel_release);
    }
    pvVar5 = _objc_msgSend(self->_transitionPopup,sel_menu,pvVar5,uVar6);
    pvVar1 = _objc_msgSend(cls_NSMenuItem,sel_separatorItem);
    uVar6 = 1;
    _objc_msgSend(pvVar5,sel_insertItem_atIndex_,pvVar1,1);
  }
  _objc_msgSend(self,sel_validateUIWithNotification_,0,uVar6);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_durationSlider setDoubleValue:0.0];
    [self addActionAssistantPaneObserver];
    if ([_transitionPopup numberOfItems] < 2) {
        [_transitionPopup removeAllItems];
        HSTransitionEffectProvider *provider = [HSTransitionEffectProvider sharedTransitionEffectProvider];
        NSArray *names = [provider transitionEffectNames];
        NSUInteger count = [names count];
        for (NSUInteger i = 0; i < count; i++) {
            id name = [names objectAtIndex:i];
            id displayName = [provider displayNameForTransitionEffectWithName:name];
            if (displayName == nil) {
                break;
            }
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:displayName action:NULL keyEquivalent:@""];
            if (item == nil) {
                break;
            }
            [item setRepresentedObject:name];
            [[_transitionPopup menu] addItem:item];
            [item release];
        }
        [[_transitionPopup menu] insertItem:[NSMenuItem separatorItem] atIndex:1];
    }
    [self validateUIWithNotification:nil];
}

- (id)actionAttribute
{
    return (id)@protocol(HSSlideShowActionAttributes);
}

- (void)HSSlideShowActionAssistantPane_hideTransition
{
    [_effectTransitionView setTransitionEffect:nil];
    [_effectTransitionView setHidden:YES];
    [_effectTransitionImageView setHidden:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011beb1 @ 0011beb1, 327 bytes * /

void FUN_0011beb1(HSSlideShowActionAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAssistantPaneApplier);
  pvVar1 = _objc_msgSend(pvVar1,sel_slideShowActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_slideTransition);
  if (pvVar1 != (id)0x0) {
    dVar2 = _objc_msgSend_fpret(pvVar1,sel_duration);
    if (dVar2 != 0.0) {
      _objc_msgSend(self->_effectTransitionView,sel_setHidden_,0);
      _objc_msgSend(self->_effectTransitionImageView,sel_setHidden_,1);
      self_00 = self->_effectTransitionView;
      pvVar1 = _objc_msgSend(pvVar1,sel_effect);
      _objc_msgSend(self_00,sel_setTransitionEffect_,pvVar1);
      _objc_msgSend(self->_effectTransitionView,sel_setTransitionDuration_,dVar2);
      _objc_msgSend(self->_effectTransitionView,sel_startTransition);
    }
  }
  return;
}

*/
- (void)HSSlideShowActionAssistantPane_startTransition
{
    HSTransition *transition = [[[self slideShowActionAssistantPaneApplier] slideShowActionAttributes] slideTransition];
    if (transition != nil) {
        double duration = [transition duration];
        if (duration != 0.0) {
            [_effectTransitionView setHidden:NO];
            [_effectTransitionImageView setHidden:YES];
            [_effectTransitionView setTransitionEffect:[transition effect]];
            [_effectTransitionView setTransitionDuration:duration];
            [_effectTransitionView startTransition];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011bff8 @ 0011bff8, 421 bytes * /

void FUN_0011bff8(HSSlideShowActionAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  HSSlideShowActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_003510b0;
  _objc_msgSendSuper(&local_1c,sel_viewDidLoad);
  _objc_msgSend(self->_durationSlider,sel_setMinValue_,0,0);
  _objc_msgSend(self->_durationSlider,sel_setMaxValue_,0,0x3ff80000);
  _objc_msgSend(self->_effectTransitionView,sel_enableOpenGLSurface);
  _objc_msgSend(self->_effectTransitionView,sel_setScalesImagesToFit_,1);
  _objc_msgSend(self->_effectTransitionView,sel_setDelegate_,self);
  self_00 = cls_NSBundle;
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperCoreGraphicsImageFromResource_ofType_,
                         &cfstr_Transition_start,&cfstr_png);
  _objc_msgSend(self->_effectTransitionView,sel_setStartImage_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCoreGraphicsImageFromResource_ofType_,&cfstr_Transition_end
                         ,&cfstr_png);
  _objc_msgSend(self->_effectTransitionView,sel_setEndImage_,pvVar1);
  return;
}

*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    [_durationSlider setMinValue:0.0];
    [_durationSlider setMaxValue:1.5];
    [_effectTransitionView enableOpenGLSurface];
    [_effectTransitionView setScalesImagesToFit:YES];
    [_effectTransitionView setDelegate:self];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    [_effectTransitionView setStartImage:[bundle hyperCoreGraphicsImageFromResource:@"Transition_start" ofType:@"png"]];
    [_effectTransitionView setEndImage:[bundle hyperCoreGraphicsImageFromResource:@"Transition_end" ofType:@"png"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011c19d @ 0011c19d, 1174 bytes * /

void FUN_0011c19d(HSSlideShowActionAssistantPane *self,SEL _cmd,id validateUIWithNotification)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  double dVar7;
  double local_44;
  undefined1 local_34 [8];
  float local_2c;
  float local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  float local_1c;
  float fStack_18;
  
  puVar6 = (undefined4 *)&stack0xffffff74;
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar3 = _objc_msgSend(pvVar2,sel_slideTransition);
  if (pvVar3 == (id)0x0) {
    _objc_msgSend(self->_effectTransitionImageView,sel_setImage_);
    _objc_msgSend(self->_effectTransitionImageView,sel_setAlternateImage_);
  }
  else {
    pvVar4 = _objc_msgSend(pvVar3,sel_transitionName);
    if (pvVar4 == (id)0x0) {
LAB_0011c1f9:
      puVar6 = (undefined4 *)&stack0xffffff74;
      pvVar4 = (id)0x0;
    }
    else {
      pvVar4 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider);
      if (pvVar4 == (id)0x0) goto LAB_0011c1f9;
      pvVar5 = _objc_msgSend(pvVar4,sel_displayNameForTransitionEffectWithName_);
      if (pvVar5 == (id)0x0) goto LAB_0011c1f9;
      _objc_msgSend(self->_transitionPopup,sel_selectItemWithTitle_);
      pvVar4 = _objc_msgSend(pvVar4,sel_thumbnailForTransitionEffectWithName_);
      puVar6 = (undefined4 *)&stack0xffffff74;
      if (pvVar4 != (id)0x0) {
        _objc_msgSend_stret(local_34,self->_effectTransitionImageView,sel_frame);
        puVar6 = (undefined4 *)&stack0xffffff70;
        if ((0.0 < local_2c) && (puVar6 = (undefined4 *)&stack0xffffff70, 0.0 < local_28)) {
          _objc_msgSend(pvVar4,sel_size);
          cVar1 = _NSEqualSizes();
          puVar6 = (undefined4 *)&stack0xffffff70;
          if (cVar1 == '\0') {
            pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc);
            pvVar5 = _objc_msgSend(pvVar5,sel_initWithSize_);
            pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
            puVar6 = (undefined4 *)&stack0xffffff70;
            if (pvVar5 != (id)0x0) {
              _objc_msgSend(pvVar5,sel_lockFocus);
              local_24 = 0;
              uStack_20 = 0;
              local_1c = local_2c;
              fStack_18 = local_28;
              _objc_msgSend(pvVar4,sel_drawInRect_fromRect_operation_fraction_);
              _objc_msgSend(pvVar5,sel_unlockFocus);
              puVar6 = (undefined4 *)&stack0xffffff70;
              pvVar4 = pvVar5;
            }
          }
        }
      }
    }
    pvVar5 = self->_effectTransitionImageView;
    puVar6[2] = pvVar4;
    puVar6[1] = sel_setImage_;
    *puVar6 = pvVar5;
    puVar6[-1] = 0x11c41c;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    pvVar5 = self->_effectTransitionImageView;
    puVar6[2] = pvVar4;
    puVar6[1] = sel_setAlternateImage_;
    *puVar6 = pvVar5;
    puVar6[-1] = 0x11c438;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    if (pvVar3 != (id)0x0) {
      puVar6[1] = sel_duration;
      *puVar6 = pvVar3;
      puVar6[-1] = 0x11c457;
      local_44 = _objc_msgSend_fpret((id)*puVar6,(SEL)puVar6[1]);
      if (0.0 < local_44) {
        pvVar3 = self->_durationSlider;
        *(double *)(puVar6 + 2) = 2.0 - local_44;
        puVar6[1] = sel_setDoubleValue_;
        *puVar6 = pvVar3;
        puVar6[-1] = 0x11c49b;
        _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
      }
      goto LAB_0011c4e9;
    }
  }
  local_44 = 0.0;
LAB_0011c4e9:
  pvVar3 = self->_durationSlider;
  puVar6[2] = (uint)(0.0 < local_44);
  puVar6[1] = sel_setEnabled_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x11c51b;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar3 = self->_slideDurationField;
  puVar6[1] = sel_slideDuration;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x11c539;
  dVar7 = _objc_msgSend_fpret((id)*puVar6,(SEL)puVar6[1]);
  *(double *)(puVar6 + 2) = dVar7;
  puVar6[1] = sel_setDoubleValue_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x11c54f;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar3 = self->_slideDurationStepper;
  puVar6[1] = sel_slideDuration;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x11c56a;
  dVar7 = _objc_msgSend_fpret((id)*puVar6,(SEL)puVar6[1]);
  *(double *)(puVar6 + 2) = dVar7;
  puVar6[1] = sel_setDoubleValue_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x11c580;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar3 = self->_returnToOriginalCardButton;
  puVar6[1] = sel_returnsToOriginalCard;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x11c59b;
  pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[2] = (uint)((char)pvVar4 != '\0');
  puVar6[1] = sel_setState_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x11c5b9;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar3 = self->_useClickOnExitCardButton;
  puVar6[1] = sel_useClickOnExitCard;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x11c5d4;
  pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[2] = (uint)((char)pvVar4 != '\0');
  puVar6[1] = sel_setState_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x11c5f2;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar3 = self->_loopButton;
  puVar6[1] = sel_loopSlideShow;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x11c60d;
  pvVar2 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[2] = (uint)((char)pvVar2 != '\0');
  puVar6[1] = sel_setState_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x11c62b;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  return;
}

*/
- (void)validateUIWithNotification:(id)aNotification
{
    id attributes = [self actionAttributes];
    HSTransition *transition = [attributes slideTransition];
    double duration = 0.0;
    if (transition == nil) {
        [_effectTransitionImageView setImage:nil];
        [_effectTransitionImageView setAlternateImage:nil];
    } else {
        id image = nil;
        id transitionName = [transition transitionName];
        if (transitionName != nil) {
            HSTransitionEffectProvider *provider = [HSTransitionEffectProvider sharedTransitionEffectProvider];
            id displayName = (provider != nil) ? [provider displayNameForTransitionEffectWithName:transitionName] : nil;
            if (displayName != nil) {
                [_transitionPopup selectItemWithTitle:displayName];
                image = [provider thumbnailForTransitionEffectWithName:transitionName];
                if (image != nil) {
                    NSRect frame = [_effectTransitionImageView frame];
                    if (frame.size.width > 0.0f && frame.size.height > 0.0f && !NSEqualSizes(frame.size, [image size])) {
                        NSImage *scaled = [[[NSImage alloc] initWithSize:frame.size] autorelease];
                        if (scaled != nil) {
                            [scaled lockFocus];
                            [image drawInRect:NSMakeRect(0.0f, 0.0f, frame.size.width, frame.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                            [scaled unlockFocus];
                            image = scaled;
                        }
                    }
                }
            }
        }
        [_effectTransitionImageView setImage:image];
        [_effectTransitionImageView setAlternateImage:image];
        duration = [transition duration];
        if (duration > 0.0) {
            [_durationSlider setDoubleValue:2.0 - duration];
        }
    }
    [_durationSlider setEnabled:(duration > 0.0)];
    [_slideDurationField setDoubleValue:[attributes slideDuration]];
    [_slideDurationStepper setDoubleValue:[attributes slideDuration]];
    [_returnToOriginalCardButton setState:[attributes returnsToOriginalCard] != 0];
    [_useClickOnExitCardButton setState:[attributes useClickOnExitCard] != 0];
    [_loopButton setState:[attributes loopSlideShow] != 0];
}

- (id)actionAttributes
{
    return [[self slideShowActionAssistantPaneApplier] slideShowActionAttributes];
}

- (id)actionType
{
    return [HSSlideShowAction actionType];
}

- (id)slideShowActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSSlideShowActionAssistantPaneApplier class];
}

- (void)dealloc
{
    [_effectTransitionView setDelegate:0];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"SlideshowAssistantPane"];
    return self;
}

@end

@implementation HSSlideShowActionAssistantPaneApplier

/* i386 ivar offsets: _initialTransitionName=0x30, _initialTransitionDuration=0x34, _initialSlideDuration=0x3c, _initialReturnsToOriginalCard=0x44, _initialLoopSlideshow=0x45, _initialUseClickOnExitCard=0x46, _transitionName=0x48, _transitionDuration=0x4c, _slideDuration=0x54, _returnsToOriginalCard=0x5c, _loopSlideshow=0x5d, _useClickOnExitCard=0x5e */

- (void)setUseClickOnExitCard:(BOOL)aCard
{
    if ((BOOL)_useClickOnExitCard != (aCard != NO)) {
        _useClickOnExitCard = aCard != NO;
        [self disableUndo];
        [[self slideShowActionAttributes] setUseClickOnExitCard:_useClickOnExitCard];
        [self enableUndo];
    }
}

- (void)setLoopSlideShow:(BOOL)aShow
{
    if ((BOOL)_loopSlideshow != (aShow != NO)) {
        _loopSlideshow = aShow != NO;
        [self disableUndo];
        [[self slideShowActionAttributes] setLoopSlideShow:_loopSlideshow];
        [self enableUndo];
    }
}

- (void)setReturnsToOriginalCard:(BOOL)aCard
{
    if ((BOOL)_returnsToOriginalCard != (aCard != NO)) {
        _returnsToOriginalCard = aCard != NO;
        [self disableUndo];
        [[self slideShowActionAttributes] setReturnsToOriginalCard:_returnsToOriginalCard];
        [self enableUndo];
    }
}

- (void)setSlideDuration:(double)aDuration
{
    if (_slideDuration != aDuration) {
        _slideDuration = aDuration;
        [self disableUndo];
        [[self slideShowActionAttributes] setSlideDuration:_slideDuration];
        [self enableUndo];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setTransitionDuration:(double)aDuration
{
    if (_transitionDuration != aDuration) {
        _transitionDuration = aDuration;
        [self disableUndo];
        [[[self slideShowActionAttributes] slideTransition] setDuration:_transitionDuration];
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
        [[[self slideShowActionAttributes] slideTransition] setTransitionName:_transitionName];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011b27b @ 0011b27b, 288 bytes * /

BOOL FUN_0011b27b(HSSlideShowActionAssistantPaneApplier *self,SEL _cmd)

{
  double dVar1;
  double dVar2;
  char cVar3;
  id pvVar4;
  double dVar5;
  double dVar6;
  HSSlideShowActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00351080;
  pvVar4 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar4 == '\0') {
    return '\0';
  }
  dVar1 = self->_initialSlideDuration;
  dVar2 = self->_slideDuration;
  if ((dVar1 != 0.0) || (NAN(dVar1))) {
    dVar5 = ABS(dVar1);
  }
  else {
    dVar5 = 1.0;
  }
  if ((dVar2 != 0.0) || (NAN(dVar2))) {
    dVar6 = ABS(dVar2);
  }
  else {
    dVar6 = 1.0;
  }
  if (dVar6 <= dVar5) {
    dVar6 = dVar5;
  }
  if (dVar6 * 1e-05 < ABS(dVar1 - dVar2)) {
    return '\0';
  }
  cVar3 = self->_initialReturnsToOriginalCard;
  if (cVar3 == '\0') {
LAB_0011b332:
    if (self->_returnsToOriginalCard != '\0') {
      return '\0';
    }
    if (cVar3 != '\0') goto LAB_0011b33c;
LAB_0011b346:
    if (self->_returnsToOriginalCard != '\0') {
      return '\0';
    }
  }
  else {
    if (self->_returnsToOriginalCard == '\0') {
      return '\0';
    }
    if (cVar3 == '\0') goto LAB_0011b332;
LAB_0011b33c:
    if (self->_returnsToOriginalCard == '\0') {
      return '\0';
    }
    if (cVar3 == '\0') goto LAB_0011b346;
  }
  if (self->_initialUseClickOnExitCard != '\0') {
    if (self->_useClickOnExitCard == '\0') {
      return '\0';
    }
    if (self->_initialUseClickOnExitCard != '\0') goto LAB_0011b363;
  }
  if (self->_useClickOnExitCard != '\0') {
    return '\0';
  }
LAB_0011b363:
  if (self->_transitionName != (id)0x0) {
    pvVar4 = _objc_msgSend(self->_initialTransitionName,sel_isEqualToString_,self->_transitionName);
    return (BOOL)pvVar4;
  }
  return self->_initialTransitionName == (id)0x0;
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual]) {
        return NO;
    }
    double initialDuration = _initialSlideDuration;
    double duration = _slideDuration;
    double initialMagnitude = (initialDuration == 0.0) ? 1.0 : fabs(initialDuration);
    double magnitude = (duration == 0.0) ? 1.0 : fabs(duration);
    if (fmax(magnitude, initialMagnitude) * 1e-05 < fabs(initialDuration - duration)) {
        return NO;
    }
    /* the original compares the returns-to-original-card flags twice and never the loop flags */
    if (_initialReturnsToOriginalCard != _returnsToOriginalCard) {
        return NO;
    }
    if (_initialUseClickOnExitCard != _useClickOnExitCard) {
        return NO;
    }
    if (_transitionName == nil) {
        return _initialTransitionName == nil;
    }
    return [_initialTransitionName isEqualToString:_transitionName];
}

- (void)makeCurrentEqualToInitial
{
    [_transitionName release];
    _transitionName = [_initialTransitionName retain];
    _transitionDuration = _initialTransitionDuration;
    _slideDuration = _initialSlideDuration;
    _returnsToOriginalCard = _initialReturnsToOriginalCard;
    _loopSlideshow = _initialLoopSlideshow;
    _useClickOnExitCard = _initialUseClickOnExitCard;
    [super makeCurrentEqualToInitial];
}

- (void)makeInitialEqualToCurrent
{
    [_initialTransitionName release];
    _initialTransitionName = [_transitionName retain];
    _initialTransitionDuration = _transitionDuration;
    _initialSlideDuration = _slideDuration;
    _initialReturnsToOriginalCard = _returnsToOriginalCard;
    _initialLoopSlideshow = _loopSlideshow;
    _initialUseClickOnExitCard = _useClickOnExitCard;
    [super makeInitialEqualToCurrent];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setInitialSettingsToObject
{
    id self_00;
    id self_01;

    self_00 = [self slideShowActionAttributes];
    self_01 = [self_00 slideTransition];
    [self_01 setTransitionName:_initialTransitionName];
    [self_01 setDuration:_initialTransitionDuration];
    [self_00 setSlideDuration:_initialSlideDuration];
    [self_00 setReturnsToOriginalCard:_initialReturnsToOriginalCard];
    [self_00 setLoopSlideShow:_initialLoopSlideshow];
    [self_00 setUseClickOnExitCard:_initialUseClickOnExitCard];
    [super setInitialSettingsToObject];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)setCurrentSettingsToObject
{
    id self_00;
    id self_01;

    [super setCurrentSettingsToObject];
    self_00 = [self slideShowActionAttributes];
    self_01 = [self_00 slideTransition];
    [self_01 setTransitionName:_transitionName];
    [self_01 setDuration:_transitionDuration];
    [self_00 setSlideDuration:_slideDuration];
    [self_00 setReturnsToOriginalCard:_returnsToOriginalCard];
    [self_00 setLoopSlideShow:_loopSlideshow];
    [self_00 setUseClickOnExitCard:_useClickOnExitCard];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011b6e5 @ 0011b6e5, 364 bytes * /

void FUN_0011b6e5(HSSlideShowActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_slideTransition);
  pvVar2 = _objc_msgSend(pvVar1,sel_transitionName);
  pvVar2 = _objc_msgSend(pvVar2,sel_copy);
  self->_initialTransitionName = pvVar2;
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_transitionName = pvVar2;
  *(undefined4 *)((int)&self->_initialTransitionDuration + 4) = 0;
  *(undefined4 *)&self->_initialTransitionDuration = 0;
  if (pvVar1 == (id)0x0) {
    dVar3 = 0.0;
  }
  else {
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_duration);
    self->_initialTransitionDuration = dVar3;
  }
  self->_transitionDuration = dVar3;
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAttributes);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_slideDuration);
  self->_slideDuration = dVar3;
  self->_initialSlideDuration = dVar3;
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_returnsToOriginalCard);
  self->_returnsToOriginalCard = (BOOL)pvVar1;
  self->_initialReturnsToOriginalCard = (BOOL)pvVar1;
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_loopSlideShow);
  self->_loopSlideshow = (BOOL)pvVar1;
  self->_initialLoopSlideshow = (BOOL)pvVar1;
  pvVar1 = _objc_msgSend(self,sel_slideShowActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_useClickOnExitCard);
  self->_useClickOnExitCard = (BOOL)pvVar1;
  self->_initialUseClickOnExitCard = (BOOL)pvVar1;
  return;
}

*/
- (void)setUpInitialSettings
{
    HSTransition *transition = [[self slideShowActionAttributes] slideTransition];
    _initialTransitionName = [[transition transitionName] copy];
    _transitionName = [_initialTransitionName retain];
    _initialTransitionDuration = 0.0;
    if (transition != nil) {
        _initialTransitionDuration = [transition duration];
    }
    _transitionDuration = _initialTransitionDuration;
    _initialSlideDuration = [[self slideShowActionAttributes] slideDuration];
    _slideDuration = _initialSlideDuration;
    _initialReturnsToOriginalCard = [[self slideShowActionAttributes] returnsToOriginalCard];
    _returnsToOriginalCard = _initialReturnsToOriginalCard;
    _initialLoopSlideshow = [[self slideShowActionAttributes] loopSlideShow];
    _loopSlideshow = _initialLoopSlideshow;
    _initialUseClickOnExitCard = [[self slideShowActionAttributes] useClickOnExitCard];
    _useClickOnExitCard = _initialUseClickOnExitCard;
}

- (id)slideShowActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSSlideShowActionAttributes)];
}

- (void)dealloc
{
    [_transitionName release];
    [_initialTransitionName release];
    [super dealloc];
}

@end

