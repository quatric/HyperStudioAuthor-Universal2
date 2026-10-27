#import "HSNBAApplier.h"

@implementation HSNBAApplier

/* i386 ivar offsets: _initialActionEvent=0xc, _initialAction=0x10, _actionEvent=0x14, _action=0x18 */

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Add Action" value:@"" table:@"UndoManager"];
}

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    if ((_actionEvent != nil || _initialActionEvent != nil) && (pvVar1 = [_actionEvent isEqual:_initialActionEvent], !pvVar1)) {
        return NO;
    }
    if (_action == nil && _initialAction == nil) {
        bVar2 = YES;
    }
    else {
        bVar2 = [_action isEqual:_initialAction];
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [_actionEvent release];
    [_action release];
    _actionEvent = [_initialActionEvent retain];
    _action = [_initialAction retain];
}

- (void)makeInitialEqualToCurrent
{
    [_initialActionEvent release];
    [_initialAction release];
    _initialActionEvent = [_actionEvent retain];
    _initialAction = [_action retain];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8871 @ 000f8871, 165 bytes * /

void FUN_000f8871(HSNBAApplier *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  SEL op;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_actor);
  if (self->_initialAction == (id)0x0) {
    pvVar2 = self->_actionEvent;
    pvVar1 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
    op = sel_removeHyperActionsOfType_forEvent_;
  }
  else {
    pvVar2 = self->_initialActionEvent;
    pvVar1 = _objc_msgSend(self->_initialAction,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_actionType);
    op = sel_addHyperActionOfType_forEvent_;
  }
  _objc_msgSend(self_00,op,pvVar1,pvVar2);
  return;
}

*/
- (void)setInitialSettingsToObject
{
    id actor = [self actor];
    if (_initialAction == nil) {
        [actor removeHyperActionsOfType:[HSNBAAction actionType] forEvent:_actionEvent];
    }
    else {
        [actor addHyperActionOfType:[[_initialAction class] actionType] forEvent:_initialActionEvent];
    }
}

- (void)setCurrentSettingsToObject
{
    id self_00;
    id pvVar2;
    id pvVar2_2;
    id pvVar2_3;

    self_00 = [self actor];
    [self disableUndo];
    [self_00 removeHyperAction:_action forEvent:_actionEvent];
    pvVar2 = _initialAction;
    if (pvVar2 != nil) {
        [self_00 addHyperAction:pvVar2 forEvent:_initialActionEvent];
    }
    [self enableUndo];
    pvVar2_2 = _initialAction;
    if (pvVar2_2 != nil) {
        [self_00 removeHyperAction:pvVar2_2 forEvent:_initialActionEvent];
    }
    pvVar2_3 = _actionEvent;
    [self_00 addHyperActionOfType:[[_action class] actionType] forEvent:pvVar2_3];
}

- (id)addHyperActionOfType:(id)aType forEvent:(id)aEvent
{
    id pvVar1_2;

    [self disableUndo];
    pvVar1_2 = [[self actor] addHyperActionOfType:aType forEvent:aEvent];
    [self enableUndo];
    [_action release];
    _action = [[[self actor] hyperActionOfType:[HSNBAAction actionType]] retain];
    [_actionEvent release];
    _actionEvent = [aEvent retain];
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f8b30 @ 000f8b30, 196 bytes * /

id FUN_000f8b30(HSNBAApplier *self,SEL _cmd,id initWithObject,id actionEvent)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  HSNBAApplier *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSAssistantPaneApplier_00350a20;
  self_00 = _objc_msgSendSuper(&local_1c,sel_initWithObject_,initWithObject);
  if (self_00 != (id)0x0) {
    pvVar2 = _objc_msgSend(actionEvent,sel_retain);
    *(id *)((int)self_00 + 0xc) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_actor);
    uVar1 = *(undefined4 *)((int)self_00 + 0xc);
    pvVar3 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionOfType_forEvent_,pvVar3,uVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    *(id *)((int)self_00 + 0x10) = pvVar2;
  }
  return self_00;
}

*/
- (id)initWithObject:(id)aObject actionEvent:(id)aEvent
{
    self = [super initWithObject:aObject];
    if (self != nil) {
        _initialActionEvent = [aEvent retain];
        _initialAction = [[[self actor] hyperActionOfType:[HSNBAAction actionType] forEvent:_initialActionEvent] retain];
    }
    return self;
}

- (void)dealloc
{
    [_initialActionEvent release];
    [_initialAction release];
    [_actionEvent release];
    [_action release];
    [super dealloc];
}

- (id)actor
{
    return [[self object] queryHyperInterface:@protocol(HSActor)];
}

@end

static NSInteger HSCompareNBAActionTypes(id aType1, id aType2, void *aContext)
{
    return [[NSClassFromString(aType1) localizedName] compare:[NSClassFromString(aType2) localizedName]];
}

@implementation HSNewButtonActionsAssistantPane

