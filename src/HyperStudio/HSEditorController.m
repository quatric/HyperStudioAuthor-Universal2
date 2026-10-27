#import "HSEditorController.h"

@implementation HSEditorController

static BOOL sLastTextFieldTamerReadOnly;
static BOOL sLastTextFieldTamerThisCard;

/* i386 ivar offsets: _sharedPlayerInEditorWindowController=0x4c, _sharedPurePlayerWindowController=0x50, _sharedPresentationWindowController=0x54, _windowsOwnerDocument=0x58, _filesToOpen=0x5c, _applicationLicensor=0x60, _applicationWillFinishCriticalLaunching=0x64, _applicationOpenUntitledFilePending=0x64, _needCancelImportFiles=0x64, _replacingDocument=0x64, _documentInEditor=0x65, _documentsInPurePlayerAndPresentationModesCount=0x68, _onionSkinMode=0x6c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da80 @ 0002da80, 12 bytes * /

void FUN_0002da80(HSEditorController *self,SEL _cmd,id cancelExport)

{
  self->_applicationWillFinishCriticalLaunching[0] =
       self->_applicationWillFinishCriticalLaunching[0] | 4;
  return;
}

*/
- (void)cancelExport:(id)aExport
{
    _needCancelImportFiles = YES;
}

- (void)insertInOrderedDocuments:(id)aDocuments
{
    [self insertInOrderedDocuments:aDocuments atIndex:0];
}

- (void)insertInOrderedDocuments:(id)aDocuments atIndex:(NSInteger)aIndex
{
    [self openUntitledDocumentAndDisplay:YES error:0];
}

- (BOOL)application:(id)aApplication delegateHandlesKey:(id)aKey
{
    return (BOOL)[aKey isEqualToString:@"orderedDocuments"];
}

- (id)orderedDocuments
{
    return [self documents];
}

- (id)EULAAttributedString
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] pathForResource:@"HS5LA" ofType:@"rtf"];
    return [[[NSAttributedString alloc] initWithPath:pvVar1_2 documentAttributes:nil] autorelease];
}

- (id)EULATitle
{
    return [[NSBundle mainBundle] localizedStringForKey:@"HSEditorEULATitle" value:@"" table:0];
}

- (id)EULAWindowTitle
{
    return [[NSBundle mainBundle] localizedStringForKey:@"HSEditorEULAWindowTitle" value:@"" table:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003438b @ 0003438b, 743 bytes * /

BOOL FUN_0003438b(HSEditorController *self,SEL _cmd,
                 BOOL HSEditorController_validateApplicationLicenseWithInteraction,BOOL forced)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  HSApplicationLicensor *self_00;
  id pvVar4;
  HSEditorController *pHVar5;
  HSEditorController *self_01;
  int iVar6;
  SEL op;
  undefined *puVar7;
  undefined4 uVar8;
  cfstringStruct *pcVar9;
  undefined4 uVar10;
  
  self_00 = self->_applicationLicensor;
  if (self_00 == (HSApplicationLicensor *)0x0) {
    pvVar2 = _objc_msgSend(cls_HSApplicationLicensor,sel_alloc);
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar9 = &cfstr_5_0;
    puVar7 = &DAT_00341c88;
    uVar10 = 0;
    uVar8 = 0x805;
    self_00 = _objc_msgSend(pvVar2,
                            sel_initWithLicensorBytes_bytesSize_bundle_majorVersion_minorVersion_,
                            &DAT_00341c88,0x805,pvVar3,&cfstr_5_0,0);
    self->_applicationLicensor = self_00;
    if (self_00 == (HSApplicationLicensor *)0x0) {
      pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar7,uVar8,pvVar3
                             ,pcVar9,uVar10);
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Quit,&cfstr_empty,
                             &cfstr_Alerts);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_Bundle_content_is_corrupted__Try_to_reinstall,&cfstr_empty,
                             &cfstr_Alerts);
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                             &cfstr_HyperStudio_will_quit_now,&cfstr_empty,&cfstr_Alerts);
      _NSRunAlertPanel(pvVar4,pvVar3,pvVar2,0,0);
      _objc_msgSend(*(id *)PTR_00336058,sel_terminate_,self);
      self_00 = self->_applicationLicensor;
    }
  }
  pvVar3 = (id)(int)forced;
  iVar6 = (int)HSEditorController_validateApplicationLicenseWithInteraction;
  pvVar2 = _objc_msgSend(self_00,sel_validateApplicationLicenseWithInteraction_forced_,iVar6,pvVar3)
  ;
  cVar1 = (char)pvVar2;
  if (HSEditorController_validateApplicationLicenseWithInteraction != '\0') {
    if (cVar1 == '\0') {
      if (forced != '\0') {
        return '\0';
      }
      _objc_msgSend(self->_applicationLicensor,sel_release,iVar6,pvVar3);
      self->_applicationLicensor = (HSApplicationLicensor *)0x0;
      self_01 = *(HSEditorController **)PTR_00336058;
      op = sel_terminate_;
    }
    else {
      pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_mainMenu,iVar6,pvVar3);
      uVar8 = 0;
      pvVar2 = _objc_msgSend(pvVar2,sel_itemAtIndex_,0);
      pHVar5 = _objc_msgSend(pvVar2,sel_submenu);
      if (pHVar5 == (HSEditorController *)0x0) {
        return cVar1;
      }
      _objc_msgSend(self->_applicationLicensor,sel_licenseUsageTimeInfo,uVar8,pvVar3);
      pvVar3 = _objc_msgSend(self->_applicationLicensor,sel_licenseType);
      self_01 = self;
      op = sel_HSEditorController_updateMenu_licenseType_usageTimeFlags_;
      self = pHVar5;
    }
    _objc_msgSend(self_01,op,self,pvVar3);
  }
  return cVar1;
}

*/
- (BOOL)HSEditorController_validateApplicationLicenseWithInteraction:(BOOL)aInteraction forced:(BOOL)aForced
{
    // Licensing is intentionally not ported (HSApplicationLicensor stays untranslated): every launch is treated as licensed.
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00033d0e @ 00033d0e, 605 bytes * /

void FUN_00033d0e(HSEditorController *self,SEL _cmd,id HSEditorController_updateMenu,int licenseType
                 ,int usageTimeFlags)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL pcVar5;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  
  if (HSEditorController_updateMenu == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar9 = &cfstr_empty;
  uVar7 = 0;
  pcVar6 = pcVar9;
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Register_HyperStudio,
                         &cfstr_empty,0);
  pvVar2 = _objc_msgSend(HSEditorController_updateMenu,sel_indexOfItemWithTitle_,pvVar1);
  if (pvVar2 == (id)0xffffffff) {
    return;
  }
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar1,pcVar6,uVar7);
  pvVar2 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_Enter_Registration_Number,&cfstr_empty,0);
  pvVar3 = _objc_msgSend(HSEditorController_updateMenu,sel_indexOfItemWithTitle_,pvVar2);
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar8 = (cfstringStruct *)0x0;
  pcVar6 = pcVar9;
  pvVar4 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_Change_Registration_Number,&cfstr_empty,0);
  pvVar1 = _objc_msgSend(HSEditorController_updateMenu,sel_indexOfItemWithTitle_,pvVar4);
  pcVar5 = sel_insertItemWithTitle_action_keyEquivalent_atIndex_;
  if ((licenseType == 3) || (((usageTimeFlags & 1U) != 0 && (licenseType == 1)))) {
    pvVar4 = pvVar3;
    if (pvVar1 != (id)0xffffffff) {
      _objc_msgSend(HSEditorController_updateMenu,sel_removeItemAtIndex_,pvVar1,pcVar6,pcVar8);
      pcVar5 = sel_insertItemWithTitle_action_keyEquivalent_atIndex_;
    }
  }
  else {
    if ((char)(usageTimeFlags & 1U) == '\0' && licenseType != 2) {
      if (licenseType != 1) {
        return;
      }
      if (pvVar3 != (id)0xffffffff) {
        _objc_msgSend(HSEditorController_updateMenu,sel_removeItemAtIndex_,pvVar3,pcVar6,pcVar8);
      }
      pcVar5 = sel_removeItemAtIndex_;
      pcVar9 = pcVar8;
      if (pvVar1 == (id)0xffffffff) {
        return;
      }
      goto LAB_00033f5e;
    }
    pvVar2 = pvVar4;
    pvVar4 = pvVar1;
    if (pvVar3 != (id)0xffffffff) {
      _objc_msgSend(HSEditorController_updateMenu,sel_removeItemAtIndex_,pvVar3,pcVar6,pcVar8);
      pcVar5 = sel_insertItemWithTitle_action_keyEquivalent_atIndex_;
    }
  }
  pcVar6 = (cfstringStruct *)sel_enterSerialNumber_;
  pvVar1 = pvVar2;
  sel_insertItemWithTitle_action_keyEquivalent_atIndex_ = pcVar5;
  sel_enterSerialNumber_ = (undefined *)pcVar6;
  if (pvVar4 != (id)0xffffffff) {
    return;
  }
LAB_00033f5e:
  _objc_msgSend(HSEditorController_updateMenu,pcVar5,pvVar1,pcVar6,pcVar9);
  return;
}

*/
- (void)HSEditorController_updateMenu:(id)aMenu licenseType:(NSInteger)aType usageTimeFlags:(NSInteger)aFlags
{
    // Registration menu items are tied to the (unported) licensing code; nothing to update.
}

- (void)showLicenseInfo:(id)aInfo
{
    [_applicationLicensor showLicenseInfoDialog];
}

- (void)enterSerialNumber:(id)aNumber
{
    [self HSEditorController_validateApplicationLicenseWithInteraction:YES forced:YES];
}

- (void)techSupportForHyperStudio:(id)aStudio
{
    [_applicationLicensor createRequestWithURLString:[[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSTechSupportForHyperStudioURL" value:@"" table:@"HyperPlayerBase"]];
}

- (void)provideHyperStudioFeedback:(id)aFeedback
{
    HSApplicationLicensor *self_00;
    NSString *pvVar1_3;

    self_00 = _applicationLicensor;
    pvVar1_3 = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSProvideHyperStudioFeedbackURL" value:@"" table:@"HyperPlayerBase"]
    ;
    [self_00 createRequestWithURLString:pvVar1_3];
}

- (void)registerHyperStudio:(id)aStudio
{
    id self_00;

    self_00 = [_applicationLicensor showRegistrationDialogForceUI:YES isGoBack:nil];
    if ([self_00 count] != 0) {
        [[HSSubmitRequest sharedInstance] submitInformationDictionary:self_00];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000335c6 @ 000335c6, 1336 bytes * /

void FUN_000335c6(HSEditorController *self,SEL _cmd,id addReadyMadeCards)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  HSEditorController *self_00;
  id pvVar4;
  id pvVar5;
  SEL pcVar6;
  cfstringStruct *pcVar7;
  undefined4 uVar8;
  
  pvVar2 = _objc_msgSend(addReadyMadeCards,sel_representedObject);
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperResolveAliasAtPath_,pvVar2);
  if (pvVar3 == (id)0x0) {
    pvVar3 = pvVar2;
  }
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4);
  pvVar4 = pvVar3;
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperIsFileReadableAtPath_,pvVar3);
  pcVar6 = sel_addReadyMadeCardsFromPath_;
  if ((char)pvVar2 == '\0') {
    self_00 = _objc_msgSend(cls_HSAlert,sel_new,pvVar4);
    puVar1 = cls_NSString;
    pvVar4 = _objc_msgSend(pvVar3,sel_lastPathComponent);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_OtherStackMissingAlertMessage,&cfstr_empty,&cfstr_Alerts);
    pvVar4 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar2,pvVar4);
    _objc_msgSend(self_00,sel_setMessageText_,pvVar4);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_OtherStackMissingAlertInformativeText,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(self_00,sel_setInformativeText_,pvVar4);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_OtherStackMissingAlertFirstButtonTitle,&cfstr_empty,&cfstr_Alerts)
    ;
    _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar4);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar7 = &cfstr_empty;
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_OtherStackMissingAlertSecondButtonTitle,&cfstr_empty,&cfstr_Alerts
                          );
    _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar4);
    pvVar4 = (id)0x5;
    _objc_msgSend(self_00,sel_setAlertStyle_,5);
    pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    if (pvVar3 != (id)0x0) {
      pcVar7 = &cfstr_HSReadyMadeCardsUserInfoPathKey;
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,&cfstr_HSReadyMadeCardsUserInfoPathKey);
      pvVar4 = pvVar3;
    }
    pvVar3 = _objc_msgSend(self,sel_currentDocument,pvVar4,pcVar7);
    pvVar5 = _objc_msgSend(pvVar3,sel_windowForSheet);
    if (pvVar5 == (id)0x0) {
      pvVar3 = _objc_msgSend(self_00,sel_runModal,pvVar4,pcVar7);
      if (pvVar3 != (id)0x3e8) {
        return;
      }
      pvVar3 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
      _objc_msgSend(pvVar3,sel_setAllowsOtherFileTypes_,0);
      _objc_msgSend(pvVar3,sel_setAllowsMultipleSelection_,0);
      _objc_msgSend(pvVar3,sel_setCanChooseDirectories_,0);
      pcVar7 = &cfstr_stack;
      uVar8 = 0;
      pvVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSDocumentType,&cfstr_stack,0)
      ;
      _objc_msgSend(pvVar3,sel_setAllowedFileTypes_,pvVar4);
      puVar1 = cls_NSURL;
      if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
        pvVar4 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar4,pcVar7,uVar8);
        pvVar4 = _objc_msgSend(pvVar4,sel_hyperStudioDocumentsFolder);
        pcVar6 = sel_setDirectory_;
      }
      else {
        pvVar4 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar4,pcVar7,uVar8);
        pvVar4 = _objc_msgSend(pvVar4,sel_hyperStudioDocumentsFolder);
        pcVar7 = (cfstringStruct *)0x1;
        pvVar4 = _objc_msgSend(puVar1,sel_fileURLWithPath_isDirectory_,pvVar4,1);
        pcVar6 = sel_setDirectoryURL_;
      }
      _objc_msgSend(pvVar3,pcVar6,pvVar4,pcVar7);
      pvVar4 = _objc_msgSend(pvVar3,sel_runModal);
      _objc_msgSend(self,sel_findReadyMadeCardPanelDidEnd_returnCode_contextInfo_,pvVar3,pvVar4,
                    pvVar2);
      self = self_00;
      pcVar6 = sel_release;
    }
    else {
      pvVar3 = _objc_msgSend(pvVar3,sel_windowForSheet,pvVar4,pcVar7);
      self = self_00;
      pcVar6 = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
    }
  }
  _objc_msgSend(self,pcVar6,pvVar3);
  return;
}

*/
- (void)addReadyMadeCards:(id)aCards
{
    NSString *path = [aCards representedObject];
    NSString *resolved = [[NSFileManager defaultManager] hyperResolveAliasAtPath:path];
    if (resolved == nil) {
        resolved = path;
    }
    if ([[NSFileManager defaultManager] hyperIsFileReadableAtPath:resolved]) {
        [self addReadyMadeCardsFromPath:resolved];
        return;
    }
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[NSString stringWithFormat:[provider localizedStringForKey:@"OtherStackMissingAlertMessage" value:@"" table:@"Alerts"], [resolved lastPathComponent]]];
    [alert setInformativeText:[provider localizedStringForKey:@"OtherStackMissingAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OtherStackMissingAlertFirstButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OtherStackMissingAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
    [alert setAlertStyle:NSAlertStyleCritical];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    if (resolved != nil) {
        [info setObject:resolved forKey:@"HSReadyMadeCardsUserInfoPathKey"];
    }
    NSWindow *window = [[self currentDocument] windowForSheet];
    if (window != nil) {
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(missingReadyMadeCardAlertDidEnd:returnCode:contextInfo:) contextInfo:info];
        return;
    }
    if ([alert runModal] == 1000) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowsOtherFileTypes:NO];
        [panel setAllowsMultipleSelection:NO];
        [panel setCanChooseDirectories:NO];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"HSDocumentType", @"stack", nil]];
        [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder] isDirectory:YES]];
        NSInteger result = [panel runModal];
        [self findReadyMadeCardPanelDidEnd:panel returnCode:result contextInfo:info];
    } else {
        [info release];
    }
    [alert release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00033401 @ 00033401, 453 bytes * /

void FUN_00033401(HSEditorController *self,SEL _cmd,id findReadyMadeCardPanelDidEnd,int returnCode,
                 void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  undefined4 uVar3;
  undefined4 uVar4;
  
  if (returnCode == 1) {
    pvVar1 = _objc_msgSend(findReadyMadeCardPanelDidEnd,sel_URL);
    pvVar1 = _objc_msgSend(pvVar1,sel_path);
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    uVar4 = 0;
    uVar3 = 1;
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperIsReadableFileAtPath_showAlert_error_,pvVar1,1,0);
    if ((char)pvVar2 != '\0') {
      pvVar2 = pvVar1;
      _objc_msgSend(self,sel_addReadyMadeCardsFromPath_,pvVar1,uVar3,uVar4);
      op = sel_directory;
      if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
        findReadyMadeCardPanelDidEnd =
             _objc_msgSend(findReadyMadeCardPanelDidEnd,sel_directoryURL,pvVar2,uVar3,uVar4);
        op = sel_path;
      }
      pvVar2 = _objc_msgSend(findReadyMadeCardPanelDidEnd,op,pvVar2,uVar3,uVar4);
      self_00 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
      _objc_msgSend(self_00,sel_setHyperStudioDocumentsFolder_,pvVar2);
      pvVar2 = _objc_msgSend(contextInfo,sel_objectForKey_,&cfstr_HSReadyMadeCardsUserInfoPathKey);
      pvVar2 = _objc_msgSend(pvVar2,sel_lastPathComponent);
      _objc_msgSend(self,sel_storeSymbolicLinkToReadyMadeCardAtPath_withName_overwrite_,pvVar1,
                    pvVar2,1);
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar1,sel_postNotificationName_object_,*(undefined4 *)PTR_PTR_00336198,self);
    }
  }
  _objc_msgSend(contextInfo,sel_release);
  return;
}

*/
- (void)findReadyMadeCardPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == NSModalResponseOK) {
        NSString *path = [[aEnd URL] path];
        if ([[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:YES error:NULL]) {
            [self addReadyMadeCardsFromPath:path];
            NSString *directory = [[aEnd directoryURL] path];
            [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:directory];
            NSString *name = [[(NSDictionary *)aInfo objectForKey:@"HSReadyMadeCardsUserInfoPathKey"] lastPathComponent];
            [self storeSymbolicLinkToReadyMadeCardAtPath:path withName:name overwrite:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSReadyMadeCardsDidChange" object:self];
        }
    }
    [(id)aInfo release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003301d @ 0003301d, 738 bytes * /

void FUN_0003301d(HSEditorController *self,SEL _cmd,id missingReadyMadeCardAlertDidEnd,
                 int returnCode,void *contextInfo)

{
  undefined *self_00;
  id self_01;
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  undefined **ppuVar3;
  id pvVar4;
  undefined *local_34;
  undefined4 local_30;
  undefined4 local_2c;
  code *local_28;
  undefined *local_24;
  void *local_20;
  id local_1c;
  HSEditorController *local_18;
  
  if (returnCode == 1000) {
    self_01 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
    _objc_msgSend(self_01,sel_setAllowsMultipleSelection_,0);
    uVar2 = 0;
    _objc_msgSend(self_01,sel_setCanChooseDirectories_,0);
    self_00 = cls_NSURL;
    if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
      _objc_msgSend(contextInfo,sel_retain,uVar2);
      pvVar1 = _objc_msgSend(self,sel_currentDocument);
      _objc_msgSend(pvVar1,sel_windowForSheet);
      pvVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSDocumentType,&cfstr_stack,0)
      ;
      pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperStudioDocumentsFolder);
      ppuVar3 = (undefined **)0x0;
      op = 
      sel_beginSheetForDirectory_file_types_modalForWindow_modalDelegate_didEndSelector_contextInfo_
      ;
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,uVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperStudioDocumentsFolder);
      pvVar1 = _objc_msgSend(self_00,sel_fileURLWithPath_isDirectory_,pvVar1,1);
      _objc_msgSend(self_01,sel_setDirectoryURL_,pvVar1);
      pvVar4 = (id)0x0;
      pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSDocumentType,&cfstr_stack,0)
      ;
      _objc_msgSend(self_01,sel_setAllowedFileTypes_,pvVar1);
      _objc_msgSend(self_01,sel_setNameFieldStringValue_,0);
      local_34 = PTR_003361cc;
      local_30 = 0x42000000;
      local_2c = 0;
      local_28 = FUN_000332ff;
      local_24 = &DAT_00341c70;
      local_20 = contextInfo;
      local_18 = self;
      local_1c = self_01;
      pvVar1 = _objc_msgSend(self,sel_currentDocument);
      pvVar1 = _objc_msgSend(pvVar1,sel_windowForSheet);
      ppuVar3 = &local_34;
      op = sel_beginSheetModalForWindow_completionHandler_;
    }
    _objc_msgSend(self_01,op,pvVar1,ppuVar3,pvVar4);
  }
  _objc_msgSend(contextInfo,sel_release);
  _objc_msgSend(missingReadyMadeCardAlertDidEnd,sel_release);
  return;
}

*/
- (void)missingReadyMadeCardAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowsMultipleSelection:NO];
        [panel setCanChooseDirectories:NO];
        [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder] isDirectory:YES]];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"HSDocumentType", @"stack", nil]];
        [panel setNameFieldStringValue:@""];
        id contextInfo = (id)aInfo;
        [contextInfo retain];
        [panel beginSheetModalForWindow:[[self currentDocument] windowForSheet] completionHandler:^(NSModalResponse result) {
            [self findReadyMadeCardPanelDidEnd:panel returnCode:result contextInfo:contextInfo];
        }];
    }
    [(id)aInfo release];
    [aEnd release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000328a5 @ 000328a5, 1912 bytes * /

void FUN_000328a5(HSEditorController *self,SEL _cmd,id addReadyMadeCardsFromPath)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id self_02;
  cfstringStruct *pcVar9;
  HSEditorController *self_03;
  undefined4 extraout_EDX;
  SEL pcVar10;
  undefined4 uVar11;
  id local_28;
  id local_14;
  
  local_14 = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  if (pvVar1 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_openUntitledDocumentAndDisplay_error_,0,&local_14);
    local_28 = _objc_msgSend(pvVar2,sel_retain);
    pvVar2 = local_28;
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSEditorDocument,sel_alloc);
    local_28 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = pvVar1;
  }
  pvVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,addReadyMadeCardsFromPath);
  pcVar9 = (cfstringStruct *)&local_14;
  pcVar4 = _objc_msgSend(self,sel_typeForContentsOfURL_error_,pvVar3,pcVar9);
  if (local_14 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,addReadyMadeCardsFromPath,pcVar9);
    _objc_msgSend(local_28,sel_readFromURL_ofType_error_,pvVar3,pcVar4,&local_14);
    pcVar9 = pcVar4;
  }
  if (local_14 == (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar2,sel_undoManager,pvVar3,pcVar9);
    pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar9 = &cfstr_UndoManager;
    pcVar4 = &cfstr_empty;
    pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_Add_Ready_Made_Cards
                           ,&cfstr_empty,&cfstr_UndoManager);
    _objc_msgSend(pvVar3,sel_setMultipleActionsName_,pvVar5);
    pvVar3 = _objc_msgSend(pvVar2,sel_isNewAndNotChanged);
    pvVar6 = _objc_msgSend(pvVar2,sel_stack);
    if (pvVar1 == (id)0x0) {
      pvVar6 = _objc_msgSend(pvVar2,sel_createDefaultStack,pvVar5,pcVar4,pcVar9);
    }
    if ((char)pvVar3 == '\0') {
      pvVar5 = _objc_msgSend(local_28,sel_stack,pvVar5);
      pvVar3 = pvVar2;
    }
    else {
      _objc_msgSend(pvVar6,sel_removeHyperAllChildren,pvVar5);
      pvVar3 = local_28;
      pvVar5 = pvVar6;
    }
    pvVar3 = _objc_msgSend(pvVar3,sel_stack);
    pvVar7 = _objc_msgSend(pvVar3,sel_hyperCardSize);
    _objc_msgSend(pvVar5,sel_setHyperCardSize_,pvVar7,extraout_EDX);
    pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar8 = _objc_msgSend(cls_NSMutableSet,sel_set);
    pvVar3 = _objc_msgSend(local_28,sel_stack);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperChildren);
    self_02 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    pvVar3 = _objc_msgSend(self_02,sel_nextObject);
    self_00 = cls_NSBundle;
    self_01 = cls_NSDictionary;
    while (cls_NSBundle = self_00, cls_NSDictionary = self_01, pvVar3 != (id)0x0) {
      pvVar7 = _objc_msgSend(self,sel_class,pvVar7);
      pvVar7 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar7);
      pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                             &cfstr_HSReadyMadeCardsDefaultTitle,&cfstr_empty,&cfstr_Localizable);
      _objc_msgSend(pvVar3,sel_setHyperTitle_,pvVar7);
      pvVar7 = _objc_msgSend(pvVar3,sel_fullDictionaryRepresentation);
      _objc_msgSend(pvVar5,sel_addObject_,pvVar7);
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003625b4);
      pvVar7 = _objc_msgSend(pvVar3,sel_mediaUIDs);
      _objc_msgSend(pvVar8,sel_unionSet_);
      pvVar3 = _objc_msgSend(self_02,sel_nextObject);
      self_00 = cls_NSBundle;
      self_01 = cls_NSDictionary;
    }
    pvVar3 = _objc_msgSend(pvVar8,sel_allObjects,pvVar7);
    pvVar7 = _objc_msgSend(pvVar3,sel_extraPlistRepresentation);
    pcVar9 = &cfstr_HSSerializedCardsMediaUIDsKey;
    pcVar4 = &cfstr_HSSerializedCardsKey;
    uVar11 = 0;
    pvVar3 = _objc_msgSend(self_01,sel_dictionaryWithObjectsAndKeys_,pvVar5,
                           &cfstr_HSSerializedCardsKey,pvVar7,&cfstr_HSSerializedCardsMediaUIDsKey,0
                          );
    pvVar8 = _objc_msgSend(pvVar2,sel_editorWindowController);
    pvVar8 = _objc_msgSend(pvVar8,sel_selectedCard);
    if (pvVar8 == (id)0x0) {
      pvVar5 = _objc_msgSend(self,sel_activeCard,pvVar5,pcVar4,pvVar7,pcVar9,uVar11);
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperIndex);
      self_03 = self;
      pcVar10 = sel_activeCard;
      if (pvVar5 != (id)0x7fffffff) goto LAB_00032f23;
LAB_00032ec3:
      pcVar9 = (cfstringStruct *)0x0;
    }
    else {
      pvVar5 = _objc_msgSend(pvVar2,sel_editorWindowController,pvVar5,pcVar4,pvVar7,pcVar9,uVar11);
      pvVar5 = _objc_msgSend(pvVar5,sel_selectedCard);
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperIndex);
      if (pvVar5 == (id)0x7fffffff) goto LAB_00032ec3;
      self_03 = _objc_msgSend(pvVar2,sel_editorWindowController);
      pcVar10 = sel_selectedCard;
LAB_00032f23:
      pvVar5 = _objc_msgSend(self_03,pcVar10);
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperIndex);
      pcVar9 = (cfstringStruct *)((int)pvVar5 + 1);
    }
    pvVar5 = _objc_msgSend(pvVar6,sel_insertCards_atIndex_,pvVar3,pcVar9);
    pvVar6 = _objc_msgSend(pvVar5,sel_count);
    if (pvVar6 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar2,sel_mainWindowController,pvVar3,pcVar9);
      pvVar3 = _objc_msgSend(pvVar5,sel_objectAtIndex_,0);
      _objc_msgSend(pvVar2,sel_setActiveCard_,pvVar3);
    }
    if (pvVar1 != (id)0x0) goto LAB_00033000;
    pvVar3 = local_28;
    _objc_msgSend(self,sel_addDocument_,local_28,pcVar9);
    _objc_msgSend(local_28,sel_makeWindowControllers);
    pcVar10 = sel_showWindows;
  }
  else {
    pvVar2 = _objc_msgSend(local_14,sel_code,pvVar3,pcVar9);
    if (pvVar2 == (id)0x4e36) {
      pvVar2 = _objc_msgSend(cls_HSAlert,sel_new,pvVar3,pcVar9);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_Cannot_create_a_Ready_Made_Card,&cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar2,sel_setMessageText_,pvVar3);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar9 = &cfstr_empty;
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_There_is_not_enough_disk_space_to_add_a_Ready_Ma,&cfstr_empty,
                             &cfstr_Alerts);
      _objc_msgSend(pvVar2,sel_setInformativeText_,pvVar3);
      _objc_msgSend(pvVar2,sel_runModal);
      _objc_msgSend(pvVar2,sel_release);
    }
    if ((pvVar1 != (id)0x0) || (pcVar10 = sel_close, local_28 == (id)0x0)) goto LAB_00033000;
  }
  _objc_msgSend(local_28,pcVar10,pvVar3);
LAB_00033000:
  _objc_msgSend(local_28,sel_release,pvVar3,pcVar9);
  return;
}

*/
- (void)addReadyMadeCardsFromPath:(id)aPath
{
    NSError *error = nil;
    HSEditorDocument *currentDocument = [self currentDocument];
    HSEditorDocument *document;
    HSEditorDocument *readDocument;
    if (currentDocument == nil) {
        readDocument = [[self openUntitledDocumentAndDisplay:NO error:&error] retain];
        document = readDocument;
    } else {
        readDocument = [[HSEditorDocument alloc] init];
        document = currentDocument;
    }
    NSString *type = [self typeForContentsOfURL:[NSURL fileURLWithPath:aPath] error:&error];
    if (error == nil) {
        [readDocument readFromURL:[NSURL fileURLWithPath:aPath] ofType:type error:&error];
    }
    if (error == nil) {
        [[document undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Ready Made Cards" value:@"" table:@"UndoManager"]];
        BOOL isNewAndNotChanged = [document isNewAndNotChanged];
        HSStack *documentStack = [document stack];
        if (currentDocument == nil) {
            documentStack = [document createDefaultStack];
        }
        HSStack *sizedStack;
        HSEditorDocument *sizeSource;
        if (!isNewAndNotChanged) {
            sizedStack = [readDocument stack];
            sizeSource = document;
        } else {
            [documentStack removeHyperAllChildren];
            sizedStack = documentStack;
            sizeSource = readDocument;
        }
        [sizedStack setHyperCardSize:[[sizeSource stack] hyperCardSize]];
        NSMutableArray *cardDictionaries = [NSMutableArray array];
        NSMutableSet *mediaUIDs = [NSMutableSet set];
        NSEnumerator *cards = [[[readDocument stack] hyperChildren] objectEnumerator];
        id card;
        while ((card = [cards nextObject]) != nil) {
            [card setHyperTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSReadyMadeCardsDefaultTitle" value:@"" table:@"Localizable"]];
            [cardDictionaries addObject:[card fullDictionaryRepresentation]];
            [mediaUIDs unionSet:[[card queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs]];
        }
        NSDictionary *serialized = [NSDictionary dictionaryWithObjectsAndKeys:cardDictionaries, @"HSSerializedCardsKey", [[mediaUIDs allObjects] extraPlistRepresentation], @"HSSerializedCardsMediaUIDsKey", nil];
        NSUInteger insertIndex;
        id selectedCard = [[document editorWindowController] selectedCard];
        if (selectedCard == nil) {
            id activeCard = [self activeCard];
            insertIndex = ([activeCard hyperIndex] == NSNotFound) ? 0 : [[self activeCard] hyperIndex] + 1;
        } else {
            insertIndex = ([[[document editorWindowController] selectedCard] hyperIndex] == NSNotFound) ? 0 : [[[document editorWindowController] selectedCard] hyperIndex] + 1;
        }
        NSArray *inserted = [documentStack insertCards:serialized atIndex:insertIndex];
        if ([inserted count] != 0) {
            [[document mainWindowController] setActiveCard:[inserted objectAtIndex:0]];
        }
        if (currentDocument == nil) {
            [self addDocument:readDocument];
            [readDocument makeWindowControllers];
            [readDocument showWindows];
        }
    } else {
        if ([error code] == 0x4e36) {
            HSAlert *alert = [HSAlert new];
            [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot create a Ready Made Card" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There is not enough disk space to add a Ready Made Card to your stack. Free some disk space and try again." value:@"" table:@"Alerts"]];
            [alert runModal];
            [alert release];
        }
        if (currentDocument == nil && readDocument != nil) {
            [readDocument close];
        }
    }
    [readDocument release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00032837 @ 00032837, 110 bytes * /

id FUN_00032837(HSEditorController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  if ((pvVar1 != (id)0x0) &&
     (pvVar2 = _objc_msgSend(pvVar1,sel_isInStoryboardMode), (char)pvVar2 == '\0')) {
    pvVar1 = _objc_msgSend(pvVar1,sel_editorWindowController);
    pvVar1 = _objc_msgSend(pvVar1,sel_activeCard);
    return pvVar1;
  }
  return (id)0x0;
}

*/
- (id)activeCard
{
    HSEditorDocument *document = [self currentDocument];
    if (document != nil && ![document isInStoryboardMode]) {
        return [[document editorWindowController] activeCard];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003250b @ 0003250b, 812 bytes * /

void FUN_0003250b(HSEditorController *self,SEL _cmd,id saveAsReadyMadeCardPanelDidEnd,int returnCode
                 ,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  SEL op;
  HSEditorController *pHVar6;
  undefined4 uVar7;
  
  _objc_msgSend(*(id *)PTR_00336058,sel_endSheet_,saveAsReadyMadeCardPanelDidEnd);
  pHVar6 = self;
  _objc_msgSend(saveAsReadyMadeCardPanelDidEnd,sel_orderOut_,self);
  if (returnCode != 1) {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pHVar6);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperStudioDocumentsFolder);
  pvVar2 = _objc_msgSend(self,sel_currentDocument);
  pvVar3 = _objc_msgSend(saveAsReadyMadeCardPanelDidEnd,sel_URL);
  pcVar5 = &cfstr_HSDocumentType;
  uVar7 = 1;
  _objc_msgSend(pvVar2,sel_saveToURL_ofType_forSaveOperation_delegate_didSaveSelector_contextInfo_,
                pvVar3,&cfstr_HSDocumentType,1,0,0,0);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  _objc_msgSend(pvVar2,sel_setHyperStudioDocumentsFolder_,pvVar1);
  pvVar2 = _objc_msgSend(saveAsReadyMadeCardPanelDidEnd,sel_URL);
  pvVar2 = _objc_msgSend(pvVar2,sel_path);
  pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar3 = _objc_msgSend(pvVar3,sel_isSandboxed);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = pvVar2;
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperIsFileWritableAtPath_,pvVar2);
    if ((char)pvVar3 == '\0') {
      return;
    }
  }
  op = sel_directory;
  if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
    saveAsReadyMadeCardPanelDidEnd =
         _objc_msgSend(saveAsReadyMadeCardPanelDidEnd,sel_directoryURL,pvVar1);
    op = sel_path;
  }
  pvVar3 = _objc_msgSend(saveAsReadyMadeCardPanelDidEnd,op,pvVar1);
  pvVar4 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar4 = _objc_msgSend(pvVar4,sel_isSandboxed);
  if ((char)pvVar4 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pvVar1 = _objc_msgSend(pvVar1,sel_readyMadeCardsSupportFolder);
    pvVar4 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar1);
    if ((char)pvVar4 != '\0') goto LAB_000327f2;
    pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_readyMadeCardsLocalSupportFolder);
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar1);
    if ((char)pvVar3 != '\0') goto LAB_000327f2;
  }
  pcVar5 = _objc_msgSend(pvVar2,sel_lastPathComponent,pvVar1);
  uVar7 = 0;
  _objc_msgSend(self,sel_storeSymbolicLinkToReadyMadeCardAtPath_withName_overwrite_,pvVar2,pcVar5,0)
  ;
  pvVar1 = pvVar2;
LAB_000327f2:
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar1,pcVar5,uVar7);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,*(undefined4 *)PTR_PTR_00336198,self);
  return;
}

