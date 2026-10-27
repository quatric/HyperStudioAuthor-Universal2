#import "HSSoundsLibraryiTunesHelper.h"
#import "HSLibraryScanning.h"

@implementation HSSoundsLibraryiTunesHelper

+ (id)iAppsRecentDatabasesForKeys:(id)aKeys
{
    return HSiAppsRecentDatabasesForKeys(self, aKeys, @"LibrarySoundsiTunes");
}

+ (id)applicationBundleForBundleID:(id)aID creator:(NSUInteger)aCreator
{
    return HSiAppsApplicationBundle(aID);
}

+ (id)arrayByRemovingNonExistedPaths:(id)aPaths
{
    return HSiAppsArrayByRemovingNonExistedPaths(self, aPaths);
}

+ (id)defaultAttributes:(id)aAttributes
{
    return HSLibraryDefaultAttributes(aAttributes);
}

+ (id)resolveAliasesInURL:(id)aURL
{
    return HSiAppsResolveAliasesInURL(self, aURL);
}

+ (BOOL)iTunesApplicationVersionSupported
{
    return [self iTunesApplicationVersion] >= 3.0f;
}

+ (CGFloat)iTunesApplicationVersion
{
    NSString *bundleID = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"iTunesBundleId" value:@"" table:@"LibrarySoundsiTunes"];
    NSBundle *bundle = [self applicationBundleForBundleID:bundleID creator:'hook'];
    if (bundle == nil)
        return 0;
    return [[[bundle infoDictionary] objectForKey:shortVersionKey] floatValue];
}

+ (id)iTunesRecentDatabases
{
    return [self iAppsRecentDatabasesForKeys:[NSArray arrayWithObject:iTunesRecentDatabasesKey]];
}

@end
