#import "HSDependentPlayerWindowController.h"

@implementation HSDependentPlayerWindowController

/* i386 ivar offsets: _dummyUndoManager=0x60, _bottomAreaTintedView=0x64, _mainAreaTintedView=0x68, _workAreaView=0x6c, _statusbarController=0x70, _stackTextProvider=0x74 */

+ (id)windowNibName
{
    return @"PlayerInEditorWindowEmbedded";
}

- (id)stackTextProvider
{
    HSPlayerStackTextProvider *pHVar3;

    pHVar3 = _stackTextProvider;
    if (pHVar3 == nil) {
        pHVar3 = [[[HSPlayerStackTextProvider alloc] initWithWindowController:self selectionController:[self selectionController]] queryHyperInterface:@protocol(HSTextObjectDataSource)];
        _stackTextProvider = pHVar3;
    }
    return pHVar3;
}

- (void)hyperShowGuessPanel:(id)aPanel
{
    [[HSTextProvider sharedInstance] performShowGuessPanel:aPanel];
}

- (void)hyperCheckSpelling:(id)aSpelling
{
    [[HSTextProvider sharedInstance] performCheckSpelling:aSpelling];
}

- (void)performHyperFindPanelAction:(id)aAction
{
    [[HSTextProvider sharedInstance] performFindAction:aAction];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bf705 @ 001bf705, 223 bytes * /

void FUN_001bf705(HSDependentPlayerWindowController *self,SEL _cmd,BOOL setBottomToolbarVisible)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  HSDependentPlayerWindowController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSPlayerInEditorWindowController_00353810;
  _objc_msgSendSuper(&local_1c,sel_setBottomToolbarVisible_,(int)setBottomToolbarVisible);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_editorWindowController);
  pvVar2 = _objc_msgSend(self,sel_window);
  if (setBottomToolbarVisible == 0) {
    pvVar3 = self->_bottomAreaTintedView;
    pvVar6 = (id)0x1;
    op = sel_hideIfNeededBottomToolbarView_mainAreaTintedView_mainWindow_animated_;
    pvVar4 = self->_mainAreaTintedView;
    pvVar5 = pvVar2;
  }
  else {
    pvVar3 = self->_bottomAreaTintedView;
    op = sel_showIfNeededBottomToolbarView_workAreaView_mainAreaTintedView_mainWindow_animated_;
    pvVar4 = self->_workAreaView;
    pvVar5 = self->_mainAreaTintedView;
    pvVar6 = pvVar2;
  }
  _objc_msgSend(pvVar1,op,pvVar3,pvVar4,pvVar5,pvVar6);
  return;
}

*/
- (void)setBottomToolbarVisible:(BOOL)aVisible
{
    [super setBottomToolbarVisible:aVisible];
    id editor = [[self document] editorWindowController];
    id window = [self window];
    if (!aVisible) {
        [editor hideIfNeededBottomToolbarView:_bottomAreaTintedView mainAreaTintedView:_mainAreaTintedView mainWindow:window animated:YES];
    } else {
        [editor showIfNeededBottomToolbarView:_bottomAreaTintedView workAreaView:_workAreaView mainAreaTintedView:_mainAreaTintedView mainWindow:window animated:YES];
    }
}

- (void)setStatusbarController:(id)aController
{
    _statusbarController = aController;
}

- (void)setWorkAreaView:(id)aView
{
    _workAreaView = aView;
}

- (void)setMainAreaTintedView:(id)aView
{
    _mainAreaTintedView = aView;
}

- (void)setBottomAreaTintedView:(id)aView
{
    _bottomAreaTintedView = aView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bf7e4 @ 001bf7e4, 134 bytes * /

void FUN_001bf7e4(HSDependentPlayerWindowController *self,SEL _cmd,
                 id modeSwitcherDidEndModeSwitching)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar1 = _objc_msgSend(modeSwitcherDidEndModeSwitching,sel_object);
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_00336104,pvVar1)
  ;
  _objc_msgSend(self->_statusbarController,sel_validateUI);
  return;
}

