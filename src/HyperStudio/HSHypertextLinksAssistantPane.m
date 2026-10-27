#import "HSHypertextLinksAssistantPane.h"
static id sDAT_00342a24;
static id sDAT_00342a28;

static id sDAT_00342a24;
static id sDAT_00342a28;


@implementation HSHypertextLinksAssistantPane

/* i386 ivar offsets: _titleTextField=0x5c, _addButton=0x60, _replaceButton=0x64, _linksTableView=0x68, _thisFieldOnlyButton=0x6c, _editActionsButton=0x70, _initialText=0x74, _initialStack=0x78, _initialField=0x7c, _initialPane=0x80, _stackContainer=0x84, _fieldContainer=0x88, _paneSwitcher=0x8c, _actionHelpView=0x90, _helpTextView=0x94, _helpText=0x98, _helpDrawer=0x9c, _helpIsActive=0xa0, _linkInModalSession=0xa4 */

+ (id)invalidActionImage
{
    if (sDAT_00342a28 == nil) {
        sDAT_00342a28 = [[NSImage imageNamed:@"auxInvalidAction"] retain];
    }
    return sDAT_00342a28;
}

+ (id)validActionImage
{
    if (sDAT_00342a24 == nil) {
        sDAT_00342a24 = [[NSImage imageNamed:@"auxAction"] retain];
    }
    return sDAT_00342a24;
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022d712 @ 0022d712, 672 bytes * /

id FUN_0022d712(HSHypertextLinksAssistantPane *self,SEL _cmd,id tableView,id toolTipForCell,
               NSRect *rect,id tableColumn,int row,NSPoint mouseLocation)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  bool bVar5;
  cfstringStruct *pcVar6;
  undefined *puVar7;
  int iVar8;
  id local_18;
  int local_14;
  
  local_18 = _objc_msgSend(cls_NSString,sel_string);
  pvVar1 = _objc_msgSend(tableColumn,sel_identifier);
  pcVar6 = &cfstr_ActionsColumn;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_ActionsColumn);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(tableColumn,sel_identifier,pcVar6);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_ValidActionColumn);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_linkAtIndex_,row);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00383cf0);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperActions);
      pvVar2 = _objc_msgSend(pvVar1,sel_count);
      if (0 < (int)pvVar2) {
        local_14 = 0;
        do {
          pvVar3 = _objc_msgSend(pvVar1,sel_objectAtIndex_,local_14);
          puVar7 = &DAT_00383e1c;
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00383e1c);
          if (pvVar3 == (id)0x0) {
            bVar5 = false;
          }
          else {
            pvVar3 = _objc_msgSend(pvVar3,sel_isValid,puVar7);
            bVar5 = (char)pvVar3 == '\0';
          }
          iVar8 = local_14;
          pvVar3 = _objc_msgSend(pvVar1,sel_objectAtIndex_,local_14);
          pvVar3 = _objc_msgSend(pvVar3,sel_class);
          pvVar3 = _objc_msgSend(pvVar3,sel_localizedName);
          if (bVar5) {
            pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle,iVar8);
            pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr___Broken_,
                                   &cfstr_empty,&cfstr_AssistantPanes);
            pvVar3 = _objc_msgSend(pvVar3,sel_stringByAppendingString_,pvVar4);
          }
          if (local_14 != 0) {
            pvVar3 = _objc_msgSend(local_18,sel_stringByAppendingFormat_,&cfstr_____,pvVar3);
          }
          local_18 = pvVar3;
          local_14 = local_14 + 1;
        } while (local_14 < (int)pvVar2);
      }
    }
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar6);
    local_18 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                             &cfstr_Click_to_remove_the_hypertext_link_,&cfstr_empty,
                             &cfstr_AssistantPanes);
  }
  return local_18;
}

*/
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    NSString *toolTip = [NSString string];
    if ([[aColumn identifier] isEqualToString:@"ActionsColumn"]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Click to remove the hypertext link." value:@"" table:@"AssistantPanes"];
    }
    if ([[aColumn identifier] isEqualToString:@"ValidActionColumn"]) {
        NSArray *actions = [[[self linkAtIndex:aRow] queryHyperInterface:@protocol(HSActor)] hyperActions];
        NSInteger count = [actions count];
        for (NSInteger i = 0; i < count; i++) {
            id validation = [[actions objectAtIndex:i] queryHyperInterface:@protocol(HSActionValidation)];
            BOOL isBroken = validation != nil && ![validation isValid];
            NSString *name = [[[actions objectAtIndex:i] class] localizedName];
            if (isBroken) {
                name = [name stringByAppendingString:[[NSBundle mainBundle] localizedStringForKey:@" (Broken)" value:@"" table:@"AssistantPanes"]];
            }
            if (i != 0) {
                name = [toolTip stringByAppendingFormat:@", %@", name];
            }
            toolTip = name;
        }
    }
    return toolTip;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022d9b2 @ 0022d9b2, 402 bytes * /

