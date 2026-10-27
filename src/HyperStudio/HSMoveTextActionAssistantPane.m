#import "HSMoveTextActionAssistantPane.h"

@implementation HSMoveTextActionAssistantPane

/* i386 ivar offsets: _sourcePopUp=0x88, _destinationPopUp=0x8c, _sourceMatrix=0x90, _destinationMatrix=0x94, _availableTextObjects=0x98, _availableCardIndexes=0x9c, _availableCommentItems=0xa0, _availableSourceObjects=0xa4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f4a8a @ 000f4a8a, 543 bytes * /

void FUN_000f4a8a(HSMoveTextActionAssistantPane *self,SEL _cmd,id validatePopUp,id objectUID,
                 id context)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  cfstringStruct *self_01;
  SEL op;
  cfstringStruct *pcVar3;
  char local_18;
  
  pvVar1 = _objc_msgSend(context,sel_objectEnumerator);
switchD_000f4c4f_default:
  do {
    self_01 = _objc_msgSend(pvVar1,sel_nextObject);
    local_18 = '\0';
    if (self_01 == (cfstringStruct *)0x0) goto LAB_000f4bca;
    pvVar2 = _objc_msgSend(self,sel_availableTextObjects);
    pcVar3 = self_01;
    pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,self_01);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_availableCommentItems,pcVar3);
      pcVar3 = self_01;
      pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,self_01);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(self,sel_actionAttributes,pcVar3);
        pvVar2 = _objc_msgSend(pvVar2,sel_sourceDataType);
        switch(pvVar2) {
        case (id)0x1:
          self_01 = &cfstr_This_Object_s_Comments;
          goto LAB_000f4c6f;
        case (id)0x2:
          self_01 = &cfstr_This_Card_s_Comments;
          goto LAB_000f4c6f;
        case (id)0x3:
          self_01 = &cfstr_This_Stack_s_Comments;
          goto LAB_000f4c6f;
        case (id)0x4:
          self_01 = &cfstr_All_Comments_on_This_Card;
          goto LAB_000f4c6f;
        }
        goto switchD_000f4c4f_default;
      }
    }
    else {
      pvVar2 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_0036e990);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,objectUID);
      local_18 = (char)pvVar2;
    }
    if (local_18 != '\0') {
LAB_000f4bca:
      self_00 = cls_NSBundle;
      if (local_18 == '\0') {
        pvVar1 = _objc_msgSend(self,sel_class);
        pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
        pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_None,
                               &cfstr_empty,&cfstr_Dialogs);
        op = sel_setTitle_;
      }
      else {
LAB_000f4c6f:
        pvVar1 = _objc_msgSend(validatePopUp,sel_indexOfItemWithRepresentedObject_,self_01);
        op = sel_selectItemAtIndex_;
      }
      _objc_msgSend(validatePopUp,op,pvVar1);
      return;
    }
  } while( true );
}

*/
- (void)validatePopUp:(id)aUp objectUID:(id)aUID context:(id)aContext
{
    NSEnumerator *enumerator = [aContext objectEnumerator];
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        BOOL matched = NO;
        if (![[self availableTextObjects] containsObject:item]) {
            if ([[self availableCommentItems] containsObject:item]) {
                NSString *comment;
                switch ([[self actionAttributes] sourceDataType]) {
                case 1:
                    comment = @"This Object's Comments";
                    break;
                case 2:
                    comment = @"This Card's Comments";
                    break;
                case 3:
                    comment = @"This Stack's Comments";
                    break;
                case 4:
                    comment = @"All Comments on This Card";
                    break;
                default:
                    continue;
                }
                [aUp selectItemAtIndex:[aUp indexOfItemWithRepresentedObject:comment]];
                return;
            }
        } else {
            matched = [[[item queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:aUID];
        }
        if (matched) {
            [aUp selectItemAtIndex:[aUp indexOfItemWithRepresentedObject:item]];
            return;
        }
    }
    [aUp setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"None" value:@"" table:@"Dialogs"]];
}

