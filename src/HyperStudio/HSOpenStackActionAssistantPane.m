#import "HSOpenStackActionAssistantPane.h"

@implementation HSOpenStackActionAssistantPane

/* i386 ivar offsets: _stackNameField=0x78, _containerView=0x7c, _placeholderView=0x80, _cardPreviewContentView=0x84, _stackDropArea=0x88, _cardPreviewView=0x8c, _contentView=0x90, _paneMultiApplier=0x94, _previewDocument=0x98, _cachedPath=0x9c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001063a9 @ 001063a9, 637 bytes * /

id FUN_001063a9(HSOpenStackActionAssistantPane *self,SEL _cmd,id thumbnailOfCard,NSSize ofSize)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  undefined8 in_stack_ffffff8c;
  undefined8 uVar5;
  float local_44;
  float local_40;
  
  uVar5 = CONCAT44((int)((ulonglong)in_stack_ffffff8c >> 0x20),&DAT_0036fbd8);
  pvVar1 = _objc_msgSend(thumbnailOfCard,sel_queryHyperInterface_,&DAT_0036fbd8);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  local_44 = ofSize.height + -20.0;
  local_40 = ofSize.width + -20.0;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  fVar4 = (float)pvVar1 / extraout_EDX;
  if (fVar4 <= local_40 / local_44) {
    local_40 = fVar4 * local_44;
  }
  else {
    local_44 = local_40 / fVar4;
  }
  pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc,uVar5);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithSize_,local_40,local_44);
  _objc_msgSend(pvVar2,sel_setFlipped_,1);
  _objc_msgSend(pvVar2,sel_lockFocus);
  pvVar3 = _objc_msgSend(cls_NSAffineTransform,sel_transformWithHyperCGAffineTransform_,
                         (ulonglong)(uint)(local_40 / (float)pvVar1),
                         (ulonglong)(uint)(local_44 / extraout_EDX) << 0x20,0);
  _objc_msgSend(pvVar3,sel_concat);
  pvVar3 = _objc_msgSend(thumbnailOfCard,sel_queryHyperInterface_,&DAT_0036fbec);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryRenderer);
  pvVar1 = _objc_msgSend(cls_HSRegion,sel_regionWithRect_,0,CONCAT44(extraout_EDX,pvVar1));
  _objc_msgSend(pvVar3,sel_drawRegion_withDelegate_,pvVar1,0);
  _objc_msgSend(pvVar2,sel_unlockFocus);
  pvVar1 = _objc_msgSend(pvVar2,sel_autorelease);
  return pvVar1;
}

*/
- (id)thumbnailOfCard:(id)aCard ofSize:(NSSize)aSize
{
    id<HSUserObjectSupport> support = [aCard queryHyperInterface:@protocol(HSUserObjectSupport)];
    NSSize cardSize = [[support stack] hyperCardSize];
    float width = aSize.width - 20.0f;
    float height = aSize.height - 20.0f;
    float ratio = cardSize.width / cardSize.height;
    if (ratio <= width / height) {
        width = ratio * height;
    } else {
        height = width / ratio;
    }
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [image setFlipped:YES];
    [image lockFocus];
    CGAffineTransform scale = CGAffineTransformMake(width / cardSize.width, 0.0f, 0.0f, height / cardSize.height, 0.0f, 0.0f);
    [[NSAffineTransform transformWithHyperCGAffineTransform:scale] concat];
    id renderer = [[aCard queryHyperInterface:@protocol(HSVisualization)] queryRenderer];
    [renderer drawRegion:[HSRegion regionWithRect:NSMakeRect(0.0f, 0.0f, cardSize.width, cardSize.height)] withDelegate:nil];
    [image unlockFocus];
    return [image autorelease];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00106bdd @ 00106bdd, 262 bytes * /

void FUN_00106bdd(HSOpenStackActionAssistantPane *self,SEL _cmd,id mountContentView)

{
  id pvVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  if (self->_contentView != mountContentView) {
    _objc_msgSend(self->_contentView,sel_removeFromSuperviewWithoutNeedingDisplay);
    _objc_msgSend(self->_contentView,sel_release);
    pvVar1 = _objc_msgSend(mountContentView,sel_retain);
    self->_contentView = pvVar1;
    _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = self->_contentView;
    _objc_msgSend_stret(local_24,self->_containerView,sel_frame);
    _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
    _objc_msgSend(self->_containerView,sel_addSubview_,self->_contentView);
  }
  return;
}

*/
- (void)mountContentView:(id)aView
{
    if (_contentView != aView) {
        [_contentView removeFromSuperviewWithoutNeedingDisplay];
        [_contentView release];
        _contentView = [aView retain];
        [_contentView setFrameOrigin:NSZeroPoint];
        [_contentView setFrameSize:[_containerView frame].size];
        [_containerView addSubview:_contentView];
    }
}

- (void)setPreviewDocument:(id)aDocument
{
    if (_previewDocument != aDocument) {
        [_previewDocument release];
        _previewDocument = [aDocument retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00106145 @ 00106145, 531 bytes * /

id FUN_00106145(HSOpenStackActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  undefined4 uVar6;
  
  if (self->_previewDocument != (id)0x0) goto LAB_00106347;
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  if (pvVar1 == (id)0x0) goto LAB_00106347;
  pvVar3 = self->_cachedPath;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar3);
  if ((char)pvVar2 != '\0') goto LAB_00106347;
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_fileExistsAtPath_,pvVar1);
  if ((char)pvVar3 == '\0') goto LAB_00106347;
  _objc_msgSend(self,sel_setCachedPath_,pvVar1);
  pvVar3 = _objc_msgSend(cls_HSPlayerDocument,sel_new);
  _objc_msgSend(pvVar3,sel_setSuppressAlerts_,1);
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar1 = _objc_msgSend(pvVar2,sel_hyperFileTypeAtPath_,pvVar1);
  pcVar5 = &cfstr__Stak_;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr__Stak_);
  if ((char)pvVar2 == '\0') {
    pcVar5 = &cfstr_stk;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_stk);
    if ((char)pvVar1 != '\0') goto LAB_001062a1;
    pcVar4 = &cfstr_HSDocumentType;
  }
  else {
LAB_001062a1:
    pcVar4 = &cfstr_HSNativeDocumentType;
  }
  pvVar1 = _objc_msgSend(self,sel_actionAttributes,pcVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  uVar6 = 0;
  pvVar2 = _objc_msgSend(pvVar3,sel_readFromURL_ofType_error_,pvVar1,pcVar4,0);
  if ((char)pvVar2 != '\0') {
    pvVar1 = pvVar3;
    _objc_msgSend(self,sel_setPreviewDocument_,pvVar3,pcVar4,uVar6);
  }
  _objc_msgSend(pvVar3,sel_release,pvVar1,pcVar4,uVar6);
LAB_00106347:
  return self->_previewDocument;
}

*/
- (id)previewDocument
{
    if (_previewDocument == nil) {
        NSString *path = [[[self actionAttributes] URL] path];
        if (path != nil && ![path isEqualToString:_cachedPath] && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [self setCachedPath:path];
            HSPlayerDocument *document = [HSPlayerDocument new];
            [document setSuppressAlerts:YES];
            NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
            NSString *documentType;
            if ([fileType isEqualToString:@"'Stak'"] || [fileType isEqualToString:@"stk"]) {
                documentType = @"HSNativeDocumentType";
            } else {
                documentType = @"HSDocumentType";
            }
            if ([document readFromURL:[[self actionAttributes] URL] ofType:documentType error:NULL]) {
                [self setPreviewDocument:document];
            }
            [document release];
        }
    }
    return _previewDocument;
    return 0;
}

- (void)setCachedPath:(id)aPath
{
    [_cachedPath release];
    _cachedPath = [aPath retain];
}

- (id)objectAssistantForNavigationPaneSwitcher:(id)aSwitcher
{
    return [self assistant];
}

- (BOOL)canGoToNextPane
{
    BOOL bVar2;

    if ([[self actionAttributes] URL] == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [[self previewDocument] stack] != nil;
    }
    return bVar2;
}

- (id)nextPaneForObjectAssistant:(id)aAssistant
{
    id pvVar1;
    id pvVar2;
    id pvVar1_3;

    pvVar1 = [HSTransitionsAssistantPane alloc];
    pvVar2 = [self paneMultiApplier];
    pvVar1_3 = [[pvVar1 initWithActionType:[self actionType] paneMultiApplier:pvVar2] autorelease];
    [pvVar1_3 setActionEvent:[self actionEvent]];
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00105d1e @ 00105d1e, 654 bytes * /

void FUN_00105d1e(HSOpenStackActionAssistantPane *self,SEL _cmd,id chooseStack)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  id pvVar3;
  
  _objc_msgSend(self,sel_setCachedPath_,0);
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  _objc_msgSend(pvVar1,sel_setAllowsMultipleSelection_,0);
  pvVar3 = (id)0x0;
  _objc_msgSend(pvVar1,sel_setCanChooseDirectories_,0);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperStudioDocumentsFolder);
  if (pvVar2 != (id)0x0) {
    op = sel_setDirectory_;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,1);
      op = sel_setDirectoryURL_;
    }
    _objc_msgSend(pvVar1,op,pvVar2);
    pvVar3 = pvVar2;
  }
  pvVar3 = _objc_msgSend(cls_HSApplicationController,sel_sharedDocumentController,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_readableFileExtensions);
  pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithArray_,pvVar3);
  _objc_msgSend(pvVar3,sel_removeObject_,&cfstr_key);
  pvVar2 = _objc_msgSend(pvVar1,sel_runModalForTypes_,pvVar3);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(pvVar1,sel_URLs,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_URLs,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
      pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
      pvVar2 = _objc_msgSend(pvVar3,sel_path);
      pvVar2 = _objc_msgSend(pvVar2,sel_stringByDeletingLastPathComponent);
      _objc_msgSend(pvVar1,sel_setHyperStudioDocumentsFolder_,pvVar2);
      pvVar1 = _objc_msgSend(self,sel_openStackActionAssistantApplier);
      _objc_msgSend(pvVar1,sel_setURL_,pvVar3);
      _objc_msgSend(self,sel_setPreviewDocument_,0);
      _objc_msgSend(self,sel_validateUserInterface);
    }
  }
  return;
}

