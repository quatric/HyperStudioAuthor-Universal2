#import "HSObjectAssistantController.h"
static id sDAT_00342924;

static id sDAT_00342924;


@implementation HSObjectAssistantController

/* i386 ivar offsets: _selectedInModelObject=0x4, _selectedObject=0x8, _newObjectRef=0xc, _objectAssistant=0x10, _mainWindow=0x14, _lockedDelegate=0x18, _historyByObject=0x1c, _objectsByContainer=0x20, _lastNonEmptyRect=0x24, _lastAddedChildren=0x34, _objectAssistantControllerProxy=0x38, _temporaryHideTimer=0x3c, _temporaryShowTimer=0x40, _updateObjectScreenFrameTimer=0x44, _locked=0x48, _geometryLocked=0x48, _active=0x48, _wasOpenExplicitlyByUser=0x48, _newObjectDidAdd=0x48, _shouldOpenCardInfo=0x48, _temporaryHide=0x48, _isRecordingMovie=0x48, _isRecordingSound=0x49, reserved=0x49 */

+ (id)sharedAssistantController
{
    if (sDAT_00342924 == nil) {
        sDAT_00342924 = [HSObjectAssistantController new];
    }
    return sDAT_00342924;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001016f5 @ 001016f5, 139 bytes * /

id FUN_001016f5(HSObjectAssistantController *self,SEL _cmd)

{
  ushort uVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  if ((uVar1 & 8) == 0) {
    pcVar3 = &cfstr_OK;
  }
  else {
    pcVar3 = &cfstr_Continue;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,
                         &cfstr_AssistantPanes);
  return pvVar2;
}

*/
- (id)coachingHintDefaultButton
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:_wasOpenExplicitlyByUser ? @"Continue" : @"OK" value:@"" table:@"AssistantPanes"];
}

- (void)openDefaultEditingPaneForObject:(id)aObject
{
    if (![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
        if (![self isLocked]) {
            [self setSelectedInModelObjectAndBringAssistantToFront:aObject];
            [self setActive:YES explicitlyByUser:YES];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00101463 @ 00101463, 501 bytes * /

void FUN_00101463(HSObjectAssistantController *self,SEL _cmd,NSRange selectObjectNameWithRange)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_isActive);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_objectAssistant);
    _objc_msgSend(pvVar1,sel_showAssistant_,1);
  }
  pvVar1 = _objc_msgSend(self,sel_objectAssistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentPane);
  pvVar2 = _objc_msgSend(pvVar1,sel_modalViewController);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(pvVar1,sel_dismissModalViewControllerAnimated_,1);
  }
  pvVar2 = _objc_msgSend(self,sel_objectAssistant);
  _objc_msgSend(pvVar2,sel_openPaneWithIdentifier_,*(undefined4 *)PTR_PTR_00336094);
  puVar3 = sel_selectedViewController;
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_selectedViewController);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedViewController,puVar3);
    self_00 = _objc_msgSend(pvVar1,sel_nameTextfField);
    pvVar1 = _objc_msgSend(self_00,sel_currentEditor);
    pvVar2 = _objc_msgSend(self,sel_objectAssistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_window);
    pvVar2 = _objc_msgSend(pvVar2,sel_firstResponder);
    if (pvVar1 != pvVar2) {
      pvVar1 = _objc_msgSend(self,sel_objectAssistant);
      pvVar1 = _objc_msgSend(pvVar1,sel_window);
      puVar3 = self_00;
      _objc_msgSend(pvVar1,sel_makeFirstResponder_,self_00);
    }
    pvVar1 = _objc_msgSend(self_00,sel_currentEditor,puVar3);
    _objc_msgSend(pvVar1,sel_setSelectedRange_,selectObjectNameWithRange.location,
                  selectObjectNameWithRange.length);
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0010138c @ 0010138c, 215 bytes * /

ulonglong FUN_0010138c(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 extraout_EDX;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_objectAssistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentPane);
  puVar4 = sel_selectedViewController;
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_selectedViewController);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedViewController,puVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_nameTextfField);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_currentEditor,puVar4);
      if (pvVar2 != (id)0x0) {
        pvVar1 = _objc_msgSend(pvVar1,sel_currentEditor,puVar4);
        pvVar1 = _objc_msgSend(pvVar1,sel_selectedRange);
        uVar3 = extraout_EDX;
        goto LAB_00101458;
      }
    }
  }
  pvVar1 = (id)0x7fffffff;
  uVar3 = 0;
LAB_00101458:
  return CONCAT44(uVar3,pvVar1);
}

*/
- (void)openHypertextLinksPaneForField:(id)aField selectedObject:(id)aObject initialText:(id)aText stack:(id)aStack
{
    if (aField == nil) {
        aField = aObject;
    }
    [[[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:[self stack]] setupHypertextLinksPaneWithInitialText:aText initialStack:aStack initialField:aField];
    [self setSelectedInModelObjectAndBringAssistantToFront:[[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:[self stack]]];
    [self setActive:YES explicitlyByUser:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001011df @ 001011df, 256 bytes * /

void FUN_001011df(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  
  if ((self->_locked[0] & 1) == 0) {
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_dontShowCoachingHintsForKey_,&cfstr_StoryboardCoaching);
    if ((char)pvVar1 == '\0') {
      _objc_msgSend(self,sel_setActive_explicitlyByUser_,1,0);
      pvVar1 = _objc_msgSend(cls_HSStoryboardHelpAssistantPane,sel_paneWithCoachingKey_,
                             &cfstr_StoryboardCoaching);
      self_00 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc);
      pvVar1 = _objc_msgSend(self_00,sel_initWithRootViewController_,pvVar1);
      _objc_msgSend(self,sel_openAssistantPaneWithoutObject_supportsSettingsOnTheSpotMode_,pvVar1,0)
      ;
      _objc_msgSend(pvVar1,sel_release);
    }
  }
  return;
}

*/
- (void)openEnterStoryboardCoachingPaneIfNeeded
{
    if (!_locked) {
        if (![[HSCoachingHelpManager sharedCoachingHelpManager] dontShowCoachingHintsForKey:@"StoryboardCoaching"]) {
            [self setActive:YES explicitlyByUser:NO];
            id pane = [HSStoryboardHelpAssistantPane paneWithCoachingKey:@"StoryboardCoaching"];
            id navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
            [self openAssistantPaneWithoutObject:navigationController supportsSettingsOnTheSpotMode:NO];
            [navigationController release];
        }
    }
}

- (void)openAssistantPaneWithoutObject:(id)aObject
{
    [self openAssistantPaneWithoutObject:aObject supportsSettingsOnTheSpotMode:YES];
}

- (void)openAssistantPaneWithoutObject:(id)aObject supportsSettingsOnTheSpotMode:(BOOL)aMode
{
    id pvVar1_2;

    pvVar1_2 = [[HSObjectAssistantNullObject alloc] initWithRootViewController:aObject supportsSettingsOnTheSpotMode:(unsigned int)aMode];
    [self setAtomicSelectedInModelObjectAndBringAssistantToFront:pvVar1_2];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00101057 @ 00101057, 216 bytes * /

id FUN_00101057(HSObjectAssistantController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036f494);
  pvVar1 = _objc_msgSend(pvVar1,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_displayName);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036f3b8);
  self_00 = cls_NSString;
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperKindDisplayName);
  pvVar1 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr________,pvVar2,pvVar1);
  return pvVar1;
}

