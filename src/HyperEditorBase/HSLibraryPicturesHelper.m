#import "HSLibraryPicturesHelper.h"
#import "HSLibraryScanning.h"

@implementation HSLibraryPicturesHelper

+ (id)imageUserObjectClassName
{
    return @"HSSystemImageView";
}

+ (id)defaultAttributes:(id)aAttributes
{
    return HSLibraryDefaultAttributes(aAttributes);
}

+ (id)patternsFileTypes
{
    return [NSArray arrayWithObjects:@"png", @"tiff", nil];
}

+ (id)patternsFolders
{
    NSMutableArray *folders = [NSMutableArray arrayWithCapacity:0];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] readyMadePatternsFolder];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folder])
        [folders addObject:folder];
    return folders;
}

+ (id)picturesFileTypes
{
    static NSArray *types;
    if (types == nil)
        types = [[NSArray alloc] initWithArray:[HSUserObject typesForUserObjectClassName:[self imageUserObjectClassName]]];
    return types;
}

// The folders in the ready-made pictures folder.
+ (id)picturesFolders
{
    return HSLibraryFolderContents([[HSPathsProvider sharedPathsProvider] readyMadePicturesFolder]);
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
