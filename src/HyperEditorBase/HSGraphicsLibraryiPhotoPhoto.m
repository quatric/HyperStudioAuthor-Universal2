#import "HSGraphicsLibraryiPhotoPhoto.h"

// A photo of the iPhoto library, from its album data dictionary.

@implementation HSGraphicsLibraryiPhotoPhoto

- (id)imageUID
{
    return [[self URL] absoluteString];
}

- (id)imageRepresentation
{
    return [self URL];
}

- (id)imageRepresentationType
{
    return @"IKImageBrowserNSURLRepresentationType";
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
    if ([aType isEqualToString:NSTIFFPboardType]) {
        NSImage *image = [[[NSImage alloc] initWithContentsOfURL:[self URL]] autorelease];
        NSData *data = [image TIFFRepresentation];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    } else if ([aType isEqualToString:NSStringPboardType]) {
        NSString *name = [self displayName];
        if (name != nil)
            [pasteboard setString:name forType:aType];
    } else if ([aType isEqualToString:NSURLPboardType]) {
        [[self URL] writeToPasteboard:pasteboard];
    } else if ([aType isEqualToString:NSRTFPboardType] || [aType isEqualToString:NSRTFDPboardType]) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:[self displayName]];
        NSRange range = NSMakeRange(0, [string length]);
        NSData *data = [aType isEqualToString:NSRTFPboardType] ? [string RTFFromRange:range documentAttributes:@{}] : [string RTFDFromRange:range documentAttributes:@{}];
        [string release];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    }
}

- (id)info
{
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

// The photo's name, else its (or its thumbnail's) file name.
- (id)displayName
{
    id name = [[self info] objectForKey:ipPhotoNameKey];
    if (name == nil) {
        NSURL *url = [self URL];
        if (url == nil)
            url = [self thumbURL];
        if ([url isFileURL])
            name = [[[url path] lastPathComponent] stringByDeletingPathExtension];
    }
    return name;
}

- (id)thumbURL
{
    NSString *path = [[self info] objectForKey:ipThumbPathKey];
    if (path == nil)
        return nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURL *resolved = [HSGraphicsLibraryiPhotoHelper resolveAliasesInURL:url];
    return resolved != nil ? resolved : url;
}

- (id)URL
{
    NSString *path = [[self info] objectForKey:ipPhotoPathKey];
    if (path == nil)
        return nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURL *resolved = [HSGraphicsLibraryiPhotoHelper resolveAliasesInURL:url];
    return resolved != nil ? resolved : url;
}

- (void)dealloc
{
    [_info release];
    [super dealloc];
}

- (id)initWithDictionaryRepresentation:(id)aRepresentation
{
    if ((self = [super init]))
        _info = [aRepresentation retain];
    return self;
}

- (id)init
{
    return [self initWithDictionaryRepresentation:nil];
}

@end