/* i386 ivar offsets: _actionsTable=0x5c, _actionDescriptionView=0x60, _segmentedControl=0x64, _actionEvent=0x68, _availableNewButtonActions=0x6c, _newButtonActions=0x70, _buttonBackgroundRenderer=0x74, _enabledButtonBackgroundRenderer=0x78, _applier=0x7c, _navigationPaneSwitcher=0x80 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f6173 @ 000f6173, 813 bytes * /

void FUN_000f6173(HSNewButtonActionsAssistantPane *self,SEL _cmd,id tableDoubleAction)

{
  id pvVar1;
  id pvVar2;
  HSNewButtonActionsAssistantPane *self_00;
  id pvVar3;
  id pvVar4;
  HSNewButtonActionsAssistantPane *pHVar5;
  SEL pcVar6;
  undefined *self_01;
  undefined *puVar7;
  cfstringStruct *pcVar8;
  
  pvVar1 = _objc_msgSend(self->_actionsTable,sel_clickedRow);
  pvVar2 = _objc_msgSend(self->_actionsTable,sel_clickedColumn);
  if (pvVar1 == (id)0xffffffff) {
    return;
  }
  if (pvVar2 == (id)0xffffffff) {
    return;
  }
  self_00 = _objc_msgSend(self->_newButtonActions,sel_objectAtIndex_,pvVar1);
  pHVar5 = self_00;
  pvVar1 = _objc_msgSend(self,sel_isEnabledActionOfType_,self_00);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self->_actionsTable,sel_tableColumns,pHVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar2);
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  puVar7 = &DAT_0036ed8c;
  pvVar2 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_0036ed8c);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_assistant,puVar7);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    puVar7 = &DAT_0036eddc;
    pvVar2 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_0036eddc);
    self_01 = cls_HSActor;
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_assistant,puVar7);
      pvVar2 = _objc_msgSend(pvVar2,sel_object);
      pcVar6 = sel_actionEventsForObject_;
      goto LAB_000f631a;
    }
  }
  self_01 = cls_NSArray;
  pvVar2 = _objc_msgSend(self,sel_actionEvent,puVar7);
  pcVar6 = sel_arrayWithObject_;
LAB_000f631a:
  pvVar2 = _objc_msgSend(self_01,pcVar6,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_identifier);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSActionNameFieldTableColumnIdentifier);
  if ((char)pvVar1 != '\0') {
    pcVar8 = &cfstr_HSNoneNBAActionType;
    pvVar1 = _objc_msgSend(self_00,sel_isEqual_,&cfstr_HSNoneNBAActionType);
    pcVar6 = sel_openAssistantPaneForActionType_forEvents_;
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self,sel_revertSettings,pcVar8);
      pvVar1 = _objc_msgSend(cls_HSActionAssistantSettingsApplier,sel_alloc);
      pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pvVar2);
      pvVar2 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
      pvVar4 = _objc_msgSend(self,sel_assistant);
      pvVar4 = _objc_msgSend(pvVar4,sel_object);
      pHVar5 = _objc_msgSend(pvVar1,sel_initWithObject_actionType_actionEvents_,pvVar4,pvVar2,pvVar3
                            );
      self_00 = pHVar5;
      _objc_msgSend(self,sel_setApplier_,pHVar5);
      _objc_msgSend(pHVar5,sel_removeActionFromActor);
      self = pHVar5;
      pcVar6 = sel_release;
    }
    _objc_msgSend(self,pcVar6,self_00,pvVar2);
  }
  return;
}

*/
- (void)tableDoubleAction:(id)aAction
{
    NSInteger row = [_actionsTable clickedRow];
    NSInteger column = [_actionsTable clickedColumn];
    id actionType;
    id tableColumn;
    id object;
    id events;
    id applier;
    if (row == -1 || column == -1) {
        return;
    }
    actionType = [_newButtonActions objectAtIndex:row];
    if (![self isEnabledActionOfType:actionType]) {
        return;
    }
    tableColumn = [[_actionsTable tableColumns] objectAtIndex:column];
    object = [[self assistant] object];
    if ([object implementsHyperInterface:@protocol(HSCardAttributes)] || [[[self assistant] object] implementsHyperInterface:@protocol(HSStackAttributes)]) {
        events = [NSArray arrayWithObject:[self actionEvent]];
    }
    else {
        events = [HSActor actionEventsForObject:[[self assistant] object]];
    }
    if (![[tableColumn identifier] isEqual:@"HSActionNameFieldTableColumnIdentifier"]) {
        return;
    }
    if ([actionType isEqual:@"HSNoneNBAActionType"]) {
        [self revertSettings];
        // The original wraps the event list in another array here.
        applier = [[HSActionAssistantSettingsApplier alloc] initWithObject:[[self assistant] object] actionType:[HSNBAAction actionType] actionEvents:[NSArray arrayWithObject:events]];
        [self setApplier:applier];
        [applier removeActionFromActor];
        [applier release];
    }
    else {
        [self openAssistantPaneForActionType:actionType forEvents:events];
    }
}

- (void)actionsSourceChanged:(id)aChanged
{
    id pvVar1;

    pvVar1 = [self currentActions];
    if (_newButtonActions != pvVar1) {
        [_newButtonActions release];
        _newButtonActions = [pvVar1 retain];
        [_actionsTable reloadData];
    }
}

- (void)disabledActionsListDidChange:(id)aChange
{
    [_actionsTable reloadData];
}

- (BOOL)isEnabledActionOfType:(id)aType
{
    id self_00;
    id pvVar2;
    BOOL bVar3;

    if (![aType isEqual:@"HSNoneNBAActionType"]) {
        self_00 = [HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory];
        pvVar2 = [self_00 actionTypeToAssistantMap];
        if ([pvVar2 objectForKey:aType] == nil) {
            bVar3 = NO;
        }
        else {
            bVar3 = ![[self_00 disabledActionTypes] containsObject:aType];
        }
    }
    else {
        bVar3 = YES;
    }
    return bVar3;
}

- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    NSBundle *self_00;
    id pcVar2;
    BOOL pvVar1_2;

    pvVar1_2 = [[aColumn identifier] isEqual:@"HSActionEnabledCheckboxTableColumnIdentifier"];
    self_00 = [NSBundle mainBundle];
    if (!pvVar1_2) {
        pcVar2 = @"NBA name tooltip";
    }
    else {
        pcVar2 = @"Radio button tooltip";
    }
    return [self_00 localizedStringForKey:pcVar2 value:@"" table:@"AssistantPanes"];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    [self validateActionDescription];
    if ([_actionsTable selectedRow] == 0) {
        [self updateInUseTab];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f6702 @ 000f6702, 1038 bytes * /

void FUN_000f6702(HSNewButtonActionsAssistantPane *self,SEL _cmd,id tableView,id willDisplayCell,
                 id forTableColumn,int row)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  SEL pcVar5;
  char cVar6;
  double dVar7;
  undefined4 uVar8;
  cfstringStruct *pcVar9;
  
  pvVar1 = _objc_msgSend(self->_newButtonActions,sel_objectAtIndex_,row);
  pvVar2 = _objc_msgSend(self,sel_isEnabledActionOfType_,pvVar1);
  _objc_msgSend(willDisplayCell,sel_setEnabled_,(int)(char)pvVar2);
  pvVar2 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar4 = &cfstr_HSActionEnabledCheckboxTableColumnIdentifier;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSActionEnabledCheckboxTableColumnIdentifier);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_tableView_objectValueForTableColumn_row_,tableView,
                           forTableColumn,row);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    _objc_msgSend(willDisplayCell,sel_setState_,(uint)((char)pvVar1 != '\0'));
    pvVar2 = (id)0x1;
    pvVar1 = willDisplayCell;
    pcVar5 = sel_setImagePosition_;
    goto LAB_000f6809;
  }
  pvVar3 = _objc_msgSend(self,sel_actor,pcVar4);
  pcVar4 = _objc_msgSend(self,sel_actionEvent);
  pvVar2 = pvVar1;
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperActionOfType_forEvent_,pvVar1,pcVar4);
  if (pvVar3 == (id)0x0) {
LAB_000f6899:
    cVar6 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSActionSettingsAssistantFactory,
                           sel_sharedActionSettingsAssistantFactory,pvVar2,pcVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_actionAssistantForActionType_,pvVar1);
    if (pvVar2 == (id)0x0) goto LAB_000f6899;
    cVar6 = '\x01';
  }
  _objc_msgSend(willDisplayCell,sel_setBordered_,(int)cVar6,pcVar4);
  pvVar2 = _objc_msgSend(self,sel_buttonBackgroundRenderer);
  uVar8 = 1;
  _objc_msgSend(pvVar2,sel_setDrawsEmptyBorder_,1);
  pcVar5 = sel_buttonBackgroundRenderer;
  if (cVar6 != '\0') {
    pcVar5 = sel_enabledButtonBackgroundRenderer;
  }
  pvVar2 = _objc_msgSend(self,pcVar5,uVar8);
  pvVar3 = _objc_msgSend(willDisplayCell,sel_backgroundRenderer);
  if (pvVar3 != pvVar2) {
    _objc_msgSend(willDisplayCell,sel_setBackgroundRenderer_,pvVar2);
  }
  _objc_msgSend(willDisplayCell,sel_setButtonType_,(uint)(cVar6 == '\0') * 5);
  _objc_msgSend(willDisplayCell,sel_setAlignment_,(uint)(cVar6 != '\0') * 2);
  self_00 = cls_NSFont;
  dVar7 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
  pvVar2 = _objc_msgSend(self_00,sel_systemFontOfSize_,(float)dVar7);
  _objc_msgSend(willDisplayCell,sel_setFont_,pvVar2);
  pcVar9 = &cfstr_HSNoneNBAActionType;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSNoneNBAActionType);
  if ((char)pvVar2 == '\0') {
    pvVar1 = (id)_NSClassFromString(pvVar1);
    pcVar5 = sel_localizedName;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar9);
    pcVar4 = &cfstr_empty;
    pcVar9 = &cfstr_None;
    pcVar5 = sel_localizedStringForKey_value_table_;
  }
  pvVar1 = _objc_msgSend(pvVar1,pcVar5,pcVar9,pcVar4);
  _objc_msgSend(willDisplayCell,sel_setTitle_,pvVar1);
  pvVar1 = _objc_msgSend(willDisplayCell,sel_attributedTitle);
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  forTableColumn = _objc_msgSend(cls_NSColor,sel_controlTextColor);
  row = 0;
  _objc_msgSend(pvVar1,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336394,forTableColumn,0,
                pvVar2);
  pvVar2 = pvVar1;
  _objc_msgSend(willDisplayCell,sel_setAttributedTitle_,pvVar1);
  pcVar5 = sel_release;
LAB_000f6809:
  _objc_msgSend(pvVar1,pcVar5,pvVar2,forTableColumn,row);
  return;
}

*/
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id actionType = [_newButtonActions objectAtIndex:aRow];
    BOOL hasAssistant;
    id renderer;
    id title;
    NSMutableAttributedString *attributedTitle;
    [aCell setEnabled:[self isEnabledActionOfType:actionType]];
    if ([[aColumn identifier] isEqual:@"HSActionEnabledCheckboxTableColumnIdentifier"]) {
        [aCell setState:[[self tableView:aView objectValueForTableColumn:aColumn row:aRow] boolValue] ? NSOnState : NSOffState];
        [aCell setImagePosition:NSImageOnly];
        return;
    }
    hasAssistant = [[self actor] hyperActionOfType:actionType forEvent:[self actionEvent]] != nil
        && [[HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory] actionAssistantForActionType:actionType] != nil;
    [aCell setBordered:hasAssistant];
    [[self buttonBackgroundRenderer] setDrawsEmptyBorder:YES];
    renderer = hasAssistant ? [self enabledButtonBackgroundRenderer] : [self buttonBackgroundRenderer];
    if ([aCell backgroundRenderer] != renderer) {
        [aCell setBackgroundRenderer:renderer];
    }
    [(NSButtonCell *)aCell setButtonType:hasAssistant ? NSMomentaryLightButton : NSMomentaryChangeButton];
    [aCell setAlignment:hasAssistant ? NSTextAlignmentCenter : NSTextAlignmentLeft];
    [aCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    if ([actionType isEqual:@"HSNoneNBAActionType"]) {
        title = [[NSBundle mainBundle] localizedStringForKey:@"None" value:@"" table:@"AssistantPanes"];
    }
    else {
        title = [NSClassFromString(actionType) localizedName];
    }
    [aCell setTitle:title];
    attributedTitle = [[aCell attributedTitle] mutableCopy];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[NSColor controlTextColor] range:NSMakeRange(0, [attributedTitle length])];
    [aCell setAttributedTitle:attributedTitle];
    [attributedTitle release];
}

