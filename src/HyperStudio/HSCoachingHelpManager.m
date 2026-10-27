#import "HSCoachingHelpManager.h"

static id sharedCoachingHelpManagerInstance = nil;

@implementation HSCoachingHelpManager

/* i386 ivar offsets: _stacks=0x4, _lastAddedChildren=0x8, _ignoredChildren=0xc, _objectToAdditionalCoachingPanesMap=0x10, _objectToDropHelpPanesMap=0x14, _ignoreAddedObject=0x18 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021f7fc @ 0021f7fc, 224 bytes * /

id FUN_0021f7fc(id self,SEL _cmd,NSZone *allocWithZone)

{
  bool bVar1;
  int iVar2;
  id unaff_EBX;
  id local_7c;
  undefined *local_78;
  int local_74 [23];
  NSZone *local_18;
  id local_14;
  
  local_14 = self;
  local_18 = allocWithZone;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  if (iVar2 == 0) {
    if (DAT_00342a18 == (id)0x0) {
      local_7c = local_14;
      local_78 = PTR_s_NSObject_0035df80;
      unaff_EBX = _objc_msgSendSuper(&local_7c,sel_allocWithZone_,local_18);
      iVar2 = 0;
      bVar1 = false;
      DAT_00342a18 = unaff_EBX;
    }
    else {
      bVar1 = true;
      iVar2 = 0;
      unaff_EBX = (id)0x0;
    }
  }
  else {
    iVar2 = _objc_exception_extract(local_74);
    if (iVar2 != 0) {
      bVar1 = true;
      goto LAB_0021f8b1;
    }
    bVar1 = true;
    unaff_EBX = (id)0x0;
  }
  _objc_exception_try_exit(local_74);
LAB_0021f8b1:
  _objc_sync_exit(self);
  if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar2);
  }
  if (bVar1) {
    unaff_EBX = (id)0x0;
  }
  return unaff_EBX;
}

*/
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sharedCoachingHelpManagerInstance == nil) {
            sharedCoachingHelpManagerInstance = [super allocWithZone:aZone];
            return sharedCoachingHelpManagerInstance;
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021f8dc @ 0021f8dc, 175 bytes * /

id FUN_0021f8dc(id self,SEL _cmd)

{
  int iVar1;
  id self_00;
  int local_6c [22];
  id local_14;
  
  local_14 = self;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    if (DAT_00342a18 == (id)0x0) {
      self_00 = _objc_msgSend(local_14,sel_alloc);
      _objc_msgSend(self_00,sel_init);
    }
    iVar1 = 0;
  }
  else {
    iVar1 = _objc_exception_extract(local_6c);
    if (iVar1 != 0) goto LAB_0021f964;
  }
  _objc_exception_try_exit(local_6c);
LAB_0021f964:
  _objc_sync_exit(self);
  if (iVar1 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar1);
  }
  return DAT_00342a18;
}

*/
+ (id)sharedCoachingHelpManager
{
    @synchronized (self) {
        if (sharedCoachingHelpManagerInstance == nil) {
            [[self alloc] init];
        }
    }
    return sharedCoachingHelpManagerInstance;
}

- (void)enableObjectRegistration
{
    _ignoreAddedObject = NO;
}

- (void)disableObjectRegistration
{
    _ignoreAddedObject = YES;
}

