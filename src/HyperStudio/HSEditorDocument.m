#import "HSEditorDocument.h"
static id sDAT_00342a44;
static id sDAT_00342a48;
static id sDAT_00342a4c;
static id sDAT_00342a50;

static id sDAT_00342a44;
static id sDAT_00342a48;
static id sDAT_00342a4c;
static id sDAT_00342a50;


@implementation HSEditorDocument

/* i386 ivar offsets: _iPadStack=0xb0, _originalStackStorage=0xb4, _iPadUndoManager=0xb8, _modeSwitcher=0xbc, _animationModeController=0xc0, _exportManager=0xc4, _documentSharingController=0xc8, _commitLogMessage=0xcc, _isReceived=0xd0, _isHyperCollaborative=0xd1, _isHyperServer=0xd2, _isHyperClient=0xd3, _hyperSaveOperation=0xd4, _hyperRemovedItemsPaths=0xd8, _autosaveUndoManager=0xdc, _openWarning=0xe0, _editObjectDialogContext=0xe4, _selectionController=0xe8, _stackSelectionHolder=0xec, _selectionSync=0xf0, _storyboardController=0xf4, _purePlayerWindowController=0xf8, _presentationWindowController=0xfc, _playerInEditorWindowController=0x100, _hyperCastingWindowController=0x104, _invocationsToPerformAfterSwitchToEditMode=0x108, _modeHistory=0x10c, _playerView=0x110, _minimalWindowApplier=0x114, _isReadyToCreateMinimalWindowApplier=0x118, _hasPendingRequestToCreateMinimalWindowApplier=0x119, _isInDocumentClosing=0x11a, _palettesToHideInHypercastingMode=0x11c, _textViewsToResetScrollPosition=0x120, _wasOptimizedAndNotSaved=0x124 */

- (id)previewImageToStoreForCard:(id)aCard
{
    id pvVar1;

    pvVar1 = [super previewImageToStoreForCard:aCard];
    if (pvVar1 == nil) {
        pvVar1 = [[self stackView] previewImageToStoreForCard:aCard];
        [self setPreviewImage:pvVar1 forCard:aCard];
    }
    return pvVar1;
}

- (id)thumbnailImageToStoreForCard:(id)aCard
{
    id pvVar1;

    pvVar1 = [super thumbnailImageToStoreForCard:aCard];
    if (pvVar1 == nil) {
        pvVar1 = [[self stackView] thumbnailImageToStoreForCard:aCard];
        [self setThumbnailImage:pvVar1 forCard:aCard];
    }
    return pvVar1;
}

- (void)exportManagerDidEndPublishing:(id)aPublishing
{
    [[self exportManager] closeExportSession];
}

- (void)exportManagerDidEnd:(id)aEnd
{
    [[self stackView] setMediaStripUpdateDisabled:NO];
    [self clearCaches];
}

- (void)exportManagerWillStart:(id)aStart
{
    [[self stackView] setMediaStripUpdateDisabled:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00271ec7 @ 00271ec7, 581 bytes * /

void FUN_00271ec7(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorNotInstalledMessageText,&cfstr_empty,&cfstr_Alerts);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorNotInstalledInformativeText,&cfstr_empty,&cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorNotInstalledDownloadNowButtonTitle,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  _objc_msgSend(self_00,sel_setAlertStyle_,5);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar2);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar3);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar4);
  pvVar1 = _objc_msgSend(self_00,sel_runModal);
  _objc_msgSend(self_00,sel_release);
  if (pvVar1 == (id)0x3e8) {
    pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar4);
    pvVar2 = _objc_msgSend(cls_NSURL,sel_URLWithString_,&cfstr_http___www_hyperstudio_com_hsa);
    _objc_msgSend(pvVar1,sel_openURL_,pvVar2);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0027210c @ 0027210c, 154 bytes * /

void FUN_0027210c(HSEditorDocument *self,SEL _cmd,id HSAuthorOpenAlertDidEnd,int returnCode,
                 void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  SEL op;
  
  op = sel_openInHSAuthor;
  if (returnCode != 1000) {
    pvVar1 = _objc_msgSend(cls_NSMenuItem,sel_class);
    pvVar2 = _objc_msgSend(contextInfo,sel_isKindOfClass_,pvVar1);
    if ((((char)pvVar2 == '\0') ||
        (puVar3 = _objc_msgSend(contextInfo,sel_action,pvVar1), op = sel_exportTo_,
        puVar3 != sel_exportTo_)) && (op = sel_exportTo_, contextInfo != self)) {
      return;
    }
  }
  _objc_msgSend(self,op);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_002721a6 @ 002721a6, 538 bytes * /

void FUN_002721a6(HSEditorDocument *self,SEL _cmd,id showExportToHTML5Alert)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSExportToHTML5MessageText,&cfstr_empty,&cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_HSExportToHTML5InformativeText,&cfstr_empty,&cfstr_Alerts);
  pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorOpenButtonTitle,&cfstr_empty,&cfstr_Alerts);
  pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar6 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
  _objc_msgSend(pvVar6,sel_setAlertStyle_,5);
  _objc_msgSend(pvVar6,sel_setMessageText_,pvVar2);
  _objc_msgSend(pvVar6,sel_setInformativeText_,pvVar3);
  _objc_msgSend(pvVar6,sel_addButtonWithTitle_,pvVar4);
  _objc_msgSend(pvVar6,sel_addButtonWithTitle_,pvVar5);
  puVar1 = sel_HSAuthorOpenAlertDidEnd_returnCode_contextInfo_;
  pvVar2 = _objc_msgSend(self,sel_windowForSheet);
  _objc_msgSend(pvVar6,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,pvVar2
                ,self,puVar1,showExportToHTML5Alert);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_002723c0 @ 002723c0, 538 bytes * /

void FUN_002723c0(HSEditorDocument *self,SEL _cmd,id showHSAuthorOpenAlert)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorOpenMessageText,&cfstr_empty,&cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorOpenInformativeText,&cfstr_empty,&cfstr_Alerts);
  pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAuthorOpenButtonTitle,&cfstr_empty,&cfstr_Alerts);
  pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar6 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
  _objc_msgSend(pvVar6,sel_setAlertStyle_,5);
  _objc_msgSend(pvVar6,sel_setMessageText_,pvVar2);
  _objc_msgSend(pvVar6,sel_setInformativeText_,pvVar3);
  _objc_msgSend(pvVar6,sel_addButtonWithTitle_,pvVar4);
  _objc_msgSend(pvVar6,sel_addButtonWithTitle_,pvVar5);
  puVar1 = sel_HSAuthorOpenAlertDidEnd_returnCode_contextInfo_;
  pvVar2 = _objc_msgSend(self,sel_windowForSheet);
  _objc_msgSend(pvVar6,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,pvVar2
                ,self,puVar1,showHSAuthorOpenAlert);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_002725da @ 002725da, 764 bytes * /

void FUN_002725da(HSEditorDocument *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSEditorDocument *pHVar4;
  id pvVar5;
  HSEditorDocument *pHVar6;
  cfstringStruct *pcVar7;
  undefined4 uVar8;
  
  pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pcVar7 = &cfstr_com_mackiev_hyperstudioauthor;
  pvVar2 = _objc_msgSend(pvVar1,sel_absolutePathForAppBundleWithIdentifier_,
                         &cfstr_com_mackiev_hyperstudioauthor);
  pHVar4 = (HSEditorDocument *)pcVar7;
  if (pvVar2 == (id)0x0) goto LAB_002728b9;
  pvVar3 = _objc_msgSend(self,sel_fileURL,pcVar7);
  pHVar4 = _objc_msgSend(pvVar3,sel_path);
  if ((pHVar4 == (HSEditorDocument *)0x0) ||
     (pvVar3 = _objc_msgSend(self,sel_isDocumentEdited,pcVar7), (char)pvVar3 != '\0')) {
    pHVar4 = (HSEditorDocument *)pcVar7;
    if (DAT_00342a54 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSString,sel_hyperUIDString,pHVar4);
      if (pvVar3 == (id)0x0) goto LAB_002728b9;
      pvVar5 = (id)_NSTemporaryDirectory();
      pHVar6 = _objc_msgSend(pvVar5,sel_stringByAppendingPathComponent_,pvVar3);
      pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
      uVar8 = 0;
      pHVar4 = pHVar6;
      pvVar3 = _objc_msgSend(pvVar3,sel_createDirectoryAtPath_attributes_,pHVar6,0);
      if ((char)pvVar3 == '\0') goto LAB_002728b9;
      DAT_00342a54 = _objc_msgSend(pHVar6,sel_retain,pHVar4,uVar8);
    }
    pvVar3 = _objc_msgSend(self,sel_currentWindowController,pHVar4);
    _objc_msgSend(pvVar3,sel_saveEditingState);
    pHVar4 = (HSEditorDocument *)0x0;
    _objc_msgSend(self,sel_setResourcesWrapper_,0);
    pvVar3 = _objc_msgSend(self,sel_resourcesWrapper);
    if ((pvVar3 == (id)0x0) ||
       (pHVar4 = self,
       pvVar5 = _objc_msgSend(cls_HSMediaSaver,sel_saveMediaForDocument_resourcesWrapper_,self,
                              pvVar3), (char)pvVar5 == '\0')) goto LAB_002728b9;
    _objc_msgSend(self,sel_reloadDocumentMedia,pHVar4,pvVar3);
    pvVar3 = _objc_msgSend(self,sel_displayName);
    pvVar5 = _objc_msgSend(pvVar3,sel_pathExtension);
    pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,&cfstr_stack);
    if ((char)pvVar5 == '\0') {
      pvVar3 = _objc_msgSend(pvVar3,sel_stringByAppendingPathExtension_,&cfstr_stack);
    }
    self_00 = cls_NSURL;
    pvVar3 = _objc_msgSend(DAT_00342a54,sel_stringByAppendingPathComponent_,pvVar3);
    pHVar6 = _objc_msgSend(self_00,sel_fileURLWithPath_,pvVar3);
    pcVar7 = &cfstr_HSDocumentType;
    uVar8 = 0;
    pHVar4 = pHVar6;
    pvVar3 = _objc_msgSend(self,sel_writeToURL_ofType_error_,pHVar6,&cfstr_HSDocumentType,0);
    if ((char)pvVar3 == '\0') goto LAB_002728b9;
    pHVar4 = _objc_msgSend(pHVar6,sel_path,pHVar4,pcVar7,uVar8);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_openFile_withApplication_andDeactivate_,pHVar4,pvVar2,1);
  if ((char)pvVar1 != '\0') {
    return;
  }
LAB_002728b9:
  _objc_msgSend(self,sel_showHSAuthorNotInstalledAlert,pHVar4);
  return;
}

*/
- (void)exportForiBooksAuthor:(id)aAuthor
{
    [self exportToDocumentWithType:@"HSiBooksAuthorDocumentType" inPublishType:3 inFormat:8 withRequiredFileType:@"wdgt"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027294d @ 0027294d, 122 bytes * /

void FUN_0027294d(HSEditorDocument *self,SEL _cmd,id exportToHTML5)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(self,sel_shouldOpenHSAuthorForExport);
  op = sel_showExportToHTML5Alert_;
  pcVar2 = exportToHTML5;
  if ((char)pvVar1 == '\0') {
    pcVar2 = &cfstr_HSHTML5DocumentType;
    op = sel_exportToDocumentWithType_inPublishType_inFormat_withRequiredFileType_;
  }
  _objc_msgSend(self,op,pcVar2);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_002729c7 @ 002729c7, 308 bytes * /

void FUN_002729c7(HSEditorDocument *self,SEL _cmd,id exportToDocumentWithType,int inPublishType,
                 int inFormat,id withRequiredFileType)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_isWritingDisabled);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_exportManager);
    pvVar2 = _objc_msgSend(pvVar1,sel_isOpenExportSession);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(pvVar1,sel_closeExportSession);
    }
    _objc_msgSend(pvVar1,sel_openExportSessionWithDocument_,self);
    _objc_msgSend(pvVar1,sel_setPublishType_,inPublishType);
    _objc_msgSend(pvVar1,sel_setExportFormat_,inFormat);
    pvVar2 = _objc_msgSend(withRequiredFileType,sel_length);
    if (pvVar2 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_exportPanelController,inFormat);
      _objc_msgSend(pvVar1,sel_setRequiredFileType_,withRequiredFileType);
    }
    _objc_msgSend(self,
                  sel_runModalExportPanelWithDelegate_didSaveSelector_contextInfo_needRunExportDialogOnCancel_
                  ,self,sel_exportPanelControllerDidEnd_returnCode_contextInfo_,
                  exportToDocumentWithType,0);
  }
  return;
}

*/
- (void)exportToDocumentWithType:(id)aType inPublishType:(NSInteger)aType2 inFormat:(NSInteger)aFormat withRequiredFileType:(id)aType3
{
    if (![self isWritingDisabled]) {
        id manager = [self exportManager];
        if ([manager isOpenExportSession]) {
            [manager closeExportSession];
        }
        [manager openExportSessionWithDocument:self];
        [manager setPublishType:aType2];
        [manager setExportFormat:aFormat];
        if ([aType3 length] != 0) {
            [[manager exportPanelController] setRequiredFileType:aType3];
        }
        [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEnd:returnCode:contextInfo:) contextInfo:aType needRunExportDialogOnCancel:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00272afb @ 00272afb, 645 bytes * /

void FUN_00272afb(HSEditorDocument *self,SEL _cmd,id exportTo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *self_00;
  SEL op;
  HSEditorDocument *pHVar5;
  HSEditorDocument *pHVar6;
  
  pvVar1 = _objc_msgSend(self,sel_isWritingDisabled);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSExportComboDialog,sel_new);
  pHVar5 = self;
  pvVar2 = _objc_msgSend(pvVar1,sel_runModalWithDelegate_,self);
  pHVar6 = pHVar5;
  if (pvVar2 != (id)0x1) goto LAB_00272d63;
  pvVar2 = _objc_msgSend(pvVar1,sel_exportFormat,pHVar5);
  pvVar3 = _objc_msgSend(self,sel_shouldOpenHSAuthorForExport);
  if (((char)pvVar3 != '\0') &&
     (op = sel_showExportToHTML5Alert_, pHVar6 = exportTo, pvVar2 == (id)0x7)) goto LAB_00272d5e;
  pvVar3 = _objc_msgSend(self,sel_exportManager,pHVar5);
  pvVar4 = _objc_msgSend(pvVar3,sel_isOpenExportSession);
  if ((char)pvVar4 != '\0') {
    _objc_msgSend(pvVar3,sel_closeExportSession);
  }
  _objc_msgSend(pvVar3,sel_openExportSessionWithDocument_,self);
  pvVar4 = _objc_msgSend(pvVar1,sel_publishType);
  _objc_msgSend(pvVar3,sel_setExportFormat_,pvVar2);
  switch(pvVar2) {
  case (id)0x1:
    break;
  case (id)0x2:
    break;
  case (id)0x3:
    break;
  case (id)0x4:
    break;
  case (id)0x5:
    goto joined_r0x00272ca7;
  case (id)0x6:
joined_r0x00272ca7:
    if (pvVar4 == (id)0x1) {
      pvVar4 = (id)0x2;
    }
    break;
  case (id)0x7:
    break;
  case (id)0x8:
  }
  _objc_msgSend(pvVar3,sel_setPublishType_,pvVar4);
  if (pvVar2 == (id)0x7) {
    self_00 = &cfstr_empty;
  }
  else if (pvVar2 == (id)0x8) {
    self_00 = &cfstr_wdgt;
  }
  else {
    self_00 = (cfstringStruct *)0x0;
  }
  pvVar2 = _objc_msgSend(self_00,sel_length,pvVar4);
  op = sel_runModalExportPanelWithDelegate_didSaveSelector_contextInfo_needRunExportDialogOnCancel_;
  pHVar6 = self;
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar3,sel_exportPanelController,pvVar4);
    _objc_msgSend(pvVar2,sel_setRequiredFileType_,self_00);
    op = 
    sel_runModalExportPanelWithDelegate_didSaveSelector_contextInfo_needRunExportDialogOnCancel_;
  }
LAB_00272d5e:
  _objc_msgSend(self,op,pHVar6);
LAB_00272d63:
  _objc_msgSend(pvVar1,sel_release,pHVar6);
  return;
}

*/
- (void)exportTo:(id)aTo
{
    if ([self isWritingDisabled]) {
        return;
    }
    HSExportComboDialog *dialog = [HSExportComboDialog new];
    if ([dialog runModalWithDelegate:self] == 1) {
        NSInteger format = [dialog exportFormat];
        if ([self shouldOpenHSAuthorForExport] && format == 7) {
            [self showExportToHTML5Alert:aTo];
        } else {
            id manager = [self exportManager];
            if ([manager isOpenExportSession]) {
                [manager closeExportSession];
            }
            [manager openExportSessionWithDocument:self];
            NSInteger publishType = [dialog publishType];
            [manager setExportFormat:format];
            NSString *documentType = nil;
            switch (format) {
                case 1: documentType = @"HSWebDocumentType"; break;
                case 2: documentType = @"HSMakeStackToGoDocumentType"; break;
                case 3: documentType = @"HSImageSequenceDocumentType"; break;
                case 4: documentType = @"HSQTMovieDocumentType"; break;
                case 5:
                    documentType = @"HSiPodDocumentType";
                    if (publishType == 1) {
                        publishType = 2;
                    }
                    break;
                case 6:
                    documentType = @"HSiPhoneDocumentType";
                    if (publishType == 1) {
                        publishType = 2;
                    }
                    break;
                case 7: documentType = @"HSHTML5DocumentType"; break;
                case 8: documentType = @"HSiBooksAuthorDocumentType"; break;
                default: break;
            }
            [manager setPublishType:publishType];
            NSString *requiredFileType = (format == 7) ? @"" : (format == 8) ? @"wdgt" : nil;
            if ([requiredFileType length] != 0) {
                [[manager exportPanelController] setRequiredFileType:requiredFileType];
            }
            [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEnd:returnCode:contextInfo:) contextInfo:documentType needRunExportDialogOnCancel:YES];
        }
    }
    [dialog release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00272da0 @ 00272da0, 291 bytes * /

void FUN_00272da0(HSEditorDocument *self,SEL _cmd,int exitFromHyperCastingModeWithReturnCode)

{
  id pvVar1;
  id self_00;
  HSEditorDocument *self_01;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_switching);
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_isInHyperCastingMode), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_modeHistory);
    pvVar1 = _objc_msgSend(pvVar1,sel_lastObject);
    self_01 = self;
    op = sel_switchToEditor;
    if (pvVar1 != (id)0x0) {
      self_00 = _objc_msgSend(self,sel_modeSwitcher);
      _objc_msgSend(self_00,sel_switchToModeController_,pvVar1);
      self_01 = _objc_msgSend(self,sel_modeHistory);
      op = sel_removeLastObject;
    }
    _objc_msgSend(self_01,op);
    pvVar1 = _objc_msgSend(self,sel_hyperCastingWindowController);
    _objc_msgSend(pvVar1,sel_setHyperCastingWindowControllerDelegate_,0);
    _objc_msgSend(self,sel_showPalettesAfterExport);
  }
  return;
}

*/
- (void)exitFromHyperCastingModeWithReturnCode:(NSInteger)aCode
{
    if (![[self modeSwitcher] switching] && [self isInHyperCastingMode]) {
        id lastMode = [[self modeHistory] lastObject];
        if (lastMode != nil) {
            [[self modeSwitcher] switchToModeController:lastMode];
            [[self modeHistory] removeLastObject];
        } else {
            [self switchToEditor];
        }
        [[self hyperCastingWindowController] setHyperCastingWindowControllerDelegate:nil];
        [self showPalettesAfterExport];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00272ec3 @ 00272ec3, 373 bytes * /

void FUN_00272ec3(HSEditorDocument *self,SEL _cmd,id switchToHyperCastingModeWithDelegate)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_editorWindowController);
  _objc_msgSend(pvVar1,sel_saveScrollerPosition);
  _objc_msgSend(pvVar1,sel_saveEditingState);
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_00336430);
  _objc_msgSend(pvVar1,sel_set);
  pvVar1 = _objc_msgSend(self,sel_modeHistory);
  pvVar2 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar2 = _objc_msgSend(pvVar2,sel_activeModeController);
  _objc_msgSend(pvVar1,sel_addObject_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_hyperCastingWindowController);
  _objc_msgSend(pvVar1,sel_setHyperCastingWindowControllerDelegate_,
                switchToHyperCastingModeWithDelegate);
  pvVar2 = _objc_msgSend(self,sel_isInPurePlayerMode);
  if ((char)pvVar2 != '\0') {
    switchToHyperCastingModeWithDelegate = (id)0x0;
    _objc_msgSend(self,sel_exitPurePlayerModeWithAnimation_,0);
  }
  pvVar2 = _objc_msgSend(self,sel_modeSwitcher,switchToHyperCastingModeWithDelegate);
  _objc_msgSend(pvVar2,sel_switchWithoutAnimationToModeController_deffered_,pvVar1,0);
  _objc_msgSend(self,sel_hidePalettesBeforeExport);
  return;
}

*/
- (void)switchToHyperCastingModeWithDelegate:(id)aDelegate
{
    id editorWindowController = [self editorWindowController];
    [editorWindowController saveScrollerPosition];
    [editorWindowController saveEditingState];
    [[HSCursor cursorNamed:HSDefaultCursor] set];
    [[self modeHistory] addObject:[[self modeSwitcher] activeModeController]];
    id hyperCastingController = [self hyperCastingWindowController];
    [hyperCastingController setHyperCastingWindowControllerDelegate:aDelegate];
    if ([self isInPurePlayerMode]) {
        [self exitPurePlayerModeWithAnimation:NO];
    }
    [[self modeSwitcher] switchWithoutAnimationToModeController:hyperCastingController deffered:NO];
    [self hidePalettesBeforeExport];
}

- (id)hyperCastingWindowController
{
    HSHyperCastingWindowController *pHVar1;
    HSHyperCastingWindowController *pHVar1_2;

    pHVar1 = _hyperCastingWindowController;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSHyperCastingWindowController new];
        _hyperCastingWindowController = pHVar1_2;
        [self addWindowController:pHVar1_2];
        pHVar1 = _hyperCastingWindowController;
    }
    return pHVar1;
}

- (id)objectListTopLevelParent
{
    return [[self currentWindowController] activeCard];
}

- (id)objectListSelectionSynchronizer
{
    return [self selectionSync];
}

- (void)toggleBottomToolbar:(id)aToolbar
{
    BOOL pvVar1_2;

    pvVar1_2 = [[self currentWindowController] isBottomToolbarVisible];
    [[self currentWindowController] setBottomToolbarVisible:(unsigned int)(!pvVar1_2)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00273164 @ 00273164, 106 bytes * /

void FUN_00273164(HSEditorDocument *self,SEL _cmd,id toggleCardIndex)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_stackView);
  pvVar1 = _objc_msgSend(self_00,sel_isStripVisible);
  op = sel_showCardIndex_;
  if ((char)pvVar1 != '\0') {
    op = sel_hideCardIndex_;
  }
  _objc_msgSend(self_00,op,self);
  return;
}

*/
- (void)toggleCardIndex:(id)aIndex
{
    id stackView = [self stackView];
    if ([stackView isStripVisible]) {
        [stackView hideCardIndex:self];
    } else {
        [stackView showCardIndex:self];
    }
}

- (void)removeCurrentCard:(id)aCard
{
    [self removeCurrentCardWithAlert:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002731fc @ 002731fc, 1619 bytes * /

void FUN_002731fc(HSEditorDocument *self,SEL _cmd,id removeCards,BOOL withAlert)

{
  cfstringStruct *pcVar1;
  bool bVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  HSEditorDocument *pHVar9;
  ushort uVar10;
  uint uVar11;
  cfstringStruct *pcVar12;
  cfstringStruct *pcVar13;
  SEL op;
  
  cVar3 = '\x01';
  pvVar4 = _objc_msgSend(removeCards,sel_objectEnumerator);
  do {
    pvVar5 = _objc_msgSend(pvVar4,sel_nextObject);
    if (pvVar5 == (id)0x0) break;
    pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_003875bc);
    pvVar5 = _objc_msgSend(pvVar5,sel_isEmpty);
    cVar3 = (char)pvVar5;
  } while (cVar3 != '\0');
  if (withAlert != '\0') {
    pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,&cfstr_HSDeleteCardAlertShow);
    pvVar4 = _objc_msgSend(pvVar4,sel_intValue);
    if ((pvVar4 != (id)0x0) && (cVar3 == '\0')) {
      bVar2 = true;
      goto LAB_002732ce;
    }
  }
  bVar2 = false;
LAB_002732ce:
  uVar11 = 0;
  pvVar4 = _objc_msgSend(self,sel_stack);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperEnumerator);
  do {
    cVar3 = (char)(uVar11 >> 8);
    pvVar5 = _objc_msgSend(pvVar4,sel_nextObject);
    if (pvVar5 == (id)0x0) break;
    pvVar6 = _objc_msgSend(removeCards,sel_containsObject_,pvVar5);
    if ((char)pvVar6 == '\0') {
      pvVar6 = removeCards;
      pvVar8 = pvVar5;
      pvVar7 = _objc_msgSend(self,sel_hasClickingOtherCardActionLeadingToCards_inObject_,removeCards
                             ,pvVar5);
      cVar3 = (char)pvVar7;
      uVar10 = CONCAT11(cVar3,bVar2);
      if (cVar3 != '\0') break;
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperEnumerator,pvVar6,pvVar8);
      while( true ) {
        uVar11 = (uint)uVar10;
        pvVar8 = _objc_msgSend(pvVar5,sel_nextObject,pvVar6,pvVar8);
        if (pvVar8 == (id)0x0) break;
        pvVar6 = removeCards;
        pvVar7 = _objc_msgSend(self,sel_hasClickingOtherCardActionLeadingToCards_inObject_,
                               removeCards,pvVar8);
        if ((char)pvVar7 != '\0') {
          uVar11 = ((uint)pvVar7 & 0xff) << 8;
          break;
        }
        uVar10 = 0;
      }
    }
    cVar3 = (char)(uVar11 >> 8);
  } while (cVar3 == '\0');
  if (cVar3 == '\0') {
    op = sel_actuallyRemoveCards_;
    if (bVar2) {
      pHVar9 = _objc_msgSend(cls_HSDontShowAgainAlert,sel_new);
      pvVar4 = _objc_msgSend(removeCards,sel_count);
      pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar12 = &cfstr_HSDeleteCardAlertMessageText;
      if ((id)0x1 < pvVar4) {
        pcVar12 = &cfstr_HSDeleteCardsAlertMessageText;
      }
      pcVar13 = &cfstr_HSDeleteCardAlertInformativeText;
      pcVar1 = &cfstr_HSDeleteCardAlertFirstButtonTitle;
      if ((id)0x1 < pvVar4) {
        pcVar13 = &cfstr_HSDeleteCardsAlertInformativeText;
        pcVar1 = &cfstr_HSDeleteCardsAlertFirstButtonTitle;
      }
      pvVar4 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,pcVar12,&cfstr_empty,
                             &cfstr_Alerts);
      _objc_msgSend(pHVar9,sel_setMessageText_,pvVar4);
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,pcVar13,&cfstr_empty,
                             &cfstr_Alerts);
      _objc_msgSend(pHVar9,sel_setInformativeText_,pvVar4);
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,pcVar1,&cfstr_empty,
                             &cfstr_Alerts);
      _objc_msgSend(pHVar9,sel_addButtonWithTitle_,pvVar4);
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                             &cfstr_HSDeleteCardAlertSecondButtonTitle,&cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pHVar9,sel_addButtonWithTitle_,pvVar4);
      _objc_msgSend(pHVar9,sel_setShowAlertKey_,&cfstr_HSDeleteCardAlertShow);
      _objc_msgSend(removeCards,sel_retain);
      pvVar4 = _objc_msgSend(self,sel_currentWindowController);
      removeCards = _objc_msgSend(pvVar4,sel_window);
      self = pHVar9;
      op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
    }
  }
  else {
    pHVar9 = _objc_msgSend(cls_HSAlert,sel_new);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInconsistentActionsAlertMessageText,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pHVar9,sel_setMessageText_,pvVar4);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInconsistentActionsAlertInformativeText,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pHVar9,sel_setInformativeText_,pvVar4);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInconsistentActionsAlertDefaultButtonTitle,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pHVar9,sel_addButtonWithTitle_,pvVar4);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pHVar9,sel_addButtonWithTitle_,pvVar4);
    _objc_msgSend(removeCards,sel_retain);
    pvVar4 = _objc_msgSend(self,sel_currentWindowController);
    removeCards = _objc_msgSend(pvVar4,sel_window);
    self = pHVar9;
    op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
  }
  _objc_msgSend(self,op,removeCards);
  return;
}

