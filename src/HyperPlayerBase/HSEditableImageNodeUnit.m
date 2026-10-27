#import "HSEditableImageNodeUnit.h"
#import "HSEditableImageAttributesImplementation.h"
#import "HSNewMediaAccessor.h"
#import "HSMediaFileWrapper.h"
#import "HSProtocolIdentifier.h"
#import "NSImage+HSImageSize.h"
#import "CGEBitmapContext.h"

// An image that can be edited in place. Edits are announced as changes of
// HSImageAttribute carrying the changed rect, undone through the image's own
// undoer, and the media is regenerated (as PNG) from the edited image when
// asked for.
@implementation HSEditableImageNodeUnit

static size_t HSEditableImagePixelCount(CGFloat aLength)
{
    return 0.0f < (float)aLength ? (size_t)lroundf(ceilf((float)aLength)) : 0;
}

static CGContextRef HSEditableImageCreateBitmapContext(CGSize aSize)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return NULL;
    size_t width = HSEditableImagePixelCount(aSize.width);
    size_t height = HSEditableImagePixelCount(aSize.height);
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 0xf) & ~(size_t)0xf, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    return (CGContextRef)[(id)context autorelease];
}

+ (struct CGContext *)bitmapLayerForCocoaImage:(id)aImage
{
    CGContextRef context = HSEditableImageCreateBitmapContext([aImage imageSize]);
    if (context == NULL)
        return NULL;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
    if (graphicsContext == nil) {
        context = NULL;
    } else {
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:graphicsContext];
        [(id<BTCocoaImage>)aImage drawInCurrentNSGraphicsContextAtPoint:NSZeroPoint];
        [NSGraphicsContext restoreGraphicsState];
    }
    [pool release];
    return context;
}

+ (struct CGContext *)bitmapLayerForCGImage:(id)aImage
{
    CGContextRef context = HSEditableImageCreateBitmapContext([aImage imageSize]);
    if (context != NULL)
        [(id<BTCGImage>)aImage drawInCGContext:context atPoint:CGPointZero];
    return context;
}

- (void)imageUndoer:(id)aUndoer didChangeImageInRect:(CGRect)aRect
{
    if (_imageUndoer != aUndoer)
        return;
    [self notifyChange:2 ofAttribute:@protocol(HSImageAttribute) withUserInfo:[self HSEditableImageNodeUnit_notificationInfoWithChangedRect:aRect]];
    [self HSEditableImageNodeUnit_releaseMedia];
}

- (void)imageUndoer:(id)aUndoer willChangeImageInRect:(CGRect)aRect
{
    if (_imageUndoer == aUndoer)
        [self notifyChange:1 ofAttribute:@protocol(HSImageAttribute) withUserInfo:[self HSEditableImageNodeUnit_notificationInfoWithChangedRect:aRect]];
}

- (id)prepareUndoForImageUndoer:(id)aUndoer withInvocationTarget:(id)aTarget
{
    if (_imageUndoer != aUndoer)
        return nil;
    return [[self undoManager] BT_prepareWithInvocationTarget:aTarget];
}

- (void)registerUndoForImageUndoer:(id)aUndoer withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    if (_imageUndoer == aUndoer)
        [[self undoManager] BT_registerUndoWithTarget:aTarget selector:aSelector object:aObject];
}

- (void)setEditableImageMedia:(id)aMedia
{
    if (_media == aMedia)
        return;
    [_media release];
    _media = [aMedia retain];
    [_image release];
    _image = nil;
}

- (id)editableImageMedia
{
    return [self media];
}

- (void)endEditImage
{
    [self HSEditableImageNodeUnit_releaseMedia];
    [self notifyChange:2 ofAttribute:@protocol(HSImageAttribute) withUserInfo:_notificationInfo];
    [_notificationInfo release];
    _notificationInfo = nil;
    _isImageBeingEdited = NO;
}

- (void)beginEditImage:(id)aImage inRect:(NSRect)aRect
{
    if (_image != nil || aImage != nil)
        [self HSEditableImageNodeUnit_beginEditImage:aImage inRect:aRect];
}

- (void)beginEditImage:(id)aImage
{
    if (_image == nil && aImage == nil)
        return;
    CGSize size = [(_image != nil ? _image : aImage) imageSize];
    [self HSEditableImageNodeUnit_beginEditImage:aImage inRect:NSMakeRect(CGPointZero.x, CGPointZero.y, size.width, size.height)];
}