- (id)enabledButtonBackgroundRenderer
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _enabledButtonBackgroundRenderer;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSActionsPaneButtonBackgroundRenderer alloc] initPrimitive];
        _enabledButtonBackgroundRenderer = pvVar1_3;
        [pvVar1_3 setDrawsEmptyBorder:NO];
        pvVar1 = _enabledButtonBackgroundRenderer;
    }
    return pvVar1;
}

- (id)buttonBackgroundRenderer
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _buttonBackgroundRenderer;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSActionsPaneButtonBackgroundRenderer new];
        _buttonBackgroundRenderer = pvVar1_2;
        [pvVar1_2 setDrawsEmptyBorder:YES];
        pvVar1 = _buttonBackgroundRenderer;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f6bd0 @ 000f6bd0, 851 bytes * /

void FUN_000f6bd0(HSNewButtonActionsAssistantPane *self,SEL _cmd,id tableView,id setObjectValue,
                 id forTableColumn,int row)

{
  HSNewButtonActionsAssistantPane *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  HSNewButtonActionsAssistantPane *pHVar5;
  SEL pcVar6;
  undefined *self_01;
  undefined *puVar7;
  cfstringStruct *pcVar8;
  
  self_00 = _objc_msgSend(self->_newButtonActions,sel_objectAtIndex_,row);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar7 = &DAT_0036ed8c;
  pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036ed8c);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_assistant,puVar7);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    puVar7 = &DAT_0036eddc;
    pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036eddc);
    self_01 = cls_HSActor;
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_assistant,puVar7);
      pvVar1 = _objc_msgSend(pvVar1,sel_object);
      pcVar6 = sel_actionEventsForObject_;
      goto LAB_000f6ce0;
    }
  }
  self_01 = cls_NSArray;
  pvVar1 = _objc_msgSend(self,sel_actionEvent,puVar7);
  pcVar6 = sel_arrayWithObject_;
LAB_000f6ce0:
  pvVar1 = _objc_msgSend(self_01,pcVar6,pvVar1);
  pvVar2 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar8 = &cfstr_HSActionEnabledCheckboxTableColumnIdentifier;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSActionEnabledCheckboxTableColumnIdentifier);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_actor,pcVar8);
    pvVar3 = _objc_msgSend(self,sel_actionEvent);
    pHVar5 = self_00;
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionOfType_forEvent_,self_00,pvVar3);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(cls_HSActionSettingsAssistantFactory,
                           sel_sharedActionSettingsAssistantFactory,pHVar5,pvVar3);
    pHVar5 = self_00;
    pvVar2 = _objc_msgSend(pvVar2,sel_actionAssistantForActionType_,self_00);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(setObjectValue,sel_intValue,pHVar5,pvVar3);
    pcVar6 = sel_openAssistantPaneForActionType_forEvents_;
    if (pvVar2 == (id)0x0) {
      return;
    }
  }
  else {
    pvVar2 = _objc_msgSend(setObjectValue,sel_intValue,pcVar8);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pcVar8 = &cfstr_HSNoneNBAActionType;
    pvVar2 = _objc_msgSend(self_00,sel_isEqual_,&cfstr_HSNoneNBAActionType);
    pcVar6 = sel_openAssistantPaneForActionType_forEvents_;
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(self,sel_revertSettings,pcVar8);
      pvVar2 = _objc_msgSend(cls_HSActionAssistantSettingsApplier,sel_alloc);
      pvVar3 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
      pvVar4 = _objc_msgSend(self,sel_assistant);
      pvVar4 = _objc_msgSend(pvVar4,sel_object);
      pHVar5 = _objc_msgSend(pvVar2,sel_initWithObject_actionType_actionEvents_,pvVar4,pvVar3,pvVar1
                            );
      self_00 = pHVar5;
      _objc_msgSend(self,sel_setApplier_,pHVar5);
      _objc_msgSend(pHVar5,sel_removeActionFromActor);
      self = pHVar5;
      pcVar6 = sel_release;
      pvVar1 = pvVar3;
    }
  }
  _objc_msgSend(self,pcVar6,self_00,pvVar1);
  return;
}