*/
- (void)removeCards:(id)aCards withAlert:(BOOL)aAlert
{
    BOOL allEmpty = YES;
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        allEmpty = [[card queryHyperInterface:@protocol(HSCardAttributes)] isEmpty];
        if (!allEmpty) {
            break;
        }
    }
    BOOL showAlert = NO;
    if (aAlert) {
        NSInteger setting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HSDeleteCardAlertShow"] intValue];
        showAlert = (setting != 0 && !allEmpty);
    }
    BOOL inconsistent = NO;
    NSEnumerator *cards = [[[self stack] hyperEnumerator] retain];
    id other;
    while (!inconsistent && (other = [cards nextObject]) != nil) {
        if ([aCards containsObject:other]) {
            continue;
        }
        if ([self hasClickingOtherCardActionLeadingToCards:aCards inObject:other]) {
            inconsistent = YES;
            break;
        }
        NSEnumerator *children = [other hyperEnumerator];
        id child;
        while ((child = [children nextObject]) != nil) {
            if ([self hasClickingOtherCardActionLeadingToCards:aCards inObject:child]) {
                inconsistent = YES;
                break;
            }
        }
    }
    [cards release];
    if (!inconsistent) {
        if (!showAlert) {
            [self actuallyRemoveCards:aCards];
            return;
        }
        HSDontShowAgainAlert *alert = [HSDontShowAgainAlert new];
        BOOL plural = [aCards count] > 1;
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        [alert setMessageText:[provider localizedStringForKey:(plural ? @"HSDeleteCardsAlertMessageText" : @"HSDeleteCardAlertMessageText") value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(plural ? @"HSDeleteCardsAlertInformativeText" : @"HSDeleteCardAlertInformativeText") value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:(plural ? @"HSDeleteCardsAlertFirstButtonTitle" : @"HSDeleteCardAlertFirstButtonTitle") value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSDeleteCardAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
        [alert setShowAlertKey:@"HSDeleteCardAlertShow"];
        [aCards retain];
        [alert beginSheetModalForWindow:[[self currentWindowController] window] modalDelegate:self didEndSelector:@selector(alertDeleteCardDidEnd:returnCode:contextInfo:) contextInfo:aCards];
        return;
    }
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInconsistentActionsAlertMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInconsistentActionsAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSInconsistentActionsAlertDefaultButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [aCards retain];
    [alert beginSheetModalForWindow:[[self currentWindowController] window] modalDelegate:self didEndSelector:@selector(alertDeleteCardDidEnd:returnCode:contextInfo:) contextInfo:aCards];
}

- (void)removeCurrentCardWithAlert:(BOOL)aAlert
{
    id pvVar1;

    pvVar1 = [self selectedCard];
    if (pvVar1 == nil) {
        pvVar1 = [self activeCard];
    }
    [self removeCards:[NSArray arrayWithObject:pvVar1] withAlert:aAlert];
}

- (void)removeSelectedCardsWithAlert:(BOOL)aAlert
{
    [self removeCards:[self selectedCards] withAlert:aAlert];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00273911 @ 00273911, 304 bytes * /

BOOL FUN_00273911(HSEditorDocument *self,SEL _cmd,id hasClickingOtherCardActionLeadingToCards,
                 id inObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  uint uVar5;
  
  pvVar1 = _objc_msgSend(inObject,sel_queryHyperInterface_,&DAT_003876fc);
  pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336084);
  pvVar3 = _objc_msgSend(cls_HSOtherCardAction,sel_actionType);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionOfType_forEvent_,pvVar3,pvVar2);
  uVar5 = 0;
  self_00 = _objc_msgSend(hasClickingOtherCardActionLeadingToCards,sel_objectEnumerator);
  while( true ) {
    pvVar3 = _objc_msgSend(self_00,sel_nextObject,pvVar3,pvVar2);
    if (pvVar3 == (id)0x0) {
      return (BOOL)uVar5;
    }
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003876c0,pvVar2);
    pvVar4 = _objc_msgSend(pvVar1,sel_destinationCardUID);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperUID);
    pvVar4 = _objc_msgSend(pvVar4,sel_isEqual_,pvVar3);
    if ((char)pvVar4 != '\0') break;
    uVar5 = (uint)pvVar4 & 0xff;
  }
  return (char)pvVar4;
}

*/
- (BOOL)hasClickingOtherCardActionLeadingToCards:(id)aCards inObject:(id)aObject
{
    id otherCardAction = [[aObject queryHyperInterface:@protocol(HSActor)] hyperActionOfType:[HSOtherCardAction actionType] forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if ([[otherCardAction destinationCardUID] isEqual:[[card queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID]]) {
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00273a41 @ 00273a41, 99 bytes * /

void FUN_00273a41(HSEditorDocument *self,SEL _cmd,id alertDeleteCardDidEnd,int returnCode,
                 void *contextInfo)

{
  if (returnCode == 1000) {
    _objc_msgSend(self,sel_actuallyRemoveCards_,contextInfo);
  }
  _objc_msgSend(contextInfo,sel_release);
  _objc_msgSend(alertDeleteCardDidEnd,sel_release);
  return;
}

*/
- (void)alertDeleteCardDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [self actuallyRemoveCards:(id)aInfo];
    }
    [(id)aInfo release];
    [aEnd release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00273aa4 @ 00273aa4, 745 bytes * /

void FUN_00273aa4(HSEditorDocument *self,SEL _cmd,id actuallyRemoveCards)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  HSEditorDocument *pHVar7;
  
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar1,sel_deactivateIfNeeded);
  pvVar1 = _objc_msgSend(cls_NSMutableIndexSet,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar1,sel_init);
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
  self_00 = _objc_msgSend(pvVar1,sel_init);
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
  self_01 = _objc_msgSend(pvVar1,sel_init);
  pvVar3 = _objc_msgSend(actuallyRemoveCards,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(pvVar3,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar1,sel_hyperIndex);
    _objc_msgSend(pvVar2,sel_addIndex_,pvVar4);
    pvVar5 = _objc_msgSend(pvVar1,sel_cardGroupUID);
    pvVar4 = self_01;
    if (pvVar5 != (id)0x0) {
      pvVar4 = self_00;
    }
    _objc_msgSend(pvVar4,sel_addObject_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar3,sel_nextObject);
  }
  pcVar6 = &cfstr_HSCardsIndexesForRemovalKey;
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar2,
                         &cfstr_HSCardsIndexesForRemovalKey);
  _objc_msgSend(pvVar2,sel_release);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar4 = _objc_msgSend(self_00,sel_count);
  if (pvVar4 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar2,sel_cardGroupController,pvVar1,pcVar6);
    pvVar1 = self_00;
    _objc_msgSend(pvVar4,sel_removeGroupCards_,self_00);
  }
  pvVar4 = _objc_msgSend(self_01,sel_count,pvVar1);
  if (pvVar4 != (id)0x0) {
    pvVar1 = self_01;
    _objc_msgSend(pvVar2,sel_removeHyperChildren_,self_01);
  }
  _objc_msgSend(self_01,sel_release,pvVar1);
  _objc_msgSend(self_00,sel_release);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pcVar6 = &cfstr_HSCardsDidDeleteNotification;
  pHVar7 = self;
  _objc_msgSend(pvVar1,sel_postNotificationName_object_userInfo_,&cfstr_HSCardsDidDeleteNotification
                ,self,pvVar3);
  if ((pvVar2 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(pvVar2,sel_hyperCount,pcVar6,pHVar7,pvVar3), pvVar1 == (id)0x0)) {
    _objc_msgSend(self,sel_newCard_,self,pHVar7,pvVar3);
  }
  return;
}

*/
- (void)actuallyRemoveCards:(id)aCards
{
    [[HSObjectAssistantController sharedAssistantController] deactivateIfNeeded];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray *groupCards = [[NSMutableArray alloc] init];
    NSMutableArray *plainCards = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        [indexes addIndex:[card hyperIndex]];
        if ([card cardGroupUID] != nil) {
            [groupCards addObject:card];
        } else {
            [plainCards addObject:card];
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:indexes forKey:@"HSCardsIndexesForRemovalKey"];
    [indexes release];
    id stack = [self stack];
    if ([groupCards count] != 0) {
        [[stack cardGroupController] removeGroupCards:groupCards];
    }
    if ([plainCards count] != 0) {
        [stack removeHyperChildren:plainCards];
    }
    [plainCards release];
    [groupCards release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCardsDidDeleteNotification" object:self userInfo:userInfo];
    if (stack != nil && [stack hyperCount] == 0) {
        [self newCard:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00273d8d @ 00273d8d, 309 bytes * /

void FUN_00273d8d(HSEditorDocument *self,SEL _cmd,id liveSlideShow)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_shouldHandleToolSwitching);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_canTogglePlayEdit), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_playerView);
    pvVar1 = _objc_msgSend(pvVar1,sel_isSlideshow);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_playerInEditorWindowController);
      pvVar2 = _objc_msgSend(pvVar1,sel_slideshowAttributesFromDialog);
      if (pvVar2 == (id)0x0) {
        return;
      }
      pvVar2 = _objc_msgSend(self,sel_currentCard);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
      _objc_msgSend(self,sel_testCardWithUID_animate_,pvVar2,0);
      op = sel_startSlideShowWithAttributes_;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_playerView);
      op = sel_stopSlideshow;
    }
    _objc_msgSend(pvVar1,op);
  }
  return;
}

*/
- (void)liveSlideShow:(id)aShow
{
    if ([self shouldHandleToolSwitching] && [self canTogglePlayEdit]) {
        if ([[self playerView] isSlideshow]) {
            [[self playerView] stopSlideshow];
        } else {
            id playerWindowController = [self playerInEditorWindowController];
            id attributes = [playerWindowController slideshowAttributesFromDialog];
            if (attributes == nil) {
                return;
            }
            [self testCardWithUID:[[self currentCard] hyperUID] animate:NO];
            [playerWindowController startSlideShowWithAttributes:attributes];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00273ec2 @ 00273ec2, 379 bytes * /

void FUN_00273ec2(HSEditorDocument *self,SEL _cmd,id newCard)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_HSCard,sel_defaultObject);
  pvVar2 = _objc_msgSend(self,sel_selectedHyperObject);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003876e8);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  self_00 = _objc_msgSend(self,sel_stack);
  op = sel_addHyperChild_;
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(self_00,sel_indexOfHyperChild_,pvVar2);
    self_00 = _objc_msgSend(self,sel_stack);
    op = sel_insertHyperChild_atIndex_;
    if (pvVar3 == (id)0x7fffffff) {
      pvVar2 = _objc_msgSend(self,sel_stack,pvVar2);
      _objc_msgSend(pvVar2,sel_hyperCount);
      op = sel_insertHyperChild_atIndex_;
    }
  }
  pvVar2 = pvVar1;
  _objc_msgSend(self_00,op,pvVar1);
  _objc_msgSend(pvVar1,sel_fillBackgroundWithEraserColorIfNeeded);
  pvVar1 = _objc_msgSend(self,sel_isInPlayerMode);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_editorWindowController,pvVar2);
    _objc_msgSend(pvVar1,sel_didAddNewCard);
  }
  return;
}

*/
- (void)newCard:(id)aCard
{
    HSCard *card = [HSCard defaultObject];
    id selectedCard = [[[self selectedHyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    id stack = [self stack];
    if (selectedCard != nil) {
        NSUInteger index = [stack indexOfHyperChild:selectedCard];
        index = (index == NSNotFound) ? [[self stack] hyperCount] : index + 1;
        [[self stack] insertHyperChild:card atIndex:index];
    } else {
        [stack addHyperChild:card];
    }
    [card fillBackgroundWithEraserColorIfNeeded];
    if (![self isInPlayerMode]) {
        [[self editorWindowController] didAddNewCard];
    }
}

- (id)selectionSync
{
    id pvVar1;
    HSEditorSelectionSync *pHVar3;
    HSEditorSelectionSync *pHVar3_2;

    pHVar3 = _selectionSync;
    if (pHVar3 == nil) {
        pvVar1 = [self editorWindowController];
        pHVar3_2 = [[HSEditorSelectionSync alloc] init];
        _selectionSync = pHVar3_2;
        [pHVar3_2 setStackSelectionHost:[self stackSelectionHolder]];
        [_selectionSync setWindowController:pvVar1];
        pHVar3 = _selectionSync;
    }
    return pHVar3;
}

- (id)stackSelectionHolder
{
    HSStackSelectionHolder *pHVar1;
    HSStackSelectionHolder *pHVar1_2;

    pHVar1 = _stackSelectionHolder;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSStackSelectionHolder alloc] init];
        _stackSelectionHolder = pHVar1_2;
        [pHVar1_2 setDocument:self];
        pHVar1 = _stackSelectionHolder;
    }
    return pHVar1;
}

- (id)selectionController
{
    id pvVar1;
    HSEditorSelectionController *pHVar2;
    HSEditorSelectionController *pHVar2_2;

    pHVar2 = _selectionController;
    if (pHVar2 == nil) {
        pvVar1 = [self editorWindowController];
        pHVar2_2 = [[HSEditorSelectionController alloc] init];
        _selectionController = pHVar2_2;
        [pHVar2_2 setWindowController:pvVar1];
        [_selectionController setCardView:[self editorCardView]];
        [_selectionController setStackController:[self stackView]];
        [_selectionController setEnabled:YES];
        pHVar2 = _selectionController;
    }
    return pHVar2;
}

- (id)selectedHyperObject
{
    id pvVar1_2;

    pvVar1_2 = [[self selectionController] selectedHyperObject];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [self stack];
    }
    return pvVar1_2;
}

- (id)activeCard
{
    id pvVar1_3;

    if (![self isInStoryboardMode]) {
        pvVar1_3 = [[self editorWindowController] activeCard];
    }
    else {
        pvVar1_3 = nil;
    }
    return pvVar1_3;
}

- (id)selectedCard
{
    id self_00;
    BOOL pvVar1;
    id pvVar2;

    self_00 = [self selectedHyperObject];
    pvVar1 = [self_00 implementsHyperInterface:@protocol(HSCardAttributes)];
    pvVar2 = nil;
    if (pvVar1) {
        pvVar2 = self_00;
    }
    return pvVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00274365 @ 00274365, 336 bytes * /

id FUN_00274365(HSEditorDocument *self,SEL _cmd)

{
  HSExportManager *pHVar1;
  id self_00;
  
  pHVar1 = self->_exportManager;
  if (pHVar1 == (HSExportManager *)0x0) {
    pHVar1 = _objc_msgSend(cls_HSExportManager,sel_new);
    self->_exportManager = pHVar1;
    self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,sel_exportManagerWillStart_,
                  *(undefined4 *)PTR_PTR_00336428,self->_exportManager);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,sel_exportManagerDidEnd_,
                  *(undefined4 *)PTR_PTR_00336424,self->_exportManager);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,
                  sel_exportManagerDidEndPublishing_,*(undefined4 *)PTR_PTR_00336960,
                  self->_exportManager);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,
                  sel_exportManagerDidEndPublishing_,*(undefined4 *)PTR_PTR_00336964,
                  self->_exportManager);
    pHVar1 = self->_exportManager;
  }
  return pHVar1;
}

*/
- (id)exportManager
{
    if (_exportManager == nil) {
        _exportManager = [HSExportManager new];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(exportManagerWillStart:) name:HSExportManagerWillStartExportNotification object:_exportManager];
        [center addObserver:self selector:@selector(exportManagerDidEnd:) name:HSExportManagerDidEndExportNotification object:_exportManager];
        [center addObserver:self selector:@selector(exportManagerDidEndPublishing:) name:HSExportManagerDidEndPublishNotification object:_exportManager];
        [center addObserver:self selector:@selector(exportManagerDidEndPublishing:) name:HSExportManagerDidFailNotification object:_exportManager];
    }
    return _exportManager;
}

- (id)purePlayerWindowControllerCreateIfNeeded:(BOOL)aNeeded withPreferencesSettings:(BOOL)aSettings
{
    id pvVar1;
    id *ppvVar2;
    id pvVar1_3;

    if (aSettings == NO) {
        if ((_purePlayerWindowController == nil) && (aNeeded != NO)) {
            pvVar1 = [HSPurePlayerInEditorWindowController new];
            _purePlayerWindowController = pvVar1;
            [pvVar1 setShouldCloseDocument:YES];
            [self addWindowController:_purePlayerWindowController];
        }
        ppvVar2 = &_purePlayerWindowController;
        if ([_presentationWindowController playerSettingsDataSource] != nil) {
            [_presentationWindowController setPlayerSettingsDataSource:nil];
        }
    }
    else {
        if ((_presentationWindowController == nil) && (aNeeded != NO)) {
            pvVar1_3 = [HSPurePlayerInEditorWindowController new];
            _presentationWindowController = pvVar1_3;
            [pvVar1_3 setShouldCloseDocument:YES];
            [self addWindowController:_presentationWindowController];
        }
        ppvVar2 = &_presentationWindowController;
        [*ppvVar2 setPlayerSettingsDataSource:[[[HSPlayerSettingsDataSource alloc] initPreferencesSettingsDataSource] autorelease]];
    }
    return *ppvVar2;
}

- (id)presentationWindowControllerCreateIfNeeded:(BOOL)aNeeded
{
    return [self purePlayerWindowControllerCreateIfNeeded:(unsigned int)aNeeded withPreferencesSettings:YES];
}

- (id)purePlayerWindowControllerCreateIfNeeded:(BOOL)aNeeded
{
    return [self purePlayerWindowControllerCreateIfNeeded:(unsigned int)aNeeded withPreferencesSettings:NO];
}

- (id)storyboardController
{
    HSStoryboardController *pHVar1;
    HSStoryboardController *pHVar1_2;

    pHVar1 = _storyboardController;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSStoryboardController new];
        _storyboardController = pHVar1_2;
        [self addWindowController:pHVar1_2];
        pHVar1 = _storyboardController;
    }
    return pHVar1;
}

- (void)setIsReadyToCreateMinimalWindowApplier
{
    char cVar1;

    cVar1 = _hasPendingRequestToCreateMinimalWindowApplier;
    _hasPendingRequestToCreateMinimalWindowApplier = NO;
    _isReadyToCreateMinimalWindowApplier = YES;
    if (cVar1 != NO) {
        [self minimalWindowApplier];
    }
}

- (id)minimalWindowApplier
{
    HSMinimalWindowApplier *pHVar1;
    id self_00;

    if (_minimalWindowApplier == nil) {
        if (_isReadyToCreateMinimalWindowApplier == NO) {
            _hasPendingRequestToCreateMinimalWindowApplier = YES;
        }
        else {
            if (_modeSwitcher == nil) {
                self_00 = nil;
                pHVar1 = nil;
            }
            else {
                self_00 = [self currentWindowController];
                pHVar1 = [self newMinimalWindowApplierWithWindowController:self_00];
                _minimalWindowApplier = pHVar1;
            }
            if (pHVar1 != nil) {
                [[self editorWindowController] setupMinimalWindowApplier:_minimalWindowApplier];
                if ([self_00 respondsToSelector:@selector(documentDidCreateMinimalWindowApplier)]) {
                    [self_00 documentDidCreateMinimalWindowApplier];
                }
            }
        }
    }
    return _minimalWindowApplier;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00274842 @ 00274842, 264 bytes * /

id FUN_00274842(HSEditorDocument *self,SEL _cmd,id newMinimalWindowApplierWithWindowController)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_supportsMinimalWindowMode);
  if ((((char)pvVar1 != '\0') &&
      (pvVar1 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_window),
      pvVar1 != (id)0x0)) &&
     (pvVar1 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_cardView),
     pvVar1 != (id)0x0)) {
    pvVar1 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_cardView);
    pvVar1 = _objc_msgSend(pvVar1,sel_window);
    pvVar2 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_window);
    if (pvVar1 == pvVar2) {
      pvVar1 = _objc_msgSend(cls_HSMinimalWindowApplier,sel_alloc);
      pvVar2 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_cardView);
      pvVar3 = _objc_msgSend(newMinimalWindowApplierWithWindowController,sel_window);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithWindow_cardView_,pvVar3,pvVar2);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)newMinimalWindowApplierWithWindowController:(id)aController
{
    if ([aController supportsMinimalWindowMode] && [aController window] != nil && [aController cardView] != nil && [[aController cardView] window] == [aController window]) {
        return [[HSMinimalWindowApplier alloc] initWithWindow:[aController window] cardView:[aController cardView]];
    }
    return nil;
}

- (void)addReadyMadeCards:(id)aCards
{
    [[HSEditorController sharedDocumentController] addReadyMadeCards:aCards];
}

- (void)selectInEditorCardViewObjects:(id)aObjects
{
    [[self editorCardView] selectHyperObjects:aObjects];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002749cf @ 002749cf, 458 bytes * /

void FUN_002749cf(HSEditorDocument *self,SEL _cmd,SEL finalizeBitmapToolIfNeededForAction,id to,
                 id from)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_isInStandardMode);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_internalPlayerActive);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  puVar3 = sel_openDrawer_;
  if (pvVar1 != (id)0x12) {
    return;
  }
  if (sel_redo_ == finalizeBitmapToolIfNeededForAction ||
      (sel_undo_ == finalizeBitmapToolIfNeededForAction ||
      (sel_openDrawer_ == finalizeBitmapToolIfNeededForAction ||
      sel_actionToleranceChanged_ == finalizeBitmapToolIfNeededForAction))) {
    if (sel_actionToleranceChanged_ == finalizeBitmapToolIfNeededForAction) {
      pvVar1 = _objc_msgSend(cls_HSPaintBucketSettingsViewController,sel_class);
      pvVar1 = _objc_msgSend(to,sel_isKindOfClass_,pvVar1);
      if ((char)pvVar1 == '\0') goto LAB_00274ae3;
    }
    if (puVar3 != finalizeBitmapToolIfNeededForAction) {
      return;
    }
    pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
    if (pvVar1 == to) {
      return;
    }
  }
LAB_00274ae3:
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar1 = _objc_msgSend(pvVar1,sel_bitmapTool);
  puVar3 = sel_finalize_;
  _objc_msgSend(pvVar1,sel_doCommandBySelector_,sel_finalize_);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(pvVar1,sel_groupsByEvent);
  if (((char)pvVar2 != '\0') &&
     (pvVar2 = _objc_msgSend(pvVar1,sel_groupingLevel,puVar3), pvVar2 == (id)0x1)) {
    _objc_msgSend(pvVar1,sel_NSE_endUndoAutogroup,puVar3);
  }
  return;
}

*/
- (void)finalizeBitmapToolIfNeededForAction:(SEL)aAction to:(id)aTo from:(id)aFrom
{
    if (![self isInStandardMode] || [self internalPlayerActive]) {
        return;
    }
    if ([[HSToolManager sharedToolManager] selectedToolTag] != 0x12) {
        return;
    }
    if (aAction == @selector(redo:) || aAction == @selector(undo:) || aAction == @selector(openDrawer:) || aAction == @selector(actionToleranceChanged:)) {
        BOOL skipChecks = NO;
        if (aAction == @selector(actionToleranceChanged:) && ![aTo isKindOfClass:[HSPaintBucketSettingsViewController class]]) {
            skipChecks = YES;
        }
        if (!skipChecks) {
            if (aAction != @selector(openDrawer:)) {
                return;
            }
            if ([HSToolPaletteController sharedInstance] == aTo) {
                return;
            }
        }
    }
    [[[[HSToolManager sharedToolManager] currentTool] bitmapTool] doCommandBySelector:@selector(finalize:)];
    NSUndoManager *undoManager = [self undoManager];
    if ([undoManager groupsByEvent] && [undoManager groupingLevel] == 1) {
        [undoManager NSE_endUndoAutogroup];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00274b99 @ 00274b99, 128 bytes * /

void FUN_00274b99(HSEditorDocument *self,SEL _cmd,id togglePlayerMode)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode);
  if (((char)pvVar1 == '\0') &&
     ((pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode),
      op = sel_exitPurePlayerModeWithAnimation_, (char)pvVar1 != '\0' ||
      (pvVar1 = _objc_msgSend(self,sel_canTogglePlayEdit),
      op = sel_enterPurePlayerModeWithAnimation_, (char)pvVar1 != '\0')))) {
    _objc_msgSend(self,op,1);
  }
  return;
}

