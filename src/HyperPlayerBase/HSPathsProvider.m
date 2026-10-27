#import "HSPathsProvider.h"

static HSPathsProvider *HSSharedPathsProvider = nil;
static NSString *HSPathsProviderDocumentsFolder = nil;

@implementation HSPathsProvider

/* i386 ivar offsets: _directoriesCache=0x4 */

+ (BOOL)isBundleResourceURL:(id)aURL
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    return [[aURL path] rangeOfString:resourcePath options:NSCaseInsensitiveSearch].length != 0;
}

+ (id)sharedPathsProvider
{
    if (HSSharedPathsProvider == nil)
        HSSharedPathsProvider = [HSPathsProvider new];
    return HSSharedPathsProvider;
}

// Folders remembered in the user defaults, created by the given selector the
// first time.
- (id)imageSequencesFolder
{
    return [self HSPathsProvider_pathForKey:@"HSImageSequencesFolderKey" creationSelector:@selector(HSPathsProvider_picturesFolder)];
}

- (id)googleEarthDocumentsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSGoogleEarthDocumentsFolderKey" creationSelector:NULL];
}

- (id)appleScriptsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderAppleScriptsFolder" creationSelector:@selector(documentsFolder)];
}

- (id)usersDocumentsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderUsersDocumentsFolderKey" creationSelector:@selector(HSPathsProvider_usersDocumentsFolder)];
}

- (id)applicationsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderApplicationsFolder" creationSelector:@selector(HSPathsProvider_applicationsFolder)];
}

- (id)iconLocationFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderIconLocationFolder" creationSelector:@selector(HSPathsProvider_userHomeFolder)];
}

- (id)cursorLocationFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderCursorLocationFolder" creationSelector:@selector(HSPathsProvider_userHomeFolder)];
}

- (id)openLocationFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderOpenLocationFolder" creationSelector:@selector(HSPathsProvider_userHomeFolder)];
}

- (id)hyperStudioDocumentsExportFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderHyperStudioDocumentsExportFolder" creationSelector:@selector(documentsFolder)];
}

- (id)keynoteDocumentsImportFolder
{
    return [self HSPathsProvider_pathForKey:@"HSKeynoteDocumentsImportFolder" creationSelector:@selector(documentsFolder)];
}

- (id)hyperStudioDocumentsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderHyperStudioDocumentsFolder" creationSelector:@selector(documentsFolder)];
}

- (id)mediaObjectsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderMediaObjectsFolder" creationSelector:@selector(HSPathsProvider_moviesFolder)];
}

- (id)easyLinkFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderEasyLinkFolder" creationSelector:@selector(HSPathsProvider_userHomeFolder)];
}

- (id)generalTypeFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderGeneralTypeFolder" creationSelector:@selector(HSPathsProvider_userHomeFolder)];
}

- (id)picturesFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderPicturesFolder" creationSelector:@selector(HSPathsProvider_picturesFolder)];
}

- (id)musicFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderMusicFolder" creationSelector:@selector(HSPathsProvider_musicFolder)];
}

- (id)moviesFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderMoviesFolder" creationSelector:@selector(HSPathsProvider_moviesFolder)];
}

- (id)textDocumentsFolder
{
    return [self HSPathsProvider_pathForKey:@"HSPathsProviderTextDocumentsFolder" creationSelector:@selector(documentsFolder)];
}

- (id)defaultHomeStackPath
{
    if (_directoriesCache.defaultHomeStackPath == nil)
        _directoriesCache.defaultHomeStackPath = [[[NSBundle mainBundle] pathForResource:@"Home Stack" ofType:@"stack"] retain];
    return _directoriesCache.defaultHomeStackPath;
}

- (id)libraryMoviesFolder
{
    if (_directoriesCache.libraryMoviesFolder == nil)
        _directoriesCache.libraryMoviesFolder = [[self HSPathsProvider_moviesFolder] retain];
    return _directoriesCache.libraryMoviesFolder;
}

- (id)temporaryFolder
{
    return NSTemporaryDirectory();
}

- (id)documentsFolder
{
    if (HSPathsProviderDocumentsFolder == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] != 0)
            HSPathsProviderDocumentsFolder = [[paths objectAtIndex:0] retain];
    }
    return HSPathsProviderDocumentsFolder;
}

- (id)preferencesFolder
{
    if (_directoriesCache.preferencesFolder == nil)
        _directoriesCache.preferencesFolder = [[self HSPathsProvider_preferencesFolderForDomain:NSUserDomainMask] retain];
    return _directoriesCache.preferencesFolder;
}

