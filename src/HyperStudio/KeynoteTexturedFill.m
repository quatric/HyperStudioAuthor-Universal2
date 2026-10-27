#import "KeynoteTexturedFill.h"

@implementation KeynoteTexturedFill

- (id)mediaWithSize:(NSSize)aSize
{
    if (_mediaDictionary == nil)
        _mediaDictionary = [NSMutableDictionary new];
    NSString *key = NSStringFromSize(aSize);
    id media = [_mediaDictionary objectForKey:key];
    if (media == nil) {
        media = [HSNewMedia mediaWithImage:[self scaledTintedImageForSize:aSize]];
        [_mediaDictionary setObject:media forKey:key];
    }
    return media;
}

- (id)scaledTintedImageForSize:(NSSize)aSize
{
    NSRect rect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height);
    NSImage *image = [[[NSImage alloc] initWithSize:aSize] autorelease];
    [image lockFocus];
    [[self tintedImage] hyperDrawInRect:rect ofBounds:rect withAlignment:0 scaling:[self scaleType]];
    [image unlockFocus];
    return image;
}

- (id)tintedImage
{
    if (_tintedImage == nil) {
        NSImage *image = [self image];
        NSColor *tintColor = [self tintColor];
        if (image == nil || tintColor == nil) {
            _tintedImage = [image retain];
        } else {
            _tintedImage = [[NSImage alloc] initWithSize:[image size]];
            [_tintedImage lockFocus];
            [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
            [tintColor set];
            NSSize size = [image size];
            NSRectFillUsingOperation(NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height), NSCompositingOperationSourceOver);
            [_tintedImage unlockFocus];
        }
    }
    return _tintedImage;
}

- (id)tintColor
{
    return [[self keynoteObjectForXMLPath:@"./color"] color];
}

- (NSSize)size
{
    [self loadImageAndSize];
    return _size;
}

- (id)image
{
    [self loadImageAndSize];
    return _image;
}

- (void)loadImageAndSize
{
    if (_isLoaded)
        return;
    _isLoaded = YES;
    id imageObject = [self keynoteObjectForXMLPath:@"./image"];
    if (imageObject == nil) {
        id reference = [self keynoteObjectForXMLPath:@"./image-ref"];
        if (reference != nil)
            imageObject = [[self cache] objectOfType:@"image" inCacheForId:[[reference nodeAttributes] objectForKey:@"IDREF"]];
    }
    if (imageObject == nil)
        imageObject = [self keynoteObjectForXMLPath:@"./filtered-image"];
    _image = [[imageObject image] retain];
    _size = [(KeynoteSize *)imageObject size];
    if (NSEqualSizes(_size, NSZeroSize))
        _size = [_image size];
}

- (NSInteger)scaleType
{
    return [KeynoteTools scaleTypeWithAttributesDictionary:[self nodeAttributes]];
}

- (void)didDetail
{
    [super didDetail];
    if ([self tintedImage] == nil)
        [[self importManager] addImportingProblemForCode:0x4e2c point:@"002" info:@"(texturedFill)"];
}

- (void)dealloc
{
    [_image release];
    [_tintedImage release];
    [_mediaDictionary release];
    [super dealloc];
}

@end
