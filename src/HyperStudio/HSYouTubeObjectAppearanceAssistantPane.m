#import "HSYouTubeObjectAppearanceAssistantPane.h"

@implementation HSYouTubeObjectAppearanceAssistantPane

/* i386 ivar offsets: _nameTextField=0x5c, _authorLinkButton=0x60, _durationTextField=0x64, _shadowSwitch=0x68, _shadowButton=0x6c, _watchButton=0x70, _changeButton=0x74 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00214892 @ 00214892, 917 bytes * /

void FUN_00214892(HSYouTubeObjectAppearanceAssistantPane *self,SEL _cmd,id youTubeDialog,
                 int didEndWithReturnCode)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  undefined8 in_stack_ffffffdc;
  undefined4 uVar7;
  undefined8 uVar6;
  cfstringStruct *pcVar8;
  char local_11;
  
  uVar7 = (undefined4)((ulonglong)in_stack_ffffffdc >> 0x20);
  if (didEndWithReturnCode == 1) {
    pvVar1 = _objc_msgSend(youTubeDialog,sel_youTubeMovieID);
    pvVar2 = _objc_msgSend(self,sel_youTubeObjectAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_youTubeMovieID);
    uVar6 = CONCAT44(uVar7,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar2);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_stack,uVar6);
      pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
      if (pvVar1 == (id)0x0) {
        local_11 = '\0';
      }
      else {
        pvVar2 = _objc_msgSend(pvVar1,sel_groupsByEvent,uVar6);
        local_11 = (char)pvVar2;
        _objc_msgSend(pvVar1,sel_setGroupsByEvent_,0);
        _objc_msgSend(pvVar1,sel_beginUndoGrouping);
        pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
        pcVar8 = &cfstr_empty;
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                               &cfstr_Change_YouTube_Video,&cfstr_empty,&cfstr_UndoManager);
        uVar6 = CONCAT44(pcVar8,pvVar2);
        _objc_msgSend(pvVar1,sel_setMultipleActionsName_,pvVar2);
      }
      pvVar2 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,uVar6);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieID);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieID_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieURL);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieURL_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieWatchURL);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieWatchURL_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieTitle);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieTitle_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieAuthor);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieAuthor_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieAuthorURL);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieAuthorURL_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_youTubeObjectAttributes);
      dVar5 = _objc_msgSend_fpret(youTubeDialog,sel_youTubeMovieDuration);
      _objc_msgSend(pvVar3,sel_setYouTubeMovieDuration_,dVar5);
      _objc_msgSend(pvVar2,sel_release);
      if (pvVar1 != (id)0x0) {
        _objc_msgSend(pvVar1,sel_endUndoGrouping,dVar5);
        _objc_msgSend(pvVar1,sel_setGroupsByEvent_,(int)local_11);
      }
    }
  }
  _objc_msgSend(youTubeDialog,sel_autorelease);
  return;
}

*/
- (void)youTubeDialog:(id)aDialog didEndWithReturnCode:(NSInteger)aCode
{
    if (aCode == 1 && ![[aDialog youTubeMovieID] isEqualToString:[[self youTubeObjectAttributes] youTubeMovieID]]) {
        NSUndoManager *undoManager = [[self stack] undoManager];
        BOOL groupsByEvent = NO;
        if (undoManager != nil) {
            groupsByEvent = [undoManager groupsByEvent];
            [undoManager setGroupsByEvent:NO];
            [undoManager beginUndoGrouping];
            [undoManager setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Change YouTube Video" value:@"" table:@"UndoManager"]];
        }
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [[self youTubeObjectAttributes] setYouTubeMovieID:[aDialog youTubeMovieID]];
        [[self youTubeObjectAttributes] setYouTubeMovieURL:[aDialog youTubeMovieURL]];
        [[self youTubeObjectAttributes] setYouTubeMovieWatchURL:[aDialog youTubeMovieWatchURL]];
        [[self youTubeObjectAttributes] setYouTubeMovieTitle:[aDialog youTubeMovieTitle]];
        [[self youTubeObjectAttributes] setYouTubeMovieAuthor:[aDialog youTubeMovieAuthor]];
        [[self youTubeObjectAttributes] setYouTubeMovieAuthorURL:[aDialog youTubeMovieAuthorURL]];
        [[self youTubeObjectAttributes] setYouTubeMovieDuration:[aDialog youTubeMovieDuration]];
        [pool release];
        if (undoManager != nil) {
            [undoManager endUndoGrouping];
            [undoManager setGroupsByEvent:groupsByEvent];
        }
    }
    [aDialog autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00214c27 @ 00214c27, 281 bytes * /

void FUN_00214c27(HSYouTubeObjectAppearanceAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  uint uVar4;
  undefined1 local_24 [12];
  undefined4 local_18;
  
  pvVar2 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_isHyperShadowEnabled);
  cVar1 = (char)pvVar2;
  _objc_msgSend(self->_shadowSwitch,sel_setState_,(int)cVar1);
  uVar4 = (uint)(cVar1 == '\0');
  _objc_msgSend(self->_shadowButton,sel_setHidden_,uVar4);
  if (cVar1 == '\0') {
    pcVar3 = _objc_msgSend(self->_shadowButton,sel_title,uVar4);
  }
  else {
    pcVar3 = &cfstr_empty;
  }
  _objc_msgSend(self->_shadowSwitch,sel_setTitle_,pcVar3);
  pvVar2 = self->_shadowSwitch;
  _objc_msgSend_stret(local_24,pvVar2,sel_frame);
  _objc_msgSend(pvVar2,sel_setFrameSize_,*(undefined4 *)(&DAT_00335bd0 + (uint)(cVar1 == '\0') * 4),
                local_18);
  return;
}

*/
- (void)updateShadow
{
    BOOL enabled = [[self shadowAttributes] isHyperShadowEnabled];
    [_shadowSwitch setState:enabled];
    [_shadowButton setHidden:!enabled];
    [_shadowSwitch setTitle:enabled ? @"" : [_shadowButton title]];
    NSRect frame = [_shadowSwitch frame];
    [_shadowSwitch setFrameSize:NSMakeSize(enabled ? 14.0f : 72.0f, frame.size.height)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00214d40 @ 00214d40, 588 bytes * /

void FUN_00214d40(HSYouTubeObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id self_00;
  int iVar4;
  double dVar5;
  int iVar6;
  
  pvVar1 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  pcVar2 = _objc_msgSend(pvVar1,sel_youTubeMovieTitle);
  if (pcVar2 == (cfstringStruct *)0x0) {
    pcVar2 = &cfstr___;
  }
  _objc_msgSend(self->_nameTextField,sel_setStringValue_,pcVar2);
  pvVar1 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  pvVar3 = _objc_msgSend(pvVar1,sel_youTubeMovieAuthor);
  pvVar1 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  self_00 = _objc_msgSend(pvVar1,sel_youTubeMovieAuthorURL);
  pvVar1 = self->_authorLinkButton;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self_00,sel_absoluteString);
  }
  _objc_msgSend(pvVar1,sel_setTitle_,pvVar3);
  _objc_msgSend(self->_authorLinkButton,sel_setURL_,self_00);
  pvVar1 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  dVar5 = _objc_msgSend_fpret(pvVar1,sel_youTubeMovieDuration);
  iVar4 = (int)dVar5 % 0x3c;
  iVar6 = ((int)dVar5 - iVar4) / 0x3c;
  pcVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr___2d___2d,iVar6,iVar4);
  if (pcVar2 == (cfstringStruct *)0x0) {
    pcVar2 = &cfstr___;
  }
  _objc_msgSend(self->_durationTextField,sel_setStringValue_,pcVar2,iVar6,iVar4);
  pvVar1 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_youTubeMovieWatchURL);
  _objc_msgSend(self->_watchButton,sel_setEnabled_,(uint)(pvVar1 != (id)0x0),iVar6,iVar4);
  pvVar1 = self->_changeButton;
  pvVar3 = _objc_msgSend(cls_HSRestrictionsManager,sel_restrictionState_,*(undefined4 *)PTR_00336148
                        );
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)(char)pvVar3);
  return;
}

