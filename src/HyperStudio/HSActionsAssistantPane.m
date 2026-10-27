#import "HSActionsAssistantPane.h"

@implementation HSActionsAssistantPane

/* i386 ivar offsets: _actionEvent=0x5c, _containerView=0x60, _placesToGoView=0x64, _thingsToDoView=0x68, _placesToGoTableView=0x6c, _thingsToDoTableView=0x70, _thingsToDoActionTypes=0x74, _placesToGoActionTypes=0x78, _availablePlacesToGoActionTypes=0x7c, _buttonBackgroundRenderer=0x80, _hasNavigationSwitcher=0x84, _navigationSwitcherClass=0x88, _navigationPaneSwitcher=0x8c */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSActor)];
}

- (void)hideAnimationObjectForAssistantPane:(id)aPane
{
    [[aPane animationModeController] hideAnimationObjectForAssistantPane:aPane];
}

- (void)cancelFromPickImageAssistantPane:(id)aPane
{
    [aPane dismiss:YES];
}

- (void)pickMovie:(id)aMovie name:(id)aName forPickImageAssistantPane:(id)aPane
{
    [[aPane animationModeController] pickMovie:aMovie name:aName forPickImageAssistantPane:aPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e1a8a @ 000e1a8a, 281 bytes * /

id FUN_000e1a8a(HSActionsAssistantPane *self,SEL _cmd,id actionEventsForObject)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  SEL pcVar3;
  undefined *puVar4;
  
  puVar4 = &DAT_0036c780;
  pvVar1 = _objc_msgSend(actionEventsForObject,sel_implementsHyperInterface_,&DAT_0036c780);
  if ((char)pvVar1 == '\0') {
    puVar4 = &DAT_0036c7d0;
    pvVar1 = _objc_msgSend(actionEventsForObject,sel_implementsHyperInterface_,&DAT_0036c7d0);
    self_00 = cls_HSActor;
    pcVar3 = sel_actionEventsForObject_;
    if ((char)pvVar1 == '\0') goto LAB_000e1b97;
  }
  pvVar2 = _objc_msgSend(self,sel_actionEvent,puVar4);
  pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,pvVar1);
  self_00 = cls_NSArray;
  pcVar3 = sel_actionEvent;
  if ((char)pvVar2 != '\0') {
    pvVar1 = *(id *)PTR_00336084;
    self = (HSActionsAssistantPane *)cls_HSActionEvent;
    pcVar3 = sel_actionEventOfType_;
  }
  actionEventsForObject = _objc_msgSend(self,pcVar3,pvVar1);
  pcVar3 = sel_arrayWithObject_;
LAB_000e1b97:
  pvVar1 = _objc_msgSend(self_00,pcVar3,actionEventsForObject);
  return pvVar1;
}

*/
- (id)actionEventsForObject:(id)aObject
{
    id event;
    if ([aObject implementsHyperInterface:@protocol(HSCardAttributes)] || [aObject implementsHyperInterface:@protocol(HSStackAttributes)]) {
        if ([[self actionEvent] isEqual:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]]) {
            event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
        }
        else {
            event = [self actionEvent];
        }
        return [NSArray arrayWithObject:event];
    }
    return [HSActor actionEventsForObject:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e1dce @ 000e1dce, 498 bytes * /

id FUN_000e1dce(HSActionsAssistantPane *self,SEL _cmd,id tableView,id toolTipForCell,NSRect *rect,
               id tableColumn,int row,NSPoint mouseLocation)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  SEL op;
  cfstringStruct *pcVar6;
  
  pvVar2 = _objc_msgSend(self,sel_actionTypeForTableView_row_,tableView,row);
  pvVar3 = _objc_msgSend(tableColumn,sel_identifier);
  pcVar5 = &cfstr_HSActionNameColumnIdentifier;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSActionNameColumnIdentifier);
  if ((char)pvVar3 == '\0') {
    return (id)0x0;
  }
  pvVar3 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar5,row);
  pvVar4 = _objc_msgSend(pvVar2,sel_isEqual_,pvVar3);
  puVar1 = cls_NSBundle;
  if ((char)pvVar4 == '\0') {
    pcVar5 = &cfstr_HSAutomaticTimerActionType;
    pvVar3 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSAutomaticTimerActionType);
    puVar1 = cls_NSBundle;
    if ((char)pvVar3 == '\0') {
      pcVar5 = &cfstr_HSNoneActionType;
      pvVar3 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSNoneActionType);
      if ((char)pvVar3 == '\0') {
        if (pvVar2 == (id)0x0) {
          return (id)0x0;
        }
        pvVar2 = (id)_NSClassFromString(pvVar2);
        op = sel_tooltip;
        pcVar6 = (cfstringStruct *)row;
        goto LAB_000e1f95;
      }
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar5);
      pcVar5 = &cfstr_None_of_the_above_ToolTip;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_class,pcVar5);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      pcVar5 = &cfstr_Automatic_timer_ToolTip;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_class,pvVar3);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pcVar5 = &cfstr_New_Button_Actions_ToolTip;
  }
  pcVar6 = &cfstr_empty;
  op = sel_localizedStringForKey_value_table_;
LAB_000e1f95:
  pvVar2 = _objc_msgSend(pvVar2,op,pcVar5,pcVar6);
  return pvVar2;
}

*/
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    id type = [self actionTypeForTableView:aView row:aRow];
    if (![[aColumn identifier] isEqual:@"HSActionNameColumnIdentifier"]) {
        return nil;
    }
    if ([type isEqual:[HSNBAAction actionType]]) {
        return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"New Button Actions ToolTip" value:@"" table:@"AssistantPanes"];
    }
    if ([type isEqual:@"HSAutomaticTimerActionType"]) {
        return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Automatic timer ToolTip" value:@"" table:@"AssistantPanes"];
    }
    if ([type isEqual:@"HSNoneActionType"]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"None of the above ToolTip" value:@"" table:@"AssistantPanes"];
    }
    if (type == nil) {
        return nil;
    }
    return [(id)NSClassFromString(type) tooltip];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e1fc0 @ 000e1fc0, 1885 bytes * /