*/
- (id)stackAssistantTitle
{
    NSString *name = [[[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] document] displayName];
    NSString *kind = [[[self stack] queryHyperInterface:@protocol(HSObjectAttributes)] hyperKindDisplayName];
    return [NSString stringWithFormat:@"%@ : %@", kind, name];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdfe9 @ 000fdfe9, 36 bytes * /

void FUN_000fdfe9(HSObjectAssistantController *self,SEL _cmd,BOOL setIsRecordingSound)

{
  ushort uVar1;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  *(ushort *)self->_locked = (ushort)(setIsRecordingSound & 1) * 0x100 + (uVar1 & 0xfeff);
  return;
}

*/
- (void)setIsRecordingSound:(BOOL)aSound
{
    [[[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] document] setIsRecordingSound:aSound];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdfd0 @ 000fdfd0, 25 bytes * /

BOOL FUN_000fdfd0(HSObjectAssistantController *self,SEL _cmd)

{
  ushort uVar1;
  BOOL BVar2;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  BVar2 = -1;
  if ((uVar1 & 0x100) == 0) {
    BVar2 = '\0';
  }
  return BVar2;
}

*/
- (BOOL)isRecordingSound
{
    return [[[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] document] isRecordingSound];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdfac @ 000fdfac, 36 bytes * /

void FUN_000fdfac(HSObjectAssistantController *self,SEL _cmd,BOOL setIsRecordingMovie)

{
  ushort uVar1;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  *(ushort *)self->_locked = (ushort)(setIsRecordingMovie & 1) * 0x80 + (uVar1 & 0xff7f);
  return;
}

*/
- (void)setIsRecordingMovie:(BOOL)aMovie
{
    [[[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] document] setIsRecordingMovie:aMovie];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdf94 @ 000fdf94, 24 bytes * /

BOOL FUN_000fdf94(HSObjectAssistantController *self,SEL _cmd)

{
  ushort uVar1;
  BOOL BVar2;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  BVar2 = -1;
  if ((uVar1 & 0x80) == 0) {
    BVar2 = '\0';
  }
  return BVar2;
}

*/
- (BOOL)isRecordingMovie
{
    return [[[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] document] isRecordingMovie];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100f79 @ 00100f79, 222 bytes * /

void FUN_00100f79(HSObjectAssistantController *self,SEL _cmd,BOOL setLocked,id delegate)

{
  ushort uVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  *(ushort *)self->_locked = (uVar1 & 0xfffe) + (ushort)(setLocked & 1);
  self->_lockedDelegate = delegate;
  _objc_msgSend(self,sel_noteCanChangeActiveDidChange);
  puVar3 = &DAT_0036f458;
  pvVar2 = _objc_msgSend(self->_selectedInModelObject,sel_queryHyperInterface_,&DAT_0036f458);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController,puVar3);
    op = sel_removeObserver_selector_ofChanges_ofAttribute_;
    if (setLocked != '\0') {
      op = sel_addObserver_selector_ofChanges_ofAttribute_withPriority_;
    }
    _objc_msgSend(pvVar2,op,self,sel_supportChangingInLockedStateForSelectedObject_,1,&DAT_0036f46c)
    ;
  }
  return;
}

*/
- (void)setLocked:(BOOL)aLocked delegate:(id)aDelegate
{
    _locked = aLocked;
    _lockedDelegate = aDelegate;
    [self noteCanChangeActiveDidChange];
    id nodeSupport = [_selectedInModelObject queryHyperInterface:@protocol(HSNodeSupportAttributes)];
    if (nodeSupport != nil) {
        id observingController = [nodeSupport attributeObservingController];
        if (aLocked) {
            [observingController addObserver:self selector:@selector(supportChangingInLockedStateForSelectedObject:) ofChanges:1 ofAttribute:@protocol(HSNodeSupportAttribute) withPriority:0.25];
        } else {
            [observingController removeObserver:self selector:@selector(supportChangingInLockedStateForSelectedObject:) ofChanges:1 ofAttribute:@protocol(HSNodeSupportAttribute)];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdf7c @ 000fdf7c, 24 bytes * /

BOOL FUN_000fdf7c(HSObjectAssistantController *self,SEL _cmd)

{
  ushort uVar1;
  BOOL BVar2;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  BVar2 = -1;
  if ((uVar1 & 1) == 0) {
    BVar2 = '\0';
  }
  return BVar2;
}

*/
- (BOOL)isLocked
{
    return _locked;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdf58 @ 000fdf58, 36 bytes * /

void FUN_000fdf58(HSObjectAssistantController *self,SEL _cmd,BOOL setTemporaryHide)

{
  ushort uVar1;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  *(ushort *)self->_locked = (ushort)(setTemporaryHide & 1) * 0x40 + (uVar1 & 0xffbf);
  return;
}

*/
- (void)setTemporaryHide:(BOOL)aHide
{
    _temporaryHide = aHide;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100f34 @ 00100f34, 69 bytes * /

BOOL FUN_00100f34(HSObjectAssistantController *self,SEL _cmd,id shouldOpenCardInfoForObject)

{
  ushort uVar1;
  byte bVar2;
  id pvVar3;
  
  pvVar3 = _objc_msgSend(shouldOpenCardInfoForObject,sel_implementsHyperInterface_,&DAT_0036f598);
  if ((char)pvVar3 == '\0') {
    bVar2 = 0;
  }
  else {
    uVar1._0_1_ = self->_locked[0];
    uVar1._1_1_ = self->_geometryLocked[0];
    bVar2 = (byte)(uVar1 >> 5) & 1;
  }
  return bVar2;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdf34 @ 000fdf34, 36 bytes * /

void FUN_000fdf34(HSObjectAssistantController *self,SEL _cmd,BOOL setShouldOpenCardInfo)

{
  ushort uVar1;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  *(ushort *)self->_locked = (ushort)(setShouldOpenCardInfo & 1) * 0x20 + (uVar1 & 0xffdf);
  return;
}

*/
- (void)setShouldOpenCardInfo:(BOOL)aInfo
{
    _shouldOpenCardInfo = aInfo;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fdf0a @ 000fdf0a, 42 bytes * /

void FUN_000fdf0a(HSObjectAssistantController *self,SEL _cmd,id setNewObject,BOOL didAdd)

{
  ushort uVar1;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  *(ushort *)self->_locked = (ushort)(didAdd & 1) * 0x10 + (uVar1 & 0xffef);
  self->_newObjectRef = setNewObject;
  return;
}

*/
- (void)setNewObject:(id)aObject didAdd:(BOOL)aAdd
{
    _newObjectDidAdd = aAdd;
    _newObjectRef = aObject;
}

- (void)setSupportsSettingsOnTheSpotMode:(BOOL)aMode
{
    [[self objectAssistant] setSupportsSettingsOnTheSpotMode:aMode]
    ;
}

- (BOOL)supportsSettingsOnTheSpotMode
{
    return (BOOL)[[self objectAssistant] supportsSettingsOnTheSpotMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100e0e @ 00100e0e, 167 bytes * /

void FUN_00100e0e(HSObjectAssistantController *self,SEL _cmd,BOOL setActive,BOOL explicitlyByUser)

{
  ushort uVar1;
  ushort uVar2;
  id self_00;
  undefined4 uVar3;
  
  if (explicitlyByUser != '\0') {
    uVar1._0_1_ = self->_locked[0];
    uVar1._1_1_ = self->_geometryLocked[0];
    *(ushort *)self->_locked = (ushort)(setActive & 1) * 8 + (uVar1 & 0xfff7);
    self_00 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    uVar2._0_1_ = self->_locked[0];
    uVar2._1_1_ = self->_geometryLocked[0];
    uVar3 = 0xffffffff;
    if ((uVar2 & 8) == 0) {
      uVar3 = 0;
    }
    _objc_msgSend(self_00,sel_setBool_forKey_,uVar3,
                  &cfstr_HSIsObjectAssistantControllerActivatedByUser);
  }
  _objc_msgSend(self,sel_setActive_storeInDefaults_,(int)setActive,1);
  return;
}

*/
- (void)setActive:(BOOL)aActive explicitlyByUser:(BOOL)aUser
{
    if (aUser) {
        _wasOpenExplicitlyByUser = aActive;
        [[NSUserDefaults standardUserDefaults] setBool:_wasOpenExplicitlyByUser forKey:HSIsObjectAssistantControllerActivatedByUser];
    }
    [self setActive:aActive storeInDefaults:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100dc9 @ 00100dc9, 69 bytes * /

void FUN_00100dc9(HSObjectAssistantController *self,SEL _cmd,BOOL setActive)

{
  ushort uVar1;
  undefined4 uVar2;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  uVar2 = 0xffffffff;
  if ((uVar1 & 8) == 0) {
    uVar2 = 0;
  }
  _objc_msgSend(self,sel_setActive_explicitlyByUser_,(int)setActive,uVar2);
  return;
}

*/
- (void)setActive:(BOOL)aActive
{
    [self setActive:aActive explicitlyByUser:_wasOpenExplicitlyByUser];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100d34 @ 00100d34, 149 bytes * /

void FUN_00100d34(HSObjectAssistantController *self,SEL _cmd,id deactivateIfNeededForObject)

{
  ushort uVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self,sel_isActive);
  if ((char)pvVar2 == '\0') {
    return;
  }
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  if ((((uVar1 & 8) != 0) || ((uVar1 & 0x10) != 0)) &&
     (pvVar2 = _objc_msgSend(self,sel_toolAllowsActivation), (char)pvVar2 != '\0')) {
    if ((self->_locked[0] & 8) == 0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_shouldOpenCardInfoForObject_,deactivateIfNeededForObject);
    if ((char)pvVar2 != '\0') {
      return;
    }
  }
  _objc_msgSend(self,sel_setActive_explicitlyByUser_,0,0);
  return;
}

*/
- (void)deactivateIfNeeded
{
    if (![self isActive])
        return;
    if ((_wasOpenExplicitlyByUser || _newObjectDidAdd) && [self toolAllowsActivation]) {
        if (!_wasOpenExplicitlyByUser)
            return;
        if ([self shouldOpenCardInfo])
            return;
    }
    [self setActive:NO explicitlyByUser:NO];
}

- (void)activateIfNeeded
{
    if ([NSApp isActive]) {
        if ([self shouldActivateForObject:_selectedInModelObject]) {
            [self setActive:YES storeInDefaults:NO];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100a4e @ 00100a4e, 580 bytes * /

BOOL FUN_00100a4e(HSObjectAssistantController *self,SEL _cmd,id shouldActivateForObject)

{
  ushort uVar1;
  ushort uVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  byte bVar9;
  undefined *puVar10;
  undefined4 uVar11;
  
  pvVar4 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  pvVar5 = _objc_msgSend(self,sel_stack);
  pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_0036f494);
  uVar11 = 0;
  pvVar4 = _objc_msgSend(pvVar4,sel_coachingPanesForObject_inStack_remove_,shouldActivateForObject,
                         pvVar5,0);
  pvVar6 = _objc_msgSend(shouldActivateForObject,sel_implementsHyperInterface_,&DAT_0036f534);
  puVar10 = &DAT_0036f598;
  pvVar7 = _objc_msgSend(shouldActivateForObject,sel_implementsHyperInterface_,&DAT_0036f598);
  pvVar8 = _objc_msgSend(pvVar4,sel_count);
  if (pvVar8 == (id)0x0) {
    cVar3 = '\0';
  }
  else {
    puVar10 = &DAT_0036f5ac;
    pvVar5 = _objc_msgSend(shouldActivateForObject,sel_implementsHyperInterface_,&DAT_0036f5ac,
                           pvVar5,uVar11);
    cVar3 = (char)pvVar5;
  }
  if (shouldActivateForObject != (id)0x0) {
    puVar10 = &DAT_0036f480;
    pvVar5 = _objc_msgSend(shouldActivateForObject,sel_queryHyperInterface_,&DAT_0036f480);
    pvVar5 = _objc_msgSend(pvVar5,sel_isLocked);
    if ((((char)pvVar5 == '\0') &&
        ((pvVar5 = _objc_msgSend(self,sel_toolAllowsActivation,puVar10), (char)pvVar5 != '\0' ||
         ((char)pvVar7 == '\0')))) &&
       (((self->_locked[0] & 8) != 0 ||
        (pvVar5 = _objc_msgSend(pvVar4,sel_count,puVar10), pvVar5 != (id)0x0)))) {
      bVar9 = 0;
      goto LAB_00100bc8;
    }
  }
  bVar9 = 1;
LAB_00100bc8:
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  if (((((uVar1 & 0x10) == 0) || (self->_newObjectRef == (id)0x0)) &&
      (((uVar1 & 8) == 0 ||
       (((pvVar5 = _objc_msgSend(self,sel_toolAllowsActivation,puVar10), (char)pvVar5 == '\0' ||
         (uVar2._0_1_ = self->_locked[0], uVar2._1_1_ = self->_geometryLocked[0],
         ((byte)(uVar2 >> 6) & 1) == 1 && (char)pvVar7 != '\0')) &&
        (pvVar5 = _objc_msgSend(self,sel_shouldOpenCardInfoForObject_,shouldActivateForObject),
        puVar10 = shouldActivateForObject, (char)pvVar5 == '\0')))))) &&
     ((pvVar4 = _objc_msgSend(pvVar4,sel_count,puVar10), pvVar4 == (id)0x0 || (char)pvVar6 == '\0'
      && (cVar3 == '\0')))) {
    return '\0';
  }
  pvVar4 = _objc_msgSend(self->_mainWindow,sel_attachedSheet,puVar10);
  return (pvVar4 != (id)0x0 | bVar9) ^ 1;
}

*/
- (BOOL)shouldActivateForObject:(id)aObject
{
    NSArray *coachingPanes = [[HSCoachingHelpManager sharedCoachingHelpManager] coachingPanesForObject:aObject inStack:[[self stack] queryHyperInterface:@protocol(HSStackAttributes)] remove:NO];
    BOOL isNullObject = [aObject implementsHyperInterface:@protocol(HSObjectAssistantNullObjectInterface)];
    BOOL isMutableCard = [aObject implementsHyperInterface:@protocol(HSMutableCardAttributes)];
    BOOL isMutableStack = ([coachingPanes count] == 0) ? NO : [aObject implementsHyperInterface:@protocol(HSMutableStackAttributes)];
    BOOL needsNothing = YES;
    if (aObject != nil && ![[aObject queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]
        && ([self toolAllowsActivation] || !isMutableCard)
        && (_wasOpenExplicitlyByUser || [coachingPanes count] != 0)) {
        needsNothing = NO;
    }
    BOOL activate = NO;
    if (_newObjectDidAdd && _newObjectRef != nil) {
        activate = YES;
    } else if (_wasOpenExplicitlyByUser
               && ([self toolAllowsActivation] ? (!_temporaryHide || !isMutableCard) : NO)) {
        activate = YES;
    } else if (_wasOpenExplicitlyByUser && [self shouldOpenCardInfo]) {
        activate = YES;
    } else if ([coachingPanes count] != 0 && isNullObject) {
        activate = YES;
    } else if (isMutableStack) {
        activate = YES;
    }
    if (!activate) {
        return NO;
    }
    return !(([_mainWindow attachedSheet] != nil) || needsNothing);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100984 @ 00100984, 202 bytes * /

void FUN_00100984(HSObjectAssistantController *self,SEL _cmd,BOOL setActive,BOOL storeInDefaults)

{
  ushort uVar1;
  ushort uVar2;
  ushort uVar3;
  char cVar4;
  id pvVar5;
  undefined4 uVar6;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  cVar4 = -1;
  if ((short)((uVar1 & 4) >> 2) == 0) {
    cVar4 = '\0';
  }
  if (cVar4 != setActive) {
    pvVar5 = _objc_msgSend(self,sel_isActive);
    uVar2._0_1_ = self->_locked[0];
    uVar2._1_1_ = self->_geometryLocked[0];
    *(ushort *)self->_locked = (uVar2 & 0xfffb) + (ushort)(setActive & 1) * 4;
    if ((char)pvVar5 != setActive) {
      _objc_msgSend(self,sel_applySelectedObjectIfPossible);
      if (storeInDefaults != '\0') {
        pvVar5 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
        uVar3._0_1_ = self->_locked[0];
        uVar3._1_1_ = self->_geometryLocked[0];
        uVar6 = 0xffffffff;
        if ((uVar3 & 4) == 0) {
          uVar6 = 0;
        }
        _objc_msgSend(pvVar5,sel_setBool_forKey_,uVar6,&cfstr_HSIsObjectAssistantControllerActive);
      }
    }
  }
  return;
}

*/
- (void)setActive:(BOOL)aActive storeInDefaults:(BOOL)aDefaults
{
    if (_active != aActive) {
        BOOL wasActive = [self isActive];
        _active = aActive;
        if (wasActive != aActive) {
            [self applySelectedObjectIfPossible];
            if (aDefaults) {
                [[NSUserDefaults standardUserDefaults] setBool:_active forKey:@"HSIsObjectAssistantControllerActive"];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100949 @ 00100949, 59 bytes * /

BOOL FUN_00100949(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  
  if ((self->_locked[0] & 4) == 0) {
    bVar2 = false;
  }
  else {
    pvVar1 = _objc_msgSend(self->_objectAssistant,sel_isActive);
    bVar2 = (char)pvVar1 != '\0';
  }
  return bVar2;
}

*/
- (BOOL)isActive
{
    if (!_active) {
        return NO;
    }
    return [_objectAssistant isActive];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010088c @ 0010088c, 189 bytes * /

BOOL FUN_0010088c(HSObjectAssistantController *self,SEL _cmd,id canSupportSettingsOnTheSpotForObject
                 )

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(canSupportSettingsOnTheSpotForObject,sel_queryHyperInterface_,&DAT_0036f534
                        );
  pvVar2 = _objc_msgSend(canSupportSettingsOnTheSpotForObject,sel_implementsHyperInterface_,
                         &DAT_0036f548);
  if ((char)pvVar2 == '\0') {
    puVar3 = &DAT_0036f494;
    pvVar2 = _objc_msgSend(canSupportSettingsOnTheSpotForObject,sel_implementsHyperInterface_,
                           &DAT_0036f494);
    if (((char)pvVar2 == '\0') &&
       (pvVar2 = _objc_msgSend(cls_HSHypertextLinksProxyForInspector,
                               sel_sharedHypertextLinksProxyForInspector,puVar3),
       pvVar2 != canSupportSettingsOnTheSpotForObject)) {
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(pvVar1,sel_supportsSettingsOnTheSpotMode,puVar3);
        return (char)pvVar1 != '\0';
      }
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)canSupportSettingsOnTheSpotForObject:(id)aObject
{
    id nullObjectInterface = [aObject queryHyperInterface:@protocol(HSObjectAssistantNullObjectInterface)];
    if ([aObject implementsHyperInterface:@protocol(HSCardAttributes)] || [aObject implementsHyperInterface:@protocol(HSStackAttributes)]) {
        return NO;
    }
    if ([[HSHypertextLinksInspectorController sharedHypertextLinksInspectorController] hypertextLinksInspectorForStack:[self stack]] == aObject) {
        return NO;
    }
    if (nullObjectInterface != nil) {
        return [nullObjectInterface supportsSettingsOnTheSpotMode];
    }
    return YES;
}

- (void)noteCanChangeActiveDidChange
{
    [[self objectAssistant] setCloseButtonEnabled:[self canChangeActive]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100786 @ 00100786, 173 bytes * /

BOOL FUN_00100786(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar3 = self->_selectedInModelObject;
  pvVar1 = _objc_msgSend(pvVar3,sel_countOfAllHyperInterfaces);
  if ((((pvVar1 == (id)0x1) && (pvVar3 != (id)0x0)) &&
      (pvVar1 = _objc_msgSend(self,sel_isLocked), (char)pvVar1 == '\0')) &&
     (pvVar1 = pvVar3, pvVar2 = _objc_msgSend(self,sel_canAssistObject_,pvVar3),
     (char)pvVar2 != '\0')) {
    pvVar1 = _objc_msgSend(self,sel_toolAllowsActivation,pvVar1);
    if ((char)pvVar1 == '\0') {
      pvVar3 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_0036f494);
      return (char)pvVar3 != '\0';
    }
    return '\x01';
  }
  return '\0';
}

*/
- (BOOL)canChangeActive
{
    id object = _selectedInModelObject;
    if ([object countOfAllHyperInterfaces] == 1 && object != nil && ![self isLocked] && [self canAssistObject:object]) {
        if ([self toolAllowsActivation]) {
            return YES;
        }
        return [object implementsHyperInterface:@protocol(HSStackAttributes)];
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001006ee @ 001006ee, 152 bytes * /

void FUN_001006ee(HSObjectAssistantController *self,SEL _cmd,
                 id applicationDidBecomeActiveNotification)

{
  id pvVar1;
  
  if ((self->_mainWindow != (id)0x0) &&
     (pvVar1 = _objc_msgSend(self,sel_isActive), (char)pvVar1 != '\0')) {
    if (((self->_locked[0] & 1) == 0) &&
       (pvVar1 = _objc_msgSend(self->_mainWindow,sel_isMiniaturized), (char)pvVar1 != '\0')) {
      return;
    }
    pvVar1 = _objc_msgSend(self->_mainWindow,sel_attachedSheet);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_objectAssistant);
      _objc_msgSend(pvVar1,sel_showAssistant_,0);
    }
  }
  return;
}

*/
- (void)applicationDidBecomeActiveNotification:(id)aNotification
{
    if (_mainWindow != nil && [self isActive]) {
        if (!_locked && [_mainWindow isMiniaturized]) {
            return;
        }
        if ([_mainWindow attachedSheet] == nil) {
            [[self objectAssistant] showAssistant:NO];
        }
    }
}

- (void)applicationWillResignActiveNotification:(id)aNotification
{
    [[NSApp mainWindow] makeKeyWindow];
    [[self objectAssistant] hideAssistant:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100654 @ 00100654, 44 bytes * /

void FUN_00100654(HSObjectAssistantController *self,SEL _cmd,id windowDidDeminiaturize)

{
  if ((self->_locked[0] & 1) == 0) {
    _objc_msgSend(self,sel_activateIfNeeded);
  }
  return;
}

*/
- (void)windowDidDeminiaturize:(id)aDeminiaturize
{
    if (!_locked) {
        [self activateIfNeeded];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100618 @ 00100618, 60 bytes * /

void FUN_00100618(HSObjectAssistantController *self,SEL _cmd,id windowWillMiniaturize)

{
  if ((self->_locked[0] & 1) == 0) {
    _objc_msgSend(self,sel_setActive_explicitlyByUser_,0,0);
  }
  return;
}

*/
- (void)windowWillMiniaturize:(id)aMiniaturize
{
    if (!_locked) {
        [self setActive:NO explicitlyByUser:NO];
    }
}

- (void)documentWindowDidBecomeMain:(id)aMain
{
    [self setMainWindow:[aMain object]];
    if ([_mainWindow attachedSheet] == nil) {
        [self applySelectedObjectIfPossible];
    }
}

- (void)windowDidEndSheet:(id)aSheet
{
    if ([_mainWindow attachedSheet] == nil) {
        if ([self isActive]) {
            [[self objectAssistant] showAssistant:NO];
        }
    }
}

- (void)windowWillBeginSheet:(id)aSheet
{
    if ([NSApp modalWindow] == nil) {
        if ([aSheet object] != [NSColorPanel sharedColorPanel]) {
            [[self objectAssistant] hideAssistant:NO];
        }
    }
}

- (void)windowWillClose:(id)aClose
{
    [[self objectAssistant] deactivate];
    [self removePaneHistoryForAllObjects];
    [self setMainWindow:nil];
}

- (void)editorDidChangeWindow:(id)aWindow
{
    [self noteCanChangeActiveDidChange];
}

- (void)visibleRectDidChange:(id)aChange
{
    if ([[[self objectAssistant] currentPane] needToRelayoutAssistant]) {
        [[self objectAssistant] updateObjectScreenFrame:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00100240 @ 00100240, 368 bytes * /

void FUN_00100240(HSObjectAssistantController *self,SEL _cmd,id hiddenAttributeChanged)

{
  id pvVar1;
  id self_00;
  
  pvVar1 = _objc_msgSend(self->_selectedObject,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_cardObjectsVisibility);
  if ((pvVar1 == (id)0x2) && ((self->_locked[0] & 1) == 0)) {
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_dontShowCoachingHintsForKey_,&cfstr_HiddenAttributeCoaching);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self->_selectedObject,sel_queryHyperInterface_,&DAT_0036f37c);
      pvVar1 = _objc_msgSend(pvVar1,sel_isHidden);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(cls_HSHelpAssistantPane,sel_paneWithCoachingKey_,
                               &cfstr_HiddenAttributeCoaching);
        self_00 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
        _objc_msgSend(self_00,sel_pushAdditionalCoachingPane_forObject_,pvVar1,self->_selectedObject
                     );
        pvVar1 = _objc_msgSend(self,sel_objectAssistant);
        pvVar1 = _objc_msgSend(pvVar1,sel_currentPane);
        _objc_msgSend(pvVar1,sel_showCoachingHelpIfNeeded);
      }
    }
  }
  return;
}

*/
- (void)hiddenAttributeChanged:(id)aChanged
{
    if ([[[_selectedObject document] stack] cardObjectsVisibility] == 2 && !_locked) {
        if (![[HSCoachingHelpManager sharedCoachingHelpManager] dontShowCoachingHintsForKey:@"HiddenAttributeCoaching"]) {
            if ([[_selectedObject queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)] isHidden]) {
                id pane = [HSHelpAssistantPane paneWithCoachingKey:@"HiddenAttributeCoaching"];
                [[HSCoachingHelpManager sharedCoachingHelpManager] pushAdditionalCoachingPane:pane forObject:_selectedObject];
                [[[self objectAssistant] currentPane] showCoachingHelpIfNeeded];
            }
        }
    }
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    id pvVar2;
    id pvVar1_2;

    if ([aPath isEqual:@"windowController"]) {
        pvVar1_2 = [aChange objectForKey:NSKeyValueChangeOldKey];
        pvVar2 = [aChange objectForKey:NSKeyValueChangeNewKey];
        if (pvVar1_2 == [NSNull null]) {
            pvVar1_2 = nil;
        }
        [self detachFromMainWindowController:pvVar1_2];
        if (pvVar2 == [NSNull null]) {
            pvVar2 = nil;
        }
        [self attachToMainWindowController:pvVar2];
    }
}

- (void)setMainWindow:(id)aWindow
{
    id pvVar1;
    id pvVar1_3;

    if (_mainWindow != aWindow) {
        pvVar1 = nil;
        if (_mainWindow != nil) {
            [self unsubscribeFromNotificationsOnWindowChange];
            pvVar1 = _mainWindow;
        }
        [self detachFromMainWindowController:[pvVar1 windowController]];
        [_mainWindow removeObserver:self forKeyPath:@"windowController"];
        [_mainWindow autorelease];
        pvVar1_3 = [aWindow retain];
        _mainWindow = pvVar1_3;
        [pvVar1_3 addObserver:self forKeyPath:@"windowController" options:3 context:nil];
        [self attachToMainWindowController:[_mainWindow windowController]];
        if (_mainWindow != nil) {
            [self subscribeToNotificationsOnWindowChange];
        }
    }
}

- (void)attachToMainWindowController:(id)aController
{
    NSView *pvVar1_4;
    id pvVar2_3;

    if (![aController isKindOfClass:[HSEditorWindowController class]]) {
        if (![aController isKindOfClass:[NSNull class]]) {
            return;
        }
    }
    pvVar2_3 = [aController cardView];
    if (pvVar2_3 != nil) {
        pvVar1_4 = [[pvVar2_3 enclosingScrollView] contentView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visibleRectDidChange:) name:NSViewBoundsDidChangeNotification object:pvVar1_4];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visibleRectDidChange:) name:NSViewFrameDidChangeNotification object:pvVar1_4];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visibleRectDidChange:) name:@"HSEditorCardViewDidChangeZoomFactorNotification" object:pvVar2_3];
    }
}

- (void)detachFromMainWindowController:(id)aController
{
    NSNotificationCenter *self_00;
    id pvVar2_3;
    NSView *pvVar2_5;

    if (![aController isKindOfClass:[HSEditorWindowController class]]) {
        if (![aController isKindOfClass:[NSNull class]]) {
            return;
        }
    }
    pvVar2_3 = [aController cardView];
    if (pvVar2_3 != nil) {
        self_00 = [NSNotificationCenter defaultCenter];
        [self_00 removeObserver:self name:0 object:pvVar2_3];
        pvVar2_5 = [[pvVar2_3 enclosingScrollView] contentView];
        if (pvVar2_5 != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:0 object:pvVar2_5];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ffc2b @ 000ffc2b, 262 bytes * /

void FUN_000ffc2b(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_windowWillClose_,
                *(undefined4 *)PTR_00336584,self->_mainWindow);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_currentToolDidChange_,
                &cfstr_HSActiveToolDidSelectionNotification,0);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_editorDidChangeWindow_,
                *(undefined4 *)PTR_PTR_00336560,self->_mainWindow);
  return;
}

*/
- (void)subscribeToNotificationsOnWindowChange
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_mainWindow];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentToolDidChange:) name:@"HSActiveToolDidSelectionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editorDidChangeWindow:) name:HSEditorDidChangeWindowNotification object:_mainWindow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ffb49 @ 000ffb49, 226 bytes * /

void FUN_000ffb49(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_00336584,
                self->_mainWindow);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,
                &cfstr_HSActiveToolDidSelectionNotification,0);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_00336560,
                self->_mainWindow);
  return;
}

*/
- (void)unsubscribeFromNotificationsOnWindowChange
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:_mainWindow];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSEditorDidChangeWindowNotification object:_mainWindow];
}

- (BOOL)toolAllowsActivation
{
    BOOL bVar2;

    if ([self currentEditorView] == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self stateForTool:[[HSToolManager sharedToolManager] selectedToolTag]] != 0;
    }
    return bVar2;
}

- (NSInteger)stateForTool:(NSInteger)aTool
{
    if (aTool < 0x30) {
        if (aTool == 0) {
            return 2;
        }
        if (aTool != 1) {
            return 0;
        }
    }
    else {
        if (0x14 < aTool - 0x30U) {
            return 0;
        }
        if ((0x1dfbffU >> (aTool - 0x30U & 0x1f) & 1) == 0) {
            return 0;
        }
    }
    return 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ffa2b @ 000ffa2b, 164 bytes * /

void FUN_000ffa2b(HSObjectAssistantController *self,SEL _cmd,id currentToolDidChange)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  pvVar2 = _objc_msgSend(self,sel_stateForTool_,pvVar1);
  if (pvVar2 == (id)0x1) {
    _objc_msgSend(self,sel_activateIfNeeded,pvVar1);
    op = sel_noteCanChangeActiveDidChange;
  }
  else {
    if (pvVar2 != (id)0x0) {
      return;
    }
    pvVar1 = (id)0x0;
    op = sel_setActive_explicitlyByUser_;
  }
  _objc_msgSend(self,op,pvVar1);
  return;
}

*/
- (void)currentToolDidChange:(id)aChange
{
    NSInteger toolTag = [[HSToolManager sharedToolManager] selectedToolTag];
    NSInteger state = [self stateForTool:toolTag];
    if (state == 1) {
        [self activateIfNeeded];
        [self noteCanChangeActiveDidChange];
    } else if (state == 0) {
        [self setActive:NO explicitlyByUser:NO];
    }
}

- (id)stack
{
    return [[[self currentEditorView] card] stack];
}

- (void)dealloc
{
    id pvVar1;
    HSObjectAssistantController *pHVar2;
    int uVar4;

    pvVar1 = [NSNotificationCenter defaultCenter];
    [pvVar1 removeObserver:self];
    [self unsubscribeFromNotifications];
    [self unsubscribeFromListeningObjectAdditions];
    [self unsubscribeFromNotificationsOnWindowChange];
    [self removePaneHistoryForAllObjects];
    pvVar1 = [[_selectedInModelObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    uVar4 = HSActualDidAttributeChanges;
    pHVar2 = self;
    [pvVar1 removeObserver:self selector:@selector(objectLockedStateDidChange:) ofChanges:uVar4 ofAttribute:@protocol(HSCardObjectLockedAttribute)];
    [_selectedInModelObject release];
    [_historyByObject release];
    NSFreeMapTable(_objectsByContainer);
    if (_objectAssistantControllerProxy != nil) {
        pvVar1 = [NSRunLoop currentRunLoop];
        pHVar2 = _objectAssistantControllerProxy;
        [pvVar1 cancelPerformSelectorsWithTarget:pHVar2];
    }
    pvVar1 = [self class];
    [pvVar1 NSE_invalidateWeakProxy:_objectAssistantControllerProxy];
    [_objectAssistantControllerProxy release];
    [_temporaryHideTimer invalidate];
    [_temporaryHideTimer release];
    [_temporaryShowTimer invalidate];
    [_temporaryShowTimer release];
    [_updateObjectScreenFrameTimer invalidate];
    [_updateObjectScreenFrameTimer release];
    [_mainWindow removeObserver:self forKeyPath:@"windowController"];
    [_mainWindow release];
    [_objectAssistant release];
    [self setNewObject:nil didAdd:NO];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00102ef9 @ 00102ef9, 384 bytes * /

void FUN_00102ef9(HSObjectAssistantController *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined1 local_24 [16];
  id local_14;
  
  local_14 = (id)0x0;
  _NSEnumerateMapTable(local_24,self->_objectsByContainer);
  while (cVar1 = _NSNextMapEnumeratorPair(local_24,&local_14,0), pvVar2 = local_14, cVar1 != '\0') {
    puVar4 = sel_attributeObservingController;
    pvVar3 = _objc_msgSend(local_14,sel_respondsToSelector_,sel_attributeObservingController);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(pvVar2,sel_attributeObservingController,puVar4);
      _objc_msgSend(pvVar3,sel_removeAttributeObserver_selector_,self,
                    sel_historyObjectSupportDidChange_);
      pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
      _objc_msgSend(pvVar2,sel_removeAttributeObserver_selector_,self,
                    sel_hypertextLinkContainerDidChange_);
    }
  }
  _NSEndMapTableEnumeration(local_24);
  _NSResetMapTable(self->_objectsByContainer);
  _objc_msgSend(self->_historyByObject,sel_removeAllObjects);
  pvVar2 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
  pvVar3 = _objc_msgSend(self,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036f494);
  _objc_msgSend(pvVar2,sel_cleanAllDropHelpPanesForStack_,pvVar3);
  return;
}

*/
- (void)removePaneHistoryForAllObjects
{
    for (id container in [_objectsByContainer keyEnumerator]) {
        if ([container respondsToSelector:@selector(attributeObservingController)]) {
            [[container attributeObservingController] removeAttributeObserver:self selector:@selector(historyObjectSupportDidChange:)];
            [[container attributeObservingController] removeAttributeObserver:self selector:@selector(hypertextLinkContainerDidChange:)];
        }
    }
    [_objectsByContainer removeAllObjects];
    [_historyByObject removeAllObjects];
    [[HSCoachingHelpManager sharedCoachingHelpManager] cleanAllDropHelpPanesForStack:[[self stack] queryHyperInterface:@protocol(HSStackAttributes)]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010287a @ 0010287a, 970 bytes * /

id FUN_0010287a(HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  HSObjectAssistantController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_00350a80;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,
                  sel_applicationWillResignActiveNotification_,*(undefined4 *)PTR_00336484,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,
                  sel_applicationDidBecomeActiveNotification_,*(undefined4 *)PTR_00336060,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pvVar3 = _objc_msgSend(cls_HSGlobalSelectionSync,sel_globalSelectionSync);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,
                  sel_globalSelectionSyncDidChangeSelectedObject_,*(undefined4 *)PTR_PTR_00336564,
                  pvVar3);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,
                  sel_documentWindowDidBecomeMain_,*(undefined4 *)PTR_003364b0,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,sel_windowWillBeginSheet_,
                  *(undefined4 *)PTR_00336580,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,sel_windowDidEndSheet_,
                  *(undefined4 *)PTR_0033657c,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,sel_windowWillMiniaturize_,
                  *(undefined4 *)PTR_00336588,0);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,pvVar1,sel_windowDidDeminiaturize_,
                  *(undefined4 *)PTR_00336578,0);
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,&cfstr_HSIsObjectAssistantControllerActive);
    *(ushort *)((int)pvVar1 + 0x48) =
         (ushort)((byte)pvVar2 & 1) * 4 + (*(ushort *)((int)pvVar1 + 0x48) & 0xfffb);
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,
                           &cfstr_HSIsObjectAssistantControllerActivatedByUser);
    *(ushort *)((int)pvVar1 + 0x48) =
         (ushort)((byte)pvVar2 & 1) * 8 + (*(ushort *)((int)pvVar1 + 0x48) & 0xfff7);
    uVar4 = _NSCreateMapTable(*(undefined8 *)PTR_00336570,*(undefined8 *)(PTR_00336570 + 8),
                              *(undefined8 *)(PTR_00336570 + 0x10),*(undefined4 *)PTR_0033639c,
                              *(undefined4 *)(PTR_0033639c + 4),*(undefined4 *)(PTR_0033639c + 8),0)
    ;
    *(undefined4 *)((int)pvVar1 + 0x20) = uVar4;
  }
  return pvVar1;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:NSApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:NSApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globalSelectionSyncDidChangeSelectedObject:) name:@"HSGlobalSelectionSyncDidChangeSelectedObjectNotification" object:[HSGlobalSelectionSync globalSelectionSync]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentWindowDidBecomeMain:) name:HSDocumentWindowDidBecomeMainNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillBeginSheet:) name:NSWindowWillBeginSheetNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidEndSheet:) name:NSWindowDidEndSheetNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillMiniaturize:) name:NSWindowWillMiniaturizeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidDeminiaturize:) name:NSWindowDidDeminiaturizeNotification object:nil];
        _active = [[NSUserDefaults standardUserDefaults] boolForKey:@"HSIsObjectAssistantControllerActive"];
        _wasOpenExplicitlyByUser = [[NSUserDefaults standardUserDefaults] boolForKey:HSIsObjectAssistantControllerActivatedByUser];
        _objectsByContainer = NSCreateMapTable(NSNonRetainedObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    }
    return self;
}

- (void)supportChangingInLockedStateForSelectedObject:(id)aObject
{
    if ([self isLocked]) {
        [self setLocked:NO delegate:nil];
        [self setSelectedInModelObject:nil needToBringAssistantWindowToFront:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ff898 @ 000ff898, 213 bytes * /

id FUN_000ff898(HSObjectAssistantController *self,SEL _cmd,id paneHistoryForObject)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  SEL op;
  undefined *puVar3;
  
  self_00 = cls_NSArray;
  op = sel_array;
  if (paneHistoryForObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_historyByObject);
    pvVar2 = _objc_msgSend(cls_NSValue,sel_valueWithNonretainedObject_,paneHistoryForObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
    if (pvVar1 != (id)0x0) {
      return pvVar1;
    }
    puVar3 = sel_rootViewController;
    pvVar1 = _objc_msgSend(paneHistoryForObject,sel_respondsToSelector_,sel_rootViewController);
    self_00 = cls_NSArray;
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    _objc_msgSend(paneHistoryForObject,sel_rootViewController,puVar3);
    op = sel_arrayWithObject_;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)paneHistoryForObject:(id)aObject
{
    if (aObject == nil) {
        return [NSArray array];
    }
    id history = [[self historyByObject] objectForKey:[NSValue valueWithNonretainedObject:aObject]];
    if (history != nil) {
        return history;
    }
    if (![aObject respondsToSelector:@selector(rootViewController)]) {
        return nil;
    }
    return [NSArray arrayWithObject:[aObject rootViewController]];
}

- (void)setPaneHistory:(id)aHistory forObject:(id)aObject
{
    NSValue *pvVar1;
    id pvVar2;
    id self_01;
    NSEnumerator *self_02;
    id pvVar2_3;
    id pvVar3_2;

    pvVar1 = [NSValue valueWithNonretainedObject:aObject];
    pvVar2 = [aObject queryHyperInterface:@protocol(HSNodeSupportAttributes)];
    if ([pvVar2 support] != nil) {
        pvVar3_2 = NSMapGet(_objectsByContainer,pvVar2);
        if (pvVar3_2 == nil) {
            pvVar3_2 = [NSMutableSet setWithCapacity:1];
            NSMapInsert(_objectsByContainer,pvVar2,pvVar3_2);
            [[pvVar2 attributeObservingController] addObserver:self selector:@selector(historyObjectSupportDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeSupportAttribute) withPriority:-0.25];
        }
        [pvVar3_2 addObject:pvVar1];
        self_01 = [NSMutableArray arrayWithCapacity:[aHistory count]];
        self_02 = [aHistory objectEnumerator];
        pvVar2_3 = [self_02 nextObject];
        while (pvVar2_3 != nil) {
            if ([pvVar2_3 needsToBeSavedInHistory]) {
                [self_01 addObject:pvVar2_3];
            }
            pvVar2_3 = [self_02 nextObject];
        }
        [[self historyByObject] setObject:self_01 forKey:pvVar1];
    }
}

- (void)historyObjectSupportDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [[aChange object] queryHyperInterface:@protocol(HSNodeSupportAttributes)];
    if ([pvVar1_2 support] == nil) {
        [self removePaneHistoryForSupportAttributes:pvVar1_2];
    }
}

- (void)removePaneHistoryForObject:(id)aObject
{
    [self removePaneHistoryForSupportAttributes:[aObject queryHyperInterface:@protocol(HSNodeSupportAttributes)]];
}

- (void)removePaneHistoryForSupportAttributes:(id)aAttributes
{
    id self_00;

    self_00 = NSMapGet(_objectsByContainer,aAttributes);
    [_historyByObject removeObjectsForKeys:[self_00 allObjects]];
    if ([self_00 count] != 0) {
        [[aAttributes attributeObservingController] removeObserver:self selector:@selector(historyObjectSupportDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeSupportAttribute)];
        NSMapRemove(_objectsByContainer,aAttributes);
    }
}

- (id)historyByObject
{
    id pvVar1;

    pvVar1 = _historyByObject;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary alloc] init];
        _historyByObject = pvVar1;
    }
    return pvVar1;
}

- (void)hideAssistantWithTimer:(id)aTimer
{
    [self invalidateTimerForHideAssistant];
    [[self objectAssistant] hideAssistant:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ff6b6 @ 000ff6b6, 126 bytes * /

void FUN_000ff6b6(HSObjectAssistantController *self,SEL _cmd,id objectLockedStateDidChange)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  puVar2 = &DAT_0036f480;
  pvVar1 = _objc_msgSend(self->_selectedObject,sel_queryHyperInterface_,&DAT_0036f480);
  pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
  op = sel_activateIfNeeded;
  if ((char)pvVar1 != '\0') {
    puVar2 = (undefined *)0x0;
    op = sel_setActive_explicitlyByUser_;
  }
  _objc_msgSend(self,op,puVar2);
  return;
}

*/
- (void)objectLockedStateDidChange:(id)aChange
{
    if ([[_selectedObject queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
        [self setActive:NO explicitlyByUser:NO];
    } else {
        [self activateIfNeeded];
    }
}

- (void)nameAttributesDidChange:(id)aChange
{
    [[self objectAssistant] updateInspectorName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00102398 @ 00102398, 513 bytes * /

void FUN_00102398(HSObjectAssistantController *self,SEL _cmd,id showAssistantWithTimer)

{
  bool bVar1;
  char cVar2;
  id pvVar3;
  SEL op;
  undefined8 uVar4;
  undefined8 in_stack_ffffffac;
  undefined4 uVar5;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  uVar5 = (undefined4)((ulonglong)in_stack_ffffffac >> 0x20);
  _objc_msgSend(self,sel_invalidateTimerForShowAssistant);
  pvVar3 = _objc_msgSend(self,sel_currentEditorView);
  pvVar3 = _objc_msgSend(pvVar3,sel_enclosingScrollView);
  _objc_msgSend_stret(&local_24,pvVar3,sel_documentVisibleRect);
  pvVar3 = _objc_msgSend(self,sel_objectAssistant);
  pvVar3 = _objc_msgSend(pvVar3,sel_object);
  uVar4 = CONCAT44(uVar5,pvVar3);
  pvVar3 = _objc_msgSend(self,sel_boundingFramePathInView_forObject_);
  _objc_msgSend_stret(&local_34,pvVar3,sel_hyperVisualBounds,uVar4);
  if (self->_updateObjectScreenFrameTimer == (id)0x0) {
LAB_00102479:
    bVar1 = false;
  }
  else {
    pvVar3 = _objc_msgSend(self->_updateObjectScreenFrameTimer,sel_isValid);
    if ((char)pvVar3 == '\0') goto LAB_00102479;
    bVar1 = true;
  }
  _objc_msgSend(self->_updateObjectScreenFrameTimer,sel_invalidate);
  _objc_msgSend(self->_updateObjectScreenFrameTimer,sel_release);
  self->_updateObjectScreenFrameTimer = (id)0x0;
  cVar2 = _NSIntersectsRect(local_34,local_2c,local_24,local_1c);
  uVar4 = local_2c;
  if (cVar2 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_objectAssistant);
    pvVar3 = _objc_msgSend(pvVar3,sel_prefersInspectorMode);
    uVar4 = local_2c;
    if ((char)pvVar3 == '\0') goto LAB_0010252d;
    pvVar3 = _objc_msgSend(self,sel_objectAssistant);
    uVar4 = CONCAT44((int)((ulonglong)local_2c >> 0x20),self);
    op = sel_toggleInspectorMode_;
  }
  else {
LAB_0010252d:
    if (!bVar1) goto LAB_0010255d;
    pvVar3 = _objc_msgSend(self,sel_objectAssistant);
    uVar4 = CONCAT44((int)((ulonglong)uVar4 >> 0x20),1);
    op = sel_updateObjectScreenFrame_;
  }
  _objc_msgSend(pvVar3,op,uVar4);
LAB_0010255d:
  pvVar3 = _objc_msgSend(self,sel_objectAssistant,uVar4);
  _objc_msgSend(pvVar3,sel_setShouldBeVisible_animate_,1,0);
  return;
}

*/
- (void)showAssistantWithTimer:(id)aTimer
{
    [self invalidateTimerForShowAssistant];
    id editorView = [self currentEditorView];
    NSRect visibleRect = [[editorView enclosingScrollView] documentVisibleRect];
    id path = [self boundingFramePathInView:editorView forObject:[[self objectAssistant] object]];
    NSRect objectBounds = [path hyperVisualBounds];
    BOOL hadFrameTimer = (_updateObjectScreenFrameTimer != nil && [_updateObjectScreenFrameTimer isValid]);
    [_updateObjectScreenFrameTimer invalidate];
    [_updateObjectScreenFrameTimer release];
    _updateObjectScreenFrameTimer = nil;
    if (!NSIntersectsRect(objectBounds, visibleRect)) {
        if ([[self objectAssistant] prefersInspectorMode]) {
            [[self objectAssistant] toggleInspectorMode:self];
        }
    } else if (hadFrameTimer) {
        [[self objectAssistant] updateObjectScreenFrame:YES];
    }
    [[self objectAssistant] setShouldBeVisible:YES animate:NO];
}

- (void)cardVisibleAreaChanged:(id)aChanged
{
    if ([[self objectAssistant] isCurrentlyWorkingInSOTSMode]) {
        if ([[self objectAssistant] isActive]) {
            if ([[[self objectAssistant] currentPane] needToRelayoutAssistant]) {
                if (_temporaryShowTimer == nil) {
                    if (_temporaryHideTimer != nil) {
                        return;
                    }
                    [self scheduleTimerForHideAssistant];
                }
                else {
                    [self invalidateTimerForShowAssistant];
                }
                [self scheduleTimerForShowAssistant];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ff507 @ 000ff507, 129 bytes * /

void FUN_000ff507(HSObjectAssistantController *self,SEL _cmd,id geometryAttributesDidEndChanging)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_objectAssistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_isCurrentlyWorkingInSOTSMode);
  if (((char)pvVar1 != '\0') &&
     (((self->_temporaryHideTimer != (id)0x0 &&
       (pvVar1 = _objc_msgSend(self->_temporaryHideTimer,sel_isValid),
       op = sel_invalidateTimerForHideAssistant, (char)pvVar1 != '\0')) ||
      (op = sel_scheduleTimerForShowAssistant, self->_temporaryShowTimer == (id)0x0)))) {
    _objc_msgSend(self,op);
  }
  return;
}

*/
- (void)geometryAttributesDidEndChanging:(id)aChanging
{
    if ([[self objectAssistant] isCurrentlyWorkingInSOTSMode]) {
        if (_temporaryHideTimer != nil && [_temporaryHideTimer isValid]) {
            [self invalidateTimerForHideAssistant];
        } else if (_temporaryShowTimer == nil) {
            [self scheduleTimerForShowAssistant];
        }
    }
}

- (void)geometryAttributesWillStartChanging:(id)aChanging
{
    if ([[self objectAssistant] isCurrentlyWorkingInSOTSMode]) {
        [self invalidateTimerForShowAssistant];
        [self invalidateTimerForHideAssistant];
        [self scheduleTimerForHideAssistant];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ff375 @ 000ff375, 284 bytes * /

void FUN_000ff375(HSObjectAssistantController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  self_00 = cls_NSTimer;
  puVar1 = sel_showAssistantWithTimer_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3fe00000,pvVar2,puVar1,0,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_temporaryShowTimer = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_temporaryShowTimer,*(undefined4 *)PTR_003361b4);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_temporaryShowTimer,*(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)scheduleTimerForShowAssistant
{
    _temporaryShowTimer = [[NSTimer timerWithTimeInterval:0.5 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(showAssistantWithTimer:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:_temporaryShowTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_temporaryShowTimer forMode:NSEventTrackingRunLoopMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ff259 @ 000ff259, 284 bytes * /

void FUN_000ff259(HSObjectAssistantController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  self_00 = cls_NSTimer;
  puVar1 = sel_hideAssistantWithTimer_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,
                         0x47ae147b,0x3f847ae1,pvVar2,puVar1,0,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_temporaryHideTimer = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_temporaryHideTimer,*(undefined4 *)PTR_003361b4);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_temporaryHideTimer,*(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)scheduleTimerForHideAssistant
{
    _temporaryHideTimer = [[NSTimer timerWithTimeInterval:0.01 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(hideAssistantWithTimer:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:_temporaryHideTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_temporaryHideTimer forMode:NSEventTrackingRunLoopMode];
}

- (void)invalidateTimerForShowAssistant
{
    [_temporaryShowTimer invalidate];
    [_temporaryShowTimer release];
    _temporaryShowTimer = nil;
}

- (void)invalidateTimerForHideAssistant
{
    [_temporaryHideTimer invalidate];
    [_temporaryHideTimer release];
    _temporaryHideTimer = nil;
}

- (void)geometryAttributesDidChange:(id)aChange
{
    if ([[[self objectAssistant] currentPane] needToRelayoutAssistant]) {
        [[self objectAssistant] updateObjectScreenFrame:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000feff7 @ 000feff7, 364 bytes * /

void FUN_000feff7(HSObjectAssistantController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self->_updateObjectScreenFrameTimer,sel_isValid);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self->_updateObjectScreenFrameTimer,sel_invalidate);
    _objc_msgSend(self->_updateObjectScreenFrameTimer,sel_release);
    self->_updateObjectScreenFrameTimer = (id)0x0;
  }
  self_00 = cls_NSTimer;
  puVar1 = sel_updateObjectSreenFrameWithTimer_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,
                         0x47ae147b,0x3f847ae1,pvVar2,puVar1,0,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_updateObjectScreenFrameTimer = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_updateObjectScreenFrameTimer,
                *(undefined4 *)PTR_003361b4);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_updateObjectScreenFrameTimer,
                *(undefined4 *)PTR_00336064);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_000fedb6 @ 000fedb6, 481 bytes * /

void FUN_000fedb6(HSObjectAssistantController *self,SEL _cmd,
                 id globalSelectionSyncDidChangeSelectedObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  if ((self->_locked[0] & 1) == 0) {
    pvVar1 = _objc_msgSend(cls_HSGlobalSelectionSync,sel_globalSelectionSync);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentSelectedObject);
    pcVar4 = (cfstringStruct *)&DAT_0036f494;
    pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036f494);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,pcVar4);
      pcVar4 = &cfstr_StackSizeCoaching;
      pvVar3 = _objc_msgSend(pvVar2,sel_dontShowCoachingHintsForKey_,&cfstr_StackSizeCoaching);
      if ((char)pvVar3 != '\0') {
        pcVar4 = &cfstr_HSStack;
        pvVar2 = _objc_msgSend(pvVar2,sel_dontShowCoachingHintsForKey_,&cfstr_HSStack);
        if ((char)pvVar2 != '\0') {
          pvVar2 = _objc_msgSend(self,sel_currentEditorWindowController,pcVar4);
          pvVar2 = _objc_msgSend(pvVar2,sel_stackSelectionHostWasCurrentBeforeAssistantHide);
          if ((char)pvVar2 == '\0') {
            return;
          }
        }
      }
    }
    if (self->_objectAssistantControllerProxy == (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy,pcVar4);
      self->_objectAssistantControllerProxy = pvVar2;
      if (pvVar2 == (id)0x0) {
        return;
      }
    }
    pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop,pcVar4);
    _objc_msgSend(pvVar2,sel_cancelPerformSelectorsWithTarget_,self->_objectAssistantControllerProxy
                 );
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_003361b4,
                           *(undefined4 *)PTR_00336064,*(undefined4 *)PTR_003363f8,0);
    _objc_msgSend(pvVar2,sel_performSelector_target_argument_order_modes_,
                  sel_setAtomicSelectedInModelObjectAndBringAssistantToFront_,
                  self->_objectAssistantControllerProxy,pvVar1,0xffffffff,pvVar3);
  }
  return;
}

*/
- (void)globalSelectionSyncDidChangeSelectedObject:(id)aObject
{
    if (!_locked) {
        id selectedObject = [[HSGlobalSelectionSync globalSelectionSync] currentSelectedObject];
        if ([selectedObject implementsHyperInterface:@protocol(HSStackAttributes)]) {
            HSCoachingHelpManager *coachingHelpManager = [HSCoachingHelpManager sharedCoachingHelpManager];
            if ([coachingHelpManager dontShowCoachingHintsForKey:@"StackSizeCoaching"]
                && [coachingHelpManager dontShowCoachingHintsForKey:@"HSStack"]
                && ![[self currentEditorWindowController] stackSelectionHostWasCurrentBeforeAssistantHide]) {
                return;
            }
        }
        if (_objectAssistantControllerProxy == nil) {
            _objectAssistantControllerProxy = [self NSE_newWeakProxy];
            if (_objectAssistantControllerProxy == nil) {
                return;
            }
        }
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop cancelPerformSelectorsWithTarget:_objectAssistantControllerProxy];
        [runLoop performSelector:@selector(setAtomicSelectedInModelObjectAndBringAssistantToFront:) target:_objectAssistantControllerProxy argument:selectedObject order:NSUIntegerMax
                           modes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000feafa @ 000feafa, 700 bytes * /

void FUN_000feafa(HSObjectAssistantController *self,SEL _cmd,id setSelectedInModelObject,
                 BOOL needToBringAssistantWindowToFront)

{
  ushort uVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined4 uVar5;
  undefined *puVar6;
  undefined4 uVar7;
  
  if (self->_selectedInModelObject != setSelectedInModelObject) {
    pvVar3 = setSelectedInModelObject;
    pvVar2 = _objc_msgSend(self,sel_shouldActivateForObject_,setSelectedInModelObject);
    if ((char)pvVar2 == '\0') {
      pvVar3 = setSelectedInModelObject;
      _objc_msgSend(self,sel_deactivateIfNeededForObject_,setSelectedInModelObject);
    }
    pvVar3 = _objc_msgSend(self,sel_isLocked,pvVar3);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(self->_selectedInModelObject,sel_queryHyperInterface_,&DAT_0036f458);
      pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
      _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_supportChangingInLockedStateForSelectedObject_,1,&DAT_0036f46c);
    }
    pvVar3 = _objc_msgSend(self->_selectedInModelObject,sel_queryHyperInterface_,&DAT_0036f32c);
    pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
    uVar5 = *(undefined4 *)PTR_0033601c;
    _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                  sel_objectLockedStateDidChange_,uVar5,&DAT_0036f480);
    _objc_msgSend(self->_selectedInModelObject,sel_autorelease);
    pvVar3 = _objc_msgSend(setSelectedInModelObject,sel_retain);
    self->_selectedInModelObject = pvVar3;
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036f32c);
    pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
    puVar6 = &DAT_0036f480;
    uVar7 = 0xbe800000;
    puVar4 = sel_objectLockedStateDidChange_;
    _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                  sel_objectLockedStateDidChange_,uVar5,&DAT_0036f480,0xbe800000);
    _objc_msgSend(self,sel_noteCanChangeActiveDidChange);
    _objc_msgSend(self,sel_applySelectedObjectIfPossible);
    pvVar3 = _objc_msgSend(self,sel_objectAssistant);
    uVar1._0_1_ = self->_locked[0];
    uVar1._1_1_ = self->_geometryLocked[0];
    if (((uVar1 & 1) == 0) && ((uVar1 & 4) != 0)) {
      pvVar2 = self->_selectedInModelObject;
    }
    else {
      pvVar2 = (id)0x0;
    }
    pvVar2 = _objc_msgSend(self,sel_canSupportSettingsOnTheSpotForObject_,pvVar2,puVar4,uVar5,puVar6
                           ,uVar7);
    _objc_msgSend(pvVar3,sel_setSupportsSettingsOnTheSpotMode_,(int)(char)pvVar2);
    _objc_msgSend(self,sel_activateIfNeeded);
    if (self->_selectedInModelObject == self->_newObjectRef) {
      _objc_msgSend(self,sel_setNewObject_didAdd_,0,0);
    }
  }
  return;
}

*/
- (void)setSelectedInModelObject:(id)aObject needToBringAssistantWindowToFront:(BOOL)aFront
{
    if (_selectedInModelObject != aObject) {
        if (![self shouldActivateForObject:aObject]) {
            [self deactivateIfNeeded];
        }
        if ([self isLocked]) {
            [[[_selectedInModelObject queryHyperInterface:@protocol(HSNodeSupportAttributes)] attributeObservingController] removeObserver:self selector:@selector(supportChangingInLockedStateForSelectedObject:) ofChanges:1 ofAttribute:@protocol(HSNodeSupportAttribute)];
        }
        [[[_selectedInModelObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] removeObserver:self selector:@selector(objectLockedStateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectLockedAttribute)];
        [_selectedInModelObject autorelease];
        _selectedInModelObject = [aObject retain];
        [[[_selectedInModelObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] addObserver:self selector:@selector(objectLockedStateDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectLockedAttribute) withPriority:-0.25];
        [self noteCanChangeActiveDidChange];
        [self applySelectedObjectIfPossible];
        [[self objectAssistant] setSupportsSettingsOnTheSpotMode:[self canSupportSettingsOnTheSpotForObject:(!_locked && _active) ? _selectedInModelObject : nil]];
        [self activateIfNeeded];
        if (_selectedInModelObject == _newObjectRef) {
            [self setNewObject:nil didAdd:NO];
        }
    }
}

- (void)setSelectedInModelObjectAndBringAssistantToFront:(id)aFront
{
    [self cancelPreviousRequestsToChangeSelectedInModelObject];
    [self setAtomicSelectedInModelObjectAndBringAssistantToFront:aFront];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fe968 @ 000fe968, 335 bytes * /

void FUN_000fe968(HSObjectAssistantController *self,SEL _cmd,
                 id setAtomicSelectedInModelObjectAndBringAssistantToFront)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_objectAssistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_isCurrentlyWorkingInSOTSMode);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_canSupportSettingsOnTheSpotForObject_,
                           self->_selectedInModelObject);
    if ((char)pvVar1 != '\0') goto LAB_000fea1b;
  }
  if (self->_selectedInModelObject != setAtomicSelectedInModelObjectAndBringAssistantToFront) {
    pvVar1 = _objc_msgSend(self,sel_objectAssistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_prefersInspectorMode);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_objectAssistant);
      _objc_msgSend(pvVar1,sel_hideAssistant_,0);
    }
  }
LAB_000fea1b:
  uVar3 = 1;
  pvVar1 = setAtomicSelectedInModelObjectAndBringAssistantToFront;
  _objc_msgSend(self,sel_setSelectedInModelObject_needToBringAssistantWindowToFront_,
                setAtomicSelectedInModelObjectAndBringAssistantToFront,1);
  if (setAtomicSelectedInModelObjectAndBringAssistantToFront != (id)0x0) {
    pvVar2 = _objc_msgSend(setAtomicSelectedInModelObjectAndBringAssistantToFront,sel_isHyperProxy,
                           pvVar1,uVar3);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_objectAssistant,pvVar1,uVar3);
      pvVar2 = _objc_msgSend(pvVar2,sel_isActive);
      if ((char)pvVar2 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_objectAssistant,pvVar1,uVar3);
        _objc_msgSend(pvVar1,sel_setShouldBeVisible_animate_,1,0);
      }
    }
  }
  return;
}

