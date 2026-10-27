#import "HSHelpAssistantPane.h"

@implementation HSHelpAssistantPane

/* i386 ivar offsets: _informativeText=0x5c, _dontShowThisMessageAgainSwitchHidden=0x60, _coachingHintKey=0x64, _didDoneDelegate=0x68, _didDoneSelector=0x6c, _delegateContextInfo=0x70, _shouldDismissWhenDisappeared=0x74, _shouldDismissOnOkFromSwitcher=0x75, _textView=0x78, _dontShowThisMessageAgainSwitch=0x7c, _addyImageView=0x80, _helpAssistantPaneSwitcher=0x84 */

+ (id)paneWithCoachingKey:(id)aKey
{
    return [[[self alloc] initWithCoachingKey:aKey] autorelease];
}

- (void)toggleDontShowThisMessageAgain:(id)aAgain
{
    id self_00;
    id pvVar1;

    self_00 = [HSCoachingHelpManager sharedCoachingHelpManager];
    pvVar1 = [self coachingKey];
    [self_00 setDontShowCoachingHints:(unsigned int)([aAgain state] == 0x1) forKey:pvVar1];
    [self updateUI];
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c6a25 @ 001c6a25, 397 bytes * /

void FUN_001c6a25(HSHelpAssistantPane *self,SEL _cmd,id paneDidOK)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(paneDidOK,sel_navigationController);
  pvVar2 = _objc_msgSend(pvVar1,sel_parentViewController);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  puVar3 = &DAT_0037ead4;
  pvVar2 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_0037ead4);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(pvVar1,sel_viewControllers,puVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar2 == (id)0x1) {
      pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar3);
      _objc_msgSend(pvVar2,sel_deactivateIfNeeded);
    }
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_viewControllers,puVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)0x1) {
    pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar3);
    puVar3 = *(undefined **)PTR_PTR_00336700;
    pvVar1 = _objc_msgSend(pvVar1,sel_boolForKey_,puVar3);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar3);
      _objc_msgSend(pvVar1,sel_deactivateIfNeeded);
    }
  }
  _objc_msgSend(self,sel_invokeDidDoneSelectorIfNeeded,puVar3);
  if (self->_shouldDismissOnOkFromSwitcher != '\0') {
    _objc_msgSend(self,sel_dismiss_slide_,1,0);
  }
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    id navigationController = [aOK navigationController];
    if ([[[navigationController parentViewController] object] implementsHyperInterface:@protocol(HSStackAttributes)]) {
        if ([[navigationController viewControllers] count] == 1) {
            [[HSObjectAssistantController sharedAssistantController] deactivateIfNeeded];
        }
    }
    if ([[navigationController viewControllers] count] == 1) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:HSIsObjectAssistantControllerActivatedByUser]) {
            [[HSObjectAssistantController sharedAssistantController] deactivateIfNeeded];
        }
    }
    [self invokeDidDoneSelectorIfNeeded];
    if (_shouldDismissOnOkFromSwitcher) {
        [self dismiss:YES slide:NO];
    }
}

- (BOOL)isCoachingPane
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c691f @ 001c691f, 262 bytes * /

void FUN_001c691f(HSHelpAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  HSHelpAssistantPane *local_10;
  
  self_00 = cls_NSInvocation;
  local_10 = self;
  if ((self->_didDoneDelegate != (id)0x0) && (self->_didDoneSelector != (SEL)0x0)) {
    pvVar1 = _objc_msgSend(self->_didDoneDelegate,sel_methodSignatureForSelector_,
                           self->_didDoneSelector);
    pvVar1 = _objc_msgSend(self_00,sel_invocationWithMethodSignature_,pvVar1);
    _objc_msgSend(pvVar1,sel_setSelector_,local_10->_didDoneSelector);
    _objc_msgSend(pvVar1,sel_setTarget_,local_10->_didDoneDelegate);
    _objc_msgSend(pvVar1,sel_retainArguments);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_10,2);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_10->_delegateContextInfo,3);
    _objc_msgSend(pvVar1,sel_invoke);
  }
  return;
}