- (void)validateUI
{
    char cVar1;
    id pvVar2;
    id pvVar3;
    NSInteger pvVar4;
    NSInteger pvVar6;
    NSUInteger pvVar3_2;
    id pvVar3_4;
    id pvVar3_5;
    id pvVar5_3;

    pvVar2 = [self actionAttributes];
    if (pvVar2 != nil) {
        pvVar3 = [self availableTextObjects];
        pvVar3_2 = [pvVar3 count];
        pvVar4 = [pvVar2 sourceDataType];
        if (pvVar4 != 0 || pvVar3_2 == 0) {
            if ([[_sourceMatrix selectedCell] tag] == 0) {
                [_sourceMatrix selectCellWithTag:1];
                [self sourceActionChanged:nil];
            }
        }
        pvVar5_3 = _destinationMatrix;
        if ((pvVar3 == nil) || ((pvVar6 = [pvVar2 sourceAction], pvVar6 == 0x2 && (pvVar6 = [pvVar2 sourceDataType], pvVar6 == 0)))) {
            cVar1 = NO;
        }
        else {
            cVar1 = YES;
        }
        [pvVar5_3 setEnabled:cVar1];
        [_destinationPopUp setEnabled:[_destinationMatrix isEnabled]];
        [_sourceMatrix selectCellWithTag:[pvVar2 sourceAction]];
        [self setSourceMatrixEnabled:(pvVar4 == 0 && pvVar3_2 != 0)];
        [_destinationMatrix selectCellWithTag:[pvVar2 destinationAction]];
        pvVar3_4 = [self availableSourceObjects];
        [self validatePopUp:_sourcePopUp objectUID:[pvVar2 sourceObjectUID] context:pvVar3_4];
        pvVar3_5 = [self availableDestinationObjects];
        [self validatePopUp:_destinationPopUp objectUID:[pvVar2 destinationObjectUID] context:pvVar3_5];
        return;
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f466b @ 000f466b, 309 bytes * /

void FUN_000f466b(HSMoveTextActionAssistantPane *self,SEL _cmd,id sourceChanged)

{
  id pvVar1;
  cfstringStruct *self_00;
  id pvVar2;
  undefined4 uVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(sourceChanged,sel_selectedItem);
  self_00 = _objc_msgSend(pvVar1,sel_representedObject);
  if (self_00 != (cfstringStruct *)0x0) {
    pvVar1 = _objc_msgSend(self,sel_availableTextObjects);
    pcVar4 = self_00;
    pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,self_00);
    if ((char)pvVar1 == '\0') {
      if (self_00 == &cfstr_This_Object_s_Comments) {
        pvVar1 = (id)0x0;
        uVar3 = 1;
      }
      else if (self_00 == &cfstr_This_Card_s_Comments) {
        pvVar1 = (id)0x0;
        uVar3 = 2;
      }
      else if (self_00 == &cfstr_This_Stack_s_Comments) {
        pvVar1 = (id)0x0;
        uVar3 = 3;
      }
      else if (self_00 == &cfstr_All_Comments_on_This_Card) {
        pvVar1 = (id)0x0;
        uVar3 = 4;
      }
      else {
        pvVar1 = (id)0x0;
        uVar3 = 0;
      }
    }
    else {
      uVar3 = 0;
      pvVar1 = _objc_msgSend(self_00,sel_hyperUID,pcVar4);
    }
    pvVar2 = _objc_msgSend(self,sel_moveTextActionAssistantPaneApplier,pcVar4);
    _objc_msgSend(pvVar2,sel_setSourceDataType_,uVar3);
    pvVar2 = _objc_msgSend(self,sel_moveTextActionAssistantPaneApplier);
    _objc_msgSend(pvVar2,sel_setSourceObjectUID_,pvVar1);
  }
  return;
}

*/
- (void)sourceChanged:(id)aChanged
{
    id represented = [[aChanged selectedItem] representedObject];
    if (represented != nil) {
        id uid = nil;
        int sourceDataType = 0;
        if (![[self availableTextObjects] containsObject:represented]) {
            if ([represented isEqual:@"This Object's Comments"]) {
                sourceDataType = 1;
            } else if ([represented isEqual:@"This Card's Comments"]) {
                sourceDataType = 2;
            } else if ([represented isEqual:@"This Stack's Comments"]) {
                sourceDataType = 3;
            } else if ([represented isEqual:@"All Comments on This Card"]) {
                sourceDataType = 4;
            }
        } else {
            uid = [represented hyperUID];
        }
        [[self moveTextActionAssistantPaneApplier] setSourceDataType:sourceDataType];
        [[self moveTextActionAssistantPaneApplier] setSourceObjectUID:uid];
    }
}

- (void)destinationChanged:(id)aChanged
{
    id pvVar2;
    id pvVar3;

    pvVar2 = [[aChanged selectedItem] representedObject];
    pvVar3 = [self availableDestinationObjects];
    if ([pvVar3 containsObject:pvVar2]) {
        [[self moveTextActionAssistantPaneApplier] setDestinationObjectUID:[pvVar2 hyperUID]];
    }
}

- (void)sourceActionChanged:(id)aChanged
{
    [[self moveTextActionAssistantPaneApplier] setSourceAction:[[_sourceMatrix selectedCell] tag]];
}

- (void)destinationActionChanged:(id)aChanged
{
    [[self moveTextActionAssistantPaneApplier] setDestinationAction:[[_destinationMatrix selectedCell] tag]];
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
/* FUN_000f51ee @ 000f51ee, 953 bytes * /

void FUN_000f51ee(HSMoveTextActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  uint uVar6;
  HSMoveTextActionAssistantPane *self_00;
  SEL op;
  HSMoveTextActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00350960;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  _objc_msgSend(self->_availableTextObjects,sel_release);
  self->_availableTextObjects = (id)0x0;
  if (self->_availableCardIndexes != (CFDictionary *)0x0) {
    _CFRelease(self->_availableCardIndexes);
    self->_availableCardIndexes = (CFDictionary *)0x0;
  }
  _objc_msgSend(self->_availableCommentItems,sel_release);
  self->_availableCommentItems = (id)0x0;
  _objc_msgSend(self->_availableSourceObjects,sel_release);
  self->_availableSourceObjects = (id)0x0;
  pvVar2 = _objc_msgSend(self,sel_availableTextObjects);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  uVar6 = (uint)(pvVar2 != (id)0x0);
  _objc_msgSend(self->_sourcePopUp,sel_setEnabled_,uVar6);
  _objc_msgSend(self->_destinationPopUp,sel_setEnabled_,uVar6);
  _objc_msgSend(self,sel_setSourceMatrixEnabled_,uVar6);
  _objc_msgSend(self->_destinationMatrix,sel_setEnabled_,uVar6);
  puVar1 = cls_NSBundle;
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_sourcePopUp;
    pvVar3 = _objc_msgSend(self,sel_class,uVar6);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_No_Text_Objects_On_Card,&cfstr_empty,&cfstr_Dialogs);
    _objc_msgSend(pvVar2,sel_setTitle_,pvVar3);
    puVar1 = cls_NSBundle;
    self_00 = self->_destinationPopUp;
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pcVar4 = &cfstr_Dialogs;
    pcVar5 = &cfstr_empty;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_No_Text_Objects_On_Card,&cfstr_empty,&cfstr_Dialogs);
    op = sel_setTitle_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_availableSourceObjects,uVar6);
    pvVar3 = _objc_msgSend(self,sel_actionAttributes);
    pvVar3 = _objc_msgSend(pvVar3,sel_sourceObjectUID);
    _objc_msgSend(self,sel_fillInPopUp_objectUID_context_,self->_sourcePopUp,pvVar3,pvVar2);
    pcVar4 = _objc_msgSend(self,sel_availableDestinationObjects);
    pvVar2 = _objc_msgSend(self,sel_actionAttributes);
    pcVar5 = _objc_msgSend(pvVar2,sel_destinationObjectUID);
    pvVar2 = self->_destinationPopUp;
    self_00 = self;
    op = sel_fillInPopUp_objectUID_context_;
  }
  _objc_msgSend(self_00,op,pvVar2,pcVar5,pcVar4);
  pvVar2 = _objc_msgSend(self,sel_applier);
  pvVar2 = _objc_msgSend(pvVar2,sel_actor);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036ea44);
  _objc_msgSend(pvVar2,sel_updateActionValidationStatus);
  _objc_msgSend(self,sel_validateUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [_availableTextObjects release];
    _availableTextObjects = nil;
    if (_availableCardIndexes != NULL) {
        CFRelease(_availableCardIndexes);
        _availableCardIndexes = NULL;
    }
    [_availableCommentItems release];
    _availableCommentItems = nil;
    [_availableSourceObjects release];
    _availableSourceObjects = nil;
    BOOL hasTextObjects = ([[self availableTextObjects] count] != 0);
    [_sourcePopUp setEnabled:hasTextObjects];
    [_destinationPopUp setEnabled:hasTextObjects];
    [self setSourceMatrixEnabled:hasTextObjects];
    [_destinationMatrix setEnabled:hasTextObjects];
    if (!hasTextObjects) {
        NSString *title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No Text Objects On Card" value:@"" table:@"Dialogs"];
        [_sourcePopUp setTitle:title];
        [_destinationPopUp setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"No Text Objects On Card" value:@"" table:@"Dialogs"]];
    } else {
        [self fillInPopUp:_sourcePopUp objectUID:[[self actionAttributes] sourceObjectUID] context:[self availableSourceObjects]];
        [self fillInPopUp:_destinationPopUp objectUID:[[self actionAttributes] destinationObjectUID] context:[self availableDestinationObjects]];
    }
    [[[[self applier] actor] queryHyperInterface:@protocol(HSActionValidation)] updateActionValidationStatus];
    [self validateUI];
}

- (void)setSourceMatrixEnabled:(BOOL)aEnabled
{
    [_sourceMatrix setEnabled:aEnabled];
    [[_sourceMatrix cellAtRow:1 column:1] setEnabled:NO];
}

- (id)actionAttribute
{
    return (id)@protocol(HSMoveTextActionAttributes);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f55a7 @ 000f55a7, 823 bytes * /

void FUN_000f55a7(HSMoveTextActionAssistantPane *self,SEL _cmd,id fillInPopUp,id objectUID,
                 id context)

{
  bool bVar1;
  undefined *puVar2;
  id self_00;
  id self_01;
  undefined *self_02;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  SEL op;
  undefined *puVar6;
  
  _objc_msgSend(fillInPopUp,sel_removeAllItems);
  self_00 = _objc_msgSend(fillInPopUp,sel_menu);
  puVar6 = (undefined *)0x0;
  _objc_msgSend(self_00,sel_setAutoenablesItems_,0);
  self_01 = _objc_msgSend(context,sel_objectEnumerator);
  self_02 = _objc_msgSend(self_01,sel_nextObject);
  if (self_02 != (undefined *)0x0) {
    bVar1 = true;
    do {
      pvVar3 = _objc_msgSend(self,sel_availableCommentItems,puVar6);
      puVar6 = self_02;
      pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,self_02);
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(self,sel_availableTextObjects,puVar6);
        puVar6 = self_02;
        pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,self_02);
        if ((char)pvVar3 != '\0') {
          if (self->_availableCardIndexes != (CFDictionary *)0x0) {
            pvVar3 = (id)_CFDictionaryGetValue(self->_availableCardIndexes,self_02);
            puVar2 = cls_NSString;
            if (pvVar3 != (id)0x0) {
              pvVar3 = _objc_msgSend(pvVar3,sel_unsignedIntegerValue,puVar6);
              pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
              pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Card_title
                                     ,&cfstr_empty,&cfstr_AssistantPanes);
              pvVar3 = _objc_msgSend(puVar2,sel_stringWithFormat_,pvVar4,pvVar3);
              _objc_msgSend(self_00,sel_insertSeparatorWithTitle_,pvVar3);
            }
          }
          puVar6 = &DAT_0036e990;
          pvVar3 = _objc_msgSend(self_02,sel_queryHyperInterface_,&DAT_0036e990);
          op = sel_hyperName;
          goto LAB_000f5817;
        }
        pcVar5 = (cfstringStruct *)0x0;
      }
      else {
        if (bVar1) {
          puVar6 = _objc_msgSend(cls_NSMenuItem,sel_separatorItem,puVar6);
          _objc_msgSend(self_00,sel_addItem_,puVar6);
          bVar1 = false;
        }
        puVar2 = cls_NSBundle;
        pvVar3 = _objc_msgSend(self,sel_class,puVar6);
        pvVar3 = _objc_msgSend(puVar2,sel_bundleForClass_,pvVar3);
        op = sel_localizedStringForKey_value_table_;
        puVar6 = self_02;
LAB_000f5817:
        pcVar5 = _objc_msgSend(pvVar3,op,puVar6);
      }
      if (pcVar5 == (cfstringStruct *)0x0) {
        pcVar5 = &cfstr_empty;
      }
      _objc_msgSend(self_00,sel_addItemWithTitle_action_keyEquivalent_,pcVar5,0,&cfstr_empty);
      pvVar3 = _objc_msgSend(self_00,sel_itemArray);
      pvVar3 = _objc_msgSend(pvVar3,sel_lastObject);
      _objc_msgSend(pvVar3,sel_setRepresentedObject_,self_02);
      puVar6 = self_02;
      self_02 = _objc_msgSend(self_01,sel_nextObject);
    } while (self_02 != (undefined *)0x0);
  }
  _objc_msgSend(self,sel_validatePopUp_objectUID_context_,fillInPopUp,objectUID,context);
  return;
}

*/
- (void)fillInPopUp:(id)aUp objectUID:(id)aUID context:(id)aContext
{
    [aUp removeAllItems];
    NSMenu *menu = [aUp menu];
    [menu setAutoenablesItems:NO];
    NSEnumerator *enumerator = [aContext objectEnumerator];
    id item;
    BOOL separatorPending = YES;
    while ((item = [enumerator nextObject]) != nil) {
        NSString *title;
        if ([[self availableCommentItems] containsObject:item]) {
            if (separatorPending) {
                [menu addItem:[NSMenuItem separatorItem]];
                separatorPending = NO;
            }
            title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:item value:@"" table:@"Dialogs"];
        } else if ([[self availableTextObjects] containsObject:item]) {
            if (_availableCardIndexes != NULL) {
                NSNumber *cardIndex = (NSNumber *)CFDictionaryGetValue(_availableCardIndexes, item);
                if (cardIndex != nil) {
                    NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"Card title" value:@"" table:@"AssistantPanes"];
                    [menu insertSeparatorWithTitle:[NSString stringWithFormat:format, [cardIndex unsignedIntegerValue]]];
                }
            }
            title = [[item queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
        } else {
            title = nil;
        }
        if (title == nil) {
            title = @"";
        }
        [menu addItemWithTitle:title action:NULL keyEquivalent:@""];
        [[[menu itemArray] lastObject] setRepresentedObject:item];
    }
    [self validatePopUp:aUp objectUID:aUID context:aContext];
}

- (id)availableDestinationObjects
{
    return [self availableTextObjects];
}

- (id)availableSourceObjects
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _availableSourceObjects;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSMutableArray alloc] initWithArray:[self availableTextObjects] copyItems:NO];
        _availableSourceObjects = pvVar1_3;
        [pvVar1_3 addObjectsFromArray:[self availableCommentItems]];
        pvVar1 = _availableSourceObjects;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f4244 @ 000f4244, 344 bytes * /

