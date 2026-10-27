#import "HSMovieStartingAssistantPane.h"

@implementation HSMovieStartingAssistantPane

/* i386 ivar offsets: _actorAttributes=0x5c, _playMovieActionAttributes=0x60, _moviePlaybackAttributes=0x64, _observerdStartingPlayableObjectAttributes=0x68, _movieObjectAttributes=0x6c, _containerView=0x70, _QTVRView=0x74, _movieView=0x78, _startOnArriveSwitchButton=0x7c, _startOnClickSwitchButton=0x80, _allowOtherMoviesSwitchButton=0x84, _allowOtherSoundsSwitchButton=0x88, _currentContentView=0x8c */

- (void)allowOtherSoundsDidChange:(id)aChange
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)] setHyperAllowPlayingOtherSounds:(unsigned int)([_allowOtherSoundsSwitchButton state] == 0)];
}

- (void)allowOtherMoviesDidChange:(id)aChange
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)] setHyperAllowPlayingOtherMovies:(unsigned int)([_allowOtherMoviesSwitchButton state] == 0)];
}

- (void)startingOnClickDidChange:(id)aChange
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)] setHyperStartingOnClick:(unsigned int)([_startOnClickSwitchButton state] == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024472f @ 0024472f, 105 bytes * /

void FUN_0024472f(HSMovieStartingAssistantPane *self,SEL _cmd,id startingOnArriveDidChange)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_startOnArriveSwitchButton,sel_state);
  op = sel_addMovieToAction;
  if ((pvVar1 == (id)0x1) ||
     (pvVar1 = _objc_msgSend(self->_startOnArriveSwitchButton,sel_state),
     op = sel_removeMovieFromAction, pvVar1 == (id)0x0)) {
    _objc_msgSend(self,op);
  }
  return;
}

*/
- (void)startingOnArriveDidChange:(id)aChange
{
    if ([_startOnArriveSwitchButton state] == 1) {
        [self addMovieToAction];
    } else if ([_startOnArriveSwitchButton state] == 0) {
        [self removeMovieFromAction];
    }
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    [self stopObservingChangesOfPlayableObjectAttributes];
    [self stopObservingChangesInPlayMovieActionAttributes];
    [self stopObservingChangesOfActorAttributes];
    [self stopObservingChangesInMovieObjectAttributes];
    [self setMoviePlaybackAttributes:nil];
    [_playMovieActionAttributes release];
    _playMovieActionAttributes = nil;
    [_actorAttributes release];
    _actorAttributes = nil;
    [_movieObjectAttributes release];
    _movieObjectAttributes = nil;
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00244b33 @ 00244b33, 506 bytes * /

void FUN_00244b33(HSMovieStartingAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  HSMovieStartingAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_003559d0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003851e0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_actorAttributes = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_alloc);
  self_00 = _objc_msgSend(pvVar1,sel_initWithActionEventType_,*(undefined4 *)PTR_00336080);
  pvVar1 = self->_actorAttributes;
  pvVar2 = _objc_msgSend(cls_HSPlayMovieAction,sel_actionType);
  pvVar4 = self_00;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionOfType_forEvent_,pvVar2,self_00);
  puVar3 = &DAT_00385118;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00385118);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playMovieActionAttributes = pvVar1;
  _objc_msgSend(self_00,sel_release);
  if (self->_playMovieActionAttributes != (id)0x0) {
    puVar3 = _objc_msgSend(self,sel_findMoviePlaybackAttributes,puVar3,pvVar4);
    _objc_msgSend(self,sel_setMoviePlaybackAttributes_,puVar3);
  }
  pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes,puVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_movieObjectAttributes = pvVar1;
  _objc_msgSend(self,sel_startObservingChangesOfActorAttributes);
  _objc_msgSend(self,sel_startObservingChangesInPlayMovieActionAttributes);
  _objc_msgSend(self,sel_startObservingChangesOfPlayableObjectAttributes);
  _objc_msgSend(self,sel_startObservingChangesInMovieObjectAttributes);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    _actorAttributes = [[[self card] queryHyperInterface:@protocol(HSActor)] retain];
    HSActionEvent *event = [[HSActionEvent alloc] initWithActionEventType:kHSArriveActionEventType];
    _playMovieActionAttributes = [[[_actorAttributes hyperActionOfType:[HSPlayMovieAction actionType] forEvent:event] queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] retain];
    [event release];
    if (_playMovieActionAttributes != nil) {
        [self setMoviePlaybackAttributes:[self findMoviePlaybackAttributes]];
    }
    _movieObjectAttributes = [[self movieObjectAttributes] retain];
    [self startObservingChangesOfActorAttributes];
    [self startObservingChangesInPlayMovieActionAttributes];
    [self startObservingChangesOfPlayableObjectAttributes];
    [self startObservingChangesInMovieObjectAttributes];
    [self validateUserInterface];
}