*/
- (void)togglePlayerMode:(id)aMode
{
    if (![self isInPurePlayerMode] && ([self isInPurePlayerMode] || [self canTogglePlayEdit])) {
        if ([self isInPurePlayerMode]) {
            [self exitPurePlayerModeWithAnimation:YES];
        } else {
            [self enterPurePlayerModeWithAnimation:YES];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00274c19 @ 00274c19, 117 bytes * /

void FUN_00274c19(HSEditorDocument *self,SEL _cmd,id togglePresentationMode)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isInPresentationMode);
  op = sel_exitPurePlayerModeWithAnimation_;
  if (((char)pvVar1 != '\0') ||
     (pvVar1 = _objc_msgSend(self,sel_canTogglePlayEdit),
     op = sel_enterPurePlayerModeWithAnimation_withPreferencesSettings_, (char)pvVar1 != '\0')) {
    _objc_msgSend(self,op,1);
  }
  return;
}

*/
- (void)togglePresentationMode:(id)aMode
{
    if ([self isInPresentationMode]) {
        [self exitPurePlayerModeWithAnimation:YES];
    } else if ([self canTogglePlayEdit]) {
        [self enterPurePlayerModeWithAnimation:YES withPreferencesSettings:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00274c8e @ 00274c8e, 542 bytes * /

void FUN_00274c8e(HSEditorDocument *self,SEL _cmd,BOOL exitPurePlayerModeWithAnimation)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  SEL op;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isStackProtected);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode);
    pvVar2 = _objc_msgSend(self,sel_isInPresentationMode);
    pvVar3 = _objc_msgSend(self,sel_modeSwitcher);
    pvVar3 = _objc_msgSend(pvVar3,sel_switching);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self,sel_modeHistory);
      pvVar3 = _objc_msgSend(pvVar3,sel_extraFirstObject);
      self_00 = _objc_msgSend(self,sel_modeSwitcher);
      op = sel_switchWithoutAnimationToModeController_deffered_;
      if (exitPurePlayerModeWithAnimation != '\0') {
        op = sel_switchToModeController_;
      }
      pvVar4 = pvVar3;
      _objc_msgSend(self_00,op,pvVar3);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(self,sel_modeHistory,pvVar4);
        _objc_msgSend(pvVar3,sel_removeAllObjects);
      }
      pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,pvVar4);
      _objc_msgSend(pvVar3,sel_activateIfNeeded);
    }
    if ((char)pvVar2 != '\0' || (char)pvVar1 != '\0') {
      pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
      _objc_msgSend(pvVar3,sel_documentEnteredPurePlayerMode_,0);
    }
    if ((char)pvVar2 == '\0') {
      if ((char)pvVar1 != '\0') {
        _objc_msgSend(self,sel_removeWindowController_,self->_purePlayerWindowController);
        _objc_msgSend(self->_purePlayerWindowController,sel_release);
        self->_purePlayerWindowController = (id)0x0;
      }
    }
    else {
      _objc_msgSend(self,sel_removeWindowController_,self->_presentationWindowController);
      _objc_msgSend(self->_presentationWindowController,sel_release);
      self->_presentationWindowController = (id)0x0;
    }
  }
  return;
}

*/
- (void)exitPurePlayerModeWithAnimation:(BOOL)aAnimation
{
    if (![self isStackProtected]) {
        BOOL inPurePlayer = [self isInPurePlayerMode];
        BOOL inPresentation = [self isInPresentationMode];
        if (![[self modeSwitcher] switching]) {
            id firstMode = [[self modeHistory] extraFirstObject];
            if (aAnimation) {
                [[self modeSwitcher] switchToModeController:firstMode];
            } else {
                [[self modeSwitcher] switchWithoutAnimationToModeController:firstMode deffered:NO];
            }
            if (firstMode != nil) {
                [[self modeHistory] removeAllObjects];
            }
            [[HSObjectAssistantController sharedAssistantController] activateIfNeeded];
        }
        if (inPresentation || inPurePlayer) {
            [[HSEditorController sharedDocumentController] documentEnteredPurePlayerMode:NO];
        }
        if (!inPresentation) {
            if (inPurePlayer) {
                [self removeWindowController:_purePlayerWindowController];
                [_purePlayerWindowController release];
                _purePlayerWindowController = nil;
            }
        } else {
            [self removeWindowController:_presentationWindowController];
            [_presentationWindowController release];
            _presentationWindowController = nil;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00274eac @ 00274eac, 661 bytes * /

void FUN_00274eac(HSEditorDocument *self,SEL _cmd,BOOL enterPurePlayerModeWithAnimation,
                 BOOL withPreferencesSettings)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  uint uVar6;
  SEL op;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  uVar7 = 0;
  _objc_msgSend(pvVar1,sel_setDocumentInEditor_,0);
  pvVar1 = _objc_msgSend(self,sel_isInPresentationMode);
  pvVar2 = _objc_msgSend(self,sel_isInPurePlayerMode);
  if ((char)pvVar2 == '\0' && (char)pvVar1 == '\0') {
    pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,uVar7);
    uVar7 = 1;
    _objc_msgSend(pvVar3,sel_documentEnteredPurePlayerMode_,1);
  }
  pvVar3 = _objc_msgSend(self,sel_modeSwitcher,uVar7);
  pvVar3 = _objc_msgSend(pvVar3,sel_switching);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,uVar7);
    _objc_msgSend(pvVar3,sel_setActive_explicitlyByUser_,0,0);
    pvVar3 = _objc_msgSend(self,sel_editorWindowController);
    _objc_msgSend(pvVar3,sel_saveScrollerPosition);
    uVar6 = (uint)(byte)withPreferencesSettings;
    pvVar3 = _objc_msgSend(self,
                           sel_purePlayerWindowControllerCreateIfNeeded_withPreferencesSettings_,1,
                           uVar6);
    pvVar4 = _objc_msgSend(self,sel_modeHistory);
    pvVar5 = _objc_msgSend(self,sel_modeSwitcher);
    pvVar5 = _objc_msgSend(pvVar5,sel_activeModeController);
    _objc_msgSend(pvVar4,sel_addObject_,pvVar5);
    pvVar4 = _objc_msgSend(self,sel_modeSwitcher);
    op = sel_switchToModeController_;
    if (enterPurePlayerModeWithAnimation == '\0') {
      uVar6 = 0;
      op = sel_switchWithoutAnimationToModeController_deffered_;
    }
    _objc_msgSend(pvVar4,op,pvVar3,uVar6);
    if ((char)pvVar1 == '\0') {
      if ((char)pvVar2 != '\0') {
        _objc_msgSend(self,sel_removeWindowController_,self->_purePlayerWindowController,uVar6);
        _objc_msgSend(self->_purePlayerWindowController,sel_release);
        self->_purePlayerWindowController = (id)0x0;
      }
    }
    else {
      _objc_msgSend(self,sel_removeWindowController_,self->_presentationWindowController,uVar6);
      _objc_msgSend(self->_presentationWindowController,sel_release);
      self->_presentationWindowController = (id)0x0;
    }
  }
  return;
}

*/
- (void)enterPurePlayerModeWithAnimation:(BOOL)aAnimation withPreferencesSettings:(BOOL)aSettings
{
    [[HSEditorController sharedDocumentController] setDocumentInEditor:NO];
    BOOL inPresentation = [self isInPresentationMode];
    BOOL inPurePlayer = [self isInPurePlayerMode];
    if (!inPurePlayer && !inPresentation) {
        [[HSEditorController sharedDocumentController] documentEnteredPurePlayerMode:YES];
    }
    if (![[self modeSwitcher] switching]) {
        [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
        [[self editorWindowController] saveScrollerPosition];
        id purePlayerController = [self purePlayerWindowControllerCreateIfNeeded:YES withPreferencesSettings:aSettings];
        [[self modeHistory] addObject:[[self modeSwitcher] activeModeController]];
        if (aAnimation) {
            [[self modeSwitcher] switchToModeController:purePlayerController];
        } else {
            [[self modeSwitcher] switchWithoutAnimationToModeController:purePlayerController deffered:NO];
        }
        if (!inPresentation) {
            if (inPurePlayer) {
                [self removeWindowController:_purePlayerWindowController];
                [_purePlayerWindowController release];
                _purePlayerWindowController = nil;
            }
        } else {
            [self removeWindowController:_presentationWindowController];
            [_presentationWindowController release];
            _presentationWindowController = nil;
        }
    }
}

- (void)enterPurePlayerModeWithAnimation:(BOOL)aAnimation
{
    [self enterPurePlayerModeWithAnimation:aAnimation withPreferencesSettings:NO];
}

- (void)setStoryboardModeOn:(BOOL)aOn
{
    BOOL pvVar1;

    pvVar1 = [self isInStoryboardMode];
    if (aOn == NO) {
        if (!pvVar1) {
            return;
        }
    }
    if (pvVar1) {
        return;
    }
    [self toggleStoryboard:nil];
}

- (void)exitStoryboardMode:(id)aMode
{
    id pvVar1_3;

    if ([self isInStoryboardMode]) {
        pvVar1_3 = [[self modeHistory] lastObject];
        [[self modeSwitcher] switchToModeController:pvVar1_3];
        [[self modeHistory] removeLastObject];
    }
}

- (void)enterStoryboardMode:(id)aMode
{
    if (![[self modeSwitcher] switching]) {
        if (![self isInStoryboardMode]) {
            if ([self isInPresentationMode]) {
                [self exitPurePlayerModeWithAnimation:YES];
            }
            [[self modeHistory] addObject:[[self modeSwitcher] activeModeController]];
            if ([[self modeSwitcher] activeModeController] == [self playerInEditorWindowController]) {
                [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSounds];
            }
            [[self modeSwitcher] switchToModeController:[self storyboardController]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002753ed @ 002753ed, 199 bytes * /

void FUN_002753ed(HSEditorDocument *self,SEL _cmd,id toggleStoryboard)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_switching);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_isInPresentationMode);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode), (char)pvVar1 != '\0')) {
      _objc_msgSend(self,sel_exitPurePlayerModeWithAnimation_,1);
    }
    pvVar1 = _objc_msgSend(self,sel_isInStoryboardMode);
    op = sel_exitStoryboardMode_;
    if ((char)pvVar1 == '\0') {
      op = sel_enterStoryboardMode_;
    }
    _objc_msgSend(self,op,toggleStoryboard);
  }
  return;
}

*/
- (void)toggleStoryboard:(id)aStoryboard
{
    if (![[self modeSwitcher] switching]) {
        if ([self isInPresentationMode] || [self isInPurePlayerMode]) {
            [self exitPurePlayerModeWithAnimation:YES];
        }
        if ([self isInStoryboardMode]) {
            [self exitStoryboardMode:aStoryboard];
        } else {
            [self enterStoryboardMode:aStoryboard];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002754b4 @ 002754b4, 385 bytes * /

void FUN_002754b4(HSEditorDocument *self,SEL _cmd,id toggleIpadExportPreview)

{
  id pvVar1;
  id self_00;
  SEL op;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_isInIpadExportPreviewMode);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_invalidateIpadStack);
    _objc_msgSend(self,sel_updateIPadStack);
    if (self->_iPadStack == (id)0x0) {
      return;
    }
    if (self->_originalStackStorage != (id)0x0) {
      _objc_msgSend(self->_originalStackStorage,sel_release);
    }
    pvVar1 = _objc_msgSend(self,sel_stack);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_originalStackStorage = pvVar1;
    pvVar1 = self->_iPadStack;
    uVar3 = 0;
    uVar2 = 1;
    op = sel_setStack_notify_clearChanges_;
  }
  else {
    uVar3 = 0;
    uVar2 = 1;
    _objc_msgSend(self,sel_setStack_notify_clearChanges_,self->_originalStackStorage,1,0);
    pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
    self_00 = _objc_msgSend(pvVar1,sel_activeModeController);
    pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
    _objc_msgSend(self_00,sel_didBecomeWorkingInModeSwitcher_,pvVar1);
    _objc_msgSend(self->_originalStackStorage,sel_release);
    self->_originalStackStorage = (id)0x0;
    op = sel_invalidateIPadUndoManager;
  }
  _objc_msgSend(self,op,pvVar1,uVar2,uVar3);
  return;
}

*/
- (id)modeHistory
{
    id pvVar1;

    pvVar1 = _modeHistory;
    if (pvVar1 == nil) {
        [self setModeHistory:[[[NSMutableArray alloc] init] autorelease]];
        pvVar1 = _modeHistory;
    }
    return pvVar1;
}

- (void)setModeHistory:(id)aHistory
{
    if (_modeHistory != aHistory) {
        [_modeHistory autorelease];
        _modeHistory = [aHistory retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027592e @ 0027592e, 779 bytes * /

void FUN_0027592e(HSEditorDocument *self,SEL _cmd,id optimizeAndSaveAs)

{
  undefined *self_00;
  id self_01;
  id pvVar1;
  undefined **ppuVar2;
  SEL op;
  cfstringStruct *pcVar3;
  undefined4 uVar4;
  id pvVar5;
  undefined *local_2c;
  undefined4 local_28;
  undefined4 local_24;
  code *local_20;
  undefined *local_1c;
  id local_18;
  HSEditorDocument *local_14;
  
  self_01 = _objc_msgSend(cls_NSSavePanel,sel_savePanel);
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = (id)0x0;
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Optimize,&cfstr_empty,
                         0);
  _objc_msgSend(self_01,sel_setPrompt_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_fileURL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  pvVar1 = _objc_msgSend(pvVar1,sel_lastPathComponent);
  ppuVar2 = _objc_msgSend(pvVar1,sel_stringByDeletingPathExtension);
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pcVar3 = &cfstr_stack;
    _objc_msgSend(self_01,sel_setRequiredFileType_,&cfstr_stack);
    pvVar1 = _objc_msgSend(self,sel_currentWindowController);
    pvVar5 = _objc_msgSend(pvVar1,sel_window);
    if (ppuVar2 == (undefined **)0x0) {
      ppuVar2 = _objc_msgSend(self,sel_displayName,pcVar3);
    }
    pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperStudioDocumentsFolder);
    op = sel_beginSheetForDirectory_file_modalForWindow_modalDelegate_didEndSelector_contextInfo_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_stack);
    _objc_msgSend(self_01,sel_setAllowedFileTypes_,pvVar1);
    self_00 = cls_NSURL;
    pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperStudioDocumentsFolder);
    uVar4 = 1;
    pvVar1 = _objc_msgSend(self_00,sel_fileURLWithPath_isDirectory_,pvVar1,1);
    _objc_msgSend(self_01,sel_setDirectoryURL_,pvVar1);
    if (ppuVar2 == (undefined **)0x0) {
      ppuVar2 = _objc_msgSend(self,sel_displayName,pvVar1,uVar4);
    }
    _objc_msgSend(self_01,sel_setNameFieldStringValue_,ppuVar2,uVar4);
    local_2c = PTR_003361cc;
    local_28 = 0x42000000;
    local_24 = 0;
    local_20 = FUN_0027cf86;
    local_1c = &DAT_003426f0;
    local_14 = self;
    local_18 = self_01;
    pvVar1 = _objc_msgSend(self,sel_currentWindowController);
    pvVar1 = _objc_msgSend(pvVar1,sel_window);
    ppuVar2 = &local_2c;
    op = sel_beginSheetModalForWindow_completionHandler_;
  }
  _objc_msgSend(self_01,op,pvVar1,ppuVar2,pvVar5);
  return;
}

*/
- (void)optimizeAndSaveAs:(id)aAs
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"Optimize" value:@"" table:nil]];
    NSString *name = [[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"stack"]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder] isDirectory:YES]];
    if (name == nil) {
        name = [self displayName];
    }
    [panel setNameFieldStringValue:name];
    [panel beginSheetModalForWindow:[[self currentWindowController] window] completionHandler:^(NSInteger result) {
        [self optimizeAndSaveAsPanelDidEnd:panel returnCode:result contextInfo:NULL];
    }];
}

- (void)showPalettesAfterExport
{
    if (_palettesToHideInHypercastingMode != nil) {
        [_palettesToHideInHypercastingMode makeObjectsPerformSelector:@selector(showPalette)];
        [_palettesToHideInHypercastingMode release];
        _palettesToHideInHypercastingMode = nil;
    }
}

- (void)hidePalettesBeforeExport
{
    if (_palettesToHideInHypercastingMode == nil) {
        _palettesToHideInHypercastingMode = [[NSMutableArray alloc] init];
    }
    if ([[HSObjectListPaletteController sharedInstance] isPaletteVisible]) {
        [_palettesToHideInHypercastingMode addObject:[HSObjectListPaletteController sharedInstance]];
    }
    if ([[HSLayoutPaletteController sharedInstance] isPaletteVisible]) {
        [_palettesToHideInHypercastingMode addObject:[HSLayoutPaletteController sharedInstance]];
    }
    [_palettesToHideInHypercastingMode makeObjectsPerformSelector:@selector(hidePalette)];
}

- (void)saveDocumentAs:(id)aAs
{
    if (![self isWritingDisabled]) {
        [super saveDocumentAs:aAs];
    }
}

- (void)saveDocument:(id)aDocument
{
    if (![self isWritingDisabled]) {
        [super saveDocument:aDocument];
    }
}

- (void)editStack:(id)aStack
{
    [self switchToEditorWithToolTag:1];
}

- (void)testCard:(id)aCard
{
    [self testCardWithUID:[[self currentCard] hyperUID] animate:YES];
}

- (void)testStack:(id)aStack
{
    [self testCardWithUID:[[[self stack] hyperChildAtIndex:0] hyperUID] animate:YES];
}

- (void)togglePlayEditViaGlobalShortcut:(id)aShortcut
{
    if (![self isStackProtected]) {
        if (![self isInPurePlayerMode]) {
            [self togglePlayEdit:aShortcut];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00275fd7 @ 00275fd7, 212 bytes * /

void FUN_00275fd7(HSEditorDocument *self,SEL _cmd,id togglePlayEdit)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_shouldHandleToolSwitching);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_canTogglePlayEdit), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_internalPlayerActive);
    op = sel_testCard_;
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode);
      if (((char)pvVar1 != '\0') ||
         (pvVar1 = _objc_msgSend(self,sel_isInPresentationMode), (char)pvVar1 != '\0')) {
        _objc_msgSend(self,sel_exitPurePlayerModeWithAnimation_,0);
      }
      togglePlayEdit = (id)0x1;
      op = sel_switchToEditorWithToolTag_;
    }
    _objc_msgSend(self,op,togglePlayEdit);
  }
  return;
}

*/
- (void)togglePlayEdit:(id)aEdit
{
    if ([self shouldHandleToolSwitching] && [self canTogglePlayEdit]) {
        if ([self internalPlayerActive]) {
            if ([self isInPurePlayerMode] || [self isInPresentationMode]) {
                [self exitPurePlayerModeWithAnimation:NO];
            }
            [self switchToEditorWithToolTag:1];
        } else {
            [self testCard:aEdit];
        }
    }
}

- (void)switchToPurePlayerMode:(id)aMode
{
    if (![self isInPurePlayerMode]) {
        [self enterPurePlayerModeWithAnimation:YES withPreferencesSettings:NO];
    }
}

- (void)switchToPresentationMode:(id)aMode
{
    if (![self isInPresentationMode]) {
        [self enterPurePlayerModeWithAnimation:YES withPreferencesSettings:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027614b @ 0027614b, 264 bytes * /

void FUN_0027614b(HSEditorDocument *self,SEL _cmd,id switchToStandardMode)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isInStandardMode);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_isInPresentationMode);
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode), (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(self,sel_isInStoryboardMode);
    op = sel_exitStoryboardMode_;
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_isInIpadExportPreviewMode),
       op = sel_toggleIpadExportPreview_, switchToStandardMode = self, (char)pvVar1 == '\0'))
    goto LAB_0027620f;
  }
  else {
    op = sel_exitPurePlayerModeWithAnimation_;
    switchToStandardMode = (HSEditorDocument *)0x1;
  }
  _objc_msgSend(self,op,switchToStandardMode);
LAB_0027620f:
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar2 = _objc_msgSend(self,sel_editorWindowController);
  _objc_msgSend(pvVar1,sel_switchToModeController_,pvVar2);
  return;
}