*/
- (void)chooseStack:(id)aStack
{
    [self setCachedPath:nil];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder];
    if (folder != nil) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    }
    NSMutableArray *types = [NSMutableArray arrayWithArray:[[HSApplicationController sharedDocumentController] readableFileExtensions]];
    [types removeObject:@"key"];
    [panel setAllowedFileTypes:types];
    if ([panel runModal] == NSModalResponseOK) {
        if ([[panel URLs] count] != 0) {
            NSURL *url = [[panel URLs] objectAtIndex:0];
            [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[url path] stringByDeletingLastPathComponent]];
            [[self openStackActionAssistantApplier] setURL:url];
            [self setPreviewDocument:nil];
            [self validateUserInterface];
        }
    }
}

- (id)helpTopicKey
{
    return @"HSAnotherStack";
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self navigationPaneSwitcher] setApplier:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[self navigationPaneSwitcher] setApplier:[self applier]];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00106e46 @ 00106e46, 764 bytes * /

void FUN_00106e46(HSOpenStackActionAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  undefined4 *puVar3;
  undefined1 local_24 [20];
  
  puVar3 = (undefined4 *)&stack0xffffffb4;
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  _objc_msgSend(pvVar1,sel_validateURL);
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  pvVar2 = _objc_msgSend(pvVar1,sel_path);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_previewDocument);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    if (pvVar2 != (id)0x0) {
      pvVar2 = self->_stackNameField;
      self_01 = _objc_msgSend(pvVar1,sel_path);
      _objc_msgSend(self_01,sel_lastPathComponent);
      _objc_msgSend(pvVar2,sel_setStringValue_);
      pvVar2 = _objc_msgSend(self,sel_previewDocument);
      pvVar2 = _objc_msgSend(pvVar2,sel_stack);
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperChildren);
      _objc_msgSend(pvVar2,sel_extraFirstObject);
      self_00 = cls_HSCardBorderRenderer;
      pvVar2 = self->_cardPreviewView;
      _objc_msgSend_stret(local_24,pvVar2,sel_frame);
      puVar3 = (undefined4 *)&stack0xffffffb0;
      _objc_msgSend(self,sel_thumbnailOfCard_ofSize_);
      _objc_msgSend(self_00,sel_borderedThumbnailWithCardThumbnail_);
      _objc_msgSend(pvVar2,sel_setImage_);
      _objc_msgSend(self,sel_mountContentView_);
      pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
      _objc_msgSend(pvVar1,sel_path);
      _objc_msgSend(pvVar2,sel_iconForFile_);
      goto LAB_0010710e;
    }
  }
  pvVar1 = self->_stackNameField;
  _objc_msgSend(cls_NSString,sel_string);
  _objc_msgSend(pvVar1,sel_setStringValue_);
  _objc_msgSend(self,sel_mountContentView_);
