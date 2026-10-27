#import "HSGraphicObjectsAssistantPane.h"

@implementation HSGraphicObjectsAssistantPane

- (id)mediaAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMediaAttributes)];
}

- (id)document
{
    return [[[[self assistant] object] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

- (void)runCropDialogButtonClicked:(id)aClicked
{
    id geometry = [[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)];
    BOOL flippedHorizontally = [geometry isFlippedHorizontally];
    BOOL flippedVertically = [geometry isFlippedVertically];
    HSCropImageDialogController *dialog = [HSCropImageDialogController new];
    [dialog setOKButtonTitle:[[NSBundle mainBundle] localizedStringForKey:@"Crop" value:@"" table:nil]];
    [dialog setFlippedHorizontally:[geometry isFlippedHorizontally]];
    [dialog setFlippedVertically:[geometry isFlippedVertically]];
    HSImageCropApplier *applier = [[HSImageCropApplier alloc] initWithImageObject:[[self assistant] object]];
    NSSize size = NSZeroSize;
    CGImageRef image = [[applier croppedImageDrawing] currentCGImageOfSize:&size isFlippedHorizontally:flippedHorizontally isFlippedVertically:flippedVertically];
    [dialog setSourceCGImage:image size:size];
    if ([NSApp runModalForWindow:[dialog window]] == 1) {
        id imageObject = [[[self assistant] object] queryHyperInterface:@protocol(HSImageObjectAttributes)];
        if (![imageObject isEnabledCacheImage]) {
            [applier cropImageObjectWithPath:[dialog borderPath]];
        } else {
            [imageObject setEnabledCacheImageForAllGroupObjects:NO setUpUndoManager:YES];
            [applier cropImageObjectWithPath:[dialog borderPath]];
            [imageObject setEnabledCacheImageForAllGroupObjects:YES setUpUndoManager:YES];
        }
    }
    [applier release];
    [dialog release];
}

- (void)scaleToFitCardButtonClicked:(id)aClicked
{
    [NSApp sendAction:@selector(resizeToFitCard:) to:nil from:aClicked];
}

- (void)scaleToFillCardButtonClicked:(id)aClicked
{
    [NSApp sendAction:@selector(resizeToFillCard:) to:nil from:aClicked];
}

- (void)flattenToBackgroundButtonClicked:(id)aClicked
{
    [[[self document] currentCard] flatObjectsToBackground:[NSArray arrayWithObject:[[self assistant] object]]];
}

// Replaces the picture with a library or file image, a cropped one or a camera capture. The
// image is fitted (layout 3) or filled into the object's current size, keeping its proportions.
- (void)chooseAnotherPicture:(id)aPicture
{
    if (_importGraphicDialogController == nil) {
        _importGraphicDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeGetAnotherPicture];
        [_importGraphicDialogController setupDialogInterfaceWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:HSImportDialogGraphicsObjectLayout]];
        [_importGraphicDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
        [_importGraphicDialogController setCaptureImageButtonEnabled:YES];
        [_importGraphicDialogController setHyperDocument:[self document]];
    }
    [self setSettingsForGraphicImportDialogController:_importGraphicDialogController];
    if ([_importGraphicDialogController runModal] != 1)
        return;
    NSDictionary *options = [_importGraphicDialogController dialogUserOptions];
    id media = nil;
    if (![[options valueForKey:HSCaptureImageKey] boolValue]) {
        NSString *fileName = [_importGraphicDialogController fileName];
        if ([[options valueForKey:HSImportDialogGraphicsOptionKeyIsImageCropped] boolValue]) {
            media = [HSNewMedia mediaWithImage:[options valueForKey:HSImportDialogGraphicsOptionKeyCroppedImage]];
        } else {
            if (fileName == nil)
                return;
            id uid = nil;
            NSString *uidString = [[[HSLibraryManager sharedLibraryManager] mediaContentFilter] globalUIDStringForMediaItem:fileName];
            if (uidString != nil) {
                uid = [HSUID UIDWithString:uidString];
                if (uid != nil)
                    media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
            }
            if (media == nil)
                media = [HSNewMedia mediaWithPath:fileName mediaUID:uid];
        }
    } else {
        HSCaptureImageController *capture = [[HSCaptureImageController alloc] init];
        if ([capture runModal] == 1) {
            NSImage *image = [capture capturedImage];
            [image setScalesWhenResized:YES];
            media = [HSNewMedia mediaWithImage:image];
        }
        [capture release];
    }
    if (media == nil)
        return;
    id object = [[self assistant] object];
    id imageObject = [object queryHyperInterface:@protocol(HSImageObjectAttributes)];
    HSImageCropApplier *applier = [[HSImageCropApplier alloc] initWithImageObject:imageObject];
    if ([[object queryHyperInterface:@protocol(HSEffectMutableAttributes)] hyperEffectName] != nil)
        [applier updateEffectedImageObject];
    NSSize objectSize = NSZeroSize;
    if ([object queryHyperInterface:@protocol(HSSizeAttributes)] != nil)
        objectSize = [(id<HSSizeAttributes>)[object queryHyperInterface:@protocol(HSSizeAttributes)] size];
    BOOL cacheEnabled = [imageObject isEnabledCacheImage];
    if (cacheEnabled)
        [imageObject setEnabledCacheImageForAllGroupObjects:NO setUpUndoManager:YES];
    [imageObject setHyperEffectedMedia:media refreshName:YES];
    [imageObject setRelativeImageRect:NSMakeRect(0.0, 0.0, 1.0, 1.0) updateClipPaths:NO];
    id image = [[object queryHyperInterface:@protocol(HSImageAttributes)] image];
    NSSize pixelsSize = image != nil ? [image hyperPixelsSize] : NSZeroSize;
    if (!NSEqualSizes(NSZeroSize, objectSize) && !NSEqualSizes(NSZeroSize, pixelsSize) && !NSEqualSizes(objectSize, pixelsSize)) {
        float objectAspect = objectSize.width / objectSize.height;
        float pixelsAspect = pixelsSize.width / pixelsSize.height;
        BOOL fitWidth = [[options valueForKey:HSImportDialogGraphicsOptionKeyLayout] intValue] == 3 ? pixelsAspect > objectAspect : objectAspect > pixelsAspect;
        float width, height;
        if (fitWidth) {
            width = objectSize.width;
            height = objectSize.width / pixelsAspect;
        } else {
            width = pixelsAspect * objectSize.height;
            height = objectSize.height;
        }
        NSRect rect = NSMakeRect(NSZeroRect.origin.x + (objectSize.width - width) * 0.5f, NSZeroRect.origin.y + (objectSize.height - height) * 0.5f, width, height);
        [imageObject setImageRect:rect updateClipPaths:NO];
    }
    [[imageObject queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] removeAllClipPaths];
    [imageObject dropInitialClipPaths];
    [applier updateCurrentBorderPath];
    [applier release];
    if (cacheEnabled)
        [imageObject setEnabledCacheImageForAllGroupObjects:YES setUpUndoManager:YES];
    id commentsAttributes = [object queryHyperInterface:@protocol(HSCommentsAttributes)];
    if (commentsAttributes != nil) {
        id mediaUID = [[object queryHyperInterface:@protocol(HSMediaUIDAttribute)] mediaUID];
        if (mediaUID != nil) {
            NSString *comments = [HSMediaCommentsAndAttributionsProvider commentsAndAttributionsForMediaUID:mediaUID];
            // Fix: a captured image has no file name, and a nil path raised here.
            if (comments == nil && [_importGraphicDialogController fileName] != nil)
                comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:[_importGraphicDialogController fileName]]];
            if (comments != nil && [comments length] != 0 && ![[commentsAttributes hyperComments] hasHyperSubstring:comments])
                [commentsAttributes appendHyperComments:comments];
        }
    }
}