*/
- (void)switchToStandardMode:(id)aMode
{
    if ([self isInStandardMode]) {
        return;
    }
    if ([self isInPresentationMode] || [self isInPurePlayerMode]) {
        [self exitPurePlayerModeWithAnimation:YES];
    } else if ([self isInStoryboardMode]) {
        [self exitStoryboardMode:aMode];
    } else if ([self isInIpadExportPreviewMode]) {
        [self toggleIpadExportPreview:self];
    }
    [[self modeSwitcher] switchToModeController:[self editorWindowController]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00276253 @ 00276253, 301 bytes * /

BOOL FUN_00276253(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(self,sel_mainWindowController);
  pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
  pvVar1 = _objc_msgSend(pvVar1,sel_canDeactivate);
  pvVar2 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar2 = _objc_msgSend(pvVar2,sel_switching);
  pvVar3 = _objc_msgSend(self,sel_editorCardView);
  pvVar3 = _objc_msgSend(pvVar3,sel_isOccupiedByTool);
  pvVar4 = _objc_msgSend(self,sel_isInPlayerMode);
  if (((char)pvVar4 == '\0') &&
     (((pvVar4 = _objc_msgSend(self,sel_isInAnimationMode), (char)pvVar4 != '\0' ||
       (pvVar4 = _objc_msgSend(self,sel_isInPurePlayerMode), (char)pvVar4 != '\0')) ||
      (pvVar4 = _objc_msgSend(self,sel_isInStoryboardMode), (char)pvVar4 != '\0')))) {
    pvVar1 = _objc_msgSend(self,sel_modeHistory);
    _objc_msgSend(pvVar1,sel_lastObject);
  }
  else if ((char)pvVar1 != '\0') {
    return (char)pvVar3 == '\0' && (char)pvVar2 == '\0';
  }
  return '\0';
}

*/
- (BOOL)canTogglePlayEdit
{
    BOOL canDeactivate = [[[self mainWindowController] cardView] canDeactivate];
    BOOL switching = [[self modeSwitcher] switching];
    BOOL occupiedByTool = [[self editorCardView] isOccupiedByTool];
    if (![self isInPlayerMode] && ([self isInAnimationMode] || [self isInPurePlayerMode] || [self isInStoryboardMode])) {
        [[self modeHistory] lastObject];
        return NO;
    }
    if (canDeactivate) {
        return !occupiedByTool && !switching;
    }
    return NO;
}

- (BOOL)prepareForHandlingActionThatRequiresConditionalSwitchToEditMode
{
    return (BOOL)[self prepareForActionThatRequiresSwitchToEditMode];
}

- (BOOL)shouldHandleActionThatRequiresConditionalSwitchToEditMode
{
    return ![[self modeSwitcher] switching];
}

- (BOOL)shouldHandleActionThatRequiresImmediateSwitchToEditMode:(BOOL)aMode
{
    return (BOOL)[self prepareForActionThatRequiresSwitchToEditMode:aMode];
}

- (BOOL)shouldHandleActionThatRequiresImmediateSwitchToEditMode
{
    return (BOOL)[self shouldHandleActionThatRequiresImmediateSwitchToEditMode:YES];
}

- (BOOL)prepareForActionThatRequiresSwitchToEditMode
{
    return (BOOL)[self prepareForActionThatRequiresSwitchToEditMode:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027647e @ 0027647e, 227 bytes * /

BOOL FUN_0027647e(HSEditorDocument *self,SEL _cmd,BOOL prepareForActionThatRequiresSwitchToEditMode)

{
  BOOL BVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar2 = _objc_msgSend(pvVar2,sel_switching);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_isInPlayerMode);
    if (((char)pvVar2 == '\0') ||
       (pvVar2 = _objc_msgSend(self,sel_isStackProtected), (char)pvVar2 != '\0')) {
      BVar1 = '\x01';
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_isInPurePlayerMode);
      if (((char)pvVar2 != '\0') ||
         (pvVar2 = _objc_msgSend(self,sel_isInPresentationMode), (char)pvVar2 != '\0')) {
        _objc_msgSend(self,sel_exitPurePlayerModeWithAnimation_,0);
      }
      _objc_msgSend(self,sel_switchToEditor_,(int)prepareForActionThatRequiresSwitchToEditMode);
      BVar1 = '\x01';
    }
  }
  else {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)prepareForActionThatRequiresSwitchToEditMode:(BOOL)aMode
{
    if ([[self modeSwitcher] switching]) {
        return NO;
    }
    if (![self isInPlayerMode] || [self isStackProtected]) {
        return YES;
    }
    if ([self isInPurePlayerMode] || [self isInPresentationMode]) {
        [self exitPurePlayerModeWithAnimation:NO];
    }
    [self switchToEditor:aMode];
    return YES;
}

- (BOOL)shouldHandleToolSwitching
{
    return ![[self modeSwitcher] switching];
}

- (void)stopExport
{
    [[self exportManager] stopExport];
}

- (void)switchToEditor:(BOOL)aEditor
{
    [self switchToEditor:aEditor blockingAnimation:NO];
}

- (void)switchToEditor
{
    [self switchToEditor:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00276641 @ 00276641, 745 bytes * /

void FUN_00276641(HSEditorDocument *self,SEL _cmd,BOOL switchToEditor,BOOL blockingAnimation)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  uVar3 = 1;
  _objc_msgSend(pvVar1,sel_setDocumentInEditor_,1);
  pvVar1 = _objc_msgSend(self,sel_editorWindowController);
  _objc_msgSend(pvVar1,sel_saveScrollerPosition);
  pvVar1 = _objc_msgSend(self,sel_modeHistory);
  _objc_msgSend(pvVar1,sel_removeAllObjects);
  pvVar1 = _objc_msgSend(cls_HSActionMediaPlayer,sel_sharedActionMediaPlayer);
  _objc_msgSend(pvVar1,sel_stopAllSounds);
  pvVar1 = _objc_msgSend(self,sel_navigationController);
  _objc_msgSend(pvVar1,sel_interruptAllNavigationOperations);
  pvVar1 = _objc_msgSend(self,sel_textViewsToResetScrollPosition);
  pvVar2 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    _objc_msgSend(pvVar1,sel_setVerticalScrollPosition_,0);
    uVar3 = 0;
    _objc_msgSend(pvVar1,sel_setHorizontalScrollPosition_,0);
    pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
  }
  pvVar1 = _objc_msgSend(self,sel_textViewsToResetScrollPosition,uVar3);
  _objc_msgSend(pvVar1,sel_removeAllObjects);
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar2 = _objc_msgSend(self,sel_editorWindowController);
  op = sel_switchToModeController_;
  if (blockingAnimation != '\0') {
    op = sel_switchWithBlockingAnimationAnimationToModeController_;
  }
  _objc_msgSend(pvVar1,op,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_navigationController);
  pvVar2 = _objc_msgSend(cls_HSEditorNavigationController,sel_class);
  pvVar1 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
  if ((char)pvVar1 == '\0') {
    pvVar2 = (id)0x0;
    _objc_msgSend(self,sel_setNavigationController_,0);
  }
  if (switchToEditor != '\0') {
    pvVar1 = _objc_msgSend(self,sel_modeSwitcher,pvVar2);
    pvVar2 = _objc_msgSend(pvVar1,sel_previousModeController);
    pvVar2 = _objc_msgSend(pvVar2,sel_modeSwitcherWindowController_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_activeCard);
    if (pvVar2 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_mainWindowController,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
      _objc_msgSend(pvVar1,sel_setCard_,pvVar2);
    }
  }
  return;
}

*/
- (void)switchToEditor:(BOOL)aEditor blockingAnimation:(BOOL)aAnimation
{
    [[HSEditorController sharedDocumentController] setDocumentInEditor:YES];
    [[self editorWindowController] saveScrollerPosition];
    [[self modeHistory] removeAllObjects];
    [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSounds];
    [[self navigationController] interruptAllNavigationOperations];
    NSEnumerator *enumerator = [[self textViewsToResetScrollPosition] objectEnumerator];
    id textView;
    while ((textView = [enumerator nextObject]) != nil) {
        [textView setVerticalScrollPosition:0];
        [textView setHorizontalScrollPosition:0];
    }
    [[self textViewsToResetScrollPosition] removeAllObjects];
    if (aAnimation) {
        [[self modeSwitcher] switchWithBlockingAnimationAnimationToModeController:[self editorWindowController]];
    } else {
        [[self modeSwitcher] switchToModeController:[self editorWindowController]];
    }
    if (![[self navigationController] isKindOfClass:[HSEditorNavigationController class]]) {
        [self setNavigationController:nil];
    }
    if (aEditor) {
        id activeCard = [[[[self modeSwitcher] previousModeController] modeSwitcherWindowController:[self modeSwitcher]] activeCard];
        if (activeCard != nil) {
            [[[self mainWindowController] cardView] setCard:activeCard];
        }
    }
}

- (void)switchToEditorWithToolTag:(NSInteger)aTag
{
    [self switchToEditor];
    [[self editorWindowController] switchToToolWithTag:aTag];
}

- (void)switchToEditorWithTool:(id)aTool
{
    [self switchToEditorWithToolTag:[aTool tag]];
}

- (void)selectAllArea:(id)aArea
{
    [[[self mainWindowController] cardView] setCard:[[[self playerInEditorWindowController] cardView] card]];
    [[self modeHistory] removeAllObjects];
    [self addActionToPerformAfterSwitchToEditMode:@selector(selectAllArea:) sender:aArea handler:[self editorWindowController]];
    [[self modeSwitcher] switchToModeController:[self editorWindowController]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00276ae5 @ 00276ae5, 413 bytes * /

void FUN_00276ae5(HSEditorDocument *self,SEL _cmd,id testCardWithUID,BOOL animate)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  _objc_msgSend(pvVar1,sel_setDocumentInEditor_,0);
  pvVar1 = _objc_msgSend(self,sel_editorWindowController);
  _objc_msgSend(pvVar1,sel_saveScrollerPosition);
  _objc_msgSend(pvVar1,sel_saveEditingState);
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_00336430);
  _objc_msgSend(pvVar1,sel_set);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_childWithUID_,testCardWithUID);
  _objc_msgSend(pvVar1,sel_setCard_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_modeHistory);
  _objc_msgSend(pvVar1,sel_removeAllObjects);
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar2 = _objc_msgSend(self,sel_playerInEditorWindowController);
  op = sel_switchWithoutAnimationToModeController_deffered_;
  if (animate != '\0') {
    op = sel_switchToModeController_;
  }
  _objc_msgSend(pvVar1,op,pvVar2);
  return;
}

*/
- (void)testCardWithUID:(id)aUID animate:(BOOL)aAnimate
{
    [[HSEditorController sharedDocumentController] setDocumentInEditor:NO];
    id editorWindowController = [self editorWindowController];
    [editorWindowController saveScrollerPosition];
    [editorWindowController saveEditingState];
    [[HSCursor cursorNamed:HSDefaultCursor] set];
    [[self cardView] setCard:[[self stack] childWithUID:aUID]];
    [[self modeHistory] removeAllObjects];
    if (aAnimate) {
        [[self modeSwitcher] switchToModeController:[self playerInEditorWindowController]];
    } else {
        [[self modeSwitcher] switchWithoutAnimationToModeController:[self playerInEditorWindowController] deffered:NO];
    }
}

- (BOOL)internalPlayerActive
{
    return (BOOL)[self isInPlayerMode];
}

- (id)modeSwitcher
{
    HSModeSwitcher *self_00;

    if (_modeSwitcher == nil) {
        if ([self mainWindowController] != nil) {
            self_00 = [[HSModeSwitcher alloc] initWithModeController:[self mainWindowController]];
            _modeSwitcher = self_00;
            [self_00 awakeFromInit];
        }
    }
    return _modeSwitcher;
}

- (void)setModeSwitcher:(id)aSwitcher
{
    if (_modeSwitcher != aSwitcher) {
        [_modeSwitcher autorelease];
        _modeSwitcher = [aSwitcher retain];
    }
}

- (id)editObjectDialogContext
{
    HSEditObjectDialogContext *pHVar1;

    pHVar1 = _editObjectDialogContext;
    if (pHVar1 == nil) {
        pHVar1 = [[HSEditObjectDialogContext alloc] initWithEditorDocument:self];
        _editObjectDialogContext = pHVar1;
    }
    return pHVar1;
}

- (id)selectedCards
{
    id pvVar1_2;

    if (![self isInStoryboardMode]) {
        pvVar1_2 = [super selectedCards];
    }
    else {
        pvVar1_2 = [[[self selectionController] selectedHyperObject] allHyperInterfaces];
    }
    return pvVar1_2;
}

- (id)transitionNames
{
    id pvVar1;
    id self_00;
    id self_01;
    NSUInteger pvVar2;
    NSUInteger pvVar4;
    id pvVar3_2;

    pvVar1 = [NSMutableArray array];
    if (((pvVar1 != nil) && (self_00 = [HSTransitionEffectProvider sharedTransitionEffectProvider], self_00 != nil)) && (self_01 = [self_00 transitionEffectNames], self_01 != nil)) {
        pvVar2 = [self_01 count];
        if (pvVar2 != 0) {
            pvVar4 = 0;
            do {
                pvVar3_2 = [self_00 displayNameForTransitionEffectWithName:[self_01 objectAtIndex:pvVar4]];
                if (pvVar3_2 != nil) {
                    [pvVar1 addObject:pvVar3_2];
                }
                pvVar4 = (pvVar4 + 1);
            } while (pvVar4 < pvVar2);
        }
        return [[pvVar1 copy] autorelease];
    }
    return nil;
}

- (void)detachToolView
{
    [[HSToolManager sharedToolManager] setToolView:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00276fca @ 00276fca, 330 bytes * /

void FUN_00276fca(HSEditorDocument *self,SEL _cmd)

{
  bool bVar1;
  bool bVar2;
  id pvVar3;
  HSEditorDocument *pHVar4;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  if (self->_isInDocumentClosing == '\0') {
    self->_isInDocumentClosing = '\x01';
    pHVar4 = self;
    _objc_msgSend(cls_NSObject,sel_cancelPreviousPerformRequestsWithTarget_,self);
    pvVar3 = _objc_msgSend(self,sel_selectionController);
    _objc_msgSend(pvVar3,sel_noteWindowControllerWillClose);
    if (((self->_purePlayerWindowController == (id)0x0) ||
        (pvVar3 = _objc_msgSend(self,sel_currentWindowController,pHVar4),
        pvVar3 != self->_purePlayerWindowController)) ||
       (pvVar3 = _objc_msgSend(self,sel_isInPurePlayerMode,pHVar4), (char)pvVar3 == '\0')) {
      bVar2 = false;
    }
    else {
      bVar2 = true;
    }
    if (((self->_presentationWindowController == (id)0x0) ||
        (pvVar3 = _objc_msgSend(self,sel_currentWindowController),
        pvVar3 != self->_presentationWindowController)) ||
       (pvVar3 = _objc_msgSend(self,sel_isInPresentationMode), (char)pvVar3 == '\0')) {
      bVar1 = false;
    }
    else {
      bVar1 = true;
    }
    if (bVar1 || bVar2) {
      pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
      _objc_msgSend(pvVar3,sel_documentEnteredPurePlayerMode_,0);
    }
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    _objc_msgSendSuper(&local_1c,sel_close);
    self->_isInDocumentClosing = '\0';
    return;
  }
  return;
}

*/
- (void)close
{
    if (!_isInDocumentClosing) {
        _isInDocumentClosing = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [[self selectionController] noteWindowControllerWillClose];
        BOOL pure = (_purePlayerWindowController != nil && [self currentWindowController] == _purePlayerWindowController && [self isInPurePlayerMode]);
        BOOL presentation = (_presentationWindowController != nil && [self currentWindowController] == _presentationWindowController && [self isInPresentationMode]);
        if (presentation || pure) {
            [[HSEditorController sharedDocumentController] documentEnteredPurePlayerMode:NO];
        }
        [super close];
        _isInDocumentClosing = NO;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00277114 @ 00277114, 273 bytes * /

void FUN_00277114(HSEditorDocument *self,SEL _cmd)

{
  HSEditorDocument *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSDocumentStoring_00356420;
  _objc_msgSendSuper(&local_14,sel_removeWindowControllers);
  if (self->_playerInEditorWindowController != (id)0x0) {
    _objc_msgSend(self->_playerInEditorWindowController,sel_setStatusbarController_,0);
    _objc_msgSend(self->_playerInEditorWindowController,sel_setToolbarController_,0);
    _objc_msgSend(self->_playerInEditorWindowController,sel_release);
    self->_playerInEditorWindowController = (id)0x0;
  }
  if (self->_storyboardController != (HSStoryboardController *)0x0) {
    _objc_msgSend(self->_storyboardController,sel_release);
    self->_storyboardController = (HSStoryboardController *)0x0;
  }
  if (self->_minimalWindowApplier != (HSMinimalWindowApplier *)0x0) {
    _objc_msgSend(self->_minimalWindowApplier,sel_release);
    self->_minimalWindowApplier = (HSMinimalWindowApplier *)0x0;
  }
  return;
}

*/
- (void)removeWindowControllers
{
    [super removeWindowControllers];
    if (_playerInEditorWindowController != nil) {
        [_playerInEditorWindowController setStatusbarController:nil];
        [_playerInEditorWindowController setToolbarController:nil];
        [_playerInEditorWindowController release];
        _playerInEditorWindowController = nil;
    }
    if (_animationModeController != nil) {
        [_animationModeController release];
        _animationModeController = nil;
    }
    if (_storyboardController != nil) {
        [_storyboardController release];
        _storyboardController = nil;
    }
    if (_minimalWindowApplier != nil) {
        [_minimalWindowApplier release];
        _minimalWindowApplier = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00277225 @ 00277225, 361 bytes * /

void FUN_00277225(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  self_00 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  local_1c = self;
  local_18 = PTR_s_HSDocumentStoring_00356420;
  _objc_msgSendSuper(&local_1c,sel_createWindowControllers);
  pvVar1 = _objc_msgSend(self_00,sel_sharedPlayerInEditorWindowController);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_playerInEditorWindowController = pvVar1;
    _objc_msgSend(self,sel_addWindowController_,pvVar1);
    _objc_msgSend(self_00,sel_sharedPLayerInEditorWindowControllerHandled);
  }
  pvVar1 = _objc_msgSend(self_00,sel_sharedPurePlayerWindowController);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_purePlayerWindowController = pvVar1;
    _objc_msgSend(self,sel_addWindowController_,pvVar1);
    _objc_msgSend(self_00,sel_sharedPurePlayerWindowControllerHandled);
  }
  pvVar1 = _objc_msgSend(self_00,sel_sharedPresentationWindowController);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_presentationWindowController = pvVar1;
    _objc_msgSend(self,sel_addWindowController_,pvVar1);
    _objc_msgSend(self_00,sel_sharedPresentationWindowControllerHandled);
  }
  _objc_msgSend(self,sel_animationModeController);
  return;
}

*/
- (void)createWindowControllers
{
    HSEditorController *controller = [HSEditorController sharedDocumentController];
    [super createWindowControllers];
    id playerInEditor = [controller sharedPlayerInEditorWindowController];
    if (playerInEditor != nil) {
        _playerInEditorWindowController = [playerInEditor retain];
        [self addWindowController:_playerInEditorWindowController];
        [controller sharedPLayerInEditorWindowControllerHandled];
    }
    id purePlayer = [controller sharedPurePlayerWindowController];
    if (purePlayer != nil) {
        _purePlayerWindowController = [purePlayer retain];
        [self addWindowController:_purePlayerWindowController];
        [controller sharedPurePlayerWindowControllerHandled];
    }
    id presentation = [controller sharedPresentationWindowController];
    if (presentation != nil) {
        _presentationWindowController = [presentation retain];
        [self addWindowController:_presentationWindowController];
        [controller sharedPresentationWindowControllerHandled];
    }
    [self animationModeController];
}

- (void)cleanupWindowControllers
{
    if ([[HSEditorController sharedDocumentController] sharedPlayerInEditorWindowController] == _playerInEditorWindowController) {
        [self removeWindowController:_playerInEditorWindowController];
    }
    [super cleanupWindowControllers];
}

- (void)removeWindowController:(id)aController
{
    if ([self mainWindowController] == aController) {
        [self setModeSwitcher:nil];
    }
    [super removeWindowController:aController];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00277483 @ 00277483, 102 bytes * /

void FUN_00277483(HSEditorDocument *self,SEL _cmd,id document,BOOL didSave,void *contextInfo)

{
  _objc_msgSend(contextInfo,sel_invokeCanCloseCallbackFrom_shouldClose_,self,(uint)(didSave != '\0')
               );
  _objc_msgSend(contextInfo,sel_release);
  return;
}

*/
- (void)document:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo
{
    [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:aSave];
    [(id)aInfo release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002774e9 @ 002774e9, 220 bytes * /

void FUN_002774e9(HSEditorDocument *self,SEL _cmd,id alertCloseStackProtectedDocumentDidEnd,
                 int returnCode,void *contextInfo)

{
  id self_00;
  SEL op;
  HSEditorDocument *pHVar1;
  HSEditorDocument *pHVar2;
  
  self_00 = _objc_msgSend(alertCloseStackProtectedDocumentDidEnd,sel_window);
  _objc_msgSend(self_00,sel_orderOut_,self);
  if (returnCode == 1000) {
    pHVar1 = (HSEditorDocument *)0x1;
    op = sel_runModalSavePanelForSaveOperation_delegate_didSaveSelector_contextInfo_;
    pHVar2 = self;
  }
  else {
    pHVar2 = (HSEditorDocument *)(uint)(returnCode == 0x3ea);
    pHVar1 = self;
    _objc_msgSend(contextInfo,sel_invokeCanCloseCallbackFrom_shouldClose_,self,pHVar2);
    self = contextInfo;
    op = sel_release;
  }
  _objc_msgSend(self,op,pHVar1,pHVar2);
  _objc_msgSend(alertCloseStackProtectedDocumentDidEnd,sel_release);
  return;
}

*/
- (void)alertCloseStackProtectedDocumentDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [[aEnd window] orderOut:self];
    if (aCode == 1000) {
        [self runModalSavePanelForSaveOperation:1 delegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:aInfo];
    } else {
        [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:(aCode == 0x3ea)];
        [(id)aInfo release];
    }
    [aEnd release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002775c5 @ 002775c5, 261 bytes * /

void FUN_002775c5(HSEditorDocument *self,SEL _cmd,id alertCloseHyperCastingModeDidEnd,int returnCode
                 ,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  if (returnCode == 1000) {
    pvVar1 = _objc_msgSend(self,sel_exportManager);
    _objc_msgSend(pvVar1,sel_stopExport);
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    pvVar2 = _objc_msgSend(contextInfo,sel_contextInfo);
    pvVar1 = _objc_msgSend(contextInfo,sel_selector);
    self = _objc_msgSend(contextInfo,sel_delegate);
    _objc_msgSendSuper(&local_1c,sel_canCloseDocumentWithDelegate_shouldCloseSelector_contextInfo_,
                       self,pvVar1,pvVar2);
  }
  else {
    pvVar1 = (id)0x0;
    _objc_msgSend(contextInfo,sel_invokeCanCloseCallbackFrom_shouldClose_,self,0);
  }
  _objc_msgSend(contextInfo,sel_release,self,pvVar1);
  _objc_msgSend(alertCloseHyperCastingModeDidEnd,sel_release);
  return;
}

*/
- (void)alertCloseHyperCastingModeDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [[self exportManager] stopExport];
        [super canCloseDocumentWithDelegate:[(id)aInfo delegate] shouldCloseSelector:[(id)aInfo selector] contextInfo:[(id)aInfo contextInfo]];
    } else {
        [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:NO];
    }
    [(id)aInfo release];
    [aEnd release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002776ca @ 002776ca, 269 bytes * /

void FUN_002776ca(HSEditorDocument *self,SEL _cmd,id alertCloseAnimationModeDidEnd,int returnCode,
                 void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  if (returnCode == 1000) {
    pvVar1 = _objc_msgSend(self,sel_animationModeController);
    _objc_msgSend(pvVar1,sel_finishAndApplyChanges_,0);
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    pvVar2 = _objc_msgSend(contextInfo,sel_contextInfo);
    pvVar1 = _objc_msgSend(contextInfo,sel_selector);
    self = _objc_msgSend(contextInfo,sel_delegate);
    _objc_msgSendSuper(&local_1c,sel_canCloseDocumentWithDelegate_shouldCloseSelector_contextInfo_,
                       self,pvVar1,pvVar2);
  }
  else {
    pvVar1 = (id)0x0;
    _objc_msgSend(contextInfo,sel_invokeCanCloseCallbackFrom_shouldClose_,self,0);
  }
  _objc_msgSend(contextInfo,sel_release,self,pvVar1);
  _objc_msgSend(alertCloseAnimationModeDidEnd,sel_release);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_002777d7 @ 002777d7, 283 bytes * /

void FUN_002777d7(HSEditorDocument *self,SEL _cmd,id alertCloseRecordingMovieOrSoundDidEnd,
                 int returnCode,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  if (returnCode == 1000) {
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar1,sel_setActive_explicitlyByUser_,0,0);
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    pvVar2 = _objc_msgSend(contextInfo,sel_contextInfo);
    pvVar1 = _objc_msgSend(contextInfo,sel_selector);
    self = _objc_msgSend(contextInfo,sel_delegate);
    _objc_msgSendSuper(&local_1c,sel_canCloseDocumentWithDelegate_shouldCloseSelector_contextInfo_,
                       self,pvVar1,pvVar2);
  }
  else {
    pvVar1 = (id)0x0;
    _objc_msgSend(contextInfo,sel_invokeCanCloseCallbackFrom_shouldClose_,self,0);
  }
  _objc_msgSend(contextInfo,sel_release,self,pvVar1);
  _objc_msgSend(alertCloseRecordingMovieOrSoundDidEnd,sel_release);
  return;
}

*/
- (void)alertCloseRecordingMovieOrSoundDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
        [super canCloseDocumentWithDelegate:[(id)aInfo delegate] shouldCloseSelector:[(id)aInfo selector] contextInfo:[(id)aInfo contextInfo]];
    } else {
        [(id)aInfo invokeCanCloseCallbackFrom:self shouldClose:NO];
    }
    [(id)aInfo release];
    [aEnd release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00277979 @ 00277979, 641 bytes * /

void FUN_00277979(HSEditorDocument *self,SEL _cmd,id canCloseDocumentWithDelegate,
                 SEL shouldCloseSelector,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  SEL op;
  undefined *puVar8;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_isInAnimationMode);
  pvVar2 = _objc_msgSend(self,sel_isInHyperCastingMode);
  pvVar3 = _objc_msgSend(self,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_isStackProtected);
  pvVar4 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar4 = _objc_msgSend(pvVar4,sel_isRecordingMovie);
  pvVar5 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar5 = _objc_msgSend(pvVar5,sel_isRecordingSound);
  if (((char)pvVar2 == '\0' && (char)pvVar1 == '\0') &&
     ((((char)pvVar3 == '\0' ||
       (pvVar6 = _objc_msgSend(self,sel_isDocumentEdited), (char)pvVar6 == '\0')) &&
      ((char)pvVar5 == '\0' && (char)pvVar4 == '\0')))) {
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    _objc_msgSendSuper(&local_1c,sel_canCloseDocumentWithDelegate_shouldCloseSelector_contextInfo_,
                       canCloseDocumentWithDelegate,shouldCloseSelector,contextInfo);
  }
  else {
    pvVar6 = _objc_msgSend(cls_HSCanCloseDocumentParametersData,sel_alloc);
    pvVar6 = _objc_msgSend(pvVar6,sel_initWithDelegate_selector_contextInfo_,
                           canCloseDocumentWithDelegate,shouldCloseSelector,contextInfo);
    pvVar7 = _objc_msgSend(self,sel_currentWindowController);
    pvVar7 = _objc_msgSend(pvVar7,sel_window);
    if ((char)pvVar1 == '\0') {
      if ((char)pvVar2 == '\0') {
        op = sel_createCanCloseRecordingMovieAlert;
        if (((char)pvVar4 == '\0') &&
           (op = sel_createCanCloseRecordingSoundAlert, (char)pvVar5 == '\0')) {
          if ((char)pvVar3 == '\0') {
            return;
          }
          pvVar1 = _objc_msgSend(self,sel_newCanCloseProtectedStackAlert,
                                 canCloseDocumentWithDelegate,shouldCloseSelector,contextInfo);
          puVar8 = sel_alertCloseStackProtectedDocumentDidEnd_returnCode_contextInfo_;
        }
        else {
          pvVar1 = _objc_msgSend(self,op,canCloseDocumentWithDelegate,shouldCloseSelector,
                                 contextInfo);
          puVar8 = sel_alertCloseRecordingMovieOrSoundDidEnd_returnCode_contextInfo_;
        }
      }
      else {
        pvVar1 = _objc_msgSend(self,sel_createCanCloseHyperCastingModeAlert,
                               canCloseDocumentWithDelegate,shouldCloseSelector,contextInfo);
        puVar8 = sel_alertCloseHyperCastingModeDidEnd_returnCode_contextInfo_;
      }
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_createCanCloseAnimationModeAlert,canCloseDocumentWithDelegate,
                             shouldCloseSelector,contextInfo);
      puVar8 = sel_alertCloseAnimationModeDidEnd_returnCode_contextInfo_;
    }
    _objc_msgSend(pvVar1,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,
                  pvVar7,self,puVar8,pvVar6);
  }
  return;
}

*/
- (void)canCloseDocumentWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    BOOL inAnimationMode = [self isInAnimationMode];
    BOOL inHyperCastingMode = [self isInHyperCastingMode];
    BOOL stackProtected = [[self stack] isStackProtected];
    BOOL recordingMovie = [[HSObjectAssistantController sharedAssistantController] isRecordingMovie];
    BOOL recordingSound = [[HSObjectAssistantController sharedAssistantController] isRecordingSound];
    if (!inHyperCastingMode && !inAnimationMode && (!stackProtected || ![self isDocumentEdited]) && !recordingSound && !recordingMovie) {
        [super canCloseDocumentWithDelegate:aDelegate shouldCloseSelector:aSelector contextInfo:aInfo];
        return;
    }
    HSCanCloseDocumentParametersData *parameters = [[HSCanCloseDocumentParametersData alloc] initWithDelegate:aDelegate selector:aSelector contextInfo:aInfo];
    id window = [[self currentWindowController] window];
    id alert;
    SEL didEnd;
    if (inAnimationMode) {
        alert = [self createCanCloseAnimationModeAlert];
        didEnd = @selector(alertCloseAnimationModeDidEnd:returnCode:contextInfo:);
    } else if (inHyperCastingMode) {
        alert = [self createCanCloseHyperCastingModeAlert];
        didEnd = @selector(alertCloseHyperCastingModeDidEnd:returnCode:contextInfo:);
    } else if (recordingMovie || recordingSound) {
        alert = recordingMovie ? [self createCanCloseRecordingMovieAlert] : [self createCanCloseRecordingSoundAlert];
        didEnd = @selector(alertCloseRecordingMovieOrSoundDidEnd:returnCode:contextInfo:);
    } else if (stackProtected) {
        alert = [self newCanCloseProtectedStackAlert];
        didEnd = @selector(alertCloseStackProtectedDocumentDidEnd:returnCode:contextInfo:);
    } else {
        return;
    }
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:didEnd contextInfo:parameters];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00277cbc @ 00277cbc, 521 bytes * /

id FUN_00277cbc(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_NavigationSaveDocumentAlertText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_NavigationSaveDocumentAlertInformativeText,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_NavigationSaveDocumentSaveAsButtonTitle,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_NavigationSaveDocumentDontSaveTitle,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  return self_00;
}

*/
- (id)newCanCloseProtectedStackAlert
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentAlertText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentSaveAsButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NavigationSaveDocumentDontSaveTitle" value:@"" table:@"Alerts"]];
    return alert;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00277ec5 @ 00277ec5, 427 bytes * /

id FUN_00277ec5(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHyperCastingModeQuitMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHyperCastingModeQuitInformativeText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHyperCastingModeQuitCloseButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSHyperCastingModeQuitCancelButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  return self_00;
}

*/
- (id)createCanCloseHyperCastingModeAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSHyperCastingModeQuitMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHyperCastingModeQuitInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHyperCastingModeQuitCloseButtonText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHyperCastingModeQuitCancelButtonText" value:@"" table:@"Alerts"]];
    return alert;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00278070 @ 00278070, 427 bytes * /

id FUN_00278070(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingMovieQuitMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingMovieQuitInformativeText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingMovieQuitOKButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingMovieQuitCancelButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  return self_00;
}

*/
- (id)createCanCloseRecordingMovieAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSRecordingMovieQuitMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingMovieQuitInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingMovieQuitOKButtonText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingMovieQuitCancelButtonText" value:@"" table:@"Alerts"]];
    return alert;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027821b @ 0027821b, 427 bytes * /

id FUN_0027821b(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingSoundQuitMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingSoundQuitInformativeText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingSoundQuitOKButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSRecordingSoundQuitCancelButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  return self_00;
}

*/
- (id)createCanCloseRecordingSoundAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:@"HSRecordingSoundQuitMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingSoundQuitInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingSoundQuitOKButtonText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSRecordingSoundQuitCancelButtonText" value:@"" table:@"Alerts"]];
    return alert;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002783c6 @ 002783c6, 427 bytes * /

id FUN_002783c6(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAnimationModeQuitMessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAnimationModeQuitInformativeText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAnimationModeQuitOKButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAnimationModeQuitCancelButtonText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  return self_00;
}

*/
- (void)takeDataFromDocument:(id)aDocument
{
    id pvVar1;

    [super takeDataFromDocument:aDocument];
    pvVar1 = [aDocument modeSwitcher];
    [self setModeSwitcher:pvVar1];
    pvVar1 = [HSEditorDocument class];
    if ([aDocument isKindOfClass:pvVar1]) {
        pvVar1 = [aDocument modeHistory];
        [self setModeHistory:pvVar1];
    }
}

- (void)setPlayerView:(id)aView
{
    if (_playerView != aView) {
        [_playerView release];
        _playerView = [aView retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00278686 @ 00278686, 172 bytes * /

id FUN_00278686(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id *ppvVar2;
  
  if (self->_playerView == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode);
    if ((((char)pvVar1 != '\0') ||
        (pvVar1 = _objc_msgSend(self,sel_isInPresentationMode), (char)pvVar1 != '\0')) ||
       (pvVar1 = self->_playerInEditorWindowController, pvVar1 == (id)0x0)) {
      pvVar1 = _objc_msgSend(self,sel_isInPresentationMode);
      if ((char)pvVar1 == '\0') {
        ppvVar2 = &self->_purePlayerWindowController;
      }
      else {
        ppvVar2 = &self->_presentationWindowController;
      }
      pvVar1 = *ppvVar2;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_playerView);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_playerView = pvVar1;
    return pvVar1;
  }
  return self->_playerView;
}

*/
- (id)playerView
{
    if (_playerView == nil) {
        id controller = _playerInEditorWindowController;
        if ([self isInPurePlayerMode] || [self isInPresentationMode] || controller == nil) {
            controller = [self isInPresentationMode] ? _presentationWindowController : _purePlayerWindowController;
        }
        _playerView = [[controller playerView] retain];
    }
    return _playerView;
}

- (id)editorWindowController
{
    return [self mainWindowController];
}

- (id)editorCardView
{
    return [[self editorWindowController] cardView];
}

- (id)playerCardView
{
    return [[self playerView] cardView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002787cc @ 002787cc, 838 bytes * /

void FUN_002787cc(HSEditorDocument *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSDocumentStoring_00356420;
  _objc_msgSendSuper(&local_1c,sel_makeWindowControllers);
  if (self->_playerInEditorWindowController == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    pvVar2 = _objc_msgSend(pvVar2,sel_sharedPlayerInEditorWindowController);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_playerInEditorWindowController = pvVar2;
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self,sel_addWindowController_,pvVar2);
    }
  }
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  _objc_msgSend(pvVar2,sel_sharedPLayerInEditorWindowControllerHandled);
  if (self->_presentationWindowController == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    pvVar2 = _objc_msgSend(pvVar2,sel_sharedPresentationWindowController);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_presentationWindowController = pvVar2;
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self,sel_addWindowController_,pvVar2);
    }
  }
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  _objc_msgSend(pvVar2,sel_sharedPresentationWindowControllerHandled);
  if (self->_purePlayerWindowController == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    pvVar2 = _objc_msgSend(pvVar2,sel_sharedPurePlayerWindowController);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_purePlayerWindowController = pvVar2;
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self,sel_addWindowController_,pvVar2);
    }
  }
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  _objc_msgSend(pvVar2,sel_sharedPurePlayerWindowControllerHandled);
  _objc_msgSend(self,sel_animationModeController);
  pvVar2 = _objc_msgSend(self,sel_fileURL);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pvVar3 = _objc_msgSend(self,sel_stack);
    pvVar4 = _objc_msgSend(self,sel_stack);
    _objc_msgSend(pvVar2,sel_addObject_forStack_,pvVar4,pvVar3);
    pvVar2 = _objc_msgSend(cls_HSStack,sel_newStackCardSize);
    cVar1 = _NSEqualSizes(pvVar2,extraout_EDX,*(undefined4 *)PTR_0033607c,
                          *(undefined4 *)(PTR_0033607c + 4));
    if (cVar1 == '\0') {
      pvVar2 = _objc_msgSend(cls_HSNewStackCoachingPane,sel_new);
      pvVar3 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
      pvVar4 = _objc_msgSend(self,sel_stack);
      _objc_msgSend(pvVar3,sel_pushAdditionalCoachingPane_forObject_,pvVar2,pvVar4);
      _objc_msgSend(pvVar2,sel_release);
    }
  }
  return;
}

