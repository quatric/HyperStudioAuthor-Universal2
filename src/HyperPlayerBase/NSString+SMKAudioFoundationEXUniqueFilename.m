#import "NSString+SMKAudioFoundationEXUniqueFilename.h"
@implementation NSString (SMKAudioFoundationEXUniqueFilename)
+ (id)_audioCreateUniqueFilename:(id)aFilename extension:(id)aExtension
{
    // "Name" -> "Name 1" -> "Name 2"... until no such file exists
    NSString *path = aFilename;
    if ([aExtension length] != 0)
        path = [aFilename stringByAppendingPathExtension:aExtension];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return path;
    NSString *name = [aFilename lastPathComponent];
    NSArray *words = [name componentsSeparatedByString:@" "];
    NSString *lastWord = [words lastObject];
    int number;
    if ([words count] > 1 && (number = [lastWord intValue]) != 0) {
        name = [name substringToIndex:[name length] - [lastWord length] - 1];
        number++;
    } else
        number = 1;
    name = [name stringByAppendingFormat:@" %i", number];
    return [self _audioCreateUniqueFilename:[[aFilename stringByDeletingLastPathComponent] stringByAppendingPathComponent:name]
                                  extension:aExtension];
}
@end
