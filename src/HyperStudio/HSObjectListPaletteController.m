#import "HSObjectListPaletteController.h"

@implementation HSObjectListPaletteController

/* i386 ivar offsets: _containerView=0x10, _dataProvider=0x14, _needsDataProvider=0x18, _objectListController=0x1c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d757f @ 000d757f, 94 bytes * /

void FUN_000d757f(HSObjectListPaletteController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPaletteVisible);
  op = sel_hidePalette;
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_showCoachingHintIfNeeded);
    op = sel_showPalette;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)togglePalette
{
    if ([self isPaletteVisible]) {
        [self hidePalette];
    } else {
        [self showCoachingHintIfNeeded];
        [self showPalette];
    }
}

- (void)showCoachingHintIfNeeded
{
    id self_00;
    id pvVar1_2;
    id pvVar1_8;
    id pvVar3_4;
    id pvVar4_2;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    pvVar1_2 = [[self_00 objectAssistant] currentPane];
    if ([pvVar1_2 isKindOfClass:(NSClassFromString(@"HSObjectAssistantNavigationController"))]) {
        if ([[pvVar1_2 topViewController] isKindOfClass:(NSClassFromString(@"HSObjectsBrowserCoachingPane"))]) {
            return;
        }
    }
    if (![self_00 isLocked]) {
        if (![[HSCoachingHelpManager sharedCoachingHelpManager] dontShowCoachingHintsForKey:[HSObjectsBrowserCoachingPane coachingKey]]) {
            pvVar1_8 = [HSObjectsBrowserCoachingPane new];
            pvVar3_4 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_8];
            pvVar4_2 = [[HSObjectAssistantNullObject alloc] initWithRootViewController:pvVar3_4 supportsSettingsOnTheSpotMode:YES];
            [self_00 setSelectedInModelObjectAndBringAssistantToFront:pvVar4_2];
            [pvVar4_2 release];
            [pvVar1_8 release];
            [pvVar3_4 release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d78dc @ 000d78dc, 183 bytes * /

NSRect * FUN_000d78dc(NSRect *__return_storage_ptr__,HSObjectListPaletteController *self,SEL _cmd,
                     id windowWillUseStandardFrame,NSRect defaultFrame)

{
  NSRect *pNVar1;
  NSRect *extraout_EAX;
  float local_2c;
  float local_28;
  float local_24 [2];
  float local_1c;
  
  local_28 = defaultFrame.size.width;
  local_2c = defaultFrame.origin.x;
  pNVar1 = _objc_msgSend(self,sel_window);
  if (pNVar1 == windowWillUseStandardFrame) {
    _objc_msgSend_stret(local_24,windowWillUseStandardFrame,sel_frame);
    local_2c = local_24[0];
    local_28 = local_1c;
    pNVar1 = extraout_EAX;
  }
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = defaultFrame.origin.y;
  (__return_storage_ptr__->size).width = local_28;
  (__return_storage_ptr__->size).height = defaultFrame.size.height;
  return pNVar1;
}

*/
- (NSRect)windowWillUseStandardFrame:(id)aFrame defaultFrame:(NSRect)aFrame2
{
    NSRect frame = aFrame2;
    if ([self window] == aFrame) {
        NSRect windowFrame = [aFrame frame];
        frame.origin.x = windowFrame.origin.x;
        frame.size.width = windowFrame.size.width;
    }
    return frame;
    return (NSRect){0};
}

- (void)mountObjectListController
{
    id pvVar2;
    NSView *pvVar1_2;

    pvVar1_2 = [[self objectListController] view];
    if ((pvVar1_2 != nil) && (_containerView != nil)) {
        pvVar2 = [self objectListController];
        [pvVar2 willMountIntoWindow:[self window]];
        [pvVar1_2 setFrame:[_containerView bounds]];
        [_containerView addSubview:pvVar1_2];
        [_containerView setDelegate:_objectListController];
        [[self objectListController] didMountIntoWindow:[self window]];
    }
}

- (id)objectListController
{
    HSStackObjectListController *pHVar1;

    pHVar1 = _objectListController;
    if (pHVar1 == nil) {
        pHVar1 = [[HSStackObjectListController alloc] init];
        _objectListController = pHVar1;
    }
    return pHVar1;
}

