#import "HSImportDialogController.h"
static id sDAT_003429dc;

static id sDAT_003429dc;


@implementation HSImportDialogController

/* i386 ivar offsets: _dialogType=0x28, _paneViewControllerClasses=0x2c, _paneViewControllers=0x30, _modalDelegate=0x34, _didEndSelector=0x38, _tabTitlesControl=0x3c, _tabView=0x40, _accessoryViewContainer=0x44, _defaultButtonTitle=0x48, _defaultButton=0x4c, _cancelButton=0x50, _currentPaneViewController=0x54, _hyperDocument=0x58, _isObjectTypeOptionsDisabled=0x5c, _isObjectOptionsDisabled=0x5d, _captureImageButtonEnabled=0x5e, _helpTopicKey=0x60, _dialogInterfaceOptions=0x64, _options=0x68 */

+ (id)defaultButtonTitleForObject:(id)aObject
{
    id self_00;
    id pcVar3;
    BOOL pvVar1_3;

    if (![aObject implementsHyperInterface:@protocol(HSButtonObjectAttributes)]) {
        if (![aObject implementsHyperInterface:@protocol(HSCardAttributes)]) {
            pvVar1_3 = [aObject implementsHyperInterface:@protocol(HSStackAttributes)];
            self_00 = [HSExecutableResourceProvider sharedInstance];
            if (!pvVar1_3) {
                pcVar3 = @"Add to Object";
            }
            else {
                pcVar3 = @"Add to Stack";
            }
        }
        else {
            self_00 = [HSExecutableResourceProvider sharedInstance];
            pcVar3 = @"Add to Card";
        }
    }
    else {
        self_00 = [HSExecutableResourceProvider sharedInstance];
        pcVar3 = @"Add to Button";
    }
    return [self_00 localizedStringForKey:pcVar3 value:@"" table:@"Dialogs"];
}