void FUN_000e1fc0(HSActionsAssistantPane *self,SEL _cmd,id tableView,id willDisplayCell,
                 id forTableColumn,int row)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined *puVar4;
  undefined *self_00;
  cfstringStruct *self_01;
  id pvVar5;
  cfstringStruct *pcVar6;
  id pvVar7;
  id pvVar8;
  double dVar9;
  bool local_15;
  byte local_14;
  
  self_01 = _objc_msgSend(self,sel_actionTypeForTableView_row_,tableView,row);
  pvVar5 = _objc_msgSend(cls_HSActionSettingsAssistantFactory,
                         sel_sharedActionSettingsAssistantFactory);
  pvVar5 = _objc_msgSend(pvVar5,sel_actionTypeToAssistantMap);
  pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_,self_01);
  pcVar6 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
  pvVar7 = _objc_msgSend(self_01,sel_isEqual_,pcVar6);
  if ((char)pvVar7 == '\0') {
    pcVar6 = &cfstr_HSNoneActionType;
    pvVar7 = _objc_msgSend(self_01,sel_isEqual_,&cfstr_HSNoneActionType);
    if ((char)pvVar7 != '\0') goto LAB_000e206c;
    pcVar6 = &cfstr_HSAutomaticTimerActionType;
    pvVar7 = _objc_msgSend(self_01,sel_isEqual_,&cfstr_HSAutomaticTimerActionType);
    if ((char)pvVar7 != '\0') goto LAB_000e206c;
    pvVar7 = (id)_NSClassFromString(self_01);
    pcVar6 = _objc_msgSend(cls_HSToGoAction,sel_class,pcVar6);
    pvVar7 = _objc_msgSend(pvVar7,sel_isSubclassOfClass_,pcVar6);
    if ((char)pvVar7 == '\0') {
LAB_000e2131:
      if (self_01 == (cfstringStruct *)0x0) goto LAB_000e206c;
      local_15 = pvVar5 != (id)0x0;
    }
    else {
      pvVar7 = _objc_msgSend(self,sel_availablePlacesToGoActionTypes,pcVar6);
      pcVar6 = self_01;
      pvVar7 = _objc_msgSend(pvVar7,sel_containsObject_,self_01);
      if ((char)pvVar7 != '\0') goto LAB_000e2131;
      local_15 = false;
    }
  }
  else {
LAB_000e206c:
    local_15 = true;
  }
  pvVar7 = _objc_msgSend(forTableColumn,sel_identifier,pcVar6);
  pcVar6 = &cfstr_HSActionNameColumnIdentifier;
  pvVar7 = _objc_msgSend(pvVar7,sel_isEqual_,&cfstr_HSActionNameColumnIdentifier);
  if ((char)pvVar7 == '\0') {
    pvVar5 = _objc_msgSend(forTableColumn,sel_identifier,pcVar6);
    pvVar5 = _objc_msgSend(pvVar5,sel_isEqual_,&cfstr_HSActionStateColumnIdentifier);
    if ((char)pvVar5 != '\0') {
      _objc_msgSend(willDisplayCell,sel_setImagePosition_,1);
      pvVar5 = _objc_msgSend(self,sel_actionEvent);
      pvVar7 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
      pvVar5 = _objc_msgSend(pvVar5,sel_isEqual_,pvVar7);
      if ((char)pvVar5 != '\0') {
        pvVar5 = _objc_msgSend(self_01,sel_isEqual_,&cfstr_HSAutomaticTimerActionType);
        if ((char)pvVar5 != '\0') {
          local_15 = false;
        }
      }
    }
    goto LAB_000e26f8;
  }
  pvVar7 = _objc_msgSend(willDisplayCell,sel_backgroundRenderer,pcVar6);
  pvVar8 = _objc_msgSend(self,sel_buttonBackgroundRenderer);
  if (pvVar7 != pvVar8) {
    pcVar6 = _objc_msgSend(self,sel_buttonBackgroundRenderer,pcVar6);
    _objc_msgSend(willDisplayCell,sel_setBackgroundRenderer_,pcVar6);
  }
  pvVar7 = _objc_msgSend(self,sel_actor,pcVar6);
  pvVar8 = _objc_msgSend(self,sel_actionEvent);
  pcVar6 = self_01;
  pvVar7 = _objc_msgSend(pvVar7,sel_hyperActionOfType_forEvent_,self_01,pvVar8);
  if ((pvVar7 == (id)0x0) || (pvVar5 == (id)0x0)) {
    pvVar5 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar6,pvVar8);
    pvVar7 = _objc_msgSend(self_01,sel_isEqual_,pvVar5);
    if ((char)pvVar7 != '\0') {
      pvVar5 = _objc_msgSend(self,sel_actor,pvVar5,pvVar8);
      pvVar8 = _objc_msgSend(self,sel_actionEvent);
      pvVar7 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperActionsOfType_forEvent_,pvVar7,pvVar8);
      pvVar5 = _objc_msgSend(pvVar5,sel_count);
      if (pvVar5 != (id)0x0) goto LAB_000e222d;
    }
    pcVar6 = &cfstr_HSAutomaticTimerActionType;
    pvVar5 = _objc_msgSend(self_01,sel_isEqual_,&cfstr_HSAutomaticTimerActionType,pvVar8);
    if ((char)pvVar5 != '\0') {
      pvVar5 = _objc_msgSend(self,sel_actor,pcVar6,pvVar8);
      pvVar7 = _objc_msgSend(self,sel_actionEvent);
      pvVar5 = _objc_msgSend(pvVar5,sel_automaticTimerForActionEvent_,pvVar7);
      pvVar5 = _objc_msgSend(pvVar5,sel_runActionsAutomatically);
      if ((char)pvVar5 != '\0') goto LAB_000e222d;
    }
    local_14 = 0;
  }
  else {
LAB_000e222d:
    local_14 = 1;
  }
  _objc_msgSend(willDisplayCell,sel_setBordered_,(int)(char)local_14,pvVar8);
  pvVar5 = _objc_msgSend(self,sel_buttonBackgroundRenderer);
  _objc_msgSend(pvVar5,sel_setDrawsEmptyBorder_,(int)(char)(local_14 ^ 1));
  _objc_msgSend(willDisplayCell,sel_setButtonType_,(uint)(local_14 == 0) * 5);
  puVar4 = cls_NSFont;
  dVar9 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
  pvVar5 = _objc_msgSend(puVar4,sel_systemFontOfSize_,(float)dVar9);
  _objc_msgSend(willDisplayCell,sel_setFont_,pvVar5);
  if (local_14 == 0) {
    pvVar5 = _objc_msgSend(self,sel_tableView_objectValueForTableColumn_row_,tableView,
                           forTableColumn,row);
    _objc_msgSend(willDisplayCell,sel_setTitle_,pvVar5);
  }
  else {
    pvVar5 = _objc_msgSend(cls_NSMutableParagraphStyle,sel_new,pvVar5);
    _objc_msgSend(pvVar5,sel_setAlignment_,2);
    puVar4 = cls_NSMutableDictionary;
    uVar1 = *(undefined4 *)PTR_003363cc;
    uVar2 = *(undefined4 *)PTR_00336150;
    pvVar7 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,0xbe4ccccd);
    self_00 = cls_NSFont;
    uVar3 = *(undefined4 *)PTR_00336068;
    dVar9 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
    pvVar8 = _objc_msgSend(self_00,sel_systemFontOfSize_,(float)dVar9);
    pvVar7 = _objc_msgSend(puVar4,sel_dictionaryWithObjectsAndKeys_,pvVar8,uVar3,pvVar7,uVar1,pvVar5
                           ,uVar2,0);
    _objc_msgSend(pvVar5,sel_release);
    pvVar5 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar8 = _objc_msgSend(self,sel_tableView_objectValueForTableColumn_row_,tableView,
                           forTableColumn,row);
    pvVar5 = _objc_msgSend(pvVar5,sel_initWithString_attributes_,pvVar8,pvVar7);
    pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
    _objc_msgSend(willDisplayCell,sel_setAttributedTitle_,pvVar5);
    forTableColumn = pvVar7;
  }
  _objc_msgSend(willDisplayCell,sel_setAlignment_,(uint)(local_14 != 0) * 2,forTableColumn,row);
LAB_000e26f8:
  _objc_msgSend(willDisplayCell,sel_setEnabled_,(int)local_15);
  return;
}

*/
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id type = [self actionTypeForTableView:aView row:aRow];
    id assistantClass = [[[HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory] actionTypeToAssistantMap] objectForKey:type];
    BOOL enabled;
    BOOL bordered;
    NSMutableParagraphStyle *paragraphStyle;
    NSDictionary *attributes;
    if ([type isEqual:[HSNBAAction actionType]] || [type isEqual:@"HSNoneActionType"] || [type isEqual:@"HSAutomaticTimerActionType"]) {
        enabled = YES;
    }
    else if ([NSClassFromString(type) isSubclassOfClass:[HSToGoAction class]] && ![[self availablePlacesToGoActionTypes] containsObject:type]) {
        enabled = NO;
    }
    else if (type == nil) {
        enabled = YES;
    }
    else {
        enabled = assistantClass != nil;
    }
    if ([[aColumn identifier] isEqual:@"HSActionNameColumnIdentifier"]) {
        if ([aCell backgroundRenderer] != [self buttonBackgroundRenderer]) {
            [aCell setBackgroundRenderer:[self buttonBackgroundRenderer]];
        }
        if ([[self actor] hyperActionOfType:type forEvent:[self actionEvent]] != nil && assistantClass != nil) {
            bordered = YES;
        }
        else if ([type isEqual:[HSNBAAction actionType]] && [[[self actor] hyperActionsOfType:[HSNBAAction actionType] forEvent:[self actionEvent]] count] != 0) {
            bordered = YES;
        }
        else if ([type isEqual:@"HSAutomaticTimerActionType"] && [[[self actor] automaticTimerForActionEvent:[self actionEvent]] runActionsAutomatically]) {
            bordered = YES;
        }
        else {
            bordered = NO;
        }
        [aCell setBordered:bordered];
        [[self buttonBackgroundRenderer] setDrawsEmptyBorder:!bordered];
        [(NSButtonCell *)aCell setButtonType:(bordered ? NSButtonTypeMomentaryLight : NSButtonTypeMomentaryChange)];
        [aCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        if (bordered) {
            paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setAlignment:NSTextAlignmentCenter];
            attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName, [NSNumber numberWithFloat:-0.2f], NSKernAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil];
            [paragraphStyle release];
            [aCell setAttributedTitle:[[[NSAttributedString alloc] initWithString:[self tableView:aView objectValueForTableColumn:aColumn row:aRow] attributes:attributes] autorelease]];
        }
        else {
            [aCell setTitle:[self tableView:aView objectValueForTableColumn:aColumn row:aRow]];
        }
        [aCell setAlignment:(bordered ? NSTextAlignmentCenter : NSTextAlignmentLeft)];
    }
    else if ([[aColumn identifier] isEqual:@"HSActionStateColumnIdentifier"]) {
        [aCell setImagePosition:NSImageOnly];
        if ([[self actionEvent] isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]] && [type isEqual:@"HSAutomaticTimerActionType"]) {
            enabled = NO;
        }
    }
    [aCell setEnabled:enabled];
}