*/
- (void)invokeDidDoneSelectorIfNeeded
{
    if (_didDoneDelegate != nil && _didDoneSelector != NULL) {
        HSHelpAssistantPane *pane = self;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_didDoneDelegate methodSignatureForSelector:_didDoneSelector]];
        [invocation setSelector:_didDoneSelector];
        [invocation setTarget:_didDoneDelegate];
        [invocation retainArguments];
        [invocation setArgument:&pane atIndex:2];
        [invocation setArgument:&_delegateContextInfo atIndex:3];
        [invocation invoke];
    }
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (BOOL)isEqual:(id)aEqual
{
    BOOL pvVar1;
    BOOL bVar3;

    pvVar1 = [super isEqual:aEqual];
    if (!pvVar1) {
        bVar3 = NO;
    }
    else {
        pvVar1 = [[self informativeText] isEqualToAttributedString:[aEqual informativeText]];
        bVar3 = pvVar1;
    }
    return bVar3;
}

- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide
{
    _shouldDismissWhenDisappeared = NO;
    [super dismiss:aDismiss slide:aSlide];
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    [super viewDidDisappear:aDisappear];
    if ([self shouldDismissWhenDisappeared]) {
        [self dismiss:NO];
    }
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self updateUI];
}

- (void)updateUI
{
    if (_informativeText != nil) {
        [[_textView textStorage] setAttributedString:_informativeText];
    }
    [_dontShowThisMessageAgainSwitch setState:(unsigned int)([[HSCoachingHelpManager sharedCoachingHelpManager] dontShowCoachingHintsForKey:[self coachingKey]])];
    [_dontShowThisMessageAgainSwitch setHidden:_dontShowThisMessageAgainSwitchHidden];
}

- (void)setDontShowThisMessageAgainSwitchVisible:(BOOL)aVisible
{
    if ([self isDontShowThisMessageAgainSwitchVisible] != aVisible) {
        _dontShowThisMessageAgainSwitchHidden = aVisible == NO;
        [self updateUI];
    }
}

- (BOOL)ignoresPreferences
{
    return NO;
}

- (BOOL)needsToShow
{
    return ![[HSCoachingHelpManager sharedCoachingHelpManager] dontShowCoachingHintsForKey:[self coachingKey]];
}

- (BOOL)isDontShowThisMessageAgainSwitchVisible
{
    return _dontShowThisMessageAgainSwitchHidden == NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c6ed0 @ 001c6ed0, 776 bytes * /

void FUN_001c6ed0(HSHelpAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  undefined4 extraout_EDX;
  uint extraout_EDX_00;
  undefined8 local_4c [2];
  HSHelpAssistantPane *local_3c;
  undefined *local_38;
  undefined1 local_34 [8];
  undefined8 local_2c;
  undefined8 local_24 [2];
  
  local_3c = self;
  local_38 = PTR_s_HSObjectAssistantPane_00353990;
  _objc_msgSendSuper(&local_3c,sel_viewDidLoad);
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar1,sel_setParentViewController_,self);
  pvVar1 = _objc_msgSend(cls_HSCoachingTextContainer,sel_alloc);
  pvVar2 = _objc_msgSend(self->_textView,sel_textContainer);
  pvVar2 = _objc_msgSend(pvVar2,sel_containerSize);
  self_00 = _objc_msgSend(pvVar1,sel_initWithContainerSize_,pvVar2,extraout_EDX);
  _objc_msgSend(self->_textView,sel_replaceTextContainer_,self_00);
  _objc_msgSend(self->_textView,sel_setUsesFindPanel_,0);
  _objc_msgSend(self->_textView,sel_setHorizontallyResizable_,0);
  _objc_msgSend(self->_textView,sel_setVerticallyResizable_,0);
  _objc_msgSend(self->_textView,sel_setEditable_,0);
  _objc_msgSend(self->_textView,sel_setSelectable_,0);
  _objc_msgSend(self->_textView,sel_setAllowsUndo_,0);
  _objc_msgSend(self->_textView,sel_setDrawsBackground_,0);
  _objc_msgSend(self->_textView,sel_setNeverDrawsBackground_,1);
  _objc_msgSend(self->_textView,sel_setTextContainerInset_,*(undefined4 *)PTR_0033607c,
                *(undefined4 *)(PTR_0033607c + 4));
  _objc_msgSend(self->_textView,sel_textContainerOrigin);
  pvVar3 = _objc_msgSend(self->_textView,sel_textContainerOrigin);
  pvVar1 = self->_textView;
  pvVar2 = self->_addyImageView;
  _objc_msgSend_stret(local_34,pvVar2,sel_bounds);
  _objc_msgSend_stret(local_24,pvVar2,sel_convertRect_toView_,local_34._0_4_,local_34._4_4_,local_2c
                      ,pvVar1);
  _NSOffsetRect(local_4c,local_24[0],(int)local_24[1],(int)((ulonglong)local_24[1] >> 0x20),
                (uint)pvVar3 ^ 0x80000000,extraout_EDX_00 ^ 0x80000000);
  _objc_msgSend(self_00,sel_setObstacleRect_,local_4c[0],(int)local_4c[1],
                (int)((ulonglong)local_4c[1] >> 0x20));
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationPaneSwitcher] setParentViewController:self];
    HSCoachingTextContainer *container = [[HSCoachingTextContainer alloc] initWithContainerSize:[[_textView textContainer] containerSize]];
    [_textView replaceTextContainer:container];
    [_textView setUsesFindPanel:NO];
    [_textView setHorizontallyResizable:NO];
    [_textView setVerticallyResizable:NO];
    [_textView setEditable:NO];
    [_textView setSelectable:NO];
    [_textView setAllowsUndo:NO];
    [_textView setDrawsBackground:NO];
    [_textView setNeverDrawsBackground:YES];
    [_textView setTextContainerInset:NSZeroSize];
    NSPoint origin = [_textView textContainerOrigin];
    NSRect rect = [_addyImageView convertRect:[_addyImageView bounds] toView:_textView];
    rect = NSOffsetRect(rect, -origin.x, -origin.y);
    [container setObstacleRect:rect];
    [container release];
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _helpAssistantPaneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_2 = [self newBackgroundImage];
        _helpAssistantPaneSwitcher = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _helpAssistantPaneSwitcher;
    }
    return pvVar1;
}