*/
- (void)validateUI
{
    NSString *title = [[self youTubeObjectAttributes] youTubeMovieTitle];
    [_nameTextField setStringValue:(title != nil) ? title : @"--"];
    NSString *author = [[self youTubeObjectAttributes] youTubeMovieAuthor];
    NSURL *authorURL = [[self youTubeObjectAttributes] youTubeMovieAuthorURL];
    [_authorLinkButton setTitle:(author != nil) ? author : [authorURL absoluteString]];
    [_authorLinkButton setURL:authorURL];
    int duration = (int)[[self youTubeObjectAttributes] youTubeMovieDuration];
    int seconds = duration % 60;
    int minutes = (duration - seconds) / 60;
    NSString *durationString = [NSString stringWithFormat:@"%.2d:%.2d", minutes, seconds];
    [_durationTextField setStringValue:(durationString != nil) ? durationString : @"--"];
    [_watchButton setEnabled:([[self youTubeObjectAttributes] youTubeMovieWatchURL] != nil)];
    [_changeButton setEnabled:(BOOL)[HSRestrictionsManager restrictionState:HSYouTubeDialogEnabled]];
}

- (void)validateShadowAttributesWithNotification:(id)aNotification
{
    [self updateShadow];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)changeVideo:(id)aVideo
{
    [[[HSYouTubeMoviesDialogController alloc] init] runForWindow:[[[NSDocumentController sharedDocumentController] currentDocument] windowForSheet] delegate:self didEndSelector:@selector(youTubeDialog:didEndWithReturnCode:)];
}

