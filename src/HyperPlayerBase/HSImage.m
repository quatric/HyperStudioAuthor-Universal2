#import "HSImage.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "NSFileManager+HSExtensions.h"
#import "NSImage+HSImageSize.h"

@implementation HSImage

- (NSUInteger)hash
{
    return [super hash] + [[self imageUID] hash] + [[self image] hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if (![super isEqual:aEqual])
        return NO;
    if (![[aEqual imageUID] isEqual:[self imageUID]])
        return NO;
    if ([aEqual hyperImageAlignment] != _imageAlignment || [aEqual hyperImageScaling] != _imageScaling)
        return NO;
    if (![[aEqual image] isEqual:[self image]])
        return NO;
    return NSEqualSizes([self hyperImageSize], [aEqual hyperImageSize]);
}

- (void)setHyperImageUID:(id)aUID
{
    if ([self imageUID] != aUID) {
        [self setImageUID:aUID];
        [self postDidChange];
    }
}

- (id)mediaUIDs
{
    return [NSSet setWithSet:[self ownedMediaUIDs]];
}

- (id)ownedMediaUIDs
{
    NSCountedSet *uids = [NSCountedSet set];
    if ([self imageUID] != nil)
        [uids addObject:[self imageUID]];
    return uids;
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSImage *copy = [super copyWithZone:aZone];
    [copy setMedia:[self media]];
    [copy setImageAlignment:_imageAlignment];
    [copy setImageScaling:_imageScaling];
    [copy setHyperImageSize:_imageSize];
    return copy;
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    id keys = [super keysForExtraStoringWithCodingContext:aContext];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        keys = [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"imageData", @"imageUID", @"imageAlignment", @"imageScaling", @"sizeAsString", nil]];
    return keys;
}

- (void)setSizeAsString:(id)aString
{
    [self setHyperImageSize:NSSizeFromString(aString)];
}

- (id)sizeAsString
{
    return NSStringFromSize([self hyperImageSize]);
}

- (void)setImageData:(id)aData
{
    [self setHyperImage:[NSImage hyperImageWithData:aData]];
}

- (id)imageData
{
    // Image data is only read (from old documents); the media UID is stored instead.
    return nil;
}

- (id)image
{
    return [[self media] image];
}

- (void)setImageUID:(id)aUID
{
    if (![[self imageUID] isEqual:aUID])
        [self setMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}

- (id)imageUID
{
    return [[self media] mediaUID];
}

- (void)setMedia:(id)aMedia
{
    id oldMedia = [self media];
    if ([oldMedia isEqual:aMedia] || oldMedia == aMedia)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Insert Image" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMedia:oldMedia];
    [_imageMedia release];
    _imageMedia = [aMedia retain];
    [self setHyperImageSize:NSZeroSize];
    [self postDidChange];
}

- (id)media
{
    return _imageMedia;
}

- (void)setHyperImageScaling:(NSInteger)aScaling
{
    if (_imageScaling == aScaling)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change  Attributes" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperImageScaling:_imageScaling];
    [self setImageScaling:aScaling];
    [self postDidChange];
}

- (void)setImageScaling:(NSInteger)aScaling
{
    _imageScaling = (int)aScaling;
}

- (void)setHyperImageAlignment:(NSUInteger)aAlignment
{
    if (_imageAlignment == aAlignment)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change  Attributes" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperImageAlignment:_imageAlignment];
    [self setImageAlignment:aAlignment];
    [self postDidChange];
}

- (void)setImageAlignment:(NSUInteger)aAlignment
{
    _imageAlignment = (unsigned int)aAlignment;
}

- (void)setHyperImage:(id)aImage
{
    [self setMedia:aImage ? [HSNewMedia mediaWithImage:aImage] : nil];
}

- (void)setHyperImageFromPath:(id)aPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:aPath]
        && [[NSFileManager defaultManager] hyperIsReadableFileAtPath:aPath showAlert:YES error:NULL])
        [self setMedia:[HSNewMedia mediaWithPath:aPath]];
}

- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [super hyperDrawHighlightedInRect:aRect ofBounds:aBounds];
}

- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [[self hyperImage] hyperDrawInRect:aRect ofBounds:aBounds withAlignment:_imageAlignment scaling:_imageScaling];
}

- (void)setHyperImageSize:(NSSize)aSize
{
    if (!NSEqualSizes(_imageSize, aSize)) {
        _imageSize = aSize;
        [self postDidChange];
    }
}

- (NSSize)hyperImageSize
{
    // Lazily take the size from the image itself.
    if (NSEqualSizes(_imageSize, NSZeroSize)) {
        NSImage *image = [self image];
        if (image != nil)
            _imageSize = [image size];
    }
    return _imageSize;
}

- (NSInteger)hyperImageScaling
{
    return _imageScaling;
}

- (NSUInteger)hyperImageAlignment
{
    return _imageAlignment;
}

- (id)hyperImage
{
    return [self image];
}

- (id)hyperData
{
    return [[self media] mediaData];
}

- (void)dealloc
{
    [_imageMedia release];
    [super dealloc];
}

@end