- (BOOL)isObjectRegistrationEnabled
{
    return _ignoreAddedObject == NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021f98b @ 0021f98b, 169 bytes * /

void FUN_0021f98b(HSCoachingHelpManager *self,SEL _cmd,id cleanAllDropHelpPanesForStack)

{
  char cVar1;
  id pvVar2;
  id local_20;
  undefined1 local_1c [12];
  
  if (self->_objectToDropHelpPanesMap != (id)0x0) {
    _NSEnumerateMapTable(local_1c,self->_objectToDropHelpPanesMap);
    local_20 = (id)0x0;
    cVar1 = _NSNextMapEnumeratorPair(local_1c,&local_20,0);
    while (cVar1 != '\0') {
      pvVar2 = _objc_msgSend(local_20,sel_rootNode);
      if (pvVar2 == cleanAllDropHelpPanesForStack) {
        _NSMapRemove(self->_objectToDropHelpPanesMap,local_20);
      }
      cVar1 = _NSNextMapEnumeratorPair(local_1c,&local_20,0);
    }
  }
  return;
}

*/
- (void)cleanAllDropHelpPanesForStack:(id)aStack
{
    if (_objectToDropHelpPanesMap != nil) {
        NSMutableArray *keysToRemove = [NSMutableArray array];
        NSMapEnumerator enumerator = NSEnumerateMapTable(_objectToDropHelpPanesMap);
        id key = nil;
        while (NSNextMapEnumeratorPair(&enumerator, (void **)&key, NULL)) {
            if ([key rootNode] == aStack) {
                [keysToRemove addObject:key];
            }
        }
        NSEndMapTableEnumeration(&enumerator);
        for (id removedKey in keysToRemove) {
            NSMapRemove(_objectToDropHelpPanesMap, removedKey);
        }
    }
}

- (void)removeDropHelpPaneForObject:(id)aObject
{
    if (_objectToDropHelpPanesMap != nil) {
        if ((NSMapMember(_objectToDropHelpPanesMap,aObject,0,0)) != NO) {
            NSMapRemove(_objectToDropHelpPanesMap,aObject);
        }
    }
}

- (void)addDropHelpPane:(id)aPane forObject:(id)aObject
{
    NSMapInsert([self HSCoachingHelpManager_objectToDropHelpPanesMap],aObject,aPane);
}

- (id)dropHelpPaneForObject:(id)aObject
{
    id pvVar1;

    if (_objectToDropHelpPanesMap == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = NSMapGet(_objectToDropHelpPanesMap,aObject);
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021fae3 @ 0021fae3, 108 bytes * /

id FUN_0021fae3(HSCoachingHelpManager *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_objectToDropHelpPanesMap;
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)_NSCreateMapTable(*(undefined8 *)PTR_00336570,*(undefined8 *)(PTR_00336570 + 8),
                                   *(undefined8 *)(PTR_00336570 + 0x10),*(undefined4 *)PTR_0033639c,
                                   *(undefined4 *)(PTR_0033639c + 4),
                                   *(undefined4 *)(PTR_0033639c + 8),0);
    self->_objectToDropHelpPanesMap = pvVar1;
  }
  return pvVar1;
}

*/
- (id)HSCoachingHelpManager_objectToDropHelpPanesMap
{
    if (_objectToDropHelpPanesMap == nil) {
        _objectToDropHelpPanesMap = NSCreateMapTable(NSNonRetainedObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    }
    return (id)_objectToDropHelpPanesMap;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021fb4f @ 0021fb4f, 169 bytes * /

void FUN_0021fb4f(HSCoachingHelpManager *self,SEL _cmd,id cleanAllAdditionalCoachingPanesForStack)

{
  char cVar1;
  id pvVar2;
  id local_20;
  undefined1 local_1c [12];
  
  if (self->_objectToAdditionalCoachingPanesMap != (id)0x0) {
    _NSEnumerateMapTable(local_1c,self->_objectToAdditionalCoachingPanesMap);
    local_20 = (id)0x0;
    cVar1 = _NSNextMapEnumeratorPair(local_1c,&local_20,0);
    while (cVar1 != '\0') {
      pvVar2 = _objc_msgSend(local_20,sel_rootNode);
      if (pvVar2 == cleanAllAdditionalCoachingPanesForStack) {
        _NSMapRemove(self->_objectToAdditionalCoachingPanesMap,local_20);
      }
      cVar1 = _NSNextMapEnumeratorPair(local_1c,&local_20,0);
    }
  }
  return;
}

*/
- (void)cleanAllAdditionalCoachingPanesForStack:(id)aStack
{
    if (_objectToAdditionalCoachingPanesMap != nil) {
        NSMutableArray *keysToRemove = [NSMutableArray array];
        NSMapEnumerator enumerator = NSEnumerateMapTable(_objectToAdditionalCoachingPanesMap);
        id key = nil;
        while (NSNextMapEnumeratorPair(&enumerator, (void **)&key, NULL)) {
            if ([key rootNode] == aStack) {
                [keysToRemove addObject:key];
            }
        }
        NSEndMapTableEnumeration(&enumerator);
        for (id removedKey in keysToRemove) {
            NSMapRemove(_objectToAdditionalCoachingPanesMap, removedKey);
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021fbf8 @ 0021fbf8, 180 bytes * /

void FUN_0021fbf8(HSCoachingHelpManager *self,SEL _cmd,id pushAdditionalCoachingPane,id forObject)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_HSCoachingHelpManager_objectToAdditionalCoachingPanesMap);
  pvVar2 = (id)_NSMapGet(pvVar1,forObject);
  op = sel_addObject_;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithObjects_,pushAdditionalCoachingPane,0);
    pushAdditionalCoachingPane = pvVar2;
    _NSMapInsert(pvVar1,forObject,pvVar2);
    op = sel_release;
  }
  _objc_msgSend(pvVar2,op,pushAdditionalCoachingPane);
  return;
}

*/
- (void)pushAdditionalCoachingPane:(id)aPane forObject:(id)aObject
{
    NSMapTable *map = (NSMapTable *)[self HSCoachingHelpManager_objectToAdditionalCoachingPanesMap];
    NSMutableArray *panes = NSMapGet(map, aObject);
    if (panes == nil) {
        panes = [[NSMutableArray alloc] initWithObjects:aPane, nil];
        NSMapInsert(map, aObject, panes);
        [panes release];
    }
    else {
        [panes addObject:aPane];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021fcac @ 0021fcac, 108 bytes * /

id FUN_0021fcac(HSCoachingHelpManager *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_objectToAdditionalCoachingPanesMap;
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)_NSCreateMapTable(*(undefined8 *)PTR_00336570,*(undefined8 *)(PTR_00336570 + 8),
                                   *(undefined8 *)(PTR_00336570 + 0x10),*(undefined4 *)PTR_0033639c,
                                   *(undefined4 *)(PTR_0033639c + 4),
                                   *(undefined4 *)(PTR_0033639c + 8),0);
    self->_objectToAdditionalCoachingPanesMap = pvVar1;
  }
  return pvVar1;
}

*/
- (id)HSCoachingHelpManager_objectToAdditionalCoachingPanesMap
{
    if (_objectToAdditionalCoachingPanesMap == nil) {
        _objectToAdditionalCoachingPanesMap = NSCreateMapTable(NSNonRetainedObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    }
    return (id)_objectToAdditionalCoachingPanesMap;
}

- (id)coachingPanesForObject:(id)aObject inStack:(id)aStack
{
    return [self coachingPanesForObject:aObject inStack:aStack remove:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021fd18 @ 0021fd18, 1184 bytes * /

id FUN_0021fd18(HSCoachingHelpManager *self,SEL _cmd,id coachingPanesForObject,id inStack,
               BOOL remove)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  id pvVar5;
  cfstringStruct *self_02;
  cfstringStruct *pcVar6;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_new);
  pvVar1 = _objc_msgSend(cls_HSCoachingInfoProvider,sel_sharedProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_coachingKeyForObject_,coachingPanesForObject);
  pvVar2 = _objc_msgSend(self,sel_dontShowCoachingHintsForKey_,pvVar1);
  pvVar3 = _objc_msgSend(self,sel_HSCoachingHelpManager_objectToAdditionalCoachingPanesMap);
  pvVar4 = (id)_NSMapGet(pvVar3,coachingPanesForObject);
  if (pvVar4 != (id)0x0) {
    self_01 = _objc_msgSend(pvVar4,sel_objectEnumerator,pvVar1);
    pvVar4 = _objc_msgSend(self_01,sel_nextObject);
    while (pvVar4 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar4,sel_coachingKey,pvVar1);
      pvVar5 = _objc_msgSend(self,sel_dontShowCoachingHintsForKey_);
      if (((char)pvVar5 == '\0') ||
         (pvVar5 = _objc_msgSend(pvVar4,sel_ignoresPreferences,pvVar1), (char)pvVar5 != '\0')) {
        _objc_msgSend(pvVar4,sel_setObject_,coachingPanesForObject);
        _objc_msgSend(self_00,sel_addObject_,pvVar4);
        pvVar1 = pvVar4;
      }
      pvVar4 = _objc_msgSend(self_01,sel_nextObject,pvVar1);
    }
    if (remove != '\0') {
      _NSMapRemove(pvVar3,coachingPanesForObject);
    }
  }
  pvVar1 = _objc_msgSend(self,sel_lastAddedChildrenForStack_,inStack);
  self_02 = coachingPanesForObject;
  pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,coachingPanesForObject);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_HSCoachingInfoProvider,sel_sharedProvider,self_02);
    self_02 = coachingPanesForObject;
    pvVar1 = _objc_msgSend(pvVar1,sel_coachingInfoForObject_,coachingPanesForObject);
    if (pvVar1 != (id)0x0) {
      self_02 = &cfstr_objectIndex;
      pvVar3 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_objectIndex);
      if (pvVar3 != (id)0x0) {
        self_02 = (cfstringStruct *)&DAT_003833cc;
        pvVar4 = _objc_msgSend(coachingPanesForObject,sel_queryHyperInterface_,&DAT_003833cc);
        if (pvVar4 != (id)0x0) {
          pvVar4 = _objc_msgSend(pvVar4,sel_hyperIndex,self_02);
          pvVar3 = _objc_msgSend(pvVar3,sel_intValue);
          if (pvVar4 != pvVar3) goto LAB_0022010f;
        }
      }
      pvVar3 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,self_02);
      pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_informativeTextFilename);
      pvVar1 = _objc_msgSend(pvVar4,sel_pathForResource_ofType_inDirectory_,pvVar1,&cfstr_rtf,
                             &cfstr_Coaching);
      pvVar1 = _objc_msgSend(pvVar3,sel_initWithPath_documentAttributes_,pvVar1,0);
      self_02 = _objc_msgSend(pvVar1,sel_autorelease);
      pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
      pvVar1 = _objc_msgSend(pvVar1,sel_coachingHintDefaultButton);
      _objc_msgSend(self_02,sel_replaceOccurencesOfString_withString_,
                    *(undefined4 *)PTR_PTR_003366fc,pvVar1);
      pvVar3 = _objc_msgSend(cls_HSHelpAssistantPane,sel_alloc);
      pvVar3 = _objc_msgSend(pvVar3,sel_initWithInformativeText_,self_02);
      pcVar6 = _objc_msgSend(pvVar3,sel_autorelease);
      if (((char)pvVar2 == '\0') ||
         (pvVar1 = _objc_msgSend(pcVar6,sel_ignoresPreferences,self_02,pvVar1), (char)pvVar1 != '\0'
         )) {
        _objc_msgSend(pcVar6,sel_setObject_,coachingPanesForObject);
        _objc_msgSend(self_00,sel_addObject_,pcVar6);
        self_02 = pcVar6;
      }
    }
  }
