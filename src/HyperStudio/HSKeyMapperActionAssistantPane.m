#import "HSKeyMapperActionAssistantPane.h"

@implementation HSKeyMapperActionAssistantPane

/* i386 ivar offsets: _tableView=0x88, _characterMenu=0x8c, _availableObjects=0x90, _buttonBackgroundRenderer=0x94, _shortcutPane=0x98, _keyMappingsByIndex=0x9c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f3323 @ 000f3323, 804 bytes * /

void FUN_000f3323(HSKeyMapperActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  id self_01;
  id pvVar6;
  cfstringStruct *pcVar7;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_keyMappings);
  self_00 = _objc_msgSend(pvVar1,sel_mutableCopy);
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_keyMappings);
  pvVar2 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
  do {
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_actionAttributes);
      pvVar2 = _objc_msgSend(pvVar1,sel_keyMappings);
      pvVar1 = self_00;
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToArray_,self_00);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(self,sel_keyMapperActionAssistantPaneApplier,pvVar1);
        pvVar1 = _objc_msgSend(self_00,sel_copy);
        pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
        _objc_msgSend(pvVar2,sel_setKeyMappings_,pvVar1);
        pvVar2 = _objc_msgSend(self,sel_keyMapperActionAssistantPaneApplier);
        _objc_msgSend(pvVar2,sel_makeInitialEqualToCurrent);
      }
      _objc_msgSend(self_00,sel_release,pvVar1);
      return;
    }
    pcVar7 = &cfstr_HSKeyMapperActionObjectUIDKey;
    pvVar3 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSKeyMapperActionObjectUIDKey);
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_mutableCopy,pcVar7);
      pcVar7 = &cfstr_HSKeyMapperActionObjectTitleKey;
      pcVar4 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSKeyMapperActionObjectTitleKey);
      pvVar5 = _objc_msgSend(self,sel_availableObjects);
      pvVar5 = _objc_msgSend(pvVar5,sel_objectEnumerator);
      do {
        self_01 = _objc_msgSend(pvVar5,sel_nextObject,pcVar7);
        if (self_01 == (id)0x0) goto LAB_000f3554;
        pvVar6 = _objc_msgSend(self_01,sel_hyperName,pcVar7);
        pcVar7 = pcVar4;
        pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_);
      } while ((char)pvVar6 == '\0');
      pvVar5 = _objc_msgSend(self_01,sel_hyperUID,pcVar7);
      pvVar5 = _objc_msgSend(pvVar5,sel_stringValue);
      _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar5,&cfstr_HSKeyMapperActionObjectUIDKey);
      _objc_msgSend(self_00,sel_removeObject_,pvVar1);
      pvVar1 = _objc_msgSend(pvVar3,sel_copy);
      pcVar7 = _objc_msgSend(pvVar1,sel_autorelease);
      _objc_msgSend(self_00,sel_addObject_,pcVar7);
LAB_000f3554:
      _objc_msgSend(pvVar3,sel_release,pcVar7);
    }
    pvVar1 = _objc_msgSend(pvVar2,sel_nextObject,pcVar7);
  } while( true );
}

*/
- (void)checkKeyMappingsForUIDKey
{
    NSMutableArray *mappings = [[[self actionAttributes] keyMappings] mutableCopy];
    NSEnumerator *enumerator = [[[self actionAttributes] keyMappings] objectEnumerator];
    NSDictionary *mapping;
    while ((mapping = [enumerator nextObject]) != nil) {
        if ([mapping objectForKey:@"HSKeyMapperActionObjectUIDKey"] == nil) {
            NSMutableDictionary *fixed = [mapping mutableCopy];
            NSString *title = [mapping objectForKey:@"HSKeyMapperActionObjectTitleKey"];
            NSEnumerator *objects = [[self availableObjects] objectEnumerator];
            id object;
            while ((object = [objects nextObject]) != nil) {
                if ([[object hyperName] isEqualToString:title]) {
                    [fixed setObject:[[object hyperUID] stringValue] forKey:@"HSKeyMapperActionObjectUIDKey"];
                    [mappings removeObject:mapping];
                    [mappings addObject:[[fixed copy] autorelease]];
                    break;
                }
            }
            [fixed release];
        }
    }
    if (![[[self actionAttributes] keyMappings] isEqualToArray:mappings]) {
        [[self keyMapperActionAssistantPaneApplier] setKeyMappings:[[mappings copy] autorelease]];
        [[self keyMapperActionAssistantPaneApplier] makeInitialEqualToCurrent];
    }
    [mappings release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f309b @ 000f309b, 648 bytes * /

void FUN_000f309b(HSKeyMapperActionAssistantPane *self,SEL _cmd,id shortcutPaneDidEnd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id self_01;
  id pvVar5;
  
  puVar1 = cls_NSMutableArray;
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_keyMappings);
  pvVar3 = _objc_msgSend(puVar1,sel_arrayWithArray_,pvVar2);
  self_00 = _objc_msgSend(shortcutPaneDidEnd,sel_resultDictionary);
  if (self_00 != (id)0x0) {
    pvVar4 = _objc_msgSend(self,sel_keyMappingsByIndex,pvVar2);
    pvVar4 = _objc_msgSend(pvVar4,sel_allValues);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectEnumerator);
    do {
      self_01 = _objc_msgSend(pvVar4,sel_nextObject,pvVar2);
      if (self_01 == (id)0x0) goto LAB_000f3234;
      pvVar5 = _objc_msgSend(self_00,sel_objectForKey_,&cfstr_HSKeyMapperActionObjectUIDKey);
      pvVar2 = _objc_msgSend(self_01,sel_objectForKey_,&cfstr_HSKeyMapperActionObjectUIDKey);
      pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,pvVar2);
    } while ((char)pvVar5 == '\0');
    pvVar2 = _objc_msgSend(self,sel_keyMappingsByIndex,pvVar2);
    pvVar4 = _objc_msgSend(self,sel_keyMappingsByIndex);
    pvVar4 = _objc_msgSend(pvVar4,sel_allKeysForObject_,self_01);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,0);
    _objc_msgSend(pvVar2,sel_removeObjectForKey_,pvVar4);
