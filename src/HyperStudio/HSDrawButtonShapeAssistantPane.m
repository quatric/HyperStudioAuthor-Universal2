#import "HSDrawButtonShapeAssistantPane.h"

@implementation HSDrawButtonShapeAssistantPane

/* i386 ivar offsets: _paneState=0x8c, _toolTag=0x90, _behaveAsCancel=0x94 */

- (BOOL)shouldEnableBackButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return [[[[HSEditorController sharedDocumentController] currentDocument] windowForSheet] attachedSheet] == nil;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return NO;
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00195da3 @ 00195da3, 101 bytes * /

id FUN_00195da3(HSDrawButtonShapeAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  SEL op;
  
  self_00 = cls_HSNavigationPaneSwitcherWithCancelButton;
  op = sel_new;
  if (self->_behaveAsCancel == '\0') {
    self_00 = _objc_msgSend(cls_HSObjectAssistantNavigationPaneSwitcher,sel_alloc);
    op = sel_initWithNibName_;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)newBackgroundImage
{
    if (_behaveAsCancel) {
        return [HSNavigationPaneSwitcherWithCancelButton new];
    }
    return [[HSObjectAssistantNavigationPaneSwitcher alloc] initWithNibName:@"ModeAssistantPaneSwitcher"];
    return 0;
}

- (void)activateTool
{
    NSInteger pvVar1_2;
    id pvVar1_4;

    [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    pvVar1_2 = [self toolTag];
    [[HSToolManager sharedToolManager] selectToolWithTag:pvVar1_2 setAsPermanent:NO];
    pvVar1_4 = [[HSToolManager sharedToolManager] currentTool];
    [[self buttonObjectInterface] setHiddenInEditor:YES];
    [pvVar1_4 setDelegate:self];
    [[[HSToolManager sharedToolManager] toolView] setOccupiedByTool:YES];
}

- (void)paneWillGoBack:(id)aBack
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide
{
    [self runDidDoneDelegateSelector];
    [super dismiss:aDismiss slide:aSlide];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00195aa1 @ 00195aa1, 392 bytes * /

void FUN_00195aa1(HSDrawButtonShapeAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id local_18;
  HSDrawButtonShapeAssistantPane *local_14;
  
  local_14 = self;
  pvVar1 = _objc_msgSend(self,sel_didDoneDelegate);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(local_14,sel_didDoneSelector);
    self_00 = cls_NSInvocation;
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(local_14,sel_didDoneDelegate);
      pvVar2 = _objc_msgSend(local_14,sel_didDoneSelector);
      pvVar1 = _objc_msgSend(pvVar1,sel_methodSignatureForSelector_,pvVar2);
      pvVar1 = _objc_msgSend(self_00,sel_invocationWithMethodSignature_,pvVar1);
      pvVar2 = _objc_msgSend(local_14,sel_didDoneSelector);
      _objc_msgSend(pvVar1,sel_setSelector_,pvVar2);
      pvVar2 = _objc_msgSend(local_14,sel_didDoneDelegate);
      _objc_msgSend(pvVar1,sel_setTarget_,pvVar2);
      _objc_msgSend(pvVar1,sel_retainArguments);
      _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_14,2);
      local_18 = _objc_msgSend(local_14,sel_didDoneContextInfo);
      _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_18,3);
      _objc_msgSend(pvVar1,sel_invoke);
    }
  }
  return;
}

*/
- (void)runDidDoneDelegateSelector
{
    id strongSelf = self;
    if ([self didDoneDelegate] != nil && [self didDoneSelector] != NULL) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self didDoneDelegate] methodSignatureForSelector:[self didDoneSelector]]];
        [invocation setSelector:[self didDoneSelector]];
        [invocation setTarget:[self didDoneDelegate]];
        [invocation retainArguments];
        [invocation setArgument:&strongSelf atIndex:2];
        id contextInfo = [self didDoneContextInfo];
        [invocation setArgument:&contextInfo atIndex:3];
        [invocation invoke];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00195a18 @ 00195a18, 137 bytes * /

void FUN_00195a18(HSDrawButtonShapeAssistantPane *self,SEL _cmd,BOOL setButtonIsCancel)