- (id)localApplicationSupportFolder
{
    if (_directoriesCache.localApplicationSupportFolder == nil)
        _directoriesCache.localApplicationSupportFolder = [[self HSPathsProvider_applicationSupportFolderForDomain:NSLocalDomainMask] retain];
    return _directoriesCache.localApplicationSupportFolder;
}

- (id)applicationSupportFolder
{
    if (_directoriesCache.applicationSupportFolder == nil)
        _directoriesCache.applicationSupportFolder = [[self HSPathsProvider_applicationSupportFolderForDomain:NSUserDomainMask] retain];
    return _directoriesCache.applicationSupportFolder;
}

- (id)readyMadeCardsLocalSupportFolder
{
    return [[self hyperStudioLocalSupportFolder] stringByAppendingPathComponent:@"Ready Made Cards"];
}

- (id)readyMadeCardsSupportFolder
{
    return [[self hyperStudioSupportFolder] stringByAppendingPathComponent:@"Ready Made Cards"];
}

- (id)readyMadeCardsFolder
{
    return [[[NSBundle bundleForClass:NSClassFromString(@"HSReadyMadeCardsProvider")] resourcePath] stringByAppendingPathComponent:@"Ready Made Cards"];
}

- (id)sampleProjectsFolder
{
    return [[[self defaultTutorialStackName] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Sample Projects"];
}

- (id)readyMadeAnimationsFolder
{
    return [[self readyMadeLibraryFolder] stringByAppendingPathComponent:@"Animation"];
}

- (id)readyMadePatternsFolder
{
    return [[self readyMadeLibraryFolder] stringByAppendingPathComponent:@"Patterns"];
}

- (id)readyMadeSoundsFolder
{
    return [[self readyMadeLibraryFolder] stringByAppendingPathComponent:@"Sounds"];
}

- (id)readyMadePicturesFolder
{
    return [[self readyMadeLibraryFolder] stringByAppendingPathComponent:@"Photos"];
}

// The media library inside the application, else the installed one.
- (id)mediaSoundFolder
{
    NSString *folder = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Media Library"] stringByAppendingPathComponent:@"Sounds"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder])
        folder = [[self hyperStudioLocalSupportFolder] stringByAppendingPathComponent:@"Sounds"];
    return folder;
}

- (id)readyMadeLibraryFolder
{
    NSString *folder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Media Library"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder])
        folder = [[self hyperStudioLocalSupportFolder] stringByAppendingPathComponent:@"Media Library"];
    return folder;
}

- (id)thumbnailsImagesFolder
{
    return [[self thumbnailsFolder] stringByAppendingPathComponent:@"Images"];
}

- (id)thumbnailsFilePath
{
    return [[self thumbnailsFolder] stringByAppendingPathComponent:@"Thumbnails.plist"];
}

- (id)thumbnailsFolder
{
    return [[self hyperStudioSupportFolder] stringByAppendingPathComponent:@"Thumbnails"];
}

- (id)libraryMediaAccessorFolder
{
    return [[self hyperStudioSupportFolder] stringByAppendingPathComponent:@"Media Accessor"];
}

- (id)userMediaFolder
{
    return [[self userLibraryFolder] stringByAppendingPathComponent:@"User Media"];
}

- (id)userLibraryFilePath
{
    return [[self userLibraryFolder] stringByAppendingPathComponent:@"UserLibraries.plist"];
}

- (id)userLibraryFolder
{
    return [[self hyperStudioSupportFolder] stringByAppendingPathComponent:@"User Libraries"];
}

- (id)hyperStudioLocalSupportFolder
{
    NSString *name = [self HSPathsProvider_applicationSupportName];
    if (name == nil)
        return nil;
    return [[self HSPathsProvider_localMacKievSupportFolder] stringByAppendingPathComponent:name];
}

- (id)hyperStudioSupportFolder
{
    NSString *name = [self HSPathsProvider_applicationSupportName];
    if (name == nil)
        return nil;
    return [[self HSPathsProvider_macKievSupportFolder] stringByAppendingPathComponent:name];
}

// From the Info.plist, else the executable name.
- (id)HSPathsProvider_applicationSupportName
{
    NSBundle *bundle = [NSBundle mainBundle];
    id name = [bundle objectForInfoDictionaryKey:@"HSApplicationSupportName"];
    if (name == nil)
        name = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleExecutableKey];
    return name;
}

- (void)dealloc
{
    [_directoriesCache.applicationSupportFolder release];
    [_directoriesCache.localApplicationSupportFolder release];
    [_directoriesCache.macKievSupportFolder release];
    [_directoriesCache.localMacKievSupportFolder release];
    [_directoriesCache.libraryMoviesFolder release];
    [_directoriesCache.defaultHomeStackPath release];
    [_directoriesCache.defaultTutorialStackPath release];
    [_directoriesCache.preferencesFolder release];
    [super dealloc];
}

@end

@implementation HSPathsProvider (PredefinedPathsCreation)

- (id)HSPathsProvider_usersDocumentsFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths count] != 0 ? [paths objectAtIndex:0] : nil;
}