- (id)buttonBackgroundRenderer
{
    id pvVar1;

    pvVar1 = _buttonBackgroundRenderer;
    if (pvVar1 == nil) {
        pvVar1 = [HSActionsPaneButtonBackgroundRenderer new];
        _buttonBackgroundRenderer = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e0b11 @ 000e0b11, 3899 bytes * /

void FUN_000e0b11(HSActionsAssistantPane *self,SEL _cmd,id tableView,id setObjectValue,
                 id forTableColumn,int row)

{
  bool bVar1;
  HSActionsAssistantPane *pHVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  cfstringStruct *pcVar8;
  id pvVar9;
  cfstringStruct *pcVar10;
  HSActionsAssistantPane *pHVar11;
  undefined *puVar12;
  HSActionsAssistantPane *pHVar13;
  undefined4 *puVar14;
  SEL pcVar15;
  
  pHVar2 = _objc_msgSend(self,sel_actionTypeForTableView_row_,tableView,row);
  pvVar3 = _objc_msgSend(cls_HSPlayAnimationAction,sel_actionType);
  pvVar4 = _objc_msgSend(pvVar3,sel_isEqualToString_,pHVar2);
  pvVar3 = _objc_msgSend(cls_HSPlayMovieAction,sel_actionType);
  pvVar5 = _objc_msgSend(pvVar3,sel_isEqualToString_,pHVar2);
  pvVar3 = _objc_msgSend(cls_HSPlaySoundAction,sel_actionType);
  pvVar6 = _objc_msgSend(pvVar3,sel_isEqualToString_,pHVar2);
  pvVar7 = _objc_msgSend(self,sel_actor);
  pvVar3 = _objc_msgSend(self,sel_actionEvent);
  pcVar8 = (cfstringStruct *)pHVar2;
  pvVar7 = _objc_msgSend(pvVar7,sel_hyperActionOfType_forEvent_,pHVar2,pvVar3);
  if (pvVar7 == (id)0x0) {
LAB_000e0c5e:
    pvVar7 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar8,pvVar3);
    pvVar9 = _objc_msgSend(pHVar2,sel_isEqual_,pvVar7);
    if ((char)pvVar9 != '\0') {
      pvVar7 = _objc_msgSend(self,sel_actor,pvVar7,pvVar3);
      pvVar3 = _objc_msgSend(self,sel_actionEvent);
      pcVar8 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
      pvVar7 = _objc_msgSend(pvVar7,sel_hyperActionsOfType_forEvent_,pcVar8,pvVar3);
      pvVar7 = _objc_msgSend(pvVar7,sel_count);
      if (pvVar7 != (id)0x0) goto LAB_000e0c57;
    }
    pcVar8 = &cfstr_HSAutomaticTimerActionType;
    pvVar7 = _objc_msgSend(pHVar2,sel_isEqual_,&cfstr_HSAutomaticTimerActionType,pvVar3);
    if ((char)pvVar7 != '\0') {
      pvVar7 = _objc_msgSend(self,sel_actor,pcVar8,pvVar3);
      pcVar8 = _objc_msgSend(self,sel_actionEvent);
      pvVar7 = _objc_msgSend(pvVar7,sel_automaticTimerForActionEvent_,pcVar8);
      pvVar7 = _objc_msgSend(pvVar7,sel_runActionsAutomatically);
      if ((char)pvVar7 != '\0') goto LAB_000e0c57;
    }
    bVar1 = false;
  }
  else {
    pvVar7 = _objc_msgSend(cls_HSActionSettingsAssistantFactory,
                           sel_sharedActionSettingsAssistantFactory,pcVar8,pvVar3);
    pcVar8 = (cfstringStruct *)pHVar2;
    pvVar7 = _objc_msgSend(pvVar7,sel_actionAssistantForActionType_,pHVar2);
    if (pvVar7 == (id)0x0) goto LAB_000e0c5e;
LAB_000e0c57:
    bVar1 = true;
  }
  pvVar7 = _objc_msgSend(forTableColumn,sel_identifier,pcVar8,pvVar3);
  pcVar8 = &cfstr_HSActionStateColumnIdentifier;
  pvVar7 = _objc_msgSend(pvVar7,sel_isEqual_,&cfstr_HSActionStateColumnIdentifier);
  pHVar11 = self;
  pcVar10 = (cfstringStruct *)pHVar2;
  if ((char)pvVar7 == '\0') {
    pvVar7 = _objc_msgSend(forTableColumn,sel_identifier,pcVar8);
    pcVar8 = &cfstr_HSActionNameColumnIdentifier;
    pvVar7 = _objc_msgSend(pvVar7,sel_isEqual_,&cfstr_HSActionNameColumnIdentifier);
    if (((char)pvVar7 == '\0') || (bVar1)) {
      pvVar5 = _objc_msgSend(setObjectValue,sel_boolValue,pcVar8);
      if ((char)pvVar5 == '\0') {
        return;
      }
      if (!bVar1) {
        return;
      }
      pcVar10 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar8);
      pvVar5 = _objc_msgSend(pHVar2,sel_isEqual_,pcVar10);
      pcVar15 = sel_openNBAAssistantPane;
      if ((char)pvVar5 == '\0') {
        pcVar10 = &cfstr_HSAutomaticTimerActionType;
        pvVar5 = _objc_msgSend(pHVar2,sel_isEqual_,&cfstr_HSAutomaticTimerActionType);
        pcVar15 = sel_openAutomaticTimerActionsAssistantPane;
        if ((char)pvVar5 == '\0') {
          if (pHVar2 == (HSActionsAssistantPane *)0x0) {
            return;
          }
          pvVar3 = _objc_msgSend(self,sel_assistant,pcVar10);
          pvVar5 = _objc_msgSend(pvVar3,sel_object);
          pvVar3 = _objc_msgSend(self,sel_actionEventsForObject_,pvVar5);
          puVar12 = cls_NSArray;
          if ((char)pvVar4 == '\0') {
            pvVar3 = _objc_msgSend(pvVar3,sel_lastObject,pvVar5);
            pvVar3 = _objc_msgSend(puVar12,sel_arrayWithObject_,pvVar3);
            pcVar15 = sel_openAssistantPaneForActionType_forEvents_;
            pcVar10 = (cfstringStruct *)pHVar2;
          }
          else {
            pvVar4 = _objc_msgSend(self,sel_assistant,pvVar5);
            pcVar10 = _objc_msgSend(pvVar4,sel_object);
            pvVar4 = _objc_msgSend(self,sel_stack);
            pvVar4 = _objc_msgSend(pvVar4,sel_document);
            pHVar11 = _objc_msgSend(pvVar4,sel_animationModeController);
            _objc_msgSend(self,sel_objectAssistantNavigationController);
            _objc_msgSend(self,sel_assistant);
            pcVar15 = 
            sel_editAnimationForActingObject_actionEvents_assistant_assistantNavigationController_;
          }
        }
      }
      goto LAB_000e0ed6;
    }
  }
  pvVar7 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar8);
  pvVar9 = _objc_msgSend(pHVar2,sel_isEqual_,pvVar7);
  if ((char)pvVar9 == '\0') {
    pcVar8 = &cfstr_HSAutomaticTimerActionType;
    pvVar7 = _objc_msgSend(pHVar2,sel_isEqual_,&cfstr_HSAutomaticTimerActionType);
    if ((char)pvVar7 == '\0') {
      pcVar8 = &cfstr_HSNoneActionType;
      pvVar3 = _objc_msgSend(pHVar2,sel_isEqual_,&cfstr_HSNoneActionType);
      if ((char)pvVar3 == '\0') {
        if (pHVar2 == (HSActionsAssistantPane *)0x0) {
          return;
        }
        pvVar3 = _objc_msgSend(setObjectValue,sel_intValue,pcVar8);
        if (pvVar3 == (id)0x0) {
          if (self->_placesToGoTableView == tableView) {
            return;
          }
          pHVar11 = _objc_msgSend(self,sel_actor,pcVar8);
          pvVar3 = _objc_msgSend(self,sel_actionEvent);
          pcVar15 = sel_removeHyperActionsOfType_forEvent_;
          goto LAB_000e0ed6;
        }
        pvVar3 = _objc_msgSend(self,sel_assistant,pcVar8);
        pvVar7 = _objc_msgSend(pvVar3,sel_object);
        pvVar3 = _objc_msgSend(self,sel_actionEventsForObject_,pvVar7);
        if (((char)pvVar4 == '\0') ||
           (pvVar4 = _objc_msgSend(pvVar3,sel_count,pvVar7), pvVar4 == (id)0x0)) {
          if ((char)pvVar5 != '\0') {
            pvVar4 = _objc_msgSend(self,sel_actor,pvVar7);
            pvVar5 = _objc_msgSend(pvVar3,sel_lastObject);
            pHVar11 = _objc_msgSend(pvVar4,sel_createActionOfType_forEvent_,pHVar2,pvVar5);
            puVar12 = &DAT_0036c758;
            pvVar4 = _objc_msgSend(pHVar11,sel_queryHyperInterface_,&DAT_0036c758);
            pvVar4 = _objc_msgSend(pvVar4,sel_isValid);
            if ((char)pvVar4 == '\0') {
              pvVar6 = _objc_msgSend(cls_HSRootPickMovieSourceAssistantPane,sel_new,puVar12,pvVar5);
              pvVar4 = *(id *)PTR_PTR_003364f4;
            }
            else {
              pvVar6 = _objc_msgSend(cls_HSPlayMovieActionAssistantPane,sel_new,puVar12,pvVar5);
              pvVar4 = (id)0x0;
            }
            pHVar2 = _objc_msgSend(pvVar6,sel_autorelease,puVar12);
            pcVar10 = _objc_msgSend(pvVar3,sel_lastObject);
            _objc_msgSend(pHVar2,sel_setActionEvent_,pcVar10);
            pvVar3 = _objc_msgSend(self,sel_modalViewController);
            if (pvVar3 == (id)0x0) {
              pvVar3 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,pcVar10);
              pHVar13 = _objc_msgSend(pvVar3,sel_initWithRootViewController_identifier_,pHVar2,
                                      pvVar4);
              pvVar4 = (id)0x1;
              pHVar2 = pHVar13;
              _objc_msgSend(self,sel_presentModalViewController_animated_,pHVar13,1);
              pcVar15 = sel_release;
            }
            else {
              pvVar6 = _objc_msgSend(self,sel_objectAssistantNavigationController,pcVar10);
              pcVar15 = sel_release;
              pvVar3 = pvVar5;
              if (pvVar6 == (id)0x0) goto LAB_000e0ed6;
              pHVar13 = _objc_msgSend(self,sel_objectAssistantNavigationController,pcVar10);
              pcVar15 = sel_pushViewController_withIdentifier_animate_replacePrevious_;
            }
            _objc_msgSend(pHVar13,pcVar15,pHVar2,pvVar4);
            pcVar15 = sel_release;
            pcVar10 = (cfstringStruct *)pHVar2;
            pvVar3 = pvVar4;
            goto LAB_000e0ed6;
          }
          pcVar15 = sel_openAssistantPaneForActionType_forEvents_;
          if ((char)pvVar6 == '\0') goto LAB_000e0ed6;
          pvVar4 = _objc_msgSend(cls_HSRootPickSoundSourceAssistantPane,sel_new,pvVar7);
          pHVar2 = _objc_msgSend(pvVar4,sel_autorelease);
          pvVar3 = _objc_msgSend(pvVar3,sel_lastObject);
          _objc_msgSend(pHVar2,sel_setActionEvent_,pvVar3);
          pvVar4 = _objc_msgSend(self,sel_modalViewController);
          if (pvVar4 == (id)0x0) {
            pvVar3 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,pvVar3);
            pHVar11 = _objc_msgSend(pvVar3,sel_initWithRootViewController_identifier_,pHVar2,
                                    *(undefined4 *)PTR_PTR_003364f8);
            pvVar3 = (id)0x1;
            pcVar10 = (cfstringStruct *)pHVar11;
            _objc_msgSend(self,sel_presentModalViewController_animated_,pHVar11,1);
            pcVar15 = sel_release;
            goto LAB_000e0ed6;
          }
          pvVar4 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar3);
          if (pvVar4 == (id)0x0) {
            return;
          }
          pHVar11 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar3);
          puVar14 = (undefined4 *)PTR_PTR_003364f8;
        }
        else {
          pvVar4 = _objc_msgSend(self,sel_actor,pvVar7);
          pvVar5 = _objc_msgSend(pvVar3,sel_lastObject);
          pvVar4 = _objc_msgSend(pvVar4,sel_createActionOfType_forEvent_,pHVar2,pvVar5);
          pvVar5 = _objc_msgSend(self,sel_stack);
          pvVar5 = _objc_msgSend(pvVar5,sel_document);
          pHVar11 = _objc_msgSend(pvVar5,sel_animationModeController);
          pvVar5 = _objc_msgSend(self,sel_actor);
          pvVar6 = _objc_msgSend(pvVar3,sel_lastObject);
          pHVar13 = pHVar2;
          pvVar5 = _objc_msgSend(pvVar5,sel_hyperActionOfType_forEvent_,pHVar2,pvVar6);
          if (pvVar5 == (id)0x0) {
            pHVar13 = (HSActionsAssistantPane *)&DAT_0036c6cc;
            pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0036c6cc,pvVar6);
            pvVar4 = _objc_msgSend(pvVar4,sel_animation);
            if (pvVar4 != (id)0x0) {
              pvVar4 = _objc_msgSend(self,sel_actor,pHVar13,pvVar6);
              pvVar5 = _objc_msgSend(pvVar3,sel_lastObject);
              pHVar13 = pHVar2;
              pvVar4 = _objc_msgSend(pvVar4,sel_hyperActionOfType_forEvent_,pHVar2,pvVar5);
              if (pvVar4 == (id)0x0) {
                pvVar4 = _objc_msgSend(self,sel_actor,pHVar13,pvVar5);
                pvVar5 = _objc_msgSend(pvVar3,sel_lastObject);
                _objc_msgSend(pvVar4,sel_addHyperActionOfType_forEvent_,pHVar2,pvVar5);
                pHVar13 = pHVar2;
              }
              _objc_msgSend(self,sel_objectAssistantNavigationController,pHVar13,pvVar5);
              _objc_msgSend(self,sel_assistant);
              pvVar4 = _objc_msgSend(self,sel_assistant);
              pcVar10 = _objc_msgSend(pvVar4,sel_object);
              pcVar15 = 
              sel_editAnimationForActingObject_actionEvents_assistant_assistantNavigationController_
              ;
              goto LAB_000e0ed6;
            }
          }
          pvVar4 = _objc_msgSend(cls_HSAnimationSetupPickImageAssistantPane,sel_new,pHVar13,pvVar6);
          pHVar2 = _objc_msgSend(pvVar4,sel_autorelease);
          _objc_msgSend(pHVar2,sel_setDelegate_,self);
          _objc_msgSend(pHVar11,sel_setActionEvents_,pvVar3);
          _objc_msgSend(pHVar2,sel_setAnimationModeController_,pHVar11);
          pvVar3 = _objc_msgSend(self,sel_modalViewController);
          if (pvVar3 == (id)0x0) {
            pvVar3 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,pHVar11);
            pHVar11 = _objc_msgSend(pvVar3,sel_initWithRootViewController_,pHVar2);
            pvVar3 = (id)0x1;
            pcVar10 = (cfstringStruct *)pHVar11;
            _objc_msgSend(self,sel_presentModalViewController_animated_,pHVar11,1);
            _objc_msgSend(pHVar11,sel_release);
            pHVar11 = pHVar2;
            pcVar15 = sel_notePaneOpenedAsModalViewController;
            goto LAB_000e0ed6;
          }
          pvVar3 = _objc_msgSend(self,sel_objectAssistantNavigationController,pHVar11);
          if (pvVar3 == (id)0x0) {
            return;
          }
          pHVar11 = _objc_msgSend(self,sel_objectAssistantNavigationController,pHVar11);
          puVar14 = (undefined4 *)PTR_PTR_003364f0;
        }
        pcVar15 = sel_pushViewController_withIdentifier_animate_replacePrevious_;
        pcVar10 = (cfstringStruct *)pHVar2;
        pvVar3 = (id)*puVar14;
        goto LAB_000e0ed6;
      }
      pvVar3 = _objc_msgSend(self,sel_actor,pcVar8);
      pvVar3 = _objc_msgSend(pvVar3,sel_hyperActions);
      pvVar3 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar3 == (id)0x0) {
        return;
      }
      pHVar11 = _objc_msgSend(self,sel_actor,pcVar8);
      pvVar3 = _objc_msgSend(self,sel_actionEvent);
      puVar12 = cls_HSToGoAction;
      goto LAB_000e0f14;
    }
    pvVar4 = _objc_msgSend(self,sel_actor,pcVar8);
    pcVar10 = _objc_msgSend(self,sel_actionEvent);
    pvVar4 = _objc_msgSend(pvVar4,sel_automaticTimerForActionEvent_,pcVar10);
    pvVar4 = _objc_msgSend(pvVar4,sel_runActionsAutomatically);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(self,sel_actor,pcVar10);
      pvVar5 = _objc_msgSend(self,sel_actionEvent);
      pHVar11 = _objc_msgSend(pvVar4,sel_automaticTimerForActionEvent_,pvVar5);
      pcVar15 = sel_setRunActionsAutomatically_;
      pcVar10 = (cfstringStruct *)(HSActionsAssistantPane *)0x0;
      goto LAB_000e0ed6;
    }
    pvVar4 = _objc_msgSend(setObjectValue,sel_intValue,pcVar10);
    pcVar15 = sel_openAutomaticTimerActionsAssistantPane;
  }
  else {
    pvVar4 = _objc_msgSend(self,sel_actor,pvVar7);
    pvVar3 = _objc_msgSend(self,sel_actionEvent);
    pcVar10 = _objc_msgSend(cls_HSNBAAction,sel_actionType);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperActionsOfType_forEvent_,pcVar10,pvVar3);
    pvVar4 = _objc_msgSend(pvVar4,sel_count);
    if (pvVar4 != (id)0x0) {
      pHVar11 = _objc_msgSend(self,sel_actor,pcVar10,pvVar3);
      pvVar3 = _objc_msgSend(self,sel_actionEvent);
      puVar12 = cls_HSNBAAction;
LAB_000e0f14:
      pcVar10 = _objc_msgSend(puVar12,sel_actionType);
      pcVar15 = sel_removeHyperActionsOfType_forEvent_;
      goto LAB_000e0ed6;
    }
    pvVar4 = _objc_msgSend(setObjectValue,sel_intValue,pcVar10,pvVar3);
    pcVar15 = sel_openNBAAssistantPane;
  }
  if (pvVar4 == (id)0x0) {
    return;
  }
