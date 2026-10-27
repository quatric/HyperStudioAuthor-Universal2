#import "HSPickSoundSourceAssistantPane.h"

@implementation HSPickSoundSourceAssistantPane

/* i386 ivar offsets: _diskFolderButton=0x78, _recordSoundButton=0x7c, _stopSoundButton=0x80, _pickSoundSourcePaneDelegate=0x84, _navigationPaneSwitcher=0x88, _importSoundObjectDialogController=0x8c, _soundRecordingAssistantPane=0x90 */

- (void)soundRecordingAssistantPane:(id)aPane didRecordSoundItem:(id)aItem
{
    [self processSoundItem:aItem];
}

- (void)openSoundRecordingAssistantPane
{
    id self_00;

    self_00 = [self soundRecordingAssistantPane];
    [self_00 setActionEvent:[self actionEvent]];
    [[self objectAssistantNavigationController] pushViewController:self_00 withIdentifier:@"HSPickSoundSourcePaneIdentifier" animate:YES replacePrevious:NO];
}

- (id)soundRecordingAssistantPane
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _soundRecordingAssistantPane;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSSoundRecordingAssistantPane alloc] init];
        _soundRecordingAssistantPane = pvVar1_3;
        [pvVar1_3 setSoundRecordingAssistantPaneDelegate:self];
        pvVar1 = _soundRecordingAssistantPane;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002211c5 @ 002211c5, 94 bytes * /

id FUN_002211c5(HSPickSoundSourceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_importSoundObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360dc);
    self->_importSoundObjectDialogController = pvVar1;
  }
  return pvVar1;
}

*/
- (id)importSoundObjectDialogController
{
    if (_importSoundObjectDialogController == nil) {
        _importSoundObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:@"HSImportDialogControllerTypeSound"];
    }
    return _importSoundObjectDialogController;
    return 0;
}

- (id)actor
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
}

- (id)actionType
{
    return [HSPlaySoundAction actionType];
}

- (void)stopSound:(id)aSound
{
    [self dismissPaneIfNeeded];
    [[self pickSoundSourcePaneDelegate] stopSound:self];
}

- (void)soundRecordChosen:(id)aChosen
{
    [self openSoundRecordingAssistantPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022131a @ 0022131a, 682 bytes * /

void FUN_0022131a(HSPickSoundSourceAssistantPane *self,SEL _cmd,id diskFileChosen)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  
  pvVar1 = _objc_msgSend(self,sel_importSoundObjectDialogController);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  self_00 = cls_HSImportDialogController;
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_runModal);
  if (pvVar3 == (id)0x1) {
    pvVar3 = _objc_msgSend(pvVar1,sel_fileName,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_fileDisplayName);
    if (pvVar3 != (id)0x0) {
      pvVar4 = _objc_msgSend(cls_HSMovie,sel_alloc,pvVar2);
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar3);
      pvVar6 = (id)0x0;
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithURL_error_,pvVar2,0);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
      if (pvVar4 != (id)0x0) {
        _objc_msgSend(self,sel_retain,pvVar2,pvVar6);
        _objc_msgSend(self,sel_autorelease);
        pvVar2 = _objc_msgSend(self,sel_stack);
        pvVar5 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00383444);
        pvVar2 = pvVar3;
        pvVar5 = _objc_msgSend(pvVar5,sel_soundMediaForPath_,pvVar3);
        if (pvVar5 == (id)0x0) {
          pvVar5 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_name_,pvVar3,pvVar1);
          pvVar2 = pvVar3;
          pvVar6 = pvVar1;
        }
        if (pvVar5 != (id)0x0) {
          pvVar1 = _objc_msgSend(cls_HSSoundItem,sel_alloc,pvVar2,pvVar6);
          pvVar2 = _objc_msgSend(pvVar5,sel_mediaUID);
          pvVar1 = _objc_msgSend(pvVar1,sel_initWithMediaUID_andApplyOptionsFromSound_,pvVar2,pvVar4
                                );
          pvVar2 = pvVar1;
          _objc_msgSend(self,sel_processSoundItem_,pvVar1);
          _objc_msgSend(pvVar1,sel_release);
          pvVar6 = pvVar4;
        }
      }
      _objc_msgSend(self,sel_dismissPaneIfNeeded,pvVar2,pvVar6);
    }
  }
  return;
}

