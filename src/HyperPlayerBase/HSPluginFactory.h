#import "HyperPlayerBasePrefix.h"


@interface HSPluginFactory : NSObject
{
    NSMutableArray *_plugins;
}
- (void)removePluginAtIndex:(NSInteger)aIndex;
- (void)setPlugins:(id)aPlugins;
- (id)plugins;
- (void)loadPluginsAtPath:(id)aPath;
- (BOOL)registerPlugin:(id)aPlugin;
- (BOOL)registerClass:(Class)aClass;
- (BOOL)checkPluginInterface:(Class)aInterface;
- (id)pluginExtensions;
- (void)dealloc;
- (id)init;
@end

@interface NSMutableDictionary (PluginFactory)
- (void)setHyperPluginInterface:(id)aInterface;
- (void)setHyperPluginBundle:(id)aBundle;
@end

@interface NSDictionary (PluginFactory)
- (id)pluginInterface;
- (id)hyperPluginBundle;
@end

@interface NSBundle (NSBundleSupportVersionComparison)
- (id)hyperBundleVersionString;
- (NSInteger)hyperCompareVersionWithVersionOfBundle:(id)aBundle;
@end

