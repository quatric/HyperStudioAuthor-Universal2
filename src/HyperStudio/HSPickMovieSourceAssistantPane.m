#import "HSPickMovieSourceAssistantPane.h"

@implementation HSPickMovieSourceAssistantPane

/* i386 ivar offsets: _diskFolderButton=0x78, _recordVideoButton=0x7c, _showLiveVideoButton=0x80, _movieRecordingAssistantPane=0x84, _navigationPaneSwitcher=0x88, _importMovieObjectDialogController=0x8c, _pickMovieSourcePaneDelegate=0x90 */

- (void)movieRecordingAssistantPane:(id)aPane didChooseMovieObject:(id)aObject
{
    [self processMovieObject:aObject isInUse:NO];
}

- (void)openMovieRecordingAssistantPane
{
    id pvVar1;

    pvVar1 = [self movieRecordingAssistantPane];
    [pvVar1 setActionEvent:[self actionEvent]];
    [[self objectAssistantNavigationController] pushViewController:pvVar1 withIdentifier:@"HSPickMovieSourcePaneIdentifier" animate:YES replacePrevious:NO];
    [self setParentViewController:[[self objectAssistantNavigationController] topViewController]];
}

- (id)movieRecordingAssistantPane
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _movieRecordingAssistantPane;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSMovieRecordingAssistantPane new];
        _movieRecordingAssistantPane = pvVar1_2;
        [pvVar1_2 setMovieRecordingPaneDelegate:self];
        pvVar1 = _movieRecordingAssistantPane;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a48af @ 001a48af, 94 bytes * /

id FUN_001a48af(HSPickMovieSourceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_importMovieObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360cc);
    self->_importMovieObjectDialogController = pvVar1;
  }
  return pvVar1;
}

*/
- (id)importMovieObjectDialogController
{
    if (_importMovieObjectDialogController == nil) {
        _importMovieObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:@"HSImportDialogControllerTypeAnimations"];
    }
    return _importMovieObjectDialogController;
    return 0;
}

- (id)actionAttributes
{
    id pvVar2;
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    pvVar2 = [self actionEvent];
    return [pvVar1_3 hyperActionOfType:[self actionType] forEvent:pvVar2];
}

- (id)actionType
{
    return [HSPlayMovieAction actionType];
}

- (void)setPickMovieSourcePaneDelegate:(id)aDelegate
{
    _pickMovieSourcePaneDelegate = aDelegate;
}

- (id)pickMovieSourcePaneDelegate
{
    return _pickMovieSourcePaneDelegate;
}

- (void)liveVideoChosen:(id)aChosen
{
    [self retain];
    [self autorelease];
    [self processLiveObject:[HSLiveObject defaultObject]];
    [self dismissPaneIfNeeded];
}

- (void)videoRecordChosen:(id)aChosen
{
    [self openMovieRecordingAssistantPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a4a7a @ 001a4a7a, 834 bytes * /

void FUN_001a4a7a(HSPickMovieSourceAssistantPane *self,SEL _cmd,id diskFileChosen)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *self_00;
  SEL op;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_importMovieObjectDialogController);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  puVar4 = cls_HSImportDialogController;
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(puVar4,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
  pvVar3 = _objc_msgSend(pvVar1,sel_dialogUserOptions);
  uVar6 = *(undefined4 *)PTR_PTR_003360f0;
  puVar4 = _objc_msgSend(pvVar3,sel_valueForKey_,uVar6);
  if (((pvVar2 == (id)0x1) &&
      (pvVar3 = _objc_msgSend(pvVar1,sel_fileName,uVar6), puVar5 = cls_HSNewMedia, pvVar3 != (id)0x0
      )) && (puVar4 == (undefined *)0x0)) {
    puVar4 = _objc_msgSend(pvVar1,sel_fileName,uVar6);
    puVar5 = _objc_msgSend(puVar5,sel_mediaWithPath_,puVar4);
    if (puVar5 == (undefined *)0x0) {
      self_00 = (undefined *)0x0;
      puVar5 = puVar4;
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSMovieObject,sel_alloc,puVar4);
      self_00 = _objc_msgSend(pvVar1,sel_initWithMedia_,puVar5);
      if (self_00 != (undefined *)0x0) {
        _objc_msgSend(self,sel_retain,puVar5);
        _objc_msgSend(self,sel_autorelease);
        puVar5 = self_00;
        _objc_msgSend(self,sel_processMovieObject_isInUse_,self_00,0);
      }
    }
    _objc_msgSend(self_00,sel_release,puVar5);
  }
  else {
    if (pvVar2 != (id)0x1) {
      return;
    }
    if (puVar4 == (undefined *)0x0) {
      return;
    }
    _objc_msgSend(self,sel_retain,uVar6);
    _objc_msgSend(self,sel_autorelease);
    puVar5 = &DAT_0037c5a4;
    pvVar1 = _objc_msgSend(puVar4,sel_implementsHyperInterface_,&DAT_0037c5a4);
    if ((((char)pvVar1 != '\0') &&
        (pvVar1 = _objc_msgSend(puVar4,sel_queryHyperInterface_,&DAT_0037c5a4), pvVar1 != (id)0x0))
       && (pvVar2 = _objc_msgSend(pvVar1,sel_hyperParent,puVar5), pvVar2 == (id)0x0)) {
      puVar4 = _objc_msgSend(pvVar1,sel_localCopyIncludingNodeUnits_,1);
    }
    pvVar1 = _objc_msgSend(puVar4,sel_implementsHyperInterface_,&DAT_0037c5f4);
    op = sel_processMovieObject_isInUse_;
    if ((char)pvVar1 == '\0') {
      puVar5 = &DAT_0037c838;
      pvVar1 = _objc_msgSend(puVar4,sel_implementsHyperInterface_,&DAT_0037c838);
      op = sel_processLiveObject_;
      if ((char)pvVar1 == '\0') goto LAB_001a4daf;
    }
    _objc_msgSend(self,op,puVar4);
    puVar5 = puVar4;
  }
LAB_001a4daf:
  _objc_msgSend(self,sel_dismissPaneIfNeeded,puVar5);
  return;
}