*/
- (void)setAtomicSelectedInModelObjectAndBringAssistantToFront:(id)aFront
{
    if (![[self objectAssistant] isCurrentlyWorkingInSOTSMode] && [self canSupportSettingsOnTheSpotForObject:_selectedInModelObject]) {
        // The assistant is kept as it is: the new selection is applied below.
    } else if (_selectedInModelObject != aFront && ![[self objectAssistant] prefersInspectorMode]) {
        [[self objectAssistant] hideAssistant:NO];
    }
    [self setSelectedInModelObject:aFront needToBringAssistantWindowToFront:YES];
    if (aFront != nil && ![aFront isHyperProxy] && [[self objectAssistant] isActive]) {
        [[self objectAssistant] setShouldBeVisible:YES animate:NO];
    }
}

- (void)setSelectedInModelObject:(id)aObject
{
    [self cancelPreviousRequestsToChangeSelectedInModelObject];
    [self setAtomicSelectedInModelObject:aObject];
}

- (void)setAtomicSelectedInModelObject:(id)aObject
{
    [self setSelectedInModelObject:aObject needToBringAssistantWindowToFront:NO];
}

- (void)cancelPreviousRequestsToChangeSelectedInModelObject
{
    if (_objectAssistantControllerProxy != nil) {
        [[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:_objectAssistantControllerProxy];
    }
}

- (NSRect)selectedObjectScreenFrame
{
    NSRect result;

    result = [self objectScreenFrame:_selectedObject];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fe84f @ 000fe84f, 82 bytes * /

void FUN_000fe84f(HSObjectAssistantController *self,SEL _cmd)

{
  ushort uVar1;
  id pvVar2;
  
  uVar1._0_1_ = self->_locked[0];
  uVar1._1_1_ = self->_geometryLocked[0];
  if ((uVar1 & 1) == 0) {
    if ((uVar1 & 4) == 0) {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar2 = self->_selectedInModelObject;
    }
    _objc_msgSend(self,sel_applySelectedObject_,pvVar2);
  }
  return;
}

*/
- (void)applySelectedObjectIfPossible
{
    if (!_locked) {
        [self applySelectedObject:_active ? _selectedInModelObject : nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000fe7a0 @ 000fe7a0, 175 bytes * /

void FUN_000fe7a0(HSObjectAssistantController *self,SEL _cmd,id applySelectedObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar3 = self->_selectedObject;
  if (pvVar3 != applySelectedObject) {
    pvVar2 = applySelectedObject;
    pvVar1 = _objc_msgSend(self,sel_canAssistObject_,applySelectedObject);
    pvVar3 = (id)0x0;
    if ((char)pvVar1 != '\0') {
      pvVar3 = applySelectedObject;
    }
    _objc_msgSend(self,sel_unsubscribeFromNotifications,pvVar2);
    self->_selectedObject = pvVar3;
    _objc_msgSend(self,sel_subscribeToNotifications);
    pvVar3 = self->_selectedObject;
  }
  pvVar2 = _objc_msgSend(self,sel_objectAssistant);
  op = sel_deactivate;
  if (pvVar3 != (id)0x0) {
    op = sel_activateWithObject_delegate_;
  }
  _objc_msgSend(pvVar2,op);
  return;
}

*/
- (void)applySelectedObject:(id)aObject
{
    if (_selectedObject != aObject) {
        id assistable = [self canAssistObject:aObject] ? aObject : nil;
        [self unsubscribeFromNotifications];
        _selectedObject = assistable;
        [self subscribeToNotifications];
    }
    if (_selectedObject != nil) {
        [[self objectAssistant] activateWithObject:_selectedObject delegate:self];
    } else {
        [[self objectAssistant] deactivate];
    }
}

- (NSRect)objectScreenFrame:(id)aFrame
{
    NSRect result;

    result = [self objectScreenFrame:aFrame allowEmptyFrame:NO];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00101eeb @ 00101eeb, 825 bytes * /

NSRect * FUN_00101eeb(NSRect *__return_storage_ptr__,HSObjectAssistantController *self,SEL _cmd,
                     id objectScreenFrame,BOOL allowEmptyFrame)

{
  char cVar1;
  id pvVar2;
  id self_00;
  NSRect *extraout_EAX;
  undefined4 *puVar3;
  undefined4 local_ac;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  float local_54;
  float fStack_50;
  float local_4c;
  float fStack_48;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  undefined1 local_24 [20];
  
  local_34 = *(float *)PTR_00336078;
  fStack_30 = *(float *)(PTR_00336078 + 4);
  local_2c = *(float *)(PTR_00336078 + 8);
  fStack_28 = *(float *)(PTR_00336078 + 0xc);
  pvVar2 = _objc_msgSend(objectScreenFrame,sel_implementsHyperInterface_);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(objectScreenFrame,sel_implementsHyperInterface_);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_currentEditorView);
      puVar3 = (undefined4 *)&stack0xffffff64;
      if ((pvVar2 != (id)0x0) &&
         (self_00 = _objc_msgSend(self,sel_boundingFramePathInView_forObject_),
         puVar3 = (undefined4 *)&stack0xffffff64, self_00 != (id)0x0)) {
        _objc_msgSend_stret(&local_54,pvVar2,sel_visibleRect);
        _objc_msgSend_stret(local_24,self_00,sel_hyperVisualBounds);
        _local_ac = CONCAT44(0x102092,local_ac);
        _NSIntersectionRect();
        local_34 = local_64;
        fStack_30 = (float)local_60;
        local_2c = (float)local_5c;
        fStack_28 = (float)local_58;
        _local_ac = CONCAT44(&local_74,0x1020f4);
        _objc_msgSend_stret(&local_74,pvVar2,sel_convertRect_toView_);
        local_34 = local_74;
        fStack_30 = local_70;
        local_2c = local_6c;
        fStack_28 = local_68;
        puVar3 = &local_ac;
        if (allowEmptyFrame == '\0') {
          cVar1 = _NSIsEmptyRect();
          if (cVar1 != '\0') {
            local_34 = (self->_lastNonEmptyRect).origin.x;
            fStack_30 = (self->_lastNonEmptyRect).origin.y;
            local_2c = (self->_lastNonEmptyRect).size.width;
            fStack_28 = (self->_lastNonEmptyRect).size.height;
          }
          _local_ac = CONCAT44(fStack_30,local_34);
          cVar1 = _NSIsEmptyRect();
          if (cVar1 != '\0') {
            local_34 = local_54;
            fStack_30 = fStack_50;
            local_2c = local_4c;
            fStack_28 = fStack_48;
          }
          (self->_lastNonEmptyRect).origin.x = local_34;
          (self->_lastNonEmptyRect).origin.y = fStack_30;
          (self->_lastNonEmptyRect).size.width = local_2c;
          (self->_lastNonEmptyRect).size.height = fStack_28;
          puVar3 = &local_ac;
        }
      }
    }
    else {
      _objc_msgSend_stret(&local_44,self,sel_editorViewFrame);
      local_34 = local_44;
      fStack_30 = local_40;
      local_2c = local_3c;
      fStack_28 = local_38;
      puVar3 = (undefined4 *)&stack0xffffff60;
    }
  }
  else {
    _objc_msgSend_stret(&local_34,self,sel_editorViewFrame);
    puVar3 = (undefined4 *)&stack0xffffff60;
  }
  *(ulonglong *)(puVar3 + 5) = CONCAT44(fStack_28,local_2c);
  *(ulonglong *)(puVar3 + 3) = CONCAT44(fStack_30,local_34);
  puVar3[2] = sel_convertBaseToScreen_;
  puVar3[1] = self;
  *puVar3 = __return_storage_ptr__;
  puVar3[-1] = 0x102217;
  _objc_msgSend_stret((void *)*puVar3,(id)puVar3[1],(SEL)puVar3[2]);
  return extraout_EAX;
}

*/
- (NSRect)objectScreenFrame:(id)aFrame allowEmptyFrame:(BOOL)aFrame2
{
    NSRect frame = NSZeroRect;
    if ([aFrame implementsHyperInterface:@protocol(HSStackAttributes)] || [aFrame implementsHyperInterface:@protocol(HSCardAttributes)]) {
        frame = [self editorViewFrame];
    } else {
        NSView *editorView = [self currentEditorView];
        id path = (editorView != nil) ? [self boundingFramePathInView:editorView forObject:aFrame] : nil;
        if (path != nil) {
            NSRect visibleRect = [editorView visibleRect];
            frame = NSIntersectionRect(visibleRect, [path hyperVisualBounds]);
            frame = [editorView convertRect:frame toView:nil];
            if (!aFrame2) {
                if (NSIsEmptyRect(frame)) {
                    frame = _lastNonEmptyRect;
                }
                if (NSIsEmptyRect(frame)) {
                    frame = visibleRect;
                }
                _lastNonEmptyRect = frame;
            }
        }
    }
    return [self convertBaseToScreen:frame];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00101e2b @ 00101e2b, 192 bytes * /

NSRect * FUN_00101e2b(NSRect *__return_storage_ptr__,HSObjectAssistantController *self,SEL _cmd,
                     NSRect convertBaseToScreen)

{
  NSRect *pNVar1;
  id pvVar2;
  float extraout_EDX;
  
  pNVar1 = (NSRect *)_NSIsEmptyRect(convertBaseToScreen.origin,convertBaseToScreen.size);
  if ((char)pNVar1 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_currentEditorWindowController);
    pvVar2 = _objc_msgSend(pvVar2,sel_window);
    pNVar1 = _objc_msgSend(pvVar2,sel_convertBaseToScreen_,convertBaseToScreen.origin.x,
                           convertBaseToScreen.origin.y);
    convertBaseToScreen.origin.y = extraout_EDX;
    convertBaseToScreen.origin.x = (float)pNVar1;
  }
  (__return_storage_ptr__->origin).x = convertBaseToScreen.origin.x;
  (__return_storage_ptr__->origin).y = convertBaseToScreen.origin.y;
  (__return_storage_ptr__->size).width = convertBaseToScreen.size.width;
  (__return_storage_ptr__->size).height = convertBaseToScreen.size.height;
  return pNVar1;
}

*/
- (NSRect)convertBaseToScreen:(NSRect)aScreen
{
    if (!NSIsEmptyRect(aScreen)) {
        NSWindow *window = [[self currentEditorWindowController] window];
        aScreen.origin = [window convertRectToScreen:NSMakeRect(aScreen.origin.x, aScreen.origin.y, 0.0, 0.0)].origin;
    }
    return aScreen;
}

- (NSRect)screenBounds
{
    NSRect result;

    result = [[NSScreen mainScreen] visibleFrame];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001019cf @ 001019cf, 301 bytes * /

NSRect * FUN_001019cf(NSRect *__return_storage_ptr__,HSObjectAssistantController *self,SEL _cmd)

{
  id pvVar1;
  undefined8 in_stack_ffffffbc;
  undefined4 uVar3;
  undefined8 uVar2;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined8 local_1c;
  undefined8 local_14;
  
  uVar3 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  local_2c = *(float *)PTR_00336078;
  local_28 = *(float *)(PTR_00336078 + 4);
  local_24 = *(float *)(PTR_00336078 + 8);
  local_20 = *(float *)(PTR_00336078 + 0xc);
  pvVar1 = _objc_msgSend(self->_mainWindow,sel_windowController);
  uVar2 = CONCAT44(uVar3,sel_cardView);
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_cardView);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_mainWindow,sel_windowController,uVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend_stret(&local_1c,pvVar1,sel_visibleRect);
      _objc_msgSend_stret(&local_2c,pvVar1,sel_convertRect_toView_,local_1c,local_14,0);
    }
  }
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = local_28;
  (__return_storage_ptr__->size).width = local_24;
  (__return_storage_ptr__->size).height = local_20;
  return __return_storage_ptr__;
}

*/
- (NSRect)editorViewFrame
{
    NSRect frame = NSZeroRect;
    id windowController = [_mainWindow windowController];
    if ([windowController respondsToSelector:@selector(cardView)]) {
        NSView *cardView = [windowController cardView];
        if (cardView != nil) {
            frame = [cardView convertRect:[cardView visibleRect] toView:nil];
        }
    }
    return frame;
}

- (id)currentStackController
{
    return [[self currentEditorWindowController] stackView];
}

- (id)currentEditorView
{
    return [[self currentEditorWindowController] cardView];
}

- (id)currentEditorWindowController
{
    NSWindowController *self_00;
    BOOL pvVar2;
    id pvVar3;
    BOOL pvVar1_2;

    self_00 = [_mainWindow windowController];
    pvVar2 = [self_00 isKindOfClass:[HSEditorWindowController class]];
    pvVar3 = self_00;
    if (!pvVar2) {
        pvVar1_2 = [self_00 isKindOfClass:[NSNull class]];
        pvVar3 = nil;
        if (pvVar1_2) {
            pvVar3 = self_00;
        }
    }
    return pvVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00101c26 @ 00101c26, 517 bytes * /

id FUN_00101c26(HSObjectAssistantController *self,SEL _cmd,id boundingFramePathInView,id forObject)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id self_00;
  undefined4 extraout_EDX;
  double dVar4;
  undefined *puVar5;
  undefined4 local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined4 local_54;
  undefined4 uStack_50;
  undefined4 local_4c;
  undefined4 uStack_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  id local_34;
  undefined1 local_2c [8];
  undefined8 local_24;
  undefined8 local_1c;
  
  puVar5 = &DAT_0036f688;
  pvVar3 = _objc_msgSend(forObject,sel_queryHyperInterface_,&DAT_0036f688);
  if (pvVar3 == (id)0x0) {
    self_00 = (id)0x0;
  }
  else {
    uVar1 = *(undefined4 *)PTR_00336074;
    uVar2 = *(undefined4 *)(PTR_00336074 + 4);
    local_34 = _objc_msgSend(pvVar3,sel_size,puVar5);
    local_3c = uVar1;
    uStack_38 = uVar2;
    self_00 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,uVar1,uVar2,local_34,
                            extraout_EDX);
    _objc_msgSend_stret(&local_54,pvVar3,sel_affineTransform);
    _objc_msgSend_stret(local_2c,boundingFramePathInView,sel_userSpaceToViewSpaceCGAffineTransform);
    _CGAffineTransformConcat
              (&local_6c,CONCAT44(uStack_50,local_54),local_4c,uStack_48,local_44,uStack_40,
               local_2c._0_4_,local_2c._4_4_,local_24,local_1c);
    local_54 = local_6c;
    uStack_50 = local_68;
    local_4c = local_64;
    uStack_48 = local_60;
    local_44 = local_5c;
    uStack_40 = local_58;
    pvVar3 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperCGAffineTransform_,
                           CONCAT44(local_68,local_6c),local_64,local_60,local_5c,local_58);
    _objc_msgSend(self_00,sel_transformUsingAffineTransform_,pvVar3);
    dVar4 = _objc_msgSend_fpret(cls_HSSelectedObjectCanvasItem,sel_cardObjectBoundingFrameThickness)
    ;
    _objc_msgSend(self_00,sel_setLineWidth_,(float)dVar4);
  }
  return self_00;
}