*/
- (void)saveAsReadyMadeCardPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [NSApp endSheet:aEnd];
    [aEnd orderOut:self];
    if (aCode != NSModalResponseOK) {
        return;
    }
    NSString *documentsFolder = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder];
    [[self currentDocument] saveToURL:[aEnd URL] ofType:@"HSDocumentType" forSaveOperation:NSSaveAsOperation delegate:nil didSaveSelector:NULL contextInfo:NULL];
    [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:documentsFolder];
    NSString *path = [[aEnd URL] path];
    BOOL sandboxed = [[HSSystem sharedSystem] isSandboxed];
    if (!sandboxed && ![[NSFileManager defaultManager] hyperIsFileWritableAtPath:path]) {
        return;
    }
    NSString *directory = [[aEnd directoryURL] path];
    BOOL skipLink = NO;
    if (!sandboxed) {
        skipLink = [directory isEqualToString:[[HSPathsProvider sharedPathsProvider] readyMadeCardsSupportFolder]]
            || [directory isEqualToString:[[HSPathsProvider sharedPathsProvider] readyMadeCardsLocalSupportFolder]];
    }
    if (!skipLink) {
        [self storeSymbolicLinkToReadyMadeCardAtPath:path withName:[path lastPathComponent] overwrite:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSReadyMadeCardsDidChange" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000320e1 @ 000320e1, 874 bytes * /

void FUN_000320e1(HSEditorController *self,SEL _cmd,id saveAsReadyMadeCard)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined **ppuVar4;
  id pvVar5;
  SEL op;
  undefined4 uVar6;
  undefined *local_2c;
  undefined4 local_28;
  undefined4 local_24;
  code *local_20;
  undefined *local_1c;
  id local_18;
  HSEditorController *local_14;
  
  self_00 = _objc_msgSend(cls_NSSavePanel,sel_savePanel);
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_stack);
  _objc_msgSend(self_00,sel_setAllowedFileTypes_,pvVar1);
  pvVar2 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar2 = _objc_msgSend(pvVar2,sel_isSandboxed);
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSSavePanelAccessoryViewController,sel_alloc,pvVar1);
    pvVar2 = _objc_msgSend(pvVar1,sel_initWithNibName_,&cfstr_SaveAsReadyMadeAccessoryView);
    pvVar1 = _objc_msgSend(pvVar2,sel_accessoryView);
    _objc_msgSend(self_00,sel_setAccessoryView_,pvVar1);
    _objc_msgSend(pvVar2,sel_release);
  }
  pvVar2 = _objc_msgSend(self,sel_currentDocument,pvVar1);
  pvVar3 = _objc_msgSend(pvVar2,sel_fileURL);
  pvVar3 = _objc_msgSend(pvVar3,sel_path);
  pvVar3 = _objc_msgSend(pvVar3,sel_lastPathComponent);
  ppuVar4 = _objc_msgSend(pvVar3,sel_stringByDeletingPathExtension);
  pvVar3 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_readyMadeCardsSupportFolder);
  if (pvVar3 != (id)0x0) {
    pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = pvVar3;
    _objc_msgSend(pvVar5,sel_createDirectoryAtPath_attributes_createIntermediate_,pvVar3,0,1);
  }
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar5 = _objc_msgSend(pvVar2,sel_currentWindowController,pvVar1);
    _objc_msgSend(pvVar5,sel_window);
    op = sel_beginSheetForDirectory_file_modalForWindow_modalDelegate_didEndSelector_contextInfo_;
    if (ppuVar4 == (undefined **)0x0) {
      ppuVar4 = _objc_msgSend(pvVar2,sel_displayName,pvVar1);
      op = sel_beginSheetForDirectory_file_modalForWindow_modalDelegate_didEndSelector_contextInfo_;
    }
  }
  else {
    uVar6 = 1;
    pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar3,1);
    _objc_msgSend(self_00,sel_setDirectoryURL_,pvVar1);
    if (ppuVar4 == (undefined **)0x0) {
      ppuVar4 = _objc_msgSend(pvVar2,sel_displayName,pvVar1,uVar6);
    }
    _objc_msgSend(self_00,sel_setNameFieldStringValue_,ppuVar4,uVar6);
    local_2c = PTR_003361cc;
    local_28 = 0x42000000;
    local_24 = 0;
    local_20 = FUN_0003244b;
    local_1c = &DAT_00341c50;
    local_14 = self;
    local_18 = self_00;
    pvVar1 = _objc_msgSend(pvVar2,sel_currentWindowController);
    pvVar3 = _objc_msgSend(pvVar1,sel_window);
    ppuVar4 = &local_2c;
    op = sel_beginSheetModalForWindow_completionHandler_;
  }
  _objc_msgSend(self_00,op,pvVar3,ppuVar4);
  return;
}

*/
- (void)saveAsReadyMadeCard:(id)aCard
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"stack"]];
    if (![[HSSystem sharedSystem] isSandboxed]) {
        HSSavePanelAccessoryViewController *accessory = [[HSSavePanelAccessoryViewController alloc] initWithNibName:@"SaveAsReadyMadeAccessoryView"];
        [panel setAccessoryView:[accessory accessoryView]];
        [accessory release];
    }
    HSEditorDocument *document = [self currentDocument];
    NSString *name = [[[[document fileURL] path] lastPathComponent] stringByDeletingPathExtension];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] readyMadeCardsSupportFolder];
    if (folder != nil) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    if (name == nil) {
        name = [document displayName];
    }
    [panel setNameFieldStringValue:name];
    [panel beginSheetModalForWindow:[[document currentWindowController] window] completionHandler:^(NSModalResponse result) {
        [self saveAsReadyMadeCardPanelDidEnd:panel returnCode:result contextInfo:NULL];
    }];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031ece @ 00031ece, 531 bytes * /

void FUN_00031ece(HSEditorController *self,SEL _cmd,id storeSymbolicLinkToReadyMadeCardAtPath,
                 id withName,BOOL overwrite)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  int iVar6;
  int iVar7;
  id local_28;
  
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar1,sel_readyMadeCardsSupportFolder);
  pvVar3 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithPath_,pvVar2);
  local_28 = withName;
  self_00 = _objc_msgSend(pvVar3,sel_fileWrappers);
  if (overwrite == '\0') {
    pvVar1 = _objc_msgSend(withName,sel_stringByDeletingPathExtension,pvVar1);
    pvVar4 = _objc_msgSend(withName,sel_pathExtension);
    pvVar5 = _objc_msgSend(self_00,sel_objectForKey_,withName);
    if (pvVar5 != (id)0x0) {
      iVar6 = 1;
      do {
        iVar7 = iVar6;
        withName = _objc_msgSend(pvVar1,sel_stringByAppendingFormat_,&cfstr__i,iVar6);
        if (pvVar4 != (id)0x0) {
          withName = _objc_msgSend(withName,sel_stringByAppendingPathExtension_,pvVar4,iVar7);
        }
        iVar6 = iVar6 + 1;
        pvVar5 = _objc_msgSend(self_00,sel_objectForKey_,withName,iVar7);
      } while (pvVar5 != (id)0x0);
    }
    if (withName != (id)0x0) {
      local_28 = withName;
    }
  }
  else {
    pvVar1 = _objc_msgSend(self_00,sel_objectForKey_,withName);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_removeFileWrapper_,pvVar1);
    }
  }
  _objc_msgSend(pvVar3,sel_addSymbolicLinkWithDestination_preferredFilename_,
                storeSymbolicLinkToReadyMadeCardAtPath,local_28);
  _objc_msgSend(pvVar3,sel_writeToFile_atomically_updateFilenames_,pvVar2,1,1);
  _objc_msgSend(pvVar3,sel_release);
  return;
}

*/
- (void)storeSymbolicLinkToReadyMadeCardAtPath:(id)aPath withName:(id)aName overwrite:(BOOL)aOverwrite
{
    NSString *supportFolder = [[HSPathsProvider sharedPathsProvider] readyMadeCardsSupportFolder];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath:supportFolder];
    NSDictionary *wrappers = [wrapper fileWrappers];
    NSString *name = aName;
    if (!aOverwrite) {
        NSString *base = [aName stringByDeletingPathExtension];
        NSString *extension = [aName pathExtension];
        if ([wrappers objectForKey:aName] != nil) {
            int index = 1;
            NSString *candidate;
            do {
                candidate = [base stringByAppendingFormat:@"%i", index];
                if (extension != nil) {
                    candidate = [candidate stringByAppendingPathExtension:extension];
                }
                index++;
            } while ([wrappers objectForKey:candidate] != nil);
            aName = candidate;
        }
        if (aName != nil) {
            name = aName;
        }
    } else {
        NSFileWrapper *existing = [wrappers objectForKey:aName];
        if (existing != nil) {
            [wrapper removeFileWrapper:existing];
        }
    }
    [wrapper addSymbolicLinkWithDestination:aPath preferredFilename:name];
    [wrapper writeToFile:supportFolder atomically:YES updateFilenames:YES];
    [wrapper release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031e73 @ 00031e73, 91 bytes * /

void FUN_00031e73(HSEditorController *self,SEL _cmd,int setOnionSkinMode)

{
  id self_00;
  
  if (*(int *)((int)&self->_documentsInPurePlayerAndPresentationModesCount + 3) != setOnionSkinMode)
  {
    *(int *)((int)&self->_documentsInPurePlayerAndPresentationModesCount + 3) = setOnionSkinMode;
    self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(self_00,sel_postNotificationName_object_,
                  &cfstr_HSOnionSkinModeDidChangeNotification,self);
  }
  return;
}

*/
- (void)setOnionSkinMode:(NSInteger)aMode
{
    if (_onionSkinMode != aMode) {
        _onionSkinMode = (int)aMode;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSOnionSkinModeDidChangeNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da75 @ 0002da75, 11 bytes * /

int FUN_0002da75(HSEditorController *self,SEL _cmd)

{
  return *(int *)((int)&self->_documentsInPurePlayerAndPresentationModesCount + 3);
}

*/
- (NSInteger)onionSkinMode
{
    return _onionSkinMode;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031e0e @ 00031e0e, 101 bytes * /

void FUN_00031e0e(HSEditorController *self,SEL _cmd,id runEmbedCodeForStackDialog)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_HSEmbedCodeForStackDialogController,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_init);
  _objc_msgSend(pvVar1,sel_runModal);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)runEmbedCodeForStackDialog:(id)aDialog
{
    id controller = [[HSEmbedCodeForStackDialogController alloc] init];
    [controller runModal];
    [controller release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031d8f @ 00031d8f, 127 bytes * /

void FUN_00031d8f(HSEditorController *self,SEL _cmd,id setOnionSkin)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(setOnionSkin,sel_tag);
  _objc_msgSend(self,sel_setOnionSkinMode_,pvVar1);
  self_00 = _objc_msgSend(self,sel_currentDocument);
  pvVar2 = _objc_msgSend(self_00,sel_isInPlayerMode);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self_00,sel_switchToEditor,pvVar1);
  }
  return;
}

*/
- (void)setOnionSkin:(id)aSkin
{
    [self setOnionSkinMode:[aSkin tag]];
    HSEditorDocument *document = [self currentDocument];
    if ([document isInPlayerMode]) {
        [document switchToEditor];
    }
}

- (void)paste:(id)aPaste
{
    if ([[NSPasteboard generalPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] != nil) {
        [[[self openUntitledDocumentAndDisplay:YES error:0] editorWindowController] paste:aPaste];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031c48 @ 00031c48, 140 bytes * /

void FUN_00031c48(HSEditorController *self,SEL _cmd,id sameBackground)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  op = sel_openUntitledDocumentAndDisplay_error_;
  if (pvVar1 != (id)0x0) {
    op = sel_currentDocument;
  }
  pvVar1 = _objc_msgSend(self,op);
  pvVar1 = _objc_msgSend(pvVar1,sel_editorWindowController);
  _objc_msgSend(pvVar1,sel_sameBackground_,sameBackground);
  return;
}

*/
- (void)sameBackground:(id)aBackground
{
    id document = [self currentDocument] != nil ? [self currentDocument] : [self openUntitledDocumentAndDisplay:YES error:NULL];
    [[document editorWindowController] sameBackground:aBackground];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031bbc @ 00031bbc, 140 bytes * /

void FUN_00031bbc(HSEditorController *self,SEL _cmd,id makeGroupCard)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  op = sel_openUntitledDocumentAndDisplay_error_;
  if (pvVar1 != (id)0x0) {
    op = sel_currentDocument;
  }
  pvVar1 = _objc_msgSend(self,op);
  pvVar1 = _objc_msgSend(pvVar1,sel_editorWindowController);
  _objc_msgSend(pvVar1,sel_makeGroupCard_,makeGroupCard);
  return;
}

*/
- (void)makeGroupCard:(id)aCard
{
    id document = [self currentDocument] != nil ? [self currentDocument] : [self openUntitledDocumentAndDisplay:YES error:NULL];
    [[document editorWindowController] makeGroupCard:aCard];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031b62 @ 00031b62, 90 bytes * /

void FUN_00031b62(HSEditorController *self,SEL _cmd,id newCard)

{
  HSEditorController *pHVar1;
  SEL op;
  
  pHVar1 = _objc_msgSend(self,sel_currentDocument);
  op = sel_newDocument_;
  if (pHVar1 != (HSEditorController *)0x0) {
    self = pHVar1;
    op = sel_newCard_;
  }
  _objc_msgSend(self,op,newCard);
  return;
}

*/
- (void)newCard:(id)aCard
{
    HSEditorDocument *document = [self currentDocument];
    if (document != nil) {
        [document newCard:aCard];
    } else {
        [self newDocument:aCard];
    }
}

- (void)goToHomeWithoutLeaveActions:(id)aActions
{
    [[self defaultNavigationControllerClass] goToHomeStack];
}

- (void)openReferenceGuide:(id)aGuide
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] pathForResource:@"HyperStudio 5 Reference Guide" ofType:@"pdf"];
    [[NSWorkspace sharedWorkspace] openFile:pvVar1_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000316ec @ 000316ec, 822 bytes * /

void FUN_000316ec(HSEditorController *self,SEL _cmd,id importFromKeynote)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  id *ppvVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  _objc_msgSend(pvVar1,sel_setAllowsOtherFileTypes_,0);
  _objc_msgSend(pvVar1,sel_setCanChooseDirectories_,0);
  _objc_msgSend(pvVar1,sel_setAllowsMultipleSelection_,0);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_ImportKeynotePrompt,
                         &cfstr_empty,0);
  _objc_msgSend(pvVar1,sel_setPrompt_,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar4 = &cfstr_empty;
  ppvVar5 = (id *)0x0;
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_ImportKeynoteMessage,
                         &cfstr_empty,0);
  _objc_msgSend(pvVar1,sel_setMessage_,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_key);
  _objc_msgSend(pvVar1,sel_setAllowedFileTypes_,pvVar2);
  self_00 = cls_NSURL;
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar2,pcVar4,ppvVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_keynoteDocumentsImportFolder);
    op = sel_setDirectory_;
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar2,pcVar4,ppvVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_keynoteDocumentsImportFolder);
    pcVar4 = (cfstringStruct *)0x1;
    pvVar2 = _objc_msgSend(self_00,sel_fileURLWithPath_isDirectory_,pvVar2,1);
    op = sel_setDirectoryURL_;
  }
  _objc_msgSend(pvVar1,op,pvVar2,pcVar4);
  pvVar3 = _objc_msgSend(pvVar1,sel_runModal);
  if (pvVar3 == (id)0x1) {
    pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar2,pcVar4);
    pvVar3 = _objc_msgSend(pvVar1,sel_URL);
    pvVar3 = _objc_msgSend(pvVar3,sel_path);
    pvVar3 = _objc_msgSend(pvVar3,sel_stringByDeletingLastPathComponent);
    _objc_msgSend(pvVar2,sel_setKeynoteDocumentsImportFolder_,pvVar3);
    local_14 = (id)0x0;
    pvVar2 = _objc_msgSend(pvVar1,sel_URL);
    ppvVar5 = &local_14;
    pcVar4 = (cfstringStruct *)0x1;
    _objc_msgSend(self,sel_openDocumentWithContentsOfURL_display_error_,pvVar2,1,ppvVar5);
    if (local_14 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager,pvVar2,pcVar4,ppvVar5);
      pvVar2 = local_14;
      _objc_msgSend(pvVar3,sel_presentError_,local_14);
    }
  }
  _objc_msgSend(pvVar1,sel_release,pvVar2,pcVar4,ppvVar5);
  return;
}

*/
- (void)importFromKeynote:(id)aKeynote
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    [panel setAllowsOtherFileTypes:NO];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"ImportKeynotePrompt" value:@"" table:nil]];
    [panel setMessage:[[NSBundle mainBundle] localizedStringForKey:@"ImportKeynoteMessage" value:@"" table:nil]];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"key"]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] keynoteDocumentsImportFolder] isDirectory:YES]];
    if ([panel runModal] == NSModalResponseOK) {
        [[HSPathsProvider sharedPathsProvider] setKeynoteDocumentsImportFolder:[[[panel URL] path] stringByDeletingLastPathComponent]];
        NSError *error = nil;
        [self openDocumentWithContentsOfURL:[panel URL] display:YES error:&error];
        if (error != nil) {
            [[HSErrorManager sharedErrorManager] presentError:error];
        }
    }
    [panel release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003162d @ 0003162d, 191 bytes * /

void FUN_0003162d(HSEditorController *self,SEL _cmd,id toggleCoverDesktop)

{
  undefined4 uVar1;
  undefined *puVar2;
  id pvVar3;
  id self_00;
  
  pvVar3 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  puVar2 = PTR_003361a4;
  pvVar3 = _objc_msgSend(pvVar3,sel_settingsForKey_,*(undefined4 *)PTR_003361a4);
  pvVar3 = _objc_msgSend(pvVar3,sel_boolValue);
  self_00 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  uVar1 = *(undefined4 *)puVar2;
  pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)((char)pvVar3 == '\0'));
  _objc_msgSend(self_00,sel_setSettings_forKey_,pvVar3,uVar1);
  return;
}

*/
- (void)toggleCoverDesktop:(id)aDesktop
{
    BOOL enabled = [[[HSUI sharedUI] settingsForKey:HSUIModeIsCoverDesktopEnabled] boolValue];
    [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:!enabled] forKey:HSUIModeIsCoverDesktopEnabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003156e @ 0003156e, 191 bytes * /

void FUN_0003156e(HSEditorController *self,SEL _cmd,id hideShowToolbar)

{
  undefined4 uVar1;
  undefined *puVar2;
  id pvVar3;
  id self_00;
  
  pvVar3 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  puVar2 = PTR_0033612c;
  pvVar3 = _objc_msgSend(pvVar3,sel_settingsForKey_,*(undefined4 *)PTR_0033612c);
  pvVar3 = _objc_msgSend(pvVar3,sel_boolValue);
  self_00 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  uVar1 = *(undefined4 *)puVar2;
  pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)((char)pvVar3 == '\0'));
  _objc_msgSend(self_00,sel_setSettings_forKey_,pvVar3,uVar1);
  return;
}

*/
- (void)hideShowToolbar:(id)aToolbar
{
    BOOL enabled = [[[HSUI sharedUI] settingsForKey:HSUIModeIsToolbarShown] boolValue];
    [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:!enabled] forKey:HSUIModeIsToolbarShown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000314e7 @ 000314e7, 135 bytes * /

void FUN_000314e7(HSEditorController *self,SEL _cmd,id togglePresentationModeButton)

{
  id pvVar1;
  undefined **ppuVar2;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar1 = _objc_msgSend(pvVar1,sel_boolForKey_,&cfstr_HSPresentationModeButtonSwitchesPlayerMode);
  ppuVar2 = &sel_togglePlayerMode_;
  if ((char)pvVar1 == '\0') {
    ppuVar2 = &sel_togglePresentationMode_;
  }
  _objc_msgSend(*(id *)PTR_00336058,sel_sendAction_to_from_,*ppuVar2,0,togglePresentationModeButton)
  ;
  return;
}

*/
- (void)toggleCommentsAndAttributionsPalette:(id)aPalette
{
    [[HSCommentsAndAttributionsPaletteController sharedInstance] togglePalette];
}

- (void)toggleShortcutsPalette:(id)aPalette
{
    [[HSShortcutsPaletteController sharedInstance] togglePalette];
}

- (void)toggleObjectListPalette:(id)aPalette
{
    [[HSObjectListPaletteController sharedInstance] togglePalette];
}

- (void)toggleLayoutPanel:(id)aPanel
{
    [[HSLayoutPaletteController sharedInstance] togglePalette];
}

- (void)toggleToolsPalette:(id)aPalette
{
    [[HSToolPaletteController sharedInstance] togglePalette];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031348 @ 00031348, 110 bytes * /

void FUN_00031348(HSEditorController *self,SEL _cmd,id toggleColorPanel)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(cls_NSColorPanel,sel_sharedColorPanel);
  pvVar1 = _objc_msgSend(self_00,sel_isVisible);
  op = sel_orderFront_;
  if ((char)pvVar1 != '\0') {
    op = sel_performClose_;
  }
  _objc_msgSend(self_00,op,self);
  return;
}

*/
- (void)toggleColorPanel:(id)aPanel
{
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    if ([panel isVisible]) {
        [panel performClose:self];
    } else {
        [panel orderFront:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000312bd @ 000312bd, 139 bytes * /

void FUN_000312bd(HSEditorController *self,SEL _cmd,id toggleFontPanel)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(cls_NSFontPanel,sel_sharedFontPanel);
  pvVar1 = _objc_msgSend(self_00,sel_isVisible);
  op = sel_orderOut_;
  if ((char)pvVar1 == '\0') {
    self_00 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
    op = sel_orderFrontFontPanel_;
  }
  _objc_msgSend(self_00,op,self);
  return;
}

*/
- (void)toggleFontPanel:(id)aPanel
{
    NSFontPanel *panel = [NSFontPanel sharedFontPanel];
    if ([panel isVisible]) {
        [panel orderOut:self];
    } else {
        [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003125a @ 0003125a, 99 bytes * /

void FUN_0003125a(HSEditorController *self,SEL _cmd,id toggleLibrary)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController);
  pvVar1 = _objc_msgSend(self_00,sel_isLibraryVisible);
  op = sel_showLibrary;
  if ((char)pvVar1 != '\0') {
    op = sel_hideLibrary;
  }
  _objc_msgSend(self_00,op);
  return;
}

*/
- (void)toggleLibrary:(id)aLibrary
{
    HSLibraryController *library = [HSLibraryController sharedLibraryController];
    if ([library isLibraryVisible]) {
        [library hideLibrary];
    } else {
        [library showLibrary];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00031090 @ 00031090, 458 bytes * /

void FUN_00031090(HSEditorController *self,SEL _cmd,id launchTextEdit)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  
  pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pcVar5 = &cfstr_TextEdit;
  pvVar2 = _objc_msgSend(pvVar2,sel_launchApplication_,&cfstr_TextEdit);
  puVar1 = cls_NSBundle;
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_class,pcVar5);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_Cannot_launch_TextEdit,&cfstr_empty,&cfstr_Alerts);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_The_TextEdit_application_may_have_been_deleted__,&cfstr_empty,
                           &cfstr_Alerts);
    self_00 = cls_NSAlert;
    puVar1 = cls_NSBundle;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar2 = _objc_msgSend(self_00,
                           sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                           ,pvVar2,pvVar4,0,0,pvVar3);
    _objc_msgSend(pvVar2,sel_runModal);
  }
  return;
}

*/
- (void)launchTextEdit:(id)aEdit
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"TextEdit"]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = [bundle localizedStringForKey:@"Cannot launch TextEdit" value:@"" table:@"Alerts"];
        NSString *information = [bundle localizedStringForKey:@"The TextEdit application may have been deleted, or you may not have sufficient privileges to launch it. Reinstall TextEdit or change its privileges to \"Read & Write\" and try again." value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:[bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", information];
        [alert runModal];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00030ec6 @ 00030ec6, 458 bytes * /

void FUN_00030ec6(HSEditorController *self,SEL _cmd,id launchGrab)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  
  pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pcVar5 = &cfstr_Grab;
  pvVar2 = _objc_msgSend(pvVar2,sel_launchApplication_,&cfstr_Grab);
  puVar1 = cls_NSBundle;
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_class,pcVar5);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Cannot_launch_Grab,
                           &cfstr_empty,&cfstr_Alerts);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_The_Grab_application_may_have_been_deleted__or_y,&cfstr_empty,
                           &cfstr_Alerts);
    self_00 = cls_NSAlert;
    puVar1 = cls_NSBundle;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar2 = _objc_msgSend(self_00,
                           sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                           ,pvVar2,pvVar4,0,0,pvVar3);
    _objc_msgSend(pvVar2,sel_runModal);
  }
  return;
}

*/
- (void)launchGrab:(id)aGrab
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"Grab"]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = [bundle localizedStringForKey:@"Cannot launch Grab" value:@"" table:@"Alerts"];
        NSString *information = [bundle localizedStringForKey:@"The Grab application may have been deleted, or you may not have sufficient privileges to launch it. Reinstall Grab or change its privileges to \"Read & Write\" and try again." value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:[bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", information];
        [alert runModal];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00030cfc @ 00030cfc, 458 bytes * /

void FUN_00030cfc(HSEditorController *self,SEL _cmd,id launchGrapher)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  
  pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pcVar5 = &cfstr_Grapher;
  pvVar2 = _objc_msgSend(pvVar2,sel_launchApplication_,&cfstr_Grapher);
  puVar1 = cls_NSBundle;
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_class,pcVar5);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_Cannot_launch_Grapher,&cfstr_empty,&cfstr_Alerts);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_The_Grapher_application_may_have_been_deleted__o,&cfstr_empty,
                           &cfstr_Alerts);
    self_00 = cls_NSAlert;
    puVar1 = cls_NSBundle;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar2 = _objc_msgSend(self_00,
                           sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                           ,pvVar2,pvVar4,0,0,pvVar3);
    _objc_msgSend(pvVar2,sel_runModal);
  }
  return;
}

