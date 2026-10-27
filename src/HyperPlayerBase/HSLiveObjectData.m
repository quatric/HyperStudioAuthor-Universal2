#import "HSLiveObjectData.h"
@implementation HSLiveObjectData
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        [keys addObject:@"deviceIndex"];
    [keys addObject:@"opacity"];
    return keys;
}
- (void)setDeviceIndex:(NSUInteger)aIndex
{
    _deviceIndex = (unsigned int)aIndex;
}
- (NSUInteger)deviceIndex
{
    return _deviceIndex;
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _deviceIndex = 0;
    return self;
}
@end