*/
- (void)makeWindowControllers
{
    [super makeWindowControllers];
    if (_playerInEditorWindowController == nil) {
        _playerInEditorWindowController = [[[HSEditorController sharedDocumentController] sharedPlayerInEditorWindowController] retain];
        if (_playerInEditorWindowController != nil) {
            [self addWindowController:_playerInEditorWindowController];
        }
    }
    [[HSEditorController sharedDocumentController] sharedPLayerInEditorWindowControllerHandled];
    if (_presentationWindowController == nil) {
        _presentationWindowController = [[[HSEditorController sharedDocumentController] sharedPresentationWindowController] retain];
        if (_presentationWindowController != nil) {
            [self addWindowController:_presentationWindowController];
        }
    }
    [[HSEditorController sharedDocumentController] sharedPresentationWindowControllerHandled];
    if (_purePlayerWindowController == nil) {
        _purePlayerWindowController = [[[HSEditorController sharedDocumentController] sharedPurePlayerWindowController] retain];
        if (_purePlayerWindowController != nil) {
            [self addWindowController:_purePlayerWindowController];
        }
    }
    [[HSEditorController sharedDocumentController] sharedPurePlayerWindowControllerHandled];
    [self animationModeController];
    if ([self fileURL] == nil) {
        [[HSCoachingHelpManager sharedCoachingHelpManager] addObject:[self stack] forStack:[self stack]];
        if (!NSEqualSizes([HSStack newStackCardSize], NSZeroSize)) {
            HSNewStackCoachingPane *pane = [HSNewStackCoachingPane new];
            [[HSCoachingHelpManager sharedCoachingHelpManager] pushAdditionalCoachingPane:pane forObject:[self stack]];
            [pane release];
        }
    }
}

- (id)hyperScriptableEntityWithScriptName:(id)aName
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [HSUID uidWithScriptValue:aName];
    if (pvVar1 != nil) {
        pvVar1_2 = [[self stack] childInTreeWithUID:pvVar1];
        if (pvVar1_2 != nil) {
            return [pvVar1_2 queryHyperInterface:@protocol(HSScriptableEntity)];
        }
    }
    return nil;
}

- (id)objectInTopLevelHyperScriptableEntitiesAtIndex:(NSUInteger)aIndex
{
    return [[self stack] queryHyperInterface:@protocol(HSScriptableEntity)];
}

- (NSUInteger)countOfTopLevelHyperScriptableEntities
{
    return (unsigned int)([[self stack] queryHyperInterface:@protocol(HSScriptableEntity)] != nil);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00278c2b @ 00278c2b, 420 bytes * /

void FUN_00278c2b(HSEditorDocument *self,SEL _cmd,SEL performActionThatRequiresSwitchToEditMode,
                 id sender)

{
  id pvVar1;
  HSEditorDocument *self_00;
  bool bVar2;
  SEL op;
  SEL pcVar3;
  
  pvVar1 = _objc_msgSend(self,sel_mainWindowController);
  pcVar3 = performActionThatRequiresSwitchToEditMode;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,performActionThatRequiresSwitchToEditMode);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_respondsToSelector_,performActionThatRequiresSwitchToEditMode);
    self_00 = self;
    if ((char)pvVar1 == '\0') {
      self_00 = (HSEditorDocument *)0x0;
    }
  }
  else {
    self_00 = _objc_msgSend(self,sel_mainWindowController,pcVar3);
  }
  pvVar1 = _objc_msgSend(self_00,sel_respondsToSelector_,
                         sel_actionRequiresConditionalPreprocessingBeforeSwitchToEditMode_);
  if ((char)pvVar1 == '\0') {
    bVar2 = false;
  }
  else {
    pvVar1 = _objc_msgSend(self_00,sel_actionRequiresConditionalPreprocessingBeforeSwitchToEditMode_
                           ,performActionThatRequiresSwitchToEditMode);
    bVar2 = (char)pvVar1 == '\0';
  }
  pcVar3 = sel_actionShouldWaitForFinishingSwitchToEditModeBeforeExecution_;
  pvVar1 = _objc_msgSend(self_00,sel_respondsToSelector_,
                         sel_actionShouldWaitForFinishingSwitchToEditModeBeforeExecution_);
  if (((char)pvVar1 == '\0') ||
     (pcVar3 = performActionThatRequiresSwitchToEditMode,
     pvVar1 = _objc_msgSend(self_00,sel_actionShouldWaitForFinishingSwitchToEditModeBeforeExecution_
                            ,performActionThatRequiresSwitchToEditMode), (char)pvVar1 == '\0')) {
    if (((!bVar2) ||
        (pvVar1 = _objc_msgSend(self,sel_shouldHandleActionThatRequiresImmediateSwitchToEditMode,
                                pcVar3), op = sel_performSelector_withObject_, (char)pvVar1 == '\0')
        ) && (pvVar1 = _objc_msgSend(self,
                                     sel_shouldHandleActionThatRequiresConditionalSwitchToEditMode,
                                     pcVar3), op = sel_performSelector_withObject_,
             (char)pvVar1 == '\0')) {
      return;
    }
  }
  else {
    performActionThatRequiresSwitchToEditMode =
         _objc_msgSend(self,sel_addActionToPerformAfterSwitchToEditMode_sender_handler_,
                       performActionThatRequiresSwitchToEditMode,sender,self_00);
    pvVar1 = _objc_msgSend(self,sel_shouldHandleActionThatRequiresImmediateSwitchToEditMode);
    self_00 = self;
    op = sel_removeDelayedInvocationIfExists_;
    if ((char)pvVar1 != '\0') {
      return;
    }
  }
  _objc_msgSend(self_00,op,performActionThatRequiresSwitchToEditMode,sender);
  return;
}

*/
- (void)performActionThatRequiresSwitchToEditMode:(SEL)aMode sender:(id)aSender
{
    id target;
    if ([[self mainWindowController] respondsToSelector:aMode]) {
        target = [self mainWindowController];
    } else {
        target = [self respondsToSelector:aMode] ? self : nil;
    }
    BOOL conditional = NO;
    if ([target respondsToSelector:@selector(actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:)]) {
        conditional = ![target actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:aMode];
    }
    if ([target respondsToSelector:@selector(actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:)] && [target actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:aMode]) {
        id invocation = [self addActionToPerformAfterSwitchToEditMode:aMode sender:aSender handler:target];
        if ([self shouldHandleActionThatRequiresImmediateSwitchToEditMode]) {
            return;
        }
        [self removeDelayedInvocationIfExists:invocation];
        return;
    }
    if (!((conditional && [self shouldHandleActionThatRequiresImmediateSwitchToEditMode]) || [self shouldHandleActionThatRequiresConditionalSwitchToEditMode])) {
        return;
    }
    [target performSelector:aMode withObject:aSender];
}

- (void)didFinishSwitchToEditMode
{
    [[self stack] restoreObjectsVisibility];
    [[self stack] dropMovieObjectsCurrentTime];
    [[self stack] discardTemporaryChildrenOrder];
    [self flushActionsAfterSwitchToEditMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00278e65 @ 00278e65, 235 bytes * /

void FUN_00278e65(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  HSEditorDocument *pHVar2;
  
  pvVar1 = _objc_msgSend(self->_invocationsToPerformAfterSwitchToEditMode,sel_count);
  if (pvVar1 != (id)0x0) {
    pHVar2 = self->_invocationsToPerformAfterSwitchToEditMode;
    pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pHVar2);
    _objc_msgSend(self->_invocationsToPerformAfterSwitchToEditMode,sel_removeAllObjects);
    self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pHVar2 = _objc_msgSend(pvVar1,sel_target,pHVar2);
      if (pHVar2 == (HSEditorDocument *)0x0) {
        pHVar2 = self;
      }
      _objc_msgSend(pvVar1,sel_invokeWithTarget_,pHVar2);
      pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    }
  }
  return;
}

*/
- (void)flushActionsAfterSwitchToEditMode
{
    if ([_invocationsToPerformAfterSwitchToEditMode count] != 0) {
        NSArray *invocations = [NSArray arrayWithArray:_invocationsToPerformAfterSwitchToEditMode];
        [_invocationsToPerformAfterSwitchToEditMode removeAllObjects];
        NSEnumerator *enumerator = [invocations objectEnumerator];
        NSInvocation *invocation;
        while ((invocation = [enumerator nextObject]) != nil) {
            id target = [invocation target];
            if (target == nil) {
                target = self;
            }
            [invocation invokeWithTarget:target];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00278f50 @ 00278f50, 260 bytes * /

id FUN_00278f50(HSEditorDocument *self,SEL _cmd,SEL addActionToPerformAfterSwitchToEditMode,
               id sender,id handler)

{
  id pvVar1;
  id self_00;
  id *ppvVar2;
  undefined4 uVar3;
  id local_14;
  
  local_14 = sender;
  pvVar1 = _objc_msgSend(handler,sel_methodSignatureForSelector_,
                         addActionToPerformAfterSwitchToEditMode);
  pvVar1 = _objc_msgSend(cls_NSInvocation,sel_invocationWithMethodSignature_,pvVar1);
  _objc_msgSend(pvVar1,sel_setSelector_,addActionToPerformAfterSwitchToEditMode);
  if (self != handler) {
    _objc_msgSend(pvVar1,sel_setTarget_,handler);
  }
  ppvVar2 = &local_14;
  uVar3 = 2;
  _objc_msgSend(pvVar1,sel_setArgument_atIndex_,ppvVar2,2);
  _objc_msgSend(pvVar1,sel_retainArguments);
  self_00 = self->_invocationsToPerformAfterSwitchToEditMode;
  if (self_00 == (id)0x0) {
    self_00 = _objc_msgSend(cls_NSMutableArray,sel_new,ppvVar2,uVar3);
    self->_invocationsToPerformAfterSwitchToEditMode = self_00;
  }
  _objc_msgSend(self_00,sel_addObject_,pvVar1,uVar3);
  return pvVar1;
}

*/
- (id)addActionToPerformAfterSwitchToEditMode:(SEL)aMode sender:(id)aSender handler:(id)aHandler
{
    id sender = aSender;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[aHandler methodSignatureForSelector:aMode]];
    [invocation setSelector:aMode];
    if (self != aHandler) {
        [invocation setTarget:aHandler];
    }
    [invocation setArgument:&sender atIndex:2];
    [invocation retainArguments];
    if (_invocationsToPerformAfterSwitchToEditMode == nil) {
        _invocationsToPerformAfterSwitchToEditMode = [NSMutableArray new];
    }
    [_invocationsToPerformAfterSwitchToEditMode addObject:invocation];
    return invocation;
}

- (void)removeDelayedInvocationIfExists:(id)aExists
{
    NSUInteger pvVar1;

    if (_invocationsToPerformAfterSwitchToEditMode != nil) {
        pvVar1 = [_invocationsToPerformAfterSwitchToEditMode indexOfObjectIdenticalTo:aExists];
        if (pvVar1 != NSNotFound) {
            [_invocationsToPerformAfterSwitchToEditMode removeObjectAtIndex:pvVar1];
        }
    }
}

- (BOOL)actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:(SEL)aExecution
{
    return @selector(addReadyMadeCards:) == aExecution;
}

- (BOOL)actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:(SEL)aMode
{
    if (@selector(addGraphic:) != aMode) {
        return @selector(addGraphicObject:) == aMode;
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002790b2 @ 002790b2, 142 bytes * /

BOOL FUN_002790b2(HSEditorDocument *self,SEL _cmd,
                 id validateUserInterfaceItemThatRequiresTogglePlayEditModes)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_isInAnimationMode);
  if (((((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_isInStoryboardMode), (char)pvVar1 == '\0')) &&
      (pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode), (char)pvVar1 == '\0')) &&
     (pvVar1 = _objc_msgSend(self,sel_canTogglePlayEdit), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_isInHyperCastingMode);
    return (char)pvVar1 == '\0';
  }
  return '\0';
}

*/
- (BOOL)validateUserInterfaceItemThatRequiresTogglePlayEditModes:(id)aModes
{
    if ([self isInAnimationMode] || [self isInStoryboardMode] || [self isInPurePlayerMode] || ![self canTogglePlayEdit]) {
        return NO;
    }
    return ![self isInHyperCastingMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00279140 @ 00279140, 222 bytes * /

BOOL FUN_00279140(HSEditorDocument *self,SEL _cmd,
                 id validateUserInterfaceItemThatRequiresSwitchToEditMode)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(self,sel_mainWindowController);
  pvVar3 = _objc_msgSend(validateUserInterfaceItemThatRequiresSwitchToEditMode,sel_action);
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,pvVar3);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(validateUserInterfaceItemThatRequiresSwitchToEditMode,sel_action,pvVar3);
    pvVar2 = _objc_msgSend(self,sel_respondsToSelector_,pvVar2);
    if ((char)pvVar2 == '\0') {
      BVar1 = '\0';
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_validateUserInterfaceItem_,
                             validateUserInterfaceItemThatRequiresSwitchToEditMode);
      BVar1 = (BOOL)pvVar2;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_mainWindowController,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_validateUserInterfaceItem_,
                           validateUserInterfaceItemThatRequiresSwitchToEditMode);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)validateUserInterfaceItemThatRequiresSwitchToEditMode:(id)aMode
{
    if ([[self mainWindowController] respondsToSelector:[aMode action]]) {
        return [[self mainWindowController] validateUserInterfaceItem:aMode];
    }
    if ([self respondsToSelector:[aMode action]]) {
        return [self validateUserInterfaceItem:aMode];
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027921e @ 0027921e, 4018 bytes * /

BOOL FUN_0027921e(HSEditorDocument *self,SEL _cmd,id validateUserInterfaceItem)

{
  bool bVar1;
  byte bVar2;
  byte bVar3;
  byte bVar4;
  byte bVar5;
  char cVar6;
  id pvVar7;
  undefined *puVar8;
  id pvVar9;
  cfstringStruct *pcVar10;
  HSEditorDocument *pHVar11;
  byte bVar12;
  byte bVar14;
  uint uVar13;
  undefined *puVar15;
  undefined4 uVar16;
  SEL pcVar17;
  char local_1d;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSDocumentStoring_00356420;
  pvVar7 = _objc_msgSendSuper(&local_1c,sel_validateUserInterfaceItem_,validateUserInterfaceItem);
  local_1d = (char)pvVar7;
  puVar8 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  pvVar7 = _objc_msgSend(self,sel_isInAnimationMode);
  bVar2 = (byte)pvVar7;
  pvVar7 = _objc_msgSend(self,sel_isInPurePlayerMode);
  bVar12 = (byte)pvVar7;
  pvVar7 = _objc_msgSend(self,sel_isInStoryboardMode);
  bVar3 = (byte)pvVar7;
  uVar13 = (uint)CONCAT11(bVar3,bVar12);
  pvVar7 = _objc_msgSend(self,sel_isInHyperCastingMode);
  bVar4 = (byte)pvVar7;
  pvVar7 = _objc_msgSend(self,sel_isInPresentationMode);
  bVar14 = (byte)pvVar7;
  pvVar7 = _objc_msgSend(self,sel_isInIpadExportPreviewMode);
  bVar5 = (byte)pvVar7;
  puVar15 = sel_setState_;
  if ((puVar8 == sel_togglePresentationMode_) || (puVar8 == sel_switchToPresentationMode_)) {
    pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
    if ((char)pvVar7 != '\0') {
      uVar13 = (uint)CONCAT11(bVar3,bVar14 != 0);
      puVar15 = (undefined *)(uVar13 & 0xff);
      _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar15);
    }
    bVar12 = bVar14;
    if ((char)(uVar13 >> 8) != '\0' || bVar2 != 0) {
      return '\0';
    }
  }
  else {
    if ((puVar8 != sel_togglePlayerMode_) && (puVar8 != sel_switchToPurePlayerMode_)) {
      if (((puVar8 == sel_saveDocument_) || (puVar8 == sel_saveDocumentAs_)) ||
         (puVar8 == sel_optimizeAndSaveAs_)) {
        if (bVar2 != 0) {
          return '\0';
        }
        pvVar7 = _objc_msgSend(self,sel_isWritingDisabled);
        bVar14 = bVar5;
        if ((char)pvVar7 != '\0') {
          return '\0';
        }
      }
      else {
        if (puVar8 != sel_revertDocumentToSaved_) {
          if (((puVar8 == sel_exportTo_) || (puVar8 == sel_exportToHTML5_)) ||
             (puVar8 == sel_exportForiBooksAuthor_)) {
            pvVar7 = _objc_msgSend(self,sel_isWritingDisabled);
            if ((char)pvVar7 != '\0') {
              return '\0';
            }
            if (bVar4 != 0 || bVar2 != 0) {
              return '\0';
            }
            pvVar7 = _objc_msgSend(self,sel_exportManager);
            pvVar7 = _objc_msgSend(pvVar7,sel_isExporting);
            bVar14 = (byte)pvVar7;
LAB_0027961b:
            local_1d = bVar14 == 0;
          }
          else if (puVar8 == sel_togglePlayEdit_) {
            pvVar7 = validateUserInterfaceItem;
            pvVar9 = _objc_msgSend(self,
                                   sel_validateUserInterfaceItemThatRequiresTogglePlayEditModes_,
                                   validateUserInterfaceItem);
            local_1d = (char)pvVar9;
            pvVar9 = _objc_msgSend(self,sel_isInPlayerMode);
            if ((char)pvVar9 == '\0') {
              uVar13 = (uint)CONCAT11(bVar3 | bVar2,bVar12);
              if ((bVar3 | bVar2) != 0) {
                pvVar7 = _objc_msgSend(self,sel_modeHistory,pvVar7);
                pvVar7 = _objc_msgSend(pvVar7,sel_lastObject);
                if (pvVar7 == self->_playerInEditorWindowController) goto LAB_0027966f;
              }
              uVar16 = 0;
            }
            else {
LAB_0027966f:
              bVar12 = (byte)uVar13;
              uVar16 = 1;
            }
            pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
            if ((char)pvVar7 != '\0') {
              _objc_msgSend(validateUserInterfaceItem,sel_setState_,uVar16);
            }
            if (bVar12 != 0) {
              return '\0';
            }
          }
          else {
            if (puVar8 == sel_switchToStandardMode_) {
              pvVar7 = _objc_msgSend(self,sel_isInAnimationMode);
              if (((char)pvVar7 == '\0') &&
                 (pvVar7 = _objc_msgSend(self,sel_isInHyperCastingMode), (char)pvVar7 == '\0')) {
                local_1d = '\x01';
              }
              else {
                local_1d = '\0';
              }
              pvVar7 = _objc_msgSend(self,sel_isInStandardMode);
              pvVar9 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_
                                    );
              if ((char)pvVar9 != '\0') {
                _objc_msgSend(validateUserInterfaceItem,sel_setState_,(uint)((char)pvVar7 != '\0'));
              }
              goto joined_r0x0027a150;
            }
            if ((puVar8 == sel_toggleStoryboard_) || (puVar8 == sel_enterStoryboardMode_)) {
              if ((bVar14 == 0 && bVar12 == 0) && ((bVar2 == 0 && (local_1d != '\0')))) {
                pvVar7 = _objc_msgSend(self,sel_modeSwitcher);
                pvVar7 = _objc_msgSend(pvVar7,sel_switching);
                if ((char)pvVar7 != '\0') goto LAB_0027982a;
                pvVar7 = _objc_msgSend(self,sel_navigationController);
                pvVar7 = _objc_msgSend(pvVar7,sel_currentNavigationOperation);
                if ((pvVar7 != (id)0x0) || (bVar5 != 0 || bVar4 != 0)) goto LAB_0027982a;
                local_1d = '\x01';
              }
              else {
LAB_0027982a:
                local_1d = '\0';
              }
              pvVar7 = _objc_msgSend(cls_NSMenuItem,sel_class);
              pvVar9 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar7);
              if ((char)pvVar9 != '\0') {
                uVar13 = (uint)CONCAT11(bVar3,bVar3 != 0);
                pvVar7 = (id)(uVar13 & 0xff);
                _objc_msgSend(validateUserInterfaceItem,sel_setState_,pvVar7);
              }
              pvVar7 = _objc_msgSend(cls_HSButton,sel_class,pvVar7);
              pvVar9 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar7);
              if ((char)pvVar9 == '\0') {
                pvVar7 = _objc_msgSend(cls_NSButton,sel_class,pvVar7);
                pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar7);
                if ((char)pvVar7 == '\0') goto joined_r0x0027a150;
                pHVar11 = (HSEditorDocument *)cls_NSImage;
                pcVar17 = sel_imageNamed_;
                if ((char)(uVar13 >> 8) == '\0') {
                  pcVar10 = &cfstr_StoryBoardIcon;
                }
                else {
                  pcVar10 = &cfstr_StoryBoard_On;
                }
              }
              else {
                pcVar10 = &cfstr_Storyboard;
                pHVar11 = (HSEditorDocument *)cls_NSImage;
                pcVar17 = sel_imageNamed_;
              }
            }
            else if (puVar8 == sel_toggleCardIndex_) {
              if ((((bVar3 == 0 && bVar12 == 0) && bVar14 == 0) && (bVar2 == 0)) &&
                 (local_1d != '\0')) {
                pvVar7 = _objc_msgSend(self,sel_modeSwitcher);
                pvVar7 = _objc_msgSend(pvVar7,sel_switching);
                if ((char)pvVar7 != '\0') goto LAB_002799de;
                pvVar7 = _objc_msgSend(self,sel_navigationController);
                pvVar7 = _objc_msgSend(pvVar7,sel_currentNavigationOperation);
                if ((pvVar7 != (id)0x0) || (bVar4 != 0)) goto LAB_002799de;
                local_1d = '\x01';
              }
              else {
LAB_002799de:
                local_1d = '\0';
              }
              pvVar7 = _objc_msgSend(cls_NSMenuItem,sel_class);
              pvVar9 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar7);
              if ((char)pvVar9 != '\0') {
                pvVar7 = _objc_msgSend(self,sel_stackView,pvVar7);
                pvVar7 = _objc_msgSend(pvVar7,sel_isStripVisible);
                pvVar7 = (id)(uint)((char)pvVar7 != '\0');
                _objc_msgSend(validateUserInterfaceItem,sel_setState_,pvVar7);
              }
              pvVar7 = _objc_msgSend(cls_NSButton,sel_class,pvVar7);
              pvVar9 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar7);
              if ((char)pvVar9 == '\0') goto joined_r0x0027a150;
              pvVar7 = _objc_msgSend(self,sel_stackView,pvVar7);
              pvVar7 = _objc_msgSend(pvVar7,sel_isStripVisible);
              pHVar11 = (HSEditorDocument *)cls_NSImage;
              pcVar17 = sel_imageNamed_;
              if (((char)pvVar7 == '\0') || (local_1d == '\0')) {
                pcVar10 = &cfstr_CardIndex;
              }
              else {
                pcVar10 = &cfstr_CardIndex_On;
              }
            }
            else {
              if (puVar8 == sel_toggleBottomToolbar_) {
                pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,
                                       sel_setState_);
                if ((char)pvVar7 != '\0') {
                  pvVar7 = _objc_msgSend(self,sel_currentWindowController,puVar15);
                  pvVar7 = _objc_msgSend(pvVar7,sel_isBottomToolbarVisible);
                  _objc_msgSend(validateUserInterfaceItem,sel_setState_,(uint)((char)pvVar7 != '\0')
                               );
                }
                bVar14 = bVar3 | bVar12 | bVar4 | bVar14;
                goto LAB_0027961b;
              }
              if ((puVar8 == sel_newCard_) || (puVar8 == sel_goToCard_)) {
                if (bVar12 == 0 && bVar2 == 0) {
                  pvVar7 = _objc_msgSend(self,sel_editorCardView);
                  pvVar7 = _objc_msgSend(pvVar7,sel_isEditable);
                  if ((char)pvVar7 == '\0') goto LAB_00279be6;
                  pvVar7 = _objc_msgSend(self,sel_navigationController);
                  pvVar7 = _objc_msgSend(pvVar7,sel_currentNavigationOperation);
                  if ((pvVar7 != (id)0x0) || (bVar4 != 0)) goto LAB_00279be6;
                  local_1d = '\x01';
                }
                else {
LAB_00279be6:
                  local_1d = '\0';
                }
                if (puVar8 == sel_newCard_) {
                  local_1d = local_1d != '\0' && bVar14 == 0;
                }
                goto joined_r0x0027a150;
              }
              if (puVar8 == sel_removeCurrentCard_) {
                if ((bVar12 != 0 || bVar2 != 0) || bVar4 != 0) {
                  return '\0';
                }
                pvVar7 = _objc_msgSend(self,sel_selectionController);
                pvVar7 = _objc_msgSend(pvVar7,sel_selectedHyperObject);
                pvVar7 = _objc_msgSend(pvVar7,sel_allHyperInterfaces);
                puVar15 = &DAT_003875bc;
                pvVar7 = _objc_msgSend(pvVar7,sel_queryHyperInterfaceForAllObjects_,&DAT_003875bc);
                pvVar7 = _objc_msgSend(pvVar7,sel_countOfAllHyperInterfaces);
                if ((pvVar7 == (id)0x0) &&
                   (pvVar7 = _objc_msgSend(self,sel_activeCard,puVar15), pvVar7 == (id)0x0)) {
                  return '\0';
                }
                pvVar7 = _objc_msgSend(self,sel_navigationController,puVar15);
                pvVar7 = _objc_msgSend(pvVar7,sel_currentNavigationOperation);
                if (pvVar7 != (id)0x0) {
                  return '\0';
                }
                goto LAB_002793ab;
              }
              if ((((((((puVar8 == sel_goBack_) || (puVar8 == sel_goForward_)) ||
                      (puVar8 == sel_goToNextCard_)) ||
                     ((puVar8 == sel_goToPreviousCard_ ||
                      (puVar8 == sel_goToNextCardWithoutLeaveActions_)))) ||
                    (puVar8 == sel_goToPreviousCardWithoutLeaveActions_)) ||
                   (((puVar8 == sel_goToLastCardWithoutLeaveActions_ ||
                     (puVar8 == sel_goToFirstCardWithoutLeaveActions_)) ||
                    ((puVar8 == sel_goBackWithoutLeaveActions_ ||
                     (((puVar8 == sel_goForwardWithoutLeaveActions_ ||
                       (puVar8 == sel_goToSpecificCardWithoutLeaveActions_)) ||
                      (puVar8 == sel_goToHomeWithoutLeaveActions_)))))))) ||
                  ((puVar8 == sel_goToLastCard_ || (puVar8 == sel_goToFirstCard_)))) ||
                 (puVar8 == sel_goToSpecificCard_)) {
                if ((bVar2 == 0) && (local_1d != '\0')) {
                  pvVar7 = _objc_msgSend(self,sel_currentWindowController);
                  pvVar9 = _objc_msgSend(self,sel_storyboardController);
                  if (pvVar7 == pvVar9) goto LAB_00279da0;
                  local_1d = '\x01';
                }
                else {
LAB_00279da0:
                  local_1d = '\0';
                }
                pvVar7 = _objc_msgSend(self,sel_navigationController);
                pvVar7 = _objc_msgSend(pvVar7,sel_respondsToSelector_,puVar8);
                if ((char)pvVar7 == '\0') goto joined_r0x0027a150;
                if (local_1d == '\0') {
                  return '\0';
                }
                pvVar7 = _objc_msgSend(self,sel_navigationController,puVar8);
LAB_0027a149:
                pvVar7 = _objc_msgSend(pvVar7,sel_validateUserInterfaceItem_,
                                       validateUserInterfaceItem);
                local_1d = (char)pvVar7;
                goto joined_r0x0027a150;
              }
              if ((puVar8 != sel_testStack_) && (puVar8 != sel_testCard_)) {
                if (puVar8 == sel_editStack_) {
                  if (((bVar12 == 0) && (local_1d != '\0')) &&
                     ((bVar3 == 0 && bVar2 == 0) && bVar4 == 0)) {
                    local_1d = '\x01';
                  }
                  else {
                    local_1d = '\0';
                  }
                  pvVar7 = _objc_msgSend(self,sel_internalPlayerActive);
                  if ((char)pvVar7 == '\0') {
                    pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                    pvVar7 = _objc_msgSend(pvVar7,sel_selectedToolTag);
                    if (pvVar7 != (id)0x1) goto LAB_00279f6b;
                    bVar1 = false;
                  }
                  else {
LAB_00279f6b:
                    bVar1 = true;
                  }
                  if (local_1d != '\0') {
                    pcVar10 = _objc_msgSend(cls_NSButtonCell,sel_class);
                    pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pcVar10);
                    if ((char)pvVar7 != '\0') {
                      pHVar11 = self;
                      pcVar17 = sel_editModeSelectedImage;
                      if (bVar1) {
                        pHVar11 = self;
                        pcVar17 = sel_editModeNormalImage;
                      }
                      goto LAB_0027993a;
                    }
                  }
                  goto joined_r0x0027a150;
                }
                if (puVar8 == sel_addReadyMadeCards_) {
                  if ((((bVar12 == 0 && bVar2 == 0) && bVar4 == 0) && bVar14 == 0) && bVar5 == 0) {
                    pvVar7 = _objc_msgSend(self,sel_currentWindowController);
                    pvVar7 = _objc_msgSend(pvVar7,sel_cardView);
                    pvVar7 = _objc_msgSend(pvVar7,sel_isOccupiedByTool);
                    if ((char)pvVar7 != '\0') goto LAB_0027a054;
                  }
                  else {
LAB_0027a054:
                    local_1d = '\0';
                  }
                  pvVar7 = _objc_msgSend(self,sel_currentWindowController);
                  pHVar11 = _objc_msgSend(pvVar7,sel_cardView);
                  puVar15 = sel_isOccupiedByTool;
                  pvVar7 = _objc_msgSend(pHVar11,sel_respondsToSelector_,sel_isOccupiedByTool);
                  if ((char)pvVar7 == '\0') goto joined_r0x0027a150;
                  pcVar17 = sel_isOccupiedByTool;
                  if (local_1d == '\0') {
                    return '\0';
                  }
LAB_0027a0bc:
                  pvVar7 = _objc_msgSend(pHVar11,pcVar17,puVar15);
                  if ((char)pvVar7 != '\0') {
                    return '\0';
                  }
                  goto LAB_002793ab;
                }
                if (puVar8 != sel_liveSlideShow_) {
                  if (puVar8 != sel_toggleIpadExportPreview_) goto joined_r0x0027a150;
                  pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,
                                         sel_setState_);
                  if ((char)pvVar7 != '\0') {
                    puVar15 = (undefined *)(uint)(bVar5 != 0);
                    _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar15);
                  }
                  pHVar11 = self;
                  pcVar17 = sel_isStackProtected;
                  if (((bVar12 != 0 || bVar2 != 0) || bVar3 != 0) || bVar4 != 0) {
                    return '\0';
                  }
                  goto LAB_0027a0bc;
                }
                pvVar9 = _objc_msgSend(self,
                                       sel_validateUserInterfaceItemThatRequiresTogglePlayEditModes_
                                       ,validateUserInterfaceItem);
                pvVar7 = _objc_msgSend(self,sel_playerInEditorWindowController);
                if ((char)pvVar9 == '\0') {
                  return '\0';
                }
                pvVar9 = _objc_msgSend(pvVar7,sel_respondsToSelector_,puVar8);
                if ((char)pvVar9 == '\0') {
                  return '\0';
                }
                goto LAB_0027a149;
              }
              if (((bVar2 == 0) && (local_1d != '\0')) && (bVar4 == 0 && bVar3 == 0)) {
                local_1d = '\x01';
              }
              else {
                local_1d = '\0';
              }
              pvVar7 = _objc_msgSend(self,sel_currentWindowController);
              pvVar7 = _objc_msgSend(pvVar7,sel_cardView);
              puVar15 = sel_isOccupiedByTool;
              pvVar9 = _objc_msgSend(pvVar7,sel_respondsToSelector_,sel_isOccupiedByTool);
              if ((char)pvVar9 == '\0') {
                if (local_1d == '\0') goto joined_r0x0027a150;
              }
              else {
                if (local_1d == '\0') {
                  return '\0';
                }
                pvVar7 = _objc_msgSend(pvVar7,sel_isOccupiedByTool,puVar15);
                if ((char)pvVar7 != '\0') {
                  return '\0';
                }
                local_1d = '\x01';
              }
              pcVar10 = _objc_msgSend(cls_NSButtonCell,sel_class,puVar15);
              pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pcVar10);
              if ((char)pvVar7 == '\0') goto joined_r0x0027a150;
              pvVar7 = _objc_msgSend(self,sel_internalPlayerActive,pcVar10);
              pHVar11 = self;
              pcVar17 = sel_browseModeSelectedImage;
              if ((char)pvVar7 == '\0') {
                pHVar11 = self;
                pcVar17 = sel_browseModeNormalImage;
              }
            }
