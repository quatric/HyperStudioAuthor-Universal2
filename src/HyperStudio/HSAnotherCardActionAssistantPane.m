#import "HSAnotherCardActionAssistantPane.h"

@implementation HSAnotherCardActionAssistantPane

/* i386 ivar offsets: _storyboardView=0x78, _containerView=0x7c, _stackDropArea=0x80, _stackNameField=0x84, _storyboardContentView=0x88, _placeholderView=0x8c, _contentView=0x90, _paneMultiApplier=0x94, _previewDocument=0x98, _ignoreActionAttributesChanging=0x9c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e443b @ 000e443b, 262 bytes * /

void FUN_000e443b(HSAnotherCardActionAssistantPane *self,SEL _cmd,id mountContentView)

{
  id pvVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  if (self->_contentView != mountContentView) {
    _objc_msgSend(self->_contentView,sel_removeFromSuperviewWithoutNeedingDisplay);
    _objc_msgSend(self->_contentView,sel_release);
    pvVar1 = _objc_msgSend(mountContentView,sel_retain);
    self->_contentView = pvVar1;
    _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = self->_contentView;
    _objc_msgSend_stret(local_24,self->_containerView,sel_frame);
    _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
    _objc_msgSend(self->_containerView,sel_addSubview_,self->_contentView);
  }
  return;
}

*/
- (void)mountContentView:(id)aView
{
    if (_contentView != aView) {
        [_contentView removeFromSuperviewWithoutNeedingDisplay];
        [_contentView release];
        _contentView = [aView retain];
        [_contentView setFrameOrigin:NSZeroPoint];
        [_contentView setFrameSize:[_containerView frame].size];
        [_containerView addSubview:_contentView];
    }
}