*/
- (void)diskFileChosen:(id)aChosen
{
    id dialog = [self importMovieObjectDialogController];
    [dialog setHyperDocument:[[self stack] document]];
    [dialog setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
    NSInteger result = [dialog runModal];
    id playableObject = [[dialog dialogUserOptions] valueForKey:@"HSImportDialogMoviesInUseOptionKeyPlayableObject"];
    if (result == NSOKButton && [dialog fileName] != nil && playableObject == nil) {
        id path = [dialog fileName];
        id media = [HSNewMedia mediaWithPath:path];
        id movieObject = nil;
        if (media != nil) {
            movieObject = [[HSMovieObject alloc] initWithMedia:media];
            if (movieObject != nil) {
                [[self retain] autorelease];
                [self processMovieObject:movieObject isInUse:NO];
            }
        }
        [movieObject release];
    } else {
        if (result != NSOKButton || playableObject == nil) {
            return;
        }
        [[self retain] autorelease];
        id object = playableObject;
        id nodeAttributes = nil;
        if ([object implementsHyperInterface:@protocol(HSNodeAttributes)]
            && (nodeAttributes = [object queryHyperInterface:@protocol(HSNodeAttributes)]) != nil
            && [nodeAttributes hyperParent] == nil) {
            object = [nodeAttributes localCopyIncludingNodeUnits:YES];
        }
        if ([object implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
            [self processMovieObject:object isInUse:NO];
        } else if ([object implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
            [self processLiveObject:object];
        }
    }
    [self dismissPaneIfNeeded];
}

- (void)cancel:(id)aCancel
{
    [self dismiss:YES];
}

- (void)dismissPaneIfNeeded
{

}

- (void)processLiveObject:(id)aObject
{
    if ([[self objectAssistantNavigationController] topViewController] == self) {
        [[self objectAssistantNavigationController] changeIdentifierForViewController:self toIdentifier:@"HSPickMovieSourcePane_RemoveIfOkIdentifier"];
    }
    [[self pickMovieSourcePaneDelegate] pickMovieSourceAssistantPane:self didChooseLiveObject:aObject]
    ;
}

- (void)processMovieObject:(id)aObject isInUse:(BOOL)aUse
{
    if ([[self objectAssistantNavigationController] topViewController] == self) {
        [[self objectAssistantNavigationController] changeIdentifierForViewController:self toIdentifier:@"HSPickMovieSourcePane_RemoveIfOkIdentifier"];
    }
    [[self pickMovieSourcePaneDelegate] pickMovieSourceAssistantPane:self didChooseMovieObject:aObject isInUse:aUse];
}

- (void)restoreApplierSettings
{

}

- (void)updateObjectWithApplier
{

}

- (id)applier
{
    return nil;
}

- (id)helpTopicKey
{
    return @"HSPlayMovie";
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSNavigationPaneSwitcherWithCancelButton new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[_diskFolderButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_recordVideoButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_showLiveVideoButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [_recordVideoButton setEnabled:[[HSSystem sharedSystem] isQTKitCapturingAvailable]];
}

- (void)dealloc
{
    int uVar2;

    uVar2 = 0;
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    if ([_movieRecordingAssistantPane movieRecordingPaneDelegate] == self) {
        uVar2 = 0;
        [_movieRecordingAssistantPane setMovieRecordingPaneDelegate:nil];
    }
    [_movieRecordingAssistantPane release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PickMovieSourcePane"];
    return self;
}

@end

