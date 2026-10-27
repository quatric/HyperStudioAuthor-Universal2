#import "HSImportDialogGraphicsPaneViewController.h"

static BOOL HSGraphicsPaneFloatsAreEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f;
    float mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}

// Layout matrix tags map to card preview layout options.
static NSInteger HSGraphicsPaneLayoutOptionForTag(NSInteger aTag)
{
    switch (aTag) {
    case 0: return 1;
    case 1: return 2;
    case 2: return 3;
    case 3: return 4;
    case 4: return 5;
    case 5: return 0;
    default: return -1;
    }
}

static void HSGraphicsPaneReleaseProviderData(void *aInfo, const void *aData, size_t aSize)
{
    if (aInfo != NULL) {
        CFRelease(aInfo);
    }
}

@implementation HSImportDialogGraphicsPaneViewController

/* i386 ivar offsets: _paneView=0x1c, _paneAccessoryView=0x20, _historyNavigationControl=0x24, _itemsFilterPopUp=0x28, _searchField=0x2c, _browseTableView=0x30, _imageGrid=0x34, _cardPreviewBackground=0x38, _cardPreview=0x3c, _objectTypeSeparator=0x40, _objectTypeLabelField=0x44, _thumbnailSizeSlider=0x48, _itemsCountTextField=0x4c, _layoutOptionsView=0x50, _backgroundOptionsView=0x54, _backgroundOptionsMatrix=0x58, _objectOptionsView=0x5c, _objectOptionsMatrix=0x60, _getAnotherPictureOptionsView=0x64, _getAnotherPictureOptionsMatrix=0x68, _runCropImageButton=0x6c, _captureImageButton=0x70, _filterString=0x74, _defaultObjectLayoutTag=0x78, _userSelectedObjectLayoutTag=0x7c, _defaultBackgroundLayoutTag=0x80, _disableCropImage=0x84, _wasCropped=0x85, _tempObjectLayoutTagChange=0x86, _croppedImage=0x88, _cropPaths=0x8c, _croppedImageSourceInfo=0x90, _storedGridSelection=0x94 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b0617 @ 001b0617, 444 bytes * /

void FUN_001b0617(HSImportDialogGraphicsPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  undefined8 in_stack_ffffff9c;
  undefined4 uVar4;
  undefined8 uVar3;
  float local_40;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined8 local_1c;
  undefined8 local_14;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_paneHyperDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  uVar3 = CONCAT44(uVar4,&DAT_0037da44);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037da44);
  if (pvVar1 == (id)0x0) {
    local_40 = 480.0;
    pvVar1 = (id)0x44200000;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize,uVar3);
    local_40 = extraout_EDX;
  }
  _objc_msgSend_stret(&local_1c,self->_cardPreviewBackground,sel_bounds);
  _NSInsetRect(&local_2c,local_1c,local_14,0x41100000,0x41100000);
  if (local_24 / local_20 <= (float)pvVar1 / local_40) {
    fVar2 = local_24 / (float)pvVar1;
  }
  else {
    fVar2 = local_20 / local_40;
  }
  _objc_msgSend(self->_cardPreview,sel_setFrame_,
                CONCAT44((local_20 - fVar2 * local_40) * 0.5 + local_28,
                         (local_24 - (float)pvVar1 * fVar2) * 0.5 + local_2c),
                CONCAT44(fVar2 * local_40,(float)pvVar1 * fVar2));
  _objc_msgSend(self->_cardPreview,sel_setBoundsSize_,pvVar1,local_40);
  return;
}

*/
- (void)updateCardPreviewSize
{
    id stack = [[[self paneHyperDocument] stack] queryHyperInterface:@protocol(HSStackAttributes)];
    NSSize cardSize = NSMakeSize(640.0f, 480.0f);
    NSRect bounds;
    float scale;
    if (stack != nil) {
        cardSize = [stack hyperCardSize];
    }
    bounds = NSInsetRect([_cardPreviewBackground bounds], 9.0f, 9.0f);
    if (bounds.size.width / bounds.size.height <= cardSize.width / cardSize.height) {
        scale = bounds.size.width / cardSize.width;
    }
    else {
        scale = bounds.size.height / cardSize.height;
    }
    [_cardPreview setFrame:NSMakeRect((bounds.size.width - cardSize.width * scale) * 0.5f + bounds.origin.x, (bounds.size.height - scale * cardSize.height) * 0.5f + bounds.origin.y, cardSize.width * scale, scale * cardSize.height)];
    [_cardPreview setBoundsSize:cardSize];
}

- (void)updateCardPreviewForLayoutOption:(NSInteger)aOption
{
    [_cardPreview setImageScaling:aOption];
    [_cardPreview setNeedsDisplay:YES];
}

- (void)invalidateSearch
{
    [_searchField setStringValue:@""];
    [_filterString release];
    _filterString = nil;
    [self invalidateMediaPaths];
}

- (void)setupDisableCropImage:(id)aImage
{
    _disableCropImage = (BOOL)[aImage boolValue];
}

- (void)setupDefaultBackgroundLayout:(id)aLayout
{
    int iVar2;

    if (aLayout != nil) {
        switch([aLayout intValue]) {
            case 0x2:
            iVar2 = 1;
            break;
            case 0x3:
            iVar2 = 2;
            break;
            case 0x4:
            iVar2 = 3;
            break;
            case 0x5:
            iVar2 = 4;
            break;
            default:
            iVar2 = 0;
        }
        _defaultBackgroundLayoutTag = iVar2;
    }
}

- (void)setupDefaultObjectLayout:(id)aLayout
{
    int iVar2;

    if (aLayout != nil) {
        switch([aLayout intValue]) {
            case 0x2:
            iVar2 = 1;
            break;
            case 0x3:
            iVar2 = 2;
            break;
            case 0x4:
            iVar2 = 3;
            break;
            case 0x5:
            iVar2 = 4;
            break;
            default:
            iVar2 = 0;
        }
        _defaultObjectLayoutTag = iVar2;
    }
}

- (id)optionsKeyToProcessingSelectorMap
{
    NSValue *pvVar1;
    NSValue *pvVar2;

    pvVar1 = [NSValue valueWithPointer:@selector(setupDisableCropImage:)];
    pvVar2 = [NSValue valueWithPointer:@selector(setupDefaultBackgroundLayout:)];
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:@selector(setupDefaultObjectLayout:)], @"HSImportDialogGraphicsObjectLayout", pvVar2, @"HSImportDialogGraphicsBackgroundLayout", pvVar1, @"HSImportDialogGraphicsDisableCropImageKey", nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b07d3 @ 001b07d3, 237 bytes * /

BOOL FUN_001b07d3(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,
                 id mediaPathConformsToFilter)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  HSImportDialogGraphicsPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogBasePaneViewContro_003535a0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_mediaPathConformsToFilter_,mediaPathConformsToFilter);
  cVar3 = (char)pvVar1;
  if (cVar3 != '\0') {
    pvVar1 = _objc_msgSend(self->_searchField,sel_stringValue);
    pvVar1 = _objc_msgSend(pvVar1,sel_length);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
      pvVar1 = _objc_msgSend(pvVar1,sel_displayNameAtPath_,mediaPathConformsToFilter);
      pvVar2 = _objc_msgSend(self->_searchField,sel_stringValue);
      pvVar1 = _objc_msgSend(pvVar1,sel_rangeOfString_options_,pvVar2,1);
      cVar3 = pvVar1 != (id)0x7fffffff;
    }
  }
  return cVar3;
}

