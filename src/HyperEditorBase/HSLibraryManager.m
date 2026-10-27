#import "HSLibraryManager.h"

// The media library plug-ins (.library), their data providers by media
// type, and the content filters the app registers.

@implementation HSLibraryManager

static HSLibraryManager *sharedLibraryManager;

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sharedLibraryManager == nil) {
            sharedLibraryManager = [super allocWithZone:aZone];
            return sharedLibraryManager;
        }
    }
    return nil;
}

// Loads the app's built-in plug-ins the first time.
+ (id)sharedLibraryManager
{
    @synchronized (self) {
        if (sharedLibraryManager == nil) {
            [[self alloc] init];
            [sharedLibraryManager loadPluginsAtPath:[[NSBundle mainBundle] builtInPlugInsPath]];
            [[NSNotificationCenter defaultCenter] addObserver:sharedLibraryManager selector:@selector(applicationTerminate:) name:NSApplicationWillTerminateNotification object:nil];
        }
    }
    return sharedLibraryManager;
}

// Indexes the plug-in just registered, and its data providers.
- (void)addLastLibraryPlugin
{
    id plugin = [[[self plugins] objectAtIndex:[[self plugins] count] - 1] pluginInterface];
    id type = [plugin pluginType];
    if (type != nil)
        [_libraryPlugins setObject:plugin forKey:type];
    for (id provider in [plugin dataProviders]) {
        [_libraryDataProviders setObject:provider forKey:[provider mediaType]];
        if ([provider queryInterface:@protocol(HSLibrarySharedMedia)] != nil)
            [_sharedProviders addObject:provider];
    }
}

- (void)applicationTerminate:(id)aTerminate
{
    [self saveUserLibrariesResources];
    [self autorelease];
}

- (void)saveUserLibrariesResources
{
}

- (void)mediaProvider:(id)aProvider changeItem:(id)aItem
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    if (aProvider != nil)
        [userInfo setObject:aProvider forKey:HSLibraryMediaManagerChangedItemProviderKey];
    if (aItem != nil)
        [userInfo setObject:aItem forKey:HSLibraryMediaManagerChangedItemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSLibraryMediaManagerItemChangedNotificationName object:self userInfo:userInfo];
}

- (id)sharedProviders
{
    return _sharedProviders;
}

- (id)providerForMediaType:(id)aType
{
    return [_libraryDataProviders objectForKey:aType];
}

- (id)availableMediaTypes
{
    return [_libraryDataProviders allKeys];
}

- (id)pluginForLibraryType:(id)aType
{
    return [_libraryPlugins objectForKey:aType];
}

- (id)libraryTypes
{
    return [_libraryPlugins allKeys];
}

- (void)registerSoundsContentFilter:(id)aFilter
{
    if (_soundsContentFilter != aFilter) {
        [_soundsContentFilter release];
        _soundsContentFilter = [aFilter retain];
    }
}

- (id)soundsContentFilter
{
    return _soundsContentFilter;
}

- (void)registerMoviesContentFilter:(id)aFilter
{
    if (_moviesContentFilter != aFilter) {
        [_moviesContentFilter release];
        _moviesContentFilter = [aFilter retain];
    }
}

- (id)moviesContentFilter
{
    return _moviesContentFilter;
}

- (void)registerMediaContentFilter:(id)aFilter
{
    if (_mediaContentFilter != aFilter) {
        [_mediaContentFilter release];
        _mediaContentFilter = [aFilter retain];
    }
}

- (id)mediaContentFilter
{
    return _mediaContentFilter;
}

- (void)removePluginAtIndex:(NSInteger)aIndex
{
    id type = [[[[self plugins] objectAtIndex:aIndex] pluginInterface] pluginType];
    if (type != nil)
        [_libraryPlugins removeObjectForKey:type];
    [super removePluginAtIndex:aIndex];
}

- (BOOL)registerPlugin:(id)aPlugin
{
    BOOL registered = [super registerPlugin:aPlugin];
    if (registered)
        [self addLastLibraryPlugin];
    return registered;
}

- (BOOL)registerClass:(Class)aClass
{
    BOOL registered = [super registerClass:aClass];
    if (registered)
        [self addLastLibraryPlugin];
    return registered;
}

- (BOOL)checkPluginInterface:(Class)aInterface
{
    return aInterface != Nil && [aInterface conformsToProtocol:@protocol(HSLibraryPlugin)];
}

- (id)pluginExtensions
{
    return [NSArray arrayWithObject:@"library"];
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_libraryPlugins release];
    [_libraryDataProviders release];
    [_sharedProviders release];
    [_mediaContentFilter release];
    [_moviesContentFilter release];
    [_soundsContentFilter release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        _libraryPlugins = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
        _libraryDataProviders = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
        _sharedProviders = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