- (void)setPreviewDocument:(id)aDocument
{
    if (_previewDocument != aDocument) {
        [_previewDocument release];
        _previewDocument = [aDocument retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e3a9f @ 000e3a9f, 467 bytes * /

id FUN_000e3a9f(HSAnotherCardActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  undefined4 uVar6;
  
  if (self->_previewDocument != (id)0x0) goto LAB_000e3c61;
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  if (pvVar1 == (id)0x0) goto LAB_000e3c61;
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,pvVar1);
  if ((char)pvVar2 == '\0') goto LAB_000e3c61;
  pvVar3 = _objc_msgSend(cls_HSPlayerDocument,sel_new,pvVar3);
  _objc_msgSend(pvVar3,sel_setSuppressAlerts_,1);
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar1 = _objc_msgSend(pvVar2,sel_hyperFileTypeAtPath_,pvVar1);
  pcVar5 = &cfstr__Stak_;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr__Stak_);
  if ((char)pvVar2 == '\0') {
    pcVar5 = &cfstr_stk;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_stk);
    if ((char)pvVar1 != '\0') goto LAB_000e3bbb;
    pcVar4 = &cfstr_HSDocumentType;
  }
  else {
LAB_000e3bbb:
    pcVar4 = &cfstr_HSNativeDocumentType;
  }
  pvVar1 = _objc_msgSend(self,sel_actionAttributes,pcVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  uVar6 = 0;
  pvVar2 = _objc_msgSend(pvVar3,sel_readFromURL_ofType_error_,pvVar1,pcVar4,0);
  if ((char)pvVar2 != '\0') {
    pvVar1 = pvVar3;
    _objc_msgSend(self,sel_setPreviewDocument_,pvVar3,pcVar4,uVar6);
  }
  _objc_msgSend(pvVar3,sel_release,pvVar1,pcVar4,uVar6);
LAB_000e3c61:
  return self->_previewDocument;
}

*/
- (id)previewDocument
{
    if (_previewDocument == nil) {
        NSString *path = [[[self actionAttributes] URL] path];
        if (path != nil && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            id document = [HSPlayerDocument new];
            [document setSuppressAlerts:YES];
            NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
            NSString *documentType;
            if ([fileType isEqualToString:@"'Stak'"] || [fileType isEqualToString:@"stk"]) {
                documentType = @"HSNativeDocumentType";
            }
            else {
                documentType = @"HSDocumentType";
            }
            if ([document readFromURL:[[self actionAttributes] URL] ofType:documentType error:NULL]) {
                [self setPreviewDocument:document];
            }
            [document release];
        }
    }
    return _previewDocument;
}

- (void)animationDidEnd:(id)aEnd
{
    [self invalidateAnimation];
}

- (void)animationDidStop:(id)aStop
{
    [self invalidateAnimation];
}

- (void)invalidateAnimation
{
    [_storyboardView setInLiveScale:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e39cf @ 000e39cf, 83 bytes * /

void FUN_000e39cf(HSAnotherCardActionAssistantPane *self,SEL _cmd,id validateUIWithNotification)

{
  undefined4 uVar1;
  
  if (self->_ignoreActionAttributesChanging == '\0') {
    uVar1 = 0;
    _objc_msgSend(self,sel_setPreviewDocument_,0);
    if ((self->super).super._userMadeTheDecision == '\0') {
      _objc_msgSend(self,sel_validateUserInterface,uVar1);
    }
  }
  return;
}

*/
- (void)validateUIWithNotification:(id)aNotification
{
    if (!_ignoreActionAttributesChanging) {
        [self setPreviewDocument:nil];
        if (!_userMadeTheDecision) {
            [self validateUserInterface];
        }
    }
}

- (BOOL)canGoToNextPane
{
    return (BOOL)[[[self actionAttributes] queryHyperInterface:@protocol(HSActionValidationStatusAttribute)] isValid];
}

- (id)objectAssistantForNavigationPaneSwitcher:(id)aSwitcher
{
    return [self assistant];
}

- (id)nextPaneForObjectAssistant:(id)aAssistant
{
    id pvVar1;
    id pvVar2;
    id pvVar1_3;

    pvVar1 = [HSTransitionsAssistantPane alloc];
    pvVar2 = [self paneMultiApplier];
    pvVar1_3 = [[pvVar1 initWithActionType:[self actionType] paneMultiApplier:pvVar2] autorelease];
    [pvVar1_3 setActionEvent:[self actionEvent]];
    return pvVar1_3;
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _paneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSActionSetupPaneSwitcher alloc] initWithAssistantSettingsApplier:[self paneMultiApplier] windowNibName:@"ActionPaneSwitcher"];
        _paneSwitcher = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        pvVar1 = _paneSwitcher;
    }
    return pvVar1;
}

- (id)paneMultiApplier
{
    HSAssistantPaneMultiApplier *pHVar3;

    pHVar3 = _paneMultiApplier;
    if (pHVar3 == nil) {
        if ([[self assistant] object] == nil) {
            pHVar3 = _paneMultiApplier;
        }
        else {
            pHVar3 = [[HSAssistantPaneMultiApplier alloc] initWithObject:[[self assistant] object]];
            _paneMultiApplier = pHVar3;
        }
    }
    return pHVar3;
}