LAB_0010710e:
  puVar3[-1] = 0x107113;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_navigationPaneSwitcher;
  *puVar3 = self;
  puVar3[-1] = 0x107128;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_validateUserInterface;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x10713a;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)validateUserInterface
{
    [[self actionAttributes] validateURL];
    NSURL *url = [[self actionAttributes] URL];
    if ([url path] != nil && [[self previewDocument] stack] != nil) {
        [_stackNameField setStringValue:[[url path] lastPathComponent]];
        id card = [[[[[self previewDocument] stack] queryHyperInterface:@protocol(HSNodeAttributes)] hyperChildren] extraFirstObject];
        [_cardPreviewView setImage:[HSCardBorderRenderer borderedThumbnailWithCardThumbnail:[self thumbnailOfCard:card ofSize:[_cardPreviewView frame].size]]];
        [self mountContentView:_cardPreviewContentView];
        [_stackDropArea setImage:[[NSWorkspace sharedWorkspace] iconForFile:[url path]]];
    } else {
        [_stackNameField setStringValue:[NSString string]];
        [self mountContentView:_placeholderView];
        [_stackDropArea setImage:nil];
    }
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_stackDropArea setDelegate:self];
    [_stackDropArea registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType, NSFilenamesPboardType, nil]];
    [_containerView setImage:[NSImage imageNamed:@"Background_Medium"]];
}