*/
- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    if (![super mediaPathConformsToFilter:aFilter]) {
        return NO;
    }
    if ([[_searchField stringValue] length] == 0) {
        return YES;
    }
    return [[[NSFileManager defaultManager] displayNameAtPath:aFilter] rangeOfString:[_searchField stringValue] options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (void)itemsFilterPopUpDidChange:(id)aChange
{
    [_itemsFilterPopUp synchronizeTitleAndSelectedItem];
    [self invalidateMediaPaths];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b005f @ 001b005f, 328 bytes * /

void FUN_001b005f(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,id controlTextDidChange)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  pvVar2 = _objc_msgSend(pvVar1,sel_stringValue);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(self->_filterString,sel_isEqualToString_,pvVar2);
  if ((char)pvVar3 == '\0') {
    _objc_msgSend(self->_filterString,sel_release,pvVar1);
    pvVar1 = _objc_msgSend(pvVar2,sel_copy);
    self->_filterString = pvVar1;
    self_00 = cls_NSBundle;
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pvVar2 = _objc_msgSend(self->_filterString,sel_length);
    pcVar4 = &cfstr_NotFound_placeholderString;
    if (pvVar2 == (id)0x0) {
      pcVar4 = &cfstr_Empty_placeholderString;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                           &cfstr_ImportDialogs);
    _objc_msgSend(self->_imageGrid,sel_setPlaceholderString_,pvVar1);
  }
  _objc_msgSend(self,sel_invalidateMediaPaths,pvVar1);
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    id string = [[aChange object] stringValue];
    if (![_filterString isEqualToString:string]) {
        [_filterString release];
        _filterString = [string copy];
        [_imageGrid setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:([_filterString length] == 0 ? @"Empty_placeholderString" : @"NotFound_placeholderString") value:@"" table:@"ImportDialogs"]];
    }
    [self invalidateMediaPaths];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001af84f @ 001af84f, 2064 bytes * /

void FUN_001af84f(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,
                 id selectionDidChangeInGridControl)

{
  bool bVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  float extraout_EDX_00;
  id *ppvVar5;
  HSImportDialogGraphicsPaneViewController *pHVar6;
  SEL op;
  undefined4 uVar7;
  undefined4 uVar8;
  int iVar9;
  float fVar10;
  int *piVar11;
  char local_24;
  float local_20;
  id local_1c;
  id local_18;
  int local_14;
  
  _objc_msgSend((self->super)._dialogController,sel_validateUIElements);
  pvVar2 = _objc_msgSend(self->_croppedImageSourceInfo,sel_objectForKey_,
                         &cfstr_croppedImageSourceFilePath);
  pvVar3 = _objc_msgSend(self,sel_paneFilePath);
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pvVar3);
  local_1c = *(id *)PTR_0033607c;
  local_20 = *(float *)(PTR_0033607c + 4);
  if ((char)pvVar2 == '\0') {
LAB_001af997:
    _objc_msgSend(self->_croppedImage,sel_release,pvVar3);
    self->_croppedImage = (id)0x0;
    _objc_msgSend(self->_cropPaths,sel_release);
    self->_cropPaths = (id)0x0;
    _objc_msgSend(self->_croppedImageSourceInfo,sel_release);
    self->_croppedImageSourceInfo = (id)0x0;
    pvVar2 = _objc_msgSend(self,sel_paneFilePath);
    if (pvVar2 == (id)0x0) {
      local_18 = (id)0x0;
LAB_001afa20:
      self_00 = cls_HSMovieObject;
      pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_hyperFileTypeAtPath_,pvVar2);
      pvVar3 = _objc_msgSend(self_00,sel_isMediaTypeSupported_,pvVar3);
      if ((char)pvVar3 != '\0') {
        pvVar3 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_,pvVar2);
        local_14 = 0;
        pvVar2 = _objc_msgSend(cls_HSMovieObject,sel_alloc);
        piVar11 = &local_14;
        pvVar2 = _objc_msgSend(pvVar2,sel_initWithMedia_error_,pvVar3,piVar11);
        if ((pvVar2 != (id)0x0) && (local_14 == 0)) {
          pvVar3 = _objc_msgSend(pvVar2,sel_movie,pvVar3,piVar11);
          pvVar3 = _objc_msgSend(pvVar3,sel_posterFrameImage);
          bVar1 = true;
          local_24 = '\0';
          local_18 = _objc_msgSend(pvVar3,sel_retain);
          goto LAB_001afbd6;
        }
      }
      bVar1 = false;
      local_24 = '\0';
    }
    else {
      pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc);
      pvVar3 = pvVar2;
      local_18 = _objc_msgSend(pvVar4,sel_initWithContentsOfFile_,pvVar2);
      if (local_18 == (id)0x0) goto LAB_001afa20;
      local_1c = _objc_msgSend(local_18,sel_hyperPixelsSize,pvVar3);
      bVar1 = false;
      pvVar3 = _objc_msgSend(cls_HSCelMovieObject,
                             sel_isCelAnimationCanBeCreatedAtPath_frameFormat_firstFrame_framesCount_
                             ,pvVar2,0,0,0);
      local_24 = (char)pvVar3;
      local_20 = extraout_EDX;
    }
LAB_001afbd6:
    pvVar3 = local_1c;
    fVar10 = local_20;
    _objc_msgSend(self->_cardPreview,sel_setImageSize_,local_1c,local_20);
    if (local_18 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_dialogType,pvVar3,fVar10);
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,*(undefined4 *)PTR_PTR_00336664);
      if ((char)pvVar3 != '\0') {
        pvVar3 = self->_getAnotherPictureOptionsMatrix;
        pvVar2 = _objc_msgSend(self,sel_isImageRectangular_,local_18,fVar10);
        _objc_msgSend(pvVar3,sel_selectCellWithTag_,((char)pvVar2 == '\0') + 1);
      }
    }
    pvVar3 = local_18;
    _objc_msgSend(self->_cardPreview,sel_setImage_,local_18,fVar10);
    _objc_msgSend(local_18,sel_release);
  }
  else {
    pvVar2 = _objc_msgSend(self->_croppedImageSourceInfo,sel_objectForKey_,
                           &cfstr_croppedImageSourceFileModDate);
    pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar4 = _objc_msgSend(self,sel_paneFilePath);
    fVar10 = 0.0;
    pvVar3 = _objc_msgSend(pvVar3,sel_fileAttributesAtPath_traverseLink_,pvVar4,0);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,*(undefined4 *)PTR_003366d4);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToDate_,pvVar3);
    if ((char)pvVar2 == '\0') goto LAB_001af997;
    bVar1 = false;
    local_24 = '\0';
  }
  pvVar3 = _objc_msgSend(self,sel_paneHyperDocument,pvVar3,fVar10);
  pvVar3 = _objc_msgSend(pvVar3,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0037da44);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperCardSize);
  pvVar2 = _objc_msgSend(self,sel_dialogType);
  pHVar6 = self;
  if (bVar1) {
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,*(undefined4 *)PTR_PTR_003360d0);
    if ((char)pvVar2 == '\0') {
      ppvVar5 = &self->_objectOptionsMatrix;
    }
    else {
      ppvVar5 = &self->_backgroundOptionsMatrix;
    }
    pvVar2 = *ppvVar5;
    if (((float)pvVar3 < (float)local_1c) || (extraout_EDX_00 < local_20)) {
      uVar7 = 1;
    }
    else {
      uVar7 = 3;
    }
    _objc_msgSend(pvVar2,sel_selectCellWithTag_,uVar7);
    self->_tempObjectLayoutTagChange = '\x01';
    op = sel_layoutChanged_;
    goto LAB_001b003d;
  }
  uVar7 = *(undefined4 *)PTR_PTR_003360d8;
  uVar8 = uVar7;
  pvVar4 = _objc_msgSend(pvVar2,sel_isEqualToString_,uVar7);
  if (((char)pvVar4 != '\0') &&
     (pvVar4 = _objc_msgSend(self,sel_isObjectOptionsDisabled,uVar8), (char)pvVar4 != '\0')) {
    if (((float)pvVar3 < (float)local_1c) || (extraout_EDX_00 < local_20)) {
      iVar9 = 1;
    }
    else {
      iVar9 = self->_defaultObjectLayoutTag;
    }
    _objc_msgSend(self->_objectOptionsMatrix,sel_selectCellWithTag_,iVar9);
    pvVar2 = self->_objectOptionsMatrix;
    op = sel_layoutChanged_;
    goto LAB_001b003d;
  }
  pvVar4 = _objc_msgSend(pvVar2,sel_isEqualToString_,uVar7);
  if ((char)pvVar4 == '\0') {
    uVar7 = *(undefined4 *)PTR_PTR_003360d4;
    pvVar4 = _objc_msgSend(pvVar2,sel_isEqualToString_,uVar7);
    if ((char)pvVar4 == '\0') {
      uVar7 = *(undefined4 *)PTR_PTR_003360d0;
      pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,uVar7);
      if (((char)pvVar3 == '\0') ||
         (pvVar3 = (id)self->_userSelectedObjectLayoutTag,
         pvVar4 = _objc_msgSend(self->_backgroundOptionsMatrix,sel_selectedTag,uVar7),
         pvVar3 == pvVar4)) {
        pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,*(undefined4 *)PTR_PTR_00336664);
        if ((char)pvVar3 == '\0') {
          pvVar2 = (id)0x1;
          pHVar6 = (HSImportDialogGraphicsPaneViewController *)self->_cardPreview;
          op = sel_setNeedsDisplay_;
        }
        else {
          pvVar2 = self->_getAnotherPictureOptionsMatrix;
          op = sel_layoutChanged_;
        }
      }
      else {
        _objc_msgSend(self->_backgroundOptionsMatrix,sel_selectCellWithTag_,
                      self->_userSelectedObjectLayoutTag);
        pvVar2 = self->_backgroundOptionsMatrix;
        op = sel_layoutChanged_;
      }
      goto LAB_001b003d;
    }
  }
  if ((local_20 < extraout_EDX_00 * 0.57735026 &&
       (float)local_1c < ((float)pvVar3 / extraout_EDX_00) * extraout_EDX_00 * 0.57735026) ||
     (local_24 != '\0')) {
    self->_tempObjectLayoutTagChange = '\x01';
    pvVar3 = self->_objectOptionsMatrix;
    iVar9 = 3;
LAB_001aff55:
    _objc_msgSend(pvVar3,sel_selectCellWithTag_,iVar9);
  }
  else {
    pvVar3 = (id)self->_userSelectedObjectLayoutTag;
    pvVar2 = _objc_msgSend(self->_objectOptionsMatrix,sel_selectedTag,uVar7);
    if (pvVar3 != pvVar2) {
      pvVar3 = self->_objectOptionsMatrix;
      iVar9 = self->_userSelectedObjectLayoutTag;
      goto LAB_001aff55;
    }
  }
  pvVar2 = self->_objectOptionsMatrix;
  op = sel_layoutChanged_;
