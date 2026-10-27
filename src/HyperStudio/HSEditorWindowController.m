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

+ (void)setTransform:(CGAffineTransform)aTransform toBitmapTool:(id)aTool
{
    id bitmapTool = [aTool bitmapTool];
    [bitmapTool finalizeSelection:nil];
    [bitmapTool setSelectionAffineTransform:aTransform flippingHorizontally:NO];
}

+ (void)applyTransform:(CGAffineTransform)aTransform toTransformableObject:(id)aObject
{
    id applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier != nil) {
        CGAffineTransform current = [[applier mutableGeometryAttributes] affineTransform];
        [applier setAffineTransform:CGAffineTransformConcat(current, aTransform) withLayoutGuidingContext:nil];
    }
}

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

- (void)HSEditorWindowController_modeSwitcherDidEndModeSwitching:(id)aSwitching
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSModeSwitcherDidEndModeSwitchingNotification" object:[aSwitching object]];
    [_statusbarController validateUI];
}

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

- (void)editFeatures:(id)aFeatures
{
    HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
    if (![assistant isActive]) {
        [assistant setActive:YES explicitlyByUser:YES];
    }
    [[self cardView] saveRunTimeEditors];
    [[assistant objectAssistant] openPaneWithIdentifier:@"HSGenericObjectFeaturesAssistantPane"];
}

- (void)editActions:(id)aActions
{
    [[self cardView] saveRunTimeEditors];
    HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
    if (![assistant isActive]) {
        [assistant setActive:YES explicitlyByUser:YES];
    }
    [[assistant objectAssistant] openPaneWithIdentifier:@"HSActionsAssistantPane"];
}

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
}

- (void)showCardOptionsDialog:(id)aDialog
{
    [self switchToToolWithTag:1];
    [self selectActiveCardAndShowInspector];
}

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

- (void)addImageToBackgroundAndSwitchToBitmapSelectionTool:(id)aTool inRect:(NSRect)aRect
{
    [_cardView addImageToBackgroundAndSwitchToBitmapSelectionTool:aTool inRect:aRect];
}

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

- (void)setSettingsForGraphicImportDialogController:(id)aController
{
    [aController setOptions:[NSDictionary dictionaryWithObject:[self selectionToolTolerance] forKey:@"selectionTolerance"]];
}

- (id)selectionToolTolerance
{
    id tolerance = [[[HSToolManager sharedToolManager] toolSettings] settingForIdentifier:@"HSLassoSelectionTool" andKey:@"selectionTolerance"];
    if (tolerance == nil) {
        tolerance = [NSNumber numberWithFloat:0.0f];
    }
    return tolerance;
}

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

- (void)hyperShowGuessPanel:(id)aPanel
{
    if ([[HSToolManager sharedToolManager] currentToolSet] == nil && [[[self document] currentCard] hyperCount] == 0
        && [[self selectedHyperObject] queryHyperInterface:@protocol(HSRunTimeEditor)] != nil) {
        [NSApp sendAction:@selector(showGuessPanel:) to:[[self window] firstResponder] from:aPanel];
        return;
    }
    [[HSTextProvider sharedInstance] performShowGuessPanel:aPanel];
}

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

- (void)runEasyLinkDialog:(id)aDialog
{
    id controller = [[HSEasyLinkDialogController alloc] initWithContext:[[self document] editObjectDialogContext]];
    [controller runModal];
    [controller release];
}

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

- (void)openHypertextLinksPane:(id)aPane
{
    id selected = [[self document] selectedHyperObject];
    id object = (selected != nil) ? [selected hyperObject] : [[self document] currentCard];
    [[HSObjectAssistantController sharedAssistantController] openHypertextLinksPaneForField:selected selectedObject:object initialText:aPane stack:[[self document] stack]];
}

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

- (void)runVideoRecordingPanel:(id)aPanel
{
    [self videoRecordingDidEndWithCode:[[self videoRecordingController] runModal]];
}

- (void)runSoundRecordingPanel:(id)aPanel
{
    id code = (id)[[self soundRecordingController] runModal];
    if (_playSoundActionEvent == nil) {
        _playSoundActionEvent = [[HSActionEvent actionEventOfType:kHSArriveActionEventType] retain];
    }
    [self soundRecordingDidEndWithCode:(NSInteger)code];
}

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

