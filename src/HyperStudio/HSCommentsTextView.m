#import "HSCommentsTextView.h"

@implementation HSCommentsTextView

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

@end

@implementation HSObjectAssistantPane

/* i386 ivar offsets: _window=0x40, _assistant=0x44, _validateTextFieldsWithFormatters=0x48, _objectAssistantPaneDelegate=0x4c, _object=0x50, _windowTitle=0x54, _objectAssistantNavigationController=0x58 */

- (BOOL)isCoachingPane
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00103e66 @ 00103e66, 142 bytes * /

void FUN_00103e66(HSObjectAssistantPane *self,SEL _cmd,id setParentViewController)

{
  id pvVar1;
  HSObjectAssistantPane *local_1c;
  undefined *local_18;
  
  if (setParentViewController != (id)0x0) {
    pvVar1 = _objc_msgSend(setParentViewController,sel_respondsToSelector_,sel_assistant);
    if ((char)pvVar1 == '\0') goto LAB_00103ec7;
  }
  pvVar1 = _objc_msgSend(setParentViewController,sel_assistant);
  _objc_msgSend(self,sel_setAssistant_,pvVar1);
LAB_00103ec7:
  local_1c = self;
  local_18 = PTR_s_HSViewController_00350ab0;
  _objc_msgSendSuper(&local_1c,sel_setParentViewController_,setParentViewController);
  return;
}

*/
- (void)setParentViewController:(id)aController
{
    if (aController == nil || [aController respondsToSelector:@selector(assistant)]) {
        [self setAssistant:[aController assistant]];
    }
    [super setParentViewController:aController];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00103ef4 @ 00103ef4, 205 bytes * /

void FUN_00103ef4(HSObjectAssistantPane *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  char cVar3;
  id pvVar4;
  HSObjectAssistantPane *local_14;
  undefined *local_10;
  
  if ((self->super)._layoutIsValid == '\0') {
    fVar1 = (self->super)._presentationSize.width;
    fVar2 = (self->super)._presentationSize.height;
    local_14 = self;
    local_10 = PTR_s_HSViewController_00350ab0;
    _objc_msgSendSuper(&local_14,sel_layout);
    cVar3 = _NSEqualSizes(fVar1,fVar2,(self->super)._presentationSize.width,
                          (self->super)._presentationSize.height);
    if (cVar3 == '\0') {
      pvVar4 = _objc_msgSend(self,sel_parentViewController);
      if (pvVar4 == (id)0x0) {
        pvVar4 = _objc_msgSend(self,sel_assistant);
        _objc_msgSend(pvVar4,sel_updateObjectScreenFrame_,1);
      }
    }
  }
  return;
}

*/
- (void)layout
{
    if (!_layoutIsValid) {
        NSSize oldSize = _presentationSize;
        [super layout];
        if (!NSEqualSizes(oldSize, _presentationSize)) {
            if ([self parentViewController] == nil) {
                [[self assistant] updateObjectScreenFrame:YES];
            }
        }
    }
}

- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription
{
    BOOL bVar1;

    bVar1 = _validateTextFieldsWithFormatters == NO;
    if (bVar1) {
        NSBeep();
    }
    else {
        [aControl abortEditing];
    }
    return !bVar1;
}

- (BOOL)shouldDismissWhenDisappeared
{
    return NO;
}

- (void)dismiss:(BOOL)aDismiss
{
    [self dismiss:aDismiss slide:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00103977 @ 00103977, 391 bytes * /

void FUN_00103977(HSObjectAssistantPane *self,SEL _cmd,BOOL dismiss,BOOL slide)

{
  HSObjectAssistantPane *self_00;
  id pvVar1;
  SEL op;
  HSObjectAssistantPane *pHVar2;
  
  self_00 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  pHVar2 = self;
  if (self_00 == (HSObjectAssistantPane *)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isModalViewController);
    if ((char)pvVar1 != '\0') {
      op = sel_dismissModalViewControllerAnimated_;
      pHVar2 = (HSObjectAssistantPane *)(int)dismiss;
      goto LAB_00103a31;
    }
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_canGoBack);
    op = sel_assistantGoBack_;
    if ((char)pvVar1 != '\0') goto LAB_00103a31;
    self = _objc_msgSend(self,sel_assistant);
  }
  else {
    pvVar1 = _objc_msgSend(self_00,sel_viewControllers);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar1 != (id)0x1) {
      self = self_00;
      op = sel_popViewControllerAnimated_slide_;
      pHVar2 = (HSObjectAssistantPane *)(uint)(byte)dismiss;
      goto LAB_00103a31;
    }
    pvVar1 = _objc_msgSend(self_00,sel_isModalViewController);
    if ((char)pvVar1 != '\0') {
      op = sel_dismissModalViewControllerAnimated_;
      pHVar2 = (HSObjectAssistantPane *)(int)dismiss;
      goto LAB_00103a31;
    }
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_canGoBack);
    op = sel_assistantGoBack_;
    if ((char)pvVar1 != '\0') goto LAB_00103a31;
    self = _objc_msgSend(self,sel_assistant);
  }
  op = sel_hideAssistant_;
  pHVar2 = (HSObjectAssistantPane *)0x0;
