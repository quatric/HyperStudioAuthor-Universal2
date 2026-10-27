#import "HSSelectionOperationVerifier.h"
static id sDAT_003428d8;

static id sDAT_003428d8;


@implementation HSSelectionOperationVerifier

/* i386 ivar offsets: _selection=0x4 */

- (BOOL)verifyCanPerformOperation:(id)aOperation onNodesInArray:(id *)aArray
{
    return (BOOL)[self verifyCanPerformOperation:aOperation onNodesInArray:aArray proceedWithOperation:nil neverAskUser:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c8458 @ 000c8458, 2121 bytes * /

BOOL FUN_000c8458(HSSelectionOperationVerifier *self,SEL _cmd,id verifyCanPerformOperation,
                 id *onNodesInArray,BOOL *proceedWithOperation,BOOL neverAskUser)

{
  bool bVar1;
  bool bVar2;
  char cVar3;
  char cVar4;
  id pvVar5;
  SEL pcVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  undefined *puVar10;
  cfstringStruct *pcVar11;
  cfstringStruct *pcVar12;
  cfstringStruct *pcVar13;
  bool bVar14;
  id local_24;
  cfstringStruct *local_20;
  cfstringStruct *local_18;
  char local_14;
  char local_13;
  char local_12;
  char local_11;
  
  pvVar9 = *onNodesInArray;
  pvVar5 = _objc_msgSend(pvVar9,sel_count);
  pcVar6 = sel_lastObject;
  if ((id)0x1 < pvVar5) {
    pcVar6 = sel_hyperObjectForAnyInterfaces;
  }
  pvVar5 = _objc_msgSend(pvVar9,pcVar6);
  local_11 = '\0';
  local_12 = '\0';
  local_13 = '\0';
  pcVar12 = (cfstringStruct *)&local_13;
  pcVar13 = (cfstringStruct *)&local_12;
  pcVar11 = (cfstringStruct *)&local_11;
  pvVar7 = _objc_msgSend(self,
                         sel_hasLockedItemsInObject_multipleLockedItems_allLocked_multipleObjects_,
                         pvVar5,pcVar11,pcVar13,pcVar12);
  if ((char)pvVar7 == '\0') {
    bVar2 = false;
LAB_000c8a3b:
    bVar14 = true;
    goto LAB_000c8c87;
  }
  pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Drag,pcVar11,pcVar13,
                         pcVar12);
  if ((char)pvVar7 == '\0') {
    pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Move,pcVar11,
                           pcVar13,pcVar12);
    if ((char)pvVar7 != '\0') {
LAB_000c856b:
      bVar2 = true;
      goto LAB_000c8517;
    }
    pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Select,pcVar11,
                           pcVar13,pcVar12);
    if (((char)pvVar7 != '\0') ||
       ((((pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Delete,
                                  pcVar11,pcVar13,pcVar12), (char)pvVar7 == '\0' &&
          (pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Cut),
          (char)pvVar7 == '\0')) &&
         (pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Edit),
         (char)pvVar7 == '\0')) &&
        (((pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Flat),
          (char)pvVar7 == '\0' &&
          (pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Merge),
          (char)pvVar7 == '\0')) &&
         ((pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Order),
          (char)pvVar7 == '\0' &&
          (pvVar7 = _objc_msgSend(verifyCanPerformOperation,sel_isEqualToString_,&cfstr_Restore),
          (char)pvVar7 == '\0')))))))) goto LAB_000c8513;
    if (neverAskUser != '\0') goto LAB_000c856b;
    pvVar7 = _objc_msgSend(self,sel_shouldUseUniqueMessageForOperation_,verifyCanPerformOperation);
    cVar4 = (char)pvVar7;
    pvVar7 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_ProceedLockedButton__,
                           verifyCanPerformOperation);
    pvVar8 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar13 = &cfstr_Alerts;
    local_20 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,pvVar7,&cfstr_empty,
                             &cfstr_Alerts);
    if (cVar4 == '\0') {
      pvVar7 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_LockedMessage__,
                             verifyCanPerformOperation,pcVar13);
      pvVar8 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar11 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,pvVar7,&cfstr_empty,
                              &cfstr_Alerts);
      cVar3 = local_13;
      puVar10 = cls_NSString;
      pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      local_18 = pcVar11;
      if (cVar3 == '\0') {
        pcVar13 = &cfstr_Alerts;
        pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                               &cfstr_Unlock_and____the_item_,&cfstr_empty,&cfstr_Alerts);
        pcVar6 = sel_stringWithFormat_;
      }
      else {
        pcVar13 = &cfstr_Alerts;
        pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                               &cfstr_Unlock_and____the_items_,&cfstr_empty,&cfstr_Alerts);
        pcVar6 = sel_stringWithFormat_;
      }
    }
    else {
      pvVar7 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_UniqueLockedTitle__,
                             verifyCanPerformOperation,pcVar13);
      puVar10 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar13 = &cfstr_Alerts;
      pcVar11 = &cfstr_empty;
      local_18 = (cfstringStruct *)0x0;
      pcVar6 = sel_localizedStringForKey_value_table_;
    }
    bVar1 = false;
    bVar2 = false;
    local_24 = _objc_msgSend(puVar10,pcVar6,pvVar7,pcVar11,pcVar13);
  }
  else {
LAB_000c8513:
    bVar2 = false;
LAB_000c8517:
    local_24 = (id)0x0;
    bVar1 = true;
    pvVar7 = verifyCanPerformOperation;
    pvVar8 = _objc_msgSend(self,sel_shouldUseUniqueMessageForOperation_,verifyCanPerformOperation,
                           pcVar11,pcVar13,pcVar12);
    cVar4 = (char)pvVar8;
    local_20 = (cfstringStruct *)0x0;
    local_18 = (cfstringStruct *)0x0;
  }
  cVar3 = local_11;
  if (local_12 == '\0') {
    local_14 = '\0';
    if (bVar1) {
      if (!bVar2) {
        bVar14 = true;
        bVar1 = false;
        local_20 = pcVar13;
        goto LAB_000c8c06;
      }
      local_14 = '\x01';
      bVar1 = false;
LAB_000c8c12:
      pvVar9 = _objc_msgSend(self,sel_filteredUnlockedItemsInNodesArray_,pvVar9,pcVar11,pcVar13,
                             pcVar12);
      *onNodesInArray = pvVar9;
      pvVar9 = _objc_msgSend(pvVar9,sel_count);
      bVar14 = pvVar9 != (id)0x0;
      local_20 = pcVar13;
    }
    else {
      pvVar7 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_SkipLockedButton__,
                             verifyCanPerformOperation,pcVar13);
      pvVar8 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar13 = &cfstr_Alerts;
      pcVar11 = &cfstr_empty;
      pcVar12 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,pvVar7,&cfstr_empty,
                              &cfstr_Alerts);
      cVar4 = local_13;
      if (local_11 == '\0') {
        pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7,pcVar11,
                               pcVar13);
        if (cVar4 == '\0') {
          pcVar13 = &cfstr_The_items_you_are_trying_to____are_locked_and_ca;
        }
        else {
          pcVar13 = &cfstr_One_of_the_items_you_are_trying_to____is_locked_;
        }
      }
      else {
        pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7,pcVar11,
                               pcVar13);
        pcVar13 = &cfstr_Some_of_the_items_you_are_trying_to____is_locked;
      }
      pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,pcVar13,&cfstr_empty,
                             &cfstr_Alerts);
      pcVar11 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pvVar7,local_18,local_20,local_18,
                              pcVar12,local_18);
      pvVar7 = _objc_msgSend(self,
                             sel_displayAlertWithTitle_message_proceedButtonTitle_skipLockedButtonTitle_shouldSkipLocked_
                             ,local_24,pcVar11,local_20,pcVar12,&local_14);
      if ((char)pvVar7 == '\0') {
        if (local_14 == '\0') {
          bVar14 = false;
          bVar1 = false;
        }
        else {
          bVar14 = true;
          bVar1 = false;
        }
      }
      else {
        bVar14 = true;
        bVar1 = true;
      }