LAB_000e0ed6:
  _objc_msgSend(pHVar11,pcVar15,pcVar10,pvVar3);
  return;
}

*/
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id type = [self actionTypeForTableView:aView row:aRow];
    BOOL isAnimation = [[HSPlayAnimationAction actionType] isEqualToString:type];
    BOOL isMovie = [[HSPlayMovieAction actionType] isEqualToString:type];
    BOOL isSound = [[HSPlaySoundAction actionType] isEqualToString:type];
    BOOL hasAction;
    id events;
    id createdAction;
    id animationModeController;
    id pane;
    id identifier;
    HSObjectAssistantNavigationController *navigationController;
    if ([[self actor] hyperActionOfType:type forEvent:[self actionEvent]] != nil && [[HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory] actionAssistantForActionType:type] != nil) {
        hasAction = YES;
    }
    else if ([type isEqual:[HSNBAAction actionType]] && [[[self actor] hyperActionsOfType:[HSNBAAction actionType] forEvent:[self actionEvent]] count] != 0) {
        hasAction = YES;
    }
    else if ([type isEqual:@"HSAutomaticTimerActionType"] && [[[self actor] automaticTimerForActionEvent:[self actionEvent]] runActionsAutomatically]) {
        hasAction = YES;
    }
    else {
        hasAction = NO;
    }
    if ([[aColumn identifier] isEqual:@"HSActionStateColumnIdentifier"] || ([[aColumn identifier] isEqual:@"HSActionNameColumnIdentifier"] && !hasAction)) {
        // Checkbox (or the title of an action that is not set up yet): toggle the action.
        if ([type isEqual:[HSNBAAction actionType]]) {
            if ([[[self actor] hyperActionsOfType:[HSNBAAction actionType] forEvent:[self actionEvent]] count] != 0) {
                [[self actor] removeHyperActionsOfType:[HSNBAAction actionType] forEvent:[self actionEvent]];
            }
            else if ([aValue intValue] != 0) {
                [self openNBAAssistantPane];
            }
            return;
        }
        if ([type isEqual:@"HSAutomaticTimerActionType"]) {
            if ([[[self actor] automaticTimerForActionEvent:[self actionEvent]] runActionsAutomatically]) {
                [[[self actor] automaticTimerForActionEvent:[self actionEvent]] setRunActionsAutomatically:NO];
            }
            else if ([aValue intValue] != 0) {
                [self openAutomaticTimerActionsAssistantPane];
            }
            return;
        }
        if ([type isEqual:@"HSNoneActionType"]) {
            if ([[[self actor] hyperActions] count] != 0) {
                [[self actor] removeHyperActionsOfType:[HSToGoAction actionType] forEvent:[self actionEvent]];
            }
            return;
        }
        if (type == nil) {
            return;
        }
        if ([aValue intValue] == 0) {
            if (_placesToGoTableView != aView) {
                [[self actor] removeHyperActionsOfType:type forEvent:[self actionEvent]];
            }
            return;
        }
        events = [self actionEventsForObject:[[self assistant] object]];
        if (isAnimation && [events count] != 0) {
            // The created action is not released here in the original.
            createdAction = [[self actor] createActionOfType:type forEvent:[events lastObject]];
            animationModeController = [[[self stack] document] animationModeController];
            if ([[self actor] hyperActionOfType:type forEvent:[events lastObject]] == nil
                && [(id<HSPlayAnimationActionAttributes>)[createdAction queryHyperInterface:@protocol(HSPlayAnimationActionAttributes)] animation] != nil) {
                if ([[self actor] hyperActionOfType:type forEvent:[events lastObject]] == nil) {
                    [[self actor] addHyperActionOfType:type forEvent:[events lastObject]];
                }
                [animationModeController editAnimationForActingObject:[[self assistant] object] actionEvents:events assistant:[self assistant] assistantNavigationController:[self objectAssistantNavigationController]];
                return;
            }
            pane = [[HSAnimationSetupPickImageAssistantPane new] autorelease];
            [pane setDelegate:self];
            [animationModeController setActionEvents:events];
            [pane setAnimationModeController:animationModeController];
            if ([self modalViewController] == nil) {
                navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
                [self presentModalViewController:navigationController animated:YES];
                [navigationController release];
                [pane notePaneOpenedAsModalViewController];
            }
            else if ([self objectAssistantNavigationController] != nil) {
                [[self objectAssistantNavigationController] pushViewController:pane withIdentifier:HSAnimationModePane animate:YES replacePrevious:NO];
            }
        }
        else if (isMovie) {
            createdAction = [[self actor] createActionOfType:type forEvent:[events lastObject]];
            if ([[createdAction queryHyperInterface:@protocol(HSActionValidation)] isValid]) {
                pane = [[HSPlayMovieActionAssistantPane new] autorelease];
                identifier = nil;
            }
            else {
                pane = [[HSRootPickMovieSourceAssistantPane new] autorelease];
                identifier = HSPickMovieSourcePane_RemoveIfOkIdentifier;
            }
            [pane setActionEvent:[events lastObject]];
            if ([self modalViewController] == nil) {
                navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane identifier:identifier];
                [self presentModalViewController:navigationController animated:YES];
                [navigationController release];
            }
            else if ([self objectAssistantNavigationController] != nil) {
                [[self objectAssistantNavigationController] pushViewController:pane withIdentifier:identifier animate:YES replacePrevious:NO];
            }
            [createdAction release];
        }
        else if (isSound) {
            pane = [[HSRootPickSoundSourceAssistantPane new] autorelease];
            [pane setActionEvent:[events lastObject]];
            if ([self modalViewController] == nil) {
                navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane identifier:HSRootAssistantPaneIdentifier];
                [self presentModalViewController:navigationController animated:YES];
                [navigationController release];
            }
            else if ([self objectAssistantNavigationController] != nil) {
                [[self objectAssistantNavigationController] pushViewController:pane withIdentifier:HSRootAssistantPaneIdentifier animate:YES replacePrevious:NO];
            }
        }
        else {
            [self openAssistantPaneForActionType:type forEvents:events];
        }
        return;
    }
    // Clicking the title of an action that is set up edits it.
    if (![aValue boolValue] || !hasAction) {
        return;
    }
    if ([type isEqual:[HSNBAAction actionType]]) {
        [self openNBAAssistantPane];
        return;
    }
    if ([type isEqual:@"HSAutomaticTimerActionType"]) {
        [self openAutomaticTimerActionsAssistantPane];
        return;
    }
    if (type == nil) {
        return;
    }
    events = [self actionEventsForObject:[[self assistant] object]];
    if (isAnimation) {
        [[[[self stack] document] animationModeController] editAnimationForActingObject:[[self assistant] object] actionEvents:events assistant:[self assistant] assistantNavigationController:[self objectAssistantNavigationController]];
    }
    else {
        [self openAssistantPaneForActionType:type forEvents:[NSArray arrayWithObject:[events lastObject]]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e271d @ 000e271d, 942 bytes * /

id FUN_000e271d(HSActionsAssistantPane *self,SEL _cmd,id tableView,id objectValueForTableColumn,
               int row)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  undefined *puVar6;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_actionTypeForTableView_row_,tableView,row);
  pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar5 = &cfstr_HSActionStateColumnIdentifier;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSActionStateColumnIdentifier);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar5,row);
    pcVar5 = &cfstr_HSActionNameColumnIdentifier;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSActionNameColumnIdentifier);
    if ((char)pvVar2 == '\0') {
      return (id)0x0;
    }
    pvVar2 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar5);
    pvVar4 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar2);
    puVar6 = cls_NSBundle;
    if ((char)pvVar4 == '\0') {
      pcVar5 = &cfstr_HSAutomaticTimerActionType;
      pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSAutomaticTimerActionType);
      puVar6 = cls_NSBundle;
      if ((char)pvVar2 == '\0') {
        pcVar5 = &cfstr_HSNoneActionType;
        pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSNoneActionType);
        if ((char)pvVar2 == '\0') {
          if (pvVar1 == (id)0x0) {
            return (id)0x0;
          }
          puVar6 = (undefined *)_NSClassFromString(pvVar1);
          op = sel_localizedNameInInspector;
          pcVar3 = (cfstringStruct *)row;
        }
        else {
          puVar6 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar5);
          pcVar3 = &cfstr_empty;
          pcVar5 = &cfstr_None_of_the_above;
          op = sel_localizedStringForKey_value_table_;
        }
        goto LAB_000e2aba;
      }
      pvVar1 = _objc_msgSend(self,sel_class,pcVar5);
      pvVar1 = _objc_msgSend(puVar6,sel_bundleForClass_,pvVar1);
      pcVar5 = &cfstr_Automatic_timer;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_class,pvVar2);
      pvVar1 = _objc_msgSend(puVar6,sel_bundleForClass_,pvVar1);
      pcVar5 = &cfstr_New_Button_Actions;
    }
    pcVar3 = &cfstr_empty;
    puVar6 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                           &cfstr_AssistantPanes);
    op = sel_hyperStringByAddingEllipsis;
  }
  else {
    pcVar5 = &cfstr_HSNoneActionType;
    pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSNoneActionType,row);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSAutomaticTimerActionType,row);
      pvVar4 = _objc_msgSend(self,sel_actor);
      pcVar3 = _objc_msgSend(self,sel_actionEvent);
      if ((char)pvVar2 == '\0') {
        pvVar1 = _objc_msgSend(pvVar4,sel_hyperActionsOfType_forEvent_,pvVar1,pcVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_count);
        pvVar1 = (id)(uint)(pvVar1 != (id)0x0);
      }
      else {
        pvVar1 = _objc_msgSend(pvVar4,sel_automaticTimerForActionEvent_,pcVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_runActionsAutomatically);
        pcVar3 = (cfstringStruct *)row;
      }
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_actor,pcVar5,row);
      pcVar3 = _objc_msgSend(self,sel_actionEvent);
      pvVar2 = _objc_msgSend(cls_HSToGoAction,sel_actionType);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionsOfType_forEvent_,pvVar2,pcVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_count);
      pvVar1 = (id)(uint)(pvVar1 == (id)0x0);
    }
    pcVar5 = (cfstringStruct *)((uint)pvVar1 & 0xff);
    puVar6 = cls_NSNumber;
    op = sel_numberWithBool_;
  }