*/
- (void)modeSwitcherDidEndModeSwitching:(id)aSwitching
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:[aSwitching object]];
    [_statusbarController validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bf86a @ 001bf86a, 220 bytes * /

void FUN_001bf86a(HSDependentPlayerWindowController *self,SEL _cmd,id didBecomeWorkingInModeSwitcher
                 )

{
  id pvVar1;
  id pvVar2;
  HSDependentPlayerWindowController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSPlayerInEditorWindowController_00353810;
  _objc_msgSendSuper(&local_1c,sel_didBecomeWorkingInModeSwitcher_,didBecomeWorkingInModeSwitcher);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSDocumentDidActivateObjectListDataProviderNotif,pvVar2);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                sel_modeSwitcherDidEndModeSwitching_,*(undefined4 *)PTR_PTR_00336104,
                didBecomeWorkingInModeSwitcher);
  return;
}

*/
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [super didBecomeWorkingInModeSwitcher:aSwitcher];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentDidActivateObjectListDataProviderNotification" object:[self document]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeSwitcherDidEndModeSwitching:) name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:aSwitcher];
}

- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecameNonWorkingInModeSwitcher:aSwitcher];
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:nil];
}

- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecomeWorkingInModeSwitcher:aSwitcher]
    ;
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:self];
    [[[HSObjectListPaletteController sharedInstance] objectListController] updateSelectionInTableViewWithCurrentSelection];
    [self setupUIMode];
}

- (void)windowDidBecomeKey:(id)aKey
{
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:self];
}

- (id)secondaryModeSwitcherWindows:(id)aWindows
{
    id self_00;
    unsigned int uVar2;
    BOOL pvVar1_2;

    pvVar1_2 = [[self document] isStackProtected];
    self_00 = [super secondaryModeSwitcherWindows:aWindows];
    uVar2 = (unsigned int)(!pvVar1_2);
    return [self_00 arrayByAddingObjectsFromArray:[HSEditorWindowController palettesArrayIncludingLibrary:uVar2 toolPalette:uVar2 layoutPalette:uVar2 objectListPalette:uVar2 commentsAndAttributionsPalette:uVar2 shortcutsPalette:uVar2]];
}

- (id)mainModeSwitcherWindow:(id)aWindow
{
    return [self window];
}

- (BOOL)cancelOperation
{
    BOOL BVar1;

    BVar1 = (BOOL)[super cancelOperation];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:HSToggleBrowseEditByEscapeEnabledKey] boolValue]) {
        [[self document] togglePlayEdit:self];
        BVar1 = YES;
    }
    return BVar1;
}

- (BOOL)hasPlayerMode
{
    return NO;
}

- (void)navigationOperationDidFinishInPlayerView:(id)aView
{
    [_statusbarController validateUI];
    [super navigationOperationDidFinishInPlayerView:aView];
}

- (void)hideShowToolbar:(id)aToolbar
{
    [super hideShowToolbar:aToolbar];
}

- (void)toggleObjectAssistant:(id)aAssistant
{
    [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:YES];
}

- (BOOL)supportMenuItemStoredTitleValidation
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bfcf4 @ 001bfcf4, 808 bytes * /

BOOL FUN_001bfcf4(HSDependentPlayerWindowController *self,SEL _cmd,id validateUserInterfaceItem)