LAB_001b003d:
  _objc_msgSend(pHVar6,op,pvVar2);
  _objc_msgSend(self,sel_validateRunCropImageButton);
  return;
}

*/
- (void)selectionDidChangeInGridControl:(id)aControl
{
    NSSize imageSize = NSZeroSize;
    BOOL isMovie = NO;
    BOOL isCelAnimation = NO;
    NSSize cardSize;
    id type;
    id matrix;
    [_dialogController validateUIElements];
    if (![[_croppedImageSourceInfo objectForKey:@"croppedImageSourceFilePath"] isEqualToString:[self paneFilePath]]
        || ![[_croppedImageSourceInfo objectForKey:@"croppedImageSourceFileModDate"] isEqualToDate:[[[NSFileManager defaultManager] fileAttributesAtPath:[self paneFilePath] traverseLink:NO] objectForKey:NSFileModificationDate]]) {
        id path;
        NSImage *image = nil;
        [_croppedImage release];
        _croppedImage = nil;
        [_cropPaths release];
        _cropPaths = nil;
        [_croppedImageSourceInfo release];
        _croppedImageSourceInfo = nil;
        path = [self paneFilePath];
        if (path != nil) {
            image = [[NSImage alloc] initWithContentsOfFile:path];
        }
        if (image != nil) {
            imageSize = [image hyperPixelsSize];
            isCelAnimation = [HSCelMovieObject isCelAnimationCanBeCreatedAtPath:path frameFormat:NULL firstFrame:NULL framesCount:NULL];
        }
        else if ([HSMovieObject isMediaTypeSupported:[[NSFileManager defaultManager] hyperFileTypeAtPath:path]]) {
            id error = nil;
            // The movie object is not released, as in the original.
            id movieObject = [[HSMovieObject alloc] initWithMedia:[HSNewMedia mediaWithPath:path] error:&error];
            if (movieObject != nil && error == nil) {
                image = [[[movieObject movie] posterFrameImage] retain];
                isMovie = YES;
            }
        }
        [_cardPreview setImageSize:imageSize];
        if (image != nil && [[self dialogType] isEqualToString:HSImportDialogControllerTypeGetAnotherPicture]) {
            [_getAnotherPictureOptionsMatrix selectCellWithTag:([self isImageRectangular:image] ? 1 : 2)];
        }
        [_cardPreview setImage:image];
        [image release];
    }
    cardSize = [[[[self paneHyperDocument] stack] queryHyperInterface:@protocol(HSStackAttributes)] hyperCardSize];
    type = [self dialogType];
    if (isMovie) {
        matrix = [type isEqualToString:HSImportDialogControllerTypeBackground] ? _backgroundOptionsMatrix : _objectOptionsMatrix;
        [matrix selectCellWithTag:((cardSize.width < imageSize.width || cardSize.height < imageSize.height) ? 1 : 3)];
        _tempObjectLayoutTagChange = YES;
        [self layoutChanged:matrix];
    }
    else if ([type isEqualToString:HSImportDialogControllerTypeGraphicObject] && [self isObjectOptionsDisabled]) {
        [_objectOptionsMatrix selectCellWithTag:((cardSize.width < imageSize.width || cardSize.height < imageSize.height) ? 1 : _defaultObjectLayoutTag)];
        [self layoutChanged:_objectOptionsMatrix];
    }
    else if (![type isEqualToString:HSImportDialogControllerTypeGraphicObject] && ![type isEqualToString:HSImportDialogControllerTypeGraphic]) {
        if ([type isEqualToString:HSImportDialogControllerTypeBackground] && _userSelectedObjectLayoutTag != [_backgroundOptionsMatrix selectedTag]) {
            [_backgroundOptionsMatrix selectCellWithTag:_userSelectedObjectLayoutTag];
            [self layoutChanged:_backgroundOptionsMatrix];
        }
        else if ([type isEqualToString:HSImportDialogControllerTypeGetAnotherPicture]) {
            [self layoutChanged:_getAnotherPictureOptionsMatrix];
        }
        else {
            [_cardPreview setNeedsDisplay:YES];
        }
    }
    else {
        // Small images (under 1/sqrt(3) of the card) and cel animations default to tag 3.
        if ((imageSize.height < cardSize.height * 0.57735026f && imageSize.width < (cardSize.width / cardSize.height) * cardSize.height * 0.57735026f) || isCelAnimation) {
            _tempObjectLayoutTagChange = YES;
            [_objectOptionsMatrix selectCellWithTag:3];
        }
        else if (_userSelectedObjectLayoutTag != [_objectOptionsMatrix selectedTag]) {
            [_objectOptionsMatrix selectCellWithTag:_userSelectedObjectLayoutTag];
        }
        [self layoutChanged:_objectOptionsMatrix];
    }
    [self validateRunCropImageButton];
}

- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self gridControl:aControl titleForItemAt:aAt];
    if (pvVar1 == nil) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [NSDictionary dictionaryWithObject:pvVar1 forKey:SMKGridAttributeVoiceOverItemTypeKey];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001af4fc @ 001af4fc, 749 bytes * /

id FUN_001af4fc(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,id gridControl,
               int imageForItemAt)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  float fVar5;
  float fVar6;
  float fVar7;
  char *pcVar8;
  undefined4 uVar9;
  char local_11;
  
  pvVar2 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar2 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,imageForItemAt);
  pvVar3 = _objc_msgSend(self->_imageGrid,sel_mode);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager,imageForItemAt);
    imageForItemAt = (int)pvVar2;
    pvVar3 = _objc_msgSend(pvVar3,sel_thumbnailForPath_,pvVar2);
    if (pvVar3 != (id)0x0) goto LAB_001af6c8;
  }
  local_11 = '\0';
  pvVar4 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,imageForItemAt);
  pcVar8 = &local_11;
  pvVar3 = pvVar2;
  pvVar4 = _objc_msgSend(pvVar4,sel_fileExistsAtPath_isDirectory_,pvVar2,pcVar8);
  if (((char)pvVar4 == '\0') || (local_11 == '\0')) {
    pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar3,pcVar8);
    imageForItemAt = (int)pvVar2;
    pvVar3 = _objc_msgSend(pvVar3,sel_initByReferencingFile_,pvVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar3,pcVar8);
    pvVar3 = _objc_msgSend(pvVar3,sel_iconForFile_,pvVar2);
    pvVar4 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
    pvVar4 = _objc_msgSend(pvVar4,sel_isLeopardOrGreater);
    if ((char)pvVar4 == '\0') {
      uVar9 = 0x43000000;
      imageForItemAt = 0x43000000;
    }
    else {
      uVar9 = 0x44000000;
      imageForItemAt = 0x44000000;
    }
    _objc_msgSend(pvVar3,sel_setSize_,imageForItemAt,uVar9);
  }
LAB_001af6c8:
  pvVar4 = _objc_msgSend(pvVar3,sel_size,imageForItemAt);
  fVar5 = *(float *)PTR_0033607c;
  fVar1 = *(float *)(PTR_0033607c + 4);
  if (((float)pvVar4 != 0.0) || (NAN((float)pvVar4))) {
    fVar6 = ABS((float)pvVar4);
  }
  else {
    fVar6 = 1.0;
  }
  if ((fVar5 != 0.0) || (NAN(fVar5))) {
    fVar7 = ABS(fVar5);
  }
  else {
    fVar7 = 1.0;
  }
  if (fVar7 <= fVar6) {
    fVar7 = fVar6;
  }
  if (ABS((float)pvVar4 - fVar5) <= fVar7 * 0.0005) {
    if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
      fVar5 = ABS(extraout_EDX);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar6 = ABS(fVar1);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (ABS(extraout_EDX - fVar1) <= fVar6 * 0.0005) {
      pvVar3 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager,imageForItemAt);
      pvVar3 = _objc_msgSend(pvVar3,sel_thumbnailForPath_,pvVar2);
    }
  }
  return pvVar3;
}

*/
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    id path = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:aAt];
    NSImage *image = nil;
    BOOL isDirectory;
    NSSize size;
    if ([_imageGrid mode] == 0) {
        image = [[HSThumbnailManager sharedThumbnailManager] thumbnailForPath:path];
    }
    if (image == nil) {
        isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            float iconSize = [[HSSystem sharedSystem] isLeopardOrGreater] ? 512.0f : 128.0f;
            image = [[NSWorkspace sharedWorkspace] iconForFile:path];
            [image setSize:NSMakeSize(iconSize, iconSize)];
        }
        else {
            image = [[[NSImage alloc] initByReferencingFile:path] autorelease];
        }
    }
    size = [image size];
    if (HSGraphicsPaneFloatsAreEqual(size.width, NSZeroSize.width) && HSGraphicsPaneFloatsAreEqual(size.height, NSZeroSize.height)) {
        image = [[HSThumbnailManager sharedThumbnailManager] thumbnailForPath:path];
    }
    return image;
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return [[[[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:aAt] lastPathComponent] stringByDeletingPathExtension];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001af340 @ 001af340, 319 bytes * /

int FUN_001af340(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,
                id numberOfItemsInGridControl)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_01 = cls_NSString;
  pvVar3 = self->_itemsCountTextField;
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar1 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  self_00 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr__dItems,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar1 = _objc_msgSend(self_01,sel_stringWithFormat_,pvVar2,pvVar1);
  _objc_msgSend(pvVar3,sel_setStringValue_,pvVar1);
  pvVar3 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar3 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  return (int)pvVar3;
}