- (void)delete:(id)aDelete
{
    if ([self selectedCardObject] != nil) {
        [[self cardView] performSelector:@selector(delete:) withObject:aDelete];
    } else if ([self canDeleteSelectedObjectInSelectionHolder:nil]) {
        [self deleteSelectedObjectInSelectionHolder:nil];
    }
}

- (void)cut:(id)aCut
{
    if ([self selectedCardObject] != nil) {
        [[self cardView] performSelector:@selector(cut:) withObject:aCut];
    } else if ([self canDeleteSelectedObjectInSelectionHolder:nil]) {
        [self copy:aCut];
        [self deleteSelectedObjectInSelectionHolder:nil showAlert:NO];
    }
}

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

- (NSRect)bestWindowFrameForCurrentStack
{
    NSRect windowFrame = [[self window] frame];
    NSRect documentFrame = [[_cardScrollView documentView] frame];
    NSSize contentSize = [(NSScrollView *)_cardScrollView contentSize];
    return NSMakeRect(windowFrame.origin.x, windowFrame.origin.y, (documentFrame.size.width - contentSize.width) + windowFrame.size.width, (documentFrame.size.height - contentSize.height) + windowFrame.size.height);
}

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

- (void)mouseMoved:(id)aMoved
{
    [[self cardView] handleMouseMoved:aMoved];
    [[HSAEditorApplication sharedHyperApplication] noteMainWindowDidHandleMouseMovedEvent];
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

- (void)addSoundComboDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1) {
        [NSApp sendAction:[aDialog action] to:nil from:nil];
    }
    [aDialog autorelease];
}

- (void)captureDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self importBackgroundDialogDidEnd:_importDialogControllerActiveLast returnCode:aCode contextInfo:aDialog];
    [aDialog autorelease];
}

- (void)cardViewOccupiedByToolDidChange:(id)aChange
{
    [[self statusbarController] validateUI];
}

- (void)easyLinkDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aDialog autorelease];
}

- (void)textFieldTamerDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aDialog autorelease];
}

- (void)importMovieDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1) {
        [NSApp sendAction:[aDialog action] to:nil from:nil];
    }
    [aDialog autorelease];
}

- (void)openEffectsDialog:(id)aDialog didEndWithReturnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
}

- (void)soundAddingOptionsDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aDialog orderOut:nil];
    id delegate = [aDialog delegate];
    if (aCode == 1) {
        _playSoundActionEvent = [[delegate selectedActionEvent] retain];
    }
    [delegate autorelease];
    if (_playSoundActionEvent != nil) {
        HSAddSoundComboDialog *dialog = [HSAddSoundComboDialog new];
        if ([dialog runModal] == 1) {
            [NSApp sendAction:[dialog action] to:nil from:nil];
        }
        [dialog release];
    }
}