+ (void)registerPaneViewController:(Class)aController withIdentifier:(id)aIdentifier
{
    id self_00;

    if ((aController != Nil) && (aIdentifier != nil)) {
        if ([aController conformsToProtocol:@protocol(HSImportDialogPaneViewController)]) {
            if (sDAT_003429dc == nil) {
                sDAT_003429dc = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            self_00 = [sDAT_003429dc objectForKey:aIdentifier];
            if (self_00 == nil) {
                self_00 = [[NSMutableArray allocWithZone:[sDAT_003429dc zone]] initWithCapacity:0];
                [sDAT_003429dc setObject:self_00 forKey:aIdentifier];
                [self_00 release];
            }
            [self_00 addObject:[NSValue valueWithPointer:aController]];
        }
    }
}

- (void)restrictionPaneDidChange:(id)aChange
{
    [self updatePanels];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    [self validateUIElements];
}

- (void)gridControlSelectionDidChange:(id)aChange
{
    [self validateUIElements];
}

- (void)validateUIElements
{
    [_defaultButton setEnabled:[_currentPaneViewController isObjectValid]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b7021 @ 001b7021, 467 bytes * /

void FUN_001b7021(HSImportDialogController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  id local_1c;
  
  self_00 = _objc_msgSend(self,sel_paneViewControllers);
  pvVar1 = _objc_msgSend(self->_tabTitlesControl,sel_selectedSegment);
  if (pvVar1 == (id)0xffffffff) {
    local_1c = (id)0x0;
  }
  else {
    local_1c = _objc_msgSend(self->_tabTitlesControl,sel_selectedSegment);
  }
  pvVar4 = local_1c;
  pvVar1 = _objc_msgSend(self_00,sel_objectAtIndex_,local_1c);
  pvVar2 = _objc_msgSend(pvVar1,sel_isPaneValid);
  self_01 = _objc_msgSend(self_00,sel_objectEnumerator);
  pvVar1 = (id)0x0;
  if ((char)pvVar2 != '\0') {
    pvVar1 = local_1c;
  }
  pvVar2 = _objc_msgSend(self_01,sel_nextObject,pvVar4);
  pvVar4 = self->_tabTitlesControl;
  while (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(self_00,sel_indexOfObject_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_isPaneValid);
    _objc_msgSend(pvVar4,sel_setEnabled_forSegment_,(int)(char)pvVar2,pvVar3);
    pvVar4 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar1);
    pvVar4 = _objc_msgSend(pvVar4,sel_isPaneValid);
    pvVar1 = (id)((int)pvVar1 + (uint)((char)pvVar4 == '\0'));
    pvVar2 = _objc_msgSend(self_01,sel_nextObject);
    pvVar4 = self->_tabTitlesControl;
  }
  _objc_msgSend(pvVar4,sel_setSelectedSegment_,pvVar1);
  _objc_msgSend(self,sel_changeSelectedPane_,self->_tabTitlesControl);
  return;
}

*/
- (void)updatePanels
{
    NSArray *panes = [self paneViewControllers];
    NSInteger selected = ([_tabTitlesControl selectedSegment] == -1) ? 0 : [_tabTitlesControl selectedSegment];
    NSUInteger index = [[panes objectAtIndex:selected] isPaneValid] ? (NSUInteger)selected : 0;
    for (id pane in panes) {
        [_tabTitlesControl setEnabled:[pane isPaneValid] forSegment:[panes indexOfObject:pane]];
        if (![[panes objectAtIndex:index] isPaneValid]) {
            index++;
        }
    }
    [_tabTitlesControl setSelectedSegment:index];
    [self changeSelectedPane:_tabTitlesControl];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b7716 @ 001b7716, 451 bytes * /

void FUN_001b7716(HSImportDialogController *self,SEL _cmd)

{
  id self_00;
  float fVar1;
  undefined1 local_5c [8];
  float local_54;
  undefined4 local_50;
  undefined1 local_4c [8];
  float local_44;
  undefined1 local_3c [8];
  float local_34;
  undefined1 local_2c [4];
  undefined4 local_28;
  undefined1 local_1c [8];
  float local_14;
  
  _objc_msgSend(self->_defaultButton,sel_setTitle_,self->_defaultButtonTitle);
  _objc_msgSend(self->_defaultButton,sel_sizeToFit);
  _objc_msgSend_stret(local_5c,self->_defaultButton,sel_frame);
  _objc_msgSend(self->_defaultButton,sel_setFrameSize_,local_54 + 12.0,local_50);
  self_00 = _objc_msgSend(self->_defaultButton,sel_superview);
  _objc_msgSend_stret(local_4c,self_00,sel_bounds);
  _objc_msgSend_stret(local_3c,self->_defaultButton,sel_frame);
  _objc_msgSend_stret(local_2c,self->_defaultButton,sel_frame);
  fVar1 = local_44 - (local_34 + 12.0);
  _objc_msgSend_stret(local_1c,self->_cancelButton,sel_frame);
  _objc_msgSend(self->_defaultButton,sel_setFrameOrigin_,fVar1,local_28);
  _objc_msgSend(self->_cancelButton,sel_setFrameOrigin_,fVar1 - local_14,local_28);
  return;
}

*/
- (void)adjustDefaultAndCancelButtons
{
    [_defaultButton setTitle:_defaultButtonTitle];
    [_defaultButton sizeToFit];
    NSRect frame = [_defaultButton frame];
    [_defaultButton setFrameSize:NSMakeSize(frame.size.width + 12.0, frame.size.height)];
    NSRect bounds = [[_defaultButton superview] bounds];
    CGFloat x = bounds.size.width - ([_defaultButton frame].size.width + 12.0);
    CGFloat y = [_defaultButton frame].origin.y;
    NSRect cancelFrame = [_cancelButton frame];
    [_defaultButton setFrameOrigin:NSMakePoint(x, y)];
    [_cancelButton setFrameOrigin:NSMakePoint(x - cancelFrame.size.width, y)];
}

- (id)defaultButtonTitle
{
    return _defaultButtonTitle;
}

- (void)setDefaultButtonTitle:(id)aTitle
{
    if (_defaultButtonTitle != aTitle) {
        [_defaultButtonTitle release];
        _defaultButtonTitle = [aTitle copy];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b6e11 @ 001b6e11, 453 bytes * /

id FUN_001b6e11(HSImportDialogController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = self->_paneViewControllers;
  if (pvVar1 == (id)0x0) {
    pvVar1 = self->_paneViewControllerClasses;
    if ((pvVar1 == (id)0x0) && (self->_dialogType != (id)0x0)) {
      pvVar1 = _objc_msgSend(DAT_003429dc,sel_objectForKey_,self->_dialogType);
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    while( true ) {
      pvVar3 = _objc_msgSend(pvVar1,sel_nextObject);
      if (pvVar3 == (id)0x0) break;
      pvVar3 = _objc_msgSend(pvVar3,sel_pointerValue);
      pvVar3 = _objc_msgSend(pvVar3,sel_alloc);
      pvVar3 = _objc_msgSend(pvVar3,sel_init);
      self_00 = cls_NSMutableArray;
      if (pvVar3 != (id)0x0) {
        pvVar2 = self->_paneViewControllers;
        if (pvVar2 == (id)0x0) {
          pvVar2 = _objc_msgSend(self,sel_zone);
          pvVar2 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar2);
          pvVar2 = _objc_msgSend(pvVar2,sel_initWithCapacity_,0);
          self->_paneViewControllers = pvVar2;
        }
        _objc_msgSend(pvVar2,sel_addObject_,pvVar3);
        pvVar2 = _objc_msgSend(self,sel_isObjectOptionsDisabled);
        _objc_msgSend(pvVar3,sel_setObjectOptionsDisabled_,(int)(char)pvVar2);
        _objc_msgSend(pvVar3,sel_setupDialogInterfaceWithOptions_,self->_dialogInterfaceOptions);
      }
      _objc_msgSend(pvVar3,sel_release);
    }
    _objc_msgSend(self->_paneViewControllers,sel_sortUsingSelector_,
                  sel_importDialogControllerPaneCompare_);
    pvVar1 = self->_paneViewControllers;
  }
  return pvVar1;
}

*/
- (id)paneViewControllers
{
    if (_paneViewControllers == nil) {
        NSArray *classes = _paneViewControllerClasses;
        if (classes == nil && _dialogType != nil) {
            classes = [sDAT_003429dc objectForKey:_dialogType];
        }
        for (NSValue *value in classes) {
            id pane = [[(Class)[value pointerValue] alloc] init];
            if (pane != nil) {
                if (_paneViewControllers == nil) {
                    _paneViewControllers = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
                }
                [_paneViewControllers addObject:pane];
                [pane setObjectOptionsDisabled:[self isObjectOptionsDisabled]];
                [pane setupDialogInterfaceWithOptions:_dialogInterfaceOptions];
            }
            [pane release];
        }
        [_paneViewControllers sortUsingSelector:@selector(importDialogControllerPaneCompare:)];
    }
    return _paneViewControllers;
}

- (BOOL)captureImageButtonEnabled
{
    return _captureImageButtonEnabled;
}

- (void)setCaptureImageButtonEnabled:(BOOL)aEnabled
{
    _captureImageButtonEnabled = aEnabled;
}

- (id)options
{
    return _options;
}

- (void)setOptions:(id)aOptions
{
    if (_options != aOptions) {
        [_options release];
        _options = [aOptions retain];
    }
}

- (void)setHelpTopicKey:(id)aKey
{
    if (![_helpTopicKey isEqualToString:aKey]) {
        [_helpTopicKey release];
        _helpTopicKey = [aKey retain];
    }
}

- (id)helpTopicKey
{
    id pvVar1;

    pvVar1 = _helpTopicKey;
    if (pvVar1 == nil) {
        pvVar1 = [_currentPaneViewController helpTopicKey];
    }
    return pvVar1;
}

- (void)setObjectOptionsDisabled:(BOOL)aDisabled
{
    _isObjectOptionsDisabled = aDisabled;
}

- (BOOL)isObjectOptionsDisabled
{
    return _isObjectOptionsDisabled;
}

- (void)showHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:[self helpTopicKey]];
}

- (id)hyperDocument
{
    return _hyperDocument;
}

- (void)setHyperDocument:(id)aDocument
{
    _hyperDocument = aDocument;
}

- (id)dialogUserOptions
{
    id self_00;

    self_00 = [_currentPaneViewController paneUserOptions];
    if (_currentPaneViewController != nil) {
        [self_00 setValue:[_currentPaneViewController paneIdentifier] forKey:@"HSImportDialogOptionsSourceIdentifier"];
    }
    return self_00;
}

- (id)fileDisplayName
{
    return [_currentPaneViewController paneFileDisplayName];
}

- (id)fileName
{
    return [_currentPaneViewController paneFilePath];
}

- (id)dialogType
{
    return _dialogType;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b78d9 @ 001b78d9, 510 bytes * /

void FUN_001b78d9(HSImportDialogController *self,SEL _cmd,id changeSelectedPane)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  undefined4 *puVar4;
  undefined1 local_24 [20];
  
  puVar4 = (undefined4 *)&stack0xffffffb4;
  pvVar1 = _objc_msgSend(self->_tabTitlesControl,sel_selectedSegment);
  if (-1 < (int)pvVar1) {
    pvVar2 = _objc_msgSend(self->_paneViewControllers,sel_count);
    if ((int)pvVar1 < (int)pvVar2) {
      _objc_msgSend(self->_currentPaneViewController,sel_willUnmountFromDialogController_);
      pvVar1 = _objc_msgSend(self,sel_paneViewControllers);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_);
      pvVar2 = _objc_msgSend(pvVar1,sel_paneView);
      _objc_msgSend(pvVar1,sel_willMountToDialogController_);
      self_00 = _objc_msgSend(self->_tabView,sel_tabViewItemAtIndex_);
      pvVar3 = _objc_msgSend(self_00,sel_view);
      if (pvVar3 != pvVar2) {
        _objc_msgSend(self_00,sel_setView_);
      }
      _objc_msgSend(self->_tabView,sel_selectTabViewItemAtIndex_);
      pvVar2 = _objc_msgSend(self->_currentPaneViewController,sel_paneAccessoryView);
      _objc_msgSend(pvVar2,sel_removeFromSuperview);
      self->_currentPaneViewController = pvVar1;
      pvVar1 = _objc_msgSend(pvVar1,sel_paneAccessoryView);
      if (pvVar1 != (id)0x0) {
        _objc_msgSend_stret(local_24,self->_accessoryViewContainer,sel_bounds);
        puVar4 = (undefined4 *)&stack0xffffffb0;
        _objc_msgSend(pvVar1,sel_setFrame_);
        _objc_msgSend(self->_accessoryViewContainer,sel_addSubview_);
      }
      puVar4[1] = sel_validateUIElements;
      *puVar4 = self;
      puVar4[-1] = 0x1b7acf;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
    }
  }
  return;
}

*/
- (void)changeSelectedPane:(id)aPane
{
    NSInteger index = [_tabTitlesControl selectedSegment];
    if (index < 0 || index >= (NSInteger)[_paneViewControllers count]) {
        return;
    }
    [_currentPaneViewController willUnmountFromDialogController:self];
    id pane = [[self paneViewControllers] objectAtIndex:index];
    NSView *paneView = [pane paneView];
    [pane willMountToDialogController:self];
    NSTabViewItem *item = [_tabView tabViewItemAtIndex:index];
    if ([item view] != paneView) {
        [item setView:paneView];
    }
    [_tabView selectTabViewItemAtIndex:index];
    [[_currentPaneViewController paneAccessoryView] removeFromSuperview];
    _currentPaneViewController = pane;
    NSView *accessoryView = [pane paneAccessoryView];
    if (accessoryView != nil) {
        [accessoryView setFrame:[_accessoryViewContainer bounds]];
        [_accessoryViewContainer addSubview:accessoryView];
    }
    [self validateUIElements];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b6b06 @ 001b6b06, 278 bytes * /

void FUN_001b6b06(HSImportDialogController *self,SEL _cmd,id addToCard)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  undefined4 uVar5;
  
  puVar4 = sel_paneDialogWillClose;
  _objc_msgSend(self->_paneViewControllers,sel_makeObjectsPerformSelector_,sel_paneDialogWillClose);
  puVar1 = PTR_00336058;
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow);
  pvVar3 = _objc_msgSend(self,sel_window);
  if (pvVar2 == pvVar3) {
    pvVar2 = *(id *)puVar1;
    uVar5 = 1;
    op = sel_stopModalWithCode_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_window,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_isSheet);
    if ((char)pvVar2 == '\0') {
      return;
    }
    pvVar2 = *(id *)puVar1;
    pvVar3 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_endSheet_returnCode_,pvVar3,1);
    pvVar2 = _objc_msgSend(self,sel_window);
    uVar5 = 0;
    op = sel_orderOut_;
  }
  _objc_msgSend(pvVar2,op,uVar5);
  return;
}