LAB_0027993a:
            pvVar7 = _objc_msgSend(pHVar11,pcVar17,pcVar10);
            _objc_msgSend(validateUserInterfaceItem,sel_setImage_,pvVar7);
          }
joined_r0x0027a150:
          if (local_1d == '\0') {
            return '\0';
          }
          goto LAB_002793ab;
        }
        pvVar7 = _objc_msgSend(self,sel_currentWindowController);
        pvVar7 = _objc_msgSend(pvVar7,sel_cardView);
        puVar15 = sel_isOccupiedByTool;
        pvVar9 = _objc_msgSend(pvVar7,sel_respondsToSelector_,sel_isOccupiedByTool);
        if ((char)pvVar9 == '\0') {
          cVar6 = '\0';
        }
        else {
          pvVar7 = _objc_msgSend(pvVar7,sel_isOccupiedByTool,puVar15);
          cVar6 = (char)pvVar7;
        }
        if (bVar12 != 0) {
          return '\0';
        }
        if (local_1d == '\0') {
          return '\0';
        }
        if (cVar6 != '\0' || bVar3 != 0) {
          return '\0';
        }
        pvVar7 = _objc_msgSend(self,sel_isDocumentEdited,puVar15);
        if ((char)pvVar7 == '\0') {
          return '\0';
        }
        pvVar7 = _objc_msgSend(self,sel_fileType,puVar15);
        pvVar7 = _objc_msgSend(pvVar7,sel_isEqualToString_,&cfstr_HSDocumentType);
        if ((char)pvVar7 == '\0') {
          return '\0';
        }
      }
      if (bVar14 != 0 || bVar4 != 0) {
        return '\0';
      }
      goto LAB_002793ab;
    }
    pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
    if ((char)pvVar7 != '\0') {
      puVar15 = (undefined *)(uint)(bVar12 != 0);
      _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar15);
    }
    if (bVar3 != 0 || bVar2 != 0) {
      return '\0';
    }
  }
  if ((bVar12 == 0) &&
     (pvVar7 = _objc_msgSend(self,sel_canTogglePlayEdit,puVar15), (char)pvVar7 == '\0')) {
    return '\0';
  }
  if (bVar4 != 0) {
    return '\0';
  }
  pvVar7 = _objc_msgSend(self,sel_isStackProtected,puVar15);
  if (bVar5 != 0 || (char)pvVar7 != '\0') {
    return '\0';
  }
LAB_002793ab:
  pvVar7 = _objc_msgSend(self,sel_validateUserInterfaceItemIfInLockStackMode_,
                         validateUserInterfaceItem);
  if (((char)pvVar7 != '\0') &&
     (pvVar7 = _objc_msgSend(self,sel_validateUserInterfaceItemIfInOccupiedByToolMode_,
                             validateUserInterfaceItem), (char)pvVar7 != '\0')) {
    pvVar7 = _objc_msgSend(self,sel_validateUserInterfaceItemIfInModalSession_,
                           validateUserInterfaceItem);
    return (char)pvVar7 != '\0';
  }
  return '\0';
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL ok = [super validateUserInterfaceItem:aItem];
    SEL action = [aItem action];
    BOOL anim = [self isInAnimationMode];
    BOOL pure = [self isInPurePlayerMode];
    BOOL story = [self isInStoryboardMode];
    BOOL hyper = [self isInHyperCastingMode];
    BOOL pres = [self isInPresentationMode];
    BOOL ipad = [self isInIpadExportPreviewMode];
    id cardView;
    id navigationOperation;
    NSImage *image;
    if (action == @selector(togglePresentationMode:) || action == @selector(switchToPresentationMode:)) {
        pure = (pres != 0);
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:pure];
        }
        if (story || anim) {
            return NO;
        }
        goto togglePlayEditCheck;
    }
    if (action == @selector(togglePlayerMode:) || action == @selector(switchToPurePlayerMode:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:pure != 0];
        }
        if (story || anim) {
            return NO;
        }
        goto togglePlayEditCheck;
    }
    if (action == @selector(saveDocument:) || action == @selector(saveDocumentAs:) || action == @selector(optimizeAndSaveAs:)) {
        if (anim || [self isWritingDisabled] || ipad || hyper) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(revertDocumentToSaved:)) {
        cardView = [[self currentWindowController] cardView];
        BOOL occupied = [cardView respondsToSelector:@selector(isOccupiedByTool)] ? [cardView isOccupiedByTool] : NO;
        if (pure || !ok || occupied || story || ![self isDocumentEdited] || ![[self fileType] isEqualToString:@"HSDocumentType"] || pres || hyper) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(exportTo:) || action == @selector(exportToHTML5:) || action == @selector(exportForiBooksAuthor:)) {
        if ([self isWritingDisabled] || hyper || anim) {
            return NO;
        }
        ok = ![[self exportManager] isExporting];
        goto joined;
    }
    if (action == @selector(togglePlayEdit:)) {
        ok = [self validateUserInterfaceItemThatRequiresTogglePlayEditModes:aItem];
        BOOL playerState = [self isInPlayerMode] || ((story || anim) && [[self modeHistory] lastObject] == _playerInEditorWindowController);
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:playerState];
        }
        if (pure) {
            return NO;
        }
        goto joined;
    }
    if (action == @selector(switchToStandardMode:)) {
        ok = !([self isInAnimationMode] || [self isInHyperCastingMode]);
        BOOL standard = [self isInStandardMode];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:standard != 0];
        }
        goto joined;
    }
    if (action == @selector(toggleStoryboard:) || action == @selector(enterStoryboardMode:)) {
        if (!(pure || pres) && !anim && ok && ![[self modeSwitcher] switching] && [[self navigationController] currentNavigationOperation] == nil && !(ipad || hyper)) {
            ok = YES;
        } else {
            ok = NO;
        }
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:story != 0];
        }
        if ([aItem isKindOfClass:[HSButton class]]) {
            [aItem setImage:[NSImage imageNamed:@"Storyboard"]];
        } else if ([aItem isKindOfClass:[NSButton class]]) {
            [aItem setImage:[NSImage imageNamed:story ? @"StoryBoard_On" : @"StoryBoardIcon"]];
        }
        goto joined;
    }
    if (action == @selector(toggleCardIndex:)) {
        if (!(pure || story || pres) && !anim && ok && ![[self modeSwitcher] switching] && [[self navigationController] currentNavigationOperation] == nil && !hyper) {
            ok = YES;
        } else {
            ok = NO;
        }
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:[[self stackView] isStripVisible] != 0];
        }
        if ([aItem isKindOfClass:[NSButton class]]) {
            [aItem setImage:[NSImage imageNamed:([[self stackView] isStripVisible] && ok) ? @"CardIndex_On" : @"CardIndex"]];
        }
        goto joined;
    }
    if (action == @selector(toggleBottomToolbar:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[self currentWindowController] isBottomToolbarVisible] != 0];
        }
        ok = !(pure || story || hyper || pres);
        goto joined;
    }
    if (action == @selector(newCard:) || action == @selector(goToCard:)) {
        if (!(anim || pure) && [[self editorCardView] isEditable] && [[self navigationController] currentNavigationOperation] == nil && !hyper) {
            ok = YES;
        } else {
            ok = NO;
        }
        if (action == @selector(newCard:)) {
            ok = ok && !pres;
        }
        goto joined;
    }
    if (action == @selector(removeCurrentCard:)) {
        if (anim || pure || hyper) {
            return NO;
        }
        id cards = [[[[self selectionController] selectedHyperObject] allHyperInterfaces] queryHyperInterfaceForAllObjects:@protocol(HSCardAttributes)];
        if ([cards countOfAllHyperInterfaces] == 0 && [self activeCard] == nil) {
            return NO;
        }
        if ([[self navigationController] currentNavigationOperation] != nil) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(goBack:) || action == @selector(goForward:) || action == @selector(goToNextCard:) || action == @selector(goToPreviousCard:) || action == @selector(goToNextCardWithoutLeaveActions:) || action == @selector(goToPreviousCardWithoutLeaveActions:) || action == @selector(goToLastCardWithoutLeaveActions:) || action == @selector(goToFirstCardWithoutLeaveActions:) || action == @selector(goBackWithoutLeaveActions:) || action == @selector(goForwardWithoutLeaveActions:) || action == @selector(goToSpecificCardWithoutLeaveActions:) || action == @selector(goToHomeWithoutLeaveActions:) || action == @selector(goToLastCard:) || action == @selector(goToFirstCard:) || action == @selector(goToSpecificCard:)) {
        if (!anim && ok && [self currentWindowController] != [self storyboardController]) {
            ok = YES;
        } else {
            ok = NO;
        }
        if (![[self navigationController] respondsToSelector:action]) {
            goto joined;
        }
        if (!ok) {
            return NO;
        }
        ok = [[self navigationController] validateUserInterfaceItem:aItem];
        goto joined;
    }
    if (action == @selector(testStack:) || action == @selector(testCard:)) {
        if (!anim && ok && !(story || hyper)) {
            ok = YES;
        } else {
            ok = NO;
        }
        cardView = [[self currentWindowController] cardView];
        if ([cardView respondsToSelector:@selector(isOccupiedByTool)]) {
            if (!ok) {
                return NO;
            }
            if ([cardView isOccupiedByTool]) {
                return NO;
            }
            ok = YES;
        } else if (!ok) {
            goto joined;
        }
        if (![aItem isKindOfClass:[NSButtonCell class]]) {
            goto joined;
        }
        image = [self internalPlayerActive] ? [self browseModeSelectedImage] : [self browseModeNormalImage];
        [aItem setImage:image];
        goto joined;
    }
    if (action == @selector(editStack:)) {
        if (!pure && ok && !(story || anim || hyper)) {
            ok = YES;
        } else {
            ok = NO;
        }
        BOOL notBrowsing;
        if ([self internalPlayerActive]) {
            notBrowsing = YES;
        } else {
            notBrowsing = [[HSToolManager sharedToolManager] selectedToolTag] != 1;
        }
        if (!ok) {
            goto joined;
        }
        if ([aItem isKindOfClass:[NSButtonCell class]]) {
            image = notBrowsing ? [self editModeNormalImage] : [self editModeSelectedImage];
            [aItem setImage:image];
        }
        goto joined;
    }
    if (action == @selector(addReadyMadeCards:)) {
        if (pure || anim || hyper || pres || ipad || [[[self currentWindowController] cardView] isOccupiedByTool]) {
            ok = NO;
        }
        cardView = [[self currentWindowController] cardView];
        if (![cardView respondsToSelector:@selector(isOccupiedByTool)]) {
            goto joined;
        }
        if (!ok) {
            return NO;
        }
        if ([cardView isOccupiedByTool]) {
            return NO;
        }
        goto chain;
    }
    if (action == @selector(liveSlideShow:)) {
        BOOL valid = [self validateUserInterfaceItemThatRequiresTogglePlayEditModes:aItem];
        id playerController = [self playerInEditorWindowController];
        if (!valid) {
            return NO;
        }
        if (![playerController respondsToSelector:action]) {
            return NO;
        }
        ok = [playerController validateUserInterfaceItem:aItem];
        goto joined;
    }
    if (action == @selector(toggleIpadExportPreview:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:ipad != 0];
        }
        if (pure || anim || story || hyper) {
            return NO;
        }
        if ([self isStackProtected]) {
            return NO;
        }
        goto chain;
    }
    goto joined;
togglePlayEditCheck:
    if (!pure && ![self canTogglePlayEdit]) {
        return NO;
    }
    if (hyper) {
        return NO;
    }
    if (ipad || [self isStackProtected]) {
        return NO;
    }
    goto chain;
joined:
    if (!ok) {
        return NO;
    }
chain:
    if (![self validateUserInterfaceItemIfInLockStackMode:aItem]) {
        return NO;
    }
    if (![self validateUserInterfaceItemIfInOccupiedByToolMode:aItem]) {
        return NO;
    }
    return [self validateUserInterfaceItemIfInModalSession:aItem] != 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027a1d0 @ 0027a1d0, 528 bytes * /

BOOL FUN_0027a1d0(HSEditorDocument *self,SEL _cmd,id validateUserInterfaceItemIfInModalSession)

{
  undefined *puVar1;
  id pvVar2;
  bool bVar3;
  
  puVar1 = _objc_msgSend(validateUserInterfaceItemIfInModalSession,sel_action);
  pvVar2 = _objc_msgSend(self,sel_isModalSessionPresent);
  if ((char)pvVar2 == '\0') {
    bVar3 = true;
  }
  else if ((((((puVar1 == sel_togglePresentationMode_) || (puVar1 == sel_togglePlayerMode_)) ||
             (puVar1 == sel_toggleStoryboard_)) ||
            (((puVar1 == sel_enterStoryboardMode_ || (puVar1 == sel_newCard_)) ||
             ((puVar1 == sel_removeCurrentCard_ ||
              ((puVar1 == sel_goToCard_ || (puVar1 == sel_goBack_)))))))) ||
           ((((puVar1 == sel_goForward_ ||
              ((((puVar1 == sel_goToNextCard_ || (puVar1 == sel_goToPreviousCard_)) ||
                (puVar1 == sel_goToNextCardWithoutLeaveActions_)) ||
               ((puVar1 == sel_goToPreviousCardWithoutLeaveActions_ ||
                (puVar1 == sel_goToLastCardWithoutLeaveActions_)))))) ||
             (((puVar1 == sel_goToFirstCardWithoutLeaveActions_ ||
               ((puVar1 == sel_goBackWithoutLeaveActions_ ||
                (puVar1 == sel_goForwardWithoutLeaveActions_)))) ||
              (puVar1 == sel_goToSpecificCardWithoutLeaveActions_)))) ||
            ((((puVar1 == sel_goToHomeWithoutLeaveActions_ || (puVar1 == sel_goToLastCard_)) ||
              (puVar1 == sel_goToFirstCard_)) ||
             ((puVar1 == sel_goToSpecificCard_ || (puVar1 == sel_testStack_)))))))) ||
          ((((puVar1 == sel_testCard_ || ((puVar1 == sel_editStack_ || (puVar1 == sel_goToHome_))))
            || (puVar1 == sel_addReadyMadeCards_)) ||
           ((((puVar1 == sel_togglePlayEdit_ || (puVar1 == sel_revertDocumentToSaved_)) ||
             (puVar1 == sel_saveDocument_)) ||
            (((((puVar1 == sel_saveDocumentAs_ || (puVar1 == sel_optimizeAndSaveAs_)) ||
               ((puVar1 == sel_exportTo_ ||
                ((puVar1 == sel_exportToHTML5_ || (puVar1 == sel_exportForiBooksAuthor_)))))) ||
              (puVar1 == sel_printCard_)) ||
             ((((puVar1 == sel_printDocument_ || (puVar1 == sel_printText_)) ||
               (puVar1 == sel_switchToStandardMode_)) ||
              ((puVar1 == sel_toggleCardIndex_ || (puVar1 == sel_toggleBottomToolbar_)))))))))))) {
    bVar3 = false;
  }
  else {
    bVar3 = puVar1 != sel_toggleIpadExportPreview_;
  }
  return bVar3;
}

