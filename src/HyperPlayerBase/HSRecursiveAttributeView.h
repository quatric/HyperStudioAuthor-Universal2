#import "HyperPlayerBasePrefix.h"


@interface HSRecursiveAttributeView : NSView
{
    BOOL _enabled;
}
+ (void)initialize;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
@end