*/
- (void)addToCard:(id)aCard
{
    [_paneViewControllers makeObjectsPerformSelector:@selector(paneDialogWillClose)];
    if ([NSApp modalWindow] == [self window]) {
        [NSApp stopModalWithCode:1];
    }
    else if ([[self window] isSheet]) {
        [NSApp endSheet:[self window] returnCode:1];
        [[self window] orderOut:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b69d6 @ 001b69d6, 304 bytes * /

void FUN_001b69d6(HSImportDialogController *self,SEL _cmd,id cancel)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  _objc_msgSend(self->_paneViewControllers,sel_makeObjectsPerformSelector_,sel_paneDialogWillCancel)
  ;
  puVar4 = sel_paneDialogWillClose;
  _objc_msgSend(self->_paneViewControllers,sel_makeObjectsPerformSelector_,sel_paneDialogWillClose);
  puVar1 = PTR_00336058;
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow);
  pvVar3 = _objc_msgSend(self,sel_window);
  if (pvVar2 == pvVar3) {
    pvVar2 = *(id *)puVar1;
    op = sel_stopModalWithCode_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_window,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_isSheet);
    if ((char)pvVar2 == '\0') {
      return;
    }
    pvVar2 = *(id *)puVar1;
    pvVar3 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_endSheet_returnCode_,pvVar3,0);
    pvVar2 = _objc_msgSend(self,sel_window);
    op = sel_orderOut_;
  }
  _objc_msgSend(pvVar2,op,0);
  return;
}

