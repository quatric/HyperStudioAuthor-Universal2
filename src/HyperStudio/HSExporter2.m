#import "HSExporter2.h"

@implementation HSExporter2

/* i386 ivar offsets: _exportedDocumentName=0x4, _delegate=0x8, _dataSource=0xc, _framesPerSecondLimit=0x10, _exportRepresentation=0x18, _exportAccessoryViewController=0x1c, _shouldTerminateExport=0x20 */

+ (id)defaultExportDocumentName
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"DefaultExportDocumentName" value:@"" table:@"Export"];
}

- (void)notifyExportDidTerminate
{
    if ([[self delegate] respondsToSelector:@selector(exportDidTerminate:)]) {
        [[self delegate] exportDidTerminate:self];
    }
}

- (void)notifyExportDidEnd
{
    if ([[self delegate] respondsToSelector:@selector(exportDidEnd:)]) {
        [[self delegate] exportDidEnd:self];
    }
}

- (void)notifyExportWillEnd
{
    if ([[self delegate] respondsToSelector:@selector(exportWillEnd:)]) {
        [[self delegate] exportWillEnd:self];
    }
}

- (void)notifyExportDidStart
{
    if ([[self delegate] respondsToSelector:@selector(exportDidStart:)]) {
        [[self delegate] exportDidStart:self];
    }
}

- (void)notifyExportWillStartWithSlideshowAttributes:(id)aAttributes
{
    if ([[self delegate] respondsToSelector:@selector(exportWillStart:withSlideshowAttributes:)]) {
        [[self delegate] exportWillStart:self withSlideshowAttributes:aAttributes];
    }
}

- (void)notifyExportErrorInProgress:(id)aProgress
{
    if ([[self delegate] respondsToSelector:@selector(exportErrorInProgress:error:)]) {
        [[self delegate] exportErrorInProgress:self error:aProgress];
    }
}

- (void)notifyExportProgressDidChangeWithProgress:(double)aProgress
{
    if ([[self delegate] respondsToSelector:@selector(exportProgressDidChange:withProgress:)]) {
        [[self delegate] exportProgressDidChange:self withProgress:aProgress];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00252e62 @ 00252e62, 12 bytes * /

void FUN_00252e62(HSExporter2 *self,SEL _cmd)

{
  *(byte *)&self->_shouldTerminateExport = (byte)self->_shouldTerminateExport | 1;
  return;
}

*/
- (void)terminateExport
{
    _shouldTerminateExport = YES;
}

- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    [self doesNotRecognizeSelector:_cmd];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00253293 @ 00253293, 667 bytes * /

void FUN_00253293(HSExporter2 *self,SEL _cmd,id exportDocument,id ofType)

{
  id pvVar1;
  id pvVar2;
  HSExporter2 *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_shouldVerifyDocumentActions);
  self_00 = self;
  op = sel_performExportDocument_ofType_;
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = exportDocument,
     pvVar2 = _objc_msgSend(self,sel_doesDocumentContainActionsThatCannotBeRun_,exportDocument),
     op = sel_performExportDocument_ofType_, (char)pvVar2 != '\0')) {
    self_00 = _objc_msgSend(cls_HSAlert,sel_new,pvVar1);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_HSExportStackWithUnsupportedActionsMessageText,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_HSExportStackWithUnsupportedActionsInformativeTe,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Continue,
                           &cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
    pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,exportDocument,
                           &cfstr_HSExporterUserInfoDocumentKey,ofType,
                           &cfstr_HSExporterUserInfoDocumentTypeKey,0);
    _objc_msgSend(pvVar1,sel_retain);
    exportDocument = _objc_msgSend(exportDocument,sel_windowForSheet);
    op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
    ofType = self;
  }
  _objc_msgSend(self_00,op,exportDocument,ofType);
  return;
}

