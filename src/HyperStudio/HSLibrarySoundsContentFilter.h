#import "HyperStudioPrefix.h"


@interface HSLibraryContentFilter : NSObject <HSMediaContentFilter, NSObject>
{
    NSManagedObjectContext *_context;
    NSString *_contextPath;
    NSSet *_mediaTypes;
    NSMutableDictionary *_entities;
    NSMutableDictionary *_rootPaths;
    NSManagedObjectModel *_managedObjectModel;
}
+ (id)sharedContentFilter;
- (id)dataBasePath;
- (id)rootPathForFilePath:(id)aPath;
- (id)contextPath;
- (id)managedObjectContext;
- (id)persistentStoreCoordinator;
- (id)managedObjectModel;
- (id)globalUIDStringForMediaItem:(id)aItem;
- (BOOL)mediaItem:(id)aItem conformsToDisplayNameFilter:(id)aFilter mediaTypeFilter:(id)aFilter2;
- (id)entities;
- (id)sortedMediaTypes;
- (id)mediaTypes;
- (void)dealloc;
@end

@interface HSLibrarySoundsContentFilter : HSLibraryContentFilter
{
}
+ (id)sharedContentFilter;
- (id)dataBasePath;
@end

@interface HSLibraryMoviesContentFilter : HSLibraryContentFilter
{
}
+ (id)sharedContentFilter;
- (id)dataBasePath;
@end