*/
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id actionType = [_newButtonActions objectAtIndex:aRow];
    id object = [[self assistant] object];
    id events;
    id applier;
    if ([object implementsHyperInterface:@protocol(HSCardAttributes)] || [[[self assistant] object] implementsHyperInterface:@protocol(HSStackAttributes)]) {
        events = [NSArray arrayWithObject:[self actionEvent]];
    }
    else {
        events = [HSActor actionEventsForObject:[[self assistant] object]];
    }
    if (![[aColumn identifier] isEqual:@"HSActionEnabledCheckboxTableColumnIdentifier"]) {
        if ([[self actor] hyperActionOfType:actionType forEvent:[self actionEvent]] == nil) {
            return;
        }
        if ([[HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory] actionAssistantForActionType:actionType] == nil) {
            return;
        }
        if ([aValue intValue] == 0) {
            return;
        }
    }
    else {
        if ([aValue intValue] == 0) {
            return;
        }
        if ([actionType isEqual:@"HSNoneNBAActionType"]) {
            [self revertSettings];
            applier = [[HSActionAssistantSettingsApplier alloc] initWithObject:[[self assistant] object] actionType:[HSNBAAction actionType] actionEvents:events];
            [self setApplier:applier];
            [applier removeActionFromActor];
            [applier release];
            return;
        }
    }
    [self openAssistantPaneForActionType:actionType forEvents:events];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f6f23 @ 000f6f23, 466 bytes * /

id FUN_000f6f23(HSNewButtonActionsAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *self_00;
  bool bVar5;
  SEL op;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(self->_newButtonActions,sel_objectAtIndex_,row);
  pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSActionEnabledCheckboxTableColumnIdentifier);
  pcVar6 = &cfstr_HSNoneNBAActionType;
  pvVar3 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSNoneNBAActionType);
  self_00 = cls_NSNumber;
  if ((char)pvVar2 == '\0') {
    if ((char)pvVar3 == '\0') {
      self_00 = (undefined *)_NSClassFromString(pvVar1);
      op = sel_localizedName;
    }
    else {
      self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar6);
      pcVar6 = &cfstr_None;
      op = sel_localizedStringForKey_value_table_;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_actor,pcVar6);
    pvVar4 = _objc_msgSend(self,sel_actionEvent);
    if ((char)pvVar3 == '\0') {
      pvVar1 = _objc_msgSend(pvVar2,sel_hyperActionsOfType_forEvent_,pvVar1,pvVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_count);
      bVar5 = pvVar1 != (id)0x0;
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar6);
      pvVar1 = _objc_msgSend(pvVar2,sel_hyperActionsOfType_forEvent_,pvVar1,pvVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_count);
      bVar5 = pvVar1 == (id)0x0;
    }
    pcVar6 = (cfstringStruct *)(uint)bVar5;
    op = sel_numberWithBool_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pcVar6);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id actionType = [_newButtonActions objectAtIndex:aRow];
    BOOL isCheckbox = [[aColumn identifier] isEqual:@"HSActionEnabledCheckboxTableColumnIdentifier"];
    BOOL isNone = [actionType isEqual:@"HSNoneNBAActionType"];
    id actor;
    id event;
    if (!isCheckbox) {
        if (isNone) {
            return [[NSBundle mainBundle] localizedStringForKey:@"None" value:@"" table:@"AssistantPanes"];
        }
        return [NSClassFromString(actionType) localizedName];
    }
    actor = [self actor];
    event = [self actionEvent];
    if (isNone) {
        return [NSNumber numberWithBool:[[actor hyperActionsOfType:[HSNBAAction actionType] forEvent:event] count] == 0];
    }
    return [NSNumber numberWithBool:[[actor hyperActionsOfType:actionType forEvent:event] count] != 0];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[_newButtonActions count];
}

- (void)actionPaneDidClose:(id)aClose withApplier:(id)aApplier canceled:(BOOL)aCanceled
{
    [self setApplier:aApplier];
}