{
  HSDrawButtonShapeAssistantPane *pHVar1;
  
  if (self->_behaveAsCancel != setButtonIsCancel) {
    pHVar1 = _objc_msgSend((self->super).super._helpAssistantPaneSwitcher,sel_delegate);
    if (pHVar1 == self) {
      _objc_msgSend((self->super).super._helpAssistantPaneSwitcher,sel_setDelegate_,0);
    }
    _objc_msgSend((self->super).super._helpAssistantPaneSwitcher,sel_release);
    (self->super).super._helpAssistantPaneSwitcher = (id)0x0;
    self->_behaveAsCancel = setButtonIsCancel;
  }
  return;
}

*/
- (void)setButtonIsCancel:(BOOL)aCancel
{
    if (_behaveAsCancel != aCancel) {
        if ([_helpAssistantPaneSwitcher delegate] == self) {
            [_helpAssistantPaneSwitcher setDelegate:nil];
        }
        [_helpAssistantPaneSwitcher release];
        _helpAssistantPaneSwitcher = nil;
        _behaveAsCancel = aCancel;
    }
}

- (BOOL)buttonIsCancel
{
    return _behaveAsCancel;
}

- (NSInteger)toolTag
{
    return _toolTag;
}

- (void)setToolTag:(NSInteger)aTag
{
    _toolTag = aTag;
}

- (id)shapeBackgroundInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
}

- (id)buttonObjectInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
}

- (void)applyShapeBackgroundStyleWithButtonType
{
    [[self buttonObjectInterface] setBackgroundStyle:[_paneState backgroundStyle]];
    [[self shapeBackgroundInterface] setShapeButtonType:[_paneState buttonType]];
    [[self buttonObjectInterface] setTitleVisible:[_paneState titleVisible]];
    [[self buttonObjectInterface] setHasHighlight:[_paneState highlight]];
    if ([[_paneState buttonType] isEqualToString:@"HSInvisibleShapeButtonType"]) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:[[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect]];
        [[self shapeBackgroundInterface] setBorderPath:path];
        [[self buttonObjectInterface] setContentOverlapsBackground:NO];
    }
}

