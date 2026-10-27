#import "HSNewMedia+DataHelpers.h"
@implementation HSNewMedia (DataHelpers)
- (id)hsMovie
{
    NSString *path = [self fullPathToMediaFileCreateIfNeeded:YES];
    return [[[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:NULL] autorelease];
}
- (id)imagePNGRepresentation
{
    return [[self image] hyperPNGRepresentation];
}
// The image representation's image; failing that (for media without a
// group or of group 3) the image read from the data or the file, which then
// becomes the image representation.
- (id)image
{
    id representation = [self imageRepresentation];
    NSImage *image = [representation image];
    if (image == nil && ([self mediaGroup] == 0 || [self mediaGroup] == 3)) {
        image = [NSImage hyperImageWithData:[[self dataRepresentation] mediaData]];
        if (image == nil)
            image = [NSImage hyperImageWithContentsOfFile:[[self fileRepresentation] path]];
    }
    if (representation == nil && image != nil) {
        representation = [[HSImageMediaRepresentation alloc] initWithImage:image];
        [_representations addObject:representation];
        [representation release];
    }
    return image;
}
- (id)fileRepresentation
{
    return [self representationOfClass:[HSMediaFileRepresentation class]];
}
- (id)dataRepresentation
{
    return [self representationOfClass:[HSMediaDataRepresentation class]];
}
- (id)imageRepresentation
{
    return [self representationOfClass:[HSImageMediaRepresentation class]];
}
- (id)representationOfClass:(Class)aClass
{
    for (id representation in _representations) {
        if ([representation isKindOfClass:aClass])
            return representation;
    }
    return nil;
}
@end
