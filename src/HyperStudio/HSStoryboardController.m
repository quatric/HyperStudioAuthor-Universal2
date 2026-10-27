#import "HSStoryboardController.h"

@implementation HSStoryboardController

/* i386 ivar offsets: _storyboardContainerView=0x34, _storyboardView=0x38, _bottomAreaTintedView=0x3c, _statusbarController=0x40, _userDoubleClickedOnCard=0x44, _prevWindowMinContentSize=0x48 */

- (void)stackTitleDidChanged:(id)aChanged
{
    [self synchronizeWindowTitleWithDocumentName];
}

- (void)revertWindowMinContentSize
{
    [self updateContentMinSize:(_prevWindowMinContentSize) forWindow:[self window] animated:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e477 @ 0015e477, 242 bytes * /

void FUN_0015e477(HSStoryboardController *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  undefined8 local_34;
  undefined8 local_2c;
  undefined1 local_24 [12];
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_contentMinSize);
  (self->_prevWindowMinContentSize).width = (float)pvVar1;
  (self->_prevWindowMinContentSize).height = extraout_EDX;
  pvVar1 = self->_bottomAreaTintedView;
  _objc_msgSend_stret(&local_34,pvVar1,sel_bounds);
  _objc_msgSend_stret(local_24,pvVar1,sel_convertRect_toView_,local_34,local_2c,0);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(self,sel_updateContentMinSize_forWindow_animated_,0x43d30000,local_18 + 100.0,pvVar1
                ,1);
  return;
}

*/
- (void)adjustWindowMinContentSize
{
    _prevWindowMinContentSize = [[self window] contentMinSize];
    NSRect rect = [_bottomAreaTintedView convertRect:[_bottomAreaTintedView bounds] toView:nil];
    [self updateContentMinSize:NSMakeSize(422.0, rect.size.height + 100.0) forWindow:[self window] animated:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e569 @ 0015e569, 387 bytes * /

ulonglong FUN_0015e569(HSStoryboardController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  float local_48;
  undefined1 local_44 [8];
  ulonglong local_3c;
  undefined4 local_34;
  float local_30;
  float local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  id local_1c;
  float fStack_18;
  
  pvVar1 = _objc_msgSend(self,sel_storyboardView);
  local_1c = _objc_msgSend(pvVar1,sel_requiredSizeToFitAllItems);
  local_24 = 0;
  uStack_20 = 0;
  if ((float)local_1c < 422.0) {
    local_1c = (id)0x43d30000;
  }
  fStack_18 = extraout_EDX;
  if (extraout_EDX < 100.0) {
    fStack_18 = 100.0;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_enclosingScrollView);
  _objc_msgSend_stret(&local_34,pvVar1,sel_bounds);
  local_48 = local_30;
  pvVar2 = _objc_msgSend(pvVar1,sel_isFlipped);
  if ((char)pvVar2 != '\0') {
    local_48 = local_30 + local_28;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_convertPoint_toView_,local_34,local_48,0);
  local_1c = (id)((float)pvVar1 + (float)local_1c);
  fStack_18 = extraout_EDX_00 + fStack_18;
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(local_44,pvVar1,sel_frameRectForContentRect_,CONCAT44(uStack_20,local_24),
                      CONCAT44(fStack_18,local_1c));
  return local_3c;
}

*/
- (NSSize)windowFrameSizeAdjustedToCurrentContent
{
    id view = [self storyboardView];
    NSSize size = [view requiredSizeToFitAllItems];
    if (size.width < 422.0) {
        size.width = 422.0;
    }
    if (size.height < 100.0) {
        size.height = 100.0;
    }
    NSScrollView *scroll = [view enclosingScrollView];
    NSRect bounds = [scroll bounds];
    NSPoint point = NSMakePoint(bounds.origin.x, bounds.origin.y);
    if ([scroll isFlipped]) {
        point.y = bounds.origin.y + bounds.size.height;
    }
    point = [scroll convertPoint:point toView:nil];
    size.width = point.x + size.width;
    size.height = point.y + size.height;
    return [[self window] frameRectForContentRect:NSMakeRect(0, 0, size.width, size.height)].size;
}

- (id)cardView
{
    return nil;
}

- (void)setActiveCard:(id)aCard
{
    [self window];
    [_storyboardView selectHyperObject:aCard];
}

- (id)activeCard
{
    return [_storyboardView activeCard];
}

- (BOOL)needsDeleteSelectedCardInStoryboardView:(id)aView
{
    [[self document] removeSelectedCardsWithAlert:YES];
    return NO;
}

- (void)storyboardView:(id)aView didSelectCard:(id)aCard
{
    [[[self document] navigationController] goToCardAtIndex:[aCard hyperIndex]];
    [[self document] setStoryboardModeOn:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e6ec @ 0015e6ec, 60 bytes * /

void FUN_0015e6ec(HSStoryboardController *self,SEL _cmd,id zoomFactorDidChange)

{
  id self_00;
  longdouble lVar1;
  
  self_00 = self->_storyboardView;
  lVar1 = (longdouble)_HSNonLinearValueForSlider(zoomFactorDidChange);
  _objc_msgSend(self_00,sel_setCardScaleFactor_,(float)lVar1);
  return;
}

*/
- (void)zoomFactorDidChange:(id)aChange
{
    [_storyboardView setCardScaleFactor:HSNonLinearValueForSlider(aChange)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e195 @ 0015e195, 98 bytes * /

void FUN_0015e195(HSStoryboardController *self,SEL _cmd,id zoomToMinScaleFactor)

{
  undefined4 uVar1;
  
  uVar1 = *(undefined4 *)PTR_DAT_00336644;
  _objc_msgSend(self->_storyboardView,sel_setCardScaleFactor_,uVar1,uVar1);
  _objc_msgSend(self->_statusbarController,sel_setZoomFactor_,uVar1);
  return;
}

*/
- (void)zoomToMinScaleFactor:(id)aFactor
{
    [_storyboardView setCardScaleFactor:0.1];
    [_statusbarController setZoomFactor:0.1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e133 @ 0015e133, 98 bytes * /

void FUN_0015e133(HSStoryboardController *self,SEL _cmd,id zoomToMaxScaleFactor)

{
  undefined4 uVar1;
  
  uVar1 = *(undefined4 *)PTR_DAT_00336640;
  _objc_msgSend(self->_storyboardView,sel_setCardScaleFactor_,uVar1,uVar1);
  _objc_msgSend(self->_statusbarController,sel_setZoomFactor_,uVar1);
  return;
}

*/
- (void)zoomToMaxScaleFactor:(id)aFactor
{
    [_storyboardView setCardScaleFactor:1.0];
    [_statusbarController setZoomFactor:1.0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e0a1 @ 0015e0a1, 146 bytes * /

void FUN_0015e0a1(HSStoryboardController *self,SEL _cmd,id textFieldTamer)

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
    HSTextFieldTamerDialogController *controller = [[HSTextFieldTamerDialogController alloc] initWithContext:[[self document] editObjectDialogContext]];
    [controller runModal];
    [controller release];
}

- (void)sameBackground:(id)aBackground
{
    id self_00;
    id pvVar2_3;
    NSUInteger pvVar2_4;
    id pvVar3_3;
    id pvVar3_5;
    id pvVar4_2;

    [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Same Background" value:@"" table:@"UndoManager"]];
    pvVar2_3 = [self activeCard];
    pvVar3_3 = [pvVar2_3 unitForRole:HSEditableBackgroundUnitRole];
    self_00 = [HSCard node];
    pvVar4_2 = [[self document] stack];
    pvVar2_4 = [[pvVar4_2 hyperChildren] indexOfObject:pvVar2_3];
    pvVar3_5 = [[pvVar3_3 copyWithZone:0] autorelease];
    if (pvVar3_5 != nil) {
        [self_00 injectUnit:pvVar3_5 forRole:HSEditableBackgroundUnitRole];
    }
    [pvVar4_2 insertHyperChild:self_00 atIndex:(int)pvVar2_4 + 1];
}

- (void)makeGroupCard:(id)aCard
{
    [[self activeCard] makeNewGroupCard];
}

- (BOOL)supportMenuItemStoredTitleValidation
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e728 @ 0015e728, 303 bytes * /

BOOL FUN_0015e728(HSStoryboardController *self,SEL _cmd,id validateUserInterfaceItem)

{
  undefined *puVar1;
  id pvVar2;
  BOOL BVar3;
  HSStoryboardController *local_1c;
  undefined *local_18;
  
  puVar1 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_00351da0;
  pvVar2 = _objc_msgSendSuper(&local_1c,sel_validateUserInterfaceItem_,validateUserInterfaceItem);
  if ((puVar1 == sel_sameBackground_) || (puVar1 == sel_makeGroupCard_)) {
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,sel_selectionController);
    pvVar2 = _objc_msgSend(pvVar2,sel_selectedHyperObject);
    pvVar2 = _objc_msgSend(pvVar2,sel_allHyperInterfaces);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    BVar3 = pvVar2 == (id)0x1;
  }
  else if (puVar1 == sel_titleCard_) {
    pvVar2 = _objc_msgSend(self,sel_activeCard);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0037496c);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperIndex);
    BVar3 = pvVar2 != (id)0x0;
  }
  else {
    BVar3 = '\x01';
    if (puVar1 != sel_textFieldTamer_) {
      BVar3 = (BOOL)pvVar2;
    }
  }
  return BVar3;
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    BOOL result = [super validateUserInterfaceItem:aItem];
    if (action == @selector(sameBackground:) || action == @selector(makeGroupCard:)) {
        return [[[[[self document] selectionController] selectedHyperObject] allHyperInterfaces] count] == 1;
    }
    if (action == @selector(titleCard:)) {
        return [[[self activeCard] queryHyperInterface:@protocol(HSNodeChild)] hyperIndex] != 0;
    }
    if (action != @selector(textFieldTamer:)) {
        return result;
    }
    return YES;
}

- (void)documentBackgroundPatternDidChange:(id)aChange
{
    [[self storyboardView] setBackgroundColor:0];
}

- (void)zoomSliderDidFinishTracking:(id)aTracking inStatusbarController:(id)aController
{
    [_storyboardView setInLiveScale:NO];
}

- (void)zoomSliderDidStartTracking:(id)aTracking inStatusbarController:(id)aController
{
    [_storyboardView setInLiveScale:YES];
}

- (id)textForStatusBarController:(id)aController
{
    NSString *pvVar1_2;
    NSUInteger pvVar2_3;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"%u of %u selected" value:@"" table:0];
    pvVar2_3 = [[[_storyboardView stack] children] count];
    return [NSString stringWithFormat:pvVar1_2, [[[[[self document] selectionController] selectedHyperObject] allHyperInterfaces] count], pvVar2_3];
}

- (void)selectionDidChange:(id)aChange
{
    [_statusbarController refreshStatusbarText];
    [self synchronizeWindowTitleWithDocumentName];
}

- (BOOL)canGoToPreviousCardInStatusbarController:(id)aController
{
    return (BOOL)[[[self document] navigationController] canGoToPreviousCard];
}

- (BOOL)canGoToNextCardInStatusbarController:(id)aController
{
    return (BOOL)[[[self document] navigationController] canGoToNextCard];
}

- (void)didLoadNib
{
    [self prepareUI];
}

- (void)didBecomeNonWorkingInModeSwitcher:(id)aSwitcher
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSStackTitleDidChangeNotification object:0];
    [[[self document] selectionController] setStoryboardView:nil];
    [self setStack:nil];
    [super didBecomeNonWorkingInModeSwitcher:aSwitcher];
}

- (void)windowControllerWillUnbindFromWindowInModeSwitcher:(id)aSwitcher
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldDisableAnimationInModeSwitcher:(id)aSwitcher
{
    return [aSwitcher switchesAllWindows];
}

- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher
{
    [[aSwitcher activeModeController] setActiveCard:[self activeCard]];
    [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
    [self revertWindowMinContentSize];
    [_storyboardView unregisterItemsForActionsAttributeChanges];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015da33 @ 0015da33, 134 bytes * /

void FUN_0015da33(HSStoryboardController *self,SEL _cmd,
                 id HSStoryboardController_modeSwitcherDidEndModeSwitching)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar1 = _objc_msgSend(HSStoryboardController_modeSwitcherDidEndModeSwitching,sel_object);
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_00336104,pvVar1)
  ;
  _objc_msgSend(self->_statusbarController,sel_validateUI);
  return;
}

*/
- (void)HSStoryboardController_modeSwitcherDidEndModeSwitching:(id)aSwitching
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:[aSwitching object]];
    [_statusbarController validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015d908 @ 0015d908, 299 bytes * /

void FUN_0015d908(HSStoryboardController *self,SEL _cmd,id didBecomeWorkingInModeSwitcher)

{
  id pvVar1;
  
  _objc_msgSend(self,sel_adjustWindowMinContentSize);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar1,sel_setActive_explicitlyByUser_,0,0);
  _objc_msgSend(pvVar1,sel_openEnterStoryboardCoachingPaneIfNeeded);
  pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_setDataProvider_,0);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_makeFirstResponder_,self->_storyboardView);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                sel_HSStoryboardController_modeSwitcherDidEndModeSwitching_,
                *(undefined4 *)PTR_PTR_00336104,didBecomeWorkingInModeSwitcher);
  return;
}

*/
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [self adjustWindowMinContentSize];
    id assistant = [HSObjectAssistantController sharedAssistantController];
    [assistant setActive:NO explicitlyByUser:NO];
    [assistant openEnterStoryboardCoachingPaneIfNeeded];
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:nil];
    [[self window] makeFirstResponder:_storyboardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSStoryboardController_modeSwitcherDidEndModeSwitching:) name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:aSwitcher];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015e931 @ 0015e931, 769 bytes * /