- (void)movieObjectAttributesDidChange:(id)aChange
{
    [self validateUserInterface];
}

- (void)stopObservingChangesInMovieObjectAttributes
{
    [[_movieObjectAttributes attributeObservingController] removeObserver:self selector:@selector(movieObjectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMovieObjectAttributes)];
}

- (void)startObservingChangesInMovieObjectAttributes
{
    [[_movieObjectAttributes attributeObservingController] addObserver:self selector:@selector(movieObjectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMovieObjectAttributes) withPriority:-0.25];
}

- (void)playableObjectAttributesDidChange:(id)aChange
{
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00244513 @ 00244513, 252 bytes * /

void FUN_00244513(HSMovieStartingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  
  if (self->_observerdStartingPlayableObjectAttributes != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSEProtocolSet,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithProtocols_,&DAT_00385064,&DAT_00385078,&DAT_0038508c,0
                          );
    self_00 = _objc_msgSend(self->_observerdStartingPlayableObjectAttributes,
                            sel_attributeObservingController);
    _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttributesFromSet_,self,
                  sel_playableObjectAttributesDidChange_,*(undefined4 *)PTR_0033601c,pvVar1);
    _objc_msgSend(self->_observerdStartingPlayableObjectAttributes,sel_release);
    self->_observerdStartingPlayableObjectAttributes = (id)0x0;
    _objc_msgSend(pvVar1,sel_release);
  }
  return;
}

*/
- (void)stopObservingChangesOfPlayableObjectAttributes
{
    if (_observerdStartingPlayableObjectAttributes != nil) {
        id attributes = [[NSEProtocolSet alloc] initWithProtocols:@protocol(HSPlayableObjectHyperStartingOnClickAttribute), @protocol(HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute), @protocol(HSPlayableObjectHyperAllowPlayingOtherSoundsAttribute), nil];
        [[_observerdStartingPlayableObjectAttributes attributeObservingController] removeObserver:self selector:@selector(playableObjectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:attributes];
        [_observerdStartingPlayableObjectAttributes release];
        _observerdStartingPlayableObjectAttributes = nil;
        [attributes release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002443d1 @ 002443d1, 322 bytes * /

void FUN_002443d1(HSMovieStartingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined *puVar2;
  
  if (self->_observerdStartingPlayableObjectAttributes == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    puVar2 = &DAT_00385050;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00385050);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_observerdStartingPlayableObjectAttributes = pvVar1;
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSEProtocolSet,sel_alloc,puVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithProtocols_,&DAT_00385064,&DAT_00385078,&DAT_0038508c
                             ,0);
      self_00 = _objc_msgSend(self->_observerdStartingPlayableObjectAttributes,
                              sel_attributeObservingController);
      _objc_msgSend(self_00,sel_addObserver_selector_ofChanges_ofAttributesFromSet_withPriority_,
                    self,sel_playableObjectAttributesDidChange_,*(undefined4 *)PTR_0033601c,pvVar1,
                    0xbe800000);
      _objc_msgSend(pvVar1,sel_release);
    }
  }
  return;
}

*/
- (void)startObservingChangesOfPlayableObjectAttributes
{
    if (_observerdStartingPlayableObjectAttributes == nil) {
        _observerdStartingPlayableObjectAttributes = [[[[self assistant] object] queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)] retain];
        if (_observerdStartingPlayableObjectAttributes != nil) {
            id attributes = [[NSEProtocolSet alloc] initWithProtocols:@protocol(HSPlayableObjectHyperStartingOnClickAttribute), @protocol(HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute), @protocol(HSPlayableObjectHyperAllowPlayingOtherSoundsAttribute), nil];
            [[_observerdStartingPlayableObjectAttributes attributeObservingController] addObserver:self selector:@selector(playableObjectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:attributes withPriority:-0.25];
            [attributes release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00244269 @ 00244269, 360 bytes * /

void FUN_00244269(HSMovieStartingAssistantPane *self,SEL _cmd,id actorAttributesDidChange)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_alloc);
  self_00 = _objc_msgSend(pvVar1,sel_initWithActionEventType_,*(undefined4 *)PTR_00336080);
  pvVar1 = self->_actorAttributes;
  pvVar2 = _objc_msgSend(cls_HSPlayMovieAction,sel_actionType);
  pvVar4 = self_00;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionOfType_forEvent_,pvVar2,self_00);
  puVar3 = &DAT_00385118;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00385118);
  _objc_msgSend(self_00,sel_release);
  if (self->_playMovieActionAttributes != pvVar1) {
    if (self->_playMovieActionAttributes != (id)0x0) {
      _objc_msgSend(self,sel_stopObservingChangesInPlayMovieActionAttributes,puVar3,pvVar4);
      _objc_msgSend(self->_playMovieActionAttributes,sel_release);
      self->_playMovieActionAttributes = (id)0x0;
    }
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_retain,puVar3,pvVar4);
      self->_playMovieActionAttributes = pvVar1;
      _objc_msgSend(self,sel_startObservingChangesInPlayMovieActionAttributes);
    }
    puVar3 = _objc_msgSend(self,sel_findMoviePlaybackAttributes,puVar3);
    _objc_msgSend(self,sel_setMoviePlaybackAttributes_,puVar3);
  }
  _objc_msgSend(self,sel_validateUserInterface,puVar3,pvVar4);
  return;
}