*/
- (void)launchGrapher:(id)aGrapher
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"Grapher"]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = [bundle localizedStringForKey:@"Cannot launch Grapher" value:@"" table:@"Alerts"];
        NSString *information = [bundle localizedStringForKey:@"The Grapher application may have been deleted, or you may not have sufficient privileges to launch it. Reinstall Grapher or change its privileges to \"Read & Write\" and try again." value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:[bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", information];
        [alert runModal];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00034672 @ 00034672, 3974 bytes * /

/* WARNING: Type propagation algorithm not settling * /

BOOL FUN_00034672(HSEditorController *self,SEL _cmd,id validateUserInterfaceItem)

{
  char cVar1;
  id pvVar2;
  HSEditorController *self_00;
  undefined *puVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  undefined4 uVar6;
  id pvVar7;
  HSEditorController *pHVar8;
  ushort uVar9;
  undefined *self_01;
  SEL pcVar10;
  char local_20;
  HSEditorController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSApplicationController_0034dc00;
  pcVar4 = validateUserInterfaceItem;
  pvVar2 = _objc_msgSendSuper(&local_1c,sel_validateUserInterfaceItem_,validateUserInterfaceItem);
  local_20 = (char)pvVar2;
  self_00 = _objc_msgSend(self,sel_currentDocument);
  puVar3 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  pvVar2 = _objc_msgSend(self_00,sel_actionExecutionContext);
  pvVar2 = _objc_msgSend(pvVar2,sel_waitingForMouseDownEvent);
  if (((char)pvVar2 != '\0') ||
     (pvVar2 = _objc_msgSend(self_00,sel_isInHyperCastingMode), (char)pvVar2 != '\0')) {
    if ((puVar3 != sel_openReferenceGuide_) && (puVar3 != sel_openTutorial_)) {
      return puVar3 == sel_techSupportForHyperStudio_;
    }
    return '\x01';
  }
  if (local_20 == '\0') {
    pvVar2 = _objc_msgSend(self_00,sel_mainWindowController);
    pvVar2 = _objc_msgSend(pvVar2,sel_isSheetRunning);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
  }
  if (puVar3 == sel_toggleLibrary_) {
    pcVar4 = _objc_msgSend(cls_NSMenuItem,sel_class);
    pvVar2 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pcVar4);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController,pcVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_isLibraryVisible);
      pcVar4 = (cfstringStruct *)(uint)((char)pvVar2 != '\0');
      _objc_msgSend(validateUserInterfaceItem,sel_setState_,pcVar4);
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInPurePlayerMode,pcVar4);
    cVar1 = (char)pvVar2;
    pcVar10 = sel_isInPresentationMode;
joined_r0x0003482e:
    if (cVar1 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,pcVar10,pcVar4);
    self = self_00;
    pcVar10 = sel_isStackProtected;
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
LAB_00034853:
    pvVar2 = _objc_msgSend(self,pcVar10);
    cVar1 = (char)pvVar2;
    pcVar10 = sel_isModalSessionPresent;
joined_r0x0003485a:
    if (cVar1 != '\0') {
      return '\0';
    }
    goto LAB_00034866;
  }
  if (puVar3 == sel_toggleObjects_) {
    return '\0';
  }
  if (puVar3 == sel_toggleToolsPalette_) {
    pvVar2 = _objc_msgSend(self_00,sel_isInPurePlayerMode);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInPresentationMode);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isStackProtected);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isModalSessionPresent);
    cVar1 = (char)pvVar2;
    puVar3 = cls_HSToolPaletteController;
joined_r0x00034a0c:
    if (cVar1 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(puVar3,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_validateTogglePaletteUserInterfaceItem_,
                           validateUserInterfaceItem);
    return (char)pvVar2;
  }
  self_01 = cls_HSLayoutPaletteController;
  if (puVar3 == sel_toggleLayoutPanel_) {
LAB_0003494a:
    pvVar2 = _objc_msgSend(self_01,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_validateTogglePaletteUserInterfaceItem_,
                           validateUserInterfaceItem);
    if ((char)pvVar2 == '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInStoryboardMode,validateUserInterfaceItem);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInHyperCastingMode,validateUserInterfaceItem);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInPresentationMode,validateUserInterfaceItem);
    cVar1 = (char)pvVar2;
    pcVar4 = validateUserInterfaceItem;
    pcVar10 = sel_isInPurePlayerMode;
    goto joined_r0x0003482e;
  }
  if (puVar3 == sel_toggleShortcutsPalette_) {
    pvVar2 = _objc_msgSend(self_00,sel_isInPresentationMode);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInPlayerMode);
    cVar1 = (char)pvVar2;
    puVar3 = cls_HSShortcutsPaletteController;
    goto joined_r0x00034a0c;
  }
  self_01 = cls_HSObjectListPaletteController;
  if (puVar3 == sel_toggleObjectListPalette_) goto LAB_0003494a;
  if (puVar3 == sel_toggleCommentsAndAttributionsPalette_) {
    pvVar2 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_validateTogglePaletteUserInterfaceItem_,
                           validateUserInterfaceItem);
    if ((char)pvVar2 == '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInStoryboardMode,validateUserInterfaceItem);
    if ((char)pvVar2 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,sel_isInHyperCastingMode,validateUserInterfaceItem);
    cVar1 = (char)pvVar2;
    pcVar4 = validateUserInterfaceItem;
    pcVar10 = sel_isInPurePlayerMode;
joined_r0x00034aa3:
    if (cVar1 != '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(self_00,pcVar10,pcVar4);
    cVar1 = (char)pvVar2;
    pcVar10 = sel_isInPresentationMode;
    goto joined_r0x0003485a;
  }
  if (puVar3 != sel_togglePresentationModeButton_) {
    if (puVar3 == sel_toggleCoverDesktop_) {
      pcVar4 = (cfstringStruct *)sel_setState_;
      pvVar2 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
      pcVar10 = sel_isInPresentationMode;
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI,pcVar4);
        pvVar2 = _objc_msgSend(pvVar2,sel_settingsForKey_,*(undefined4 *)PTR_003361a4);
        pvVar2 = _objc_msgSend(pvVar2,sel_boolValue);
        pcVar4 = (cfstringStruct *)(uint)((char)pvVar2 == '\0');
        _objc_msgSend(validateUserInterfaceItem,sel_setState_,pcVar4);
        pcVar10 = sel_isInPresentationMode;
      }
      goto LAB_00034866;
    }
    if (puVar3 == sel_sameBackground_) {
      if (self_00 == (HSEditorController *)0x0) {
        return '\0';
      }
      pvVar2 = _objc_msgSend(self_00,sel_isModalSessionPresent);
      cVar1 = (char)pvVar2;
      pcVar10 = sel_isStackProtected;
      goto joined_r0x00034aa3;
    }
    if (puVar3 == sel_makeGroupCard_) {
      if (self_00 == (HSEditorController *)0x0) {
        return '\0';
      }
      pvVar2 = _objc_msgSend(self_00,sel_isModalSessionPresent);
      if ((char)pvVar2 != '\0') {
        return '\0';
      }
      pvVar2 = _objc_msgSend(self_00,sel_isStackProtected);
      if ((char)pvVar2 != '\0') {
        return '\0';
      }
      pvVar2 = _objc_msgSend(self_00,sel_isInPresentationMode);
      cVar1 = (char)pvVar2;
      pcVar10 = sel_isInAnimationMode;
      goto joined_r0x0003485a;
    }
    pcVar10 = sel_isModalSessionPresent;
    if ((puVar3 == sel_goToHomeWithoutLeaveActions_) || (puVar3 == sel_importFromKeynote_))
    goto LAB_00034866;
    if ((puVar3 == sel_addReadyMadeCards_) || (puVar3 == sel_newCard_)) goto LAB_00034853;
    if (puVar3 == sel_launchGrapher_) {
      pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
      pcVar4 = &cfstr_Grapher;
LAB_00034f39:
      pHVar8 = _objc_msgSend(pvVar2,sel_fullPathForApplication_,pcVar4);
      pcVar10 = sel_isModalSessionPresent;
    }
    else {
      if (puVar3 == sel_launchGrab_) {
        pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
        pcVar4 = &cfstr_Grab;
        goto LAB_00034f39;
      }
      if (puVar3 == sel_launchTextEdit_) {
        pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
        pcVar4 = &cfstr_TextEdit;
        goto LAB_00034f39;
      }
      if (puVar3 == sel_runEmbedCodeForStackDialog_) goto LAB_00034866;
      if (puVar3 == sel_paste_) {
        pvVar2 = _objc_msgSend(self,sel_isMultiDocument);
        if ((char)pvVar2 == '\0') {
          pvVar2 = _objc_msgSend(self_00,sel_isModalSessionPresent);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(self_00,sel_isInPresentationMode);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(self_00,sel_isInPurePlayerMode);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
          pvVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
        }
        else {
          pvVar2 = _objc_msgSend(self,sel_isModalSessionPresent);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(self_00,sel_isInPresentationMode);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(self_00,sel_isInPurePlayerMode);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
          pvVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
        }
        pvVar2 = _objc_msgSend(pvVar2,sel_availableTypeFromArray_,pvVar5);
        if (pvVar2 == (id)0x0) {
          return '\0';
        }
        pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class,pvVar5);
        pvVar5 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar2);
        if ((char)pvVar5 == '\0') {
          return '\x01';
        }
        pvVar2 = _objc_msgSend(cls_HSEditorWindowController,sel_class,pvVar2);
        pvVar5 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedMenuTitleForCardsPasteBoardType_,pvVar5);
        puVar3 = cls_NSString;
        pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_HSPasteFormat,
                               &cfstr_empty,&cfstr_Editor);
        pvVar2 = _objc_msgSend(puVar3,sel_stringWithFormat_,pvVar5,pvVar2);
        _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,pvVar2);
        return '\x01';
      }
      if (puVar3 == sel_saveAsReadyMadeCard_) {
        if (self_00 == (HSEditorController *)0x0) {
          return '\0';
        }
        pvVar2 = _objc_msgSend(self_00,sel_isModalSessionPresent);
        if ((char)pvVar2 != '\0') {
          return '\0';
        }
        pvVar2 = _objc_msgSend(self_00,sel_isInAnimationMode);
        if ((char)pvVar2 != '\0') {
          return '\0';
        }
        pvVar2 = _objc_msgSend(self_00,sel_isWritingDisabled);
        if ((char)pvVar2 != '\0') {
          return '\0';
        }
        pvVar2 = _objc_msgSend(self_00,sel_isInHyperCastingMode);
        if ((char)pvVar2 != '\0') {
          return '\0';
        }
        pvVar2 = _objc_msgSend(self_00,sel_isInPurePlayerMode);
        cVar1 = (char)pvVar2;
        pcVar10 = sel_isStackProtected;
        goto joined_r0x0003485a;
      }
      pHVar8 = self_00;
      if (puVar3 != sel_hideShowToolbar_) {
        if (puVar3 == sel_setOnionSkin_) {
          pvVar2 = _objc_msgSend(self,sel_onionSkinMode);
          pvVar5 = _objc_msgSend(validateUserInterfaceItem,sel_tag);
          pcVar4 = (cfstringStruct *)(uint)(pvVar2 == pvVar5);
          _objc_msgSend(validateUserInterfaceItem,sel_setState_,pcVar4);
          pvVar2 = _objc_msgSend(self_00,sel_isInStandardMode);
          pcVar10 = sel_isModalSessionPresent;
          if ((char)pvVar2 == '\0') {
            return '\0';
          }
          goto LAB_00034866;
        }
        if ((puVar3 != sel_newDocument_) && (puVar3 != sel_openDocument_)) {
          if (local_20 == '\0') {
            return '\0';
          }
          pcVar4 = _objc_msgSend(cls_NSMenuItem,sel_class);
          pvVar2 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pcVar4);
          if ((char)pvVar2 == '\0') {
            return local_20;
          }
          pvVar2 = _objc_msgSend(validateUserInterfaceItem,sel_menu,pcVar4);
          pvVar2 = _objc_msgSend(pvVar2,sel_itemArray);
          pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
          puVar3 = _objc_msgSend(pvVar2,sel_action);
          if (puVar3 != sel_clearRecentDocuments_) {
            return local_20;
          }
          pvVar2 = _objc_msgSend(self_00,sel_exportManager);
          pvVar2 = _objc_msgSend(pvVar2,sel_isExporting);
          if ((char)pvVar2 != '\0') {
            return '\0';
          }
          pvVar2 = _objc_msgSend(self,sel_isMultiDocument);
          if ((char)pvVar2 != '\0') {
            return '\x01';
          }
          pvVar2 = _objc_msgSend(self_00,sel_mainWindowController);
          pvVar2 = _objc_msgSend(pvVar2,sel_isSheetRunning);
          cVar1 = (char)pvVar2;
          pcVar10 = sel_isModalSessionPresent;
          goto joined_r0x0003485a;
        }
        if (local_20 != '\0') {
          pvVar2 = _objc_msgSend(self_00,sel_exportManager);
          pvVar2 = _objc_msgSend(pvVar2,sel_isExporting);
          if ((char)pvVar2 == '\0') {
            pvVar2 = _objc_msgSend(self,sel_isMultiDocument);
            if ((char)pvVar2 == '\0') {
              pvVar2 = _objc_msgSend(self_00,sel_mainWindowController);
              pvVar2 = _objc_msgSend(pvVar2,sel_isSheetRunning);
              if (((char)pvVar2 != '\0') ||
                 (pvVar2 = _objc_msgSend(self_00,sel_isModalSessionPresent), (char)pvVar2 != '\0'))
              goto LAB_0003540d;
            }
            local_20 = '\x01';
          }
          else {
LAB_0003540d:
            local_20 = '\0';
          }
        }
        pvVar2 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
        pvVar2 = _objc_msgSend(pvVar2,sel_isMountainLionOrGreater);
        if ((char)pvVar2 == '\0') {
          return local_20;
        }
        pvVar2 = _objc_msgSend(self,sel_isModalSessionPresent);
        if ((char)pvVar2 == '\0') {
          return local_20;
        }
        pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_mainMenu);
        pvVar2 = _objc_msgSend(pvVar2,sel_itemAtIndex_,1);
        pvVar2 = _objc_msgSend(pvVar2,sel_submenu);
        validateUserInterfaceItem = _objc_msgSend(pvVar2,sel_itemAtIndex_,0);
        pvVar2 = (id)0x0;
        pcVar10 = sel_setEnabled_;
        goto LAB_00034d81;
      }
    }
    sel_isModalSessionPresent = pcVar10;
    if (pHVar8 == (HSEditorController *)0x0) {
      return '\0';
    }
LAB_00034866:
    pvVar2 = _objc_msgSend(self_00,pcVar10,pcVar4);
    return (char)pvVar2 == '\0';
  }
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,&cfstr_HSPresentationModeButtonSwitchesPlayerMode);
  cVar1 = (char)pvVar2;
  puVar3 = sel_setState_;
  pvVar5 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
  if ((char)pvVar5 != '\0') {
    if (cVar1 == '\0') {
      pvVar5 = _objc_msgSend(cls_HSUI,sel_sharedUI,puVar3);
      pvVar5 = _objc_msgSend(pvVar5,sel_currentMode);
      if (pvVar5 != (id)0x1) goto LAB_00034b6d;
      uVar6 = 1;
    }
    else {
LAB_00034b6d:
      uVar6 = 0;
    }
    _objc_msgSend(validateUserInterfaceItem,sel_setState_,uVar6);
  }
  pvVar5 = _objc_msgSend(self_00,sel_validateUserInterfaceItemThatRequiresTogglePlayEditModes_,
                         validateUserInterfaceItem);
  local_20 = (char)pvVar5;
  pvVar5 = _objc_msgSend(cls_NSButton,sel_class);
  pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar5);
  if ((char)pvVar7 == '\0') {
    return local_20;
  }
  if (cVar1 == '\0') {
    pvVar5 = _objc_msgSend(cls_HSUI,sel_sharedUI,pvVar5);
    pvVar5 = _objc_msgSend(pvVar5,sel_currentMode);
    if ((pvVar5 != (id)0x1) || (local_20 == '\0')) goto LAB_00034c1a;
    uVar9 = (ushort)pvVar2 & 0xff;
  }
  else {
LAB_00034c1a:
    uVar9 = CONCAT11(1,cVar1);
  }
  if ((char)uVar9 != '\0') {
    if ((uVar9 & 0x100) == 0) {
      pcVar4 = &cfstr_PlayerMode_On;
    }
    else {
      pcVar4 = &cfstr_PlayerMode;
    }
    pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pcVar4);
    _objc_msgSend(validateUserInterfaceItem,sel_setImage_,pvVar2);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar4 = &cfstr_Leave_Player_view_;
    if ((uVar9 & 0x100) != 0) {
      pcVar4 = &cfstr_Enter_Player_view_;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,0);
    _objc_msgSend(validateUserInterfaceItem,sel_setToolTip_,pvVar2);
    return local_20;
  }
  if ((uVar9 & 0x100) == 0) {
    pcVar4 = &cfstr_PMode_On;
  }
  else {
    pcVar4 = &cfstr_PMode;
  }
  pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pcVar4);
  _objc_msgSend(validateUserInterfaceItem,sel_setImage_,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar4 = &cfstr_Leave_Presentation_view_;
  if ((uVar9 & 0x100) != 0) {
    pcVar4 = &cfstr_Enter_Presentation_view_;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,0);
  pcVar10 = sel_setToolTip_;
LAB_00034d81:
  _objc_msgSend(validateUserInterfaceItem,pcVar10,pvVar2);
  return local_20;
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL superResult = [super validateUserInterfaceItem:aItem];
    HSEditorDocument *document = [self currentDocument];
    SEL action = [aItem action];
    if ([[document actionExecutionContext] waitingForMouseDownEvent] || [document isInHyperCastingMode]) {
        return action == @selector(openReferenceGuide:) || action == @selector(openTutorial:) || action == @selector(techSupportForHyperStudio:);
    }
    if (!superResult && [[document mainWindowController] isSheetRunning]) {
        return NO;
    }
    if (action == @selector(toggleLibrary:)) {
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:[[HSLibraryController sharedLibraryController] isLibraryVisible]];
        }
        if ([document isInPurePlayerMode] || [document isInPresentationMode] || [document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(toggleObjects:)) {
        return NO;
    }
    if (action == @selector(toggleToolsPalette:)) {
        if ([document isInPurePlayerMode] || [document isInPresentationMode] || [document isStackProtected] || [document isModalSessionPresent]) {
            return NO;
        }
        return [[HSToolPaletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem];
    }
    if (action == @selector(toggleLayoutPanel:) || action == @selector(toggleObjectListPalette:)) {
        Class paletteController = (action == @selector(toggleLayoutPanel:)) ? [HSLayoutPaletteController class] : [HSObjectListPaletteController class];
        if (![[paletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem]) {
            return NO;
        }
        if ([document isInStoryboardMode] || [document isInHyperCastingMode] || [document isInPresentationMode] || [document isInPurePlayerMode] || [document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(toggleShortcutsPalette:)) {
        if ([document isInPresentationMode] || [document isInPlayerMode]) {
            return NO;
        }
        return [[HSShortcutsPaletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem];
    }
    if (action == @selector(toggleCommentsAndAttributionsPalette:)) {
        if (![[HSCommentsAndAttributionsPaletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem]) {
            return NO;
        }
        if ([document isInStoryboardMode] || [document isInHyperCastingMode] || [document isInPurePlayerMode]) {
            return NO;
        }
        return ![document isInPresentationMode];
    }
    if (action == @selector(togglePresentationModeButton:)) {
        BOOL switchesPlayerMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"HSPresentationModeButtonSwitchesPlayerMode"];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:(!switchesPlayerMode && [[HSUI sharedUI] currentMode] == 1) ? 1 : 0];
        }
        BOOL result = [document validateUserInterfaceItemThatRequiresTogglePlayEditModes:aItem];
        if (![aItem isKindOfClass:[NSButton class]]) {
            return result;
        }
        BOOL playerMode;
        BOOL entering;
        if (switchesPlayerMode || [[HSUI sharedUI] currentMode] != 1 || !result) {
            playerMode = switchesPlayerMode;
            entering = YES;
        } else {
            playerMode = NO;
            entering = NO;
        }
        if (playerMode) {
            [aItem setImage:[NSImage imageNamed:entering ? @"PlayerMode" : @"PlayerMode_On"]];
            [aItem setToolTip:[[NSBundle mainBundle] localizedStringForKey:entering ? @"Enter Player view." : @"Leave Player view." value:@"" table:nil]];
            return result;
        }
        [aItem setImage:[NSImage imageNamed:entering ? @"PMode" : @"PMode_On"]];
        [aItem setToolTip:[[NSBundle mainBundle] localizedStringForKey:entering ? @"Enter Presentation view." : @"Leave Presentation view." value:@"" table:nil]];
        return result;
    }
    if (action == @selector(toggleCoverDesktop:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:![[[HSUI sharedUI] settingsForKey:HSUIModeIsCoverDesktopEnabled] boolValue]];
        }
        return ![document isInPresentationMode];
    }
    if (action == @selector(sameBackground:)) {
        if (document == nil || [document isModalSessionPresent] || [document isStackProtected]) {
            return NO;
        }
        return ![document isInPresentationMode];
    }
    if (action == @selector(makeGroupCard:)) {
        if (document == nil || [document isModalSessionPresent] || [document isStackProtected] || [document isInPresentationMode]) {
            return NO;
        }
        return ![document isInAnimationMode];
    }
    if (action == @selector(goToHomeWithoutLeaveActions:) || action == @selector(importFromKeynote:) || action == @selector(runEmbedCodeForStackDialog:)) {
        return ![document isModalSessionPresent];
    }
    if (action == @selector(addReadyMadeCards:) || action == @selector(newCard:)) {
        if ([document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(launchGrapher:) || action == @selector(launchGrab:) || action == @selector(launchTextEdit:)) {
        NSString *application = (action == @selector(launchGrapher:)) ? @"Grapher" : (action == @selector(launchGrab:)) ? @"Grab" : @"TextEdit";
        if ([[NSWorkspace sharedWorkspace] fullPathForApplication:application] == nil) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(paste:)) {
        if ([self isMultiDocument]) {
            if ([self isModalSessionPresent]) {
                return NO;
            }
        } else if ([document isModalSessionPresent]) {
            return NO;
        }
        if ([document isInPresentationMode] || [document isInPurePlayerMode]) {
            return NO;
        }
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] == nil) {
            return NO;
        }
        if (![aItem isKindOfClass:[NSMenuItem class]]) {
            return YES;
        }
        NSString *menuTitle = [[HSEditorWindowController class] localizedMenuTitleForCardsPasteBoardType:[NSPasteboard generalPasteboard]];
        NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSPasteFormat" value:@"" table:@"Editor"];
        [aItem setTitle:[NSString stringWithFormat:format, menuTitle]];
        return YES;
    }
    if (action == @selector(saveAsReadyMadeCard:)) {
        if (document == nil || [document isModalSessionPresent] || [document isInAnimationMode] || [document isWritingDisabled] || [document isInHyperCastingMode] || [document isInPurePlayerMode] || [document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(hideShowToolbar:)) {
        if (document == nil) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(setOnionSkin:)) {
        [aItem setState:[self onionSkinMode] == [aItem tag]];
        if (![document isInStandardMode]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action != @selector(newDocument:) && action != @selector(openDocument:)) {
        if (!superResult) {
            return NO;
        }
        if (![aItem isKindOfClass:[NSMenuItem class]]) {
            return superResult;
        }
        if ([[[[aItem menu] itemArray] lastObject] action] != @selector(clearRecentDocuments:)) {
            return superResult;
        }
        if ([[document exportManager] isExporting]) {
            return NO;
        }
        if ([self isMultiDocument]) {
            return YES;
        }
        if ([[document mainWindowController] isSheetRunning]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (superResult) {
        if ([[document exportManager] isExporting]) {
            superResult = NO;
        } else if (![self isMultiDocument]) {
            superResult = !([[document mainWindowController] isSheetRunning] || [document isModalSessionPresent]);
        } else {
            superResult = YES;
        }
    }
    if (![[HSSystem sharedSystem] isMountainLionOrGreater]) {
        return superResult;
    }
    if (![self isModalSessionPresent]) {
        return superResult;
    }
    [[[[[NSApp mainMenu] itemAtIndex:1] submenu] itemAtIndex:0] setEnabled:NO];
    return superResult;
}

- (BOOL)toolPaletteControllerShouldUseToolManager
{
    return ![[self currentDocument] isInStoryboardMode];
}

- (void)contextHelpModeDidActivate:(id)aActivate
{
    [NSApp showHelp:0];
}

- (void)applicationDidResignActive:(id)aActive
{
    [[HSKeysRegistry sharedRegistry] resetKeysRegistry];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00030b3c @ 00030b3c, 270 bytes * /

void FUN_00030b3c(HSEditorController *self,SEL _cmd,uint undoImportingFilesCount,
                 uint lastAddedCardIndex)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  if (1 < undoImportingFilesCount) {
    _objc_msgSend(pvVar1,sel_hyperRemoveChildrenBeginGrouping);
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperCount);
  if (pvVar2 == (id)undoImportingFilesCount) {
    pvVar2 = _objc_msgSend(cls_HSCard,sel_defaultObject);
    _objc_msgSend(pvVar1,sel_addHyperChild_,pvVar2);
  }
  if (undoImportingFilesCount != 0) {
    uVar3 = undoImportingFilesCount;
    do {
      pvVar2 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,
                             (1 - undoImportingFilesCount) + lastAddedCardIndex);
      _objc_msgSend(pvVar1,sel_removeHyperChild_,pvVar2);
      uVar3 = uVar3 - 1;
    } while (uVar3 != 0);
  }
  if (1 < undoImportingFilesCount) {
    _objc_msgSend(pvVar1,sel_hyperRemoveChildrenEndGrouping);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_000355f8 @ 000355f8, 3398 bytes * /

void FUN_000355f8(HSEditorController *self,SEL _cmd,id application,id openFiles)

{
  id pvVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *self_00;
  id self_01;
  id self_02;
  undefined4 *self_03;
  undefined4 *puVar6;
  id pvVar7;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar8;
  int iVar9;
  id pvVar10;
  char cVar11;
  SEL op;
  undefined1 *puVar12;
  cfstringStruct *pcVar13;
  char *pcVar14;
  undefined1 *puVar15;
  cfstringStruct *pcVar16;
  id *ppvVar17;
  undefined1 *puVar18;
  cfstringStruct *pcVar19;
  id local_bc;
  undefined4 local_b4;
  id local_b0;
  id local_ac;
  id local_a8;
  id local_98;
  id local_90;
  char local_86;
  undefined1 local_85 [13];
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  char local_50 [64];
  
  pvVar1 = _objc_msgSend(self,sel_shouldShowEULA);
  cVar11 = (char)pvVar1;
  if (cVar11 == '\0') {
    pvVar1 = _objc_msgSend(self,
                           sel_HSEditorController_validateApplicationLicenseWithInteraction_forced_,
                           0,0);
    cVar11 = (char)pvVar1 == '\0';
  }
  local_78 = (id)0x0;
  if ((cVar11 == '\0') && ((self->_applicationWillFinishCriticalLaunching[0] & 1) == 0)) {
    pvVar1 = _objc_msgSend(openFiles,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_isModalSessionPresent);
      if ((char)pvVar1 != '\0') goto LAB_00035709;
      pvVar1 = _objc_msgSend(self,sel_isMultiDocument);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(self,sel_currentDocument);
        pvVar1 = _objc_msgSend(pvVar1,sel_mainWindowController);
        pvVar1 = _objc_msgSend(pvVar1,sel_isSheetRunning);
        if ((char)pvVar1 != '\0') goto LAB_00035709;
      }
      self->_applicationWillFinishCriticalLaunching[0] =
           self->_applicationWillFinishCriticalLaunching[0] & 0xfb;
      pvVar1 = _objc_msgSend(self,sel_isMultiDocument);
      if ((char)pvVar1 != '\0') {
        self->_applicationOpenUntitledFilePending[0] = 1;
      }
      local_85._9_4_ = (id)0x0;
      local_85._5_4_ = (id)0x0;
      local_85._1_4_ = (id)0x0;
      pvVar1 = _objc_msgSend(self,sel_currentDocument);
      pvVar3 = _objc_msgSend(pvVar1,sel_isNewAndNotChanged);
      cVar11 = (char)pvVar3;
      local_b0 = *(id *)PTR_0033607c;
      local_b4 = *(undefined4 *)(PTR_0033607c + 4);
      if (cVar11 != '\0') {
        pvVar3 = _objc_msgSend(pvVar1,sel_stack);
        local_b0 = _objc_msgSend(pvVar3,sel_hyperCardSize);
        local_b4 = extraout_EDX;
      }
      pvVar3 = _objc_msgSend(pvVar1,sel_isModalSessionPresent);
      if (((char)pvVar3 == '\0') &&
         (pvVar3 = _objc_msgSend(pvVar1,sel_isInAnimationMode), (char)pvVar3 == '\0')) {
        puVar18 = local_85 + 1;
        puVar15 = local_85 + 5;
        puVar12 = local_85 + 9;
        pvVar3 = openFiles;
        _objc_msgSend(self,sel_chooseFilesForImportWithFiles_images_movies_otherMediaOrText_,
                      openFiles,puVar12,puVar15,puVar18);
        pvVar7 = _objc_msgSend((id)local_85._9_4_,sel_count);
        if ((((pvVar7 != (id)0x0) ||
             ((pvVar7 = _objc_msgSend((id)local_85._5_4_,sel_count,pvVar3,puVar12,puVar15,puVar18),
              pvVar7 != (id)0x0 ||
              (pvVar7 = _objc_msgSend((id)local_85._1_4_,sel_count,pvVar3,puVar12,puVar15,puVar18),
              pvVar7 != (id)0x0)))) &&
            (pvVar7 = _objc_msgSend(pvVar1,sel_isStackProtected,pvVar3,puVar12,puVar15,puVar18),
            (char)pvVar7 == '\0')) &&
           ((pvVar7 = _objc_msgSend(pvVar1,sel_isInPlayerMode,pvVar3,puVar12,puVar15,puVar18),
            (char)pvVar7 != '\0' ||
            (pvVar7 = _objc_msgSend(pvVar1,sel_isInPresentationMode), (char)pvVar7 != '\0')))) {
          pvVar3 = (id)0x1;
          _objc_msgSend(pvVar1,sel_switchToEditor_,1);
        }
        local_85[0] = '\0';
        pvVar4 = _objc_msgSend(pvVar1,sel_isInStoryboardMode,pvVar3);
        pvVar7 = pvVar1;
        op = sel_currentCard;
        if ((char)pvVar4 != '\0') {
          pvVar7 = _objc_msgSend(pvVar1,sel_selectionController,pvVar3);
          pvVar7 = _objc_msgSend(pvVar7,sel_storyboardView);
          op = sel_activeCard;
        }
        pcVar5 = _objc_msgSend(pvVar7,op,pvVar3);
        self_00 = _objc_msgSend(cls_NSMutableArray,sel_new);
        pcVar16 = (cfstringStruct *)local_85;
        pcVar13 = (cfstringStruct *)0x0;
        pvVar3 = (id)local_85._9_4_;
        pcVar19 = pcVar5;
        pcVar8 = self_00;
        local_bc = _objc_msgSend(self,
                                 sel_importImageFiles_orImages_importDenied_selectedCard_addedCards_
                                 ,local_85._9_4_,0,pcVar16,pcVar5,self_00);
        if (local_85[0] == '\0') {
          pcVar13 = (cfstringStruct *)local_85;
          pvVar3 = (id)local_85._5_4_;
          pcVar16 = pcVar5;
          pcVar19 = self_00;
          local_a8 = _objc_msgSend(self,sel_importMovieFiles_importDenied_selectedCard_addedCards_,
                                   local_85._5_4_,pcVar13,pcVar5,self_00,pcVar8);
        }
        else {
          local_a8 = (id)0x0;
        }
        if (local_85[0] == '\0') {
          pcVar13 = (cfstringStruct *)local_85;
          pvVar3 = (id)local_85._1_4_;
          pcVar16 = pcVar5;
          pcVar19 = self_00;
          local_ac = _objc_msgSend(self,
                                   sel_importMediaOrTextFiles_importDenied_selectedCard_addedCards_,
                                   local_85._1_4_,pcVar13,pcVar5,self_00,pcVar8);
        }
        else {
          local_ac = (id)0x0;
        }
        if (local_85[0] == '\0') {
          pvVar7 = _objc_msgSend(self_00,sel_count,pvVar3,pcVar13,pcVar16,pcVar19,pcVar8);
          if (pvVar7 != (id)0x0) {
            pvVar3 = _objc_msgSend(self,sel_currentDocument,pvVar3,pcVar13,pcVar16,pcVar19,pcVar8);
            pvVar4 = _objc_msgSend(pvVar3,sel_undoManager);
            _objc_msgSend(pvVar4,sel_disableUndoRegistration);
            pvVar3 = _objc_msgSend(self,sel_currentDocument);
            self_01 = _objc_msgSend(pvVar3,sel_stack);
            if ((pcVar5 == (cfstringStruct *)0x0) || (cVar11 != '\0')) {
              iVar9 = 0;
            }
            else {
              pvVar3 = _objc_msgSend(self_01,sel_indexOfHyperChild_,pcVar5);
              iVar9 = (int)pvVar3 + 1;
            }
            pcVar13 = (cfstringStruct *)0x0;
            pvVar10 = (id)0x0;
            self_02 = _objc_msgSend(self_00,sel_sortedArrayUsingFunction_context_,FUN_00030774,0);
            do {
              pcVar13 = _objc_msgSend(self_02,sel_objectAtIndex_,pvVar10,pcVar13);
              pvVar3 = (id)(iVar9 + (int)pvVar10);
              _objc_msgSend(self_01,sel_setIndex_ofHyperChild_,pvVar3);
              pvVar10 = (id)((int)pvVar10 + 1);
            } while (pvVar10 < pvVar7);
            _objc_msgSend(pvVar4,sel_enableUndoRegistration,pvVar3,pcVar13);
            if (cVar11 != '\0') {
              _objc_msgSend(pvVar4,sel_beginUndoGrouping,pvVar3,pcVar13);
              pvVar3 = _objc_msgSend(pvVar4,sel_prepareWithInvocationTarget_,self_01);
              pvVar10 = _objc_msgSend(cls_HSCard,sel_defaultObject);
              _objc_msgSend(pvVar3,sel_addHyperChild_,pvVar10);
              pvVar3 = _objc_msgSend(pvVar4,sel_prepareWithInvocationTarget_,self_01);
              _objc_msgSend(pvVar3,sel_setHyperCardSize_,local_b0,local_b4);
              pvVar3 = _objc_msgSend(pvVar4,sel_prepareWithInvocationTarget_,self_01);
              _objc_msgSend(pvVar3,sel_removeHyperChildren_,self_02);
              _objc_msgSend(pvVar4,sel_endUndoGrouping);
              pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
              pcVar16 = &cfstr_UndoManager;
              pcVar13 = &cfstr_empty;
              pcVar8 = &cfstr_Add_Items;
              if (pvVar7 == (id)0x1) {
                pcVar8 = &cfstr_Add_Item;
              }
              pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar8,
                                     &cfstr_empty,&cfstr_UndoManager);
              _objc_msgSend(pvVar4,sel_setActionName_,pvVar3);
            }
          }
        }
        else {
          _NSBeep();
        }
        _objc_msgSend(self_00,sel_release,pvVar3,pcVar13,pcVar16,pcVar19);
      }
      else {
        local_bc = (id)0x0;
        local_a8 = (id)0x0;
        local_ac = (id)0x0;
      }
      if (pvVar1 == (id)0x0) {
        pvVar1 = _objc_msgSend(self,sel_currentDocument);
        _objc_msgSend(pvVar1,sel_testCard_,0);
      }
      if (((local_a8 == (id)0x0 && local_bc == (id)0x0) && local_ac == (id)0x0) &&
         ((self->_applicationWillFinishCriticalLaunching[0] & 4) == 0)) {
        pvVar1 = _objc_msgSend((id)local_85._9_4_,sel_count);
        if ((pvVar1 == (id)0x0) &&
           ((pvVar1 = _objc_msgSend((id)local_85._5_4_,sel_count), pvVar1 == (id)0x0 &&
            (pvVar1 = _objc_msgSend((id)local_85._1_4_,sel_count), pvVar1 == (id)0x0)))) {
          local_74 = 0;
          local_70 = 0;
          local_6c = (int *)0x0;
          local_68 = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          pcVar14 = local_50;
          puVar6 = &local_74;
          ppvVar17 = (id *)0x10;
          local_98 = _objc_msgSend(openFiles,sel_countByEnumeratingWithState_objects_count_,puVar6,
                                   pcVar14,0x10);
          if (local_98 != (id)0x0) {
            iVar9 = *local_6c;
            do {
              local_90 = (id)0x0;
              do {
                if (iVar9 != *local_6c) {
                  _objc_enumerationMutation(openFiles);
                }
                self_03 = *(undefined4 **)(local_70 + (int)local_90 * 4);
                pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,puVar6,pcVar14,ppvVar17)
                ;
                puVar6 = self_03;
                pvVar3 = _objc_msgSend(pvVar1,sel_isReadableFileAtPath_);
                if ((char)pvVar3 != '\0') {
                  pvVar3 = _objc_msgSend(cls_NSURL,sel_alloc,puVar6);
                  puVar6 = self_03;
                  pvVar3 = _objc_msgSend(pvVar3,sel_initFileURLWithPath_,self_03);
                  if (pvVar3 == (id)0x0) goto LAB_000356c4;
                  pvVar7 = _objc_msgSend(pvVar3,sel_absoluteURL,puVar6);
                  ppvVar17 = &local_78;
                  pvVar7 = _objc_msgSend(self,sel_openDocumentWithContentsOfURL_display_error_,
                                         pvVar7,1,ppvVar17);
                  _objc_msgSend(pvVar3,sel_release);
                  local_86 = '\0';
                  pcVar14 = &local_86;
                  puVar6 = self_03;
                  pvVar1 = _objc_msgSend(pvVar1,sel_fileExistsAtPath_isDirectory_,self_03,pcVar14);
                  if (pvVar7 == (id)0x0) {
                    pvVar3 = _objc_msgSend(local_78,sel_userInfo,puVar6,pcVar14,ppvVar17);
                    uVar2 = *(undefined4 *)PTR_003361a8;
                    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,uVar2);
                    if (pvVar3 != (id)0x0) goto LAB_000356c4;
                    if (((char)pvVar1 != '\0') && (local_86 != '\0')) {
                      pvVar1 = _objc_msgSend(local_78,sel_domain,uVar2,pcVar14);
                      uVar2 = *(undefined4 *)PTR_003361ac;
                      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,uVar2);
                      if (((char)pvVar1 != '\0') &&
                         (pvVar1 = _objc_msgSend(local_78,sel_code,uVar2), pvVar1 == (id)0x100)) {
                        local_78 = (id)0x0;
                        _NSBeep();
                      }
                    }
                    goto LAB_0003630d;
                  }
                  if ((char)pvVar1 == '\0') goto LAB_000356c4;
                  if (local_86 == '\0') {
                    self_03 = _objc_msgSend(self_03,sel_stringByDeletingLastPathComponent,puVar6,
                                            pcVar14,ppvVar17);
                  }
                  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,puVar6,pcVar14,ppvVar17);
                  puVar6 = _objc_msgSend(pvVar1,sel_bundlePath);
                  pvVar1 = _objc_msgSend(self_03,sel_hasPrefix_,puVar6);
                  if ((char)pvVar1 == '\0') {
                    pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,puVar6);
                    _objc_msgSend(pvVar1,sel_setHyperStudioDocumentsFolder_,self_03);
                    puVar6 = self_03;
                  }
                }
                local_90 = (id)((int)local_90 + 1);
              } while (local_90 < local_98);
              pcVar14 = local_50;
              puVar6 = &local_74;
              ppvVar17 = (id *)0x10;
              local_98 = _objc_msgSend(openFiles,sel_countByEnumeratingWithState_objects_count_,
                                       puVar6,pcVar14,0x10);
            } while (local_98 != (id)0x0);
          }
        }
        else {
          _NSBeep();
        }
      }
    }
LAB_000356c4:
    uVar2 = 0;
  }
  else {
    _objc_msgSend(openFiles,sel_retain);
    _objc_msgSend(self->_filesToOpen,sel_release);
    self->_filesToOpen = openFiles;
LAB_00035709:
    uVar2 = 1;
  }
  _objc_msgSend(application,sel_replyToOpenOrPrint_,uVar2);
LAB_0003630d:
  if (local_78 != (id)0x0) {
    _objc_msgSend(self,sel_presentError_,local_78);
  }
  return;
}

*/
- (void)application:(id)aApplication openFiles:(id)aFiles
{
    BOOL cannotOpen = [self shouldShowEULA];
    if (!cannotOpen) {
        cannotOpen = ![self HSEditorController_validateApplicationLicenseWithInteraction:NO forced:NO];
    }
    NSError *error = nil;
    BOOL reply = NO;
    if (cannotOpen || _applicationWillFinishCriticalLaunching) {
        [aFiles retain];
        [_filesToOpen release];
        _filesToOpen = aFiles;
        reply = YES;
    } else if ([aFiles count] != 0) {
        if ([self isModalSessionPresent] || (![self isMultiDocument] && [[[self currentDocument] mainWindowController] isSheetRunning])) {
            reply = YES;
        } else {
            _needCancelImportFiles = 0;
            if ([self isMultiDocument]) {
                _applicationOpenUntitledFilePending = 1;
            }
            id images = nil;
            id movies = nil;
            id otherMediaOrText = nil;
            HSEditorDocument *document = [self currentDocument];
            BOOL isNewAndNotChanged = [document isNewAndNotChanged];
            NSSize cardSize = NSZeroSize;
            if (isNewAndNotChanged) {
                cardSize = [[document stack] hyperCardSize];
            }
            NSUInteger imageCount = 0;
            NSUInteger movieCount = 0;
            NSUInteger mediaCount = 0;
            if (![document isModalSessionPresent] && ![document isInAnimationMode]) {
                [self chooseFilesForImportWithFiles:aFiles images:&images movies:&movies otherMediaOrText:&otherMediaOrText];
                if (([images count] != 0 || [movies count] != 0 || [otherMediaOrText count] != 0) && ![document isStackProtected] && ([document isInPlayerMode] || [document isInPresentationMode])) {
                    [document switchToEditor:YES];
                }
                BOOL importDenied = NO;
                id cardSource = document;
                id selectedCard;
                if ([document isInStoryboardMode]) {
                    cardSource = [[document selectionController] storyboardView];
                    selectedCard = [cardSource activeCard];
                } else {
                    selectedCard = [cardSource currentCard];
                }
                NSMutableArray *addedCards = [NSMutableArray new];
                imageCount = [self importImageFiles:images orImages:nil importDenied:&importDenied selectedCard:selectedCard addedCards:addedCards];
                if (!importDenied) {
                    movieCount = [self importMovieFiles:movies importDenied:&importDenied selectedCard:selectedCard addedCards:addedCards];
                }
                if (!importDenied) {
                    mediaCount = [self importMediaOrTextFiles:otherMediaOrText importDenied:&importDenied selectedCard:selectedCard addedCards:addedCards];
                }
                if (!importDenied) {
                    NSUInteger count = [addedCards count];
                    if (count != 0) {
                        NSUndoManager *undoManager = [[self currentDocument] undoManager];
                        [undoManager disableUndoRegistration];
                        HSStack *stack = [[self currentDocument] stack];
                        NSUInteger index = (selectedCard != nil && !isNewAndNotChanged) ? [stack indexOfHyperChild:selectedCard] + 1 : 0;
                        NSArray *sorted = [addedCards sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                            NSString *titleA = [[a queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
                            NSString *titleB = [[b queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
                            return (NSComparisonResult)CFStringCompareWithOptions((CFStringRef)titleA, (CFStringRef)titleB, CFRangeMake(0, CFStringGetLength((CFStringRef)titleA)), 0x71);
                        }];
                        for (NSUInteger i = 0; i < count; i++) {
                            [stack setIndex:index + i ofHyperChild:[sorted objectAtIndex:i]];
                        }
                        [undoManager enableUndoRegistration];
                        if (isNewAndNotChanged) {
                            [undoManager beginUndoGrouping];
                            [[undoManager prepareWithInvocationTarget:stack] addHyperChild:[HSCard defaultObject]];
                            [[undoManager prepareWithInvocationTarget:stack] setHyperCardSize:cardSize];
                            [[undoManager prepareWithInvocationTarget:stack] removeHyperChildren:sorted];
                            [undoManager endUndoGrouping];
                            [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(count == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
                        }
                    }
                } else {
                    NSBeep();
                }
                [addedCards release];
            }
            if (document == nil) {
                [[self currentDocument] testCard:nil];
            }
            if (imageCount == 0 && movieCount == 0 && mediaCount == 0 && !_needCancelImportFiles) {
                if ([images count] == 0 && [movies count] == 0 && [otherMediaOrText count] == 0) {
                    for (NSString *path in aFiles) {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        if (![fileManager isReadableFileAtPath:path]) {
                            continue;
                        }
                        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
                        if (url == nil) {
                            break;
                        }
                        id opened = [self openDocumentWithContentsOfURL:[url absoluteURL] display:YES error:&error];
                        [url release];
                        BOOL isDirectory = NO;
                        BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
                        if (opened == nil) {
                            if ([[error userInfo] objectForKey:HSUserCancelledImportKey] != nil) {
                                break;
                            }
                            if (exists && isDirectory && [[error domain] isEqualToString:NSCocoaErrorDomain] && [error code] == 0x100) {
                                error = nil;
                                NSBeep();
                            }
                            if (error != nil) {
                                [self presentError:error];
                            }
                            return;
                        }
                        if (!exists) {
                            break;
                        }
                        NSString *folder = path;
                        if (!isDirectory) {
                            folder = [path stringByDeletingLastPathComponent];
                        }
                        if (![folder hasPrefix:[[NSBundle mainBundle] bundlePath]]) {
                            [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:folder];
                        }
                    }
                } else {
                    NSBeep();
                }
            }
        }
    }
    [aApplication replyToOpenOrPrint:reply ? NSApplicationDelegateReplyCancel : NSApplicationDelegateReplySuccess];
    if (error != nil) {
        [self presentError:error];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00030813 @ 00030813, 809 bytes * /

uint FUN_00030813(HSEditorController *self,SEL _cmd,id importMediaOrTextFiles,BOOL *importDenied,
                 id selectedCard,id addedCards)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  undefined *puVar7;
  undefined *local_1c;
  id local_18;
  id local_14;
  
  pvVar2 = _objc_msgSend(importMediaOrTextFiles,sel_count);
  if (pvVar2 == (id)0x0) {
    BVar1 = '\0';
    local_18 = (id)0x0;
    goto LAB_00030b26;
  }
  local_18 = selectedCard;
  local_14 = _objc_msgSend(self,sel_currentDocument);
  if (local_14 == (id)0x0) {
    local_14 = _objc_msgSend(self,sel_openUntitledDocumentAndDisplay_error_,1,0);
LAB_000308c2:
    local_1c = _objc_msgSend(local_14,sel_currentCard);
    puVar7 = local_1c;
    _objc_msgSend(addedCards,sel_addObject_,local_1c);
    uVar6 = 1;
    pvVar3 = _objc_msgSend(local_14,sel_stack);
LAB_00030970:
    pvVar2 = _objc_msgSend(local_14,sel_mainWindowController,puVar7);
    pvVar2 = _objc_msgSend(pvVar2,sel_cardView);
    puVar7 = sel_importToCardDataFromFiles_showHelpPane_;
    pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,
                           sel_importToCardDataFromFiles_showHelpPane_);
    if ((char)pvVar2 != '\0') {
      if (selectedCard == (id)0x0) {
        local_18 = _objc_msgSend(local_14,sel_currentCard,puVar7);
      }
      pvVar2 = _objc_msgSend(pvVar3,sel_indexOfHyperChild_,local_18);
      local_18 = _objc_msgSend(self,
                               sel_importMediaOrTextFiles_asCardsAtIndex_replaceCard_toDocument_addedCards_
                               ,importMediaOrTextFiles,(int)pvVar2 + 1,uVar6,local_14,addedCards);
      pvVar2 = _objc_msgSend(local_14,sel_undoManager);
      _objc_msgSend(pvVar2,sel_disableUndoRegistration);
      pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
      self_00 = _objc_msgSend(local_1c,sel_queryHyperInterface_,&DAT_00362500);
      pvVar4 = _objc_msgSend(cls_HSOpenLocationAction,sel_actionType);
      pvVar2 = pvVar3;
      pvVar5 = _objc_msgSend(self_00,sel_hyperActionOfType_forEvent_,pvVar4,pvVar3);
      if (pvVar5 == (id)0x0) {
        pvVar4 = _objc_msgSend(cls_HSNextCardAction,sel_nextCardActionWithFadeTransition,pvVar4,
                               pvVar2);
        _objc_msgSend(self_00,sel_addHyperAction_forEvent_,pvVar4,pvVar3);
        pvVar2 = pvVar3;
      }
      pvVar2 = _objc_msgSend(local_14,sel_undoManager,pvVar4,pvVar2);
      _objc_msgSend(pvVar2,sel_enableUndoRegistration);
      BVar1 = '\0';
      goto LAB_00030b26;
    }
  }
  else {
    pvVar2 = _objc_msgSend(local_14,sel_isNewAndNotChanged);
    if ((char)pvVar2 != '\0') goto LAB_000308c2;
    pvVar2 = _objc_msgSend(local_14,sel_stack);
    puVar7 = &DAT_00362708;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00362708);
    pvVar2 = _objc_msgSend(pvVar2,sel_isStackProtected);
    pvVar3 = _objc_msgSend(local_14,sel_stack);
    if ((char)pvVar2 == '\0') {
      uVar6 = 0;
      local_1c = (undefined *)0x0;
      goto LAB_00030970;
    }
  }
  BVar1 = '\x01';
  local_18 = (id)0x0;
LAB_00030b26:
  if (importDenied != (BOOL *)0x0) {
    *importDenied = BVar1;
  }
  return (uint)local_18;
}

*/
- (NSUInteger)importMediaOrTextFiles:(id)aFiles importDenied:(BOOL *)aDenied selectedCard:(id)aCard addedCards:(id)aCards
{
    NSUInteger result = 0;
    BOOL denied = NO;
    if ([aFiles count] != 0) {
        denied = YES;
        HSEditorDocument *document = [self currentDocument];
        HSCard *firstCard = nil;
        BOOL replaceCard = NO;
        BOOL canImport = YES;
        if (document == nil) {
            document = [self openUntitledDocumentAndDisplay:YES error:NULL];
            firstCard = [document currentCard];
            [aCards addObject:firstCard];
            replaceCard = YES;
        } else if ([document isNewAndNotChanged]) {
            firstCard = [document currentCard];
            [aCards addObject:firstCard];
            replaceCard = YES;
        } else if ([[[document stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] isStackProtected]) {
            canImport = NO;
        }
        if (canImport && [[[document mainWindowController] cardView] respondsToSelector:@selector(importToCardDataFromFiles:showHelpPane:)]) {
            HSStack *stack = [document stack];
            HSCard *selected = aCard != nil ? aCard : [document currentCard];
            result = [self importMediaOrTextFiles:aFiles asCardsAtIndex:[stack indexOfHyperChild:selected] + 1 replaceCard:replaceCard toDocument:document addedCards:aCards];
            [[document undoManager] disableUndoRegistration];
            id event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
            id actor = [firstCard queryHyperInterface:@protocol(HSActor)];
            if ([actor hyperActionOfType:[HSOpenLocationAction actionType] forEvent:event] == nil) {
                [actor addHyperAction:[HSNextCardAction nextCardActionWithFadeTransition] forEvent:event];
            }
            [[document undoManager] enableUndoRegistration];
            denied = NO;
        }
    }
    if (aDenied != NULL) {
        *aDenied = denied;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00030061 @ 00030061, 1811 bytes * /

void FUN_00030061(HSEditorController *self,SEL _cmd,id importDataFromFiles,uint asCardWithIndex,
                 id toDocument)

{
  id *ppvVar1;
  id *ppvVar2;
  id *ppvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id self_01;
  id pvVar6;
  id *self_02;
  id pvVar7;
  id pvVar8;
  id *ppvVar9;
  SEL op;
  id *ppvVar10;
  cfstringStruct *pcVar11;
  id pvVar12;
  int iVar13;
  uint uVar14;
  id *ppvVar15;
  id *ppvVar16;
  cfstringStruct *pcVar17;
  undefined4 uVar18;
  uint local_3c;
  id local_24;
  id local_1c;
  id local_18;
  id local_14;
  
  pvVar4 = _objc_msgSend(toDocument,sel_stack);
  self_00 = _objc_msgSend(toDocument,sel_undoManager);
  _objc_msgSend(self_00,sel_disableUndoRegistration);
  local_14 = (id)0x0;
  local_18 = (id)0x0;
  local_1c = (id)0x0;
  self_02 = &local_1c;
  ppvVar10 = &local_18;
  ppvVar9 = &local_14;
  _objc_msgSend(self,sel_chooseFilesForImportWithFiles_images_movies_otherMediaOrText_,
                importDataFromFiles,ppvVar9,ppvVar10,self_02);
  pvVar5 = _objc_msgSend(local_14,sel_objectEnumerator);
  self_01 = _objc_msgSend(cls_NSMutableArray,sel_new);
  local_24 = _objc_msgSend(pvVar5,sel_nextObject);
  if (local_24 == (id)0x0) {
    local_3c = asCardWithIndex;
  }
  else {
    local_3c = asCardWithIndex;
    do {
      pvVar6 = _objc_msgSend(cls_NSImage,sel_alloc);
      importDataFromFiles = local_24;
      pvVar6 = _objc_msgSend(pvVar6,sel_initWithContentsOfFile_,local_24);
      if (pvVar6 != (id)0x0) {
        self_02 = _objc_msgSend(cls_HSCard,sel_defaultObject,importDataFromFiles);
        uVar14 = local_3c;
        _objc_msgSend(pvVar4,sel_insertHyperChild_atIndex_,self_02,local_3c);
        _objc_msgSend(self_01,sel_addObject_,self_02);
        if (local_3c != 0) {
          iVar13 = local_3c - 1;
          pvVar7 = _objc_msgSend(pvVar4,sel_hyperChildAtIndex_,iVar13,uVar14);
          pvVar8 = _objc_msgSend(pvVar7,sel_isGroupCard);
          if ((char)pvVar8 != '\0') {
            pvVar7 = _objc_msgSend(pvVar7,sel_cardGroupUID,iVar13,uVar14);
            _objc_msgSend(self_02,sel_makeGroupCardWithGroupUID_,pvVar7);
          }
        }
        ppvVar9 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,local_24,uVar14);
        importDataFromFiles = pvVar6;
        ppvVar10 = toDocument;
        _objc_msgSend(self,sel_importImage_withFileURL_toDocument_withCard_,pvVar6,ppvVar9,
                      toDocument,self_02);
        local_3c = local_3c + 1;
      }
      _objc_msgSend(pvVar6,sel_release,importDataFromFiles,ppvVar9,ppvVar10,self_02);
      local_24 = _objc_msgSend(pvVar5,sel_nextObject);
    } while (local_24 != (id)0x0);
  }
  pvVar5 = _objc_msgSend(cls_HSMovieVerifier,sel_alloc);
  pvVar5 = _objc_msgSend(pvVar5,sel_init);
  ppvVar1 = *(id **)PTR_003361c4;
  ppvVar2 = *(id **)PTR_003361d0;
  ppvVar3 = *(id **)PTR_003361c8;
  local_24 = (id)0x0;
  pvVar6 = _objc_msgSend(local_18,sel_objectEnumerator);
  while (pvVar7 = _objc_msgSend(pvVar6,sel_nextObject,importDataFromFiles,ppvVar9,ppvVar10),
        ppvVar15 = ppvVar9, ppvVar16 = ppvVar10, pvVar7 != (id)0x0) {
    _objc_msgSend(local_24,sel_release,importDataFromFiles,ppvVar9,ppvVar10);
    local_24 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
    pvVar8 = _objc_msgSend(cls_NSDictionary,sel_alloc);
    uVar18 = 0;
    importDataFromFiles = pvVar7;
    ppvVar15 = ppvVar1;
    ppvVar16 = ppvVar2;
    self_02 = ppvVar3;
    pvVar8 = _objc_msgSend(pvVar8,sel_initWithObjectsAndKeys_,pvVar7,ppvVar1,ppvVar2,ppvVar3,0);
    if (pvVar8 == (id)0x0) break;
    pvVar12 = _objc_msgSend(cls_QTMovie,sel_alloc,importDataFromFiles,ppvVar15,ppvVar16,self_02,
                            uVar18);
    ppvVar9 = (id *)0x0;
    importDataFromFiles = pvVar8;
    pvVar12 = _objc_msgSend(pvVar12,sel_initWithAttributes_error_,pvVar8,0);
    _objc_msgSend(pvVar8,sel_release);
    ppvVar10 = ppvVar16;
    if (pvVar12 != (id)0x0) {
      ppvVar16 = (id *)0x0;
      ppvVar15 = (id *)0x0;
      importDataFromFiles = pvVar12;
      pvVar8 = _objc_msgSend(pvVar5,sel_verifyMovie_withOptions_error_,pvVar12,0,0,self_02,uVar18);
      op = sel_autorelease;
      if (pvVar12 != pvVar8) {
        op = sel_release;
      }
      _objc_msgSend(pvVar12,op,importDataFromFiles,ppvVar15,ppvVar16);
      ppvVar9 = ppvVar15;
      ppvVar10 = ppvVar16;
      if (pvVar8 != (id)0x0) {
        ppvVar9 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar7,ppvVar15,ppvVar16);
        importDataFromFiles = pvVar7;
        if ((ppvVar9 == (id *)0x0) ||
           (ppvVar10 = _objc_msgSend(cls_HSCard,sel_defaultObject,pvVar7,ppvVar15,ppvVar16),
           importDataFromFiles = pvVar7, ppvVar10 == (id *)0x0)) break;
        _objc_msgSend(pvVar4,sel_insertHyperChild_atIndex_,ppvVar10,local_3c,ppvVar16);
        _objc_msgSend(self_01,sel_addObject_,ppvVar10);
        _objc_msgSend(self,sel_importMovie_withFileURL_toCard_,pvVar8,ppvVar9,ppvVar10);
        local_3c = local_3c + 1;
        importDataFromFiles = pvVar8;
      }
    }
  }
  _objc_msgSend(pvVar5,sel_release,importDataFromFiles,ppvVar15,ppvVar16,self_02);
  _objc_msgSend(local_24,sel_release);
  pcVar17 = (cfstringStruct *)0x0;
  pvVar5 = local_1c;
  pvVar6 = self_01;
  _objc_msgSend(self,sel_importMediaOrTextFiles_asCardsAtIndex_replaceCard_toDocument_addedCards_,
                local_1c,local_3c,0,toDocument,self_01);
  _objc_msgSend(self_00,sel_enableUndoRegistration);
  pvVar7 = _objc_msgSend(self_01,sel_count);
  if (pvVar7 != (id)0x0) {
    _objc_msgSend(self_00,sel_disableUndoRegistration,pvVar5,local_3c,pcVar17,toDocument,pvVar6);
    pvVar8 = (id)0x0;
    pvVar12 = (id)0x0;
    pvVar5 = _objc_msgSend(self_01,sel_sortedArrayUsingFunction_context_,FUN_00030774,0);
    do {
      pvVar8 = _objc_msgSend(pvVar5,sel_objectAtIndex_,pvVar12,pvVar8);
      iVar13 = asCardWithIndex + (int)pvVar12;
      _objc_msgSend(pvVar4,sel_setIndex_ofHyperChild_,iVar13);
      pvVar12 = (id)((int)pvVar12 + 1);
    } while (pvVar12 < pvVar7);
    _objc_msgSend(self_00,sel_enableUndoRegistration,iVar13,pvVar8);
    pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar17 = &cfstr_UndoManager;
    pcVar11 = &cfstr_Add_Items;
    if (pvVar7 == (id)0x1) {
      pcVar11 = &cfstr_Add_Item;
    }
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,pcVar11,&cfstr_empty,
                           &cfstr_UndoManager);
    _objc_msgSend(self_00,sel_setActionName_,pvVar4);
    local_3c = (asCardWithIndex - 1) + (int)pvVar7;
    pvVar4 = _objc_msgSend(self_00,sel_prepareWithInvocationTarget_,self);
    _objc_msgSend(pvVar4,sel_undoImportingFilesCount_lastAddedCardIndex_,pvVar7,local_3c);
    pvVar5 = pvVar7;
  }
  _objc_msgSend(self_01,sel_release,pvVar5,local_3c,pcVar17,toDocument,pvVar6);
  return;
}

*/
- (void)importDataFromFiles:(id)aFiles asCardWithIndex:(NSUInteger)aIndex toDocument:(id)aDocument
{
    HSStack *stack = [aDocument stack];
    NSUndoManager *undoManager = [aDocument undoManager];
    [undoManager disableUndoRegistration];
    NSArray *images = nil;
    NSArray *movies = nil;
    NSArray *otherMediaOrText = nil;
    [self chooseFilesForImportWithFiles:aFiles images:&images movies:&movies otherMediaOrText:&otherMediaOrText];
    NSMutableArray *addedCards = [NSMutableArray new];
    NSUInteger index = aIndex;
    NSEnumerator *imageEnumerator = [images objectEnumerator];
    NSString *file;
    while ((file = [imageEnumerator nextObject]) != nil) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
        if (image != nil) {
            HSCard *card = [HSCard defaultObject];
            [stack insertHyperChild:card atIndex:index];
            [addedCards addObject:card];
            if (index != 0) {
                HSCard *previous = [stack hyperChildAtIndex:index - 1];
                if ([previous isGroupCard]) {
                    [card makeGroupCardWithGroupUID:[previous cardGroupUID]];
                }
            }
            [self importImage:image withFileURL:[NSURL fileURLWithPath:file] toDocument:aDocument withCard:card];
            index++;
        }
        [image release];
    }
    HSMovieVerifier *verifier = [[HSMovieVerifier alloc] init];
    NSAutoreleasePool *pool = nil;
    NSEnumerator *movieEnumerator = [movies objectEnumerator];
    while ((file = [movieEnumerator nextObject]) != nil) {
        [pool release];
        pool = [NSAutoreleasePool new];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:file, QTMovieFileNameAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
        if (attributes == nil) {
            break;
        }
        QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
        [attributes release];
        if (movie != nil) {
            QTMovie *verified = [verifier verifyMovie:movie withOptions:0 error:NULL];
            if (movie == verified) {
                [movie autorelease];
            } else {
                [movie release];
            }
            if (verified != nil) {
                NSURL *url = [NSURL fileURLWithPath:file];
                HSCard *card = url != nil ? [HSCard defaultObject] : nil;
                if (card == nil) {
                    break;
                }
                [stack insertHyperChild:card atIndex:index];
                [addedCards addObject:card];
                [self importMovie:verified withFileURL:url toCard:card];
                index++;
            }
        }
    }
    [verifier release];
    [pool release];
    [self importMediaOrTextFiles:otherMediaOrText asCardsAtIndex:index replaceCard:NO toDocument:aDocument addedCards:addedCards];
    [undoManager enableUndoRegistration];
    NSUInteger count = [addedCards count];
    if (count != 0) {
        [undoManager disableUndoRegistration];
        NSArray *sorted = [addedCards sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *titleA = [[a queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
            NSString *titleB = [[b queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
            return (NSComparisonResult)CFStringCompareWithOptions((CFStringRef)titleA, (CFStringRef)titleB, CFRangeMake(0, CFStringGetLength((CFStringRef)titleA)), 0x71);
        }];
        for (NSUInteger i = 0; i < count; i++) {
            [stack setIndex:aIndex + i ofHyperChild:[sorted objectAtIndex:i]];
        }
        [undoManager enableUndoRegistration];
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(count == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
        [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:count lastAddedCardIndex:(aIndex - 1) + count];
    }
    [addedCards release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003633e @ 0003633e, 3248 bytes * /

uint FUN_0003633e(HSEditorController *self,SEL _cmd,id importMediaOrTextFiles,uint asCardsAtIndex,
                 BOOL replaceCard,id toDocument,id addedCards)

{
  undefined4 uVar1;
  undefined4 uVar2;
  int iVar3;
  bool bVar4;
  id self_00;
  id pvVar5;
  undefined *puVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  float fVar15;
  undefined *puVar16;
  uint uVar17;
  id pvVar18;
  id self_01;
  undefined1 *puVar19;
  id pvVar20;
  float extraout_EDX;
  cfstringStruct *pcVar21;
  undefined1 *puVar22;
  bool bVar23;
  float fVar24;
  SEL pcVar25;
  undefined *puVar26;
  undefined4 uVar27;
  id pvVar28;
  undefined4 uVar29;
  id local_b4;
  id local_b0;
  uint local_ac;
  id local_9c;
  float local_90;
  undefined *local_8c;
  id local_80;
  id local_7c;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_new);
  pvVar5 = _objc_msgSend(toDocument,sel_stack);
  puVar6 = &DAT_003627bc;
  pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_003627bc);
  local_80 = (id)asCardsAtIndex;
  if (replaceCard == '\0') {
    puVar6 = (undefined *)0x0;
    if (asCardsAtIndex != 0) {
      puVar6 = (undefined *)(asCardsAtIndex - 1);
    }
    pvVar7 = _objc_msgSend(pvVar5,sel_hyperChildAtIndex_,puVar6);
    local_9c = _objc_msgSend(pvVar7,sel_cardGroupUID);
  }
  else {
    local_9c = (id)0x0;
  }
  pvVar7 = _objc_msgSend(toDocument,sel_undoManager,puVar6);
  _objc_msgSend(pvVar7,sel_disableUndoRegistration);
  if (replaceCard == '\0') {
    pvVar8 = _objc_msgSend(pvVar5,sel_hyperCount,puVar6);
    pvVar9 = _objc_msgSend(addedCards,sel_count);
    if (pvVar8 == pvVar9) goto LAB_00036476;
    bVar4 = true;
  }
  else {
LAB_00036476:
    bVar4 = false;
  }
  pvVar8 = _objc_msgSend(importMediaOrTextFiles,sel_count);
  if ((pvVar8 != (id)0x0) && (pvVar5 != (id)0x0)) {
    pvVar9 = _objc_msgSend(toDocument,sel_mainWindowController);
    pvVar9 = _objc_msgSend(pvVar9,sel_cardView);
    pvVar20 = _objc_msgSend(pvVar9,sel_respondsToSelector_,
                            sel_importToCardDataFromFiles_showHelpPane_);
    puVar6 = PTR_0033607c;
    if ((char)pvVar20 != '\0') {
      uVar29 = *(undefined4 *)PTR_00336084;
      uVar1 = *(undefined4 *)PTR_0033617c;
      uVar2 = *(undefined4 *)PTR_0033618c;
      local_ac = 0;
      local_b0 = (id)0x1;
      local_b4 = (id)0x0;
      while (local_80 = (id)asCardsAtIndex, local_b4 < pvVar8) {
        pvVar20 = (id)((int)local_b4 + 1);
        pvVar10 = _objc_msgSend(importMediaOrTextFiles,sel_objectAtIndex_,local_b4);
        pvVar11 = _objc_msgSend(pvVar10,sel_lastPathComponent);
        pvVar11 = _objc_msgSend(pvVar11,sel_stringByDeletingPathExtension);
        if (replaceCard == '\0') {
          pvVar12 = _objc_msgSend(cls_HSCard,sel_defaultObject,local_b4);
          if (pvVar12 == (id)0x0) break;
          _objc_msgSend(self_00,sel_addObject_,pvVar12);
          pvVar13 = _objc_msgSend(pvVar12,sel_queryHyperInterface_,&DAT_003627e4);
          _objc_msgSend(pvVar13,sel_setHyperTitle_,pvVar11);
          _objc_msgSend(pvVar5,sel_insertHyperChild_atIndex_,pvVar12,asCardsAtIndex);
          pvVar13 = pvVar9;
          pcVar25 = sel_setCard_;
        }
        else {
          pvVar13 = _objc_msgSend(pvVar5,sel_hyperChildAtIndex_,asCardsAtIndex + -1);
          pvVar13 = _objc_msgSend(pvVar13,sel_queryHyperInterface_,&DAT_003627e4);
          pcVar25 = sel_setHyperTitle_;
          pvVar12 = pvVar11;
        }
        _objc_msgSend(pvVar13,pcVar25,pvVar12);
        pvVar13 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
        pvVar12 = _objc_msgSend(pvVar10,sel_pathExtension);
        pvVar14 = _objc_msgSend(pvVar13,sel_boolForKey_,uVar2);
        if ((char)pvVar14 == '\0') {
          uVar27 = 1;
          pvVar14 = _objc_msgSend(pvVar12,sel_compare_options_,&cfstr_pdf,1);
          if (pvVar14 != (id)0x0) goto LAB_00036a8f;
          pvVar13 = _objc_msgSend(pvVar13,sel_boolForKey_,uVar1,uVar27);
          fVar15 = (float)(uint)((char)pvVar13 == '\0');
          pvVar13 = _objc_msgSend(pvVar9,sel_objectsFromPDFFile_firstPageOnly_,pvVar10,fVar15);
          pvVar12 = _objc_msgSend(pvVar13,sel_count);
          if (pvVar12 == (id)0x0) goto LAB_0003679a;
          if ((replaceCard != '\0') &&
             (pvVar10 = _objc_msgSend(pvVar5,sel_hyperCount,pvVar10,fVar15), pvVar10 == (id)0x1)) {
            pvVar10 = (id)0x0;
            local_90 = *(float *)(puVar6 + 4);
            local_8c = *(undefined **)puVar6;
            do {
              pvVar14 = _objc_msgSend(pvVar13,sel_objectAtIndex_,pvVar10,fVar15);
              puVar26 = &DAT_0036267c;
              pvVar14 = _objc_msgSend(pvVar14,sel_queryHyperInterface_,&DAT_0036267c);
              pvVar10 = (id)((int)pvVar10 + 1);
              puVar16 = _objc_msgSend(pvVar14,sel_size);
              fVar24 = extraout_EDX;
              if (extraout_EDX <= local_90) {
                fVar24 = local_90;
              }
              if ((float)puVar16 <= (float)local_8c) {
                puVar16 = local_8c;
              }
              local_90 = fVar24;
              local_8c = puVar16;
            } while (pvVar10 < pvVar12);
            if ((0.0 < (float)puVar16) && (0.0 < fVar24)) {
              pvVar10 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00362708);
              _objc_msgSend(pvVar10,sel_setHyperCardSize_,puVar16,fVar24);
              puVar26 = puVar16;
              fVar15 = fVar24;
            }
            _objc_msgSend(pvVar9,sel_fitInWindow,puVar26,fVar15);
          }
          local_78 = (id)0x0;
          while (local_78 < pvVar12) {
            pvVar10 = (id)((int)local_78 + 1);
            pcVar21 = &cfstr_____d;
            pvVar14 = pvVar11;
            pvVar28 = pvVar10;
            pvVar18 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_____d,pvVar11,pvVar10)
            ;
            if (local_78 != (id)0x0) {
              self_01 = _objc_msgSend(cls_HSCard,sel_defaultObject,pcVar21,pvVar14,pvVar28);
              if (self_01 == (id)0x0) break;
              _objc_msgSend(self_00,sel_addObject_,self_01,pvVar14,pvVar28);
              pvVar14 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_003627e4);
              _objc_msgSend(pvVar14,sel_setHyperTitle_,pvVar18);
              pvVar14 = local_80;
              _objc_msgSend(pvVar5,sel_insertHyperChild_atIndex_,self_01,local_80);
              _objc_msgSend(pvVar9,sel_setCard_,self_01);
            }
            pvVar14 = _objc_msgSend(pvVar13,sel_objectAtIndex_,local_78,pvVar14,pvVar28);
            uVar17 = -(uint)(local_78 < (id)((int)pvVar12 - 1U)) & 1;
            local_80 = (id)((int)local_80 + uVar17);
            local_ac = local_ac + uVar17;
            _objc_msgSend(pvVar9,sel_addObjectToCenter_useDragPreferences_,pvVar14,1);
            local_78 = pvVar10;
          }
          pvVar10 = (id)0x1;
        }
        else {
LAB_00036a8f:
          pcVar21 = &cfstr_kmz;
          pvVar11 = _objc_msgSend(pvVar12,sel_isEqualToString_,&cfstr_kmz);
          if ((char)pvVar11 == '\0') {
            pcVar21 = &cfstr_kml;
            pvVar11 = _objc_msgSend(pvVar12,sel_isEqualToString_,&cfstr_kml);
            if ((char)pvVar11 == '\0') {
              pvVar10 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pvVar10);
              if (pvVar10 != (id)0x0) {
                bVar23 = pvVar8 == local_b0;
                if ((!bVar23) &&
                   (pvVar13 = _objc_msgSend(pvVar13,sel_boolForKey_,uVar2), pvVar11 = local_b0,
                   (char)pvVar13 == '\0')) {
                  do {
                    if (pvVar8 <= pvVar11) {
                      bVar23 = true;
                      goto LAB_00036c7f;
                    }
                    pvVar13 = _objc_msgSend(importMediaOrTextFiles,sel_objectAtIndex_,pvVar11);
                    pvVar13 = _objc_msgSend(pvVar13,sel_pathExtension);
                    pvVar13 = _objc_msgSend(pvVar13,sel_compare_options_,&cfstr_pdf,1);
                    pvVar11 = (id)((int)pvVar11 + 1);
                  } while (pvVar13 == (id)0x0);
                  bVar23 = false;
                }
LAB_00036c7f:
                pvVar10 = _objc_msgSend(pvVar9,sel_importToCardDataFromFiles_showHelpPane_,pvVar10,
                                        (uint)bVar23);
                goto LAB_00036ca2;
              }
              break;
            }
          }
          pvVar11 = _objc_msgSend(pvVar9,sel_card,pcVar21);
          pvVar13 = _objc_msgSend(cls_HSGoogleEarthAction,sel_new);
          pvVar10 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar10);
          _objc_msgSend(pvVar13,sel_setURL_,pvVar10);
          pvVar10 = _objc_msgSend(pvVar11,sel_queryHyperInterface_,&DAT_00362500);
          pvVar11 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar29);
          _objc_msgSend(pvVar10,sel_addHyperAction_forEvent_,pvVar13,pvVar11);
          _objc_msgSend(pvVar13,sel_release);
LAB_0003679a:
          pvVar10 = (id)0x0;
        }
LAB_00036ca2:
        local_ac = local_ac + (int)pvVar10;
        replaceCard = pvVar10 == (id)0x0;
        asCardsAtIndex = (uint)!(bool)replaceCard + (int)local_80;
        local_b0 = (id)((int)local_b0 + 1);
        local_b4 = pvVar20;
      }
      goto LAB_00036cd5;
    }
  }
  local_ac = 0;
LAB_00036cd5:
  puVar19 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar22 = local_50;
  uVar29 = 0x10;
  local_7c = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,&local_74,puVar22,
                           0x10);
  if (local_7c != (id)0x0) {
    iVar3 = *local_6c;
    do {
      local_78 = (id)0x0;
      do {
        if (iVar3 != *local_6c) {
          _objc_enumerationMutation(self_00);
        }
        pvVar5 = *(id *)(local_70 + (int)local_78 * 4);
        puVar6 = &DAT_00362500;
        local_78 = (id)((int)local_78 + 1);
        pvVar8 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00362500,puVar22,uVar29);
        if (local_9c == (id)0x0) {
LAB_00036e0c:
          pvVar5 = _objc_msgSend(cls_HSOpenLocationAction,sel_actionType,puVar6);
          puVar22 = puVar19;
          pvVar9 = _objc_msgSend(pvVar8,sel_hyperActionOfType_forEvent_,pvVar5,puVar19);
          if (pvVar9 == (id)0x0) {
            pvVar9 = _objc_msgSend(cls_HSNextCardAction,sel_nextCardActionWithFadeTransition,pvVar5,
                                   puVar22);
            pvVar5 = pvVar8;
            pcVar25 = sel_addHyperAction_forEvent_;
            puVar22 = puVar19;
            goto LAB_00036e75;
          }
        }
        else {
          pvVar9 = _objc_msgSend(pvVar8,sel_hyperActions,puVar6);
          pvVar20 = _objc_msgSend(pvVar9,sel_count);
          pcVar25 = sel_makeGroupCardWithGroupUID_;
          pvVar9 = local_9c;
          if (pvVar20 != (id)0x0) goto LAB_00036e0c;
LAB_00036e75:
          _objc_msgSend(pvVar5,pcVar25,pvVar9,puVar22);
        }
      } while (local_78 < local_7c);
      puVar22 = local_50;
      uVar29 = 0x10;
      local_7c = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               puVar22,0x10);
    } while (local_7c != (id)0x0);
  }
  pvVar5 = self_00;
  _objc_msgSend(addedCards,sel_addObjectsFromArray_,self_00,puVar22,uVar29);
  _objc_msgSend(pvVar7,sel_enableUndoRegistration);
  if ((bVar4) &&
     (pvVar8 = _objc_msgSend(self_00,sel_count,pvVar5,puVar22,uVar29), pvVar8 != (id)0x0)) {
    pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar5);
    pcVar21 = &cfstr_Add_Items;
    if (pvVar8 == (id)0x1) {
      pcVar21 = &cfstr_Add_Item;
    }
    pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,pcVar21,&cfstr_empty,
                           &cfstr_UndoManager);
    _objc_msgSend(pvVar7,sel_setActionName_,pvVar5);
    pvVar5 = _objc_msgSend(pvVar7,sel_prepareWithInvocationTarget_,self);
    puVar22 = (undefined1 *)((int)local_80 + -1);
    _objc_msgSend(pvVar5,sel_undoImportingFilesCount_lastAddedCardIndex_,pvVar8,puVar22);
    pvVar5 = pvVar8;
  }
  _objc_msgSend(self_00,sel_release,pvVar5,puVar22);
  return local_ac;
}