LAB_0022010f:
  pvVar1 = _objc_msgSend(self,sel_HSCoachingHelpManager_objectToDropHelpPanesMap,self_02);
  if ((pvVar1 != (id)0x0) &&
     (((pcVar6 = (cfstringStruct *)_NSMapGet(pvVar1,coachingPanesForObject),
       pcVar6 != (cfstringStruct *)0x0 ||
       (pvVar1 = _objc_msgSend((id)0x0,sel_ignoresPreferences,self_02), (char)pvVar1 != '\0')) &&
      (pvVar1 = _objc_msgSend(pcVar6,sel_objectAssistantNavigationController), pvVar1 == (id)0x0))))
  {
    _objc_msgSend(pcVar6,sel_setObject_,coachingPanesForObject);
    _objc_msgSend(self_00,sel_addObject_,pcVar6);
    self_02 = pcVar6;
  }
  pvVar1 = _objc_msgSend(self_00,sel_autorelease,self_02);
  return pvVar1;
}

*/
- (id)coachingPanesForObject:(id)aObject inStack:(id)aStack remove:(BOOL)aRemove
{
    NSMutableArray *result = [NSMutableArray new];
    id key = [[HSCoachingInfoProvider sharedProvider] coachingKeyForObject:aObject];
    BOOL dontShow = [self dontShowCoachingHintsForKey:key];
    NSMapTable *additionalMap = (NSMapTable *)[self HSCoachingHelpManager_objectToAdditionalCoachingPanesMap];
    NSArray *additional = NSMapGet(additionalMap, aObject);
    if (additional != nil) {
        NSEnumerator *enumerator = [additional objectEnumerator];
        id pane;
        while ((pane = [enumerator nextObject]) != nil) {
            if (![self dontShowCoachingHintsForKey:[pane coachingKey]] || [pane ignoresPreferences]) {
                [pane setObject:aObject];
                [result addObject:pane];
            }
        }
        if (aRemove) {
            NSMapRemove(additionalMap, aObject);
        }
    }
    if ([[self lastAddedChildrenForStack:aStack] containsObject:aObject]) {
        NSDictionary *info = [[HSCoachingInfoProvider sharedProvider] coachingInfoForObject:aObject];
        if (info != nil) {
            BOOL skip = NO;
            id objectIndex = [info objectForKey:@"objectIndex"];
            if (objectIndex != nil) {
                id child = [aObject queryHyperInterface:@protocol(HSNodeChild)];
                if (child != nil && [child hyperIndex] != (NSUInteger)[objectIndex intValue]) {
                    skip = YES;
                }
            }
            if (!skip) {
                NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:[info objectForKey:@"informativeTextFilename"] ofType:@"rtf" inDirectory:@"Coaching"] documentAttributes:NULL] autorelease];
                [text replaceOccurencesOfString:@"<defaultButtonName>" withString:[[HSObjectAssistantController sharedAssistantController] coachingHintDefaultButton]];
                HSHelpAssistantPane *pane = [[[HSHelpAssistantPane alloc] initWithInformativeText:text] autorelease];
                if (!dontShow || [pane ignoresPreferences]) {
                    [pane setObject:aObject];
                    [result addObject:pane];
                }
            }
        }
    }
    NSMapTable *dropMap = (NSMapTable *)[self HSCoachingHelpManager_objectToDropHelpPanesMap];
    if (dropMap != nil) {
        id dropPane = NSMapGet(dropMap, aObject);
        if (dropPane != nil && [dropPane objectAssistantNavigationController] == nil) {
            [dropPane setObject:aObject];
            [result addObject:dropPane];
        }
    }
    return [result autorelease];
}