- (id)newBackgroundImage
{
    return [[HSObjectAssistantNavigationPaneSwitcher alloc] initWithNibName:@"HSHelpAssistantPaneSwitcher"];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return YES;
}

- (void *)didDoneContextInfo
{
    return _delegateContextInfo;
}

- (SEL)didDoneSelector
{
    return _didDoneSelector;
}

- (id)didDoneDelegate
{
    return _didDoneDelegate;
}

- (void)setDidDoneDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    _didDoneDelegate = aDelegate;
    _didDoneSelector = aSelector;
    _delegateContextInfo = aInfo;
}

- (void)setCoachingKey:(id)aKey
{
    [_coachingHintKey autorelease];
    _coachingHintKey = [aKey copy];
    [self updateUI];
}

- (id)coachingKey
{
    id pvVar1;

    pvVar1 = _coachingHintKey;
    if (pvVar1 == nil) {
        pvVar1 = [[[HSCoachingInfoProvider sharedProvider] coachingKeyForObject:[[self assistant] object]] retain];
        _coachingHintKey = pvVar1;
    }
    if (pvVar1 == nil) {
        pvVar1 = NSStringFromClass([[[self assistant] object] class]);
    }
    return pvVar1;
}

- (void)setShouldDismissOnOkFromSwitcher:(BOOL)aSwitcher
{
    _shouldDismissOnOkFromSwitcher = aSwitcher;
}

- (BOOL)shouldDismissOnOkFromSwitcher
{
    return _shouldDismissOnOkFromSwitcher;
}

- (void)setShouldDismissWhenDisappeared:(BOOL)aDisappeared
{
    _shouldDismissWhenDisappeared = aDisappeared;
}

- (BOOL)shouldDismissWhenDisappeared
{
    return _shouldDismissWhenDisappeared;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return YES;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithCoachingKey:[self coachingKey]];
}