id FUN_0022d9b2(HSHypertextLinksAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  SEL pcVar4;
  undefined *self_00;
  SEL op;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar5 = &cfstr_LinksColumn;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_LinksColumn);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_ValidActionColumn);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_linkAtIndex_,row);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00383cf0);
      pvVar3 = _objc_msgSend(pvVar1,sel_hyperActions);
      pvVar3 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar3 != (id)0x0) {
        row = (int)&DAT_00383e1c;
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00383e1c);
        pvVar1 = _objc_msgSend(pvVar1,sel_isValid);
        puVar2 = _objc_msgSend(self,sel_class);
        pcVar4 = sel_validActionImage;
        self_00 = puVar2;
        op = sel_invalidActionImage;
        if ((char)pvVar1 != '\0') goto LAB_0022da1c;
        goto LAB_0022da23;
      }
    }
    pvVar1 = (id)0x0;
  }
  else {
    puVar2 = _objc_msgSend(self,sel_linkAtIndex_,row);
    pcVar4 = sel_title;
    self_00 = cls_NSString;
    op = sel_string;
    if (puVar2 != (undefined *)0x0) {
LAB_0022da1c:
      self_00 = puVar2;
      op = pcVar4;
    }
LAB_0022da23:
    pvVar1 = _objc_msgSend(self_00,op,row);
  }
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([[aColumn identifier] isEqualToString:@"LinksColumn"]) {
        id link = [self linkAtIndex:aRow];
        if (link == nil) {
            return [NSString string];
        }
        return [link title];
    }
    if ([[aColumn identifier] isEqualToString:@"ValidActionColumn"]) {
        id actor = [[self linkAtIndex:aRow] queryHyperInterface:@protocol(HSActor)];
        if ([[actor hyperActions] count] != 0) {
            if ([[actor queryHyperInterface:@protocol(HSActionValidation)] isValid]) {
                return [[self class] validActionImage];
            }
            return [[self class] invalidActionImage];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022db44 @ 0022db44, 41 bytes * /

int FUN_0022db44(HSHypertextLinksAssistantPane *self,SEL _cmd,id numberOfRowsInTableView)

{
  id pvVar1;
  int extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_stackContainerRange);
  return extraout_EDX + (int)pvVar1;
}

*/
- (NSInteger)numberOfRowsInTableView:(id)aView
{
    NSRange range = [self stackContainerRange];
    return range.location + range.length;
}

- (void)clearTextFieldAndSelectLinkAtIndex:(NSUInteger)aIndex
{
    [_titleTextField setStringValue:@""];
    [self selectLinkAtIndex:aIndex];
    [[self window] makeFirstResponder:_linksTableView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022dbe8 @ 0022dbe8, 216 bytes * /

void FUN_0022dbe8(HSHypertextLinksAssistantPane *self,SEL _cmd,uint selectLinkAtIndex)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  
  pvVar1 = _objc_msgSend(self->_linksTableView,sel_numberOfRows);
  pcVar4 = sel_indexSet;
  if ((int)selectLinkAtIndex < (int)pvVar1) {
    pcVar4 = sel_indexSetWithIndex_;
  }
  pvVar2 = _objc_msgSend(cls_NSIndexSet,pcVar4);
  pvVar3 = _objc_msgSend(self->_linksTableView,sel_selectedRowIndexes);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToIndexSet_,pvVar2);
  pcVar4 = sel_updateUI;
  if ((char)pvVar3 == '\0') {
    _objc_msgSend(self->_linksTableView,sel_selectRowIndexes_byExtendingSelection_,pvVar2,0);
    self = self->_linksTableView;
    pcVar4 = sel_scrollRowToVisible_;
    pvVar1 = (id)selectLinkAtIndex;
  }
  _objc_msgSend(self,pcVar4,pvVar1);
  return;
}

*/
- (void)selectLinkAtIndex:(NSUInteger)aIndex
{
    NSIndexSet *indexes = (NSInteger)aIndex < [_linksTableView numberOfRows] ? [NSIndexSet indexSetWithIndex:aIndex] : [NSIndexSet indexSet];
    if ([[_linksTableView selectedRowIndexes] isEqualToIndexSet:indexes]) {
        [self updateUI];
        return;
    }
    [_linksTableView selectRowIndexes:indexes byExtendingSelection:NO];
    [_linksTableView scrollRowToVisible:aIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022dcc0 @ 0022dcc0, 471 bytes * /

void FUN_0022dcc0(HSHypertextLinksAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  uint uVar4;
  int extraout_EDX;
  uint extraout_EDX_00;
  bool bVar5;
  
  _objc_msgSend(self->_linksTableView,sel_reloadData);
  pvVar1 = _objc_msgSend(self->_linksTableView,sel_selectedRowIndexes);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  pvVar3 = _objc_msgSend(self->_titleTextField,sel_stringValue);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  _objc_msgSend(self->_addButton,sel_setEnabled_,(uint)(pvVar3 != (id)0x0));
  bVar5 = pvVar2 == (id)0x1;
  _objc_msgSend(self->_replaceButton,sel_setEnabled_,(uint)(pvVar3 != (id)0x0 && bVar5));
  pvVar2 = _objc_msgSend(self,sel_fieldContainer);
  pvVar3 = _objc_msgSend(self,sel_stackContainerRange);
  uVar4 = (uint)((pvVar2 != (id)0x0 && extraout_EDX != -(int)pvVar3) && bVar5);
  _objc_msgSend(self->_thisFieldOnlyButton,sel_setEnabled_,uVar4);
  if ((pvVar2 == (id)0x0 || extraout_EDX == -(int)pvVar3) || !bVar5) {
    pvVar1 = self->_thisFieldOnlyButton;
    uVar4 = 0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_fieldContainerRange,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_firstIndex);
    uVar4 = -(uint)((uint)((int)pvVar1 - (int)pvVar2) < extraout_EDX_00) & 1;
    pvVar1 = self->_thisFieldOnlyButton;
  }
  _objc_msgSend(pvVar1,sel_setState_,uVar4);
  _objc_msgSend(self->_editActionsButton,sel_setEnabled_,(uint)bVar5);
  return;
}

*/
- (void)updateUI
{
    [_linksTableView reloadData];
    NSIndexSet *selection = [_linksTableView selectedRowIndexes];
    BOOL isSingleSelection = [selection count] == 1;
    BOOL hasTitle = [[_titleTextField stringValue] length] != 0;
    [_addButton setEnabled:hasTitle];
    [_replaceButton setEnabled:hasTitle && isSingleSelection];
    id fieldContainer = [self fieldContainer];
    NSRange stackRange = [self stackContainerRange];
    BOOL canToggle = fieldContainer != nil && stackRange.location + stackRange.length != 0 && isSingleSelection;
    [_thisFieldOnlyButton setEnabled:canToggle];
    if (canToggle) {
        NSRange fieldRange = [self fieldContainerRange];
        [_thisFieldOnlyButton setState:[selection firstIndex] - fieldRange.location < fieldRange.length];
    } else {
        [_thisFieldOnlyButton setState:NSControlStateValueOff];
    }
    [_editActionsButton setEnabled:isSingleSelection];
}

- (void)editActions:(id)aActions
{
    id pvVar1_3;
    id pvVar1_4;
    id pvVar1_6;
    Class pvVar2_3;

    pvVar1_3 = [self linkAtIndex:[[_linksTableView selectedRowIndexes] firstIndex]];
    [[[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:_initialStack] selectHypertextLink:pvVar1_3];
    if ([self modalViewController] == nil) {
        pvVar1_4 = [HSActionsAssistantPane alloc];
        pvVar2_3 = [HSActionsPaneGoBackSwitcher class];
        pvVar1_6 = [[pvVar1_4 initWithActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] navigationSwitcherClass:pvVar2_3] autorelease];
        [self presentModalViewController:[[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_6] animated:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022e011 @ 0022e011, 473 bytes * /

void FUN_0022e011(HSHypertextLinksAssistantPane *self,SEL _cmd,id removeLink)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(self->_linksTableView,sel_selectedRowIndexes);
  pvVar2 = _objc_msgSend(pvVar1,sel_firstIndex);
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  _objc_msgSend(self_00,sel_setAlertStyle_,5);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHypertextLinkDeleteMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHypertextLinkDeleteButtonTitle,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pcVar5 = &cfstr_Alerts;
  pcVar4 = &cfstr_empty;
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar3 = _objc_msgSend(self_00,sel_runModal);
  if (pvVar3 == (id)0x3e8) {
    _objc_msgSend(self,sel_removeLinkAtIndex_,pvVar2,pcVar4,pcVar5);
    pvVar1 = pvVar2;
  }
  _objc_msgSend(self_00,sel_release,pvVar1,pcVar4,pcVar5);
  return;
}

*/
- (void)removeLink:(id)aLink
{
    NSUInteger index = [[_linksTableView selectedRowIndexes] firstIndex];
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHypertextLinkDeleteMessageText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHypertextLinkDeleteButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self removeLinkAtIndex:index];
    }
    [alert release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022e1ea @ 0022e1ea, 398 bytes * /

void FUN_0022e1ea(HSHypertextLinksAssistantPane *self,SEL _cmd,id toggleThisFieldOnly)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  uint extraout_EDX;
  char cVar6;
  
  pvVar1 = _objc_msgSend(self->_linksTableView,sel_selectedRowIndexes);
  pvVar2 = _objc_msgSend(pvVar1,sel_firstIndex);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(self,sel_linkAtIndex_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_title);
  pvVar4 = _objc_msgSend(self,sel_fieldContainerRange);
  if ((uint)((int)pvVar2 - (int)pvVar4) < extraout_EDX) {
    pvVar1 = _objc_msgSend(self,sel_fieldContainer,pvVar1);
    op = sel_stackContainer;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_stackContainer,pvVar1);
    op = sel_fieldContainer;
  }
  pvVar4 = _objc_msgSend(self,op);
  pvVar2 = pvVar3;
  pvVar5 = _objc_msgSend(pvVar4,sel_linkWithTitle_,pvVar3);
  cVar6 = pvVar5 == (id)0x0;
  if (!(bool)cVar6) {
    pvVar2 = _objc_msgSend(self,sel_confirmLinkReplacement,pvVar2);
    cVar6 = (char)pvVar2;
    if (cVar6 != '\0') {
      _objc_msgSend(pvVar4,sel_removeLinkWithTitle_,pvVar3);
    }
  }
  if (cVar6 != '\0') {
    _objc_msgSend(pvVar4,sel_takeLinkWithTitle_fromContainer_,pvVar3,pvVar1);
    pvVar1 = _objc_msgSend(pvVar4,sel_allSortedTitles);
    pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar3);
    _objc_msgSend(self,sel_selectLinkAtIndex_,pvVar1);
  }
  return;
}

*/
- (void)toggleThisFieldOnly:(id)aOnly
{
    NSUInteger index = [[_linksTableView selectedRowIndexes] firstIndex];
    NSString *title = [[self linkAtIndex:index] title];
    NSRange fieldRange = [self fieldContainerRange];
    id source;
    id destination;
    if (index - fieldRange.location < fieldRange.length) {
        source = [self fieldContainer];
        destination = [self stackContainer];
    } else {
        source = [self stackContainer];
        destination = [self fieldContainer];
    }
    BOOL shouldMove = [destination linkWithTitle:title] == nil;
    if (!shouldMove) {
        shouldMove = [self confirmLinkReplacement];
        if (shouldMove) {
            [destination removeLinkWithTitle:title];
        }
    }
    if (shouldMove) {
        [destination takeLinkWithTitle:title fromContainer:source];
        [self selectLinkAtIndex:[[destination allSortedTitles] indexOfObject:title]];
    }
}

- (void)replaceLink:(id)aLink
{
    NSString *pvVar1;

    pvVar1 = [_titleTextField stringValue];
    [self replaceLinkAtIndex:[_linksTableView selectedRow] withTitle:pvVar1];
}

- (void)addLink:(id)aLink
{
    [self addLinkWithTitle:[_titleTextField stringValue]];
}

- (void)changeTitle:(id)aTitle
{
    [self addLinkWithTitle:[_titleTextField stringValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022e45e @ 0022e45e, 164 bytes * /

void FUN_0022e45e(HSHypertextLinksAssistantPane *self,SEL _cmd,id textViewTextDidChange)

{
  id pvVar1;
  id self_00;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(textViewTextDidChange,sel_object);
  if (pvVar1 == self->_initialField) {
    self_00 = _objc_msgSend(pvVar1,sel_hyperPlainText);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperSelectedRange);
    pvVar1 = _objc_msgSend(self_00,sel_substringWithRange_,pvVar1,extraout_EDX);
    _objc_msgSend(self->_titleTextField,sel_setStringValue_,pvVar1);
    _objc_msgSend(self,sel_updateUI);
  }
  return;
}

*/
- (void)textViewTextDidChange:(id)aChange
{
    id field = [aChange object];
    if (field == _initialField) {
        [_titleTextField setStringValue:[[field hyperPlainText] substringWithRange:[field hyperSelectedRange]]];
        [self updateUI];
    }
}

- (void)controlTextDidChange:(id)aChange
{
    [self updateUI];
}

- (void)containerWillChangeDuringModal:(id)aModal
{
    id self_00;

    self_00 = [[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:_initialStack];
    if ([[[aModal userInfo] objectForKey:@"HSHypertextLinkRemovedLinks"] containsObject:_linkInModalSession]) {
        if ([self modalViewController] != nil) {
            [self dismissModalViewControllerAnimated:YES];
        }
        [self_00 selectHypertextLink:nil];
    }
    [[_linkInModalSession queryHyperInterface:@protocol(HSAttributeObserving)] removeObserver:self selector:@selector(containerWillChangeDuringModal:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    _linkInModalSession = nil;
}

- (void)containerDidChange:(id)aChange
{
    [self updateUI];
}

- (void)removeLinkAtIndex:(NSUInteger)aIndex
{
    id pvVar1;

    pvVar1 = [self linkAtIndex:aIndex];
    [[self containerForLinkAtIndex:aIndex] removeLinkWithTitle:[pvVar1 title]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022e708 @ 0022e708, 508 bytes * /

void FUN_0022e708(HSHypertextLinksAssistantPane *self,SEL _cmd,uint replaceLinkAtIndex,id withTitle)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  bool bVar5;
  
  pvVar1 = _objc_msgSend(withTitle,sel_length);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_linkAtIndex_,replaceLinkAtIndex);
    self_00 = _objc_msgSend(self,sel_containerForLinkAtIndex_,replaceLinkAtIndex);
    pvVar3 = _objc_msgSend(pvVar2,sel_title);
    pvVar1 = withTitle;
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,withTitle);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self,sel_stackContainer,pvVar1);
      pvVar1 = withTitle;
      pvVar4 = _objc_msgSend(pvVar3,sel_linkWithTitle_,withTitle);
      if (pvVar4 == (id)0x0) {
        pvVar3 = _objc_msgSend(self,sel_fieldContainer,pvVar1);
        pvVar1 = withTitle;
        pvVar4 = _objc_msgSend(pvVar3,sel_linkWithTitle_,withTitle);
        bVar5 = pvVar4 != (id)0x0 && self_00 == pvVar3;
      }
      else {
        bVar5 = self_00 == pvVar3;
      }
      if (bVar5) {
        pvVar1 = _objc_msgSend(self,sel_confirmLinkReplacement,pvVar1);
        if ((char)pvVar1 == '\0') {
          return;
        }
        pvVar1 = withTitle;
        _objc_msgSend(pvVar3,sel_removeLinkWithTitle_,withTitle);
      }
      pvVar2 = _objc_msgSend(pvVar2,sel_title,pvVar1);
      pvVar1 = withTitle;
      _objc_msgSend(self_00,sel_renameLinkWithTitle_to_,pvVar2,withTitle);
      pvVar2 = _objc_msgSend(self_00,sel_allSortedTitles);
      pvVar2 = _objc_msgSend(pvVar2,sel_indexOfObject_,withTitle);
      pvVar3 = _objc_msgSend(self,sel_stackContainer);
      if (self_00 == pvVar3) {
        pvVar1 = _objc_msgSend(self,sel_fieldLinkCount,withTitle,pvVar1);
        pvVar2 = (id)((int)pvVar2 + (int)pvVar1);
      }
      _objc_msgSend(self,sel_clearTextFieldAndSelectLinkAtIndex_,pvVar2);
    }
  }
  return;
}

*/
- (void)replaceLinkAtIndex:(NSUInteger)aIndex withTitle:(id)aTitle
{
    if ([aTitle length] == 0) {
        return;
    }
    id link = [self linkAtIndex:aIndex];
    id container = [self containerForLinkAtIndex:aIndex];
    if ([[link title] isEqualToString:aTitle]) {
        return;
    }
    id otherContainer = [self stackContainer];
    BOOL conflicts;
    if ([otherContainer linkWithTitle:aTitle] != nil) {
        conflicts = container == otherContainer;
    } else {
        otherContainer = [self fieldContainer];
        conflicts = [otherContainer linkWithTitle:aTitle] != nil && container == otherContainer;
    }
    if (conflicts) {
        if (![self confirmLinkReplacement]) {
            return;
        }
        [otherContainer removeLinkWithTitle:aTitle];
    }
    [container renameLinkWithTitle:[link title] to:aTitle];
    NSUInteger index = [[container allSortedTitles] indexOfObject:aTitle];
    if (container == [self stackContainer]) {
        index += [self fieldLinkCount];
    }
    [self clearTextFieldAndSelectLinkAtIndex:index];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022e904 @ 0022e904, 334 bytes * /

void FUN_0022e904(HSHypertextLinksAssistantPane *self,SEL _cmd,id addLinkWithTitle)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  
  pvVar1 = _objc_msgSend(addLinkWithTitle,sel_length);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_stackContainer);
    pvVar1 = addLinkWithTitle;
    pvVar2 = _objc_msgSend(pvVar2,sel_linkWithTitle_,addLinkWithTitle);
    cVar3 = pvVar2 == (id)0x0;
    if (!(bool)cVar3) {
      pvVar2 = _objc_msgSend(self,sel_confirmLinkReplacement,pvVar1);
      cVar3 = (char)pvVar2;
      if (cVar3 != '\0') {
        pvVar2 = _objc_msgSend(self,sel_stackContainer,pvVar1);
        pvVar1 = addLinkWithTitle;
        _objc_msgSend(pvVar2,sel_removeLinkWithTitle_,addLinkWithTitle);
      }
    }
    if (cVar3 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_stackContainer,pvVar1);
      _objc_msgSend(pvVar1,sel_addLinkWithTitle_,addLinkWithTitle);
      pvVar1 = _objc_msgSend(self,sel_fieldLinkCount);
      pvVar2 = _objc_msgSend(self,sel_stackContainer);
      pvVar2 = _objc_msgSend(pvVar2,sel_allSortedTitles);
      pvVar2 = _objc_msgSend(pvVar2,sel_indexOfObject_,addLinkWithTitle);
      _objc_msgSend(self,sel_clearTextFieldAndSelectLinkAtIndex_,(int)pvVar2 + (int)pvVar1);
    }
  }
  return;
}