LAB_00103a31:
  _objc_msgSend(self,op,pHVar2);
  return;
}

*/
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide
{
    id navigationController = [self objectAssistantNavigationController];
    if (navigationController == nil) {
        if ([self isModalViewController]) {
            [self dismissModalViewControllerAnimated:aDismiss];
        } else if ([[self assistant] canGoBack]) {
            [self assistantGoBack:self];
        } else {
            [[self assistant] hideAssistant:NO];
        }
    } else {
        if ([[navigationController viewControllers] count] != 1) {
            [navigationController popViewControllerAnimated:aDismiss slide:aSlide];
        } else if ([navigationController isModalViewController]) {
            [self dismissModalViewControllerAnimated:aDismiss];
        } else if ([[self assistant] canGoBack]) {
            [self assistantGoBack:self];
        } else {
            [[self assistant] hideAssistant:NO];
        }
    }
}

- (BOOL)isEditingTextAttribute
{
    return NO;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([self isEditingTextAttribute]) {
        _validateTextFieldsWithFormatters = YES;
        [[self window] makeFirstResponder:[self window]];
        _validateTextFieldsWithFormatters = NO;
    }
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self window] makeFirstResponder:[self initialKeyView]];
    [[self window] recalculateKeyViewLoop];
    [[self assistant] updateAssistantWithShowedPane:self];
}

- (void)paneDidCancel:(id)aCancel
{
    [self dismiss:YES];
}

- (void)assistantGoBack:(id)aBack
{
    [_assistant assistantGoBack:aBack];
}

- (void)setWindowTitle:(id)aTitle
{
    if (![_windowTitle isEqualToString:aTitle]) {
        [_windowTitle release];
        _windowTitle = [aTitle retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001037a8 @ 001037a8, 269 bytes * /

id FUN_001037a8(HSObjectAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar2 = self->_windowTitle;
  if (pvVar2 == (id)0x0) {
    puVar3 = sel_windowTitle;
    pvVar1 = _objc_msgSend((self->super)._modalViewController,sel_respondsToSelector_,
                           sel_windowTitle);
    if ((char)pvVar1 != '\0') {
      pvVar2 = _objc_msgSend((self->super)._modalViewController,sel_windowTitle,puVar3);
    }
    if (pvVar2 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_assistant,puVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_object);
      puVar3 = &DAT_0036f8b8;
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036f8b8);
      self_00 = cls_NSString;
      if (pvVar1 != (id)0x0) {
        pvVar2 = _objc_msgSend(pvVar1,sel_hyperName,puVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperKindDisplayName);
        pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr________,pvVar1,pvVar2);
      }
    }
  }
  return pvVar2;
}

