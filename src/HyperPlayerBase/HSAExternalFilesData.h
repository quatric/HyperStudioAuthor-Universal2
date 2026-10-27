#import "HyperPlayerBasePrefix.h"


@interface HSAExternalFilesData : NSObject
{
    HSDocument *_document;
    NSURL *_temporaryURL;
    NSMutableDictionary *_externalFilesBookmarks;
    NSMutableSet *_resolvedExternalURLs;
}
- (id)init;
- (id)initWithDocument:(id)aDocument;
- (void)dealloc;
- (id)externalURLsFromChangeCardActions;
- (id)externalURLs;
- (id)externalFilesBookmarks;
- (id)bookmarksForStoring;
- (id)resolvedURLsFromBookmarkData:(id)aData;
- (void)resolveURLsFromBookmarkData:(id)aData;
- (void)startAccessingToAllSecurityScopedResource;
- (void)stopAccessingToAllSecurityScopedResource;
- (id)temporaryURL;
- (void)setTemporaryURL:(id)aURL;
@end