*/
- (void)cancel:(id)aCancel
{
    [_paneViewControllers makeObjectsPerformSelector:@selector(paneDialogWillCancel)];
    [_paneViewControllers makeObjectsPerformSelector:@selector(paneDialogWillClose)];
    if ([NSApp modalWindow] == [self window]) {
        [NSApp stopModalWithCode:0];
    }
    else if ([[self window] isSheet]) {
        [NSApp endSheet:[self window] returnCode:0];
        [[self window] orderOut:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b6844 @ 001b6844, 402 bytes * /

void FUN_001b6844(HSImportDialogController *self,SEL _cmd,id sheetDidEnd,int returnCode,
                 void *contextInfo)

{
  undefined *self_00;
  id pvVar1;
  void **ppvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  void *local_18;
  int local_14;
  HSImportDialogController *local_10;
  
  local_10 = self;
  local_14 = returnCode;
  local_18 = contextInfo;
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  uVar3 = *(undefined4 *)PTR_003364e0;
  uVar4 = 0;
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,local_10,uVar3,0);
  ppvVar2 = (void **)local_10->_didEndSelector;
  pvVar1 = _objc_msgSend(local_10->_modalDelegate,sel_respondsToSelector_,ppvVar2);
  self_00 = cls_NSInvocation;
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(local_10->_modalDelegate,sel_methodSignatureForSelector_,
                           local_10->_didEndSelector,uVar3,uVar4);
    pvVar1 = _objc_msgSend(self_00,sel_invocationWithMethodSignature_,pvVar1);
    _objc_msgSend(pvVar1,sel_setTarget_,local_10->_modalDelegate);
    _objc_msgSend(pvVar1,sel_setSelector_,local_10->_didEndSelector);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_10,2);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_14,3);
    ppvVar2 = &local_18;
    uVar3 = 4;
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,ppvVar2,4);
    _objc_msgSend(pvVar1,sel_invoke);
  }
  _objc_msgSend(local_10,sel_autorelease,ppvVar2,uVar3,uVar4);
  return;
}

