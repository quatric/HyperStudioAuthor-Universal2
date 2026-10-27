#import "NSMovie+HSExtensions.h"
// NSMovie from hyper media and data. NSMovie is a QuickTime wrapper: since
// macOS 10.15 it cannot load a movie (its initialisers return nil and
// -QTMovie is always nil), so these fail with the original's errors and the
// QuickTime track and box methods have nothing to work on. HyperStudio's
// movies go through HSQTKit instead.
@implementation NSMovie (HSExtensions)
+ (id)movieWithHyperMedia:(id)aMedia
{
    return [NSMovie movieWithHyperMedia:aMedia error:NULL];
}
+ (id)movieWithHyperMedia:(id)aMedia error:(id *)aError
{
    return [[[self allocWithZone:[self zone]] initWithHyperMedia:aMedia error:aError] autorelease];
}
+ (id)movieWithHyperData:(id)aData ofType:(id)aType
{
    return [self movieWithHyperMedia:[HSNewMedia mediaWithData:aData name:nil type:aType]];
}
// Kept the tracks whose media handler type was aType (QuickTime only).
- (void)filterMediaByType:(NSInteger)aType
{
}
// The largest sample count of the video tracks (QuickTime only).
- (NSUInteger)maxVideoFrameCount
{
    return 0;
}
// Moved the movie box to the origin (QuickTime only).
- (void)normalizeBox
{
}
// The movie box size (QuickTime only); NSZeroSize without a movie.
- (NSSize)size
{
    return NSZeroSize;
}
// The movie flattened into a handle (QuickTime only).
- (id)movieHyperDataRepresentation
{
    return nil;
}
- (id)initWithHyperMedia:(id)aMedia
{
    return [self initWithHyperMedia:aMedia error:NULL];
}
- (id)initWithHyperMedia:(id)aMedia error:(id *)aError
{
    NSString *path = [aMedia fullPathToMediaFileCreateIfNeeded:YES];
    if (path != nil && [[NSFileManager defaultManager] isReadableFileAtPath:path])
        return [self initWithHyperURL:[NSURL fileURLWithPath:path] byReference:YES error:aError];
    [self release];
    if (aError != NULL)
        *aError = [HSError cantOpenFileErrorWithFileName:@""];
    return nil;
}
- (id)initWithHyperData:(id)aData ofType:(id)aType
{
    return [self initWithHyperMedia:[HSNewMedia mediaWithData:aData name:nil type:aType]];
}
// Was initWithURL:byReference:, which no longer exists.
- (id)initWithHyperURL:(id)aURL byReference:(BOOL)aReference error:(id *)aError
{
    [self release];
    if (aError != NULL)
        *aError = [HSError cantOpenFileErrorWithFileName:[[NSFileManager defaultManager]
                                                             displayNameAtPath:[aURL path]]];
    return nil;
}
@end