- (void)removeAllObjectsForStack:(id)aStack
{
    [_lastAddedChildren removeObjectForKey:[aStack hyperUID]];
}

- (void)removeObject:(id)aObject forStack:(id)aStack
{
    [[self lastAddedChildrenForStack:aStack] removeObject:aObject];
}

- (void)removeObject:(id)aObject
{
    [self removeObject:aObject forStack:[aObject rootNode]];
}

- (void)addObject:(id)aObject forStack:(id)aStack
{
    if (_ignoreAddedObject == NO) {
        [[self lastAddedChildrenForStack:aStack] addObject:aObject];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021f1c4 @ 0021f1c4, 820 bytes * /

void FUN_0021f1c4(HSCoachingHelpManager *self,SEL _cmd,id containerAttributeDidChange)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  id pvVar6;
  undefined *puVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  undefined *puVar10;
  undefined *puVar11;
  
  pvVar2 = _objc_msgSend(containerAttributeDidChange,sel_userInfo);
  pcVar8 = &cfstr_HSNodeChildrenForAddition;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
  pvVar2 = _objc_msgSend(pvVar2,sel_allObjects);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  pvVar3 = _objc_msgSend(containerAttributeDidChange,sel_object);
  pvVar3 = _objc_msgSend(pvVar3,sel_rootNode);
  pcVar4 = _objc_msgSend(pvVar2,sel_nextObject);
  do {
    pcVar9 = pcVar4;
    if (pcVar9 == (cfstringStruct *)0x0) {
      pvVar2 = _objc_msgSend(containerAttributeDidChange,sel_userInfo,pcVar8);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
      pvVar2 = _objc_msgSend(pvVar2,sel_allObjects);
      pvVar5 = _objc_msgSend(pvVar2,sel_objectEnumerator);
      pvVar2 = _objc_msgSend(pvVar5,sel_nextObject);
      while (pvVar2 != (id)0x0) {
        if (self->_ignoreAddedObject != '\0') {
          pvVar6 = _objc_msgSend(self,sel_ignoredChildrenForStack_,pvVar3);
          _objc_msgSend(pvVar6,sel_addObject_,pvVar2);
        }
        puVar10 = &DAT_0038337c;
        pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0038337c);
        pvVar2 = _objc_msgSend(pvVar2,sel_hyperDeepEnumerator);
        puVar7 = _objc_msgSend(pvVar2,sel_nextObject);
        while (puVar11 = puVar7, puVar11 != (undefined *)0x0) {
          _objc_msgSend(self,sel_removeDropHelpPaneForObject_,puVar11);
          pvVar6 = _objc_msgSend(self,sel_lastAddedChildrenForStack_,pvVar3);
          _objc_msgSend(pvVar6,sel_removeObject_,puVar11);
          puVar7 = _objc_msgSend(pvVar2,sel_nextObject);
          puVar10 = puVar11;
        }
        pvVar2 = _objc_msgSend(pvVar5,sel_nextObject,puVar10);
      }
      return;
    }
    pvVar5 = _objc_msgSend(self,sel_ignoredChildrenForStack_,pvVar3);
    pcVar8 = pcVar9;
    pvVar5 = _objc_msgSend(pvVar5,sel_containsObject_,pcVar9);
    if ((char)pvVar5 == '\0') {
      pvVar5 = _objc_msgSend(pvVar3,sel_document,pcVar8);
      pvVar5 = _objc_msgSend(pvVar5,sel_currentWindowController);
      pvVar5 = _objc_msgSend(pvVar5,sel_needsHelpCoachingHintForObject_,pcVar9);
      if ((char)pvVar5 != '\0') goto LAB_0021f2a6;
      bVar1 = false;
    }
    else {
LAB_0021f2a6:
      bVar1 = true;
    }
    if (!bVar1 && self->_ignoreAddedObject == '\0') {
      pvVar5 = _objc_msgSend(self,sel_lastAddedChildrenForStack_,pvVar3);
      _objc_msgSend(pvVar5,sel_addObject_,pcVar9);
    }
    pvVar5 = _objc_msgSend(self,sel_ignoredChildrenForStack_,pvVar3);
    _objc_msgSend(pvVar5,sel_removeObject_,pcVar9);
    pcVar4 = _objc_msgSend(pvVar2,sel_nextObject);
    pcVar8 = pcVar9;
  } while( true );
}