*/
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    HSImportDialogController *controller = self;
    NSInteger returnCode = aCode;
    void *contextInfo = aInfo;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMediaLibraryAccessDidChangeNotification object:nil];
    if ([_modalDelegate respondsToSelector:_didEndSelector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_modalDelegate methodSignatureForSelector:_didEndSelector]];
        [invocation setTarget:_modalDelegate];
        [invocation setSelector:_didEndSelector];
        [invocation setArgument:&controller atIndex:2];
        [invocation setArgument:&returnCode atIndex:3];
        [invocation setArgument:&contextInfo atIndex:4];
        [invocation invoke];
    }
    [self autorelease];
}

- (void)beginSheetForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    id pvVar1;

    _modalDelegate = aDelegate;
    _didEndSelector = aSelector;
    pvVar1 = [self window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restrictionPaneDidChange:) name:HSMediaLibraryAccessDidChangeNotification object:0];
    [_paneViewControllers makeObjectsPerformSelector:@selector(paneDialogWillOpen)];
    [NSApp beginSheet:pvVar1 modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:aInfo];
    [self retain];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b665d @ 001b665d, 239 bytes * /

int FUN_001b665d(HSImportDialogController *self,SEL _cmd)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  
  self_00 = _objc_msgSend(self,sel_window);
  _objc_msgSend(self,sel_adjustDefaultAndCancelButtons);
  pvVar2 = _objc_msgSend(self_00,sel_isSheet);
  puVar1 = PTR_00336058;
  if (((char)pvVar2 == '\0') &&
     (pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow), pvVar2 != self_00)) {
    _objc_msgSend(self,sel_updatePanels);
    _objc_msgSend(self->_paneViewControllers,sel_makeObjectsPerformSelector_,sel_paneDialogWillOpen)
    ;
    pvVar2 = _objc_msgSend(*(id *)puVar1,sel_runModalForWindow_,self_00);
    _objc_msgSend(self_00,sel_orderOut_,0);
    return (int)pvVar2;
  }
  return 0;
}

