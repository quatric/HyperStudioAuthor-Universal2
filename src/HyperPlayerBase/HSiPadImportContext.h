#import "HyperPlayerBasePrefix.h"


@interface HSiPadImportContext : NSObject
{
    HSStack *_stack;
    NSMutableDictionary *_prototypesMap;
}
- (void)setPrototypeObject:(id)aObject forUID:(id)aUID;
- (id)prototypeObjectForUID:(id)aUID;
- (id)stack;
- (void)dealloc;
- (id)initWithStack:(id)aStack;
@end

