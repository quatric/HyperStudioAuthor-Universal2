#import "HyperPlayerBasePrefix.h"


@interface HSSimpleArchiver : NSObject <HSArchivingMethod, HSArchiving, NSObject>
{
}
+ (id)methodKey;
- (id)uncompressData:(id)aData;
- (id)compressData:(id)aData;
- (id)description;
- (id)archivingMethod;
@end

@interface HSSimpleArchiver (Private)
- (void)zerror:(NSInteger)aZerror;
@end