- (void)watchOnYouTube:(id)aTube
{
    id pvVar1_2;

    pvVar1_2 = [[self youTubeObjectAttributes] youTubeMovieWatchURL];
    if (pvVar1_2 != nil) {
        [[NSWorkspace sharedWorkspace] openURL:pvVar1_2];
    }
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00215114 @ 00215114, 201 bytes * /

void FUN_00215114(HSYouTubeObjectAppearanceAssistantPane *self,SEL _cmd,id setShadow)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(setShadow,sel_state);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    uVar2 = 0;
    op = sel_setHyperShadowEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,1);
    _objc_msgSend(self->_shadowButton,sel_setHidden_,0);
    pvVar1 = self->_shadowButton;
    uVar2 = 1;
    op = sel_setEnabled_;
  }
  _objc_msgSend(pvVar1,op,uVar2);
  return;
}

*/
- (void)setShadow:(id)aShadow
{
    NSInteger state = [aShadow state];
    if (state == 0) {
        [[self shadowAttributes] setHyperShadowEnabled:NO];
    } else if (state == 1) {
        [[self shadowAttributes] setHyperShadowEnabled:YES];
        [_shadowButton setHidden:NO];
        [_shadowButton setEnabled:YES];
    }
}

- (void)showShadowPane
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSTextShadowAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

- (void)setName:(id)aName
{
    [[self youTubeObjectAttributes] setYouTubeMovieTitle:[aName stringValue]];
}

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)youTubeObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSYouTubeObjectAttributes)];
}

- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002153b5 @ 002153b5, 312 bytes * /

void FUN_002153b5(HSYouTubeObjectAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  undefined4 uVar1;
  id pvVar2;
  HSYouTubeObjectAppearanceAssistantPane *local_34;
  undefined *local_30;
  undefined *local_2c;
  undefined *local_28;
  undefined *local_24;
  undefined *local_20;
  undefined *local_1c;
  undefined *local_18;
  undefined4 local_14;
  
  local_2c = &DAT_00382d64;
  local_28 = &DAT_00382db4;
  local_24 = &DAT_00382dc8;
  local_20 = &DAT_00382ddc;
  local_1c = &DAT_00382df0;
  local_18 = &DAT_00382e04;
  local_14 = 0;
  pvVar2 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  uVar1 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributes_,self,
                sel_validateUIWithNotification_,uVar1,&local_2c);
  pvVar2 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateShadowAttributesWithNotification_,uVar1,&DAT_00382e18);
  local_34 = self;
  local_30 = PTR_s_HSObjectAssistantPane_00354bf0;
  _objc_msgSendSuper(&local_34,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    id attributes[] = { @protocol(HSYouTubeMovieIDAttribute), @protocol(HSYouTubeMovieURLAttribute), @protocol(HSYouTubeMovieTitleAttribute), @protocol(HSYouTubeMovieAuthorAttribute), @protocol(HSYouTubeMovieDurationAttribute), @protocol(HSYouTubeMovieSizeAttribute), nil };
    [[[self youTubeObjectAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributes:attributes];
    [[[self shadowAttributes] attributeObservingController] removeObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002154ed @ 002154ed, 367 bytes * /

void FUN_002154ed(HSYouTubeObjectAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined4 uVar1;
  id pvVar2;
  undefined *local_38;
  undefined *local_34;
  undefined *local_30;
  undefined *local_2c;
  undefined *local_28;
  undefined *local_24;
  undefined4 local_20;
  HSYouTubeObjectAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00354bf0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  local_38 = &DAT_00382d64;
  local_34 = &DAT_00382db4;
  local_30 = &DAT_00382dc8;
  local_2c = &DAT_00382ddc;
  local_28 = &DAT_00382df0;
  local_24 = &DAT_00382e04;
  local_20 = 0;
  pvVar2 = _objc_msgSend(self,sel_youTubeObjectAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  uVar1 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofAttributes_withPriority_,self,
                sel_validateUIWithNotification_,uVar1,&local_38,0xbe800000);
  pvVar2 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateShadowAttributesWithNotification_,uVar1,&DAT_00382e18,0xbe800000);
  _objc_msgSend(self,sel_validateUI);
  _objc_msgSend(self,sel_updateShadow);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    id attributes[] = { @protocol(HSYouTubeMovieIDAttribute), @protocol(HSYouTubeMovieURLAttribute), @protocol(HSYouTubeMovieTitleAttribute), @protocol(HSYouTubeMovieAuthorAttribute), @protocol(HSYouTubeMovieDurationAttribute), @protocol(HSYouTubeMovieSizeAttribute), nil };
    [[[self youTubeObjectAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributes:attributes withPriority:-0.25];
    [[[self shadowAttributes] attributeObservingController] addObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    [self validateUI];
    [self updateShadow];
}

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"YouTubeObjectAppearancePane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end

