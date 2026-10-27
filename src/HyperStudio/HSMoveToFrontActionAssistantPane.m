#import "HSMoveToFrontActionAssistantPane.h"

@implementation HSMoveToFrontActionAssistantPane

/* i386 ivar offsets: _sourcePopUp=0x88, _availableSourceObjects=0x8c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00281c38 @ 00281c38, 382 bytes * /

void FUN_00281c38(HSMoveToFrontActionAssistantPane *self,SEL _cmd,id validatePopUp,id objectUID,
                 id context)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  char cVar3;
  uint uVar4;
  SEL op;
  
  uVar4 = 0;
  pvVar1 = _objc_msgSend(context,sel_objectEnumerator);
  do {
    cVar3 = (char)uVar4;
    self_01 = _objc_msgSend(pvVar1,sel_nextObject);
    if (self_01 == (id)0x0) break;
    pvVar2 = _objc_msgSend(self,sel_availableSourceObjects);
    pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,self_01);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00387fd0);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,objectUID);
      uVar4 = (uint)pvVar2 & 0xff;
    }
    cVar3 = (char)uVar4;
  } while (cVar3 == '\0');
  self_00 = cls_NSBundle;
  if (cVar3 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_None,&cfstr_empty,
                           &cfstr_Dialogs);
    op = sel_setTitle_;
  }
  else {
    pvVar1 = _objc_msgSend(context,sel_indexOfObject_,self_01);
    op = sel_selectItemAtIndex_;
  }
  _objc_msgSend(validatePopUp,op,pvVar1);
  return;
}

*/
- (void)validatePopUp:(id)aUp objectUID:(id)aUID context:(id)aContext
{
    BOOL found = NO;
    id object = nil;
    NSEnumerator *enumerator = [aContext objectEnumerator];
    while (!found && (object = [enumerator nextObject]) != nil) {
        if ([[self availableSourceObjects] containsObject:object]) {
            found = [[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:aUID];
        }
    }
    if (!found) {
        [aUp setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"None" value:@"" table:@"Dialogs"]];
    } else {
        [aUp selectItemAtIndex:[aContext indexOfObject:object]];
    }
}

- (void)validateUI
{
    id pvVar1;
    id pvVar2;

    pvVar1 = [self actionAttributes];
    if (pvVar1 != nil) {
        pvVar2 = [self availableSourceObjects];
        [self validatePopUp:_sourcePopUp objectUID:[pvVar1 sourceObjectUID] context:pvVar2];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)sourceChanged:(id)aChanged
{
    id pvVar2;
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[aChanged selectedItem] representedObject];
    if (pvVar1_2 != nil) {
        pvVar2 = [self availableSourceObjects];
        if (![pvVar2 containsObject:pvVar1_2]) {
            pvVar1_3 = nil;
        }
        else {
            pvVar1_3 = [pvVar1_2 hyperUID];
        }
        [[self moveToFrontActionAssistantPaneApplier] setSourceObjectUID:pvVar1_3];
    }
}

