#import "HyperPlayerBasePrefix.h"


@interface HSZipDirectoryWrapper : NSFileWrapper
{
}
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames;
@end