void FUN_0015e931(HSStoryboardController *self,SEL _cmd,id willBecomeWorkingInModeSwitcher)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  HSStoryboardController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_00351da0;
  _objc_msgSendSuper(&local_1c,sel_willBecomeWorkingInModeSwitcher_,willBecomeWorkingInModeSwitcher)
  ;
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar1,sel_navigationController);
  pvVar1 = _objc_msgSend(cls_HSEditorNavigationController,sel_class);
  pvVar2 = _objc_msgSend(pvVar2,sel_isKindOfClass_,pvVar1);
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSEditorNavigationController,sel_alloc,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar1,sel_initWithDocument_,pvVar2);
    self_00 = _objc_msgSend(self,sel_document);
    pvVar1 = pvVar2;
    _objc_msgSend(self_00,sel_setNavigationController_,pvVar2);
    _objc_msgSend(pvVar2,sel_release);
  }
  pvVar1 = _objc_msgSend(self,sel_document,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectionController);
  _objc_msgSend(pvVar1,sel_setStoryboardView_,self->_storyboardView);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectionController);
  _objc_msgSend(pvVar1,sel_setEnabled_,1);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_selectionController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_selectionDidChange_,
                &cfstr_HSSelectionHolderDidChangeSelectionNotification,pvVar2);
  _objc_msgSend(self->_statusbarController,sel_validateUI);
  _objc_msgSend(self->_statusbarController,sel_refreshStatusbarText);
  pvVar1 = _objc_msgSend(willBecomeWorkingInModeSwitcher,sel_previousModeController);
  pvVar1 = _objc_msgSend(pvVar1,sel_activeCard);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_stack);
  _objc_msgSend(self,sel_setStack_andSelectCard_,pvVar2,pvVar1);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_stackTitleDidChanged_,
                *(undefined4 *)PTR_00336110,0);
  return;
}