- (void)chooseCurrentStack:(id)aStack
{
    [self setPreviewDocument:nil];
    _ignoreActionAttributesChanging = YES;
    [[self anotherCardActionAsssistantApplier] setURL:0];
    _ignoreActionAttributesChanging = NO;
    [self setPreviewDocument:nil];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e3437 @ 000e3437, 645 bytes * /

void FUN_000e3437(HSAnotherCardActionAssistantPane *self,SEL _cmd,id chooseStack)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  _objc_msgSend(pvVar1,sel_setAllowsMultipleSelection_,0);
  pvVar3 = (id)0x0;
  _objc_msgSend(pvVar1,sel_setCanChooseDirectories_,0);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperStudioDocumentsFolder);
  if (pvVar2 != (id)0x0) {
    op = sel_setDirectory_;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,1);
      op = sel_setDirectoryURL_;
    }
    _objc_msgSend(pvVar1,op,pvVar2);
    pvVar3 = pvVar2;
  }
  pvVar3 = _objc_msgSend(cls_HSApplicationController,sel_sharedDocumentController,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_readableFileExtensions);
  pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithArray_,pvVar3);
  _objc_msgSend(pvVar3,sel_removeObject_,&cfstr_key);
  pvVar2 = _objc_msgSend(pvVar1,sel_runModalForTypes_,pvVar3);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(pvVar1,sel_URLs,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_URLs,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
      pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
      pvVar2 = _objc_msgSend(pvVar3,sel_path);
      pvVar2 = _objc_msgSend(pvVar2,sel_stringByDeletingLastPathComponent);
      _objc_msgSend(pvVar1,sel_setHyperStudioDocumentsFolder_,pvVar2);
      self->_ignoreActionAttributesChanging = '\x01';
      pvVar1 = _objc_msgSend(self,sel_anotherCardActionAsssistantApplier);
      _objc_msgSend(pvVar1,sel_setURL_,pvVar3);
      self->_ignoreActionAttributesChanging = '\0';
      _objc_msgSend(self,sel_setPreviewDocument_,0);
      _objc_msgSend(self,sel_validateUserInterface);
    }
  }
  return;
}

*/
- (void)chooseStack:(id)aStack
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder];
    if (folder != nil) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    }
    NSMutableArray *types = [NSMutableArray arrayWithArray:[[HSApplicationController sharedDocumentController] readableFileExtensions]];
    [types removeObject:@"key"];
    [panel setAllowedFileTypes:types];
    if ([panel runModal] == NSModalResponseOK && [[panel URLs] count] != 0) {
        NSURL *url = [[panel URLs] objectAtIndex:0];
        [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[url path] stringByDeletingLastPathComponent]];
        _ignoreActionAttributesChanging = YES;
        [[self anotherCardActionAsssistantApplier] setURL:url];
        _ignoreActionAttributesChanging = NO;
        [self setPreviewDocument:nil];
        [self validateUserInterface];
    }
}