{
  char cVar1;
  undefined *puVar2;
  id pvVar3;
  HSDependentPlayerWindowController *local_1c;
  undefined *local_18;
  
  puVar2 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  pvVar3 = _objc_msgSend(self,sel_document);
  pvVar3 = _objc_msgSend(pvVar3,sel_isDocumentClosing);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_document);
    pvVar3 = _objc_msgSend(pvVar3,sel_actionExecutionContext);
    pvVar3 = _objc_msgSend(pvVar3,sel_waitingForMouseDownEvent);
    if ((char)pvVar3 == '\0') {
      if ((((((((puVar2 == sel_paste_) || (puVar2 == sel_addButtonObject_)) ||
              (puVar2 == sel_addTextObject_)) ||
             (((puVar2 == sel_importText_ || (puVar2 == sel_addWebObject_)) ||
              ((puVar2 == sel_addMediaObject_ ||
               ((puVar2 == sel_addSoundObject_ || (puVar2 == sel_addLiveVideoObject_)))))))) ||
            (puVar2 == sel_addWebCamObject_)) ||
           ((((puVar2 == sel_addGraphicObject_ || (puVar2 == sel_addGraphic_)) ||
             (puVar2 == sel_importBackground_)) ||
            (((puVar2 == sel_eraseBackground_ || (puVar2 == sel_showCardOptionsDialog_)) ||
             ((puVar2 == sel_showStackOptionsDialog_ ||
              ((puVar2 == sel_editStackActions_ || (puVar2 == sel_editCardActions_)))))))))) ||
          ((puVar2 == sel_runSoundRecordingPanel_ ||
           ((((((puVar2 == sel_runVideoRecordingPanel_ || (puVar2 == sel_addQuickShotGraphicObject_)
                ) || (puVar2 == sel_addQuickShotBackground_)) ||
              ((puVar2 == sel_titleCard_ || (puVar2 == sel_runEasyLinkDialog_)))) ||
             (puVar2 == sel_runMakeEveryCardNextCardExtra_)) ||
            (((puVar2 == sel_draw3DShapes_ || (puVar2 == sel_addMovieComboObject_)) ||
             ((puVar2 == sel_addSoundComboObject_ ||
              (((puVar2 == sel_showYouTubeDialog_ || (puVar2 == sel_copy_)) || (puVar2 == sel_cut_))
              )))))))))) ||
         (((puVar2 == sel_delete_ || (puVar2 == sel_sameBackground_)) ||
          (puVar2 == sel_makeGroupCard_)))) {
        pvVar3 = _objc_msgSend(self,sel_validateUserInterfaceItemThatRequiresSwitchToEditMode_,
                               validateUserInterfaceItem);
        return (BOOL)pvVar3;
      }
      if (puVar2 == sel_toggleObjectAssistant_) {
        pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
        pvVar3 = _objc_msgSend(pvVar3,sel_isActive);
        cVar1 = (char)pvVar3;
        pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
        if ((char)pvVar3 == '\0') {
          return cVar1;
        }
        _objc_msgSend(validateUserInterfaceItem,sel_setState_,(uint)(cVar1 != '\0'));
        return cVar1;
      }
      if ((puVar2 != sel_addReadyMadeCards_) && (puVar2 != sel_textFieldTamer_)) {
        if (((puVar2 != sel_performHyperFindPanelAction_) && (puVar2 != sel_showGuessPanel_)) &&
           (puVar2 != sel_checkSpelling_)) {
          local_1c = self;
          local_18 = PTR_s_HSPlayerInEditorWindowController_00353810;
          pvVar3 = _objc_msgSendSuper(&local_1c,sel_validateUserInterfaceItem_,
                                      validateUserInterfaceItem);
          return (BOOL)pvVar3;
        }
        return '\x01';
      }
      pvVar3 = _objc_msgSend(self,sel_document);
      pvVar3 = _objc_msgSend(pvVar3,sel_isStackProtected);
      return (char)pvVar3 == '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    if ([[self document] isDocumentClosing] || [[[self document] actionExecutionContext] waitingForMouseDownEvent]) {
        return NO;
    }
    if (action == @selector(paste:) ||
        action == @selector(addButtonObject:) ||
        action == @selector(addTextObject:) ||
        action == @selector(importText:) ||
        action == @selector(addWebObject:) ||
        action == @selector(addMediaObject:) ||
        action == @selector(addSoundObject:) ||
        action == @selector(addLiveVideoObject:) ||
        action == @selector(addWebCamObject:) ||
        action == @selector(addGraphicObject:) ||
        action == @selector(addGraphic:) ||
        action == @selector(importBackground:) ||
        action == @selector(eraseBackground:) ||
        action == @selector(showCardOptionsDialog:) ||
        action == @selector(showStackOptionsDialog:) ||
        action == @selector(editStackActions:) ||
        action == @selector(editCardActions:) ||
        action == @selector(runSoundRecordingPanel:) ||
        action == @selector(runVideoRecordingPanel:) ||
        action == @selector(addQuickShotGraphicObject:) ||
        action == @selector(addQuickShotBackground:) ||
        action == @selector(titleCard:) ||
        action == @selector(runEasyLinkDialog:) ||
        action == @selector(runMakeEveryCardNextCardExtra:) ||
        action == @selector(draw3DShapes:) ||
        action == @selector(addMovieComboObject:) ||
        action == @selector(addSoundComboObject:) ||
        action == @selector(showYouTubeDialog:) ||
        action == @selector(copy:) ||
        action == @selector(cut:) ||
        action == @selector(delete:) ||
        action == @selector(sameBackground:) ||
        action == @selector(makeGroupCard:)) {
        return [self validateUserInterfaceItemThatRequiresSwitchToEditMode:aItem];
    }
    if (action == @selector(toggleObjectAssistant:)) {
        BOOL active = [[HSObjectAssistantController sharedAssistantController] isActive];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:active ? NSControlStateValueOn : NSControlStateValueOff];
        }
        return active;
    }
    if (action == @selector(addReadyMadeCards:) || action == @selector(textFieldTamer:)) {
        return ![[self document] isStackProtected];
    }
    if (action == @selector(performHyperFindPanelAction:) || action == @selector(showGuessPanel:) || action == @selector(checkSpelling:)) {
        return YES;
    }
    return [super validateUserInterfaceItem:aItem];
}