*/
- (void)exportDocument:(id)aDocument ofType:(id)aType
{
    if ([self shouldVerifyDocumentActions] && [self doesDocumentContainActionsThatCannotBeRun:aDocument]) {
        HSAlert *alert = [HSAlert new];
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        [alert setMessageText:[provider localizedStringForKey:@"HSExportStackWithUnsupportedActionsMessageText" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[provider localizedStringForKey:@"HSExportStackWithUnsupportedActionsInformativeText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aDocument, @"HSExporterUserInfoDocumentKey", aType, @"HSExporterUserInfoDocumentTypeKey", nil];
        [userInfo retain];
        [alert beginSheetModalForWindow:[aDocument windowForSheet] modalDelegate:self didEndSelector:@selector(invalidActionsAlertDidEnd:returnCode:contextInfo:) contextInfo:userInfo];
    } else {
        [self performExportDocument:aDocument ofType:aType];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025352e @ 0025352e, 161 bytes * /

void FUN_0025352e(HSExporter2 *self,SEL _cmd,id invalidActionsAlertDidEnd,int returnCode,
                 void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  
  if (returnCode == 1000) {
    pvVar1 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_HSExporterUserInfoDocumentTypeKey);
    pvVar2 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_HSExporterUserInfoDocumentKey);
    _objc_msgSend(self,sel_performExportDocument_ofType_,pvVar2,pvVar1);
  }
  _objc_msgSend(contextInfo,sel_release);
  _objc_msgSend(invalidActionsAlertDidEnd,sel_release);
  return;
}

*/
- (void)invalidActionsAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSDictionary *userInfo = (NSDictionary *)aInfo;
    if (aCode == NSAlertFirstButtonReturn) {
        [self performExportDocument:[userInfo objectForKey:@"HSExporterUserInfoDocumentKey"] ofType:[userInfo objectForKey:@"HSExporterUserInfoDocumentTypeKey"]];
    }
    [userInfo release];
    [aEnd release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002535cf @ 002535cf, 2201 bytes * /

id FUN_002535cf(HSExporter2 *self,SEL _cmd,id actionsInDocumentThatCannotBeRun,id *forObjects)

{
  int iVar1;
  int iVar2;
  int iVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  id self_01;
  id pvVar6;
  id pvVar7;
  undefined *puVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  undefined1 *puVar13;
  SEL op;
  undefined *self_02;
  undefined4 *puVar14;
  cfstringStruct *pcVar15;
  id local_174;
  id local_170;
  id local_168;
  id local_160;
  id local_150;
  id local_144;
  cfstringStruct *local_13c;
  undefined4 local_134;
  int local_130;
  int *local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  undefined1 local_114 [64];
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar4 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_array);
  local_134 = 0;
  local_130 = 0;
  local_12c = (int *)0x0;
  local_128 = 0;
  local_124 = 0;
  local_120 = 0;
  local_11c = 0;
  local_118 = 0;
  self_00 = _objc_msgSend(actionsInDocumentThatCannotBeRun,sel_stack);
  self_01 = _objc_msgSend(self_00,sel_hyperDeepEnumerator);
  puVar13 = local_114;
  puVar14 = &local_134;
  local_13c = (cfstringStruct *)0x10;
  local_174 = _objc_msgSend(self_01,sel_countByEnumeratingWithState_objects_count_,puVar14,puVar13,
                            0x10);
  if (local_174 != (id)0x0) {
    iVar1 = *local_12c;
    do {
      local_170 = (id)0x0;
      do {
        if (iVar1 != *local_12c) {
          pvVar6 = _objc_msgSend(self_00,sel_hyperDeepEnumerator,puVar14,puVar13,local_13c);
          _objc_enumerationMutation(pvVar6);
        }
        pvVar6 = *(id *)(local_130 + (int)local_170 * 4);
        pvVar7 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00385a3c,puVar13,local_13c);
        local_170 = (id)((int)local_170 + 1);
        puVar8 = _objc_msgSend(pvVar7,sel_allLinks);
        op = sel_arrayByAddingObject_;
        if (puVar8 == (undefined *)0x0) {
          puVar8 = cls_NSArray;
          op = sel_arrayWithObject_;
        }
        pvVar6 = _objc_msgSend(puVar8,op,pvVar6);
        local_d4 = 0;
        local_d0 = 0;
        local_cc = (int *)0x0;
        local_c8 = 0;
        local_c4 = 0;
        local_c0 = 0;
        local_bc = 0;
        local_b8 = 0;
        puVar13 = local_b4;
        puVar14 = &local_d4;
        local_13c = (cfstringStruct *)0x10;
        local_168 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,puVar14,
                                  puVar13,0x10);
        if (local_168 != (id)0x0) {
          iVar2 = *local_cc;
          do {
            local_160 = (id)0x0;
            do {
              if (iVar2 != *local_cc) {
                _objc_enumerationMutation(pvVar6);
              }
              pvVar7 = _objc_msgSend(*(id *)(local_d0 + (int)local_160 * 4),sel_queryHyperInterface_
                                     ,&DAT_00385ab4,puVar13,local_13c);
              pvVar7 = _objc_msgSend(pvVar7,sel_hyperActions);
              local_74 = 0;
              local_70 = 0;
              local_6c = (int *)0x0;
              local_68 = 0;
              local_64 = 0;
              local_60 = 0;
              local_5c = 0;
              local_58 = 0;
              puVar13 = local_50;
              local_13c = (cfstringStruct *)0x10;
              local_150 = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_,
                                        &local_74);
              if (local_150 != (id)0x0) {
                iVar3 = *local_6c;
                do {
                  local_144 = (id)0x0;
                  do {
                    if (iVar3 != *local_6c) {
                      _objc_enumerationMutation(pvVar7);
                    }
                    pvVar12 = *(id *)(local_70 + (int)local_144 * 4);
                    pvVar9 = _objc_msgSend(pvVar12,sel_queryHyperInterface_,&DAT_00385b68,puVar13,
                                           local_13c);
                    if ((pvVar9 != (id)0x0) &&
                       (pvVar11 = pvVar9, pvVar10 = _objc_msgSend(self,sel_canRunAction_,pvVar9),
                       puVar8 = cls_NSString, (char)pvVar10 == '\0')) {
                      pvVar9 = _objc_msgSend(pvVar9,sel_localizedName,pvVar11);
                      pvVar11 = _objc_msgSend(puVar8,sel_stringWithFormat_,&cfstr_____,pvVar9);
                      _objc_msgSend(pvVar4,sel_addObject_,pvVar11);
                      pvVar11 = _objc_msgSend(pvVar12,sel_hyperObject);
                      puVar8 = &DAT_00385bcc;
                      pvVar11 = _objc_msgSend(pvVar11,sel_queryHyperInterface_,&DAT_00385bcc);
                      if (pvVar11 == (id)0x0) {
                        local_13c = &cfstr_empty;
                      }
                      else {
                        local_13c = _objc_msgSend(pvVar11,sel_hyperName,puVar8,pvVar9);
                      }
                      pvVar9 = _objc_msgSend(pvVar12,sel_hyperObject,puVar8);
                      puVar8 = &DAT_00385c80;
                      pvVar9 = _objc_msgSend(pvVar9,sel_implementsHyperInterface_,&DAT_00385c80);
                      self_02 = cls_NSString;
                      if ((char)pvVar9 == '\0') {
                        pvVar9 = _objc_msgSend(pvVar12,sel_hyperObject,puVar8);
                        puVar8 = &DAT_00385cd0;
                        pvVar9 = _objc_msgSend(pvVar9,sel_implementsHyperInterface_,&DAT_00385cd0);
                        self_02 = cls_NSString;
                        if ((char)pvVar9 == '\0') {
                          pvVar9 = _objc_msgSend(pvVar12,sel_hyperObject,puVar8);
                          pvVar9 = _objc_msgSend(pvVar9,sel_card);
                          _objc_msgSend(pvVar9,sel_hyperIndex);
                          pvVar12 = _objc_msgSend(pvVar12,sel_hyperObject);
                          pvVar12 = _objc_msgSend(pvVar12,sel_card);
                          _objc_msgSend(pvVar12,sel_hyperKindDisplayName);
                          puVar13 = _objc_msgSend(pvVar11,sel_hyperKindDisplayName);
                          pcVar15 = &cfstr_________at_____d;
                        }
                        else {
                          pvVar12 = _objc_msgSend(pvVar12,sel_hyperObject,puVar8);
                          puVar8 = &DAT_00385cd0;
                          pvVar12 = _objc_msgSend(pvVar12,sel_queryHyperInterface_,&DAT_00385cd0);
                          if (pvVar12 != (id)0x0) {
                            pvVar12 = _objc_msgSend(pvVar12,sel_document,puVar8);
                            local_13c = _objc_msgSend(pvVar12,sel_displayName);
                          }
                          self_02 = cls_NSString;
                          puVar13 = _objc_msgSend(pvVar11,sel_hyperKindDisplayName,puVar8);
                          pcVar15 = &cfstr________;
                        }
                      }
                      else {
                        pvVar9 = _objc_msgSend(pvVar12,sel_hyperObject,puVar8);
                        pvVar9 = _objc_msgSend(pvVar9,sel_hyperIndex);
                        pvVar12 = _objc_msgSend(pvVar12,sel_hyperObject);
                        puVar13 = _objc_msgSend(pvVar12,sel_hyperKindDisplayName);
                        local_13c = (cfstringStruct *)((int)pvVar9 + 1);
                        pcVar15 = &cfstr_____d_____;
                      }
                      pvVar12 = _objc_msgSend(self_02,sel_stringWithFormat_,pcVar15,puVar13,
                                              local_13c);
                      _objc_msgSend(pvVar5,sel_addObject_,pvVar12);
                    }
                    local_144 = (id)((int)local_144 + 1);
                  } while (local_144 < local_150);
                  puVar13 = local_50;
                  local_13c = (cfstringStruct *)0x10;
                  local_150 = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_,
                                            &local_74,puVar13,0x10);
                } while (local_150 != (id)0x0);
              }
              local_160 = (id)((int)local_160 + 1);
            } while (local_160 < local_168);
            puVar13 = local_b4;
            puVar14 = &local_d4;
            local_13c = (cfstringStruct *)0x10;
            local_168 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,puVar14,
                                      puVar13,0x10);
          } while (local_168 != (id)0x0);
        }
      } while (local_170 < local_174);
      puVar13 = local_114;
      puVar14 = &local_134;
      local_13c = (cfstringStruct *)0x10;
      local_174 = _objc_msgSend(self_01,sel_countByEnumeratingWithState_objects_count_,puVar14,
                                puVar13,0x10);
    } while (local_174 != (id)0x0);
  }
  if (forObjects != (id *)0x0) {
    pvVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar5,puVar13,local_13c);
    *forObjects = pvVar5;
  }
  pvVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar4,puVar13,local_13c);
  return pvVar4;
}

