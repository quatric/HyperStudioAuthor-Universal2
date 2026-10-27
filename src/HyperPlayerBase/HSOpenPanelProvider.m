#import "HSOpenPanelProvider.h"
// Open panels for kinds of files, each starting in (and remembering) the
// folder last used for its kind, kept by HSPathsProvider.
@implementation HSOpenPanelProvider
+ (id)sharedOpenPanelProvider
{
    static HSOpenPanelProvider *provider = nil;
    if (provider == nil)
        provider = [HSOpenPanelProvider new];
    return [[provider retain] autorelease];
}
- (void)setTypeToFolderMapValue:(id)aValue forKey:(id)aKey
{
    SEL setter = [self setterSelectorForFileType:aKey];
    [[self fileTypeToFolderMap] setObject:aValue forKey:aKey];
    if (setter != NULL)
        [[HSPathsProvider sharedPathsProvider] performSelector:setter withObject:aValue];
}
- (id)fileTypeToFolderMap
{
    if (_fileTypeToFolderMap == nil) {
        HSPathsProvider *paths = [HSPathsProvider sharedPathsProvider];
        _fileTypeToFolderMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            [paths generalTypeFolder], @"HSAnyFileType",
            [paths picturesFolder], @"HSImageFileType",
            [paths moviesFolder], @"HSMovieFileType",
            [paths musicFolder], @"HSSoundFileType",
            [paths textDocumentsFolder], @"HSTextFileType",
            [paths mediaObjectsFolder], @"HSMediaFileType",
            [paths usersDocumentsFolder], @"kHSUsersDocumentsFileType",
            [paths applicationsFolder], @"kHSApplicationsFileType", nil];
    }
    return _fileTypeToFolderMap;
}
- (SEL)setterSelectorForFileType:(id)aType
{
    static NSDictionary *setters = nil;
    if (setters == nil)
        setters = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSValue valueWithPointer:@selector(setGeneralTypeFolder:)], @"HSAnyFileType",
            [NSValue valueWithPointer:@selector(setPicturesFolder:)], @"HSImageFileType",
            [NSValue valueWithPointer:@selector(setMoviesFolder:)], @"HSMovieFileType",
            [NSValue valueWithPointer:@selector(setMusicFolder:)], @"HSSoundFileType",
            [NSValue valueWithPointer:@selector(setTextDocumentsFolder:)], @"HSTextFileType",
            [NSValue valueWithPointer:@selector(setMediaObjectsFolder:)], @"HSMediaFileType",
            [NSValue valueWithPointer:@selector(setUsersDocumentsFolder:)], @"kHSUsersDocumentsFileType",
            [NSValue valueWithPointer:@selector(setApplicationsFolder:)], @"kHSApplicationsFileType",
            [NSValue valueWithPointer:@selector(setGoogleEarthDocumentsFolder:)], @"kHSGoogleEarthFileType", nil];
    return (SEL)[[setters objectForKey:aType] pointerValue];
}
// Empty for any file, nil for documents.
- (id)supportedTypesForFileType:(id)aType
{
    NSMutableArray *types = [NSMutableArray array];
    if ([aType isEqual:@"HSMovieFileType"])
        [types addObjectsFromArray:[HSNewMediaAccessor supportedMediaTypesForClass:@"HSMovieObject"]];
    else if ([aType isEqual:@"HSImageFileType"])
        [types addObjectsFromArray:[HSNewMediaAccessor supportedMediaTypesForClass:@"HSImageObject"]];
    else if ([aType isEqual:@"HSSoundFileType"])
        [types addObjectsFromArray:[HSNewMediaAccessor supportedMediaTypesForClass:@"HSPlaySoundAction"]];
    else if ([aType isEqual:@"HSTextFileType"])
        [types addObjectsFromArray:[NSAttributedString textUnfilteredFileTypes]];
    else if ([aType isEqual:@"HSMediaFileType"])
        [types addObjectsFromArray:[HSNewMediaAccessor supportedMediaTypesForClass:@"HSMovieObject"]];
    else if ([aType isEqual:@"kHSApplicationsFileType"])
        [types addObject:@"app"];
    else if ([aType isEqual:@"kHSGoogleEarthFileType"])
        [types addObjectsFromArray:[HSNewMediaAccessor supportedMediaTypesForClass:@"HSGoogleEarthAction"]];
    else if ([aType isEqual:@"kHSUsersDocumentsFileType"])
        return nil;
    return types;
}
// The delegate gets (nil, its context).
static NSOpenPanel *HSOpenPanelForTypes(NSArray *aTypes, NSString *aFolder)
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    if (aFolder != nil)
        [panel setDirectoryURL:[NSURL fileURLWithPath:aFolder isDirectory:YES]];
    // (No types meant any file.)
    [panel setAllowedFileTypes:[aTypes count] != 0 ? aTypes : nil];
    return panel;
}
// (Through the block-based sheet, as beginSheetForDirectory:… is gone.)
- (void)beginSheetForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector fileType:(id)aType accessoryView:(id)aView contextInfo:(void *)aInfo
{
    NSOpenPanel *panel = HSOpenPanelForTypes([self supportedTypesForFileType:aType], [[self fileTypeToFolderMap] objectForKey:aType]);
    [panel setAccessoryView:aView];
    _modalDelegate = aDelegate;
    _didEndSelector = aSelector;
    _contextInfo = aInfo;
    [panel beginSheetModalForWindow:aWindow completionHandler:^(NSModalResponse aResult) {
        [self sheetDidEnd:panel returnCode:aResult contextInfo:(void *)aType];
    }];
}
// The original returned nil whatever was chosen (it only remembers the
// folder).
- (id)chooseFileOfType:(id)aType
{
    NSOpenPanel *panel = HSOpenPanelForTypes([self supportedTypesForFileType:aType], [[self fileTypeToFolderMap] objectForKey:aType]);
    if ([panel runModal] == NSModalResponseOK && [[panel URLs] count] != 0) {
        NSString *path = [[[panel URLs] objectAtIndex:0] path];
        if (path != nil)
            [self setTypeToFolderMapValue:[path stringByDeletingLastPathComponent] forKey:aType];
    }
    return nil;
}
- (void)dealloc
{
    [_fileTypeToFolderMap release];
    [super dealloc];
}
@end