- (id)dummyUndoManager
{
    return _dummyUndoManager;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c001c @ 001c001c, 173 bytes * /

id FUN_001c001c(HSDependentPlayerWindowController *self,SEL _cmd,id windowWillReturnUndoManager)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_isStackProtected);
  op = sel_dummyUndoManager;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_navigationController);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentNavigationOperation);
    op = sel_dummyUndoManager;
    if (pvVar1 == (id)0x0) {
      self = _objc_msgSend(self,sel_document);
      op = sel_undoManager;
    }
  }
  pvVar1 = _objc_msgSend(self,op);
  return pvVar1;
}

*/
- (id)windowWillReturnUndoManager:(id)aManager
{
    if ([[self document] isStackProtected] || [[[self document] navigationController] currentNavigationOperation] != nil) {
        return [self dummyUndoManager];
    }
    return [[self document] undoManager];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c00c9 @ 001c00c9, 144 bytes * /

BOOL FUN_001c00c9(HSDependentPlayerWindowController *self,SEL _cmd,
                 id validateUserInterfaceItemThatRequiresSwitchToEditMode)

{
  id pvVar1;
  undefined *puVar2;
  BOOL BVar3;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_isStackProtected);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_validateUserInterfaceItemThatRequiresSwitchToEditMode_,
                           validateUserInterfaceItemThatRequiresSwitchToEditMode);
    BVar3 = (BOOL)pvVar1;
  }
  else {
    puVar2 = _objc_msgSend(validateUserInterfaceItemThatRequiresSwitchToEditMode,sel_action);
    BVar3 = puVar2 == sel_showStackOptionsDialog_;
  }
  return BVar3;
}

*/
- (BOOL)validateUserInterfaceItemThatRequiresSwitchToEditMode:(id)aMode
{
    if ([[self document] isStackProtected]) {
        return [aMode action] == @selector(showStackOptionsDialog:);
    }
    return [[self document] validateUserInterfaceItemThatRequiresSwitchToEditMode:aMode];
}