*/
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecomeWorkingInModeSwitcher:aSwitcher];
    if (![[[self document] navigationController] isKindOfClass:[HSEditorNavigationController class]]) {
        HSEditorNavigationController *navigation = [[HSEditorNavigationController alloc] initWithDocument:[self document]];
        [[self document] setNavigationController:navigation];
        [navigation release];
    }
    [[[self document] selectionController] setStoryboardView:_storyboardView];
    [[[self document] selectionController] setEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:@"HSSelectionHolderDidChangeSelectionNotification" object:[[self document] selectionController]];
    [_statusbarController validateUI];
    [_statusbarController refreshStatusbarText];
    id card = [[aSwitcher previousModeController] activeCard];
    [self setStack:[[self document] stack] andSelectCard:card];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stackTitleDidChanged:) name:HSStackTitleDidChangeNotification object:nil];
}

- (id)storyboardView
{
    [self loadNibIfNeeded];
    return _storyboardView;
}

- (void)setStack:(id)aStack
{
    [self setStack:aStack andSelectCard:nil];
}

- (void)setStack:(id)aStack andSelectCard:(id)aCard
{
    [[self storyboardView] setStack:aStack andSelectCard:aCard];
    [_statusbarController refreshStatusbarText];
}

- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible
{
    return NO;
}

- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding
{
    return NO;
}

- (id)secondaryModeSwitcherWindows:(id)aWindows
{
    return [[super secondaryModeSwitcherWindows:aWindows] arrayByAddingObjectsFromArray:[HSEditorWindowController palettesArrayIncludingLibrary:YES toolPalette:YES layoutPalette:NO objectListPalette:NO commentsAndAttributionsPalette:NO shortcutsPalette:NO]];
}

- (id)modeSwitcherWindowController:(id)aController
{
    return self;
}

- (id)modeSwitcherView:(id)aView
{
    [self loadNibIfNeeded];
    return _storyboardContainerView;
}

- (void)windowDidLoad
{
    [self prepareUI];
    [_storyboardView setAllowEmptySelection:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015ecd2 @ 0015ecd2, 601 bytes * /

void FUN_0015ecd2(HSStoryboardController *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend(self->_bottomAreaTintedView,sel_setDrawsBorder_);
  _objc_msgSend(self->_bottomAreaTintedView,sel_setDrawsFill_);
  pvVar1 = self->_bottomAreaTintedView;
  _objc_msgSend(cls_NSColor,sel_colorWithCalibratedWhite_alpha_);
  _objc_msgSend(pvVar1,sel_setTintColor_);
  _objc_msgSend(self->_bottomAreaTintedView,sel_setOpaque_);
  _objc_msgSend(cls_NSImage,sel_imageNamed_);
  _objc_msgSend(self->_bottomAreaTintedView,sel_setBackgroundImage_);
  pvVar1 = _objc_msgSend(cls_HSStoryboardStatusbarController,sel_new);
  self->_statusbarController = pvVar1;
  pvVar1 = _objc_msgSend(pvVar1,sel_statusbarView);
  _objc_msgSend(self->_bottomAreaTintedView,sel_addSubview_);
  _objc_msgSend_stret(&local_24,self->_bottomAreaTintedView,sel_bounds);
  _objc_msgSend(pvVar1,sel_setFrame_,local_24,local_1c);
  _objc_msgSend(self->_statusbarController,sel_setDelegate_,self);
  _objc_msgSend(self->_statusbarController,sel_setMaxZoomFactor_,*(undefined4 *)PTR_DAT_00336640);
  _objc_msgSend(self->_statusbarController,sel_setMinZoomFactor_,*(undefined4 *)PTR_DAT_00336644);
  pvVar1 = self->_statusbarController;
  dVar2 = _objc_msgSend_fpret(self->_storyboardView,sel_cardScaleFactor);
  _objc_msgSend(pvVar1,sel_setZoomFactor_,(float)dVar2);
  _objc_msgSend(self->_storyboardView,sel_setDelegate_,self);
  pvVar1 = _objc_msgSend(self->_storyboardView,sel_cardBorderRenderer);
  _objc_msgSend(pvVar1,sel_setCardBorderRendererType_,*(undefined4 *)PTR_PTR_0033663c);
  return;
}

*/
- (id)windowNibName
{
    return @"StoryboardController";
}

- (void)loadNibIfNeeded
{
    if (_storyboardView == nil) {
        [self window];
    }
}

- (void)dealloc
{
    if ([_statusbarController delegate] == self) {
        [_statusbarController setDelegate:0];
    }
    [_statusbarController release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