- (void)scaleAndRotateButtonClicked:(id)aClicked
{
    id pane = [[HSScaleAndRotateAssistantPane new] autorelease];
    id navigationController = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

// The preview gets the tolerance, the current clip paths and the bottom-up flip they are drawn with.
- (void)setSettingsForGraphicImportDialogController:(id)aController
{
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:[self selectionToolTolerance] forKey:@"selectionTolerance"];
    NSArray *clipPaths = [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] clipPaths];
    if ([clipPaths count] != 0)
        [options setObject:clipPaths forKey:HSImportDialogGraphicsPreviewRelativeClipPathsKey];
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 1.0);
    [options setObject:[NSValue valueWithBytes:&flip objCType:@encode(CGAffineTransform)] forKey:HSImportDialogGraphicsPreviewRelativeClipPathsAffineTransformKey];
    [(HSImportDialogController *)aController setOptions:options];
}

- (id)selectionToolTolerance
{
    id tolerance = [[[HSToolManager sharedToolManager] toolSettings] settingForIdentifier:@"HSLassoSelectionTool" andKey:@"selectionTolerance"];
    if (tolerance == nil)
        tolerance = [NSNumber numberWithFloat:0.0f];
    return tolerance;
}

- (void)dealloc
{
    [_importGraphicDialogController release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"GraphicObjectsAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Layout" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"format"]];
    }
    return self;
}

- (void)imageCaptureDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id media = nil;
    if (aCode == 1) {
        id image = [aDialog capturedImage];
        [image setScalesWhenResized:YES];
        media = [HSNewMedia mediaWithImage:image];
    }
    [self anotherImageObjectWithMedia:media];
    [aDialog autorelease];
}

