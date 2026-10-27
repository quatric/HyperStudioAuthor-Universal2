#import "HyperPlayerBasePrefix.h"


@interface HSZipArchiver : NSObject
{
}
+ (id)zipExtension;
+ (id)uniqueStringSuffix;
+ (id)fileWrapperForDataZip:(id)aZip;
+ (id)dataZipForFileWrapper:(id)aWrapper;
@end