*/
- (id)boundingFramePathInView:(id)aView forObject:(id)aObject
{
    id geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil) {
        return nil;
    }
    NSSize size = [geometry size];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, size.width, size.height)];
    CGAffineTransform transform = CGAffineTransformConcat([geometry affineTransform], [aView userSpaceToViewSpaceCGAffineTransform]);
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:transform]];
    [path setLineWidth:[HSSelectedObjectCanvasItem cardObjectBoundingFrameThickness]];
    return path;
}

- (BOOL)canAssistObject:(id)aObject
{
    BOOL pvVar1;

    if ((aObject != nil) && (pvVar1 = [aObject respondsToSelector:@selector(rootViewController)], pvVar1)) {
        if ([aObject queryHyperInterface:@protocol(HSRunTimeEditor)] != nil) {
            return [aObject queryHyperInterface:@protocol(HSObjectAttributes)] != nil;
        }
        return YES;
    }
    return NO;
}

- (void)unsubscribeFromNotifications
{
    int uVar1;
    id pvVar2_2;

    pvVar2_2 = [[_selectedObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    if (pvVar2_2 != nil) {
        [pvVar2_2 removeObserver:self selector:@selector(geometryAttributesWillStartChanging:) ofChanges:0x40 ofAttribute:@protocol(HSGeometryAttribute)];
        [pvVar2_2 removeObserver:self selector:@selector(geometryAttributesDidEndChanging:) ofChanges:0x80 ofAttribute:@protocol(HSGeometryAttribute)];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2_2 removeObserver:self selector:@selector(geometryAttributesDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSGeometryAttribute)];
        [pvVar2_2 removeObserver:self selector:@selector(nameAttributesDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSObjectNameAttribute)];
        [pvVar2_2 removeObserver:self selector:@selector(hiddenAttributeChanged:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute)];
    }
}

- (void)subscribeToNotifications
{
    int uVar6;
    id pvVar1_2;
    NSView *pvVar2_2;

    pvVar1_2 = [[_selectedObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    if (pvVar1_2 != nil) {
        [self HSObjectAssistantController_subscribeForGeometryChangesIfNonContinuousWithAttributeObservingController:pvVar1_2];
        [pvVar1_2 addObserver:self selector:@selector(geometryAttributesWillStartChanging:) ofChanges:0x40 ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
        [pvVar1_2 addObserver:self selector:@selector(geometryAttributesDidEndChanging:) ofChanges:0x80 ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
        uVar6 = HSActualDidAttributeChanges;
        [pvVar1_2 addObserver:self selector:@selector(nameAttributesDidChange:) ofChanges:uVar6 ofAttribute:@protocol(HSObjectNameAttribute) withPriority:-0.25];
        pvVar2_2 = [[self currentEditorView] superview];
        if (pvVar2_2 != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardVisibleAreaChanged:) name:NSViewBoundsDidChangeNotification object:pvVar2_2];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardVisibleAreaChanged:) name:NSViewFrameDidChangeNotification object:pvVar2_2];
        }
        [pvVar1_2 addObserver:self selector:@selector(hiddenAttributeChanged:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) withPriority:-0.25];
    }
}

- (void)HSObjectAssistantController_subscribeForGeometryChangesIfNonContinuousWithAttributeObservingController:(id)aController
{
    id pvVar1;

    pvVar1 = [aController attributesBeingChangedContinuously];
    if (![pvVar1 containsProtocol:@protocol(HSWidthAttribute)]) {
        if (![pvVar1 containsProtocol:@protocol(HSHeightAttribute)]) {
            if (![pvVar1 containsProtocol:@protocol(HSHorizontalScaleAttribute)]) {
                if (![pvVar1 containsProtocol:@protocol(HSVerticalScaleAttribute)]) {
                    if (![pvVar1 containsProtocol:@protocol(HSWidthScaleAttribute)]) {
                        if (![pvVar1 containsProtocol:@protocol(HSHeightScaleAttribute)]) {
                            if (![pvVar1 containsProtocol:@protocol(HSHorizontalFlipAttribute)]) {
                                if (![pvVar1 containsProtocol:@protocol(HSVerticalFlipAttribute)]) {
                                    if (![pvVar1 containsProtocol:@protocol(HSRotationAngleAttribute)]) {
                                        if (![pvVar1 containsProtocol:@protocol(HSSkewAngleAttribute)]) {
                                            if (![pvVar1 containsProtocol:@protocol(HSHorizontalOffsetAttribute)]) {
                                                if (![pvVar1 containsProtocol:@protocol(HSVerticalOffsetAttribute)]) {
                                                    [aController addObserver:self selector:@selector(geometryAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (id)objectAssistant
{
    HSObjectAssistant *pHVar1;

    pHVar1 = _objectAssistant;
    if (pHVar1 == nil) {
        pHVar1 = [HSObjectAssistant new];
        _objectAssistant = pHVar1;
    }
    return pHVar1;
}

- (BOOL)canSupportSettingsOnTheSpot
{
    return [self canSupportSettingsOnTheSpotForObject:_selectedInModelObject];
}

- (BOOL)shouldOpenCardInfo
{
    if (![_selectedInModelObject implementsHyperInterface:@protocol(HSMutableCardAttributes)])
        return NO;
    return _shouldOpenCardInfo;
}

- (void)noteSupportsSettingsOnTheSpotDidChange
{
    [[self objectAssistant] setSupportsSettingsOnTheSpotMode:[self canSupportSettingsOnTheSpot]];
}

@end

@implementation HSObjectAssistantController (HSObjectAssistantDelegate)

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010192d @ 0010192d, 162 bytes * /

BOOL FUN_0010192d(HSObjectAssistantController *self,SEL _cmd,id objectAssistant,
                 SEL doCommandBySelector)

{
  SEL op;
  
  if (((((sel_deleteForward_ == doCommandBySelector) || (sel_deleteBackward_ == doCommandBySelector)
        ) || (sel_moveLeft_ == doCommandBySelector)) ||
      ((sel_moveRight_ == doCommandBySelector || (sel_moveUp_ == doCommandBySelector)))) ||
     (sel_moveDown_ == doCommandBySelector)) {
    objectAssistant = _objc_msgSend(self,sel_currentEditorView);
    op = sel_doCommandBySelector_;
    self = (HSObjectAssistantController *)doCommandBySelector;
  }
  else {
    op = sel_performClose_;
    if ((sel_cancel_ != doCommandBySelector) && (sel_cancelOperation_ != doCommandBySelector)) {
      return '\0';
    }
  }
  _objc_msgSend(objectAssistant,op,self);
  return '\x01';
}

*/
- (BOOL)objectAssistant:(id)aAssistant doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(deleteForward:) || aSelector == @selector(deleteBackward:) || aSelector == @selector(moveLeft:)
        || aSelector == @selector(moveRight:) || aSelector == @selector(moveUp:) || aSelector == @selector(moveDown:)) {
        [[self currentEditorView] doCommandBySelector:aSelector];
        return YES;
    }
    if (aSelector == @selector(cancel:) || aSelector == @selector(cancelOperation:)) {
        [aAssistant performClose:self];
        return YES;
    }
    return NO;
}

- (id)objectAssistantParentWindow:(id)aWindow
{
    return [[self currentEditorWindowController] window];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010187e @ 0010187e, 117 bytes * /

id FUN_0010187e(HSObjectAssistantController *self,SEL _cmd,id objectAssistant,
               id paneHistoryForObject)

{
  id pvVar1;
  HSObjectAssistantController *self_00;
  SEL op;
  
  self_00 = self;
  op = sel_paneHistoryForObject_;
  if ((self->_lockedDelegate != (id)0x0) &&
     (pvVar1 = _objc_msgSend(self->_lockedDelegate,sel_respondsToSelector_,
                             sel_lockedObjectAssistantController_paneHistoryForObject_),
     op = sel_paneHistoryForObject_, (char)pvVar1 != '\0')) {
    self_00 = self->_lockedDelegate;
    op = sel_lockedObjectAssistantController_paneHistoryForObject_;
    paneHistoryForObject = self;
  }
  pvVar1 = _objc_msgSend(self_00,op,paneHistoryForObject);
  return pvVar1;
}

*/
- (id)objectAssistant:(id)aAssistant paneHistoryForObject:(id)aObject
{
    if (_lockedDelegate != nil && [_lockedDelegate respondsToSelector:@selector(lockedObjectAssistantController:paneHistoryForObject:)]) {
        return [_lockedDelegate lockedObjectAssistantController:self paneHistoryForObject:aObject];
    }
    return [self paneHistoryForObject:aObject];
}

- (void)userDidMoveObjectAssistantWindow:(id)aWindow
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00101818 @ 00101818, 102 bytes * /

void FUN_00101818(HSObjectAssistantController *self,SEL _cmd,id objectAssistantDidCloseByUser)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_canChangeActive);
  if (((char)pvVar1 == '\0') && (pvVar1 = _objc_msgSend(self,sel_stack), pvVar1 != (id)0x0)) {
    return;
  }
  _objc_msgSend(self,sel_setActive_explicitlyByUser_,0,1);
  return;
}

*/
- (void)objectAssistantDidCloseByUser:(id)aUser
{
    if (![self canChangeActive] && [self stack] != nil) {
        return;
    }
    [self setActive:NO explicitlyByUser:YES];
}

- (void)objectAssistantDidFinishObjectEditing:(id)aEditing
{
    id pvVar1;

    pvVar1 = [aEditing object];
    [self setPaneHistory:[aEditing paneHistory] forObject:pvVar1];
}

- (BOOL)objectAssistantWillFinishObjectEditing:(id)aEditing
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00102224 @ 00102224, 372 bytes * /

NSRect * FUN_00102224(NSRect *__return_storage_ptr__,HSObjectAssistantController *self,SEL _cmd,
                     id editorCardViewFrameForObjectAssistant)

{
  id self_00;
  id self_01;
  NSRect *pNVar1;
  float extraout_EDX;
  undefined4 local_64;
  undefined4 local_60;
  float local_5c;
  float local_58;
  undefined1 local_54 [16];
  undefined8 local_44 [2];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  self_00 = _objc_msgSend(self,sel_currentEditorView);
  self_01 = _objc_msgSend(self_00,sel_window);
  _objc_msgSend_stret(local_34,self_00,sel_visibleRect);
  _objc_msgSend_stret(local_44,self_00,sel_convertRect_toView_,(int)local_34._0_8_,
                      SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4),0);
  _objc_msgSend_stret(local_24,self_00,sel_contentViewingRect);
  _objc_msgSend_stret(local_54,self_00,sel_convertRect_toView_,(int)local_24._0_8_,
                      SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4),0);
  _NSIntersectionRect(&local_64,local_44[0],(int)local_44[1],(int)((ulonglong)local_44[1] >> 0x20),
                      (int)local_54._0_8_,SUB84(local_54._0_8_,4),(int)local_54._8_8_,
                      SUB84(local_54._8_8_,4));
  pNVar1 = _objc_msgSend(self_01,sel_convertBaseToScreen_,local_64,local_60);
  (__return_storage_ptr__->origin).x = (float)pNVar1;
  (__return_storage_ptr__->origin).y = extraout_EDX;
  (__return_storage_ptr__->size).width = local_5c;
  (__return_storage_ptr__->size).height = local_58;
  return pNVar1;
}

*/
- (NSRect)editorCardViewFrameForObjectAssistant:(id)aAssistant
{
    id editorView = [self currentEditorView];
    NSWindow *window = [editorView window];
    NSRect visibleRect = [editorView convertRect:[editorView visibleRect] toView:nil];
    NSRect viewingRect = [editorView convertRect:[editorView contentViewingRect] toView:nil];
    NSRect frame = NSIntersectionRect(visibleRect, viewingRect);
    frame.origin = [window convertRectToScreen:NSMakeRect(frame.origin.x, frame.origin.y, 0.0, 0.0)].origin;
    return frame;
}

- (NSRect)mainWindowFrameForObjectAssistant:(id)aAssistant
{
    NSRect result;

    result = [_mainWindow frame];
    return result;
}

- (NSRect)objectAssistantObjectScreenFrame:(id)aFrame
{
    NSRect result;

    result = [self objectScreenFrame:_selectedObject allowEmptyFrame:YES];
    return result;
}

@end