LAB_000f3234:
    puVar1 = cls_HSUID;
    pvVar2 = _objc_msgSend(self_00,sel_objectForKey_,&cfstr_HSKeyMapperActionObjectUIDKey);
    pvVar2 = _objc_msgSend(puVar1,sel_UIDWithString_,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_keyMappingForObjectWithUID_,pvVar2);
    _objc_msgSend(pvVar3,sel_removeObject_,pvVar2);
    _objc_msgSend(pvVar3,sel_addObject_,self_00);
    pvVar2 = _objc_msgSend(self,sel_keyMapperActionAssistantPaneApplier);
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar3);
    _objc_msgSend(pvVar2,sel_setKeyMappings_,pvVar3);
    _objc_msgSend(self->_tableView,sel_reloadData);
  }
  return;
}

*/
- (void)shortcutPaneDidEnd:(id)aEnd
{
    NSMutableArray *mappings = [NSMutableArray arrayWithArray:[[self actionAttributes] keyMappings]];
    NSDictionary *result = [aEnd resultDictionary];
    if (result != nil) {
        NSEnumerator *enumerator = [[[self keyMappingsByIndex] allValues] objectEnumerator];
        id existing;
        while ((existing = [enumerator nextObject]) != nil) {
            if ([[result objectForKey:@"HSKeyMapperActionObjectUIDKey"] isEqualToString:[existing objectForKey:@"HSKeyMapperActionObjectUIDKey"]]) {
                [[self keyMappingsByIndex] removeObjectForKey:[[[self keyMappingsByIndex] allKeysForObject:existing] objectAtIndex:0]];
                break;
            }
        }
        id mapping = [self keyMappingForObjectWithUID:[HSUID UIDWithString:[result objectForKey:@"HSKeyMapperActionObjectUIDKey"]]];
        [mappings removeObject:mapping];
        [mappings addObject:result];
        [[self keyMapperActionAssistantPaneApplier] setKeyMappings:[NSArray arrayWithArray:mappings]];
        [_tableView reloadData];
    }
}

