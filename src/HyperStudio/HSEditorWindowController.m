#import "HSEditorWindowController.h"

// FUN_00012a1c: the rect an image (srcRect) takes inside aDstRect for an image scaling option.
static NSRect HSEditorImportFitRect(NSInteger aOption, NSRect aSrcRect, NSRect aDstRect)
{
    float x = 0.0f, y = 0.0f;
    float w = aSrcRect.size.width, h = aSrcRect.size.height;
    float dw = aDstRect.size.width, dh = aDstRect.size.height;
    switch (aOption) {
        case 0:
        case 2:
            if (aOption == 0 ? (dw / dh < w / h) : !(dw / dh <= w / h)) {
                h = dw / (w / h);
                w = dw;
            } else {
                w = (w / h) * dh;
                h = dh;
            }
            y = y + ((dh * 0.5f + y) - (h * 0.5f + y));
            x = x + ((dw * 0.5f + x) - (w * 0.5f + x));
            break;
        case 1: {
            float ratio = w / h;
            if (ratio <= dw / dh) {
                w = ratio * dh;
                h = dh;
            } else {
                h = dw / ratio;
                w = dw;
            }
            h = h * 0.57735026f;
            y = y + ((dh * 0.5f + aDstRect.origin.y) - (h * 0.5f + y));
            w = w * 0.57735026f;
            x = x + ((dw * 0.5f + aDstRect.origin.x) - (w * 0.5f + x));
            break;
        }
        case 3:
            x = aDstRect.origin.x;
            y = aDstRect.origin.y;
            w = dw;
            h = dh;
            break;
        case 4:
            y = ((dh * 0.5f + aDstRect.origin.y) - (h * 0.5f + aSrcRect.origin.y)) + aSrcRect.origin.y;
            x = ((dw * 0.5f + aDstRect.origin.x) - (w * 0.5f + aSrcRect.origin.x)) + aSrcRect.origin.x;
            break;
        case 6:
            if (dw < w || dh < h) {
                float ratio = w / h;
                if (ratio <= dw / dh) {
                    w = ratio * dh;
                    h = dh;
                } else {
                    h = dw / ratio;
                    w = dw;
                }
                y = y + ((dh * 0.5f + y) - (h * 0.5f + y));
                x = x + ((dw * 0.5f + x) - (w * 0.5f + x));
            } else {
                y = ((dh * 0.5f + 0.0f) - (h * 0.5f + 0.0f)) + 0.0f;
                x = ((dw * 0.5f + 0.0f) - (w * 0.5f + 0.0f)) + 0.0f;
            }
            break;
        default:
            w = 0.0f;
            h = 0.0f;
            break;
    }
    return NSMakeRect(x, y, w, h);
}

// Comments for an imported file: the library's record for the media, else the file's own comments.
static NSString *HSEditorImportedCommentsForPath(NSString *aPath, BOOL aIsCapture)
{
    NSString *comments = nil;
    if (!aIsCapture) {
        NSString *uidString = [[[HSLibraryManager sharedLibraryManager] mediaContentFilter] globalUIDStringForMediaItem:aPath];
        if (uidString != nil) {
            comments = [HSMediaCommentsAndAttributionsProvider commentsAndAttributionsForMediaUID:[HSUID UIDWithString:uidString]];
        }
    }
    if (comments == nil && [aPath length] != 0) {
        comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:aPath]];
    }
    return comments;
}

static BOOL HSEditorFuzzyEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f, mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}

// The "Add recorded ... to the card?" alert with a "don't show again" check box; YES when the user chose to add.
static BOOL HSEditorRunRecordingConfirmationAlert(NSString *aMessage, NSString *aInformative, NSString *aDiscardTitle, NSString *aDefaultsKey)
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[provider localizedStringForKey:aMessage value:@"" table:@"Alerts"]];
    [alert setInformativeText:[provider localizedStringForKey:aInformative value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"Add to Card" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:aDiscardTitle value:@"" table:@"Alerts"]];
    NSButton *checkBox = [[NSButton alloc] initWithFrame:NSZeroRect];
    [checkBox setButtonType:NSSwitchButton];
    [checkBox setTitle:[provider localizedStringForKey:@"Don't show this message again" value:@"" table:@"Alerts"]];
    [alert setCustomView:checkBox];
    BOOL add = ([alert runModal] == 1000);
    if ([checkBox state] == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:aDefaultsKey];
    }
    [checkBox release];
    [alert release];
    return add;
}

static NSInteger HSEditorSpacingCompareByOriginX(id aObject, id aOther, void *aContext)
{
    float a = [aObject frameBoundingRect].origin.x;
    float b = [aOther frameBoundingRect].origin.x;
    if (b <= a) {
        if (a != b || isnan(a) || isnan(b)) {
            return (b < a) ? 1 : 0x7fffffff;
        }
        return 0;
    }
    return -1;
}

static NSInteger HSEditorSpacingCompareByOriginY(id aObject, id aOther, void *aContext)
{
    float a = [aObject frameBoundingRect].origin.y;
    float b = [aOther frameBoundingRect].origin.y;
    if (b <= a) {
        if (a != b || isnan(a) || isnan(b)) {
            return (b < a) ? 1 : 0x7fffffff;
        }
        return 0;
    }
    return -1;
}

@implementation HSEditorWindowController

/* i386 ivar offsets: _cardView=0x34, _stackController=0x38, _cardScrollView=0x3c, _canisterContainerView=0x40, _cardAreaContainerView=0x44, _workAreaContainerView=0x48, _workAreaView=0x4c, _mainAreaTintedView=0x50, _bottomAreaTintedView=0x54, _thisCardSelectionHolder=0x58, _soundRecordingController=0x5c, _videoRecordingController=0x60, _webcamWorkshopController=0x64, _importGraphicDialogController=0x68, _importGraphicObjectDialogController=0x6c, _importBackgroundDialogController=0x70, _playSoundActionEvent=0x74, _importSoundObjectDialogController=0x78, _importMoviesObjectDialogController=0x7c, _wasMediaStripVisible=0x80, _stackTextProvider=0x84, _fieldEditor=0x88, _statusbarController=0x8c, _isLassoIconChanged=0x90, _effectsDialogController=0x94, _originPositionOnCard=0x98, _captureDeviceList=0xa0, _didRequestBackground=0xa4, _addChildrenGroupingIsInProgress=0xa5, _alertHaveShowedForThisGroup=0xa6, _stackSelectionHostWasCurrentBeforeAssistantHide=0xa7 */

+ (id)palettesArrayIncludingLibrary:(BOOL)aLibrary toolPalette:(BOOL)aPalette layoutPalette:(BOOL)aPalette2 objectListPalette:(BOOL)aPalette3 commentsAndAttributionsPalette:(BOOL)aPalette4 shortcutsPalette:(BOOL)aPalette5
{
    id self_00;
    id pvVar1_4;
    id pvVar1_8;
    id pvVar1_12;
    id pvVar1_16;
    id pvVar1_20;
    id pvVar1_24;

    self_00 = [NSMutableArray array];
    if (aLibrary != NO) {
        if ([[HSLibraryController sharedLibraryController] isWindowLoaded]) {
            pvVar1_4 = [[HSLibraryController sharedLibraryController] window];
            if (pvVar1_4 != nil) {
                [self_00 addObject:pvVar1_4];
            }
        }
    }
    if (aPalette != NO) {
        if ([[HSToolPaletteController sharedInstance] isWindowLoaded]) {
            pvVar1_8 = [[HSToolPaletteController sharedInstance] window];
            if (pvVar1_8 != nil) {
                [self_00 addObject:pvVar1_8];
            }
        }
    }
    if (aPalette2 != NO) {
        if ([[HSLayoutPaletteController sharedInstance] isWindowLoaded]) {
            pvVar1_12 = [[HSLayoutPaletteController sharedInstance] window];
            if (pvVar1_12 != nil) {
                [self_00 addObject:pvVar1_12];
            }
        }
    }
    if (aPalette3 != NO) {
        if ([[HSObjectListPaletteController sharedInstance] isWindowLoaded]) {
            pvVar1_16 = [[HSObjectListPaletteController sharedInstance] window];
            if (pvVar1_16 != nil) {
                [self_00 addObject:pvVar1_16];
            }
        }
    }
    if (aPalette4 != NO) {
        if ([[HSCommentsAndAttributionsPaletteController sharedInstance] isWindowLoaded]) {
            pvVar1_20 = [[HSCommentsAndAttributionsPaletteController sharedInstance] window];
            if (pvVar1_20 != nil) {
                [self_00 addObject:pvVar1_20];
            }
        }
    }
    if (aPalette5 != NO) {
        if ([[HSShortcutsPaletteController sharedInstance] isWindowLoaded]) {
            pvVar1_24 = [[HSShortcutsPaletteController sharedInstance] window];
            if (pvVar1_24 != nil) {
                [self_00 addObject:pvVar1_24];
            }
        }
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001efa2 @ 0001efa2, 473 bytes * /

id FUN_0001efa2(id self,SEL _cmd,id loadImageAtPath,id *error)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  float fVar5;
  float fVar6;
  undefined4 uVar7;
  
  if (loadImageAtPath != (id)0x0) {
    uVar7 = 1;
    pvVar1 = _objc_msgSend(cls_NSData,sel_dataWithContentsOfFile_options_error_,loadImageAtPath,1,
                           error);
    if (pvVar1 != (id)0x0) {
      pvVar3 = pvVar1;
      pvVar2 = _objc_msgSend(cls_NSBitmapImageRep,sel_canInitWithData_,pvVar1,uVar7,error);
      if (((char)pvVar2 == '\0') ||
         (pvVar2 = _objc_msgSend(cls_NSBitmapImageRep,sel_imageRepWithData_,pvVar1,uVar7,error),
         pvVar3 = pvVar1, pvVar2 == (id)0x0)) {
        pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar3,uVar7,error);
        pvVar1 = _objc_msgSend(pvVar1,sel_initWithContentsOfFile_,loadImageAtPath);
        pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
        return pvVar1;
      }
      pvVar3 = _objc_msgSend(pvVar2,sel_pixelsHigh,pvVar1,uVar7,error);
      pvVar4 = _objc_msgSend(pvVar2,sel_pixelsWide);
      fVar5 = (float)(int)pvVar4;
      if ((fVar5 != 0.0) && (fVar6 = (float)(int)pvVar3, fVar6 != 0.0)) {
        pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar1,uVar7,error,fVar6,fVar5);
        pvVar1 = _objc_msgSend(pvVar1,sel_initWithSize_,fVar5,fVar6);
        _objc_msgSend(pvVar1,sel_addRepresentation_,pvVar2);
        pvVar3 = _objc_msgSend(pvVar1,sel_isValid);
        if ((char)pvVar3 != '\0') {
          _objc_msgSend(pvVar1,sel_autorelease,pvVar2,fVar6);
          return pvVar1;
        }
        _objc_msgSend(pvVar1,sel_release,pvVar2,fVar6);
      }
    }
  }
  return (id)0x0;
}

*/
+ (id)loadImageAtPath:(id)aPath error:(id *)aError
{
    if (aPath != nil) {
        NSData *data = [NSData dataWithContentsOfFile:aPath options:NSDataReadingMappedIfSafe error:aError];
        if (data != nil) {
            NSBitmapImageRep *rep = nil;
            if ([NSBitmapImageRep canInitWithData:data]) {
                rep = [NSBitmapImageRep imageRepWithData:data];
            }
            if (rep == nil) {
                return [[[NSImage alloc] initWithContentsOfFile:aPath] autorelease];
            }
            float height = (float)[rep pixelsHigh];
            float width = (float)[rep pixelsWide];
            if (width != 0.0f && height != 0.0f) {
                NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
                [image addRepresentation:rep];
                if ([image isValid]) {
                    return [image autorelease];
                }
                [image release];
            }
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001ee98 @ 0001ee98, 266 bytes * /

BOOL FUN_0001ee98(id self,SEL _cmd,id canResizeAndRotateObject)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,canResizeAndRotateObject);
  cVar3 = (char)pvVar1;
  if (cVar3 == '\0') {
    puVar4 = &DAT_003620c8;
    pvVar1 = _objc_msgSend(canResizeAndRotateObject,sel_queryHyperInterface_,&DAT_003620c8);
    pvVar2 = _objc_msgSend(pvVar1,sel_canRotate);
    if ((((char)pvVar2 == '\0') ||
        ((pvVar2 = _objc_msgSend(pvVar1,sel_canResizeHorizontally,puVar4), (char)pvVar2 == '\0' &&
         (pvVar2 = _objc_msgSend(pvVar1,sel_canScaleHorizontally,puVar4), (char)pvVar2 == '\0'))))
       || ((pvVar2 = _objc_msgSend(pvVar1,sel_canResizeVertically,puVar4), (char)pvVar2 == '\0' &&
           (pvVar1 = _objc_msgSend(pvVar1,sel_canScaleVertically), (char)pvVar1 == '\0')))) {
      cVar3 = '\0';
    }
    else {
      pvVar1 = _objc_msgSend(canResizeAndRotateObject,sel_queryHyperInterface_,&DAT_003612cc);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      cVar3 = (char)pvVar1 == '\0';
    }
  }
  return cVar3;
}

*/
+ (BOOL)canResizeAndRotateObject:(id)aObject
{
    BOOL result = [self isValidSelectionTool:aObject];
    if (!result) {
        id geometry = [aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
        if (![geometry canRotate] || (![geometry canResizeHorizontally] && ![geometry canScaleHorizontally]) || (![geometry canResizeVertically] && ![geometry canScaleVertically])) {
            result = NO;
        } else {
            result = ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001ed74 @ 0001ed74, 292 bytes * /

BOOL FUN_0001ed74(id self,SEL _cmd,id canMoveAndResizeObject)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,canMoveAndResizeObject);
  cVar3 = (char)pvVar1;
  if (cVar3 == '\0') {
    puVar4 = &DAT_003620c8;
    pvVar1 = _objc_msgSend(canMoveAndResizeObject,sel_queryHyperInterface_,&DAT_003620c8);
    pvVar2 = _objc_msgSend(pvVar1,sel_canMoveHorizontally);
    if (((((char)pvVar2 == '\0') ||
         (pvVar2 = _objc_msgSend(pvVar1,sel_canMoveVertically,puVar4), (char)pvVar2 == '\0')) ||
        ((pvVar2 = _objc_msgSend(pvVar1,sel_canResizeHorizontally,puVar4), (char)pvVar2 == '\0' &&
         (pvVar2 = _objc_msgSend(pvVar1,sel_canScaleHorizontally,puVar4), (char)pvVar2 == '\0'))))
       || ((pvVar2 = _objc_msgSend(pvVar1,sel_canResizeVertically), (char)pvVar2 == '\0' &&
           (pvVar1 = _objc_msgSend(pvVar1,sel_canScaleVertically), (char)pvVar1 == '\0')))) {
      cVar3 = '\0';
    }
    else {
      pvVar1 = _objc_msgSend(canMoveAndResizeObject,sel_queryHyperInterface_,&DAT_003612cc);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      cVar3 = (char)pvVar1 == '\0';
    }
  }
  return cVar3;
}

*/
+ (BOOL)canMoveAndResizeObject:(id)aObject
{
    BOOL result = [self isValidSelectionTool:aObject];
    if (!result) {
        id geometry = [aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
        if (![geometry canMoveHorizontally] || ![geometry canMoveVertically] || (![geometry canResizeHorizontally] && ![geometry canScaleHorizontally]) || (![geometry canResizeVertically] && ![geometry canScaleVertically])) {
            result = NO;
        } else {
            result = ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001ecb0 @ 0001ecb0, 196 bytes * /

BOOL FUN_0001ecb0(id self,SEL _cmd,id canMoveObject)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,canMoveObject);
  cVar3 = (char)pvVar1;
  if (cVar3 == '\0') {
    puVar4 = &DAT_003620c8;
    pvVar1 = _objc_msgSend(canMoveObject,sel_queryHyperInterface_,&DAT_003620c8);
    pvVar2 = _objc_msgSend(pvVar1,sel_canMoveHorizontally);
    if (((char)pvVar2 == '\0') ||
       (pvVar1 = _objc_msgSend(pvVar1,sel_canMoveVertically,puVar4), (char)pvVar1 == '\0')) {
      cVar3 = '\0';
    }
    else {
      pvVar1 = _objc_msgSend(canMoveObject,sel_queryHyperInterface_,&DAT_003612cc);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      cVar3 = (char)pvVar1 == '\0';
    }
  }
  return cVar3;
}

*/
+ (BOOL)canMoveObject:(id)aObject
{
    BOOL result = [self isValidSelectionTool:aObject];
    if (!result) {
        id geometry = [aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
        if (![geometry canMoveHorizontally] || ![geometry canMoveVertically]) {
            result = NO;
        } else {
            result = ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
        }
    }
    return result;
}

+ (BOOL)isValidSelectionBitmapTool:(id)aTool
{
    BOOL bVar2;

    if (![self isSelectionBitmapToolHasValidEditablePath:aTool validatePath:NO]) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self isSelectionBitmapToolHasValidEditableImage:aTool validateImage:YES];
    }
    return bVar2;
}

+ (BOOL)isSelectionTool:(id)aTool
{
    BOOL bVar3;

    if (![aTool isKindOfClass:[HSBitmapTool class]]) {
        bVar3 = [aTool isKindOfClass:[HSImagePartSelectionTool class]];
    }
    else {
        bVar3 = YES;
    }
    return bVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001ea61 @ 0001ea61, 351 bytes * /

BOOL FUN_0001ea61(id self,SEL _cmd,id canFlipUpsideDownObject)

{
  BOOL BVar1;
  id pvVar2;
  char cVar3;
  
  pvVar2 = _objc_msgSend(self,sel_isValidSelectionTool_,canFlipUpsideDownObject);
  if (((((char)pvVar2 == '\0') &&
       (pvVar2 = _objc_msgSend(canFlipUpsideDownObject,sel_implementsHyperInterface_,&DAT_00361f38),
       (char)pvVar2 == '\0')) &&
      (pvVar2 = _objc_msgSend(canFlipUpsideDownObject,sel_implementsHyperInterface_,&DAT_00361f4c),
      (char)pvVar2 == '\0')) &&
     (pvVar2 = _objc_msgSend(canFlipUpsideDownObject,sel_implementsHyperInterface_,&DAT_00361970),
     (char)pvVar2 == '\0')) {
    cVar3 = '\0';
  }
  else {
    cVar3 = '\x01';
  }
  pvVar2 = _objc_msgSend(canFlipUpsideDownObject,sel_implementsHyperInterface_,&DAT_003613d0);
  if ((char)pvVar2 == '\0') {
    if (cVar3 != '\0') {
      return cVar3;
    }
  }
  else if (cVar3 != '\0') {
    pvVar2 = _objc_msgSend(canFlipUpsideDownObject,sel_queryHyperInterface_,&DAT_003613d0);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEmpty);
    if ((char)pvVar2 == '\0') {
      return '\x01';
    }
  }
  BVar1 = '\0';
  pvVar2 = _objc_msgSend(self,sel_isValidTransformableObject_,canFlipUpsideDownObject);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(canFlipUpsideDownObject,sel_queryHyperInterface_,&DAT_003620c8);
    pvVar2 = _objc_msgSend(pvVar2,sel_canFlipVertically);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
+ (BOOL)canFlipUpsideDownObject:(id)aObject
{
    BOOL editable = [self isValidSelectionTool:aObject]
        || [aObject implementsHyperInterface:@protocol(HSImageMutableAttributes)]
        || [aObject implementsHyperInterface:@protocol(HSSystemSquareButtonAttributes)]
        || [aObject implementsHyperInterface:@protocol(HSEditableImageAttributes)];
    if ([aObject implementsHyperInterface:@protocol(HSCardAttributes)]) {
        if (editable && ![[aObject queryHyperInterface:@protocol(HSCardAttributes)] isEmpty]) {
            return YES;
        }
    } else if (editable) {
        return YES;
    }
    BOOL result = NO;
    if ([self isValidTransformableObject:aObject]) {
        result = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)] canFlipVertically];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e902 @ 0001e902, 351 bytes * /

BOOL FUN_0001e902(id self,SEL _cmd,id canFlipSidewaysObject)

{
  BOOL BVar1;
  id pvVar2;
  char cVar3;
  
  pvVar2 = _objc_msgSend(self,sel_isValidSelectionTool_,canFlipSidewaysObject);
  if (((((char)pvVar2 == '\0') &&
       (pvVar2 = _objc_msgSend(canFlipSidewaysObject,sel_implementsHyperInterface_,&DAT_00361f38),
       (char)pvVar2 == '\0')) &&
      (pvVar2 = _objc_msgSend(canFlipSidewaysObject,sel_implementsHyperInterface_,&DAT_00361f4c),
      (char)pvVar2 == '\0')) &&
     (pvVar2 = _objc_msgSend(canFlipSidewaysObject,sel_implementsHyperInterface_,&DAT_00361970),
     (char)pvVar2 == '\0')) {
    cVar3 = '\0';
  }
  else {
    cVar3 = '\x01';
  }
  pvVar2 = _objc_msgSend(canFlipSidewaysObject,sel_implementsHyperInterface_,&DAT_003613d0);
  if ((char)pvVar2 == '\0') {
    if (cVar3 != '\0') {
      return cVar3;
    }
  }
  else if (cVar3 != '\0') {
    pvVar2 = _objc_msgSend(canFlipSidewaysObject,sel_queryHyperInterface_,&DAT_003613d0);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEmpty);
    if ((char)pvVar2 == '\0') {
      return '\x01';
    }
  }
  BVar1 = '\0';
  pvVar2 = _objc_msgSend(self,sel_isValidTransformableObject_,canFlipSidewaysObject);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(canFlipSidewaysObject,sel_queryHyperInterface_,&DAT_003620c8);
    pvVar2 = _objc_msgSend(pvVar2,sel_canFlipHorizontally);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
+ (BOOL)canFlipSidewaysObject:(id)aObject
{
    BOOL editable = [self isValidSelectionTool:aObject]
        || [aObject implementsHyperInterface:@protocol(HSImageMutableAttributes)]
        || [aObject implementsHyperInterface:@protocol(HSSystemSquareButtonAttributes)]
        || [aObject implementsHyperInterface:@protocol(HSEditableImageAttributes)];
    if ([aObject implementsHyperInterface:@protocol(HSCardAttributes)]) {
        if (editable && ![[aObject queryHyperInterface:@protocol(HSCardAttributes)] isEmpty]) {
            return YES;
        }
    } else if (editable) {
        return YES;
    }
    BOOL result = NO;
    if ([self isValidTransformableObject:aObject]) {
        result = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)] canFlipHorizontally];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001f4e3 @ 0001f4e3, 1063 bytes * /

/* WARNING: Type propagation algorithm not settling * /

id FUN_0001f4e3(id self,SEL _cmd,id transformImage,CGAffineTransform transform,CGRect *pathRect)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  float *pfVar6;
  id pvVar7;
  float fVar8;
  longdouble lVar9;
  float *apfStack_c8 [3];
  float local_88;
  float local_84;
  id local_74;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_4c;
  float fStack_48;
  float local_3c;
  float local_38;
  float local_24;
  float local_20;
  
  pfVar6 = (float *)&stack0xffffff44;
  apfStack_c8[2] = (float *)0x1f50d;
  _objc_msgSend(transformImage,sel_imageSize);
  if (transformImage == (id)0x0) {
    local_74 = (id)0x0;
    pvVar7 = (id)0x0;
    goto LAB_0001f8d5;
  }
  if (pathRect == (CGRect *)0x0) {
    apfStack_c8[2] = (float *)0x1f56c;
    _CGRectIntegral();
    pfVar6 = (float *)(apfStack_c8 + 2);
    local_4c = transform.tx;
    fStack_48 = transform.ty;
    local_84 = *(float *)PTR_0033608c;
    local_88 = *(float *)(PTR_0033608c + 4);
  }
  else {
    apfStack_c8[2] = (float *)0x1f5f1;
    _CGRectIntegral();
    local_3c = local_64;
    local_38 = local_60;
    local_4c = transform.tx - local_6c;
    fStack_48 = transform.ty - local_68;
    apfStack_c8[2] = &local_24;
    apfStack_c8[1] = (float *)0x1f67f;
    _CGRectIntegral();
    pfVar6 = (float *)(apfStack_c8 + 1);
    local_84 = local_24;
    local_88 = local_20;
  }
  if (0.0 < local_3c) {
    *pfVar6 = local_3c;
    pfVar6[-1] = 1.8034e-40;
    lVar9 = (longdouble)_ceilf();
    *pfVar6 = (float)lVar9;
    pfVar6[-1] = 1.80351e-40;
    fVar1 = (float)_lroundf();
  }
  else {
    fVar1 = 0.0;
  }
  if (0.0 < local_38) {
    *pfVar6 = local_38;
    pfVar6[-1] = 1.80395e-40;
    lVar9 = (longdouble)_ceilf();
    *pfVar6 = (float)lVar9;
    pfVar6[-1] = 1.80406e-40;
    fVar2 = (float)_lroundf();
  }
  else {
    fVar2 = 0.0;
  }
  pfVar6[1] = (float)sel_alloc;
  *pfVar6 = (float)cls_NSMutableData;
  fVar8 = (float)((int)fVar1 * 4 + 0xfU & 0xfffffff0);
  pfVar6[-1] = 1.80472e-40;
  pvVar7 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
  pfVar6[2] = (float)((int)fVar2 * (int)fVar8);
  pfVar6[1] = (float)sel_initWithLength_;
  *pfVar6 = (float)pvVar7;
  pfVar6[-1] = 1.80507e-40;
  local_74 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
  if (local_74 != (id)0x0) {
    *pfVar6 = (float)local_74;
    pfVar6[-1] = 1.80542e-40;
    fVar3 = (float)_CGDataProviderCreateWithCFData();
    if (fVar3 != 0.0) {
      pfVar6[-1] = 1.80559e-40;
      fVar4 = (float)_CGColorSpaceCreateDeviceRGB();
      if (fVar4 != 0.0) {
        pfVar6[1] = (float)sel_mutableBytes;
        *pfVar6 = (float)local_74;
        pfVar6[-1] = 1.80623e-40;
        pvVar7 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
        pfVar6[5] = fVar4;
        pfVar6[4] = fVar8;
        pfVar6[2] = fVar2;
        pfVar6[1] = fVar1;
        *pfVar6 = (float)pvVar7;
        pfVar6[6] = 2.8026e-45;
        pfVar6[3] = 1.12104e-44;
        pfVar6[-1] = 1.80683e-40;
        fVar5 = (float)_CGBitmapContextCreate();
        if (fVar5 == 0.0) {
LAB_0001f7b2:
          pvVar7 = (id)0x0;
        }
        else {
          *(ulonglong *)(pfVar6 + 5) = CONCAT44(fStack_48,local_4c);
          *(longlong *)(pfVar6 + 3) = transform._8_8_;
          *(longlong *)(pfVar6 + 1) = transform._0_8_;
          *pfVar6 = fVar5;
          pfVar6[-1] = 1.80759e-40;
          _CGContextConcatCTM();
          pfVar6[4] = local_88;
          pfVar6[3] = local_84;
          pfVar6[2] = fVar5;
          pfVar6[1] = (float)sel_drawInCGContext_atPoint_;
          *pfVar6 = (float)transformImage;
          pfVar6[-1] = 1.80833e-40;
          _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
          pfVar6[7] = fVar3;
          pfVar6[5] = fVar4;
          pfVar6[4] = fVar8;
          pfVar6[1] = fVar2;
          *pfVar6 = fVar1;
          pfVar6[10] = 0.0;
          pfVar6[9] = 1.4013e-45;
          pfVar6[8] = 0.0;
          pfVar6[6] = 2.8026e-45;
          pfVar6[3] = 4.48416e-44;
          pfVar6[2] = 1.12104e-44;
          pfVar6[-1] = 1.80947e-40;
          fVar1 = (float)_CGImageCreate();
          if (fVar1 == 0.0) goto LAB_0001f7b2;
          pfVar6[1] = (float)sel_alloc;
          *pfVar6 = (float)cls_BTCGImage;
          pfVar6[-1] = 1.80999e-40;
          pvVar7 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
          pfVar6[2] = fVar1;
          pfVar6[1] = (float)sel_initWithCGImage_;
          *pfVar6 = (float)pvVar7;
          pfVar6[-1] = 1.8103e-40;
          pvVar7 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
          *pfVar6 = fVar1;
          pfVar6[-1] = 1.81044e-40;
          _CGImageRelease();
        }
        *pfVar6 = fVar3;
        pfVar6[-1] = 1.81059e-40;
        _CGDataProviderRelease();
        if (fVar4 != 0.0) {
          *pfVar6 = fVar4;
          pfVar6[-1] = 1.81083e-40;
          _CGColorSpaceRelease();
        }
        if (fVar5 != 0.0) {
          *pfVar6 = fVar5;
          pfVar6[-1] = 1.811e-40;
          _CGContextRelease();
        }
        goto LAB_0001f8d5;
      }
      *pfVar6 = fVar3;
      pfVar6[-1] = 1.8058e-40;
      _CGDataProviderRelease();
    }
  }
  pvVar7 = (id)0x0;
LAB_0001f8d5:
  pfVar6[1] = (float)sel_release;
  *pfVar6 = (float)local_74;
  pfVar6[-1] = 1.81133e-40;
  _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
  pfVar6[1] = (float)sel_autorelease;
  *pfVar6 = (float)pvVar7;
  pfVar6[-1] = 1.81158e-40;
  pvVar7 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
  return pvVar7;
}

*/
+ (id)transformImage:(id)aImage transform:(CGAffineTransform)aTransform pathRect:(CGRect *)aRect
{
    if (aImage == nil) {
        return nil;
    }
    NSSize imageSize = [aImage imageSize];
    CGRect bounds;
    CGPoint drawPoint = CGPointZero;
    if (aRect == NULL) {
        bounds = CGRectIntegral(CGRectApplyAffineTransform(CGRectMake(0, 0, imageSize.width, imageSize.height), aTransform));
    } else {
        bounds = CGRectIntegral(*aRect);
        aTransform.tx -= bounds.origin.x;
        aTransform.ty -= bounds.origin.y;
    }
    long width = (bounds.size.width > 0.0f) ? lroundf(ceilf(bounds.size.width)) : 0;
    long height = (bounds.size.height > 0.0f) ? lroundf(ceilf(bounds.size.height)) : 0;
    size_t bytesPerRow = ((width * 4) + 0xf) & ~(size_t)0xf;
    NSMutableData *data = [[NSMutableData alloc] initWithLength:height * bytesPerRow];
    id result = nil;
    if (data != nil) {
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
        if (provider != NULL) {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            if (colorSpace != NULL) {
                CGContextRef context = CGBitmapContextCreate([data mutableBytes], width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
                if (context != NULL) {
                    CGContextConcatCTM(context, aTransform);
                    [aImage drawInCGContext:context atPoint:drawPoint];
                    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst, provider, NULL, true, kCGRenderingIntentDefault);
                    if (cgImage != NULL) {
                        result = [[BTCGImage alloc] initWithCGImage:cgImage];
                        CGImageRelease(cgImage);
                    }
                }
                CGDataProviderRelease(provider);
                CGColorSpaceRelease(colorSpace);
                if (context != NULL) {
                    CGContextRelease(context);
                }
                [data release];
                return [result autorelease];
            }
            CGDataProviderRelease(provider);
        }
    }
    [data release];
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001f90a @ 0001f90a, 974 bytes * /

void FUN_0001f90a(id self,SEL _cmd,CGAffineTransform setTransform,id toImageOfObject)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined4 *puVar3;
  longdouble lVar4;
  
  puVar3 = (undefined4 *)&stack0xffffff74;
  pvVar1 = _objc_msgSend(toImageOfObject,sel_queryHyperInterface_);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(toImageOfObject,sel_respondsToSelector_);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar2 = _objc_msgSend(toImageOfObject,sel_image);
    if (pvVar2 == (id)0x0) {
      return;
    }
    _objc_msgSend(pvVar2,sel_size);
    _CGRectApplyAffineTransform();
    _CGRectIntegral();
    puVar3 = (undefined4 *)&stack0xffffff6c;
    lVar4 = (longdouble)_CGRectGetWidth();
    if ((float)lVar4 <= 0.0) {
      return;
    }
    lVar4 = (longdouble)_CGRectGetHeight();
    if ((float)lVar4 <= 0.0) {
      return;
    }
    pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithSize_);
    if (pvVar1 == (id)0x0) {
      return;
    }
    _objc_msgSend(pvVar1,sel_lockFocus);
    self_00 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    _objc_msgSend(self_00,sel_graphicsPort);
    _CGContextTranslateCTM();
    _CGContextConcatCTM();
    _objc_msgSend(pvVar2,sel_drawAtPoint_fromRect_operation_fraction_);
    _objc_msgSend(pvVar1,sel_unlockFocus);
    _objc_msgSend(toImageOfObject,sel_setImage_);
  }
  else {
    pvVar2 = _objc_msgSend(pvVar1,sel_queryImageWithRequiredProtocols_optionalProtocols_);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_transformImage_transform_pathRect_);
    if (pvVar2 == (id)0x0) {
      return;
    }
    _objc_msgSend(pvVar1,sel_beginEditImage_);
  }
  *puVar3 = pvVar1;
  puVar3[-1] = 0x1f9e7;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
+ (void)setTransform:(CGAffineTransform)aTransform toImageOfObject:(id)aObject
{
    id imageAttributes = [aObject queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (imageAttributes != nil) {
        id required[] = { @protocol(BTCGImage), nil };
        id image = [imageAttributes queryImageWithRequiredProtocols:required optionalProtocols:nil];
        if (image == nil) {
            return;
        }
        id transformed = [self transformImage:image transform:aTransform pathRect:NULL];
        if (transformed == nil) {
            return;
        }
        [imageAttributes beginEditImage:transformed];
        [imageAttributes endEditImage];
        return;
    }
    if (![aObject respondsToSelector:@selector(image)]) {
        return;
    }
    NSImage *image = [aObject image];
    if (image == nil) {
        return;
    }
    CGRect bounds = CGRectIntegral(CGRectApplyAffineTransform(CGRectMake(0.0, 0.0, [image size].width, [image size].height), aTransform));
    if (CGRectGetWidth(bounds) <= 0.0f || CGRectGetHeight(bounds) <= 0.0f) {
        return;
    }
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(bounds.size.width, bounds.size.height)];
    if (newImage == nil) {
        return;
    }
    [newImage lockFocus];
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextTranslateCTM(context, -bounds.origin.x, -bounds.origin.y);
    CGContextConcatCTM(context, aTransform);
    [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [newImage unlockFocus];
    [aObject setImage:newImage];
    [newImage release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e881 @ 0001e881, 129 bytes * /

void FUN_0001e881(id self,SEL _cmd,CGAffineTransform setTransform,id toBitmapTool)

{
  id self_00;
  
  self_00 = _objc_msgSend(toBitmapTool,sel_bitmapTool);
  _objc_msgSend(self_00,sel_finalizeSelection_,0);
  _objc_msgSend(self_00,sel_setSelectionAffineTransform_flippingHorizontally_,setTransform._0_8_,
                setTransform._8_8_,setTransform._16_8_,0);
  return;
}

*/
+ (void)setTransform:(CGAffineTransform)aTransform toBitmapTool:(id)aTool
{
    id bitmapTool = [aTool bitmapTool];
    [bitmapTool finalizeSelection:nil];
    [bitmapTool setSelectionAffineTransform:aTransform flippingHorizontally:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001fcd8 @ 0001fcd8, 394 bytes * /

void FUN_0001fcd8(id self,SEL _cmd,CGAffineTransform applyTransform,id toTransformableObject)

{
  id pvVar1;
  id self_00;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  pvVar1 = _objc_msgSend(toTransformableObject,sel_queryHyperInterface_);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  if (pvVar1 != (id)0x0) {
    self_00 = _objc_msgSend(pvVar1,sel_mutableGeometryAttributes);
    _objc_msgSend_stret(&local_44,self_00,sel_affineTransform);
    fStack_18 = local_34 * applyTransform.b + local_30 * applyTransform.d + applyTransform.ty;
    local_1c = local_34 * applyTransform.a + local_30 * applyTransform.c + applyTransform.tx;
    local_2c = local_44 * applyTransform.a + local_40 * applyTransform.c;
    fStack_28 = local_44 * applyTransform.b + local_40 * applyTransform.d;
    local_24 = applyTransform.a * local_3c + applyTransform.c * local_38;
    fStack_20 = local_3c * applyTransform.b + local_38 * applyTransform.d;
    _objc_msgSend(pvVar1,sel_setAffineTransform_withLayoutGuidingContext_,
                  CONCAT44(fStack_28,local_2c),CONCAT44(fStack_20,local_24),
                  CONCAT44(fStack_18,local_1c),0);
  }
  return;
}

*/
+ (void)applyTransform:(CGAffineTransform)aTransform toTransformableObject:(id)aObject
{
    id applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier != nil) {
        CGAffineTransform current = [[applier mutableGeometryAttributes] affineTransform];
        [applier setAffineTransform:CGAffineTransformConcat(current, aTransform) withLayoutGuidingContext:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e800 @ 0001e800, 129 bytes * /

void FUN_0001e800(id self,SEL _cmd,CGAffineTransform applyTransform,id toBitmapTool)

{
  id self_00;
  
  self_00 = _objc_msgSend(toBitmapTool,sel_bitmapTool);
  _objc_msgSend(self_00,sel_finalizeSelection_,0);
  _objc_msgSend(self_00,sel_posttransformSelectionUsingAffineTransform_flippingHorizontally_,
                applyTransform._0_8_,applyTransform._8_8_,applyTransform._16_8_,0);
  return;
}

*/
+ (void)applyTransform:(CGAffineTransform)aTransform toBitmapTool:(id)aTool
{
    id bitmapTool = [aTool bitmapTool];
    [bitmapTool finalizeSelection:nil];
    [bitmapTool posttransformSelectionUsingAffineTransform:aTransform flippingHorizontally:NO];
}

+ (void)scaleTransformableObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] resizeFrameBy:NSMakeSize(aBy, aBy) aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}

+ (void)scaleBitmapTool:(id)aTool aboutCenterBy:(CGFloat)aBy
{
    id self_00;

    self_00 = [aTool bitmapTool];
    [self_00 finalizeSelection:nil];
    [self_00 scaleSelectionAboutCenterBy:NSMakeSize(aBy, aBy)];
}

+ (void)rotateTransformableObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] rotateBy:-aBy aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}

+ (void)rotateBitmapTool:(id)aTool aboutCenterBy:(CGFloat)aBy
{
    id self_00;

    self_00 = [aTool bitmapTool];
    [self_00 finalizeSelection:nil];
    [self_00 rotateSelectionAboutCenterBy:aBy];
}

+ (id)localizedMenuTitleForCardsPasteBoardType:(id)aType
{
    id self_00;
    id pvVar1_2;
    NSUInteger pvVar1_3;
    NSString *pcVar2_2;
    id pcVar2_3;

    pvVar1_2 = [[aType propertyListForType:@"HSCardPasteboardType"] objectForKey:@"HSSerializedCardsKey"];
    if (pvVar1_2 == nil) {
        pcVar2_2 = NULL;
    }
    else {
        pvVar1_3 = [pvVar1_2 count];
        self_00 = [HSExecutableResourceProvider sharedInstance];
        if (pvVar1_3 < 0x2) {
            pcVar2_3 = @"HSPasteCard";
        }
        else {
            pcVar2_3 = @"HSPasteCards";
        }
        pcVar2_2 = [self_00 localizedStringForKey:pcVar2_3 value:@"" table:@"Editor"];
    }
    if (pcVar2_2 == NULL) {
        pcVar2_2 = @"";
    }
    return pcVar2_2;
}

+ (void)validateToolbarVisibility:(id)aVisibility
{
    [aVisibility setVisible:[[[HSUI sharedUI] settingsForKey:HSUIModeIsToolbarShown] boolValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001fe62 @ 0001fe62, 1507 bytes * /

void FUN_0001fe62(id self,SEL _cmd,id scaleObject,float aboutCenterBy,float rotateAboutCenterBy)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  float extraout_EDX;
  cfstringStruct *pcVar5;
  longdouble lVar6;
  longdouble lVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  undefined8 in_stack_ffffff8c;
  undefined4 uVar14;
  undefined8 uVar12;
  ulonglong uVar13;
  undefined8 in_stack_ffffff94;
  undefined4 uVar16;
  undefined8 uVar15;
  float local_44;
  id local_40;
  undefined *local_34;
  undefined4 local_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  uVar16 = (undefined4)((ulonglong)in_stack_ffffff94 >> 0x20);
  uVar14 = (undefined4)((ulonglong)in_stack_ffffff8c >> 0x20);
  pvVar2 = _objc_msgSend(self,sel_isValidSelectionTool_,scaleObject);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_isValidTransformableObject_,scaleObject);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(scaleObject,sel_queryHyperInterface_,&DAT_00361970);
      local_40 = *(id *)PTR_0033607c;
      local_44 = *(float *)(PTR_0033607c + 4);
      if (pvVar2 == (id)0x0) {
        uVar13 = CONCAT44(uVar14,sel_image);
        pvVar2 = _objc_msgSend(scaleObject,sel_respondsToSelector_,sel_image);
        if (((char)pvVar2 != '\0') &&
           (pvVar2 = _objc_msgSend(scaleObject,sel_image,uVar13), pcVar4 = sel_size,
           pvVar2 != (id)0x0)) goto LAB_00020286;
      }
      else {
        local_34 = &DAT_003619ac;
        local_30 = 0;
        uVar13 = ZEXT48(&local_34);
        pvVar2 = _objc_msgSend(pvVar2,sel_queryImageWithRequiredProtocols_optionalProtocols_,
                               &local_34,0);
        pcVar4 = sel_imageSize;
        if (pvVar2 == (id)0x0) {
          return;
        }
LAB_00020286:
        local_40 = _objc_msgSend(pvVar2,pcVar4,uVar13);
        local_44 = extraout_EDX;
      }
      if ((float)local_40 == 0.0) {
        return;
      }
      if (local_44 == 0.0) {
        return;
      }
      lVar6 = (longdouble)_sinf(rotateAboutCenterBy);
      lVar7 = (longdouble)_cosf(rotateAboutCenterBy);
      fVar8 = (float)lVar7;
      fVar9 = (float)lVar6;
      local_2c = fVar8 * aboutCenterBy;
      local_44 = local_44 * 0.5;
      fVar1 = local_44 * (1.0 - aboutCenterBy);
      fStack_28 = fVar9 * aboutCenterBy;
      fVar11 = (float)local_40 * 0.5;
      fVar10 = fVar11 * (1.0 - aboutCenterBy);
      local_24 = -fVar9 * aboutCenterBy;
      local_1c = (1.0 - fVar8) * fVar11 + fVar9 * local_44 + (fVar10 * fVar8 - fVar1 * fVar9);
      fStack_18 = (local_44 * (1.0 - fVar8) - fVar11 * fVar9) + fVar1 * fVar8 + fVar10 * fVar9;
      uVar12 = CONCAT44(fStack_28,local_2c);
      pcVar4 = sel_setTransform_toImageOfObject_;
      fStack_20 = local_2c;
      goto LAB_0001fed1;
    }
    pvVar2 = _objc_msgSend(scaleObject,sel_queryHyperInterface_,&DAT_00361240);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperObject);
    uVar12 = CONCAT44(uVar14,&DAT_003624ec);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003624ec);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar12);
      uVar15 = CONCAT44(uVar16,&cfstr_UndoManager);
      uVar12 = 0x33767c00337fdc;
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Scale___Rotate,
                             &cfstr_empty,&cfstr_UndoManager);
      if ((aboutCenterBy != 0.0) || (NAN(aboutCenterBy))) {
        fVar8 = ABS(aboutCenterBy);
      }
      else {
        fVar8 = 1.0;
      }
      fVar9 = 1.0;
      fVar10 = fVar9;
      if (1.0 <= fVar8) {
        fVar10 = fVar8;
      }
      if (fVar10 * 0.0005 < ABS(aboutCenterBy + -1.0)) {
LAB_000200a1:
        if ((aboutCenterBy != 0.0) || (fVar8 = fVar9, NAN(aboutCenterBy))) {
          fVar8 = ABS(aboutCenterBy);
        }
        if (1.0 <= fVar8) {
          fVar9 = fVar8;
        }
        if (fVar9 * 0.0005 < ABS(aboutCenterBy + -1.0)) {
          if ((rotateAboutCenterBy != 0.0) || (NAN(rotateAboutCenterBy))) {
            fVar8 = ABS(rotateAboutCenterBy);
          }
          else {
            fVar8 = 1.0;
          }
          fVar9 = 0.0005;
          if (1.0 <= fVar8) {
            fVar9 = fVar8 * 0.0005;
          }
          if (ABS(rotateAboutCenterBy) <= fVar9) {
            pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar12,uVar15);
            uVar14 = (undefined4)((ulonglong)uVar15 >> 0x20);
            pcVar5 = &cfstr_Scale;
            goto LAB_0002016b;
          }
        }
      }
      else {
        if ((rotateAboutCenterBy != 0.0) || (NAN(rotateAboutCenterBy))) {
          fVar8 = ABS(rotateAboutCenterBy);
        }
        else {
          fVar8 = 1.0;
        }
        fVar10 = 0.0005;
        if (1.0 <= fVar8) {
          fVar10 = fVar8 * 0.0005;
        }
        if (ABS(rotateAboutCenterBy) <= fVar10) goto LAB_000200a1;
        pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar12,uVar15);
        uVar14 = (undefined4)((ulonglong)uVar15 >> 0x20);
        pcVar5 = &cfstr_Rotate;
LAB_0002016b:
        uVar15 = CONCAT44(uVar14,&cfstr_UndoManager);
        uVar12 = CONCAT44(&cfstr_empty,pcVar5);
        pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                               uVar15);
      }
      _objc_msgSend(pvVar2,sel_setMultipleActionsName_,pvVar3,(int)((ulonglong)uVar12 >> 0x20),
                    uVar15);
    }
    _objc_msgSend(self,sel_scaleTransformableObject_aboutCenterBy_,scaleObject,aboutCenterBy);
    pcVar4 = sel_rotateTransformableObject_aboutCenterBy_;
  }
  else {
    _objc_msgSend(self,sel_scaleBitmapTool_aboutCenterBy_,scaleObject,aboutCenterBy);
    pcVar4 = sel_rotateBitmapTool_aboutCenterBy_;
  }
  uVar12 = CONCAT44(rotateAboutCenterBy,scaleObject);
LAB_0001fed1:
  _objc_msgSend(self,pcVar4,uVar12);
  return;
}

*/
+ (void)scaleObject:(id)aObject aboutCenterBy:(CGFloat)aBy rotateAboutCenterBy:(CGFloat)aBy2
{
    float scale = (float)aBy;
    float rotation = (float)aBy2;
    if ([self isValidSelectionTool:aObject]) {
        [self scaleBitmapTool:aObject aboutCenterBy:aBy];
        [self rotateBitmapTool:aObject aboutCenterBy:aBy2];
        return;
    }
    if (![self isValidTransformableObject:aObject]) {
        NSSize imageSize = NSZeroSize;
        id editable = [aObject queryHyperInterface:@protocol(HSEditableImageAttributes)];
        if (editable == nil) {
            if ([aObject respondsToSelector:@selector(image)]) {
                id image = [aObject image];
                if (image != nil) {
                    imageSize = [image size];
                }
            }
        } else {
            id requiredProtocols[2] = { @protocol(BTCGImage), nil };
            id image = [editable queryImageWithRequiredProtocols:requiredProtocols optionalProtocols:NULL];
            if (image == nil) {
                return;
            }
            imageSize = [image imageSize];
        }
        if (imageSize.width == 0.0f || imageSize.height == 0.0f) {
            return;
        }
        float sine = sinf(rotation);
        float cosine = cosf(rotation);
        float halfHeight = imageSize.height * 0.5f;
        float halfWidth = imageSize.width * 0.5f;
        float scaledOffsetY = halfHeight * (1.0f - scale);
        float scaledOffsetX = halfWidth * (1.0f - scale);
        CGAffineTransform transform = CGAffineTransformMake(cosine * scale, sine * scale, -sine * scale, cosine * scale,
                                                            (1.0f - cosine) * halfWidth + sine * halfHeight + (scaledOffsetX * cosine - scaledOffsetY * sine),
                                                            (halfHeight * (1.0f - cosine) - halfWidth * sine) + scaledOffsetY * cosine + scaledOffsetX * sine);
        [self setTransform:transform toImageOfObject:aObject];
        return;
    }
    NSUndoManager *undoManager = [[[[aObject queryHyperInterface:@protocol(HyperInterface)] hyperObject] queryHyperInterface:@protocol(HSNodeSupport)] undoManager];
    if (undoManager != nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *name = [bundle localizedStringForKey:@"Scale & Rotate" value:@"" table:@"UndoManager"];
        BOOL scaleChanged = fabsf(scale - 1.0f) > MAX((scale != 0.0f || isnan(scale)) ? fabsf(scale) : 1.0f, 1.0f) * 0.0005f;
        BOOL rotationChanged = fabsf(rotation) > (((rotation != 0.0f || isnan(rotation)) ? fabsf(rotation) : 1.0f) >= 1.0f ? fabsf(rotation) * 0.0005f : 0.0005f);
        if (scaleChanged && !rotationChanged) {
            name = [bundle localizedStringForKey:@"Scale" value:@"" table:@"UndoManager"];
        } else if (!scaleChanged && rotationChanged) {
            name = [bundle localizedStringForKey:@"Rotate" value:@"" table:@"UndoManager"];
        }
        [undoManager setMultipleActionsName:name];
    }
    [self scaleTransformableObject:aObject aboutCenterBy:aBy];
    [self rotateTransformableObject:aObject aboutCenterBy:aBy2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e2e2 @ 0001e2e2, 508 bytes * /

void FUN_0001e2e2(id self,SEL _cmd,id scaleObject,float aboutCenterBy)

{
  id pvVar1;
  SEL pcVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar3;
  undefined8 in_stack_ffffffac;
  undefined4 uVar6;
  ulonglong uVar4;
  undefined8 uVar5;
  undefined *local_34;
  undefined4 local_30;
  float local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  uVar6 = (undefined4)((ulonglong)in_stack_ffffffac >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,scaleObject);
  pcVar2 = sel_scaleBitmapTool_aboutCenterBy_;
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_isValidTransformableObject_,scaleObject),
     pcVar2 = sel_scaleTransformableObject_aboutCenterBy_, (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(scaleObject,sel_queryHyperInterface_,&DAT_00361970);
    if (pvVar1 == (id)0x0) {
      uVar5 = CONCAT44(uVar6,sel_image);
      pvVar1 = _objc_msgSend(scaleObject,sel_respondsToSelector_,sel_image);
      if ((char)pvVar1 == '\0') {
        return;
      }
      pvVar1 = _objc_msgSend(scaleObject,sel_image,uVar5);
      if (pvVar1 == (id)0x0) {
        return;
      }
      _objc_msgSend(pvVar1,sel_size,uVar5);
      pcVar2 = sel_size;
      fVar3 = extraout_EDX_00;
    }
    else {
      local_34 = &DAT_003619ac;
      local_30 = 0;
      uVar4 = ZEXT48(&local_34);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryImageWithRequiredProtocols_optionalProtocols_,&local_34
                             ,0);
      if (pvVar1 == (id)0x0) {
        return;
      }
      _objc_msgSend(pvVar1,sel_imageSize,uVar4);
      pcVar2 = sel_imageSize;
      fVar3 = extraout_EDX;
    }
    pvVar1 = _objc_msgSend(pvVar1,pcVar2);
    local_2c = aboutCenterBy;
    uStack_28 = 0;
    local_24 = 0;
    local_1c = (float)pvVar1 * 0.5 * (1.0 - aboutCenterBy);
    fStack_18 = fVar3 * 0.5 * (1.0 - aboutCenterBy);
    uVar4 = (ulonglong)(uint)aboutCenterBy;
    pcVar2 = sel_setTransform_toImageOfObject_;
    fStack_20 = local_2c;
  }
  else {
    uVar4 = CONCAT44(aboutCenterBy,scaleObject);
  }
  _objc_msgSend(self,pcVar2,uVar4);
  return;
}

*/
+ (void)scaleObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    if ([self isValidSelectionTool:aObject]) {
        [self scaleBitmapTool:aObject aboutCenterBy:aBy];
        return;
    }
    if ([self isValidTransformableObject:aObject]) {
        [self scaleTransformableObject:aObject aboutCenterBy:aBy];
        return;
    }
    NSSize imageSize;
    id editable = [aObject queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editable == nil) {
        if (![aObject respondsToSelector:@selector(image)]) {
            return;
        }
        id image = [aObject image];
        if (image == nil) {
            return;
        }
        imageSize = [image size];
    } else {
        id requiredProtocols[2] = { @protocol(BTCGImage), nil };
        id image = [editable queryImageWithRequiredProtocols:requiredProtocols optionalProtocols:NULL];
        if (image == nil) {
            return;
        }
        imageSize = [image imageSize];
    }
    float scale = (float)aBy;
    CGAffineTransform transform = CGAffineTransformMake(scale, 0, 0, scale, imageSize.width * 0.5f * (1.0f - scale), imageSize.height * 0.5f * (1.0f - scale));
    [self setTransform:transform toImageOfObject:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00020445 @ 00020445, 584 bytes * /

void FUN_00020445(id self,SEL _cmd,id rotateObject,float aboutCenterBy)

{
  id pvVar1;
  SEL pcVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar3;
  longdouble lVar4;
  longdouble lVar5;
  undefined8 in_stack_ffffff9c;
  undefined4 uVar8;
  undefined8 uVar6;
  ulonglong uVar7;
  undefined *local_34;
  undefined4 local_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  uVar8 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,rotateObject);
  pcVar2 = sel_rotateBitmapTool_aboutCenterBy_;
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(self,sel_isValidTransformableObject_,rotateObject),
     pcVar2 = sel_rotateTransformableObject_aboutCenterBy_, (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(rotateObject,sel_queryHyperInterface_,&DAT_00361970);
    if (pvVar1 == (id)0x0) {
      uVar6 = CONCAT44(uVar8,sel_image);
      pvVar1 = _objc_msgSend(rotateObject,sel_respondsToSelector_,sel_image);
      if ((char)pvVar1 == '\0') {
        return;
      }
      pvVar1 = _objc_msgSend(rotateObject,sel_image,uVar6);
      if (pvVar1 == (id)0x0) {
        return;
      }
      _objc_msgSend(pvVar1,sel_size,uVar6);
      pcVar2 = sel_size;
      fVar3 = extraout_EDX_00;
    }
    else {
      local_34 = &DAT_003619ac;
      local_30 = 0;
      uVar7 = ZEXT48(&local_34);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryImageWithRequiredProtocols_optionalProtocols_,&local_34
                             ,0);
      if (pvVar1 == (id)0x0) {
        return;
      }
      _objc_msgSend(pvVar1,sel_imageSize,uVar7);
      pcVar2 = sel_imageSize;
      fVar3 = extraout_EDX;
    }
    pvVar1 = _objc_msgSend(pvVar1,pcVar2);
    lVar4 = (longdouble)_sinf(aboutCenterBy);
    lVar5 = (longdouble)_cosf(aboutCenterBy);
    local_2c = (float)lVar5;
    fStack_28 = (float)lVar4;
    local_24 = -fStack_28;
    local_1c = (1.0 - local_2c) * (float)pvVar1 * 0.5 + fStack_28 * fVar3 * 0.5;
    fStack_18 = (1.0 - local_2c) * fVar3 * 0.5 - (float)pvVar1 * 0.5 * fStack_28;
    uVar6 = CONCAT44(fStack_28,local_2c);
    pcVar2 = sel_setTransform_toImageOfObject_;
    fStack_20 = local_2c;
  }
  else {
    uVar6 = CONCAT44(aboutCenterBy,rotateObject);
  }
  _objc_msgSend(self,pcVar2,uVar6);
  return;
}

*/
+ (void)rotateObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    if ([self isValidSelectionTool:aObject]) {
        [self rotateBitmapTool:aObject aboutCenterBy:aBy];
        return;
    }
    if ([self isValidTransformableObject:aObject]) {
        [self rotateTransformableObject:aObject aboutCenterBy:aBy];
        return;
    }
    NSSize imageSize;
    id editable = [aObject queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editable == nil) {
        if (![aObject respondsToSelector:@selector(image)]) {
            return;
        }
        id image = [aObject image];
        if (image == nil) {
            return;
        }
        imageSize = [image size];
    } else {
        id requiredProtocols[2] = { @protocol(BTCGImage), nil };
        id image = [editable queryImageWithRequiredProtocols:requiredProtocols optionalProtocols:NULL];
        if (image == nil) {
            return;
        }
        imageSize = [image imageSize];
    }
    float angle = (float)aBy;
    float sine = sinf(angle);
    float cosine = cosf(angle);
    CGAffineTransform transform = CGAffineTransformMake(cosine, sine, -sine, cosine,
                                                        (1.0f - cosine) * imageSize.width * 0.5f + sine * imageSize.height * 0.5f,
                                                        (1.0f - cosine) * imageSize.height * 0.5f - imageSize.width * 0.5f * sine);
    [self setTransform:transform toImageOfObject:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e1f2 @ 0001e1f2, 240 bytes * /

BOOL FUN_0001e1f2(id self,SEL _cmd,id canResizeObject)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,canResizeObject);
  cVar3 = (char)pvVar1;
  if (cVar3 == '\0') {
    puVar4 = &DAT_003620c8;
    pvVar1 = _objc_msgSend(canResizeObject,sel_queryHyperInterface_,&DAT_003620c8);
    pvVar2 = _objc_msgSend(pvVar1,sel_canResizeHorizontally);
    if ((((char)pvVar2 == '\0') &&
        (pvVar2 = _objc_msgSend(pvVar1,sel_canScaleHorizontally,puVar4), (char)pvVar2 == '\0')) ||
       ((pvVar2 = _objc_msgSend(pvVar1,sel_canResizeVertically,puVar4), (char)pvVar2 == '\0' &&
        (pvVar1 = _objc_msgSend(pvVar1,sel_canScaleVertically,puVar4), (char)pvVar1 == '\0')))) {
      cVar3 = '\0';
    }
    else {
      pvVar1 = _objc_msgSend(canResizeObject,sel_queryHyperInterface_,&DAT_003612cc);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      cVar3 = (char)pvVar1 == '\0';
    }
  }
  return cVar3;
}

*/
+ (BOOL)canResizeObject:(id)aObject
{
    BOOL result = [self isValidSelectionTool:aObject];
    if (!result) {
        id geometry = [aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
        if ((![geometry canResizeHorizontally] && ![geometry canScaleHorizontally]) || (![geometry canResizeVertically] && ![geometry canScaleVertically])) {
            result = NO;
        } else {
            result = ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e148 @ 0001e148, 170 bytes * /

BOOL FUN_0001e148(id self,SEL _cmd,id canRotateObject)

{
  id pvVar1;
  char cVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,canRotateObject);
  cVar2 = (char)pvVar1;
  if (cVar2 == '\0') {
    puVar3 = &DAT_003620c8;
    pvVar1 = _objc_msgSend(canRotateObject,sel_queryHyperInterface_,&DAT_003620c8);
    if ((pvVar1 == (id)0x0) ||
       (pvVar1 = _objc_msgSend(pvVar1,sel_canRotate,puVar3), (char)pvVar1 == '\0')) {
      cVar2 = '\0';
    }
    else {
      pvVar1 = _objc_msgSend(canRotateObject,sel_queryHyperInterface_,&DAT_003612cc);
      pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
      cVar2 = (char)pvVar1 == '\0';
    }
  }
  return cVar2;
}

*/
+ (BOOL)canRotateObject:(id)aObject
{
    BOOL result = [self isValidSelectionTool:aObject];
    if (!result) {
        id geometry = [aObject queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
        if (geometry == nil || ![geometry canRotate]) {
            result = NO;
        } else {
            result = ![[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001e088 @ 0001e088, 192 bytes * /

BOOL FUN_0001e088(id self,SEL _cmd,id canTransformObject)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,canTransformObject);
  if (((((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_isValidTransformableObject_,canTransformObject),
       (char)pvVar1 == '\0')) &&
      (pvVar1 = _objc_msgSend(canTransformObject,sel_implementsHyperInterface_,&DAT_00361f38),
      (char)pvVar1 == '\0')) &&
     (pvVar1 = _objc_msgSend(canTransformObject,sel_implementsHyperInterface_,&DAT_00361f4c),
     (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(canTransformObject,sel_implementsHyperInterface_,&DAT_00361970);
    return (char)pvVar1 != '\0';
  }
  return '\x01';
}

*/
+ (BOOL)canTransformObject:(id)aObject
{
    return [self isValidSelectionTool:aObject]
        || [self isValidTransformableObject:aObject]
        || [aObject implementsHyperInterface:@protocol(HSImageMutableAttributes)]
        || [aObject implementsHyperInterface:@protocol(HSSystemSquareButtonAttributes)]
        || [aObject implementsHyperInterface:@protocol(HSEditableImageAttributes)];
}

+ (BOOL)isValidTransformableObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSMutableGeometryAttributes)];
}

+ (BOOL)isValidSelectionTool:(id)aTool
{
    BOOL bVar3;

    if (![self isSelectionTool:aTool]) {
        bVar3 = NO;
    }
    else {
        bVar3 = [self isValidSelectionBitmapTool:[aTool bitmapTool]];
    }
    return bVar3;
}

+ (BOOL)isSelectionBitmapToolHasValidEditableImage:(id)aImage validateImage:(BOOL)aImage2
{
    id pvVar1;
    id self_00;

    pvVar1 = [aImage inputKeys];
    self_00 = [aImage outputKeys];
    if ([pvVar1 containsObject:@"imageSelection"]) {
        if ([self_00 containsObject:@"selectionPath"]) {
            if (aImage2 == NO) {
                return YES;
            }
            return [aImage selectionPath] != nil;
        }
    }
    return NO;
}

+ (BOOL)isSelectionBitmapToolHasValidEditablePath:(id)aPath validatePath:(BOOL)aPath2
{
    char cVar2;

    cVar2 = [[aPath inputKeys] containsObject:@"selectionPath"];
    if ((cVar2 != NO) && (aPath2 != NO)) {
        cVar2 = [aPath selectionPath] != nil;
    }
    return cVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001dd88 @ 0001dd88, 321 bytes * /

void FUN_0001dd88(id self,SEL _cmd,CGAffineTransform setTransform,id toObject)

{
  id pvVar1;
  SEL op;
  undefined8 in_stack_ffffffcc;
  undefined8 uVar2;
  
  uVar2 = CONCAT44((int)((ulonglong)in_stack_ffffffcc >> 0x20),toObject);
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,toObject);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_isValidTransformableObject_,toObject);
    op = sel_setTransform_toImageOfObject_;
    if (((char)pvVar1 != '\0') &&
       (self = _objc_msgSend(toObject,sel_queryHyperInterface_,&DAT_00361f24),
       op = sel_setAffineTransform_, self == (id)0x0)) {
      return;
    }
  }
  else {
    self = _objc_msgSend(toObject,sel_bitmapTool,uVar2);
    _objc_msgSend(self,sel_finalizeSelection_,0);
    op = sel_setSelectionAffineTransform_flippingHorizontally_;
  }
  _objc_msgSend(self,op,setTransform._0_8_,setTransform._8_8_,setTransform._16_8_);
  return;
}

*/
+ (void)setTransform:(CGAffineTransform)aTransform toObject:(id)aObject
{
    if ([self isValidSelectionTool:aObject]) {
        id bitmapTool = [aObject bitmapTool];
        [bitmapTool finalizeSelection:nil];
        [bitmapTool setSelectionAffineTransform:aTransform flippingHorizontally:NO];
    } else if ([self isValidTransformableObject:aObject]) {
        id geometry = [aObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
        if (geometry != nil) {
            [geometry setAffineTransform:aTransform];
        }
    } else {
        [self setTransform:aTransform toImageOfObject:aObject];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001dcba @ 0001dcba, 206 bytes * /

void FUN_0001dcba(id self,SEL _cmd,CGAffineTransform applyTransform,id toObject)

{
  id pvVar1;
  SEL pcVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isValidSelectionTool_,toObject);
  pcVar2 = sel_applyTransform_toBitmapTool_;
  if (((char)pvVar1 != '\0') ||
     (pvVar1 = _objc_msgSend(self,sel_isValidTransformableObject_,toObject),
     pcVar2 = sel_applyTransform_toTransformableObject_, op = sel_setTransform_toImageOfObject_,
     (char)pvVar1 != '\0')) {
    op = pcVar2;
  }
  _objc_msgSend(self,op,applyTransform._0_8_,applyTransform._8_8_,applyTransform._16_8_,toObject);
  return;
}

*/
+ (void)applyTransform:(CGAffineTransform)aTransform toObject:(id)aObject
{
    if ([self isValidSelectionTool:aObject]) {
        [self applyTransform:aTransform toBitmapTool:aObject];
    } else if ([self isValidTransformableObject:aObject]) {
        [self applyTransform:aTransform toTransformableObject:aObject];
    } else {
        [self setTransform:aTransform toImageOfObject:aObject];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001dc2c @ 0001dc2c, 142 bytes * /

void FUN_0001dc2c(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  if (DAT_00342780 == '\0') {
    pvVar1 = _objc_msgSend(cls_NSArray,sel_array);
    pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_00336154,0);
    _objc_msgSend(*(id *)PTR_00336058,sel_registerServicesMenuSendTypes_returnTypes_,pvVar1,pvVar2);
    DAT_00342780 = '\x01';
  }
  return;
}

*/
+ (void)initialize
{
    static BOOL servicesRegistered = NO;
    if (!servicesRegistered) {
        [NSApp registerServicesMenuSendTypes:[NSArray array] returnTypes:[NSArray arrayWithObjects:NSTIFFPboardType, nil]];
        servicesRegistered = YES;
    }
}

- (void)updateAllButtonStyles:(id)aStyles
{
    id pvVar3;
    id pvVar1_3;
    id pvVar3_2;

    pvVar1_3 = [[[self document] stack] hyperDeepEnumerator];
    while( YES ) {
        pvVar3 = [pvVar1_3 nextObject];
        if (pvVar3 == nil) break;
        pvVar3_2 = [pvVar3 queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
        if ([pvVar3_2 canButtonStyleBeUpdated]) {
            [pvVar3_2 updateButtonObjectStyle];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001daae @ 0001daae, 206 bytes * /

BOOL FUN_0001daae(HSEditorWindowController *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_typeOfAcceptedFile);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperDeepEnumerator);
    do {
      pvVar3 = _objc_msgSend(pvVar2,sel_nextObject);
      if (pvVar3 == (id)0x0) goto LAB_0001dae8;
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00361e98);
      pvVar3 = _objc_msgSend(pvVar3,sel_canButtonStyleBeUpdated);
    } while ((char)pvVar3 == '\0');
    BVar1 = '\x01';
  }
  else {
LAB_0001dae8:
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isThereButtonStylesToUpdate
{
    if ([[self document] typeOfAcceptedFile] == nil) {
        NSEnumerator *enumerator = [[[self document] stack] hyperDeepEnumerator];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            if ([[object queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] canButtonStyleBeUpdated]) {
                return YES;
            }
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002068d @ 0002068d, 553 bytes * /

ulonglong FUN_0002068d(HSEditorWindowController *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  int *piVar2;
  undefined4 local_94;
  id local_64;
  float local_60;
  HSEditorWindowController *local_5c;
  undefined *local_58;
  undefined1 local_54 [16];
  undefined1 local_44 [8];
  float local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined1 local_24 [12];
  float local_18;
  
  local_5c = self;
  local_58 = PTR_s_HSMainWindowController_0034dbd0;
  local_64 = _objc_msgSendSuper(&local_5c,sel_mainWindowMinCardAreaSize);
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_isMultiDocument);
  if ((char)pvVar1 == '\0') {
LAB_0002072f:
    pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    pvVar1 = _objc_msgSend(pvVar1,sel_isMultiDocument);
    piVar2 = (int *)&stack0xffffff74;
    if ((char)pvVar1 != '\0') goto LAB_00020818;
    pvVar1 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    pvVar1 = _objc_msgSend(pvVar1,sel_settingsForKey_);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    piVar2 = (int *)&stack0xffffff74;
    if ((char)pvVar1 == '\0') goto LAB_00020818;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_stackController);
    pvVar1 = _objc_msgSend(pvVar1,sel_isStripVisible);
    if ((char)pvVar1 == '\0') goto LAB_0002072f;
  }
  pvVar1 = self->_canisterContainerView;
  _objc_msgSend_stret(local_54,pvVar1,sel_bounds);
  local_94 = 0x20806;
  _objc_msgSend_stret(local_44,pvVar1,sel_convertRect_toView_);
  piVar2 = &local_94;
  local_64 = (id)((float)local_64 + local_3c);
LAB_00020818:
  piVar2[1] = (int)sel_isBottomToolbarVisible;
  *piVar2 = (int)self;
  piVar2[-1] = 0x2082d;
  pvVar1 = _objc_msgSend((id)*piVar2,(SEL)piVar2[1]);
  local_60 = extraout_EDX;
  if ((char)pvVar1 != '\0') {
    pvVar1 = self->_bottomAreaTintedView;
    piVar2[2] = (int)sel_bounds;
    piVar2[1] = (int)pvVar1;
    *piVar2 = (int)&local_34;
    piVar2[-1] = 0x20850;
    _objc_msgSend_stret((void *)*piVar2,(id)piVar2[1],(SEL)piVar2[2]);
    *(undefined8 *)(piVar2 + 4) = local_2c;
    *(undefined8 *)(piVar2 + 2) = local_34;
    piVar2[1] = (int)sel_convertRect_toView_;
    *piVar2 = (int)pvVar1;
    piVar2[-1] = (int)local_24;
    piVar2[6] = 0;
    piVar2[-2] = 0x2088a;
    _objc_msgSend_stret((void *)piVar2[-1],(id)*piVar2,(SEL)piVar2[1]);
    local_60 = extraout_EDX + local_18;
  }
  return CONCAT44(local_60,local_64);
}

*/
- (NSSize)mainWindowMinCardAreaSize
{
    NSSize size = [super mainWindowMinCardAreaSize];
    BOOL addCanister;
    if ([[HSEditorController sharedDocumentController] isMultiDocument]) {
        addCanister = [[self stackController] isStripVisible];
    } else {
        addCanister = [[[HSUI sharedUI] settingsForKey:HSUIModeIsCardIndexShown] boolValue];
    }
    if (addCanister) {
        NSRect canisterRect = [_canisterContainerView convertRect:[_canisterContainerView bounds] toView:nil];
        size.width += canisterRect.size.width;
    }
    if ([self isBottomToolbarVisible]) {
        NSRect bottomRect = [_bottomAreaTintedView convertRect:[_bottomAreaTintedView bounds] toView:nil];
        size.height += bottomRect.size.height;
    }
    return size;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000208b6 @ 000208b6, 557 bytes * /

ulonglong FUN_000208b6(HSEditorWindowController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  float fVar3;
  id pvVar4;
  id pvVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  double dVar6;
  float local_4c;
  undefined1 local_44 [8];
  ulonglong local_3c;
  undefined4 local_34;
  float local_30;
  float local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  id local_1c;
  float fStack_18;
  
  pvVar4 = _objc_msgSend(self,sel_document);
  pvVar4 = _objc_msgSend(pvVar4,sel_currentCard);
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_003614fc);
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  local_1c = _objc_msgSend(pvVar4,sel_size);
  local_24 = uVar1;
  uStack_20 = uVar2;
  fStack_18 = extraout_EDX;
  pvVar4 = _objc_msgSend(self,sel_cardView);
  dVar6 = _objc_msgSend_fpret(pvVar4,sel_zoomFactor);
  fVar3 = (float)dVar6;
  if (1.0 < fVar3) {
    local_1c = (id)((float)local_1c * fVar3);
    fStack_18 = fVar3 * fStack_18;
  }
  pvVar4 = _objc_msgSend(self,sel_mainWindowMinCardAreaSize);
  if ((float)local_1c < (float)pvVar4) {
    local_1c = pvVar4;
  }
  if (fStack_18 < extraout_EDX_00) {
    fStack_18 = extraout_EDX_00;
  }
  pvVar4 = _objc_msgSend(self,sel_cardView);
  pvVar4 = _objc_msgSend(pvVar4,sel_enclosingScrollView);
  _objc_msgSend_stret(&local_34,pvVar4,sel_bounds);
  local_4c = local_30;
  pvVar5 = _objc_msgSend(pvVar4,sel_isFlipped);
  if ((char)pvVar5 != '\0') {
    local_4c = local_30 + local_28;
  }
  pvVar4 = _objc_msgSend(pvVar4,sel_convertPoint_toView_,local_34,local_4c,0);
  local_1c = (id)((float)pvVar4 + (float)local_1c);
  fStack_18 = extraout_EDX_01 + fStack_18;
  pvVar4 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(local_44,pvVar4,sel_frameRectForContentRect_,CONCAT44(uStack_20,local_24),
                      CONCAT44(fStack_18,local_1c));
  return local_3c;
}

*/
- (NSSize)windowFrameSizeAdjustedToCurrentContent
{
    NSSize size = [[[[self document] currentCard] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    float zoom = [[self cardView] zoomFactor];
    if (zoom > 1.0f) {
        size.width *= zoom;
        size.height *= zoom;
    }
    NSSize minimumSize = [self mainWindowMinCardAreaSize];
    if (size.width < minimumSize.width) {
        size.width = minimumSize.width;
    }
    if (size.height < minimumSize.height) {
        size.height = minimumSize.height;
    }
    NSScrollView *scrollView = [[self cardView] enclosingScrollView];
    NSRect bounds = [scrollView bounds];
    float originY = bounds.origin.y;
    if ([scrollView isFlipped]) {
        originY = bounds.origin.y + bounds.size.height;
    }
    NSPoint origin = [scrollView convertPoint:NSMakePoint(bounds.origin.x, originY) toView:nil];
    size.width += origin.x;
    size.height += origin.y;
    return [[self window] frameRectForContentRect:NSMakeRect(0, 0, size.width, size.height)].size;
}

- (void)setWindow:(id)aWindow
{
    [super setWindow:aWindow];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSEditorDidChangeWindowNotification" object:aWindow];
}

- (void)awakeFromImporting
{
    [[self stackView] reloadCards];
}

- (id)stringOfPermittedLengthFromString:(id)aString
{
    return [[self cardView] stringOfPermittedLengthFromString:aString];
}

- (id)textForStatusBarController:(id)aController
{
    NSBundle *pvVar1;
    NSString *pvVar1_2;
    id pvVar1_3;
    id pvVar1_4;
    id pvVar2_3;
    id pvVar2_8;

    pvVar1 = [NSBundle mainBundle];
    pvVar1_2 = [pvVar1 localizedStringForKey:@"Card %u of %u" value:@"" table:0];
    pvVar2_3 = [[[self document] cardView] card];
    if (pvVar2_3 == nil) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_4 = [NSString stringWithFormat:pvVar1_2, (int)[pvVar2_3 hyperIndex] + 1, [[[pvVar2_3 stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperCount]];
        pvVar2_8 = [NSDictionary dictionaryWithObjectsAndKeys:[NSParagraphStyle hyperParagraphStyleWithAlignment:2 lineBreakMode:5], NSParagraphStyleAttributeName, nil];
        pvVar1_3 = [[[NSAttributedString alloc] initWithString:pvVar1_4 attributes:pvVar2_8] autorelease];
    }
    return pvVar1_3;
}

- (id)targetForScalePopUpButton:(id)aButton inStatusbarController:(id)aController
{
    HSEditorCardView *pHVar2;

    pHVar2 = _cardView;
    if ([[self document] isInAnimationMode]) {
        pHVar2 = [[[self document] animationModeController] targetForScalePopUpButton:aButton inStatusbarController:aController];
    }
    return pHVar2;
}

- (void)zoomSliderDidFinishTracking:(id)aTracking inStatusbarController:(id)aController
{
    [_cardView declineDrawingQualityLoss:0.9999];
    [_cardView setNeedsDisplay:YES];
}

- (void)zoomSliderDidStartTracking:(id)aTracking inStatusbarController:(id)aController
{
    [_cardView acceptDrawingQualityLoss:0.9999];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001d6d3 @ 0001d6d3, 137 bytes * /

void FUN_0001d6d3(HSEditorWindowController *self,SEL _cmd,
                 id HSEditorWindowController_modeSwitcherDidEndModeSwitching)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar1 = _objc_msgSend(HSEditorWindowController_modeSwitcherDidEndModeSwitching,sel_object);
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_00336104,pvVar1)
  ;
  _objc_msgSend(self->_statusbarController,sel_validateUI);
  return;
}

*/
- (void)HSEditorWindowController_modeSwitcherDidEndModeSwitching:(id)aSwitching
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:[aSwitching object]];
    [_statusbarController validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00020b5b @ 00020b5b, 964 bytes * /

void FUN_00020b5b(HSEditorWindowController *self,SEL _cmd,id didBecomeWorkingInModeSwitcher)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  HSEditorWindowController *local_1c;
  undefined *local_18;
  
  _objc_msgSend(self,sel_restoreScrollerPosition);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_activate);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar1,sel_window);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar2,sel_firstResponder);
    if (pvVar3 == pvVar2) {
      _objc_msgSend(pvVar2,sel_makeFirstResponder_,pvVar1);
    }
  }
  if (self->_stackSelectionHostWasCurrentBeforeAssistantHide == '\0') {
    pvVar1 = _objc_msgSend(self,sel_cardView);
    op = sel_localNotifyHyperSelectionDidChangeAndActivate_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_stackSelectionHolder);
    op = sel_makeCurrent;
  }
  _objc_msgSend(pvVar1,op);
  pvVar1 = _objc_msgSend(self,sel_selectionController);
  _objc_msgSend(pvVar1,sel_setEnabled_,1);
  pvVar1 = _objc_msgSend(self,sel_documentSelectionSync);
  _objc_msgSend(pvVar1,sel_setEnabled_,1);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar1,sel_navigationController);
  pvVar1 = _objc_msgSend(cls_HSEditorNavigationController,sel_class);
  pvVar2 = _objc_msgSend(pvVar2,sel_isKindOfClass_,pvVar1);
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSEditorNavigationController,sel_alloc,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar1,sel_initWithDocument_,pvVar2);
    pvVar3 = _objc_msgSend(self,sel_document);
    pvVar1 = pvVar2;
    _objc_msgSend(pvVar3,sel_setNavigationController_,pvVar2);
    _objc_msgSend(pvVar2,sel_release);
  }
  pvVar1 = _objc_msgSend(self,sel_stackView,pvVar1);
  _objc_msgSend(pvVar1,sel_reloadCards);
  pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
  pvVar2 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_validateUserInterfaceWithView_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_didFinishSwitchToEditMode);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSDocumentDidActivateObjectListDataProviderNotif,pvVar2);
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_0034dbd0;
  _objc_msgSendSuper(&local_1c,sel_didBecomeWorkingInModeSwitcher_,didBecomeWorkingInModeSwitcher);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar1,sel_activateIfNeeded);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                sel_HSEditorWindowController_modeSwitcherDidEndModeSwitching_,
                *(undefined4 *)PTR_PTR_00336104,didBecomeWorkingInModeSwitcher);
  return;
}

*/
- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [self restoreScrollerPosition];
    [[self cardView] activate];
    id cardView = [self cardView];
    NSWindow *window = [cardView window];
    if (window != nil && [window firstResponder] == window) {
        [window makeFirstResponder:cardView];
    }
    if (_stackSelectionHostWasCurrentBeforeAssistantHide) {
        [[self stackSelectionHolder] makeCurrent];
    } else {
        [[self cardView] localNotifyHyperSelectionDidChangeAndActivate:NO];
    }
    [[self selectionController] setEnabled:YES];
    [[self documentSelectionSync] setEnabled:YES];
    if (![[[self document] navigationController] isKindOfClass:[HSEditorNavigationController class]]) {
        id navigationController = [[HSEditorNavigationController alloc] initWithDocument:[self document]];
        [[self document] setNavigationController:navigationController];
        [navigationController release];
    }
    [[self stackView] reloadCards];
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:[self cardView]];
    [[self document] didFinishSwitchToEditMode];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentDidActivateObjectListDataProviderNotification" object:[self document]];
    [super didBecomeWorkingInModeSwitcher:aSwitcher];
    [[HSObjectAssistantController sharedAssistantController] activateIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorWindowController_modeSwitcherDidEndModeSwitching:) name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:aSwitcher];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00020f1f @ 00020f1f, 1025 bytes * /

void FUN_00020f1f(HSEditorWindowController *self,SEL _cmd,id willBecomeWorkingInModeSwitcher)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  undefined4 uVar4;
  HSEditorWindowController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_0034dbd0;
  _objc_msgSendSuper(&local_1c,sel_willBecomeWorkingInModeSwitcher_,willBecomeWorkingInModeSwitcher)
  ;
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  _objc_msgSend(pvVar1,sel_removeAllTemporaryObjects);
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_enableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setPlayerView_,0);
  _objc_msgSend(self->_statusbarController,sel_validateUI);
  _objc_msgSend(self->_statusbarController,sel_updateScalePopUpButtonTarget);
  pvVar1 = _objc_msgSend(self,sel_selectionController);
  pvVar2 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_setCardView_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_documentSelectionSync);
  pvVar2 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_setCardView_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_documentSelectionSync);
  pvVar2 = _objc_msgSend(self,sel_thisCardSelectionHolder);
  _objc_msgSend(pvVar1,sel_setThisCardSelectionHost_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_documentSelectionSync);
  pvVar2 = _objc_msgSend(self,sel_stackSelectionHolder);
  _objc_msgSend(pvVar1,sel_setStackSelectionHost_,pvVar2);
  pvVar1 = _objc_msgSend(self->_cardView,sel_card);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperIndex);
  if (pvVar1 == (id)0x7fffffff) {
    pvVar1 = _objc_msgSend(self,sel_document,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_stack);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildren);
    pvVar2 = _objc_msgSend(pvVar1,sel_lastObject);
    _objc_msgSend(self->_cardView,sel_setCard_,pvVar2);
  }
  pvVar1 = _objc_msgSend(self,sel_cardView,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_runTimeEditorController);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRunTimeEditorObject);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(pvVar1,sel_updateEmbeddedViewWithEditingObject);
  }
  pvVar1 = self->_statusbarController;
  pvVar2 = _objc_msgSend(self,sel_cardView);
  dVar3 = _objc_msgSend_fpret(pvVar2,sel_zoomFactor);
  _objc_msgSend(pvVar1,sel_setZoomFactor_,(float)dVar3);
  uVar4 = 1;
  _objc_msgSend(self->_statusbarController,sel_setZoomControlsEnabled_,1);
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_replacingDocument);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSSystemUI,sel_sharedSystemUI,uVar4);
    uVar4 = 0;
    _objc_msgSend(pvVar1,sel_setupWithMode_options_,0,0);
  }
  pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance,uVar4);
  _objc_msgSend(pvVar1,sel_setDataProvider_,self);
  return;
}

*/
- (void)willBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecomeWorkingInModeSwitcher:aSwitcher];
    [[[self document] undoManager] disableUndoRegistration];
    [[[self document] stack] removeAllTemporaryObjects];
    [[[self document] undoManager] enableUndoRegistration];
    [[self document] setPlayerView:nil];
    [_statusbarController validateUI];
    [_statusbarController updateScalePopUpButtonTarget];
    [[self selectionController] setCardView:[self cardView]];
    [[self documentSelectionSync] setCardView:[self cardView]];
    [[self documentSelectionSync] setThisCardSelectionHost:[self thisCardSelectionHolder]];
    [[self documentSelectionSync] setStackSelectionHost:[self stackSelectionHolder]];
    if ([[_cardView card] hyperIndex] == 0x7fffffff) {
        [_cardView setCard:[[[[self document] stack] hyperChildren] lastObject]];
    }
    id editor = [[[self cardView] runTimeEditorController] selectedRunTimeEditorObject];
    if (editor != nil) {
        [editor updateEmbeddedViewWithEditingObject];
    }
    [_statusbarController setZoomFactor:[[self cardView] zoomFactor]];
    [_statusbarController setZoomControlsEnabled:YES];
    if (![[HSEditorController sharedDocumentController] replacingDocument]) {
        [[HSSystemUI sharedSystemUI] setupWithMode:0 options:0];
    }
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:self];
}

- (void)didBecomeNonWorkingInModeSwitcher:(id)aSwitcher
{
    [_statusbarController validateUI];
    [_statusbarController updateScalePopUpButtonTarget];
    if (![[self document] isInAnimationMode]) {
        [_statusbarController setZoomControlsEnabled:NO];
    }
    [[self cardView] endLightweightChangeProcessingMode];
    [[self cardView] saveEditingState];
    [[self cardView] deactivateRunTimeEditor];
    [super didBecomeNonWorkingInModeSwitcher:aSwitcher];
}

- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher
{
    [super willBecameNonWorkingInModeSwitcher:aSwitcher];
    [self saveScrollerPosition];
    [[self cardView] deactivate];
    [[self cardView] beginLightweightChangeProcessingMode];
    [[[self toolbarController] toolbar] validateVisibleItems];
    _stackSelectionHostWasCurrentBeforeAssistantHide = [[self documentSelectionSync] currentSelectionHost] == [self stackSelectionHolder];
    [[self selectionController] setCardView:nil];
    [[self documentSelectionSync] setCardView:nil];
    [[self documentSelectionSync] setThisCardSelectionHost:nil];
    [[self documentSelectionSync] setStackSelectionHost:nil];
    [_statusbarController setZoomFactor:1.0];
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:nil];
}

- (void)willResignActiveInModeSwitcher:(id)aSwitcher
{
    [self switchToToolWithTag:1];
    [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
}

- (void)windowControllerDidBindToWindowInModeSwitcher:(id)aSwitcher
{
    if ([self document] != nil) {
        [self didAttachToMainWindow];
        [super windowControllerDidBindToWindowInModeSwitcher:aSwitcher];
    }
}

- (void)windowControllerWillUnbindFromWindowInModeSwitcher:(id)aSwitcher
{
    [self willDetachFromMainWindow];
}

- (id)secondaryModeSwitcherWindows:(id)aWindows
{
    return [[super secondaryModeSwitcherWindows:aWindows] arrayByAddingObjectsFromArray:[HSEditorWindowController palettesArrayIncludingLibrary:YES toolPalette:YES layoutPalette:YES objectListPalette:YES commentsAndAttributionsPalette:YES shortcutsPalette:YES]];
}

- (id)mainModeSwitcherWindow:(id)aWindow
{
    return [self window];
}

- (id)modeSwitcherCardView:(id)aView
{
    return [self cardView];
}

- (BOOL)prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible
{
    return NO;
}

- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding
{
    return YES;
}

- (id)modeSwitcherWindowController:(id)aController
{
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001d547 @ 0001d547, 176 bytes * /

id FUN_0001d547(HSEditorWindowController *self,SEL _cmd,id modeSwitcherView)

{
  HSEditorWindowController *pHVar1;
  id pvVar2;
  
  pHVar1 = _objc_msgSend(modeSwitcherView,sel_previousModeController);
  if (pHVar1 == self) {
    pvVar2 = _objc_msgSend(modeSwitcherView,sel_activeModeController);
    pvVar2 = _objc_msgSend(pvVar2,sel_prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible);
    if ((char)pvVar2 == '\0') goto LAB_0001d59a;
LAB_0001d5e3:
    pvVar2 = _objc_msgSend(self,sel_cardView);
  }
  else {
LAB_0001d59a:
    pvVar2 = _objc_msgSend(modeSwitcherView,sel_previousModeController);
    pvVar2 = _objc_msgSend(pvVar2,sel_prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible);
    if ((char)pvVar2 != '\0') {
      pHVar1 = _objc_msgSend(modeSwitcherView,sel_activeModeController);
      if (pHVar1 == self) goto LAB_0001d5e3;
    }
    pvVar2 = self->_workAreaContainerView;
  }
  return pvVar2;
}

*/
- (id)modeSwitcherView:(id)aView
{
    if ([aView previousModeController] == self && [[aView activeModeController] prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible]) {
        return [self cardView];
    }
    if ([[aView previousModeController] prefersToEmbedModeSwitcherViewIntoScrollViewIfPossible] && [aView activeModeController] == self) {
        return [self cardView];
    }
    return _workAreaContainerView;
}

- (void)copyIntoSelection:(id)aSelection
{
    id self_00;

    self_00 = [self cardView];
    if ([self_00 respondsToSelector:@selector(copyIntoSelection:)]) {
        [self_00 performSelector:@selector(copyIntoSelection:) withObject:aSelection];
    }
    [[self_00 window] makeFirstResponder:self_00];
}

- (void)setEraserColor:(id)aColor
{
    [[[HSEraserColorDialogController alloc] initWithOriginalObject:[self document]] runForWindow:[self window] delegate:self didEndSelector:@selector(effectDialog:didEndWithReturnCode:)];
}

- (void)eraseBackground:(id)aBackground
{
    [[[HSEraseBackgroundDialogController alloc] initWithOriginalObject:[self document]] runForWindow:[[[self document] currentWindowController] window] delegate:self didEndSelector:@selector(effectDialog:didEndWithReturnCode:)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00021765 @ 00021765, 1024 bytes * /

void FUN_00021765(HSEditorWindowController *self,SEL _cmd,id youTubeDialog,int didEndWithReturnCode)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar5;
  undefined8 uVar6;
  
  if (didEndWithReturnCode == 1) {
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,
                           sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_document);
      pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
      _objc_msgSend(pvVar2,sel_disableUndoRegistration);
      pvVar2 = _objc_msgSend(cls_HSYouTubeObject,sel_new);
      pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
      pvVar3 = _objc_msgSend(pvVar2,sel_defaultSize);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieID);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieID_,pvVar4);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieURL);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieURL_,pvVar4);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieWatchURL);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieWatchURL_,pvVar4);
      pvVar4 = _objc_msgSend(pvVar4,sel_absoluteString);
      _objc_msgSend(pvVar2,sel_setHyperComments_,pvVar4);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieSize_,pvVar3,extraout_EDX);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieTitle);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieTitle_,pvVar4);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieAuthor);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieAuthor_,pvVar4);
      pvVar4 = _objc_msgSend(youTubeDialog,sel_youTubeMovieAuthorURL);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieAuthorURL_,pvVar4);
      dVar5 = _objc_msgSend_fpret(youTubeDialog,sel_youTubeMovieDuration);
      _objc_msgSend(pvVar2,sel_setYouTubeMovieDuration_,dVar5);
      pvVar4 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00361de4);
      cVar1 = _NSEqualSizes(pvVar3,extraout_EDX,*(undefined4 *)PTR_0033607c,
                            *(undefined4 *)(PTR_0033607c + 4));
      if (cVar1 == '\0') {
        uVar6 = CONCAT44(extraout_EDX,pvVar3);
      }
      else {
        pvVar3 = _objc_msgSend(pvVar4,sel_defaultSize);
        uVar6 = CONCAT44(extraout_EDX_00,pvVar3);
      }
      _objc_msgSend(pvVar4,sel_setSize_,uVar6);
      pvVar3 = _objc_msgSend(self,sel_document);
      pvVar3 = _objc_msgSend(pvVar3,sel_undoManager);
      _objc_msgSend(pvVar3,sel_enableUndoRegistration);
      pvVar3 = _objc_msgSend(self,sel_document);
      pvVar3 = _objc_msgSend(pvVar3,sel_undoManager);
      pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Add_Item,
                             &cfstr_empty,&cfstr_UndoManager);
      _objc_msgSend(pvVar3,sel_setMultipleActionsName_,pvVar4);
      pvVar3 = _objc_msgSend(self,sel_cardView);
      _objc_msgSend(pvVar3,sel_addObjectToCenter_useDragPreferences_,pvVar2,0);
      _objc_msgSend(self,sel_didAddNewObject);
    }
  }
  _objc_msgSend(youTubeDialog,sel_autorelease);
  return;
}

*/
- (void)youTubeDialog:(id)aDialog didEndWithReturnCode:(NSInteger)aCode
{
    if (aCode == 1 && [[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
        [[[self document] undoManager] disableUndoRegistration];
        HSYouTubeObject *object = [[HSYouTubeObject new] autorelease];
        NSSize defaultSize = [object defaultSize];
        [object setYouTubeMovieID:[aDialog youTubeMovieID]];
        [object setYouTubeMovieURL:[aDialog youTubeMovieURL]];
        NSURL *watchURL = [aDialog youTubeMovieWatchURL];
        [object setYouTubeMovieWatchURL:watchURL];
        [object setHyperComments:[watchURL absoluteString]];
        [object setYouTubeMovieSize:defaultSize];
        [object setYouTubeMovieTitle:[aDialog youTubeMovieTitle]];
        [object setYouTubeMovieAuthor:[aDialog youTubeMovieAuthor]];
        [object setYouTubeMovieAuthorURL:[aDialog youTubeMovieAuthorURL]];
        [object setYouTubeMovieDuration:[aDialog youTubeMovieDuration]];
        id sizeAttributes = [object queryHyperInterface:@protocol(HSMutableSizeAttributes)];
        NSSize size = NSEqualSizes(defaultSize, NSZeroSize) ? [sizeAttributes defaultSize] : defaultSize;
        [sizeAttributes setSize:size];
        [[[self document] undoManager] enableUndoRegistration];
        [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Item" value:@"" table:@"UndoManager"]];
        [[self cardView] addObjectToCenter:object useDragPreferences:NO];
        [self didAddNewObject];
    }
    [aDialog autorelease];
}

- (void)showYouTubeDialog:(id)aDialog
{
    [[[HSYouTubeMoviesDialogController alloc] init] runForWindow:[[self document] windowForSheet] delegate:self didEndSelector:@selector(youTubeDialog:didEndWithReturnCode:)];
}

- (void)openEffectsDialog:(id)aDialog
{
    id pvVar2;
    BOOL pvVar3;
    HSEffectsDialogController *self_00;
    Class pvVar1_2;
    id pvVar1_3;

    pvVar2 = [[HSToolManager sharedToolManager] currentTool];
    pvVar1_2 = [self class];
    pvVar3 = [pvVar1_2 isValidSelectionTool:pvVar2];
    pvVar1_3 = nil;
    if (pvVar3) {
        pvVar1_3 = pvVar2;
    }
    if (pvVar1_3 == nil) {
        pvVar1_3 = [self selectedHyperObject];
    }
    if (pvVar1_3 == nil) {
        pvVar1_3 = [[self cardView] card];
    }
    self_00 = _effectsDialogController;
    if (self_00 == nil) {
        self_00 = [[HSEffectsDialogController alloc] init];
        _effectsDialogController = self_00;
    }
    [self_00 setObject:pvVar1_3];
    [_effectsDialogController runModal];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001d041 @ 0001d041, 358 bytes * /

void FUN_0001d041(HSEditorWindowController *self,SEL _cmd,id rotateSelectedObject)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  puVar3 = sel_selectedItem;
  pvVar1 = _objc_msgSend(rotateSelectedObject,sel_respondsToSelector_,sel_selectedItem);
  pvVar2 = rotateSelectedObject;
  if ((char)pvVar1 != '\0') {
    pvVar2 = _objc_msgSend(rotateSelectedObject,sel_selectedItem,puVar3);
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_tag,puVar3);
  op = sel_scaleAndRotate_;
  if ((int)pvVar2 - 1U < 2) {
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar3);
    rotateSelectedObject = _objc_msgSend(pvVar2,sel_currentTool);
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar2 = rotateSelectedObject;
    pvVar1 = _objc_msgSend(pvVar1,sel_isValidSelectionTool_,rotateSelectedObject);
    if ((char)pvVar1 == '\0') {
      rotateSelectedObject =
           _objc_msgSend(self,sel_selectedCardObjectForEditingOperationWithImplicitVerification,
                         pvVar2);
    }
    self = _objc_msgSend(self,sel_class,pvVar2);
    op = sel_rotateObject_aboutCenterBy_;
  }
  _objc_msgSend(self,op,rotateSelectedObject);
  return;
}

*/
- (void)rotateSelectedObject:(id)aObject
{
    id item = [aObject respondsToSelector:@selector(selectedItem)] ? [aObject selectedItem] : aObject;
    NSInteger tag = [item tag];
    if (tag == 1 || tag == 2) {
        id target = [[HSToolManager sharedToolManager] currentTool];
        if (![[self class] isValidSelectionTool:target]) {
            target = [self selectedCardObjectForEditingOperationWithImplicitVerification];
        }
        double angle = (tag == 1) ? M_PI * 0.5 : M_PI * -0.5;
        [[self class] rotateObject:target aboutCenterBy:(float)angle];
    } else {
        [self scaleAndRotate:aObject];
    }
}

- (void)scaleAndRotate:(id)aRotate
{
    [self applyEffectUsingControllerClass:[HSTransformationEffectDialogController class]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001cc6b @ 0001cc6b, 914 bytes * /

void FUN_0001cc6b(HSEditorWindowController *self,SEL _cmd,id drawCentered)

{
  undefined *puVar1;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  id pvVar8;
  id pvVar9;
  undefined4 uVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  id pvVar15;
  id pvVar16;
  id pvVar17;
  id pvVar18;
  id pvVar19;
  undefined4 *puVar20;
  undefined4 uVar21;
  
  pvVar8 = _objc_msgSend(cls_NSMenuItem,sel_class);
  pvVar9 = _objc_msgSend(drawCentered,sel_isKindOfClass_,pvVar8);
  if ((char)pvVar9 == '\0') {
    return;
  }
  pvVar9 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar8);
  pvVar9 = _objc_msgSend(pvVar9,sel_toolSettings);
  puVar1 = cls_NSNumber;
  if (pvVar9 == (id)0x0) {
    return;
  }
  pvVar8 = _objc_msgSend(drawCentered,sel_state,pvVar8);
  uVar10 = 0xffffffff;
  if (pvVar8 != (id)0x1) {
    uVar10 = 0;
  }
  pvVar8 = _objc_msgSend(puVar1,sel_numberWithUnsignedInteger_,uVar10);
  if (pvVar8 == (id)0x0) {
    return;
  }
  pvVar11 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar10);
  pvVar11 = _objc_msgSend(pvVar11,sel_selectedToolTag);
  puVar4 = PTR_PTR_003360fc;
  pvVar12 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360fc);
  puVar2 = PTR_PTR_003360b0;
  pvVar13 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360b0);
  puVar1 = PTR_PTR_003360ac;
  pvVar14 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360ac);
  puVar3 = PTR_PTR_003360b4;
  pvVar15 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360b4);
  puVar7 = PTR_PTR_00336140;
  pvVar16 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_00336140);
  puVar5 = PTR_PTR_00336138;
  pvVar17 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_00336138);
  puVar20 = (undefined4 *)PTR_PTR_00336134;
  pvVar18 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_00336134);
  puVar6 = PTR_PTR_0033613c;
  pvVar19 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_0033613c);
  if ((pvVar11 == pvVar12) || (pvVar11 == pvVar16)) {
    uVar10 = *(undefined4 *)PTR_00336118;
    _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar4,uVar10);
    puVar20 = (undefined4 *)puVar7;
  }
  else if ((pvVar11 == pvVar13) || (pvVar11 == pvVar17)) {
    uVar10 = *(undefined4 *)PTR_00336118;
    _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar2,uVar10);
    puVar20 = (undefined4 *)puVar5;
  }
  else {
    if ((pvVar11 != pvVar14) && (pvVar11 != pvVar18)) {
      if ((pvVar11 != pvVar15) && (pvVar11 != pvVar19)) {
        return;
      }
      uVar10 = *(undefined4 *)PTR_00336118;
      _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar3,uVar10)
      ;
      uVar21 = *(undefined4 *)puVar6;
      goto LAB_0001cf09;
    }
    uVar10 = *(undefined4 *)PTR_00336118;
    _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar1,uVar10);
  }
  uVar21 = *puVar20;
LAB_0001cf09:
  _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,uVar21,uVar10);
  return;
}

*/
- (void)drawCentered:(id)aCentered
{
    if (![aCentered isKindOfClass:[NSMenuItem class]]) {
        return;
    }
    id settings = [[HSToolManager sharedToolManager] toolSettings];
    if (settings == nil) {
        return;
    }
    id value = [NSNumber numberWithUnsignedInteger:([aCentered state] == 1) ? (NSUInteger)-1 : 0];
    if (value == nil) {
        return;
    }
    NSInteger selectedTag = [[HSToolManager sharedToolManager] selectedToolTag];
    static NSString *const identifiers[4][2] = {
        { @"HSLineTool", @"HSVectorLineTool" },
        { @"HSDragRectTool", @"HSVectorDragRectTool" },
        { @"HSDragCircleTool", @"HSVectorDragCircleTool" },
        { @"HSDragRoundedRectTool", @"HSVectorDragRoundedRectTool" },
    };
    for (int index = 0; index < 4; index++) {
        NSInteger bitmapTag = [HSToolManager toolTagForIdentifier:identifiers[index][0]];
        NSInteger vectorTag = [HSToolManager toolTagForIdentifier:identifiers[index][1]];
        if (selectedTag == bitmapTag || selectedTag == vectorTag) {
            [settings setSetting:value forIdentifier:identifiers[index][0] andKey:HSToolCenteringOptionAttributeKey];
            [settings setSetting:value forIdentifier:identifiers[index][1] andKey:HSToolCenteringOptionAttributeKey];
            return;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001c8d9 @ 0001c8d9, 914 bytes * /

void FUN_0001c8d9(HSEditorWindowController *self,SEL _cmd,id drawMultiple)

{
  undefined *puVar1;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  id pvVar8;
  id pvVar9;
  undefined4 uVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  id pvVar15;
  id pvVar16;
  id pvVar17;
  id pvVar18;
  id pvVar19;
  undefined4 *puVar20;
  undefined4 uVar21;
  
  pvVar8 = _objc_msgSend(cls_NSMenuItem,sel_class);
  pvVar9 = _objc_msgSend(drawMultiple,sel_isKindOfClass_,pvVar8);
  if ((char)pvVar9 == '\0') {
    return;
  }
  pvVar9 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar8);
  pvVar9 = _objc_msgSend(pvVar9,sel_toolSettings);
  puVar1 = cls_NSNumber;
  if (pvVar9 == (id)0x0) {
    return;
  }
  pvVar8 = _objc_msgSend(drawMultiple,sel_state,pvVar8);
  uVar10 = 0xffffffff;
  if (pvVar8 == (id)0x1) {
    uVar10 = 0;
  }
  pvVar8 = _objc_msgSend(puVar1,sel_numberWithUnsignedInteger_,uVar10);
  if (pvVar8 == (id)0x0) {
    return;
  }
  pvVar11 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar10);
  pvVar11 = _objc_msgSend(pvVar11,sel_selectedToolTag);
  puVar4 = PTR_PTR_003360fc;
  pvVar12 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360fc);
  puVar7 = PTR_PTR_00336140;
  pvVar13 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_00336140);
  puVar2 = PTR_PTR_003360b0;
  pvVar14 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360b0);
  puVar5 = PTR_PTR_00336138;
  pvVar15 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_00336138);
  puVar1 = PTR_PTR_003360ac;
  pvVar16 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360ac);
  puVar20 = (undefined4 *)PTR_PTR_00336134;
  pvVar17 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_00336134);
  puVar3 = PTR_PTR_003360b4;
  pvVar18 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_003360b4);
  puVar6 = PTR_PTR_0033613c;
  pvVar19 = _objc_msgSend(cls_HSToolManager,sel_toolTagForIdentifier_,
                          *(undefined4 *)PTR_PTR_0033613c);
  if ((pvVar11 == pvVar12) || (pvVar11 == pvVar13)) {
    uVar10 = *(undefined4 *)PTR_0033611c;
    _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar4,uVar10);
    puVar20 = (undefined4 *)puVar7;
  }
  else if ((pvVar11 == pvVar14) || (pvVar11 == pvVar15)) {
    uVar10 = *(undefined4 *)PTR_0033611c;
    _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar2,uVar10);
    puVar20 = (undefined4 *)puVar5;
  }
  else {
    if ((pvVar11 != pvVar16) && (pvVar11 != pvVar17)) {
      if ((pvVar11 != pvVar18) && (pvVar11 != pvVar19)) {
        return;
      }
      uVar10 = *(undefined4 *)PTR_0033611c;
      _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar3,uVar10)
      ;
      uVar21 = *(undefined4 *)puVar6;
      goto LAB_0001cb77;
    }
    uVar10 = *(undefined4 *)PTR_0033611c;
    _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,*(undefined4 *)puVar1,uVar10);
  }
  uVar21 = *puVar20;
LAB_0001cb77:
  _objc_msgSend(pvVar9,sel_setSetting_forIdentifier_andKey_,pvVar8,uVar21,uVar10);
  return;
}

*/
- (void)drawMultiple:(id)aMultiple
{
    if (![aMultiple isKindOfClass:[NSMenuItem class]]) {
        return;
    }
    id settings = [[HSToolManager sharedToolManager] toolSettings];
    if (settings == nil) {
        return;
    }
    id value = [NSNumber numberWithUnsignedInteger:([aMultiple state] == 1) ? 0 : (NSUInteger)-1];
    if (value == nil) {
        return;
    }
    NSInteger selectedTag = [[HSToolManager sharedToolManager] selectedToolTag];
    static NSString *const identifiers[4][2] = {
        { @"HSLineTool", @"HSVectorLineTool" },
        { @"HSDragRectTool", @"HSVectorDragRectTool" },
        { @"HSDragCircleTool", @"HSVectorDragCircleTool" },
        { @"HSDragRoundedRectTool", @"HSVectorDragRoundedRectTool" },
    };
    for (int index = 0; index < 4; index++) {
        NSInteger bitmapTag = [HSToolManager toolTagForIdentifier:identifiers[index][0]];
        NSInteger vectorTag = [HSToolManager toolTagForIdentifier:identifiers[index][1]];
        if (selectedTag == bitmapTag || selectedTag == vectorTag) {
            [settings setSetting:value forIdentifier:identifiers[index][0] andKey:HSToolPositioningOptionAttributeKey];
            [settings setSetting:value forIdentifier:identifiers[index][1] andKey:HSToolPositioningOptionAttributeKey];
            return;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001c666 @ 0001c666, 627 bytes * /

void FUN_0001c666(HSEditorWindowController *self,SEL _cmd,id draw3DShapes)

{
  undefined4 uVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar1 = *(undefined4 *)PTR_003360b8;
  uVar3 = uVar1;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,uVar1);
  if ((pvVar2 == (id)0x0) ||
     (pvVar2 = _objc_msgSend(pvVar2,sel_intValue,uVar3), op = sel_continueDraw3DShapes_,
     pvVar2 != (id)0x0)) {
    self = _objc_msgSend(cls_HSDontShowAgainAlert,sel_new,uVar3);
    _objc_msgSend(self,sel_setShowAlertKey_,uVar1);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSDraw3dShapesAlertMessageText,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(self,sel_setMessageText_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSDraw3dShapesAlertInformativeText,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(self,sel_setInformativeText_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSDraw3dShapesAlertContinueButtonTitle,&cfstr_empty,&cfstr_Alerts)
    ;
    _objc_msgSend(self,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(self,sel_addButtonWithTitle_,pvVar2);
    draw3DShapes = _objc_msgSend(*(id *)PTR_00336058,sel_mainWindow);
    op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
  }
  _objc_msgSend(self,op,draw3DShapes);
  return;
}

*/
- (void)draw3DShapes:(id)aShapes
{
    id showAlert = [[NSUserDefaults standardUserDefaults] objectForKey:HSDraw3dShapesShowAlertKey];
    if (showAlert == nil || [showAlert intValue] != 0) {
        HSDontShowAgainAlert *alert = [HSDontShowAgainAlert new];
        [alert setShowAlertKey:HSDraw3dShapesShowAlertKey];
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        [alert setMessageText:[provider localizedStringForKey:@"HSDraw3dShapesAlertMessageText" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[provider localizedStringForKey:@"HSDraw3dShapesAlertInformativeText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"HSDraw3dShapesAlertContinueButtonTitle" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[provider localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(draw3DShapesAlert:didEndWithReturnCode:contextInfo:) contextInfo:aShapes];
    } else {
        [self continueDraw3DShapes:aShapes];
    }
}

- (void)draw3DShapesAlert:(id)aAlert didEndWithReturnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        [self continueDraw3DShapes:aInfo];
    }
}

- (void)continueDraw3DShapes:(id)aShapes
{
    [self switchTool:aShapes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001c571 @ 0001c571, 146 bytes * /

void FUN_0001c571(HSEditorWindowController *self,SEL _cmd,id textFieldTamer)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSTextFieldTamerDialogController,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_editObjectDialogContext);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithContext_,pvVar2);
  _objc_msgSend(pvVar1,sel_runModal);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)textFieldTamer:(id)aTamer
{
    id controller = [[HSTextFieldTamerDialogController alloc] initWithContext:[[self document] editObjectDialogContext]];
    [controller runModal];
    [controller release];
}

- (void)gridSetupDialog:(id)aDialog didEndWithReturnCode:(NSInteger)aCode
{
    [aDialog autorelease];
}

- (void)showGridOptionsDialog:(id)aDialog
{
    [[[HSGridSetupDialogController alloc] initWithContext:[[self document] editObjectDialogContext]] runForWindow:[self window] delegate:self didEndSelector:@selector(gridSetupDialog:didEndWithReturnCode:)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001c3e1 @ 0001c3e1, 190 bytes * /

void FUN_0001c3e1(HSEditorWindowController *self,SEL _cmd,id editFeatures)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar2 = _objc_msgSend(pvVar1,sel_isActive);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(pvVar1,sel_setActive_explicitlyByUser_,1,1);
  }
  pvVar2 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar2,sel_saveRunTimeEditors);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAssistant);
  _objc_msgSend(pvVar1,sel_openPaneWithIdentifier_,*(undefined4 *)PTR_PTR_003360c0);
  return;
}

*/
- (void)editFeatures:(id)aFeatures
{
    HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
    if (![assistant isActive]) {
        [assistant setActive:YES explicitlyByUser:YES];
    }
    [[self cardView] saveRunTimeEditors];
    [[assistant objectAssistant] openPaneWithIdentifier:@"HSGenericObjectFeaturesAssistantPane"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001c323 @ 0001c323, 190 bytes * /

void FUN_0001c323(HSEditorWindowController *self,SEL _cmd,id editActions)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_saveRunTimeEditors);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar2 = _objc_msgSend(pvVar1,sel_isActive);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(pvVar1,sel_setActive_explicitlyByUser_,1,1);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAssistant);
  _objc_msgSend(pvVar1,sel_openPaneWithIdentifier_,*(undefined4 *)PTR_PTR_00336018);
  return;
}

*/
- (void)editActions:(id)aActions
{
    [[self cardView] saveRunTimeEditors];
    HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
    if (![assistant isActive]) {
        [assistant setActive:YES explicitlyByUser:YES];
    }
    [[assistant objectAssistant] openPaneWithIdentifier:@"HSActionsAssistantPane"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001c28c @ 0001c28c, 151 bytes * /

void FUN_0001c28c(HSEditorWindowController *self,SEL _cmd,id editAppearance)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar2 = _objc_msgSend(pvVar1,sel_isActive);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(pvVar1,sel_setActive_explicitlyByUser_,1,1);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAssistant);
  _objc_msgSend(pvVar1,sel_openPaneWithIdentifier_,*(undefined4 *)PTR_PTR_00336094);
  return;
}

*/
- (void)editAppearance:(id)aAppearance
{
    HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
    if (![assistant isActive]) {
        [assistant setActive:YES explicitlyByUser:YES];
    }
    [[assistant objectAssistant] openPaneWithIdentifier:@"HSAppearanceObjectAssistantRootPaneName"];
}

- (void)editActionsForActiveCard
{
    [self editActions:self];
}

- (void)selectActiveCardAndShowInspector:(id)aInspector
{
    BOOL cVar3;

    [[self cardView] setCard:[aInspector activeCard]];
    [self selectActiveCard];
    cVar3 = ![[self document] isInPlayerMode];
    if (!(BOOL)cVar3) {
        cVar3 = [[self document] shouldHandleActionThatRequiresImmediateSwitchToEditMode:NO];
    }
    if (cVar3 != NO) {
        [self switchToToolWithTag:1];
        [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:[self activeCard]];
    }
}

- (void)selectActiveCardAndShowInspector
{
    BOOL cVar3;

    [self selectActiveCard];
    cVar3 = ![[self document] isInPlayerMode];
    if (!(BOOL)cVar3) {
        cVar3 = [[self document] shouldHandleActionThatRequiresImmediateSwitchToEditMode];
    }
    if (cVar3 != NO) {
        [[HSObjectAssistantController sharedAssistantController] setShouldOpenCardInfo:YES];
        [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:[self activeCard]];
    }
}

- (void)selectActiveCard
{
    [self saveEditingState];
    [[self thisCardSelectionHolder] makeCurrent];
}

- (void)editCardActions:(id)aActions
{
    id pvVar2_4;

    [self selectActiveCard];
    [self switchToToolWithTag:1];
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
    [[HSObjectAssistantController sharedAssistantController] setShouldOpenCardInfo:YES];
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:[self activeCard]];
    pvVar2_4 = [[[HSObjectAssistantController sharedAssistantController] objectAssistant] currentPane];
    if ([pvVar2_4 modalViewController] == nil) {
        [pvVar2_4 openActionsPaneForClickEvent:aActions];
    }
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
}

- (void)editStackActions:(id)aActions
{
    id pvVar2_4;

    [[[self document] stackSelectionHolder] makeCurrent];
    [self switchToToolWithTag:1];
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:[[self document] stack]];
    pvVar2_4 = [[[HSObjectAssistantController sharedAssistantController] objectAssistant] currentPane];
    if ([pvVar2_4 modalViewController] == nil) {
        [pvVar2_4 openActionsPaneForClickEvent:aActions];
    }
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
}

- (void)showStackOptionsDialog:(id)aDialog
{
    [[[self document] stackSelectionHolder] makeCurrent];
    [self switchToToolWithTag:1];
    [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:[[self document] stack]];
    [self removeHelpPaneOverCurrentPaneOfClass:[HSStackAssistantPane class]];
}

- (void)showCardOptionsDialog:(id)aDialog
{
    [self switchToToolWithTag:1];
    [self selectActiveCardAndShowInspector];
    [self removeHelpPaneOverCurrentPaneOfClass:[HSCardAssistantPane class]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00021b65 @ 00021b65, 501 bytes * /

void FUN_00021b65(HSEditorWindowController *self,SEL _cmd,Class removeHelpPaneOverCurrentPaneOfClass
                 )

{
  undefined4 uVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined1 *puVar8;
  undefined4 uVar9;
  undefined4 local_6c;
  int local_68;
  int *local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined4 local_54;
  undefined4 local_50;
  undefined1 local_4c [64];
  
  pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAssistant);
  pvVar3 = _objc_msgSend(pvVar3,sel_currentPane);
  pvVar4 = _objc_msgSend(pvVar3,sel_modalViewController);
  if (pvVar4 != (id)0x0) {
    pvVar5 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_class);
    pvVar6 = _objc_msgSend(pvVar4,sel_isKindOfClass_,pvVar5);
    if ((char)pvVar6 != '\0') {
      pvVar4 = _objc_msgSend(pvVar4,sel_viewControllers,pvVar5);
      local_6c = 0;
      local_68 = 0;
      local_64 = (int *)0x0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      local_54 = 0;
      local_50 = 0;
      puVar8 = local_4c;
      uVar9 = 0x10;
      pvVar5 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_6c,puVar8,
                             0x10);
      if (pvVar5 != (id)0x0) {
        uVar1 = *(undefined4 *)PTR_PTR_00336108;
        iVar2 = *local_64;
        do {
          pvVar6 = (id)0x0;
          do {
            if (iVar2 != *local_64) {
              _objc_enumerationMutation(pvVar4);
            }
            pvVar7 = _objc_msgSend(*(id *)(local_68 + (int)pvVar6 * 4),sel_objectForKey_,uVar1,
                                   puVar8,uVar9);
            pvVar7 = _objc_msgSend(pvVar7,sel_isCoachingPane);
            if ((char)pvVar7 == '\0') {
              return;
            }
            pvVar6 = (id)((int)pvVar6 + 1);
          } while (pvVar6 < pvVar5);
          puVar8 = local_4c;
          uVar9 = 0x10;
          pvVar5 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_6c,
                                 puVar8,0x10);
        } while (pvVar5 != (id)0x0);
      }
      _objc_msgSend(pvVar3,sel_dismissModalViewControllerAnimated_,1,puVar8,uVar9);
    }
  }
  return;
}

*/
- (void)effectDialog:(id)aDialog didEndWithReturnCode:(NSInteger)aCode
{
    [aDialog autorelease];
}

- (void)applyEffectUsingControllerClass:(Class)aClass
{
    id pvVar3;
    Class pvVar4;

    pvVar3 = [[HSToolManager sharedToolManager] currentTool];
    pvVar4 = [self class];
    if (![pvVar4 isValidSelectionTool:pvVar3]) {
        pvVar3 = [self selectedCardObjectForEditingOperationWithImplicitVerification];
    }
    [[[aClass alloc] initWithOriginalObject:pvVar3] runForWindow:[self window] delegate:self didEndSelector:@selector(effectDialog:didEndWithReturnCode:)];
}

- (id)createActionObjectWithClassNameEnumerator:(id)aEnumerator forMedia:(id)aMedia error:(id *)aError
{
    id pvVar2;
    id pvVar3;
    id pvVar2_2;
    id pvVar2_3;
    id pvVar2_4;

    pvVar3 = nil;
    do {
        pvVar2 = [aEnumerator nextObject];
        if (pvVar2 == nil) break;
        pvVar2_2 = NSClassFromString(pvVar2);
        if ([pvVar2_2 conformsToProtocol:@protocol(HSMediaAttributes)]) {
            pvVar3 = [[[pvVar2_2 alloc] init] autorelease];
        }
    } while (pvVar3 == nil);
    pvVar2_3 = pvVar3;
    if (pvVar3 != nil) {
        pvVar2_4 = [pvVar3 queryHyperInterface:@protocol(HSMediaAttributes)];
        [pvVar2_4 setMedia:aMedia error:aError];
        if (pvVar2_4 == nil) {
            pvVar2_3 = nil;
        }
        else {
            pvVar2_3 = nil;
            if (*aError == nil) {
                pvVar2_3 = pvVar3;
            }
        }
    }
    return pvVar2_3;
}

- (id)createCardObjectWithClassNameEnumerator:(id)aEnumerator forMedia:(id)aMedia error:(id *)aError
{
    id pvVar2;
    id pvVar3;
    id pvVar2_2;

    pvVar3 = nil;
    do {
        pvVar2 = [aEnumerator nextObject];
        if (pvVar2 == nil) {
            return pvVar3;
        }
        pvVar2_2 = NSClassFromString(pvVar2);
        if ([pvVar2_2 conformsToProtocol:@protocol(HSMediaObject)]) {
            pvVar3 = [[[pvVar2_2 alloc] initWithMedia:aMedia error:aError] autorelease];
        }
    } while (pvVar3 == nil);
    return pvVar3;
}

- (void)addActionToActorOfActiveCard:(id)aCard
{
    [self addActionToActorOfActiveCard:aCard ofEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b8f8 @ 0001b8f8, 256 bytes * /

void FUN_0001b8f8(HSEditorWindowController *self,SEL _cmd,id addActionToActorOfActiveCard,id ofEvent
                 )

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  SEL op;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_activeCard);
  self_00 = _objc_msgSend(pvVar1,sel_actor);
  pvVar1 = _objc_msgSend(cls_HSPlaySoundAction,sel_actionType);
  pvVar3 = ofEvent;
  self_01 = _objc_msgSend(self_00,sel_hyperActionsOfType_forEvent_,pvVar1,ofEvent);
  pvVar2 = _objc_msgSend(self_01,sel_count);
  op = sel_addHyperAction_forEvent_;
  pvVar1 = addActionToActorOfActiveCard;
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(cls_NSArray,sel_arrayWithObject_,ofEvent,pvVar3);
    pvVar1 = _objc_msgSend(self_01,sel_extraFirstObject);
    op = sel_replaceHyperAction_withAction_forEvents_;
    ofEvent = addActionToActorOfActiveCard;
  }
  _objc_msgSend(self_00,op,pvVar1,ofEvent);
  return;
}

*/
- (void)addActionToActorOfActiveCard:(id)aCard ofEvent:(id)aEvent
{
    id actor = [[self activeCard] actor];
    id existing = [actor hyperActionsOfType:[HSPlaySoundAction actionType] forEvent:aEvent];
    if ([existing count] != 0) {
        [actor replaceHyperAction:[existing extraFirstObject] withAction:aCard forEvents:[NSArray arrayWithObject:aEvent]];
    } else {
        [actor addHyperAction:aCard forEvent:aEvent];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00021efe @ 00021efe, 665 bytes * /

id FUN_00021efe(HSEditorWindowController *self,SEL _cmd,id verifyObjects,id beforeAddToCard)

{
  undefined *self_00;
  id self_01;
  id self_02;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_03;
  id pvVar4;
  id self_04;
  id self_05;
  SEL op;
  undefined *puVar5;
  undefined4 uVar6;
  
  self_01 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_02 = _objc_msgSend(verifyObjects,sel_objectEnumerator);
LAB_0002217f:
  self_05 = _objc_msgSend(self_02,sel_nextObject);
  if (self_05 == (id)0x0) {
    return self_01;
  }
  puVar5 = &DAT_00361b78;
  pvVar1 = _objc_msgSend(self_05,sel_queryHyperInterface_,&DAT_00361b78);
  self_03 = self_01;
  op = sel_addObject_;
  pvVar3 = self_05;
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_media,puVar5);
    pvVar3 = _objc_msgSend(pvVar2,sel_fullPathToMediaFileCreateIfNeeded_,1);
    self_03 = _objc_msgSend(cls_HSMovieVerifier,sel_new);
    pvVar4 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar3);
    uVar6 = 0;
    pvVar1 = (id)0x0;
    pvVar3 = pvVar4;
    self_04 = _objc_msgSend(self_03,sel_verifyMovieAtURL_withOptions_error_,pvVar4,0,0);
    if (self_04 == (id)0x0) {
      _NSBeep();
      op = sel_release;
      goto LAB_00021ffa;
    }
    pvVar3 = _objc_msgSend(self_04,sel_path,pvVar3,pvVar1,uVar6);
    pvVar3 = _objc_msgSend(pvVar3,sel_stringByResolvingSymlinksInPath);
    pvVar4 = _objc_msgSend(pvVar4,sel_path);
    pvVar4 = _objc_msgSend(pvVar4,sel_stringByResolvingSymlinksInPath);
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,pvVar4);
    if ((char)pvVar3 == '\0') goto code_r0x00022146;
    goto LAB_00021fca;
  }
  goto LAB_00021ffa;
code_r0x00022146:
  puVar5 = &DAT_00361bb4;
  pvVar3 = _objc_msgSend(self_05,sel_queryHyperInterface_,&DAT_00361bb4);
  self_00 = cls_HSNewMedia;
  if (pvVar3 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar2,sel_mediaName,puVar5);
    pvVar2 = _objc_msgSend(self_04,sel_path);
    uVar6 = 1;
    pvVar2 = _objc_msgSend(self_00,sel_mediaWithPath_name_removeWhenDone_,pvVar2,pvVar1,1);
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_setMedia_,pvVar2,pvVar1,uVar6);
LAB_00021fca:
      _objc_msgSend(self_01,sel_addObject_,self_05,pvVar1,uVar6);
      op = sel_release;
      pvVar3 = self_05;
LAB_00021ffa:
      _objc_msgSend(self_03,op,pvVar3);
    }
  }
  goto LAB_0002217f;
}

*/
- (id)verifyObjects:(id)aObjects beforeAddToCard:(id)aCard
{
    NSMutableArray *verified = [NSMutableArray array];
    NSEnumerator *enumerator = [aObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id movie = [object queryHyperInterface:@protocol(HSMovieObjectAttributes)];
        if (movie == nil) {
            [verified addObject:object];
            continue;
        }
        id media = [movie media];
        NSURL *url = [NSURL fileURLWithPath:[media fullPathToMediaFileCreateIfNeeded:YES]];
        HSMovieVerifier *verifier = [HSMovieVerifier new];
        NSURL *verifiedURL = [verifier verifyMovieAtURL:url withOptions:0 error:NULL];
        if (verifiedURL == nil) {
            NSBeep();
            [verifier release];
            continue;
        }
        if ([[[verifiedURL path] stringByResolvingSymlinksInPath] isEqual:[[url path] stringByResolvingSymlinksInPath]]) {
            [verified addObject:object];
        } else {
            id mediaAttributes = [object queryHyperInterface:@protocol(HSMediaAttributes)];
            if (mediaAttributes != nil) {
                id replacement = [HSNewMedia mediaWithPath:[verifiedURL path] name:[media mediaName] removeWhenDone:YES];
                if (replacement != nil) {
                    [mediaAttributes setMedia:replacement];
                    [verified addObject:object];
                }
            }
        }
        [verifier release];
    }
    return verified;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00022197 @ 00022197, 5809 bytes * /

void FUN_00022197(HSEditorWindowController *self,SEL _cmd,id importBackgroundDialogDidEnd,
                 int returnCode,void *contextInfo)

{
  undefined4 uVar1;
  float fVar2;
  undefined4 uVar3;
  bool bVar4;
  undefined *puVar5;
  char cVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  cfstringStruct *pcVar13;
  HSEditorWindowController *pHVar14;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 *puVar15;
  float *pfVar16;
  float *pfVar17;
  undefined4 *puVar18;
  bool bVar19;
  longdouble lVar20;
  longdouble lVar21;
  undefined4 uStack_164;
  SEL op;
  id local_114;
  float local_10c;
  id local_100;
  undefined4 local_f4;
  undefined4 local_f0;
  undefined4 local_ec;
  undefined4 local_e8;
  int local_c0;
  float local_bc;
  float local_b8;
  float local_b4;
  float local_b0;
  float local_ac;
  float fStack_a8;
  float local_a4;
  float fStack_a0;
  undefined4 local_9c;
  undefined4 uStack_98;
  id local_94;
  undefined4 local_8c;
  undefined4 uStack_88;
  id local_84;
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  undefined4 local_5c;
  undefined4 uStack_58;
  id local_54;
  undefined4 local_4c;
  undefined4 uStack_48;
  id local_44;
  undefined4 local_3c;
  undefined4 local_38;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar15 = (undefined4 *)&stack0xfffffea4;
  pfVar16 = (float *)&stack0xfffffea4;
  pfVar17 = (float *)&stack0xfffffea4;
  puVar18 = (undefined4 *)&stack0xfffffea4;
  if (returnCode == 1) {
    pvVar7 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
    pvVar8 = _objc_msgSend(importBackgroundDialogDidEnd,sel_dialogUserOptions);
    pvVar9 = _objc_msgSend(pvVar8,sel_valueForKey_);
    pvVar9 = _objc_msgSend(pvVar9,sel_boolValue);
    cVar6 = (char)pvVar9;
    pvVar9 = _objc_msgSend(pvVar8,sel_valueForKey_);
    pvVar9 = _objc_msgSend(pvVar9,sel_boolValue);
    pvVar10 = _objc_msgSend(importBackgroundDialogDidEnd,sel_dialogType);
    pvVar11 = _objc_msgSend(pvVar8,sel_valueForKey_);
    pvVar11 = _objc_msgSend(pvVar11,sel_intValue);
    if ((char)pvVar9 != '\0') {
      _objc_msgSend(pvVar8,sel_valueForKey_);
    }
    pvVar8 = _objc_msgSend(pvVar8,sel_valueForKey_);
    local_100 = _objc_msgSend(importBackgroundDialogDidEnd,sel_fileName);
    local_114 = _objc_msgSend(importBackgroundDialogDidEnd,sel_fileDisplayName);
    if (cVar6 == '\0') {
      local_100 = _objc_msgSend(self,sel_checkFileExistenceAtPath_expectedType_);
      bVar19 = local_100 == (id)0x0;
    }
    else {
      bVar19 = false;
    }
    local_38 = 0;
    if (bVar19 || cVar6 != '\0') {
      pvVar9 = (id)0x0;
    }
    else {
      pvVar9 = _objc_msgSend(self,sel_class);
      pvVar9 = _objc_msgSend(pvVar9,sel_loadImageAtPath_error_);
    }
    if (cVar6 != '\0') {
      pvVar8 = _objc_msgSend(cls_HSCaptureImageController,sel_alloc);
      pvVar8 = _objc_msgSend(pvVar8,sel_init);
      pvVar8 = _objc_msgSend(pvVar8,sel_autorelease);
      pvVar9 = _objc_msgSend(pvVar8,sel_runModal);
      if (pvVar9 != (id)0x1) goto LAB_00022645;
      pvVar9 = _objc_msgSend(pvVar8,sel_capturedImage);
      _objc_msgSend(pvVar9,sel_setScalesWhenResized_);
      pvVar12 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar8 = (id)0x0;
      local_114 = _objc_msgSend(pvVar12,sel_localizedStringForKey_value_table_);
    }
    if (pvVar8 != (id)0x0) {
      pvVar9 = pvVar8;
    }
    if (pvVar9 == (id)0x0) goto LAB_000224c6;
    pvVar8 = _objc_msgSend(pvVar10,sel_isEqualToString_);
    if ((char)pvVar8 == '\0') {
      pvVar8 = _objc_msgSend(pvVar10,sel_isEqualToString_);
      if ((char)pvVar8 == '\0') {
        pvVar8 = _objc_msgSend(pvVar10,sel_isEqualToString_);
        if ((char)pvVar8 == '\0') {
LAB_000224c6:
          bVar4 = false;
          pfVar16 = (float *)&stack0xfffffea4;
          goto LAB_000224c8;
        }
        pvVar8 = _objc_msgSend(self,sel_document);
        pvVar8 = _objc_msgSend(pvVar8,
                               sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
        if ((char)pvVar8 == '\0') goto LAB_000224c6;
        uVar3 = *(undefined4 *)PTR_0033608c;
        uVar1 = *(undefined4 *)(PTR_0033608c + 4);
        local_84 = _objc_msgSend(pvVar9,sel_size);
        local_8c = uVar3;
        uStack_88 = uVar1;
        pvVar8 = _objc_msgSend(self,sel_document);
        pvVar8 = _objc_msgSend(pvVar8,sel_stack);
        uVar3 = *(undefined4 *)PTR_00336074;
        uVar1 = *(undefined4 *)(PTR_00336074 + 4);
        local_94 = _objc_msgSend(pvVar8,sel_hyperCardSize);
        local_9c = uVar3;
        uStack_98 = uVar1;
        FUN_00012a1c();
        pvVar8 = _objc_msgSend(self,sel_cardView);
        pvVar8 = _objc_msgSend(pvVar8,sel_enclosingScrollView);
        pfVar17 = (float *)&stack0xfffffea4;
        if (((int)pvVar11 - 4U < 2) && (pfVar17 = (float *)&stack0xfffffea4, pvVar8 != (id)0x0)) {
          pvVar10 = _objc_msgSend(self,sel_cardView);
          _objc_msgSend_stret(local_24,pvVar8,sel_documentVisibleRect);
          uStack_164 = 0x231da;
          _objc_msgSend_stret(&local_bc,pvVar10,sel_userBoundingRectForViewRect_);
          local_ac = ((local_b4 * 0.5 + local_bc) - (local_a4 * 0.5 + local_ac)) + local_ac;
          fStack_a8 = ((local_b0 * 0.5 + local_b8) - (fStack_a0 * 0.5 + fStack_a8)) + fStack_a8;
          pfVar17 = (float *)&uStack_164;
        }
        fVar2 = fStack_a8;
        *pfVar17 = local_ac;
        pfVar17[-1] = 2.01758e-40;
        lVar20 = (longdouble)_roundf();
        local_ac = (float)lVar20;
        *pfVar17 = fVar2;
        pfVar17[-1] = 2.01791e-40;
        lVar20 = (longdouble)_roundf();
        fStack_a8 = (float)lVar20;
        *(ulonglong *)(pfVar17 + 5) = CONCAT44(fStack_a0,local_a4);
        *(ulonglong *)(pfVar17 + 3) = CONCAT44(fStack_a8,local_ac);
        pfVar17[2] = (float)pvVar9;
        pfVar17[1] = (float)sel_addImageToBackgroundAndSwitchToBitmapSelectionTool_inRect_;
        *pfVar17 = (float)self;
        pfVar17[-1] = 2.01882e-40;
        _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
        pfVar17[1] = (float)sel_sharedLibraryManager;
        *pfVar17 = (float)cls_HSLibraryManager;
        pfVar17[-1] = 2.01916e-40;
        pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
        pfVar17[1] = (float)sel_mediaContentFilter;
        *pfVar17 = (float)pvVar8;
        pfVar17[-1] = 2.01941e-40;
        pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
        pfVar17[2] = (float)local_100;
        pfVar17[1] = (float)sel_globalUIDStringForMediaItem_;
        *pfVar17 = (float)pvVar8;
        pfVar17[-1] = 2.0198e-40;
        pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
        puVar5 = cls_HSMediaCommentsAndAttributionsProvider;
        if (pvVar8 == (id)0x0) {
          pvVar8 = (id)0x0;
LAB_0002334e:
          pfVar17[1] = (float)sel_length;
          *pfVar17 = (float)local_100;
          pfVar17[-1] = 2.02112e-40;
          pvVar9 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          puVar5 = cls_HSEditorCardViewDragHelper;
          if (pvVar9 != (id)0x0) {
            pfVar17[2] = (float)local_100;
            pfVar17[1] = (float)sel_fileURLWithPath_;
            *pfVar17 = (float)cls_NSURL;
            pfVar17[-1] = 2.02179e-40;
            pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
            pfVar17[2] = (float)pvVar8;
            pfVar17[1] = (float)sel_commentsForDroppedObjectWithURL_;
            *pfVar17 = (float)puVar5;
            pfVar17[-1] = 2.0221e-40;
            pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          }
        }
        else {
          pfVar17[2] = (float)pvVar8;
          pfVar17[1] = (float)sel_UIDWithString_;
          *pfVar17 = (float)cls_HSUID;
          pfVar17[-1] = 2.02039e-40;
          pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar17[2] = (float)pvVar8;
          pfVar17[1] = (float)sel_commentsAndAttributionsForMediaUID_;
          *pfVar17 = (float)puVar5;
          pfVar17[-1] = 2.0207e-40;
          pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          if (pvVar8 == (id)0x0) goto LAB_0002334e;
        }
        pfVar17[1] = (float)sel_length;
        *pfVar17 = (float)pvVar8;
        pfVar17[-1] = 2.02244e-40;
        pvVar9 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
        pfVar16 = pfVar17;
        if (pvVar9 != (id)0x0) {
          pfVar17[1] = (float)sel_document;
          *pfVar17 = (float)self;
          pfVar17[-1] = 2.02284e-40;
          pvVar9 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar17[1] = (float)sel_currentCard;
          *pfVar17 = (float)pvVar9;
          pfVar17[-1] = 2.0231e-40;
          pvVar9 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar17[2] = (float)&DAT_00361e20;
          pfVar17[1] = (float)sel_queryHyperInterface_;
          *pfVar17 = (float)pvVar9;
          pfVar17[-1] = 2.02349e-40;
          pvVar9 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          if (pvVar9 == (id)0x0) goto LAB_000227ea;
          pfVar17[1] = (float)sel_hyperComments;
          *pfVar17 = (float)pvVar9;
          pfVar17[-1] = 2.02394e-40;
          pvVar10 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar17[2] = (float)pvVar8;
          pfVar17[1] = (float)sel_hasHyperSubstring_;
          *pfVar17 = (float)pvVar10;
          pfVar17[-1] = 2.02436e-40;
          pvVar11 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          puVar5 = cls_NSString;
          if (pvVar11 != (id)0x0) goto LAB_000227ea;
          pfVar17[1] = (float)sel_length;
          *pfVar17 = (float)pvVar10;
          pfVar17[-1] = 2.02489e-40;
          pvVar11 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar17[5] = (float)pvVar8;
          pcVar13 = &cfstr__;
          if (pvVar11 == (id)0x0) {
            pcVar13 = &cfstr_empty;
          }
          pfVar17[4] = (float)pcVar13;
          pfVar17[3] = (float)pvVar10;
          pfVar17[2] = (float)&cfstr_______;
          pfVar17[1] = (float)sel_stringWithFormat_;
          *pfVar17 = (float)puVar5;
          pfVar17[-1] = 2.02586e-40;
          pvVar8 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar17[2] = (float)pvVar8;
          pfVar17[1] = (float)sel_setHyperComments_;
          goto LAB_000228ee;
        }
        goto LAB_000227ea;
      }
      pHVar14 = (HSEditorWindowController *)cls_HSNewMedia;
      op = sel_mediaWithImage_;
      if (cVar6 == '\0') {
        pvVar8 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
        _objc_msgSend(pvVar8,sel_mediaContentFilter);
        pHVar14 = self;
        op = sel_reusableMediaForPath_contentFilter_;
      }
      _objc_msgSend(pHVar14,op);
      local_3c = 0;
      pvVar8 = _objc_msgSend(cls_HSImageObject,sel_alloc);
      pvVar8 = _objc_msgSend(pvVar8,sel_initWithMedia_error_);
      if ((local_114 != (id)0x0) &&
         (pvVar10 = _objc_msgSend(local_114,sel_length), pvVar10 != (id)0x0)) {
        _objc_msgSend(pvVar8,sel_setHyperName_);
      }
      pvVar10 = _objc_msgSend(cls_HSImageCropApplier,sel_cropApplierForImageObject_);
      _objc_msgSend(pvVar10,sel_updateCurrentBorderPath);
      _objc_msgSend(pvVar10,sel_cropImageObjectWithPaths_modifyObjectGeometry_);
      pvVar10 = _objc_msgSend(pvVar8,sel_queryHyperInterface_);
      _objc_msgSend(pvVar10,sel_setAllClipPathsAsInitial);
      _objc_msgSend(pvVar8,sel_setCurrentClipPathsAreInitial_);
      pvVar10 = _objc_msgSend(pvVar8,sel_queryHyperInterface_);
      pvVar10 = _objc_msgSend(pvVar10,sel_queryGeometryBehaviorApplier);
      if (pvVar10 == (id)0x0) {
        bVar4 = false;
      }
      else {
        pvVar12 = _objc_msgSend(self,sel_document);
        pvVar12 = _objc_msgSend(pvVar12,sel_stack);
        puVar5 = PTR_00336074;
        uVar3 = *(undefined4 *)PTR_00336074;
        uVar1 = *(undefined4 *)(PTR_00336074 + 4);
        local_44 = _objc_msgSend(pvVar12,sel_hyperCardSize);
        local_4c = uVar3;
        uStack_48 = uVar1;
        local_54 = _objc_msgSend(pvVar9,sel_size);
        local_5c = uVar3;
        uStack_58 = uVar1;
        FUN_00012a1c();
        pvVar9 = _objc_msgSend(self,sel_cardView);
        pvVar9 = _objc_msgSend(pvVar9,sel_enclosingScrollView);
        if ((pvVar9 == (id)0x0) || (pvVar11 != (id)0x4)) {
          local_10c = local_60;
          local_114 = (id)local_64;
          pfVar16 = (float *)&stack0xfffffea4;
        }
        else {
          pvVar11 = _objc_msgSend(self,sel_cardView);
          _objc_msgSend_stret(local_34,pvVar9,sel_documentVisibleRect);
          uStack_164 = 0x22cbd;
          _objc_msgSend_stret(&local_7c,pvVar11,sel_userBoundingRectForViewRect_);
          pfVar16 = (float *)&uStack_164;
          local_10c = local_60;
          local_114 = (id)local_64;
          local_6c = ((local_74 * 0.5 + local_7c) - (local_64 * 0.5 + local_6c)) + local_6c;
          local_68 = ((local_70 * 0.5 + local_78) - (local_60 * 0.5 + local_68)) + local_68;
        }
        fVar2 = local_68;
        *pfVar16 = local_6c;
        pfVar16[-1] = 1.99912e-40;
        lVar20 = (longdouble)_roundf();
        *pfVar16 = fVar2;
        pfVar16[-1] = 1.99975e-40;
        local_6c = (float)lVar20;
        lVar21 = (longdouble)_roundf();
        fVar2 = *(float *)puVar5;
        pfVar16[5] = *(float *)(puVar5 + 4);
        pfVar16[4] = fVar2;
        pfVar16[3] = local_10c;
        pfVar16[2] = (float)local_114;
        pfVar16[1] = (float)
                     sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
        ;
        *pfVar16 = (float)pvVar10;
        pfVar16[9] = 0.0;
        pfVar16[8] = 0.0;
        pfVar16[7] = 2.8026e-45;
        pfVar16[6] = 1.4013e-45;
        pfVar16[-1] = 2.00168e-40;
        local_68 = (float)lVar21;
        _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[3] = (float)lVar21;
        pfVar16[2] = (float)lVar20;
        pfVar16[1] = (float)sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_;
        *pfVar16 = (float)pvVar10;
        pfVar16[4] = 0.0;
        pfVar16[-1] = 2.00244e-40;
        _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[1] = (float)sel_document;
        *pfVar16 = (float)self;
        pfVar16[-1] = 2.00274e-40;
        pvVar9 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[1] = (float)sel_currentCard;
        *pfVar16 = (float)pvVar9;
        pfVar16[-1] = 2.00299e-40;
        pvVar9 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[1] = (float)sel_document;
        *pfVar16 = (float)self;
        pfVar16[-1] = 2.00332e-40;
        pvVar10 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[1] = (float)sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode;
        *pfVar16 = (float)pvVar10;
        pfVar16[-1] = 2.00358e-40;
        pvVar10 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        puVar5 = cls_HSEditorCardViewDragHelper;
        if ((char)pvVar10 != '\0') {
          if (cVar6 == '\0') {
            pfVar16[2] = (float)local_100;
            pfVar16[1] = (float)sel_fileURLWithPath_;
            *pfVar16 = (float)cls_NSURL;
            pfVar16[-1] = 2.00443e-40;
            pvVar10 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
            pfVar16[2] = (float)pvVar10;
            pfVar16[1] = (float)sel_commentsForDroppedObjectWithURL_;
            *pfVar16 = (float)puVar5;
            pfVar16[-1] = 2.00474e-40;
            pvVar10 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
          }
          else {
            pvVar10 = (id)0x0;
          }
          pfVar16[1] = (float)sel_length;
          *pfVar16 = (float)pvVar10;
          pfVar16[-1] = 2.00502e-40;
          pvVar11 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
          if (pvVar11 != (id)0x0) {
            pfVar16[2] = (float)&DAT_00361e20;
            pfVar16[1] = (float)sel_queryHyperInterface_;
            *pfVar16 = (float)pvVar8;
            pfVar16[-1] = 2.00555e-40;
            pvVar11 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
            pfVar16[1] = (float)sel_copy;
            *pfVar16 = (float)pvVar10;
            pfVar16[-1] = 2.00583e-40;
            pvVar10 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
            pfVar16[1] = (float)sel_autorelease;
            *pfVar16 = (float)pvVar10;
            pfVar16[-1] = 2.00608e-40;
            pvVar10 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
            pfVar16[2] = (float)pvVar10;
            pfVar16[1] = (float)sel_setHyperComments_;
            *pfVar16 = (float)pvVar11;
            pfVar16[-1] = 2.00639e-40;
            _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
          }
          pfVar16[2] = (float)pvVar8;
          pfVar16[1] = (float)sel_addHyperChild_;
          *pfVar16 = (float)pvVar9;
          pfVar16[-1] = 2.00687e-40;
          _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        }
        pfVar16[1] = (float)sel_didAddNewObject;
        *pfVar16 = (float)self;
        pfVar16[-1] = 2.00716e-40;
        _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        bVar4 = true;
      }
      pfVar16[1] = (float)sel_release;
      *pfVar16 = (float)pvVar8;
      pfVar16[-1] = 2.00753e-40;
      _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
LAB_000224c8:
      puVar5 = cls_HSMovieObject;
      if ((local_100 == (id)0x0) || (bVar4)) goto LAB_000227ec;
      *(undefined **)((int)pfVar16 + 4) = sel_defaultManager;
      *pfVar16 = (float)cls_NSFileManager;
      *(undefined4 *)((int)pfVar16 + -4) = 0x22501;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      *(id *)((int)pfVar16 + 8) = local_100;
      *(undefined **)((int)pfVar16 + 4) = sel_hyperFileTypeAtPath_;
      *pfVar16 = (float)pvVar8;
      *(undefined4 *)((int)pfVar16 + -4) = 0x2251d;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      *(id *)((int)pfVar16 + 8) = pvVar8;
      *(undefined **)((int)pfVar16 + 4) = sel_isMediaTypeSupported_;
      *pfVar16 = (float)puVar5;
      *(undefined4 *)((int)pfVar16 + -4) = 0x22539;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      if ((char)pvVar8 == '\0') goto LAB_000227ec;
      *(undefined **)((int)pfVar16 + 4) = sel_sharedLibraryManager;
      *pfVar16 = (float)cls_HSLibraryManager;
      *(undefined4 *)((int)pfVar16 + -4) = 0x22559;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      *(undefined **)((int)pfVar16 + 4) = sel_moviesContentFilter;
      *pfVar16 = (float)pvVar8;
      *(undefined4 *)((int)pfVar16 + -4) = 0x2256b;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      *(id *)((int)pfVar16 + 0xc) = pvVar8;
      *(id *)((int)pfVar16 + 8) = local_100;
      *(undefined **)((int)pfVar16 + 4) = sel_reusableMediaForPath_contentFilter_;
      *pfVar16 = (float)self;
      *(undefined4 *)((int)pfVar16 + -4) = 0x2258a;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      local_c0 = 0;
      *(undefined **)((int)pfVar16 + 4) = sel_alloc;
      *pfVar16 = (float)cls_HSMovieObject;
      *(undefined4 *)((int)pfVar16 + -4) = 0x225ae;
      pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      *(int **)((int)pfVar16 + 0xc) = &local_c0;
      *(id *)((int)pfVar16 + 8) = pvVar8;
      *(undefined **)((int)pfVar16 + 4) = sel_initWithMedia_error_;
      *pfVar16 = (float)pvVar9;
      *(undefined4 *)((int)pfVar16 + -4) = 0x225ce;
      pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      if (pvVar8 == (id)0x0) {
        if (local_c0 != 0) {
          *(undefined **)((int)pfVar16 + 4) = sel_sharedErrorManager;
          *pfVar16 = (float)cls_HSErrorManager;
          *(undefined4 *)((int)pfVar16 + -4) = 0x225fb;
          pvVar8 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(undefined **)((int)pfVar16 + 4) = sel_window;
          *pfVar16 = (float)self;
          *(undefined4 *)((int)pfVar16 + -4) = 0x22612;
          pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(id *)((int)pfVar16 + 0xc) = pvVar9;
          *(int *)((int)pfVar16 + 8) = local_c0;
          *(undefined **)((int)pfVar16 + 4) = sel_presentError_inWindow_;
          *pfVar16 = (float)pvVar8;
          goto LAB_00023760;
        }
      }
      else {
        *(undefined **)((int)pfVar16 + 8) = &DAT_00361df8;
        *(undefined **)((int)pfVar16 + 4) = sel_queryHyperInterface_;
        *pfVar16 = (float)pvVar8;
        *(undefined4 *)((int)pfVar16 + -4) = 0x234fb;
        pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        *(undefined4 *)((int)pfVar16 + 8) = *(undefined4 *)PTR_00336080;
        *(undefined **)((int)pfVar16 + 4) = sel_actionEventOfType_;
        *pfVar16 = (float)cls_HSActionEvent;
        *(undefined4 *)((int)pfVar16 + -4) = 0x23521;
        pvVar10 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        *(id *)((int)pfVar16 + 8) = pvVar10;
        *(undefined **)((int)pfVar16 + 4) = sel_setAutoPlayActionEvent_;
        *pfVar16 = (float)pvVar9;
        *(undefined4 *)((int)pfVar16 + -4) = 0x23537;
        _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        *(undefined **)((int)pfVar16 + 8) = &DAT_003619d4;
        *(undefined **)((int)pfVar16 + 4) = sel_queryHyperInterface_;
        *pfVar16 = (float)pvVar8;
        *(undefined4 *)((int)pfVar16 + -4) = 0x23559;
        pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        *(undefined **)((int)pfVar16 + 4) = sel_queryGeometryBehaviorApplier;
        *pfVar16 = (float)pvVar9;
        *(undefined4 *)((int)pfVar16 + -4) = 0x2356b;
        pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        if (pvVar9 != (id)0x0) {
          *(undefined **)((int)pfVar16 + 4) = sel_document;
          *pfVar16 = (float)self;
          *(undefined4 *)((int)pfVar16 + -4) = 0x2358e;
          pvVar10 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(undefined **)((int)pfVar16 + 4) = sel_stack;
          *pfVar16 = (float)pvVar10;
          *(undefined4 *)((int)pfVar16 + -4) = 0x235a0;
          pvVar10 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(undefined **)((int)pfVar16 + 4) = sel_hyperCardSize;
          *pfVar16 = (float)pvVar10;
          *(undefined4 *)((int)pfVar16 + -4) = 0x235b2;
          pvVar10 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(undefined **)((int)pfVar16 + 4) = sel_defaultSize;
          *pfVar16 = (float)pvVar8;
          *(undefined4 *)((int)pfVar16 + -4) = 0x235ce;
          pvVar11 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(ulonglong *)((int)pfVar16 + 0x18) = CONCAT44(extraout_EDX,pvVar10);
          *(undefined8 *)((int)pfVar16 + 0x10) = 0;
          *(ulonglong *)((int)pfVar16 + 8) = CONCAT44(extraout_EDX_00,pvVar11);
          *(undefined8 *)pfVar16 = 0;
          *(undefined4 *)((int)pfVar16 + -4) = 0x23656;
          FUN_00012a1c();
          uVar3 = *(undefined4 *)PTR_00336074;
          *(undefined4 *)((int)pfVar16 + 0x14) = *(undefined4 *)(PTR_00336074 + 4);
          *(undefined4 *)((int)pfVar16 + 0x10) = uVar3;
          *(undefined4 *)((int)pfVar16 + 0xc) = local_e8;
          *(undefined4 *)((int)pfVar16 + 8) = local_ec;
          *(undefined **)((int)pfVar16 + 4) =
               sel_resizeFrameTo_aboutRelativePoint_withLayoutGuidingContext_;
          *pfVar16 = (float)pvVar9;
          *(undefined4 *)((int)pfVar16 + 0x18) = 0;
          *(undefined4 *)((int)pfVar16 + -4) = 0x236ad;
          _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(undefined4 *)((int)pfVar16 + 0xc) = local_f0;
          *(undefined4 *)((int)pfVar16 + 8) = local_f4;
          *(undefined **)((int)pfVar16 + 4) =
               sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_;
          *pfVar16 = (float)pvVar9;
          *(undefined4 *)((int)pfVar16 + 0x10) = 0;
          *(undefined4 *)((int)pfVar16 + -4) = 0x236e9;
          _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        }
        *(undefined **)((int)pfVar16 + 4) = sel_document;
        *pfVar16 = (float)self;
        *(undefined4 *)((int)pfVar16 + -4) = 0x236fe;
        pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        *(undefined **)((int)pfVar16 + 4) =
             sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode;
        *pfVar16 = (float)pvVar9;
        *(undefined4 *)((int)pfVar16 + -4) = 0x23710;
        pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        if ((char)pvVar9 != '\0') {
          *(undefined **)((int)pfVar16 + 4) = sel_cardView;
          *pfVar16 = (float)self;
          *(undefined4 *)((int)pfVar16 + -4) = 0x23729;
          pvVar9 = _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
          *(id *)((int)pfVar16 + 8) = pvVar8;
          *(undefined **)((int)pfVar16 + 4) = sel_addObjectToCenter_useDragPreferences_;
          *pfVar16 = (float)pvVar9;
          *(undefined4 *)((int)pfVar16 + 0xc) = 0;
          *(undefined4 *)((int)pfVar16 + -4) = 0x2374d;
          _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
        }
        *(undefined **)((int)pfVar16 + 4) = sel_release;
        *pfVar16 = (float)pvVar8;
LAB_00023760:
        *(undefined4 *)((int)pfVar16 + -4) = 0x23765;
        _objc_msgSend((id)*pfVar16,*(SEL *)((int)pfVar16 + 4));
      }
      *(undefined **)((int)pfVar16 + 4) = sel_didAddNewObject;
      pHVar14 = self;
LAB_000237d7:
      *pfVar16 = (float)pHVar14;
      pfVar16[-1] = 2.03714e-40;
      _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
    }
    else {
      pvVar8 = _objc_msgSend(self,sel_document);
      pvVar8 = _objc_msgSend(pvVar8,sel_currentCard);
      _objc_msgSend(pvVar8,sel_importBackgroundFromImage_imageScalingOption_eraseBackground_);
      if (cVar6 == '\0') {
        pvVar9 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
        pvVar9 = _objc_msgSend(pvVar9,sel_mediaContentFilter);
        pvVar9 = _objc_msgSend(pvVar9,sel_globalUIDStringForMediaItem_);
        puVar5 = cls_HSMediaCommentsAndAttributionsProvider;
        if (pvVar9 == (id)0x0) goto LAB_000226e5;
        _objc_msgSend(cls_HSUID,sel_UIDWithString_);
        pvVar9 = _objc_msgSend(puVar5,sel_commentsAndAttributionsForMediaUID_);
        if (pvVar9 == (id)0x0) goto LAB_00022772;
      }
      else {
LAB_000226e5:
        pvVar9 = (id)0x0;
LAB_00022772:
        pvVar10 = _objc_msgSend(local_100,sel_length);
        puVar5 = cls_HSEditorCardViewDragHelper;
        if (pvVar10 != (id)0x0) {
          _objc_msgSend(cls_NSURL,sel_fileURLWithPath_);
          pvVar9 = _objc_msgSend(puVar5,sel_commentsForDroppedObjectWithURL_);
        }
      }
      pvVar9 = _objc_msgSend(pvVar9,sel_length);
      pfVar16 = (float *)&stack0xfffffea4;
      if ((pvVar9 != (id)0x0) &&
         (pvVar9 = _objc_msgSend(pvVar8,sel_queryHyperInterface_),
         pfVar16 = (float *)&stack0xfffffea4, pvVar9 != (id)0x0)) {
        pvVar8 = _objc_msgSend(pvVar9,sel_hyperComments);
        pvVar10 = _objc_msgSend(pvVar8,sel_hasHyperSubstring_);
        puVar5 = cls_NSString;
        pfVar16 = (float *)&stack0xfffffea4;
        if (pvVar10 == (id)0x0) {
          _objc_msgSend(pvVar8,sel_length);
          _objc_msgSend(puVar5,sel_stringWithFormat_);
LAB_000228ee:
          *pfVar17 = (float)pvVar9;
          pfVar17[-1] = 1.98365e-40;
          _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
          pfVar16 = pfVar17;
        }
      }
LAB_000227ea:
      bVar4 = true;
LAB_000227ec:
      if (!bVar4 && !bVar19) {
        pfVar16[1] = (float)sel_code;
        *pfVar16 = (float)local_38;
        pfVar16[-1] = 1.98039e-40;
        pvVar8 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        if (pvVar8 == (id)0x0) {
          pvVar8 = (id)0x103;
        }
        else {
          pfVar16[1] = (float)sel_code;
          *pfVar16 = (float)local_38;
          pfVar16[-1] = 2.03593e-40;
          pvVar8 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        }
        pfVar16[3] = (float)local_100;
        pfVar16[2] = (float)pvVar8;
        pfVar16[1] = (float)sel_fileErrorWithHSCode_filePath_;
        *pfVar16 = (float)cls_HSError;
        pfVar16[-1] = 2.03647e-40;
        pvVar8 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[1] = (float)sel_sharedErrorManager;
        *pfVar16 = (float)cls_HSErrorManager;
        pfVar16[-1] = 2.03683e-40;
        pHVar14 = _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
        pfVar16[2] = (float)pvVar8;
        pfVar16[1] = (float)sel_presentError_;
        goto LAB_000237d7;
      }
    }
    pfVar16[1] = (float)sel_release;
    *pfVar16 = (float)pvVar7;
    pfVar16[-1] = 2.03747e-40;
    _objc_msgSend((id)*pfVar16,(SEL)pfVar16[1]);
    puVar18 = pfVar16;
  }
  puVar18[1] = sel_hyperDocument;
  *puVar18 = importBackgroundDialogDidEnd;
  puVar18[-1] = 0x2380c;
  pvVar7 = _objc_msgSend((id)*puVar18,(SEL)puVar18[1]);
  puVar18[1] = sel_document;
  *puVar18 = self;
  puVar18[-1] = 0x23823;
  pvVar8 = _objc_msgSend((id)*puVar18,(SEL)puVar18[1]);
  if (pvVar7 != pvVar8) {
    return;
  }
  puVar18[1] = sel_setHyperDocument_;
  *puVar18 = importBackgroundDialogDidEnd;
  puVar18[2] = 0;
  puVar15 = puVar18;
LAB_00022645:
  puVar15[-1] = 0x2264a;
  _objc_msgSend((id)*puVar15,(SEL)puVar15[1]);
  return;
}

*/
- (void)importBackgroundDialogDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id options = [aEnd dialogUserOptions];
        BOOL isCapture = [[options valueForKey:HSCaptureImageKey] boolValue];
        BOOL isCropped = [[options valueForKey:HSImportDialogGraphicsOptionKeyIsImageCropped] boolValue];
        id type = [aEnd dialogType];
        NSInteger layout = [[options valueForKey:HSImportDialogGraphicsOptionKeyLayout] intValue];
        id clipPaths = nil;
        if (isCropped) {
            clipPaths = [options valueForKey:HSImportDialogGraphicsOptionKeyClipPaths];
        }
        id croppedImage = [options valueForKey:HSImportDialogGraphicsOptionKeyCroppedImage];
        NSString *path = [aEnd fileName];
        NSString *displayName = [aEnd fileDisplayName];
        BOOL fileMissing = NO;
        if (!isCapture) {
            path = [self checkFileExistenceAtPath:path expectedType:kHSImageFileType];
            fileMissing = (path == nil);
        }
        NSError *error = nil;
        NSImage *image = nil;
        if (!fileMissing && !isCapture) {
            image = [[self class] loadImageAtPath:path error:&error];
        }
        if (isCapture) {
            id controller = [[[HSCaptureImageController alloc] init] autorelease];
            if ([controller runModal] != 1) {
                [pool release];
                return;
            }
            image = [controller capturedImage];
            [image setScalesWhenResized:YES];
            displayName = [[NSBundle mainBundle] localizedStringForKey:@"Captured Image" value:@"" table:nil];
            croppedImage = nil;
        }
        if (croppedImage != nil) {
            image = croppedImage;
        }
        BOOL success = NO;
        if (image != nil) {
            if ([type isEqualToString:HSImportDialogControllerTypeBackground]) {
                id card = [[self document] currentCard];
                [card importBackgroundFromImage:image imageScalingOption:layout eraseBackground:NO];
                NSString *comments = HSEditorImportedCommentsForPath(path, isCapture);
                if ([comments length] != 0) {
                    id target = [card queryHyperInterface:@protocol(HSCommentsAttributes)];
                    if (target != nil) {
                        NSString *existing = [target hyperComments];
                        if (![existing hasHyperSubstring:comments]) {
                            [target setHyperComments:[NSString stringWithFormat:@"%@%@%@", existing, [existing length] == 0 ? @"" : @"\n", comments]];
                        }
                    }
                }
                success = YES;
            } else if ([type isEqualToString:HSImportDialogControllerTypeGraphicObject]) {
                id media;
                if (isCapture) {
                    media = [HSNewMedia mediaWithImage:image];
                } else {
                    media = [self reusableMediaForPath:path contentFilter:[[HSLibraryManager sharedLibraryManager] mediaContentFilter]];
                }
                error = nil;
                id object = [[HSImageObject alloc] initWithMedia:media error:&error];
                if (displayName != nil && [displayName length] != 0) {
                    [object setHyperName:displayName];
                }
                id cropApplier = [HSImageCropApplier cropApplierForImageObject:object];
                [cropApplier updateCurrentBorderPath];
                [cropApplier cropImageObjectWithPaths:clipPaths modifyObjectGeometry:YES];
                [[object queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] setAllClipPathsAsInitial];
                [object setCurrentClipPathsAreInitial:NO];
                id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
                if (applier == nil) {
                    success = NO;
                } else {
                    NSSize cardSize = [[[self document] stack] hyperCardSize];
                    NSRect rect = HSEditorImportFitRect(layout, NSMakeRect(0.0f, 0.0f, [image size].width, [image size].height), NSMakeRect(0.0f, 0.0f, cardSize.width, cardSize.height));
                    NSScrollView *scrollView = [[self cardView] enclosingScrollView];
                    if (scrollView != nil && layout == 4) {
                        NSRect visible = [scrollView documentVisibleRect];
                        NSRect userRect = [[self cardView] userBoundingRectForViewRect:visible];
                        rect.origin.x = ((userRect.size.width * 0.5f + userRect.origin.x) - (rect.size.width * 0.5f + rect.origin.x)) + rect.origin.x;
                        rect.origin.y = ((userRect.size.height * 0.5f + userRect.origin.y) - (rect.size.height * 0.5f + rect.origin.y)) + rect.origin.y;
                    }
                    rect.origin.x = roundf(rect.origin.x);
                    rect.origin.y = roundf(rect.origin.y);
                    [applier resizeFrameTo:rect.size aboutRelativePoint:NSZeroPoint followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
                    [applier moveFrameBoundingRectOriginTo:rect.origin withLayoutGuidingContext:nil];
                    id card = [[self document] currentCard];
                    if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
                        NSString *comments = nil;
                        if (!isCapture) {
                            comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:path]];
                        }
                        if ([comments length] != 0) {
                            [[object queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
                        }
                        [card addHyperChild:object];
                    }
                    [self didAddNewObject];
                    success = YES;
                }
                [object release];
            } else if ([type isEqualToString:HSImportDialogControllerTypeGraphic]) {
                if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
                    NSSize cardSize = [[[self document] stack] hyperCardSize];
                    NSRect rect = HSEditorImportFitRect(layout, NSMakeRect(0.0f, 0.0f, [image size].width, [image size].height), NSMakeRect(0.0f, 0.0f, cardSize.width, cardSize.height));
                    NSScrollView *scrollView = [[self cardView] enclosingScrollView];
                    if ((layout == 4 || layout == 5) && scrollView != nil) {
                        NSRect visible = [scrollView documentVisibleRect];
                        NSRect userRect = [[self cardView] userBoundingRectForViewRect:visible];
                        rect.origin.x = ((userRect.size.width * 0.5f + userRect.origin.x) - (rect.size.width * 0.5f + rect.origin.x)) + rect.origin.x;
                        rect.origin.y = ((userRect.size.height * 0.5f + userRect.origin.y) - (rect.size.height * 0.5f + rect.origin.y)) + rect.origin.y;
                    }
                    rect.origin.x = roundf(rect.origin.x);
                    rect.origin.y = roundf(rect.origin.y);
                    [self addImageToBackgroundAndSwitchToBitmapSelectionTool:image inRect:rect];
                    NSString *comments = HSEditorImportedCommentsForPath(path, isCapture);
                    if ([comments length] != 0) {
                        id target = [[[self document] currentCard] queryHyperInterface:@protocol(HSCommentsAttributes)];
                        if (target != nil) {
                            NSString *existing = [target hyperComments];
                            if (![existing hasHyperSubstring:comments]) {
                                [target setHyperComments:[NSString stringWithFormat:@"%@%@%@", existing, [existing length] == 0 ? @"" : @"\n", comments]];
                            }
                        }
                    }
                    success = YES;
                }
            }
        }
        if (path != nil && !success) {
            if ([HSMovieObject isMediaTypeSupported:[[NSFileManager defaultManager] hyperFileTypeAtPath:path]]) {
                id media = [self reusableMediaForPath:path contentFilter:[[HSLibraryManager sharedLibraryManager] moviesContentFilter]];
                NSError *movieError = nil;
                id object = [[HSMovieObject alloc] initWithMedia:media error:&movieError];
                if (object == nil) {
                    if (movieError != nil) {
                        [[HSErrorManager sharedErrorManager] presentError:movieError inWindow:[self window]];
                    }
                } else {
                    [[object queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoPlayActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
                    id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
                    if (applier != nil) {
                        NSSize cardSize = [[[self document] stack] hyperCardSize];
                        NSSize defaultSize = [object defaultSize];
                        NSRect rect = HSEditorImportFitRect(layout, NSMakeRect(0.0f, 0.0f, defaultSize.width, defaultSize.height), NSMakeRect(0.0f, 0.0f, cardSize.width, cardSize.height));
                        [applier resizeFrameTo:rect.size aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
                        [applier moveFrameBoundingRectOriginTo:rect.origin withLayoutGuidingContext:nil];
                    }
                    if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
                        [[self cardView] addObjectToCenter:object useDragPreferences:NO];
                    }
                    [object release];
                }
                [self didAddNewObject];
                success = YES;
            }
        }
        if (!success && !fileMissing) {
            NSInteger code = (error == nil) ? 0x103 : [error code];
            [[HSErrorManager sharedErrorManager] presentError:[HSError fileErrorWithHSCode:code filePath:path]];
        }
        [pool release];
    }
    if ([aEnd hyperDocument] != [self document]) {
        return;
    }
    [aEnd setHyperDocument:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b8b0 @ 0001b8b0, 72 bytes * /

void FUN_0001b8b0(HSEditorWindowController *self,SEL _cmd,
                 id addImageToBackgroundAndSwitchToBitmapSelectionTool,NSRect inRect)

{
  _objc_msgSend(self->_cardView,sel_addImageToBackgroundAndSwitchToBitmapSelectionTool_inRect_,
                addImageToBackgroundAndSwitchToBitmapSelectionTool,inRect.origin,inRect.size);
  return;
}

*/
- (void)addImageToBackgroundAndSwitchToBitmapSelectionTool:(id)aTool inRect:(NSRect)aRect
{
    [_cardView addImageToBackgroundAndSwitchToBitmapSelectionTool:aTool inRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b75f @ 0001b75f, 337 bytes * /

void FUN_0001b75f(HSEditorWindowController *self,SEL _cmd,id importBackground)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = self->_importBackgroundDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360d0);
    self->_importBackgroundDialogController = pvVar1;
  }
  _objc_msgSend(self,sel_setSettingsForGraphicImportDialogController_,pvVar1);
  _objc_msgSend(self->_importBackgroundDialogController,sel_setCaptureImageButtonEnabled_,1);
  pvVar1 = self->_importBackgroundDialogController;
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  self_00 = cls_HSImportDialogController;
  pvVar1 = self->_importBackgroundDialogController;
  pvVar2 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar1 = _objc_msgSend(self->_importBackgroundDialogController,sel_runModal);
  _objc_msgSend(self,sel_importBackgroundDialogDidEnd_returnCode_contextInfo_,
                self->_importBackgroundDialogController,pvVar1,0);
  return;
}

*/
- (void)importBackground:(id)aBackground
{
    if (_importBackgroundDialogController == nil) {
        _importBackgroundDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeBackground];
    }
    [self setSettingsForGraphicImportDialogController:_importBackgroundDialogController];
    [_importBackgroundDialogController setCaptureImageButtonEnabled:YES];
    [_importBackgroundDialogController setHyperDocument:[self document]];
    [_importBackgroundDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self cardView] card]]];
    [self importBackgroundDialogDidEnd:_importBackgroundDialogController returnCode:[_importBackgroundDialogController runModal] contextInfo:NULL];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b60e @ 0001b60e, 337 bytes * /

void FUN_0001b60e(HSEditorWindowController *self,SEL _cmd,id addGraphicObject)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = self->_importGraphicObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360d8);
    self->_importGraphicObjectDialogController = pvVar1;
  }
  _objc_msgSend(self,sel_setSettingsForGraphicImportDialogController_,pvVar1);
  _objc_msgSend(self->_importGraphicObjectDialogController,sel_setCaptureImageButtonEnabled_,1);
  pvVar1 = self->_importGraphicObjectDialogController;
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  self_00 = cls_HSImportDialogController;
  pvVar1 = self->_importGraphicObjectDialogController;
  pvVar2 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar1 = _objc_msgSend(self->_importGraphicObjectDialogController,sel_runModal);
  _objc_msgSend(self,sel_importBackgroundDialogDidEnd_returnCode_contextInfo_,
                self->_importGraphicObjectDialogController,pvVar1,0);
  return;
}

*/
- (void)addGraphicObject:(id)aObject
{
    if (_importGraphicObjectDialogController == nil) {
        _importGraphicObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeGraphicObject];
    }
    [self setSettingsForGraphicImportDialogController:_importGraphicObjectDialogController];
    [_importGraphicObjectDialogController setCaptureImageButtonEnabled:YES];
    [_importGraphicObjectDialogController setHyperDocument:[self document]];
    [_importGraphicObjectDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self cardView] card]]];
    [self importBackgroundDialogDidEnd:_importGraphicObjectDialogController returnCode:[_importGraphicObjectDialogController runModal] contextInfo:NULL];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b4bd @ 0001b4bd, 337 bytes * /

void FUN_0001b4bd(HSEditorWindowController *self,SEL _cmd,id addGraphic)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = self->_importGraphicDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360d4);
    self->_importGraphicDialogController = pvVar1;
  }
  _objc_msgSend(self,sel_setSettingsForGraphicImportDialogController_,pvVar1);
  _objc_msgSend(self->_importGraphicDialogController,sel_setCaptureImageButtonEnabled_,1);
  pvVar1 = self->_importGraphicDialogController;
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  self_00 = cls_HSImportDialogController;
  pvVar1 = self->_importGraphicDialogController;
  pvVar2 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar1 = _objc_msgSend(self->_importGraphicDialogController,sel_runModal);
  _objc_msgSend(self,sel_importBackgroundDialogDidEnd_returnCode_contextInfo_,
                self->_importGraphicDialogController,pvVar1,0);
  return;
}

*/
- (void)addGraphic:(id)aGraphic
{
    if (_importGraphicDialogController == nil) {
        _importGraphicDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeGraphic];
    }
    [self setSettingsForGraphicImportDialogController:_importGraphicDialogController];
    [_importGraphicDialogController setCaptureImageButtonEnabled:YES];
    [_importGraphicDialogController setHyperDocument:[self document]];
    [_importGraphicDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self cardView] card]]];
    [self importBackgroundDialogDidEnd:_importGraphicDialogController returnCode:[_importGraphicDialogController runModal] contextInfo:NULL];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b452 @ 0001b452, 107 bytes * /

void FUN_0001b452(HSEditorWindowController *self,SEL _cmd,
                 id setSettingsForGraphicImportDialogController)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_selectionToolTolerance);
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar1,
                         *(undefined4 *)PTR_PTR_003360f8);
  _objc_msgSend(setSettingsForGraphicImportDialogController,sel_setOptions_,pvVar1);
  return;
}

*/
- (void)setSettingsForGraphicImportDialogController:(id)aController
{
    [aController setOptions:[NSDictionary dictionaryWithObject:[self selectionToolTolerance] forKey:@"selectionTolerance"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001b3c5 @ 0001b3c5, 141 bytes * /

id FUN_0001b3c5(HSEditorWindowController *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  uVar2 = *(undefined4 *)PTR_PTR_003360f8;
  pvVar1 = _objc_msgSend(pvVar1,sel_settingForIdentifier_andKey_,*(undefined4 *)PTR_PTR_003360f4,
                         uVar2);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,0,uVar2);
  }
  return pvVar1;
}

*/
- (id)selectionToolTolerance
{
    id tolerance = [[[HSToolManager sharedToolManager] toolSettings] settingForIdentifier:@"HSLassoSelectionTool" andKey:@"selectionTolerance"];
    if (tolerance == nil) {
        tolerance = [NSNumber numberWithFloat:0.0f];
    }
    return tolerance;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001af71 @ 0001af71, 1108 bytes * /

void FUN_0001af71(HSEditorWindowController *self,SEL _cmd,id addSoundObject)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  undefined *puVar4;
  id pvVar5;
  undefined *puVar6;
  id pvVar7;
  SEL op;
  undefined *local_18;
  id local_14;
  
  pvVar1 = self->_importSoundObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360dc);
    self->_importSoundObjectDialogController = pvVar1;
  }
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  puVar4 = cls_HSImportDialogController;
  pvVar1 = self->_importSoundObjectDialogController;
  pvVar2 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(puVar4,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar2 = _objc_msgSend(self->_importSoundObjectDialogController,sel_runModal);
  pvVar1 = _objc_msgSend(self->_importSoundObjectDialogController,sel_fileName);
  if (pvVar1 == (id)0x0) {
    return;
  }
  puVar4 = *(undefined **)PTR_00336168;
  puVar3 = _objc_msgSend(self,sel_checkFileExistenceAtPath_expectedType_,pvVar1,puVar4);
  if (pvVar2 != (id)0x1) {
    return;
  }
  if (puVar3 == (undefined *)0x0) {
    return;
  }
  if (self->_playSoundActionEvent == (id)0x0) {
    pvVar1 = *(id *)PTR_00336080;
    pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,pvVar1,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_playSoundActionEvent = pvVar2;
  }
  pvVar1 = _objc_msgSend(self,sel_document,pvVar1,puVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentCard);
  puVar6 = &DAT_00361d6c;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361d6c);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager,puVar6);
    puVar4 = _objc_msgSend(pvVar2,sel_soundsContentFilter);
    puVar6 = puVar3;
    pvVar2 = _objc_msgSend(self,sel_reusableMediaForPath_contentFilter_,puVar3,puVar4);
    if (pvVar2 != (id)0x0) {
      pvVar5 = _objc_msgSend(cls_HSMovie,sel_alloc,puVar6,puVar4);
      puVar6 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,puVar3);
      puVar4 = (undefined *)0x0;
      local_18 = _objc_msgSend(pvVar5,sel_initWithURL_error_,puVar6,0);
      if (local_18 == (undefined *)0x0) {
        puVar3 = (undefined *)0x0;
        local_14 = (id)0x0;
      }
      else {
        pvVar5 = _objc_msgSend(cls_HSSoundItem,sel_alloc,puVar6,puVar4);
        puVar6 = _objc_msgSend(pvVar2,sel_mediaUID);
        puVar4 = local_18;
        local_14 = _objc_msgSend(pvVar5,sel_initWithMediaUID_andApplyOptionsFromSound_,puVar6,
                                 local_18);
        if (local_14 == (id)0x0) {
          puVar3 = (undefined *)0x0;
        }
        else {
          puVar3 = _objc_msgSend(cls_HSPlaySoundAction,sel_new,puVar6,puVar4);
          pvVar2 = self->_playSoundActionEvent;
          pvVar5 = _objc_msgSend(cls_HSPlaySoundAction,sel_actionType);
          pvVar5 = _objc_msgSend(pvVar1,sel_hyperActionsOfType_forEvent_,pvVar5,pvVar2);
          _objc_msgSend(puVar3,sel_addSound_,local_14);
          pvVar7 = _objc_msgSend(pvVar5,sel_count);
          if (pvVar7 == (id)0x0) {
            puVar4 = self->_playSoundActionEvent;
            op = sel_addHyperAction_forEvent_;
            puVar6 = puVar3;
          }
          else {
            _objc_msgSend(cls_NSArray,sel_arrayWithObject_,self->_playSoundActionEvent,pvVar2);
            puVar6 = _objc_msgSend(pvVar5,sel_extraFirstObject);
            op = sel_replaceHyperAction_withAction_forEvents_;
            puVar4 = puVar3;
          }
          _objc_msgSend(pvVar1,op,puVar6,puVar4);
          _objc_msgSend(self,sel_didAddNewObject);
        }
      }
      goto LAB_0001b381;
    }
  }
  puVar3 = (undefined *)0x0;
  local_18 = (undefined *)0x0;
  local_14 = (id)0x0;
LAB_0001b381:
  _objc_msgSend(local_18,sel_release,puVar6,puVar4);
  _objc_msgSend(local_14,sel_release);
  _objc_msgSend(puVar3,sel_release);
  return;
}

*/
- (void)addSoundObject:(id)aObject
{
    if (_importSoundObjectDialogController == nil) {
        _importSoundObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeSound];
    }
    [_importSoundObjectDialogController setHyperDocument:[self document]];
    [_importSoundObjectDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self cardView] card]]];
    NSInteger code = [_importSoundObjectDialogController runModal];
    id fileName = [_importSoundObjectDialogController fileName];
    if (fileName == nil) {
        return;
    }
    id path = [self checkFileExistenceAtPath:fileName expectedType:kHSSoundFileType];
    if (code != 1 || path == nil) {
        return;
    }
    if (_playSoundActionEvent == nil) {
        _playSoundActionEvent = [[HSActionEvent actionEventOfType:kHSArriveActionEventType] retain];
    }
    id actor = [[[self document] currentCard] queryHyperInterface:@protocol(HSActor)];
    id movie = nil;
    id sound = nil;
    id action = nil;
    if (actor != nil) {
        id media = [self reusableMediaForPath:path contentFilter:[[HSLibraryManager sharedLibraryManager] soundsContentFilter]];
        if (media != nil) {
            movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:NULL];
            if (movie != nil) {
                sound = [[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:movie];
                if (sound != nil) {
                    action = [HSPlaySoundAction new];
                    id existing = [actor hyperActionsOfType:[HSPlaySoundAction actionType] forEvent:_playSoundActionEvent];
                    [action addSound:sound];
                    if ([existing count] == 0) {
                        [actor addHyperAction:action forEvent:_playSoundActionEvent];
                    } else {
                        [actor replaceHyperAction:[existing extraFirstObject] withAction:action forEvents:[NSArray arrayWithObject:_playSoundActionEvent]];
                    }
                    [self didAddNewObject];
                }
            }
        }
    }
    [movie release];
    [sound release];
    [action release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001a59a @ 0001a59a, 2519 bytes * /

void FUN_0001a59a(HSEditorWindowController *self,SEL _cmd,id addMediaObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *self_00;
  id pvVar7;
  id self_01;
  undefined **extraout_EDX;
  float extraout_EDX_00;
  bool bVar8;
  float fVar9;
  SEL op;
  undefined **ppuVar10;
  id local_24;
  undefined **local_1c;
  undefined *local_18;
  undefined *local_14;
  
  pvVar1 = self->_importMoviesObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360cc);
    self->_importMoviesObjectDialogController = pvVar1;
  }
  pvVar2 = _objc_msgSend(self,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  puVar5 = cls_HSImportDialogController;
  pvVar1 = self->_importMoviesObjectDialogController;
  pvVar2 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(puVar5,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar1 = _objc_msgSend(self->_importMoviesObjectDialogController,sel_runModal);
  if (pvVar1 != (id)0x1) {
    return;
  }
  pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
  pvVar2 = _objc_msgSend(self->_importMoviesObjectDialogController,sel_dialogUserOptions);
  pvVar2 = _objc_msgSend(pvVar2,sel_valueForKey_,*(undefined4 *)PTR_PTR_003360f0);
  pvVar3 = _objc_msgSend(self->_importMoviesObjectDialogController,sel_fileName);
  local_1c = *(undefined ***)PTR_00336164;
  puVar4 = _objc_msgSend(self,sel_checkFileExistenceAtPath_expectedType_,pvVar3,local_1c);
  puVar5 = &DAT_00361b78;
  pvVar3 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_00361b78);
  puVar6 = cls_HSMovieObject;
  if (((char)pvVar3 == '\0') && (puVar4 == (undefined *)0x0)) {
    puVar6 = &DAT_00361e48;
    pvVar1 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_00361e48,local_1c);
    puVar5 = puVar6;
    ppuVar10 = local_1c;
    if ((char)pvVar1 == '\0') goto LAB_0001af54;
    local_18 = _objc_msgSend(pvVar2,sel_copy,puVar6,local_1c);
LAB_0001af0f:
    pvVar1 = _objc_msgSend(self,sel_cardView,puVar6,local_1c);
    local_1c = (undefined **)0x0;
    puVar6 = local_18;
    _objc_msgSend(pvVar1,sel_addObjectToCenter_useDragPreferences_,local_18,0);
    op = sel_release;
  }
  else {
    ppuVar10 = local_1c;
    if (puVar4 == (undefined *)0x0) goto LAB_0001af54;
    pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,puVar5,local_1c);
    puVar5 = _objc_msgSend(pvVar3,sel_hyperFileTypeAtPath_,puVar4);
    pvVar3 = _objc_msgSend(puVar6,sel_isMediaTypeSupported_,puVar5);
    ppuVar10 = local_1c;
    if ((char)pvVar3 == '\0') goto LAB_0001af54;
    pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,puVar5);
    ppuVar10 = (undefined **)0x1;
    puVar5 = puVar4;
    pvVar3 = _objc_msgSend(pvVar3,sel_canImportFileAtPath_showAlert_,puVar4,1);
    if ((char)pvVar3 == '\0') goto LAB_0001af54;
    pvVar3 = _objc_msgSend(self,sel_document,puVar5,ppuVar10);
    ppuVar10 = _objc_msgSend(pvVar3,sel_currentCard);
    pvVar3 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
    local_1c = _objc_msgSend(pvVar3,sel_moviesContentFilter);
    puVar5 = puVar4;
    puVar6 = _objc_msgSend(self,sel_reusableMediaForPath_contentFilter_,puVar4,local_1c);
    local_14 = (undefined *)0x0;
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSMovieObject,sel_alloc,puVar5,local_1c);
      local_1c = &local_14;
      puVar5 = puVar6;
      local_18 = _objc_msgSend(pvVar2,sel_initWithMedia_error_,puVar6,local_1c);
      if (local_18 != (undefined *)0x0) {
        puVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,local_18,local_1c);
        local_1c = ppuVar10;
        pvVar2 = _objc_msgSend(self,sel_verifyObjects_beforeAddToCard_,puVar5,ppuVar10);
        pvVar3 = _objc_msgSend(pvVar2,sel_count);
        if (pvVar3 != (id)0x0) {
          _objc_msgSend(local_18,sel_release,puVar5,local_1c);
          pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
          bVar8 = true;
          local_18 = _objc_msgSend(pvVar2,sel_retain);
          goto LAB_0001aa16;
        }
      }
      bVar8 = true;
    }
    else {
      local_18 = _objc_msgSend(pvVar2,sel_copy,puVar5,local_1c);
      pvVar2 = _objc_msgSend(cls_HSUID,sel_UID);
      _objc_msgSend(local_18,sel_setHyperUID_,pvVar2);
      puVar5 = &DAT_00361d6c;
      pvVar2 = _objc_msgSend(local_18,sel_queryHyperInterface_,&DAT_00361d6c);
      self_00 = _objc_msgSend(pvVar2,sel_hyperActions);
      pvVar3 = _objc_msgSend(self_00,sel_count);
      if (pvVar3 != (id)0x0) {
        _objc_msgSend(pvVar2,sel_removeActions_,self_00);
        puVar5 = self_00;
      }
      bVar8 = local_18 == (undefined *)0x0;
    }
LAB_0001aa16:
    if (local_18 == (undefined *)0x0) {
      if (local_14 == (undefined *)0x0) {
        puVar5 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,puVar4,local_1c);
        local_1c = &local_14;
        ppuVar10 = local_1c;
        pvVar1 = _objc_msgSend(cls_HSMovie,sel_movieWithURL_error_,puVar5,local_1c);
        if (((local_14 != (undefined *)0x0) || (pvVar1 == (id)0x0)) ||
           ((pvVar2 = _objc_msgSend(pvVar1,sel_isGifMovie,puVar5,ppuVar10), (char)pvVar2 == '\0' ||
            (pvVar1 = _objc_msgSend(pvVar1,sel_hasMultiplySamples,puVar5,ppuVar10),
            (char)pvVar1 != '\0')))) goto LAB_0001af54;
        pvVar1 = _objc_msgSend(cls_HSImageObject,sel_alloc,puVar5,ppuVar10);
        local_18 = _objc_msgSend(pvVar1,sel_initWithMedia_error_,puVar6,local_1c);
        pvVar1 = _objc_msgSend(self,sel_document);
        pvVar1 = _objc_msgSend(pvVar1,
                               sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
        op = sel_release;
        if ((char)pvVar1 != '\0') goto LAB_0001af0f;
      }
      else {
        local_18 = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager,puVar5,local_1c);
        local_1c = _objc_msgSend(self,sel_window);
        op = sel_presentError_inWindow_;
        puVar6 = local_14;
      }
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_document,puVar5,local_1c);
      pvVar2 = _objc_msgSend(pvVar2,
                             sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
      op = sel_release;
      puVar6 = puVar5;
      if ((char)pvVar2 != '\0') {
        puVar5 = &DAT_00361218;
        pvVar2 = _objc_msgSend(local_18,sel_queryHyperInterface_,&DAT_00361218);
        if ((pvVar2 != (id)0x0) && (bVar8)) {
          pvVar3 = _objc_msgSend(ppuVar10,sel_support,puVar5);
          _objc_msgSend(pvVar2,sel_setSupport_,pvVar3);
          pvVar3 = _objc_msgSend(ppuVar10,sel_queryHyperInterface_,&DAT_003614fc);
          local_24 = _objc_msgSend(pvVar3,sel_size);
          puVar5 = &DAT_00361de4;
          pvVar3 = _objc_msgSend(local_18,sel_queryHyperInterface_,&DAT_00361de4);
          pvVar7 = _objc_msgSend(pvVar3,sel_size);
          if ((pvVar3 != (id)0x0) &&
             ((((float)local_24 < (float)pvVar7 || ((float)extraout_EDX < extraout_EDX_00)) ||
              ((float)local_24 * (float)extraout_EDX * 0.9 < (float)pvVar7 * extraout_EDX_00)))) {
            self_01 = _objc_msgSend(ppuVar10,sel_undoManager,puVar5);
            fVar9 = (float)pvVar7 / extraout_EDX_00;
            _objc_msgSend(self_01,sel_disableUndoRegistration);
            if (fVar9 <= (float)local_24 / (float)extraout_EDX) {
              local_24 = (id)(fVar9 * (float)extraout_EDX);
              local_1c = extraout_EDX;
            }
            else {
              local_1c = (undefined **)((float)local_24 / fVar9);
            }
            _objc_msgSend(pvVar3,sel_setSize_,local_24,local_1c);
            pvVar3 = _objc_msgSend(ppuVar10,sel_undoManager);
            _objc_msgSend(pvVar3,sel_enableUndoRegistration);
          }
          _objc_msgSend(pvVar2,sel_setSupport_,0,local_1c);
        }
        pvVar2 = _objc_msgSend(local_18,sel_queryHyperInterface_,&DAT_00361df8);
        _objc_msgSend(pvVar2,sel_setAutoPlayActionEvent_,pvVar1);
        puVar5 = cls_HSEditorCardViewDragHelper;
        pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,puVar4);
        pvVar2 = _objc_msgSend(puVar5,sel_commentsForDroppedObjectWithURL_,pvVar1);
        if ((pvVar2 != (id)0x0) &&
           (pvVar3 = _objc_msgSend(pvVar2,sel_length,pvVar1), pvVar3 != (id)0x0)) {
          pvVar3 = _objc_msgSend(local_18,sel_queryHyperInterface_,&DAT_00361e20);
          pvVar1 = _objc_msgSend(pvVar2,sel_copy);
          pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
          _objc_msgSend(pvVar3,sel_setHyperComments_,pvVar1);
        }
        pvVar1 = _objc_msgSend(self,sel_cardView,pvVar1);
        local_1c = (undefined **)0x0;
        puVar6 = local_18;
        _objc_msgSend(pvVar1,sel_addObjectToCenter_useDragPreferences_,local_18,0);
        op = sel_release;
      }
    }
  }
  _objc_msgSend(local_18,op,puVar6,local_1c);
  puVar5 = puVar6;
  ppuVar10 = local_1c;
LAB_0001af54:
  _objc_msgSend(self,sel_didAddNewObject,puVar5,ppuVar10);
  return;
}

*/
- (void)addMediaObject:(id)aObject
{
    if (_importMoviesObjectDialogController == nil) {
        _importMoviesObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeAnimations];
    }
    [_importMoviesObjectDialogController setHyperDocument:[self document]];
    [_importMoviesObjectDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self cardView] card]]];
    if ([_importMoviesObjectDialogController runModal] != 1) {
        return;
    }
    id autoplayEvent = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    id playable = [[_importMoviesObjectDialogController dialogUserOptions] valueForKey:HSImportDialogMoviesInUseOptionKeyPlayableObject];
    id path = [self checkFileExistenceAtPath:[_importMoviesObjectDialogController fileName] expectedType:kHSMovieFileType];
    if (![playable implementsHyperInterface:@protocol(HSMovieObjectAttributes)] && path == nil) {
        if ([playable implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
            id object = [playable copy];
            [[self cardView] addObjectToCenter:object useDragPreferences:NO];
            [object release];
        }
        [self didAddNewObject];
        return;
    }
    if (path == nil || ![HSMovieObject isMediaTypeSupported:[[NSFileManager defaultManager] hyperFileTypeAtPath:path]] || ![[HSEditorController sharedDocumentController] canImportFileAtPath:path showAlert:YES]) {
        [self didAddNewObject];
        return;
    }
    id card = [[self document] currentCard];
    id media = [self reusableMediaForPath:path contentFilter:[[HSLibraryManager sharedLibraryManager] moviesContentFilter]];
    NSError *error = nil;
    id object;
    BOOL isNewObject;
    if (playable == nil) {
        object = [[HSMovieObject alloc] initWithMedia:media error:&error];
        if (object != nil) {
            id verified = [self verifyObjects:[NSArray arrayWithObject:object] beforeAddToCard:card];
            if ([verified count] != 0) {
                [object release];
                object = [[verified lastObject] retain];
            }
        }
        isNewObject = YES;
    } else {
        object = [playable copy];
        [object setHyperUID:[HSUID UID]];
        id actor = [object queryHyperInterface:@protocol(HSActor)];
        id actions = [actor hyperActions];
        if ([actions count] != 0) {
            [actor removeActions:actions];
        }
        isNewObject = (object == nil);
    }
    if (object == nil) {
        if (error != nil) {
            [[HSErrorManager sharedErrorManager] presentError:error inWindow:[self window]];
        } else {
            HSMovie *movie = [HSMovie movieWithURL:[NSURL fileURLWithPath:path] error:&error];
            if (error == nil && movie != nil && [movie isGifMovie] && ![movie hasMultiplySamples]) {
                object = [[HSImageObject alloc] initWithMedia:media error:&error];
                if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
                    [[self cardView] addObjectToCenter:object useDragPreferences:NO];
                }
                [object release];
            }
        }
        [self didAddNewObject];
        return;
    }
    if (![[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
        [object release];
        [self didAddNewObject];
        return;
    }
    id nodeChild = [object queryHyperInterface:@protocol(HSNodeChild)];
    if (nodeChild != nil && isNewObject) {
        [nodeChild setSupport:[card support]];
        NSSize cardSize = [[card queryHyperInterface:@protocol(HSSizeAttributes)] size];
        id sizeAttributes = [object queryHyperInterface:@protocol(HSMutableSizeAttributes)];
        NSSize objectSize = [sizeAttributes size];
        if (sizeAttributes != nil && (cardSize.width < objectSize.width || cardSize.height < objectSize.height || cardSize.width * cardSize.height * 0.9f < objectSize.width * objectSize.height)) {
            [[card undoManager] disableUndoRegistration];
            float ratio = objectSize.width / objectSize.height;
            NSSize newSize;
            if (ratio <= cardSize.width / cardSize.height) {
                newSize = NSMakeSize(ratio * cardSize.height, cardSize.height);
            } else {
                newSize = NSMakeSize(cardSize.width, cardSize.width / ratio);
            }
            [sizeAttributes setSize:newSize];
            [[card undoManager] enableUndoRegistration];
        }
        [nodeChild setSupport:nil];
    }
    [[object queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoPlayActionEvent:autoplayEvent];
    NSString *comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:path]];
    if (comments != nil && [comments length] != 0) {
        [[object queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
    }
    [[self cardView] addObjectToCenter:object useDragPreferences:NO];
    [object release];
    [self didAddNewObject];
}

- (void)addWebCamObject:(id)aObject
{
    [self runWebcamWorkshopPanel:aObject];
}

- (void)addLiveVideoObject:(id)aObject
{
    id pvVar1;

    pvVar1 = [HSLiveObject defaultObject];
    [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Item" value:@"" table:@"UndoManager"]];
    [[self cardView] addObjectToCenter:pvVar1 useDragPreferences:NO];
    [self didAddNewObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001a308 @ 0001a308, 355 bytes * /

void FUN_0001a308(HSEditorWindowController *self,SEL _cmd,id addSoundComboObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self->_playSoundActionEvent,sel_release);
  self->_playSoundActionEvent = (id)0x0;
  pvVar1 = _objc_msgSend(cls_HSSoundAddingOptionsDialog,sel_new);
  pvVar2 = _objc_msgSend(cls_NSApplication,sel_sharedApplication);
  pvVar3 = _objc_msgSend(pvVar1,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_runModalForWindow_,pvVar3);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(pvVar1,sel_selectedActionEvent,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_playSoundActionEvent = pvVar2;
  }
  _objc_msgSend(pvVar1,sel_release,pvVar3);
  if (self->_playSoundActionEvent != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSAddSoundComboDialog,sel_new,pvVar3);
    pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
    if (pvVar2 == (id)0x1) {
      pvVar2 = *(id *)PTR_00336058;
      pvVar3 = _objc_msgSend(pvVar1,sel_action);
      _objc_msgSend(pvVar2,sel_sendAction_to_from_,pvVar3,0,0);
    }
    _objc_msgSend(pvVar1,sel_release,pvVar3);
  }
  return;
}

*/
- (void)addSoundComboObject:(id)aObject
{
    [_playSoundActionEvent release];
    _playSoundActionEvent = nil;
    id optionsDialog = [HSSoundAddingOptionsDialog new];
    if ([[NSApplication sharedApplication] runModalForWindow:[optionsDialog window]] == 1) {
        _playSoundActionEvent = [[optionsDialog selectedActionEvent] retain];
    }
    [optionsDialog release];
    if (_playSoundActionEvent != nil) {
        id comboDialog = [HSAddSoundComboDialog new];
        if ([comboDialog runModal] == 1) {
            [NSApp sendAction:[comboDialog action] to:nil from:nil];
        }
        [comboDialog release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001a26e @ 0001a26e, 154 bytes * /

void FUN_0001a26e(HSEditorWindowController *self,SEL _cmd,id addMovieComboObject)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  
  self_00 = _objc_msgSend(cls_HSAddVideoComboDialog,sel_new);
  pvVar1 = _objc_msgSend(self_00,sel_runModal);
  if (pvVar1 == (id)0x1) {
    pvVar1 = *(id *)PTR_00336058;
    pvVar2 = _objc_msgSend(self_00,sel_action);
    _objc_msgSend(pvVar1,sel_sendAction_to_from_,pvVar2,0,0);
  }
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)addMovieComboObject:(id)aObject
{
    id dialog = [HSAddVideoComboDialog new];
    if ([dialog runModal] == 1) {
        [NSApp sendAction:[dialog action] to:nil from:nil];
    }
    [dialog release];
}

- (void)addWebObject:(id)aObject
{
    id pvVar1;

    pvVar1 = [HSWebObject defaultObject];
    [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Item" value:@"" table:@"UndoManager"]];
    [[self cardView] addObjectToCenter:pvVar1 useDragPreferences:NO];
    [self didAddNewObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00023848 @ 00023848, 1133 bytes * /

void FUN_00023848(HSEditorWindowController *self,SEL _cmd,id importText)

{
  int iVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  undefined4 *puVar5;
  id pvVar6;
  SEL pcVar7;
  cfstringStruct *pcVar8;
  undefined1 *puVar9;
  undefined4 uVar10;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  self_00 = _objc_msgSend(pvVar2,sel_retain);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar8 = &cfstr_empty;
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_ImportTextPrompt,
                         &cfstr_empty,0);
  _objc_msgSend(self_00,sel_setPrompt_,pvVar2);
  _objc_msgSend(self_00,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self_00,sel_setCanChooseFiles_,1);
  pvVar2 = (id)0x0;
  _objc_msgSend(self_00,sel_setCanChooseDirectories_,0);
  pvVar3 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_textDocumentsFolder);
  if (pvVar3 != (id)0x0) {
    pcVar7 = sel_setDirectory_;
    pvVar2 = pvVar3;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pcVar8 = (cfstringStruct *)0x1;
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar3,1);
      pcVar7 = sel_setDirectoryURL_;
    }
    _objc_msgSend(self_00,pcVar7,pvVar2,pcVar8);
  }
  pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_textUnfilteredFileTypes,pvVar2,pcVar8);
  pvVar3 = _objc_msgSend(self_00,sel_runModalForTypes_,pvVar2);
  if (pvVar3 == (id)0x1) {
    pvVar3 = _objc_msgSend(self,sel_document,pvVar2);
    pvVar3 = _objc_msgSend(pvVar3,
                           sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pvVar2);
      if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
        pvVar2 = _objc_msgSend(self_00,sel_directory,pvVar2);
        _objc_msgSend(pvVar3,sel_setTextDocumentsFolder_,pvVar2);
        pvVar3 = _objc_msgSend(self,sel_cardView);
        pvVar2 = _objc_msgSend(self_00,sel_filenames);
        pcVar8 = (cfstringStruct *)0x1;
        pcVar7 = sel_importToCardDataFromFiles_showHelpPane_;
      }
      else {
        pvVar2 = _objc_msgSend(self_00,sel_directoryURL,pvVar2);
        pvVar2 = _objc_msgSend(pvVar2,sel_path);
        _objc_msgSend(pvVar3,sel_setTextDocumentsFolder_,pvVar2);
        pvVar2 = _objc_msgSend(self_00,sel_URLs);
        pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_new);
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar9 = local_50;
        puVar5 = &local_74;
        uVar10 = 0x10;
        pvVar4 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar5,puVar9,
                               0x10);
        if (pvVar4 != (id)0x0) {
          iVar1 = *local_6c;
          do {
            pvVar6 = (id)0x0;
            do {
              if (iVar1 != *local_6c) {
                _objc_enumerationMutation(pvVar2);
              }
              puVar5 = _objc_msgSend(*(id *)(local_70 + (int)pvVar6 * 4),sel_path,puVar5,puVar9,
                                     uVar10);
              _objc_msgSend(pvVar3,sel_addObject_);
              pvVar6 = (id)((int)pvVar6 + 1);
            } while (pvVar6 < pvVar4);
            puVar9 = local_50;
            puVar5 = &local_74;
            uVar10 = 0x10;
            pvVar4 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar5,
                                   puVar9,0x10);
          } while (pvVar4 != (id)0x0);
        }
        pvVar4 = _objc_msgSend(self,sel_cardView,puVar5,puVar9,uVar10);
        pcVar8 = (cfstringStruct *)0x1;
        pvVar2 = pvVar3;
        _objc_msgSend(pvVar4,sel_importToCardDataFromFiles_showHelpPane_,pvVar3,1);
        pcVar7 = sel_release;
      }
      _objc_msgSend(pvVar3,pcVar7,pvVar2,pcVar8);
    }
  }
  _objc_msgSend(self_00,sel_release,pvVar2,pcVar8);
  return;
}

*/
- (void)importText:(id)aText
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"ImportTextPrompt" value:@"" table:nil]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    id folder = [[HSPathsProvider sharedPathsProvider] textDocumentsFolder];
    if (folder != nil) {
        if (NSAppKitVersionNumber >= 1038.0) {
            [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
        } else {
            [panel setDirectory:folder];
        }
    }
    if ([panel runModalForTypes:[NSAttributedString textUnfilteredFileTypes]] == 1
        && [[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
        HSPathsProvider *paths = [HSPathsProvider sharedPathsProvider];
        if (NSAppKitVersionNumber <= 1038.0 && NSAppKitVersionNumber != 1038.0) {
            [paths setTextDocumentsFolder:[panel directory]];
            [[self cardView] importToCardDataFromFiles:[panel filenames] showHelpPane:YES];
        } else {
            [paths setTextDocumentsFolder:[[panel directoryURL] path]];
            NSMutableArray *files = [NSMutableArray new];
            for (NSURL *url in [panel URLs]) {
                [files addObject:[url path]];
            }
            [[self cardView] importToCardDataFromFiles:files showHelpPane:YES];
            [files release];
        }
    }
    [panel release];
}

- (void)addTextObject:(id)aObject
{
    id pvVar1;

    pvVar1 = [HSSystemTextView defaultObject];
    [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Item" value:@"" table:@"UndoManager"]];
    [[self cardView] addObjectToCenter:pvVar1 useDragPreferences:NO];
    [self didAddNewObject];
}

- (id)reusableMediaForPath:(id)aPath contentFilter:(id)aFilter
{
    id pvVar1;
    id pvVar2;
    id pvVar1_2;
    id pvVar1_4;

    if (aPath == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1_2 = [aFilter globalUIDStringForMediaItem:aPath];
        if (pvVar1_2 == nil) {
            pvVar2 = nil;
        }
        else {
            pvVar2 = [HSUID UIDWithString:pvVar1_2];
            if (pvVar2 != nil) {
                pvVar1_4 = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:pvVar2];
                if (pvVar1_4 != nil) {
                    return pvVar1_4;
                }
            }
        }
        pvVar1 = [HSNewMedia mediaWithPath:aPath mediaUID:pvVar2];
    }
    return pvVar1;
}

- (void)showAssistantIfNeeded
{
    id pvVar1_6;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:HSShowAssistantOnNewObject]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:HSForceSOTSForNewObjectsKey]) {
            pvVar1_6 = [[HSObjectAssistantController sharedAssistantController] objectAssistant];
            [pvVar1_6 setPrefersInspectorMode:NO];
        }
        [[HSObjectAssistantController sharedAssistantController] setNewObject:[self selectedUserObject] didAdd:YES];
        [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:[self selectedUserObject]];
    }
}

- (void)didAddNewObject
{
    [self showAssistantIfNeeded];
}

- (void)didAddNewCard
{
    [self showAssistantIfNeeded];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00019bb0 @ 00019bb0, 594 bytes * /

id FUN_00019bb0(HSEditorWindowController *self,SEL _cmd,id checkFileExistenceAtPath,id expectedType)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(checkFileExistenceAtPath,sel_length);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = checkFileExistenceAtPath;
    pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,checkFileExistenceAtPath);
    self_00 = cls_NSString;
    if ((char)pvVar2 == '\0') {
      pvVar1 = _objc_msgSend(checkFileExistenceAtPath,sel_lastPathComponent,pvVar1);
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_CannotFindFileMessageText,&cfstr_empty,&cfstr_Alerts);
      pvVar1 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar2,pvVar1);
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_CannotFindFileAlertFindButtonTitle,&cfstr_empty,&cfstr_Alerts);
      pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_CannotFindFileAlertCancelButtonTitle,&cfstr_empty,&cfstr_Alerts)
      ;
      pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                             &cfstr_CannotFindFileInformativeText,&cfstr_empty,&cfstr_Alerts);
      uVar6 = 0;
      pvVar5 = _objc_msgSend(cls_HSAlert,
                             sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeText_
                             ,pvVar1,pvVar2,pvVar3,0,pvVar4);
      pvVar5 = _objc_msgSend(pvVar5,sel_runModal);
      if (pvVar5 == (id)0x3e8) {
        pvVar1 = _objc_msgSend(cls_HSOpenPanelProvider,sel_sharedOpenPanelProvider,pvVar1,pvVar2,
                               pvVar3,uVar6,pvVar4);
        checkFileExistenceAtPath = _objc_msgSend(pvVar1,sel_chooseFileOfType_,expectedType);
      }
      else {
        checkFileExistenceAtPath = (id)0x0;
      }
    }
  }
  return checkFileExistenceAtPath;
}

*/
- (id)checkFileExistenceAtPath:(id)aPath expectedType:(id)aType
{
    if ([aPath length] != 0 && ![[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *message = [NSString stringWithFormat:[bundle localizedStringForKey:@"CannotFindFileMessageText" value:@"" table:@"Alerts"], [aPath lastPathComponent]];
        NSString *findTitle = [bundle localizedStringForKey:@"CannotFindFileAlertFindButtonTitle" value:@"" table:@"Alerts"];
        NSString *cancelTitle = [bundle localizedStringForKey:@"CannotFindFileAlertCancelButtonTitle" value:@"" table:@"Alerts"];
        NSString *informative = [bundle localizedStringForKey:@"CannotFindFileInformativeText" value:@"" table:@"Alerts"];
        HSAlert *alert = [HSAlert alertWithMessageText:message defaultButton:findTitle alternateButton:cancelTitle otherButton:nil informativeText:informative];
        if ([alert runModal] == 1000) {
            return [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:aType];
        }
        return nil;
    }
    return aPath;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001994a @ 0001994a, 614 bytes * /

void FUN_0001994a(HSEditorWindowController *self,SEL _cmd,id convertToGraphicObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  HSEditorCardView *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedUserObject);
  puVar4 = &DAT_00361a10;
  pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00361a10);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_class,puVar4);
    pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    puVar4 = _objc_msgSend(pvVar3,sel_currentTool);
    pvVar2 = _objc_msgSend(pvVar2,sel_isValidSelectionTool_,puVar4);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(self,sel_document,puVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
      pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_Consolidate_Graphic_Object,&cfstr_empty,&cfstr_UndoManager);
      _objc_msgSend(pvVar2,sel_setMultipleActionsName_,pvVar3);
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361b64);
      pvVar2 = _objc_msgSend(pvVar2,sel_mediaUIDsForOptimization);
      pvVar2 = _objc_msgSend(pvVar2,sel_anyObject);
      puVar4 = cls_HSImageObjectsOptimizer;
      if (pvVar2 == (id)0x0) {
        return;
      }
      pvVar1 = _objc_msgSend(cls_NSSet,sel_setWithObject_,pvVar1);
      self_00 = _objc_msgSend(puVar4,sel_optimizerForMediaUID_usedInObjects_,pvVar2,pvVar1);
      op = sel_optimize;
      goto LAB_00019a79;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar2 = _objc_msgSend(cls_HSBaseBitmapTool,sel_class);
  pvVar1 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_createObjectFromSelection_,convertToGraphicObject);
    pvVar2 = convertToGraphicObject;
  }
  self_00 = self->_cardView;
  op = sel_convertSelectedObjectToImage;
LAB_00019a79:
  _objc_msgSend(self_00,op,pvVar2);
  return;
}

*/
- (void)convertToGraphicObject:(id)aObject
{
    id object = [self selectedUserObject];
    if ([object implementsHyperInterface:@protocol(HSImageObjectAttributes)]
        && ![[self class] isValidSelectionTool:[[HSToolManager sharedToolManager] currentTool]]) {
        [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Consolidate Graphic Object" value:@"" table:@"UndoManager"]];
        id mediaUID = [[[object queryHyperInterface:@protocol(HSCardObjectOptimization)] mediaUIDsForOptimization] anyObject];
        if (mediaUID == nil) {
            return;
        }
        [[HSImageObjectsOptimizer optimizerForMediaUID:mediaUID usedInObjects:[NSSet setWithObject:object]] optimize];
        return;
    }
    if ([[[HSToolManager sharedToolManager] currentTool] isKindOfClass:[HSBaseBitmapTool class]]) {
        [self createObjectFromSelection:aObject];
        return;
    }
    [_cardView convertSelectedObjectToImage];
}

- (void)createObjectFromSelection:(id)aSelection
{
    [self addGraphicObjectUsingSelection:YES tool:[[HSToolManager sharedToolManager] currentTool]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00023cb5 @ 00023cb5, 4333 bytes * /

void FUN_00023cb5(HSEditorWindowController *self,SEL _cmd,BOOL addGraphicObjectUsingSelection,
                 id tool)

{
  float fVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined *puVar5;
  id pvVar6;
  int iVar7;
  int iVar8;
  id pvVar9;
  float *pfVar10;
  id pvVar11;
  id pvVar12;
  float extraout_EDX;
  float extraout_EDX_00;
  float *pfVar13;
  float *ret;
  longdouble lVar14;
  longdouble lVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  float fVar24;
  float fVar25;
  float fVar26;
  float fVar27;
  float fVar28;
  undefined4 local_1d4;
  float local_180;
  float local_17c;
  float local_11c;
  float fStack_118;
  float local_114;
  float fStack_110;
  float local_10c;
  float fStack_108;
  id local_c4;
  id local_b8;
  float local_b4;
  float local_b0 [3];
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  float local_94;
  float local_90;
  undefined4 local_8c;
  undefined4 local_88;
  undefined4 local_84;
  undefined4 local_80;
  float local_7c;
  float local_78;
  int local_74 [22];
  id local_1c;
  BOOL local_15;
  HSEditorWindowController *local_14;
  
  pfVar10 = (float *)&stack0xfffffe34;
  local_14 = self;
  local_15 = addGraphicObjectUsingSelection;
  local_1c = tool;
  local_b8 = (id)0x0;
  if ((addGraphicObjectUsingSelection == '\0') || (tool == (id)0x0)) {
    pvVar6 = _objc_msgSend(cls_HSOpenPanelProvider,sel_sharedOpenPanelProvider);
    pvVar6 = _objc_msgSend(pvVar6,sel_chooseFileOfType_);
    if (pvVar6 == (id)0x0) {
      return;
    }
    pvVar6 = _objc_msgSend(cls_HSImageObject,sel_defaultObject);
    _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_);
    _objc_msgSend(pvVar6,sel_setMedia_);
    if (pvVar6 == (id)0x0) {
      return;
    }
    _objc_msgSend(local_14,sel_cardView);
    goto LAB_00024d97;
  }
  pvVar6 = _objc_msgSend(tool,sel_bitmapTool);
  fVar24 = *(float *)PTR_00336090;
  fVar18 = *(float *)(PTR_00336090 + 4);
  fVar21 = *(float *)(PTR_00336090 + 8);
  fVar22 = *(float *)(PTR_00336090 + 0xc);
  local_11c = *(float *)PTR_00336088;
  fStack_118 = *(float *)(PTR_00336088 + 4);
  uVar3 = *(undefined8 *)PTR_00336088;
  local_114 = *(float *)(PTR_00336088 + 8);
  fStack_110 = *(float *)(PTR_00336088 + 0xc);
  uVar4 = *(undefined8 *)(PTR_00336088 + 8);
  local_10c = *(float *)(PTR_00336088 + 0x10);
  fStack_108 = *(float *)(PTR_00336088 + 0x14);
  uVar2 = *(undefined8 *)(PTR_00336088 + 0x10);
  local_17c = *(float *)PTR_0033607c;
  local_180 = *(float *)(PTR_0033607c + 4);
  _objc_exception_try_enter();
  iVar7 = __setjmp(local_74);
  if (iVar7 == 0) {
    pvVar9 = _objc_msgSend(pvVar6,sel_valueForKey_);
    pfVar10 = (float *)&stack0xfffffe34;
    if (pvVar9 != (id)0x0) {
      _CGEPathGetPathBoundingBox();
      pfVar13 = (float *)&stack0xfffffe30;
      local_1d4 = 0x23f34;
      local_c4 = _objc_msgSend(pvVar6,sel_valueForKey_);
      if (local_c4 == (id)0x0) {
        local_1d4 = 0x23f65;
        pvVar9 = _objc_msgSend(pvVar6,sel_respondsToSelector_);
        if ((char)pvVar9 != '\0') {
          local_1d4 = 0x23f89;
          _objc_msgSend(pvVar6,sel_finalizeSelection_);
          local_1d4 = 0x23fa5;
          local_c4 = _objc_msgSend(pvVar6,sel_valueForKey_);
        }
      }
      local_1d4 = 0x23fcd;
      pvVar9 = _objc_msgSend(pvVar6,sel_valueForKey_);
      if (pvVar9 != (id)0x0) {
        local_1d4 = 0x23fed;
        _objc_msgSend(pvVar9,sel_getValue_);
      }
      local_1d4 = 0x2400f;
      pvVar9 = _objc_msgSend(pvVar6,sel_valueForKey_);
      if (pvVar9 != (id)0x0) {
        local_1d4 = 0x2402f;
        _objc_msgSend(pvVar9,sel_getValue_);
      }
      local_1d4 = 0x24051;
      pvVar9 = _objc_msgSend(pvVar6,sel_valueForKey_);
      if (pvVar9 == (id)0x0) {
        pfVar10 = (float *)(PTR_00336074 + 4);
        ret = (float *)PTR_00336074;
      }
      else {
        ret = &local_b4;
        local_1d4 = 0x2407c;
        _objc_msgSend_stret(ret,pvVar9,sel_rectValue);
        pfVar13 = (float *)&local_1d4;
        pfVar10 = local_b0;
      }
      fVar25 = *ret;
      fVar27 = *pfVar10;
      *(undefined8 *)(pfVar13 + 5) = uVar2;
      *(undefined8 *)(pfVar13 + 3) = uVar4;
      *(undefined8 *)(pfVar13 + 1) = uVar3;
      *pfVar13 = (float)&local_a4;
      pfVar13[-1] = 2.06928e-40;
      _CGAffineTransformInvert();
      fVar23 = local_11c * local_a4 + fStack_118 * local_9c;
      fVar19 = local_11c * local_a0 + fStack_118 * local_98;
      fVar26 = local_a4 * local_114 + local_9c * fStack_110;
      fVar16 = local_114 * local_a0 + fStack_110 * local_98;
      *pfVar13 = fVar19;
      pfVar13[-1] = fVar23;
      pfVar13[-2] = 2.07415e-40;
      lVar14 = (longdouble)_hypotf();
      *pfVar13 = fVar16;
      pfVar13[-1] = fVar26;
      fVar28 = (float)lVar14;
      pfVar13[-2] = 2.07468e-40;
      lVar14 = (longdouble)_hypotf();
      fVar1 = (float)lVar14;
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar17 = 1.0 / fVar1;
      }
      else {
        fVar17 = 1.0;
      }
      if ((fVar28 != 0.0) || (NAN(fVar28))) {
        fVar20 = 1.0 / fVar28;
      }
      else {
        fVar20 = 1.0;
      }
      *(ulonglong *)(pfVar13 + 4) =
           CONCAT44(local_10c * local_a0 + fStack_108 * local_98 + local_90,
                    local_10c * local_a4 + fStack_108 * local_9c + local_94);
      *(ulonglong *)(pfVar13 + 2) = CONCAT44(fVar16 * fVar17,fVar26 * fVar17);
      *(ulonglong *)pfVar13 = CONCAT44(fVar19 * fVar20,fVar23 * fVar20);
      pfVar13[-1] = (float)&local_8c;
      pfVar13[-2] = 2.07961e-40;
      _CGAffineTransformInvert();
      pfVar13[-2] = fVar28 * fVar21;
      pfVar13[-3] = 2.08153e-40;
      lVar14 = (longdouble)_roundf();
      pfVar13[-2] = fVar1 * fVar22;
      pfVar13[-3] = 2.08209e-40;
      lVar15 = (longdouble)_roundf();
      pfVar13[-1] = (float)sel_alloc;
      pfVar13[-2] = (float)cls_NSImage;
      fVar16 = (float)lVar15;
      pfVar13[-3] = 2.08251e-40;
      pvVar9 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
      pfVar13[1] = fVar16;
      fVar19 = (float)lVar14;
      *pfVar13 = fVar19;
      pfVar13[-1] = (float)sel_initWithSize_;
      pfVar13[-2] = (float)pvVar9;
      pfVar13[-3] = 2.08355e-40;
      pvVar9 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
      pfVar10 = pfVar13 + -2;
      if (pvVar9 != (id)0x0) {
        pfVar13[-1] = (float)sel_lockFocus;
        pfVar13[-2] = (float)pvVar9;
        pfVar13[-3] = 2.08408e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_currentContext;
        pfVar13[-2] = (float)cls_NSGraphicsContext;
        pfVar13[-3] = 2.08442e-40;
        pvVar11 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_graphicsPort;
        pfVar13[-2] = (float)pvVar11;
        pfVar13[-3] = 2.08467e-40;
        pvVar11 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        *(ulonglong *)(pfVar13 + 3) = CONCAT44(local_78 - fVar18 * fVar1,local_7c - fVar24 * fVar28)
        ;
        *(ulonglong *)(pfVar13 + 1) = CONCAT44(local_80,local_84);
        *(ulonglong *)(pfVar13 + -1) = CONCAT44(local_88,local_8c);
        pfVar13[-2] = (float)pvVar11;
        pfVar13[-3] = 2.08537e-40;
        _CGContextConcatCTM();
        pfVar13[-1] = (float)sel_currentContext;
        pfVar13[-2] = (float)cls_NSGraphicsContext;
        pfVar13[-3] = 2.08579e-40;
        pvVar11 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_graphicsPort;
        pfVar13[-2] = (float)pvVar11;
        pfVar13[-3] = 2.08604e-40;
        pvVar11 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[2] = fVar27;
        pfVar13[1] = fVar25;
        *pfVar13 = (float)pvVar11;
        pfVar13[-1] = (float)sel_drawInCGContext_atPoint_;
        pfVar13[-2] = (float)local_c4;
        pfVar13[-3] = 2.08674e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_unlockFocus;
        pfVar13[-2] = (float)pvVar9;
        pfVar13[-3] = 2.08708e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_hyperPixelsSize;
        pfVar13[-2] = (float)pvVar9;
        pfVar13[-3] = 2.08742e-40;
        pvVar11 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_defaultObject;
        pfVar13[-2] = (float)cls_HSImageObject;
        pfVar13[-3] = 2.08809e-40;
        local_b8 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        puVar5 = cls_HSNewMedia;
        pfVar13[-1] = (float)sel_mainBundle;
        pfVar13[-2] = (float)cls_NSBundle;
        pfVar13[-3] = 2.08859e-40;
        pvVar12 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[1] = (float)&cfstr_empty;
        *pfVar13 = (float)&cfstr_Untitled;
        pfVar13[-1] = (float)sel_localizedStringForKey_value_table_;
        pfVar13[-2] = (float)pvVar12;
        pfVar13[2] = 0.0;
        pfVar13[-3] = 2.08924e-40;
        pvVar12 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[1] = (float)pvVar12;
        *pfVar13 = (float)pvVar9;
        pfVar13[-1] = (float)sel_mediaWithImage_name_;
        pfVar13[-2] = (float)puVar5;
        pfVar13[-3] = 2.08969e-40;
        pvVar12 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        *pfVar13 = (float)pvVar12;
        pfVar13[-1] = (float)sel_setMedia_;
        pfVar13[-2] = (float)local_b8;
        pfVar13[-3] = 2.09008e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        *pfVar13 = (float)&DAT_00362460;
        pfVar13[-1] = (float)sel_queryHyperInterface_;
        pfVar13[-2] = (float)local_b8;
        pfVar13[-3] = 2.09056e-40;
        pvVar12 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_setShadowEnabled_;
        pfVar13[-2] = (float)pvVar12;
        *pfVar13 = 0.0;
        pfVar13[-3] = 2.09092e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        if ((fVar19 != 0.0) || (NAN(fVar19))) {
          fVar21 = fVar21 / fVar19;
        }
        else {
          fVar21 = 1.0;
        }
        if ((fVar16 != 0.0) || (NAN(fVar16))) {
          fVar22 = fVar22 / fVar16;
        }
        else {
          fVar22 = 1.0;
        }
        fVar24 = fVar24 - fVar21 * 0.0;
        fVar18 = fVar18 - fVar22 * 0.0;
        fVar25 = fVar21 * local_11c + local_114 * 0.0;
        fVar27 = local_11c * 0.0 + fVar22 * local_114;
        fVar28 = fStack_118 * 0.0 + fVar22 * fStack_110;
        fVar22 = -fVar27;
        local_10c = fVar27 * fVar16 + fVar18 * local_114 + fVar24 * local_11c + local_10c;
        pfVar13[-1] = (float)sel_workImage;
        pfVar13[-2] = (float)pvVar6;
        pfVar13[-3] = 2.10029e-40;
        pvVar12 = _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar13[-1] = (float)sel_imageSize;
        pfVar13[-2] = (float)pvVar12;
        pfVar13[-3] = 2.10055e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        fStack_108 = extraout_EDX_00 -
                     (fVar28 * fVar16 + fVar24 * fStack_118 + fVar18 * fStack_110 + fStack_108);
        fStack_118 = -(fVar21 * fStack_118 + fStack_110 * 0.0);
        fStack_110 = --fVar28;
        pfVar13[-1] = fStack_118;
        pfVar13[-2] = fVar25;
        pfVar13[-3] = 2.10304e-40;
        lVar14 = (longdouble)_hypotf();
        pfVar13[-1] = fStack_110;
        pfVar13[-2] = fVar22;
        local_17c = (float)lVar14;
        pfVar13[-3] = 2.10357e-40;
        lVar14 = (longdouble)_hypotf();
        local_180 = (float)lVar14;
        if ((local_180 != 0.0) || (NAN(local_180))) {
          fVar24 = 1.0 / local_180;
        }
        else {
          fVar24 = 1.0;
        }
        if ((local_17c != 0.0) || (NAN(local_17c))) {
          fVar18 = 1.0 / local_17c;
        }
        else {
          fVar18 = 1.0;
        }
        local_11c = fVar25 * fVar18;
        fStack_118 = fStack_118 * fVar18;
        local_114 = fVar22 * fVar24;
        fStack_110 = fStack_110 * fVar24;
        local_17c = (float)pvVar11 * local_17c;
        local_180 = extraout_EDX * local_180;
        pfVar13[-1] = (float)sel_release;
        pfVar13[-2] = (float)pvVar9;
        pfVar13[-3] = 2.10772e-40;
        _objc_msgSend((id)pfVar13[-2],(SEL)pfVar13[-1]);
        pfVar10 = pfVar13 + -2;
      }
    }
  }
  else {
    iVar8 = _objc_exception_extract();
    _objc_exception_try_enter();
    iVar7 = __setjmp(local_74);
    if (iVar7 == 0) {
      iVar7 = _objc_exception_match();
      pfVar10 = (float *)&stack0xfffffe34;
      if (iVar7 != 0) goto LAB_00024b8c;
      _objc_exception_try_exit();
    }
    else {
      iVar8 = _objc_exception_extract();
    }
    pfVar10 = (float *)&stack0xfffffe34;
    if (iVar8 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw();
    }
  }
LAB_00024b8c:
  *pfVar10 = (float)local_74;
  pfVar10[-1] = 2.10788e-40;
  _objc_exception_try_exit();
  if (local_b8 == (id)0x0) {
    return;
  }
  pfVar10[2] = (float)local_14;
  pfVar10[1] = (float)sel_delete_;
  *pfVar10 = (float)pvVar6;
  pfVar10[-1] = 2.10849e-40;
  _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  pfVar10[2] = (float)&DAT_003619d4;
  pfVar10[1] = (float)sel_queryHyperInterface_;
  *pfVar10 = (float)local_b8;
  pfVar10[-1] = 2.10897e-40;
  pvVar6 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  pfVar10[1] = (float)sel_queryGeometryBehaviorApplier;
  *pfVar10 = (float)pvVar6;
  pfVar10[-1] = 2.10922e-40;
  pvVar6 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  *(ulonglong *)(pfVar10 + 8) = CONCAT44(fStack_108,local_10c);
  *(ulonglong *)(pfVar10 + 6) = CONCAT44(fStack_110,local_114);
  *(ulonglong *)(pfVar10 + 4) = CONCAT44(fStack_118,local_11c);
  pfVar10[3] = local_180;
  pfVar10[2] = local_17c;
  pfVar10[1] = (float)sel_setSize_affineTransform_flippedHorizontally_withLayoutGuidingContext_;
  *pfVar10 = (float)pvVar6;
  pfVar10[0xb] = 0.0;
  pfVar10[10] = 0.0;
  pfVar10[-1] = 2.11068e-40;
  _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  pfVar10[2] = (float)local_b8;
  pfVar10[1] = (float)sel_cropApplierForImageObject_;
  *pfVar10 = (float)cls_HSImageCropApplier;
  pfVar10[-1] = 2.11115e-40;
  pvVar6 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  pfVar10[1] = (float)sel_updateCurrentBorderPath;
  *pfVar10 = (float)pvVar6;
  pfVar10[-1] = 2.11141e-40;
  _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  pfVar10[1] = (float)sel_activeCard;
  *pfVar10 = (float)local_14;
  pfVar10[-1] = 2.1117e-40;
  pvVar6 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  pfVar10[2] = (float)local_b8;
  pfVar10[1] = (float)sel_addHyperChild_;
  *pfVar10 = (float)pvVar6;
LAB_00024d97:
  pfVar10[-1] = 2.11512e-40;
  _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  return;
}

*/
- (void)addGraphicObjectUsingSelection:(BOOL)aSelection tool:(id)aTool
{
    id object = nil;
    if (!aSelection || aTool == nil) {
        id path = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSImageFileType];
        if (path == nil) {
            return;
        }
        object = [HSImageObject defaultObject];
        [object setMedia:[HSNewMedia mediaWithPath:path]];
        if (object == nil) {
            return;
        }
        [[self cardView] addObjectToCenter:object useDragPreferences:NO];
        return;
    }
    id bitmapTool = [aTool bitmapTool];
    id selectionPath = nil;
    id imageSelection = nil;
    CGRect bounds = CGRectZero;
    CGAffineTransform pathTransform = CGAffineTransformIdentity;
    CGAffineTransform imageTransform = CGAffineTransformIdentity;
    CGAffineTransform finalTransform = CGAffineTransformIdentity;
    NSSize finalSize = NSZeroSize;
    @try {
        selectionPath = [bitmapTool valueForKey:@"selectionPath"];
        if (selectionPath != nil) {
            bounds = CGEPathGetPathBoundingBox((CGPathRef)selectionPath);
            imageSelection = [bitmapTool valueForKey:@"imageSelection"];
            if (imageSelection == nil && [bitmapTool respondsToSelector:@selector(finalizeSelection:)]) {
                [bitmapTool finalizeSelection:nil];
                imageSelection = [bitmapTool valueForKey:@"imageSelection"];
            }
            id value = [bitmapTool valueForKey:@"selectionPathTransform"];
            if (value != nil) {
                [value getValue:&pathTransform];
            }
            value = [bitmapTool valueForKey:@"imageSelectionTransform"];
            if (value != nil) {
                [value getValue:&imageTransform];
            }
            NSPoint selectionOrigin = NSZeroPoint;
            value = [bitmapTool valueForKey:@"imageSelectionBounds"];
            if (value != nil) {
                selectionOrigin = [value rectValue].origin;
            }
            CGAffineTransform m = CGAffineTransformConcat(pathTransform, CGAffineTransformInvert(imageTransform));
            float scaleX = hypotf(m.a, m.b);
            float scaleY = hypotf(m.c, m.d);
            float invScaleY = scaleY != 0.0f ? 1.0f / scaleY : 1.0f;
            float invScaleX = scaleX != 0.0f ? 1.0f / scaleX : 1.0f;
            CGAffineTransform rotation = CGAffineTransformMake(m.a * invScaleX, m.b * invScaleX, m.c * invScaleY, m.d * invScaleY, m.tx, m.ty);
            float originX = bounds.origin.x * scaleX;
            float originY = bounds.origin.y * scaleY;
            CGAffineTransform inverse = CGAffineTransformInvert(rotation);
            CGAffineTransform drawTransform = CGAffineTransformMake(inverse.a, inverse.b, inverse.c, inverse.d, inverse.tx - originX, inverse.ty - originY);
            float width = roundf(scaleX * bounds.size.width);
            float height = roundf(scaleY * bounds.size.height);
            NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
            if (image != nil) {
                [image lockFocus];
                CGContextConcatCTM((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], drawTransform);
                [imageSelection drawInCGContext:(CGContextRef)[[NSGraphicsContext currentContext] graphicsPort] atPoint:selectionOrigin];
                [image unlockFocus];
                NSSize pixelsSize = [image hyperPixelsSize];
                object = [HSImageObject defaultObject];
                [object setMedia:[HSNewMedia mediaWithImage:image name:[[NSBundle mainBundle] localizedStringForKey:@"Untitled" value:@"" table:nil]]];
                [[object queryHyperInterface:@protocol(HSShadowAttributes)] setShadowEnabled:NO];
                float scaleToImageX = width != 0.0f ? bounds.size.width / width : 1.0f;
                float scaleToImageY = height != 0.0f ? bounds.size.height / height : 1.0f;
                float tx = bounds.origin.x - scaleToImageX * 0.0f;
                float ty = bounds.origin.y - scaleToImageY * 0.0f;
                float a = scaleToImageX * pathTransform.a + 0.0f * pathTransform.c;
                float b = scaleToImageX * pathTransform.b + 0.0f * pathTransform.d;
                float c = 0.0f * pathTransform.a + scaleToImageY * pathTransform.c;
                float d = 0.0f * pathTransform.b + scaleToImageY * pathTransform.d;
                float ex = tx * pathTransform.a + ty * pathTransform.c + pathTransform.tx;
                float ey = tx * pathTransform.b + ty * pathTransform.d + pathTransform.ty;
                // Flip into the bitmap tool's bottom-up coordinate space.
                float fx = c * height + ex;
                float fy = d * height + ey;
                NSSize workSize = [[bitmapTool workImage] imageSize];
                float oa = a, ob = -b, oc = -c, od = d;
                float otx = fx, oty = workSize.height - fy;
                float lengthX = hypotf(oa, ob);
                float lengthY = hypotf(oc, od);
                float invY = lengthY != 0.0f ? 1.0f / lengthY : 1.0f;
                float invX = lengthX != 0.0f ? 1.0f / lengthX : 1.0f;
                finalTransform = CGAffineTransformMake(oa * invX, ob * invX, oc * invY, od * invY, otx, oty);
                finalSize = NSMakeSize(pixelsSize.width * lengthX, pixelsSize.height * lengthY);
                [image release];
            }
        }
    } @catch (NSException *exception) {
    }
    if (object == nil) {
        return;
    }
    [bitmapTool delete:self];
    [[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] setSize:finalSize affineTransform:finalTransform flippedHorizontally:NO withLayoutGuidingContext:nil];
    [[HSImageCropApplier cropApplierForImageObject:object] updateCurrentBorderPath];
    [[self activeCard] addHyperChild:object];
}

- (void)underline:(id)aUnderline
{
    id pvVar2;
    id pvVar1_2;

    pvVar1_2 = [[self selectedHyperObject] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [[self selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
    }
    pvVar2 = [HSToolManager sharedToolManager];
    if (pvVar1_2 == nil) {
        if ([pvVar2 selectedToolTag] == 0x2) {
            pvVar1_2 = [[[pvVar2 toolSettings] userObjectPrototypeForTool:[pvVar2 currentTool]] queryHyperInterface:@protocol(HSTextObjectAttributes)];
        }
    }
    if (pvVar1_2 != nil) {
        [pvVar1_2 setHyperUnderlined:(unsigned int)(![pvVar1_2 isHyperUnderlined])];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00019652 @ 00019652, 347 bytes * /

void FUN_00019652(HSEditorWindowController *self,SEL _cmd,id changeFontTrait)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  undefined *puVar6;
  
  pvVar2 = _objc_msgSend(changeFontTrait,sel_tag);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar4 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar6 = &DAT_003616dc;
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_003616dc);
  if ((pvVar4 == (id)0x0) &&
     (pvVar5 = _objc_msgSend(pvVar3,sel_selectedToolTag,puVar6), pvVar5 == (id)0x2)) {
    pvVar4 = _objc_msgSend(pvVar3,sel_toolSettings,puVar6);
    pvVar3 = _objc_msgSend(pvVar3,sel_currentTool);
    pvVar3 = _objc_msgSend(pvVar4,sel_userObjectPrototypeForTool_,pvVar3);
    puVar6 = &DAT_003616dc;
    pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003616dc);
  }
  if (pvVar4 != (id)0x0) {
    if (pvVar2 == (id)0x2) {
      pvVar2 = _objc_msgSend(pvVar4,sel_isHyperBold,puVar6);
      cVar1 = (char)pvVar2;
      op = sel_setHyperBold_;
    }
    else {
      if (pvVar2 != (id)0x1) {
        return;
      }
      pvVar2 = _objc_msgSend(pvVar4,sel_isHyperItalic,puVar6);
      cVar1 = (char)pvVar2;
      op = sel_setHyperItalic_;
    }
    _objc_msgSend(pvVar4,op,(uint)(cVar1 == '\0'));
  }
  return;
}

*/
- (void)changeFontTrait:(id)aTrait
{
    NSInteger trait = [aTrait tag];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    id target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    if (target == nil && [toolManager selectedToolTag] == 2) {
        target = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    }
    if (target != nil) {
        if (trait == 2) {
            [target setHyperBold:![target isHyperBold]];
        } else if (trait == 1) {
            [target setHyperItalic:![target isHyperItalic]];
        }
    }
}

- (void)addNewButtonDidDone:(id)aDone
{
    id pvVar1;

    pvVar1 = [aDone object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSButtonObjectAssistantPaneDidDoneNotification" object:pvVar1];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSButtonObjectAssistantPaneDidCancelNotification" object:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000192cb @ 000192cb, 544 bytes * /

void FUN_000192cb(HSEditorWindowController *self,SEL _cmd,id addButtonObject)

{
  id pvVar1;
  HSEditorWindowController *pHVar2;
  id self_00;
  HSEditorWindowController *self_01;
  SEL op;
  cfstringStruct *pcVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode)
  ;
  if ((char)pvVar1 != '\0') {
    pHVar2 = _objc_msgSend(cls_HSButtonObject,sel_defaultObject);
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pcVar3 = &cfstr_NewButtonTypeCoachingHintsKey;
    pvVar1 = _objc_msgSend(pvVar1,sel_dontShowCoachingHintsForKey_,
                           &cfstr_NewButtonTypeCoachingHintsKey);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(cls_HSButtonTypeAssistantPane,sel_new,pcVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      self_00 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
      _objc_msgSend(self_00,sel_pushAdditionalCoachingPane_forObject_,pvVar1,pHVar2);
      pvVar1 = _objc_msgSend(self,sel_cardView);
      _objc_msgSend(pvVar1,sel_addObjectToCenter_useDragPreferences_,pHVar2,0);
      _objc_msgSend(self,sel_didAddNewObject);
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_addNewButtonDidDone_,
                    &cfstr_HSButtonObjectAssistantPaneDidDoneNotification,pHVar2);
      self_01 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      op = sel_addObserver_selector_name_object_;
      pHVar2 = self;
      puVar4 = sel_addNewButtonDidCancel_;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_cardView,pcVar3);
      puVar4 = (undefined *)0x0;
      _objc_msgSend(pvVar1,sel_addObjectToCenter_useDragPreferences_,pHVar2,0);
      self_01 = self;
      op = sel_didAddNewObject;
    }
    _objc_msgSend(self_01,op,pHVar2,puVar4);
  }
  return;
}

*/
- (void)addButtonObject:(id)aObject
{
    if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
        HSButtonObject *button = [HSButtonObject defaultObject];
        if (![[HSCoachingHelpManager sharedCoachingHelpManager] dontShowCoachingHintsForKey:@"NewButtonTypeCoachingHintsKey"]) {
            id pane = [[HSButtonTypeAssistantPane new] autorelease];
            [[HSCoachingHelpManager sharedCoachingHelpManager] pushAdditionalCoachingPane:pane forObject:button];
            [[self cardView] addObjectToCenter:button useDragPreferences:NO];
            [self didAddNewObject];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewButtonDidDone:) name:@"HSButtonObjectAssistantPaneDidDoneNotification" object:button];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewButtonDidCancel:) name:@"HSButtonObjectAssistantPaneDidCancelNotification" object:button];
        } else {
            [[self cardView] addObjectToCenter:button useDragPreferences:NO];
            [self didAddNewObject];
        }
    }
}

- (void)sameBackground:(id)aBackground
{
    id pvVar3;
    id self_00;
    id pvVar2_2;
    NSUInteger pvVar2_3;
    id pvVar3_3;
    id pvVar4_2;

    pvVar2_2 = [[self document] currentCard];
    pvVar3 = [pvVar2_2 unitForRole:HSEditableBackgroundUnitRole];
    self_00 = [HSCard node];
    pvVar4_2 = [[self document] stack];
    pvVar2_3 = [[pvVar4_2 hyperChildren] indexOfObject:pvVar2_2];
    pvVar3_3 = [[pvVar3 copyWithZone:0] autorelease];
    if (pvVar3_3 != nil) {
        [self_00 injectUnit:pvVar3_3 forRole:HSEditableBackgroundUnitRole];
    }
    [pvVar4_2 insertHyperChild:self_00 atIndex:(int)pvVar2_3 + 1];
}

- (void)makeGroupCard:(id)aCard
{
    [[[self document] currentCard] makeNewGroupCard];
}

- (void)standardColors:(id)aColors
{
    [[HSBigColorMatrixDataProvider sharedDataProvider] resetToDefault];
    [[[HSToolManager sharedToolManager] toolSettings] resetColorsToDefault];
}

- (void)ignoreSpelling:(id)aSpelling
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSIgnoreMisspelledWordNotification object:aSpelling]
    ;
}

- (void)changeSpelling:(id)aSpelling
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSCorrectMisspelledWordNotification object:aSpelling]
    ;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00018ee1 @ 00018ee1, 318 bytes * /

void FUN_00018ee1(HSEditorWindowController *self,SEL _cmd,id hyperShowGuessPanel)

{
  id pvVar1;
  id self_00;
  SEL op;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentToolSet);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentCard);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperCount);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
      puVar2 = &DAT_003619e8;
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003619e8);
      if (pvVar1 != (id)0x0) {
        pvVar1 = *(id *)PTR_00336058;
        self_00 = _objc_msgSend(self,sel_window,puVar2);
        _objc_msgSend(self_00,sel_firstResponder);
        op = sel_sendAction_to_from_;
        hyperShowGuessPanel = sel_showGuessPanel_;
        goto LAB_00019012;
      }
    }
  }
  pvVar1 = _objc_msgSend(cls_HSTextProvider,sel_sharedInstance);
  op = sel_performShowGuessPanel_;
LAB_00019012:
  _objc_msgSend(pvVar1,op,hyperShowGuessPanel);
  return;
}

*/
- (void)hyperShowGuessPanel:(id)aPanel
{
    if ([[HSToolManager sharedToolManager] currentToolSet] == nil && [[[self document] currentCard] hyperCount] == 0
        && [[self selectedHyperObject] queryHyperInterface:@protocol(HSRunTimeEditor)] != nil) {
        [NSApp sendAction:@selector(showGuessPanel:) to:[[self window] firstResponder] from:aPanel];
        return;
    }
    [[HSTextProvider sharedInstance] performShowGuessPanel:aPanel];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00018da3 @ 00018da3, 318 bytes * /

void FUN_00018da3(HSEditorWindowController *self,SEL _cmd,id hyperCheckSpelling)

{
  id pvVar1;
  id self_00;
  SEL op;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentToolSet);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentCard);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperCount);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
      puVar2 = &DAT_003619e8;
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003619e8);
      if (pvVar1 != (id)0x0) {
        pvVar1 = *(id *)PTR_00336058;
        self_00 = _objc_msgSend(self,sel_window,puVar2);
        _objc_msgSend(self_00,sel_firstResponder);
        op = sel_sendAction_to_from_;
        hyperCheckSpelling = sel_checkSpelling_;
        goto LAB_00018ed4;
      }
    }
  }
  pvVar1 = _objc_msgSend(cls_HSTextProvider,sel_sharedInstance);
  op = sel_performCheckSpelling_;
LAB_00018ed4:
  _objc_msgSend(pvVar1,op,hyperCheckSpelling);
  return;
}

*/
- (void)hyperCheckSpelling:(id)aSpelling
{
    if ([[HSToolManager sharedToolManager] currentToolSet] == nil && [[[self document] currentCard] hyperCount] == 0
        && [[self selectedHyperObject] queryHyperInterface:@protocol(HSRunTimeEditor)] != nil) {
        [NSApp sendAction:@selector(checkSpelling:) to:[[self window] firstResponder] from:aSpelling];
        return;
    }
    [[HSTextProvider sharedInstance] performCheckSpelling:aSpelling];
}

- (void)performHyperFindPanelAction:(id)aAction
{
    [[HSTextProvider sharedInstance] performFindAction:aAction];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00018c74 @ 00018c74, 235 bytes * /

void FUN_00018c74(HSEditorWindowController *self,SEL _cmd,id toolPaletteSwitchTool)

{
  id pvVar1;
  id self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(toolPaletteSwitchTool,sel_tag);
  op = sel_switchTool_;
  if (pvVar1 == (id)0x18) {
    pvVar1 = _objc_msgSend(cls_NSMenuItem,sel_new);
    _objc_msgSend(pvVar1,sel_setTag_,0);
    self_00 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    _objc_msgSend(self_00,sel_setOnionSkin_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
    self = _objc_msgSend(self,sel_document);
    toolPaletteSwitchTool = (id)0x0;
    op = sel_testCard_;
  }
  _objc_msgSend(self,op,toolPaletteSwitchTool);
  return;
}

*/
- (void)toolPaletteSwitchTool:(id)aTool
{
    if ([aTool tag] == 0x18) {
        NSMenuItem *item = [NSMenuItem new];
        [item setTag:0];
        [[HSEditorController sharedDocumentController] setOnionSkin:item];
        [item release];
        [[self document] testCard:nil];
    } else {
        [self switchTool:aTool];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00018a0a @ 00018a0a, 618 bytes * /

void FUN_00018a0a(HSEditorWindowController *self,SEL _cmd,id activateSelectedObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  id pvVar5;
  SEL pcVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar4 = &DAT_003612cc;
  pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_003612cc);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,puVar4);
  puVar4 = &DAT_003619e8;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003619e8);
  pvVar2 = _objc_msgSend(self,sel_selectedHyperObject);
  if (pvVar1 != (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_cardView,puVar4);
    puVar4 = _objc_msgSend(self,sel_selectedHyperObject);
    pcVar6 = sel_startEditorForObject_creationMode_;
    if (pvVar2 == pvVar1) {
      pcVar6 = sel_endEditorForObject_;
    }
    _objc_msgSend(pvVar3,pcVar6,puVar4);
  }
  pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar4);
  pvVar5 = _objc_msgSend(pvVar3,sel_isActive);
  if ((char)pvVar5 == '\0') {
    if ((pvVar1 != (id)0x0) && (pvVar2 == pvVar1)) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_selectedUserObject);
    puVar4 = &DAT_00361358;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361358);
    pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
    if ((char)pvVar1 != '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar4);
    uVar7 = *(undefined4 *)PTR_003360c4;
    pvVar1 = _objc_msgSend(pvVar1,sel_boolForKey_,uVar7);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(pvVar3,sel_objectAssistant,uVar7);
      _objc_msgSend(pvVar1,sel_setPrefersInspectorMode_,0);
    }
    uVar7 = 1;
    _objc_msgSend(pvVar3,sel_setActive_explicitlyByUser_,1,1);
    pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
    pcVar6 = sel_setSelectedInModelObjectAndBringAssistantToFront_;
  }
  else {
    if (pvVar2 != pvVar1 && pvVar1 != (id)0x0) {
      return;
    }
    uVar7 = 1;
    pvVar1 = (id)0x0;
    pcVar6 = sel_setActive_explicitlyByUser_;
  }
  _objc_msgSend(pvVar3,pcVar6,pvVar1,uVar7);
  return;
}

*/
- (void)activateSelectedObject:(id)aObject
{
    if (![[self selectedHyperObject] implementsHyperInterface:@protocol(HSCardObjectAttributes)]) {
        return;
    }
    id editor = [[self selectedHyperObject] queryHyperInterface:@protocol(HSRunTimeEditor)];
    id selected = [self selectedHyperObject];
    if (editor != nil) {
        if (selected == editor) {
            [[self cardView] endEditorForObject:[self selectedHyperObject]];
        } else {
            [[self cardView] startEditorForObject:[self selectedHyperObject] creationMode:NO];
        }
    }
    HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
    if (![assistant isActive]) {
        if (editor != nil && selected == editor) {
            return;
        }
        if ([[[self selectedUserObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
            return;
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:HSForceSOTSForNewObjectsKey]) {
            [[assistant objectAssistant] setPrefersInspectorMode:NO];
        }
        [assistant setActive:YES explicitlyByUser:YES];
        [assistant setSelectedInModelObjectAndBringAssistantToFront:[self selectedHyperObject]];
    } else {
        if (editor != nil && selected != editor) {
            return;
        }
        [assistant setActive:NO explicitlyByUser:YES];
    }
}

- (void)snapToObjects:(id)aObjects
{
    id pvVar1_3;

    pvVar1_3 = [[[self document] stack] guidelinesSettings];
    [pvVar1_3 setSnapToObjectsEnabled:(unsigned int)(![pvVar1_3 isSnapToObjectsEnabled])];
}

- (void)snapToGrid:(id)aGrid
{
    id pvVar1_3;

    pvVar1_3 = [[[self document] stack] gridSettings];
    [pvVar1_3 setIsSnapToGridEnabled:(unsigned int)(![pvVar1_3 isSnapToGridEnabled])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001885c @ 0001885c, 174 bytes * /

void FUN_0001885c(HSEditorWindowController *self,SEL _cmd,id toggleAuxiliaryIcons)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar1 = *(undefined4 *)PTR_00336034;
  pvVar3 = _objc_msgSend(pvVar2,sel_boolForKey_,uVar1);
  _objc_msgSend(pvVar2,sel_setBool_forKey_,(uint)((char)pvVar3 == '\0'),uVar1);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_postNotificationName_object_,*(undefined4 *)PTR_00336038,self);
  return;
}

*/
- (void)toggleAuxiliaryIcons:(id)aIcons
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:![defaults boolForKey:HSHideAuxiliaryIcons] forKey:HSHideAuxiliaryIcons];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSHideAuxiliaryIconsDidChangeNotification object:self];
}

- (void)restoreToOriginalGraphic:(id)aGraphic
{
    id pvVar1;

    pvVar1 = [_cardView selection];
    if (pvVar1 != nil) {
        if ([pvVar1 objectsCount] == 0x1) {
            [HSImageObjectRestorer restoreNodeToOriginal:[[[[[HSSelectionOperationVerifier alloc] initWithSelection:pvVar1] autorelease] selectedNodesArrayForRestoreOperation] lastObject]];
        }
    }
}

- (void)mergeSelectionToImage:(id)aImage
{
    [_cardView flatSelectedObjects:YES];
}

- (void)flatSelectionToImage:(id)aImage
{
    [_cardView flatSelectedObjects:YES];
}

- (void)flatSelection:(id)aSelection
{
    [_cardView flatSelectedObjects:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00024da7 @ 00024da7, 265 bytes * /

NSRect * FUN_00024da7(NSRect *__return_storage_ptr__,HSEditorWindowController *self,SEL _cmd,
                     id unionRectForArrayOfObjects)

{
  id self_00;
  id pvVar1;
  int *piVar2;
  int aiStack_68 [3];
  undefined8 local_54 [4];
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  local_34 = *(float *)PTR_00336078;
  fStack_30 = *(float *)(PTR_00336078 + 4);
  local_2c = *(float *)(PTR_00336078 + 8);
  fStack_28 = *(float *)(PTR_00336078 + 0xc);
  self_00 = _objc_msgSend(unionRectForArrayOfObjects,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  if (pvVar1 != (id)0x0) {
    piVar2 = (int *)&stack0xffffffa4;
    do {
      piVar2[2] = (int)sel_frameBoundingRect;
      piVar2[1] = (int)pvVar1;
      *piVar2 = (int)&local_24;
      piVar2[-1] = 0x24e2c;
      _objc_msgSend_stret((void *)*piVar2,(id)piVar2[1],(SEL)piVar2[2]);
      *(undefined8 *)(piVar2 + 6) = local_1c;
      *(undefined8 *)(piVar2 + 4) = local_24;
      *(ulonglong *)(piVar2 + 2) = CONCAT44(fStack_28,local_2c);
      *(ulonglong *)piVar2 = CONCAT44(fStack_30,local_34);
      piVar2[-1] = (int)&local_34;
      piVar2[-2] = 0x24e63;
      _NSUnionRect();
      piVar2[-1] = (int)sel_nextObject;
      piVar2[-2] = (int)self_00;
      piVar2[-3] = 0x24e78;
      pvVar1 = _objc_msgSend((id)piVar2[-2],(SEL)piVar2[-1]);
      piVar2 = piVar2 + -2;
    } while (pvVar1 != (id)0x0);
  }
  (__return_storage_ptr__->origin).x = local_34;
  (__return_storage_ptr__->origin).y = fStack_30;
  (__return_storage_ptr__->size).width = local_2c;
  (__return_storage_ptr__->size).height = fStack_28;
  return __return_storage_ptr__;
}

*/
- (NSRect)unionRectForArrayOfObjects:(id)aObjects
{
    NSRect result = NSZeroRect;
    NSEnumerator *enumerator = [aObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        result = NSUnionRect(result, [object frameBoundingRect]);
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00018404 @ 00018404, 755 bytes * /

void FUN_00018404(HSEditorWindowController *self,SEL _cmd,id flipUpsideDown)

{
  id pvVar1;
  id pvVar2;
  SEL pcVar3;
  float extraout_EDX;
  undefined8 in_stack_ffffff9c;
  ulonglong uVar4;
  undefined4 uVar5;
  uint uVar6;
  float local_3c;
  id local_38;
  undefined *local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  uVar5 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar2 = _objc_msgSend(self,sel_class);
  uVar4 = CONCAT44(uVar5,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_isValidSelectionTool_,pvVar1);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_bitmapTool,uVar4);
    uVar4 = uVar4 & 0xffffffff00000000;
    _objc_msgSend(pvVar1,sel_finalizeSelection_,0);
    pcVar3 = sel_flipSelectionVertically;
    goto LAB_000186ea;
  }
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,uVar4);
  pvVar2 = _objc_msgSend(self,sel_selectedCard);
  if (pvVar1 == pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_class,uVar4);
    uVar4 = CONCAT44((int)(uVar4 >> 0x20),pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_canFlipUpsideDownObject_,pvVar1);
    if ((char)pvVar2 != '\0') {
      uVar5 = (undefined4)(uVar4 >> 0x20);
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361970);
      local_38 = *(id *)PTR_0033607c;
      local_3c = *(float *)(PTR_0033607c + 4);
      if (pvVar2 == (id)0x0) {
        uVar4 = CONCAT44(uVar5,sel_image);
        pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_image);
        if (((char)pvVar2 != '\0') &&
           (pvVar1 = _objc_msgSend(pvVar1,sel_image,uVar4), pcVar3 = sel_size, pvVar1 != (id)0x0))
        goto LAB_000185c7;
      }
      else {
        local_34 = &DAT_003619ac;
        local_30 = 0;
        uVar4 = ZEXT48(&local_34);
        pvVar1 = _objc_msgSend(pvVar2,sel_queryImageWithRequiredProtocols_optionalProtocols_,
                               &local_34,0);
        pcVar3 = sel_imageSize;
        if (pvVar1 == (id)0x0) {
          return;
        }
LAB_000185c7:
        local_38 = _objc_msgSend(pvVar1,pcVar3,uVar4);
        local_3c = extraout_EDX;
      }
      if ((float)local_38 == 0.0) {
        return;
      }
      if (local_3c == 0.0) {
        return;
      }
      fStack_18 = local_3c + 0.0;
      local_2c = 0x3f800000;
      uStack_28 = 0;
      local_24 = 0;
      uStack_20 = 0xbf800000;
      local_1c = 0;
      pvVar1 = _objc_msgSend(self,sel_class,uVar4);
      uVar4 = CONCAT44(uStack_28,local_2c);
      pcVar3 = sel_setTransform_toImageOfObject_;
      goto LAB_000186ea;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_selectedCardObjectForEditingOperationWithImplicitVerification,
                         uVar4);
  uVar6 = (uint)(uVar4 >> 0x20);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003619d4);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  if (pvVar1 == (id)0x0) {
    return;
  }
  uVar4 = (ulonglong)uVar6 << 0x20;
  pcVar3 = sel_flipVerticallyWithLayoutGuidingContext_;
LAB_000186ea:
  _objc_msgSend(pvVar1,pcVar3,uVar4);
  return;
}

*/
- (void)flipUpsideDown:(id)aDown
{
    id tool = [[HSToolManager sharedToolManager] currentTool];
    if ([[self class] isValidSelectionTool:tool]) {
        id bitmapTool = [tool bitmapTool];
        [bitmapTool finalizeSelection:nil];
        [bitmapTool flipSelectionVertically];
        return;
    }
    id selected = [self selectedHyperObject];
    if (selected == [self selectedCard] && [[self class] canFlipUpsideDownObject:selected]) {
        NSSize size = NSZeroSize;
        id editable = [selected queryHyperInterface:@protocol(HSEditableImageAttributes)];
        if (editable == nil) {
            if ([selected respondsToSelector:@selector(image)]) {
                id image = [selected image];
                if (image != nil) {
                    size = [image size];
                }
            }
        } else {
            id requiredProtocols[2] = { @protocol(BTCGImage), nil };
            id image = [editable queryImageWithRequiredProtocols:requiredProtocols optionalProtocols:NULL];
            if (image == nil) {
                return;
            }
            size = [image imageSize];
        }
        if (size.width == 0.0f || size.height == 0.0f) {
            return;
        }
        [[self class] setTransform:CGAffineTransformMake(1, 0, 0, -1, 0, size.height) toImageOfObject:selected];
        return;
    }
    id applier = [[[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil) {
        return;
    }
    [applier flipVerticallyWithLayoutGuidingContext:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001810c @ 0001810c, 760 bytes * /

void FUN_0001810c(HSEditorWindowController *self,SEL _cmd,id flipSideways)

{
  id pvVar1;
  id pvVar2;
  SEL pcVar3;
  float extraout_EDX;
  undefined8 in_stack_ffffff9c;
  ulonglong uVar4;
  undefined4 uVar5;
  uint uVar6;
  float local_3c;
  id local_38;
  undefined *local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  float local_1c;
  undefined4 uStack_18;
  
  uVar5 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar2 = _objc_msgSend(self,sel_class);
  uVar4 = CONCAT44(uVar5,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_isValidSelectionTool_,pvVar1);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_bitmapTool,uVar4);
    uVar4 = uVar4 & 0xffffffff00000000;
    _objc_msgSend(pvVar1,sel_finalizeSelection_,0);
    pcVar3 = sel_flipSelectionHorizontally;
    goto LAB_000183f7;
  }
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,uVar4);
  pvVar2 = _objc_msgSend(self,sel_selectedCard);
  if (pvVar1 == pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_class,uVar4);
    uVar4 = CONCAT44((int)(uVar4 >> 0x20),pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_canFlipSidewaysObject_,pvVar1);
    if ((char)pvVar2 != '\0') {
      uVar5 = (undefined4)(uVar4 >> 0x20);
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361970);
      local_38 = *(id *)PTR_0033607c;
      local_3c = *(float *)(PTR_0033607c + 4);
      if (pvVar2 == (id)0x0) {
        uVar4 = CONCAT44(uVar5,sel_image);
        pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_image);
        if (((char)pvVar2 != '\0') &&
           (pvVar1 = _objc_msgSend(pvVar1,sel_image,uVar4), pcVar3 = sel_size, pvVar1 != (id)0x0))
        goto LAB_000182cf;
      }
      else {
        local_34 = &DAT_003619ac;
        local_30 = 0;
        uVar4 = ZEXT48(&local_34);
        pvVar1 = _objc_msgSend(pvVar2,sel_queryImageWithRequiredProtocols_optionalProtocols_,
                               &local_34,0);
        pcVar3 = sel_imageSize;
        if (pvVar1 == (id)0x0) {
          return;
        }
LAB_000182cf:
        local_38 = _objc_msgSend(pvVar1,pcVar3,uVar4);
        local_3c = extraout_EDX;
      }
      if ((float)local_38 == 0.0) {
        return;
      }
      if (local_3c == 0.0) {
        return;
      }
      local_1c = (float)local_38 + 0.0;
      local_2c = 0xbf800000;
      uStack_28 = 0;
      local_24 = 0;
      uStack_20 = 0x3f800000;
      uStack_18 = 0;
      pvVar1 = _objc_msgSend(self,sel_class,uVar4);
      uVar4 = CONCAT44(uStack_28,local_2c);
      pcVar3 = sel_setTransform_toImageOfObject_;
      goto LAB_000183f7;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_selectedCardObjectForEditingOperationWithImplicitVerification,
                         uVar4);
  uVar6 = (uint)(uVar4 >> 0x20);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003619d4);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  if (pvVar1 == (id)0x0) {
    return;
  }
  uVar4 = (ulonglong)uVar6 << 0x20;
  pcVar3 = sel_flipHorizontallyWithLayoutGuidingContext_;
LAB_000183f7:
  _objc_msgSend(pvVar1,pcVar3,uVar4);
  return;
}

*/
- (void)flipSideways:(id)aSideways
{
    id tool = [[HSToolManager sharedToolManager] currentTool];
    if ([[self class] isValidSelectionTool:tool]) {
        id bitmapTool = [tool bitmapTool];
        [bitmapTool finalizeSelection:nil];
        [bitmapTool flipSelectionHorizontally];
        return;
    }
    id selected = [self selectedHyperObject];
    if (selected == [self selectedCard] && [[self class] canFlipSidewaysObject:selected]) {
        NSSize size = NSZeroSize;
        id editable = [selected queryHyperInterface:@protocol(HSEditableImageAttributes)];
        if (editable == nil) {
            if ([selected respondsToSelector:@selector(image)]) {
                id image = [selected image];
                if (image != nil) {
                    size = [image size];
                }
            }
        } else {
            id requiredProtocols[2] = { @protocol(BTCGImage), nil };
            id image = [editable queryImageWithRequiredProtocols:requiredProtocols optionalProtocols:NULL];
            if (image == nil) {
                return;
            }
            size = [image imageSize];
        }
        if (size.width == 0.0f || size.height == 0.0f) {
            return;
        }
        [[self class] setTransform:CGAffineTransformMake(-1, 0, 0, 1, size.width, 0) toImageOfObject:selected];
        return;
    }
    id applier = [[[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil) {
        return;
    }
    [applier flipHorizontallyWithLayoutGuidingContext:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00024eb0 @ 00024eb0, 982 bytes * /

void FUN_00024eb0(HSEditorWindowController *self,SEL _cmd,id centerSelectedObjectOnCard)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 *puVar3;
  
  puVar3 = (undefined4 *)&stack0xffffff74;
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(pvVar2,sel_isValidSelectionTool_);
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_selectedCardObjectForEditingOperationWithImplicitVerification);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_stack);
    _objc_msgSend(pvVar1,sel_hyperCardSize);
  }
  else {
    pvVar2 = _objc_msgSend(pvVar1,sel_bitmapTool);
    pvVar2 = _objc_msgSend(pvVar2,sel_selectionPath);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,sel_currentCard);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
    op = sel_size;
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_document);
      pvVar2 = _objc_msgSend(pvVar2,sel_stack);
      op = sel_hyperCardSize;
    }
    _objc_msgSend(pvVar2,op);
    _CGEPathGetPathBoundingBox();
    pvVar1 = _objc_msgSend(pvVar1,sel_bitmapTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectionPathTransform);
    _objc_msgSend(pvVar1,sel_getValue_);
    _CGAffineTransformMakeTranslation();
    puVar3 = (undefined4 *)&stack0xffffff6c;
    _objc_msgSend(self,sel_class);
  }
  puVar3[-1] = 0x2527c;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  return;
}

*/
- (void)centerSelectedObjectOnCard:(id)aCard
{
    id tool = [[HSToolManager sharedToolManager] currentTool];
    if ([[self class] isValidSelectionTool:tool]) {
        id bitmapTool = [tool bitmapTool];
        CGPathRef selectionPath = (CGPathRef)[bitmapTool selectionPath];
        if (selectionPath == NULL) {
            return;
        }
        id card = [[self document] currentCard];
        NSSize cardSize;
        if ([card queryHyperInterface:@protocol(HSSizeAttributes)] != nil) {
            cardSize = [card size];
        } else {
            cardSize = [[[self document] stack] hyperCardSize];
        }
        CGRect pathBounds = CGEPathGetPathBoundingBox(selectionPath);
        float centerX = pathBounds.origin.x + pathBounds.size.width * 0.5f;
        float centerY = pathBounds.origin.y + pathBounds.size.height * 0.5f;
        CGAffineTransform pathTransform;
        [[[tool bitmapTool] selectionPathTransform] getValue:&pathTransform];
        float x = cardSize.width * 0.5f - (float)(pathTransform.a * centerX + pathTransform.c * centerY + pathTransform.tx);
        float y = cardSize.height * 0.5f - (float)(pathTransform.b * centerX + pathTransform.d * centerY + pathTransform.ty);
        [[self class] applyTransform:CGAffineTransformMakeTranslation(x, y) toBitmapTool:tool];
    } else {
        id applier = [[[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier == nil) {
            return;
        }
        NSSize cardSize = [[[self document] stack] hyperCardSize];
        [applier moveCenterTo:NSMakePoint(cardSize.width * 0.5f, cardSize.height * 0.5f) withLayoutGuidingContext:nil];
    }
}

- (void)resizeToFillCard:(id)aCard
{
    [self resizeSelectedObject:NO];
}

- (void)resizeToFitCard:(id)aCard
{
    [self resizeSelectedObject:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00025286 @ 00025286, 1802 bytes * /

void FUN_00025286(HSEditorWindowController *self,SEL _cmd,BOOL resizeSelectedObject)

{
  bool bVar1;
  float fVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  SEL pcVar7;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  double dVar12;
  undefined8 uVar13;
  undefined8 in_stack_ffffff70;
  uint uVar15;
  ulonglong uVar14;
  float local_54;
  float local_4c;
  float local_48;
  float local_44;
  float local_40;
  float local_3c;
  undefined4 uStack_38;
  undefined4 local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  
  uVar15 = (uint)((ulonglong)in_stack_ffffff70 >> 0x20);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar4 = _objc_msgSend(pvVar3,sel_currentTool);
  pvVar5 = _objc_msgSend(self,sel_class);
  pvVar3 = pvVar4;
  pvVar5 = _objc_msgSend(pvVar5,sel_isValidSelectionTool_);
  if ((char)pvVar5 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_selectedCardObjectForEditingOperationWithImplicitVerification);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryGeometryBehaviorApplier);
    if (pvVar3 == (id)0x0) {
      return;
    }
    pvVar4 = _objc_msgSend(self,sel_document);
    pvVar4 = _objc_msgSend(pvVar4,sel_currentCard);
    pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_);
    pcVar7 = sel_size;
    if (pvVar4 == (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_document);
      pvVar4 = _objc_msgSend(pvVar4,sel_stack);
      pcVar7 = sel_hyperCardSize;
    }
    pvVar4 = _objc_msgSend(pvVar4,pcVar7);
    pvVar5 = _objc_msgSend(pvVar3,sel_mutableGeometryAttributes);
    dVar12 = _objc_msgSend_fpret(pvVar5,sel_rotationAngle);
    fVar2 = (float)dVar12;
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      local_54 = ABS(fVar2);
    }
    else {
      local_54 = 1.0;
    }
    bVar1 = local_54 <= 1.0;
    local_54 = local_54 * 0.0005;
    if (bVar1) {
      local_54 = 0.0005;
    }
    pvVar6 = _objc_msgSend(pvVar5,sel_affineFrameSize);
    if (((float)pvVar6 != 0.0) || (NAN((float)pvVar6))) {
      fVar8 = ABS((float)pvVar6);
    }
    else {
      fVar8 = 1.0;
    }
    if (((float)pvVar4 != 0.0) || (NAN((float)pvVar4))) {
      fVar9 = ABS((float)pvVar4);
    }
    else {
      fVar9 = 1.0;
    }
    if (fVar9 <= fVar8) {
      fVar9 = fVar8;
    }
    if (ABS((float)pvVar6 - (float)pvVar4) <= fVar9 * 0.0005) {
      if ((extraout_EDX_01 != 0.0) || (NAN(extraout_EDX_01))) {
        fVar8 = ABS(extraout_EDX_01);
      }
      else {
        fVar8 = 1.0;
      }
      if ((extraout_EDX_00 != 0.0) || (NAN(extraout_EDX_00))) {
        fVar9 = ABS(extraout_EDX_00);
      }
      else {
        fVar9 = 1.0;
      }
      if (fVar9 <= fVar8) {
        fVar9 = fVar8;
      }
      bVar1 = fVar9 * 0.0005 < ABS(extraout_EDX_01 - extraout_EDX_00);
    }
    else {
      bVar1 = true;
    }
    _objc_msgSend_stret(&local_24,pvVar5,sel_frameBoundingRect);
    fVar8 = *(float *)PTR_00336074;
    fVar9 = *(float *)(PTR_00336074 + 4);
    if ((fVar8 != 0.0) || (NAN(fVar8))) {
      fVar10 = ABS(fVar8);
    }
    else {
      fVar10 = 1.0;
    }
    if ((local_24 != 0.0) || (NAN(local_24))) {
      fVar11 = ABS(local_24);
    }
    else {
      fVar11 = 1.0;
    }
    if (fVar11 <= fVar10) {
      fVar11 = fVar10;
    }
    if (ABS(fVar8 - local_24) <= fVar11 * 0.0005) {
      if ((fVar9 != 0.0) || (NAN(fVar9))) {
        fVar8 = ABS(fVar9);
      }
      else {
        fVar8 = 1.0;
      }
      if ((local_20 != 0.0) || (NAN(local_20))) {
        fVar10 = ABS(local_20);
      }
      else {
        fVar10 = 1.0;
      }
      if (ABS(0.0 - fVar2) <= local_54 && !bVar1) {
        if (fVar10 <= fVar8) {
          fVar10 = fVar8;
        }
        if (ABS(fVar9 - local_20) <= fVar10 * 0.0005) {
          return;
        }
      }
    }
    pvVar5 = _objc_msgSend(self,sel_document);
    pvVar5 = _objc_msgSend(pvVar5,sel_undoManager);
    pvVar6 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    uVar14 = (ulonglong)uVar15 << 0x20;
    pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Resize,&cfstr_empty,
                           &cfstr_UndoManager);
    _objc_msgSend(pvVar5,sel_setMultipleActionsName_,pvVar6);
    if (local_54 < ABS(0.0 - fVar2)) {
      uVar14 = 0;
      _objc_msgSend(pvVar3,sel_rotateTo_aboutRelativePoint_withLayoutGuidingContext_,0,0x3f000000,
                    0x3f000000,0);
    }
    if (bVar1) {
      uVar14 = 0x3f0000003f000000;
      _objc_msgSend(pvVar3,
                    sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                    ,pvVar4,extraout_EDX_00,0x3f000000,0x3f000000,1,3,
                    (uint)(resizeSelectedObject == '\0'),0);
    }
    uVar13 = CONCAT44(extraout_EDX_00 * 0.5,(float)pvVar4 * 0.5);
    uVar14 = uVar14 & 0xffffffff00000000;
    pcVar7 = sel_moveCenterTo_withLayoutGuidingContext_;
  }
  else {
    pvVar4 = _objc_msgSend(pvVar4,sel_bitmapTool);
    pvVar4 = _objc_msgSend(pvVar4,sel_selectionPath);
    if (pvVar4 == (id)0x0) {
      return;
    }
    _CGEPathGetPathBoundingBox(&local_4c,pvVar4);
    pvVar4 = _objc_msgSend(self,sel_document);
    pvVar4 = _objc_msgSend(pvVar4,sel_currentCard);
    uVar13 = CONCAT44(pvVar3,&DAT_003614fc);
    pvVar3 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_003614fc);
    pcVar7 = sel_size;
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_document,uVar13);
      pvVar3 = _objc_msgSend(pvVar3,sel_stack);
      pcVar7 = sel_hyperCardSize;
    }
    pvVar3 = _objc_msgSend(pvVar3,pcVar7,uVar13);
    if ((local_44 != 0.0) || (NAN(local_44))) {
      local_3c = (float)pvVar3 / local_44;
    }
    else {
      local_3c = 1.0;
    }
    if ((local_40 != 0.0) || (NAN(local_40))) {
      fStack_30 = extraout_EDX / local_40;
    }
    else {
      fStack_30 = 1.0;
    }
    local_2c = 0.0 - local_4c * local_3c;
    uStack_38 = 0;
    local_34 = 0;
    fStack_28 = 0.0 - local_48 * fStack_30;
    pvVar3 = _objc_msgSend(self,sel_class,uVar13);
    uVar13 = CONCAT44(uStack_38,local_3c);
    uVar14 = CONCAT44(fStack_30,local_34);
    pcVar7 = sel_setTransform_toBitmapTool_;
  }
  _objc_msgSend(pvVar3,pcVar7,uVar13,uVar14);
  return;
}

*/
- (void)resizeSelectedObject:(BOOL)aObject
{
    id tool = [[HSToolManager sharedToolManager] currentTool];
    if (![[self class] isValidSelectionTool:tool]) {
        id applier = [[[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier == nil) {
            return;
        }
        id card = [[self document] currentCard];
        NSSize cardSize;
        if ([card queryHyperInterface:@protocol(HSSizeAttributes)] != nil) {
            cardSize = [card size];
        } else {
            cardSize = [[[self document] stack] hyperCardSize];
        }
        id geometry = [applier mutableGeometryAttributes];
        float angle = (float)[geometry rotationAngle];
        float angleTolerance = MAX(fabsf(angle), 1.0f) * 0.0005f;
        NSSize frameSize = [geometry affineFrameSize];
        BOOL sizeDiffers;
        if (HSEditorFuzzyEqual(frameSize.width, cardSize.width) && HSEditorFuzzyEqual(frameSize.height, cardSize.height)) {
            sizeDiffers = NO;
        } else {
            sizeDiffers = YES;
        }
        NSRect frame = [geometry frameBoundingRect];
        if (HSEditorFuzzyEqual(NSZeroPoint.x, frame.origin.x) && HSEditorFuzzyEqual(NSZeroPoint.y, frame.origin.y) && fabsf(0.0f - angle) <= angleTolerance && !sizeDiffers) {
            return;
        }
        [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Resize" value:@"" table:@"UndoManager"]];
        if (angleTolerance < fabsf(0.0f - angle)) {
            [applier rotateTo:0.0 aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
        }
        if (sizeDiffers) {
            [applier resizeFrameTo:cardSize aboutRelativePoint:NSMakePoint(0.5, 0.5) followResizingScalingPreference:YES maintainAspectRatio:3 byAspectRatioMaintainingRule:(aObject == NO) withLayoutGuidingContext:nil];
        }
        [applier moveCenterTo:NSMakePoint(cardSize.width * 0.5f, cardSize.height * 0.5f) withLayoutGuidingContext:nil];
    } else {
        CGPathRef selectionPath = (CGPathRef)[[tool bitmapTool] selectionPath];
        if (selectionPath == NULL) {
            return;
        }
        CGRect bounds = CGEPathGetPathBoundingBox(selectionPath);
        id card = [[self document] currentCard];
        NSSize cardSize;
        if ([card queryHyperInterface:@protocol(HSSizeAttributes)] != nil) {
            cardSize = [card size];
        } else {
            cardSize = [[[self document] stack] hyperCardSize];
        }
        float scaleX = bounds.size.width != 0.0f ? cardSize.width / bounds.size.width : 1.0f;
        float scaleY = bounds.size.height != 0.0f ? cardSize.height / bounds.size.height : 1.0f;
        CGAffineTransform transform = CGAffineTransformMake(scaleX, 0.0f, 0.0f, scaleY, 0.0f - bounds.origin.x * scaleX, 0.0f - bounds.origin.y * scaleY);
        [[self class] setTransform:transform toBitmapTool:tool];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00025990 @ 00025990, 802 bytes * /

void FUN_00025990(HSEditorWindowController *self,SEL _cmd,BOOL spacingObjectsWithDirection)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  code *pcVar5;
  SEL op;
  uint uVar6;
  float fVar7;
  float fVar8;
  undefined *puVar9;
  undefined4 uVar10;
  cfstringStruct *pcVar11;
  int local_68;
  float local_54 [2];
  float local_4c;
  undefined1 local_44 [4];
  float local_40;
  float local_38;
  float local_34 [2];
  float local_2c;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  uVar10 = 0;
  pvVar1 = _objc_msgSend(self,
                         sel_selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray_
                         ,0);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if ((id)0x2 < pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_document,uVar10);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar11 = &cfstr_UndoManager;
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Align_Objects,
                           &cfstr_empty,&cfstr_UndoManager);
    _objc_msgSend(pvVar2,sel_setMultipleActionsName_,pvVar3);
    if (spacingObjectsWithDirection == '\0') {
      pcVar5 = FUN_0002d92a;
    }
    else {
      pcVar5 = FUN_0002d898;
    }
    uVar10 = 0;
    pvVar1 = _objc_msgSend(pvVar1,sel_sortedArrayUsingFunction_context_,pcVar5,0,pcVar11);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0,uVar10,pcVar11);
      pvVar3 = _objc_msgSend(pvVar1,sel_lastObject);
      pvVar4 = _objc_msgSend(pvVar1,sel_count);
      if (spacingObjectsWithDirection == '\0') {
        _objc_msgSend_stret(local_44,pvVar2,sel_frameBoundingRect);
        fVar7 = local_38 * 0.5 + local_40;
        puVar9 = sel_frameBoundingRect;
        _objc_msgSend_stret(local_24,pvVar3,sel_frameBoundingRect);
        fVar8 = local_18 * 0.5 + local_20;
      }
      else {
        _objc_msgSend_stret(local_54,pvVar2,sel_frameBoundingRect);
        fVar7 = local_4c * 0.5 + local_54[0];
        puVar9 = sel_frameBoundingRect;
        _objc_msgSend_stret(local_34,pvVar3,sel_frameBoundingRect);
        fVar8 = local_2c * 0.5 + local_34[0];
      }
      if (1 < (int)pvVar4 - 1U) {
        local_68 = (int)pvVar4 + -2;
        uVar6 = 1;
        do {
          pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,uVar6,puVar9);
          pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterfaceForAllObjects_,&DAT_003619d4);
          pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
          op = sel_moveVerticalCenterTo_withLayoutGuidingContext_;
          if (spacingObjectsWithDirection != '\0') {
            op = sel_moveHorizontalCenterTo_withLayoutGuidingContext_;
          }
          puVar9 = (undefined *)0x0;
          _objc_msgSend(pvVar2,op,
                        (float)((double)((ulonglong)uVar6 | 0x4330000000000000) - 4503599627370496.0
                               ) *
                        ((fVar8 - fVar7) /
                        (float)((double)((ulonglong)((int)pvVar4 - 1U) | 0x4330000000000000) -
                               4503599627370496.0)) + fVar7,0);
          uVar6 = uVar6 + 1;
          local_68 = local_68 + -1;
        } while (local_68 != 0);
      }
    }
  }
  return;
}

*/
- (void)spacingObjectsWithDirection:(BOOL)aDirection
{
    NSArray *objects = [self selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray:NULL];
    if ([objects count] > 2) {
        [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Align Objects" value:@"" table:@"UndoManager"]];
        NSArray *sorted = [objects sortedArrayUsingFunction:(aDirection ? HSEditorSpacingCompareByOriginX : HSEditorSpacingCompareByOriginY) context:NULL];
        if (sorted != nil) {
            id first = [sorted objectAtIndex:0];
            id last = [sorted lastObject];
            NSUInteger count = [sorted count];
            float firstCenter;
            float lastCenter;
            if (!aDirection) {
                NSRect rect = [first frameBoundingRect];
                firstCenter = rect.size.height * 0.5f + rect.origin.y;
                rect = [last frameBoundingRect];
                lastCenter = rect.size.height * 0.5f + rect.origin.y;
            } else {
                NSRect rect = [first frameBoundingRect];
                firstCenter = rect.size.width * 0.5f + rect.origin.x;
                rect = [last frameBoundingRect];
                lastCenter = rect.size.width * 0.5f + rect.origin.x;
            }
            for (NSUInteger index = 1; index + 1 < count; index++) {
                id applier = [[[sorted objectAtIndex:index] queryHyperInterfaceForAllObjects:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
                float position = (float)index * ((lastCenter - firstCenter) / (float)(count - 1)) + firstCenter;
                if (aDirection) {
                    [applier moveHorizontalCenterTo:position withLayoutGuidingContext:nil];
                } else {
                    [applier moveVerticalCenterTo:position withLayoutGuidingContext:nil];
                }
            }
        }
    }
}

- (void)spacingObjectVertical:(id)aVertical
{
    [self spacingObjectsWithDirection:NO];
}

- (void)spacingObjectHorizontal:(id)aHorizontal
{
    [self spacingObjectsWithDirection:YES];
}

- (void)alignObjectBottom:(id)aBottom
{
    [self alignObjectWithDirection:5];
}

- (void)alignObjectMiddle:(id)aMiddle
{
    [self alignObjectWithDirection:4];
}

- (void)alignObjectTop:(id)aTop
{
    [self alignObjectWithDirection:3];
}

- (void)alignObjectCenter:(id)aCenter
{
    [self alignObjectWithDirection:1];
}

- (void)alignObjectRight:(id)aRight
{
    [self alignObjectWithDirection:2];
}

- (void)alignObjectLeft:(id)aLeft
{
    [self alignObjectWithDirection:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00025cb2 @ 00025cb2, 1306 bytes * /

void FUN_00025cb2(HSEditorWindowController *self,SEL _cmd,int alignObjectWithDirection)

{
  float fVar1;
  int iVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_01;
  SEL op;
  float extraout_EDX;
  undefined4 *puVar6;
  undefined *puVar7;
  float fVar8;
  int local_a4;
  id local_a0;
  float local_9c;
  float local_98;
  id local_94;
  float local_90;
  float local_8c;
  float local_88;
  id local_84;
  float local_80;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  
  puVar7 = PTR_00336078;
  puVar6 = (undefined4 *)&stack0xffffff34;
  local_78 = (id)0x0;
  fVar8 = *(float *)PTR_00336078;
  fVar1 = *(float *)(PTR_00336078 + 4);
  pvVar3 = _objc_msgSend(self,
                         sel_selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray_
                        );
  local_84 = *(id *)(puVar7 + 8);
  local_80 = *(float *)(puVar7 + 0xc);
  local_8c = fVar8;
  local_88 = fVar1;
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  pvVar5 = _objc_msgSend(local_78,sel_count);
  if (pvVar5 == pvVar4) {
    if (pvVar4 < (id)0x2) {
      pvVar4 = _objc_msgSend(self,sel_document);
      pvVar4 = _objc_msgSend(pvVar4,sel_currentCard);
      pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_);
      op = sel_size;
      if (pvVar4 == (id)0x0) {
        pvVar4 = _objc_msgSend(self,sel_document);
        pvVar4 = _objc_msgSend(pvVar4,sel_stack);
        op = sel_hyperCardSize;
      }
      local_84 = _objc_msgSend(pvVar4,op);
      local_8c = 0.0;
      local_88 = 0.0;
      local_80 = extraout_EDX;
    }
    else {
      _objc_msgSend_stret(&local_9c,self,sel_unionRectForArrayOfObjects_);
      puVar6 = (undefined4 *)&stack0xffffff30;
      local_8c = local_9c;
      local_88 = local_98;
      local_84 = local_94;
      local_80 = local_90;
    }
  }
  else {
    self_01 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self_00 = local_78;
    local_74 = 0;
    local_70 = 0;
    local_6c = (int *)0x0;
    local_68 = 0;
    local_64 = 0;
    local_60 = 0;
    local_5c = 0;
    local_58 = 0;
    local_a0 = _objc_msgSend(local_78,sel_countByEnumeratingWithState_objects_count_);
    if (local_a0 != (id)0x0) {
      local_a4 = (int)pvVar5 - (int)pvVar4;
      iVar2 = *local_6c;
      do {
        pvVar4 = (id)0x0;
        do {
          if (iVar2 != *local_6c) {
            _objc_enumerationMutation();
          }
          pvVar5 = (id)((int)pvVar4 + 1);
          pvVar4 = _objc_msgSend(*(id *)(local_70 + (int)pvVar4 * 4),sel_queryHyperInterface_);
          pvVar4 = _objc_msgSend(pvVar4,sel_isLocked);
          if ((char)pvVar4 != '\0') {
            _objc_msgSend(self_01,sel_addObject_);
            local_a4 = local_a4 + -1;
            if (local_a4 == 0) goto LAB_00025ef4;
          }
          pvVar4 = pvVar5;
        } while (pvVar5 < local_a0);
        local_a0 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_);
      } while (local_a0 != (id)0x0);
    }
LAB_00025ef4:
    _objc_msgSend_stret(&local_8c,self,sel_unionRectForArrayOfObjects_);
    puVar6 = (undefined4 *)&stack0xffffff30;
    _objc_msgSend(self_01,sel_release);
  }
  puVar6[1] = sel_document;
  *puVar6 = self;
  puVar6[-1] = 0x2605b;
  pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[1] = sel_undoManager;
  *puVar6 = pvVar4;
  puVar6[-1] = 0x2606d;
  pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[1] = sel_mainBundle;
  *puVar6 = cls_NSBundle;
  puVar6[-1] = 0x26087;
  pvVar5 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[4] = &cfstr_UndoManager;
  puVar6[3] = &cfstr_empty;
  puVar6[2] = &cfstr_Align_Object;
  puVar6[1] = sel_localizedStringForKey_value_table_;
  *puVar6 = pvVar5;
  puVar6[-1] = 0x260b7;
  pvVar5 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[2] = pvVar5;
  puVar6[1] = sel_setMultipleActionsName_;
  *puVar6 = pvVar4;
  puVar6[-1] = 0x260cd;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[2] = &DAT_003619d4;
  puVar6[1] = sel_queryHyperInterfaceForAllObjects_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x260ef;
  pvVar3 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[1] = sel_queryGeometryBehaviorApplier;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x26101;
  pvVar3 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  switch(alignObjectWithDirection) {
  case 0:
    puVar7 = sel_moveMinHorizontalFrameBoundTo_withLayoutGuidingContext_;
    fVar8 = local_8c;
    break;
  case 1:
    fVar8 = (float)local_84 * 0.5 + local_8c;
    puVar7 = sel_moveHorizontalCenterTo_withLayoutGuidingContext_;
    break;
  case 2:
    fVar8 = local_8c + (float)local_84;
    puVar7 = sel_moveMaxHorizontalFrameBoundTo_withLayoutGuidingContext_;
    break;
  case 3:
    puVar7 = sel_moveMinVerticalFrameBoundTo_withLayoutGuidingContext_;
    fVar8 = local_88;
    break;
  case 4:
    puVar7 = sel_moveVerticalCenterTo_withLayoutGuidingContext_;
    fVar8 = local_80 * 0.5 + local_88;
    break;
  case 5:
    puVar6[2] = local_88 + local_80;
    puVar6[1] = sel_moveMaxVerticalFrameBoundTo_withLayoutGuidingContext_;
    goto LAB_0002612d;
  default:
    goto switchD_00026113_default;
  }
  puVar6[2] = fVar8;
  puVar6[1] = puVar7;
LAB_0002612d:
  *puVar6 = pvVar3;
  puVar6[3] = 0;
  puVar6[-1] = 0x2613d;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
switchD_00026113_default:
  return;
}

*/
- (void)alignObjectWithDirection:(NSInteger)aDirection
{
    NSArray *originalObjects = nil;
    NSRect rect = NSZeroRect;
    id objects = [self selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray:&originalObjects];
    NSUInteger count = [objects count];
    if ([originalObjects count] == count) {
        if (count < 2) {
            id card = [[self document] currentCard];
            NSSize size;
            if ([card queryHyperInterface:@protocol(HSSizeAttributes)] != nil) {
                size = [card size];
            } else {
                size = [[[self document] stack] hyperCardSize];
            }
            rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
        } else {
            rect = [self unionRectForArrayOfObjects:objects];
        }
    } else {
        // Some of the selected objects are locked: align to those.
        NSMutableArray *lockedObjects = [NSMutableArray new];
        NSUInteger remaining = [originalObjects count] - count;
        for (id object in originalObjects) {
            if ([[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
                [lockedObjects addObject:object];
                if (--remaining == 0) {
                    break;
                }
            }
        }
        rect = [self unionRectForArrayOfObjects:lockedObjects];
        [lockedObjects release];
    }
    [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Align Object" value:@"" table:@"UndoManager"]];
    id applier = [[objects queryHyperInterfaceForAllObjects:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    switch (aDirection) {
        case 0:
            [applier moveMinHorizontalFrameBoundTo:rect.origin.x withLayoutGuidingContext:nil];
            break;
        case 1:
            [applier moveHorizontalCenterTo:rect.origin.x + rect.size.width * 0.5f withLayoutGuidingContext:nil];
            break;
        case 2:
            [applier moveMaxHorizontalFrameBoundTo:rect.origin.x + rect.size.width withLayoutGuidingContext:nil];
            break;
        case 3:
            [applier moveMinVerticalFrameBoundTo:rect.origin.y withLayoutGuidingContext:nil];
            break;
        case 4:
            [applier moveVerticalCenterTo:rect.origin.y + rect.size.height * 0.5f withLayoutGuidingContext:nil];
            break;
        case 5:
            [applier moveMaxVerticalFrameBoundTo:rect.origin.y + rect.size.height withLayoutGuidingContext:nil];
            break;
        default:
            break;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00017dfd @ 00017dfd, 323 bytes * /

void FUN_00017dfd(HSEditorWindowController *self,SEL _cmd,id alignJustified)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar4 = &DAT_00361934;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361934);
  op = sel_setHyperAlignment_;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,puVar4);
    puVar4 = &DAT_00361948;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
    if (pvVar1 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar4);
      pvVar3 = _objc_msgSend(pvVar2,sel_selectedToolTag);
      if (pvVar3 == (id)0x2) {
        pvVar1 = _objc_msgSend(pvVar2,sel_toolSettings,puVar4);
        pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
        pvVar1 = _objc_msgSend(pvVar1,sel_userObjectPrototypeForTool_,pvVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
      }
    }
    op = sel_setHyperTextAlignment_;
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  _objc_msgSend(pvVar1,op,3);
  return;
}

*/
- (void)alignJustified:(id)aJustified
{
    id target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    SEL action = @selector(setHyperAlignment:);
    if (target == nil) {
        target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
        if (target == nil) {
            HSToolManager *toolManager = [HSToolManager sharedToolManager];
            if ([toolManager selectedToolTag] == 2) {
                target = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSTextObjectAttributes)];
            }
        }
        action = @selector(setHyperTextAlignment:);
        if (target == nil) {
            return;
        }
    }
    [target performSelector:action withObject:(id)3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00017cba @ 00017cba, 323 bytes * /

void FUN_00017cba(HSEditorWindowController *self,SEL _cmd,id alignCenter)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar4 = &DAT_00361934;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361934);
  op = sel_setHyperAlignment_;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,puVar4);
    puVar4 = &DAT_00361948;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
    if (pvVar1 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar4);
      pvVar3 = _objc_msgSend(pvVar2,sel_selectedToolTag);
      if (pvVar3 == (id)0x2) {
        pvVar1 = _objc_msgSend(pvVar2,sel_toolSettings,puVar4);
        pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
        pvVar1 = _objc_msgSend(pvVar1,sel_userObjectPrototypeForTool_,pvVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
      }
    }
    op = sel_setHyperTextAlignment_;
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  _objc_msgSend(pvVar1,op,2);
  return;
}

*/
- (void)alignCenter:(id)aCenter
{
    id target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    SEL action = @selector(setHyperAlignment:);
    if (target == nil) {
        target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
        if (target == nil) {
            HSToolManager *toolManager = [HSToolManager sharedToolManager];
            if ([toolManager selectedToolTag] == 2) {
                target = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSTextObjectAttributes)];
            }
        }
        action = @selector(setHyperTextAlignment:);
        if (target == nil) {
            return;
        }
    }
    [target performSelector:action withObject:(id)2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00017b77 @ 00017b77, 323 bytes * /

void FUN_00017b77(HSEditorWindowController *self,SEL _cmd,id alignLeft)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar4 = &DAT_00361934;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361934);
  op = sel_setHyperAlignment_;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,puVar4);
    puVar4 = &DAT_00361948;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
    if (pvVar1 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar4);
      pvVar3 = _objc_msgSend(pvVar2,sel_selectedToolTag);
      if (pvVar3 == (id)0x2) {
        pvVar1 = _objc_msgSend(pvVar2,sel_toolSettings,puVar4);
        pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
        pvVar1 = _objc_msgSend(pvVar1,sel_userObjectPrototypeForTool_,pvVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
      }
    }
    op = sel_setHyperTextAlignment_;
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  _objc_msgSend(pvVar1,op,0);
  return;
}

*/
- (void)alignLeft:(id)aLeft
{
    id target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    SEL action = @selector(setHyperAlignment:);
    if (target == nil) {
        target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
        if (target == nil) {
            HSToolManager *toolManager = [HSToolManager sharedToolManager];
            if ([toolManager selectedToolTag] == 2) {
                target = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSTextObjectAttributes)];
            }
        }
        action = @selector(setHyperTextAlignment:);
        if (target == nil) {
            return;
        }
    }
    [target performSelector:action withObject:(id)0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00017a34 @ 00017a34, 323 bytes * /

void FUN_00017a34(HSEditorWindowController *self,SEL _cmd,id alignRight)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  puVar4 = &DAT_00361934;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361934);
  op = sel_setHyperAlignment_;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selectedHyperObject,puVar4);
    puVar4 = &DAT_00361948;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
    if (pvVar1 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar4);
      pvVar3 = _objc_msgSend(pvVar2,sel_selectedToolTag);
      if (pvVar3 == (id)0x2) {
        pvVar1 = _objc_msgSend(pvVar2,sel_toolSettings,puVar4);
        pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
        pvVar1 = _objc_msgSend(pvVar1,sel_userObjectPrototypeForTool_,pvVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361948);
      }
    }
    op = sel_setHyperTextAlignment_;
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  _objc_msgSend(pvVar1,op,1);
  return;
}

*/
- (void)alignRight:(id)aRight
{
    id target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    SEL action = @selector(setHyperAlignment:);
    if (target == nil) {
        target = [[self selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
        if (target == nil) {
            HSToolManager *toolManager = [HSToolManager sharedToolManager];
            if ([toolManager selectedToolTag] == 2) {
                target = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSTextObjectAttributes)];
            }
        }
        action = @selector(setHyperTextAlignment:);
        if (target == nil) {
            return;
        }
    }
    [target performSelector:action withObject:(id)1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000179af @ 000179af, 133 bytes * /

id FUN_000179af(HSEditorWindowController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_selectedObjectsForEditingOperationWithImplicitVerification);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  op = sel_lastObject;
  if ((id)0x1 < pvVar2) {
    op = sel_hyperObjectForAllInterfaces;
  }
  pvVar2 = _objc_msgSend(pvVar1,op);
  pvVar3 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_003612cc);
  pvVar1 = (id)0x0;
  if ((char)pvVar3 != '\0') {
    pvVar1 = pvVar2;
  }
  return pvVar1;
}

*/
- (id)selectedCardObjectForEditingOperationWithImplicitVerification
{
    id objects = [self selectedObjectsForEditingOperationWithImplicitVerification];
    id object = ([objects count] > 1) ? [objects hyperObjectForAllInterfaces] : [objects lastObject];
    return [object implementsHyperInterface:@protocol(HSCardObjectAttributes)] ? object : nil;
}

- (id)selectedObjectsForEditingOperationWithImplicitVerification
{
    return [self selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001785c @ 0001785c, 293 bytes * /

id FUN_0001785c(HSEditorWindowController *self,SEL _cmd,
               id *selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_cardView);
  pvVar2 = _objc_msgSend(pvVar2,sel_editorSelection);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  puVar3 = (undefined *)0x1;
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForEditingOperationWithImplicitCheck_,1);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    puVar3 = &DAT_003617a4;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryAllHyperInterfaces_,&DAT_003617a4);
  }
  if (selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray != (id *)0x0) {
    pvVar2 = _objc_msgSend(self->_cardView,sel_selection,puVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectsArray);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryAllHyperInterfaces_,&DAT_003617a4);
    *selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray = pvVar2;
  }
  return pvVar1;
}

*/
- (id)selectedObjectsForEditingOperationWithImplicitVerificationOfOriginalArray:(id *)aArray
{
    id verifier = [[[HSSelectionOperationVerifier alloc] initWithSelection:[[self cardView] editorSelection]] autorelease];
    id nodes = [verifier selectedNodesArrayForEditingOperationWithImplicitCheck:YES];
    id result = ([nodes count] == 0) ? nil : [nodes queryAllHyperInterfaces:@protocol(HSGeometryAttributes)];
    if (aArray != NULL) {
        *aArray = [[[_cardView selection] objectsArray] queryAllHyperInterfaces:@protocol(HSGeometryAttributes)];
    }
    return result;
}

- (void)unlockGeometry:(id)aGeometry
{
    [[[self selectedHyperObject] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setLocked:NO];
}

- (void)lockGeometry:(id)aGeometry
{
    [[[self selectedHyperObject] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setLocked:YES];
}

- (void)toggleLockGeometry:(id)aGeometry
{
    BOOL pvVar1_6;

    [[self cardView] saveEditingState];
    [[self cardView] deactivateRunTimeEditor];
    pvVar1_6 = [[[[_cardView selection] selectedObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
    [[[self selectedHyperObject] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setLocked:(unsigned int)(!pvVar1_6)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00017609 @ 00017609, 146 bytes * /

void FUN_00017609(HSEditorWindowController *self,SEL _cmd,id runEasyLinkDialog)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSEasyLinkDialogController,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_editObjectDialogContext);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithContext_,pvVar2);
  _objc_msgSend(pvVar1,sel_runModal);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)runEasyLinkDialog:(id)aDialog
{
    id controller = [[HSEasyLinkDialogController alloc] initWithContext:[[self document] editObjectDialogContext]];
    [controller runModal];
    [controller release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000173fa @ 000173fa, 527 bytes * /

void FUN_000173fa(HSEditorWindowController *self,SEL _cmd,id runHypertextLinksDialog)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  id pvVar3;
  cfstringStruct *pcVar4;
  undefined4 extraout_EDX;
  SEL op;
  undefined *puVar5;
  
  puVar5 = (undefined *)0x1;
  _objc_msgSend(self,sel_switchToToolWithTag_,1);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selection);
  pvVar2 = _objc_msgSend(pvVar1,sel_nodesEnumerator);
  self_00 = _objc_msgSend(pvVar2,sel_nextObject);
  while (self_00 != (undefined *)0x0) {
    puVar5 = &DAT_003616b4;
    pvVar3 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_003616b4);
    if ((char)pvVar3 == '\0') {
      _objc_msgSend(pvVar1,sel_removeNode_,self_00);
      puVar5 = self_00;
    }
    self_00 = _objc_msgSend(pvVar2,sel_nextObject,puVar5);
  }
  pvVar1 = _objc_msgSend(self,sel_cardView,puVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_runTimeEditorController);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRunTimeEditorObject);
  if (pvVar1 != (id)0x0) {
    puVar5 = &DAT_003616c8;
    pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003616c8);
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_editingObject,puVar5);
      puVar5 = &DAT_0036177c;
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036177c);
      op = sel_objectString;
    }
    else {
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperText,puVar5);
      op = sel_string;
    }
    pvVar2 = _objc_msgSend(pvVar2,op,puVar5);
    puVar5 = sel_hyperSelectedRange;
    pvVar3 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_hyperSelectedRange);
    if ((char)pvVar3 != '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperSelectedRange,puVar5);
      pcVar4 = _objc_msgSend(pvVar2,sel_substringWithRange_,pvVar1,extraout_EDX);
      goto LAB_000175e8;
    }
  }
  pcVar4 = &cfstr_empty;
LAB_000175e8:
  _objc_msgSend(self,sel_openHypertextLinksPane_,pcVar4);
  return;
}

*/
- (void)runHypertextLinksDialog:(id)aDialog
{
    [self switchToToolWithTag:1];
    id selection = [[self cardView] selection];
    NSEnumerator *enumerator = [selection nodesEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil) {
        if (![node implementsHyperInterface:@protocol(HSHypertextLinkContainerAttributes)]) {
            [selection removeNode:node];
        }
    }
    NSString *text = @"";
    id editor = [[[self cardView] runTimeEditorController] selectedRunTimeEditorObject];
    if (editor != nil) {
        NSString *string;
        id textAttributes = [editor queryHyperInterface:@protocol(HSTextAttributes)];
        if (textAttributes == nil) {
            string = [[[editor editingObject] queryHyperInterface:@protocol(HSGenericObjectStringAttribute)] objectString];
        } else {
            string = [[textAttributes hyperText] string];
        }
        if ([editor respondsToSelector:@selector(hyperSelectedRange)]) {
            text = [string substringWithRange:[editor hyperSelectedRange]];
        }
    }
    [self openHypertextLinksPane:text];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00017314 @ 00017314, 230 bytes * /

void FUN_00017314(HSEditorWindowController *self,SEL _cmd,id openHypertextLinksPane)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
  pvVar1 = pvVar2;
  op = sel_hyperObject;
  if (pvVar2 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_document);
    op = sel_currentCard;
  }
  pvVar1 = _objc_msgSend(pvVar1,op);
  self_00 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar3 = _objc_msgSend(self,sel_document);
  pvVar3 = _objc_msgSend(pvVar3,sel_stack);
  _objc_msgSend(self_00,sel_openHypertextLinksPaneForField_selectedObject_initialText_stack_,pvVar2,
                pvVar1,openHypertextLinksPane,pvVar3);
  return;
}

*/
- (void)openHypertextLinksPane:(id)aPane
{
    id selected = [[self document] selectedHyperObject];
    id object = (selected != nil) ? [selected hyperObject] : [[self document] currentCard];
    [[HSObjectAssistantController sharedAssistantController] openHypertextLinksPaneForField:selected selectedObject:object initialText:aPane stack:[[self document] stack]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000261e4 @ 000261e4, 364 bytes * /

void FUN_000261e4(HSEditorWindowController *self,SEL _cmd,id runWebcamWorkshopPanel)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  
  dVar4 = _objc_msgSend_fpret(cls_HSWebCamDataProvider,sel_safariApplicationVersion);
  if ((float)dVar4 < 3.0) {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_You_must_have_Safari_3_0_or_later_installed_to_v,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Cannot_show_webcams,
                           &cfstr_empty,&cfstr_Alerts);
    _NSRunAlertPanel(pvVar3,pvVar2,pvVar1,0,0);
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_webcamWorkshopController);
    _objc_msgSend(pvVar1,sel_runModal);
  }
  return;
}

*/
- (void)runWebcamWorkshopPanel:(id)aPanel
{
    if ([HSWebCamDataProvider safariApplicationVersion] < 3.0f) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSRunAlertPanel([provider localizedStringForKey:@"Cannot show webcams" value:@"" table:@"Alerts"],
                        [provider localizedStringForKey:@"You must have Safari 3.0 or later installed to view webcams. Update your Safari and try again." value:@"" table:@"Alerts"],
                        [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"], nil, nil);
    } else {
        [[self webcamWorkshopController] runModal];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001718d @ 0001718d, 391 bytes * /

void FUN_0001718d(HSEditorWindowController *self,SEL _cmd,id captureImageController,
                 uint didEndWithReturnCode)

{
  id pvVar1;
  id self_00;
  HSEditorWindowController *pHVar2;
  SEL op;
  HSEditorWindowController *pHVar3;
  
  if (didEndWithReturnCode == 1) {
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,
                           sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
    if ((char)pvVar1 == '\0') goto LAB_0001728e;
    pvVar1 = _objc_msgSend(captureImageController,sel_capturedImage);
    self_00 = _objc_msgSend(cls_HSImageObject,sel_alloc);
    pvVar1 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithImage_,pvVar1);
    pHVar2 = _objc_msgSend(self_00,sel_initWithMedia_,pvVar1);
    pvVar1 = _objc_msgSend(self,sel_cardView);
    pHVar3 = pHVar2;
    _objc_msgSend(pvVar1,sel_addObjectToCenter_useDragPreferences_,pHVar2,0);
    _objc_msgSend(self,sel_didAddNewObject);
    self = pHVar2;
    op = sel_release;
  }
  else {
LAB_0001728e:
    pvVar1 = _objc_msgSend(self->_importGraphicObjectDialogController,sel_dialogUserOptions);
    pHVar3 = *(HSEditorWindowController **)PTR_PTR_003360a0;
    pvVar1 = _objc_msgSend(pvVar1,sel_valueForKey_,pHVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    if ((char)pvVar1 == '\0') goto LAB_000172f7;
    pHVar3 = (HSEditorWindowController *)0x0;
    op = sel_addGraphicObject_;
  }
  _objc_msgSend(self,op,pHVar3);
LAB_000172f7:
  _objc_msgSend(captureImageController,sel_autorelease,pHVar3);
  return;
}

*/
- (void)captureImageController:(id)aController didEndWithReturnCode:(NSUInteger)aCode
{
    BOOL handled = NO;
    if (aCode == 1 && [[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
        HSImageObject *object = [[HSImageObject alloc] initWithMedia:[HSNewMedia mediaWithImage:[aController capturedImage]]];
        [[self cardView] addObjectToCenter:object useDragPreferences:NO];
        [self didAddNewObject];
        [object release];
        handled = YES;
    }
    if (!handled && [[[_importGraphicObjectDialogController dialogUserOptions] valueForKey:@"HSCaptureImageKey"] boolValue]) {
        [self addGraphicObject:nil];
    }
    [aController autorelease];
}

- (void)captureImage:(id)aImage
{
    [[HSCaptureImageController new] runForWindow:[[self document] windowForSheet] delegate:self didEndSelector:@selector(captureImageController:didEndWithReturnCode:)];
}

- (void)quickCaptureImageController:(id)aController didProduceImage:(id)aImage
{
    id pvVar1_4;

    if (aImage != nil) {
        if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
            if (_didRequestBackground == NO) {
                pvVar1_4 = [[HSImageObject alloc] initWithMedia:[HSNewMedia mediaWithImage:aImage]];
                [[self cardView] addObjectToCenter:pvVar1_4 useDragPreferences:NO];
                [self didAddNewObject];
                [pvVar1_4 release];
            }
            else {
                [[[self document] currentCard] importBackgroundFromImage:aImage imageScalingOption:4 eraseBackground:YES];
                _didRequestBackground = NO;
            }
        }
    }
}

- (void)addQuickShotBackground:(id)aBackground
{
    if ([[HSQuickCaptureImageController sharedQuickCaptureImageController] requestImageFor:self]) {
        _didRequestBackground = YES;
    }
}

- (void)addQuickShotGraphicObject:(id)aObject
{
    [[HSQuickCaptureImageController sharedQuickCaptureImageController] requestImageFor:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00016ec9 @ 00016ec9, 82 bytes * /

void FUN_00016ec9(HSEditorWindowController *self,SEL _cmd,id runVideoRecordingPanel)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_videoRecordingController);
  pvVar1 = _objc_msgSend(pvVar1,sel_runModal);
  _objc_msgSend(self,sel_videoRecordingDidEndWithCode_,pvVar1);
  return;
}

*/
- (void)runVideoRecordingPanel:(id)aPanel
{
    [self videoRecordingDidEndWithCode:[[self videoRecordingController] runModal]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00016e2f @ 00016e2f, 154 bytes * /

void FUN_00016e2f(HSEditorWindowController *self,SEL _cmd,id runSoundRecordingPanel)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_soundRecordingController);
  pvVar1 = _objc_msgSend(pvVar1,sel_runModal);
  if (self->_playSoundActionEvent == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_playSoundActionEvent = pvVar2;
  }
  _objc_msgSend(self,sel_soundRecordingDidEndWithCode_,pvVar1);
  return;
}

*/
- (void)runSoundRecordingPanel:(id)aPanel
{
    id code = (id)[[self soundRecordingController] runModal];
    if (_playSoundActionEvent == nil) {
        _playSoundActionEvent = [[HSActionEvent actionEventOfType:kHSArriveActionEventType] retain];
    }
    [self soundRecordingDidEndWithCode:(NSInteger)code];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00026350 @ 00026350, 272 bytes * /

void FUN_00026350(HSEditorWindowController *self,SEL _cmd,id zoomFactorDidChange)

{
  float fVar1;
  longdouble lVar2;
  float fVar3;
  float fVar4;
  double dVar5;
  float fVar6;
  
  dVar5 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_zoomFactorValueFrom_,
                              zoomFactorDidChange);
  fVar6 = (float)dVar5;
  dVar5 = _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
  fVar1 = (float)dVar5;
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar3 = ABS(fVar6);
  }
  else {
    fVar3 = 1.0;
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar4 = ABS(fVar1);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= fVar3) {
    fVar4 = fVar3;
  }
  if (ABS(fVar6 - fVar1) <= fVar4 * 0.0005) {
    lVar2 = (longdouble)_HSLinearValueForSliderFromNonLinear(zoomFactorDidChange,fVar1);
    fVar6 = (float)lVar2;
    _objc_msgSend(zoomFactorDidChange,sel_setFloatValue_,fVar6);
  }
  else {
    _objc_msgSend(self->_cardView,sel_zoomToFactor_,fVar6);
  }
  _objc_msgSend(self,sel_refreshToolManager,fVar6);
  return;
}

*/
- (void)zoomFactorDidChange:(id)aChange
{
    float target = [HSEditorZoomController zoomFactorValueFrom:aChange];
    float current = [_cardView zoomFactor];
    float magnitude = MAX((target != 0.0f || isnan(target)) ? fabsf(target) : 1.0f, (current != 0.0f || isnan(current)) ? fabsf(current) : 1.0f);
    if (fabsf(target - current) <= magnitude * 0.0005f) {
        target = HSLinearValueForSliderFromNonLinear(aChange, current);
        [aChange setFloatValue:target];
    } else {
        [_cardView zoomToFactor:target];
    }
    [self refreshToolManager];
}

- (void)zoomToMaxScaleFactor:(id)aFactor
{
    [_cardView zoomToFactor:(float)[HSEditorZoomController maxZoomFactor]];
}

- (void)zoomToMinScaleFactor:(id)aFactor
{
    [_cardView zoomToFactor:(float)[HSEditorZoomController minZoomFactor]];
}

- (void)fitInWindow:(id)aWindow
{
    [_cardView fitInWindow];
}

- (void)zoomToActualSize:(id)aSize
{
    [_cardView zoomToActualSize];
}

- (void)zoomOut:(id)aOut
{
    [_cardView zoomOut];
}

- (void)zoomIn:(id)aIn
{
    [_cardView zoomIn];
}

- (void)sendToBack:(id)aBack
{
    id pvVar1_2;

    pvVar1_2 = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeAttributes)];
    [pvVar1_2 sortHyperInterfacesUsingSelector:@selector(compareWeightBack:)];
    [pvVar1_2 moveToHyperBegin];
}

- (void)sendBackward:(id)aBackward
{
    id pvVar1_2;

    pvVar1_2 = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeAttributes)];
    [pvVar1_2 sortHyperInterfacesUsingSelector:@selector(compareWeight:)];
    [pvVar1_2 decrementHyperIndex];
}

- (void)bringToFront:(id)aFront
{
    id pvVar1_2;

    pvVar1_2 = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeAttributes)];
    [pvVar1_2 sortHyperInterfacesUsingSelector:@selector(compareWeight:)];
    [pvVar1_2 moveToHyperEnd];
}

- (void)bringForward:(id)aForward
{
    id pvVar1_2;

    pvVar1_2 = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeAttributes)];
    [pvVar1_2 sortHyperInterfacesUsingSelector:@selector(compareWeightBack:)];
    [pvVar1_2 incrementHyperIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00016add @ 00016add, 214 bytes * /

void FUN_00016add(HSEditorWindowController *self,SEL _cmd,id goToCard)

{
  undefined *puVar1;
  id pvVar2;
  SEL op;
  id pvVar3;
  undefined **ppuVar4;
  
  pvVar2 = _objc_msgSend(goToCard,sel_clickedCell);
  op = sel_keyCell;
  if (pvVar2 != (id)0x0) {
    op = sel_clickedCell;
  }
  pvVar2 = _objc_msgSend(goToCard,op);
  if ((pvVar2 != (id)0x0) && (pvVar3 = _objc_msgSend(pvVar2,sel_isEnabled), (char)pvVar3 != '\0')) {
    pvVar2 = _objc_msgSend(pvVar2,sel_tag);
    if (pvVar2 == (id)0x1) {
      ppuVar4 = &sel_goToNextCard_;
    }
    else {
      if (pvVar2 != (id)0x0) goto LAB_00016b96;
      ppuVar4 = &sel_goToPreviousCard_;
    }
    puVar1 = *ppuVar4;
    if (puVar1 != (undefined *)0x0) {
      pvVar2 = _objc_msgSend(goToCard,sel_target);
      _objc_msgSend(goToCard,sel_sendAction_to_,puVar1,pvVar2);
    }
  }
LAB_00016b96:
  _objc_msgSend(self,sel_validateStackNavigationControl);
  return;
}

*/
- (void)goToCard:(id)aCard
{
    id cell = [aCard clickedCell] != nil ? [aCard clickedCell] : [aCard keyCell];
    if (cell != nil && [cell isEnabled]) {
        SEL action = NULL;
        if ([cell tag] == 1) {
            action = @selector(goToNextCard:);
        } else if ([cell tag] == 0) {
            action = @selector(goToPreviousCard:);
        }
        if (action != NULL) {
            [aCard sendAction:action to:[aCard target]];
        }
    }
    [self validateStackNavigationControl];
}

- (void)toolPaletteSwitchToolTypes:(id)aTypes
{

}

- (void)selectAllArea:(id)aArea
{
    NSInteger pvVar1;
    HSEditorWindowController *self_00;

    pvVar1 = [aArea tag];
    [self switchToToolWithTag:pvVar1];
    if ([[HSToolManager sharedToolManager] selectedToolTag] == pvVar1) {
        self_00 = [NSApp targetForAction:@selector(selectAllArea:)];
        if (self_00 == self) {
            self_00 = [self cardView];
        }
        if ([self_00 respondsToSelector:@selector(selectAllArea:)]) {
            [self_00 performSelector:@selector(selectAllArea:) withObject:aArea];
        }
    }
}

- (void)switchTool:(id)aTool
{
    [self switchToToolWithTag:[aTool tag]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00016747 @ 00016747, 564 bytes * /

void FUN_00016747(HSEditorWindowController *self,SEL _cmd,int switchToToolWithTag)

{
  id pvVar1;
  undefined *puVar2;
  
  switch(switchToToolWithTag) {
  case 0x19:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_0036159c;
    break;
  case 0x1a:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_003615d8;
    break;
  case 0x1b:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_003615ec;
    break;
  case 0x1c:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_00361600;
    break;
  case 0x1d:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_00361614;
    break;
  case 0x1e:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_00361628;
    break;
  case 0x1f:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_0036163c;
    break;
  case 0x20:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_00361650;
    break;
  case 0x21:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_00361664;
    break;
  case 0x22:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_00361678;
    break;
  case 0x23:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_0036168c;
    break;
  default:
    pvVar1 = _objc_msgSend(self,sel_cardView);
    puVar2 = &DAT_003615b0;
  }
  _objc_msgSend(pvVar1,sel_setHitTestingInterface_,puVar2);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(pvVar1,sel_selectToolWithTag_setAsPermanent_,switchToToolWithTag,1);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_updateCursor);
  return;
}

*/
- (void)switchToToolWithTag:(NSInteger)aTag
{
    Protocol *hitTesting;
    switch (aTag) {
        case 0x19: hitTesting = @protocol(HSVectorGraphicObjectHitTesting); break;
        case 0x1a: hitTesting = @protocol(HSTextObjectHitTesting); break;
        case 0x1b: hitTesting = @protocol(HSButtonObjectHitTesting); break;
        case 0x1c: hitTesting = @protocol(HSEffectObjectHitTesting); break;
        case 0x1d: hitTesting = @protocol(HSMovieObjectHitTesting); break;
        case 0x1e: hitTesting = @protocol(HSImageObjectHitTesting); break;
        case 0x1f: hitTesting = @protocol(HSTextViewObjectHitTesting); break;
        case 0x20: hitTesting = @protocol(HSCameraObjectHitTesting); break;
        case 0x21: hitTesting = @protocol(HSWebObjectHitTesting); break;
        case 0x22: hitTesting = @protocol(HSImageWellObjectHitTesting); break;
        case 0x23: hitTesting = @protocol(HSGroupBoxObjectHitTesting); break;
        default: hitTesting = @protocol(HSUserObjectEditorHitTesting); break;
    }
    [[self cardView] setHitTestingInterface:hitTesting];
    [[HSToolManager sharedToolManager] selectToolWithTag:aTag setAsPermanent:YES];
    [[self cardView] updateCursor];
}

- (void)deleteSelectedCardObjects:(id)aObjects
{
    [self switchToToolWithTag:1];
    [[self cardView] performSelector:_cmd withObject:aObjects];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001664c @ 0001664c, 151 bytes * /

void FUN_0001664c(HSEditorWindowController *self,SEL _cmd,id delete)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedCardObject);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_canDeleteSelectedObjectInSelectionHolder_,0);
    if ((char)pvVar1 == '\0') {
      return;
    }
    _cmd = (SEL)0x0;
    op = sel_deleteSelectedObjectInSelectionHolder_;
  }
  else {
    self = _objc_msgSend(self,sel_cardView);
    op = sel_performSelector_withObject_;
  }
  _objc_msgSend(self,op,_cmd);
  return;
}

*/
- (void)delete:(id)aDelete
{
    if ([self selectedCardObject] != nil) {
        [[self cardView] performSelector:@selector(delete:) withObject:aDelete];
    } else if ([self canDeleteSelectedObjectInSelectionHolder:nil]) {
        [self deleteSelectedObjectInSelectionHolder:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00016597 @ 00016597, 181 bytes * /

void FUN_00016597(HSEditorWindowController *self,SEL _cmd,id cut)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedCardObject);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_canDeleteSelectedObjectInSelectionHolder_,0);
    if ((char)pvVar1 == '\0') {
      return;
    }
    _objc_msgSend(self,sel_copy_,cut);
    cut = (id)0x0;
    _cmd = (SEL)0x0;
    op = sel_deleteSelectedObjectInSelectionHolder_showAlert_;
  }
  else {
    self = _objc_msgSend(self,sel_cardView);
    op = sel_performSelector_withObject_;
  }
  _objc_msgSend(self,op,_cmd,cut);
  return;
}

*/
- (void)cut:(id)aCut
{
    if ([self selectedCardObject] != nil) {
        [[self cardView] performSelector:@selector(cut:) withObject:aCut];
    } else if ([self canDeleteSelectedObjectInSelectionHolder:nil]) {
        [self copy:aCut];
        [self deleteSelectedObjectInSelectionHolder:nil showAlert:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00016181 @ 00016181, 1046 bytes * /

void FUN_00016181(HSEditorWindowController *self,SEL _cmd,id paste)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSEditorWindowController *self_01;
  id pvVar4;
  undefined *puVar5;
  int iVar6;
  HSEditorWindowController *self_02;
  SEL pcVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  
  self_00 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(cls_HSMediaLoader,sel_forceLoadMediasFromPasteboard_,self_00);
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
  pvVar3 = _objc_msgSend(self_00,sel_availableTypeFromArray_,pvVar2);
  if (pvVar3 == (id)0x0) {
    puVar5 = sel_paste_;
    pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_paste_);
    if ((char)pvVar2 != '\0') {
      puVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_BTArchivedImageRegionPboardType
                            );
      pvVar2 = _objc_msgSend(self_00,sel_availableTypeFromArray_,puVar5);
      pcVar7 = sel_paste_;
      if (pvVar2 != (id)0x0) goto LAB_00016487;
    }
    pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar5);
    pvVar2 = self_00;
    pvVar3 = _objc_msgSend(pvVar3,sel_toolForPastingPasteboardContents_,self_00);
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar2);
      _objc_msgSend(pvVar2,sel_selectToolWithTag_,pvVar3);
      pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_paste_);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,
                               &cfstr_BTArchivedImageRegionPboardType);
        pvVar2 = _objc_msgSend(self_00,sel_availableTypeFromArray_,pvVar2);
        pcVar7 = sel_paste_;
        if (pvVar2 != (id)0x0) goto LAB_00016487;
      }
    }
    pvVar2 = _objc_msgSend(pvVar1,sel_canRecieveDataFromPasteboard_,self_00);
    pcVar7 = sel_readSelectionFromPasteboard_;
    paste = self_00;
    if ((char)pvVar2 == '\0') {
      return;
    }
  }
  else {
    self_01 = _objc_msgSend(self,sel_stackView,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    puVar5 = sel_selectedCard;
    pvVar3 = _objc_msgSend(self_01,sel_respondsToSelector_,sel_selectedCard);
    self_02 = self;
    pcVar7 = sel_selectedCard;
    if ((char)pvVar3 != '\0') {
      self_02 = self_01;
      pcVar7 = sel_performSelector_;
      puVar5 = sel_selectedCard;
    }
    pvVar3 = _objc_msgSend(self_02,pcVar7,puVar5);
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar9 = &cfstr_UndoManager;
    pcVar8 = &cfstr_empty;
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Paste,&cfstr_empty,
                           &cfstr_UndoManager);
    _objc_msgSend(pvVar1,sel_setMultipleActionsName_,pvVar4);
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_isNewAndNotChanged);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(pvVar2,sel_indexOfHyperChild_,pvVar3,pcVar8,pcVar9);
    }
    else {
      _objc_msgSend(pvVar2,sel_removeHyperAllChildren,pvVar4,pcVar8,pcVar9);
      pvVar1 = (id)0x7fffffff;
      pvVar3 = pvVar4;
    }
    pvVar4 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,pvVar3);
    iVar6 = (int)pvVar1 + 1;
    if (pvVar1 == (id)0x7fffffff) {
      iVar6 = 0;
    }
    _objc_msgSend(pvVar4,sel_disableObjectRegistration,pvVar3);
    _objc_msgSend(pvVar2,sel_insertCardsFromPasteboard_atIndex_,self_00,iVar6);
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pcVar7 = sel_enableObjectRegistration;
    paste = self_00;
  }
LAB_00016487:
  _objc_msgSend(pvVar1,pcVar7,paste);
  return;
}

*/
- (void)paste:(id)aPaste
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    id cardView = [self cardView];
    [HSMediaLoader forceLoadMediasFromPasteboard:pasteboard];
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] == nil) {
        if ([cardView respondsToSelector:@selector(paste:)]
            && [pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"BTArchivedImageRegionPboardType"]] != nil) {
            [cardView paste:aPaste];
            return;
        }
        NSInteger toolTag = [[HSToolManager sharedToolManager] toolForPastingPasteboardContents:pasteboard];
        if (toolTag != 0) {
            [[HSToolManager sharedToolManager] selectToolWithTag:toolTag];
            if ([cardView respondsToSelector:@selector(paste:)]
                && [pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"BTArchivedImageRegionPboardType"]] != nil) {
                [cardView paste:aPaste];
                return;
            }
        }
        if (![cardView canRecieveDataFromPasteboard:pasteboard]) {
            return;
        }
        [cardView readSelectionFromPasteboard:pasteboard];
        return;
    }
    id stackView = [self stackView];
    id stack = [[self document] stack];
    id selectedCard = [stackView respondsToSelector:@selector(selectedCard)] ? [stackView selectedCard] : [self selectedCard];
    [[[self document] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Paste" value:@"" table:@"UndoManager"]];
    NSUInteger index;
    if ([[self document] isNewAndNotChanged]) {
        [stack removeHyperAllChildren];
        index = 0x7fffffff;
    } else {
        index = [stack indexOfHyperChild:selectedCard];
    }
    NSUInteger insertionIndex = (index == 0x7fffffff) ? 0 : index + 1;
    [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
    [stack insertCardsFromPasteboard:pasteboard atIndex:insertionIndex];
    [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00015dea @ 00015dea, 919 bytes * /

void FUN_00015dea(HSEditorWindowController *self,SEL _cmd,id copy)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_01;
  id self_02;
  id self_03;
  undefined4 extraout_EDX;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedCardObject);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selectedCards);
    pvVar2 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar2 == (id)0x0) {
      return;
    }
    pvVar3 = _objc_msgSend(pvVar1,sel_extraFirstObject);
    pvVar2 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003614fc);
    pvVar2 = _objc_msgSend(pvVar2,sel_size);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00361560);
    pvVar3 = _objc_msgSend(pvVar3,sel_imageOfSize_,pvVar2,extraout_EDX);
    copy = _objc_msgSend(cls_NSMutableSet,sel_set);
    self_01 = _objc_msgSend(cls_NSMutableSet,sel_set);
    self_02 = _objc_msgSend(cls_NSMutableArray,sel_array);
    self_03 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(self_03,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361574);
      pvVar2 = _objc_msgSend(pvVar2,sel_mediaUIDs);
      _objc_msgSend(copy,sel_unionSet_,pvVar2);
      pvVar2 = _objc_msgSend(pvVar1,sel_fullDictionaryRepresentation);
      _objc_msgSend(self_02,sel_addObject_,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00361588);
      pvVar2 = _objc_msgSend(pvVar1,sel_unrefreshingUIDs);
      _objc_msgSend(self_01,sel_unionSet_,pvVar2);
      pvVar1 = _objc_msgSend(self_03,sel_nextObject);
    }
    pvVar1 = _objc_msgSend(copy,sel_count,pvVar2);
    if ((pvVar1 == (id)0x0) && (pvVar1 = _objc_msgSend(self_02,sel_count,pvVar2), pvVar1 == (id)0x0)
       ) {
      return;
    }
    self_00 = cls_HSPasteboardDataProvider;
    pvVar1 = _objc_msgSend(self,sel_zone);
    pvVar1 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_cardGroupController);
    pvVar2 = _objc_msgSend(pvVar2,sel_allGroupedObjectsUIDs);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithCards_UIDs_groupUIDs_unrefreshingUIDs_cardImage_,
                           self_02,copy,pvVar2,self_01,pvVar3);
    _cmd = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
    _objc_msgSend(pvVar1,sel_declareTypesForPasteboard_,_cmd);
    op = sel_release;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_cardView);
    op = sel_performSelector_withObject_;
  }
  _objc_msgSend(pvVar1,op,_cmd,copy);
  return;
}

*/
- (void)copy:(id)aCopy
{
    if ([self selectedCardObject] != nil) {
        [[self cardView] performSelector:@selector(copy:) withObject:aCopy];
        return;
    }
    id cards = [self selectedCards];
    if ([cards count] == 0) {
        return;
    }
    id firstCard = [cards extraFirstObject];
    NSSize cardSize = [[firstCard queryHyperInterface:@protocol(HSSizeAttributes)] size];
    id cardImage = [[firstCard queryHyperInterface:@protocol(HSUserObjectImageProvider)] imageOfSize:cardSize];
    NSMutableSet *mediaUIDs = [NSMutableSet set];
    NSMutableSet *unrefreshingUIDs = [NSMutableSet set];
    NSMutableArray *cardDictionaries = [NSMutableArray array];
    NSEnumerator *enumerator = [cards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        [mediaUIDs unionSet:[[card queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs]];
        [cardDictionaries addObject:[card fullDictionaryRepresentation]];
        [unrefreshingUIDs unionSet:[[card queryHyperInterface:@protocol(HSActionCopySupport)] unrefreshingUIDs]];
    }
    if ([mediaUIDs count] == 0 && [cardDictionaries count] == 0) {
        return;
    }
    HSPasteboardDataProvider *provider = [[HSPasteboardDataProvider allocWithZone:[self zone]] initWithCards:cardDictionaries UIDs:mediaUIDs groupUIDs:[[[[self document] stack] cardGroupController] allGroupedObjectsUIDs] unrefreshingUIDs:unrefreshingUIDs cardImage:cardImage];
    [provider declareTypesForPasteboard:[NSPasteboard generalPasteboard]];
    [provider release];
}

- (void)removeCurrentObject:(id)aObject
{
    [[[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeChild)] removeFromHyperParent];
}

- (void)changeObjectsVisibility:(id)aVisibility
{
    id pvVar1_2;

    pvVar1_2 = [[self document] stack];
    [pvVar1_2 setCardObjectsVisibility:[aVisibility tag]];
    [pvVar1_2 restoreObjectsVisibility];
}

- (void)toggleObjectAssistantInspectorMode:(id)aMode
{
    id pvVar1;

    pvVar1 = [HSObjectAssistantController sharedAssistantController];
    [[pvVar1 objectAssistant] setPrefersInspectorMode:(unsigned int)(![[pvVar1 objectAssistant] prefersInspectorMode])];
}

- (void)toggleObjectAssistant:(id)aAssistant
{
    id self_00;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    [self_00 setActive:(unsigned int)(![self_00 isActive]) explicitlyByUser:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000264f2 @ 000264f2, 473 bytes * /

void FUN_000264f2(HSEditorWindowController *self,SEL _cmd,id hideIfNeededBottomToolbarView,
                 id mainAreaTintedView,id mainWindow,BOOL animated,BOOL moveFrame)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined1 local_34 [12];
  float local_28;
  undefined4 local_24;
  float fStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  pvVar1 = _objc_msgSend(hideIfNeededBottomToolbarView,sel_superview);
  if (((pvVar1 != (id)0x0) && (mainWindow != (id)0x0)) && (mainAreaTintedView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_mainWindowMinCardAreaSize);
    _objc_msgSend(self,sel_updateContentMinSize_forWindow_animated_,pvVar1,extraout_EDX,mainWindow,
                  (int)animated);
    _objc_msgSend_stret(&local_24,mainWindow,sel_frame);
    _objc_msgSend_stret(local_34,hideIfNeededBottomToolbarView,sel_bounds);
    pvVar1 = _objc_msgSend(mainAreaTintedView,sel_autoresizingMask);
    if (moveFrame != '\0') {
      fStack_20 = fStack_20 + local_28;
    }
    fStack_18 = fStack_18 - local_28;
    _objc_msgSend(mainAreaTintedView,sel_setAutoresizingMask_,10);
    _objc_msgSend(hideIfNeededBottomToolbarView,sel_setAutoresizingMask_,10);
    _objc_msgSend(mainWindow,sel_setFrame_display_animate_,CONCAT44(fStack_20,local_24),
                  CONCAT44(fStack_18,local_1c),1,(int)animated);
    _objc_msgSend(hideIfNeededBottomToolbarView,sel_retain);
    _objc_msgSend(hideIfNeededBottomToolbarView,sel_removeFromSuperviewWithoutNeedingDisplay);
    _objc_msgSend(mainAreaTintedView,sel_setAutoresizingMask_,pvVar1);
    _objc_msgSend(hideIfNeededBottomToolbarView,sel_setAutoresizingMask_,0x22);
  }
  return;
}

*/
- (void)hideIfNeededBottomToolbarView:(id)aView mainAreaTintedView:(id)aView2 mainWindow:(id)aWindow animated:(BOOL)aAnimated moveFrame:(BOOL)aFrame
{
    if ([aView superview] != nil && aWindow != nil && aView2 != nil) {
        [self updateContentMinSize:[self mainWindowMinCardAreaSize] forWindow:aWindow animated:aAnimated];
        NSRect windowFrame = [aWindow frame];
        NSRect viewBounds = [aView bounds];
        NSUInteger savedMask = [aView2 autoresizingMask];
        if (aFrame) {
            windowFrame.origin.y += viewBounds.size.height;
        }
        windowFrame.size.height -= viewBounds.size.height;
        [aView2 setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [aView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [aWindow setFrame:windowFrame display:YES animate:aAnimated];
        [aView retain];
        [aView removeFromSuperviewWithoutNeedingDisplay];
        [aView2 setAutoresizingMask:savedMask];
        [aView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
    }
}

- (void)hideIfNeededBottomToolbarView:(id)aView mainAreaTintedView:(id)aView2 mainWindow:(id)aWindow animated:(BOOL)aAnimated
{
    [self hideIfNeededBottomToolbarView:aView mainAreaTintedView:aView2 mainWindow:aWindow animated:aAnimated moveFrame:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000266cb @ 000266cb, 1109 bytes * /

void FUN_000266cb(HSEditorWindowController *self,SEL _cmd,id showIfNeededBottomToolbarView,
                 id workAreaView,id mainAreaTintedView,id mainWindow,BOOL animated)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 *puVar4;
  float fVar5;
  undefined1 local_a4 [4];
  float fStack_a0;
  float fStack_98;
  undefined1 local_94 [12];
  float local_88;
  undefined4 local_84;
  float fStack_80;
  undefined4 local_7c;
  float fStack_78;
  undefined4 local_74;
  float fStack_70;
  undefined4 local_6c;
  float fStack_68;
  undefined1 local_64 [16];
  undefined1 local_54 [16];
  undefined1 local_44 [8];
  undefined4 local_3c;
  undefined1 local_34 [4];
  float local_30;
  undefined1 local_24 [12];
  float local_18;
  
  if (showIfNeededBottomToolbarView != (id)0x0) {
    pvVar1 = _objc_msgSend(showIfNeededBottomToolbarView,sel_superview);
    if ((((pvVar1 == (id)0x0) && (workAreaView != (id)0x0)) && (mainWindow != (id)0x0)) &&
       (mainAreaTintedView != (id)0x0)) {
      pvVar2 = _objc_msgSend(self,sel_mainWindowMinCardAreaSize);
      pvVar1 = self->_bottomAreaTintedView;
      _objc_msgSend_stret(local_64,pvVar1,sel_bounds);
      _objc_msgSend_stret(local_54,pvVar1,sel_convertRect_toView_);
      _objc_msgSend(self,sel_updateContentMinSize_forWindow_animated_);
      _objc_msgSend_stret(&local_74,mainWindow,sel_frame);
      _objc_msgSend_stret(&local_84,showIfNeededBottomToolbarView,sel_frame);
      _objc_msgSend_stret(local_94,showIfNeededBottomToolbarView,sel_bounds);
      pvVar1 = _objc_msgSend(mainAreaTintedView,sel_autoresizingMask);
      _objc_msgSend_stret(local_44,workAreaView,sel_bounds);
      local_7c = local_3c;
      fStack_80 = -fStack_78;
      pvVar3 = _objc_msgSend(mainWindow,sel_screen);
      _objc_msgSend_stret(local_34,pvVar3,sel_visibleFrame);
      fStack_70 = fStack_70 - local_88;
      if (fStack_70 <= local_30) {
        fStack_70 = local_30;
      }
      fStack_68 = local_88 + fStack_68;
      pvVar3 = _objc_msgSend(mainWindow,sel_screen);
      _objc_msgSend_stret(local_24,pvVar3,sel_visibleFrame);
      puVar4 = (undefined4 *)&stack0xffffff04;
      if (local_18 < fStack_68) {
        fVar5 = fStack_68 - local_18;
        fStack_80 = fVar5 - fStack_78;
        _objc_msgSend_stret(local_a4,mainAreaTintedView,sel_frame);
        puVar4 = (undefined4 *)&stack0xffffff00;
        fStack_98 = fStack_98 - fVar5;
        fStack_a0 = fVar5 + fStack_a0;
        _objc_msgSend(mainAreaTintedView,sel_setFrame_);
      }
      puVar4[1] = sel_setAutoresizingMask_;
      *puVar4 = mainAreaTintedView;
      puVar4[2] = 10;
      puVar4[-1] = 0x26a01;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      puVar4[1] = sel_setAutoresizingMask_;
      *puVar4 = showIfNeededBottomToolbarView;
      puVar4[2] = 10;
      puVar4[-1] = 0x26a1e;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      *(ulonglong *)(puVar4 + 4) = CONCAT44(fStack_78,local_7c);
      *(ulonglong *)(puVar4 + 2) = CONCAT44(fStack_80,local_84);
      puVar4[1] = sel_setFrame_;
      *puVar4 = showIfNeededBottomToolbarView;
      puVar4[-1] = 0x26a49;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      puVar4[2] = showIfNeededBottomToolbarView;
      puVar4[1] = sel_addSubview_;
      *puVar4 = workAreaView;
      puVar4[-1] = 0x26a65;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      puVar4[1] = sel_release;
      *puVar4 = showIfNeededBottomToolbarView;
      puVar4[-1] = 0x26a7a;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      *(ulonglong *)(puVar4 + 4) = CONCAT44(fStack_68,local_6c);
      *(ulonglong *)(puVar4 + 2) = CONCAT44(fStack_70,local_74);
      puVar4[7] = (int)animated;
      puVar4[1] = sel_setFrame_display_animate_;
      *puVar4 = mainWindow;
      puVar4[6] = 1;
      puVar4[-1] = 0x26ab1;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      puVar4[3] = extraout_EDX;
      puVar4[2] = pvVar2;
      puVar4[1] = sel_setContentMinSize_;
      *puVar4 = mainWindow;
      puVar4[-1] = 0x26adf;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      puVar4[1] = sel_setAutoresizingMask_;
      *puVar4 = showIfNeededBottomToolbarView;
      puVar4[2] = 0x22;
      puVar4[-1] = 0x26afc;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
      puVar4[2] = pvVar1;
      puVar4[1] = sel_setAutoresizingMask_;
      *puVar4 = mainAreaTintedView;
      puVar4[-1] = 0x26b15;
      _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
    }
  }
  return;
}

*/
- (void)showIfNeededBottomToolbarView:(id)aView workAreaView:(id)aView2 mainAreaTintedView:(id)aView3 mainWindow:(id)aWindow animated:(BOOL)aAnimated
{
    if (aView != nil && [aView superview] == nil && aView2 != nil && aWindow != nil && aView3 != nil) {
        NSSize minimumSize = [self mainWindowMinCardAreaSize];
        [self updateContentMinSize:minimumSize forWindow:aWindow animated:aAnimated];
        NSRect windowFrame = [aWindow frame];
        NSRect toolbarFrame = [aView frame];
        NSRect toolbarBounds = [aView bounds];
        NSUInteger savedMask = [aView3 autoresizingMask];
        NSRect workAreaBounds = [aView2 bounds];
        toolbarFrame.size.width = workAreaBounds.size.width;
        toolbarFrame.origin.y = -toolbarFrame.size.height;
        NSRect visibleFrame = [[aWindow screen] visibleFrame];
        windowFrame.origin.y -= toolbarBounds.size.height;
        if (windowFrame.origin.y <= visibleFrame.origin.y) {
            windowFrame.origin.y = visibleFrame.origin.y;
        }
        windowFrame.size.height += toolbarBounds.size.height;
        visibleFrame = [[aWindow screen] visibleFrame];
        if (visibleFrame.size.height < windowFrame.size.height) {
            float excess = windowFrame.size.height - visibleFrame.size.height;
            toolbarFrame.origin.y = excess - toolbarFrame.size.height;
            NSRect mainFrame = [aView3 frame];
            mainFrame.size.height -= excess;
            mainFrame.origin.y += excess;
            [aView3 setFrame:mainFrame];
        }
        [aView3 setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [aView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [aView setFrame:toolbarFrame];
        [aView2 addSubview:aView];
        [aView release];
        [aWindow setFrame:windowFrame display:YES animate:aAnimated];
        [aWindow setContentMinSize:minimumSize];
        [aView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
        [aView3 setAutoresizingMask:savedMask];
    }
}

- (id)statusbarController
{
    return _statusbarController;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00026b20 @ 00026b20, 354 bytes * /

void FUN_00026b20(HSEditorWindowController *self,SEL _cmd,BOOL setBottomToolbarVisible,BOOL animated
                 ,BOOL moveFrame)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  id pvVar5;
  id pvVar6;
  int iVar7;
  HSEditorWindowController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_0034dbd0;
  _objc_msgSendSuper(&local_1c,sel_setBottomToolbarVisible_,(int)setBottomToolbarVisible);
  pvVar2 = _objc_msgSend(self,sel_window);
  if (setBottomToolbarVisible == 0) {
    pvVar3 = self->_bottomAreaTintedView;
    pvVar4 = (id)(int)animated;
    op = sel_hideIfNeededBottomToolbarView_mainAreaTintedView_mainWindow_animated_moveFrame_;
    pvVar5 = self->_mainAreaTintedView;
    pvVar6 = pvVar2;
    animated = moveFrame;
  }
  else {
    pvVar3 = self->_bottomAreaTintedView;
    op = sel_showIfNeededBottomToolbarView_workAreaView_mainAreaTintedView_mainWindow_animated_;
    pvVar5 = self->_workAreaView;
    pvVar6 = self->_mainAreaTintedView;
    pvVar4 = pvVar2;
  }
  iVar7 = (int)animated;
  _objc_msgSend(self,op,pvVar3,pvVar5,pvVar6,pvVar4,iVar7);
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI,pvVar3,pvVar5,pvVar6,pvVar4,iVar7);
    uVar1 = *(undefined4 *)PTR_00336124;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(byte)setBottomToolbarVisible);
    _objc_msgSend(pvVar2,sel_setSettings_forKey_,pvVar3,uVar1);
  }
  return;
}

*/
- (void)setBottomToolbarVisible:(BOOL)aVisible animated:(BOOL)aAnimated moveFrame:(BOOL)aFrame
{
    [super setBottomToolbarVisible:aVisible animated:aAnimated moveFrame:aFrame];
    id window = [self window];
    if (!aVisible) {
        [self hideIfNeededBottomToolbarView:_bottomAreaTintedView mainAreaTintedView:_mainAreaTintedView mainWindow:window animated:aAnimated moveFrame:aFrame];
    } else {
        [self showIfNeededBottomToolbarView:_bottomAreaTintedView workAreaView:_workAreaView mainAreaTintedView:_mainAreaTintedView mainWindow:window animated:aAnimated];
    }
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:aVisible] forKey:HSUIModeIsBottomToolbarShown];
    }
}

- (void)setBottomToolbarVisible:(BOOL)aVisible animated:(BOOL)aAnimated
{
    [self setBottomToolbarVisible:aVisible animated:aAnimated moveFrame:YES];
}

- (void)setBottomToolbarVisible:(BOOL)aVisible
{
    [self setBottomToolbarVisible:aVisible animated:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00026c82 @ 00026c82, 267 bytes * /

void FUN_00026c82(HSEditorWindowController *self,SEL _cmd,id hideShowToolbar)

{
  undefined4 uVar1;
  id pvVar2;
  id self_00;
  HSEditorWindowController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_0034dbd0;
  _objc_msgSendSuper(&local_1c,sel_hideShowToolbar_,hideShowToolbar);
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_toolbarController);
    pvVar2 = _objc_msgSend(pvVar2,sel_toolbar);
    pvVar2 = _objc_msgSend(pvVar2,sel_isVisible);
    self_00 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    uVar1 = *(undefined4 *)PTR_0033612c;
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)pvVar2 & 0xff);
    _objc_msgSend(self_00,sel_setSettings_forKey_,pvVar2,uVar1);
  }
  return;
}

*/
- (void)hideShowToolbar:(id)aToolbar
{
    [super hideShowToolbar:aToolbar];
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:[[[self toolbarController] toolbar] isVisible]] forKey:HSUIModeIsToolbarShown];
    }
}

- (BOOL)supportMenuItemStoredTitleValidation
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00026d8d @ 00026d8d, 12352 bytes * /

BOOL FUN_00026d8d(HSEditorWindowController *self,SEL _cmd,id validateUserInterfaceItem)

{
  char cVar1;
  undefined *puVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  HSEditorWindowController *pHVar6;
  id pvVar7;
  cfstringStruct *pcVar8;
  undefined *puVar9;
  id pvVar10;
  id pvVar11;
  undefined *puVar12;
  SEL pcVar13;
  undefined4 *puVar14;
  bool bVar15;
  double dVar16;
  undefined4 uVar17;
  undefined *local_2c;
  char local_24;
  cfstringStruct *local_20;
  HSEditorWindowController *local_1c;
  undefined *local_18;
  
  puVar2 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_0034dbd0;
  puVar12 = validateUserInterfaceItem;
  pvVar3 = _objc_msgSendSuper(&local_1c,sel_validateUserInterfaceItem_,validateUserInterfaceItem);
  puVar9 = cls_HSEditorZoomController;
  local_24 = (char)pvVar3;
  if (puVar2 == sel_delete_) {
    if (local_24 == '\0') {
      puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class);
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
      if ((char)pvVar3 == '\0') goto LAB_0002993f;
      local_2c = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar12);
      pcVar5 = &cfstr_HSDeleteMenuTitle;
LAB_00028feb:
      pcVar8 = &cfstr_Editor;
      pcVar4 = &cfstr_empty;
      pcVar13 = sel_localizedStringForKey_value_table_;
    }
    else {
      pvVar3 = _objc_msgSend(self,sel_selectedCard);
      local_2c = cls_NSString;
      if (pvVar3 == (id)0x0) goto LAB_0002993f;
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar4 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSCopyCard,
                             &cfstr_empty,&cfstr_Editor);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar8 = &cfstr_Editor;
      pcVar5 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSDeleteFormat,
                             &cfstr_empty,&cfstr_Editor);
      pcVar13 = sel_stringWithFormat_;
    }
LAB_00028ff3:
    puVar12 = _objc_msgSend(local_2c,pcVar13,pcVar5,pcVar4,pcVar8);
    _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,puVar12);
  }
  else {
    if (puVar2 == sel_cut_) {
      if (local_24 == '\0') {
        puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class);
        pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
        if ((char)pvVar3 != '\0') {
          local_2c = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar12);
          pcVar5 = &cfstr_HSCutMenuTitle;
          goto LAB_00028feb;
        }
      }
      else {
        pvVar3 = _objc_msgSend(self,sel_selectedCard);
        if (pvVar3 != (id)0x0) {
          local_2c = cls_NSString;
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pcVar4 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSCopyCard,
                                 &cfstr_empty,&cfstr_Editor);
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pcVar5 = &cfstr_HSCutFormat;
LAB_00026ff2:
          pcVar8 = &cfstr_Editor;
          pcVar5 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                                 &cfstr_Editor);
          pcVar13 = sel_stringWithFormat_;
          goto LAB_00028ff3;
        }
      }
      goto LAB_0002993f;
    }
    if (puVar2 == sel_deleteSelectedCardObjects_) {
LAB_0002709d:
      pHVar6 = _objc_msgSend(self,sel_cardView,puVar12);
      pcVar13 = sel_validateUserInterfaceItem_;
      goto LAB_00029937;
    }
    if (puVar2 == sel_copy_) {
      if (local_24 == '\0') {
        puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class);
        pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
        if ((char)pvVar3 != '\0') {
          local_2c = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar12);
          pcVar5 = &cfstr_HSCopyMenuTitle;
          goto LAB_00028feb;
        }
      }
      else {
        pvVar3 = _objc_msgSend(self,sel_selectedCard);
        if (pvVar3 != (id)0x0) {
          local_2c = cls_NSString;
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pcVar4 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSCopyCard,
                                 &cfstr_empty,&cfstr_Editor);
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pcVar5 = &cfstr_HSCopyFormat;
          goto LAB_00026ff2;
        }
      }
      goto LAB_0002993f;
    }
    if (puVar2 == sel_paste_) {
      local_20 = (cfstringStruct *)0x0;
      pvVar3 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
      pvVar7 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
      pvVar3 = _objc_msgSend(pvVar3,sel_availableTypeFromArray_,pvVar7);
      if (pvVar3 == (id)0x0) {
        pvVar3 = _objc_msgSend(self,sel_cardView,pvVar7);
        pvVar7 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
        pvVar3 = _objc_msgSend(pvVar3,sel_canRecieveDataFromPasteboard_dataName_,pvVar7,&local_20);
        if ((char)pvVar3 != '\0') goto LAB_00027336;
        local_24 = '\0';
      }
      else {
LAB_00027336:
        pvVar7 = _objc_msgSend(cls_NSMenuItem,sel_class,pvVar7);
        pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar7);
        if ((char)pvVar3 != '\0') {
          if (local_20 == (cfstringStruct *)0x0) {
            pvVar3 = _objc_msgSend(self,sel_class,pvVar7);
            pvVar7 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
            local_20 = _objc_msgSend(pvVar3,sel_localizedMenuTitleForCardsPasteBoardType_,pvVar7);
          }
          pcVar4 = local_20;
          puVar12 = cls_NSString;
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
          pcVar5 = &cfstr_Editor;
          pcVar8 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteFormat,
                                 &cfstr_empty,&cfstr_Editor);
          pcVar13 = sel_stringWithFormat_;
LAB_00028050:
          puVar12 = _objc_msgSend(puVar12,pcVar13,pcVar8,pcVar4,pcVar5);
          pcVar13 = sel_setTitle_;
LAB_00027eeb:
          _objc_msgSend(validateUserInterfaceItem,pcVar13,puVar12);
          goto LAB_000290ca;
        }
        local_24 = '\x01';
      }
      puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class,pvVar7);
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
      if ((char)pvVar3 != '\0') {
        local_2c = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar12);
        pcVar5 = &cfstr_HSPasteMenuTitle;
        goto LAB_00028feb;
      }
    }
    else {
      if (puVar2 == sel_changeObjectsVisibility_) {
        puVar12 = sel_setState_;
        pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
        if ((char)pvVar3 != '\0') {
          pvVar3 = _objc_msgSend(self,sel_document,puVar12);
          pvVar3 = _objc_msgSend(pvVar3,sel_stack);
          pvVar3 = _objc_msgSend(pvVar3,sel_cardObjectsVisibility);
          pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_tag);
          puVar12 = (undefined *)(uint)(pvVar3 == pvVar7);
          _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar12);
        }
        if (local_24 != '\0') {
          pvVar3 = _objc_msgSend(self,sel_document,puVar12);
          pvVar3 = _objc_msgSend(pvVar3,sel_isInStoryboardMode);
          if ((char)pvVar3 == '\0') {
            pvVar3 = _objc_msgSend(self,sel_document,puVar12);
            pcVar13 = sel_isStackProtected;
LAB_0002751f:
            pvVar3 = _objc_msgSend(pvVar3,pcVar13,puVar12);
            if ((char)pvVar3 == '\0') goto LAB_000290ca;
          }
        }
        goto LAB_00027533;
      }
      if (puVar2 == sel_removeCurrentObject_) {
        pvVar3 = _objc_msgSend(self,
                               sel_selectedCardObjectForEditingOperationWithImplicitVerification);
        puVar12 = &DAT_00361218;
        pcVar13 = sel_queryHyperInterface_;
LAB_00027b3b:
        pvVar3 = _objc_msgSend(pvVar3,pcVar13,puVar12);
        local_24 = pvVar3 != (id)0x0;
      }
      else {
        if ((puVar2 == sel_bringForward_) || (puVar2 == sel_bringToFront_)) {
          pvVar3 = _objc_msgSend(self,sel_class);
          pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
          puVar12 = _objc_msgSend(pvVar7,sel_currentTool);
          pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,puVar12);
          local_24 = (char)pvVar3 == '\0';
          if ((bool)local_24) {
            pvVar3 = _objc_msgSend(self,
                                   sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                   ,puVar12);
            pHVar6 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003616a0);
            validateUserInterfaceItem = sel_compareWeight_;
            _objc_msgSend(pHVar6,sel_sortHyperInterfacesUsingSelector_,sel_compareWeight_);
            pcVar13 = sel_canIncrementHyperIndex;
            goto LAB_00029937;
          }
          goto LAB_0002993f;
        }
        if ((puVar2 == sel_sendBackward_) || (puVar2 == sel_sendToBack_)) {
          pvVar3 = _objc_msgSend(self,sel_class);
          pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
          puVar12 = _objc_msgSend(pvVar7,sel_currentTool);
          pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,puVar12);
          local_24 = (char)pvVar3 == '\0';
          if ((bool)local_24) {
            pvVar3 = _objc_msgSend(self,
                                   sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                   ,puVar12);
            pHVar6 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003616a0);
            validateUserInterfaceItem = sel_compareWeightBack_;
            _objc_msgSend(pHVar6,sel_sortHyperInterfacesUsingSelector_,sel_compareWeightBack_);
            pcVar13 = sel_canDecrementHyperIndex;
            goto LAB_00029937;
          }
          goto LAB_0002993f;
        }
        if (puVar2 == sel_zoomIn_) {
          dVar16 = _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
          puVar12 = (undefined *)(float)dVar16;
          pcVar13 = sel_canZoomInForZoomFactor_;
LAB_00027749:
          pvVar3 = _objc_msgSend(puVar9,pcVar13,puVar12);
          local_24 = (char)pvVar3;
          goto LAB_0002993f;
        }
        if (puVar2 == sel_zoomOut_) {
          dVar16 = _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
          puVar12 = (undefined *)(float)dVar16;
          pcVar13 = sel_canZoomOutForZoomFactor_;
          goto LAB_00027749;
        }
        if (puVar2 == sel_zoomToActualSize_) {
          dVar16 = _objc_msgSend_fpret(self->_cardView,sel_zoomFactor);
          puVar12 = (undefined *)(float)dVar16;
          pcVar13 = sel_canZoomToActualSizeForZoomFactor_;
          goto LAB_00027749;
        }
        if (puVar2 == sel_fitInWindow_) {
          pvVar3 = _objc_msgSend(self->_cardView,sel_zoomMode);
          local_24 = pvVar3 != (id)0x1;
          goto LAB_0002993f;
        }
        if (puVar2 == sel_toggleLockGeometry_) {
          pvVar3 = _objc_msgSend(self,sel_class);
          pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
          puVar12 = _objc_msgSend(pvVar7,sel_currentTool);
          pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,puVar12);
          if ((char)pvVar3 == '\0') {
            pvVar3 = _objc_msgSend(self->_cardView,sel_selection,puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_selectedObject);
            puVar12 = &DAT_003612cc;
            pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003612cc);
          }
          else {
            pvVar3 = (id)0x0;
          }
          puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class,puVar12);
          pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
          if ((char)pvVar7 != '\0') {
            pvVar7 = _objc_msgSend(pvVar3,sel_isLocked,puVar12);
            if ((char)pvVar7 == '\0') {
              puVar12 = (undefined *)0x0;
            }
            else {
              puVar12 = (undefined *)0x1;
            }
LAB_0002791f:
            _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar12);
          }
          local_24 = pvVar3 != (id)0x0;
          goto LAB_0002993f;
        }
        if (puVar2 == sel_lockGeometry_) {
          pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
          pvVar3 = _objc_msgSend(pvVar3,sel_selectedObject);
          puVar12 = &DAT_003612cc;
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003612cc);
          pcVar13 = sel_isLocked;
          if (pvVar3 != (id)0x0) goto LAB_0002751f;
LAB_00027533:
          local_24 = '\0';
          goto LAB_0002993f;
        }
        if (puVar2 == sel_unlockGeometry_) {
          pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
          pvVar3 = _objc_msgSend(pvVar3,sel_selectedObject);
          puVar12 = &DAT_003612cc;
          puVar9 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003612cc);
          pcVar13 = sel_isLocked;
          if (puVar9 != (undefined *)0x0) {
LAB_000279f9:
            pvVar3 = _objc_msgSend(puVar9,pcVar13,puVar12);
            if ((char)pvVar3 != '\0') goto LAB_000290ca;
          }
          goto LAB_00027533;
        }
        if (puVar2 == sel_runSoundRecordingPanel_) {
          pHVar6 = _objc_msgSend(self,sel_soundRecordingController);
          pcVar13 = sel_isInputSoundValid;
          validateUserInterfaceItem = puVar12;
          goto LAB_00029937;
        }
        if (((puVar2 == sel_runVideoRecordingPanel_) || (puVar2 == sel_addQuickShotGraphicObject_))
           || (puVar2 == sel_addQuickShotBackground_)) {
          if (self->_captureDeviceList == (id)0x0) {
            pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
            pvVar3 = _objc_msgSend(pvVar3,sel_isQTKitCapturingAvailable);
            if ((char)pvVar3 != '\0') {
              pvVar3 = _objc_msgSend(cls_NSArray,sel_alloc);
              puVar9 = _objc_msgSend(pvVar3,sel_initWithObjects_,*(undefined4 *)PTR_0033615c,
                                     *(undefined4 *)PTR_00336158,0);
              puVar12 = puVar9;
              pvVar3 = _objc_msgSend(cls_HSCaptureDeviceList,sel_captureDeviceListForMediaTypes_,
                                     puVar9);
              pvVar3 = _objc_msgSend(pvVar3,sel_retain);
              self->_captureDeviceList = pvVar3;
              _objc_msgSend(puVar9,sel_release);
            }
          }
          pvVar3 = self->_captureDeviceList;
          pcVar13 = sel_captureDeviceCount;
          goto LAB_00027b3b;
        }
        if (puVar2 == sel_runHypertextLinksDialog_) {
          pvVar3 = _objc_msgSend(self,sel_selectedUserObject);
          puVar12 = &DAT_0036221c;
          pvVar7 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036221c);
          pvVar10 = _objc_msgSend(pvVar7,sel_card);
          pvVar11 = _objc_msgSend(pvVar3,sel_hyperObject);
          if (pvVar10 != pvVar11) {
            pvVar7 = _objc_msgSend(pvVar7,sel_stack,puVar12);
            pvVar10 = _objc_msgSend(pvVar3,sel_hyperObject);
            if (pvVar7 != pvVar10) {
              pvVar7 = _objc_msgSend(pvVar3,sel_isHyperProxy);
              if ((char)pvVar7 == '\0') {
                puVar12 = &DAT_003616b4;
                pvVar7 = pvVar3;
                pcVar13 = sel_implementsHyperInterface_;
                goto LAB_000291ac;
              }
              goto LAB_00027533;
            }
          }
LAB_00027c1f:
          puVar12 = &DAT_003612cc;
LAB_00027c36:
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,puVar12);
          pcVar13 = sel_isLocked;
          goto LAB_0002751f;
        }
        if ((puVar2 == sel_switchTool_) || (puVar2 == sel_switchToolTypes_)) goto LAB_000290ca;
        if ((puVar2 == sel_flatSelection_) ||
           ((puVar2 == sel_flatSelectionToImage_ || (puVar2 == sel_mergeSelectionToImage_)))) {
          pvVar3 = _objc_msgSend(self,sel_class);
          pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
          puVar12 = _objc_msgSend(pvVar7,sel_currentTool);
          pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,puVar12);
          local_24 = (char)pvVar3 == '\0';
          if ((bool)local_24) {
            pvVar3 = _objc_msgSend(self->_cardView,sel_selection,puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_selectedObject);
            puVar12 = &DAT_003612cc;
            pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003612cc);
            pvVar7 = _objc_msgSend(pvVar3,sel_lastHyperAccessDidReturnMultipleValues);
            if ((((char)pvVar7 != '\0') ||
                (pvVar7 = _objc_msgSend(pvVar3,sel_canBeFlatten,puVar12), (char)pvVar7 == '\0')) ||
               (pvVar3 = _objc_msgSend(pvVar3,sel_lastHyperAccessDidReturnMultipleValues,puVar12),
               (char)pvVar3 != '\0')) goto LAB_00027533;
            if (puVar2 != sel_mergeSelectionToImage_) goto LAB_000290ca;
            pvVar3 = _objc_msgSend(self->_cardView,sel_selection,puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_nodesCount);
            local_24 = (id)0x1 < pvVar3;
          }
          goto LAB_0002993f;
        }
        if (puVar2 == sel_restoreToOriginalGraphic_) {
          pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
          pvVar3 = _objc_msgSend(pvVar3,sel_nodesCount);
          puVar9 = cls_HSImageObjectRestorer;
          if (pvVar3 == (id)0x1) {
            pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
            puVar12 = _objc_msgSend(pvVar3,sel_selectedObject);
            pcVar13 = sel_canRestoreNode_;
            goto LAB_000279f9;
          }
          goto LAB_00027533;
        }
        if (puVar2 == sel_showGridOptionsDialog_) {
          return '\x01';
        }
        if (puVar2 == sel_snapToGrid_) {
          puVar12 = sel_setState_;
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
          if ((char)pvVar3 == '\0') goto LAB_000290ca;
          pvVar3 = _objc_msgSend(self,sel_document,puVar12);
          pvVar3 = _objc_msgSend(pvVar3,sel_stack);
          pHVar6 = _objc_msgSend(pvVar3,sel_gridSettings);
          pcVar13 = sel_isSnapToGridEnabled;
LAB_00027ec7:
          pvVar3 = _objc_msgSend(pHVar6,pcVar13,puVar12);
          pcVar13 = sel_setState_;
          if ((char)pvVar3 == '\0') {
            puVar12 = (undefined *)0x0;
          }
          else {
            puVar12 = (undefined *)0x1;
          }
          goto LAB_00027eeb;
        }
        if (puVar2 == sel_snapToObjects_) {
          puVar12 = sel_setState_;
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
          pHVar6 = self;
          pcVar13 = sel_isSnapToObjectsEnabled;
          if ((char)pvVar3 != '\0') goto LAB_00027ec7;
          goto LAB_000290ca;
        }
        if (puVar2 == sel_toggleAuxiliaryIcons_) {
          puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class);
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
          if ((char)pvVar3 == '\0') goto LAB_000290ca;
          pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar12);
          pvVar3 = _objc_msgSend(pvVar3,sel_boolForKey_,*(undefined4 *)PTR_00336034);
          puVar12 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
          if ((char)pvVar3 != '\0') {
            puVar12 = _objc_msgSend(puVar12,sel_localizedStringForKey_value_table_,
                                    &cfstr_Show_Action_Icons,&cfstr_empty,0);
            pcVar13 = sel_setTitle_;
            goto LAB_00027eeb;
          }
          pcVar4 = &cfstr_empty;
          pcVar8 = &cfstr_Hide_Action_Icons;
          pcVar5 = (cfstringStruct *)0x0;
          pcVar13 = sel_localizedStringForKey_value_table_;
          goto LAB_00028050;
        }
        if (puVar2 == sel_toolPaletteSwitchTool_) {
          pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
          pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_tag);
          pvVar3 = _objc_msgSend(pvVar3,sel_canSelectToolWithTag_,pvVar7);
          local_24 = (char)pvVar3;
          puVar12 = sel_setState_;
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_selectedToolTag);
            pvVar7 = _objc_msgSend(validateUserInterfaceItem,sel_tag);
            puVar12 = (undefined *)(uint)(pvVar3 == pvVar7);
            _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar12);
          }
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_tag,puVar12);
          if (pvVar3 == (id)0x10) {
            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_selectedToolTag);
            if ((pvVar3 == (id)0x10) || (self->_isLassoIconChanged != '\0')) {
              pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
              pvVar3 = _objc_msgSend(pvVar3,sel_selectedToolTag);
              pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
              if (pvVar3 == (id)0x10) {
                pvVar3 = _objc_msgSend(pvVar7,sel_currentTool);
                pvVar3 = _objc_msgSend(pvVar3,sel_bitmapTool);
                pvVar3 = _objc_msgSend(pvVar3,sel_currentCreateSelectionMode);
                self->_isLassoIconChanged = '\x01';
              }
              else {
                pvVar3 = _objc_msgSend(pvVar7,sel_toolSettings);
                puVar12 = *(undefined **)PTR_PTR_003360f4;
                pvVar3 = _objc_msgSend(pvVar3,sel_settingForIdentifier_andKey_,puVar12,
                                       &cfstr_initialCreateSelectionMode);
                self->_isLassoIconChanged = '\0';
              }
              pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar12);
              pvVar7 = _objc_msgSend(pvVar7,sel_currentToolSet);
              pvVar10 = _objc_msgSend(pvVar3,sel_isEqualToString_,
                                      &cfstr_BTMagicWandCreateSelectionMode);
              if ((char)pvVar10 == '\0') {
                pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,
                                       &cfstr_BTFreeHandCreateSelectionMode);
                if ((char)pvVar3 == '\0') {
                  if (pvVar7 == (id)0x1) {
                    pcVar5 = &cfstr____Disable;
                  }
                  else {
                    pcVar5 = &cfstr____Normal;
                  }
                  pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pcVar5,&cfstr_Lasso_tool
                                        );
                  pcVar5 = &cfstr_Lasso_tool;
                }
                else {
                  if (pvVar7 == (id)0x1) {
                    pcVar5 = &cfstr____Disabled;
                  }
                  else {
                    pcVar5 = &cfstr____Normal;
                  }
                  pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pcVar5,
                                         &cfstr_PencilLasso_tool);
                  pcVar5 = &cfstr_PencilLasso_tool;
                }
              }
              else {
                if (pvVar7 == (id)0x1) {
                  pcVar5 = &cfstr____Disable;
                }
                else {
                  pcVar5 = &cfstr____Normal;
                }
                pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pcVar5,
                                       &cfstr_Freeform_selection);
                pcVar5 = &cfstr_Freeform_selection;
              }
              pvVar7 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____Press,pcVar5);
              pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pvVar3);
              _objc_msgSend(validateUserInterfaceItem,sel_setImage_,pvVar3);
              puVar12 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pvVar7);
              _objc_msgSend(validateUserInterfaceItem,sel_setAlternateImage_,puVar12);
            }
          }
          goto LAB_0002993f;
        }
        if (((puVar2 == sel_performHyperFindPanelAction_) || (puVar2 == sel_hyperShowGuessPanel_))
           || (puVar2 == sel_hyperCheckSpelling_)) goto LAB_000290ca;
        if ((((puVar2 == sel_showCardOptionsDialog_) || (puVar2 == sel_showStackOptionsDialog_)) ||
            (puVar2 == sel_editStackActions_)) || (puVar2 == sel_editCardActions_)) {
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
          pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
          local_24 = (char)pvVar3 == '\0';
          goto LAB_0002993f;
        }
        if (puVar2 == sel_standardColors_) goto LAB_000290ca;
        if (puVar2 == sel_editAppearance_) {
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
          pcVar13 = sel_canChangeActive;
LAB_00028599:
          pvVar3 = _objc_msgSend(pvVar3,pcVar13,puVar12);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(self,sel_selectedUserObject,puVar12);
            pcVar13 = sel_isHyperProxy;
            goto LAB_0002751f;
          }
          goto LAB_00027533;
        }
        if (puVar2 == sel_editActions_) {
          pvVar3 = _objc_msgSend(self,sel_selectedUserObject);
          puVar12 = &DAT_003612cc;
          pvVar3 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_003612cc);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(self,sel_selectedUserObject,puVar12);
            puVar12 = &DAT_00361d6c;
            pcVar13 = sel_implementsHyperInterface_;
            goto LAB_00028599;
          }
          goto LAB_00027533;
        }
        if (puVar2 == sel_editFeatures_) {
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
          pvVar3 = _objc_msgSend(pvVar3,sel_canChangeActive);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(self,sel_selectedUserObject);
            puVar12 = &DAT_003612cc;
            pcVar13 = sel_implementsHyperInterface_;
            goto LAB_00028599;
          }
          goto LAB_00027533;
        }
        if (puVar2 == sel_textFieldTamer_) goto LAB_000290ca;
        if ((puVar2 == sel_makeGroupCard_) || (puVar2 == sel_sameBackground_)) {
          pvVar3 = _objc_msgSend(self,sel_document);
          pcVar13 = sel_currentCard;
          goto LAB_00027b3b;
        }
        if (puVar2 == sel_toggleObjectAssistant_) {
          puVar12 = sel_setState_;
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                   puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_isActive);
            puVar12 = (undefined *)(uint)((char)pvVar3 != '\0');
            _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar12);
          }
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                 puVar12);
          pvVar3 = _objc_msgSend(pvVar3,sel_canChangeActive);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(self,sel_selectedUserObject,puVar12);
            puVar12 = &DAT_00361358;
            goto LAB_00027c36;
          }
          goto LAB_00027533;
        }
        if (puVar2 == sel_toggleObjectAssistantInspectorMode_) {
          puVar12 = sel_setState_;
          pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                   puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_objectAssistant);
            pvVar3 = _objc_msgSend(pvVar3,sel_isCurrentlyWorkingInSOTSMode);
            puVar12 = (undefined *)(uint)((char)pvVar3 != '\0');
            _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar12);
          }
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                 puVar12);
          pvVar3 = _objc_msgSend(pvVar3,sel_isActive);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                   puVar12);
            pvVar3 = _objc_msgSend(pvVar3,sel_objectAssistant);
            pvVar3 = _objc_msgSend(pvVar3,sel_supportsSettingsOnTheSpotMode);
            if ((char)pvVar3 != '\0') {
              pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
              pvVar3 = _objc_msgSend(pvVar3,sel_objectAssistant);
              pcVar13 = sel_isWorkingInTemporaryMode;
              goto LAB_0002751f;
            }
          }
          goto LAB_00027533;
        }
        if (((puVar2 != sel_addButtonObject_) && (puVar2 != sel_addGraphic_)) &&
           ((puVar2 != sel_addGraphicObject_ && (puVar2 != sel_addTextObject_)))) {
          if (puVar2 == sel_importText_) {
            pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
            pvVar3 = _objc_msgSend(pvVar3,sel_selectedObject);
            pvVar7 = _objc_msgSend(self,sel_document);
            pvVar7 = _objc_msgSend(pvVar7,sel_isInPlayerMode);
            if ((char)pvVar7 == '\0') {
              puVar12 = &DAT_00362230;
              pvVar7 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_00362230);
              if ((char)pvVar7 != '\0') {
                puVar12 = &DAT_003612cc;
                goto LAB_00027c36;
              }
            }
          }
          else if ((((puVar2 != sel_addWebObject_) && (puVar2 != sel_addMovieComboObject_)) &&
                   (puVar2 != sel_addSoundComboObject_)) &&
                  ((puVar2 != sel_addMediaObject_ && (puVar2 != sel_addLiveVideoObject_)))) {
            puVar14 = (undefined4 *)PTR_00336144;
            if (puVar2 == sel_addWebCamObject_) {
LAB_000289bc:
              pHVar6 = (HSEditorWindowController *)cls_HSRestrictionsManager;
              pcVar13 = sel_restrictionState_;
              validateUserInterfaceItem = (undefined *)*puVar14;
              goto LAB_00029937;
            }
            if (puVar2 == sel_draw3DShapes_) goto LAB_000290ca;
            if (puVar2 == sel_drawMultiple_) {
              puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class);
              pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
              if ((((char)pvVar3 == '\0') ||
                  (pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar12),
                  pvVar3 == (id)0x0)) ||
                 ((pvVar7 = _objc_msgSend(pvVar3,sel_selectedToolTag,puVar12), 3 < (int)pvVar7 - 10U
                  && ((pvVar7 != (id)0x2b && (2 < (int)pvVar7 - 0x2cU)))))) goto LAB_00027533;
              pvVar7 = _objc_msgSend(cls_HSToolManager,sel_toolIdentifierForTag_,pvVar7);
              pvVar3 = _objc_msgSend(pvVar3,sel_toolSettings);
              uVar17 = *(undefined4 *)PTR_0033611c;
              pvVar3 = _objc_msgSend(pvVar3,sel_settingForIdentifier_andKey_,pvVar7,uVar17);
              if (pvVar3 == (id)0x0) {
LAB_00028abe:
                bVar15 = false;
              }
              else {
                pvVar3 = _objc_msgSend(pvVar3,sel_unsignedIntegerValue,pvVar7,uVar17);
                bVar15 = pvVar3 == (id)0xffffffff;
              }
            }
            else {
              if (puVar2 != sel_drawCentered_) {
                if (puVar2 == sel_rotateSelectedObject_) {
                  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                  validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                  pvVar3 = _objc_msgSend(self,sel_class);
                  puVar12 = validateUserInterfaceItem;
                  pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,validateUserInterfaceItem);
                  if ((char)pvVar3 == '\0') {
                    validateUserInterfaceItem =
                         _objc_msgSend(self,
                                       sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                       ,puVar12);
                  }
                  pHVar6 = _objc_msgSend(self,sel_class,puVar12);
                  pcVar13 = sel_canRotateObject_;
                }
                else if (puVar2 == sel_scaleAndRotate_) {
                  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                  validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                  pvVar3 = _objc_msgSend(self,sel_class);
                  puVar12 = validateUserInterfaceItem;
                  pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,validateUserInterfaceItem);
                  if ((char)pvVar3 == '\0') {
                    validateUserInterfaceItem =
                         _objc_msgSend(self,
                                       sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                       ,puVar12);
                  }
                  pHVar6 = _objc_msgSend(self,sel_class,puVar12);
                  pcVar13 = sel_canResizeAndRotateObject_;
                }
                else {
                  if (puVar2 != sel_createObjectFromSelection_) {
                    if (puVar2 != sel_convertToGraphicObject_) {
                      if (((puVar2 == sel_alignRight_) || (puVar2 == sel_alignLeft_)) ||
                         ((puVar2 == sel_alignCenter_ || (puVar2 == sel_alignJustified_)))) {
                        pvVar3 = _objc_msgSend(self,
                                               sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                              );
                        puVar12 = &DAT_00361934;
                        pvVar7 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_00361934);
                        if ((char)pvVar7 == '\0') {
                          puVar12 = &DAT_00361948;
                          pvVar3 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_00361948)
                          ;
                          if ((char)pvVar3 == '\0') {
                            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar12);
                            pvVar3 = _objc_msgSend(pvVar3,sel_selectedToolTag);
                            if (pvVar3 != (id)0x2) goto LAB_00027533;
                          }
                        }
                        goto LAB_000290ca;
                      }
                      if (((puVar2 == sel_alignObjectRight_) || (puVar2 == sel_alignObjectLeft_)) ||
                         (puVar2 == sel_alignObjectCenter_)) {
                        pvVar3 = _objc_msgSend(self,sel_class);
                        pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                        puVar12 = _objc_msgSend(pvVar7,sel_currentTool);
                        pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,puVar12);
                        local_24 = (char)pvVar3 == '\0';
                        if ((bool)local_24) {
                          pvVar3 = _objc_msgSend(self,
                                                 sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                 ,puVar12);
                          pvVar7 = _objc_msgSend(pvVar3,sel_countOfAllHyperInterfaces);
                          if (pvVar7 != (id)0x0) {
                            puVar12 = &DAT_003620c8;
                            pvVar7 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003620c8);
                            pcVar13 = sel_canMoveHorizontally;
LAB_000291ac:
                            pvVar7 = _objc_msgSend(pvVar7,pcVar13,puVar12);
                            if ((char)pvVar7 != '\0') goto LAB_00027c1f;
                          }
                          goto LAB_00027533;
                        }
                      }
                      else {
                        if (((puVar2 != sel_alignObjectTop_) && (puVar2 != sel_alignObjectMiddle_))
                           && (puVar2 != sel_alignObjectBottom_)) {
                          if ((puVar2 == sel_resizeToFillCard_) || (puVar2 == sel_resizeToFitCard_))
                          {
                            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                            validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                            pvVar3 = _objc_msgSend(self,sel_class);
                            puVar12 = validateUserInterfaceItem;
                            pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,
                                                   validateUserInterfaceItem);
                            if ((char)pvVar3 == '\0') {
                              validateUserInterfaceItem =
                                   _objc_msgSend(self,
                                                 sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                 ,puVar12);
                            }
                            pHVar6 = _objc_msgSend(self,sel_class,puVar12);
                            pcVar13 = sel_canMoveAndResizeObject_;
                          }
                          else if (puVar2 == sel_centerSelectedObjectOnCard_) {
                            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                            validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                            pvVar3 = _objc_msgSend(self,sel_class);
                            puVar12 = validateUserInterfaceItem;
                            pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,
                                                   validateUserInterfaceItem);
                            if ((char)pvVar3 == '\0') {
                              validateUserInterfaceItem =
                                   _objc_msgSend(self,
                                                 sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                 ,puVar12);
                            }
                            pHVar6 = _objc_msgSend(self,sel_class,puVar12);
                            pcVar13 = sel_canMoveObject_;
                          }
                          else if (puVar2 == sel_flipSideways_) {
                            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                            validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                            pvVar3 = _objc_msgSend(self,sel_class);
                            puVar12 = validateUserInterfaceItem;
                            pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,
                                                   validateUserInterfaceItem);
                            if ((char)pvVar3 == '\0') {
                              validateUserInterfaceItem =
                                   _objc_msgSend(self,sel_selectedHyperObject,puVar12);
                              puVar9 = _objc_msgSend(self,sel_selectedCard);
                              if (validateUserInterfaceItem != puVar9) {
                                validateUserInterfaceItem =
                                     _objc_msgSend(self,
                                                  sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                  ,puVar12);
                              }
                            }
                            pHVar6 = _objc_msgSend(self,sel_class,puVar12);
                            pcVar13 = sel_canFlipSidewaysObject_;
                          }
                          else {
                            if (puVar2 != sel_flipUpsideDown_) {
                              if (puVar2 == sel_openEffectsDialog_) {
                                pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                                puVar12 = _objc_msgSend(pvVar3,sel_currentTool);
                                pvVar3 = _objc_msgSend(self,sel_class);
                                pvVar3 = _objc_msgSend(pvVar3,sel_isValidSelectionTool_,puVar12);
                                local_24 = (char)pvVar3 != '\0';
                                if (!(bool)local_24) {
                                  validateUserInterfaceItem =
                                       _objc_msgSend(self,sel_selectedHyperObject,puVar12);
                                  pHVar6 = (HSEditorWindowController *)cls_HSEffectsDialogController
                                  ;
                                  pcVar13 = sel_canEditObject_;
                                  if (validateUserInterfaceItem == (undefined *)0x0) {
                                    pvVar3 = _objc_msgSend(self,sel_cardView,puVar12);
                                    validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_card);
                                    pHVar6 = (HSEditorWindowController *)
                                             cls_HSEffectsDialogController;
                                    pcVar13 = sel_canEditObject_;
                                  }
                                  goto LAB_00029937;
                                }
                              }
                              else {
                                puVar14 = (undefined4 *)PTR_00336148;
                                if (puVar2 == sel_showYouTubeDialog_) goto LAB_000289bc;
                                if (puVar2 == sel_copyIntoSelection_) {
                                  pvVar3 = _objc_msgSend(self,sel_cardView);
                                  puVar12 = puVar2;
                                  pvVar3 = _objc_msgSend(pvVar3,sel_respondsToSelector_,puVar2);
                                  if ((char)pvVar3 != '\0') goto LAB_0002709d;
                                  goto LAB_00027533;
                                }
                                if (puVar2 == sel_changeFontTrait_) {
                                  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                                  pvVar7 = _objc_msgSend(self,
                                                  sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                  );
                                  puVar12 = &DAT_003616dc;
                                  pvVar7 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,
                                                         &DAT_003616dc);
                                  if ((pvVar7 == (id)0x0) &&
                                     (pvVar10 = _objc_msgSend(pvVar3,sel_selectedToolTag,puVar12),
                                     pvVar10 == (id)0x2)) {
                                    pvVar7 = _objc_msgSend(pvVar3,sel_toolSettings,puVar12);
                                    pvVar3 = _objc_msgSend(pvVar3,sel_currentTool);
                                    pvVar3 = _objc_msgSend(pvVar7,sel_userObjectPrototypeForTool_,
                                                           pvVar3);
                                    puVar12 = &DAT_003616dc;
                                    pvVar7 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,
                                                           &DAT_003616dc);
                                  }
                                  pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_tag,puVar12);
                                  pcVar13 = sel_isHyperBold;
                                  if ((pvVar3 == (id)0x2) ||
                                     (pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_tag,
                                                             puVar12), pcVar13 = sel_isHyperItalic,
                                     pvVar3 == (id)0x1)) {
                                    pvVar3 = _objc_msgSend(pvVar7,pcVar13,puVar12);
                                    puVar12 = (undefined *)(uint)((char)pvVar3 != '\0');
                                    _objc_msgSend(validateUserInterfaceItem,sel_setState_,puVar12);
                                  }
                                  local_24 = pvVar7 != (id)0x0;
                                }
                                else {
                                  if (puVar2 == sel_underline_) {
                                    pvVar7 = _objc_msgSend(self,
                                                  sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                  );
                                    puVar12 = &DAT_00361934;
                                    pvVar3 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,
                                                           &DAT_00361934);
                                    if (pvVar3 == (id)0x0) {
                                      puVar12 = &DAT_00361948;
                                      pvVar3 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,
                                                             &DAT_00361948);
                                    }
                                    pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,
                                                           puVar12);
                                    if ((pvVar3 == (id)0x0) &&
                                       (pvVar10 = _objc_msgSend(pvVar7,sel_selectedToolTag,puVar12),
                                       pvVar10 == (id)0x2)) {
                                      pvVar3 = _objc_msgSend(pvVar7,sel_toolSettings,puVar12);
                                      pvVar7 = _objc_msgSend(pvVar7,sel_currentTool);
                                      pvVar3 = _objc_msgSend(pvVar3,sel_userObjectPrototypeForTool_,
                                                             pvVar7);
                                      puVar12 = &DAT_00361948;
                                      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,
                                                             &DAT_00361948);
                                    }
                                    pvVar7 = _objc_msgSend(pvVar3,sel_isHyperUnderlined,puVar12);
                                    puVar12 = (undefined *)(uint)((char)pvVar7 != '\0');
                                    goto LAB_0002791f;
                                  }
                                  pHVar6 = self;
                                  pcVar13 = sel_isThereButtonStylesToUpdate;
                                  validateUserInterfaceItem = puVar12;
                                  if (puVar2 == sel_updateAllButtonStyles_) goto LAB_00029937;
                                }
                              }
                              goto LAB_0002993f;
                            }
                            pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                            validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                            pvVar3 = _objc_msgSend(self,sel_class);
                            puVar12 = validateUserInterfaceItem;
                            pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,
                                                   validateUserInterfaceItem);
                            if ((char)pvVar3 == '\0') {
                              validateUserInterfaceItem =
                                   _objc_msgSend(self,sel_selectedHyperObject,puVar12);
                              puVar9 = _objc_msgSend(self,sel_selectedCard);
                              if (validateUserInterfaceItem != puVar9) {
                                validateUserInterfaceItem =
                                     _objc_msgSend(self,
                                                  sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                  ,puVar12);
                              }
                            }
                            pHVar6 = _objc_msgSend(self,sel_class,puVar12);
                            pcVar13 = sel_canFlipUpsideDownObject_;
                          }
                          goto LAB_00029937;
                        }
                        pvVar3 = _objc_msgSend(self,sel_class);
                        pvVar7 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                        puVar12 = _objc_msgSend(pvVar7,sel_currentTool);
                        pvVar3 = _objc_msgSend(pvVar3,sel_isSelectionTool_,puVar12);
                        local_24 = (char)pvVar3 == '\0';
                        if ((bool)local_24) {
                          pvVar3 = _objc_msgSend(self,
                                                 sel_selectedCardObjectForEditingOperationWithImplicitVerification
                                                 ,puVar12);
                          pvVar7 = _objc_msgSend(pvVar3,sel_countOfAllHyperInterfaces);
                          if (pvVar7 != (id)0x0) {
                            puVar12 = &DAT_003620c8;
                            pvVar7 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003620c8);
                            pcVar13 = sel_canMoveVertically;
                            goto LAB_000291ac;
                          }
                          goto LAB_00027533;
                        }
                      }
                      goto LAB_0002993f;
                    }
                    pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                    puVar9 = _objc_msgSend(pvVar3,sel_currentTool);
                    pvVar3 = _objc_msgSend(self,sel_class);
                    puVar12 = puVar9;
                    pvVar3 = _objc_msgSend(pvVar3,sel_isValidSelectionTool_,puVar9);
                    local_24 = (char)pvVar3;
                    if (local_24 == '\0') {
                      pvVar3 = _objc_msgSend(cls_HSToolManager,sel_toolIdentifierForTag_,1);
                      puVar12 = _objc_msgSend(puVar9,sel_toolIdentifier);
                      pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,puVar12);
                      if ((char)pvVar3 == '\0') goto LAB_00028e0f;
                      puVar9 = _objc_msgSend(self,sel_selectedUserObject,puVar12);
                      pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
                      pvVar3 = _objc_msgSend(pvVar3,sel_nodesCount);
                      if (pvVar3 != (id)0x1) goto LAB_00028e0f;
                      pvVar3 = _objc_msgSend(puVar9,sel_queryHyperInterface_,&DAT_003612cc);
                      pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
                      puVar12 = &DAT_00361a24;
                      local_24 = (char)pvVar3 == '\0';
                      pvVar3 = _objc_msgSend(puVar9,sel_implementsHyperInterface_,&DAT_00361a24);
                      bVar15 = (char)pvVar3 != '\0';
                      if ((bVar15) && ((bool)local_24)) {
                        bVar15 = true;
                        pvVar3 = _objc_msgSend(cls_HSImageObjectsOptimizer,sel_canConsolidateObject_
                                               ,puVar9);
                        local_24 = (char)pvVar3;
                        puVar12 = puVar9;
                      }
                    }
                    else {
LAB_00028e0f:
                      bVar15 = false;
                    }
                    puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class,puVar12);
                    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
                    if ((char)pvVar3 != '\0') {
                      local_2c = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,
                                               puVar12);
                      if (!bVar15) {
                        pcVar5 = &cfstr_HSConvertToGraphicObjectMenuTitle;
                        goto LAB_00028feb;
                      }
                      puVar12 = _objc_msgSend(local_2c,sel_localizedStringForKey_value_table_,
                                              &cfstr_HSConsolidateGraphicObjectMenuTitle,
                                              &cfstr_empty,&cfstr_Editor);
                      _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,puVar12);
                    }
                    goto LAB_0002993f;
                  }
                  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
                  validateUserInterfaceItem = _objc_msgSend(pvVar3,sel_currentTool);
                  pHVar6 = _objc_msgSend(self,sel_class);
                  pcVar13 = sel_isValidSelectionTool_;
                }
LAB_00029937:
                puVar12 = validateUserInterfaceItem;
                pvVar3 = _objc_msgSend(pHVar6,pcVar13,puVar12);
                local_24 = (char)pvVar3;
                goto LAB_0002993f;
              }
              puVar12 = _objc_msgSend(cls_NSMenuItem,sel_class);
              pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,puVar12);
              if ((((char)pvVar3 == '\0') ||
                  (pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar12),
                  pvVar3 == (id)0x0)) ||
                 ((pvVar7 = _objc_msgSend(pvVar3,sel_selectedToolTag,puVar12), 3 < (int)pvVar7 - 10U
                  && ((pvVar7 != (id)0x2b && (2 < (int)pvVar7 - 0x2cU)))))) goto LAB_00027533;
              pvVar7 = _objc_msgSend(cls_HSToolManager,sel_toolIdentifierForTag_,pvVar7);
              pvVar3 = _objc_msgSend(pvVar3,sel_toolSettings);
              uVar17 = *(undefined4 *)PTR_00336118;
              pvVar3 = _objc_msgSend(pvVar3,sel_settingForIdentifier_andKey_,pvVar7,uVar17);
              if (pvVar3 == (id)0x0) goto LAB_00028abe;
              pvVar3 = _objc_msgSend(pvVar3,sel_unsignedIntegerValue,pvVar7,uVar17);
              bVar15 = pvVar3 == (id)0x0;
            }
            puVar12 = (undefined *)(uint)bVar15;
            pcVar13 = sel_setState_;
            goto LAB_00027eeb;
          }
        }
LAB_000290ca:
        local_24 = '\x01';
      }
    }
  }
LAB_0002993f:
  pvVar3 = _objc_msgSend(self,sel_cardView,puVar12);
  pvVar3 = _objc_msgSend(pvVar3,sel_isOccupiedByTool);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_document,puVar12);
    pvVar3 = _objc_msgSend(pvVar3,sel_isDocumentClosing);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self,sel_document);
      pvVar3 = _objc_msgSend(pvVar3,sel_isModalSessionPresent);
      if ((char)pvVar3 == '\0') goto LAB_00029d33;
    }
  }
  if (((((((((((puVar2 == sel_createObjectFromSelection_) || (puVar2 == sel_convertToGraphicObject_)
              ) || (puVar2 == sel_scaleAndRotate_)) ||
            ((puVar2 == sel_draw3DShapes_ || (puVar2 == sel_addWebCamObject_)))) ||
           (puVar2 == sel_addLiveVideoObject_)) ||
          ((puVar2 == sel_addMediaObject_ || (puVar2 == sel_addTextObject_)))) ||
         ((puVar2 == sel_importText_ ||
          (((puVar2 == sel_addWebObject_ || (puVar2 == sel_addGraphic_)) ||
           (puVar2 == sel_addGraphicObject_)))))) ||
        ((((puVar2 == sel_addButtonObject_ || (puVar2 == sel_toggleObjectAssistantInspectorMode_))
          || (puVar2 == sel_toggleObjectAssistant_)) ||
         ((puVar2 == sel_sameBackground_ || (puVar2 == sel_makeGroupCard_)))))) ||
       ((((puVar2 == sel_textFieldTamer_ ||
          (((puVar2 == sel_titleCard_ || (puVar2 == sel_editFeatures_)) ||
           (puVar2 == sel_editActions_)))) ||
         ((puVar2 == sel_editAppearance_ || (puVar2 == sel_showStackOptionsDialog_)))) ||
        ((puVar2 == sel_hyperShowGuessPanel_ ||
         (((puVar2 == sel_performHyperFindPanelAction_ || (puVar2 == sel_toolPaletteSwitchTool_)) ||
          ((puVar2 == sel_toggleAuxiliaryIcons_ ||
           ((((puVar2 == sel_changeObjectsVisibility_ || (puVar2 == sel_snapToObjects_)) ||
             (puVar2 == sel_snapToGrid_)) ||
            ((puVar2 == sel_showGridOptionsDialog_ || (puVar2 == sel_flatSelection_)))))))))))))) ||
      (((puVar2 == sel_flatSelectionToImage_ ||
        ((puVar2 == sel_mergeSelectionToImage_ || (puVar2 == sel_switchTool_)))) ||
       ((((puVar2 == sel_switchToolTypes_ ||
          (((puVar2 == sel_runHypertextLinksDialog_ || (puVar2 == sel_runVideoRecordingPanel_)) ||
           (puVar2 == sel_captureImage_)))) ||
         (((puVar2 == sel_runSoundRecordingPanel_ || (puVar2 == sel_addQuickShotGraphicObject_)) ||
          (puVar2 == sel_addQuickShotBackground_)))) ||
        ((((puVar2 == sel_lockGeometry_ || (puVar2 == sel_unlockGeometry_)) ||
          ((puVar2 == sel_toggleLockGeometry_ ||
           (((puVar2 == sel_goToSpecificCard_ || (puVar2 == sel_goBack_)) ||
            (puVar2 == sel_goForward_)))))) ||
         ((puVar2 == sel_goToNextCard_ || (puVar2 == sel_goToPreviousCard_)))))))))) ||
     (((((puVar2 == sel_goToNextCardWithoutLeaveActions_ ||
         ((((puVar2 == sel_goToPreviousCardWithoutLeaveActions_ ||
            (puVar2 == sel_goToLastCardWithoutLeaveActions_)) ||
           ((puVar2 == sel_goToFirstCardWithoutLeaveActions_ ||
            ((((puVar2 == sel_goBackWithoutLeaveActions_ ||
               (puVar2 == sel_goForwardWithoutLeaveActions_)) ||
              (puVar2 == sel_goToSpecificCardWithoutLeaveActions_)) ||
             ((puVar2 == sel_goToHomeWithoutLeaveActions_ || (puVar2 == sel_goToLastCard_)))))))) ||
          (puVar2 == sel_goToFirstCard_)))) ||
        (((puVar2 == sel_sendBackward_ || (puVar2 == sel_sendToBack_)) ||
         (((((puVar2 == sel_bringForward_ ||
             (((puVar2 == sel_bringToFront_ || (puVar2 == sel_goToHome_)) ||
              (puVar2 == sel_removeCurrentObject_)))) ||
            (((puVar2 == sel_paste_ || (puVar2 == sel_copy_)) || (puVar2 == sel_delete_)))) ||
           ((puVar2 == sel_cut_ || (puVar2 == sel_selectAll_)))) ||
          ((puVar2 == sel_runEasyLinkDialog_ ||
           (((puVar2 == sel_runMakeEveryCardNextCardExtra_ || (puVar2 == sel_importBackground_)) ||
            (puVar2 == sel_eraseBackground_)))))))))) ||
       ((puVar2 == sel_addSoundObject_ || (puVar2 == sel_addMovieComboObject_)))) ||
      (puVar2 == sel_addSoundComboObject_)))) {
    local_24 = '\0';
  }
LAB_00029d33:
  pvVar3 = _objc_msgSend(self->_cardView,sel_selection);
  pvVar3 = _objc_msgSend(pvVar3,sel_selectedObject);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003612cc);
  pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
  cVar1 = local_24;
  if ((char)pvVar3 != '\0') {
    if (((puVar2 == sel_editAppearance_) || (puVar2 == sel_editActions_)) ||
       (puVar2 == sel_editFeatures_)) {
      cVar1 = '\0';
    }
    else {
      cVar1 = '\0';
      if (puVar2 != sel_scaleAndRotate_) {
        cVar1 = local_24;
      }
    }
  }
  return cVar1;
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    BOOL ok = [super validateUserInterfaceItem:aItem];
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    if (action == @selector(delete:) || action == @selector(cut:) || action == @selector(copy:)) {
        NSString *menuTitleKey = action == @selector(delete:) ? @"HSDeleteMenuTitle" : (action == @selector(cut:) ? @"HSCutMenuTitle" : @"HSCopyMenuTitle");
        NSString *formatKey = action == @selector(delete:) ? @"HSDeleteFormat" : (action == @selector(cut:) ? @"HSCutFormat" : @"HSCopyFormat");
        if (!ok) {
            if ([aItem isKindOfClass:[NSMenuItem class]]) {
                [aItem setTitle:[resources localizedStringForKey:menuTitleKey value:@"" table:@"Editor"]];
            }
        } else if ([self selectedCard] != nil) {
            NSString *cardTitle = [resources localizedStringForKey:@"HSCopyCard" value:@"" table:@"Editor"];
            NSString *format = [resources localizedStringForKey:formatKey value:@"" table:@"Editor"];
            [aItem setTitle:[NSString stringWithFormat:format, cardTitle]];
        }
    } else if (action == @selector(deleteSelectedCardObjects:)) {
        ok = [[self cardView] validateUserInterfaceItem:aItem];
    } else if (action == @selector(paste:)) {
        NSString *dataName = nil;
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        BOOL canPaste = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] != nil
            || [[self cardView] canRecieveDataFromPasteboard:[NSPasteboard generalPasteboard] dataName:&dataName];
        if (!canPaste) {
            ok = NO;
            if ([aItem isKindOfClass:[NSMenuItem class]]) {
                [aItem setTitle:[resources localizedStringForKey:@"HSPasteMenuTitle" value:@"" table:@"Editor"]];
            }
        } else if (![aItem isKindOfClass:[NSMenuItem class]]) {
            ok = YES;
        } else {
            if (dataName == nil) {
                dataName = [[self class] localizedMenuTitleForCardsPasteBoardType:[NSPasteboard generalPasteboard]];
            }
            NSString *format = [resources localizedStringForKey:@"HSPasteFormat" value:@"" table:@"Editor"];
            [aItem setTitle:[NSString stringWithFormat:format, dataName]];
            ok = YES;
        }
    } else if (action == @selector(changeObjectsVisibility:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[[self document] stack] cardObjectsVisibility] == [aItem tag]];
        }
        if (ok) {
            ok = ![[self document] isInStoryboardMode] && ![[self document] isStackProtected];
        } else {
            ok = NO;
        }
    } else if (action == @selector(removeCurrentObject:)) {
        ok = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeChild)] != nil;
    } else if (action == @selector(bringForward:) || action == @selector(bringToFront:) || action == @selector(sendBackward:) || action == @selector(sendToBack:)) {
        BOOL forward = (action == @selector(bringForward:) || action == @selector(bringToFront:));
        ok = ![[self class] isSelectionTool:[[HSToolManager sharedToolManager] currentTool]];
        if (ok) {
            id nodes = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSNodeAttributes)];
            [nodes sortHyperInterfacesUsingSelector:forward ? @selector(compareWeight:) : @selector(compareWeightBack:)];
            ok = forward ? [nodes canIncrementHyperIndex] : [nodes canDecrementHyperIndex];
        }
    } else if (action == @selector(zoomIn:)) {
        ok = [HSEditorZoomController canZoomInForZoomFactor:(float)[_cardView zoomFactor]];
    } else if (action == @selector(zoomOut:)) {
        ok = [HSEditorZoomController canZoomOutForZoomFactor:(float)[_cardView zoomFactor]];
    } else if (action == @selector(zoomToActualSize:)) {
        ok = [HSEditorZoomController canZoomToActualSizeForZoomFactor:(float)[_cardView zoomFactor]];
    } else if (action == @selector(fitInWindow:)) {
        ok = [_cardView zoomMode] != 1;
    } else if (action == @selector(toggleLockGeometry:)) {
        id lockAttributes = nil;
        if (![[self class] isSelectionTool:[[HSToolManager sharedToolManager] currentTool]]) {
            lockAttributes = [[[_cardView selection] selectedObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
        }
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:[lockAttributes isLocked] ? 1 : 0];
        }
        ok = lockAttributes != nil;
    } else if (action == @selector(lockGeometry:)) {
        id lockAttributes = [[[_cardView selection] selectedObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
        ok = lockAttributes != nil && ![lockAttributes isLocked];
    } else if (action == @selector(unlockGeometry:)) {
        id lockAttributes = [[[_cardView selection] selectedObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
        ok = lockAttributes != nil && [lockAttributes isLocked];
    } else if (action == @selector(runSoundRecordingPanel:)) {
        ok = [[self soundRecordingController] isInputSoundValid];
    } else if (action == @selector(runVideoRecordingPanel:) || action == @selector(addQuickShotGraphicObject:) || action == @selector(addQuickShotBackground:)) {
        if (_captureDeviceList == nil && [[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
            NSArray *mediaTypes = [[NSArray alloc] initWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
            _captureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:mediaTypes] retain];
            [mediaTypes release];
        }
        ok = [_captureDeviceList captureDeviceCount] != 0;
    } else if (action == @selector(runHypertextLinksDialog:)) {
        id object = [self selectedUserObject];
        id support = [object queryHyperInterface:@protocol(HSUserObjectSupport)];
        BOOL allowed = YES;
        if ([support card] != [object hyperObject] && [support stack] != [object hyperObject]) {
            if ([object isHyperProxy] || ![object implementsHyperInterface:@protocol(HSHypertextLinkContainerAttributes)]) {
                allowed = NO;
            }
        }
        ok = allowed && ![[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
    } else if (action == @selector(switchTool:) || action == @selector(switchToolTypes:)) {
        ok = YES;
    } else if (action == @selector(flatSelection:) || action == @selector(flatSelectionToImage:) || action == @selector(mergeSelectionToImage:)) {
        ok = ![[self class] isSelectionTool:[[HSToolManager sharedToolManager] currentTool]];
        if (ok) {
            id attributes = [[[_cardView selection] selectedObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
            if ([attributes lastHyperAccessDidReturnMultipleValues] || ![attributes canBeFlatten] || [attributes lastHyperAccessDidReturnMultipleValues]) {
                ok = NO;
            } else if (action == @selector(mergeSelectionToImage:)) {
                ok = [[_cardView selection] nodesCount] > 1;
            } else {
                ok = YES;
            }
        }
    } else if (action == @selector(restoreToOriginalGraphic:)) {
        if ([[_cardView selection] nodesCount] == 1) {
            ok = [HSImageObjectRestorer canRestoreNode:[[_cardView selection] selectedObject]];
        } else {
            ok = NO;
        }
    } else if (action == @selector(showGridOptionsDialog:)) {
        return YES;
    } else if (action == @selector(snapToGrid:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[[[self document] stack] gridSettings] isSnapToGridEnabled] ? 1 : 0];
        }
        ok = YES;
    } else if (action == @selector(snapToObjects:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[self isSnapToObjectsEnabled] ? 1 : 0];
        }
        ok = YES;
    } else if (action == @selector(toggleAuxiliaryIcons:)) {
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            BOOL hidden = [[NSUserDefaults standardUserDefaults] boolForKey:HSHideAuxiliaryIcons];
            [aItem setTitle:[[NSBundle mainBundle] localizedStringForKey:hidden ? @"Show Action Icons" : @"Hide Action Icons" value:@"" table:nil]];
        }
        ok = YES;
    } else if (action == @selector(toolPaletteSwitchTool:)) {
        ok = [[HSToolManager sharedToolManager] canSelectToolWithTag:[aItem tag]];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[HSToolManager sharedToolManager] selectedToolTag] == [aItem tag]];
        }
        if ([aItem tag] == 0x10 && ([[HSToolManager sharedToolManager] selectedToolTag] == 0x10 || _isLassoIconChanged)) {
            HSToolManager *toolManager = [HSToolManager sharedToolManager];
            id mode;
            if ([toolManager selectedToolTag] == 0x10) {
                mode = [[[[HSToolManager sharedToolManager] currentTool] bitmapTool] currentCreateSelectionMode];
                _isLassoIconChanged = YES;
            } else {
                mode = [[toolManager toolSettings] settingForIdentifier:@"HSLassoSelectionTool" andKey:@"initialCreateSelectionMode"];
                _isLassoIconChanged = NO;
            }
            BOOL disabled = [[HSToolManager sharedToolManager] currentToolSet] == 1;
            NSString *baseName;
            NSString *disabledSuffix;
            if ([mode isEqualToString:@"BTMagicWandCreateSelectionMode"]) {
                baseName = @"Freeform_selection";
                disabledSuffix = @"%@_Disable";
            } else if ([mode isEqualToString:@"BTFreeHandCreateSelectionMode"]) {
                baseName = @"PencilLasso_tool";
                disabledSuffix = @"%@_Disabled";
            } else {
                baseName = @"Lasso_tool";
                disabledSuffix = @"%@_Disable";
            }
            NSString *imageName = [NSString stringWithFormat:disabled ? disabledSuffix : @"%@_Normal", baseName];
            NSString *pressedName = [NSString stringWithFormat:@"%@_Press", baseName];
            [aItem setImage:[NSImage imageNamed:imageName]];
            [aItem setAlternateImage:[NSImage imageNamed:pressedName]];
        }
    } else if (action == @selector(performHyperFindPanelAction:) || action == @selector(hyperShowGuessPanel:) || action == @selector(hyperCheckSpelling:)) {
        ok = YES;
    } else if (action == @selector(showCardOptionsDialog:) || action == @selector(showStackOptionsDialog:) || action == @selector(editStackActions:) || action == @selector(editCardActions:)) {
        ok = ![[HSObjectAssistantController sharedAssistantController] isLocked];
    } else if (action == @selector(standardColors:)) {
        ok = YES;
    } else if (action == @selector(editAppearance:)) {
        ok = [[HSObjectAssistantController sharedAssistantController] canChangeActive] && ![[self selectedUserObject] isHyperProxy];
    } else if (action == @selector(editActions:)) {
        ok = [[self selectedUserObject] implementsHyperInterface:@protocol(HSCardObjectAttributes)]
            && [[self selectedUserObject] implementsHyperInterface:@protocol(HSActor)]
            && ![[self selectedUserObject] isHyperProxy];
    } else if (action == @selector(editFeatures:)) {
        ok = [[HSObjectAssistantController sharedAssistantController] canChangeActive]
            && [[self selectedUserObject] implementsHyperInterface:@protocol(HSCardObjectAttributes)]
            && ![[self selectedUserObject] isHyperProxy];
    } else if (action == @selector(textFieldTamer:)) {
        ok = YES;
    } else if (action == @selector(makeGroupCard:) || action == @selector(sameBackground:)) {
        ok = [[[self document] currentCard] queryHyperInterface:@protocol(HSCardObjectAttributes)] != nil;
    } else if (action == @selector(toggleObjectAssistant:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[HSObjectAssistantController sharedAssistantController] isActive] ? 1 : 0];
        }
        if (![[HSObjectAssistantController sharedAssistantController] canChangeActive]) {
            ok = NO;
        } else {
            ok = ![[[self selectedUserObject] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked];
        }
    } else if (action == @selector(toggleObjectAssistantInspectorMode:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:[[[HSObjectAssistantController sharedAssistantController] objectAssistant] isCurrentlyWorkingInSOTSMode] ? 1 : 0];
        }
        if (![[HSObjectAssistantController sharedAssistantController] isActive]) {
            ok = NO;
        } else if (![[[HSObjectAssistantController sharedAssistantController] objectAssistant] supportsSettingsOnTheSpotMode]) {
            ok = NO;
        } else {
            ok = ![[[HSObjectAssistantController sharedAssistantController] objectAssistant] isWorkingInTemporaryMode];
        }
    } else if (action == @selector(addButtonObject:) || action == @selector(addGraphic:) || action == @selector(addGraphicObject:) || action == @selector(addTextObject:)) {
        ok = YES;
    } else if (action == @selector(importText:)) {
        id selected = [[_cardView selection] selectedObject];
        if ([[self document] isInPlayerMode] || ![selected implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
            ok = YES;
        } else {
            ok = ![[selected queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked];
        }
    } else if (action == @selector(addWebObject:) || action == @selector(addMovieComboObject:) || action == @selector(addSoundComboObject:) || action == @selector(addMediaObject:) || action == @selector(addLiveVideoObject:)) {
        ok = YES;
    } else if (action == @selector(addWebCamObject:)) {
        ok = [HSRestrictionsManager restrictionState:HSWebCamsEnabled];
    } else if (action == @selector(showYouTubeDialog:)) {
        ok = [HSRestrictionsManager restrictionState:HSYouTubeDialogEnabled];
    } else if (action == @selector(draw3DShapes:)) {
        ok = YES;
    } else if (action == @selector(drawMultiple:) || action == @selector(drawCentered:)) {
        HSToolManager *toolManager = [HSToolManager sharedToolManager];
        if (![aItem isKindOfClass:[NSMenuItem class]] || toolManager == nil) {
            ok = NO;
        } else {
            NSInteger tag = [toolManager selectedToolTag];
            if (!((tag - 10) < 4U || tag == 0x2b || (tag - 0x2c) <= 2U)) {
                ok = NO;
            } else {
                id setting = [[toolManager toolSettings] settingForIdentifier:[HSToolManager toolIdentifierForTag:tag] andKey:action == @selector(drawMultiple:) ? HSToolPositioningOptionAttributeKey : HSToolCenteringOptionAttributeKey];
                BOOL state = NO;
                if (setting != nil) {
                    state = action == @selector(drawMultiple:) ? ([setting unsignedIntegerValue] == (NSUInteger)-1) : ([setting unsignedIntegerValue] == 0);
                }
                [aItem setState:state];
                ok = YES;
            }
        }
    } else if (action == @selector(rotateSelectedObject:) || action == @selector(scaleAndRotate:) || action == @selector(resizeToFillCard:) || action == @selector(resizeToFitCard:) || action == @selector(centerSelectedObjectOnCard:)) {
        id tool = [[HSToolManager sharedToolManager] currentTool];
        id object = tool;
        if (![[self class] isSelectionTool:tool]) {
            object = [self selectedCardObjectForEditingOperationWithImplicitVerification];
        }
        if (action == @selector(rotateSelectedObject:)) {
            ok = [[self class] canRotateObject:object];
        } else if (action == @selector(scaleAndRotate:)) {
            ok = [[self class] canResizeAndRotateObject:object];
        } else if (action == @selector(centerSelectedObjectOnCard:)) {
            ok = [[self class] canMoveObject:object];
        } else {
            ok = [[self class] canMoveAndResizeObject:object];
        }
    } else if (action == @selector(createObjectFromSelection:)) {
        ok = [[self class] isValidSelectionTool:[[HSToolManager sharedToolManager] currentTool]];
    } else if (action == @selector(convertToGraphicObject:)) {
        id tool = [[HSToolManager sharedToolManager] currentTool];
        BOOL consolidate = NO;
        ok = [[self class] isValidSelectionTool:tool];
        if (!ok && [[HSToolManager toolIdentifierForTag:1] isEqualToString:[tool toolIdentifier]]) {
            id object = [self selectedUserObject];
            if ([[_cardView selection] nodesCount] == 1) {
                BOOL locked = [[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
                ok = !locked;
                consolidate = [object implementsHyperInterface:@protocol(HSImageAttributes)];
                if (consolidate && !locked) {
                    ok = [HSImageObjectsOptimizer canConsolidateObject:object];
                }
            }
        }
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setTitle:[resources localizedStringForKey:consolidate ? @"HSConsolidateGraphicObjectMenuTitle" : @"HSConvertToGraphicObjectMenuTitle" value:@"" table:@"Editor"]];
        }
    } else if (action == @selector(alignRight:) || action == @selector(alignLeft:) || action == @selector(alignCenter:) || action == @selector(alignJustified:)) {
        id object = [self selectedCardObjectForEditingOperationWithImplicitVerification];
        if ([object implementsHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)] || [object implementsHyperInterface:@protocol(HSTextObjectAttributes)]) {
            ok = YES;
        } else {
            ok = [[HSToolManager sharedToolManager] selectedToolTag] == 2;
        }
    } else if (action == @selector(alignObjectRight:) || action == @selector(alignObjectLeft:) || action == @selector(alignObjectCenter:) || action == @selector(alignObjectTop:) || action == @selector(alignObjectMiddle:) || action == @selector(alignObjectBottom:)) {
        BOOL horizontal = (action == @selector(alignObjectRight:) || action == @selector(alignObjectLeft:) || action == @selector(alignObjectCenter:));
        ok = ![[self class] isSelectionTool:[[HSToolManager sharedToolManager] currentTool]];
        if (ok) {
            id object = [self selectedCardObjectForEditingOperationWithImplicitVerification];
            if ([object countOfAllHyperInterfaces] == 0) {
                ok = NO;
            } else {
                id geometry = [object queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
                ok = horizontal ? [geometry canMoveHorizontally] : [geometry canMoveVertically];
                if (ok) {
                    ok = ![[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked];
                }
            }
        }
    } else if (action == @selector(flipSideways:) || action == @selector(flipUpsideDown:)) {
        id tool = [[HSToolManager sharedToolManager] currentTool];
        id object = tool;
        if (![[self class] isSelectionTool:tool] && [self selectedHyperObject] != [self selectedCard]) {
            object = [self selectedCardObjectForEditingOperationWithImplicitVerification];
        }
        ok = action == @selector(flipSideways:) ? [[self class] canFlipSidewaysObject:object] : [[self class] canFlipUpsideDownObject:object];
    } else if (action == @selector(openEffectsDialog:)) {
        ok = [[self class] isValidSelectionTool:[[HSToolManager sharedToolManager] currentTool]];
        if (!ok) {
            id object = [self selectedHyperObject];
            if (object == nil) {
                object = [[self cardView] card];
            }
            ok = [HSEffectsDialogController canEditObject:object];
        } else {
            ok = YES;
        }
    } else if (action == @selector(copyIntoSelection:)) {
        if ([[self cardView] respondsToSelector:action]) {
            ok = [[self cardView] validateUserInterfaceItem:aItem];
        } else {
            ok = NO;
        }
    } else if (action == @selector(changeFontTrait:)) {
        HSToolManager *toolManager = [HSToolManager sharedToolManager];
        id fonts = [[self selectedCardObjectForEditingOperationWithImplicitVerification] queryHyperInterface:@protocol(HSGenericFontAttributes)];
        if (fonts == nil && [toolManager selectedToolTag] == 2) {
            fonts = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSGenericFontAttributes)];
        }
        if ([aItem tag] == 2) {
            [aItem setState:[fonts isHyperBold] ? 1 : 0];
        } else if ([aItem tag] == 1) {
            [aItem setState:[fonts isHyperItalic] ? 1 : 0];
        }
        ok = fonts != nil;
    } else if (action == @selector(underline:)) {
        id object = [self selectedCardObjectForEditingOperationWithImplicitVerification];
        id fonts = [object queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
        if (fonts == nil) {
            fonts = [object queryHyperInterface:@protocol(HSTextObjectAttributes)];
        }
        HSToolManager *toolManager = [HSToolManager sharedToolManager];
        if (fonts == nil && [toolManager selectedToolTag] == 2) {
            fonts = [[[toolManager toolSettings] userObjectPrototypeForTool:[toolManager currentTool]] queryHyperInterface:@protocol(HSTextObjectAttributes)];
        }
        [aItem setState:[fonts isHyperUnderlined] ? 1 : 0];
        ok = fonts != nil;
    } else if (action == @selector(updateAllButtonStyles:)) {
        ok = [self isThereButtonStylesToUpdate];
    }
    if ([_cardView isOccupiedByTool] || [[self document] isDocumentClosing] || [[self document] isModalSessionPresent]) {
        if (action == @selector(createObjectFromSelection:) || action == @selector(convertToGraphicObject:) || action == @selector(scaleAndRotate:) || action == @selector(draw3DShapes:) || action == @selector(addWebCamObject:) || action == @selector(addLiveVideoObject:) || action == @selector(addMediaObject:) || action == @selector(addTextObject:) || action == @selector(importText:) || action == @selector(addWebObject:) || action == @selector(addGraphic:) || action == @selector(addGraphicObject:) || action == @selector(addButtonObject:) || action == @selector(toggleObjectAssistantInspectorMode:) || action == @selector(toggleObjectAssistant:) || action == @selector(sameBackground:) || action == @selector(makeGroupCard:) || action == @selector(textFieldTamer:) || action == @selector(titleCard:) || action == @selector(editFeatures:) || action == @selector(editActions:) || action == @selector(editAppearance:) || action == @selector(showStackOptionsDialog:) || action == @selector(hyperShowGuessPanel:) || action == @selector(performHyperFindPanelAction:) || action == @selector(toolPaletteSwitchTool:) || action == @selector(toggleAuxiliaryIcons:) || action == @selector(changeObjectsVisibility:) || action == @selector(snapToObjects:) || action == @selector(snapToGrid:) || action == @selector(showGridOptionsDialog:) || action == @selector(flatSelection:) || action == @selector(flatSelectionToImage:) || action == @selector(mergeSelectionToImage:) || action == @selector(switchTool:) || action == @selector(switchToolTypes:) || action == @selector(runHypertextLinksDialog:) || action == @selector(runVideoRecordingPanel:) || action == @selector(captureImage:) || action == @selector(runSoundRecordingPanel:) || action == @selector(addQuickShotGraphicObject:) || action == @selector(addQuickShotBackground:) || action == @selector(lockGeometry:) || action == @selector(unlockGeometry:) || action == @selector(toggleLockGeometry:) || action == @selector(goToSpecificCard:) || action == @selector(goBack:) || action == @selector(goForward:) || action == @selector(goToNextCard:) || action == @selector(goToPreviousCard:) || action == @selector(goToNextCardWithoutLeaveActions:) || action == @selector(goToPreviousCardWithoutLeaveActions:) || action == @selector(goToLastCardWithoutLeaveActions:) || action == @selector(goToFirstCardWithoutLeaveActions:) || action == @selector(goBackWithoutLeaveActions:) || action == @selector(goForwardWithoutLeaveActions:) || action == @selector(goToSpecificCardWithoutLeaveActions:) || action == @selector(goToHomeWithoutLeaveActions:) || action == @selector(goToLastCard:) || action == @selector(goToFirstCard:) || action == @selector(sendBackward:) || action == @selector(sendToBack:) || action == @selector(bringForward:) || action == @selector(bringToFront:) || action == @selector(goToHome:) || action == @selector(removeCurrentObject:) || action == @selector(paste:) || action == @selector(copy:) || action == @selector(delete:) || action == @selector(cut:) || action == @selector(selectAll:) || action == @selector(runEasyLinkDialog:) || action == @selector(runMakeEveryCardNextCardExtra:) || action == @selector(importBackground:) || action == @selector(eraseBackground:) || action == @selector(addSoundObject:) || action == @selector(addMovieComboObject:) || action == @selector(addSoundComboObject:)) {
            ok = NO;
        }
    }
    if ([[[[_cardView selection] selectedObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
        if (action == @selector(editAppearance:) || action == @selector(editActions:) || action == @selector(editFeatures:)) {
            return NO;
        }
        return action == @selector(scaleAndRotate:) ? NO : ok;
    }
    return ok;
}

- (id)validRequestorForSendType:(id)aType returnType:(id)aType2
{
    id pvVar1_2;

    if (![aType2 isEqualToString:NSTIFFPboardType]) {
        pvVar1_2 = [super validRequestorForSendType:aType returnType:aType2];
    }
    else {
        pvVar1_2 = [self cardView];
    }
    return pvVar1_2;
}

- (BOOL)actionShouldWaitForFinishingSwitchToEditModeBeforeExecution:(SEL)aExecution
{
    if (@selector(showStackOptionsDialog:) == aExecution) {
        if (![[self document] isStackProtected]) {
            return YES;
        }
    }
    if (((@selector(showCardOptionsDialog:) != aExecution) && (@selector(editStackActions:) != aExecution)) && (@selector(editCardActions:) != aExecution)) {
        return @selector(paste:) == aExecution;
    }
    return YES;
}

- (BOOL)actionRequiresConditionalPreprocessingBeforeSwitchToEditMode:(SEL)aMode
{
    if (((((((@selector(addWebCamObject:) != aMode) && (@selector(addButtonObject:) != aMode)) && (@selector(addMediaObject:) != aMode)) && ((@selector(addSoundObject:) != aMode && (@selector(addGraphic:) != aMode)))) && ((@selector(addGraphicObject:) != aMode && ((@selector(importBackground:) != aMode && (@selector(eraseBackground:) != aMode)))))) && (@selector(runSoundRecordingPanel:) != aMode)) && (((((@selector(runVideoRecordingPanel:) != aMode && (@selector(titleCard:) != aMode)) && (@selector(runEasyLinkDialog:) != aMode)) && (((@selector(runMakeEveryCardNextCardExtra:) != aMode && (@selector(addMovieComboObject:) != aMode)) && ((@selector(addSoundComboObject:) != aMode && ((@selector(showYouTubeDialog:) != aMode && (@selector(importText:) != aMode)))) )))) && ((@selector(sameBackground:) != aMode && (@selector(makeGroupCard:) != aMode)))))) {
        return @selector(captureImage:) == aMode;
    }
    return YES;
}

- (id)windowWillReturnFieldEditor:(id)aEditor toObject:(id)aObject
{
    id pvVar1_2;
    id pvVar2_2;

    if (![aObject isKindOfClass:[NSTextField class]]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar2_2 = _fieldEditor;
        if (pvVar2_2 == nil) {
            pvVar2_2 = [HSNonOpaqueTextView new];
            _fieldEditor = pvVar2_2;
        }
        [pvVar2_2 setFieldEditor:YES];
        pvVar1_2 = _fieldEditor;
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001584f @ 0001584f, 526 bytes * /

void FUN_0001584f(HSEditorWindowController *self,SEL _cmd,id webcamWorkshopSheetDidEnd,
                 int returnCode,void *contextInfo,BOOL invalidWebCamsWasPresent)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  
  if (returnCode == 1) {
    pvVar1 = _objc_msgSend(contextInfo,sel_count);
    if (0 < (int)pvVar1) {
      pvVar2 = _objc_msgSend(self,sel_document);
      pvVar2 = _objc_msgSend(pvVar2,
                             sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
      if ((char)pvVar2 != '\0') {
        iVar4 = 0;
        do {
          pvVar2 = _objc_msgSend(contextInfo,sel_objectAtIndex_,iVar4);
          pvVar3 = _objc_msgSend(self,sel_cardView);
          _objc_msgSend(pvVar3,sel_addObjectToCenter_useDragPreferences_,pvVar2,0);
          _objc_msgSend(self,sel_didAddNewObject);
          iVar4 = iVar4 + 1;
        } while (iVar4 < (int)pvVar1);
      }
    }
    self_00 = cls_NSAlert;
    if (invalidWebCamsWasPresent != '\0') {
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                             &cfstr_Some_of_imported_Web_Cams_are_invalid_and_will_b,&cfstr_empty,
                             &cfstr_Alerts);
      pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                             &cfstr_Alerts);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_Cannot_perform_action,&cfstr_empty,&cfstr_Alerts);
      pvVar1 = _objc_msgSend(self_00,
                             sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                             ,pvVar3,pvVar2,0,0,pvVar1);
      _objc_msgSend(pvVar1,sel_runModal);
    }
  }
  return;
}

*/
- (void)webcamWorkshopSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo invalidWebCamsWasPresent:(BOOL)aPresent
{
    if (aCode == 1) {
        NSArray *webcams = (NSArray *)aInfo;
        NSInteger count = [webcams count];
        if (count > 0 && [[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
            for (NSInteger index = 0; index < count; index++) {
                [[self cardView] addObjectToCenter:[webcams objectAtIndex:index] useDragPreferences:NO];
                [self didAddNewObject];
            }
        }
        if (aPresent) {
            HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
            NSAlert *alert = [NSAlert alertWithMessageText:[provider localizedStringForKey:@"Cannot perform action" value:@"" table:@"Alerts"]
                                             defaultButton:[provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"]
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:[provider localizedStringForKey:@"Some of imported Web Cams are invalid and will be removed." value:@"" table:@"Alerts"]];
            [alert runModal];
        }
    }
}

- (void)videoRecordingSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self videoRecordingDidEndWithCode:aCode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00029e4a @ 00029e4a, 1670 bytes * /

void FUN_00029e4a(HSEditorWindowController *self,SEL _cmd,int videoRecordingDidEndWithCode)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  float extraout_EDX;
  float extraout_EDX_00;
  bool bVar7;
  longdouble lVar8;
  longdouble lVar9;
  SEL op;
  undefined8 in_stack_ffffffbc;
  undefined4 uVar12;
  undefined8 uVar10;
  cfstringStruct *pcVar13;
  ulonglong uVar11;
  undefined8 in_stack_ffffffc4;
  uint uVar15;
  longlong lVar14;
  
  uVar15 = (uint)((ulonglong)in_stack_ffffffc4 >> 0x20);
  uVar12 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  pvVar1 = _objc_msgSend(self->_videoRecordingController,sel_fileName);
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  uVar10 = CONCAT44(uVar12,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,pvVar1);
  if (videoRecordingDidEndWithCode == 1) {
    bVar7 = true;
  }
  else {
    pvVar5 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar10);
    uVar12 = *(undefined4 *)PTR_0033609c;
    uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),uVar12);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_,uVar12);
    pvVar5 = _objc_msgSend(pvVar5,sel_intValue);
    if (((char)pvVar2 == '\0') || (pvVar5 != (id)0x0)) {
      bVar7 = false;
    }
    else {
      pvVar5 = _objc_msgSend(cls_HSAlert,sel_new,uVar10);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,
                             &cfstr_Add_recorded_video_to_the_card_,&cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar5,sel_setMessageText_,pvVar6);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,
                             &cfstr_If_you_do_not_add_your_recorded_video_to_the_car,&cfstr_empty,
                             &cfstr_Alerts);
      _objc_msgSend(pvVar5,sel_setInformativeText_,pvVar6);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Add_to_Card,
                             &cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar5,sel_addButtonWithTitle_,pvVar6);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Discard_Video,
                             &cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar5,sel_addButtonWithTitle_,pvVar6);
      pvVar6 = _objc_msgSend(cls_NSButton,sel_alloc);
      uVar10 = *(undefined8 *)(PTR_00336078 + 8);
      pvVar6 = _objc_msgSend(pvVar6,sel_initWithFrame_,*(undefined8 *)PTR_00336078,uVar10);
      uVar15 = (uint)((ulonglong)uVar10 >> 0x20);
      _objc_msgSend(pvVar6,sel_setButtonType_,3);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar13 = &cfstr_empty;
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_Don_t_show_this_message_again,&cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar6,sel_setTitle_,pvVar3);
      uVar10 = CONCAT44(pcVar13,pvVar6);
      _objc_msgSend(pvVar5,sel_setCustomView_,pvVar6);
      pvVar3 = _objc_msgSend(pvVar5,sel_runModal);
      bVar7 = pvVar3 == (id)0x3e8;
      pvVar3 = _objc_msgSend(pvVar6,sel_state);
      if (pvVar3 == (id)0x1) {
        pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar10);
        pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
        uVar10 = CONCAT44(uVar12,pvVar4);
        _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar4,uVar12);
      }
      _objc_msgSend(pvVar6,sel_release,uVar10);
      _objc_msgSend(pvVar5,sel_release);
    }
  }
  self_00 = cls_HSNewMedia;
  if ((char)pvVar2 != '\0') {
    if (bVar7) {
      pvVar2 = _objc_msgSend(self,sel_generateUniqueVideoRecordName,uVar10);
      pvVar1 = _objc_msgSend(self_00,sel_mediaWithPath_name_removeWhenDone_,pvVar1,pvVar2,1);
      pvVar1 = _objc_msgSend(cls_HSDocument,sel_userObjectWithMedia_,pvVar1);
      pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003619d4);
      pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
      _objc_msgSend(pvVar2,sel_resizeToWidth_maintainAspectRatio_withLayoutGuidingContext_,
                    0x43960000,3,0);
      pvVar5 = _objc_msgSend(self,sel_document);
      pvVar5 = _objc_msgSend(pvVar5,sel_stack);
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperCardSize);
      pvVar6 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003617a4);
      pvVar6 = _objc_msgSend(pvVar6,sel_size);
      lVar8 = (longdouble)_ceilf((extraout_EDX - extraout_EDX_00) * 0.5);
      lVar9 = (longdouble)_ceilf(((float)pvVar5 - (float)pvVar6) * 0.5);
      uVar10 = CONCAT44((float)lVar8,(float)lVar9);
      lVar14 = (ulonglong)uVar15 << 0x20;
      _objc_msgSend(pvVar2,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,(float)lVar9,
                    (float)lVar8,0);
      pvVar2 = _objc_msgSend(self,sel_document);
      pvVar2 = _objc_msgSend(pvVar2,
                             sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
      if ((char)pvVar2 == '\0') {
        return;
      }
      pvVar2 = _objc_msgSend(self,sel_document,uVar10,lVar14);
      uVar12 = (undefined4)((ulonglong)uVar10 >> 0x20);
      pvVar2 = _objc_msgSend(pvVar2,sel_currentCard);
      uVar11 = CONCAT44(uVar12,pvVar1);
      op = sel_addHyperChild_;
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar10);
      uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),pvVar1);
      pvVar2 = _objc_msgSend(pvVar2,sel_isDeletableFileAtPath_,pvVar1);
      if ((char)pvVar2 == '\0') {
        return;
      }
      pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar10);
      uVar11 = ZEXT48(pvVar1);
      op = sel_removeFileAtPath_handler_;
    }
    _objc_msgSend(pvVar2,op,uVar11);
  }
  return;
}

*/
- (void)videoRecordingDidEndWithCode:(NSInteger)aCode
{
    NSString *fileName = [_videoRecordingController fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:fileName];
    BOOL add;
    if (aCode == 1) {
        add = YES;
    } else if (exists && [[[NSUserDefaults standardUserDefaults] objectForKey:HSCancelVideoRecordConfirmationAlert] intValue] == 0) {
        add = HSEditorRunRecordingConfirmationAlert(@"Add recorded video to the card?", @"If you do not add your recorded video to the card, it will be erased. This cannot be undone.", @"Discard Video", HSCancelVideoRecordConfirmationAlert);
    } else {
        add = NO;
    }
    if (!exists) {
        return;
    }
    if (add) {
        id media = [HSNewMedia mediaWithPath:fileName name:[self generateUniqueVideoRecordName] removeWhenDone:YES];
        id object = [HSDocument userObjectWithMedia:media];
        id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        [applier resizeToWidth:300.0f maintainAspectRatio:3 withLayoutGuidingContext:nil];
        NSSize cardSize = [[[self document] stack] hyperCardSize];
        NSSize objectSize = [[object queryHyperInterface:@protocol(HSGeometryAttributes)] size];
        float x = ceilf((cardSize.width - objectSize.width) * 0.5f);
        float y = ceilf((cardSize.height - objectSize.height) * 0.5f);
        [applier moveFrameBoundingRectOriginTo:NSMakePoint(x, y) withLayoutGuidingContext:nil];
        if (![[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
            return;
        }
        [[[self document] currentCard] addHyperChild:object];
    } else if ([fileManager isDeletableFileAtPath:fileName]) {
        [fileManager removeFileAtPath:fileName handler:nil];
    }
}

- (void)soundRecordingDidEndSheet:(id)aSheet returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self soundRecordingDidEndWithCode:aCode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00015150 @ 00015150, 1701 bytes * /

void FUN_00015150(HSEditorWindowController *self,SEL _cmd,int soundRecordingDidEndWithCode)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  HSEditorWindowController *self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  int extraout_EDX;
  SEL op;
  bool bVar8;
  undefined8 in_stack_ffffffbc;
  undefined4 uVar11;
  undefined8 uVar9;
  undefined4 uVar12;
  cfstringStruct *pcVar13;
  ulonglong uVar10;
  
  uVar11 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  pvVar3 = _objc_msgSend(self->_soundRecordingController,sel_fileName);
  self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  uVar9 = CONCAT44(uVar11,pvVar3);
  pvVar4 = _objc_msgSend(self_00,sel_fileExistsAtPath_,pvVar3);
  cVar2 = (char)pvVar4;
  if (soundRecordingDidEndWithCode == 1) {
    bVar8 = true;
LAB_000155ad:
    if ((bVar8) && (cVar2 != '\0')) {
      pvVar4 = _objc_msgSend(self,sel_document,uVar9);
      uVar11 = (undefined4)((ulonglong)uVar9 >> 0x20);
      pvVar4 = _objc_msgSend(pvVar4,
                             sel_prepareForHandlingActionThatRequiresConditionalSwitchToEditMode);
      if ((char)pvVar4 == '\0') {
        return;
      }
      pvVar4 = _objc_msgSend(self->_soundRecordingController,sel_fileName);
      uVar9 = CONCAT44(uVar11,pvVar4);
      pvVar4 = _objc_msgSend(self_00,sel_fileExistsAtPath_,pvVar4);
      puVar1 = cls_NSString;
      if ((char)pvVar4 == '\0') {
        return;
      }
      pvVar4 = _objc_msgSend(pvVar3,sel_pathExtension,uVar9);
      pvVar6 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
      pvVar6 = _objc_msgSend(pvVar6,sel_temporaryFolder);
      pvVar7 = _objc_msgSend(cls_HSUID,sel_UID);
      pvVar7 = _objc_msgSend(pvVar7,sel_stringValue);
      pvVar6 = _objc_msgSend(pvVar6,sel_stringByAppendingPathComponent_,pvVar7);
      pvVar4 = _objc_msgSend(puVar1,sel_extraCreateUniqueFilename_extension_,pvVar6,pvVar4);
      _objc_msgSend(self_00,sel_copyPath_toPath_handler_,pvVar3,pvVar4,0);
      pvVar6 = _objc_msgSend(self,sel_document);
      puVar1 = cls_HSNewMedia;
      pvVar3 = _objc_msgSend(self,sel_generateUniqueSoundRecordName);
      pvVar4 = _objc_msgSend(puVar1,sel_mediaWithPath_name_removeWhenDone_,pvVar4,pvVar3,1);
      pvVar4 = _objc_msgSend(pvVar6,sel_userActionWithMedia_,pvVar4);
      op = sel_addActionToActorOfActiveCard_;
      if (self->_playSoundActionEvent != (id)0x0) {
        op = sel_addActionToActorOfActiveCard_ofEvent_;
        pvVar3 = self->_playSoundActionEvent;
      }
      uVar10 = CONCAT44(pvVar3,pvVar4);
      self_00 = self;
      goto LAB_000157cf;
    }
  }
  else {
    pvVar4 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar9);
    uVar12 = 0;
    pvVar4 = _objc_msgSend(pvVar4,sel_fileAttributesAtPath_traverseLink_,pvVar3,0);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,*(undefined4 *)PTR_0033614c);
    pvVar6 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    uVar11 = *(undefined4 *)PTR_00336098;
    uVar9 = CONCAT44(uVar12,uVar11);
    pvVar6 = _objc_msgSend(pvVar6,sel_objectForKey_,uVar11);
    pvVar6 = _objc_msgSend(pvVar6,sel_intValue);
    if (((pvVar6 == (id)0x0) && (cVar2 != '\0')) &&
       (pvVar4 = _objc_msgSend(pvVar4,sel_unsignedLongLongValue,uVar9),
       extraout_EDX != 0 || pvVar4 != (id)0x0)) {
      pvVar4 = _objc_msgSend(cls_HSAlert,sel_new,uVar9);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,
                             &cfstr_Add_recorded_sound_to_the_card_,&cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar4,sel_setMessageText_,pvVar6);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,
                             &cfstr_If_you_do_not_add_your_recorded_sound_to_the_car,&cfstr_empty,
                             &cfstr_Alerts);
      _objc_msgSend(pvVar4,sel_setInformativeText_,pvVar6);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Add_to_Card,
                             &cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar4,sel_addButtonWithTitle_,pvVar6);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Discard_Sound,
                             &cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar4,sel_addButtonWithTitle_,pvVar6);
      pvVar6 = _objc_msgSend(cls_NSButton,sel_alloc);
      pvVar6 = _objc_msgSend(pvVar6,sel_initWithFrame_,*(undefined8 *)PTR_00336078,
                             *(undefined8 *)(PTR_00336078 + 8));
      _objc_msgSend(pvVar6,sel_setButtonType_,3);
      pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pcVar13 = &cfstr_empty;
      pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                             &cfstr_Don_t_show_this_message_again,&cfstr_empty,&cfstr_Alerts);
      _objc_msgSend(pvVar6,sel_setTitle_,pvVar7);
      uVar9 = CONCAT44(pcVar13,pvVar6);
      _objc_msgSend(pvVar4,sel_setCustomView_,pvVar6);
      pvVar7 = _objc_msgSend(pvVar4,sel_runModal);
      bVar8 = pvVar7 == (id)0x3e8;
      pvVar7 = _objc_msgSend(pvVar6,sel_state);
      if (pvVar7 == (id)0x1) {
        pvVar7 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar9);
        pvVar5 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
        uVar9 = CONCAT44(uVar11,pvVar5);
        _objc_msgSend(pvVar7,sel_setObject_forKey_,pvVar5,uVar11);
      }
      _objc_msgSend(pvVar6,sel_release,uVar9);
      _objc_msgSend(pvVar4,sel_release);
      goto LAB_000155ad;
    }
  }
  if (cVar2 == '\0') {
    return;
  }
  op = sel_removeFileAtPath_handler_;
  if (949.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 949.0) {
    op = sel_removeItemAtPath_error_;
  }
  uVar10 = ZEXT48(pvVar3);
LAB_000157cf:
  _objc_msgSend(self_00,op,uVar10);
  return;
}

*/
- (void)soundRecordingDidEndWithCode:(NSInteger)aCode
{
    NSString *fileName = [_soundRecordingController fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:fileName];
    BOOL add = NO;
    if (aCode == 1) {
        add = YES;
    } else {
        id fileSize = [[fileManager fileAttributesAtPath:fileName traverseLink:NO] objectForKey:NSFileSize];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:HSCancelSoundRecordConfirmationAlert] intValue] == 0 && exists && [fileSize unsignedLongLongValue] != 0) {
            add = HSEditorRunRecordingConfirmationAlert(@"Add recorded sound to the card?", @"If you do not add your recorded sound to the card, it will be erased. This cannot be undone.", @"Discard Sound", HSCancelSoundRecordConfirmationAlert);
        }
    }
    if (add && exists) {
        if (![[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
            return;
        }
        if (![fileManager fileExistsAtPath:[_soundRecordingController fileName]]) {
            return;
        }
        NSString *temporaryPath = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[HSUID UID] stringValue]];
        NSString *copyPath = [NSString extraCreateUniqueFilename:temporaryPath extension:[fileName pathExtension]];
        [fileManager copyPath:fileName toPath:copyPath handler:nil];
        id media = [HSNewMedia mediaWithPath:copyPath name:[self generateUniqueSoundRecordName] removeWhenDone:YES];
        id action = [[self document] userActionWithMedia:media];
        if (_playSoundActionEvent != nil) {
            [self addActionToActorOfActiveCard:action ofEvent:_playSoundActionEvent];
        } else {
            [self addActionToActorOfActiveCard:action];
        }
        return;
    }
    if (!exists) {
        return;
    }
    if (NSAppKitVersionNumber >= 949.0) {
        [fileManager removeItemAtPath:fileName error:NULL];
    } else {
        [fileManager removeFileAtPath:fileName handler:nil];
    }
}

- (id)generateUniqueVideoRecordName
{
    id pvVar1_3;
    id pvVar2_3;

    pvVar1_3 = [[[NSBundle mainBundle] localizedStringForKey:@"MyVideoRecord" value:@"" table:0] stringByAppendingFormat:@" %d", 1];
    pvVar2_3 = [HSMoviesInUseProvider moviesInUseForStack:[[self document] stack]];
    if ([pvVar2_3 count] != 0) {
        pvVar1_3 = [self generateUniqueRecordNameForMediaObjects:pvVar2_3];
    }
    return pvVar1_3;
}

- (id)generateUniqueSoundRecordName
{
    id pvVar1_3;
    id pvVar2_3;

    pvVar1_3 = [[[NSBundle mainBundle] localizedStringForKey:@"MySoundRecord" value:@"" table:@"AssistantPanes"] stringByAppendingFormat:@" %d", 1];
    pvVar2_3 = [HSSoundsInUseProvider soundsInUseForStack:[[self document] stack]];
    if ([pvVar2_3 count] != 0) {
        pvVar1_3 = [self generateUniqueRecordNameForMediaObjects:pvVar2_3];
    }
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00014e1e @ 00014e1e, 314 bytes * /

id FUN_00014e1e(HSEditorWindowController *self,SEL _cmd,id generateUniqueRecordNameForMediaObjects)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  undefined *puVar5;
  id pvVar6;
  
  pvVar1 = _objc_msgSend(generateUniqueRecordNameForMediaObjects,sel_lastObject);
  puVar5 = &DAT_003614e8;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003614e8);
  if (pvVar1 == (id)0x0) {
    pvVar2 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(generateUniqueRecordNameForMediaObjects,sel_lastObject,puVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_defaultRecordName);
    pvVar2 = _objc_msgSend(pvVar1,sel_stringByAppendingFormat_,&cfstr___d,1);
    pvVar1 = generateUniqueRecordNameForMediaObjects;
    pvVar6 = pvVar2;
    pvVar3 = _objc_msgSend(self,sel_mediaObjects_containsObjectWithName_,
                           generateUniqueRecordNameForMediaObjects,pvVar2);
    if ((char)pvVar3 != '\0') {
      iVar4 = 2;
      do {
        pvVar1 = _objc_msgSend(generateUniqueRecordNameForMediaObjects,sel_lastObject,pvVar1,pvVar6)
        ;
        pvVar1 = _objc_msgSend(pvVar1,sel_defaultRecordName);
        pvVar2 = _objc_msgSend(pvVar1,sel_stringByAppendingFormat_,&cfstr___d,iVar4);
        iVar4 = iVar4 + 1;
        pvVar1 = generateUniqueRecordNameForMediaObjects;
        pvVar6 = pvVar2;
        pvVar3 = _objc_msgSend(self,sel_mediaObjects_containsObjectWithName_);
      } while ((char)pvVar3 != '\0');
    }
  }
  return pvVar2;
}

*/
- (id)generateUniqueRecordNameForMediaObjects:(id)aObjects
{
    if ([[aObjects lastObject] queryHyperInterface:@protocol(HSRecordAttributes)] == nil) {
        return nil;
    }
    NSInteger index = 1;
    NSString *name = [[[aObjects lastObject] defaultRecordName] stringByAppendingFormat:@" %d", (int)index];
    while ([self mediaObjects:aObjects containsObjectWithName:name]) {
        index++;
        name = [[[aObjects lastObject] defaultRecordName] stringByAppendingFormat:@" %d", (int)index];
    }
    return name;
}

- (BOOL)mediaObjects:(id)aObjects containsObjectWithName:(id)aName
{
    NSEnumerator *self_00;
    id pvVar1;
    id pvVar2;
    BOOL pvVar1_3;

    self_00 = [aObjects objectEnumerator];
    do {
        do {
            pvVar1 = [self_00 nextObject];
            if (pvVar1 == nil) {
                return NO;
            }
            pvVar2 = [pvVar1 queryHyperInterface:@protocol(HSRecordAttributes)];
        } while (pvVar2 == nil);
        pvVar1_3 = [aName isEqualToString:[pvVar1 recordName]];
    } while (!pvVar1_3);
    return YES;
}

- (id)webcamWorkshopController
{
    HSWebcamWorkshopController *pHVar1;
    HSWebcamWorkshopController *pHVar1_2;

    pHVar1 = _webcamWorkshopController;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSWebcamWorkshopController new];
        _webcamWorkshopController = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _webcamWorkshopController;
    }
    return pHVar1;
}

- (id)videoRecordingController
{
    HSVideoRecordingController *self_00;

    if (_videoRecordingController == nil) {
        if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
            self_00 = [HSVideoRecordingController new];
            _videoRecordingController = self_00;
            [self_00 setDelegate:self];
        }
    }
    return _videoRecordingController;
}

- (id)soundRecordingController
{
    HSSoundRecordingController *self_00;

    if (_soundRecordingController == nil) {
        if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
            self_00 = [HSSoundRecordingController new];
            _soundRecordingController = self_00;
            [self_00 setDelegate:self];
        }
    }
    return _soundRecordingController;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00014b5d @ 00014b5d, 208 bytes * /

void FUN_00014b5d(HSEditorWindowController *self,SEL _cmd,id windowDidBecomeKey)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolPaletteController,sel_sharedInstance);
  pvVar2 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_validateUserInterfaceWithView_,pvVar2);
  pvVar1 = _objc_msgSend(cls_HSCommentsAndAttributionsPaletteController,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_setDataProvider_,self);
  pvVar1 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_performSelector_withObject_afterDelay_,sel_updateCursor,0,0,0);
  return;
}

*/
- (void)windowDidBecomeKey:(id)aKey
{
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:[self cardView]];
    [[HSCommentsAndAttributionsPaletteController sharedInstance] setDataProvider:self];
    [[self cardView] performSelector:@selector(updateCursor) withObject:nil afterDelay:0];
}

- (BOOL)isSnapToObjectsEnabled
{
    return (BOOL)[[[[self document] stack] guidelinesSettings] isSnapToObjectsEnabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00014aa3 @ 00014aa3, 89 bytes * /

void FUN_00014aa3(HSEditorWindowController *self,SEL _cmd)

{
  id self_00;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_stackView);
  op = sel_hideStripAndEnable_;
  if (self->_wasMediaStripVisible != '\0') {
    op = sel_showStripAndEnable_;
  }
  _objc_msgSend(self_00,op,1);
  return;
}

*/
- (void)restoreMediaStripState
{
    if (_wasMediaStripVisible) {
        [[self stackView] showStripAndEnable:YES];
    } else {
        [[self stackView] hideStripAndEnable:YES];
    }
}

- (void)saveMediaStripStateHideAndDisable
{
    id self_00;

    self_00 = [self stackView];
    _wasMediaStripVisible = (BOOL)[self_00 isStripVisible];
    [self_00 hideStripAndEnable:NO];
}

- (BOOL)stackView:(id)aView handleKeyEventBySelector:(SEL)aSelector
{
    BOOL pvVar1;

    if (((@selector(deleteBackward:) == aSelector) || (@selector(deleteForward:) == aSelector)) && (pvVar1 = [self canDeleteSelectedObjectInSelectionHolder:aView], pvVar1)) {
        [self deleteSelectedObjectInSelectionHolder:aView];
        return YES;
    }
    return NO;
}

- (void)deleteSelectedObjectInSelectionHolder:(id)aHolder
{
    [self deleteSelectedObjectInSelectionHolder:aHolder showAlert:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000148c6 @ 000148c6, 223 bytes * /

void FUN_000148c6(HSEditorWindowController *self,SEL _cmd,id deleteSelectedObjectInSelectionHolder,
                 BOOL showAlert)

{
  id self_00;
  id pvVar1;
  undefined *puVar2;
  HSEditorWindowController *self_01;
  SEL op;
  
  self_01 = self;
  if (deleteSelectedObjectInSelectionHolder != (id)0x0) {
    self_01 = deleteSelectedObjectInSelectionHolder;
  }
  self_00 = _objc_msgSend(self_01,sel_selectedHyperObject);
  _objc_msgSend(self_00,sel_retain);
  puVar2 = &DAT_003613d0;
  pvVar1 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_003613d0);
  if ((char)pvVar1 == '\0') {
    puVar2 = &DAT_00361218;
    pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_00361218);
    _objc_msgSend(pvVar1,sel_removeFromHyperParent);
    op = sel_release;
  }
  else {
    self_00 = _objc_msgSend(self,sel_document,puVar2);
    puVar2 = (undefined *)(int)showAlert;
    op = sel_removeSelectedCardsWithAlert_;
  }
  _objc_msgSend(self_00,op,puVar2);
  return;
}

*/
- (void)deleteSelectedObjectInSelectionHolder:(id)aHolder showAlert:(BOOL)aAlert
{
    id object = [(aHolder != nil ? aHolder : self) selectedHyperObject];
    [object retain];
    if ([object implementsHyperInterface:@protocol(HSCardAttributes)]) {
        [[self document] removeSelectedCardsWithAlert:aAlert];
    } else {
        [[object queryHyperInterface:@protocol(HSNodeChild)] removeFromHyperParent];
        [object release];
    }
}

- (BOOL)canDeleteSelectedObjectInSelectionHolder:(id)aHolder
{
    id pvVar2;
    HSEditorWindowController *self_00;
    id pvVar1_7;
    BOOL pvVar1_8;

    if (![[self document] isStackProtected]) {
        if ([[[self document] navigationController] currentNavigationOperation] == nil) {
            self_00 = self;
            if (aHolder != nil) {
                self_00 = aHolder;
            }
            pvVar1_7 = [[self_00 selectedHyperObject] queryHyperInterface:@protocol(HSNodeChild)];
            pvVar2 = [pvVar1_7 hyperParent];
            if ([[self cardView] isEditable]) {
                pvVar1_8 = [pvVar1_7 isRoot];
                return !pvVar1_8 && pvVar2 != nil;
            }
        }
    }
    return NO;
}

- (id)stackTextProvider
{
    HSStackTextProvider *pHVar3;

    pHVar3 = _stackTextProvider;
    if (pHVar3 == nil) {
        pHVar3 = [[[HSStackTextProvider alloc] initWithWindowController:self selectionController:[self selectionController]] queryHyperInterface:@protocol(HSTextObjectDataSource)];
        _stackTextProvider = pHVar3;
    }
    return pHVar3;
}

- (id)selectedUserObject
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self selectedHyperObject];
    if (![pvVar1 implementsHyperInterface:@protocol(HSObjectAttributes)]) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [pvVar1 queryHyperInterface:@protocol(HSObjectAttributes)];
    }
    return pvVar1_2;
}

- (id)selectedCards
{
    return [[self selectedCard] allHyperInterfaces];
}

- (id)selectedCard
{
    id self_00;
    BOOL pvVar1;
    id pvVar2;

    self_00 = [self selectedHyperObject];
    pvVar1 = [self_00 implementsHyperInterface:@protocol(HSCardAttributes)];
    pvVar2 = nil;
    if (pvVar1) {
        pvVar2 = self_00;
    }
    return pvVar2;
}

- (id)selectedCardObject
{
    id self_00;
    BOOL pvVar1;
    id pvVar2;

    self_00 = [self selectedHyperObject];
    pvVar1 = [self_00 implementsHyperInterface:@protocol(HSCardObjectAttributes)];
    pvVar2 = nil;
    if (pvVar1) {
        pvVar2 = self_00;
    }
    return pvVar2;
}

- (void)notifyWillClose:(id)aClose
{
    [[self selectionController] noteWindowControllerWillClose];
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:nil];
    [super notifyWillClose:aClose];
}

- (void)HSEditorWindowController_HSUIModeSettingsDidChangeNotification:(id)aNotification
{
    BOOL pvVar1_6;

    [self setBottomToolbarVisible:[[[HSUI sharedUI] settingsForKey:HSUIModeIsBottomToolbarShown] boolValue]];
    pvVar1_6 = [[[HSUI sharedUI] settingsForKey:HSUIModeIsToolbarShown] boolValue];
    if ([[[self toolbarController] toolbar] isVisible] != pvVar1_6) {
        [self hideShowToolbar:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002a566 @ 0002a566, 1452 bytes * /

void FUN_0002a566(HSEditorWindowController *self,SEL _cmd,id windowWillClose)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  int *piVar4;
  HSEditorWindowController *local_2c;
  undefined *local_28;
  undefined1 local_24 [20];
  
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_fileURL);
  pvVar2 = _objc_msgSend(pvVar2,sel_path);
  piVar4 = (int *)&stack0xffffff84;
  if ((pvVar2 != (id)0x0) &&
     (pvVar2 = _objc_msgSend(self,sel_window), piVar4 = (int *)&stack0xffffff84, pvVar2 != (id)0x0))
  {
    pvVar2 = _objc_msgSend(self->_cardScrollView,sel_documentView);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_cardOffset);
    }
    pvVar2 = _objc_msgSend(self->_cardScrollView,sel_contentView);
    _objc_msgSend_stret(local_24,pvVar2,sel_bounds);
    piVar4 = (int *)&stack0xffffff80;
    pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
    pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(cls_HSUI,sel_sharedUI);
      _objc_msgSend(pvVar2,sel_removeObserver_name_object_);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(cls_HSUI,sel_sharedUI);
      _objc_msgSend(pvVar2,sel_removeObserver_name_object_);
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_alloc);
      _NSStringFromPoint();
      pvVar3 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar3,sel_stringWithSavedFrame);
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_alloc);
      _NSStringFromPoint();
      puVar1 = cls_NSNumber;
      pvVar3 = _objc_msgSend(self,sel_stackView);
      _objc_msgSend(pvVar3,sel_isStripVisible);
      _objc_msgSend(puVar1,sel_numberWithBool_);
      puVar1 = cls_NSNumber;
      _objc_msgSend(self,sel_isBottomToolbarVisible);
      _objc_msgSend(puVar1,sel_numberWithBool_);
      puVar1 = cls_NSNumber;
      pvVar3 = _objc_msgSend(self,sel_toolbarController);
      pvVar3 = _objc_msgSend(pvVar3,sel_toolbar);
      _objc_msgSend(pvVar3,sel_isVisible);
      _objc_msgSend(puVar1,sel_numberWithBool_);
      pvVar3 = _objc_msgSend(self,sel_window);
      _objc_msgSend(pvVar3,sel_stringWithSavedFrame);
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithObjectsAndKeys_);
    puVar1 = cls_NSMutableDictionary;
    pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    _objc_msgSend(pvVar3,sel_objectForKey_);
    pvVar3 = _objc_msgSend(puVar1,sel_dictionaryWithDictionary_);
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
    }
    _objc_msgSend(pvVar3,sel_setObject_forKey_);
    pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    _objc_msgSend(pvVar3,sel_setObject_forKey_);
    pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    _objc_msgSend(pvVar3,sel_synchronize);
    _objc_msgSend(pvVar2,sel_release);
  }
  local_2c = self;
  local_28 = PTR_s_HSMainWindowController_0034dbd0;
  piVar4[2] = (int)windowWillClose;
  piVar4[1] = (int)sel_windowWillClose_;
  *piVar4 = (int)&local_2c;
  piVar4[-1] = 0x2ab0a;
  _objc_msgSendSuper((void *)*piVar4,(SEL)piVar4[1]);
  return;
}

*/
- (void)windowWillClose:(id)aClose
{
    NSString *path = [[[self document] fileURL] path];
    if (path != nil && [self window] != nil) {
        id host = [[_cardScrollView documentView] queryHyperInterface:@protocol(HSEditorCardViewBackgroundHost)];
        NSSize cardOffset = (host != nil) ? [host cardOffset] : NSZeroSize;
        NSRect bounds = [[_cardScrollView contentView] bounds];
        NSPoint scrollPoint = NSMakePoint(bounds.origin.x - cardOffset.width, bounds.origin.y - cardOffset.height);
        NSDictionary *state;
        if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
            state = [[NSDictionary alloc] initWithObjectsAndKeys:NSStringFromPoint(scrollPoint), @"HSEditorScrollPointKey",
                     [[self window] stringWithSavedFrame], HSMainWindowFrameAsStringAttributeKey, nil];
        } else {
            state = [[NSDictionary alloc] initWithObjectsAndKeys:NSStringFromPoint(scrollPoint), @"HSEditorScrollPointKey",
                     [NSNumber numberWithBool:[[self stackView] isStripVisible]], @"HSCardBrowserVisibleKey",
                     [NSNumber numberWithBool:[self isBottomToolbarVisible]], @"HSBottomToolbarVisibleKey",
                     [NSNumber numberWithBool:[[[self toolbarController] toolbar] isVisible]], @"HSToolbarVisibleKey",
                     [[self window] stringWithSavedFrame], HSMainWindowFrameAsStringAttributeKey, nil];
        }
        NSMutableDictionary *states = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:HSDocumentWindowStates]];
        if (states == nil) {
            states = [NSMutableDictionary dictionary];
        }
        [states setObject:state forKey:path];
        [[NSUserDefaults standardUserDefaults] setObject:states forKey:HSDocumentWindowStates];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [state release];
    }
    [super windowWillClose:aClose];
}

- (void)notifyDidBecomeMain:(id)aMain
{
    [self refreshToolManager];
    [[self selectionController] noteWindowControllerDidBecomeMain];
    [super notifyDidBecomeMain:aMain];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001440a @ 0001440a, 161 bytes * /

void FUN_0001440a(HSEditorWindowController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(pvVar2,sel_selectToolWithTag_,0);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(pvVar2,sel_selectToolWithTag_,pvVar1);
  return;
}

*/
- (void)refreshToolManager
{
    NSInteger tag = [[HSToolManager sharedToolManager] selectedToolTag];
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
    [[HSToolManager sharedToolManager] selectToolWithTag:tag];
}

- (id)selectionController
{
    return [[self document] selectionController];
}

- (id)documentSelectionSync
{
    return [[self document] selectionSync];
}

- (id)selectedHyperObject
{
    return [[self document] selectedHyperObject];
}

- (id)windowWillReturnUndoManager:(id)aManager
{
    id pvVar1_4;

    pvVar1_4 = [[[[HSObjectAssistantController sharedAssistantController] objectAssistant] currentPane] assistantPaneUndoManager];
    if (pvVar1_4 == nil) {
        pvVar1_4 = [[self document] undoManager];
    }
    return pvVar1_4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000141c5 @ 000141c5, 267 bytes * /

void FUN_000141c5(HSEditorWindowController *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  float extraout_EDX;
  undefined *puVar4;
  id local_14;
  float local_10;
  
  pvVar3 = _objc_msgSend(self,sel_cardScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_documentView);
  puVar4 = &DAT_003612b8;
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003612b8);
  if (pvVar3 == (id)0x0) {
    local_14 = *(id *)PTR_0033607c;
    local_10 = *(float *)(PTR_0033607c + 4);
  }
  else {
    local_14 = _objc_msgSend(pvVar3,sel_cardOffset,puVar4);
    local_10 = extraout_EDX;
  }
  fVar1 = (self->_originPositionOnCard).x;
  fVar2 = (self->_originPositionOnCard).y;
  pvVar3 = _objc_msgSend(self,sel_cardScrollView,puVar4);
  pvVar3 = _objc_msgSend(pvVar3,sel_documentView);
  _objc_msgSend(pvVar3,sel_scrollPoint_,(float)local_14 + fVar1,local_10 + fVar2);
  return;
}

*/
- (void)restoreScrollerPosition
{
    id host = [[[self cardScrollView] documentView] queryHyperInterface:@protocol(HSEditorCardViewBackgroundHost)];
    NSSize cardOffset = (host != nil) ? [host cardOffset] : NSZeroSize;
    [[[self cardScrollView] documentView] scrollPoint:NSMakePoint(cardOffset.width + _originPositionOnCard.x, cardOffset.height + _originPositionOnCard.y)];
}

- (void)saveScrollerPosition
{
    [self useScrollerPositionFrom:[self cardScrollView]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ab88 @ 0002ab88, 224 bytes * /

void FUN_0002ab88(HSEditorWindowController *self,SEL _cmd,id useScrollerPositionFrom)

{
  id pvVar1;
  float extraout_EDX;
  undefined *puVar2;
  id local_2c;
  float local_28;
  float local_24;
  float local_20;
  
  pvVar1 = _objc_msgSend(useScrollerPositionFrom,sel_documentView);
  puVar2 = &DAT_003612b8;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003612b8);
  if (pvVar1 == (id)0x0) {
    local_2c = *(id *)PTR_0033607c;
    local_28 = *(float *)(PTR_0033607c + 4);
  }
  else {
    local_2c = _objc_msgSend(pvVar1,sel_cardOffset,puVar2);
    local_28 = extraout_EDX;
  }
  pvVar1 = _objc_msgSend(useScrollerPositionFrom,sel_contentView,puVar2);
  _objc_msgSend_stret(&local_24,pvVar1,sel_bounds);
  (self->_originPositionOnCard).x = local_24 - (float)local_2c;
  (self->_originPositionOnCard).y = local_20 - local_28;
  return;
}

*/
- (void)useScrollerPositionFrom:(id)aFrom
{
    id host = [[aFrom documentView] queryHyperInterface:@protocol(HSEditorCardViewBackgroundHost)];
    NSSize cardOffset = (host != nil) ? [host cardOffset] : NSZeroSize;
    NSRect bounds = [[aFrom contentView] bounds];
    _originPositionOnCard.x = bounds.origin.x - cardOffset.width;
    _originPositionOnCard.y = bounds.origin.y - cardOffset.height;
}

- (void)saveEditingState
{
    [[self cardView] saveEditingState];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ac68 @ 0002ac68, 240 bytes * /

NSRect * FUN_0002ac68(NSRect *__return_storage_ptr__,HSEditorWindowController *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(&local_2c,pvVar1,sel_frame);
  pvVar1 = _objc_msgSend(self->_cardScrollView,sel_documentView);
  _objc_msgSend_stret(local_1c,pvVar1,sel_frame);
  pvVar1 = _objc_msgSend(self->_cardScrollView,sel_contentSize);
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = local_28;
  (__return_storage_ptr__->size).width = (local_14 - (float)pvVar1) + local_24;
  (__return_storage_ptr__->size).height = (local_10 - extraout_EDX) + local_20;
  return __return_storage_ptr__;
}

*/
- (NSRect)bestWindowFrameForCurrentStack
{
    NSRect windowFrame = [[self window] frame];
    NSRect documentFrame = [[_cardScrollView documentView] frame];
    NSSize contentSize = [(NSScrollView *)_cardScrollView contentSize];
    return NSMakeRect(windowFrame.origin.x, windowFrame.origin.y, (documentFrame.size.width - contentSize.width) + windowFrame.size.width, (documentFrame.size.height - contentSize.height) + windowFrame.size.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ad58 @ 0002ad58, 414 bytes * /

void FUN_0002ad58(HSEditorWindowController *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined4 local_3c;
  undefined4 uStack_38;
  float local_34;
  float fStack_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  float local_24;
  float fStack_20;
  undefined4 local_1c;
  undefined4 local_18;
  float local_14;
  float local_10;
  
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_screen);
  _objc_msgSend_stret(&local_1c,pvVar2,sel_visibleFrame);
  pvVar2 = _objc_msgSend(self,sel_window);
  _objc_msgSend_stret(&local_2c,pvVar2,sel_frame);
  local_3c = local_2c;
  uStack_38 = uStack_28;
  local_34 = local_24;
  fStack_30 = fStack_20;
  if (local_14 < local_24) {
    local_3c = local_1c;
  }
  if (local_10 < fStack_20) {
    uStack_38 = local_18;
  }
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_screen);
  _objc_msgSend_stret(&local_3c,self,sel_constrainSizeOfWindowFrame_forScreen_,
                      CONCAT44(uStack_38,local_3c),CONCAT44(fStack_30,local_34),pvVar2);
  cVar1 = _NSEqualRects(CONCAT44(uStack_28,local_2c),CONCAT44(fStack_20,local_24),
                        CONCAT44(uStack_38,local_3c),CONCAT44(fStack_30,local_34));
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_setFrame_display_,CONCAT44(uStack_38,local_3c),
                  CONCAT44(fStack_30,local_34),0);
  }
  return;
}

*/
- (void)adjustWindowFrameAfterToolbarVisibilityValidation
{
    NSRect visibleFrame = [[[self window] screen] visibleFrame];
    NSRect frame = [[self window] frame];
    NSRect newFrame = frame;
    if (visibleFrame.size.width < frame.size.width) {
        newFrame.origin.x = visibleFrame.origin.x;
    }
    if (visibleFrame.size.height < frame.size.height) {
        newFrame.origin.y = visibleFrame.origin.y;
    }
    newFrame = [self constrainSizeOfWindowFrame:newFrame forScreen:[[self window] screen]];
    if (!NSEqualRects(frame, newFrame)) {
        [[self window] setFrame:newFrame display:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002aef6 @ 0002aef6, 2219 bytes * /

void FUN_0002aef6(HSEditorWindowController *self,SEL _cmd)

{
  HSEditorCardView *pHVar1;
  undefined4 uVar2;
  char cVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  HSEditorWindowController *self_00;
  int extraout_EDX;
  float extraout_EDX_00;
  int *piVar9;
  int *piVar10;
  NSPoint NVar11;
  undefined4 auStack_9c [3];
  SEL pcVar12;
  undefined4 auStack_84 [11];
  id local_58;
  float local_54;
  float fStack_50;
  undefined8 local_4c;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  piVar9 = (int *)&stack0xffffff74;
  pvVar5 = _objc_msgSend(self,sel_document);
  local_58 = _objc_msgSend(cls_NSDictionary,sel_dictionary);
  pvVar6 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar6 = _objc_msgSend(pvVar6,sel_objectForKey_);
  pvVar5 = _objc_msgSend(pvVar5,sel_fileURL);
  pvVar5 = _objc_msgSend(pvVar5,sel_path);
  if ((pvVar6 != (id)0x0) && (pvVar5 != (id)0x0)) {
    local_58 = _objc_msgSend(pvVar6,sel_objectForKey_);
  }
  pvVar6 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar6 = _objc_msgSend(pvVar6,sel_defaultHomeStackPath);
  pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_);
  pvVar7 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar7 = _objc_msgSend(pvVar7,sel_defaultTutorialStackName);
  pvVar7 = _objc_msgSend(pvVar7,sel_isEqualToString_);
  pvVar8 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar8 = _objc_msgSend(pvVar8,sel_sampleProjectsFolder);
  _objc_msgSend(pvVar5,sel_stringByDeletingLastPathComponent);
  pvVar5 = _objc_msgSend(pvVar8,sel_isEqualToString_);
  if ((char)pvVar5 == '\0' && ((char)pvVar7 == '\0' && (char)pvVar6 == '\0')) {
    pvVar5 = _objc_msgSend(local_58,sel_objectForKey_);
  }
  else {
    pvVar5 = (id)0x0;
  }
  pvVar6 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar6,sel_setContentMinSize_);
  pvVar6 = _objc_msgSend(self,sel_toolbarController);
  pvVar6 = _objc_msgSend(pvVar6,sel_toolbar);
  _objc_msgSend(pvVar6,sel_setVisible_);
  pvVar6 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  pvVar6 = _objc_msgSend(pvVar6,sel_settingsForKey_);
  pvVar6 = _objc_msgSend(pvVar6,sel_boolValue);
  cVar4 = (char)pvVar6;
  pvVar6 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  pvVar6 = _objc_msgSend(pvVar6,sel_settingsForKey_);
  pvVar6 = _objc_msgSend(pvVar6,sel_boolValue);
  cVar3 = (char)pvVar6;
  pvVar6 = _objc_msgSend(cls_HSUI,sel_sharedUI);
  pvVar6 = _objc_msgSend(pvVar6,sel_settingsForKey_);
  _objc_msgSend(pvVar6,sel_boolValue);
  pvVar6 = _objc_msgSend(local_58,sel_objectForKey_);
  if (pvVar6 != (id)0x0) {
    _objc_msgSend(pvVar6,sel_boolValue);
  }
  pvVar6 = _objc_msgSend(local_58,sel_objectForKey_);
  if (pvVar6 != (id)0x0) {
    pvVar6 = _objc_msgSend(pvVar6,sel_boolValue);
    cVar4 = (char)pvVar6;
  }
  pvVar6 = _objc_msgSend(local_58,sel_objectForKey_);
  if (pvVar6 != (id)0x0) {
    pvVar6 = _objc_msgSend(pvVar6,sel_boolValue);
    cVar3 = (char)pvVar6;
  }
  _objc_msgSend(self,sel_setBottomToolbarVisible_animated_moveFrame_);
  pvVar6 = _objc_msgSend(self,sel_stackView);
  pcVar12 = sel_showStripAndEnable_;
  if (cVar4 == '\0') {
    pcVar12 = sel_hideStripAndEnable_moveFrame_;
  }
  _objc_msgSend(pvVar6,pcVar12);
  if (pvVar5 == (id)0x0) {
    pvVar5 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_);
    if (pvVar5 == (id)0x0) goto LAB_0002b43f;
    _NSRectFromString();
    pvVar5 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar5,sel_setFrame_display_);
    self_00 = self;
    pcVar12 = sel_adjustDefaultWindowSize;
  }
  else {
    _NSRectFromString();
    self_00 = _objc_msgSend(self,sel_window);
    pcVar12 = sel_setFrame_display_;
  }
  piVar9 = (int *)&stack0xffffff70;
  _objc_msgSend(self_00,pcVar12);
LAB_0002b43f:
  piVar9[1] = (int)sel_toolbarController;
  *piVar9 = (int)self;
  piVar9[-1] = 0x2b454;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[1] = (int)sel_toolbar;
  *piVar9 = (int)pvVar5;
  piVar9[-1] = 0x2b466;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[2] = (int)cVar3;
  piVar9[1] = (int)sel_setVisible_;
  *piVar9 = (int)pvVar5;
  piVar9[-1] = 0x2b480;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[2] = (int)&cfstr_HSEditorScrollPointKey;
  piVar9[1] = (int)sel_objectForKey_;
  *piVar9 = (int)local_58;
  piVar9[-1] = 0x2b49f;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  if (pvVar5 != (id)0x0) {
    *piVar9 = (int)pvVar5;
    piVar9[-1] = 0x2b4ab;
    NVar11 = (NSPoint)_NSPointFromString();
    self->_originPositionOnCard = NVar11;
  }
  pHVar1 = self->_cardView;
  piVar9[1] = (int)sel_zoomToActualSize;
  *piVar9 = (int)pHVar1;
  piVar9[-1] = 0x2b4d2;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[1] = (int)sel_window;
  *piVar9 = (int)self;
  piVar9[-1] = 0x2b4e7;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[1] = (int)sel_contentView;
  *piVar9 = (int)pvVar5;
  piVar9[-1] = 0x2b4f9;
  pvVar5 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[2] = (int)sel_frame;
  piVar9[1] = (int)pvVar5;
  *piVar9 = (int)local_24;
  piVar9[-1] = 0x2b512;
  _objc_msgSend_stret((void *)*piVar9,(id)piVar9[1],(SEL)piVar9[2]);
  piVar10 = piVar9 + -1;
  *piVar9 = (int)sel_window;
  piVar9[-1] = (int)self;
  piVar9[-2] = 0x2b53e;
  pvVar5 = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
  *piVar9 = (int)sel_mainWindowMinCardAreaSize;
  piVar9[-1] = (int)self;
  piVar9[-2] = 0x2b555;
  pvVar6 = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
  piVar9[2] = extraout_EDX;
  piVar9[1] = (int)pvVar6;
  *piVar9 = (int)sel_setContentMinSize_;
  piVar9[-1] = (int)pvVar5;
  piVar9[-2] = 0x2b56f;
  _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
  *piVar9 = (int)sel_window;
  piVar9[-1] = (int)self;
  piVar9[-2] = 0x2b584;
  pvVar5 = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
  *piVar9 = (int)sel_contentMinSize;
  piVar9[-1] = (int)pvVar5;
  piVar9[-2] = 0x2b596;
  pvVar5 = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
  if ((local_18 < extraout_EDX_00) || (local_1c < (float)pvVar5)) {
    *piVar9 = (int)sel_window;
    piVar9[-1] = (int)self;
    piVar9[-2] = 0x2b5cd;
    pvVar6 = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
    piVar9[1] = (int)sel_frame;
    *piVar9 = (int)pvVar6;
    piVar9[-1] = (int)&local_54;
    piVar9[-2] = 0x2b5fd;
    _objc_msgSend_stret((void *)piVar9[-1],(id)*piVar9,(SEL)piVar9[1]);
    piVar10 = piVar9 + -2;
    fStack_50 = (extraout_EDX_00 - local_18) * -0.5 + fStack_50;
    local_54 = ((float)pvVar5 - local_1c) * -0.5 + local_54;
    piVar9[-1] = (int)sel_window;
    piVar9[-2] = (int)self;
    piVar9[-3] = 0x2b642;
    pvVar5 = _objc_msgSend((id)piVar9[-2],(SEL)piVar9[-1]);
    *(undefined8 *)(piVar9 + 2) = local_4c;
    *(ulonglong *)piVar9 = CONCAT44(fStack_50,local_54);
    piVar9[-1] = (int)sel_setFrame_display_;
    piVar9[-2] = (int)pvVar5;
    piVar9[4] = 1;
    piVar9[-3] = 0x2b672;
    _objc_msgSend((id)piVar9[-2],(SEL)piVar9[-1]);
  }
  piVar10[1] = (int)sel_document;
  *piVar10 = (int)self;
  piVar10[-1] = 0x2b687;
  pvVar5 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
  piVar10[1] = (int)sel_setIsReadyToCreateMinimalWindowApplier;
  *piVar10 = (int)pvVar5;
  piVar10[-1] = 0x2b699;
  _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
  piVar10[1] = (int)sel_sharedDocumentController;
  *piVar10 = (int)cls_HSEditorController;
  piVar10[-1] = 0x2b6b1;
  pvVar5 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
  piVar10[1] = (int)sel_isMultiDocument;
  *piVar10 = (int)pvVar5;
  piVar10[-1] = 0x2b6c3;
  pvVar5 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
  if ((char)pvVar5 == '\0') {
    piVar10[1] = (int)sel_defaultCenter;
    *piVar10 = (int)cls_NSNotificationCenter;
    piVar10[-1] = 0x2b6e3;
    pvVar5 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    piVar10[1] = (int)sel_sharedUI;
    *piVar10 = (int)cls_HSUI;
    piVar10[-1] = 0x2b6fe;
    pvVar6 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    uVar2 = *(undefined4 *)PTR_00336130;
    piVar10[5] = (int)pvVar6;
    piVar10[4] = uVar2;
    piVar10[3] = (int)sel_HSEditorWindowController_HSUIModeSettingsDidChangeNotification_;
    piVar10[2] = (int)self;
    piVar10[1] = (int)sel_addObserver_selector_name_object_;
    *piVar10 = (int)pvVar5;
    piVar10[-1] = 0x2b734;
    _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    piVar10[1] = (int)sel_defaultCenter;
    *piVar10 = (int)cls_NSNotificationCenter;
    piVar10[-1] = 0x2b74c;
    pvVar5 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    piVar10[1] = (int)sel_sharedUI;
    *piVar10 = (int)cls_HSUI;
    piVar10[-1] = 0x2b766;
    pvVar6 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
    uVar2 = *(undefined4 *)PTR_00336120;
    piVar10[5] = (int)pvVar6;
    piVar10[4] = uVar2;
    piVar10[3] = (int)sel_HSEditorWindowController_HSUIModeSettingsDidChangeNotification_;
    piVar10[2] = (int)self;
    piVar10[1] = (int)sel_addObserver_selector_name_object_;
    *piVar10 = (int)pvVar5;
    piVar10[-1] = 0x2b799;
    _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
  }
  return;
}

*/
- (void)loadWindowSettings
{
    id document = [self document];
    NSDictionary *settings = [NSDictionary dictionary];
    id windowStates = [[NSUserDefaults standardUserDefaults] objectForKey:HSDocumentWindowStates];
    NSString *path = [[document fileURL] path];
    if (windowStates != nil && path != nil) {
        settings = [windowStates objectForKey:path];
    }
    HSPathsProvider *paths = [HSPathsProvider sharedPathsProvider];
    BOOL isHomeStack = [[paths defaultHomeStackPath] isEqualToString:path];
    BOOL isTutorialStack = [[paths defaultTutorialStackName] isEqualToString:path];
    BOOL isSampleProject = [[paths sampleProjectsFolder] isEqualToString:[path stringByDeletingLastPathComponent]];
    NSString *frameString = nil;
    if (!isSampleProject && !isTutorialStack && !isHomeStack) {
        frameString = [settings objectForKey:HSMainWindowFrameAsStringAttributeKey];
    }
    [[self window] setContentMinSize:NSZeroSize];
    [[[self toolbarController] toolbar] setVisible:NO];
    BOOL cardIndexShown = [[[HSUI sharedUI] settingsForKey:HSUIModeIsCardIndexShown] boolValue];
    BOOL toolbarShown = [[[HSUI sharedUI] settingsForKey:HSUIModeIsToolbarShown] boolValue];
    BOOL bottomToolbarShown = [[[HSUI sharedUI] settingsForKey:HSUIModeIsBottomToolbarShown] boolValue];
    id value = [settings objectForKey:@"HSBottomToolbarVisibleKey"];
    if (value != nil) {
        bottomToolbarShown = [value boolValue];
    }
    value = [settings objectForKey:@"HSCardBrowserVisibleKey"];
    if (value != nil) {
        cardIndexShown = [value boolValue];
    }
    value = [settings objectForKey:@"HSToolbarVisibleKey"];
    if (value != nil) {
        toolbarShown = [value boolValue];
    }
    [self setBottomToolbarVisible:bottomToolbarShown animated:NO moveFrame:NO];
    if (cardIndexShown) {
        [[self stackView] showStripAndEnable:YES];
    } else {
        [[self stackView] hideStripAndEnable:YES moveFrame:NO];
    }
    if (frameString != nil) {
        [[self window] setFrame:NSRectFromString(frameString) display:YES];
    } else {
        NSString *untitledFrame = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSUntitledWindowFrame"];
        if (untitledFrame != nil) {
            [[self window] setFrame:NSRectFromString(untitledFrame) display:YES];
            [self adjustDefaultWindowSize];
        }
    }
    [[[self toolbarController] toolbar] setVisible:toolbarShown];
    id scrollPoint = [settings objectForKey:@"HSEditorScrollPointKey"];
    if (scrollPoint != nil) {
        _originPositionOnCard = NSPointFromString(scrollPoint);
    }
    [_cardView zoomToActualSize];
    NSRect contentFrame = [[[self window] contentView] frame];
    [[self window] setContentMinSize:[self mainWindowMinCardAreaSize]];
    NSSize minSize = [[self window] contentMinSize];
    if (minSize.height > contentFrame.size.height || minSize.width > contentFrame.size.width) {
        NSRect windowFrame = [[self window] frame];
        windowFrame.origin.x += (minSize.width - contentFrame.size.width) * -0.5f;
        windowFrame.origin.y += (minSize.height - contentFrame.size.height) * -0.5f;
        [[self window] setFrame:windowFrame display:YES];
    }
    [[self document] setIsReadyToCreateMinimalWindowApplier];
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorWindowController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorWindowController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002b7a1 @ 0002b7a1, 1209 bytes * /

void FUN_0002b7a1(HSEditorWindowController *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  float extraout_EDX;
  float extraout_EDX_00;
  longdouble lVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  undefined *puVar9;
  undefined8 uVar8;
  undefined4 uVar10;
  float local_68;
  float local_54;
  float local_50;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  undefined1 local_34 [8];
  undefined4 local_2c;
  undefined4 local_28;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend_stret(local_34,pvVar2,sel_bounds);
  pvVar2 = _objc_msgSend(self,sel_cardView);
  puVar9 = sel_contentViewingRect;
  _objc_msgSend_stret(local_24,pvVar2,sel_contentViewingRect);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar8 = CONCAT44(puVar9,&cfstr_HSCardAreaIdealSizeHorisontalOffset);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSCardAreaIdealSizeHorisontalOffset);
  if (pvVar2 == (id)0x0) {
    local_68 = 0.0;
  }
  else {
    dVar7 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
    local_68 = (float)dVar7;
  }
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar8);
  uVar8 = CONCAT44((int)((ulonglong)uVar8 >> 0x20),&cfstr_HSCardAreaIdealSizeVerticalOffset);
  fVar5 = local_1c + local_68;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSCardAreaIdealSizeVerticalOffset);
  if (pvVar2 == (id)0x0) {
    local_68 = 0.0;
  }
  else {
    dVar7 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
    local_68 = (float)dVar7;
  }
  pvVar2 = _objc_msgSend(self,sel_cardView,uVar8);
  pvVar2 = _objc_msgSend(pvVar2,sel_convertSize_toView_,local_2c,local_28,0);
  pvVar3 = _objc_msgSend(self,sel_cardView);
  uVar8 = CONCAT44(local_18 + local_68,fVar5);
  uVar10 = 0;
  pvVar3 = _objc_msgSend(pvVar3,sel_convertSize_toView_,fVar5,local_18 + local_68,0);
  if (((float)pvVar2 != 0.0) || (NAN((float)pvVar2))) {
    fVar5 = ABS((float)pvVar2);
  }
  else {
    fVar5 = 1.0;
  }
  if (((float)pvVar3 != 0.0) || (NAN((float)pvVar3))) {
    fVar6 = ABS((float)pvVar3);
  }
  else {
    fVar6 = 1.0;
  }
  if (fVar6 <= fVar5) {
    fVar6 = fVar5;
  }
  if (ABS((float)pvVar2 - (float)pvVar3) <= fVar6 * 0.0005) {
    if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
      fVar5 = ABS(extraout_EDX);
    }
    else {
      fVar5 = 1.0;
    }
    if ((extraout_EDX_00 != 0.0) || (NAN(extraout_EDX_00))) {
      fVar6 = ABS(extraout_EDX_00);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    bVar1 = fVar6 * 0.0005 < ABS(extraout_EDX - extraout_EDX_00);
  }
  else {
    bVar1 = true;
  }
  if (((bVar1) && (0.0 < extraout_EDX_00)) && (0.0 < (float)pvVar3)) {
    self_00 = _objc_msgSend(self,sel_window,uVar8,uVar10);
    _objc_msgSend_stret(&local_44,self_00,sel_frame);
    local_3c = local_3c + ((float)pvVar3 - (float)pvVar2);
    fStack_38 = (extraout_EDX_00 - extraout_EDX) + fStack_38;
    fStack_40 = (extraout_EDX_00 - extraout_EDX) * -0.5 + fStack_40;
    local_44 = ((float)pvVar3 - (float)pvVar2) * -0.5 + local_44;
    pvVar2 = _objc_msgSend(self,sel_window);
    pvVar2 = _objc_msgSend(pvVar2,sel_screen);
    _objc_msgSend_stret(&local_54,pvVar2,sel_visibleFrame);
    if (local_44 < local_54) {
      local_44 = local_54;
    }
    if (fStack_40 < local_50) {
      fStack_40 = local_50;
    }
    fVar5 = fStack_40;
    lVar4 = (longdouble)_roundf(local_44);
    local_44 = (float)lVar4;
    lVar4 = (longdouble)_roundf(fVar5);
    fStack_40 = (float)lVar4;
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_setFrame_display_,CONCAT44(fStack_40,local_44),
                  CONCAT44(fStack_38,local_3c),1);
  }
  return;
}

*/
- (void)adjustDefaultWindowSize
{
    NSRect cardBounds = [[self cardView] bounds];
    NSRect viewingRect = [[self cardView] contentViewingRect];
    id horizontalOffset = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSCardAreaIdealSizeHorisontalOffset"];
    float horizontal = (horizontalOffset == nil) ? 0.0f : [horizontalOffset floatValue];
    float idealWidth = viewingRect.size.width + horizontal;
    id verticalOffset = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSCardAreaIdealSizeVerticalOffset"];
    float vertical = (verticalOffset == nil) ? 0.0f : [verticalOffset floatValue];
    NSSize currentSize = [[self cardView] convertSize:cardBounds.size toView:nil];
    NSSize idealSize = [[self cardView] convertSize:NSMakeSize(idealWidth, viewingRect.size.height + vertical) toView:nil];
    BOOL widthMatches = fabsf(currentSize.width - idealSize.width) <= MAX((currentSize.width != 0.0f || isnan(currentSize.width)) ? fabsf(currentSize.width) : 1.0f, (idealSize.width != 0.0f || isnan(idealSize.width)) ? fabsf(idealSize.width) : 1.0f) * 0.0005f;
    BOOL sizeChanged;
    if (widthMatches) {
        sizeChanged = MAX((currentSize.height != 0.0f || isnan(currentSize.height)) ? fabsf(currentSize.height) : 1.0f, (idealSize.height != 0.0f || isnan(idealSize.height)) ? fabsf(idealSize.height) : 1.0f) * 0.0005f < fabsf(currentSize.height - idealSize.height);
    } else {
        sizeChanged = YES;
    }
    if (sizeChanged && idealSize.height > 0.0f && idealSize.width > 0.0f) {
        NSRect frame = [[self window] frame];
        frame.size.width += idealSize.width - currentSize.width;
        frame.size.height += idealSize.height - currentSize.height;
        frame.origin.y += (idealSize.height - currentSize.height) * -0.5f;
        frame.origin.x += (idealSize.width - currentSize.width) * -0.5f;
        NSRect visibleFrame = [[[self window] screen] visibleFrame];
        if (frame.origin.x < visibleFrame.origin.x) {
            frame.origin.x = visibleFrame.origin.x;
        }
        if (frame.origin.y < visibleFrame.origin.y) {
            frame.origin.y = visibleFrame.origin.y;
        }
        frame.origin.x = roundf(frame.origin.x);
        frame.origin.y = roundf(frame.origin.y);
        [[self window] setFrame:frame display:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002bc5a @ 0002bc5a, 473 bytes * /

BOOL FUN_0002bc5a(HSEditorWindowController *self,SEL _cmd,id windowFrameFitsToScreen)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  cfstringStruct *pcVar8;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  pvVar2 = _objc_msgSend(windowFrameFitsToScreen,sel_length);
  if (pvVar2 != (id)0x0) {
    pcVar8 = &cfstr__;
    pvVar2 = _objc_msgSend(windowFrameFitsToScreen,sel_componentsSeparatedByString_,&cfstr__);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar3 < (id)0x8) {
      return '\0';
    }
    pvVar3 = _objc_msgSend(cls_NSScreen,sel_mainScreen,pcVar8);
    _objc_msgSend_stret(&local_1c,pvVar3,sel_visibleFrame);
    pvVar3 = _objc_msgSend(pvVar2,sel_objectAtIndex_,7);
    dVar7 = _objc_msgSend_fpret(pvVar3,sel_floatValue);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,6);
    fVar1 = (float)dVar7;
    dVar7 = _objc_msgSend_fpret(pvVar2,sel_floatValue);
    fVar4 = (float)dVar7;
    local_1c = local_1c + local_14;
    if ((local_1c != 0.0) || (NAN(local_1c))) {
      fVar5 = ABS(local_1c);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar4 != 0.0) || (NAN(fVar4))) {
      fVar6 = ABS(fVar4);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (fVar4 + fVar6 * -0.0005 <= local_1c) {
      local_18 = local_18 + local_10;
      if ((local_18 != 0.0) || (NAN(local_18))) {
        fVar4 = ABS(local_18);
      }
      else {
        fVar4 = 1.0;
      }
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar5 = ABS(fVar1);
      }
      else {
        fVar5 = 1.0;
      }
      if (fVar5 <= fVar4) {
        fVar5 = fVar4;
      }
      return local_18 < fVar1 + fVar5 * -0.0005;
    }
  }
  return '\x01';
}

*/
- (BOOL)windowFrameFitsToScreen:(id)aScreen
{
    if ([aScreen length] != 0) {
        NSArray *components = [aScreen componentsSeparatedByString:@" "];
        if ([components count] < 8) {
            return NO;
        }
        NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
        float savedHeight = [[components objectAtIndex:7] floatValue];
        float savedWidth = [[components objectAtIndex:6] floatValue];
        float maxX = visibleFrame.origin.x + visibleFrame.size.width;
        float maxXTolerance = MAX((maxX != 0.0f || isnan(maxX)) ? fabsf(maxX) : 1.0f, (savedWidth != 0.0f || isnan(savedWidth)) ? fabsf(savedWidth) : 1.0f) * 0.0005f;
        if (savedWidth - maxXTolerance <= maxX) {
            float maxY = visibleFrame.origin.y + visibleFrame.size.height;
            float maxYTolerance = MAX((maxY != 0.0f || isnan(maxY)) ? fabsf(maxY) : 1.0f, (savedHeight != 0.0f || isnan(savedHeight)) ? fabsf(savedHeight) : 1.0f) * 0.0005f;
            return maxY < savedHeight - maxYTolerance;
        }
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00013ebe @ 00013ebe, 653 bytes * /

void FUN_00013ebe(HSEditorWindowController *self,SEL _cmd,id cardUndoableAttributeDidChange)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  char cVar5;
  cfstringStruct *pcVar6;
  
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_isInPlayerMode);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_document);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    pvVar3 = _objc_msgSend(pvVar2,sel_isUndoing);
    if (((char)pvVar3 == '\0') &&
       (pvVar2 = _objc_msgSend(pvVar2,sel_isRedoing), (char)pvVar2 == '\0')) {
      return;
    }
    pvVar2 = _objc_msgSend(cardUndoableAttributeDidChange,sel_userInfo);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSUnderlyingAttributeNotification);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003611f0);
    pvVar2 = _objc_msgSend(pvVar2,sel_isGroupObject);
    pvVar3 = _objc_msgSend(cardUndoableAttributeDidChange,sel_userInfo);
    pcVar6 = &cfstr_HSVisualSubobjectChangeDescriptions;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSVisualSubobjectChangeDescriptions);
    self_00 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    if (((char)pvVar2 == '\0') && (pvVar3 != (id)0x0)) {
      cVar5 = '\0';
      cVar1 = '\0';
      while ((cVar1 == '\0' && cVar5 == '\0' &&
             (pvVar3 = _objc_msgSend(self_00,sel_nextObject,pcVar6), pvVar3 != (id)0x0))) {
        pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSVisualSubobject);
        pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003611f0);
        pvVar4 = _objc_msgSend(pvVar4,sel_isGroupObject);
        cVar5 = (char)pvVar4;
        pcVar6 = (cfstringStruct *)&DAT_00361218;
        pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00361218);
        pvVar3 = _objc_msgSend(pvVar3,sel_isTemporary);
        cVar1 = (char)pvVar3;
      }
    }
    else {
      cVar5 = '\0';
      cVar1 = '\0';
    }
    pvVar3 = _objc_msgSend(cardUndoableAttributeDidChange,sel_object,pcVar6);
    if (((pvVar3 != (id)0x0) && ((char)pvVar2 == '\0')) && (cVar1 == '\0' && cVar5 == '\0')) {
      pvVar2 = _objc_msgSend(self,sel_stackView,pcVar6);
      pvVar2 = _objc_msgSend(pvVar2,sel_selectedHyperObject);
      if (pvVar2 != pvVar3) {
        pvVar2 = _objc_msgSend(self,sel_stackView);
        _objc_msgSend(pvVar2,sel_selectHyperObject_,pvVar3);
      }
    }
  }
  return;
}

*/
- (void)cardUndoableAttributeDidChange:(id)aChange
{
    if ([[self document] isInPlayerMode]) {
        return;
    }
    NSUndoManager *undoManager = [[self document] undoManager];
    if (![undoManager isUndoing] && ![undoManager isRedoing]) {
        return;
    }
    NSDictionary *info = [aChange userInfo];
    BOOL isGroup = [[[[info objectForKey:@"HSUnderlyingAttributeNotification"] object] queryHyperInterface:@protocol(HSCardObjectGroupAttribute)] isGroupObject];
    id changes = [[aChange userInfo] objectForKey:@"HSVisualSubobjectChangeDescriptions"];
    NSEnumerator *enumerator = [changes objectEnumerator];
    BOOL subobjectIsGroup = NO;
    BOOL subobjectIsTemporary = NO;
    if (!isGroup && changes != nil) {
        id description;
        while (!subobjectIsTemporary && !subobjectIsGroup && (description = [enumerator nextObject]) != nil) {
            id subobject = [description objectForKey:@"HSVisualSubobject"];
            subobjectIsGroup = [[subobject queryHyperInterface:@protocol(HSCardObjectGroupAttribute)] isGroupObject];
            subobjectIsTemporary = [[subobject queryHyperInterface:@protocol(HSNodeChild)] isTemporary];
        }
    }
    id object = [aChange object];
    if (object != nil && !isGroup && !subobjectIsTemporary && !subobjectIsGroup) {
        if ([[self stackView] selectedHyperObject] != object) {
            [[self stackView] selectHyperObject:object];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002be33 @ 0002be33, 439 bytes * /

void FUN_0002be33(HSEditorWindowController *self,SEL _cmd,id navigationOperationStageDidChange)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  float fVar4;
  double dVar5;
  
  pvVar1 = _objc_msgSend(navigationOperationStageDidChange,sel_object);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_isInStandardMode);
  if ((char)pvVar2 == '\0') {
    return;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_stage);
  if (pvVar2 == (id)0x2) {
    pvVar1 = _objc_msgSend(self,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_isInAnimationMode);
    if ((char)pvVar1 != '\0') {
      fVar4 = 1.0;
      cVar3 = '\x01';
      goto LAB_0002bf72;
    }
  }
  else {
    pvVar2 = _objc_msgSend(pvVar1,sel_stage);
    if ((pvVar2 == (id)0xd) || (pvVar1 = _objc_msgSend(pvVar1,sel_stage), pvVar1 == (id)0xe)) {
      pvVar1 = _objc_msgSend(self,sel_document);
      pvVar1 = _objc_msgSend(pvVar1,sel_isInPlayerMode);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(self,sel_cardView);
        dVar5 = _objc_msgSend_fpret(pvVar1,sel_zoomFactor);
        fVar4 = (float)dVar5;
        cVar3 = '\x01';
        goto LAB_0002bf72;
      }
    }
  }
  fVar4 = 1.0;
  cVar3 = '\0';
LAB_0002bf72:
  _objc_msgSend(self->_statusbarController,sel_setZoomFactor_,fVar4);
  _objc_msgSend(self->_statusbarController,sel_validateUI);
  _objc_msgSend(self->_statusbarController,sel_updateScalePopUpButtonTarget);
  _objc_msgSend(self->_statusbarController,sel_setZoomControlsEnabled_,(int)cVar3);
  return;
}

*/
- (void)navigationOperationStageDidChange:(id)aChange
{
    id operation = [aChange object];
    if (![[self document] isInStandardMode]) {
        return;
    }
    float zoom = 1.0f;
    BOOL controlsEnabled = NO;
    if ([operation stage] == 2) {
        if ([[self document] isInAnimationMode]) {
            zoom = 1.0f;
            controlsEnabled = YES;
        }
    } else if ([operation stage] == 0xd || [operation stage] == 0xe) {
        if (![[self document] isInPlayerMode]) {
            zoom = [[self cardView] zoomFactor];
            controlsEnabled = YES;
        }
    }
    [_statusbarController setZoomFactor:zoom];
    [_statusbarController validateUI];
    [_statusbarController updateScalePopUpButtonTarget];
    [_statusbarController setZoomControlsEnabled:controlsEnabled];
}

- (void)documentBackgroundPatternDidChange:(id)aChange
{
    [[self cardView] setBackgroundColor:0];
    [[self cardView] setNeedsDisplayWorkAreaBackground];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00013c72 @ 00013c72, 484 bytes * /

void FUN_00013c72(HSEditorWindowController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(self,sel_isThereButtonStylesToUpdate);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_HSUpdateAllButtonStylesAlertMessageText,&cfstr_empty,&cfstr_Alerts
                          );
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSUpdateAllButtonStylesAlertInformativeText,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_HSUpdateAllButtonStylesAlertUpdateButtonTitle,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_HSUpdateAllButtonStylesAlertDontUpdateButtonTitl,&cfstr_empty,
                           &cfstr_Alerts);
    uVar5 = 0;
    pvVar1 = _objc_msgSend(cls_HSAlert,
                           sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeText_
                           ,pvVar1,pvVar3,pvVar4,0,pvVar2);
    _objc_msgSend(pvVar1,sel_setAlertStyle_,1);
    pvVar1 = _objc_msgSend(pvVar1,sel_runModal);
    if (pvVar1 == (id)0x3e8) {
      _objc_msgSend(self,sel_updateAllButtonStyles_,self,pvVar3,pvVar4,uVar5,pvVar2);
    }
  }
  return;
}

*/
- (void)showAlertAboutOldButtonStylesIfNeeded
{
    if ([self isThereButtonStylesToUpdate]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *message = [bundle localizedStringForKey:@"HSUpdateAllButtonStylesAlertMessageText" value:@"" table:@"Alerts"];
        NSString *informative = [bundle localizedStringForKey:@"HSUpdateAllButtonStylesAlertInformativeText" value:@"" table:@"Alerts"];
        NSString *updateTitle = [bundle localizedStringForKey:@"HSUpdateAllButtonStylesAlertUpdateButtonTitle" value:@"" table:@"Alerts"];
        NSString *dontUpdateTitle = [bundle localizedStringForKey:@"HSUpdateAllButtonStylesAlertDontUpdateButtonTitle" value:@"" table:@"Alerts"];
        HSAlert *alert = [HSAlert alertWithMessageText:message defaultButton:updateTitle alternateButton:dontUpdateTitle otherButton:nil informativeText:informative];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == 1000) {
            [self updateAllButtonStyles:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002bfea @ 0002bfea, 483 bytes * /

void FUN_0002bfea(HSEditorWindowController *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  id local_7c;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperDeepEnumerator);
  while (pvVar4 = _objc_msgSend(pvVar2,sel_nextObject), pvVar4 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00361d6c);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperActions);
    local_74 = 0;
    local_70 = 0;
    local_6c = (int *)0x0;
    local_68 = 0;
    local_64 = 0;
    local_60 = 0;
    local_5c = 0;
    local_58 = 0;
    puVar6 = local_50;
    uVar7 = 0x10;
    local_7c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74,puVar6,
                             0x10);
    if (local_7c != (id)0x0) {
      iVar1 = *local_6c;
      do {
        pvVar5 = (id)0x0;
        do {
          if (iVar1 != *local_6c) {
            _objc_enumerationMutation(pvVar4);
          }
          pvVar3 = *(id *)(local_70 + (int)pvVar5 * 4);
          self_00 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00362348,puVar6,uVar7);
          _objc_msgSend(self_00,sel_updateURL);
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00362410);
          _objc_msgSend(pvVar3,sel_updateURL);
          pvVar5 = (id)((int)pvVar5 + 1);
        } while (pvVar5 < local_7c);
        puVar6 = local_50;
        uVar7 = 0x10;
        local_7c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                 puVar6,0x10);
      } while (local_7c != (id)0x0);
    }
  }
  return;
}

*/
- (void)didBindToModelOnLoad
{
    id pvVar1;
    id pvVar1_2;
    id pvVar1_4;
    id pvVar1_5;
    id pvVar1_9;
    id pvVar1_10;
    id pvVar1_11;

    [super didBindToModelOnLoad];
    [[self selectionController] setCardView:[self cardView]];
    [[self selectionController] setStackController:[self stackView]];
    [[self selectionController] setEnabled:YES];
    [[self documentSelectionSync] setThisCardSelectionHost:[self thisCardSelectionHolder]];
    [[self documentSelectionSync] setCardView:[self cardView]];
    [[self documentSelectionSync] setEnabled:YES];
    [[self window] setAutorecalculatesKeyViewLoop:YES];
    [[self window] recalculateKeyViewLoop];
    [_bottomAreaTintedView setDrawsBorder:NO];
    [_bottomAreaTintedView setDrawsFill:YES];
    [_bottomAreaTintedView setTintColor:[NSColor colorWithCalibratedWhite:0.82f alpha:1.0f]];
    [_bottomAreaTintedView setOpaque:YES];
    _statusbarController = [HSEditorWindowStatusbarController new];
    pvVar1_11 = [_statusbarController statusbarView];
    [_bottomAreaTintedView addSubview:pvVar1_11];
    [pvVar1_11 setFrame:[_bottomAreaTintedView bounds]];
    [_statusbarController setDelegate:self];
    [self loadWindowSettings];
    [self adjustWindowFrameAfterToolbarVisibilityValidation];
    [_cardView setEditObjectDialogContext:[[self document] editObjectDialogContext]];
    [_bottomAreaTintedView setBackgroundImage:[NSImage imageNamed:@"Bgr line"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardViewDidChangedZoomFactor:) name:@"HSEditorCardViewDidChangeZoomFactorNotification" object:_cardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardViewDidChangedZoomFactor:) name:@"HSEditorCardViewDidFitInWindowNotification" object:_cardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stackTitleDidChanged:) name:HSStackTitleDidChangeNotification object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationOperationStageDidChange:) name:@"HSNavigationOperationStageDidChangeNotification" object:0];
    [_statusbarController setupScalePopUpButton];
    [_statusbarController setMaxZoomFactor:(float)[HSEditorZoomController maxZoomFactor]];
    [_statusbarController setMinZoomFactor:(float)[HSEditorZoomController minZoomFactor]];
    [_statusbarController setZoomFactor:(float)[_cardView zoomFactor]];
    [_statusbarController refreshStatusbarText];
    [self synchronizeWindowTitleWithDocumentName];
    [self showAlertAboutOldButtonStylesIfNeeded];
    [self updateURLInOpenStackAndOtherCardActions];
}

- (id)stackSelectionHolder
{
    return [[self document] stackSelectionHolder];
}

- (id)thisCardSelectionHolder
{
    HSThisCardSelectionHolder *pHVar2;
    HSThisCardSelectionHolder *pHVar2_2;

    pHVar2 = _thisCardSelectionHolder;
    if (pHVar2 == nil) {
        pHVar2_2 = [[HSThisCardSelectionHolder alloc] init];
        _thisCardSelectionHolder = pHVar2_2;
        [pHVar2_2 setCardView:[self cardView]];
        pHVar2 = _thisCardSelectionHolder;
    }
    return pHVar2;
}

- (void)bindToModelOnLoad
{
    id self_00;
    id pvVar1_2;
    id pvVar1_3;
    BOOL pvVar2_3;

    [super bindToModelOnLoad];
    pvVar1_2 = [[self document] stack];
    pvVar2_3 = [[[HSHomeStackController sharedHomeStackController] homeStackURL] isEqual:[[pvVar1_2 document] fileURL]];
    self_00 = [self cardView];
    if (!pvVar2_3) {
        pvVar1_3 = [pvVar1_2 posterCard];
    }
    else {
        pvVar1_3 = [pvVar1_2 hyperChildAtIndex:[[HSHomeStackController sharedHomeStackController] defaultCardIndex]];
    }
    [self_00 setCard:pvVar1_3];
    [_statusbarController refreshStatusbarText];
    [[self stackView] setStack:[[self document] stack]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002c9d4 @ 0002c9d4, 339 bytes * /

void FUN_0002c9d4(HSEditorWindowController *self,SEL _cmd)

{
  HSEditorCardView *pHVar1;
  id pvVar2;
  undefined4 *puVar3;
  HSEditorWindowController *local_2c;
  undefined *local_28;
  undefined1 local_24 [20];
  
  local_2c = self;
  local_28 = PTR_s_HSMainWindowController_0034dbd0;
  _objc_msgSendSuper(&local_2c,sel_willBindToModelOnLoad);
  pvVar2 = self->_workAreaView;
  puVar3 = (undefined4 *)&stack0xffffffb4;
  if ((pvVar2 != (id)0x0) &&
     (puVar3 = (undefined4 *)&stack0xffffffb4, self->_workAreaContainerView != (id)0x0)) {
    _objc_msgSend_stret(local_24,self->_workAreaContainerView,sel_bounds);
    puVar3 = (undefined4 *)&stack0xffffffb0;
    _objc_msgSend(pvVar2,sel_setFrame_);
    _objc_msgSend(self->_workAreaView,sel_setAutoresizingMask_);
    _objc_msgSend(self->_workAreaContainerView,sel_addSubview_);
  }
  pvVar2 = self->_workAreaContainerView;
  puVar3[1] = sel_retain;
  *puVar3 = pvVar2;
  puVar3[-1] = 0x2cab8;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  pHVar1 = self->_cardView;
  puVar3[1] = sel_retain;
  *puVar3 = pHVar1;
  puVar3[-1] = 0x2cacd;
  _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  if (self->_stackController != (HSStackController *)0x0) {
    puVar3[1] = sel_defaultCenter;
    *puVar3 = cls_NSNotificationCenter;
    puVar3[-1] = 0x2caeb;
    pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    puVar3[5] = self->_stackController;
    puVar3[4] = &cfstr_HSStackViewDidChangeActiveCardNotification;
    puVar3[3] = sel_activeCardDidChange_;
    puVar3[2] = self;
    puVar3[1] = sel_addObserver_selector_name_object_;
    *puVar3 = pvVar2;
    puVar3[-1] = 0x2cb1f;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)willBindToModelOnLoad
{
    [super willBindToModelOnLoad];
    if (_workAreaView != nil && _workAreaContainerView != nil) {
        [_workAreaView setFrame:[_workAreaContainerView bounds]];
        [_workAreaView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_workAreaContainerView addSubview:_workAreaView];
    }
    [_workAreaContainerView retain];
    [_cardView retain];
    if (_stackController != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeCardDidChange:) name:@"HSStackViewDidChangeActiveCardNotification" object:_stackController];
    }
}

- (void)validateStackNavigationControl
{
    [_statusbarController validateUI];
}

- (void)attachToStack
{
    id pvVar1;
    HSEditorWindowController *pHVar3;

    [super attachToStack];
    pvVar1 = [self stackView];
    pHVar3 = [[[self document] modeSwitcher] activeModeController];
    [pvVar1 setStack:[[self document] stack] forceSelection:(unsigned int)(pHVar3 == self)];
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:[self cardView]];
}

- (void)detachFromStack
{
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:nil];
    [[self stackView] setStack:nil];
    [[self cardView] setCard:nil];
    [super detachFromStack];
}

- (void)didAttachToMainWindow
{
    [[[self document] selectionSync] setWindowController:self];
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:[self cardView]];
    [[[self toolbarController] toolbar] validateVisibleItems];
    [[self selectionController] setStackController:[self stackView]];
    [_statusbarController refreshStatusbarText];
}

- (void)willDetachFromMainWindow
{
    [[HSToolPaletteController sharedInstance] validateUserInterfaceWithView:nil];
    [_statusbarController refreshStatusbarText];
    [[self selectionController] setStackController:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002ccfd @ 0002ccfd, 608 bytes * /

void FUN_0002ccfd(HSEditorWindowController *self,SEL _cmd,id nodeContainer,id didRemoveChildren)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  undefined *puVar6;
  HSEditorWindowController *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_selectionController);
  pvVar3 = nodeContainer;
  pvVar4 = didRemoveChildren;
  _objc_msgSend(pvVar1,sel_noteNodeContainer_didRemoveChildren_,nodeContainer,didRemoveChildren);
  pvVar1 = _objc_msgSend(didRemoveChildren,sel_extraFirstObject);
  pvVar2 = _objc_msgSend(didRemoveChildren,sel_count);
  if (pvVar2 == (id)0x1) {
    pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,pvVar3,
                           pvVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectAssistant);
    pvVar4 = _objc_msgSend(pvVar3,sel_object);
    pvVar3 = pvVar1;
    pvVar4 = _objc_msgSend(pvVar4,sel_isEqual_,pvVar1);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(pvVar1,sel_isTemporary,pvVar3);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,pvVar3)
        ;
        pvVar4 = _objc_msgSend(pvVar4,sel_isLocked);
        if ((char)pvVar4 == '\0') {
          pvVar3 = _objc_msgSend(self,sel_selectionController,pvVar3);
          pvVar3 = _objc_msgSend(pvVar3,sel_selectedHyperObject);
          puVar6 = &DAT_003611f0;
          puVar5 = puVar6;
          pvVar4 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003611f0);
          pvVar4 = _objc_msgSend(pvVar4,sel_isGroupObject);
          if ((char)pvVar4 != '\0') {
            pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003611f0);
            pvVar4 = _objc_msgSend(pvVar4,sel_isGroupObject);
            puVar5 = puVar6;
            if ((char)pvVar4 != '\0') {
              pvVar4 = _objc_msgSend(pvVar1,sel_nodeData,puVar6);
              puVar5 = _objc_msgSend(pvVar3,sel_nodeData);
              pvVar3 = _objc_msgSend(pvVar4,sel_isEqual_,puVar5);
              if ((char)pvVar3 != '\0') goto LAB_0002cf23;
            }
          }
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                 puVar5);
          _objc_msgSend(pvVar3,sel_setActive_explicitlyByUser_,0,0);
        }
      }
    }
  }
LAB_0002cf23:
  local_1c = self;
  local_18 = PTR_s_HSMainWindowController_0034dbd0;
  _objc_msgSendSuper(&local_1c,sel_nodeContainer_didRemoveChildren_,nodeContainer,didRemoveChildren)
  ;
  return;
}

*/
- (void)nodeContainer:(id)aContainer didRemoveChildren:(id)aChildren
{
    [[self selectionController] noteNodeContainer:aContainer didRemoveChildren:aChildren];
    id removed = [aChildren extraFirstObject];
    if ([aChildren count] == 1) {
        if ([[[[HSObjectAssistantController sharedAssistantController] objectAssistant] object] isEqual:removed]
            && ![removed isTemporary]
            && ![[HSObjectAssistantController sharedAssistantController] isLocked]) {
            id selected = [[self selectionController] selectedHyperObject];
            BOOL sameGroup = NO;
            if ([[removed queryHyperInterface:@protocol(HSCardObjectGroupAttribute)] isGroupObject]
                && [[selected queryHyperInterface:@protocol(HSCardObjectGroupAttribute)] isGroupObject]
                && [[removed nodeData] isEqual:[selected nodeData]]) {
                sameGroup = YES;
            }
            if (!sameGroup) {
                [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:NO];
            }
        }
    }
    [super nodeContainer:aContainer didRemoveChildren:aChildren];
}

- (void)nodeContainer:(id)aContainer didAddChild:(id)aChild
{
    id pvVar1_3;

    if (![aChild implementsHyperInterface:@protocol(HSCardAttributes)]) {
        pvVar1_3 = [[HSObjectAssistantController sharedAssistantController] objectAssistant];
        [pvVar1_3 setShouldNotCoverObjectForAssistant:YES];
        if ((_addChildrenGroupingIsInProgress == NO) || (_alertHaveShowedForThisGroup == NO)) {
            [self showAlertAboutHiddenObjectsIfNeeded];
            _alertHaveShowedForThisGroup = YES;
        }
    }
    [super nodeContainer:aContainer didAddChild:aChild];
    [[self selectionController] noteNodeContainer:aContainer didAddChild:aChild];
}

- (void)nodeContainerRemoveChildrenEndGrouping:(id)aGrouping
{
    [[self selectionController] noteNodeContainerRemoveChildrenEndGrouping:aGrouping];
    [[[self cardView] selection] endSelectionChanging];
    [[self cardView] endContentChangeAccumulation];
    [[self cardView] dehibernate];
    [[self cardView] setNeedsDisplayOpenGLSurface:YES];
}

- (void)nodeContainerRemoveChildrenBeginGrouping:(id)aGrouping
{
    [[self cardView] hibernate];
    [[self cardView] beginContentChangeAccumulation];
    [[[self cardView] selection] beginSelectionChanging];
    [[self selectionController] noteNodeContainerRemoveChildrenBeginGrouping:aGrouping];
}

- (void)nodeContainerAddChildrenEndGrouping:(id)aGrouping
{
    [[self selectionController] noteNodeContainerAddChildrenEndGrouping:aGrouping];
    [[[self cardView] selection] endSelectionChanging];
    [[self cardView] endContentChangeAccumulation];
    [[self cardView] dehibernate];
    [[self cardView] setNeedsDisplayOpenGLSurface:YES];
    _addChildrenGroupingIsInProgress = NO;
}

- (void)nodeContainerAddChildrenBeginGrouping:(id)aGrouping
{
    [[self cardView] hibernate];
    [[self cardView] beginContentChangeAccumulation];
    [[HSToolManager sharedToolManager] selectToolWithTag:0 setAsPermanent:NO forceSelection:NO];
    [[[self cardView] selection] beginSelectionChanging];
    [[self selectionController] noteNodeContainerAddChildrenBeginGrouping:aGrouping];
    _addChildrenGroupingIsInProgress = YES;
    _alertHaveShowedForThisGroup = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001341b @ 0001341b, 533 bytes * /

void FUN_0001341b(HSEditorWindowController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_cardObjectsVisibility);
  self_00 = cls_NSAlert;
  if (pvVar1 == (id)0x1) {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHideOrShowObjectsAlertInformativeText,&cfstr_empty,&cfstr_Alerts
                          );
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHideOrShowObjectsAlertAlternateButton,&cfstr_empty,&cfstr_Alerts
                          );
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHideOrShowObjectsAlertDefaultButton,&cfstr_empty,&cfstr_Alerts);
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHideOrShowObjectsAlertMessageText,&cfstr_empty,&cfstr_Alerts);
    uVar6 = 0;
    pvVar5 = _objc_msgSend(self_00,
                           sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                           ,pvVar4,pvVar3,pvVar2,0,pvVar1);
    pvVar5 = _objc_msgSend(pvVar5,sel_runModal);
    if (pvVar5 == (id)0x1) {
      pvVar1 = _objc_msgSend(self,sel_document,pvVar4,pvVar3,pvVar2,uVar6,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_stack);
      _objc_msgSend(pvVar1,sel_setCardObjectsVisibility_,0);
    }
  }
  return;
}

*/
- (void)showAlertAboutHiddenObjectsIfNeeded
{
    if ([[[self document] stack] cardObjectsVisibility] == 1) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSAlert *alert = [NSAlert alertWithMessageText:[provider localizedStringForKey:@"HSHideOrShowObjectsAlertMessageText" value:@"" table:@"Alerts"]
                                         defaultButton:[provider localizedStringForKey:@"HSHideOrShowObjectsAlertDefaultButton" value:@"" table:@"Alerts"]
                                       alternateButton:[provider localizedStringForKey:@"HSHideOrShowObjectsAlertAlternateButton" value:@"" table:@"Alerts"]
                                           otherButton:nil
                             informativeTextWithFormat:[provider localizedStringForKey:@"HSHideOrShowObjectsAlertInformativeText" value:@"" table:@"Alerts"]];
        if ([alert runModal] == 1) {
            [[[self document] stack] setCardObjectsVisibility:0];
        }
    }
}

- (void)cardView:(id)aView didSetCard:(id)aCard
{
    [[self document] cardView:aView inWindowController:self didSetCard:aCard];
}

- (void)activeCardViewDidSetCard:(id)aCard
{
    if ([[self stackView] activeCard] != aCard) {
        [[self stackView] selectHyperObject:aCard];
    }
    [self validateStackNavigationControl];
    [self synchronizeWindowTitleWithDocumentName];
    [_statusbarController refreshStatusbarText];
}

- (void)stackTitleDidChanged:(id)aChanged
{
    [self synchronizeWindowTitleWithDocumentName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0002d067 @ 0002d067, 83 bytes * /

void FUN_0002d067(HSEditorWindowController *self,SEL _cmd,id cardViewDidChangedZoomFactor)

{
  id self_00;
  double dVar1;
  
  self_00 = _objc_msgSend(cardViewDidChangedZoomFactor,sel_object);
  dVar1 = _objc_msgSend_fpret(self_00,sel_zoomFactor);
  _objc_msgSend(self,sel_activeCardViewDidChangeZoomFactor_,(float)dVar1);
  return;
}

*/
- (void)cardViewDidChangedZoomFactor:(id)aFactor
{
    [self activeCardViewDidChangeZoomFactor:[[aFactor object] zoomFactor]];
}

- (void)activeCardViewDidChangeZoomFactor:(CGFloat)aFactor
{
    [_statusbarController setZoomFactor:aFactor];
}

- (void)activeCardDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [[self stackView] activeCard];
    if ([[[self document] navigationController] currentNavigationOperation] == nil) {
        [[[self document] actionExecutionManager] setLeaveActionsDisabled:YES];
        [[[self document] navigationController] goToCardAtIndex:[pvVar1_2 hyperIndex]];
        [[[self document] actionExecutionManager] setLeaveActionsDisabled:NO];
    }
    [_statusbarController refreshStatusbarText];
}

- (void)stackDidChangeAttributes:(id)aAttributes
{

}

- (void)switchToPreviousObjectAssistantPaneViaGlobalShortcut:(id)aShortcut
{
    [[[HSObjectAssistantController sharedAssistantController] objectAssistant] openPreviousPane:aShortcut];
}

- (void)switchToNextObjectAssistantPaneViaGlobalShortcut:(id)aShortcut
{
    [[[HSObjectAssistantController sharedAssistantController] objectAssistant] openNextPane:aShortcut];
}

- (void)switchToRectSelectionToolViaGlobalShortcut:(id)aShortcut
{
    NSInteger uVar2;
    NSInteger pvVar1_2;

    pvVar1_2 = [[HSToolManager sharedToolManager] selectedToolTag];
    uVar2 = 0xe;
    if (pvVar1_2 == 0xe) {
        uVar2 = 1;
    }
    [self switchToToolWithTag:uVar2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00012fe6 @ 00012fe6, 107 bytes * /

void FUN_00012fe6(HSEditorWindowController *self,SEL _cmd,id mouseMoved)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_cardView);
  _objc_msgSend(pvVar1,sel_handleMouseMoved_,mouseMoved);
  pvVar1 = _objc_msgSend(cls_HSEditorApplication,sel_sharedHyperApplication);
  _objc_msgSend(pvVar1,sel_noteMainWindowDidHandleMouseMovedEvent);
  return;
}

*/
- (void)mouseMoved:(id)aMoved
{
    [[self cardView] handleMouseMoved:aMoved];
    [[HSEditorApplication sharedHyperApplication] noteMainWindowDidHandleMouseMovedEvent];
}

- (BOOL)cancelOperation
{
    BOOL BVar1;

    BVar1 = (BOOL)[super cancelOperation];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:HSToggleBrowseEditByEscapeEnabledKey] boolValue]) {
        [[self document] togglePlayEdit:self];
        BVar1 = YES;
    }
    return BVar1;
}

- (BOOL)stackSelectionHostWasCurrentBeforeAssistantHide
{
    return _stackSelectionHostWasCurrentBeforeAssistantHide;
}

- (BOOL)supportsMinimalWindowMode
{
    return YES;
}

- (void)setupMinimalWindowApplier:(id)aApplier
{
    [aApplier setupWithWorkAreaView:_workAreaView cardWorkAreaView:_mainAreaTintedView statusBarContainerView:_bottomAreaTintedView cardScrollView:_cardScrollView mediaStripSwitcher:[[self stackController] mediaStripSwitcher]];
}

- (id)windowNibName
{
    return @"EditorWindow";
}

- (id)workAreaView
{
    return _workAreaView;
}

- (id)bottomAreaTintedView
{
    return _bottomAreaTintedView;
}

- (id)mainAreaTintedView
{
    return _mainAreaTintedView;
}

- (id)cardScrollView
{
    return _cardScrollView;
}

- (id)cardView
{
    return _cardView;
}

- (id)stackController
{
    return _stackController;
}

- (id)stackView
{
    return _stackController;
}

- (void)showWindow:(id)aWindow
{
    [[HSSplashScreenWindowController sharedSplashWindow] hideSplashWaitUntilTimeout:YES];
    [super showWindow:0];
}

- (void)setDocument:(id)aDocument
{
    int uVar1;
    id pvVar2_2;

    pvVar2_2 = [[self stackController] stack];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 removeObserver:self selector:@selector(cardUndoableAttributeDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSUndoableAttribute)];
    [super setDocument:aDocument];
    [_stackTextProvider setSelectionController:[self selectionController]];
    [[[self stackController] stack] addObserver:self selector:@selector(cardUndoableAttributeDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSUndoableAttribute) withPriority:-0.25];
    [_cardView setEditObjectDialogContext:[[self document] editObjectDialogContext]];
    [_importGraphicDialogController setHyperDocument:nil];
    [_importGraphicObjectDialogController setHyperDocument:nil];
    [_importBackgroundDialogController setHyperDocument:nil];
    [_importSoundObjectDialogController setHyperDocument:nil];
    [_importMoviesObjectDialogController setHyperDocument:nil];
}

- (void)dealloc
{
    id pvVar1;
    HSEditorWindowController *pHVar3;

    pvVar1 = [[self stackController] stack];
    [pvVar1 removeAttributeObserver:self];
    [_captureDeviceList release];
    [_importGraphicObjectDialogController release];
    [_importBackgroundDialogController release];
    [_importGraphicDialogController release];
    [_importSoundObjectDialogController release];
    [_importMoviesObjectDialogController release];
    pvVar1 = [NSNotificationCenter defaultCenter];
    pHVar3 = self;
    [pvVar1 removeObserver:self];
    if ([_soundRecordingController delegate] == self) {
        pHVar3 = nil;
        [_soundRecordingController setDelegate:0];
    }
    [_soundRecordingController release];
    if ([_videoRecordingController delegate] == self) {
        pHVar3 = nil;
        [_videoRecordingController setDelegate:0];
    }
    [_videoRecordingController release];
    if ([_webcamWorkshopController delegate] == self) {
        pHVar3 = nil;
        [_webcamWorkshopController setDelegate:0];
    }
    [_webcamWorkshopController release];
    pvVar1 = [self documentSelectionSync];
    [pvVar1 setEnabled:NO];
    pvVar1 = [self selectionController];
    [pvVar1 setEnabled:NO];
    [pvVar1 setWindowController:0];
    [pvVar1 setStackController:nil];
    [pvVar1 setCardView:nil];
    [pvVar1 setStoryboardView:nil];
    [_thisCardSelectionHolder setCardView:nil];
    [_thisCardSelectionHolder release];
    [_stackController setStack:nil];
    [_workAreaContainerView release];
    [_stackController setStackViewDelegate:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:_cardView selector:@selector(updateCursor) object:nil];
    [_cardView setDelegate:0];
    [_cardView release];
    [_stackTextProvider release];
    [_fieldEditor release];
    [_statusbarController release];
    [_effectsDialogController release];
    pvVar1 = [HSCommentsAndAttributionsPaletteController sharedInstance];
    pHVar3 = [pvVar1 dataProvider];
    if (pHVar3 == self) {
        pvVar1 = [HSCommentsAndAttributionsPaletteController sharedInstance];
        [pvVar1 setDataProvider:nil];
    }
    [super dealloc];
}

- (id)initWithWindow:(id)aWindow
{
    self = [super initWithWindow:aWindow];
    if (self != nil) {
        [self setShouldCloseDocument:YES];
    }
    return self;
}

@end

@implementation SMKSegmentedControl (UserInterfaceValidation)

- (NSInteger)tag
{
    NSInteger pvVar1_2;

    if ([self selectedSegment] == 0xffffffff) {
        pvVar1_2 = 0;
    }
    else {
        pvVar1_2 = [self tagForSegment:[self selectedSegment]];
    }
    return (int)pvVar1_2;
}

@end

@implementation NSObject (HSWeigthExtension)

- (NSInteger)compareWeightBack:(id)aBack
{
    return (int)[aBack compareWeight:self];
}

@end