*/
- (NSUInteger)importMediaOrTextFiles:(id)aFiles asCardsAtIndex:(NSUInteger)aIndex replaceCard:(BOOL)aCard toDocument:(id)aDocument addedCards:(id)aCards
{
    NSMutableArray *added = [NSMutableArray new];
    id stack = [[aDocument stack] queryHyperInterface:@protocol(HSNodeContainer)];
    NSUInteger index = aIndex;
    BOOL replaceCard = aCard;
    id groupUID = nil;
    if (!replaceCard) {
        groupUID = [[stack hyperChildAtIndex:(aIndex != 0 ? aIndex - 1 : 0)] cardGroupUID];
    }
    NSUndoManager *undoManager = [aDocument undoManager];
    [undoManager disableUndoRegistration];
    BOOL registerUndo = !replaceCard && [stack hyperCount] != [aCards count];
    NSUInteger fileCount = [aFiles count];
    NSUInteger result = 0;
    if (fileCount != 0 && stack != nil) {
        id cardView = [[aDocument mainWindowController] cardView];
        if ([cardView respondsToSelector:@selector(importToCardDataFromFiles:showHelpPane:)]) {
            for (NSUInteger i = 0; i < fileCount; i++) {
                NSString *path = [aFiles objectAtIndex:i];
                NSString *title = [[path lastPathComponent] stringByDeletingPathExtension];
                if (!replaceCard) {
                    id card = [HSCard defaultObject];
                    if (card == nil) {
                        break;
                    }
                    [added addObject:card];
                    [[card queryHyperInterface:@protocol(HSMutableCardAttributes)] setHyperTitle:title];
                    [stack insertHyperChild:card atIndex:index];
                    [cardView setCard:card];
                } else {
                    [[[stack hyperChildAtIndex:index - 1] queryHyperInterface:@protocol(HSMutableCardAttributes)] setHyperTitle:title];
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *extension = [path pathExtension];
                BOOL textAsTarget = [defaults boolForKey:HSImportTextAsTargetForOpenThisDocumentActionKey];
                NSUInteger imported;
                if (!textAsTarget && [extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    NSArray *objects = [cardView objectsFromPDFFile:path firstPageOnly:![defaults boolForKey:HSImportAllPDFPagesKey]];
                    NSUInteger pageCount = [objects count];
                    if (pageCount == 0) {
                        imported = 0;
                    } else {
                        if (replaceCard && [stack hyperCount] == 1) {
                            NSSize largest = NSZeroSize;
                            for (NSUInteger j = 0; j < pageCount; j++) {
                                NSSize size = [[[objects objectAtIndex:j] queryHyperInterface:@protocol(HSSizeAttributes)] size];
                                if (size.width > largest.width) {
                                    largest.width = size.width;
                                }
                                if (size.height > largest.height) {
                                    largest.height = size.height;
                                }
                            }
                            if (largest.width > 0 && largest.height > 0) {
                                [[stack queryHyperInterface:@protocol(HSMutableStackAttributes)] setHyperCardSize:largest];
                            }
                            [cardView fitInWindow];
                        }
                        for (NSUInteger j = 0; j < pageCount; j++) {
                            NSString *pageTitle = [NSString stringWithFormat:@"%@ %d", title, (int)(j + 1)];
                            if (j != 0) {
                                id card = [HSCard defaultObject];
                                if (card == nil) {
                                    break;
                                }
                                [added addObject:card];
                                [[card queryHyperInterface:@protocol(HSMutableCardAttributes)] setHyperTitle:pageTitle];
                                [stack insertHyperChild:card atIndex:index];
                                [cardView setCard:card];
                            }
                            NSUInteger advance = (j < pageCount - 1) ? 1 : 0;
                            index += advance;
                            result += advance;
                            [cardView addObjectToCenter:[objects objectAtIndex:j] useDragPreferences:YES];
                        }
                        imported = 1;
                    }
                } else if ([extension isEqualToString:@"kmz"] || [extension isEqualToString:@"kml"]) {
                    id card = [cardView card];
                    HSGoogleEarthAction *action = [HSGoogleEarthAction new];
                    [action setURL:[NSURL fileURLWithPath:path]];
                    [[card queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
                    [action release];
                    imported = 0;
                } else {
                    NSArray *single = [NSArray arrayWithObject:path];
                    if (single == nil) {
                        break;
                    }
                    BOOL showHelpPane = (fileCount == i + 1);
                    if (!showHelpPane && !textAsTarget) {
                        showHelpPane = YES;
                        for (NSUInteger j = i + 1; j < fileCount; j++) {
                            if ([[[aFiles objectAtIndex:j] pathExtension] compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                                showHelpPane = NO;
                                break;
                            }
                        }
                    }
                    imported = [cardView importToCardDataFromFiles:single showHelpPane:showHelpPane];
                }
                result += imported;
                replaceCard = (imported == 0);
                index += (imported != 0);
            }
        }
    }
    HSActionEvent *clickEvent = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    for (id card in added) {
        id actor = [card queryHyperInterface:@protocol(HSActor)];
        if (groupUID == nil || [[actor hyperActions] count] != 0) {
            id openLocation = [actor hyperActionOfType:[HSOpenLocationAction actionType] forEvent:clickEvent];
            if (openLocation == nil) {
                [actor addHyperAction:[HSNextCardAction nextCardActionWithFadeTransition] forEvent:clickEvent];
            }
        } else {
            [card makeGroupCardWithGroupUID:groupUID];
        }
    }
    [aCards addObjectsFromArray:added];
    [undoManager enableUndoRegistration];
    NSUInteger addedCount = [added count];
    if (registerUndo && addedCount != 0) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(addedCount == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
        [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:addedCount lastAddedCardIndex:index - 1];
    }
    [added release];
    return result;
}

- (NSUInteger)importMovieFiles:(id)aFiles importDenied:(BOOL *)aDenied
{
    return (unsigned int)[self importMovieFiles:aFiles importDenied:aDenied selectedCard:nil addedCards:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002f54c @ 0002f54c, 2769 bytes * /

uint FUN_0002f54c(HSEditorController *self,SEL _cmd,id importMovieFiles,BOOL *importDenied,
                 id selectedCard,id addedCards)

{
  undefined4 uVar1;
  bool bVar2;
  undefined *self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  SEL pcVar8;
  id self_01;
  id pvVar9;
  id pvVar10;
  BOOL BVar11;
  cfstringStruct *pcVar12;
  undefined8 in_stack_ffffff7c;
  ulonglong uVar13;
  undefined4 uVar15;
  undefined4 uVar16;
  undefined8 uVar14;
  uint uVar17;
  undefined4 uVar18;
  undefined4 uVar19;
  undefined4 uVar20;
  undefined4 uVar21;
  id local_60;
  HSEditorController *local_30;
  id local_2c;
  id local_28;
  id local_18;
  id local_14;
  
  uVar15 = (undefined4)((ulonglong)in_stack_ffffff7c >> 0x20);
  local_18 = _objc_msgSend(self,sel_currentDocument);
  if (local_18 == (id)0x0) {
LAB_0002f5bf:
    bVar2 = false;
  }
  else {
    pvVar3 = _objc_msgSend(local_18,sel_stack);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperCount);
    pvVar4 = _objc_msgSend(addedCards,sel_count);
    if (pvVar3 == pvVar4) goto LAB_0002f5bf;
    bVar2 = true;
  }
  if ((importMovieFiles == (id)0x0) ||
     (pvVar3 = _objc_msgSend(importMovieFiles,sel_count), pvVar3 == (id)0x0)) {
    BVar11 = '\0';
    local_2c = (id)0x0;
    goto LAB_00030007;
  }
  if (local_18 == (id)0x0) {
    uVar15 = 0;
    local_18 = _objc_msgSend(self,sel_openUntitledDocumentAndDisplay_error_,1,0);
LAB_0002f650:
    local_60 = _objc_msgSend(local_18,sel_currentCard);
    uVar13 = CONCAT44(uVar15,local_60);
    _objc_msgSend(addedCards,sel_addObject_,local_60);
  }
  else {
    pvVar3 = _objc_msgSend(local_18,sel_isNewAndNotChanged);
    if ((char)pvVar3 != '\0') goto LAB_0002f650;
    pvVar3 = _objc_msgSend(local_18,sel_stack);
    uVar13 = CONCAT44(uVar15,&DAT_00362708);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00362708);
    pvVar3 = _objc_msgSend(pvVar3,sel_isStackProtected);
    if ((char)pvVar3 != '\0') {
      BVar11 = '\x01';
      local_2c = (id)0x0;
      goto LAB_00030007;
    }
    local_60 = (id)0x0;
  }
  pvVar3 = _objc_msgSend(importMovieFiles,sel_count,uVar13);
  pvVar4 = _objc_msgSend(local_18,sel_undoManager);
  _objc_msgSend(pvVar4,sel_disableUndoRegistration);
  if (pvVar3 < (id)0x15) {
    local_30 = (HSEditorController *)0x0;
  }
  else {
    local_30 = _objc_msgSend(cls_HSExportProgressSheetController,sel_new);
    _objc_msgSend(local_30,sel_setDelegate_,self);
    self_00 = cls_NSBundle;
    pvVar5 = _objc_msgSend(self,sel_class);
    pvVar5 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar5);
    pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                           &cfstr_ImportMoviesSheetProgressDescription,&cfstr_empty,&cfstr_Dialogs);
    _objc_msgSend(local_30,sel_setDescription_,pvVar5);
    _objc_msgSend(local_30,sel_setProgressIndicatorIndeterminate_,0);
    uVar15 = 0;
    _objc_msgSend(local_30,sel_setProgress_,0,0);
    pvVar5 = _objc_msgSend(local_18,sel_windowForSheet);
    uVar13 = CONCAT44(uVar15,pvVar5);
    _objc_msgSend(local_30,sel_beginSheetForWindow_,pvVar5);
  }
  local_28 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,uVar13);
  pvVar5 = _objc_msgSend(cls_HSMovieVerifier,sel_alloc);
  pvVar5 = _objc_msgSend(pvVar5,sel_init);
  if (local_60 == (id)0x0) {
    local_2c = (id)0x0;
    local_14 = local_2c;
  }
  else {
    pvVar10 = _objc_msgSend(importMovieFiles,sel_objectAtIndex_,0);
    pvVar6 = _objc_msgSend(cls_NSDictionary,sel_alloc);
    uVar15 = *(undefined4 *)PTR_003361c8;
    uVar18 = *(undefined4 *)PTR_003361d0;
    uVar13 = CONCAT44(*(undefined4 *)PTR_003361c4,pvVar10);
    uVar20 = 0;
    pvVar6 = _objc_msgSend(pvVar6,sel_initWithObjectsAndKeys_,pvVar10,*(undefined4 *)PTR_003361c4,
                           uVar18,uVar15,0);
    if (pvVar6 != (id)0x0) {
      pvVar7 = _objc_msgSend(cls_QTMovie,sel_alloc,uVar13,uVar18,uVar15,uVar20);
      uVar13 = ZEXT48(pvVar6);
      pvVar7 = _objc_msgSend(pvVar7,sel_initWithAttributes_error_,pvVar6,0);
      _objc_msgSend(pvVar6,sel_release);
      if (pvVar7 != (id)0x0) {
        uVar18 = 0;
        uVar13 = ZEXT48(pvVar7);
        pvVar6 = _objc_msgSend(pvVar5,sel_verifyMovie_withOptions_error_,pvVar7,0,0,uVar15,uVar20);
        pcVar8 = sel_autorelease;
        if (pvVar7 != pvVar6) {
          pcVar8 = sel_release;
        }
        _objc_msgSend(pvVar7,pcVar8,uVar13,uVar18);
        if (pvVar6 != (id)0x0) {
          uVar15 = (undefined4)(uVar13 >> 0x20);
          uVar13 = CONCAT44(uVar15,pvVar10);
          pvVar10 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar10,uVar15,uVar18);
          if (pvVar10 != (id)0x0) {
            uVar13 = CONCAT44(pvVar10,pvVar6);
            _objc_msgSend(self,sel_importMovie_withFileURL_toCard_,pvVar6,pvVar10,local_60);
            local_2c = (id)0x1;
            local_14 = local_2c;
            goto LAB_0002fa27;
          }
        }
      }
    }
    local_14 = (id)0x1;
    local_2c = (id)0x0;
  }
LAB_0002fa27:
  uVar15 = *(undefined4 *)PTR_003361c4;
  uVar18 = *(undefined4 *)PTR_003361d0;
  uVar20 = *(undefined4 *)PTR_003361c8;
  uVar1 = *(undefined4 *)PTR_003361b4;
  for (; local_14 < pvVar3; local_14 = (id)((int)local_14 + 1)) {
    uVar13 = CONCAT44((int)(uVar13 >> 0x20),local_14);
    pvVar10 = _objc_msgSend(importMovieFiles,sel_objectAtIndex_,local_14);
    if ((self->_applicationWillFinishCriticalLaunching[0] & 4) != 0) break;
    _objc_msgSend(local_28,sel_release,uVar13);
    local_28 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
    if ((id)0x14 < pvVar3) {
      _objc_msgSend(local_30,sel_setProgress_,
                    (((double)(ZEXT48(local_14) | 0x4330000000000000) - 4503599627370496.0) * 100.0)
                    / ((double)(ZEXT48(pvVar3) | 0x4330000000000000) - 4503599627370496.0));
      pvVar6 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
      pvVar7 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x9999999a);
      uVar13 = CONCAT44(pvVar7,uVar1);
      _objc_msgSend(pvVar6,sel_runMode_beforeDate_,uVar1);
    }
    pvVar6 = _objc_msgSend(cls_NSDictionary,sel_alloc,uVar13);
    uVar13 = CONCAT44(uVar15,pvVar10);
    uVar21 = 0;
    uVar19 = uVar18;
    uVar16 = uVar20;
    pvVar6 = _objc_msgSend(pvVar6,sel_initWithObjectsAndKeys_,pvVar10,uVar15,uVar18,uVar20,0);
    if (pvVar6 == (id)0x0) break;
    pvVar7 = _objc_msgSend(cls_QTMovie,sel_alloc,uVar13,uVar19,uVar16,uVar21);
    uVar13 = ZEXT48(pvVar6);
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithAttributes_error_,pvVar6);
    _objc_msgSend(pvVar6,sel_release);
    if (pvVar7 != (id)0x0) {
      uVar19 = 0;
      uVar13 = ZEXT48(pvVar7);
      pvVar6 = _objc_msgSend(pvVar5,sel_verifyMovie_withOptions_error_,pvVar7,0,0,uVar16,uVar21);
      pcVar8 = sel_autorelease;
      if (pvVar7 != pvVar6) {
        pcVar8 = sel_release;
      }
      _objc_msgSend(pvVar7,pcVar8,uVar13,uVar19);
      if (pvVar6 != (id)0x0) {
        uVar16 = (undefined4)(uVar13 >> 0x20);
        uVar13 = CONCAT44(uVar16,pvVar10);
        pvVar10 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar10,uVar16,uVar19);
        if ((pvVar10 == (id)0x0) ||
           (pvVar7 = _objc_msgSend(cls_HSCard,sel_defaultObject,uVar13,uVar19), pvVar7 == (id)0x0))
        break;
        uVar16 = (undefined4)(uVar13 >> 0x20);
        uVar14 = CONCAT44(uVar16,pvVar7);
        _objc_msgSend(addedCards,sel_addObject_,pvVar7,uVar16,uVar19);
        self_01 = _objc_msgSend(local_18,sel_stack);
        pvVar9 = selectedCard;
        if (selectedCard == (id)0x0) {
          pvVar9 = _objc_msgSend(local_18,sel_currentCard,uVar14);
        }
        _objc_msgSend(self_01,sel_indexOfHyperChild_,pvVar9);
        _objc_msgSend(self_01,sel_insertHyperChild_atIndex_,pvVar7);
        uVar13 = CONCAT44(pvVar10,pvVar6);
        _objc_msgSend(self,sel_importMovie_withFileURL_toCard_,pvVar6,pvVar10,pvVar7);
        local_2c = (id)((int)local_2c + 1);
      }
    }
  }
  _objc_msgSend(pvVar5,sel_release,uVar13);
  _objc_msgSend(local_28,sel_release);
  if (((self->_applicationWillFinishCriticalLaunching[0] & 4) == 0) && (local_2c != (id)0x0)) {
    if (local_60 == (id)0x0) {
      if (bVar2) {
        _objc_msgSend(pvVar4,sel_enableUndoRegistration);
        pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
        pcVar12 = &cfstr_Add_Items;
        if (local_2c == (id)0x1) {
          pcVar12 = &cfstr_Add_Item;
        }
        pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,pcVar12,&cfstr_empty,
                               &cfstr_UndoManager);
        _objc_msgSend(pvVar4,sel_setActionName_,pvVar5);
        pvVar5 = _objc_msgSend(pvVar4,sel_prepareWithInvocationTarget_,self);
        pvVar10 = _objc_msgSend(local_18,sel_stack);
        pvVar10 = _objc_msgSend(pvVar10,sel_indexOfHyperChild_,selectedCard);
        uVar13 = CONCAT44((int)pvVar10 + (int)pvVar3,local_2c);
        _objc_msgSend(pvVar5,sel_undoImportingFilesCount_lastAddedCardIndex_,local_2c,
                      (int)pvVar10 + (int)pvVar3);
        pvVar5 = pvVar4;
        pcVar8 = sel_disableUndoRegistration;
        goto LAB_0002ff26;
      }
    }
    else {
      pvVar5 = _objc_msgSend(local_18,sel_selectionController);
      uVar17 = (uint)(uVar13 >> 0x20);
      pvVar5 = _objc_msgSend(pvVar5,sel_stackController);
      _objc_msgSend(pvVar5,sel_selectHyperObject_,local_60);
      uVar13 = (ulonglong)uVar17 << 0x20;
      pvVar5 = local_18;
      pcVar8 = sel_updateChangeCount_;
LAB_0002ff26:
      _objc_msgSend(pvVar5,pcVar8,uVar13);
    }
    BVar11 = '\0';
  }
  else {
    BVar11 = '\x01';
  }
  if ((id)0x14 < pvVar3) {
    if ((self->_applicationWillFinishCriticalLaunching[0] & 4) == 0) {
      uVar13 = 0x4059000000000000;
      self = local_30;
      pcVar8 = sel_setProgress_;
    }
    else {
      pvVar3 = _objc_msgSend(local_18,sel_stack);
      pvVar3 = _objc_msgSend(pvVar3,sel_indexOfHyperChild_,selectedCard);
      uVar13 = CONCAT44((int)pvVar3 + 1,local_2c);
      pcVar8 = sel_undoImportingFilesCount_lastAddedCardIndex_;
    }
    _objc_msgSend(self,pcVar8,uVar13);
    _objc_msgSend(local_30,sel_endSheet);
    uVar13 = uVar13 & 0xffffffff00000000;
    _objc_msgSend(local_30,sel_setDelegate_,0);
    _objc_msgSend(local_30,sel_release);
  }
  _objc_msgSend(pvVar4,sel_enableUndoRegistration,uVar13);