*/
- (id)actionsInDocumentThatCannotBeRun:(id)aRun forObjects:(id *)aObjects
{
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *objects = [NSMutableArray array];
    for (id node in [[aRun stack] hyperDeepEnumerator]) {
        id linkContainer = [node queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
        NSArray *links = [linkContainer allLinks];
        NSArray *owners = (links != nil) ? [links arrayByAddingObject:node] : [NSArray arrayWithObject:node];
        for (id owner in owners) {
            id actor = [owner queryHyperInterface:@protocol(HSActor)];
            for (id action in [actor hyperActions]) {
                id attributes = [action queryHyperInterface:@protocol(HSActionAttributes)];
                if (attributes != nil && ![self canRunAction:attributes]) {
                    [names addObject:[NSString stringWithFormat:@"\"%@\"", [attributes localizedName]]];
                    id object = [action hyperObject];
                    id objectAttributes = [object queryHyperInterface:@protocol(HSObjectAttributes)];
                    NSString *objectName = (objectAttributes != nil) ? [objectAttributes hyperName] : @"";
                    NSString *description;
                    if ([object implementsHyperInterface:@protocol(HSCardAttributes)]) {
                        description = [NSString stringWithFormat:@"%@ %d \"%@\"", [object hyperKindDisplayName], (int)[object hyperIndex] + 1, objectName];
                    } else if ([object implementsHyperInterface:@protocol(HSStackAttributes)]) {
                        id stackAttributes = [object queryHyperInterface:@protocol(HSStackAttributes)];
                        if (stackAttributes != nil) {
                            objectName = [[stackAttributes document] displayName];
                        }
                        description = [NSString stringWithFormat:@"%@ \"%@\"", [objectAttributes hyperKindDisplayName], objectName];
                    } else {
                        description = [NSString stringWithFormat:@"%@ \"%@\" at %@ %d", [objectAttributes hyperKindDisplayName], objectName, [[object card] hyperKindDisplayName], (int)[[object card] hyperIndex]];
                    }
                    [objects addObject:description];
                }
            }
        }
    }
    if (aObjects != NULL) {
        *aObjects = [NSArray arrayWithArray:objects];
    }
    return [NSArray arrayWithArray:names];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00253e68 @ 00253e68, 428 bytes * /

BOOL FUN_00253e68(HSExporter2 *self,SEL _cmd,id doesDocumentContainActionsThatCannotBeRun)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  undefined *self_00;
  SEL op;
  bool local_11;
  
  pvVar1 = _objc_msgSend(doesDocumentContainActionsThatCannotBeRun,sel_stack);
  local_11 = false;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperDeepEnumerator);
LAB_00253fe2:
  if ((local_11 != false) ||
     (self_00 = _objc_msgSend(pvVar1,sel_nextObject), self_00 == (undefined *)0x0)) {
    return local_11;
  }
  pvVar2 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_00385a3c);
  puVar3 = _objc_msgSend(pvVar2,sel_allLinks);
  op = sel_arrayByAddingObject_;
  if (puVar3 == (undefined *)0x0) {
    puVar3 = cls_NSArray;
    op = sel_arrayWithObject_;
  }
  pvVar2 = _objc_msgSend(puVar3,op,self_00);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