- (void)toolDidCancelOperation:(id)aOperation
{
    [self leaveCurrentModeWithSelectingToolWithTag:1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001958ad @ 001958ad, 145 bytes * /

void FUN_001958ad(HSDrawButtonShapeAssistantPane *self,SEL _cmd,id alertDidEnd,int returnCode,
                 void *contextInfo)

{
  SEL op;
  
  _objc_msgSend(alertDidEnd,sel_release);
  op = sel_activateTool;
  if (returnCode == 0x3e9) {
    _objc_msgSend(self,sel_setShouldLeavePaneOnToolChange_,1);
    op = sel_dismiss_;
  }
  _objc_msgSend(self,op);
  _objc_msgSend((self->super).super._helpAssistantPaneSwitcher,sel_validateUserInterface);
  return;
}

*/
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    if (aCode == 0x3e9) {
        [self setShouldLeavePaneOnToolChange:YES];
        [self dismiss:YES];
    } else {
        [self activateTool];
    }
    [_helpAssistantPaneSwitcher validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001961ad @ 001961ad, 1374 bytes * /

void FUN_001961ad(HSDrawButtonShapeAssistantPane *self,SEL _cmd,id buttonShapeCreationTool,
                 id didFinalizeWithEvent)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  uint **ppuVar3;
  undefined4 *puVar4;
  uint *apuStack_68 [3];
  uint local_34;
  float local_30;
  float local_28;
  undefined1 local_24 [20];
  
  ppuVar3 = (uint **)&stack0xffffffa4;
  puVar4 = (undefined4 *)&stack0xffffffa4;
  apuStack_68[2] = (uint *)0x1961da;
  _objc_msgSend((id)0x0,sel_setCanGoBack_);
  apuStack_68[2] = (uint *)0x1961ef;
  pvVar1 = _objc_msgSend(buttonShapeCreationTool,sel_borderPath);
  if (pvVar1 == (id)0x0) {
    apuStack_68[2] = (uint *)0x19646a;
    pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
    apuStack_68[2] = (uint *)0x196484;
    _objc_msgSend(pvVar1,sel_setHiddenInEditor_);
    apuStack_68[2] = (uint *)0x19649c;
    pvVar1 = _objc_msgSend(cls_HSAlert,sel_alloc);
    apuStack_68[2] = (uint *)0x1964ae;
    pvVar1 = _objc_msgSend(pvVar1,sel_init);
    apuStack_68[2] = (uint *)0x1964c8;
    pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    apuStack_68[2] = (uint *)0x1964da;
    pvVar2 = _objc_msgSend(pvVar2,sel_currentDocument);
    apuStack_68[2] = (uint *)0x1964ec;
    _objc_msgSend(pvVar2,sel_windowForSheet);
    apuStack_68[2] = (uint *)0x196507;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    apuStack_68[2] = (uint *)0x196537;
    _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
    apuStack_68[2] = (uint *)0x19654d;
    _objc_msgSend(pvVar1,sel_setInformativeText_);
    apuStack_68[2] = (uint *)0x196565;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    apuStack_68[2] = (uint *)0x196595;
    _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
    apuStack_68[2] = (uint *)0x1965ab;
    _objc_msgSend(pvVar1,sel_setMessageText_);
    apuStack_68[2] = (uint *)0x1965c3;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    apuStack_68[2] = (uint *)0x1965f3;
    _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
    apuStack_68[2] = (uint *)0x196609;
    _objc_msgSend(pvVar1,sel_addButtonWithTitle_);
    apuStack_68[2] = (uint *)0x196621;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    apuStack_68[2] = (uint *)0x196651;
    _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
    apuStack_68[2] = (uint *)0x196667;
    _objc_msgSend(pvVar1,sel_addButtonWithTitle_);
    apuStack_68[2] = (uint *)0x196699;
    _objc_msgSend(pvVar1,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_);
    apuStack_68[2] = (uint *)0x1966b6;
    _objc_msgSend(self,sel_setShouldLeavePaneOnToolChange_);
    apuStack_68[2] = (uint *)0x1966ce;
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    apuStack_68[2] = (uint *)0x1966f0;
    _objc_msgSend(pvVar1,sel_setLocked_delegate_);
  }
  else {
    apuStack_68[2] = (uint *)0x196211;
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    apuStack_68[2] = (uint *)0x196233;
    _objc_msgSend(pvVar2,sel_setLocked_delegate_);
    apuStack_68[2] = (uint *)0x19624e;
    pvVar2 = _objc_msgSend(self->_paneState,sel_buttonType);
    apuStack_68[2] = (uint *)0x19626a;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_);
    if ((char)pvVar2 == '\0') {
      apuStack_68[2] = (uint *)0x1962d0;
      _objc_msgSend_stret(&local_34,pvVar1,sel_bounds);
    }
    else {
      apuStack_68[2] = (uint *)0x196287;
      _objc_msgSend_stret(local_24,pvVar1,sel_bounds);
      ppuVar3 = apuStack_68 + 2;
      apuStack_68[2] = &local_34;
      _NSInsetRect();
    }
    puVar4 = ppuVar3 + -1;
    *ppuVar3 = (uint *)sel_transform;
    ppuVar3[-1] = (uint *)cls_NSAffineTransform;
    ppuVar3[-2] = (uint *)0x1962eb;
    pvVar2 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    ppuVar3[2] = (uint *)-local_30;
    ppuVar3[1] = (uint *)(local_34 ^ 0x80000000);
    *ppuVar3 = (uint *)sel_translateXBy_yBy_;
    ppuVar3[-1] = pvVar2;
    ppuVar3[-2] = (uint *)0x196323;
    _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    ppuVar3[1] = pvVar2;
    *ppuVar3 = (uint *)sel_transformUsingAffineTransform_;
    ppuVar3[-1] = pvVar1;
    ppuVar3[-2] = (uint *)0x196339;
    _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_stack;
    ppuVar3[-1] = (uint *)self;
    ppuVar3[-2] = (uint *)0x19634e;
    pvVar2 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_hyperCardSize;
    ppuVar3[-1] = pvVar2;
    ppuVar3[-2] = (uint *)0x196360;
    _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    local_30 = extraout_EDX - (local_28 + local_30);
    *ppuVar3 = (uint *)sel_applyShapeBackgroundStyleWithButtonType;
    ppuVar3[-1] = (uint *)self;
    ppuVar3[-2] = (uint *)0x196389;
    _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_shapeBackgroundInterface;
    ppuVar3[-1] = (uint *)self;
    ppuVar3[-2] = (uint *)0x19639b;
    pvVar2 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    ppuVar3[1] = pvVar1;
    *ppuVar3 = (uint *)sel_setBorderPath_;
    ppuVar3[-1] = pvVar2;
    ppuVar3[-2] = (uint *)0x1963b1;
    _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_assistant;
    ppuVar3[-1] = (uint *)self;
    ppuVar3[-2] = (uint *)0x1963c3;
    pvVar1 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_object;
    ppuVar3[-1] = pvVar1;
    ppuVar3[-2] = (uint *)0x1963d5;
    pvVar1 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    ppuVar3[1] = (uint *)&DAT_0037ae0c;
    *ppuVar3 = (uint *)sel_queryHyperInterface_;
    ppuVar3[-1] = pvVar1;
    ppuVar3[-2] = (uint *)0x1963f1;
    pvVar1 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_queryGeometryBehaviorApplier;
    ppuVar3[-1] = pvVar1;
    ppuVar3[-2] = (uint *)0x196403;
    pvVar1 = _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    ppuVar3[2] = (uint *)local_30;
    ppuVar3[1] = (uint *)local_34;
    *ppuVar3 = (uint *)sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_;
    ppuVar3[-1] = pvVar1;
    ppuVar3[3] = (uint *)0x0;
    ppuVar3[-2] = (uint *)0x196433;
    _objc_msgSend(ppuVar3[-1],(SEL)*ppuVar3);
    *ppuVar3 = (uint *)sel_dismiss_;
    ppuVar3[-1] = (uint *)self;
    ppuVar3[1] = (uint *)0x1;
  }
  puVar4[-1] = 0x19644d;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return;
}

*/
- (void)buttonShapeCreationTool:(id)aTool didFinalizeWithEvent:(id)aEvent
{
    /* the original sends setCanGoBack: to nil here, which does nothing */
    id path = [aTool borderPath];
    if (path == nil) {
        [[self buttonObjectInterface] setHiddenInEditor:NO];
        HSAlert *alert = [[HSAlert alloc] init];
        id window = [[[HSEditorController sharedDocumentController] currentDocument] windowForSheet];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSDrawBttonShapeInformativeText" value:@"" table:@"Alerts"]];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSDrawBttonShapeMessageText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Try Again" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        [self setShouldLeavePaneOnToolChange:NO];
        [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
        [_helpAssistantPaneSwitcher validateUserInterface];
        return;
    }
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    NSRect bounds;
    if ([[_paneState buttonType] isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
        bounds = NSInsetRect([path bounds], -0.5, -0.5);
    } else {
        bounds = [path bounds];
    }
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:-bounds.origin.x yBy:-bounds.origin.y];
    [path transformUsingAffineTransform:transform];
    NSSize cardSize = [[self stack] hyperCardSize];
    bounds.origin.y = cardSize.height - (bounds.size.height + bounds.origin.y);
    [self applyShapeBackgroundStyleWithButtonType];
    [[self shapeBackgroundInterface] setBorderPath:path];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:bounds.origin withLayoutGuidingContext:nil];
    [self dismiss:YES];
}

- (id)paneState
{
    return _paneState;
}

- (void)setPaneState:(id)aState
{
    if (_paneState != aState) {
        [_paneState release];
        _paneState = [aState retain];
    }
}

- (void)leaveCurrentModeWithSelectingToolWithTag:(NSInteger)aTag
{
    [[[HSToolManager sharedToolManager] toolView] setOccupiedByTool:NO];
    [super leaveCurrentModeWithSelectingToolWithTag:aTag];
    [[self buttonObjectInterface] setHiddenInEditor:NO];
}

- (id)modeToolTags
{
    NSNumber *pvVar1;
    NSNumber *pvVar2;

    pvVar1 = [NSNumber numberWithUnsignedInt:0x3d];
    pvVar2 = [NSNumber numberWithUnsignedInt:0x3c];
    return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0x3b], pvVar2, pvVar1, nil];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [self setShouldLeavePaneOnToolChange:YES];
    [self activateTool];
    [super viewWillAppear:aAppear];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [_paneState release];
    _paneState = nil;
    [super viewWillDisappear:aDisappear];
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

@end