*/
- (void)addLinkWithTitle:(id)aTitle
{
    if ([aTitle length] == 0) {
        return;
    }
    BOOL shouldAdd = [[self stackContainer] linkWithTitle:aTitle] == nil;
    if (!shouldAdd) {
        shouldAdd = [self confirmLinkReplacement];
        if (shouldAdd) {
            [[self stackContainer] removeLinkWithTitle:aTitle];
        }
    }
    if (shouldAdd) {
        [(id<HSHypertextLinkContainerAttributes>)[self stackContainer] addLinkWithTitle:aTitle];
        NSUInteger fieldCount = [self fieldLinkCount];
        [self clearTextFieldAndSelectLinkAtIndex:[[[self stackContainer] allSortedTitles] indexOfObject:aTitle] + fieldCount];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022ea52 @ 0022ea52, 500 bytes * /

BOOL FUN_0022ea52(HSHypertextLinksAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  _objc_msgSend(self_00,sel_setAlertStyle_,5);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSReplaceHypertextLinkMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSReplaceHypertextLinkInformativeText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSReplaceHypertextLinkButtonTitle,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(self_00,sel_runModal);
  _objc_msgSend(self_00,sel_release);
  return pvVar1 == (id)0x3e8;
}

*/
- (BOOL)confirmLinkReplacement
{
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSReplaceHypertextLinkMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSReplaceHypertextLinkInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSReplaceHypertextLinkButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    NSModalResponse response = [alert runModal];
    [alert release];
    return response == NSAlertFirstButtonReturn;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022ec46 @ 0022ec46, 77 bytes * /

id FUN_0022ec46(HSHypertextLinksAssistantPane *self,SEL _cmd,uint containerForLinkAtIndex)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_fieldLinkCount);
  op = sel_stackContainer;
  if (containerForLinkAtIndex < pvVar1) {
    op = sel_fieldContainer;
  }
  pvVar1 = _objc_msgSend(self,op);
  return pvVar1;
}

*/
- (id)containerForLinkAtIndex:(NSUInteger)aIndex
{
    if (aIndex < [self fieldLinkCount]) {
        return [self fieldContainer];
    }
    return [self stackContainer];
}

- (id)linkAtIndex:(NSUInteger)aIndex
{
    NSUInteger pvVar1;
    id self_00;
    id pvVar1_4;

    pvVar1 = [self fieldLinkCount];
    if (aIndex < pvVar1) {
        self_00 = [self fieldContainer];
        pvVar1_4 = [[[self fieldContainer] allSortedTitles] objectAtIndex:aIndex];
    }
    else {
        self_00 = [self stackContainer];
        pvVar1_4 = [[[self stackContainer] allSortedTitles] objectAtIndex:aIndex - (int)pvVar1];
    }
    return [self_00 linkWithTitle:pvVar1_4];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022ed96 @ 0022ed96, 42 bytes * /

ulonglong FUN_0022ed96(HSHypertextLinksAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_fieldLinkCount);
  return ZEXT48(pvVar1) << 0x20;
}

*/
- (NSRange)fieldContainerRange
{
    return NSMakeRange(0, [self fieldLinkCount]);
}

- (NSRange)stackContainerRange
{
    NSUInteger pvVar1_3;

    pvVar1_3 = [[[self stackContainer] allSortedTitles] count];
    return NSMakeRange([self fieldLinkCount], pvVar1_3);
}

- (NSUInteger)fieldLinkCount
{
    return (unsigned int)[[[self fieldContainer] allSortedTitles] count];
}

- (id)fieldContainer
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _fieldContainer;
    if (pvVar1 == nil) {
        pvVar1_3 = [[_initialField queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] retain];
        _fieldContainer = pvVar1_3;
        [[pvVar1_3 attributeObservingController] addObserver:self selector:@selector(containerDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withPriority:0.25];
        pvVar1 = _fieldContainer;
    }
    return pvVar1;
}

- (id)stackContainer
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _stackContainer;
    if (pvVar1 == nil) {
        pvVar1_3 = [[_initialStack queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] retain];
        _stackContainer = pvVar1_3;
        [[pvVar1_3 attributeObservingController] addObserver:self selector:@selector(containerDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withPriority:0.25];
        pvVar1 = _stackContainer;
    }
    return pvVar1;
}

- (id)field
{
    return [[self document] selectedHyperObject];
}

- (id)document
{
    return [_initialStack document];
}

- (void)dismissModalViewControllerAnimated:(BOOL)aAnimated
{
    [[_linkInModalSession queryHyperInterface:@protocol(HSAttributeObserving)] removeObserver:self selector:@selector(containerWillChangeDuringModal:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    _linkInModalSession = nil;
    [super dismissModalViewControllerAnimated:aAnimated];
}

- (void)presentModalViewController:(id)aController animated:(BOOL)aAnimated
{
    id pvVar1_2;

    pvVar1_2 = [[[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:_initialStack] selectedHypertextLink];
    _linkInModalSession = pvVar1_2;
    [[pvVar1_2 queryHyperInterface:@protocol(HSAttributeObserving)] addObserver:self selector:@selector(containerWillChangeDuringModal:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute) withPriority:0.25];
    [super presentModalViewController:aController animated:aAnimated];
    [aController setParentViewController:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022f1eb @ 0022f1eb, 416 bytes * /

id FUN_0022f1eb(HSHypertextLinksAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(self,sel_modalViewController);
  pcVar4 = (cfstringStruct *)sel_windowTitle;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_windowTitle);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_modalViewController,pcVar4);
    pvVar2 = _objc_msgSend(pvVar1,sel_windowTitle);
    self_00 = cls_NSString;
    pvVar1 = _objc_msgSend(cls_HSHypertextLinksProxyForInspector,
                           sel_sharedHypertextLinksProxyForInspector);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedHypertextLink);
    pvVar3 = _objc_msgSend(pvVar1,sel_title);
    pvVar1 = pvVar3;
    if (pvVar2 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_HyperText_Link,
                             &cfstr_empty,&cfstr_AssistantPanes);
      pvVar2 = pvVar3;
    }
    pcVar4 = &cfstr________;
    pvVar1 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr________,pvVar1,pvVar2);
    if (pvVar1 != (id)0x0) {
      return pvVar1;
    }
  }
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_HyperText_Link,
                         &cfstr_empty,&cfstr_AssistantPanes);
  return pvVar1;
}

