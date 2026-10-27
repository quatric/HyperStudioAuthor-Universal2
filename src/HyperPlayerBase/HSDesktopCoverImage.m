#import "HSDesktopCoverImage.h"

static HSDesktopCoverImage *HSDesktopCoverImageShared = nil;

// The image lives in the library as DesktopCoverImage.png and is loaded lazily.
@implementation HSDesktopCoverImage
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSDesktopCoverImageShared) {
            HSDesktopCoverImageShared = [super allocWithZone:aZone];
            return HSDesktopCoverImageShared;
        }
    }
    return nil;
}
+ (id)sharedDesktopCoverImage
{
    @synchronized(self) {
        if (!HSDesktopCoverImageShared)
            [[self alloc] init];
    }
    return HSDesktopCoverImageShared;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    id keys = [super keysForExtraStoringWithCodingContext:aContext];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        keys = [keys arrayByAddingObject:@"imageScaling"];
    return keys;
}
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [super hyperDrawHighlightedInRect:aRect ofBounds:aBounds];
}
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [[self hyperImage] hyperDrawInRect:aRect ofBounds:aBounds withAlignment:[self hyperImageAlignment] scaling:[self hyperImageScaling]];
}
- (void)setHyperImageSize:(NSSize)aSize
{
    [(NSImage *)[self hyperImage] setSize:aSize];
    [self postDidChange];
}
- (NSSize)hyperImageSize
{
    return [(NSImage *)[self hyperImage] size];
}
- (void)setHyperImageScaling:(NSInteger)aScaling
{
    if (_imageScaling != aScaling) {
        _imageScaling = (int)aScaling;
        [self postDidChange];
    }
}
- (NSInteger)hyperImageScaling
{
    return _imageScaling;
}
- (void)setHyperImageAlignment:(NSUInteger)aAlignment
{
}
- (NSUInteger)hyperImageAlignment
{
    return 0;
}
// Writes the image as PNG; it is reloaded from the file on next use.
- (void)setHyperImage:(id)aImage
{
    if ([_image isEqual:aImage])
        return;
    NSString *path = [self desktopCoverImagePath];
    BOOL isDirectory = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[path stringByDeletingLastPathComponent] isDirectory:&isDirectory] || !isDirectory)
        [manager createDirectoryAtPath:[path stringByDeletingLastPathComponent] attributes:nil createIntermediate:YES];
    [[aImage hyperPNGRepresentation] writeToFile:path atomically:YES];
    [_image release];
    _image = nil;
    [self postDidChange];
}
- (id)hyperImage
{
    if (!_image)
        _image = [[NSImage alloc] initByReferencingFile:[self desktopCoverImagePath]];
    return _image;
}
- (void)setHyperImageFromPath:(id)aPath
{
    if ([aPath isEqualToString:[self desktopCoverImagePath]])
        return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:aPath])
        return;
    if (![[NSFileManager defaultManager] hyperIsReadableFileAtPath:aPath showAlert:YES error:NULL])
        return;
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:aPath];
    [self setHyperImage:image];
    [image release];
}
- (id)desktopCoverImagePath
{
    return [[[HSPathsProvider sharedPathsProvider] libraryMediaAccessorFolder] stringByAppendingPathComponent:@"DesktopCoverImage.png"];
}
- (void)dealloc
{
    [_image release];
    [super dealloc];
}
- (id)autorelease
{
    return self;
}
- (void)release
{
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (id)retain
{
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}
@end