id FUN_000f4244(HSMoveTextActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = self->_availableCommentItems;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    puVar3 = &DAT_0036e878;
    pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036e878);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036e940);
      pvVar1 = _objc_msgSend(cls_NSArray,sel_alloc);
      if ((char)pvVar2 == '\0') {
        pcVar5 = &cfstr_This_Card_s_Comments;
        pcVar4 = &cfstr_This_Object_s_Comments;
      }
      else {
        pcVar5 = &cfstr_This_Stack_s_Comments;
        pcVar4 = &cfstr_This_Card_s_Comments;
      }
    }
    else {
      pvVar1 = _objc_msgSend(cls_NSArray,sel_alloc,puVar3);
      pcVar4 = &cfstr_This_Stack_s_Comments;
      pcVar5 = (cfstringStruct *)0x0;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithObjects_,pcVar4,pcVar5);
    self->_availableCommentItems = pvVar1;
  }
  return pvVar1;
}

*/
- (id)availableCommentItems
{
    if (_availableCommentItems == nil) {
        id object = [[self assistant] object];
        if ([object implementsHyperInterface:@protocol(HSStackAttributes)]) {
            _availableCommentItems = [[NSArray alloc] initWithObjects:@"This Stack's Comments", nil];
        } else if ([object implementsHyperInterface:@protocol(HSCardAttributes)]) {
            _availableCommentItems = [[NSArray alloc] initWithObjects:@"This Card's Comments", @"This Stack's Comments", nil];
        } else {
            _availableCommentItems = [[NSArray alloc] initWithObjects:@"This Object's Comments", @"This Card's Comments", nil];
        }
    }
    return _availableCommentItems;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f58de @ 000f58de, 583 bytes * /

id FUN_000f58de(HSMoveTextActionAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  CFDictionary *pCVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined *puVar7;
  id self_00;
  id local_1c;
  
  pvVar2 = self->_availableTextObjects;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self->_availableTextObjects = pvVar2;
    pCVar3 = (CFDictionary *)
             _CFDictionaryCreateMutable(*(undefined4 *)PTR_003363a4,0,PTR_00336510,PTR_00336514);
    self->_availableCardIndexes = pCVar3;
    pvVar2 = _objc_msgSend(self,sel_assistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036ea6c);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036ea80);
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperCount);
    if (pvVar4 != (id)0x0) {
      local_1c = (id)0x0;
      do {
        pvVar5 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,local_1c);
        puVar7 = &DAT_0036ea80;
        pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_0036ea80);
        local_1c = (id)((int)local_1c + 1);
        bVar1 = true;
        pvVar5 = _objc_msgSend(pvVar5,sel_hyperDeepEnumerator);
        while( true ) {
          self_00 = _objc_msgSend(pvVar5,sel_nextObject,puVar7);
          if (self_00 == (id)0x0) break;
          puVar7 = &DAT_0036eaa8;
          pvVar6 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_0036eaa8);
          if ((char)pvVar6 != '\0') {
            if (bVar1) {
              pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInteger_,local_1c);
              _CFDictionaryAddValue(self->_availableCardIndexes,self_00,pvVar6);
              bVar1 = false;
            }
            pvVar6 = self->_availableTextObjects;
            puVar7 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036e990);
            _objc_msgSend(pvVar6,sel_addObject_,puVar7);
          }
        }
      } while (local_1c < pvVar4);
    }
    pvVar2 = self->_availableTextObjects;
  }
  return pvVar2;
}