*/
- (id)windowTitle
{
    id title = _windowTitle;
    if (title == nil) {
        if ([_modalViewController respondsToSelector:@selector(windowTitle)]) {
            title = [_modalViewController windowTitle];
        }
        if (title == nil) {
            id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
            if (attributes != nil) {
                title = [NSString stringWithFormat:@"%@ : %@", [attributes hyperKindDisplayName], [attributes hyperName]];
            }
        }
    }
    return title;
}

- (id)helpTopicKey
{
    return @"HSHomeTopic";
}

- (id)stack
{
    return [[[[self assistant] object] queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
}

- (id)card
{
    return [[[[self assistant] object] queryHyperInterface:@protocol(HSUserObjectSupport)] card];
}

- (id)window
{
    return [[self view] window];
}

- (id)assistantPaneUndoManager
{
    return nil;
}

- (BOOL)needsToBeSavedInHistory
{
    return YES;
}

- (BOOL)assistantShouldBeKeyWindow
{
    BOOL BVar3;

    BVar3 = [[self window] defaultButtonCell] != nil;
    if (![self isVisible]) {
        if ([self parentViewController] != [self modalViewController]) {
            BVar3 = (BOOL)[[self modalViewController] assistantShouldBeKeyWindow];
        }
    }
    return BVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001033ed @ 001033ed, 512 bytes * /

void FUN_001033ed(HSObjectAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int iVar6;
  bool bVar7;
  undefined *puVar8;
  
  pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar3 = _objc_msgSend(self,sel_assistant);
  pvVar3 = _objc_msgSend(pvVar3,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_coachingPanesForObject_inStack_,pvVar3,pvVar2);
  pvVar4 = _objc_msgSend(pvVar1,sel_count);
  if (0 < (int)pvVar4) {
    pvVar3 = _objc_msgSend(pvVar1,sel_lastObject,pvVar3,pvVar2);
    puVar8 = sel_dropHelpPaneIdentifier;
    pvVar5 = _objc_msgSend(pvVar3,sel_respondsToSelector_,sel_dropHelpPaneIdentifier);
    if ((char)pvVar5 == '\0') {
      pvVar5 = (id)0x0;
    }
    else {
      puVar8 = sel_dropHelpPaneIdentifier;
      pvVar5 = _objc_msgSend(pvVar3,sel_performSelector_,sel_dropHelpPaneIdentifier,pvVar2);
    }
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,puVar8,pvVar2,pvVar5)
    ;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithRootViewController_identifier_,pvVar3,pvVar5);
    iVar6 = (int)pvVar4 + -2;
    if (-1 < iVar6) {
      do {
        pvVar3 = _objc_msgSend(pvVar1,sel_objectAtIndex_,iVar6,pvVar5);
        pvVar5 = (id)0x0;
        _objc_msgSend(pvVar2,sel_pushViewController_animate_,pvVar3);
        bVar7 = iVar6 != 0;
        iVar6 = iVar6 + -1;
      } while (bVar7);
    }
    _objc_msgSend(self,sel_presentModalViewController_animated_,pvVar2,0);
    _objc_msgSend(pvVar2,sel_release);
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pvVar2 = _objc_msgSend(self,sel_stack);
    _objc_msgSend(pvVar1,sel_removeAllObjectsForStack_,pvVar2);
  }
  return;
}

*/
- (void)showCoachingHelpIfNeeded
{
    id panes = [[HSCoachingHelpManager sharedCoachingHelpManager] coachingPanesForObject:[[self assistant] object] inStack:[self stack]];
    NSInteger count = [panes count];
    if (count > 0) {
        id last = [panes lastObject];
        id identifier = nil;
        if ([last respondsToSelector:@selector(dropHelpPaneIdentifier)]) {
            identifier = [last performSelector:@selector(dropHelpPaneIdentifier)];
        }
        id navigation = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:last identifier:identifier];
        NSInteger index = count - 2;
        while (index >= 0) {
            [navigation pushViewController:[panes objectAtIndex:index] animate:NO];
            index--;
        }
        [self presentModalViewController:navigation animated:NO];
        [navigation release];
        [[HSCoachingHelpManager sharedCoachingHelpManager] removeAllObjectsForStack:[self stack]];
    }
}

