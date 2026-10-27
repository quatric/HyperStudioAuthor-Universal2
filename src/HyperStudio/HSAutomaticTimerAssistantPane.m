#import "HSAutomaticTimerAssistantPane.h"

@implementation HSAutomaticTimerAssistantPane

/* i386 ivar offsets: _timerTypeMatrix=0x68, _delayField=0x6c, _delayStepper=0x70, _repeatingSwitch=0x74, _delayBetweenRepeatingActionsField=0x78, _delayBetweenRepeatingActionsStepper=0x7c, _observedActorAttributes=0x80, _paneSwitcher=0x84, _actionEvent=0x88, _isDelayBetweenRepeatingActionsSet=0x8c */

- (void)validateUserInterfaceWithNotification:(id)aNotification
{
    [self setupUIElements];
}

- (void)delayBetweenRepeatingActionsChanged:(id)aChanged
{
    double dVar2;
    double local_24;
    id pvVar1_2;

    dVar2 = [aChanged doubleValue];
    local_24 = 1e-09;
    if (dVar2 != 0.0) {
        local_24 = dVar2;
    }
    [[self HSAutomaticTimerAssistantPane_applier] setDelayBetweenRepeatingActions:local_24];
    pvVar1_2 = _delayBetweenRepeatingActionsField;
    if (pvVar1_2 == aChanged) {
        pvVar1_2 = _delayBetweenRepeatingActionsStepper;
    }
    [pvVar1_2 setDoubleValue:local_24];
}

- (void)repeatingChanged:(id)aChanged
{
    NSInteger pvVar1;
    BOOL uVar3;
    double dVar4;
    double local_2c;

    pvVar1 = [aChanged state];
    if (pvVar1 == 0x1) {
        if (_isDelayBetweenRepeatingActionsSet == NO) {
            dVar4 = [[self automaticTimer] delayBeforeRunActionsAutomatically];
            _isDelayBetweenRepeatingActionsSet = YES;
        }
        else {
            dVar4 = [_delayBetweenRepeatingActionsField doubleValue];
        }
        local_2c = 1e-09;
        if (dVar4 != 0.0) {
            local_2c = dVar4;
        }
        [_delayBetweenRepeatingActionsField setDoubleValue:local_2c];
        [_delayBetweenRepeatingActionsStepper setDoubleValue:local_2c];
    }
    else {
        local_2c = 0.0;
    }
    [[self HSAutomaticTimerAssistantPane_applier] setDelayBetweenRepeatingActions:local_2c];
    uVar3 = (unsigned int)(pvVar1 == 0x1);
    [_delayBetweenRepeatingActionsField setEnabled:uVar3];
    [_delayBetweenRepeatingActionsStepper setEnabled:uVar3];
}

- (void)delayChanged:(id)aChanged
{
    double dVar2;
    double local_24;
    id pvVar1_2;

    dVar2 = [aChanged doubleValue];
    local_24 = 1e-09;
    if (dVar2 != 0.0) {
        local_24 = dVar2;
    }
    [[self HSAutomaticTimerAssistantPane_applier] setDelay:local_24];
    pvVar1_2 = _delayField;
    if (pvVar1_2 == aChanged) {
        pvVar1_2 = _delayStepper;
    }
    [pvVar1_2 setDoubleValue:local_24];
}

- (void)timerTypeChanged:(id)aChanged
{
    double local_1c;

    if ([_timerTypeMatrix selectedRow] == 0x1) {
        local_1c = [_delayField doubleValue];
        if (local_1c == 0.0) {
            local_1c = 1e-09;
        }
    }
    else {
        local_1c = 0.0;
    }
    [[self HSAutomaticTimerAssistantPane_applier] setDelay:local_1c];
    [self validateUserInterface];
}

- (id)actionEvent
{
    return _actionEvent;
}

- (void)setActionEvent:(id)aEvent
{
    [aEvent retain];
    [_actionEvent release];
    _actionEvent = aEvent;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e58b2 @ 000e58b2, 342 bytes * /

id FUN_000e58b2(HSAutomaticTimerAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  undefined *self_00;
  SEL op;
  undefined *puVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar5 = &DAT_0036cc58;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036cc58);
  self_00 = cls_NSString;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar5);
    pcVar3 = &cfstr_AssistantPanes;
    pcVar4 = &cfstr_empty;
    pcVar6 = &cfstr_Automatic_timer_actions;
    self_00 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                            &cfstr_Automatic_timer_actions,&cfstr_empty,&cfstr_AssistantPanes);
    op = sel_hyperStringByAddingEllipsis;
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_Automatic_timer_actions,&cfstr_empty,&cfstr_AssistantPanes);
    pcVar3 = _objc_msgSend(pvVar2,sel_hyperStringByAddingEllipsis);
    pcVar4 = _objc_msgSend(pvVar1,sel_hyperName);
    pcVar6 = &cfstr________;
    op = sel_stringWithFormat_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pcVar6,pcVar4,pcVar3);
  return pvVar1;
}

