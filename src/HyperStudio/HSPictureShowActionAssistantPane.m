#import "HSPictureShowActionAssistantPane.h"

@implementation HSPictureShowActionAssistantPane

/* i386 ivar offsets: _loopPictureShowButton=0x88, _leaveLastPictureOnExitButton=0x8c, _showFilenameOnPictureButton=0x90, _timeDelayField=0x94, _timeDelayStepper=0x98, _URLField=0x9c, _chooseFolderButton=0xa0 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001089c3 @ 001089c3, 136 bytes * /

void FUN_001089c3(HSPictureShowActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  if (pvVar1 != (id)0x0) {
    pvVar1 = (id)_CFURLCopyFileSystemPath(pvVar1,1);
    if (pvVar1 != (id)0x0) goto LAB_00108a28;
  }
  pvVar1 = _objc_msgSend(cls_NSString,sel_string);
LAB_00108a28:
  _objc_msgSend(self->_URLField,sel_setStringValue_,pvVar1);
  return;
}

*/
- (void)validateURLField
{
    NSURL *url = [[self actionAttributes] URL];
    NSString *path = nil;
    if (url != nil) {
        /* the original leaked the copied path; the HFS path style is kept */
        path = [(id)CFURLCopyFileSystemPath((CFURLRef)url, kCFURLHFSPathStyle) autorelease];
    }
    if (path == nil) {
        path = [NSString string];
    }
    [_URLField setStringValue:path];
}

- (void)validateUI
{
    id pcVar3;
    NSBundle *pvVar2_6;
    NSURL *pvVar1_10;

    [_loopPictureShowButton setState:[[self actionAttributes] loopPictureShow]];
    [_leaveLastPictureOnExitButton setState:[[self actionAttributes] leavesLastPictureOnExit]];
    [_showFilenameOnPictureButton setState:[[self actionAttributes] showsFilenameOnPicture]];
    [_timeDelayField setDoubleValue:[[self actionAttributes] timeDelay]];
    [_timeDelayStepper setDoubleValue:[[self actionAttributes] timeDelay]];
    pvVar2_6 = [NSBundle mainBundle];
    pvVar1_10 = [[self actionAttributes] URL];
    pcVar3 = @"Change";
    if (pvVar1_10 == nil) {
        pcVar3 = @"Choose";
    }
    [_chooseFolderButton setTitle:[[pvVar2_6 localizedStringForKey:pcVar3 value:@"" table:@"AssistantPanes"] hyperStringByAddingEllipsis]];
    [self validateURLField];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)timeDelayChanged:(id)aChanged
{
    [[self pictureShowActionAssistantPaneApplier] setTimeDelay:[aChanged floatValue]];
}

- (void)showFilenameOnPicturesChanged:(id)aChanged
{
    [[self pictureShowActionAssistantPaneApplier] setShowsFilenameOnPicture:[aChanged state]];
}

- (void)loopPictureShowChanged:(id)aChanged
{
    [[self pictureShowActionAssistantPaneApplier] setLoopPictureShow:[aChanged state]];
}

- (void)leaveLastPictureOnExitChanged:(id)aChanged
{
    [[self pictureShowActionAssistantPaneApplier] setLeavesLastPictureOnExit:[aChanged state]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00108053 @ 00108053, 512 bytes * /

void FUN_00108053(HSPictureShowActionAssistantPane *self,SEL _cmd,id chooseFolder)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  self_00 = _objc_msgSend(pvVar1,sel_retain);
  _objc_msgSend(self_00,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self_00,sel_setCanChooseFiles_,0);
  pvVar1 = (id)0x1;
  _objc_msgSend(self_00,sel_setCanChooseDirectories_,1);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_picturesFolder);
  if (pvVar2 != (id)0x0) {
    op = sel_setDirectory_;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,1);
      op = sel_setDirectoryURL_;
    }
    _objc_msgSend(self_00,op,pvVar2);
    pvVar1 = pvVar2;
  }
  pvVar2 = _objc_msgSend(self_00,sel_runModal,pvVar1);
  if (pvVar2 == (id)0x1) {
    pvVar1 = _objc_msgSend(self_00,sel_URLs,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_extraFirstObject);
    pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pvVar3 = _objc_msgSend(pvVar1,sel_path);
    pvVar3 = _objc_msgSend(pvVar3,sel_stringByDeletingLastPathComponent);
    _objc_msgSend(pvVar2,sel_setPicturesFolder_,pvVar3);
    pvVar2 = _objc_msgSend(self,sel_pictureShowActionAssistantPaneApplier);
    _objc_msgSend(pvVar2,sel_setURL_,pvVar1);
    _objc_msgSend(self,sel_validateURLField);
  }
  _objc_msgSend(self_00,sel_release,pvVar1);
  return;
}