*/
- (id)windowTitle
{
    if ([[self modalViewController] respondsToSelector:@selector(windowTitle)]) {
        NSString *modalTitle = [[self modalViewController] windowTitle];
        NSString *linkTitle = [[[[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:_initialStack] selectedHypertextLink] title];
        NSString *title;
        if (modalTitle != nil) {
            title = [NSString stringWithFormat:@"%@ : %@", linkTitle, modalTitle];
        } else {
            title = [NSString stringWithFormat:@"%@ : %@", [[NSBundle mainBundle] localizedStringForKey:@"HyperText Link" value:@"" table:@"AssistantPanes"], linkTitle];
        }
        if (title != nil) {
            return title;
        }
    }
    return [[NSBundle mainBundle] localizedStringForKey:@"HyperText Link" value:@"" table:@"AssistantPanes"];
}

- (void)cleanUp
{
    int uVar1;
    id pvVar2;

    pvVar2 = [_fieldContainer attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(containerDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    [[_stackContainer attributeObservingController] removeObserver:self selector:@selector(containerDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    [_initialField removeAttributeObserver:self selector:@selector(textViewTextDidChange:)];
    [_titleTextField setDelegate:0];
    [_linksTableView setDelegate:0];
    [_linksTableView setDataSource:0];
    [_fieldContainer release];
    _fieldContainer = nil;
    [_stackContainer release];
    _stackContainer = nil;
    [self setInitialText:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022f53b @ 0022f53b, 723 bytes * /

void FUN_0022f53b(HSHypertextLinksAssistantPane *self,SEL _cmd,id setUp)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSHypertextLinksProxyForInspector,
                         sel_sharedHypertextLinksProxyForInspector);
  _objc_msgSend(pvVar1,sel_selectHypertextLink_,0);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_makeFirstResponder_,self->_titleTextField);
  _objc_msgSend(self->_titleTextField,sel_setStringValue_,setUp);
  _objc_msgSend(self->_titleTextField,sel_setDelegate_,self);
  pvVar1 = _objc_msgSend(self->_linksTableView,sel_tableColumnWithIdentifier_,
                         &cfstr_ValidActionColumn);
  pvVar1 = _objc_msgSend(pvVar1,sel_headerCell);
  pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Action);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  pvVar1 = _objc_msgSend(self->_linksTableView,sel_tableColumnWithIdentifier_,&cfstr_ActionsColumn);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataCell);
  pvVar2 = _objc_msgSend(cls_NSString,sel_string);
  _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
  _objc_msgSend(pvVar1,sel_setButtonType_,5);
  _objc_msgSend(pvVar1,sel_setImagePosition_,1);
  pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Minus);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  _objc_msgSend(pvVar1,sel_setBordered_,0);
  _objc_msgSend(pvVar1,sel_setTarget_,self);
  _objc_msgSend(pvVar1,sel_setAction_,sel_removeLink_);
  _objc_msgSend(self->_linksTableView,sel_setDataSource_,self);
  _objc_msgSend(self->_linksTableView,sel_setDelegate_,self);
  _objc_msgSend(self,sel_updateUI);
  _objc_msgSend(self->_initialField,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,
                self,sel_textViewTextDidChange_,*(undefined4 *)PTR_0033601c,&DAT_00383dcc,0x3e800000
               );
  return;
}

*/
- (void)setUp:(id)aUp
{
    [[[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:_initialStack] selectHypertextLink:nil];
    [[self window] makeFirstResponder:_titleTextField];
    [_titleTextField setStringValue:aUp];
    [_titleTextField setDelegate:self];
    [[[_linksTableView tableColumnWithIdentifier:@"ValidActionColumn"] headerCell] setImage:[NSImage imageNamed:@"Action"]];
    NSButtonCell *removeCell = [[_linksTableView tableColumnWithIdentifier:@"ActionsColumn"] dataCell];
    [removeCell setTitle:[NSString string]];
    [removeCell setButtonType:5];
    [removeCell setImagePosition:NSImageOnly];
    [removeCell setImage:[NSImage imageNamed:@"Minus"]];
    [removeCell setBordered:NO];
    [removeCell setTarget:self];
    [removeCell setAction:@selector(removeLink:)];
    [_linksTableView setDataSource:self];
    [_linksTableView setDelegate:self];
    [self updateUI];
    [_initialField addObserver:self selector:@selector(textViewTextDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSTextViewTextAttribute) withPriority:0.25];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022f80e @ 0022f80e, 810 bytes * /

BOOL FUN_0022f80e(HSHypertextLinksAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_fieldContainer);
  pvVar1 = _objc_msgSend(pvVar1,sel_allLinks);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while (pvVar2 = _objc_msgSend(pvVar1,sel_nextObject), pvVar2 != (id)0x0) {
    puVar3 = &DAT_00383cf0;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00383cf0);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperActions);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar2 == (id)0x0) goto LAB_0022f956;
  }
  pvVar1 = _objc_msgSend(self,sel_stackContainer);
  pvVar1 = _objc_msgSend(pvVar1,sel_allLinks);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  do {
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    if (pvVar2 == (id)0x0) {
      return '\x01';
    }
    puVar3 = &DAT_00383cf0;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00383cf0);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperActions);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
  } while (pvVar2 != (id)0x0);