- (void)paneDidCancel:(id)aCancel
{
    [self revertSettings];
    [[self actor] invalidateSavedActions];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    [self applySettings];
    [self dismiss:YES slide:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f71ff @ 000f71ff, 66 bytes * /

void FUN_000f71ff(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  _objc_msgSend(self->_applier,sel_applyChanges);
  _objc_msgSend(self->_applier,sel_makeInitialEqualToCurrent);
  return;
}

*/
- (void)applySettings
{
    [_applier applyChanges];
    [(HSNBAApplier *)_applier makeInitialEqualToCurrent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f7241 @ 000f7241, 92 bytes * /

void FUN_000f7241(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  _objc_msgSend(self->_applier,sel_revertChanges);
  _objc_msgSend(self->_applier,sel_makeCurrentEqualToInitial);
  _objc_msgSend(self,sel_setApplier_,0);
  return;
}

*/
- (void)revertSettings
{
    [_applier revertChanges];
    [(HSNBAApplier *)_applier makeCurrentEqualToInitial];
    [self setApplier:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f729d @ 000f729d, 574 bytes * /

void FUN_000f729d(HSNewButtonActionsAssistantPane *self,SEL _cmd,id openAssistantPaneForActionType,
                 id forEvents)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(cls_HSActionSettingsAssistantFactory,
                         sel_sharedActionSettingsAssistantFactory);
  pvVar1 = _objc_msgSend(pvVar1,sel_actionAssistantForActionType_,openAssistantPaneForActionType);
  uVar3 = 0;
  _objc_msgSend(self,sel_setApplier_,0);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSNBAApplier,sel_alloc,uVar3);
    self_00 = cls_HSActor;
    pvVar2 = _objc_msgSend(self,sel_assistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar2 = _objc_msgSend(self_00,sel_actionEventsForObject_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
    pvVar4 = _objc_msgSend(self,sel_assistant);
    pvVar4 = _objc_msgSend(pvVar4,sel_object);
    pvVar2 = _objc_msgSend(pvVar1,sel_initWithObject_actionEvent_,pvVar4,pvVar2);
    pvVar4 = _objc_msgSend(forEvents,sel_lastObject);
    pvVar1 = _objc_msgSend(pvVar2,sel_addHyperActionOfType_forEvent_,openAssistantPaneForActionType,
                           pvVar4);
    _objc_msgSend(pvVar1,sel_setEvents_,forEvents);
    pvVar1 = pvVar2;
    _objc_msgSend(self,sel_setApplier_,pvVar2);
    op = sel_release;
  }
  else {
    pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_setDelegate_);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(pvVar1,sel_performSelector_withObject_,sel_setDelegate_,self);
    }
    _objc_msgSend(pvVar1,sel_setActionEvents_,forEvents);
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,forEvents);
    pvVar4 = (id)0x1;
    op = sel_pushViewController_animate_;
  }
  _objc_msgSend(pvVar2,op,pvVar1,pvVar4);
  return;
}

*/
- (void)openAssistantPaneForActionType:(id)aType forEvents:(id)aEvents
{
    id assistant = [[HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory] actionAssistantForActionType:aType];
    id applier;
    [self setApplier:nil];
    if (assistant == nil) {
        applier = [[HSNBAApplier alloc] initWithObject:[[self assistant] object] actionEvent:[[HSActor actionEventsForObject:[[self assistant] object]] lastObject]];
        [[applier addHyperActionOfType:aType forEvent:[aEvents lastObject]] setEvents:aEvents];
        [self setApplier:applier];
        [applier release];
        return;
    }
    if ([assistant respondsToSelector:@selector(setDelegate:)]) {
        [assistant performSelector:@selector(setDelegate:) withObject:self];
    }
    [assistant setActionEvents:aEvents];
    if ([self objectAssistantNavigationController] != nil) {
        [[self objectAssistantNavigationController] pushViewController:assistant animate:YES];
    }
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier) {
        [_applier release];
        _applier = [aApplier retain];
    }
}

- (id)applier
{
    return _applier;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f7526 @ 000f7526, 356 bytes * /

id FUN_000f7526(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  undefined *self_01;
  SEL op;
  undefined *puVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar5 = &DAT_0036ecd8;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036ecd8);
  self_01 = cls_NSString;
  self_00 = cls_NSBundle;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_class,puVar5);
    self_01 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar3 = &cfstr_AssistantPanes;
    pcVar4 = &cfstr_empty;
    pcVar6 = &cfstr_New_Button_Actions;
    op = sel_localizedStringForKey_value_table_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_class,puVar5);
    pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
    pcVar3 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_New_Button_Actions,
                           &cfstr_empty,&cfstr_AssistantPanes);
    pcVar4 = _objc_msgSend(pvVar1,sel_hyperName);
    pcVar6 = &cfstr________;
    op = sel_stringWithFormat_;
  }
  pvVar1 = _objc_msgSend(self_01,op,pcVar6,pcVar4,pcVar3);
  return pvVar1;
}

*/
- (id)windowTitle
{
    id object = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    if (object == nil) {
        return [bundle localizedStringForKey:@"New Button Actions" value:@"" table:@"AssistantPanes"];
    }
    return [NSString stringWithFormat:@"%@ : %@", [object hyperName], [bundle localizedStringForKey:@"New Button Actions" value:@"" table:@"AssistantPanes"]];
}

- (id)helpTopicKey
{
    return @"HSActionNewButton";
}

- (void)HSNewButtonActionsAssistantPane_actorDidChange:(id)aChange
{
    [_actionsTable reloadData];
}

- (id)initialKeyView
{
    return _actionsTable;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[[self actor] attributeObservingController] removeObserver:self selector:@selector(HSNewButtonActionsAssistantPane_actorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSActor)];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id pvVar2;
    id pvVar3;
    id pvVar1_8;
    id pvVar2_2;
    id pvVar2_3;
    id pvVar2_4;

    [super viewWillAppear:aAppear];
    _newButtonActions = [[self currentActions] retain];
    [_actionsTable setDataSource:self];
    [_actionsTable reloadData];
    pvVar2 = [self actor];
    pvVar3 = [self actionEvent];
    pvVar2_2 = [pvVar2 hyperActionsOfType:[HSNBAAction actionType] forEvent:pvVar3];
    if ([pvVar2_2 count] != 0) {
        pvVar2_3 = [[[pvVar2_2 extraFirstObject] class] actionType];
        if ([_newButtonActions containsObject:pvVar2_3]) {
            pvVar1_8 = [NSIndexSet indexSetWithIndex:[_newButtonActions indexOfObject:pvVar2_3]];
            [_actionsTable selectRowIndexes:pvVar1_8 byExtendingSelection:NO];
            pvVar2_4 = _actionsTable;
            [pvVar2_4 scrollRowToVisible:[pvVar2_4 selectedRow]];
        }
    }
    [self validateActionDescription];
    [[[self actor] attributeObservingController] addObserver:self selector:@selector(HSNewButtonActionsAssistantPane_actorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSActor) withPriority:-0.25];
    [self updateInUseTab];
}

- (void)updateInUseTab
{
    NSCell *self_01;
    NSUInteger pvVar1_2;

    self_01 = [_segmentedControl cellWithTag:1];
    pvVar1_2 = [[self inUseButtonActions] count];
    [self_01 setTitle:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"In Use (%d)" value:@"" table:@"AssistantPanes"], (int)pvVar1_2 + -1]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f7ac0 @ 000f7ac0, 286 bytes * /

