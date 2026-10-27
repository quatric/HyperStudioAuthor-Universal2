#import "HyperPlayerBasePrefix.h"


@interface HSDataArchiver : NSObject <HSArchiving, NSObject>
{
    NSMutableDictionary *_archivers;
    NSString *_currentMethodKey;
}
- (id)uncompressData:(id)aData;
- (id)compressData:(id)aData;
- (id)description;
- (id)archivingMethod;
- (void)selectMethodWithKey:(id)aKey;
- (id)currentMethodKey;
- (void)addArchiver:(id)aArchiver;
- (id)methodKeyEnumerator;
- (id)archivingMethodKeys;
- (void)dealloc;
- (id)init;
@end