- (void)storyboardSelectionDidChange:(id)aChange
{
    id pvVar1_3;
    NSInteger pvVar2_3;

    pvVar1_3 = [[[_storyboardView selectedHyperObject] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    pvVar2_3 = [[[_storyboardView selectedHyperObject] queryHyperInterface:@protocol(HSCardAttributes)] cardIdOldFileFormat];
    _ignoreActionAttributesChanging = YES;
    [[self anotherCardActionAsssistantApplier] setCardUID:pvVar1_3];
    [[self anotherCardActionAsssistantApplier] setCardID:pvVar2_3];
    _ignoreActionAttributesChanging = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e4541 @ 000e4541, 318 bytes * /

float FUN_000e4541(HSAnotherCardActionAssistantPane *self,SEL _cmd,
                  int storyboardScaleFactorForColumnsCount)

{
  id pvVar1;
  HSAnotherCardActionAssistantPane *self_00;
  id pvVar2;
  float extraout_EDX;
  float fVar3;
  undefined1 local_34 [8];
  float local_2c;
  undefined1 local_24 [12];
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_previewDocument);
  self_00 = self;
  if (pvVar1 != (id)0x0) {
    self_00 = _objc_msgSend(self,sel_previewDocument);
  }
  pvVar1 = _objc_msgSend(self_00,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  pvVar2 = _objc_msgSend(self->_storyboardView,sel_enclosingScrollView);
  pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
  if ((float)pvVar1 <= extraout_EDX) {
    _objc_msgSend_stret(local_24,pvVar2,sel_bounds);
    fVar3 = (local_18 + -40.0) / extraout_EDX;
  }
  else {
    _objc_msgSend_stret(local_34,pvVar2,sel_bounds);
    fVar3 = (local_2c + -75.0) / ((float)pvVar1 * (float)storyboardScaleFactorForColumnsCount);
  }
  return fVar3;
}

*/
- (CGFloat)storyboardScaleFactorForColumnsCount:(NSInteger)aCount
{
    id source = ([self previewDocument] != nil) ? [self previewDocument] : (id)self;
    NSSize cardSize = [[source stack] hyperCardSize];
    NSClipView *clipView = [[_storyboardView enclosingScrollView] contentView];
    if (cardSize.width <= cardSize.height) {
        return (float)(([clipView bounds].size.height - 40.0) / cardSize.height);
    }
    return (float)(([clipView bounds].size.width - 75.0) / (cardSize.width * (float)aCount));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e467f @ 000e467f, 1130 bytes * /

void FUN_000e467f(HSAnotherCardActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  HSAnotherCardActionAssistantPane *self_00;
  id pvVar5;
  id pvVar6;
  double dVar7;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  if ((pvVar1 == (id)0x0) || (pvVar2 = _objc_msgSend(self,sel_previewDocument), pvVar2 != (id)0x0))
  {
    pvVar2 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar2 = _objc_msgSend(pvVar2,sel_currentDocument);
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
      pvVar2 = _objc_msgSend(pvVar2,sel_documents);
      pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
    }
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar2,sel_fileURL);
    }
    pvVar4 = self->_stackNameField;
    if (pvVar1 == (id)0x0) {
      if (pvVar2 == (id)0x0) {
        pcVar3 = &cfstr_empty;
      }
      else {
        pcVar3 = _objc_msgSend(pvVar2,sel_displayName);
      }
      _objc_msgSend(pvVar4,sel_setStringValue_,pcVar3);
      pvVar2 = self->_stackDropArea;
      pvVar1 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(pvVar1,sel_path);
      pvVar2 = _objc_msgSend(pvVar2,sel_lastPathComponent);
      _objc_msgSend(pvVar4,sel_setStringValue_,pvVar2);
      pvVar2 = self->_stackDropArea;
      pvVar4 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
      pvVar1 = _objc_msgSend(pvVar1,sel_path);
      pvVar1 = _objc_msgSend(pvVar4,sel_iconForFile_,pvVar1);
    }
    _objc_msgSend(pvVar2,sel_setImage_,pvVar1);
    pvVar1 = self->_storyboardContentView;
    _objc_msgSend(self,sel_mountContentView_,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_previewDocument);
    self_00 = self;
    if (pvVar2 != (id)0x0) {
      self_00 = _objc_msgSend(self,sel_previewDocument,pvVar1);
    }
    pvVar5 = _objc_msgSend(self_00,sel_stack,pvVar1);
    pvVar1 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_0036cb40);
    pvVar2 = _objc_msgSend(self,sel_actionAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_destinationCardUID);
    pvVar2 = _objc_msgSend(pvVar1,sel_childWithUID_,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    pvVar6 = _objc_msgSend(pvVar1,sel_cardIdOldFileFormat);
    _objc_msgSend(self->_storyboardView,sel_setStack_,pvVar5);
    pvVar1 = self->_storyboardView;
    dVar7 = _objc_msgSend_fpret(self,sel_storyboardScaleFactorForColumnsCount_,2);
    pvVar4 = (id)(float)dVar7;
    _objc_msgSend(pvVar1,sel_setCardScaleFactor_,pvVar4);
    if (((pvVar2 == (id)0x0) && (pvVar6 != (id)0x0)) && (pvVar6 != (id)0x7fffffff)) {
      pvVar1 = _objc_msgSend(pvVar5,sel_hyperEnumerator,pvVar4);
      do {
        pvVar2 = _objc_msgSend(pvVar1,sel_nextObject,pvVar4);
        if (pvVar2 == (id)0x0) goto LAB_000e4aba;
        pvVar5 = _objc_msgSend(pvVar2,sel_cardIdOldFileFormat,pvVar4);
      } while (pvVar5 != pvVar6);
      pvVar1 = self->_storyboardView;
      op = sel_selectHyperObject_;
    }
    else {
      pvVar1 = self->_storyboardView;
      op = sel_selectHyperObject_;
    }
  }
  else {
    pvVar1 = self->_stackNameField;
    pvVar2 = _objc_msgSend(cls_NSString,sel_string);
    _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
    _objc_msgSend(self,sel_mountContentView_,self->_placeholderView);
    pvVar1 = self->_stackDropArea;
    pvVar2 = (id)0x0;
    op = sel_setImage_;
  }
  _objc_msgSend(pvVar1,op,pvVar2);
  pvVar4 = pvVar2;
LAB_000e4aba:
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher,pvVar4);
  _objc_msgSend(pvVar1,sel_validateUserInterface);
  return;
}

