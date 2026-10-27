#import "HyperPlayerBasePrefix.h"


@interface HSCFAllocatorHandleContext : NSObject
{
    char **_handle;
    struct HyperPlayerBase_anon4 *_context;
}
- (void)setHandle:(char **)aHandle;
- (char **)handle;
- (struct HyperPlayerBase_anon4 *)context;
- (void)dealloc;
- (id)initWithHandle:(char **)aHandle;
@end

@interface NSData (HSExtension)
+ (id)hyperDataWithHyperHandleNoCopy:(char **)aCopy;
@end