- (void)importSoundObjectDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSString *fileName = [_importSoundObjectDialogController fileName];
    if (fileName == nil) {
        return;
    }
    NSString *path = [self checkFileExistenceAtPath:fileName expectedType:kHSSoundFileType];
    if (aCode != 1 || path == nil) {
        return;
    }
    if (_playSoundActionEvent == nil) {
        _playSoundActionEvent = [[HSActionEvent actionEventOfType:kHSArriveActionEventType] retain];
    }
    id actor = [[[self document] currentCard] queryHyperInterface:@protocol(HSActor)];
    HSMovie *movie = nil;
    id item = nil;
    id action = nil;
    if (actor != nil) {
        id media = [self reusableMediaForPath:path contentFilter:[[HSLibraryManager sharedLibraryManager] soundsContentFilter]];
        if (media != nil) {
            movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:nil];
            if (movie != nil) {
                item = [[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:movie];
                if (item != nil) {
                    action = [HSPlaySoundAction new];
                    id existing = [actor hyperActionsOfType:[HSPlaySoundAction actionType] forEvent:_playSoundActionEvent];
                    [action addSound:item];
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
    [item release];
    [action release];
}

- (void)importMediaObjectDialogDidEnd:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != 1) {
        return;
    }
    id arriveEvent = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    id playable = [[_importMoviesObjectDialogController dialogUserOptions] valueForKey:HSImportDialogMoviesInUseOptionKeyPlayableObject];
    NSString *path = [self checkFileExistenceAtPath:[_importMoviesObjectDialogController fileName] expectedType:kHSMovieFileType];
    id object = nil;
    if (![playable implementsHyperInterface:@protocol(HSMovieObjectAttributes)] && path == nil) {
        if ([playable implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
            object = [playable copy];
            [[self cardView] addObjectToCenter:object useDragPreferences:NO];
            [object release];
        }
    } else if (path != nil) {
        NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
        if ([HSMovieObject isMediaTypeSupported:fileType] && [[HSEditorController sharedDocumentController] canImportFileAtPath:path showAlert:YES]) {
            id card = [[self document] currentCard];
            id media = [self reusableMediaForPath:path contentFilter:[[HSLibraryManager sharedLibraryManager] moviesContentFilter]];
            NSError *error = nil;
            BOOL copied = NO;
            if (playable == nil) {
                object = [[HSMovieObject alloc] initWithMedia:media error:&error];
                if (object != nil) {
                    NSArray *verified = [self verifyObjects:[NSArray arrayWithObject:object] beforeAddToCard:card];
                    if ([verified count] != 0) {
                        [object release];
                        object = [[verified lastObject] retain];
                    }
                }
            } else {
                object = [playable copy];
                [object setHyperUID:[HSUID UID]];
                id actor = [object queryHyperInterface:@protocol(HSActor)];
                id actions = [actor hyperActions];
                if ([actions count] != 0) {
                    [actor removeActions:actions];
                }
                copied = object != nil;
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
            } else {
                if ([[self document] prepareForHandlingActionThatRequiresConditionalSwitchToEditMode]) {
                    id nodeChild = [object queryHyperInterface:@protocol(HSNodeChild)];
                    if (nodeChild != nil && !copied) {
                        [nodeChild setSupport:[card support]];
                        NSSize cardSize = [[card queryHyperInterface:@protocol(HSSizeAttributes)] size];
                        id sizeAttributes = [object queryHyperInterface:@protocol(HSMutableSizeAttributes)];
                        NSSize objectSize = [sizeAttributes size];
                        if (sizeAttributes != nil && (cardSize.width < objectSize.width || cardSize.height < objectSize.height || cardSize.width * cardSize.height * 0.9 < objectSize.width * objectSize.height)) {
                            [[card undoManager] disableUndoRegistration];
                            CGFloat ratio = objectSize.width / objectSize.height;
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
                    [[object queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoPlayActionEvent:arriveEvent];
                    NSString *comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:path]];
                    if (comments != nil && [comments length] != 0) {
                        [[object queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
                    }
                    [[self cardView] addObjectToCenter:object useDragPreferences:NO];
                }
                [object release];
            }
        }
    }
    [self didAddNewObject];
}

- (void)hideFixedToolbars
{
    BOOL toolbarVisible = [[[self toolbarController] toolbar] isVisible];
    _wasToolbarVisible = toolbarVisible;
    if (toolbarVisible) {
        [[[self toolbarController] toolbar] setVisible:NO];
    }
    BOOL bottomVisible = [self isBottomToolbarVisible];
    _wasBottomToolbarVisible = bottomVisible;
    if (bottomVisible) {
        [[[self document] playerInEditorWindowController] setBottomToolbarVisible:NO];
        [self setBottomToolbarVisible:NO];
    }
    BOOL stripVisible = [[self stackController] isStripVisible];
    _wasCardIndexVisible = stripVisible;
    if (stripVisible) {
        id stackController = [self stackController];
        if ([stackController respondsToSelector:@selector(hideCardIndexWithoutAnimation)]) {
            [stackController hideCardIndexWithoutAnimation];
        }
    }
}

- (void)hideFloatingPalettes
{
    _wasToolPaletteVisible = [[HSToolPaletteController sharedInstance] isPaletteVisible];
    if (_wasToolPaletteVisible) {
        [[HSToolPaletteController sharedInstance] hidePalette];
    }
    _wasLibraryPaletteVisible = [[HSLibraryController sharedLibraryController] isLibraryVisible];
    if (_wasLibraryPaletteVisible) {
        [[HSLibraryController sharedLibraryController] hideLibrary];
    }
    _wasLayoutPaletteVisible = [[HSLayoutPaletteController sharedInstance] isPaletteVisible];
    if (_wasLayoutPaletteVisible) {
        [[HSLayoutPaletteController sharedInstance] hidePalette];
    }
    _wasObjectListPaletteVisible = [[HSObjectListPaletteController sharedInstance] isPaletteVisible];
    if (_wasObjectListPaletteVisible) {
        [[HSObjectListPaletteController sharedInstance] hidePalette];
    }
    _wasCommentsAndAttributionsPaletteVisible = [[HSCommentsAndAttributionsPaletteController sharedInstance] isPaletteVisible];
    if (_wasCommentsAndAttributionsPaletteVisible) {
        [[HSCommentsAndAttributionsPaletteController sharedInstance] hidePalette];
    }
    _wasShortcutsPaletteVisible = [[HSShortcutsPaletteController sharedInstance] isPaletteVisible];
    if (_wasShortcutsPaletteVisible) {
        [[HSShortcutsPaletteController sharedInstance] hidePalette];
    }
    _wasObjectAssistantVisible = [[[HSObjectAssistantController sharedAssistantController] objectAssistant] isActive];
    if (_wasObjectAssistantVisible) {
        [[[[HSObjectAssistantController sharedAssistantController] objectAssistant] window] setAlphaValue:0];
    }
}

- (void)restoreFixedToolbars
{
    if (_wasToolbarVisible) {
        [[[self toolbarController] toolbar] setVisible:YES];
    }
    if (_wasBottomToolbarVisible) {
        [[[self document] playerInEditorWindowController] setBottomToolbarVisible:YES];
        [self setBottomToolbarVisible:YES];
    }
    if (_wasCardIndexVisible) {
        id stackController = [self stackController];
        if ([stackController respondsToSelector:@selector(showCardIndexWithoutAnimation)]) {
            [stackController showCardIndexWithoutAnimation];
        }
    }
}

- (void)restoreFloatingPalettes
{
    if (_wasToolPaletteVisible) {
        [[HSToolPaletteController sharedInstance] showPalette];
    }
    if (_wasLibraryPaletteVisible) {
        [[HSLibraryController sharedLibraryController] showLibrary];
    }
    if (_wasLayoutPaletteVisible) {
        [[HSLayoutPaletteController sharedInstance] showPalette];
    }
    if (_wasObjectListPaletteVisible) {
        [[HSObjectListPaletteController sharedInstance] showPalette];
    }
    if (_wasCommentsAndAttributionsPaletteVisible) {
        [[HSCommentsAndAttributionsPaletteController sharedInstance] showPalette];
    }
    if (_wasShortcutsPaletteVisible) {
        [[HSShortcutsPaletteController sharedInstance] showPalette];
    }
    if (_wasObjectAssistantVisible) {
        [[[[HSObjectAssistantController sharedAssistantController] objectAssistant] window] setAlphaValue:1];
    }
}

- (void)inspectorsRestoration
{
    if (![[HSEditorController sharedDocumentController] isInViewingMode]) {
        return;
    }
    if (_wasToolPaletteVisible) {
        [[HSToolPaletteController sharedInstance] showPalette];
    }
    if (_wasLibraryPaletteVisible) {
        [[HSLibraryController sharedLibraryController] showLibrary];
    }
    if (_wasLayoutPaletteVisible) {
        [[HSLayoutPaletteController sharedInstance] showPalette];
    }
    if (_wasObjectListPaletteVisible) {
        [[HSObjectListPaletteController sharedInstance] showPalette];
    }
    if (_wasCommentsAndAttributionsPaletteVisible) {
        [[HSCommentsAndAttributionsPaletteController sharedInstance] showPalette];
    }
    if (_wasShortcutsPaletteVisible) {
        [[HSShortcutsPaletteController sharedInstance] showPalette];
    }
    BOOL toolbarVisible = [[[self toolbarController] toolbar] isVisible];
    if (_wasToolbarVisible != toolbarVisible) {
        [self hideShowToolbar:self];
    }
    id stackController = [self stackController];
    SEL indexSelector = _wasCardIndexVisible ? @selector(showCardIndex:) : @selector(hideCardIndex:);
    if ([stackController respondsToSelector:indexSelector]) {
        [stackController performSelector:indexSelector];
    }
    [self setBottomToolbarVisible:_wasBottomToolbarVisible];
    [_statusbarController validateUI];
    if (_wasMenuVisible) {
        [[HSSystemUI sharedSystemUI] setupWithMode:0 options:0];
    }
    if (_wasObjectAssistantVisible) {
        [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:YES];
    }
}

- (BOOL)isCurrentCardNotTitle
{
    return [[[[self document] currentCard] queryHyperInterface:@protocol(HSNodeChild)] hyperIndex] != 0;
}

- (void)mediaStripSwitcherDidShowMediaStrip
{
    if (_isNibLoaded) {
        id state = [self documentWindowStateDictionary];
        [state setObject:[NSNumber numberWithBool:YES] forKey:@"HSCardBrowserVisibleKey"];
        [self commitToDocumentWindowStatesDictionary:state];
    }
}

- (void)mediaStripSwitcherWillHideMediaStrip
{
    if (_isNibLoaded) {
        id state = [self documentWindowStateDictionary];
        [state setObject:[NSNumber numberWithBool:NO] forKey:@"HSCardBrowserVisibleKey"];
        [self commitToDocumentWindowStatesDictionary:state];
    }
}

- (Class)navigationControllerClass
{
    return [HSEditorNavigationController class];
}

- (void)navigationControllerDidFinishNavigationOperation:(id)aOperation
{
    [_statusbarController validateUI];
}

- (void)nodeContainer:(id)aContainer didLoadChildren:(id)aChildren
{
    if (![[self document] isInPlayerMode] && [[self document] isInStandardMode]) {
        return;
    }
    if ([aContainer implementsHyperInterface:@protocol(HSCardAttributes)]) {
        [[aContainer animationController] presentationIsStarting];
    }
}

- (void)notifyDidEnterVersionBrowser:(id)aBrowser
{
    [[HSEditorController sharedDocumentController] setViewingMode:YES];
    if (_wasBottomToolbarVisible) {
        [_statusbarController validateUI];
    }
    [super notifyDidEnterVersionBrowser:aBrowser];
}

- (void)notifyDidExitVersionBrowser:(id)aBrowser
{
    [self inspectorsRestoration];
    [[HSEditorController sharedDocumentController] setViewingMode:NO];
    [_statusbarController validateUI];
    [super notifyDidExitVersionBrowser:aBrowser];
}

- (void)notifyWillEnterVersionBrowser:(id)aBrowser
{
    _wasToolPaletteVisible = [[HSToolPaletteController sharedInstance] isPaletteVisible];
    if (_wasToolPaletteVisible) {
        [[HSToolPaletteController sharedInstance] hidePalette];
    }
    _wasLibraryPaletteVisible = [[HSLibraryController sharedLibraryController] isLibraryVisible];
    if (_wasLibraryPaletteVisible) {
        [[HSLibraryController sharedLibraryController] hideLibrary];
    }
    _wasLayoutPaletteVisible = [[HSLayoutPaletteController sharedInstance] isPaletteVisible];
    if (_wasLayoutPaletteVisible) {
        [[HSLayoutPaletteController sharedInstance] hidePalette];
    }
    _wasObjectListPaletteVisible = [[HSObjectListPaletteController sharedInstance] isPaletteVisible];
    if (_wasObjectListPaletteVisible) {
        [[HSObjectListPaletteController sharedInstance] hidePalette];
    }
    _wasCommentsAndAttributionsPaletteVisible = [[HSCommentsAndAttributionsPaletteController sharedInstance] isPaletteVisible];
    if (_wasCommentsAndAttributionsPaletteVisible) {
        [[HSCommentsAndAttributionsPaletteController sharedInstance] hidePalette];
    }
    _wasShortcutsPaletteVisible = [[HSShortcutsPaletteController sharedInstance] isPaletteVisible];
    if (_wasShortcutsPaletteVisible) {
        [[HSShortcutsPaletteController sharedInstance] hidePalette];
    }
    _wasToolbarVisible = [[[self toolbarController] toolbar] isVisible];
    if (_wasToolbarVisible) {
        [self hideShowToolbar:self];
    }
    _wasCardIndexVisible = [[self stackController] isStripVisible];
    if (!_wasCardIndexVisible) {
        id stackController = [self stackController];
        if ([stackController respondsToSelector:@selector(showCardIndex:)]) {
            [stackController showCardIndex:self];
        }
    }
    _wasBottomToolbarVisible = [self isBottomToolbarVisible];
    if (_wasBottomToolbarVisible) {
        [[[self document] playerInEditorWindowController] setBottomToolbarVisible:NO];
        [self setBottomToolbarVisible:NO];
    }
    _wasMenuVisible = [[[self document] stack] isPresentationMenuVisible];
    if (_wasMenuVisible) {
        [[HSSystemUI sharedSystemUI] setupWithMode:3 options:1];
    }
    _wasObjectAssistantVisible = [[[HSObjectAssistantController sharedAssistantController] objectAssistant] isActive];
    if (_wasObjectAssistantVisible) {
        [[HSObjectAssistantController sharedAssistantController] setActive:NO explicitlyByUser:YES];
    }
    [super notifyWillEnterVersionBrowser:aBrowser];
}

- (void)objectAssistantLockStateDidChange:(id)aChange
{
    [[self statusbarController] validateUI];
}

- (void)refreshObjectsAssistant
{
    if (_selectedObjectForAssistantRefresh != nil) {
        if (![[self document] isModalSessionPresent]) {
            [[HSObjectAssistantController sharedAssistantController] performSelector:@selector(openDefaultEditingPaneForObject:) withObject:_selectedObjectForAssistantRefresh afterDelay:0];
        }
        _selectedObjectForAssistantRefresh = nil;
    }
}

- (void)setSelectedObjectForAssistantRefresh:(id)aRefresh
{
    _selectedObjectForAssistantRefresh = aRefresh;
}

- (void)storeDocumentWindowState:(id)aState
{
    [super storeDocumentWindowState:aState];
    id hyperCardView = [[_cardScrollView documentView] queryHyperInterface:@protocol(HSCardViewOffset)];
    NSSize offset = NSZeroSize;
    if (hyperCardView != nil) {
        offset = [hyperCardView cardOffset];
    }
    NSRect bounds = NSZeroRect;
    if ([_cardScrollView contentView] != nil) {
        bounds = [[_cardScrollView contentView] bounds];
    }
    NSPoint scrollPoint = NSMakePoint(bounds.origin.x - offset.width, bounds.origin.y - offset.height);
    [aState setObject:NSStringFromPoint(scrollPoint) forKey:@"HSEditorScrollPointKey"];
    if (![[self document] isInPresentationMode]) {
        [aState setObject:[NSNumber numberWithBool:[[self stackView] isStripVisible]] forKey:@"HSCardBrowserVisibleKey"];
    } else {
        [aState setValue:[NSNumber numberWithBool:_wasToolbarVisible] forKey:@"HSToolbarVisibleKey"];
        [aState setValue:[NSNumber numberWithBool:_wasBottomToolbarVisible] forKey:@"HSBottomToolbarVisibleKey"];
        [aState setObject:[NSNumber numberWithBool:_wasCardIndexVisible] forKey:@"HSCardBrowserVisibleKey"];
    }
}

- (id)swipeTracker
{
    if (_swipeTracker == nil) {
        _swipeTracker = [HSFluidSwipeTracker new];
    }
    return _swipeTracker;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    if ([[self document] isTutorialStack]) {
        [[self window] setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
        [[self window] setCollectionBehavior:0];
    }
    [[self swipeTracker] setNextResponder:[_cardScrollView nextResponder]];
    [_cardScrollView setNextResponder:[self swipeTracker]];
    _selectedObjectForAssistantRefresh = nil;
}

- (BOOL)windowShouldClose:(id)aClose
{
    return ![[self document] isModalSessionPresent];
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