*/
- (NSInteger)runModal
{
    NSWindow *window = [self window];
    [self adjustDefaultAndCancelButtons];
    if ([window isSheet] || [NSApp modalWindow] == window) {
        return 0;
    }
    [self updatePanels];
    [_paneViewControllers makeObjectsPerformSelector:@selector(paneDialogWillOpen)];
    NSInteger result = [NSApp runModalForWindow:window];
    [window orderOut:nil];
    return result;
}

- (void)setupDialogInterfaceWithOptions:(id)aOptions
{
    if (_dialogInterfaceOptions != aOptions) {
        [_dialogInterfaceOptions release];
        _dialogInterfaceOptions = [aOptions retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b7ad7 @ 001b7ad7, 1444 bytes * /

void FUN_001b7ad7(HSImportDialogController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_01;
  id pvVar4;
  undefined4 *puVar5;
  undefined4 local_74;
  undefined4 local_70;
  undefined4 local_6c;
  float local_68;
  undefined1 local_64 [16];
  undefined1 local_54 [16];
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  pvVar1 = _objc_msgSend(self,sel_paneViewControllers);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = self->_tabTitlesControl;
    _objc_msgSend(pvVar1,sel_count);
    _objc_msgSend(pvVar2,sel_setSegmentCount_);
  }
  pvVar2 = _objc_msgSend(self->_tabView,sel_numberOfTabViewItems);
  pvVar3 = _objc_msgSend(pvVar1,sel_count);
  if ((int)pvVar2 < (int)pvVar3) {
    do {
      pvVar2 = self->_tabView;
      pvVar3 = _objc_msgSend(cls_NSTabViewItem,sel_new);
      _objc_msgSend(pvVar3,sel_autorelease);
      _objc_msgSend(pvVar2,sel_addTabViewItem_);
      pvVar2 = _objc_msgSend(self->_tabView,sel_numberOfTabViewItems);
      pvVar3 = _objc_msgSend(pvVar1,sel_count);
    } while ((int)pvVar2 < (int)pvVar3);
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar3 = (id)0x0;
    do {
      self_01 = _objc_msgSend(pvVar1,sel_objectAtIndex_);
      pvVar4 = _objc_msgSend(self_01,sel_paneTitle);
      if (pvVar4 != (id)0x0) {
        pvVar4 = self->_tabTitlesControl;
        _objc_msgSend(self_01,sel_paneTitle);
        _objc_msgSend(pvVar4,sel_setLabel_forSegment_);
      }
      pvVar3 = (id)((int)pvVar3 + 1);
    } while (pvVar3 < pvVar2);
  }
  _objc_msgSend(self->_tabTitlesControl,sel_sizeToFit);
  pvVar1 = self->_tabTitlesControl;
  _objc_msgSend_stret(local_64,pvVar1,sel_frame);
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
  _objc_msgSend_stret(local_54,pvVar2,sel_bounds);
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
  _objc_msgSend_stret(local_44,pvVar2,sel_bounds);
  _objc_msgSend_stret(local_34,self->_tabTitlesControl,sel_frame);
  puVar5 = (undefined4 *)&stack0xffffff44;
  _roundf();
  _objc_msgSend(pvVar1,sel_setFrameOrigin_);
  _objc_msgSend(self,sel_adjustDefaultAndCancelButtons);
  self_00 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_);
  _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setTitle_);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(self->_defaultButton,sel_cell);
  _objc_msgSend(pvVar1,sel_setDefaultButtonCell_);
  pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_);
      if ((char)pvVar1 == '\0') goto LAB_001b8058;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_minSize);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setMinSize_);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(&local_74,pvVar1,sel_frame);
  puVar5 = (undefined4 *)&stack0xffffff40;
  pvVar1 = _objc_msgSend(self,sel_window);
  fStack_18 = local_68 + -240.0;
  local_24 = local_74;
  uStack_20 = local_70;
  local_1c = local_6c;
  _objc_msgSend(pvVar1,sel_setFrame_display_);