- (void)openShortcutPaneForKeyMapping:(id)aMapping
{
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:YES];
    }
    [[self shortcutPane] setInitialDictionary:aMapping];
    [[self objectAssistantNavigationController] pushViewController:[self shortcutPane] animate:YES];
}

- (id)shortcutPane
{
    HSKeyMapperActionShortcutAssistantPane *pHVar1;
    HSKeyMapperActionShortcutAssistantPane *pHVar1_2;

    pHVar1 = _shortcutPane;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSKeyMapperActionShortcutAssistantPane new];
        _shortcutPane = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _shortcutPane;
    }
    return pHVar1;
}

- (id)keyMappingDictionaryForObject:(id)aObject
{
    return [self keyMappingForObjectWithUID:[aObject hyperUID]];
}

- (id)keyMappingsByIndex
{
    id pvVar1;

    pvVar1 = _keyMappingsByIndex;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _keyMappingsByIndex = pvVar1;
    }
    return pvVar1;
}

- (id)keyMappingForObjectWithUID:(id)aUID
{
    NSString *pvVar1;
    id self_00;
    NSEnumerator *pvVar2_3;
    BOOL pvVar3_2;

    [self checkKeyMappingsForUIDKey];
    pvVar1 = [aUID stringValue];
    pvVar2_3 = [[[self actionAttributes] keyMappings] objectEnumerator];
    do {
        self_00 = [pvVar2_3 nextObject];
        if (self_00 == nil) {
            return nil;
        }
        pvVar3_2 = [[self_00 objectForKey:@"HSKeyMapperActionObjectUIDKey"] isEqualToString:pvVar1];
    } while (!pvVar3_2);
    return self_00;
}

- (id)keyMappingForObjectWithTitle:(id)aTitle
{
    id self_00;
    NSEnumerator *pvVar1_3;
    BOOL pvVar2_2;

    pvVar1_3 = [[[self actionAttributes] keyMappings] objectEnumerator];
    do {
        self_00 = [pvVar1_3 nextObject];
        if (self_00 == nil) {
            return nil;
        }
        pvVar2_2 = [[self_00 objectForKey:@"HSKeyMapperActionObjectTitleKey"] isEqualToString:aTitle];
    } while (!pvVar2_2);
    return self_00;
}

- (BOOL)isShortcutEnabledForObject:(id)aObject
{
    return [self keyMappingDictionaryForObject:aObject] != nil;
}