LAB_000e2aba:
  pvVar1 = _objc_msgSend(puVar6,op,pcVar5,pcVar3);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id type = [self actionTypeForTableView:aView row:aRow];
    BOOL state;
    if ([[aColumn identifier] isEqual:@"HSActionStateColumnIdentifier"]) {
        if ([type isEqual:@"HSNoneActionType"]) {
            state = [[[self actor] hyperActionsOfType:[HSToGoAction actionType] forEvent:[self actionEvent]] count] == 0;
        }
        else if ([type isEqual:@"HSAutomaticTimerActionType"]) {
            state = [[[self actor] automaticTimerForActionEvent:[self actionEvent]] runActionsAutomatically];
        }
        else {
            state = [[[self actor] hyperActionsOfType:type forEvent:[self actionEvent]] count] != 0;
        }
        return [NSNumber numberWithBool:state];
    }
    if (![[aColumn identifier] isEqual:@"HSActionNameColumnIdentifier"]) {
        return nil;
    }
    if ([type isEqual:[HSNBAAction actionType]]) {
        return [[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"New Button Actions" value:@"" table:@"AssistantPanes"] hyperStringByAddingEllipsis];
    }
    if ([type isEqual:@"HSAutomaticTimerActionType"]) {
        return [[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Automatic timer" value:@"" table:@"AssistantPanes"] hyperStringByAddingEllipsis];
    }
    if ([type isEqual:@"HSNoneActionType"]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"None of the above" value:@"" table:@"AssistantPanes"];
    }
    if (type == nil) {
        return nil;
    }
    return [(id)NSClassFromString(type) localizedNameInInspector];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e0abe @ 000e0abe, 83 bytes * /

int FUN_000e0abe(HSActionsAssistantPane *self,SEL _cmd,id numberOfRowsInTableView)

{
  SEL op;
  id pvVar1;
  
  op = sel_placesToGoActionTypes;
  if ((self->_placesToGoTableView == numberOfRowsInTableView) ||
     (op = sel_thingsToDoActionTypes, self->_thingsToDoTableView == numberOfRowsInTableView)) {
    pvVar1 = _objc_msgSend(self,op);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
  }
  else {
    pvVar1 = (id)0x0;
  }
  return (int)pvVar1;
}

*/
- (NSInteger)numberOfRowsInTableView:(id)aView
{
    if (_placesToGoTableView == aView) {
        return [[self placesToGoActionTypes] count];
    }
    if (_thingsToDoTableView == aView) {
        return [[self thingsToDoActionTypes] count];
    }
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e0a62 @ 000e0a62, 92 bytes * /

id FUN_000e0a62(HSActionsAssistantPane *self,SEL _cmd,id actionTypeForTableView,int row)

{
  SEL op;
  id pvVar1;
  
  op = sel_placesToGoActionTypes;
  if ((self->_placesToGoTableView == actionTypeForTableView) ||
     (op = sel_thingsToDoActionTypes, self->_thingsToDoTableView == actionTypeForTableView)) {
    pvVar1 = _objc_msgSend(self,op);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
  }
  else {
    pvVar1 = (id)0x0;
  }
  return pvVar1;
}

*/
- (id)actionTypeForTableView:(id)aView row:(NSInteger)aRow
{
    if (_placesToGoTableView == aView) {
        return [[self placesToGoActionTypes] objectAtIndex:aRow];
    }
    if (_thingsToDoTableView == aView) {
        return [[self thingsToDoActionTypes] objectAtIndex:aRow];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e076c @ 000e076c, 758 bytes * /

id FUN_000e076c(HSActionsAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  SEL op;
  
  if (self->_thingsToDoActionTypes != (id)0x0) {
    return self->_thingsToDoActionTypes;
  }
  pvVar2 = _objc_msgSend(cls_HSAvailableActionsProvider,sel_sharedAvailableActionsProvider);
  pvVar3 = _objc_msgSend(self,sel_actionEvent);
  pvVar4 = _objc_msgSend(self,sel_assistant);
  pvVar4 = _objc_msgSend(pvVar4,sel_object);
  pvVar5 = _objc_msgSend(cls_HSToDoAction,sel_actionType);
  pvVar2 = _objc_msgSend(pvVar2,sel_availableActionsOfType_forObject_forEvent_,pvVar5,pvVar4,pvVar3)
  ;
  pvVar5 = _objc_msgSend(pvVar2,sel_mutableCopy);
  pvVar2 = _objc_msgSend(cls_HSGoToURLAction,sel_actionType);
  pvVar2 = _objc_msgSend(pvVar5,sel_indexOfObject_,pvVar2);
  pvVar6 = _objc_msgSend(self,sel_actionEvent);
  pcVar7 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
  pvVar6 = _objc_msgSend(pvVar6,sel_isEqual_,pcVar7);
  if ((char)pvVar6 == '\0') {
    pvVar6 = _objc_msgSend(self,sel_actionEvent,pcVar7);
    pcVar7 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
    pvVar6 = _objc_msgSend(pvVar6,sel_isEqual_,pcVar7);
    if ((char)pvVar6 != '\0') goto LAB_000e090f;
LAB_000e096e:
    bVar1 = false;
  }
  else {
LAB_000e090f:
    pvVar6 = _objc_msgSend(self,sel_assistant,pcVar7);
    pvVar6 = _objc_msgSend(pvVar6,sel_object);
    pcVar7 = _objc_msgSend(cls_HSHypertextLinksProxyForInspector,sel_class);
    pvVar6 = _objc_msgSend(pvVar6,sel_isKindOfClass_,pcVar7);
    if ((char)pvVar6 != '\0') goto LAB_000e096e;
    bVar1 = true;
  }
  if (pvVar2 == (id)0x7fffffff) {
    if (bVar1) {
      pcVar7 = &cfstr_HSAutomaticTimerActionType;
      _objc_msgSend(pvVar5,sel_addObject_,&cfstr_HSAutomaticTimerActionType);
    }
    pcVar7 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar7);
    op = sel_addObject_;
  }
  else {
    pcVar7 = _objc_msgSend(cls_HSNBAAction,sel_actionType,pcVar7);
    pvVar2 = (id)((int)pvVar2 + 1);
    pvVar4 = pvVar2;
    _objc_msgSend(pvVar5,sel_insertObject_atIndex_,pcVar7,pvVar2,pvVar3,pvVar2);
    if (!bVar1) goto LAB_000e0a2a;
    pcVar7 = &cfstr_HSAutomaticTimerActionType;
    op = sel_insertObject_atIndex_;
  }
  _objc_msgSend(pvVar5,op,pcVar7,pvVar4);
  pvVar2 = pvVar4;
LAB_000e0a2a:
  pvVar2 = _objc_msgSend(pvVar5,sel_copy,pcVar7,pvVar2);
  self->_thingsToDoActionTypes = pvVar2;
  _objc_msgSend(pvVar5,sel_release);
  return self->_thingsToDoActionTypes;
}

*/
- (id)thingsToDoActionTypes
{
    NSMutableArray *types;
    NSUInteger index;
    BOOL addTimer;
    if (_thingsToDoActionTypes != nil) {
        return _thingsToDoActionTypes;
    }
    types = [[[HSAvailableActionsProvider sharedAvailableActionsProvider] availableActionsOfType:[HSToDoAction actionType] forObject:[[self assistant] object] forEvent:[self actionEvent]] mutableCopy];
    index = [types indexOfObject:[HSGoToURLAction actionType]];
    if ([[self actionEvent] isEqual:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] || [[self actionEvent] isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]) {
        addTimer = ![[[self assistant] object] isKindOfClass:[HSHypertextLinksProxyForInspector class]];
    }
    else {
        addTimer = NO;
    }
    if (index == NSNotFound) {
        if (addTimer) {
            [types addObject:@"HSAutomaticTimerActionType"];
        }
        [types addObject:[HSNBAAction actionType]];
    }
    else {
        [types insertObject:[HSNBAAction actionType] atIndex:index + 1];
        if (addTimer) {
            [types insertObject:@"HSAutomaticTimerActionType" atIndex:index + 1];
        }
    }
    _thingsToDoActionTypes = [types copy];
    [types release];
    return _thingsToDoActionTypes;
}

- (id)placesToGoActionTypes
{
    id pvVar1;
    id pvVar1_2;
    id pvVar1_4;
    id pvVar2_2;

    pvVar1 = _placesToGoActionTypes;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSAvailableActionsProvider sharedAvailableActionsProvider];
        pvVar2_2 = [[self assistant] object];
        pvVar1_4 = [[pvVar1_2 allActionsOfType:[HSToGoAction actionType] forObject:pvVar2_2] mutableCopy];
        [pvVar1_4 addObject:@"HSNoneActionType"];
        _placesToGoActionTypes = [pvVar1_4 copy];
        [pvVar1_4 release];
        pvVar1 = _placesToGoActionTypes;
    }
    return pvVar1;
}

- (id)availablePlacesToGoActionTypes
{
    id pvVar1;
    id pvVar2;
    id pvVar1_2;
    id pvVar1_4;
    id pvVar3_2;

    pvVar1 = _availablePlacesToGoActionTypes;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSAvailableActionsProvider sharedAvailableActionsProvider];
        pvVar2 = [self actionEvent];
        pvVar3_2 = [[self assistant] object];
        pvVar1_4 = [[pvVar1_2 availableActionsOfType:[HSToGoAction actionType] forObject:pvVar3_2 forEvent:pvVar2] mutableCopy];
        [pvVar1_4 addObject:@"HSNoneActionType"];
        _availablePlacesToGoActionTypes = [pvVar1_4 copy];
        [pvVar1_4 release];
        pvVar1 = _availablePlacesToGoActionTypes;
    }
    return pvVar1;
}

