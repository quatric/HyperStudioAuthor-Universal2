#import "HSActionAssistantSettingsApplier.h"

@implementation HSActionAssistantSettingsApplier

/* i386 ivar offsets: _isInActor=0xc, _initialIsInActor=0xd, _actionType=0x10, _actionEvents=0x14, _action=0x18, _isToGoAction=0x1c, _previousToGoAction=0x20, _isNBA=0x24, _previousNBA=0x28, _actor=0x2c */

- (void)actionsDidChange:(id)aChange
{
    if ((_isInActor != NO) && (_action != nil)) {
        if ([_action owner] == nil) {
            [self invalidateActionAttributes];
        }
    }
}

- (BOOL)initialIsInActor
{
    return _initialIsInActor;
}

- (BOOL)isInActor
{
    return _isInActor;
}

- (BOOL)areSettingsEqual
{
    return _isInActor == _initialIsInActor;
}

- (void)makeCurrentEqualToInitial
{
    _isInActor = _initialIsInActor;
}

- (void)makeInitialEqualToCurrent
{
    _initialIsInActor = _isInActor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bcf31 @ 001bcf31, 280 bytes * /

void FUN_001bcf31(HSActionAssistantSettingsApplier *self,SEL _cmd)

{
  char cVar1;
  undefined *self_00;
  id self_01;
  id pvVar2;
  id pvVar3;
  HSActionAssistantSettingsApplier *pHVar4;
  SEL op;
  
  cVar1 = self->_initialIsInActor;
  if (self->_isInActor != cVar1) {
    self_01 = _objc_msgSend(self,sel_actor);
    self_00 = cls_NSArray;
    if (cVar1 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_actionAttributes);
      pvVar2 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar2);
      _objc_msgSend(self_01,sel_removeActions_,pvVar2);
      _objc_msgSend(self,sel_restorePreviousToGoActionIfNeeded);
      op = sel_restorePreviousNBAIfNeeded;
    }
    else {
      pvVar2 = _objc_msgSend(self->_actionEvents,sel_lastObject);
      pvVar3 = _objc_msgSend(self,sel_actionAttributes);
      _objc_msgSend(self_01,sel_addHyperAction_forEvent_,pvVar3,pvVar2);
      pHVar4 = _objc_msgSend(self,sel_actionAttributes);
      pvVar2 = self->_actionEvents;
      self = pHVar4;
      op = sel_setEvents_;
    }
    _objc_msgSend(self,op,pvVar2);
  }
  return;
}