*/
- (void)validateUserInterface
{
    NSURL *url = [[self actionAttributes] URL];
    if (url == nil || [self previewDocument] != nil) {
        id document = [[NSDocumentController sharedDocumentController] currentDocument];
        if (document == nil) {
            document = [[[NSDocumentController sharedDocumentController] documents] lastObject];
        }
        if (url == nil) {
            url = [document fileURL];
        }
        if (url == nil) {
            [_stackNameField setStringValue:(document != nil) ? [document displayName] : @""];
            [_stackDropArea setImage:nil];
        }
        else {
            [_stackNameField setStringValue:[[url path] lastPathComponent]];
            [_stackDropArea setImage:[[NSWorkspace sharedWorkspace] iconForFile:[url path]]];
        }
        [self mountContentView:_storyboardContentView];
        id source = ([self previewDocument] != nil) ? [self previewDocument] : (id)self;
        id stack = [source stack];
        id card = [[stack queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:[[self actionAttributes] destinationCardUID]];
        NSInteger cardID = [[self actionAttributes] cardIdOldFileFormat];
        [_storyboardView setStack:stack];
        [_storyboardView setCardScaleFactor:[self storyboardScaleFactorForColumnsCount:2]];
        if (card == nil && cardID != 0 && cardID != NSNotFound) {
            NSEnumerator *enumerator = [stack hyperEnumerator];
            while ((card = [enumerator nextObject]) != nil) {
                if ([card cardIdOldFileFormat] == cardID) {
                    break;
                }
            }
            if (card != nil) {
                [_storyboardView selectHyperObject:card];
            }
        }
        else {
            [_storyboardView selectHyperObject:card];
        }
    }
    else {
        [_stackNameField setStringValue:[NSString string]];
        [self mountContentView:_placeholderView];
        [_stackDropArea setImage:nil];
    }
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (id)helpTopicKey
{
    return @"HSToGo";
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e4b4e @ 000e4b4e, 221 bytes * /

void FUN_000e4b4e(HSAnotherCardActionAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  HSAnotherCardActionAssistantPane *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar1,sel_setApplier_,0);
  _objc_msgSend(self->_storyboardView,sel_setStack_,0);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_003364fc,
                self->_storyboardView);
  _objc_msgSend(self,sel_removeActionAssistantPaneObserver);
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantPane_00350600;
  _objc_msgSendSuper(&local_14,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self navigationPaneSwitcher] setApplier:nil];
    [_storyboardView setStack:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSStoryboardViewDidChangeSelectionNotification object:_storyboardView];
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e4c2b @ 000e4c2b, 528 bytes * /

void FUN_000e4c2b(HSAnotherCardActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  HSAnotherCardActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00350600;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar3 = self->_storyboardView;
  pvVar1 = _objc_msgSend(self,sel_previewDocument);
  pvVar2 = _objc_msgSend(pvVar1,sel_stack);
  _objc_msgSend(pvVar3,sel_setStack_,pvVar2);
  pvVar3 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar3,sel_cardIdOldFileFormat);
  if (pvVar1 == (id)0x7fffffff) {
LAB_000e4d1d:
    pvVar1 = _objc_msgSend(pvVar3,sel_destinationCardUID,pvVar2);
    if (pvVar1 != (id)0x0) goto LAB_000e4d8a;
    pvVar1 = _objc_msgSend(self,sel_anotherCardActionAsssistantApplier);
    pvVar2 = _objc_msgSend(self,sel_card);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
    op = sel_setCardUID_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar3,sel_cardIdOldFileFormat,pvVar2);
    if (pvVar1 == (id)0x0) goto LAB_000e4d1d;
    pvVar1 = _objc_msgSend(self,sel_anotherCardActionAsssistantApplier,pvVar2);
    pvVar2 = _objc_msgSend(pvVar3,sel_cardIdOldFileFormat);
    op = sel_setCardID_;
  }
  _objc_msgSend(pvVar1,op,pvVar2);
