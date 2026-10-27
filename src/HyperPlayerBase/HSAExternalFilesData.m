#import "HSAExternalFilesData.h"
#import "HSDocument.h"

@interface HSAExternalFilesData ()
@property(nonatomic, retain) NSURL *temporaryURL;
@end

@implementation HSAExternalFilesData

@synthesize temporaryURL = _temporaryURL;

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithDocument:(id)aDocument
{
    if (aDocument == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        _document = aDocument;
    }
    return self;
}

- (void)dealloc
{
    [_temporaryURL release];
    [_externalFilesBookmarks release];
    [self stopAccessingToAllSecurityScopedResource];
    [_resolvedExternalURLs release];
    [super dealloc];
}

- (id)externalURLsFromChangeCardActions
{
    NSMutableSet *urls = [NSMutableSet set];
    NSURL *documentURL = [_document fileURL];
    NSArray *actions = [(id)[_document stack] allActionsOfType:@protocol(HSChangeCardActionAttributes)];
    [actions enumerateObjectsUsingBlock:^(id action, NSUInteger idx, BOOL *stop) {
        NSURL *url = [[action queryHyperInterface:@protocol(HSURLAttribute)] URL];
        if (url != nil && ![documentURL isEqualTo:url]) {
            [urls addObject:url];
        }
    }];
    return urls;
}

- (id)externalURLs
{
    NSSet *candidates = [self externalURLsFromChangeCardActions];
    if ([candidates count] == 0) {
        if ([_externalFilesBookmarks count] == 0) {
            return nil;
        }
        [[_externalFilesBookmarks allKeys] makeObjectsPerformSelector:@selector(stopAccessingSecurityScopedResource)];
        [_externalFilesBookmarks removeAllObjects];
        return nil;
    }
    NSMutableSet *result = [NSMutableSet set];
    [candidates enumerateObjectsUsingBlock:^(id url, BOOL *stop) {
        if ([_externalFilesBookmarks objectForKey:url] == nil) {
            [result addObject:url];
        }
    }];
    return result;
}

- (id)externalFilesBookmarks
{
    if (_externalFilesBookmarks == nil) {
        _externalFilesBookmarks = [NSMutableDictionary new];
    }
    NSSet *urls = [self externalURLs];
    if ([urls count] != 0 && _temporaryURL != nil) {
        NSString *path = [_temporaryURL path];
        if (path != nil &&
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
            [urls enumerateObjectsUsingBlock:^(id url, BOOL *stop) {
                NSError *error = nil;
                NSData *data = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                                  includingResourceValuesForKeys:nil
                                                   relativeToURL:_temporaryURL
                                                           error:&error];
                if ([data length] != 0 && error == nil) {
                    [_externalFilesBookmarks setObject:data forKey:[url path]];
                }
            }];
        }
    }
    return _externalFilesBookmarks;
}

- (id)bookmarksForStoring
{
    id bookmarks = [self externalFilesBookmarks];
    if ([bookmarks count] == 0) {
        return nil;
    }
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:bookmarks, @"HSDocumentBookmarks", nil];
}

- (id)resolvedURLsFromBookmarkData:(id)aData
{
    if ([aData length] == 0) {
        return nil;
    }
    id plist = [NSPropertyListSerialization propertyListFromData:aData
                                                mutabilityOption:0
                                                          format:NULL
                                                errorDescription:NULL];
    NSDictionary *bookmarks = [plist objectForKey:@"HSDocumentBookmarks"];
    if ([bookmarks count] == 0) {
        return nil;
    }
    NSMutableSet *result = [NSMutableSet set];
    NSURL *documentURL = [_document fileURL];
    [bookmarks enumerateKeysAndObjectsUsingBlock:^(id key, id data, BOOL *stop) {
        NSURL *url = [NSURL URLByResolvingBookmarkData:data
                                               options:NSURLBookmarkResolutionWithSecurityScope
                                         relativeToURL:documentURL
                                   bookmarkDataIsStale:NULL
                                                 error:NULL];
        if (url != nil) {
            [result addObject:url];
        }
    }];
    return result;
}

- (void)resolveURLsFromBookmarkData:(id)aData
{
    if ([aData length] != 0 && [_resolvedExternalURLs count] == 0) {
        _resolvedExternalURLs = [[self resolvedURLsFromBookmarkData:aData] retain];
    }
}

- (void)startAccessingToAllSecurityScopedResource
{
    if ([_resolvedExternalURLs count] != 0) {
        [_resolvedExternalURLs makeObjectsPerformSelector:@selector(startAccessingSecurityScopedResource)];
    }
}

- (void)stopAccessingToAllSecurityScopedResource
{
    if ([_resolvedExternalURLs count] != 0) {
        [_resolvedExternalURLs makeObjectsPerformSelector:@selector(stopAccessingSecurityScopedResource)];
    }
}

@end