*/
- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"], (int)[[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count]]];
    return [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b08c0 @ 001b08c0, 916 bytes * /

BOOL FUN_001b08c0(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,id isImageRectangular)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  id pvVar7;
  id pvVar8;
  byte *pbVar9;
  int iVar10;
  byte *pbVar11;
  int iVar12;
  int iVar13;
  int local_3c;
  int local_34;
  
  pvVar2 = _objc_msgSend(isImageRectangular,sel_representations);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(isImageRectangular,sel_representations);
    iVar13 = 0;
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,0);
    if ((pvVar2 != (id)0x0) &&
       (pvVar3 = _objc_msgSend(pvVar2,sel_hasAlpha,iVar13), (char)pvVar3 != '\0')) {
      local_3c = _CGColorSpaceCreateWithName(*(undefined4 *)PTR_003366d8);
      if (local_3c == 0) {
        local_3c = _CGColorSpaceCreateDeviceRGB();
        iVar13 = local_3c;
        _objc_msgSend(cls_HSCFObject,sel_autoreleasedCFObject_,local_3c);
      }
      pvVar3 = _objc_msgSend(pvVar2,sel_pixelsWide,iVar13);
      pvVar4 = _objc_msgSend(pvVar2,sel_pixelsHigh);
      iVar12 = (int)pvVar4 * (int)pvVar3 * 4;
      iVar13 = _CFDataCreateMutable(*(undefined4 *)PTR_003363a4,iVar12);
      if (iVar13 != 0) {
        _objc_msgSend(cls_HSCFObject,sel_autoreleasedCFObject_,iVar13);
        uVar5 = _CFDataGetMutableBytePtr(iVar13);
        uVar6 = _CFRetain(iVar13);
        iVar12 = _CGDataProviderCreateWithData(uVar6,uVar5,iVar12,FUN_001b1906);
        if (iVar12 != 0) {
          _objc_msgSend(cls_HSCFObject,sel_autoreleasedCFObject_,iVar12);
          uVar5 = _CFDataGetMutableBytePtr(iVar13);
          iVar13 = _CGBitmapContextCreate(uVar5,pvVar3,pvVar4,8,(int)pvVar3 * 4,local_3c,2);
          if (iVar13 != 0) {
            pvVar7 = _objc_msgSend(cls_NSGraphicsContext,
                                   sel_graphicsContextWithGraphicsPort_flipped_,iVar13,0);
            pvVar8 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
            pvVar8 = _objc_msgSend(pvVar8,sel_retain);
            _objc_msgSend(cls_NSGraphicsContext,sel_setCurrentContext_,pvVar7);
            _objc_msgSend(isImageRectangular,sel_drawRepresentation_inRect_,pvVar2,0,
                          CONCAT44((float)(int)pvVar4,(float)(int)pvVar3));
            _objc_msgSend(cls_NSGraphicsContext,sel_setCurrentContext_,pvVar8);
            _objc_msgSend(pvVar8,sel_release);
            pbVar9 = (byte *)_CGBitmapContextGetData(iVar13);
            if (0 < (int)pvVar3) {
              local_34 = 0;
              do {
                iVar12 = local_34 + 1;
                pbVar11 = pbVar9;
                for (iVar10 = 0; iVar10 < (int)pvVar4; iVar10 = iVar10 + 1) {
                  if (((((local_34 == 0) || (iVar10 == 0)) || ((int)pvVar3 + -1 == local_34)) ||
                      ((int)pvVar4 + -1 == iVar10)) && ((float)*pbVar11 < 128.0)) {
                    bVar1 = true;
                    goto LAB_001b0bc2;
                  }
                  pbVar11 = pbVar11 + (int)pvVar3 * 4;
                }
                pbVar9 = pbVar9 + 4;
                local_34 = iVar12;
              } while (iVar12 < (int)pvVar3);
            }
            bVar1 = false;
LAB_001b0bc2:
            _CGContextRelease(iVar13);
            return !bVar1;
          }
        }
      }
    }
  }
  return '\x01';
}

*/
- (BOOL)isImageRectangular:(id)aRectangular
{
    NSImageRep *rep;
    CGColorSpaceRef colorSpace;
    NSInteger width;
    NSInteger height;
    NSInteger length;
    CFMutableDataRef data;
    CGDataProviderRef provider;
    CGContextRef context;
    NSGraphicsContext *previousContext;
    const unsigned char *bytes;
    NSInteger x;
    NSInteger y;
    BOOL hasTransparentEdge = NO;
    if ([[aRectangular representations] count] == 0) {
        return YES;
    }
    rep = [[aRectangular representations] objectAtIndex:0];
    if (rep == nil || ![rep hasAlpha]) {
        return YES;
    }
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    // The original leaked the generic color space; both are released here.
    [HSCFObject autoreleasedCFObject:colorSpace];
    width = [rep pixelsWide];
    height = [rep pixelsHigh];
    length = height * width * 4;
    data = CFDataCreateMutable(kCFAllocatorDefault, length);
    if (data == NULL) {
        return YES;
    }
    CFDataSetLength(data, length);
    [HSCFObject autoreleasedCFObject:data];
    provider = CGDataProviderCreateWithData((void *)CFRetain(data), CFDataGetMutableBytePtr(data), length, HSGraphicsPaneReleaseProviderData);
    if (provider == NULL) {
        return YES;
    }
    [HSCFObject autoreleasedCFObject:provider];
    context = CGBitmapContextCreate(CFDataGetMutableBytePtr(data), width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        return YES;
    }
    previousContext = [[NSGraphicsContext currentContext] retain];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithCGContext:context flipped:NO]];
    [aRectangular drawRepresentation:rep inRect:NSMakeRect(0.0f, 0.0f, (float)width, (float)height)];
    [NSGraphicsContext setCurrentContext:previousContext];
    [previousContext release];
    bytes = CGBitmapContextGetData(context);
    // Any edge pixel with alpha below half makes the image non rectangular.
    for (x = 0; x < width && !hasTransparentEdge; x++) {
        const unsigned char *pixel = bytes + x * 4;
        for (y = 0; y < height; y++) {
            if ((x == 0 || y == 0 || x == width - 1 || y == height - 1) && (float)*pixel < 128.0f) {
                hasTransparentEdge = YES;
                break;
            }
            pixel += width * 4;
        }
    }
    CGContextRelease(context);
    return !hasTransparentEdge;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001af2ff @ 001af2ff, 65 bytes * /

id FUN_001af2ff(HSImportDialogGraphicsPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  puVar1 = PTR_PTR_003360d0;
  pvVar2 = _objc_msgSend(self,sel_dialogType);
  pcVar3 = &cfstr_HSAddGraphic;
  if (pvVar2 == *(id *)puVar1) {
    pcVar3 = &cfstr_HSImportBackground;
  }
  return pcVar3;
}

*/
- (id)helpTopicKey
{
    // Identity comparison, as in the original.
    if ([self dialogType] == HSImportDialogControllerTypeBackground) {
        return @"HSImportBackground";
    }
    return @"HSAddGraphic";
}

- (id)currentMediaPathsLocation
{
    return nil;
}

- (void)restoreSelection
{
    NSUInteger pvVar1;
    NSUInteger pvVar2;
    NSUInteger pvVar3;

    pvVar2 = [_imageGrid count];
    pvVar1 = _storedGridSelection;
    if (pvVar1 != NSNotFound) {
        pvVar3 = (pvVar2 - 1);
        if (pvVar1 < pvVar2) {
            pvVar3 = pvVar1;
        }
        [_imageGrid selectItemAtIndex:pvVar3 byExtendingSelection:NO];
    }
}

- (void)storeSelection
{
    _storedGridSelection = (unsigned int)[_imageGrid selectedItemIndex];
}

- (void)reloadMediaPaths
{
    [self storeSelection];
    [_imageGrid reloadData];
    [self restoreSelection];
    [self selectionDidChangeInGridControl:_imageGrid];
    [self validateRunCropImageButton];
}

- (id)supportedMediaTypes
{
    return [HSNewMediaAccessor supportedMediaTypesForClass:@"HSImageObject"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001af034 @ 001af034, 391 bytes * /

id FUN_001af034(HSImportDialogGraphicsPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSImportDialogUserOptions,sel_new);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  self_00 = cls_NSNumber;
  pvVar2 = _objc_msgSend(self->_cardPreview,sel_imageScaling);
  pvVar2 = _objc_msgSend(self_00,sel_numberWithInt_,pvVar2);
  _objc_msgSend(pvVar1,sel_setValue_forKey_,pvVar2,*(undefined4 *)PTR_PTR_003360ec);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(self->_croppedImage != (id)0x0));
  _objc_msgSend(pvVar1,sel_setValue_forKey_,pvVar2,*(undefined4 *)PTR_PTR_003360e8);
  _objc_msgSend(pvVar1,sel_setValue_forKey_,self->_croppedImage,*(undefined4 *)PTR_PTR_003360e4);
  _objc_msgSend(pvVar1,sel_setValue_forKey_,self->_cropPaths,*(undefined4 *)PTR_PTR_003360e0);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(byte)self->_wasCropped);
  _objc_msgSend(pvVar1,sel_setValue_forKey_,pvVar2,*(undefined4 *)PTR_PTR_003360a0);
  return pvVar1;
}