LAB_000e4d8a:
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar2);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_storyboardSelectionDidChange_,
                *(undefined4 *)PTR_PTR_003364fc,self->_storyboardView);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  _objc_msgSend(self,sel_validateUserInterface);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036cb2c);
  _objc_msgSend(pvVar3,sel_updateActionValidationStatus);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_storyboardView setStack:[[self previewDocument] stack]];
    id attributes = [self actionAttributes];
    NSInteger cardID = [attributes cardIdOldFileFormat];
    if (cardID != NSNotFound && cardID != 0) {
        [[self anotherCardActionAsssistantApplier] setCardID:cardID];
    }
    else if ([attributes destinationCardUID] == nil) {
        [[self anotherCardActionAsssistantApplier] setCardUID:[[self card] hyperUID]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyboardSelectionDidChange:) name:HSStoryboardViewDidChangeSelectionNotification object:_storyboardView];
    [self addActionAssistantPaneObserver];
    [self validateUserInterface];
    [[attributes queryHyperInterface:@protocol(HSActionValidation)] updateActionValidationStatus];
}

- (id)actionAttribute
{
    return (id)@protocol(HSOtherCardActionAttributes);
}

- (void)updateObjectWithApplier
{
    [super updateObjectWithApplier];
}

- (void)viewDidLoad
{
    id pvVar2_3;

    [super viewDidLoad];
    [_containerView setImage:[NSImage imageNamed:@"Background_Medium"]];
    [_storyboardView setBackgroundColor:[NSColor clearColor]];
    [_storyboardView setAllowMultipleSelection:NO];
    [_storyboardView setAllowEmptySelection:NO];
    [_storyboardView setAllowDragAndDrop:NO];
    pvVar2_3 = [HSCardBorderRenderer new];
    [pvVar2_3 setFillColor:[NSColor redColor]];
    [pvVar2_3 setCardBorderRendererType:@"chooser_Card_"];
    [_storyboardView setCardBorderRenderer:pvVar2_3];
    [pvVar2_3 release];
    [_storyboardView setShouldDrawBadgedIcons:NO];
    [_stackDropArea setDelegate:self];
}

- (id)actionAttributes
{
    return [[self anotherCardActionAsssistantApplier] otherCardActionAttributes];
}

- (id)actionType
{
    return [HSOtherCardAction actionType];
}

- (id)anotherCardActionAsssistantApplier
{
    [[self paneMultiApplier] addApplier:[self applier]];
    return [self applier];
}

- (Class)applierClass
{
    return [HSAnotherCardActionAssistantApplier class];
}

- (void)dealloc
{
    [_paneMultiApplier release];
    [_previewDocument close];
    [_previewDocument release];
    [_contentView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"AnotherCardAssistantPane"];
    return self;
}

@end

@implementation HSAnotherCardActionAssistantApplier

/* i386 ivar offsets: _initialURL=0x30, _initialCardUID=0x34, _initialCardIDOldFileFormat=0x38, _URL=0x3c, _cardUID=0x40, _cardIDOldFileFormat=0x44 */

- (void)setCardID:(NSInteger)aID
{
    if (_cardIDOldFileFormat != aID) {
        _cardIDOldFileFormat = aID;
        [[self otherCardActionAttributes] setCardIdOldFileFormat:_cardIDOldFileFormat];
    }
}