- (id)availableObjects
{
    id pvVar1;
    id pvVar2;
    id pvVar3;

    pvVar1 = [self stack];
    pvVar2 = _availableObjects;
    if ((pvVar2 == nil) && (pvVar1 != nil)) {
        pvVar2 = [NSMutableArray new];
        _availableObjects = pvVar2;
        pvVar2 = [pvVar1 hyperDeepEnumerator];
        while (pvVar1 = [pvVar2 nextObject], pvVar1 != nil) {
            pvVar3 = [pvVar1 queryHyperInterface:@protocol(HSCardAttributes)];
            if ((pvVar3 == nil) && (pvVar3 = [pvVar1 queryHyperInterface:@protocol(HSStackAttributes)], pvVar3 == nil))
            {
                pvVar3 = _availableObjects;
                pvVar1 = [pvVar1 queryHyperInterface:@protocol(HSObjectAttributes)];
                [pvVar3 addObject:pvVar1];
            }
        }
        pvVar2 = _availableObjects;
    }
    return pvVar2;
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateTableView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f38f1 @ 000f38f1, 552 bytes * /

void FUN_000f38f1(HSKeyMapperActionAssistantPane *self,SEL _cmd,id tableView,id willDisplayCell,
                 id forTableColumn,int row)

{
  undefined *self_00;
  char cVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  uint uVar5;
  double dVar6;
  
  pvVar2 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar4 = &cfstr_KeyMapperShortcutIdentifier;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_KeyMapperShortcutIdentifier);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(willDisplayCell,sel_backgroundRenderer,pcVar4);
    pvVar3 = _objc_msgSend(self,sel_buttonBackgroundRenderer);
    if (pvVar2 != pvVar3) {
      pcVar4 = _objc_msgSend(self,sel_buttonBackgroundRenderer,pcVar4);
      _objc_msgSend(willDisplayCell,sel_setBackgroundRenderer_,pcVar4);
    }
    pvVar2 = _objc_msgSend(self,sel_availableObjects,pcVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
    pvVar2 = _objc_msgSend(self,sel_isShortcutEnabledForObject_,pvVar2);
    cVar1 = (char)pvVar2;
    _objc_msgSend(willDisplayCell,sel_setBordered_,(int)cVar1);
    pvVar2 = _objc_msgSend(self,sel_buttonBackgroundRenderer);
    uVar5 = (uint)(cVar1 == '\0');
    _objc_msgSend(pvVar2,sel_setDrawsEmptyBorder_,uVar5);
    _objc_msgSend(willDisplayCell,sel_setButtonType_,uVar5 * 5);
    _objc_msgSend(willDisplayCell,sel_setAlignment_,(uint)(cVar1 != '\0') * 2);
    self_00 = cls_NSFont;
    dVar6 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
    pvVar2 = _objc_msgSend(self_00,sel_systemFontOfSize_,(float)dVar6);
    _objc_msgSend(willDisplayCell,sel_setFont_,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_tableView_objectValueForTableColumn_row_,tableView,
                           forTableColumn,row);
    _objc_msgSend(willDisplayCell,sel_setTitle_,pvVar2);
    _objc_msgSend(willDisplayCell,sel_setEnabled_,(int)cVar1);
  }
  return;
}