LAB_00030007:
  if (importDenied != (BOOL *)0x0) {
    *importDenied = BVar11;
  }
  return (uint)local_2c;
}

*/
- (NSUInteger)importMovieFiles:(id)aFiles importDenied:(BOOL *)aDenied selectedCard:(id)aCard addedCards:(id)aCards
{
    HSEditorDocument *document = [self currentDocument];
    BOOL registerUndo = (document != nil) && [[document stack] hyperCount] != [aCards count];
    NSUInteger imported = 0;
    BOOL denied = NO;
    if (aFiles == nil || [aFiles count] == 0) {
        if (aDenied != NULL) {
            *aDenied = NO;
        }
        return 0;
    }
    HSCard *firstCard = nil;
    BOOL proceed = NO;
    if (document == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if ([document isNewAndNotChanged]) {
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if (![[[document stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] isStackProtected]) {
        proceed = YES;
    }
    if (!proceed) {
        if (aDenied != NULL) {
            *aDenied = YES;
        }
        return 0;
    }
    NSUInteger count = [aFiles count];
    NSUndoManager *undoManager = [document undoManager];
    [undoManager disableUndoRegistration];
    HSExportProgressSheetController *progress = nil;
    if (count > 20) {
        progress = [HSExportProgressSheetController new];
        [progress setDelegate:self];
        [progress setDescription:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportMoviesSheetProgressDescription" value:@"" table:@"Dialogs"]];
        [progress setProgressIndicatorIndeterminate:NO];
        [progress setProgress:0];
        [progress beginSheetForWindow:[document windowForSheet]];
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    HSMovieVerifier *verifier = [[HSMovieVerifier alloc] init];
    NSUInteger index = 0;
    if (firstCard != nil) {
        NSString *file = [aFiles objectAtIndex:0];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:file, QTMovieFileNameAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
        if (attributes != nil) {
            QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
            [attributes release];
            if (movie != nil) {
                QTMovie *verified = [verifier verifyMovie:movie withOptions:0 error:NULL];
                if (movie == verified) {
                    [movie autorelease];
                } else {
                    [movie release];
                }
                if (verified != nil) {
                    NSURL *url = [NSURL fileURLWithPath:file];
                    if (url != nil) {
                        [self importMovie:verified withFileURL:url toCard:firstCard];
                        imported = 1;
                    }
                }
            }
        }
        index = 1;
    }
    for (; index < count; index++) {
        NSString *file = [aFiles objectAtIndex:index];
        if (_needCancelImportFiles) {
            break;
        }
        [pool release];
        pool = [NSAutoreleasePool new];
        if (count > 20) {
            [progress setProgress:((double)index * 100.0) / (double)count];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:file, QTMovieFileNameAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
        if (attributes == nil) {
            break;
        }
        QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
        [attributes release];
        if (movie != nil) {
            QTMovie *verified = [verifier verifyMovie:movie withOptions:0 error:NULL];
            if (movie == verified) {
                [movie autorelease];
            } else {
                [movie release];
            }
            if (verified != nil) {
                NSURL *url = [NSURL fileURLWithPath:file];
                HSCard *card = (url != nil) ? [HSCard defaultObject] : nil;
                if (card == nil) {
                    break;
                }
                [aCards addObject:card];
                HSStack *stack = [document stack];
                NSUInteger insertIndex = [stack indexOfHyperChild:(aCard != nil ? aCard : [document currentCard])] + 1 + (imported - (firstCard != nil ? 1 : 0));
                [stack insertHyperChild:card atIndex:insertIndex];
                [self importMovie:verified withFileURL:url toCard:card];
                imported++;
            }
        }
    }
    [verifier release];
    [pool release];
    if (!_needCancelImportFiles && imported != 0) {
        if (firstCard == nil) {
            if (registerUndo) {
                [undoManager enableUndoRegistration];
                [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(imported == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
                [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + count];
                [undoManager disableUndoRegistration];
            }
        } else {
            [[[document selectionController] stackController] selectHyperObject:firstCard];
            [document updateChangeCount:0];
        }
        denied = NO;
    } else {
        denied = YES;
    }
    if (count > 20) {
        if (!_needCancelImportFiles) {
            [progress setProgress:100.0];
        } else {
            [self undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + 1];
        }
        [progress endSheet];
        [progress setDelegate:nil];
        [progress release];
    }
    [undoManager enableUndoRegistration];
    if (aDenied != NULL) {
        *aDenied = denied;
    }
    return imported;
}

- (void)importMovie:(id)aMovie withFileURL:(id)aURL asCardWithIndex:(NSUInteger)aIndex toDocument:(id)aDocument
{
    id pvVar1;

    pvVar1 = [HSCard defaultObject];
    [[aDocument stack] insertHyperChild:pvVar1 atIndex:aIndex];
    [self importMovie:aMovie withFileURL:aURL toCard:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002f074 @ 0002f074, 1104 bytes * /

void FUN_0002f074(HSEditorController *self,SEL _cmd,id importMovie,id withFileURL,id toCard)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  undefined *self_00;
  SEL op;
  undefined4 uVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(withFileURL,sel_isFileURL);
  self_00 = cls_HSNewMedia;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(importMovie,sel_movieAttributes);
    uVar5 = *(undefined4 *)PTR_003361c0;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar5);
    pvVar2 = _objc_msgSend(cls_NSNull,sel_null);
    local_14 = (id)0x0;
    if (pvVar2 != pvVar1) {
      local_14 = pvVar1;
    }
    pvVar1 = _objc_msgSend(importMovie,sel_movieFormatRepresentation,uVar5);
    self_00 = cls_HSNewMedia;
    op = sel_mediaWithData_name_type_;
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  else {
    pvVar1 = _objc_msgSend(withFileURL,sel_path);
    local_14 = (id)0x0;
    op = sel_mediaWithPath_;
  }
  pvVar2 = _objc_msgSend(self_00,op,pvVar1);
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSMovieObject,sel_alloc,pvVar1);
  uVar5 = 0;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithMedia_error_,pvVar2,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036262c,uVar5);
  _objc_msgSend(pvVar2,sel_setHyperStartingOnClick_,0);
  pvVar2 = _objc_msgSend(toCard,sel_queryHyperInterface_,&DAT_0036267c);
  pvVar2 = _objc_msgSend(pvVar2,sel_size);
  _objc_msgSend(pvVar1,sel_stretchIfNeededToCardSize_,pvVar2,extraout_EDX);
  pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003626f4);
  fVar4 = extraout_EDX * 0.5;
  pvVar3 = _objc_msgSend(pvVar3,sel_queryGeometryBehaviorApplier);
  uVar5 = 0;
  _objc_msgSend(pvVar3,sel_moveCenterTo_withLayoutGuidingContext_,(float)pvVar2 * 0.5,fVar4,0);
  _objc_msgSend(toCard,sel_addHyperChild_,pvVar1);
  pvVar2 = _objc_msgSend(withFileURL,sel_isFileURL);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(withFileURL,sel_path,pvVar1,fVar4,uVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastPathComponent);
    local_14 = _objc_msgSend(pvVar2,sel_stringByDeletingPathExtension);
  }
  if (local_14 != (id)0x0) {
    _objc_msgSend(toCard,sel_setHyperTitle_,local_14,fVar4,uVar5);
    pvVar1 = local_14;
  }
  _objc_msgSend(toCard,sel_hyperRefreshTitle,pvVar1);
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar5 = *(undefined4 *)PTR_003361a0;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar5);
  if (pvVar1 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSColor,sel_blackColor,uVar5);
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSColor,sel_whiteColor,uVar5);
    if (pvVar2 == (id)0x0) goto LAB_0002f443;
    pvVar3 = _objc_msgSend(cls_NSUnarchiver,sel_unarchiveObjectWithData_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar3,sel_isEqual_,pvVar2);
    if ((char)pvVar1 != '\0') goto LAB_0002f443;
  }
  if (pvVar3 != (id)0x0) {
    _objc_msgSend(toCard,sel_eraseBackgroundWithColor_,pvVar3);
  }
LAB_0002f443:
  pvVar1 = _objc_msgSend(toCard,sel_queryHyperInterface_,&DAT_00362500);
  pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
  pvVar3 = _objc_msgSend(cls_HSNextCardAction,sel_nextCardActionWithFadeTransition);
  _objc_msgSend(pvVar1,sel_replaceHyperActionsForEvent_withAction_,pvVar2,pvVar3);
  return;
}

*/
- (void)importMovie:(id)aMovie withFileURL:(id)aURL toCard:(id)aCard
{
    NSString *name = nil;
    HSNewMedia *media;
    if ([aURL isFileURL]) {
        media = [HSNewMedia mediaWithPath:[aURL path]];
    } else {
        id displayName = [[aMovie movieAttributes] objectForKey:QTMovieDisplayNameAttribute];
        name = displayName != [NSNull null] ? displayName : nil;
        NSData *data = [aMovie movieFormatRepresentation];
        if (data == nil) {
            return;
        }
        media = [HSNewMedia mediaWithData:data name:name type:@"mov"];
    }
    if (media == nil) {
        return;
    }
    HSMovieObject *movieObject = [[[HSMovieObject alloc] initWithMedia:media error:NULL] autorelease];
    if (movieObject == nil) {
        return;
    }
    [[movieObject queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)] setHyperStartingOnClick:NO];
    NSSize cardSize = [[aCard queryHyperInterface:@protocol(HSSizeAttributes)] size];
    [movieObject stretchIfNeededToCardSize:cardSize];
    [[[movieObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveCenterTo:NSMakePoint(cardSize.width * 0.5, cardSize.height * 0.5) withLayoutGuidingContext:nil];
    [aCard addHyperChild:movieObject];
    if ([aURL isFileURL]) {
        name = [[[aURL path] lastPathComponent] stringByDeletingPathExtension];
    }
    if (name != nil) {
        [aCard setHyperTitle:name];
    }
    [aCard hyperRefreshTitle];
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:HSToolEraserColorPreferencesKey];
    NSColor *color;
    if (colorData == nil) {
        color = [NSColor blackColor];
    } else {
        NSColor *white = [NSColor whiteColor];
        if (white == nil) {
            color = nil;
        } else {
            color = [NSUnarchiver unarchiveObjectWithData:colorData];
            if ([color isEqual:white]) {
                color = nil;
            }
        }
    }
    if (color != nil) {
        [aCard eraseBackgroundWithColor:color];
    }
    id actor = [aCard queryHyperInterface:@protocol(HSActor)];
    [actor replaceHyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] withAction:[HSNextCardAction nextCardActionWithFadeTransition]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00036fee @ 00036fee, 2938 bytes * /

uint FUN_00036fee(HSEditorController *self,SEL _cmd,id importImageFiles,id orImages,
                 BOOL *importDenied,id selectedCard,id addedCards)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id self_00;
  id self_01;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar10;
  id pvVar11;
  SEL pcVar12;
  undefined8 in_stack_ffffff7c;
  ulonglong uVar13;
  undefined4 uVar15;
  undefined8 uVar14;
  uint uVar16;
  id local_38;
  id local_34;
  HSEditorController *local_30;
  undefined4 local_2c;
  id local_20;
  id local_1c;
  
  uVar15 = (undefined4)((ulonglong)in_stack_ffffff7c >> 0x20);
  pvVar3 = orImages;
  if (importImageFiles != (id)0x0) {
    pvVar3 = importImageFiles;
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  if ((importImageFiles == (id)0x0 && orImages == (id)0x0) || (pvVar3 == (id)0x0)) {
    local_1c._0_1_ = '\0';
    local_34 = (id)0x0;
    goto LAB_00037b4f;
  }
  local_20 = _objc_msgSend(self,sel_currentDocument);
  if (local_20 == (id)0x0) {
    uVar15 = 0;
    local_20 = _objc_msgSend(self,sel_openUntitledDocumentAndDisplay_error_,1,0);
LAB_000370cd:
    local_38 = _objc_msgSend(local_20,sel_currentCard);
    uVar13 = CONCAT44(uVar15,local_38);
    _objc_msgSend(addedCards,sel_addObject_,local_38);
LAB_00037154:
    pvVar4 = _objc_msgSend(self,sel_currentDocument,uVar13);
    pvVar4 = _objc_msgSend(pvVar4,sel_isInPurePlayerMode);
    if ((char)pvVar4 == '\0') {
      pvVar4 = _objc_msgSend(local_20,sel_undoManager);
      _objc_msgSend(pvVar4,sel_disableUndoRegistration);
      if (pvVar3 < (id)0x15) {
        local_30 = (HSEditorController *)0x0;
      }
      else {
        local_30 = _objc_msgSend(cls_HSExportProgressSheetController,sel_new);
        _objc_msgSend(local_30,sel_setDelegate_,self);
        puVar1 = cls_NSBundle;
        pvVar5 = _objc_msgSend(self,sel_class);
        pvVar5 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar5);
        pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                               &cfstr_ImportImagesSheetProgressDescription,&cfstr_empty,
                               &cfstr_Dialogs);
        _objc_msgSend(local_30,sel_setDescription_,pvVar5);
        _objc_msgSend(local_30,sel_setProgressIndicatorIndeterminate_,0);
        uVar15 = 0;
        _objc_msgSend(local_30,sel_setProgress_,0,0);
        pvVar5 = _objc_msgSend(local_20,sel_windowForSheet);
        uVar13 = CONCAT44(uVar15,pvVar5);
        _objc_msgSend(local_30,sel_beginSheetForWindow_,pvVar5);
      }
      pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_array,uVar13);
      pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_array);
      if (orImages == (id)0x0) {
        if (pvVar3 != (id)0x0) {
          pvVar11 = (id)0x0;
          do {
            pvVar7 = _objc_msgSend(cls_NSImage,sel_alloc,uVar13);
            uVar15 = (undefined4)(uVar13 >> 0x20);
            pvVar8 = _objc_msgSend(importImageFiles,sel_objectAtIndex_,pvVar11);
            pvVar7 = _objc_msgSend(pvVar7,sel_initWithContentsOfFile_,pvVar8);
            uVar13 = CONCAT44(uVar15,pvVar11);
            pvVar8 = _objc_msgSend(importImageFiles,sel_objectAtIndex_);
            if (pvVar7 != (id)0x0) {
              uVar15 = (undefined4)(uVar13 >> 0x20);
              _objc_msgSend(pvVar6,sel_addObject_,pvVar7);
              _objc_msgSend(pvVar7,sel_release);
              uVar13 = CONCAT44(uVar15,pvVar8);
              _objc_msgSend(pvVar5,sel_addObject_,pvVar8);
            }
            pvVar11 = (id)((int)pvVar11 + 1);
          } while (pvVar11 < pvVar3);
        }
      }
      else {
        uVar13 = CONCAT44((int)(uVar13 >> 0x20),orImages);
        _objc_msgSend(pvVar6,sel_addObjectsFromArray_,orImages);
        if (pvVar3 != (id)0x0) {
          pvVar11 = (id)0x0;
          do {
            uVar15 = (undefined4)(uVar13 >> 0x20);
            pvVar7 = _objc_msgSend(orImages,sel_objectAtIndex_,pvVar11);
            pvVar7 = _objc_msgSend(pvVar7,sel_name);
            uVar13 = CONCAT44(uVar15,pvVar7);
            _objc_msgSend(pvVar5,sel_addObject_,pvVar7);
            pvVar11 = (id)((int)pvVar11 + 1);
          } while (pvVar11 < pvVar3);
        }
      }
      puVar1 = PTR_0033607c;
      if (local_38 == (id)0x0) {
        local_1c = (id)0x0;
      }
      else {
        local_1c = *(id *)PTR_0033607c;
        local_2c = *(undefined4 *)(PTR_0033607c + 4);
        for (pvVar11 = (id)0x0; pvVar11 < pvVar3; pvVar11 = (id)((int)pvVar11 + 1)) {
          pvVar7 = _objc_msgSend(pvVar6,sel_objectAtIndex_,pvVar11);
          local_1c = _objc_msgSend(pvVar7,sel_hyperPixelsSize);
          cVar2 = _NSEqualSizes(local_1c,extraout_EDX,*(undefined4 *)puVar1,
                                *(undefined4 *)(puVar1 + 4));
          local_2c = extraout_EDX;
          if (cVar2 == '\0') break;
        }
        cVar2 = _NSEqualSizes(local_1c,local_2c,*(undefined4 *)puVar1,*(undefined4 *)(puVar1 + 4));
        if (cVar2 == '\0') {
          pvVar11 = _objc_msgSend(local_20,sel_stack);
          _objc_msgSend(pvVar11,sel_setHyperCardSize_,local_1c,local_2c);
        }
        puVar1 = cls_NSURL;
        pvVar11 = _objc_msgSend(pvVar5,sel_objectAtIndex_,0);
        pvVar11 = _objc_msgSend(puVar1,sel_fileURLWithPath_,pvVar11);
        pvVar7 = _objc_msgSend(pvVar6,sel_objectAtIndex_,0);
        uVar13 = CONCAT44(pvVar11,pvVar7);
        _objc_msgSend(self,sel_importImage_withFileURL_toDocument_withCard_,pvVar7,pvVar11,local_20,
                      local_38);
        pvVar11 = _objc_msgSend(local_20,sel_cardView);
        _objc_msgSend(pvVar11,sel_autosizePreservingVisibleCenter);
        local_1c = (id)0x1;
      }
      uVar15 = *(undefined4 *)PTR_003361b4;
      local_34 = local_1c;
      while ((local_1c < pvVar3 && ((self->_applicationWillFinishCriticalLaunching[0] & 4) == 0))) {
        pvVar11 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
        pvVar7 = (id)(uVar13 >> 0x20);
        if ((id)0x14 < pvVar3) {
          _objc_msgSend(local_30,sel_setProgress_,
                        (((double)(ZEXT48(local_1c) | 0x4330000000000000) - 4503599627370496.0) *
                        100.0) / ((double)(ZEXT48(pvVar3) | 0x4330000000000000) - 4503599627370496.0
                                 ));
          pvVar8 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
          pvVar7 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x9999999a,0x3fb99999)
          ;
          _objc_msgSend(pvVar8,sel_runMode_beforeDate_,uVar15,pvVar7);
        }
        pvVar8 = _objc_msgSend(pvVar6,sel_objectAtIndex_,local_1c);
        uVar14 = CONCAT44(pvVar7,local_1c);
        pvVar9 = _objc_msgSend(pvVar5,sel_objectAtIndex_,local_1c);
        pvVar7 = local_20;
        if (local_38 == (id)0x0) {
          pvVar9 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar9);
          uVar13 = CONCAT44(pvVar9,pvVar8);
          self_00 = selectedCard;
          pvVar8 = _objc_msgSend(self,
                                 sel_importImage_withFileURL_toDocument_selectedCard_addedCards_,
                                 pvVar8,pvVar9,local_20,selectedCard,addedCards);
          if ((char)pvVar8 != '\0') goto LAB_000378b8;
        }
        else {
          self_00 = _objc_msgSend(cls_HSCard,sel_defaultObject,uVar14);
          self_01 = _objc_msgSend(local_20,sel_stack);
          _objc_msgSend(self_01,sel_addHyperChild_,self_00);
          _objc_msgSend(addedCards,sel_addObject_,self_00);
          _objc_msgSend(self_00,sel_fillBackgroundWithEraserColorIfNeeded);
          pvVar9 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar9);
          uVar13 = CONCAT44(pvVar9,pvVar8);
          _objc_msgSend(self,sel_importImage_withFileURL_toDocument_withCard_,pvVar8,pvVar9,local_20
                        ,self_00);