*/
- (void)containerAttributeDidChange:(id)aChange
{
    NSEnumerator *added = [[[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] allObjects] objectEnumerator];
    id root = [[aChange object] rootNode];
    id child;
    while ((child = [added nextObject]) != nil) {
        BOOL handled;
        if (![[self ignoredChildrenForStack:root] containsObject:child]) {
            HSMainWindowController *windowController = [[root document] currentWindowController];
            handled = [windowController needsHelpCoachingHintForObject:child];
        }
        else {
            handled = YES;
        }
        if (!handled && !_ignoreAddedObject) {
            [[self lastAddedChildrenForStack:root] addObject:child];
        }
        [[self ignoredChildrenForStack:root] removeObject:child];
    }
    NSEnumerator *removed = [[[[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"] allObjects] objectEnumerator];
    id object;
    while ((object = [removed nextObject]) != nil) {
        if (_ignoreAddedObject) {
            [[self ignoredChildrenForStack:root] addObject:object];
        }
        NSEnumerator *deep = [[object queryHyperInterface:@protocol(HSNodeContainer)] hyperDeepEnumerator];
        id descendant;
        while ((descendant = [deep nextObject]) != nil) {
            [self removeDropHelpPaneForObject:descendant];
            [[self lastAddedChildrenForStack:root] removeObject:descendant];
        }
    }
}

- (void)removeStack:(id)aStack
{
    if ([_stacks containsObject:aStack]) {
        [aStack removeObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [aStack removeObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [_lastAddedChildren removeObjectForKey:[aStack hyperUID]];
        [_ignoredChildren removeObjectForKey:[aStack hyperUID]];
        [self cleanAllAdditionalCoachingPanesForStack:aStack];
        [self cleanAllDropHelpPanesForStack:aStack];
        [_stacks removeObject:aStack];
    }
}

- (void)addStack:(id)aStack
{
    id pvVar1;

    pvVar1 = _stacks;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _stacks = pvVar1;
    }
    if (![pvVar1 containsObject:aStack]) {
        [_stacks addObject:aStack];
        [aStack addObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
        [aStack addObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    }
}

- (id)ignoredChildrenForStack:(id)aStack
{
    id pvVar1;
    id self_00;

    if (aStack == nil) {
        pvVar1 = nil;
    }
    else {
        self_00 = [self ignoredChildrenDict];
        pvVar1 = [self_00 objectForKey:[aStack hyperUID]];
        if (pvVar1 == nil) {
            pvVar1 = [NSMutableArray array];
            [self_00 setObject:pvVar1 forKey:[aStack hyperUID]];
        }
    }
    return pvVar1;
}

- (id)ignoredChildrenDict
{
    id pvVar1;

    pvVar1 = _ignoredChildren;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _ignoredChildren = pvVar1;
    }
    return pvVar1;
}

- (id)lastAddedChildrenForStack:(id)aStack
{
    id pvVar1;
    id self_00;

    if (aStack == nil) {
        pvVar1 = nil;
    }
    else {
        self_00 = [self lastAddedChildrenDict];
        pvVar1 = [self_00 objectForKey:[aStack hyperUID]];
        if (pvVar1 == nil) {
            pvVar1 = [NSMutableArray array];
            [self_00 setObject:pvVar1 forKey:[aStack hyperUID]];
        }
    }
    return pvVar1;
}

- (id)lastAddedChildrenDict
{
    id pvVar1;

    pvVar1 = _lastAddedChildren;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _lastAddedChildren = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021ec51 @ 0021ec51, 352 bytes * /

void FUN_0021ec51(HSCoachingHelpManager *self,SEL _cmd,BOOL setDontShowCoachingHints,id forKey)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_DontShowCoachingHintsFor__Key,
                         forKey);
  self_00 = cls_NSMutableDictionary;
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,
                         &cfstr_HSObjectAssistantControlsDictionaryDontShowCoach);
  self_01 = _objc_msgSend(self_00,sel_dictionaryWithDictionary_,pvVar2);
  op = sel_removeObjectForKey_;
  pvVar2 = pvVar1;
  if (setDontShowCoachingHints != '\0') {
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(byte)setDontShowCoachingHints,
                           forKey);
    op = sel_setObject_forKey_;
    forKey = pvVar1;
  }
  _objc_msgSend(self_01,op,pvVar2,forKey);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  _objc_msgSend(pvVar2,sel_setObject_forKey_,self_01,
                &cfstr_HSObjectAssistantControlsDictionaryDontShowCoach);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_postNotificationName_object_,*(undefined4 *)PTR_PTR_0033686c,self);
  return;
}

*/
- (void)setDontShowCoachingHints:(BOOL)aHints forKey:(id)aKey
{
    NSString *key = [NSString stringWithFormat:@"DontShowCoachingHintsFor%@Key", aKey];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSObjectAssistantControlsDictionaryDontShowCoachingHintsKey"]];
    if (aHints) {
        [dictionary setObject:[NSNumber numberWithBool:aHints] forKey:key];
    }
    else {
        [dictionary removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"HSObjectAssistantControlsDictionaryDontShowCoachingHintsKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSHelpAssistantPaneSwitcherDontShowThisMessageDidChangedNotification" object:self];
}

- (BOOL)dontShowCoachingHintsForKey:(id)aKey
{
    char cVar1;
    id pvVar2_2;

    cVar1 = [self dontShowAllCoachingHints];
    if ((cVar1 == NO) && (aKey != nil)) {
        pvVar2_2 = [NSString stringWithFormat:@"DontShowCoachingHintsFor%@Key", aKey];
        cVar1 = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"HSObjectAssistantControlsDictionaryDontShowCoachingHintsKey"] objectForKey:pvVar2_2] boolValue];
    }
    return cVar1;
}

