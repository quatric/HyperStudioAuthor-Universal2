#import "HyperPlayerBasePrefix.h"


@interface HSPathsProvider : NSObject
{
    struct HyperPlayerBase_anon7 _directoriesCache;
}
+ (BOOL)isBundleResourceURL:(id)aURL;
+ (id)sharedPathsProvider;
- (id)imageSequencesFolder;
- (id)googleEarthDocumentsFolder;
- (id)appleScriptsFolder;
- (id)usersDocumentsFolder;
- (id)applicationsFolder;
- (id)iconLocationFolder;
- (id)cursorLocationFolder;
- (id)openLocationFolder;
- (id)hyperStudioDocumentsExportFolder;
- (id)keynoteDocumentsImportFolder;
- (id)hyperStudioDocumentsFolder;
- (id)mediaObjectsFolder;
- (id)easyLinkFolder;
- (id)generalTypeFolder;
- (id)picturesFolder;
- (id)musicFolder;
- (id)moviesFolder;
- (id)textDocumentsFolder;
- (id)defaultTutorialStackName;
- (id)defaultHomeStackPath;
- (id)libraryMoviesFolder;
- (id)temporaryFolder;
- (id)documentsFolder;
- (id)preferencesFolder;
- (id)localApplicationSupportFolder;
- (id)applicationSupportFolder;
- (id)readyMadeCardsLocalSupportFolder;
- (id)readyMadeCardsSupportFolder;
- (id)readyMadeCardsFolder;
- (id)sampleProjectsFolder;
- (id)readyMadeAnimationsFolder;
- (id)readyMadePatternsFolder;
- (id)readyMadeSoundsFolder;
- (id)readyMadePicturesFolder;
- (id)mediaSoundFolder;
- (id)readyMadeLibraryFolder;
- (id)thumbnailsImagesFolder;
- (id)thumbnailsFilePath;
- (id)thumbnailsFolder;
- (id)libraryMediaAccessorFolder;
- (id)userMediaFolder;
- (id)userLibraryFilePath;
- (id)userLibraryFolder;
- (id)hyperStudioLocalSupportFolder;
- (id)hyperStudioSupportFolder;
- (id)HSPathsProvider_applicationSupportName;
- (void)dealloc;
@end

@interface HSPathsProvider (PredefinedPathsCreation)
- (id)HSPathsProvider_usersDocumentsFolder;
- (id)HSPathsProvider_applicationsFolder;
- (id)HSPathsProvider_userHomeFolder;
- (id)HSPathsProvider_picturesFolder;
- (id)HSPathsProvider_musicFolder;
- (id)HSPathsProvider_moviesFolder;
@end

@interface HSPathsProvider (PathsUpdating)
- (void)setImageSequencesFolder:(id)aFolder;
- (void)setGoogleEarthDocumentsFolder:(id)aFolder;
- (void)setAppleScriptsFolder:(id)aFolder;
- (void)setUsersDocumentsFolder:(id)aFolder;
- (void)setApplicationsFolder:(id)aFolder;
- (void)setIconLocationFolder:(id)aFolder;
- (void)setCursorLocationFolder:(id)aFolder;
- (void)setOpenLocationFolder:(id)aFolder;
- (void)setHyperStudioDocumentsExportFolder:(id)aFolder;
- (void)setKeynoteDocumentsImportFolder:(id)aFolder;
- (void)setHyperStudioDocumentsFolder:(id)aFolder;
- (void)setMediaObjectsFolder:(id)aFolder;
- (void)setEasyLinkFolder:(id)aFolder;
- (void)setGeneralTypeFolder:(id)aFolder;
- (void)setTextDocumentsFolder:(id)aFolder;
- (void)setMusicFolder:(id)aFolder;
- (void)setMoviesFolder:(id)aFolder;
- (void)setPicturesFolder:(id)aFolder;
@end

@interface HSPathsProvider (Private)
- (id)HSPathsProvider_localMacKievSupportFolder;
- (id)HSPathsProvider_macKievSupportFolder;
- (id)HSPathsProvider_preferencesFolderForDomain:(NSUInteger)aDomain;
- (id)HSPathsProvider_applicationSupportFolderForDomain:(NSUInteger)aDomain;
- (id)HSPathsProvider_pathForKey:(id)aKey creationSelector:(SEL)aSelector;
@end