*/
- (void)actorAttributesDidChange:(id)aChange
{
    HSActionEvent *event = [[HSActionEvent alloc] initWithActionEventType:kHSArriveActionEventType];
    id attributes = [[_actorAttributes hyperActionOfType:[HSPlayMovieAction actionType] forEvent:event] queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
    [event release];
    if (_playMovieActionAttributes != attributes) {
        if (_playMovieActionAttributes != nil) {
            [self stopObservingChangesInPlayMovieActionAttributes];
            [_playMovieActionAttributes release];
            _playMovieActionAttributes = nil;
        }
        if (attributes != nil) {
            _playMovieActionAttributes = [attributes retain];
            [self startObservingChangesInPlayMovieActionAttributes];
        }
        [self setMoviePlaybackAttributes:[self findMoviePlaybackAttributes]];
    }
    [self validateUserInterface];
}

- (void)stopObservingChangesOfActorAttributes
{
    [[_actorAttributes attributeObservingController] removeObserver:self selector:@selector(actorAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute)];
}

- (void)startObservingChangesOfActorAttributes
{
    [[_actorAttributes attributeObservingController] addObserver:self selector:@selector(actorAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
}

- (void)moviesInActionDidChange:(id)aChange
{
    [self setMoviePlaybackAttributes:[self findMoviePlaybackAttributes]];
    [self validateUserInterface];
}

- (void)stopObservingChangesInPlayMovieActionAttributes
{
    [[_playMovieActionAttributes attributeObservingController] removeObserver:self selector:@selector(moviesInActionDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayMovieMoviesAttribute)];
}

- (void)startObservingChangesInPlayMovieActionAttributes
{
    [[_playMovieActionAttributes attributeObservingController] addObserver:self selector:@selector(moviesInActionDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayMovieMoviesAttribute) withPriority:-0.25];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00243ef1 @ 00243ef1, 382 bytes * /

void FUN_00243ef1(HSMovieStartingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSMovieStartingAssistantPane *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isHyperQTVR);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_mountContentView_,self->_movieView);
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00385050);
    pvVar1 = self->_startOnClickSwitchButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_isHyperStartingOnClick);
    _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar3 != '\0'));
    pvVar1 = self->_allowOtherMoviesSwitchButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_isHyperAllowPlayingOtherMovies);
    _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar3 == '\0'));
    pvVar1 = self->_allowOtherSoundsSwitchButton;
    pvVar2 = _objc_msgSend(pvVar2,sel_isHyperAllowPlayingOtherSounds);
    _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 == '\0'));
    self_00 = self->_startOnArriveSwitchButton;
    pvVar1 = (id)(uint)(self->_moviePlaybackAttributes != (id)0x0);
    op = sel_setState_;
  }
  else {
    pvVar1 = self->_QTVRView;
    self_00 = self;
    op = sel_mountContentView_;
  }
  _objc_msgSend(self_00,op,pvVar1);
  return;
}

*/
- (void)validateUserInterface
{
    if (![self isHyperQTVR]) {
        [self mountContentView:_movieView];
        id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)];
        [_startOnClickSwitchButton setState:[attributes isHyperStartingOnClick]];
        [_allowOtherMoviesSwitchButton setState:![attributes isHyperAllowPlayingOtherMovies]];
        [_allowOtherSoundsSwitchButton setState:![attributes isHyperAllowPlayingOtherSounds]];
        [_startOnArriveSwitchButton setState:(_moviePlaybackAttributes != nil)];
    } else {
        [self mountContentView:_QTVRView];
    }
}

- (void)removeMovieFromAction
{
    id self_00;
    id pvVar2;

    self_00 = _playMovieActionAttributes;
    if ((self_00 != nil) && (pvVar2 = _moviePlaybackAttributes, pvVar2 != nil)) {
        [self_00 removeMovie:pvVar2];
        if ([[self_00 movies] count] == 0) {
            if ([[self_00 liveVideos] count] == 0) {
                [_actorAttributes removeHyperAction:self_00 forEvent:[[self_00 events] extraFirstObject]];
            }
        }
    }
}