- (void)sameBackground:(id)aBackground
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aBackground];
}

- (void)makeGroupCard:(id)aCard
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aCard];
}

- (void)delete:(id)aDelete
{
    [[[self document] editorWindowController] delete:aDelete];
}

- (void)cut:(id)aCut
{
    [[[self document] editorWindowController] cut:aCut];
}

- (void)paste:(id)aPaste
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aPaste];
}

- (void)copy:(id)aCopy
{
    [[[self document] editorWindowController] copy:aCopy];
}

- (void)draw3DShapes:(id)aShapes
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aShapes];
}

- (void)runMakeEveryCardNextCardExtra:(id)aExtra
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aExtra];
}

- (void)runEasyLinkDialog:(id)aDialog
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aDialog];
}

- (void)titleCard:(id)aCard
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aCard];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c044a @ 001c044a, 146 bytes * /

void FUN_001c044a(HSDependentPlayerWindowController *self,SEL _cmd,id textFieldTamer)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSTextFieldTamerDialogController,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_editObjectDialogContext);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithContext_,pvVar2);
  _objc_msgSend(pvVar1,sel_runModal);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)textFieldTamer:(id)aTamer
{
    id controller = [[HSTextFieldTamerDialogController alloc] initWithContext:[[self document] editObjectDialogContext]];
    [controller runModal];
    [controller release];
}

- (void)addReadyMadeCards:(id)aCards
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aCards];
}

- (void)addQuickShotBackground:(id)aBackground
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aBackground];
}

- (void)addQuickShotGraphicObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)runVideoRecordingPanel:(id)aPanel
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aPanel];
}

- (void)runSoundRecordingPanel:(id)aPanel
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aPanel];
}

- (void)editCardActions:(id)aActions
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aActions];
}

- (void)editStackActions:(id)aActions
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aActions]
    ;
}

- (void)showStackOptionsDialog:(id)aDialog
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aDialog];
}

- (void)showCardOptionsDialog:(id)aDialog
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aDialog];
}

- (void)eraseBackground:(id)aBackground
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aBackground];
}

- (void)importBackground:(id)aBackground
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aBackground]
    ;
}

- (void)showYouTubeDialog:(id)aDialog
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aDialog];
}

- (void)captureImage:(id)aImage
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aImage];
}

- (void)addGraphicObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject]
    ;
}

- (void)addGraphic:(id)aGraphic
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aGraphic];
}

- (void)addWebCamObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addLiveVideoObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addSoundObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addMediaObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addMovieComboObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addSoundComboObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addWebObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)importText:(id)aText
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aText];
}

- (void)addTextObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)addButtonObject:(id)aObject
{
    [[self document] performActionThatRequiresSwitchToEditMode:_cmd sender:aObject];
}

- (void)HSDependentPlayerWindowController_HSUIModeSettingsDidChangeNotification:(id)aNotification
{
    if ([self document] != nil) {
        if ([[self window] isVisible]) {
            [HSEditorWindowController validateToolbarVisibility:[[self toolbarController] toolbar]];
            [self setBottomToolbarVisible:[[[HSUI sharedUI] settingsForKey:HSUIModeIsBottomToolbarShown] boolValue]];
        }
    }
}

- (BOOL)supportsMinimalWindowMode
{
    return YES;
}

- (void)windowControllerDidBindToWindowInModeSwitcher:(id)aSwitcher
{
    [[self selectionController] setStackController:[[self document] stackView]];
    [super windowControllerDidBindToWindowInModeSwitcher:aSwitcher];
}

- (void)windowControllerWillUnbindFromWindowInModeSwitcher:(id)aSwitcher
{
    [[self selectionController] setStackController:nil];
}

- (id)stackView
{
    return [[self selectionController] stackController];
}

