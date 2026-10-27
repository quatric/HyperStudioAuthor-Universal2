#import "HyperEditorBasePrefix.h"


@interface HSLibraryPicturesHelper : NSObject
{
}
+ (id)imageUserObjectClassName;
+ (id)defaultAttributes:(id)aAttributes;
+ (id)patternsFileTypes;
+ (id)patternsFolders;
+ (id)picturesFileTypes;
+ (id)picturesFolders;
+ (void)plainScanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass;
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toDictionary:(id)aDictionary insertClass:(Class)aClass;
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass;
@end