*/
- (void)setInitialSettingsToObject
{
    if (_isInActor != _initialIsInActor) {
        id actor = [self actor];
        if (_initialIsInActor == NO) {
            [actor removeActions:[NSArray arrayWithObject:[self actionAttributes]]];
            [self restorePreviousToGoActionIfNeeded];
            [self restorePreviousNBAIfNeeded];
        } else {
            [actor addHyperAction:[self actionAttributes] forEvent:[_actionEvents lastObject]];
            [[self actionAttributes] setEvents:_actionEvents];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bd049 @ 001bd049, 280 bytes * /

void FUN_001bd049(HSActionAssistantSettingsApplier *self,SEL _cmd)

{
  char cVar1;
  undefined *self_00;
  id self_01;
  id pvVar2;
  id pvVar3;
  HSActionAssistantSettingsApplier *pHVar4;
  SEL op;
  
  cVar1 = self->_isInActor;
  if (cVar1 != self->_initialIsInActor) {
    self_01 = _objc_msgSend(self,sel_actor);
    self_00 = cls_NSArray;
    if (cVar1 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_actionAttributes);
      pvVar2 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar2);
      _objc_msgSend(self_01,sel_removeActions_,pvVar2);
      _objc_msgSend(self,sel_restorePreviousToGoActionIfNeeded);
      op = sel_restorePreviousNBAIfNeeded;
    }
    else {
      pvVar2 = _objc_msgSend(self->_actionEvents,sel_lastObject);
      pvVar3 = _objc_msgSend(self,sel_actionAttributes);
      _objc_msgSend(self_01,sel_addHyperAction_forEvent_,pvVar3,pvVar2);
      pHVar4 = _objc_msgSend(self,sel_actionAttributes);
      pvVar2 = self->_actionEvents;
      self = pHVar4;
      op = sel_setEvents_;
    }
    _objc_msgSend(self,op,pvVar2);
  }
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    if (_isInActor != _initialIsInActor) {
        id actor = [self actor];
        if (_isInActor == NO) {
            [actor removeActions:[NSArray arrayWithObject:[self actionAttributes]]];
            [self restorePreviousToGoActionIfNeeded];
            [self restorePreviousNBAIfNeeded];
        } else {
            [actor addHyperAction:[self actionAttributes] forEvent:[_actionEvents lastObject]];
            [[self actionAttributes] setEvents:_actionEvents];
        }
    }
}

- (id)undoActionName
{
    char cVar1;
    NSBundle *pvVar2;
    id pcVar3;

    cVar1 = _initialIsInActor;
    pvVar2 = [NSBundle mainBundle];
    if (cVar1 == NO) {
        pcVar3 = @"Add Action";
    }
    else {
        pcVar3 = @"Change Action";
    }
    return [pvVar2 localizedStringForKey:pcVar3 value:@"" table:@"UndoManager"];
}

- (void)invalidateActionAttributes
{
    [_action release];
    _action = nil;
}

- (void)removeActionFromActor
{
    if (_isInActor != NO) {
        _isInActor = NO;
        [self disableUndo];
        [[self actor] removeActions:[NSArray arrayWithObject:[self actionAttributes]]];
        [self restorePreviousToGoActionIfNeeded];
        [self restorePreviousNBAIfNeeded];
        [self enableUndo];
    }
}

- (void)addActionToActor
{
    id pvVar1;
    id pvVar2;

    if (_isInActor == NO) {
        _isInActor = YES;
        [self disableUndo];
        pvVar1 = [self actor];
        pvVar2 = [_actionEvents lastObject];
        [pvVar1 addHyperAction:[self actionAttributes] forEvent:pvVar2];
        [[self actionAttributes] setEvents:_actionEvents];
        [self enableUndo];
    }
}

- (void)restorePreviousNBAIfNeeded
{
    id pvVar2;
    id pvVar1_2;

    if (_isNBA != NO) {
        if ([self previousNBA] != nil) {
            pvVar1_2 = [self actor];
            pvVar2 = [_actionEvents lastObject];
            [pvVar1_2 addHyperAction:[self previousNBA] forEvent:pvVar2];
            [[self previousNBA] setEvents:_actionEvents];
        }
    }
}

- (void)restorePreviousToGoActionIfNeeded
{
    id pvVar2;
    id pvVar1_2;

    if (_isToGoAction != NO) {
        if ([self previousToGoAction] != nil) {
            pvVar1_2 = [self actor];
            pvVar2 = [_actionEvents lastObject];
            [pvVar1_2 addHyperAction:[self previousToGoAction] forEvent:pvVar2];
            [[self previousToGoAction] setEvents:_actionEvents];
        }
    }
}

- (void)setPreviousNBA:(id)aNBA
{
    if (_previousNBA != aNBA) {
        [_previousNBA release];
        _previousNBA = [aNBA retain];
    }
}

- (id)previousNBA
{
    return _previousNBA;
}

- (void)setPreviousToGoAction:(id)aAction
{
    if (_previousToGoAction != aAction) {
        [_previousToGoAction release];
        _previousToGoAction = [aAction retain];
    }
}

- (id)previousToGoAction
{
    return _previousToGoAction;
}

- (void)setUpInitialSettings
{

}

- (id)actionEvent
{
    return [_actionEvents lastObject];
}

- (id)actionAttributes
{
    id pvVar1;

    pvVar1 = _action;
    if (pvVar1 == nil) {
        pvVar1 = [[[self actor] hyperActionOfType:_actionType forEvent:[_actionEvents lastObject]] retain];
        _action = pvVar1;
        if (pvVar1 == nil) {
            pvVar1 = [[self actor] createActionOfType:_actionType forEvent:[_actionEvents lastObject]];
            _action = pvVar1;
        }
    }
    return pvVar1;
}

- (id)actor
{
    id pvVar1;
    id pvVar1_4;

    pvVar1 = _actor;
    if (pvVar1 == nil) {
        pvVar1_4 = [[[self object] queryHyperInterface:@protocol(HSActor)] retain];
        _actor = pvVar1_4;
        [[pvVar1_4 attributeObservingController] addObserver:self selector:@selector(actionsDidChange:) ofChanges:2 ofAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
        pvVar1 = _actor;
    }
    return pvVar1;
}

- (void)dealloc
{
    [_previousToGoAction release];
    [_previousNBA release];
    [_actionType release];
    [_actionEvents release];
    [_action release];
    [[_actor attributeObservingController] removeObserver:self selector:@selector(actionsDidChange:) ofChanges:2 ofAttribute:@protocol(HSActionsAttribute)];
    [_actor release];
    [super dealloc];
}

- (id)initWithObject:(id)aObject actionType:(id)aType actionEvents:(id)aEvents
{
    id pvVar2;
    id pvVar3;
    id pvVar1_3;
    id pvVar1_5;
    id pvVar1_7;
    BOOL pvVar1_9;
    id pvVar1_10;
    id pvVar1_12;
    id pvVar3_2;
    BOOL pvVar3_3;
    id pvVar4_2;
    id pvVar4_3;

    self = [super initWithObject:aObject];
    if (self != nil) {
        _actionType = [aType retain];
        _actionEvents = [aEvents retain];
        pvVar1_3 = [HSAvailableActionsProvider sharedAvailableActionsProvider];
        pvVar2 = [aEvents lastObject];
        pvVar3 = [HSToGoAction actionType];
        pvVar3_2 = [pvVar1_3 availableActionsOfType:pvVar3 forObject:aObject forEvent:pvVar2];
        pvVar3_3 = [pvVar3_2 containsObject:aType];
        _isToGoAction = pvVar3_3;
        if (pvVar3_3) {
            pvVar1_5 = [self actor];
            pvVar4_2 = [aEvents lastObject];
            [self setPreviousToGoAction:[pvVar1_5 hyperActionOfType:[HSToGoAction actionType] forEvent:pvVar4_2]];
        }
        pvVar1_7 = [HSAvailableActionsProvider sharedAvailableActionsProvider];
        pvVar4_3 = [aEvents lastObject];
        pvVar1_9 = [[pvVar1_7 availableActionsOfType:[HSNBAAction actionType] forObject:aObject forEvent:pvVar4_3] containsObject:aType];
        _isNBA = pvVar1_9;
        if (pvVar1_9) {
            pvVar1_10 = [self actor];
            aObject = [aEvents lastObject];
            aType = [pvVar1_10 hyperActionOfType:[HSNBAAction actionType] forEvent:aObject];
            [self setPreviousNBA:aType];
        }
        pvVar1_12 = [[self actor] hyperActionOfType:_actionType forEvent:[_actionEvents lastObject]];
        _isInActor = pvVar1_12 != nil;
        _initialIsInActor = pvVar1_12 != nil;
        [self setUpInitialSettings];
    }
    return self;
}

@end

