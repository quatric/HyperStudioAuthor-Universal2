#import "HSSimpleArchiver.h"
@implementation HSSimpleArchiver
+ (id)methodKey
{
    return @"HSSimpleArchivingMethod";
}
- (id)uncompressData:(id)aData
{
    return [aData hyperDataWithGzipUnpack];
}
- (id)compressData:(id)aData
{
    return [aData hyperDataWithGzipPack];
}
- (id)description
{
    return [[NSBundle mainBundle] localizedStringForKey:@"HSSimpleArchivingDescription" value:@"" table:nil];
}
- (id)archivingMethod
{
    return [[NSBundle mainBundle] localizedStringForKey:@"HSSimpleArchivingMethod" value:@"" table:nil];
}
@end
@implementation HSSimpleArchiver (Private)
// Logs a zlib error (the zpipe example's zerr).
- (void)zerror:(NSInteger)aZerror
{
    NSString *message = nil;
    switch (aZerror) {
    case Z_VERSION_ERROR: message = @"zlib version mismatch!"; break;
    case Z_BUF_ERROR: message = @"there is not enough room in the output buffer"; break;
    case Z_MEM_ERROR: message = @"out of memory"; break;
    case Z_DATA_ERROR: message = @"invalid or incomplete deflate data"; break;
    case Z_STREAM_ERROR: message = @"invalid compression level"; break;
    case Z_ERRNO:
        if (ferror(stdin))
            NSLog(@"error reading stdin");
        if (ferror(stdout))
            message = @"error writing stdout";
        break;
    }
    if (message != nil)
        NSLog(@"%@", message);
    NSLog(@"zlib reports: %s", zError((int)aZerror));
}
@end
