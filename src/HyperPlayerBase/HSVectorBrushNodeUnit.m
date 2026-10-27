#import "HSVectorBrushNodeUnit.h"

// Node unit of a vector brush stroke: the recorded touches, the brush tool
// settings, and a cached rendering stored as a PNG media.
@implementation HSVectorBrushNodeUnit
+ (id)createNewTool
{
    return [BTBrushTool new];
}
// Moves the touches so the bounding rect starts at the origin; returns the
// offset applied.
- (NSSize)HSVectorBrushNodeUnit_normalizeStorageBounds
{
    NSRect bounds = [self toolBoundingRect];
    NSSize offset = NSMakeSize(-bounds.origin.x, -bounds.origin.y);
    [_touchStorage applyAffineTransform:CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, offset.width, offset.height)];
    _areBoundsValid = 0;
    return offset;
}
// Stores the renderer's current cache image as the cache media when it changed.
- (void)HSVectorBrushNodeUnit_recreateRendererCacheIfNeeded
{
    if (_brushRenderer == nil)
        return;
    if (_rendererCacheMedia && (CGImageRef)[_brushRenderer cacheImage] == _rendererCacheImage)
        return;
    CGImageRelease(_rendererCacheImage);
    _rendererCacheImage = (CGImageRef)[_brushRenderer cacheImage];
    CGImageRetain(_rendererCacheImage);
    [_rendererCacheMedia release];
    _rendererCacheMedia = nil;
    NSData *data = [self HSVectorBrushNodeUnit_rendererCacheImageData];
    if (data)
        _rendererCacheMedia = [[HSNewMedia mediaWithData:data name:@"brushImage" type:@"png"] retain];
}
static void HSVectorBrushNodeUnit_releaseData(void *aInfo, const void *aData, size_t aSize)
{
    [(id)aInfo release];
}
- (void)HSVectorBrushNodeUnit_createRendererCacheImageWithData:(id)aData
{
    if ([aData length] == 0)
        return;
    CGDataProviderRef provider = CGDataProviderCreateWithData(aData, [aData bytes], [aData length], HSVectorBrushNodeUnit_releaseData);
    if (provider == NULL)
        return;
    [aData retain];
    NSDictionary *options = [NSDictionary dictionaryWithObject:(id)kUTTypePNG forKey:(id)kCGImageSourceTypeIdentifierHint];
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, (CFDictionaryRef)options);
    CGDataProviderRelease(provider);
    if (source) {
        CGImageRelease(_rendererCacheImage);
        _rendererCacheImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);
    }
}
// PNG of the cache image converted to the display color space.
- (id)HSVectorBrushNodeUnit_rendererCacheImageData
{
    if (_rendererCacheImage == NULL)
        return nil;
    // Original: ColorSync's default display profile (CMGetDefaultProfileByUse 'dply').
    CGColorSpaceRef colorSpace = CGDisplayCopyColorSpace(CGMainDisplayID());
    if (colorSpace == NULL)
        return nil;
    CGImageRef image = CGImageCreateCopyWithColorSpace(_rendererCacheImage, colorSpace);
    CGColorSpaceRelease(colorSpace);
    if (image == NULL)
        return nil;
    NSMutableData *data = (NSMutableData *)CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypePNG, 1, NULL);
    if (destination == NULL) {
        CGImageRelease(image);
        return [data autorelease];
    }
    CGImageDestinationAddImage(destination, image, NULL);
    if (!CGImageDestinationFinalize(destination)) {
        CFRelease(data);
        data = nil;
    }
    CGImageRelease(image);
    CFRelease(destination);
    return [data autorelease];
}
- (struct CGImage *)HSVectorBrushNodeUnit_rendererCacheImage
{
    if (_rendererCacheImage == NULL && _rendererCacheMedia)
        [self HSVectorBrushNodeUnit_createRendererCacheImageWithData:[_rendererCacheMedia mediaData]];
    return _rendererCacheImage;
}
- (id)mediaUIDs
{
    id mediaUIDs = [super mediaUIDs];
    id cacheUID = [self rendererCacheImageUID];
    if (cacheUID) {
        if ([mediaUIDs count] == 0) {
            mediaUIDs = [NSSet setWithObject:cacheUID];
        } else {
            mediaUIDs = [NSMutableSet setWithSet:mediaUIDs];
            [mediaUIDs addObject:cacheUID];
        }
    }
    return mediaUIDs;
}
- (void)setRendererCacheImageUID:(id)aUID
{
    if ([[_rendererCacheMedia mediaUID] isEqual:aUID])
        return;
    [_rendererCacheMedia release];
    _rendererCacheMedia = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
    CGImageRelease(_rendererCacheImage);
    _rendererCacheImage = NULL;
    if (_brushRenderer)
        [_brushRenderer setCacheImage:[self HSVectorBrushNodeUnit_rendererCacheImage]];
}
- (id)rendererCacheImageUID
{
    [self HSVectorBrushNodeUnit_recreateRendererCacheIfNeeded];
    return [_rendererCacheMedia mediaUID];
}
- (void)setTouchStorageData:(id)aData
{
    HSUnarchiver *unarchiver = [[[HSUnarchiver alloc] initForReadingWithData:aData] autorelease];
    if (unarchiver)
        [self setTouchStorage:[[[BTBrushTouchStorage alloc] initWithCoder:unarchiver] autorelease]];
}
- (id)touchStorageData
{
    HSArchiver *archiver = [[HSArchiver new] autorelease];
    [_touchStorage encodeWithCoder:archiver];
    return [archiver archiverData];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"touchStorageData", @"rendererCacheImageUID", nil]];
}
- (void)setting:(id)aSetting didChangeInSerialization:(id)aSerialization
{
    id attributes = nil;
    if ([aSetting isEqualTo:@"drawColor"])
        attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSBrushColorAttribute)];
    else if ([aSetting isEqualTo:@"size"])
        attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSBrushThicknessAttribute), @protocol(HSVectorBrushToolBoundingRectAttribute), nil];
    if (attributes)
        [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [super setting:aSetting didChangeInSerialization:aSerialization];
    _areBoundsValid = 0;
    [_brushRenderer invalidateCache];
    if (attributes) {
        NSDictionary *userInfo = nil;
        if ([aSetting isEqualTo:@"size"]) {
            // A thicker brush grows the bounds; report how far the strokes moved.
            NSSize offset = [self HSVectorBrushNodeUnit_normalizeStorageBounds];
            userInfo = [NSDictionary dictionaryWithObject:[NSDictionary extraDictionaryWithSize:offset] forKey:@"HSVectorBrushToolBoundingRectOffset"];
        }
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:userInfo];
    }
}
- (void)setting:(id)aSetting willChangeInSerialization:(id)aSerialization
{
    NSUndoManager *undoManager = [self undoManager];
    NSString *actionName = [aSetting isEqualTo:@"size"] ? @"ChangeBrushThickness"
                         : [aSetting isEqualTo:@"drawColor"] ? @"ChangeBrushColor" : @"ChangeBrushSettings";
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:actionName value:@"" table:@"UndoManager"]];
    id settings = [aSerialization settings];
    if (aSetting == nil)
        [(HSSettingsSerialization *)[undoManager prepareWithInvocationTarget:aSerialization] setSettings:settings];
    else
        [(HSSettingsSerialization *)[undoManager prepareWithInvocationTarget:aSerialization] setSetting:[settings objectForKey:aSetting] forKey:aSetting];
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVectorBrushAttributes), aInterface))
        return [HSVectorBrushAttributesImplementation class];
    if (HSProtocolsAreEqual(@protocol(HSBrushMutableAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSGenericSolidColorAttributes), aInterface))
        return [HSBrushAttributesImplementation class];
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSVectorBrushAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSBrushMutableAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSGenericSolidColorAttributes), aInterface);
}
- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSVectorBrushAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSBrushMutableAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSGenericSolidColorAttributes)], nil];
}
- (id)brushRenderer
{
    if (_brushRenderer == nil) {
        _brushRenderer = [[HSVectorBrushRenderer alloc] initWithOwner:self];
        [_brushRenderer setCacheImage:[self HSVectorBrushNodeUnit_rendererCacheImage]];
    }
    return _brushRenderer;
}
- (NSRect)toolBoundingRect
{
    if (!_areBoundsValid && _touchStorage) {
        BTBrushTool *tool = [self tool];
        NSSize size = [tool size];
        NSSize shadowOffset = [tool shadowOffset];
        // No blur radius when a shadow mask is used.
        CGFloat blurRadius = [tool shadowMask] ? NAN : [tool shadowBlurRadius];
        _boundingRect = NSRectToCGRect([_touchStorage boundingRectForToolSize:size rotationAngle:[tool rotationAngle]
                                                                 shadowOffset:shadowOffset shadowBlurRadius:blurRadius]);
        _areBoundsValid = 1;
    }
    return NSRectFromCGRect(_boundingRect);
}
- (void)setTouchStorage:(id)aStorage
{
    if (_touchStorage != aStorage) {
        [_touchStorage release];
        _touchStorage = [aStorage retain];
        _areBoundsValid = 0;
        _isPatternPhaseSet = _touchStorage == nil;
    }
}
- (id)touchProvider
{
    return _touchStorage;
}
// Pattern brushes start their pattern at the first touch.
- (id)tool
{
    id tool = [super tool];
    if (!_isPatternPhaseSet) {
        CGPoint position = CGPointZero;
        [_touchStorage position:&position sizeDeviation:NULL rotationAngleDeviation:NULL opacityDeviation:NULL alternateColor:NULL
             colorHSVADeviation:NULL colorNativeDeviation:NULL shadowColorHSVADeviation:NULL shadowColorNativeDeviation:NULL forTouchAtIndex:0];
        [tool setUserPatternPhase:NSMakeSize(position.x, position.y)];
    }
    return tool;
}
- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSBrushColorAttribute), @protocol(HSBrushThicknessAttribute),
            @protocol(HSVectorBrushToolBoundingRectAttribute), nil];
}
- (void)dealloc
{
    [_brushRenderer release];
    CGImageRelease(_rendererCacheImage);
    [_rendererCacheMedia release];
    [_touchStorage release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self)
        _isPatternPhaseSet = 1;
    return self;
}
@end