LAB_000c8c06:
      pcVar13 = local_20;
      if (local_14 != '\0') goto LAB_000c8c12;
    }
    if (!bVar1) goto LAB_000c8c87;
LAB_000c8c4e:
    pvVar9 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_0036bdf8,pcVar11,local_20,pcVar12);
    _objc_msgSend(pvVar9,sel_setLocked_,0);
  }
  else {
    if (bVar1) {
      if (!bVar2) goto LAB_000c8a3b;
    }
    else {
      if (cVar4 == '\0') {
        pvVar9 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7,pcVar11,
                               pcVar13);
        if (cVar3 == '\0') {
          pcVar12 = &cfstr_The_item_you_are_trying_to____is_locked_and_cann;
        }
        else {
          pcVar12 = &cfstr_The_items_you_are_trying_to____are_locked_and_ca;
        }
        pvVar9 = _objc_msgSend(pvVar9,sel_localizedStringForKey_value_table_,pcVar12,&cfstr_empty,
                               &cfstr_Alerts);
        puVar10 = cls_NSString;
        pcVar6 = sel_stringWithFormat_;
        pcVar13 = local_20;
        pcVar12 = local_18;
      }
      else {
        pvVar9 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_UniqueLockedMessage__,
                               verifyCanPerformOperation,pcVar13);
        puVar10 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        local_18 = &cfstr_empty;
        pcVar6 = sel_localizedStringForKey_value_table_;
        pcVar13 = &cfstr_Alerts;
      }
      pcVar11 = _objc_msgSend(puVar10,pcVar6,pvVar9,local_18,pcVar13,pcVar12);
      pvVar9 = _objc_msgSend(self,sel_displayAlertWithTitle_message_proceedButtonTitle_,local_24,
                             pcVar11,local_20);
      if ((char)pvVar9 != '\0') {
        bVar14 = true;
        goto LAB_000c8c4e;
      }
    }
    bVar14 = false;
  }
