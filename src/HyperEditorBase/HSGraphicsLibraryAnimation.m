#import "HSGraphicsLibraryAnimation.h"

// An animation (movie or GIF file) of the graphics library.

@implementation HSGraphicsLibraryAnimation

+ (BOOL)canInitWithURL:(id)aURL
{
    return YES;
}

- (void)generateMovieImageInMainThread:(id)aThread
{
    HSMovie *movie = [HSMovie movieWithURL:aThread error:NULL];
    [_movieImage release];
    _movieImage = [[movie posterImage] retain];
}

- (id)invalidMovieImage
{
    if (_invalidMovieImage == nil)
        _invalidMovieImage = [[[HSImagesProvider sharedImagesProvider] imageForName:@"InvalidMoviePreview" ofType:@"tiff"] retain];
    return _invalidMovieImage;
}

// The poster image (made on the main thread), or the invalid movie image.
- (id)movieImage
{
    if ([self hasAccessibleURL]) {
        if (_movieImage == nil) {
            NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, HSThumbnailGenerationRunLoopMode, nil];
            [self performSelectorOnMainThread:@selector(generateMovieImageInMainThread:) withObject:[self URL] waitUntilDone:YES modes:modes];
        }
        if (_movieImage != nil)
            return _movieImage;
    }
    return [self invalidMovieImage];
}

- (id)dataDisplayName
{
    return [self displayName];
}

- (id)dataURL
{
    return [self URL];
}

- (NSInteger)compareWithAnimation:(id)aAnimation
{
    return [[self displayName] caseInsensitiveCompare:[aAnimation displayName]];
}

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    NSPasteboard *pasteboard = aPasteboard;
    if ([aType isEqualToString:@"HSLibraryReusableMediaPboardType"]) {
        NSString *path = [[self URL] path];
        NSString *uid = [[[HSLibraryManager sharedLibraryManager] moviesContentFilter] globalUIDStringForMediaItem:path];
        if (path != nil && uid != nil)
            [pasteboard setPropertyList:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:uid, @"HSLibraryReusableMediaGlobalUIDKey", path, @"HSLibraryReusableMediaPathKey", nil]] forType:aType];
    } else if ([aType isEqualToString:NSStringPboardType]) {
        [pasteboard setString:[self displayName] forType:aType];
    } else if ([aType isEqualToString:NSURLPboardType]) {
        [[self URL] writeToPasteboard:pasteboard];
    } else if ([aType isEqualToString:NSRTFPboardType] || [aType isEqualToString:NSRTFDPboardType]) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:[self displayName]];
        NSRange range = NSMakeRange(0, [string length]);
        NSData *data = [aType isEqualToString:NSRTFPboardType] ? [string RTFFromRange:range documentAttributes:@{}] : [string RTFDFromRange:range documentAttributes:@{}];
        [string release];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    } else if ([aType isEqualToString:NSTIFFPboardType]) {
        NSData *data = [[self movieImage] TIFFRepresentation];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    }
}

- (id)info
{
    if (_info == nil)
        _info = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[[self URL] path] stringByResolvingSymlinksInPath] error:NULL] retain];
    return _info;
}

- (BOOL)hasAccessibleURL
{
    if (!_urlAccessTested) {
        NSURL *url = [self URL];
        if ([url isFileURL])
            _urlAccessOk = [[NSFileManager defaultManager] isReadableFileAtPath:[url path]];
        _urlAccessTested = YES;
    }
    return _urlAccessOk;
}

- (id)displayName
{
    if (_displayString == nil)
        _displayString = [[[[[self URL] path] lastPathComponent] stringByDeletingPathExtension] retain];
    return _displayString;
}

- (id)URL
{
    return _animationURL;
}

- (void)dealloc
{
    [_animationURL release];
    [_displayString release];
    [_info release];
    [_movieImage release];
    [_invalidMovieImage release];
    [super dealloc];
}

- (id)initWithURL:(id)aURL
{
    if ((self = [super init]))
        _animationURL = [aURL retain];
    return self;
}

@end