- (void)openAssistantPaneForActionType:(id)aType forEvents:(id)aEvents
{
    [self openAssistantPaneForActionType:aType forEvents:aEvents animate:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e0327 @ 000e0327, 502 bytes * /

void FUN_000e0327(HSActionsAssistantPane *self,SEL _cmd,id openAssistantPaneForActionType,
                 id forEvents,BOOL animate)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  HSActionsAssistantPane *pHVar5;
  int iVar6;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_HSActionSettingsAssistantFactory,
                         sel_sharedActionSettingsAssistantFactory);
  pvVar1 = _objc_msgSend(pvVar1,sel_actionAssistantForActionType_,openAssistantPaneForActionType);
  if (pvVar1 == (id)0x0) {
    return;
  }
  _objc_msgSend(pvVar1,sel_setActionEvents_,forEvents);
  pvVar2 = _objc_msgSend(self,sel_actor);
  pvVar3 = _objc_msgSend(forEvents,sel_extraFirstObject);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionOfType_forEvent_,openAssistantPaneForActionType,
                         pvVar3);
  _objc_msgSend(pvVar1,sel_setObject_,pvVar2);
  pvVar4 = _objc_msgSend(self,sel_parentViewController);
  pHVar5 = _objc_msgSend(pvVar4,sel_modalViewController);
  if (pHVar5 == self) {
LAB_000e0482:
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar2);
    iVar6 = (int)animate;
    op = sel_pushViewController_animate_;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_parentViewController,pvVar2,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_modalViewController);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_parentViewController);
      pvVar3 = _objc_msgSend(pvVar3,sel_modalViewController);
      pvVar4 = _objc_msgSend(self,sel_objectAssistantNavigationController);
      if (pvVar3 == pvVar4) goto LAB_000e0482;
    }
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithRootViewController_,pvVar1);
    iVar6 = (int)animate;
    pvVar1 = pvVar2;
    _objc_msgSend(self,sel_presentModalViewController_animated_,pvVar2,iVar6);
    op = sel_release;
  }
  _objc_msgSend(pvVar2,op,pvVar1,iVar6);
  return;
}