LAB_000c8c87:
  if (proceedWithOperation != (BOOL *)0x0) {
    *proceedWithOperation = bVar2 || bVar14 != false;
  }
  return bVar14;
}

*/
- (BOOL)verifyCanPerformOperation:(id)aOperation onNodesInArray:(id *)aArray proceedWithOperation:(BOOL *)aOperation2 neverAskUser:(BOOL)aUser
{
    NSArray *nodes = *aArray;
    id object = ([nodes count] > 1) ? [nodes hyperObjectForAnyInterfaces] : [nodes lastObject];
    BOOL multipleLockedItems = NO;
    BOOL allLocked = NO;
    BOOL multipleObjects = NO;
    BOOL noAsk;
    BOOL forceProceed;
    BOOL result;
    BOOL skipLocked;
    BOOL unique = NO;
    id alertTitle = nil;
    NSString *proceedTitle = nil;
    NSString *verb = nil;
    if (![self hasLockedItemsInObject:object multipleLockedItems:&multipleLockedItems allLocked:&allLocked multipleObjects:&multipleObjects]) {
        forceProceed = NO;
        result = YES;
        goto done;
    }
    if (![aOperation isEqualToString:@"Drag"]) {
        if ([aOperation isEqualToString:@"Move"]) {
            forceProceed = YES;
            noAsk = YES;
            unique = [self shouldUseUniqueMessageForOperation:aOperation];
        } else if ([aOperation isEqualToString:@"Select"] ||
                   !([aOperation isEqualToString:@"Delete"] || [aOperation isEqualToString:@"Cut"] ||
                     [aOperation isEqualToString:@"Edit"] || [aOperation isEqualToString:@"Flat"] ||
                     [aOperation isEqualToString:@"Merge"] || [aOperation isEqualToString:@"Order"] ||
                     [aOperation isEqualToString:@"Restore"])) {
            forceProceed = NO;
            noAsk = YES;
            unique = [self shouldUseUniqueMessageForOperation:aOperation];
        } else if (aUser) {
            forceProceed = YES;
            noAsk = YES;
            unique = [self shouldUseUniqueMessageForOperation:aOperation];
        } else {
            HSExecutableResourceProvider *provider;
            unique = [self shouldUseUniqueMessageForOperation:aOperation];
            provider = [HSExecutableResourceProvider sharedInstance];
            proceedTitle = [provider localizedStringForKey:[NSString stringWithFormat:@"ProceedLockedButton%@", aOperation] value:@"" table:@"Alerts"];
            if (!unique) {
                verb = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"LockedMessage%@", aOperation] value:@"" table:@"Alerts"];
                NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(multipleObjects ? @"Unlock and %@ the items?" : @"Unlock and %@ the item?") value:@"" table:@"Alerts"];
                alertTitle = [NSString stringWithFormat:format, verb];
            } else {
                alertTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"UniqueLockedTitle%@", aOperation] value:@"" table:@"Alerts"];
            }
            noAsk = NO;
            forceProceed = NO;
        }
    } else {
        forceProceed = NO;
        noAsk = YES;
        unique = [self shouldUseUniqueMessageForOperation:aOperation];
    }
    if (!allLocked) {
        skipLocked = NO;
        if (noAsk) {
            if (!forceProceed) {
                result = YES;
                goto done;
            }
            skipLocked = YES;
        } else {
            NSString *skipTitle = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"SkipLockedButton%@", aOperation] value:@"" table:@"Alerts"];
            NSString *format;
            if (!multipleLockedItems) {
                format = multipleObjects ? @"One of the items you are trying to %@ is locked and cannot be edited. Click %@ to %@ all the selected items including the locked one, or click %@ to %@ only the items that are not locked." : @"The items you are trying to %@ are locked and cannot be edited. Click %@ to %@ all the selected items.";
            } else {
                format = @"Some of the items you are trying to %@ is locked and cannot be edited. Click %@ to %@ all the selected items including the locked one, or click %@ to %@ only the items that are not locked.";
            }
            NSString *localized = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:format value:@"" table:@"Alerts"];
            NSString *message = [NSString stringWithFormat:localized, verb, proceedTitle, verb, skipTitle, verb];
            if ([self displayAlertWithTitle:alertTitle message:message proceedButtonTitle:proceedTitle skipLockedButtonTitle:skipTitle shouldSkipLocked:&skipLocked]) {
                result = YES;
                noAsk = YES;
            } else {
                result = skipLocked;
                noAsk = NO;
            }
            if (!skipLocked) {
                if (noAsk) {
                    goto unlock;
                }
                goto done;
            }
        }
        nodes = [self filteredUnlockedItemsInNodesArray:nodes];
        *aArray = nodes;
        result = ([nodes count] != 0);
        if (noAsk && !forceProceed) {
            goto unlock;
        }
        if (!noAsk) {
            goto done;
        }
        goto unlockIfNeeded;
    } else {
        if (noAsk) {
            if (!forceProceed) {
                result = YES;
                goto done;
            }
        } else {
            NSString *message;
            if (!unique) {
                NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(multipleLockedItems ? @"The items you are trying to %@ are locked and cannot be edited. Click %@ to %@ all the selected items." : @"The item you are trying to %@ is locked and cannot be edited. Click %@ to %@ it.") value:@"" table:@"Alerts"];
                message = [NSString stringWithFormat:format, verb, proceedTitle, verb];
            } else {
                message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"UniqueLockedMessage%@", aOperation] value:@"" table:@"Alerts"];
            }
            if ([self displayAlertWithTitle:alertTitle message:message proceedButtonTitle:proceedTitle]) {
                result = YES;
                goto unlock;
            }
        }
        result = NO;
        goto done;
    }
