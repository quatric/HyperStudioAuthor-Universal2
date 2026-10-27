#import "SMKBitmapToolsPrefix.h"


@interface BTPointer : NSObject
{
    void *_pointer;
    void *_disposer;
}
+ (id)wrapperForPointer:(void *)aPointer withDisposer:(void *)aDisposer;
+ (void *)autoreleasedPointer:(void *)aPointer withDisposer:(void *)aDisposer;
- (void *)pointer;
- (void)dealloc;
- (id)init;
- (id)initWithPointer:(void *)aPointer;
- (id)initWithPointer:(void *)aPointer disposer:(void *)aDisposer;
@end

