#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSLiveObjectData : HSShadowedObjectData
{
    unsigned int _deviceIndex;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setDeviceIndex:(NSUInteger)aIndex;
- (NSUInteger)deviceIndex;
- (id)init;
@end

