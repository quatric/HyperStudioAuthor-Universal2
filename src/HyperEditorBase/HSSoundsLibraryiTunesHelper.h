#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryiTunesHelper : NSObject
{
}
+ (id)iAppsRecentDatabasesForKeys:(id)aKeys;
+ (id)applicationBundleForBundleID:(id)aID creator:(NSUInteger)aCreator;
+ (id)arrayByRemovingNonExistedPaths:(id)aPaths;
+ (id)defaultAttributes:(id)aAttributes;
+ (id)resolveAliasesInURL:(id)aURL;
+ (BOOL)iTunesApplicationVersionSupported;
+ (CGFloat)iTunesApplicationVersion;
+ (id)iTunesRecentDatabases;
@end