- (id)actionAttributes
{
    return [[self openStackActionAssistantApplier] openStackActionAttributes];
}

- (id)actionType
{
    return [HSOpenStackAction actionType];
}

- (id)openStackActionAssistantApplier
{
    [[self paneMultiApplier] addApplier:[self applier]];
    return [super applier];
}

- (Class)applierClass
{
    return [HSOpenStackActionAssistantApplier class];
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _paneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSActionSetupPaneSwitcher alloc] initWithAssistantSettingsApplier:nil windowNibName:@"ActionPaneSwitcher"];
        _paneSwitcher = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        pvVar1 = _paneSwitcher;
    }
    return pvVar1;
}

- (id)paneMultiApplier
{
    HSAssistantPaneMultiApplier *pHVar3;

    pHVar3 = _paneMultiApplier;
    if (pHVar3 == nil) {
        if ([[self assistant] object] == nil) {
            pHVar3 = _paneMultiApplier;
        }
        else {
            pHVar3 = [[HSAssistantPaneMultiApplier alloc] initWithObject:[[self assistant] object]];
            _paneMultiApplier = pHVar3;
        }
    }
    return pHVar3;
}

- (void)dealloc
{
    [_contentView release];
    [_paneMultiApplier release];
    [_previewDocument close];
    [_previewDocument release];
    [_cachedPath release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"OpenStackAssistantPane"];
    return self;
}

- (BOOL)shouldRewindToPreviousHubPane
{
    return [[self actionAttributes] shouldOpenInSeparateWindow];
}

- (void)toggleOpenInSeparateWindow:(id)aSender
{
    [[self openStackActionAssistantApplier] setShouldOpenInSeparateWindow:[aSender state] == NSControlStateValueOn];
    [[self navigationPaneSwitcher] validateUserInterface];
}

@end

@implementation HSOpenStackActionAssistantApplier

/* i386 ivar offsets: _initialURL=0x30, _URL=0x34 */

- (void)setURL:(id)aURL
{
    if (![_URL isEqual:aURL]) {
        [_URL release];
        _URL = [aURL retain];
        [self disableUndo];
        [[self openStackActionAttributes] setURL:_URL];
        [self enableUndo];
    }
}

- (BOOL)areSettingsEqual
{
    char cVar1;
    BOOL pvVar2;

    pvVar2 = [super areSettingsEqual];
    cVar1 = pvVar2;
    if ((_URL != nil) || (_initialURL != nil)) {
        if (cVar1 == NO) {
            return NO;
        }
        pvVar2 = [_URL isEqual:_initialURL];
        cVar1 = pvVar2;
    }
    return cVar1 != NO;
}

- (void)makeCurrentEqualToInitial
{
    [_URL release];
    _URL = [_initialURL retain];
    [super makeCurrentEqualToInitial];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialURL release];
    _initialURL = [_URL retain];
}

- (void)setInitialSettingsToObject
{
    [[self openStackActionAttributes] setURL:_initialURL];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self openStackActionAttributes] setURL:_URL];
}

- (void)setUpInitialSettings
{
    id pvVar1_3;

    pvVar1_3 = [[[self openStackActionAttributes] URL] retain];
    _initialURL = pvVar1_3;
    _URL = [pvVar1_3 retain];
}

- (id)openStackActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSOpenStackActionAttributes)];
}

- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen
{
    if (_shouldOpenInSeparateWindow != aOpen) {
        _shouldOpenInSeparateWindow = aOpen;
        [[self openStackActionAttributes] setShouldOpenInSeparateWindow:aOpen];
    }
}

@end

@implementation HSOpenStackActionAssistantPane (HSDropImageViewDelegate)

