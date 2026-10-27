#import "HyperEditorBasePrefix.h"


@interface HSLibraryManager : HSPluginFactory
{
    NSMutableDictionary *_libraryPlugins;
    NSMutableDictionary *_libraryDataProviders;
    NSMutableArray *_sharedProviders;
    id<HSMediaContentFilter> _mediaContentFilter;
    id<HSMediaContentFilter> _moviesContentFilter;
    id<HSMediaContentFilter> _soundsContentFilter;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedLibraryManager;
- (void)addLastLibraryPlugin;
- (void)applicationTerminate:(id)aTerminate;
- (void)saveUserLibrariesResources;
- (void)mediaProvider:(id)aProvider changeItem:(id)aItem;
- (id)sharedProviders;
- (id)providerForMediaType:(id)aType;
- (id)availableMediaTypes;
- (id)pluginForLibraryType:(id)aType;
- (id)libraryTypes;
- (void)registerSoundsContentFilter:(id)aFilter;
- (id)soundsContentFilter;
- (void)registerMoviesContentFilter:(id)aFilter;
- (id)moviesContentFilter;
- (void)registerMediaContentFilter:(id)aFilter;
- (id)mediaContentFilter;
- (void)removePluginAtIndex:(NSInteger)aIndex;
- (BOOL)registerPlugin:(id)aPlugin;
- (BOOL)registerClass:(Class)aClass;
- (BOOL)checkPluginInterface:(Class)aInterface;
- (id)pluginExtensions;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (void)dealloc;
- (id)init;
- (id)copyWithZone:(NSZone *)aZone;
@end