*/
- (BOOL)validateUserInterfaceItemIfInModalSession:(id)aSession
{
    SEL action = [aSession action];
    if (![self isModalSessionPresent]) {
        return YES;
    }
    if (action == @selector(togglePresentationMode:) ||
        action == @selector(togglePlayerMode:) ||
        action == @selector(toggleStoryboard:) ||
        action == @selector(enterStoryboardMode:) ||
        action == @selector(newCard:) ||
        action == @selector(removeCurrentCard:) ||
        action == @selector(goToCard:) ||
        action == @selector(goBack:) ||
        action == @selector(goForward:) ||
        action == @selector(goToNextCard:) ||
        action == @selector(goToPreviousCard:) ||
        action == @selector(goToNextCardWithoutLeaveActions:) ||
        action == @selector(goToPreviousCardWithoutLeaveActions:) ||
        action == @selector(goToLastCardWithoutLeaveActions:) ||
        action == @selector(goToFirstCardWithoutLeaveActions:) ||
        action == @selector(goBackWithoutLeaveActions:) ||
        action == @selector(goForwardWithoutLeaveActions:) ||
        action == @selector(goToSpecificCardWithoutLeaveActions:) ||
        action == @selector(goToHomeWithoutLeaveActions:) ||
        action == @selector(goToLastCard:) ||
        action == @selector(goToFirstCard:) ||
        action == @selector(goToSpecificCard:) ||
        action == @selector(testStack:) ||
        action == @selector(testCard:) ||
        action == @selector(editStack:) ||
        action == @selector(goToHome:) ||
        action == @selector(addReadyMadeCards:) ||
        action == @selector(togglePlayEdit:) ||
        action == @selector(revertDocumentToSaved:) ||
        action == @selector(saveDocument:) ||
        action == @selector(saveDocumentAs:) ||
        action == @selector(optimizeAndSaveAs:) ||
        action == @selector(exportTo:) ||
        action == @selector(exportToHTML5:) ||
        action == @selector(exportForiBooksAuthor:) ||
        action == @selector(printCard:) ||
        action == @selector(printDocument:) ||
        action == @selector(printText:) ||
        action == @selector(switchToStandardMode:) ||
        action == @selector(toggleCardIndex:) ||
        action == @selector(toggleBottomToolbar:)) {
        return NO;
    }
    return action != @selector(toggleIpadExportPreview:);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027a3e0 @ 0027a3e0, 240 bytes * /

BOOL FUN_0027a3e0(HSEditorDocument *self,SEL _cmd,id validateUserInterfaceItemIfInLockStackMode)

{
  undefined *puVar1;
  id pvVar2;
  bool bVar3;
  
  puVar1 = _objc_msgSend(validateUserInterfaceItemIfInLockStackMode,sel_action);
  pvVar2 = _objc_msgSend(self,sel_isStackProtected);
  if ((char)pvVar2 == '\0') {
    bVar3 = true;
  }
  else if (((((((puVar1 == sel_toggleStoryboard_) || (puVar1 == sel_enterStoryboardMode_)) ||
              (puVar1 == sel_sendBackward_)) ||
             ((puVar1 == sel_sendToBack_ || (puVar1 == sel_bringForward_)))) ||
            ((puVar1 == sel_bringToFront_ ||
             ((puVar1 == sel_removeCurrentObject_ || (puVar1 == sel_editStack_)))))) ||
           (puVar1 == sel_removeCurrentCard_)) ||
          ((((puVar1 == sel_newCard_ || (puVar1 == sel_testStack_)) || (puVar1 == sel_testCard_)) ||
           (((puVar1 == sel_resizeToFillCard_ || (puVar1 == sel_togglePlayEdit_)) ||
            ((puVar1 == sel_addReadyMadeCards_ ||
             ((puVar1 == sel_switchToStandardMode_ || (puVar1 == sel_resizeToFitCard_)))))))))) {
    bVar3 = false;
  }
  else {
    bVar3 = puVar1 != sel_toggleIpadExportPreview_;
  }
  return bVar3;
}

*/
- (BOOL)validateUserInterfaceItemIfInLockStackMode:(id)aMode
{
    SEL action = [aMode action];
    if (![self isStackProtected]) {
        return YES;
    }
    if (action == @selector(toggleStoryboard:) ||
        action == @selector(enterStoryboardMode:) ||
        action == @selector(sendBackward:) ||
        action == @selector(sendToBack:) ||
        action == @selector(bringForward:) ||
        action == @selector(bringToFront:) ||
        action == @selector(removeCurrentObject:) ||
        action == @selector(editStack:) ||
        action == @selector(removeCurrentCard:) ||
        action == @selector(newCard:) ||
        action == @selector(testStack:) ||
        action == @selector(testCard:) ||
        action == @selector(resizeToFillCard:) ||
        action == @selector(togglePlayEdit:) ||
        action == @selector(addReadyMadeCards:) ||
        action == @selector(switchToStandardMode:) ||
        action == @selector(resizeToFitCard:)) {
        return NO;
    }
    return action != @selector(toggleIpadExportPreview:);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027a4d0 @ 0027a4d0, 481 bytes * /

BOOL FUN_0027a4d0(HSEditorDocument *self,SEL _cmd,id validateUserInterfaceItemIfInOccupiedByToolMode
                 )

{
  id pvVar1;
  undefined *puVar2;
  bool bVar3;
  
  pvVar1 = _objc_msgSend(self,sel_actionExecutionContext);
  pvVar1 = _objc_msgSend(pvVar1,sel_waitingForMouseDownEvent);
  if ((char)pvVar1 == '\0') {
    puVar2 = _objc_msgSend(validateUserInterfaceItemIfInOccupiedByToolMode,sel_action);
    pvVar1 = _objc_msgSend(self,sel_editorCardView);
    pvVar1 = _objc_msgSend(pvVar1,sel_isOccupiedByTool);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_isDocumentClosing), (char)pvVar1 == '\0')) {
      bVar3 = true;
    }
    else if ((((((((puVar2 == sel_toggleStoryboard_) || (puVar2 == sel_enterStoryboardMode_)) ||
                 (puVar2 == sel_goToSpecificCard_)) ||
                (((puVar2 == sel_goBack_ || (puVar2 == sel_goForward_)) ||
                 ((puVar2 == sel_goToNextCard_ ||
                  ((puVar2 == sel_goToPreviousCard_ ||
                   (puVar2 == sel_goToNextCardWithoutLeaveActions_)))))))) ||
               (puVar2 == sel_goToPreviousCardWithoutLeaveActions_)) ||
              (((puVar2 == sel_goToLastCardWithoutLeaveActions_ ||
                (puVar2 == sel_goToFirstCardWithoutLeaveActions_)) ||
               (puVar2 == sel_goBackWithoutLeaveActions_)))) ||
             (((puVar2 == sel_goForwardWithoutLeaveActions_ ||
               (puVar2 == sel_goToSpecificCardWithoutLeaveActions_)) ||
              ((puVar2 == sel_goToLastCard_ ||
               ((puVar2 == sel_goToFirstCard_ || (puVar2 == sel_goToHome_)))))))) ||
            (((puVar2 == sel_goToHomeWithoutLeaveActions_ ||
              (((((puVar2 == sel_sendBackward_ || (puVar2 == sel_sendToBack_)) ||
                 (puVar2 == sel_bringForward_)) ||
                ((puVar2 == sel_bringToFront_ || (puVar2 == sel_removeCurrentObject_)))) ||
               ((puVar2 == sel_editStack_ ||
                ((puVar2 == sel_removeCurrentCard_ || (puVar2 == sel_newCard_)))))))) ||
             ((puVar2 == sel_togglePlayerMode_ ||
              (((puVar2 == sel_togglePresentationMode_ || (puVar2 == sel_switchToPresentationMode_))
               || (puVar2 == sel_switchToPurePlayerMode_)))))))) {
      bVar3 = false;
    }
    else {
      bVar3 = puVar2 != sel_toggleIpadExportPreview_;
    }
  }
  else {
    bVar3 = false;
  }
  return bVar3;
}

*/
- (BOOL)validateUserInterfaceItemIfInOccupiedByToolMode:(id)aMode
{
    if ([[self actionExecutionContext] waitingForMouseDownEvent]) {
        return NO;
    }
    SEL action = [aMode action];
    if (![[self editorCardView] isOccupiedByTool] && ![self isDocumentClosing]) {
        return YES;
    }
    if (action == @selector(toggleStoryboard:) ||
            action == @selector(enterStoryboardMode:) ||
            action == @selector(goToSpecificCard:) ||
            action == @selector(goBack:) ||
            action == @selector(goForward:) ||
            action == @selector(goToNextCard:) ||
            action == @selector(goToPreviousCard:) ||
            action == @selector(goToNextCardWithoutLeaveActions:) ||
            action == @selector(goToPreviousCardWithoutLeaveActions:) ||
            action == @selector(goToLastCardWithoutLeaveActions:) ||
            action == @selector(goToFirstCardWithoutLeaveActions:) ||
            action == @selector(goBackWithoutLeaveActions:) ||
            action == @selector(goForwardWithoutLeaveActions:) ||
            action == @selector(goToSpecificCardWithoutLeaveActions:) ||
            action == @selector(goToLastCard:) ||
            action == @selector(goToFirstCard:) ||
            action == @selector(goToHome:) ||
            action == @selector(goToHomeWithoutLeaveActions:) ||
            action == @selector(sendBackward:) ||
            action == @selector(sendToBack:) ||
            action == @selector(bringForward:) ||
            action == @selector(bringToFront:) ||
            action == @selector(removeCurrentObject:) ||
            action == @selector(editStack:) ||
            action == @selector(removeCurrentCard:) ||
            action == @selector(newCard:) ||
            action == @selector(togglePlayerMode:) ||
            action == @selector(togglePresentationMode:) ||
            action == @selector(switchToPresentationMode:) ||
            action == @selector(switchToPurePlayerMode:)) {
        return NO;
    }
    return action != @selector(toggleIpadExportPreview:);
}

- (void)setHyperRemovedItemsPaths:(id)aPaths
{
    if (_hyperRemovedItemsPaths != aPaths) {
        [_hyperRemovedItemsPaths release];
        _hyperRemovedItemsPaths = [aPaths retain];
    }
}

- (id)hyperRemovedItemsPaths
{
    return _hyperRemovedItemsPaths;
}

- (void)setHyperSaveOperation:(NSUInteger)aOperation
{
    _hyperSaveOperation = (short)aOperation;
}

- (NSUInteger)hyperSaveOperation
{
    return _hyperSaveOperation;
}

- (void)setHyperClient:(BOOL)aClient
{
    if (_isHyperClient != aClient) {
        _isHyperClient = aClient;
    }
}

- (BOOL)isHyperClient
{
    return _isHyperClient;
}

- (void)setHyperServer:(BOOL)aServer
{
    if (_isHyperServer != aServer) {
        _isHyperServer = aServer;
    }
}

- (BOOL)isHyperServer
{
    return _isHyperServer;
}

- (void)setHyperCollaborative:(BOOL)aCollaborative
{
    _isHyperCollaborative = aCollaborative;
}

- (BOOL)isHyperCollaborative
{
    return _isHyperCollaborative;
}

- (void)setReceived:(BOOL)aReceived
{
    if (_isReceived != aReceived) {
        _isReceived = aReceived;
    }
}

- (BOOL)isReceived
{
    return _isReceived;
}

- (void)setCommitLogMessage:(id)aMessage
{
    if (_commitLogMessage != aMessage) {
        [_commitLogMessage release];
        _commitLogMessage = [aMessage retain];
    }
}

- (id)commitLogMessage
{
    return _commitLogMessage;
}

- (void)setDocumentSharingController:(id)aController
{
    if (_documentSharingController != aController) {
        [_documentSharingController release];
        _documentSharingController = [aController retain];
    }
}

- (id)documentSharingController
{
    return _documentSharingController;
}

- (void)textViewWillBeginScrolling:(id)aScrolling
{
    if ([self isInPlayerMode]) {
        [[self textViewsToResetScrollPosition] addObject:[aScrolling object]];
    }
}

- (id)textViewsToResetScrollPosition
{
    id pvVar1;

    pvVar1 = _textViewsToResetScrollPosition;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableSet new];
        _textViewsToResetScrollPosition = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027a851 @ 0027a851, 169 bytes * /

void FUN_0027a851(HSEditorDocument *self,SEL _cmd,id backgroundDidChange)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  HSEditorDocument *pHVar3;
  
  pvVar1 = _objc_msgSend(self,sel_windowControllers);
  self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  pHVar3 = (HSEditorDocument *)sel_documentBackgroundPatternDidChange_;
  while (pvVar1 != (id)0x0) {
    sel_documentBackgroundPatternDidChange_ = pHVar3->super_HSDocumentStoring;
    pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,pHVar3);
    if ((char)pvVar2 != '\0') {
      pHVar3 = self;
      _objc_msgSend(pvVar1,sel_documentBackgroundPatternDidChange_,self);
    }
    pvVar1 = _objc_msgSend(self_00,sel_nextObject,pHVar3);
    pHVar3 = (HSEditorDocument *)sel_documentBackgroundPatternDidChange_;
  }
  sel_documentBackgroundPatternDidChange_ = pHVar3->super_HSDocumentStoring;
  return;
}

*/
- (void)backgroundDidChange:(id)aChange
{
    NSEnumerator *enumerator = [[self windowControllers] objectEnumerator];
    id controller;
    while ((controller = [enumerator nextObject]) != nil) {
        if ([controller respondsToSelector:@selector(documentBackgroundPatternDidChange:)]) {
            [controller documentBackgroundPatternDidChange:self];
        }
    }
}

- (id)windowForSheet
{
    return [[self modeSwitcher] mainWindow];
}

- (id)stackView
{
    return [[self editorWindowController] stackView];
}

- (void)cardView:(id)aView inWindowController:(id)aController didSetCard:(id)aCard
{
    if ([self cardViewForNavigation] == aView) {
        [[self mainWindowController] activeCardViewDidSetCard:aCard];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSObjectListDataProviderDidChangeTopLevelParentNotification" object:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027aa02 @ 0027aa02, 351 bytes * /

id FUN_0027aa02(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined *puVar3;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_activeModeController);
  puVar3 = sel_cardView;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_cardView);
  if ((char)pvVar1 == '\0') {
    local_14 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_modeSwitcher,puVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_activeModeController);
    local_14 = _objc_msgSend(pvVar1,sel_cardView);
    if (local_14 != (id)0x0) goto LAB_0027ab27;
  }
  pvVar1 = _objc_msgSend(self,sel_modeHistory,puVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while ((self_00 = _objc_msgSend(pvVar1,sel_nextObject,puVar3), self_00 != (id)0x0 &&
         (local_14 == (id)0x0))) {
    puVar3 = sel_cardView;
    pvVar2 = _objc_msgSend(self_00,sel_respondsToSelector_,sel_cardView);
    if ((char)pvVar2 != '\0') {
      local_14 = _objc_msgSend(self_00,sel_cardView,puVar3);
    }
  }
LAB_0027ab27:
  if (local_14 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_mainWindowController,puVar3);
    local_14 = _objc_msgSend(pvVar1,sel_cardView);
  }
  return local_14;
}

*/
- (id)cardViewForNavigation
{
    id cardView = nil;
    id activeController = [[self modeSwitcher] activeModeController];
    if ([activeController respondsToSelector:@selector(cardView)]) {
        cardView = [[[self modeSwitcher] activeModeController] cardView];
    }
    if (cardView == nil) {
        NSEnumerator *enumerator = [[self modeHistory] objectEnumerator];
        id controller;
        while ((controller = [enumerator nextObject]) != nil && cardView == nil) {
            if ([controller respondsToSelector:@selector(cardView)]) {
                cardView = [controller cardView];
            }
        }
    }
    if (cardView == nil) {
        cardView = [[self mainWindowController] cardView];
    }
    return cardView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027ab61 @ 0027ab61, 363 bytes * /

id FUN_0027ab61(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_activeModeController);
  puVar4 = sel_cardView;
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_cardView);
  if ((char)pvVar2 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_cardView,puVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_card);
    if (pvVar1 != (id)0x0) goto LAB_0027ac87;
  }
  pvVar2 = _objc_msgSend(self,sel_modeSwitcher,puVar4);
  pvVar2 = _objc_msgSend(pvVar2,sel_switching);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_modeSwitcher,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_previousModeController);
    puVar4 = sel_cardView;
    pvVar3 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_cardView);
    if ((char)pvVar3 != '\0') {
      pvVar1 = _objc_msgSend(pvVar2,sel_cardView,puVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_card);
    }
  }
LAB_0027ac87:
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_mainWindowController,puVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
    pvVar1 = _objc_msgSend(pvVar1,sel_card);
  }
  return pvVar1;
}

*/
- (id)currentCard
{
    id card = nil;
    id activeController = [[self modeSwitcher] activeModeController];
    if ([activeController respondsToSelector:@selector(cardView)]) {
        card = [[activeController cardView] card];
    }
    if (card == nil) {
        if ([[self modeSwitcher] switching]) {
            id previousController = [[self modeSwitcher] previousModeController];
            if ([previousController respondsToSelector:@selector(cardView)]) {
                card = [[previousController cardView] card];
            }
        }
    }
    if (card == nil) {
        card = [[[self mainWindowController] cardView] card];
    }
    return card;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027accc @ 0027accc, 250 bytes * /

id FUN_0027accc(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_modeSwitcher);
  pvVar1 = _objc_msgSend(pvVar1,sel_activeModeController);
  puVar4 = sel_cardView;
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_cardView);
  if ((char)pvVar2 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_cardView,puVar4);
    if (pvVar1 != (id)0x0) goto LAB_0027ad93;
  }
  pvVar2 = _objc_msgSend(self->_modeSwitcher,sel_previousModeController,puVar4);
  puVar4 = sel_cardView;
  pvVar3 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_cardView);
  if ((char)pvVar3 != '\0') {
    pvVar1 = _objc_msgSend(pvVar2,sel_cardView,puVar4);
  }
LAB_0027ad93:
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_mainWindowController,puVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
  }
  return pvVar1;
}

*/
- (id)cardView
{
    id activeController = [[self modeSwitcher] activeModeController];
    id cardView = nil;
    if ([activeController respondsToSelector:@selector(cardView)]) {
        cardView = [activeController cardView];
    }
    if (cardView == nil) {
        id previousController = [_modeSwitcher previousModeController];
        if ([previousController respondsToSelector:@selector(cardView)]) {
            cardView = [previousController cardView];
        }
    }
    if (cardView == nil) {
        cardView = [[self mainWindowController] cardView];
    }
    return cardView;
}

- (Class)navigationControllerClass
{
    return [HSEditorNavigationController class];
}

- (void)setOpenWarning:(id)aWarning
{
    if (_openWarning != aWarning) {
        [_openWarning release];
        _openWarning = [aWarning retain];
    }
}

- (id)openWarning
{
    return _openWarning;
}

- (id)editModeNormalImage
{
    if (sDAT_00342a50 == nil) {
        sDAT_00342a50 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Edit_Mode_Normal"]];
    }
    return sDAT_00342a50;
}

- (id)editModeSelectedImage
{
    if (sDAT_00342a4c == nil) {
        sDAT_00342a4c = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Edit_Mode_Selected"]];
    }
    return sDAT_00342a4c;
}

- (id)browseModeSelectedImage
{
    if (sDAT_00342a48 == nil) {
        sDAT_00342a48 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Browse_Mode_Selected"]];
    }
    return sDAT_00342a48;
}

- (id)browseModeNormalImage
{
    if (sDAT_00342a44 == nil) {
        sDAT_00342a44 = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"Browse_Mode_Normal"]];
    }
    return sDAT_00342a44;
}

- (BOOL)hasUnautosavedChanges
{
    unsigned char bVar1;

    if (![super hasUnautosavedChanges]) {
        bVar1 = _wasOptimizedAndNotSaved & 1;
    }
    else {
        bVar1 = 1;
    }
    return bVar1;
}

- (BOOL)isDocumentEdited
{
    BOOL bVar3;
    BOOL pvVar1_2;

    pvVar1_2 = [[HSObjectAssistantController sharedAssistantController] isRecordingSound];
    if (![super isDocumentEdited]) {
        bVar3 = (_wasOptimizedAndNotSaved & 1) != 0 || pvVar1_2;
    }
    else {
        bVar3 = YES;
    }
    return bVar3;
}

- (id)createDefaultStack
{
    id self_00;

    self_00 = [super createDefaultStack];
    [self_00 setBackgroundGraphics:[[HSUI sharedUI] backgroundGraphics]];
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027b163 @ 0027b163, 452 bytes * /

void FUN_0027b163(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  HSEditorDocument **super;
  HSEditorDocument *local_1c;
  undefined *local_18;
  HSEditorDocument *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_replacingDocument);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_fileURL);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldBeDocumentOpenedInEditorMode);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_isStackProtected);
      if ((char)pvVar1 != '\0') goto LAB_0027b277;
      pvVar1 = _objc_msgSend(self,sel_currentCard);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
      _objc_msgSend(self,sel_testCardWithUID_animate_,pvVar1,0);
      local_14 = self;
      local_10 = PTR_s_HSDocumentStoring_00356420;
      super = &local_14;
      goto LAB_0027b263;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_isStackProtected);
  if ((char)pvVar1 != '\0') {
LAB_0027b277:
    _objc_msgSend(self,sel_enterPurePlayerModeWithAnimation_,0);
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  _objc_msgSend(pvVar1,sel_setDocumentInEditor_,1);
  pvVar1 = _objc_msgSend(self,sel_stackSelectionHolder);
  _objc_msgSend(pvVar1,sel_makeCurrent);
  local_18 = PTR_s_HSDocumentStoring_00356420;
  super = &local_1c;
  local_1c = self;
LAB_0027b263:
  _objc_msgSendSuper(super,sel_showWindows);
  return;
}

*/
- (void)showWindows
{
    if ([[HSEditorController sharedDocumentController] replacingDocument]) {
        return;
    }
    if ([self fileURL] != nil && ![[HSEditorController sharedDocumentController] shouldBeDocumentOpenedInEditorMode]) {
        if ([self isStackProtected]) {
            [self enterPurePlayerModeWithAnimation:NO];
            return;
        }
        [self testCardWithUID:[[self currentCard] hyperUID] animate:NO];
    }
    if ([self isStackProtected]) {
        [self enterPurePlayerModeWithAnimation:NO];
        return;
    }
    [[HSEditorController sharedDocumentController] setDocumentInEditor:YES];
    [[self stackSelectionHolder] makeCurrent];
    [super showWindows];
}

- (void)saveDocumentWithDelegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [NSApp sendAction:@selector(finalize:) to:0 from:self];
    [super saveDocumentWithDelegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
}

- (void)autosaveDocumentWithDelegate:(id)aDelegate didAutosaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if ([NSView BT_mouseTrackingView] == nil) {
        if (![self isInHyperCastingMode]) {
            if (![self isInIpadExportPreviewMode]) {
                _autosaveUndoManager = [[NSUndoManager alloc] init];
                [NSApp sendAction:@selector(stamp:) to:0 from:self];
                [super autosaveDocumentWithDelegate:aDelegate didAutosaveSelector:aSelector contextInfo:aInfo];
                [_autosaveUndoManager undo];
                [_autosaveUndoManager release];
                _autosaveUndoManager = nil;
            }
        }
    }
}

- (BOOL)isAutosaving
{
    return _autosaveUndoManager != nil;
}