*/
- (void)chooseFolder:(id)aFolder
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    id picturesFolder = [[HSPathsProvider sharedPathsProvider] picturesFolder];
    if (picturesFolder != nil) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:picturesFolder isDirectory:YES]];
    }
    if ([panel runModal] == NSOKButton) {
        NSURL *url = [[panel URLs] extraFirstObject];
        [[HSPathsProvider sharedPathsProvider] setPicturesFolder:[[url path] stringByDeletingLastPathComponent]];
        [[self pictureShowActionAssistantPaneApplier] setURL:url];
        [self validateURLField];
    }
    [panel release];
}

- (id)initialKeyView
{
    return _loopPictureShowButton;
}

- (id)helpTopicKey
{
    return @"HSPictureShow";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSPictureShowActionAttributes);
}

- (id)actionType
{
    return [HSPictureShowAction actionType];
}

- (id)actionAttributes
{
    return [[self pictureShowActionAssistantPaneApplier] pictureShowActionAttributes];
}

- (id)pictureShowActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSPictureShowActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"PictureShowAssistantPane"];
    return self;
}

@end

@implementation HSPictureShowActionAssistantPaneApplier

/* i386 ivar offsets: _initialLoopPictureShow=0x30, _initialLeavesLastPictureOnExit=0x31, _initialShowsFilenameOnPicture=0x32, _initialTimeDelay=0x34, _initialUrl=0x3c, _loopPictureShow=0x40, _leavesLastPictureOnExit=0x41, _showsFilenameOnPicture=0x42, _timeDelay=0x44, _url=0x4c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001083ea @ 001083ea, 266 bytes * /

BOOL FUN_001083ea(HSPictureShowActionAssistantPaneApplier *self,SEL _cmd)

{
  double dVar1;
  double dVar2;
  id pvVar3;
  bool bVar4;
  double dVar5;
  double dVar6;
  HSPictureShowActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00350c90;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if (((((char)pvVar3 != '\0') && (self->_initialLoopPictureShow == self->_loopPictureShow)) &&
      (self->_initialLeavesLastPictureOnExit == self->_leavesLastPictureOnExit)) &&
     (self->_initialShowsFilenameOnPicture == self->_showsFilenameOnPicture)) {
    dVar1 = self->_initialTimeDelay;
    dVar2 = self->_timeDelay;
    if ((dVar1 != 0.0) || (NAN(dVar1))) {
      dVar5 = ABS(dVar1);
    }
    else {
      dVar5 = 1.0;
    }
    if ((dVar2 != 0.0) || (NAN(dVar2))) {
      dVar6 = ABS(dVar2);
    }
    else {
      dVar6 = 1.0;
    }
    if (dVar6 <= dVar5) {
      dVar6 = dVar5;
    }
    if (ABS(dVar1 - dVar2) <= dVar6 * 1e-05) {
      bVar4 = true;
      goto LAB_001084b2;
    }
  }
  bVar4 = false;
LAB_001084b2:
  if ((self->_initialUrl != (id)0x0) || (self->_url != (id)0x0)) {
    if (bVar4 == false) {
      bVar4 = false;
    }
    else {
      pvVar3 = _objc_msgSend(self->_initialUrl,sel_isEqual_,self->_url);
      bVar4 = (char)pvVar3 != '\0';
    }
  }
  return bVar4;
}

*/
- (BOOL)areSettingsEqual
{
    double a = _initialTimeDelay;
    double b = _timeDelay;
    double scaleA = (a != 0.0 || a != a) ? fabs(a) : 1.0;
    double scaleB = (b != 0.0 || b != b) ? fabs(b) : 1.0;
    if (scaleB <= scaleA) {
        scaleB = scaleA;
    }
    BOOL equal = NO;
    if ([super areSettingsEqual] && _initialLoopPictureShow == _loopPictureShow && _initialLeavesLastPictureOnExit == _leavesLastPictureOnExit
        && _initialShowsFilenameOnPicture == _showsFilenameOnPicture && fabs(a - b) <= scaleB * 1e-05) {
        equal = YES;
    }
    if (_initialUrl != nil || _url != nil) {
        equal = equal ? [_initialUrl isEqual:_url] : NO;
    }
    return equal;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [super makeInitialEqualToCurrent];
    _loopPictureShow = _initialLoopPictureShow;
    _leavesLastPictureOnExit = _initialLeavesLastPictureOnExit;
    _showsFilenameOnPicture = _initialShowsFilenameOnPicture;
    _timeDelay = _initialTimeDelay;
    [_url release];
    _url = [_initialUrl retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialLoopPictureShow = _loopPictureShow;
    _initialLeavesLastPictureOnExit = _leavesLastPictureOnExit;
    _initialShowsFilenameOnPicture = _showsFilenameOnPicture;
    _initialTimeDelay = _timeDelay;
    [_initialUrl release];
    _initialUrl = [_url retain];
}

- (void)setInitialSettingsToObject
{
    [[self pictureShowActionAttributes] setLoopPictureShow:_initialLoopPictureShow];
    [[self pictureShowActionAttributes] setLeavesLastPictureOnExit:_initialLeavesLastPictureOnExit];
    [[self pictureShowActionAttributes] setShowsFilenameOnPicture:_initialShowsFilenameOnPicture];
    [[self pictureShowActionAttributes] setTimeDelay:_initialTimeDelay];
    [[self pictureShowActionAttributes] setURL:_initialUrl];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self pictureShowActionAttributes] setLoopPictureShow:_loopPictureShow];
    [[self pictureShowActionAttributes] setLeavesLastPictureOnExit:_leavesLastPictureOnExit];
    [[self pictureShowActionAttributes] setShowsFilenameOnPicture:_showsFilenameOnPicture];
    [[self pictureShowActionAttributes] setTimeDelay:_timeDelay];
    [[self pictureShowActionAttributes] setURL:_url];
}

