#import "HSLibrarySoundsHelper.h"
#import "HSLibraryScanning.h"

@implementation HSLibrarySoundsHelper

+ (id)soundUserObjectClassName
{
    return NSStringFromClass([HSPlaySoundAction class]);
}

+ (id)defaultAttributes:(id)aAttributes
{
    return HSLibraryDefaultAttributes(aAttributes);
}

+ (id)soundsFileTypes
{
    static NSMutableArray *types;
    if (types == nil)
        types = [[NSMutableArray alloc] initWithArray:[HSNewMediaAccessor supportedMediaTypesForClass:[self soundUserObjectClassName]]];
    return types;
}

// The folders in the ready-made sounds folder.
+ (id)soundsFolders
{
    return HSLibraryFolderContents([[HSPathsProvider sharedPathsProvider] readyMadeSoundsFolder]);
}

+ (void)plainScanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass
{
    HSLibraryPlainScanDirectory(aDirectory, aTypes, aArray, aClass);
}

+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toDictionary:(id)aDictionary insertClass:(Class)aClass
{
    HSLibraryScanDirectoryToDictionary([self class], aDirectory, aTypes, aDictionary, aClass);
}

+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass
{
    HSLibraryScanDirectoryToArray([self class], aDirectory, aTypes, aArray, aClass);
}

@end