void FUN_000f7ac0(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(self->_actionsTable,sel_selectedRow);
  if (pvVar1 != (id)0xffffffff) {
    pvVar1 = _objc_msgSend(self->_newButtonActions,sel_objectAtIndex_,pvVar1);
    pcVar3 = &cfstr_HSNoneNBAActionType;
    pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSNoneNBAActionType);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(cls_HSNBAHelpProvider,sel_sharedNBAHelpProvider,pcVar3);
      op = sel_localizedDescriptionForActionOfType_;
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_alloc,pcVar3);
      pvVar1 = _objc_msgSend(cls_NSString,sel_string);
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithString_,pvVar1);
      op = sel_autorelease;
    }
    pvVar1 = _objc_msgSend(pvVar2,op,pvVar1);
    pvVar2 = _objc_msgSend(self->_actionDescriptionView,sel_textStorage);
    _objc_msgSend(pvVar2,sel_setAttributedString_,pvVar1);
  }
  return;
}

*/
- (void)validateActionDescription
{
    NSInteger row = [_actionsTable selectedRow];
    id actionType;
    id description;
    if (row == -1) {
        return;
    }
    actionType = [_newButtonActions objectAtIndex:row];
    if ([actionType isEqual:@"HSNoneNBAActionType"]) {
        description = [[[NSAttributedString alloc] initWithString:[NSString string]] autorelease];
    }
    else {
        description = [[HSNBAHelpProvider sharedNBAHelpProvider] localizedDescriptionForActionOfType:actionType];
    }
    [[_actionDescriptionView textStorage] setAttributedString:description];
}

- (void)viewDidLoad
{
    [_segmentedControl setBackgroundRenderer:[HSAssistantSegmentedControlBackgroundRenderer sharedBackgroundRenderer]];
    [_actionDescriptionView setTextContainerInset:NSMakeSize(0, 3.0)];
    [[_actionDescriptionView enclosingScrollView] setLineScroll:10.0];
    [_actionsTable setTarget:self];
    [_actionsTable setDoubleAction:@selector(tableDoubleAction:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disabledActionsListDidChange:) name:HSDisabledActionsListDidChangeNotification object:0];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f7d5d @ 000f7d5d, 97 bytes * /

id FUN_000f7d5d(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_segmentedControl,sel_selectedCell);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  op = sel_inUseButtonActions;
  if (pvVar1 == (id)0x0) {
    op = sel_availableNewButtonActions;
  }
  pvVar1 = _objc_msgSend(self,op);
  return pvVar1;
}

*/
- (id)currentActions
{
    if ([[_segmentedControl selectedCell] tag] == 0) {
        return [self availableNewButtonActions];
    }
    return [self inUseButtonActions];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f7dbe @ 000f7dbe, 536 bytes * /

id FUN_000f7dbe(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id self_01;
  id self_02;
  id pvVar1;
  id self_03;
  id pvVar2;
  id pvVar3;
  id self_04;
  id pvVar4;
  undefined4 uVar5;
  
  self_01 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_02 = _objc_msgSend(self,sel_availableNewButtonActions);
  pvVar1 = _objc_msgSend(self,sel_stack);
  self_03 = _objc_msgSend(pvVar1,sel_hyperDeepEnumerator);
  pvVar1 = _objc_msgSend(self_03,sel_nextObject);
  self_00 = cls_NSMutableArray;
  while (cls_NSMutableArray = self_00, pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
    uVar5 = 0;
    pvVar3 = _objc_msgSend(self,sel_actionsForObject_ofType_forEvent_,pvVar1,pvVar2,0);
    self_04 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    pvVar3 = _objc_msgSend(self_04,sel_nextObject);
    while (pvVar3 != (id)0x0) {
      pvVar1 = pvVar3;
      pvVar4 = _objc_msgSend(self_02,sel_containsObject_,pvVar3,pvVar2,uVar5);
      if ((char)pvVar4 != '\0') {
        _objc_msgSend(self_01,sel_addObject_,pvVar3);
        pvVar1 = pvVar3;
      }
      pvVar3 = _objc_msgSend(self_04,sel_nextObject,pvVar1);
    }
    pvVar1 = _objc_msgSend(self_03,sel_nextObject,pvVar1,pvVar2,uVar5);
    self_00 = cls_NSMutableArray;
  }
  pvVar1 = _objc_msgSend(cls_NSSet,sel_setWithArray_,self_01);
  pvVar1 = _objc_msgSend(pvVar1,sel_allObjects);
  pvVar1 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
  _objc_msgSend(pvVar1,sel_sortUsingFunction_context_,FUN_000f8581,self);
  _objc_msgSend(pvVar1,sel_insertObject_atIndex_,&cfstr_HSNoneNBAActionType,0);
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar1);
  return pvVar1;
}

*/
- (id)inUseButtonActions
{
    NSMutableArray *inUse = [NSMutableArray array];
    id available = [self availableNewButtonActions];
    NSEnumerator *objects = [[self stack] hyperDeepEnumerator];
    id object;
    NSMutableArray *actions;
    while ((object = [objects nextObject]) != nil) {
        NSEnumerator *types = [[self actionsForObject:object ofType:[HSNBAAction actionType] forEvent:nil] objectEnumerator];
        id type;
        while ((type = [types nextObject]) != nil) {
            if ([available containsObject:type]) {
                [inUse addObject:type];
            }
        }
    }
    actions = [NSMutableArray arrayWithArray:[[NSSet setWithArray:inUse] allObjects]];
    [actions sortUsingFunction:HSCompareNBAActionTypes context:self];
    [actions insertObject:@"HSNoneNBAActionType" atIndex:0];
    return [NSArray arrayWithArray:actions];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f7fd6 @ 000f7fd6, 324 bytes * /

id FUN_000f7fd6(HSNewButtonActionsAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar1 = self->_availableNewButtonActions;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSAvailableActionsProvider,sel_sharedAvailableActionsProvider);
    pvVar2 = _objc_msgSend(self,sel_actionEvent);
    pvVar3 = _objc_msgSend(self,sel_assistant);
    pvVar3 = _objc_msgSend(pvVar3,sel_object);
    pvVar4 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
    pvVar1 = _objc_msgSend(pvVar1,sel_availableActionsOfType_forObject_forEvent_,pvVar4,pvVar3,
                           pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
    _objc_msgSend(pvVar1,sel_sortUsingFunction_context_,FUN_000f8581,self);
    _objc_msgSend(pvVar1,sel_insertObject_atIndex_,&cfstr_HSNoneNBAActionType,0);
    pvVar2 = _objc_msgSend(pvVar1,sel_copy);
    self->_availableNewButtonActions = pvVar2;
    _objc_msgSend(pvVar1,sel_release);
    pvVar1 = self->_availableNewButtonActions;
  }
  return pvVar1;
}