- (id)initialKeyView
{
    return _sourcePopUp;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002820b1 @ 002820b1, 523 bytes * /

void FUN_002820b1(HSMoveToFrontActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  uint uVar4;
  HSMoveToFrontActionAssistantPane *self_01;
  SEL op;
  HSMoveToFrontActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_003565d0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  _objc_msgSend(self->_availableSourceObjects,sel_release);
  self->_availableSourceObjects = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_availableSourceObjects);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  uVar4 = (uint)(pvVar1 != (id)0x0);
  _objc_msgSend(self->_sourcePopUp,sel_setEnabled_,uVar4);
  self_00 = cls_NSBundle;
  if (pvVar1 == (id)0x0) {
    self_01 = self->_sourcePopUp;
    pvVar1 = _objc_msgSend(self,sel_class,uVar4);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_Dialogs;
    pcVar3 = &cfstr_empty;
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_No_Text_Objects_On_Card,&cfstr_empty,&cfstr_Dialogs);
    op = sel_setTitle_;
  }
  else {
    pcVar2 = _objc_msgSend(self,sel_availableSourceObjects,uVar4);
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    pcVar3 = _objc_msgSend(pvVar1,sel_sourceObjectUID);
    pvVar1 = self->_sourcePopUp;
    self_01 = self;
    op = sel_fillInPopUp_objectUID_context_;
  }
  _objc_msgSend(self_01,op,pvVar1,pcVar3,pcVar2);
  pvVar1 = _objc_msgSend(self,sel_applier);
  pvVar1 = _objc_msgSend(pvVar1,sel_actor);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00388084);
  _objc_msgSend(pvVar1,sel_updateActionValidationStatus);
  _objc_msgSend(self,sel_validateUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [_availableSourceObjects release];
    _availableSourceObjects = nil;
    NSUInteger count = [[self availableSourceObjects] count];
    [_sourcePopUp setEnabled:count != 0];
    if (count == 0) {
        [_sourcePopUp setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No Text Objects On Card" value:@"" table:@"Dialogs"]];
    } else {
        [self fillInPopUp:_sourcePopUp objectUID:[[self actionAttributes] sourceObjectUID] context:[self availableSourceObjects]];
    }
    [[[[self applier] actor] queryHyperInterface:@protocol(HSActionValidation)] updateActionValidationStatus];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSMoveToFrontActionAttributes);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002818aa @ 002818aa, 563 bytes * /

void FUN_002818aa(HSMoveToFrontActionAssistantPane *self,SEL _cmd,id fillInPopUp,id objectUID,
                 id context)

{
  undefined *self_00;
  id self_01;
  id self_02;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  id self_03;
  cfstringStruct *pcVar4;
  
  _objc_msgSend(fillInPopUp,sel_removeAllItems);
  self_01 = _objc_msgSend(fillInPopUp,sel_menu);
  self_03 = (id)0x0;
  _objc_msgSend(self_01,sel_setAutoenablesItems_,0);
  self_02 = _objc_msgSend(context,sel_objectEnumerator);
  do {
    self_03 = _objc_msgSend(self_02,sel_nextObject,self_03);
    if (self_03 == (id)0x0) {
      _objc_msgSend(self,sel_validatePopUp_objectUID_context_,fillInPopUp,objectUID,context);
      return;
    }
    pvVar2 = self_03;
    pvVar3 = self_01;
    pvVar1 = _objc_msgSend(self,sel_titleForObject_inMenu_,self_03,self_01);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSNumber,sel_class,pvVar2,pvVar3);
      pvVar2 = _objc_msgSend(self_03,sel_isKindOfClass_,pvVar1);
      self_00 = cls_NSString;
      if ((char)pvVar2 != '\0') {
        pvVar3 = _objc_msgSend(self_03,sel_unsignedIntegerValue,pvVar1,pvVar3);
        pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
        pcVar4 = &cfstr_AssistantPanes;
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Card_title,
                               &cfstr_empty,&cfstr_AssistantPanes);
        pvVar1 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar2,pvVar3);
        op = sel_insertSeparatorWithTitle_;
        goto LAB_00281947;
      }
    }
    else {
      pcVar4 = &cfstr_empty;
      pvVar3 = (id)0x0;
      op = sel_addItemWithTitle_action_keyEquivalent_;
LAB_00281947:
      _objc_msgSend(self_01,op,pvVar1,pvVar3,pcVar4);
    }
    pvVar2 = _objc_msgSend(self_01,sel_itemArray,pvVar1,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
    _objc_msgSend(pvVar2,sel_setRepresentedObject_,self_03);
  } while( true );
}

*/
- (void)fillInPopUp:(id)aUp objectUID:(id)aUID context:(id)aContext
{
    [aUp removeAllItems];
    NSMenu *menu = [aUp menu];
    [menu setAutoenablesItems:NO];
    NSEnumerator *enumerator = [aContext objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id title = [self titleForObject:object inMenu:menu];
        if (title != nil) {
            [menu addItemWithTitle:title action:NULL keyEquivalent:@""];
        } else if ([object isKindOfClass:[NSNumber class]]) {
            [menu insertSeparatorWithTitle:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Card title" value:@"" table:@"AssistantPanes"], (unsigned int)[object unsignedIntegerValue]]];
        }
        /* an object without a title and that is not a card number still re-tags the last item, as in the original */
        [[[menu itemArray] lastObject] setRepresentedObject:object];
    }
    [self validatePopUp:aUp objectUID:aUID context:aContext];
}

- (id)titleForObject:(id)aObject inMenu:(id)aMenu
{
    if (![aObject isKindOfClass:[NSNumber class]]) {
        if ([[self availableSourceObjects] containsObject:aObject]) {
            return [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002822bc @ 002822bc, 689 bytes * /

id FUN_002822bc(HSMoveToFrontActionAssistantPane *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined1 *puVar8;
  undefined4 uVar9;
  id local_80;
  id local_78;
  undefined4 local_6c;
  int local_68;
  int *local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined4 local_54;
  undefined4 local_50;
  undefined1 local_4c [64];
  
  pvVar2 = self->_availableSourceObjects;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self->_availableSourceObjects = pvVar2;
    pvVar2 = _objc_msgSend(self,sel_assistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003880ac);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003880c0);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperChildren);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar3 != (id)0x0) {
      local_80 = (id)0x0;
      do {
        pvVar4 = _objc_msgSend(pvVar2,sel_objectAtIndex_,local_80);
        pvVar4 = _objc_msgSend(pvVar4,sel_hyperChildren);
        pvVar5 = _objc_msgSend(pvVar4,sel_count);
        if (pvVar5 != (id)0x0) {
          pvVar5 = self->_availableSourceObjects;
          pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInteger_,(int)local_80 + 1);
          _objc_msgSend(pvVar5,sel_addObject_,pvVar6);
        }
        local_6c = 0;
        local_68 = 0;
        local_64 = (int *)0x0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        local_54 = 0;
        local_50 = 0;
        puVar8 = local_4c;
        uVar9 = 0x10;
        local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_6c,
                                 puVar8,0x10);
        if (local_78 != (id)0x0) {
          iVar1 = *local_64;
          do {
            pvVar5 = (id)0x0;
            do {
              if (iVar1 != *local_64) {
                _objc_enumerationMutation(pvVar4);
              }
              pvVar6 = self->_availableSourceObjects;
              pvVar7 = _objc_msgSend(*(id *)(local_68 + (int)pvVar5 * 4),sel_queryHyperInterface_,
                                     &DAT_00387fd0,puVar8,uVar9);
              _objc_msgSend(pvVar6,sel_addObject_,pvVar7);
              pvVar5 = (id)((int)pvVar5 + 1);
            } while (pvVar5 < local_78);
            puVar8 = local_4c;
            uVar9 = 0x10;
            local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_6c
                                     ,puVar8,0x10);
          } while (local_78 != (id)0x0);
        }
        local_80 = (id)((int)local_80 + 1);
      } while (local_80 < pvVar3);
    }
    pvVar2 = self->_availableSourceObjects;
  }
  return pvVar2;
}