- (void)setDontShowAllCoachingHints:(BOOL)aHints
{
    [[NSUserDefaults standardUserDefaults] setBool:aHints forKey:@"HSObjectAssistantDontShowCoachingHintsKey"];
}

- (BOOL)dontShowAllCoachingHints
{
    return (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"HSObjectAssistantDontShowCoachingHintsKey"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021f659 @ 0021f659, 419 bytes * /

void FUN_0021f659(HSCoachingHelpManager *self,SEL _cmd)

{
  id self_00;
  int iVar1;
  id pvVar2;
  id pvVar3;
  undefined4 *puVar4;
  undefined1 *puVar5;
  undefined4 uVar6;
  HSCoachingHelpManager *local_7c;
  undefined *local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  self_00 = self->_stacks;
  puVar5 = local_50;
  puVar4 = &local_74;
  uVar6 = 0x10;
  pvVar2 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,puVar4,puVar5,0x10);
  if (pvVar2 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar3 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(self->_stacks);
        }
        _objc_msgSend(*(id *)(local_70 + (int)pvVar3 * 4),sel_removeAttributeObserver_,self,puVar5,
                      uVar6);
        pvVar3 = (id)((int)pvVar3 + 1);
      } while (pvVar3 < pvVar2);
      puVar5 = local_50;
      puVar4 = &local_74;
      uVar6 = 0x10;
      pvVar2 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,puVar4,puVar5,
                             0x10);
    } while (pvVar2 != (id)0x0);
  }
  _objc_msgSend(self->_stacks,sel_release,puVar4,puVar5,uVar6);
  _objc_msgSend(self->_lastAddedChildren,sel_release);
  _objc_msgSend(self->_ignoredChildren,sel_release);
  if (self->_objectToAdditionalCoachingPanesMap != (id)0x0) {
    _NSFreeMapTable(self->_objectToAdditionalCoachingPanesMap);
  }
  if (self->_objectToDropHelpPanesMap != (id)0x0) {
    _NSFreeMapTable(self->_objectToDropHelpPanesMap);
  }
  local_7c = self;
  local_78 = PTR_s_NSObject_00354dd0;
  _objc_msgSendSuper(&local_7c,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    for (id stack in _stacks) {
        [stack removeAttributeObserver:self];
    }
    [_stacks release];
    [_lastAddedChildren release];
    [_ignoredChildren release];
    if (_objectToAdditionalCoachingPanesMap != nil) {
        NSFreeMapTable(_objectToAdditionalCoachingPanesMap);
    }
    if (_objectToDropHelpPanesMap != nil) {
        NSFreeMapTable(_objectToDropHelpPanesMap);
    }
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{

}

- (NSUInteger)retainCount
{
    return 0xffffffff;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end