*/
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([[aColumn identifier] isEqual:@"KeyMapperShortcutIdentifier"]) {
        if ([aCell backgroundRenderer] != [self buttonBackgroundRenderer]) {
            [aCell setBackgroundRenderer:[self buttonBackgroundRenderer]];
        }
        BOOL enabled = [self isShortcutEnabledForObject:[[self availableObjects] objectAtIndex:aRow]];
        [aCell setBordered:enabled];
        [[self buttonBackgroundRenderer] setDrawsEmptyBorder:!enabled];
        [aCell setButtonType:enabled ? 0 : NSButtonTypeMomentaryChange];
        [aCell setAlignment:enabled ? NSTextAlignmentCenter : NSTextAlignmentLeft];
        [aCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [aCell setTitle:[self tableView:aView objectValueForTableColumn:aColumn row:aRow]];
        [aCell setEnabled:enabled];
    }
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
/* FUN_000f27fa @ 000f27fa, 964 bytes * /

void FUN_000f27fa(HSKeyMapperActionAssistantPane *self,SEL _cmd,id tableView,id setObjectValue,
                 id forTableColumn,int row)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  HSKeyMapperActionAssistantPane *pHVar6;
  SEL pcVar7;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_keyMappings);
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  pvVar2 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar5 = &cfstr_KeyMapperEnabledIdentifier;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_KeyMapperEnabledIdentifier);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(forTableColumn,sel_identifier,pcVar5);
    pcVar5 = &cfstr_KeyMapperShortcutIdentifier;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_KeyMapperShortcutIdentifier);
    if ((char)pvVar2 == '\0') goto LAB_000f2b50;
    pvVar2 = _objc_msgSend(self,sel_availableObjects,pcVar5);
    pcVar5 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
    pvVar2 = _objc_msgSend(self,sel_isShortcutEnabledForObject_,pcVar5);
    if ((char)pvVar2 == '\0') goto LAB_000f2b50;
    pvVar2 = _objc_msgSend(self,sel_availableObjects,pcVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
    pcVar5 = _objc_msgSend(self,sel_keyMappingDictionaryForObject_,pvVar2);
    pHVar6 = self;
    pcVar7 = sel_openShortcutPaneForKeyMapping_;
  }
  else {
    pvVar2 = _objc_msgSend(setObjectValue,sel_intValue,pcVar5);
    if (pvVar2 == (id)0x1) {
      pvVar2 = _objc_msgSend(self,sel_keyMappingsByIndex,pcVar5);
      pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,row);
      pcVar4 = _objc_msgSend(pvVar2,sel_objectForKey_,pvVar3);
      pHVar6 = self;
      pcVar7 = sel_openShortcutPaneForKeyMapping_;
      if (pcVar4 == (cfstringStruct *)0x0) {
        pvVar2 = _objc_msgSend(self,sel_availableObjects,pvVar3);
        pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
        self_00 = cls_NSDictionary;
        pvVar3 = _objc_msgSend(pvVar2,sel_hyperUID);
        pvVar3 = _objc_msgSend(pvVar3,sel_stringValue);
        pvVar2 = _objc_msgSend(pvVar2,sel_hyperName);
        pcVar4 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar2,
                               &cfstr_HSKeyMapperActionObjectTitleKey,pvVar3,
                               &cfstr_HSKeyMapperActionObjectUIDKey,0);
        pcVar7 = sel_openShortcutPaneForKeyMapping_;
      }
LAB_000f2a61:
      _objc_msgSend(pHVar6,pcVar7,pcVar4);
      pcVar5 = pcVar4;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_availableObjects,pcVar5);
      pcVar5 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
      pcVar4 = _objc_msgSend(self,sel_keyMappingDictionaryForObject_,pcVar5);
      if (pcVar4 != (cfstringStruct *)0x0) {
        _objc_msgSend(pvVar1,sel_removeObject_,pcVar4);
        pHVar6 = _objc_msgSend(self,sel_keyMappingsByIndex);
        _objc_msgSend(cls_NSNumber,sel_numberWithInt_,row);
        pcVar7 = sel_setObject_forKey_;
        goto LAB_000f2a61;
      }
    }
    pHVar6 = self->_tableView;
    pcVar7 = sel_reloadData;
  }
  _objc_msgSend(pHVar6,pcVar7,pcVar5);
LAB_000f2b50:
  pvVar2 = _objc_msgSend(self,sel_keyMapperActionAssistantPaneApplier,pcVar5);
  pvVar3 = _objc_msgSend(pvVar1,sel_copy);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  _objc_msgSend(pvVar2,sel_setKeyMappings_,pvVar3);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSMutableArray *mappings = [[[self actionAttributes] keyMappings] mutableCopy];
    if ([[aColumn identifier] isEqual:@"KeyMapperEnabledIdentifier"]) {
        if ([aValue intValue] == 1) {
            NSDictionary *mapping = [[self keyMappingsByIndex] objectForKey:[NSNumber numberWithInt:(int)aRow]];
            if (mapping == nil) {
                id object = [[self availableObjects] objectAtIndex:aRow];
                mapping = [NSDictionary dictionaryWithObjectsAndKeys:[object hyperName], @"HSKeyMapperActionObjectTitleKey", [[object hyperUID] stringValue], @"HSKeyMapperActionObjectUIDKey", nil];
            }
            [self openShortcutPaneForKeyMapping:mapping];
        } else {
            NSDictionary *mapping = [self keyMappingDictionaryForObject:[[self availableObjects] objectAtIndex:aRow]];
            if (mapping != nil) {
                [mappings removeObject:mapping];
                [[self keyMappingsByIndex] setObject:mapping forKey:[NSNumber numberWithInt:(int)aRow]];
            }
        }
        [_tableView reloadData];
    } else if ([[aColumn identifier] isEqual:@"KeyMapperShortcutIdentifier"]) {
        id object = [[self availableObjects] objectAtIndex:aRow];
        if ([self isShortcutEnabledForObject:object]) {
            [self openShortcutPaneForKeyMapping:[self keyMappingDictionaryForObject:[[self availableObjects] objectAtIndex:aRow]]];
        }
    }
    [[self keyMapperActionAssistantPaneApplier] setKeyMappings:[[mappings copy] autorelease]];
    [mappings release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f2115 @ 000f2115, 1765 bytes * /

id FUN_000f2115(HSKeyMapperActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  cfstringStruct *pcVar3;
  uint uVar4;
  SEL op;
  uint uVar5;
  undefined4 uVar6;
  cfstringStruct *local_18;
  undefined2 local_12;
  
  pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar3 = &cfstr_KeyMapperObjectIdentifier;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_KeyMapperObjectIdentifier);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar3);
    pcVar3 = &cfstr_KeyMapperEnabledIdentifier;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_KeyMapperEnabledIdentifier);
    self_00 = cls_NSNumber;
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar3);
      pcVar3 = &cfstr_KeyMapperShortcutIdentifier;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_KeyMapperShortcutIdentifier);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_availableObjects,pcVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
        pvVar2 = _objc_msgSend(self,sel_keyMappingForObjectWithUID_,pvVar1);
        if (pvVar2 == (id)0x0) {
          pvVar1 = _objc_msgSend(self,sel_keyMappingsByIndex,pvVar1);
          pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,row);
          pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
        }
        if (pvVar2 != (id)0x0) {
          pcVar3 = &cfstr_HSKeyMapperActionCharacterKey;
          local_18 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSKeyMapperActionCharacterKey);
          if ((local_18 == (cfstringStruct *)0x0) ||
             (pvVar1 = _objc_msgSend(local_18,sel_length,pcVar3), pvVar1 == (id)0x0)) {
            pvVar1 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSKeyMapperActionCharacterCodeKey
                                  );
            pvVar1 = _objc_msgSend(pvVar1,sel_unsignedShortValue);
            local_12 = SUB42(pvVar1,0);
            local_18 = _objc_msgSend(cls_NSString,sel_stringWithCharacters_length_,&local_12,1);
          }
          pcVar3 = &cfstr_HSKeyMapperActionUseCommandKeyKey;
          pvVar1 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSKeyMapperActionUseCommandKeyKey);
          pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
          self_00 = cls_NSString;
          if (pvVar1 == (id)0x1) {
            pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar3);
            pcVar3 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                                   &cfstr_KeyWithCommandFormat,&cfstr_empty,&cfstr_AssistantPanes);
            op = sel_stringWithFormat_;
          }
          else {
            pvVar1 = _objc_msgSend(local_18,sel_characterAtIndex_,0);
            uVar4 = (uint)pvVar1 & 0xffff;
            pvVar1 = _objc_msgSend(cls_NSCharacterSet,sel_alphanumericCharacterSet);
            uVar5 = uVar4;
            pvVar1 = _objc_msgSend(pvVar1,sel_characterIsMember_,uVar4);
            if ((char)pvVar1 != '\0') {
              return local_18;
            }
            pvVar1 = _objc_msgSend(cls_NSCharacterSet,sel_symbolCharacterSet,uVar5);
            uVar5 = uVar4;
            pvVar1 = _objc_msgSend(pvVar1,sel_characterIsMember_,uVar4);
            if ((char)pvVar1 != '\0') {
              return local_18;
            }
            pvVar1 = _objc_msgSend(cls_NSCharacterSet,sel_punctuationCharacterSet,uVar5);
            pvVar1 = _objc_msgSend(pvVar1,sel_characterIsMember_,uVar4);
            if ((char)pvVar1 != '\0') {
              return local_18;
            }
            uVar6 = 0x20;
            pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0x20);
            pvVar2 = _objc_msgSend(local_18,sel_isEqualToString_,pvVar1);
            if ((char)pvVar2 == '\0') {
              uVar6 = 0x7f;
              pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0x7f);
              pvVar2 = _objc_msgSend(local_18,sel_isEqualToString_,pvVar1);
              if ((char)pvVar2 == '\0') {
                uVar6 = 0xf739;
                pcVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__C,0xf739);
                pvVar1 = _objc_msgSend(local_18,sel_isEqualToString_,pcVar3);
                if ((char)pvVar1 == '\0') {
                  pvVar1 = _objc_msgSend(self->_characterMenu,sel_itemArray,pcVar3,uVar6);
                  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
                  do {
                    self_00 = _objc_msgSend(pvVar1,sel_nextObject,pcVar3);
                    if (self_00 == (undefined *)0x0) {
                      return (id)0x0;
                    }
                    pvVar2 = _objc_msgSend(self_00,sel_keyEquivalent,pcVar3);
                    pcVar3 = local_18;
                    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_);
                    op = sel_title;
                  } while ((char)pvVar2 == '\0');
                }
                else {
                  self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar3,uVar6);
                  pcVar3 = &cfstr_Clear;
                  op = sel_localizedStringForKey_value_table_;
                }
              }
              else {
                self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar1,uVar6);
                pcVar3 = &cfstr_Delete;
                op = sel_localizedStringForKey_value_table_;
              }
            }
            else {
              self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar1,uVar6);
              pcVar3 = &cfstr_Space;
              op = sel_localizedStringForKey_value_table_;
            }
          }
          goto LAB_000f265c;
        }
      }
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(self,sel_availableObjects,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    pvVar1 = _objc_msgSend(self,sel_isShortcutEnabledForObject_,pvVar1);
    pcVar3 = (cfstringStruct *)(int)(char)pvVar1;
    op = sel_numberWithInt_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,pcVar3);
    pvVar2 = _objc_msgSend(self,sel_availableObjects);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperName);
    self_00 = _objc_msgSend(pvVar1,sel_initWithString_,pvVar2);
    pvVar1 = _objc_msgSend(cls_NSParagraphStyle,sel_defaultParagraphStyle);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperParagraphStyleByChangingLineBreakMode_,4);
    pvVar2 = _objc_msgSend(self_00,sel_length);
    pcVar3 = *(cfstringStruct **)PTR_00336150;
    _objc_msgSend(self_00,sel_addAttribute_value_range_,pcVar3,pvVar1,0,pvVar2);
    op = sel_autorelease;
  }
LAB_000f265c:
  pvVar1 = _objc_msgSend(self_00,op,pcVar3);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([[aColumn identifier] isEqual:@"KeyMapperObjectIdentifier"]) {
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[[[self availableObjects] objectAtIndex:aRow] hyperName]];
        id style = [[NSParagraphStyle defaultParagraphStyle] hyperParagraphStyleByChangingLineBreakMode:NSLineBreakByTruncatingTail];
        [title addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [title length])];
        return [title autorelease];
    }
    if ([[aColumn identifier] isEqual:@"KeyMapperEnabledIdentifier"]) {
        return [NSNumber numberWithInt:(int)[self isShortcutEnabledForObject:[[self availableObjects] objectAtIndex:aRow]]];
    }
    if (![[aColumn identifier] isEqual:@"KeyMapperShortcutIdentifier"]) {
        return nil;
    }
    id uid = [[[self availableObjects] objectAtIndex:aRow] hyperUID];
    NSDictionary *mapping = [self keyMappingForObjectWithUID:uid];
    if (mapping == nil) {
        mapping = [[self keyMappingsByIndex] objectForKey:[NSNumber numberWithInt:(int)aRow]];
    }
    if (mapping == nil) {
        return nil;
    }
    NSString *character = [mapping objectForKey:@"HSKeyMapperActionCharacterKey"];
    if (character == nil || [character length] == 0) {
        unichar code = [[mapping objectForKey:@"HSKeyMapperActionCharacterCodeKey"] unsignedShortValue];
        character = [NSString stringWithCharacters:&code length:1];
    }
    if ([[mapping objectForKey:@"HSKeyMapperActionUseCommandKeyKey"] intValue] == 1) {
        NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"KeyWithCommandFormat" value:@"" table:@"AssistantPanes"];
        return [NSString stringWithFormat:format, character];
    }
    unichar ch = [character characterAtIndex:0];
    if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:ch]) {
        return character;
    }
    if ([[NSCharacterSet symbolCharacterSet] characterIsMember:ch]) {
        return character;
    }
    if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:ch]) {
        return character;
    }
    if ([character isEqualToString:[NSString stringWithFormat:@"%C", (unichar)0x20]]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Space" value:@"" table:@"AssistantPanes"];
    }
    if ([character isEqualToString:[NSString stringWithFormat:@"%C", (unichar)0x7f]]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Delete" value:@"" table:@"AssistantPanes"];
    }
    if ([character isEqualToString:[NSString stringWithFormat:@"%C", (unichar)0xf739]]) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Clear" value:@"" table:@"AssistantPanes"];
    }
    NSEnumerator *enumerator = [[_characterMenu itemArray] objectEnumerator];
    NSMenuItem *item;
    while ((item = [enumerator nextObject]) != nil) {
        if ([[item keyEquivalent] isEqualToString:character]) {
            return [item title];
        }
    }
    return nil;
    return 0;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self availableObjects] count];
}

- (id)initialKeyView
{
    return _tableView;
}

- (id)helpTopicKey
{
    return @"HSKeyMapper";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    if ([_tableView dataSource] == self) {
        [_tableView setDataSource:0];
    }
    [_availableObjects release];
    _availableObjects = nil;
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_tableView setDataSource:self];
    [self validateTableView];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSKeyMapperActionAttributes);
}

- (void)validateTableView
{
    [_tableView reloadData];
}

- (id)actionType
{
    return [HSKeyMapperAction actionType];
}

- (id)actionAttributes
{
    return [[self keyMapperActionAssistantPaneApplier] keyMapperActionAttributes];
}

- (id)keyMapperActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSKeyMapperActionAssistantPaneApplier class];
}

- (void)awakeFromNib
{
    [_tableView setFocusRingType:1];
}

- (void)dealloc
{
    [_availableObjects release];
    [_buttonBackgroundRenderer release];
    [_shortcutPane release];
    [_keyMappingsByIndex release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"KeyMapperAssistantPane"];
    return self;
}

@end

@implementation HSKeyMapperActionAssistantPaneApplier

/* i386 ivar offsets: _initialKeyMappings=0x30, _keyMappings=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    char cVar2;

    pvVar1 = [super areSettingsEqual];
    cVar2 = pvVar1;
    if ((_initialKeyMappings != nil) || (_keyMappings != nil)) {
        if (cVar2 == NO) {
            cVar2 = NO;
        }
        else {
            pvVar1 = [_initialKeyMappings isEqualToArray:_keyMappings];
            cVar2 = pvVar1;
        }
    }
    return cVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_keyMappings release];
    _keyMappings = [_initialKeyMappings retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialKeyMappings release];
    _initialKeyMappings = [_keyMappings retain];
}

- (void)setInitialSettingsToObject
{
    [[self keyMapperActionAttributes] setKeyMappings:_initialKeyMappings];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self keyMapperActionAttributes] setKeyMappings:_keyMappings];
}

- (void)setKeyMappings:(id)aMappings
{
    if (_keyMappings != aMappings) {
        [_keyMappings release];
        _keyMappings = [aMappings retain];
        [self disableUndo];
        [[self keyMapperActionAttributes] setKeyMappings:_keyMappings];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _initialKeyMappings = [[[self keyMapperActionAttributes] keyMappings] retain];
    _keyMappings = [[[self keyMapperActionAttributes] keyMappings] retain];
}

- (id)keyMapperActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSKeyMapperActionAttributes)];
}

- (void)dealloc
{
    [_initialKeyMappings release];
    [_keyMappings release];
    [super dealloc];
}

@end