- (void)objectListDataProviderDidChangeTopLevelParent:(id)aParent
{
    [[self objectListController] setTopLevelParent:[_dataProvider objectListTopLevelParent]];
}

- (BOOL)paletteShouldBecomeKeyOnlyWhenNeeded
{
    return NO;
}

- (void)willCloseWindow
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentWindowDidBecomeMainNotification object:0];
    [super willCloseWindow];
    [self setNeedsDataProvider:NO];
}

- (void)didShowWindow
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentWindowDidBecomeMain:) name:HSDocumentWindowDidBecomeMainNotification object:0];
    [self setNeedsDataProvider:YES];
    [super didShowWindow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d7315 @ 000d7315, 453 bytes * /

void FUN_000d7315(HSObjectListPaletteController *self,SEL _cmd,BOOL setNeedsDataProvider)

{
  id pvVar1;
  HSObjectListPaletteController *pHVar2;
  id pvVar3;
  SEL op;
  HSObjectListPaletteController *pHVar4;
  cfstringStruct *pcVar5;
  undefined *puVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentDocument);
  pHVar4 = (HSObjectListPaletteController *)&DAT_0036c44c;
  pHVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036c44c);
  if (pHVar2 != self->_dataProvider) {
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pHVar4);
      _objc_msgSend(pvVar3,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003364ac,pvVar1);
      pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      pcVar5 = &cfstr_HSDocumentDidActivateObjectListDataProviderNotif;
      uVar7 = 0;
      pHVar4 = self;
      _objc_msgSend(pvVar3,sel_removeObserver_name_object_,self,
                    &cfstr_HSDocumentDidActivateObjectListDataProviderNotif,0);
      if (self->_needsDataProvider != '\0') {
        pHVar4 = (HSObjectListPaletteController *)0x0;
        _objc_msgSend(self,sel_setDataProvider_,0,pcVar5,uVar7);
      }
    }
    self->_needsDataProvider = setNeedsDataProvider;
    if (setNeedsDataProvider != '\0') {
      pHVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pHVar4);
      if (pvVar1 == (id)0x0) {
        pcVar5 = &cfstr_HSDocumentDidActivateObjectListDataProviderNotif;
        pvVar1 = (id)0x0;
        op = sel_addObserver_selector_name_object_;
        puVar6 = sel_documentDidActivateObjectListDataProvider_;
      }
      else {
        pcVar5 = *(cfstringStruct **)PTR_003364ac;
        puVar6 = sel_documentDidRemoveFromDocumentController_;
        _objc_msgSend(pHVar4,sel_addObserver_selector_name_object_,self,
                      sel_documentDidRemoveFromDocumentController_,pcVar5,pvVar1);
        pHVar4 = self;
        op = sel_setDataProvider_;
        self = pHVar2;
      }
      _objc_msgSend(pHVar4,op,self,puVar6,pcVar5,pvVar1);
    }
  }
  return;
}

*/
- (void)setNeedsDataProvider:(BOOL)aProvider
{
    id document = [[NSDocumentController sharedDocumentController] currentDocument];
    id provider = [document queryHyperInterface:@protocol(HSObjectListDataProvider)];
    if (provider != _dataProvider) {
        if (document != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentDidRemoveFromDocumentControllerNotification object:document];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSDocumentDidActivateObjectListDataProviderNotification" object:nil];
            if (_needsDataProvider) {
                [self setDataProvider:nil];
            }
        }
        _needsDataProvider = aProvider;
        if (aProvider) {
            if (document == nil) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidActivateObjectListDataProvider:) name:@"HSDocumentDidActivateObjectListDataProviderNotification" object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidRemoveFromDocumentController:) name:HSDocumentDidRemoveFromDocumentControllerNotification object:document];
                [self setDataProvider:provider];
            }
        }
    }
}