LAB_001b8058:
  puVar5[1] = sel_validateUIElements;
  *puVar5 = self;
  puVar5[-1] = 0x1b8070;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)windowDidLoad
{
    NSArray *panes = [self paneViewControllers];
    if ([panes count] != 0) {
        [_tabTitlesControl setSegmentCount:[panes count]];
    }
    while ([_tabView numberOfTabViewItems] < (NSInteger)[panes count]) {
        [_tabView addTabViewItem:[[NSTabViewItem new] autorelease]];
    }
    NSUInteger count = [panes count];
    for (NSUInteger i = 0; i < count; i++) {
        id pane = [panes objectAtIndex:i];
        if ([pane paneTitle] != nil) {
            [_tabTitlesControl setLabel:[pane paneTitle] forSegment:i];
        }
    }
    [_tabTitlesControl sizeToFit];
    CGFloat y = [_tabTitlesControl frame].origin.y;
    NSRect contentBounds = [[[self window] contentView] bounds];
    CGFloat contentWidth = [[[self window] contentView] bounds].size.width;
    CGFloat x = roundf(contentBounds.origin.x + (contentWidth - [_tabTitlesControl frame].size.width) * 0.5);
    [_tabTitlesControl setFrameOrigin:NSMakePoint(x, y)];
    [self adjustDefaultAndCancelButtons];
    [[self window] setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:_dialogType value:@"" table:@"ImportDialogs"]];
    [[self window] setDefaultButtonCell:[_defaultButton cell]];
    if ([_dialogType isEqualToString:@"HSImportDialogControllerTypeSound"] || [_dialogType isEqualToString:@"HSImportDialogControllerTypeMovies"] || [_dialogType isEqualToString:@"HSImportDialogControllerTypeAnimations"]) {
        NSSize minSize = [[self window] minSize];
        [[self window] setMinSize:NSMakeSize(minSize.width, minSize.height - 240.0)];
        NSRect frame = [[self window] frame];
        [[self window] setFrame:NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 240.0) display:YES];
    }
    [self validateUIElements];
}