- (void)cropImageDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id delegate = [aDialog delegate];
    if (aCode == 1)
        [(id)aInfo cropImageObjectWithPath:[delegate borderPath]];
    [(id)aInfo release];
    [delegate autorelease];
    [aDialog orderOut:nil];
}

- (void)anotherImageObjectWithMedia:(id)aMedia
{
    if (aMedia == nil)
        return;
    id options = [_importGraphicDialogController dialogUserOptions];
    id object = [[self assistant] object];
    id imageObject = [object queryHyperInterface:@protocol(HSImageObjectAttributes)];
    id applier = [[HSImageCropApplier alloc] initWithImageObject:imageObject];
    if ([[object queryHyperInterface:@protocol(HSEffectMutableAttributes)] hyperEffectName] != nil)
        [applier updateEffectedImageObject];
    NSSize targetSize = NSZeroSize;
    if ([object queryHyperInterface:@protocol(HSSizeAttributes)] != nil)
        targetSize = [[object queryHyperInterface:@protocol(HSSizeAttributes)] size];
    BOOL cacheEnabled = [imageObject isEnabledCacheImage];
    if (cacheEnabled)
        [imageObject setEnabledCacheImageForAllGroupObjects:NO setUpUndoManager:YES];
    [imageObject setHyperEffectedMedia:aMedia refreshName:YES];
    [imageObject setRelativeImageRect:NSMakeRect(0, 0, 1, 1) updateClipPaths:NO];
    id image = [[object queryHyperInterface:@protocol(HSImageAttributes)] image];
    NSSize pixels = image != nil ? [image hyperPixelsSize] : NSZeroSize;
    if (!NSEqualSizes(NSZeroSize, targetSize) && !NSEqualSizes(NSZeroSize, pixels) && !NSEqualSizes(targetSize, pixels)) {
        int layout = [[options valueForKey:HSImportDialogGraphicsOptionKeyLayout] intValue];
        float targetAspect = targetSize.width / targetSize.height;
        float imageAspect = pixels.width / pixels.height;
        BOOL fitHeight = layout == 3 ? imageAspect < targetAspect : targetAspect < imageAspect;
        float width, height;
        if (fitHeight || imageAspect == targetAspect) {
            width = imageAspect * targetSize.height;
            height = targetSize.height;
        } else {
            width = targetSize.width;
            height = targetSize.width / imageAspect;
        }
        float x = (targetSize.width * 0.5 - width * 0.5);
        float y = (targetSize.height * 0.5 - height * 0.5);
        [imageObject setImageRect:NSMakeRect(x, y, width, height) updateClipPaths:NO];
    }
    [[imageObject queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] removeAllClipPaths];
    [imageObject dropInitialClipPaths];
    [applier updateCurrentBorderPath];
    [applier release];
    if (cacheEnabled)
        [imageObject setEnabledCacheImageForAllGroupObjects:YES setUpUndoManager:YES];
    id commentsAttributes = [object queryHyperInterface:@protocol(HSCommentsAttributes)];
    if (commentsAttributes == nil)
        return;
    id mediaUID = [[object queryHyperInterface:@protocol(HSMediaUIDAttribute)] mediaUID];
    if (mediaUID == nil)
        return;
    id comments = [HSMediaCommentsAndAttributionsProvider commentsAndAttributionsForMediaUID:mediaUID];
    if (comments == nil) {
        comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:[_importGraphicDialogController fileName]]];
        if (comments == nil)
            return;
    }
    if ([comments length] != 0 && ![[commentsAttributes hyperComments] hasHyperSubstring:comments])
        [commentsAttributes appendHyperComments:comments];
}

- (void)importDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [[aDialog window] orderOut:nil];
    if (aCode != 1)
        return;
    id options = [_importGraphicDialogController dialogUserOptions];
    id media;
    if ([[options valueForKey:HSCaptureImageKey] boolValue]) {
        id capture = [[HSCaptureImageController alloc] init];
        NSInteger code = [capture runModal];
        [self imageCaptureDialogDidEnd:capture returnedCode:code contextInfo:NULL];
        return;
    }
    NSString *path = [_importGraphicDialogController fileName];
    if ([[options valueForKey:HSImportDialogGraphicsOptionKeyIsImageCropped] boolValue]) {
        media = [HSNewMedia mediaWithImage:[options valueForKey:HSImportDialogGraphicsOptionKeyCroppedImage]];
    } else {
        if (path == nil) {
            [self anotherImageObjectWithMedia:nil];
            return;
        }
        id UIDString = [[[HSLibraryManager sharedLibraryManager] mediaContentFilter] globalUIDStringForMediaItem:path];
        id UID = UIDString != nil ? [HSUID UIDWithString:UIDString] : nil;
        media = UID != nil ? [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID] : nil;
        if (media == nil)
            media = [HSNewMedia mediaWithPath:path mediaUID:UID];
    }
    [self anotherImageObjectWithMedia:media];
}

@end