LAB_0022f956:
  pvVar1 = _objc_msgSend(cls_HSAlert,sel_new,puVar3);
  _objc_msgSend(pvVar1,sel_setAlertStyle_,5);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHypertextLinkWithoutActionMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHypertextLinkWithoutActionInformativeText,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSLeaveUnassignedButtonTitle,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
  _objc_msgSend(pvVar1,sel_release);
  return pvVar2 == (id)0x3e8;
}

*/
- (BOOL)canClosePane
{
    for (id link in [[self fieldContainer] allLinks]) {
        if ([[[link queryHyperInterface:@protocol(HSActor)] hyperActions] count] == 0) {
            goto confirm;
        }
    }
    for (id link in [[self stackContainer] allLinks]) {
        if ([[[link queryHyperInterface:@protocol(HSActor)] hyperActions] count] == 0) {
            goto confirm;
        }
    }
    return YES;
confirm:;
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHypertextLinkWithoutActionMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHypertextLinkWithoutActionInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSLeaveUnassignedButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    NSModalResponse response = [alert runModal];
    [alert release];
    return response == NSAlertFirstButtonReturn;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:NO];
    }
    [self cleanUp];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022fbbf @ 0022fbbf, 101 bytes * /

void FUN_0022fbbf(HSHypertextLinksAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  cfstringStruct *pcVar1;
  HSHypertextLinksAssistantPane *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSObjectAssistantPane_003552b0;
  _objc_msgSendSuper(&local_14,sel_viewWillAppear_,(int)viewWillAppear);
  pcVar1 = &cfstr_empty;
  if (self->_initialText != (cfstringStruct *)0x0) {
    pcVar1 = self->_initialText;
  }
  _objc_msgSend(self,sel_setUp_,pcVar1);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self setUp:_initialText != nil ? _initialText : @""];
}