*/
- (void)openAssistantPaneForActionType:(id)aType forEvents:(id)aEvents animate:(BOOL)aAnimate
{
    id pane = [[HSActionSettingsAssistantFactory sharedActionSettingsAssistantFactory] actionAssistantForActionType:aType];
    HSObjectAssistantNavigationController *navigationController;
    if (pane == nil) {
        return;
    }
    [pane setActionEvents:aEvents];
    [pane setObject:[[self actor] hyperActionOfType:aType forEvent:[aEvents extraFirstObject]]];
    if ([[self parentViewController] modalViewController] == self
        || ([[self parentViewController] modalViewController] != nil && [[self parentViewController] modalViewController] == [self objectAssistantNavigationController])) {
        [[self objectAssistantNavigationController] pushViewController:pane animate:aAnimate];
    }
    else {
        navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
        [self presentModalViewController:navigationController animated:aAnimate];
        [navigationController release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e0194 @ 000e0194, 403 bytes * /

void FUN_000e0194(HSActionsAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  HSActionsAssistantPane *pHVar3;
  id pvVar4;
  SEL op;
  undefined4 uVar5;
  
  self_00 = _objc_msgSend(cls_HSNewButtonActionsAssistantPane,sel_new);
  pvVar1 = _objc_msgSend(self,sel_actionEvent);
  _objc_msgSend(self_00,sel_setActionEvent_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_parentViewController);
  pHVar3 = _objc_msgSend(pvVar2,sel_modalViewController);
  if (pHVar3 == self) {
LAB_000e0277:
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar1);
    uVar5 = 1;
    op = sel_pushViewController_animate_;
    pvVar1 = self_00;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_parentViewController,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_modalViewController);
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_parentViewController);
      pvVar2 = _objc_msgSend(pvVar2,sel_modalViewController);
      pvVar4 = _objc_msgSend(self,sel_objectAssistantNavigationController);
      if (pvVar2 == pvVar4) goto LAB_000e0277;
    }
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar1,sel_initWithRootViewController_,self_00);
    uVar5 = 1;
    pvVar1 = pvVar2;
    _objc_msgSend(self,sel_presentModalViewController_animated_,pvVar2,1);
    op = sel_release;
  }
  _objc_msgSend(pvVar2,op,pvVar1,uVar5);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)openNBAAssistantPane
{
    id pane = [HSNewButtonActionsAssistantPane new];
    HSObjectAssistantNavigationController *navigationController;
    [pane setActionEvent:[self actionEvent]];
    if ([[self parentViewController] modalViewController] == self
        || ([[self parentViewController] modalViewController] != nil && [[self parentViewController] modalViewController] == [self objectAssistantNavigationController])) {
        [[self objectAssistantNavigationController] pushViewController:pane animate:YES];
    }
    else {
        navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
        [self presentModalViewController:navigationController animated:YES];
        [navigationController release];
    }
    [pane release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e0064 @ 000e0064, 304 bytes * /

void FUN_000e0064(HSActionsAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  
  self_00 = _objc_msgSend(cls_HSAutomaticTimerAssistantPane,sel_new);
  pvVar1 = _objc_msgSend(self,sel_actionEvent);
  _objc_msgSend(self_00,sel_setActionEvent_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_modalViewController);
  if (pvVar2 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,pvVar1);
    pvVar2 = _objc_msgSend(pvVar1,sel_initWithRootViewController_,self_00);
    uVar3 = 1;
    pvVar1 = pvVar2;
    _objc_msgSend(self,sel_presentModalViewController_animated_,pvVar2,1);
    op = sel_release;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar1);
    if (pvVar2 == (id)0x0) goto LAB_000e017a;
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar1);
    uVar3 = 1;
    op = sel_pushViewController_animate_;
    pvVar1 = self_00;
  }
  _objc_msgSend(pvVar2,op,pvVar1,uVar3);