- (void)setCardUID:(id)aUID
{
    if (![_cardUID isEqual:aUID]) {
        [_cardUID release];
        _cardUID = [aUID retain];
        [self disableUndo];
        [[self otherCardActionAttributes] setDestinationCardUID:_cardUID];
        [self enableUndo];
    }
}

- (void)setURL:(id)aURL
{
    if (![_URL isEqual:aURL]) {
        [_URL release];
        _URL = [aURL retain];
        [self disableUndo];
        [[self otherCardActionAttributes] setURL:_URL];
        [self enableUndo];
    }
}

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;

    if ((_initialURL == nil && _URL == nil) || (pvVar1 = [_initialURL isEqual:_URL], pvVar1)) {
        pvVar1 = [super areSettingsEqual];
        if ((pvVar1) && (pvVar1 = [_initialCardUID isEqual:_cardUID], pvVar1)) {
            return _initialCardIDOldFileFormat == _cardIDOldFileFormat;
        }
    }
    return NO;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_URL release];
    _URL = [_initialURL retain];
    [_cardUID release];
    _cardUID = [_initialCardUID retain];
    _cardIDOldFileFormat = _initialCardIDOldFileFormat;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialURL release];
    _initialURL = [_URL retain];
    [_initialCardUID release];
    _initialCardUID = [_cardUID retain];
    _initialCardIDOldFileFormat = _cardIDOldFileFormat;
}

- (void)setInitialSettingsToObject
{
    [[self otherCardActionAttributes] setURL:_initialURL];
    [[self otherCardActionAttributes] setDestinationCardUID:_initialCardUID];
    [[self otherCardActionAttributes] setCardIdOldFileFormat:_initialCardIDOldFileFormat];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self otherCardActionAttributes] setURL:_URL];
    [[self otherCardActionAttributes] setDestinationCardUID:_cardUID];
    [[self otherCardActionAttributes] setCardIdOldFileFormat:_cardIDOldFileFormat];
}

- (void)setUpInitialSettings
{
    id pvVar1_3;
    id pvVar1_7;
    NSInteger pvVar1_10;

    pvVar1_3 = [[[self otherCardActionAttributes] URL] retain];
    _initialURL = pvVar1_3;
    _URL = [pvVar1_3 retain];
    pvVar1_7 = [[[self otherCardActionAttributes] destinationCardUID] retain];
    _initialCardUID = pvVar1_7;
    _cardUID = [pvVar1_7 retain];
    pvVar1_10 = [[self otherCardActionAttributes] cardIdOldFileFormat];
    _initialCardIDOldFileFormat = (int)pvVar1_10;
    _cardIDOldFileFormat = (int)pvVar1_10;
}

- (id)otherCardActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSOtherCardActionAttributes)];
}

- (void)dealloc
{
    [_URL release];
    [_cardUID release];
    [super dealloc];
}

@end

@implementation HSAnotherCardActionAssistantPane (HSDropImageViewDelegate)

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e3e57 @ 000e3e57, 521 bytes * /

void FUN_000e3e57(HSAnotherCardActionAssistantPane *self,SEL _cmd,id hyperImageView,
                 id didAcceptedDropWithDraggingInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(didAcceptedDropWithDraggingInfo,sel_draggingPasteboard);
  puVar4 = PTR_00336414;
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336414);
  pvVar2 = _objc_msgSend(pvVar1,sel_availableTypeFromArray_,pvVar2);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336418);
    pvVar3 = _objc_msgSend(pvVar1,sel_availableTypeFromArray_,pvVar2);
    puVar4 = cls_NSURL;
    op = sel_URLFromPasteboard_;
    if (pvVar3 != (id)0x0) goto LAB_000e3f98;
  }
  else {
    pvVar2 = *(id *)puVar4;
    pvVar1 = _objc_msgSend(pvVar1,sel_propertyListForType_,pvVar2);
    pvVar3 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar3 == (id)0x1) {
      puVar4 = _objc_msgSend(cls_NSURL,sel_alloc,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_lastObject);
      op = sel_initFileURLWithPath_;
LAB_000e3f98:
      pvVar2 = _objc_msgSend(puVar4,op,pvVar1);
      goto LAB_000e3f9d;
    }
  }
  pvVar1 = pvVar2;
  pvVar2 = (id)0x0;