LAB_000378b8:
          local_34 = (id)((int)local_34 + 1);
        }
        _objc_msgSend(pvVar11,sel_release,uVar13,pvVar7,self_00);
        local_1c = (id)((int)local_1c + 1);
      }
      if (((self->_applicationWillFinishCriticalLaunching[0] & 4) == 0) && (local_34 != (id)0x0)) {
        if (local_38 == (id)0x0) {
          _objc_msgSend(pvVar4,sel_enableUndoRegistration);
          pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
          pcVar10 = &cfstr_Add_Items;
          if (local_34 == (id)0x1) {
            pcVar10 = &cfstr_Add_Item;
          }
          pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,pcVar10,&cfstr_empty,
                                 &cfstr_UndoManager);
          _objc_msgSend(pvVar4,sel_setActionName_,pvVar5);
          pvVar5 = _objc_msgSend(pvVar4,sel_prepareWithInvocationTarget_,self);
          pvVar6 = _objc_msgSend(local_20,sel_stack);
          pvVar6 = _objc_msgSend(pvVar6,sel_indexOfHyperChild_,selectedCard);
          uVar13 = CONCAT44((int)pvVar6 + (int)pvVar3,local_34);
          _objc_msgSend(pvVar5,sel_undoImportingFilesCount_lastAddedCardIndex_,local_34,
                        (int)pvVar6 + (int)pvVar3);
          pvVar5 = pvVar4;
          pcVar12 = sel_disableUndoRegistration;
        }
        else {
          pvVar5 = _objc_msgSend(local_20,sel_selectionController);
          uVar16 = (uint)(uVar13 >> 0x20);
          pvVar5 = _objc_msgSend(pvVar5,sel_stackController);
          _objc_msgSend(pvVar5,sel_selectHyperObject_,local_38);
          uVar13 = (ulonglong)uVar16 << 0x20;
          pvVar5 = local_20;
          pcVar12 = sel_updateChangeCount_;
        }
        _objc_msgSend(pvVar5,pcVar12,uVar13);
        local_1c._0_1_ = '\0';
      }
      else {
        local_1c._0_1_ = '\x01';
      }
      if ((id)0x14 < pvVar3) {
        if ((self->_applicationWillFinishCriticalLaunching[0] & 4) == 0) {
          uVar13 = 0x4059000000000000;
          self = local_30;
          pcVar12 = sel_setProgress_;
        }
        else {
          pvVar3 = _objc_msgSend(local_20,sel_stack,uVar13);
          pvVar3 = _objc_msgSend(pvVar3,sel_indexOfHyperChild_,selectedCard);
          uVar13 = CONCAT44((int)pvVar3 + 1,local_34);
          pcVar12 = sel_undoImportingFilesCount_lastAddedCardIndex_;
        }
        _objc_msgSend(self,pcVar12,uVar13);
        _objc_msgSend(local_30,sel_endSheet);
        uVar13 = uVar13 & 0xffffffff00000000;
        _objc_msgSend(local_30,sel_setDelegate_,0);
        _objc_msgSend(local_30,sel_release);
      }
      _objc_msgSend(pvVar4,sel_enableUndoRegistration,uVar13);
      goto LAB_00037b4f;
    }
  }
  else {
    pvVar4 = _objc_msgSend(local_20,sel_isNewAndNotChanged);
    if ((char)pvVar4 != '\0') goto LAB_000370cd;
    pvVar4 = _objc_msgSend(local_20,sel_stack);
    uVar13 = CONCAT44(uVar15,&DAT_00362708);
    pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00362708);
    pvVar4 = _objc_msgSend(pvVar4,sel_isStackProtected);
    if ((char)pvVar4 == '\0') {
      local_38 = (id)0x0;
      goto LAB_00037154;
    }
  }
  local_1c._0_1_ = '\x01';
  local_34 = (id)0x0;
LAB_00037b4f:
  if (importDenied != (BOOL *)0x0) {
    *importDenied = (BOOL)local_1c;
  }
  return (uint)local_34;
}

*/
- (NSUInteger)importImageFiles:(id)aFiles orImages:(id)aImages importDenied:(BOOL *)aDenied selectedCard:(id)aCard addedCards:(id)aCards
{
    NSUInteger count = [(aFiles != nil ? aFiles : aImages) count];
    BOOL denied = NO;
    NSUInteger imported = 0;
    if ((aFiles == nil && aImages == nil) || count == 0) {
        if (aDenied != NULL) {
            *aDenied = NO;
        }
        return 0;
    }
    HSEditorDocument *document = [self currentDocument];
    HSCard *firstCard = nil;
    BOOL proceed = NO;
    if (document == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if ([document isNewAndNotChanged]) {
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if (![[[document stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] isStackProtected]) {
        proceed = YES;
    }
    if (!proceed || [[self currentDocument] isInPurePlayerMode]) {
        if (aDenied != NULL) {
            *aDenied = YES;
        }
        return 0;
    }
    NSUndoManager *undoManager = [document undoManager];
    [undoManager disableUndoRegistration];
    HSExportProgressSheetController *progress = nil;
    if (count > 20) {
        progress = [HSExportProgressSheetController new];
        [progress setDelegate:self];
        [progress setDescription:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportImagesSheetProgressDescription" value:@"" table:@"Dialogs"]];
        [progress setProgressIndicatorIndeterminate:NO];
        [progress setProgress:0];
        [progress beginSheetForWindow:[document windowForSheet]];
    }
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    if (aImages == nil) {
        for (NSUInteger i = 0; i < count; i++) {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:[aFiles objectAtIndex:i]];
            NSString *name = [aFiles objectAtIndex:i];
            if (image != nil) {
                [images addObject:image];
                [image release];
                [names addObject:name];
            }
        }
    } else {
        [images addObjectsFromArray:aImages];
        for (NSUInteger i = 0; i < count; i++) {
            [names addObject:[[aImages objectAtIndex:i] name]];
        }
    }
    NSUInteger start = 0;
    if (firstCard != nil) {
        NSSize size = NSZeroSize;
        for (NSUInteger i = 0; i < count; i++) {
            size = [[images objectAtIndex:i] hyperPixelsSize];
            if (!NSEqualSizes(size, NSZeroSize)) {
                break;
            }
        }
        if (!NSEqualSizes(size, NSZeroSize)) {
            [[document stack] setHyperCardSize:size];
        }
        [self importImage:[images objectAtIndex:0] withFileURL:[NSURL fileURLWithPath:[names objectAtIndex:0]] toDocument:document withCard:firstCard];
        [[document cardView] autosizePreservingVisibleCenter];
        start = 1;
    }
    imported = start;
    for (NSUInteger i = start; i < count && !_needCancelImportFiles; i++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        if (count > 20) {
            [progress setProgress:((double)i * 100.0) / (double)count];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        id image = [images objectAtIndex:i];
        NSString *name = [names objectAtIndex:i];
        if (firstCard == nil) {
            if ([self importImage:image withFileURL:[NSURL fileURLWithPath:name] toDocument:document selectedCard:aCard addedCards:aCards]) {
                imported++;
            }
        } else {
            HSCard *card = [HSCard defaultObject];
            [[document stack] addHyperChild:card];
            [aCards addObject:card];
            [card fillBackgroundWithEraserColorIfNeeded];
            [self importImage:image withFileURL:[NSURL fileURLWithPath:name] toDocument:document withCard:card];
            imported++;
        }
        [pool release];
    }
    if (!_needCancelImportFiles && imported != 0) {
        if (firstCard == nil) {
            [undoManager enableUndoRegistration];
            [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(imported == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
            [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + count];
            [undoManager disableUndoRegistration];
        } else {
            [[[document selectionController] stackController] selectHyperObject:firstCard];
            [document updateChangeCount:0];
        }
        denied = NO;
    } else {
        denied = YES;
    }
    if (count > 20) {
        if (!_needCancelImportFiles) {
            [progress setProgress:100.0];
        } else {
            [self undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + 1];
        }
        [progress endSheet];
        [progress setDelegate:nil];
        [progress release];
    }
    [undoManager enableUndoRegistration];
    if (aDenied != NULL) {
        *aDenied = denied;
    }
    return imported;
}

- (BOOL)importImage:(id)aImage withFileURL:(id)aURL toDocument:(id)aDocument
{
    return (BOOL)[self importImage:aImage withFileURL:aURL toDocument:aDocument selectedCard:nil addedCards:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ef15 @ 0002ef15, 273 bytes * /

void FUN_0002ef15(HSEditorController *self,SEL _cmd,id importImage,id withFileURL,
                 uint asCardWithIndex,id toDocument)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  uint uVar4;
  
  self_00 = _objc_msgSend(cls_HSCard,sel_defaultObject);
  pvVar1 = _objc_msgSend(toDocument,sel_stack);
  pvVar3 = self_00;
  uVar4 = asCardWithIndex;
  _objc_msgSend(pvVar1,sel_insertHyperChild_atIndex_,self_00,asCardWithIndex);
  if (asCardWithIndex == 0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(toDocument,sel_stack,pvVar3,uVar4);
    pvVar3 = (id)(asCardWithIndex - 1);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,pvVar3);
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_isGroupCard,pvVar3,uVar4);
  op = sel_fillBackgroundWithEraserColorIfNeeded;
  if ((char)pvVar2 != '\0') {
    pvVar3 = _objc_msgSend(pvVar1,sel_cardGroupUID,pvVar3,uVar4);
    op = sel_makeGroupCardWithGroupUID_;
  }
  _objc_msgSend(self_00,op,pvVar3,uVar4);
  _objc_msgSend(self,sel_importImage_withFileURL_toDocument_withCard_,importImage,withFileURL,
                toDocument,self_00);
  return;
}

*/
- (void)importImage:(id)aImage withFileURL:(id)aURL asCardWithIndex:(NSUInteger)aIndex toDocument:(id)aDocument
{
    HSCard *card = [HSCard defaultObject];
    [[aDocument stack] insertHyperChild:card atIndex:aIndex];
    HSCard *previous = (aIndex == 0) ? nil : [[aDocument stack] hyperChildAtIndex:aIndex - 1];
    if ([previous isGroupCard]) {
        [card makeGroupCardWithGroupUID:[previous cardGroupUID]];
    } else {
        [card fillBackgroundWithEraserColorIfNeeded];
    }
    [self importImage:aImage withFileURL:aURL toDocument:aDocument withCard:card];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ed99 @ 0002ed99, 380 bytes * /

BOOL FUN_0002ed99(HSEditorController *self,SEL _cmd,id importImage,id withFileURL,id toDocument,
                 id selectedCard,id addedCards)

{
  id self_00;
  id self_01;
  id pvVar1;
  int iVar2;
  id pvVar3;
  undefined *self_02;
  SEL op;
  undefined *local_14;
  
  local_14 = toDocument;
  self_02 = cls_HSCard;
  op = sel_defaultObject;
  if (toDocument == (id)0x0) {
    local_14 = _objc_msgSend(self,sel_openUntitledDocumentAndDisplay_error_,1,0);
    self_02 = local_14;
    op = sel_currentCard;
  }
  self_00 = _objc_msgSend(self_02,op);
  pvVar3 = self_00;
  _objc_msgSend(addedCards,sel_addObject_,self_00);
  self_01 = _objc_msgSend(local_14,sel_stack);
  pvVar1 = selectedCard;
  if (selectedCard == (id)0x0) {
    pvVar1 = _objc_msgSend(local_14,sel_currentCard,pvVar3);
  }
  pvVar1 = _objc_msgSend(self_01,sel_indexOfHyperChild_,pvVar1);
  iVar2 = (int)pvVar1 + 1;
  pvVar1 = self_00;
  _objc_msgSend(self_01,sel_insertHyperChild_atIndex_,self_00,iVar2);
  pvVar3 = _objc_msgSend(selectedCard,sel_isGroupCard);
  if ((char)pvVar3 != '\0') {
    pvVar1 = _objc_msgSend(selectedCard,sel_cardGroupUID,pvVar1,iVar2);
    _objc_msgSend(self_00,sel_makeGroupCardWithGroupUID_,pvVar1);
  }
  _objc_msgSend(self_00,sel_fillBackgroundWithEraserColorIfNeeded,pvVar1,iVar2);
  _objc_msgSend(self,sel_importImage_withFileURL_toDocument_withCard_,importImage,withFileURL,
                local_14,self_00);
  return '\x01';
}

*/
- (BOOL)importImage:(id)aImage withFileURL:(id)aURL toDocument:(id)aDocument selectedCard:(id)aCard addedCards:(id)aCards
{
    HSEditorDocument *document = aDocument;
    HSCard *card;
    if (document == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        card = [document currentCard];
    } else {
        card = [HSCard defaultObject];
    }
    [aCards addObject:card];
    HSStack *stack = [document stack];
    NSUInteger index = [stack indexOfHyperChild:(aCard != nil ? aCard : [document currentCard])] + 1;
    [stack insertHyperChild:card atIndex:index];
    if ([aCard isGroupCard]) {
        [card makeGroupCardWithGroupUID:[aCard cardGroupUID]];
    }
    [card fillBackgroundWithEraserColorIfNeeded];
    [self importImage:aImage withFileURL:aURL toDocument:document withCard:card];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00037b68 @ 00037b68, 2615 bytes * /

void FUN_00037b68(HSEditorController *self,SEL _cmd,id importImage,id withFileURL,id toDocument,
                 id withCard)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  float extraout_EDX_04;
  float extraout_EDX_05;
  float extraout_EDX_06;
  bool bVar5;
  bool bVar6;
  longdouble lVar7;
  longdouble lVar8;
  float fVar9;
  SEL pcVar10;
  undefined4 uVar11;
  float fVar12;
  undefined4 uVar13;
  undefined4 uVar14;
  undefined4 uVar15;
  undefined4 uVar16;
  undefined4 uVar17;
  float local_38;
  float local_30;
  id local_2c;
  float local_20;
  id local_14;
  
  pvVar2 = _objc_msgSend(withFileURL,sel_isFileURL);
  pvVar3 = importImage;
  pcVar10 = sel_name;
  if ((char)pvVar2 != '\0') {
    pvVar3 = _objc_msgSend(withFileURL,sel_path);
    pvVar3 = _objc_msgSend(pvVar3,sel_lastPathComponent);
    pcVar10 = sel_stringByDeletingPathExtension;
  }
  pvVar3 = _objc_msgSend(pvVar3,pcVar10);
  if (pvVar3 != (id)0x0) {
    _objc_msgSend(withCard,sel_setHyperTitle_,pvVar3);
  }
  _objc_msgSend(withCard,sel_hyperRefreshTitle);
  pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar11 = *(undefined4 *)PTR_00336180;
  pvVar2 = _objc_msgSend(pvVar3,sel_boolForKey_,uVar11);
  if (((char)pvVar2 != '\0') &&
     (pvVar2 = _objc_msgSend(withCard,sel_isGroupCard,uVar11),
     pcVar10 = sel_importImage_withFileURL_toBackgroundOfCard_, (char)pvVar2 == '\0'))
  goto LAB_00038500;
  pvVar4 = _objc_msgSend(withFileURL,sel_isFileURL,uVar11);
  puVar1 = cls_HSNewMedia;
  pcVar10 = sel_mediaWithImage_;
  pvVar2 = importImage;
  if ((char)pvVar4 != '\0') {
    pvVar2 = _objc_msgSend(withFileURL,sel_path,uVar11);
    pcVar10 = sel_mediaWithPath_;
  }
  pvVar4 = _objc_msgSend(puVar1,pcVar10,pvVar2);
  if (pvVar4 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(cls_HSImageObject,sel_alloc,pvVar2);
  self = _objc_msgSend(pvVar2,sel_initWithMedia_,pvVar4);
  if (self == (HSEditorController *)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(self,sel_queryHyperInterface_,&DAT_00362848);
  pvVar4 = _objc_msgSend(pvVar3,sel_boolForKey_,*(undefined4 *)PTR_00336188);
  _objc_msgSend(pvVar2,sel_setHyperShadowEnabled_,(int)(char)pvVar4);
  pvVar2 = _objc_msgSend(self,sel_queryHyperInterface_,&DAT_003626f4);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
  if (pvVar2 == (id)0x0) goto LAB_00038354;
  uVar11 = *(undefined4 *)PTR_00336190;
  pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,uVar11);
  puVar1 = PTR_00336078;
  local_2c = *(id *)PTR_00336078;
  local_20 = *(float *)(PTR_00336078 + 4);
  if (pvVar4 == (id)0x0) {
switchD_00037e26_caseD_3:
    pvVar4 = _objc_msgSend(toDocument,sel_stack,uVar11);
    local_14 = _objc_msgSend(pvVar4,sel_hyperCardSize);
    fVar12 = *(float *)PTR_00336074;
    local_20 = *(float *)(PTR_00336074 + 4);
    pvVar4 = _objc_msgSend(importImage,sel_hyperPixelsSize);
    fVar9 = (float)local_14 * 0.5;
    if (((float)local_14 < (float)pvVar4) || (extraout_EDX_05 < extraout_EDX_06)) {
      local_38 = (float)pvVar4 / extraout_EDX_06;
      fVar12 = *(float *)puVar1;
      local_20 = *(float *)(puVar1 + 4);
      if (local_38 <= (float)local_14 / extraout_EDX_05) {
        local_14 = (id)(local_38 * extraout_EDX_05);
        local_38 = extraout_EDX_05;
      }
      else {
        local_38 = (float)local_14 / local_38;
      }
      local_20 = ((extraout_EDX_05 * 0.5 + local_20) - (local_38 * 0.5 + local_20)) + local_20;
      local_2c = (id)(((fVar9 + fVar12) - ((float)local_14 * 0.5 + fVar12)) + fVar12);
      local_30 = local_38;
    }
    else {
      local_20 = ((extraout_EDX_05 * 0.5 + local_20) - (extraout_EDX_06 * 0.5 + local_20)) +
                 local_20;
      local_2c = (id)(((fVar9 + fVar12) - ((float)pvVar4 * 0.5 + fVar12)) + fVar12);
      local_30 = extraout_EDX_06;
      local_14 = pvVar4;
    }
    goto LAB_00038206;
  }
  pvVar4 = _objc_msgSend(pvVar4,sel_intValue,uVar11);
  switch(pvVar4) {
  case (id)0x0:
    local_14 = _objc_msgSend(importImage,sel_hyperPixelsSize,uVar11);
    pvVar4 = _objc_msgSend(toDocument,sel_stack);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperCardSize);
    local_20 = local_20 +
               ((extraout_EDX_00 * 0.5 + *(float *)(puVar1 + 4)) - (extraout_EDX * 0.5 + local_20));
    local_2c = (id)((float)local_2c +
                   (((float)pvVar4 * 0.5 + *(float *)puVar1) -
                   ((float)local_14 * 0.5 + (float)local_2c)));
    local_30 = extraout_EDX;
    break;
  case (id)0x1:
    pvVar4 = _objc_msgSend(toDocument,sel_stack,uVar11);
    local_2c = _objc_msgSend(pvVar4,sel_hyperCardSize);
    local_14 = _objc_msgSend(importImage,sel_hyperPixelsSize);
    local_14 = (id)((float)local_14 / extraout_EDX_02);
    bVar6 = (float)local_14 == (float)local_2c / extraout_EDX_01;
    bVar5 = (float)local_14 < (float)local_2c / extraout_EDX_01;
    local_20 = extraout_EDX_01;
    goto LAB_00037f6a;
  case (id)0x2:
    pvVar4 = _objc_msgSend(toDocument,sel_stack,uVar11);
    local_2c = _objc_msgSend(pvVar4,sel_hyperCardSize);
    local_14 = _objc_msgSend(importImage,sel_hyperPixelsSize);
    local_14 = (id)((float)local_14 / extraout_EDX_04);
    bVar6 = (float)local_2c / extraout_EDX_03 == (float)local_14;
    bVar5 = (float)local_2c / extraout_EDX_03 < (float)local_14;
    local_20 = extraout_EDX_03;
LAB_00037f6a:
    fVar12 = *(float *)puVar1;
    fVar9 = *(float *)(puVar1 + 4);
    if (bVar5 || bVar6) {
      local_14 = (id)((float)local_14 * local_20);
      local_30 = local_20;
    }
    else {
      local_30 = (float)local_2c / (float)local_14;
      local_14 = local_2c;
    }
    local_20 = ((local_20 * 0.5 + fVar9) - (local_30 * 0.5 + fVar9)) + fVar9;
    local_2c = (id)((((float)local_2c * 0.5 + fVar12) - ((float)local_14 * 0.5 + fVar12)) + fVar12);
    break;
  case (id)0x3:
    goto switchD_00037e26_caseD_3;
  default:
    local_30 = *(float *)(puVar1 + 0xc);
    local_14 = *(id *)(puVar1 + 8);
  }
LAB_00038206:
  lVar7 = (longdouble)_roundf(local_2c);
  lVar8 = (longdouble)_roundf(local_20);
  uVar11 = *(undefined4 *)(PTR_00336074 + 4);
  uVar17 = 0;
  uVar16 = 0;
  uVar15 = 2;
  uVar14 = 1;
  _objc_msgSend(pvVar2,
                sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                ,local_14,local_30,*(undefined4 *)PTR_00336074,uVar11,1,2,0,0);
  fVar12 = (float)lVar8;
  pvVar4 = (id)(float)lVar7;
  uVar13 = 0;
  _objc_msgSend(pvVar2,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,pvVar4,fVar12,0);
  if (withFileURL == (id)0x0) {
    pvVar2 = (id)0x0;
    withFileURL = pvVar4;
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSEditorCardViewDragHelper,sel_commentsForDroppedObjectWithURL_,
                           withFileURL,fVar12,uVar13,uVar11,uVar14,uVar15,uVar16,uVar17);
  }
  pvVar4 = _objc_msgSend(pvVar2,sel_length,withFileURL,fVar12,uVar13,uVar11,uVar14,uVar15,uVar16,
                         uVar17);
  if (pvVar4 != (id)0x0) {
    pvVar4 = _objc_msgSend(self,sel_queryHyperInterface_,&DAT_00362604,fVar12,uVar13,uVar11,uVar14,
                           uVar15,uVar16,uVar17);
    pvVar2 = _objc_msgSend(pvVar2,sel_copy);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(pvVar4,sel_setHyperComments_,pvVar2);
  }
LAB_00038354:
  uVar11 = *(undefined4 *)PTR_00336184;
  pvVar3 = _objc_msgSend(pvVar3,sel_boolForKey_,uVar11);
  if ((char)pvVar3 != '\0') {
    pvVar3 = _objc_msgSend(self,sel_media,uVar11);
    pvVar3 = _objc_msgSend(pvVar3,sel_GPSDictionary);
    if ((((pvVar3 != (id)0x0) &&
         (pvVar2 = _objc_msgSend(pvVar3,sel_objectForKey_,*(undefined4 *)PTR_003361d4),
         pvVar2 != (id)0x0)) &&
        (pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,*(undefined4 *)PTR_003361d8),
        pvVar3 != (id)0x0)) &&
       (((pvVar4 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,
                                 &cfstr_http___maps_google_com__q_______spn_0_05_0_05_t_,pvVar2,
                                 pvVar3), pvVar4 != (id)0x0 &&
         (pvVar4 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar4,pvVar2,pvVar3),
         pvVar4 != (id)0x0)) &&
        (pvVar4 = _objc_msgSend(cls_HSGoToURLAction,sel_actionWithURL_,pvVar4,pvVar2,pvVar3),
        pvVar4 != (id)0x0)))) {
      pvVar3 = _objc_msgSend(self,sel_queryHyperInterface_,&DAT_00362500,pvVar2,pvVar3);
      pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
      _objc_msgSend(pvVar3,sel_addHyperAction_forEvent_,pvVar4,pvVar2);
    }
  }
  importImage = self;
  _objc_msgSend(withCard,sel_addHyperChild_,self);
  pcVar10 = sel_release;
LAB_00038500:
  _objc_msgSend(self,pcVar10,importImage);
  pvVar3 = _objc_msgSend(withCard,sel_isGroupCard);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(withCard,sel_queryHyperInterface_,&DAT_00362500);
    pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
    pvVar4 = _objc_msgSend(cls_HSNextCardAction,sel_nextCardActionWithFadeTransition);
    _objc_msgSend(pvVar3,sel_replaceHyperActionsForEvent_withAction_,pvVar2,pvVar4);
  }
  return;
}

*/
- (void)importImage:(id)aImage withFileURL:(id)aURL toDocument:(id)aDocument withCard:(id)aCard
{
    NSString *name = [aURL isFileURL] ? [[[aURL path] lastPathComponent] stringByDeletingPathExtension] : [aImage name];
    if (name != nil) {
        [aCard setHyperTitle:name];
    }
    [aCard hyperRefreshTitle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:HSImportImageAsBackgroundKey] && ![aCard isGroupCard]) {
        [self importImage:aImage withFileURL:aURL toBackgroundOfCard:aCard];
    } else {
        id media = [aURL isFileURL] ? [HSNewMedia mediaWithPath:[aURL path]] : [HSNewMedia mediaWithImage:aImage];
        if (media == nil) {
            return;
        }
        HSImageObject *object = [[HSImageObject alloc] initWithMedia:media];
        if (object == nil) {
            return;
        }
        [[object queryHyperInterface:@protocol(HSMutableShadowAttributes)] setHyperShadowEnabled:[defaults boolForKey:HSImportImageWithShadowKey]];
        id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            NSSize cardSize = [[aDocument stack] hyperCardSize];
            NSSize pixelsSize = [aImage hyperPixelsSize];
            NSRect frame = NSZeroRect;
            id layout = [defaults objectForKey:HSImportedImageLayoutKey];
            NSInteger layoutValue = (layout != nil) ? [layout intValue] : 3;
            switch (layoutValue) {
                case 0:
                    frame.size = pixelsSize;
                    frame.origin.x += (cardSize.width * 0.5 + 0) - (pixelsSize.width * 0.5 + 0);
                    frame.origin.y += (cardSize.height * 0.5 + 0) - (pixelsSize.height * 0.5 + 0);
                    break;
                case 1:
                case 2: {
                    CGFloat aspect = pixelsSize.width / pixelsSize.height;
                    CGFloat cardAspect = cardSize.width / cardSize.height;
                    BOOL heightFills = (layoutValue == 1) ? (aspect <= cardAspect) : (cardAspect <= aspect);
                    if (heightFills) {
                        frame.size.width = aspect * cardSize.height;
                        frame.size.height = cardSize.height;
                    } else {
                        frame.size.height = cardSize.width / aspect;
                        frame.size.width = cardSize.width;
                    }
                    frame.origin.y = (cardSize.height * 0.5) - (frame.size.height * 0.5);
                    frame.origin.x = (cardSize.width * 0.5) - (frame.size.width * 0.5);
                    break;
                }
                case 3:
                default:
                    if (layoutValue != 3) {
                        frame = NSZeroRect;
                        break;
                    }
                    if (cardSize.width < pixelsSize.width || cardSize.height < pixelsSize.height) {
                        CGFloat aspect = pixelsSize.width / pixelsSize.height;
                        if (aspect <= cardSize.width / cardSize.height) {
                            frame.size.width = aspect * cardSize.height;
                            frame.size.height = cardSize.height;
                        } else {
                            frame.size.height = cardSize.width / aspect;
                            frame.size.width = cardSize.width;
                        }
                    } else {
                        frame.size = pixelsSize;
                    }
                    frame.origin.y = (cardSize.height * 0.5) - (frame.size.height * 0.5);
                    frame.origin.x = (cardSize.width * 0.5) - (frame.size.width * 0.5);
                    break;
            }
            [applier resizeFrameTo:frame.size aboutRelativePoint:NSZeroPoint followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
            [applier moveFrameBoundingRectOriginTo:NSMakePoint(roundf(frame.origin.x), roundf(frame.origin.y)) withLayoutGuidingContext:nil];
            NSString *comments = (aURL == nil) ? nil : [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:aURL];
            if ([comments length] != 0) {
                [[object queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
            }
        }
        if ([defaults boolForKey:HSImportImageWithGoogleMapsConnectionKey]) {
            NSDictionary *gps = [[object media] GPSDictionary];
            id latitude;
            id longitude;
            if (gps != nil && (latitude = [gps objectForKey:(id)kCGImagePropertyGPSLatitude]) != nil && (longitude = [gps objectForKey:(id)kCGImagePropertyGPSLongitude]) != nil) {
                NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@&spn=0.05,0.05&t=h&om=1&hl=en", latitude, longitude];
                NSURL *mapsURL = (urlString != nil) ? [NSURL URLWithString:urlString] : nil;
                id action = (mapsURL != nil) ? [HSGoToURLAction actionWithURL:mapsURL] : nil;
                if (action != nil) {
                    [[object queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
                }
            }
        }
        [aCard addHyperChild:object];
        [object release];
    }
    if (![aCard isGroupCard]) {
        [[aCard queryHyperInterface:@protocol(HSActor)] replaceHyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] withAction:[HSNextCardAction nextCardActionWithFadeTransition]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ec4e @ 0002ec4e, 331 bytes * /

void FUN_0002ec4e(HSEditorController *self,SEL _cmd,id importImage,id withFileURL,
                 id toBackgroundOfCard)

{
  id pvVar1;
  undefined4 uVar2;
  id pvVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar2 = *(undefined4 *)PTR_00336190;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar2);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue,uVar2);
    if (pvVar1 == (id)0x1) {
      uVar2 = 0;
      goto LAB_0002ecd5;
    }
    if (pvVar1 == (id)0x2) {
      uVar2 = 2;
      goto LAB_0002ecd5;
    }
    if (pvVar1 != (id)0x3) {
      uVar2 = 4;
      goto LAB_0002ecd5;
    }
  }
  uVar2 = 6;
LAB_0002ecd5:
  uVar4 = 1;
  _objc_msgSend(toBackgroundOfCard,sel_importBackgroundFromImage_imageScalingOption_eraseBackground_
                ,importImage,uVar2,1);
  if (withFileURL == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSEditorCardViewDragHelper,sel_commentsForDroppedObjectWithURL_,
                           withFileURL,uVar2,uVar4);
    importImage = withFileURL;
  }
  pvVar3 = _objc_msgSend(pvVar1,sel_length,importImage,uVar2,uVar4);
  if (pvVar3 != (id)0x0) {
    pvVar3 = _objc_msgSend(toBackgroundOfCard,sel_queryHyperInterface_,&DAT_00362604,uVar2,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_copy);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    _objc_msgSend(pvVar3,sel_setHyperComments_,pvVar1);
  }
  return;
}

*/
- (void)importImage:(id)aImage withFileURL:(id)aURL toBackgroundOfCard:(id)aCard
{
    NSInteger option = 6;
    id layout = [[NSUserDefaults standardUserDefaults] objectForKey:HSImportedImageLayoutKey];
    if (layout != nil) {
        switch ([layout intValue]) {
            case 1: option = 0; break;
            case 2: option = 2; break;
            case 3: option = 6; break;
            default: option = 4; break;
        }
    }
    [aCard importBackgroundFromImage:aImage imageScalingOption:option eraseBackground:YES];
    NSString *comments = (aURL == nil) ? nil : [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:aURL];
    if ([comments length] != 0) {
        [[aCard queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ea2b @ 0002ea2b, 547 bytes * /

BOOL FUN_0002ea2b(HSEditorController *self,SEL _cmd,id canImportFileAtPath,BOOL showAlert)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int extraout_EDX;
  cfstringStruct *pcVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  uVar6 = 1;
  pvVar1 = _objc_msgSend(pvVar1,sel_fileAttributesAtPath_traverseLink_,canImportFileAtPath,1);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_fileSize,canImportFileAtPath,uVar6);
    if (extraout_EDX == 0 && -1 < (int)pvVar1) {
      return '\x01';
    }
    if (showAlert != '\0') {
      pvVar1 = _objc_msgSend(cls_NSAlert,sel_alloc,canImportFileAtPath,uVar6);
      pvVar1 = _objc_msgSend(pvVar1,sel_init);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      if (pvVar1 != (id)0x0) {
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar8 = &cfstr_Alerts;
        pcVar7 = &cfstr_empty;
        pcVar5 = &cfstr_HSCannotAddFileTitle;
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                               &cfstr_HSCannotAddFileTitle,&cfstr_empty,&cfstr_Alerts);
        if (pvVar2 != (id)0x0) {
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar5,pcVar7,
                                 pcVar8);
          pcVar8 = &cfstr_Alerts;
          pcVar7 = &cfstr_empty;
          pcVar5 = &cfstr_HSCannotAddFileText;
          pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                                 &cfstr_HSCannotAddFileText,&cfstr_empty,&cfstr_Alerts);
          if (pvVar3 != (id)0x0) {
            pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar5,pcVar7
                                   ,pcVar8,pvVar3);
            pcVar8 = &cfstr_Alerts;
            pcVar7 = &cfstr_empty;
            pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_OK,
                                   &cfstr_empty,&cfstr_Alerts);
            if (pvVar4 != (id)0x0) {
              _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2,pcVar7,pcVar8);
              _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar3);
              _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar4);
              _objc_msgSend(pvVar1,sel_runModal);
              return '\0';
            }
          }
        }
      }
    }
  }
  return '\0';
}