- (void)setInitialPane:(id)aPane
{
    [aPane retain];
    [_initialPane release];
    _initialPane = aPane;
}

- (id)initialField
{
    return _initialField;
}

- (void)setInitialField:(id)aField
{
    if (_initialField != aField) {
        [_initialField release];
        if (![aField isHyperProxy]) {
            _initialField = [aField retain];
        }
        else {
            _initialField = nil;
        }
    }
}

- (void)setInitialStack:(id)aStack
{
    [aStack retain];
    [_initialStack release];
    _initialStack = aStack;
}

- (void)setInitialText:(id)aText
{
    [aText retain];
    [_initialText release];
    _initialText = aText;
}

- (id)undoManager
{
    return [[self stack] undoManager];
}

- (BOOL)isEqual:(id)aEqual
{
    return NO;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return YES;
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _paneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSNBAAssistantNavigationPaneSwitcher alloc] initWithNibName:@"ShowHelpSwitcher"];
        _paneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _paneSwitcher;
    }
    return pHVar1;
}

- (void)hideHelp:(id)aHelp
{
    [self hideHelpNeedsRelayout:YES];
}

- (void)showHelp:(id)aHelp
{
    [self setFooterView:[self actionHelpView]];
    [[_helpTextView textStorage] setAttributedString:[self helpText]];
    [self layoutIfNeeded];
    _helpIsActive = YES;
}