*/
- (id)paneUserOptions
{
    id options = [[HSImportDialogUserOptions new] autorelease];
    [options setValue:[NSNumber numberWithInt:(int)[_cardPreview imageScaling]] forKey:HSImportDialogGraphicsOptionKeyLayout];
    [options setValue:[NSNumber numberWithBool:(_croppedImage != nil)] forKey:HSImportDialogGraphicsOptionKeyIsImageCropped];
    [options setValue:_croppedImage forKey:HSImportDialogGraphicsOptionKeyCroppedImage];
    [options setValue:_cropPaths forKey:HSImportDialogGraphicsOptionKeyClipPaths];
    [options setValue:[NSNumber numberWithBool:_wasCropped] forKey:HSCaptureImageKey];
    return options;
}

- (id)paneFilePath
{
    id pvVar1_4;

    if ([_imageGrid selectedItemIndex] < [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count]) {
        pvVar1_4 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:[_imageGrid selectedItemIndex]];
    }
    else {
        pvVar1_4 = nil;
    }
    return pvVar1_4;
}

- (void)validateRunCropImageButton
{
    char cVar1;
    NSFileManager *pvVar3;
    id pvVar2_2;

    if (([_imageGrid selectedItem] == nil) || (_disableCropImage != NO)) {
        cVar1 = NO;
    }
    else {
        pvVar2_2 = [self paneFilePath];
        if (pvVar2_2 != nil) {
            pvVar3 = [NSFileManager defaultManager];
            if ([pvVar3 isHyperAliasAtPath:pvVar2_2]) {
                pvVar2_2 = [[NSFileManager defaultManager] hyperResolveAliasAtPath:pvVar2_2];
            }
        }
        cVar1 = [[NSFileManager defaultManager] hyperIsFileReadableAtPath:pvVar2_2];
    }
    [_runCropImageButton setEnabled:cVar1];
}

- (void)captureImage:(id)aImage
{
    _wasCropped = YES;
    [_dialogController addToCard:aImage];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ae854 @ 001ae854, 1498 bytes * /

void FUN_001ae854(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,id cropImage)

{
  HSBackgroundPreviewView *self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSImportDialogGraphicsPaneViewController *pHVar4;
  float extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  SEL op;
  undefined *puVar5;
  int iVar6;
  cfstringStruct *pcVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  
  self_01 = _objc_msgSend(cls_HSCropImageDialogController,sel_new);
  pvVar1 = _objc_msgSend(self,sel_paneHyperDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  _objc_msgSend(self_01,sel_setSelectionAlternateProportion_,extraout_EDX / (float)pvVar1);
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar7 = &cfstr_empty;
  uVar9 = 0;
  pvVar2 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Crop,&cfstr_empty,0);
  _objc_msgSend(self_01,sel_setOKButtonTitle_,pvVar2);
  pvVar1 = self->_croppedImage;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar2,pcVar7,uVar9);
    pvVar2 = _objc_msgSend(self,sel_paneFilePath);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithContentsOfFile_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  }
  _objc_msgSend(self_01,sel_setSourceNSImage_,pvVar1,pcVar7,uVar9);
  pvVar1 = _objc_msgSend(self,sel_paneView);
  pvVar1 = _objc_msgSend(pvVar1,sel_window);
  _objc_msgSend(pvVar1,sel_close);
  pvVar1 = _objc_msgSend(cls_NSApplication,sel_sharedApplication);
  pvVar2 = _objc_msgSend(self_01,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_runModalForWindow_,pvVar2);
  pvVar2 = _objc_msgSend(self,sel_paneView);
  pvVar2 = _objc_msgSend(pvVar2,sel_window);
  pHVar4 = self;
  _objc_msgSend(pvVar2,sel_makeKeyAndOrderFront_,self);
  if (pvVar1 != (id)0x1) goto LAB_001aee11;
  pvVar1 = _objc_msgSend(self_01,sel_croppedImage,pHVar4);
  if (pvVar1 == (id)0x0) goto LAB_001aee11;
  _objc_msgSend(self->_croppedImage,sel_release,pHVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_croppedImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar2 = _objc_msgSend(self,sel_paneFilePath);
  pvVar1 = _objc_msgSend(pvVar1,sel_fileAttributesAtPath_traverseLink_,pvVar2,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_003366d4);
  _objc_msgSend(self->_croppedImageSourceInfo,sel_release);
  pvVar2 = _objc_msgSend(cls_NSDictionary,sel_alloc);
  pvVar3 = _objc_msgSend(self,sel_paneFilePath);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithObjectsAndKeys_,pvVar3,&cfstr_croppedImageSourceFilePath
                         ,pvVar1,&cfstr_croppedImageSourceFileModDate,0);
  self->_croppedImageSourceInfo = pvVar1;
  self_00 = self->_cardPreview;
  pvVar1 = _objc_msgSend(self->_croppedImage,sel_size);
  uVar8 = extraout_EDX_00;
  _objc_msgSend(self_00,sel_setImageSize_,pvVar1,extraout_EDX_00);
  _objc_msgSend(self->_cardPreview,sel_setImage_,self->_croppedImage);
  pvVar1 = _objc_msgSend(self,sel_dialogType);
  uVar9 = *(undefined4 *)PTR_PTR_003360d8;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,uVar9);
  if ((char)pvVar1 == '\0') {
LAB_001aed7c:
    pHVar4 = (HSImportDialogGraphicsPaneViewController *)self->_cardPreview;
    pvVar1 = (id)0x1;
    op = sel_setNeedsDisplay_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_isObjectOptionsDisabled,uVar9,uVar8);
    if ((char)pvVar1 == '\0') goto LAB_001aed7c;
    pvVar1 = _objc_msgSend(self,sel_paneHyperDocument,uVar9);
    pvVar1 = _objc_msgSend(pvVar1,sel_stack);
    puVar5 = &DAT_0037da44;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037da44);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
    pvVar2 = _objc_msgSend(self->_croppedImage,sel_size);
    if ((float)pvVar1 < (float)pvVar2) {
LAB_001aed27:
      pvVar1 = self->_objectOptionsMatrix;
      iVar6 = 1;
    }
    else {
      _objc_msgSend(self->_croppedImage,sel_size,puVar5);
      if (extraout_EDX_01 < extraout_EDX_02) goto LAB_001aed27;
      pvVar1 = self->_objectOptionsMatrix;
      iVar6 = self->_defaultObjectLayoutTag;
    }
    _objc_msgSend(pvVar1,sel_selectCellWithTag_,iVar6);
    pvVar1 = self->_objectOptionsMatrix;
    pHVar4 = self;
    op = sel_layoutChanged_;
  }
  _objc_msgSend(pHVar4,op,pvVar1);
  pvVar2 = self->_cropPaths;
  if (pvVar2 == (id)0x0) {
    pvVar1 = (id)0x1;
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,1);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_cropPaths = pvVar2;
  }
  pHVar4 = _objc_msgSend(self_01,sel_borderPath,pvVar1);
  _objc_msgSend(pvVar2,sel_addObject_,pHVar4);
LAB_001aee11:
  _objc_msgSend(self_01,sel_release,pHVar4);
  return;
}

*/
- (void)cropImage:(id)aImage
{
    HSCropImageDialogController *cropController = [HSCropImageDialogController new];
    NSSize cardSize = [[[self paneHyperDocument] stack] hyperCardSize];
    id sourceImage;
    NSInteger result;
    id croppedImage;
    id modificationDate;
    [cropController setSelectionAlternateProportion:cardSize.height / cardSize.width];
    [cropController setOKButtonTitle:[[NSBundle mainBundle] localizedStringForKey:@"Crop" value:@"" table:nil]];
    sourceImage = _croppedImage;
    if (sourceImage == nil) {
        sourceImage = [[[NSImage alloc] initWithContentsOfFile:[self paneFilePath]] autorelease];
    }
    [cropController setSourceNSImage:sourceImage];
    [[[self paneView] window] close];
    result = [NSApp runModalForWindow:[cropController window]];
    [[[self paneView] window] makeKeyAndOrderFront:self];
    if (result == NSModalResponseOK && (croppedImage = [cropController croppedImage]) != nil) {
        [_croppedImage release];
        _croppedImage = [croppedImage retain];
        modificationDate = [[[NSFileManager defaultManager] fileAttributesAtPath:[self paneFilePath] traverseLink:NO] objectForKey:NSFileModificationDate];
        [_croppedImageSourceInfo release];
        _croppedImageSourceInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[self paneFilePath], @"croppedImageSourceFilePath", modificationDate, @"croppedImageSourceFileModDate", nil];
        [_cardPreview setImageSize:[_croppedImage size]];
        [_cardPreview setImage:_croppedImage];
        if ([[self dialogType] isEqualToString:HSImportDialogControllerTypeGraphicObject] && [self isObjectOptionsDisabled]) {
            NSSize stackSize = [[[[self paneHyperDocument] stack] queryHyperInterface:@protocol(HSStackAttributes)] hyperCardSize];
            NSSize imageSize = [_croppedImage size];
            [_objectOptionsMatrix selectCellWithTag:((stackSize.width < imageSize.width || stackSize.height < imageSize.height) ? 1 : _defaultObjectLayoutTag)];
            [self layoutChanged:_objectOptionsMatrix];
        }
        else {
            [_cardPreview setNeedsDisplay:YES];
        }
        if (_cropPaths == nil) {
            _cropPaths = [[NSMutableArray arrayWithCapacity:1] retain];
        }
        [_cropPaths addObject:(id)[cropController borderPath]];
    }
    [cropController release];
}