*/
- (BOOL)canImportFileAtPath:(id)aPath showAlert:(BOOL)aAlert
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[aPath stringByResolvingSymlinksInPath] error:NULL];
    if (attributes == nil) {
        return NO;
    }
    if ([attributes fileSize] <= INT_MAX) {
        return YES;
    }
    if (aAlert) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *title = [provider localizedStringForKey:@"HSCannotAddFileTitle" value:@"" table:@"Alerts"];
        NSString *text = [provider localizedStringForKey:@"HSCannotAddFileText" value:@"" table:@"Alerts"];
        NSString *button = [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        if (alert != nil && title != nil && text != nil && button != nil) {
            [alert setMessageText:title];
            [alert setInformativeText:text];
            [alert addButtonWithTitle:button];
            [alert runModal];
        }
    }
    return NO;
}

- (BOOL)shouldCancelWindowRestoration
{
    return ![self HSEditorController_validateApplicationLicenseWithInteraction:NO forced:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000385b0 @ 000385b0, 2332 bytes * /

void FUN_000385b0(HSEditorController *self,SEL _cmd,id chooseFilesForImportWithFiles,id *images,
                 id *movies,id *otherMediaOrText)

{
  int iVar1;
  id self_00;
  id self_01;
  id self_02;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  SEL op;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  char *pcVar9;
  undefined4 uVar10;
  id local_100;
  id local_fc;
  id local_f8;
  id local_f4;
  id local_ec;
  char local_d7;
  char local_d6;
  char local_d5;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  cfstringStruct local_74;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  char local_50 [64];
  
  self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  self_01 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  self_02 = _objc_msgSend(cls_NSMutableArray,sel_new);
  local_d5 = '\0';
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  uVar10 = 0x10;
  local_f4 = _objc_msgSend(chooseFilesForImportWithFiles,
                           sel_countByEnumeratingWithState_objects_count_,&local_d4,local_b4,0x10);
  if (local_f4 != (id)0x0) {
    iVar1 = *local_cc;
    do {
      local_ec = (id)0x0;
      do {
        if (iVar1 != *local_cc) {
          _objc_enumerationMutation(chooseFilesForImportWithFiles);
        }
        pcVar8 = *(cfstringStruct **)(local_d0 + (int)local_ec * 4);
        pcVar9 = &local_d5;
        pvVar2 = _objc_msgSend(self_00,sel_fileExistsAtPath_isDirectory_,pcVar8,pcVar9,uVar10);
        if ((char)pvVar2 != '\0') {
          if (local_d5 != '\0') {
            pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pcVar8,pcVar9);
            pcVar9 = (char *)0x0;
            pvVar2 = _objc_msgSend(self,sel_typeForContentsOfURL_error_,pvVar2,0);
            pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_HSKeynoteDocumentType);
            if (((char)pvVar2 == '\0') &&
               (pvVar2 = _objc_msgSend(self_01,sel_isFilePackageAtPath_,pcVar8,pcVar9),
               (char)pvVar2 == '\0')) {
              pcVar7 = pcVar8;
              pvVar2 = _objc_msgSend(self_00,sel_enumeratorAtPath_,pcVar8,pcVar9);
              while (pvVar3 = _objc_msgSend(pvVar2,sel_nextObject,pcVar7,pcVar9), pvVar3 != (id)0x0)
              {
                pvVar4 = _objc_msgSend(pvVar3,sel_substringToIndex_,1,pcVar9);
                pcVar7 = &cfstr__;
                pvVar4 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr__);
                if ((char)pvVar4 == '\0') {
                  local_d6 = '\0';
                  pcVar5 = _objc_msgSend(pcVar8,sel_stringByAppendingPathComponent_,pvVar3);
                  pcVar9 = &local_d6;
                  pcVar7 = pcVar5;
                  pvVar3 = _objc_msgSend(self_00,sel_fileExistsAtPath_isDirectory_,pcVar5,pcVar9);
                  if (((char)pvVar3 != '\0') && (local_d6 == '\0')) {
                    _objc_msgSend(self_02,sel_addObject_,pcVar5,pcVar9);
                    pcVar7 = pcVar5;
                  }
                }
              }
              goto LAB_00038907;
            }
          }
          if (local_d5 == '\0') {
            _objc_msgSend(self_02,sel_addObject_,pcVar8,pcVar9);
          }
        }
LAB_00038907:
        local_ec = (id)((int)local_ec + 1);
      } while (local_ec < local_f4);
      uVar10 = 0x10;
      local_f4 = _objc_msgSend(chooseFilesForImportWithFiles,
                               sel_countByEnumeratingWithState_objects_count_,&local_d4,local_b4,
                               0x10);
    } while (local_f4 != (id)0x0);
  }
  local_74.field0_0x0 = 0;
  local_74.field1_0x4 = 0;
  local_74.field2_0x8 = (undefined *)0x0;
  local_74.field3_0xc = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  pcVar9 = local_50;
  pcVar8 = &local_74;
  uVar10 = 0x10;
  local_100 = _objc_msgSend(self_02,sel_countByEnumeratingWithState_objects_count_,pcVar8,pcVar9,
                            0x10);
  if (local_100 == (id)0x0) {
    local_fc = (id)0x0;
    local_f8 = (id)0x0;
    local_ec = (id)0x0;
  }
  else {
    iVar1 = *(int *)local_74.field2_0x8;
    local_fc = (id)0x0;
    local_f8 = (id)0x0;
    local_ec = (id)0x0;
    do {
      local_f4 = (id)0x0;
      do {
        if (iVar1 != *(int *)local_74.field2_0x8) {
          _objc_enumerationMutation(self_02);
        }
        pcVar7 = *(cfstringStruct **)(local_74.field1_0x4 + (int)local_f4 * 4);
        pvVar2 = _objc_msgSend(pcVar7,sel_pathExtension,pcVar8,pcVar9,uVar10);
        pcVar9 = (char *)0x1;
        local_f4 = (id)((int)local_f4 + 1);
        pvVar3 = _objc_msgSend(pvVar2,sel_compare_options_,&cfstr_rtfd);
        pcVar8 = pcVar7;
        if (pvVar3 == (id)0x0) {
          pvVar2 = _objc_msgSend(self_00,sel_enumeratorAtPath_,pcVar7,pcVar9);
LAB_00038d03:
          pvVar3 = _objc_msgSend(pvVar2,sel_nextObject,pcVar8,pcVar9);
          if (pvVar3 != (id)0x0) {
            local_d7 = '\0';
            pcVar6 = _objc_msgSend(pcVar7,sel_stringByAppendingPathComponent_,pvVar3,pcVar9);
            pcVar9 = &local_d7;
            pcVar5 = pcVar6;
            pvVar4 = _objc_msgSend(self_00,sel_fileExistsAtPath_isDirectory_,pcVar6);
            if (((char)pvVar4 == '\0') ||
               (pvVar4 = pvVar2, op = sel_skipDescendents, local_d7 == '\0')) goto LAB_00038c30;
            goto LAB_00038cfb;
          }
          goto LAB_00038b34;
        }
        pvVar3 = _objc_msgSend(self_01,sel_isFileImageAtPath_,pcVar7,pcVar9);
        if ((char)pvVar3 == '\0') {
LAB_00038e4a:
          pcVar5 = pcVar7;
          pvVar3 = _objc_msgSend(self_01,sel_isFileMovieAtPath_,pcVar7,pcVar9);
          if ((char)pvVar3 != '\0') {
            pvVar2 = local_f8;
            if (local_f8 == (id)0x0) {
              pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new,pcVar5,pcVar9);
              pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
              local_f8 = pvVar2;
            }
            goto LAB_00038b2c;
          }
          pvVar3 = _objc_msgSend(self_01,sel_isFileMediaOrTextAtPath_,pcVar7,pcVar9);
          if ((char)pvVar3 != '\0') {
LAB_00038ad9:
            pvVar2 = local_ec;
            if (local_ec == (id)0x0) {
              pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new,pcVar8);
              pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
              local_ec = pvVar2;
            }
            goto LAB_00038b2c;
          }
          pcVar8 = &cfstr_kmz;
          pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_kmz,pcVar9);
          if ((char)pvVar3 != '\0') goto LAB_00038ad9;
          pcVar8 = &cfstr_kml;
          pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_kml);
          if ((char)pvVar2 != '\0') goto LAB_00038ad9;
        }
        else {
          pcVar5 = &cfstr_pdf;
          pcVar9 = (char *)0x1;
          pvVar3 = _objc_msgSend(pvVar2,sel_compare_options_,&cfstr_pdf,1);
          if (pvVar3 == (id)0x0) goto LAB_00038e4a;
          pvVar2 = local_fc;
          if (local_fc == (id)0x0) {
            pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new,pcVar5,pcVar9);
            pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
            local_fc = pvVar2;
          }
LAB_00038b2c:
          _objc_msgSend(pvVar2,sel_addObject_,pcVar7,pcVar9);
          pcVar8 = pcVar7;
        }
LAB_00038b34:
      } while (local_f4 < local_100);
      pcVar9 = local_50;
      pcVar8 = &local_74;
      uVar10 = 0x10;
      local_100 = _objc_msgSend(self_02,sel_countByEnumeratingWithState_objects_count_,pcVar8,pcVar9
                                ,0x10);
    } while (local_100 != (id)0x0);
  }
  _objc_msgSend(self_02,sel_release,pcVar8,pcVar9,uVar10);
  if (images != (id *)0x0) {
    *images = local_fc;
  }
  if (movies != (id *)0x0) {
    *movies = local_f8;
  }
  if (otherMediaOrText != (id *)0x0) {
    *otherMediaOrText = local_ec;
  }
  return;
LAB_00038c30:
  pvVar3 = _objc_msgSend(pvVar3,sel_substringToIndex_,1,pcVar9);
  pcVar8 = &cfstr__;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr__);
  if (((char)pvVar3 == '\0') &&
     ((pcVar8 = pcVar6, pvVar3 = _objc_msgSend(self_01,sel_isFileImageAtPath_,pcVar6,pcVar9),
      (char)pvVar3 == '\0' &&
      (pcVar8 = pcVar6, pvVar3 = _objc_msgSend(self_01,sel_isFileMediaOrTextAtPath_,pcVar6,pcVar9),
      (char)pvVar3 != '\0')))) {
    pvVar4 = local_ec;
    op = sel_addObject_;
    pcVar5 = pcVar6;
    if (local_ec == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_new,pcVar8);
      local_ec = _objc_msgSend(pvVar3,sel_autorelease);
      pvVar4 = local_ec;
      op = sel_addObject_;
    }
LAB_00038cfb:
    _objc_msgSend(pvVar4,op,pcVar5,pcVar9);
    pcVar8 = pcVar5;
  }
  goto LAB_00038d03;
}

*/
- (void)chooseFilesForImportWithFiles:(id)aFiles images:(id *)aImages movies:(id *)aMovies otherMediaOrText:(id *)aText
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSMutableArray *expanded = [NSMutableArray new];
    for (NSString *path in aFiles) {
        BOOL isDirectory = NO;
        if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            continue;
        }
        if (isDirectory) {
            NSString *type = [self typeForContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
            if (![type isEqualToString:@"HSKeynoteDocumentType"] && ![workspace isFilePackageAtPath:path]) {
                NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
                NSString *relativePath;
                while ((relativePath = [enumerator nextObject]) != nil) {
                    if (![[relativePath substringToIndex:1] isEqualToString:@"."]) {
                        NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
                        BOOL isSubdirectory = NO;
                        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isSubdirectory] && !isSubdirectory) {
                            [expanded addObject:fullPath];
                        }
                    }
                }
                continue;
            }
        }
        if (!isDirectory) {
            [expanded addObject:path];
        }
    }
    NSMutableArray *images = nil;
    NSMutableArray *movies = nil;
    NSMutableArray *otherMediaOrText = nil;
    for (NSString *path in expanded) {
        NSString *extension = [path pathExtension];
        if ([extension compare:@"rtfd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
            NSString *relativePath;
            while ((relativePath = [enumerator nextObject]) != nil) {
                NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
                BOOL isSubdirectory = NO;
                if ([fileManager fileExistsAtPath:fullPath isDirectory:&isSubdirectory] && isSubdirectory) {
                    [enumerator skipDescendents];
                    continue;
                }
                if (![[relativePath substringToIndex:1] isEqualToString:@"."] && ![workspace isFileImageAtPath:fullPath] && [workspace isFileMediaOrTextAtPath:fullPath]) {
                    if (otherMediaOrText == nil) {
                        otherMediaOrText = [[NSMutableArray new] autorelease];
                    }
                    [otherMediaOrText addObject:fullPath];
                }
            }
            continue;
        }
        if ([workspace isFileImageAtPath:path] && [extension compare:@"pdf" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
            if (images == nil) {
                images = [[NSMutableArray new] autorelease];
            }
            [images addObject:path];
        } else if ([workspace isFileMovieAtPath:path]) {
            if (movies == nil) {
                movies = [[NSMutableArray new] autorelease];
            }
            [movies addObject:path];
        } else if ([workspace isFileMediaOrTextAtPath:path] || [extension isEqualToString:@"kmz"] || [extension isEqualToString:@"kml"]) {
            if (otherMediaOrText == nil) {
                otherMediaOrText = [[NSMutableArray new] autorelease];
            }
            [otherMediaOrText addObject:path];
        }
    }
    [expanded release];
    if (aImages != NULL) {
        *aImages = images;
    }
    if (aMovies != NULL) {
        *aMovies = movies;
    }
    if (aText != NULL) {
        *aText = otherMediaOrText;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002e5ea @ 0002e5ea, 1027 bytes * /

void FUN_0002e5ea(HSEditorController *self,SEL _cmd,id openSelection,id userData,id *error)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id local_18;
  
  pvVar2 = _objc_msgSend(self,sel_currentDocument);
  if (pvVar2 == (id)0x0) {
    pvVar7 = (id)0x0;
    pvVar6 = (id)0x1;
    local_18 = _objc_msgSend(self,sel_openUntitledDocumentAndDisplay_error_,1,0);
    pvVar3 = _objc_msgSend(local_18,sel_currentCard);
  }
  else {
    pvVar3 = _objc_msgSend(cls_HSCard,sel_defaultObject);
    pvVar6 = _objc_msgSend(pvVar2,sel_currentCard);
    pvVar4 = _objc_msgSend(pvVar2,sel_stack);
    pvVar7 = _objc_msgSend(pvVar4,sel_indexOfHyperChild_,pvVar6);
    pvVar6 = pvVar3;
    _objc_msgSend(pvVar4,sel_insertHyperChild_atIndex_,pvVar3,pvVar7);
    local_18 = pvVar2;
  }
  pvVar4 = _objc_msgSend(openSelection,sel_types,pvVar6,pvVar7);
  puVar1 = PTR_003361bc;
  pvVar6 = *(id *)PTR_003361bc;
  pvVar4 = _objc_msgSend(pvVar4,sel_containsObject_,pvVar6);
  if ((char)pvVar4 == '\0') {
    pvVar4 = (id)0x0;
  }
  else {
    pvVar4 = _objc_msgSend(cls_NSURL,sel_alloc,pvVar6,pvVar7);
    pvVar6 = _objc_msgSend(openSelection,sel_stringForType_,*(undefined4 *)puVar1);
    pvVar4 = _objc_msgSend(pvVar4,sel_initWithString_,pvVar6);
  }
  pvVar7 = _objc_msgSend(pvVar4,sel_scheme,pvVar6);
  pvVar7 = _objc_msgSend(pvVar7,sel_length);
  if (pvVar7 == (id)0x0) {
    _objc_msgSend(pvVar4,sel_release,pvVar6);
LAB_0002e7a2:
    pvVar6 = _objc_msgSend(local_18,sel_cardView,pvVar6);
    _objc_msgSend(pvVar6,sel_setCard_,pvVar3);
    _objc_msgSend(pvVar6,sel_readSelectionFromPasteboard_useDragPreferences_,openSelection,1);
    pvVar7 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00362500);
    pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
    pvVar6 = _objc_msgSend(cls_HSOpenLocationAction,sel_actionType);
    pvVar4 = pvVar3;
    pvVar5 = _objc_msgSend(pvVar7,sel_hyperActionOfType_forEvent_,pvVar6,pvVar3);
    if (pvVar5 != (id)0x0) goto LAB_0002e9b0;
    pvVar6 = _objc_msgSend(cls_HSGoToURLAction,sel_actionType,pvVar6,pvVar4);
    pvVar4 = pvVar3;
    pvVar5 = _objc_msgSend(pvVar7,sel_hyperActionOfType_forEvent_,pvVar6,pvVar3);
    if (pvVar5 != (id)0x0) goto LAB_0002e9b0;
  }
  else {
    pvVar7 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar6);
    pvVar6 = pvVar4;
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithContentsOfURL_,pvVar4);
    _objc_msgSend(pvVar4,sel_release);
    if (pvVar7 == (id)0x0) goto LAB_0002e7a2;
    _objc_msgSend(self,sel_importImage_withFileURL_toDocument_withCard_,pvVar7,pvVar4,local_18,
                  pvVar3);
    _objc_msgSend(pvVar7,sel_release);
    pvVar7 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00362500);
    pvVar6 = *(id *)PTR_00336084;
    pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,pvVar6);
  }
  pvVar6 = _objc_msgSend(cls_HSNextCardAction,sel_nextCardActionWithFadeTransition,pvVar6,pvVar4);
  _objc_msgSend(pvVar7,sel_addHyperAction_forEvent_,pvVar6,pvVar3);
  pvVar4 = pvVar3;
LAB_0002e9b0:
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_currentDocument,pvVar6,pvVar4);
    _objc_msgSend(pvVar2,sel_testCard_,0);
  }
  return;
}

*/
- (void)openSelection:(id)aSelection userData:(id)aData error:(id *)aError
{
    HSEditorDocument *originalDocument = [self currentDocument];
    HSEditorDocument *document;
    HSCard *card;
    if (originalDocument == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        card = [document currentCard];
    } else {
        card = [HSCard defaultObject];
        HSStack *stack = [originalDocument stack];
        [stack insertHyperChild:card atIndex:[stack indexOfHyperChild:[originalDocument currentCard]]];
        document = originalDocument;
    }
    NSURL *url = nil;
    if ([[aSelection types] containsObject:NSPasteboardTypeString]) {
        url = [[NSURL alloc] initWithString:[aSelection stringForType:NSPasteboardTypeString]];
    }
    id actor;
    id event;
    BOOL addNextCard = NO;
    NSImage *image = nil;
    if ([[url scheme] length] != 0) {
        image = [[NSImage alloc] initWithContentsOfURL:url];
    }
    if (image != nil) {
        [self importImage:image withFileURL:url toDocument:document withCard:card];
        [image release];
        actor = [card queryHyperInterface:@protocol(HSActor)];
        event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
        addNextCard = YES;
    } else {
        id cardView = [document cardView];
        [cardView setCard:card];
        [cardView readSelectionFromPasteboard:aSelection useDragPreferences:YES];
        actor = [card queryHyperInterface:@protocol(HSActor)];
        event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
        addNextCard = [actor hyperActionOfType:[HSOpenLocationAction actionType] forEvent:event] == nil
            && [actor hyperActionOfType:[HSGoToURLAction actionType] forEvent:event] == nil;
    }
    [url release];
    if (addNextCard) {
        [actor addHyperAction:[HSNextCardAction nextCardActionWithFadeTransition] forEvent:event];
    }
    if (originalDocument == nil) {
        [[self currentDocument] testCard:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00038ecc @ 00038ecc, 372 bytes * /

void FUN_00038ecc(HSEditorController *self,SEL _cmd,id applicationWillTerminate)

{
  undefined *puVar1;
  id pvVar2;
  undefined4 uVar3;
  HSEditorController *local_14;
  undefined *local_10;
  
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar3 = *(undefined4 *)PTR_PTR_00336194;
  pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,uVar3);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
    _objc_msgSend(pvVar2,sel_saveToolsSettingsToDefaults);
  }
  puVar1 = PTR_DAT_003361dc;
  if (*(int *)PTR_DAT_003361dc != 0) {
    uVar3 = 0;
    _QFEnableFlashInQuickTime(*(int *)PTR_DAT_003361dc,0,0);
    _QFRelease(*(undefined4 *)puVar1);
  }
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,uVar3);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003361b0,0);
  _objc_msgSend(self->_applicationLicensor,sel_release);
  self->_applicationLicensor = (HSApplicationLicensor *)0x0;
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar2,sel_setSelectedInModelObject_,0);
  local_14 = self;
  local_10 = PTR_s_HSApplicationController_0034dc00;
  _objc_msgSendSuper(&local_14,sel_applicationWillTerminate_,applicationWillTerminate);
  return;
}

*/
- (void)applicationWillTerminate:(id)aTerminate
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HSPreserveToolsSettings"]) {
        [[[HSToolManager sharedToolManager] toolSettings] saveToolsSettingsToDefaults];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSContextHelpModeDidActivateNotification object:nil];
    [_applicationLicensor release];
    _applicationLicensor = nil;
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:nil];
    [super applicationWillTerminate:aTerminate];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00039040 @ 00039040, 179 bytes * /

BOOL FUN_00039040(HSEditorController *self,SEL _cmd,id applicationOpenUntitledFile)

{
  char cVar1;
  id pvVar2;
  undefined4 uVar3;
  HSEditorController *local_14;
  undefined *local_10;
  
  self->_applicationWillFinishCriticalLaunching[0] =
       self->_applicationWillFinishCriticalLaunching[0] & 0xfd;
  local_14 = self;
  local_10 = PTR_s_HSApplicationController_0034dc00;
  pvVar2 = _objc_msgSendSuper(&local_14,sel_applicationOpenUntitledFile_,applicationOpenUntitledFile
                             );
  cVar1 = (char)pvVar2;
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar3 = *(undefined4 *)PTR_0033619c;
  pvVar2 = _objc_msgSend(pvVar2,sel_integerForKey_,uVar3);
  if ((cVar1 == '\0') && (pvVar2 == (id)0x0)) {
    pvVar2 = _objc_msgSend(self,sel_defaultNavigationControllerClass,uVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_goToHomeStack);
    cVar1 = (char)pvVar2;
  }
  return cVar1;
}

*/
- (BOOL)applicationOpenUntitledFile:(id)aFile
{
    _applicationOpenUntitledFilePending = NO;
    BOOL result = [super applicationOpenUntitledFile:aFile];
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:HSStartupActionKey];
    if (!result && action == 0) {
        result = [[self defaultNavigationControllerClass] goToHomeStack];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000390f3 @ 000390f3, 115 bytes * /

BOOL FUN_000390f3(HSEditorController *self,SEL _cmd,id applicationShouldOpenUntitledFile)

{
  BOOL BVar1;
  id pvVar2;
  HSEditorController *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSApplicationController_0034dc00;
  pvVar2 = _objc_msgSendSuper(&local_14,sel_applicationShouldOpenUntitledFile_,
                              applicationShouldOpenUntitledFile);
  if (((char)pvVar2 == '\0') ||
     (pvVar2 = _objc_msgSend(self,sel_resolvingError), (char)pvVar2 != '\0')) {
    BVar1 = '\0';
  }
  else if ((self->_applicationWillFinishCriticalLaunching[0] & 1) == 0) {
    BVar1 = '\x01';
  }
  else {
    self->_applicationWillFinishCriticalLaunching[0] =
         self->_applicationWillFinishCriticalLaunching[0] | 2;
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)applicationShouldOpenUntitledFile:(id)aFile
{
    if (![super applicationShouldOpenUntitledFile:aFile] || [self resolvingError]) {
        return NO;
    }
    if (!_applicationWillFinishCriticalLaunching) {
        return YES;
    }
    _applicationOpenUntitledFilePending = YES;
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00039166 @ 00039166, 1350 bytes * /

void FUN_00039166(HSEditorController *self,SEL _cmd,id applicationDidFinishLaunching)

{
  undefined *self_00;
  id pvVar1;
  char cVar2;
  int iVar3;
  bool bVar4;
  undefined4 uVar5;
  id pvVar6;
  HSEditorController *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_shouldShowEULA);
  bVar4 = (char)pvVar1 != '\0';
  if (bVar4) {
    _objc_msgSend(self,sel_showEULAAppModalDialog);
  }
  pvVar1 = _objc_msgSend(cls_HSSubmitRequest,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_submitInformationDictionary_,0);
  _objc_msgSend(self,sel_HSEditorController_validateApplicationLicenseWithInteraction_forced_,1,0);
  pvVar1 = _objc_msgSend(cls_HSSplashScreenWindowController,sel_sharedSplashWindow);
  pvVar6 = (id)0x40080000;
  _objc_msgSend(pvVar1,sel_showSplashWithMinimalTimeout_,0,0x40080000);
  self->_applicationWillFinishCriticalLaunching[0] =
       self->_applicationWillFinishCriticalLaunching[0] & 0xfe;
  _objc_msgSend(self,sel_configureObjectsMenu);
  uVar5 = 1;
  _objc_msgSend(self,sel_HSEditorController_setMenuVisible_,1);
  pvVar1 = self->_filesToOpen;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_documents,uVar5,pvVar6);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    if (((pvVar1 == (id)0x0) &&
        ((self->_applicationWillFinishCriticalLaunching[0] & 2) != 0 || bVar4)) &&
       (pvVar1 = _objc_msgSend(self,sel_applicationOpenUntitledFile_,*(undefined4 *)PTR_00336058),
       (char)pvVar1 == '\0')) {
      _objc_msgSend(self,sel_newDocument_,0);
    }
  }
  else {
    _objc_msgSend(self,sel_application_openFiles_,*(undefined4 *)PTR_00336058,pvVar1);
    _objc_msgSend(self->_filesToOpen,sel_release);
    self->_filesToOpen = (id)0x0;
    pvVar6 = pvVar1;
  }
  local_1c = self;
  local_18 = PTR_s_HSApplicationController_0034dc00;
  _objc_msgSendSuper(&local_1c,sel_applicationDidFinishLaunching_,applicationDidFinishLaunching);
  _objc_msgSend(self,sel_setAutosaving,applicationDidFinishLaunching,pvVar6);
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  if (((pvVar1 == (id)0x0) ||
      (pvVar6 = _objc_msgSend(pvVar1,sel_isStackProtected), (char)pvVar6 != '\0')) ||
     (pvVar1 = _objc_msgSend(pvVar1,sel_isInPurePlayerMode), (char)pvVar1 != '\0')) {
    cVar2 = '\0';
  }
  else {
    cVar2 = '\x01';
  }
  pvVar1 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController);
  iVar3 = (int)cVar2;
  _objc_msgSend(pvVar1,sel_showLibraryIfNeededByDefault_,iVar3);
  pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,iVar3);
  pvVar1 = _objc_msgSend(cls_HSLayoutPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,iVar3);
  pvVar1 = _objc_msgSend(cls_HSObjectListPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,iVar3);
  pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
  pvVar1 = _objc_msgSend(cls_HSShortcutsPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
  pvVar1 = _objc_msgSend(cls_HSUpdater,sel_sharedUpdater);
  _objc_msgSend(pvVar1,sel_automaticCheckForUpdates);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_contextHelpModeDidActivate_,
                *(undefined4 *)PTR_003361b0,0);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar6 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                sel_HSEditorController_HSUIModeSettingsDidChangeNotification_,
                *(undefined4 *)PTR_00336130,pvVar6);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar6 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                sel_HSEditorController_HSUIModeSettingsDidChangeNotification_,
                *(undefined4 *)PTR_00336120,pvVar6);
  _objc_msgSend(*(id *)PTR_00336058,sel_setServicesProvider_,self);
  pvVar1 = _objc_msgSend(cls_HSSplashScreenWindowController,sel_sharedSplashWindow);
  _objc_msgSend(pvVar1,sel_hideSplashWaitUntilTimeout_,1);
  self_00 = cls_HSCrayonsView;
  pvVar1 = _objc_msgSend(cls_HSSystemCrayonsDataSource,sel_class);
  _objc_msgSend(self_00,sel_setDefaultDataSourceClass_,pvVar1);
  return;
}

