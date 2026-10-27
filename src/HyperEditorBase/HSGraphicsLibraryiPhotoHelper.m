#import "HSGraphicsLibraryiPhotoHelper.h"
#import "HSLibraryScanning.h"

@implementation HSGraphicsLibraryiPhotoHelper

+ (id)iAppsRecentDatabasesForKeys:(id)aKeys
{
    return HSiAppsRecentDatabasesForKeys(self, aKeys, @"LibraryGraphicsiPhoto");
}

+ (id)applicationBundleForBundleID:(id)aID creator:(NSUInteger)aCreator
{
    return HSiAppsApplicationBundle(aID);
}

+ (id)arrayByRemovingNonExistedPaths:(id)aPaths
{
    return HSiAppsArrayByRemovingNonExistedPaths(self, aPaths);
}

+ (id)resolveAliasesInURL:(id)aURL
{
    return HSiAppsResolveAliasesInURL(self, aURL);
}

+ (BOOL)iPhotoApplicationVersionSupported
{
    return [self iPhotoApplicationVersion] >= 1.1f;
}

+ (CGFloat)iPhotoApplicationVersion
{
    NSString *bundleID = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"iPhotoBundleId" value:@"" table:@"LibraryGraphicsiPhoto"];
    NSBundle *bundle = [self applicationBundleForBundleID:bundleID creator:'iPho'];
    if (bundle == nil)
        return 0;
    return [[[bundle infoDictionary] objectForKey:iPhotoShortVersionKey] floatValue];
}

+ (id)iPhotoRecentDatabases
{
    return [self iAppsRecentDatabasesForKeys:[NSArray arrayWithObjects:iPhotoRecentDatabasesKey, iPhotoRecentDatabases1Key, nil]];
}

@end
