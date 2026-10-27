#import "NSBundle+HSCoreGraphicsExtensions.h"
@implementation NSBundle (HSCoreGraphicsExtensions)
- (struct CGImage *)hyperCoreGraphicsImageFromResource:(id)aResource ofType:(id)aType inDirectory:(id)aDirectory forLocalization:(id)aLocalization
{
    NSString *path = [self pathForResource:aResource ofType:aType inDirectory:aDirectory forLocalization:aLocalization];
    return path != nil ? [self NSBundle_HSCoreGraphicsExtensions_coreGraphicsImageFromFilePath:path] : NULL;
}
- (struct CGImage *)hyperCoreGraphicsImageFromResource:(id)aResource ofType:(id)aType inDirectory:(id)aDirectory
{
    NSString *path = [self pathForResource:aResource ofType:aType inDirectory:aDirectory];
    return path != nil ? [self NSBundle_HSCoreGraphicsExtensions_coreGraphicsImageFromFilePath:path] : NULL;
}
- (struct CGImage *)hyperCoreGraphicsImageFromResource:(id)aResource ofType:(id)aType
{
    NSString *path = [self pathForResource:aResource ofType:aType];
    return path != nil ? [self NSBundle_HSCoreGraphicsExtensions_coreGraphicsImageFromFilePath:path] : NULL;
}
// The first image of the file, autoreleased.
- (struct CGImage *)NSBundle_HSCoreGraphicsExtensions_coreGraphicsImageFromFilePath:(id)aPath
{
    NSURL *url = [NSURL fileURLWithPath:aPath];
    if (url == nil)
        return NULL;
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    if (source == NULL)
        return NULL;
    CGImageRef image = NULL;
    if (CGImageSourceGetCount(source) != 0) {
        image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        if (image != NULL)
            CFAutorelease(image);
    }
    CFRelease(source);
    return image;
}
@end