*/
- (id)availableTextObjects
{
    if (_availableTextObjects == nil) {
        _availableTextObjects = [NSMutableArray new];
        _availableCardIndexes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        id stack = [[[[[self assistant] object] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] queryHyperInterface:@protocol(HSNodeContainer)];
        NSUInteger count = [stack hyperCount];
        for (NSUInteger index = 0; index < count; index++) {
            id card = [stack hyperChildAtIndex:index];
            BOOL first = YES;
            NSEnumerator *enumerator = [[card queryHyperInterface:@protocol(HSNodeContainer)] hyperDeepEnumerator];
            id object;
            while ((object = [enumerator nextObject]) != nil) {
                if ([object implementsHyperInterface:@protocol(HSStringContentAttributes)]) {
                    if (first) {
                        CFDictionaryAddValue(_availableCardIndexes, object, [NSNumber numberWithUnsignedInteger:index + 1]);
                        first = NO;
                    }
                    [_availableTextObjects addObject:[object queryHyperInterface:@protocol(HSObjectAttributes)]];
                }
            }
        }
    }
    return _availableTextObjects;
    return 0;
}

- (id)actionType
{
    return [HSMoveTextAction actionType];
}

- (id)helpTopicKey
{
    return @"HSTextMover";
}

- (void)dealloc
{
    [_availableTextObjects release];
    if (_availableCardIndexes != nil) {
        CFRelease(_availableCardIndexes);
    }
    [_availableCommentItems release];
    [_availableSourceObjects release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"MoveTextAssistantPane"];
    return self;
}

- (id)actionAttributes
{
    return [[self moveTextActionAssistantPaneApplier] moveTextActionAttributes];
}

- (id)moveTextActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSMoveTextActionAssistantPaneApplier class];
}

