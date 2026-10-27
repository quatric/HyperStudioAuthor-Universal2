#import "HyperEditorBasePrefix.h"


@interface HSLibrarySoundsHelper : NSObject
{
}
+ (id)soundUserObjectClassName;
+ (id)defaultAttributes:(id)aAttributes;
+ (id)soundsFileTypes;
+ (id)soundsFolders;
+ (void)plainScanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass;
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toDictionary:(id)aDictionary insertClass:(Class)aClass;
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass;
@end