*/
- (id)availableNewButtonActions
{
    NSMutableArray *actions;
    if (_availableNewButtonActions == nil) {
        actions = [[[HSAvailableActionsProvider sharedAvailableActionsProvider] availableActionsOfType:[HSNBAAction actionType] forObject:[[self assistant] object] forEvent:[self actionEvent]] mutableCopy];
        [actions sortUsingFunction:HSCompareNBAActionTypes context:self];
        [actions insertObject:@"HSNoneNBAActionType" atIndex:0];
        _availableNewButtonActions = [actions copy];
        [actions release];
    }
    return _availableNewButtonActions;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f811a @ 000f811a, 681 bytes * /

id FUN_000f811a(HSNewButtonActionsAssistantPane *self,SEL _cmd,id actionsForObject,id ofType,
               id forEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  id pvVar6;
  undefined *puVar7;
  
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar2 = _objc_msgSend(actionsForObject,sel_queryHyperInterface_,&DAT_0036ebe8);
  pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array);
  if (forEvent == (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionsOfType_,ofType);
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionsOfType_forEvent_,ofType,forEvent);
  }
  _objc_msgSend(pvVar3,sel_addObjectsFromArray_,pvVar2);
  puVar5 = &DAT_0036ee90;
  puVar7 = puVar5;
  pvVar2 = _objc_msgSend(actionsForObject,sel_queryHyperInterface_,&DAT_0036ee90);
  pvVar2 = _objc_msgSend(pvVar2,sel_allLinks);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(actionsForObject,sel_queryHyperInterface_,&DAT_0036ee90);
    pvVar2 = _objc_msgSend(pvVar2,sel_allLinks);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    while( true ) {
      pvVar6 = _objc_msgSend(pvVar2,sel_nextObject,puVar5);
      puVar7 = puVar5;
      if (pvVar6 == (id)0x0) break;
      pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0036ebe8);
      pvVar4 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
      if (forEvent == (id)0x0) {
        puVar5 = _objc_msgSend(pvVar6,sel_hyperActionsOfType_,pvVar4);
      }
      else {
        puVar5 = _objc_msgSend(pvVar6,sel_hyperActionsOfType_forEvent_,pvVar4,forEvent);
      }
      _objc_msgSend(pvVar3,sel_addObjectsFromArray_,puVar5);
    }
  }
  pvVar2 = _objc_msgSend(pvVar3,sel_objectEnumerator,puVar7);
  while( true ) {
    pvVar3 = _objc_msgSend(pvVar2,sel_nextObject,puVar7);
    if (pvVar3 == (id)0x0) break;
    pvVar3 = _objc_msgSend(pvVar3,sel_class,puVar7);
    puVar7 = (undefined *)_NSStringFromClass(pvVar3);
    _objc_msgSend(pvVar1,sel_addObject_);
  }
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar1);
  return pvVar1;
}

*/
- (id)actionsForObject:(id)aObject ofType:(id)aType forEvent:(id)aEvent
{
    NSMutableArray *names = [NSMutableArray array];
    id actor = [aObject queryHyperInterface:@protocol(HSActor)];
    NSMutableArray *actions = [NSMutableArray array];
    NSEnumerator *links;
    NSEnumerator *enumerator;
    id link;
    id action;
    if (aEvent == nil) {
        [actions addObjectsFromArray:[actor hyperActionsOfType:aType]];
    }
    else {
        [actions addObjectsFromArray:[actor hyperActionsOfType:aType forEvent:aEvent]];
    }
    if ([[[aObject queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks] count] != 0) {
        links = [[[aObject queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks] objectEnumerator];
        while ((link = [links nextObject]) != nil) {
            id linkActor = [link queryHyperInterface:@protocol(HSActor)];
            // Links always contribute their new button actions, whatever type was asked for.
            if (aEvent == nil) {
                [actions addObjectsFromArray:[linkActor hyperActionsOfType:[HSNBAAction actionType]]];
            }
            else {
                [actions addObjectsFromArray:[linkActor hyperActionsOfType:[HSNBAAction actionType] forEvent:aEvent]];
            }
        }
    }
    enumerator = [actions objectEnumerator];
    while ((action = [enumerator nextObject]) != nil) {
        [names addObject:NSStringFromClass([action class])];
    }
    return [NSArray arrayWithArray:names];
}

- (id)actor
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
}

- (void)setActionEvent:(id)aEvent
{
    if (_actionEvent != aEvent) {
        [_actionEvent release];
        _actionEvent = [aEvent retain];
    }
}

- (id)actionEvent
{
    return _actionEvent;
}

- (void)dealloc
{
    [_actionEvent release];
    [_availableNewButtonActions release];
    [_buttonBackgroundRenderer release];
    [_enabledButtonBackgroundRenderer release];
    [_newButtonActions release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [_applier release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"NBAAssistantPane"];
    return self;
}

@end