/* --- i386 decompilation (Ghidra) ---
/* FUN_001067ba @ 001067ba, 481 bytes * /

void FUN_001067ba(HSOpenStackActionAssistantPane *self,SEL _cmd,id hyperImageView,
                 id didAcceptedDropWithDraggingInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(didAcceptedDropWithDraggingInfo,sel_draggingPasteboard);
  puVar4 = PTR_00336414;
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336414);
  pvVar2 = _objc_msgSend(pvVar1,sel_availableTypeFromArray_,pvVar2);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336418);
    pvVar3 = _objc_msgSend(pvVar1,sel_availableTypeFromArray_,pvVar2);
    puVar4 = cls_NSURL;
    op = sel_URLFromPasteboard_;
    if (pvVar3 != (id)0x0) goto LAB_001068fb;
  }
  else {
    pvVar2 = *(id *)puVar4;
    pvVar1 = _objc_msgSend(pvVar1,sel_propertyListForType_,pvVar2);
    pvVar3 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar3 == (id)0x1) {
      puVar4 = _objc_msgSend(cls_NSURL,sel_alloc,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_lastObject);
      op = sel_initFileURLWithPath_;
LAB_001068fb:
      pvVar2 = _objc_msgSend(puVar4,op,pvVar1);
      goto LAB_00106900;
    }
  }
  pvVar1 = pvVar2;
  pvVar2 = (id)0x0;
LAB_00106900:
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar1);
  pvVar3 = _objc_msgSend(pvVar2,sel_path);
  pvVar3 = _objc_msgSend(pvVar3,sel_stringByDeletingLastPathComponent);
  _objc_msgSend(pvVar1,sel_setHyperStudioDocumentsFolder_,pvVar3);
  pvVar1 = _objc_msgSend(self,sel_openStackActionAssistantApplier);
  _objc_msgSend(pvVar1,sel_setURL_,pvVar2);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)hyperImageView:(id)aView didAcceptedDropWithDraggingInfo:(id)aInfo
{
    NSPasteboard *pasteboard = [aInfo draggingPasteboard];
    NSURL *url = nil;
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]] != nil) {
        NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
        if ([files count] == 1) {
            url = [[NSURL alloc] initFileURLWithPath:[files lastObject]];
        }
    } else if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSURLPboardType]] != nil) {
        url = [NSURL URLFromPasteboard:pasteboard];
    }
    [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[url path] stringByDeletingLastPathComponent]];
    [[self openStackActionAssistantApplier] setURL:url];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00106626 @ 00106626, 404 bytes * /

uint FUN_00106626(HSOpenStackActionAssistantPane *self,SEL _cmd,id draggingEntered,
                 id inHyperImageView)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  SEL op;
  
  pvVar2 = _objc_msgSend(draggingEntered,sel_draggingPasteboard);
  puVar1 = PTR_00336414;
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336414);
  pvVar3 = _objc_msgSend(pvVar2,sel_availableTypeFromArray_,pvVar3);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336418);
    pvVar3 = _objc_msgSend(pvVar2,sel_availableTypeFromArray_,pvVar3);
    if (pvVar3 == (id)0x0) {
      return 0;
    }
    self_00 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,pvVar2);
    op = sel_path;
    pvVar3 = pvVar2;
  }
  else {
    pvVar3 = *(id *)puVar1;
    self_00 = _objc_msgSend(pvVar2,sel_propertyListForType_,pvVar3);
    pvVar2 = _objc_msgSend(self_00,sel_count);
    op = sel_lastObject;
    if (pvVar2 != (id)0x1) {
      return 0;
    }
  }
  pvVar2 = _objc_msgSend(self_00,op,pvVar3);
  if (pvVar2 == (id)0x0) {
    return 0;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_pathExtension,pvVar3);
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_stack);
  if ((char)pvVar3 != '\0') {
    return 2;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_stk);
  return (uint)((char)pvVar2 != '\0') * 2;
}

*/
- (NSUInteger)draggingEntered:(id)aEntered inHyperImageView:(id)aView
{
    NSPasteboard *pasteboard = [aEntered draggingPasteboard];
    NSString *path;
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]] != nil) {
        NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
        if ([files count] != 1) {
            return 0;
        }
        path = [files lastObject];
    } else {
        if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSURLPboardType]] == nil) {
            return 0;
        }
        path = [[NSURL URLFromPasteboard:pasteboard] path];
    }
    if (path == nil) {
        return 0;
    }
    NSString *extension = [path pathExtension];
    if ([extension isEqualToString:@"stack"]) {
        return 2;
    }
    return [extension isEqualToString:@"stk"] ? 2 : 0;
    return 0;
}

@end