unlockIfNeeded:
    goto done;
unlock:
    [[object queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setLocked:NO];
done:
    if (aOperation2 != NULL) {
        *aOperation2 = (forceProceed || result);
    }
    return result;
    return 0;
}

- (BOOL)shouldUseUniqueMessageForOperation:(id)aOperation
{
    return [aOperation isEqual:@"Restore"];
}

- (id)filteredUnlockedItemsInNodesArray:(id)aArray
{
    NSUInteger pvVar2;
    id self_01;
    NSUInteger pvVar4;
    id pvVar1_2;

    pvVar1_2 = [NSMutableArray arrayWithCapacity:[aArray count]];
    pvVar2 = [aArray count];
    if (pvVar2 != 0) {
        pvVar4 = 0;
        do {
            self_01 = [aArray objectAtIndex:pvVar4];
            if (![[self_01 queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
                [pvVar1_2 addObject:self_01];
            }
            pvVar4 = (pvVar4 + 1);
        } while (pvVar4 < pvVar2);
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c8dae @ 000c8dae, 366 bytes * /

BOOL FUN_000c8dae(HSSelectionOperationVerifier *self,SEL _cmd,id hasLockedItemsInObject,
                 BOOL *multipleLockedItems,BOOL *allLocked,BOOL *multipleObjects)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  BOOL BVar5;
  BOOL BVar6;
  uint uVar7;
  undefined *puVar8;
  bool local_1a;
  BOOL local_19;
  
  puVar8 = &DAT_0036bc90;
  pvVar1 = _objc_msgSend(hasLockedItemsInObject,sel_queryHyperInterface_,&DAT_0036bc90);
  if (pvVar1 == (id)0x0) {
    BVar6 = '\0';
    local_19 = '\0';
    local_1a = false;
    BVar5 = '\0';
    goto LAB_000c8dee;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_isLocked,puVar8);
  pvVar3 = _objc_msgSend(pvVar1,sel_lastHyperAccessDidReturnMultipleValues);
  local_19 = '\x01';
  if ((char)pvVar3 == '\0' || (char)pvVar2 != '\0') {
    local_19 = (char)pvVar2;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_countOfAllHyperInterfaces,puVar8);
  local_1a = (id)0x1 < pvVar2;
  if (local_19 != '\0') {
    if (pvVar2 < (id)0x2) {
      BVar6 = '\x01';
      BVar5 = '\0';
      goto LAB_000c8dee;
    }
    if ((char)pvVar3 == '\0') {
      BVar5 = '\x01';
      BVar6 = '\x01';
      goto LAB_000c8dee;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_allHyperInterfaces,puVar8);
    uVar7 = 0;
    pvVar2 = _objc_msgSend(pvVar1,sel_count);
    for (pvVar3 = (id)0x0; pvVar3 < pvVar2; pvVar3 = (id)((int)pvVar3 + 1)) {
      pvVar4 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar3);
      pvVar4 = _objc_msgSend(pvVar4,sel_isLocked);
      uVar7 = uVar7 + ((char)pvVar4 != '\0');
      if (1 < uVar7) {
        BVar6 = '\0';
        BVar5 = '\x01';
        goto LAB_000c8dee;
      }
    }
  }
  BVar6 = '\0';
  BVar5 = BVar6;
LAB_000c8dee:
  if (multipleLockedItems != (BOOL *)0x0) {
    *multipleLockedItems = BVar5;
  }
  if (allLocked != (BOOL *)0x0) {
    *allLocked = BVar6;
  }
  if (multipleObjects != (BOOL *)0x0) {
    *multipleObjects = local_1a;
  }
  return local_19;
}

*/
- (BOOL)hasLockedItemsInObject:(id)aObject multipleLockedItems:(BOOL *)aItems allLocked:(BOOL *)aLocked multipleObjects:(BOOL *)aObjects
{
    BOOL locked = NO;
    BOOL allLocked = NO;
    BOOL multipleLocked = NO;
    BOOL multipleObjects = NO;
    id<HSCardObjectAttributes> attributes = [aObject queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (attributes != nil) {
        BOOL isLocked = [attributes isLocked];
        BOOL multipleValues = ((BOOL (*)(id, SEL))objc_msgSend)(attributes, @selector(lastHyperAccessDidReturnMultipleValues));
        locked = YES;
        if (!multipleValues || isLocked) {
            locked = isLocked;
        }
        NSUInteger count = ((NSUInteger (*)(id, SEL))objc_msgSend)(attributes, @selector(countOfAllHyperInterfaces));
        multipleObjects = (count > 1);
        if (locked) {
            if (count < 2) {
                allLocked = YES;
            } else if (!multipleValues) {
                allLocked = YES;
                multipleLocked = YES;
            } else {
                NSArray *interfaces = [attributes allHyperInterfaces];
                NSUInteger lockedCount = 0;
                NSUInteger total = [interfaces count];
                for (NSUInteger index = 0; index < total; index++) {
                    if ([[interfaces objectAtIndex:index] isLocked]) {
                        lockedCount++;
                    }
                    if (lockedCount > 1) {
                        multipleLocked = YES;
                        break;
                    }
                }
            }
        }
    }
    if (aItems != NULL) {
        *aItems = multipleLocked;
    }
    if (aLocked != NULL) {
        *aLocked = allLocked;
    }
    if (aObjects != NULL) {
        *aObjects = multipleObjects;
    }
    return locked;
    return 0;
}

- (BOOL)displayAlertWithTitle:(id)aTitle message:(id)aMessage proceedButtonTitle:(id)aTitle2
{
    return (BOOL)[self displayAlertWithTitle:aTitle message:aMessage proceedButtonTitle:aTitle2 skipLockedButtonTitle:nil shouldSkipLocked:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c8f6a @ 000c8f6a, 217 bytes * /

BOOL FUN_000c8f6a(HSSelectionOperationVerifier *self,SEL _cmd,id displayAlertWithTitle,id message,
                 id proceedButtonTitle,id skipLockedButtonTitle,BOOL *shouldSkipLocked)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  bool bVar4;
  bool bVar5;
  
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar3 = pvVar2;
  pvVar1 = (id)0x0;
  if (skipLockedButtonTitle != (id)0x0) {
    pvVar3 = skipLockedButtonTitle;
    pvVar1 = pvVar2;
  }
  pvVar1 = _objc_msgSend(cls_NSAlert,
                         sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                         ,displayAlertWithTitle,proceedButtonTitle,pvVar3,pvVar1,message);
  pvVar1 = _objc_msgSend(pvVar1,sel_runModal);
  bVar4 = pvVar1 == (id)0x1;
  if ((bVar4) || (skipLockedButtonTitle == (id)0x0)) {
    bVar5 = false;
  }
  else {
    bVar5 = pvVar1 == (id)0x0;
    bVar4 = false;
  }
  if (shouldSkipLocked != (BOOL *)0x0) {
    *shouldSkipLocked = bVar5;
  }
  return bVar4;
}

*/
- (BOOL)displayAlertWithTitle:(id)aTitle message:(id)aMessage proceedButtonTitle:(id)aTitle2 skipLockedButtonTitle:(id)aTitle3 shouldSkipLocked:(BOOL *)aLocked
{
    NSString *cancel = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"];
    NSString *alternate = cancel;
    NSString *other = nil;
    if (aTitle3 != nil) {
        alternate = aTitle3;
        other = cancel;
    }
    NSAlert *alert = [NSAlert alertWithMessageText:aTitle defaultButton:aTitle2 alternateButton:alternate otherButton:other informativeTextWithFormat:@"%@", aMessage];
    NSInteger response = [alert runModal];
    BOOL proceed = (response == 1);
    BOOL skip = NO;
    if (!proceed && aTitle3 != nil) {
        skip = (response == 0);
    }
    if (aLocked != NULL) {
        *aLocked = skip;
    }
    return proceed;
    return 0;
}

- (BOOL)isOperationAllowedNoSelect:(id)aSelect
{
    if (sDAT_003428d8 == nil) {
        sDAT_003428d8 = [[NSSet alloc] initWithObjects:@"Move", @"Drag", @"Delete", @"Cut", @"Edit", @"Flat", @"Merge", @"Order", @"Restore", nil];
    }
    return (BOOL)[sDAT_003428d8 containsObject:aSelect];
}

- (id)selectedNodesArrayForRestoreOperation
{
    return [self selectedNodesArrayForOperation:@"Restore"];
}

- (id)selectedNodesArrayForOrderOperation
{
    return [self selectedNodesArrayForOperation:@"Order"];
}

- (id)selectedNodesArrayForMergeOperation
{
    return [self selectedNodesArrayForOperation:@"Merge"];
}

- (id)selectedNodesArrayForFlatOperation
{
    return [self selectedNodesArrayForOperation:@"Flat"];
}

- (id)selectedNodesArrayForEditingOperationWithImplicitCheck:(BOOL)aCheck
{
    return [self selectedNodesArrayForOperation:@"Edit" proceedWithOperation:nil neverAskUser:(unsigned int)aCheck modifySelectionIfNeeded:(unsigned int)(aCheck == 0)];
}

- (id)selectedNodesArrayForCutOperation
{
    return [self selectedNodesArrayForOperation:@"Cut"];
}

- (id)selectedNodesArrayForDeleteOperation
{
    return [self selectedNodesArrayForOperation:@"Delete"];
}

- (id)selectedNodesArrayForMoveOperation
{
    return [self selectedNodesArrayForOperation:@"Move"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c92b0 @ 000c92b0, 96 bytes * /

void FUN_000c92b0(HSSelectionOperationVerifier *self,SEL _cmd,
                 id *getSelectedNodesArrayForDragOperation,BOOL *canProceed,
                 BOOL modifySelectionIfNeeded)

{
  id pvVar1;
  BOOL local_5;
  
  local_5 = '\x01';
  pvVar1 = _objc_msgSend(self,
                         sel_selectedNodesArrayForOperation_proceedWithOperation_neverAskUser_modifySelectionIfNeeded_
                         ,&cfstr_Drag,&local_5,0,(uint)(byte)modifySelectionIfNeeded);
  if (getSelectedNodesArrayForDragOperation != (id *)0x0) {
    *getSelectedNodesArrayForDragOperation = pvVar1;
  }
  if (canProceed != (BOOL *)0x0) {
    *canProceed = local_5;
  }
  return;
}

*/
- (void)getSelectedNodesArrayForDragOperation:(id *)aOperation canProceed:(BOOL *)aProceed modifySelectionIfNeeded:(BOOL)aNeeded
{
    BOOL canProceed = YES;
    id nodes = [self selectedNodesArrayForOperation:@"Drag" proceedWithOperation:&canProceed neverAskUser:NO modifySelectionIfNeeded:aNeeded];
    if (aOperation != NULL) {
        *aOperation = nodes;
    }
    if (aProceed != NULL) {
        *aProceed = canProceed;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c9310 @ 000c9310, 96 bytes * /

void FUN_000c9310(HSSelectionOperationVerifier *self,SEL _cmd,
                 id *getSelectedNodesArrayForMoveOperation,BOOL *canProceed,
                 BOOL modifySelectionIfNeeded)

{
  id pvVar1;
  BOOL local_5;
  
  local_5 = '\x01';
  pvVar1 = _objc_msgSend(self,
                         sel_selectedNodesArrayForOperation_proceedWithOperation_neverAskUser_modifySelectionIfNeeded_
                         ,&cfstr_Move,&local_5,0,(uint)(byte)modifySelectionIfNeeded);
  if (getSelectedNodesArrayForMoveOperation != (id *)0x0) {
    *getSelectedNodesArrayForMoveOperation = pvVar1;
  }
  if (canProceed != (BOOL *)0x0) {
    *canProceed = local_5;
  }
  return;
}

*/
- (void)getSelectedNodesArrayForMoveOperation:(id *)aOperation canProceed:(BOOL *)aProceed modifySelectionIfNeeded:(BOOL)aNeeded
{
    BOOL canProceed = YES;
    id nodes = [self selectedNodesArrayForOperation:@"Move" proceedWithOperation:&canProceed neverAskUser:NO modifySelectionIfNeeded:aNeeded];
    if (aOperation != NULL) {
        *aOperation = nodes;
    }
    if (aProceed != NULL) {
        *aProceed = canProceed;
    }
}

- (BOOL)verifyCanSelectNodesInArray:(id *)aArray
{
    return (BOOL)[self verifyCanPerformOperation:@"Select" onNodesInArray:aArray];
}

- (id)selectedNodesArrayForOperation:(id)aOperation
{
    return [self selectedNodesArrayForOperation:aOperation proceedWithOperation:nil neverAskUser:NO modifySelectionIfNeeded:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c93ef @ 000c93ef, 205 bytes * /

id FUN_000c93ef(HSSelectionOperationVerifier *self,SEL _cmd,id selectedNodesArrayForOperation,
               BOOL *proceedWithOperation,BOOL neverAskUser,BOOL modifySelectionIfNeeded)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  id *ppvVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(pvVar1,sel_nodesArray);
  iVar4 = (int)neverAskUser;
  ppvVar5 = &local_14;
  local_14 = pvVar2;
  pvVar3 = _objc_msgSend(self,
                         sel_verifyCanPerformOperation_onNodesInArray_proceedWithOperation_neverAskUser_
                         ,selectedNodesArrayForOperation,ppvVar5,proceedWithOperation,iVar4);
  pvVar1 = local_14;
  if ((char)pvVar3 == '\0') {
    pvVar1 = (id)0x0;
  }
  else if ((local_14 != pvVar2) && (modifySelectionIfNeeded != '\0')) {
    pvVar3 = _objc_msgSend(self,sel_selection,selectedNodesArrayForOperation,ppvVar5,
                           proceedWithOperation,iVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    _objc_msgSend(pvVar3,sel_selectNodesInEnumerator_,pvVar2);
  }
  return pvVar1;
}

*/
- (id)selectedNodesArrayForOperation:(id)aOperation proceedWithOperation:(BOOL *)aOperation2 neverAskUser:(BOOL)aUser modifySelectionIfNeeded:(BOOL)aNeeded
{
    id original = [[self selection] nodesArray];
    id nodes = original;
    if (![self verifyCanPerformOperation:aOperation onNodesInArray:&nodes proceedWithOperation:aOperation2 neverAskUser:aUser]) {
        return nil;
    }
    if (nodes != original && aNeeded) {
        [[self selection] selectNodesInEnumerator:[original objectEnumerator]];
    }
    return nodes;
    return 0;
}

- (id)selection
{
    return _selection;
}

- (void)dealloc
{
    [_selection release];
    [super dealloc];
}

- (id)init
{
    return [self initWithSelection:nil];
}

- (id)initWithSelection:(id)aSelection
{
    self = [super init];
    if (self != nil) {
        _selection = [aSelection retain];
    }
    return self;
}

@end