// Editing the current image registers an undo of the rect with its undoer
// (grouped while editing continuously); a new image replaces the current one
// with an undo of the replacement.
- (void)HSEditableImageNodeUnit_beginEditImage:(id)aImage inRect:(NSRect)aRect
{
    CGSize oldSize = _image != nil ? [_image imageSize] : CGSizeZero;
    CGSize newSize = aImage != nil ? [aImage imageSize] : CGSizeZero;
    _isImageBeingEdited = YES;
    NSDictionary *willInfo = nil;
    if (_image != nil) {
        CGRect changed = CGRectIntersection(CGRectMake(CGPointZero.x, CGPointZero.y, oldSize.width, oldSize.height), NSRectToCGRect(aRect));
        willInfo = [self HSEditableImageNodeUnit_notificationInfoWithChangedRect:changed];
    }
    [self notifyChange:1 ofAttribute:@protocol(HSImageAttribute) withUserInfo:willInfo];
    [self HSEditableImageNodeUnit_releaseMedia];
    if (_image == aImage) {
        if ([self undoManager] == nil)
            return;
        if (_imageUndoer == nil) {
            _imageUndoer = [(id<BTMutableImage>)_image createImageUndoerWithDelegate:self];
            if (_imageUndoer == nil)
                return;
        }
        if (!_isImageUndoGroupingBegun && _isImageUndoGroupingScheduled) {
            [_imageUndoer beginUndoGrouping];
            _isImageUndoGroupingScheduled = NO;
            _isImageUndoGroupingBegun = YES;
        }
        _notificationInfo = [willInfo retain];
        [_imageUndoer registerUndoInRect:NSRectToCGRect(aRect)];
        return;
    }
    if (aImage != nil) {
        if (_image == nil || oldSize.width != newSize.width || oldSize.height != newSize.height) {
            CGRect changed = CGRectIntersection(CGRectMake(CGPointZero.x, CGPointZero.y, newSize.width, newSize.height), NSRectToCGRect(aRect));
            _notificationInfo = [[self HSEditableImageNodeUnit_notificationInfoWithChangedRect:changed] retain];
        } else {
            _notificationInfo = [willInfo retain];
        }
    }
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil)
        [(HSEditableImageNodeUnit *)[undoManager BT_prepareWithInvocationTarget:self] HSEditableImageNodeUnit_setEditedImage:_image undoer:_imageUndoer
                                                                                  withWillNotificationInfo:willInfo didNotificationInfo:_notificationInfo];
    [aImage retain];
    [_image release];
    _image = aImage;
    if (_isImageUndoGroupingBegun) {
        [_imageUndoer endUndoGrouping];
        _isImageUndoGroupingBegun = NO;
        _isImageUndoGroupingScheduled = YES;
    }
    [_imageUndoer release];
    _imageUndoer = nil;
}

- (id)HSEditableImageNodeUnit_notificationInfoWithChangedRect:(CGRect)aRect
{
    NSValue *rect = [NSValue valueWithRect:NSRectFromCGRect(aRect)];
    if (rect == nil)
        return nil;
    return [NSDictionary dictionaryWithObject:rect forKey:@"HSChangedImageRect"];
}

- (void)endEditImageContinuously
{
    if (_isImageUndoGroupingBegun) {
        [_imageUndoer endUndoGrouping];
        _isImageUndoGroupingBegun = NO;
    }
    _isImageUndoGroupingScheduled = NO;
}

- (void)beginEditImageContinuously
{
    _isImageUndoGroupingScheduled = YES;
}

static Protocol *HSFirstProtocolNotConformedTo(id aObject, Protocol **aProtocols)
{
    for (; *aProtocols != nil; aProtocols++) {
        if (![aObject conformsToProtocol:*aProtocols])
            return *aProtocols;
    }
    return nil;
}