- (void)dismissModalViewControllerAnimated:(BOOL)aAnimated
{
    [super dismissModalViewControllerAnimated:aAnimated];
    [[self assistant] updateObjectScreenFrame:YES];
    [[self assistant] setHasSeparatedFooter:(unsigned int)([self footerView] != nil)];
}

- (void)presentModalViewControllerAsRootViewController:(id)aController withIdentifier:(id)aIdentifier
{
    id pvVar1_2;

    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:aController identifier:aIdentifier];
    [self presentModalViewController:pvVar1_2 animated:YES];
    [pvVar1_2 release];
}

- (void)presentModalViewControllerAsRootViewController:(id)aController
{
    [self presentModalViewControllerAsRootViewController:aController withIdentifier:nil];
}

- (void)presentModalViewController:(id)aController animated:(BOOL)aAnimated
{
    [super presentModalViewController:aController animated:aAnimated];
    [[self assistant] updateObjectScreenFrameIfNeeded:YES];
    [[self assistant] setHasSeparatedFooter:(unsigned int)([aController footerView] != nil)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001042d5 @ 001042d5, 161 bytes * /

void FUN_001042d5(HSObjectAssistantPane *self,SEL _cmd,id setFooterView)

{
  char cVar1;
  id self_00;
  id pvVar2;
  HSObjectAssistantPane *pHVar3;
  HSObjectAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSViewController_00350ab0;
  _objc_msgSendSuper(&local_1c,sel_setFooterView_,setFooterView);
  self_00 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(self,sel_footerView);
  if (pvVar2 != (id)0x0) {
    pHVar3 = _objc_msgSend(self,sel_rootViewController);
    if (pHVar3 == self) {
      cVar1 = '\x01';
      goto LAB_00104355;
    }
  }
  cVar1 = '\0';
LAB_00104355:
  _objc_msgSend(self_00,sel_setHasSeparatedFooter_,(int)cVar1);
  return;
}

*/
- (void)setFooterView:(id)aView
{
    [super setFooterView:aView];
    [[self assistant] setHasSeparatedFooter:([self footerView] != nil && [self rootViewController] == self)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00104376 @ 00104376, 385 bytes * /

void FUN_00104376(HSObjectAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_nibBundle);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  }
  pvVar2 = _objc_msgSend(self,sel_zone);
  pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,self,&cfstr_NSOwner);
  pvVar4 = _objc_msgSend(self,sel_nibName);
  _objc_msgSend(pvVar1,sel_loadNibFile_externalNameTable_withZone_,pvVar4,pvVar3,pvVar2);
  if ((self->_window != (id)0x0) && ((self->super)._view == (id)0x0)) {
    pvVar1 = _objc_msgSend(self->_window,sel_contentView,pvVar4,pvVar3,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    (self->super)._view = pvVar1;
    _objc_msgSend(self->_window,sel_release);
    self->_window = (id)0x0;
  }
  pvVar1 = (self->super)._view;
  if (pvVar1 != (id)0x0) {
    _objc_msgSend_stret(local_24,pvVar1,sel_frame);
    (self->super)._originalSize.width = local_1c;
    (self->super)._originalSize.height = local_18;
    _objc_msgSend(self,sel_createPresentationView);
    _objc_msgSend(self,sel_viewDidLoad);
  }
  return;
}

*/
- (void)loadView
{
    NSBundle *bundle = [self nibBundle];
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    [bundle loadNibFile:[self nibName] externalNameTable:[NSDictionary dictionaryWithObject:self forKey:@"NSOwner"] withZone:[self zone]];
    if (_window != nil && _view == nil) {
        _view = [[_window contentView] retain];
        [_window release];
        _window = nil;
    }
    if (_view != nil) {
        _originalSize = [_view frame].size;
        [self createPresentationView];
        [self viewDidLoad];
    }
}

- (BOOL)isEnabled
{
    if ([[self object] implementsHyperInterface:@protocol(HSCardObjectAttributes)]) {
        if ([[[self object] queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
            return NO;
        }
    }
    return ![[self object] implementsHyperInterface:@protocol(HSEmbeddedEditor)];
}

- (void)setObjectAssistantPaneDelegate:(id)aDelegate
{
    _objectAssistantPaneDelegate = aDelegate;
}

- (id)objectAssistantPaneDelegate
{
    return _objectAssistantPaneDelegate;
}

- (void)setObject:(id)aObject
{
    if (_object != aObject) {
        [_object release];
        _object = [aObject retain];
    }
}

- (id)object
{
    return _object;
}

- (BOOL)requiresDarkBottomArea
{
    BOOL bVar2;

    if ([self footerView] == nil) {
        bVar2 = [[self modalViewController] footerView] != nil;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (BOOL)isEqual:(id)aEqual
{
    if ([self class] == [aEqual class]) {
        if ([[self nibName] isEqual:[aEqual nibName]]) {
            return YES;
        }
    }
    return (BOOL)[super isEqual:aEqual];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithNibName:[self nibName]];
}

- (void)dealloc
{
    [_assistant release];
    [_windowTitle release];
    [_object release];
    [super dealloc];
}

- (void)setAssistant:(id)aAssistant
{
    if (_assistant != aAssistant) {
        [_assistant release];
        _assistant = [aAssistant retain];
    }
}

- (BOOL)needToRelayoutAssistant
{
    return YES;
}

- (id)assistant
{
    return _assistant;
}

@end

@implementation HSObjectAssistantPaneWithApplier

/* i386 ivar offsets: _applier=0x5c, _delegate=0x60, _userMadeTheDecision=0x64 */

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)paneDidCancel:(id)aCancel
{
    _userMadeTheDecision = YES;
    [self revertSettingsOnCancel];
    [super paneDidCancel:aCancel];
}

- (void)paneDidOK:(id)aOK
{
    if ([[self window] makeFirstResponder:[self window]]) {
        _userMadeTheDecision = YES;
        [self applySettingsOnOK];
        [self dismiss:YES slide:NO];
    }
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    if (_userMadeTheDecision != NO) {
        [self restoreApplierSettings];
    }
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if (_userMadeTheDecision != NO) {
        [self updateObjectWithApplier];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _userMadeTheDecision = YES;
}

- (void)applySettingsOnOK
{
    [[self applier] applyChanges];
    [[self applier] makeInitialEqualToCurrent];
}

- (void)revertSettingsOnCancel
{
    [[self applier] revertChanges];
}

- (void)restoreApplierSettings
{
    if (_userMadeTheDecision == NO) {
        [[self applier] restoreIfNotApplied];
    }
}

- (void)updateObjectWithApplier
{
    _userMadeTheDecision = NO;
    [[self applier] updateObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00103b63 @ 00103b63, 225 bytes * /

id FUN_00103b63(HSObjectAssistantPaneWithApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  if (self->_applier == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_applierClass);
      pvVar1 = _objc_msgSend(pvVar1,sel_alloc);
      pvVar2 = _objc_msgSend(self,sel_assistant);
      pvVar2 = _objc_msgSend(pvVar2,sel_object);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithObject_,pvVar2);
      self->_applier = pvVar1;
      _objc_msgSend(pvVar1,sel_setDelegate_,self);
      _objc_msgSend(self->_applier,sel_setUpInitialSettings);
    }
  }
  return self->_applier;
}

*/
- (id)applier
{
    if (_applier == nil) {
        if ([[self assistant] object] != nil) {
            _applier = [[[self applierClass] alloc] initWithObject:[[self assistant] object]];
            [_applier setDelegate:self];
            [_applier setUpInitialSettings];
        }
    }
    return _applier;
}

- (Class)applierClass
{
    [self doesNotRecognizeSelector:_cmd];
    return Nil;
}

- (void)dealloc
{
    [_applier setDelegate:0];
    [_applier release];
    [super dealloc];
}

@end