*/
- (id)windowTitle
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Automatic timer actions" value:@"" table:@"AssistantPanes"];
    if (attributes == nil) {
        return [title hyperStringByAddingEllipsis];
    }
    return [NSString stringWithFormat:@"%@ : %@", [attributes hyperName], [title hyperStringByAddingEllipsis]];
    return 0;
}

- (id)helpTopicKey
{
    return @"HSAutomaticTimer";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self setObservedActorAttributes:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[self HSAutomaticTimerAssistantPane_applier] setRunActionsAutomatically:YES];
    [self setObservedActorAttributes:[self actor]];
    [self setupUIElements];
}

- (void)setObservedActorAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedActorAttributes != aAttributes) {
        pvVar2 = [_observedActorAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUserInterfaceWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSActor)];
        [_observedActorAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedActorAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUserInterfaceWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSActor) withPriority:-0.25];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e606f @ 000e606f, 624 bytes * /

void FUN_000e606f(HSAutomaticTimerAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  uint uVar2;
  double dVar3;
  double dVar4;
  undefined8 in_stack_ffffffbc;
  undefined4 uVar6;
  undefined8 uVar5;
  
  uVar6 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_automaticTimer);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_delayBeforeRunActionsAutomatically);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  uVar5 = CONCAT44(uVar6,&DAT_0036cd0c);
  pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036cd0c);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_timerTypeMatrix,sel_cells,uVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0);
    _objc_msgSend(pvVar1,sel_setTitle_,&cfstr_as_soon_as_card_is_shown);
  }
  uVar2 = (uint)(dVar3 != 0.0);
  dVar4 = (double)(ulonglong)uVar2;
  _objc_msgSend(self->_timerTypeMatrix,sel_selectCellAtRow_column_,uVar2,0);
  if (dVar3 != 0.0) {
    _objc_msgSend(self->_delayField,sel_setDoubleValue_,dVar3);
    _objc_msgSend(self->_delayStepper,sel_setDoubleValue_,dVar3);
    dVar4 = dVar3;
  }
  pvVar1 = _objc_msgSend(self,sel_automaticTimer,dVar4);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_delayBetweenRepeatingActions);
  _objc_msgSend(self->_repeatingSwitch,sel_setState_,(uint)(0.0 < dVar3));
  pvVar1 = _objc_msgSend(self->_delayBetweenRepeatingActionsField,sel_formatter);
  pvVar1 = _objc_msgSend(pvVar1,sel_minimum);
  dVar4 = _objc_msgSend_fpret(pvVar1,sel_doubleValue);
  if (dVar3 <= 0.0) {
    dVar3 = dVar4;
  }
  _objc_msgSend(self->_delayBetweenRepeatingActionsField,sel_setDoubleValue_,dVar3);
  _objc_msgSend(self->_delayBetweenRepeatingActionsStepper,sel_setDoubleValue_,dVar3);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)setupUIElements
{
    double delay = [[self automaticTimer] delayBeforeRunActionsAutomatically];
    if ([[[self assistant] object] implementsHyperInterface:@protocol(HSCardAttributes)]) {
        [[[_timerTypeMatrix cells] objectAtIndex:0] setTitle:@"as soon as card is shown"];
    }
    [_timerTypeMatrix selectCellAtRow:(delay != 0.0) column:0];
    if (delay != 0.0) {
        [_delayField setDoubleValue:delay];
        [_delayStepper setDoubleValue:delay];
    }
    double repeatDelay = [[self automaticTimer] delayBetweenRepeatingActions];
    [_repeatingSwitch setState:(0.0 < repeatDelay)];
    double minimum = [[[_delayBetweenRepeatingActionsField formatter] minimum] doubleValue];
    if (repeatDelay <= 0.0) {
        repeatDelay = minimum;
    }
    [_delayBetweenRepeatingActionsField setDoubleValue:repeatDelay];
    [_delayBetweenRepeatingActionsStepper setDoubleValue:repeatDelay];
    [self validateUserInterface];
}