- (void)addMovieToAction
{
    id pvVar1;
    id pvVar2;
    id pvVar2_4;
    id pvVar2_5;

    pvVar1 = _playMovieActionAttributes;
    if (pvVar1 == nil) {
        pvVar2 = [[HSActionEvent alloc] initWithActionEventType:kHSArriveActionEventType];
        pvVar1 = [_actorAttributes addHyperActionOfType:[HSPlayMovieAction actionType] forEvent:pvVar2];
        [pvVar2 release];
    }
    pvVar2_4 = [[[self assistant] object] queryHyperInterface:@protocol(HSMovieObjectAttributes)];
    if (pvVar2_4 != nil) {
        if ([self findMoviePlaybackAttributes] == nil) {
            pvVar2_5 = [[HSMoviePlaybackItem alloc] initWithMovieObject:pvVar2_4 playMovieAction:pvVar1];
            [pvVar2_5 setEnabled:YES];
            [pvVar1 addMovie:pvVar2_5];
            [pvVar2_5 release];
        }
    }
}

- (void)mountContentView:(id)aView
{
    id self_00;

    if (_currentContentView != aView) {
        [_currentContentView removeFromSuperview];
        [_currentContentView release];
        self_00 = [aView retain];
        _currentContentView = self_00;
        [self_00 setFrame:[_containerView bounds]];
        [_containerView addSubview:_currentContentView];
    }
}

- (BOOL)isHyperQTVR
{
    BOOL bVar2;

    if (![[self movieObjectAttributes] isHyperQTVR]) {
        bVar2 = [[self movieObjectAttributes] isHyperPanoramaObject];
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (id)movieObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMovieObjectAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00243abd @ 00243abd, 271 bytes * /

id FUN_00243abd(HSMovieStartingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  undefined *puVar4;
  
  if (self->_playMovieActionAttributes == (id)0x0) {
LAB_00243ad6:
    pvVar3 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_playMovieActionAttributes,sel_movies);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    do {
      pvVar3 = _objc_msgSend(pvVar1,sel_nextObject);
      if (pvVar3 == (id)0x0) goto LAB_00243ad6;
      puVar4 = &DAT_00384ce0;
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00384ce0);
      if (pvVar3 == (id)0x0) {
        return (id)0x0;
      }
      pvVar2 = _objc_msgSend(self,sel_card,puVar4);
      self_00 = _objc_msgSend(pvVar3,sel_movieObjectForCard_,pvVar2);
      if (self_00 == (id)0x0) {
        return pvVar3;
      }
      pvVar2 = _objc_msgSend(self,sel_assistant,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_object);
      pvVar2 = _objc_msgSend(self_00,sel_isEqual_,pvVar2);
    } while ((char)pvVar2 == '\0');
  }
  return pvVar3;
}

*/
- (id)findMoviePlaybackAttributes
{
    if (_playMovieActionAttributes == nil) {
        return nil;
    }
    NSEnumerator *enumerator = [[_playMovieActionAttributes movies] objectEnumerator];
    id movie;
    while ((movie = [enumerator nextObject]) != nil) {
        id attributes = [movie queryHyperInterface:@protocol(HSMoviePlaybackAttributes)];
        if (attributes == nil) {
            return nil;
        }
        id object = [attributes movieObjectForCard:[self card]];
        if (object == nil) {
            return attributes;
        }
        if ([object isEqual:[[self assistant] object]]) {
            return attributes;
        }
    }
    return nil;
    return 0;
}

- (void)setMoviePlaybackAttributes:(id)aAttributes
{
    if (_moviePlaybackAttributes != aAttributes) {
        [_moviePlaybackAttributes release];
        _moviePlaybackAttributes = [aAttributes retain];
    }
}

- (id)moviePlaybackAttributes
{
    return _moviePlaybackAttributes;
}

- (void)dealloc
{
    [self stopObservingChangesInPlayMovieActionAttributes];
    [self stopObservingChangesOfActorAttributes];
    [self stopObservingChangesOfPlayableObjectAttributes];
    [self stopObservingChangesInMovieObjectAttributes];
    [_actorAttributes release];
    [_playMovieActionAttributes release];
    [_moviePlaybackAttributes release];
    [_movieObjectAttributes release];
    [_currentContentView release];
    [super dealloc];
}

- (id)init
{
    id self_00;

    self_00 = [self initWithNibName:@"MovieStartingAssistantPane"];
    if (self_00 != nil) {
        [self_00 setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Starting" value:@"" table:@"AssistantPanes"]];
        [self_00 setIcon:[NSImage imageNamed:@"starting_movie"]];
    }
    return self_00;
}

@end