*/
- (id)availableSourceObjects
{
    if (_availableSourceObjects == nil) {
        _availableSourceObjects = [NSMutableArray new];
        id container = [[[[[self assistant] object] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] queryHyperInterface:@protocol(HSNodeContainer)];
        NSArray *cards = [container hyperChildren];
        NSUInteger cardCount = [cards count];
        for (NSUInteger index = 0; index < cardCount; index++) {
            NSArray *children = [[cards objectAtIndex:index] hyperChildren];
            if ([children count] != 0) {
                [_availableSourceObjects addObject:[NSNumber numberWithUnsignedInteger:index + 1]];
            }
            for (id child in children) {
                [_availableSourceObjects addObject:[child queryHyperInterface:@protocol(HSObjectAttributes)]];
            }
        }
    }
    return _availableSourceObjects;
    return 0;
}

- (id)actionType
{
    return [HSMoveToFrontAction actionType];
}

- (id)helpTopicKey
{
    return @"HSMoveToFront";
}

- (void)dealloc
{
    [_availableSourceObjects release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"MoveToFrontAssistantPane"];
    return self;
}

- (id)actionAttributes
{
    return [[self moveToFrontActionAssistantPaneApplier] moveToFrontActionAttributes];
}

- (id)moveToFrontActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSMoveToFrontActionAssistantPaneApplier class];
}

@end

@implementation HSMoveToFrontActionAssistantPaneApplier

/* i386 ivar offsets: _initialSourceObjectUID=0x30, _sourceObjectUID=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    pvVar1 = [super areSettingsEqual];
    if (!pvVar1) {
        bVar2 = NO;
    }
    else if (_initialSourceObjectUID == nil && _sourceObjectUID == nil) {
        bVar2 = YES;
    }
    else {
        pvVar1 = [_initialSourceObjectUID isEqual:_sourceObjectUID];
        bVar2 = pvVar1;
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_sourceObjectUID release];
    _sourceObjectUID = [_initialSourceObjectUID retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialSourceObjectUID release];
    _initialSourceObjectUID = [_sourceObjectUID retain];
}

- (void)setInitialSettingsToObject
{
    [[self moveToFrontActionAttributes] setSourceObjectUID:_initialSourceObjectUID];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self moveToFrontActionAttributes] setSourceObjectUID:_sourceObjectUID];
}

- (void)setSourceObjectUID:(id)aUID
{
    if (![_sourceObjectUID isEqual:aUID]) {
        [_sourceObjectUID release];
        _sourceObjectUID = [aUID retain];
        [self disableUndo];
        [[self moveToFrontActionAttributes] setSourceObjectUID:_sourceObjectUID];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    id pvVar1_3;

    pvVar1_3 = [[[self moveToFrontActionAttributes] sourceObjectUID] retain];
    _sourceObjectUID = pvVar1_3;
    _initialSourceObjectUID = [pvVar1_3 retain];
}

- (id)moveToFrontActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSMoveToFrontActionAttributes)];
}

- (void)dealloc
{
    [_sourceObjectUID release];
    [_initialSourceObjectUID release];
    [super dealloc];
}

@end