- (id)init
{
    return [self initWithInformativeText:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c648e @ 001c648e, 383 bytes * /

id FUN_001c648e(HSHelpAssistantPane *self,SEL _cmd,id initWithCoachingKey)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSCoachingInfoProvider,sel_sharedProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_coachingInfoForKey_,initWithCoachingKey);
  pvVar2 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_informativeTextFilename);
  pvVar1 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_inDirectory_,pvVar1,&cfstr_rtf,
                         &cfstr_Coaching);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithPath_documentAttributes_,pvVar1,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar2 = _objc_msgSend(pvVar2,sel_coachingHintDefaultButton);
  _objc_msgSend(pvVar1,sel_replaceOccurencesOfString_withString_,*(undefined4 *)PTR_PTR_003366fc,
                pvVar2);
  pvVar3 = _objc_msgSend(self,sel_initWithInformativeText_,pvVar1);
  if (pvVar3 != (id)0x0) {
    pvVar1 = _objc_msgSend(initWithCoachingKey,sel_copy,pvVar1,pvVar2);
    *(id *)((int)pvVar3 + 100) = pvVar1;
  }
  return pvVar3;
}

*/
- (id)initWithCoachingKey:(id)aKey
{
    id info = [[HSCoachingInfoProvider sharedProvider] coachingInfoForKey:aKey];
    NSString *path = [[NSBundle mainBundle] pathForResource:[info objectForKey:@"informativeTextFilename"] ofType:@"rtf" inDirectory:@"Coaching"];
    NSMutableAttributedString *text = [[[NSMutableAttributedString alloc] initWithPath:path documentAttributes:NULL] autorelease];
    [text replaceOccurencesOfString:@"<defaultButtonName>" withString:[[HSObjectAssistantController sharedAssistantController] coachingHintDefaultButton]];
    self = [self initWithInformativeText:text];
    if (self != nil) {
        _coachingHintKey = [aKey copy];
    }
    return self;
    return 0;
}

- (id)initWithInformativeText:(id)aText
{
    return [self initWithInformativeText:aText didEndDelegate:nil didDoneSelector:nil contextInfo:nil];
}

- (id)initWithInformativeText:(id)aText didEndDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    return [self initWithNibName:@"HSHelpAssistantPane" informativeText:aText didEndDelegate:aDelegate didDoneSelector:aSelector contextInfo:aInfo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c6394 @ 001c6394, 105 bytes * /

id FUN_001c6394(HSHelpAssistantPane *self,SEL _cmd,id initWithNibName,id informativeText,
               id didEndDelegate,SEL didDoneSelector,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_initWithNibName_,initWithNibName);
  if (pvVar1 != (id)0x0) {
    *(id *)((int)pvVar1 + 0x68) = didEndDelegate;
    *(SEL *)((int)pvVar1 + 0x6c) = didDoneSelector;
    *(void **)((int)pvVar1 + 0x70) = contextInfo;
    pvVar2 = _objc_msgSend(informativeText,sel_retain,initWithNibName);
    *(id *)((int)pvVar1 + 0x5c) = pvVar2;
    *(undefined1 *)((int)pvVar1 + 0x75) = 1;
  }
  return pvVar1;
}

*/
- (id)initWithNibName:(id)aName informativeText:(id)aText didEndDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    self = [self initWithNibName:aName];
    if (self != nil) {
        _didDoneDelegate = aDelegate;
        _didDoneSelector = aSelector;
        _delegateContextInfo = aInfo;
        _informativeText = [aText retain];
        _shouldDismissOnOkFromSwitcher = YES;
    }
    return self;
    return 0;
}

- (id)initWithNibName:(id)aName
{
    self = [super initWithNibName:aName];
    if (self != nil) {
        _shouldDismissWhenDisappeared = [self shouldDismissWhenDisappearedByDefault];
    }
    return self;
}

- (void)dealloc
{
    [_coachingHintKey release];
    [_informativeText release];
    [_helpAssistantPaneSwitcher setDelegate:0];
    [_helpAssistantPaneSwitcher release];
    [super dealloc];
}

- (id)informativeText
{
    id pvVar1;

    pvVar1 = _informativeText;
    if (pvVar1 == nil) {
        [self setInformativeText:[[NSAttributedString new] autorelease]];
        pvVar1 = _informativeText;
    }
    return pvVar1;
}

- (void)setInformativeText:(id)aText
{
    if (_informativeText != aText) {
        [_informativeText autorelease];
        _informativeText = [aText retain];
        [self updateUI];
    }
}

@end

