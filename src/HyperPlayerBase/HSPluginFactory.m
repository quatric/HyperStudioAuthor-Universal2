#import "HSPluginFactory.h"
// Loads plug-in bundles from a folder (subclasses name the extensions) and
// keeps one instance of each bundle's principal class, newest version first.
@implementation HSPluginFactory
- (void)removePluginAtIndex:(NSInteger)aIndex
{
    NSBundle *bundle = [[_plugins objectAtIndex:aIndex] hyperPluginBundle];
    if ([bundle isLoaded] && [bundle respondsToSelector:@selector(unload)])
        [bundle unload];
    [_plugins removeObjectAtIndex:aIndex];
}
- (void)setPlugins:(id)aPlugins
{
    if (_plugins == aPlugins)
        return;
    [_plugins release];
    _plugins = [aPlugins retain];
}
- (id)plugins
{
    return _plugins;
}
- (void)loadPluginsAtPath:(id)aPath
{
    for (NSString *name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:NULL]) {
        NSString *path = [[aPath stringByAppendingPathComponent:name] stringByResolvingSymlinksInPath];
        for (NSString *extension in [self pluginExtensions]) {
            if (![[path pathExtension] isEqualToString:extension])
                continue;
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            if (bundle != nil) {
                [self registerPlugin:bundle];
                break;
            }
        }
    }
}
// A bundle already registered in the same or a newer version counts as
// registered; an older one is replaced.
- (BOOL)registerPlugin:(NSBundle *)aPlugin
{
    // (The original kept the count from before the loop and stepped past
    // the entry after a removed one.)
    for (NSUInteger i = 0; i < [_plugins count];) {
        NSBundle *bundle = [[_plugins objectAtIndex:i] hyperPluginBundle];
        if ([[bundle bundleIdentifier] isEqualToString:[aPlugin bundleIdentifier]]) {
            if ([bundle hyperCompareVersionWithVersionOfBundle:aPlugin] != NSOrderedAscending)
                return YES;
            [self removePluginAtIndex:i];
            continue;
        }
        i++;
    }
    Class principalClass = [aPlugin principalClass];
    if (principalClass != Nil && [aPlugin load] && [self checkPluginInterface:principalClass]) {
        id instance = [[principalClass allocWithZone:[self zone]] init];
        if (instance == nil)
            return NO;
        NSMutableDictionary *plugin = [NSMutableDictionary dictionaryWithCapacity:0];
        [plugin setHyperPluginBundle:aPlugin];
        [plugin setHyperPluginInterface:instance];
        [instance release];
        [_plugins addObject:plugin];
        return YES;
    }
    if ([aPlugin isLoaded] && [aPlugin respondsToSelector:@selector(unload)])
        [aPlugin unload];
    return NO;
}
- (BOOL)registerClass:(Class)aClass
{
    if (![self checkPluginInterface:aClass])
        return NO;
    id instance = [[aClass allocWithZone:[self zone]] init];
    if (instance == nil)
        return NO;
    NSMutableDictionary *plugin = [NSMutableDictionary dictionaryWithCapacity:0];
    [plugin setHyperPluginInterface:instance];
    [instance release];
    [_plugins addObject:plugin];
    return YES;
}
- (BOOL)checkPluginInterface:(Class)aInterface
{
    return aInterface != Nil;
}
// Subclasses return the plug-in file extensions.
- (id)pluginExtensions
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
- (void)dealloc
{
    [_plugins release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _plugins = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    return self;
}
@end
@implementation NSMutableDictionary (PluginFactory)
- (void)setHyperPluginInterface:(id)aInterface
{
    [self setObject:aInterface forKey:pluginInterfaceKey];
}
- (void)setHyperPluginBundle:(id)aBundle
{
    [self setObject:aBundle forKey:pluginBundleKey];
}
@end
@implementation NSDictionary (PluginFactory)
- (id)pluginInterface
{
    return [self objectForKey:pluginInterfaceKey];
}
- (id)hyperPluginBundle
{
    return [self objectForKey:pluginBundleKey];
}
@end
@implementation NSBundle (NSBundleSupportVersionComparison)
- (id)hyperBundleVersionString
{
    return [[self infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}
- (NSInteger)hyperCompareVersionWithVersionOfBundle:(id)aBundle
{
    return [[self hyperBundleVersionString] compare:[aBundle hyperBundleVersionString] options:NSNumericSearch];
}
@end
