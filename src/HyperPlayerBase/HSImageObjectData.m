#import "HSImageObjectData.h"
#import "HSCroppedImageLegacyStoring.h"
#import "HSImage.h"
#import "HSNode.h"
#import "NSBezierPath+HSBinarySerialization.h"

// The node data of an image object: the original and effected images, the
// border, the relative image (crop) rect and the initial clip paths.
@implementation HSImageObjectData

+ (id)nodeDataKeysToNodeKeysMap
{
    id map = [super nodeDataKeysToNodeKeysMap];
    [map setObject:@"imageObject" forKey:@"image"];
    return map;
}

// The original image's media UID is stored under "originalMediaUIDPost670Format"
// now; older stacks have it as "originalMediaUID", "effectedMediaUID" or the
// "image" dictionary's "imageUID".
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableDictionary *representation = [aRepresentation mutableCopy];
    id UID = [representation objectForKey:@"originalMediaUIDPost670Format"];
    if (UID == nil)
        UID = [representation objectForKey:@"originalMediaUID"];
    if (UID == nil) {
        UID = [representation objectForKey:@"effectedMediaUID"];
        if (UID != nil) {
            [[UID retain] autorelease];
            [representation removeObjectForKey:@"effectedMediaUID"];
        }
    }
    if (UID == nil)
        UID = [[representation objectForKey:@"image"] objectForKey:@"imageUID"];
    if (UID != nil) {
        [representation setObject:UID forKey:@"originalMediaUIDPost670Format"];
        [representation removeObjectForKey:@"originalMediaUID"];
        [representation removeObjectForKey:@"image"];
    }
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
    [representation release];
    // An effected image that is the original one is dropped.
    id originalUID = [self originalMediaUIDPost670Format];
    if (originalUID != nil && [[self effectedMediaUID] isEqual:originalUID])
        [[self effectedImage] setMedia:nil];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"borderPath"];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"image"];
    [keys addObject:@"opacity"];
    [keys addObject:@"bordered"];
    [keys addObject:@"borderColor"];
    [keys addObject:@"borderWidth"];
    [keys addObject:@"relativeBorderPath"];
    [keys addObject:@"canBeHighlighted"];
    [keys addObject:@"originalMediaUID"];
    [keys addObject:@"relativeImageRectAsString"];
    [keys addObject:@"originalMediaUIDPost670Format"];
    [keys addObject:@"effectedMediaUID"];
    [keys addObject:@"binaryInitialClipPaths"];
    [keys addObject:@"canRestoreClipPathsNumber"];
    return keys;
}

- (id)undoManagerForGraphics:(id)aGraphics
{
    return [[[self owner] anyOwningObjectForNodeData:self] undoManager];
}

- (void)hyperVisualAttributesChanged:(id)aChanged
{
    [[[self owner] anyOwningObjectForNodeData:self] hyperVisualAttributesChanged:aChanged];
}

- (void)setRelativeImageRectAsString:(id)aString
{
    _relativeImageRect = NSRectFromString(aString);
}

- (id)relativeImageRectAsString
{
    return NSStringFromRect(_relativeImageRect);
}

- (void)setRelativeImageRect:(NSRect)aRect
{
    _relativeImageRect = aRect;
}

// The whole image when not set.
- (NSRect)relativeImageRect
{
    if (NSEqualRects(NSZeroRect, _relativeImageRect))
        _relativeImageRect = NSMakeRect(0, 0, 1, 1);
    return _relativeImageRect;
}

- (void)setCanRestoreClipPathsNumber:(id)aNumber
{
    if (aNumber != nil)
        [self setCanRestoreToInitialClipPaths:[aNumber boolValue]];
}

- (id)canRestoreClipPathsNumber
{
    return [NSNumber numberWithBool:[self canRestoreToInitialClipPaths]];
}

- (void)setCanRestoreToInitialClipPaths:(BOOL)aPaths
{
    _canRestoreToInitialClipPaths = aPaths;
}

- (BOOL)canRestoreToInitialClipPaths
{
    return _canRestoreToInitialClipPaths;
}

- (void)setInitialClipPaths:(id)aPaths
{
    if (_initialClipPaths == aPaths)
        return;
    [_initialClipPaths release];
    _initialClipPaths = [aPaths retain];
}

- (id)initialClipPaths
{
    return _initialClipPaths;
}

- (void)setBinaryInitialClipPaths:(id)aPaths
{
    [self setInitialClipPaths:[NSBezierPath hyperCGPathsFromBinaryStoredDataArray:aPaths]];
}

- (id)binaryInitialClipPaths
{
    return [NSBezierPath hyperBinaryDataArrayForStoringFromCGPaths:_initialClipPaths];
}