- (void)onDoubleClick:(id)aClick
{
    [_dialogController addToCard:aClick];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ae755 @ 001ae755, 181 bytes * /

void FUN_001ae755(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,id layoutChanged)

{
  id pvVar1;
  undefined4 uVar2;
  
  if ((layoutChanged == (id)0x0) || (self->_tempObjectLayoutTagChange != '\0')) {
    self->_tempObjectLayoutTagChange = '\0';
  }
  else {
    pvVar1 = _objc_msgSend(layoutChanged,sel_selectedTag);
    self->_userSelectedObjectLayoutTag = (int)pvVar1;
  }
  if (layoutChanged == (id)0x0) {
    pvVar1 = (id)self->_defaultObjectLayoutTag;
  }
  else {
    pvVar1 = _objc_msgSend(layoutChanged,sel_selectedTag);
  }
  switch(pvVar1) {
  case (id)0x0:
    uVar2 = 1;
    break;
  case (id)0x1:
    uVar2 = 2;
    break;
  case (id)0x2:
    uVar2 = 3;
    break;
  case (id)0x3:
    uVar2 = 4;
    break;
  case (id)0x4:
    uVar2 = 5;
    break;
  case (id)0x5:
    uVar2 = 0;
    break;
  default:
    uVar2 = 0xffffffff;
  }
  _objc_msgSend(self,sel_updateCardPreviewForLayoutOption_,uVar2);
  return;
}

*/
- (void)layoutChanged:(id)aChanged
{
    if (aChanged == nil || _tempObjectLayoutTagChange) {
        _tempObjectLayoutTagChange = NO;
    }
    else {
        _userSelectedObjectLayoutTag = (int)[aChanged selectedTag];
    }
    [self updateCardPreviewForLayoutOption:HSGraphicsPaneLayoutOptionForTag(aChanged == nil ? _defaultObjectLayoutTag : [aChanged selectedTag])];
}

- (void)zoomMax:(id)aMax
{
    [self zoomThumbnailSizeSliderToValue:[_thumbnailSizeSlider maxValue]];
}

- (void)zoomMin:(id)aMin
{
    [self zoomThumbnailSizeSliderToValue:[_thumbnailSizeSlider minValue]];
}

- (void)zoomThumbnailSizeSliderToValue:(double)aValue
{
    [_thumbnailSizeSlider setDoubleValue:aValue];
    [self sliderMoved:_thumbnailSizeSlider];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b0cda @ 001b0cda, 277 bytes * /

void FUN_001b0cda(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,id sliderMoved)

{
  id pvVar1;
  longdouble lVar2;
  double dVar3;
  HSImportDialogGraphicsPaneViewController *self_00;
  SEL op;
  id pvVar4;
  
  lVar2 = (longdouble)_HSNonLinearValueForSlider(self->_thumbnailSizeSlider);
  dVar3 = _objc_msgSend_fpret(sliderMoved,sel_maxValue);
  pvVar4 = (id)(float)lVar2;
  if ((float)pvVar4 <= (float)dVar3 * 0.98) {
    if ((float)dVar3 * 0.98 < (float)pvVar4) goto LAB_001b0d9f;
    _objc_msgSend(self,sel_setMode_forGridControl_,0,self->_imageGrid);
    self_00 = self->_imageGrid;
    op = sel_setThumbnailSize_;
    pvVar1 = pvVar4;
  }
  else {
    pvVar4 = (id)0x1;
    self_00 = self;
    op = sel_setMode_forGridControl_;
    pvVar1 = self->_imageGrid;
  }
  _objc_msgSend(self_00,op,pvVar4,pvVar1);
LAB_001b0d9f:
  pvVar4 = self->_imageGrid;
  pvVar1 = _objc_msgSend(pvVar4,sel_selectedItemIndex);
  _objc_msgSend(pvVar4,sel_scrollToVisibleAtIndex_,pvVar1);
  _objc_msgSend(self->_imageGrid,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)sliderMoved:(id)aMoved
{
    float value = HSNonLinearValueForSlider(_thumbnailSizeSlider);
    float maxValue = [(NSSlider *)aMoved maxValue];
    if (value > maxValue * 0.98f) {
        [self setMode:1 forGridControl:_imageGrid];
    }
    else if (value <= maxValue * 0.98f) {
        [self setMode:0 forGridControl:_imageGrid];
        [_imageGrid setThumbnailSize:NSMakeSize(value, value)];
    }
    [_imageGrid scrollToVisibleAtIndex:[_imageGrid selectedItemIndex]];
    [_imageGrid setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ae661 @ 001ae661, 163 bytes * /

void FUN_001ae661(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,int setMode,
                 id forGridControl)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(forGridControl,sel_mode);
  if (pvVar1 != (id)setMode) {
    pvVar1 = _objc_msgSend(forGridControl,sel_selectedItemIndex);
    _objc_msgSend(forGridControl,sel_setMode_,setMode);
    _objc_msgSend(forGridControl,sel_reloadData);
    _objc_msgSend(forGridControl,sel_selectItemAtIndex_byExtendingSelection_,pvVar1,0);
    _objc_msgSend(self,sel_validateRunCropImageButton);
  }
  return;
}

*/
- (void)setMode:(NSInteger)aMode forGridControl:(id)aControl
{
    NSInteger index;
    if ([(SMKGridControl *)aControl mode] == aMode) {
        return;
    }
    index = [aControl selectedItemIndex];
    [aControl setMode:aMode];
    [aControl reloadData];
    [aControl selectItemAtIndex:index byExtendingSelection:NO];
    [self validateRunCropImageButton];
}

- (void)switchHistoryTo:(id)aTo
{

}

- (id)paneViewNibName
{
    return @"ImportDialogGraphicsPaneView";
}

- (id)paneAccessoryView
{
    [self paneView];
    return _paneAccessoryView;
}

- (id)paneView
{
    id pvVar1;

    pvVar1 = _paneView;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:[self paneViewNibName] owner:self];
        pvVar1 = _paneView;
    }
    return pvVar1;
}

- (id)paneIdentifier
{
    return @"HSImportDialogGraphicsBase";
}

- (void)willUnmountFromDialogController:(id)aController
{
    [_captureImageButton setHidden:YES];
    [super willUnmountFromDialogController:aController]
    ;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b0e4c @ 001b0e4c, 1023 bytes * /

void FUN_001b0e4c(HSImportDialogGraphicsPaneViewController *self,SEL _cmd,
                 id willMountToDialogController)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  longdouble lVar4;
  float local_3c [4];
  float local_2c [4];
  HSImportDialogGraphicsPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogBasePaneViewContro_003535a0;
  _objc_msgSendSuper(&local_1c,sel_willMountToDialogController_);
  pvVar1 = _objc_msgSend(self,sel_dialogType);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_);
  if ((char)pvVar1 == '\0') {
LAB_001b0f31:
    pvVar1 = _objc_msgSend(self,sel_dialogType);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_dialogType);
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_);
      if ((char)pvVar1 != '\0') goto LAB_001b0f99;
    }
    else {
LAB_001b0f99:
      pvVar1 = _objc_msgSend(self->_layoutOptionsView,sel_contentView);
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_);
      if ((char)pvVar1 == '\0') {
        _objc_msgSend(self->_layoutOptionsView,sel_setContentView_);
        pvVar1 = _objc_msgSend(self->_objectOptionsMatrix,sel_selectedTag);
        switch(pvVar1) {
        case (id)0x0:
          goto switchD_001b0f2f_caseD_0;
        case (id)0x1:
          goto switchD_001b0f2f_caseD_1;
        case (id)0x2:
          goto switchD_001b0f2f_caseD_2;
        case (id)0x3:
          goto switchD_001b0f2f_caseD_3;
        case (id)0x4:
          goto switchD_001b0f2f_caseD_4;
        case (id)0x5:
          goto switchD_001b0f2f_caseD_5;
        }
        goto LAB_001b10eb;
      }
    }
    pvVar1 = _objc_msgSend(self,sel_dialogType);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_);
    puVar3 = (undefined4 *)&stack0xffffffa4;
    if ((char)pvVar1 == '\0') goto LAB_001b11b4;
    pvVar1 = _objc_msgSend(self->_layoutOptionsView,sel_contentView);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_);
    puVar3 = (undefined4 *)&stack0xffffffa4;
    if ((char)pvVar1 != '\0') goto LAB_001b11b4;
    _objc_msgSend(self->_layoutOptionsView,sel_setContentView_);
    pvVar1 = _objc_msgSend(self->_getAnotherPictureOptionsMatrix,sel_selectedTag);
    switch(pvVar1) {
    case (id)0x0:
      goto switchD_001b0f2f_caseD_0;
    case (id)0x1:
      goto switchD_001b0f2f_caseD_1;
    case (id)0x2:
      goto switchD_001b0f2f_caseD_2;
    case (id)0x3:
      goto switchD_001b0f2f_caseD_3;
    case (id)0x4:
      goto switchD_001b0f2f_caseD_4;
    case (id)0x5:
      goto switchD_001b0f2f_caseD_5;
    }
  }
  else {
    pvVar1 = _objc_msgSend(self->_layoutOptionsView,sel_contentView);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_);
    if ((char)pvVar1 != '\0') goto LAB_001b0f31;
    _objc_msgSend(self->_layoutOptionsView,sel_setContentView_);
    pvVar1 = _objc_msgSend(self->_backgroundOptionsMatrix,sel_selectedTag);
    switch(pvVar1) {
    case (id)0x0:
switchD_001b0f2f_caseD_0:
      break;
    case (id)0x1:
switchD_001b0f2f_caseD_1:
      break;
    case (id)0x2:
switchD_001b0f2f_caseD_2:
      break;
    case (id)0x3:
switchD_001b0f2f_caseD_3:
      break;
    case (id)0x4:
switchD_001b0f2f_caseD_4:
      break;
    case (id)0x5:
switchD_001b0f2f_caseD_5:
    }
  }