- (id)undoManager
{
    id pvVar1_2;

    if (![self isInIpadExportPreviewMode]) {
        pvVar1_2 = _autosaveUndoManager;
        if (pvVar1_2 == nil) {
            pvVar1_2 = [super undoManager];
        }
    }
    else {
        pvVar1_2 = [self iPadUndoManager];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027b5c4 @ 0027b5c4, 469 bytes * /

void FUN_0027b5c4(HSEditorDocument *self,SEL _cmd,id optimizeAndSaveAsPanelDidEnd,int returnCode,
                 void *contextInfo)

{
  id self_00;
  id pvVar1;
  id self_01;
  SEL op;
  cfstringStruct *pcVar2;
  undefined4 uVar3;
  undefined *puVar4;
  undefined4 uVar5;
  
  _objc_msgSend(optimizeAndSaveAsPanelDidEnd,sel_orderOut_,self);
  if (returnCode == 1) {
    _objc_msgSend(self,sel_setShouldStoreCardPreviewImages_,0);
    self_00 = _objc_msgSend(cls_HSStackOptimizer,sel_new);
    pvVar1 = _objc_msgSend(self,sel_stack);
    _objc_msgSend(self_00,sel_optimizeStack_,pvVar1);
    *(byte *)&self->_wasOptimizedAndNotSaved = (byte)self->_wasOptimizedAndNotSaved | 1;
    pvVar1 = _objc_msgSend(self,sel_undoManager);
    _objc_msgSend(pvVar1,sel_removeAllActions);
    _objc_msgSend(self,sel_updateChangeCount_,2);
    puVar4 = sel_optimizedDocument_didSave_contextInfo_;
    pvVar1 = _objc_msgSend(optimizeAndSaveAsPanelDidEnd,sel_URL);
    pcVar2 = &cfstr_HSDocumentType;
    uVar5 = 0;
    uVar3 = 1;
    _objc_msgSend(self,sel_saveToURL_ofType_forSaveOperation_delegate_didSaveSelector_contextInfo_,
                  pvVar1,&cfstr_HSDocumentType,1,self,puVar4,0);
    op = sel_directory;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      optimizeAndSaveAsPanelDidEnd =
           _objc_msgSend(optimizeAndSaveAsPanelDidEnd,sel_directoryURL,pvVar1,pcVar2,uVar3,self,
                         puVar4,uVar5);
      op = sel_path;
    }
    pvVar1 = _objc_msgSend(optimizeAndSaveAsPanelDidEnd,op,pvVar1,pcVar2,uVar3,self,puVar4,uVar5);
    self_01 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    _objc_msgSend(self_01,sel_setHyperStudioDocumentsFolder_,pvVar1);
    _objc_msgSend(self_00,sel_postprocessAfterOptimization);
    _objc_msgSend(self_00,sel_release);
  }
  return;
}

*/
- (void)optimizeAndSaveAsPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd orderOut:self];
    if (aCode == 1) {
        [self setShouldStoreCardPreviewImages:NO];
        HSStackOptimizer *optimizer = [HSStackOptimizer new];
        [optimizer optimizeStack:[self stack]];
        _wasOptimizedAndNotSaved = 1;
        [[self undoManager] removeAllActions];
        [self updateChangeCount:2];
        [self saveToURL:[aEnd URL] ofType:@"HSDocumentType" forSaveOperation:1 delegate:self didSaveSelector:@selector(optimizedDocument:didSave:contextInfo:) contextInfo:NULL];
        [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[aEnd directoryURL] path]];
        [optimizer postprocessAfterOptimization];
        [optimizer release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027b799 @ 0027b799, 59 bytes * /

void FUN_0027b799(HSEditorDocument *self,SEL _cmd,id optimizedDocument,BOOL didSave,
                 void *contextInfo)

{
  if (didSave != '\0') {
    *(byte *)&self->_wasOptimizedAndNotSaved = (byte)self->_wasOptimizedAndNotSaved & 0xfe;
  }
  _objc_msgSend(self,sel_setShouldStoreCardPreviewImages_,1);
  return;
}

*/
- (void)optimizedDocument:(id)aDocument didSave:(BOOL)aSave contextInfo:(void *)aInfo
{
    if (aSave) {
        _wasOptimizedAndNotSaved = 0;
    }
    [self setShouldStoreCardPreviewImages:YES];
}

- (void)invalidExportFilenameAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self runModalExportPanelWithDelegate:self didSaveSelector:@selector(exportPanelControllerDidEnd:returnCode:contextInfo:) contextInfo:aInfo needRunExportDialogOnCancel:[[[self exportManager] exportPanelController] isNeedRunExportDialog]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027b850 @ 0027b850, 796 bytes * /

void FUN_0027b850(HSEditorDocument *self,SEL _cmd,id exportPanelControllerDidEnd,int returnCode,
                 void *contextInfo)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  HSEditorDocument *self_00;
  HSEditorDocument *pHVar5;
  SEL op;
  cfstringStruct *pcVar6;
  id *ppvVar7;
  id local_14;
  
  pcVar6 = &cfstr_HSDocumentType;
  pvVar2 = _objc_msgSend(contextInfo,sel_isEqualToString_,&cfstr_HSDocumentType);
  if ((char)pvVar2 != '\0') {
    return;
  }
  if (returnCode == 1) {
    local_14 = (id)0x0;
    pvVar2 = _objc_msgSend(exportPanelControllerDidEnd,sel_window,pcVar6);
    pvVar3 = _objc_msgSend(pvVar2,sel_delegate);
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar2,sel_URL,pcVar6);
      ppvVar7 = &local_14;
      pvVar4 = _objc_msgSend(self,sel_panel_validateURL_error_,pvVar2,pvVar3,ppvVar7);
      if (((char)pvVar4 == '\0') && (local_14 != (id)0x0)) {
        self_00 = _objc_msgSend(cls_HSAlert,sel_new,pvVar2,pvVar3,ppvVar7);
        _objc_msgSend(self_00,sel_setAlertStyle_,0);
        pvVar2 = _objc_msgSend(local_14,sel_localizedDescription);
        _objc_msgSend(self_00,sel_setMessageText_,pvVar2);
        pvVar2 = _objc_msgSend(local_14,sel_localizedRecoverySuggestion);
        _objc_msgSend(self_00,sel_setInformativeText_,pvVar2);
        puVar1 = sel_invalidExportFilenameAlertDidEnd_returnCode_contextInfo_;
        pHVar5 = _objc_msgSend(self,sel_windowForSheet);
        _objc_msgSend(self_00,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_
                      ,pHVar5,self,puVar1,contextInfo);
        op = sel_release;
        goto LAB_0027b9f2;
      }
    }
    _objc_msgSend(self,sel_setResourcesWrapper_,0);
    pvVar2 = _objc_msgSend(cls_HSMediaValidator,sel_mediaValidatorForDocument_,self);
    _objc_msgSend(pvVar2,sel_validateMedia);
    puVar1 = cls_HSMediaSaver;
    pvVar2 = _objc_msgSend(self,sel_resourcesWrapper);
    _objc_msgSend(puVar1,sel_saveMediaForDocument_resourcesWrapper_,self,pvVar2);
    _objc_msgSend(self,sel_reloadDocumentMedia);
    pvVar2 = _objc_msgSend(self,sel_editorCardView);
    _objc_msgSend(pvVar2,sel_saveEditingState);
    pvVar2 = _objc_msgSend(self,sel_exportManager);
    pvVar3 = _objc_msgSend(exportPanelControllerDidEnd,sel_filename);
    _objc_msgSend(pvVar2,sel_exportDocumentWithFileName_ofType_,pvVar3,contextInfo);
    self_00 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pHVar5 = _objc_msgSend(exportPanelControllerDidEnd,sel_directory);
    op = sel_setHyperStudioDocumentsExportFolder_;
  }
  else {
    pvVar2 = _objc_msgSend(exportPanelControllerDidEnd,sel_isNeedRunExportDialog,pcVar6);
    self_00 = self;
    op = sel_exportTo_;
    pHVar5 = self;
    if ((char)pvVar2 == '\0') {
      return;
    }
  }
LAB_0027b9f2:
  _objc_msgSend(self_00,op,pHVar5);
  return;
}

*/
- (void)exportPanelControllerDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if ([(id)aInfo isEqualToString:@"HSDocumentType"]) {
        return;
    }
    if (aCode == 1) {
        NSError *error = nil;
        id panel = [aEnd window];
        if ([panel delegate] == nil) {
            NSURL *url = [panel URL];
            if (![self panel:panel validateURL:url error:&error] && error != nil) {
                HSAlert *alert = [HSAlert new];
                [alert setAlertStyle:0];
                [alert setMessageText:[error localizedDescription]];
                [alert setInformativeText:[error localizedRecoverySuggestion]];
                [alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(invalidExportFilenameAlertDidEnd:returnCode:contextInfo:) contextInfo:aInfo];
            }
        }
        [self setResourcesWrapper:nil];
        [[HSMediaValidator mediaValidatorForDocument:self] validateMedia];
        [HSMediaSaver saveMediaForDocument:self resourcesWrapper:[self resourcesWrapper]];
        [self reloadDocumentMedia];
        [[self editorCardView] saveEditingState];
        [[self exportManager] exportDocumentWithFileName:[aEnd filename] ofType:(id)aInfo];
        [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsExportFolder:[aEnd directory]];
    } else if ([aEnd isNeedRunExportDialog]) {
        [self exportTo:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027bb6c @ 0027bb6c, 450 bytes * /

void FUN_0027bb6c(HSEditorDocument *self,SEL _cmd,id runModalExportPanelWithDelegate,
                 SEL didSaveSelector,void *contextInfo,BOOL needRunExportDialogOnCancel)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(self,sel_exportManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_exportPanelController);
  pvVar2 = _objc_msgSend(self,sel_fileName);
  pvVar2 = _objc_msgSend(pvVar2,sel_lastPathComponent);
  pvVar2 = _objc_msgSend(pvVar2,sel_stringByDeletingPathExtension);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_displayName);
  }
  pcVar5 = &cfstr_HSiBooksAuthorDocumentType;
  pvVar3 = _objc_msgSend(contextInfo,sel_isEqualToString_,&cfstr_HSiBooksAuthorDocumentType);
  if ((char)pvVar3 != '\0') {
    pvVar3 = _objc_msgSend(pvVar1,sel_filename,pcVar5);
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_filename,pcVar5);
    }
    pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_relativeString);
    pvVar2 = _objc_msgSend(pvVar2,sel_extraStringByReplacingURLEscapedSymbolsWithUnderscores);
  }
  _objc_msgSend(pvVar1,sel_setNeedRunExportDialog_,(int)needRunExportDialogOnCancel);
  pvVar3 = _objc_msgSend(self,sel_windowForSheet);
  pvVar4 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperStudioDocumentsExportFolder);
  _objc_msgSend(pvVar1,
                sel_beginSheetForDirectory_file_modalForWindow_modalDelegate_didEndSelector_contextInfo_
                ,pvVar4,pvVar2,pvVar3,runModalExportPanelWithDelegate,didSaveSelector,contextInfo);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0027bd2e @ 0027bd2e, 1351 bytes * /

BOOL FUN_0027bd2e(HSEditorDocument *self,SEL _cmd,id panel,id validateURL,id *error)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  undefined4 uVar8;
  cfstringStruct *pcVar9;
  undefined4 uVar10;
  
  pvVar2 = _objc_msgSend(self,sel_exportManager);
  pvVar3 = _objc_msgSend(pvVar2,sel_exportPanelController);
  pvVar4 = _objc_msgSend(pvVar3,sel_isWindowLoaded);
  if ((char)pvVar4 == '\0') {
    return '\x01';
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_window);
  if (pvVar3 != panel) {
    return '\x01';
  }
  pvVar3 = _objc_msgSend(validateURL,sel_path);
  pvVar3 = _objc_msgSend(pvVar3,sel_lastPathComponent);
  if (pvVar3 == (id)0x0) {
    return '\0';
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_exportFormat);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(cls_NSCharacterSet,sel_characterSetWithCharactersInString_,&cfstr____);
    if (pvVar2 == (id)0x0) {
      return '\0';
    }
    pvVar4 = _objc_msgSend(pvVar3,sel_rangeOfCharacterFromSet_,pvVar2);
    puVar1 = cls_NSString;
    if (pvVar4 == (id)0x7fffffff) {
      return '\x01';
    }
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar2);
    pcVar9 = &cfstr_Alerts;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInvalidWebExportPanelFilenameMessageText,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar4 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar2,pvVar3);
    if (pvVar4 == (id)0x0) {
      return '\0';
    }
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar2,pvVar3,pcVar9)
    ;
    pcVar9 = &cfstr_Alerts;
    pcVar7 = &cfstr_empty;
    pcVar5 = &cfstr_HSInvalidWebExportPanelFilenameInformativeText;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInvalidWebExportPanelFilenameInformativeText,&cfstr_empty,
                           &cfstr_Alerts);
    if (error != (id *)0x0) {
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar4,
                             *(undefined4 *)PTR_00336968,pvVar2,*(undefined4 *)PTR_0033696c,0);
      pvVar2 = _objc_msgSend(cls_NSError,sel_errorWithDomain_code_userInfo_,
                             *(undefined4 *)PTR_003361ac,0x102,pvVar2);
      *error = pvVar2;
      return '\0';
    }
    pvVar3 = _objc_msgSend(cls_HSAlert,sel_new,pcVar5,pcVar7,pcVar9);
    _objc_msgSend(pvVar3,sel_setAlertStyle_,0);
    _objc_msgSend(pvVar3,sel_setMessageText_,pvVar4);
    _objc_msgSend(pvVar3,sel_setInformativeText_,pvVar2);
    uVar10 = 0;
    uVar8 = 0;
    uVar6 = 0;
    _objc_msgSend(pvVar3,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,
                  panel,0,0,0);
  }
  else {
    if (pvVar2 != (id)0x8) {
      return '\x01';
    }
    uVar6 = 0;
    pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar3,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_relativeString);
    if (pvVar2 == (id)0x0) {
      return '\0';
    }
    pvVar4 = pvVar3;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pvVar3,uVar6);
    puVar1 = cls_NSString;
    if ((char)pvVar2 != '\0') {
      return '\x01';
    }
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4,uVar6);
    pcVar9 = &cfstr_Alerts;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInvalidIBAExportPanelFilenameMessageText,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar4 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar2,pvVar3);
    if (pvVar4 == (id)0x0) {
      return '\0';
    }
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar2,pvVar3,pcVar9)
    ;
    pcVar9 = &cfstr_Alerts;
    pcVar7 = &cfstr_empty;
    pcVar5 = &cfstr_HSInvalidIBAExportPanelFilenameInformativeText;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInvalidIBAExportPanelFilenameInformativeText,&cfstr_empty,
                           &cfstr_Alerts);
    if (error != (id *)0x0) {
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar4,
                             *(undefined4 *)PTR_00336968,pvVar2,*(undefined4 *)PTR_0033696c,0);
      pvVar2 = _objc_msgSend(cls_NSError,sel_errorWithDomain_code_userInfo_,
                             *(undefined4 *)PTR_003361ac,0x102,pvVar2);
      *error = pvVar2;
      return '\0';
    }
    pvVar3 = _objc_msgSend(cls_HSAlert,sel_new,pcVar5,pcVar7,pcVar9);
    _objc_msgSend(pvVar3,sel_setAlertStyle_,0);
    _objc_msgSend(pvVar3,sel_setMessageText_,pvVar4);
    _objc_msgSend(pvVar3,sel_setInformativeText_,pvVar2);
    uVar10 = 0;
    uVar8 = 0;
    uVar6 = 0;
    _objc_msgSend(pvVar3,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,
                  panel,0,0,0);
  }
  _objc_msgSend(pvVar3,sel_release,panel,uVar6,uVar8,uVar10);
  return '\0';
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0027c2d2 @ 0027c2d2, 634 bytes * /

BOOL FUN_0027c2d2(HSEditorDocument *self,SEL _cmd,id hyperReadFromFileWrapper,id ofType,id *error)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  undefined *self_00;
  bool bVar4;
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  pvVar2 = _objc_msgSend(ofType,sel_isEqual_,&cfstr_HSDocumentType);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSKeynoteDocumentType);
    if ((char)pvVar2 != '\0') {
      pvVar2 = hyperReadFromFileWrapper;
      pvVar3 = _objc_msgSend(cls_KeynoteImportManager,sel_isKeynote2FileWrapperRepresentation_,
                             hyperReadFromFileWrapper);
      if ((char)pvVar3 != '\0') {
        pvVar2 = _objc_msgSend(self,sel_undoManager,pvVar2);
        _objc_msgSend(pvVar2,sel_disableUndoRegistration);
        pvVar2 = _objc_msgSend(cls_KeynoteImportManager,sel_new);
        pvVar3 = _objc_msgSend(self,sel_fileURL);
        pvVar3 = _objc_msgSend(pvVar3,sel_path);
        _objc_msgSend(pvVar2,sel_setPathToDocument_,pvVar3);
        _objc_msgSend(pvVar2,sel_setFileWrapper_,hyperReadFromFileWrapper);
        self_00 = _objc_msgSend(pvVar2,sel_presentation);
        _objc_msgSend(self_00,sel_detailChildren);
        pvVar3 = _objc_msgSend(pvVar2,sel_shouldImportPresentation);
        bVar4 = (char)pvVar3 == '\0';
        if (bVar4) {
          self_00 = &DAT_00002711;
          pvVar3 = _objc_msgSend(cls_HSError,sel_errorWithHSCode_,&DAT_00002711);
          *error = pvVar3;
        }
        else {
          pvVar3 = _objc_msgSend(cls_HSStack,sel_defaultObject,hyperReadFromFileWrapper);
          _objc_msgSend(self,sel_setStack_,pvVar3);
          _objc_msgSend(pvVar3,sel_importFromKeynoteObject_,self_00);
        }
        _objc_msgSend(pvVar2,sel_release,self_00);
        pvVar2 = _objc_msgSend(self,sel_undoManager);
        _objc_msgSend(pvVar2,sel_enableUndoRegistration);
        return !bVar4;
      }
      if (error != (id *)0x0) {
        pvVar2 = _objc_msgSend(cls_HSError,sel_errorWithHSCode_,0x5026);
        *error = pvVar2;
      }
    }
    BVar1 = '\0';
  }
  else {
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    pvVar2 = _objc_msgSendSuper(&local_1c,sel_hyperReadFromFileWrapper_ofType_error_,
                                hyperReadFromFileWrapper,ofType,error);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)hyperReadFromFileWrapper:(id)aWrapper ofType:(id)aType error:(id *)aError
{
    if ([aType isEqual:@"HSDocumentType"]) {
        return [super hyperReadFromFileWrapper:aWrapper ofType:aType error:aError];
    }
    if ([aType isEqualToString:@"HSKeynoteDocumentType"]) {
        if ([KeynoteImportManager isKeynote2FileWrapperRepresentation:aWrapper]) {
            [[self undoManager] disableUndoRegistration];
            KeynoteImportManager *manager = [KeynoteImportManager new];
            [manager setPathToDocument:[[self fileURL] path]];
            [manager setFileWrapper:aWrapper];
            id presentation = [manager presentation];
            [presentation detailChildren];
            BOOL imported = [manager shouldImportPresentation];
            if (!imported) {
                *aError = [HSError errorWithHSCode:0x2711];
            } else {
                HSStack *stack = [HSStack defaultObject];
                [self setStack:stack];
                [stack importFromKeynoteObject:presentation];
            }
            [manager release];
            [[self undoManager] enableUndoRegistration];
            return imported;
        }
        if (aError != NULL) {
            *aError = [HSError errorWithHSCode:0x5026];
        }
    }
    return NO;
}

- (id)currentWindowController
{
    return [[self modeSwitcher] activeModeController];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027c586 @ 0027c586, 120 bytes * /

BOOL FUN_0027c586(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_isInStoryboardMode);
  if ((((char)pvVar1 == '\0') &&
      (pvVar1 = _objc_msgSend(self,sel_isInPurePlayerMode), (char)pvVar1 == '\0')) &&
     (pvVar1 = _objc_msgSend(self,sel_isInPresentationMode), (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(self,sel_isInIpadExportPreviewMode);
    return (char)pvVar1 == '\0';
  }
  return '\0';
}

*/
- (BOOL)isInStandardMode
{
    if ([self isInStoryboardMode] || [self isInPurePlayerMode] || [self isInPresentationMode]) {
        return NO;
    }
    return ![self isInIpadExportPreviewMode];
}

- (BOOL)isInHyperCastingMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _hyperCastingWindowController;
    }
    return bVar2;
}

- (BOOL)isInPurePlayerMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _purePlayerWindowController;
    }
    return bVar2;
}

- (BOOL)isInPresentationMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _presentationWindowController;
    }
    return bVar2;
}

- (BOOL)isInStoryboardMode
{
    BOOL bVar2;

    if (_modeSwitcher == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self currentWindowController] == _storyboardController;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027c743 @ 0027c743, 126 bytes * /

BOOL FUN_0027c743(HSEditorDocument *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  
  if (self->_modeSwitcher == (HSModeSwitcher *)0x0) {
    bVar2 = false;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_currentWindowController);
    if ((pvVar1 == self->_playerInEditorWindowController) ||
       (pvVar1 = _objc_msgSend(self,sel_currentWindowController),
       pvVar1 == self->_purePlayerWindowController)) {
      bVar2 = true;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_currentWindowController);
      bVar2 = pvVar1 == self->_presentationWindowController;
    }
  }
  return bVar2;
}

*/
- (BOOL)isInPlayerMode
{
    if (_modeSwitcher == nil) {
        return NO;
    }
    return [self currentWindowController] == _playerInEditorWindowController || [self currentWindowController] == _purePlayerWindowController || [self currentWindowController] == _presentationWindowController;
}

- (id)playerInEditorWindowController
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _playerInEditorWindowController;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSDependentPlayerWindowController new];
        _playerInEditorWindowController = pvVar1_2;
        [self addWindowController:pvVar1_2];
        pvVar1 = _playerInEditorWindowController;
    }
    return pvVar1;
}

- (Class)mainWindowControllerClass
{
    return [HSEditorWindowController class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027c8d6 @ 0027c8d6, 398 bytes * /

void FUN_0027c8d6(HSEditorDocument *self,SEL _cmd,id setStack,BOOL notify,BOOL clearChanges)

{
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  if (*(id *)(self->super_HSDocumentStoring + 0x38) != setStack) {
    _objc_msgSend(*(id *)(self->super_HSDocumentStoring + 0x38),
                  sel_removeObserver_selector_ofChanges_ofAttribute_ofChildrenInDepthRange_,self,
                  sel_textViewWillBeginScrolling_,0x40,&DAT_00387558,0,2);
    _objc_msgSend(*(id *)(self->super_HSDocumentStoring + 0x38),
                  sel_removeObserver_selector_ofChanges_ofAttribute_ofChildrenInDepthRange_,self,
                  sel_textViewWillBeginScrolling_,0x40,&DAT_003875a8,0,2);
    local_1c = self;
    local_18 = PTR_s_HSDocumentStoring_00356420;
    _objc_msgSendSuper(&local_1c,sel_setStack_notify_clearChanges_,setStack,(int)notify,
                       (int)clearChanges);
    _objc_msgSend(*(id *)(self->super_HSDocumentStoring + 0x38),
                  sel_addObserver_selector_ofChanges_ofAttribute_ofChildrenInDepthRange_withPriority_
                  ,self,sel_textViewWillBeginScrolling_,0x40,&DAT_00387558,0,2,0x3f000000);
    _objc_msgSend(*(id *)(self->super_HSDocumentStoring + 0x38),
                  sel_addObserver_selector_ofChanges_ofAttribute_ofChildrenInDepthRange_withPriority_
                  ,self,sel_textViewWillBeginScrolling_,0x40,&DAT_003875a8,0,2,0x3f000000);
  }
  return;
}

*/
- (void)setStack:(id)aStack notify:(BOOL)aNotify clearChanges:(BOOL)aChanges
{
    if (_stack != aStack) {
        [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
        [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
        [super setStack:aStack notify:aNotify clearChanges:aChanges];
        [_stack addObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:0.5];
        [_stack addObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:0.5];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027ca64 @ 0027ca64, 206 bytes * /

void FUN_0027ca64(HSEditorDocument *self,SEL _cmd)

{
  HSEditorDocument *local_1c;
  undefined *local_18;
  
  _objc_msgSend(*(id *)(self->super_HSDocumentStoring + 0x38),
                sel_removeObserver_selector_ofChanges_ofAttribute_ofChildrenInDepthRange_,self,
                sel_textViewWillBeginScrolling_,0x40,&DAT_00387558,0,2);
  _objc_msgSend(*(id *)(self->super_HSDocumentStoring + 0x38),
                sel_removeObserver_selector_ofChanges_ofAttribute_ofChildrenInDepthRange_,self,
                sel_textViewWillBeginScrolling_,0x40,&DAT_003875a8,0,2);
  local_1c = self;
  local_18 = PTR_s_HSDocumentStoring_00356420;
  _objc_msgSendSuper(&local_1c,sel_destoyModel);
  return;
}

*/
- (void)destoyModel
{
    [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
    [_stack removeObserver:self selector:@selector(textViewWillBeginScrolling:) ofChanges:0x40 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
    [super destoyModel];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027cb32 @ 0027cb32, 849 bytes * /

void FUN_0027cb32(HSEditorDocument *self,SEL _cmd)

{
  id self_00;
  HSEditorDocument *local_14;
  undefined *local_10;
  
  _objc_msgSend(self,sel_destoryModelIfNeeded);
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_removeObserver_,self);
  _objc_msgSend(self->_hyperRemovedItemsPaths,sel_release);
  _objc_msgSend(self->_commitLogMessage,sel_release);
  _objc_msgSend(self->_documentSharingController,sel_release);
  _objc_msgSend(self->_editObjectDialogContext,sel_release);
  _objc_msgSend(self->_animationModeController,sel_release);
  _objc_msgSend(self->_modeSwitcher,sel_release);
  _objc_msgSend(self->_exportManager,sel_release);
  _objc_msgSend(self->_selectionController,sel_setCardView_,0);
  _objc_msgSend(self->_selectionController,sel_release);
  _objc_msgSend(self->_storyboardController,sel_release);
  _objc_msgSend(self->_selectionSync,sel_setCardView_,0);
  _objc_msgSend(self->_selectionSync,sel_release);
  _objc_msgSend(self->_stackSelectionHolder,sel_setDocument_,0);
  _objc_msgSend(self->_stackSelectionHolder,sel_release);
  _objc_msgSend(self->_playerInEditorWindowController,sel_setStatusbarController_,0);
  _objc_msgSend(self->_playerInEditorWindowController,sel_release);
  _objc_msgSend(self->_hyperCastingWindowController,sel_release);
  _objc_msgSend(self->_purePlayerWindowController,sel_release);
  _objc_msgSend(self->_presentationWindowController,sel_release);
  _objc_msgSend(self->_modeHistory,sel_release);
  _objc_msgSend(self->_playerView,sel_release);
  _objc_msgSend(self->_invocationsToPerformAfterSwitchToEditMode,sel_release);
  _objc_msgSend(self->_minimalWindowApplier,sel_release);
  _objc_msgSend(self->_openWarning,sel_release);
  _objc_msgSend(self->_palettesToHideInHypercastingMode,sel_release);
  _objc_msgSend(self->_textViewsToResetScrollPosition,sel_release);
  _objc_msgSend(self->_iPadStack,sel_release);
  _objc_msgSend(self->_originalStackStorage,sel_release);
  _objc_msgSend(self->_iPadUndoManager,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSDocumentStoring_00356420;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [self destoryModelIfNeeded];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_hyperRemovedItemsPaths release];
    [_commitLogMessage release];
    [_documentSharingController release];
    [_editObjectDialogContext release];
    [_animationModeController release];
    [_modeSwitcher release];
    [_exportManager release];
    [_selectionController setCardView:nil];
    [_selectionController release];
    [_storyboardController release];
    [_selectionSync setCardView:nil];
    [_selectionSync release];
    [_stackSelectionHolder setDocument:nil];
    [_stackSelectionHolder release];
    [_playerInEditorWindowController setStatusbarController:nil];
    [_playerInEditorWindowController release];
    [_hyperCastingWindowController release];
    [_purePlayerWindowController release];
    [_presentationWindowController release];
    [_modeHistory release];
    [_playerView release];
    [_invocationsToPerformAfterSwitchToEditMode release];
    [_minimalWindowApplier release];
    [_openWarning release];
    [_palettesToHideInHypercastingMode release];
    [_textViewsToResetScrollPosition release];
    [_iPadStack release];
    [_originalStackStorage release];
    [_iPadUndoManager release];
    [super dealloc];
}

- (id)initForURL:(id)aURL withContentsOfURL:(id)aURL2 ofType:(id)aType error:(id *)aError
{
    id pcVar3;
    NSString *pvVar1_3;

    self = [super initForURL:aURL withContentsOfURL:aURL2 ofType:aType error:aError];
    if (self != nil) {
        pvVar1_3 = [[[aURL path] pathExtension] lowercaseString];
        if (![pvVar1_3 isEqualToString:@"stack"]) {
            if (![pvVar1_3 isEqualToString:@"key"]) {
                pcVar3 = @"HSNativeDocumentType";
            }
            else {
                pcVar3 = @"HSKeynoteDocumentType";
            }
            [self setFileType:pcVar3];
        }
    }
    return self;
}

@end