LAB_000e3f9d:
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar1);
  pvVar3 = _objc_msgSend(pvVar2,sel_path);
  pvVar3 = _objc_msgSend(pvVar3,sel_stringByDeletingLastPathComponent);
  _objc_msgSend(pvVar1,sel_setHyperStudioDocumentsFolder_,pvVar3);
  self->_ignoreActionAttributesChanging = '\x01';
  pvVar1 = _objc_msgSend(self,sel_anotherCardActionAsssistantApplier);
  _objc_msgSend(pvVar1,sel_setURL_,pvVar2);
  self->_ignoreActionAttributesChanging = '\0';
  _objc_msgSend(self,sel_setPreviewDocument_,0);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)hyperImageView:(id)aView didAcceptedDropWithDraggingInfo:(id)aInfo
{
    NSPasteboard *pasteboard = [aInfo draggingPasteboard];
    NSURL *url = nil;
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]] != nil) {
        NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
        if ([files count] == 1) {
            url = [[[NSURL alloc] initFileURLWithPath:[files lastObject]] autorelease];
        }
    }
    else if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSURLPboardType]] != nil) {
        url = [NSURL URLFromPasteboard:pasteboard];
    }
    [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[url path] stringByDeletingLastPathComponent]];
    _ignoreActionAttributesChanging = YES;
    [[self anotherCardActionAsssistantApplier] setURL:url];
    _ignoreActionAttributesChanging = NO;
    [self setPreviewDocument:nil];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e3cc3 @ 000e3cc3, 404 bytes * /

uint FUN_000e3cc3(HSAnotherCardActionAssistantPane *self,SEL _cmd,id draggingEntered,
                 id inHyperImageView)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  SEL op;
  
  pvVar2 = _objc_msgSend(draggingEntered,sel_draggingPasteboard);
  puVar1 = PTR_00336414;
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336414);
  pvVar3 = _objc_msgSend(pvVar2,sel_availableTypeFromArray_,pvVar3);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336418);
    pvVar3 = _objc_msgSend(pvVar2,sel_availableTypeFromArray_,pvVar3);
    if (pvVar3 == (id)0x0) {
      return 0;
    }
    self_00 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,pvVar2);
    op = sel_path;
    pvVar3 = pvVar2;
  }
  else {
    pvVar3 = *(id *)puVar1;
    self_00 = _objc_msgSend(pvVar2,sel_propertyListForType_,pvVar3);
    pvVar2 = _objc_msgSend(self_00,sel_count);
    op = sel_lastObject;
    if (pvVar2 != (id)0x1) {
      return 0;
    }
  }
  pvVar2 = _objc_msgSend(self_00,op,pvVar3);
  if (pvVar2 == (id)0x0) {
    return 0;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_pathExtension,pvVar3);
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_stack);
  if ((char)pvVar3 != '\0') {
    return 2;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_stk);
  return (uint)((char)pvVar2 != '\0') * 2;
}

*/
- (NSUInteger)draggingEntered:(id)aEntered inHyperImageView:(id)aView
{
    NSPasteboard *pasteboard = [aEntered draggingPasteboard];
    NSString *path = nil;
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]] != nil) {
        NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
        if ([files count] != 1) {
            return 0;
        }
        path = [files lastObject];
    }
    else {
        if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSURLPboardType]] == nil) {
            return 0;
        }
        path = [[NSURL URLFromPasteboard:pasteboard] path];
    }
    if (path == nil) {
        return 0;
    }
    NSString *extension = [path pathExtension];
    if ([extension isEqualToString:@"stack"]) {
        return 2;
    }
    return [extension isEqualToString:@"stk"] ? 2 : 0;
}

@end