LAB_001b10eb:
  _objc_msgSend(self,sel_updateCardPreviewForLayoutOption_);
  _objc_msgSend_stret(local_2c,self->_layoutOptionsView,sel_frame);
  pvVar1 = _objc_msgSend(self->_layoutOptionsView,sel_superview);
  _objc_msgSend_stret(local_3c,pvVar1,sel_bounds);
  lVar4 = (longdouble)_roundf();
  local_2c[0] = local_3c[0] + (float)lVar4;
  _objc_msgSend(self->_layoutOptionsView,sel_setFrame_);
  puVar3 = (undefined4 *)&stack0xffffff9c;
LAB_001b11b4:
  self->_wasCropped = '\0';
  pvVar1 = self->_captureImageButton;
  puVar3[1] = sel_captureImageButtonEnabled;
  *puVar3 = willMountToDialogController;
  puVar3[-1] = 0x1b11d3;
  pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[2] = (uint)((char)pvVar2 == '\0');
  puVar3[1] = sel_setHidden_;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x1b11f1;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_invalidateSearch;
  *puVar3 = self;
  puVar3[-1] = 0x1b1203;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[1] = sel_updateCardPreviewSize;
  *puVar3 = self;
  puVar3[-1] = 0x1b1215;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  pvVar1 = self->_searchField;
  puVar3[1] = sel_window;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x1b122a;
  pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  puVar3[2] = self->_searchField;
  puVar3[1] = sel_makeFirstResponder_;
  *puVar3 = pvVar1;
  puVar3[-1] = 0x1b1243;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)willMountToDialogController:(id)aController
{
    id type;
    id optionsView = nil;
    id optionsMatrix = nil;
    NSRect frame;
    NSRect bounds;
    [super willMountToDialogController:aController];
    type = [self dialogType];
    if ([type isEqualToString:HSImportDialogControllerTypeBackground] && ![[_layoutOptionsView contentView] isEqual:_backgroundOptionsView]) {
        optionsView = _backgroundOptionsView;
        optionsMatrix = _backgroundOptionsMatrix;
    }
    else if (([[self dialogType] isEqualToString:HSImportDialogControllerTypeGraphicObject] || [[self dialogType] isEqualToString:HSImportDialogControllerTypeGraphic])
        && ![[_layoutOptionsView contentView] isEqual:_objectOptionsView]) {
        optionsView = _objectOptionsView;
        optionsMatrix = _objectOptionsMatrix;
    }
    else if ([[self dialogType] isEqualToString:HSImportDialogControllerTypeGetAnotherPicture] && ![[_layoutOptionsView contentView] isEqual:_getAnotherPictureOptionsView]) {
        optionsView = _getAnotherPictureOptionsView;
        optionsMatrix = _getAnotherPictureOptionsMatrix;
    }
    if (optionsView != nil) {
        [_layoutOptionsView setContentView:optionsView];
        [self updateCardPreviewForLayoutOption:HSGraphicsPaneLayoutOptionForTag([optionsMatrix selectedTag])];
        // The options box is centred horizontally in its superview.
        frame = [_layoutOptionsView frame];
        bounds = [[_layoutOptionsView superview] bounds];
        frame.origin.x = bounds.origin.x + roundf((bounds.size.width - frame.size.width) * 0.5f);
        [_layoutOptionsView setFrame:frame];
    }
    _wasCropped = NO;
    [_captureImageButton setHidden:![aController captureImageButtonEnabled]];
    [self invalidateSearch];
    [self updateCardPreviewSize];
    [[_searchField window] makeFirstResponder:_searchField];
}

- (void)paneDialogWillOpen
{
    _wasCropped = NO;
    [self invalidateSearch];
    [self updateCardPreviewSize];
    [self selectionDidChangeInGridControl:_imageGrid];
}

- (void)paneDialogWillCancel
{
    [_croppedImageSourceInfo release];
    _croppedImageSourceInfo = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b1294 @ 001b1294, 1650 bytes * /

void FUN_001b1294(HSImportDialogGraphicsPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  float fVar4;
  double dVar5;
  double dVar6;
  undefined4 uVar8;
  undefined8 uVar7;
  
  _objc_msgSend(self->_searchField,sel_setDelegate_,self);
  _objc_msgSend(self->_imageGrid,sel_setDataSource_,self);
  _objc_msgSend(self->_imageGrid,sel_setDelegate_,self);
  _objc_msgSend(self->_imageGrid,sel_setTarget_,self);
  _objc_msgSend(self->_imageGrid,sel_setCellControlSize_,1);
  _objc_msgSend(self->_imageGrid,sel_setSelectionStyle_,3);
  _objc_msgSend(self->_imageGrid,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailCachingEnabled_,0);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailHyphenationEnabled_,1);
  _objc_msgSend(self->_imageGrid,sel_setThreadedPreloadingEnabled_,0);
  _objc_msgSend(self->_imageGrid,sel_setExtraPasteboardDataProvidingAllowed_,0);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_scrollView);
  _objc_msgSend(pvVar1,sel_setBorderType_,0);
  _objc_msgSend(self->_imageGrid,sel_setMode_,0);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailMaxTitleHeight_,0x41880000);
  _objc_msgSend(self->_imageGrid,sel_setGraphicContentShadowEnabled_,0);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_gridMatrix);
  pvVar2 = _objc_msgSend(cls_SMKGridAttributedCell,sel_class);
  _objc_msgSend(pvVar1,sel_setCellClass_,pvVar2);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_gridMatrix);
  _objc_msgSend(pvVar1,sel_setAcceptsFirstMouse_,1);
  pvVar1 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager);
  dVar5 = _objc_msgSend_fpret(pvVar1,sel_thumbnailSize);
  dVar6 = _objc_msgSend_fpret(self->_thumbnailSizeSlider,sel_minValue);
  fVar4 = (float)((dVar6 + dVar5) * 0.5);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailSize_,fVar4,fVar4);
  _objc_msgSend(self->_imageGrid,sel_setDoubleAction_,sel_onDoubleClick_);
  self_00 = cls_NSBundle;
  pvVar1 = self->_imageGrid;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Empty_placeholderString,&cfstr_empty,&cfstr_ImportDialogs);
  _objc_msgSend(pvVar1,sel_setPlaceholderString_,pvVar2);
  pvVar2 = _objc_msgSend(self->_imageGrid,sel_thumbnailSize);
  _objc_msgSend(self->_thumbnailSizeSlider,sel_setMaxValue_,dVar5);
  uVar8 = (undefined4)((ulonglong)dVar5 >> 0x20);
  pvVar1 = self->_thumbnailSizeSlider;
  lVar3 = (longdouble)_HSLinearValueForSliderFromNonLinear(pvVar1,pvVar2);
  _objc_msgSend(pvVar1,sel_setFloatValue_,(float)lVar3);
  _objc_msgSend(self->_cardPreviewBackground,sel_setImageScaling_,1);
  pvVar1 = self->_cardPreviewBackground;
  pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_DenimPreview);
  uVar7 = CONCAT44(uVar8,pvVar2);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  pvVar2 = _objc_msgSend(self->_objectOptionsMatrix,sel_selectedTag);
  pvVar1 = (id)self->_defaultObjectLayoutTag;
  if (pvVar2 != pvVar1) {
    uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),pvVar1);
    _objc_msgSend(self->_objectOptionsMatrix,sel_selectCellWithTag_,pvVar1);
  }
  pvVar2 = _objc_msgSend(self->_backgroundOptionsMatrix,sel_selectedTag,uVar7);
  pvVar1 = (id)self->_defaultBackgroundLayoutTag;
  if (pvVar2 != pvVar1) {
    uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),pvVar1);
    _objc_msgSend(self->_backgroundOptionsMatrix,sel_selectCellWithTag_,pvVar1);
  }
  pvVar1 = _objc_msgSend(self->_getAnotherPictureOptionsMatrix,sel_selectedTag,uVar7);
  if (pvVar1 != (id)self->_defaultObjectLayoutTag) {
    _objc_msgSend(self->_getAnotherPictureOptionsMatrix,sel_selectCellWithTag_,
                  (id)self->_defaultObjectLayoutTag);
  }
  _objc_msgSend(self,sel_selectionDidChangeInGridControl_,self->_imageGrid);
  _objc_msgSend(self->_layoutOptionsView,sel_setTitlePosition_,0);
  _objc_msgSend(self->_layoutOptionsView,sel_setBorderType_,0);
  _objc_msgSend(self->_layoutOptionsView,sel_setBoxType_,3);
  _objc_msgSend(self->_layoutOptionsView,sel_setContentViewMargins_,0,0);
  pvVar1 = self->_backgroundOptionsMatrix;
  pvVar2 = _objc_msgSend(self,sel_isObjectOptionsDisabled);
  _objc_msgSend(pvVar1,sel_setEnabled_,(uint)((char)pvVar2 == '\0'));
  pvVar1 = self->_objectOptionsMatrix;
  pvVar2 = _objc_msgSend(self,sel_isObjectOptionsDisabled);
  _objc_msgSend(pvVar1,sel_setEnabled_,(uint)((char)pvVar2 == '\0'));
  _objc_msgSend(self->_historyNavigationControl,sel_setLabel_forSegment_,0,0);
  _objc_msgSend(self->_historyNavigationControl,sel_setLabel_forSegment_,0,1);
  _objc_msgSend(self,sel_validateRunCropImageButton);
  return;
}