- (id)selectionController
{
    return [[self document] selectionController];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c0e2b @ 001c0e2b, 175 bytes * /

void FUN_001c0e2b(HSDependentPlayerWindowController *self,SEL _cmd,id hyperWindowDidToggleToolbar)

{
  undefined4 uVar1;
  undefined *self_00;
  id self_01;
  id pvVar2;
  
  self_01 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  self_00 = cls_NSNumber;
  uVar1 = *(undefined4 *)PTR_0033612c;
  pvVar2 = _objc_msgSend(self,sel_toolbarController);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolbar);
  pvVar2 = _objc_msgSend(pvVar2,sel_isVisible);
  pvVar2 = _objc_msgSend(self_00,sel_numberWithBool_,(uint)pvVar2 & 0xff);
  _objc_msgSend(self_01,sel_setSettings_forKey_,pvVar2,uVar1);
  return;
}

*/
- (void)hyperWindowDidToggleToolbar:(id)aToolbar
{
    [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:[[[self toolbarController] toolbar] isVisible]] forKey:HSUIModeIsToolbarShown];
}

- (void)didBindToModelOnLoad
{
    [super didBindToModelOnLoad];
    [HSEditorWindowController validateToolbarVisibility:[[self toolbarController] toolbar]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSDependentPlayerWindowController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSDependentPlayerWindowController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
}

- (void)activateOnLoad
{

}

- (void)handleWindowDidLoad
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c1024 @ 001c1024, 125 bytes * /

void FUN_001c1024(HSDependentPlayerWindowController *self,SEL _cmd)

{
  HSDependentPlayerWindowController *local_14;
  undefined *local_10;
  
  _objc_msgSend(*(id *)(self->super_HSPlayerInEditorWindowController + 0x34),sel_retain);
  _objc_msgSend(*(id *)(self->super_HSPlayerInEditorWindowController + 0x34),
                sel_removeFromSuperviewWithoutNeedingDisplay);
  _objc_msgSend(self,sel_setWindow_,0);
  local_14 = self;
  local_10 = PTR_s_HSPlayerInEditorWindowController_00353810;
  _objc_msgSendSuper(&local_14,sel_windowDidLoad);
  return;
}

*/
- (void)windowDidLoad
{
    [_playerView retain];
    [_playerView removeFromSuperviewWithoutNeedingDisplay];
    [self setWindow:nil];
    [super windowDidLoad];
}

- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c10a1 @ 001c10a1, 226 bytes * /

id FUN_001c10a1(HSDependentPlayerWindowController *self,SEL _cmd,id modeSwitcherView)

{
  HSDependentPlayerWindowController *pHVar1;
  id pvVar2;
  SEL op;
  
  pHVar1 = _objc_msgSend(modeSwitcherView,sel_previousModeController);
  if (pHVar1 == self) {
    pvVar2 = _objc_msgSend(modeSwitcherView,sel_activeModeController);
    pvVar2 = _objc_msgSend(pvVar2,sel_ownsScrollViewForModeSwitcherViewEmbedding);
    op = sel_cardView;
    if ((char)pvVar2 != '\0') goto LAB_001c1176;
  }
  pvVar2 = _objc_msgSend(modeSwitcherView,sel_previousModeController);
  pvVar2 = _objc_msgSend(pvVar2,sel_ownsScrollViewForModeSwitcherViewEmbedding);
  if (((char)pvVar2 == '\0') ||
     (pHVar1 = _objc_msgSend(modeSwitcherView,sel_activeModeController), op = sel_cardView,
     pHVar1 != self)) {
    pvVar2 = _objc_msgSend(self,sel_document);
    self = _objc_msgSend(pvVar2,sel_editorWindowController);
    op = sel_modeSwitcherView_;
  }
LAB_001c1176:
  pvVar2 = _objc_msgSend(self,op);
  return pvVar2;
}

*/
- (id)modeSwitcherView:(id)aView
{
    if ([aView previousModeController] == self && [[aView activeModeController] ownsScrollViewForModeSwitcherViewEmbedding]) {
        return [self cardView];
    }
    if ([[aView previousModeController] ownsScrollViewForModeSwitcherViewEmbedding] && [aView activeModeController] == self) {
        return [self cardView];
    }
    return [[[self document] editorWindowController] modeSwitcherView:aView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c1183 @ 001c1183, 283 bytes * /

void FUN_001c1183(HSDependentPlayerWindowController *self,SEL _cmd)

{
  id pvVar1;
  HSDependentPlayerWindowController *pHVar2;
  HSDependentPlayerWindowController *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_,self);
  _objc_msgSend(*(id *)(self->super_HSPlayerInEditorWindowController + 0x34),sel_autorelease);
  _objc_msgSend(self->_dummyUndoManager,sel_release);
  self->_bottomAreaTintedView = (id)0x0;
  self->_mainAreaTintedView = (id)0x0;
  self->_workAreaView = (id)0x0;
  _objc_msgSend(self->_stackTextProvider,sel_release);
  pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
  pHVar2 = _objc_msgSend(pvVar1,sel_dataProvider);
  if (pHVar2 == self) {
    pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
    _objc_msgSend(pvVar1,sel_setDataProvider_,0);
  }
  local_14 = self;
  local_10 = PTR_s_HSPlayerInEditorWindowController_00353810;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playerView autorelease];
    [_dummyUndoManager release];
    _bottomAreaTintedView = nil;
    _mainAreaTintedView = nil;
    _workAreaView = nil;
    [_stackTextProvider release];
    if ([[HSCommentsAndAttributionsPaletteController sharedInstance] dataProvider] == self) {
        [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:nil];
    }
    [super dealloc];
}

- (id)initWithWindow:(id)aWindow
{
    id self_00;

    self = [super initWithWindow:aWindow];
    if (self != nil) {
        self_00 = [NSUndoManager new];
        _dummyUndoManager = self_00;
        [self_00 disableUndoRegistration];
    }
    return self;
}

- (void)cardViewDidChangeZoomFactor:(id)aNotification
{
    [_statusbarController setZoomFactor:[[aNotification object] zoomFactor]];
}

- (void)fitInWindow:(id)aSender
{
    [[self cardView] fitInWindow];
}

- (NSRect)frameForDisplayingPause
{
    if (_mainAreaTintedView != nil) {
        return [_mainAreaTintedView frame];
    }
    return NSZeroRect;
}

- (id)statusbarController
{
    return _statusbarController;
}

- (void)textFieldTamerDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aDialog autorelease];
}

- (void)zoomFactorDidChange:(id)aSlider
{
    CGFloat target = [HSEditorZoomController zoomFactorValueFrom:aSlider];
    CGFloat current = [[self cardView] zoomFactor];
    if (fabsf(target - current) <= MAX(fabsf(target) != 0 ? fabsf(target) : 1.0f, fabsf(current) != 0 ? fabsf(current) : 1.0f) * 0.0005) {
        [aSlider setFloatValue:HSLinearValueForSliderFromNonLinear(aSlider, current)];
    } else {
        [[self cardView] zoomToFactor:target];
    }
}

- (void)zoomIn:(id)aSender
{
    [[self cardView] zoomIn];
}

- (void)zoomOut:(id)aSender
{
    [[self cardView] zoomOut];
}

- (void)zoomToActualSize:(id)aSender
{
    [[self cardView] zoomToActualSize];
}

- (void)zoomToMaxScaleFactor:(id)aSender
{
    [[self cardView] zoomToFactor:[HSEditorZoomController maxZoomFactor]];
}

- (void)zoomToMinScaleFactor:(id)aSender
{
    [[self cardView] zoomToFactor:[HSEditorZoomController minZoomFactor]];
}

@end

