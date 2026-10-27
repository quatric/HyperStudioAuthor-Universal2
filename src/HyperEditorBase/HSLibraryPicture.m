#import "HSLibraryPicture.h"

// A picture file of the library.

@implementation HSLibraryPicture

+ (id)invalidPictureImage
{
    return [[HSImagesProvider sharedImagesProvider] imageForName:@"InvalidPicturePreview" ofType:@"tiff"];
}

+ (BOOL)canInitWithURL:(id)aURL
{
    return YES;
}

- (id)invalidPictureImage
{
    if (_invalidPictureImage == nil)
        _invalidPictureImage = [[[self class] invalidPictureImage] retain];
    return _invalidPictureImage;
}

- (id)dataDisplayName
{
    return [self displayName];
}

- (id)dataURL
{
    return [self URL];
}

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    NSPasteboard *pasteboard = aPasteboard;
    if ([aType isEqualToString:@"HSLibraryReusableMediaPboardType"]) {
        NSString *path = [[self URL] path];
        NSString *uid = [[[HSLibraryManager sharedLibraryManager] mediaContentFilter] globalUIDStringForMediaItem:path];
        if (path != nil && uid != nil)
            [pasteboard setPropertyList:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:uid, @"HSLibraryReusableMediaGlobalUIDKey", path, @"HSLibraryReusableMediaPathKey", nil]] forType:aType];
    } else if ([aType isEqualToString:NSStringPboardType]) {
        NSString *name = [self displayName];
        if (name != nil)
            [pasteboard setString:name forType:aType];
    } else if ([aType isEqualToString:NSURLPboardType]) {
        [[self URL] writeToPasteboard:pasteboard];
    } else if ([aType isEqualToString:NSRTFPboardType] || [aType isEqualToString:NSRTFDPboardType]) {
        NSAttributedString *string = [[[NSAttributedString alloc] initWithString:[self displayName]] autorelease];
        NSRange range = NSMakeRange(0, [string length]);
        NSData *data = [aType isEqualToString:NSRTFPboardType] ? [string RTFFromRange:range documentAttributes:@{}] : [string RTFDFromRange:range documentAttributes:@{}];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    } else if ([aType isEqualToString:NSTIFFPboardType]) {
        NSData *data = [[self pictureImage] TIFFRepresentation];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    }
}

- (NSInteger)compareWithPicture:(id)aPicture
{
    return [[self displayName] caseInsensitiveCompare:[aPicture displayName]];
}

- (id)pictureImage
{
    if ([self hasAccessibleURL]) {
        if (_pictureImage == nil)
            _pictureImage = [[NSImage alloc] initWithContentsOfURL:[self URL]];
        if (_pictureImage != nil)
            return _pictureImage;
    }
    return [self invalidPictureImage];
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
    return _pictureURL;
}

- (void)dealloc
{
    [_pictureURL release];
    [_displayString release];
    [_info release];
    [_pictureImage release];
    [_invalidPictureImage release];
    [super dealloc];
}

- (id)initWithURL:(id)aURL
{
    if ((self = [super init]))
        _pictureURL = [aURL retain];
    return self;
}

@end