*/
- (void)awakeFromNib
{
    float thumbnailSize;
    float managerSize;
    [_searchField setDelegate:(id)self];
    [_imageGrid setDataSource:self];
    [_imageGrid setDelegate:self];
    [_imageGrid setTarget:self];
    [_imageGrid setCellControlSize:NSControlSizeSmall];
    [_imageGrid setSelectionStyle:3];
    [_imageGrid setAllowsMultipleSelection:NO];
    [_imageGrid setThumbnailCachingEnabled:NO];
    [_imageGrid setThumbnailHyphenationEnabled:YES];
    [_imageGrid setThreadedPreloadingEnabled:NO];
    [_imageGrid setExtraPasteboardDataProvidingAllowed:NO];
    [[_imageGrid scrollView] setBorderType:NSNoBorder];
    [_imageGrid setMode:0];
    [_imageGrid setThumbnailMaxTitleHeight:17.0f];
    [_imageGrid setGraphicContentShadowEnabled:NO];
    [[_imageGrid gridMatrix] setCellClass:[SMKGridAttributedCell class]];
    [[_imageGrid gridMatrix] setAcceptsFirstMouse:YES];
    managerSize = [(HSThumbnailManager *)[HSThumbnailManager sharedThumbnailManager] thumbnailSize];
    thumbnailSize = (float)(([_thumbnailSizeSlider minValue] + managerSize) * 0.5);
    [_imageGrid setThumbnailSize:NSMakeSize(thumbnailSize, thumbnailSize)];
    [_imageGrid setDoubleAction:@selector(onDoubleClick:)];
    [_imageGrid setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Empty_placeholderString" value:@"" table:@"ImportDialogs"]];
    thumbnailSize = [_imageGrid thumbnailSize].width;
    [_thumbnailSizeSlider setMaxValue:managerSize];
    [_thumbnailSizeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_thumbnailSizeSlider, thumbnailSize)];
    [_cardPreviewBackground setImageScaling:NSImageScaleAxesIndependently];
    [_cardPreviewBackground setImage:[NSImage imageNamed:@"DenimPreview"]];
    if ([_objectOptionsMatrix selectedTag] != _defaultObjectLayoutTag) {
        [_objectOptionsMatrix selectCellWithTag:_defaultObjectLayoutTag];
    }
    if ([_backgroundOptionsMatrix selectedTag] != _defaultBackgroundLayoutTag) {
        [_backgroundOptionsMatrix selectCellWithTag:_defaultBackgroundLayoutTag];
    }
    if ([_getAnotherPictureOptionsMatrix selectedTag] != _defaultObjectLayoutTag) {
        [_getAnotherPictureOptionsMatrix selectCellWithTag:_defaultObjectLayoutTag];
    }
    [self selectionDidChangeInGridControl:_imageGrid];
    [_layoutOptionsView setTitlePosition:NSNoTitle];
    [_layoutOptionsView setBorderType:NSNoBorder];
    [_layoutOptionsView setBoxType:NSBoxOldStyle];
    [_layoutOptionsView setContentViewMargins:NSZeroSize];
    [_backgroundOptionsMatrix setEnabled:![self isObjectOptionsDisabled]];
    [_objectOptionsMatrix setEnabled:![self isObjectOptionsDisabled]];
    [_historyNavigationControl setLabel:@"" forSegment:0];
    [_historyNavigationControl setLabel:@"" forSegment:1];
    [self validateRunCropImageButton];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b048b @ 001b048b, 396 bytes * /

void FUN_001b048b(HSImportDialogGraphicsPaneViewController *self,SEL _cmd)

{
  HSImportDialogGraphicsPaneViewController *pHVar1;
  HSImportDialogGraphicsPaneViewController *local_14;
  undefined *local_10;
  
  pHVar1 = _objc_msgSend(self->_searchField,sel_delegate);
  if (pHVar1 == self) {
    _objc_msgSend(self->_searchField,sel_setDelegate_,0);
  }
  _objc_msgSend(self->_filterString,sel_release);
  pHVar1 = _objc_msgSend(self->_imageGrid,sel_delegate);
  if (pHVar1 == self) {
    _objc_msgSend(self->_imageGrid,sel_setDelegate_,0);
  }
  pHVar1 = _objc_msgSend(self->_imageGrid,sel_dataSource);
  if (pHVar1 == self) {
    _objc_msgSend(self->_imageGrid,sel_setDataSource_,0);
  }
  _objc_msgSend(self->_paneView,sel_release);
  _objc_msgSend(self->_paneAccessoryView,sel_release);
  _objc_msgSend(self->_backgroundOptionsView,sel_release);
  _objc_msgSend(self->_objectOptionsView,sel_release);
  _objc_msgSend(self->_croppedImage,sel_release);
  _objc_msgSend(self->_cropPaths,sel_release);
  _objc_msgSend(self->_croppedImageSourceInfo,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSImportDialogBasePaneViewContro_003535a0;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    if ([_searchField delegate] == (id)self) {
        [_searchField setDelegate:nil];
    }
    [_filterString release];
    if ([_imageGrid delegate] == (id)self) {
        [_imageGrid setDelegate:nil];
    }
    if ([_imageGrid dataSource] == (id)self) {
        [_imageGrid setDataSource:nil];
    }
    [_paneView release];
    [_paneAccessoryView release];
    [_backgroundOptionsView release];
    [_objectOptionsView release];
    [_croppedImage release];
    [_cropPaths release];
    [_croppedImageSourceInfo release];
    [super dealloc];
}

- (void)cropImageDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id delegate = [aDialog delegate];
    if (aCode == 1 && [delegate croppedImage] != nil) {
        [_croppedImage release];
        _croppedImage = [[delegate croppedImage] retain];
        id modificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:[self paneFilePath] error:NULL] objectForKey:NSFileModificationDate];
        [_croppedImageSourceInfo release];
        _croppedImageSourceInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[self paneFilePath], @"croppedImageSourceFilePath", modificationDate, @"croppedImageSourceFileModDate", nil];
        [_cardPreview setImageSize:[_croppedImage size]];
        [_cardPreview setImage:_croppedImage];
        if ([[self dialogType] isEqualToString:HSImportDialogControllerTypeGraphicObject] && [self isObjectOptionsDisabled]) {
            NSSize cardSize = [[[[self paneHyperDocument] stack] queryHyperInterface:@protocol(HSStackAttributes)] hyperCardSize];
            NSSize imageSize = [_croppedImage size];
            if (cardSize.width < imageSize.width || cardSize.height < imageSize.height)
                [_objectOptionsMatrix selectCellWithTag:1];
            else
                [_objectOptionsMatrix selectCellWithTag:_defaultObjectLayoutTag];
            [self layoutChanged:_objectOptionsMatrix];
        } else {
            [_cardPreview setNeedsDisplay:YES];
        }
        if (_cropPaths == nil)
            _cropPaths = [[NSMutableArray arrayWithCapacity:1] retain];
        [_cropPaths addObject:[delegate borderPath]];
    }
    [delegate autorelease];
}

@end

