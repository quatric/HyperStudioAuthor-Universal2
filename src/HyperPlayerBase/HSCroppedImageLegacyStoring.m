#import "HSCroppedImageLegacyStoring.h"
// Stores an image object the old way ("HSImage" with a cropped image
// media) for older readers: the media is the object's own, or, when it has
// an effect per object, a PNG of the current drawing made on demand.
@implementation HSCroppedImageLegacyStoring
+ (id)extraClassNameForStoring
{
    return @"HSImage";
}
+ (id)croppedImageLegacyStoringWithOwner:(id)aOwner
{
    return [[[self alloc] initWithOwner:aOwner] autorelease];
}
- (id)mediaTypeForPromisedDataRepresentation:(id)aRepresentation
{
    return @"png";
}
- (id)mediaDataForPromisedDataRepresentation:(id)aRepresentation
{
    id image = [[_owner imageObjectForLegacyImageStoring:self] queryHyperInterface:@protocol(HSImageObjectAttributes)];
    return [[HSCurrentImageDrawing drawingForImageObject:image] currentImagePNGRepresentationOfSize:0];
}
- (void)setEffectedImageBoundsAsString:(id)aString
{
}
- (id)effectedImageBoundsAsString
{
    id image = [[_owner imageObjectForLegacyImageStoring:self] queryHyperInterface:@protocol(HSImageObjectAttributes)];
    HSCurrentImageDrawing *drawing = [HSCurrentImageDrawing drawingForImageObject:image];
    if (drawing == nil)
        return nil;
    return NSStringFromRect([drawing imageBoundingRect]);
}
- (id)extraClassNameForStoring
{
    return @"HSImage";
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"imageUID", @"effectedImageBoundsAsString", nil];
}
- (id)imageUID
{
    return [[self legacyCroppedImageMedia] mediaUID];
}
- (void)setLegacyCroppedImageMedia:(id)aMedia
{
    [self setLegacyCroppedImageMedia:aMedia externalMedia:YES];
}
- (void)setLegacyCroppedImageMedia:(id)aMedia externalMedia:(BOOL)aMedia2
{
    if (_croppedImageMedia != aMedia) {
        [_croppedImageMedia release];
        _croppedImageMedia = [aMedia retain];
    }
    if (_hasExternalMedia != aMedia2)
        _hasExternalMedia = aMedia2;
}
- (id)legacyCroppedImageMedia
{
    [self recreateLegacyCroppedImageMediaIfNeeded];
    return _croppedImageMedia;
}
// Unless the media was set from outside.
- (void)recreateLegacyCroppedImageMediaIfNeeded
{
    if (_hasExternalMedia)
        return;
    id media = [[[_owner imageObjectForLegacyImageStoring:self] queryHyperInterface:@protocol(HSImageObjectAttributes)] media];
    if (media == nil)
        return;
    if ([self shouldUsePromisedCroppedImageMedia])
        media = [self promisedMedia];
    [self setLegacyCroppedImageMedia:media externalMedia:NO];
}
- (BOOL)shouldUsePromisedCroppedImageMedia
{
    id image = [[_owner imageObjectForLegacyImageStoring:self] queryHyperInterface:@protocol(HSImageObjectAttributes)];
    if (image == nil)
        return NO;
    return [[image queryHyperInterface:@protocol(HSCardObjectEffectPerObjectAttribute)] hasEffectPerObject];
}
// A new media (named like the image's) whose data comes from us.
- (id)promisedMedia
{
    if (_promisedMedia == nil) {
        [_promisedMediaRepresentation release];
        _promisedMediaRepresentation = [[HSPromisedMediaDataRepresentation alloc] initWithDataOwner:self];
        id image = [[_owner imageObjectForLegacyImageStoring:self] queryHyperInterface:@protocol(HSImageObjectAttributes)];
        HSNewMedia *media = [HSNewMedia alloc];
        NSString *name = [[image media] mediaName];
        _promisedMedia = [media initWithMediaUID:[HSUID UID] representation:_promisedMediaRepresentation name:name];
    }
    return _promisedMedia;
}
- (id)uniqueNameForPromisedMedia
{
    return [[NSString hyperUIDString] stringByAppendingPathExtension:@"png"];
}
- (void)dealloc
{
    [_croppedImageMedia release];
    [_promisedMediaRepresentation setOwner:nil];
    [_promisedMediaRepresentation release];
    [_promisedMedia release];
    [super dealloc];
}
- (id)initWithOwner:(id)aOwner
{
    if (aOwner == nil) {
        [self release];
        return nil;
    }
    self = [super init];
    if (self != nil)
        _owner = aOwner;
    return self;
}
@end
