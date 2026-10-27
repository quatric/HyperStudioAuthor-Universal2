#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryMoviesHelper : NSObject
{
}
+ (id)resolveOSXAlias:(id)aAlias;
+ (id)movieUserObjectClassName;
+ (id)defaultAttributes:(id)aAttributes;
+ (id)animationsFileTypes;
+ (id)hyperStudioMoviesFolders;
+ (id)animationsFolders;
+ (id)movieFileTypes;
+ (id)movieFolders;
+ (void)plainScanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass;
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toDictionary:(id)aDictionary insertClass:(Class)aClass;
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass;
@end