// Returns the image if it conforms to all required protocols, else a bitmap
// layer or NSImage-backed copy that does.
- (id)queryImageWithRequiredProtocols:(id *)aProtocols optionalProtocols:(id *)aProtocols2
{
    [self image];
    if (aProtocols == NULL)
        return _image;
    Protocol **required = (Protocol **)aProtocols;
    if (HSFirstProtocolNotConformedTo(_image, required) == nil)
        return _image;
    BOOL isCGImage = [_image conformsToProtocol:@protocol(BTCGImage)];
    if (isCGImage || [_image conformsToProtocol:@protocol(BTCocoaImage)]) {
        if (HSFirstProtocolNotConformedTo([BTCGBitmapLayer class], required) == nil) {
            CGContextRef context = isCGImage ? [[self class] bitmapLayerForCGImage:_image] : [[self class] bitmapLayerForCocoaImage:_image];
            if (context == NULL)
                return nil;
            return [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
        }
    }
    if (![_image conformsToProtocol:@protocol(BTCocoaImage)])
        return nil;
    if (HSFirstProtocolNotConformedTo([BTNSImage class], required) != nil)
        return nil;
    NSImage *image = [NSImage BT_imageWithBTCocoaImage:_image];
    if (image == nil)
        return nil;
    return [[[BTNSImage alloc] initWithNSImage:image] autorelease];
}

- (id)NSImage
{
    if ([self image] == nil || ![_image conformsToProtocol:@protocol(BTCocoaImage)])
        return nil;
    return [NSImage BT_imageWithBTCocoaImage:_image];
}

// Loaded lazily from the media, at its pixel size.
- (id)image
{
    if (_image == nil && [self mediaUID] != nil) {
        NSImage *image = [[[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[self mediaUID]] image] copy];
        if (image != nil) {
            NSSize size = [image hyperPixelsSize];
            [image setSize:size];
            NSEnumerator *e = [[image representations] objectEnumerator];
            NSImageRep *rep;
            while ((rep = [e nextObject]) != nil)
                [rep setSize:size];
            _image = [[BTNSImage alloc] initWithNSImage:image];
            [image release];
        }
    }
    return _image;
}

- (BOOL)hasImage
{
    return _image != nil || [self mediaUID] != nil;
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSEditableImageAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditableImageMediaAttributes), aInterface))
        return [HSEditableImageAttributesImplementation class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSEditableImageAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditableImageMediaAttributes), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSEditableImageAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSEditableImageMediaAttributes)], nil];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [self HSEditableImageNodeUnit_releaseMedia];
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"mediaUID"];
}

// Placeholder images are shared, others are copied through their media.
- (id)copyWithZone:(NSZone *)aZone
{
    HSEditableImageNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    if ([_image conformsToProtocol:@protocol(HSPlaceholderImage)] && _image != nil)
        [copy HSEditableImageNodeUnit_setEditedImage:_image undoer:nil withWillNotificationInfo:nil didNotificationInfo:nil];
    else
        [copy setMediaUID:[self mediaUID]];
    return copy;
}

- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocol:@protocol(HSImageAttribute)];
}

- (id)mediaUIDs
{
    return [NSSet setWithObjects:[self mediaUID], nil];
}

// Only media that has an image is kept.
- (void)setMediaUID:(id)aUID
{
    if ([[self mediaUID] isEqual:aUID])
        return;
    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID];
    id image = [media image];
    [_media release];
    _media = [(image != nil ? media : nil) retain];
}

- (id)mediaUID
{
    return [[self media] mediaUID];
}

- (id)media
{
    if (_media == nil && _image != nil && ![_image conformsToProtocol:@protocol(HSPlaceholderImage)]) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [self HSEditableImageNodeUnit_releaseMedia];
        NSData *data = [[NSBitmapImageRep imageRepWithData:[[self NSImage] TIFFRepresentation]] representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        if (data != nil && !_isImageBeingEdited)
            _media = [[HSNewMedia alloc] initWithData:data name:[NSString hyperUIDString] type:@"png"];
        [pool release];
    }
    return _media;
}

// Undoing swaps the will and did notification infos.
- (void)HSEditableImageNodeUnit_setEditedImage:(id)aImage undoer:(id)aUndoer withWillNotificationInfo:(id)aInfo didNotificationInfo:(id)aInfo2
{
    [self notifyChange:1 ofAttribute:@protocol(HSImageAttribute) withUserInfo:aInfo];
    [(HSEditableImageNodeUnit *)[[self undoManager] BT_prepareWithInvocationTarget:self] HSEditableImageNodeUnit_setEditedImage:_image undoer:_imageUndoer
                                                                                         withWillNotificationInfo:aInfo2 didNotificationInfo:aInfo];
    [aImage retain];
    [_image release];
    _image = aImage;
    if (_isImageUndoGroupingBegun) {
        [_imageUndoer endUndoGrouping];
        _isImageUndoGroupingBegun = NO;
        _isImageUndoGroupingScheduled = YES;
    }
    [aUndoer retain];
    [_imageUndoer release];
    _imageUndoer = aUndoer;
    [self HSEditableImageNodeUnit_releaseMedia];
    [self notifyChange:2 ofAttribute:@protocol(HSImageAttribute) withUserInfo:aInfo2];
}

- (void)HSEditableImageNodeUnit_releaseMedia
{
    [_media release];
    _media = nil;
}

- (void)dealloc
{
    [_imageUndoer release];
    [_media release];
    [_image release];
    [super dealloc];
}

@end