*/
- (void)applicationDidFinishLaunching:(id)aLaunching
{
    BOOL showedEULA = [self shouldShowEULA];
    if (showedEULA) {
        [self showEULAAppModalDialog];
    }
    [[HSSubmitRequest sharedInstance] submitInformationDictionary:nil];
    [self HSEditorController_validateApplicationLicenseWithInteraction:YES forced:NO];
    [[HSSplashScreenWindowController sharedSplashWindow] showSplashWithMinimalTimeout:3.0];
    _applicationWillFinishCriticalLaunching = NO;
    [self configureObjectsMenu];
    [self HSEditorController_setMenuVisible:YES];
    if (_filesToOpen != nil) {
        [self application:NSApp openFiles:_filesToOpen];
        [_filesToOpen release];
        _filesToOpen = nil;
    } else if ([[self documents] count] == 0 && (_applicationOpenUntitledFilePending || showedEULA)
               && ![self applicationOpenUntitledFile:NSApp]) {
        [self newDocument:nil];
    }
    [super applicationDidFinishLaunching:aLaunching];
    [self setAutosaving];
    HSEditorDocument *document = [self currentDocument];
    BOOL show = document != nil && ![document isStackProtected] && ![document isInPurePlayerMode];
    [[HSLibraryController sharedLibraryController] showLibraryIfNeededByDefault:show];
    [[HSToolPaletteController sharedInstance] showPaletteIfNeededByDefault:show];
    [[HSLayoutPaletteController sharedInstance] showPaletteIfNeededByDefault:show];
    [[HSObjectListPaletteController sharedInstance] showPaletteIfNeededByDefault:show];
    [[HSCommentsAndAttributionsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
    [[HSShortcutsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
    [[HSUpdater sharedUpdater] automaticCheckForUpdates];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextHelpModeDidActivate:) name:NSContextHelpModeDidActivateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
    [NSApp setServicesProvider:self];
    [[HSSplashScreenWindowController sharedSplashWindow] hideSplashWaitUntilTimeout:YES];
    [HSCrayonsView setDefaultDataSourceClass:[HSSystemCrayonsDataSource class]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000396ac @ 000396ac, 218 bytes * /

void FUN_000396ac(HSEditorController *self,SEL _cmd,id applicationWillFinishLaunching)

{
  undefined *self_00;
  id self_01;
  id pvVar1;
  HSEditorController *local_1c;
  undefined *local_18;
  
  self->_applicationWillFinishCriticalLaunching[0] =
       self->_applicationWillFinishCriticalLaunching[0] | 1;
  self_01 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  self_00 = cls_NSBundle;
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
  _objc_msgSend(self_01,sel_setExecutableBundle_,pvVar1);
  local_1c = self;
  local_18 = PTR_s_HSApplicationController_0034dc00;
  _objc_msgSendSuper(&local_1c,sel_applicationWillFinishLaunching_,applicationWillFinishLaunching);
  _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  return;
}

*/
- (void)applicationWillFinishLaunching:(id)aLaunching
{
    _applicationWillFinishCriticalLaunching = YES;
    [[HSExecutableResourceProvider sharedInstance] setExecutableBundle:[NSBundle bundleForClass:[self class]]];
    [super applicationWillFinishLaunching:aLaunching];
    [HSObjectAssistantController sharedAssistantController];
    [HSCoachingHelpManager sharedCoachingHelpManager];
}

- (id)applicationDefaults
{
    id pvVar1_2;

    pvVar1_2 = [HSDefaultWindowsLayoutManager windowsLayoutManagerWithDefaults:[super applicationDefaults]];
    [pvVar1_2 applySmartDefaultWindowsLayout];
    return [pvVar1_2 defaults];
}

- (void)documentProtectionDidChange:(id)aChange
{
    [self updateOnDocumentProtectionChange];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002e517 @ 0002e517, 173 bytes * /

void FUN_0002e517(HSEditorController *self,SEL _cmd)

{
  SEL op;
  char cVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  
  self_00 = _objc_msgSend(self,sel_currentDocument);
  pvVar2 = _objc_msgSend(self_00,sel_isStackProtected);
  pvVar3 = _objc_msgSend(self_00,sel_isInPurePlayerMode);
  cVar1 = (char)pvVar3;
  op = sel_enterPurePlayerModeWithAnimation_;
  if ((char)pvVar2 == '\0') {
    if (cVar1 == '\0') goto LAB_0002e5aa;
    pvVar2 = _objc_msgSend(self,sel_replacingDocument);
    cVar1 = (char)pvVar2;
    op = sel_exitPurePlayerModeWithAnimation_;
  }
  if (cVar1 == '\0') {
    _objc_msgSend(self_00,op,1);
  }
LAB_0002e5aa:
  _objc_msgSend(self,sel_updateToolDeviceAndLibraryOnDocumentProtectionChange);
  return;
}

*/
- (void)updateOnDocumentProtectionChange
{
    HSEditorDocument *document = [self currentDocument];
    BOOL protected = [document isStackProtected];
    BOOL pure = [document isInPurePlayerMode];
    if (protected) {
        if (!pure) {
            [document enterPurePlayerModeWithAnimation:YES];
        }
    } else if (pure && ![self replacingDocument]) {
        [document exitPurePlayerModeWithAnimation:YES];
    }
    [self updateToolDeviceAndLibraryOnDocumentProtectionChange];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002e36e @ 0002e36e, 425 bytes * /

void FUN_0002e36e(HSEditorController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_isStackProtected);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_currentDocument);
    pvVar1 = _objc_msgSend(pvVar1,sel_isInPurePlayerMode);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController);
      _objc_msgSend(pvVar1,sel_showLibraryIfNeededByDefault_,1);
      pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
      self = (HSEditorController *)0x1;
      op = sel_showPaletteIfNeededByDefault_;
      goto LAB_0002e4aa;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController);
  pvVar1 = _objc_msgSend(pvVar1,sel_isLibraryVisible);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController);
    pvVar1 = _objc_msgSend(pvVar1,sel_window);
    _objc_msgSend(pvVar1,sel_hyperOrderOutWithSavingVisibilityState_,self);
  }
  pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_isPaletteVisible);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_window);
  op = sel_hyperOrderOutWithSavingVisibilityState_;
LAB_0002e4aa:
  _objc_msgSend(pvVar1,op,self);
  return;
}

*/
- (void)updateToolDeviceAndLibraryOnDocumentProtectionChange
{
    if (![[self currentDocument] isStackProtected] && ![[self currentDocument] isInPurePlayerMode]) {
        [[HSLibraryController sharedLibraryController] showLibraryIfNeededByDefault:YES];
        [[HSToolPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        return;
    }
    if ([[HSLibraryController sharedLibraryController] isLibraryVisible]) {
        [[[HSLibraryController sharedLibraryController] window] hyperOrderOutWithSavingVisibilityState:self];
    }
    if ([[HSToolPaletteController sharedInstance] isPaletteVisible]) {
        [[[HSToolPaletteController sharedInstance] window] hyperOrderOutWithSavingVisibilityState:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00039801 @ 00039801, 545 bytes * /

id FUN_00039801(HSEditorController *self,SEL _cmd,BOOL openUntitledDocumentAndDisplay,id *error)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  HSEditorController *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self,sel_currentDocument);
  self_00 = cls_HSStack;
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperCardSize);
    _objc_msgSend(self_00,sel_setNewStackCardSize_,pvVar2,extraout_EDX);
  }
  local_14 = self;
  local_10 = PTR_s_HSApplicationController_0034dc00;
  pvVar2 = _objc_msgSendSuper(&local_14,sel_openUntitledDocumentAndDisplay_error_,
                              (uint)(byte)openUntitledDocumentAndDisplay,error);
  if ((pvVar2 != (id)0x0) && (pvVar2 != pvVar1)) {
    pvVar1 = _objc_msgSend(cls_HSLibraryController,sel_sharedLibraryController);
    _objc_msgSend(pvVar1,sel_showLibraryIfNeededByDefault_,1);
    pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
    _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
    pvVar1 = _objc_msgSend(cls_HSLayoutPaletteController,sel_sharedInstance);
    _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
    pvVar1 = _objc_msgSend(cls_HSObjectListPaletteController,sel_sharedInstance);
    _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
    pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
    _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
    pvVar1 = _objc_msgSend(cls_HSShortcutsPaletteController,sel_sharedInstance);
    _objc_msgSend(pvVar1,sel_showPaletteIfNeededByDefault_,1);
  }
  _objc_msgSend(cls_HSStack,sel_setNewStackCardSize_,*(undefined4 *)PTR_0033607c,
                *(undefined4 *)(PTR_0033607c + 4));
  return pvVar2;
}

*/
- (id)openUntitledDocumentAndDisplay:(BOOL)aDisplay error:(id *)aError
{
    HSEditorDocument *current = [self currentDocument];
    if (current != nil) {
        [HSStack setNewStackCardSize:[[current stack] hyperCardSize]];
    }
    id document = [super openUntitledDocumentAndDisplay:aDisplay error:aError];
    if (document != nil && document != current) {
        [[HSLibraryController sharedLibraryController] showLibraryIfNeededByDefault:YES];
        [[HSToolPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSLayoutPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSObjectListPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSCommentsAndAttributionsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSShortcutsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
    }
    [HSStack setNewStackCardSize:NSZeroSize];
    return document;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002e29c @ 0002e29c, 210 bytes * /

void FUN_0002e29c(HSEditorController *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  undefined8 in_stack_ffffffec;
  undefined4 uVar4;
  undefined8 uVar3;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffffec >> 0x20);
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar3 = CONCAT44(uVar4,*(undefined4 *)PTR_00336170);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_00336170);
  pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
  if (pvVar1 == (id)0x1) {
    pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_00336174);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    dVar2 = (double)((int)pvVar1 * 0x3c);
  }
  else {
    dVar2 = 0.0;
  }
  _objc_msgSend(self,sel_setAutosavingDelay_,dVar2);
  return;
}

*/
- (void)setAutosaving
{
    NSTimeInterval delay = 0.0;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:HSAutoSaveOnKey] intValue] == 1) {
        delay = [[[NSUserDefaults standardUserDefaults] objectForKey:HSAutoSavePeriodKey] intValue] * 60;
    }
    [self setAutosavingDelay:delay];
}

- (void)removeDocument:(id)aDocument
{
    [[HSCoachingHelpManager sharedCoachingHelpManager] removeStack:[aDocument stack]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentDidChangeProtectionNotification object:aDocument];
    [super removeDocument:aDocument];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00039ae4 @ 00039ae4, 345 bytes * /

void FUN_00039ae4(HSEditorController *self,SEL _cmd,id addDocument)

{
  id pvVar1;
  id pvVar2;
  HSEditorController *pHVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined4 uVar6;
  HSEditorController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSApplicationController_0034dc00;
  _objc_msgSendSuper(&local_1c,sel_addDocument_,addDocument);
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  pvVar2 = _objc_msgSend(addDocument,sel_stack);
  _objc_msgSend(pvVar1,sel_addStack_,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  uVar6 = *(undefined4 *)PTR_00336178;
  pHVar3 = self;
  puVar5 = sel_documentProtectionDidChange_;
  pvVar1 = addDocument;
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_documentProtectionDidChange_,
                uVar6,addDocument);
  if ((self->_applicationWillFinishCriticalLaunching[0] & 8) == 0) {
    _objc_msgSend(self,sel_updateToolDeviceAndLibraryOnDocumentProtectionChange,pHVar3,puVar5,uVar6,
                  pvVar1);
  }
  puVar4 = sel_openWarning;
  pvVar2 = _objc_msgSend(addDocument,sel_respondsToSelector_,sel_openWarning,puVar5,uVar6,pvVar1);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(addDocument,sel_openWarning,puVar4,puVar5,uVar6,pvVar1);
    if (pvVar2 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager,puVar4,puVar5,uVar6,pvVar1);
      _objc_msgSend(pvVar1,sel_presentError_,pvVar2);
    }
  }
  return;
}

*/
- (void)addDocument:(id)aDocument
{
    [super addDocument:aDocument];
    [[HSCoachingHelpManager sharedCoachingHelpManager] addStack:[aDocument stack]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentProtectionDidChange:) name:HSDocumentDidChangeProtectionNotification object:aDocument];
    if (!_replacingDocument) {
        [self updateToolDeviceAndLibraryOnDocumentProtectionChange];
    }
    if ([aDocument respondsToSelector:@selector(openWarning)]) {
        id warning = [aDocument openWarning];
        if (warning != nil) {
            [[HSErrorManager sharedErrorManager] presentError:warning];
        }
    }
}

- (void)HSEditorController_HSUIModeSettingsDidChangeNotification:(id)aNotification
{
    if (*(int *)&_documentInEditor == 0) {
        [self HSEditorController_setMenuVisible:YES];
        [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
    }
}

- (void)HSEditorController_setMenuVisible:(BOOL)aVisible
{
    int uVar2;
    id pvVar1_3;

    if ([[HSSystemUI sharedSystemUI] menuBarVisible] != aVisible) {
        pvVar1_3 = [HSSystemUI sharedSystemUI];
        if (aVisible != NO) {
            uVar2 = 0;
        }
        else {
            uVar2 = 4;
        }
        [pvVar1_3 setupWithMode:uVar2 options:(unsigned int)(aVisible == NO)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002dff6 @ 0002dff6, 417 bytes * /

void FUN_0002dff6(HSEditorController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(*(id *)PTR_00336058,sel_mainMenu);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar4 = &cfstr_HSWebObjectUIEnabled;
  pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,&cfstr_HSWebObjectUIEnabled);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(pvVar1,sel_indexOfItemWithTag_,6);
    pvVar2 = _objc_msgSend(pvVar1,sel_itemAtIndex_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_submenu);
    pvVar3 = _objc_msgSend(pvVar2,sel_indexOfItemWithTag_,0x40);
    pcVar4 = _objc_msgSend(pvVar2,sel_itemAtIndex_,pvVar3);
    _objc_msgSend(pvVar2,sel_removeItem_,pcVar4);
  }
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar4);
  pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,&cfstr_HSExportToIPadEnabled);
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_itemWithTag_,3);
    pvVar1 = _objc_msgSend(pvVar1,sel_submenu);
    pvVar1 = _objc_msgSend(pvVar1,sel_itemWithTag_,6);
    pvVar2 = _objc_msgSend(pvVar1,sel_menu);
    _objc_msgSend(pvVar2,sel_removeItem_,pvVar1);
  }
  return;
}

*/
- (void)configureObjectsMenu
{
    NSMenu *mainMenu = [NSApp mainMenu];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HSWebObjectUIEnabled"]) {
        NSMenu *submenu = [[mainMenu itemAtIndex:[mainMenu indexOfItemWithTag:6]] submenu];
        [submenu removeItem:[submenu itemAtIndex:[submenu indexOfItemWithTag:0x40]]];
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HSExportToIPadEnabled"]) {
        NSMenuItem *item = [[[mainMenu itemWithTag:3] submenu] itemWithTag:6];
        [[item menu] removeItem:item];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da63 @ 0002da63, 18 bytes * /

BOOL FUN_0002da63(HSEditorController *self,SEL _cmd)

{
  return DAT_00341c41;
}

*/
- (BOOL)lastTextFieldTamerThisCard
{
    return sLastTextFieldTamerThisCard;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da4f @ 0002da4f, 20 bytes * /

void FUN_0002da4f(HSEditorController *self,SEL _cmd,BOOL setLastTextFieldTamerThisCard)

{
  DAT_00341c41 = setLastTextFieldTamerThisCard;
  return;
}

*/
- (void)setLastTextFieldTamerThisCard:(BOOL)aCard
{
    sLastTextFieldTamerThisCard = aCard;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da3d @ 0002da3d, 18 bytes * /

BOOL FUN_0002da3d(HSEditorController *self,SEL _cmd)

{
  return DAT_00341c40;
}

*/
- (BOOL)lastTextFieldTamerReadyOnly
{
    return sLastTextFieldTamerReadOnly;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da29 @ 0002da29, 20 bytes * /

void FUN_0002da29(HSEditorController *self,SEL _cmd,BOOL setLastTextFieldTamerReadOnly)

{
  DAT_00341c40 = setLastTextFieldTamerReadOnly;
  return;
}

*/
- (void)setLastTextFieldTamerReadOnly:(BOOL)aOnly
{
    sLastTextFieldTamerReadOnly = aOnly;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00039cc1 @ 00039cc1, 395 bytes * /

BOOL FUN_00039cc1(HSEditorController *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  undefined1 *puVar7;
  undefined4 uVar8;
  BOOL local_89;
  id local_84;
  HSEditorController *local_7c;
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
  
  local_7c = self;
  local_78 = PTR_s_HSApplicationController_0034dc00;
  pvVar2 = _objc_msgSendSuper(&local_7c,sel_hasEditedDocuments);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_documents);
    local_74 = 0;
    local_70 = 0;
    local_6c = (int *)0x0;
    local_68 = 0;
    local_64 = 0;
    local_60 = 0;
    local_5c = 0;
    local_58 = 0;
    puVar7 = local_50;
    puVar6 = &local_74;
    uVar8 = 0x10;
    local_84 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar6,puVar7,
                             0x10);
    local_89 = '\0';
    if (local_84 != (id)0x0) {
      iVar1 = *local_6c;
      do {
        pvVar5 = (id)0x0;
        do {
          if (iVar1 != *local_6c) {
            _objc_enumerationMutation(pvVar2);
          }
          pvVar4 = *(id *)(local_70 + (int)pvVar5 * 4);
          pvVar3 = _objc_msgSend(pvVar4,sel_actionExecutionContext,puVar6,puVar7,uVar8);
          pvVar3 = _objc_msgSend(pvVar3,sel_isRecording);
          if ((char)pvVar3 != '\0') goto LAB_00039d01;
          pvVar4 = _objc_msgSend(pvVar4,sel_isInHyperCastingMode);
          if ((char)pvVar4 != '\0') goto LAB_00039d01;
          pvVar5 = (id)((int)pvVar5 + 1);
        } while (pvVar5 < local_84);
        puVar7 = local_50;
        puVar6 = &local_74;
        uVar8 = 0x10;
        local_84 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar6,puVar7
                                 ,0x10);
      } while (local_84 != (id)0x0);
    }
  }
  else {
LAB_00039d01:
    local_89 = '\x01';
  }
  return local_89;
}

*/
- (BOOL)hasEditedDocuments
{
    if ([super hasEditedDocuments]) {
        return YES;
    }
    for (id document in [self documents]) {
        if ([[document actionExecutionContext] isRecording] || [document isInHyperCastingMode]) {
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da1d @ 0002da1d, 12 bytes * /

BOOL FUN_0002da1d(HSEditorController *self,SEL _cmd)

{
  return self->_applicationOpenUntitledFilePending[0];
}

*/
- (BOOL)documentInEditor
{
    return _documentInEditor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da0f @ 0002da0f, 14 bytes * /

void FUN_0002da0f(HSEditorController *self,SEL _cmd,BOOL setDocumentInEditor)

{
  self->_applicationOpenUntitledFilePending[0] = setDocumentInEditor;
  return;
}

*/
- (void)setDocumentInEditor:(BOOL)aEditor
{
    _documentInEditor = aEditor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002d9f9 @ 0002d9f9, 22 bytes * /

BOOL FUN_0002d9f9(HSEditorController *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_applicationWillFinishCriticalLaunching[0] & 8) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)replacingDocument
{
    return _replacingDocument;
}

- (BOOL)shouldBeDocumentOpenedInEditorMode
{
    BOOL bVar2;

    if (![self documentInEditor]) {
        if (_windowsOwnerDocument == nil) {
            bVar2 = NO;
        }
        else {
            bVar2 = ![_windowsOwnerDocument isInPlayerMode];
        }
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00039e4c @ 00039e4c, 688 bytes * /

id FUN_00039e4c(HSEditorController *self,SEL _cmd,id openDocumentWithContentsOfURL,
               id inWindowOfDocument,id *error)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  double dVar4;
  SEL op;
  undefined4 uVar5;
  undefined8 in_stack_ffffffc4;
  undefined4 uVar7;
  double dVar6;
  HSEditorController *local_1c;
  undefined *local_18;
  
  uVar7 = (undefined4)((ulonglong)in_stack_ffffffc4 >> 0x20);
  self->_applicationWillFinishCriticalLaunching[0] =
       self->_applicationWillFinishCriticalLaunching[0] | 8;
  self->_windowsOwnerDocument = inWindowOfDocument;
  pvVar1 = _objc_msgSend(inWindowOfDocument,sel_currentWindowController);
  uVar5 = 0;
  pvVar2 = _objc_msgSend(inWindowOfDocument,sel_purePlayerWindowControllerCreateIfNeeded_,0);
  if (pvVar1 == pvVar2) {
    pvVar1 = _objc_msgSend(pvVar1,sel_retain,uVar5);
    self->_sharedPurePlayerWindowController = pvVar1;
  }
  else {
    uVar5 = 0;
    pvVar2 = _objc_msgSend(inWindowOfDocument,sel_presentationWindowControllerCreateIfNeeded_,0);
    if (pvVar1 == pvVar2) {
      pvVar1 = _objc_msgSend(pvVar1,sel_retain,uVar5);
      self->_sharedPresentationWindowController = pvVar1;
    }
  }
  pvVar1 = _objc_msgSend(inWindowOfDocument,sel_playerInEditorWindowController,uVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_sharedPlayerInEditorWindowController = pvVar1;
  pvVar1 = _objc_msgSend(inWindowOfDocument,sel_isInPurePlayerMode);
  if (((char)pvVar1 != '\0') ||
     (pvVar1 = _objc_msgSend(inWindowOfDocument,sel_isInPresentationMode), (char)pvVar1 != '\0')) {
    *(int *)&self->_documentInEditor = *(int *)&self->_documentInEditor + 1;
  }
  pvVar2 = _objc_msgSend(inWindowOfDocument,sel_isStackProtected);
  local_1c = self;
  local_18 = PTR_s_HSApplicationController_0034dc00;
  dVar6 = (double)CONCAT44(uVar7,error);
  pvVar1 = inWindowOfDocument;
  self_00 = _objc_msgSendSuper(&local_1c,sel_openDocumentWithContentsOfURL_inWindowOfDocument_error_
                               ,openDocumentWithContentsOfURL,inWindowOfDocument,error);
  self->_applicationWillFinishCriticalLaunching[0] =
       self->_applicationWillFinishCriticalLaunching[0] & 0xf7;
  if ((self_00 == (id)0x0) || (self_00 == inWindowOfDocument)) {
    _objc_msgSend(self,sel_sharedPLayerInEditorWindowControllerHandled);
    _objc_msgSend(self,sel_sharedPurePlayerWindowControllerHandled);
    _objc_msgSend(self,sel_sharedPresentationWindowControllerHandled);
    pvVar1 = _objc_msgSend(inWindowOfDocument,sel_isInPurePlayerMode);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(inWindowOfDocument,sel_isInPresentationMode), (char)pvVar1 != '\0'))
    {
      *(int *)&self->_documentInEditor = *(int *)&self->_documentInEditor + -1;
    }
  }
  else {
    _objc_msgSend(self_00,sel_loadWindows);
    pvVar3 = _objc_msgSend(self_00,sel_isStackProtected);
    if ((char)pvVar2 != (char)pvVar3) {
      pvVar2 = _objc_msgSend(inWindowOfDocument,sel_navigationController);
      dVar4 = _objc_msgSend_fpret(pvVar2,sel_transitionDurationForCurrentNavigationOperation);
      pvVar2 = _objc_msgSend(inWindowOfDocument,sel_navigationController);
      pvVar2 = _objc_msgSend(pvVar2,sel_currentNavigationOperation);
      op = sel_updateOnDocumentProtectionChange;
      if ((pvVar2 != (id)0x0) && ((dVar4 != 0.0 || (NAN(dVar4))))) {
        pvVar1 = (id)0x0;
        op = sel_performSelector_withObject_afterDelay_;
        openDocumentWithContentsOfURL = sel_updateOnDocumentProtectionChange;
        dVar6 = dVar4;
      }
      _objc_msgSend(self,op,openDocumentWithContentsOfURL,pvVar1,dVar6);
    }
  }
  self->_windowsOwnerDocument = (id)0x0;
  return self_00;
}

*/
- (id)openDocumentWithContentsOfURL:(id)aURL inWindowOfDocument:(id)aDocument error:(id *)aError
{
    _replacingDocument = YES;
    _windowsOwnerDocument = aDocument;
    id currentController = [aDocument currentWindowController];
    if (currentController == [aDocument purePlayerWindowControllerCreateIfNeeded:NO]) {
        _sharedPurePlayerWindowController = [currentController retain];
    } else if (currentController == [aDocument presentationWindowControllerCreateIfNeeded:NO]) {
        _sharedPresentationWindowController = [currentController retain];
    }
    _sharedPlayerInEditorWindowController = [[aDocument playerInEditorWindowController] retain];
    if ([aDocument isInPurePlayerMode] || [aDocument isInPresentationMode]) {
        _documentsInPurePlayerAndPresentationModesCount++;
    }
    BOOL wasProtected = [aDocument isStackProtected];
    id document = [super openDocumentWithContentsOfURL:aURL inWindowOfDocument:aDocument error:aError];
    _replacingDocument = NO;
    if (document == nil || document == aDocument) {
        [self sharedPLayerInEditorWindowControllerHandled];
        [self sharedPurePlayerWindowControllerHandled];
        [self sharedPresentationWindowControllerHandled];
        if ([aDocument isInPurePlayerMode] || [aDocument isInPresentationMode]) {
            _documentsInPurePlayerAndPresentationModesCount--;
        }
    } else {
        [document loadWindows];
        if (wasProtected != [document isStackProtected]) {
            NSTimeInterval duration = [[aDocument navigationController] transitionDurationForCurrentNavigationOperation];
            if ([[aDocument navigationController] currentNavigationOperation] != nil && duration != 0.0) {
                [self performSelector:@selector(updateOnDocumentProtectionChange) withObject:nil afterDelay:duration];
            } else {
                [self updateOnDocumentProtectionChange];
            }
        }
    }
    _windowsOwnerDocument = nil;
    return document;
}

- (void)applicationDidReplaceDocumentWithDocument:(id)aDocument
{
    id pvVar1_2;

    pvVar1_2 = [[aDocument mainWindowController] cardView];
    [[aDocument selectionSync] setCardView:pvVar1_2];
    [[aDocument selectionSync] setEnabled:YES];
    [[aDocument selectionController] setEnabled:YES];
    [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentDidActivateObjectListDataProviderNotification" object:aDocument];
}

- (void)sharedPresentationWindowControllerHandled
{
    [_sharedPresentationWindowController release];
    _sharedPresentationWindowController = nil;
}

- (id)sharedPresentationWindowController
{
    return _sharedPresentationWindowController;
}

- (void)sharedPurePlayerWindowControllerHandled
{
    [_sharedPurePlayerWindowController release];
    _sharedPurePlayerWindowController = nil;
}

- (id)sharedPurePlayerWindowController
{
    return _sharedPurePlayerWindowController;
}

- (void)sharedPLayerInEditorWindowControllerHandled
{
    [_sharedPlayerInEditorWindowController release];
    _sharedPlayerInEditorWindowController = nil;
}

- (id)sharedPlayerInEditorWindowController
{
    return _sharedPlayerInEditorWindowController;
}

- (Class)remoteHyperDocumentClass
{
    return [HSEditorDocument class];
}

- (void)documentEnteredPurePlayerMode:(BOOL)aMode
{
    int iVar1;

    iVar1 = *(int *)&_documentInEditor;
    if (aMode == NO) {
        *(int *)&_documentInEditor = iVar1 + -1;
        if (iVar1 + -1 == 0) {
            [self HSEditorController_HSUIModeSettingsDidChangeNotification:nil];
        }
    }
    else {
        if (iVar1 == 0) {
            [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
            iVar1 = *(int *)&_documentInEditor;
        }
        *(int *)&_documentInEditor = iVar1 + 1;
    }
}

- (BOOL)areDocumentSpecificPresentationSettingsActive
{
    return *(int *)&_documentInEditor != 0;
}

- (BOOL)supportsHomeStack
{
    return YES;
}

- (Class)defaultNavigationControllerClass
{
    return [HSEditorNavigationController class];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _onionSkinMode = 0;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_sharedPlayerInEditorWindowController release];
    [_sharedPurePlayerWindowController release];
    [_sharedPresentationWindowController release];
    [_applicationLicensor release];
    [_filesToOpen release];
    [super dealloc];
}

@end

@implementation NSWorkspace (HSFileTypesUtilities)

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002dbec @ 0002dbec, 284 bytes * /

BOOL FUN_0002dbec(id self,SEL _cmd,id isFileMediaOrTextAtPath)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar2 = isFileMediaOrTextAtPath;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperIsTextForPath_,isFileMediaOrTextAtPath);
  if ((char)pvVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar2);
    uVar3 = 0;
    pvVar2 = _objc_msgSend(pvVar2,sel_fileAttributesAtPath_traverseLink_,isFileMediaOrTextAtPath,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_fileType);
    uVar4 = *(undefined4 *)PTR_003361b8;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,uVar4);
    if ((char)pvVar2 == '\0') {
      return '\0';
    }
    pvVar2 = _objc_msgSend(isFileMediaOrTextAtPath,sel_pathExtension,uVar4,uVar3);
    uVar4 = 1;
    pvVar2 = _objc_msgSend(pvVar2,sel_compare_options_,&cfstr_pdf,1);
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_QTMovie,sel_canInitWithFile_,isFileMediaOrTextAtPath,uVar4);
      return (BOOL)pvVar2;
    }
  }
  return '\x01';
}

*/
- (BOOL)isFileMediaOrTextAtPath:(id)aPath
{
    if ([[NSFileManager defaultManager] hyperIsTextForPath:aPath]) {
        return YES;
    }
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:NULL] fileType];
    if (![fileType isEqualToString:NSFileTypeRegular]) {
        return NO;
    }
    if ([[aPath pathExtension] compare:@"pdf" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
        return [QTMovie canInitWithFile:aPath];
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003417e @ 0003417e, 317 bytes * /

BOOL FUN_0003417e(id self,SEL _cmd,id isFileMovieAtPath)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  id *ppvVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_fileAttributesAtPath_traverseLink_,isFileMovieAtPath,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_fileType);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,*(undefined4 *)PTR_003361b8);
  if ((char)pvVar1 != '\0') {
    local_14 = (id)0x0;
    ppvVar5 = &local_14;
    uVar4 = 0;
    pvVar2 = _objc_msgSend(self,sel_getInfoForFile_application_type_,isFileMovieAtPath,0,ppvVar5);
    pvVar1 = local_14;
    uVar3 = _NSHFSTypeOfFile(isFileMovieAtPath);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,uVar3);
    if ((char)pvVar1 == '\0') {
      local_14 = _objc_msgSend(local_14,sel_lowercaseString,uVar3,uVar4,ppvVar5);
    }
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(cls_HSMovieObject,sel_movieFileTypes,uVar3,uVar4,ppvVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,local_14);
      return (char)pvVar1 != '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)isFileMovieAtPath:(id)aPath
{
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:NULL] fileType];
    if (![fileType isEqualToString:NSFileTypeRegular]) {
        return NO;
    }
    NSString *type = nil;
    BOOL found = [self getInfoForFile:aPath application:NULL type:&type];
    if (![type isEqualToString:NSHFSTypeOfFile(aPath)]) {
        type = [type lowercaseString];
    }
    if (!found) {
        return NO;
    }
    return [[HSMovieObject movieFileTypes] containsObject:type];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002da8c @ 0002da8c, 352 bytes * /

BOOL FUN_0002da8c(id self,SEL _cmd,id isFileImageAtPath)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  int *piVar4;
  undefined4 *puVar5;
  int local_18;
  undefined4 local_14;
  
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_fileAttributesAtPath_traverseLink_,isFileImageAtPath,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_fileType);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,*(undefined4 *)PTR_003361b8);
  if ((char)pvVar1 != '\0') {
    local_14 = 0;
    puVar5 = &local_14;
    uVar3 = 0;
    pvVar1 = isFileImageAtPath;
    pvVar2 = _objc_msgSend(self,sel_getInfoForFile_application_type_,isFileImageAtPath,0,puVar5);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(cls_NSImage,sel_imageFileTypes,pvVar1,uVar3,puVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,local_14);
      self_00 = cls_HSMovie;
      if ((char)pvVar1 != '\0') {
        local_18 = 0;
        pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,isFileImageAtPath,uVar3,puVar5);
        piVar4 = &local_18;
        pvVar2 = _objc_msgSend(self_00,sel_movieWithURL_error_,pvVar1,piVar4);
        if (local_18 != 0) {
          return '\x01';
        }
        pvVar1 = _objc_msgSend(pvVar2,sel_isAnimatedGifMovie,pvVar1,piVar4);
        return (char)pvVar1 == '\0';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)isFileImageAtPath:(id)aPath
{
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:NULL] fileType];
    if (![fileType isEqualToString:NSFileTypeRegular]) {
        return NO;
    }
    NSString *type = nil;
    if (![self getInfoForFile:aPath application:NULL type:&type]) {
        return NO;
    }
    if (![[NSImage imageFileTypes] containsObject:type]) {
        return NO;
    }
    NSError *error = nil;
    HSMovie *movie = [HSMovie movieWithURL:[NSURL fileURLWithPath:aPath] error:&error];
    if (error != nil) {
        return YES;
    }
    return ![movie isAnimatedGifMovie];
}

@end