- (void)setCanBeHighlighted:(BOOL)aHighlighted
{
    _canBeHighlighted = aHighlighted;
}

- (BOOL)canBeHighlighted
{
    return _canBeHighlighted;
}

- (void)setRelativeBorderPath:(id)aPath
{
    if (_relativeBorderPath == aPath)
        return;
    [_relativeBorderPath release];
    _relativeBorderPath = [aPath retain];
}

- (id)relativeBorderPath
{
    return _relativeBorderPath;
}

- (void)setBorderPath:(id)aPath
{
    if (_borderPath == aPath)
        return;
    [_borderPath release];
    _borderPath = [aPath retain];
}

- (id)borderPath
{
    return _borderPath;
}

- (void)setBorderWidth:(CGFloat)aWidth
{
    _borderWidth = aWidth;
}

- (CGFloat)borderWidth
{
    return _borderWidth;
}

- (void)setBorderColor:(id)aColor
{
    [aColor retain];
    [_borderColor release];
    _borderColor = aColor;
}

// Black when not set.
- (id)borderColor
{
    if (_borderColor == nil)
        _borderColor = [[NSColor blackColor] retain];
    return _borderColor;
}

- (void)setBordered:(BOOL)aBordered
{
    _bordered = aBordered;
}

- (BOOL)isBordered
{
    return _bordered;
}

// The effected image when it has media.
- (id)currentImage
{
    if ([[self effectedImage] imageUID] != nil)
        return [self effectedImage];
    return [self originalImage];
}

- (void)setEffectedMediaUID:(id)aUID
{
    [[self effectedImage] setHyperImageUID:aUID];
}

- (id)effectedMediaUID
{
    return [[self effectedImage] imageUID];
}

- (void)setEffectedImage:(id)aImage
{
    if (_effectedImage == aImage)
        return;
    [_effectedImage setHyperOwner:nil];
    [_effectedImage release];
    _effectedImage = [aImage retain];
    [_effectedImage setHyperOwner:self];
}

- (id)effectedImage
{
    return _effectedImage;
}

// Read only (the old storing key).
- (void)setOriginalMediaUID:(id)aUID
{
}

- (id)originalMediaUID
{
    return [[self currentImage] imageUID];
}

- (void)setOriginalMediaUIDPost670Format:(id)aFormat
{
    [[self originalImage] setHyperImageUID:aFormat];
}

- (id)originalMediaUIDPost670Format
{
    return [[self originalImage] imageUID];
}

- (void)setOriginalImage:(id)aImage
{
    if (_originalImage == aImage)
        return;
    [_originalImage setHyperOwner:nil];
    [_originalImage release];
    _originalImage = [aImage retain];
    [_originalImage setHyperOwner:self];
}

- (id)originalImage
{
    return _originalImage;
}

- (id)legacyCroppedImageMedia
{
    return [[self croppedImageLegacyStoring] legacyCroppedImageMedia];
}

- (void)setLegacyCroppedImageMedia:(id)aMedia
{
    [[self croppedImageLegacyStoring] setLegacyCroppedImageMedia:aMedia];
}

// Read only (stored for objects with an effect per object).
- (void)setImage:(id)aImage
{
}

- (id)image
{
    id effectAttributes = [[[self owner] anyOwningObjectForNodeData:self] queryHyperInterface:@protocol(HSCardObjectEffectPerObjectAttribute)];
    if (![effectAttributes hasEffectPerObject])
        return nil;
    return [self croppedImageLegacyStoring];
}

- (id)croppedImageLegacyStoring
{
    if (_legacyImageStoring == nil)
        _legacyImageStoring = [[HSCroppedImageLegacyStoring alloc] initWithOwner:self];
    return _legacyImageStoring;
}

- (id)imageObjectForLegacyImageStoring:(id)aStoring
{
    return [[self owner] anyOwningObjectForNodeData:self];
}

- (void)willRemoveOwningObjectFromDocument:(id)aDocument
{
    [super willRemoveOwningObjectFromDocument:aDocument];
    [_originalImage willRemoveFromDocument];
    [_effectedImage willRemoveFromDocument];
}

- (void)didAddOwningObjectToDocument:(id)aDocument
{
    [super didAddOwningObjectToDocument:aDocument];
    [_originalImage didAddToDocument];
    [_effectedImage didAddToDocument];
}

- (void)dealloc
{
    [_borderColor release];
    [_borderPath release];
    [_relativeBorderPath release];
    [_initialClipPaths release];
    [_originalImage setHyperOwner:nil];
    [_originalImage release];
    [_effectedImage setHyperOwner:nil];
    [_effectedImage release];
    [_legacyImageStoring release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _originalImage = [[HSImage alloc] initWithOwner:self];
        _effectedImage = [[HSImage alloc] initWithOwner:self];
    }
    return self;
}

@end
