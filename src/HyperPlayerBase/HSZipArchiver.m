#import "HSZipArchiver.h"
@implementation HSZipArchiver
+ (id)zipExtension
{
    return @"zip";
}
+ (id)uniqueStringSuffix
{
    return [NSString stringWithFormat:@"-%@", [NSString hyperUIDString]];
}
// The original removed the temporary files with -removeFileAtPath:handler:,
// which is gone from the SDK; -removeItemAtPath:error: does the same.
static void HSZipArchiverRemoveTemporaryFiles(NSString *aSource, NSString *aTarget)
{
    [[NSFileManager defaultManager] removeItemAtPath:aSource error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:aTarget error:NULL];
}
+ (id)fileWrapperForDataZip:(id)aZip
{
    // A data zip is a stored zip whose "PK" signature was changed to "HS"
    // (+dataZipForFileWrapper:); 22 bytes is the smallest zip (an empty
    // end-of-central-directory record).
    if (aZip == nil || [aZip length] < 22)
        return nil;
    NSMutableData *zip = [aZip mutableCopy];
    unsigned char *bytes = [zip mutableBytes];
    bytes[0] = 'P';
    bytes[1] = 'K';
    NSString *folder = [[HSPathsProvider sharedPathsProvider] temporaryFolder];
    NSString *source = [folder stringByAppendingPathComponent:
        [[@"HSZipArchiverSourceFile" stringByAppendingString:[HSZipArchiver uniqueStringSuffix]]
            stringByAppendingPathExtension:[HSZipArchiver zipExtension]]];
    NSString *target = [folder stringByAppendingPathComponent:
        [@"HSZipArchiverTargetFile" stringByAppendingString:[HSZipArchiver uniqueStringSuffix]]];
    HSZipArchiverRemoveTemporaryFiles(source, target);
    BOOL written = [zip writeToFile:source atomically:YES];
    [zip release];
    NSFileWrapper *wrapper = nil;
    if (written) {
        NSTask *task = [[NSTask alloc] init];
        NSFileHandle *null = [NSFileHandle fileHandleWithNullDevice];
        [task setStandardOutput:null];
        [task setStandardError:null];
        [task setCurrentDirectoryPath:[source stringByDeletingLastPathComponent]];
        [task setLaunchPath:@"/usr/bin/unzip"];
        [task setArguments:[NSArray arrayWithObjects:@"-o", [source lastPathComponent], @"-d", [target lastPathComponent], nil]];
        [task launch];
        [task waitUntilExit];
        int status = [task terminationStatus];
        [task release];
        if (status == 0) {
            // Read immediately: the folder is deleted below (the original's
            // -initWithPath: always read the whole tree).
            wrapper = [[[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:target]
                                                  options:NSFileWrapperReadingImmediate error:NULL] autorelease];
        }
    }
    HSZipArchiverRemoveTemporaryFiles(source, target);
    return wrapper;
}
+ (id)dataZipForFileWrapper:(id)aWrapper
{
    if (aWrapper == nil)
        return nil;
    NSString *folder = [[HSPathsProvider sharedPathsProvider] temporaryFolder];
    NSString *source = [folder stringByAppendingPathComponent:
        [@"HSZipArchiverSourceFile" stringByAppendingString:[HSZipArchiver uniqueStringSuffix]]];
    NSString *target = [folder stringByAppendingPathComponent:
        [[@"HSZipArchiverTargetFile" stringByAppendingString:[HSZipArchiver uniqueStringSuffix]]
            stringByAppendingPathExtension:[HSZipArchiver zipExtension]]];
    HSZipArchiverRemoveTemporaryFiles(source, target);
    BOOL written = [aWrapper writeToURL:[NSURL fileURLWithPath:source]
                                options:NSFileWrapperWritingAtomic | NSFileWrapperWritingWithNameUpdating
                    originalContentsURL:nil error:NULL];
    // zip -r -0 <target> . inside the written folder: stored (uncompressed) entries.
    NSTask *task = [[NSTask alloc] init];
    NSFileHandle *null = [NSFileHandle fileHandleWithNullDevice];
    [task setStandardOutput:null];
    [task setStandardError:null];
    [task setCurrentDirectoryPath:source];
    [task setLaunchPath:@"/usr/bin/zip"];
    [task setArguments:[NSArray arrayWithObjects:@"-r", @"-0", target, @".", nil]];
    NSMutableData *data = nil;
    // The original launched zip even when writing the wrapper had failed
    // (NSTask then raised for the missing directory); only launch it on success.
    if (written) {
        [task launch];
        [task waitUntilExit];
        if ([task terminationStatus] == 0) {
            data = [[[NSMutableData alloc] initWithContentsOfFile:target] autorelease];
            if (data != nil && [data length] != 0) {
                unsigned char *bytes = [data mutableBytes];
                bytes[0] = 'H';
                bytes[1] = 'S';
            }
        }
    }
    [task release];
    HSZipArchiverRemoveTemporaryFiles(source, target);
    return data;
}
@end