- (void)setURL:(id)aURL
{
    if (![_url isEqualTo:aURL]) {
        [_url release];
        _url = [aURL retain];
        [self disableUndo];
        [[self pictureShowActionAttributes] setURL:_url];
        [self enableUndo];
    }
}

- (void)setTimeDelay:(double)aDelay
{
    if (_timeDelay != aDelay) {
        _timeDelay = aDelay;
        [self disableUndo];
        [[self pictureShowActionAttributes] setTimeDelay:_timeDelay];
        [self enableUndo];
    }
}

- (void)setShowsFilenameOnPicture:(BOOL)aPicture
{
    if (_showsFilenameOnPicture != aPicture) {
        _showsFilenameOnPicture = aPicture;
        [self disableUndo];
        [[self pictureShowActionAttributes] setShowsFilenameOnPicture:_showsFilenameOnPicture];
        [self enableUndo];
    }
}

- (void)setLeavesLastPictureOnExit:(BOOL)aExit
{
    if (_leavesLastPictureOnExit != aExit) {
        _leavesLastPictureOnExit = aExit;
        [self disableUndo];
        [[self pictureShowActionAttributes] setLeavesLastPictureOnExit:_leavesLastPictureOnExit];
        [self enableUndo];
    }
}

- (void)setLoopPictureShow:(BOOL)aShow
{
    if (_loopPictureShow != aShow) {
        _loopPictureShow = aShow;
        [self disableUndo];
        [[self pictureShowActionAttributes] setLoopPictureShow:_loopPictureShow];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    double dVar2;
    BOOL pvVar1_2;
    BOOL pvVar1_4;
    BOOL pvVar1_6;

    pvVar1_2 = [[self pictureShowActionAttributes] loopPictureShow];
    _initialLoopPictureShow = (BOOL)pvVar1_2;
    _loopPictureShow = (BOOL)pvVar1_2;
    pvVar1_4 = [[self pictureShowActionAttributes] leavesLastPictureOnExit];
    _initialLeavesLastPictureOnExit = (BOOL)pvVar1_4;
    _leavesLastPictureOnExit = (BOOL)pvVar1_4;
    pvVar1_6 = [[self pictureShowActionAttributes] showsFilenameOnPicture];
    _initialShowsFilenameOnPicture = (BOOL)pvVar1_6;
    _showsFilenameOnPicture = (BOOL)pvVar1_6;
    dVar2 = [[self pictureShowActionAttributes] timeDelay];
    _initialTimeDelay = dVar2;
    _timeDelay = dVar2;
    _url = [[[self pictureShowActionAttributes] URL] retain];
    _initialUrl = [[[self pictureShowActionAttributes] URL] retain];
}

- (id)pictureShowActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSPictureShowActionAttributes)];
}

- (void)dealloc
{
    [_url release];
    [_initialUrl release];
    [super dealloc];
}

@end