- (void)hideHelpNeedsRelayout:(BOOL)aRelayout
{
    [self setFooterView:nil];
    if (aRelayout != NO) {
        [self layoutIfNeeded];
    }
    _helpIsActive = NO;
}

- (id)helpDrawer
{
    id pvVar2;
    id pvVar3;
    HSObjectAssistantDrawer *pHVar5;
    NSString *pcVar6;
    id pcVar7;
    NSBundle *pvVar2_3;
    id pvVar2_6;
    id pvVar2_7;

    pHVar5 = _helpDrawer;
    if (pHVar5 == nil) {
        pvVar2 = [HSObjectAssistantDrawer alloc];
        pvVar3 = [self assistant];
        _helpDrawer = [pvVar2 initWithContentView:[self actionHelpView] objectAssistant:pvVar3];
        pvVar2_3 = [NSBundle bundleForClass:[self class]];
        pcVar7 = @"HypertextLinkHelp";
        pcVar6 = [pvVar2_3 pathForResource:@"HypertextLinkHelp" ofType:@"rtf"];
        if (pcVar6 == NULL) {
            pcVar6 = [[NSBundle bundleForClass:[self class]] pathForResource:@"HypertextLinkHelp" ofType:@"rtfd"];
            pcVar7 = @"HypertextLinkHelp";
        }
        if (pcVar6 == NULL) {
            pvVar2_6 = nil;
        }
        else {
            pvVar2_7 = [NSAttributedString alloc];
            pvVar2_6 = [[pvVar2_7 initWithPath:pcVar6 documentAttributes:nil] autorelease];
        }
        [[_helpTextView textStorage] setAttributedString:pvVar2_6];
        pHVar5 = _helpDrawer;
    }
    return pHVar5;
}