LAB_00253fbf:
  do {
    if ((local_11 != false) ||
       (pvVar5 = _objc_msgSend(pvVar2,sel_nextObject,self_00), pvVar5 == (id)0x0))
    goto LAB_00253fe2;
    puVar3 = &DAT_00385ab4;
    pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00385ab4);
    pvVar5 = _objc_msgSend(pvVar5,sel_hyperActions);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectEnumerator);
    while (self_00 = puVar3, local_11 == false) {
      do {
        pvVar4 = _objc_msgSend(pvVar5,sel_nextObject,self_00);
        if (pvVar4 == (id)0x0) goto LAB_00253fbf;
        self_00 = &DAT_00385b68;
        puVar3 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00385b68);
      } while (puVar3 == (undefined *)0x0);
      pvVar4 = _objc_msgSend(self,sel_canRunAction_,puVar3);
      local_11 = (char)pvVar4 == '\0';
    }
  } while( true );
}

*/
- (BOOL)doesDocumentContainActionsThatCannotBeRun:(id)aRun
{
    for (id node in [[aRun stack] hyperDeepEnumerator]) {
        id linkContainer = [node queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
        NSArray *links = [linkContainer allLinks];
        NSArray *owners = (links != nil) ? [links arrayByAddingObject:node] : [NSArray arrayWithObject:node];
        for (id owner in owners) {
            id actor = [owner queryHyperInterface:@protocol(HSActor)];
            for (id action in [actor hyperActions]) {
                id attributes = [action queryHyperInterface:@protocol(HSActionAttributes)];
                if (attributes != nil && ![self canRunAction:attributes]) {
                    return YES;
                }
            }
        }
    }
    return NO;
    return 0;
}

- (BOOL)canRunAction:(id)aAction
{
    return YES;
}

- (BOOL)shouldVerifyDocumentActions
{
    return NO;
}

- (void)setDataSource:(id)aSource
{
    if (_dataSource != aSource) {
        _dataSource = aSource;
    }
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)progressSheetDescription
{
    return nil;
}

- (BOOL)isSupportedProgressSheet
{
    return YES;
}

- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType
{
    return _exportAccessoryViewController;
}

- (id)exportRepresentation
{
    return _exportRepresentation;
}

- (double)framesPerSecondLimit
{
    return _framesPerSecondLimit;
}

- (void)setFramesPerSecondLimit:(double)aLimit
{
    _framesPerSecondLimit = aLimit;
}

- (void)setExportedDocumentName:(id)aName
{
    if (![aName isEqualToString:_exportedDocumentName]) {
        [_exportedDocumentName release];
        _exportedDocumentName = [aName retain];
    }
}

- (id)exportedDocumentName
{
    id pvVar1;

    pvVar1 = _exportedDocumentName;
    if (pvVar1 == nil) {
        pvVar1 = [[[self class] defaultExportDocumentName] retain];
        _exportedDocumentName = pvVar1;
    }
    return pvVar1;
}

- (void)dealloc
{
    [_exportedDocumentName release];
    [_exportRepresentation release];
    [_exportAccessoryViewController release];
    [_exportSettings release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00252e6e @ 00252e6e, 71 bytes * /

id FUN_00252e6e(HSExporter2 *self,SEL _cmd)

{
  id pvVar1;
  HSExporter2 *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_NSObject_00355e50;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x14) = 0x40240000;
    *(undefined4 *)((int)pvVar1 + 0x10) = 0;
  }
  return pvVar1;
}

*/
- (id)defaultExportSettings
{
    return [NSDictionary dictionary];
}

- (id)exportSettings
{
    if (_exportSettings == nil)
        _exportSettings = [[NSMutableDictionary alloc] initWithDictionary:[self defaultExportSettings]];
    return _exportSettings;
}

- (id)exportSettingsValueForKey:(id)aKey
{
    return [[self exportSettings] valueForKey:aKey];
}

- (void)setExportSettingsValue:(id)aValue forKey:(id)aKey
{
    if (aKey != nil)
        [[self exportSettings] setValue:aValue forKey:aKey];
}

- (id)requiredFileType
{
    return nil;
}

- (id)escapeFileNameForExport:(id)aName
{
    return aName;
}

@end