- (id)initWithPropertyList:(id)aList
{
    return [self initWithPaneViewControllerClasses:[NSArray arrayWithContentsOfFile:aList]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b807b @ 001b807b, 341 bytes * /

id FUN_001b807b(HSImportDialogController *self,SEL _cmd,id initWithPaneViewControllerClasses)

{
  undefined *self_00;
  id self_01;
  id self_02;
  cfstringStruct *pcVar1;
  id pvVar2;
  id pvVar3;
  HSImportDialogController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSWindowController_003536f0;
  pcVar1 = &cfstr_ImportDialogControllerWindow;
  self_01 = _objc_msgSendSuper(&local_1c,sel_initWithWindowNibName_,
                               &cfstr_ImportDialogControllerWindow);
  if (self_01 != (id)0x0) {
    self_02 = _objc_msgSend(initWithPaneViewControllerClasses,sel_objectEnumerator);
    while (pvVar3 = _objc_msgSend(self_02,sel_nextObject,pcVar1), pvVar3 != (id)0x0) {
      pvVar3 = (id)_NSClassFromString(pvVar3);
      pcVar1 = (cfstringStruct *)&DAT_0037dcc4;
      pvVar2 = _objc_msgSend(pvVar3,sel_conformsToProtocol_,&DAT_0037dcc4);
      self_00 = cls_NSMutableArray;
      if ((char)pvVar2 != '\0') {
        pvVar2 = *(id *)((int)self_01 + 0x2c);
        if (pvVar2 == (id)0x0) {
          pvVar2 = _objc_msgSend(self_01,sel_zone,pcVar1);
          pvVar2 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar2);
          pvVar2 = _objc_msgSend(pvVar2,sel_initWithCapacity_,0);
          *(id *)((int)self_01 + 0x2c) = pvVar2;
        }
        pcVar1 = _objc_msgSend(cls_NSValue,sel_valueWithPointer_,pvVar3);
        _objc_msgSend(pvVar2,sel_addObject_,pcVar1);
      }
    }
  }
  return self_01;
}

*/
- (id)initWithPaneViewControllerClasses:(id)aClasses
{
    self = [super initWithWindowNibName:@"ImportDialogControllerWindow"];
    if (self != nil) {
        for (NSString *className in aClasses) {
            Class paneClass = NSClassFromString(className);
            if ([paneClass conformsToProtocol:@protocol(HSImportDialogPaneViewController)]) {
                if (_paneViewControllerClasses == nil) {
                    _paneViewControllerClasses = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
                }
                [_paneViewControllerClasses addObject:[NSValue valueWithPointer:paneClass]];
            }
        }
    }
    return self;
}

- (id)initWithDialogType:(id)aType
{
    self = [super initWithWindowNibName:@"ImportDialogControllerWindow"];
    if (self != nil) {
        _dialogType = [aType retain];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dialogType release];
    [_paneViewControllerClasses release];
    [_currentPaneViewController willUnmountFromDialogController:self];
    [_paneViewControllers release];
    [_helpTopicKey release];
    [_dialogInterfaceOptions release];
    [_defaultButtonTitle release];
    [_options release];
    [super dealloc];
}

@end

@implementation NSObject (HSImportDialogControllerPaneSorting)

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b7580 @ 001b7580, 131 bytes * /

int FUN_001b7580(id self,SEL _cmd,id importDialogControllerPaneCompare)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  
  pvVar1 = _objc_msgSend(self,sel_paneWeight);
  pvVar2 = _objc_msgSend(importDialogControllerPaneCompare,sel_paneWeight);
  if ((int)pvVar2 < (int)pvVar1) {
    iVar3 = 1;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_paneWeight);
    pvVar2 = _objc_msgSend(importDialogControllerPaneCompare,sel_paneWeight);
    iVar3 = -1;
    if ((int)pvVar2 <= (int)pvVar1) {
      iVar3 = 0;
    }
  }
  return iVar3;
}

*/
- (NSInteger)importDialogControllerPaneCompare:(id)aCompare
{
    if ([(id)self paneWeight] > [aCompare paneWeight]) {
        return 1;
    }
    if ([(id)self paneWeight] < [aCompare paneWeight]) {
        return -1;
    }
    return 0;
}

@end