- (BOOL)isTextObjectRotationAngleZero:(id)aObject
{
    id geometry = [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] mutableGeometryAttributes];
    float angle = (float)[geometry rotationAngle];
    if (angle >= -0.01 && angle <= 0.01)
        return YES;
    return angle >= 6.2731853 && angle <= 6.2931857;
}

@end

@implementation HSMoveTextActionAssistantPaneApplier

/* i386 ivar offsets: _initialSourceObjectUID=0x30, _initialDestinationObjectUID=0x34, _initialSourceDataType=0x38, _initialSourceAction=0x3c, _initialDestinationAction=0x40, _sourceObjectUID=0x44, _destinationObjectUID=0x48, _sourceDataType=0x4c, _sourceAction=0x50, _destinationAction=0x54 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;

    pvVar1 = [super areSettingsEqual];
    if (pvVar1) {
        if ((_initialSourceObjectUID == nil && _sourceObjectUID == nil) || (pvVar1 = [_initialSourceObjectUID isEqual:_sourceObjectUID], pvVar1)) {
            if (((_initialDestinationObjectUID == nil && _destinationObjectUID == nil) || (pvVar1 = [_initialDestinationObjectUID isEqual:_destinationObjectUID], pvVar1)) && ((_initialSourceDataType == _sourceDataType && (_initialSourceAction == _sourceAction)))) {
                return _initialDestinationAction == _destinationAction;
            }
        }
    }
    return NO;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_sourceObjectUID release];
    [_destinationObjectUID release];
    _sourceObjectUID = [_initialSourceObjectUID retain];
    _destinationObjectUID = [_initialDestinationObjectUID retain];
    _sourceDataType = _initialSourceDataType;
    _sourceAction = _initialSourceAction;
    _destinationAction = _initialDestinationAction;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialSourceObjectUID release];
    [_initialDestinationObjectUID release];
    _initialSourceObjectUID = [_sourceObjectUID retain];
    _initialDestinationObjectUID = [_destinationObjectUID retain];
    _initialSourceDataType = _sourceDataType;
    _initialSourceAction = _sourceAction;
    _initialDestinationAction = _destinationAction;
}

- (void)setInitialSettingsToObject
{
    [[self moveTextActionAttributes] setSourceObjectUID:_initialSourceObjectUID];
    [[self moveTextActionAttributes] setDestinationObjectUID:_initialDestinationObjectUID];
    [[self moveTextActionAttributes] setSourceDataType:_initialSourceDataType];
    [[self moveTextActionAttributes] setSourceAction:_initialSourceAction];
    [[self moveTextActionAttributes] setDestinationAction:_initialDestinationAction];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self moveTextActionAttributes] setSourceObjectUID:_sourceObjectUID];
    [[self moveTextActionAttributes] setDestinationObjectUID:_destinationObjectUID];
    [[self moveTextActionAttributes] setSourceDataType:_sourceDataType];
    [[self moveTextActionAttributes] setSourceAction:_sourceAction];
    [[self moveTextActionAttributes] setDestinationAction:_destinationAction];
}

- (void)setDestinationAction:(NSInteger)aAction
{
    if (_destinationAction != aAction) {
        _destinationAction = aAction;
        [self disableUndo];
        [[self moveTextActionAttributes] setDestinationAction:_destinationAction];
        [self enableUndo];
    }
}

- (void)setSourceAction:(NSInteger)aAction
{
    if (_sourceAction != aAction) {
        _sourceAction = aAction;
        [self disableUndo];
        [[self moveTextActionAttributes] setSourceAction:_sourceAction];
        [self enableUndo];
    }
}

- (void)setSourceDataType:(NSInteger)aType
{
    if (_sourceDataType != aType) {
        _sourceDataType = aType;
        [self disableUndo];
        [[self moveTextActionAttributes] setSourceDataType:_sourceDataType];
        [self enableUndo];
    }
}

- (void)setDestinationObjectUID:(id)aUID
{
    if (![_destinationObjectUID isEqual:aUID]) {
        [_destinationObjectUID release];
        _destinationObjectUID = [aUID retain];
        [self disableUndo];
        [[self moveTextActionAttributes] setDestinationObjectUID:_destinationObjectUID];
        [self enableUndo];
    }
}

- (void)setSourceObjectUID:(id)aUID
{
    if (![_sourceObjectUID isEqual:aUID]) {
        [_sourceObjectUID release];
        _sourceObjectUID = [aUID retain];
        [self disableUndo];
        [[self moveTextActionAttributes] setSourceObjectUID:_sourceObjectUID];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    NSInteger pvVar1_14;
    NSInteger pvVar1_16;
    NSInteger pvVar1_18;

    _sourceObjectUID = [[[self moveTextActionAttributes] sourceObjectUID] retain];
    _destinationObjectUID = [[[self moveTextActionAttributes] destinationObjectUID] retain];
    _initialSourceObjectUID = [[[self moveTextActionAttributes] sourceObjectUID] retain];
    _initialDestinationObjectUID = [[[self moveTextActionAttributes] destinationObjectUID] retain];
    pvVar1_14 = [[self moveTextActionAttributes] sourceDataType];
    _initialSourceDataType = (int)pvVar1_14;
    _sourceDataType = (int)pvVar1_14;
    pvVar1_16 = [[self moveTextActionAttributes] sourceAction];
    _initialSourceAction = (int)pvVar1_16;
    _sourceAction = (int)pvVar1_16;
    pvVar1_18 = [[self moveTextActionAttributes] destinationAction];
    _initialDestinationAction = (int)pvVar1_18;
    _destinationAction = (int)pvVar1_18;
}

- (id)moveTextActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSMoveTextActionAttributes)];
}

- (void)dealloc
{
    [_sourceObjectUID release];
    [_destinationObjectUID release];
    [_initialSourceObjectUID release];
    [_initialDestinationObjectUID release];
    [super dealloc];
}

@end