- (id)HSPathsProvider_applicationsFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES);
    return [paths count] != 0 ? [paths objectAtIndex:0] : nil;
}

- (id)HSPathsProvider_userHomeFolder
{
    return NSHomeDirectory();
}

- (id)HSPathsProvider_picturesFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
}

- (id)HSPathsProvider_musicFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Music"];
}

- (id)HSPathsProvider_moviesFolder
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Movies"];
}

@end

@implementation HSPathsProvider (PathsUpdating)

- (void)setImageSequencesFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSImageSequencesFolderKey"];
}

- (void)setGoogleEarthDocumentsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSGoogleEarthDocumentsFolderKey"];
}

- (void)setAppleScriptsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderAppleScriptsFolder"];
}

- (void)setUsersDocumentsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderUsersDocumentsFolderKey"];
}

- (void)setApplicationsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderApplicationsFolder"];
}

- (void)setIconLocationFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderIconLocationFolder"];
}

- (void)setCursorLocationFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderCursorLocationFolder"];
}

- (void)setOpenLocationFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderOpenLocationFolder"];
}

- (void)setHyperStudioDocumentsExportFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderHyperStudioDocumentsExportFolder"];
}

- (void)setKeynoteDocumentsImportFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSKeynoteDocumentsImportFolder"];
}

- (void)setHyperStudioDocumentsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderHyperStudioDocumentsFolder"];
}

- (void)setMediaObjectsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderMediaObjectsFolder"];
}

- (void)setEasyLinkFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderEasyLinkFolder"];
}

- (void)setGeneralTypeFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderGeneralTypeFolder"];
}

- (void)setTextDocumentsFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderTextDocumentsFolder"];
}

- (void)setMusicFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderMusicFolder"];
}

- (void)setMoviesFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderMoviesFolder"];
}

- (void)setPicturesFolder:(id)aFolder
{
    [[NSUserDefaults standardUserDefaults] setObject:aFolder forKey:@"HSPathsProviderPicturesFolder"];
}
@end

@implementation HSPathsProvider (Private)

- (id)HSPathsProvider_localMacKievSupportFolder
{
    if (_directoriesCache.localMacKievSupportFolder == nil)
        _directoriesCache.localMacKievSupportFolder = [[[self localApplicationSupportFolder] stringByAppendingPathComponent:@"Software MacKiev"] retain];
    return _directoriesCache.localMacKievSupportFolder;
}

- (id)HSPathsProvider_macKievSupportFolder
{
    if (_directoriesCache.macKievSupportFolder == nil)
        _directoriesCache.macKievSupportFolder = [[[self applicationSupportFolder] stringByAppendingPathComponent:@"Software MacKiev"] retain];
    return _directoriesCache.macKievSupportFolder;
}

- (id)HSPathsProvider_preferencesFolderForDomain:(NSUInteger)aDomain
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, aDomain, YES);
    if ([paths count] == 0)
        return nil;
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences"];
}

// The pre-Tiger Library/Application Support fallback is dropped.
- (id)HSPathsProvider_applicationSupportFolderForDomain:(NSUInteger)aDomain
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, aDomain, YES);
    if ([paths count] == 0)
        return nil;
    return [paths objectAtIndex:0];
}

// The original performed a NULL creation selector too, which raises; a key
// without one simply stays unset.
- (id)HSPathsProvider_pathForKey:(id)aKey creationSelector:(SEL)aSelector
{
    id path = [[NSUserDefaults standardUserDefaults] stringForKey:aKey];
    if (path == nil && aSelector != NULL) {
        path = [self performSelector:aSelector];
        if (path != nil)
            [[NSUserDefaults standardUserDefaults] setObject:path forKey:aKey];
    }
    return path;
}

@end