- (void)validateUserInterface
{
    NSInteger pvVar1;
    NSInteger pvVar1_2;

    pvVar1 = [_timerTypeMatrix selectedRow];
    [_delayField setEnabled:(unsigned int)(pvVar1 != 0)];
    [_delayStepper setEnabled:(unsigned int)(pvVar1 != 0)];
    pvVar1_2 = [_repeatingSwitch state];
    [_delayBetweenRepeatingActionsField setEnabled:(unsigned int)(pvVar1_2 == 0x1)];
    [_delayBetweenRepeatingActionsStepper setEnabled:(unsigned int)(pvVar1_2 == 0x1)];
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

- (id)automaticTimer
{
    return [[self HSAutomaticTimerAssistantPane_applier] automaticTimer];
}

- (id)actor
{
    return [[self HSAutomaticTimerAssistantPane_applier] actor];
}

- (Class)applierClass
{
    return [HSAutomaticTimerAssistantPaneApplier class];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    [[_observedActorAttributes attributeObservingController] removeAttributeObserver:self];
    [_observedActorAttributes release];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [[self applier] setDelegate:0];
    [super dealloc];
}

- (id)HSAutomaticTimerAssistantPane_applier
{
    return [self applier];
}

- (id)init
{
    self = [super initWithNibName:@"AutomaticTimerAssistantPane"];
    return self;
}

@end

@implementation HSAutomaticTimerAssistantPaneApplier

/* i386 ivar offsets: _initialRunActionsAutomatically=0xc, _initialDelay=0x10, _initialDelayBetweenRepeatingActions=0x18, _runActionsAutomatically=0x20, _delay=0x24, _delayBetweenRepeatingActions=0x2c, _runActionsImmediatedly=0x34, _actionEvent=0x38 */

- (id)actionEvent
{
    id pvVar1_3;

    if (![[self delegate] respondsToSelector:@selector(actionEvent)]) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [[self delegate] performSelector:@selector(actionEvent)];
    }
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e512b @ 000e512b, 52 bytes * /

BOOL FUN_000e512b(HSAutomaticTimerAssistantPaneApplier *self,SEL _cmd)

{
  if ((((self->_initialDelayBetweenRepeatingActions == self->_delayBetweenRepeatingActions) &&
       (!NAN(self->_initialDelayBetweenRepeatingActions) &&
        !NAN(self->_delayBetweenRepeatingActions))) && (self->_initialDelay == self->_delay)) &&
     (!NAN(self->_initialDelay) && !NAN(self->_delay))) {
    return self->_initialRunActionsAutomatically == self->_runActionsAutomatically;
  }
  return '\0';
}

*/
- (BOOL)areSettingsEqual
{
    return _initialDelayBetweenRepeatingActions == _delayBetweenRepeatingActions && _initialDelay == _delay
        && _initialRunActionsAutomatically == _runActionsAutomatically;
    return 0;
}

- (void)setUpInitialSettings
{
    double dVar2;
    BOOL pvVar1_2;
    double dVar2_2;

    pvVar1_2 = [[self automaticTimer] runActionsAutomatically];
    _runActionsAutomatically = (BOOL)pvVar1_2;
    _initialRunActionsAutomatically = (BOOL)pvVar1_2;
    dVar2 = [[self automaticTimer] delayBeforeRunActionsAutomatically];
    _delay = dVar2;
    _initialDelay = dVar2;
    dVar2_2 = [[self automaticTimer] delayBetweenRepeatingActions];
    _delayBetweenRepeatingActions = dVar2_2;
    _initialDelayBetweenRepeatingActions = dVar2_2;
}

- (void)makeCurrentEqualToInitial
{
    _runActionsAutomatically = _initialRunActionsAutomatically;
    _delay = _initialDelay;
    _delayBetweenRepeatingActions = _initialDelayBetweenRepeatingActions;
}

- (void)makeInitialEqualToCurrent
{
    _initialRunActionsAutomatically = _runActionsAutomatically;
    _initialDelay = _delay;
    _initialDelayBetweenRepeatingActions = _delayBetweenRepeatingActions;
}

- (void)setInitialSettingsToObject
{
    [[self automaticTimer] setRunActionsAutomatically:_initialRunActionsAutomatically];
    [[self automaticTimer] setDelayBeforeRunActionsAutomatically:_initialDelay];
    [[self automaticTimer] setDelayBetweenRepeatingActions:_initialDelayBetweenRepeatingActions];
}

- (void)setCurrentSettingsToObject
{
    [[self automaticTimer] setRunActionsAutomatically:_runActionsAutomatically];
    [[self automaticTimer] setDelayBeforeRunActionsAutomatically:_delay];
    [[self automaticTimer] setDelayBetweenRepeatingActions:_delayBetweenRepeatingActions];
}

- (void)setDelayBetweenRepeatingActions:(double)aActions
{
    [self disableUndo];
    _delayBetweenRepeatingActions = aActions;
    [[self automaticTimer] setDelayBetweenRepeatingActions:_delayBetweenRepeatingActions];
    [self enableUndo];
}

- (void)setDelay:(double)aDelay
{
    [self disableUndo];
    _delay = aDelay;
    [[self automaticTimer] setDelayBeforeRunActionsAutomatically:_delay];
    [self enableUndo];
}

- (void)setRunActionsAutomatically:(BOOL)aAutomatically
{
    [self disableUndo];
    _runActionsAutomatically = aAutomatically;
    [[self automaticTimer] setRunActionsAutomatically:_runActionsAutomatically];
    [self enableUndo];
}

- (id)undoActionName
{
    NSBundle *self_00;
    id pcVar2;
    BOOL pvVar1_2;

    pvVar1_2 = [[self automaticTimer] runActionsAutomatically];
    self_00 = [NSBundle mainBundle];
    if (!pvVar1_2) {
        pcVar2 = @"Add Action";
    }
    else {
        pcVar2 = @"Change Action";
    }
    return [self_00 localizedStringForKey:pcVar2 value:@"" table:@"UndoManager"];
}

- (void)dealloc
{
    [_actionEvent release];
    [super dealloc];
}

- (id)automaticTimer
{
    return [[self actor] automaticTimerForActionEvent:[self actionEvent]];
}

- (id)actor
{
    return [[self object] queryHyperInterface:@protocol(HSActor)];
}

@end