- (BOOL)isHelpVisible
{
    return _helpIsActive;
}

- (id)actionHelpView
{
    id pvVar1;

    pvVar1 = _actionHelpView;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:@"NBAHelpView" owner:self];
        pvVar1 = _actionHelpView;
    }
    return pvVar1;
}

- (id)helpText
{
    id pvVar2;
    id pcVar3;
    NSBundle *pvVar2_3;
    NSString *pvVar2_4;
    id pcVar3_2;

    pvVar2 = _helpText;
    if (pvVar2 == nil) {
        pvVar2_3 = [NSBundle bundleForClass:[self class]];
        pcVar3 = @"HypertextLinkHelp";
        pvVar2_4 = [pvVar2_3 pathForResource:@"HypertextLinkHelp" ofType:@"rtf"];
        if (pvVar2_4 == nil) {
            pvVar2_4 = [[NSBundle bundleForClass:[self class]] pathForResource:@"HypertextLinkHelp" ofType:@"rtfd"];
            pcVar3_2 = @"HypertextLinkHelp";
        }
        if (pvVar2_4 == nil) {
            pvVar2 = _helpText;
        }
        else {
            pvVar2 = [[NSAttributedString alloc] initWithPath:pvVar2_4 documentAttributes:nil];
            _helpText = pvVar2;
        }
    }
    return pvVar2;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    int uVar1;
    id pvVar2_2;

    [[_linkInModalSession queryHyperInterface:@protocol(HSAttributeObserving)] removeObserver:self selector:@selector(containerWillChangeDuringModal:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    pvVar2_2 = [_fieldContainer attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 removeObserver:self selector:@selector(containerDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    [_fieldContainer release];
    [[_stackContainer attributeObservingController] removeObserver:self selector:@selector(containerDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSHypertextLinkContainerLinksAttribute)];
    [_stackContainer release];
    [_initialPane release];
    [_initialField removeAttributeObserver:self selector:@selector(textViewTextDidChange:)];
    [_initialField release];
    [_initialStack release];
    [_initialText release];
    [_actionHelpView release];
    [_helpText release];
    [_helpDrawer release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"HypertextLinksPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Hypertext Links" value:@"" table:@"AssistantPanes"]];
    }
    return self;
}

@end