LAB_000e017a:
  _objc_msgSend(self_00,sel_release,pvVar1);
  return;
}

*/
- (void)openAutomaticTimerActionsAssistantPane
{
    id pane = [HSAutomaticTimerAssistantPane new];
    HSObjectAssistantNavigationController *navigationController;
    [pane setActionEvent:[self actionEvent]];
    if ([self modalViewController] == nil) {
        navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
        [self presentModalViewController:navigationController animated:YES];
        [navigationController release];
    }
    else if ([self objectAssistantNavigationController] != nil) {
        [[self objectAssistantNavigationController] pushViewController:pane animate:YES];
    }
    [pane release];
}

- (id)initialKeyView
{
    return _placesToGoTableView;
}

- (void)paneWillGoBack:(id)aBack
{
    [self dismiss:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e2acb @ 000e2acb, 319 bytes * /

void FUN_000e2acb(HSActionsAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id self_00;
  HSActionsAssistantPane *pHVar2;
  undefined *puVar3;
  undefined4 uVar4;
  undefined *puVar5;
  undefined4 uVar6;
  HSActionsAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_actor);
  self_00 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  puVar5 = &DAT_0036c5c8;
  uVar4 = *(undefined4 *)PTR_0033601c;
  puVar3 = sel_HSActionsAssistantPane_actorDidChange_;
  uVar6 = uVar4;
  _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_HSActionsAssistantPane_actorDidChange_,uVar4,&DAT_0036c5c8,uVar4);
  pHVar2 = _objc_msgSend(self,sel_actionEvent);
  pvVar1 = _objc_msgSend(pvVar1,sel_automaticTimerForActionEvent_,pHVar2);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController,pHVar2,puVar3,uVar4,puVar5);
    uVar4 = uVar6;
    puVar5 = &DAT_0036c898;
    pHVar2 = self;
    puVar3 = sel_HSActionsAssistantPane_automaticTimerDidChange_;
    _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                  sel_HSActionsAssistantPane_automaticTimerDidChange_,uVar4,&DAT_0036c898);
  }
  _objc_msgSend(self->_thingsToDoActionTypes,sel_release,pHVar2,puVar3,uVar4,puVar5);
  self->_thingsToDoActionTypes = (id)0x0;
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00350570;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    id actor = [self actor];
    id timer;
    [[actor attributeObservingController] removeObserver:self selector:@selector(HSActionsAssistantPane_actorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSActor)];
    timer = [actor automaticTimerForActionEvent:[self actionEvent]];
    if (timer != nil) {
        [[timer attributeObservingController] removeObserver:self selector:@selector(HSActionsAssistantPane_automaticTimerDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSAutomaticTimerAttributes)];
    }
    [_thingsToDoActionTypes release];
    _thingsToDoActionTypes = nil;
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    int uVar1;
    id pvVar2;
    id pvVar3;

    [super viewWillAppear:aAppear];
    [self validateNib];
    [_placesToGoTableView reloadData];
    [_thingsToDoTableView reloadData];
    pvVar2 = [self actor];
    pvVar3 = [pvVar2 attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar3 addObserver:self selector:@selector(HSActionsAssistantPane_actorDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSActor) withPriority:-0.25];
    pvVar2 = [pvVar2 automaticTimerForActionEvent:[self actionEvent]];
    if (pvVar2 != nil) {
        pvVar2 = [pvVar2 attributeObservingController]
        ;
        [pvVar2 addObserver:self selector:@selector(HSActionsAssistantPane_automaticTimerDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSAutomaticTimerAttributes) withPriority:-0.25];
    }
}

- (void)HSActionsAssistantPane_automaticTimerDidChange:(id)aChange
{
    [_thingsToDoTableView reloadData];
}

- (void)HSActionsAssistantPane_actorDidChange:(id)aChange
{
    [_placesToGoTableView reloadData];
    [_thingsToDoTableView reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e2d78 @ 000e2d78, 232 bytes * /

void FUN_000e2d78(HSActionsAssistantPane *self,SEL _cmd)

{
  float fVar1;
  undefined4 uVar2;
  float local_1c [2];
  float local_14;
  
  _objc_msgSend(self->_containerView,sel_addSubview_,self->_placesToGoView);
  fVar1 = *(float *)PTR_00336074;
  uVar2 = *(undefined4 *)(PTR_00336074 + 4);
  _objc_msgSend(self->_placesToGoView,sel_setFrameOrigin_,fVar1,uVar2);
  _objc_msgSend_stret(local_1c,self->_placesToGoView,sel_frame);
  _objc_msgSend(self->_containerView,sel_addSubview_,self->_thingsToDoView);
  _objc_msgSend(self->_thingsToDoView,sel_setFrameOrigin_,local_1c[0] + local_14 + fVar1,uVar2);
  return;
}

*/
- (void)validateNib
{
    NSRect frame;
    [_containerView addSubview:_placesToGoView];
    [_placesToGoView setFrameOrigin:NSZeroPoint];
    frame = [_placesToGoView frame];
    [_containerView addSubview:_thingsToDoView];
    [_thingsToDoView setFrameOrigin:NSMakePoint(frame.origin.x + frame.size.width + NSZeroPoint.x, NSZeroPoint.y)];
}

- (void)setActionEvent:(id)aEvent
{
    if (![_actionEvent isEqual:aEvent]) {
        [_actionEvent release];
        _actionEvent = [aEvent retain];
    }
}

- (id)actionEvent
{
    return _actionEvent;
}

- (id)actor
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
}

- (void)dealloc
{
    [_actionEvent release];
    [_buttonBackgroundRenderer release];
    [_placesToGoActionTypes release];
    [_thingsToDoActionTypes release];
    [_availablePlacesToGoActionTypes release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [super dealloc];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        if (_navigationSwitcherClass == nil) {
            pHVar1_2 = nil;
        }
        else {
            pHVar1_2 = [_navigationSwitcherClass new];
        }
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e1c92 @ 000e1c92, 316 bytes * /

id FUN_000e1c92(HSActionsAssistantPane *self,SEL _cmd,id initWithActionEvent,
               Class navigationSwitcherClass)

{
  id self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  id local_20;
  HSActionsAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00350570;
  self_00 = _objc_msgSendSuper(&local_1c,sel_initWithNibName_,&cfstr_ActionsAssistantPane);
  if (self_00 != (id)0x0) {
    local_20 = initWithActionEvent;
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar3 = &cfstr_AssistantPanes;
    pcVar2 = &cfstr_empty;
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Actions,&cfstr_empty
                           ,&cfstr_AssistantPanes);
    _objc_msgSend(self_00,sel_setTitle_,pvVar1);
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_actions);
    _objc_msgSend(self_00,sel_setIcon_,pvVar1);
    if (initWithActionEvent == (id)0x0) {
      local_20 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8,
                               pcVar2,pcVar3);
    }
    _objc_msgSend(self_00,sel_setActionEvent_,local_20);
    *(Class *)((int)self_00 + 0x88) = navigationSwitcherClass;
  }
  return self_00;
}

*/
- (id)initWithActionEvent:(id)aEvent navigationSwitcherClass:(Class)aClass
{
    self = [super initWithNibName:@"ActionsAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Actions" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"actions"]];
        if (aEvent == nil) {
            aEvent = [HSActionEvent actionEventOfType:kHSDefaultActionEventType];
        }
        [self setActionEvent:aEvent];
        _navigationSwitcherClass = aClass;
    }
    return self;
}

- (id)initWithActionEvent:(id)aEvent
{
    return [self initWithActionEvent:aEvent navigationSwitcherClass:nil];
}

- (id)initWithNibName:(id)aName
{
    return [self initWithActionEvent:nil];
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

@implementation HSActionsTableView

- (void)selectRowIndexes:(id)aIndexes byExtendingSelection:(BOOL)aSelection
{

}

@end