*/
- (void)diskFileChosen:(id)aChosen
{
    id dialog = [self importSoundObjectDialogController];
    [dialog setHyperDocument:[[self stack] document]];
    [dialog setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
    if ([dialog runModal] == NSOKButton) {
        id path = [dialog fileName];
        id displayName = [dialog fileDisplayName];
        if (path != nil) {
            id movie = [[[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:nil] autorelease];
            if (movie != nil) {
                [[self retain] autorelease];
                id media = [[[self stack] queryHyperInterface:@protocol(HSStackSoundStorage)] soundMediaForPath:path];
                if (media == nil) {
                    media = [HSNewMedia mediaWithPath:path name:displayName];
                }
                if (media != nil) {
                    id soundItem = [[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:movie];
                    [self processSoundItem:soundItem];
                    [soundItem release];
                }
            }
            [self dismissPaneIfNeeded];
        }
    }
}

- (void)cancel:(id)aCancel
{
    [self dismiss:YES];
}

- (void)dismissPaneIfNeeded
{
    [[self objectAssistantNavigationController] popViewControllerAnimated:YES];
}

- (void)processSoundItem:(id)aItem
{
    [[self pickSoundSourcePaneDelegate] pickSoundSourceAssistantPane:self didChooseSoundItem:aItem];
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
    return @"HSPlaySound";
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _navigationPaneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSNavigationPaneSwitcherWithCancelButton new];
        _navigationPaneSwitcher = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _navigationPaneSwitcher;
    }
    return pvVar1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[_diskFolderButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_recordSoundButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_stopSoundButton cell] setBackgroundRenderer:[HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer]];
    [_recordSoundButton setEnabled:[[HSSystem sharedSystem] isQTKitCapturingAvailable]];
}

- (void)setPickSoundSourcePaneDelegate:(id)aDelegate
{
    _pickSoundSourcePaneDelegate = aDelegate;
}

- (id)pickSoundSourcePaneDelegate
{
    return _pickSoundSourcePaneDelegate;
}

- (void)dealloc
{
    HSPickSoundSourceAssistantPane *pHVar1_2;

    if ([_navigationPaneSwitcher delegate] == self) {
        [_navigationPaneSwitcher setDelegate:0];
    }
    [_navigationPaneSwitcher release];
    pHVar1_2 = [_soundRecordingAssistantPane soundRecordingAssistantPaneDelegate]
    ;
    if (pHVar1_2 == self) {
        [_soundRecordingAssistantPane setSoundRecordingAssistantPaneDelegate:nil];
    }
    [_soundRecordingAssistantPane release];
    [_importSoundObjectDialogController release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PickSoundSourcePane"];
    return self;
}

- (void)importSoundObjectDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != 1)
        return;
    NSString *fileName = [aDialog fileName];
    NSString *displayName = [aDialog fileDisplayName];
    if (fileName == nil)
        return;
    id movie = [[[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:fileName] error:NULL] autorelease];
    if (movie != nil) {
        [[self retain] autorelease];
        id media = [[[self stack] queryHyperInterface:@protocol(HSStackSoundStorage)] soundMediaForPath:fileName];
        if (media == nil)
            media = [HSNewMedia mediaWithPath:fileName name:displayName];
        if (media != nil) {
            id soundItem = [[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:movie];
            [self processSoundItem:soundItem];
            [soundItem release];
        }
    }
    [self dismissPaneIfNeeded];
}

@end