- (void)setDataProvider:(id)aProvider
{
    id pvVar1;
    id pvVar1_5;

    if (_dataProvider != aProvider) {
        pvVar1 = nil;
        if (_dataProvider != nil) {
            [[self objectListController] setTopLevelParent:nil];
            [[_dataProvider objectListSelectionSynchronizer] setObjectBrowser:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSObjectListDataProviderDidChangeTopLevelParentNotification" object:_dataProvider];
            pvVar1 = _dataProvider;
        }
        [pvVar1 release];
        pvVar1_5 = [aProvider retain];
        _dataProvider = pvVar1_5;
        if (pvVar1_5 != nil) {
            [[self objectListController] setTopLevelParent:[_dataProvider objectListTopLevelParent]];
            [[_dataProvider objectListSelectionSynchronizer] setObjectBrowser:[self objectListController]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectListDataProviderDidChangeTopLevelParent:) name:@"HSObjectListDataProviderDidChangeTopLevelParentNotification" object:_dataProvider];
        }
    }
}

- (id)dataProvider
{
    return _dataProvider;
}

- (void)validateUserInterface
{
    [[self objectListController] validateUserInterface];
}

- (void)orderFrontPaletteWindow:(id)aWindow
{
    [aWindow makeKeyAndOrderFront:0];
}

- (void)documentDidRemoveFromDocumentController:(id)aController
{
    [self setDataProvider:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentDidRemoveFromDocumentControllerNotification object:[aController object]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidActivateObjectListDataProvider:) name:@"HSDocumentDidActivateObjectListDataProviderNotification" object:0];
    [self setNeedsDataProvider:YES];
}

- (void)documentWindowDidBecomeMain:(id)aMain
{
    [self setNeedsDataProvider:YES];
}

- (void)documentDidActivateObjectListDataProvider:(id)aProvider
{
    id self_00;
    id pvVar1_2;

    self_00 = [aProvider object];
    if (self_00 != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSDocumentDidActivateObjectListDataProviderNotification" object:0];
        pvVar1_2 = [self_00 queryHyperInterface:@protocol(HSObjectListDataProvider)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentDidRemoveFromDocumentController:) name:HSDocumentDidRemoveFromDocumentControllerNotification object:self_00];
        [self setDataProvider:pvVar1_2];
    }
}

- (void)windowDidBecomeKey:(id)aKey
{
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)applicationWillResignActive:(id)aActive
{
    id self_00;

    self_00 = [self window];
    [self_00 setLevel:(CGWindowLevelForKey(4))];
    if ([self_00 isVisible]) {
        [self_00 orderFront:self];
    }
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)applicationDidBecomeActive:(id)aActive
{
    [[self window] setLevel:(CGWindowLevelForKey(4)) + 1];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d7cdf @ 000d7cdf, 354 bytes * /

void FUN_000d7cdf(HSObjectListPaletteController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  int iVar3;
  HSObjectListPaletteController *pHVar4;
  undefined *puVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  HSObjectListPaletteController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSValidatedUserInterfacePaletteC_003502a0;
  _objc_msgSendSuper(&local_1c,sel_didLoadNib);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar2,sel_setHidesOnDeactivate_,0);
  _objc_msgSend(self,sel_mountObjectListController);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  puVar1 = PTR_00336058;
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_applicationDidBecomeActive_,
                *(undefined4 *)PTR_00336060,*(undefined4 *)PTR_00336058);
  uVar6 = *(undefined4 *)PTR_00336484;
  uVar7 = *(undefined4 *)puVar1;
  pHVar4 = self;
  puVar5 = sel_applicationWillResignActive_;
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_applicationWillResignActive_,
                uVar6,uVar7);
  pvVar2 = _objc_msgSend(*(id *)puVar1,sel_isActive);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_window,pHVar4,puVar5,uVar6,uVar7);
    iVar3 = _CGWindowLevelForKey(4);
    _objc_msgSend(pvVar2,sel_setLevel_,iVar3 + 1);
  }
  return;
}

*/
- (void)didLoadNib
{
    [super didLoadNib];
    [[self window] setHidesOnDeactivate:NO];
    [self mountObjectListController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:NSApp];
    if ([NSApp isActive]) {
        [[self window] setLevel:CGWindowLevelForKey(kCGNormalWindowLevelKey) + 1];
    }
}

- (id)nibName
{
    return @"ObjectListPalette";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_objectListController setTopLevelParent:nil];
    [[_dataProvider objectListSelectionSynchronizer] setObjectBrowser:nil];
    [_dataProvider release];
    [_containerView setDelegate:0];
    [_objectListController release];
    [super dealloc];
}

@end

