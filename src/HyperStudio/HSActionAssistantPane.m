#import "HSActionAssistantPane.h"

@implementation HSActionAssistantPane

/* i386 ivar offsets: _actionEvents=0x68, _paneSwitcher=0x6c, _observedActorAttributes=0x70, _actionAssistantPaneObserver=0x74 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00194e91 @ 00194e91, 212 bytes * /

id FUN_00194e91(HSActionAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar3 = &DAT_0037a650;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037a650);
  pvVar2 = _objc_msgSend(self,sel_actionType);
  pvVar2 = (id)_NSClassFromString(pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedNameInInspector);
  self_00 = cls_NSString;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperName,puVar3);
    pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr________,pvVar1,pvVar2);
  }
  return pvVar2;
}

*/
- (id)windowTitle
{
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    id name = [NSClassFromString([self actionType]) localizedNameInInspector];
    if (attributes != nil) {
        name = [NSString stringWithFormat:@"%@ : %@", [attributes hyperName], name];
    }
    return name;
    return 0;
}

- (id)helpTopicKey
{
    return @"HSActionNewButton";
}

- (void)paneWillGoBack:(id)aBack
{
    [self dismiss:YES];
}

- (void)willGoToNextPane
{
    _userMadeTheDecision = YES;
}

- (void)paneWillGoToInitial:(id)aInitial settingsCanceled:(BOOL)aCanceled
{
    [self removeActorObserver];
    _userMadeTheDecision = YES;
}

- (void)paneDidCancel:(id)aCancel
{
    [self removeActorObserver];
    [super paneDidCancel:aCancel];
    if ([_delegate respondsToSelector:@selector(actionPaneDidClose:withApplier:canceled:)]) {
        [_delegate actionPaneDidClose:self withApplier:[self applier] canceled:YES];
    }
}

- (void)paneDidOK:(id)aOK
{
    if ([[self window] makeFirstResponder:[self window]]) {
        [self removeActorObserver];
        [[self objectAssistantNavigationController] removeAllViewControllersWithIdentifier:@"HSRootAssistantPaneIdentifier"];
        [super paneDidOK:aOK];
        [self dismiss:YES slide:NO];
        if ([_delegate respondsToSelector:@selector(actionPaneDidClose:withApplier:canceled:)]) {
            [_delegate actionPaneDidClose:self withApplier:[self applier] canceled:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActorObserver];
    [[self navigationPaneSwitcher] setApplier:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[self navigationPaneSwitcher] setApplier:[self applier]];
    [self addActorObserver];
}

- (void)updateObjectWithApplier
{
    [super updateObjectWithApplier];
    [[self applier] addActionToActor];
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _paneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _paneSwitcher = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _paneSwitcher;
    }
    return pvVar1;
}

- (void)actorDidChageActions:(id)aActions
{
    if (![[[aActions object] hyperActions] containsObject:[[self applier] actionAttributes]]) {
        [[self navigationPaneSwitcher] setApplier:nil];
        [self dismiss:YES];
    }
}

- (void)removeActionAssistantPaneObserver
{
    [_actionAssistantPaneObserver removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:[self actionAttribute]];
    [_actionAssistantPaneObserver release];
    _actionAssistantPaneObserver = nil;
}

- (void)addActionAssistantPaneObserver
{
    id pvVar1_4;

    pvVar1_4 = [[[[self applier] actionAttributes] attributeObservingController] retain];
    _actionAssistantPaneObserver = pvVar1_4;
    [pvVar1_4 addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:[self actionAttribute] withPriority:-0.25]
    ;
}

- (id)actionAttribute
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)removeActorObserver
{
    [[_observedActorAttributes attributeObservingController] removeObserver:self selector:@selector(actorDidChageActions:) ofChanges:2 ofAttribute:@protocol(HSActionsAttribute)];
    [_observedActorAttributes release];
    _observedActorAttributes = nil;
}

- (void)addActorObserver
{
    id pvVar1_4;

    pvVar1_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSActor)] retain];
    _observedActorAttributes = pvVar1_4;
    [[pvVar1_4 attributeObservingController] addObserver:self selector:@selector(actorDidChageActions:) ofChanges:2 ofAttribute:@protocol(HSActionsAttribute) withPriority:0];
}

- (void)setActionEvent:(id)aEvent
{
    [self setActionEvents:[NSArray arrayWithObject:aEvent]];
}

- (id)actionEvent
{
    return [[self actionEvents] lastObject];
}

- (void)setActionEvents:(id)aEvents
{
    if (_actionEvents != aEvents) {
        [_actionEvents release];
        _actionEvents = [aEvents retain];
    }
}

- (id)actionEvents
{
    return _actionEvents;
}

- (id)applier
{
    id pvVar1;
    id pvVar2;
    id pvVar3;
    id pvVar1_3;

    pvVar1 = _applier;
    if (pvVar1 == nil) {
        pvVar1_3 = [[self applierClass] alloc];
        pvVar2 = [self actionEvents];
        pvVar3 = [self actionType];
        pvVar1 = [pvVar1_3 initWithObject:[[self assistant] object] actionType:pvVar3 actionEvents:pvVar2];
        _applier = pvVar1;
    }
    return pvVar1;
}

- (id)actionType
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    [self removeActorObserver];
    [_actionAssistantPaneObserver removeAttributeObserver:self];
    [_actionAssistantPaneObserver release];
    [_actionEvents release];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [super dealloc];
}

@end

